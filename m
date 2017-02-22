Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B826D6B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 07:01:31 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w37so198920wrc.0
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 04:01:31 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id k69si1486719wrc.76.2017.02.22.04.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 04:01:29 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id v77so87253wmv.0
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 04:01:29 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] staging, android: remove lowmemory killer from the tree
Date: Wed, 22 Feb 2017 13:01:21 +0100
Message-Id: <20170222120121.12601-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: =?UTF-8?q?Arve=20Hj=C3=B8nnev=C3=A5g?= <arve@android.com>, Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Lowmemory killer is sitting in the staging tree since 2008 without any
serious interest for fixing issues brought up by the MM folks. The main
objection is that the implementation is basically broken by design:
	- it hooks into slab shrinker API which is not suitable for this
	  purpose. lowmem_count implementation just shows this nicely.
	  There is no scaling based on the memory pressure and no
	  feedback to the generic shrinker infrastructure.
	  Moreover lowmem_scan is called way too often for the heavy
	  work it performs.
	- it is not reclaim context aware - no NUMA and/or memcg
	  awareness.

As the code stands right now it just adds a maintenance overhead when
core MM changes have to update lowmemorykiller.c as well. It also seems
that the alternative LMK implementation will be solely in the userspace
so this code has no perspective it seems. The staging tree is supposed
to be for a code which needs to be put in shape before it can be merged
which is not the case here obviously.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/staging/android/Kconfig           |  10 --
 drivers/staging/android/Makefile          |   1 -
 drivers/staging/android/lowmemorykiller.c | 212 ------------------------------
 include/linux/sched.h                     |   4 -
 4 files changed, 227 deletions(-)
 delete mode 100644 drivers/staging/android/lowmemorykiller.c

diff --git a/drivers/staging/android/Kconfig b/drivers/staging/android/Kconfig
index 6c00d6f765c6..71a50b99caff 100644
--- a/drivers/staging/android/Kconfig
+++ b/drivers/staging/android/Kconfig
@@ -14,16 +14,6 @@ config ASHMEM
 	  It is, in theory, a good memory allocator for low-memory devices,
 	  because it can discard shared memory units when under memory pressure.
 
-config ANDROID_LOW_MEMORY_KILLER
-	bool "Android Low Memory Killer"
-	---help---
-	  Registers processes to be killed when low memory conditions, this is useful
-	  as there is no particular swap space on android.
-
-	  The registered process will kill according to the priorities in android init
-	  scripts (/init.rc), and it defines priority values with minimum free memory size
-	  for each priority.
-
 source "drivers/staging/android/ion/Kconfig"
 
 endif # if ANDROID
diff --git a/drivers/staging/android/Makefile b/drivers/staging/android/Makefile
index 7ed1be798909..7cf1564a49a5 100644
--- a/drivers/staging/android/Makefile
+++ b/drivers/staging/android/Makefile
@@ -3,4 +3,3 @@ ccflags-y += -I$(src)			# needed for trace events
 obj-y					+= ion/
 
 obj-$(CONFIG_ASHMEM)			+= ashmem.o
