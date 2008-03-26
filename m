Message-Id: <20080326014137.934171000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:41:37 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 0/2] NR_CPUS: increase maximum NR_CPUS to 4096
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Increases the limit of NR_CPUS to 4096 and introduces a
boolean called "MAXSMP" which when set (e.g. "allyesconfig")
will set NR_CPUS = 4096 and NODES_SHIFT = 9 (512).

I've been running this config (4k NR_CPUS, 512 Max Nodes)
on an AMD box with 2 dual-cores and 4gb memory.  I've also
successfully booted it in a simulated 2cpus/1Gb environment.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Signed-off-by: Mike Travis <travis@sgi.com>
---

Memory usage effects from upping NR_CPUS to 4096 and MAX_NUMANODES to 512.

255-akpm2: akpm2 config with NR_CPUS=255  / NUMA_NODE_SHIFT=6
4k-akpm2:  akpm2 config with NR_CPUS=4096 / NUMA_NODE_SHIFT=9

====== Data (-l 1000)
    1 - 255-akpm2
    2 - 4k-akpm2

      .1.       .2.    ..final..
  1114112  +3899392 5013504  +350%  irq_desc(.data.cacheline_aligned)
   313344  +4177920 4491264 +1333%  irq_cfg(.data.read_mostly)
    76800   +537600  614400  +700%  early_node_map(.init.data)
    32640   +491648  524288 +1506%  boot_pageset(.bss)
    32640   +491648  524288 +1506%  boot_cpu_pda(.data.cacheline_aligned)
    23040   +161280  184320  +700%  initkmem_list3(.init.data)
     5632    +39424   45056  +700%  node_devices(.bss)
     4096    +28672   32768  +700%  plat_node_bdata(.bss)
     2656    +34312   36968 +1291%  cache_cache(.data)
     2048    +14336   16384  +700%  rio_devs(.init.data)
     2048   +260096  262144 +12700%  node_to_cpumask_map(.data.read_mostly)
     2040    +30728   32768 +1506%  centrino_model(.bss)
     2040    +30728   32768 +1506%  centrino_cpu(.bss)
     2040    +30728   32768 +1506%  _cpu_pda(.data.read_mostly)
     1024     +1024    2048  +100%  pxm_to_node_map(.data)
     1024     +7168    8192  +700%  nodes_add(.bss)
     1024     +7168    8192  +700%  nodes(.init.data)
     1024     +7168    8192  +700%  hugepage_freelists(.bss)
     1020    +15364   16384 +1506%  x86_cpu_to_node_map_init(.data)
     1020    +15364   16384 +1506%  cpu_set_freq(.bss)
     1020    +15364   16384 +1506%  cpu_min_freq(.bss)
     1020    +15364   16384 +1506%  cpu_max_freq(.bss)
     1020    +15364   16384 +1506%  cpu_is_managed(.bss)
     1020    +15364   16384 +1506%  cpu_cur_freq(.bss)
      512     +3584    4096  +700%  zone_movable_pfn(.init.data)
      512     +3584    4096  +700%  scal_devs(.init.data)
      512     +3584    4096  +700%  node_data(.data.read_mostly)
      510     +7682    8192 +1506%  x86_cpu_to_apicid_init(.init.data)
      510     +7682    8192 +1506%  x86_bios_cpu_apicid_init(.init.data)
        0     +4096    4096      .  tvec_base_done(.data)
        0     +2048    2048      .  surplus_huge_pages_node(.bss)
        0     +2048    2048      .  nr_huge_pages_node(.bss)
        0     +2048    2048      .  node_to_pxm_map(.data)
        0     +2048    2048      .  node_order(.bss)
        0     +2048    2048      .  node_load(.bss)
        0     +2048    2048      .  free_huge_pages_node(.bss)
        0     +2048    2048      .  fake_node_to_pxm_map(.init.data)
        0     +1552    1552      .  def_root_domain(.bss)

