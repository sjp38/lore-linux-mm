Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id B04F06B06EF
	for <linux-mm@kvack.org>; Sat, 12 May 2018 10:18:48 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id e32-v6so8206940ote.23
        for <linux-mm@kvack.org>; Sat, 12 May 2018 07:18:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s186-v6si1669491oia.209.2018.05.12.07.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 May 2018 07:18:45 -0700 (PDT)
Subject: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201805122318.HJG81246.MFVFLFJOOQtSHO@I-love.SAKURA.ne.jp>
Date: Sat, 12 May 2018 23:18:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, rientjes@google.com
Cc: guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

OK. Since "mm, oom: fix concurrent munlock and oom reaper unmap, v3" went to
linux.git as 27ae357fa82be5ab, it is time to resume this patch. I do hope that
you don't ignore me again...

Here is the reproducer of OOM lockup.
Note that I'm not using hundreds of concurrent memory allocating threads.

------------------------------------------------------------
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
#include <sys/time.h>
#include <sys/resource.h>

int main(int argc, char *argv[])
{
	struct sched_param sp = { 0 };
	cpu_set_t cpu = { { 1 } };
	static int pipe_fd[2] = { EOF, EOF };
	char *buf = NULL;
	unsigned long size = 0;
	unsigned int i;
	const int fd = open("/dev/zero", O_RDONLY);
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
	for (i = 0; i < 32; i++)
		if (fork() == 0) {
			char c;
			buf = malloc(1048576);
			/* Wait until the first-victim is OOM-killed. */
			read(pipe_fd[0], &c, 1);
			/* Try to consume as much CPU time as possible. */
			read(fd, buf, 1048576);
			pause();
			_exit(0);
		}
	close(pipe_fd[0]);
	sleep(1);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sched_setscheduler(0, SCHED_IDLE, &sp);
	setpriority(PRIO_PROCESS, 0, 19);
	prctl(PR_SET_NAME, (unsigned long) "idle-priority", 0, 0, 0);
	while (size) {
		int ret = read(fd, buf, size); /* Will cause OOM due to overcommit */
		if (ret <= 0)
			break;
		buf += ret;
		size -= ret;
	}
	return 0; /* Not reached. */
}
------------------------------------------------------------

