Date: Fri, 6 Apr 2001 17:31:30 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.31.0104051727490.1149-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0104061638200.1098-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2001, Linus Torvalds wrote:
> 
> I'd prefer something more along these lines: it gets rid of
> free_page_and_swap_cache() altogether, along with "is_page_shared()",
> realizing that "is_page_shared()" was only validly used on swap-cache
> pages anyway and thus getting rid of the generic tests it had for other
> kinds of pages.

I like this direction, but (if I understand the issues better today
than I did yesterday) the patch you posted looks seriously incomplete
to me.  While it deals with one of the issues raised by Rich Jerrell
(writing dead swap pages), doesn't it exacerbate his other issue?

That after a process exits (unmaps), if a page was in the swap cache,
its swap slot will remain allocated until vmscan.c gets to deal with it;
which would be okay, except that vm_enough_memory() may give false
negatives meanwhile, because there's no count of such pages (and Rich
gave the nice example that immediately starting up the same program
again was liable to fail because of this).  Exacerbates, because
that problem was just on the !pte_present entries, now with your
patch it would be on the pte_present entries too.

But I don't agree with the way Rich adds his nr_swap_cache_pages to
"free" in his vm_enough_memory(), because cached pages are all already
counted into "free" from page_cache_size - so I believe he's double-
accounting all the swap cache pages as free, when it should just be
those which (could) have been freed on exit/unmap.  And to count those,
I think you'd have to reinstate code like free_page_and_swap_cache().

Instead, perhaps vm_enough_memory() should force a scan to free
before failing?  And would need to register its own memory pressure,
so the scan tries hard enough to provide what will be needed?

Sorry, we've moved well away from Ben's "swap_state.c thinko".

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
