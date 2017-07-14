Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id AFF57440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 08:31:14 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id m84so109385488ita.15
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:31:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a141si5244001ioe.32.2017.07.14.05.31.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 05:31:11 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170711134900.GD11936@dhcp22.suse.cz>
	<201707120706.FHC86458.FLFOHtQVJSFMOO@I-love.SAKURA.ne.jp>
	<20170712085431.GD28912@dhcp22.suse.cz>
	<201707122123.CDD21817.FOQSFJtOHOVLFM@I-love.SAKURA.ne.jp>
	<20170712124145.GI28912@dhcp22.suse.cz>
In-Reply-To: <20170712124145.GI28912@dhcp22.suse.cz>
Message-Id: <201707142130.JJF10142.FHJFOQSOOtMVLF@I-love.SAKURA.ne.jp>
Date: Fri, 14 Jul 2017 21:30:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky.work@gmail.com, pmladek@suse.com

Michal Hocko wrote:
> On Wed 12-07-17 21:23:05, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Wed 12-07-17 07:06:11, Tetsuo Handa wrote:
> > > > They don't call printk() until something completes (e.g. some operation returned
> > > > an error code) or they do throttling. Only watchdog calls printk() without waiting
> > > > for something to complete (because watchdog is there in order to warn that something
> > > > might be wrong). But watchdog is calling printk() carefully not to cause flooding
> > > > (e.g. khungtaskd sleeps enough) and not to cause lockups (e.g. khungtaskd calls
> > > > rcu_lock_break()).
> > >
> > > Look at hard/soft lockup detector and how it can cause flood of printks.
> > 
> > Lockup detector is legitimate because it is there to warn that somebody is
> > continuously consuming CPU time. Lockup detector might do
> 
> Sigh. What I've tried to convey is that the lockup detector can print _a
> lot_ (just consider a large machine with hundreds of CPUs and trying to
> dump stack trace on each of them....) and that might mimic a herd of
> printks from allocation stalls...

So, you are brave enough to offload writing to consoles to a schedulable context
when the system is experiencing hard/soft lockups (which means that there is no
guarantee that printk kthread can start writing to consoles from a schedulable
context). Good luck. Watchdog messages from interrupt context are urgent.

But OOM killer messages and warn_alloc() (for stall reporting) messages are
both from schedulable context and these messages can be offloaded to printk kthread.
I'm not objecting offloading OOM killer messages and warn_alloc() messages.

> [...]
> > > warn_alloc prints a single line + dump_stack for each stalling allocation and
> > > show_mem once per second. That doesn't sound overly crazy to me.
> > > Sure we can have many stalling tasks under certain conditions (most of
> > > them quite unrealistic) and then we can print a lot. I do not see an
> > > easy way out of it without losing information about stalls and I guess
> > > we want to know about them otherwise we will have much harder time to
> > > debug stalls.
> > 
> > Printing just one line per every second can lead to lockup, for
> > the condition to escape the "for (;;)" loop in console_unlock() is
> > 
> >                 if (console_seq == log_next_seq)
> >                         break;
> 
> Then something is really broken in that condition, don't you think?
> Peter has already mentioned that offloading to a different context seems
> like the way to go here.
> 
> > when cond_resched() in that loop slept for more than one second due to
> > SCHED_IDLE priority.
> > 
> > Currently preempt_disable()/preempt_enable_no_resched() (or equivalent)
> > is the only available countermeasure for minimizing interference like
> > 
> >     for (i = 0; i < 1000; i++)
> >       printk();
> > 
> > . If prink() allows per printk context (shown below) flag which allows printk()
> > users to force printk() not to try to print immediately (i.e. declare that
> > use deferred printing (maybe offloaded to the printk-kthread)), lockups by
> > cond_resched() from console_unlock() from printk() from out_of_memory() will be
> > avoided.
> 
> As I've said earlier, if there is no other way to make printk work without all
> these nasty side effected then I would be OK to add a printk context
> specific calls into the oom killer.
> 
> Removing the rest because this is again getting largely tangent. The
> primary problem you are seeing is that we stumble over printk here.
> Unless I can see a sound argument this is not the case it doesn't make
> any sense to discuss allocator changes.

