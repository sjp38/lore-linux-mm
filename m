Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB9936B0009
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 17:47:57 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id s62so2508997vke.4
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 14:47:57 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id m2si590396vkf.323.2018.03.09.14.47.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 14:47:56 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2] mm: make start_isolate_page_range() fail if already isolated
Date: Fri,  9 Mar 2018 14:47:31 -0800
Message-Id: <20180309224731.16978-1-mike.kravetz@oracle.com>
In-Reply-To: <20180226191054.14025-1-mike.kravetz@oracle.com>
References: <20180226191054.14025-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

start_isolate_page_range() is used to set the migrate type of a
set of pageblocks to MIGRATE_ISOLATE while attempting to start
a migration operation.  It assumes that only one thread is
calling it for the specified range.  This routine is used by
CMA, memory hotplug and gigantic huge pages.  Each of these users
synchronize access to the range within their subsystem.  However,
two subsystems (CMA and gigantic huge pages for example) could
attempt operations on the same range.  If this happens, one thread
may 'undo' the work another thread is doing.  This can result in
pageblocks being incorrectly left marked as MIGRATE_ISOLATE and
therefore not available for page allocation.

What is ideally needed is a way to synchronize access to a set
of pageblocks that are undergoing isolation and migration.  The
only thing we know about these pageblocks is that they are all
in the same zone.  A per-node mutex is too coarse as we want to
allow multiple operations on different ranges within the same zone
concurrently.  Instead, we will use the migration type of the
pageblocks themselves as a form of synchronization.

start_isolate_page_range sets the migration type on a set of page-
blocks going in order from the one associated with the smallest
pfn to the largest pfn.  The zone lock is acquired to check and
set the migration type.  When going through the list of pageblocks
check if MIGRATE_ISOLATE is already set.  If so, this indicates
another thread is working on this pageblock.  We know exactly
which pageblocks we set, so clean up by undo those and return
-EBUSY.

This allows start_isolate_page_range to serve as a synchronization
mechanism and will allow for more general use of callers making
use of these interfaces.  Update comments in alloc_contig_range
to reflect this new functionality.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
Changes in v2
  * Updated commit message and comments as suggested by Andrew Morton

 mm/page_alloc.c     |  8 ++++----
 mm/page_isolation.c | 18 +++++++++++++++++-
 2 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cb416723538f..02a17efac233 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7621,11 +7621,11 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
  * @gfp_mask:	GFP mask to use during compaction
  *
  * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
- * aligned, however it's the caller's responsibility to guarantee that
- * we are the only thread that changes migrate type of pageblocks the
- * pages fall in.
+ * aligned.  The PFN range must belong to a single zone.
  *
- * The PFN range must belong to a single zone.
+ * The first thing this routine does is attempt to MIGRATE_ISOLATE all
+ * pageblocks in the range.  Once isolated, the pageblocks should not
+ * be modified by others.
  *
  * Returns zero on success or negative error code.  On success all
  * pages which PFN is in [start, end) are allocated for the caller and
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 165ed8117bd1..61dee77bb211 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -28,6 +28,14 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
 
 	spin_lock_irqsave(&zone->lock, flags);
 
+	/*
+	 * We assume the caller intended to SET migrate type to isolate.
+	 * If it is already set, then someone else must have raced and
+	 * set it before us.  Return -EBUSY
+	 */
+	if (is_migrate_isolate_page(page))
+		goto out;
+
 	pfn = page_to_pfn(page);
 	arg.start_pfn = pfn;
 	arg.nr_pages = pageblock_nr_pages;
@@ -166,7 +174,15 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * future will not be allocated again.
  *
  * start_pfn/end_pfn must be aligned to pageblock_order.
- * Returns 0 on success and -EBUSY if any part of range cannot be isolated.
+ * Return 0 on success and -EBUSY if any part of range cannot be isolated.
+ *
+ * There is no high level synchronization mechanism that prevents two threads
+ * from trying to isolate overlapping ranges.  If this happens, one thread
+ * will notice pageblocks in the overlapping range already set to isolate.
+ * This happens in set_migratetype_isolate, and set_migratetype_isolate
+ * returns an error.  We then clean up by restoring the migration type on
+ * pageblocks we may have modified and return -EBUSY to caller.  This
+ * prevents two threads from simultaneously working on overlapping ranges.
  */
 int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			     unsigned migratetype, bool skip_hwpoisoned_pages)
-- 
2.13.6
