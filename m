Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8DF6B02C6
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 10:04:59 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r196so1057995wmf.3
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 07:04:59 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r58si1550523edd.139.2017.11.07.07.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 07:04:57 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v1 1/1] mm: split deferred_init_range into initializing and freeing parts
Date: Tue,  7 Nov 2017 10:04:46 -0500
Message-Id: <20171107150446.32055-2-pasha.tatashin@oracle.com>
In-Reply-To: <20171107150446.32055-1-pasha.tatashin@oracle.com>
References: <20171107150446.32055-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In deferred_init_range() we initialize struct pages, and also free them to
buddy allocator. We do it in separate loops, because buddy page is computed
ahead, so we do not want to access a struct page that has not been
initialized yet.

There is still, however, a corner case where it is potentially possible to
access uninitialized struct page: this is when buddy page is from the next
memblock range.

This patch fixes this problem by splitting deferred_init_range() into two
functions: one to initialize struct pages, and another to free them.

In addition, this patch brings the following improvements:
- Get rid of __def_free() helper function. And simplifies loop logic by
  adding a new pfn validity check function: deferred_pfn_valid().
- Reduces number of variables that we track. So, there is a higher chance
  that we will avoid using stack to store/load variables inside hot loops.
- Enables future multi-threading of these functions: do initialization in
  multiple threads, wait for all threads to finish, do freeing part in
  multithreading.

Tested on x86 with 1T of memory to make sure no regressions are introduced.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/page_alloc.c | 146 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 76 insertions(+), 70 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 536431bf0f0c..d9f1e7159af8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1457,92 +1457,87 @@ static inline void __init pgdat_init_report_one_done(void)
 }
 
 /*
- * Helper for deferred_init_range, free the given range, reset the counters, and
- * return number of pages freed.
+ * Returns true if page needs to be initialized of freed to buddy allocator.
+ *
+ * First we check if pfn is valid on architectures where it is possible to have
+ * holes within pageblock_nr_pages. On systems where it is not possible, this
+ * function is optimized out.
+ *
+ * Then, we check if a current large page is valid by only checking the validity
+ * of the head pfn.
+ *
+ * Finally, meminit_pfn_in_nid is checked on systems where pfns can interleave
+ * within a node: a pfn is between start and end of a node, but does not belong
+ * to this memory node.
  */
-static inline unsigned long __init __def_free(unsigned long *nr_free,
-					      unsigned long *free_base_pfn,
-					      struct page **page)
+static inline bool __init
+deferred_pfn_valid(int nid, unsigned long pfn,
+		   struct mminit_pfnnid_cache *nid_init_state)
 {
-	unsigned long nr = *nr_free;
+	if (!pfn_valid_within(pfn))
+		return false;
+	if (!(pfn & (pageblock_nr_pages - 1)) && !pfn_valid(pfn))
+		return false;
+	if (!meminit_pfn_in_nid(pfn, nid, nid_init_state))
+		return false;
+	return true;
+}
 
-	deferred_free_range(*free_base_pfn, nr);
-	*free_base_pfn = 0;
-	*nr_free = 0;
-	*page = NULL;
+/*
+ * Free pages to buddy allocator. Try to free aligned pages in
+ * pageblock_nr_pages sizes.
+ */
+static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
+				       unsigned long end_pfn)
+{
+	struct mminit_pfnnid_cache nid_init_state = { };
+	unsigned long nr_pgmask = pageblock_nr_pages - 1;
+	unsigned long nr_free = 0;
 
-	return nr;
+	for (; pfn < end_pfn; pfn++) {
+		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
+			deferred_free_range(pfn - nr_free, nr_free);
+			nr_free = 0;
+		} else if (!(pfn & nr_pgmask)) {
+			deferred_free_range(pfn - nr_free, nr_free);
+			nr_free = 1;
+			cond_resched();
+		} else {
+			nr_free++;
+		}
+	}
+	/* Free the last block of pages to allocator */
+	deferred_free_range(pfn - nr_free, nr_free);
 }
 
