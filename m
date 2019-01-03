Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9CC98E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 10:05:26 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w1so41584049qta.12
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 07:05:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x1si3466347qkc.167.2019.01.03.07.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 07:05:25 -0800 (PST)
Date: Thu, 3 Jan 2019 10:05:21 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
Message-ID: <20190103150521.GF3395@redhat.com>
References: <20190103002126.GM6310@bombadil.infradead.org>
 <20190103143116.GB3395@redhat.com>
 <20190103144313.GR6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103144313.GR6310@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>

On Thu, Jan 03, 2019 at 06:43:13AM -0800, Matthew Wilcox wrote:
> On Thu, Jan 03, 2019 at 09:31:16AM -0500, Jerome Glisse wrote:
> > On Wed, Jan 02, 2019 at 04:21:26PM -0800, Matthew Wilcox wrote:
> > > 
> > > One of the paths in follow_pte_pmd() initialised the mmu_notifier_range
> > > incorrectly.
> > > 
> > > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > > Fixes: ac46d4f3c432 ("mm/mmu_notifier: use structure for invalidate_range_start/end calls v2")
> > > Tested-by: Dave Chinner <dchinner@redhat.com>
> > 
> > Actually now that i have read the code again this is not ok to
> > do so. The caller of follow_pte_pmd() will call range_init and
> > follow pmd will only update the range address. So existing code
> > is ok.
> 
> I think you need to re-read your own patch.
> 
> `git show ac46d4f3c43241ffa23d5bf36153a0830c0e02cc`
> 
> @@ -4058,10 +4059,10 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
>                 if (!pmdpp)
>                         goto out;
>  
> -               if (start && end) {
> -                       *start = address & PMD_MASK;
> -                       *end = *start + PMD_SIZE;
> -                       mmu_notifier_invalidate_range_start(mm, *start, *end);
> +               if (range) {
> +                       mmu_notifier_range_init(range, mm, address & PMD_MASK,
> +                                            (address & PMD_MASK) + PMD_SIZE);
> +                       mmu_notifier_invalidate_range_start(range);
> 
> ... so it's fine to call range_init() *here*.
> 
> @@ -4069,17 +4070,17 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsign
> ed long address,
> [...]
>         if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
>                 goto out;
>  
> -       if (start && end) {
> -               *start = address & PAGE_MASK;
> -               *end = *start + PAGE_SIZE;
> -               mmu_notifier_invalidate_range_start(mm, *start, *end);
> +       if (range) {
> +               range->start = address & PAGE_MASK;
> +               range->end = range->start + PAGE_SIZE;
> +               mmu_notifier_invalidate_range_start(range);
> 
> ... but then *not* here later in the same function?  You're not making
> any sense.

Ok i see that the patch that add the reason why mmu notifier is
call have been drop. So yes using range_init in follow_pte_pmd
is fine. With that other patch the reasons is set by the caller
of follow_pte_pmd and using range_init would have overwritten
it.

So this patch is fine for current tree. Sorry i was thinking with
the other patch included in mind.

Cheers,
J�r�me
