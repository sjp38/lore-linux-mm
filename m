Message-ID: <41FF00CE.8060904@yahoo.com.au>
Date: Tue, 01 Feb 2005 15:08:46 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page fault scalability patch V16 [3/4]: Drop page_table_lock
 in handle_mm_fault
References: <41E5B7AD.40304@yahoo.com.au> <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com> <41E5BC60.3090309@yahoo.com.au> <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com> <20050113031807.GA97340@muc.de> <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com> <20050113180205.GA17600@muc.de> <Pine.LNX.4.58.0501131701150.21743@schroedinger.engr.sgi.com> <20050114043944.GB41559@muc.de> <Pine.LNX.4.58.0501140838240.27382@schroedinger.engr.sgi.com> <20050114170140.GB4634@muc.de> <Pine.LNX.4.58.0501281233560.19266@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501281237010.19266@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501281237010.19266@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@muc.de>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

Slightly OT: are you still planning to move the update_mem_hiwater and
friends crud out of these fastpaths? It looks like at least that function
is unsafe to be lockless.

> @@ -1316,21 +1318,27 @@ static int do_wp_page(struct mm_struct *
>  			flush_cache_page(vma, address);
>  			entry = maybe_mkwrite(pte_mkyoung(pte_mkdirty(pte)),
>  					      vma);
> -			ptep_set_access_flags(vma, address, page_table, entry, 1);
> -			update_mmu_cache(vma, address, entry);
> +			/*
> +			 * If the bits are not updated then another fault
> +			 * will be generated with another chance of updating.
> +			 */
> +			if (ptep_cmpxchg(page_table, pte, entry))
> +				update_mmu_cache(vma, address, entry);
> +			else
> +				inc_page_state(cmpxchg_fail_flag_reuse);
>  			pte_unmap(page_table);
> -			spin_unlock(&mm->page_table_lock);
> +			page_table_atomic_stop(mm);
>  			return VM_FAULT_MINOR;
>  		}
>  	}
>  	pte_unmap(page_table);
> +	page_table_atomic_stop(mm);
> 
>  	/*
>  	 * Ok, we need to copy. Oh, well..
>  	 */
>  	if (!PageReserved(old_page))
>  		page_cache_get(old_page);
> -	spin_unlock(&mm->page_table_lock);
> 

I don't think you can do this unless you have done something funky that I
missed. And that kind of shoots down your lockless COW too, although it
looks like you can safely have the second part of do_wp_page without the
lock. Basically - your lockless COW patch itself seems like it should be
OK, but this hunk does not.

I would be very interested if you are seeing performance gains with your
lockless COW patches, BTW.

Basically, getting a reference on a struct page was the only thing I found
I wasn't able to do lockless with pte cmpxchg. Because it can race with
unmapping in rmap.c and reclaim and reuse, which probably isn't too good.
That means: the only operations you are able to do lockless is when there
is no backing page (ie. the anonymous unpopulated->populated case).

A per-pte lock is sufficient for this case, of course, which is why the
pte-locked system is completely free of the page table lock.

Although I may have some fact fundamentally wrong?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
