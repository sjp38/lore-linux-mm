Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9DC6B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 17:58:31 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id c200so244076051wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:58:31 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id yn6si93924wjc.37.2016.02.23.14.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 14:58:29 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id g62so221561574wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:58:29 -0800 (PST)
Date: Wed, 24 Feb 2016 01:58:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 08/28] mm: postpone page table allocation until
 do_set_pte()
Message-ID: <20160223225825.GA3651@node.shutemov.name>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-9-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE1A09.6000007@intel.com>
 <20160216142657.GA16364@node.shutemov.name>
 <56C35EA8.2000407@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56C35EA8.2000407@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Feb 16, 2016 at 09:38:48AM -0800, Dave Hansen wrote:
> Sorry, fat-fingered the send on the last one.
> 
> On 02/16/2016 06:26 AM, Kirill A. Shutemov wrote:
> > On Fri, Feb 12, 2016 at 09:44:41AM -0800, Dave Hansen wrote:
> >>> +	if (unlikely(pmd_none(*fe->pmd) &&
> >>> +			__pte_alloc(vma->vm_mm, vma, fe->pmd, fe->address)))
> >>> +		return VM_FAULT_OOM;
> >>
> >> Should we just move this pmd_none() check in to __pte_alloc()?  You do
> >> this same-style check at least twice.
> > 
> > We have it there. The check here is speculative to avoid taking ptl.
> 
> OK, that's a performance optimization.  Why shouldn't all callers of
> __pte_alloc() get the same optimization?

I've sent patch for this.

> >>> +	/* If an huge pmd materialized from under us just retry later */
> >>> +	if (unlikely(pmd_trans_huge(*fe->pmd)))
> >>> +		return 0;
> >>
> >> Nit: please stop sprinkling unlikely() everywhere.  Is there some
> >> concrete benefit to doing it here?  I really doubt the compiler needs
> >> help putting the code for "return 0" out-of-line.
> >>
> >> Why is it important to abort here?  Is this a small-page-only path?
> > 
> > This unlikely() was moved from __handle_mm_fault(). I didn't put much
> > consideration in it.
> 
> OK, but separately from the unlikely()...  Why is it important to jump
> out of this code when we see a pmd_trans_huge() pmd?

The code below work on pte level, so it expect the pmd to point to page
table.

And the page fault most likely was solved anyway.

> >>> +static int pte_alloc_one_map(struct fault_env *fe)
> >>> +{
> >>> +	struct vm_area_struct *vma = fe->vma;
> >>> +
> >>> +	if (!pmd_none(*fe->pmd))
> >>> +		goto map_pte;
> >>
> >> So the calling convention here is...?  It looks like this has to be
> >> called with fe->pmd == pmd_none().  If not, we assume it's pointing to a
> >> pte page.  This can never be called on a huge pmd.  Right?
> > 
> > It's not under ptl, so pmd can be filled under us. There's huge pmd check in
> > 'map_pte' goto path.
> 
> OK, could we add some comments on that?  We expect to be called to
> ______, but if there is a race, we might also have to handle ______, etc...?

Ok.

> >>> +	if (fe->prealloc_pte) {
> >>> +		smp_wmb(); /* See comment in __pte_alloc() */
> >>
> >> Are we trying to make *this* cpu's write visible, or to see the write
> >> from __pte_alloc()?  It seems like we're trying to see the write.  Isn't
> >> smp_rmb() what we want for that?
> > 
> > See 362a61ad6119.
> 
> That patch explains that anyone allocating and initializing a page table
> page must ensure that all CPUs can see the initialization writes
> *before* the page can be linked into the page tables.  __pte_alloc()
> performs a smp_wmb() to ensure that other processors can see its writes.
> 
> That still doesn't answer my question though.  What does this barrier
> do?  What does it make visible to this processor?  __pte_alloc() already
> made its initialization visible, so what's the purpose *here*?

We don't call __pte_alloc() to allocate the page table for ->prealloc_pte,
we call pte_alloc_one(), which doesn't have the barrier.

> >>> +		atomic_long_inc(&vma->vm_mm->nr_ptes);
> >>> +		pmd_populate(vma->vm_mm, fe->pmd, fe->prealloc_pte);
> >>> +		spin_unlock(fe->ptl);
> >>> +		fe->prealloc_pte = 0;
> >>> +	} else if (unlikely(__pte_alloc(vma->vm_mm, vma, fe->pmd,
> >>> +					fe->address))) {
> >>> +		return VM_FAULT_OOM;
> >>> +	}
> >>> +map_pte:
> >>> +	if (unlikely(pmd_trans_huge(*fe->pmd)))
> >>> +		return VM_FAULT_NOPAGE;
> >>
> >> I think I need a refresher on the locking rules.  pte_offset_map*() is
> >> unsafe to call on a huge pmd.  What in this context makes it impossible
> >> for the pmd to get promoted after the check?
> > 
> > Do you mean what stops pte page table to collapsed into huge pmd?
> > The answer is mmap_sem. Collapse code takes the lock on write to be able to
> > retract page table.
> 
> What I learned in this set is that pte_offset_map_lock() is dangerous to
> call unless THPs have been excluded somehow from the PMD it's being
> called on.
> 
> What I'm looking for is something to make sure that the context has been
> thought through and is thoroughly THP-free.
> 
> It sounds like you've thought through all the cases, but your thoughts
> aren't clear from the way the code is laid out currently.

Actually, I've discovered race looking into this code. Andrea has fixed it
in __handle_mm_fault() and I will move the comment here.

> >>> + * Caller must take care of unlocking fe->ptl, if fe->pte is non-NULL on return.
> >>>   *
> >>>   * Target users are page handler itself and implementations of
> >>>   * vm_ops->map_pages.
> >>>   */
> >>> -void do_set_pte(struct fault_env *fe, struct page *page)
> >>> +int do_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
> >>> +		struct page *page)
> >>>  {
> >>>  	struct vm_area_struct *vma = fe->vma;
> >>>  	bool write = fe->flags & FAULT_FLAG_WRITE;
> >>>  	pte_t entry;
> >>>  
> >>> +	if (!fe->pte) {
> >>> +		int ret = pte_alloc_one_map(fe);
> >>> +		if (ret)
> >>> +			return ret;
> >>> +	}
> >>> +
> >>> +	if (!pte_none(*fe->pte))
> >>> +		return VM_FAULT_NOPAGE;
> >>
> >> Oh, you've got to add another pte_none() check because you're deferring
> >> the acquisition of the ptl lock?
> > 
> > Yes, we need to re-check once ptl is taken.
> 
> Another good comment to add, I think. :)

