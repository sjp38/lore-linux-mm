Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF0C4800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 05:57:17 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id u6so3855026oiv.21
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 02:57:17 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e39si1645908oth.353.2018.01.25.02.57.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 02:57:16 -0800 (PST)
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171115140020.GA6771@cmpxchg.org>
	<20171115141113.2nw4c4nejermhckb@dhcp22.suse.cz>
	<201801250204.w0P24NKZ033992@www262.sakura.ne.jp>
	<20180125083604.GM28465@dhcp22.suse.cz>
In-Reply-To: <20180125083604.GM28465@dhcp22.suse.cz>
Message-Id: <201801251956.FAH73425.VFJLFFtSHOOMQO@I-love.SAKURA.ne.jp>
Date: Thu, 25 Jan 2018 19:56:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, linux-mm@lists.ewheeler.net, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, akpm@linux-foundation.org, shakeelb@google.com, gthelen@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Using a debug patch and a reproducer shown below, we can trivially form
a circular locking dependency shown below.

----------------------------------------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8219001..240efb1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -950,7 +950,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	}
 	task_unlock(p);
 
-	if (__ratelimit(&oom_rs))
+	if (0 && __ratelimit(&oom_rs))
 		dump_header(oc, p);
 
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1afb2af..9858449 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -410,6 +410,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	return freed;
 }
 
