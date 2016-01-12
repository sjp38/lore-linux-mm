Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5D74403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 06:32:37 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id q21so380224977iod.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 03:32:37 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d8si32682546igz.69.2016.01.12.03.32.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jan 2016 03:32:36 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160107091512.GB27868@dhcp22.suse.cz>
	<201601072231.DGG78695.OOFVLHJFFQOStM@I-love.SAKURA.ne.jp>
	<20160107145841.GN27868@dhcp22.suse.cz>
	<201601080038.CIF04698.VFJHSOQLOFFMOt@I-love.SAKURA.ne.jp>
	<20160111151835.GH27317@dhcp22.suse.cz>
In-Reply-To: <20160111151835.GH27317@dhcp22.suse.cz>
Message-Id: <201601122032.FHH13586.MOQVFFOJStFHOL@I-love.SAKURA.ne.jp>
Date: Tue, 12 Jan 2016 20:32:18 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 08-01-16 00:38:43, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > @@ -333,6 +333,14 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
> > >  		if (points == chosen_points && thread_group_leader(chosen))
> > >  			continue;
> > >  
> > > +		/*
> > > +		 * If the current major task is already ooom killed and this
> > > +		 * is sysrq+f request then we rather choose somebody else
> > > +		 * because the current oom victim might be stuck.
> > > +		 */
> > > +		if (is_sysrq_oom(sc) && test_tsk_thread_flag(p, TIF_MEMDIE))
> > > +			continue;
> > > +
> > >  		chosen = p;
> > >  		chosen_points = points;
> > >  	}
> > 
> > Do we want to require SysRq-f for each thread in a process?
> > If g has 1024 p, dump_tasks() will do
> > 
> >   pr_info("[%5d] %5d %5d %8lu %8lu %7ld %7ld %8lu         %5hd %s\n",
> > 
> > for 1024 times? I think one SysRq-f per one process is sufficient.
> 
> I am not following you here. If we kill the process the whole process
> group (aka all threads) will get killed which ever thread we happen to
> send the sigkill to.

Please distinguish "sending SIGKILL to a process" and "all threads in that
process terminate". do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true)
sends SIGKILL to a victim process, but it does not guarantee that all
threads in that process terminate even if the OOM reaper reclaimed memory.
That's when SysRq-f (and timeout based next victim selection) is needed
but currently SysRq-f forever continues selecting incorrect process.

I can observe SysRq-f is disabled
(Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160112.txt.xz .)
----------
[   86.767482] a.out invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO)
[   86.769905] a.out cpuset=/ mems_allowed=0
[   86.771393] CPU: 2 PID: 9573 Comm: a.out Not tainted 4.4.0-next-20160112+ #279
(...snipped...)
[   86.874710] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
(...snipped...)
[   86.945286] [ 9573]  1000  9573   541717   402522     796       6        0             0 a.out
[   86.947457] [ 9574]  1000  9574     1078       21       7       3        0             0 a.out
[   86.949568] Out of memory: Kill process 9573 (a.out) score 908 or sacrifice child
[   86.951538] Killed process 9574 (a.out) total-vm:4312kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[   86.955296] systemd-journal invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|GFP_COLD)
[   86.958035] systemd-journal cpuset=/ mems_allowed=0
(...snipped...)
[   87.128808] [ 9573]  1000  9573   541717   402522     796       6        0             0 a.out
[   87.130926] [ 9575]  1000  9574     1078        0       7       3        0             0 a.out
[   87.133055] Out of memory: Kill process 9573 (a.out) score 908 or sacrifice child
[   87.134989] Killed process 9575 (a.out) total-vm:4312kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  116.979564] sysrq: SysRq : Manual OOM execution
[  116.984119] kworker/0:8 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
[  116.986367] kworker/0:8 cpuset=/ mems_allowed=0
(...snipped...)
[  117.157045] [ 9573]  1000  9573   541717   402522     797       6        0             0 a.out
[  117.159191] [ 9575]  1000  9574     1078        0       7       3        0             0 a.out
[  117.161302] Out of memory: Kill process 9573 (a.out) score 908 or sacrifice child
[  117.163250] Killed process 9575 (a.out) total-vm:4312kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  119.043685] sysrq: SysRq : Manual OOM execution
[  119.046239] kworker/0:8 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
[  119.048453] kworker/0:8 cpuset=/ mems_allowed=0
(...snipped...)
[  119.215982] [ 9573]  1000  9573   541717   402522     797       6        0             0 a.out
[  119.218122] [ 9575]  1000  9574     1078        0       7       3        0             0 a.out
[  119.220237] Out of memory: Kill process 9573 (a.out) score 908 or sacrifice child
[  119.222129] Killed process 9575 (a.out) total-vm:4312kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  120.179644] sysrq: SysRq : Manual OOM execution
[  120.206938] kworker/0:8 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
[  120.209152] kworker/0:8 cpuset=/ mems_allowed=0
(...snipped...)
[  120.376821] [ 9573]  1000  9573   541717   402522     797       6        0             0 a.out
[  120.378924] [ 9575]  1000  9574     1078        0       7       3        0             0 a.out
[  120.381065] Out of memory: Kill process 9573 (a.out) score 908 or sacrifice child
[  120.382929] Killed process 9575 (a.out) total-vm:4312kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  121.235296] sysrq: SysRq : Manual OOM execution
[  121.252742] kworker/0:8 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
[  121.254955] kworker/0:8 cpuset=/ mems_allowed=0
(...snipped...)
[  141.024984] a.out           D ffff88007c417948     0  9573   8117 0x00000080
[  141.026830]  ffff88007c417948 ffff880076cac2c0 ffff880076c442c0 ffff88007c418000
[  141.028789]  ffff88007c417980 ffff88007fc90240 00000000fffd7aa1 00000000000006bc
[  141.030746]  ffff88007c417960 ffffffff816fc1a7 ffff88007fc90240 ffff88007c417a08
[  141.032703] Call Trace:
[  141.033653]  [<ffffffff816fc1a7>] schedule+0x37/0x90
[  141.035056]  [<ffffffff81700567>] schedule_timeout+0x117/0x1c0
[  141.036629]  [<ffffffff810e1310>] ? init_timer_key+0x40/0x40
[  141.038182]  [<ffffffff81700694>] schedule_timeout_uninterruptible+0x24/0x30
[  141.039963]  [<ffffffff8114944b>] __alloc_pages_nodemask+0x91b/0xd90
[  141.041631]  [<ffffffff811925e6>] alloc_pages_vma+0xb6/0x290
[  141.043173]  [<ffffffff811711d0>] handle_mm_fault+0x1180/0x1630
[  141.044770]  [<ffffffff811700a4>] ? handle_mm_fault+0x54/0x1630
[  141.046355]  [<ffffffff8105a651>] __do_page_fault+0x1a1/0x440
[  141.047915]  [<ffffffff8105a920>] do_page_fault+0x30/0x80
[  141.049408]  [<ffffffff81702307>] ? native_iret+0x7/0x7
[  141.050876]  [<ffffffff817033e8>] page_fault+0x28/0x30
[  141.052327]  [<ffffffff813a6f3d>] ? __clear_user+0x3d/0x70
[  141.053831]  [<ffffffff813ab9e8>] iov_iter_zero+0x68/0x250
[  141.055346]  [<ffffffff814866a8>] read_iter_zero+0x38/0xb0
[  141.056854]  [<ffffffff811c0994>] __vfs_read+0xc4/0xf0
[  141.058295]  [<ffffffff811c154a>] vfs_read+0x7a/0x120
[  141.059711]  [<ffffffff811c1df3>] SyS_read+0x53/0xd0
[  141.061104]  [<ffffffff81701772>] entry_SYSCALL_64_fastpath+0x12/0x76
[  141.062768] a.out           x ffff88007b92fca0     0  9574   9573 0x00000084
[  141.064604]  ffff88007b92fca0 ffff880076cac2c0 ffff88007a862c80 ffff88007b930000
[  141.066555]  ffff88007a863040 ffff88007a863308 ffff88007a862c80 ffff88007cc10000
[  141.068492]  ffff88007b92fcb8 ffffffff816fc1a7 ffff88007a863308 ffff88007b92fd28
[  141.070437] Call Trace:
[  141.071389]  [<ffffffff816fc1a7>] schedule+0x37/0x90
[  141.072788]  [<ffffffff810733fe>] do_exit+0x6be/0xb50
[  141.074198]  [<ffffffff81073917>] do_group_exit+0x47/0xc0
[  141.075676]  [<ffffffff8107f122>] get_signal+0x222/0x7e0
[  141.077135]  [<ffffffff8100f232>] do_signal+0x32/0x6d0
[  141.078570]  [<ffffffff81095cc8>] ? finish_task_switch+0xa8/0x2b0
[  141.080176]  [<ffffffff8106b967>] ? syscall_slow_exit_work+0x4b/0x10d
[  141.081837]  [<ffffffff81095cc8>] ? finish_task_switch+0xa8/0x2b0
[  141.083441]  [<ffffffff8106b8ba>] ? exit_to_usermode_loop+0x2e/0x90
[  141.085063]  [<ffffffff8106b8d8>] exit_to_usermode_loop+0x4c/0x90
[  141.086667]  [<ffffffff8100355b>] syscall_return_slowpath+0xbb/0x130
[  141.088305]  [<ffffffff817018da>] int_ret_from_sys_call+0x25/0x9f
[  141.089896] a.out           D ffff88007be2fab8     0  9575   9573 0x00100084
[  141.091734]  ffff88007be2fab8 ffff880036509640 ffff8800366742c0 ffff88007be30000
[  141.093688]  0000000000000000 7fffffffffffffff ffff88007ff72cb8 ffffffff816fca00
[  141.095743]  ffff88007be2fad0 ffffffff816fc1a7 ffff88007fc17280 ffff88007be2fb70
[  141.097699] Call Trace:
[  141.098649]  [<ffffffff816fca00>] ? bit_wait+0x60/0x60
[  141.100071]  [<ffffffff816fc1a7>] schedule+0x37/0x90
[  141.101453]  [<ffffffff817005c8>] schedule_timeout+0x178/0x1c0
[  141.103001]  [<ffffffff810e81e2>] ? ktime_get+0x102/0x130
[  141.104468]  [<ffffffff810bdfd9>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  141.106158]  [<ffffffff810be0ad>] ? trace_hardirqs_on+0xd/0x10
[  141.107698]  [<ffffffff810e8187>] ? ktime_get+0xa7/0x130
[  141.109138]  [<ffffffff811276ea>] ? __delayacct_blkio_start+0x1a/0x30
[  141.110782]  [<ffffffff816fb641>] io_schedule_timeout+0xa1/0x110
[  141.112350]  [<ffffffff816fca16>] bit_wait_io+0x16/0x70
[  141.113774]  [<ffffffff816fc62b>] __wait_on_bit+0x5b/0x90
[  141.115234]  [<ffffffff8113f83a>] ? find_get_pages_tag+0x19a/0x2c0
[  141.116824]  [<ffffffff8113e5c6>] wait_on_page_bit+0xc6/0xf0
[  141.118319]  [<ffffffff810b5830>] ? autoremove_wake_function+0x30/0x30
[  141.119983]  [<ffffffff8113e797>] __filemap_fdatawait_range+0x107/0x190
[  141.121643]  [<ffffffff81140a8c>] ? __filemap_fdatawrite_range+0xcc/0x100
[  141.123352]  [<ffffffff8113e82f>] filemap_fdatawait_range+0xf/0x30
[  141.124955]  [<ffffffff81140bad>] filemap_write_and_wait_range+0x3d/0x60
[  141.126655]  [<ffffffff812b2614>] xfs_file_fsync+0x44/0x180
[  141.128149]  [<ffffffff811f482b>] vfs_fsync_range+0x3b/0xb0
[  141.129646]  [<ffffffff812b4242>] xfs_file_write_iter+0x102/0x140
[  141.131260]  [<ffffffff811c0a87>] __vfs_write+0xc7/0x100
[  141.132702]  [<ffffffff811c168d>] vfs_write+0x9d/0x190
[  141.134108]  [<ffffffff811e104a>] ? __fget_light+0x6a/0x90
[  141.135593]  [<ffffffff811c1ec3>] SyS_write+0x53/0xd0
[  141.136998]  [<ffffffff81701772>] entry_SYSCALL_64_fastpath+0x12/0x76
[  141.138646] a.out           D ffff88007af4fce8     0  9576   9573 0x00000084
[  141.140490]  ffff88007af4fce8 ffff8800366742c0 ffff880036672c80 ffff88007af50000
[  141.142415]  ffff88007d14a5b0 ffff880036672c80 0000000000000246 00000000ffffffff
[  141.144331]  ffff88007af4fd00 ffffffff816fc1a7 ffff88007d14a5a8 ffff88007af4fd10
[  141.146308] Call Trace:
[  141.147261]  [<ffffffff816fc1a7>] schedule+0x37/0x90
[  141.148651]  [<ffffffff816fc4d0>] schedule_preempt_disabled+0x10/0x20
[  141.150326]  [<ffffffff816fd31b>] mutex_lock_nested+0x17b/0x3e0
[  141.151902]  [<ffffffff812b3faf>] ? xfs_file_buffered_aio_write+0x5f/0x1f0
[  141.153647]  [<ffffffff812b3faf>] xfs_file_buffered_aio_write+0x5f/0x1f0
[  141.155397]  [<ffffffff812b41c4>] xfs_file_write_iter+0x84/0x140
[  141.156989]  [<ffffffff811c0a87>] __vfs_write+0xc7/0x100
[  141.158460]  [<ffffffff811c168d>] vfs_write+0x9d/0x190
[  141.159933]  [<ffffffff811e104a>] ? __fget_light+0x6a/0x90
[  141.161417]  [<ffffffff811c1ec3>] SyS_write+0x53/0xd0
[  141.162853]  [<ffffffff81701772>] entry_SYSCALL_64_fastpath+0x12/0x76
(...snipped...)
[  181.154922] [ 9573]  1000  9573   541717   402522     797       6        0             0 a.out
[  181.157145] [ 9575]  1000  9574     1078        0       7       3        0             0 a.out
[  181.159265] Out of memory: Kill process 9573 (a.out) score 908 or sacrifice child
[  181.161160] Killed process 9575 (a.out) total-vm:4312kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  184.227075] sysrq: SysRq : Kill All Tasks
----------
using linux-next-20160112 without "mm,oom: exclude TIF_MEMDIE processes from
candidates." patch, and reproducer shown below.
----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>

