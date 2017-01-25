Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD7FC6B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 12:15:29 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e4so150200430pfg.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:15:29 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id v75si19136254pfj.50.2017.01.25.09.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 09:15:28 -0800 (PST)
Date: Wed, 25 Jan 2017 09:15:19 -0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH] mm: write protect MADV_FREE pages
Message-ID: <20170125171429.5vbqizijrhav522d@kernel.org>
References: <791151284cd6941296f08488b8cb7f1968175a0a.1485212872.git.shli@fb.com>
 <20170124023212.GA24523@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170124023212.GA24523@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@surriel.com>

On Tue, Jan 24, 2017 at 11:32:12AM +0900, Minchan Kim wrote:
> Hi Shaohua,
> 
> On Mon, Jan 23, 2017 at 03:15:52PM -0800, Shaohua Li wrote:
> > The page reclaim has an assumption writting to a page with clean pte
> > should trigger a page fault, because there is a window between pte zero
> > and tlb flush where a new write could come. If the new write doesn't
> > trigger page fault, page reclaim will not notice it and think the page
> > is clean and reclaim it. The MADV_FREE pages don't comply with the rule
> > and the pte is just cleaned without writeprotect, so there will be no
> > pagefault for new write. This will cause data corruption.
> 
> It's hard to understand.
> Could you show me exact scenario seqence you have in mind?
Sorry for the delay, for some reason, I didn't receive the mail.
in try_to_unmap_one:
CPU 1:						CPU2:
1. pteval = ptep_get_and_clear(mm, address, pte);
2.						write to the address
3. tlb flush

step 1 will get a clean pteval, step2 dirty it, but the unmap missed the dirty
bit so discard the page without pageout. step2 doesn't trigger a page fault,
because the tlb cache still has the pte entry. The defer flush makes the window
bigger actually. There are comments about this in try_to_unmap_one too.

Thanks,
Shaohua

> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Rik van Riel <riel@surriel.com>
> > Cc: stable@kernel.org
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > ---
> >  mm/huge_memory.c | 1 +
> >  mm/madvise.c     | 1 +
> >  2 files changed, 2 insertions(+)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 9a6bd6c..9cc5de5 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1381,6 +1381,7 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >  			tlb->fullmm);
> >  		orig_pmd = pmd_mkold(orig_pmd);
> >  		orig_pmd = pmd_mkclean(orig_pmd);
> > +		orig_pmd = pmd_wrprotect(orig_pmd);
> >  
> >  		set_pmd_at(mm, addr, pmd, orig_pmd);
> >  		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 0e3828e..bfb6800 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -373,6 +373,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> >  
> >  			ptent = pte_mkold(ptent);
> >  			ptent = pte_mkclean(ptent);
> > +			ptent = pte_wrprotect(ptent);
> >  			set_pte_at(mm, addr, pte, ptent);
> >  			if (PageActive(page))
> >  				deactivate_page(page);
> > -- 
> > 2.9.3
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
