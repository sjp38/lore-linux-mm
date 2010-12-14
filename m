Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 45D476B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 05:18:16 -0500 (EST)
Received: by fxm9 with SMTP id 9so458612fxm.31
        for <linux-mm@kvack.org>; Tue, 14 Dec 2010 02:18:13 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCHv7 06/10] mm: MIGRATE_CMA migration type added
References: <cover.1292004520.git.m.nazarewicz@samsung.com>
	<25250c1c5fb3ffd0c33ce744965bc8e958220f58.1292004520.git.m.nazarewicz@samsung.com>
	<20101214101508.4199a3dd.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 14 Dec 2010 11:18:09 +0100
In-Reply-To: <20101214101508.4199a3dd.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Tue, 14 Dec 2010 10:15:08 +0900")
Message-ID: <874oaghd3y.fsf@erwin.mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Nazarewicz <m.nazarewicz@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, BooJin Kim <boojin.kim@samsung.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>
List-ID: <linux-mm.kvack.org>

> On Mon, 13 Dec 2010 12:26:47 +0100
> Michal Nazarewicz <m.nazarewicz@samsung.com> wrote:
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> @@ -35,13 +35,24 @@
>>   */
>>  #define PAGE_ALLOC_COSTLY_ORDER 3
>>  
>> -#define MIGRATE_UNMOVABLE     0
>> -#define MIGRATE_RECLAIMABLE   1
>> -#define MIGRATE_MOVABLE       2
>> -#define MIGRATE_PCPTYPES      3 /* the number of types on the pcp lists */
>> -#define MIGRATE_RESERVE       3
>> -#define MIGRATE_ISOLATE       4 /* can't allocate from here */
>> -#define MIGRATE_TYPES         5
>> +enum {
>> +	MIGRATE_UNMOVABLE,
>> +	MIGRATE_RECLAIMABLE,
>> +	MIGRATE_MOVABLE,
>> +	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
>> +	MIGRATE_RESERVE = MIGRATE_PCPTYPES,
>> +	MIGRATE_ISOLATE,	/* can't allocate from here */
>> +#ifdef CONFIG_MIGRATE_CMA
>> +	MIGRATE_CMA,		/* only movable */
>> +#endif
>> +	MIGRATE_TYPES
>> +};
>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> I personaly would like to put MIGRATE_ISOLATE to be bottom of enum
> because it means _not_for_allocation.

Will change.  I didn't want to change the value of MIGRATE_ISOLATE in
fear of breaking something but hopefully no one depends on
MIGRATE_ISOLATE's value. 