You are still ignoring my point. I agree that we stumble over printk(), but
printk() is nothing but one of locations we stumble.

Look at schedule_timeout_killable(1) in out_of_memory() which is called with
oom_lock still held. I'm reporting that even printk() is offloaded to printk
kernel thread, scheduling priority can make schedule_timeout_killable(1) sleep
for more than 12 minutes (which is intended to sleep for only one millisecond).
(I gave up waiting and pressed SysRq-i. I can't imagine how long it would have
continued sleeping inside schedule_timeout_killable(1) with oom_lock held.)

Without cooperation from other allocating threads which failed to hold oom_lock,
it is dangerous to keep out_of_memory() preemptible/schedulable context.

---------- Reproducer start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sched.h>
#include <signal.h>
#include <sys/prctl.h>

int main(int argc, char *argv[])
{
	struct sched_param sp = { };
	cpu_set_t cpu = { { 1 } };
	static int pipe_fd[2] = { EOF, EOF };
	unsigned long size = 65536;
	char *buf = malloc(size);
	unsigned long i = 0;
	signal(SIGCLD, SIG_IGN);
	sched_setaffinity(0, sizeof(cpu), &cpu);
	prctl(PR_SET_NAME, (unsigned long) "normal-priority", 0, 0, 0);
	pipe(pipe_fd);
	for (i = 0; i < 1024; i++)
		if (fork() == 0) {
			if (i)
				close(pipe_fd[1]);
			/* Wait until first child gets SIGKILL. */
			read(pipe_fd[0], &i, 1);
			/* Join the direct reclaim storm. */
			for (i = 0; i < size; i += 4096)
				buf[i] = 0;
			_exit(0);
		}
	for (size = 512; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sched_setscheduler(0, SCHED_IDLE, &sp);
	prctl(PR_SET_NAME, (unsigned long) "idle-priority", 0, 0, 0);
	close(pipe_fd[1]);
	for (i = 0; i < size; i += 4096)
		buf[i] = 0; /* Will cause OOM due to overcommit */
	kill(-1, SIGKILL);
	return 0; /* Not reached. */
}
---------- Reproducer end ----------

---------- Simple printk() offloading patch start ----------
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8337e2d..529fc36 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -651,6 +651,7 @@ struct task_struct {
 	/* disallow userland-initiated cgroup migration */
 	unsigned			no_cgroup_migration:1;
 #endif
+	unsigned			offload_printk:1;
 
 	unsigned long			atomic_flags; /* Flags requiring atomic access. */
 
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index fc47863..06afcd7 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -48,6 +48,7 @@
 #include <linux/sched/clock.h>
 #include <linux/sched/debug.h>
 #include <linux/sched/task_stack.h>
+#include <linux/kthread.h>
 
 #include <linux/uaccess.h>
 #include <asm/sections.h>
@@ -2120,6 +2121,20 @@ static int have_callable_console(void)
 	return 0;
 }
 
+static atomic_t printk_reaper_pending = ATOMIC_INIT(0);
+static DECLARE_WAIT_QUEUE_HEAD(printk_reaper_wait);
+
+static int printk_reaper(void *unused)
+{
+	while (true) {
+		wait_event(printk_reaper_wait, atomic_read(&printk_reaper_pending));
+		console_lock();
+		console_unlock();
+		atomic_dec(&printk_reaper_pending);
+	}
+	return 0;
+}
+
 /*
  * Can we actually use the console at this time on this cpu?
  *
@@ -2129,6 +2144,11 @@ static int have_callable_console(void)
  */
 static inline int can_use_console(void)
 {
+	if (current->offload_printk && in_task()) {
+		atomic_inc(&printk_reaper_pending);
+		wake_up(&printk_reaper_wait);
+		return 0;
+	}
 	return cpu_online(raw_smp_processor_id()) || have_callable_console();
 }
 
@@ -2678,6 +2698,7 @@ static int __init printk_late_init(void)
 	ret = cpuhp_setup_state_nocalls(CPUHP_AP_ONLINE_DYN, "printk:online",
 					console_cpu_notify, NULL);
 	WARN_ON(ret < 0);
+	kthread_run(printk_reaper, NULL, "printk_reaper");
 	return 0;
 }
 late_initcall(printk_late_init);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 80e4adb..66356f2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3754,6 +3754,19 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return false;
 }
 
