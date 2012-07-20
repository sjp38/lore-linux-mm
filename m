Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 714EB6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:37:58 -0400 (EDT)
Date: Fri, 20 Jul 2012 15:37:53 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: hugetlbfs: Close race during teardown of hugetlbfs
 shared page tables V2 (resend)
Message-ID: <20120720143753.GI9222@suse.de>
References: <20120720134937.GG9222@suse.de>
 <20120720141108.GH9222@suse.de>
 <20120720142920.GD12434@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120720142920.GD12434@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 20, 2012 at 04:29:20PM +0200, Michal Hocko wrote:
> > <SNIP>
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Yes this looks correct. mmap_sem will make sure that unmap_vmas and
> free_pgtables are executed atomicaly wrt. huge_pmd_share so it doesn't
> see non-NULL spte on the way out.

Yes.

> I am just wondering whether we need
> the page_table_lock as well. It is not harmful but I guess we can drop
> it because both exit_mmap and shmdt are not taking it and mmap_sem is
> sufficient for them.

While it is true that we don't *really* need page_table_lock here, we are
still updating page tables and it's in line with the the ordinary locking
rules.  There are other cases in hugetlb.c where we do pte_same() checks even
though we are protected from the related races by the instantiation_mutex.

page_table_lock is actually a bit useless for shared page tables. If shared
page tables were every to be a general thing then I think we'd have to
revisit how PTE update locking is done but I doubt anyone wants to dive
down that rat-hole.

For now, I'm going to keep taking it even if strictly speaking it's not
necessary.

> One more nit bellow.
> 
> I will send my version of the fix which took another path as a reply to
> this email to have something to compare with.
> 

Thanks.

> [...]
> > diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> > index f6679a7..944b2df 100644
> > --- a/arch/x86/mm/hugetlbpage.c
> > +++ b/arch/x86/mm/hugetlbpage.c
> > @@ -58,7 +58,8 @@ static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
> >  /*
> >   * search for a shareable pmd page for hugetlb.
> >   */
> > -static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> > +static void huge_pmd_share(struct mm_struct *mm, struct mm_struct *locked_mm,
> > +			   unsigned long addr, pud_t *pud)
> >  {
> >  	struct vm_area_struct *vma = find_vma(mm, addr);
> >  	struct address_space *mapping = vma->vm_file->f_mapping;
> > @@ -68,14 +69,40 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
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
> > +		 * to share pagetables with the current mm. In the fork
> > +		 * case, we are already both mm's so check for that
> > +		 */
> > +		if (locked_mm != svma->vm_mm) {
> > +			if (!down_read_trylock(&svma->vm_mm->mmap_sem)) {
> > +				mutex_unlock(&mapping->i_mmap_mutex);
> > +				goto retry;
> > +			}
> > +			smmap_sem = &svma->vm_mm->mmap_sem;
> > +		}
> > +
> > +		spage_table_lock = &svma->vm_mm->page_table_lock;
> > +		spin_lock_nested(spage_table_lock, SINGLE_DEPTH_NESTING);
> >  
> >  		saddr = page_table_shareable(svma, vma, addr, idx);
> >  		if (saddr) {
> [...]
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index ae8f708..4832277 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -2244,7 +2244,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
> >  		src_pte = huge_pte_offset(src, addr);
> >  		if (!src_pte)
> >  			continue;
> > -		dst_pte = huge_pte_alloc(dst, addr, sz);
> > +		dst_pte = huge_pte_alloc(dst, src, addr, sz);
> >  		if (!dst_pte)
> >  			goto nomem;
> >  
> > @@ -2745,7 +2745,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  			       VM_FAULT_SET_HINDEX(h - hstates);
> >  	}
> >  
> > -	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
> > +	ptep = huge_pte_alloc(mm, NULL, address, huge_page_size(h));
> 
> strictly speaking we should provide current->mm here because we are in
> the page fault path and mmap_sem is held for reading. This doesn't
> matter here though because huge_pmd_share will take it for reading so
> nesting wouldn't hurt. Maybe a small comment that this is intentional
> and correct would be nice.
> 

Fair point. If we go with this version of the fix, I'll improve the
documentation a bit.

Thanks!

> >  	if (!ptep)
> >  		return VM_FAULT_OOM;
> >  
> > 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
