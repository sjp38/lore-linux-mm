Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id D4DAD6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 18:57:47 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id l13so14619185iga.0
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 15:57:47 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ad2si841719igd.12.2015.01.19.15.57.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jan 2015 15:57:46 -0800 (PST)
Message-ID: <54BD99F7.8050603@codeaurora.org>
Date: Mon, 19 Jan 2015 15:57:43 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: Issue on reserving memory with no-map flag  in  DT
References: <54B8F63C.1060300@linaro.org> <54B9ABAA.9060908@codeaurora.org> <54BD279E.1040709@suse.cz>
In-Reply-To: <54BD279E.1040709@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux@arm.linux.org.uk, ssantosh@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Kevin Hilman <khilman@linaro.org>, Stephen Boyd <sboyd@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Kumar Gala <galak@codeaurora.org>, linux-mm@kvack.org

On 1/19/2015 7:49 AM, Vlastimil Babka wrote:
> On 01/17/2015 01:24 AM, Laura Abbott wrote:
>> (Adding linux-mm and relevant people because this looks like an issue there)
>>
>> On 1/16/2015 3:30 AM, Srinivas Kandagatla wrote:
>>> Hi All,
>>>
>>> I am hitting boot failures when I did try to reserve memory with no-map flag using DT. Basically kernel just hangs with no indication of whats going on. Added some debug to find out the location, it was some where while dma mapping at kmap_atomic() in __dma_clear_buffer().
>>> reserving.
>>>
>>> The issue is very much identical to http://lists.infradead.org/pipermail/linux-arm-kernel/2014-October/294773.html but the memory reserve in my case is at start of the memory. I tried the same fixes on this thread but it did not help.
>>>
>>> Platform: IFC6410 with APQ8064 which is a v7 platform with 2GB of memory starting at 0x80000000 and kernel is always loaded at 0x80200000
>>> And am using multi_v7_defconfig.
>>>
>>> Meminfo without memory reserve:
>>> 80000000-88dfffff : System RAM
>>>     80208000-80e5d307 : Kernel code
>>>     80f64000-810be397 : Kernel data
>>> 8a000000-8d9fffff : System RAM
>>> 8ec00000-8effffff : System RAM
>>> 8f700000-8fdfffff : System RAM
>>> 90000000-af7fffff : System RAM
>>>
>>> DT entry:
>>>          reserved-memory {
>>>                  #address-cells = <1>;
>>>                  #size-cells = <1>;
>>>                  ranges;
>>>                  smem@80000000 {
>>>                          reg = <0x80000000 0x200000>;
>>>                          no-map;
>>>                  };
>>>          };
>>>
>>> If I remove the no-map flag, then I can boot the board. But I dona??t want kernel to map this memory at all, as this a IPC memory.
>>>
>>> I just wanted to understand whats going on here, Am guessing that kernel would never touch that 2MB memory.
>>>
>>> Does arm-kernel has limitation on unmapping/memblock_remove() such memory locations?
>>> Or
>>> Is this a known issue?
>>>
>>> Any pointers to debug this issue?
>>>
>>> Before the kernel hangs it reports 2 errors like:
>>>
>>> BUG: Bad page state in process swapper  pfn:fffa8
>>> page:ef7fb500 count:0 mapcount:0 mapping:  (null) index:0x0
>>> flags: 0x96640253(locked|error|dirty|active|arch_1|reclaim|mlocked)
>>> page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
>>> bad because of flags:
>>> flags: 0x200041(locked|active|mlocked)
>>> Modules linked in:
>>> CPU: 0 PID: 0 Comm: swapper Not tainted 3.19.0-rc3-00007-g412f9ba-dirty #816
>>> Hardware name: Qualcomm (Flattened Device Tree)
>>> [<c0218280>] (unwind_backtrace) from [<c0212be8>] (show_stack+0x20/0x24)
>>> [<c0212be8>] (show_stack) from [<c0af7124>] (dump_stack+0x80/0x9c)
>>> [<c0af7124>] (dump_stack) from [<c0301570>] (bad_page+0xc8/0x128)
>>> [<c0301570>] (bad_page) from [<c03018a8>] (free_pages_prepare+0x168/0x1e0)
>>> [<c03018a8>] (free_pages_prepare) from [<c030369c>] (free_hot_cold_page+0x3c/0x174)
>>> [<c030369c>] (free_hot_cold_page) from [<c0303828>] (__free_pages+0x54/0x58)
>>> [<c0303828>] (__free_pages) from [<c030395c>] (free_highmem_page+0x38/0x88)
>>> [<c030395c>] (free_highmem_page) from [<c0f62d5c>] (mem_init+0x240/0x430)
>>> [<c0f62d5c>] (mem_init) from [<c0f5db3c>] (start_kernel+0x1e4/0x3c8)
>>> [<c0f5db3c>] (start_kernel) from [<80208074>] (0x80208074)
>>> Disabling lock debugging due to kernel taint
>>>
>>>
>>> Full kernel log with memblock debug at http://paste.ubuntu.com/9761000/
>>>
>>
>> I don't have an IFC handy but I was able to reproduce the same issue on another board.
>> I think this is an underlying issue in mm code.
>>
>> Removing the first 2MB changes the start address of the zone. This means the start
>> address is no longer pageblock aligned (4MB on this system). With a little
>> digging, it looks like the issue is we're running off the end of the end of the
>> mem_map array because the memmap array is too small. This is similar to
>> an issue fixed by 7c45512 mm: fix pageblock bitmap allocation and the following
>> fixes it for me:
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 7633c50..32d9436 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5012,7 +5012,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>>    #ifdef CONFIG_FLAT_NODE_MEM_MAP
>>           /* ia64 gets its own node_mem_map, before this, without bootmem */
>>           if (!pgdat->node_mem_map) {
>> -               unsigned long size, start, end;
>> +               unsigned long size, start, end, offset;
>>                   struct page *map;
>>
>>                   /*
>> @@ -5020,10 +5020,11 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>>                    * aligned but the node_mem_map endpoints must be in order
>>                    * for the buddy allocator to function correctly.
>>                    */
>> +               offset = pgdat->node_start_pfn & (pageblock_nr_pages - 1);
>>                   start = pgdat->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
>>                   end = pgdat_end_pfn(pgdat);
>>                   end = ALIGN(end, MAX_ORDER_NR_PAGES);
>> -               size =  (end - start) * sizeof(struct page);
>> +               size =  ((end - start) + offset) * sizeof(struct page);
>>                   map = alloc_remap(pgdat->node_id, size);
>>                   if (!map)
>>                           map = memblock_virt_alloc_node_nopanic(size,
>>
>> If there is agreement on this approach, I can turn this into a proper patch.
>
> I admit I may not see clearly through all the arch-specific layers and various
> config option combinations that are possible here, so I might be misinterpreting
> the code. But I think the problem here is not insufficient allocation size, but
> something else.
>
> The code above continues by this line:
>
> 		pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
>
> So, size for the map allocation has already been calculated aligned to
> MAX_ORDER_NR_PAGES before your patch, and node_mem_map points to the first
> actually present page, which might be offset from the perfect alignment. Your
> patch adds another offset to the already aligned size (but you use
> pageblock_nr_pages which might be lower than MAX_ORDER_NR_PAGES; this seems like
> a mistake in itself?). So with your patch we have map of aligned size starting
> from the node_mem_map. This means the last offset-worth of struct pages should
> be beyond what's needed to access struct page of pgdat_end_pfn(). If we need
> that extra padding to prevent crashing, then it looks really suspicious...
>
> And when I look at node_mem_map usage, I see include/asm/generic/memory_model.h
> defines __pfn_to_page as (basically)
>
> NODE_DATA(__nid)->node_mem_map + arch_local_page_offset(__pfn, __nid);\
>
> and further above is a generic definition of arch_local_page_offset:
>
> #define arch_local_page_offset(pfn, nid)        \
>          ((pfn) - NODE_DATA(nid)->node_start_pfn)
>
> So it looks correct to me without your patch. The map is allocated aligned,
> node_mem_map points to this map at the offset corresponding to node_start_pfn,
> and pfn_to_page subtracts node_start_pfn to get the offset relative to
> node_mem_map. We shouldn't need the extra padding by the node_start_pfn offset,
> unless something else is misbehaving here.
>
> In the issue fixed by 7c45512 that you refer to, the problem was basically that
> the allocation didn't use aligned size, but this looks different to me?
>
>

With this hard coded debugging:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7633c50..241b870 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5029,6 +5029,11 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
                         map = memblock_virt_alloc_node_nopanic(size,
                                                                pgdat->node_id);
                 pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
+               pr_err(">>> node_start_pfn %lx node_end_pfn %lx\n",
+                       pgdat->node_start_pfn, pgdat_end_pfn(pgdat));
+               pr_err(">>> size calculated %lx\n", size);
+               pr_err(">>> allocated region %p-%lx\n", map, ((unsigned long)map)+size);
+
         }
  #ifndef CONFIG_NEED_MULTIPLE_NODES
         /*
@@ -5043,6 +5048,8 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
         }
  #endif
  #endif /* CONFIG_FLAT_NODE_MEM_MAP */
+       pr_err(">>> pfn %lx page %p\n", 0x200, pfn_to_page(0x200));
+       pr_err(">>> pfn %lx page %p\n", 0xbffff, pfn_to_page(0xbffff));
  }
  
  void __paginginit free_area_init_node(int nid, unsigned long *zones_size,

I get this output:
[    0.000000] >>> node_start_pfn 200 node_end_pfn c0000
[    0.000000] >>> size calculated 1800000
[    0.000000] >>> allocated region edffa000-ef7fa000
[    0.000000] >>> pfn 200 page ee002000
[    0.000000] >>> pfn bffff page ef7fdfe0

The start and end pfn values are correct but that page value is outside of the
allocated region for the memory map. This is a CONFIG_FLATMEM system so we
aren't actually using arch_local_page_offset at all:


#define __pfn_to_page(pfn)      (mem_map + ((pfn) - ARCH_PFN_OFFSET))
#define __page_to_pfn(page)     ((unsigned long)((page) - mem_map) + \
                                  ARCH_PFN_OFFSET)

If you do the math, the array size is fine if we don't offset by the
start but alloc_node_mem_map offsets assuming pfn_to_page will offset
as well but this doesn't happen in CONFIG_FLATMEM.

Either alloc_node_mem_map needs to drop the offset or the pfn_to_page
functions need to start adding the offset. It's worth noting that
this gets corrected properly if we have CONFIG_HAVE_MEMBLOCK_NODE_MAP enabled
so perhaps the fix is to unoffset for flatmem as well:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7633c50..271c44b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5036,7 +5036,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
          */
         if (pgdat == NODE_DATA(0)) {
                 mem_map = NODE_DATA(0)->node_mem_map;
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+#if defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) || defined(CONFIG_FLATMEM)
                 if (page_to_pfn(mem_map) != pgdat->node_start_pfn)
                         mem_map -= (pgdat->node_start_pfn - ARCH_PFN_OFFSET);
  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
