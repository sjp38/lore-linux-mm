Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3776B0011
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 22:03:31 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g125so1407813ita.6
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 19:03:31 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id q135si394738ioe.149.2018.02.27.19.03.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 19:03:29 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v5 6/6] mm/memory_hotplug: optimize memory hotplug
Date: Tue, 27 Feb 2018 22:03:08 -0500
Message-Id: <20180228030308.1116-7-pasha.tatashin@oracle.com>
In-Reply-To: <20180228030308.1116-1-pasha.tatashin@oracle.com>
References: <20180228030308.1116-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

During memory hotplugging we traverse struct pages three times:

1. memset(0) in sparse_add_one_section()
2. loop in __add_section() to set do: set_page_node(page, nid); and
   SetPageReserved(page);
3. loop in memmap_init_zone() to call __init_single_pfn()

This patch removes the first two loops, and leaves only loop 3. All struct
pages are initialized in one place, the same as it is done during boot.

The benefits:
- We improve memory hotplug performance because we are not evicting the
  cache several times and also reduce loop branching overhead.

- Remove condition from hotpath in __init_single_pfn(), that was added in
  order to fix the problem that was reported by Bharata in the above email
  thread, thus also improve performance during normal boot.

- Make memory hotplug more similar to the boot memory initialization path
  because we zero and initialize struct pages only in one function.

- Simplifies memory hotplug struct page initialization code, and thus
  enables future improvements, such as multi-threading the initialization
  of struct pages in order to improve hotplug performance even further on
  larger machines.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Ingo Molnar <mingo@kernel.org>
---
 drivers/base/node.c    |  2 ++
 include/linux/memory.h |  1 +
 mm/memory_hotplug.c    | 27 ++++++++-------------------
 mm/page_alloc.c        | 28 ++++++++++------------------
 mm/sparse.c            |  8 +++++++-
 5 files changed, 28 insertions(+), 38 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index d7cfc8d8a5c5..51de4af290ac 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -405,6 +405,8 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
 
 	if (!mem_blk)
 		return -EFAULT;
+
+	mem_blk->nid = nid;
 	if (!node_online(nid))
 		return 0;
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 9f8cd856ca1e..31ca3e28b0eb 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -33,6 +33,7 @@ struct memory_block {
 	void *hw;			/* optional pointer to fw/hw data */
 	int (*phys_callback)(struct memory_block *);
 	struct device dev;
+	int nid;			/* NID for this memory block */
 };
 
 int arch_get_memory_phys_device(unsigned long start_pfn);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 477e183a4ac7..6a9ba14e18ed 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -250,7 +250,6 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 		struct vmem_altmap *altmap, bool want_memblock)
 {
 	int ret;
-	int i;
 
 	if (pfn_valid(phys_start_pfn))
 		return -EEXIST;
@@ -259,23 +258,6 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 	if (ret < 0)
 		return ret;
 
-	/*
-	 * Make all the pages reserved so that nobody will stumble over half
-	 * initialized state.
-	 * FIXME: We also have to associate it with a node because page_to_nid
-	 * relies on having page with the proper node.
-	 */
-	for (i = 0; i < PAGES_PER_SECTION; i++) {
-		unsigned long pfn = phys_start_pfn + i;
-		struct page *page;
-		if (!pfn_valid(pfn))
-			continue;
-
-		page = pfn_to_page(pfn);
-		set_page_node(page, nid);
-		SetPageReserved(page);
-	}
-
 	if (!want_memblock)
 		return 0;
 
@@ -908,8 +890,15 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	int nid;
 	int ret;
 	struct memory_notify arg;
+	struct memory_block *mem;
+
+	/*
+	 * We can't use pfn_to_nid() because nid might be stored in struct page
+	 * which is not yet initialized. Instead, we find nid from memory block.
+	 */
+	mem = find_memory_block(__pfn_to_section(pfn));
+	nid = mem->nid;
 
-	nid = pfn_to_nid(pfn);
 	/* associate pfn range with the zone */
 	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cb416723538f..8bf3b9c215c1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1181,10 +1181,9 @@ static void free_one_page(struct zone *zone,
 }
 
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
-				unsigned long zone, int nid, bool zero)
+				unsigned long zone, int nid)
 {
-	if (zero)
-		mm_zero_struct_page(page);
+	mm_zero_struct_page(page);
 	set_page_links(page, zone, nid, pfn);
 	init_page_count(page);
 	page_mapcount_reset(page);
@@ -1198,12 +1197,6 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 #endif
 }
 
-static void __meminit __init_single_pfn(unsigned long pfn, unsigned long zone,
-					int nid, bool zero)
-{
-	return __init_single_page(pfn_to_page(pfn), pfn, zone, nid, zero);
-}
-
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 static void __meminit init_reserved_page(unsigned long pfn)
 {
@@ -1222,7 +1215,7 @@ static void __meminit init_reserved_page(unsigned long pfn)
 		if (pfn >= zone->zone_start_pfn && pfn < zone_end_pfn(zone))
 			break;
 	}
-	__init_single_pfn(pfn, zid, nid, true);
+	__init_single_page(pfn_to_page(pfn), pfn, zid, nid);
 }
 #else
 static inline void init_reserved_page(unsigned long pfn)
@@ -1539,7 +1532,7 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
 		} else {
 			page++;
 		}
-		__init_single_page(page, pfn, zid, nid, true);
+		__init_single_page(page, pfn, zid, nid);
 		nr_pages++;
 	}
 	return (nr_pages);
@@ -5332,6 +5325,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long pfn;
 	unsigned long nr_initialised = 0;
+	struct page *page;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	struct memblock_region *r = NULL, *tmp;
 #endif
@@ -5393,6 +5387,11 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 #endif
 
 not_early:
+		page = pfn_to_page(pfn);
+		__init_single_page(page, pfn, zone, nid);
+		if (context == MEMMAP_HOTPLUG)
+			SetPageReserved(page);
+
 		/*
 		 * Mark the block movable so that blocks are reserved for
 		 * movable at startup. This will force kernel allocations
@@ -5409,15 +5408,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		 * because this is done early in sparse_add_one_section
 		 */
 		if (!(pfn & (pageblock_nr_pages - 1))) {
-			struct page *page = pfn_to_page(pfn);
-
-			__init_single_page(page, pfn, zone, nid,
-					context != MEMMAP_HOTPLUG);
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 			cond_resched();
-		} else {
-			__init_single_pfn(pfn, zone, nid,
-					context != MEMMAP_HOTPLUG);
 		}
 	}
 }
diff --git a/mm/sparse.c b/mm/sparse.c
index 7af5e7a92528..775e1a4fd95e 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -816,7 +816,13 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 		goto out;
 	}
 
-	memset(memmap, 0, sizeof(struct page) * PAGES_PER_SECTION);
+#ifdef CONFIG_DEBUG_VM
+	/*
+	 * Poison uninitialized struct pages in order to catch invalid flags
+	 * combinations.
+	 */
+	memset(memmap, PAGE_POISON_PATTERN, sizeof(struct page) * PAGES_PER_SECTION);
+#endif
 
 	section_mark_present(ms);
 
-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
