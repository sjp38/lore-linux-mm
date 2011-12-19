Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 3CC1F6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 08:58:18 -0500 (EST)
Received: by eekc41 with SMTP id c41so6194804eek.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 05:58:16 -0800 (PST)
Message-ID: <4EEF42F5.7040002@monstr.eu>
Date: Mon, 19 Dec 2011 14:58:13 +0100
From: Michal Simek <monstr@monstr.eu>
Reply-To: monstr@monstr.eu
MIME-Version: 1.0
Subject: memblock and bootmem problems if start + size = 4GB
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Sam Ravnborg <sam@ravnborg.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,

I have reached some problems with memblock and bootmem code for some configurations.
We can completely setup the whole system and all addresses in it.
The problem happens if we place main memory to the end of address space when
mem_start + size reach 4GB limit.

For example:
mem_start      0xF000 0000
mem_size       0x1000 0000 (or better lowmem size)
mem_end        0xFFFF FFFF
start + size 0x1 0000 0000 (u32 limit reached).

I have done some patches which completely remove start + size values from architecture specific
code but I have found some problem in generic code too.

For example in bootmem code where are three places where physaddr + size is used.
I would prefer to retype it to u64 because baseaddr and size don't need to be 2^n.

Is it correct solution? If yes, I will create proper patch.

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 1a77012..45a691a 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -371,7 +371,7 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
         kmemleak_free_part(__va(physaddr), size);

         start = PFN_UP(physaddr);
-       end = PFN_DOWN(physaddr + size);
+       end = PFN_DOWN((u64)physaddr + (u64)size);

         mark_bootmem_node(pgdat->bdata, start, end, 0, 0);
  }
@@ -414,7 +414,7 @@ int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
         unsigned long start, end;

         start = PFN_DOWN(physaddr);
-       end = PFN_UP(physaddr + size);
+       end = PFN_UP((u64)physaddr + (u64)size);

         return mark_bootmem_node(pgdat->bdata, start, end, 1, flags);
  }
@@ -435,7 +435,7 @@ int __init reserve_bootmem(unsigned long addr, unsigned long size,
         unsigned long start, end;

         start = PFN_DOWN(addr);
-       end = PFN_UP(addr + size);
+       end = PFN_UP((u64)addr + (u64)size);

         return mark_bootmem(start, end, 1, flags);
  }



The similar problem is with memblock code.

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index e6b843e..55d5279 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -127,7 +127,7 @@ static inline unsigned long memblock_region_memory_base_pfn(const struct membloc
   */
  static inline unsigned long memblock_region_memory_end_pfn(const struct memblock_region *reg)
  {
-       return PFN_DOWN(reg->base + reg->size);
+       return PFN_DOWN((u64)reg->base + (u64)reg->size);
  }

  /**
@@ -145,7 +145,7 @@ static inline unsigned long memblock_region_reserved_base_pfn(const struct membl
   */
  static inline unsigned long memblock_region_reserved_end_pfn(const struct memblock_region *reg)
  {
-       return PFN_UP(reg->base + reg->size);
+       return PFN_UP((u64)reg->base + (u64)reg->size);
  }

  #define for_each_memblock(memblock_type, region)                                       \


Plus fixing two conditions in memblock_find_base for the same reasons.

diff --git a/mm/memblock.c b/mm/memblock.c
index 84bec49..6c443bd 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -131,10 +131,10 @@ static phys_addr_t __init_memblock memblock_find_base(phys_addr_t size,

                 if (memblocksize < size)
                         continue;
-               if ((memblockbase + memblocksize) <= start)
+               if ((memblockbase + memblocksize - 1) <= start)
                         break;
                 bottom = max(memblockbase, start);
-               top = min(memblockbase + memblocksize, end);
+               top = min(memblockbase + memblocksize - 1, end);
                 if (bottom >= top)
                         continue;
                 found = memblock_find_region(bottom, top, size, align);


Thanks,
Michal



-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
