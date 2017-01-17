Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 694416B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 04:29:57 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r126so32254373wmr.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:29:57 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id s22si15254118wme.155.2017.01.17.01.29.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 01:29:56 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id E1FD598E5F
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 09:29:55 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue context
Date: Tue, 17 Jan 2017 09:29:53 +0000
Message-Id: <20170117092954.15413-4-mgorman@techsingularity.net>
In-Reply-To: <20170117092954.15413-1-mgorman@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

The per-cpu page allocator can be drained immediately via drain_all_pages()
which sends IPIs to every CPU. In the next patch, the per-cpu allocator
will only be used for interrupt-safe allocations which prevents draining
it from IPI context. This patch uses workqueues to drain the per-cpu
lists instead.

This is slower but no slowdown during intensive reclaim was measured and
the paths that use drain_all_pages() are not that sensitive to performance.
This is particularly true as the path would only be triggered when reclaim
is failing. It also makes a some sense to avoid storming a machine with IPIs
when it's under memory pressure. Arguably, it should be further adjusted
so that only one caller at a time is draining pages but it's beyond the
scope of the current patch.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 42 +++++++++++++++++++++++++++++++++++-------
 1 file changed, 35 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d15527a20dce..9c3a0fcf8c13 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2341,19 +2341,21 @@ void drain_local_pages(struct zone *zone)
 		drain_pages(cpu);
 }
 
+static void drain_local_pages_wq(struct work_struct *work)
+{
+	drain_local_pages(NULL);
+}
+
 /*
  * Spill all the per-cpu pages from all CPUs back into the buddy allocator.
  *
  * When zone parameter is non-NULL, spill just the single zone's pages.
  *
- * Note that this code is protected against sending an IPI to an offline
- * CPU but does not guarantee sending an IPI to newly hotplugged CPUs:
- * on_each_cpu_mask() blocks hotplug and won't talk to offlined CPUs but
- * nothing keeps CPUs from showing up after we populated the cpumask and
- * before the call to on_each_cpu_mask().
+ * Note that this can be extremely slow as the draining happens in a workqueue.
  */
 void drain_all_pages(struct zone *zone)
 {
+	struct work_struct __percpu *works;
 	int cpu;
 
 	/*
@@ -2362,6 +2364,16 @@ void drain_all_pages(struct zone *zone)
 	 */
 	static cpumask_t cpus_with_pcps;
 
+	/* Workqueues cannot recurse */
+	if (current->flags & PF_WQ_WORKER)
+		return;
+
+	/*
+	 * As this can be called from reclaim context, do not reenter reclaim.
+	 * An allocation failure can be handled, it's simply slower
+	 */
+	works = alloc_percpu_gfp(struct work_struct, GFP_ATOMIC);
+
 	/*
 	 * We don't care about racing with CPU hotplug event
 	 * as offline notification will cause the notified
@@ -2392,8 +2404,24 @@ void drain_all_pages(struct zone *zone)
 		else
 			cpumask_clear_cpu(cpu, &cpus_with_pcps);
 	}
-	on_each_cpu_mask(&cpus_with_pcps, (smp_call_func_t) drain_local_pages,
-								zone, 1);
+
+	if (works) {
+		for_each_cpu(cpu, &cpus_with_pcps) {
+			struct work_struct *work = per_cpu_ptr(works, cpu);
+			INIT_WORK(work, drain_local_pages_wq);
+			schedule_work_on(cpu, work);
+		}
+		for_each_cpu(cpu, &cpus_with_pcps)
+			flush_work(per_cpu_ptr(works, cpu));
+	} else {
+		for_each_cpu(cpu, &cpus_with_pcps) {
+			struct work_struct work;
+
+			INIT_WORK(&work, drain_local_pages_wq);
+			schedule_work_on(cpu, &work);
+			flush_work(&work);
+		}
+	}
 }
 
 #ifdef CONFIG_HIBERNATION
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
