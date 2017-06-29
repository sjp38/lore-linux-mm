Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B6AA06B0387
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 12:11:21 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b189so2994395wmb.12
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 09:11:21 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k205si1538573wmf.17.2017.06.29.09.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 29 Jun 2017 09:11:20 -0700 (PDT)
Date: Thu, 29 Jun 2017 18:11:15 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH] mm/memory-hotplug: Switch locking to a percpu rwsem
Message-ID: <alpine.DEB.2.20.1706291803380.1861@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

Andrey reported a potential deadlock with the memory hotplug lock and the
cpu hotplug lock.

The reason is that memory hotplug takes the memory hotplug lock and then
calls stop_machine() which calls get_online_cpus(). That's the reverse lock
order to get_online_cpus(); get_online_mems(); in mm/slub_common.c

The problem has been there forever. The reason why this was never reported
is that the cpu hotplug locking had this homebrewn recursive reader writer
semaphore construct which due to the recursion evaded the full lock dep
coverage. The memory hotplug code copied that construct verbatim and
therefor has similar issues.

Two steps to fix this:

1) Convert the memory hotplug locking to a per cpu rwsem so the potential
   issues get reported proper by lockdep.

2) Lock the online cpus in mem_hotplug_begin() before taking the memory
   hotplug rwsem and use stop_machine_cpuslocked() in the page_alloc code
   to avoid recursive locking.

Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
---

Note 1:
 Applies against -next or
     
   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git smp/hotplug

 which contains the hotplug locking rework including stop_machine_cpuslocked()

Note 2:

 Most of the call sites of get_online_mems() are also calling get_online_cpus().

 So we could switch the whole machinery to use the CPU hotplug locking for
 protecting both memory and CPU hotplug. That actually works and removes
 another 40 lines of code.

---
 mm/memory_hotplug.c |   85 +++++++---------------------------------------------
 mm/page_alloc.c     |    2 -
 2 files changed, 14 insertions(+), 73 deletions(-)

--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -52,32 +52,17 @@ static void generic_online_page(struct p
 static online_page_callback_t online_page_callback = generic_online_page;
 static DEFINE_MUTEX(online_page_callback_lock);
 
-/* The same as the cpu_hotplug lock, but for memory hotplug. */
-static struct {
-	struct task_struct *active_writer;
-	struct mutex lock; /* Synchronizes accesses to refcount, */
-	/*
-	 * Also blocks the new readers during
-	 * an ongoing mem hotplug operation.
-	 */
-	int refcount;
+DEFINE_STATIC_PERCPU_RWSEM(mem_hotplug_lock);
 
-#ifdef CONFIG_DEBUG_LOCK_ALLOC
-	struct lockdep_map dep_map;
-#endif
-} mem_hotplug = {
-	.active_writer = NULL,
-	.lock = __MUTEX_INITIALIZER(mem_hotplug.lock),
-	.refcount = 0,
-#ifdef CONFIG_DEBUG_LOCK_ALLOC
-	.dep_map = {.name = "mem_hotplug.lock" },
-#endif
-};
+void get_online_mems(void)
+{
+	percpu_down_read(&mem_hotplug_lock);
+}
 
-/* Lockdep annotations for get/put_online_mems() and mem_hotplug_begin/end() */
-#define memhp_lock_acquire_read() lock_map_acquire_read(&mem_hotplug.dep_map)
-#define memhp_lock_acquire()      lock_map_acquire(&mem_hotplug.dep_map)
-#define memhp_lock_release()      lock_map_release(&mem_hotplug.dep_map)
+void put_online_mems(void)
+{
+	percpu_up_read(&mem_hotplug_lock);
+}
 
 #ifndef CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
 bool memhp_auto_online;
@@ -97,60 +82,16 @@ static int __init setup_memhp_default_st
 }
 __setup("memhp_default_state=", setup_memhp_default_state);
 
-void get_online_mems(void)
-{
-	might_sleep();
-	if (mem_hotplug.active_writer == current)
-		return;
-	memhp_lock_acquire_read();
-	mutex_lock(&mem_hotplug.lock);
-	mem_hotplug.refcount++;
-	mutex_unlock(&mem_hotplug.lock);
-
-}
-
-void put_online_mems(void)
-{
-	if (mem_hotplug.active_writer == current)
-		return;
-	mutex_lock(&mem_hotplug.lock);
-
-	if (WARN_ON(!mem_hotplug.refcount))
-		mem_hotplug.refcount++; /* try to fix things up */
-
-	if (!--mem_hotplug.refcount && unlikely(mem_hotplug.active_writer))
-		wake_up_process(mem_hotplug.active_writer);
-	mutex_unlock(&mem_hotplug.lock);
-	memhp_lock_release();
-
-}
-
-/* Serializes write accesses to mem_hotplug.active_writer. */
-static DEFINE_MUTEX(memory_add_remove_lock);
-
 void mem_hotplug_begin(void)
 {
-	mutex_lock(&memory_add_remove_lock);
-
-	mem_hotplug.active_writer = current;
-
-	memhp_lock_acquire();
-	for (;;) {
-		mutex_lock(&mem_hotplug.lock);
-		if (likely(!mem_hotplug.refcount))
-			break;
-		__set_current_state(TASK_UNINTERRUPTIBLE);
-		mutex_unlock(&mem_hotplug.lock);
-		schedule();
-	}
+	cpus_read_lock();
+	percpu_down_write(&mem_hotplug_lock);
 }
 
 void mem_hotplug_done(void)
 {
-	mem_hotplug.active_writer = NULL;
-	mutex_unlock(&mem_hotplug.lock);
-	memhp_lock_release();
-	mutex_unlock(&memory_add_remove_lock);
+	percpu_up_write(&mem_hotplug_lock);
+	cpus_read_unlock();
 }
 
 /* add this memory to iomem resource */
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5216,7 +5216,7 @@ void __ref build_all_zonelists(pg_data_t
 #endif
 		/* we have to stop all cpus to guarantee there is no user
 		   of zonelist */
-		stop_machine(__build_all_zonelists, pgdat, NULL);
+		stop_machine_cpuslocked(__build_all_zonelists, pgdat, NULL);
 		/* cpuset refresh routine should be here */
 	}
 	vm_total_pages = nr_free_pagecache_pages();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
