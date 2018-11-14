Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6766F6B0277
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 04:46:36 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id m137-v6so20151465ita.9
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 01:46:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id e70-v6si15493076iof.46.2018.11.14.01.46.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 01:46:33 -0800 (PST)
Subject: Re: [RFC PATCH v2 0/3] oom: rework oom_reaper vs. exit_mmap handoff
References: <20181025082403.3806-1-mhocko@kernel.org>
 <20181108093224.GS27423@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <9dfd5c87-ae48-8ffb-fbc6-706d627658ff@i-love.sakura.ne.jp>
Date: Wed, 14 Nov 2018 18:46:13 +0900
MIME-Version: 1.0
In-Reply-To: <20181108093224.GS27423@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/11/08 18:32, Michal Hocko wrote:
> On Thu 25-10-18 10:24:00, Michal Hocko wrote:
>> The previous version of this RFC has been posted here [1]. I have fixed
>> few issues spotted during the review and by 0day bot. I have also reworked
>> patch 2 to be ratio rather than an absolute number based.
>>
>> With this series applied the locking protocol between the oom_reaper and
>> the exit path is as follows.
>>
>> All parts which cannot race should use the exclusive lock on the exit
>> path. Once the exit path has passed the moment when no blocking locks
>> are taken then it clears mm->mmap under the exclusive lock. oom_reaper
>> checks for this and sets MMF_OOM_SKIP only if the exit path is not guaranteed
>> to finish the job. This is patch 3 so see the changelog for all the details.
>>
>> I would really appreciate if David could give this a try and see how
>> this behaves in workloads where the oom_reaper falls flat now. I have
>> been playing with sparsely allocated memory with a high pte/real memory
>> ratio and large mlocked processes and it worked reasonably well.
> 
> Does this help workloads you were referring to earlier David?

I still refuse this patch, due to allowing OOM lockups in the exit path
triggered by CPU starvation.



First, try a stressor shown below

----------------------------------------
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <sched.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
	cpu_set_t cpu = { { 1 } };
	struct sched_param sp = { 99 };
	FILE *fp;
	int i;
	const unsigned long size = 1048576 * 200;
	char *buf = malloc(size);
	mkdir("/sys/fs/cgroup/memory/test1", 0755);
	fp = fopen("/sys/fs/cgroup/memory/test1/memory.limit_in_bytes", "w");
	fprintf(fp, "%lu\n", size / 2);
	fclose(fp);
	fp = fopen("/sys/fs/cgroup/memory/test1/tasks", "w");
	fprintf(fp, "%u\n", getpid());
	fclose(fp);
	fp = fopen("/proc/self/oom_score_adj", "w");
	fprintf(fp, "1000\n");
	fclose(fp);
	sched_setaffinity(0, sizeof(cpu), &cpu);
	sched_setscheduler(0, SCHED_FIFO, &sp);
	nice(-20);
	sp.sched_priority = 0;
	for (i = 0; i < 64; i++)
		if (fork() == 0) {
			if (i < 32) {
				sched_setscheduler(0, SCHED_IDLE, &sp);
				nice(19);
			}
			memset(buf, 0, size);
			_exit(0);
		}
	while (wait(NULL) > 0);
	return 0;
}
----------------------------------------

with a bit of additional printk() patch shown below.

----------------------------------------
 kernel/locking/lockdep.c | 6 ------
 mm/oom_kill.c            | 9 +++++++--
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 1efada2..822b412 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -564,12 +564,6 @@ static void lockdep_print_held_locks(struct task_struct *p)
 	else
 		printk("%d lock%s held by %s/%d:\n", depth,
 		       depth > 1 ? "s" : "", p->comm, task_pid_nr(p));
-	/*
-	 * It's not reliable to print a task's held locks if it's not sleeping
-	 * and it's not the current task.
-	 */
-	if (p->state == TASK_RUNNING && p != current)
-		return;
 	for (i = 0; i < depth; i++) {
 		printk(" #%d: ", i);
 		print_lock(p->held_locks + i);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 503d24d..b9e5a61 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -613,8 +613,11 @@ static void oom_reap_task(struct task_struct *tsk)
 	    test_bit(MMF_OOM_SKIP, &mm->flags))
 		goto done;
 
