Date: Tue, 29 Jan 2008 15:03:45 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 4/6] MMU notifier: invalidate_page callbacks using
	Linux rmaps
Message-ID: <20080129140345.GG7233@v2.random>
References: <20080128202840.974253868@sgi.com> <20080128202924.334342410@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080128202924.334342410@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2008 at 12:28:44PM -0800, Christoph Lameter wrote:
>  	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
> -			(ptep_clear_flush_young(vma, address, pte)))) {
> +			(ptep_clear_flush_young(vma, address, pte) ||
> +				mmu_notifier_age_page(mm, address)))) {

here an example of how inferior and error prone it is to have
mmu_notifier_age_page and invalidate_page outside of pgtable.h, you
just managed to break again with the above || go figure. The
mmu_notifier_age_page has to be called unconditionally regardless of
ptep_clear_flush_young return value, we want to give only one
additional LRU scan to the referenced pages, not more than that or the
KVM guest pages will get tons more priority than the regular linux
anonymous memory.

>  		ret = SWAP_FAIL;
>  		goto out_unmap;
>  	}
> @@ -688,6 +693,7 @@ static int try_to_unmap_one(struct page 
>  	/* Nuke the page table entry. */
>  	flush_cache_page(vma, address, page_to_pfn(page));
>  	pteval = ptep_clear_flush(vma, address, pte);
> +	mmu_notifier(invalidate_page, mm, address);
>  
>  	/* Move the dirty bit to the physical page now the pte is gone. */
>  	if (pte_dirty(pteval))
> @@ -815,9 +821,13 @@ static void try_to_unmap_cluster(unsigne
>  		if (ptep_clear_flush_young(vma, address, pte))
>  			continue;
>  
> +		if (mmu_notifier_age_page(mm, address))
> +			continue;
> +

Here the same exact aging regression compared to my code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
