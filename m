Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id BC6006B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 01:49:07 -0400 (EDT)
Message-ID: <4FE012CD.6010605@kernel.org>
Date: Tue, 19 Jun 2012 14:49:01 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: RFC:  Easy-Reclaimable LRU list
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Pekka Enberg <penberg@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>

Hi everybody!

Recently, there are some efforts to handle system memory pressure.

1) low memory notification - [1]
2) fallocate(VOLATILE) - [2]
3) fadvise(NOREUSE) - [3]

For them, I would like to add new LRU list, aka "Ereclaimable" which is opposite of "unevictable".
Reclaimable LRU list includes _easy_ reclaimable pages.
For example, easy reclaimable pages are following as. 

1. invalidated but remained LRU list.
2. pageout pages for reclaim(PG_reclaim pages)
3. fadvise(NOREUSE)
4. fallocate(VOLATILE)

Their pages shouldn't stir normal LRU list and compaction might not migrate them, even.
Reclaimer can reclaim Ereclaimable pages before normal lru list and will avoid unnecessary
swapout in anon pages in easy-reclaimable LRU list.
It also can make admin measure how many we have available pages at the moment without latency.
It's very important in recent mobile systems because page reclaim/writeback is very critical
of application latency. Of course, it could affect normal desktop, too.
With it, we can calculate fast-available pages more exactly with NR_FREE_PAGES + NR_ERECLAIMABLE_PAGES,
for example. If it's below threshold we defined, we could trigger 1st level notification
if we really need prototying low memory notification.

We may change madvise(DONTNEED) implementation instead of zapping page immediately.
If memory pressure doesn't happen, pages are in memory so we can avoid so many minor fault.
Of course, we can discard instead of swap out if system memory pressure happens.
We might implement it madvise(VOLATILE) instead of DONTNEED, but anyway it's off-topic in this thread.

As a another example, we can implement CFLRU(Clean-First LRU) which reclaims unmapped-clean cache page firstly.
The rationale is that in non-rotation device, read/write cost is much asynchronous.
Read is very fast while write is very slow so it would be a gain while we can avoid writeback of dirty pages
if possible although we need several reads. It can be implemented easily with Ereclaimable pages, too.

Anyway, it's just a brain-storming phase and never implemented yet but decide posting before it's too late.
I hope listen others opinion before get into the code.

Any comment are welcome.
Thanks.

[1] http://lkml.org/lkml/2012/5/1/97
[2] https://lkml.org/lkml/2012/6/1/322
[3] https://lkml.org/lkml/2011/6/24/136

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
