Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 005636B0005
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 12:04:41 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f4so168587plr.14
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 09:04:40 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q10si1693491pgp.285.2018.02.15.09.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 09:04:39 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v4 6/6] mm/memory_hotplug: optimize memory hotplug
Date: Thu, 15 Feb 2018 11:59:20 -0500
Message-Id: <20180215165920.8570-7-pasha.tatashin@oracle.com>
In-Reply-To: <20180215165920.8570-1-pasha.tatashin@oracle.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

During memory hotplugging we traverse struct pages three times:

1. memset(0) in sparse_add_one_section()
2. loop in __add_section() to set do: set_page_node(page, nid); and
   SetPageReserved(page);
3. loop in memmap_init_zone() to call __init_single_pfn()

This patch remove the first two loops, and leaves only loop 3. All struct
pages are initialized in one place, the same as it is done during boot.

The benefits:
- We improve the memory hotplug performance because we are not evicting
  cache several times and also reduce loop branching overheads.

- Remove condition from hotpath in __init_single_pfn(), that was added in
  order to fix the problem that was reported by Bharata in the above email
  thread, thus also improve the performance during normal boot.

- Make memory hotplug more similar to boot memory initialization path
  because we zero and initialize struct pages only in one function.

- Simplifies memory hotplug strut page initialization code, and thus
  enables future improvements, such as multi-threading the initialization
  of struct pages in order to improve the hotplug performance even further
  on larger machines.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/memory_hotplug.c | 21 ++++++---------------
 mm/page_alloc.c     | 28 ++++++++++------------------
 mm/sparse.c         |  9 ++++++++-
 3 files changed, 24 insertions(+), 34 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 565048f496f7..ee04dae21f0c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -250,7 +250,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 		struct vmem_altmap *altmap, bool want_memblock)
 {
 	int ret;
-	int i;
+	struct page *page;
 
 	if (pfn_valid(phys_start_pfn))
 		return -EEXIST;
@@ -260,21 +260,12 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 		return ret;
 
 	/*
-	 * Make all the pages reserved so that nobody will stumble over half
-	 * initialized state.
-	 * FIXME: We also have to associate it with a node because page_to_nid
-	 * relies on having page with the proper node.
+	 * The first page in every section holds node id, this is because we
+	 * will need it in online_pages().
 	 */
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
+	page = pfn_to_page(phys_start_pfn);
+	mm_zero_struct_page(page);
+	set_page_node(page, nid);
 
 	if (!want_memblock)
 		return 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 81e18ceef579..2667b35fca41 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1177,10 +1177,9 @@ static void free_one_page(struct zone *zone,
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
@@ -1194,12 +1193,6 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
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
@@ -1218,7 +1211,7 @@ static void __meminit init_reserved_page(unsigned long pfn)
 		if (pfn >= zone->zone_start_pfn && pfn < zone_end_pfn(zone))
 			break;
 	}
-	__init_single_pfn(pfn, zid, nid, true);
+	__init_single_page(pfn_to_page(pfn), pfn, zid, nid);
 }
 #else
 static inline void init_reserved_page(unsigned long pfn)
@@ -1535,7 +1528,7 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
 		} else {
 			page++;
 		}
-		__init_single_page(page, pfn, zid, nid, true);
+		__init_single_page(page, pfn, zid, nid);
 		nr_pages++;
 	}
 	return (nr_pages);
@@ -5328,6 +5321,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long pfn;
 	unsigned long nr_initialised = 0;
+	struct page *page;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	struct memblock_region *r = NULL, *tmp;
 #endif
@@ -5389,6 +5383,11 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
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
@@ -5405,15 +5404,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
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
index 7af5e7a92528..eb72de54089c 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -816,7 +816,14 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 		goto out;
 	}
 
-	memset(memmap, 0, sizeof(struct page) * PAGES_PER_SECTION);
+#ifdef CONFIG_DEBUG_VM
+	/*
+	 * poison uninitialized struct pages in order to catch invalid flags
+	 * combinations.
+	 */
+	memset(memmap, PAGE_POISON_PATTERN,
+	       sizeof(struct page) * PAGES_PER_SECTION);
+#endif
 
 	section_mark_present(ms);
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
