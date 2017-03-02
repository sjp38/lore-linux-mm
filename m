Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79CB96B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 08:09:40 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 65so90725995pgi.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 05:09:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k7si7417482pln.183.2017.03.02.05.09.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 05:09:39 -0800 (PST)
Subject: Re: mm allocation failure and hang when running xfstests generic/269 on xfs
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <42eb5d53-5ceb-a9ce-791a-9469af30810c@I-love.SAKURA.ne.jp>
	<20170302103520.GC1404@dhcp22.suse.cz>
	<20170302122426.GA3213@bfoster.bfoster>
	<20170302124909.GE1404@dhcp22.suse.cz>
	<20170302130009.GC3213@bfoster.bfoster>
In-Reply-To: <20170302130009.GC3213@bfoster.bfoster>
Message-Id: <201703022207.AGC56244.FMVQLOFtFSJHOO@I-love.SAKURA.ne.jp>
Date: Thu, 2 Mar 2017 22:07:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bfoster@redhat.com, mhocko@kernel.org
Cc: xzhou@redhat.com, hch@infradead.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Brian Foster wrote:
> On Thu, Mar 02, 2017 at 01:49:09PM +0100, Michal Hocko wrote:
> > On Thu 02-03-17 07:24:27, Brian Foster wrote:
> > > On Thu, Mar 02, 2017 at 11:35:20AM +0100, Michal Hocko wrote:
> > > > On Thu 02-03-17 19:04:48, Tetsuo Handa wrote:
> > > > [...]
> > > > > So, commit 5d17a73a2ebeb8d1("vmalloc: back off when the current task is
> > > > > killed") implemented __GFP_KILLABLE flag and automatically applied that
> > > > > flag. As a result, those who are not ready to fail upon SIGKILL are
> > > > > confused. ;-)
> > > > 
> > > > You are right! The function is documented it might fail but the code
> > > > doesn't really allow that. This seems like a bug to me. What do you
> > > > think about the following?
> > > > ---
> > > > From d02cb0285d8ce3344fd64dc7e2912e9a04bef80d Mon Sep 17 00:00:00 2001
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > Date: Thu, 2 Mar 2017 11:31:11 +0100
> > > > Subject: [PATCH] xfs: allow kmem_zalloc_greedy to fail
> > > > 
> > > > Even though kmem_zalloc_greedy is documented it might fail the current
> > > > code doesn't really implement this properly and loops on the smallest
> > > > allowed size for ever. This is a problem because vzalloc might fail
> > > > permanently. Since 5d17a73a2ebe ("vmalloc: back off when the current
> > > > task is killed") such a failure is much more probable than it used to
> > > > be. Fix this by bailing out if the minimum size request failed.
> > > > 
> > > > This has been noticed by a hung generic/269 xfstest by Xiong Zhou.
> > > > 
> > > > Reported-by: Xiong Zhou <xzhou@redhat.com>
> > > > Analyzed-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > > ---
> > > >  fs/xfs/kmem.c | 2 ++
> > > >  1 file changed, 2 insertions(+)
> > > > 
> > > > diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> > > > index 339c696bbc01..ee95f5c6db45 100644
> > > > --- a/fs/xfs/kmem.c
> > > > +++ b/fs/xfs/kmem.c
> > > > @@ -34,6 +34,8 @@ kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
> > > >  	size_t		kmsize = maxsize;
> > > >  
> > > >  	while (!(ptr = vzalloc(kmsize))) {
> > > > +		if (kmsize == minsize)
> > > > +			break;
> > > >  		if ((kmsize >>= 1) <= minsize)
> > > >  			kmsize = minsize;
> > > >  	}
> > > 
> > > More consistent with the rest of the kmem code might be to accept a
> > > flags argument and do something like this based on KM_MAYFAIL.
> > 
> > Well, vmalloc doesn't really support GFP_NOFAIL semantic right now for
> > the same reason it doesn't support GFP_NOFS. So I am not sure this is a
> > good idea.
> > 
> 
> Not sure I follow..? I'm just suggesting to control the loop behavior
> based on the KM_ flag, not to do or change anything wrt to GFP_ flags.

vmalloc() cannot support __GFP_NOFAIL. Therefore, kmem_zalloc_greedy()
cannot support !KM_MAYFAIL. We will change kmem_zalloc_greedy() not to
use vmalloc() when we need to support !KM_MAYFAIL. That won't be now.

> 
> > > The one
> > > current caller looks like it would pass it, but I suppose we'd still
> > > need a mechanism to break out should a new caller not pass that flag.
> > > Would a fatal_signal_pending() check in the loop as well allow us to
> > > break out in the scenario that is reproduced here?
> > 
> > Yes that check would work as well I just thought the break out when the
> > minsize request fails to be more logical. There might be other reasons
> > to fail the request and looping here seems just wrong. But whatever you
> > or other xfs people prefer.
> 
> There may be higher level reasons for why this code should or should not
> loop, that just seems like a separate issue to me. My thinking is more
> that this appears to be how every kmem_*() function operates today and
> it seems a bit out of place to change behavior of one to fix a bug.
> 
> Maybe I'm missing something though.. are we subject to the same general
> problem in any of the other kmem_*() functions that can currently loop
> indefinitely?
> 

The kmem code looks to me a source of problems. For example,
kmem_alloc() by RESCUER workqueue threads got stuck doing GFP_NOFS allocation.
Due to __GFP_NOWARN, warn_alloc() cannot warn allocation stalls.
Due to order <= PAGE_ALLOC_COSTLY_ORDER, the
"%s(%u) possible memory allocation deadlock size %u in %s (mode:0x%x)"
message cannot be printed because __alloc_pages_nodemask() does not
return. And due to GFP_NOFS without __GFP_HIGH nor __GFP_NOFAIL,
memory cannot be allocated to RESCUER thread which are trying to
allocate memory for reclaiming memory; the result is silent lockup.
(I must stop here, for this is a different thread.)

----------------------------------------
[ 1095.633625] MemAlloc: xfs-data/sda1(451) flags=0x4228060 switches=45509 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652073
[ 1095.633626] xfs-data/sda1   R  running task    12696   451      2 0x00000000
[ 1095.633663] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.633665] Call Trace:
[ 1095.633668]  __schedule+0x336/0xe00
[ 1095.633671]  schedule+0x3d/0x90
[ 1095.633672]  schedule_timeout+0x20d/0x510
[ 1095.633675]  ? lock_timer_base+0xa0/0xa0
[ 1095.633678]  schedule_timeout_uninterruptible+0x2a/0x30
[ 1095.633680]  __alloc_pages_slowpath+0x2b5/0xd95
[ 1095.633687]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.633699]  alloc_pages_current+0x97/0x1b0
[ 1095.633702]  new_slab+0x4cb/0x6b0
[ 1095.633706]  ___slab_alloc+0x3a3/0x620
[ 1095.633728]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.633730]  ? ___slab_alloc+0x5c6/0x620
[ 1095.633732]  ? cpuacct_charge+0x38/0x1e0
[ 1095.633767]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.633770]  __slab_alloc+0x46/0x7d
[ 1095.633773]  __kmalloc+0x301/0x3b0
[ 1095.633802]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.633804]  ? kfree+0x1fa/0x330
[ 1095.633842]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.633864]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.633883]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.633901]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.633936]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.633954]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.633971]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.633973]  process_one_work+0x22b/0x760
[ 1095.633975]  ? process_one_work+0x194/0x760
[ 1095.633997]  rescuer_thread+0x1f2/0x3d0
[ 1095.634002]  kthread+0x10f/0x150
[ 1095.634003]  ? worker_thread+0x4b0/0x4b0
[ 1095.634004]  ? kthread_create_on_node+0x70/0x70
[ 1095.634007]  ret_from_fork+0x31/0x40
[ 1095.634013] MemAlloc: xfs-eofblocks/s(456) flags=0x4228860 switches=15435 seq=1 gfp=0x1400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=293074
[ 1095.634014] xfs-eofblocks/s R  running task    12032   456      2 0x00000000
[ 1095.634037] Workqueue: xfs-eofblocks/sda1 xfs_eofblocks_worker [xfs]
[ 1095.634038] Call Trace:
[ 1095.634040]  ? _raw_spin_lock+0x3d/0x80
[ 1095.634042]  ? vmpressure+0xd0/0x120
[ 1095.634044]  ? vmpressure+0xd0/0x120
[ 1095.634047]  ? vmpressure_prio+0x21/0x30
[ 1095.634049]  ? do_try_to_free_pages+0x70/0x300
[ 1095.634052]  ? try_to_free_pages+0x131/0x3f0
[ 1095.634058]  ? __alloc_pages_slowpath+0x3ec/0xd95
[ 1095.634065]  ? __alloc_pages_nodemask+0x3e4/0x460
[ 1095.634069]  ? alloc_pages_current+0x97/0x1b0
[ 1095.634111]  ? xfs_buf_allocate_memory+0x160/0x2a3 [xfs]
[ 1095.634133]  ? xfs_buf_get_map+0x2be/0x480 [xfs]
[ 1095.634169]  ? xfs_buf_read_map+0x2c/0x400 [xfs]
[ 1095.634204]  ? xfs_trans_read_buf_map+0x186/0x830 [xfs]
[ 1095.634222]  ? xfs_btree_read_buf_block.constprop.34+0x78/0xc0 [xfs]
[ 1095.634239]  ? xfs_btree_lookup_get_block+0x8a/0x180 [xfs]
[ 1095.634257]  ? xfs_btree_lookup+0xd0/0x3f0 [xfs]
[ 1095.634296]  ? kmem_zone_alloc+0x96/0x120 [xfs]
[ 1095.634299]  ? _raw_spin_unlock+0x27/0x40
[ 1095.634315]  ? xfs_bmbt_lookup_eq+0x1f/0x30 [xfs]
[ 1095.634348]  ? xfs_bmap_del_extent+0x1b2/0x1610 [xfs]
[ 1095.634380]  ? kmem_zone_alloc+0x96/0x120 [xfs]
[ 1095.634400]  ? __xfs_bunmapi+0x4db/0xda0 [xfs]
[ 1095.634421]  ? xfs_bunmapi+0x2b/0x40 [xfs]
[ 1095.634459]  ? xfs_itruncate_extents+0x1df/0x780 [xfs]
[ 1095.634502]  ? xfs_rename+0xc70/0x1080 [xfs]
[ 1095.634525]  ? xfs_free_eofblocks+0x1c4/0x230 [xfs]
[ 1095.634546]  ? xfs_inode_free_eofblocks+0x18d/0x280 [xfs]
[ 1095.634565]  ? xfs_inode_ag_walk.isra.13+0x2b5/0x620 [xfs]
[ 1095.634582]  ? xfs_inode_ag_walk.isra.13+0x91/0x620 [xfs]
[ 1095.634618]  ? xfs_inode_clear_eofblocks_tag+0x1a0/0x1a0 [xfs]
[ 1095.634630]  ? radix_tree_next_chunk+0x10b/0x2d0
[ 1095.634635]  ? radix_tree_gang_lookup_tag+0xd7/0x150
[ 1095.634672]  ? xfs_perag_get_tag+0x11d/0x370 [xfs]
[ 1095.634690]  ? xfs_perag_get_tag+0x5/0x370 [xfs]
[ 1095.634709]  ? xfs_inode_ag_iterator_tag+0x71/0xa0 [xfs]
[ 1095.634726]  ? xfs_inode_clear_eofblocks_tag+0x1a0/0x1a0 [xfs]
[ 1095.634744]  ? __xfs_icache_free_eofblocks+0x3b/0x40 [xfs]
[ 1095.634759]  ? xfs_eofblocks_worker+0x27/0x40 [xfs]
[ 1095.634762]  ? process_one_work+0x22b/0x760
[ 1095.634763]  ? process_one_work+0x194/0x760
[ 1095.634784]  ? rescuer_thread+0x1f2/0x3d0
[ 1095.634788]  ? kthread+0x10f/0x150
[ 1095.634789]  ? worker_thread+0x4b0/0x4b0
[ 1095.634790]  ? kthread_create_on_node+0x70/0x70
[ 1095.634793]  ? ret_from_fork+0x31/0x40
----------------------------------------

> Brian
> 
> > -- 
> > Michal Hocko
> > SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
