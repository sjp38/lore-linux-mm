Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D85E96B025E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 09:13:41 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id v125so93669189itc.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:13:41 -0700 (PDT)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id g127si25484249itg.20.2016.05.30.06.13.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 06:13:40 -0700 (PDT)
Received: by mail-it0-x243.google.com with SMTP id z123so6056257itg.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:13:40 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 30 May 2016 15:13:40 +0200
Message-ID: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
Subject: BUG: scheduling while atomic: cron/668/0x10c9a0c0 (was: Re: mm,
 page_alloc: avoid looking up the first zone in a zonelist twice)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

Hi Mel,

On Fri, May 20, 2016 at 7:42 PM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Web:        https://git.kernel.org/torvalds/c/c33d6c06f60f710f0305ae792773e1c2560e1e51
> Commit:     c33d6c06f60f710f0305ae792773e1c2560e1e51
> Parent:     48ee5f3696f62496481a8b6d852bcad9b3ebbe37
> Refname:    refs/heads/master
> Author:     Mel Gorman <mgorman@techsingularity.net>
> AuthorDate: Thu May 19 17:14:10 2016 -0700
> Committer:  Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Thu May 19 19:12:14 2016 -0700
>
>     mm, page_alloc: avoid looking up the first zone in a zonelist twice
>
>     The allocator fast path looks up the first usable zone in a zonelist and
>     then get_page_from_freelist does the same job in the zonelist iterator.
>     This patch preserves the necessary information.
>
>                                                  4.6.0-rc2                  4.6.0-rc2
>                                             fastmark-v1r20             initonce-v1r20
>       Min      alloc-odr0-1               364.00 (  0.00%)           359.00 (  1.37%)
>       Min      alloc-odr0-2               262.00 (  0.00%)           260.00 (  0.76%)
>       Min      alloc-odr0-4               214.00 (  0.00%)           214.00 (  0.00%)
>       Min      alloc-odr0-8               186.00 (  0.00%)           186.00 (  0.00%)
>       Min      alloc-odr0-16              173.00 (  0.00%)           173.00 (  0.00%)
>       Min      alloc-odr0-32              165.00 (  0.00%)           165.00 (  0.00%)
>       Min      alloc-odr0-64              161.00 (  0.00%)           162.00 ( -0.62%)
>       Min      alloc-odr0-128             159.00 (  0.00%)           161.00 ( -1.26%)
>       Min      alloc-odr0-256             168.00 (  0.00%)           170.00 ( -1.19%)
>       Min      alloc-odr0-512             180.00 (  0.00%)           181.00 ( -0.56%)
>       Min      alloc-odr0-1024            190.00 (  0.00%)           190.00 (  0.00%)
>       Min      alloc-odr0-2048            196.00 (  0.00%)           196.00 (  0.00%)
>       Min      alloc-odr0-4096            202.00 (  0.00%)           202.00 (  0.00%)
>       Min      alloc-odr0-8192            206.00 (  0.00%)           205.00 (  0.49%)
>       Min      alloc-odr0-16384           206.00 (  0.00%)           205.00 (  0.49%)
>
>     The benefit is negligible and the results are within the noise but each
>     cycle counts.
>
>     Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
>     Cc: Vlastimil Babka <vbabka@suse.cz>
>     Cc: Jesper Dangaard Brouer <brouer@redhat.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

About one week ago, I started seeing an obscure intermittent crash during
system shutdown on m68k/ARAnyM using atari_defconfig.
The crash isn't 100% reproducible, but it happens during ca. 1 out of 5
shutdowns.

I finally managed to bisect it to the above commit.
I did verify that the parent commit didn't crash after 60 tries.
Unfortunately I couldn't revert the offending commit on top of v4.7-rc1, due to
conflicting changes.

Do you have any idea what's going wrong?
Thanks!

