Date: Mon, 7 Jul 2008 11:58:44 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [patch 12/13] GRU Driver V3 -  export is_uv_system(),
 zap_page_range() & follow_page()
Message-ID: <20080707115844.5ee43343@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0807071657450.17825@blonde.site>
References: <20080703213348.489120321@attica.americas.sgi.com>
	<20080703213633.890647632@attica.americas.sgi.com>
	<20080704073926.GA1449@infradead.org>
	<20080707143916.GA5209@sgi.com>
	<Pine.LNX.4.64.0807071657450.17825@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jack Steiner <steiner@sgi.com>, Christoph Hellwig <hch@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, cl@linux-foundation.org, akpm@osdl.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, holt@sgi.com, andrea@qumranet.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jul 2008 17:29:54 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> On Mon, 7 Jul 2008, Jack Steiner wrote:
> > > > +EXPORT_SYMBOL_GPL(follow_page);
> > > 
> > > NACK.
> > > 
> > > These should never be called by a driver and suggest you need to
> > > rething your VM integration in this driver.
> > 
> > Can you provide some additional details on the type of kernel API
> > that could be exported to provide a pte lookup in atomic context?
> 
> I don't see EXPORT_SYMBOL_GPL(follow_page) as objectionable myself:
> it rather seems rather to complement EXPORT_SYMBOL(vm_insert_page)
> and EXPORT_SYMBOL(vmalloc_to_page); though I'd agree that it's
> sufficiently sensitive to need that _GPL on it.
> 
> ...
> 
> > Currently, the driver calls follow_page() in interrupt context.
> 
> However, that's a problem, isn't it, given the pte_offset_map_lock
> in follow_page?  To avoid the possibility of deadlock, wouldn't we
> have to change all the page table locking to irq-disabling variants?
> Which I think we'd have reason to prefer not to do.
> 
> Maybe study the assumptions Nick is making in his arch/x86/mm/gup.c
> in mm, and do something similar in your GRU driver (falling back to
> the slow method when anything's not quite right).  It's not nice to
> have such code out in a driver, but GRU is going to be exceptional,
> and it may be better to have it out there than pretence of generality
> in the core mm exporting it.
> 

I wonder if GRU even should be a module; it sounds rather like pretty
core functionality and if it's this invasive to the VM it probably
should be a real part of the VM instead

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
