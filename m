Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA22162
	for <linux-mm@kvack.org>; Fri, 1 Jan 1999 11:46:25 -0500
Date: Fri, 1 Jan 1999 17:44:55 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
In-Reply-To: <Pine.LNX.3.96.981231193257.330B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990101171008.1145B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I' ll try to comment my latest VM patch.

The patch basically do two things.

It add an heuristic to block trashing tasks in try_to_free_pages() and
allow normal tasks to run fine in the meantime.

It returns to the old do_try_to_free_pages() way to do things. I think the
reason the old way was no longer working well is that we are using
swap_out()  as other freeing-methods while swapout has really nothing to
do with them. 

To get VM stability under low memory we must use both swap_out() (that put
pages from the user process Vmemory to the swap cache) and shrink_mmap() 
in a new method. My new method put user pages in the swap cache because
there we can handle aging very well. Then shrink_mmap() can free a not
refernced page to really do some progress in the memory freeing (and not
only in the swapout).

So basically my patch cause sure the system to swapout more than we was
used to do, but most of the time we will not need a swapin to reput the
pages in the process Vmemory.

Somebody reported a big slowdown of the trashing application. Right now I
don't know which bit of the patch caused this slowdown (yesterday my
benchmark here didn't showed this slowdown). My new trashing_memory
heuristic will probably decrease performance for the trashing application
(but hey you know that if you need performance you can alwaws buy more RAM
;), but it will improve a lot performance for normal not-trashing tasks. 

I' ll try to change do_free_user_and_cache() to see if I can achieve
something better.

I changed also the swap_out() since the best way to choose a process it to
compare the raw RSS I think. And I don' t want that swap_cnt is decreased
of something every time something is swapped out. I want that the kernel
will continue passing throught all the pages of one process once it
started playing with it (if it will still exists of course ;). I changed
also the pressure of swap_out() since it make no sense to me to pass more
than one time over the VM of all tasks in the system. Now at priority 6
swap_out()  is trying to swapout something at max from nr_tasks/7 (low
bound to 1 task). I changed also the pressure of shrink_mmap() because it
was making no sense to me to do two passes on just not referenced pages.

I also changed swapout() allowing it to return 0 1 or more.

0 means that swap_out() is been not able to put in the swap cache
something.

1 means that swap_out() is been able to swapout something and has also
freed up one page (how??? it can't right now because the page should
always be still at least present in the swap cache)

2 means that swap_out() has swapped out 1 page and that the page is still
referenced somewhere (probably by the swap cache)

So in case 2 and case 0 we must use shrink_mmap() to really do some
progress in the page freeing.  This the idea that my new
do_free_user_and_cache() follows.

Comments?

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
