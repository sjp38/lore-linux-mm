Date: Mon, 2 Oct 2000 19:08:20 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.10.10010021447310.2206-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010021902530.1067-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Linus Torvalds wrote:
> On Mon, 2 Oct 2000, Rik van Riel wrote:
> > 
> > You will want to add page->mapping too, so we won't be kicking
> > buffermem data out of memory when we don't need to.
> 
> Fair enough.
> 
> > Also, you really want to free the bufferheads on the pages that
> > are in heavy use (say glibc shared ages) too...
> 
> I don't think they matter that much, but yes, we could just do this all
> outside the whole test.
> 
> > > (and yes, I think it should also start background writing - we
> > > probably need the gfp_mask to know whether we can do that).
> > 
> > Background writing is done by kupdate / kflushd.
> 
> .. but there's no reason why we should not do it here.
> 
> I'd MUCH rather work towards a setup where kupdate/kflushd goes
> away completely, and the work is done as a natural end result of
> just aging the pages.

I agree. But I don't know how much of this can be a 2.4 thing,
considering the __GFP_IO related locking issues ;(

> In fact, if you look at how the VM layer tries to wake up
> bdflush, you'll notice that the VM layer really wants to say
> "please flush more pages because I'm low on memory". Which is
> really another way of saying that kswapd should run more.

*nod*

> Note that the current "flush_dirty_buffers()" should just go
> away. It has no advantages compared to having
> "try_to_free_buffers(x,1)" on the properly aged LRU queue..

Yes it has. The write order in flush_dirty_buffers() is the order
in which the pages were written. This may be different from the
LRU order and could give us slightly better IO performance.

OTOH, having proper write clustering code to do everything from
the LRU queue will be much much better, but that's probably a
2.5 issue ...

Furthermore, we'll need to preserve the data writeback list,
since you really want to write back old data to disk some
time. However, we will want to get rid of flush_dirty_buffers()
for this purpose since it is mostly unsuitable for filesystems
that don't use buffer heads (yet), like XFS with del-alloc,
filesystems with write ordering constraints or network FSes..

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