====== Sections (-l 500)
    1 - 255-akpm2
    2 - 4k-akpm2

       .1.        .2.    ..final..
  63092788  +10579589 73672377   +16%  Total
  41514099     +93823 41607922    <1%  .debug_info
   6648945      -2268  6646677    <1%  .debug_loc
   3365341      +7483  3372824    <1%  .text
   2631073      -1672  2629401    <1%  .debug_line
   1320219     +31557  1351776    +2%  .debug_abbrev
   1149568   +4391040  5540608  +381%  .data.cacheline_aligned
   1106192      -4784  1101408    <1%  .debug_ranges
    732736    +728832  1461568   +99%  .bss
    329672   +4474992  4804664 +1357%  .data.read_mostly
    285576    +100320   385896   +35%  .data
    173664    +751936   925600  +432%  .init.data
     40824      +7808    48632   +19%  .data.percpu

====== Text/Data ()
    1 - 255-akpm2
    2 - 4k-akpm2

      .1.       .2.    ..final..
  3364864     +8192   3373056    <1%  TextSize
  1552384   +100352   1652736    +6%  DataSize
   733184   +729088   1462272   +99%  BssSize
   393216   +757760   1150976  +192%  InitSize
    40960     +8192     49152   +20%  PerCPU
  1529856  +8869888  10399744  +579%  OtherSize
  7614464  +10473472 18087936  +137%  Totals

====== PerCPU ()
    1 - 255-akpm2
    2 - 4k-akpm2

    .1.    .2.    ..final..
  18432  -2048 16384   -11%  kstat
  10240  -2048  8192   -20%  init_tss
   2048  -2048     .  -100%  fdtable_defer_list
      0  +2048  2048      .  node_domains
      0  +2048  2048      .  lru_add_active_pvecs
      0  +2048  2048      .  cpuidle_devices
      0  +2048  2048      .  cpu_mask
      0  +2048  2048      .  cpu_info
      0  +2048  2048      .  cpu_core_map
      0  +2048  2048      .  core_domains
  30720  +8192 38912   +26%  Totals

====== Stack (-l 1000)
    1 - 255-akpm2
    2 - 4k-akpm2

  .1.    .2.    ..final..
    0  +4216 4216      .  show_schedstat
    0  +2744 2744      .  build_sched_domains
    0  +2152 2152      .  centrino_target
    0  +1640 1640      .  setup_IO_APIC
    0  +1592 1592      .  move_task_off_dead_cpu
    0  +1576 1576      .  setup_IO_APIC_irq
    0  +1560 1560      .  tick_notify
    0  +1560 1560      .  __assign_irq_vector
    0  +1552 1552      .  arch_setup_msi_irq
    0  +1552 1552      .  arch_setup_ht_irq
    0  +1544 1544      .  tick_do_periodic_broadcast
    0  +1544 1544      .  irq_affinity_write_proc
    0  +1144 1144      .  threshold_create_device
    0  +1112 1112      .  sched_balance_self
    0  +1064 1064      .  _cpu_down
    0  +1056 1056      .  __smp_call_function_mask
    0  +1048 1048      .  store_threshold_limit
    0  +1048 1048      .  set_ioapic_affinity_irq
    0  +1048 1048      .  acpi_processor_set_throttling
    0  +1048 1048      .  acpi_map_lsapic
    0  +1040 1040      .  store_interrupt_enable
    0  +1040 1040      .  set_msi_irq_affinity
    0  +1040 1040      .  set_ht_irq_affinity
    0  +1032 1032      .  store_error_count
    0  +1032 1032      .  show_error_count
    0  +1032 1032      .  setup_ioapic_dest
    0  +1032 1032      .  sched_setaffinity
    0  +1032 1032      .  physflat_send_IPI_allbutself
    0  +1032 1032      .  native_flush_tlb_others
    0  +1032 1032      .  move_masked_irq
    0  +1032 1032      .  flat_send_IPI_allbutself
    0  +1024 1024      .  pci_bus_show_cpuaffinity
    0  +1024 1024      .  machine_crash_shutdown
    0  +1024 1024      .  local_cpus_show
    0  +1024 1024      .  irq_complete_move
    0  +1024 1024      .  ioapic_retrigger_irq
    0  +1024 1024      .  fixup_irqs
    0  +1024 1024      .  create_irq

