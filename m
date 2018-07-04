Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C959D6B000A
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 00:22:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m18-v6so1697305eds.0
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 21:22:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p4-v6si2536016eda.101.2018.07.03.21.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 21:22:32 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w644JLJK010613
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 00:22:30 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0k43r6b4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 00:22:30 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 05:22:28 +0100
Date: Wed, 4 Jul 2018 07:22:22 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
References: <1530613795-6956-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530613795-6956-4-git-send-email-rppt@linux.vnet.ibm.com>
 <5388c6eb-2159-b103-51f9-2a211c54b4bc@linux-m68k.org>
 <0614f397-d9c9-cc99-69bc-25b7d0361af4@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0614f397-d9c9-cc99-69bc-25b7d0361af4@linux-m68k.org>
Message-Id: <20180704042221.GG4809@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Ungerer <gerg@linux-m68k.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, Michal Hocko <mhocko@kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 04, 2018 at 12:02:52PM +1000, Greg Ungerer wrote:
> Hi Mike,
> 
> On 04/07/18 11:39, Greg Ungerer wrote:
> >On 03/07/18 20:29, Mike Rapoport wrote:
> >>In m68k the physical memory is described by [memory_start, memory_end] for
> >>!MMU variant and by m68k_memory array of memory ranges for the MMU version.
> >>This information is directly used to register the physical memory with
> >>memblock.
> >>
> >>The reserve_bootmem() calls are replaced with memblock_reserve() and the
> >>bootmap bitmap allocation is simply dropped.
> >>
> >>Since the MMU variant creates early mappings only for the small part of the
> >>memory we force bottom-up allocations in memblock because otherwise we will
> >>attempt to access memory that not yet mapped
> >>
> >>Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> >
> >This builds cleanly for me with a m5475_defconfig, but it fails
> >to boot on real hardware. No console, no nothing on startup.
> >I haven't debugged any further yet.
> >
> >The M5475 is a ColdFire with MMU enabled target.
> 
> With some early serial debug trace I see:
> 
> Linux version 4.18.0-rc3-00003-g109f5e551b18-dirty (gerg@goober) (gcc version 5.4.0 (GCC)) #5 Wed Jul 4 12:00:03 AEST 2018
> On node 0 totalpages: 4096
>   DMA zone: 18 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 4096 pages, LIFO batch:0
> pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
> pcpu-alloc: [0] 0
> Built 1 zonelists, mobility grouping off.  Total pages: 4078
> Kernel command line: root=/dev/mtdblock0
> Dentry cache hash table entries: 4096 (order: 1, 16384 bytes)
> Inode-cache hash table entries: 2048 (order: 0, 8192 bytes)
> Sorting __ex_table...
> Memory: 3032K/32768K available (1489K kernel code, 96K rwdata, 240K rodata, 56K init, 77K bss, 29736K reserved, 0K cma-reserved)
                                                                                                 ^^^^^^
It seems I was over enthusiastic when I reserved the memory for the kernel.
Can you please try with the below patch:

diff --git a/arch/m68k/mm/mcfmmu.c b/arch/m68k/mm/mcfmmu.c
index e9e60e1..18c7bf6 100644
--- a/arch/m68k/mm/mcfmmu.c
+++ b/arch/m68k/mm/mcfmmu.c
@@ -174,7 +174,7 @@ void __init cf_bootmem_alloc(void)
 	high_memory = (void *)_ramend;
 
 	/* Reserve kernel text/data/bss */
-	memblock_reserve(memstart, _ramend - memstart);
+	memblock_reserve(memstart, memstart - _rambase);
 
 	m68k_virt_to_node_shift = fls(_ramend - 1) - 6;
 	module_fixup(NULL, __start_fixup, __stop_fixup);
diff --git a/mm/memblock.c b/mm/memblock.c
index 03d48d8..98661be 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -54,7 +54,7 @@ struct memblock memblock __initdata_memblock = {
 	.current_limit		= MEMBLOCK_ALLOC_ANYWHERE,
 };
 
-int memblock_debug __initdata_memblock;
+int memblock_debug __initdata_memblock = 1;
 static bool system_has_some_mirror __initdata_memblock = false;
 static int memblock_can_resize __initdata_memblock;
 static int memblock_memory_in_slab __initdata_memblock = 0;


The memblock hunk is needed to see early memblock debug messages as all the
setup happens before parsing of the command line.

