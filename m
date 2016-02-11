Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id D45576B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 02:06:51 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id f81so45782527iof.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 23:06:51 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n9si35838679iga.37.2016.02.10.23.06.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Feb 2016 23:06:50 -0800 (PST)
Subject: Re: How to handle infinite too_many_isolated() loop (for OOM detection rework v4) ?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp>
In-Reply-To: <201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp>
Message-Id: <201602111606.IIG81724.QOLFJOSMtFHOFV@I-love.SAKURA.ne.jp>
Date: Thu, 11 Feb 2016 16:06:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

Tetsuo Handa wrote:
> The result is that, we have no TIF_MEMDIE tasks but nobody is calling
> out_of_memory(). That is, OOM livelock without invoking the OOM killer.
> They seem to be waiting at congestion_wait() from too_many_isolated()
> loop called from shrink_inactive_list() because nobody can make forward
> progress. I think we must not wait forever at too_many_isolated() loop.

I used delta patch shown below for confirming that they are actually
waiting at congestion_wait() from too_many_isolated() loop called from
shrink_inactive_list().

---------- delta patch (for linux-next-20160209 + kmallocwd) ----------
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0aeff29..e954ac3 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1400,6 +1400,7 @@ struct memalloc_info {
 	 * bit 0: Will be reported as OOM victim.
 	 * bit 1: Will be reported as dying task.
 	 * bit 2: Will be reported as stalling task.
+	 * bit 3: Will be reported as exiting task.
 	 */
 	u8 type;
 	/* Started time in jiffies as of valid == 1. */
diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index 745a78c..d804d7e 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -17,6 +17,7 @@
 #include <linux/sysctl.h>
 #include <linux/utsname.h>
 #include <linux/oom.h> /* out_of_memory_count */
+#include <linux/console.h> /* console_trylock()/console_unlock() */
 #include <trace/events/sched.h>
 
 /*
@@ -153,10 +154,24 @@ static bool is_stalling_task(const struct task_struct *task,
 	return time_after_eq(expire, memalloc.start);
 }
 
+static bool wait_console_flushed(unsigned int max_wait)
+{
+	while (1) {
+		if (console_trylock()) {
+			console_unlock();
+			return true;
+		}
+		if (max_wait--)
+			schedule_timeout_interruptible(1);
+		else
+			return false;
+	}
+}
+	
 /* Check for memory allocation stalls. */
 static void check_memalloc_stalling_tasks(unsigned long timeout)
 {
-	char buf[128];
+	char buf[256];
 	struct task_struct *g, *p;
 	unsigned long now;
 	unsigned long expire;
@@ -205,8 +220,9 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 	preempt_enable();
 	if (!stalling_tasks)
 		return;
+	wait_console_flushed(10);
 	/* Report stalling tasks, dying and victim tasks. */
-	pr_warn("MemAlloc-Info: %u stalling task, %u dying task, %u exiting task, %u victim task. oom_count=%u\n",
+	pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u, victim=%u oom_count=%u\n",
 		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending, out_of_memory_count);
 	cond_resched();
 	preempt_disable();
@@ -240,15 +256,14 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 		 * Victim tasks get pending SIGKILL removed before arriving at
 		 * do_exit(). Therefore, print " exiting" instead for " dying".
 		 */
-		pr_warn("MemAlloc: %s(%u)%s%s%s%s%s\n", p->comm, p->pid,
-			(type & 4) ? buf : "",
+		pr_warn("MemAlloc: %s(%u) flags=0x%x%s%s%s%s%s\n", p->comm,
+			p->pid, p->flags, (type & 4) ? buf : "",
 			(p->state & TASK_UNINTERRUPTIBLE) ?
 			" uninterruptible" : "",
 			(type & 8) ? " exiting" : "",
 			(type & 2) ? " dying" : "",
 			(type & 1) ? " victim" : "");
 		sched_show_task(p);
-		debug_show_held_locks(p);
 		/*
 		 * Since there could be thousands of tasks to report, we always
 		 * sleep and try to flush printk() buffer after each report, in
@@ -262,7 +277,8 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 		get_task_struct(p);
 		rcu_read_unlock();
 		preempt_enable();
-		schedule_timeout_interruptible(1);
+		cond_resched();
+		wait_console_flushed(1);
 		preempt_disable();
 		rcu_read_lock();
 		can_cont = pid_alive(g) && pid_alive(p);
@@ -278,6 +294,8 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 	show_mem(0);
 	/* Show workqueue state. */
 	show_workqueue_state();
+	/* Show lock information. (SysRq-d) */
+	debug_show_all_locks();
 }
 #endif /* CONFIG_DETECT_MEMALLOC_STALL_TASK */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 18b3767..0d94523 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1576,6 +1576,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	int file = is_file_lru(lru);
 	struct zone *zone = lruvec_zone(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	unsigned char counter = 0;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1583,6 +1584,18 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		/* We are about to die and free our memory. Return now. */
 		if (fatal_signal_pending(current))
 			return SWAP_CLUSTER_MAX;
+		if (!++counter) {
+			if (file)
+				printk(KERN_WARNING "zone=%s NR_INACTIVE_FILE=%lu NR_ISOLATED_FILE=%lu\n",
+				       zone->name,
+				       zone_page_state(zone, NR_INACTIVE_FILE),
+				       zone_page_state(zone, NR_ISOLATED_FILE));
+			else
+				printk(KERN_WARNING "zone=%s NR_INACTIVE_ANON=%lu NR_ISOLATED_ANON=%lu\n",
+				       zone->name,
+				       zone_page_state(zone, NR_INACTIVE_ANON),
+				       zone_page_state(zone, NR_ISOLATED_ANON));
+		}
 	}
 
 	lru_add_drain();
---------- delta patch (for linux-next-20160209 + kmallocwd) ----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160211.txt.xz .
---------- console log ----------
[  101.471027] MemAlloc-Info: stalling=46 dying=2 exiting=0, victim=0 oom_count=182
[  117.187128] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
[  121.199151] MemAlloc-Info: stalling=50 dying=2 exiting=0, victim=0 oom_count=182
[  123.777398] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
[  141.184386] MemAlloc-Info: stalling=50 dying=2 exiting=0, victim=0 oom_count=182
[  142.944292] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
[  161.188356] MemAlloc-Info: stalling=51 dying=2 exiting=0, victim=0 oom_count=182
[  163.541083] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
[  181.211690] MemAlloc-Info: stalling=51 dying=2 exiting=0, victim=0 oom_count=182
[  189.423559] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
[  201.404914] MemAlloc-Info: stalling=51 dying=2 exiting=0, victim=0 oom_count=182
[  204.456970] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
[  213.753982] MemAlloc-Info: stalling=53 dying=2 exiting=0, victim=0 oom_count=182
[  215.117586] zone=DMA NR_INACTIVE_FILE=4 NR_ISOLATED_FILE=19
---------- console log ----------

The zone which causes this silent hang up is not DMA32 but DMA. Nobody except
kswapd can escape this too_many_isolated() loop because isolated > inactive is
always true. Unless kswapd performs operations for making isolated > inactive
false, we will silently hang up. And I think kswapd did nothing for this zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
