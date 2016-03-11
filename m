Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2040A6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:45:59 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id tt10so94330819pab.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:45:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e86si5068439pfd.41.2016.03.11.02.45.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Mar 2016 02:45:57 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
Message-Id: <201603111945.FHI64215.JVOFLHQFOMOSFt@I-love.SAKURA.ne.jp>
Date: Fri, 11 Mar 2016 19:45:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(Posting as a reply to this thread.)

I was trying to test side effect of "oom, oom_reaper: disable oom_reaper for
oom_kill_allocating_task" compared to "oom: clear TIF_MEMDIE after oom_reaper
managed to unmap the address space" using a reproducer shown below.

---------- Reproducer start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <sys/prctl.h>
#include <signal.h>

static char buffer[4096] = { };

static int file_io(void *unused)
{
	const int fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
	sleep(2);
	while (write(fd, buffer, sizeof(buffer)) > 0);
	close(fd);
	return 0;
}

int main(int argc, char *argv[])
{
	int i;
	if (chdir("/tmp"))
		return 1;
	for (i = 0; i < 64; i++)
		if (fork() == 0) {
			static cpu_set_t set = { { 1 } };
			const int fd = open("/proc/self/oom_score_adj", O_WRONLY);
			write(fd, "1000", 4);
			close(fd);
			sched_setaffinity(0, sizeof(set), &set);
			snprintf(buffer, sizeof(buffer), "file_io.%02u", i);
			prctl(PR_SET_NAME, (unsigned long) buffer, 0, 0, 0);
			for (i = 0; i < 16; i++)
				clone(file_io, malloc(1024) + 1024, CLONE_VM, NULL);
			while (1)
				pause();
		}
	{ /* A dummy process for invoking the OOM killer. */
		char *buf = NULL;
		unsigned long i;
		unsigned long size = 0;
		prctl(PR_SET_NAME, (unsigned long) "memeater", 0, 0, 0);
		for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
			char *cp = realloc(buf, size);
			if (!cp) {
				size >>= 1;
				break;
			}
			buf = cp;
		}
		sleep(4);
		for (i = 0; i < size; i += 4096)
			buf[i] = '\0'; /* Will cause OOM due to overcommit */
	}
	kill(-1, SIGKILL);
	return * (char *) NULL; /* Not reached. */
}
---------- Reproducer end ----------

The characteristic of this reproducer is that the OOM killer chooses the same mm
for multiple times due to clone(!CLONE_SIGHAND && CLONE_VM) and the OOM reaper
happily skips reaping that mm due to marking that mm_struct as MMF_OOM_KILLED or
marking only first victim's signal_struct as OOM_SCORE_ADJ_MIN, which means that
nobody can unlock TIF_MEMDIE when non-first victim cannot terminate.

