Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 834B56B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:25:20 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id o135so17089964qke.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:25:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 3si15444193qkr.154.2017.03.06.05.25.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 05:25:19 -0800 (PST)
Date: Mon, 6 Mar 2017 08:25:18 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
Message-ID: <20170306132517.GB3223@bfoster.bfoster>
References: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
 <20170303133950.GD31582@dhcp22.suse.cz>
 <20170303153720.GC21245@bfoster.bfoster>
 <20170303155258.GJ31499@dhcp22.suse.cz>
 <20170303172904.GE21245@bfoster.bfoster>
 <201703042354.DCH17637.JOHSFOQFFVOMLt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201703042354.DCH17637.JOHSFOQFFVOMLt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Sat, Mar 04, 2017 at 11:54:56PM +0900, Tetsuo Handa wrote:
> Brian Foster wrote:
> > On Fri, Mar 03, 2017 at 04:52:58PM +0100, Michal Hocko wrote:
> > > On Fri 03-03-17 10:37:21, Brian Foster wrote:
> > > [...]
> > > > That aside, looking through some of the traces in this case...
> > > > 
> > > > - kswapd0 is waiting on an inode flush lock. This means somebody else
> > > >   flushed the inode and it won't be unlocked until the underlying buffer
> > > >   I/O is completed. This context is also holding pag_ici_reclaim_lock
> > > >   which is what probably blocks other contexts from getting into inode
> > > >   reclaim.
> > > > - xfsaild is in xfs_iflush(), which means it has the inode flush lock.
> > > >   It's waiting on reading the underlying inode buffer. The buffer read
> > > >   sets b_ioend_wq to the xfs-buf wq, which is ultimately going to be
> > > >   queued in xfs_buf_bio_end_io()->xfs_buf_ioend_async(). The associated
> > > >   work item is what eventually triggers the I/O completion in
> > > >   xfs_buf_ioend().
> > > > 
> > > > So at this point reclaim is waiting on a read I/O completion. It's not
> > > > clear to me whether the read had completed and the work item was queued
> > > > or not. I do see the following in the workqueue lockup BUG output:
> > > > 
> > > > [  273.412600] workqueue xfs-buf/sda1: flags=0xc
> > > > [  273.414486]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/1
> > > > [  273.416415]     pending: xfs_buf_ioend_work [xfs]
> > > > 
> > > > ... which suggests that it was queued..? I suppose this could be one of
> > > > the workqueues waiting on a kthread, but xfs-buf also has a rescuer that
> > > > appears to be idle:
> > > > 
> > > > [ 1041.555227] xfs-buf/sda1    S14904   450      2 0x00000000
> > > > [ 1041.556813] Call Trace:
> > > > [ 1041.557796]  __schedule+0x336/0xe00
> > > > [ 1041.558983]  schedule+0x3d/0x90
> > > > [ 1041.560085]  rescuer_thread+0x322/0x3d0
> > > > [ 1041.561333]  kthread+0x10f/0x150
> > > > [ 1041.562464]  ? worker_thread+0x4b0/0x4b0
> > > > [ 1041.563732]  ? kthread_create_on_node+0x70/0x70
> > > > [ 1041.565123]  ret_from_fork+0x31/0x40
> > > > 
> > > > So shouldn't that thread pick up the work item if that is the case?
> > > 
> > > Is it possible that the progress is done but tediously slow? Keep in
> > > mind that the test case is doing write from 1k processes while one
> > > process basically consumes all the memory. So I wouldn't be surprised
> > > if this just made system to crawl on any attempt to do an IO.
> > 
> > That would seem like a possibility to me.. either waiting on an actual
> > I/O (no guarantee that the pending xfs-buf item is the one we care about
> > I suppose) completion or waiting for whatever needs to happen for the wq
> > infrastructure to kick off the rescuer. Though I think that's probably
> > something Tetsuo would ultimately have to confirm on his setup..
> 
> This lockup began from uptime = 444. Thus, please ignore logs up to
> 
> [  444.281177] Killed process 9477 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  444.287046] oom_reaper: reaped process 9477 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> 
...
> 
> You can't say that 1024 processes were doing write() requests. Many were still
> blocked at open(). Only 20 or so processes were able to consume CPU time for
> memory allocation. I don't think this is a too insane stress to wait. This is not
> a stress which can justify stalls over 10 minutes. The kworker/2:0(27) line
> indicates that order-0 GFP_NOIO allocation request was unable to find a page
> for more than 10 minutes. Under such situation, how can other GFP_NOFS allocation
> requests find a page without boosting priority (unless someone releases memory
> voluntarily) ?

As noted in my previous reply, I'm not sure there's enough here to point
at allocation failure as the root cause. E.g., kswapd is stuck here:

