Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA686B0007
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 01:07:49 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id h77so289602pfj.11
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 22:07:49 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id z33-v6si8047102plb.663.2018.02.05.22.07.46
        for <linux-mm@kvack.org>;
        Mon, 05 Feb 2018 22:07:48 -0800 (PST)
Date: Tue, 6 Feb 2018 17:08:40 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: freezing system for several second on high I/O [kernel 4.15]
Message-ID: <20180206060840.kj2u6jjmkuk3vie6@destitution>
References: <1517337604.9211.13.camel@gmail.com>
 <20180131022209.lmhespbauhqtqrxg@destitution>
 <1517888875.7303.3.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1517888875.7303.3.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikhail <mikhail.v.gavrilov@gmail.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Feb 06, 2018 at 08:47:55AM +0500, mikhail wrote:
> On Wed, 2018-01-31 at 13:22 +1100, Dave Chinner wrote:
> > 
> > 
> > Could be a disk that is slow, or could be many other
> > things. More information required:
> > 
> > http://xfs.org/index.php/XFS_FAQ#Q:_What_information_should_I_include_when_reporting_a_problem.3F
> > 
> > And everything else is backed up behind it trying to allocate
> > inodes. There could be many, many reasons for that, and that's why
> > we need more information to begin to isolate the cause.
> > 
> > Cheers,
> > 
> > Dave.
> > 
> 
> 
> 
> > # trace-cmd record -e xfs\*
> > before the problem occurs, and once it has occurred, kill the trace-cmd with ctrl-C, and then run:
> > 
> > # trace-cmd report > trace_report.txt
> 
> https://dumps.sy24.ru/trace_report.txt.bz2 (860MB)
> 
> Ok, I collected needed information.

You collected a trace of something, but didn't supply any of the
other storage and fs config stuff that was mentioned in that link.

> Cant you now look into in?

I don't see a filesystem problem from the log you've posted, I see
some slow IO a minute after boot, then a lockdep false positive
about 40mins in, but the system then reports GPU memory allocation
problems and hardware MCEs for the next 4-5 hours before the GPU
appears to stop working.


[....]

> [    4.687255] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)

I'm guessing that you have an ssd with ext4 and two 4TB drives.
And ext4 is on the SSD?

> [    5.778628] EXT4-fs (sda1): re-mounted. Opts: (null)
.....
> [    7.918812] XFS (sdb): Mounting V5 Filesystem
> [    8.123854] XFS (sdb): Starting recovery (logdev: internal)

And there's an XFS filesystem on one drive...

> [   77.459679] sysrq: SysRq : Show Blocked State
> [   77.459693]   task                        PC stack   pid father
> [   77.459947] tracker-store   D12296  2469   1847 0x00000000
> [   77.459957] Call Trace:
> [   77.459963]  __schedule+0x2dc/0xba0
> [   77.459966]  ? _raw_spin_unlock_irq+0x2c/0x40
> [   77.459970]  schedule+0x33/0x90
> [   77.459974]  io_schedule+0x16/0x40
> [   77.459978]  generic_file_read_iter+0x3b8/0xe10
> [   77.459986]  ? page_cache_tree_insert+0x140/0x140
> [   77.460026]  xfs_file_buffered_aio_read+0x6e/0x1a0 [xfs]
> [   77.460054]  xfs_file_read_iter+0x68/0xc0 [xfs]
> [   77.460058]  __vfs_read+0xf1/0x160
> [   77.460065]  vfs_read+0xa3/0x150
> [   77.460069]  SyS_pread64+0x98/0xc0
> [   77.460074]  entry_SYSCALL_64_fastpath+0x1f/0x96

That's waiting on a read IO - no indication of anything being wrong
here....

