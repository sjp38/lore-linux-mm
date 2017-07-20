Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9076B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 06:17:21 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 65so5721596lfa.1
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 03:17:21 -0700 (PDT)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [2a02:6b8:0:1465::fd])
        by mx.google.com with ESMTPS id s26si913238ljd.54.2017.07.20.03.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 03:17:19 -0700 (PDT)
Subject: Re: [PATCH RFC] mm: allow isolation for pages not inserted into lru
 lists yet
References: <150039362282.196778.7901790444249317003.stgit@buzz>
 <9a95eec1-54c6-0c8d-101b-aa53e6af36e3@suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <866256fa-14a8-75ba-18e0-12c64d0f7a89@yandex-team.ru>
Date: Thu, 20 Jul 2017 13:17:18 +0300
MIME-Version: 1.0
In-Reply-To: <9a95eec1-54c6-0c8d-101b-aa53e6af36e3@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: ru-RU
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Shaohua Li <shli@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org

On 20.07.2017 12:45, Vlastimil Babka wrote:
> On 07/18/2017 06:00 PM, Konstantin Khlebnikov wrote:
>> Pages are added into lru lists via per-cpu page vectors in order
>> to combine these insertions and reduce lru lock contention.
>>
>> These pending pages cannot be isolated and moved into another lru.
>> This breaks in some cases page activation and makes mlock-munlock
>> much more complicated.
>>
>> Also this breaks newly added swapless MADV_FREE: if it cannot move
>> anon page into file lru then page could never be freed lazily.
>>
>> This patch rearranges lru list handling to allow lru isolation for
>> such pages. It set PageLRU earlier and initialize page->lru to mark
>> pages still pending for lru insert.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> I think it's not so simple and won't work as you expect after this
> patch. See below.
> 
>> ---
>>   include/linux/mm_inline.h |   10 ++++++++--
>>   mm/swap.c                 |   26 ++++++++++++++++++++++++--
>>   2 files changed, 32 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
>> index e030a68ead7e..6618c588ee40 100644
>> --- a/include/linux/mm_inline.h
>> +++ b/include/linux/mm_inline.h
>> @@ -60,8 +60,14 @@ static __always_inline void add_page_to_lru_list_tail(struct page *page,
>>   static __always_inline void del_page_from_lru_list(struct page *page,
>>   				struct lruvec *lruvec, enum lru_list lru)
>>   {
>> -	list_del(&page->lru);
>> -	update_lru_size(lruvec, lru, page_zonenum(page), -hpage_nr_pages(page));
>> +	/*
>> +	 * Empty list head means page is not drained to lru list yet.
>> +	 */
>> +	if (likely(!list_empty(&page->lru))) {
>> +		list_del(&page->lru);
>> +		update_lru_size(lruvec, lru, page_zonenum(page),
>> +				-hpage_nr_pages(page));
>> +	}
>>   }
>>   
>>   /**
>> diff --git a/mm/swap.c b/mm/swap.c
>> index 23fc6e049cda..ba4c98074a09 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -400,13 +400,35 @@ void mark_page_accessed(struct page *page)
>>   }
>>   EXPORT_SYMBOL(mark_page_accessed);
>>   
>> +static void __pagevec_lru_add_drain_fn(struct page *page, struct lruvec *lruvec,
>> +				       void *arg)
>> +{
>> +	/* Check for isolated or already added pages */
>> +	if (likely(PageLRU(page) && list_empty(&page->lru))) {
> 
> I think it's now possible that page ends up on two (or more) cpu's
> pagevecs, right. And they can race doing their local drains, and both
> pass this check at the same moment. The lru lock should prevent at least
> some disaster, but what if the first CPU succeeds, and then the page is
> further isolated and e.g. reclaimed. Then the second CPU still assumes
> it's PageLRU() etc, but it's not anymore...?

Reclaimer/isolate clears PageLRU under lru_lock and drain will skip that page.
Duplicate inserts are catched by second check.


> 
>> +		int file = page_is_file_cache(page);
>> +		int active = PageActive(page);
>> +		enum lru_list lru = page_lru(page);
>> +
>> +		add_page_to_lru_list(page, lruvec, lru);
>> +		update_page_reclaim_stat(lruvec, file, active);
>> +		trace_mm_lru_insertion(page, lru);
>> +	}
>> +}
>> +
>>   static void __lru_cache_add(struct page *page)
>>   {
>>   	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
>>   
>> +	/*
>> +	 * Set PageLRU right here and initialize list head to
>> +	 * allow page isolation while it on the way to the LRU list.
>> +	 */
>> +	VM_BUG_ON_PAGE(PageLRU(page), page);
>> +	INIT_LIST_HEAD(&page->lru);
>>   	get_page(page);
> 
> This elevates the page count, I think at least some LRU isolators will
> skip the pages anyway because of that.

Yep, theoretically we could get rid of these references:
memory offline must darain all these vectors before freeing stuct page.

This will help memory migration and compaction a little.

> 
>> +	SetPageLRU(page);
>>   	if (!pagevec_add(pvec, page) || PageCompound(page))
>> -		__pagevec_lru_add(pvec);
>> +		pagevec_lru_move_fn(pvec, __pagevec_lru_add_drain_fn, NULL);
>>   	put_cpu_var(lru_add_pvec);
>>   }
>>   
>> @@ -611,7 +633,7 @@ void lru_add_drain_cpu(int cpu)
>>   	struct pagevec *pvec = &per_cpu(lru_add_pvec, cpu);
>>   
>>   	if (pagevec_count(pvec))
>> -		__pagevec_lru_add(pvec);
>> +		pagevec_lru_move_fn(pvec, __pagevec_lru_add_drain_fn, NULL);
>>   
>>   	pvec = &per_cpu(lru_rotate_pvecs, cpu);
>>   	if (pagevec_count(pvec)) {
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