Linux version 4.6.0-atari-05133-gc33d6c06f60f710f (geert@ramsan) (gcc
version 4.1.2 20061115 (prerelease) (Ubuntu 4.1.1-21)) #364 Mon May 30
14:13:39 CEST 2016
Saving 198 bytes of bootinfo
console [debug0] enabled
Atari hardware found: VIDEL STDMA-SCSI ST_MFP YM2149 PCM CODEC DSP56K
SCC ANALOG_JOY Blitter tried to read byte from register ff8a00 at
007606
BLITTER IDE TT_CLK FDC_SPEED
On node 0 totalpages: 3584
free_area_init_node: node 0, pgdat 003ca184, node_mem_map 0046a000
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 3584 pages, LIFO batch:0
On node 1 totalpages: 65536
free_area_init_node: node 1, pgdat 003caa76, node_mem_map 0048e090
  DMA zone: 576 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 65536 pages, LIFO batch:15
NatFeats found (ARAnyM, 1.0)
pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
pcpu-alloc: [0] 0
Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 68512
Kernel command line: root=/dev/hda1 video=atafb:tthigh debug=par
console=tty0 initcall_blacklist=atari_scsi_driver_init
BOOT_IMAGE=vmlinux
blacklisting initcall atari_scsi_driver_init
PID hash table entries: 2048 (order: 1, 8192 bytes)
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Sorting __ex_table...
Memory: 268060K/276480K available (3023K kernel code, 301K rwdata,
716K rodata, 148K init, 178K bss, 8420K reserved, 0K cma-reserved)
Virtual kernel memory layout:
    vector  : 0x003c9c74 - 0x003ca074   (   1 KiB)
    kmap    : 0xd0000000 - 0xf0000000   ( 512 MiB)
    vmalloc : 0x11800000 - 0xd0000000   (3048 MiB)
    lowmem  : 0x00000000 - 0x11000000   ( 272 MiB)
      .init : 0x003f7000 - 0x0041c000   ( 148 KiB)
      .text : 0x00001000 - 0x002f4fc6   (3024 KiB)
      .data : 0x002f7e20 - 0x003f65f0   (1018 KiB)
      .bss  : 0x003c9b80 - 0x003f65f0   ( 179 KiB)
NR_IRQS:141
Console: colour dummy device 80x25
console [tty0] enabled
Calibrating delay loop... 187.80 BogoMIPS (lpj=939008)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
devtmpfs: initialized
clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff,
max_idle_ns: 19112604462750000 ns
NET: Registered protocol family 16
SCSI subsystem initialized
VFS: Disk quotas dquot_6.6.0
VFS: Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
NET: Registered protocol family 2
TCP established hash table entries: 4096 (order: 2, 16384 bytes)
TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
TCP: Hash tables configured (established 4096 bind 4096)
UDP hash table entries: 256 (order: 0, 4096 bytes)
UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
NET: Registered protocol family 1
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
nfhd8: found device with 2118816 blocks (512 bytes)
 nfhd8: AHDI p1 p2
nfeth: API 5
eth0: nfeth addr:192.168.0.1 (192.168.0.2) HWaddr:00:41:45:54:48:30
futex hash table entries: 256 (order: -1, 3072 bytes)
workingset: timestamp_bits=25 max_order=17 bucket_order=0
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
io scheduler noop registered
io scheduler cfq registered (default)
atafb_init: start
atafb_init: initializing Falcon hw
atafb: screen_base 006cf000 phys_screen_base 6cf000 screen_len 311296
Determined 640x480, depth 4
   virtual 640x972
Console: switching to colour frame buffer device 80x30
fb0: frame buffer device, using 304K of video memory
Non-volatile memory driver v1.3
Atari floppy driver: max. HD, track buffering
Probing floppy drive(s):
fd0
brd: module loaded
loop: module loaded
Uniform Multi-Platform E-IDE driver
ide: Falcon IDE controller
Probing IDE interface ide0...
hda: Sarge m68k, ATA DISK drive
ide0 at 0xfff00000 on irq 15 (serialized)
ide-gd driver 1.18
hda: max request size: 128KiB
hda: 2118816 sectors (1084 MB) w/256KiB Cache, CHS=2102/16/63
 hda: AHDI hda1 hda2
ide-cd driver 5.00
initcall atari_scsi_driver_init blacklisted
ne ne (unnamed net_device) (uninitialized): NE*000 ethercard probe at 0x300:
 not found (no reset ack).
