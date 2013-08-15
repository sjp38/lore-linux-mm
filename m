Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 508C06B004D
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 01:46:28 -0400 (EDT)
From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH] memblock, numa: Binary search node id
Date: Wed, 14 Aug 2013 22:46:29 -0700
Message-Id: <1376545589-32129-1-git-send-email-yinghai@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>
Cc: Russ Anderson <rja@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>

Current early_pfn_to_nid() on arch that support memblock go
over memblock.memory one by one, so will take too many try
near the end.

We can use existing memblock_search to find the node id for
given pfn, that could save some time on bigger system that
have many entries memblock.memory array.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 include/linux/memblock.h |    2 ++
 mm/memblock.c            |   18 ++++++++++++++++++
 mm/page_alloc.c          |   19 +++++++++----------
 3 files changed, 29 insertions(+), 10 deletions(-)

Index: linux-2.6/include/linux/memblock.h
===================================================================
--- linux-2.6.orig/include/linux/memblock.h
+++ linux-2.6/include/linux/memblock.h
@@ -60,6 +60,8 @@ int memblock_reserve(phys_addr_t base, p
 void memblock_trim_memory(phys_addr_t align);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
+			    unsigned long  *end_pfn);
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 			  unsigned long *out_end_pfn, int *out_nid);
 
Index: linux-2.6/mm/memblock.c
===================================================================
--- linux-2.6.orig/mm/memblock.c
+++ linux-2.6/mm/memblock.c
@@ -914,6 +914,24 @@ int __init_memblock memblock_is_memory(p
 	return memblock_search(&memblock.memory, addr) != -1;
 }
 
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
+			 unsigned long *start_pfn, unsigned long *end_pfn)
+{
+	struct memblock_type *type = &memblock.memory;
+	int mid = memblock_search(type, (phys_addr_t)pfn << PAGE_SHIFT);
+
+	if (mid == -1)
+		return -1;
+
+	*start_pfn = type->regions[mid].base >> PAGE_SHIFT;
+	*end_pfn = (type->regions[mid].base + type->regions[mid].size)
+			>> PAGE_SHIFT;
+
+	return type->regions[mid].nid;
+}
+#endif
+
 /**
  * memblock_is_region_memory - check if a region is a subset of memory
  * @base: base of region to check
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -4186,7 +4186,7 @@ int __meminit init_currently_empty_zone(
 int __meminit __early_pfn_to_nid(unsigned long pfn)
 {
 	unsigned long start_pfn, end_pfn;
-	int i, nid;
+	int nid;
 	/*
 	 * NOTE: The following SMP-unsafe globals are only used early in boot
 	 * when the kernel is running single-threaded.
@@ -4197,15 +4197,14 @@ int __meminit __early_pfn_to_nid(unsigne
 	if (last_start_pfn <= pfn && pfn < last_end_pfn)
 		return last_nid;
 
-	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
-		if (start_pfn <= pfn && pfn < end_pfn) {
-			last_start_pfn = start_pfn;
-			last_end_pfn = end_pfn;
-			last_nid = nid;
-			return nid;
-		}
-	/* This is a memory hole */
-	return -1;
+	nid = memblock_search_pfn_nid(pfn, &start_pfn, &end_pfn);
+	if (nid != -1) {
+		last_start_pfn = start_pfn;
+		last_end_pfn = end_pfn;
+		last_nid = nid;
+	}
+
+	return nid;
 }
 #endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
