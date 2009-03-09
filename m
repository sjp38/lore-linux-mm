Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 70F306B0047
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:32:19 -0400 (EDT)
Date: Mon, 9 Mar 2009 13:31:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] atomic highmem kmap page pinning
Message-Id: <20090309133121.eab3bbd9.akpm@linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0903071731120.30483@xanadu.home>
References: <alpine.LFD.2.00.0903071731120.30483@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nicolas Pitre <nico@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan.kim@gmail.com, linux@arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Sat, 07 Mar 2009 17:42:44 -0500 (EST)
Nicolas Pitre <nico@cam.org> wrote:

> 
> Discussion about this patch is settling, so I'd like to know if there 
> are more comments, or if official ACKs could be provided.  If people 
> agree I'd like to carry this patch in my ARM highmem patch series since 
> a couple things depend on this.
> 
> Andrew: You seemed OK with the original one.  Does this one pass your 
> grottiness test?
> 
> Anyone else?
> 
> ----- >8
> From: Nicolas Pitre <nico@cam.org>
> Date: Wed, 4 Mar 2009 22:49:41 -0500
> Subject: [PATCH] atomic highmem kmap page pinning
> 
> Most ARM machines have a non IO coherent cache, meaning that the
> dma_map_*() set of functions must clean and/or invalidate the affected
> memory manually before DMA occurs.  And because the majority of those
> machines have a VIVT cache, the cache maintenance operations must be
> performed using virtual
> addresses.
> 
> When a highmem page is kunmap'd, its mapping (and cache) remains in place
> in case it is kmap'd again. However if dma_map_page() is then called with
> such a page, some cache maintenance on the remaining mapping must be
> performed. In that case, page_address(page) is non null and we can use
> that to synchronize the cache.
> 
> It is unlikely but still possible for kmap() to race and recycle the
> virtual address obtained above, and use it for another page before some
> on-going cache invalidation loop in dma_map_page() is done. In that case,
> the new mapping could end up with dirty cache lines for another page,
> and the unsuspecting cache invalidation loop in dma_map_page() might
> simply discard those dirty cache lines resulting in data loss.
> 
> For example, let's consider this sequence of events:
> 
> 	- dma_map_page(..., DMA_FROM_DEVICE) is called on a highmem page.
> 
> 	-->	- vaddr = page_address(page) is non null. In this case
> 		it is likely that the page has valid cache lines
> 		associated with vaddr. Remember that the cache is VIVT.
> 
> 		-->	for (i = vaddr; i < vaddr + PAGE_SIZE; i += 32)
> 				invalidate_cache_line(i);
> 
> 	*** preemption occurs in the middle of the loop above ***
> 
> 	- kmap_high() is called for a different page.
> 
> 	-->	- last_pkmap_nr wraps to zero and flush_all_zero_pkmaps()
> 		  is called.  The pkmap_count value for the page passed
> 		  to dma_map_page() above happens to be 1, so the page
> 		  is unmapped.  But prior to that, flush_cache_kmaps()
> 		  cleared the cache for it.  So far so good.
> 
> 		- A fresh pkmap entry is assigned for this kmap request.
> 		  The Murphy law says this pkmap entry will eventually
> 		  happen to use the same vaddr as the one which used to
> 		  belong to the other page being processed by
> 		  dma_map_page() in the preempted thread above.
> 
> 	- The kmap_high() caller start dirtying the cache using the
> 	  just assigned virtual mapping for its page.
> 
> 	*** the first thread is rescheduled ***
> 
> 			- The for(...) loop is resumed, but now cached
> 			  data belonging to a different physical page is
> 			  being discarded !
> 
> And this is not only a preemption issue as ARM can be SMP as well,
> making the above scenario just as likely. Hence the need for some kind
> of pkmap page pinning which can be used in any context, primarily for
> the benefit of dma_map_page() on ARM.
> 
> This provides the necessary interface to cope with the above issue if
> ARCH_NEEDS_KMAP_HIGH_GET is defined, otherwise the resulting code is
> unchanged.

OK by me.

> +/*
> + * Most architectures have no use for kmap_high_get(), so let's abstract
> + * the disabling of IRQ out of the locking in that case to save on a
> + * potential useless overhead.
> + */
> +#ifdef ARCH_NEEDS_KMAP_HIGH_GET
> +#define spin_lock_kmap()             spin_lock_irq(&kmap_lock)
> +#define spin_unlock_kmap()           spin_unlock_irq(&kmap_lock)
> +#define spin_lock_kmap_any(flags)    spin_lock_irqsave(&kmap_lock, flags)
> +#define spin_unlock_kmap_any(flags)  spin_unlock_irqrestore(&kmap_lock, flags)
> +#else
> +#define spin_lock_kmap()             spin_lock(&kmap_lock)
> +#define spin_unlock_kmap()           spin_unlock(&kmap_lock)
> +#define spin_lock_kmap_any(flags)    \
> +	do { spin_lock(&kmap_lock); (void)(flags); } while (0)
> +#define spin_unlock_kmap_any(flags)  \
> +	do { spin_unlock(&kmap_lock); (void)(flags); } while (0)
> +#endif

It's a little bit misleading to discover that a "function" called
spin_lock_kmap() secretly does an irq_disable().  Perhaps just remove
the "spin_" from all these identifiers?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
