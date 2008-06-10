Date: Tue, 10 Jun 2008 04:53:12 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm: vmap rewrite
Message-ID: <20080610025312.GC19404@wotan.suse.de>
References: <20080605102015.GA11366@wotan.suse.de> <484AC779.1070803@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <484AC779.1070803@goop.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jun 07, 2008 at 06:38:01PM +0100, Jeremy Fitzhardinge wrote:
> Nick Piggin wrote:
> >Hi. RFC.
> >
> >Rewrite the vmap allocator to use rbtrees and lazy tlb flushing, and 
> >provide a
> >fast, scalable percpu frontend for small vmaps.
> >
> >XEN and PAT and such do not like deferred TLB flushing. They just need to 
> >call
> >vm_unmap_aliases() in order to flush any deferred mappings.  That call is 
> >very
> >expensive (well, actually not a lot more expensive than a single vunmap 
> >under
> >the old scheme), however it should be OK if not called too often.
> >  
> 
> What are the performance characteristics?

Basically it goes through the lazy mappings, and does a global kernel TLB
flush and discards them if there were any. So in the case there was just
a single lazy mapping there, it will be about as expensive as the current
scheme (the TLB flush being the dominating cost), maybe a little more due
to extra logic involved. If you have multiple lazy mappings, it should
still be a win.


>  Can it be fast-pathed if 
> there are no outstanding aliases?

The TLB flush can be avoided. But I suspect what you really ask for is
whether a given page has outstanding aliases...

 
> For Xen, I'd need to do the alias unmap each time it allocates a page 
> for use in a pagetable.  For initial process construction that could be 
> deferred, but creating mappings on a live process could get fairly 
> expensive as a result.  The ideal interface for me would be a way of 
> testing if a given page has vmap aliases, so that we need only do the 
> unmap if really necessary.  I'm guessing that goes into "need a new page 
> flag" territory though...

It's harder than that even, because we don't own the page flags, so then
clearing the PG_kalias bit would require that we make all page flags ops
atomic in all parts of the kernel. Obviously not going to happen.

The other thing we could do is have vmap layer keep some p->v translations
around (actually it doesn't even need to go all the way to v, just a single
bit would suffice) So I guess this would be like another page flag, but
without the atomicity problem and without me getting angry at using another
flag ;) Still, I'd rather not do this and slow everything else down.

It could be switched on at runtime if Xen is running perhaps. Or the other
thing Xen could do is keep a cache of unaliased page table pages. You
could fill it up N pages at a time, and just do a single unmap_aliases call
to sanitize them all; also, clean pages returned from pagetables could be
reused. Like the quicklists things.

Or: doesn't the host have to do its own alias check anyway? In case of an
AWOL guest? Why not just reuse that and trap back into the guest to fix it
up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
