Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id D6B5F6B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 01:23:07 -0500 (EST)
Received: by bkty12 with SMTP id y12so5954170bkt.14
        for <linux-mm@kvack.org>; Mon, 27 Feb 2012 22:23:06 -0800 (PST)
Message-ID: <4F4C72C7.2000405@openvz.org>
Date: Tue, 28 Feb 2012 10:23:03 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 14/21] mm: introduce lruvec locking primitives
References: <20120223133728.12988.5432.stgit@zurg>	<20120223135247.12988.49745.stgit@zurg> <20120228095642.39eaab28.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120228095642.39eaab28.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 23 Feb 2012 17:52:47 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> This is initial preparation for lru_lock splitting.
>>
>> This locking primites designed to hide splitted nature of lru_lock
>> and to avoid overhead for non-splitted lru_lock in non-memcg case.
>>
>> * Lock via lruvec reference
>>
>> lock_lruvec(lruvec, flags)
>> lock_lruvec_irq(lruvec)
>>
>> * Lock via page reference
>>
>> lock_page_lruvec(page, flags)
>> lock_page_lruvec_irq(page)
>> relock_page_lruvec(lruvec, page, flags)
>> relock_page_lruvec_irq(lruvec, page)
>> __relock_page_lruvec(lruvec, page) ( lruvec != NULL, page in same zone )
>>
>> They always returns pointer to some locked lruvec, page anyway can be
>> not in lru, PageLRU() sign is stable while we hold returned lruvec lock.
>> Caller must guarantee page to lruvec reference validity.
>>
>> * Lock via page, without stable page reference
>>
>> __lock_page_lruvec_irq(&lruvec, page)
>>
>> It returns true of lruvec succesfully locked and PageLRU is set.
>> Initial lruvec can be NULL. Consequent calls must be in the same zone.
>>
>> * Unlock
>>
>> unlock_lruvec(lruvec, flags)
>> unlock_lruvec_irq(lruvec)
>>
>> * Wait
>>
>> wait_lruvec_unlock(lruvec)
>> Wait for lruvec unlock, caller must have stable reference to lruvec.
>>
>> __wait_lruvec_unlock(lruvec)
>> Wait for lruvec unlock before locking other lrulock for same page,
>> nothing if there only one possible lruvec per page.
>> Used at page-to-lruvec reference switching to stabilize PageLRU sign.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>
> O.K. I like this.
>
> Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> Hmm....Could you add a comment in memcg part ? (see below)
>
>
>
>> ---
>>   mm/huge_memory.c |    8 +-
>>   mm/internal.h    |  176 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   mm/memcontrol.c  |   14 ++--
>>   mm/swap.c        |   58 ++++++------------
>>   mm/vmscan.c      |   77 ++++++++++--------------
>>   5 files changed, 237 insertions(+), 96 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 09e7069..74996b8 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1228,13 +1228,11 @@ static int __split_huge_page_splitting(struct page *page,
>>   static void __split_huge_page_refcount(struct page *page)
>>   {
>>   	int i;
>> -	struct zone *zone = page_zone(page);
>>   	struct lruvec *lruvec;
>>   	int tail_count = 0;
>>
>>   	/* prevent PageLRU to go away from under us, and freeze lru stats */
>> -	spin_lock_irq(&zone->lru_lock);
>> -	lruvec = page_lruvec(page);
>> +	lruvec = lock_page_lruvec_irq(page);
>>   	compound_lock(page);
>>   	/* complete memcg works before add pages to LRU */
>>   	mem_cgroup_split_huge_fixup(page);
>> @@ -1316,11 +1314,11 @@ static void __split_huge_page_refcount(struct page *page)
>>   	BUG_ON(atomic_read(&page->_count)<= 0);
>>
>>   	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
>> -	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
>> +	__mod_zone_page_state(lruvec_zone(lruvec), NR_ANON_PAGES, HPAGE_PMD_NR);
>>
>>   	ClearPageCompound(page);
>>   	compound_unlock(page);
>> -	spin_unlock_irq(&zone->lru_lock);
>> +	unlock_lruvec_irq(lruvec);
>>
>>   	for (i = 1; i<  HPAGE_PMD_NR; i++) {
>>   		struct page *page_tail = page + i;
>> diff --git a/mm/internal.h b/mm/internal.h
>> index ef49dbf..9454752 100644
>> --- a/mm/internal.h
>> +++ b/mm/internal.h
>> @@ -13,6 +13,182 @@
>>
>>   #include<linux/mm.h>
>>
>> +static inline void lock_lruvec(struct lruvec *lruvec, unsigned long *flags)
>> +{
>> +	spin_lock_irqsave(&lruvec_zone(lruvec)->lru_lock, *flags);
>> +}
>> +
>> +static inline void lock_lruvec_irq(struct lruvec *lruvec)
>> +{
>> +	spin_lock_irq(&lruvec_zone(lruvec)->lru_lock);
>> +}
>> +
>> +static inline void unlock_lruvec(struct lruvec *lruvec, unsigned long *flags)
>> +{
>> +	spin_unlock_irqrestore(&lruvec_zone(lruvec)->lru_lock, *flags);
>> +}
>> +
>> +static inline void unlock_lruvec_irq(struct lruvec *lruvec)
>> +{
>> +	spin_unlock_irq(&lruvec_zone(lruvec)->lru_lock);
>> +}
>> +
>> +static inline void wait_lruvec_unlock(struct lruvec *lruvec)
>> +{
>> +	spin_unlock_wait(&lruvec_zone(lruvec)->lru_lock);
>> +}
>> +
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>> +
>> +/* Dynamic page to lruvec mapping */
>> +
>> +/* Lock other lruvec for other page in the same zone */
>> +static inline struct lruvec *__relock_page_lruvec(struct lruvec *locked_lruvec,
>> +						  struct page *page)
>> +{
>> +	/* Currenyly only one lru_lock per-zone */
>> +	return page_lruvec(page);
>> +}
>> +
>> +static inline struct lruvec *relock_page_lruvec_irq(struct lruvec *lruvec,
>> +						    struct page *page)
>> +{
>> +	struct zone *zone = page_zone(page);
>> +
>> +	if (!lruvec) {
>> +		spin_lock_irq(&zone->lru_lock);
>> +	} else if (zone != lruvec_zone(lruvec)) {
>> +		unlock_lruvec_irq(lruvec);
>> +		spin_lock_irq(&zone->lru_lock);
>> +	}
>> +	return page_lruvec(page);
>> +}
>
> Could you add comments/caution to the caller
>
>   - !PageLRU(page) case ?
>   - Can the caller assume page_lruvec(page) == lruvec ? If no, which lru_vec is locked ?

Yes, caller can assume page_lruvec(page) == lruvec. And PageLRU() is stable,
it means it stays true or false while this lruvec is locked.

>
> etc...
>
>
>> +
>> +static inline struct lruvec *relock_page_lruvec(struct lruvec *lruvec,
>> +						struct page *page,
>> +						unsigned long *flags)
>> +{
>> +	struct zone *zone = page_zone(page);
>> +
>> +	if (!lruvec) {
>> +		spin_lock_irqsave(&zone->lru_lock, *flags);
>> +	} else if (zone != lruvec_zone(lruvec)) {
>> +		unlock_lruvec(lruvec, flags);
>> +		spin_lock_irqsave(&zone->lru_lock, *flags);
>> +	}
>> +	return page_lruvec(page);
>> +}
>
>
> Same here.
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
