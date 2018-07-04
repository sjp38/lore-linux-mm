Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF886B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 03:44:28 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id w73-v6so1241618vkd.9
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 00:44:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m126-v6sor776861vkb.49.2018.07.04.00.44.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 00:44:26 -0700 (PDT)
MIME-Version: 1.0
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com> <1530685696-14672-4-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1530685696-14672-4-git-send-email-rppt@linux.vnet.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 4 Jul 2018 09:44:14 +0200
Message-ID: <CAMuHMdWEHSz34bN-U3gHW972w13f_Jrx_ObEsP3w8XZ1Gx65OA@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, Michal Hocko <mhocko@kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Mike,

On Wed, Jul 4, 2018 at 8:28 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> In m68k the physical memory is described by [memory_start, memory_end] for
> !MMU variant and by m68k_memory array of memory ranges for the MMU version.
> This information is directly use to register the physical memory with
> memblock.
>
> The reserve_bootmem() calls are replaced with memblock_reserve() and the
> bootmap bitmap allocation is simply dropped.
>
> Since the MMU variant creates early mappings only for the small part of the
> memory we force bottom-up allocations in memblock.
>
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Thanks a lot for doing this!

My virtual Atari (using ARAnyM) now has +12KiB of memory available:

-Memory: 267976K/276480K available (3037K kernel code, 304K rwdata,
792K rodata, 148K init, 168K bss, 8504K reserved, 0K cma-reserved)
+Memory: 267988K/276480K available (3036K kernel code, 304K rwdata,
792K rodata, 152K init, 168K bss, 8492K reserved, 0K cma-reserved)

However, a WARNING is triggered. With memblock_debug=1:

Atari hardware found: VIDEL STDMA-SCSI ST_MFP YM2149 PCM CODEC DSP56K
SCC ANALOG_JOY BLITTER IDE TT_CLK FDC_SPEED
memblock_reserve: [0x00000000-0x00439fff] paging_init+0x172/0x462
memblock_reserve: [0x0043a000-0x0043afff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0043b000-0x0043bfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0043c000-0x0043cfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0043d000-0x0043dfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0043e000-0x0043efff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0043f000-0x0043ffff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00440000-0x00440fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00441000-0x00441fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00442000-0x00442fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00443000-0x00443fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00444000-0x00444fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00445000-0x00445fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00446000-0x00446fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00447000-0x00447fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00448000-0x00448fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00449000-0x00449fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0044a000-0x0044afff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0044b000-0x0044bfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0044c000-0x0044cfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0044d000-0x0044dfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0044e000-0x0044efff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0044f000-0x0044ffff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00450000-0x00450fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00451000-0x00451fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00452000-0x00452fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00453000-0x00453fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00454000-0x00454fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00455000-0x00455fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00456000-0x00456fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00457000-0x00457fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00458000-0x00458fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00459000-0x00459fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0045a000-0x0045afff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0045b000-0x0045bfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0045c000-0x0045cfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0045d000-0x0045dfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0045e000-0x0045efff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0045f000-0x0045ffff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00460000-0x00460fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00461000-0x00461fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00462000-0x00462fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00463000-0x00463fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00464000-0x00464fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00465000-0x00465fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00466000-0x00466fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00467000-0x00467fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00468000-0x00468fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00469000-0x00469fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0046a000-0x0046afff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0046b000-0x0046bfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0046c000-0x0046cfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0046d000-0x0046dfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0046e000-0x0046efff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0046f000-0x0046ffff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00470000-0x00470fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00471000-0x00471fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00472000-0x00472fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00473000-0x00473fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00474000-0x00474fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00475000-0x00475fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00476000-0x00476fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00477000-0x00477fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00478000-0x00478fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x00479000-0x00479fff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0047a000-0x0047afff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0047b000-0x0047bfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0047c000-0x0047cfff] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x0047d000-0x0047dfff] __alloc_memory_core_early+0x86/0xb8
On node 0 totalpages: 3584
memblock_virt_alloc_try_nid_nopanic: 147456 bytes align=0x0 nid=0
from=0x0 max_addr=0x0 __wake_up_parent+0xc/0x24
memblock_reserve: [0x0047e000-0x004a1fff]
memblock_virt_alloc_internal+0xe4/0x156
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 3584 pages, LIFO batch:0
memblock_virt_alloc_try_nid_nopanic: 4 bytes align=0x0 nid=0 from=0x0
max_addr=0x0 0x4
memblock_reserve: [0x004a2000-0x004a2003]
memblock_virt_alloc_internal+0xe4/0x156
On node 1 totalpages: 65536
memblock_virt_alloc_try_nid_nopanic: 2359296 bytes align=0x0 nid=1
from=0x0 max_addr=0x0 netdev_lower_get_next+0x2/0x22
------------[ cut here ]------------
WARNING: CPU: 0 PID: 0 at mm/memblock.c:230
memblock_find_in_range_node+0x11c/0x1be
memblock: bottom-up allocation failed, memory hotunplug may be affected
Modules linked in:
CPU: 0 PID: 0 Comm: swapper Not tainted
4.18.0-rc3-atari-01343-gf2fb5f2e09a97a3c-dirty #7
Stack from 003c3e20:
        003c3e20 0039cf44 00023800 00433000 ffffffff 00001000 00240000 000238aa
        00378734 000000e6 004285ac 00000009 00000000 003c3e58 003787c0 003c3e74
        003c3ea4 004285ac 00378734 000000e6 003787c0 00000000 00000000 00000001
        00000000 00000010 00000000 00428490 003e3856 ffffffff ffffffff 003c3ed0
        00044620 003c3ee0 00417a10 00240000 00000010 00000000 00000000 00000001
        00000000 00000001 00240000 00000000 00000000 00000000 00001000 003e3856
