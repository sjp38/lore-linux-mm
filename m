Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF1096B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 07:14:58 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id x96so16986913ioi.2
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 04:14:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b189si2479964iob.196.2017.08.29.04.14.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 04:14:55 -0700 (PDT)
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170828121055.GI17097@dhcp22.suse.cz>
	<20170828170611.GV491396@devbig577.frc2.facebook.com>
	<201708290715.FEI21383.HSFOQtJOMVOFFL@I-love.SAKURA.ne.jp>
	<20170828230256.GF491396@devbig577.frc2.facebook.com>
	<20170828230924.GG491396@devbig577.frc2.facebook.com>
In-Reply-To: <20170828230924.GG491396@devbig577.frc2.facebook.com>
Message-Id: <201708292014.JHH35412.FMVFHOQOJtSLOF@I-love.SAKURA.ne.jp>
Date: Tue, 29 Aug 2017 20:14:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Tejun Heo wrote:
> Can you please try this patch and see how the work item behaves w/
> WQ_HIGHPRI set?  It disables concurrency mgmt for highpri work items
> which makes sense anyway.

I tried with below diff, but it did not help.

----------
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
index 5a2277f..173bd00 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -1296,6 +1296,7 @@ static void insert_work(struct pool_workqueue *pwq, struct work_struct *work,
 	struct worker_pool *pool = pwq->pool;
 
 	/* we own @work, set data and link */
+	work->stamp = jiffies;
 	set_work_pwq(work, pwq, extra_flags);
 	list_add_tail(&work->entry, head);
 	get_pwq(pwq);
@@ -2021,7 +2022,7 @@ static void process_one_work(struct worker *worker, struct work_struct *work)
 {
 	struct pool_workqueue *pwq = get_work_pwq(work);
 	struct worker_pool *pool = worker->pool;
-	bool cpu_intensive = pwq->wq->flags & WQ_CPU_INTENSIVE;
+	bool cpu_intensive = pwq->wq->flags & (WQ_CPU_INTENSIVE | WQ_HIGHPRI);
 	int work_color;
 	struct worker *collision;
 #ifdef CONFIG_LOCKDEP
@@ -4372,10 +4373,10 @@ static void pr_cont_work(bool comma, struct work_struct *work)
 
 		barr = container_of(work, struct wq_barrier, work);
 
-		pr_cont("%s BAR(%d)", comma ? "," : "",
-			task_pid_nr(barr->task));
+		pr_cont("%s BAR(%d){%lu}", comma ? "," : "",
+			task_pid_nr(barr->task), jiffies - work->stamp);
 	} else {
-		pr_cont("%s %pf", comma ? "," : "", work->func);
+		pr_cont("%s %pf{%lu}", comma ? "," : "", work->func, jiffies - work->stamp);
 	}
 }
 
@@ -4407,10 +4408,11 @@ static void show_pwq(struct pool_workqueue *pwq)
 			if (worker->current_pwq != pwq)
 				continue;
 
-			pr_cont("%s %d%s:%pf", comma ? "," : "",
+			pr_cont("%s %d%s:%pf{%lu}", comma ? "," : "",
 				task_pid_nr(worker->task),
 				worker == pwq->wq->rescuer ? "(RESCUER)" : "",
-				worker->current_func);
+				worker->current_func, worker->current_work ?
+				jiffies - worker->current_work->stamp : 0);
 			list_for_each_entry(work, &worker->scheduled, entry)
 				pr_cont_work(false, work);
 			comma = true;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4bb13e7..cb7e198 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1923,7 +1923,8 @@ void __init init_mm_internals(void)
 {
 	int ret __maybe_unused;
 
-	mm_percpu_wq = alloc_workqueue("mm_percpu_wq", WQ_MEM_RECLAIM, 0);
+	mm_percpu_wq = alloc_workqueue("mm_percpu_wq",
+				       WQ_MEM_RECLAIM | WQ_HIGHPRI, 0);
 
 #ifdef CONFIG_SMP
 	ret = cpuhp_setup_state_nocalls(CPUHP_MM_VMSTAT_DEAD, "mm/vmstat:dead",
----------

Unless above diff for printing delay is wrong, work items on
WQ_MEM_RECLAIM | WQ_HIGHPRI workqueues are delayed by other work items.

----------
[  654.670289] Showing busy workqueues and worker pools:
[  654.670320] workqueue events: flags=0x0
[  654.670664]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  654.670776]     pending: vmpressure_work_fn{5}
[  654.670870] workqueue events_power_efficient: flags=0x80
[  654.670992]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  654.671003]     pending: fb_flashcursor{160}
[  654.671032] workqueue events_freezable_power_: flags=0x84
[  654.671152]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[  654.671162]     in-flight: 2100:disk_events_workfn{64432}
[  654.671259] workqueue writeback: flags=0x4e
[  654.671370]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  654.671453]     in-flight: 380:wb_workfn{1}
[  654.671461]     pending: wb_workfn{1}
[  654.672793] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=2 manager: 444 idle: 2126
[  654.672815] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 41 257
[  654.673048] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=4 idle: 3305 378 379