> [ 2095.241660] TaskSchedulerFo (16168) used greatest stack depth: 10232 bytes left
> 
> [ 2173.204790] ======================================================
> [ 2173.204791] WARNING: possible circular locking dependency detected
> [ 2173.204793] 4.15.0-rc4-amd-vega+ #8 Not tainted
> [ 2173.204794] ------------------------------------------------------
> [ 2173.204795] gnome-shell/1971 is trying to acquire lock:
> [ 2173.204796]  (sb_internal){.+.+}, at: [<00000000221fd49d>] xfs_trans_alloc+0xec/0x130 [xfs]
> [ 2173.204832] 
>                but task is already holding lock:
> [ 2173.204833]  (fs_reclaim){+.+.}, at: [<00000000bdc32871>] fs_reclaim_acquire.part.74+0x5/0x30
> [ 2173.204837] 
>                which lock already depends on the new lock.

And here we go again on another lockdep memory-reclaim false positive
whack-a-mole game.

> [ 2173.204838] 
>                the existing dependency chain (in reverse order) is:
> [ 2173.204839] 
>                -> #1 (fs_reclaim){+.+.}:
> [ 2173.204843]        fs_reclaim_acquire.part.74+0x29/0x30
> [ 2173.204844]        fs_reclaim_acquire+0x19/0x20
> [ 2173.204846]        kmem_cache_alloc+0x33/0x300
> [ 2173.204870]        kmem_zone_alloc+0x6c/0xf0 [xfs]
> [ 2173.204891]        xfs_trans_alloc+0x6b/0x130 [xfs]
> [ 2173.204912]        xfs_efi_recover+0x11c/0x1c0 [xfs]
> [ 2173.204932]        xlog_recover_process_efi+0x41/0x60 [xfs]
> [ 2173.204951]        xlog_recover_process_intents.isra.40+0x138/0x270 [xfs]
> [ 2173.204969]        xlog_recover_finish+0x23/0xb0 [xfs]
> [ 2173.204987]        xfs_log_mount_finish+0x61/0xe0 [xfs]
> [ 2173.205005]        xfs_mountfs+0x657/0xa60 [xfs]
> [ 2173.205022]        xfs_fs_fill_super+0x4aa/0x630 [xfs]
> [ 2173.205024]        mount_bdev+0x184/0x1c0
> [ 2173.205042]        xfs_fs_mount+0x15/0x20 [xfs]
> [ 2173.205043]        mount_fs+0x32/0x150
> [ 2173.205045]        vfs_kern_mount.part.25+0x5d/0x160
> [ 2173.205046]        do_mount+0x65d/0xde0
> [ 2173.205047]        SyS_mount+0x98/0xe0
> [ 2173.205049]        do_syscall_64+0x6c/0x220
> [ 2173.205052]        return_from_SYSCALL_64+0x0/0x75
> [ 2173.205053] 
>                -> #0 (sb_internal){.+.+}:
> [ 2173.205056]        lock_acquire+0xa3/0x1f0
> [ 2173.205058]        __sb_start_write+0x11c/0x190
> [ 2173.205075]        xfs_trans_alloc+0xec/0x130 [xfs]
> [ 2173.205091]        xfs_free_eofblocks+0x12a/0x1e0 [xfs]
> [ 2173.205108]        xfs_inactive+0xf0/0x110 [xfs]
> [ 2173.205125]        xfs_fs_destroy_inode+0xbb/0x2d0 [xfs]
> [ 2173.205127]        destroy_inode+0x3b/0x60
> [ 2173.205128]        evict+0x13e/0x1a0
> [ 2173.205129]        dispose_list+0x56/0x80
> [ 2173.205131]        prune_icache_sb+0x5a/0x80
> [ 2173.205132]        super_cache_scan+0x137/0x1b0
> [ 2173.205134]        shrink_slab.part.47+0x1fb/0x590
> [ 2173.205135]        shrink_slab+0x29/0x30
> [ 2173.205136]        shrink_node+0x11e/0x2f0
> [ 2173.205137]        do_try_to_free_pages+0xd0/0x350
> [ 2173.205138]        try_to_free_pages+0x136/0x340
> [ 2173.205140]        __alloc_pages_slowpath+0x487/0x1150
> [ 2173.205141]        __alloc_pages_nodemask+0x3a8/0x430
> [ 2173.205143]        dma_generic_alloc_coherent+0x91/0x160
> [ 2173.205146]        x86_swiotlb_alloc_coherent+0x25/0x50
> [ 2173.205150]        ttm_dma_pool_get_pages+0x230/0x630 [ttm]

