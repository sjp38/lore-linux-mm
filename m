Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF356B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 19:02:12 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id a88so100122615uaa.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 16:02:12 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t11si4664740vkc.175.2017.01.23.16.02.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 16:02:11 -0800 (PST)
Date: Mon, 23 Jan 2017 16:01:54 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH] mm: write protect MADV_FREE pages
Message-ID: <20170124000153.GA10693@shli-mbp.local>
References: <791151284cd6941296f08488b8cb7f1968175a0a.1485212872.git.shli@fb.com>
 <20170123152814.2a55c4110df3bd0d67de5fc3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170123152814.2a55c4110df3bd0d67de5fc3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Kernel-team@fb.com, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@surriel.com>, stable@kernel.org

On Mon, Jan 23, 2017 at 03:28:14PM -0800, Andrew Morton wrote:
> On Mon, 23 Jan 2017 15:15:52 -0800 Shaohua Li <shli@fb.com> wrote:
> 
> > The page reclaim has an assumption writting to a page with clean pte
> > should trigger a page fault, because there is a window between pte zero
> > and tlb flush where a new write could come. If the new write doesn't
> > trigger page fault, page reclaim will not notice it and think the page
> > is clean and reclaim it. The MADV_FREE pages don't comply with the rule
> > and the pte is just cleaned without writeprotect, so there will be no
> > pagefault for new write. This will cause data corruption.
> 
> I'd like to see here a complete description of the bug's effects: waht
> sort of workload will trigger it, what the end-user visible effects
> are, etc.

I don't have a real workload to trigger this, it's from code study, sorry. I
thought a workload like this triggering the bug:

madvise(MADV_FREE) /* memory range */
write to the memory range
read from the memory range

With memory pressure, the data read by the application could be all 0 instead
of those written
 
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1381,6 +1381,7 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >  			tlb->fullmm);
> >  		orig_pmd = pmd_mkold(orig_pmd);
> >  		orig_pmd = pmd_mkclean(orig_pmd);
> > +		orig_pmd = pmd_wrprotect(orig_pmd);
> 
> Is this the right way round?  There's still a window where we won't get
> that write fault on the cleaned pte.  Should the pmd_wrprotect() happen
> before the pmd_mkclean()?

This doesn't matter. We haven't set the pmd value to page table yet

Thanks,
Shaohua 
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