====== MemInfo ()
    1 - 255-akpm2
    2 - 4k-akpm2

          .1.        .2.    ..final..
     30146560    +786432    30932992    +2%  Active
      1018880     +64512     1083392    +6%  Active(Node.0)
      6517760    +132096     6649856    +2%  Active(Node.1)
     17465344     -12288    17453056    <1%  AnonPages
      2932736     +69632     3002368    +2%  AnonPages(Node.0)
     14532608     -81920    14450688    <1%  AnonPages(Node.1)
      5804032    +327680     6131712    +5%  Buffers
     57851904  +17252352    75104256   +29%  Cached
  10078793728   -5058560 10073735168    <1%  CommitLimit
     73453568   +1028096    74481664    +1%  Committed_AS
       184320    -184320           .  -100%  Dirty
        20480     -20480           .  -100%  Dirty(Node.0)
       163840    -163840           .  -100%  Dirty(Node.1)
      3391488    +352256     3743744   +10%  FilePages(Node.0)
     60264448  +17227776    77492224   +28%  FilePages(Node.1)
     50900992  +16818176    67719168   +33%  Inactive
       561152     +41984      603136    +7%  Inactive(Node.0)
     12164096   +4162560    16326656   +34%  Inactive(Node.1)
      8847360     +16384     8863744    <1%  Mapped
       290816     +45056      335872   +15%  Mapped(Node.0)
      8556544     -28672     8527872    <1%  Mapped(Node.1)
   4014837760  -54091776  3960745984    -1%  MemFree
   2012188672  -16060416  1996128256    <1%  MemFree(Node.0)
   2002522112  -38031360  1964490752    -1%  MemFree(Node.1)
   4151279616  -10117120  4141162496    <1%  MemTotal
    134877184  +16060416   150937600   +11%  MemUsed(Node.0)
    143912960  +38031360   181944320   +26%  MemUsed(Node.1)
      2306048      -8192     2297856    <1%  PageTables
       872448     +32768      905216    +3%  PageTables(Node.0)
      1433600     -40960     1392640    -2%  PageTables(Node.1)
      8290304    +217088     8507392    +2%  SReclaimable
      1155072    -184320      970752   -15%  SReclaimable(Node.0)
      7135232    +401408     7536640    +5%  SReclaimable(Node.1)
     12480512  +11087872    23568384   +88%  SUnreclaim
      4730880   +6569984    11300864  +138%  SUnreclaim(Node.0)
      7749632   +4517888    12267520   +58%  SUnreclaim(Node.1)
     20770816  +11304960    32075776   +54%  Slab
      5885952   +6385664    12271616  +108%  Slab(Node.0)
     14884864   +4919296    19804160   +33%  Slab(Node.1)
    159670272      -4096   159666176    <1%  VmallocUsed
  23140846592  +33765376 23174611968    +0%  Totals


Memory usage in a simulated 2cpu/1gb environment using the
default configuration and NR_CPUS=4096, MAX Nodes=512:

Memory: 1013440k/1048576k available 
(3588k kernel code, 33728k reserved, 1962k data, 1212k init)

	MemTotal:      1014652 kB
	MemFree:        991364 kB
	Buffers:           192 kB
	Cached:           3436 kB
	SwapCached:          0 kB
	Active:           1636 kB
	Inactive:         2648 kB
	SwapTotal:           0 kB
	SwapFree:            0 kB
	Dirty:              20 kB
	Writeback:           0 kB
	AnonPages:         656 kB
	Mapped:           1412 kB
	Slab:            12752 kB
	SReclaimable:      236 kB
	SUnreclaim:      12516 kB
	PageTables:         36 kB
	NFS_Unstable:        0 kB
	Bounce:              0 kB
	CommitLimit:    507324 kB
	Committed_AS:        0 kB
	VmallocTotal: 34359738367 kB
	VmallocUsed:      4896 kB
	VmallocChunk: 34359733471 kB
	HugePages_Total:     0
	HugePages_Free:      0
	HugePages_Rsvd:      0
	HugePages_Surp:      0
	Hugepagesize:     2048 kB

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
