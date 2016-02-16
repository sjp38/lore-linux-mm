Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 18C476B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 09:27:02 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id a4so102669256wme.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 06:27:02 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id v124si33826821wmg.0.2016.02.16.06.27.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 06:27:00 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id g62so194063767wme.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 06:27:00 -0800 (PST)
Date: Tue, 16 Feb 2016 16:26:57 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 08/28] mm: postpone page table allocation until
 do_set_pte()
Message-ID: <20160216142657.GA16364@node.shutemov.name>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-9-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE1A09.6000007@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56BE1A09.6000007@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 12, 2016 at 09:44:41AM -0800, Dave Hansen wrote:
> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index ca99c0ecf52e..172f4d8e798d 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -265,6 +265,7 @@ struct fault_env {
> >  	pmd_t *pmd;
> >  	pte_t *pte;
> >  	spinlock_t *ptl;
> > +	pgtable_t prealloc_pte;
> >  };
> 
> If we're going to do this fault_env thing, we need some heavy-duty
> comments on what the different fields do and what they mean.  We don't
> want to get in to a situation where we're doing
> 
> 	void fault_foo(struct fault_env *fe);..
> 
> and then we change the internals of fault_foo() to manipulate a
> different set of fe->* variables, or change assumptions, then have
> callers randomly break.
> 
> One _nice_ part of passing all the arguments explicitly is that it makes
> you go visit all the call sites and think about how the conventions change.
> 
> It just makes me nervous.
> 
> The semantics of having both a ->pte and ->pmd need to be very clearly
> spelled out too, please.

I've updated this to:

/*
 * Page fault context: passes though page fault handler instead of endless list
 * of function arguments.
 */
struct fault_env {
	struct vm_area_struct *vma;	/* Target VMA */
	unsigned long address;		/* Faulting virtual address */
	unsigned int flags;		/* FAULT_FLAG_xxx flags */
	pmd_t *pmd;			/* Pointer to pmd entry matching
					 * the 'address'
					 */
	pte_t *pte;			/* Pointer to pte entry matching
					 * the 'address'. NULL if the page
					 * table hasn't been allocated.
					 */
	spinlock_t *ptl;		/* Page table lock.
					 * Protects pte page table if 'pte'
					 * is not NULL, otherwise pmd.
					 */
	pgtable_t prealloc_pte;		/* Pre-allocated pte page table.
					 * vm_ops->map_pages() calls
					 * do_set_pte() from atomic context.
					 * do_fault_around() pre-allocates
					 * page table to avoid allocation from
					 * atomic context.
					 */
};

> 
> >  /*
> > @@ -559,7 +560,8 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> >  	return pte;
> >  }
> >  
> > -void do_set_pte(struct fault_env *fe, struct page *page);
> > +int do_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
> > +		struct page *page);
> >  #endif
> 
> I think do_set_pte() might be due for a new name if it's going to be
> doing allocations internally.

Any suggestions?

> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 28b3875969a8..ba8150d6dc33 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2146,11 +2146,6 @@ void filemap_map_pages(struct fault_env *fe,
> >  			start_pgoff) {
> >  		if (iter.index > end_pgoff)
> >  			break;
> > -		fe->pte += iter.index - last_pgoff;
> > -		fe->address += (iter.index - last_pgoff) << PAGE_SHIFT;
> > -		last_pgoff = iter.index;
> > -		if (!pte_none(*fe->pte))
> > -			goto next;
> >  repeat:
> >  		page = radix_tree_deref_slot(slot);
> >  		if (unlikely(!page))
> > @@ -2187,7 +2182,17 @@ repeat:
> >  
> >  		if (file->f_ra.mmap_miss > 0)
> >  			file->f_ra.mmap_miss--;
> > -		do_set_pte(fe, page);
> > +
> > +		fe->address += (iter.index - last_pgoff) << PAGE_SHIFT;
> > +		if (fe->pte)
> > +			fe->pte += iter.index - last_pgoff;
> > +		last_pgoff = iter.index;
> > +		if (do_set_pte(fe, NULL, page)) {
> > +			/* failed to setup page table: giving up */
> > +			if (!fe->pte)
> > +				break;
> > +			goto unlock;
> > +		}
> 
> What's the failure here, though?

