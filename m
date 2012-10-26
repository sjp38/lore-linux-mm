Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 8330B6B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 14:48:07 -0400 (EDT)
Date: Fri, 26 Oct 2012 14:48:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: spinning in isolate_migratepages_range on busy nfs server
Message-ID: <20121026184805.GB13094@fieldses.org>
References: <20121025164722.GE6846@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121025164722.GE6846@fieldses.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, bmarson@redhat.com

On Thu, Oct 25, 2012 at 12:47:22PM -0400, bfields wrote:
> We're seeing an nfs server on a 3.6-ish kernel lock up after running
> specfs for a while.
> 
> Looking at the logs, there are some hung task warnings showing nfsd
> threads stuck on directory i_mutexes trying to do lookups.
> 
> A sysrq-t dump showed there were also lots of threads holding those
> i_mutexes while trying to allocate xfs inodes:
> 
>  	nfsd            R running task        0  6517      2 0x00000080
>  	 ffff880f925074c0 0000000000000046 ffff880fe4718000 ffff880f92507fd8
>  	 ffff880f92507fd8 ffff880f92507fd8 ffff880fd7920000 ffff880fe4718000
>  	 0000000000000000 ffff880f92506000 ffff88102ffd96c0 ffff88102ffd9b40
>  	Call Trace:
>  	[<ffffffff81091aaa>] __cond_resched+0x2a/0x40
>  	[<ffffffff815d3750>] _cond_resched+0x30/0x40
>  	[<ffffffff81150e92>] isolate_migratepages_range+0xb2/0x550
>  	[<ffffffff811507c0>] ?  compact_checklock_irqsave.isra.17+0xe0/0xe0
>  	[<ffffffff81151536>] compact_zone+0x146/0x3f0
>  	[<ffffffff81151a92>] compact_zone_order+0x82/0xc0
>  	[<ffffffff81151bb1>] try_to_compact_pages+0xe1/0x110
>  	[<ffffffff815c99e2>] __alloc_pages_direct_compact+0xaa/0x190
>  	[<ffffffff81138317>] __alloc_pages_nodemask+0x517/0x980
>  	[<ffffffff81088a00>] ? __synchronize_srcu+0xf0/0x110
>  	[<ffffffff81171e30>] alloc_pages_current+0xb0/0x120
>  	[<ffffffff8117b015>] new_slab+0x265/0x310
>  	[<ffffffff815caefc>] __slab_alloc+0x358/0x525
>  	[<ffffffffa05625a7>] ? kmem_zone_alloc+0x67/0xf0 [xfs]
>  	[<ffffffff81088c72>] ? up+0x32/0x50
>  	[<ffffffffa05625a7>] ? kmem_zone_alloc+0x67/0xf0 [xfs]
>  	[<ffffffff8117b4ef>] kmem_cache_alloc+0xff/0x130
>  	[<ffffffffa05625a7>] kmem_zone_alloc+0x67/0xf0 [xfs]
>  	[<ffffffffa0552f49>] xfs_inode_alloc+0x29/0x270 [xfs]
>  	[<ffffffffa0553801>] xfs_iget+0x231/0x6c0 [xfs]
>  	[<ffffffffa0560687>] xfs_lookup+0xe7/0x110 [xfs]
>  	[<ffffffffa05583e1>] xfs_vn_lookup+0x51/0x90 [xfs]
>  	[<ffffffff81193e9d>] lookup_real+0x1d/0x60
>  	[<ffffffff811940b8>] __lookup_hash+0x38/0x50
>  	[<ffffffff81197e26>] lookup_one_len+0xd6/0x110
>  	[<ffffffffa034667b>] nfsd_lookup_dentry+0x12b/0x4a0 [nfsd]
>  	[<ffffffffa0346a69>] nfsd_lookup+0x79/0x140 [nfsd]
>  	[<ffffffffa034fb5f>] nfsd3_proc_lookup+0xef/0x1c0 [nfsd]
>  	[<ffffffffa0341bbb>] nfsd_dispatch+0xeb/0x230 [nfsd]
>  	[<ffffffffa02ee3a8>] svc_process_common+0x328/0x6d0 [sunrpc]
>  	[<ffffffffa02eeaa2>] svc_process+0x102/0x150 [sunrpc]
>  	[<ffffffffa0341115>] nfsd+0xb5/0x1a0 [nfsd]
>  	[<ffffffffa0341060>] ? nfsd_get_default_max_blksize+0x60/0x60 [nfsd]
>  	[<ffffffff81082613>] kthread+0x93/0xa0
>  	[<ffffffff815ddc34>] kernel_thread_helper+0x4/0x10
>  	[<ffffffff81082580>] ? kthread_freezable_should_stop+0x70/0x70
>  	[<ffffffff815ddc30>] ? gs_change+0x13/0x13
> 
> And perf --call-graph also shows we're spending all our time in the same
> place, spinning on a lock (zone->lru_lock, I assume):
> 
>  -  92.65%           nfsd  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave
>     - _raw_spin_lock_irqsave
>        - 99.86% isolate_migratepages_range
> 
> Just grepping through logs, I ran across 2a1402aa04 "mm: compaction:
> acquire the zone->lru_lock as late as possible", in v3.7-rc1, which
> looks relevant:
> 
> 	Richard Davies and Shaohua Li have both reported lock contention
> 	problems in compaction on the zone and LRU locks as well as
> 	significant amounts of time being spent in compaction.  This
> 	series aims to reduce lock contention and scanning rates to
> 	reduce that CPU usage.  Richard reported at
> 	https://lkml.org/lkml/2012/9/21/91 that this series made a big
> 	different to a problem he reported in August:
> 			        
> 		http://marc.info/?l=kvm&m=134511507015614&w=2
> 
> So we're trying that.  Is there anything else we should try?

Confirmed, applying that to 3.6 seems to fix the problem.

--b.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
