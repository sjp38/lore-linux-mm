Date: Thu, 30 Mar 2000 20:57:34 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: shrink_mmap SMP race fix
In-Reply-To: <Pine.LNX.4.21.0003301406530.1104-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0003302042030.8695-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Mar 2000, Rik van Riel wrote:

>Sorry, but if page aging happens elsewhere, why do we go through
>the trouble of maintaining an LRU list in the first place?

We can use the LRU for the page aging at any time. I did that at first.
But to do that we have to roll the page-LRU at each page/swap/buffer cache
hit and that's slow and not worty. Setting a bit is much faster and the
roll of the list become zero cost in shrink_mmap and the current aging
works fine as far I can tell.

>The answer is that the one-bit "page aging" (NRU replacement) of
>pages in the page tables simply isn't enough. I agree that the

Actually it's better than NRU for the aging anyway since new pages are
allocated always added to the bottom of the LRU for example. Also with the
LRU we avoid wasting time in non-cache pages and if almost all cache is
freeable shrink_mmap works in O(1) despite of how much memory is allocated
in userspace or in non cache things (that wasn't true in
2.2.x). Also thanks to the page-LRU 2.3.x doesn't random swap as 2.2.x
does.

>The idea of this approach is that we need the LRU cache to do some
>aging on pages we're about to free. We absolutely need this because
>otherwise the system will be thrashing much earlier than needed.
>Good page replacement simply is a must.

I really don't think aging is the problem. If you want I can send you the
patch to replace the test_and_set_bit(PG_referenced) with a perfect and
costly roll of the lru list. That's almost trivial patch. But I'm 99& sure
you'll get the same swap behaviour.

The _real_ problem is that we have to split the LRU in page/buffer-cache
LRU and swap-cache LRU. And then we have to always try to shrink the
swap-cache LRU first. This is what we have to do for great swap behaviour
IMHO. But there's a problem, to do that we have to keep the mapped pages
out of the LRU (at least out of the swap-cache LRU), otherwise we'll have
to pass over all the unfreeable mapped swap cache pages before we can
shrink the page/buffer cache and that would have a too high complexity
cost that we can't accept (it would hit us also when the memory pressure
is finished).

Shrinking the unused swap cache first is the way to go.

>That would be great!

Do you think we should do that for 2.4.x? How is the current swap
behaviour with low mem? It doesn't feel bad to me while pushing 100mbyte
on swap in 2.3.99-pre4-pre1 + the latest posted patches (but I have to say
that I don't hit swap while closing the linux-kernel folder anymore... ;).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
