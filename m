Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 397C36B0255
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 10:58:17 -0500 (EST)
Received: by obdgf3 with SMTP id gf3so24939950obd.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 07:58:17 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w144si4951040oie.42.2015.11.11.07.58.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 07:58:15 -0800 (PST)
Subject: Re: memory reclaim problems on fs usage
References: <201511102313.36685.arekm@maven.pl>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <5643658B.9090206@I-love.SAKURA.ne.jp>
Date: Thu, 12 Nov 2015 00:58:03 +0900
MIME-Version: 1.0
In-Reply-To: <201511102313.36685.arekm@maven.pl>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Arkadiusz_Mi=c5=9bkiewicz?= <arekm@maven.pl>, linux-mm@kvack.org, xfs@oss.sgi.com

On 2015/11/11 7:13, Arkadiusz MiA?kiewicz wrote:
> The usual (repeatable) problem is like this:
>
> full dmesg: http://sprunge.us/VEiE (more in it then in partial log below)

Maybe somebody doing GFP_NOIO allocation which XFS driver doing GFP_NOFS
allocation is waiting for is stalling inside memory allocator. I think that
checking tasks which are stalling inside memory allocator would help.

Please try reproducing this problem with a debug printk() patch shown below
applied. This is a patch which I used for debugging silent lockup problem.
When memory allocation got stuck, lines with MemAlloc keyword will be
printed.

---
  fs/xfs/kmem.c          |  10 ++-
  fs/xfs/xfs_buf.c       |   3 +-
  include/linux/mmzone.h |   1 +
  include/linux/vmstat.h |   1 +
  mm/page_alloc.c        | 217 +++++++++++++++++++++++++++++++++++++++++++++++++
  mm/vmscan.c            |  22 +++++
  6 files changed, 249 insertions(+), 5 deletions(-)

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index a7a3a63..535c136 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -55,8 +55,9 @@ kmem_alloc(size_t size, xfs_km_flags_t flags)
  			return ptr;
  		if (!(++retries % 100))
  			xfs_err(NULL,
-		"possible memory allocation deadlock in %s (mode:0x%x)",
-					__func__, lflags);
+		"%s(%u) possible memory allocation deadlock in %s (mode:0x%x)",
+				current->comm, current->pid,
+				__func__, lflags);
  		congestion_wait(BLK_RW_ASYNC, HZ/50);
  	} while (1);
  }
