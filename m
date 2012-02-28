Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id C3F006B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 01:04:11 -0500 (EST)
Received: by bkty12 with SMTP id y12so5943613bkt.14
        for <linux-mm@kvack.org>; Mon, 27 Feb 2012 22:04:09 -0800 (PST)
Message-ID: <4F4C6E56.7080508@openvz.org>
Date: Tue, 28 Feb 2012 10:04:06 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 05/21] mm: rename lruvec->lists into lruvec->pages_lru
References: <20120223133728.12988.5432.stgit@zurg>	<20120223135200.12988.92340.stgit@zurg> <20120228092049.4a36b022.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120228092049.4a36b022.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 23 Feb 2012 17:52:00 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> This is much more unique and grep-friendly name.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>
> I worries this kind of change can cause many hunks and make merging difficult..
> But this seems not very destructive..
>
> Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> I have no strong opinions to this naming. How other mm developpers think ?
>
> I personally think making this kind of changes in the head of patch set tend do
> make it difficult to merge full sets of patche series.

This rename allows to easily highlight lru-lists manipulations,
because some of them are in non-trivial places.

>
> Thanks,
> -Kame
>
>> ---
>>   include/linux/mm_inline.h |    2 +-
>>   include/linux/mmzone.h    |    2 +-
>>   mm/memcontrol.c           |    6 +++---
>>   mm/page_alloc.c           |    2 +-
>>   mm/swap.c                 |    4 ++--
>>   mm/vmscan.c               |    6 +++---
>>   6 files changed, 11 insertions(+), 11 deletions(-)
>>
>> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
>> index 227fd3e..8415596 100644
>> --- a/include/linux/mm_inline.h
>> +++ b/include/linux/mm_inline.h
>> @@ -27,7 +27,7 @@ add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
>>   	struct lruvec *lruvec;
>>
>>   	lruvec = mem_cgroup_lru_add_list(zone, page, lru);
>> -	list_add(&page->lru,&lruvec->lists[lru]);
>> +	list_add(&page->lru,&lruvec->pages_lru[lru]);
>>   	__mod_zone_page_state(zone, NR_LRU_BASE + lru, hpage_nr_pages(page));
>>   }
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 3e1f7ff..ddd0fd2 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -160,7 +160,7 @@ static inline int is_unevictable_lru(enum lru_list lru)
>>   }
>>
>>   struct lruvec {
>> -	struct list_head lists[NR_LRU_LISTS];
>> +	struct list_head pages_lru[NR_LRU_LISTS];
>>   };
>>
>>   /* Mask used at gathering information at once (see memcontrol.c) */
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 77f5d48..8f8c7c4 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1050,7 +1050,7 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>>    * the lruvec for the given @zone and the memcg @page is charged to.
>>    *
>>    * The callsite is then responsible for physically linking the page to
>> - * the returned lruvec->lists[@lru].
>> + * the returned lruvec->pages_lru[@lru].
>>    */
>>   struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
>>   				       enum lru_list lru)
>> @@ -3592,7 +3592,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>>
>>   	zone =&NODE_DATA(node)->node_zones[zid];
>>   	mz = mem_cgroup_zoneinfo(memcg, node, zid);
>> -	list =&mz->lruvec.lists[lru];
>> +	list =&mz->lruvec.pages_lru[lru];
>>
>>   	loop = mz->lru_size[lru];
>>   	/* give some margin against EBUSY etc...*/
>> @@ -4716,7 +4716,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>>   	for (zone = 0; zone<  MAX_NR_ZONES; zone++) {
>>   		mz =&pn->zoneinfo[zone];
>>   		for_each_lru(lru)
>> -			INIT_LIST_HEAD(&mz->lruvec.lists[lru]);
>> +			INIT_LIST_HEAD(&mz->lruvec.pages_lru[lru]);
>>   		mz->usage_in_excess = 0;
>>   		mz->on_tree = false;
>>   		mz->memcg = memcg;
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 38f6744..5f19392 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4363,7 +4363,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>>
>>   		zone_pcp_init(zone);
>>   		for_each_lru(lru)
>> -			INIT_LIST_HEAD(&zone->lruvec.lists[lru]);
>> +			INIT_LIST_HEAD(&zone->lruvec.pages_lru[lru]);
>>   		zone->reclaim_stat.recent_rotated[0] = 0;
>>   		zone->reclaim_stat.recent_rotated[1] = 0;
>>   		zone->reclaim_stat.recent_scanned[0] = 0;
>> diff --git a/mm/swap.c b/mm/swap.c
>> index fff1ff7..17993c0 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -238,7 +238,7 @@ static void pagevec_move_tail_fn(struct page *page, void *arg)
>>
>>   		lruvec = mem_cgroup_lru_move_lists(page_zone(page),
>>   						   page, lru, lru);
>> -		list_move_tail(&page->lru,&lruvec->lists[lru]);
>> +		list_move_tail(&page->lru,&lruvec->pages_lru[lru]);
>>   		(*pgmoved)++;
>>   	}
>>   }
>> @@ -482,7 +482,7 @@ static void lru_deactivate_fn(struct page *page, void *arg)
>>   		 * We moves tha page into tail of inactive.
>>   		 */
>>   		lruvec = mem_cgroup_lru_move_lists(zone, page, lru, lru);
>> -		list_move_tail(&page->lru,&lruvec->lists[lru]);
>> +		list_move_tail(&page->lru,&lruvec->pages_lru[lru]);
>>   		__count_vm_event(PGROTATED);
>>   	}
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 8b59cb5..e41ad52 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1164,7 +1164,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>   		lru += LRU_ACTIVE;
>>   	if (file)
>>   		lru += LRU_FILE;
>> -	src =&lruvec->lists[lru];
>> +	src =&lruvec->pages_lru[lru];
>>
>>   	for (scan = 0; scan<  nr_to_scan&&  !list_empty(src); scan++) {
>>   		struct page *page;
>> @@ -1663,7 +1663,7 @@ static void move_active_pages_to_lru(struct zone *zone,
>>   		SetPageLRU(page);
>>
>>   		lruvec = mem_cgroup_lru_add_list(zone, page, lru);
>> -		list_move(&page->lru,&lruvec->lists[lru]);
>> +		list_move(&page->lru,&lruvec->pages_lru[lru]);
>>   		pgmoved += hpage_nr_pages(page);
>>
>>   		if (put_page_testzero(page)) {
>> @@ -3592,7 +3592,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
>>   			__dec_zone_state(zone, NR_UNEVICTABLE);
>>   			lruvec = mem_cgroup_lru_move_lists(zone, page,
>>   						LRU_UNEVICTABLE, lru);
>> -			list_move(&page->lru,&lruvec->lists[lru]);
>> +			list_move(&page->lru,&lruvec->pages_lru[lru]);
>>   			__inc_zone_state(zone, NR_INACTIVE_ANON + lru);
>>   			pgrescued++;
>>   		}
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
