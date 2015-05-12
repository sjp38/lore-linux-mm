Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id DAF6C6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 03:54:53 -0400 (EDT)
Received: by widdi4 with SMTP id di4so3077045wid.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 00:54:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v3si1792633wiw.60.2015.05.12.00.54.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 May 2015 00:54:52 -0700 (PDT)
Message-ID: <5551B1CB.7070301@suse.cz>
Date: Tue, 12 May 2015 09:54:51 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/page_alloc: don't break highest order freepage
 if steal
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com> <5551B11C.4080000@suse.cz>
In-Reply-To: <5551B11C.4080000@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On 05/12/2015 09:51 AM, Vlastimil Babka wrote:
>>    {
>>    	struct page *page;
>> +	bool steal_fallback;
>>
>> -retry_reserve:
>> +retry:
>>    	page = __rmqueue_smallest(zone, order, migratetype);
>>
>>    	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
>>    		if (migratetype == MIGRATE_MOVABLE)
>>    			page = __rmqueue_cma_fallback(zone, order);
>>
>> -		if (!page)
>> -			page = __rmqueue_fallback(zone, order, migratetype);
>> +		if (page)
>> +			goto out;
>> +
>> +		steal_fallback = __rmqueue_fallback(zone, order, migratetype);

Oh and the variable can be probably replaced by calling 
__rmqueue_fallback directly in the if() below.

>>
>>    		/*
>>    		 * Use MIGRATE_RESERVE rather than fail an allocation. goto
>>    		 * is used because __rmqueue_smallest is an inline function
>>    		 * and we want just one call site
>>    		 */
>> -		if (!page) {
>> +		if (!steal_fallback)
>>    			migratetype = MIGRATE_RESERVE;
>> -			goto retry_reserve;
>> -		}
>> +
>> +		goto retry;
>>    	}
>>
>> +out:
>>    	trace_mm_page_alloc_zone_locked(page, order, migratetype);
>>    	return page;
>>    }
>>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
