From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301100450.29753.26488.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
References: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 7/12] Drain per-cpu lists when high-order allocations fail
Date: Thu,  1 Mar 2007 10:04:50 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Per-cpu pages can accidentally cause fragmentation because they are free, but
pinned pages in an otherwise contiguous block.  When this patch is applied,
the per-cpu caches are drained after the direct-reclaim is entered if the
requested order is greater than 0. It simply reuses the code used by suspend
and hotplug.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 page_alloc.c |   28 +++++++++++++++++++++++++++-
 1 files changed, 27 insertions(+), 1 deletion(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-006_configurable/mm/page_alloc.c linux-2.6.20-mm2-007_drainpercpu/mm/page_alloc.c
--- linux-2.6.20-mm2-006_configurable/mm/page_alloc.c	2007-02-20 18:33:41.000000000 +0000
+++ linux-2.6.20-mm2-007_drainpercpu/mm/page_alloc.c	2007-02-20 18:35:52.000000000 +0000
@@ -916,7 +916,9 @@ void mark_free_pages(struct zone *zone)
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
+#endif /* CONFIG_PM */
 
+#if defined(CONFIG_PM) || defined(CONFIG_PAGE_GROUP_BY_MOBILITY)
 /*
  * Spill all of this CPU's per-cpu pages back into the buddy allocator.
  */
@@ -928,7 +930,28 @@ void drain_local_pages(void)
 	__drain_pages(smp_processor_id());
 	local_irq_restore(flags);	
 }
-#endif /* CONFIG_PM */
+
+void smp_drain_local_pages(void *arg)
+{
+	drain_local_pages();
+}
+
+/*
+ * Spill all the per-cpu pages from all CPUs back into the buddy allocator
+ */
+void drain_all_local_pages(void)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__drain_pages(smp_processor_id());
+	local_irq_restore(flags);
+
+	smp_call_function(smp_drain_local_pages, NULL, 0, 1);
+}
+#else
+void drain_all_local_pages(void) {}
+#endif /* CONFIG_PM || CONFIG_PAGE_GROUP_BY_MOBILITY */
 
 /*
  * Free a 0-order page
@@ -1557,6 +1580,9 @@ nofail_alloc:
 
 	cond_resched();
 
+	if (order != 0)
+		drain_all_local_pages();
+
 	if (likely(did_some_progress)) {
 		page = get_page_from_freelist(gfp_mask, order,
 						zonelist, alloc_flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
