Date: Wed, 15 Aug 2001 19:15:52 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.21.0108160009520.972-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0108151901310.26574-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 16 Aug 2001, Hugh Dickins wrote:

> On Wed, 15 Aug 2001, Marcelo Tosatti wrote:
> > 
> > Hugh, could you check which kind of allocation is failing and from where?
> > (allocation flags, etc).
> 
> Whenever I looked the allocation flags were 0x70,
> __GFP_IO|__GFP_HIGH|__GFP_WAIT; but presumably PF_MEMALLOC too.
> 
> What I was doing was running a memory hog (for 600MB with 256MB
> RAM and 512MB swap), exiting that, doing swapoff -a and swapon -a
> (being interested in timing different swapoff methods).  First
> run no problem at all, but when immediately run again after,
> collapsed into endless 0-order allocation failure messages.
> Didn't happen in 2.4.8.  Linus' patch to 2.4.9-pre4 gets it
> back to work again, after a burst of those messages.
> 
> The stack trace was usually some high-level function, _alloc_pages,
> __alloc_pages, try_to_free_pages, do_try_to_free_pages, page_launder,
> swap_writepage, rw_swap_page, rw_swap_page_base, brw_page,
> create_empty_buffers, create_buffers, get_unused_buffer_head,
> kmem_cache_alloc, kmem_cache_grow, __get_free_pages,
> _alloc_pages, __alloc_pages, printk.
> 
> But on one occasion it was kswapd calling
> do_try_to_free_pages, page_launder, swap_writepage... as above.

Linus, 

The problem is probably "showing up" due to the reduced scan of the
inactive dirty list in 2.4.9pre.

It looks like allocations keep failing until page_launder() finds clean
buffers to free. Since the scan rate is much smaller now, that is likely
to happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