[  838.554020] Showing busy workqueues and worker pools:
[  838.554127] workqueue events_power_efficient: flags=0x80
[  838.554282]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  838.554295]     in-flight: 2126:fb_flashcursor{52}
[  838.554304]     pending: fb_flashcursor{52}
[  838.554335] workqueue events_freezable_power_: flags=0x84
[  838.554467]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[  838.554479]     in-flight: 2100:disk_events_workfn{248316}
[  838.554595] workqueue writeback: flags=0x4e
[  838.554599]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  838.554610]     in-flight: 380:wb_workfn{0} wb_workfn{0}
[  838.555989] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=2 manager: 444
[  838.556012] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 41 257
[  838.556252] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=4 idle: 3305 378 379

[  897.501844] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 40s!
[  897.501935] Showing busy workqueues and worker pools:
[  897.501961] workqueue events: flags=0x0
[  897.502274]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  897.502367]     pending: vmw_fb_dirty_flush{58910}
[  897.502379]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  897.502390]     in-flight: 97:console_callback{58946} console_callback{58946}
[  897.502404]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[  897.502414]     pending: vmpressure_work_fn{40434}, e1000_watchdog [e1000]{40192}, vmstat_shepherd{39743}
[  897.502496] workqueue events_long: flags=0x0
[  897.502643]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  897.502654]     pending: gc_worker [nf_conntrack]{40352}
[  897.502712] workqueue events_power_efficient: flags=0x80
[  897.502855]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  897.502864]     in-flight: 2126:fb_flashcursor{59001}
[  897.502872]     pending: fb_flashcursor{59001}
[  897.502882]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  897.502892]     pending: neigh_periodic_work{30209}, neigh_periodic_work{30209}
[  897.502926] workqueue events_freezable_power_: flags=0x84
[  897.503062]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[  897.503072]     in-flight: 2100:disk_events_workfn{307265}
[  897.503107] workqueue mm_percpu_wq: flags=0x18
[  897.503291]   pwq 5: cpus=2 node=0 flags=0x0 nice=-20 active=1/256
[  897.503301]     pending: vmstat_update{58752}
[  897.503374] workqueue writeback: flags=0x4e
[  897.503464]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  897.503516]     in-flight: 380:wb_workfn{0}
[  897.503524]     pending: wb_workfn{0}
[  897.504901] workqueue xfs-eofblocks/sda1: flags=0xc
[  897.505045]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  897.505057]     in-flight: 57:xfs_eofblocks_worker [xfs]{40451}
[  897.505127] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=40s workers=2 manager: 135
[  897.505160] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3311 2132
[  897.505179] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=59s workers=2 manager: 444
[  897.505200] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=43s workers=3 idle: 41 257
[  897.505478] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378

[  927.288644] Showing busy workqueues and worker pools:
[  927.288669] workqueue events: flags=0x0
[  927.288814]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  927.288827]     pending: vmw_fb_dirty_flush{88697}
[  927.288836]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  927.288847]     in-flight: 97:console_callback{88733} console_callback{88733}
[  927.288861]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[  927.288872]     pending: vmpressure_work_fn{70221}, e1000_watchdog [e1000]{69979}, vmstat_shepherd{69530}
[  927.288936] workqueue events_long: flags=0x0
[  927.289082]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  927.289093]     pending: gc_worker [nf_conntrack]{70139}
[  927.289152] workqueue events_power_efficient: flags=0x80
[  927.289284]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  927.289295]     in-flight: 2126:fb_flashcursor{88787}
[  927.289303]     pending: fb_flashcursor{88787}
[  927.289312]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  927.289323]     pending: neigh_periodic_work{59995}, neigh_periodic_work{59995}
[  927.289356] workqueue events_freezable_power_: flags=0x84
[  927.289483]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[  927.289493]     in-flight: 2100:disk_events_workfn{337051}
[  927.289529] workqueue mm_percpu_wq: flags=0x18
[  927.289681]   pwq 5: cpus=2 node=0 flags=0x0 nice=-20 active=1/256
[  927.289693]     pending: vmstat_update{88538}
[  927.289766] workqueue writeback: flags=0x4e
[  927.289770]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  927.289780]     in-flight: 380:wb_workfn{1}
[  927.289788]     pending: wb_workfn{1}
[  927.291244] workqueue xfs-eofblocks/sda1: flags=0xc
[  927.291383]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  927.291395]     in-flight: 57:xfs_eofblocks_worker [xfs]{70237}
[  927.291449] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=70s workers=2 manager: 135
[  927.291466] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3311 2132
[  927.291486] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=88s workers=2 manager: 444
[  927.291507] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=73s workers=3 idle: 41 257
[  927.291776] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378

