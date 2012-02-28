Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id D05856B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 01:16:18 -0500 (EST)
Received: by bkty12 with SMTP id y12so5950462bkt.14
        for <linux-mm@kvack.org>; Mon, 27 Feb 2012 22:16:17 -0800 (PST)
Message-ID: <4F4C712E.5040002@openvz.org>
Date: Tue, 28 Feb 2012 10:16:14 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 07/21] mm: add lruvec->pages_count
References: <20120223133728.12988.5432.stgit@zurg>	<20120223135208.12988.74252.stgit@zurg> <20120228093529.eda35cdc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120228093529.eda35cdc.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 23 Feb 2012 17:52:08 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> Move lru pages counter from mem_cgroup_per_zone->count[] to lruvec->pages_count[]
>>
>> Account pages in all lruvecs, incuding root,
>> this isn't a huge overhead, but it greatly simplifies all code.
>>
>> Redundant page_lruvec() calls will be optimized in further patches.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>
> Hmm, I like this but..a question below.
>
>> ---
>>   include/linux/memcontrol.h |   29 --------------
>>   include/linux/mm_inline.h  |   15 +++++--
>>   include/linux/mmzone.h     |    1
>>   mm/memcontrol.c            |   93 +-------------------------------------------
>>   mm/swap.c                  |    7 +--
>>   mm/vmscan.c                |   25 +++++++++---
>>   6 files changed, 34 insertions(+), 136 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 4822d53..b9d555b 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -63,12 +63,6 @@ extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>>   					gfp_t gfp_mask);
>>
>>   struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
>> -struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
>> -				       enum lru_list);
>> -void mem_cgroup_lru_del_list(struct page *, enum lru_list);
>> -void mem_cgroup_lru_del(struct page *);
>> -struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,
>> -					 enum lru_list, enum lru_list);
>>
>>   /* For coalescing uncharge for reducing memcg' overhead*/
>>   extern void mem_cgroup_uncharge_start(void);
>> @@ -212,29 +206,6 @@ static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>>   	return&zone->lruvec;
>>   }
>>
>> -static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,
>> -						     struct page *page,
>> -						     enum lru_list lru)
>> -{
>> -	return&zone->lruvec;
>> -}
>> -
>> -static inline void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
>> -{
>> -}
>> -
>> -static inline void mem_cgroup_lru_del(struct page *page)
>> -{
>> -}
>> -
>> -static inline struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
>> -						       struct page *page,
>> -						       enum lru_list from,
>> -						       enum lru_list to)
>> -{
>> -	return&zone->lruvec;
>> -}
>> -
>>   static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>>   {
>>   	return NULL;
>> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
>> index 8415596..daa3d15 100644
>> --- a/include/linux/mm_inline.h
>> +++ b/include/linux/mm_inline.h
>> @@ -24,19 +24,24 @@ static inline int page_is_file_cache(struct page *page)
>>   static inline void
>>   add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
>>   {
>> -	struct lruvec *lruvec;
>> +	struct lruvec *lruvec = page_lruvec(page);
>> +	int numpages = hpage_nr_pages(page);
>>
>> -	lruvec = mem_cgroup_lru_add_list(zone, page, lru);
>>   	list_add(&page->lru,&lruvec->pages_lru[lru]);
>> -	__mod_zone_page_state(zone, NR_LRU_BASE + lru, hpage_nr_pages(page));
>> +	lruvec->pages_count[lru] += numpages;
>> +	__mod_zone_page_state(zone, NR_LRU_BASE + lru, numpages);
>>   }
>>
>>   static inline void
>>   del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
>>   {
>> -	mem_cgroup_lru_del_list(page, lru);
>> +	struct lruvec *lruvec = page_lruvec(page);
>> +	int numpages = hpage_nr_pages(page);
>> +
>>   	list_del(&page->lru);
>> -	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -hpage_nr_pages(page));
>> +	lruvec->pages_count[lru] -= numpages;
>> +	VM_BUG_ON((long)lruvec->pages_count[lru]<  0);
>> +	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -numpages);
>>   }
>>
>>   /**
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index be8873a..69b0f31 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -298,6 +298,7 @@ struct zone_reclaim_stat {
>>
>>   struct lruvec {
>>   	struct list_head	pages_lru[NR_LRU_LISTS];
>> +	unsigned long		pages_count[NR_LRU_LISTS];
>
> In this time, you don't put the objects under #ifdef...why ?

It will make the code much uglier and does not speed up it at all.

>
> How do you handle duplication "the number of pages in LRU" of zone->vm_stat and this ?

I don't think this is totally bad, vmstat usually has per-cpu drift, these numbers will be exact.

>
> Thanks,
> -Kame
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
