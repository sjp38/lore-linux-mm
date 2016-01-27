Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id DC0206B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 06:02:59 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id is5so4112953obc.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 03:02:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id di4si5128906oeb.17.2016.01.27.03.02.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 03:02:58 -0800 (PST)
Subject: Re: [LTP] [BUG] oom hangs the system, NMI backtrace shows most CPUs in shrink_slab
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <569D06F8.4040209@redhat.com>
	<569E1010.2070806@I-love.SAKURA.ne.jp>
	<56A24760.5020503@redhat.com>
	<56A724B1.3000407@redhat.com>
	<201601262346.BFB30785.VOQOFFHJLMtFSO@I-love.SAKURA.ne.jp>
In-Reply-To: <201601262346.BFB30785.VOQOFFHJLMtFSO@I-love.SAKURA.ne.jp>
Message-Id: <201601272002.FFF21524.OLFVQHFSOtJFOM@I-love.SAKURA.ne.jp>
Date: Wed, 27 Jan 2016 20:02:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: tj@kernel.org, clameter@sgi.com, js1304@gmail.com, arekm@maven.pl, akpm@linux-foundation.org, torvalds@linux-foundation.org, jstancek@redhat.com, linux-mm@kvack.org

Inviting people who involved in commit 373ccbe5927034b5 "mm, vmstat: allow
WQ concurrency to discover memory reclaim doesn't make any progress".

In this thread, Jan hit an OOM stall where free memory does not increase
even after OOM victim and dying tasks terminated. I'm wondering why such
thing can happen. Jan established a reproducer and I tried it.

