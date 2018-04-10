Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8CBDD6B0006
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 04:15:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id y7-v6so8970641plh.7
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 01:15:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r62si1754075pfe.68.2018.04.10.01.15.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Apr 2018 01:15:42 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC] mm, slab: reschedule cache_reap() on the same CPU
Date: Tue, 10 Apr 2018 10:15:31 +0200
Message-Id: <20180410081531.18053-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>

cache_reap() is initially scheduled in start_cpu_timer() via
schedule_delayed_work_on(). But then the next iterations are scheduled via
schedule_delayed_work(), thus using WORK_CPU_UNBOUND.

AFAIU there is thus no guarantee the future iterations will happen on the
intended cpu, although it's preferred. I was able to demonstrate this with
/sys/module/workqueue/parameters/debug_force_rr_cpu. IIUC the timer code, it
may also happen due to migrating timers in nohz context. As a result, some
cpu's would be calling cache_reap() more frequently and others never.

What would be even worse is a potential scenario where WORK_CPU_UNBOUND would
result in being run via kworker thread that's not pinned to any single CPU
(although I haven't observed that in my simple tests). Migration to another CPU
during cache_reap() e.g. between cpu_cache_get() and drain_array() would result
in operating on non-local cpu array cache and might race with the other cpu.
Migration to another numa node than the one obtained with numa_mem_id() could
result in slabs being moved to a list on a wrong node, which would then be
modified with a wrong lock, againn potentially racing.

This patch makes sure schedule_delayed_work_on() is used with the proper cpu
when scheduling the next iteration. The cpu is stored with delayed_work on a
new slab_reap_work_struct super-structure.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Stephen Boyd <sboyd@kernel.org>
---
Hi,

this patch is a result of hunting some rare crashes in our (4.4-based) kernel
where slabs misplaced on wrong nodes were identified in the crash dumps. I
don't yet know if cache_reap() is the culprit and if this patch fill fix it,
but the problem seems real to me nevertheless. I CC'd workqueue and timer
maintainers and would like to check if my assumptions in changelog are correct,
and especially if there's a guarantee that work scheduled with
schedule_delayed_work_on(cpu) will never migrate to another cpu. If that's not
guaranteed (including past stable kernel versions), we will have to be even
more careful and e.g. disable interrupts sooner.

Thanks,
Vlastimil

 mm/slab.c | 29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9095c3945425..b3e3d082099c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -429,7 +429,12 @@ static struct kmem_cache kmem_cache_boot = {
 	.name = "kmem_cache",
 };
 
-static DEFINE_PER_CPU(struct delayed_work, slab_reap_work);
+struct slab_reap_work_struct {
+	struct delayed_work dwork;
+	int cpu;
+};
+
+static DEFINE_PER_CPU(struct slab_reap_work_struct, slab_reap_work);
 
 static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
 {
@@ -551,12 +556,15 @@ static void next_reap_node(void)
  */
 static void start_cpu_timer(int cpu)
 {
-	struct delayed_work *reap_work = &per_cpu(slab_reap_work, cpu);
 
-	if (reap_work->work.func == NULL) {
+	struct slab_reap_work_struct *reap_work = &per_cpu(slab_reap_work, cpu);
+	struct delayed_work *dwork = &reap_work->dwork;
+
+	if (dwork->work.func == NULL) {
+		reap_work->cpu = cpu;
 		init_reap_node(cpu);
-		INIT_DEFERRABLE_WORK(reap_work, cache_reap);
-		schedule_delayed_work_on(cpu, reap_work,
+		INIT_DEFERRABLE_WORK(dwork, cache_reap);
+		schedule_delayed_work_on(cpu, dwork,
 					__round_jiffies_relative(HZ, cpu));
 	}
 }
@@ -1120,9 +1128,9 @@ static int slab_offline_cpu(unsigned int cpu)
 	 * expensive but will only modify reap_work and reschedule the
 	 * timer.
 	 */
-	cancel_delayed_work_sync(&per_cpu(slab_reap_work, cpu));
+	cancel_delayed_work_sync(&per_cpu(slab_reap_work, cpu).dwork);
 	/* Now the cache_reaper is guaranteed to be not running. */
-	per_cpu(slab_reap_work, cpu).work.func = NULL;
+	per_cpu(slab_reap_work, cpu).dwork.work.func = NULL;
 	return 0;
 }
 
@@ -4027,11 +4035,15 @@ static void cache_reap(struct work_struct *w)
 	struct kmem_cache_node *n;
 	int node = numa_mem_id();
 	struct delayed_work *work = to_delayed_work(w);
+	struct slab_reap_work_struct *reap_work =
+		container_of(work, struct slab_reap_work_struct, dwork);
 
 	if (!mutex_trylock(&slab_mutex))
 		/* Give up. Setup the next iteration. */
 		goto out;
 
+	WARN_ON_ONCE(reap_work->cpu != smp_processor_id());
+
 	list_for_each_entry(searchp, &slab_caches, list) {
 		check_irq_on();
 
@@ -4074,7 +4086,8 @@ static void cache_reap(struct work_struct *w)
 	next_reap_node();
 out:
 	/* Set up the next iteration */
-	schedule_delayed_work(work, round_jiffies_relative(REAPTIMEOUT_AC));
+	schedule_delayed_work_on(reap_work->cpu, work,
+					round_jiffies_relative(REAPTIMEOUT_AC));
 }
 
 void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
-- 
2.16.3
