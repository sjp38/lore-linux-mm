Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 496D56B2373
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:05:07 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x98-v6so2348918ede.0
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 19:05:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i26-v6sor62211ejz.40.2018.11.20.19.05.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 19:05:05 -0800 (PST)
Date: Wed, 21 Nov 2018 03:05:04 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: use managed_zone() for more exact check in zone
 iteration
Message-ID: <20181121030504.ucclpgl62es7lnwf@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181114235040.36180-1-richard.weiyang@gmail.com>
 <20181116102405.GF14706@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116102405.GF14706@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 16, 2018 at 11:24:05AM +0100, Michal Hocko wrote:
>On Thu 15-11-18 07:50:40, Wei Yang wrote:
>[...]
>> @@ -1193,8 +1196,8 @@ static unsigned int count_free_highmem_pages(void)
>>  	struct zone *zone;
>>  	unsigned int cnt = 0;
>>  
>> -	for_each_populated_zone(zone)
>> -		if (is_highmem(zone))
>> +	for_each_zone(zone)
>> +		if (populated_zone(zone) && is_highmem(zone))
>>  			cnt += zone_page_state(zone, NR_FREE_PAGES);
>
>this should be for_each_managed_zone because we only care about highmem
>zones which have pages in the allocator (NR_FREE_PAGES).
>
>>  
>>  	return cnt;
>> @@ -1239,10 +1242,10 @@ static unsigned int count_highmem_pages(void)
>>  	struct zone *zone;
>>  	unsigned int n = 0;
>>  
>> -	for_each_populated_zone(zone) {
>> +	for_each_zone(zone) {
>>  		unsigned long pfn, max_zone_pfn;
>>  
>> -		if (!is_highmem(zone))
>> +		if (!populated_zone(zone) || !is_highmem(zone))
>>  			continue;
>>  
>>  		mark_free_pages(zone);
>
>I am not familiar with this code much but I strongly suspect that we do
>want for_each_managed_zone here because saveable_highmem_page skips over
>all reserved pages which rules out the bootmem. But this should be
>double checked with Rafael (Cc-ed).
>
>Rafael, does this loop care about pages which are not managed by the
>page allocator?
>

Hi, Rafael

Your opinion on this change and the following one is appreciated :-)

>> @@ -1305,8 +1308,8 @@ static unsigned int count_data_pages(void)
>>  	unsigned long pfn, max_zone_pfn;
>>  	unsigned int n = 0;
>>  
>> -	for_each_populated_zone(zone) {
>> -		if (is_highmem(zone))
>> +	for_each_zone(zone) {
>> +		if (!populated_zone(zone) || is_highmem(zone))
>>  			continue;
>>  
>>  		mark_free_pages(zone);
>> @@ -1399,9 +1402,12 @@ static void copy_data_pages(struct memory_bitmap *copy_bm,
>>  	struct zone *zone;
>>  	unsigned long pfn;
>>  
>> -	for_each_populated_zone(zone) {
>> +	for_each_zone(zone) {
>>  		unsigned long max_zone_pfn;
>>  
>> +		if (!populated_zone(zone))
>> +			continue;
>> +
>>  		mark_free_pages(zone);
>>  		max_zone_pfn = zone_end_pfn(zone);
>>  		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
>> @@ -1717,7 +1723,10 @@ int hibernate_preallocate_memory(void)
>>  	saveable += save_highmem;
>>  	highmem = save_highmem;
>>  	size = 0;
>> -	for_each_populated_zone(zone) {
>> +	for_each_zone(zone) {
>> +		if (!populated_zone(zone))
>> +			continue;
>> +
>>  		size += snapshot_additional_pages(zone);
>>  		if (is_highmem(zone))
>>  			highmem += zone_page_state(zone, NR_FREE_PAGES);
>
>ditto for the above.
>
>
>> @@ -1863,8 +1872,8 @@ static int enough_free_mem(unsigned int nr_pages, unsigned int nr_highmem)
>>  	struct zone *zone;
>>  	unsigned int free = alloc_normal;
>>  
>> -	for_each_populated_zone(zone)
>> -		if (!is_highmem(zone))
>> +	for_each_zone(zone)
>> +		if (populated_zone(zone) && !is_highmem(zone))
>>  			free += zone_page_state(zone, NR_FREE_PAGES);
>>  
>>  	nr_pages += count_pages_for_highmem(nr_highmem);
>
>This one should be for_each_managed_zone (NR_FREE_PAGES)
>
>The rest looks good to me.
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
