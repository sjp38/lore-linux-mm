Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA9C8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:26:11 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id b17so15439436pfc.11
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 06:26:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c84sor28474771pfe.49.2018.12.12.06.26.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 06:26:10 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v2] mm, page_alloc: enable pcpu_drain with zone capability
Date: Wed, 12 Dec 2018 22:25:50 +0800
Message-Id: <20181212142550.61686-1-richard.weiyang@gmail.com>
In-Reply-To: <20181212002933.53337-1-richard.weiyang@gmail.com>
References: <20181212002933.53337-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de, david@redhat.com, Wei Yang <richard.weiyang@gmail.com>

drain_all_pages is documented to drain per-cpu pages for a given zone (if
non-NULL). The current implementation doesn't match the description though.
It will drain all pcp pages for all zones that happen to have cached pages
on the same cpu as the given zone. This will leave to premature pcp cache
draining for zones that are not of an interest for the caller - e.g.
compaction, hwpoison or memory offline.

This would force the page allocator to take locks and potential lock
contention as a result.

There is no real reason for this sub-optimal implementnation. Replace
per-cpu work item with a dedicated structure which contains a pointer to
zone and pass it over to the worker. This will get the zone information all
the way down to the worker function and do the right job.

[mhocko@suse.com: refactor the whole changelog]

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
v2:
   * refactor changelog from Michal's suggestion
---
 mm/page_alloc.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 65db26995466..eb4df3f63f5e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -96,8 +96,12 @@ int _node_numa_mem_[MAX_NUMNODES];
 #endif
 
 /* work_structs for global per-cpu drains */
+struct pcpu_drain {
+	struct zone *zone;
+	struct work_struct work;
+};
 DEFINE_MUTEX(pcpu_drain_mutex);
-DEFINE_PER_CPU(struct work_struct, pcpu_drain);
+DEFINE_PER_CPU(struct pcpu_drain, pcpu_drain);
 
 #ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
 volatile unsigned long latent_entropy __latent_entropy;
@@ -2596,6 +2600,8 @@ void drain_local_pages(struct zone *zone)
 
 static void drain_local_pages_wq(struct work_struct *work)
 {
+	struct pcpu_drain *drain =
+		container_of(work, struct pcpu_drain, work);
 	/*
 	 * drain_all_pages doesn't use proper cpu hotplug protection so
 	 * we can race with cpu offline when the WQ can move this from
@@ -2604,7 +2610,7 @@ static void drain_local_pages_wq(struct work_struct *work)
 	 * a different one.
 	 */
 	preempt_disable();
-	drain_local_pages(NULL);
+	drain_local_pages(drain->zone);
 	preempt_enable();
 }
 
@@ -2675,12 +2681,14 @@ void drain_all_pages(struct zone *zone)
 	}
 
 	for_each_cpu(cpu, &cpus_with_pcps) {
-		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
-		INIT_WORK(work, drain_local_pages_wq);
-		queue_work_on(cpu, mm_percpu_wq, work);
+		struct pcpu_drain *drain = per_cpu_ptr(&pcpu_drain, cpu);
+
+		drain->zone = zone;
+		INIT_WORK(&drain->work, drain_local_pages_wq);
+		queue_work_on(cpu, mm_percpu_wq, &drain->work);
 	}
 	for_each_cpu(cpu, &cpus_with_pcps)
-		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
+		flush_work(&per_cpu_ptr(&pcpu_drain, cpu)->work);
 
 	mutex_unlock(&pcpu_drain_mutex);
 }
-- 
2.15.1
