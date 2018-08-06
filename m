Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4C66B0007
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 07:57:18 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id x5-v6so9626839ioa.6
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 04:57:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n66-v6si1123918iof.22.2018.08.06.04.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 04:57:15 -0700 (PDT)
Subject: Re: INFO: task hung in generic_file_write_iter
References: <0000000000009ce88d05714242a8@google.com>
 <4b349bff-8ad4-6410-250d-593b13d8d496@I-love.SAKURA.ne.jp>
 <9b9fcdda-c347-53ee-fdbb-8a7d11cf430e@I-love.SAKURA.ne.jp>
 <20180720130602.f3d6dc4c943558875a36cb52@linux-foundation.org>
 <a2df1f24-f649-f5d8-0b2d-66d45b6cb61f@i-love.sakura.ne.jp>
 <20180806100928.x7anab3c3y5q4ssa@quack2.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <8248f4e9-3567-b8f5-4751-8b38c1807eff@i-love.sakura.ne.jp>
Date: Mon, 6 Aug 2018 20:56:30 +0900
MIME-Version: 1.0
In-Reply-To: <20180806100928.x7anab3c3y5q4ssa@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>, linux-mm@kvack.org, mgorman@techsingularity.net, Michal Hocko <mhocko@kernel.org>, ak@linux.intel.com, jlayton@redhat.com, linux-kernel@vger.kernel.org, mawilcox@microsoft.com, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 2018/08/06 19:09, Jan Kara wrote:
>> syzbot reproduced this problem ( https://syzkaller.appspot.com/text?tag=CrashLog&x=11f2fc44400000 ) .
>> It says that grow_dev_page() is returning 1 but __find_get_block() is failing forever. Any idea?

So far syzbot reproduced 7 times, and all reports are saying that
grow_dev_page() is returning 1 but __find_get_block() is failing forever.

  INFO: task hung in __get_super
  https://syzkaller.appspot.com/text?tag=CrashLog&x=17347272400000

  INFO: task hung in __blkdev_get (2)
  https://syzkaller.appspot.com/text?tag=CrashLog&x=144347fc400000
  https://syzkaller.appspot.com/text?tag=CrashLog&x=12382bfc400000

  INFO: task hung in __writeback_inodes_sb_nr
  https://syzkaller.appspot.com/text?tag=CrashLog&x=11f2fc44400000
  https://syzkaller.appspot.com/text?tag=CrashLog&x=13c2449c400000

  INFO: task hung in filename_create
  https://syzkaller.appspot.com/text?tag=CrashLog&x=174a672c400000

  INFO: task hung in lookup_slow
  https://syzkaller.appspot.com/text?tag=CrashLog&x=16113bdc400000

> 
> Looks like some kind of a race where device block size gets changed while
> getblk() runs (and creates buffers for underlying page). I don't have time
> to nail it down at this moment can have a look into it later unless someone
> beats me to it.
> 

It seems that loop device is relevant to this problem.

144347fc400000:

[  557.484258] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  560.491589] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  563.500432] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  566.508502] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  569.516546] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  572.524800] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  575.532499] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  575.803688] INFO: task syz-executor7:7893 blocked for more than 140 seconds.
[  575.810957]       Not tainted 4.18.0-rc7-next-20180801+ #29
[  575.816685] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  575.824663] syz-executor7   D24464  7893   4272 0x00000004
[  575.830298] Call Trace:
[  575.832911]  __schedule+0x87c/0x1ec0
[  575.879299]  schedule+0xfb/0x450
[  575.912448]  rwsem_down_read_failed+0x362/0x610
[  575.951922]  call_rwsem_down_read_failed+0x18/0x30
[  575.956843]  down_read+0xc3/0x1d0
[  575.990222]  __get_super.part.12+0x20f/0x2e0
[  575.994654]  get_super+0x2d/0x50
[  575.998016]  fsync_bdev+0x17/0xc0
[  576.001469]  invalidate_partition+0x35/0x60
[  576.005800]  drop_partitions.isra.13+0xe8/0x200
[  576.023366]  rescan_partitions+0x75/0x910
[  576.037534]  __blkdev_reread_part+0x1ad/0x230
[  576.042023]  blkdev_reread_part+0x26/0x40
[  576.046173]  loop_reread_partitions+0x163/0x190
[  576.055795]  loop_set_status+0xb95/0x1010
[  576.059938]  loop_set_status64+0xaa/0x100
[  576.078629]  lo_ioctl+0x90e/0x1d70
[  576.095290]  blkdev_ioctl+0x9cd/0x2030
[  576.146746]  block_ioctl+0xee/0x130
[  576.154704]  do_vfs_ioctl+0x1de/0x1720
[  576.183069]  ksys_ioctl+0xa9/0xd0
[  576.186519]  __x64_sys_ioctl+0x73/0xb0
[  576.190423]  do_syscall_64+0x1b9/0x820



