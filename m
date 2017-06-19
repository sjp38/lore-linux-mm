Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 075196B0292
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 15:05:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c68so12843900wmi.4
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 12:05:33 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id 53si5420894wru.4.2017.06.19.12.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 12:05:32 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id m125so1875458wmm.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 12:05:32 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] mm: remove a redundant condition in the for loop
References: <20170619135418.8580-1-haolee.swjtu@gmail.com>
	<e2169d83-8845-7eac-2b81-e5f0b16943a3@suse.cz>
Date: Mon, 19 Jun 2017 21:05:29 +0200
In-Reply-To: <e2169d83-8845-7eac-2b81-e5f0b16943a3@suse.cz> (Vlastimil Babka's
	message of "Mon, 19 Jun 2017 16:17:01 +0200")
Message-ID: <87y3snajd2.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hao Lee <haolee.swjtu@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 19 2017, Vlastimil Babka <vbabka@suse.cz> wrote:

> On 06/19/2017 03:54 PM, Hao Lee wrote:
>> The variable current_order decreases from MAX_ORDER-1 to order, so the
>> condition current_order <= MAX_ORDER-1 is always true.
>> 
>> Signed-off-by: Hao Lee <haolee.swjtu@gmail.com>
>
> Sounds right.
>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

current_order and order are both unsigned, and if order==0,
current_order >= order is always true, and we may decrement
current_order past 0 making it UINT_MAX... A comment would be in order,
though.

>> ---
>>  mm/page_alloc.c | 5 ++---
>>  1 file changed, 2 insertions(+), 3 deletions(-)
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 2302f25..9120c2b 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2215,9 +2215,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>>  	bool can_steal;
>>  
>>  	/* Find the largest possible block of pages in the other list */
>> -	for (current_order = MAX_ORDER-1;
>> -				current_order >= order && current_order <= MAX_ORDER-1;
>> -				--current_order) {
>> +	for (current_order = MAX_ORDER-1; current_order >= order;
>> +							--current_order) {
>>  		area = &(zone->free_area[current_order]);
>>  		fallback_mt = find_suitable_fallback(area, current_order,
>>  				start_migratetype, false, &can_steal);
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