And the output is shown below.
(Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20180512.txt.xz and
kernel config is at http://I-love.SAKURA.ne.jp/tmp/config-4.17-rc4 .)

------------------------------------------------------------
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
------------------------------------------------------------

------------------------------------------------------------
[  243.867497] idle-priority invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[  243.870958] idle-priority cpuset=/ mems_allowed=0
[  243.873757] CPU: 0 PID: 8151 Comm: idle-priority Kdump: loaded Not tainted 4.17.0-rc4+ #400
[  243.876647] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  243.879890] Call Trace:
[  243.881396]  dump_stack+0x5e/0x8b
[  243.883068]  dump_header+0x6f/0x454
[  243.884778]  ? _raw_spin_unlock_irqrestore+0x2d/0x50
[  243.886770]  ? trace_hardirqs_on_caller+0xed/0x1a0
[  243.888952]  oom_kill_process+0x223/0x6a0
[  243.890942]  ? out_of_memory+0x26f/0x550
[  243.892909]  out_of_memory+0x120/0x550
[  243.894692]  ? out_of_memory+0x1f7/0x550
[  243.896535]  __alloc_pages_nodemask+0xc98/0xdd0
[  243.898465]  alloc_pages_vma+0x6e/0x1a0
[  243.900170]  __handle_mm_fault+0xe27/0x1380
[  243.902152]  handle_mm_fault+0x1b7/0x370
[  243.904047]  ? handle_mm_fault+0x41/0x370
[  243.905792]  __do_page_fault+0x1e9/0x510
[  243.907513]  do_page_fault+0x1b/0x60
[  243.909105]  ? page_fault+0x8/0x30
[  243.910777]  page_fault+0x1e/0x30
[  243.912331] RIP: 0010:__clear_user+0x38/0x60
[  243.913957] RSP: 0018:ffffc90001ebfdd8 EFLAGS: 00010202
[  243.915761] RAX: 0000000000000000 RBX: 0000000000000200 RCX: 0000000000000002
[  243.917941] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00007f5984db9000
[  243.920078] RBP: 00007f5984db8010 R08: 0000000000000000 R09: 0000000000000000
[  243.922276] R10: 0000000000000000 R11: 0000000000000000 R12: ffffc90001ebfe68
[  243.924366] R13: 0000000053969000 R14: 0000000000001000 R15: 0000000000000000
[  243.926556]  ? __clear_user+0x19/0x60
[  243.927942]  iov_iter_zero+0x77/0x360
[  243.929437]  read_iter_zero+0x32/0xa0
[  243.930793]  __vfs_read+0xc0/0x120
[  243.932052]  vfs_read+0x94/0x140
[  243.933293]  ksys_read+0x40/0xa0
[  243.934453]  ? do_syscall_64+0x17/0x1f0
[  243.935773]  do_syscall_64+0x4f/0x1f0
[  243.937034]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  243.939054] RIP: 0033:0x7f5ab134bc70
[  243.940471] RSP: 002b:00007ffc78de8548 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
[  243.943037] RAX: ffffffffffffffda RBX: 0000000080001000 RCX: 00007f5ab134bc70
[  243.945421] RDX: 0000000080001000 RSI: 00007f593144f010 RDI: 0000000000000003
[  243.947500] RBP: 00007f593144f010 R08: 0000000000000000 R09: 0000000000021000
[  243.949567] R10: 00007ffc78de7fa0 R11: 0000000000000246 R12: 0000000000000003
[  243.951747] R13: 00007f58b1450010 R14: 0000000000000006 R15: 0000000000000000
[  243.953949] Mem-Info:
[  243.955039] active_anon:877880 inactive_anon:2117 isolated_anon:0
[  243.955039]  active_file:17 inactive_file:19 isolated_file:0
[  243.955039]  unevictable:0 dirty:0 writeback:0 unstable:0
[  243.955039]  slab_reclaimable:3696 slab_unreclaimable:14669
[  243.955039]  mapped:892 shmem:2199 pagetables:3619 bounce:0
[  243.955039]  free:21271 free_pcp:70 free_cma:0
[  243.964871] Node 0 active_anon:3511520kB inactive_anon:8468kB active_file:68kB inactive_file:76kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3568kB dirty:0kB writeback:0kB shmem:8796kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 3284992kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  243.971819] Node 0 DMA free:14804kB min:284kB low:352kB high:420kB active_anon:1064kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  243.979206] lowmem_reserve[]: 0 2683 3633 3633
[  243.980835] Node 0 DMA32 free:53012kB min:49696kB low:62120kB high:74544kB active_anon:2693220kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2748024kB mlocked:0kB kernel_stack:16kB pagetables:204kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  243.987955] lowmem_reserve[]: 0 0 950 950
[  243.989471] Node 0 Normal free:17268kB min:17596kB low:21992kB high:26388kB active_anon:817296kB inactive_anon:8468kB active_file:68kB inactive_file:76kB unevictable:0kB writepending:0kB present:1048576kB managed:972972kB mlocked:0kB kernel_stack:4096kB pagetables:14268kB bounce:0kB free_pcp:280kB local_pcp:120kB free_cma:0kB
[  243.998191] lowmem_reserve[]: 0 0 0 0
[  243.999773] Node 0 DMA: 1*4kB (U) 2*8kB (UM) 2*16kB (UM) 1*32kB (U) 2*64kB (UM) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (M) = 14804kB
[  244.004513] Node 0 DMA32: 9*4kB (UM) 12*8kB (U) 17*16kB (UME) 14*32kB (UE) 9*64kB (UE) 7*128kB (UME) 8*256kB (UME) 9*512kB (UME) 7*1024kB (UME) 2*2048kB (ME) 8*4096kB (UM) = 53012kB
[  244.009711] Node 0 Normal: 181*4kB (UM) 7*8kB (UM) 55*16kB (UME) 95*32kB (UME) 33*64kB (UME) 12*128kB (UE) 3*256kB (UE) 0*512kB 8*1024kB (UM) 0*2048kB 0*4096kB = 17308kB
[  244.014831] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  244.017675] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  244.020366] 2245 total pagecache pages
[  244.022137] 0 pages in swap cache
[  244.023758] Swap cache stats: add 0, delete 0, find 0/0
[  244.026300] Free swap  = 0kB
[  244.029023] Total swap = 0kB
[  244.030598] 1048445 pages RAM
[  244.032541] 0 pages HighMem/MovableOnly
[  244.034382] 114220 pages reserved
[  244.036039] 0 pages hwpoisoned
[  244.038042] Out of memory: Kill process 8151 (idle-priority) score 929 or sacrifice child
[  244.041499] Killed process 8157 (normal-priority) total-vm:5248kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  302.561100] INFO: task oom_reaper:40 blocked for more than 30 seconds.
[  302.563687]       Not tainted 4.17.0-rc4+ #400
[  302.565635] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  302.568355] oom_reaper      D14408    40      2 0x80000000
[  302.570616] Call Trace:
[  302.572154]  ? __schedule+0x227/0x780
[  302.573923]  ? __mutex_lock+0x289/0x8d0
[  302.575725]  schedule+0x34/0x80
[  302.577381]  schedule_preempt_disabled+0xc/0x20
[  302.579334]  __mutex_lock+0x28e/0x8d0
[  302.581136]  ? __mutex_lock+0xb6/0x8d0
[  302.582929]  ? find_held_lock+0x2d/0x90
[  302.584809]  ? oom_reaper+0x9f/0x270
[  302.586534]  oom_reaper+0x9f/0x270
[  302.588214]  ? wait_woken+0x90/0x90
[  302.589909]  kthread+0xf6/0x130
[  302.591585]  ? __oom_reap_task_mm+0x90/0x90
[  302.593430]  ? kthread_create_on_node+0x40/0x40
[  302.595341]  ret_from_fork+0x24/0x30
[  302.597127] INFO: task normal-priority:8157 blocked for more than 30 seconds.
[  302.599634]       Not tainted 4.17.0-rc4+ #400
[  302.601492] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  302.604047] normal-priority D13752  8157   8151 0x80100084
[  302.606052] Call Trace:
[  302.607385]  ? __schedule+0x227/0x780
[  302.608951]  ? __mutex_lock+0x289/0x8d0
[  302.610533]  schedule+0x34/0x80
[  302.611932]  schedule_preempt_disabled+0xc/0x20
[  302.613647]  __mutex_lock+0x28e/0x8d0
[  302.615144]  ? __mutex_lock+0xb6/0x8d0
[  302.616637]  ? __lock_acquire+0x22a/0x1830
[  302.618183]  ? exit_mmap+0x126/0x160
[  302.619591]  exit_mmap+0x126/0x160
[  302.620917]  ? do_exit+0x261/0xb80
[  302.622213]  ? find_held_lock+0x2d/0x90
[  302.623581]  mmput+0x63/0x130
[  302.624757]  do_exit+0x297/0xb80
[  302.625984]  do_group_exit+0x41/0xc0
[  302.627281]  get_signal+0x22a/0x810
[  302.628546]  do_signal+0x1e/0x600
[  302.629792]  exit_to_usermode_loop+0x34/0x6c
[  302.631302]  ? page_fault+0x8/0x30
[  302.632650]  prepare_exit_to_usermode+0xd4/0xe0
[  302.634163]  retint_user+0x8/0x18
[  302.635432] RIP: 0033:0x7f5ab134bc70
[  302.636725] RSP: 002b:00007ffc78de8548 EFLAGS: 00010246
[  302.638378] RAX: 0000000000000000 RBX: 00007f5ab1736010 RCX: 00007f5ab134bc70
[  302.640435] RDX: 0000000000000001 RSI: 00007ffc78de855f RDI: 0000000000000004
[  302.642487] RBP: 0000000000000000 R08: ffffffffffffffff R09: 0000000000100000
[  302.644531] R10: 00007ffc78de7fa0 R11: 0000000000000246 R12: 0000000000000003
[  302.646556] R13: 00007ffc78de86f0 R14: 0000000000000000 R15: 0000000000000000
[  302.648593] 
[  302.648593] Showing all locks held in the system:
[  302.650828] 2 locks held by kworker/0:1/37:
[  302.652320]  #0: 00000000528edd68 ((wq_completion)"events_freezable_power_efficient"){+.+.}, at: process_one_work+0x13c/0x380
[  302.655297]  #1: 00000000b1d2489c ((work_completion)(&(&ev->dwork)->work)){+.+.}, at: process_one_work+0x13c/0x380
[  302.658072] 1 lock held by khungtaskd/39:
[  302.659459]  #0: 00000000bfc6260d (tasklist_lock){.+.+}, at: debug_show_all_locks+0x39/0x1b0
[  302.661844] 1 lock held by oom_reaper/40:
[  302.663369]  #0: 000000005eee3cbe (oom_lock){+.+.}, at: oom_reaper+0x9f/0x270
[  302.665725] 2 locks held by agetty/3801:
[  302.667189]  #0: 00000000c0409157 (&tty->ldisc_sem){++++}, at: tty_ldisc_ref_wait+0x1f/0x50
[  302.669604]  #1: 000000008d7198da (&ldata->atomic_read_lock){+.+.}, at: n_tty_read+0xc0/0x8a0
[  302.672054] 2 locks held by smbd-notifyd/3898:
[  302.673621]  #0: 00000000c0fc1118 (&mm->mmap_sem){++++}, at: __do_page_fault+0x133/0x510
[  302.675991]  #1: 00000000ebb6be0a (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0xae/0xc0
[  302.678482] 2 locks held by cleanupd/3899:
[  302.679976]  #0: 0000000073a8b85a (&mm->mmap_sem){++++}, at: __do_page_fault+0x133/0x510
[  302.682363]  #1: 00000000ebb6be0a (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0xae/0xc0
[  302.684866] 1 lock held by normal-priority/8157:
[  302.686517]  #0: 000000005eee3cbe (oom_lock){+.+.}, at: exit_mmap+0x126/0x160
[  302.688718] 2 locks held by normal-priority/8161:
[  302.690368]  #0: 000000007b02f050 (&mm->mmap_sem){++++}, at: __do_page_fault+0x133/0x510
[  302.692779]  #1: 00000000ebb6be0a (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0xae/0xc0
[  302.695312] 2 locks held by normal-priority/8162:
[  302.696985]  #0: 00000000cdede75e (&mm->mmap_sem){++++}, at: __do_page_fault+0x133/0x510
[  302.699427]  #1: 00000000ebb6be0a (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0xae/0xc0
[  302.702004] 2 locks held by normal-priority/8165:
[  302.703721]  #0: 00000000cf5d7878 (&mm->mmap_sem){++++}, at: __do_page_fault+0x133/0x510
[  302.706198]  #1: 00000000ebb6be0a (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0xae/0xc0
[  302.708788] 2 locks held by normal-priority/8166:
[  302.710531]  #0: 00000000069df873 (&mm->mmap_sem){++++}, at: __do_page_fault+0x133/0x510
[  302.713031]  #1: 00000000ebb6be0a (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0xae/0xc0
[  302.715646] 2 locks held by normal-priority/8169:
[  302.717416]  #0: 00000000d218c9a8 (&mm->mmap_sem){++++}, at: __do_page_fault+0x133/0x510
[  302.719950]  #1: 00000000ebb6be0a (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0xae/0xc0
[  302.722641] 2 locks held by normal-priority/8170:
[  302.724434]  #0: 00000000a5a3283b (&mm->mmap_sem){++++}, at: __do_page_fault+0x133/0x510
[  302.726964]  #1: 00000000ebb6be0a (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0xae/0xc0
[  302.729618] 2 locks held by normal-priority/8176:
[  302.731468]  #0: 0000000036591c0b (&mm->mmap_sem){++++}, at: __do_page_fault+0x133/0x510
[  302.734075]  #1: 00000000ebb6be0a (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0xae/0xc0
[  302.736790] 2 locks held by normal-priority/8181:
[  302.738656]  #0: 0000000017fa21f0 (&mm->mmap_sem){++++}, at: __do_page_fault+0x133/0x510
[  302.741282]  #1: 00000000ebb6be0a (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0xae/0xc0
[  302.745176] 2 locks held by normal-priority/8182:
[  302.747556]  #0: 0000000048a6d0b7 (&mm->mmap_sem){++++}, at: __do_page_fault+0x133/0x510
[  302.750392]  #1: 00000000ebb6be0a (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0xae/0xc0
[  302.754698] 
[  302.755948] =============================================
(...snipped...)
[  399.139454] idle-priority   R  running task    12264  8151   4971 0x00000080
[  399.141499] Call Trace:
[  399.142539]  ? __schedule+0x227/0x780
[  399.143831]  schedule+0x34/0x80
[  399.144998]  schedule_timeout+0x196/0x390
[  399.146372]  ? collect_expired_timers+0xb0/0xb0
[  399.147933]  out_of_memory+0x12a/0x550
[  399.149230]  ? out_of_memory+0x1f7/0x550
[  399.150563]  __alloc_pages_nodemask+0xc98/0xdd0
[  399.152034]  alloc_pages_vma+0x6e/0x1a0
[  399.153350]  __handle_mm_fault+0xe27/0x1380
[  399.154735]  handle_mm_fault+0x1b7/0x370
[  399.156064]  ? handle_mm_fault+0x41/0x370
[  399.157406]  __do_page_fault+0x1e9/0x510
[  399.158740]  do_page_fault+0x1b/0x60
[  399.159985]  ? page_fault+0x8/0x30
[  399.161183]  page_fault+0x1e/0x30
[  399.162354] RIP: 0010:__clear_user+0x38/0x60
[  399.163814] RSP: 0018:ffffc90001ebfdd8 EFLAGS: 00010202
[  399.165399] RAX: 0000000000000000 RBX: 0000000000000200 RCX: 0000000000000002
[  399.167389] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00007f5984db9000
[  399.169369] RBP: 00007f5984db8010 R08: 0000000000000000 R09: 0000000000000000
[  399.171361] R10: 0000000000000000 R11: 0000000000000000 R12: ffffc90001ebfe68
[  399.173358] R13: 0000000053969000 R14: 0000000000001000 R15: 0000000000000000
[  399.175353]  ? __clear_user+0x19/0x60
[  399.176616]  iov_iter_zero+0x77/0x360
[  399.177871]  read_iter_zero+0x32/0xa0
[  399.179131]  __vfs_read+0xc0/0x120
[  399.180377]  vfs_read+0x94/0x140
[  399.181549]  ksys_read+0x40/0xa0
[  399.182723]  ? do_syscall_64+0x17/0x1f0
[  399.184025]  do_syscall_64+0x4f/0x1f0
[  399.185291]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
(...snipped...)
[  481.033433] idle-priority   R  running task    12264  8151   4971 0x00000080
[  481.033433] Call Trace:
[  481.033433]  ? __schedule+0x227/0x780
[  481.033433]  schedule+0x34/0x80
[  481.033433]  schedule_timeout+0x196/0x390
[  481.033433]  ? collect_expired_timers+0xb0/0xb0
[  481.033433]  out_of_memory+0x12a/0x550
[  481.033433]  ? out_of_memory+0x1f7/0x550
[  481.033433]  __alloc_pages_nodemask+0xc98/0xdd0
[  481.033433]  alloc_pages_vma+0x6e/0x1a0
[  481.033433]  __handle_mm_fault+0xe27/0x1380
[  481.033433]  handle_mm_fault+0x1b7/0x370
[  481.033433]  ? handle_mm_fault+0x41/0x370
[  481.033433]  __do_page_fault+0x1e9/0x510
[  481.033433]  do_page_fault+0x1b/0x60
[  481.033433]  ? page_fault+0x8/0x30
[  481.033433]  page_fault+0x1e/0x30
[  481.033433] RIP: 0010:__clear_user+0x38/0x60
[  481.033433] RSP: 0018:ffffc90001ebfdd8 EFLAGS: 00010202
[  481.033433] RAX: 0000000000000000 RBX: 0000000000000200 RCX: 0000000000000002
[  481.033433] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00007f5984db9000
[  481.033433] RBP: 00007f5984db8010 R08: 0000000000000000 R09: 0000000000000000
[  481.033433] R10: 0000000000000000 R11: 0000000000000000 R12: ffffc90001ebfe68
[  481.033433] R13: 0000000053969000 R14: 0000000000001000 R15: 0000000000000000
[  481.033433]  ? __clear_user+0x19/0x60
[  481.033433]  iov_iter_zero+0x77/0x360
[  481.033433]  read_iter_zero+0x32/0xa0
[  481.033433]  __vfs_read+0xc0/0x120
[  481.033433]  vfs_read+0x94/0x140
[  481.033433]  ksys_read+0x40/0xa0
[  481.033433]  ? do_syscall_64+0x17/0x1f0
[  481.033433]  do_syscall_64+0x4f/0x1f0
[  481.033433]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
------------------------------------------------------------