ne ne (unnamed net_device) (uninitialized): ne.c: No NE*000 card found
at i/o = 0x300
mousedev: PS/2 mouse device common for all mice
input: Atari Keyboard as /devices/virtual/input/input0
NET: Registered protocol family 17
NET: Registered protocol family 15
Key type dns_resolver registered
hctosys: unable to open rtc device (rtc0)
EXT4-fs (hda1): mounting ext3 file system using the ext4 subsystem
EXT4-fs (hda1): mounted filesystem with ordered data mode. Opts: (null)
VFS: Mounted root (ext3 filesystem) readonly on device 3:1.
devtmpfs: mounted
Freeing unused kernel memory: 148K (003f7000 - 0041c000)
This architecture does not have kernel memory protection.
random: nonblocking pool is initialized
Detected scancode offset = 8 (key: 'left ctrl' with scancode $25)
Adding 137800k swap on /dev/hda2.  Priority:-1 extents:1 across:137800k
EXT4-fs (hda1): re-mounted. Opts:
EXT4-fs (hda1): re-mounted. Opts: errors=remount-ro
BUG: scheduling while atomic: cron/668/0x10c9a0c0
Modules linked in:
CPU: 0 PID: 668 Comm: cron Not tainted 4.6.0-atari-05133-gc33d6c06f60f710f #364
Stack from 10c9a074:
        10c9a074 003763ca 0003d7d0 00361a58 00bcf834 0000029c 10c9a0c0 10c9a0c0
        002f0f42 00bcf5e0 00000000 00000082 0048e018 00000000 00000000 002f0c30
        000410de 00000000 00000000 10c9a0e0 002f112c 00000000 7fffffff 10c9a180
        003b1490 00bcf60c 10c9a1f0 10c9a118 002f2d30 00000000 10c9a174 10c9a180
        0003ef56 003b1490 00bcf60c 003b1490 00bcf60c 0003eff6 003b1490 00bcf60c
        003b1490 10c9a128 002f118e 7fffffff 00000082 002f1612 002f1624 7fffffff
Call Trace: [<0003d7d0>] __schedule_bug+0x40/0x54
 [<002f0f42>] __schedule+0x312/0x388
 [<002f0c30>] __schedule+0x0/0x388
 [<000410de>] prepare_to_wait+0x0/0x52
 [<002f112c>] schedule+0x64/0x82
 [<002f2d30>] schedule_timeout+0xda/0x104
 [<0003ef56>] set_next_entity+0x18/0x40
 [<0003eff6>] pick_next_task_fair+0x78/0xda
 [<002f118e>] io_schedule_timeout+0x36/0x4a
 [<002f1612>] bit_wait_io+0x0/0x40
 [<002f1624>] bit_wait_io+0x12/0x40
 [<002f12c4>] __wait_on_bit+0x46/0x76
 [<0006a06a>] wait_on_page_bit_killable+0x64/0x6c
 [<002f1612>] bit_wait_io+0x0/0x40
 [<000411fe>] wake_bit_function+0x0/0x4e
 [<0006a1b8>] __lock_page_or_retry+0xde/0x124
 [<00217000>] do_scan_async+0x114/0x17c
 [<00098856>] lookup_swap_cache+0x24/0x4e
 [<0008b7c8>] handle_mm_fault+0x626/0x7de
 [<0008ef46>] find_vma+0x0/0x66
 [<002f2612>] down_read+0x0/0xe
 [<0006a001>] wait_on_page_bit_killable_timeout+0x77/0x7c
 [<0008ef5c>] find_vma+0x16/0x66
 [<00006b44>] do_page_fault+0xe6/0x23a
 [<0000c350>] res_func+0xa3c/0x141a
 [<00005bb8>] buserr_c+0x190/0x6d4
 [<0000c350>] res_func+0xa3c/0x141a
 [<000028ec>] buserr+0x20/0x28
 [<0000c350>] res_func+0xa3c/0x141a
 [<000028ec>] buserr+0x20/0x28
...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
