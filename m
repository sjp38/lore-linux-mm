Message-Id: <20080326013811.569646000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:38:11 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 00/12] cpumask: reduce stack pressure from local/passed cpumask variables v2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Modify usage of cpumask_t variables to use pointers as much as possible.

Changes are:

	* Use an allocated array of cpumask_t's for cpumask_of_cpu() when
	  large NR_CPUS count is present.  This removes 26168 bytes of stack
	  usage (see chart below), as well as reduces the code generated for
	  each usage.

	* Modify set_cpus_allowed to pass a pointer to the "newly allowed"
	  cpumask.  This removes 10792 bytes of stack usage but is an
	  ABI change.

	* Add node_to_cpumask_ptr that returns pointer to cpumask for the
	  specified node.  This removes 10256 bytes of stack usage.

	* Modify build_sched_domains and related sub-functions to pass
	  pointers to cpumask temp variables.  This consolidates stack
	  space that was spread over various functions.

	* Remove large array from numa_initmem_init() [-8248 bytes].

	* Optimize usages of {CPU,NODE}_MASK_{NONE,ALL} [-9408 bytes].

	* Various other changes to reduce stacksize and silence checkpatch
	  warnings [-7672 bytes].

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Cc: Anton Blanchard <anton@samba.org>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: Cliff Wickman <cpw@sgi.com>
Cc: Dave Jones <davej@codemonkey.org.uk>
Cc: David Howells <dhowells@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Jack Steiner <steiner@sgi.com>
Cc: Len Brown <len.brown@intel.com>
Cc: Paul Jackson <pj@sgi.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: William L. Irwin <wli@holomorphy.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---

v2: resubmitted based on x86/latest.

Summaries:

	1 - Memory Usages Changes
	2 - Build & Test Results

--- ---------------------------------------------------------
* Memory Usages Changes

Patch list summary of various memory usage changes using the akpm2
config file with NR_CPUS=4096 and MAX_NUMNODES=512.


====== Data (-l 500)
    1 - initial
    2 - cpumask_of_cpu
    8 - sched_domain
   13 - CPU_NODE_MASK

   .1.   .2.    .8.  .13.    ..final..
  3553     .  -1146  +320 2727   -23%  build_sched_domains(.text)
   533  -533      .     .    .  -100%  hpet_enable(.init.text)
   512     .      .  -512    .  -100%  C(.rodata)
     0     .      .  +512  512      .  cpu_mask_all(.data)
 4598 -533 -1146 +320 3239  -29%  Totals

====== Text/Data ()
    1 - initial
    2 - cpumask_of_cpu
    3 - set_cpus_allowed
    6 - numa_initmem_init
    9 - kern_sched
   13 - CPU_NODE_MASK

        .1.    .2.    .3.    .6.    .9.   .13.    ..final..
    3397632  -2048      .      .      .      .   3395584    <1%  TextSize
    1642496  +2048  +4096      .  -4096  -4096   1640448    <1%  DataSize
    1658880      .      .  +8192      .      .   1667072    <1%  InitSize
  287709184      .  +4096      .  -4096  +4096 287713280    <1%  OtherSize
  294408192      .  +8192  +8192  -8192      . 294416384    +0%  Totals

