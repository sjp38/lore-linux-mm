Date: Wed, 7 Jun 2000 10:39:13 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
In-Reply-To: <qwwhfb5prq3.fsf@sap.com>
Message-ID: <Pine.LNX.4.21.0006071025330.14304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7 Jun 2000, Christoph Rohland wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> > Ahh, but it could easily swap them out when the last of the
> > pages is unmapped.
> > 
> > if (PageSHM(page) && not_in_use(page) && PageDirty(page)) {
> > 	swapentry_t entry;
> > 	entry.val = alloc_swap_entry();
> > 	....
> > 	rw_swap_page(page);
> > }
> > 
> > And the next time it can be freed like a normal SwapCache
> > page...
> 
> O.K. So what do I test in PageSHM()? Right now there is no such flag.

It's just another flag for page->flags usage. When we allocate
the SHM page (shm_nopage??), we simply mark the page as such.

The SetPage<foo>(page) macros in include/linux/mm.h can be used
for this.

> > > Thus shm does it's own page handling and swap out mechanism.
> > > Since I do not know enough about the page cache I will not do
> > > this before 2.5. If you think it can be easily done, feel free
> > > to do it yourself or show me the way to go (But I will be on
> > > vacation the next two weeks).
> > 
> > OK. The shrink_mmap() side of the story should be relatively
> > easy (see above), but the ipc/shm.c part is a complete mystery
> > to me ... ;(
> 
> You see and for me it's vice versa. The shm part is relatively
> easy. Pages in shm do not get introduced into any other cache
> unless they are swapped out. shm uses a very dumb algorithm to
> find swappable pages when shm_swap is called.

The only thing we really want to change is the algorithm to
find which pages to swap. If we can put the shm pages on the
normal LRU queue, we'll be finding better pages to swap out
and performance (and robustness) under load will be better.

> If we want to introduce the shm pages into the lru lists, we
> need a mark as shm page. Then we could perhaps make shm_swap
> obsolete and leave the work to shrink_mmap. But shrink_mmap is
> new to me...

Basically we need 2 things from the shm code, then I'll
be able to adapt shrink_mmap with a few minutes of work ;)

1) shm pages should be marked as such so we can recognise them
2) we need to be able to swap out shm pages (maybe just
   call a page->mapping->swapout() function?) by knowing just
   the page

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
