Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
References: <Pine.LNX.4.21.0006070939330.14304-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 07 Jun 2000 15:04:36 +0200
In-Reply-To: Rik van Riel's message of "Wed, 7 Jun 2000 09:43:50 -0300 (BRST)"
Message-ID: <qwwhfb5prq3.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:
> Ahh, but it could easily swap them out when the last of the
> pages is unmapped.
> 
> if (PageSHM(page) && not_in_use(page) && PageDirty(page)) {
> 	swapentry_t entry;
> 	entry.val = alloc_swap_entry();
> 	....
> 	rw_swap_page(page);
> }
> 
> And the next time it can be freed like a normal SwapCache
> page...

O.K. So what do I test in PageSHM()? Right now there is no such flag.

> > Thus shm does it's own page handling and swap out mechanism.
> > Since I do not know enough about the page cache I will not do
> > this before 2.5. If you think it can be easily done, feel free
> > to do it yourself or show me the way to go (But I will be on
> > vacation the next two weeks).
> 
> OK. The shrink_mmap() side of the story should be relatively
> easy (see above), but the ipc/shm.c part is a complete mystery
> to me ... ;(

You see and for me it's vice versa. The shm part is relatively
easy. Pages in shm do not get introduced into any other cache unless
they are swapped out. shm uses a very dumb algorithm to find swappable
pages when shm_swap is called.

If we want to introduce the shm pages into the lru lists, we need a
mark as shm page. Then we could perhaps make shm_swap obsolete and
leave the work to shrink_mmap. But shrink_mmap is new to me...

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
