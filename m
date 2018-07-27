Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C86936B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 12:55:04 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f64-v6so4734248qkb.20
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 09:55:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f34-v6si775894qtb.125.2018.07.27.09.55.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 09:55:03 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1] mm: inititalize struct pages when adding a section
Date: Fri, 27 Jul 2018 18:54:54 +0200
Message-Id: <20180727165454.27292-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Souptick Joarder <jrdr.linux@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@techadventures.net>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Right now, struct pages are inititalized when memory is onlined, not
when it is added (since commit d0dc12e86b31 ("mm/memory_hotplug: optimize
memory hotplug")).

remove_memory() will call arch_remove_memory(). Here, we usually access
the struct page to get the zone of the pages.

So effectively, we access stale struct pages in case we remove memory that
was never onlined. So let's simply inititalize them earlier, when the
memory is added. We only have to take care of updating the zone once we
know it. We can use a dummy zone for that purpose.

So effectively, all pages will already be initialized and set to
reserved after memory was added but before it was onlined (and even the
memblock is added). We only inititalize pages once, to not degrade
performance.

This will also mean that user space dump tools will always see sane
struct pages once a memblock pops up.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@techadventures.net>
Cc: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: Mathieu Malaterre <malat@debian.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/node.c    |  1 -
 include/linux/memory.h |  1 -
 include/linux/mm.h     | 10 ++++++++++
 mm/memory_hotplug.c    | 27 +++++++++++++++++++--------
 mm/page_alloc.c        | 23 +++++++++++------------
 5 files changed, 40 insertions(+), 22 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index a5e821d09656..3ec78f80afe2 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -408,7 +408,6 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
 	if (!mem_blk)
 		return -EFAULT;
 
-	mem_blk->nid = nid;
 	if (!node_online(nid))
 		return 0;
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index a6ddefc60517..8a0864a65a98 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -33,7 +33,6 @@ struct memory_block {
 	void *hw;			/* optional pointer to fw/hw data */
 	int (*phys_callback)(struct memory_block *);
 	struct device dev;
-	int nid;			/* NID for this memory block */
 };
 
 int arch_get_memory_phys_device(unsigned long start_pfn);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d3a3842316b8..e6bf3527b7a2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1162,7 +1162,15 @@ static inline void set_page_address(struct page *page, void *address)
 {
 	page->virtual = address;
 }
+static void set_page_virtual(struct page *page, and enum zone_type zone)
+{
+	/* The shift won't overflow because ZONE_NORMAL is below 4G. */
+	if (!is_highmem_idx(zone))
+		set_page_address(page, __va(pfn << PAGE_SHIFT));
+}
 #define page_address_init()  do { } while(0)
+#else
+#define set_page_virtual(page, zone)  do { } while(0)
 #endif
 
 #if defined(HASHED_PAGE_VIRTUAL)
@@ -2116,6 +2124,8 @@ extern unsigned long find_min_pfn_with_active_regions(void);
 extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
 extern void sparse_memory_present_with_active_regions(int nid);
+extern void __meminit init_single_page(struct page *page, unsigned long pfn,
+				       unsigned long zone, int nid);
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7deb49f69e27..3f28ca3c3a33 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -250,6 +250,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 		struct vmem_altmap *altmap, bool want_memblock)
 {
 	int ret;
+	int i;
 
 	if (pfn_valid(phys_start_pfn))
 		return -EEXIST;
@@ -258,6 +259,23 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 	if (ret < 0)
 		return ret;
 
+	/*
+	 * Initialize all pages in the section before fully exposing them to the
+	 * system so nobody will stumble over a half inititalized state.
+	 */
+	for (i = 0; i < PAGES_PER_SECTION; i++) {
+		unsigned long pfn = phys_start_pfn + i;
+		struct page *page;
+
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+
+		/* dummy zone, the actual one will be set when onlining pages */
+		init_single_page(page, pfn, ZONE_NORMAL, nid);
+		SetPageReserved(page);
+	}
+
 	if (!want_memblock)
 		return 0;
 
@@ -891,15 +909,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	int nid;
 	int ret;
 	struct memory_notify arg;
-	struct memory_block *mem;
-
-	/*
-	 * We can't use pfn_to_nid() because nid might be stored in struct page
-	 * which is not yet initialized. Instead, we find nid from memory block.
-	 */
-	mem = find_memory_block(__pfn_to_section(pfn));
-	nid = mem->nid;
 
+	nid = pfn_to_nid(pfn);
 	/* associate pfn range with the zone */
 	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a790ef4be74e..8d81df4c40ab 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1168,7 +1168,7 @@ static void free_one_page(struct zone *zone,
 	spin_unlock(&zone->lock);
 }
 
-static void __meminit __init_single_page(struct page *page, unsigned long pfn,
+void __meminit init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
 	mm_zero_struct_page(page);
@@ -1178,11 +1178,7 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 	page_cpupid_reset_last(page);
 
 	INIT_LIST_HEAD(&page->lru);
-#ifdef WANT_PAGE_VIRTUAL
-	/* The shift won't overflow because ZONE_NORMAL is below 4G. */
-	if (!is_highmem_idx(zone))
-		set_page_address(page, __va(pfn << PAGE_SHIFT));
-#endif
+	set_page_virtual(page, zone);
 }
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
@@ -1203,7 +1199,7 @@ static void __meminit init_reserved_page(unsigned long pfn)
 		if (pfn >= zone->zone_start_pfn && pfn < zone_end_pfn(zone))
 			break;
 	}
-	__init_single_page(pfn_to_page(pfn), pfn, zid, nid);
+	init_single_page(pfn_to_page(pfn), pfn, zid, nid);
 }
 #else
 static inline void init_reserved_page(unsigned long pfn)
@@ -1520,7 +1516,7 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
 		} else {
 			page++;
 		}
-		__init_single_page(page, pfn, zid, nid);
+		init_single_page(page, pfn, zid, nid);
 		nr_pages++;
 	}
 	return (nr_pages);
@@ -5519,9 +5515,12 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 
 not_early:
 		page = pfn_to_page(pfn);
-		__init_single_page(page, pfn, zone, nid);
-		if (context == MEMMAP_HOTPLUG)
-			SetPageReserved(page);
+		if (context == MEMMAP_HOTPLUG) {
+			/* everything but the zone was inititalized */
+			set_page_zone(page, zone);
+			set_page_virtual(page, zone);
+		} else
+			init_single_page(page, pfn, zone, nid);
 
 		/*
 		 * Mark the block movable so that blocks are reserved for
@@ -6386,7 +6385,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 #if defined(CONFIG_HAVE_MEMBLOCK) && !defined(CONFIG_FLAT_NODE_MEM_MAP)
 /*
  * Only struct pages that are backed by physical memory are zeroed and
- * initialized by going through __init_single_page(). But, there are some
+ * initialized by going through init_single_page(). But, there are some
  * struct pages which are reserved in memblock allocator and their fields
  * may be accessed (for example page_to_pfn() on some configuration accesses
  * flags). We must explicitly zero those struct pages.
-- 
2.17.1
