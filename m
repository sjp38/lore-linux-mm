Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9788A6B00A0
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 07:06:44 -0400 (EDT)
Subject: [rfc] lru_add_drain_all() vs isolation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1252311463.7586.26.camel@marge.simson.net>
References: <dgRNo-3uc-5@gated-at.bofh.it> <dhb9j-1hp-5@gated-at.bofh.it>
	 <dhcf5-263-13@gated-at.bofh.it>
	 <36bbf267-be27-4c9e-b782-91ed32a1dfe9@g1g2000pra.googlegroups.com>
	 <1252218779.6126.17.camel@marge.simson.net>
	 <1252232289.29247.11.camel@marge.simson.net>
	 <DDFD17CC94A9BD49A82147DDF7D545C54DC482@exchange.ZeugmaSystems.local>
	 <1252249790.13541.28.camel@marge.simson.net>
	 <1252311463.7586.26.camel@marge.simson.net>
Content-Type: text/plain
Date: Mon, 07 Sep 2009 13:06:36 +0200
Message-Id: <1252321596.7959.6.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mike Galbraith <efault@gmx.de>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-09-07 at 10:17 +0200, Mike Galbraith wrote:

> [  774.651779] SysRq : Show Blocked State
> [  774.655770]   task                        PC stack   pid father
> [  774.655770] evolution.bin D ffff8800bc1575f0     0  7349   6459 0x00000000
> [  774.676008]  ffff8800bc3c9d68 0000000000000086 ffff8800015d9340 ffff8800bb91b780
> [  774.676008]  000000000000dd28 ffff8800bc3c9fd8 0000000000013340 0000000000013340
> [  774.676008]  00000000000000fd ffff8800015d9340 ffff8800bc1575f0 ffff8800bc157888
> [  774.676008] Call Trace:
> [  774.676008]  [<ffffffff812c4a11>] schedule_timeout+0x2d/0x20c
> [  774.676008]  [<ffffffff812c4891>] wait_for_common+0xde/0x155
> [  774.676008]  [<ffffffff8103f1cd>] ? default_wake_function+0x0/0x14
> [  774.676008]  [<ffffffff810c0e63>] ? lru_add_drain_per_cpu+0x0/0x10
> [  774.676008]  [<ffffffff810c0e63>] ? lru_add_drain_per_cpu+0x0/0x10
> [  774.676008]  [<ffffffff812c49ab>] wait_for_completion+0x1d/0x1f
> [  774.676008]  [<ffffffff8105fdf5>] flush_work+0x7f/0x93
> [  774.676008]  [<ffffffff8105f870>] ? wq_barrier_func+0x0/0x14
> [  774.676008]  [<ffffffff81060109>] schedule_on_each_cpu+0xb4/0xed
> [  774.676008]  [<ffffffff810c0c78>] lru_add_drain_all+0x15/0x17
> [  774.676008]  [<ffffffff810d1dbd>] sys_mlock+0x2e/0xde
> [  774.676008]  [<ffffffff8100bc1b>] system_call_fastpath+0x16/0x1b

FWIW, something like the below (prone to explode since its utterly
untested) should (mostly) fix that one case. Something similar needs to
be done for pretty much all machine wide workqueue thingies, possibly
also flush_workqueue().

---
 include/linux/workqueue.h |    1 +
 kernel/workqueue.c        |   52 +++++++++++++++++++++++++++++++++++---------
 mm/swap.c                 |   14 ++++++++---
 3 files changed, 52 insertions(+), 15 deletions(-)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index 6273fa9..95b1df2 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -213,6 +213,7 @@ extern int schedule_work_on(int cpu, struct work_struct *work);
 extern int schedule_delayed_work(struct delayed_work *work, unsigned long delay);
 extern int schedule_delayed_work_on(int cpu, struct delayed_work *work,
 					unsigned long delay);
