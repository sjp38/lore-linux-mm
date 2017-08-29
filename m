Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E3E106B02B4
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 17:41:10 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p13so13958993qtp.5
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 14:41:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s25sor2339617qth.128.2017.08.29.14.41.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Aug 2017 14:41:09 -0700 (PDT)
Date: Tue, 29 Aug 2017 14:41:04 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170829214104.GW491396@devbig577.frc2.facebook.com>
References: <20170828121055.GI17097@dhcp22.suse.cz>
 <20170828170611.GV491396@devbig577.frc2.facebook.com>
 <201708290715.FEI21383.HSFOQtJOMVOFFL@I-love.SAKURA.ne.jp>
 <20170828230256.GF491396@devbig577.frc2.facebook.com>
 <20170828230924.GG491396@devbig577.frc2.facebook.com>
 <201708292014.JHH35412.FMVFHOQOJtSLOF@I-love.SAKURA.ne.jp>
 <20170829143817.GK491396@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170829143817.GK491396@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Hello,

I can't repro the problem.  The test program gets cleanly oom killed.
Hmm... the workqueue dumps you posted are really weird because there
are multiple work items stalling for really long times but only one
pool is reporting hang and nobody has rescuers active.  I don't get
how the system can be in such state.

Just in case, you're testing mainline, right?  I've updated your debug
patch slightly so that it doesn't skip seemingly idle pools.  Can you
please repro the problem with the patch applied?  Thanks.

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index db6dc9d..54027fc 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -101,6 +101,7 @@ struct work_struct {
 	atomic_long_t data;
 	struct list_head entry;
 	work_func_t func;
+	unsigned long stamp;
 #ifdef CONFIG_LOCKDEP
 	struct lockdep_map lockdep_map;
 #endif
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index ca937b0..006c19a 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -1296,6 +1296,7 @@ static void insert_work(struct pool_workqueue *pwq, struct work_struct *work,
 	struct worker_pool *pool = pwq->pool;
 
 	/* we own @work, set data and link */
+	work->stamp = jiffies;
 	set_work_pwq(work, pwq, extra_flags);
 	list_add_tail(&work->entry, head);
 	get_pwq(pwq);
@@ -2021,7 +2022,7 @@ __acquires(&pool->lock)
 {
 	struct pool_workqueue *pwq = get_work_pwq(work);
 	struct worker_pool *pool = worker->pool;
-	bool cpu_intensive = pwq->wq->flags & WQ_CPU_INTENSIVE;
+	bool cpu_intensive = pwq->wq->flags & (WQ_CPU_INTENSIVE | WQ_HIGHPRI);
 	int work_color;
 	struct worker *collision;
 #ifdef CONFIG_LOCKDEP
@@ -4338,10 +4339,10 @@ static void pr_cont_work(bool comma, struct work_struct *work)
 
 		barr = container_of(work, struct wq_barrier, work);
 
-		pr_cont("%s BAR(%d)", comma ? "," : "",
-			task_pid_nr(barr->task));
+		pr_cont("%s BAR(%d){%u}", comma ? "," : "",
+			task_pid_nr(barr->task), jiffies_to_msecs(jiffies - work->stamp));
 	} else {
-		pr_cont("%s %pf", comma ? "," : "", work->func);
+		pr_cont("%s %pf{%u}", comma ? "," : "", work->func, jiffies_to_msecs(jiffies - work->stamp));
 	}
 }
 
@@ -4373,10 +4374,11 @@ static void show_pwq(struct pool_workqueue *pwq)
 			if (worker->current_pwq != pwq)
 				continue;
 
-			pr_cont("%s %d%s:%pf", comma ? "," : "",
+			pr_cont("%s %d%s:%pf{%u}", comma ? "," : "",
 				task_pid_nr(worker->task),
 				worker == pwq->wq->rescuer ? "(RESCUER)" : "",
-				worker->current_func);
+				worker->current_func, worker->current_work ?
+				jiffies_to_msecs(jiffies - worker->current_work->stamp) : 0);
 			list_for_each_entry(work, &worker->scheduled, entry)
 				pr_cont_work(false, work);
 			comma = true;
@@ -4461,8 +4463,8 @@ void show_workqueue_state(void)
 		bool first = true;
 
 		spin_lock_irqsave(&pool->lock, flags);
-		if (pool->nr_workers == pool->nr_idle)
-			goto next_pool;
+		/*if (pool->nr_workers == pool->nr_idle)
+		  goto next_pool;*/
 
 		pr_info("pool %d:", pool->id);
 		pr_cont_pool_info(pool);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9a4441b..c099ebf 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1768,7 +1768,8 @@ void __init init_mm_internals(void)
 {
 	int ret __maybe_unused;
 
-	mm_percpu_wq = alloc_workqueue("mm_percpu_wq", WQ_MEM_RECLAIM, 0);
+	mm_percpu_wq = alloc_workqueue("mm_percpu_wq",
+				       WQ_MEM_RECLAIM | WQ_HIGHPRI, 0);
 
 #ifdef CONFIG_SMP
 	ret = cpuhp_setup_state_nocalls(CPUHP_MM_VMSTAT_DEAD, "mm/vmstat:dead",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