====== Stack (-l 500)
    1 - initial
    2 - cpumask_of_cpu
    3 - set_cpus_allowed
    4 - cpumask_affinity
    6 - numa_initmem_init
    7 - node_to_cpumask_ptr
    8 - sched_domain
    9 - kern_sched
   11 - build_sched_domains
   12 - cpu_coregroup_map
   13 - CPU_NODE_MASK

    .1.    .2.    .3.    .4.    .6.    .7.    .8.   .9.  .11.  .12.   .13.    ..final..
  11080      .      .      .      .   -512  -6352     .  -976   +16   -512 2744   -75%  build_sched_domains
   8248      .      .      .  -8248      .      .     .     .     .      .    .  -100%  numa_initmem_init
   3672  -1024   -496      .      .      .      .     .     .     .      . 2152   -41%  centrino_target
   3176      .      .      .      .  -2576      .     .     .     .      .  600   -81%  sched_domain_node_span
   3096  -1536   -520      .      .      .      .     .     .     .      . 1040   -66%  acpi_processor_set_throttling
   2600  -1536      .      .      .      .      .     .     .     .   -512  552   -78%  powernowk8_cpu_init
   2120  -1024   -512      .      .      .      .     .     .     .      .  584   -72%  cache_add_dev
   2104  -1008      .      .      .      .      .     .     .     .   -512  584   -72%  powernowk8_target
   2104      .   -512      .      .      .      .     .     .     .   -512 1080   -48%  _cpu_down
   2072   -512      .      .      .      .      .     .     .     .      . 1560   -24%  tick_notify
   2064  -1024      .      .      .      .      .     .     .     .   -504  536   -74%  check_supported_cpu
   2056      .  -1544   +520      .      .      .     .     .     .      . 1032   -49%  sched_setaffinity
   2056  -1024   -512      .      .      .      .     .     .     .      .  520   -74%  get_cur_freq
   2056      .   -512  -1032      .      .      .     .     .     .   -512    .  -100%  affinity_set
   2056  -1024   -520      .      .      .      .     .     .     .      .  512   -75%  acpi_processor_get_throttling
   2056  -1024   -512      .      .      .      .     .     .     .      .  520   -74%  acpi_processor_ffh_cstate_probe
   2048  -1016   -520      .      .      .      .     .     .     .      .  512   -75%  powernowk8_get
   1784  -1024      .      .      .      .      .     .     .     .      .  760   -57%  cpufreq_add_dev
   1768      .   -512      .      .  -1256      .     .     .     .      .    .  -100%  kswapd
   1608  -1608      .      .      .      .      .     .     .     .      .    .  -100%  disable_smp
   1592      .      .      .      .  -1592      .     .     .     .      .    .  -100%  do_tune_cpucache
   1576      .      .      .      .      .      .  -480     .     .  -1096    .  -100%  init_sched_build_groups
   1560      .   -528      .      .   -512      .     .     .     .      .  520   -66%  pci_device_probe
   1552      .   -512      .      .      .      .     .     .     .  -1040    .  -100%  kthreadd
   1544  -1024   -520      .      .      .      .     .     .     .      .    .  -100%  stopmachine
   1544  -1032   -512      .      .      .      .     .     .     .      .    .  -100%  native_machine_shutdown
   1544  -1008      .      .      .      .      .     .     .     .      .  536   -65%  alloc_ldt
   1536   -504      .      .      .      .      .     .     .     .      . 1032   -32%  smp_call_function_single
   1536  -1024      .      .      .      .      .     .     .     .      .  512   -66%  native_smp_send_reschedule
   1176      .      .      .      .      .      .  -512     .     .      .  664   -43%  thread_return
   1176      .      .      .      .      .      .  -512     .     .      .  664   -43%  schedule
   1160      .      .      .      .      .      .  -512     .     .      .  648   -44%  run_rebalance_domains
   1160      .      .      .      .  -1160      .     .     .     .      .    .  -100%  __build_all_zonelists
   1144      .      .   +512      .      .      .     .     .     .   -512 1144      .  threshold_create_device
   1080      .   -520      .      .      .      .     .     .     .      .  560   -48%  pdflush
   1080      .   -512      .      .      .      .     .     .     .   -568    .  -100%  kernel_init
   1064      .      .      .      .  -1064      .     .     .     .      .    .  -100%  cpuup_canceled
   1064      .      .      .      .  -1064      .     .     .     .      .    .  -100%  cpuup_callback
   1032  -1032      .      .      .      .      .     .     .     .      .    .  -100%  setup_pit_timer
   1032      .      .      .      .      .      .     .     .     .   -520  512   -50%  physflat_vector_allocation_domain
   1032  -1032      .      .      .      .      .     .     .     .      .    .  -100%  init_workqueues
   1032  -1032      .      .      .      .      .     .     .     .      .    .  -100%  init_idle
   1032      .      .      .      .      .      .     .     .     .   -512  520   -49%  destroy_irq
   1024      .      .   -512      .      .      .     .     .     .      .  512   -50%  sys_sched_setaffinity
   1024  -1024      .      .      .      .      .     .     .     .      .    .  -100%  setup_APIC_timer
   1024      .   -504      .      .      .      .     .     .     .      .  520   -49%  sched_init_smp
   1024  -1024      .      .      .      .      .     .     .     .      .    .  -100%  native_smp_prepare_cpus
   1024  -1024      .      .      .      .      .     .     .     .      .    .  -100%  kthread_bind
   1024  -1024      .      .      .      .      .     .     .     .      .    .  -100%  hpet_enable
   1024      .      .   -512      .      .      .     .     .     .      .  512   -50%  compat_sys_sched_setaffinity
   1024      .      .      .      .      .      .     .     .     .   -512  512   -50%  __percpu_populate_mask
   1024      .   -512      .      .      .      .     .     .     .   -512    .  -100%  ____call_usermodehelper
    568      .      .      .      .      .      .  -568     .     .      .    .  -100%  cpu_attach_domain
    552      .      .      .      .      .      .     .     .     .   -552    .  -100%  migration_call
    520      .      .      .      .   -520      .     .     .     .      .    .  -100%  node_read_cpumap
    520      .      .      .      .      .      .     .     .     .   -520    .  -100%  dynamic_irq_init
    520      .      .      .      .      .      .    -8     .  -512      .    .  -100%  cpu_to_phys_group
    520      .      .      .      .      .      .  -520     .     .      .    .  -100%  cpu_to_core_group
      0      .      .      .      .      .   +760     .     .     .      .  760      .  sd_init_SIBLING
      0      .      .      .      .      .   +760     .     .     .      .  760      .  sd_init_NODE
      0      .      .      .      .      .   +752     .     .     .      .  752      .  sd_init_MC
      0      .      .      .      .      .   +752     .     .     .      .  752      .  sd_init_CPU
      0      .      .      .      .      .   +752     .     .     .      .  752      .  sd_init_ALLNODES
      0      .      .      .      .      .      .  +512     .     .      .  512      .  detach_destroy_domains
 101488 -26168 -10792  -1024  -8248 -10256  -2576 -2600  -976  -496  -9408 28944  -71%  Totals

