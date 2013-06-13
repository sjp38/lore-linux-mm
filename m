Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id EA13D90000B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:06 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part3 PATCH v2 1/4] bootmem, mem-hotplug: Register local pagetable pages with LOCAL_NODE_DATA when freeing bootmem.
Date: Thu, 13 Jun 2013 21:03:53 +0800
Message-Id: <1371128636-9027-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

As Yinghai suggested, even if a node is movable node, which has only
ZONE_MOVABLE, pagetables should be put in the local node.

In memory hot-remove logic, it offlines all pages first, and then
removes pagetables. But the local pagetable pages cannot be offlined
because they are used by kernel.

So we should skip this kind of pages in offline procedure. But first
of all, we need to mark them.

This patch marks local node data pages in the same way as we mark the
SECTION_INFO and MIX_SECTION_INFO data pages. We introduce a new type
of bootmem: LOCAL_NODE_DATA. And use page->lru.next to mark this type
of memory.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/init_64.c          |    2 +
 include/linux/memblock.h       |   22 +++++++++++++++++
 include/linux/memory_hotplug.h |   13 ++++++++-
 mm/memblock.c                  |   52 ++++++++++++++++++++++++++++++++++++++++
 mm/memory_hotplug.c            |   26 ++++++++++++++++++++
 5 files changed, 113 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bb00c46..25de304 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1053,6 +1053,8 @@ static void __init register_page_bootmem_info(void)
 
 	for_each_online_node(i)
 		register_page_bootmem_info_node(NODE_DATA(i));
+
+	register_page_bootmem_local_node();
 #endif
 }
 
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index a85ced9..8a38eef 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -131,6 +131,28 @@ void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
 	     i != (u64)ULLONG_MAX;					\
 	     __next_free_mem_range_rev(&i, nid, p_start, p_end, p_nid))
 
+void __next_local_node_mem_range(int *idx, int nid, phys_addr_t *out_start,
+				 phys_addr_t *out_end, int *out_nid);
+
+/**
+ * for_each_local_node_mem_range - iterate memblock areas storing local node
+ *                                 data
+ * @i: int used as loop variable
+ * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ * @p_nid: ptr to int for nid of the range, can be %NULL
+ *
+ * Walks over memblock areas storing local node data. Since all the local node
+ * areas will be reserved by memblock, this iterator will only iterate
+ * memblock.reserve. Available as soon as memblock is initialized.
+ */
+#define for_each_local_node_mem_range(i, nid, p_start, p_end, p_nid)	    \
+	for (i = -1,							    \
+	     __next_local_node_mem_range(&i, nid, p_start, p_end, p_nid);   \
+	     i != -1;							    \
+	     __next_local_node_mem_range(&i, nid, p_start, p_end, p_nid))
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_set_node(phys_addr_t base, phys_addr_t size, int nid);
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 0b21e54..c0c4107 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -16,14 +16,19 @@ struct memory_block;
 
 /*
  * Types for free bootmem stored in page->lru.next. These have to be in
- * some random range in unsigned long space for debugging purposes.
+ * some random range in unsigned long space for debugging purposes except
+ * LOCAL_NODE_DATA.
+ *
+ * LOCAL_NODE_DATA is used to mark local node pages storing data to
+ * describe the memory of the node, such as local pagetable pages.
  */
 enum {
 	MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE = 12,
 	SECTION_INFO = MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE,
 	MIX_SECTION_INFO,
 	NODE_INFO,
-	MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE = NODE_INFO,
+	LOCAL_NODE_DATA,
+	MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE = LOCAL_NODE_DATA,
 };
 
 /* Types for control the zone type of onlined memory */
@@ -179,10 +184,14 @@ static inline void arch_refresh_nodedata(int nid, pg_data_t *pgdat)
 
 #ifdef CONFIG_HAVE_BOOTMEM_INFO_NODE
 extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
+extern void register_page_bootmem_local_node(void);
 #else
 static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
 {
 }
+static inline void register_page_bootmem_local_node()
+{
+}
 #endif
 extern void put_page_bootmem(struct page *page);
 extern void get_page_bootmem(unsigned long ingo, struct page *page,
diff --git a/mm/memblock.c b/mm/memblock.c
index e672b9e..420e7fb 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -631,6 +631,58 @@ bool __init_memblock memblock_is_hotpluggable(struct memblock_region *region)
 	return region->flags & MEMBLK_HOTPLUGGABLE;
 }
 
+/*
+ * Common iterator to find next range with the same flags.
+ */
+static void __init_memblock __next_flag_mem_range(int *idx, int nid,
+					unsigned long flags,
+					phys_addr_t *out_start,
+					phys_addr_t *out_end, int *out_nid)
+{
+	struct memblock_type *rsv = &memblock.reserved;
+	struct memblock_region *r;
+
+	while (++*idx < rsv->cnt) {
+		r = &rsv->regions[*idx];
+
+		if (nid != MAX_NUMNODES &&
+		    nid != memblock_get_region_node(r))
+			continue;
+
+		if (r->flags & flags)
+			break;
+	}
+
+	if (*idx >= rsv->cnt) {
+		*idx = -1;
+		return;
+	}
+
+	if (out_start)
+		*out_start = r->base;
+	if (out_end)
+		*out_end = r->base + r->size;
+	if (out_nid)
+		*out_nid = memblock_get_region_node(r);
+}
+
+/**
+ * __next_local_node_mem_range - next function for
+ *                               for_each_local_node_mem_range()
+ * @idx: pointer to int loop variable
+ * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ * @out_nid: ptr to int for nid of the range, can be %NULL
+ */
+void __init_memblock __next_local_node_mem_range(int *idx, int nid,
+					phys_addr_t *out_start,
+					phys_addr_t *out_end, int *out_nid)
+{
+	__next_flag_mem_range(idx, nid, MEMBLK_LOCAL_NODE,
+			      out_start, out_end, out_nid);
+}
+
 /**
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1ad92b4..c2017eb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -30,6 +30,7 @@
 #include <linux/mm_inline.h>
 #include <linux/firmware-map.h>
 #include <linux/stop_machine.h>
+#include <linux/memblock.h>
 
 #include <asm/tlbflush.h>
 
@@ -191,6 +192,31 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
+void __ref register_page_bootmem_local_node()
+{
+	int i, nid;
+	phys_addr_t start, end;
+	unsigned long start_pfn, end_pfn;
+	struct page *page;
+
+	for_each_local_node_mem_range(i, MAX_NUMNODES, &start, &end, &nid) {
+		start_pfn = PFN_DOWN(start);
+		end_pfn = PFN_UP(end);
+		page = pfn_to_page(start_pfn);
+
+		for ( ; start_pfn <= end_pfn; start_pfn++, page++) {
+			/*
+			 * We need to set the whole page as LOCAL_NODE_DATA,
+			 * so we get the upper end_pfn. But this upper end_pfn
+			 * may not exist. So we have to check if the page
+			 * present before we access its struct page.
+			 */
+			if (pfn_present(start_pfn))
+				get_page_bootmem(nid, page, LOCAL_NODE_DATA);
+		}
+	}
+}
+
 void register_page_bootmem_info_node(struct pglist_data *pgdat)
 {
 	unsigned long i, pfn, end_pfn, nr_pages;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
