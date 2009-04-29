Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 431E16B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 04:22:08 -0400 (EDT)
Date: Wed, 29 Apr 2009 16:21:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: btrfs BUG on creating huge sparse file
Message-ID: <20090429082151.GA15170@localhost>
References: <20090407509.382219156@firstfloor.org> <20090407151010.E72A91D0471@basil.firstfloor.org> <1239210239.28688.15.camel@think.oraclecorp.com> <20090409072949.GF14687@one.firstfloor.org> <20090409075805.GG14687@one.firstfloor.org> <1239283829.23150.34.camel@think.oraclecorp.com> <20090409140257.GI14687@one.firstfloor.org> <1239287859.23150.57.camel@think.oraclecorp.com> <20090429081616.GA8339@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090429081616.GA8339@localhost>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, npiggin@suse.de, riel@redhat.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 04:16:16PM +0800, Wu Fengguang wrote:
> On Thu, Apr 09, 2009 at 10:37:39AM -0400, Chris Mason wrote:
[snip]
> > PagePrivate is very common.  try_to_releasepage failing on a clean page
> > without the writeback bit set and without dirty/locked buffers will be
> > pretty rare.
> 
> Yup. btrfs seems to tag most(if not all) dirty pages with PG_private.
> While ext4 won't.

Chris, I run into a btrfs BUG() when doing

        dd if=/dev/zero of=/b/sparse bs=1k count=1 seek=104857512345

The half created sparse file is

        -rw-r--r-- 1 root root 98T 2009-04-29 14:54 /b/sparse
        Or
        -rw-r--r-- 1 root root 107374092641280 2009-04-29 14:54 /b/sparse

Below is the kernel messages. I can test patches you throw at me :-)

Thanks,
Fengguang