Ok.

> >>> -	/* Check if it makes any sense to call ->map_pages */
> >>> -	fe->address = start_addr;
> >>> -	while (!pte_none(*fe->pte)) {
> >>> -		if (++start_pgoff > end_pgoff)
> >>> -			goto out;
> >>> -		fe->address += PAGE_SIZE;
> >>> -		if (fe->address >= fe->vma->vm_end)
> >>> -			goto out;
> >>> -		fe->pte++;
> >>> +	if (pmd_none(*fe->pmd))
> >>> +		fe->prealloc_pte = pte_alloc_one(fe->vma->vm_mm, fe->address);
> >>> +	fe->vma->vm_ops->map_pages(fe, start_pgoff, end_pgoff);
> >>> +	if (fe->prealloc_pte) {
> >>> +		pte_free(fe->vma->vm_mm, fe->prealloc_pte);
> >>> +		fe->prealloc_pte = 0;
> >>>  	}
> >>> +	if (!fe->pte)
> >>> +		goto out;
> >>
> >> What does !fe->pte *mean* here?  No pte page?  No pte present?  Huge pte
> >> present?
> > 
> > Huge pmd is mapped.
> > 
> > Comment added.
> 
> Huh, so in _some_ contexts, !fe->pte means that we've got a huge pmd.  I
> don't remember seeing that spelled out in the structure comments.

I'll change it to "if (pmd_trans_huge(*fe->pmd))".

> >>> +	if (unlikely(pmd_none(*fe->pmd))) {
> >>> +		/*
> >>> +		 * Leave __pte_alloc() until later: because vm_ops->fault may
> >>> +		 * want to allocate huge page, and if we expose page table
> >>> +		 * for an instant, it will be difficult to retract from
> >>> +		 * concurrent faults and from rmap lookups.
> >>> +		 */
> >>> +	} else {
> >>> +		/*
> >>> +		 * A regular pmd is established and it can't morph into a huge
> >>> +		 * pmd from under us anymore at this point because we hold the
> >>> +		 * mmap_sem read mode and khugepaged takes it in write mode.
> >>> +		 * So now it's safe to run pte_offset_map().
> >>> +		 */
> >>> +		fe->pte = pte_offset_map(fe->pmd, fe->address);
> >>> +
> >>> +		entry = *fe->pte;
> >>> +		barrier();
> >>
> >> Barrier because....?
> 
> Did you miss a response here, Kirill?

The comment below is about this barrier.
Isn't it sufficient?

> >>> +		if (pte_none(entry)) {
> >>> +			pte_unmap(fe->pte);
> >>> +			fe->pte = NULL;
> >>> +		}
> >>> +	}
> >>> +
> >>>  	/*
> >>>  	 * some architectures can have larger ptes than wordsize,
> >>>  	 * e.g.ppc44x-defconfig has CONFIG_PTE_64BIT=y and CONFIG_32BIT=y,
> >>>  	 * so READ_ONCE or ACCESS_ONCE cannot guarantee atomic accesses.
> >>> -	 * The code below just needs a consistent view for the ifs and
> >>> +	 * The code above just needs a consistent view for the ifs and
> >>>  	 * we later double check anyway with the ptl lock held. So here
> >>>  	 * a barrier will do.
> >>>  	 */
> >>
> >> Looks like the barrier got moved, but not the comment.
> > 
> > Moved.
> > 
> >> Man, that's a lot of code.
> > 
> > Yeah. I don't see a sensible way to split it. :-/
> 
> Can you do the "postpone allocation" parts without adding additional THP
> code?  Or does the postponement just add all of the extra THP-handling
> spots?

I'll check. But I wouldn't expect moving THP-handling out of the commit
will make it much smaller.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
