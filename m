Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 925B86B032D
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 06:24:41 -0400 (EDT)
Date: Mon, 25 Jun 2012 11:24:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: RFC:  Easy-Reclaimable LRU list
Message-ID: <20120625102435.GD8271@suse.de>
References: <4FE012CD.6010605@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4FE012CD.6010605@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Pekka Enberg <penberg@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>

On Tue, Jun 19, 2012 at 02:49:01PM +0900, Minchan Kim wrote:
> Hi everybody!
> 
> Recently, there are some efforts to handle system memory pressure.
> 
> 1) low memory notification - [1]
> 2) fallocate(VOLATILE) - [2]
> 3) fadvise(NOREUSE) - [3]
> 
> For them, I would like to add new LRU list, aka "Ereclaimable" which is opposite of "unevictable".
> Reclaimable LRU list includes _easy_ reclaimable pages.
> For example, easy reclaimable pages are following as. 
> 
> 1. invalidated but remained LRU list.
> 2. pageout pages for reclaim(PG_reclaim pages)
> 3. fadvise(NOREUSE)
> 4. fallocate(VOLATILE)
> 
> Their pages shouldn't stir normal LRU list and compaction might not migrate them, even.

Why would compaction not migrate them? We might still want to migrate
NORESUSE or VOLATILE pages.

> Reclaimer can reclaim Ereclaimable pages before normal lru list and will avoid unnecessary
> swapout in anon pages in easy-reclaimable LRU list.
> It also can make admin measure how many we have available pages at the moment without latency.

That's not true for PG_reclaim pages as those pages cannot be discarded
until writeback completes.

One reason why I tried moving PG_reclaim pages to a separate list was
to avoid excessive scanning when writing back to slow devices. If those
pages were moved to an "easy-reclaimable" LRU list then the value would
be reduced as scanning would still occur. It might make it worse because
the whole Ereclaimable list would be scanned for pages that cannot be
reclaimed at all before moving to another LRU list.

This separate list does not exist today because it required a page bit to
implement and I did not want it to be a 64-bit only feature. You will
probably hit the same problem.

The setting of the page bit is also going to be a problem but you may be
able to lazily move pages to the EReclaimable list in the same way
unevictable pages are handled.

> It's very important in recent mobile systems because page reclaim/writeback is very critical
> of application latency. Of course, it could affect normal desktop, too.
> With it, we can calculate fast-available pages more exactly with NR_FREE_PAGES + NR_ERECLAIMABLE_PAGES,
> for example. If it's below threshold we defined, we could trigger 1st level notification
> if we really need prototying low memory notification.
> 

If PG_reclaim pages are on this list, then that calculation will not be
helpful.

> We may change madvise(DONTNEED) implementation instead of zapping page immediately.
> If memory pressure doesn't happen, pages are in memory so we can avoid so many minor fault.
> Of course, we can discard instead of swap out if system memory pressure happens.
> We might implement it madvise(VOLATILE) instead of DONTNEED, but anyway it's off-topic in this thread.
> 
> As a another example, we can implement CFLRU(Clean-First LRU) which reclaims unmapped-clean cache page firstly.

That alters ageing of pages significantly. It means that workloads that
are using read heavily will have their pages discarded first.

> The rationale is that in non-rotation device, read/write cost is much asynchronous.

While this is true that does not justify throwing away unmapped clean
page cache first every time.

> Read is very fast while write is very slow so it would be a gain while we can avoid writeback of dirty pages
> if possible although we need several reads. It can be implemented easily with Ereclaimable pages, too.
> 
> Anyway, it's just a brain-storming phase and never implemented yet but decide posting before it's too late.
> I hope listen others opinion before get into the code.
> 

Care is needed. I think you'll only be able to use this list for
NORESUSE, VOLATILE and invalidated pages. If you add PG_reclaim it not be
"easily-reclaimable" and if you add clean unmapped pages then there will
be regressions in workloads that are read-intensive.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
