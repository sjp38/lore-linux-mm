Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9D778E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:43:17 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p15so34841071pfk.7
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:43:17 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c136si53342053pfc.141.2019.01.03.06.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Jan 2019 06:43:16 -0800 (PST)
Date: Thu, 3 Jan 2019 06:43:13 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
Message-ID: <20190103144313.GR6310@bombadil.infradead.org>
References: <20190103002126.GM6310@bombadil.infradead.org>
 <20190103143116.GB3395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190103143116.GB3395@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>

On Thu, Jan 03, 2019 at 09:31:16AM -0500, Jerome Glisse wrote:
> On Wed, Jan 02, 2019 at 04:21:26PM -0800, Matthew Wilcox wrote:
> > 
> > One of the paths in follow_pte_pmd() initialised the mmu_notifier_range
> > incorrectly.
> > 
> > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > Fixes: ac46d4f3c432 ("mm/mmu_notifier: use structure for invalidate_range_start/end calls v2")
> > Tested-by: Dave Chinner <dchinner@redhat.com>
> 
> Actually now that i have read the code again this is not ok to
> do so. The caller of follow_pte_pmd() will call range_init and
> follow pmd will only update the range address. So existing code
> is ok.

I think you need to re-read your own patch.

`git show ac46d4f3c43241ffa23d5bf36153a0830c0e02cc`

@@ -4058,10 +4059,10 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
                if (!pmdpp)
                        goto out;
 
-               if (start && end) {
-                       *start = address & PMD_MASK;
-                       *end = *start + PMD_SIZE;
-                       mmu_notifier_invalidate_range_start(mm, *start, *end);
+               if (range) {
+                       mmu_notifier_range_init(range, mm, address & PMD_MASK,
+                                            (address & PMD_MASK) + PMD_SIZE);
+                       mmu_notifier_invalidate_range_start(range);

... so it's fine to call range_init() *here*.

@@ -4069,17 +4070,17 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsign
ed long address,
[...]
        if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
                goto out;
 
-       if (start && end) {
-               *start = address & PAGE_MASK;
-               *end = *start + PAGE_SIZE;
-               mmu_notifier_invalidate_range_start(mm, *start, *end);
+       if (range) {
+               range->start = address & PAGE_MASK;
+               range->end = range->start + PAGE_SIZE;
+               mmu_notifier_invalidate_range_start(range);

... but then *not* here later in the same function?  You're not making
any sense.
