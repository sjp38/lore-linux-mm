Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1A36B0038
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 03:05:34 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so69713713pad.3
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 00:05:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b16si19905054pbu.61.2015.09.19.00.05.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Sep 2015 00:05:33 -0700 (PDT)
Subject: [PATCH] mm, oom: Disable preemption during OOM-kill operation.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201509191605.CAF13520.QVSFHLtFJOMOOF@I-love.SAKURA.ne.jp>
Date: Sat, 19 Sep 2015 16:05:12 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Well, this seems to be a problem which prevents me from testing various
patches that tries to address OOM livelock problem.

---------- rcu-stall.c start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>

static int dummy(void *fd)
{
	char c;
	/* Wait until the first child thread is killed by the OOM killer. */
	read(* (int *) fd, &c, 1);
	/* Try to consume as much CPU time as possible via preemption. */
	while (1);
	return 0;
}

int main(int argc, char *argv[])
{
	cpu_set_t cpu = { { 1 } };
	static int pipe_fd[2] = { EOF, EOF };
	char *buf = NULL;
	unsigned long size = 0;
	unsigned int i;
	const int fd = open("/dev/zero", O_RDONLY);
	pipe(pipe_fd);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sched_setaffinity(0, sizeof(cpu), &cpu);
	/*
	 * Create many child threads which will disturb operations with
	 * oom_lock and RCU held.
	 */
	for (i = 0; i < 1000; i++) {
		clone(dummy, malloc(1024) + 1024, CLONE_SIGHAND | CLONE_VM,
		      &pipe_fd[0]);
		if (!i)
			close(pipe_fd[1]);
	}
	read(fd, buf, size); /* Will cause OOM due to overcommit */
	return * (char *) NULL; /* Kill all threads. */
}
---------- rcu-stall.c end ----------

---------- console log start ----------
[   53.020558] rcu-stall invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
[   53.022200] rcu-stall cpuset=/ mems_allowed=0
[   53.023172] CPU: 0 PID: 3780 Comm: rcu-stall Not tainted 4.3.0-rc1-next-20150918 #125
(...snipped...)
[   53.119884] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
(...snipped...)
[   53.198811] [ 3780]  1000  3780   541715   392717     777       6        0             0 rcu-stall
(...snipped...)
[   55.087789] [ 4780]  1000  4780   541715   392717     777       6        0             0 rcu-stall
[   55.089637] Out of memory: Kill process 3780 (rcu-stall) score 879 or sacrifice child
[   55.091437] Killed process 3780 (rcu-stall) total-vm:2166860kB, anon-rss:1570864kB, file-rss:4kB
[   55.093269] Kill process 3781 (rcu-stall) sharing same memory
[   55.094553] Kill process 3782 (rcu-stall) sharing same memory
[   65.541045] Kill process 3783 (rcu-stall) sharing same memory
[   65.542382] Kill process 3784 (rcu-stall) sharing same memory
[   65.543689] Kill process 3785 (rcu-stall) sharing same memory
[   69.519022] Kill process 3786 (rcu-stall) sharing same memory
[   69.520425] Kill process 3787 (rcu-stall) sharing same memory
[   69.521893] Kill process 3788 (rcu-stall) sharing same memory
[   73.735956] Kill process 3789 (rcu-stall) sharing same memory
[   73.737336] Kill process 3790 (rcu-stall) sharing same memory
[   73.738672] Kill process 3791 (rcu-stall) sharing same memory
[   77.781839] Kill process 3792 (rcu-stall) sharing same memory
[   77.783183] Kill process 3793 (rcu-stall) sharing same memory
[   77.784506] Kill process 3794 (rcu-stall) sharing same memory
[   81.725121] Kill process 3795 (rcu-stall) sharing same memory
[   81.726454] Kill process 3796 (rcu-stall) sharing same memory
[   81.727665] Kill process 3797 (rcu-stall) sharing same memory
(...snipped...)
[  113.019058] Kill process 3821 (rcu-stall) sharing same memory
[  115.094645] INFO: rcu_preempt detected stalls on CPUs/tasks:
[  115.095971] 	Tasks blocked on level-0 rcu_node (CPUs 0-7): P3780
[  115.097405] 	(detected by 0, t=60002 jiffies, g=3458, c=3457, q=0)
[  115.098780] rcu-stall       R  running task        0  3780   3757 0x00100082
(...snipped...)
[ 1194.420740] Kill process 4647 (rcu-stall) sharing same memory
[ 1194.421992] Kill process 4648 (rcu-stall) sharing same memory
[ 1194.423196] Kill process 4649 (rcu-stall) sharing same memory
[ 1195.124700] INFO: rcu_preempt detected stalls on CPUs/tasks:
[ 1195.125970] 	Tasks blocked on level-0 rcu_node (CPUs 0-7): P3780
[ 1195.127286] 	(detected by 0, t=1140032 jiffies, g=3458, c=3457, q=0)
[ 1195.128663] rcu-stall       R  running task        0  3780   3757 0x00100082
(...snipped...)
[ 1366.561198] Kill process 4780 (rcu-stall) sharing same memory
---------- console log end ----------
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20150919.txt.xz .
Kernel config is at http://I-love.SAKURA.ne.jp/tmp/config-4.3-rc1 .

