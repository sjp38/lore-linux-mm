Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id C58786B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:33:32 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id is5so136145941obc.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 22:33:32 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0093.outbound.protection.outlook.com. [157.55.234.93])
        by mx.google.com with ESMTPS id e142si20907737oib.22.2016.01.25.22.33.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 22:33:31 -0800 (PST)
From: <mika.penttila@nextfour.com>
Subject: [PATCH 0/2 v2] set_memory_xx fixes
Date: Tue, 26 Jan 2016 08:33:07 +0200
Message-ID: <1453789989-13260-1-git-send-email-mika.penttila@nextfour.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux@arm.linux.org.uk

Recent changes (4.4.0+) in module loader triggered oops on ARM.

The module in question is in-tree module :
drivers/misc/ti-st/st_drv.ko

The BUG is here :

[ 53.638335] ------------[ cut here ]------------
[ 53.642967] kernel BUG at mm/memory.c:1878!
[ 53.647153] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
[ 53.652987] Modules linked in:
[ 53.656061] CPU: 0 PID: 483 Comm: insmod Not tainted 4.4.0 #3
[ 53.661808] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
[ 53.668338] task: a989d400 ti: 9e6a2000 task.ti: 9e6a2000
[ 53.673751] PC is at apply_to_page_range+0x204/0x224
[ 53.678723] LR is at change_memory_common+0x90/0xdc
[ 53.683604] pc : [<800ca0ec>] lr : [<8001d668>] psr: 600b0013
[ 53.683604] sp : 9e6a3e38 ip : 8001d6b4 fp : 7f0042fc
[ 53.695082] r10: 00000000 r9 : 9e6a3e90 r8 : 00000080
[ 53.700309] r7 : 00000000 r6 : 7f008000 r5 : 7f008000 r4 : 7f008000
[ 53.706837] r3 : 8001d5a4 r2 : 7f008000 r1 : 7f008000 r0 : 80b8d3c0
[ 53.713368] Flags: nZCv IRQs on FIQs on Mode SVC_32 ISA ARM Segment user
[ 53.720504] Control: 10c5387d Table: 2e6b804a DAC: 00000055
[ 53.726252] Process insmod (pid: 483, stack limit = 0x9e6a2210)
[ 53.732173] Stack: (0x9e6a3e38 to 0x9e6a4000)
[ 53.736532] 3e20: 7f007fff 7f008000
[ 53.744714] 3e40: 80b8d3c0 80b8d3c0 00000000 7f007000 7f00426c 7f008000 00000000 7f008000
[ 53.752895] 3e60: 7f004140 7f008000 00000000 00000080 00000000 00000000 7f0042fc 8001d668
[ 53.761076] 3e80: 9e6a3e90 00000000 8001d6b4 7f00426c 00000080 00000000 9e6a3f58 7f004140
[ 53.769257] 3ea0: 7f004240 7f00414c 00000000 8008bbe0 00000000 7f000000 00000000 00000000
[ 53.777438] 3ec0: a8b12f00 0001cfd4 7f004250 7f004240 80b8159c 00000000 000000e0 7f0042fc
[ 53.785619] 3ee0: c183d000 000074f8 000018fd 00000000 0b30000c 00000000 00000000 7f002024
[ 53.793800] 3f00: 00000002 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[ 53.801980] 3f20: 00000000 00000000 00000000 00000000 00000040 00000000 00000003 0001cfd4
[ 53.810161] 3f40: 0000017b 8000f7e4 9e6a2000 00000000 00000002 8008c498 c183d000 000074f8
[ 53.818342] 3f60: c1841588 c1841409 c1842950 00005000 000052a0 00000000 00000000 00000000
[ 53.826523] 3f80: 00000023 00000024 0000001a 0000001e 00000016 00000000 00000000 00000000
[ 53.834703] 3fa0: 003e3d60 8000f640 00000000 00000000 00000003 0001cfd4 00000000 003e3d60
[ 53.842884] 3fc0: 00000000 00000000 003e3d60 0000017b 003e3d20 7eabc9d4 76f2c000 00000002
[ 53.851065] 3fe0: 7eabc990 7eabc980 00016320 76e81d00 600b0010 00000003 00000000 00000000
[ 53.859256] [<800ca0ec>] (apply_to_page_range) from [<8001d668>] (change_memory_common+0x90/0xdc)
[ 53.868139] [<8001d668>] (change_memory_common) from [<8008bbe0>] (load_module+0x194c/0x2068)
[ 53.876671] [<8008bbe0>] (load_module) from [<8008c498>] (SyS_finit_module+0x64/0x74)
[ 53.884512] [<8008c498>] (SyS_finit_module) from [<8000f640>] (ret_fast_syscall+0x0/0x34)
[ 53.892694] Code: e0834104 eaffffbc e51a1008 eaffffac (e7f001f2)
[ 53.898792] ---[ end trace fe43fc78ebde29a3 ]---


apply_to_page_range gets zero length resulting in triggering :

  BUG_ON(addr >= end)

This is regression and a consequence of changes in module section handling.

Fix by making arm and arm64 check for zero size update in change_memory_common(),
letting set_memory_xx(addr, 0); succeed. This makes behavior similar to x86.

Also, BUG_ON() in apply_to_page_range is too strong, make it WARN_ON()
and return -EINVAL instead. There may be other caller expecting !size
to succeed.

v2:
  - drop patch 1/4 for the bounds check, it has been submitted before
  - merge arm/arm64 changes into one patch

--Mika

[PATCH 1/2] arm, arm64: change_memory_common with numpages == 0 should be no-op.
[PATCH 2/2] make apply_to_page_range() more robust.

 arch/arm/mm/pageattr.c   | 3 +++
 arch/arm64/mm/pageattr.c | 3 +++
 mm/memory.c              | 4 +++-
 3 files changed, 9 insertions(+), 1 deletion(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
