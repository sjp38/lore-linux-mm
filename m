Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 3424F6B0062
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 03:31:19 -0400 (EDT)
Received: by wibhq4 with SMTP id hq4so1891958wib.8
        for <linux-mm@kvack.org>; Fri, 07 Sep 2012 00:31:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAH9JG2VOoA30q+3sjC4UbNFNv2Vn9KnPNNXRb+kYMKWXKHbPew@mail.gmail.com>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
	<1346832673-12512-2-git-send-email-minchan@kernel.org>
	<20120905105611.GI11266@suse.de>
	<20120906053112.GA16231@bbox>
	<20120906082935.GN11266@suse.de>
	<20120906090325.GO11266@suse.de>
	<20120907022434.GG16231@bbox>
	<CAH9JG2VOoA30q+3sjC4UbNFNv2Vn9KnPNNXRb+kYMKWXKHbPew@mail.gmail.com>
Date: Fri, 7 Sep 2012 16:31:17 +0900
Message-ID: <CAH9JG2XozEBOah1BsaowbU=j3SE35wZVXkDjZhK7GLUzcTbfEA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: support MIGRATE_DISCARD
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On 9/7/12, Kyungmin Park <kmpark@infradead.org> wrote:
> Hi Minchan,
>
> I tested Mel patch again with ClearPageActive(page). but after some
> testing, it's stall and can't return from
> reclaim_clean_pages_from_list(&cc.migratepages).
>
> Maybe it's related with unmap feature from yours?
> stall is not happened from your codes until now.
>
> I'll test it more and report any issue if happened.
Updated. it's hang also. there are other issues.
>
> Thank you,
> Kyungmin Park
>
> On 9/7/12, Minchan Kim <minchan@kernel.org> wrote:
>> On Thu, Sep 06, 2012 at 10:03:25AM +0100, Mel Gorman wrote:
>>> On Thu, Sep 06, 2012 at 09:29:35AM +0100, Mel Gorman wrote:
>>> > On Thu, Sep 06, 2012 at 02:31:12PM +0900, Minchan Kim wrote:
>>> > > Hi Mel,
>>> > >
>>> > > On Wed, Sep 05, 2012 at 11:56:11AM +0100, Mel Gorman wrote:
>>> > > > On Wed, Sep 05, 2012 at 05:11:13PM +0900, Minchan Kim wrote:
>>> > > > > This patch introudes MIGRATE_DISCARD mode in migration.
>>> > > > > It drops *clean cache pages* instead of migration so that
>>> > > > > migration latency could be reduced by avoiding (memcpy + page
>>> > > > > remapping).
>>> > > > > It's useful for CMA because latency of migration is very
>>> > > > > important
>>> > > > > rather
>>> > > > > than eviction of background processes's workingset. In addition,
>>> > > > > it needs
>>> > > > > less free pages for migration targets so it could avoid memory
>>> > > > > reclaiming
>>> > > > > to get free pages, which is another factor increase latency.
>>> > > > >
>>> > > >
>>> > > > Bah, this was released while I was reviewing the older version. I
>>> > > > did
>>> > > > not read this one as closely but I see the enum problems have gone
>>> > > > away
>>> > > > at least. I'd still prefer if CMA had an additional helper to
>>> > > > discard
>>> > > > some pages with shrink_page_list() and migrate the remaining pages
>>> > > > with
>>> > > > migrate_pages(). That would remove the need to add a
>>> > > > MIGRATE_DISCARD
>>> > > > migrate mode at all.
>>> > >
>>> > > I am not convinced with your point. What's the benefit on separating
>>> > > reclaim and migration? For just removing MIGRATE_DISCARD mode?
>>> >
>>> > Maintainability. There are reclaim functions and there are migration
>>> > functions. Your patch takes migrate_pages() and makes it partially a
>>> > reclaim function mixing up the responsibilities of migrate.c and
>>> > vmscan.c.
>>> >
>>> > > I don't think it's not bad because my implementation is very
>>> > > simple(maybe
>>> > > it's much simpler than separating reclaim and migration) and
>>> > > could be used by others like memory-hotplug in future.
>>> >
>>> > They could also have used the helper function from CMA that takes a
>>> > list
>>> > of pages, reclaims some and migrates other.
>>> >
>>>
>>> I also do not accept that your approach is inherently simpler than what
>>> I
>>> proposed to you. This is not tested at all but it should be functionally
>>> similar to both your patches except that it keeps the responsibility for
>>> reclaim in vmscan.c
>>>
>>> Your diffstats are
>>>
>>> 8 files changed, 39 insertions(+), 36 deletions(-)
>>> 3 files changed, 46 insertions(+), 4 deletions(-)
>>>
>>> Mine is
>>>
>>>  3 files changed, 32 insertions(+), 5 deletions(-)
>>>
>>> Fewer files changed and fewer lines inserted.
>>>
>>> ---8<---
>>> mm: cma: Discard clean pages during contiguous allocation instead of
>>> migration
>>>
>>> This patch drops clean cache pages instead of migration during
>>> alloc_contig_range() to minimise allocation latency by reducing the
>>> amount
>>> of migration is necessary. It's useful for CMA because latency of
>>> migration
>>> is more important than evicting the background processes working set.
>>>
>>> Prototype-not-signed-off-but-feel-free-to-pick-up-and-test
>>> ---
>>>  mm/internal.h   |    1 +
>>>  mm/page_alloc.c |    2 ++
>>>  mm/vmscan.c     |   34 +++++++++++++++++++++++++++++-----
>>>  3 files changed, 32 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/mm/internal.h b/mm/internal.h
>>> index b8c91b3..6d4bdf9 100644
>>> --- a/mm/internal.h
>>> +++ b/mm/internal.h
>>> @@ -356,3 +356,4 @@ extern unsigned long vm_mmap_pgoff(struct file *,
>>> unsigned long,
>>>          unsigned long, unsigned long);
>>>
>>>  extern void set_pageblock_order(void);
>>> +unsigned long reclaim_clean_pages_from_list(struct list_head
>>> *page_list);
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index c66fb87..977bdb2 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -5670,6 +5670,8 @@ static int __alloc_contig_migrate_range(unsigned
>>> long start, unsigned long end)
>>>  			break;
>>>  		}
>>>
>>> +		reclaim_clean_pages_from_list(&cc.migratepages);
>>> +
>>>  		ret = migrate_pages(&cc.migratepages,
>>>  				    __alloc_contig_migrate_alloc,
>>>  				    0, false, MIGRATE_SYNC);
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index 8d01243..ccf7bc2 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -703,7 +703,7 @@ static unsigned long shrink_page_list(struct
>>> list_head
>>> *page_list,
>>>  			goto keep;
>>>
>>>  		VM_BUG_ON(PageActive(page));
>>> -		VM_BUG_ON(page_zone(page) != zone);
>>> +		VM_BUG_ON(zone && page_zone(page) != zone);
>>>
>>>  		sc->nr_scanned++;
>>>
>>> @@ -817,7 +817,9 @@ static unsigned long shrink_page_list(struct
>>> list_head
>>> *page_list,
>>>  				 * except we already have the page isolated
>>>  				 * and know it's dirty
>>>  				 */
>>> -				inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
>>> +				if (zone)
>>> +					inc_zone_page_state(page,
>>> +							NR_VMSCAN_IMMEDIATE);
>>>  				SetPageReclaim(page);
>>>
>>>  				goto keep_locked;
>>> @@ -947,7 +949,7 @@ keep:
>>>  	 * back off and wait for congestion to clear because further reclaim
>>>  	 * will encounter the same problem
>>>  	 */
>>> -	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
>>> +	if (zone && nr_dirty && nr_dirty == nr_congested &&
>>> global_reclaim(sc))
>>>  		zone_set_flag(zone, ZONE_CONGESTED);
>>>
>>>  	free_hot_cold_page_list(&free_pages, 1);
>>> @@ -955,11 +957,33 @@ keep:
>>>  	list_splice(&ret_pages, page_list);
>>>  	count_vm_events(PGACTIVATE, pgactivate);
>>>  	mem_cgroup_uncharge_end();
>>> -	*ret_nr_dirty += nr_dirty;
>>> -	*ret_nr_writeback += nr_writeback;
>>> +	if (ret_nr_dirty)
>>> +		*ret_nr_dirty += nr_dirty;
>>> +	if (ret_nr_writeback)
>>> +		*ret_nr_writeback += nr_writeback;
>>>  	return nr_reclaimed;
>>>  }
>>>
>>> +unsigned long reclaim_clean_pages_from_list(struct list_head
>>> *page_list)
>>> +{
>>> +	struct scan_control sc = {
>>> +		.gfp_mask = GFP_KERNEL,
>>> +		.priority = DEF_PRIORITY,
>>> +	};
>>> +	unsigned long ret;
>>> +	struct page *page, *next;
>>> +	LIST_HEAD(clean_pages);
>>> +
>>> +	list_for_each_entry_safe(page, next, page_list, lru) {
>>> +		if (page_is_file_cache(page) && !PageDirty(page))
>>> +			list_move(&page->lru, &clean_pages);
>>> +	}
>>> +
>>> +	ret = shrink_page_list(&clean_pages, NULL, &sc, NULL, NULL);
>>> +	list_splice(&clean_pages, page_list);
>>> +	return ret;
>>> +}
>>> +
>>
>> It's different with my point.
>> My intention is to free mapped clean pages as well as not-mapped's one.
>>
>> How about this?
>>
>> From 0f6986e943e55929b4d7b0220a1c24a6bae1a24d Mon Sep 17 00:00:00 2001
>> From: Minchan Kim <minchan@kernel.org>
>> Date: Fri, 7 Sep 2012 11:20:48 +0900
>> Subject: [PATCH] mm: cma: Discard clean pages during contiguous
>> allocation
>>  instead of migration
>>
>> This patch introudes MIGRATE_DISCARD mode in migration.
>> It drops *clean cache pages* instead of migration so that
>> migration latency could be reduced by avoiding (memcpy + page remapping).
>> It's useful for CMA because latency of migration is very important rather
>> than eviction of background processes's workingset. In addition, it needs
>> less free pages for migration targets so it could avoid memory reclaiming
>> to get free pages, which is another factor increase latency.
>>
>> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
>> Cc: Michal Nazarewicz <mina86@mina86.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>  mm/internal.h   |    2 ++
>>  mm/page_alloc.c |    2 ++
>>  mm/vmscan.c     |   42 ++++++++++++++++++++++++++++++++++++------
>>  3 files changed, 40 insertions(+), 6 deletions(-)
>>
>> diff --git a/mm/internal.h b/mm/internal.h
>> index 3314f79..be09a7e 100644
>> --- a/mm/internal.h
>> +++ b/mm/internal.h
>> @@ -355,3 +355,5 @@ extern unsigned long vm_mmap_pgoff(struct file *,
>> unsigned long,
>>          unsigned long, unsigned long);
>>
>>  extern void set_pageblock_order(void);
>> +unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>> +				struct list_head *page_list);
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index ba3100a..bf35e59 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5668,6 +5668,8 @@ static int __alloc_contig_migrate_range(unsigned
>> long
>> start, unsigned long end)
>>  			break;
>>  		}
>>
>> +		reclaim_clean_pages_from_list(&cc.migratepages, cc.zone);
>> +
>>  		ret = migrate_pages(&cc.migratepages,
>>  				    __alloc_contig_migrate_alloc,
>>  				    0, false, MIGRATE_SYNC);
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 8d01243..525355e 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -674,8 +674,10 @@ static enum page_references
>> page_check_references(struct page *page,
>>  static unsigned long shrink_page_list(struct list_head *page_list,
>>  				      struct zone *zone,
>>  				      struct scan_control *sc,
>> +				      enum ttu_flags ttu_flags,
>>  				      unsigned long *ret_nr_dirty,
>> -				      unsigned long *ret_nr_writeback)
>> +				      unsigned long *ret_nr_writeback,
>> +				      bool force_reclaim)
>>  {
>>  	LIST_HEAD(ret_pages);
>>  	LIST_HEAD(free_pages);
>> @@ -689,10 +691,10 @@ static unsigned long shrink_page_list(struct
>> list_head
>> *page_list,
>>
>>  	mem_cgroup_uncharge_start();
>>  	while (!list_empty(page_list)) {
>> -		enum page_references references;
>>  		struct address_space *mapping;
>>  		struct page *page;
>>  		int may_enter_fs;
>> +		enum page_references references = PAGEREF_RECLAIM;
>>
>>  		cond_resched();
>>
>> @@ -758,7 +760,9 @@ static unsigned long shrink_page_list(struct
>> list_head
>> *page_list,
>>  			wait_on_page_writeback(page);
>>  		}
>>
>> -		references = page_check_references(page, sc);
>> +		if (!force_reclaim)
>> +			references = page_check_references(page, sc);
>> +
>>  		switch (references) {
>>  		case PAGEREF_ACTIVATE:
>>  			goto activate_locked;
>> @@ -788,7 +792,7 @@ static unsigned long shrink_page_list(struct
>> list_head
>> *page_list,
>>  		 * processes. Try to unmap it here.
>>  		 */
>>  		if (page_mapped(page) && mapping) {
>> -			switch (try_to_unmap(page, TTU_UNMAP)) {
>> +			switch (try_to_unmap(page, ttu_flags)) {
>>  			case SWAP_FAIL:
>>  				goto activate_locked;
>>  			case SWAP_AGAIN:
>> @@ -960,6 +964,32 @@ keep:
>>  	return nr_reclaimed;
>>  }
>>
>> +unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>> +					struct list_head *page_list)
>> +{
>> +	struct scan_control sc = {
>> +		.gfp_mask = GFP_KERNEL,
>> +		.priority = DEF_PRIORITY,
>> +		.may_unmap = 1,
>> +	};
>> +	unsigned long ret, dummy1, dummy2;
>> +	struct page *page, *next;
>> +	LIST_HEAD(clean_pages);
>> +
>> +	list_for_each_entry_safe(page, next, page_list, lru) {
>> +		if (page_is_file_cache(page) && !PageDirty(page)) {
>> +			ClearPageActive(page);
>> +			list_move(&page->lru, &clean_pages);
>> +		}
>> +	}
>> +
>> +	ret = shrink_page_list(&clean_pages, zone, &sc,
>> +				TTU_UNMAP|TTU_IGNORE_ACCESS,
>> +				&dummy1, &dummy2, true);
>> +	list_splice(&clean_pages, page_list);
>> +	return ret;
>> +}
>> +
>>  /*
>>   * Attempt to remove the specified page from its LRU.  Only take this
>> page
>>   * if it is of the appropriate PageActive status.  Pages which are being
>> @@ -1278,8 +1308,8 @@ shrink_inactive_list(unsigned long nr_to_scan,
>> struct
>> lruvec *lruvec,
>>  	if (nr_taken == 0)
>>  		return 0;
>>
>> -	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
>> -						&nr_dirty, &nr_writeback);
>> +	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
>> +					&nr_dirty, &nr_writeback, false);
>>
>>  	spin_lock_irq(&zone->lru_lock);
>>
>> --
>> 1.7.9.5
>>
>> --
>> Kind regards,
>> Minchan Kim
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