+static void memalloc_print(unsigned long unused);
+static atomic_t memalloc_in_flight = ATOMIC_INIT(0);
+static DEFINE_TIMER(memalloc_timer, memalloc_print, 0, 0);
+static void memalloc_print(unsigned long unused)
+{
+	const int in_flight = atomic_read(&memalloc_in_flight);
+
+	if (in_flight < 10)
+		return;
+	pr_warn("MemAlloc: %d in-flight.\n", in_flight);
+	mod_timer(&memalloc_timer, jiffies + HZ);
+}
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
@@ -3770,6 +3783,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	unsigned long alloc_start = jiffies;
 	unsigned int stall_timeout = 10 * HZ;
 	unsigned int cpuset_mems_cookie;
+	const bool offload_printk = current->offload_printk;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3790,6 +3804,9 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 				(__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
 		gfp_mask &= ~__GFP_ATOMIC;
 
+	if (can_direct_reclaim)
+		atomic_inc(&memalloc_in_flight);
+	current->offload_printk = 1;
 retry_cpuset:
 	compaction_retries = 0;
 	no_progress_loops = 0;
@@ -3898,6 +3915,8 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	if (!can_direct_reclaim)
 		goto nopage;
 
+	if (!timer_pending(&memalloc_timer))
+		mod_timer(&memalloc_timer, jiffies + HZ);
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
 		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
@@ -4020,6 +4039,9 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	warn_alloc(gfp_mask, ac->nodemask,
 			"page allocation failure: order:%u", order);
 got_pg:
+	current->offload_printk = offload_printk;
+	if (can_direct_reclaim)
+		atomic_dec(&memalloc_in_flight);
 	return page;
 }
 