[  957.917850] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 100s!
[  957.917935] Showing busy workqueues and worker pools:
[  957.917959] workqueue events: flags=0x0
[  957.918109]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  957.918121]     pending: vmw_fb_dirty_flush{119326}
[  957.918131]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  957.918142]     in-flight: 97:console_callback{119362} console_callback{119362}
[  957.918156]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[  957.918167]     pending: vmpressure_work_fn{100850}, e1000_watchdog [e1000]{100608}, vmstat_shepherd{100159}
[  957.918233] workqueue events_long: flags=0x0
[  957.918374]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  957.918384]     pending: gc_worker [nf_conntrack]{100768}
[  957.918442] workqueue events_power_efficient: flags=0x80
[  957.918599]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  957.918609]     in-flight: 2126:fb_flashcursor{119416}
[  957.918618]     pending: fb_flashcursor{119416}
[  957.918627]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  957.918637]     pending: neigh_periodic_work{90624}, neigh_periodic_work{90624}
[  957.918669] workqueue events_freezable_power_: flags=0x84
[  957.918809]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[  957.918819]     in-flight: 2100:disk_events_workfn{367681}
[  957.918855] workqueue mm_percpu_wq: flags=0x18
[  957.919003]   pwq 5: cpus=2 node=0 flags=0x0 nice=-20 active=1/256
[  957.919014]     pending: vmstat_update{119168}
[  957.919090] workqueue writeback: flags=0x4e
[  957.919093]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  957.919104]     in-flight: 380:wb_workfn{0} wb_workfn{0}
[  957.920562] workqueue xfs-eofblocks/sda1: flags=0xc
[  957.920705]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  957.920716]     in-flight: 57:xfs_eofblocks_worker [xfs]{100866}
[  957.920772] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=100s workers=2 manager: 135
[  957.920789] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3311 2132
[  957.920807] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=119s workers=2 manager: 444
[  957.920826] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=103s workers=3 idle: 41 257
[  957.921096] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378

[  988.125885] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 131s!
[  988.125973] Showing busy workqueues and worker pools:
[  988.125998] workqueue events: flags=0x0
[  988.126155]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  988.126168]     pending: vmw_fb_dirty_flush{149534}
[  988.126179]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  988.126190]     in-flight: 97:console_callback{149570} console_callback{149570}
[  988.126204]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[  988.126215]     pending: vmpressure_work_fn{131058}, e1000_watchdog [e1000]{130816}, vmstat_shepherd{130367}
[  988.126283] workqueue events_long: flags=0x0
[  988.126430]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  988.126441]     pending: gc_worker [nf_conntrack]{130976}
[  988.126521] workqueue events_power_efficient: flags=0x80
[  988.126667]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  988.126678]     in-flight: 2126:fb_flashcursor{149625}
[  988.126686]     pending: fb_flashcursor{149625}
[  988.126695]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  988.126706]     pending: neigh_periodic_work{120833}, neigh_periodic_work{120833}
[  988.126738] workqueue events_freezable_power_: flags=0x84
[  988.126881]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[  988.126891]     in-flight: 2100:disk_events_workfn{397889}
[  988.126929] workqueue mm_percpu_wq: flags=0x18
[  988.127086]   pwq 5: cpus=2 node=0 flags=0x0 nice=-20 active=1/256
[  988.127096]     pending: vmstat_update{149376}
[  988.127211] workqueue writeback: flags=0x4e
[  988.127215]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=1/256
[  988.127226]     in-flight: 380:wb_workfn{0}
[  988.128675] workqueue xfs-eofblocks/sda1: flags=0xc
[  988.128825]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  988.128838]     in-flight: 57:xfs_eofblocks_worker [xfs]{131075}
[  988.128897] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=131s workers=2 manager: 135
[  988.128915] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3311 2132
[  988.128935] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=149s workers=2 manager: 444
[  988.128956] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=134s workers=3 idle: 41 257
[  988.129278] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378