-	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
+	pr_info("oom_reaper: unable to reap pid:%d (%s), anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+		task_pid_nr(tsk), tsk->comm,
+		K(get_mm_counter(mm, MM_ANONPAGES)),
+		K(get_mm_counter(mm, MM_FILEPAGES)),
+		K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	debug_show_all_locks();
 
 done:
@@ -628,6 +631,8 @@ static void oom_reap_task(struct task_struct *tsk)
 	 */
 	if (mm->mmap)
 		set_bit(MMF_OOM_SKIP, &mm->flags);
+	else if (!test_bit(MMF_OOM_SKIP, &mm->flags))
+		pr_info("Handed over %u to exit path.\n", task_pid_nr(tsk));
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
----------------------------------------

You will find that "oom_reaper: unable to reap" message is trivially printed (and
MMF_OOM_SKIP is set) when the OOM victim is doing sched_setscheduler() request in
the stressor shown above.

  1 lock held by a.out/1331:
   #0: 00000000065062b5 (rcu_read_lock){....}, at: do_sched_setscheduler+0x54/0x190

This is because

	if (oom_badness_pages(mm) > (original_badness >> 2))
		ret = false;

made OOM reaper to print "oom_reaper: unable to reap" message even after reaping
succeeded when the OOM victim was consuming little memory. Yes, we could disable
"oom_reaper: unable to reap" message if reaping succeeded.



Next, let's think the lucky cases where "Handed over " message is printed.
Remove

	if (i < 32) {
		sched_setscheduler(0, SCHED_IDLE, &sp);
		nice(19);
	}

lines from the stressor, and retry with a patch shown below which will do the
similar thing from the exit path.

----------------------------------------
 kernel/sys.c | 14 ++++++++++++++
 mm/mmap.c    |  2 ++
 2 files changed, 16 insertions(+)

diff --git a/kernel/sys.c b/kernel/sys.c
index 123bd73..a1798bb 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -190,6 +190,20 @@ static int set_one_prio(struct task_struct *p, int niceval, int error)
 	return error;
 }
 
