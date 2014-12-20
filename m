Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 65C2F6B0032
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 07:41:29 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so2948241pad.10
        for <linux-mm@kvack.org>; Sat, 20 Dec 2014 04:41:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ob9si17393247pbb.57.2014.12.20.04.41.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 20 Dec 2014 04:41:27 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141217130807.GB24704@dhcp22.suse.cz>
	<201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
	<20141218153341.GB832@dhcp22.suse.cz>
	<201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
	<20141220020331.GM1942@devil.localdomain>
In-Reply-To: <20141220020331.GM1942@devil.localdomain>
Message-Id: <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
Date: Sat, 20 Dec 2014 21:41:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com
Cc: mhocko@suse.cz, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, david@fromorbit.com

Dave Chinner wrote:
> On Fri, Dec 19, 2014 at 09:22:49PM +0900, Tetsuo Handa wrote:
> > > > The global OOM killer will try to kill this program because this program
> > > > will be using 400MB+ of RAM by the time the global OOM killer is triggered.
> > > > But sometimes this program cannot be terminated by the global OOM killer
> > > > due to XFS lock dependency.
> > > >
> > > > You can see what is happening from OOM traces after uptime > 320 seconds of
> > > > http://I-love.SAKURA.ne.jp/tmp/serial-20141213.txt.xz though memcg is not
> > > > configured on this program.
> > >
> > > This is clearly a separate issue. It is a lock dependency and that alone
> > > _cannot_ be handled from OOM killer as it doesn't understand lock
> > > dependencies. This should be addressed from the xfs point of view IMHO
> > > but I am not familiar with this filesystem to tell you how or whether it
> > > is possible.
> 
> What XFS lock dependency? I see nothing in that output file that indicates a
> lock dependency problem - can you point out what the issue is here?

This is a problem which lockdep cannot report.

