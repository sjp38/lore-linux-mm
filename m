Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA14204
	for <linux-mm@kvack.org>; Thu, 21 Jan 1999 15:38:08 -0500
Date: Thu, 21 Jan 1999 20:53:28 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901211650.QAA04674@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990121204645.1387F-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Dr. Werner Fink" <werner@suse.de>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 1999, Stephen C. Tweedie wrote:

> > I know that most of you do not like aging.  Nevertheless, on high stressed
> > systems with less than 128M you will see a critical point whereas the page
> > cache and readahead does not avoid that swapin I/O time needed by a program
> > increases to similar size of the average program time slice.
> 
> There's no reason why timeslices should have anything to do with swapin
> IO time; we do not count time spent waiting for IO against the process's
> allocated timeslice.

Yes we do I/O async so while the I/O is in action we could be just back in
userspace, but both shrink_mmap() and swap_out() are not something of
really so light (at least with >128Mbyte of ram). When we are running in
shrink_mmap() the current->counter is decreased as usual.

It's trivial conceptually make shrink_mmap() _fast_, adding two
prev_freeable,next_freeable pointers in the mem_map struct and adding
pages back and forth to the list (at the same time I now update
nr_freeable_pages). Probably I'll do that soon.

I see instead not trivial to decrease the cost of swap_out()... 

I agree that the timeslice has nothing to do with swapout/shrink_mmap
issue. But the timeslice _must_ be decremented as now during the
shrink_mmap/swapout passes, because otherwise we would risk to stall the
not trashing process too much. 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
