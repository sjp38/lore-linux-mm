Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8F51E6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:25:31 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id l127so84551375iof.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 03:25:31 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f16si3975941igt.13.2016.02.25.03.25.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Feb 2016 03:25:30 -0800 (PST)
Subject: Re: [PATCH v2] mm,oom: don't abort on exiting processes when selecting a victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1455719485-7730-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160217143917.GP29196@dhcp22.suse.cz>
In-Reply-To: <20160217143917.GP29196@dhcp22.suse.cz>
Message-Id: <201602252025.ICH57371.FMOtOOFJFQHVSL@I-love.SAKURA.ne.jp>
Date: Thu, 25 Feb 2016 20:25:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Wed 17-02-16 23:31:25, Tetsuo Handa wrote:
> > Currently, oom_scan_process_thread() returns OOM_SCAN_ABORT when there is
> > a thread which is exiting. But it is possible that that thread is blocked
> > at down_read(&mm->mmap_sem) in exit_mm() called from do_exit() whereas
> > one of threads sharing that memory is doing a GFP_KERNEL allocation
> > between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
> > (e.g. mmap()).
> >
> > ----------
> > T1                  T2
> >                     Calls mmap()
> > Calls _exit(0)
> >                     Arrives at vm_mmap_pgoff()
> > Arrives at do_exit()
> > Gets PF_EXITING via exit_signals()
> >                     Calls down_write(&mm->mmap_sem)
> >                     Calls do_mmap_pgoff()
> > Calls down_read(&mm->mmap_sem) from exit_mm()
> >                     Calls out of memory via a GFP_KERNEL allocation but
> >                     oom_scan_process_thread(T1) returns OOM_SCAN_ABORT
> > ----------
> >
> > down_read(&mm->mmap_sem) by T1 is waiting for up_write(&mm->mmap_sem) by
> > T2 while oom_scan_process_thread() by T2 is waiting for T1 to set
> > T1->mm = NULL. Under such situation, the OOM killer does not choose
> > a victim, which results in silent OOM livelock problem.
> >
> > This patch changes oom_scan_process_thread() not to return OOM_SCAN_ABORT
> > when there is a thread which is exiting.
>
> Thank you for the updated changelog. This makes much more sense now.
> This problem exists for quite some time but I would be hesitant to
> mark it for stable because the side effects are quite hard to evaluate.
> We could e.g. see a premature OOM killer invocation while the currently
> exiting task just didn't get to finish and release its mm.
>
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>
> Acked-by: Michal Hocko <mhocko@suse.com>

It seems to me that mm->mmap_sem is not the only lock which will cause
OOM livelock. Today I was testing OOM reaper with a patch shown bottom.

---------- reproducer program ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <poll.h>
#include <sched.h>

static int fd = EOF;

static int memory_eater(void *unused)
{
	char *buf = NULL;
	unsigned long size = 0;
	char c;
	read(fd, &c, 1);
	while (1) {
		char *tmp = realloc(buf, size + 4096);
		if (!tmp)
			break;
		buf = tmp;
		buf[size] = 0;
		size += 4096;
	}
	pause();
	return 0;
}

