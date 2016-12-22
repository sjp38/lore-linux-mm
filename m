Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A686028026B
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 17:37:36 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 5so483387231pgi.2
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 14:37:36 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id b31si32147518pli.65.2016.12.22.14.37.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 14:37:35 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id i5so11899335pgh.2
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 14:37:35 -0800 (PST)
Date: Thu, 22 Dec 2016 22:37:33 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/2] mm/memblock.c: check return value of
 memblock_reserve() in memblock_virt_alloc_internal()
Message-ID: <20161222223733.GA27208@vultr.guest>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1482363033-24754-1-git-send-email-richard.weiyang@gmail.com>
 <1482363033-24754-3-git-send-email-richard.weiyang@gmail.com>
 <20161222091519.GC6048@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161222091519.GC6048@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 22, 2016 at 10:15:20AM +0100, Michal Hocko wrote:
>On Wed 21-12-16 23:30:33, Wei Yang wrote:
>> memblock_reserve() would add a new range to memblock.reserved in case the
>> new range is not totally covered by any of the current memblock.reserved
>> range. If the memblock.reserved is full and can't resize,
>> memblock_reserve() would fail.
>> 
>> This doesn't happen in real world now, I observed this during code review.
>> While theoretically, it has the chance to happen. And if it happens, others
>> would think this range of memory is still available and may corrupt the
>> memory.
>
>OK, this explains it much better than the previous version! The silent
>memory corruption is indeed too hard to debug to have this open even
>when the issue is theoretical.
>

Thanks~ Have a nice day:-)

>> This patch checks the return value and goto "done" after it succeeds.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
>Acked-by: Michal Hocko <mhocko@suse.com>
>
>Thanks!
>
>> ---
>>  mm/memblock.c | 6 ++----
>>  1 file changed, 2 insertions(+), 4 deletions(-)
>> 
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 4929e06..d0f2c96 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -1274,18 +1274,17 @@ static void * __init memblock_virt_alloc_internal(
>>  
>>  	if (max_addr > memblock.current_limit)
>>  		max_addr = memblock.current_limit;
>> -
>>  again:
>>  	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
>>  					    nid, flags);
>> -	if (alloc)
>> +	if (alloc && !memblock_reserve(alloc, size))
>>  		goto done;
>>  
>>  	if (nid != NUMA_NO_NODE) {
>>  		alloc = memblock_find_in_range_node(size, align, min_addr,
>>  						    max_addr, NUMA_NO_NODE,
>>  						    flags);
>> -		if (alloc)
>> +		if (alloc && !memblock_reserve(alloc, size))
>>  			goto done;
>>  	}
>>  
>> @@ -1303,7 +1302,6 @@ static void * __init memblock_virt_alloc_internal(
>>  
>>  	return NULL;
>>  done:
>> -	memblock_reserve(alloc, size);
>>  	ptr = phys_to_virt(alloc);
>>  	memset(ptr, 0, size);
>>  
>> -- 
>> 2.5.0
>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