At this point in patchset it never fails: allocation failure is not
possible as we pre-allocate page table for faularound.

Later after do_set_pmd() is introduced, huge page can be mapped here. By
us or under us.

I'll update comment.

> Failed to set PTE or failed to _allocate_ pte page?  One of them is a
> harmless race setting the pte and the other is a pretty crummy
> allocation failure.  Do we really not want to differentiate these?

Not really. That's speculative codepath: do_read_fault() will check if
faultaround solved the fault or not.

> This also throws away the spiffy new error code that comes baqck from
> do_set_pte().  Is that OK?

Yes. We will try harder in do_read_fault() once faultaround code failed to
solve the page fault with all proper locks and error handling.

> >  		unlock_page(page);
> >  		goto next;
> >  unlock:
> > diff --git a/mm/memory.c b/mm/memory.c
> > index f8f9549fac86..0de6f176674d 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2661,8 +2661,6 @@ static int do_anonymous_page(struct fault_env *fe)
> >  	struct page *page;
> >  	pte_t entry;
> >  
> > -	pte_unmap(fe->pte);
> > -
> >  	/* File mapping without ->vm_ops ? */
> >  	if (vma->vm_flags & VM_SHARED)
> >  		return VM_FAULT_SIGBUS;
> > @@ -2671,6 +2669,18 @@ static int do_anonymous_page(struct fault_env *fe)
> >  	if (check_stack_guard_page(vma, fe->address) < 0)
> >  		return VM_FAULT_SIGSEGV;
> >  
> > +	/*
> > +	 * Use __pte_alloc instead of pte_alloc_map, because we can't
> > +	 * run pte_offset_map on the pmd, if an huge pmd could
> > +	 * materialize from under us from a different thread.
> > +	 */
> 
> This comment is a little bit funky.  Maybe:
> 
> "Use __pte_alloc() instead of pte_alloc_map().  We can't run
> pte_offset_map() on pmds where a huge pmd might be created (from a
> different thread)."
> 
> Could you also talk a bit about where it _is_ safe to call pte_alloc_map()?

That comment was just moved from __handle_mm_fault().

Would this be okay:

        /*
         * Use __pte_alloc() instead of pte_alloc_map().  We can't run
         * pte_offset_map() on pmds where a huge pmd might be created (from
         * a different thread).
         *
         * pte_alloc_map() is safe to use under down_write(mmap_sem) or when
         * parallel threads are excluded by other means.
         */

> > +	if (unlikely(pmd_none(*fe->pmd) &&
> > +			__pte_alloc(vma->vm_mm, vma, fe->pmd, fe->address)))
> > +		return VM_FAULT_OOM;
> 
> Should we just move this pmd_none() check in to __pte_alloc()?  You do
> this same-style check at least twice.

We have it there. The check here is speculative to avoid taking ptl.

> > +	/* If an huge pmd materialized from under us just retry later */
> > +	if (unlikely(pmd_trans_huge(*fe->pmd)))
> > +		return 0;
> 
> Nit: please stop sprinkling unlikely() everywhere.  Is there some
> concrete benefit to doing it here?  I really doubt the compiler needs
> help putting the code for "return 0" out-of-line.
> 
> Why is it important to abort here?  Is this a small-page-only path?

This unlikely() was moved from __handle_mm_fault(). I didn't put much
consideration in it.
 