> SLUB: HWalign=16, Order=0-3, MinObjects=0, CPUs=1, Nodes=8
> NR_IRQS: 256
> clocksource: slt: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 14370379300 ns
> Calibrating delay loop... 264.19 BogoMIPS (lpj=1320960)
> pid_max: default: 32768 minimum: 301
> Mount-cache hash table entries: 2048 (order: 0, 8192 bytes)
> Mountpoint-cache hash table entries: 2048 (order: 0, 8192 bytes)
> clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
> ColdFire: PCI bus initialization...
> Coldfire: PCI IO/config window mapped to 0xe0000000
> PCI host bridge to bus 0000:00
> pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
> pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffff]
> pci_bus 0000:00: root bus resource [bus 00-ff]
> pci 0000:00:14.0: [8086:1229] type 00 class 0x020000
> pci 0000:00:14.0: reg 0x10: [mem 0x00000000-0x00000fff]
> pci 0000:00:14.0: reg 0x14: [io  0x0000-0x003f]
> pci 0000:00:14.0: reg 0x18: [mem 0x00000000-0x000fffff]
> pci 0000:00:14.0: reg 0x30: [mem 0x00000000-0x000fffff pref]
> pci 0000:00:14.0: supports D1 D2
> pci 0000:00:14.0: PME# supported from D0 D1 D2 D3hot
> pci 0000:00:14.0: BAR 2: assigned [mem 0xf0000000-0xf00fffff]
> pci 0000:00:14.0: BAR 6: assigned [mem 0xf0100000-0xf01fffff pref]
> pci 0000:00:14.0: BAR 0: assigned [mem 0xf0200000-0xf0200fff]
> pci 0000:00:14.0: BAR 1: assigned [io  0x0400-0x043f]
> vgaarb: loaded
> clocksource: Switched to clocksource slt
> PCI: CLS 32 bytes, default 16
> workingset: timestamp_bits=27 max_order=9 bucket_order=0
> kobject_add_internal failed for slab (error: -12 parent: kernel)
> Cannot register slab subsystem.
> romfs: ROMFS MTD (C) 2007 Red Hat, Inc.
> io scheduler noop registered (default)
> io scheduler mq-deadline registered
> io scheduler kyber registered
> kobject_add_internal failed for ptyp0 (error: -12 parent: tty)
> Kernel panic - not syncing: Couldn't register pty driver
> CPU: 0 PID: 1 Comm: swapper Not tainted 4.18.0-rc3-00003-g109f5e551b18-dirty #5
> Stack from 00283ee4:
>         00283ee4 001bc27a 000287ea 0019075c 00000019 001f5390 0018ba36 002c6a00
>         002c6a80 0014ab82 00148816 001f2c2a 001b948c 00000000 001f2ad0 001f6ce8
>         0002118e 00283f8c 000211b4 00000006 00000019 001f5390 0018ba36 00000007
>         00000000 001f53cc 00305fb0 0002118e 0003df6a 00000000 00000006 00000006
>         00305fb0 00305fb5 001ea7f6 001ba406 00305fb0 001d1c58 00000019 00000006
>         00000006 00000000 0003df6a 001ea804 001f2ad0 00000000 001e5964 00282001
> Call Trace:
>         [<000287ea>] 0x000287ea
>  [<0019075c>] 0x0019075c
>  [<0018ba36>] 0x0018ba36
>  [<0014ab82>] 0x0014ab82
>  [<00148816>] 0x00148816
> 
>         [<001f2c2a>] 0x001f2c2a
>  [<001f2ad0>] 0x001f2ad0
>  [<0002118e>] 0x0002118e
>  [<000211b4>] 0x000211b4
>  [<0018ba36>] 0x0018ba36
> 
>         [<0002118e>] 0x0002118e
>  [<0003df6a>] 0x0003df6a
>  [<001ea7f6>] 0x001ea7f6
>  [<0003df6a>] 0x0003df6a
>  [<001ea804>] 0x001ea804
> 
>         [<001f2ad0>] 0x001f2ad0
>  [<00190bae>] 0x00190bae
>  [<00190bb6>] 0x00190bb6
>  [<00190bae>] 0x00190bae
>  [<00021aac>] 0x00021aac
> 
> ---[ end Kernel panic - not syncing: Couldn't register pty driver ]---
> random: fast init done
> 
> Regards
> Greg
> 
> 
> 
> >>---
> >>  arch/m68k/Kconfig           |  3 +++
> >>  arch/m68k/kernel/setup_mm.c | 14 ++++----------
> >>  arch/m68k/kernel/setup_no.c | 20 ++++----------------
> >>  arch/m68k/mm/init.c         |  1 -
> >>  arch/m68k/mm/mcfmmu.c       | 11 +++++++----
> >>  arch/m68k/mm/motorola.c     | 35 +++++++++++------------------------
> >>  arch/m68k/sun3/config.c     |  4 ----
> >>  7 files changed, 29 insertions(+), 59 deletions(-)
> >>
> >>diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
> >>index 785612b..bd7f38a 100644
> >>--- a/arch/m68k/Kconfig
> >>+++ b/arch/m68k/Kconfig
> >>@@ -24,6 +24,9 @@ config M68K
> >>      select MODULES_USE_ELF_RELA
> >>      select OLD_SIGSUSPEND3
> >>      select OLD_SIGACTION
> >>+    select HAVE_MEMBLOCK
> >>+    select ARCH_DISCARD_MEMBLOCK
> >>+    select NO_BOOTMEM
> >>  config CPU_BIG_ENDIAN
> >>      def_bool y
> >>diff --git a/arch/m68k/kernel/setup_mm.c b/arch/m68k/kernel/setup_mm.c
> >>index f35e3eb..6512955 100644
> >>--- a/arch/m68k/kernel/setup_mm.c
> >>+++ b/arch/m68k/kernel/setup_mm.c
> >>@@ -21,6 +21,7 @@
> >>  #include <linux/string.h>
> >>  #include <linux/init.h>
> >>  #include <linux/bootmem.h>
> >>+#include <linux/memblock.h>
> >>  #include <linux/proc_fs.h>
> >>  #include <linux/seq_file.h>
> >>  #include <linux/module.h>
> >>@@ -165,6 +166,8 @@ static void __init m68k_parse_bootinfo(const struct bi_record *record)
> >>                      be32_to_cpu(m->addr);
> >>                  m68k_memory[m68k_num_memory].size =
> >>                      be32_to_cpu(m->size);
> >>+                memblock_add(m68k_memory[m68k_num_memory].addr,
> >>+                         m68k_memory[m68k_num_memory].size);
> >>                  m68k_num_memory++;
> >>              } else
> >>                  pr_warn("%s: too many memory chunks\n",
> >>@@ -224,10 +227,6 @@ static void __init m68k_parse_bootinfo(const struct bi_record *record)
> >>  void __init setup_arch(char **cmdline_p)
> >>  {
> >>-#ifndef CONFIG_SUN3
> >>-    int i;
> >>-#endif
> >>-
> >>      /* The bootinfo is located right after the kernel */
> >>      if (!CPU_IS_COLDFIRE)
> >>          m68k_parse_bootinfo((const struct bi_record *)_end);
> >>@@ -356,14 +355,9 @@ void __init setup_arch(char **cmdline_p)
> >>  #endif
> >>  #ifndef CONFIG_SUN3
> >>-    for (i = 1; i < m68k_num_memory; i++)
> >>-        free_bootmem_node(NODE_DATA(i), m68k_memory[i].addr,
> >>-                  m68k_memory[i].size);
> >>  #ifdef CONFIG_BLK_DEV_INITRD
> >>      if (m68k_ramdisk.size) {
> >>-        reserve_bootmem_node(__virt_to_node(phys_to_virt(m68k_ramdisk.addr)),
> >>-                     m68k_ramdisk.addr, m68k_ramdisk.size,
> >>-                     BOOTMEM_DEFAULT);
> >>+        memblock_reserve(m68k_ramdisk.addr, m68k_ramdisk.size);
> >>          initrd_start = (unsigned long)phys_to_virt(m68k_ramdisk.addr);
> >>          initrd_end = initrd_start + m68k_ramdisk.size;
> >>          pr_info("initrd: %08lx - %08lx\n", initrd_start, initrd_end);
> >>diff --git a/arch/m68k/kernel/setup_no.c b/arch/m68k/kernel/setup_no.c
> >>index a98af10..3e8d87a 100644
> >>--- a/arch/m68k/kernel/setup_no.c
> >>+++ b/arch/m68k/kernel/setup_no.c
> >>@@ -28,6 +28,7 @@
> >>  #include <linux/errno.h>
> >>  #include <linux/string.h>
> >>  #include <linux/bootmem.h>
> >>+#include <linux/memblock.h>
> >>  #include <linux/seq_file.h>
> >>  #include <linux/init.h>
> >>  #include <linux/initrd.h>
> >>@@ -86,8 +87,6 @@ void (*mach_power_off)(void);
> >>  void __init setup_arch(char **cmdline_p)
> >>  {
> >>-    int bootmap_size;
> >>-
> >>      memory_start = PAGE_ALIGN(_ramstart);
> >>      memory_end = _ramend;
> >>@@ -142,6 +141,8 @@ void __init setup_arch(char **cmdline_p)
> >>      pr_debug("MEMORY -> ROMFS=0x%p-0x%06lx MEM=0x%06lx-0x%06lx\n ",
> >>           __bss_stop, memory_start, memory_start, memory_end);
> >>+    memblock_add(memory_start, memory_end - memory_start);
> >>+
> >>      /* Keep a copy of command line */
> >>      *cmdline_p = &command_line[0];
> >>      memcpy(boot_command_line, command_line, COMMAND_LINE_SIZE);
> >>@@ -158,23 +159,10 @@ void __init setup_arch(char **cmdline_p)
> >>      min_low_pfn = PFN_DOWN(memory_start);
> >>      max_pfn = max_low_pfn = PFN_DOWN(memory_end);
> >>-    bootmap_size = init_bootmem_node(
> >>-            NODE_DATA(0),
> >>-            min_low_pfn,        /* map goes here */
> >>-            PFN_DOWN(PAGE_OFFSET),
> >>-            max_pfn);
> >>-    /*
> >>-     * Free the usable memory, we have to make sure we do not free
> >>-     * the bootmem bitmap so we then reserve it after freeing it :-)
> >>-     */
> >>-    free_bootmem(memory_start, memory_end - memory_start);
> >>-    reserve_bootmem(memory_start, bootmap_size, BOOTMEM_DEFAULT);
> >>-
> >>  #if defined(CONFIG_UBOOT) && defined(CONFIG_BLK_DEV_INITRD)
> >>      if ((initrd_start > 0) && (initrd_start < initrd_end) &&
> >>              (initrd_end < memory_end))
> >>-        reserve_bootmem(initrd_start, initrd_end - initrd_start,
> >>-                 BOOTMEM_DEFAULT);
> >>+        memblock_reserve(initrd_start, initrd_end - initrd_start);
> >>  #endif /* if defined(CONFIG_BLK_DEV_INITRD) */
> >>      /*
> >>diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
> >>index 8827b7f..38e2b27 100644
> >>--- a/arch/m68k/mm/init.c
> >>+++ b/arch/m68k/mm/init.c
> >>@@ -71,7 +71,6 @@ void __init m68k_setup_node(int node)
> >>          pg_data_table[i] = pg_data_map + node;
> >>      }
> >>  #endif
> >>-    pg_data_map[node].bdata = bootmem_node_data + node;
> >>      node_set_online(node);
> >>  }
> >>diff --git a/arch/m68k/mm/mcfmmu.c b/arch/m68k/mm/mcfmmu.c
> >>index 2925d79..e9e60e1 100644
> >>--- a/arch/m68k/mm/mcfmmu.c
> >>+++ b/arch/m68k/mm/mcfmmu.c
> >>@@ -14,6 +14,7 @@
> >>  #include <linux/init.h>
> >>  #include <linux/string.h>
> >>  #include <linux/bootmem.h>
> >>+#include <linux/memblock.h>
> >>  #include <asm/setup.h>
> >>  #include <asm/page.h>
> >>@@ -160,6 +161,8 @@ void __init cf_bootmem_alloc(void)
> >>      m68k_memory[0].addr = _rambase;
> >>      m68k_memory[0].size = _ramend - _rambase;
> >>+    memblock_add(m68k_memory[0].addr, m68k_memory[0].size);
> >>+
> >>      /* compute total pages in system */
> >>      num_pages = PFN_DOWN(_ramend - _rambase);
> >>@@ -170,14 +173,14 @@ void __init cf_bootmem_alloc(void)
> >>      max_pfn = max_low_pfn = PFN_DOWN(_ramend);
> >>      high_memory = (void *)_ramend;
> >>+    /* Reserve kernel text/data/bss */
> >>+    memblock_reserve(memstart, _ramend - memstart);
> >>+
> >>      m68k_virt_to_node_shift = fls(_ramend - 1) - 6;
> >>      module_fixup(NULL, __start_fixup, __stop_fixup);
> >>-    /* setup bootmem data */
> >>+    /* setup node data */
> >>      m68k_setup_node(0);
> >>-    memstart += init_bootmem_node(NODE_DATA(0), start_pfn,
> >>-        min_low_pfn, max_low_pfn);
> >>-    free_bootmem_node(NODE_DATA(0), memstart, _ramend - memstart);
> >>  }
> >>  /*
> >>diff --git a/arch/m68k/mm/motorola.c b/arch/m68k/mm/motorola.c
> >>index e490ecc..4e17ecb 100644
> >>--- a/arch/m68k/mm/motorola.c
> >>+++ b/arch/m68k/mm/motorola.c
> >>@@ -19,6 +19,7 @@
> >>  #include <linux/types.h>
> >>  #include <linux/init.h>
> >>  #include <linux/bootmem.h>
> >>+#include <linux/memblock.h>
> >>  #include <linux/gfp.h>
> >>  #include <asm/setup.h>
> >>@@ -208,7 +209,7 @@ void __init paging_init(void)
> >>  {
> >>      unsigned long zones_size[MAX_NR_ZONES] = { 0, };
> >>      unsigned long min_addr, max_addr;
> >>-    unsigned long addr, size, end;
> >>+    unsigned long addr;
> >>      int i;
> >>  #ifdef DEBUG
> >>@@ -253,34 +254,20 @@ void __init paging_init(void)
> >>      min_low_pfn = availmem >> PAGE_SHIFT;
> >>      max_pfn = max_low_pfn = max_addr >> PAGE_SHIFT;
> >>-    for (i = 0; i < m68k_num_memory; i++) {
> >>-        addr = m68k_memory[i].addr;
> >>-        end = addr + m68k_memory[i].size;
> >>-        m68k_setup_node(i);
> >>-        availmem = PAGE_ALIGN(availmem);
> >>-        availmem += init_bootmem_node(NODE_DATA(i),
> >>-                          availmem >> PAGE_SHIFT,
> >>-                          addr >> PAGE_SHIFT,
> >>-                          end >> PAGE_SHIFT);
> >>-    }
> >>+    /* Reserve kernel text/data/bss and the memory allocated in head.S */
> >>+    memblock_reserve(m68k_memory[0].addr, availmem - m68k_memory[0].addr);
> >>      /*
> >>       * Map the physical memory available into the kernel virtual
> >>-     * address space. First initialize the bootmem allocator with
> >>-     * the memory we already mapped, so map_node() has something
> >>-     * to allocate.
> >>+     * address space. Make sure memblock will not try to allocate
> >>+     * pages beyond the memory we already mapped in head.S
> >>       */
> >>-    addr = m68k_memory[0].addr;
> >>-    size = m68k_memory[0].size;
> >>-    free_bootmem_node(NODE_DATA(0), availmem,
> >>-              min(m68k_init_mapped_size, size) - (availmem - addr));
> >>-    map_node(0);
> >>-    if (size > m68k_init_mapped_size)
> >>-        free_bootmem_node(NODE_DATA(0), addr + m68k_init_mapped_size,
> >>-                  size - m68k_init_mapped_size);
> >>-
> >>-    for (i = 1; i < m68k_num_memory; i++)
> >>+    memblock_set_bottom_up(true);
> >>+
> >>+    for (i = 0; i < m68k_num_memory; i++) {
> >>+        m68k_setup_node(i);
> >>          map_node(i);
> >>+    }
> >>      flush_tlb_all();
> >>diff --git a/arch/m68k/sun3/config.c b/arch/m68k/sun3/config.c
> >>index 1d28d38..79a2bb8 100644
> >>--- a/arch/m68k/sun3/config.c
> >>+++ b/arch/m68k/sun3/config.c
> >>@@ -123,10 +123,6 @@ static void __init sun3_bootmem_alloc(unsigned long memory_start,
> >>      availmem = memory_start;
> >>      m68k_setup_node(0);
> >>-    availmem += init_bootmem(start_page, num_pages);
> >>-    availmem = (availmem + (PAGE_SIZE-1)) & PAGE_MASK;
> >>-
> >>-    free_bootmem(__pa(availmem), memory_end - (availmem));
> >>  }
> >>
> >-- 
> >To unsubscribe from this list: send the line "unsubscribe linux-m68k" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 

-- 
Sincerely yours,
Mike.
