Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4796B0253
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 05:36:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u97so2712443wrc.3
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 02:36:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d8sor1918138edk.17.2017.11.02.02.36.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 02:36:30 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm: drop hotplug lock from lru_add_drain_all
Date: Thu,  2 Nov 2017 10:36:13 +0100
Message-Id: <20171102093613.3616-3-mhocko@kernel.org>
In-Reply-To: <20171102093613.3616-1-mhocko@kernel.org>
References: <20171102093613.3616-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Pulling cpu hotplug locks inside the mm core function like
lru_add_drain_all just asks for problems and the recent lockdep splat
[1] just proves this. While the usage in that particular case might
be wrong we should prevent from locking as lru_add_drain_all is used
at many places. It seems that this is not all that hard to achieve
actually.

We have done the same thing for drain_all_pages which is analogous by
a459eeb7b852 ("mm, page_alloc: do not depend on cpu hotplug locks inside
the allocator"). All we have to care about is to handle
      - the work item might be executed on a different cpu in worker from
        unbound pool so it doesn't run on pinned on the cpu

      - we have to make sure that we do not race with page_alloc_cpu_dead
        calling lru_add_drain_cpu

the first part is already handled because the worker calls lru_add_drain
which disables preemption when calling lru_add_drain_cpu on the local
cpu it is draining. The later is achieved by disabling IRQs around
lru_add_drain_cpu in the hotplug callback.

[1] http://lkml.kernel.org/r/089e0825eec8955c1f055c83d476@google.com

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/swap.h | 1 -
 mm/memory_hotplug.c  | 2 +-
 mm/page_alloc.c      | 4 ++++
 mm/swap.c            | 9 +--------
 4 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 84255b3da7c1..cfc200673e13 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -331,7 +331,6 @@ extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
 extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
-extern void lru_add_drain_all_cpuslocked(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
 extern void mark_page_lazyfree(struct page *page);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 832a042134f8..c9f6b418be79 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1641,7 +1641,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		goto failed_removal;
 
 	cond_resched();
-	lru_add_drain_all_cpuslocked();
+	lru_add_drain_all();
 	drain_all_pages(zone);
 
 	pfn = scan_movable_pages(start_pfn, end_pfn);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 67330a438525..8c6e9c6d194c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6830,8 +6830,12 @@ void __init free_area_init(unsigned long *zones_size)
 
 static int page_alloc_cpu_dead(unsigned int cpu)
 {
+	unsigned long flags;
 
+	local_irq_save(flags);
 	lru_add_drain_cpu(cpu);
+	local_irq_restore(flags);
+
 	drain_pages(cpu);
 
 	/*
diff --git a/mm/swap.c b/mm/swap.c
index 381e0fe9efbf..6c4e77517bd2 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -688,7 +688,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
 
 static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
 
-void lru_add_drain_all_cpuslocked(void)
+void lru_add_drain_all_cpus(void)
 {
 	static DEFINE_MUTEX(lock);
 	static struct cpumask has_work;
@@ -724,13 +724,6 @@ void lru_add_drain_all_cpuslocked(void)
 	mutex_unlock(&lock);
 }
 
-void lru_add_drain_all(void)
-{
-	get_online_cpus();
-	lru_add_drain_all_cpuslocked();
-	put_online_cpus();
-}
-
 /**
  * release_pages - batched put_page()
  * @pages: array of pages to release
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