int main(int argc, char *argv[])
{
	int pipe_fd[2] = { EOF, EOF };
	char *buf = NULL;
	unsigned long size;
	int i;
	if (pipe(pipe_fd))
		return 1;
	fd = pipe_fd[0];
	signal(SIGCLD, SIG_IGN);
	for (i = 0; i < 1024; i++) {
		if (fork() == 0) {
			char *stack = malloc(4096 * 2);
			char from[128] = { };
			char to[128] = { };
			const pid_t pid = getpid();
			unsigned char prev = 0;
			int fd = open("/proc/self/oom_score_adj", O_WRONLY);
			write(fd, "1000", 4);
			close(fd);
			close(pipe_fd[1]);
			if (chdir("/tmp"))
				_exit(1);
			srand(pid);
			sleep(2);
			snprintf(from, sizeof(from), "file.%u-0", pid);
			fd = open(from, O_WRONLY | O_CREAT, 0600);
			if (fd == EOF)
				_exit(1);
			if (clone(memory_eater, stack + 4096, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL) == -1)
				_exit(1);
			while (1) {
				const unsigned char next = rand();
				snprintf(from, sizeof(from), "file.%u-%u", pid, prev);
				snprintf(to, sizeof(to), "file.%u-%u", pid, next);
				prev = next;
				rename(from, to);
				write(fd, "", 1);
			}
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
	sleep(4);
	close(pipe_fd[0]);
	close(pipe_fd[1]);
	/* Will cause OOM due to overcommit */
	for (i = 0; i < size; i += 4096)
		buf[i] = 0;
	while (1)
		pause();
	return 0;
}
---------- reproducer program ----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160225.txt.xz .
---------- console log ----------
[   89.401532] Out of memory: Kill process 2363 (a.out) score 1001 or sacrifice child
[   89.401537] Killed process 2363 (a.out) total-vm:71168kB, anon-rss:1524kB, file-rss:0kB, shmem-rss:0kB
[   89.401902] oom_reaper: reaped process 2363 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0lB
[   89.748990] a.out           D ffff880027dd37d8     0  2581   1230 0x00000080
(...snipped...)
[   92.121717] MemAlloc: a.out(2989) flags=0x400c44 switches=398 uninterruptible exiting
[   92.127895] a.out           D ffff8800254c75a8     0  2989   1230 0x00000084
[   92.132250]  ffff8800254c75a8 ffff88002bbf8000 ffff8800254bc080 ffff8800254c8000
[   92.136880]  ffff8800254c75e0 ffff88003d650240 00000000fffcd249 0000000000000002
[   92.141378]  ffff8800254c75c0 ffffffff81672d1a ffff88003d650240 ffff8800254c7660
[   92.145982] Call Trace:
[   92.147750]  [<ffffffff81672d1a>] schedule+0x3a/0x90
[   92.151438]  [<ffffffff8167717e>] schedule_timeout+0x11e/0x1c0
[   92.155754]  [<ffffffff810e1270>] ? init_timer_key+0x40/0x40
[   92.159280]  [<ffffffff8112b7ba>] ? __delayacct_blkio_start+0x1a/0x30
[   92.163190]  [<ffffffff816720c1>] io_schedule_timeout+0xa1/0x110
[   92.166832]  [<ffffffff811650ed>] congestion_wait+0x7d/0xd0
[   92.170249]  [<ffffffff810b73e0>] ? wait_woken+0x80/0x80
[   92.173530]  [<ffffffff81159d1b>] shrink_inactive_list+0x43b/0x550
[   92.177257]  [<ffffffff810a8717>] ? set_next_entity+0x5b7/0x7e0
[   92.180841]  [<ffffffff8115a7d6>] shrink_zone_memcg+0x5b6/0x780
[   92.184595]  [<ffffffff811b38ed>] ? mem_cgroup_iter+0x15d/0x7c0
[   92.188498]  [<ffffffff8115aa74>] shrink_zone+0xd4/0x2f0
[   92.191768]  [<ffffffff8115afc9>] do_try_to_free_pages+0x139/0x360
[   92.195533]  [<ffffffff8115b284>] try_to_free_pages+0x94/0xc0
[   92.199090]  [<ffffffff8114dedd>] __alloc_pages_nodemask+0x6cd/0xed0
[   92.202908]  [<ffffffff8119fe37>] kmem_getpages+0x57/0x200
[   92.206540]  [<ffffffff811a12f6>] fallback_alloc+0x236/0x2a0
[   92.210221]  [<ffffffff811a146e>] ____cache_alloc_node+0x10e/0x150
[   92.213902]  [<ffffffff811a20a0>] kmem_cache_alloc+0x170/0x1b0
[   92.217409]  [<ffffffff8112cab5>] taskstats_exit+0x325/0x420
[   92.220813]  [<ffffffff810739b3>] do_exit+0x143/0xb40
[   92.223900]  [<ffffffff81074437>] do_group_exit+0x47/0xc0
[   92.227170]  [<ffffffff8108093f>] get_signal+0x20f/0x7e0
[   92.230401]  [<ffffffff810261f2>] do_signal+0x32/0x6d0
[   92.233554]  [<ffffffff8167799c>] ? _raw_spin_unlock+0x2c/0x50
[   92.237035]  [<ffffffff8105ce23>] ? __do_page_fault+0x163/0x4a0
[   92.240581]  [<ffffffff8106c1ea>] ? exit_to_usermode_loop+0x2e/0x90
[   92.244871]  [<ffffffff8106c208>] exit_to_usermode_loop+0x4c/0x90
[   92.248511]  [<ffffffff810034c6>] prepare_exit_to_usermode+0x76/0x80
[   92.252393]  [<ffffffff81678cfe>] retint_user+0x8/0x23
(...snipped...)
[  113.134065] MemAlloc-Info: stalling=67 dying=10 exiting=1 victim=0 oom_count=441/447
[  123.140014] MemAlloc-Info: stalling=1011 dying=38 exiting=1 victim=0 oom_count=640/481
(...snipped...)
[  220.798001] MemAlloc: a.out(3073) flags=0x400c44 switches=6853 seq=9 gfp=0x26040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK) order=0 delay=77411 exiting
[  220.798002] a.out           R  running task        0  3073   1230 0x00000084
[  220.798003]  ffff88002576f860 ffff88003cfc4100 ffff88002576a040 ffff880025770000
[  220.798004]  ffff88003fafaa18 00000000000000c0 0000000000000c00 0000000000000000
[  220.798005]  ffff88002576f878 ffffffff81672b9a ffff88003fafaa18 ffff88002576f888
[  220.798005] Call Trace:
[  220.798006]  [<ffffffff81672b9a>] preempt_schedule_common+0x1f/0x35
[  220.798006]  [<ffffffff81672bd5>] preempt_schedule+0x25/0x30
[  220.798007]  [<ffffffff81003058>] ___preempt_schedule+0x12/0x14
[  220.798008]  [<ffffffff816779af>] ? _raw_spin_unlock+0x3f/0x50
[  220.798009]  [<ffffffff811b9f01>] vmpressure+0x111/0x150
[  220.798011]  [<ffffffff811b9f5c>] vmpressure_prio+0x1c/0x20
[  220.798012]  [<ffffffff8115af08>] do_try_to_free_pages+0x78/0x360
[  220.798013]  [<ffffffff8115b284>] try_to_free_pages+0x94/0xc0
[  220.798014]  [<ffffffff8114dedd>] __alloc_pages_nodemask+0x6cd/0xed0
[  220.798015]  [<ffffffff8119fe37>] kmem_getpages+0x57/0x200
[  220.798016]  [<ffffffff811a12f6>] fallback_alloc+0x236/0x2a0
[  220.798018]  [<ffffffff811a146e>] ____cache_alloc_node+0x10e/0x150
[  220.798019]  [<ffffffff811a20a0>] kmem_cache_alloc+0x170/0x1b0
[  220.798021]  [<ffffffff8112cab5>] taskstats_exit+0x325/0x420
[  220.798023]  [<ffffffff810739b3>] do_exit+0x143/0xb40
[  220.798024]  [<ffffffff81074437>] do_group_exit+0x47/0xc0
[  220.798026]  [<ffffffff8108093f>] get_signal+0x20f/0x7e0
[  220.798028]  [<ffffffff810261f2>] do_signal+0x32/0x6d0
[  220.798029]  [<ffffffff810ba8c9>] ? __lock_is_held+0x49/0x70
[  220.798030]  [<ffffffff8106c297>] ? syscall_slow_exit_work+0x4b/0x10d
[  220.798031]  [<ffffffff8106c1ea>] ? exit_to_usermode_loop+0x2e/0x90
[  220.798032]  [<ffffffff8106c208>] exit_to_usermode_loop+0x4c/0x90
[  220.798033]  [<ffffffff8100371d>] do_syscall_64+0x11d/0x180
[  220.798034]  [<ffffffff816783ff>] entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  220.867062] MemAlloc-Info: stalling=943 dying=1930 exiting=1 victim=0 oom_count=1096/536
[  225.225437] sysrq: SysRq : Kill All Tasks
---------- console log ----------

