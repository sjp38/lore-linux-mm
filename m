Date: Tue, 29 Jun 1999 11:27:05 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <Pine.LNX.4.10.9906290412140.11414-100000@laser.random>
Message-ID: <Pine.BSO.4.10.9906291050090.20262-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 1999, Andrea Arcangeli wrote:
> On Mon, 28 Jun 1999, Chuck Lever wrote:
> >yes, that's exactly what i did.  what i can't figure out is why do the
> >shrink_mmap in both places?  seems like the shrink_mmap in kswapd is
> >overkill if it has just been awoken by try_to_free_pages.
> 
> If you remove the shrink_mmap from kswapd then you'll start swapping all
> the time.

yes, i discovered that rather quickly when i tried it. :)

> shrink_mmap give us the information about the state of
> the VM. So if you run it then you know if you should start swapping or
> not.

but it also "destroys" that state while it's running.  it would be much
nicer, i think, if there was a way to ascertain the state cheaply, then
decide whether to shrink caches or swap, or both.  i think a better
decision could be made this way.  what do you think about separating
shrink_mmap's function into two separate pieces:  maintain state
information, and trim caches?

i've been studying a hard knee that occurs just as the system exhausts
memory and try_to_free_pages is invoked.  performance drops rather
dramatically.  while i was playing around with kswapd, i noticed that when
my system started to swap more during low-memory scenarios, it seemed to
perform better; the knee is "softened".

by switching back and forth between an "all swap all the time" model and
an "all shrink_mmap all the time" model, it was clear to me, at least for
my workload, that shrink_mmap is valuable up to a point, but swapping is
quite effective at increasing available memory because it's heuristic for
choosing a memory-idle process is very good (based on watching subsequent 
swap-in numbers), and there is probably 10-12M of idle crap that can be
flushed if the system gets loaded down, that currently is left in RAM.

in my opinion, the kernel is using shrink_mmap too much and not swapping
enough.  but it isn't clear to me exactly how to rebalance the two, or how
to gather more information in do_try_to_free_pages to make a better
decision about how to get back some memory.

> I suggest you to run some memory hog that rotate 20/30mbyte of data in the
> swap to check iteractive performances.

i have a test that does roughly this -- diff two kernel source trees.

however, it's clear that breaking try_to_free_pages and kswapd into two
separate paths won't provide the locking gain i was after.  however,
unrelated to the above discussion, do_try_to_free_pages may hold onto the
kernel lock for a long time, so finding a safe place for shrink_mmap
and/or swap_out to release it occassionally would help.

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
