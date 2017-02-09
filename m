Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6F56B038A
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 08:22:17 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id j90so1476418lfi.3
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 05:22:17 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id 2si1380801ljv.79.2017.02.09.05.22.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 05:22:14 -0800 (PST)
From: peter enderborg <peter.enderborg@sonymobile.com>
Subject: [PATCH 3/3 staging-next] mm: Remove RCU and tasklocks from lmk
Message-ID: <6d83fb15-db88-52d3-bc24-2dd8b6d9b614@sonymobile.com>
Date: Thu, 9 Feb 2017 14:21:52 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

Fundamental changes:
1 Does NOT take any RCU lock in shrinker functions.
2 It returns same result for scan and counts, so  we dont need to do
   shinker will know when it is pointless to call scan.
3 It does not lock any other process than the one that is
   going to be killed.

Background.
The low memory killer scans for process that can be killed to free
memory. This can be cpu consuming when there is a high demand for
memory. This can be seen by analysing the kswapd0 task work.
The stats function added in earler patch adds a counter for waste work.

How it works.
This patch create a structure within the lowmemory killer that caches
the user spaces processes that it might kill. It is done with a
sorted rbtree so we can very easy find the candidate to be killed,
and knows its properies as memory usage and sorted by oom_score_adj
to look up the task with highest oom_score_adj. To be able to achive
this it uses oom_score_notify events.

This patch also as a other effect, we are now free to do other
lowmemorykiller configurations.  Without the patch there is a need
for a tradeoff between freed memory and task and rcu locks. This
is no longer a concern for tuning lmk. This patch is not intended
to do any calculation changes other than we do use the cache for
calculate the count values and that makes kswapd0 to shrink other
areas.

Signed-off-by: Peter Enderborg <peter.enderborg@sonymobile.com>
---
  drivers/staging/android/Kconfig                 |   1 +
  drivers/staging/android/Makefile                |   1 +
  drivers/staging/android/lowmemorykiller.c       | 294 +++++++++++++++---------
  drivers/staging/android/lowmemorykiller.h       |  15 ++
  drivers/staging/android/lowmemorykiller_stats.c |  24 ++
  drivers/staging/android/lowmemorykiller_stats.h |  14 +-
  drivers/staging/android/lowmemorykiller_tasks.c | 220 ++++++++++++++++++
  drivers/staging/android/lowmemorykiller_tasks.h |  35 +++
  8 files changed, 498 insertions(+), 106 deletions(-)
  create mode 100644 drivers/staging/android/lowmemorykiller.h
  create mode 100644 drivers/staging/android/lowmemorykiller_tasks.c
  create mode 100644 drivers/staging/android/lowmemorykiller_tasks.h

diff --git a/drivers/staging/android/Kconfig b/drivers/staging/android/Kconfig
index 96e86c7..899186c 100644
--- a/drivers/staging/android/Kconfig
+++ b/drivers/staging/android/Kconfig
@@ -16,6 +16,7 @@ config ASHMEM

  config ANDROID_LOW_MEMORY_KILLER
      bool "Android Low Memory Killer"
+    select OOM_SCORE_NOTIFIER
      ---help---
        Registers processes to be killed when low memory conditions, this is useful
        as there is no particular swap space on android.
diff --git a/drivers/staging/android/Makefile b/drivers/staging/android/Makefile
index d710eb2..b7a8036 100644
--- a/drivers/staging/android/Makefile
+++ b/drivers/staging/android/Makefile
@@ -4,4 +4,5 @@ obj-y                    += ion/

  obj-$(CONFIG_ASHMEM)            += ashmem.o
  obj-$(CONFIG_ANDROID_LOW_MEMORY_KILLER)    += lowmemorykiller.o
+obj-$(CONFIG_ANDROID_LOW_MEMORY_KILLER)    += lowmemorykiller_tasks.o
  obj-$(CONFIG_ANDROID_LOW_MEMORY_KILLER_STATS)    += lowmemorykiller_stats.o
diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index 15c1b38..1e275b1 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -41,10 +41,14 @@
  #include <linux/swap.h>
  #include <linux/rcupdate.h>
  #include <linux/profile.h>
+#include <linux/slab.h>
  #include <linux/notifier.h>
+#include <linux/oom_score_notifier.h>
+#include "lowmemorykiller.h"
  #include "lowmemorykiller_stats.h"
+#include "lowmemorykiller_tasks.h"

-static u32 lowmem_debug_level = 1;
+u32 lowmem_debug_level = 1;
  static short lowmem_adj[6] = {
      0,
      1,
@@ -62,135 +66,212 @@ static int lowmem_minfree[6] = {

  static int lowmem_minfree_size = 4;

-static unsigned long lowmem_deathpending_timeout;
-
-#define lowmem_print(level, x...)            \
-    do {                        \
-        if (lowmem_debug_level >= (level))    \
-            pr_info(x);            \
-    } while (0)
-
-static unsigned long lowmem_count(struct shrinker *s,
-                  struct shrink_control *sc)
-{
-    lmk_inc_stats(LMK_COUNT);
-    return global_node_page_state(NR_ACTIVE_ANON) +
-        global_node_page_state(NR_ACTIVE_FILE) +
-        global_node_page_state(NR_INACTIVE_ANON) +
-        global_node_page_state(NR_INACTIVE_FILE);
-}
+struct calculated_params {
+    long selected_tasksize;
+    long minfree;
+    int other_file;
+    int other_free;
+    int dynamic_max_queue_len;
+    short selected_oom_score_adj;
+    short min_score_adj;
+};

-static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
+static int kill_needed(int level, struct shrink_control *sc,
+               struct calculated_params *cp)
  {
-    struct task_struct *tsk;
-    struct task_struct *selected = NULL;
-    unsigned long rem = 0;
-    int tasksize;
      int i;
-    short min_score_adj = OOM_SCORE_ADJ_MAX + 1;
-    int minfree = 0;
-    int selected_tasksize = 0;
-    short selected_oom_score_adj;
      int array_size = ARRAY_SIZE(lowmem_adj);
-    int other_free = global_page_state(NR_FREE_PAGES) - totalreserve_pages;
-    int other_file = global_node_page_state(NR_FILE_PAGES) -
-                global_node_page_state(NR_SHMEM) -
-                total_swapcache_pages();

-    lmk_inc_stats(LMK_SCAN);
+    cp->other_free = global_page_state(NR_FREE_PAGES) - totalreserve_pages;
+    cp->other_file = global_page_state(NR_FILE_PAGES) -
+        global_page_state(NR_SHMEM) -
+        global_page_state(NR_UNEVICTABLE) -
+        total_swapcache_pages();
+
+    cp->minfree = 0;
+    cp->min_score_adj = OOM_SCORE_ADJ_MAX;
      if (lowmem_adj_size < array_size)
          array_size = lowmem_adj_size;
      if (lowmem_minfree_size < array_size)
          array_size = lowmem_minfree_size;
      for (i = 0; i < array_size; i++) {
-        minfree = lowmem_minfree[i];
-        if (other_free < minfree && other_file < minfree) {
-            min_score_adj = lowmem_adj[i];
+        cp->minfree = lowmem_minfree[i];
+        if (cp->other_free < cp->minfree &&
+            cp->other_file < cp->minfree) {
+            cp->min_score_adj = lowmem_adj[i];
              break;
          }
      }
+    if (sc->nr_to_scan > 0)
+        lowmem_print(3, "lowmem_shrink %lu, %x, ofree %d %d, ma %hd\n",
+                 sc->nr_to_scan, sc->gfp_mask, cp->other_free,
+                 cp->other_file, cp->min_score_adj);
+    cp->dynamic_max_queue_len = array_size - i + 1;
+    cp->selected_oom_score_adj = level;
+    if (level >= cp->min_score_adj)
+        return 1;
+
+    return 0;
+}
+
+static void print_obituary(struct task_struct *doomed,
+               struct calculated_params *cp,
+               struct shrink_control *sc) {
+    long cache_size = cp->other_file * (long)(PAGE_SIZE / 1024);
+    long cache_limit = cp->minfree * (long)(PAGE_SIZE / 1024);
+    long free = cp->other_free * (long)(PAGE_SIZE / 1024);
+
+    lowmem_print(1, "Killing '%s' (%d), adj %hd,\n"
+             "   to free %ldkB on behalf of '%s' (%d) because\n"
+             "   cache %ldkB is below limit %ldkB for oom_score_adj %hd\n"
+             "   Free memory is %ldkB above reserved.\n"
+             "   Free CMA is %ldkB\n"
+             "   Total reserve is %ldkB\n"
+             "   Total free pages is %ldkB\n"
+             "   Total file cache is %ldkB\n"
+             "   Slab Reclaimable is %ldkB\n"
+             "   Slab UnReclaimable is %ldkB\n"
+             "   Total Slab is %ldkB\n"
+             "   GFP mask is 0x%x\n"
+             "   queue len is %d of max %d\n",
+             doomed->comm, doomed->pid,
+             cp->selected_oom_score_adj,
+             cp->selected_tasksize * (long)(PAGE_SIZE / 1024),
+             current->comm, current->pid,
+             cache_size, cache_limit,
+             cp->min_score_adj,
+             free,
+             global_page_state(NR_FREE_CMA_PAGES) *
+             (long)(PAGE_SIZE / 1024),
+             totalreserve_pages * (long)(PAGE_SIZE / 1024),
+             global_page_state(NR_FREE_PAGES) *
+             (long)(PAGE_SIZE / 1024),
+             global_page_state(NR_FILE_PAGES) *
+             (long)(PAGE_SIZE / 1024),
+             global_page_state(NR_SLAB_RECLAIMABLE) *
+             (long)(PAGE_SIZE / 1024),
+             global_page_state(NR_SLAB_UNRECLAIMABLE) *
+             (long)(PAGE_SIZE / 1024),
+             global_page_state(NR_SLAB_RECLAIMABLE) *
+             (long)(PAGE_SIZE / 1024) +
+             global_page_state(NR_SLAB_UNRECLAIMABLE) *
+             (long)(PAGE_SIZE / 1024),
+             sc->gfp_mask,
+             death_pending_len,
+             cp->dynamic_max_queue_len);
+}
+
+static unsigned long lowmem_count(struct shrinker *s,
+                  struct shrink_control *sc)
+{
+    struct lmk_rb_watch *lrw;
+    struct calculated_params cp;
+    short score;
+
+    lmk_inc_stats(LMK_COUNT);
+    cp.selected_tasksize = 0;
+    spin_lock(&lmk_task_lock);
+    lrw = __lmk_first();
+    if (lrw && lrw->tsk->mm) {
+        int rss = get_mm_rss(lrw->tsk->mm);

-    lowmem_print(3, "lowmem_scan %lu, %x, ofree %d %d, ma %hd\n",
-             sc->nr_to_scan, sc->gfp_mask, other_free,
-             other_file, min_score_adj);
+        score = lrw->tsk->signal->oom_score_adj;
+        spin_unlock(&lmk_task_lock);
+        if (kill_needed(score, sc, &cp))
+            if (death_pending_len < cp.dynamic_max_queue_len)
+                cp.selected_tasksize = rss;

-    if (min_score_adj == OOM_SCORE_ADJ_MAX + 1) {
-        lowmem_print(5, "lowmem_scan %lu, %x, return 0\n",
-                 sc->nr_to_scan, sc->gfp_mask);
-        return 0;
+    } else {
+        spin_unlock(&lmk_task_lock);
      }

-    selected_oom_score_adj = min_score_adj;
+    return cp.selected_tasksize;
+}
+

-    rcu_read_lock();
-    for_each_process(tsk) {
-        struct task_struct *p;
-        short oom_score_adj;
+static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
+{
+    struct task_struct *selected = NULL;
+    unsigned long nr_to_scan = sc->nr_to_scan;
+    struct lmk_rb_watch *lrw;
+    int do_kill;
+    struct calculated_params cp;

-        if (tsk->flags & PF_KTHREAD)
-            continue;
+    lmk_inc_stats(LMK_SCAN);

-        p = find_lock_task_mm(tsk);
-        if (!p)
-            continue;
+    cp.selected_tasksize = 0;
+    spin_lock(&lmk_task_lock);

-        if (task_lmk_waiting(p) &&
-            time_before_eq(jiffies, lowmem_deathpending_timeout)) {
-            task_unlock(p);
-            lmk_inc_stats(LMK_TIMEOUT);
-            rcu_read_unlock();
-            return 0;
+    lrw = __lmk_first();
+    if (lrw) {
+        if (lrw->tsk->mm) {
+            cp.selected_tasksize = get_mm_rss(lrw->tsk->mm);
+        } else {
+            lowmem_print(1, "pid:%d no mem\n", lrw->tsk->pid);
+            lmk_inc_stats(LMK_ERROR);
+            goto unlock_out;
          }
-        oom_score_adj = p->signal->oom_score_adj;
-        if (oom_score_adj < min_score_adj) {
-            task_unlock(p);
-            continue;
+
+        do_kill = kill_needed(lrw->key, sc, &cp);
+
+        if (death_pending_len >= cp.dynamic_max_queue_len) {
+            lmk_inc_stats(LMK_BUSY);
+            goto unlock_out;
          }
-        tasksize = get_mm_rss(p->mm);
-        task_unlock(p);
-        if (tasksize <= 0)
-            continue;
-        if (selected) {
-            if (oom_score_adj < selected_oom_score_adj)
-                continue;
-            if (oom_score_adj == selected_oom_score_adj &&
-                tasksize <= selected_tasksize)
-                continue;
+
+        if (do_kill) {
+            struct lmk_death_pending_entry *ldpt;
+
+            selected = lrw->tsk;
+
+            /* there is a chance that task is locked,
+             * and the case where it locked in oom_score_adj_write
+             * we might have deadlock. There is no macro for it
+             *  and this is the only place there is a try on
+             * the task_lock.
+             */
+            if (!spin_trylock(&selected->alloc_lock)) {
+                lmk_inc_stats(LMK_ERROR);
+                lowmem_print(1, "Failed to lock task.\n");
+                lmk_inc_stats(LMK_BUSY);
+                goto unlock_out;
+            }
+
+            /* move to kill pending set */
+            ldpt = kmem_cache_alloc(lmk_dp_cache, GFP_ATOMIC);
+            ldpt->tsk = selected;
+
+            __lmk_death_pending_add(ldpt);
+            if (!__lmk_task_remove(selected, lrw->key))
+                WARN_ON(1);
+
+            spin_unlock(&lmk_task_lock);
+
+            set_tsk_thread_flag(selected, TIF_MEMDIE);
+            send_sig(SIGKILL, selected, 0);
+            task_set_lmk_waiting(selected);
+
+            print_obituary(selected, &cp, sc);
+
+            task_unlock(selected);
+            lmk_inc_stats(LMK_KILL);
+            goto out;
+        } else {
+            lmk_inc_stats(LMK_WASTE);
          }
-        selected = p;
-        selected_tasksize = tasksize;
-        selected_oom_score_adj = oom_score_adj;
-        lowmem_print(2, "select '%s' (%d), adj %hd, size %d, to kill\n",
-                 p->comm, p->pid, oom_score_adj, tasksize);
+    } else {
+        lmk_inc_stats(LMK_NO_KILL);
      }
-    if (selected) {
-        task_lock(selected);
-        send_sig(SIGKILL, selected, 0);
-        if (selected->mm)
-            task_set_lmk_waiting(selected);
-        task_unlock(selected);
-        lowmem_print(1, "Killing '%s' (%d), adj %hd,\n"
-                 "   to free %ldkB on behalf of '%s' (%d) because\n"
-                 "   cache %ldkB is below limit %ldkB for oom_score_adj %hd\n"
-                 "   Free memory is %ldkB above reserved\n",
-                 selected->comm, selected->pid,
-                 selected_oom_score_adj,
-                 selected_tasksize * (long)(PAGE_SIZE / 1024),
-                 current->comm, current->pid,
-                 other_file * (long)(PAGE_SIZE / 1024),
-                 minfree * (long)(PAGE_SIZE / 1024),
-                 min_score_adj,
-                 other_free * (long)(PAGE_SIZE / 1024));
-        lowmem_deathpending_timeout = jiffies + HZ;
-        rem += selected_tasksize;
-        lmk_inc_stats(LMK_KILL);
-    } else
-        lmk_inc_stats(LMK_WASTE);
-
-    lowmem_print(4, "lowmem_scan %lu, %x, return %lu\n",
-             sc->nr_to_scan, sc->gfp_mask, rem);
-    rcu_read_unlock();
-    return rem;
+unlock_out:
+    cp.selected_tasksize = SHRINK_STOP;
+    spin_unlock(&lmk_task_lock);
+out:
+    if (cp.selected_tasksize == 0)
+        lowmem_print(2, "list empty nothing to free\n");
+    lowmem_print(4, "lowmem_shrink %lu, %x, return %ld\n",
+             nr_to_scan, sc->gfp_mask, cp.selected_tasksize);
+
+    return cp.selected_tasksize;
  }

  static struct shrinker lowmem_shrinker = {
@@ -201,6 +282,9 @@ static struct shrinker lowmem_shrinker = {

  static int __init lowmem_init(void)
  {
+    lmk_dp_cache = KMEM_CACHE(lmk_death_pending_entry, 0);
+    lmk_task_cache = KMEM_CACHE(lmk_rb_watch, 0);
+    oom_score_notifier_register(&lmk_oom_score_nb);
      register_shrinker(&lowmem_shrinker);
      init_procfs_lmk();
      return 0;
diff --git a/drivers/staging/android/lowmemorykiller.h b/drivers/staging/android/lowmemorykiller.h
new file mode 100644
index 0000000..03c30f6
--- /dev/null
+++ b/drivers/staging/android/lowmemorykiller.h
@@ -0,0 +1,15 @@
+#ifndef __LOWMEMORYKILLER_H
+#define __LOWMEMORYKILLER_H
+
+/* The lowest score LMK is using */
+#define LMK_SCORE_THRESHOLD 0
+
+extern u32 lowmem_debug_level;
+
+#define lowmem_print(level, x...)            \
+    do {                        \
+        if (lowmem_debug_level >= (level))    \
+            pr_info(x);            \
+    } while (0)
+
+#endif
diff --git a/drivers/staging/android/lowmemorykiller_stats.c b/drivers/staging/android/lowmemorykiller_stats.c
index 673691c..68dbcc0 100644
--- a/drivers/staging/android/lowmemorykiller_stats.c
+++ b/drivers/staging/android/lowmemorykiller_stats.c
@@ -15,7 +15,9 @@

  #include <linux/proc_fs.h>
  #include <linux/seq_file.h>
+#include "lowmemorykiller.h"
  #include "lowmemorykiller_stats.h"
+#include "lowmemorykiller_tasks.h"

  struct lmk_stats {
      atomic_long_t scans; /* counter as in shrinker scans */
@@ -27,6 +29,10 @@ struct lmk_stats {
                  * to be cancelled due to pending kills
                  */
      atomic_long_t count; /* number of shrinker count calls */
+    atomic_long_t scan_busy; /* mutex held */
+    atomic_long_t no_kill; /* mutex held */
+    atomic_long_t busy;
+    atomic_long_t error;
      atomic_long_t unknown; /* internal */
  } st;

@@ -48,6 +54,15 @@ void lmk_inc_stats(int key)
      case LMK_COUNT:
          atomic_long_inc(&st.count);
          break;
+    case LMK_BUSY:
+        atomic_long_inc(&st.busy);
+        break;
+    case LMK_ERROR:
+        atomic_long_inc(&st.error);
+        break;
+    case LMK_NO_KILL:
+        atomic_long_inc(&st.no_kill);
+        break;
      default:
          atomic_long_inc(&st.unknown);
          break;
@@ -61,6 +76,10 @@ static int lmk_proc_show(struct seq_file *m, void *v)
      seq_printf(m, "waste: %ld\n", atomic_long_read(&st.waste));
      seq_printf(m, "timeout: %ld\n", atomic_long_read(&st.timeout));
      seq_printf(m, "count: %ld\n", atomic_long_read(&st.count));
+    seq_printf(m, "busy: %ld\n", atomic_long_read(&st.busy));
+    seq_printf(m, "error: %ld\n", atomic_long_read(&st.error));
+    seq_printf(m, "no kill: %ld\n", atomic_long_read(&st.no_kill));
+    seq_printf(m, "queue: %d\n", death_pending_len);
      seq_printf(m, "unknown: %ld (internal)\n",
             atomic_long_read(&st.unknown));

@@ -83,3 +102,8 @@ int __init init_procfs_lmk(void)
      proc_create_data(LMK_PROCFS_NAME, 0444, NULL, &lmk_proc_fops, NULL);
      return 0;
  }
+
+void exit_procfs_lmk(void)
+{
+    remove_proc_entry(LMK_PROCFS_NAME, NULL);
+}
diff --git a/drivers/staging/android/lowmemorykiller_stats.h b/drivers/staging/android/lowmemorykiller_stats.h
index abeb6924..355fa53 100644
--- a/drivers/staging/android/lowmemorykiller_stats.h
+++ b/drivers/staging/android/lowmemorykiller_stats.h
@@ -10,12 +10,20 @@
   *  published by the Free Software Foundation.
   */

+#ifndef __LOWMEMORYKILLER_STATS_H
+#define __LOWMEMORYKILLER_STATS_H
+
  enum  lmk_kill_stats {
      LMK_SCAN = 1,
      LMK_KILL = 2,
      LMK_WASTE = 3,
      LMK_TIMEOUT = 4,
-    LMK_COUNT = 5
+    LMK_COUNT = 5,
+    LMK_SCAN_BUSY = 6,
+    LMK_NO_KILL = 7,
+    LMK_BUSY = 8,
+    LMK_ERROR = 9,
+
  };

  #define LMK_PROCFS_NAME "lmkstats"
@@ -23,7 +31,11 @@ enum  lmk_kill_stats {
  #ifdef CONFIG_ANDROID_LOW_MEMORY_KILLER_STATS
  void lmk_inc_stats(int key);
  int __init init_procfs_lmk(void);
+void exit_procfs_lmk(void);
  #else
  static inline void lmk_inc_stats(int key) { return; };
  static inline int __init init_procfs_lmk(void) { return 0; };
+static inline void exit_procfs_lmk(void) { return; };
+#endif
+
  #endif
diff --git a/drivers/staging/android/lowmemorykiller_tasks.c b/drivers/staging/android/lowmemorykiller_tasks.c
new file mode 100644
index 0000000..d895bf3
--- /dev/null
+++ b/drivers/staging/android/lowmemorykiller_tasks.c
@@ -0,0 +1,220 @@
+/*
+ *  lowmemorykiller_tasks
+ *
+ *  Copyright (C) 2017 Sony Mobile Communications Inc.
+ *
+ *  Author: Peter Enderborg <peter.enderborg@sonymobile.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
+ */
+
+/* this files contains help functions for handling tasks within the
+ * lowmemorykiller. It track tasks that are in it's score range,
+ * and it track tasks that signaled to be killed
+ */
+
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/oom.h>
+#include <linux/slab.h>
+#include <linux/oom_score_notifier.h>
+
+#include "lowmemorykiller.h"
+#include "lowmemorykiller_tasks.h"
+
+static struct rb_root watch_tree = RB_ROOT;
+struct list_head lmk_death_pending;
+struct kmem_cache *lmk_dp_cache;
+struct kmem_cache *lmk_task_cache;
+
+/* We need a well defined order for our tree, score is the major order
+ * and we use pid to get a unique order.
+ * return -1 on smaller, 0 on equal and 1 on bigger
+ */
+
+enum {
+    LMK_OFR_LESS = -1,
+    LMK_OFR_EQUAL = 0,
+    LMK_OFR_GREATER = 1
+};
+
+/* to protect lmk task storage data structures */
+DEFINE_SPINLOCK(lmk_task_lock);
+LIST_HEAD(lmk_death_pending);
+
+int death_pending_len;
+
+static inline int lmk_task_orderfunc(int lkey, int lpid, int rkey, int rpid)
+{
+    if (lkey > rkey)
+        return LMK_OFR_GREATER;
+    if (lkey < rkey)
+        return LMK_OFR_LESS;
+    if (lpid > rpid)
+        return LMK_OFR_GREATER;
+    if (lpid < rpid)
+        return LMK_OFR_LESS;
+    return LMK_OFR_EQUAL;
+}
+
+static inline int __lmk_task_insert(struct rb_root *root,
+                    struct task_struct *tsk)
+{
+    struct rb_node **new = &root->rb_node, *parent = NULL;
+    struct lmk_rb_watch *t;
+
+    t = kmem_cache_alloc(lmk_task_cache, GFP_ATOMIC);
+    t->key = tsk->signal->oom_score_adj;
+    t->tsk = tsk;
+
+    /* Figure out where to put new node */
+    while (*new) {
+        struct lmk_rb_watch *this = rb_entry(*new,
+                             struct lmk_rb_watch,
+                             rb_node);
+        int result;
+
+        result = lmk_task_orderfunc(t->key, t->tsk->pid,
+                        this->key, this->tsk->pid);
+        if (result == LMK_OFR_EQUAL) {
+            lowmem_print(1, "Dupe key %d pid %d - key %d pid %d\n",
+                     t->key, t->tsk->pid,
+                     this->key, this->tsk->pid);
+            WARN_ON(1);
+            return 0;
+        }
+        parent = *new;
+        if (result > 0)
+            new = &((*new)->rb_left);
+        else
+            new = &((*new)->rb_right);
+    }
+
+    /* Add new node and rebalance tree. */
+    rb_link_node(&t->rb_node, parent, new);
+    rb_insert_color(&t->rb_node, root);
+
+    return 1;
+}
+
+static struct lmk_rb_watch *__lmk_task_search(struct rb_root *root,
+                          struct task_struct *tsk,
+                          int score)
+{
+    struct rb_node *node = root->rb_node;
+
+    while (node) {
+        struct lmk_rb_watch *data = rb_entry(node,
+                             struct lmk_rb_watch,
+                             rb_node);
+        int result;
+
+        result = lmk_task_orderfunc(data->key, data->tsk->pid,
+                        score, tsk->pid);
+
+        if (result < 0)
+            node = node->rb_left;
+        else if (result > 0)
+            node = node->rb_right;
+        else if (data->tsk == tsk)
+            return data;
+    }
+    return NULL;
+}
+
+int __lmk_task_remove(struct task_struct *tsk,
+              int score)
+{
+    struct lmk_rb_watch *lrw;
+
+    lrw = __lmk_task_search(&watch_tree, tsk, score);
+    if (lrw) {
+        rb_erase(&lrw->rb_node, &watch_tree);
+        kmem_cache_free(lmk_task_cache, lrw);
+        return 1;
+    }
+
+    return 0;
+}
+
+static void lmk_task_watch(struct task_struct *tsk, int old_oom_score_adj)
+{
+    if (thread_group_leader(tsk) &&
+        (tsk->signal->oom_score_adj >= LMK_SCORE_THRESHOLD ||
+         old_oom_score_adj >= LMK_SCORE_THRESHOLD) &&
+        !(tsk->flags & PF_KTHREAD)) {
+        spin_lock(&lmk_task_lock);
+        __lmk_task_remove(tsk, old_oom_score_adj);
+        if (tsk->signal->oom_score_adj >= LMK_SCORE_THRESHOLD)
+            if (!test_tsk_thread_flag(tsk, TIF_MEMDIE))
+                __lmk_task_insert(&watch_tree, tsk);
+        spin_unlock(&lmk_task_lock);
+    }
+}
+
+static void lmk_task_free(struct task_struct *tsk)
+{
+    if (thread_group_leader(tsk) &&
+        !(tsk->flags & PF_KTHREAD)) {
+        struct lmk_death_pending_entry *dp_iterator;
+        int clear = 1;
+
+        spin_lock(&lmk_task_lock);
+        if (__lmk_task_remove(tsk, tsk->signal->oom_score_adj))
+            clear = 0;
+
+        /* check our kill queue */
+        list_for_each_entry(dp_iterator,
+                    &lmk_death_pending, lmk_dp_list) {
+            if (dp_iterator->tsk == tsk) {
+                list_del(&dp_iterator->lmk_dp_list);
+                kmem_cache_free(lmk_dp_cache, dp_iterator);
+                death_pending_len--;
+                clear = 0;
+                break;
+            }
+        }
+        spin_unlock(&lmk_task_lock);
+        if (clear) {
+            lowmem_print(2, "Pid not in list %d %d\n",
+                     tsk->pid, tsk->signal->oom_score_adj);
+        }
+    }
+}
+
+static int lmk_oom_score_notifier(struct notifier_block *nb,
+                  unsigned long action, void *data)
+{
+    struct oom_score_notifier_struct *osns = data;
+
+    switch (action) {
+    case OSN_NEW:
+        lmk_task_watch(osns->tsk, LMK_SCORE_THRESHOLD - 1);
+        break;
+    case OSN_FREE:
+        lmk_task_free(osns->tsk);
+        break;
+    case OSN_UPDATE:
+        lmk_task_watch(osns->tsk, osns->old_score);
+        break;
+    }
+    return 0;
+}
+
+int __lmk_death_pending_add(struct lmk_death_pending_entry *lwp)
+{
+    list_add(&lwp->lmk_dp_list, &lmk_death_pending);
+    death_pending_len++;
+    return 0;
+}
+
+struct lmk_rb_watch *__lmk_first(void)
+{
+    return rb_entry(rb_first(&watch_tree), struct lmk_rb_watch, rb_node);
+}
+
+struct notifier_block lmk_oom_score_nb = {
+    .notifier_call = lmk_oom_score_notifier,
+};
diff --git a/drivers/staging/android/lowmemorykiller_tasks.h b/drivers/staging/android/lowmemorykiller_tasks.h
new file mode 100644
index 0000000..b5e94d5
--- /dev/null
+++ b/drivers/staging/android/lowmemorykiller_tasks.h
@@ -0,0 +1,35 @@
+/*
+ *  lowmemorykiller_tasks interface
+ *
+ *  Copyright (C) 2017 Sony Mobile Communications Inc.
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
+ */
+
+#ifndef __LOWMEMORYKILLER_TASKS_H
+#define __LOWMEMORYKILLER_TASKS_H
+
+struct lmk_death_pending_entry {
+    struct list_head lmk_dp_list;
+    struct task_struct *tsk;
+};
+
+struct lmk_rb_watch {
+    struct rb_node rb_node;
+    struct task_struct *tsk;
+    int key;
+};
+
+extern int death_pending_len;
+extern struct kmem_cache *lmk_dp_cache;
+extern struct kmem_cache *lmk_task_cache;
+extern spinlock_t lmk_task_lock;
+extern struct notifier_block lmk_oom_score_nb;
+
+int __lmk_task_remove(struct task_struct *tsk, int score);
+int __lmk_death_pending_add(struct lmk_death_pending_entry *lwp);
+struct lmk_rb_watch *__lmk_first(void);
+
+#endif
-- 
2.4.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
