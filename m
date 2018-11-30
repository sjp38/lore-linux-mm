Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C7E9A6B5A79
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 16:53:25 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id f69so5520200pff.5
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 13:53:25 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t6si6239072pgn.258.2018.11.30.13.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 13:53:24 -0800 (PST)
Subject: [mm PATCH v6 7/7] mm: Use common iterator for deferred_init_pages
 and deferred_free_pages
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Fri, 30 Nov 2018 13:53:23 -0800
Message-ID: <154361480390.7497.9730184349746888133.stgit@ahduyck-desk1.amr.corp.intel.com>
In-Reply-To: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
References: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.comalexander.h.duyck@linux.intel.com

Create a common iterator to be used by both deferred_init_pages and
deferred_free_pages. By doing this we can cut down a bit on code overhead
as they will likely both be inlined into the same function anyway.

This new approach allows deferred_init_pages to make use of
__init_pageblock. By doing this we can cut down on the code size by sharing
code between both the hotplug and deferred memory init code paths.

An additional benefit to this approach is that we improve in cache locality
of the memory init as we can focus on the memory areas related to
identifying if a given PFN is valid and keep that warm in the cache until
we transition to a region of a different type. So we will stream through a
chunk of valid blocks before we turn to initializing page structs.

On my x86_64 test system with 384GB of memory per node I saw a reduction in
initialization time from 1.38s to 1.06s as a result of this patch.

Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/page_alloc.c |  146 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 77 insertions(+), 69 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 61eb9945d805..48c6fc73a70d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1481,32 +1481,6 @@ void clear_zone_contiguous(struct zone *zone)
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
-		__free_pages_core(page, pageblock_order);
-		return;
-	}
-
-	for (i = 0; i < nr_pages; i++, page++, pfn++) {
-		if ((pfn & (pageblock_nr_pages - 1)) == 0)
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-		__free_pages_core(page, 0);
-	}
-}
-
 /* Completion tracking for deferred_init_memmap() threads */
 static atomic_t pgdat_init_n_undone __initdata;
 static __initdata DECLARE_COMPLETION(pgdat_init_all_done_comp);
@@ -1518,48 +1492,89 @@ static inline void __init pgdat_init_report_one_done(void)
 }
 
 /*
- * Returns true if page needs to be initialized or freed to buddy allocator.
+ * Returns count if page range needs to be initialized or freed
  *
- * First we check if pfn is valid on architectures where it is possible to have
- * holes within pageblock_nr_pages. On systems where it is not possible, this
- * function is optimized out.
+ * First we check if the contiguous pfns are valid on architectures where it
+ * is possible to have holes within pageblock_nr_pages. On systems where it
+ * is not possible, this function is optimized out.
+ *
+ * Then, we check if a current large page is valid by only checking the
+ * validity of the head pfn.
  *
- * Then, we check if a current large page is valid by only checking the validity
- * of the head pfn.
  */
-static inline bool __init deferred_pfn_valid(unsigned long pfn)
+static unsigned long __next_pfn_valid_range(unsigned long *pfn,
+					    unsigned long *i,
+					    unsigned long end_pfn)
 {
-	if (!pfn_valid_within(pfn))
-		return false;
-	if (!(pfn & (pageblock_nr_pages - 1)) && !pfn_valid(pfn))
-		return false;
-	return true;
+	unsigned long start_pfn = *i;
+
+	while (start_pfn < end_pfn) {
+		unsigned long t = ALIGN(start_pfn + 1, pageblock_nr_pages);
+		unsigned long pageblock_pfn = min(t, end_pfn);
+		unsigned long count = 0;
+
+#ifndef CONFIG_HOLES_IN_ZONE
+		if (pfn_valid(start_pfn))
+			count = pageblock_pfn - start_pfn;
+		start_pfn = pageblock_pfn;
+#else
+		while (start_pfn < pageblock_pfn) {
+			if (pfn_valid(start_pfn++)) {
+				count++;
+				continue;
+			}
+
+			if (!count)
+				continue;
+
+			/*
+			 * The last PFN was invalid, report the block of
+			 * PFNs we currently have available and skip over
+			 * the invalid one.
+			 */
+			*pfn = start_pfn - (count + 1);
+			*i = start_pfn;
+			return count;
+		}
+#endif
+		if (!count)
+			continue;
+
+		*pfn = start_pfn - count;
+		*i = start_pfn;
+		return count;
+	}
+
+	return 0;
 }
 
+#define for_each_deferred_pfn_valid_range(pfn, count, i, start_pfn, end_pfn) \
+	for (i = (start_pfn),						     \
+	     count = __next_pfn_valid_range(&pfn, &i, (end_pfn));	     \
+	     count;							     \
+	     count = __next_pfn_valid_range(&pfn, &i, (end_pfn)))
+
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
+	for_each_deferred_pfn_valid_range(pfn, count, i, start_pfn, end_pfn) {
+		struct page *page = pfn_to_page(pfn);
+
+		if (count == pageblock_nr_pages) {
+			__free_pages_core(page, pageblock_order);
 		} else {
-			nr_free++;
+			while (count--)
+				__free_pages_core(page++, 0);
 		}
+
+		touch_nmi_watchdog();
 	}
-	/* Free the last block of pages to allocator */
-	deferred_free_range(pfn - nr_free, nr_free);
 }
 
 /*
@@ -1568,29 +1583,22 @@ static void __init deferred_free_pages(unsigned long pfn,
  * Return number of pages initialized.
  */
 static unsigned long  __init deferred_init_pages(struct zone *zone,
-						 unsigned long pfn,
+						 unsigned long start_pfn,
 						 unsigned long end_pfn)
 {
-	unsigned long nr_pgmask = pageblock_nr_pages - 1;
 	int nid = zone_to_nid(zone);
+	unsigned long i, pfn, count;
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
+	for_each_deferred_pfn_valid_range(pfn, count, i, start_pfn, end_pfn) {
+		nr_pages += count;
+		__init_pageblock(pfn, count, zid, nid, NULL, false);
+
+		touch_nmi_watchdog();
 	}
-	return (nr_pages);
+
+	return nr_pages;
 }
 
 /*
