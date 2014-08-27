Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id EE9B16B0035
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 23:45:23 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so23582930pde.23
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 20:45:23 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id db4si6741589pdb.240.2014.08.26.20.45.22
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 20:45:23 -0700 (PDT)
Date: Wed, 27 Aug 2014 11:41:29 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 2111/2346] mm/nobootmem.c:122:28: note: in expansion of macro 'ULLONG_MAX'
Message-ID: <53fd5369.uS9oxLCxNZ6nReEc%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   1c9e4561f3b2afffcda007eae9d0ddd25525f50e
commit: 6e162b4c49f7fad5a82d57c8fa4afc4c7103e1f8 [2111/2346] mem-hotplug: let memblock skip the hotpluggable memory regions in __next_mem_range()
config: make ARCH=arm footbridge_defconfig

All warnings:

   In file included from include/asm-generic/bug.h:13:0,
                    from arch/arm/include/asm/bug.h:61,
                    from include/linux/bug.h:4,
                    from include/linux/thread_info.h:11,
                    from include/asm-generic/preempt.h:4,
                    from arch/arm/include/generated/asm/preempt.h:1,
                    from include/linux/preempt.h:18,
                    from include/linux/spinlock.h:50,
                    from include/linux/mmzone.h:7,
                    from include/linux/gfp.h:5,
                    from include/linux/slab.h:14,
                    from mm/nobootmem.c:13:
   mm/nobootmem.c: In function 'free_low_memory_core_early':
>> include/linux/kernel.h:29:20: warning: large integer implicitly truncated to unsigned type [-Woverflow]
    #define ULLONG_MAX (~0ULL)
                       ^
>> mm/nobootmem.c:122:28: note: in expansion of macro 'ULLONG_MAX'
     memblock_clear_hotplug(0, ULLONG_MAX);
                               ^

vim +/ULLONG_MAX +122 mm/nobootmem.c

     7	 *
     8	 * Access to this subsystem has to be serialized externally (which is true
     9	 * for the boot process anyway).
    10	 */
    11	#include <linux/init.h>
    12	#include <linux/pfn.h>
  > 13	#include <linux/slab.h>
    14	#include <linux/bootmem.h>
    15	#include <linux/export.h>
    16	#include <linux/kmemleak.h>
    17	#include <linux/range.h>
    18	#include <linux/memblock.h>
    19	
    20	#include <asm/bug.h>
    21	#include <asm/io.h>
    22	#include <asm/processor.h>
    23	
    24	#include "internal.h"
    25	
    26	#ifndef CONFIG_NEED_MULTIPLE_NODES
    27	struct pglist_data __refdata contig_page_data;
    28	EXPORT_SYMBOL(contig_page_data);
    29	#endif
    30	
    31	unsigned long max_low_pfn;
    32	unsigned long min_low_pfn;
    33	unsigned long max_pfn;
    34	
    35	static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
    36						u64 goal, u64 limit)
    37	{
    38		void *ptr;
    39		u64 addr;
    40	
    41		if (limit > memblock.current_limit)
    42			limit = memblock.current_limit;
    43	
    44		addr = memblock_find_in_range_node(size, align, goal, limit, nid);
    45		if (!addr)
    46			return NULL;
    47	
    48		if (memblock_reserve(addr, size))
    49			return NULL;
    50	
    51		ptr = phys_to_virt(addr);
    52		memset(ptr, 0, size);
    53		/*
    54		 * The min_count is set to 0 so that bootmem allocated blocks
    55		 * are never reported as leaks.
    56		 */
    57		kmemleak_alloc(ptr, size, 0, 0);
    58		return ptr;
    59	}
    60	
    61	/*
    62	 * free_bootmem_late - free bootmem pages directly to page allocator
    63	 * @addr: starting address of the range
    64	 * @size: size of the range in bytes
    65	 *
    66	 * This is only useful when the bootmem allocator has already been torn
    67	 * down, but we are still initializing the system.  Pages are given directly
    68	 * to the page allocator, no bootmem metadata is updated because it is gone.
    69	 */
    70	void __init free_bootmem_late(unsigned long addr, unsigned long size)
    71	{
    72		unsigned long cursor, end;
    73	
    74		kmemleak_free_part(__va(addr), size);
    75	
    76		cursor = PFN_UP(addr);
    77		end = PFN_DOWN(addr + size);
    78	
    79		for (; cursor < end; cursor++) {
    80			__free_pages_bootmem(pfn_to_page(cursor), 0);
    81			totalram_pages++;
    82		}
    83	}
    84	
    85	static void __init __free_pages_memory(unsigned long start, unsigned long end)
    86	{
    87		int order;
    88	
    89		while (start < end) {
    90			order = min(MAX_ORDER - 1UL, __ffs(start));
    91	
    92			while (start + (1UL << order) > end)
    93				order--;
    94	
    95			__free_pages_bootmem(pfn_to_page(start), order);
    96	
    97			start += (1UL << order);
    98		}
    99	}
   100	
   101	static unsigned long __init __free_memory_core(phys_addr_t start,
   102					 phys_addr_t end)
   103	{
   104		unsigned long start_pfn = PFN_UP(start);
   105		unsigned long end_pfn = min_t(unsigned long,
   106					      PFN_DOWN(end), max_low_pfn);
   107	
   108		if (start_pfn > end_pfn)
   109			return 0;
   110	
   111		__free_pages_memory(start_pfn, end_pfn);
   112	
   113		return end_pfn - start_pfn;
   114	}
   115	
   116	static unsigned long __init free_low_memory_core_early(void)
   117	{
   118		unsigned long count = 0;
   119		phys_addr_t start, end;
   120		u64 i;
   121	
 > 122		memblock_clear_hotplug(0, ULLONG_MAX);
   123	
   124		for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
   125			count += __free_memory_core(start, end);

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
