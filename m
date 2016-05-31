Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4AD6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 16:52:03 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id di3so221385998pab.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 13:52:03 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id h186si45846089pfc.53.2016.05.31.13.52.01
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 13:52:02 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH] mm/swap: lru drain on memory reclaim workqueue
Date: Tue, 31 May 2016 14:50:15 -0600
Message-Id: <1464727815-13073-1-git-send-email-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Cc: Keith Busch <keith.busch@intel.com>

This creates a system memory reclaim work queue and has lru_add_drain_all
use this new work queue. This allows memory reclaim work that invalidates
block devices to flush all lru add caches without triggering the
check_flush_dependency warning.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
This is similar to proposal a few months ago:

  https://patchwork.ozlabs.org/patch/574623/

The difference from this patch is this one uses a system workqueue so
others can use a memory reclaim workqueue without having to allocate
their own.

I didn't see any follow up on linux-mm on if lru_add_drain_per_cpu
should be using a WQ_MEM_RECLAIM set work queue, so sending a similar
patch since warnings are frequently being triggered.

 include/linux/workqueue.h | 1 +
 kernel/workqueue.c        | 5 ++++-
 mm/swap.c                 | 2 +-
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index ca73c50..8c79e82 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -357,6 +357,7 @@ extern struct workqueue_struct *system_unbound_wq;
 extern struct workqueue_struct *system_freezable_wq;
 extern struct workqueue_struct *system_power_efficient_wq;
 extern struct workqueue_struct *system_freezable_power_efficient_wq;
+extern struct workqueue_struct *system_mem_wq;
 
 extern struct workqueue_struct *
 __alloc_workqueue_key(const char *fmt, unsigned int flags, int max_active,
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 5f5068e..7e9050a 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -341,6 +341,8 @@ struct workqueue_struct *system_long_wq __read_mostly;
 EXPORT_SYMBOL_GPL(system_long_wq);
 struct workqueue_struct *system_unbound_wq __read_mostly;
 EXPORT_SYMBOL_GPL(system_unbound_wq);
+struct workqueue_struct *system_mem_wq __read_mostly;
+EXPORT_SYMBOL(system_mem_wq);
 struct workqueue_struct *system_freezable_wq __read_mostly;
 EXPORT_SYMBOL_GPL(system_freezable_wq);
 struct workqueue_struct *system_power_efficient_wq __read_mostly;
@@ -5574,6 +5576,7 @@ static int __init init_workqueues(void)
 	system_long_wq = alloc_workqueue("events_long", 0, 0);
 	system_unbound_wq = alloc_workqueue("events_unbound", WQ_UNBOUND,
 					    WQ_UNBOUND_MAX_ACTIVE);
+	system_mem_wq = alloc_workqueue("events_mem_unbound", WQ_UNBOUND | WQ_MEM_RECLAIM, 0);
 	system_freezable_wq = alloc_workqueue("events_freezable",
 					      WQ_FREEZABLE, 0);
 	system_power_efficient_wq = alloc_workqueue("events_power_efficient",
@@ -5582,7 +5585,7 @@ static int __init init_workqueues(void)
 					      WQ_FREEZABLE | WQ_POWER_EFFICIENT,
 					      0);
 	BUG_ON(!system_wq || !system_highpri_wq || !system_long_wq ||
-	       !system_unbound_wq || !system_freezable_wq ||
+	       !system_mem_wq || !system_unbound_wq || !system_freezable_wq ||
 	       !system_power_efficient_wq ||
 	       !system_freezable_power_efficient_wq);
 
diff --git a/mm/swap.c b/mm/swap.c
index 03aacbc..ade23de 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -685,7 +685,7 @@ void lru_add_drain_all(void)
 		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
-			schedule_work_on(cpu, work);
+			queue_work_on(cpu, system_mem_wq, work);
 			cpumask_set_cpu(cpu, &has_work);
 		}
 	}
-- 
2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