But the problem I can hit trivially is that kswapd got stuck at unkillable lock
when all allocating tasks are waiting at congestion_wait(). This situation resembles
http://lkml.kernel.org/r/201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp
but not looping at too_many_isolated() in shrink_inactive_list().
I don't know what is happening.

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160311.txt.xz .
---------- console log start ----------
[   81.282661] memeater invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=0, oom_score_adj=0
[   81.297589] memeater cpuset=/ mems_allowed=0
[   81.303615] CPU: 2 PID: 1239 Comm: memeater Tainted: G        W       4.5.0-rc7-next-20160310 #103
(...snipped...)
[   81.456295] Out of memory: Kill process 1240 (file_io.00) score 999 or sacrifice child
[   81.459768] Killed process 1240 (file_io.00) total-vm:4308kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[   81.682547] ksmtuned invoked oom-killer: gfp_mask=0x24084c0(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO), order=0, oom_score_adj=0
[   81.703992] ksmtuned cpuset=/ mems_allowed=0
[   81.709402] CPU: 1 PID: 2330 Comm: ksmtuned Tainted: G        W       4.5.0-rc7-next-20160310 #103
(...snipped...)
[   81.928733] Out of memory: Kill process 1248 (file_io.00) score 1000 or sacrifice child
[   81.932194] Killed process 1248 (file_io.00) total-vm:4308kB, anon-rss:104kB, file-rss:1044kB, shmem-rss:0kB
(...snipped...)
[  136.837273] Node 0 DMA free:3864kB min:60kB low:72kB high:84kB active_anon:9504kB inactive_anon:84kB active_file:140kB inactive_file:448kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
present:15988kB managed:15904kB mlocked:0kB dirty:448kB writeback:0kB mapped:172kB shmem:84kB slab_reclaimable:164kB slab_unreclaimable:692kB kernel_stack:448kB pagetables:156kB unstable:0kB
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4244 all_unreclaimable? yes
[  136.858075] lowmem_reserve[]: 0 953 953 953
[  136.860609] Node 0 DMA32 free:3648kB min:3780kB low:4752kB high:5724kB active_anon:783216kB inactive_anon:6376kB active_file:33388kB inactive_file:40292kB unevictable:0kB isolated(anon):0kB
isolated(file):128kB present:1032064kB managed:980816kB mlocked:0kB dirty:40232kB writeback:120kB mapped:34720kB shmem:6628kB slab_reclaimable:10528kB slab_unreclaimable:39068kB kernel_stack:20512kB
pagetables:8000kB unstable:0kB bounce:0kB free_pcp:1648kB local_pcp:116kB free_cma:0kB writeback_tmp:0kB pages_scanned:964952 all_unreclaimable? yes
[  136.880330] lowmem_reserve[]: 0 0 0 0
[  136.883137] Node 0 DMA: 28*4kB (UE) 15*8kB (UE) 9*16kB (UME) 1*32kB (M) 2*64kB (UE) 2*128kB (UE) 0*256kB 2*512kB (UE) 2*1024kB (UE) 0*2048kB 0*4096kB = 3864kB
[  136.890862] Node 0 DMA32: 860*4kB (UME) 16*8kB (UME) 1*16kB (M) 0*32kB 1*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3648kB
(...snipped...)
[  143.721805] kswapd0         D ffff880039ffb760     0    52      2 0x00000000
[  143.724711]  ffff880039ffb760 ffff88003bb5e140 ffff880039ff4000 ffff880039ffc000
[  143.727782]  ffff88003a2c3850 ffff88003a2c3868 ffff880039ffb958 0000000000000001
[  143.730815]  ffff880039ffb778 ffffffff81666600 ffff880039ff4000 ffff880039ffb7d8
[  143.733839] Call Trace:
[  143.735190]  [<ffffffff81666600>] schedule+0x30/0x80
[  143.737387]  [<ffffffff8166a066>] rwsem_down_read_failed+0xd6/0x140
[  143.739964]  [<ffffffff81323708>] call_rwsem_down_read_failed+0x18/0x30
[  143.742944]  [<ffffffff810b888b>] down_read_nested+0x3b/0x50
[  143.745315]  [<ffffffffa0242c5b>] ? xfs_ilock+0x4b/0xe0 [xfs]
[  143.747737]  [<ffffffffa0242c5b>] xfs_ilock+0x4b/0xe0 [xfs]
[  143.750071]  [<ffffffffa022d2d0>] xfs_map_blocks+0x80/0x150 [xfs]
[  143.752534]  [<ffffffffa022e27b>] xfs_do_writepage+0x15b/0x500 [xfs]
[  143.755230]  [<ffffffffa022e656>] xfs_vm_writepage+0x36/0x70 [xfs]
[  143.757959]  [<ffffffff8115356f>] pageout.isra.43+0x18f/0x240
[  143.760382]  [<ffffffff81154ed3>] shrink_page_list+0x803/0xae0
[  143.762785]  [<ffffffff8115590b>] shrink_inactive_list+0x1fb/0x460
[  143.765347]  [<ffffffff81156516>] shrink_zone_memcg+0x5b6/0x780
[  143.767801]  [<ffffffff811567b4>] shrink_zone+0xd4/0x2f0
[  143.770084]  [<ffffffff81157661>] kswapd+0x441/0x830
[  143.772193]  [<ffffffff81157220>] ? mem_cgroup_shrink_node_zone+0xb0/0xb0
[  143.774941]  [<ffffffff8109181e>] kthread+0xee/0x110
[  143.777025]  [<ffffffff8166b6f2>] ret_from_fork+0x22/0x50
[  143.779276]  [<ffffffff81091730>] ? kthread_create_on_node+0x230/0x230
(...snipped...)
[  144.479298] file_io.00      D ffff88003ac97cb8     0  1248      1 0x00100084
[  144.482410]  ffff88003ac97cb8 ffff88003b8760c0 ffff88003658c040 ffff88003ac98000
[  144.485513]  ffff88003a280ac8 0000000000000246 ffff88003658c040 00000000ffffffff
[  144.488618]  ffff88003ac97cd0 ffffffff81666600 ffff88003a280ac0 ffff88003ac97ce0
[  144.491661] Call Trace:
[  144.492921]  [<ffffffff81666600>] schedule+0x30/0x80
[  144.495066]  [<ffffffff81666909>] schedule_preempt_disabled+0x9/0x10
[  144.497582]  [<ffffffff816684bf>] mutex_lock_nested+0x14f/0x3a0
[  144.500060]  [<ffffffffa0237eef>] ? xfs_file_buffered_aio_write+0x5f/0x1f0 [xfs]
[  144.503077]  [<ffffffff810bd130>] ? __lock_acquire+0x8c0/0x1f50
[  144.505494]  [<ffffffffa0237eef>] xfs_file_buffered_aio_write+0x5f/0x1f0 [xfs]
[  144.508375]  [<ffffffff8111dfca>] ? __audit_syscall_entry+0xaa/0xf0
[  144.510996]  [<ffffffffa023810a>] xfs_file_write_iter+0x8a/0x150 [xfs]
[  144.514521]  [<ffffffff811bf327>] __vfs_write+0xc7/0x100
[  144.517230]  [<ffffffff811bfedd>] vfs_write+0x9d/0x190
[  144.519407]  [<ffffffff811df5da>] ? __fget_light+0x6a/0x90
[  144.521772]  [<ffffffff811c0713>] SyS_write+0x53/0xd0
[  144.523909]  [<ffffffff8100364d>] do_syscall_64+0x5d/0x180
[  144.526145]  [<ffffffff8166b57f>] entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  145.684411] kworker/3:3     D ffff88000e987878     0  2329      2 0x00000080
[  145.684415] Workqueue: events_freezable_power_ disk_events_workfn
[  145.684416]  ffff88000e987878 ffff880037d76140 ffff88000e980100 ffff88000e988000
[  145.684417]  ffff88000e9878b0 ffff88003d6d02c0 00000000fffd9bc4 ffff88003ffdf100
[  145.684417]  ffff88000e987890 ffffffff81666600 ffff88003d6d02c0 ffff88000e987938
[  145.684418] Call Trace:
[  145.684419]  [<ffffffff81666600>] schedule+0x30/0x80
[  145.684419]  [<ffffffff8166a687>] schedule_timeout+0x117/0x1c0
[  145.684420]  [<ffffffff810bc306>] ? mark_held_locks+0x66/0x90
[  145.684421]  [<ffffffff810def90>] ? init_timer_key+0x40/0x40
[  145.684422]  [<ffffffff810e5e17>] ? ktime_get+0xa7/0x130
[  145.684423]  [<ffffffff81665b41>] io_schedule_timeout+0xa1/0x110
[  145.684424]  [<ffffffff81160ccd>] congestion_wait+0x7d/0xd0
[  145.684425]  [<ffffffff810b63a0>] ? wait_woken+0x80/0x80
[  145.684426]  [<ffffffff8114a602>] __alloc_pages_nodemask+0xb42/0xd50
[  145.684427]  [<ffffffff810bc300>] ? mark_held_locks+0x60/0x90
[  145.684428]  [<ffffffff81193a26>] alloc_pages_current+0x96/0x1b0
[  145.684430]  [<ffffffff812e1b3d>] ? bio_alloc_bioset+0x20d/0x2d0
[  145.684431]  [<ffffffff812e2e74>] bio_copy_kern+0xc4/0x180
[  145.684433]  [<ffffffff812edb20>] blk_rq_map_kern+0x70/0x130
[  145.684435]  [<ffffffff8145255d>] scsi_execute+0x12d/0x160
[  145.684436]  [<ffffffff81452684>] scsi_execute_req_flags+0x84/0xf0
[  145.684438]  [<ffffffffa01ed762>] sr_check_events+0xb2/0x2a0 [sr_mod]
[  145.684440]  [<ffffffffa01e1163>] cdrom_check_events+0x13/0x30 [cdrom]
[  145.684441]  [<ffffffffa01edba5>] sr_block_check_events+0x25/0x30 [sr_mod]
[  145.684442]  [<ffffffff812f928b>] disk_check_events+0x5b/0x150
[  145.684443]  [<ffffffff812f9397>] disk_events_workfn+0x17/0x20
[  145.684445]  [<ffffffff8108b4c5>] process_one_work+0x1a5/0x400
[  145.684446]  [<ffffffff8108b461>] ? process_one_work+0x141/0x400
[  145.684448]  [<ffffffff8108b846>] worker_thread+0x126/0x490
[  145.684449]  [<ffffffff81665ec1>] ? __schedule+0x311/0xa20
[  145.684450]  [<ffffffff8108b720>] ? process_one_work+0x400/0x400
[  145.684451]  [<ffffffff8109181e>] kthread+0xee/0x110
[  145.684452]  [<ffffffff8166b6f2>] ret_from_fork+0x22/0x50
[  145.684453]  [<ffffffff81091730>] ? kthread_create_on_node+0x230/0x230
(...snipped...)
[  208.035194] Node 0 DMA free:3864kB min:60kB low:72kB high:84kB active_anon:9504kB inactive_anon:84kB active_file:140kB inactive_file:448kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
present:15988kB managed:15904kB mlocked:0kB dirty:448kB writeback:0kB mapped:172kB shmem:84kB slab_reclaimable:164kB slab_unreclaimable:692kB kernel_stack:448kB pagetables:156kB unstable:0kB
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4244 all_unreclaimable? yes
[  208.051970] lowmem_reserve[]: 0 953 953 953
[  208.054174] Node 0 DMA32 free:3648kB min:3780kB low:4752kB high:5724kB active_anon:783216kB inactive_anon:6376kB active_file:33388kB inactive_file:40292kB unevictable:0kB isolated(anon):0kB
isolated(file):128kB present:1032064kB managed:980816kB mlocked:0kB dirty:40232kB writeback:120kB mapped:34724kB shmem:6628kB slab_reclaimable:10528kB slab_unreclaimable:39064kB kernel_stack:20512kB
pagetables:8000kB unstable:0kB bounce:0kB free_pcp:1644kB local_pcp:108kB free_cma:0kB writeback_tmp:0kB pages_scanned:1882904 all_unreclaimable? yes
[  208.072237] lowmem_reserve[]: 0 0 0 0
[  208.074340] Node 0 DMA: 28*4kB (UE) 15*8kB (UE) 9*16kB (UME) 1*32kB (M) 2*64kB (UE) 2*128kB (UE) 0*256kB 2*512kB (UE) 2*1024kB (UE) 0*2048kB 0*4096kB = 3864kB
[  208.080915] Node 0 DMA32: 860*4kB (UME) 16*8kB (UME) 1*16kB (M) 0*32kB 1*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3648kB
(...snipped...)
[  290.388544] INFO: task kswapd0:52 blocked for more than 120 seconds.
[  290.391197]       Tainted: G        W       4.5.0-rc7-next-20160310 #103
[  290.393979] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  290.397150] kswapd0         D ffff880039ffb760     0    52      2 0x00000000
[  290.400194]  ffff880039ffb760 ffff88003bb5e140 ffff880039ff4000 ffff880039ffc000
[  290.403394]  ffff88003a2c3850 ffff88003a2c3868 ffff880039ffb958 0000000000000001
[  290.406715]  ffff880039ffb778 ffffffff81666600 ffff880039ff4000 ffff880039ffb7d8
[  290.409874] Call Trace:
[  290.411242]  [<ffffffff81666600>] schedule+0x30/0x80
[  290.413423]  [<ffffffff8166a066>] rwsem_down_read_failed+0xd6/0x140
[  290.416100]  [<ffffffff81323708>] call_rwsem_down_read_failed+0x18/0x30
[  290.418835]  [<ffffffff810b888b>] down_read_nested+0x3b/0x50
[  290.421278]  [<ffffffffa0242c5b>] ? xfs_ilock+0x4b/0xe0 [xfs]
[  290.423672]  [<ffffffffa0242c5b>] xfs_ilock+0x4b/0xe0 [xfs]
[  290.426042]  [<ffffffffa022d2d0>] xfs_map_blocks+0x80/0x150 [xfs]
[  290.428569]  [<ffffffffa022e27b>] xfs_do_writepage+0x15b/0x500 [xfs]
[  290.431173]  [<ffffffffa022e656>] xfs_vm_writepage+0x36/0x70 [xfs]
[  290.433753]  [<ffffffff8115356f>] pageout.isra.43+0x18f/0x240
[  290.436135]  [<ffffffff81154ed3>] shrink_page_list+0x803/0xae0
[  290.438583]  [<ffffffff8115590b>] shrink_inactive_list+0x1fb/0x460
[  290.441090]  [<ffffffff81156516>] shrink_zone_memcg+0x5b6/0x780
[  290.443500]  [<ffffffff811567b4>] shrink_zone+0xd4/0x2f0
[  290.445703]  [<ffffffff81157661>] kswapd+0x441/0x830
[  290.447973]  [<ffffffff81157220>] ? mem_cgroup_shrink_node_zone+0xb0/0xb0
[  290.450676]  [<ffffffff8109181e>] kthread+0xee/0x110
[  290.452780]  [<ffffffff8166b6f2>] ret_from_fork+0x22/0x50
[  290.455018]  [<ffffffff81091730>] ? kthread_create_on_node+0x230/0x230
[  290.457910] 1 lock held by kswapd0/52:
[  290.459813]  #0:  (&xfs_nondir_ilock_class){++++--}, at: [<ffffffffa0242c5b>] xfs_ilock+0x4b/0xe0 [xfs]
(...snipped...)
[  336.562747] Node 0 DMA free:3864kB min:60kB low:72kB high:84kB active_anon:9504kB inactive_anon:84kB active_file:140kB inactive_file:448kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
present:15988kB managed:15904kB mlocked:0kB dirty:448kB writeback:0kB mapped:172kB shmem:84kB slab_reclaimable:164kB slab_unreclaimable:692kB kernel_stack:448kB pagetables:156kB unstable:0kB
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4244 all_unreclaimable? yes
[  336.589823] lowmem_reserve[]: 0 953 953 953
[  336.593296] Node 0 DMA32 free:3776kB min:3780kB low:4752kB high:5724kB active_anon:783216kB inactive_anon:6376kB active_file:33388kB inactive_file:40292kB unevictable:0kB isolated(anon):0kB
isolated(file):128kB present:1032064kB managed:980816kB mlocked:0kB dirty:40232kB writeback:120kB mapped:34724kB shmem:6628kB slab_reclaimable:10528kB slab_unreclaimable:39192kB kernel_stack:20416kB
pagetables:8000kB unstable:0kB bounce:0kB free_pcp:1520kB local_pcp:100kB free_cma:0kB writeback_tmp:0kB pages_scanned:1001584 all_unreclaimable? yes
[  336.618011] lowmem_reserve[]: 0 0 0 0
[  336.620073] Node 0 DMA: 28*4kB (UE) 15*8kB (UE) 9*16kB (UME) 1*32kB (M) 2*64kB (UE) 2*128kB (UE) 0*256kB 2*512kB (UE) 2*1024kB (UE) 0*2048kB 0*4096kB = 3864kB
[  336.626844] Node 0 DMA32: 860*4kB (UME) 18*8kB (UME) 8*16kB (UM) 0*32kB 1*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3776kB
(...snipped...)
[  393.774051] kswapd0         D ffff880039ffb760     0    52      2 0x00000000
[  393.777018]  ffff880039ffb760 ffff88003bb5e140 ffff880039ff4000 ffff880039ffc000
[  393.779986]  ffff88003a2c3850 ffff88003a2c3868 ffff880039ffb958 0000000000000001
[  393.783000]  ffff880039ffb778 ffffffff81666600 ffff880039ff4000 ffff880039ffb7d8
[  393.785958] Call Trace:
[  393.787191]  [<ffffffff81666600>] schedule+0x30/0x80
[  393.789198]  [<ffffffff8166a066>] rwsem_down_read_failed+0xd6/0x140
[  393.791707]  [<ffffffff81323708>] call_rwsem_down_read_failed+0x18/0x30
[  393.794364]  [<ffffffff810b888b>] down_read_nested+0x3b/0x50
[  393.796634]  [<ffffffffa0242c5b>] ? xfs_ilock+0x4b/0xe0 [xfs]
[  393.798952]  [<ffffffffa0242c5b>] xfs_ilock+0x4b/0xe0 [xfs]
[  393.801274]  [<ffffffffa022d2d0>] xfs_map_blocks+0x80/0x150 [xfs]
[  393.803709]  [<ffffffffa022e27b>] xfs_do_writepage+0x15b/0x500 [xfs]
[  393.806254]  [<ffffffffa022e656>] xfs_vm_writepage+0x36/0x70 [xfs]
[  393.808718]  [<ffffffff8115356f>] pageout.isra.43+0x18f/0x240
[  393.811002]  [<ffffffff81154ed3>] shrink_page_list+0x803/0xae0
[  393.813415]  [<ffffffff8115590b>] shrink_inactive_list+0x1fb/0x460
[  393.815834]  [<ffffffff81156516>] shrink_zone_memcg+0x5b6/0x780
[  393.818316]  [<ffffffff811567b4>] shrink_zone+0xd4/0x2f0
[  393.820472]  [<ffffffff81157661>] kswapd+0x441/0x830
[  393.822658]  [<ffffffff81157220>] ? mem_cgroup_shrink_node_zone+0xb0/0xb0
[  393.825463]  [<ffffffff8109181e>] kthread+0xee/0x110
[  393.827626]  [<ffffffff8166b6f2>] ret_from_fork+0x22/0x50
[  393.829824]  [<ffffffff81091730>] ? kthread_create_on_node+0x230/0x230
(...snipped...)
[  395.000240] file_io.00      D ffff88003ac97cb8     0  1248      1 0x00100084
[  395.003355]  ffff88003ac97cb8 ffff88003b8760c0 ffff88003658c040 ffff88003ac98000
[  395.006582]  ffff88003a280ac8 0000000000000246 ffff88003658c040 00000000ffffffff
[  395.010026]  ffff88003ac97cd0 ffffffff81666600 ffff88003a280ac0 ffff88003ac97ce0
[  395.013010] Call Trace:
[  395.014201]  [<ffffffff81666600>] schedule+0x30/0x80
[  395.016248]  [<ffffffff81666909>] schedule_preempt_disabled+0x9/0x10
[  395.018824]  [<ffffffff816684bf>] mutex_lock_nested+0x14f/0x3a0
[  395.021194]  [<ffffffffa0237eef>] ? xfs_file_buffered_aio_write+0x5f/0x1f0 [xfs]
[  395.024197]  [<ffffffff810bd130>] ? __lock_acquire+0x8c0/0x1f50
[  395.026672]  [<ffffffffa0237eef>] xfs_file_buffered_aio_write+0x5f/0x1f0 [xfs]
[  395.029525]  [<ffffffff8111dfca>] ? __audit_syscall_entry+0xaa/0xf0
[  395.032029]  [<ffffffffa023810a>] xfs_file_write_iter+0x8a/0x150 [xfs]
[  395.034589]  [<ffffffff811bf327>] __vfs_write+0xc7/0x100
[  395.036723]  [<ffffffff811bfedd>] vfs_write+0x9d/0x190
[  395.038841]  [<ffffffff811df5da>] ? __fget_light+0x6a/0x90
[  395.041069]  [<ffffffff811c0713>] SyS_write+0x53/0xd0
[  395.043258]  [<ffffffff8100364d>] do_syscall_64+0x5d/0x180
[  395.045511]  [<ffffffff8166b57f>] entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  446.012823] kworker/3:3     D ffff88000e987878     0  2329      2 0x00000080
[  446.015632] Workqueue: events_freezable_power_ disk_events_workfn
[  446.018103]  ffff88000e987878 ffff88003cc0c040 ffff88000e980100 ffff88000e988000
[  446.021099]  ffff88000e9878b0 ffff88003d6d02c0 0000000100016c95 ffff88003ffdf100
[  446.024247]  ffff88000e987890 ffffffff81666600 ffff88003d6d02c0 ffff88000e987938
[  446.027332] Call Trace:
[  446.028568]  [<ffffffff81666600>] schedule+0x30/0x80
[  446.030748]  [<ffffffff8166a687>] schedule_timeout+0x117/0x1c0
[  446.033122]  [<ffffffff810bc306>] ? mark_held_locks+0x66/0x90
[  446.035466]  [<ffffffff810def90>] ? init_timer_key+0x40/0x40
[  446.037756]  [<ffffffff810e5e17>] ? ktime_get+0xa7/0x130
[  446.039960]  [<ffffffff81665b41>] io_schedule_timeout+0xa1/0x110
[  446.042385]  [<ffffffff81160ccd>] congestion_wait+0x7d/0xd0
[  446.044651]  [<ffffffff810b63a0>] ? wait_woken+0x80/0x80
[  446.046817]  [<ffffffff8114a602>] __alloc_pages_nodemask+0xb42/0xd50
[  446.049395]  [<ffffffff810bc300>] ? mark_held_locks+0x60/0x90
[  446.051700]  [<ffffffff81193a26>] alloc_pages_current+0x96/0x1b0
[  446.054089]  [<ffffffff812e1b3d>] ? bio_alloc_bioset+0x20d/0x2d0
[  446.056515]  [<ffffffff812e2e74>] bio_copy_kern+0xc4/0x180
[  446.058737]  [<ffffffff812edb20>] blk_rq_map_kern+0x70/0x130
[  446.061105]  [<ffffffff8145255d>] scsi_execute+0x12d/0x160
[  446.063334]  [<ffffffff81452684>] scsi_execute_req_flags+0x84/0xf0
[  446.065810]  [<ffffffffa01ed762>] sr_check_events+0xb2/0x2a0 [sr_mod]
[  446.068343]  [<ffffffffa01e1163>] cdrom_check_events+0x13/0x30 [cdrom]
[  446.070897]  [<ffffffffa01edba5>] sr_block_check_events+0x25/0x30 [sr_mod]
[  446.073569]  [<ffffffff812f928b>] disk_check_events+0x5b/0x150
[  446.075895]  [<ffffffff812f9397>] disk_events_workfn+0x17/0x20
[  446.078340]  [<ffffffff8108b4c5>] process_one_work+0x1a5/0x400
[  446.080696]  [<ffffffff8108b461>] ? process_one_work+0x141/0x400
[  446.083069]  [<ffffffff8108b846>] worker_thread+0x126/0x490
[  446.085395]  [<ffffffff81665ec1>] ? __schedule+0x311/0xa20
[  446.087587]  [<ffffffff8108b720>] ? process_one_work+0x400/0x400
[  446.089996]  [<ffffffff8109181e>] kthread+0xee/0x110
[  446.092242]  [<ffffffff8166b6f2>] ret_from_fork+0x22/0x50
[  446.094527]  [<ffffffff81091730>] ? kthread_create_on_node+0x230/0x230
---------- console log end ----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
