Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 938DB6B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 12:52:54 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p12so20553957qkl.0
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:52:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 32si5613552qtz.524.2017.08.30.09.52.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 09:52:53 -0700 (PDT)
Date: Wed, 30 Aug 2017 18:52:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Message-ID: <20170830165250.GD13559@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170829235447.10050-3-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

Hello Jerome,

On Tue, Aug 29, 2017 at 07:54:36PM -0400, Jerome Glisse wrote:
> Replacing all mmu_notifier_invalidate_page() by mmu_notifier_invalidat_range()
> and making sure it is bracketed by call to mmu_notifier_invalidate_range_start/
> end.
> 
> Note that because we can not presume the pmd value or pte value we have to
> assume the worse and unconditionaly report an invalidation as happening.

I pointed out in earlier email ->invalidate_range can only be
implemented (as mutually exclusive alternative to
->invalidate_range_start/end) by secondary MMUs that shares the very
same pagetables with the core linux VM of the primary MMU, and those
invalidate_range are already called by
__mmu_notifier_invalidate_range_end. The other bit is done by the MMU
gather (because mmu_notifier_invalidate_range_start is a noop for
drivers that implement s->invalidate_range).

The difference between sharing the same pagetables or not allows for
->invalidate_range to work because when the Linux MM changes the
primary MMU pagetables it also automatically invalidated updates
secondary MMU at the same time (because of the pagetable sharing
between primary and secondary MMUs). So then all that is left to do is
an invalidate_range to flush the secondary MMU TLBs.

There's no need of action in mmu_notifier_invalidate_range_start for
those pagetable sharing drivers because there's no risk of a secondary
MMU shadow pagetable layer to be re-created in between
mmu_notifier_invalidate_range_start and the actual pagetable
invalidate because again the pagetables are shared.

void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
				  unsigned long start, unsigned long end)
{
	struct mmu_notifier *mn;
	int id;

	id = srcu_read_lock(&srcu);
	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
		/*
		 * Call invalidate_range here too to avoid the need for the
		 * subsystem of having to register an invalidate_range_end
		 * call-back when there is invalidate_range already. Usually a
		 * subsystem registers either invalidate_range_start()/end() or
		 * invalidate_range(), so this will be no additional overhead
		 * (besides the pointer check).
		 */
		if (mn->ops->invalidate_range)
			mn->ops->invalidate_range(mn, mm, start, end);
			^^^^^^^^^^^^^^^^^^^^^^^^^
		if (mn->ops->invalidate_range_end)
			mn->ops->invalidate_range_end(mn, mm, start, end);
	}
	srcu_read_unlock(&srcu, id);
}

So this conversion from invalidate_page to invalidate_range looks
superflous and the final mmu_notifier_invalidate_range_end should be
enough.

AFIK only amd_iommu_v2 and intel-svm (svm as in shared virtual memory)
uses it.

My suggestion is to remove from below all
mmu_notifier_invalidate_range calls and keep only the
mmu_notifier_invalidate_range_end and test both amd_iommu_v2 and
intel-svm with it under heavy swapping.

The only critical constraint to keep for invalidate_range to stay safe
with a single call of mmu_notifier_invalidate_range_end after put_page
is that the put_page cannot be the last put_page. That only applies to
the case where the page isn't freed through MMU gather (MMU gather
calls mmu_notifier_invalidate_range of its own before freeing the
page, as opposed mmu gather does nothing for drivers using
invalidate_range_start/end because invalidate_range_start acted as
barrier to avoid establishing mappings on the secondary MMUs for
those).

Not strictly required but I think it would be safer and more efficient
to replace the put_page with something like:

static inline void put_page_not_freeing(struct page *page)
{
	page = compound_head(page);

	if (put_page_testzero(page))
		VM_WARN_ON_PAGE(1, page);
}

Thanks!
Andrea

> @@ -926,11 +939,13 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  		}
>  
>  		if (ret) {
> -			mmu_notifier_invalidate_page(vma->vm_mm, address);
> +			mmu_notifier_invalidate_range(vma->vm_mm, cstart, cend);
>  			(*cleaned)++;
>  		}
>  	}
>  
> +	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
> +
>  	return true;
>  }
>  
> @@ -1324,6 +1339,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	pte_t pteval;
>  	struct page *subpage;
>  	bool ret = true;
> +	unsigned long start = address, end;
>  	enum ttu_flags flags = (enum ttu_flags)arg;
>  
>  	/* munlock has nothing to gain from examining un-locked vmas */
> @@ -1335,6 +1351,14 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  				flags & TTU_MIGRATION, page);
>  	}
>  
> +	/*
> +	 * We have to assume the worse case ie pmd for invalidation. Note that
> +	 * the page can not be free in this function as call of try_to_unmap()
> +	 * must hold a reference on the page.
> +	 */
> +	end = min(vma->vm_end, (start & PMD_MASK) + PMD_SIZE);
> +	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
> +
>  	while (page_vma_mapped_walk(&pvmw)) {
>  		/*
>  		 * If the page is mlock()d, we cannot swap it out.
> @@ -1408,6 +1432,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  				set_huge_swap_pte_at(mm, address,
>  						     pvmw.pte, pteval,
>  						     vma_mmu_pagesize(vma));
> +				mmu_notifier_invalidate_range(mm, address,
> +					address + vma_mmu_pagesize(vma));
>  			} else {
>  				dec_mm_counter(mm, mm_counter(page));
>  				set_pte_at(mm, address, pvmw.pte, pteval);
> @@ -1435,6 +1461,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			if (pte_soft_dirty(pteval))
>  				swp_pte = pte_swp_mksoft_dirty(swp_pte);
>  			set_pte_at(mm, address, pvmw.pte, swp_pte);
> +			mmu_notifier_invalidate_range(mm, address,
> +						      address + PAGE_SIZE);
>  		} else if (PageAnon(page)) {
>  			swp_entry_t entry = { .val = page_private(subpage) };
>  			pte_t swp_pte;
> @@ -1445,6 +1473,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
>  				WARN_ON_ONCE(1);
>  				ret = false;
> +				/* We have to invalidate as we cleared the pte */
> +				mmu_notifier_invalidate_range(mm, address,
> +							address + PAGE_SIZE);
>  				page_vma_mapped_walk_done(&pvmw);
>  				break;
>  			}
> @@ -1453,6 +1484,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			if (!PageSwapBacked(page)) {
>  				if (!PageDirty(page)) {
>  					dec_mm_counter(mm, MM_ANONPAGES);
> +					/* Invalidate as we cleared the pte */
> +					mmu_notifier_invalidate_range(mm,
> +						address, address + PAGE_SIZE);
>  					goto discard;
>  				}
>  
> @@ -1485,13 +1519,17 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			if (pte_soft_dirty(pteval))
>  				swp_pte = pte_swp_mksoft_dirty(swp_pte);
>  			set_pte_at(mm, address, pvmw.pte, swp_pte);
> +			mmu_notifier_invalidate_range(mm, address,
> +						      address + PAGE_SIZE);
>  		} else
>  			dec_mm_counter(mm, mm_counter_file(page));
>  discard:
>  		page_remove_rmap(subpage, PageHuge(page));
>  		put_page(page);
> -		mmu_notifier_invalidate_page(mm, address);
>  	}
> +
> +	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
> +
>  	return ret;
>  }
>  
> -- 
> 2.13.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