It seems that there was loop_reread_partitions() failure before this message starts.

12382bfc400000:

[  205.467816] loop_reread_partitions: partition scan of loop0 (<E1><D3><F8>w<E5><EA><E4>S<E5>]}d<D0>^MI^A<BA><ED>!<F7><DE><92><A8>f<9B>8<CC><D6>W<DB><F5><AE>F5Eice^W<B5>^O<80>Z<E2>^H%<8D><BA>}
[  205.467816] <BE><8D> <8F>^OESC<CC><88>\<8B><A9>) failed (rc=1)

[  205.905418] loop_reread_partitions: partition scan of loop0 (<E1><D3><F8>w<E5><EA><E4>S<E5>]}d<D0>^MI^A<BA><ED>!<F7><DE><92><A8>f<9B>8<CC><D6>W<DB><F5><AE>F5Eice^W<B5>^O<80>Z<E2>^H%<8D><BA>}
[  205.905418] <BE><8D> <8F>^OESC<CC><88>\<8B><A9>) failed (rc=-16)

[  206.113592] loop_reread_partitions: partition scan of loop0 (<E1><D3><F8>w<E5><EA><E4>S<E5>]}d<D0>^MI^A<BA><ED>!<F7><DE><92><A8>f<9B>8<CC><D6>W<DB><F5><AE>F5Eice^W<B5>^O<80>Z<E2>^H%<8D><BA>}
[  206.113592] <BE><8D> <8F>^OESC<CC><88>\<8B><A9>) failed (rc=-16)

[  206.767225] loop_reread_partitions: partition scan of loop0 (<E1><D3><F8>w<E5><EA><E4>S<E5>]}d<D0>^MI^A<BA><ED>!<F7><DE><92><A8>f<9B>8<CC><D6>W<DB><F5><AE>F5Eice^W<B5>^O<80>Z<E2>^H%<8D><BA>}
[  206.767225] <BE><8D> <8F>^OESC<CC><88>\<8B><A9>) failed (rc=-16)

[  206.990060] loop_reread_partitions: partition scan of loop0 (<E1><D3><F8>w<E5><EA><E4>S<E5>]}d<D0>^MI^A<BA><ED>!<F7><DE><92><A8>f<9B>8<CC><D6>W<DB><F5><AE>F5Eice^W<B5>^O<80>Z<E2>^H%<8D><BA>}
[  206.990060] <BE><8D> <8F>^OESC<CC><88>\<8B><A9>) failed (rc=1)

[  208.630329] loop_reread_partitions: partition scan of loop0 (<E1><D3><F8>w<E5><EA><E4>S<E5>]}d<D0>^MI^A<BA><ED>!<F7><DE><92><A8>f<9B>8<CC><D6>W<DB><F5><AE>F5Eice^W<B5>^O<80>Z<E2>^H%<8D><BA>}
[  208.630329] <BE><8D> <8F>^OESC<CC><88>\<8B><A9>) failed (rc=-16)

[  228.101929] loop_reread_partitions: partition scan of loop0 (<E1><D3><F8>w<E5><EA><E4>S<E5>]}d<D0>^MI^A<BA><ED>!<F7><DE><92><A8>f<9B>8<CC><D6>W<DB><F5><AE>F5Eice^W<B5>^O<80>Z<E2>^H%<8D><BA>}
[  228.101929] <BE><8D> <8F>^OESC<CC><88>\<8B><A9>) failed (rc=-16)

