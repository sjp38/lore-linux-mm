Date: Fri, 6 Apr 2001 10:21:38 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.21.0104061638200.1098-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.31.0104061011120.12081-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 6 Apr 2001, Hugh Dickins wrote:
>
> I like this direction, but (if I understand the issues better today
> than I did yesterday) the patch you posted looks seriously incomplete
> to me.  While it deals with one of the issues raised by Rich Jerrell
> (writing dead swap pages), doesn't it exacerbate his other issue?

Yes. However, I'm assuming most of that is just "statistics get buggered",
in that swap pages tend to stay around for longer than they really are
used. It was true before, but it would be _consistently_ true now.

I don't agree with your vm_enough_memory() worry - it should be correct
already, because it shows up as page cache pages (and that, in turn, is
already taken care of). In fact, the swap cache pages shouldn't even
create any new special cases: they are exactly equivalent to already-
existing page cache pages.

So if this patch generates any problems, then those problems were
pre-existing, and the patch just triggers them more easily. For example,
it may shift the load to look a bit more like there are lots of dirty
shared pages, and maybe we haven't handled that load well before. In that
sense this is one of those "can trigger cases we haven't tested well
enough" patches, but I don't think it should introduce _new_ problems.

> Instead, perhaps vm_enough_memory() should force a scan to free
> before failing?  And would need to register its own memory pressure,
> so the scan tries hard enough to provide what will be needed?

I don't think so. It _already_ considers every single page cache page to
be completely droppable. So I don't think vm_enough_memory() can fail any
more due to my change - the only thing that happened was that pages that
were counted as "free" got moved to "page cache", but the math ends up
giving the exact same answer anyway:

	...
        free += atomic_read(&page_cache_size);
        free += nr_free_pages();
	...

Does anybody actually see failures with this path? Maybe they are due to
"page_launder()" not getting rid of the page swap pages aggressively
enough..

(I considered moving the swap-cache page earlier in page_launder(), but
I'd just be happier if we could have this all in swap_writepage() and not
pollute any of the rest of the VM at all. Pipe-dream, maybe).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
