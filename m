Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7AF56B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 05:21:44 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 144so67167537pfv.5
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 02:21:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b62si1824596pfl.65.2016.12.15.02.21.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Dec 2016 02:21:42 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161213170628.GC18362@dhcp22.suse.cz>
	<201612142037.AAC60483.HVOSOJFLMOFtQF@I-love.SAKURA.ne.jp>
	<20161214124231.GI25573@dhcp22.suse.cz>
	<201612150136.GBC13980.FHQFLSOJOFOtVM@I-love.SAKURA.ne.jp>
	<20161214181850.GC16763@dhcp22.suse.cz>
In-Reply-To: <20161214181850.GC16763@dhcp22.suse.cz>
Message-Id: <201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp>
Date: Thu, 15 Dec 2016 19:21:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

Michal Hocko wrote:
> > Regarding 1), it did not help. I can still see "** XXX printk messages dropped **"
> > ( http://I-love.SAKURA.ne.jp/tmp/serial-20161215-1.txt.xz ).
> 
> So we still manage to swamp the logbuffer. The question is whether you
> can still see the lockup. This is not obvious from the output to me.

I couldn't check whether oom_lock was released (which would have been reported
as kmallocwd's oom_count= field). But I think I can say the system locked up.
The last "Killed process" line is uptime = 118 and the stalls started from around
uptime = 112 lasted for 100 seconds. No OOM killer messages found until I issued
SysRq-b at uptime = 464.

--------------------
[  118.572525] Out of memory: Kill process 9485 (a.out) score 999 or sacrifice child
[  118.574882] Killed process 9485 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  118.584444] oom_reaper: reaped process 9485 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  118.590450] a.out invoked oom-killer: gfp_mask=0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK), nodemask=0, order=0, oom_score_adj=1000
[  118.910441] a.out cpuset=/ mems_allowed=0
(...snipped...)
[  122.418304] a.out: page allocation stalls for 10024ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
(...snipped...)
[  203.482124] nmbd: page allocation stalls for 90001ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  212.797150] systemd-journal: page allocation stalls for 100004ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  214.456261] kworker/1:2: page allocation stalls for 100003ms, order:0, mode:0x2400000(GFP_NOIO)
[  222.794883] vmtoolsd: page allocation stalls for 110001ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  222.795740] systemd-journal: page allocation stalls for 110001ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  223.485251] nmbd: page allocation stalls for 110001ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
** 88 printk messages dropped ** [  302.797171] vmtoolsd: page allocation stalls for 190003ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  354.317184] a.out: page allocation stalls for 20116ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
** 72 printk messages dropped ** [  394.275022] a.out: page allocation stalls for 60080ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
** 2081 printk messages dropped ** [  424.298603] a.out: page allocation stalls for 90046ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
(...snipped...)
** 119 printk messages dropped ** [  464.324536]  [<ffffffff8115489b>] warn_alloc+0x12b/0x170
** 56 printk messages dropped ** [  464.330865] CPU: 0 PID: 10356 Comm: a.out Tainted: G        W       4.9.0+ #102
--------------------



I think that the oom_lock stall problem is essentially independent with
printk() from warn_alloc(). I can trigger lockups even if I use one-liner
stall report per each second like below.

--------------------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440..dc7f6be 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3657,10 +3657,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
-		warn_alloc(gfp_mask,
-			"page allocation stalls for %ums, order:%u",
-			jiffies_to_msecs(jiffies-alloc_start), order);
-		stall_timeout += 10 * HZ;
+		static DEFINE_RATELIMIT_STATE(stall_rs, HZ, 1);
+
+		if (__ratelimit(&stall_rs)) {
+			pr_warn("%s(%u): page allocation stalls for %ums, order:%u mode:%#x(%pGg)\n",
+				current->comm, current->pid, jiffies_to_msecs(jiffies - alloc_start),
+				order, gfp_mask, &gfp_mask);
+			stall_timeout += 10 * HZ;
+		}
 	}
 
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
--------------------

Console log from http://I-love.SAKURA.ne.jp/tmp/serial-20161215-3.txt.xz :