[ 1067.530868] btrfs allocation failed flags 1, wanted 4096
[ 1067.536313] space_info has 0 free, is full
[ 1067.540533] space_info total=4049600512, pinned=0, delalloc=4096, may_use=0, used=4049600512
[ 1067.549280] block group 12582912 has 8388608 bytes, 8388608 used 0 pinned 0 reserved
[ 1067.557172] 0 blocks of free space at or bigger than bytes is
[ 1067.563020] block group 255918080 has 453181440 bytes, 453181440 used 0 pinned 0 reserved
[ 1067.571334] 0 blocks of free space at or bigger than bytes is
[ 1067.577159] block group 709099520 has 453181440 bytes, 453181440 used 0 pinned 0 reserved
[ 1067.585459] 0 blocks of free space at or bigger than bytes is
[ 1067.591271] block group 1162280960 has 453181440 bytes, 453181440 used 0 pinned 0 reserved
[ 1067.599641] 0 blocks of free space at or bigger than bytes is
[ 1067.605491] block group 1615462400 has 453181440 bytes, 453181440 used 0 pinned 0 reserved
[ 1067.613858] 0 blocks of free space at or bigger than bytes is
[ 1067.619684] block group 2068643840 has 453181440 bytes, 453181440 used 0 pinned 0 reserved
[ 1067.628069] 0 blocks of free space at or bigger than bytes is
[ 1067.633893] block group 2521825280 has 453181440 bytes, 453181440 used 0 pinned 0 reserved
[ 1067.642277] 0 blocks of free space at or bigger than bytes is
[ 1067.648099] block group 2975006720 has 453181440 bytes, 453181440 used 0 pinned 0 reserved
[ 1067.656483] 0 blocks of free space at or bigger than bytes is
[ 1067.662295] block group 3428188160 has 453181440 bytes, 453181440 used 0 pinned 0 reserved
[ 1067.670666] 0 blocks of free space at or bigger than bytes is
[ 1067.676508] block group 3881369600 has 415760384 bytes, 415760384 used 0 pinned 0 reserved
[ 1067.684877] 0 blocks of free space at or bigger than bytes is
[ 1067.690747] ------------[ cut here ]------------
[ 1067.695435] kernel BUG at fs/btrfs/extent-tree.c:2872!
[ 1067.700646] invalid opcode: 0000 [#1] SMP
[ 1067.704873] last sysfs file: /sys/devices/LNXSYSTM:00/device:00/PNP0C0A:00/power_supply/C23B/charge_full
[ 1067.714473] CPU 0
[ 1067.716575] Modules linked in: drm iwlagn iwlcore snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_seq snd_timer snd_seq_device snd soundcore snd_page_alloc video
[ 1067.733699] Pid: 3358, comm: dd Not tainted 2.6.30-rc2-next-20090417 #202 HP Compaq 6910p
[ 1067.741975] RIP: 0010:[<ffffffff81201b23>]  [<ffffffff81201b23>] __btrfs_reserve_extent+0x213/0x300
[ 1067.751185] RSP: 0018:ffff8800791c77f8  EFLAGS: 00010292
[ 1067.756581] RAX: 0000000000022533 RBX: ffff88007b8c5030 RCX: 0000000000000006
[ 1067.763777] RDX: ffffffff81ccffa0 RSI: ffff8800791c1db0 RDI: 0000000000000286
[ 1067.770984] RBP: ffff8800791c7878 R08: 0000000000000000 R09: 0000000000000000
[ 1067.778203] R10: 0000000000000001 R11: 0000000000000001 R12: ffff88007b38e4b8
[ 1067.785440] R13: 0000000000001000 R14: ffff88007b38e6a8 R15: ffff88007b38e658
[ 1067.792657] FS:  00007f5801f136f0(0000) GS:ffff880005a00000(0000) knlGS:0000000000000000
[ 1067.800851] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1067.806668] CR2: 00007f58017c1622 CR3: 000000007bb62000 CR4: 00000000000006e0
[ 1067.813882] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1067.821087] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1067.828304] Process dd (pid: 3358, threadinfo ffff8800791c6000, task ffff8800791c1600)
[ 1067.836319] Stack:
[ 1067.838389]  0000000000000000 ffff8800791c7948 0000000000000000 0000000000000000
[ 1067.845792]  0000000000000001 0000000000000000 0000000000000000 0000000000000000
[ 1067.853464]  ffff88007bbe4000 0000000100000000 0000000000000001 ffff8800791c7948
[ 1067.861360] Call Trace:
[ 1067.863863]  [<ffffffff81201e0b>] btrfs_reserve_extent+0x3b/0x70
[ 1067.869984]  [<ffffffff81218feb>] cow_file_range+0x21b/0x3d0
[ 1067.875745]  [<ffffffff8122f519>] ? test_range_bit+0xb9/0x180
[ 1067.881616]  [<ffffffff81219be2>] run_delalloc_range+0x302/0x3b0
[ 1067.887727]  [<ffffffff8122f519>] ? test_range_bit+0xb9/0x180
[ 1067.893583]  [<ffffffff8123352f>] ? find_lock_delalloc_range+0x12f/0x1c0
[ 1067.900396]  [<ffffffff81233c45>] __extent_writepage+0x175/0x990
[ 1067.906502]  [<ffffffff810794a8>] ? mark_held_locks+0x68/0x90
[ 1067.912361]  [<ffffffff810ca581>] ? clear_page_dirty_for_io+0x171/0x190
[ 1067.919080]  [<ffffffff810797fd>] ? trace_hardirqs_on_caller+0x16d/0x1c0
[ 1067.925891]  [<ffffffff812308ce>] extent_write_cache_pages+0x1ee/0x400
[ 1067.932529]  [<ffffffff8122e970>] ? flush_write_bio+0x0/0x40
[ 1067.938288]  [<ffffffff81233ad0>] ? __extent_writepage+0x0/0x990
[ 1067.944404]  [<ffffffff810794a8>] ? mark_held_locks+0x68/0x90
[ 1067.950254]  [<ffffffff810f88e5>] ? kmem_cache_free+0x145/0x260
[ 1067.956287]  [<ffffffff810797fd>] ? trace_hardirqs_on_caller+0x16d/0x1c0
[ 1067.963091]  [<ffffffff81230b22>] extent_writepages+0x42/0x70
[ 1067.968957]  [<ffffffff81217020>] ? btrfs_get_extent+0x0/0x960
[ 1067.974891]  [<ffffffff81216e58>] btrfs_writepages+0x28/0x30
[ 1067.980663]  [<ffffffff8122b940>] btrfs_fdatawrite_range+0x50/0x60
[ 1067.986942]  [<ffffffff8122c2c6>] btrfs_wait_ordered_range+0xb6/0x170
[ 1067.993508]  [<ffffffff8121cce4>] btrfs_truncate+0x74/0x160
[ 1067.999183]  [<ffffffff810dd46d>] vmtruncate+0xad/0x110
[ 1068.004529]  [<ffffffff81117095>] inode_setattr+0x35/0x180
[ 1068.010116]  [<ffffffff8121d3ab>] btrfs_setattr+0x6b/0xd0
[ 1068.015616]  [<ffffffff81117301>] notify_change+0x121/0x330
[ 1068.021298]  [<ffffffff810fd1aa>] do_truncate+0x6a/0x90
[ 1068.026623]  [<ffffffff810fd2c0>] sys_ftruncate+0xf0/0x130
[ 1068.032220]  [<ffffffff8100c2b2>] system_call_fastpath+0x16/0x1b
[ 1068.038364] Code: 4c 8d a0 60 fe ff ff 49 8b 84 24 a0 01 00 00 0f 18 08 49 8d 84 24 a0 01 00 00 49 39 c7 0f 85 8c 00 00 00 4c 89 f7 e8 8d 8e e6 ff <0f> 0b eb fe 66 0f 1f 84 00 00 00 00 00 49 d1 ed 41 8b 84 24 60
[ 1068.059472] RIP  [<ffffffff81201b23>] __btrfs_reserve_extent+0x213/0x300
[ 1068.066299]  RSP <ffff8800791c77f8>
[ 1068.070292] ---[ end trace ab42ff0a881d9568 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
