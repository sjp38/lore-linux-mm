Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E5F546B0337
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 11:48:26 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g1so262821682pgn.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:48:26 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id e80si22933076pfl.8.2016.12.20.08.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 08:48:26 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id b1so12661881pgc.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:48:26 -0800 (PST)
Date: Tue, 20 Dec 2016 16:48:23 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH V2 2/2] mm/memblock.c: check return value of
 memblock_reserve() in memblock_virt_alloc_internal()
Message-ID: <20161220164823.GB13224@vultr.guest>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
 <1482072470-26151-3-git-send-email-richard.weiyang@gmail.com>
 <20161219152156.GC5175@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219152156.GC5175@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 19, 2016 at 04:21:57PM +0100, Michal Hocko wrote:
>On Sun 18-12-16 14:47:50, Wei Yang wrote:
>> memblock_reserve() may fail in case there is not enough regions.
>
>Have you seen this happenning in the real setups or this is a by-review
>driven change?

This is a by-review driven change.

>[...]
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
>
>This doesn't look right. You can end up leaking the first allocated
>range.
>

Hmm... why?

If first memblock_reserve() succeed, it will jump to done, so that no 2nd
allocation.
If the second executes, it means the first allocation failed.
memblock_find_in_range_node() doesn't modify the memblock, it just tell you
there is a proper memory region available.

>>  
>> @@ -1303,7 +1302,6 @@ static void * __init memblock_virt_alloc_internal(
>>  
>>  	return NULL;
>>  done:
>> -	memblock_reserve(alloc, size);
>>  	ptr = phys_to_virt(alloc);
>>  	memset(ptr, 0, size);
>
>
>>  
>> -- 
>> 2.5.0
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
