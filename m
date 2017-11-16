Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F15F28025F
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 06:59:10 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id b80so3385543iob.23
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 03:59:10 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h82si609097ioa.94.2017.11.16.03.59.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 03:59:06 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [RFC PATCH v2] mm,sched: include memalloc info when printing debug dump of a task.
Date: Thu, 16 Nov 2017 20:57:28 +0900
Message-Id: <1510833448-19918-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mikhail.v.gavrilov@gmail.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

When analyzing memory allocation stalls, ability to cleanly take snapshots
for knowing how far progress is made is important. But warn_alloc() was
too problematic and was reverted by commit 400e22499dd92613 ("mm: don't
warn about allocations which stall for too long"). This patch demonstrates
what I referred as "asynchronous approach which can obtain information
during stalls with possibly relevant threads" in that commit.

I have been proposing memory allocation watchdog kernel thread [1], but
so far nobody seems to be interested in using ability to take snapshots
cleanly.

  [1] http://lkml.kernel.org/r/1495331504-12480-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

This patch is subset of the watchdog, which introduces a state tracking of
__GFP_DIRECT_RECLAIM memory allocations and prints MemAlloc: line to e.g.
SysRq-t output, like an example shown below which was fixed by commit
db73ee0d46379922 ("mm, vmscan: do not loop on too_many_isolated for ever").

----------
[  222.194538] a.out           R  running task        0  1976   1019 0x00000080
[  222.197091] MemAlloc: a.out(1976) flags=0x400840 switches=286 seq=142 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=175646
[  222.202617] Call Trace:
[  222.203987]  __schedule+0x23f/0x5d0
[  222.205624]  _cond_resched+0x2d/0x40
[  222.207271]  shrink_page_list+0x61/0xb70
[  222.208960]  shrink_inactive_list+0x24c/0x510
[  222.210794]  shrink_node_memcg+0x360/0x780
[  222.212556]  ? shrink_slab.part.44+0x239/0x2c0
[  222.214409]  shrink_node+0xdc/0x310
[  222.215994]  ? shrink_node+0xdc/0x310
[  222.217617]  do_try_to_free_pages+0xea/0x360
[  222.219416]  try_to_free_pages+0xbd/0xf0
[  222.221120]  __alloc_pages_slowpath+0x464/0xe50
[  222.222992]  ? io_schedule_timeout+0x19/0x40
[  222.224790]  __alloc_pages_nodemask+0x253/0x2c0
[  222.226677]  alloc_pages_current+0x65/0xd0
[  222.228427]  __page_cache_alloc+0x81/0x90
[  222.230301]  pagecache_get_page+0xa6/0x210
[  222.232388]  grab_cache_page_write_begin+0x1e/0x40
[  222.234333]  iomap_write_begin.constprop.17+0x56/0x110
[  222.236375]  iomap_write_actor+0x8f/0x160
[  222.238115]  ? iomap_write_begin.constprop.17+0x110/0x110
[  222.240219]  iomap_apply+0x9a/0x110
[  222.241813]  ? iomap_write_begin.constprop.17+0x110/0x110
[  222.243925]  iomap_file_buffered_write+0x69/0x90
[  222.245828]  ? iomap_write_begin.constprop.17+0x110/0x110
[  222.247968]  xfs_file_buffered_aio_write+0xb7/0x200 [xfs]
[  222.250108]  xfs_file_write_iter+0x8d/0x130 [xfs]
[  222.252045]  __vfs_write+0xef/0x150
[  222.253635]  vfs_write+0xb0/0x190
[  222.255184]  SyS_write+0x50/0xc0
[  222.256689]  do_syscall_64+0x62/0x170
[  222.258312]  entry_SYSCALL64_slow_path+0x25/0x25
----------

----------
[  406.416809] a.out           R  running task        0  1976   1019 0x00000080
[  406.416811] MemAlloc: a.out(1976) flags=0x400840 switches=440 seq=142 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=359866
[  406.416811] Call Trace:
[  406.416813]  __schedule+0x23f/0x5d0
[  406.416814]  _cond_resched+0x2d/0x40
[  406.416816]  wait_iff_congested+0x73/0x100
[  406.416817]  ? wait_woken+0x80/0x80
[  406.416819]  shrink_inactive_list+0x36a/0x510
[  406.416820]  shrink_node_memcg+0x360/0x780
[  406.416822]  ? shrink_slab.part.44+0x239/0x2c0
[  406.416824]  shrink_node+0xdc/0x310
[  406.416825]  ? shrink_node+0xdc/0x310
[  406.416827]  do_try_to_free_pages+0xea/0x360
[  406.416828]  try_to_free_pages+0xbd/0xf0
[  406.416829]  __alloc_pages_slowpath+0x464/0xe50
[  406.416831]  ? io_schedule_timeout+0x19/0x40
[  406.416832]  __alloc_pages_nodemask+0x253/0x2c0
[  406.416834]  alloc_pages_current+0x65/0xd0
[  406.416835]  __page_cache_alloc+0x81/0x90
[  406.416837]  pagecache_get_page+0xa6/0x210
[  406.416838]  grab_cache_page_write_begin+0x1e/0x40
[  406.416839]  iomap_write_begin.constprop.17+0x56/0x110
[  406.416841]  iomap_write_actor+0x8f/0x160
[  406.416842]  ? iomap_write_begin.constprop.17+0x110/0x110
[  406.416844]  iomap_apply+0x9a/0x110
[  406.416845]  ? iomap_write_begin.constprop.17+0x110/0x110
[  406.416846]  iomap_file_buffered_write+0x69/0x90
[  406.416848]  ? iomap_write_begin.constprop.17+0x110/0x110
[  406.416857]  xfs_file_buffered_aio_write+0xb7/0x200 [xfs]
[  406.416866]  xfs_file_write_iter+0x8d/0x130 [xfs]
[  406.416867]  __vfs_write+0xef/0x150
[  406.416869]  vfs_write+0xb0/0x190
[  406.416870]  SyS_write+0x50/0xc0
[  406.416871]  do_syscall_64+0x62/0x170
[  406.416872]  entry_SYSCALL64_slow_path+0x25/0x25
----------

This patch traces at the page fault handler and the mempool allocator
in addition to the page allocator, for the page fault handler does
sleeping operations other than calling the page allocator and the mempool
allocator fails to track accumulated delay due to __GFP_NORETRY.

This patch also provides administrators ability to take administrator-
controlled actions based on some threshold by polling like khungtaskd
kernel thread using e.g. SystemTap script, for this patch can record
the timestamp of beginning of memory allocation request without risk of
overflowing array capacity and/or skipping probes. For example, a
SystemTap script shown below will roughly mimic the watchdog.

----------
stap -DSTP_NO_OVERLOAD=1 -g - << "EOF"
%{
#include <linux/sched/debug.h>

/**
 * is_stalling_task - Check a task's memalloc variable.
 *
 * @task:   A task to check.
 * @expire: Timeout in jiffies.
 *
 * Returns true if a task is stalling, false otherwise.
 */
static inline bool is_stalling_task(const struct task_struct *task,
                                    const unsigned long expire)
{
        const struct memalloc_info *m = &task->memalloc;

        return m->in_flight && time_after_eq(expire, m->start);
}

/**
 * check_memalloc_stalling_tasks - Check for memory allocation stalls.
 *
 * @timeout: Timeout in jiffies.
 *
 * Returns number of stalling tasks.
 */
static int check_memalloc_stalling_tasks(unsigned long timeout)
{
        struct task_struct *g, *p;
        const unsigned long expire = jiffies - timeout;
        unsigned int sigkill_pending = 0;
        unsigned int exiting_tasks = 0;
        unsigned int memdie_pending = 0;
        unsigned int stalling_tasks = 0;

        /* Count stalling tasks, dying and victim tasks. */
        rcu_read_lock();
        for_each_process_thread(g, p) {
                if (test_tsk_thread_flag(p, TIF_MEMDIE))
                        memdie_pending++;
                if (fatal_signal_pending(p))
                        sigkill_pending++;
                if ((p->flags & PF_EXITING) && p->state != TASK_DEAD)
                        exiting_tasks++;
                if (is_stalling_task(p, expire))
                        stalling_tasks++;
        }
        rcu_read_unlock();
        if (!stalling_tasks)
                return 0;
        /* Report stalling tasks, dying and victim tasks. */
        pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u\n",
                stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending);
        sigkill_pending = 0;
        exiting_tasks = 0;
        memdie_pending = 0;
        stalling_tasks = 0;
        rcu_read_lock();
        for_each_process_thread(g, p) {
                bool report = false;

                if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
                        report = true;
                        memdie_pending++;
                }
                if (fatal_signal_pending(p)) {
                        report = true;
                        sigkill_pending++;
                }
                if ((p->flags & PF_EXITING) && p->state != TASK_DEAD) {
                        report = true;
                        exiting_tasks++;
                }
                if (is_stalling_task(p, expire)) {
                        report = true;
                        stalling_tasks++;
                }
                if (p->flags & PF_KSWAPD)
                        report = true;
                if (unlikely(report))
                        sched_show_task(p);
        }
        rcu_read_unlock();
        /* Show lock information. (SysRq-d) */
        debug_show_all_locks();
        pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u\n",
                stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending);
        return stalling_tasks;
}
%}

