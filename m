Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 999BA6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 19:24:15 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id ar1so1234434iec.4
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 16:24:15 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id h14si7799943ice.63.2015.01.16.16.24.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 16:24:14 -0800 (PST)
Message-ID: <54B9ABAA.9060908@codeaurora.org>
Date: Fri, 16 Jan 2015 16:24:10 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: Issue on reserving memory with no-map flag  in  DT
References: <54B8F63C.1060300@linaro.org>
In-Reply-To: <54B8F63C.1060300@linaro.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux@arm.linux.org.uk, ssantosh@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Kevin Hilman <khilman@linaro.org>, Stephen Boyd <sboyd@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Kumar Gala <galak@codeaurora.org>, linux-mm@kvack.org

(Adding linux-mm and relevant people because this looks like an issue there)

On 1/16/2015 3:30 AM, Srinivas Kandagatla wrote:
> Hi All,
>
> I am hitting boot failures when I did try to reserve memory with no-map flag using DT. Basically kernel just hangs with no indication of whats going on. Added some debug to find out the location, it was some where while dma mapping at kmap_atomic() in __dma_clear_buffer().
> reserving.
>
> The issue is very much identical to http://lists.infradead.org/pipermail/linux-arm-kernel/2014-October/294773.html but the memory reserve in my case is at start of the memory. I tried the same fixes on this thread but it did not help.
>
> Platform: IFC6410 with APQ8064 which is a v7 platform with 2GB of memory starting at 0x80000000 and kernel is always loaded at 0x80200000
> And am using multi_v7_defconfig.
>
> Meminfo without memory reserve:
> 80000000-88dfffff : System RAM
>    80208000-80e5d307 : Kernel code
>    80f64000-810be397 : Kernel data
> 8a000000-8d9fffff : System RAM
> 8ec00000-8effffff : System RAM
> 8f700000-8fdfffff : System RAM
> 90000000-af7fffff : System RAM
>
> DT entry:
>         reserved-memory {
>                 #address-cells = <1>;
>                 #size-cells = <1>;
>                 ranges;
>                 smem@80000000 {
>                         reg = <0x80000000 0x200000>;
>                         no-map;
>                 };
>         };
>
> If I remove the no-map flag, then I can boot the board. But I dona??t want kernel to map this memory at all, as this a IPC memory.
>
> I just wanted to understand whats going on here, Am guessing that kernel would never touch that 2MB memory.
>
> Does arm-kernel has limitation on unmapping/memblock_remove() such memory locations?
> Or
> Is this a known issue?
>
> Any pointers to debug this issue?
>
> Before the kernel hangs it reports 2 errors like:
>
> BUG: Bad page state in process swapper  pfn:fffa8
> page:ef7fb500 count:0 mapcount:0 mapping:  (null) index:0x0
> flags: 0x96640253(locked|error|dirty|active|arch_1|reclaim|mlocked)
> page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> bad because of flags:
> flags: 0x200041(locked|active|mlocked)
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper Not tainted 3.19.0-rc3-00007-g412f9ba-dirty #816
> Hardware name: Qualcomm (Flattened Device Tree)
> [<c0218280>] (unwind_backtrace) from [<c0212be8>] (show_stack+0x20/0x24)
> [<c0212be8>] (show_stack) from [<c0af7124>] (dump_stack+0x80/0x9c)
> [<c0af7124>] (dump_stack) from [<c0301570>] (bad_page+0xc8/0x128)
> [<c0301570>] (bad_page) from [<c03018a8>] (free_pages_prepare+0x168/0x1e0)
> [<c03018a8>] (free_pages_prepare) from [<c030369c>] (free_hot_cold_page+0x3c/0x174)
> [<c030369c>] (free_hot_cold_page) from [<c0303828>] (__free_pages+0x54/0x58)
> [<c0303828>] (__free_pages) from [<c030395c>] (free_highmem_page+0x38/0x88)
> [<c030395c>] (free_highmem_page) from [<c0f62d5c>] (mem_init+0x240/0x430)
> [<c0f62d5c>] (mem_init) from [<c0f5db3c>] (start_kernel+0x1e4/0x3c8)
> [<c0f5db3c>] (start_kernel) from [<80208074>] (0x80208074)
> Disabling lock debugging due to kernel taint
>
>
> Full kernel log with memblock debug at http://paste.ubuntu.com/9761000/
>

I don't have an IFC handy but I was able to reproduce the same issue on another board.
I think this is an underlying issue in mm code.

Removing the first 2MB changes the start address of the zone. This means the start
address is no longer pageblock aligned (4MB on this system). With a little
digging, it looks like the issue is we're running off the end of the end of the
mem_map array because the memmap array is too small. This is similar to
an issue fixed by 7c45512 mm: fix pageblock bitmap allocation and the following
fixes it for me:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7633c50..32d9436 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5012,7 +5012,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
  #ifdef CONFIG_FLAT_NODE_MEM_MAP
         /* ia64 gets its own node_mem_map, before this, without bootmem */
         if (!pgdat->node_mem_map) {
-               unsigned long size, start, end;
+               unsigned long size, start, end, offset;
                 struct page *map;
  
                 /*
@@ -5020,10 +5020,11 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
                  * aligned but the node_mem_map endpoints must be in order
                  * for the buddy allocator to function correctly.
                  */
+               offset = pgdat->node_start_pfn & (pageblock_nr_pages - 1);
                 start = pgdat->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
                 end = pgdat_end_pfn(pgdat);
                 end = ALIGN(end, MAX_ORDER_NR_PAGES);
-               size =  (end - start) * sizeof(struct page);
+               size =  ((end - start) + offset) * sizeof(struct page);
                 map = alloc_remap(pgdat->node_id, size);
                 if (!map)
                         map = memblock_virt_alloc_node_nopanic(size,

If there is agreement on this approach, I can turn this into a proper patch.

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