---------- Simple printk() offloading patch end ----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170714.txt.xz .
It is pointless to complain about 927 threads doing allocations. The primary
problem is scheduling priority rather than printk(). I would be able to reproduce
this problem with much fewer threads if I were permitted to mix realtime priority
threads; I put my reproducer under constraint not to use root privileges.
----------
[  856.066292] idle-priority invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
[  856.066298] idle-priority cpuset=/ mems_allowed=0
[  856.066306] CPU: 0 PID: 6183 Comm: idle-priority Not tainted 4.12.0-next-20170714+ #632
[  856.066307] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  856.066317] Call Trace:
[  856.066325]  dump_stack+0x67/0x9e
[  856.066331]  dump_header+0x9d/0x3fa
[  856.066337]  ? trace_hardirqs_on+0xd/0x10
[  856.066343]  oom_kill_process+0x226/0x650
[  856.066350]  out_of_memory+0x136/0x560
[  856.066351]  ? out_of_memory+0x206/0x560
[  856.066357]  __alloc_pages_nodemask+0xec1/0xf50
[  856.066375]  alloc_pages_vma+0x76/0x1a0
[  856.066381]  __handle_mm_fault+0xddd/0x1160
[  856.066384]  ? native_sched_clock+0x36/0xa0
[  856.066395]  handle_mm_fault+0x186/0x360
[  856.066396]  ? handle_mm_fault+0x44/0x360
[  856.066401]  __do_page_fault+0x1da/0x510
[  856.066409]  do_page_fault+0x21/0x70
[  856.066413]  page_fault+0x22/0x30
[  856.066416] RIP: 0033:0x4008c0
[  856.066417] RSP: 002b:00007ffc83235ba0 EFLAGS: 00010206
[  856.066419] RAX: 00000000c7b4e000 RBX: 0000000100000000 RCX: 00007f1b4da57bd0
[  856.066420] RDX: 0000000000000000 RSI: 0000000000400ae0 RDI: 0000000000000004
[  856.066420] RBP: 00007f194db63010 R08: 0000000000000000 R09: 0000000000021000
[  856.066421] R10: 00007ffc83235920 R11: 0000000000000246 R12: 0000000000000006
[  856.066422] R13: 00007f194db63010 R14: 0000000000000000 R15: 0000000000000000
[  856.066433] Mem-Info:
[  856.066437] active_anon:843412 inactive_anon:3676 isolated_anon:0
[  856.066437]  active_file:0 inactive_file:209 isolated_file:0
[  856.066437]  unevictable:0 dirty:0 writeback:0 unstable:0
[  856.066437]  slab_reclaimable:0 slab_unreclaimable:0
[  856.066437]  mapped:1877 shmem:4208 pagetables:10553 bounce:0
[  856.066437]  free:21334 free_pcp:0 free_cma:0
[  856.066439] Node 0 active_anon:3373648kB inactive_anon:14704kB active_file:0kB inactive_file:836kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:7508kB dirty:0kB writeback:0kB shmem:16832kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2762752kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  856.066484] Node 0 DMA free:14776kB min:288kB low:360kB high:432kB active_anon:1092kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  856.066487] lowmem_reserve[]: 0 2688 3624 3624
[  856.066492] Node 0 DMA32 free:53464kB min:49908kB low:62384kB high:74860kB active_anon:2696692kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752816kB mlocked:0kB kernel_stack:48kB pagetables:164kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  856.066495] lowmem_reserve[]: 0 0 936 936
[  856.066499] Node 0 Normal free:17096kB min:17384kB low:21728kB high:26072kB active_anon:675816kB inactive_anon:14704kB active_file:0kB inactive_file:944kB unevictable:0kB writepending:0kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:17632kB pagetables:42044kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  856.066502] lowmem_reserve[]: 0 0 0 0
[  856.066506] Node 0 DMA: 2*4kB (UM) 2*8kB (UM) 2*16kB (UM) 2*32kB (UM) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14776kB
[  856.066525] Node 0 DMA32: 22*4kB (UM) 70*8kB (UM) 73*16kB (UM) 78*32kB (UM) 62*64kB (UM) 41*128kB (UM) 38*256kB (UM) 15*512kB (U) 20*1024kB (UM) 1*2048kB (U) 0*4096kB = 53464kB
[  856.066553] Node 0 Normal: 89*4kB (UMH) 96*8kB (UH) 84*16kB (UMEH) 99*32kB (UMEH) 35*64kB (UMEH) 34*128kB (UMEH) 21*256kB (U) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 17604kB
[  856.066569] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  856.066570] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  856.066571] 4450 total pagecache pages
[  856.066573] 0 pages in swap cache
[  856.066574] Swap cache stats: add 0, delete 0, find 0/0
[  856.066575] Free swap  = 0kB
[  856.066576] Total swap = 0kB
[  856.066577] 1048445 pages RAM
[  856.066578] 0 pages HighMem/MovableOnly
[  856.066579] 116548 pages reserved
[  856.066580] 0 pages hwpoisoned
[  856.066581] Out of memory: Kill process 6183 (idle-priority) score 879 or sacrifice child
[  856.068245] Killed process 6301 (normal-priority) total-vm:4360kB, anon-rss:92kB, file-rss:0kB, shmem-rss:0kB
[  856.928087] MemAlloc: 916 in-flight.
[  857.952174] MemAlloc: 921 in-flight.
[  858.976265] MemAlloc: 923 in-flight.
[  859.417641] warn_alloc: 364 callbacks suppressed
(...snipped...)
[ 1155.865901] normal-priority: page allocation stalls for 300124ms, order:0, mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
[ 1155.865906] normal-priority cpuset=/ mems_allowed=0
[ 1155.865910] CPU: 0 PID: 7193 Comm: normal-priority Not tainted 4.12.0-next-20170714+ #632
[ 1155.865911] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1155.865911] Call Trace:
[ 1155.865915]  dump_stack+0x67/0x9e
[ 1155.865918]  warn_alloc+0x10f/0x1b0
[ 1155.865924]  ? wake_all_kswapds+0x56/0x96
[ 1155.865929]  __alloc_pages_nodemask+0xb2c/0xf50
[ 1155.865945]  alloc_pages_vma+0x76/0x1a0
[ 1155.865950]  __handle_mm_fault+0xddd/0x1160
[ 1155.865952]  ? native_sched_clock+0x36/0xa0
[ 1155.865962]  handle_mm_fault+0x186/0x360
[ 1155.865964]  ? handle_mm_fault+0x44/0x360
[ 1155.865968]  __do_page_fault+0x1da/0x510
[ 1155.865975]  do_page_fault+0x21/0x70
[ 1155.865979]  page_fault+0x22/0x30
(...snipped...)
[ 1175.931414] normal-priority: page allocation stalls for 320133ms, order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
[ 1175.931420] normal-priority cpuset=/ mems_allowed=0
[ 1175.931425] CPU: 0 PID: 6697 Comm: normal-priority Not tainted 4.12.0-next-20170714+ #632
[ 1175.931426] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1175.931427] Call Trace:
[ 1175.931432]  dump_stack+0x67/0x9e
[ 1175.931436]  warn_alloc+0x10f/0x1b0
[ 1175.931442]  ? wake_all_kswapds+0x56/0x96
[ 1175.931447]  __alloc_pages_nodemask+0xb2c/0xf50
[ 1175.931465]  alloc_pages_current+0x65/0xb0
[ 1175.931469]  __page_cache_alloc+0x10b/0x140
[ 1175.931474]  filemap_fault+0x3df/0x6a0
[ 1175.931475]  ? filemap_fault+0x2ab/0x6a0
[ 1175.931482]  xfs_filemap_fault+0x34/0x50
[ 1175.931485]  __do_fault+0x19/0x120
[ 1175.931489]  __handle_mm_fault+0xa5c/0x1160
[ 1175.931492]  ? native_sched_clock+0x36/0xa0
[ 1175.931502]  handle_mm_fault+0x186/0x360
[ 1175.931504]  ? handle_mm_fault+0x44/0x360
[ 1175.931508]  __do_page_fault+0x1da/0x510
[ 1175.931516]  do_page_fault+0x21/0x70
[ 1175.931520]  page_fault+0x22/0x30
(...snipped...)
[ 1494.107705] idle-priority   R  running task    13272  6183   2806 0x00000080
[ 1494.109560] Call Trace:
[ 1494.110510]  __schedule+0x256/0x8e0
[ 1494.111659]  ? _raw_spin_unlock_irqrestore+0x31/0x50
[ 1494.113078]  schedule+0x38/0x90
[ 1494.114204]  schedule_timeout+0x19a/0x330
[ 1494.115424]  ? call_timer_fn+0x120/0x120
[ 1494.116639]  ? oom_kill_process+0x50c/0x650
[ 1494.117909]  schedule_timeout_killable+0x25/0x30
[ 1494.119259]  out_of_memory+0x140/0x560
[ 1494.120485]  ? out_of_memory+0x206/0x560
[ 1494.121693]  __alloc_pages_nodemask+0xec1/0xf50
[ 1494.123058]  alloc_pages_vma+0x76/0x1a0
[ 1494.124306]  __handle_mm_fault+0xddd/0x1160
[ 1494.125572]  ? native_sched_clock+0x36/0xa0
[ 1494.126848]  handle_mm_fault+0x186/0x360
[ 1494.128103]  ? handle_mm_fault+0x44/0x360
[ 1494.129284]  __do_page_fault+0x1da/0x510
[ 1494.130575]  do_page_fault+0x21/0x70
[ 1494.131738]  page_fault+0x22/0x30
(...snipped...)
[ 1571.807967] MemAlloc: 927 in-flight.
[ 1572.832053] MemAlloc: 927 in-flight.
[ 1573.856064] MemAlloc: 927 in-flight.
[ 1574.880238] MemAlloc: 927 in-flight.
[ 1575.904575] MemAlloc: 927 in-flight.
[ 1576.060103] warn_alloc: 462 callbacks suppressed
[ 1576.060139] normal-priority: page allocation stalls for 720318ms, order:0, mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
[ 1576.060149] normal-priority cpuset=/ mems_allowed=0
[ 1576.060158] CPU: 0 PID: 7193 Comm: normal-priority Not tainted 4.12.0-next-20170714+ #632
[ 1576.060160] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1576.060162] Call Trace:
[ 1576.060170]  dump_stack+0x67/0x9e
[ 1576.060177]  warn_alloc+0x10f/0x1b0
[ 1576.060184]  ? wake_all_kswapds+0x56/0x96
[ 1576.060189]  __alloc_pages_nodemask+0xb2c/0xf50
[ 1576.060207]  alloc_pages_vma+0x76/0x1a0
[ 1576.060214]  __handle_mm_fault+0xddd/0x1160
[ 1576.060218]  ? native_sched_clock+0x36/0xa0
[ 1576.060229]  handle_mm_fault+0x186/0x360
[ 1576.060231]  ? handle_mm_fault+0x44/0x360
[ 1576.060236]  __do_page_fault+0x1da/0x510
[ 1576.060244]  do_page_fault+0x21/0x70
[ 1576.060249]  page_fault+0x22/0x30
[ 1576.060252] RIP: 0033:0x400923
[ 1576.060254] RSP: 002b:00007ffc83235ba0 EFLAGS: 00010287
[ 1576.060257] RAX: 0000000000003000 RBX: 0000000000000000 RCX: 00007f1b4da57c30
[ 1576.060259] RDX: 0000000000000001 RSI: 00007ffc83235bb0 RDI: 0000000000000003
[ 1576.060260] RBP: 0000000000000000 R08: 00007f1b4df40740 R09: 0000000000000000
[ 1576.060262] R10: 00007ffc83235920 R11: 0000000000000246 R12: 0000000000400954
[ 1576.060263] R13: 000000000212d010 R14: 0000000000000000 R15: 0000000000000000
[ 1576.060275] warn_alloc_show_mem: 9 callbacks suppressed
[ 1576.060277] Mem-Info:
[ 1576.060281] active_anon:843659 inactive_anon:3676 isolated_anon:0
[ 1576.060281]  active_file:0 inactive_file:0 isolated_file:0
[ 1576.060281]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 1576.060281]  slab_reclaimable:0 slab_unreclaimable:0
[ 1576.060281]  mapped:1853 shmem:4208 pagetables:10537 bounce:0
[ 1576.060281]  free:21425 free_pcp:60 free_cma:0
[ 1576.060284] Node 0 active_anon:3374636kB inactive_anon:14704kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:7412kB dirty:0kB writeback:0kB shmem:16832kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2762752kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[ 1576.060286] Node 0 DMA free:14776kB min:288kB low:360kB high:432kB active_anon:1092kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1576.060290] lowmem_reserve[]: 0 2688 3624 3624
[ 1576.060299] Node 0 DMA32 free:53544kB min:49908kB low:62384kB high:74860kB active_anon:2696692kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752816kB mlocked:0kB kernel_stack:32kB pagetables:164kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1576.060303] lowmem_reserve[]: 0 0 936 936
[ 1576.060311] Node 0 Normal free:17380kB min:17384kB low:21728kB high:26072kB active_anon:676852kB inactive_anon:14704kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:17584kB pagetables:41980kB bounce:0kB free_pcp:240kB local_pcp:0kB free_cma:0kB
[ 1576.060315] lowmem_reserve[]: 0 0 0 0
[ 1576.060323] Node 0 DMA: 2*4kB (UM) 2*8kB (UM) 2*16kB (UM) 2*32kB (UM) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14776kB
[ 1576.060357] Node 0 DMA32: 22*4kB (UM) 70*8kB (UM) 72*16kB (UM) 77*32kB (UM) 62*64kB (UM) 40*128kB (UM) 39*256kB (UM) 15*512kB (U) 20*1024kB (UM) 1*2048kB (U) 0*4096kB = 53544kB
[ 1576.060391] Node 0 Normal: 85*4kB (UMH) 128*8kB (UMH) 97*16kB (UMEH) 92*32kB (UMEH) 32*64kB (UEH) 32*128kB (UMEH) 21*256kB (UM) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 17380kB
[ 1576.060421] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 1576.060423] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1576.060425] 4210 total pagecache pages
[ 1576.060428] 0 pages in swap cache
[ 1576.060430] Swap cache stats: add 0, delete 0, find 0/0
[ 1576.060432] Free swap  = 0kB
[ 1576.060433] Total swap = 0kB
[ 1576.060435] 1048445 pages RAM
[ 1576.060437] 0 pages HighMem/MovableOnly
[ 1576.060438] 116548 pages reserved
[ 1576.060440] 0 pages hwpoisoned
(...snipped...)
[ 1576.168438] normal-priority: page allocation stalls for 720370ms, order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
[ 1576.168443] normal-priority cpuset=/ mems_allowed=0
[ 1576.168473] CPU: 0 PID: 6697 Comm: normal-priority Not tainted 4.12.0-next-20170714+ #632
[ 1576.168474] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1576.168475] Call Trace:
[ 1576.168479]  dump_stack+0x67/0x9e
[ 1576.168483]  warn_alloc+0x10f/0x1b0
[ 1576.168489]  ? wake_all_kswapds+0x56/0x96
[ 1576.168493]  __alloc_pages_nodemask+0xb2c/0xf50
[ 1576.168511]  alloc_pages_current+0x65/0xb0
[ 1576.168515]  __page_cache_alloc+0x10b/0x140
[ 1576.168519]  filemap_fault+0x3df/0x6a0
[ 1576.168521]  ? filemap_fault+0x2ab/0x6a0
[ 1576.168528]  xfs_filemap_fault+0x34/0x50
[ 1576.168531]  __do_fault+0x19/0x120
[ 1576.168535]  __handle_mm_fault+0xa5c/0x1160
[ 1576.168538]  ? native_sched_clock+0x36/0xa0
[ 1576.168549]  handle_mm_fault+0x186/0x360
[ 1576.168550]  ? handle_mm_fault+0x44/0x360
[ 1576.168554]  __do_page_fault+0x1da/0x510
[ 1576.168562]  do_page_fault+0x21/0x70
[ 1576.168566]  page_fault+0x22/0x30
[ 1576.168568] RIP: 0033:0x7f1b4dd39ced
[ 1576.168569] RSP: 002b:00007ffc832358e0 EFLAGS: 00010202
[ 1576.168571] RAX: 0000000000000204 RBX: 00007f1b4d972d18 RCX: 00000000000003f3
[ 1576.168572] RDX: 00007f1b4d971280 RSI: 0000000000000001 RDI: 00007f1b4df4f658
[ 1576.168573] RBP: 0000000000000001 R08: 000000000000003e R09: 00000000003bbe1a
[ 1576.168574] R10: 00007f1b4df524a8 R11: 00007ffc83235a20 R12: 0000000000000003
[ 1576.168575] R13: 000000000eef86be R14: 00007f1b4df4fb50 R15: 0000000000000000
[ 1576.928411] MemAlloc: 927 in-flight.
[ 1577.952567] MemAlloc: 927 in-flight.
[ 1578.976001] MemAlloc: 927 in-flight.
[ 1580.000154] MemAlloc: 927 in-flight.
[ 1580.003790] sysrq: SysRq : Kill All Tasks
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