Call Trace: [<00023800>] __warn+0xa8/0xc2
 [<00001000>] kernel_pg_dir+0x0/0x1000
 [<00240000>] netdev_lower_get_next+0x2/0x22
 [<000238aa>] warn_slowpath_fmt+0x2e/0x36
 [<004285ac>] memblock_find_in_range_node+0x11c/0x1be
 [<004285ac>] memblock_find_in_range_node+0x11c/0x1be
 [<00428490>] memblock_find_in_range_node+0x0/0x1be
 [<00044620>] vprintk_func+0x66/0x6e
 [<00417a10>] memblock_virt_alloc_internal+0xd0/0x156
 [<00240000>] netdev_lower_get_next+0x2/0x22
 [<00240000>] netdev_lower_get_next+0x2/0x22
 [<00001000>] kernel_pg_dir+0x0/0x1000
 [<00417b8c>] memblock_virt_alloc_try_nid_nopanic+0x58/0x7a
 [<00240000>] netdev_lower_get_next+0x2/0x22
 [<00001000>] kernel_pg_dir+0x0/0x1000
 [<00001000>] kernel_pg_dir+0x0/0x1000
 [<00010000>] EXPTBL+0x234/0x400
 [<00010000>] EXPTBL+0x234/0x400
 [<002f3644>] alloc_node_mem_map+0x4a/0x66
 [<00240000>] netdev_lower_get_next+0x2/0x22
 [<004155ca>] free_area_init_node+0xe2/0x29e
 [<00010000>] EXPTBL+0x234/0x400
 [<00411392>] paging_init+0x430/0x462
 [<00001000>] kernel_pg_dir+0x0/0x1000
 [<000427cc>] printk+0x0/0x1a
 [<00010000>] EXPTBL+0x234/0x400
 [<0041084c>] setup_arch+0x1b8/0x22c
 [<0040e020>] start_kernel+0x4a/0x40a
 [<0040d344>] _sinittext+0x344/0x9e8
random: get_random_bytes called from 0x3e75d2 with crng_init=0
---[ end trace 0000000000000000 ]---
memblock_reserve: [0x004a2010-0x006e200f]
memblock_virt_alloc_internal+0x116/0x156
  DMA zone: 576 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 65536 pages, LIFO batch:15
