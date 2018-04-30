Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB3426B0006
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 05:42:48 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id k23-v6so6636136qtj.16
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 02:42:48 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t4si6683462qkh.207.2018.04.30.02.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 02:42:47 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RCFv2 1/7] mm: introduce and use PageOffline()
Date: Mon, 30 Apr 2018 11:42:30 +0200
Message-Id: <20180430094236.29056-2-david@redhat.com>
In-Reply-To: <20180430094236.29056-1-david@redhat.com>
References: <20180430094236.29056-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Reza Arbab <arbab@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

offline_pages() theoretically works on sub-section sizes. Problem is that
we have no way to know which pages are actually offline. So right now,
offline_pages() will always mark the whole section as offline.

In addition, in virtualized environments, we might soon have pages that are
logically offline and shall no longer be read or written - e.g. because
we offline a subsection and told our hypervisor to remove it. We need a way
(e.g. for kdump) to flag these pages (like PG_hwpoison), otherwise kdump
will happily access all memory and crash the system when accessing
memory that is not meant to be accessed.

Marking pages as offline will also later to give kdump that information
and to mark a section as offline once all pages are offline. It is save
to use mapcount as all pages are logically removed from the system
(offline_pages()).

This e.g. allows us to add/remove memory to Linux in a VM in 4MB chunks

Please note that we can't use PG_reserved for this. PG_reserved does not
imply that
- a page should not be dumped
- a page is offline and we should mark the section offline

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Philippe Ombredanne <pombredanne@nexb.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Miles Chen <miles.chen@mediatek.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/node.c        |  1 -
 include/linux/memory.h     |  1 -
 include/linux/mm.h         |  2 ++
 include/linux/page-flags.h |  9 +++++++++
 mm/memory_hotplug.c        | 32 +++++++++++++++++++++++---------
 mm/page_alloc.c            | 22 ++++++++++++++--------
 mm/sparse.c                | 25 ++++++++++++++++++++++++-
 7 files changed, 72 insertions(+), 20 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 7a3a580821e0..58a889b2b2f4 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -408,7 +408,6 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
 	if (!mem_blk)
 		return -EFAULT;
 
-	mem_blk->nid = nid;
 	if (!node_online(nid))
 		return 0;
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 31ca3e28b0eb..9f8cd856ca1e 100644
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
index 1ac1f06a4be6..30c56665c327 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2063,6 +2063,8 @@ extern unsigned long find_min_pfn_with_active_regions(void);
 extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
 extern void sparse_memory_present_with_active_regions(int nid);
+extern void __meminit init_single_page(struct page *page, unsigned long pfn,
+				       unsigned long zone, int nid);
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e34a27727b9a..07ec6e48073b 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -686,6 +686,15 @@ PAGE_MAPCOUNT_OPS(Balloon, BALLOON)
 #define PAGE_KMEMCG_MAPCOUNT_VALUE		(-512)
 PAGE_MAPCOUNT_OPS(Kmemcg, KMEMCG)
 
+/*
+ * PageOffline() indicates that a page is offline (either never online via
+ * online_pages() or offlined via offline_pages()). Nobody in the system
+ * should have a reference to these pages. In virtual environments,
+ * the backing storage might already have been removed. Don't touch!
+ */
+#define PAGE_OFFLINE_MAPCOUNT_VALUE		(-1024)
+PAGE_MAPCOUNT_OPS(Offline, OFFLINE)
+
 extern bool is_free_buddy_page(struct page *page);
 
 __PAGEFLAG(Isolated, isolated, PF_ANY);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f74826cdceea..7f7bd2acb55b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -250,6 +250,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 		struct vmem_altmap *altmap, bool want_memblock)
 {
 	int ret;
+	int i;
 
 	if (pfn_valid(phys_start_pfn))
 		return -EEXIST;
@@ -258,6 +259,25 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 	if (ret < 0)
 		return ret;
 
+	/*
+	 * Mark all the pages in the section as offline before creating the
+	 * memblock and onlining any sub-sections (and therefore marking the
+	 * whole section as online). Mark them reserved so nobody will stumble
+	 * over a half inititalized state.
+	 */
+	for (i = 0; i < PAGES_PER_SECTION; i++) {
+		unsigned long pfn = phys_start_pfn + i;
+		struct page *page;
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+
+		/* dummy zone, the actual one will be set when onlining pages */
+		init_single_page(page, pfn, ZONE_NORMAL, nid);
+		SetPageReserved(page);
+		__SetPageOffline(page);
+	}
+
 	if (!want_memblock)
 		return 0;
 
@@ -651,6 +671,7 @@ EXPORT_SYMBOL_GPL(__online_page_increment_counters);
 
 void __online_page_free(struct page *page)
 {
+	__ClearPageOffline(page);
 	__free_reserved_page(page);
 }
 EXPORT_SYMBOL_GPL(__online_page_free);
@@ -891,15 +912,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
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
 
@@ -1426,7 +1440,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 }
 
 /*
- * remove from free_area[] and mark all as Reserved.
+ * remove from free_area[] and mark all as Reserved and Offline.
  */
 static int
 offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905db9d7962f..567278f28188 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1171,7 +1171,7 @@ static void free_one_page(struct zone *zone,
 	spin_unlock(&zone->lock);
 }
 