@@ -120,8 +121,9 @@ kmem_zone_alloc(kmem_zone_t *zone, xfs_km_flags_t flags)
  			return ptr;
  		if (!(++retries % 100))
  			xfs_err(NULL,
-		"possible memory allocation deadlock in %s (mode:0x%x)",
-					__func__, lflags);
+		"%s(%u) possible memory allocation deadlock in %s (mode:0x%x)",
+				current->comm, current->pid,
+				__func__, lflags);
  		congestion_wait(BLK_RW_ASYNC, HZ/50);
  	} while (1);
  }
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 1790b00..16322cb 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -354,7 +354,8 @@ retry:
  			 */
  			if (!(++retries % 100))
  				xfs_err(NULL,
-		"possible memory allocation deadlock in %s (mode:0x%x)",
+		"%s(%u) possible memory allocation deadlock in %s (mode:0x%x)",
+					current->comm, current->pid,
  					__func__, gfp_mask);

  			XFS_STATS_INC(xb_page_retries);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 54d74f6..932a6d6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -527,6 +527,7 @@ struct zone {
  	ZONE_PADDING(_pad3_)
  	/* Zone statistics */
  	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
+	unsigned long stat_last_updated[NR_VM_ZONE_STAT_ITEMS];
  } ____cacheline_internodealigned_in_smp;

  enum zone_flags {
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 82e7db7..2488925 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -115,6 +115,7 @@ static inline void zone_page_state_add(long x, struct zone *zone,
  {
  	atomic_long_add(x, &zone->vm_stat[item]);
  	atomic_long_add(x, &vm_stat[item]);
+	zone->stat_last_updated[item] = jiffies;
  }

  static inline unsigned long global_page_state(enum zone_stat_item item)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18490f3..35a46b4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -61,6 +61,8 @@
  #include <linux/hugetlb.h>
  #include <linux/sched/rt.h>
  #include <linux/page_owner.h>
+#include <linux/nmi.h>
+#include <linux/kthread.h>

  #include <asm/sections.h>
  #include <asm/tlbflush.h>
@@ -2496,6 +2498,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
  }
  #endif /* CONFIG_COMPACTION */

+pid_t dump_target_pid;
+
  /* Perform direct synchronous page reclaim */
  static int
  __perform_reclaim(gfp_t gfp_mask, unsigned int order,
@@ -2645,6 +2649,208 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
  	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
  }

+static unsigned long kmallocwd_timeout = 10 * HZ; /* Scan interval. */
+static u8 memalloc_counter_active_index; /* Either 0 or 1. */
+static int memalloc_counter[2]; /* Number of tasks doing memory allocation. */
+
+struct memalloc {
+	struct list_head list; /* Connected to memalloc_list. */
+	struct task_struct *task; /* Iniatilized to current. */
+	unsigned long start; /* Initialized to jiffies. */
+	unsigned int order;
+	gfp_t gfp;
+	u8 index; /* Initialized to memalloc_counter_active_index. */
+	u8 dumped;
+};
+
+static LIST_HEAD(memalloc_list); /* List of "struct memalloc".*/
+static DEFINE_SPINLOCK(memalloc_list_lock); /* Lock for memalloc_list. */
+
+/*
+ * kmallocwd - A kernel thread for monitoring memory allocation stalls.
+ *
+ * @unused: Not used.
+ *
+ * This kernel thread does not terminate.
+ */
+static int kmallocwd(void *unused)
+{
+	struct memalloc *m;
+	struct task_struct *g, *p;
+	unsigned long now;
+	unsigned int sigkill_pending;
+	unsigned int memdie_pending;
+	unsigned int stalling_tasks;
+	u8 index;
+	pid_t pid;
+
+ not_stalling: /* Healty case. */
+	/* Switch active counter and wait for timeout duration. */
+	index = memalloc_counter_active_index;
+	spin_lock(&memalloc_list_lock);
+	memalloc_counter_active_index ^= 1;
+	spin_unlock(&memalloc_list_lock);
+	schedule_timeout_interruptible(kmallocwd_timeout);
+	/*
+	 * If memory allocations are working, the counter should remain 0
+	 * because tasks will be able to call both start_memalloc_timer()
+	 * and stop_memalloc_timer() within timeout duration.
+	 */
+	if (likely(!memalloc_counter[index]))
+		goto not_stalling;
+ maybe_stalling: /* Maybe something is wrong. Let's check. */
+	now = jiffies;
+	/* Count stalling tasks, dying and victim tasks. */
+	sigkill_pending = 0;
+	memdie_pending = 0;
+	stalling_tasks = 0;
+	pid = 0;
+	spin_lock(&memalloc_list_lock);
+	list_for_each_entry(m, &memalloc_list, list) {
+		if (time_after(now - m->start, kmallocwd_timeout))
+			stalling_tasks++;
+	}
+	spin_unlock(&memalloc_list_lock);
+	preempt_disable();
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+			memdie_pending++;
+		if (fatal_signal_pending(p))
+			sigkill_pending++;
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	cond_resched();
+	pr_warn("MemAlloc-Info: %u stalling task, %u dying task, %u victim task.\n",
+		stalling_tasks, sigkill_pending, memdie_pending);
+	/* Report stalling tasks, dying and victim tasks. */
+	spin_lock(&memalloc_list_lock);
+	list_for_each_entry(m, &memalloc_list, list) {
+		if (time_before(now - m->start, kmallocwd_timeout))
+			continue;
+		p = m->task;
+		pr_warn("MemAlloc: %s(%u) gfp=0x%x order=%u delay=%lu\n",
+			p->comm, p->pid, m->gfp, m->order, now - m->start);
+	}
+	spin_unlock(&memalloc_list_lock);
+	preempt_disable();
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		u8 type = 0;
+
+		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+			type |= 1;
+		if (fatal_signal_pending(p))
+			type |= 2;
+		if (likely(!type))
+			continue;
+		if (p->state & TASK_UNINTERRUPTIBLE)
+			type |= 4;
+		pr_warn("MemAlloc: %s(%u)%s%s%s\n", p->comm, p->pid,
+			(type & 4) ? " uninterruptible" : "",
+			(type & 2) ? " dying" : "",
+			(type & 1) ? " victim" : "");
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	cond_resched();
+	/*
+	 * Show traces of newly reported (or too long) stalling tasks.
+	 *
+	 * Show traces only once per 256 timeouts because their traces
+	 * will likely be the same (e.g. cond_sched() or congestion_wait())
+	 * when they are stalling inside __alloc_pages_slowpath().
+	 */
+	spin_lock(&memalloc_list_lock);
+	list_for_each_entry(m, &memalloc_list, list) {
+		if (time_before(now - m->start, kmallocwd_timeout) ||
+		    m->dumped++)
+			continue;
+		p = m->task;
+		sched_show_task(p);
+		debug_show_held_locks(p);
+		touch_nmi_watchdog();
+		if (!pid)
+			pid = p->pid;
+	}
+	spin_unlock(&memalloc_list_lock);
+	/*
+	 * Show traces of dying tasks (including victim tasks).
+	 *
+	 * Only dying tasks which are in trouble (e.g. blocked at unkillable
+	 * locks held by memory allocating tasks) will be repeatedly shown.
+	 * Therefore, we need to pay attention to tasks repeatedly shown here.
+	 */
+	preempt_disable();
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (likely(!fatal_signal_pending(p)))
+			continue;
+		sched_show_task(p);
+		debug_show_held_locks(p);
+		touch_nmi_watchdog();
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	show_workqueue_state();
+	if (!dump_target_pid)
+		dump_target_pid = -pid;
+	/* Wait until next timeout duration. */
+	schedule_timeout_interruptible(kmallocwd_timeout);
+	if (memalloc_counter[index])
+		goto maybe_stalling;
+	goto not_stalling;
+	return 0; /* To suppress "no return statement" compiler warning. */
+}
+
+static int __init start_kmallocwd(void)
+{
+	if (kmallocwd_timeout) {
+		struct task_struct *task = kthread_run(kmallocwd, NULL,
+						       "kmallocwd");
+		BUG_ON(IS_ERR(task));
+	}
+	return 0;
+}
+late_initcall(start_kmallocwd);
+
+static int __init kmallocwd_config(char *str)
+{
+	if (kstrtoul(str, 10, &kmallocwd_timeout) == 0)
+		kmallocwd_timeout = min(kmallocwd_timeout * HZ,
+					(unsigned long) LONG_MAX);
+	return 0;
+}
+__setup("kmallocwd=", kmallocwd_config);
+
+static void start_memalloc_timer(struct memalloc *m, const gfp_t gfp_mask,
+				 const int order)
+{
+	if (!kmallocwd_timeout || m->task)
+		return;
+	m->task = current;
+	m->start = jiffies;
+	m->gfp = gfp_mask;
+	m->order = order;
+	m->dumped = 0;
+	spin_lock(&memalloc_list_lock);
+	m->index = memalloc_counter_active_index;
+	memalloc_counter[m->index]++;
+	list_add_tail(&m->list, &memalloc_list);
+	spin_unlock(&memalloc_list_lock);
+}
+
+static void stop_memalloc_timer(struct memalloc *m)
+{
+	if (!m->task)
+		return;
+	spin_lock(&memalloc_list_lock);
+	memalloc_counter[m->index]--;
+	list_del(&m->list);
+	spin_unlock(&memalloc_list_lock);
+}
+
  static inline struct page *
  __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
  						struct alloc_context *ac)