>> diff --git a/mm/compaction.c b/mm/compaction.c
>> @@ -824,11 +848,15 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>>   * This array describes the order lists are fallen back to when
>>   * the free lists for the desirable migrate type are depleted
>>   */
>> -static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
>> +static int fallbacks[MIGRATE_TYPES][4] = {
>>  	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
>>  	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
>> +#ifdef CONFIG_MIGRATE_CMA
>> +	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_CMA    , MIGRATE_RESERVE },
>> +#else
>>  	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
>> -	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
>> +#endif
>> +	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
>>  };
>>  
>>  /*
>> @@ -924,12 +952,12 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>>  	/* Find the largest possible block of pages in the other list */
>>  	for (current_order = MAX_ORDER-1; current_order >= order;
>>  						--current_order) {
>> -		for (i = 0; i < MIGRATE_TYPES - 1; i++) {
>> +		for (i = 0; i < ARRAY_SIZE(fallbacks[0]); i++) {

> Why fallbacks[0] ? and why do you need to change this ?

I've changed the dimensions of fallbacks matrix, in particular second
dimension from MIGRATE_TYPE - 1 to 4 so this place needed to be changed
as well.  Now, I think changing to ARRAY_SIZE() is just the safest
option available.  This is actually just a minor optimisation.

>>  			migratetype = fallbacks[start_migratetype][i];
>>  
>>  			/* MIGRATE_RESERVE handled later if necessary */
>>  			if (migratetype == MIGRATE_RESERVE)
>> -				continue;
>> +				break;
>>  

> Isn't this change enough for your purpose ?

This is mostly just an optimisation really.  I'm not sure what you think
is my purpose here. ;)  It does fix an this issue of some of the
fallback[*] arrays having MIGRATETYPE_UNMOVABLE at the end.

>> @@ -1042,7 +1083,12 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>>  			list_add(&page->lru, list);
>>  		else
>>  			list_add_tail(&page->lru, list);
>> -		set_page_private(page, migratetype);
>> +#ifdef CONFIG_MIGRATE_CMA
>> +		if (is_pageblock_cma(page))
>> +			set_page_private(page, MIGRATE_CMA);
>> +		else
>> +#endif
>> +			set_page_private(page, migratetype);

> Hmm, doesn't this meet your changes which makes MIGRATE_CMA >
> MIGRATE_PCPLIST ?  And I think putting mixture of pages marked of
> MIGRATE_TYPE onto a pcplist is ugly.

You mean that pcplist page is on can disagree with page_private()?
I didn't think this was such a big deal honestly.  Unless MIGRATE_CMA <
MIGRATE_PCPTYPES, a special case is needed either here or in
free_pcppages_bulk(), so I think this comes down to whether to make
MIGRATE_CAM < MIGRATE_PCPTYPES for which see below.

>> @@ -1181,9 +1227,16 @@ void free_hot_cold_page(struct page *page, int cold)
>>  	 * offlined but treat RESERVE as movable pages so we can get those
>>  	 * areas back if necessary. Otherwise, we may have to free
>>  	 * excessively into the page allocator
>> +	 *
>> +	 * Still, do not change migration type of MIGRATE_CMA pages (if
>> +	 * they'd be recorded as MIGRATE_MOVABLE an unmovable page could
>> +	 * be allocated from MIGRATE_CMA block and we don't want to allow
>> +	 * that).  In this respect, treat MIGRATE_CMA like
>> +	 * MIGRATE_ISOLATE.
>>  	 */
>>  	if (migratetype >= MIGRATE_PCPTYPES) {
>> -		if (unlikely(migratetype == MIGRATE_ISOLATE)) {
>> +		if (unlikely(migratetype == MIGRATE_ISOLATE
>> +			  || is_migrate_cma(migratetype))) {
>>  			free_one_page(zone, page, 0, migratetype);
>>  			goto out;
>>  		}

> Doesn't this add *BAD* performance impact for usual use of pages
> marked as MIGRATE_CMA ? IIUC, All pcp pages must be _drained_ at page
> migration after making migrate_type as ISOLATED. So, this change
> should be unnecessary.

Come to think of it, it would appear that you are right.  I'll remove
this change.

> BTW, How about changing MIGRATE_CMA < MIGRATE_PCPTYPES ? and allow to
> have it's own pcp list ?
>
> I think
> ==
>  again:
>          if (likely(order == 0)) {
>                  struct per_cpu_pages *pcp;
>                  struct list_head *list; 
>  
>                  local_irq_save(flags);
>                  pcp = &this_cpu_ptr(zone->pageset)->pcp;
>                  list = &pcp->lists[migratetype];
>                  if (list_empty(list)) {
>                          pcp->count += rmqueue_bulk(zone, 0,
>                                          pcp->batch, list,
>                                          migratetype, cold);
>                          if (unlikely(list_empty(list))) {
> +				 if (migrate_type == MIGRATE_MOVABLE) { /*allow extra fallback*/
> +					migrate_type == MIGRATE_CMA
> +					goto again;

(This unbalances local_irq_save but that's just a minor note.)

> +			 	}
> +			 }
>                                  goto failed;
>                  }
>
>                 if (cold)
>                         page = list_entry(list->prev, struct page, lru);
>                 else
>                         page = list_entry(list->next, struct page, lru);
>
>                 list_del(&page->lru);
>                 pcp->count--;
> ==
> Will work enough as a fallback path which allows to allocate a memory
> from CMA area if there aren't enough free pages. (and makes FALLBACK
> type as)
>
> fallbacks[MIGRATE_CMA] = {?????},
>
> for no fallbacks.

Yes, I think that would work.  I didn't want to create a new pcp list
especially since in most respects it behaves just like MIGRATE_MOVABLE.
Moreover, with MIGRATE_MOVABLE and MIGRATE_CMA sharing the same pcp list
the above additional fallback path is not necessary and instead the
already existing __rmqueue_fallback() path can be used.

>> @@ -1272,7 +1325,8 @@ int split_free_page(struct page *page)
>>  	if (order >= pageblock_order - 1) {
>>  		struct page *endpage = page + (1 << order) - 1;
>>  		for (; page < endpage; page += pageblock_nr_pages)
>> -			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>> +			if (!is_pageblock_cma(page))
>> +				set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>>  	}
>>  
>>  	return 1 << order;
>> @@ -5366,6 +5420,15 @@ int set_migratetype_isolate(struct page *page)
>>  	zone_idx = zone_idx(zone);
>>  
>>  	spin_lock_irqsave(&zone->lock, flags);
>> +	/*
>> +	 * Treat MIGRATE_CMA specially since it may contain immobile
>> +	 * CMA pages -- that's fine.  CMA is likely going to touch
>> +	 * only the mobile pages in the pageblokc.
>> +	 */
>> +	if (is_pageblock_cma(page)) {
>> +		ret = 0;
>> +		goto out;
>> +	}
>>  
>>  	pfn = page_to_pfn(page);
>>  	arg.start_pfn = pfn;

> Hmm, I'm not sure why you dont' have any change in __free_one_page()
> which overwrite pageblock type. Is MIGRATE_CMA range is aligned to
> MAX_ORDER ? If so, please mention about it in patch description or
> comment because of the patch order.

Yep, you're correct.  For MIGRATE_CMA to be usable, pages marked with it
must be aligned to MAX_ORDER_NR_PAGES.  I'll add that in a comment
somewhere.

-- 
Best regards,                                         _     _
 .o. | Liege of Serenly Enlightened Majesty of      o' \,=./ `o
 ..o | Computer Science,  Michal "mina86" Nazarewicz   (o o)
 ooo +--<mina86-tlen.pl>--<jid:mina86-jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
