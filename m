Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E41326B0311
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 22:03:13 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id x36so6341960qtx.9
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 19:03:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d15si1751320qkb.211.2017.08.28.19.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 19:03:12 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v7 08/11] mm: zero reserved and unavailable struct pages
Date: Mon, 28 Aug 2017 22:02:19 -0400
Message-Id: <1503972142-289376-9-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1503972142-289376-1-git-send-email-pasha.tatashin@oracle.com>
References: <1503972142-289376-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Some memory is reserved but unavailable: not present in memblock.memory
(because not backed by physical pages), but present in memblock.reserved.
Such memory has backing struct pages, but they are not initialized by going
through __init_single_page().

In some cases these struct pages are accessed even if they do not contain
any data. One example is page_to_pfn() might access page->flags if this is
where section information is stored (CONFIG_SPARSEMEM,
SECTION_IN_PAGE_FLAGS).

Since, struct pages are zeroed in __init_single_page(), and not during
allocation time, we must zero such struct pages explicitly.

The patch involves adding a new memblock iterator:
	for_each_resv_unavail_range(i, p_start, p_end)

Which iterates through reserved && !memory lists, and we zero struct pages
explicitly by calling mm_zero_struct_page().

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 include/linux/memblock.h | 16 ++++++++++++++++
 include/linux/mm.h       |  6 ++++++
 mm/page_alloc.c          | 30 ++++++++++++++++++++++++++++++
 3 files changed, 52 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index bae11c7e7bf3..bdd4268f9323 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -237,6 +237,22 @@ unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
 	for_each_mem_range_rev(i, &memblock.memory, &memblock.reserved,	\
 			       nid, flags, p_start, p_end, p_nid)
 
+/**
+ * for_each_resv_unavail_range - iterate through reserved and unavailable memory
+ * @i: u64 used as loop variable
+ * @flags: pick from blocks based on memory attributes
+ * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ *
+ * Walks over unavailabled but reserved (reserved && !memory) areas of memblock.
+ * Available as soon as memblock is initialized.
+ * Note: because this memory does not belong to any physical node, flags and
+ * nid arguments do not make sense and thus not exported as arguments.
+ */
+#define for_each_resv_unavail_range(i, p_start, p_end)			\
+	for_each_mem_range(i, &memblock.reserved, &memblock.memory,	\
+			   NUMA_NO_NODE, MEMBLOCK_NONE, p_start, p_end, NULL)
+
 static inline void memblock_set_region_flags(struct memblock_region *r,
 					     unsigned long flags)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 183ac5e733db..0a440ff8f226 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1968,6 +1968,12 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
 					struct mminit_pfnnid_cache *state);
 #endif
 
+#ifdef CONFIG_HAVE_MEMBLOCK
+void zero_resv_unavail(void);
+#else
+static inline void __paginginit zero_resv_unavail(void) {}
+#endif
+
 extern void set_dma_reserve(unsigned long new_dma_reserve);
 extern void memmap_init_zone(unsigned long, int, unsigned long,
 				unsigned long, enum memmap_context);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4d67fe3dd172..484c16fb5f0d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6261,6 +6261,34 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	free_area_init_core(pgdat);
 }
 
+#ifdef CONFIG_HAVE_MEMBLOCK
+/*
+ * Only struct pages that are backed by physical memory are zeroed and
+ * initialized by going through __init_single_page(). But, there are some
+ * struct pages which are reserved in memblock allocator and their fields
+ * may be accessed (for example page_to_pfn() on some configuration accesses
+ * flags). We must explicitly zero those struct pages.
+ */
+void __paginginit zero_resv_unavail(void)
+{
+	phys_addr_t start, end;
+	unsigned long pfn;
+	u64 i, pgcnt;
+
+	/* Loop through ranges that are reserved, but do not have reported
+	 * physical memory backing.
+	 */
+	pgcnt = 0;
+	for_each_resv_unavail_range(i, &start, &end) {
+		for (pfn = PFN_DOWN(start); pfn < PFN_UP(end); pfn++) {
+			mm_zero_struct_page(pfn_to_page(pfn));
+			pgcnt++;
+		}
+	}
+	pr_info("Reserved but unavailable: %lld pages", pgcnt);
+}
+#endif /* CONFIG_HAVE_MEMBLOCK */
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 
 #if MAX_NUMNODES > 1
@@ -6684,6 +6712,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 			node_set_state(nid, N_MEMORY);
 		check_for_memory(pgdat, nid);
 	}
+	zero_resv_unavail();
 }
 
 static int __init cmdline_parse_core(char *p, unsigned long *core)
@@ -6847,6 +6876,7 @@ void __init free_area_init(unsigned long *zones_size)
 {
 	free_area_init_node(0, zones_size,
 			__pa(PAGE_OFFSET) >> PAGE_SHIFT, NULL);
+	zero_resv_unavail();
 }
 
 static int page_alloc_cpu_dead(unsigned int cpu)
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
