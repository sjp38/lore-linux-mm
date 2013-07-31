Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 7E7B06B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 07:43:13 -0400 (EDT)
Received: by mail-ea0-f179.google.com with SMTP id b10so295142eae.38
        for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:43:11 -0700 (PDT)
Message-ID: <51F8F827.6020108@gmail.com>
Date: Wed, 31 Jul 2013 13:42:31 +0200
From: Wladislav Wiebe <wladislav.kw@gmail.com>
MIME-Version: 1.0
Subject: mm/slab: ppc: ubi: kmalloc_slab WARNING / PPC + UBI driver
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org, cl@linux.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, dedekind1@gmail.com, dwmw2@infradead.org, linux-mtd@lists.infradead.org

Hello guys,

on a PPC 32-Bit board with a Linux Kernel v3.10.0 I see trouble with kmalloc_slab.
Basically at system startup, something request a size of 8388608 b,
but KMALLOC_MAX_SIZE has 4194304 b in our case. It points a WARNING at:
..
NIP [c0099fec] kmalloc_slab+0x60/0xe8
LR [c0099fd4] kmalloc_slab+0x48/0xe8
Call Trace:
[ccd3be60] [c0099fd4] kmalloc_slab+0x48/0xe8 (unreliable)
[ccd3be70] [c00ae650] __kmalloc+0x20/0x1b4
[ccd3be90] [c00d46f4] seq_read+0x2a4/0x540
[ccd3bee0] [c00fe09c] proc_reg_read+0x5c/0x90
[ccd3bef0] [c00b4e1c] vfs_read+0xa4/0x150
[ccd3bf10] [c00b500c] SyS_read+0x4c/0x84
[ccd3bf40] [c000be80] ret_from_syscall+0x0/0x3c
..

Do you have any idea how I can analyze where these 8388608 b coming from?
Kernel log show that UBI driver tries to do something, but I am unsure where it is in detail.

I enabled in the kernel config additionally this parts
- Debug slab memory allocations
- Verbose BUG() reporting (adds 70K)
- Debug VM
- Debug memory initialisation
- Debug page memory allocations

log snip:
...
UBI: attaching mtd0 to ubi0
UBI: scanning is finished
UBI: attached mtd0 (name "fs", size 47 MiB) to ubi0
UBI: PEB size: 131072 bytes (128 KiB), LEB size: 130944 bytes
UBI: min./max. I/O unit sizes: 1/8, sub-page size 1
UBI: VID header offset: 64 (aligned 64), data offset: 128
UBI: good PEBs: 376, bad PEBs: 0, corrupted PEBs: 0
UBI: user volume: 1, internal volumes: 1, max. volumes count: 128
UBI: max/mean erase counter: 8/5, WL threshold: 4096, image sequence number: 657495904
UBI: available PEBs: 0, total reserved PEBs: 376, PEBs reserved for bad PEB handling: 0
UBI: background thread "ubi_bgt0d" started, PID 892
DEBUG: xxx kmalloc_slab, requested 'size' = 8388608, KMALLOC_MAX_SIZE = 4194304
------------[ cut here ]------------
WARNING: at /var/fpwork/wiebe/newfsm/bld/bld-kernelsources-linux/results/linux/mm/slab_common.c:383
Modules linked in: ubi mddg_post(O) mddg_rpram(O) mddg_system_driver(O) mddg_watchdog(O)
CPU: 0 PID: 900 Comm: hexdump Tainted: G           O 3.10.0-0-sampleversion-fcmd #40
task: cf3e7280 ti: ccd3a000 task.ti: ccd3a000
NIP: c0099fec LR: c0099fd4 CTR: c018b0dc
REGS: ccd3bdb0 TRAP: 0700   Tainted: G           O  (3.10.0-0-sampleversion-fcmd)
MSR: 00029000 <CE,EE,ME>  CR: 22000442  XER: 20000000

GPR00: c0099fd4 ccd3be60 cf3e7280 00000000 d100e501 00000005 00000000 c0372ac0
GPR08: 00000004 00000001 00000000 ccd3be20 22000444 100a24dc 00000000 00000000
GPR16: 10076b54 00000000 fffff000 00000000 ccd3bea0 00000000 00000001 00000400
GPR24: 00000000 00000000 4801c000 c00d46f4 ccd3bf18 000000d0 00800000 000000d0
NIP [c0099fec] kmalloc_slab+0x60/0xe8
LR [c0099fd4] kmalloc_slab+0x48/0xe8
Call Trace:
[ccd3be60] [c0099fd4] kmalloc_slab+0x48/0xe8 (unreliable)
[ccd3be70] [c00ae650] __kmalloc+0x20/0x1b4
[ccd3be90] [c00d46f4] seq_read+0x2a4/0x540
[ccd3bee0] [c00fe09c] proc_reg_read+0x5c/0x90
[ccd3bef0] [c00b4e1c] vfs_read+0xa4/0x150
[ccd3bf10] [c00b500c] SyS_read+0x4c/0x84
[ccd3bf40] [c000be80] ret_from_syscall+0x0/0x3c
--- Exception: c01 at 0xfe63934
    LR = 0xfe1a6a8
Instruction dump:
3884dff0 3863e98c 38840094 3cc00040 4cc63182 481e9fc1 73e90200 38600000
40a20090 3d20c038 89291e69 69290001 <0f090000> 2f890000 41be0078 3d20c038
---[ end trace afdc4720a42f3f3c ]---
UBIFS: recovery needed
UBIFS: recovery deferred
UBIFS: mounted UBI device 0, volume 0, name "flash", R/O mode
UBIFS: LEB size: 130944 bytes (127 KiB), min./max. I/O unit sizes: 8 bytes/8 bytes
UBIFS: FS size: 47532672 bytes (45 MiB, 363 LEBs), journal size 2356992 bytes (2 MiB, 18 LEBs)
UBIFS: reserved for root: 0 bytes (0 KiB)
UBIFS: media format: w4/r0 (latest is w4/r0), UUID 7570E817-F0E4-4BF4-8AB5-552B4C55AF30, small LPT model
UBIFS: completing deferred recovery
UBIFS: background thread "ubifs_bgt0_0" started, PID 962
UBIFS: deferred recovery completed
..


Thanks & BR
Wladislav Wiebe


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