--- ---------------------------------------------------------
* Build & Test Results

Built/tested:

    nosmp
    nonuma
    defconfig (NR_CPUS/MAX_NUMANODES: 32/64 and 4096/512)
    akpm2 config (NR_CPUS/MAX_NUMANODES: 255/64 and 4096/512)

Built no errors:

    allyesconfig
    allnoconfig
    allmodconfig
    current-x86_64-default
    current-ia64-sn2
    current-ia64-default
    current-ia64-nosmp
    current-ia64-zx1
    current-s390-default
    current-arm-default
    current-sparc-default
    current-sparc64-default
    current-sparc64-smp
    current-ppc-pmac32

Not Built (previous errors):

    current-x86_64-single
	drivers/built-in.o: In function `sas_request_addr':
	(.text+0x814bd): undefined reference to `request_firmware'
	drivers/built-in.o: In function `sas_request_addr':
	(.text+0x81556): undefined reference to `release_firmware'
    current-x86_64-8psmp
	drivers/built-in.o: In function `sas_request_addr':
	(.text+0x814bd): undefined reference to `request_firmware'
	drivers/built-in.o: In function `sas_request_addr':
	(.text+0x81556): undefined reference to `release_firmware'
    current-x86_64-debug
	sas_scsi_host.c:1091: undefined reference to `request_firmware'
	sas_scsi_host.c:1103: undefined reference to `release_firmware'
    current-x86_64-numa
	drivers/built-in.o: In function `sas_request_addr':
	(.text+0x8540d): undefined reference to `request_firmware'
	drivers/built-in.o: In function `sas_request_addr':
	(.text+0x854a6): undefined reference to `release_firmware'
    current-i386-single
	drivers/built-in.o: In function `sas_request_addr':
	(.text+0x7617a): undefined reference to `request_firmware'
	drivers/built-in.o: In function `sas_request_addr':
	(.text+0x76208): undefined reference to `release_firmware'
    current-i386-smp
	drivers/built-in.o: In function `sas_request_addr':
	(.text+0x7985a): undefined reference to `request_firmware'
	drivers/built-in.o: In function `sas_request_addr':
	(.text+0x798e8): undefined reference to `release_firmware'
    current-ppc-smp
	WRAP    arch/powerpc/boot/uImage
	ln: accessing `arch/powerpc/boot/uImage': No such file or directory

(Note: build with patches applied did not change errors.)


--- ---------------------------------------------------------

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
