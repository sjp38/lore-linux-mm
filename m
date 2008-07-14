Date: Mon, 14 Jul 2008 16:52:38 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] - GRU virtual -> physical translation
Message-ID: <20080714215238.GA6503@sgi.com>
References: <20080709191439.GA7307@sgi.com> <20080711121736.18687570.akpm@linux-foundation.org> <20080714145255.GA23173@sgi.com> <20080714092451.2c81a472.akpm@linux-foundation.org> <20080714163107.GA936@sgi.com> <20080714195018.GD8534@sgi.com> <Pine.LNX.4.64.0807142057060.22604@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0807142057060.22604@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, nickpiggin@yahoo.com.au
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

> > Maybe I missed part of the discussion, but I thought follow_page() would
> > not work because you need this to function in the interrupt context and
> > locks would then need to be made irqsave/irqrestore.
> 
> Exactly, that seems to have gone missing from the patch explanation.
> 
> > This, of course does not in any way answer the question about why
> > follow_page() can not be exported.
> 
> I can't answer that either, and like Andrew I would have preferred
> to export follow_page, but for this locking issue: on the face of it,
> you cannot safely pte_offset_map_lock from interrupt context.

Agree. But there were flaws that you pointed out, I forgot, & Robin reminded
me.


> 
> But I do now wonder whether it was just my kneejerk reaction on seeing
> Jack's comment that it was needed in interrupt context.  After glancing
> through the GRU patches, I'm left wondering whether gru_intr is an
> asynchronous interrupt - in which case follow_page cannot be used,
> and it's not obvious to me that the version in this patch is safe -
> or whether it's more akin to a trap, coming in the context of the
> current mm, in which case using follow_page may be okay.

gru_intr() is truly an asynchronous interrupt.

The function that actually does the TLB dropin can be called thru two
different paths. One is from user context & should be safe for using
follow_page(). However, the other path really is via an async interrupt.
The GRU needs to do a lookup using something similar to the
get_user_pages_fast() function from Nick.


> I say it's not obvious to me that the version in this patch is safe,
> because I was wondering about the local_irq_disable there.  That's
> copied from Nick's fast GUP patches, but its function here is less
> obvious.  gru_intr already did down_read_trylock(&gts->ts->mmap_sem),
> which seems to give more guarantees than Nick relies upon; but is
> gts->ts_mm necessarily the same as current->mm or not?
> 
> If not, then you don't have quite the TLB flushing guarantees that
> Nick relies upon: you won't be sent an IPI to flush TLB if swapping
> or truncation suddenly frees the page, which that local_irq_disable
> is designed to keep at bay (if I understand fast GUP correctly)
> while we get a reference to the page to rescue it from freeing.

I think the GRU is ok but the reason is very specific to the GRU (but please
check me on this). In fact, maybe for this reason alone, I should open-code
the lookup. Otherwise the new lookup routine potentially could be misused by
other drivers.

The control structions used to manage the GRU & GRU TLB reside in normal
cacheable writeback memory. The GRU memory resides in the GRU chip - not
normal RAM. Aside from that, the GRU space appears to the cpu as RAM but
with a few special properties & side-effects.

The GRU is a home agent for all of the GRU space & tracks ownership of cache
lines that belong to the GRU.  At all times, the GRU is aware of whether a
cache line belonging to the GRU is unowned OR if a copy of the cacheline is
potentially held by a cpu.


A GRU TLB dropin consists of the following steps by a cpu:

	- read the TLB-related cacheline (referred to as a TFH) from the GRU.
	  This cacheline contains the vaddr that caused the miss.
	- convert the vaddr into a physical address
	- store the paddr into the TFH cacheline that contains the vaddr
	- issue a flush-cache to write the TFH cacheline back to the GRU.

If another cpu is flushing the same entry, there is a race that must be
resolved. For example cpu1 could be in the middle of a TLB dropin while
another cpu is purging the entry that is about to be dropped in. This is the
race that you refer to above. The timing could be something like:

	cpu 1					cpu 2
	-----					-----
	read TFH
	look up pte
						0 -> pte
						flush TLB 
						flush GRU TLB via MMUOPS callback
	extract paddr from pte
	store paddr -> TFH
	writeback TFH to GRU


The GRU has special hardware that eliminates the need for locks to resolve
this race.  If a TLB flush is issued AND the GRU does not own the TFH, the
subsequent TLB dropin is ignored. I think this solves the race shown above.


> But perhaps the MMU notification mechanism, or the GRU's
> "magic hardware", keeps it all safe.

The above is a very brief description of the "magic" hardware.


So.... How should I proceed?  It looks like 2 approaches:

1) add a get_user_pte_fast() as discussed in mail with Nick. This function
   would resides in gup.c and be exported to drivers can can handle the
   necessary races dealing with TLB flushes/dropin

2) Open code a fast pte walker in the GRU. This has the advantage that it
   does not add a difficult-to-use-correctly API to the kernel. The downside
   is that pte lookup functions are questionable in drivers. (Not sure if it
   is possible to implement the API on all arches. Might be restricted to
   arches that implement CONFIG_HAVE_GET_USER_PAGES_FAST. Other arches would always
   return "fail" but this is permitted by the API.


 
----
> (Personally, I dislike the other patch, adding zap_vma_ptes:
> to me it's just minor bloat and obscurity on top of the familiar
> zap_page_range; but I may be in a minority of one on that.)

I can live with either. The original zap_page_range() was NACKed with no
explanation. I looked at possible objections to exporting zap_page_range()
& the main one that I could find was that it far more powerful than
what a normal driver would need. I can understand this objection - it
makes sense to me. I floated the idea of a restricted form of a zap & got no
objections. But like I said - either works for me & I don't see an
obvious reason to chose one over the other.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