+extern int schedule_on_mask(const struct cpumask *mask, work_func_t func);
 extern int schedule_on_each_cpu(work_func_t func);
 extern int current_is_keventd(void);
 extern int keventd_up(void);
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 3c44b56..81456fc 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -657,6 +657,23 @@ int schedule_delayed_work_on(int cpu,
 }
 EXPORT_SYMBOL(schedule_delayed_work_on);
 
+struct sched_work_struct {
+	struct work_struct work;
+	work_func_t func;
+	atomic_t *count;
+	struct completion *completion;
+};
+
+static void do_sched_work(struct work_struct *work)
+{
+	struct sched_work_struct *sws = work;
+
+	sws->func(NULL);
+
+	if (atomic_dec_and_test(sws->count))
+		complete(sws->completion);
+}
+
 /**
  * schedule_on_each_cpu - call a function on each online CPU from keventd
  * @func: the function to call
@@ -666,29 +683,42 @@ EXPORT_SYMBOL(schedule_delayed_work_on);
  *
  * schedule_on_each_cpu() is very slow.
  */
-int schedule_on_each_cpu(work_func_t func)
+int schedule_on_mask(const struct cpumask *mask, work_func_t func)
 {
+	struct completion completion = COMPLETION_INITIALIZER_ONSTACK(completion);
+	atomic_t count = ATOMIC_INIT(cpumask_weight(mask));
+	struct sched_work_struct *works;
 	int cpu;
-	struct work_struct *works;
 
-	works = alloc_percpu(struct work_struct);
+	works = alloc_percpu(struct sched_work_struct);
 	if (!works)
 		return -ENOMEM;
 
-	get_online_cpus();
-	for_each_online_cpu(cpu) {
-		struct work_struct *work = per_cpu_ptr(works, cpu);
+	for_each_cpu(cpu, mask) {
+		struct sched_work_struct *work = per_cpu_ptr(works, cpu);
+		work->count = &count;
+		work->completion = &completion;
+		work->func = func;
 
-		INIT_WORK(work, func);
-		schedule_work_on(cpu, work);
+		INIT_WORK(&work->work, do_sched_work);
+		schedule_work_on(cpu, &work->work);
 	}
-	for_each_online_cpu(cpu)
-		flush_work(per_cpu_ptr(works, cpu));
-	put_online_cpus();
+	wait_for_completion(&completion);
 	free_percpu(works);
 	return 0;
 }
 
+int schedule_on_each_cpu(work_func_t func)
+{
+	int ret;
+
+	get_online_cpus();
+	ret = schedule_on_mask(cpu_online_mask, func);
+	put_online_cpus();
+
+	return ret;
+}
+
 void flush_scheduled_work(void)
 {
 	flush_workqueue(keventd_wq);
diff --git a/mm/swap.c b/mm/swap.c
index cb29ae5..11e4b1e 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -36,6 +36,7 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
+static cpumask_t lru_drain_mask;
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 
@@ -216,12 +217,15 @@ EXPORT_SYMBOL(mark_page_accessed);
 
 void __lru_cache_add(struct page *page, enum lru_list lru)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs)[lru];
+	int cpu = get_cpu();
+	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu)[lru];
+
+	cpumask_set_cpu(cpu, lru_drain_mask);
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
 		____pagevec_lru_add(pvec, lru);
-	put_cpu_var(lru_add_pvecs);
+	put_cpu();
 }
 
 /**
@@ -294,7 +298,9 @@ static void drain_cpu_pagevecs(int cpu)
 
 void lru_add_drain(void)
 {
-	drain_cpu_pagevecs(get_cpu());
+	int cpu = get_cpu();
+	cpumask_clear_cpu(cpu, lru_drain_mask);
+	drain_cpu_pagevecs(cpu);
 	put_cpu();
 }
 
@@ -308,7 +314,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
  */
 int lru_add_drain_all(void)
 {
-	return schedule_on_each_cpu(lru_add_drain_per_cpu);
+	return schedule_on_mask(lru_drain_mask, lru_add_drain_per_cpu);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
