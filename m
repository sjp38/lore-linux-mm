Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 58FDD6B0032
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 17:35:11 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so3428733pdi.31
        for <linux-mm@kvack.org>; Sat, 20 Dec 2014 14:35:11 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id ud1si1390528pbc.21.2014.12.20.14.35.07
        for <linux-mm@kvack.org>;
        Sat, 20 Dec 2014 14:35:09 -0800 (PST)
Date: Sun, 21 Dec 2014 09:35:04 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20141220223504.GI15665@dastard>
References: <20141217130807.GB24704@dhcp22.suse.cz>
 <201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
 <20141218153341.GB832@dhcp22.suse.cz>
 <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
 <20141220020331.GM1942@devil.localdomain>
 <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: dchinner@redhat.com, mhocko@suse.cz, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Sat, Dec 20, 2014 at 09:41:22PM +0900, Tetsuo Handa wrote:
> Dave Chinner wrote:
> > On Fri, Dec 19, 2014 at 09:22:49PM +0900, Tetsuo Handa wrote:
> > > > > The global OOM killer will try to kill this program because this program
> > > > > will be using 400MB+ of RAM by the time the global OOM killer is triggered.
> > > > > But sometimes this program cannot be terminated by the global OOM killer
> > > > > due to XFS lock dependency.
> > > > >
> > > > > You can see what is happening from OOM traces after uptime > 320 seconds of
> > > > > http://I-love.SAKURA.ne.jp/tmp/serial-20141213.txt.xz though memcg is not
> > > > > configured on this program.
> > > >
> > > > This is clearly a separate issue. It is a lock dependency and that alone
> > > > _cannot_ be handled from OOM killer as it doesn't understand lock
> > > > dependencies. This should be addressed from the xfs point of view IMHO
> > > > but I am not familiar with this filesystem to tell you how or whether it
> > > > is possible.
> > 
> > What XFS lock dependency? I see nothing in that output file that indicates a
> > lock dependency problem - can you point out what the issue is here?
> 
> This is a problem which lockdep cannot report.
> 
> The problem is that an OOM-victim task is unable to terminate because it is
> blocked for waiting for (I don't know which lock but) one of locks used by XFS.

That's not an XFS problem - XFS relies on the memory reclaim
subsystem being able to make progress. If the memory reclaim
subsystem cannot make progress, then there's a bug in the memory
reclaim subsystem, not a problem with the OOM killer.

IOWs, you're not looking at the right place to solve the problem.

> ----------
> [  320.788387] Kill process 10732 (a.out) sharing same memory
> (...snipped...)
> [  398.641724] a.out           D ffff880077e42638     0 10732      1 0x00000084
> [  398.643705]  ffff8800770ebcb8 0000000000000082 ffff8800770ebc88 ffff880077e42210
> [  398.645819]  0000000000012500 ffff8800770ebfd8 0000000000012500 ffff880077e42210
> [  398.647917]  ffff8800770ebcb8 ffff88007b4a2a48 ffff88007b4a2a4c ffff880077e42210
> [  398.650009] Call Trace:
> [  398.651094]  [<ffffffff8159f954>] schedule_preempt_disabled+0x24/0x70
> [  398.652913]  [<ffffffff815a1705>] __mutex_lock_slowpath+0xb5/0x120
> [  398.654679]  [<ffffffff815a178e>] mutex_lock+0x1e/0x32
> [  398.656262]  [<ffffffffa023b58a>] xfs_file_buffered_aio_write.isra.15+0x6a/0x200 [xfs]
> [  398.658350]  [<ffffffffa023b79e>] xfs_file_write_iter+0x7e/0x120 [xfs]
> [  398.660191]  [<ffffffff8117edd9>] new_sync_write+0x89/0xd0
> [  398.661829]  [<ffffffff8117f742>] vfs_write+0xb2/0x1f0
> [  398.663397]  [<ffffffff8101a9f4>] ? do_audit_syscall_entry+0x64/0x70
> [  398.665190]  [<ffffffff81180200>] SyS_write+0x50/0xc0
> [  398.666745]  [<ffffffff810f729e>] ? __audit_syscall_exit+0x22e/0x2d0
> [  398.668539]  [<ffffffff815a38e9>] system_call_fastpath+0x12/0x17

These processes are blocked because some other process is holding the
i_mutex - likely another write that is blocked in memory reclaim
during page cache allocation. Yup:

[  398.852364] a.out           R  running task        0 10739      1 0x00000084
[  398.854312]  ffff8800751d3898 0000000000000082 ffff8800751d3960 ffff880035c42a80
[  398.856369]  0000000000012500 ffff8800751d3fd8 0000000000012500 ffff880035c42a80
[  398.858440]  0000000000000020 ffff8800751d3970 0000000000000003 ffffffff81848408
[  398.860497] Call Trace:
[  398.861602]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
[  398.863195]  [<ffffffff81122119>] shrink_slab+0x139/0x150
[  398.864799]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
[  398.866536]  [<ffffffff811254c4>] try_to_free_pages+0x94/0xc0
[  398.868177]  [<ffffffff8111a793>] __alloc_pages_nodemask+0x4e3/0xa40
[  398.869920]  [<ffffffff8115a8ce>] alloc_pages_current+0x8e/0x100
[  398.871647]  [<ffffffff81111b27>] __page_cache_alloc+0xa7/0xc0
[  398.873785]  [<ffffffff8111263b>] pagecache_get_page+0x6b/0x1e0
[  398.875468]  [<ffffffff811127de>] grab_cache_page_write_begin+0x2e/0x50
[  398.881857]  [<ffffffffa02301cf>] xfs_vm_write_begin+0x2f/0xe0 [xfs]
[  398.883553]  [<ffffffff8111188c>] generic_perform_write+0xcc/0x1d0
[  398.885210]  [<ffffffffa023b50f>] ? xfs_file_aio_write_checks+0xdf/0xf0 [xfs]
[  398.887100]  [<ffffffffa023b5ef>] xfs_file_buffered_aio_write.isra.15+0xcf/0x200 [xfs]
[  398.889135]  [<ffffffffa023b79e>] xfs_file_write_iter+0x7e/0x120 [xfs]
[  398.890907]  [<ffffffff8117edd9>] new_sync_write+0x89/0xd0
[  398.892495]  [<ffffffff8117f742>] vfs_write+0xb2/0x1f0
[  398.894017]  [<ffffffff8101a9f4>] ? do_audit_syscall_entry+0x64/0x70
[  398.895768]  [<ffffffff81180200>] SyS_write+0x50/0xc0
[  398.897273]  [<ffffffff810f729e>] ? __audit_syscall_exit+0x22e/0x2d0
[  398.899013]  [<ffffffff815a38e9>] system_call_fastpath+0x12/0x17

That's what's holding the i_mutex. This is normal, and *every*
filesystem holds the i_mutex here for buffered writes. Stop
trying to shoot the messenger...

Oh, boy.

struct page *grab_cache_page_write_begin(struct address_space *mapping,
                                        pgoff_t index, unsigned flags)
{
        struct page *page;
        int fgp_flags = FGP_LOCK|FGP_ACCESSED|FGP_WRITE|FGP_CREAT;

        if (flags & AOP_FLAG_NOFS)
                fgp_flags |= FGP_NOFS;

        page = pagecache_get_page(mapping, index, fgp_flags,
                        mapping_gfp_mask(mapping),
                        GFP_KERNEL);
        if (page)
                wait_for_stable_page(page);

        return page;
}

There are *3* different memory allocation controls passed to
pagecache_get_page. The first is via AOP_FLAG_NOFS, where the caller
explicitly says this allocation is in filesystem context with locks
held, and so all allocations need to be done in GFP_NOFS context.
This is used to override the second and third gfp parameters.

The second is mapping_gfp_mask(mapping), which is the *default
allocation context* the filesystem wants the page cache to use for
allocating pages to the mapping.

The third is a hard coded GFP_KERNEL, which is used for radix tree
node allocation.

Why are there separate allocation contexts for the radix tree nodes
and the page cache pages when they are done under *exactly the same
caller context*? Either we are allowed to recurse into the
filesystem or we aren't, and the inode mapping mask defines that
context for all page cache allocations, not just the pages
themselves.

And to point out how many filesystems this affects,
the loop device, btrfs, f2fs, gfs2, jfs, logfs, nil2fs, reiserfs
and XFS all use this mapping default to clear __GFP_FS from
page cache allocations. Only ext4 and gfs2 use AOP_FLAG_NOFS in
their ->write_begin callouts to prevent recusrion.

IOWs, grab_cache_page_write_begin/pagecache_get_page multiple
allocation contexts are just wrong.  It does not match the way
filesystems are informing the page cache of allocation context to
avoid recursion (for avoiding stack overflow and/or deadlock).
AOP_FLAG_NOFS should go away, and all filesystems should modify the
mapping gfp mask to set their allocation context. If should be used
*everywhere* pages are allocated into the page cache, and for all
allocations related to tracking those allocated pages.

Now, that's not the problem directly related to this lockup, but
it's indicative of how far the page cache code has become from
reality over the past few years...

So, going back to the lockup, doesn't hte fact that so many
processes are spinning in the shrinker tell you that there's a
problem in that area? i.e. this:

[  398.861602]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
[  398.863195]  [<ffffffff81122119>] shrink_slab+0x139/0x150
[  398.864799]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0

tells me a shrinker is not making progress for some reason.  I'd
suggest that you run some tracing to find out what shrinker it is
stuck in. there are tracepoints in shrink_slab that will tell you
what shrinker is iterating for long periods of time. i.e instead of
ranting and pointing fingers at everyone, you need to keep digging
until you know exactly where reclaim progress is stalling.

> I don't know how block layer requests are issued by filesystem layer's
> activities, but PID=10832 is blocked for so long at blk_rq_map_kern() doing
> __GFP_WAIT allocation. I'm sure that this blk_rq_map_kern() is issued by XFS
> filesystem's activities because this system has only /dev/sda1 formatted as
> XFS and there is no swap memory.

Sorry, what?

[  525.184545]  [<ffffffff81265e6f>] blk_rq_map_kern+0x6f/0x130
[  525.186156]  [<ffffffff8116393e>] ? kmem_cache_alloc+0x48e/0x4b0
[  525.187831]  [<ffffffff813a66cf>] scsi_execute+0x12f/0x160
[  525.189418]  [<ffffffff813a7f14>] scsi_execute_req_flags+0x84/0xf0
[  525.191148]  [<ffffffffa01e29cc>] sr_check_events+0xbc/0x2e0 [sr_mod]
[  525.192969]  [<ffffffff8109834c>] ? put_prev_entity+0x2c/0x3b0
[  525.194688]  [<ffffffffa01d6177>] cdrom_check_events+0x17/0x30 [cdrom]
[  525.196455]  [<ffffffffa01e2e5d>] sr_block_check_events+0x2d/0x30 [sr_mod]
[  525.198291]  [<ffffffff812701c6>] disk_check_events+0x56/0x1b0
[  525.199984]  [<ffffffff81270331>] disk_events_workfn+0x11/0x20
[  525.201616]  [<ffffffff8107ceaf>] process_one_work+0x13f/0x370
[  525.203264]  [<ffffffff8107de99>] worker_thread+0x119/0x500
[  525.204799]  [<ffffffff8107dd80>] ? rescuer_thread+0x350/0x350
[  525.206436]  [<ffffffff81082f7c>] kthread+0xdc/0x100
[  525.207902]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
[  525.209655]  [<ffffffff815a383c>] ret_from_fork+0x7c/0xb0
[  525.211206]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0

That's a CDROM event through the SCSI stack via a raw scsi device.
If you read the code you'd see that scsi_execute() is the function
using __GFP_WAIT semantics. This has *absolutely nothing* to do with
XFS, and clearly has nothing to do with anything related to the
problem you are seeing.

> Anyway stalling for 10 minutes upon OOM (and can't solve with
> SysRq-f) is unusable for me.

OOM-killing is not a magic button that will miraculously make the
system work when you oversubscribe it severely.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
