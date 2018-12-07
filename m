Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7C1F8E0001
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 05:09:15 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r16so2233417pgr.15
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 02:09:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j1sor4580489plk.57.2018.12.07.02.09.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 02:09:14 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, page_alloc: calculate first_deferred_pfn directly
Date: Fri,  7 Dec 2018 18:08:59 +0800
Message-Id: <20181207100859.8999-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: pavel.tatashin@microsoft.com, akpm@linux-foundation.org, mhocko@suse.com, Wei Yang <richard.weiyang@gmail.com>

After commit c9e97a1997fb ("mm: initialize pages on demand during
boot"), the behavior of DEFERRED_STRUCT_PAGE_INIT is changed to
initialize first section for highest zone on each node.

Instead of test each pfn during iteration, we could calculate the
first_deferred_pfn directly with necessary information.

By doing so, we also get some performance benefit during bootup:

    +----------+-----------+-----------+--------+
    |          |Base       |Patched    |Gain    |
    +----------+-----------+-----------+--------+
    | 1 Node   |0.011993   |0.011459   |-4.45%  |
    +----------+-----------+-----------+--------+
    | 4 Nodes  |0.006466   |0.006255   |-3.26%  |
    +----------+-----------+-----------+--------+

Test result is retrieved from dmesg time stamp by add printk around
free_area_init_nodes().

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 57 +++++++++++++++++++++++++++------------------------------
 1 file changed, 27 insertions(+), 30 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index baf473f80800..5f077bf07f3e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -306,38 +306,33 @@ static inline bool __meminit early_page_uninitialised(unsigned long pfn)
 }
 
 /*
- * Returns true when the remaining initialisation should be deferred until
- * later in the boot cycle when it can be parallelised.
+ * Calculate first_deferred_pfn in case:
+ * - in MEMMAP_EARLY context
+ * - this is the last zone
+ *
+ * If the first aligned section doesn't exceed the end_pfn, set it to
+ * first_deferred_pfn and return it.
  */
-static bool __meminit
-defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
+unsigned long __meminit
+defer_pfn(int nid, unsigned long start_pfn, unsigned long end_pfn,
+	  enum memmap_context context)
 {
-	static unsigned long prev_end_pfn, nr_initialised;
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	unsigned long pfn;
 
-	/*
-	 * prev_end_pfn static that contains the end of previous zone
-	 * No need to protect because called very early in boot before smp_init.
-	 */
-	if (prev_end_pfn != end_pfn) {
-		prev_end_pfn = end_pfn;
-		nr_initialised = 0;
-	}
+	if (context != MEMMAP_EARLY)
+		return end_pfn;
 
-	/* Always populate low zones for address-constrained allocations */
-	if (end_pfn < pgdat_end_pfn(NODE_DATA(nid)))
-		return false;
+	/* Always populate low zones */
+	if (end_pfn < pgdat_end_pfn(pgdat))
+		return end_pfn;
 
-	/*
-	 * We start only with one section of pages, more pages are added as
-	 * needed until the rest of deferred pages are initialized.
-	 */
-	nr_initialised++;
-	if ((nr_initialised > PAGES_PER_SECTION) &&
-	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
-		NODE_DATA(nid)->first_deferred_pfn = pfn;
-		return true;
+	pfn = roundup(start_pfn + PAGES_PER_SECTION - 1, PAGES_PER_SECTION);
+	if (end_pfn > pfn) {
+		pgdat->first_deferred_pfn = pfn;
+		end_pfn = pfn;
 	}
-	return false;
+	return end_pfn;
 }
 #else
 static inline bool early_page_uninitialised(unsigned long pfn)
@@ -345,9 +340,11 @@ static inline bool early_page_uninitialised(unsigned long pfn)
 	return false;
 }
 
-static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
+unsigned long __meminit
+defer_pfn(int nid, unsigned long start_pfn, unsigned long end_pfn,
+	  enum memmap_context context)
 {
-	return false;
+	return end_pfn;
 }
 #endif
 
@@ -5514,6 +5511,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	}
 #endif
 
+	end_pfn = defer_pfn(nid, start_pfn, end_pfn, context);
+
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
 		 * There can be holes in boot-time mem_map[]s handed to this
@@ -5526,8 +5525,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 				continue;
 			if (overlap_memmap_init(zone, &pfn))
 				continue;
-			if (defer_init(nid, pfn, end_pfn))
-				break;
 		}
 
 		page = pfn_to_page(pfn);
-- 
2.15.1