[ 1018.333984] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 161s!
[ 1018.339385] Showing busy workqueues and worker pools:
[ 1018.343135] workqueue events: flags=0x0
[ 1018.346272]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[ 1018.350632]     pending: vmpressure_work_fn{161283}, e1000_watchdog [e1000]{161041}, vmstat_shepherd{160592}
[ 1018.356151] workqueue events_long: flags=0x0
[ 1018.359581]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1018.363519]     pending: gc_worker [nf_conntrack]{161213}
[ 1018.367290] workqueue events_power_efficient: flags=0x80
[ 1018.371142]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[ 1018.375057]     pending: neigh_periodic_work{151081}, neigh_periodic_work{151081}
[ 1018.379686] workqueue events_freezable_power_: flags=0x84
[ 1018.383621]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[ 1018.387684]     in-flight: 2100:disk_events_workfn{428150}
[ 1018.391519] workqueue writeback: flags=0x4e
[ 1018.394708]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[ 1018.398537]     in-flight: 380:wb_workfn{0}
[ 1018.401495]     pending: wb_workfn{0}
[ 1018.405654] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1018.409202]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1018.413075]     in-flight: 57:xfs_eofblocks_worker [xfs]{161359}
[ 1018.417061] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=161s workers=2 manager: 135
[ 1018.421598] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=2 manager: 444 idle: 2126
[ 1018.426532] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=164s workers=3 idle: 41 257
[ 1018.431490] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378

[ 1042.653684] Showing busy workqueues and worker pools:
[ 1042.653710] workqueue events: flags=0x0
[ 1042.653857]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
[ 1042.653869]     pending: vmpressure_work_fn{185586}, e1000_watchdog [e1000]{185344}, vmstat_shepherd{184895}, vmw_fb_dirty_flush{24218}
[ 1042.653935] workqueue events_long: flags=0x0
[ 1042.654060]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1042.654070]     pending: gc_worker [nf_conntrack]{185504}
[ 1042.654126] workqueue events_power_efficient: flags=0x80
[ 1042.654264]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[ 1042.654275]     in-flight: 2126:fb_flashcursor{176}
[ 1042.654283]     pending: fb_flashcursor{176}
[ 1042.654292]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[ 1042.654303]     pending: neigh_periodic_work{175360}, neigh_periodic_work{175360}
[ 1042.654334] workqueue events_freezable_power_: flags=0x84
[ 1042.654455]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[ 1042.654466]     in-flight: 2100:disk_events_workfn{452416}
[ 1042.654563] workqueue writeback: flags=0x4e
[ 1042.654574]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[ 1042.654585]     in-flight: 380:wb_workfn{0}
[ 1042.654592]     pending: wb_workfn{0}
[ 1042.655922] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1042.656048]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1042.656058]     in-flight: 57:xfs_eofblocks_worker [xfs]{185602}
[ 1042.656109] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=185s workers=2 manager: 135
[ 1042.656126] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=2 manager: 444
[ 1042.656146] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=188s workers=3 idle: 41 257
[ 1042.656402] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378

