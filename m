Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 87F87680FD0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 20:53:58 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id d9so54316984itc.4
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 17:53:58 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id b196si2697387ioa.42.2017.02.14.17.53.56
        for <linux-mm@kvack.org>;
        Tue, 14 Feb 2017 17:53:57 -0800 (PST)
Subject: Re: [PATCH] mm: free reserved area's memmap if possiable
References: <1486987349-58711-1-git-send-email-zhouxianrong@huawei.com>
 <1487055180-128750-1-git-send-email-zhouxianrong@huawei.com>
 <CAKv+Gu9NF3dS_EWi4k42Ke+aagTScu-yk+UFZ_6sG6tK5zHP2Q@mail.gmail.com>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <04630153-bc82-ac1f-2f80-344c90200732@huawei.com>
Date: Wed, 15 Feb 2017 09:44:25 +0800
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu9NF3dS_EWi4k42Ke+aagTScu-yk+UFZ_6sG6tK5zHP2Q@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mark Rutland <mark.rutland@arm.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, srikar@linux.vnet.ibm.com, Mi.Sophia.Wang@huawei.com, Will Deacon <will.deacon@arm.com>, zhangshiming5@huawei.com, zijun_hu@htc.com, Jisheng Zhang <jszhang@marvell.com>, won.ho.park@huawei.com, Alexander
 Kuleshov <kuleshovmail@gmail.com>, chengang@emindsoft.com.cn, zhouxiyu@huawei.com, tj@kernel.org, weidu.du@huawei.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Steve Capper <steve.capper@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Dennis Chen <dennis.chen@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>



On 2017/2/14 17:03, Ard Biesheuvel wrote:
> On 14 February 2017 at 06:53,  <zhouxianrong@huawei.com> wrote:
>> From: zhouxianrong <zhouxianrong@huawei.com>
>>
>> just like freeing no-map area's memmap (gaps of memblock.memory)
>> we could free reserved area's memmap (areas of memblock.reserved)
>> as well only when user of reserved area indicate that we can do
>> this in drivers. that is, user of reserved area know how to
>> use the reserved area who could not memblock_free or free_reserved_xxx
>> the reserved area and regard the area as raw pfn usage by kernel.
>> the patch supply a way to users who want to utilize the memmap
>> memory corresponding to raw pfn reserved areas as many as possible.
>> users can do this by memblock_mark_raw_pfn interface which mark the
>> reserved area as raw pfn and tell free_unused_memmap that this area's
>> memmap could be freeed.
>>
>
> Could you give an example how much memory we actually recover by doing
> this? I understand it depends on the size of the reserved regions, but
> I'm sure you have an actual example that inspired you to write this
> patch.

i did statistics in our platform, the memmap of reserved region that can be freed
is about 6MB. it's fewer.

>
>> Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
>> ---
>>  arch/arm64/mm/init.c     |   14 +++++++++++++-
>>  include/linux/memblock.h |    3 +++
>>  mm/memblock.c            |   24 ++++++++++++++++++++++++
>>  3 files changed, 40 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>> index 380ebe7..7e62ef8 100644
>> --- a/arch/arm64/mm/init.c
>> +++ b/arch/arm64/mm/init.c
>> @@ -358,7 +358,7 @@ static inline void free_memmap(unsigned long start_pfn, unsigned long end_pfn)
>>   */
>>  static void __init free_unused_memmap(void)
>>  {
>> -       unsigned long start, prev_end = 0;
>> +       unsigned long start, end, prev_end = 0;
>>         struct memblock_region *reg;
>>
>>         for_each_memblock(memory, reg) {
>> @@ -391,6 +391,18 @@ static void __init free_unused_memmap(void)
>>         if (!IS_ALIGNED(prev_end, PAGES_PER_SECTION))
>>                 free_memmap(prev_end, ALIGN(prev_end, PAGES_PER_SECTION));
>>  #endif
>> +
>> +       for_each_memblock(reserved, reg) {
>> +               if (!(reg->flags & MEMBLOCK_RAW_PFN))
>> +                       continue;
>> +
>> +               start = memblock_region_memory_base_pfn(reg);
>> +               end = round_down(memblock_region_memory_end_pfn(reg),
>> +                                MAX_ORDER_NR_PAGES);
>> +
>
> Why are you rounding down end only? Shouldn't you round up start and
> round down end? Or does free_memmap() deal with that already?

ok, i could round up start.

>
> In any case, it is good to emphasize that on 4 KB pagesize kernels, we
> will only free multiples of 8 MB that are 8 MB aligned, resulting in
> 128 KB of memmap backing to be released.


>
>
>> +               if (start < end)
>> +                       free_memmap(start, end);
>> +       }
>>  }
>>  #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
>>
>> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>> index 5b759c9..9f8d277 100644
>> --- a/include/linux/memblock.h
>> +++ b/include/linux/memblock.h
>> @@ -26,6 +26,7 @@ enum {
>>         MEMBLOCK_HOTPLUG        = 0x1,  /* hotpluggable region */
>>         MEMBLOCK_MIRROR         = 0x2,  /* mirrored region */
>>         MEMBLOCK_NOMAP          = 0x4,  /* don't add to kernel direct mapping */
>> +       MEMBLOCK_RAW_PFN        = 0x8,  /* region whose memmap never be used */
>
> I think we should be *very* careful about the combinatorial explosion
> that results when combining all these flags, given that this is not a
> proper enum but a bit field.
>
> In any case, the generic memblock change should be in a separate patch
> from the arm64 change.

MEMBLOCK_RAW_PFN and MEMBLOCK_NOMAP can not be set at the same time

>
>>  };
>>
>>  struct memblock_region {
>> @@ -92,6 +93,8 @@ bool memblock_overlaps_region(struct memblock_type *type,
>>  int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
>>  int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
>>  int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
>> +int memblock_mark_raw_pfn(phys_addr_t base, phys_addr_t size);
>> +int memblock_clear_raw_pfn(phys_addr_t base, phys_addr_t size);
>>  ulong choose_memblock_flags(void);
>>
>>  /* Low level functions */
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 7608bc3..c103b94 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -814,6 +814,30 @@ int __init_memblock memblock_mark_nomap(phys_addr_t base, phys_addr_t size)
>>  }
>>
>>  /**
>> + * memblock_mark_raw_pfn - Mark raw pfn memory with flag MEMBLOCK_RAW_PFN.
>> + * @base: the base phys addr of the region
>> + * @size: the size of the region
>> + *
>> + * Return 0 on succees, -errno on failure.
>> + */
>> +int __init_memblock memblock_mark_raw_pfn(phys_addr_t base, phys_addr_t size)
>> +{
>> +       return memblock_setclr_flag(base, size, 1, MEMBLOCK_RAW_PFN);
>> +}
>> +
>> +/**
>> + * memblock_clear_raw_pfn - Clear flag MEMBLOCK_RAW_PFN for a specified region.
>> + * @base: the base phys addr of the region
>> + * @size: the size of the region
>> + *
>> + * Return 0 on succees, -errno on failure.
>> + */
>> +int __init_memblock memblock_clear_raw_pfn(phys_addr_t base, phys_addr_t size)
>> +{
>> +       return memblock_setclr_flag(base, size, 0, MEMBLOCK_RAW_PFN);
>> +}
>> +
>> +/**
>>   * __next_reserved_mem_region - next function for for_each_reserved_region()
>>   * @idx: pointer to u64 loop variable
>>   * @out_start: ptr to phys_addr_t for start address of the region, can be %NULL
>> --
>> 1.7.9.5
>>
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
