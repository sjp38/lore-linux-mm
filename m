Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3BF06B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 07:51:01 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id d65so10612603ith.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 04:51:01 -0700 (PDT)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [198.47.19.12])
        by mx.google.com with ESMTPS id e138si1198463oig.186.2016.08.11.04.51.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Aug 2016 04:51:01 -0700 (PDT)
From: Vignesh R <vigneshr@ti.com>
Subject: kmemleak: Cannot insert 0xff7f1000 into the object search tree
 (overlaps existing)
Message-ID: <7f50c137-5c6a-0882-3704-ae9bb7552c30@ti.com>
Date: Thu, 11 Aug 2016 17:20:51 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>

Hi,


I see the below message from kmemleak when booting linux-next on AM335x
GP EVM and DRA7 EVM

[    0.803934] kmemleak: Cannot insert 0xff7f1000 into the object search
tree (overlaps existing)
[    0.803950] CPU: 0 PID: 1 Comm: swapper/0 Not tainted
4.8.0-rc1-next-20160809 #497
[    0.803958] Hardware name: Generic DRA72X (Flattened Device Tree)
[    0.803979] [<c0110104>] (unwind_backtrace) from [<c010c24c>]
(show_stack+0x10/0x14)
[    0.803994] [<c010c24c>] (show_stack) from [<c0490df0>]
(dump_stack+0xac/0xe0)
[    0.804010] [<c0490df0>] (dump_stack) from [<c0296f88>]
(create_object+0x214/0x278)
[    0.804025] [<c0296f88>] (create_object) from [<c07c770c>]
(kmemleak_alloc_percpu+0x54/0xc0)
[    0.804038] [<c07c770c>] (kmemleak_alloc_percpu) from [<c025fb08>]
(pcpu_alloc+0x368/0x5fc)
[    0.804052] [<c025fb08>] (pcpu_alloc) from [<c0b1bfbc>]
(crash_notes_memory_init+0x10/0x40)
[    0.804064] [<c0b1bfbc>] (crash_notes_memory_init) from [<c010188c>]
(do_one_initcall+0x3c/0x178)
[    0.804075] [<c010188c>] (do_one_initcall) from [<c0b00e98>]
(kernel_init_freeable+0x1fc/0x2c8)
[    0.804086] [<c0b00e98>] (kernel_init_freeable) from [<c07c66b0>]
(kernel_init+0x8/0x114)
[    0.804098] [<c07c66b0>] (kernel_init) from [<c0107910>]
(ret_from_fork+0x14/0x24)
[    0.804106] kmemleak: Kernel memory leak detector disabled
[    0.804113] kmemleak: Object 0xfe800000 (size 16777216):
[    0.804121] kmemleak:   comm "swapper/0", pid 0, jiffies 4294937296
[    0.804127] kmemleak:   min_count = -1
[    0.804132] kmemleak:   count = 0
[    0.804138] kmemleak:   flags = 0x5
[    0.804143] kmemleak:   checksum = 0
[    0.804149] kmemleak:   backtrace:
[    0.804155]      [<c0b26a90>] cma_declare_contiguous+0x16c/0x214
[    0.804170]      [<c0b3c9c0>] dma_contiguous_reserve_area+0x30/0x64
[    0.804183]      [<c0b3ca74>] dma_contiguous_reserve+0x80/0x94
[    0.804195]      [<c0b06810>] arm_memblock_init+0x130/0x184
[    0.804207]      [<c0b04214>] setup_arch+0x590/0xc08
[    0.804217]      [<c0b00940>] start_kernel+0x58/0x3b4
[    0.804227]      [<8000807c>] 0x8000807c
[    0.804237]      [<ffffffff>] 0xffffffff



This happens early in the boot and the stack dump depends on the driver
that is being probed at that moment (and therefore I believe its a
generic issue).
Full boot log here: http://pastebin.ubuntu.com/23014650/
Config used: omap2plus_defconfig +
CONFIG_HAVE_DEBUG_KMEMLEAK=y
CONFIG_DEBUG_KMEMLEAK=y
CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=8000


Has anyone seen this issue before?

Any help appreciated. Thanks!

-- 
Regards
Vignesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
