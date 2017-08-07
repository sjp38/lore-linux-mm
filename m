Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 50C576B0387
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 16:39:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m80so2214768wmd.4
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 13:39:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e8si5133387edc.547.2017.08.07.13.39.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 13:39:49 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v6 04/15] mm: discard memblock data later
Date: Mon,  7 Aug 2017 16:38:38 -0400
Message-Id: <1502138329-123460-5-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

There is existing use after free bug when deferred struct pages are
enabled:

The memblock_add() allocates memory for the memory array if more than
128 entries are needed.  See comment in e820__memblock_setup():

  * The bootstrap memblock region count maximum is 128 entries
  * (INIT_MEMBLOCK_REGIONS), but EFI might pass us more E820 entries
  * than that - so allow memblock resizing.

This memblock memory is freed here:
        free_low_memory_core_early()

We access the freed memblock.memory later in boot when deferred pages are
initialized in this path:

        deferred_init_memmap()
                for_each_mem_pfn_range()
                  __next_mem_pfn_range()
                    type = &memblock.memory;

One possible explanation for why this use-after-free hasn't been hit
before is that the limit of INIT_MEMBLOCK_REGIONS has never been exceeded
at least on systems where deferred struct pages were enabled.

Another reason why we want this problem fixed in this patch series is,
in the next patch, we will need to access memblock.reserved from
deferred_init_memmap().

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 include/linux/memblock.h |  6 ++++--
 mm/memblock.c            | 38 +++++++++++++++++---------------------
 mm/nobootmem.c           | 16 ----------------
 mm/page_alloc.c          |  4 ++++
 4 files changed, 25 insertions(+), 39 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 77d427974f57..bae11c7e7bf3 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -61,6 +61,7 @@ extern int memblock_debug;
 #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
 #define __init_memblock __meminit
 #define __initdata_memblock __meminitdata
+void memblock_discard(void);
 #else
 #define __init_memblock
 #define __initdata_memblock
@@ -74,8 +75,6 @@ phys_addr_t memblock_find_in_range_node(phys_addr_t size, phys_addr_t align,
 					int nid, ulong flags);
 phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
 				   phys_addr_t size, phys_addr_t align);
-phys_addr_t get_allocated_memblock_reserved_regions_info(phys_addr_t *addr);
-phys_addr_t get_allocated_memblock_memory_regions_info(phys_addr_t *addr);
 void memblock_allow_resize(void);
 int memblock_add_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_add(phys_addr_t base, phys_addr_t size);
@@ -110,6 +109,9 @@ void __next_mem_range_rev(u64 *idx, int nid, ulong flags,
 void __next_reserved_mem_region(u64 *idx, phys_addr_t *out_start,
 				phys_addr_t *out_end);
 
+void __memblock_free_early(phys_addr_t base, phys_addr_t size);
+void __memblock_free_late(phys_addr_t base, phys_addr_t size);
+
 /**
  * for_each_mem_range - iterate through memblock areas from type_a and not
  * included in type_b. Or just type_a if type_b is NULL.
diff --git a/mm/memblock.c b/mm/memblock.c
index 2cb25fe4452c..bf14aea6ab70 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -285,31 +285,27 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 }
 
 #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
-
-phys_addr_t __init_memblock get_allocated_memblock_reserved_regions_info(
-					phys_addr_t *addr)
-{
-	if (memblock.reserved.regions == memblock_reserved_init_regions)
-		return 0;
-
-	*addr = __pa(memblock.reserved.regions);
-
-	return PAGE_ALIGN(sizeof(struct memblock_region) *
-			  memblock.reserved.max);
-}
-
-phys_addr_t __init_memblock get_allocated_memblock_memory_regions_info(
-					phys_addr_t *addr)
+/**
+ * Discard memory and reserved arrays if they were allocated
+ */
+void __init memblock_discard(void)
 {
-	if (memblock.memory.regions == memblock_memory_init_regions)
-		return 0;
+	phys_addr_t addr, size;
 
-	*addr = __pa(memblock.memory.regions);
+	if (memblock.reserved.regions != memblock_reserved_init_regions) {
+		addr = __pa(memblock.reserved.regions);
+		size = PAGE_ALIGN(sizeof(struct memblock_region) *
+				  memblock.reserved.max);
+		__memblock_free_late(addr, size);
+	}
 
-	return PAGE_ALIGN(sizeof(struct memblock_region) *
-			  memblock.memory.max);
+	if (memblock.memory.regions == memblock_memory_init_regions) {
+		addr = __pa(memblock.memory.regions);
+		size = PAGE_ALIGN(sizeof(struct memblock_region) *
+				  memblock.memory.max);
+		__memblock_free_late(addr, size);
+	}
 }
-
 #endif
 
 /**
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 36454d0f96ee..3637809a18d0 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -146,22 +146,6 @@ static unsigned long __init free_low_memory_core_early(void)
 				NULL)
 		count += __free_memory_core(start, end);
 
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
-	{
-		phys_addr_t size;
-
-		/* Free memblock.reserved array if it was allocated */
-		size = get_allocated_memblock_reserved_regions_info(&start);
-		if (size)
-			count += __free_memory_core(start, start + size);
-
-		/* Free memblock.memory array if it was allocated */
-		size = get_allocated_memblock_memory_regions_info(&start);
-		if (size)
-			count += __free_memory_core(start, start + size);
-	}
-#endif
-
 	return count;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fc32aa81f359..63d16c185736 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1584,6 +1584,10 @@ void __init page_alloc_init_late(void)
 	/* Reinit limits that are based on free pages after the kernel is up */
 	files_maxfiles_init();
 #endif
+#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+	/* Discard memblock private memory */
+	memblock_discard();
+#endif
 
 	for_each_populated_zone(zone)
 		set_zone_contiguous(zone);
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