[ 1108.958848] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 251s!
[ 1108.958946] Showing busy workqueues and worker pools:
[ 1108.958971] workqueue events: flags=0x0
[ 1108.959121]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[ 1108.959133]     in-flight: 97:console_callback{66303} console_callback{66303}
[ 1108.959149]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
[ 1108.959159]     pending: vmpressure_work_fn{251891}, e1000_watchdog [e1000]{251649}, vmstat_shepherd{251200}, vmw_fb_dirty_flush{90523}
[ 1108.959227] workqueue events_long: flags=0x0
[ 1108.959372]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1108.959382]     pending: gc_worker [nf_conntrack]{251809}
[ 1108.959440] workqueue events_power_efficient: flags=0x80
[ 1108.959616]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[ 1108.959627]     in-flight: 2126:fb_flashcursor{66482}
[ 1108.959636]     pending: fb_flashcursor{66482}
[ 1108.959645]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[ 1108.959655]     pending: neigh_periodic_work{241666}, neigh_periodic_work{241666}
[ 1108.959687] workqueue events_freezable_power_: flags=0x84
[ 1108.959825]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[ 1108.959835]     in-flight: 2100:disk_events_workfn{518722}
[ 1108.959871] workqueue mm_percpu_wq: flags=0x18
[ 1108.960020]   pwq 5: cpus=2 node=0 flags=0x0 nice=-20 active=1/256
[ 1108.960030]     pending: vmstat_update{66241}
[ 1108.960104] workqueue writeback: flags=0x4e
[ 1108.960107]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[ 1108.960117]     in-flight: 380:wb_workfn{0} wb_workfn{0}
[ 1108.961605] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1108.961749]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1108.961761]     in-flight: 57:xfs_eofblocks_worker [xfs]{251908}
[ 1108.961818] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=251s workers=2 manager: 135
[ 1108.961834] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3311 2132
[ 1108.961853] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=66s workers=2 manager: 444
[ 1108.961874] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=254s workers=3 idle: 41 257
[ 1108.962150] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378

[ 1230.033873] Showing busy workqueues and worker pools:
[ 1230.033899] workqueue events: flags=0x0
[ 1230.034066]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
[ 1230.034079]     pending: vmpressure_work_fn{372966}, e1000_watchdog [e1000]{372724}, vmstat_shepherd{372275}, vmw_fb_dirty_flush{211598}
[ 1230.034148] workqueue events_long: flags=0x0
[ 1230.034276]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1230.034286]     pending: gc_worker [nf_conntrack]{372884}
[ 1230.034342] workqueue events_power_efficient: flags=0x80
[ 1230.034466]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[ 1230.034477]     in-flight: 2126:fb_flashcursor{164}
[ 1230.034485]     pending: fb_flashcursor{164}
[ 1230.034494]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[ 1230.034505]     pending: neigh_periodic_work{362740}, neigh_periodic_work{362740}
[ 1230.034536] workqueue events_freezable_power_: flags=0x84
[ 1230.034658]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[ 1230.034670]     in-flight: 2100:disk_events_workfn{639796}
[ 1230.034723] workqueue mm_percpu_wq: flags=0x18
[ 1230.034857]   pwq 5: cpus=2 node=0 flags=0x0 nice=-20 active=1/256
[ 1230.034867]     pending: vmstat_update{308}
[ 1230.034941] workqueue writeback: flags=0x4e
[ 1230.034945]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[ 1230.034955]     in-flight: 380:wb_workfn{0}
[ 1230.034963]     pending: wb_workfn{0}
[ 1230.036617] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1230.036765]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1230.036777]     in-flight: 57:xfs_eofblocks_worker [xfs]{372980}
[ 1230.036832] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=372s workers=2 manager: 135
[ 1230.036850] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=2 manager: 444
[ 1230.036870] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=376s workers=3 idle: 41 257
[ 1230.037119] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378

[ 1290.209431] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 433s!
[ 1290.209513] Showing busy workqueues and worker pools:
[ 1290.209536] workqueue events: flags=0x0
[ 1290.209680]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[ 1290.209692]     in-flight: 97:console_callback{60175} console_callback{60175}
[ 1290.209708]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
[ 1290.209718]     pending: vmpressure_work_fn{433141}, e1000_watchdog [e1000]{432899}, vmstat_shepherd{432450}, vmw_fb_dirty_flush{271773}
[ 1290.209795] workqueue events_long: flags=0x0
[ 1290.209934]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1290.209943]     pending: gc_worker [nf_conntrack]{433059}
[ 1290.210001] workqueue events_power_efficient: flags=0x80
[ 1290.210171]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[ 1290.210182]     in-flight: 2126:fb_flashcursor{60339}
[ 1290.210191]     pending: fb_flashcursor{60339}
[ 1290.210201]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[ 1290.210212]     pending: neigh_periodic_work{422915}, neigh_periodic_work{422915}
[ 1290.210244] workqueue events_freezable_power_: flags=0x84
[ 1290.210379]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[ 1290.210390]     in-flight: 2100:disk_events_workfn{699971}
[ 1290.210426] workqueue mm_percpu_wq: flags=0x18
[ 1290.210574]   pwq 5: cpus=2 node=0 flags=0x0 nice=-20 active=1/256
[ 1290.210584]     pending: vmstat_update{60483}
[ 1290.210777] workqueue writeback: flags=0x4e
[ 1290.210781]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[ 1290.210792]     in-flight: 380:wb_workfn{0}
[ 1290.210800]     pending: wb_workfn{0}
[ 1290.212242] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1290.212388]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1290.212399]     in-flight: 57:xfs_eofblocks_worker [xfs]{433155}
[ 1290.212458] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=433s workers=2 manager: 135
[ 1290.212476] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3311 2132
[ 1290.212495] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=60s workers=2 manager: 444
[ 1290.212515] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=436s workers=3 idle: 41 257
[ 1290.212826] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378

