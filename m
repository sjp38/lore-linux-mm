Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id D73D86B0038
	for <linux-mm@kvack.org>; Sat, 10 Oct 2015 08:51:12 -0400 (EDT)
Received: by iow1 with SMTP id 1so116213610iow.1
        for <linux-mm@kvack.org>; Sat, 10 Oct 2015 05:51:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s29si4078605ioe.40.2015.10.10.05.51.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 10 Oct 2015 05:51:11 -0700 (PDT)
Subject: Re: Can't we use timeout based OOM warning/killing?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150925093556.GF16497@dhcp22.suse.cz>
	<201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
	<201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
In-Reply-To: <201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
Message-Id: <201510102150.CHH51580.QSHOFOtFLVOJFM@I-love.SAKURA.ne.jp>
Date: Sat, 10 Oct 2015 21:50:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Tetsuo Handa wrote:
> Without means to find out what was happening, we will "overlook real bugs"
> before "paper over real bugs". The means are expected to work without
> knowledge to use trace points functionality, are expected to run without
> memory allocation, are expected to dump output without administrator's
> operation, are expected to work before power reset by watchdog timers.

I want to use something like this patch (CONFIG_DEBUG_something is fine).
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20151010.txt.xz
----------------------------------------
>From 0f749ddbc2bd9ce57ba56787e77595c3f13e9cc3 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 10 Oct 2015 20:48:09 +0900
Subject: [PATCH] Memory allocation watchdog kernel thread.

This patch adds a kernel thread which periodically reports number of
memory allocating tasks, dying tasks and OOM victim tasks.
This kernel thread helps reporting whether we are failing to solve OOM
conditions after OOM killer is invoked, in addition to reporting stalls
before OOM killer is invoked (e.g. all __GFP_FS allocating tasks are
blocked by locks or throttling whereas all !__GFP_FS allocating tasks
are unable to invoke the OOM killer).

$ grep MemAlloc serial.txt | grep -A 5 MemAlloc-Info:
[  101.937548] MemAlloc-Info: 4 stalling task, 32 dying task, 1 victim task.
[  101.939460] MemAlloc: sync4(10598) gfp=0x24280ca order=0 delay=17338
[  101.975433] MemAlloc: sync4(10602) gfp=0x24280ca order=0 delay=17115
[  102.015519] MemAlloc: sync4(10599) gfp=0x24280ca order=0 delay=17097
[  102.053884] MemAlloc: sync4(10607) gfp=0x24280ca order=0 delay=15970
[  112.094349] MemAlloc-Info: 176 stalling task, 32 dying task, 1 victim task.
[  112.098411] MemAlloc: sync4(10598) gfp=0x24280ca order=0 delay=27494
[  112.138381] MemAlloc: sync4(10602) gfp=0x24280ca order=0 delay=27271
[  112.178710] MemAlloc: sync4(10599) gfp=0x24280ca order=0 delay=27253
[  112.218674] MemAlloc: sync4(10607) gfp=0x24280ca order=0 delay=26126
[  112.257749] MemAlloc: sync4(10608) gfp=0x24280ca order=0 delay=14083
--
[  128.952137] MemAlloc-Info: 176 stalling task, 32 dying task, 1 victim task.
[  128.954056] MemAlloc: sync4(10598) gfp=0x24280ca order=0 delay=44352
[  128.992231] MemAlloc: sync4(10602) gfp=0x24280ca order=0 delay=44129
[  129.034180] MemAlloc: sync4(10599) gfp=0x24280ca order=0 delay=44111
[  129.071755] MemAlloc: sync4(10607) gfp=0x24280ca order=0 delay=42984
[  129.109851] MemAlloc: sync4(10608) gfp=0x24280ca order=0 delay=30941
--
[  145.683171] MemAlloc-Info: 175 stalling task, 32 dying task, 1 victim task.
[  145.685344] MemAlloc: sync4(10598) gfp=0x24280ca order=0 delay=61084
[  145.736475] MemAlloc: sync4(10599) gfp=0x24280ca order=0 delay=60843
[  145.778084] MemAlloc: sync4(10607) gfp=0x24280ca order=0 delay=59716
[  145.815363] MemAlloc: sync4(10608) gfp=0x24280ca order=0 delay=47673
[  145.853610] MemAlloc: sync4(10601) gfp=0x24280ca order=0 delay=47673
--
[  158.030038] MemAlloc-Info: 178 stalling task, 32 dying task, 1 victim task.
[  158.031945] MemAlloc: sync4(10598) gfp=0x24280ca order=0 delay=73430
[  158.071066] MemAlloc: sync4(10599) gfp=0x24280ca order=0 delay=73189
[  158.108835] MemAlloc: sync4(10607) gfp=0x24280ca order=0 delay=72062
[  158.146500] MemAlloc: sync4(10608) gfp=0x24280ca order=0 delay=60019
[  158.184146] MemAlloc: sync4(10601) gfp=0x24280ca order=0 delay=60019
--
[  174.851184] MemAlloc-Info: 178 stalling task, 32 dying task, 1 victim task.
[  174.853106] MemAlloc: sync4(10598) gfp=0x24280ca order=0 delay=90252
[  174.896592] MemAlloc: sync4(10599) gfp=0x24280ca order=0 delay=90011
[  174.935838] MemAlloc: sync4(10607) gfp=0x24280ca order=0 delay=88884
[  174.978799] MemAlloc: sync4(10608) gfp=0x24280ca order=0 delay=76841
[  175.022003] MemAlloc: sync4(10601) gfp=0x24280ca order=0 delay=76841
--

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 145 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 145 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0d6f540..0473eec 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2972,6 +2972,147 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
 	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
 }
 
