Date: Sun, 24 Sep 2000 11:11:17 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: __GFP_IO && shrink_[d|i]cache_memory()?
In-Reply-To: <Pine.LNX.4.21.0009241158050.2789-100000@elte.hu>
Message-ID: <Pine.LNX.4.10.10009241101320.10311-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sun, 24 Sep 2000, Ingo Molnar wrote:
> 
> as a longer term solution, i'm wondering how hard it would be to propagate
> gfp_mask into the shrink_*() functions, and prevent recursion similarly to
> the swap-out logic? This way even GFP_BUFFER allocators could touch/free
> the dcache/icache.

Well, the gfp_mask actually _is_ propagated already, it's just that if
__GFP_IO isn't set the calls are never done.

A trivial patch would move the __GFP_IO test into the functions (no change
in behaviour), and then slowly move the test down to the proper place. We
should be able to do some SHM swapping even if __GFP_IO isn't set. For
example, I don't think shrinking the inode cache is actually illegal when
GPF_IO isn't set. In fact, it's probably only the buffer cache itself that
has to avoid recursion - the other stuff doesn't actually do any IO.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