[ 1320.414593] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 463s!
[ 1320.418262] Showing busy workqueues and worker pools:
[ 1320.420892] workqueue events: flags=0x0
[ 1320.423288]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
[ 1320.426296]     pending: vmpressure_work_fn{463359}, e1000_watchdog [e1000]{463117}, vmstat_shepherd{462668}, vmw_fb_dirty_flush{301991}
[ 1320.431527] workqueue events_long: flags=0x0
[ 1320.434086]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1320.437020]     pending: gc_worker [nf_conntrack]{463287}
[ 1320.439890] workqueue events_power_efficient: flags=0x80
[ 1320.442695]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[ 1320.445606]     pending: neigh_periodic_work{453152}, neigh_periodic_work{453152}
[ 1320.448995] workqueue events_freezable_power_: flags=0x84
[ 1320.451872]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[ 1320.454848]     in-flight: 2100:disk_events_workfn{730217}
[ 1320.457663] workqueue writeback: flags=0x4e
[ 1320.459955]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[ 1320.462704]     in-flight: 380:wb_workfn{3}
[ 1320.464878]     pending: wb_workfn{5}
[ 1320.467959] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1320.470801]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1320.474955]     in-flight: 57:xfs_eofblocks_worker [xfs]{463421}
[ 1320.479104] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=463s workers=2 manager: 135
[ 1320.483981] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=2 manager: 444 idle: 2126
[ 1320.489033] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=466s workers=3 idle: 41 257
[ 1320.494234] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378

[ 1411.610809] Showing busy workqueues and worker pools:
[ 1411.610835] workqueue events: flags=0x0
[ 1411.610983]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
[ 1411.610995]     pending: vmpressure_work_fn{554543}, e1000_watchdog [e1000]{554301}, vmstat_shepherd{553852}, vmw_fb_dirty_flush{393175}
[ 1411.611082] workqueue events_long: flags=0x0
[ 1411.611209]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1411.611221]     pending: gc_worker [nf_conntrack]{554462}
[ 1411.611283] workqueue events_power_efficient: flags=0x80
[ 1411.611409]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[ 1411.611420]     in-flight: 2126:fb_flashcursor{43}
[ 1411.611428]     pending: fb_flashcursor{43}
[ 1411.611437]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[ 1411.611447]     pending: neigh_periodic_work{544318}, neigh_periodic_work{544318}
[ 1411.611479] workqueue events_freezable_power_: flags=0x84
[ 1411.611599]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[ 1411.611609]     in-flight: 2100:disk_events_workfn{821374}
[ 1411.611727] workqueue writeback: flags=0x4e
[ 1411.611739]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[ 1411.611749]     in-flight: 380:wb_workfn{0}
[ 1411.611756]     pending: wb_workfn{0}
[ 1411.613564] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1411.613697]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1411.613708]     in-flight: 57:xfs_eofblocks_worker [xfs]{554560}
[ 1411.613779] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=554s workers=2 manager: 135
[ 1411.613798] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=2 manager: 444
[ 1411.613817] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=557s workers=3 idle: 41 257
[ 1411.614071] pool 256: cpus=0-127 flags=0x4 nice=0 hung=0s workers=3 idle: 3305 378
----------

Memory stressor I used is shown below.

----------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	static char buffer[4096] = { };
	char *buf = NULL;
	unsigned long size;
	unsigned long i;
	for (i = 0; i < 1024; i++) {
		if (fork() == 0) {
			int fd = open("/proc/self/oom_score_adj", O_WRONLY);
			write(fd, "1000", 4);
			close(fd);
			snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
			fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
			sleep(1);
			while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
			_exit(0);
		}
	}
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sleep(2);
	/* Will cause OOM due to overcommit */
	for (i = 0; i < size; i += 4096)
		buf[i] = 0;
	return 0;
}
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