-obj-$(CONFIG_ANDROID_LOW_MEMORY_KILLER)	+= lowmemorykiller.o
diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
deleted file mode 100644
index ec3b66561412..000000000000
--- a/drivers/staging/android/lowmemorykiller.c
+++ /dev/null
@@ -1,212 +0,0 @@
-/* drivers/misc/lowmemorykiller.c
- *
- * The lowmemorykiller driver lets user-space specify a set of memory thresholds
- * where processes with a range of oom_score_adj values will get killed. Specify
- * the minimum oom_score_adj values in
- * /sys/module/lowmemorykiller/parameters/adj and the number of free pages in
- * /sys/module/lowmemorykiller/parameters/minfree. Both files take a comma
- * separated list of numbers in ascending order.
- *
- * For example, write "0,8" to /sys/module/lowmemorykiller/parameters/adj and
- * "1024,4096" to /sys/module/lowmemorykiller/parameters/minfree to kill
- * processes with a oom_score_adj value of 8 or higher when the free memory
- * drops below 4096 pages and kill processes with a oom_score_adj value of 0 or
- * higher when the free memory drops below 1024 pages.
- *
- * The driver considers memory used for caches to be free, but if a large
- * percentage of the cached memory is locked this can be very inaccurate
- * and processes may not get killed until the normal oom killer is triggered.
- *
- * Copyright (C) 2007-2008 Google, Inc.
- *
- * This software is licensed under the terms of the GNU General Public
- * License version 2, as published by the Free Software Foundation, and
- * may be copied, distributed, and modified under those terms.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- */
-
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-
-#include <linux/init.h>
-#include <linux/moduleparam.h>
-#include <linux/kernel.h>
-#include <linux/mm.h>
-#include <linux/oom.h>
-#include <linux/sched.h>
-#include <linux/swap.h>
-#include <linux/rcupdate.h>
-#include <linux/profile.h>
-#include <linux/notifier.h>
-
-static u32 lowmem_debug_level = 1;
-static short lowmem_adj[6] = {
-	0,
-	1,
-	6,
-	12,
-};
-
-static int lowmem_adj_size = 4;
-static int lowmem_minfree[6] = {
-	3 * 512,	/* 6MB */
-	2 * 1024,	/* 8MB */
-	4 * 1024,	/* 16MB */
-	16 * 1024,	/* 64MB */
-};
-
-static int lowmem_minfree_size = 4;
-
-static unsigned long lowmem_deathpending_timeout;
-
-#define lowmem_print(level, x...)			\
-	do {						\
-		if (lowmem_debug_level >= (level))	\
-			pr_info(x);			\
-	} while (0)
-
-static unsigned long lowmem_count(struct shrinker *s,
-				  struct shrink_control *sc)
-{
-	return global_node_page_state(NR_ACTIVE_ANON) +
-		global_node_page_state(NR_ACTIVE_FILE) +
-		global_node_page_state(NR_INACTIVE_ANON) +
-		global_node_page_state(NR_INACTIVE_FILE);
-}
-
-static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
-{
-	struct task_struct *tsk;
-	struct task_struct *selected = NULL;
-	unsigned long rem = 0;
-	int tasksize;
-	int i;
-	short min_score_adj = OOM_SCORE_ADJ_MAX + 1;
-	int minfree = 0;
-	int selected_tasksize = 0;
-	short selected_oom_score_adj;
-	int array_size = ARRAY_SIZE(lowmem_adj);
-	int other_free = global_page_state(NR_FREE_PAGES) - totalreserve_pages;
-	int other_file = global_node_page_state(NR_FILE_PAGES) -
-				global_node_page_state(NR_SHMEM) -
-				total_swapcache_pages();
-
-	if (lowmem_adj_size < array_size)
-		array_size = lowmem_adj_size;
-	if (lowmem_minfree_size < array_size)
-		array_size = lowmem_minfree_size;
-	for (i = 0; i < array_size; i++) {
-		minfree = lowmem_minfree[i];
-		if (other_free < minfree && other_file < minfree) {
-			min_score_adj = lowmem_adj[i];
-			break;
-		}
-	}
-
-	lowmem_print(3, "lowmem_scan %lu, %x, ofree %d %d, ma %hd\n",
-		     sc->nr_to_scan, sc->gfp_mask, other_free,
-		     other_file, min_score_adj);
-
-	if (min_score_adj == OOM_SCORE_ADJ_MAX + 1) {
-		lowmem_print(5, "lowmem_scan %lu, %x, return 0\n",
-			     sc->nr_to_scan, sc->gfp_mask);
-		return 0;
-	}
-
-	selected_oom_score_adj = min_score_adj;
-
-	rcu_read_lock();
-	for_each_process(tsk) {
-		struct task_struct *p;
-		short oom_score_adj;
-
-		if (tsk->flags & PF_KTHREAD)
-			continue;
-
-		p = find_lock_task_mm(tsk);
-		if (!p)
-			continue;
-
-		if (task_lmk_waiting(p) &&
-		    time_before_eq(jiffies, lowmem_deathpending_timeout)) {
-			task_unlock(p);
-			rcu_read_unlock();
-			return 0;
-		}
-		oom_score_adj = p->signal->oom_score_adj;
-		if (oom_score_adj < min_score_adj) {
-			task_unlock(p);
-			continue;
-		}
-		tasksize = get_mm_rss(p->mm);
-		task_unlock(p);
-		if (tasksize <= 0)
-			continue;
-		if (selected) {
-			if (oom_score_adj < selected_oom_score_adj)
-				continue;
-			if (oom_score_adj == selected_oom_score_adj &&
-			    tasksize <= selected_tasksize)
-				continue;
-		}
-		selected = p;
-		selected_tasksize = tasksize;
-		selected_oom_score_adj = oom_score_adj;
-		lowmem_print(2, "select '%s' (%d), adj %hd, size %d, to kill\n",
-			     p->comm, p->pid, oom_score_adj, tasksize);
-	}
-	if (selected) {
-		task_lock(selected);
-		send_sig(SIGKILL, selected, 0);
-		if (selected->mm)
-			task_set_lmk_waiting(selected);
-		task_unlock(selected);
-		lowmem_print(1, "Killing '%s' (%d), adj %hd,\n"
-				 "   to free %ldkB on behalf of '%s' (%d) because\n"
-				 "   cache %ldkB is below limit %ldkB for oom_score_adj %hd\n"
-				 "   Free memory is %ldkB above reserved\n",
-			     selected->comm, selected->pid,
-			     selected_oom_score_adj,
-			     selected_tasksize * (long)(PAGE_SIZE / 1024),
-			     current->comm, current->pid,
-			     other_file * (long)(PAGE_SIZE / 1024),
-			     minfree * (long)(PAGE_SIZE / 1024),
-			     min_score_adj,
-			     other_free * (long)(PAGE_SIZE / 1024));
-		lowmem_deathpending_timeout = jiffies + HZ;
-		rem += selected_tasksize;
-	}
-
-	lowmem_print(4, "lowmem_scan %lu, %x, return %lu\n",
-		     sc->nr_to_scan, sc->gfp_mask, rem);
-	rcu_read_unlock();
-	return rem;
-}
-
-static struct shrinker lowmem_shrinker = {
-	.scan_objects = lowmem_scan,
-	.count_objects = lowmem_count,
-	.seeks = DEFAULT_SEEKS * 16
-};
-
-static int __init lowmem_init(void)
-{
-	register_shrinker(&lowmem_shrinker);
-	return 0;
-}
-device_initcall(lowmem_init);
-
-/*
- * not really modular, but the easiest way to keep compat with existing
- * bootargs behaviour is to continue using module_param here.
- */
-module_param_named(cost, lowmem_shrinker.seeks, int, 0644);
-module_param_array_named(adj, lowmem_adj, short, &lowmem_adj_size, 0644);
-module_param_array_named(minfree, lowmem_minfree, uint, &lowmem_minfree_size,
-			 0644);
-module_param_named(debug_level, lowmem_debug_level, uint, 0644);
-
diff --git a/include/linux/sched.h b/include/linux/sched.h
index e93594b88130..3cc6c650fa6a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2347,7 +2347,6 @@ static inline void memalloc_noio_restore(unsigned int flags)
 #define PFA_NO_NEW_PRIVS 0	/* May not gain new privileges. */
 #define PFA_SPREAD_PAGE  1      /* Spread page cache over cpuset */
 #define PFA_SPREAD_SLAB  2      /* Spread some slab caches over cpuset */
-#define PFA_LMK_WAITING  3      /* Lowmemorykiller is waiting */
 
 
 #define TASK_PFA_TEST(name, func)					\
@@ -2371,9 +2370,6 @@ TASK_PFA_TEST(SPREAD_SLAB, spread_slab)
 TASK_PFA_SET(SPREAD_SLAB, spread_slab)
 TASK_PFA_CLEAR(SPREAD_SLAB, spread_slab)
 
-TASK_PFA_TEST(LMK_WAITING, lmk_waiting)
-TASK_PFA_SET(LMK_WAITING, lmk_waiting)
-
 /*
  * task->jobctl flags
  */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
