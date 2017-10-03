Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB5D6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 19:42:20 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v132so1428128oie.19
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 16:42:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r34si12218943qtd.515.2017.10.03.16.42.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 16:42:19 -0700 (PDT)
Date: Wed, 4 Oct 2017 01:42:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/mmu_notifier: avoid double notification when it is
 useless
Message-ID: <20171003234215.GA5231@redhat.com>
References: <20170901173011.10745-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170901173011.10745-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, David Woodhouse <dwmw2@infradead.org>, Alistair Popple <alistair@popple.id.au>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Stephen Rothwell <sfr@canb.auug.org.au>, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-next@vger.kernel.org

Hello Jerome,

On Fri, Sep 01, 2017 at 01:30:11PM -0400, Jerome Glisse wrote:
> +Case A is obvious you do not want to take the risk for the device to write to
> +a page that might now be use by some completely different task.

used

> +is true ven if the thread doing the page table update is preempted right after

even

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 90731e3b7e58..5706252b828a 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1167,8 +1167,15 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
>  		goto out_free_pages;
>  	VM_BUG_ON_PAGE(!PageHead(page), page);
>  
> +	/*
> +	 * Leave pmd empty until pte is filled note we must notify here as
> +	 * concurrent CPU thread might write to new page before the call to
> +	 * mmu_notifier_invalidate_range_end() happen which can lead to a

happens

> +	 * device seeing memory write in different order than CPU.
> +	 *
> +	 * See Documentation/vm/mmu_notifier.txt
> +	 */
>  	pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
> -	/* leave pmd empty until pte is filled */
>  

Here we can change the following mmu_notifier_invalidate_range_end to
skip calling ->invalidate_range. It could be called
mmu_notifier_invalidate_range_only_end, or other suggestions
welcome. Otherwise we'll repeat the call for nothing.

We need it inside the PT lock for the ordering issue, but we don't
need to run it twice.

Same in do_huge_pmd_wp_page, wp_page_copy and
migrate_vma_insert_page. Every time *clear_flush_notify is used
mmu_notifier_invalidate_range_only_end should be called after it,
instead of mmu_notifier_invalidate_range_end.

I think optimizing that part too, fits in the context of this patchset
(if not in the same patch), because the objective is still the same:
to remove unnecessary ->invalidate_range calls.

> +				 * No need to notify as we downgrading page

are

> +				 * table protection not changing it to point
> +				 * to a new page.
> +	 			 *

> +		 * No need to notify as we downgrading page table to read only

are

> +	 * No need to notify as we replacing a read only page with another

are

> @@ -1510,13 +1515,43 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			if (pte_soft_dirty(pteval))
>  				swp_pte = pte_swp_mksoft_dirty(swp_pte);
>  			set_pte_at(mm, address, pvmw.pte, swp_pte);
> -		} else
> +		} else {
> +			/*
> +			 * We should not need to notify here as we reach this
> +			 * case only from freeze_page() itself only call from
> +			 * split_huge_page_to_list() so everything below must
> +			 * be true:
> +			 *   - page is not anonymous
> +			 *   - page is locked
> +			 *
> +			 * So as it is a shared page and it is locked, it can
> +			 * not be remove from the page cache and replace by
> +			 * a new page before mmu_notifier_invalidate_range_end
> +			 * so no concurrent thread might update its page table
> +			 * to point at new page while a device still is using
> +			 * this page.
> +			 *
> +			 * But we can not assume that new user of try_to_unmap
> +			 * will have that in mind so just to be safe here call
> +			 * mmu_notifier_invalidate_range()
> +			 *
> +			 * See Documentation/vm/mmu_notifier.txt
> +			 */
>  			dec_mm_counter(mm, mm_counter_file(page));
> +			mmu_notifier_invalidate_range(mm, address,
> +						      address + PAGE_SIZE);
> +		}
>  discard:
> +		/*
> +		 * No need to call mmu_notifier_invalidate_range() as we are
> +		 * either replacing a present pte with non present one (either
> +		 * a swap or special one). We handling the clearing pte case
> +		 * above.
> +		 *
> +		 * See Documentation/vm/mmu_notifier.txt
> +		 */
>  		page_remove_rmap(subpage, PageHuge(page));
>  		put_page(page);
> -		mmu_notifier_invalidate_range(mm, address,
> -					      address + PAGE_SIZE);
>  	}
>  
>  	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);

That is the path that unmaps filebacked pages (btw, not necessarily
shared unlike comment says, they can be private but still filebacked).

I'd like some more explanation about the inner working of "that new
user" as per comment above.

It would be enough to drop mmu_notifier_invalidate_range from above
without adding it to the filebacked case. The above gives higher prio
to the hypothetical and uncertain future case, than to the current
real filebacked case that doesn't need ->invalidate_range inside the
PT lock, or do you see something that might already need such
->invalidate_range?

I certainly like the patch. I expect ->invalidate_range users will
like the slight higher complexity in order to eliminate unnecessary
invalidates that are slowing them down unnecessarily. At the same time
this is zero risk (because a noop) for all other MMU notifier users
(those that don't share the primary MMU pagetables, like KVM).

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