--------------------
[  601.337474] Out of memory: Kill process 15498 (a.out) score 716 or sacrifice child
[  601.342349] Killed process 15498 (a.out) total-vm:2166868kB, anon-rss:1159344kB, file-rss:12kB, shmem-rss:0kB
[  601.575590] oom_reaper: reaped process 15498 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  641.271223] oom_kill_process: 132 callbacks suppressed
[  641.280260] a.out invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=0, order=0, oom_score_adj=0
[  641.300796] a.out cpuset=/ mems_allowed=0
[  641.310305] CPU: 0 PID: 16548 Comm: a.out Not tainted 4.9.0+ #78
[  641.320346] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  641.335472]  ffffc900069a7ac8 ffffffff8138730d ffffc900069a7c90 ffff88006fcc0040
[  641.347456]  ffffc900069a7b68 ffffffff8128125b 0000000000000000 0000000000000000
[  641.358075]  0000000000000206 ffffffffffffff10 ffffffff8175974b 0000000000000010
[  641.368537] Call Trace:
[  641.373574]  [<ffffffff8138730d>] dump_stack+0x85/0xc8
[  641.570618]  [<ffffffff8128125b>] dump_header+0x82/0x275
[  641.581733]  [<ffffffff8175974b>] ? _raw_spin_unlock_irqrestore+0x3b/0x60
[  641.594710]  [<ffffffff811e2e29>] oom_kill_process+0x219/0x400
[  641.606663]  [<ffffffff811e334e>] out_of_memory+0x13e/0x580
[  641.616883]  [<ffffffff811e341e>] ? out_of_memory+0x20e/0x580
[  641.626734]  [<ffffffff8128208b>] __alloc_pages_slowpath+0x93f/0x9db
[  641.636861]  [<ffffffff811e9966>] __alloc_pages_nodemask+0x456/0x4e0
[  641.644836]  [<ffffffff81249a0e>] alloc_pages_vma+0xbe/0x2d0
[  641.648426]  [<ffffffff812214fc>] handle_mm_fault+0xdfc/0x1010
[  641.652060]  [<ffffffff8122075b>] ? handle_mm_fault+0x5b/0x1010
[  641.655846]  [<ffffffff810783a5>] ? __do_page_fault+0x175/0x530
[  641.659547]  [<ffffffff8107847a>] __do_page_fault+0x24a/0x530
[  641.663145]  [<ffffffff81078790>] do_page_fault+0x30/0x80
[  641.666539]  [<ffffffff8175b598>] page_fault+0x28/0x30
[  641.669944] Mem-Info:
[  650.149133] active_anon:304795 inactive_anon:13357 isolated_anon:0
[  650.149133]  active_file:422 inactive_file:668 isolated_file:37
[  650.149133]  unevictable:0 dirty:0 writeback:0 unstable:0
[  650.149133]  slab_reclaimable:9296 slab_unreclaimable:32181
[  650.149133]  mapped:2489 shmem:13874 pagetables:9351 bounce:0
[  650.149133]  free:12820 free_pcp:60 free_cma:0
[  651.713701] a.out(16970): page allocation stalls for 10004ms, order:0 mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  652.714719] __alloc_pages_slowpath: 27287 callbacks suppressed
[  652.714722] a.out(17089): page allocation stalls for 10829ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  653.715782] __alloc_pages_slowpath: 59740 callbacks suppressed
[  653.715785] a.out(16619): page allocation stalls for 11930ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  654.716880] __alloc_pages_slowpath: 58342 callbacks suppressed
[  654.716883] qmgr(2570): page allocation stalls for 12036ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  655.717483] __alloc_pages_slowpath: 57454 callbacks suppressed
[  655.717486] a.out(16860): page allocation stalls for 13965ms, order:0 mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  656.718605] __alloc_pages_slowpath: 57881 callbacks suppressed
[  656.718608] a.out(16596): page allocation stalls for 14928ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  657.719694] __alloc_pages_slowpath: 52753 callbacks suppressed
[  657.719696] a.out(16960): page allocation stalls for 15266ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  658.720810] __alloc_pages_slowpath: 57183 callbacks suppressed
[  658.720813] a.out(17435): page allocation stalls for 16999ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  659.721904] __alloc_pages_slowpath: 58473 callbacks suppressed
[  659.721907] systemd-journal(375): page allocation stalls for 17036ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  660.722496] __alloc_pages_slowpath: 57207 callbacks suppressed
[  660.722499] a.out(17232): page allocation stalls for 18907ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  661.723612] __alloc_pages_slowpath: 55834 callbacks suppressed
[  661.723615] a.out(16819): page allocation stalls for 19933ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  662.750823] __alloc_pages_slowpath: 40948 callbacks suppressed
[  662.750826] kworker/3:3(11291): page allocation stalls for 20085ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  663.751839] __alloc_pages_slowpath: 59668 callbacks suppressed
[  663.751842] a.out(17055): page allocation stalls for 22030ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  664.753591] __alloc_pages_slowpath: 59260 callbacks suppressed
[  664.753593] master(2528): page allocation stalls for 17258ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  665.754543] __alloc_pages_slowpath: 59829 callbacks suppressed
[  665.754546] a.out(17113): page allocation stalls for 23924ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  666.755642] __alloc_pages_slowpath: 57192 callbacks suppressed
[  666.755645] postgres(2888): page allocation stalls for 11047ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  667.756734] __alloc_pages_slowpath: 61894 callbacks suppressed
[  667.756737] a.out(16608): page allocation stalls for 25858ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  668.757861] __alloc_pages_slowpath: 65951 callbacks suppressed
[  668.757863] a.out(17212): page allocation stalls for 26891ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  669.758474] __alloc_pages_slowpath: 66800 callbacks suppressed
[  669.758477] a.out(16920): page allocation stalls for 27908ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  670.759554] __alloc_pages_slowpath: 69374 callbacks suppressed
[  670.759557] qmgr(2570): page allocation stalls for 28079ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  671.760661] __alloc_pages_slowpath: 64171 callbacks suppressed
[  671.760664] crond(495): page allocation stalls for 29050ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  672.761787] __alloc_pages_slowpath: 55733 callbacks suppressed
[  672.761790] smbd(3561): page allocation stalls for 15833ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  673.762858] __alloc_pages_slowpath: 53271 callbacks suppressed
[  673.762861] mysqld(13418): page allocation stalls for 16925ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  674.763473] __alloc_pages_slowpath: 53489 callbacks suppressed
[  674.763476] systemd(1): page allocation stalls for 32088ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  675.764578] __alloc_pages_slowpath: 52748 callbacks suppressed
[  675.764580] a.out(16854): page allocation stalls for 34003ms, order:0 mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  676.765699] __alloc_pages_slowpath: 55054 callbacks suppressed
[  676.765702] a.out(16713): page allocation stalls for 34107ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  677.766782] __alloc_pages_slowpath: 59519 callbacks suppressed
[  677.766785] a.out(17096): page allocation stalls for 35108ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  678.767901] __alloc_pages_slowpath: 59092 callbacks suppressed
[  678.767904] a.out(17223): page allocation stalls for 36968ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  679.768499] __alloc_pages_slowpath: 58356 callbacks suppressed
[  679.768502] a.out(16979): page allocation stalls for 37938ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  680.769611] __alloc_pages_slowpath: 59518 callbacks suppressed
[  680.769614] auditd(420): page allocation stalls for 10422ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  681.770568] __alloc_pages_slowpath: 59785 callbacks suppressed
[  681.770571] a.out(16754): page allocation stalls for 39522ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  682.771814] __alloc_pages_slowpath: 56695 callbacks suppressed
[  682.771817] a.out(17162): page allocation stalls for 40981ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  683.773081] __alloc_pages_slowpath: 59588 callbacks suppressed
[  683.773084] mysqld(13418): page allocation stalls for 26935ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
** 36364 printk messages dropped ** [  904.221613]  [<ffffffffa0297836>] kmem_alloc+0x96/0x120 [xfs]
[  904.221614]  [<ffffffff81254639>] ? kfree+0x1f9/0x330
** 15 printk messages dropped ** [  904.221733] a.out           R  running task    12312 17361  16548 0x00000080
[  904.221734]  0000000000000000 ffff88003ee3a140 ffff88004d808040 ffff88003eed8040
** 18 printk messages dropped ** [  904.221797]  [<ffffffffa0297b86>] ? kmem_zone_alloc+0x96/0x120 [xfs]
** 15 printk messages dropped ** [  904.221977]  [<ffffffffa025cbcb>] xfs_vm_writepages+0x6b/0xb0 [xfs]
[  904.221978]  [<ffffffff811ef141>] do_writepages+0x21/0x40
** 19 printk messages dropped ** [  904.222046]  [<ffffffff81282020>] __alloc_pages_slowpath+0x8d4/0x9db
[  904.222048]  [<ffffffff811e9966>] __alloc_pages_nodemask+0x456/0x4e0
** 14 printk messages dropped ** [  904.222163]  [<ffffffff810f723f>] ? up_read+0x1f/0x40
[  904.222179]  [<ffffffffa025ee09>] xfs_map_blocks+0x309/0x550 [xfs]
** 16 printk messages dropped ** [  904.222265]  ffff8800753da218 ffffc900121474b0 ffffffff817524d8 ffffffff813a55b6
[  904.222266]  0000000000000000 ffff8800753da218 0000000000000292 ffff88003eeda540
[  904.222266] Call Trace:
** 24 printk messages dropped ** [  904.222419]  [<ffffffffa025f293>] xfs_do_writepage+0x243/0x940 [xfs]
[  904.222421]  [<ffffffff811ecf7b>] write_cache_pages+0x2cb/0x6b0
[  904.222435]  [<ffffffffa025f050>] ? xfs_map_blocks+0x550/0x550 [xfs]
** 25 printk messages dropped ** [  904.222503]  [<ffffffff81252e9a>] new_slab+0x4ca/0x6a0
[  904.222504]  [<ffffffff81255091>] ___slab_alloc+0x3a1/0x620
** 16 printk messages dropped ** [  904.222704]  [<ffffffffa025cba8>] ? xfs_vm_writepages+0x48/0xb0 [xfs]
[  904.222717]  [<ffffffffa025cbcb>] xfs_vm_writepages+0x6b/0xb0 [xfs]
** 15 printk messages dropped ** [  904.222753]  [<ffffffff813a55b6>] ? debug_object_activate+0x166/0x210
** 13 printk messages dropped ** [  904.222812]  [<ffffffffa0297b86>] ? kmem_zone_alloc+0x96/0x120 [xfs]
[  904.222813]  [<ffffffff812555f8>] kmem_cache_alloc+0x2e8/0x370
** 15 printk messages dropped ** [  904.222994]  [<ffffffff811ef141>] do_writepages+0x21/0x40
[  904.222994]  [<ffffffff811deff6>] __filemap_fdatawrite_range+0xc6/0x100
** 16 printk messages dropped ** [  904.223062]  [<ffffffff81127910>] ? lock_timer_base+0xa0/0xa0
[  904.223063]  [<ffffffff8175840a>] schedule_timeout_uninterruptible+0x2a/0x30
** 21 printk messages dropped ** [  904.223239]  [<ffffffffa025cba8>] ? xfs_vm_writepages+0x48/0xb0 [xfs]
[  904.223253]  [<ffffffffa025cbcb>] xfs_vm_writepages+0x6b/0xb0 [xfs]
** 15 printk messages dropped ** [  904.223288]  [<ffffffff813a55b6>] ? debug_object_activate+0x166/0x210
** 10 printk messages dropped ** [  904.223299]  [<ffffffff812f9ce0>] iomap_write_begin+0x50/0xd0
** 7 printk messages dropped ** [  904.223334]  [<ffffffffa0271890>] xfs_file_write_iter+0x90/0x130 [xfs]
[  904.223335]  [<ffffffff812870b5>] __vfs_write+0xe5/0x140
** 16 printk messages dropped ** [  904.223354]  [<ffffffff81282020>] __alloc_pages_slowpath+0x8d4/0x9db
[  904.223355]  [<ffffffff811e9966>] __alloc_pages_nodemask+0x456/0x4e0
** 1 printk messages dropped ** [  904.223357]  [<ffffffff81247507>] alloc_pages_current+0x97/0x1b0
[  904.223377]  [<ffffffffa02c5acb>] xfs_buf_allocate_memory+0x160/0x29b [xfs]
[  904.223393]  [<ffffffffa026895e>] xfs_buf_get_map+0x2be/0x480 [xfs]
[  904.223407]  [<ffffffffa026a1fc>] xfs_buf_read_map+0x2c/0x400 [xfs]
[  904.223426]  [<ffffffffa02b2e41>] xfs_trans_read_buf_map+0x201/0x810 [xfs]
[  904.223440]  [<ffffffffa021b4f8>] xfs_btree_read_buf_block.constprop.34+0x78/0xc0 [xfs]
[  904.223453]  [<ffffffffa021b5c2>] xfs_btree_lookup_get_block+0x82/0xf0 [xfs]
[  904.223467]  [<ffffffffa0221cdb>] xfs_btree_lookup+0xbb/0x700 [xfs]
[  904.223468]  [<ffffffff81255567>] ? kmem_cache_alloc+0x257/0x370
[  904.223479]  [<ffffffffa01f322b>] xfs_alloc_lookup_eq+0x1b/0x20 [xfs]
(...snipped...)
[  904.275264] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=6 idle: 16534 9227 15482 12337 11293
[  904.275266] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 19 15486
[  904.275268] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=6s workers=2 manager: 9235
[  904.275270] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 12339 284
[  904.275272] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 16524 35
[  904.275301] pool 128: cpus=0-63 flags=0x4 nice=0 hung=13s workers=3 idle: 6 57
[  905.018641] __alloc_pages_slowpath: 63439 callbacks suppressed
[  905.018644] a.out(17124): page allocation stalls for 262560ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  906.019716] __alloc_pages_slowpath: 88258 callbacks suppressed
[  906.019719] a.out(17062): page allocation stalls for 263854ms, order:0 mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  907.020846] __alloc_pages_slowpath: 85003 callbacks suppressed
[  907.020848] systemd-logind(493): page allocation stalls for 245959ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  908.021420] __alloc_pages_slowpath: 87775 callbacks suppressed
[  908.021423] auditd(420): page allocation stalls for 237674ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  909.022556] __alloc_pages_slowpath: 83301 callbacks suppressed
[  909.022559] dhclient(864): page allocation stalls for 18275ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  910.023673] __alloc_pages_slowpath: 76616 callbacks suppressed
[  910.023676] a.out(17000): page allocation stalls for 268270ms, order:0 mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  911.024731] __alloc_pages_slowpath: 82055 callbacks suppressed
[  911.024751] postgres(2883): page allocation stalls for 20263ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  912.025845] __alloc_pages_slowpath: 88979 callbacks suppressed
[  912.025848] a.out(16615): page allocation stalls for 270240ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  913.026457] __alloc_pages_slowpath: 87008 callbacks suppressed
[  913.026460] a.out(17032): page allocation stalls for 271305ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  914.027564] __alloc_pages_slowpath: 86030 callbacks suppressed
[  914.027567] tuned(3478): page allocation stalls for 23289ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  915.028668] __alloc_pages_slowpath: 84050 callbacks suppressed
[  915.028671] crond(495): page allocation stalls for 272318ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  916.029762] __alloc_pages_slowpath: 81937 callbacks suppressed
[  916.029765] a.out(17363): page allocation stalls for 274239ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  917.030882] __alloc_pages_slowpath: 76745 callbacks suppressed
[  917.030885] smbd(3526): page allocation stalls for 240888ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
(...snipped...)
[ 1018.148501] __alloc_pages_slowpath: 76879 callbacks suppressed
[ 1018.148503] postgres(2883): page allocation stalls for 127387ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1019.149587] __alloc_pages_slowpath: 87666 callbacks suppressed
[ 1019.149590] a.out(16891): page allocation stalls for 377428ms, order:0 mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[ 1020.152735] __alloc_pages_slowpath: 86402 callbacks suppressed
[ 1020.152737] kworker/1:7(16532): page allocation stalls for 75028ms, order:0 mode:0x2400000(GFP_NOIO)
[ 1020.872273] sysrq: SysRq : Terminate All Tasks
[ 1022.822657] systemd-journald[375]: /dev/kmsg buffer overrun, some messages lost.
[ 1023.161592] systemd-journald[375]: Received SIGTERM.
[ 1024.438089] audit: type=1305 audit(1481767291.051:348): audit_pid=0 old=420 auid=4294967295 ses=4294967295 res=1
[ 1025.616706] audit: type=2404 audit(1481767292.230:349): pid=1055 uid=0 auid=4294967295 ses=4294967295 msg='op=destroy kind=server fp=19:e2:36:ac:65:24:ca:d6:dd:ff:6a:aa:76:25:73:f3 direction=? s
pid=1055 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
[ 1025.616841] audit: type=2404 audit(1481767292.230:350): pid=1055 uid=0 auid=4294967295 ses=4294967295 msg='op=destroy kind=server fp=09:0b:6a:93:3e:e3:59:e1:79:8a:6e:2e:a9:05:59:94 direction=? spid=1055 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
[ 1025.616898] audit: type=2404 audit(1481767292.230:351): pid=1055 uid=0 auid=4294967295 ses=4294967295 msg='op=destroy kind=server fp=95:0b:7d:ce:9e:bd:01:8c:d9:0e:be:7c:f3:b7:96:0d direction=? spid=1055 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
[ 1025.784671] audit: type=1104 audit(1481767292.398:352): pid=1083 uid=0 auid=1000 ses=1 msg='op=PAM:setcred grantors=pam_securetty,pam_unix acct="kumaneko" exe="/usr/bin/login" hostname=? addr=? terminal=tty1 res=success'
[ 1026.242786] audit: type=1325 audit(1481767292.856:353): table=nat family=2 entries=52
[ 1026.244646] audit: type=1300 audit(1481767292.856:353): arch=c000003e syscall=54 success=yes exit=0 a0=4 a1=0 a2=40 a3=17e0bc0 items=0 ppid=491 pid=17592 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="iptables" exe="/usr/sbin/xtables-multi" key=(null)
[ 1026.244670] audit: type=1327 audit(1481767292.856:353): proctitle=2F7362696E2F69707461626C6573002D7732002D74006E6174002D46
[ 1026.292520] audit: type=1325 audit(1481767292.906:354): table=nat family=2 entries=35
[ 1026.293085] audit: type=1300 audit(1481767292.906:354): arch=c000003e syscall=54 success=yes exit=0 a0=4 a1=0 a2=40 a3=1208a60 items=0 ppid=491 pid=17599 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="iptables" exe="/usr/sbin/xtables-multi" key=(null)
[ 1033.283379] Ebtables v2.0 unregistered
[ 1060.441909] Node 0 active_anon:1044024kB inactive_anon:56280kB active_file:13396kB inactive_file:51668kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:10516kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 544768kB anon_thp: 57748kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? no
[ 1060.441912] Node 0 DMA free:6700kB min:440kB low:548kB high:656kB active_anon:9168kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1060.441914] lowmem_reserve[]: 0 1566 1566 1566
[ 1060.441916] Node 0 DMA32 free:274100kB min:44612kB low:55764kB high:66916kB active_anon:1034856kB inactive_anon:56280kB active_file:13396kB inactive_file:51668kB unevictable:0kB writepending:0kB present:2080640kB managed:1604544kB mlocked:0kB slab_reclaimable:37076kB slab_unreclaimable:87724kB kernel_stack:2944kB pagetables:3528kB bounce:0kB free_pcp:2360kB local_pcp:728kB free_cma:0kB
[ 1060.441917] lowmem_reserve[]: 0 0 0 0
[ 1060.441922] Node 0 DMA: 1*4kB (U) 1*8kB (U) 2*16kB (UM) 2*32kB (UM) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 2*1024kB (UM) 0*2048kB 1*4096kB (M) = 6700kB
[ 1060.441927] Node 0 DMA32: 385*4kB (UME) 486*8kB (UME) 1556*16kB (UMH) 1044*32kB (UMEH) 603*64kB (UME) 324*128kB (UMEH) 59*256kB (UMEH) 11*512kB (UME) 21*1024kB (UME) 31*2048kB (ME) 6*4096kB (M) = 274100kB
[ 1060.441930] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 1060.441932] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1060.441932] 30702 total pagecache pages
[ 1060.441933] 0 pages in swap cache
[ 1060.441934] Swap cache stats: add 0, delete 0, find 0/0
[ 1060.441934] Free swap  = 0kB
[ 1060.441934] Total swap = 0kB
[ 1060.441935] 524157 pages RAM
[ 1060.441935] 0 pages HighMem/MovableOnly
[ 1060.441935] 119045 pages reserved
[ 1060.441936] 0 pages cma reserved
[ 1060.441936] 0 pages hwpoisoned
[ 1060.441937] Out of memory: Kill process 16549 (a.out) score 999 or sacrifice child
[ 1060.609985] audit_printk_skb: 381 callbacks suppressed
--------------------

