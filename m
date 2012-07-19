Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id BE98A6B00BA
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:49:13 -0400 (EDT)
Date: Thu, 19 Jul 2012 15:49:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm: hugetlbfs: Close race during teardown of
 hugetlbfs shared page tables
Message-ID: <20120719144908.GX9222@suse.de>
References: <20120718104220.GR9222@suse.de>
 <20120719144213.GJ2864@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120719144213.GJ2864@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Kenneth W Chen <kenneth.w.chen@intel.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 19, 2012 at 04:42:13PM +0200, Michal Hocko wrote:
> [/me puts the patch destroyer glasses on]
> 

It's a super power now.

> On Wed 18-07-12 11:43:09, Mel Gorman wrote:
> [...]
> > diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> > index f6679a7..0524556 100644
> > --- a/arch/x86/mm/hugetlbpage.c
> > +++ b/arch/x86/mm/hugetlbpage.c
> > @@ -68,14 +68,37 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> >  	struct vm_area_struct *svma;
> >  	unsigned long saddr;
> >  	pte_t *spte = NULL;
> > +	spinlock_t *spage_table_lock = NULL;
> > +	struct rw_semaphore *smmap_sem = NULL;
> >  
> >  	if (!vma_shareable(vma, addr))
> >  		return;
> >  
> > +retry:
> >  	mutex_lock(&mapping->i_mmap_mutex);
> >  	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
> >  		if (svma == vma)
> >  			continue;
> > +		if (svma->vm_mm == vma->vm_mm)
> > +			continue;
> > +
> > +		/*
> > +		 * The target mm could be in the process of tearing down
> > +		 * its page tables and the i_mmap_mutex on its own is
> > +		 * not sufficient. To prevent races against teardown and
> > +		 * pagetable updates, we acquire the mmap_sem and pagetable
> > +		 * lock of the remote address space. down_read_trylock()
> > +		 * is necessary as the other process could also be trying
> > +		 * to share pagetables with the current mm.
> > +		 */
> > +		if (!down_read_trylock(&svma->vm_mm->mmap_sem)) {
> > +			mutex_unlock(&mapping->i_mmap_mutex);
> > +			goto retry;
> > +		}
> > +
> 
> I am afraid this can easily cause a dead lock. Consider
> fork
>   dup_mmap
>     down_write(&oldmm->mmap_sem)
>     copy_page_range
>       copy_hugetlb_page_range
>         huge_pte_alloc
> 
> svma could belong to oldmm and then we would loop for ever. 
> svma->vm_mm == vma->vm_mm doesn't help because vma is child's one and mm
> differ in that case. I am wondering you didn't hit this while testing.
> It would suggest that the ptes are not populated yet because we didn't
> let parent play and then other children could place its vma in the list
> before parent?
> 

Yes, I think you're right - both about the race and why I didn't hit it.
The libhugetlbfs tests probably avoided the bug for the same reason.
Thanks for pointing this out.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
