Date: Mon, 28 Jun 1999 17:32:05 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <199906282051.NAA12151@google.engr.sgi.com>
Message-ID: <Pine.BSO.4.10.9906281715420.24888-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: andrea@suse.de, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 1999, Kanoj Sarcar wrote:
> > or perhaps the kernel could start more than one kswapd (one per swap
> > partition?).  with my patch, regular processes never wait for swap out
> > I/O, only kswapd does.
> > 
> > if you're concerned about bounding the latency of VM operations in order
> > to provide some RT guarantees, then i'd imagine, based on what i've read
> > on this list, that Linus might want to keep things simple more than he'd
> > want to clutter the memory freeing logic... but if there's a simple way to
> > "guarantee" a low latency then it would be worth the trouble.
> 
> Oh no, I was not talking about exotic stuff like RT ... I was 
> simply pointing out that to prevent deadlocks, and guarantee forward
> progress, you have to show that despite what underlying fs/driver
> code does, at least one memory freer is free to do its job. Else,
> under low memory conditions, no memory freer can free up memory, so
> the system is effectively hung. If you have to wait for mmap_sem, 
> you can not easily do that (unless you are willing to do a trylock 
> for mmap_sem, ie give up on a process and continue scanning for others). 
> This is partly why after thinking about it, I did not attempt to do 
> this myself. 

(i also tried down_trylock, but discarded it.)

well, except that kswapd itself doesn't free any memory.  it simply copies
data from memory to disk.  shrink_mmap() actually does the freeing, and
can do this with minimal locking, and from within regular application
processes.  when a process calls shrink_mmap(), it will cause some pages
to be made available to GFP.

if you need evidence that shrink_mmap() will keep a system running without
swapping, just run 2.3.8 :) :)

come to think of it, i don't think there is a safety guarantee in this
mechanism to prevent a lock-up.  i'll have to think more about it.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
