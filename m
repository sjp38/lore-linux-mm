From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20060126184605.8550.1746.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20060126184305.8550.94358.sendpatchset@skynet.csn.ul.ie>
References: <20060126184305.8550.94358.sendpatchset@skynet.csn.ul.ie>
Subject: [PATCH 9/9] ForTesting - Drain the per-cpu caches with high order allocations fail
Date: Thu, 26 Jan 2006 18:46:05 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

The presense of free per-cpu pages appear to cause fragmentation because
contiguous free blocks do not merge with their buddies. This can skew the
results between runs a lot because how many HugeTLB pages there are available
depends on luck. This patch was applied to both stock and anti-frag kernels
to give more consistant results.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.16-rc1-mm3-902_highorderoom/mm/page_alloc.c linux-2.6.16-rc1-mm3-903_drainpercpu/mm/page_alloc.c
--- linux-2.6.16-rc1-mm3-902_highorderoom/mm/page_alloc.c	2006-01-26 18:15:07.000000000 +0000
+++ linux-2.6.16-rc1-mm3-903_drainpercpu/mm/page_alloc.c	2006-01-26 18:15:49.000000000 +0000
@@ -623,7 +623,8 @@ void drain_remote_pages(void)
 }
 #endif
 
-#if defined(CONFIG_PM) || defined(CONFIG_HOTPLUG_CPU)
+#if defined(CONFIG_PM) || \
+	defined(CONFIG_HOTPLUG_CPU)
 static void __drain_pages(unsigned int cpu)
 {
 	unsigned long flags;
@@ -685,6 +686,27 @@ void drain_local_pages(void)
 	__drain_pages(smp_processor_id());
 	local_irq_restore(flags);	
 }
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
 #endif /* CONFIG_PM */
 
 static void zone_statistics(struct zonelist *zonelist, struct zone *z, int cpu)
@@ -1073,6 +1095,9 @@ rebalance:
 
 	did_some_progress = try_to_free_pages(zonelist->zones, gfp_mask);
 
+	if (order > 3)
+		drain_all_local_pages();
+
 	p->reclaim_state = NULL;
 	p->flags &= ~PF_MEMALLOC;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
