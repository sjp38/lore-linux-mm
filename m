Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7E48E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 18:04:56 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r13so2803781pgb.7
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 15:04:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a9si18754504plp.323.2018.12.20.15.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 15:04:54 -0800 (PST)
Date: Thu, 20 Dec 2018 15:04:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, page_alloc: calculate first_deferred_pfn directly
Message-Id: <20181220150451.e89fc059660fc08e9c108d2f@linux-foundation.org>
In-Reply-To: <20181207100859.8999-1-richard.weiyang@gmail.com>
References: <20181207100859.8999-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, pavel.tatashin@microsoft.com, mhocko@suse.com

Does anyone care to review this one?

Thanks.


From: Wei Yang <richard.weiyang@gmail.com>
Subject: mm/page_alloc.c: calculate first_deferred_pfn directly

After c9e97a1997fb ("mm: initialize pages on demand during boot"), the
behavior of DEFERRED_STRUCT_PAGE_INIT is changed to initialize the first
section for the highest zone on each node.

Instead of testing each pfn during the iteration, we can calculate the
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

Link: http://lkml.kernel.org/r/20181207100859.8999-1-richard.weiyang@gmail.com
Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
Cc: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <OSalvador@suse.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |   57 +++++++++++++++++++++-------------------------
 1 file changed, 27 insertions(+), 30 deletions(-)

--- a/mm/page_alloc.c~mm-page_alloc-calculate-first_deferred_pfn-directly
+++ a/mm/page_alloc.c
@@ -306,38 +306,33 @@ static inline bool __meminit early_page_
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
@@ -345,9 +340,11 @@ static inline bool early_page_uninitiali
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
 
@@ -5785,6 +5782,8 @@ void __meminit memmap_init_zone(unsigned
 		return;
 	}
 
+	end_pfn = defer_pfn(nid, start_pfn, end_pfn, context);
+
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		struct page *page;
 
@@ -5798,8 +5797,6 @@ void __meminit memmap_init_zone(unsigned
 			continue;
 		if (overlap_memmap_init(zone, &pfn))
 			continue;
-		if (defer_init(nid, pfn, end_pfn))
-			break;
 
 		page = pfn_to_page(pfn);
 		__init_single_page(page, pfn, zone, nid);
_