+struct lockdep_map __shrink_slab_map =
+	STATIC_LOCKDEP_MAP_INIT("shrink_slab", &__shrink_slab_map);
+
 /**
  * shrink_slab - shrink slab caches
  * @gfp_mask: allocation context
@@ -453,6 +456,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		goto out;
 	}
 
+	lock_map_acquire(&__shrink_slab_map);
+
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		struct shrink_control sc = {
 			.gfp_mask = gfp_mask,
@@ -491,6 +496,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		}
 	}
 
+	lock_map_release(&__shrink_slab_map);
+
 	up_read(&shrinker_rwsem);
 out:
 	cond_resched();
----------------------------------------

----------------------------------------
#include <stdlib.h>

int main(int argc, char *argv[])
{
	unsigned long long size;
	char *buf = NULL;
	unsigned long long i;
	for (size = 1048576; size < 512ULL * (1 << 30); size *= 2) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size /= 2;
			break;
		}
		buf = cp;
	}
	for (i = 0; i < size; i += 4096)
		buf[i] = 0;
	return 0;
}
----------------------------------------

----------------------------------------
CentOS Linux 7 (Core)
Kernel 4.15.0-rc8-next-20180119+ on an x86_64

localhost login: [   36.954893] cp (2850) used greatest stack depth: 10816 bytes left
[   89.216085] Out of memory: Kill process 6981 (a.out) score 876 or sacrifice child
[   89.225853] Killed process 6981 (a.out) total-vm:4264020kB, anon-rss:3346832kB, file-rss:8kB, shmem-rss:0kB
[   89.313597] oom_reaper: reaped process 6981 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[   92.640566] Out of memory: Kill process 6983 (a.out) score 876 or sacrifice child
[   92.642153] 
[   92.643464] Killed process 6983 (a.out) total-vm:4264020kB, anon-rss:3348624kB, file-rss:4kB, shmem-rss:0kB
[   92.644416] ======================================================
[   92.644417] WARNING: possible circular locking dependency detected
[   92.644418] 4.15.0-rc8-next-20180119+ #222 Not tainted
[   92.644419] ------------------------------------------------------
[   92.644419] kworker/u256:29/401 is trying to acquire lock:
[   92.644420]  (shrink_slab){+.+.}, at: [<0000000040040aca>] shrink_slab.part.42+0x73/0x350
[   92.644428] 
[   92.644428] but task is already holding lock:
[   92.665257]  (&xfs_nondir_ilock_class){++++}, at: [<00000000ae515ec8>] xfs_ilock+0xa3/0x180 [xfs]
[   92.668490] 
[   92.668490] which lock already depends on the new lock.
[   92.668490] 
[   92.672781] 
[   92.672781] the existing dependency chain (in reverse order) is:
[   92.676310] 
[   92.676310] -> #1 (&xfs_nondir_ilock_class){++++}:
[   92.679519]        xfs_free_eofblocks+0x9d/0x210 [xfs]
[   92.681716]        xfs_fs_destroy_inode+0x9e/0x220 [xfs]
[   92.683962]        dispose_list+0x30/0x40
[   92.685822]        prune_icache_sb+0x4d/0x70
[   92.687961]        super_cache_scan+0x136/0x180
[   92.690017]        shrink_slab.part.42+0x205/0x350
[   92.692109]        shrink_node+0x313/0x320
[   92.694177]        kswapd+0x386/0x6d0
[   92.695951]        kthread+0xeb/0x120
[   92.697889]        ret_from_fork+0x3a/0x50
[   92.699800] 
[   92.699800] -> #0 (shrink_slab){+.+.}:
[   92.702676]        shrink_slab.part.42+0x93/0x350
[   92.704756]        shrink_node+0x313/0x320
[   92.706660]        do_try_to_free_pages+0xde/0x350
[   92.708737]        try_to_free_pages+0xc5/0x100
[   92.710734]        __alloc_pages_slowpath+0x41c/0xd60
[   92.712470] oom_reaper: reaped process 6983 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[   92.712978]        __alloc_pages_nodemask+0x22a/0x270
[   92.713013]        xfs_buf_allocate_memory+0x16b/0x2d0 [xfs]
[   92.721378]        xfs_buf_get_map+0xaf/0x140 [xfs]
[   92.723562]        xfs_buf_read_map+0x1f/0xc0 [xfs]
[   92.726105]        xfs_trans_read_buf_map+0xf5/0x2d0 [xfs]
[   92.728461]        xfs_btree_read_buf_block.constprop.36+0x69/0xc0 [xfs]
[   92.731321]        xfs_btree_lookup_get_block+0x82/0x180 [xfs]
[   92.733739]        xfs_btree_lookup+0x118/0x450 [xfs]
[   92.735982]        xfs_alloc_ag_vextent_near+0xb2/0xb80 [xfs]
[   92.738380]        xfs_alloc_ag_vextent+0x1cc/0x320 [xfs]
[   92.740646]        xfs_alloc_vextent+0x416/0x480 [xfs]
[   92.743023]        xfs_bmap_btalloc+0x340/0x8b0 [xfs]
[   92.745597]        xfs_bmapi_write+0x6c1/0x1270 [xfs]
[   92.747749]        xfs_iomap_write_allocate+0x16c/0x360 [xfs]
[   92.750317]        xfs_map_blocks+0x175/0x230 [xfs]
[   92.752745]        xfs_do_writepage+0x232/0x6e0 [xfs]
[   92.754843]        write_cache_pages+0x1d1/0x3b0
[   92.756801]        xfs_vm_writepages+0x60/0xa0 [xfs]
[   92.758838]        do_writepages+0x12/0x60
[   92.760822]        __writeback_single_inode+0x2c/0x170
[   92.762895]        writeback_sb_inodes+0x267/0x460
[   92.764851]        __writeback_inodes_wb+0x82/0xb0
[   92.766821]        wb_writeback+0x203/0x210
[   92.768676]        wb_workfn+0x266/0x2e0
[   92.770494]        process_one_work+0x253/0x460
[   92.772378]        worker_thread+0x42/0x3e0
[   92.774153]        kthread+0xeb/0x120
[   92.775775]        ret_from_fork+0x3a/0x50
[   92.777513] 
[   92.777513] other info that might help us debug this:
[   92.777513] 
[   92.781361]  Possible unsafe locking scenario:
[   92.781361] 
[   92.784382]        CPU0                    CPU1
[   92.786276]        ----                    ----
[   92.788130]   lock(&xfs_nondir_ilock_class);
[   92.790048]                                lock(shrink_slab);
[   92.792256]                                lock(&xfs_nondir_ilock_class);
[   92.794756]   lock(shrink_slab);
[   92.796251] 
[   92.796251]  *** DEADLOCK ***
[   92.796251] 
[   92.799521] 6 locks held by kworker/u256:29/401:
[   92.801573]  #0:  ((wq_completion)"writeback"){+.+.}, at: [<0000000087382bbf>] process_one_work+0x1f0/0x460
[   92.804947]  #1:  ((work_completion)(&(&wb->dwork)->work)){+.+.}, at: [<0000000087382bbf>] process_one_work+0x1f0/0x460
[   92.808596]  #2:  (&type->s_umount_key#31){++++}, at: [<0000000048ea98d7>] trylock_super+0x11/0x50
[   92.811957]  #3:  (sb_internal){.+.+}, at: [<0000000058532c48>] xfs_trans_alloc+0xe4/0x120 [xfs]
[   92.815280]  #4:  (&xfs_nondir_ilock_class){++++}, at: [<00000000ae515ec8>] xfs_ilock+0xa3/0x180 [xfs]
[   92.819075]  #5:  (shrinker_rwsem){++++}, at: [<0000000039dd500e>] shrink_slab.part.42+0x3c/0x350
[   92.822354] 
[   92.822354] stack backtrace:
[   92.824820] CPU: 1 PID: 401 Comm: kworker/u256:29 Not tainted 4.15.0-rc8-next-20180119+ #222
[   92.827894] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[   92.831609] Workqueue: writeback wb_workfn (flush-8:0)
[   92.833759] Call Trace:
[   92.835144]  dump_stack+0x7d/0xb6
[   92.836761]  print_circular_bug.isra.37+0x1d7/0x1e4
[   92.838908]  __lock_acquire+0x10da/0x15b0
[   92.840744]  ? __lock_acquire+0x390/0x15b0
[   92.842603]  ? lock_acquire+0x51/0x70
[   92.844308]  lock_acquire+0x51/0x70
[   92.845980]  ? shrink_slab.part.42+0x73/0x350
[   92.847896]  shrink_slab.part.42+0x93/0x350
[   92.849799]  ? shrink_slab.part.42+0x73/0x350
[   92.851710]  ? mem_cgroup_iter+0x140/0x530
[   92.853890]  ? mem_cgroup_iter+0x158/0x530
[   92.855897]  shrink_node+0x313/0x320
[   92.857609]  do_try_to_free_pages+0xde/0x350
[   92.859502]  try_to_free_pages+0xc5/0x100
[   92.861328]  __alloc_pages_slowpath+0x41c/0xd60
[   92.863298]  __alloc_pages_nodemask+0x22a/0x270
[   92.865285]  xfs_buf_allocate_memory+0x16b/0x2d0 [xfs]
[   92.867621]  xfs_buf_get_map+0xaf/0x140 [xfs]
[   92.869562]  xfs_buf_read_map+0x1f/0xc0 [xfs]
[   92.871494]  xfs_trans_read_buf_map+0xf5/0x2d0 [xfs]
[   92.873589]  xfs_btree_read_buf_block.constprop.36+0x69/0xc0 [xfs]
[   92.876322]  ? kmem_zone_alloc+0x7e/0x100 [xfs]
[   92.878320]  xfs_btree_lookup_get_block+0x82/0x180 [xfs]
[   92.880527]  xfs_btree_lookup+0x118/0x450 [xfs]
[   92.882528]  ? kmem_zone_alloc+0x7e/0x100 [xfs]
[   92.884511]  xfs_alloc_ag_vextent_near+0xb2/0xb80 [xfs]
[   92.886974]  xfs_alloc_ag_vextent+0x1cc/0x320 [xfs]
[   92.889088]  xfs_alloc_vextent+0x416/0x480 [xfs]
[   92.891098]  xfs_bmap_btalloc+0x340/0x8b0 [xfs]
[   92.893087]  xfs_bmapi_write+0x6c1/0x1270 [xfs]
[   92.895085]  xfs_iomap_write_allocate+0x16c/0x360 [xfs]
[   92.897277]  xfs_map_blocks+0x175/0x230 [xfs]
[   92.899228]  xfs_do_writepage+0x232/0x6e0 [xfs]
[   92.901218]  write_cache_pages+0x1d1/0x3b0
[   92.903102]  ? xfs_add_to_ioend+0x290/0x290 [xfs]
[   92.905170]  ? xfs_vm_writepages+0x4b/0xa0 [xfs]
[   92.907182]  xfs_vm_writepages+0x60/0xa0 [xfs]
[   92.909114]  do_writepages+0x12/0x60
[   92.910778]  __writeback_single_inode+0x2c/0x170
[   92.912735]  writeback_sb_inodes+0x267/0x460
[   92.914561]  __writeback_inodes_wb+0x82/0xb0
[   92.916413]  wb_writeback+0x203/0x210
[   92.918050]  ? cpumask_next+0x20/0x30
[   92.919790]  ? wb_workfn+0x266/0x2e0
[   92.921384]  wb_workfn+0x266/0x2e0
[   92.922908]  process_one_work+0x253/0x460
[   92.924687]  ? process_one_work+0x1f0/0x460
[   92.926518]  worker_thread+0x42/0x3e0
[   92.928077]  kthread+0xeb/0x120
[   92.929512]  ? process_one_work+0x460/0x460
[   92.931330]  ? kthread_create_worker_on_cpu+0x70/0x70
[   92.933313]  ret_from_fork+0x3a/0x50
----------------------------------------

Normally shrinker_rwsem acts like a shared lock. But when
register_shrinker()/unregister_shrinker() called down_write(),
shrinker_rwsem suddenly starts acting like an exclusive lock.

What is unfortunate is that down_write() is called independent of
memory allocation requests. That is, shrinker_rwsem is essentially
a mutex (and hence the debug patch shown above).

----------------------------------------
[<ffffffffac7538d3>] call_rwsem_down_write_failed+0x13/0x20
[<ffffffffac1cb985>] register_shrinker+0x45/0xa0
[<ffffffffac250f68>] sget_userns+0x468/0x4a0
[<ffffffffac25106a>] mount_nodev+0x2a/0xa0
[<ffffffffac251be4>] mount_fs+0x34/0x150
[<ffffffffac2701f2>] vfs_kern_mount+0x62/0x120
[<ffffffffac272a0e>] do_mount+0x1ee/0xc50
[<ffffffffac27377e>] SyS_mount+0x7e/0xd0
[<ffffffffac003831>] do_syscall_64+0x61/0x1a0
[<ffffffffac80012c>] entry_SYSCALL64_slow_path+0x25/0x25
[<ffffffffffffffff>] 0xffffffffffffffff
----------------------------------------

Therefore, I think that when do_shrink_slab() for GFP_KERNEL is in progress
and down_read_trylock() starts failing because somebody else started waiting at
down_write(), do_shrink_slab() for GFP_NOFS or GFP_NOIO cannot be called.
Doesn't such race cause unexpected results?

Michal Hocko wrote:
> I would rather understand the problem than speculate here. I strongly
> suspect somebody simply didn't unlock the page.

Then, can we please please have a mechanism which tells whether somebody
else was stuck doing memory allocation requests? It is basically
https://lkml.kernel.org/r/1510833448-19918-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
