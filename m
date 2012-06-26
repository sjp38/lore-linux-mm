Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 920F56B0254
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 20:26:57 -0400 (EDT)
Message-ID: <4FE901D1.9090400@kernel.org>
Date: Tue, 26 Jun 2012 09:26:57 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: RFC:  Easy-Reclaimable LRU list
References: <4FE012CD.6010605@kernel.org> <20120625102435.GD8271@suse.de>
In-Reply-To: <20120625102435.GD8271@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Pekka Enberg <penberg@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>

On 06/25/2012 07:24 PM, Mel Gorman wrote:

> On Tue, Jun 19, 2012 at 02:49:01PM +0900, Minchan Kim wrote:
>> Hi everybody!
>>
>> Recently, there are some efforts to handle system memory pressure.
>>
>> 1) low memory notification - [1]
>> 2) fallocate(VOLATILE) - [2]
>> 3) fadvise(NOREUSE) - [3]
>>
>> For them, I would like to add new LRU list, aka "Ereclaimable" which is opposite of "unevictable".
>> Reclaimable LRU list includes _easy_ reclaimable pages.
>> For example, easy reclaimable pages are following as. 
>>
>> 1. invalidated but remained LRU list.
>> 2. pageout pages for reclaim(PG_reclaim pages)
>> 3. fadvise(NOREUSE)
>> 4. fallocate(VOLATILE)
>>
>> Their pages shouldn't stir normal LRU list and compaction might not migrate them, even.
> 
> Why would compaction not migrate them? We might still want to migrate
> NORESUSE or VOLATILE pages.


It might.

> 
>> Reclaimer can reclaim Ereclaimable pages before normal lru list and will avoid unnecessary
>> swapout in anon pages in easy-reclaimable LRU list.
>> It also can make admin measure how many we have available pages at the moment without latency.
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


I should have written more clear.
I mean following as

end_page_writeback(struct page *)
{
	if (PageReclaim(page))
		move_ereclaim_lru_list(page);
}

So Ereclaimable LRU list can have a discardable pages.
> 

> This separate list does not exist today because it required a page bit to
> implement and I did not want it to be a 64-bit only feature. You will
> probably hit the same problem.


True. Others already pointed it out in this thread.
And I post a idea.

Copy/Paste

"
Maybe and it could be a serious problem on 32 bit machine.
I didn't dive into that but I guess we can reuse PG_reclaim bit.
PG_reclaim is always used by with !PageActive and Ereclaimable LRU list doesn't have 
active LRU list. so we can change following as

- #define PG_reclaim
+ #define PG_Ereclaim

SetPageReclaim(page)
{
	page->flags |= (PG_Ereclaim|PG_active);
}

TestPageReclaim(page)
{
	if (((page->flags && PG_Ereclaim|PG_active)) == (PG_Ereclaim|PG_active)) 
		return true;
	return false;
}

SetPageEreclaim(page)
{
	page->flags |= PG_Ereclaim;
}
"

> 
> The setting of the page bit is also going to be a problem but you may be
> able to lazily move pages to the EReclaimable list in the same way
> unevictable pages are handled.


First of all, I don't consider lazy moving like unevictable.
We can move VOLATILE/NOREUSE pages into EReclaiabmle LRU list in backgroud by using workqueue.
Please tell me the scenario if we consider lazy moving.

> 
>> It's very important in recent mobile systems because page reclaim/writeback is very critical
>> of application latency. Of course, it could affect normal desktop, too.
>> With it, we can calculate fast-available pages more exactly with NR_FREE_PAGES + NR_ERECLAIMABLE_PAGES,
>> for example. If it's below threshold we defined, we could trigger 1st level notification
>> if we really need prototying low memory notification.
>>
> 
> If PG_reclaim pages are on this list, then that calculation will not be
> helpful.


PG_reclaim pages would be not in Ereclaimable LRU list like I mentioned above.

> 
>> We may change madvise(DONTNEED) implementation instead of zapping page immediately.
>> If memory pressure doesn't happen, pages are in memory so we can avoid so many minor fault.
>> Of course, we can discard instead of swap out if system memory pressure happens.
>> We might implement it madvise(VOLATILE) instead of DONTNEED, but anyway it's off-topic in this thread.
>>
>> As a another example, we can implement CFLRU(Clean-First LRU) which reclaims unmapped-clean cache page firstly.
> 
> That alters ageing of pages significantly. It means that workloads that
> are using read heavily will have their pages discarded first.\

> 

>> The rationale is that in non-rotation device, read/write cost is much asynchronous.
> 
> While this is true that does not justify throwing away unmapped clean
> page cache first every time.


That's true. That is workload I have a concern.
We need balancing unmmapped/mapped pages so sometime, some mapped pages would be moved into
unevictable LRU list with unmapping all of pte. I believe It could mitigate the problem,
but not perfect, I admit. Maybe we need some knob for admin to tune it.
Anyway, it's a big concern for me and one of careful test for regression.

> 
>> Read is very fast while write is very slow so it would be a gain while we can avoid writeback of dirty pages
>> if possible although we need several reads. It can be implemented easily with Ereclaimable pages, too.
>>
>> Anyway, it's just a brain-storming phase and never implemented yet but decide posting before it's too late.
>> I hope listen others opinion before get into the code.
>>
> 
> Care is needed. I think you'll only be able to use this list for
> NORESUSE, VOLATILE and invalidated pages. If you add PG_reclaim it not be
> "easily-reclaimable" and if you add clean unmapped pages then there will
> be regressions in workloads that are read-intensive.
> 


Thanks for the feedback, Mel.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
