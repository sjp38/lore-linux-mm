Date: Fri, 6 Apr 2001 15:12:01 -0400 (EDT)
From: Richard Jerrell <jerrell@missioncriticallinux.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.21.0104061932300.1374-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0104061503500.12558-100000@jerrell.lowell.mclinux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> swapper_space.nrpages, that's neat, but I insist it's not right.
> You're then double counting into "free" all the swap cache pages
> (already included in page_cache_size) which correspond to pages
> of swap for running processes - erring in the opposite direction
> to the present code.

Right.  We still have the same problem.  If you count the swap cache pages
once, you are underestimating the free memory.  If you count them twice,
you are overcommitting memory.  What we would need is to check in
swap_free for swap_map[i] count of 1 and a page->count of 1.  The cell
references the page, and the page references the cell.  These pages are
freeable _twice_ because they are sitting on twice as much memory as they
should be.  I'd say that overestimating your memory is better than denying
allocation when it's possible.

Rich

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
