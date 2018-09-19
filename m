Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9802B8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 23:18:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b69-v6so2045507pfc.20
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 20:18:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b7-v6sor3893334plx.0.2018.09.18.20.18.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 20:18:31 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCH 1/3] mm/isolation: separate the isolation and migration ops in offline memblock
Date: Wed, 19 Sep 2018 11:17:44 +0800
Message-Id: <1537327066-27852-2-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1537327066-27852-1-git-send-email-kernelfans@gmail.com>
References: <1537327066-27852-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@techsingularity.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Michal Hocko <mhocko@suse.com>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

The current design of start_isolate_page_range() relies on MIGRATE_ISOLATE
to run against other threads. Hence the callers of start_isolate_page_range()
can only do the isolation by themselves.
But in this series, a suggested mem offline seq splits the pageblock's
isolation and migration on a memblock, i.e.
  -1. call start_isolate_page_range() on a batch of memblock
  -2. call __offline_pages() on each memblock.
This requires the ability to allow __offline_pages() to reuse the isolation

About the mark of isolation, it is not preferable to do it in
memblock, because at this level, pageblock is used, and the memblock should
be hidden. On the other hand, isolation and compaction can not run in
parallel, the PB_migrate_skip bit can be reused to mark the isolation
result of previous ops, as used by this patch. Also the prototype of
start_isolate_page_range() is changed to tell __offline_pages cases from
temporary isolation e.g. alloc_contig_range()

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-isolation.h  |  4 ++--
 include/linux/pageblock-flags.h |  2 ++
 mm/memory_hotplug.c             |  6 +++---
 mm/page_alloc.c                 |  4 ++--
 mm/page_isolation.c             | 28 +++++++++++++++++++++++-----
 5 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 4ae347c..dcc2bd1 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -47,7 +47,7 @@ int move_freepages_block(struct zone *zone, struct page *page,
  */
 int
 start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			 unsigned migratetype, bool skip_hwpoisoned_pages);
+	unsigned int migratetype, bool skip_hwpoisoned_pages, bool reuse);
 
 /*
  * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
@@ -55,7 +55,7 @@ start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
  */
 int
 undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			unsigned migratetype);
+	unsigned int migratetype, bool reuse);
 
 /*
  * Test all pages in [start_pfn, end_pfn) are isolated or not.
diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index 9132c5c..80c5341 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -31,6 +31,8 @@ enum pageblock_bits {
 	PB_migrate_end = PB_migrate + 3 - 1,
 			/* 3 bits required for migrate types */
 	PB_migrate_skip,/* If set the block is skipped by compaction */
+	PB_isolate_skip = PB_migrate_skip,
+			/* isolation and compaction do not concur */
 
 	/*
 	 * Assume the bits will always align on a word. If this assumption
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9eea6e8..228de4d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1616,7 +1616,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	/* set above range as isolated */
 	ret = start_isolate_page_range(start_pfn, end_pfn,
-				       MIGRATE_MOVABLE, true);
+				       MIGRATE_MOVABLE, true, true);
 	if (ret)
 		return ret;
 
@@ -1662,7 +1662,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
 	/* reset pagetype flags and makes migrate type to be MOVABLE */
-	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE, true);
 	/* removal success */
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
 	zone->present_pages -= offlined_pages;
@@ -1697,7 +1697,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
 	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
-	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE, true);
 	return ret;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 05e983f..a0ae259 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7882,7 +7882,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	ret = start_isolate_page_range(pfn_max_align_down(start),
 				       pfn_max_align_up(end), migratetype,
-				       false);
+				       false, false);
 	if (ret)
 		return ret;
 
@@ -7967,7 +7967,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 done:
 	undo_isolate_page_range(pfn_max_align_down(start),
-				pfn_max_align_up(end), migratetype);
+		pfn_max_align_up(end), migratetype, false);
 	return ret;
 }
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 43e0856..36858ab 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -15,8 +15,18 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/page_isolation.h>
 
+#define get_pageblock_isolate_skip(page) \
+			get_pageblock_flags_group(page, PB_isolate_skip,     \
+							PB_isolate_skip)
+#define clear_pageblock_isolate_skip(page) \
+			set_pageblock_flags_group(page, 0, PB_isolate_skip,  \
+							PB_isolate_skip)
+#define set_pageblock_isolate_skip(page) \
+			set_pageblock_flags_group(page, 1, PB_isolate_skip,  \
+							PB_isolate_skip)
+
 static int set_migratetype_isolate(struct page *page, int migratetype,
-				bool skip_hwpoisoned_pages)
+				bool skip_hwpoisoned_pages, bool reuse)
 {
 	struct zone *zone;
 	unsigned long flags, pfn;
@@ -33,8 +43,11 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
 	 * If it is already set, then someone else must have raced and
 	 * set it before us.  Return -EBUSY
 	 */
-	if (is_migrate_isolate_page(page))
+	if (is_migrate_isolate_page(page)) {
+		if (reuse && get_pageblock_isolate_skip(page))
+			ret = 0;
 		goto out;
+	}
 
 	pfn = page_to_pfn(page);
 	arg.start_pfn = pfn;
@@ -75,6 +88,8 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
 		int mt = get_pageblock_migratetype(page);
 
 		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
+		if (reuse)
+			set_pageblock_isolate_skip(page);
 		zone->nr_isolate_pageblock++;
 		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE,
 									NULL);
@@ -185,7 +200,7 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * prevents two threads from simultaneously working on overlapping ranges.
  */
 int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			     unsigned migratetype, bool skip_hwpoisoned_pages)
+	unsigned int migratetype, bool skip_hwpoisoned_pages, bool reuse)
 {
 	unsigned long pfn;
 	unsigned long undo_pfn;
@@ -199,7 +214,8 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
 		if (page &&
-		    set_migratetype_isolate(page, migratetype, skip_hwpoisoned_pages)) {
+		    set_migratetype_isolate(page, migratetype,
+			skip_hwpoisoned_pages, reuse)) {
 			undo_pfn = pfn;
 			goto undo;
 		}
@@ -222,7 +238,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
  * Make isolated pages available again.
  */
 int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			    unsigned migratetype)
+	unsigned int migratetype, bool reuse)
 {
 	unsigned long pfn;
 	struct page *page;
@@ -236,6 +252,8 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 		page = __first_valid_page(pfn, pageblock_nr_pages);
 		if (!page || !is_migrate_isolate_page(page))
 			continue;
+		if (reuse)
+			clear_pageblock_isolate_skip(page);
 		unset_migratetype_isolate(page, migratetype);
 	}
 	return 0;
-- 
2.7.4