memblock_virt_alloc_try_nid_nopanic: 32 bytes align=0x0 nid=1 from=0x0
max_addr=0x0 0x20
memblock_reserve: [0x006e2010-0x006e202f]
memblock_virt_alloc_internal+0x116/0x156
NatFeats found (ARAnyM, 1.0)
memblock_reserve: [0x006e3000-0x007e2fff] __alloc_memory_core_early+0x86/0xb8
memblock_virt_alloc_try_nid: 118 bytes align=0x0 nid=-1 from=0x0
max_addr=0x0 0x76
memblock_reserve: [0x006e2030-0x006e20a5]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid: 118 bytes align=0x0 nid=-1 from=0x0
max_addr=0x0 0x76
memblock_reserve: [0x006e20b0-0x006e2125]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid: 118 bytes align=0x0 nid=-1 from=0x0
max_addr=0x0 0x76
memblock_reserve: [0x006e2130-0x006e21a5]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid_nopanic: 4096 bytes align=0x1000 nid=-1
from=0x0 max_addr=0x0 kernel_pg_dir+0x0/0x1000
memblock_reserve: [0x007e3000-0x007e3fff]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid_nopanic: 32768 bytes align=0x1000 nid=-1
from=0x0 max_addr=0x0 atari_keyboard_interrupt+0x94/0x2b2
memblock_reserve: [0x007e4000-0x007ebfff]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x4
memblock_reserve: [0x006e21b0-0x006e21b3]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x4
memblock_reserve: [0x006e21c0-0x006e21c3]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x4
memblock_reserve: [0x006e21d0-0x006e21d3]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 0x4
memblock_reserve: [0x006e21e0-0x006e21e3]
memblock_virt_alloc_internal+0xe4/0x156
pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
pcpu-alloc: [0] 0
memblock_virt_alloc_try_nid: 120 bytes align=0x0 nid=-1 from=0x0
max_addr=0x0 0x78
memblock_reserve: [0x006e21f0-0x006e2267]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid: 67 bytes align=0x0 nid=-1 from=0x0
max_addr=0x0 0x43
memblock_reserve: [0x006e2270-0x006e22b2]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid: 1024 bytes align=0x0 nid=-1 from=0x0
max_addr=0x0 0x400
memblock_reserve: [0x006e22c0-0x006e26bf]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid: 1028 bytes align=0x0 nid=-1 from=0x0
max_addr=0x0 0x404
memblock_reserve: [0x006e26c0-0x006e2ac3]
memblock_virt_alloc_internal+0xe4/0x156
memblock_virt_alloc_try_nid: 160 bytes align=0x0 nid=-1 from=0x0
max_addr=0x0 0xa0
memblock_reserve: [0x006e2ad0-0x006e2b6f]
memblock_virt_alloc_internal+0xe4/0x156
__memblock_free_early: [0x000000007e3000-0x000000007e3fff] 0x7e3000
Built 2 zonelists, mobility grouping on.  Total pages: 68512
Kernel command line: root=/dev/sda1 video=atafb:tthigh debug=par
console=tty0 initcall_blacklist=atari_scsi_driver_init
BOOT_IMAGE=vmlinux
blacklisting initcall atari_scsi_driver_init
memblock_reserve: [0x006e2b70-0x006e2b7b] __alloc_memory_core_early+0x86/0xb8
memblock_reserve: [0x006e2b80-0x006e2b96] __alloc_memory_core_early+0x86/0xb8
memblock_virt_alloc_try_nid_nopanic: 262144 bytes align=0x0 nid=-1
from=0x0 max_addr=0x0 sys_membarrier+0x12/0xc6
memblock_reserve: [0x007ec000-0x0082bfff]
memblock_virt_alloc_internal+0xe4/0x156
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
memblock_virt_alloc_try_nid_nopanic: 131072 bytes align=0x0 nid=-1
from=0x0 max_addr=0x0 _I_CALL_TOP+0x660/0x1900
memblock_reserve: [0x0082c000-0x0084bfff]
memblock_virt_alloc_internal+0xe4/0x156
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Sorting __ex_table...
Memory: 267988K/276480K available (3036K kernel code, 304K rwdata,
792K rodata, 152K init, 168K bss, 8492K reserved, 0K cma-reserved)

Do you have a clue?
Thanks again!

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
