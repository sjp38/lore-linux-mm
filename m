Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF5B6B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 03:30:41 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p192so34891605wme.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 00:30:41 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id v130si21385340wmd.161.2017.01.25.00.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 00:30:39 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 700741C1AB9
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:30:39 +0000 (GMT)
Date: Wed, 25 Jan 2017 08:30:38 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, page_alloc: Use static global work_struct for draining
 per-cpu pages
Message-ID: <20170125083038.rzb5f43nptmk7aed@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

As suggested by Vlastimil Babka and Tejun Heo, this patch uses a static
work_struct to co-ordinate the draining of per-cpu pages on the workqueue.
Only one task can drain at a time but this is better than the previous
scheme that allowed multiple tasks to send IPIs at a time.

One consideration is whether parallel requests should synchronise against
each other. This patch does not synchronise for a global drain as the common
case for such callers is expected to be multiple parallel direct reclaimers
competing for pages when the watermark is close to min. Draining the per-cpu
list is unlikely to make much progress and serialising the drain is of
dubious merit. Drains are synchonrised for callers such as memory hotplug
and CMA that care about the drain being complete when the function returns.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 41 +++++++++++++++++++++++------------------
 1 file changed, 23 insertions(+), 18 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e87508ffa759..da6be2a5ff7a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -92,6 +92,10 @@ EXPORT_PER_CPU_SYMBOL(_numa_mem_);
 int _node_numa_mem_[MAX_NUMNODES];
 #endif
 
+/* work_structs for global per-cpu drains */
+DEFINE_MUTEX(pcpu_drain_mutex);
+DEFINE_PER_CPU(struct work_struct, pcpu_drain);
+
 #ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
 volatile unsigned long latent_entropy __latent_entropy;
 EXPORT_SYMBOL(latent_entropy);
@@ -2351,7 +2355,6 @@ static void drain_local_pages_wq(struct work_struct *work)
  */
 void drain_all_pages(struct zone *zone)
 {
-	struct work_struct __percpu *works;
 	int cpu;
 
 	/*
@@ -2365,11 +2368,21 @@ void drain_all_pages(struct zone *zone)
 		return;
 
 	/*
+	 * Do not drain if one is already in progress unless it's specific to
+	 * a zone. Such callers are primarily CMA and memory hotplug and need
+	 * the drain to be complete when the call returns.
+	 */
+	if (unlikely(!mutex_trylock(&pcpu_drain_mutex))) {
+		if (!zone)
+			return;
+		mutex_lock(&pcpu_drain_mutex);
+	}
+
+	/*
 	 * As this can be called from reclaim context, do not reenter reclaim.
 	 * An allocation failure can be handled, it's simply slower
 	 */
 	get_online_cpus();
-	works = alloc_percpu_gfp(struct work_struct, GFP_ATOMIC);
 
 	/*
 	 * We don't care about racing with CPU hotplug event
@@ -2402,24 +2415,16 @@ void drain_all_pages(struct zone *zone)
 			cpumask_clear_cpu(cpu, &cpus_with_pcps);
 	}
 
-	if (works) {
-		for_each_cpu(cpu, &cpus_with_pcps) {
-			struct work_struct *work = per_cpu_ptr(works, cpu);
-			INIT_WORK(work, drain_local_pages_wq);
-			schedule_work_on(cpu, work);
-		}
-		for_each_cpu(cpu, &cpus_with_pcps)
-			flush_work(per_cpu_ptr(works, cpu));
-	} else {
-		for_each_cpu(cpu, &cpus_with_pcps) {
-			struct work_struct work;
-
-			INIT_WORK(&work, drain_local_pages_wq);
-			schedule_work_on(cpu, &work);
-			flush_work(&work);
-		}
+	for_each_cpu(cpu, &cpus_with_pcps) {
+		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
+		INIT_WORK(work, drain_local_pages_wq);
+		schedule_work_on(cpu, work);
 	}
+	for_each_cpu(cpu, &cpus_with_pcps)
+		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
+
 	put_online_cpus();
+	mutex_unlock(&pcpu_drain_mutex);
 }
 
 #ifdef CONFIG_HIBERNATION

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
