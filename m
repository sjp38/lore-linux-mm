Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CF27D6B0253
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 15:53:03 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id ez2so4441646pad.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 12:53:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ai6si56114995pad.181.2016.02.09.12.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 12:53:02 -0800 (PST)
Date: Tue, 9 Feb 2016 12:53:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page()
 when zone is contiguous
Message-Id: <20160209125301.c7e6067558c321cfb87602b5@linux-foundation.org>
In-Reply-To: <56BA28C8.3060903@suse.cz>
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com>
	<20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org>
	<CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com>
	<56BA28C8.3060903@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, 9 Feb 2016 18:58:32 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 02/05/2016 05:11 PM, Joonsoo Kim wrote:
> > Yeah, it seems wrong to me. :)
> > Here goes fix.
> 
> Doesn't apply for me, even after fixing the most obvious line wraps.
> Seems like the version in mmotm is still your original patch and
> Andrew's hotfix?

Yes, that patch was hopelessly mailer-mangled.  I painstakingly fixed
it up and generated the incremental:


From: Joonsoo Kim <js1304@gmail.com>
Subject: mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-v3

v3
o remove pfn_valid_within() check for all pages in the pageblock
because pageblock_pfn_to_page() is only called with pageblock aligned pfn.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Reported-by: Aaron Lu <aaron.lu@intel.com>
Tested-by: Aaron Lu <aaron.lu@intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |  139 ++++++++++++++++++++++------------------------
 1 file changed, 69 insertions(+), 70 deletions(-)

diff -puN mm/page_alloc.c~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-v3 mm/page_alloc.c
--- a/mm/page_alloc.c~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-v3
+++ a/mm/page_alloc.c
@@ -1128,6 +1128,75 @@ void __init __free_pages_bootmem(struct
 	return __free_pages_boot_core(page, pfn, order);
 }
 
+/*
+ * Check that the whole (or subset of) a pageblock given by the interval of
+ * [start_pfn, end_pfn) is valid and within the same zone, before scanning it
+ * with the migration of free compaction scanner. The scanners then need to
+ * use only pfn_valid_within() check for arches that allow holes within
+ * pageblocks.
+ *
+ * Return struct page pointer of start_pfn, or NULL if checks were not passed.
+ *
+ * It's possible on some configurations to have a setup like node0 node1 node0
+ * i.e. it's possible that all pages within a zones range of pages do not
+ * belong to a single zone. We assume that a border between node0 and node1
+ * can occur within a single pageblock, but not a node0 node1 node0
+ * interleaving within a single pageblock. It is therefore sufficient to check
+ * the first and last page of a pageblock and avoid checking each individual
+ * page in a pageblock.
+ */
+struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
+				     unsigned long end_pfn, struct zone *zone)
+{
+	struct page *start_page;
+	struct page *end_page;
+
+	/* end_pfn is one past the range we are checking */
+	end_pfn--;
+
+	if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
+		return NULL;
+
+	start_page = pfn_to_page(start_pfn);
+
+	if (page_zone(start_page) != zone)
+		return NULL;
+
+	end_page = pfn_to_page(end_pfn);
+
+	/* This gives a shorter code than deriving page_zone(end_page) */
+	if (page_zone_id(start_page) != page_zone_id(end_page))
+		return NULL;
+
+	return start_page;
+}
+
+void set_zone_contiguous(struct zone *zone)
+{
+	unsigned long block_start_pfn = zone->zone_start_pfn;
+	unsigned long block_end_pfn;
+
+	block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
+	for (; block_start_pfn < zone_end_pfn(zone);
+			block_start_pfn = block_end_pfn,
+			 block_end_pfn += pageblock_nr_pages) {
+
+		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
+
+		if (!__pageblock_pfn_to_page(block_start_pfn,
+					     block_end_pfn, zone))
+			return;
+	}
+
+	/* We confirm that there is no hole */
+	zone->contiguous = true;
+}
+
+void clear_zone_contiguous(struct zone *zone)
+{
+	zone->contiguous = false;
+}
+
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 static void __init deferred_free_range(struct page *page,
 					unsigned long pfn, int nr_pages)
@@ -1304,76 +1373,6 @@ void __init page_alloc_init_late(void)
 		set_zone_contiguous(zone);
 }
 
-/*
- * Check that the whole (or subset of) a pageblock given by the interval of
- * [start_pfn, end_pfn) is valid and within the same zone, before scanning it
- * with the migration of free compaction scanner. The scanners then need to
- * use only pfn_valid_within() check for arches that allow holes within
- * pageblocks.
- *
- * Return struct page pointer of start_pfn, or NULL if checks were not passed.
- *
- * It's possible on some configurations to have a setup like node0 node1 node0
- * i.e. it's possible that all pages within a zones range of pages do not
- * belong to a single zone. We assume that a border between node0 and node1
- * can occur within a single pageblock, but not a node0 node1 node0
- * interleaving within a single pageblock. It is therefore sufficient to check
- * the first and last page of a pageblock and avoid checking each individual
- * page in a pageblock.
- */
-struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
-				unsigned long end_pfn, struct zone *zone)
-{
-	struct page *start_page;
-	struct page *end_page;
-
-	/* end_pfn is one past the range we are checking */
-	end_pfn--;
-
-	if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
-		return NULL;
-
-	start_page = pfn_to_page(start_pfn);
-
-	if (page_zone(start_page) != zone)
-		return NULL;
-
-	end_page = pfn_to_page(end_pfn);
-
-	/* This gives a shorter code than deriving page_zone(end_page) */
-	if (page_zone_id(start_page) != page_zone_id(end_page))
-		return NULL;
-
-	return start_page;
-}
-
-void set_zone_contiguous(struct zone *zone)
-{
-	unsigned long block_start_pfn = zone->zone_start_pfn;
-	unsigned long block_end_pfn;
-	unsigned long pfn;
-
-	block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
-	for (; block_start_pfn < zone_end_pfn(zone);
-		block_start_pfn = block_end_pfn,
-		block_end_pfn += pageblock_nr_pages) {
-
-		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
-
-		if (!__pageblock_pfn_to_page(block_start_pfn,
-					block_end_pfn, zone))
-			return;
-	}
-
-	/* We confirm that there is no hole */
-	zone->contiguous = true;
-}
-
-void clear_zone_contiguous(struct zone *zone)
-{
-	zone->contiguous = false;
-}
-
 #ifdef CONFIG_CMA
 /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
 void __init init_cma_reserved_pageblock(struct page *page)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
