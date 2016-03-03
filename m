Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 36A8C6B0257
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:42:10 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id m184so23022687iof.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:42:10 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 101si49267812iot.166.2016.03.03.02.42.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 02:42:09 -0800 (PST)
Subject: [PATCH] mm,oom: Do not sleep with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201603031941.CBC81272.OtLMSFVOFJHOFQ@I-love.SAKURA.ne.jp>
Date: Thu, 3 Mar 2016 19:42:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Michal, before we think about whether to add preempt_disable()/preempt_enable_no_resched()
to oom_kill_process(), will you accept this patch?
This is one of problems which annoy kmallocwd patch on CONFIG_PREEMPT_NONE=y kernels.

---------- sleep-with-oom_lock.c start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <signal.h>
#include <sys/prctl.h>

int main(int argc, char *argv[])
{
	struct sched_param sp = { 0 };
	cpu_set_t cpu = { { 1 } };
	static int pipe_fd[2] = { EOF, EOF };
	char *buf = NULL;
	unsigned long size = 0;
	unsigned int i;
	int fd;
	pipe(pipe_fd);
	signal(SIGCLD, SIG_IGN);
	if (fork() == 0) {
		prctl(PR_SET_NAME, (unsigned long) "first-victim", 0, 0, 0);
		while (1)
			pause();
	}
	close(pipe_fd[1]);
	sched_setaffinity(0, sizeof(cpu), &cpu);
	prctl(PR_SET_NAME, (unsigned long) "normal-priority", 0, 0, 0);
	for (i = 0; i < 64; i++)
		if (fork() == 0) {
			char c;
			/* Wait until the first-victim is OOM-killed. */
			read(pipe_fd[0], &c, 1);
			/* Try to consume as much CPU time as possible. */
			while(1);
			_exit(0);
		}
	close(pipe_fd[0]);
	fd = open("/dev/zero", O_RDONLY);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sched_setscheduler(0, SCHED_IDLE, &sp);
	prctl(PR_SET_NAME, (unsigned long) "idle-priority", 0, 0, 0);
	read(fd, buf, size); /* Will cause OOM due to overcommit */
	kill(-1, SIGKILL);
	return 0; /* Not reached. */
}
---------- sleep-with-oom_lock.c end ----------

