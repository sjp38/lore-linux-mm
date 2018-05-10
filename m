Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70F196B061E
	for <linux-mm@kvack.org>; Thu, 10 May 2018 11:13:10 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id q8-v6so2514258ioh.7
        for <linux-mm@kvack.org>; Thu, 10 May 2018 08:13:10 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id f65-v6si1027683itg.6.2018.05.10.08.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 08:13:08 -0700 (PDT)
Date: Thu, 10 May 2018 08:13:03 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: stop using buffer heads in xfs and iomap
Message-ID: <20180510151303.GW11261@magnolia>
References: <20180509074830.16196-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 09, 2018 at 09:47:57AM +0200, Christoph Hellwig wrote:
> Hi all,
> 
> this series adds support for reading blocks from disk using the iomap
> interface, and then gradually switched the buffered I/O path to not
> require buffer heads.  It has survived xfstests for 1k and 4k block
> size.
> 
> There are various small changes to the core VFS, block and readahead
> code to make this happen.
> 
> 
> A git tree is available at:
> 
>     git://git.infradead.org/users/hch/xfs.git xfs-remove-bufferheads
> 
> Gitweb:
> 
>     http://git.infradead.org/users/hch/xfs.git/shortlog/refs/heads/xfs-remove-bufferheads

I ran xfstests on this for fun last night but hung in g/095:

FSTYP         -- xfs (debug)
PLATFORM      -- Linux/x86_64 submarine-djwong-mtr01 4.17.0-rc4-djw
MKFS_OPTIONS  -- -f -m reflink=1,rmapbt=1, -i sparse=1, -b size=1024, /dev/sdf
MOUNT_OPTIONS -- /dev/sdf /opt

FWIW the stock v4 and the 'v5 with everything and 4k blocks' vms
passed, so I guess there's a bug somewhere in the sub-page block size
code paths...

--D