+struct sched_param {
+	int sched_priority;
+};
+
+void my_setpriority(void)
+{
+	struct sched_param sp = { };
+
+	sched_setscheduler(current, SCHED_IDLE, &sp);
+	rcu_read_lock();
+	set_one_prio(current, MAX_NICE, -ESRCH);
+	rcu_read_unlock();
+}
+
 SYSCALL_DEFINE3(setpriority, int, which, int, who, int, niceval)
 {
 	struct task_struct *g, *p;
diff --git a/mm/mmap.c b/mm/mmap.c
index 9063fdc..516cfc9 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3140,6 +3140,7 @@ void exit_mmap(struct mm_struct *mm)
 	 * tear down when it is safe to do so
 	 */
 	if (oom) {
+		extern void my_setpriority(void);
 		down_write(&mm->mmap_sem);
 		__unlink_vmas(vma);
 		/*
@@ -3149,6 +3150,7 @@ void exit_mmap(struct mm_struct *mm)
 		 */
 		mm->mmap = NULL;
 		up_write(&mm->mmap_sem);
+		my_setpriority();
 		__free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	} else {
 		free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
----------------------------------------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20181114-1.txt.xz .
----------------------------------------
[   43.961735] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
[   43.964369] kmem: usage 6528kB, limit 9007199254740988kB, failcnt 0
[   43.967410] Memory cgroup stats for /test1: cache:0KB rss:95832KB rss_huge:94208KB shmem:0KB mapped_file:0KB dirty:0KB writeback:0KB inactive_anon:0KB active_anon:95876KB inactive_file:0KB active_file:0KB unevictable:0KB
[   43.976150] Memory cgroup out of memory: Kill process 1079 (a.out) score 990 or sacrifice child
[   43.980391] Killed process 1083 (a.out) total-vm:209156kB, anon-rss:96kB, file-rss:0kB, shmem-rss:0kB
[   44.090703] Handed over 1083 to exit path.
[   76.209031] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 33s!
[   76.212351] Showing busy workqueues and worker pools:
[   76.215308] workqueue events: flags=0x0
[   76.217832]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[   76.217860]     pending: vmstat_shepherd, vmpressure_work_fn, vmw_fb_dirty_flush [vmwgfx]
[   76.217878] workqueue events_highpri: flags=0x10
[   76.217882]   pwq 1: cpus=0 node=0 flags=0x0 nice=-20 active=1/256
[   76.217887]     pending: flush_backlog BAR(436)
[   76.217941] workqueue mm_percpu_wq: flags=0x8
[   76.218004]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[   76.218007]     pending: vmstat_update
[   76.218011] workqueue netns: flags=0xe000a
[   76.218039]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=1/1
[   76.218068]     in-flight: 436:cleanup_net
[   76.218081] workqueue memcg_kmem_cache: flags=0x0
[   76.218085]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/1
[   76.218088]     pending: memcg_kmem_cache_create_func
[   76.218091]     delayed: memcg_kmem_cache_create_func,(...snipped...), memcg_kmem_cache_create_func
[   77.511224] pool 16: cpus=0-7 flags=0x4 nice=0 hung=4s workers=32 idle: 435 437 434 433 432 431 430 429 428 427 426 425 424 423 422 421 420 419 417 418 416 414 413 412 143 411 75 7 145 439 438
[  141.216183] rcu: INFO: rcu_preempt self-detected stall on CPU
[  141.219379] rcu:     0-....: (66161 ticks this GP) idle=11e/1/0x4000000000000002 softirq=3290/3292 fqs=15874
[  141.223795] rcu:      (t=65000 jiffies g=10501 q=1115)
[  141.226815] NMI backtrace for cpu 0
[  141.229437] CPU: 0 PID: 1084 Comm: a.out Not tainted 4.20.0-rc2+ #778
[  141.232891] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[  141.237363] Call Trace:
(...snipped...)
[  141.313476]  ? mem_cgroup_iter+0x156/0x7c0
[  141.315721]  mem_cgroup_iter+0x17e/0x7c0
[  141.318885]  ? mem_cgroup_iter+0x156/0x7c0
[  141.321488]  snapshot_refaults+0x5c/0x90
[  141.323609]  do_try_to_free_pages+0x2dd/0x3b0
[  141.326132]  try_to_free_mem_cgroup_pages+0x10d/0x390
[  141.329223]  try_charge+0x28b/0x830
[  141.331761]  memcg_kmem_charge_memcg+0x35/0x90
[  141.334568]  ? get_mem_cgroup_from_mm+0x239/0x2e0
[  141.336693]  memcg_kmem_charge+0x85/0x260
[  141.338605]  __alloc_pages_nodemask+0x218/0x360
[  141.340693]  pte_alloc_one+0x16/0xb0
[  141.342394]  __handle_mm_fault+0x873/0x1580
[  141.344355]  handle_mm_fault+0x1b2/0x3a0
[  141.346048]  ? handle_mm_fault+0x47/0x3a0
[  141.348501]  __do_page_fault+0x28c/0x530
[  141.350389]  do_page_fault+0x28/0x260
[  141.352133]  ? page_fault+0x8/0x30
[  141.353785]  page_fault+0x1e/0x30
[  141.355602] RIP: 0033:0x7f4bc7c92682
[  141.357336] Code: Bad RIP value.
[  141.358787] RSP: 002b:00007ffe682fc4a0 EFLAGS: 00010246
[  141.361110] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00007f4bc7c92682
[  141.363863] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
[  141.366464] RBP: 00007ffe682fc4c0 R08: 00007f4bc81a2740 R09: 0000000000000000
[  141.369074] R10: 00007f4bc81a2a10 R11: 0000000000000246 R12: 0000000000000000
[  141.371704] R13: 00007ffe682fc650 R14: 0000000000000000 R15: 0000000000000000
[  248.241504] INFO: task kworker/u16:28:436 blocked for more than 120 seconds.
[  248.244263]       Not tainted 4.20.0-rc2+ #778
[  248.246033] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  248.248718] kworker/u16:28  D10872   436      2 0x80000000
[  248.250768] Workqueue: netns cleanup_net
(...snipped...)
[  290.559855] a.out           R  running task    12792  1083   1079 0x80100084
[  290.562480] Call Trace:
[  290.563633]  __schedule+0x246/0x990
[  290.565031]  ? _raw_spin_unlock_irqrestore+0x55/0x70
[  290.566873]  preempt_schedule_common+0x34/0x54
[  290.568782]  preempt_schedule+0x1f/0x30
[  290.570896]  ___preempt_schedule+0x16/0x18
[  290.573639]  __sched_setscheduler+0x722/0x7c0
[  290.576363]  _sched_setscheduler+0x70/0x90
[  290.578785]  sched_setscheduler+0xe/0x10
[  290.580403]  my_setpriority+0x35/0x130
[  290.582277]  exit_mmap+0x1b8/0x1e0
[  290.583990]  mmput+0x63/0x130
[  290.585624]  do_exit+0x29d/0xcf0
[  290.586963]  ? _raw_spin_unlock_irq+0x27/0x50
[  290.588673]  ? __this_cpu_preempt_check+0x13/0x20
[  290.590600]  do_group_exit+0x47/0xc0
[  290.592098]  get_signal+0x329/0x920
[  290.594028]  do_signal+0x32/0x6e0
[  290.595620]  ? exit_to_usermode_loop+0x26/0x95
[  290.597268]  ? prepare_exit_to_usermode+0xa8/0xd0
[  290.599154]  exit_to_usermode_loop+0x3e/0x95
[  290.600794]  prepare_exit_to_usermode+0xa8/0xd0
[  290.602524]  ? page_fault+0x8/0x30
[  290.603928]  retint_user+0x8/0x18
(...snipped...)
[  336.219361] rcu: INFO: rcu_preempt self-detected stall on CPU
[  336.221340] rcu:     0-....: (259718 ticks this GP) idle=11e/1/0x4000000000000002 softirq=3290/3292 fqs=63254
[  336.224387] rcu:      (t=260003 jiffies g=10501 q=26578)
[  336.226119] NMI backtrace for cpu 0
[  336.227544] CPU: 0 PID: 1084 Comm: a.out Not tainted 4.20.0-rc2+ #778
[  336.229729] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[  336.233056] Call Trace:
[  336.234645]  <IRQ>
[  336.235696]  dump_stack+0x67/0x95
[  336.226119] NMI backtrace for cpu 0
[  336.227544] CPU: 0 PID: 1084 Comm: a.out Not tainted 4.20.0-rc2+ #778
[  336.229729] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[  336.233056] Call Trace:
(...snipped...)
[  336.287781]  shrink_node_memcg+0xa6/0x430
[  336.289621]  ? mem_cgroup_iter+0x21d/0x7c0
[  336.291382]  ? mem_cgroup_iter+0x156/0x7c0
[  336.293093]  shrink_node+0xd1/0x450
[  336.294734]  do_try_to_free_pages+0x103/0x3b0
[  336.296729]  try_to_free_mem_cgroup_pages+0x10d/0x390
[  336.298955]  try_charge+0x28b/0x830
[  336.300523]  memcg_kmem_charge_memcg+0x35/0x90
[  336.302258]  ? get_mem_cgroup_from_mm+0x239/0x2e0
[  336.304054]  memcg_kmem_charge+0x85/0x260
[  336.305688]  __alloc_pages_nodemask+0x218/0x360
[  336.307404]  pte_alloc_one+0x16/0xb0
[  336.308900]  __handle_mm_fault+0x873/0x1580
[  336.310577]  handle_mm_fault+0x1b2/0x3a0
[  336.312123]  ? handle_mm_fault+0x47/0x3a0
[  336.313768]  __do_page_fault+0x28c/0x530
[  336.315351]  do_page_fault+0x28/0x260
[  336.316870]  ? page_fault+0x8/0x30
[  336.318251]  page_fault+0x1e/0x30
----------------------------------------

Since the OOM victim thread is still reachable from the task list at this point,
it is possible that somebody changes scheduling priority of the OOM victim.



You might think that it is unfair to change scheduling priority from the exit path.
Then, retry with a patch shown below which will do the similar thing from outside
of the exit path (the OOM reaper kernel thread) instead of the patch shown above.

----------------------------------------
 kernel/sys.c  | 14 ++++++++++++++
 mm/oom_kill.c |  5 ++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 123bd73..acf24f7 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -190,6 +190,20 @@ static int set_one_prio(struct task_struct *p, int niceval, int error)
 	return error;
 }
 