---------- console log start ----------
[  915.132305] CPU: 0 PID: 1341 Comm: idle-priority Not tainted 4.5.0-rc6-next-20160301 #89
[  915.137977] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  915.144914]  0000000000000286 0000000000291f95 ffff88003b06f860 ffffffff8131424d
[  915.150071]  0000000000000000 ffff88003b06fa98 ffff88003b06f900 ffffffff811b9934
[  915.155231]  0000000000000206 ffffffff8182b7b0 ffff88003b06f8a0 ffffffff810bae39
[  915.160540] Call Trace:
[  915.162963]  [<ffffffff8131424d>] dump_stack+0x85/0xc8
[  915.166689]  [<ffffffff811b9934>] dump_header+0x5b/0x394
[  915.170509]  [<ffffffff810bae39>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  915.175324]  [<ffffffff810baf0d>] ? trace_hardirqs_on+0xd/0x10
[  915.179497]  [<ffffffff81142286>] oom_kill_process+0x376/0x570
[  915.183661]  [<ffffffff811426d6>] out_of_memory+0x206/0x5a0
[  915.187651]  [<ffffffff81142794>] ? out_of_memory+0x2c4/0x5a0
[  915.191706]  [<ffffffff811485b2>] __alloc_pages_nodemask+0xbe2/0xd90
[  915.196124]  [<ffffffff811934d6>] alloc_pages_vma+0xb6/0x290
[  915.200128]  [<ffffffff81170af8>] handle_mm_fault+0x12d8/0x16f0
[  915.204299]  [<ffffffff8116f868>] ? handle_mm_fault+0x48/0x16f0
[  915.208467]  [<ffffffff8105c089>] ? __do_page_fault+0x129/0x4f0
[  915.212599]  [<ffffffff8105c127>] __do_page_fault+0x1c7/0x4f0
[  915.216653]  [<ffffffff8105c480>] do_page_fault+0x30/0x80
[  915.220447]  [<ffffffff81669668>] page_fault+0x28/0x30
[  915.224311]  [<ffffffff81321f0d>] ? __clear_user+0x3d/0x70
[  915.228155]  [<ffffffff81321eee>] ? __clear_user+0x1e/0x70
[  915.231988]  [<ffffffff81326a98>] iov_iter_zero+0x68/0x250
[  915.235771]  [<ffffffff81400ed8>] read_iter_zero+0x38/0xa0
[  915.239517]  [<ffffffff811bd934>] __vfs_read+0xc4/0xf0
[  915.243041]  [<ffffffff811be49a>] vfs_read+0x7a/0x120
[  915.246526]  [<ffffffff811bed43>] SyS_read+0x53/0xd0
[  915.249922]  [<ffffffff8100364d>] do_syscall_64+0x5d/0x180
[  915.253613]  [<ffffffff81667bff>] entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  915.410964] Out of memory: Kill process 1341 (idle-priority) score 846 or sacrifice child
[  915.416430] Killed process 1347 (normal-priority) total-vm:4172kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[ 1066.855742] idle-priority   R  running task        0  1341   1316 0x00000080
[ 1066.861076]  ffff88003b06f898 ffff88003eb74080 ffff880039f3a000 ffff88003b070000
[ 1066.866715]  ffff88003b06f8d0 ffff88003c610240 000000010009635f ffffffff81c0dbd8
[ 1066.872338]  ffff88003b06f8b0 ffffffff81662ce0 ffff88003c610240 ffff88003b06f958
[ 1066.877976] Call Trace:
[ 1066.880120]  [<ffffffff81662ce0>] schedule+0x30/0x80
[ 1066.883963]  [<ffffffff81666d17>] schedule_timeout+0x117/0x1c0
[ 1066.888391]  [<ffffffff810dda00>] ? init_timer_key+0x40/0x40
[ 1066.892675]  [<ffffffff81666df9>] schedule_timeout_killable+0x19/0x20
[ 1066.897518]  [<ffffffff811426e0>] out_of_memory+0x210/0x5a0
[ 1066.901779]  [<ffffffff81142794>] ? out_of_memory+0x2c4/0x5a0
[ 1066.906153]  [<ffffffff811485b2>] __alloc_pages_nodemask+0xbe2/0xd90
[ 1066.910965]  [<ffffffff811934d6>] alloc_pages_vma+0xb6/0x290
[ 1066.915371]  [<ffffffff81170af8>] handle_mm_fault+0x12d8/0x16f0
[ 1066.919868]  [<ffffffff8116f868>] ? handle_mm_fault+0x48/0x16f0
[ 1066.924457]  [<ffffffff8105c089>] ? __do_page_fault+0x129/0x4f0
[ 1066.929197]  [<ffffffff8105c127>] __do_page_fault+0x1c7/0x4f0
[ 1066.933805]  [<ffffffff8105c480>] do_page_fault+0x30/0x80
[ 1066.938236]  [<ffffffff81669668>] page_fault+0x28/0x30
[ 1066.942352]  [<ffffffff81321f0d>] ? __clear_user+0x3d/0x70
[ 1066.946536]  [<ffffffff81321eee>] ? __clear_user+0x1e/0x70
[ 1066.950707]  [<ffffffff81326a98>] iov_iter_zero+0x68/0x250
[ 1066.954920]  [<ffffffff81400ed8>] read_iter_zero+0x38/0xa0
[ 1066.959044]  [<ffffffff811bd934>] __vfs_read+0xc4/0xf0
[ 1066.962965]  [<ffffffff811be49a>] vfs_read+0x7a/0x120
[ 1066.966825]  [<ffffffff811bed43>] SyS_read+0x53/0xd0
[ 1066.970615]  [<ffffffff8100364d>] do_syscall_64+0x5d/0x180
[ 1066.974741]  [<ffffffff81667bff>] entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[ 1312.850193] sysrq: SysRq : Manual OOM execution
[ 1440.303946] INFO: task kworker/3:1:46 blocked for more than 120 seconds.
[ 1440.309844]       Not tainted 4.5.0-rc6-next-20160301 #89
[ 1440.314332] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1440.320536] kworker/3:1     D ffff880039217ca8     0    46      2 0x00000000
[ 1440.326079] Workqueue: events moom_callback
[ 1440.329612]  ffff880039217ca8 ffff88003be120c0 ffff880039212000 ffff880039218000
[ 1440.335436]  ffffffff81c7a568 0000000000000246 ffff880039212000 00000000ffffffff
[ 1440.341197]  ffff880039217cc0 ffffffff81662ce0 ffffffff81c7a560 ffff880039217cd0
[ 1440.347021] Call Trace:
[ 1440.349347]  [<ffffffff81662ce0>] schedule+0x30/0x80
[ 1440.353419]  [<ffffffff81662fe9>] schedule_preempt_disabled+0x9/0x10
[ 1440.358324]  [<ffffffff81664b9f>] mutex_lock_nested+0x14f/0x3a0
[ 1440.362667]  [<ffffffff813e3f6e>] ? moom_callback+0x6e/0xb0
[ 1440.367123]  [<ffffffff813e3f6e>] moom_callback+0x6e/0xb0
[ 1440.371381]  [<ffffffff8108a955>] process_one_work+0x1a5/0x400
[ 1440.375863]  [<ffffffff8108a8f1>] ? process_one_work+0x141/0x400
[ 1440.380475]  [<ffffffff8108acd6>] worker_thread+0x126/0x490
[ 1440.384827]  [<ffffffff816625a4>] ? __schedule+0x314/0xa20
[ 1440.389139]  [<ffffffff8108abb0>] ? process_one_work+0x400/0x400
[ 1440.393820]  [<ffffffff81090c9e>] kthread+0xee/0x110
[ 1440.397749]  [<ffffffff81667d72>] ret_from_fork+0x22/0x50
[ 1440.401950]  [<ffffffff81090bb0>] ? kthread_create_on_node+0x230/0x230
[ 1440.406862] 3 locks held by kworker/3:1/46:
[ 1440.410200]  #0:  ("events"){.+.+.+}, at: [<ffffffff8108a8f1>] process_one_work+0x141/0x400
[ 1440.417208]  #1:  (moom_work){+.+...}, at: [<ffffffff8108a8f1>] process_one_work+0x141/0x400
[ 1440.423539]  #2:  (oom_lock){+.+...}, at: [<ffffffff813e3f6e>] moom_callback+0x6e/0xb0
(...snipped...)
[ 1525.328487] idle-priority   R  running task        0  1341   1316 0x00000080
[ 1525.333576]  ffff88003b06f898 ffff88003eb74080 ffff880039f3a000 ffff88003b070000
[ 1525.339361]  ffff88003b06f8d0 ffff88003c610240 000000010009635f ffffffff81c0dbd8
[ 1525.344851]  ffff88003b06f8b0 ffffffff81662ce0 ffff88003c610240 ffff88003b06f958
[ 1525.350410] Call Trace:
[ 1525.352698]  [<ffffffff81662ce0>] schedule+0x30/0x80
[ 1525.356262]  [<ffffffff81666d17>] schedule_timeout+0x117/0x1c0
[ 1525.360557]  [<ffffffff810dda00>] ? init_timer_key+0x40/0x40
[ 1525.365088]  [<ffffffff81666df9>] schedule_timeout_killable+0x19/0x20
[ 1525.370150]  [<ffffffff811426e0>] out_of_memory+0x210/0x5a0
[ 1525.374496]  [<ffffffff81142794>] ? out_of_memory+0x2c4/0x5a0
[ 1525.378937]  [<ffffffff811485b2>] __alloc_pages_nodemask+0xbe2/0xd90
[ 1525.383811]  [<ffffffff811934d6>] alloc_pages_vma+0xb6/0x290
[ 1525.388206]  [<ffffffff81170af8>] handle_mm_fault+0x12d8/0x16f0
[ 1525.392782]  [<ffffffff8116f868>] ? handle_mm_fault+0x48/0x16f0
[ 1525.397338]  [<ffffffff8105c089>] ? __do_page_fault+0x129/0x4f0
[ 1525.401933]  [<ffffffff8105c127>] __do_page_fault+0x1c7/0x4f0
[ 1525.406370]  [<ffffffff8105c480>] do_page_fault+0x30/0x80
[ 1525.410542]  [<ffffffff81669668>] page_fault+0x28/0x30
[ 1525.414698]  [<ffffffff81321f0d>] ? __clear_user+0x3d/0x70
[ 1525.418921]  [<ffffffff81321eee>] ? __clear_user+0x1e/0x70
[ 1525.423132]  [<ffffffff81326a98>] iov_iter_zero+0x68/0x250
[ 1525.427384]  [<ffffffff81400ed8>] read_iter_zero+0x38/0xa0
[ 1525.431592]  [<ffffffff811bd934>] __vfs_read+0xc4/0xf0
[ 1525.435548]  [<ffffffff811be49a>] vfs_read+0x7a/0x120
[ 1525.439440]  [<ffffffff811bed43>] SyS_read+0x53/0xd0
[ 1525.443259]  [<ffffffff8100364d>] do_syscall_64+0x5d/0x180
[ 1525.447420]  [<ffffffff81667bff>] entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[ 1560.429708] INFO: task kworker/3:1:46 blocked for more than 120 seconds.
[ 1560.435640]       Not tainted 4.5.0-rc6-next-20160301 #89
[ 1560.440208] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1560.446115] kworker/3:1     D ffff880039217ca8     0    46      2 0x00000000
[ 1560.451572] Workqueue: events moom_callback
[ 1560.455045]  ffff880039217ca8 ffff88003be120c0 ffff880039212000 ffff880039218000
[ 1560.460769]  ffffffff81c7a568 0000000000000246 ffff880039212000 00000000ffffffff
[ 1560.466530]  ffff880039217cc0 ffffffff81662ce0 ffffffff81c7a560 ffff880039217cd0
[ 1560.472363] Call Trace:
[ 1560.474603]  [<ffffffff81662ce0>] schedule+0x30/0x80
[ 1560.478892]  [<ffffffff81662fe9>] schedule_preempt_disabled+0x9/0x10
[ 1560.483713]  [<ffffffff81664b9f>] mutex_lock_nested+0x14f/0x3a0
[ 1560.488398]  [<ffffffff813e3f6e>] ? moom_callback+0x6e/0xb0
[ 1560.492703]  [<ffffffff813e3f6e>] moom_callback+0x6e/0xb0
[ 1560.496938]  [<ffffffff8108a955>] process_one_work+0x1a5/0x400
[ 1560.501391]  [<ffffffff8108a8f1>] ? process_one_work+0x141/0x400
[ 1560.505944]  [<ffffffff8108acd6>] worker_thread+0x126/0x490
[ 1560.510173]  [<ffffffff816625a4>] ? __schedule+0x314/0xa20
[ 1560.514330]  [<ffffffff8108abb0>] ? process_one_work+0x400/0x400
[ 1560.518899]  [<ffffffff81090c9e>] kthread+0xee/0x110
[ 1560.522760]  [<ffffffff81667d72>] ret_from_fork+0x22/0x50
[ 1560.526923]  [<ffffffff81090bb0>] ? kthread_create_on_node+0x230/0x230
[ 1560.531792] 3 locks held by kworker/3:1/46:
[ 1560.535086]  #0:  ("events"){.+.+.+}, at: [<ffffffff8108a8f1>] process_one_work+0x141/0x400
[ 1560.541351]  #1:  (moom_work){+.+...}, at: [<ffffffff8108a8f1>] process_one_work+0x141/0x400
[ 1560.547626]  #2:  (oom_lock){+.+...}, at: [<ffffffff813e3f6e>] moom_callback+0x6e/0xb0
[ 1582.487749] sysrq: SysRq : Kill All Tasks
[ 1582.530799] kworker/3:1 invoked oom-killer: gfp_mask=0x24000c0(GFP_KERNEL), order=-1, oom_score_adj=0
[ 1582.538355] kworker/3:1 cpuset=/ mems_allowed=0
[ 1582.570304] CPU: 3 PID: 46 Comm: kworker/3:1 Not tainted 4.5.0-rc6-next-20160301 #89
---------- console log end ----------
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160303.txt.xz .