Number of out_of_memory() calls is increasing over time ( 640 -> 1096 ).
PID=3073 is doing GFP_KERNEL allocation from taskstats_exit() from do_exit().
Since taskstats_exit() is called between exit_signals() and exit_mm(),
task_will_free_mem() returns true. While out_of_memory() is called,
oom_scan_process_thread() is returning OOM_SCAN_ABORT due to reasons
other than mmap_sem contention.

> > ---
> >  mm/oom_kill.c | 3 ---
> >  1 file changed, 3 deletions(-)
> >
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index cf87153..6e6abaf 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -292,9 +292,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> >  	if (oom_task_origin(task))
> >  		return OOM_SCAN_SELECT;
> >
> > -	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
> > -		return OOM_SCAN_ABORT;
> > -
> >  	return OOM_SCAN_OK;
> >  }
> >
> > --
> > 1.8.3.1

So, what unthrottling method should we add if we we preserve this check?



Delta patch after three patches shown in
http://lkml.kernel.org/r/201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp thread.
---------- delta3 patch (for linux-next-20160224 + kmallocwd + delta + delta2) ----------
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 238b0fb..509b120 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1405,6 +1405,7 @@ struct memalloc_info {
 	 * bit 1: Will be reported as dying task.
 	 * bit 2: Will be reported as stalling task.
 	 * bit 3: Will be reported as exiting task.
+	 * bit 7: Will be reported unconditionally.
 	 */
 	u8 type;
 	/* Started time in jiffies as of valid == 1. */
diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index f098e16..8413d5d 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -199,6 +199,8 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 			type |= 4;
 			stalling_tasks++;
 		}
