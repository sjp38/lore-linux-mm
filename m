Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA04032
	for <linux-mm@kvack.org>; Tue, 28 Jul 1998 12:30:59 -0400
Date: Tue, 28 Jul 1998 18:13:11 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Page cache ageing: yae or nae?
In-Reply-To: <199807271051.LAA00702@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980728180533.6846A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Jul 1998, Stephen C. Tweedie wrote:

> Could you let me know just what benchmarks you were running when you
> added the first page ageing code to see a speedup?  I think we need to

It's not really a benchmark; it's just that mp3s or
quicktimes (played from disk instead of ram) run
smoothly with page aging and skip without.

> look carefully at the properties of the ageing scheme and the simple
> clock algorithm we had before to see where the best compromise is.  It

The clock algorithm will throw out the not-yet-used page we
just read-ahead (and which will be needed immediately after
clearing -- cf. Murphy).

An aging (or better, LRU) algorithm will only throw out the
read-ahead page if:
- we don't use it in a larger time
- we have used it and don't use it any more

One of the ideas behind this is that swap I/O is clustered
and often cheaper than filesystem I/O (both are the case on
my system, which is tuned for this).

On systems with a single spindle and the swap partition
_far_ away, both assumptions will obviously break.

Since both types of systems can be found rather often, a
dynamic scheme would probably be best; maybe even a 'cost'
factor on mounting/swapon...

> may be that we can get away with something simple like just reducing
> the initial page age for the page cache, but I'd like to make sure
> that the readahead problems you alluded to are not brought back by any
> other changes we make to the mechanism.

The problem is with balancing, not with balancing memory usage,
but with balancing I/O cost.

I think we should think up a mechanism that both preserves the
readahead performance and balances I/O; memory balancing is a
tertiary issue here...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
