Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id E10326B068F
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 23:09:36 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id n12-v6so731793ioh.2
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 20:09:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v3-v6sor1349917iob.40.2018.11.08.20.09.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 20:09:35 -0800 (PST)
MIME-Version: 1.0
From: Kyungtae Kim <kt0755@gmail.com>
Date: Thu, 8 Nov 2018 23:09:23 -0500
Message-ID: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
Subject: UBSAN: Undefined behaviour in mm/page_alloc.c
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net
Cc: lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We report a bug in v4.19-rc2 (4.20-rc1 as well, I guess):

kernel config: https://kt0755.github.io/etc/config_v2-4.19
repro: https://kt0755.github.io/etc/repro.c4074.c

In the middle of page request, this arose because order is too large to handle
 (mm/page_alloc.c:3119). It actually comes from that order is
controllable by user input
via raw_cmd_ioctl without its sanity check, thereby causing memory problem.
To stop it, we can use like MAX_ORDER for bounds check before using it.

=========================================
UBSAN: Undefined behaviour in mm/page_alloc.c:3117:19
shift exponent 51 is too large for 32-bit type 'int'
CPU: 0 PID: 6520 Comm: syz-executor1 Not tainted 4.19.0-rc2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xd2/0x148 lib/dump_stack.c:113
 ubsan_epilogue+0x12/0x94 lib/ubsan.c:159
 __ubsan_handle_shift_out_of_bounds+0x2b6/0x30b lib/ubsan.c:425
 __zone_watermark_ok+0x2c7/0x400 mm/page_alloc.c:3117
 zone_watermark_fast mm/page_alloc.c:3216 [inline]
 get_page_from_freelist+0xc49/0x44c0 mm/page_alloc.c:3300
 __alloc_pages_nodemask+0x21e/0x640 mm/page_alloc.c:4370
 alloc_pages_current+0xcc/0x210 mm/mempolicy.c:2093
 alloc_pages include/linux/gfp.h:509 [inline]
 __get_free_pages+0x12/0x60 mm/page_alloc.c:4414
 dma_mem_alloc+0x36/0x50 arch/x86/include/asm/floppy.h:156
 raw_cmd_copyin drivers/block/floppy.c:3159 [inline]
 raw_cmd_ioctl drivers/block/floppy.c:3206 [inline]
 fd_locked_ioctl+0xa00/0x2c10 drivers/block/floppy.c:3544
 fd_ioctl+0x40/0x60 drivers/block/floppy.c:3571
 __blkdev_driver_ioctl block/ioctl.c:303 [inline]
 blkdev_ioctl+0xb3c/0x1a30 block/ioctl.c:601
 block_ioctl+0x105/0x150 fs/block_dev.c:1883
 vfs_ioctl fs/ioctl.c:46 [inline]
 do_vfs_ioctl+0x1c0/0x1150 fs/ioctl.c:687
 ksys_ioctl+0x9e/0xb0 fs/ioctl.c:702
 __do_sys_ioctl fs/ioctl.c:709 [inline]
 __se_sys_ioctl fs/ioctl.c:707 [inline]
 __x64_sys_ioctl+0x7e/0xc0 fs/ioctl.c:707
 do_syscall_64+0xc4/0x510 arch/x86/entry/common.c:290
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4497b9
Code: e8 8c 9f 02 00 48 83 c4 18 c3 0f 1f 80 00 00 00 00 48 89 f8 48
89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d
01 f0 ff ff 0f 83 9b 6b fc ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007fb5ef0e2c68 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 00007fb5ef0e36cc RCX: 00000000004497b9
RDX: 0000000020000040 RSI: 0000000000000258 RDI: 0000000000000014
RBP: 000000000071bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 0000000000005490 R14: 00000000006ed530 R15: 00007fb5ef0e3700
=========================================================


Thanks,
Kyungtae Kim