@@ -2657,6 +2863,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
  	bool deferred_compaction = false;
  	int contended_compaction = COMPACT_CONTENDED_NONE;
+	struct memalloc m = { .task = NULL };

  	/*
  	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -2678,6 +2885,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
  		goto nopage;

  retry:
+	if (dump_target_pid == -current->pid)
+		dump_target_pid = -dump_target_pid;
+
  	if (!(gfp_mask & __GFP_NO_KSWAPD))
  		wake_all_kswapds(order, ac);

@@ -2740,6 +2950,8 @@ retry:
  	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
  		goto nopage;

+	start_memalloc_timer(&m, gfp_mask, order);
+
  	/*
  	 * Try direct compaction. The first pass is asynchronous. Subsequent
  	 * attempts after direct reclaim are synchronous
@@ -2798,6 +3010,10 @@ retry:
  		goto got_pg;

  	/* Check if we should retry the allocation */
+	if (dump_target_pid == current->pid) {
+		printk(KERN_INFO "did_some_progress=%lu\n", did_some_progress);
+		dump_target_pid = 0;
+	}
  	pages_reclaimed += did_some_progress;
  	if (should_alloc_retry(gfp_mask, order, did_some_progress,
  						pages_reclaimed)) {
@@ -2834,6 +3050,7 @@ retry:
  nopage:
  	warn_alloc_failed(gfp_mask, order, NULL);
  got_pg:
+	stop_memalloc_timer(&m);
  	return page;
  }

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1a17bd7..c449371 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2432,6 +2432,8 @@ static inline bool compaction_ready(struct zone *zone, int order)
  	return watermark_ok;
  }