The problem is that an OOM-victim task is unable to terminate because it is
blocked for waiting for (I don't know which lock but) one of locks used by XFS.

----------
[  320.788387] Kill process 10732 (a.out) sharing same memory
(...snipped...)
[  398.641724] a.out           D ffff880077e42638     0 10732      1 0x00000084
[  398.643705]  ffff8800770ebcb8 0000000000000082 ffff8800770ebc88 ffff880077e42210
[  398.645819]  0000000000012500 ffff8800770ebfd8 0000000000012500 ffff880077e42210
[  398.647917]  ffff8800770ebcb8 ffff88007b4a2a48 ffff88007b4a2a4c ffff880077e42210
[  398.650009] Call Trace:
[  398.651094]  [<ffffffff8159f954>] schedule_preempt_disabled+0x24/0x70
[  398.652913]  [<ffffffff815a1705>] __mutex_lock_slowpath+0xb5/0x120
[  398.654679]  [<ffffffff815a178e>] mutex_lock+0x1e/0x32
[  398.656262]  [<ffffffffa023b58a>] xfs_file_buffered_aio_write.isra.15+0x6a/0x200 [xfs]
[  398.658350]  [<ffffffffa023b79e>] xfs_file_write_iter+0x7e/0x120 [xfs]
[  398.660191]  [<ffffffff8117edd9>] new_sync_write+0x89/0xd0
[  398.661829]  [<ffffffff8117f742>] vfs_write+0xb2/0x1f0
[  398.663397]  [<ffffffff8101a9f4>] ? do_audit_syscall_entry+0x64/0x70
[  398.665190]  [<ffffffff81180200>] SyS_write+0x50/0xc0
[  398.666745]  [<ffffffff810f729e>] ? __audit_syscall_exit+0x22e/0x2d0
[  398.668539]  [<ffffffff815a38e9>] system_call_fastpath+0x12/0x17
(...snipped...)
[  897.190487] Out of memory: Kill process 10732 (a.out) score 898 or sacrifice child
[  897.192236] Killed process 10732 (a.out) total-vm:2166864kB, anon-rss:1727976kB, file-rss:0kB
(...snipped...)
[  904.819053] a.out           D ffff880077e42638     0 10732      1 0x00100084
[  904.820967]  ffff8800770ebcb8 0000000000000082 ffff8800770ebc88 ffff880077e42210
[  904.823011]  0000000000012500 ffff8800770ebfd8 0000000000012500 ffff880077e42210
[  904.825054]  ffff8800770ebcb8 ffff88007b4a2a48 ffff88007b4a2a4c ffff880077e42210
[  904.827137] Call Trace:
[  904.828174]  [<ffffffff8159f954>] schedule_preempt_disabled+0x24/0x70
[  904.829924]  [<ffffffff815a1705>] __mutex_lock_slowpath+0xb5/0x120
[  904.831634]  [<ffffffff815a178e>] mutex_lock+0x1e/0x32
[  904.833148]  [<ffffffffa023b58a>] xfs_file_buffered_aio_write.isra.15+0x6a/0x200 [xfs]
[  904.835178]  [<ffffffffa023b79e>] xfs_file_write_iter+0x7e/0x120 [xfs]
[  904.836980]  [<ffffffff8117edd9>] new_sync_write+0x89/0xd0
[  904.838561]  [<ffffffff8117f742>] vfs_write+0xb2/0x1f0
[  904.840094]  [<ffffffff8101a9f4>] ? do_audit_syscall_entry+0x64/0x70
[  904.841846]  [<ffffffff81180200>] SyS_write+0x50/0xc0
[  904.844026]  [<ffffffff810f729e>] ? __audit_syscall_exit+0x22e/0x2d0
[  904.845826]  [<ffffffff815a38e9>] system_call_fastpath+0x12/0x17
----------

I don't know how block layer requests are issued by filesystem layer's
activities, but PID=10832 is blocked for so long at blk_rq_map_kern() doing
__GFP_WAIT allocation. I'm sure that this blk_rq_map_kern() is issued by XFS
filesystem's activities because this system has only /dev/sda1 formatted as
XFS and there is no swap memory.

----------
[  393.696527] kworker/1:1     R  running task        0    43      2 0x00000000
[  393.698561] Workqueue: events_freezable_power_ disk_events_workfn
[  393.700339]  ffff88007c5437d8 0000000000000046 ffff88007c5438a0 ffff88007c4b4cc0
[  393.702513]  0000000000012500 ffff88007c543fd8 0000000000012500 ffff88007c4b4cc0
[  393.704631]  0000000000000020 ffff88007c5438b0 0000000000000002 ffffffff81848408
[  393.706748] Call Trace:
[  393.707924]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
[  393.709572]  [<ffffffff81122119>] shrink_slab+0x139/0x150
[  393.711206]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
[  393.713001]  [<ffffffff811254c4>] try_to_free_pages+0x94/0xc0
[  393.714679]  [<ffffffff8111a793>] __alloc_pages_nodemask+0x4e3/0xa40
[  393.716538]  [<ffffffff8115a8ce>] alloc_pages_current+0x8e/0x100
[  393.718262]  [<ffffffff8125bed6>] bio_copy_user_iov+0x1d6/0x380
[  393.719959]  [<ffffffff8125e4cd>] ? blk_rq_init+0xed/0x160
[  393.721628]  [<ffffffff8125c119>] bio_copy_kern+0x49/0x100
[  393.723240]  [<ffffffff810a14a0>] ? prepare_to_wait_event+0x100/0x100
[  393.725043]  [<ffffffff81265e6f>] blk_rq_map_kern+0x6f/0x130
[  393.726695]  [<ffffffff8116393e>] ? kmem_cache_alloc+0x48e/0x4b0
[  393.728407]  [<ffffffff813a66cf>] scsi_execute+0x12f/0x160
[  393.730021]  [<ffffffff813a7f14>] scsi_execute_req_flags+0x84/0xf0
[  393.731776]  [<ffffffffa01e29cc>] sr_check_events+0xbc/0x2e0 [sr_mod]
[  393.733561]  [<ffffffff8109834c>] ? put_prev_entity+0x2c/0x3b0
[  393.735235]  [<ffffffffa01d6177>] cdrom_check_events+0x17/0x30 [cdrom]
[  393.737027]  [<ffffffffa01e2e5d>] sr_block_check_events+0x2d/0x30 [sr_mod]
[  393.738918]  [<ffffffff812701c6>] disk_check_events+0x56/0x1b0
[  393.740602]  [<ffffffff81270331>] disk_events_workfn+0x11/0x20
[  393.742254]  [<ffffffff8107ceaf>] process_one_work+0x13f/0x370
[  393.743898]  [<ffffffff8107de99>] worker_thread+0x119/0x500
[  393.745495]  [<ffffffff8107dd80>] ? rescuer_thread+0x350/0x350
[  393.747152]  [<ffffffff81082f7c>] kthread+0xdc/0x100
[  393.748637]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
[  393.750438]  [<ffffffff815a383c>] ret_from_fork+0x7c/0xb0
[  393.752004]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
(...snipped...)
[  525.157216] kworker/1:0     R  running task        0 10832      2 0x00000080
[  525.159187] Workqueue: events_freezable_power_ disk_events_workfn
[  525.160907]  ffff88007c8ab7d8 0000000000000046 ffff88007c8ab8a0 ffff88007c894190
[  525.162956]  0000000000012500 ffff88007c8abfd8 0000000000012500 ffff88007c894190
[  525.165010]  0000000000000020 ffff88007c8ab8b0 0000000000000002 ffffffff81848408
[  525.167068] Call Trace:
[  525.168100]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
[  525.169679]  [<ffffffff81122119>] shrink_slab+0x139/0x150
[  525.171241]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
[  525.172960]  [<ffffffff811254c4>] try_to_free_pages+0x94/0xc0
[  525.174580]  [<ffffffff8111a793>] __alloc_pages_nodemask+0x4e3/0xa40
[  525.176302]  [<ffffffff8115a8ce>] alloc_pages_current+0x8e/0x100
[  525.177982]  [<ffffffff8125bed6>] bio_copy_user_iov+0x1d6/0x380
[  525.179631]  [<ffffffff8125e4cd>] ? blk_rq_init+0xed/0x160
[  525.181215]  [<ffffffff8125c119>] bio_copy_kern+0x49/0x100
[  525.182785]  [<ffffffff810a14a0>] ? prepare_to_wait_event+0x100/0x100
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
(...snipped...)
[  619.934144] kworker/1:0     R  running task        0 10832      2 0x00000080
[  619.936060] Workqueue: events_freezable_power_ disk_events_workfn
[  619.937833]  ffff88007c8ab7d8 0000000000000046 ffff88007c8ab8a0 ffff88007c894190
[  619.939912]  0000000000012500 ffff88007c8abfd8 0000000000012500 ffff88007c894190
[  619.942010]  0000000000000020 ffff88007c8ab8b0 0000000000000002 ffffffff81848408
[  619.944123] Call Trace:
[  619.945168]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
[  619.946697]  [<ffffffff81122119>] shrink_slab+0x139/0x150
[  619.948271]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
[  619.949968]  [<ffffffff811254c4>] try_to_free_pages+0x94/0xc0
[  619.951576]  [<ffffffff8111a793>] __alloc_pages_nodemask+0x4e3/0xa40
[  619.953387]  [<ffffffff8115a8ce>] alloc_pages_current+0x8e/0x100
[  619.955062]  [<ffffffff8125bed6>] bio_copy_user_iov+0x1d6/0x380
[  619.956726]  [<ffffffff8125e4cd>] ? blk_rq_init+0xed/0x160
[  619.958289]  [<ffffffff8125c119>] bio_copy_kern+0x49/0x100
[  619.959886]  [<ffffffff810a14a0>] ? prepare_to_wait_event+0x100/0x100
[  619.961641]  [<ffffffff81265e6f>] blk_rq_map_kern+0x6f/0x130
[  619.963229]  [<ffffffff8116393e>] ? kmem_cache_alloc+0x48e/0x4b0
[  619.964904]  [<ffffffff813a66cf>] scsi_execute+0x12f/0x160
[  619.966499]  [<ffffffff813a7f14>] scsi_execute_req_flags+0x84/0xf0
[  619.968182]  [<ffffffffa01e29cc>] sr_check_events+0xbc/0x2e0 [sr_mod]
[  619.969936]  [<ffffffff8109834c>] ? put_prev_entity+0x2c/0x3b0
[  619.971583]  [<ffffffffa01d6177>] cdrom_check_events+0x17/0x30 [cdrom]
[  619.973346]  [<ffffffffa01e2e5d>] sr_block_check_events+0x2d/0x30 [sr_mod]
[  619.975213]  [<ffffffff812701c6>] disk_check_events+0x56/0x1b0
[  619.976865]  [<ffffffff81270331>] disk_events_workfn+0x11/0x20
[  619.978497]  [<ffffffff8107ceaf>] process_one_work+0x13f/0x370
[  619.980179]  [<ffffffff8107de99>] worker_thread+0x119/0x500
[  619.981793]  [<ffffffff8107dd80>] ? rescuer_thread+0x350/0x350
[  619.983468]  [<ffffffff81082f7c>] kthread+0xdc/0x100
[  619.984939]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
[  619.986684]  [<ffffffff815a383c>] ret_from_fork+0x7c/0xb0
[  619.988231]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
(...snipped...)
[  715.930998] kworker/1:0     R  running task        0 10832      2 0x00000080
[  715.932930] Workqueue: events_freezable_power_ disk_events_workfn
[  715.934670]  ffff880076fb9b40 0000000000000400 ffff88007c8ab8a0 0000000000000000
[  715.936814]  ffff88007c8ab7e8 ffff88007c8abfd8 0000000000012500 ffff88007c894190
[  715.938869]  0000000000000020 ffff88007c8ab8b0 0000000000000002 ffffffff81848408
[  715.940909] Call Trace:
[  715.942017]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
[  715.943638]  [<ffffffff81122119>] shrink_slab+0x139/0x150
[  715.945256]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
[  715.947001]  [<ffffffff811254c4>] try_to_free_pages+0x94/0xc0
[  715.948603]  [<ffffffff8111a793>] __alloc_pages_nodemask+0x4e3/0xa40
[  715.950298]  [<ffffffff8115a8ce>] alloc_pages_current+0x8e/0x100
[  715.952010]  [<ffffffff8125bed6>] bio_copy_user_iov+0x1d6/0x380
[  715.953658]  [<ffffffff8125e4cd>] ? blk_rq_init+0xed/0x160
[  715.955324]  [<ffffffff8125c119>] bio_copy_kern+0x49/0x100
[  715.956929]  [<ffffffff810a14a0>] ? prepare_to_wait_event+0x100/0x100
[  715.958693]  [<ffffffff81265e6f>] blk_rq_map_kern+0x6f/0x130
[  715.960722]  [<ffffffff8116393e>] ? kmem_cache_alloc+0x48e/0x4b0
[  715.962488]  [<ffffffff813a66cf>] scsi_execute+0x12f/0x160
[  715.964142]  [<ffffffff813a7f14>] scsi_execute_req_flags+0x84/0xf0
[  715.965870]  [<ffffffffa01e29cc>] sr_check_events+0xbc/0x2e0 [sr_mod]
[  715.967615]  [<ffffffff8109834c>] ? put_prev_entity+0x2c/0x3b0
[  715.969255]  [<ffffffffa01d6177>] cdrom_check_events+0x17/0x30 [cdrom]
[  715.971061]  [<ffffffffa01e2e5d>] sr_block_check_events+0x2d/0x30 [sr_mod]
[  715.972981]  [<ffffffff812701c6>] disk_check_events+0x56/0x1b0
[  715.974692]  [<ffffffff81270331>] disk_events_workfn+0x11/0x20
[  715.976330]  [<ffffffff8107ceaf>] process_one_work+0x13f/0x370
[  715.978090]  [<ffffffff8107de99>] worker_thread+0x119/0x500
[  715.979723]  [<ffffffff8107dd80>] ? rescuer_thread+0x350/0x350
[  715.981361]  [<ffffffff81082f7c>] kthread+0xdc/0x100
[  715.982794]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
[  715.984554]  [<ffffffff815a383c>] ret_from_fork+0x7c/0xb0
[  715.986116]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
(...snipped...)
[  798.788405] kworker/1:0     R  running task        0 10832      2 0x00000088
[  798.790344] Workqueue: events_freezable_power_ disk_events_workfn
[  798.792191]  ffff880035e3f340 0000000000000400 ffff88007c8ab8a0 0000000000000000
[  798.794328]  ffff88007c8ab7e8 ffffffff8112132a ffff88007c8ab908 ffff88007cfee800
[  798.796395]  0000000000000020 0000000000000000 ffff88007c8ab838 ffff88007c8ab8b0
[  798.798458] Call Trace:
[  798.799525]  [<ffffffff8112132a>] ? shrink_slab_node+0x3a/0x1b0
[  798.801229]  [<ffffffff81122063>] ? shrink_slab+0x83/0x150
[  798.802809]  [<ffffffff811252bf>] ? do_try_to_free_pages+0x35f/0x4d0
[  798.804586]  [<ffffffff811254c4>] ? try_to_free_pages+0x94/0xc0
[  798.806250]  [<ffffffff8111a793>] ? __alloc_pages_nodemask+0x4e3/0xa40
[  798.808050]  [<ffffffff8115a8ce>] ? alloc_pages_current+0x8e/0x100
[  798.809759]  [<ffffffff8125bed6>] ? bio_copy_user_iov+0x1d6/0x380
[  798.811500]  [<ffffffff8125e4cd>] ? blk_rq_init+0xed/0x160
[  798.813053]  [<ffffffff8125c119>] ? bio_copy_kern+0x49/0x100
[  798.814699]  [<ffffffff810a14a0>] ? prepare_to_wait_event+0x100/0x100
[  798.816494]  [<ffffffff81265e6f>] ? blk_rq_map_kern+0x6f/0x130
[  798.818421]  [<ffffffff8116393e>] ? kmem_cache_alloc+0x48e/0x4b0
[  798.820083]  [<ffffffff813a66cf>] ? scsi_execute+0x12f/0x160
[  798.821733]  [<ffffffff813a7f14>] ? scsi_execute_req_flags+0x84/0xf0
[  798.823454]  [<ffffffffa01e29cc>] ? sr_check_events+0xbc/0x2e0 [sr_mod]
[  798.825312]  [<ffffffff8109834c>] ? put_prev_entity+0x2c/0x3b0
[  798.826930]  [<ffffffffa01d6177>] ? cdrom_check_events+0x17/0x30 [cdrom]
[  798.828733]  [<ffffffffa01e2e5d>] ? sr_block_check_events+0x2d/0x30 [sr_mod]
[  798.830594]  [<ffffffff812701c6>] ? disk_check_events+0x56/0x1b0
[  798.832338]  [<ffffffff81270331>] ? disk_events_workfn+0x11/0x20
[  798.834013]  [<ffffffff8107ceaf>] ? process_one_work+0x13f/0x370
[  798.835682]  [<ffffffff8107de99>] ? worker_thread+0x119/0x500
[  798.837350]  [<ffffffff8107dd80>] ? rescuer_thread+0x350/0x350
[  798.838990]  [<ffffffff81082f7c>] ? kthread+0xdc/0x100
[  798.840489]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
[  798.842258]  [<ffffffff815a383c>] ? ret_from_fork+0x7c/0xb0
[  798.843837]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
(...snipped...)
[  850.354473] kworker/1:0     R  running task        0 10832      2 0x00000080
[  850.356549] Workqueue: events_freezable_power_ disk_events_workfn
[  850.358273]  ffff88007c8ab7d8 0000000000000046 ffff88007c8ab8a0 ffff88007c894190
[  850.360359]  0000000000012500 ffff88007c8abfd8 0000000000012500 ffff88007c894190
[  850.362427]  0000000000000020 ffff88007c8ab8b0 0000000000000002 ffffffff81848408
[  850.364505] Call Trace:
[  850.365504]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
[  850.369185]  [<ffffffff81122119>] shrink_slab+0x139/0x150
[  850.371553]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
[  850.373384]  [<ffffffff811254c4>] try_to_free_pages+0x94/0xc0
[  850.375503]  [<ffffffff8111a793>] __alloc_pages_nodemask+0x4e3/0xa40
[  850.377333]  [<ffffffff8115a8ce>] alloc_pages_current+0x8e/0x100
[  850.379100]  [<ffffffff8125bed6>] bio_copy_user_iov+0x1d6/0x380
[  850.380763]  [<ffffffff8125e4cd>] ? blk_rq_init+0xed/0x160
[  850.382362]  [<ffffffff8125c119>] bio_copy_kern+0x49/0x100
[  850.384008]  [<ffffffff810a14a0>] ? prepare_to_wait_event+0x100/0x100
[  850.385799]  [<ffffffff81265e6f>] blk_rq_map_kern+0x6f/0x130
[  850.387572]  [<ffffffff8116393e>] ? kmem_cache_alloc+0x48e/0x4b0
[  850.389995]  [<ffffffff813a66cf>] scsi_execute+0x12f/0x160
[  850.391575]  [<ffffffff813a7f14>] scsi_execute_req_flags+0x84/0xf0
[  850.393298]  [<ffffffffa01e29cc>] sr_check_events+0xbc/0x2e0 [sr_mod]
[  850.395050]  [<ffffffff8109834c>] ? put_prev_entity+0x2c/0x3b0
[  850.396696]  [<ffffffffa01d6177>] cdrom_check_events+0x17/0x30 [cdrom]
[  850.398459]  [<ffffffffa01e2e5d>] sr_block_check_events+0x2d/0x30 [sr_mod]
[  850.400321]  [<ffffffff812701c6>] disk_check_events+0x56/0x1b0
[  850.401986]  [<ffffffff81270331>] disk_events_workfn+0x11/0x20
[  850.403621]  [<ffffffff8107ceaf>] process_one_work+0x13f/0x370
[  850.405618]  [<ffffffff8107de99>] worker_thread+0x119/0x500
[  850.407336]  [<ffffffff8107dd80>] ? rescuer_thread+0x350/0x350
[  850.411190]  [<ffffffff81082f7c>] kthread+0xdc/0x100
[  850.412677]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
[  850.414454]  [<ffffffff815a383c>] ret_from_fork+0x7c/0xb0
[  850.416010]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
(...snipped...)
[  907.302050] kworker/1:0     R  running task        0 10832      2 0x00000080
[  907.303961] Workqueue: events_freezable_power_ disk_events_workfn
[  907.305706]  ffff88007c8ab7d8 0000000000000046 ffff88007c8ab8a0 ffff88007c894190
[  907.307761]  0000000000012500 ffff88007c8abfd8 0000000000012500 ffff88007c894190
[  907.309894]  0000000000000020 ffff88007c8ab8b0 0000000000000002 ffffffff81848408
[  907.311949] Call Trace:
[  907.312989]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
[  907.314578]  [<ffffffff81122119>] shrink_slab+0x139/0x150
[  907.316182]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
[  907.317889]  [<ffffffff811254c4>] try_to_free_pages+0x94/0xc0
[  907.319535]  [<ffffffff8111a793>] __alloc_pages_nodemask+0x4e3/0xa40
[  907.321259]  [<ffffffff8115a8ce>] alloc_pages_current+0x8e/0x100
[  907.322945]  [<ffffffff8125bed6>] bio_copy_user_iov+0x1d6/0x380
[  907.324606]  [<ffffffff8125e4cd>] ? blk_rq_init+0xed/0x160
[  907.326196]  [<ffffffff8125c119>] bio_copy_kern+0x49/0x100
[  907.327788]  [<ffffffff810a14a0>] ? prepare_to_wait_event+0x100/0x100
[  907.329549]  [<ffffffff81265e6f>] blk_rq_map_kern+0x6f/0x130
[  907.331184]  [<ffffffff8116393e>] ? kmem_cache_alloc+0x48e/0x4b0
[  907.332877]  [<ffffffff813a66cf>] scsi_execute+0x12f/0x160
[  907.334452]  [<ffffffff813a7f14>] scsi_execute_req_flags+0x84/0xf0
[  907.336156]  [<ffffffffa01e29cc>] sr_check_events+0xbc/0x2e0 [sr_mod]
[  907.337893]  [<ffffffff8109834c>] ? put_prev_entity+0x2c/0x3b0
[  907.339539]  [<ffffffffa01d6177>] cdrom_check_events+0x17/0x30 [cdrom]
[  907.341289]  [<ffffffffa01e2e5d>] sr_block_check_events+0x2d/0x30 [sr_mod]
[  907.343115]  [<ffffffff812701c6>] disk_check_events+0x56/0x1b0
[  907.344771]  [<ffffffff81270331>] disk_events_workfn+0x11/0x20
[  907.346421]  [<ffffffff8107ceaf>] process_one_work+0x13f/0x370
[  907.348057]  [<ffffffff8107de99>] worker_thread+0x119/0x500
[  907.349650]  [<ffffffff8107dd80>] ? rescuer_thread+0x350/0x350
[  907.351295]  [<ffffffff81082f7c>] kthread+0xdc/0x100
[  907.352765]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
[  907.354520]  [<ffffffff815a383c>] ret_from_fork+0x7c/0xb0
[  907.356097]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
----------

I don't know which process is holding the mutex which PID=10732 is waiting
for, but I suspect that a process holding the mutex which PID=10732 is waiting
for is waiting for completion of disk I/O which is processed by PID=10832.

If my suspect is correct, it's a AB-BA livelock because the OOM killer is
waiting for PID=10732 to terminate whereas PID=10832 cannot complete disk
I/O due to waiting for the OOM killer. Unfortunately I'm not familiar with
XFS, thus I can't find who is.

Maybe PID=10802 than PID=10832? Then, why both PID=10802 and PID=10832 are
blocked for memory allocation?

----------
[  715.162520] a.out           R  running task        0 10802      1 0x00000084
[  715.164482]  ffff88007b877898 0000000000000082 ffff88007b877960 ffff8800751bc050
[  715.166574]  0000000000012500 ffff88007b877fd8 0000000000012500 ffff8800751bc050
[  715.169036]  0000000000000020 ffff88007b877970 0000000000000003 ffffffff81848408
[  715.171125] Call Trace:
[  715.172185]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
[  715.173773]  [<ffffffff81122119>] shrink_slab+0x139/0x150
[  715.175356]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
[  715.177088]  [<ffffffff811254c4>] try_to_free_pages+0x94/0xc0
[  715.178721]  [<ffffffff8111a793>] __alloc_pages_nodemask+0x4e3/0xa40
[  715.180583]  [<ffffffff8115a8ce>] alloc_pages_current+0x8e/0x100
[  715.182203]  [<ffffffff81111b27>] __page_cache_alloc+0xa7/0xc0
[  715.183864]  [<ffffffff8111263b>] pagecache_get_page+0x6b/0x1e0
[  715.185533]  [<ffffffffa02522ae>] ? xfs_trans_commit+0x13e/0x230 [xfs]
[  715.187314]  [<ffffffff811127de>] grab_cache_page_write_begin+0x2e/0x50
[  715.189108]  [<ffffffffa02301cf>] xfs_vm_write_begin+0x2f/0xe0 [xfs]
[  715.190876]  [<ffffffff8111188c>] generic_perform_write+0xcc/0x1d0
[  715.192610]  [<ffffffffa023b50f>] ? xfs_file_aio_write_checks+0xdf/0xf0 [xfs]
[  715.194526]  [<ffffffffa023b5ef>] xfs_file_buffered_aio_write.isra.15+0xcf/0x200 [xfs]
[  715.196580]  [<ffffffffa023b79e>] xfs_file_write_iter+0x7e/0x120 [xfs]
[  715.198368]  [<ffffffff8117edd9>] new_sync_write+0x89/0xd0
[  715.200029]  [<ffffffff8117f742>] vfs_write+0xb2/0x1f0
[  715.201576]  [<ffffffff8101a9f4>] ? do_audit_syscall_entry+0x64/0x70
[  715.203309]  [<ffffffff81180200>] SyS_write+0x50/0xc0
[  715.204866]  [<ffffffff810f729e>] ? __audit_syscall_exit+0x22e/0x2d0
[  715.206613]  [<ffffffff815a38e9>] system_call_fastpath+0x12/0x17
(...snipped...)
[  906.533722] a.out           R  running task        0 10802      1 0x00000084
[  906.535671]  ffff88007b877898 0000000000000082 ffff88007b877960 ffff8800751bc050
[  906.537699]  0000000000012500 ffff88007b877fd8 0000000000012500 ffff8800751bc050
[  906.539838]  0000000000000020 ffff88007b877970 0000000000000003 ffffffff81848408
[  906.541916] Call Trace:
[  906.543075]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
[  906.544610]  [<ffffffff81122119>] shrink_slab+0x139/0x150
[  906.546223]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
[  906.547941]  [<ffffffff811254c4>] try_to_free_pages+0x94/0xc0
[  906.549622]  [<ffffffff8111a793>] __alloc_pages_nodemask+0x4e3/0xa40
[  906.551357]  [<ffffffff8115a8ce>] alloc_pages_current+0x8e/0x100
[  906.553070]  [<ffffffff81111b27>] __page_cache_alloc+0xa7/0xc0
[  906.554748]  [<ffffffff8111263b>] pagecache_get_page+0x6b/0x1e0
[  906.556409]  [<ffffffffa02522ae>] ? xfs_trans_commit+0x13e/0x230 [xfs]
[  906.558180]  [<ffffffff811127de>] grab_cache_page_write_begin+0x2e/0x50
[  906.560242]  [<ffffffffa02301cf>] xfs_vm_write_begin+0x2f/0xe0 [xfs]
[  906.562027]  [<ffffffff8111188c>] generic_perform_write+0xcc/0x1d0
[  906.563851]  [<ffffffffa023b50f>] ? xfs_file_aio_write_checks+0xdf/0xf0 [xfs]
[  906.565838]  [<ffffffffa023b5ef>] xfs_file_buffered_aio_write.isra.15+0xcf/0x200 [xfs]
[  906.567892]  [<ffffffffa023b79e>] xfs_file_write_iter+0x7e/0x120 [xfs]
[  906.569719]  [<ffffffff8117edd9>] new_sync_write+0x89/0xd0
[  906.571300]  [<ffffffff8117f742>] vfs_write+0xb2/0x1f0
[  906.572836]  [<ffffffff8101a9f4>] ? do_audit_syscall_entry+0x64/0x70
[  906.574578]  [<ffffffff81180200>] SyS_write+0x50/0xc0
[  906.576198]  [<ffffffff810f729e>] ? __audit_syscall_exit+0x22e/0x2d0
[  906.577929]  [<ffffffff815a38e9>] system_call_fastpath+0x12/0x17
----------

Anyway stalling for 10 minutes upon OOM (and can't solve with SysRq-f) is
unusable for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
