Date: Mon, 28 Jun 1999 16:33:44 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <199906281955.MAA06984@google.engr.sgi.com>
Message-ID: <Pine.BSO.4.10.9906281625130.24888-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: andrea@suse.de, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 1999, Kanoj Sarcar wrote:
> > i'm already working on a patch that will allow kswapd to grab the mmap_sem
> > for the task that is about to be swapped.  this takes a slightly different
> > approach, since i'm focusing on kswapd and not on swapoff.  essentially
> > the patch does two things:
> 
> So, I would think some (if not mine) swapoff fix is still needed ...

oh absolutely!  i was thinking that my patch might help make your work
simpler, that's all.  once i've tested it a little more, i'll post it to
the list.

> Other than the deadlock problem, there's another issue involved, I 
> think. Processes can go to sleep (inside drivers/fs for example while
> mmaping/munmaping/faulting) holding their mmap_sem, so any solution 
> should be able to guarantee that (at least one of) the memory free'ers 
> do not go to sleep indefinitely (or for some time that is upto driver/fs
> code to determine).

or perhaps the kernel could start more than one kswapd (one per swap
partition?).  with my patch, regular processes never wait for swap out
I/O, only kswapd does.

if you're concerned about bounding the latency of VM operations in order
to provide some RT guarantees, then i'd imagine, based on what i've read
on this list, that Linus might want to keep things simple more than he'd
want to clutter the memory freeing logic... but if there's a simple way to
"guarantee" a low latency then it would be worth the trouble.

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
