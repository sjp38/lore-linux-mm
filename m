Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C85D16B025C
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 11:19:57 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so79064697pac.2
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 08:19:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id rm13si1097252pab.133.2015.09.11.08.19.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 11 Sep 2015 08:19:56 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: Favor kthread and dying threads over normal threads
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201509102318.GHG18789.OHMSLFJOQFOtFV@I-love.SAKURA.ne.jp>
In-Reply-To: <201509102318.GHG18789.OHMSLFJOQFOtFV@I-love.SAKURA.ne.jp>
Message-Id: <201509120019.BJI48986.OOSVMJtOLFQHFF@I-love.SAKURA.ne.jp>
Date: Sat, 12 Sep 2015 00:19:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Tetsuo Handa wrote:
> From fb48bec5d08068bc68023f4684098d0ce9ab6439 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Thu, 10 Sep 2015 20:13:38 +0900
> Subject: [PATCH] mm/page_alloc: Favor kthread and dying threads over normal
>  threads

The effect of this patch (which gives higher priority to kernel threads
and dying threads) becomes clear if a different reproducer shown below

----------------------------------------
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
	const int fd = open("/tmp/file", O_WRONLY | O_CREAT | O_APPEND, 0600);
	sleep(2);
	while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
	return 0;
}

static int memory_consumer(void *unused)
{
	const int fd = open("/dev/zero", O_RDONLY);
	unsigned long size;
	char *buf = NULL;
	sleep(3);
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
	int i;
	for (i = 0; i < 2; i++)
		clone(file_writer, malloc(4 * 1024) + 4 * 1024, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL);
	clone(memory_consumer, malloc(4 * 1024) + 4 * 1024, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL);
	pause();
	return 0;
}
----------------------------------------

is used with "GFP_NOFS can fail" patch shown below.

----------------------------------------
diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index a7a3a63..d21742c4 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -54,8 +54,9 @@ kmem_alloc(size_t size, xfs_km_flags_t flags)
 		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
 			return ptr;
 		if (!(++retries % 100))
-			xfs_err(NULL,
+			xfs_err(NULL, "%s(%u) "
 		"possible memory allocation deadlock in %s (mode:0x%x)",
+					current->comm, current->pid,
 					__func__, lflags);
 		congestion_wait(BLK_RW_ASYNC, HZ/50);
 	} while (1);
@@ -119,8 +120,9 @@ kmem_zone_alloc(kmem_zone_t *zone, xfs_km_flags_t flags)
 		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
 			return ptr;
 		if (!(++retries % 100))
-			xfs_err(NULL,
+			xfs_err(NULL, "%s(%u) "
 		"possible memory allocation deadlock in %s (mode:0x%x)",
+					current->comm, current->pid,
 					__func__, lflags);
 		congestion_wait(BLK_RW_ASYNC, HZ/50);
 	} while (1);
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 8ecffb3..3ea4188 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -353,8 +353,9 @@ retry:
 			 * handle buffer allocation failures we can't do much.
 			 */
 			if (!(++retries % 100))
