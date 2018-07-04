Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB266B0005
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 22:02:59 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o7-v6so2176400pll.13
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 19:02:59 -0700 (PDT)
Received: from icp-osb-irony-out1.external.iinet.net.au (icp-osb-irony-out1.external.iinet.net.au. [203.59.1.210])
        by mx.google.com with ESMTP id r69-v6si2478096pfl.260.2018.07.03.19.02.56
        for <linux-mm@kvack.org>;
        Tue, 03 Jul 2018 19:02:57 -0700 (PDT)
Subject: Re: [PATCH 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
From: Greg Ungerer <gerg@linux-m68k.org>
References: <1530613795-6956-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530613795-6956-4-git-send-email-rppt@linux.vnet.ibm.com>
 <5388c6eb-2159-b103-51f9-2a211c54b4bc@linux-m68k.org>
Message-ID: <0614f397-d9c9-cc99-69bc-25b7d0361af4@linux-m68k.org>
Date: Wed, 4 Jul 2018 12:02:52 +1000
MIME-Version: 1.0
In-Reply-To: <5388c6eb-2159-b103-51f9-2a211c54b4bc@linux-m68k.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Sam Creasey <sammy@sammy.net>
Cc: Michal Hocko <mhocko@kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Mike,

On 04/07/18 11:39, Greg Ungerer wrote:
> On 03/07/18 20:29, Mike Rapoport wrote:
>> In m68k the physical memory is described by [memory_start, memory_end] for
>> !MMU variant and by m68k_memory array of memory ranges for the MMU version.
>> This information is directly used to register the physical memory with
>> memblock.
>>
>> The reserve_bootmem() calls are replaced with memblock_reserve() and the
>> bootmap bitmap allocation is simply dropped.
>>
>> Since the MMU variant creates early mappings only for the small part of the
>> memory we force bottom-up allocations in memblock because otherwise we will
>> attempt to access memory that not yet mapped
>>
>> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> This builds cleanly for me with a m5475_defconfig, but it fails
> to boot on real hardware. No console, no nothing on startup.
> I haven't debugged any further yet.
> 
> The M5475 is a ColdFire with MMU enabled target.

With some early serial debug trace I see:

Linux version 4.18.0-rc3-00003-g109f5e551b18-dirty (gerg@goober) (gcc version 5.4.0 (GCC)) #5 Wed Jul 4 12:00:03 AEST 2018
On node 0 totalpages: 4096
   DMA zone: 18 pages used for memmap
   DMA zone: 0 pages reserved
   DMA zone: 4096 pages, LIFO batch:0
pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
pcpu-alloc: [0] 0
Built 1 zonelists, mobility grouping off.  Total pages: 4078
Kernel command line: root=/dev/mtdblock0
Dentry cache hash table entries: 4096 (order: 1, 16384 bytes)
Inode-cache hash table entries: 2048 (order: 0, 8192 bytes)
Sorting __ex_table...
Memory: 3032K/32768K available (1489K kernel code, 96K rwdata, 240K rodata, 56K init, 77K bss, 29736K reserved, 0K cma-reserved)
SLUB: HWalign=16, Order=0-3, MinObjects=0, CPUs=1, Nodes=8
NR_IRQS: 256
clocksource: slt: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 14370379300 ns
Calibrating delay loop... 264.19 BogoMIPS (lpj=1320960)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 2048 (order: 0, 8192 bytes)
Mountpoint-cache hash table entries: 2048 (order: 0, 8192 bytes)
clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
ColdFire: PCI bus initialization...
Coldfire: PCI IO/config window mapped to 0xe0000000
PCI host bridge to bus 0000:00
pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffff]
pci_bus 0000:00: root bus resource [bus 00-ff]
pci 0000:00:14.0: [8086:1229] type 00 class 0x020000
pci 0000:00:14.0: reg 0x10: [mem 0x00000000-0x00000fff]
pci 0000:00:14.0: reg 0x14: [io  0x0000-0x003f]
pci 0000:00:14.0: reg 0x18: [mem 0x00000000-0x000fffff]
pci 0000:00:14.0: reg 0x30: [mem 0x00000000-0x000fffff pref]
pci 0000:00:14.0: supports D1 D2
pci 0000:00:14.0: PME# supported from D0 D1 D2 D3hot
pci 0000:00:14.0: BAR 2: assigned [mem 0xf0000000-0xf00fffff]
pci 0000:00:14.0: BAR 6: assigned [mem 0xf0100000-0xf01fffff pref]
pci 0000:00:14.0: BAR 0: assigned [mem 0xf0200000-0xf0200fff]
pci 0000:00:14.0: BAR 1: assigned [io  0x0400-0x043f]
vgaarb: loaded
clocksource: Switched to clocksource slt
PCI: CLS 32 bytes, default 16
workingset: timestamp_bits=27 max_order=9 bucket_order=0
kobject_add_internal failed for slab (error: -12 parent: kernel)
Cannot register slab subsystem.
romfs: ROMFS MTD (C) 2007 Red Hat, Inc.
io scheduler noop registered (default)
io scheduler mq-deadline registered
io scheduler kyber registered
kobject_add_internal failed for ptyp0 (error: -12 parent: tty)
Kernel panic - not syncing: Couldn't register pty driver
CPU: 0 PID: 1 Comm: swapper Not tainted 4.18.0-rc3-00003-g109f5e551b18-dirty #5
Stack from 00283ee4:
         00283ee4 001bc27a 000287ea 0019075c 00000019 001f5390 0018ba36 002c6a00
         002c6a80 0014ab82 00148816 001f2c2a 001b948c 00000000 001f2ad0 001f6ce8
         0002118e 00283f8c 000211b4 00000006 00000019 001f5390 0018ba36 00000007
         00000000 001f53cc 00305fb0 0002118e 0003df6a 00000000 00000006 00000006
         00305fb0 00305fb5 001ea7f6 001ba406 00305fb0 001d1c58 00000019 00000006
         00000006 00000000 0003df6a 001ea804 001f2ad0 00000000 001e5964 00282001