[  228.605840] loop_reread_partitions: partition scan of loop0 (<E1><D3><F8>w<E5><EA><E4>S<E5>]}d<D0>^MI^A<BA><ED>!<F7><DE><92><A8>f<9B>8<CC><D6>W<DB><F5><AE>F5Eice^W<B5>^O<80>Z<E2>^H%<8D><BA>}
[  228.605840] <BE><8D> <8F>^OESC<CC><88>\<8B><A9>) failed (rc=1)

[  229.400629] loop_reread_partitions: partition scan of loop0 (<E1><D3><F8>w<E5><EA><E4>S<E5>]}d<D0>^MI^A<BA><ED>!<F7><DE><92><A8>f<9B>8<CC><D6>W<DB><F5><AE>F5Eice^W<B5>^O<80>Z<E2>^H%<8D><BA>}
[  229.400629] <BE><8D> <8F>^OESC<CC><88>\<8B><A9>) failed (rc=1)

[  229.622379] loop_reread_partitions: partition scan of loop0 (<E1><D3><F8>w<E5><EA><E4>S<E5>]}d<D0>^MI^A<BA><ED>!<F7><DE><92><A8>f<9B>8<CC><D6>W<DB><F5><AE>F5Eice^W<B5>^O<80>Z<E2>^H%<8D><BA>}
[  229.622379] <BE><8D> <8F>^OESC<CC><88>\<8B><A9>) failed (rc=1)

[  233.406342] syz-executor0(18214): getblk(): executed=9 bh_count=0 bh_state=0
[  236.414328] syz-executor0(18214): getblk(): executed=9 bh_count=0 bh_state=0
[  239.422327] syz-executor0(18214): getblk(): executed=9 bh_count=0 bh_state=0
[  242.430332] syz-executor0(18214): getblk(): executed=9 bh_count=0 bh_state=0
(...snipped...)
[  416.894327] syz-executor0(18214): getblk(): executed=9 bh_count=0 bh_state=0
[  419.902327] syz-executor0(18214): getblk(): executed=9 bh_count=0 bh_state=0
[  422.910325] syz-executor0(18214): getblk(): executed=9 bh_count=0 bh_state=0
[  425.918329] syz-executor0(18214): getblk(): executed=9 bh_count=0 bh_state=0

[  431.005871] NMI backtrace for cpu 0
[  431.005876] CPU: 0 PID: 18214 Comm: syz-executor0 Not tainted 4.18.0-rc6-next-20180725+ #18
[  431.005881] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  431.005884] RIP: 0010:write_comp_data+0x14/0x70
[  431.005893] Code: 4c 89 ef e8 1e 93 3e 00 e9 76 fc ff ff e8 b4 9c ca ff 90 90 90 90 55 65 4c 8b 04 25 40 ee 01 00 65 8b 05 2f 46 85 7e 48 89 e5 <a9> 00 01 1f 00 75 51 41 8b 80 98 12 00 00 83 f8 03 75 45 49 8b 80
[  431.005896] RSP: 0018:ffff880192487130 EFLAGS: 00000046
[  431.005903] RAX: 0000000080000000 RBX: ffff880168426b28 RCX: ffffffff81d704dd
[  431.005906] RDX: 000000000003085f RSI: 000000000000000d RDI: 0000000000000006
[  431.005910] RBP: ffff880192487130 R08: ffff8801d9696200 R09: fffff94000af6a66
[  431.005914] R10: fffff94000af6a66 R11: ffffea00057b5337 R12: 0000000000000006
[  431.005918] R13: dffffc0000000000 R14: 0000000000000006 R15: 000000000003085f
[  431.005923] FS:  00007f6c291f1700(0000) GS:ffff8801db000000(0000) knlGS:0000000000000000
[  431.005926] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  431.005930] CR2: ffffffffff600400 CR3: 00000001c5ff4000 CR4: 00000000001406f0
[  431.005935] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  431.005938] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  431.005941] Call Trace:
[  431.005944]  __sanitizer_cov_trace_cmp8+0x18/0x20
[  431.005946]  __find_get_block+0x1bd/0xe60
[  431.005969]  __getblk_gfp+0x3dc/0xe00
[  431.005996]  __bread_gfp+0x2d/0x310
[  431.005999]  fat__get_entry+0x59c/0xa30
[  431.006017]  fat_get_short_entry+0x13c/0x2c0
[  431.006020]  fat_subdirs+0x13c/0x290
[  431.006043]  fat_fill_super+0x29f6/0x4430
[  431.006068]  vfat_fill_super+0x31/0x40
[  431.006070]  mount_bdev+0x314/0x3e0
[  431.006075]  vfat_mount+0x3c/0x50
[  431.006080]  legacy_get_tree+0x131/0x460
[  431.006083]  vfs_get_tree+0x1cb/0x5c0
[  431.006088]  do_mount+0x6f2/0x1e20
[  431.006113]  ksys_mount+0x12d/0x140
[  431.006116]  __x64_sys_mount+0xbe/0x150
[  431.006118]  do_syscall_64+0x1b9/0x820
[  431.006143]  entry_SYSCALL_64_after_hwframe+0x49/0xbe