After applying this patch, I can no longer reproduce this problem.
Please check whether I disabled preemption appropriately.
----------------------------------------
>From 9e832b0b9123c38e5f34240d43e41bdefed66a4a Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 19 Sep 2015 16:02:26 +0900
Subject: [PATCH] mm, oom: Disable preemption during OOM-kill operation.

Under CONFIG_PREEMPT=y kernels, I can observe that a local unprivileged
user can make out_of_memory() stall for longer than 20 minutes due to
preemption, by invoking OOM killer with 1000 processes.

Operations with oom_lock held should complete as soon as possible
because we might be preserving OOM condition for most of that period
if we are in OOM condition.

Since we don't use operations which might sleep regarding global OOM, this
patch disables preemption from check_panic_on_oom() till oom_kill_process()
altogether. On the other hand, since we use operations which might sleep
regarding memcg OOM, this patch disables preemption separately.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/memcontrol.c | 7 +++++++
 mm/oom_kill.c   | 6 ++++++
 2 files changed, 13 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5d9a6e8..7ee629e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1326,13 +1326,16 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		goto unlock;
 	}
 
+	preempt_disable();
 	check_panic_on_oom(&oc, CONSTRAINT_MEMCG, memcg);
+	preempt_enable();
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
 		struct task_struct *task;
 
 		css_task_iter_start(&iter->css, &it);
+		preempt_disable();
 		while ((task = css_task_iter_next(&it))) {
 			switch (oom_scan_process_thread(&oc, task, totalpages)) {
 			case OOM_SCAN_SELECT:
@@ -1349,6 +1352,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				mem_cgroup_iter_break(memcg, iter);
 				if (chosen)
 					put_task_struct(chosen);
+				preempt_enable();
 				goto unlock;
 			case OOM_SCAN_OK:
 				break;
@@ -1367,13 +1371,16 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			chosen_points = points;
 			get_task_struct(chosen);
 		}
+		preempt_enable();
 		css_task_iter_end(&it);
 	}
 
 	if (chosen) {
 		points = chosen_points * 1000 / totalpages;
+		preempt_disable();
 		oom_kill_process(&oc, chosen, points, totalpages, memcg,
 				 "Memory cgroup out of memory");
+		preempt_enable();
 	}
 unlock:
 	mutex_unlock(&oom_lock);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1ecc0bc..9e2ca62 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -668,6 +668,8 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
+	/* Disable preemption in order to send SIGKILL as soon as possible. */
+	preempt_disable();
 	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
@@ -683,6 +685,7 @@ bool out_of_memory(struct oom_control *oc)
 		get_task_struct(current);
 		oom_kill_process(oc, current, 0, totalpages, NULL,
 				 "Out of memory (oom_kill_allocating_task)");
+		preempt_enable();
 		return true;
 	}
 
@@ -695,12 +698,15 @@ bool out_of_memory(struct oom_control *oc)
 	if (p && p != (void *)-1UL) {
 		oom_kill_process(oc, p, points, totalpages, NULL,
 				 "Out of memory");
+		preempt_enable();
 		/*
 		 * Give the killed process a good chance to exit before trying
 		 * to allocate memory again.
 		 */
 		schedule_timeout_killable(1);
+		return true;
 	}
+	preempt_enable();
 	return true;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