-static void __meminit __init_single_page(struct page *page, unsigned long pfn,
+extern void __meminit init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
 	mm_zero_struct_page(page);
@@ -1206,7 +1206,7 @@ static void __meminit init_reserved_page(unsigned long pfn)
 		if (pfn >= zone->zone_start_pfn && pfn < zone_end_pfn(zone))
 			break;
 	}
-	__init_single_page(pfn_to_page(pfn), pfn, zid, nid);
+	init_single_page(pfn_to_page(pfn), pfn, zid, nid);
 }
 #else
 static inline void init_reserved_page(unsigned long pfn)
@@ -1523,7 +1523,7 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
 		} else {
 			page++;
 		}
-		__init_single_page(page, pfn, zid, nid);
+		init_single_page(page, pfn, zid, nid);
 		nr_pages++;
 	}
 	return (nr_pages);
@@ -5514,9 +5514,11 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 
 not_early:
 		page = pfn_to_page(pfn);
-		__init_single_page(page, pfn, zone, nid);
 		if (context == MEMMAP_HOTPLUG)
-			SetPageReserved(page);
+			/* everything but the zone was inititalized */
+			set_page_zone(page, zone);
+		else
+			init_single_page(page, pfn, zone, nid);
 
 		/*
 		 * Mark the block movable so that blocks are reserved for
@@ -6404,7 +6406,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 #ifdef CONFIG_HAVE_MEMBLOCK
 /*
  * Only struct pages that are backed by physical memory are zeroed and
- * initialized by going through __init_single_page(). But, there are some
+ * initialized by going through init_single_page(). But, there are some
  * struct pages which are reserved in memblock allocator and their fields
  * may be accessed (for example page_to_pfn() on some configuration accesses
  * flags). We must explicitly zero those struct pages.
@@ -8005,7 +8007,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			break;
 	if (pfn == end_pfn)
 		return;
-	offline_mem_sections(pfn, end_pfn);
 	zone = page_zone(pfn_to_page(pfn));
 	spin_lock_irqsave(&zone->lock, flags);
 	pfn = start_pfn;
@@ -8022,11 +8023,13 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		if (unlikely(!PageBuddy(page) && PageHWPoison(page))) {
 			pfn++;
 			SetPageReserved(page);
+			__SetPageOffline(page);
 			continue;
 		}
 
 		BUG_ON(page_count(page));
 		BUG_ON(!PageBuddy(page));
+		BUG_ON(PageOffline(page));
 		order = page_order(page);
 #ifdef CONFIG_DEBUG_VM
 		pr_info("remove from free list %lx %d %lx\n",
@@ -8035,11 +8038,14 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		list_del(&page->lru);
 		rmv_page_order(page);
 		zone->free_area[order].nr_free--;
-		for (i = 0; i < (1 << order); i++)
+		for (i = 0; i < (1 << order); i++) {
 			SetPageReserved((page+i));
+			__SetPageOffline(page + i);
+		}
 		pfn += (1 << order);
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
+	offline_mem_sections(start_pfn, end_pfn);
 }
 #endif
 
diff --git a/mm/sparse.c b/mm/sparse.c
index 62eef264a7bd..693e8ba2ad0c 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -623,7 +623,24 @@ void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-/* Mark all memory sections within the pfn range as online */
+static bool all_pages_in_section_offline(unsigned long section_nr)
+{
+	unsigned long pfn = section_nr_to_pfn(section_nr);
+	struct page *page;
+	int i;
+
+	for (i = 0; i < PAGES_PER_SECTION; i++, pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+
+		page = pfn_to_page(pfn);
+		if (!PageOffline(page))
+			return false;
+	}
+	return true;
+}
+
+/* Try to mark all memory sections within the pfn range as offline */
 void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long pfn;
@@ -639,6 +656,12 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 		if (WARN_ON(!valid_section_nr(section_nr)))
 			continue;
 
+		/* if we don't cover whole sections, check all pages */
+		if ((section_nr_to_pfn(section_nr) != start_pfn ||
+		     start_pfn + PAGES_PER_SECTION >= end_pfn) &&
+		    !all_pages_in_section_offline(section_nr))
+			continue;
+
 		ms = __nr_to_section(section_nr);
 		ms->section_mem_map &= ~SECTION_IS_ONLINE;
 	}
-- 
2.14.3
