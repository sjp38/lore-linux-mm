Date: Mon, 7 Jul 2008 11:53:58 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 12/13] GRU Driver V3 -  export is_uv_system(), zap_page_range() & follow_page()
Message-ID: <20080707165358.GA16420@sgi.com>
References: <20080703213348.489120321@attica.americas.sgi.com> <20080703213633.890647632@attica.americas.sgi.com> <20080704073926.GA1449@infradead.org> <20080707143916.GA5209@sgi.com> <Pine.LNX.4.64.0807071657450.17825@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0807071657450.17825@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Hellwig <hch@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, cl@linux-foundation.org, akpm@osdl.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, holt@sgi.com, andrea@qumranet.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 07, 2008 at 05:29:54PM +0100, Hugh Dickins wrote:
> On Mon, 7 Jul 2008, Jack Steiner wrote:
> > > > +EXPORT_SYMBOL_GPL(follow_page);
> > > 
> > > NACK.
> > > 
> ...
> 
> > Currently, the driver calls follow_page() in interrupt context.
> 
> However, that's a problem, isn't it, given the pte_offset_map_lock
> in follow_page?  To avoid the possibility of deadlock, wouldn't we
> have to change all the page table locking to irq-disabling variants?
> Which I think we'd have reason to prefer not to do.

Good catch. I stupidly overlooked the locking. And I agree - changes to
irq-disabling is the wrong way to solve this.


> 
> Maybe study the assumptions Nick is making in his arch/x86/mm/gup.c
> in mm, and do something similar in your GRU driver (falling back to
> the slow method when anything's not quite right).  It's not nice to
> have such code out in a driver, but GRU is going to be exceptional,
> and it may be better to have it out there than pretence of generality
> in the core mm exporting it.

Ok, I'll take this approach. Open code a pagetable walker into the GRU
driver using the ideas of fast_gup(). This has the added benefit of being
able to optimize for exactly what is needed for the GRU. For example,
nr_pages is always 1 (at least in the current design).


> 
> Note that even the unlocked pte_offset_map which gup_pte_range uses,
> is in general unsafe at interrupt time: because of using a KM_PTE0
> atomic kmap which might be in use at the time of the interrupt.  But
> I doubt your GRU driver is intended for use in HIGHMEM architectures,
> so that may be enough to excuse it.

Right. the GRU driver supports only x86_64 & ia64. No HIGHMEM issues.

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