[ 1095.632985] kswapd0         D10776    69      2 0x00000000
[ 1095.632988] Call Trace:
[ 1095.632991]  __schedule+0x336/0xe00
[ 1095.632994]  schedule+0x3d/0x90
[ 1095.632996]  io_schedule+0x16/0x40
[ 1095.633017]  __xfs_iflock+0x129/0x140 [xfs]
[ 1095.633021]  ? autoremove_wake_function+0x60/0x60
[ 1095.633051]  xfs_reclaim_inode+0x162/0x440 [xfs]
[ 1095.633072]  xfs_reclaim_inodes_ag+0x2cf/0x4f0 [xfs]
[ 1095.633106]  ? xfs_reclaim_inodes_ag+0xf2/0x4f0 [xfs]
[ 1095.633114]  ? trace_hardirqs_on+0xd/0x10
[ 1095.633116]  ? try_to_wake_up+0x59/0x7a0
[ 1095.633120]  ? wake_up_process+0x15/0x20
[ 1095.633156]  xfs_reclaim_inodes_nr+0x33/0x40 [xfs]
[ 1095.633178]  xfs_fs_free_cached_objects+0x19/0x20 [xfs]
[ 1095.633180]  super_cache_scan+0x181/0x190
[ 1095.633183]  shrink_slab+0x29f/0x6d0
[ 1095.633189]  shrink_node+0x2fa/0x310
[ 1095.633193]  kswapd+0x362/0x9b0
[ 1095.633200]  kthread+0x10f/0x150
[ 1095.633201]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
[ 1095.633202]  ? kthread_create_on_node+0x70/0x70
[ 1095.633205]  ret_from_fork+0x31/0x40

... which is waiting on an inode flush lock. It can't get the lock
(presumably) because xfsaild has it:

[ 1041.772095] xfsaild/sda1    D13216   457      2 0x00000000
[ 1041.773726] Call Trace:
[ 1041.774734]  __schedule+0x336/0xe00
[ 1041.775956]  schedule+0x3d/0x90
[ 1041.777105]  schedule_timeout+0x26a/0x510
[ 1041.778426]  ? wait_for_completion+0x4c/0x190
[ 1041.779824]  wait_for_completion+0x12c/0x190
[ 1041.781273]  ? wake_up_q+0x80/0x80
[ 1041.782597]  ? _xfs_buf_read+0x44/0x90 [xfs]
[ 1041.784086]  xfs_buf_submit_wait+0xe9/0x5c0 [xfs]
[ 1041.785659]  _xfs_buf_read+0x44/0x90 [xfs]
[ 1041.787067]  xfs_buf_read_map+0xfa/0x400 [xfs]
[ 1041.788501]  ? xfs_trans_read_buf_map+0x186/0x830 [xfs]
[ 1041.790103]  xfs_trans_read_buf_map+0x186/0x830 [xfs]
[ 1041.791672]  xfs_imap_to_bp+0x71/0x110 [xfs]
[ 1041.793090]  xfs_iflush+0x122/0x3b0 [xfs]
[ 1041.794444]  xfs_inode_item_push+0x108/0x1c0 [xfs]
[ 1041.795956]  xfsaild_push+0x1d8/0xb70 [xfs]
[ 1041.797344]  xfsaild+0x150/0x270 [xfs]
[ 1041.798623]  kthread+0x10f/0x150
[ 1041.799819]  ? xfsaild_push+0xb70/0xb70 [xfs]
[ 1041.801217]  ? kthread_create_on_node+0x70/0x70
[ 1041.802652]  ret_from_fork+0x31/0x40

xfsaild is flushing an inode, but is waiting on a read of the underlying
inode cluster buffer such that it can flush out the in-core inode data
structure. I cannot tell if the read had actually completed and is
blocked somewhere else before running the completion. As Dave notes
earlier, buffer I/O completion relies on the xfs-buf wq. What is evident
from the logs is that xfs-buf has a rescuer thread that is sitting idle:

[ 1041.555227] xfs-buf/sda1    S14904   450      2 0x00000000
[ 1041.556813] Call Trace:
[ 1041.557796]  __schedule+0x336/0xe00
[ 1041.558983]  schedule+0x3d/0x90
[ 1041.560085]  rescuer_thread+0x322/0x3d0
[ 1041.561333]  kthread+0x10f/0x150
[ 1041.562464]  ? worker_thread+0x4b0/0x4b0
[ 1041.563732]  ? kthread_create_on_node+0x70/0x70
[ 1041.565123]  ret_from_fork+0x31/0x40

So AFAICT if the buffer I/O completion would run, it would allow xfsaild
to progress, which would eventually flush the underlying buffer, write
it, release the flush lock and allow kswapd to continue. The question is
has the actually I/O completed? If so, is the xfs-buf workqueue stuck
(waiting on an allocation perhaps)? And if that is the case, why is the
xfs-buf rescuer thread not doing anything?

Brian

> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
