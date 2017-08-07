Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE97F6B0387
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 16:39:50 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t37so6610147qtg.6
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 13:39:50 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g13si5357007qtg.545.2017.08.07.13.39.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 13:39:49 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v6 05/15] mm: don't accessed uninitialized struct pages
Date: Mon,  7 Aug 2017 16:38:39 -0400
Message-Id: <1502138329-123460-6-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

In deferred_init_memmap() where all deferred struct pages are initialized
we have a check like this:

    if (page->flags) {
            VM_BUG_ON(page_zone(page) != zone);
            goto free_range;
    }

This way we are checking if the current deferred page has already been
initialized. It works, because memory for struct pages has been zeroed, and
the only way flags are not zero if it went through __init_single_page()
before.  But, once we change the current behavior and won't zero the memory
in memblock allocator, we cannot trust anything inside "struct page"es
until they are initialized. This patch fixes this.

This patch defines a new accessor memblock_get_reserved_pfn_range()
which returns successive ranges of reserved PFNs.  deferred_init_memmap()
calls it to determine if a PFN and its struct page has already been
initialized.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 include/linux/memblock.h |  3 +++
 mm/memblock.c            | 54 ++++++++++++++++++++++++++++++++++++++++++------
 mm/page_alloc.c          | 11 +++++++++-
 3 files changed, 61 insertions(+), 7 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index bae11c7e7bf3..b6a2a610f5e1 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -320,6 +320,9 @@ int memblock_is_map_memory(phys_addr_t addr);
 int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
 bool memblock_is_reserved(phys_addr_t addr);
 bool memblock_is_region_reserved(phys_addr_t base, phys_addr_t size);
+void memblock_get_reserved_pfn_range(unsigned long pfn,
+				     unsigned long *pfn_start,
+				     unsigned long *pfn_end);
 
 extern void __memblock_dump_all(void);
 
diff --git a/mm/memblock.c b/mm/memblock.c
index bf14aea6ab70..08f449acfdd1 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1580,7 +1580,13 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
 	memblock_cap_memory_range(0, max_addr);
 }
 
-static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
+/**
+ * Return index in regions array if addr is within the region. Otherwise
+ * return -1. If -1 is returned and *next_idx is not %NULL, sets it to the
+ * next region index or -1 if there is none.
+ */
+static int __init_memblock memblock_search(struct memblock_type *type,
+					   phys_addr_t addr, int *next_idx)
 {
 	unsigned int left = 0, right = type->cnt;
 
@@ -1595,22 +1601,26 @@ static int __init_memblock memblock_search(struct memblock_type *type, phys_addr
 		else
 			return mid;
 	} while (left < right);
+
+	if (next_idx)
+		*next_idx = (right == type->cnt) ? -1 : right;
+
 	return -1;
 }
 
 bool __init memblock_is_reserved(phys_addr_t addr)
 {
-	return memblock_search(&memblock.reserved, addr) != -1;
+	return memblock_search(&memblock.reserved, addr, NULL) != -1;
 }
 
 bool __init_memblock memblock_is_memory(phys_addr_t addr)
 {
-	return memblock_search(&memblock.memory, addr) != -1;
+	return memblock_search(&memblock.memory, addr, NULL) != -1;
 }
 
 int __init_memblock memblock_is_map_memory(phys_addr_t addr)
 {
-	int i = memblock_search(&memblock.memory, addr);
+	int i = memblock_search(&memblock.memory, addr, NULL);
 
 	if (i == -1)
 		return false;
@@ -1622,7 +1632,7 @@ int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
 			 unsigned long *start_pfn, unsigned long *end_pfn)
 {
 	struct memblock_type *type = &memblock.memory;
-	int mid = memblock_search(type, PFN_PHYS(pfn));
+	int mid = memblock_search(type, PFN_PHYS(pfn), NULL);
 
 	if (mid == -1)
 		return -1;
@@ -1646,7 +1656,7 @@ int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
  */
 int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size)
 {
-	int idx = memblock_search(&memblock.memory, base);
+	int idx = memblock_search(&memblock.memory, base, NULL);
 	phys_addr_t end = base + memblock_cap_size(base, &size);
 
 	if (idx == -1)
@@ -1655,6 +1665,38 @@ int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size
 		 memblock.memory.regions[idx].size) >= end;
 }
 
+/**
+ * memblock_get_reserved_pfn_range - search for the next reserved region
+ *
+ * @pfn: start searching from this pfn.
+ *
+ * RETURNS:
+ * [start_pfn, end_pfn), where start_pfn >= pfn. If none is found
+ * start_pfn, and end_pfn are both set to ULONG_MAX.
+ */
+void __init_memblock memblock_get_reserved_pfn_range(unsigned long pfn,
+						     unsigned long *start_pfn,
+						     unsigned long *end_pfn)
+{
+	struct memblock_type *type = &memblock.reserved;
+	int next_idx, idx;
+
+	idx = memblock_search(type, PFN_PHYS(pfn), &next_idx);
+	if (idx == -1 && next_idx == -1) {
+		*start_pfn = ULONG_MAX;
+		*end_pfn = ULONG_MAX;
+		return;
+	}
+
+	if (idx == -1) {
+		idx = next_idx;
+		*start_pfn = PFN_DOWN(type->regions[idx].base);
+	} else {
+		*start_pfn = pfn;
+	}
+	*end_pfn = PFN_DOWN(type->regions[idx].base + type->regions[idx].size);
+}
+
 /**
  * memblock_is_region_reserved - check if a region intersects reserved memory
  * @base: base of region to check
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 63d16c185736..983de0a8047b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1447,6 +1447,7 @@ static int __init deferred_init_memmap(void *data)
 	pg_data_t *pgdat = data;
 	int nid = pgdat->node_id;
 	struct mminit_pfnnid_cache nid_init_state = { };
+	unsigned long resv_start_pfn = 0, resv_end_pfn = 0;
 	unsigned long start = jiffies;
 	unsigned long nr_pages = 0;
 	unsigned long walk_start, walk_end;
@@ -1491,6 +1492,10 @@ static int __init deferred_init_memmap(void *data)
 			pfn = zone->zone_start_pfn;
 
 		for (; pfn < end_pfn; pfn++) {
+			if (pfn >= resv_end_pfn)
+				memblock_get_reserved_pfn_range(pfn,
+								&resv_start_pfn,
+								&resv_end_pfn);
 			if (!pfn_valid_within(pfn))
 				goto free_range;
 
@@ -1524,7 +1529,11 @@ static int __init deferred_init_memmap(void *data)
 				cond_resched();
 			}
 
-			if (page->flags) {
+			/*
+			 * Check if this page has already been initialized due
+			 * to being reserved during boot in memblock.
+			 */
+			if (pfn >= resv_start_pfn) {
 				VM_BUG_ON(page_zone(page) != zone);
 				goto free_range;
 			}
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
