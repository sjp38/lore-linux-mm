Date: Tue, 26 Sep 2000 02:32:17 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000926023217.H5010@athlon.random>
References: <20000926010332.G5010@athlon.random> <Pine.LNX.4.10.10009251617100.4587-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10009251617100.4587-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Sep 25, 2000 at 04:18:13PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 04:18:13PM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 26 Sep 2000, Andrea Arcangeli wrote:
> > 
> > The machine will run low on memory as soon as I read 200mbyte from disk.
> 
> So? 
> 
> Yes, at that point we'll do the LRU dance. Then we won't be low on memory
> any more, and we won't do the LRU dance any more. What's the magic in

We'll run low on memory again as soon as we read the next page from disk and so
very soon we'll have to roll around all the 1.5G private mapping again.  (the
program have a file working set larger than 200M)

If you want to see some number I can produce them. The testcase only need
to do a:

	truncate(1.5G)
	mmap(1.5G MAP_PRIVATE)
	fault in read mode into the mapped 1.5G
	measure how long it takes to read N Giga from disk

> zoneinfo that makes it not have to do the same thing?

The name "classzone" is misleading. The zoneinfo change is not relevant to this
case (it started only with the zoneinfo change that's why it's still called so).

This case is relevant on how the lru are been restructured.

To say it simple as soon as somebody faults into the pagecache I remove the
page from the LRU. Then munmap time (zap_page_range) the page is reinserted
into the LRU.

This avoids shrink_mmap to waste time into the mapped regions that shrink_mmap
can't do anything to change anyway. This mean that under cache pollution
there's no 1 cycle spent browsing those mapped pages and I know when it's time
to swapout in function of the age of the fs cache (so the system is very
efficient during cache pollution, this way the example performs equally to not
having any mapping in memory). The case without memory pressure (where the
working set fits in cache) is sure just fine of course.

When swap_out unmaps a page and put them back into the lru I know that such
page is not been touched recently and I consider it with zero age. (actually
it's not a big deal since there's only literally 1 bit of age, so
this may change in the future introducing more bits of info for the age)

Of course all the subtle cases of shared read only anonymous pages added to the
swap cache and page cache mapped but with bhs overlapped on it and some other
non obvious issue are handled correctly.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
