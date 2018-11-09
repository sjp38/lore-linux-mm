Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 53A8D6B06BB
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 03:42:46 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id f69-v6so959863pfa.15
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 00:42:46 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m1-v6si5381987plb.303.2018.11.09.00.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 00:42:44 -0800 (PST)
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <074309b9-ada4-ce39-5332-d64a1263e9f8@suse.cz>
Date: Fri, 9 Nov 2018 09:42:41 +0100
MIME-Version: 1.0
In-Reply-To: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungtae Kim <kt0755@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, pavel.tatashin@microsoft.com, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net
Cc: lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On 11/9/18 5:09 AM, Kyungtae Kim wrote:
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

This together with [1] makes me rather convinced that we should really
move the check back from __alloc_pages_slowpath to
__alloc_pages_nodemask. It should be a single predictable branch with an
unlikely()?

[1]
https://lore.kernel.org/lkml/154109387197.925352.10499549042420271600.stgit@buzz/T/#u

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
> 