static int file_writer(void *unused)
{
	static char buffer[4096] = { }; 
	const int fd = open("/tmp/file",
			    O_WRONLY | O_CREAT | O_APPEND | O_SYNC, 0600);
	while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
	return 0;
}

static int memory_consumer(void *unused)
{
	const int fd = open("/dev/zero", O_RDONLY);
	unsigned long size;
	char *buf = NULL;
	sleep(1);
	unlink("/tmp/file");
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	read(fd, buf, size); /* Will cause OOM due to overcommit */
	return 0;
}

int main(int argc, char *argv[])
{
	if (fork() == 0) {
		int i;
		for (i = 0; i < 10; i++) {
			char *cp = malloc(4096);
			if (!cp || clone(file_writer, cp + 4096,
					 CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL) == -1)
				break;
		}
	} else {
		memory_consumer(NULL);
	}
	while (1)
		pause();
}
----------

>  
> > How can we guarantee that find_lock_task_mm() from oom_kill_process()
> > chooses !TIF_MEMDIE thread when try_to_sacrifice_child() somehow chose
> > !TIF_MEMDIE thread? I think choosing !TIF_MEMDIE thread at
> > find_lock_task_mm() is the simplest way.
> 
> find_lock_task_mm chosing TIF_MEMDIE thread shouldn't change anything
> because the whole thread group will go down anyway. If you want to
> guarantee that the sysrq+f never choses a task which has a TIF_MEMDIE
> thread then we would have to check for fatal_signal_pending as well
> AFAIU. Fiddling with find find_lock_task_mm will not help you though
> unless I am missing something.

I do want to guarantee that the SysRq-f (and timeout based next victim
selection) never chooses a process which has a TIF_MEMDIE thread.

I don't like current "oom: clear TIF_MEMDIE after oom_reaper managed to unmap
the address space" patch unless both "mm,oom: exclude TIF_MEMDIE processes from
candidates." patch and "mm,oom: Re-enable OOM killer using timers." patch are
used together. Since your patch covers only likely case, your patch cannot become
alternative to my patches which cover unlikely cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