show_mem() from dump_header() started at uptime = 641.
Something preempted into show_mem() and output suspended at uptime = 650.
One-liner stall report started from uptime = 651.

However, increment of uptime counter is obviously slower than real time clock.
I pressed SysRq-t at uptime = 683 after waiting for a few minutes from uptime = 651.
Then, uptime counter was updated to 904 (probably real time clock) and output from
SysRq-t started (although hopelessly dropped).

I pressed SysRq-e at uptime = 1020. SysRq-e took about a half minute to complete.
Then, uptime counter was updated to 1060 (probably real time clock) and output from
show_mem() resumed. Finally, "Out of memory:" line at uptime = 1060 which was
expected to be printed by uptime = 642 was printed. So, oom_lock was held for
at least 5 minutes.



I don't know why increment of uptime counter became slow.
Since stall_timeout is updated for only once per a (slowed down) second
due to ratelimit, "__alloc_pages_slowpath: XXXXX callbacks suppressed"
represents total number of attempts that reached there for each second.
We can see that XXXXX is between 60000 and 80000. From CONFIG_HZ = 1000
and using 4 CPUs, 15 to 20 attempts reached there for every HZ on each CPU.
(This stressor generates 1024 processes but most of them are simply blocked
on fs locks. Thus, I assume this estimation is not bogus.) Thus, I think
15 to 20 threads running on each CPU are eating that CPU's time (although
there might be some overhead from other than these 15 to 20 threads).

Thus, my guess is that something deferred the OOM killer, and pointless
direct reclaim loop due to "!mutex_trylock(&oom_lock)" (or some overhead
not from the thread doing direct reclaim loop) accelerated deferral of
the OOM killer by consuming almost all CPU time.

This stall lasted with only two kernel messages per a second. I wonder we
have room for tuning warn_alloc() unless the trigger is identified and fixed.
Maybe because I'm using VMware Player. But I don't have a native machine
to test. I appreciate if someone can test using a native machine or KVM.
My environment is "4 CPUs, 2GB RAM, /dev/sda1 for / partition formatted as
XFS, no swap partition or file" on VMware Player on Windows using SATA disk
and the stressor is
http://lkml.kernel.org/r/201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp .



> Isn't that what your test case essentially does though? Keep the system
> in OOM continually? Some stalls are to be expected I guess, the main
> question is whether there is a point with no progress at all.

No. The purpose of running this testcase which keeps the system in almost
OOM situation is to find and report problems which occur when the system is
almost OOM (but that should go to kmallocwd thread). Lockups with oom_lock
held (the subject of this thread) is an obstacle for me when testing almost
OOM situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
