Date: Tue, 25 Apr 2000 17:26:42 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.21.0004251619270.10408-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.10.10004251656150.1145-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 25 Apr 2000, Rik van Riel wrote:
> 
> > That is obviously not to say that the current code gets the
> > heuristics actually =right=. There are certainly bugs in the
> > heuristics, as shown by bad performance.
> 
> The only bug I can see is that page _freeing_ in the current
> code is done on a per-zone basis, so that we could end up with
> a whole bunch of underused pages in one zone and too much
> memory pressure in the other zone.

Yes.

I removed the "zone" argument from try_to_swap_out(), because I just
always found it odious that it walked the page tables but then ignored all
the work it did if the page happened to be from the wrong zone - even if
that zone happened to be low on memory too. Just because we passed in one
zone, and the page to be free'd was of another zone equally well suited to
being free'd.

However, when I removed that argument, I completely removed the logic to
avoid freeing pages from an ok zone. And it really should be there, but it
should look something like

	/* Don't free a page if the zone in question is fine */
	if (!page->zone->zone_wake_kswapd)
		return 0;

instead of what it used to be (ie used to be something like

	if (zone && page->zone != zone)
		return 0;

which is just bogus, in my opinion, and I prefer removing bogus code
completely in order for it to not entrench itself too much).

That single test might actually improve things a lot, but this is the kind
of issue that needs testing/thinking beyond just my kind of "I think this
is the way things should work" approach. I tend to think that I'm good at
knowing how things _should_ work, but I'm just horribly lazy and bad at
the final test-and-tweak kind of thing. And this definitely needs some of
that.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
