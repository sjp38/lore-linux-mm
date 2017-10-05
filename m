Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 383176B0261
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 17:12:19 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k7so11053088wre.5
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 14:12:19 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a11si206128edb.453.2017.10.05.14.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 14:12:17 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v10 05/10] mm: zero reserved and unavailable struct pages
Date: Thu,  5 Oct 2017 17:11:19 -0400
Message-Id: <20171005211124.26524-6-pasha.tatashin@oracle.com>
In-Reply-To: <20171005211124.26524-1-pasha.tatashin@oracle.com>
References: <20171005211124.26524-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Some memory is reserved but unavailable: not present in memblock.memory
(because not backed by physical pages), but present in memblock.reserved.
Such memory has backing struct pages, but they are not initialized by going
through __init_single_page().

In some cases these struct pages are accessed even if they do not contain
any data. One example is page_to_pfn() might access page->flags if this is
where section information is stored (CONFIG_SPARSEMEM,
SECTION_IN_PAGE_FLAGS).

One example of such memory: trim_low_memory_range() unconditionally
reserves from pfn 0, but e820__memblock_setup() might provide the exiting
memory from pfn 1 (i.e. KVM).

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
 include/linux/mm.h       | 15 +++++++++++++++
 mm/page_alloc.c          | 38 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 69 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index bae11c7e7bf3..ce8bfa5f3e9b 100644
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
+ * Walks over unavailable but reserved (reserved && !memory) areas of memblock.
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
index 065d99deb847..04c8b2e5aff4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -94,6 +94,15 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #define mm_forbids_zeropage(X)	(0)
 #endif
 
+/*
+ * On some architectures it is expensive to call memset() for small sizes.
+ * Those architectures should provide their own implementation of "struct page"
+ * zeroing by defining this macro in <asm/pgtable.h>.
+ */
+#ifndef mm_zero_struct_page
+#define mm_zero_struct_page(pp)  ((void)memset((pp), 0, sizeof(struct page)))
+#endif
+
 /*
  * Default maximum number of active map areas, this limits the number of vmas
  * per mm struct. Users can overwrite this number by sysctl but there is a
@@ -2001,6 +2010,12 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
 					struct mminit_pfnnid_cache *state);
 #endif
 
+#ifdef CONFIG_HAVE_MEMBLOCK
+void zero_resv_unavail(void);
+#else
+static inline void zero_resv_unavail(void) {}
+#endif
+
 extern void set_dma_reserve(unsigned long new_dma_reserve);
 extern void memmap_init_zone(unsigned long, int, unsigned long,
 				unsigned long, enum memmap_context);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 20b0bace2235..5f0013bbbe9d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6209,6 +6209,42 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
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
+
+	/*
+	 * Struct pages that do not have backing memory. This could be because
+	 * firmware is using some of this memory, or for some other reasons.
+	 * Once memblock is changed so such behaviour is not allowed: i.e.
+	 * list of "reserved" memory must be a subset of list of "memory", then
+	 * this code can be removed.
+	 */
+	pr_info("Reserved but unavailable: %lld pages", pgcnt);
+}
+#endif /* CONFIG_HAVE_MEMBLOCK */
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 
 #if MAX_NUMNODES > 1
@@ -6632,6 +6668,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 			node_set_state(nid, N_MEMORY);
 		check_for_memory(pgdat, nid);
 	}
+	zero_resv_unavail();
 }
 
 static int __init cmdline_parse_core(char *p, unsigned long *core)
@@ -6795,6 +6832,7 @@ void __init free_area_init(unsigned long *zones_size)
 {
 	free_area_init_node(0, zones_size,
 			__pa(PAGE_OFFSET) >> PAGE_SHIFT, NULL);
+	zero_resv_unavail();
 }
 
 static int page_alloc_cpu_dead(unsigned int cpu)
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
