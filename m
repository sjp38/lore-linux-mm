Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id B34B46B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 01:31:49 -0500 (EST)
Received: by bkty12 with SMTP id y12so5958991bkt.14
        for <linux-mm@kvack.org>; Mon, 27 Feb 2012 22:31:48 -0800 (PST)
Message-ID: <4F4C74D1.3040909@openvz.org>
Date: Tue, 28 Feb 2012 10:31:45 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 16/21] mm: handle lruvec relocks in compaction
References: <20120223133728.12988.5432.stgit@zurg>	<20120223135256.12988.24796.stgit@zurg> <20120228101348.fb38e5f2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120228101348.fb38e5f2.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 23 Feb 2012 17:52:56 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> Prepare for lru_lock splitting in memory compaction code.
>>
>> * disable irqs in acct_isolated() for __mod_zone_page_state(),
>>    lru_lock isn't required there.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>> ---
>>   mm/compaction.c |   30 ++++++++++++++++--------------
>>   1 files changed, 16 insertions(+), 14 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index a976b28..54340e4 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -224,8 +224,10 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
>>   	list_for_each_entry(page,&cc->migratepages, lru)
>>   		count[!!page_is_file_cache(page)]++;
>>
>> +	local_irq_disable();
>>   	__mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
>>   	__mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
>> +	local_irq_enable();
>
> Why we need to disable Irq here ??

__mod_zone_page_state() want this to protect per-cpu counters, maybe preempt_disable() is enough.

>
>
>
>>   }
>>
>>   /* Similar to reclaim, but different enough that they don't share logic */
>> @@ -262,7 +264,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>>   	unsigned long nr_scanned = 0, nr_isolated = 0;
>>   	struct list_head *migratelist =&cc->migratepages;
>>   	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
>> -	struct lruvec *lruvec;
>> +	struct lruvec *lruvec = NULL;
>>
>>   	/* Do not scan outside zone boundaries */
>>   	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
>> @@ -294,25 +296,24 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>>
>>   	/* Time to isolate some pages for migration */
>>   	cond_resched();
>> -	spin_lock_irq(&zone->lru_lock);
>>   	for (; low_pfn<  end_pfn; low_pfn++) {
>>   		struct page *page;
>> -		bool locked = true;
>>
>>   		/* give a chance to irqs before checking need_resched() */
>>   		if (!((low_pfn+1) % SWAP_CLUSTER_MAX)) {
>> -			spin_unlock_irq(&zone->lru_lock);
>> -			locked = false;
>> +			if (lruvec)
>> +				unlock_lruvec_irq(lruvec);
>> +			lruvec = NULL;
>>   		}
>> -		if (need_resched() || spin_is_contended(&zone->lru_lock)) {
>> -			if (locked)
>> -				spin_unlock_irq(&zone->lru_lock);
>> +		if (need_resched() ||
>> +		    (lruvec&&  spin_is_contended(&zone->lru_lock))) {
>> +			if (lruvec)
>> +				unlock_lruvec_irq(lruvec);
>> +			lruvec = NULL;
>>   			cond_resched();
>> -			spin_lock_irq(&zone->lru_lock);
>>   			if (fatal_signal_pending(current))
>>   				break;
>> -		} else if (!locked)
>> -			spin_lock_irq(&zone->lru_lock);
>> +		}
>>
>>   		/*
>>   		 * migrate_pfn does not necessarily start aligned to a
>> @@ -359,7 +360,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>>   			continue;
>>   		}
>>
>> -		if (!PageLRU(page))
>> +		if (!__lock_page_lruvec_irq(&lruvec, page))
>>   			continue;
>
> Could you add more comments onto __lock_page_lruvec_irq() ?

Actually there is a very unlikely race with page free-realloc,
(which is fixed in Hugh's patchset, and surprisingly fixed in my old memory controller)
thus this part will be redesigned.

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
