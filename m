Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 617C86B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 03:53:58 -0500 (EST)
Received: by bkwq16 with SMTP id q16so1743031bkw.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 00:53:56 -0800 (PST)
Message-ID: <4F508AA2.4020103@openvz.org>
Date: Fri, 02 Mar 2012 12:53:54 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] mm: rework __isolate_lru_page() file/anon filter
References: <20120229090748.29236.35489.stgit@zurg>	<20120229091547.29236.28230.stgit@zurg>	<20120302141739.b63677ad.kamezawa.hiroyu@jp.fujitsu.com>	<4F505FDF.80003@openvz.org> <20120302171708.6f206bde.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120302171708.6f206bde.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 02 Mar 2012 09:51:27 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> KAMEZAWA Hiroyuki wrote:
>>> On Wed, 29 Feb 2012 13:15:47 +0400
>>> Konstantin Khlebnikov<khlebnikov@openvz.org>   wrote:
>>>
>>>> This patch adds file/anon filter bits into isolate_mode_t,
>>>> this allows to simplify checks in __isolate_lru_page().
>>>>
>>>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>>
>>> Hmm.. I like idea but..
>>>
>>>> ---
>>>>    include/linux/mmzone.h |    4 ++++
>>>>    include/linux/swap.h   |    2 +-
>>>>    mm/compaction.c        |    5 +++--
>>>>    mm/vmscan.c            |   27 +++++++++++++--------------
>>>>    4 files changed, 21 insertions(+), 17 deletions(-)
>>>>
>>>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>>>> index eff4918..2fed935 100644
>>>> --- a/include/linux/mmzone.h
>>>> +++ b/include/linux/mmzone.h
>>>> @@ -193,6 +193,10 @@ struct lruvec {
>>>>    #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x8)
>>>>    /* Isolate for asynchronous migration */
>>>>    #define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x10)
>>>> +/* Isolate swap-backed pages */
>>>> +#define	ISOLATE_ANON		((__force isolate_mode_t)0x20)
>>>> +/* Isolate file-backed pages */
>>>> +#define	ISOLATE_FILE		((__force isolate_mode_t)0x40)
>>>>
>>>>    /* LRU Isolation modes. */
>>>>    typedef unsigned __bitwise__ isolate_mode_t;
>>>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>>>> index ba2c8d7..dc6e6a3 100644
>>>> --- a/include/linux/swap.h
>>>> +++ b/include/linux/swap.h
>>>> @@ -254,7 +254,7 @@ static inline void lru_cache_add_file(struct page *page)
>>>>    /* linux/mm/vmscan.c */
>>>>    extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>>>>    					gfp_t gfp_mask, nodemask_t *mask);
>>>> -extern int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file);
>>>> +extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
>>>>    extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
>>>>    						  gfp_t gfp_mask, bool noswap);
>>>>    extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>>> index 74a8c82..cc054f7 100644
>>>> --- a/mm/compaction.c
>>>> +++ b/mm/compaction.c
>>>> @@ -261,7 +261,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>>>>    	unsigned long last_pageblock_nr = 0, pageblock_nr;
>>>>    	unsigned long nr_scanned = 0, nr_isolated = 0;
>>>>    	struct list_head *migratelist =&cc->migratepages;
>>>> -	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
>>>> +	isolate_mode_t mode = ISOLATE_ACTIVE | ISOLATE_INACTIVE |
>>>> +			      ISOLATE_FILE | ISOLATE_ANON;
>>>>
>>>>    	/* Do not scan outside zone boundaries */
>>>>    	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
>>>> @@ -375,7 +376,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>>>>    			mode |= ISOLATE_ASYNC_MIGRATE;
>>>>
>>>>    		/* Try isolate the page */
>>>> -		if (__isolate_lru_page(page, mode, 0) != 0)
>>>> +		if (__isolate_lru_page(page, mode) != 0)
>>>>    			continue;
>>>>
>>>>    		VM_BUG_ON(PageTransCompound(page));
>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>> index af6cfe7..1b70338 100644
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -1029,27 +1029,18 @@ keep_lumpy:
>>>>     *
>>>>     * returns 0 on success, -ve errno on failure.
>>>>     */
>>>> -int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
>>>> +int __isolate_lru_page(struct page *page, isolate_mode_t mode)
>>>>    {
>>>> -	bool all_lru_mode;
>>>>    	int ret = -EINVAL;
>>>>
>>>>    	/* Only take pages on the LRU. */
>>>>    	if (!PageLRU(page))
>>>>    		return ret;
>>>>
>>>> -	all_lru_mode = (mode&   (ISOLATE_ACTIVE|ISOLATE_INACTIVE)) ==
>>>> -		(ISOLATE_ACTIVE|ISOLATE_INACTIVE);
>>>> -
>>>> -	/*
>>>> -	 * When checking the active state, we need to be sure we are
>>>> -	 * dealing with comparible boolean values.  Take the logical not
>>>> -	 * of each.
>>>> -	 */
>>>> -	if (!all_lru_mode&&   !PageActive(page) != !(mode&   ISOLATE_ACTIVE))
>>>> +	if (!(mode&   (PageActive(page) ? ISOLATE_ACTIVE : ISOLATE_INACTIVE)))
>>>>    		return ret;
>>>
>>> Isn't this complicated ?
>>
>> But it doesn't blows my mind as old code does =)
>>
>> Maybe someone can propose more clear variant?
>>
>
> switch (mode&  (ISOLATE_ACTIVE | ISOLATE_INACTIVE)) {
> 	case ISOLATE_ACTIVE :
> 		if (!PageActive(page))
> 			return ret;
> 	case ISOLATE_INACTIVE :
> 		if (PageActive(page))
> 			return ret;
> 	default:
> 		break;
> 	}
> }
>
> ?

Thanks. It is more optimal and looks more simple. but you lost one "break"

>
> Thanks,
> -Kame
>
>>>
>>>>
>>>> -	if (!all_lru_mode&&   !!page_is_file_cache(page) != file)
>>>> +	if (!(mode&   (page_is_file_cache(page) ? ISOLATE_FILE : ISOLATE_ANON)))
>>>>    		return ret;
>>>>
>>>>    	/*
>>>
>>> ditto.
>>>
>>> Where is simple  ?
>>>
>>> Thanks,
>>> -Kame
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
>> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