probe timer.s(120)
{
        %{ check_memalloc_stalling_tasks(60 * HZ) %}
}
EOF
----------

For another example, we can modify the script shown above to enable
various tracepoints for obtaining more detailed information when
check_memalloc_stalling_tasks() returned non-zero and then disable them
when check_memalloc_stalling_tasks() returned zero. This will help
unattended recording for analyzing memory allocation stalls which
previously required manual operations.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Tejun Heo <tj@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: yuwang.yuwang <yuwang.yuwang@alibaba-inc.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/gfp.h   |  8 ++++++++
 include/linux/sched.h | 15 +++++++++++++++
 kernel/fork.c         |  4 ++++
 kernel/sched/core.c   | 15 +++++++++++++++
 lib/Kconfig.debug     |  8 ++++++++
 mm/memory.c           |  5 +++++
 mm/mempool.c          |  9 ++++++++-
 mm/page_alloc.c       | 29 +++++++++++++++++++++++++++++
 8 files changed, 92 insertions(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1a4582b..47b7d13 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -483,6 +483,14 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	return __alloc_pages_node(nid, gfp_mask, order);
 }
 
+#ifdef CONFIG_DEBUG_SHOW_MEMALLOC_LINE
+extern void start_memalloc_timer(const gfp_t gfp_mask, const int order);
+extern void stop_memalloc_timer(const gfp_t gfp_mask);
+#else
+#define start_memalloc_timer(gfp_mask, order) do { } while (0)
+#define stop_memalloc_timer(gfp_mask) do { } while (0)
+#endif
+
 #ifdef CONFIG_NUMA
 extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a5dc7c9..00a5513 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -517,6 +517,18 @@ struct wake_q_node {
 	struct wake_q_node *next;
 };
 
