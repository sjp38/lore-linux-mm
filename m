Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 967366B0069
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 07:04:24 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y7so5186643wrc.7
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 04:04:24 -0800 (PST)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id g29si8890838wra.149.2017.02.08.04.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 04:04:23 -0800 (PST)
Received: by mail-wr0-x242.google.com with SMTP id o16so8555875wra.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 04:04:23 -0800 (PST)
Date: Wed, 8 Feb 2017 15:04:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mprotect: drop overprotective lock_pte_protection()
Message-ID: <20170208120421.GE5578@node.shutemov.name>
References: <20170207143347.123871-1-kirill.shutemov@linux.intel.com>
 <20170207134454.7af755ae379ca9d016b5c15a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207134454.7af755ae379ca9d016b5c15a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 07, 2017 at 01:44:54PM -0800, Andrew Morton wrote:
> On Tue,  7 Feb 2017 17:33:47 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > lock_pte_protection() uses pmd_lock() to make sure that we have stable
> > PTE page table before walking pte range.
> > 
> > That's not necessary. We only need to make sure that PTE page table is
> > established. It cannot vanish under us as long as we hold mmap_sem at
> > least for read.
> > 
> > And we already have helper for that -- pmd_trans_unstable().
> 
> http://ozlabs.org/~akpm/mmots/broken-out/mm-mprotect-use-pmd_trans_unstable-instead-of-taking-the-pmd_lock.patch
> already did this?

Right. Except, it doesn't drop unneeded pmd_trans_unstable(pmd) check after
__split_huge_pmd().

Could you fold this part of my patch into Andrea's?

diff --git a/mm/mprotect.c b/mm/mprotect.c
index f9c07f54dd62..e919e4613eab 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -177,8 +149,6 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
 				__split_huge_pmd(vma, pmd, addr, false, NULL);
-				if (pmd_trans_unstable(pmd))
-					continue;
 			} else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
 						newprot, prot_numa);
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
