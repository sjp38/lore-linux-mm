Date: Fri, 6 Apr 2001 19:23:16 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.31.0104061011120.12081-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0104061849290.1331-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Apr 2001, Linus Torvalds wrote:
> 
> On Fri, 6 Apr 2001, Hugh Dickins wrote:
> >
> > I like this direction, but (if I understand the issues better today
> > than I did yesterday) the patch you posted looks seriously incomplete
> > to me.  While it deals with one of the issues raised by Rich Jerrell
> > (writing dead swap pages), doesn't it exacerbate his other issue?
> 
> Yes. However, I'm assuming most of that is just "statistics get buggered",
> in that swap pages tend to stay around for longer than they really are
> used. It was true before, but it would be _consistently_ true now.

Yes, I like it that the pte_present route becomes consistent with
the !pte_present route, and I share your belief that any problems
won't be _new_ ones.  But I supposed that Rich was describing a
practical problem, not just temporarily buggered statistics.

> I don't agree with your vm_enough_memory() worry - it should be correct
> already, because it shows up as page cache pages (and that, in turn, is
> already taken care of). In fact, the swap cache pages shouldn't even
> create any new special cases: they are exactly equivalent to already-
> existing page cache pages.

It is, of course, remotely conceivable that I'm confused, but...
I realize that the page cache pages (including those of swap)
are already added into "free" by vm_enough_memory().  But it's also
adding in nr_swap_pages, and that number is significantly less than
what it should be, because freeable swap slots have not been freed.
Therefore I think we need to add in that (sadly unknown) number of
should-have-been-freed slots - not because the memory hasn't been
properly counted, but because the swap hasn't been properly counted.

If this is not the case, then I (again) don't understand Rich's
difficulty in running the program just after it exited.

> (I considered moving the swap-cache page earlier in page_launder(), but
> I'd just be happier if we could have this all in swap_writepage() and not
> pollute any of the rest of the VM at all. Pipe-dream, maybe).

Aside from the vm_enough_memory() issue, if you leave page_launder()
to clean up, then some reordering there might well be good: isn't it
liable to clean and free some aged but potentially useful pages (e.g.
cached pages of live data on swap) before the entirely useless cached
pages of dead process data?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
