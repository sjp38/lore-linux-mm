Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9A1C6B000A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 18:16:59 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o18-v6so7642081pgv.14
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 15:16:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id i7-v6si17793225pgr.147.2018.10.11.15.16.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 15:16:58 -0700 (PDT)
Subject: [mm PATCH v2 6/6] mm: Use common iterator for deferred_init_pages
 and deferred_free_pages
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Thu, 11 Oct 2018 15:14:03 -0700
Message-ID: <20181011221402.1925.94407.stgit@localhost.localdomain>
In-Reply-To: <20181011221237.1925.85591.stgit@localhost.localdomain>
References: <20181011221237.1925.85591.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

This patch creates a common iterator to be used by both deferred_init_pages
and deferred_free_pages. By doing this we can cut down a bit on code
overhead as they will likely both be inlined into the same function anyway.

This new approach allows deferred_init_pages to make use of
__init_pageblock. By doing this we can cut down on the code size by sharing
code between both the hotplug and deferred memory init code paths.

An additional benefit to this approach is that we improve in cache locality
of the memory init as we can focus on the memory areas related to
identifying if a given PFN is valid and keep that warm in the cache until
we transition to a region of a different type. So we will stream through a
chunk of valid blocks before we turn to initializing page structs.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/page_alloc.c |  134 +++++++++++++++++++++++++++----------------------------
 1 file changed, 65 insertions(+), 69 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5987c859676b..a018315c8f0c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1477,32 +1477,6 @@ void clear_zone_contiguous(struct zone *zone)
 }
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-static void __init deferred_free_range(unsigned long pfn,
-				       unsigned long nr_pages)
-{
-	struct page *page;
-	unsigned long i;
-
-	if (!nr_pages)
-		return;
-
-	page = pfn_to_page(pfn);
-
-	/* Free a large naturally-aligned chunk if possible */
-	if (nr_pages == pageblock_nr_pages &&
-	    (pfn & (pageblock_nr_pages - 1)) == 0) {
-		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-		__free_pages_boot_core(page, pageblock_order);
-		return;
-	}
-
-	for (i = 0; i < nr_pages; i++, page++, pfn++) {
-		if ((pfn & (pageblock_nr_pages - 1)) == 0)
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-		__free_pages_boot_core(page, 0);
-	}
-}
-
 /* Completion tracking for deferred_init_memmap() threads */
 static atomic_t pgdat_init_n_undone __initdata;
 static __initdata DECLARE_COMPLETION(pgdat_init_all_done_comp);
@@ -1514,48 +1488,77 @@ static inline void __init pgdat_init_report_one_done(void)
 }
 
 /*
- * Returns true if page needs to be initialized or freed to buddy allocator.
+ * Returns count if page range needs to be initialized or freed
  *
- * First we check if pfn is valid on architectures where it is possible to have
- * holes within pageblock_nr_pages. On systems where it is not possible, this
- * function is optimized out.
+ * First, we check if a current large page is valid by only checking the
+ * validity of the head pfn.
  *
- * Then, we check if a current large page is valid by only checking the validity
- * of the head pfn.
+ * Then we check if the contiguous pfns are valid on architectures where it
+ * is possible to have holes within pageblock_nr_pages. On systems where it
+ * is not possible, this function is optimized out.
  */
-static inline bool __init deferred_pfn_valid(unsigned long pfn)
+static unsigned long __next_pfn_valid_range(unsigned long *i,
+					    unsigned long end_pfn)
 {
-	if (!pfn_valid_within(pfn))
-		return false;
-	if (!(pfn & (pageblock_nr_pages - 1)) && !pfn_valid(pfn))
-		return false;
-	return true;
+	unsigned long pfn = *i;
+	unsigned long count;
+
+	while (pfn < end_pfn) {
+		unsigned long t = ALIGN(pfn + 1, pageblock_nr_pages);
+		unsigned long pageblock_pfn = min(t, end_pfn);
+
+#ifndef CONFIG_HOLES_IN_ZONE
+		count = pageblock_pfn - pfn;
+		pfn = pageblock_pfn;
+		if (!pfn_valid(pfn))
+			continue;
+#else
+		for (count = 0; pfn < pageblock_pfn; pfn++) {
+			if (pfn_valid_within(pfn)) {
+				count++;
+				continue;
+			}
+
+			if (count)
+				break;
+		}
+
+		if (!count)
+			continue;
+#endif
+		*i = pfn;
+		return count;
+	}
+
+	return 0;
 }
 
+#define for_each_deferred_pfn_valid_range(i, start_pfn, end_pfn, pfn, count) \
+	for (i = (start_pfn),						     \
+	     count = __next_pfn_valid_range(&i, (end_pfn));		     \
+	     count && ({ pfn = i - count; 1; });			     \
+	     count = __next_pfn_valid_range(&i, (end_pfn)))
 /*
  * Free pages to buddy allocator. Try to free aligned pages in
  * pageblock_nr_pages sizes.
  */
-static void __init deferred_free_pages(unsigned long pfn,
+static void __init deferred_free_pages(unsigned long start_pfn,
 				       unsigned long end_pfn)
 {
-	unsigned long nr_pgmask = pageblock_nr_pages - 1;
-	unsigned long nr_free = 0;
-
-	for (; pfn < end_pfn; pfn++) {
-		if (!deferred_pfn_valid(pfn)) {
-			deferred_free_range(pfn - nr_free, nr_free);
-			nr_free = 0;
-		} else if (!(pfn & nr_pgmask)) {
-			deferred_free_range(pfn - nr_free, nr_free);
-			nr_free = 1;
-			touch_nmi_watchdog();
+	unsigned long i, pfn, count;
+
+	for_each_deferred_pfn_valid_range(i, start_pfn, end_pfn, pfn, count) {
+		struct page *page = pfn_to_page(pfn);
+
+		if (count == pageblock_nr_pages) {
+			__free_pages_boot_core(page, pageblock_order);
 		} else {
-			nr_free++;
+			while (count--)
+				__free_pages_boot_core(page++, 0);
 		}
+
+		touch_nmi_watchdog();
 	}
-	/* Free the last block of pages to allocator */
-	deferred_free_range(pfn - nr_free, nr_free);
 }
 
 /*
@@ -1564,29 +1567,22 @@ static void __init deferred_free_pages(unsigned long pfn,
  * Return number of pages initialized.
  */
 static unsigned long  __init deferred_init_pages(struct zone *zone,
-						 unsigned long pfn,
+						 unsigned long start_pfn,
 						 unsigned long end_pfn)
 {
-	unsigned long nr_pgmask = pageblock_nr_pages - 1;
+	unsigned long i, pfn, count;
 	int nid = zone_to_nid(zone);
 	unsigned long nr_pages = 0;
 	int zid = zone_idx(zone);
-	struct page *page = NULL;
 
-	for (; pfn < end_pfn; pfn++) {
-		if (!deferred_pfn_valid(pfn)) {
-			page = NULL;
-			continue;
-		} else if (!page || !(pfn & nr_pgmask)) {
-			page = pfn_to_page(pfn);
-			touch_nmi_watchdog();
-		} else {
-			page++;
-		}
-		__init_single_page(page, pfn, zid, nid);
-		nr_pages++;
+	for_each_deferred_pfn_valid_range(i, start_pfn, end_pfn, pfn, count) {
+		nr_pages += count;
+		__init_pageblock(pfn, count, zid, nid, NULL);
+
+		touch_nmi_watchdog();
 	}
-	return (nr_pages);
+
+	return nr_pages;
 }
 
 /*