There were a lot of directory bread failure messages before this message starts.

17347272400000:

[  431.497237] FAT-fs (loop3): Directory bread(block 2574) failed
[  431.505561] FAT-fs (loop3): Directory bread(block 2575) failed
[  431.516048] FAT-fs (loop3): Directory bread(block 2576) failed
[  431.525740] FAT-fs (loop3): Directory bread(block 2577) failed
[  431.535899] FAT-fs (loop3): Directory bread(block 2578) failed
[  431.636001] FAT-fs (loop5): bogus number of reserved sectors
[  431.641910] FAT-fs (loop5): Can't find a valid FAT filesystem
[  434.145080] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  437.152496] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  440.161598] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  443.169498] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
(...snipped...)
[  563.500432] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  566.508502] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  569.516546] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  572.524800] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  575.532499] syz-executor0(7883): getblk(): executed=9 bh_count=0 bh_state=0
[  575.803688] INFO: task syz-executor7:7893 blocked for more than 140 seconds.
[  575.810957]       Not tainted 4.18.0-rc7-next-20180801+ #29
[  575.816685] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  575.824663] syz-executor7   D24464  7893   4272 0x00000004
[  575.830298] Call Trace:
[  575.832911]  __schedule+0x87c/0x1ec0
[  575.879299]  schedule+0xfb/0x450
[  575.912448]  rwsem_down_read_failed+0x362/0x610
[  575.951922]  call_rwsem_down_read_failed+0x18/0x30
[  575.956843]  down_read+0xc3/0x1d0
[  575.990222]  __get_super.part.12+0x20f/0x2e0
[  575.994654]  get_super+0x2d/0x50
[  575.998016]  fsync_bdev+0x17/0xc0
[  576.001469]  invalidate_partition+0x35/0x60
[  576.005800]  drop_partitions.isra.13+0xe8/0x200
[  576.023366]  rescan_partitions+0x75/0x910
[  576.037534]  __blkdev_reread_part+0x1ad/0x230
[  576.042023]  blkdev_reread_part+0x26/0x40
[  576.046173]  loop_reread_partitions+0x163/0x190
[  576.055795]  loop_set_status+0xb95/0x1010
[  576.059938]  loop_set_status64+0xaa/0x100
[  576.078629]  lo_ioctl+0x90e/0x1d70
[  576.095290]  blkdev_ioctl+0x9cd/0x2030
[  576.146746]  block_ioctl+0xee/0x130
[  576.154704]  do_vfs_ioctl+0x1de/0x1720
[  576.183069]  ksys_ioctl+0xa9/0xd0
[  576.186519]  __x64_sys_ioctl+0x73/0xb0
[  576.190423]  do_syscall_64+0x1b9/0x820
[  576.246994]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