+struct sched_param {
+	int sched_priority;
+};
+
+void my_setpriority(struct task_struct *p)
+{
+	struct sched_param sp = { };
+
+	sched_setscheduler(p, SCHED_IDLE, &sp);
+	rcu_read_lock();
+	set_one_prio(p, MAX_NICE, -ESRCH);
+	rcu_read_unlock();
+}
+
 SYSCALL_DEFINE3(setpriority, int, which, int, who, int, niceval)
 {
 	struct task_struct *g, *p;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b9e5a61..5841522 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -631,8 +631,11 @@ static void oom_reap_task(struct task_struct *tsk)
 	 */
 	if (mm->mmap)
 		set_bit(MMF_OOM_SKIP, &mm->flags);
-	else if (!test_bit(MMF_OOM_SKIP, &mm->flags))
+	else if (!test_bit(MMF_OOM_SKIP, &mm->flags)) {
+		extern void my_setpriority(struct task_struct *p);
+		my_setpriority(tsk);
 		pr_info("Handed over %u to exit path.\n", task_pid_nr(tsk));
+	}
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
----------------------------------------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20181114-2.txt.xz .
----------------------------------------
[   63.713061] Memory cgroup out of memory: Kill process 1236 (a.out) score 994 or sacrifice child
[   63.716303] Killed process 1236 (a.out) total-vm:209156kB, anon-rss:1344kB, file-rss:440kB, shmem-rss:0kB
[   63.720719] Handed over 1236 to exit path.
[  121.588872] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 62s!
[  121.591898] Showing busy workqueues and worker pools:
[  121.594011] workqueue events: flags=0x0
[  121.596230]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=5/256
[  121.596258]     pending: vmstat_shepherd, vmpressure_work_fn, vmw_fb_dirty_flush [vmwgfx], free_work, check_corruption
[  121.596331] workqueue events_power_efficient: flags=0x80
[  121.596336]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  121.596339]     pending: neigh_periodic_work, neigh_periodic_work
[  121.596347] workqueue mm_percpu_wq: flags=0x8
[  121.596350]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  121.596353]     pending: vmstat_update
[  186.594586] rcu: INFO: rcu_preempt self-detected stall on CPU
[  186.597329] rcu:     0-....: (67217 ticks this GP) idle=55e/1/0x4000000000000002 softirq=4231/4233 fqs=15984
[  186.601230] rcu:      (t=65000 jiffies g=9133 q=905)
[  186.603531] NMI backtrace for cpu 0
[  186.605611] CPU: 0 PID: 1237 Comm: a.out Not tainted 4.20.0-rc2+ #779
[  186.608291] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[  186.612320] Call Trace:
(...snipped...)
[  186.674690]  mem_cgroup_iter+0x21d/0x7c0
[  186.676609]  ? mem_cgroup_iter+0x156/0x7c0
[  186.678443]  shrink_node+0xa9/0x450
[  186.680183]  do_try_to_free_pages+0x103/0x3b0
[  186.682154]  try_to_free_mem_cgroup_pages+0x10d/0x390
[  186.684358]  try_charge+0x28b/0x830
[  186.686018]  mem_cgroup_try_charge+0x42/0x1d0
[  186.687931]  mem_cgroup_try_charge_delay+0x11/0x30
[  186.689889]  __handle_mm_fault+0xa88/0x1580
[  186.691851]  handle_mm_fault+0x1b2/0x3a0
[  186.693686]  ? handle_mm_fault+0x47/0x3a0
[  186.695662]  __do_page_fault+0x28c/0x530
[  186.697859]  do_page_fault+0x28/0x260
[  186.699598]  ? page_fault+0x8/0x30
[  186.701223]  page_fault+0x1e/0x30
(...snipped...)
[  381.597229] rcu: INFO: rcu_preempt self-detected stall on CPU
[  381.599916] rcu:     0-....: (261318 ticks this GP) idle=55e/1/0x4000000000000002 softirq=4231/4233 fqs=63272
[  381.603762] rcu:      (t=260003 jiffies g=9133 q=4712)
[  381.605823] NMI backtrace for cpu 0
[  381.607551] CPU: 0 PID: 1237 Comm: a.out Not tainted 4.20.0-rc2+ #779
[  381.610201] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[  381.614034] Call Trace:
(...snipped...)
[  381.672523]  ? mem_cgroup_iter+0x579/0x7c0
[  381.674461]  mem_cgroup_iter+0x5a6/0x7c0
[  381.676437]  ? mem_cgroup_iter+0x579/0x7c0
[  381.678375]  shrink_node+0x125/0x450
[  381.680013]  do_try_to_free_pages+0x103/0x3b0
[  381.682017]  try_to_free_mem_cgroup_pages+0x10d/0x390
[  381.684460]  try_charge+0x28b/0x830
[  381.686290]  mem_cgroup_try_charge+0x42/0x1d0
[  381.688454]  mem_cgroup_try_charge_delay+0x11/0x30
[  381.690929]  __handle_mm_fault+0xa88/0x1580
[  381.692860]  handle_mm_fault+0x1b2/0x3a0
[  381.694599]  ? handle_mm_fault+0x47/0x3a0
[  381.696269]  __do_page_fault+0x28c/0x530
[  381.697970]  do_page_fault+0x28/0x260
[  381.699650]  ? page_fault+0x8/0x30
[  381.701160]  page_fault+0x1e/0x30
(...snipped...)
[  446.166354] a.out           R  running task    13560  1236   1212 0x80100084
[  446.169179] Call Trace:
[  446.170469]  __schedule+0x246/0x990
[  446.172061]  preempt_schedule_common+0x34/0x54
[  446.173849]  preempt_schedule+0x1f/0x30
[  446.175514]  ___preempt_schedule+0x16/0x18
[  446.177187]  _raw_spin_unlock_irqrestore+0x5e/0x70
[  446.179277]  __debug_check_no_obj_freed+0x10b/0x1c0
[  446.181315]  ? kmem_cache_free+0x7f/0x2a0
[  446.183000]  ? vm_area_free+0x13/0x20
[  446.184646]  ? vm_area_free+0x13/0x20
[  446.186144]  debug_check_no_obj_freed+0x14/0x16
[  446.187950]  kmem_cache_free+0x15d/0x2a0
[  446.189556]  vm_area_free+0x13/0x20
[  446.190968]  remove_vma+0x54/0x60
[  446.192498]  exit_mmap+0x13d/0x1d0
[  446.193941]  mmput+0x63/0x130
[  446.195628]  do_exit+0x29d/0xcf0
[  446.197013]  ? _raw_spin_unlock_irq+0x27/0x50
[  446.198981]  ? __this_cpu_preempt_check+0x13/0x20
[  446.201033]  do_group_exit+0x47/0xc0
[  446.202715]  get_signal+0x329/0x920
[  446.204375]  do_signal+0x32/0x6e0
[  446.205731]  ? exit_to_usermode_loop+0x26/0x95
[  446.207487]  ? prepare_exit_to_usermode+0xa8/0xd0
[  446.209288]  exit_to_usermode_loop+0x3e/0x95
[  446.210924]  prepare_exit_to_usermode+0xa8/0xd0
[  446.212968]  ? page_fault+0x8/0x30
[  446.214627]  retint_user+0x8/0x18
(...snipped...)
[  446.234391] a.out           R  running task    13680  1237   1212 0x80000080
[  446.236896] Call Trace:
[  446.238079]  ? mem_cgroup_iter+0x156/0x7c0
[  446.239737]  ? find_held_lock+0x44/0xb0
[  446.241264]  ? debug_smp_processor_id+0x17/0x20
[  446.243088]  ? css_next_descendant_pre+0x45/0xb0
[  446.245025]  ? delayacct_end+0x1e/0x50
[  446.246640]  ? mem_cgroup_iter+0x2d2/0x7c0
[  446.248231]  ? shrink_node+0x125/0x450
[  446.249815]  ? do_try_to_free_pages+0x103/0x3b0
[  446.251724]  ? try_to_free_mem_cgroup_pages+0x10d/0x390
[  446.253703]  ? try_charge+0x28b/0x830
[  446.255270]  ? mem_cgroup_try_charge+0x42/0x1d0
[  446.257133]  ? mem_cgroup_try_charge_delay+0x11/0x30
[  446.259433]  ? __handle_mm_fault+0xa88/0x1580
[  446.261252]  ? handle_mm_fault+0x1b2/0x3a0
[  446.263071]  ? handle_mm_fault+0x47/0x3a0
[  446.264739]  ? __do_page_fault+0x28c/0x530
[  446.266376]  ? do_page_fault+0x28/0x260
[  446.267936]  ? page_fault+0x8/0x30
[  446.269478]  ? page_fault+0x1e/0x30
(...snipped...)
[  583.605227] a.out           R  running task    13560  1236   1212 0x80100084
[  583.608637] Call Trace:
[  583.609968]  __schedule+0x246/0x990
[  583.611682]  preempt_schedule_common+0x34/0x54
[  583.613472]  preempt_schedule+0x1f/0x30
[  583.615140]  ___preempt_schedule+0x16/0x18
[  583.616803]  _raw_spin_unlock_irqrestore+0x5e/0x70
[  583.618908]  __debug_check_no_obj_freed+0x10b/0x1c0
[  583.620844]  ? kmem_cache_free+0x7f/0x2a0
[  583.622691]  ? vm_area_free+0x13/0x20
[  583.624268]  ? vm_area_free+0x13/0x20
[  583.625765]  debug_check_no_obj_freed+0x14/0x16
[  583.627572]  kmem_cache_free+0x15d/0x2a0
[  583.629095]  vm_area_free+0x13/0x20
[  583.630631]  remove_vma+0x54/0x60
[  583.632533]  exit_mmap+0x13d/0x1d0
[  583.633993]  mmput+0x63/0x130
[  583.635500]  do_exit+0x29d/0xcf0
[  583.637010]  ? _raw_spin_unlock_irq+0x27/0x50
[  583.638776]  ? __this_cpu_preempt_check+0x13/0x20
[  583.640580]  do_group_exit+0x47/0xc0
[  583.642026]  get_signal+0x329/0x920
[  583.643908]  do_signal+0x32/0x6e0
[  583.645447]  ? exit_to_usermode_loop+0x26/0x95
[  583.647548]  ? prepare_exit_to_usermode+0xa8/0xd0
[  583.649457]  exit_to_usermode_loop+0x3e/0x95
[  583.651466]  prepare_exit_to_usermode+0xa8/0xd0
[  583.653244]  ? page_fault+0x8/0x30
[  583.654681]  retint_user+0x8/0x18
(...snipped...)
[  583.674642] a.out           R  running task    13680  1237   1212 0x80000080
[  583.677898] Call Trace:
[  583.679677]  ? find_held_lock+0x44/0xb0
[  583.681522]  ? lock_acquire+0xd3/0x210
[  583.685214]  ? rcu_is_watching+0x11/0x50
[  583.687452]  ? vmpressure+0x100/0x110
[  583.689069]  ? mem_cgroup_iter+0x5a6/0x7c0
[  583.690787]  ? lockdep_hardirqs_on+0xe5/0x1c0
[  583.692476]  ? shrink_node+0x125/0x450
[  583.694018]  ? css_task_iter_next+0x2b/0x70
[  583.695883]  ? do_try_to_free_pages+0x2fe/0x3b0
[  583.697702]  ? try_to_free_mem_cgroup_pages+0x10d/0x390
[  583.699611]  ? cgroup_file_notify+0x16/0x70
[  583.701252]  ? try_charge+0x28b/0x830
[  583.702954]  ? mem_cgroup_try_charge+0x42/0x1d0
[  583.704958]  ? mem_cgroup_try_charge_delay+0x11/0x30
[  583.706993]  ? __handle_mm_fault+0xa88/0x1580
[  583.708833]  ? handle_mm_fault+0x1b2/0x3a0
[  583.710502]  ? handle_mm_fault+0x47/0x3a0
[  583.712154]  ? __do_page_fault+0x28c/0x530
[  583.713806]  ? do_page_fault+0x28/0x260
[  583.715439]  ? page_fault+0x8/0x30
[  583.716973]  ? page_fault+0x1e/0x30
----------------------------------------

Since the allocating threads call only cond_resched(), and cond_resched() for
realtime priority threads is a no-op, allocating threads with realtime priority
will forever wait for the OOM victim with idle priority.



There is always an invisible lock called "scheduling priority". You can't
leave the MMF_OOM_SKIP to the exit path. Your approach is not ready for
handling the worst case.

Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
