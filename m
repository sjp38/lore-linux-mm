From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906282051.NAA12151@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
Date: Mon, 28 Jun 1999 13:51:03 -0700 (PDT)
In-Reply-To: <Pine.BSO.4.10.9906281625130.24888-100000@funky.monkey.org> from "Chuck Lever" at Jun 28, 99 04:33:44 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: andrea@suse.de, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> > Other than the deadlock problem, there's another issue involved, I 
> > think. Processes can go to sleep (inside drivers/fs for example while
> > mmaping/munmaping/faulting) holding their mmap_sem, so any solution 
> > should be able to guarantee that (at least one of) the memory free'ers 
> > do not go to sleep indefinitely (or for some time that is upto driver/fs
> > code to determine).
> 
> or perhaps the kernel could start more than one kswapd (one per swap
> partition?).  with my patch, regular processes never wait for swap out
> I/O, only kswapd does.
> 
> if you're concerned about bounding the latency of VM operations in order
> to provide some RT guarantees, then i'd imagine, based on what i've read
> on this list, that Linus might want to keep things simple more than he'd
> want to clutter the memory freeing logic... but if there's a simple way to
> "guarantee" a low latency then it would be worth the trouble.

Oh no, I was not talking about exotic stuff like RT ... I was 
simply pointing out that to prevent deadlocks, and guarantee forward
progress, you have to show that despite what underlying fs/driver
code does, at least one memory freer is free to do its job. Else,
under low memory conditions, no memory freer can free up memory, so
the system is effectively hung. If you have to wait for mmap_sem, 
you can not easily do that (unless you are willing to do a trylock 
for mmap_sem, ie give up on a process and continue scanning for others). 
This is partly why after thinking about it, I did not attempt to do 
this myself. 

Note that while Stephen's 2.2 kpiod work was probably aimed at
fixing fs deadlocks, I think it also gave the nice property that
the chances that the "swapout" method goes to sleep were reduced.
Not to 0, since make_pio_request() itself requests memory ...
Things are probably much better in 2.3, I am not upto date with
.7 and .8. 

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