+struct memalloc_info {
+	/* Is current thread doing (nested) memory allocation? */
+	u8 in_flight;
+	/* For progress monitoring. */
+	unsigned int sequence;
+	/* Started time in jiffies as of in_flight == 1. */
+	unsigned long start;
+	/* Requested order and gfp flags as of in_flight == 1. */
+	unsigned int order;
+	gfp_t gfp;
+};
+
 struct task_struct {
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 	/*
@@ -1098,6 +1110,9 @@ struct task_struct {
 	/* Used by LSM modules for access restriction: */
 	void				*security;
 #endif
+#ifdef CONFIG_DEBUG_SHOW_MEMALLOC_LINE
+	struct memalloc_info		memalloc;
+#endif
 
 	/*
 	 * New fields for task_struct should be added above here, so that
diff --git a/kernel/fork.c b/kernel/fork.c
index a01574a..97ea0da 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1763,6 +1763,10 @@ static __latent_entropy struct task_struct *copy_process(
 	p->sequential_io_avg	= 0;
 #endif
 
+#ifdef CONFIG_DEBUG_SHOW_MEMALLOC_LINE
+	p->memalloc.sequence = 0;
+#endif
+
 	/* Perform scheduler related setup. Assign this task to a CPU. */
 	retval = sched_fork(clone_flags, p);
 	if (retval)
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 75554f3..2bbfb2b 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -5170,6 +5170,20 @@ static int sched_rr_get_interval(pid_t pid, struct timespec64 *t)
 }
 #endif
 
+static inline void print_memalloc_info(struct task_struct *p)
+{
+#ifdef CONFIG_DEBUG_SHOW_MEMALLOC_LINE
+	const struct memalloc_info *m = &p->memalloc;
+
+	if (unlikely(m->in_flight))
+		pr_info("MemAlloc: %s(%u) flags=0x%x switches=%lu seq=%u gfp=0x%x(%pGg) order=%u delay=%lu%s\n",
+			p->comm, p->pid, p->flags, p->nvcsw + p->nivcsw,
+			m->sequence, m->gfp, &m->gfp, m->order,
+			jiffies - m->start, (p->state & TASK_UNINTERRUPTIBLE) ?
+			" uninterruptible" : "");
+#endif
+}
+
 void sched_show_task(struct task_struct *p)
 {
 	unsigned long free = 0;
@@ -5194,6 +5208,7 @@ void sched_show_task(struct task_struct *p)
 		task_pid_nr(p), ppid,
 		(unsigned long)task_thread_info(p)->flags);
 