> > +static int pte_alloc_one_map(struct fault_env *fe)
> > +{
> > +	struct vm_area_struct *vma = fe->vma;
> > +
> > +	if (!pmd_none(*fe->pmd))
> > +		goto map_pte;
> 
> So the calling convention here is...?  It looks like this has to be
> called with fe->pmd == pmd_none().  If not, we assume it's pointing to a
> pte page.  This can never be called on a huge pmd.  Right?

It's not under ptl, so pmd can be filled under us. There's huge pmd check in
'map_pte' goto path.
 
> > +	if (fe->prealloc_pte) {
> > +		smp_wmb(); /* See comment in __pte_alloc() */
> 
> Are we trying to make *this* cpu's write visible, or to see the write
> from __pte_alloc()?  It seems like we're trying to see the write.  Isn't
> smp_rmb() what we want for that?

See 362a61ad6119.

I think more logical way would be to put it into do_fault_around(), just after
pte_alloc_one().
 
> > +		fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
> > +		if (unlikely(!pmd_none(*fe->pmd))) {
> > +			spin_unlock(fe->ptl);
> > +			goto map_pte;
> > +		}
> 
> Should we just make pmd_none() likely()?  That seems like it would save
> about 20MB of unlikely()'s in the source.

Heh.

> > +		atomic_long_inc(&vma->vm_mm->nr_ptes);
> > +		pmd_populate(vma->vm_mm, fe->pmd, fe->prealloc_pte);
> > +		spin_unlock(fe->ptl);
> > +		fe->prealloc_pte = 0;
> > +	} else if (unlikely(__pte_alloc(vma->vm_mm, vma, fe->pmd,
> > +					fe->address))) {
> > +		return VM_FAULT_OOM;
> > +	}
> > +map_pte:
> > +	if (unlikely(pmd_trans_huge(*fe->pmd)))
> > +		return VM_FAULT_NOPAGE;
> 
> I think I need a refresher on the locking rules.  pte_offset_map*() is
> unsafe to call on a huge pmd.  What in this context makes it impossible
> for the pmd to get promoted after the check?

Do you mean what stops pte page table to collapsed into huge pmd?
The answer is mmap_sem. Collapse code takes the lock on write to be able to
retract page table.
 
> > +	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
> > +			&fe->ptl);
> > +	return 0;
> > +}
> > +
> >  /**
> >   * do_set_pte - setup new PTE entry for given page and add reverse page mapping.
> >   *
> >   * @fe: fault environment
> > + * @memcg: memcg to charge page (only for private mappings)
> >   * @page: page to map
> >   *
> > - * Caller must hold page table lock relevant for @fe->pte.
> 
> That's a bit screwy now because fe->pte might not exist.  Right?  I

[ you're commenting deleted line ]

Right.

> thought the ptl was derived from the physical address of the pte page.
> How can we have a lock for a physical address that doesn't exist yet?

If fe->pte is NULL, pte_alloc_one_map() would take care about allocation, map
and lock the page table.
 
> > + * Caller must take care of unlocking fe->ptl, if fe->pte is non-NULL on return.
> >   *
> >   * Target users are page handler itself and implementations of
> >   * vm_ops->map_pages.
> >   */
> > -void do_set_pte(struct fault_env *fe, struct page *page)
> > +int do_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
> > +		struct page *page)
> >  {
> >  	struct vm_area_struct *vma = fe->vma;
> >  	bool write = fe->flags & FAULT_FLAG_WRITE;
> >  	pte_t entry;
> >  
> > +	if (!fe->pte) {
> > +		int ret = pte_alloc_one_map(fe);
> > +		if (ret)
> > +			return ret;
> > +	}
> > +
> > +	if (!pte_none(*fe->pte))
> > +		return VM_FAULT_NOPAGE;
> 
> Oh, you've got to add another pte_none() check because you're deferring
> the acquisition of the ptl lock?

Yes, we need to re-check once ptl is taken.

> >  	flush_icache_page(vma, page);
> >  	entry = mk_pte(page, vma->vm_page_prot);
> >  	if (write)
> > @@ -2811,6 +2864,8 @@ void do_set_pte(struct fault_env *fe, struct page *page)
> >  	if (write && !(vma->vm_flags & VM_SHARED)) {
> >  		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
> >  		page_add_new_anon_rmap(page, vma, fe->address, false);
> > +		mem_cgroup_commit_charge(page, memcg, false, false);
> > +		lru_cache_add_active_or_unevictable(page, vma);
> >  	} else {
> >  		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
> >  		page_add_file_rmap(page);
> > @@ -2819,6 +2874,8 @@ void do_set_pte(struct fault_env *fe, struct page *page)
> >  
> >  	/* no need to invalidate: a not-present page won't be cached */
> >  	update_mmu_cache(vma, fe->address, fe->pte);
> > +
> > +	return 0;
> >  }
> >  
> >  static unsigned long fault_around_bytes __read_mostly =
> > @@ -2885,19 +2942,17 @@ late_initcall(fault_around_debugfs);
> >   * fault_around_pages() value (and therefore to page order).  This way it's
> >   * easier to guarantee that we don't cross page table boundaries.
> >   */
> > -static void do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
> > +static int do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
> >  {
> > -	unsigned long address = fe->address, start_addr, nr_pages, mask;
> > -	pte_t *pte = fe->pte;
> > +	unsigned long address = fe->address, nr_pages, mask;
> >  	pgoff_t end_pgoff;
> > -	int off;
> > +	int off, ret = 0;
> >  
> >  	nr_pages = READ_ONCE(fault_around_bytes) >> PAGE_SHIFT;
> >  	mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
> >  
> > -	start_addr = max(fe->address & mask, fe->vma->vm_start);
> > -	off = ((fe->address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
> > -	fe->pte -= off;
> > +	fe->address = max(address & mask, fe->vma->vm_start);
> > +	off = ((address - fe->address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
> >  	start_pgoff -= off;
> 
> Considering what's in this patch already, I think I'd leave the trivial
> local variable replacement for another patch.

fe->address is not a local variable: it get passed into map_pages.

> >  	/*
> > @@ -2905,30 +2960,33 @@ static void do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
> >  	 *  or fault_around_pages() from start_pgoff, depending what is nearest.
> >  	 */
> >  	end_pgoff = start_pgoff -
> > -		((start_addr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
> > +		((fe->address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
> >  		PTRS_PER_PTE - 1;
> >  	end_pgoff = min3(end_pgoff, vma_pages(fe->vma) + fe->vma->vm_pgoff - 1,
> >  			start_pgoff + nr_pages - 1);
> >  
> > -	/* Check if it makes any sense to call ->map_pages */
> > -	fe->address = start_addr;
> > -	while (!pte_none(*fe->pte)) {
> > -		if (++start_pgoff > end_pgoff)
> > -			goto out;
> > -		fe->address += PAGE_SIZE;
> > -		if (fe->address >= fe->vma->vm_end)
> > -			goto out;
> > -		fe->pte++;
> > +	if (pmd_none(*fe->pmd))
> > +		fe->prealloc_pte = pte_alloc_one(fe->vma->vm_mm, fe->address);
> > +	fe->vma->vm_ops->map_pages(fe, start_pgoff, end_pgoff);
> > +	if (fe->prealloc_pte) {
> > +		pte_free(fe->vma->vm_mm, fe->prealloc_pte);
> > +		fe->prealloc_pte = 0;
> >  	}
> > +	if (!fe->pte)
> > +		goto out;
> 
> What does !fe->pte *mean* here?  No pte page?  No pte present?  Huge pte
> present?

Huge pmd is mapped.

Comment added.

> > -	fe->vma->vm_ops->map_pages(fe, start_pgoff, end_pgoff);
> > +	/* check if the page fault is solved */
> > +	fe->pte -= (fe->address >> PAGE_SHIFT) - (address >> PAGE_SHIFT);
> > +	if (!pte_none(*fe->pte))
> > +		ret = VM_FAULT_NOPAGE;
> > +	pte_unmap_unlock(fe->pte, fe->ptl);
> >  out:
> > -	/* restore fault_env */
> > -	fe->pte = pte;
> >  	fe->address = address;
> > +	fe->pte = NULL;
> > +	return ret;
> >  }
> >  
> > -static int do_read_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
> > +static int do_read_fault(struct fault_env *fe, pgoff_t pgoff)
> >  {
> >  	struct vm_area_struct *vma = fe->vma;
> >  	struct page *fault_page;
> > @@ -2940,33 +2998,25 @@ static int do_read_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
> >  	 * something).
> >  	 */
> >  	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
> > -		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
> > -				&fe->ptl);
> > -		do_fault_around(fe, pgoff);
> > -		if (!pte_same(*fe->pte, orig_pte))
> > -			goto unlock_out;
> > -		pte_unmap_unlock(fe->pte, fe->ptl);
> > +		ret = do_fault_around(fe, pgoff);
> > +		if (ret)
> > +			return ret;
> >  	}
> >  
> >  	ret = __do_fault(fe, pgoff, NULL, &fault_page);
> >  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
> >  		return ret;
> >  
> > -	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address, &fe->ptl);
> > -	if (unlikely(!pte_same(*fe->pte, orig_pte))) {
> > +	ret |= do_set_pte(fe, NULL, fault_page);
> > +	if (fe->pte)
> >  		pte_unmap_unlock(fe->pte, fe->ptl);
> > -		unlock_page(fault_page);
> > -		page_cache_release(fault_page);
> > -		return ret;
> > -	}
> > -	do_set_pte(fe, fault_page);
> >  	unlock_page(fault_page);
> > -unlock_out:
> > -	pte_unmap_unlock(fe->pte, fe->ptl);
> > +	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
> > +		page_cache_release(fault_page);
> >  	return ret;
> >  }
> >  
> > -static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
> > +static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff)
> >  {
> >  	struct vm_area_struct *vma = fe->vma;
> >  	struct page *fault_page, *new_page;
> > @@ -2994,26 +3044,9 @@ static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
> >  		copy_user_highpage(new_page, fault_page, fe->address, vma);
> >  	__SetPageUptodate(new_page);
> >  
> > -	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
> > -			&fe->ptl);
> > -	if (unlikely(!pte_same(*fe->pte, orig_pte))) {
> > +	ret |= do_set_pte(fe, memcg, new_page);
> > +	if (fe->pte)
> >  		pte_unmap_unlock(fe->pte, fe->ptl);
> > -		if (fault_page) {
> > -			unlock_page(fault_page);
> > -			page_cache_release(fault_page);
> > -		} else {
> > -			/*
> > -			 * The fault handler has no page to lock, so it holds
> > -			 * i_mmap_lock for read to protect against truncate.
> > -			 */
> > -			i_mmap_unlock_read(vma->vm_file->f_mapping);
> > -		}
> > -		goto uncharge_out;
> > -	}
> > -	do_set_pte(fe, new_page);
> > -	mem_cgroup_commit_charge(new_page, memcg, false, false);
> > -	lru_cache_add_active_or_unevictable(new_page, vma);
> > -	pte_unmap_unlock(fe->pte, fe->ptl);
> >  	if (fault_page) {
> >  		unlock_page(fault_page);
> >  		page_cache_release(fault_page);
> > @@ -3024,6 +3057,8 @@ static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
> >  		 */
> >  		i_mmap_unlock_read(vma->vm_file->f_mapping);
> >  	}
> > +	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
> > +		goto uncharge_out;
> >  	return ret;
> >  uncharge_out:
> >  	mem_cgroup_cancel_charge(new_page, memcg, false);
> > @@ -3031,7 +3066,7 @@ uncharge_out:
> >  	return ret;
> >  }
> >  
> > -static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
> > +static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff)
> >  {
> >  	struct vm_area_struct *vma = fe->vma;
> >  	struct page *fault_page;
> > @@ -3057,16 +3092,15 @@ static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
> >  		}
> >  	}
> >  
> > -	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
> > -			&fe->ptl);
> > -	if (unlikely(!pte_same(*fe->pte, orig_pte))) {
> > +	ret |= do_set_pte(fe, NULL, fault_page);
> > +	if (fe->pte)
> >  		pte_unmap_unlock(fe->pte, fe->ptl);
> > +	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
> > +					VM_FAULT_RETRY))) {
> >  		unlock_page(fault_page);
> >  		page_cache_release(fault_page);
> >  		return ret;
> >  	}
> > -	do_set_pte(fe, fault_page);
> > -	pte_unmap_unlock(fe->pte, fe->ptl);
> >  
> >  	if (set_page_dirty(fault_page))
> >  		dirtied = 1;
> > @@ -3098,21 +3132,19 @@ static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
> >   * The mmap_sem may have been released depending on flags and our
> >   * return value.  See filemap_fault() and __lock_page_or_retry().
> >   */
> > -static int do_fault(struct fault_env *fe, pte_t orig_pte)
> > +static int do_fault(struct fault_env *fe)
> >  {
> >  	struct vm_area_struct *vma = fe->vma;
> > -	pgoff_t pgoff = (((fe->address & PAGE_MASK)
> > -			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> > +	pgoff_t pgoff = linear_page_index(vma, fe->address);
> 
> Looks like another trivial cleanup.

Okay, I'll move it into separate patch.

> > -	pte_unmap(fe->pte);
> >  	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
> >  	if (!vma->vm_ops->fault)
> >  		return VM_FAULT_SIGBUS;
> >  	if (!(fe->flags & FAULT_FLAG_WRITE))
> > -		return do_read_fault(fe, pgoff,	orig_pte);
> > +		return do_read_fault(fe, pgoff);
> >  	if (!(vma->vm_flags & VM_SHARED))
> > -		return do_cow_fault(fe, pgoff, orig_pte);
> > -	return do_shared_fault(fe, pgoff, orig_pte);
> > +		return do_cow_fault(fe, pgoff);
> > +	return do_shared_fault(fe, pgoff);
> >  }
> >  
> >  static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
> > @@ -3252,37 +3284,62 @@ static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
> >   * with external mmu caches can use to update those (ie the Sparc or
> >   * PowerPC hashed page tables that act as extended TLBs).
> >   *
> > - * We enter with non-exclusive mmap_sem (to exclude vma changes,
> > - * but allow concurrent faults), and pte mapped but not yet locked.
> > - * We return with pte unmapped and unlocked.
> > + * We enter with non-exclusive mmap_sem (to exclude vma changes, but allow
> > + * concurrent faults).
> >   *
> > - * The mmap_sem may have been released depending on flags and our
> > - * return value.  See filemap_fault() and __lock_page_or_retry().
> > + * The mmap_sem may have been released depending on flags and our return value.
> > + * See filemap_fault() and __lock_page_or_retry().
> >   */
> >  static int handle_pte_fault(struct fault_env *fe)
> >  {
> >  	pte_t entry;
> >  
> > +	/* If an huge pmd materialized from under us just retry later */
> > +	if (unlikely(pmd_trans_huge(*fe->pmd)))
> > +		return 0;
> > +
> > +	if (unlikely(pmd_none(*fe->pmd))) {
> > +		/*
> > +		 * Leave __pte_alloc() until later: because vm_ops->fault may
> > +		 * want to allocate huge page, and if we expose page table
> > +		 * for an instant, it will be difficult to retract from
> > +		 * concurrent faults and from rmap lookups.
> > +		 */
> > +	} else {
> > +		/*
> > +		 * A regular pmd is established and it can't morph into a huge
> > +		 * pmd from under us anymore at this point because we hold the
> > +		 * mmap_sem read mode and khugepaged takes it in write mode.
> > +		 * So now it's safe to run pte_offset_map().
> > +		 */
> > +		fe->pte = pte_offset_map(fe->pmd, fe->address);
> > +
> > +		entry = *fe->pte;
> > +		barrier();
> 
> Barrier because....?
> 
> > +		if (pte_none(entry)) {
> > +			pte_unmap(fe->pte);
> > +			fe->pte = NULL;
> > +		}
> > +	}
> > +
> >  	/*
> >  	 * some architectures can have larger ptes than wordsize,
> >  	 * e.g.ppc44x-defconfig has CONFIG_PTE_64BIT=y and CONFIG_32BIT=y,
> >  	 * so READ_ONCE or ACCESS_ONCE cannot guarantee atomic accesses.
> > -	 * The code below just needs a consistent view for the ifs and
> > +	 * The code above just needs a consistent view for the ifs and
> >  	 * we later double check anyway with the ptl lock held. So here
> >  	 * a barrier will do.
> >  	 */
> 
> Looks like the barrier got moved, but not the comment.

Moved.

> Man, that's a lot of code.

Yeah. I don't see a sensible way to split it. :-/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