Once a thread which called out_of_memory() started sleeping at schedule_timeout_killable(1)
with oom_lock held, 32 concurrent direct reclaiming threads on the same CPU are sufficient
to trigger the OOM lockup. With below patch applied, every trial completes within 5 seconds.



>From 4b356c742a3f1b720d5b709792fe68b25d800902 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 12 May 2018 12:27:52 +0900
Subject: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.

When I was examining a bug which occurs under CPU + memory pressure, I
observed that a thread which called out_of_memory() can sleep for minutes
at schedule_timeout_killable(1) with oom_lock held when many threads are
doing direct reclaim.

The whole point of the sleep is give the OOM victim some time to exit.
But since commit 27ae357fa82be5ab ("mm, oom: fix concurrent munlock and
oom reaper unmap, v3") changed the OOM victim to wait for oom_lock in order
to close race window at exit_mmap(), the whole point of this sleep is lost
now. We need to make sure that the thread which called out_of_memory() will
release oom_lock shortly. Therefore, this patch brings the sleep to outside
of the OOM path.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/oom_kill.c   | 38 +++++++++++++++++---------------------
 mm/page_alloc.c |  7 ++++++-
 2 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8ba6cb8..23ce67f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -479,6 +479,21 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
+/*
+ * We have to make sure not to cause premature new oom victim selection.
+ *
+ * __alloc_pages_may_oom()     oom_reap_task_mm()/exit_mmap()
+ *   mutex_trylock(&oom_lock)
+ *   get_page_from_freelist(ALLOC_WMARK_HIGH) # fails
+ *                               unmap_page_range() # frees some memory
+ *                               set_bit(MMF_OOM_SKIP)
+ *   out_of_memory()
+ *     select_bad_process()
+ *       test_bit(MMF_OOM_SKIP) # selects new oom victim
+ *   mutex_unlock(&oom_lock)
+ *
+ * Therefore, the callers hold oom_lock when calling this function.
+ */
 void __oom_reap_task_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
@@ -523,20 +538,6 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	bool ret = true;
 
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * oom_reap_task_mm		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
-	 */
 	mutex_lock(&oom_lock);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
@@ -1077,15 +1078,9 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (oc->chosen && oc->chosen != (void *)-1UL) {
+	if (oc->chosen && oc->chosen != (void *)-1UL)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
 				 "Memory cgroup out of memory");
-		/*
-		 * Give the killed process a good chance to exit before trying
-		 * to allocate memory again.
-		 */
-		schedule_timeout_killable(1);
-	}
 	return !!oc->chosen;
 }
 
@@ -1111,4 +1106,5 @@ void pagefault_out_of_memory(void)
 		return;
 	out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
+	schedule_timeout_killable(1);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905db9d..458ed32 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3478,7 +3478,6 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	 */
 	if (!mutex_trylock(&oom_lock)) {
 		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
 
@@ -4241,6 +4240,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;
+		/*
+		 * This schedule_timeout_*() serves as a guaranteed sleep for
+		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
+		 */
+		if (!tsk_is_oom_victim(current))
+			schedule_timeout_uninterruptible(1);
 		goto retry;
 	}
 
-- 
1.8.3.1
