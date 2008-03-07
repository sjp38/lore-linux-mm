Received: by gv-out-0910.google.com with SMTP id n8so460726gve.19
        for <linux-mm@kvack.org>; Fri, 07 Mar 2008 13:13:51 -0800 (PST)
Date: Sat, 8 Mar 2008 00:13:22 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] [6/13] Core maskable allocator
Message-ID: <20080307211322.GD7589@cvg>
References: <200803071007.493903088@firstfloor.org> <20080307090716.9D3E91B419C@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080307090716.9D3E91B419C@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Andi Kleen - Fri, Mar 07, 2008 at 10:07:16AM +0100]
[...]
| +
| +/**
| + * alloc_pages_mask - Alloc page(s) in a specific address range.
| + * @gfp:      Standard GFP mask. See get_free_pages for a list valid flags.
| + * @size:     Allocate size worth of pages. Rounded up to PAGE_SIZE.
| + * @mask:     Memory must fit into mask physical address.
| + *
| + * Returns a struct page *
| + *
| + * Manage dedicated maskable low memory zone. This zone are isolated
| + * from the normal zones. This is only a single continuous zone.
| + * The main difference to the standard allocator is that it tries
| + * to allocate memory with an physical address fitting in the passed mask.
| + *
| + * Warning: the size is in bytes, not in order like get_free_pages.
| + */
| +struct page *
| +alloc_pages_mask(gfp_t gfp, unsigned size, u64 mask)
| +{
| +	unsigned long max_pfn = mask >> PAGE_SHIFT;
| +	unsigned pages = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
| +	struct page *p;
| +	unsigned left = (gfp & __GFP_REPEAT) ? ~0 : mask_timeout, oleft;
| +	unsigned order = get_order(size);
| +
| +	BUG_ON(size < MASK_MIN_SIZE);	/* You likely passed order by mistake */
| +	BUG_ON(gfp & (__GFP_DMA|__GFP_DMA32|__GFP_COMP));
| +
| +	/* Add fault injection here */
| +
| +again:
| +	count_vm_event(MASK_ALLOC);
| +	if (!force_mask) {
| +		/* First try normal allocation in suitable zones
| +		 * RED-PEN if size fits very badly in PS<<order don't do this?
| +		 */
| +		p = alloc_higher_pages(gfp, order, max_pfn);
| +
| +		/*
| +		 * If the mask covers everything don't bother with the low zone
| +		 * This way we avoid running out of low memory on a higher zones
| +		 * OOM too.
| +		 */
| +		if (p != NULL || max_pfn >= max_low_pfn) {

Andi, I'm a little confused by _this_ statistics. We could get p = NULL
there and change MASK_HIGH_WASTE even have mask not allocated. Am I
wrong or miss something? Or maybe there should be '&&' instead of '||'?

| +			count_vm_event(MASK_HIGHER);
| +			count_vm_events(MASK_HIGH_WASTE,
| +					(PAGE_SIZE << order) - size);
| +			return p;
| +		}
| +	}
| +
| +	might_sleep_if(gfp & __GFP_WAIT);
| +	do {
| +		int i;
| +		long pfn;
| +
| +		/* Implement waiter fairness queueing here? */
| +
| +		pfn = alloc_mask(pages, max_pfn);
| +		if (pfn != -1L) {
| +			p = pfn_to_page(pfn);
| +
| +			Mprintk("mask page %lx size %d mask %Lx\n",
| +			       po, size, mask);
| +
| +			BUG_ON(pfn + pages > mask_max_pfn);
| +
| +			if (page_prep_struct(p))
| +				goto again;
| +
| +			kernel_map_pages(p, pages, 1);
| +
| +			for (i = 0; i < pages; i++) {
| +				struct page *n = p + i;
| +				BUG_ON(!test_bit(pfn_to_maskbm_index(pfn+i),
| +						mask_bitmap));
| +				BUG_ON(!PageMaskAlloc(n));
| +				arch_alloc_page(n, 0);
| +				if (gfp & __GFP_ZERO)
| +					clear_page(page_address(n));
| +			}
| +
| +			count_vm_events(MASK_LOW_WASTE, pages*PAGE_SIZE-size);
| +			return p;
| +		}
| +
| +		if (!(gfp & __GFP_WAIT))
| +			break;
| +
| +		oleft = left;
| +		left = wait_for_mask_free(left);
| +		count_vm_events(MASK_WAIT, left - oleft);
| +	} while (left > 0);
| +
| +	if (!(gfp & __GFP_NOWARN)) {
| +		printk(KERN_ERR
| +		"%s: Cannot allocate maskable memory size %u gfp %x mask %Lx\n",
| +				current->comm, size, gfp, mask);
| +		dump_stack();
| +	}
| +	return NULL;
| +}
| +EXPORT_SYMBOL(alloc_pages_mask);
| +
[...]
		- Cyrill -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