Call Trace:
         [<000287ea>] 0x000287ea
  [<0019075c>] 0x0019075c
  [<0018ba36>] 0x0018ba36
  [<0014ab82>] 0x0014ab82
  [<00148816>] 0x00148816

         [<001f2c2a>] 0x001f2c2a
  [<001f2ad0>] 0x001f2ad0
  [<0002118e>] 0x0002118e
  [<000211b4>] 0x000211b4
  [<0018ba36>] 0x0018ba36

         [<0002118e>] 0x0002118e
  [<0003df6a>] 0x0003df6a
  [<001ea7f6>] 0x001ea7f6
  [<0003df6a>] 0x0003df6a
  [<001ea804>] 0x001ea804

         [<001f2ad0>] 0x001f2ad0
  [<00190bae>] 0x00190bae
  [<00190bb6>] 0x00190bb6
  [<00190bae>] 0x00190bae
  [<00021aac>] 0x00021aac

---[ end Kernel panic - not syncing: Couldn't register pty driver ]---
random: fast init done

Regards
Greg



>> ---
>> A  arch/m68k/KconfigA A A A A A A A A A  |A  3 +++
>> A  arch/m68k/kernel/setup_mm.c | 14 ++++----------
>> A  arch/m68k/kernel/setup_no.c | 20 ++++----------------
>> A  arch/m68k/mm/init.cA A A A A A A A  |A  1 -
>> A  arch/m68k/mm/mcfmmu.cA A A A A A  | 11 +++++++----
>> A  arch/m68k/mm/motorola.cA A A A  | 35 +++++++++++------------------------
>> A  arch/m68k/sun3/config.cA A A A  |A  4 ----
>> A  7 files changed, 29 insertions(+), 59 deletions(-)
>>
>> diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
>> index 785612b..bd7f38a 100644
>> --- a/arch/m68k/Kconfig
>> +++ b/arch/m68k/Kconfig
>> @@ -24,6 +24,9 @@ config M68K
>> A A A A A  select MODULES_USE_ELF_RELA
>> A A A A A  select OLD_SIGSUSPEND3
>> A A A A A  select OLD_SIGACTION
>> +A A A  select HAVE_MEMBLOCK
>> +A A A  select ARCH_DISCARD_MEMBLOCK
>> +A A A  select NO_BOOTMEM
>> A  config CPU_BIG_ENDIAN
>> A A A A A  def_bool y
>> diff --git a/arch/m68k/kernel/setup_mm.c b/arch/m68k/kernel/setup_mm.c
>> index f35e3eb..6512955 100644
>> --- a/arch/m68k/kernel/setup_mm.c
>> +++ b/arch/m68k/kernel/setup_mm.c
>> @@ -21,6 +21,7 @@
>> A  #include <linux/string.h>
>> A  #include <linux/init.h>
>> A  #include <linux/bootmem.h>
>> +#include <linux/memblock.h>
>> A  #include <linux/proc_fs.h>
>> A  #include <linux/seq_file.h>
>> A  #include <linux/module.h>
>> @@ -165,6 +166,8 @@ static void __init m68k_parse_bootinfo(const struct bi_record *record)
>> A A A A A A A A A A A A A A A A A A A A A  be32_to_cpu(m->addr);
>> A A A A A A A A A A A A A A A A A  m68k_memory[m68k_num_memory].size =
>> A A A A A A A A A A A A A A A A A A A A A  be32_to_cpu(m->size);
>> +A A A A A A A A A A A A A A A  memblock_add(m68k_memory[m68k_num_memory].addr,
>> +A A A A A A A A A A A A A A A A A A A A A A A A  m68k_memory[m68k_num_memory].size);
>> A A A A A A A A A A A A A A A A A  m68k_num_memory++;
>> A A A A A A A A A A A A A  } else
>> A A A A A A A A A A A A A A A A A  pr_warn("%s: too many memory chunks\n",
>> @@ -224,10 +227,6 @@ static void __init m68k_parse_bootinfo(const struct bi_record *record)
>> A  void __init setup_arch(char **cmdline_p)
>> A  {
>> -#ifndef CONFIG_SUN3
>> -A A A  int i;
>> -#endif
>> -
>> A A A A A  /* The bootinfo is located right after the kernel */
>> A A A A A  if (!CPU_IS_COLDFIRE)
>> A A A A A A A A A  m68k_parse_bootinfo((const struct bi_record *)_end);
>> @@ -356,14 +355,9 @@ void __init setup_arch(char **cmdline_p)
>> A  #endif
>> A  #ifndef CONFIG_SUN3
>> -A A A  for (i = 1; i < m68k_num_memory; i++)
>> -A A A A A A A  free_bootmem_node(NODE_DATA(i), m68k_memory[i].addr,
>> -A A A A A A A A A A A A A A A A A  m68k_memory[i].size);
>> A  #ifdef CONFIG_BLK_DEV_INITRD
>> A A A A A  if (m68k_ramdisk.size) {
>> -A A A A A A A  reserve_bootmem_node(__virt_to_node(phys_to_virt(m68k_ramdisk.addr)),
>> -A A A A A A A A A A A A A A A A A A A A  m68k_ramdisk.addr, m68k_ramdisk.size,
>> -A A A A A A A A A A A A A A A A A A A A  BOOTMEM_DEFAULT);
>> +A A A A A A A  memblock_reserve(m68k_ramdisk.addr, m68k_ramdisk.size);
>> A A A A A A A A A  initrd_start = (unsigned long)phys_to_virt(m68k_ramdisk.addr);
>> A A A A A A A A A  initrd_end = initrd_start + m68k_ramdisk.size;
>> A A A A A A A A A  pr_info("initrd: %08lx - %08lx\n", initrd_start, initrd_end);
>> diff --git a/arch/m68k/kernel/setup_no.c b/arch/m68k/kernel/setup_no.c
>> index a98af10..3e8d87a 100644
>> --- a/arch/m68k/kernel/setup_no.c
>> +++ b/arch/m68k/kernel/setup_no.c
>> @@ -28,6 +28,7 @@
>> A  #include <linux/errno.h>
>> A  #include <linux/string.h>
>> A  #include <linux/bootmem.h>
>> +#include <linux/memblock.h>
>> A  #include <linux/seq_file.h>
>> A  #include <linux/init.h>
>> A  #include <linux/initrd.h>
>> @@ -86,8 +87,6 @@ void (*mach_power_off)(void);
>> A  void __init setup_arch(char **cmdline_p)
>> A  {
>> -A A A  int bootmap_size;
>> -
>> A A A A A  memory_start = PAGE_ALIGN(_ramstart);
>> A A A A A  memory_end = _ramend;
>> @@ -142,6 +141,8 @@ void __init setup_arch(char **cmdline_p)
>> A A A A A  pr_debug("MEMORY -> ROMFS=0x%p-0x%06lx MEM=0x%06lx-0x%06lx\n ",
>> A A A A A A A A A A  __bss_stop, memory_start, memory_start, memory_end);
>> +A A A  memblock_add(memory_start, memory_end - memory_start);
>> +
>> A A A A A  /* Keep a copy of command line */
>> A A A A A  *cmdline_p = &command_line[0];
>> A A A A A  memcpy(boot_command_line, command_line, COMMAND_LINE_SIZE);
>> @@ -158,23 +159,10 @@ void __init setup_arch(char **cmdline_p)
>> A A A A A  min_low_pfn = PFN_DOWN(memory_start);
>> A A A A A  max_pfn = max_low_pfn = PFN_DOWN(memory_end);
>> -A A A  bootmap_size = init_bootmem_node(
>> -A A A A A A A A A A A  NODE_DATA(0),
>> -A A A A A A A A A A A  min_low_pfn,A A A A A A A  /* map goes here */
>> -A A A A A A A A A A A  PFN_DOWN(PAGE_OFFSET),
>> -A A A A A A A A A A A  max_pfn);
>> -A A A  /*
>> -A A A A  * Free the usable memory, we have to make sure we do not free
>> -A A A A  * the bootmem bitmap so we then reserve it after freeing it :-)
>> -A A A A  */
>> -A A A  free_bootmem(memory_start, memory_end - memory_start);
>> -A A A  reserve_bootmem(memory_start, bootmap_size, BOOTMEM_DEFAULT);
>> -
>> A  #if defined(CONFIG_UBOOT) && defined(CONFIG_BLK_DEV_INITRD)
>> A A A A A  if ((initrd_start > 0) && (initrd_start < initrd_end) &&
>> A A A A A A A A A A A A A  (initrd_end < memory_end))
>> -A A A A A A A  reserve_bootmem(initrd_start, initrd_end - initrd_start,
>> -A A A A A A A A A A A A A A A A  BOOTMEM_DEFAULT);
>> +A A A A A A A  memblock_reserve(initrd_start, initrd_end - initrd_start);
>> A  #endif /* if defined(CONFIG_BLK_DEV_INITRD) */
>> A A A A A  /*
>> diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
>> index 8827b7f..38e2b27 100644
>> --- a/arch/m68k/mm/init.c
>> +++ b/arch/m68k/mm/init.c
>> @@ -71,7 +71,6 @@ void __init m68k_setup_node(int node)
>> A A A A A A A A A  pg_data_table[i] = pg_data_map + node;
>> A A A A A  }
>> A  #endif
>> -A A A  pg_data_map[node].bdata = bootmem_node_data + node;
>> A A A A A  node_set_online(node);
>> A  }
>> diff --git a/arch/m68k/mm/mcfmmu.c b/arch/m68k/mm/mcfmmu.c
>> index 2925d79..e9e60e1 100644
>> --- a/arch/m68k/mm/mcfmmu.c
>> +++ b/arch/m68k/mm/mcfmmu.c
>> @@ -14,6 +14,7 @@
>> A  #include <linux/init.h>
>> A  #include <linux/string.h>
>> A  #include <linux/bootmem.h>
>> +#include <linux/memblock.h>
>> A  #include <asm/setup.h>
>> A  #include <asm/page.h>
>> @@ -160,6 +161,8 @@ void __init cf_bootmem_alloc(void)
>> A A A A A  m68k_memory[0].addr = _rambase;
>> A A A A A  m68k_memory[0].size = _ramend - _rambase;
>> +A A A  memblock_add(m68k_memory[0].addr, m68k_memory[0].size);
>> +
>> A A A A A  /* compute total pages in system */
>> A A A A A  num_pages = PFN_DOWN(_ramend - _rambase);
>> @@ -170,14 +173,14 @@ void __init cf_bootmem_alloc(void)
>> A A A A A  max_pfn = max_low_pfn = PFN_DOWN(_ramend);
>> A A A A A  high_memory = (void *)_ramend;
>> +A A A  /* Reserve kernel text/data/bss */
>> +A A A  memblock_reserve(memstart, _ramend - memstart);
>> +
>> A A A A A  m68k_virt_to_node_shift = fls(_ramend - 1) - 6;
>> A A A A A  module_fixup(NULL, __start_fixup, __stop_fixup);
>> -A A A  /* setup bootmem data */
>> +A A A  /* setup node data */
>> A A A A A  m68k_setup_node(0);
>> -A A A  memstart += init_bootmem_node(NODE_DATA(0), start_pfn,
>> -A A A A A A A  min_low_pfn, max_low_pfn);
>> -A A A  free_bootmem_node(NODE_DATA(0), memstart, _ramend - memstart);
>> A  }
>> A  /*
>> diff --git a/arch/m68k/mm/motorola.c b/arch/m68k/mm/motorola.c
>> index e490ecc..4e17ecb 100644
>> --- a/arch/m68k/mm/motorola.c
>> +++ b/arch/m68k/mm/motorola.c
>> @@ -19,6 +19,7 @@
>> A  #include <linux/types.h>
>> A  #include <linux/init.h>
>> A  #include <linux/bootmem.h>
>> +#include <linux/memblock.h>
>> A  #include <linux/gfp.h>
>> A  #include <asm/setup.h>
>> @@ -208,7 +209,7 @@ void __init paging_init(void)
>> A  {
>> A A A A A  unsigned long zones_size[MAX_NR_ZONES] = { 0, };
>> A A A A A  unsigned long min_addr, max_addr;
>> -A A A  unsigned long addr, size, end;
>> +A A A  unsigned long addr;
>> A A A A A  int i;
>> A  #ifdef DEBUG
>> @@ -253,34 +254,20 @@ void __init paging_init(void)
>> A A A A A  min_low_pfn = availmem >> PAGE_SHIFT;
>> A A A A A  max_pfn = max_low_pfn = max_addr >> PAGE_SHIFT;
>> -A A A  for (i = 0; i < m68k_num_memory; i++) {
>> -A A A A A A A  addr = m68k_memory[i].addr;
>> -A A A A A A A  end = addr + m68k_memory[i].size;
>> -A A A A A A A  m68k_setup_node(i);
>> -A A A A A A A  availmem = PAGE_ALIGN(availmem);
>> -A A A A A A A  availmem += init_bootmem_node(NODE_DATA(i),
>> -A A A A A A A A A A A A A A A A A A A A A A A A A  availmem >> PAGE_SHIFT,
>> -A A A A A A A A A A A A A A A A A A A A A A A A A  addr >> PAGE_SHIFT,
>> -A A A A A A A A A A A A A A A A A A A A A A A A A  end >> PAGE_SHIFT);
>> -A A A  }
>> +A A A  /* Reserve kernel text/data/bss and the memory allocated in head.S */
>> +A A A  memblock_reserve(m68k_memory[0].addr, availmem - m68k_memory[0].addr);
>> A A A A A  /*
>> A A A A A A  * Map the physical memory available into the kernel virtual
>> -A A A A  * address space. First initialize the bootmem allocator with
>> -A A A A  * the memory we already mapped, so map_node() has something
>> -A A A A  * to allocate.
>> +A A A A  * address space. Make sure memblock will not try to allocate
>> +A A A A  * pages beyond the memory we already mapped in head.S
>> A A A A A A  */
>> -A A A  addr = m68k_memory[0].addr;
>> -A A A  size = m68k_memory[0].size;
>> -A A A  free_bootmem_node(NODE_DATA(0), availmem,
>> -A A A A A A A A A A A A A  min(m68k_init_mapped_size, size) - (availmem - addr));
>> -A A A  map_node(0);
>> -A A A  if (size > m68k_init_mapped_size)
>> -A A A A A A A  free_bootmem_node(NODE_DATA(0), addr + m68k_init_mapped_size,
>> -A A A A A A A A A A A A A A A A A  size - m68k_init_mapped_size);
>> -
>> -A A A  for (i = 1; i < m68k_num_memory; i++)
>> +A A A  memblock_set_bottom_up(true);
>> +
>> +A A A  for (i = 0; i < m68k_num_memory; i++) {
>> +A A A A A A A  m68k_setup_node(i);
>> A A A A A A A A A  map_node(i);
>> +A A A  }
>> A A A A A  flush_tlb_all();
>> diff --git a/arch/m68k/sun3/config.c b/arch/m68k/sun3/config.c
>> index 1d28d38..79a2bb8 100644
>> --- a/arch/m68k/sun3/config.c
>> +++ b/arch/m68k/sun3/config.c
>> @@ -123,10 +123,6 @@ static void __init sun3_bootmem_alloc(unsigned long memory_start,
>> A A A A A  availmem = memory_start;
>> A A A A A  m68k_setup_node(0);
>> -A A A  availmem += init_bootmem(start_page, num_pages);
>> -A A A  availmem = (availmem + (PAGE_SIZE-1)) & PAGE_MASK;
>> -
>> -A A A  free_bootmem(__pa(availmem), memory_end - (availmem));
>> A  }
>>
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-m68k" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info atA  http://vger.kernel.org/majordomo-info.html
> 
