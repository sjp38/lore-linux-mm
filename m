Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 4C2686B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 11:55:25 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1246293pbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 08:55:24 -0700 (PDT)
Date: Wed, 18 Jul 2012 00:03:48 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: RFC:  Easy-Reclaimable LRU list
Message-ID: <20120717160348.GA5441@gmail.com>
References: <4FE012CD.6010605@kernel.org>
 <20120625102435.GD8271@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120625102435.GD8271@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Pekka Enberg <penberg@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>

On Mon, Jun 25, 2012 at 11:24:35AM +0100, Mel Gorman wrote:
> On Tue, Jun 19, 2012 at 02:49:01PM +0900, Minchan Kim wrote:
> > Hi everybody!
> > 
> > Recently, there are some efforts to handle system memory pressure.
> > 
> > 1) low memory notification - [1]
> > 2) fallocate(VOLATILE) - [2]
> > 3) fadvise(NOREUSE) - [3]
> > 
> > For them, I would like to add new LRU list, aka "Ereclaimable" which is opposite of "unevictable".
> > Reclaimable LRU list includes _easy_ reclaimable pages.
> > For example, easy reclaimable pages are following as. 
> > 
> > 1. invalidated but remained LRU list.
> > 2. pageout pages for reclaim(PG_reclaim pages)
> > 3. fadvise(NOREUSE)
> > 4. fallocate(VOLATILE)
> > 
> > Their pages shouldn't stir normal LRU list and compaction might not migrate them, even.
> 
> Why would compaction not migrate them? We might still want to migrate
> NORESUSE or VOLATILE pages.
> 
> > Reclaimer can reclaim Ereclaimable pages before normal lru list and will avoid unnecessary
> > swapout in anon pages in easy-reclaimable LRU list.
> > It also can make admin measure how many we have available pages at the moment without latency.
> 
> That's not true for PG_reclaim pages as those pages cannot be discarded
> until writeback completes.
> 
> One reason why I tried moving PG_reclaim pages to a separate list was
> to avoid excessive scanning when writing back to slow devices. If those
> pages were moved to an "easy-reclaimable" LRU list then the value would
> be reduced as scanning would still occur. It might make it worse because
> the whole Ereclaimable list would be scanned for pages that cannot be
> reclaimed at all before moving to another LRU list.
> 
> This separate list does not exist today because it required a page bit to
> implement and I did not want it to be a 64-bit only feature. You will
> probably hit the same problem.
> 
> The setting of the page bit is also going to be a problem but you may be
> able to lazily move pages to the EReclaimable list in the same way
> unevictable pages are handled.
> 
> > It's very important in recent mobile systems because page reclaim/writeback is very critical
> > of application latency. Of course, it could affect normal desktop, too.
> > With it, we can calculate fast-available pages more exactly with NR_FREE_PAGES + NR_ERECLAIMABLE_PAGES,
> > for example. If it's below threshold we defined, we could trigger 1st level notification
> > if we really need prototying low memory notification.
> > 
> 
> If PG_reclaim pages are on this list, then that calculation will not be
> helpful.
> 
> > We may change madvise(DONTNEED) implementation instead of zapping page immediately.
> > If memory pressure doesn't happen, pages are in memory so we can avoid so many minor fault.
> > Of course, we can discard instead of swap out if system memory pressure happens.
> > We might implement it madvise(VOLATILE) instead of DONTNEED, but anyway it's off-topic in this thread.
> > 
> > As a another example, we can implement CFLRU(Clean-First LRU) which reclaims unmapped-clean cache page firstly.
> 
> That alters ageing of pages significantly. It means that workloads that
> are using read heavily will have their pages discarded first.

Hi Mel,

Sorry, I only notice this thread today.  The key issue is that we need to
balance between page cache and mapped file page.  AFAIK, in latest kernel,
the page cache gets a higher priority than mapped file page because it is
easy to be activated and be promoted into active list.  For example,
when the application reads some data twice at a offset,
mark_page_accessed will be called twice, and this page will be
activated.  However, when the application accesses a mapped file page
twice,  it is only in inactive list and access bit is marked.  Until we
try to free pages, this page will be given a chance to keep in inactive
list.  It is unfair for mapped file page.  In old kernel, such as
2.6.18, mapped file page is treated as anonymous page, which has a
higher priority.  Meanwhile, for most developers, they think that there
is no any differences between page cache and mapped file page.  So IMHO
we need to reduce the priority of page cache, or at least we need to
measure access times of mapped file page correctly.  As this thread is
discussed [1], we met this problem in our product system.

1. http://www.spinics.net/lists/linux-mm/msg34642.html

Regards,
Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