+extern pid_t dump_target_pid;
+
  /*
   * This is the direct reclaim path, for page-allocating processes.  We only
   * try to reclaim pages from zones which will satisfy the caller's allocation
@@ -2533,7 +2535,27 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)

  		if (global_reclaim(sc) &&
  		    !reclaimable && zone_reclaimable(zone))
+		{
+			if (dump_target_pid == current->pid) {
+				unsigned long rec = zone_reclaimable_pages(zone);
+				unsigned long free = zone_page_state(zone, NR_FREE_PAGES);
+				unsigned long min = min_wmark_pages(zone);
+				unsigned long scanned = zone_page_state(zone, NR_PAGES_SCANNED);
+				unsigned long now = jiffies;
+				unsigned long rec2 = zone_page_state_snapshot(zone, NR_ACTIVE_FILE) +
+					zone_page_state_snapshot(zone, NR_INACTIVE_FILE);
+				unsigned long free2 = zone_page_state_snapshot(zone, NR_FREE_PAGES);
+				unsigned long scanned2 = zone_page_state_snapshot(zone, NR_PAGES_SCANNED);
+
+				printk(KERN_INFO "%s zone_reclaimable: reclaim:%lu(%lu,%lu,%ld) free:%lu(%lu,%ld) min:%lu pages_scanned:%lu(%lu,%ld) prio:%d\n",
+				       zone->name, rec, now - zone->stat_last_updated[NR_ACTIVE_FILE],
+				       now - zone->stat_last_updated[NR_INACTIVE_FILE], rec - rec2,
+				       free, now - zone->stat_last_updated[NR_FREE_PAGES], free - free2,
+				       min, scanned, now - zone->stat_last_updated[NR_PAGES_SCANNED],
+				       scanned - scanned2, sc->priority);
+			}
  			reclaimable = true;
+		}
  	}

  	/*
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
