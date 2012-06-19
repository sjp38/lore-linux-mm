Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 1C0706B0072
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 17:21:08 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so12649948pbb.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:21:07 -0700 (PDT)
Date: Tue, 19 Jun 2012 14:20:59 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: Early boot panic on machine with lots of memory
Message-ID: <20120619212059.GJ32733@google.com>
References: <1339623535.3321.4.camel@lappy>
 <20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
 <1339667440.3321.7.camel@lappy>
 <20120618223203.GE32733@google.com>
 <1340059850.3416.3.camel@lappy>
 <20120619041154.GA28651@shangw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120619041154.GA28651@shangw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello, guys.

On Tue, Jun 19, 2012 at 12:11:54PM +0800, Gavin Shan wrote:
> Here, [0x0000102febc080-0x0000102febf080] was released to available memory block
> by function free_low_memory_core_early(). I'm not sure the release memblock might
> be taken by bootmem, but I think it's worthy to have a try of removing following
> 2 lines: memblock_free_reserved_regions() and memblock_reserve_reserved_regions()
> 
> unsigned long __init free_low_memory_core_early(int nodeid)
> {
>         unsigned long count = 0;
>         phys_addr_t start, end;
>         u64 i;
> 
>         /* free reserved array temporarily so that it's treated as free area */
>         /* memblock_free_reserved_regions(); -REMOVED */
> 
>         for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL) {
>                 unsigned long start_pfn = PFN_UP(start);
>                 unsigned long end_pfn = min_t(unsigned long,
>                                               PFN_DOWN(end), max_low_pfn);
>                 if (start_pfn < end_pfn) {
>                         __free_pages_memory(start_pfn, end_pfn);
>                         count += end_pfn - start_pfn;
>                 }
>         }
> 
>         /* put region array back? */
>         /* memblock_reserve_reserved_regions(); -REMOVED */
> 
>         return count;
> }

I think I figured out what's going on.  Sasha, your kernel has
CONFIG_DEBUG_PAGEALLOC enabled, right?  __free_pages_memory() hands
the memory area to the buddy page allocator which marks the pages
not-present in the page table if CONFIG_DEBUG_PAGEALLOC is set by
calling kernel_map_pages().  reserved array doesn't tend to be too big
and ends up surrounded by other reserved areas to avoid being returned
to page allocator but on your setup it ends up being doubled towards
the end of the boot process and gets unmapped triggering page fault on
the following attempt to access the table.

Something like the following should fix it.

diff --git a/mm/memblock.c b/mm/memblock.c
index 32a0a5e..2770970 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -148,11 +148,15 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
  */
 int __init_memblock memblock_free_reserved_regions(void)
 {
+#ifndef CONFIG_DEBUG_PAGEALLOC
 	if (memblock.reserved.regions == memblock_reserved_init_regions)
 		return 0;
 
 	return memblock_free(__pa(memblock.reserved.regions),
 		 sizeof(struct memblock_region) * memblock.reserved.max);
+#else
+	return 0;
+#endif
 }
 
 /*
@@ -160,11 +164,15 @@ int __init_memblock memblock_free_reserved_regions(void)
  */
 int __init_memblock memblock_reserve_reserved_regions(void)
 {
+#ifndef COFNIG_DEBUG_PAGEALLOC
 	if (memblock.reserved.regions == memblock_reserved_init_regions)
 		return 0;
 
 	return memblock_reserve(__pa(memblock.reserved.regions),
 		 sizeof(struct memblock_region) * memblock.reserved.max);
+#else
+	return 0;
+#endif
 }
 
 static void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
