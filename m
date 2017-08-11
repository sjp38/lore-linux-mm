Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADE586B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 15:01:35 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id f9so16764330uaf.1
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:01:35 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l41si821778uaf.153.2017.08.11.12.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 12:01:33 -0700 (PDT)
Subject: Re: [v6 04/15] mm: discard memblock data later
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-5-git-send-email-pasha.tatashin@oracle.com>
 <20170811093249.GE30811@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <42a04441-47ad-2fa0-ca3c-784c717213f7@oracle.com>
Date: Fri, 11 Aug 2017 15:00:47 -0400
MIME-Version: 1.0
In-Reply-To: <20170811093249.GE30811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, Mel Gorman <mgorman@suse.de>

Hi Michal,

This suggestion won't work, because there are arches without memblock 
support: tile, sh...

So, I would still need to have:

#ifdef CONFIG_MEMBLOCK in page_alloc, or define memblock_discard() stubs 
in nobootmem headfile. In either case it would become messier than what 
it is right now.

Pasha

> I have just one nit below
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> [...]
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 2cb25fe4452c..bf14aea6ab70 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -285,31 +285,27 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
>>   }
>>   
>>   #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> 
> pull this ifdef inside memblock_discard and you do not have an another
> one in page_alloc_init_late
> 
> [...]
>> +/**
>> + * Discard memory and reserved arrays if they were allocated
>> + */
>> +void __init memblock_discard(void)
>>   {
> 
> here
> 
>> -	if (memblock.memory.regions == memblock_memory_init_regions)
>> -		return 0;
>> +	phys_addr_t addr, size;
>>   
>> -	*addr = __pa(memblock.memory.regions);
>> +	if (memblock.reserved.regions != memblock_reserved_init_regions) {
>> +		addr = __pa(memblock.reserved.regions);
>> +		size = PAGE_ALIGN(sizeof(struct memblock_region) *
>> +				  memblock.reserved.max);
>> +		__memblock_free_late(addr, size);
>> +	}
>>   
>> -	return PAGE_ALIGN(sizeof(struct memblock_region) *
>> -			  memblock.memory.max);
>> +	if (memblock.memory.regions == memblock_memory_init_regions) {
>> +		addr = __pa(memblock.memory.regions);
>> +		size = PAGE_ALIGN(sizeof(struct memblock_region) *
>> +				  memblock.memory.max);
>> +		__memblock_free_late(addr, size);
>> +	}
>>   }
>> -
>>   #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
