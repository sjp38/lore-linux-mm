Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 961F26B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 04:33:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t25so8706339pfg.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 01:33:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id o7si3006355pae.227.2016.10.19.01.33.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 01:33:08 -0700 (PDT)
Date: Wed, 19 Oct 2016 10:33:04 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20161019083304.GD3102@twins.programming.kicks-ass.net>
References: <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160519081146.GS3193@twins.programming.kicks-ass.net>
 <20160520001714.GC26977@dastard>
 <20160601131758.GO26601@dhcp22.suse.cz>
 <20160601181617.GV3190@twins.programming.kicks-ass.net>
 <20161006130454.GI10570@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161006130454.GI10570@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 06, 2016 at 03:04:54PM +0200, Michal Hocko wrote:
> From 04b3923e5b12f0eb3859f0718881fa0f40e60164 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 13 May 2016 17:47:31 +0200
> Subject: [PATCH] lockdep: allow to disable reclaim lockup detection
> 
> The current implementation of the reclaim lockup detection can lead to
> false positives and those even happen and usually lead to tweak the
> code to silence the lockdep by using GFP_NOFS even though the context
> can use __GFP_FS just fine. See
> http://lkml.kernel.org/r/20160512080321.GA18496@dastard as an example.
> 
> =================================
> [ INFO: inconsistent lock state ]
> 4.5.0-rc2+ #4 Tainted: G           O
> ---------------------------------
> inconsistent {RECLAIM_FS-ON-R} -> {IN-RECLAIM_FS-W} usage.
> kswapd0/543 [HC0[0]:SC0[0]:HE1:SE1] takes:
> 
> (&xfs_nondir_ilock_class){++++-+}, at: [<ffffffffa00781f7>] xfs_ilock+0x177/0x200 [xfs]
> 
> {RECLAIM_FS-ON-R} state was registered at:
>   [<ffffffff8110f369>] mark_held_locks+0x79/0xa0
>   [<ffffffff81113a43>] lockdep_trace_alloc+0xb3/0x100
>   [<ffffffff81224623>] kmem_cache_alloc+0x33/0x230
>   [<ffffffffa008acc1>] kmem_zone_alloc+0x81/0x120 [xfs]
>   [<ffffffffa005456e>] xfs_refcountbt_init_cursor+0x3e/0xa0 [xfs]
>   [<ffffffffa0053455>] __xfs_refcount_find_shared+0x75/0x580 [xfs]
>   [<ffffffffa00539e4>] xfs_refcount_find_shared+0x84/0xb0 [xfs]
>   [<ffffffffa005dcb8>] xfs_getbmap+0x608/0x8c0 [xfs]
>   [<ffffffffa007634b>] xfs_vn_fiemap+0xab/0xc0 [xfs]
>   [<ffffffff81244208>] do_vfs_ioctl+0x498/0x670
>   [<ffffffff81244459>] SyS_ioctl+0x79/0x90
>   [<ffffffff81847cd7>] entry_SYSCALL_64_fastpath+0x12/0x6f
> 
>        CPU0
>        ----
>   lock(&xfs_nondir_ilock_class);
>   <Interrupt>
>     lock(&xfs_nondir_ilock_class);
> 
>  *** DEADLOCK ***
> 
> 3 locks held by kswapd0/543:
> 
> stack backtrace:
> CPU: 0 PID: 543 Comm: kswapd0 Tainted: G           O    4.5.0-rc2+ #4
> 
> Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
> 
>  ffffffff82a34f10 ffff88003aa078d0 ffffffff813a14f9 ffff88003d8551c0
>  ffff88003aa07920 ffffffff8110ec65 0000000000000000 0000000000000001
>  ffff880000000001 000000000000000b 0000000000000008 ffff88003d855aa0
> Call Trace:
>  [<ffffffff813a14f9>] dump_stack+0x4b/0x72
>  [<ffffffff8110ec65>] print_usage_bug+0x215/0x240
>  [<ffffffff8110ee85>] mark_lock+0x1f5/0x660
>  [<ffffffff8110e100>] ? print_shortest_lock_dependencies+0x1a0/0x1a0
>  [<ffffffff811102e0>] __lock_acquire+0xa80/0x1e50
>  [<ffffffff8122474e>] ? kmem_cache_alloc+0x15e/0x230
>  [<ffffffffa008acc1>] ? kmem_zone_alloc+0x81/0x120 [xfs]
>  [<ffffffff811122e8>] lock_acquire+0xd8/0x1e0
>  [<ffffffffa00781f7>] ? xfs_ilock+0x177/0x200 [xfs]
>  [<ffffffffa0083a70>] ? xfs_reflink_cancel_cow_range+0x150/0x300 [xfs]
>  [<ffffffff8110aace>] down_write_nested+0x5e/0xc0
>  [<ffffffffa00781f7>] ? xfs_ilock+0x177/0x200 [xfs]
>  [<ffffffffa00781f7>] xfs_ilock+0x177/0x200 [xfs]
>  [<ffffffffa0083a70>] xfs_reflink_cancel_cow_range+0x150/0x300 [xfs]
>  [<ffffffffa0085bdc>] xfs_fs_evict_inode+0xdc/0x1e0 [xfs]
>  [<ffffffff8124d7d5>] evict+0xc5/0x190
>  [<ffffffff8124d8d9>] dispose_list+0x39/0x60
>  [<ffffffff8124eb2b>] prune_icache_sb+0x4b/0x60
>  [<ffffffff8123317f>] super_cache_scan+0x14f/0x1a0
>  [<ffffffff811e0d19>] shrink_slab.part.63.constprop.79+0x1e9/0x4e0
>  [<ffffffff811e50ee>] shrink_zone+0x15e/0x170
>  [<ffffffff811e5ef1>] kswapd+0x4f1/0xa80
>  [<ffffffff811e5a00>] ? zone_reclaim+0x230/0x230
>  [<ffffffff810e6882>] kthread+0xf2/0x110
>  [<ffffffff810e6790>] ? kthread_create_on_node+0x220/0x220
>  [<ffffffff8184803f>] ret_from_fork+0x3f/0x70
>  [<ffffffff810e6790>] ? kthread_create_on_node+0x220/0x220
> 
> To quote Dave:
> "
> Ignoring whether reflink should be doing anything or not, that's a
> "xfs_refcountbt_init_cursor() gets called both outside and inside
> transactions" lockdep false positive case. The problem here is
> lockdep has seen this allocation from within a transaction, hence a
> GFP_NOFS allocation, and now it's seeing it in a GFP_KERNEL context.
> Also note that we have an active reference to this inode.
> 
> So, because the reclaim annotations overload the interrupt level
> detections and it's seen the inode ilock been taken in reclaim
> ("interrupt") context, this triggers a reclaim context warning where
> it thinks it is unsafe to do this allocation in GFP_KERNEL context
> holding the inode ilock...
> "
> 
> This sounds like a fundamental problem of the reclaim lock detection.
> It is really impossible to annotate such a special usecase IMHO unless
> the reclaim lockup detection is reworked completely. Until then it
> is much better to provide a way to add "I know what I am doing flag"
> and mark problematic places. This would prevent from abusing GFP_NOFS
> flag which has a runtime effect even on configurations which have
> lockdep disabled.
> 
> Introduce __GFP_NOLOCKDEP flag which tells the lockdep gfp tracking to
> skip the current allocation request.
> 
> While we are at it also make sure that the radix tree doesn't
> accidentaly override tags stored in the upper part of the gfp_mask.
> 
> Suggested-by: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

So I'm all for this if this works for Dave.

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Please take it through the XFS tree which would introduce its first user
etc..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