------------------------------------------------------------
>From 92d4ec39ed23c6d0d5785f4f53311d55dfe480de Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 3 Mar 2016 13:27:06 +0900
Subject: [PATCH] mm,oom: Do not sleep with oom_lock held.

out_of_memory() can stall effectively forever if a SCHED_IDLE thread
called out_of_memory() when there are !SCHED_IDLE threads running on
the same CPU, for schedule_timeout_killable(1) cannot return shortly
due to scheduling priority.

Operations with oom_lock held should complete as soon as possible
because we might be preserving OOM condition for most of that period
if we are in OOM condition. SysRq-f can't work if oom_lock is held.

It would be possible to boost scheduling priority of current thread
while holding oom_lock, but priority of current thread might be
manipulated by other threads after boosting. Unless we offload
operations with oom_lock held to a dedicated kernel thread with high
priority, addressing this problem using priority manipulation is racy.

This patch brings schedule_timeout_killable(1) out of oom_lock.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c   |  8 +-------
 mm/page_alloc.c | 34 +++++++++++++++++++++++-----------
 2 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5d5eca9..dbef3a7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -901,15 +901,9 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (p && p != (void *)-1UL) {
+	if (p && p != (void *)-1UL)
 		oom_kill_process(oc, p, points, totalpages, NULL,
 				 "Out of memory");
-		/*
-		 * Give the killed process a good chance to exit before trying
-		 * to allocate memory again.
-		 */
-		schedule_timeout_killable(1);
-	}
 	return true;
 }

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1993894..cfe0997 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2871,20 +2871,32 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
+	if (out_of_memory(&oc)) {
+		mutex_unlock(&oom_lock);
+		*did_some_progress = 1;
+		/*
+		 * Give the killed process a good chance to exit before trying
+		 * to allocate memory again. We should sleep after releasing
+		 * oom_lock because current thread might be SCHED_IDLE priority
+		 * which can sleep for minutes when preempted by other threads
+		 * with !SCHED_IDLE priority running on the same CPU.
+		 */
+		schedule_timeout_killable(1);
+		return NULL;
+	}
+	if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;

-		if (gfp_mask & __GFP_NOFAIL) {
+		page = get_page_from_freelist(gfp_mask, order,
+					      ALLOC_NO_WATERMARKS|ALLOC_CPUSET,
+					      ac);
+		/*
+		 * fallback to ignore cpuset restriction if our nodes
+		 * are depleted
+		 */
+		if (!page)
 			page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
-			/*
-			 * fallback to ignore cpuset restriction if our nodes
-			 * are depleted
-			 */
-			if (!page)
-				page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS, ac);
-		}
+						      ALLOC_NO_WATERMARKS, ac);
 	}
 out:
 	mutex_unlock(&oom_lock);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
