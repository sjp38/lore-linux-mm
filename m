Date: Thu, 5 Apr 2001 17:39:26 -0400 (EDT)
From: Richard Jerrell <jerrell@missioncriticallinux.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.21.0104051758360.1715-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0104051737480.12558-100000@jerrell.lowell.mclinux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I agree that PageSwapCache(page) needs to be retested when(if) the
> page lock is acquired, but isn't it best to check PageSwapCache(page)
> first as at present - won't it very often fail? won't the overhead of
> TryLocking and Unlocking every page slow down a hot path?

Yes and no.  It's only a couple of bit operations, so it's probably a
pretty negligable slow-down.  But, yes it will quite often fail especially
in low memory usage situations where there isn't much swapping going
on.  Adding a second test after the lock would slow down the infrequent
case and make it much more like the way lookup_swap_cache works.

> And isn't this free_page_and_swap_cache(), precisely the area that's
> currently subject to debate and patches, because swap pages are not
> getting freed soon enough?

What I think you are talking about are three seperate problems, somewhat
related.

1)  swap cache pages aren't counted in vm_enough_memory as free, meaning
that you can fail when trying to allocate memory merely because a lot of
pages have already been swapped out but not yet reclaimed or possibly even
laundered.  Because these pages are already in the swap cache, we know
that they can be freed if the normal path of kswapd is followed.

2)  we waste time by laundering swap cache pages that are no longer being
referenced by either ptes or indirectly through the swap cell references.

Problem 1 is what is causing quite a few people to fail prematurely when
trying to allocate memory.  Problem 2 is just wasting our time.  Combined,
however, the two problems have dead swap cache pages eating up swap cells,
memory, and time.

> problem to be solved; but I'd rather _imagined_ it was that the page
> would here be on an LRU list, raising its count and causing the
> is_page_shared(page) test to succeed despite not really shared.

is_page_shared is expecting that someone has one of the references to the
page and is trying to determine whether or not other people are interested
in it.  Being on the LRU isn't necessarily going to have the page's count
bumped by one.  As a matter of practice, though, the pages on the LRU are
all in the swap cache which by way of having the page referenced by the
swap cell will bump the count by one.  All this is not really part of the
problem.  The problem is just that 1) swap cache pages are freeable and
2) we didn't check to make sure anyone wanted that page before writing it
to disk.

Rich

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
