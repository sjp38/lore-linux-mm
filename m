Date: Sun, 24 Sep 2000 12:11:47 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: __GFP_IO && shrink_[d|i]cache_memory()?
Message-ID: <Pine.LNX.4.21.0009241158050.2789-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

i've seen a couple of GFP_BUFFER allocation deadlocks in an atypical
system which had lots of RAM allocated to inodes. The reason for the
deadlock is that the shrink_*() functions cannot be called if __GFP_IO is
not set. Nothing else can be freed at that point, so the try_again: loop
in page_alloc() gets into an infinite loop.

as an immediate solution the previous __GFP_WAIT suggestion solves the
deadlock - because the GFP_BUFFER allocator yields the CPU and kswapd can
run and do the dcache/icache shrinking. [i cannot reproduce any deadlocks
after doing this change.]

as a longer term solution, i'm wondering how hard it would be to propagate
gfp_mask into the shrink_*() functions, and prevent recursion similarly to
the swap-out logic? This way even GFP_BUFFER allocators could touch/free
the dcache/icache.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