+		if (p->flags & PF_KSWAPD)
+			type |= 128;
 		p->memalloc.type = type;
 	}
 	rcu_read_unlock();
@@ -208,8 +210,8 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 	cond_resched();
 	/* Report stalling tasks, dying and victim tasks. */
 	pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u oom_count=%u/%u\n",
-		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending, out_of_memory_count,
-		no_out_of_memory_count);
+		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending,
+		out_of_memory_count, no_out_of_memory_count);
 	cond_resched();
 	sigkill_pending = 0;
 	exiting_tasks = 0;
@@ -222,7 +224,7 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 		bool can_cont;
 		u8 type;

-		if (likely(!p->memalloc.type && !(p->flags & PF_KSWAPD)))
+		if (likely(!p->memalloc.type))
 			continue;
 		p->memalloc.type = 0;
 		/* Recheck in case state changed meanwhile. */
@@ -244,17 +246,22 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 			stalling_tasks++;
 			snprintf(buf, sizeof(buf),
 				 " seq=%u gfp=0x%x(%pGg) order=%u delay=%lu",
-				 memalloc.sequence >> 1, memalloc.gfp, &memalloc.gfp,
+				 memalloc.sequence >> 1, memalloc.gfp,
+				 &memalloc.gfp,
 				 memalloc.order, now - memalloc.start);
+		} else {
+			buf[0] = '\0';
 		}
-		if (unlikely(!type && !(p->flags & PF_KSWAPD)))
+		if (p->flags & PF_KSWAPD)
+			type |= 128;
+		if (unlikely(!type))
 			continue;
 		/*
 		 * Victim tasks get pending SIGKILL removed before arriving at
 		 * do_exit(). Therefore, print " exiting" instead for " dying".
 		 */
-		pr_warn("MemAlloc: %s(%u) flags=0x%x%s%s%s%s%s\n", p->comm,
-			p->pid, p->flags, (type & 4) ? buf : "",
+		pr_warn("MemAlloc: %s(%u) flags=0x%x switches=%lu%s%s%s%s%s\n", p->comm,
+			p->pid, p->flags, p->nvcsw + p->nivcsw, buf,
 			(p->state & TASK_UNINTERRUPTIBLE) ?
 			" uninterruptible" : "",
 			(type & 8) ? " exiting" : "",
@@ -272,7 +279,7 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 		get_task_struct(g);
 		get_task_struct(p);
 		rcu_read_unlock();
-		preempt_enable();
+		preempt_enable_no_resched();
 		cond_resched();
 		preempt_disable();
 		rcu_read_lock();
@@ -283,7 +290,7 @@ static void check_memalloc_stalling_tasks(unsigned long timeout)
 			goto restart_report;
 	}
 	rcu_read_unlock();
-	preempt_enable();
+	preempt_enable_no_resched();
 	cond_resched();
 	/* Show memory information. (SysRq-m) */
 	show_mem(0);
---------- delta3 patch (for linux-next-20160224 + kmallocwd + delta + delta2) ----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
