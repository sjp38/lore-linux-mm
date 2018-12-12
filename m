Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 80A4A8E00E5
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 19:30:16 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a10so11764617plp.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 16:30:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t190sor23940188pgd.31.2018.12.11.16.30.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 16:30:15 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, page_alloc: enable pcpu_drain with zone capability
Date: Wed, 12 Dec 2018 08:29:33 +0800
Message-Id: <20181212002933.53337-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de, david@redhat.com, Wei Yang <richard.weiyang@gmail.com>

Current pcpu_drain is defined as work_struct, which is not capable to
carry the zone information to drain pages. During __offline_pages(), the
code is sure the exact zone to drain pages. This will leads to
__offline_pages() to drain other zones which we don't want to touch and
to some extend increase the contention of the system.

This patch enable pcpu_drain with zone information, so that we could
drain pages on the exact zone.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
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