I'm observing vmstat_update workqueue item forever remains pending.
Didn't we make sure that vmstat_update is processed when memory allocation
is stalling?
----------------------------------------
Tetsuo Handa wrote:
> Jan Stancek wrote:
> > On 01/22/2016 04:14 PM, Jan Stancek wrote:
> > > On 01/19/2016 11:29 AM, Tetsuo Handa wrote:
> > >> although I
> > >> couldn't find evidence that mlock() and madvice() are related with this hangup,
> > > 
> > > I simplified reproducer by having only single thread allocating
> > > memory when OOM triggers:
> > >   http://jan.stancek.eu/tmp/oom_hangs/console.log.3-v4.4-8606-with-memalloc.txt
> > > 
> > > In this instance it was mmap + mlock, as you can see from oom call trace.
> > > It made it to do_exit(), but couldn't complete it:
> > 
> > I have extracted test from LTP into standalone reproducer (attached),
> > if you want to give a try. It usually hangs my system within ~30
> > minutes. If it takes too long, you can try disabling swap. From my past
> > experience this usually helped to reproduce it faster on small KVM guests.
> > 
> > # gcc oom_mlock.c -pthread -O2
> > # echo 1 > /proc/sys/vm/overcommit_memory
> > (optionally) # swapoff -a
> > # ./a.out
> > 
> > Also, it's interesting to note, that when I disabled mlock() calls
> > test ran fine over night. I'll look into confirming this observation
> > on more systems.
> > 
> 
> Thank you for a reproducer. I tried it with
> 
> ----------
> --- oom_mlock.c
> +++ oom_mlock.c
> @@ -33,7 +33,7 @@
>  	if (s == MAP_FAILED)
>  		return errno;
>  
> -	if (do_mlock) {
> +	if (0 && do_mlock) {
>  		while (mlock(s, length) == -1 && loop > 0) {
>  			if (EAGAIN != errno)
>  				return errno;
> ----------
> 
> applied (i.e. disabled mlock() calls) on a VM with 4CPUs / 5120MB RAM, and
> successfully reproduced a livelock. Therefore, I think mlock() is irrelevant.
> 
> What I observed is that while disk_events_workfn workqueue item was looping,
> "Node 0 Normal free:" remained smaller than "min:" but "Node 0 Normal:" was
> larger than "Node 0 Normal free:".
> 
> Is this difference caused by pending vmstat_update, vmstat_shepherd, vmpressure_work_fn ?
> Can we somehow check how long these workqueue items remained pending?
> 
I added a counter to workqueue item (on top of yesterday's patch) for checking
how long workqueue items remained pending.

----------
diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index 0197358..fb1ebfc 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -101,6 +101,7 @@ struct work_struct {
 	atomic_long_t data;
 	struct list_head entry;
 	work_func_t func;
+	unsigned long inserted_time;
 #ifdef CONFIG_LOCKDEP
 	struct lockdep_map lockdep_map;
 #endif
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index c579dba..579ea82 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -617,6 +617,7 @@ static inline void set_work_data(struct work_struct *work, unsigned long data,
 static void set_work_pwq(struct work_struct *work, struct pool_workqueue *pwq,
 			 unsigned long extra_flags)
 {
+	work->inserted_time = jiffies;
 	set_work_data(work, (unsigned long)pwq,
 		      WORK_STRUCT_PENDING | WORK_STRUCT_PWQ | extra_flags);
 }
@@ -624,6 +625,7 @@ static void set_work_pwq(struct work_struct *work, struct pool_workqueue *pwq,
 static void set_work_pool_and_keep_pending(struct work_struct *work,
 					   int pool_id)
 {
+	work->inserted_time = jiffies;
 	set_work_data(work, (unsigned long)pool_id << WORK_OFFQ_POOL_SHIFT,
 		      WORK_STRUCT_PENDING);
 }
@@ -4173,7 +4175,7 @@ static void pr_cont_pool_info(struct worker_pool *pool)
 	pr_cont(" flags=0x%x nice=%d", pool->flags, pool->attrs->nice);
 }

-static void pr_cont_work(bool comma, struct work_struct *work)
+static void pr_cont_work(bool comma, struct work_struct *work, const unsigned long current_time)
 {
 	if (work->func == wq_barrier_func) {
 		struct wq_barrier *barr;
@@ -4185,9 +4187,10 @@ static void pr_cont_work(bool comma, struct work_struct *work)
 	} else {
 		pr_cont("%s %pf", comma ? "," : "", work->func);
 	}
+	pr_cont("(delay=%lu)", current_time - work->inserted_time);
 }

-static void show_pwq(struct pool_workqueue *pwq)
+static void show_pwq(struct pool_workqueue *pwq, const unsigned long current_time)
 {
 	struct worker_pool *pool = pwq->pool;
 	struct work_struct *work;
@@ -4215,12 +4218,13 @@ static void show_pwq(struct pool_workqueue *pwq)
 			if (worker->current_pwq != pwq)
 				continue;

-			pr_cont("%s %d%s:%pf", comma ? "," : "",
+			work = READ_ONCE(worker->current_work);
+			pr_cont("%s %d%s:%pf(delay=%lu)", comma ? "," : "",
 				task_pid_nr(worker->task),
 				worker == pwq->wq->rescuer ? "(RESCUER)" : "",
-				worker->current_func);
+				worker->current_func, work ? current_time - work->inserted_time : 0);
 			list_for_each_entry(work, &worker->scheduled, entry)
-				pr_cont_work(false, work);
+				pr_cont_work(false, work, current_time);
 			comma = true;
 		}
 		pr_cont("\n");
@@ -4240,7 +4244,7 @@ static void show_pwq(struct pool_workqueue *pwq)
 			if (get_work_pwq(work) != pwq)
 				continue;

-			pr_cont_work(comma, work);
+			pr_cont_work(comma, work, current_time);
 			comma = !(*work_data_bits(work) & WORK_STRUCT_LINKED);
 		}
 		pr_cont("\n");
@@ -4251,7 +4255,7 @@ static void show_pwq(struct pool_workqueue *pwq)

 		pr_info("    delayed:");
 		list_for_each_entry(work, &pwq->delayed_works, entry) {
-			pr_cont_work(comma, work);
+			pr_cont_work(comma, work, current_time);
 			comma = !(*work_data_bits(work) & WORK_STRUCT_LINKED);
 		}
 		pr_cont("\n");
@@ -4270,6 +4274,7 @@ void show_workqueue_state(void)
 	struct worker_pool *pool;
 	unsigned long flags;
 	int pi;
+	const unsigned long current_time = jiffies;

 	rcu_read_lock_sched();

@@ -4293,7 +4298,7 @@ void show_workqueue_state(void)
 		for_each_pwq(pwq, wq) {
 			spin_lock_irqsave(&pwq->pool->lock, flags);
 			if (pwq->nr_active || !list_empty(&pwq->delayed_works))
-				show_pwq(pwq);
+				show_pwq(pwq, current_time);
 			spin_unlock_irqrestore(&pwq->pool->lock, flags);
 		}
 	}
----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160127.txt.xz .
Today's log used /proc/sys/vm/overcommit_memory == 0. (Yesterday's log used 1.)
----------
[  103.148077] Out of memory: Kill process 9609 (a.out) score 925 or sacrifice child
[  103.149866] Killed process 9609 (a.out) total-vm:6314312kB, anon-rss:4578056kB, file-rss:0kB
[  113.848798] MemAlloc-Info: 8 stalling task, 0 dying task, 0 victim task.
[  113.850536] MemAlloc: kworker/3:1(86) seq=5 gfp=0x2400000 order=0 delay=9793
(...snipped...)
[  114.997391] Mem-Info:
[  114.998421] active_anon:1164299 inactive_anon:2092 isolated_anon:0
[  114.998421]  active_file:9 inactive_file:14 isolated_file:0
[  114.998421]  unevictable:0 dirty:0 writeback:0 unstable:0
[  114.998421]  slab_reclaimable:2909 slab_unreclaimable:5767
[  114.998421]  mapped:751 shmem:2160 pagetables:3631 bounce:0
[  114.998421]  free:8045 free_pcp:0 free_cma:0
[  115.007451] Node 0 DMA free:15888kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  115.016836] lowmem_reserve[]: 0 2708 4673 4673
[  115.018444] Node 0 DMA32 free:12724kB min:5008kB low:6260kB high:7512kB active_anon:2709028kB inactive_anon:4596kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3129216kB managed:2776588kB mlocked:0kB dirty:0kB writeback:0kB mapped:1692kB shmem:4716kB slab_reclaimable:6812kB slab_unreclaimable:10880kB kernel_stack:2032kB pagetables:7412kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  115.029268] lowmem_reserve[]: 0 0 1965 1965
[  115.030880] Node 0 Normal free:3568kB min:3632kB low:4540kB high:5448kB active_anon:1948168kB inactive_anon:3772kB active_file:36kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1312kB shmem:3924kB slab_reclaimable:4824kB slab_unreclaimable:12172kB kernel_stack:1872kB pagetables:7112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  115.042223] lowmem_reserve[]: 0 0 0 0
[  115.044295] Node 0 DMA: 0*4kB 0*8kB 1*16kB (U) 2*32kB (U) 3*64kB (U) 0*128kB 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15888kB
[  115.048168] Node 0 DMA32: 33*4kB (UM) 345*8kB (UE) 192*16kB (UME) 95*32kB (UME) 20*64kB (UE) 10*128kB (UME) 3*256kB (UM) 1*512kB (M) 0*1024kB 0*2048kB 0*4096kB = 12844kB
[  115.053309] Node 0 Normal: 44*4kB (UME) 35*8kB (UME) 20*16kB (UME) 42*32kB (UME) 7*64kB (E) 4*128kB (M) 2*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3592kB
[  115.058500] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  115.061009] 2199 total pagecache pages
[  115.062616] 0 pages in swap cache
[  115.064130] Swap cache stats: add 0, delete 0, find 0/0
[  115.065964] Free swap  = 0kB
[  115.067414] Total swap = 0kB
[  115.068840] 1310589 pages RAM
[  115.070273] 0 pages HighMem/MovableOnly
[  115.071847] 109257 pages reserved
[  115.073345] 0 pages hwpoisoned
[  115.074806] Showing busy workqueues and worker pools:
[  115.076607] workqueue events: flags=0x0
[  115.078220]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=2/256
[  115.080314]     pending: vmpressure_work_fn(delay=11001), vmw_fb_dirty_flush [vmwgfx](delay=1192)
[  115.083003] workqueue events_power_efficient: flags=0x80
[  115.084874]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  115.086986]     pending: neigh_periodic_work(delay=7661)
[  115.089044]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  115.091204]     pending: fb_flashcursor(delay=25)
[  115.093136] workqueue events_freezable_power_: flags=0x84
[  115.095052]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=3/256
[  115.097177]     in-flight: 86:disk_events_workfn(delay=11024)
[  115.099765]     pending: disk_events_workfn(delay=9707), disk_events_workfn(delay=9707)
[  115.102397] workqueue vmstat: flags=0xc
[  115.104004]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  115.106111]     pending: vmstat_update(delay=10241)
[  115.108064] pool 6: cpus=3 node=0 flags=0x0 nice=0 workers=3 idle: 88 26
(...snipped...)
[  125.111557] MemAlloc-Info: 11 stalling task, 0 dying task, 0 victim task.
(...snipped...)
[  126.919780] Node 0 Normal free:3580kB min:3632kB low:4540kB high:5448kB active_anon:1948168kB inactive_anon:3772kB active_file:36kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1312kB shmem:3924kB slab_reclaimable:4824kB slab_unreclaimable:12172kB kernel_stack:1872kB pagetables:7112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
(...snipped...)
[  126.941519] Node 0 Normal: 47*4kB (UME) 34*8kB (ME) 20*16kB (UME) 41*32kB (ME) 7*64kB (E) 4*128kB (M) 2*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3564kB
(...snipped...)
[  139.276624] Node 0 Normal free:3580kB min:3632kB low:4540kB high:5448kB active_anon:1948168kB inactive_anon:3772kB active_file:36kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1312kB shmem:3924kB slab_reclaimable:4824kB slab_unreclaimable:12172kB kernel_stack:1872kB pagetables:7112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
(...snipped...)
[  139.298331] Node 0 Normal: 47*4kB (UME) 34*8kB (ME) 20*16kB (UME) 41*32kB (ME) 7*64kB (E) 4*128kB (M) 2*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3564kB
(...snipped...)
[  151.557912] Node 0 Normal free:3580kB min:3632kB low:4540kB high:5448kB active_anon:1948168kB inactive_anon:3772kB active_file:36kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1312kB shmem:3924kB slab_reclaimable:4824kB slab_unreclaimable:12172kB kernel_stack:1872kB pagetables:7112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
(...snipped...)
[  151.579565] Node 0 Normal: 47*4kB (UME) 34*8kB (ME) 20*16kB (UME) 41*32kB (ME) 7*64kB (E) 4*128kB (M) 2*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3564kB
(...snipped...)
[  164.184580] Node 0 Normal free:3580kB min:3632kB low:4540kB high:5448kB active_anon:1948168kB inactive_anon:3772kB active_file:36kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1312kB shmem:3924kB slab_reclaimable:4824kB slab_unreclaimable:12172kB kernel_stack:1872kB pagetables:7112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
(...snipped...)
[  164.206423] Node 0 Normal: 47*4kB (UME) 34*8kB (ME) 20*16kB (UME) 41*32kB (ME) 7*64kB (E) 4*128kB (M) 2*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3564kB
(...snipped...)
[  177.314557] Node 0 Normal free:3580kB min:3632kB low:4540kB high:5448kB active_anon:1948168kB inactive_anon:3772kB active_file:36kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1312kB shmem:3924kB slab_reclaimable:4824kB slab_unreclaimable:12172kB kernel_stack:1872kB pagetables:7112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
(...snipped...)
[  177.337059] Node 0 Normal: 47*4kB (UME) 34*8kB (ME) 20*16kB (UME) 41*32kB (ME) 7*64kB (E) 4*128kB (M) 2*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3564kB
(...snipped...)
[  190.804567] Node 0 Normal free:3580kB min:3632kB low:4540kB high:5448kB active_anon:1948168kB inactive_anon:3772kB active_file:36kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1312kB shmem:3924kB slab_reclaimable:4824kB slab_unreclaimable:12172kB kernel_stack:1872kB pagetables:7112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
(...snipped...)
[  190.826437] Node 0 Normal: 47*4kB (UME) 34*8kB (ME) 20*16kB (UME) 41*32kB (ME) 7*64kB (E) 4*128kB (M) 2*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3564kB
(...snipped...)
[  204.260591] Node 0 Normal free:3580kB min:3632kB low:4540kB high:5448kB active_anon:1948168kB inactive_anon:3772kB active_file:36kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1312kB shmem:3924kB slab_reclaimable:4824kB slab_unreclaimable:12172kB kernel_stack:1872kB pagetables:7112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
(...snipped...)
[  204.282413] Node 0 Normal: 47*4kB (UME) 34*8kB (ME) 20*16kB (UME) 41*32kB (ME) 7*64kB (E) 4*128kB (M) 2*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3564kB
(...snipped...)
[  218.454026] Node 0 Normal free:3580kB min:3632kB low:4540kB high:5448kB active_anon:1948168kB inactive_anon:3772kB active_file:36kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1312kB shmem:3924kB slab_reclaimable:4824kB slab_unreclaimable:12172kB kernel_stack:1872kB pagetables:7112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
(...snipped...)
[  218.475787] Node 0 Normal: 47*4kB (UME) 34*8kB (ME) 20*16kB (UME) 41*32kB (ME) 7*64kB (E) 4*128kB (M) 2*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3564kB
(...snipped...)
[  232.040600] Node 0 Normal free:3580kB min:3632kB low:4540kB high:5448kB active_anon:1948168kB inactive_anon:3772kB active_file:36kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1312kB shmem:3924kB slab_reclaimable:4824kB slab_unreclaimable:12172kB kernel_stack:1872kB pagetables:7112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
(...snipped...)
[  232.062342] Node 0 Normal: 47*4kB (UME) 34*8kB (ME) 20*16kB (UME) 41*32kB (ME) 7*64kB (E) 4*128kB (M) 2*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3564kB
(...snipped...)
[  242.126476] MemAlloc-Info: 18 stalling task, 0 dying task, 0 victim task.
(...snipped...)
[  245.612136] Mem-Info:
[  245.613096] active_anon:1164299 inactive_anon:2092 isolated_anon:0
[  245.613096]  active_file:9 inactive_file:14 isolated_file:0
[  245.613096]  unevictable:0 dirty:0 writeback:0 unstable:0
[  245.613096]  slab_reclaimable:2909 slab_unreclaimable:5767
[  245.613096]  mapped:751 shmem:2160 pagetables:3631 bounce:0
[  245.613096]  free:8050 free_pcp:0 free_cma:0
[  245.621912] Node 0 DMA free:15888kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  245.630960] lowmem_reserve[]: 0 2708 4673 4673
[  245.632517] Node 0 DMA32 free:12732kB min:5008kB low:6260kB high:7512kB active_anon:2709028kB inactive_anon:4596kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3129216kB managed:2776588kB mlocked:0kB dirty:0kB writeback:0kB mapped:1692kB shmem:4716kB slab_reclaimable:6812kB slab_unreclaimable:10880kB kernel_stack:2032kB pagetables:7412kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  245.643221] lowmem_reserve[]: 0 0 1965 1965
[  245.644889] Node 0 Normal free:3580kB min:3632kB low:4540kB high:5448kB active_anon:1948168kB inactive_anon:3772kB active_file:36kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2097152kB managed:2012836kB mlocked:0kB dirty:0kB writeback:0kB mapped:1312kB shmem:3924kB slab_reclaimable:4824kB slab_unreclaimable:12172kB kernel_stack:1872kB pagetables:7112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  245.656041] lowmem_reserve[]: 0 0 0 0
[  245.657666] Node 0 DMA: 0*4kB 0*8kB 1*16kB (U) 2*32kB (U) 3*64kB (U) 0*128kB 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15888kB
[  245.661481] Node 0 DMA32: 36*4kB (UM) 345*8kB (UE) 192*16kB (UME) 95*32kB (UME) 20*64kB (UE) 10*128kB (UME) 3*256kB (UM) 1*512kB (M) 0*1024kB 0*2048kB 0*4096kB = 12856kB
[  245.666575] Node 0 Normal: 47*4kB (UME) 34*8kB (ME) 20*16kB (UME) 41*32kB (ME) 7*64kB (E) 4*128kB (M) 2*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3564kB
[  245.671649] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  245.674101] 2199 total pagecache pages
[  245.675677] 0 pages in swap cache
[  245.677165] Swap cache stats: add 0, delete 0, find 0/0
[  245.679033] Free swap  = 0kB
[  245.680442] Total swap = 0kB
[  245.681841] 1310589 pages RAM
[  245.683255] 0 pages HighMem/MovableOnly
[  245.684837] 109257 pages reserved
[  245.686305] 0 pages hwpoisoned
[  245.687730] Showing busy workqueues and worker pools:
[  245.689549] workqueue events: flags=0x0
[  245.691125]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=3/256
[  245.693188]     pending: vmpressure_work_fn(delay=141614), vmw_fb_dirty_flush [vmwgfx](delay=131805), push_to_pool(delay=53092)
[  245.696407] workqueue events_power_efficient: flags=0x80
[  245.698280]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  245.700401]     pending: neigh_periodic_work(delay=138274)
[  245.702475]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  245.704586]     pending: fb_flashcursor(delay=13)
[  245.706490] workqueue events_freezable_power_: flags=0x84
[  245.708440]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=3/256
[  245.710607]     in-flight: 86:disk_events_workfn(delay=141637)
[  245.712649]     pending: disk_events_workfn(delay=140320), disk_events_workfn(delay=140320)
[  245.715265] workqueue vmstat: flags=0xc
[  245.716898]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  245.719036]     pending: vmstat_update(delay=140854)
[  245.721018] pool 6: cpus=3 node=0 flags=0x0 nice=0 workers=3 idle: 88 26
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
