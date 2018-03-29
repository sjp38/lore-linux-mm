Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 146336B0003
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 04:06:58 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id w197so4529800iod.23
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 01:06:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o34sor2564393ioi.141.2018.03.29.01.06.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Mar 2018 01:06:56 -0700 (PDT)
Subject: Re: [PATCH v3 2/5] mm: page_alloc: reduce unnecessary binary search
 in memblock_next_valid_pfn()
References: <1522033340-6575-1-git-send-email-hejianet@gmail.com>
 <1522033340-6575-3-git-send-email-hejianet@gmail.com>
 <20180328092620.GA98648@WeideMacBook-Pro.local>
From: Jia He <hejianet@gmail.com>
Message-ID: <2c41a24b-1fa6-7115-c312-a11157619a16@gmail.com>
Date: Thu, 29 Mar 2018 16:06:38 +0800
MIME-Version: 1.0
In-Reply-To: <20180328092620.GA98648@WeideMacBook-Pro.local>
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>



On 3/28/2018 5:26 PM, Wei Yang Wrote:
> On Sun, Mar 25, 2018 at 08:02:16PM -0700, Jia He wrote:
>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> where possible") optimized the loop in memmap_init_zone(). But there is
>> still some room for improvement. E.g. if pfn and pfn+1 are in the same
>> memblock region, we can simply pfn++ instead of doing the binary search
>> in memblock_next_valid_pfn. This patch only works when
>> CONFIG_HAVE_ARCH_PFN_VALID is enable.
>>
>> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
>> ---
>> include/linux/memblock.h |  2 +-
>> mm/memblock.c            | 73 +++++++++++++++++++++++++++++-------------------
>> mm/page_alloc.c          |  3 +-
>> 3 files changed, 47 insertions(+), 31 deletions(-)
>>
>> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>> index efbbe4b..a8fb2ab 100644
>> --- a/include/linux/memblock.h
>> +++ b/include/linux/memblock.h
>> @@ -204,7 +204,7 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
>> #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>
>> #ifdef CONFIG_HAVE_ARCH_PFN_VALID
>> -unsigned long memblock_next_valid_pfn(unsigned long pfn);
>> +unsigned long memblock_next_valid_pfn(unsigned long pfn, int *idx);
>> #endif
>>
>> /**
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index bea5a9c..06c1a08 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -1102,35 +1102,6 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
>> 		*out_nid = r->nid;
>> }
>>
>> -#ifdef CONFIG_HAVE_ARCH_PFN_VALID
>> -unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
>> -{
>> -	struct memblock_type *type = &memblock.memory;
>> -	unsigned int right = type->cnt;
>> -	unsigned int mid, left = 0;
>> -	phys_addr_t addr = PFN_PHYS(++pfn);
>> -
>> -	do {
>> -		mid = (right + left) / 2;
>> -
>> -		if (addr < type->regions[mid].base)
>> -			right = mid;
>> -		else if (addr >= (type->regions[mid].base +
>> -				  type->regions[mid].size))
>> -			left = mid + 1;
>> -		else {
>> -			/* addr is within the region, so pfn is valid */
>> -			return pfn;
>> -		}
>> -	} while (left < right);
>> -
>> -	if (right == type->cnt)
>> -		return -1UL;
>> -	else
>> -		return PHYS_PFN(type->regions[right].base);
>> -}
>> -#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
>> -
>> /**
>>   * memblock_set_node - set node ID on memblock regions
>>   * @base: base of area to set node ID for
>> @@ -1162,6 +1133,50 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>> }
>> #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>
>> +#ifdef CONFIG_HAVE_ARCH_PFN_VALID
>> +unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
>> +							int *last_idx)
>> +{
>> +	struct memblock_type *type = &memblock.memory;
>> +	unsigned int right = type->cnt;
>> +	unsigned int mid, left = 0;
>> +	unsigned long start_pfn, end_pfn;
>> +	phys_addr_t addr = PFN_PHYS(++pfn);
>> +
>> +	/* fast path, return pfh+1 if next pfn is in the same region */
>                               ^^^  pfn
Thanks
>> +	if (*last_idx != -1) {
>> +		start_pfn = PFN_DOWN(type->regions[*last_idx].base);
> To me, it should be PFN_UP().
hmm.., seems all the base of memory region is pfn aligned (0x10000 
aligned). So

PFN_UP is the same as PFN_DOWN here?
I got this logic from memblock_search_pfn_nid()

Cheers,
Jia

>
>> +		end_pfn = PFN_DOWN(type->regions[*last_idx].base +
>> +				type->regions[*last_idx].size);
>> +
>> +		if (pfn < end_pfn && pfn > start_pfn)
> Could be (pfn < end_pfn && pfn >= start_pfn)?
>
> pfn == start_pfn is also a valid address.
No, pfn=pfn+1 at the beginning, so pfn != start_pfn
>
>> +			return pfn;
>> +	}
>> +
>> +	/* slow path, do the binary searching */
>> +	do {
>> +		mid = (right + left) / 2;
>> +
>> +		if (addr < type->regions[mid].base)
>> +			right = mid;
>> +		else if (addr >= (type->regions[mid].base +
>> +				  type->regions[mid].size))
>> +			left = mid + 1;
>> +		else {
>> +			*last_idx = mid;
>> +			return pfn;
>> +		}
>> +	} while (left < right);
>> +
>> +	if (right == type->cnt)
>> +		return -1UL;
>> +
>> +	*last_idx = right;
>> +
>> +	return PHYS_PFN(type->regions[*last_idx].base);
>> +}
>> +#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
> The same comment as Daniel, you are moving the function out of
> CONFIG_HAVE_MEMBLOCK_NODE_MAP.
>> +
>> static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
>> 					phys_addr_t align, phys_addr_t start,
>> 					phys_addr_t end, int nid, ulong flags)
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 2a967f7..0bb0274 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5459,6 +5459,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>> 	unsigned long end_pfn = start_pfn + size;
>> 	pg_data_t *pgdat = NODE_DATA(nid);
>> 	unsigned long pfn;
>> +	int idx = -1;
>> 	unsigned long nr_initialised = 0;
>> 	struct page *page;
>> #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>> @@ -5490,7 +5491,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>> 			 * end_pfn), such that we hit a valid pfn (or end_pfn)
>> 			 * on our next iteration of the loop.
>> 			 */
>> -			pfn = memblock_next_valid_pfn(pfn) - 1;
>> +			pfn = memblock_next_valid_pfn(pfn, &idx) - 1;
>> #endif
>> 			continue;
>> 		}
>> -- 
>> 2.7.4
