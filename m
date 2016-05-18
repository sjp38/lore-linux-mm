Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED4AA6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 03:52:00 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id ga2so19670409lbc.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:52:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si9393824wmb.12.2016.05.18.00.51.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 00:51:59 -0700 (PDT)
Subject: Re: [PATCH 28/28] mm, page_alloc: Defer debugging checks of pages
 allocated from the PCP
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-16-git-send-email-mgorman@techsingularity.net>
 <20160517064153.GA23930@hori1.linux.bs1.fc.nec.co.jp>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573C1F1E.4040201@suse.cz>
Date: Wed, 18 May 2016 09:51:58 +0200
MIME-Version: 1.0
In-Reply-To: <20160517064153.GA23930@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/17/2016 08:41 AM, Naoya Horiguchi wrote:
>> @@ -2579,20 +2612,22 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>>   		struct list_head *list;
>>   
>>   		local_irq_save(flags);
>> -		pcp = &this_cpu_ptr(zone->pageset)->pcp;
>> -		list = &pcp->lists[migratetype];
>> -		if (list_empty(list)) {
>> -			pcp->count += rmqueue_bulk(zone, 0,
>> -					pcp->batch, list,
>> -					migratetype, cold);
>> -			if (unlikely(list_empty(list)))
>> -				goto failed;
>> -		}
>> +		do {
>> +			pcp = &this_cpu_ptr(zone->pageset)->pcp;
>> +			list = &pcp->lists[migratetype];
>> +			if (list_empty(list)) {
>> +				pcp->count += rmqueue_bulk(zone, 0,
>> +						pcp->batch, list,
>> +						migratetype, cold);
>> +				if (unlikely(list_empty(list)))
>> +					goto failed;
>> +			}
>>   
>> -		if (cold)
>> -			page = list_last_entry(list, struct page, lru);
>> -		else
>> -			page = list_first_entry(list, struct page, lru);
>> +			if (cold)
>> +				page = list_last_entry(list, struct page, lru);
>> +			else
>> +				page = list_first_entry(list, struct page, lru);
>> +		} while (page && check_new_pcp(page));
> 
> This causes infinite loop when check_new_pcp() returns 1, because the bad
> page is still in the list (I assume that a bad page never disappears).
> The original kernel is free from this problem because we do retry after
> list_del(). So moving the following 3 lines into this do-while block solves
> the problem?
> 
>      __dec_zone_state(zone, NR_ALLOC_BATCH);
>      list_del(&page->lru);
>      pcp->count--;
> 
> There seems no infinit loop issue in order > 0 block below, because bad pages
> are deleted from free list in __rmqueue_smallest().

Ooops, thanks for catching this, wish it was sooner...

----8<----