[ 2586.943205] run fstests generic/095 at 2018-05-09 23:28:01
[ 2587.252740] XFS (sdf): Unmounting Filesystem
[ 2587.908441] XFS (sdf): Mounting V5 Filesystem
[ 2587.914685] XFS (sdf): Ending clean mount
[ 2702.258764] INFO: task kworker/u10:3:11834 blocked for more than 60 seconds.
[ 2702.261734]       Tainted: G        W         4.17.0-rc4-djw #2
[ 2702.263607] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2702.265600] kworker/u10:3   D11984 11834      2 0x80000000
[ 2702.273445] Workqueue: writeback wb_workfn (flush-8:80)
[ 2702.274751] Call Trace:
[ 2702.275339]  ? __schedule+0x3e4/0xa70
[ 2702.276112]  ? blk_flush_plug_list+0xe4/0x280
[ 2702.277086]  schedule+0x40/0x90
[ 2702.277967]  io_schedule+0x16/0x40
[ 2702.278774]  __lock_page+0x12d/0x160
[ 2702.279680]  ? page_cache_tree_insert+0x100/0x100
[ 2702.280712]  write_cache_pages+0x32c/0x530
[ 2702.281820]  ? xfs_add_to_ioend+0x350/0x350 [xfs]
[ 2702.292350]  xfs_vm_writepages+0x57/0x80 [xfs]
[ 2702.294048]  do_writepages+0x1a/0x70
[ 2702.295068]  __writeback_single_inode+0x59/0x800
[ 2702.296118]  writeback_sb_inodes+0x282/0x550
[ 2702.297039]  __writeback_inodes_wb+0x87/0xb0
[ 2702.298173]  wb_writeback+0x430/0x5d0
[ 2702.299332]  ? wb_workfn+0x448/0x740
[ 2702.300578]  wb_workfn+0x448/0x740
[ 2702.301434]  ? lock_acquire+0xab/0x200
[ 2702.305413]  process_one_work+0x1ef/0x650
[ 2702.306687]  worker_thread+0x4d/0x3e0
[ 2702.307671]  kthread+0x106/0x140
[ 2702.308473]  ? rescuer_thread+0x340/0x340
[ 2702.309442]  ? kthread_delayed_work_timer_fn+0x90/0x90
[ 2702.310995]  ret_from_fork+0x3a/0x50
[ 2702.312088] INFO: task fio:2618 blocked for more than 60 seconds.
[ 2702.313395]       Tainted: G        W         4.17.0-rc4-djw #2
[ 2702.315139] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2702.316820] fio             D14224  2618   2612 0x00000000
[ 2702.318050] Call Trace:
[ 2702.318757]  ? __schedule+0x3e4/0xa70
[ 2702.319639]  ? rwsem_down_read_failed+0x7f/0x170
[ 2702.320798]  schedule+0x40/0x90
[ 2702.321630]  rwsem_down_read_failed+0x128/0x170
[ 2702.322752]  ? current_time+0x18/0x70
[ 2702.323857]  ? xfs_file_dio_aio_read+0x6d/0x1c0 [xfs]
[ 2702.325162]  ? call_rwsem_down_read_failed+0x14/0x30
[ 2702.326423]  call_rwsem_down_read_failed+0x14/0x30
[ 2702.328393]  ? xfs_ilock+0x28f/0x330 [xfs]
[ 2702.329539]  down_read_nested+0x9d/0xa0
[ 2702.330452]  xfs_ilock+0x28f/0x330 [xfs]
[ 2702.331427]  xfs_file_dio_aio_read+0x6d/0x1c0 [xfs]
[ 2702.332590]  xfs_file_read_iter+0x9a/0xb0 [xfs]
[ 2702.333992]  __vfs_read+0x136/0x1a0
[ 2702.335133]  vfs_read+0xa3/0x150
[ 2702.336129]  ksys_read+0x45/0xa0
[ 2702.337085]  do_syscall_64+0x56/0x180
[ 2702.337985]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 2702.339537] RIP: 0033:0x7ff4c152751d
[ 2702.340623] RSP: 002b:00007fffa13c93b0 EFLAGS: 00000293 ORIG_RAX: 0000000000000000
[ 2702.342774] RAX: ffffffffffffffda RBX: 0000000000a0a2c0 RCX: 00007ff4c152751d
[ 2702.344269] RDX: 0000000000000400 RSI: 0000000000a17c00 RDI: 0000000000000005
[ 2702.345801] RBP: 00007ff4a6f57000 R08: 0800000000002000 R09: 0000000000000004
[ 2702.347342] R10: 0000000000000001 R11: 0000000000000293 R12: 0000000000000000
[ 2702.348861] R13: 0000000000000400 R14: 0000000000a0a2e8 R15: 00007ff4a6f57000
[ 2702.351298] INFO: task fio:2619 blocked for more than 60 seconds.
[ 2702.353158]       Tainted: G        W         4.17.0-rc4-djw #2
[ 2702.355103] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2702.357586] fio             D14224  2619   2612 0x00000000
[ 2702.359181] Call Trace:
[ 2702.359815]  ? __schedule+0x3e4/0xa70
[ 2702.360708]  ? rwsem_down_read_failed+0x7f/0x170
[ 2702.361880]  schedule+0x40/0x90
[ 2702.362727]  rwsem_down_read_failed+0x128/0x170
[ 2702.363811]  ? current_time+0x18/0x70
[ 2702.364775]  ? xfs_file_dio_aio_read+0x6d/0x1c0 [xfs]
[ 2702.365994]  ? call_rwsem_down_read_failed+0x14/0x30
[ 2702.367217]  call_rwsem_down_read_failed+0x14/0x30
[ 2702.368411]  ? xfs_ilock+0x28f/0x330 [xfs]
[ 2702.369445]  down_read_nested+0x9d/0xa0
[ 2702.370420]  xfs_ilock+0x28f/0x330 [xfs]
[ 2702.371454]  xfs_file_dio_aio_read+0x6d/0x1c0 [xfs]
[ 2702.372665]  xfs_file_read_iter+0x9a/0xb0 [xfs]
[ 2702.373780]  __vfs_read+0x136/0x1a0
[ 2702.374708]  vfs_read+0xa3/0x150
[ 2702.375521]  ksys_read+0x45/0xa0
[ 2702.376318]  do_syscall_64+0x56/0x180
[ 2702.377207]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 2702.378839] RIP: 0033:0x7ff4c152751d
[ 2702.379625] RSP: 002b:00007fffa13c93b0 EFLAGS: 00000293 ORIG_RAX: 0000000000000000
[ 2702.381190] RAX: ffffffffffffffda RBX: 0000000000a0a2c0 RCX: 00007ff4c152751d
[ 2702.382720] RDX: 0000000000000400 RSI: 0000000000a17c00 RDI: 0000000000000005
[ 2702.384575] RBP: 00007ff4a6f66b48 R08: 1000000000020000 R09: 0000000000000004
[ 2702.386233] R10: 0000000000000001 R11: 0000000000000293 R12: 0000000000000000
[ 2702.387928] R13: 0000000000000400 R14: 0000000000a0a2e8 R15: 00007ff4a6f66b48
[ 2702.389643] INFO: task fio:2620 blocked for more than 60 seconds.
[ 2702.391114]       Tainted: G        W         4.17.0-rc4-djw #2
[ 2702.393061] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2702.395659] fio             D14224  2620   2612 0x00000000
[ 2702.397589] Call Trace:
[ 2702.398474]  ? __schedule+0x3e4/0xa70
[ 2702.399445]  ? rwsem_down_read_failed+0x7f/0x170
[ 2702.400590]  schedule+0x40/0x90
[ 2702.401753]  rwsem_down_read_failed+0x128/0x170
[ 2702.402902]  ? current_time+0x18/0x70
[ 2702.403874]  ? xfs_file_dio_aio_read+0x6d/0x1c0 [xfs]
[ 2702.405080]  ? call_rwsem_down_read_failed+0x14/0x30
[ 2702.406597]  call_rwsem_down_read_failed+0x14/0x30
[ 2702.407918]  ? xfs_ilock+0x28f/0x330 [xfs]
[ 2702.409035]  down_read_nested+0x9d/0xa0
[ 2702.410284]  xfs_ilock+0x28f/0x330 [xfs]
[ 2702.411697]  xfs_file_dio_aio_read+0x6d/0x1c0 [xfs]
[ 2702.413413]  xfs_file_read_iter+0x9a/0xb0 [xfs]
[ 2702.414658]  __vfs_read+0x136/0x1a0
[ 2702.415855]  vfs_read+0xa3/0x150
[ 2702.416789]  ksys_read+0x45/0xa0
[ 2702.417956]  do_syscall_64+0x56/0x180
[ 2702.419108]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 2702.420636] RIP: 0033:0x7ff4c152751d
[ 2702.421861] RSP: 002b:00007fffa13c93b0 EFLAGS: 00000293 ORIG_RAX: 0000000000000000
[ 2702.424332] RAX: ffffffffffffffda RBX: 0000000000a0a2c0 RCX: 00007ff4c152751d
[ 2702.426572] RDX: 0000000000000400 RSI: 0000000000a17c00 RDI: 0000000000000005
[ 2702.428719] RBP: 00007ff4a6f76690 R08: 0001000000000000 R09: 0000000000000004
[ 2702.430587] R10: 0000000000000001 R11: 0000000000000293 R12: 0000000000000000
[ 2702.432113] R13: 0000000000000400 R14: 0000000000a0a2e8 R15: 00007ff4a6f76690
[ 2702.433608] INFO: task fio:2621 blocked for more than 60 seconds.
[ 2702.434932]       Tainted: G        W         4.17.0-rc4-djw #2
[ 2702.436202] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2702.437846] fio             D14272  2621   2612 0x00000000
[ 2702.439057] Call Trace:
[ 2702.439633]  ? __schedule+0x3e4/0xa70
[ 2702.440438]  ? rwsem_down_read_failed+0x7f/0x170
[ 2702.441443]  schedule+0x40/0x90
[ 2702.442149]  rwsem_down_read_failed+0x128/0x170
[ 2702.443199]  ? xfs_file_dio_aio_read+0x6d/0x1c0 [xfs]
[ 2702.444275]  ? call_rwsem_down_read_failed+0x14/0x30
[ 2702.445315]  call_rwsem_down_read_failed+0x14/0x30
[ 2702.446370]  ? xfs_ilock+0x28f/0x330 [xfs]
[ 2702.447300]  down_read_nested+0x9d/0xa0
[ 2702.448172]  xfs_ilock+0x28f/0x330 [xfs]
[ 2702.449059]  xfs_file_dio_aio_read+0x6d/0x1c0 [xfs]
[ 2702.450166]  xfs_file_read_iter+0x9a/0xb0 [xfs]
[ 2702.451204]  __vfs_read+0x136/0x1a0
[ 2702.451991]  vfs_read+0xa3/0x150
[ 2702.452715]  ksys_read+0x45/0xa0
[ 2702.453462]  do_syscall_64+0x56/0x180
[ 2702.454277]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 2702.455406] RIP: 0033:0x7ff4c152751d
[ 2702.456206] RSP: 002b:00007fffa13c93b0 EFLAGS: 00000293 ORIG_RAX: 0000000000000000
[ 2702.457820] RAX: ffffffffffffffda RBX: 0000000000a0a2c0 RCX: 00007ff4c152751d
[ 2702.459361] RDX: 0000000000000400 RSI: 0000000000a17c00 RDI: 0000000000000005
[ 2702.460871] RBP: 00007ff4a6f861d8 R08: 0000000000800000 R09: 0000000000000004
[ 2702.462366] R10: 0000000000000001 R11: 0000000000000293 R12: 0000000000000000
[ 2702.463863] R13: 0000000000000400 R14: 0000000000a0a2e8 R15: 00007ff4a6f861d8
[ 2702.465332] INFO: task fio:2622 blocked for more than 60 seconds.
[ 2702.466634]       Tainted: G        W         4.17.0-rc4-djw #2
[ 2702.467880] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2702.469534] fio             D14296  2622   2612 0x00000000
[ 2702.470742] Call Trace:
[ 2702.471312]  ? __schedule+0x3e4/0xa70
[ 2702.472116]  ? rwsem_down_read_failed+0x7f/0x170
[ 2702.473115]  schedule+0x40/0x90
[ 2702.473831]  rwsem_down_read_failed+0x128/0x170
[ 2702.474911]  ? xfs_file_dio_aio_read+0x6d/0x1c0 [xfs]
[ 2702.476014]  ? call_rwsem_down_read_failed+0x14/0x30
[ 2702.477085]  call_rwsem_down_read_failed+0x14/0x30
[ 2702.478171]  ? xfs_ilock+0x28f/0x330 [xfs]
[ 2702.479114]  down_read_nested+0x9d/0xa0
[ 2702.479999]  xfs_ilock+0x28f/0x330 [xfs]
[ 2702.481052]  xfs_file_dio_aio_read+0x6d/0x1c0 [xfs]
[ 2702.482155]  xfs_file_read_iter+0x9a/0xb0 [xfs]
[ 2702.483461]  __vfs_read+0x136/0x1a0
[ 2702.484542]  vfs_read+0xa3/0x150
[ 2702.485512]  ksys_read+0x45/0xa0
[ 2702.486458]  do_syscall_64+0x56/0x180
[ 2702.487597]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 2702.489099] RIP: 0033:0x7ff4c152751d
[ 2702.490149] RSP: 002b:00007fffa13c93b0 EFLAGS: 00000293 ORIG_RAX: 0000000000000000
[ 2702.492324] RAX: ffffffffffffffda RBX: 0000000000a0a2c0 RCX: 00007ff4c152751d
[ 2702.494580] RDX: 0000000000000400 RSI: 0000000000a17c00 RDI: 0000000000000005
[ 2702.496814] RBP: 00007ff4a6f95d20 R08: 0400000000000000 R09: 0000000000000004
[ 2702.498931] R10: 0000000000000001 R11: 0000000000000293 R12: 0000000000000000
[ 2702.501035] R13: 0000000000000400 R14: 0000000000a0a2e8 R15: 00007ff4a6f95d20
[ 2702.503181] INFO: task fio:2623 blocked for more than 60 seconds.
[ 2702.504980]       Tainted: G        W         4.17.0-rc4-djw #2
[ 2702.506658] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2702.508464] fio             D14240  2623   2612 0x00000000
[ 2702.509927] Call Trace:
[ 2702.510802]  ? __schedule+0x3e4/0xa70
[ 2702.511832]  ? blk_flush_plug_list+0xe4/0x280
[ 2702.512872]  schedule+0x40/0x90
[ 2702.513782]  rwsem_down_read_failed+0x128/0x170
[ 2702.515267]  ? xfs_file_dio_aio_write+0xa8/0x470 [xfs]
[ 2702.516814]  ? call_rwsem_down_read_failed+0x14/0x30
[ 2702.518340]  call_rwsem_down_read_failed+0x14/0x30
[ 2702.520179]  ? xfs_ilock+0x28f/0x330 [xfs]
[ 2702.521639]  down_read_nested+0x9d/0xa0
[ 2702.522945]  xfs_ilock+0x28f/0x330 [xfs]
[ 2702.524196]  xfs_file_dio_aio_write+0xa8/0x470 [xfs]
[ 2702.525682]  xfs_file_write_iter+0x7b/0xb0 [xfs]
[ 2702.527109]  aio_write+0x133/0x1c0
[ 2702.528170]  ? lock_acquire+0xab/0x200
[ 2702.529282]  ? __might_fault+0x36/0x80
[ 2702.530421]  ? do_io_submit+0x41b/0x8d0
[ 2702.531617]  do_io_submit+0x41b/0x8d0
[ 2702.532758]  ? do_syscall_64+0x56/0x180
[ 2702.533950]  ? do_io_submit+0x8d0/0x8d0
[ 2702.535053]  do_syscall_64+0x56/0x180
[ 2702.536048]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 2702.537236] RIP: 0033:0x7ff4c1c57697
[ 2702.538382] RSP: 002b:00007fffa13c9348 EFLAGS: 00000212 ORIG_RAX: 00000000000000d1
[ 2702.540538] RAX: ffffffffffffffda RBX: 0000000000a0a440 RCX: 00007ff4c1c57697
[ 2702.553411] RDX: 0000000000a08320 RSI: 0000000000000008 RDI: 00007ff4a4ef7000
[ 2702.556112] RBP: 0000000000000000 R08: 0000000000000008 R09: 0000000000a097e0
[ 2702.559331] R10: 00000000000001f0 R11: 0000000000000212 R12: 00007ff4a6fa5868
[ 2702.562872] R13: 0000000000a0a480 R14: 0000000000000000 R15: 00007ff4a6fa5870
[ 2702.566224] INFO: task fio:2624 blocked for more than 60 seconds.
[ 2702.568916]       Tainted: G        W         4.17.0-rc4-djw #2
[ 2702.571389] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2702.574938] fio             D14112  2624   2612 0x00000000
[ 2702.577412] Call Trace:
[ 2702.578442]  ? __schedule+0x3e4/0xa70
[ 2702.579995]  ? blk_flush_plug_list+0xe4/0x280
[ 2702.581662]  schedule+0x40/0x90
[ 2702.582905]  rwsem_down_read_failed+0x128/0x170
[ 2702.584628]  ? iomap_apply+0xd5/0x110
[ 2702.586113]  ? xfs_file_dio_aio_write+0xa8/0x470 [xfs]
[ 2702.588344]  ? call_rwsem_down_read_failed+0x14/0x30
[ 2702.590381]  call_rwsem_down_read_failed+0x14/0x30
[ 2702.592192]  ? xfs_ilock+0x28f/0x330 [xfs]
[ 2702.593850]  down_read_nested+0x9d/0xa0
[ 2702.595522]  xfs_ilock+0x28f/0x330 [xfs]
[ 2702.596803]  xfs_file_dio_aio_write+0xa8/0x470 [xfs]
[ 2702.598362]  xfs_file_write_iter+0x7b/0xb0 [xfs]
[ 2702.599758]  aio_write+0x133/0x1c0
[ 2702.600699]  ? lock_acquire+0xab/0x200
[ 2702.601902]  ? __might_fault+0x36/0x80
[ 2702.603056]  ? do_io_submit+0x41b/0x8d0
[ 2702.604191]  do_io_submit+0x41b/0x8d0
[ 2702.605368]  ? do_syscall_64+0x56/0x180
[ 2702.606499]  ? do_io_submit+0x8d0/0x8d0
[ 2702.607643]  do_syscall_64+0x56/0x180
[ 2702.608721]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 2702.610164] RIP: 0033:0x7ff4c1c57697
[ 2702.611202] RSP: 002b:00007fffa13c9348 EFLAGS: 00000212 ORIG_RAX: 00000000000000d1
[ 2702.613435] RAX: ffffffffffffffda RBX: 0000000000a0a440 RCX: 00007ff4c1c57697
[ 2702.615344] RDX: 0000000000a08320 RSI: 0000000000000008 RDI: 00007ff4a4ef6000
[ 2702.617378] RBP: 0000000000000000 R08: 0000000000000008 R09: 0000000000a097e0
[ 2702.619156] R10: 00000000000001f0 R11: 0000000000000212 R12: 00007ff4a6fb53b0
[ 2702.620699] R13: 0000000000a0a480 R14: 0000000000000000 R15: 00007ff4a6fb53b8
[ 2702.622672] INFO: task fio:2625 blocked for more than 60 seconds.
[ 2702.624119]       Tainted: G        W         4.17.0-rc4-djw #2
[ 2702.625533] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2702.627422] fio             D14072  2625   2612 0x00000000
[ 2702.628745] Call Trace:
[ 2702.629393]  ? __schedule+0x3e4/0xa70
[ 2702.630308]  ? blk_flush_plug_list+0xe4/0x280
[ 2702.631402]  schedule+0x40/0x90
[ 2702.632191]  rwsem_down_read_failed+0x128/0x170
[ 2702.633428]  ? iomap_apply+0xd5/0x110
[ 2702.634418]  ? xfs_file_dio_aio_write+0xa8/0x470 [xfs]
[ 2702.635707]  ? call_rwsem_down_read_failed+0x14/0x30
[ 2702.636899]  call_rwsem_down_read_failed+0x14/0x30
[ 2702.638269]  ? xfs_ilock+0x28f/0x330 [xfs]
[ 2702.639300]  down_read_nested+0x9d/0xa0
[ 2702.640190]  xfs_ilock+0x28f/0x330 [xfs]
[ 2702.641091]  xfs_file_dio_aio_write+0xa8/0x470 [xfs]
[ 2702.642385]  xfs_file_write_iter+0x7b/0xb0 [xfs]
[ 2702.643624]  aio_write+0x133/0x1c0
[ 2702.644550]  ? lock_acquire+0xab/0x200
[ 2702.645443]  ? __might_fault+0x36/0x80
[ 2702.646404]  ? do_io_submit+0x41b/0x8d0
[ 2702.647924]  do_io_submit+0x41b/0x8d0
[ 2702.649437]  ? do_syscall_64+0x56/0x180
[ 2702.651040]  ? do_io_submit+0x8d0/0x8d0
[ 2702.652597]  do_syscall_64+0x56/0x180
[ 2702.654063]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 2702.655804] RIP: 0033:0x7ff4c1c57697
[ 2702.657254] RSP: 002b:00007fffa13c9348 EFLAGS: 00000212 ORIG_RAX: 00000000000000d1
[ 2702.660132] RAX: ffffffffffffffda RBX: 0000000000a12600 RCX: 00007ff4c1c57697
[ 2702.662115] RDX: 0000000000a08320 RSI: 0000000000000008 RDI: 00007ff4a4ef5000
[ 2702.663694] RBP: 0000000000000000 R08: 0000000000000008 R09: 0000000000a097e0
[ 2702.665239] R10: 00000000000001f0 R11: 0000000000000212 R12: 00007ff4a6fc4ef8
[ 2702.666850] R13: 0000000000a0a440 R14: 0000000000000000 R15: 00007ff4a6fc4f00
[ 2702.668419] INFO: task fio:2626 blocked for more than 60 seconds.
[ 2702.669747]       Tainted: G        W         4.17.0-rc4-djw #2
[ 2702.671300] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2702.673099] fio             D13752  2626   2612 0x00000000
[ 2702.674841] Call Trace:
[ 2702.675719]  ? __schedule+0x3e4/0xa70
[ 2702.676960]  ? blk_flush_plug_list+0xe4/0x280
[ 2702.678387]  schedule+0x40/0x90
[ 2702.679383]  rwsem_down_read_failed+0x128/0x170
[ 2702.680667]  ? iomap_apply+0xd5/0x110
[ 2702.681779]  ? xfs_file_dio_aio_write+0xa8/0x470 [xfs]
[ 2702.683244]  ? call_rwsem_down_read_failed+0x14/0x30
[ 2702.684683]  call_rwsem_down_read_failed+0x14/0x30
[ 2702.686049]  ? xfs_ilock+0x28f/0x330 [xfs]
[ 2702.687279]  down_read_nested+0x9d/0xa0
[ 2702.688431]  xfs_ilock+0x28f/0x330 [xfs]
[ 2702.689521]  xfs_file_dio_aio_write+0xa8/0x470 [xfs]
[ 2702.690735]  xfs_file_write_iter+0x7b/0xb0 [xfs]
[ 2702.691848]  aio_write+0x133/0x1c0
[ 2702.692679]  ? lock_acquire+0xab/0x200
[ 2702.693565]  ? __might_fault+0x36/0x80
[ 2702.694557]  ? do_io_submit+0x41b/0x8d0
[ 2702.695626]  do_io_submit+0x41b/0x8d0
[ 2702.696461]  ? do_syscall_64+0x56/0x180
[ 2702.697327]  ? do_io_submit+0x8d0/0x8d0
[ 2702.698228]  do_syscall_64+0x56/0x180
[ 2702.699109]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 2702.700224] RIP: 0033:0x7ff4c1c57697
[ 2702.701060] RSP: 002b:00007fffa13c9348 EFLAGS: 00000212 ORIG_RAX: 00000000000000d1
[ 2702.703147] RAX: ffffffffffffffda RBX: 0000000000a0a440 RCX: 00007ff4c1c57697
[ 2702.704913] RDX: 0000000000a08320 RSI: 0000000000000008 RDI: 00007ff4a4ef4000
[ 2702.706747] RBP: 0000000000000000 R08: 0000000000000008 R09: 0000000000a097e0
[ 2702.708506] R10: 00000000000001f0 R11: 0000000000000212 R12: 00007ff4a6fd4a40
[ 2702.710047] R13: 0000000000a0a480 R14: 0000000000000000 R15: 00007ff4a6fd4a48
[ 2702.711685] INFO: lockdep is turned off.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