+	print_memalloc_info(p);
 	print_worker_info(KERN_INFO, p);
 	show_stack(p, NULL);
 	put_task_stack(p);
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 947d3e2..6c9a247 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -942,6 +942,14 @@ config WQ_WATCHDOG
 	  state.  This can be configured through kernel parameter
 	  "workqueue.watchdog_thresh" and its sysfs counterpart.
 
+config DEBUG_SHOW_MEMALLOC_LINE
+	bool "Print memory allocation status line to thread dumps"
+	default n
+	help
+	  Say Y here to emit memory allocation status line when e.g. SysRq-t
+	  is requested, in order to help anayzing problems under memory
+	  pressure.
+
 endmenu # "Debug lockups and hangs"
 
 config PANIC_ON_OOPS
diff --git a/mm/memory.c b/mm/memory.c
index 85e7a87..70a8040 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4070,6 +4070,7 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags)
 {
 	int ret;
+	gfp_t mask;
 
 	__set_current_state(TASK_RUNNING);
 
@@ -4091,6 +4092,9 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	if (flags & FAULT_FLAG_USER)
 		mem_cgroup_oom_enable();
 
+	mask = __get_fault_gfp_mask(vma);
+	start_memalloc_timer(mask, 0);
+
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
 	else
@@ -4108,6 +4112,7 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 			mem_cgroup_oom_synchronize(false);
 	}
 
+	stop_memalloc_timer(mask);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(handle_mm_fault);
diff --git a/mm/mempool.c b/mm/mempool.c
index 7d8c5a0..e7b7532 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -325,11 +325,14 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
 
+	start_memalloc_timer(gfp_temp, -1);
 repeat_alloc:
 
 	element = pool->alloc(gfp_temp, pool->pool_data);
-	if (likely(element != NULL))
+	if (likely(element != NULL)) {
+		stop_memalloc_timer(gfp_temp);
 		return element;
+	}
 
 	spin_lock_irqsave(&pool->lock, flags);
 	if (likely(pool->curr_nr)) {
@@ -342,6 +345,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 		 * for debugging.
 		 */
 		kmemleak_update_trace(element);
+		stop_memalloc_timer(gfp_temp);
 		return element;
 	}
 
@@ -351,13 +355,16 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 	 */
 	if (gfp_temp != gfp_mask) {
 		spin_unlock_irqrestore(&pool->lock, flags);
+		stop_memalloc_timer(gfp_temp);
 		gfp_temp = gfp_mask;
+		start_memalloc_timer(gfp_temp, -1);
 		goto repeat_alloc;
 	}
 
 	/* We must not sleep if !__GFP_DIRECT_RECLAIM */
 	if (!(gfp_mask & __GFP_DIRECT_RECLAIM)) {
 		spin_unlock_irqrestore(&pool->lock, flags);
+		stop_memalloc_timer(gfp_temp);
 		return NULL;
 	}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f34124a..61a6ab0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4198,6 +4198,33 @@ static inline void finalise_ac(gfp_t gfp_mask,
 					ac->high_zoneidx, ac->nodemask);
 }
 
+#ifdef CONFIG_DEBUG_SHOW_MEMALLOC_LINE
+
+void start_memalloc_timer(const gfp_t gfp_mask, const int order)
+{
+	struct memalloc_info *m = &current->memalloc;
+
+	/* We don't check for stalls for !__GFP_DIRECT_RECLAIM allocations. */
+	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
+		return;
+	/* Record the beginning of memory allocation request. */
+	if (!m->in_flight) {
+		m->sequence++;
+		m->start = jiffies;
+		m->order = order;
+		m->gfp = gfp_mask;
+	}
+	m->in_flight++;
+}
+
+void stop_memalloc_timer(const gfp_t gfp_mask)
+{
+	if (gfp_mask & __GFP_DIRECT_RECLAIM)
+		current->memalloc.in_flight--;
+}
+
+#endif
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -4218,6 +4245,7 @@ struct page *
 	finalise_ac(gfp_mask, order, &ac);
 
 	/* First allocation attempt */
+	start_memalloc_timer(alloc_mask, order);
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
 	if (likely(page))
 		goto out;
@@ -4247,6 +4275,7 @@ struct page *
 		page = NULL;
 	}
 
+	stop_memalloc_timer(alloc_mask);
 	trace_mm_page_alloc(page, order, alloc_mask, ac.migratetype);
 
 	return page;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
