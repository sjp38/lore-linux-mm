Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47FFA6B0009
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 14:11:32 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id n5so13479489qti.10
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 11:11:32 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h58si3507786qta.468.2018.02.26.11.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 11:11:31 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/1] mm: make start_isolate_page_range() fail if already isolated
Date: Mon, 26 Feb 2018 11:10:54 -0800
Message-Id: <20180226191054.14025-2-mike.kravetz@oracle.com>
In-Reply-To: <20180226191054.14025-1-mike.kravetz@oracle.com>
References: <20180226191054.14025-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

start_isolate_page_range() is used to set the migrate type of a
set of page blocks to MIGRATE_ISOLATE while attempting to start
a migration operation.  It assumes that only one thread is
calling it for the specified range.  This routine is used by
CMA, memory hotplug and gigantic huge pages.  Each of these users
synchronize access to the range within their subsystem.  However,
two subsystems (CMA and gigantic huge pages for example) could
attempt operations on the same range.  If this happens, page
blocks may be incorrectly left marked as MIGRATE_ISOLATE and
therefore not available for page allocation.

Without 'locking code' there is no easy way to synchronize access
to the range of page blocks passed to start_isolate_page_range.
However, if two threads are working on the same set of page blocks
one will stumble upon blocks set to MIGRATE_ISOLATE by the other.
In such conditions, make the thread noticing MIGRATE_ISOLATE
clean up as normal and return -EBUSY to the caller.

This will allow start_isolate_page_range to serve as a
synchronization mechanism and will allow for more general use
of callers making use of these interfaces.  So, update comments
in alloc_contig_range to reflect this new functionality.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/page_alloc.c     |  8 ++++----
 mm/page_isolation.c | 10 +++++++++-
 2 files changed, 13 insertions(+), 5 deletions(-)

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
index 165ed8117bd1..70d01ec5b463 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -28,6 +28,13 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
 
 	spin_lock_irqsave(&zone->lock, flags);
 
+	/*
+	 * We assume we are the only ones trying to isolate this block.
+	 * If MIGRATE_ISOLATE already set, return -EBUSY
+	 */
+	if (is_migrate_isolate_page(page))
+		goto out;
+
 	pfn = page_to_pfn(page);
 	arg.start_pfn = pfn;
 	arg.nr_pages = pageblock_nr_pages;
@@ -166,7 +173,8 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * future will not be allocated again.
  *
  * start_pfn/end_pfn must be aligned to pageblock_order.
- * Returns 0 on success and -EBUSY if any part of range cannot be isolated.
+ * Return 0 on success and -EBUSY if any part of range cannot be isolated
+ * or any part of the range is already set to MIGRATE_ISOLATE.
  */
 int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			     unsigned migratetype, bool skip_hwpoisoned_pages)
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
