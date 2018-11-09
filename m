Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC6CE6B06BC
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 03:43:57 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o42so823109edc.13
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 00:43:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c21-v6si174094edn.441.2018.11.09.00.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 00:43:55 -0800 (PST)
Date: Fri, 9 Nov 2018 09:43:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
Message-ID: <20181109084353.GA5321@dhcp22.suse.cz>
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungtae Kim <kt0755@gmail.com>
Cc: akpm@linux-foundation.org, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Thu 08-11-18 23:09:23, Kyungtae Kim wrote:
> We report a bug in v4.19-rc2 (4.20-rc1 as well, I guess):
> 
> kernel config: https://kt0755.github.io/etc/config_v2-4.19
> repro: https://kt0755.github.io/etc/repro.c4074.c
> 
> In the middle of page request, this arose because order is too large to handle
>  (mm/page_alloc.c:3119). It actually comes from that order is
> controllable by user input
> via raw_cmd_ioctl without its sanity check, thereby causing memory problem.
> To stop it, we can use like MAX_ORDER for bounds check before using it.

Yes, we do only check the max order in the slow path. We have already
discussed something similar with Konstantin [1][2]. Basically kvmalloc
for a large size might get to the page allocator with an out of bound
order and warn during direct reclaim.

I am wondering whether really want to check for the order in the fast
path instead. I have hard time to imagine this could cause a measurable
impact.

The full patch is below

[1] http://lkml.kernel.org/r/154109387197.925352.10499549042420271600.stgit@buzz
[2] http://lkml.kernel.org/r/154106356066.887821.4649178319705436373.stgit@buzz

> 
> =========================================
> UBSAN: Undefined behaviour in mm/page_alloc.c:3117:19
> shift exponent 51 is too large for 32-bit type 'int'
> CPU: 0 PID: 6520 Comm: syz-executor1 Not tainted 4.19.0-rc2 #1
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:77 [inline]
>  dump_stack+0xd2/0x148 lib/dump_stack.c:113
>  ubsan_epilogue+0x12/0x94 lib/ubsan.c:159
>  __ubsan_handle_shift_out_of_bounds+0x2b6/0x30b lib/ubsan.c:425
>  __zone_watermark_ok+0x2c7/0x400 mm/page_alloc.c:3117
>  zone_watermark_fast mm/page_alloc.c:3216 [inline]
>  get_page_from_freelist+0xc49/0x44c0 mm/page_alloc.c:3300
>  __alloc_pages_nodemask+0x21e/0x640 mm/page_alloc.c:4370
>  alloc_pages_current+0xcc/0x210 mm/mempolicy.c:2093
>  alloc_pages include/linux/gfp.h:509 [inline]
>  __get_free_pages+0x12/0x60 mm/page_alloc.c:4414
>  dma_mem_alloc+0x36/0x50 arch/x86/include/asm/floppy.h:156
>  raw_cmd_copyin drivers/block/floppy.c:3159 [inline]
>  raw_cmd_ioctl drivers/block/floppy.c:3206 [inline]
>  fd_locked_ioctl+0xa00/0x2c10 drivers/block/floppy.c:3544
>  fd_ioctl+0x40/0x60 drivers/block/floppy.c:3571
>  __blkdev_driver_ioctl block/ioctl.c:303 [inline]
>  blkdev_ioctl+0xb3c/0x1a30 block/ioctl.c:601
>  block_ioctl+0x105/0x150 fs/block_dev.c:1883
>  vfs_ioctl fs/ioctl.c:46 [inline]
>  do_vfs_ioctl+0x1c0/0x1150 fs/ioctl.c:687
>  ksys_ioctl+0x9e/0xb0 fs/ioctl.c:702
>  __do_sys_ioctl fs/ioctl.c:709 [inline]
>  __se_sys_ioctl fs/ioctl.c:707 [inline]
>  __x64_sys_ioctl+0x7e/0xc0 fs/ioctl.c:707
>  do_syscall_64+0xc4/0x510 arch/x86/entry/common.c:290
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x4497b9
> Code: e8 8c 9f 02 00 48 83 c4 18 c3 0f 1f 80 00 00 00 00 48 89 f8 48
> 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d
> 01 f0 ff ff 0f 83 9b 6b fc ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:00007fb5ef0e2c68 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 00007fb5ef0e36cc RCX: 00000000004497b9
> RDX: 0000000020000040 RSI: 0000000000000258 RDI: 0000000000000014
> RBP: 000000000071bea0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
> R13: 0000000000005490 R14: 00000000006ed530 R15: 00007fb5ef0e3700
> =========================================================
> 
> 
> Thanks,
> Kyungtae Kim
