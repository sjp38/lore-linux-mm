Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30C546B000A
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:27:11 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id p203-v6so1011358itc.1
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 02:27:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o123-v6sor2742536ith.78.2018.03.16.02.27.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 02:27:10 -0700 (PDT)
Subject: Re: [PATCH] Revert "mm/memblock.c: hardcode the end_pfn being -1"
References: <1521168966-5245-1-git-send-email-hejianet@gmail.com>
 <20180316090647.GC23100@dhcp22.suse.cz>
From: Jia He <hejianet@gmail.com>
Message-ID: <d0c53509-98b3-11a8-2bf2-b43cdd67b5de@gmail.com>
Date: Fri, 16 Mar 2018 17:26:57 +0800
MIME-Version: 1.0
In-Reply-To: <20180316090647.GC23100@dhcp22.suse.cz>
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Daniel Vacek <neelx@redhat.com>, linux-kernel@vger.kernel.org, Jia He <jia.he@hxt-semitech.com>



On 3/16/2018 5:06 PM, Michal Hocko Wrote:
> On Thu 15-03-18 19:56:06, Jia He wrote:
>> This reverts commit 379b03b7fa05f7db521b7732a52692448a3c34fe.
>>
>> Commit 864b75f9d6b0 ("mm/page_alloc: fix memmap_init_zone pageblock
>> alignment") introduced boot hang issues in arm/arm64 machines, so
>> Ard Biesheuvel reverted in commit 3e04040df6d4. But there is a
>> preparation patch for commit 864b75f9d6b0. So just revert it for
>> the sake of caution.
> Why? Is there anything wrong with this one?
I don't think there might be anything wrong. Justin for the sake of caution.
Please ignore this patch if you prefer to keep 379b03b7fa.
But seems parameter *max_pfn* is useless and can be removed in this case?

Cheers,
Jia
>> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
>> ---
>>   mm/memblock.c | 10 +++++-----
>>   1 file changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index b6ba6b7..5a9ca2a 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -1107,7 +1107,7 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
>>   	struct memblock_type *type = &memblock.memory;
>>   	unsigned int right = type->cnt;
>>   	unsigned int mid, left = 0;
>> -	phys_addr_t addr = PFN_PHYS(++pfn);
>> +	phys_addr_t addr = PFN_PHYS(pfn + 1);
>>   
>>   	do {
>>   		mid = (right + left) / 2;
>> @@ -1118,15 +1118,15 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
>>   				  type->regions[mid].size))
>>   			left = mid + 1;
>>   		else {
>> -			/* addr is within the region, so pfn is valid */
>> -			return pfn;
>> +			/* addr is within the region, so pfn + 1 is valid */
>> +			return min(pfn + 1, max_pfn);
>>   		}
>>   	} while (left < right);
>>   
>>   	if (right == type->cnt)
>> -		return -1UL;
>> +		return max_pfn;
>>   	else
>> -		return PHYS_PFN(type->regions[right].base);
>> +		return min(PHYS_PFN(type->regions[right].base), max_pfn);
>>   }
>>   
>>   /**
>> -- 
>> 2.7.4
>>