-				xfs_err(NULL,
+				xfs_err(NULL, "%s(%u) "
 		"possible memory allocation deadlock in %s (mode:0x%x)",
+					current->comm, current->pid,
 					__func__, gfp_mask);
 
 			XFS_STATS_INC(xb_page_retries);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dcfe935..2c8873b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2680,6 +2680,9 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 {
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
 
+	if (!(gfp_mask & __GFP_FS))
+		return;
+
 	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
 	    debug_guardpage_minorder() > 0)
 		return;
@@ -2764,12 +2767,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 		/* The OOM killer does not compensate for IO-less reclaim */
 		if (!(gfp_mask & __GFP_FS)) {
-			/*
-			 * XXX: Page reclaim didn't yield anything,
-			 * and the OOM killer can't be invoked, but
-			 * keep looping as per tradition.
-			 */
-			*did_some_progress = 1;
 			goto out;
 		}
 		if (pm_suspended_storage())
----------------------------------------

Without this patch, we can observe that workqueue for writeback operation
got stuck at memory allocation (indicated by XFS's possible memory
allocation deadlock warning) like what throttle_direct_reclaim() says.

----------------------------------------
[  174.062364] systemd-journal invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
[  174.064543] systemd-journal cpuset=/ mems_allowed=0
[  174.066339] CPU: 2 PID: 470 Comm: systemd-journal Not tainted 4.2.0-next-20150909+ #110
[  174.068416] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  174.070951]  0000000000000000 000000009a0f4f1a ffff880035de3af8 ffffffff8131bd76
[  174.073060]  ffff880035ce9980 ffff880035de3ba0 ffffffff81187d2d ffff880035de3b20
[  174.075067]  ffffffff8108fc93 ffff8800775d4ed0 ffff8800775d4c80 ffff8800775d4c80
[  174.077365] Call Trace:
[  174.078381]  [<ffffffff8131bd76>] dump_stack+0x4e/0x88
[  174.079888]  [<ffffffff81187d2d>] dump_header+0x82/0x232
[  174.081422]  [<ffffffff8108fc93>] ? preempt_count_add+0x43/0x90
[  174.084411]  [<ffffffff8108fc0d>] ? get_parent_ip+0xd/0x50
[  174.086105]  [<ffffffff8108fc93>] ? preempt_count_add+0x43/0x90
[  174.087817]  [<ffffffff8111b8bb>] oom_kill_process+0x35b/0x3c0
[  174.089493]  [<ffffffff810737d0>] ? has_ns_capability_noaudit+0x30/0x40
[  174.091212]  [<ffffffff810737f2>] ? has_capability_noaudit+0x12/0x20
[  174.092926]  [<ffffffff8111bb8d>] out_of_memory+0x21d/0x4a0
[  174.094552]  [<ffffffff81121184>] __alloc_pages_nodemask+0x904/0x930
[  174.096426]  [<ffffffff811643b0>] alloc_pages_vma+0xb0/0x1f0
[  174.098244]  [<ffffffff81144ed2>] handle_mm_fault+0x13f2/0x19d0
[  174.100161]  [<ffffffff81163397>] ? change_prot_numa+0x17/0x30
[  174.101943]  [<ffffffff81057912>] __do_page_fault+0x152/0x480
[  174.103483]  [<ffffffff81057c70>] do_page_fault+0x30/0x80
[  174.104982]  [<ffffffff816382e8>] page_fault+0x28/0x30
[  174.106378] Mem-Info:
[  174.107285] active_anon:314047 inactive_anon:1920 isolated_anon:16
[  174.107285]  active_file:11066 inactive_file:87440 isolated_file:0
[  174.107285]  unevictable:0 dirty:5533 writeback:81919 unstable:0
[  174.107285]  slab_reclaimable:4102 slab_unreclaimable:4889
[  174.107285]  mapped:10081 shmem:2148 pagetables:1906 bounce:0
[  174.107285]  free:13078 free_pcp:30 free_cma:0
[  174.116538] Node 0 DMA free:7312kB min:400kB low:500kB high:600kB active_anon:5204kB inactive_anon:144kB active_file:216kB inactive_file:976kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:32kB writeback:932kB mapped:296kB shmem:180kB slab_reclaimable:288kB slab_unreclaimable:300kB kernel_stack:240kB pagetables:396kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:7792 all_unreclaimable? yes
[  174.126674] lowmem_reserve[]: 0 1729 1729 1729
[  174.129129] Node 0 DMA32 free:45000kB min:44652kB low:55812kB high:66976kB active_anon:1250984kB inactive_anon:7536kB active_file:44048kB inactive_file:348784kB unevictable:0kB isolated(anon):64kB isolated(file):0kB present:2080640kB managed:1774196kB mlocked:0kB dirty:22100kB writeback:326744kB mapped:40028kB shmem:8412kB slab_reclaimable:16120kB slab_unreclaimable:19256kB kernel_stack:3920kB pagetables:7228kB unstable:0kB bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  174.141837] lowmem_reserve[]: 0 0 0 0
[  174.143413] Node 0 DMA: 5*4kB (EM) 2*8kB (UE) 7*16kB (UEM) 3*32kB (UE) 3*64kB (UEM) 2*128kB (E) 2*256kB (UE) 2*512kB (UM) 3*1024kB (UEM) 1*2048kB (U) 0*4096kB = 7348kB
[  174.148343] Node 0 DMA32: 691*4kB (UE) 650*8kB (UEM) 242*16kB (UE) 30*32kB (UE) 6*64kB (UE) 3*128kB (U) 7*256kB (UEM) 6*512kB (UE) 24*1024kB (UEM) 1*2048kB (E) 0*4096kB = 45052kB
[  174.154113] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  174.156382] 100695 total pagecache pages
[  174.157986] 0 pages in swap cache
[  174.159431] Swap cache stats: add 0, delete 0, find 0/0
[  174.161316] Free swap  = 0kB
[  174.162748] Total swap = 0kB
[  174.164874] 524157 pages RAM
[  174.166635] 0 pages HighMem/MovableOnly
[  174.168878] 76632 pages reserved
[  174.170472] 0 pages hwpoisoned
[  174.171788] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[  174.174162] [  470]     0   470    34593     2894      31       3        0             0 systemd-journal
[  174.176546] [  485]     0   485    10290      810      23       3        0         -1000 systemd-udevd
[  174.179056] [  507]     0   507    12795      763      25       3        0         -1000 auditd
[  174.181386] [ 1688]     0  1688    82430     6883      83       3        0             0 firewalld
[  174.184146] [ 1691]    70  1691     6988      671      18       3        0             0 avahi-daemon
[  174.186614] [ 1694]     0  1694    54104     1701      40       3        0             0 rsyslogd
[  174.189930] [ 1695]     0  1695   137547     5615      88       3        0             0 tuned
[  174.192275] [ 1698]     0  1698     4823      678      15       3        0             0 irqbalance
[  174.194670] [ 1699]     0  1699     1095      358       8       3        0             0 rngd
[  174.196894] [ 1705]     0  1705    53609     2135      59       3        0             0 abrtd
[  174.199280] [ 1706]     0  1706    53001     1962      57       4        0             0 abrt-watch-log
[  174.202202] [ 1708]     0  1708     8673      726      23       3        0             0 systemd-logind
[  174.205167] [ 1709]    81  1709     6647      734      18       3        0          -900 dbus-daemon
[  174.207828] [ 1717]     0  1717    31578      802      20       3        0             0 crond
[  174.210248] [ 1756]    70  1756     6988       57      17       3        0             0 avahi-daemon
[  174.212817] [ 1900]     0  1900    46741     1920      43       3        0             0 vmtoolsd
[  174.215156] [ 2445]     0  2445    25938     3354      49       3        0             0 dhclient
[  174.217955] [ 2449]   999  2449   128626     3447      49       4        0             0 polkitd
[  174.220319] [ 2532]     0  2532    20626     1512      42       4        0         -1000 sshd
[  174.222694] [ 2661]     0  2661     7320      596      19       3        0             0 xinetd
[  174.224974] [ 4080]     0  4080    22770     1182      43       3        0             0 master
[  174.227266] [ 4247]    89  4247    22796     1533      46       3        0             0 pickup
[  174.229483] [ 4248]    89  4248    22813     1605      45       3        0             0 qmgr
[  174.231719] [ 4772]     0  4772    75242     1276      96       3        0             0 nmbd
[  174.234313] [ 4930]     0  4930    92960     3416     130       3        0             0 smbd
[  174.236671] [ 4967]     0  4967    92960     1516     125       3        0             0 smbd
[  174.239945] [ 5046]     0  5046    27503      571      12       3        0             0 agetty
[  174.242850] [11027]     0 11027    21787     1047      48       3        0             0 login
[  174.246033] [11030]  1000 11030    28865      904      14       3        0             0 bash
[  174.248385] [11108]  1000 11107   541750   295927     588       6        0             0 a.out
[  174.250806] Out of memory: Kill process 11109 (a.out) score 662 or sacrifice child
[  174.252879] Killed process 11108 (a.out) total-vm:2167000kB, anon-rss:1182716kB, file-rss:992kB
[  178.675269] XFS: crond(1717) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
[  178.729646] XFS: kworker/u16:29(382) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
[  180.805219] XFS: crond(1717) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
[  180.877987] XFS: kworker/u16:29(382) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
[  182.392209] XFS: vmtoolsd(1900) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
[  182.961922] XFS: crond(1717) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
[  183.050782] XFS: kworker/u16:29(382) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
(...snipped...)
[  255.566378] kworker/u16:29  D ffff88007fc55b40     0   382      2 0x00000000
[  255.568322] Workqueue: writeback wb_workfn (flush-8:0)
[  255.569891]  ffff880077666fc8 0000000000000046 ffff880077646600 ffff880077668000
[  255.572002]  ffff880077667030 ffff88007fc4dfc0 00000000ffff501b 0000000000000040
[  255.574117]  ffff880077667010 ffffffff81631bf8 ffff88007fc4dfc0 ffff880077667090
[  255.576197] Call Trace:
[  255.577225]  [<ffffffff81631bf8>] schedule+0x38/0x90
[  255.578825]  [<ffffffff81635672>] schedule_timeout+0x122/0x1c0
[  255.580629]  [<ffffffff810c8020>] ? cascade+0x90/0x90
[  255.582192]  [<ffffffff81635769>] schedule_timeout_uninterruptible+0x19/0x20
[  255.584132]  [<ffffffff81120eb8>] __alloc_pages_nodemask+0x638/0x930
[  255.585816]  [<ffffffff8116310c>] alloc_pages_current+0x8c/0x100
[  255.587608]  [<ffffffff8127bf7a>] xfs_buf_allocate_memory+0x17b/0x26e
[  255.589529]  [<ffffffff81246bca>] xfs_buf_get_map+0xca/0x130
[  255.591139]  [<ffffffff81247144>] xfs_buf_read_map+0x24/0xb0
[  255.592828]  [<ffffffff8126ec77>] xfs_trans_read_buf_map+0x97/0x1a0
[  255.594633]  [<ffffffff812223d3>] xfs_btree_read_buf_block.constprop.28+0x73/0xc0
[  255.596745]  [<ffffffff8122249b>] xfs_btree_lookup_get_block+0x7b/0xf0
[  255.598527]  [<ffffffff812223e9>] ? xfs_btree_read_buf_block.constprop.28+0x89/0xc0
[  255.600567]  [<ffffffff8122638e>] xfs_btree_lookup+0xbe/0x4a0
[  255.602289]  [<ffffffff8120d546>] xfs_alloc_lookup_eq+0x16/0x20
[  255.604092]  [<ffffffff8120da7d>] xfs_alloc_fixup_trees+0x23d/0x340
[  255.605915]  [<ffffffff812110cc>] ? xfs_allocbt_init_cursor+0x3c/0xc0
[  255.607577]  [<ffffffff8120f381>] xfs_alloc_ag_vextent_near+0x511/0x880
[  255.609336]  [<ffffffff8120fdb5>] xfs_alloc_ag_vextent+0xb5/0xe0
[  255.611082]  [<ffffffff81210866>] xfs_alloc_vextent+0x356/0x460
[  255.613046]  [<ffffffff8121e496>] xfs_bmap_btalloc+0x386/0x6d0
[  255.614684]  [<ffffffff8121e7e9>] xfs_bmap_alloc+0x9/0x10
[  255.616322]  [<ffffffff8121f1e9>] xfs_bmapi_write+0x4b9/0xa10
[  255.617969]  [<ffffffff8125280c>] xfs_iomap_write_allocate+0x13c/0x320
[  255.619818]  [<ffffffff812407ba>] xfs_map_blocks+0x15a/0x170
[  255.621500]  [<ffffffff8124177b>] xfs_vm_writepage+0x18b/0x5b0
[  255.623066]  [<ffffffff811228ce>] __writepage+0xe/0x30
[  255.624593]  [<ffffffff811232f3>] write_cache_pages+0x1f3/0x4a0
[  255.626287]  [<ffffffff811228c0>] ? mapping_tagged+0x10/0x10
[  255.628265]  [<ffffffff811235ec>] generic_writepages+0x4c/0x80
[  255.630194]  [<ffffffff8108fc0d>] ? get_parent_ip+0xd/0x50
[  255.631883]  [<ffffffff8108fc93>] ? preempt_count_add+0x43/0x90
[  255.633464]  [<ffffffff8124062e>] xfs_vm_writepages+0x3e/0x50
[  255.635000]  [<ffffffff81124199>] do_writepages+0x19/0x30
[  255.636549]  [<ffffffff811b3de3>] __writeback_single_inode+0x33/0x170
[  255.638345]  [<ffffffff81635fe5>] ? _raw_spin_unlock+0x15/0x40
[  255.640005]  [<ffffffff811b44a9>] writeback_sb_inodes+0x279/0x440
[  255.641636]  [<ffffffff811b46f1>] __writeback_inodes_wb+0x81/0xb0
[  255.643310]  [<ffffffff811b48cc>] wb_writeback+0x1ac/0x1e0
[  255.644866]  [<ffffffff811b4e45>] wb_workfn+0xe5/0x2f0
[  255.646384]  [<ffffffff8163606c>] ? _raw_spin_unlock_irq+0x1c/0x40
[  255.648301]  [<ffffffff8108bda9>] ? finish_task_switch+0x69/0x230
[  255.649915]  [<ffffffff81081a59>] process_one_work+0x129/0x300
[  255.651479]  [<ffffffff81081d45>] worker_thread+0x115/0x450
[  255.653019]  [<ffffffff81081c30>] ? process_one_work+0x300/0x300
[  255.654664]  [<ffffffff81087113>] kthread+0xd3/0xf0
[  255.656060]  [<ffffffff81087040>] ? kthread_create_on_node+0x1a0/0x1a0
[  255.657736]  [<ffffffff81636b1f>] ret_from_fork+0x3f/0x70
[  255.659240]  [<ffffffff81087040>] ? kthread_create_on_node+0x1a0/0x1a0
(...snipped...)
[  262.539668] Showing busy workqueues and worker pools:
[  262.540997] workqueue events: flags=0x0
[  262.542153]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=5/256
[  262.544104]     pending: vmpressure_work_fn, e1000_watchdog [e1000], vmstat_update, vmw_fb_dirty_flush [vmwgfx], console_callback
[  262.547286] workqueue events_freezable: flags=0x4
[  262.548604]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  262.550398]     pending: vmballoon_work [vmw_balloon]
[  262.552006] workqueue events_power_efficient: flags=0x80
[  262.553542]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  262.555281]     pending: neigh_periodic_work
[  262.556624] workqueue events_freezable_power_: flags=0x84
[  262.558168]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  262.560241]     in-flight: 214:disk_events_workfn
[  262.561837] workqueue writeback: flags=0x4e
[  262.563258]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[  262.564916]     in-flight: 382:wb_workfn wb_workfn
[  262.566530] workqueue xfs-data/sda1: flags=0xc
[  262.567905]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=6/256
[  262.569664]     in-flight: 11065:xfs_end_io, 11066:xfs_end_io, 11026:xfs_end_io, 11068:xfs_end_io, 11064:xfs_end_io, 82:xfs_end_io
[  262.572704]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=17/256
[  262.574497]     in-flight: 447:xfs_end_io, 398(RESCUER):xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io, 11071:xfs_end_io, 11072:xfs_end_io, 11069:xfs_end_io, 11090:xfs_end_io, 11073:xfs_end_io, 11091:xfs_end_io, 23:xfs_end_io, 11070:xfs_end_io
[  262.581400] pool 0: cpus=0 node=0 flags=0x0 nice=0 workers=4 idle: 11096 47 4
[  262.583536] pool 4: cpus=2 node=0 flags=0x0 nice=0 workers=10 manager: 86
[  262.585596] pool 6: cpus=3 node=0 flags=0x0 nice=0 workers=14 idle: 11063 11062 11061 11060 11059 30 84 11067
[  262.588545] pool 16: cpus=0-7 flags=0x4 nice=0 workers=32 idle: 380 381 379 378 377 376 375 374 373 372 371 370 369 368 367 366 365 364 363 362 361 360 359 358 277 279 6 271 69 384 383
[  263.463828] XFS: vmtoolsd(1900) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
[  264.167134] XFS: crond(1717) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
[  264.292440] XFS: pickup(4247) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
[  264.335779] XFS: kworker/u16:29(382) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
----------------------------------------
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20150911.txt.xz

With this patch, as far as I tested, I didn't see the warning.

Thus, I don't know whether ALLOC_HIGH is best, but I think that
favoring kernel threads can help with making forward progress.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