OK, new symptom of the ages old problem with using lockdep for
annotating things that are not locks. In this case, it's both
memory reclaim and filesystem freeze annotations that are colliding
with an XFS function that can be called above and below memory
allocation and producing a false positive.

i.e. it's perfectly safe for us to call xfs_trans_alloc() in the
manner we are from memory reclaim because we're not in a GFP_NOFS or
PF_MEMALLOC_NOFS context.

And it's also perfectly safe for us to call xfs_trans_alloc from log
recovery at mount time like we are because the filesystem cannot be
frozen before a mount is complete and hence sb_internal ordering is
completely irrelevant at that point.

So it's a false positive, and I don't think there's anything we can
do to prevent it because using __GFP_NOLOCKDEP in xfs_trans_alloc()
will mean lockdep will not warn we we have a real deadlock due to
transaction nesting in memory reclaim contexts.....

>From here, there's nothing filesystem related in the logs:

[.....]

> [ 2229.274826] swiotlb: coherent allocation failed for device 0000:07:00.0 size=2097152

You are getting gpu memory allocation failures....

> [ 2234.832320] amdgpu 0000:07:00.0: swiotlb buffer is full (sz: 2097152 bytes)
> [ 2234.832325] swiotlb: coherent allocation failed for device 0000:07:00.0 size=2097152

repeatedly, until ....

> [ 2938.815747] mce: [Hardware Error]: Machine check events logged

your hardware starts throwing errors at the CPU.

> [ 2999.259697] kworker/dying (16220) used greatest stack depth: 9808 bytes left
> [ 3151.714448] perf: interrupt took too long (2521 > 2500), lowering kernel.perf_event_max_sample_rate to 79000
> [ 5331.990934] TCP: request_sock_TCP: Possible SYN flooding on port 8201. Sending cookies.  Check SNMP counters.
> [ 5331.991837] TCP: request_sock_TCP: Possible SYN flooding on port 9208. Sending cookies.  Check SNMP counters.
> [ 5334.781978] TCP: request_sock_TCP: Possible SYN flooding on port 7171. Sending cookies.  Check SNMP counters.

other bad things are happening to your machine....

> [ 5354.636542] sbis3plugin[29294]: segfault at 8 ip 000000001c84acaf sp 0000000038851b8c error 4 in libQt5Core.so[7f87ee665000+5a3000]
> [ 5794.612947] perf: interrupt took too long (3152 > 3151), lowering kernel.perf_event_max_sample_rate to 63000
> [ 6242.114852] amdgpu 0000:07:00.0: swiotlb buffer is full (sz: 2097152 bytes)
> [ 6242.114857] swiotlb: coherent allocation failed for device 0000:07:00.0 size=2097152

Random userspace segfaults and more gpu memory allocation failures

> [ 9663.267767] mce: [Hardware Error]: Machine check events logged
> [10322.649619] mce: [Hardware Error]: Machine check events logged
> [10557.294312] amdgpu 0000:07:00.0: swiotlb buffer is full (sz: 2097152 bytes)
> [10557.294317] swiotlb: coherent allocation failed for device 0000:07:00.0 size=2097152

more hardware and gpu memory allocation failures

[more gpu memalloc failures]

> [13609.734065] mce: [Hardware Error]: Machine check events logged
> [13920.399283] mce: [Hardware Error]: Machine check events logged
> [14116.872461] [drm:amdgpu_job_timedout [amdgpu]] *ERROR* ring gfx timeout, last signaled seq=1653418, last emitted seq=1653420
> [14116.872466] [drm] No hardware hang detected. Did some blocks stall?

And finally after 4+ hours hardware errors and the GPU times out and
drm is confused....

So there doesn't appear to be any filesystem problem here, just a
heavily loaded system under memory pressure....

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