+#if 1
+
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
+};
+
+static LIST_HEAD(memalloc_list); /* List of "struct memalloc".*/
+static DEFINE_SPINLOCK(memalloc_list_lock); /* Lock for memalloc_list. */
+
+/*
+ * malloc_watchdog - A kernel thread for monitoring memory allocation stalls.
+ *
+ * @unused: Not used.
+ *
+ * This kernel thread does not terminate.
+ */
+static int malloc_watchdog(void *unused)
+{
+	static const unsigned long timeout = 10 * HZ;
+	struct memalloc *m;
+	struct task_struct *g, *p;
+	unsigned long now;
+	unsigned long spent;
+	unsigned int sigkill_pending;
+	unsigned int memdie_pending;
+	unsigned int stalling_tasks;
+	u8 index;
+
+ not_stalling: /* Healty case. */
+	/*
+	 * Switch active counter and wait for timeout duration.
+	 * This is a kind of open coded implementation of synchronize_srcu()
+	 * because synchronize_srcu_timeout() is missing.
+	 */
+	spin_lock(&memalloc_list_lock);
+	index = memalloc_counter_active_index;
+	memalloc_counter_active_index ^= 1;
+	spin_unlock(&memalloc_list_lock);
+	schedule_timeout_interruptible(timeout);
+	/*
+	 * If memory allocations are working, the counter should remain 0
+	 * because tasks will be able to call both start_memalloc_timer()
+	 * and stop_memalloc_timer() within timeout duration.
+	 */
+	if (likely(!memalloc_counter[index]))
+		goto not_stalling;
+ maybe_stalling: /* Maybe something is wrong. Let's check. */
+	/* First, report whether there are SIGKILL tasks and/or OOM victims. */
+	sigkill_pending = 0;
+	memdie_pending = 0;
+	stalling_tasks = 0;
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
+	spin_lock(&memalloc_list_lock);
+	now = jiffies;
+	list_for_each_entry(m, &memalloc_list, list) {
+		spent = now - m->start;
+		if (time_before(spent, timeout))
+			continue;
+		stalling_tasks++;
+	}
+	pr_warn("MemAlloc-Info: %u stalling task, %u dying task, %u victim task.\n",
+		stalling_tasks, sigkill_pending, memdie_pending);
+	/* Next, report tasks stalled at memory allocation. */
+	list_for_each_entry(m, &memalloc_list, list) {
+		spent = now - m->start;
+		if (time_before(spent, timeout))
+			continue;
+		p = m->task;
+		pr_warn("MemAlloc%s: %s(%u) gfp=0x%x order=%u delay=%lu\n",
+			test_tsk_thread_flag(p, TIF_MEMDIE) ? "-victim" :
+			(fatal_signal_pending(p) ? "-dying" : ""),
+			p->comm, p->pid, m->gfp, m->order, spent);
+		show_stack(p, NULL);
+	}
+	spin_unlock(&memalloc_list_lock);
+	/* Wait until next timeout duration. */
+	schedule_timeout_interruptible(timeout);
+	if (memalloc_counter[index])
+		goto maybe_stalling;
+	goto not_stalling;
+	return 0;
+}
+
+static int __init start_malloc_watchdog(void)
+{
+	struct task_struct *task = kthread_run(malloc_watchdog, NULL,
+					       "MallocWatchdog");
+	BUG_ON(IS_ERR(task));
+	return 0;
+}
+late_initcall(start_malloc_watchdog);
+
+#define DEFINE_MEMALLOC_TIMER(m) struct memalloc m = { .task = NULL }
+
+static void start_memalloc_timer(struct memalloc *m, gfp_t gfp_mask, int order)
+{
+	if (m->task)
+		return;
+	m->task = current;
+	m->start = jiffies;
+	m->gfp = gfp_mask;
+	order = order;
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
+#else
+#define DEFINE_MEMALLOC_TIMER(m)
+#define start_memalloc_timer(m, gfp_mask, order)
+#define stop_memalloc_timer(m)
+#endif
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
@@ -2984,6 +3125,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	DEFINE_MEMALLOC_TIMER(m);
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3075,6 +3217,8 @@ retry:
 	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
 		goto nopage;
 
+	start_memalloc_timer(&m, gfp_mask, order);
+
 	/*
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
@@ -3168,6 +3312,7 @@ noretry:
 nopage:
 	warn_alloc_failed(gfp_mask, order, NULL);
 got_pg:
+	stop_memalloc_timer(&m);
 	return page;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