-static unsigned long __init deferred_init_range(int nid, int zid,
-						unsigned long start_pfn,
-						unsigned long end_pfn)
+/*
+ * Initialize struct pages.  We minimize pfn page lookups and scheduler checks
+ * by performing it only once every pageblock_nr_pages.
+ * Return number of pages initialized.
+ */
+static unsigned long  __init deferred_init_pages(int nid, int zid,
+						 unsigned long pfn,
+						 unsigned long end_pfn)
 {
 	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
-	unsigned long free_base_pfn = 0;
 	unsigned long nr_pages = 0;
-	unsigned long nr_free = 0;
 	struct page *page = NULL;
-	unsigned long pfn;
 
-	/*
-	 * First we check if pfn is valid on architectures where it is possible
-	 * to have holes within pageblock_nr_pages. On systems where it is not
-	 * possible, this function is optimized out.
-	 *
-	 * Then, we check if a current large page is valid by only checking the
-	 * validity of the head pfn.
-	 *
-	 * meminit_pfn_in_nid is checked on systems where pfns can interleave
-	 * within a node: a pfn is between start and end of a node, but does not
-	 * belong to this memory node.
-	 *
-	 * Finally, we minimize pfn page lookups and scheduler checks by
-	 * performing it only once every pageblock_nr_pages.
-	 *
-	 * We do it in two loops: first we initialize struct page, than free to
-	 * buddy allocator, becuse while we are freeing pages we can access
-	 * pages that are ahead (computing buddy page in __free_one_page()).
-	 */
-	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
-		if (!pfn_valid_within(pfn))
+	for (; pfn < end_pfn; pfn++) {
+		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
+			page = NULL;
 			continue;
-		if ((pfn & nr_pgmask) || pfn_valid(pfn)) {
-			if (meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
-				if (page && (pfn & nr_pgmask))
-					page++;
-				else
-					page = pfn_to_page(pfn);
-				__init_single_page(page, pfn, zid, nid);
-				cond_resched();
-			}
-		}
-	}
-
-	page = NULL;
-	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
-		if (!pfn_valid_within(pfn)) {
-			nr_pages += __def_free(&nr_free, &free_base_pfn, &page);
-		} else if (!(pfn & nr_pgmask) && !pfn_valid(pfn)) {
-			nr_pages += __def_free(&nr_free, &free_base_pfn, &page);
-		} else if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
-			nr_pages += __def_free(&nr_free, &free_base_pfn, &page);
-		} else if (page && (pfn & nr_pgmask)) {
-			page++;
-			nr_free++;
-		} else {
-			nr_pages += __def_free(&nr_free, &free_base_pfn, &page);
+		} else if (!page || !(pfn & nr_pgmask)) {
 			page = pfn_to_page(pfn);
-			free_base_pfn = pfn;
-			nr_free = 1;
 			cond_resched();
+		} else {
+			page++;
 		}
+		__init_single_page(page, pfn, zid, nid);
+		nr_pages++;
 	}
-	/* Free the last block of pages to allocator */
-	nr_pages += __def_free(&nr_free, &free_base_pfn, &page);
-
-	return nr_pages;
+	return (nr_pages);
 }
 
 /* Initialise remaining memory on a node */
@@ -1582,10 +1577,21 @@ static int __init deferred_init_memmap(void *data)
 	}
 	first_init_pfn = max(zone->zone_start_pfn, first_init_pfn);
 
+	/*
+	 * Initialize and free pages. We do it in two loops: first we initialize
+	 * struct page, than free to buddy allocator, because while we are
+	 * freeing pages we can access pages that are ahead (computing buddy
+	 * page in __free_one_page()).
+	 */
+	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
+		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
+		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
+		nr_pages += deferred_init_pages(nid, zid, spfn, epfn);
+	}
 	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
 		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
 		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
-		nr_pages += deferred_init_range(nid, zid, spfn, epfn);
+		deferred_free_pages(nid, zid, spfn, epfn);
 	}
 
 	/* Sanity check that the next zone really is unpopulated */
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
