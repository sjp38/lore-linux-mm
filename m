Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA4A6B0292
	for <linux-mm@kvack.org>; Wed, 31 May 2017 16:39:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e8so26170619pfl.4
        for <linux-mm@kvack.org>; Wed, 31 May 2017 13:39:59 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z184si18205043pgb.151.2017.05.31.13.39.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 13:39:57 -0700 (PDT)
Date: Thu, 01 Jun 2017 04:39:38 +0800
From: kernel test robot <fengguang.wu@intel.com>
Subject: [mm: vmstat] b6bc672448:  BUG: unable to handle kernel paging
 request at 1c435000
Message-ID: <592f2a0a.82djxxjbsYDCtigP%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_592f2a0a.EQV0bEyfNLIWsOzPExW3PzqWDxmK3x/BnefmCm4Z+PUOQ1SI"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.orgLinux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com

This is a multi-part message in MIME format.

--=_592f2a0a.EQV0bEyfNLIWsOzPExW3PzqWDxmK3x/BnefmCm4Z+PUOQ1SI
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit b6bc6724488ac9a149f4ee50d9f036b0fe2420c5
Author:     Johannes Weiner <hannes@cmpxchg.org>
AuthorDate: Wed May 31 09:17:23 2017 +1000
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Wed May 31 09:17:23 2017 +1000

    mm: vmstat: move slab statistics from zone to node counters
    
    Patch series "mm: per-lruvec slab stats"
    
    Josef is working on a new approach to balancing slab caches and the page
    cache.  For this to work, he needs slab cache statistics on the lruvec
    level.  These patches implement that by adding infrastructure that allows
    updating and reading generic VM stat items per lruvec, then switches some
    existing VM accounting sites, including the slab accounting ones, to this
    new cgroup-aware API.
    
    I'll follow up with more patches on this, because there is actually
    substantial simplification that can be done to the memory controller when
    we replace private memcg accounting with making the existing VM accounting
    sites cgroup-aware.  But this is enough for Josef to base his slab reclaim
    work on, so here goes.
    
    This patch (of 5):
    
    To re-implement slab cache vs.  page cache balancing, we'll need the slab
    counters at the lruvec level, which, ever since lru reclaim was moved from
    the zone to the node, is the intersection of the node, not the zone, and
    the memcg.
    
    We could retain the per-zone counters for when the page allocator dumps
    its memory information on failures, and have counters on both levels -
    which on all but NUMA node 0 is usually redundant.  But let's keep it
    simple for now and just move them.  If anybody complains we can restore
    the per-zone counters.
    
    Link: http://lkml.kernel.org/r/20170530181724.27197-3-hannes@cmpxchg.org
    Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
    Cc: Josef Bacik <josef@toxicpanda.com>
    Cc: Michal Hocko <mhocko@suse.com>
    Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
    Cc: Rik van Riel <riel@redhat.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

fa812e869a  mm/zswap.c: delete an error message for a failed memory allocation in zswap_dstmem_prepare()
b6bc672448  mm: vmstat: move slab statistics from zone to node counters
f2882f46b6  Add linux-next specific files for 20170531
+-------------------------------------------------+------------+------------+---------------+
|                                                 | fa812e869a | b6bc672448 | next-20170531 |
+-------------------------------------------------+------------+------------+---------------+
| boot_successes                                  | 35         | 0          | 0             |
| boot_failures                                   | 0          | 15         | 13            |
| BUG:unable_to_handle_kernel                     | 0          | 15         | 13            |
| Oops:#[##]                                      | 0          | 15         | 13            |
| EIP:mod_node_state                              | 0          | 15         | 13            |
| Kernel_panic-not_syncing:Fatal_exception        | 0          | 15         | 13            |
| BUG:kernel_reboot-without-warning_in_boot_stage | 0          | 2          |               |
| BUG:kernel_reboot-without-warning_in_test_stage | 0          | 5          |               |
| BUG:kernel_hang_in_test_stage                   | 0          | 0          | 1             |
| BUG:kernel_in_stage                             | 0          | 0          | 2             |
+-------------------------------------------------+------------+------------+---------------+

[    0.000000]     lowmem  : 0xc0000000 - 0xdffe0000   ( 511 MB)
[    0.000000]       .init : 0xc1e82000 - 0xc1f47000   ( 788 kB)
[    0.000000]       .data : 0xc1815d39 - 0xc1e71780   (6510 kB)
[    0.000000]       .text : 0xc1000000 - 0xc1815d39   (8279 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] BUG: unable to handle kernel paging request at 1c435000
[    0.000000] IP: mod_node_state+0x22/0xaf
[    0.000000] *pde = 00000000 
[    0.000000] 
[    0.000000] Oops: 0000 [#1] SMP
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.12.0-rc3-00153-gb6bc672 #1
[    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
[    0.000000] task: c1b34480 task.stack: c1b2e000
[    0.000000] EIP: mod_node_state+0x22/0xaf
[    0.000000] EFLAGS: 00210092 CPU: 0
[    0.000000] EAX: 00000000 EBX: 00000001 ECX: 00000007 EDX: 00000006
[    0.000000] ESI: c1f0ce20 EDI: ddc01000 EBP: c1b2fee0 ESP: c1b2febc
[    0.000000]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[    0.000000] CR0: 80050033 CR2: 1c435000 CR3: 01f4e000 CR4: 00000690
[    0.000000] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[    0.000000] DR6: fffe0ff0 DR7: 00000400
[    0.000000] Call Trace:
[    0.000000]  ? kmem_cache_debug+0x1e/0x25
[    0.000000]  mod_node_page_state+0xa/0xd
[    0.000000]  new_slab+0x44a/0x467
[    0.000000]  kmem_cache_open+0x1e3/0x41d
[    0.000000]  __kmem_cache_create+0xc/0x7a
[    0.000000]  create_boot_cache+0x2f/0x65
[    0.000000]  kmem_cache_init+0x37/0x105
[    0.000000]  start_kernel+0x216/0x497
[    0.000000]  i386_start_kernel+0xa8/0xac
[    0.000000]  startup_32_smp+0x16b/0x16d
[    0.000000] Code: c1 e8 07 ff ff ff 58 c9 c3 55 89 e5 57 56 53 83 ec 18 89 45 e4 8b 80 40 0c 00 00 89 4d dc 8d 4c 10 01 89 45 ec 8b 5d dc 8b 45 ec <64> 8a 00 0f be c0 89 45 f0 64 8a 01 88 45 e3 0f be c0 01 c3 39
[    0.000000] EIP: mod_node_state+0x22/0xaf SS:ESP: 0068:c1b2febc
[    0.000000] CR2: 000000001c435000
[    0.000000] ---[ end trace f68728a0d3053b52 ]---
[    0.000000] Kernel panic - not syncing: Fatal exception

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start f2882f46b623423c573c4d029b016974b04da954 5ed02dbb497422bf225783f46e6eadd237d23d6b --
git bisect good 8168ff213ef9d0cc386fdca1d46e4553262b21f3  # 23:32  G     11     0    0   0  Merge remote-tracking branch 'idle/next'
git bisect good 6cef1356d3794dd87dfac808172e3c8517137df0  # 23:44  G     11     0    0   0  Merge remote-tracking branch 'iommu/next'
git bisect good 1ad18baf77ecde079ebd95223a7e7efcea3fefc5  # 23:56  G     11     0    0   0  Merge remote-tracking branch 'extcon/extcon-next'
git bisect good 06867893048b1dadef7f2d1db824e245d568a089  # 00:10  G     11     0    0   0  Merge remote-tracking branch 'pinctrl/for-next'
git bisect good f9e05a7857806e481b38b176e88f1e087aa38f3b  # 00:30  G     11     0    0   0  Merge remote-tracking branch 'livepatching/for-next'
git bisect good 5f6e1344a0311cbdd6f12551d0939886a161e513  # 00:49  G     11     0    0   0  next-20170530/rtc
git bisect  bad ea0e19f1f81355bede5aea2d4bc1e22afcc8d3ea  # 01:09  B      0    11   25   2  Merge branch 'akpm-current/current'
git bisect good 1d4a95b197227152bf68b059923d801e6ce37ed8  # 01:32  G     11     0    0   0  mm-hugetlb-introduce-set_huge_swap_pte_at-helper-v41
git bisect  bad 9d1f2181ae0d158277513d0cb13f7a8a1d58729a  # 01:59  B      0    11   23   0  lib/kstrtox.c: use "unsigned int" more
git bisect  bad 3cdb9deb763d75ebfc0f923d1629fa444e2ff601  # 02:25  B      0     3   19   4  mm: memcontrol: use generic mod_memcg_page_state for kmem pages
git bisect good e67718370b2f707ff1dc00d22b3527692b20e1a8  # 02:45  G     11     0    0   0  mm: kmemleak: treat vm_struct as alternative reference to vmalloc'ed objects
git bisect good 393279a903528342a09c002f860ec4ed28e07671  # 02:59  G     10     0    0   0  mm-oom_kill-count-global-and-memory-cgroup-oom-kills-fix-fix
git bisect good 84ebee41ad5abc3745f8d8f0d37d585bf469d984  # 03:35  G     11     0    0   0  mm/zswap.c: improve a size determination in zswap_frontswap_init()
git bisect  bad b6bc6724488ac9a149f4ee50d9f036b0fe2420c5  # 03:55  B      0     1   16   3  mm: vmstat: move slab statistics from zone to node counters
git bisect good fa812e869a6fe7495a17150bb2639075081ef709  # 04:16  G     11     0    0   0  mm/zswap.c: delete an error message for a failed memory allocation in zswap_dstmem_prepare()
# first bad commit: [b6bc6724488ac9a149f4ee50d9f036b0fe2420c5] mm: vmstat: move slab statistics from zone to node counters
git bisect good fa812e869a6fe7495a17150bb2639075081ef709  # 04:19  G     31     0    0   0  mm/zswap.c: delete an error message for a failed memory allocation in zswap_dstmem_prepare()
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad b6bc6724488ac9a149f4ee50d9f036b0fe2420c5  # 04:38  B      0    11   24   1  mm: vmstat: move slab statistics from zone to node counters
# extra tests on HEAD of linux-next/master
git bisect  bad f2882f46b623423c573c4d029b016974b04da954  # 04:38  B      0    13   28   0  Add linux-next specific files for 20170531
# extra tests on tree/branch linux-next/master
git bisect  bad f2882f46b623423c573c4d029b016974b04da954  # 04:38  B      0    13   28   0  Add linux-next specific files for 20170531

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_592f2a0a.EQV0bEyfNLIWsOzPExW3PzqWDxmK3x/BnefmCm4Z+PUOQ1SI
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-quantal-lkp-hsw01-17:20170601035523:i386-randconfig-h1-05312124:4.12.0-rc3-00153-gb6bc672:1.gz"

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

--=_592f2a0a.EQV0bEyfNLIWsOzPExW3PzqWDxmK3x/BnefmCm4Z+PUOQ1SI
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="reproduce-quantal-lkp-hsw01-17:20170601035523:i386-randconfig-h1-05312124:4.12.0-rc3-00153-gb6bc672:1"

#!/bin/bash

kernel=$1

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu kvm64
	-kernel $kernel
	-m 512
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	console=tty0
	vga=normal
	rw
	drbd.minor_count=8
)

"${kvm[@]}" -append "${append[*]}"

--=_592f2a0a.EQV0bEyfNLIWsOzPExW3PzqWDxmK3x/BnefmCm4Z+PUOQ1SI
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-4.12.0-rc3-00153-gb6bc672"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 4.12.0-rc3 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_BITS_MAX=16
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=2
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_KERNEL_LZ4=y
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_CLASSIC_SRCU=y
# CONFIG_TASKS_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FAST_NO_HZ is not set
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_KTHREAD_PRIO=0
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
# CONFIG_BLK_CGROUP is not set
# CONFIG_CGROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_RDMA is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_SOCK_CGROUP_DATA is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
CONFIG_IPC_NS=y
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_POSIX_TIMERS=y
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
# CONFIG_BPF_SYSCALL is not set
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_USERFAULTFD is not set
CONFIG_PCI_QUIRKS=y
CONFIG_MEMBARRIER=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PC104=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
CONFIG_SLAB_FREELIST_RANDOM=y
# CONFIG_SLUB_CPU_PARTIAL is not set
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_OPROFILE=m
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
CONFIG_JUMP_LABEL=y
CONFIG_STATIC_KEYS_SELFTEST=y
CONFIG_UPROBES=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
# CONFIG_HAVE_ARCH_HASH is not set
CONFIG_ISA_BUS_API=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set
# CONFIG_HAVE_ARCH_VMAP_STACK is not set
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX is not set
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX_DEFAULT is not set
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_PROFILE_ALL is not set
CONFIG_GCOV_FORMAT_AUTODETECT=y
# CONFIG_GCOV_FORMAT_3_4 is not set
# CONFIG_GCOV_FORMAT_4_7 is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
# CONFIG_MODULE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
# CONFIG_TRIM_UNUSED_KSYMS is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_LBDAF=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_ZONED is not set
CONFIG_BLK_CMDLINE_PARSER=y
# CONFIG_BLK_WBT is not set
# CONFIG_BLK_DEBUG_FS is not set
CONFIG_BLK_SED_OPAL=y

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
CONFIG_OSF_PARTITION=y
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
# CONFIG_UNIXWARE_DISKLABEL is not set
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=m
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
CONFIG_MQ_IOSCHED_DEADLINE=m
# CONFIG_MQ_IOSCHED_KYBER is not set
# CONFIG_IOSCHED_BFQ is not set
CONFIG_PADATA=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_BIGSMP=y
# CONFIG_GOLDFISH is not set
CONFIG_INTEL_RDT_A=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=m
# CONFIG_IOSF_MBI_DEBUG is not set
# CONFIG_X86_32_IRIS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
CONFIG_M686=y
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
# CONFIG_X86_PPRO_FENCE is not set
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_NR_CPUS=32
# CONFIG_SCHED_SMT is not set
# CONFIG_SCHED_MC is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
# CONFIG_PERF_EVENTS_INTEL_UNCORE is not set
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
# CONFIG_X86_LEGACY_VM86 is not set
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX32=y
CONFIG_TOSHIBA=m
# CONFIG_I8K is not set
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=m
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_HIGHMEM=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_ARCH_WANTS_THP_SWAP is not set
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=m
# CONFIG_PGTABLE_MAPPING is not set
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_FRAME_VECTOR=y
# CONFIG_HIGHPTE is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_MPX=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
# CONFIG_PM_WAKELOCKS_GC is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_SFI=y
CONFIG_X86_APM_BOOT=y
CONFIG_APM=m
CONFIG_APM_IGNORE_USER_SUSPEND=y
# CONFIG_APM_DO_ENABLE is not set
# CONFIG_APM_CPU_IDLE is not set
# CONFIG_APM_DISPLAY_BLANK is not set
# CONFIG_APM_ALLOW_INTS is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOOLPC is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_OLPC=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
CONFIG_PCIEAER_INJECT=m
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
# CONFIG_PCIEASPM_DEFAULT is not set
# CONFIG_PCIEASPM_POWERSAVE is not set
CONFIG_PCIEASPM_POWER_SUPERSAVE=y
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
# CONFIG_PCIE_DPC is not set
CONFIG_PCIE_PTM=y
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=m
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
# CONFIG_PCI_IOV is not set
CONFIG_PCI_PRI=y
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# DesignWare PCI Core Support
#

#
# PCI host controller drivers
#

#
# PCI Endpoint
#
CONFIG_PCI_ENDPOINT=y
# CONFIG_PCI_ENDPOINT_CONFIGFS is not set
# CONFIG_PCI_EPF_TEST is not set

#
# PCI switch controller drivers
#
CONFIG_PCI_SW_SWITCHTEC=y
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
# CONFIG_EISA is not set
# CONFIG_SCx200 is not set
CONFIG_OLPC=y
# CONFIG_OLPC_XO1_PM is not set
# CONFIG_OLPC_XO15_SCI is not set
# CONFIG_ALIX is not set
# CONFIG_NET5501 is not set
# CONFIG_GEOS is not set
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
CONFIG_RAPIDIO=y
# CONFIG_RAPIDIO_TSI721 is not set
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
CONFIG_RAPIDIO_DMA_ENGINE=y
# CONFIG_RAPIDIO_DEBUG is not set
CONFIG_RAPIDIO_ENUM_BASIC=m
CONFIG_RAPIDIO_CHMAN=y
CONFIG_RAPIDIO_MPORT_CDEV=m

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=y
CONFIG_RAPIDIO_CPS_XX=m
CONFIG_RAPIDIO_TSI568=m
CONFIG_RAPIDIO_CPS_GEN2=y
CONFIG_RAPIDIO_RXS_GEN3=m
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=m
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_COMPAT_32=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=m
CONFIG_PACKET_DIAG=m
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=m
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NET_PTP_CLASSIFY is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
CONFIG_ATM=y
CONFIG_ATM_LANE=y
CONFIG_STP=m
CONFIG_GARP=m
# CONFIG_BRIDGE is not set
CONFIG_VLAN_8021Q=m
CONFIG_VLAN_8021Q_GVRP=y
# CONFIG_VLAN_8021Q_MVRP is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
CONFIG_LAPB=y
CONFIG_PHONET=m
CONFIG_IEEE802154=m
# CONFIG_IEEE802154_NL802154_EXPERIMENTAL is not set
CONFIG_IEEE802154_SOCKET=m
CONFIG_MAC802154=m
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
# CONFIG_NET_SCH_HFSC is not set
CONFIG_NET_SCH_ATM=y
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_MULTIQ=y
# CONFIG_NET_SCH_RED is not set
# CONFIG_NET_SCH_SFB is not set
CONFIG_NET_SCH_SFQ=y
# CONFIG_NET_SCH_TEQL is not set
# CONFIG_NET_SCH_TBF is not set
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=y
# CONFIG_NET_SCH_NETEM is not set
CONFIG_NET_SCH_DRR=y
CONFIG_NET_SCH_MQPRIO=m
CONFIG_NET_SCH_CHOKE=m
# CONFIG_NET_SCH_QFQ is not set
CONFIG_NET_SCH_CODEL=m
# CONFIG_NET_SCH_FQ_CODEL is not set
CONFIG_NET_SCH_FQ=m
CONFIG_NET_SCH_HHF=y
CONFIG_NET_SCH_PIE=y
# CONFIG_NET_SCH_INGRESS is not set
CONFIG_NET_SCH_PLUG=y
# CONFIG_NET_SCH_DEFAULT is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=y
# CONFIG_NET_CLS_FW is not set
# CONFIG_NET_CLS_U32 is not set
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=m
# CONFIG_NET_CLS_FLOW is not set
# CONFIG_NET_CLS_CGROUP is not set
CONFIG_NET_CLS_BPF=y
CONFIG_NET_CLS_FLOWER=y
CONFIG_NET_CLS_MATCHALL=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
# CONFIG_NET_EMATCH_CMP is not set
# CONFIG_NET_EMATCH_NBYTE is not set
CONFIG_NET_EMATCH_U32=y
# CONFIG_NET_EMATCH_META is not set
CONFIG_NET_EMATCH_TEXT=m
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=y
# CONFIG_GACT_PROB is not set
# CONFIG_NET_ACT_MIRRED is not set
CONFIG_NET_ACT_SAMPLE=y
CONFIG_NET_ACT_NAT=y
CONFIG_NET_ACT_PEDIT=y
CONFIG_NET_ACT_SIMP=y
# CONFIG_NET_ACT_SKBEDIT is not set
CONFIG_NET_ACT_VLAN=m
CONFIG_NET_ACT_BPF=y
CONFIG_NET_ACT_SKBMOD=m
CONFIG_NET_ACT_IFE=m
CONFIG_NET_ACT_TUNNEL_KEY=y
CONFIG_NET_IFE_SKBMARK=m
# CONFIG_NET_IFE_SKBPRIO is not set
# CONFIG_NET_IFE_SKBTCINDEX is not set
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=m
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
CONFIG_HSR=m
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
CONFIG_BT=m
CONFIG_BT_BREDR=y
CONFIG_BT_RFCOMM=m
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=m
CONFIG_BT_BNEP_MC_FILTER=y
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_HIDP=m
# CONFIG_BT_HS is not set
CONFIG_BT_LE=y
# CONFIG_BT_LEDS is not set
# CONFIG_BT_SELFTEST is not set
# CONFIG_BT_DEBUGFS is not set

#
# Bluetooth device drivers
#
CONFIG_BT_INTEL=m
CONFIG_BT_QCA=m
CONFIG_BT_HCIBTSDIO=m
CONFIG_BT_HCIUART=m
CONFIG_BT_HCIUART_H4=y
# CONFIG_BT_HCIUART_BCSP is not set
CONFIG_BT_HCIUART_ATH3K=y
# CONFIG_BT_HCIUART_LL is not set
CONFIG_BT_HCIUART_3WIRE=y
CONFIG_BT_HCIUART_INTEL=y
# CONFIG_BT_HCIUART_BCM is not set
CONFIG_BT_HCIUART_QCA=y
# CONFIG_BT_HCIUART_AG6XX is not set
# CONFIG_BT_HCIUART_MRVL is not set
CONFIG_BT_HCIVHCI=m
CONFIG_BT_MRVL=m
CONFIG_BT_MRVL_SDIO=m
# CONFIG_BT_WILINK is not set
# CONFIG_STREAM_PARSER is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
CONFIG_WIMAX=m
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
CONFIG_RFKILL_GPIO=m
CONFIG_NET_9P=m
# CONFIG_NET_9P_VIRTIO is not set
CONFIG_NET_9P_DEBUG=y
CONFIG_CAIF=m
CONFIG_CAIF_DEBUG=y
CONFIG_CAIF_NETDEV=m
# CONFIG_CAIF_USB is not set
CONFIG_NFC=m
CONFIG_NFC_DIGITAL=m
CONFIG_NFC_NCI=m
# CONFIG_NFC_NCI_UART is not set
CONFIG_NFC_HCI=m
CONFIG_NFC_SHDLC=y

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_MEI_PHY=m
# CONFIG_NFC_SIM is not set
CONFIG_NFC_FDP=m
CONFIG_NFC_FDP_I2C=m
# CONFIG_NFC_PN544_I2C is not set
# CONFIG_NFC_PN544_MEI is not set
# CONFIG_NFC_PN533_I2C is not set
CONFIG_NFC_MICROREAD=m
# CONFIG_NFC_MICROREAD_I2C is not set
CONFIG_NFC_MICROREAD_MEI=m
# CONFIG_NFC_ST21NFCA_I2C is not set
CONFIG_NFC_ST_NCI=m
CONFIG_NFC_ST_NCI_I2C=m
CONFIG_NFC_NXP_NCI=m
CONFIG_NFC_NXP_NCI_I2C=m
CONFIG_NFC_S3FWRN5=m
CONFIG_NFC_S3FWRN5_I2C=m
CONFIG_PSAMPLE=y
CONFIG_NET_IFE=m
CONFIG_LWTUNNEL=y
CONFIG_LWTUNNEL_BPF=y
# CONFIG_DST_CACHE is not set
# CONFIG_GRO_CELLS is not set
CONFIG_NET_DEVLINK=m
CONFIG_MAY_USE_DEVLINK=m

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_WANT_DEV_COREDUMP=y
CONFIG_ALLOW_DEV_COREDUMP=y
CONFIG_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
CONFIG_TEST_ASYNC_DRIVER_PROBE=m
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set

#
# Bus devices
#
CONFIG_CONNECTOR=m
CONFIG_MTD=m
# CONFIG_MTD_TESTS is not set
# CONFIG_MTD_REDBOOT_PARTS is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_OF_PARTS=m
CONFIG_MTD_AR7_PARTS=m

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=m
# CONFIG_MTD_BLOCK is not set
CONFIG_MTD_BLOCK_RO=m
CONFIG_FTL=m
CONFIG_NFTL=m
# CONFIG_NFTL_RW is not set
# CONFIG_INFTL is not set
# CONFIG_RFD_FTL is not set
CONFIG_SSFDC=m
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=m
CONFIG_MTD_PARTITIONED_MASTER=y

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
CONFIG_MTD_JEDECPROBE=m
CONFIG_MTD_GEN_PROBE=m
CONFIG_MTD_CFI_ADV_OPTIONS=y
CONFIG_MTD_CFI_NOSWAP=y
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
CONFIG_MTD_CFI_GEOMETRY=y
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
# CONFIG_MTD_MAP_BANK_WIDTH_4 is not set
CONFIG_MTD_MAP_BANK_WIDTH_8=y
CONFIG_MTD_MAP_BANK_WIDTH_16=y
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
# CONFIG_MTD_CFI_I2 is not set
CONFIG_MTD_CFI_I4=y
CONFIG_MTD_CFI_I8=y
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=m
CONFIG_MTD_CFI_AMDSTD=m
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=m
CONFIG_MTD_RAM=m
CONFIG_MTD_ROM=m
CONFIG_MTD_ABSENT=m

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=m
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_PHYSMAP_OF=m
# CONFIG_MTD_PHYSMAP_OF_VERSATILE is not set
# CONFIG_MTD_PHYSMAP_OF_GEMINI is not set
CONFIG_MTD_AMD76XROM=m
CONFIG_MTD_ICHXROM=m
CONFIG_MTD_ESB2ROM=m
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
CONFIG_MTD_NETtel=m
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_INTEL_VR_NOR=m
CONFIG_MTD_PLATRAM=m

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=m
# CONFIG_MTD_PMC551_BUGFIX is not set
CONFIG_MTD_PMC551_DEBUG=y
# CONFIG_MTD_SLRAM is not set
CONFIG_MTD_PHRAM=m
CONFIG_MTD_MTDRAM=m
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTD_BLOCK2MTD=m

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=m
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=m
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=m
# CONFIG_MTD_NAND_ECC_BCH is not set
# CONFIG_MTD_SM_COMMON is not set
CONFIG_MTD_NAND_DENALI=m
CONFIG_MTD_NAND_DENALI_PCI=m
CONFIG_MTD_NAND_DENALI_DT=m
CONFIG_MTD_NAND_GPIO=m
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
# CONFIG_MTD_NAND_RICOH is not set
# CONFIG_MTD_NAND_DISKONCHIP is not set
# CONFIG_MTD_NAND_DOCG4 is not set
CONFIG_MTD_NAND_CAFE=m
CONFIG_MTD_NAND_CS553X=m
# CONFIG_MTD_NAND_NANDSIM is not set
# CONFIG_MTD_NAND_PLATFORM is not set
CONFIG_MTD_NAND_HISI504=m
# CONFIG_MTD_NAND_MTK is not set
CONFIG_MTD_ONENAND=m
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=m
# CONFIG_MTD_ONENAND_OTP is not set
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=m
CONFIG_MTD_QINFO_PROBE=m
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
# CONFIG_MTD_UBI_GLUEBI is not set
CONFIG_MTD_UBI_BLOCK=y
CONFIG_DTC=y
CONFIG_OF=y
CONFIG_OF_UNITTEST=y
CONFIG_OF_FLATTREE=y
CONFIG_OF_EARLY_FLATTREE=y
CONFIG_OF_PROMTREE=y
CONFIG_OF_DYNAMIC=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_ADDRESS_PCI=y
CONFIG_OF_IRQ=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_OF_RESOLVE=y
CONFIG_OF_OVERLAY=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=m
# CONFIG_PARPORT_PC_FIFO is not set
CONFIG_PARPORT_PC_SUPERIO=y
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
# CONFIG_PARPORT_1284 is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
# CONFIG_ISAPNP is not set
# CONFIG_PNPBIOS is not set
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_FD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_RSXX is not set
CONFIG_NVME_CORE=y
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_NVME_SCSI is not set
CONFIG_NVME_FABRICS=y
CONFIG_NVME_FC=y
CONFIG_NVME_TARGET=y
# CONFIG_NVME_TARGET_LOOP is not set
CONFIG_NVME_TARGET_FC=y
CONFIG_NVME_TARGET_FCLOOP=y

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=m
CONFIG_AD525X_DPOT_I2C=m
# CONFIG_DUMMY_IRQ is not set
CONFIG_IBM_ASM=m
CONFIG_PHANTOM=y
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=m
# CONFIG_CS5535_MFGPT is not set
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=m
CONFIG_ISL29003=m
CONFIG_ISL29020=y
# CONFIG_SENSORS_TSL2550 is not set
CONFIG_SENSORS_BH1770=m
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_PCH_PHUB=m
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_SRAM=y
# CONFIG_PCI_ENDPOINT_TEST is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=m
# CONFIG_EEPROM_IDT_89HPESX is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=m
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
CONFIG_INTEL_MEI=m
CONFIG_INTEL_MEI_ME=m
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#

#
# SCIF Bus Driver
#

#
# VOP Bus Driver
#

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
CONFIG_ECHO=m
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_AFU_DRIVER_OPS is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=m
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=m
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_MQ_DEFAULT=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_ST=m
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=m
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=m
# CONFIG_SCSI_DH_HP_SW is not set
# CONFIG_SCSI_DH_EMC is not set
CONFIG_SCSI_DH_ALUA=m
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=m
# CONFIG_ATA_NONSTANDARD is not set
# CONFIG_ATA_VERBOSE_ERROR is not set
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
CONFIG_SATA_AHCI_PLATFORM=m
CONFIG_AHCI_CEVA=m
CONFIG_AHCI_QORIQ=m
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_ATA_SFF is not set
CONFIG_MD=y
# CONFIG_BLK_DEV_MD is not set
# CONFIG_BCACHE is not set
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_MQ_DEFAULT is not set
# CONFIG_DM_DEBUG is not set
CONFIG_DM_BUFIO=m
# CONFIG_DM_DEBUG_BLOCK_MANAGER_LOCKING is not set
CONFIG_DM_BIO_PRISON=m
CONFIG_DM_PERSISTENT_DATA=m
CONFIG_DM_CRYPT=m
# CONFIG_DM_SNAPSHOT is not set
CONFIG_DM_THIN_PROVISIONING=m
CONFIG_DM_CACHE=m
# CONFIG_DM_CACHE_SMQ is not set
CONFIG_DM_ERA=m
# CONFIG_DM_MIRROR is not set
# CONFIG_DM_RAID is not set
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
# CONFIG_DM_MULTIPATH_QL is not set
CONFIG_DM_MULTIPATH_ST=m
CONFIG_DM_DELAY=m
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=m
CONFIG_DM_VERITY=m
# CONFIG_DM_VERITY_FEC is not set
CONFIG_DM_SWITCH=m
CONFIG_DM_LOG_WRITES=m
# CONFIG_DM_INTEGRITY is not set
CONFIG_TARGET_CORE=m
CONFIG_TCM_IBLOCK=m
CONFIG_TCM_FILEIO=m
# CONFIG_TCM_PSCSI is not set
CONFIG_TCM_USER2=m
CONFIG_LOOPBACK_TARGET=m
# CONFIG_ISCSI_TARGET is not set
CONFIG_SBP_TARGET=m
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
CONFIG_FIREWIRE_SBP2=m
CONFIG_FIREWIRE_NOSY=y
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=m
# CONFIG_NETDEVICES is not set
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=m
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=m
CONFIG_INPUT_MATRIXKMAP=m

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=m
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADC is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_STMPE is not set
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_KEYBOARD_BCM is not set
CONFIG_INPUT_MOUSE=y
# CONFIG_MOUSE_PS2 is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_ELAN_I2C is not set
# CONFIG_MOUSE_INPORT is not set
CONFIG_MOUSE_LOGIBM=y
# CONFIG_MOUSE_PC110PAD is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=m
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=m
# CONFIG_JOYSTICK_A3D is not set
# CONFIG_JOYSTICK_ADI is not set
# CONFIG_JOYSTICK_COBRA is not set
CONFIG_JOYSTICK_GF2K=y
# CONFIG_JOYSTICK_GRIP is not set
CONFIG_JOYSTICK_GRIP_MP=y
# CONFIG_JOYSTICK_GUILLEMOT is not set
CONFIG_JOYSTICK_INTERACT=m
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=m
CONFIG_JOYSTICK_IFORCE=m
# CONFIG_JOYSTICK_IFORCE_232 is not set
CONFIG_JOYSTICK_WARRIOR=y
CONFIG_JOYSTICK_MAGELLAN=y
# CONFIG_JOYSTICK_SPACEORB is not set
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=m
# CONFIG_JOYSTICK_TWIDJOY is not set
CONFIG_JOYSTICK_ZHENHUA=m
# CONFIG_JOYSTICK_DB9 is not set
CONFIG_JOYSTICK_GAMECON=m
# CONFIG_JOYSTICK_TURBOGRAFX is not set
CONFIG_JOYSTICK_AS5011=m
# CONFIG_JOYSTICK_JOYDUMP is not set
# CONFIG_JOYSTICK_XPAD is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
CONFIG_TOUCHSCREEN_88PM860X=m
# CONFIG_TOUCHSCREEN_AD7879 is not set
CONFIG_TOUCHSCREEN_AR1021_I2C=y
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
CONFIG_TOUCHSCREEN_AUO_PIXCIR=y
CONFIG_TOUCHSCREEN_BU21013=m
CONFIG_TOUCHSCREEN_CHIPONE_ICN8318=y
CONFIG_TOUCHSCREEN_CY8CTMG110=y
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP_I2C=y
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP4_I2C=y
CONFIG_TOUCHSCREEN_DA9052=y
CONFIG_TOUCHSCREEN_DYNAPRO=m
CONFIG_TOUCHSCREEN_HAMPSHIRE=m
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_EGALAX is not set
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
CONFIG_TOUCHSCREEN_FUJITSU=m
# CONFIG_TOUCHSCREEN_GOODIX is not set
CONFIG_TOUCHSCREEN_ILI210X=m
CONFIG_TOUCHSCREEN_GUNZE=m
# CONFIG_TOUCHSCREEN_EKTF2127 is not set
CONFIG_TOUCHSCREEN_ELAN=m
CONFIG_TOUCHSCREEN_ELO=m
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=m
CONFIG_TOUCHSCREEN_MAX11801=y
# CONFIG_TOUCHSCREEN_MCS5000 is not set
CONFIG_TOUCHSCREEN_MMS114=y
CONFIG_TOUCHSCREEN_MELFAS_MIP4=m
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_IMX6UL_TSC=y
CONFIG_TOUCHSCREEN_INEXIO=m
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_HTCPEN is not set
CONFIG_TOUCHSCREEN_PENMOUNT=y
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
CONFIG_TOUCHSCREEN_TOUCHWIN=y
CONFIG_TOUCHSCREEN_PIXCIR=m
# CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set
CONFIG_TOUCHSCREEN_WM831X=m
CONFIG_TOUCHSCREEN_WM97XX=m
# CONFIG_TOUCHSCREEN_WM9705 is not set
# CONFIG_TOUCHSCREEN_WM9712 is not set
CONFIG_TOUCHSCREEN_WM9713=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_MC13783=m
CONFIG_TOUCHSCREEN_TOUCHIT213=y
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
CONFIG_TOUCHSCREEN_TSC200X_CORE=y
CONFIG_TOUCHSCREEN_TSC2004=y
CONFIG_TOUCHSCREEN_TSC2007=y
# CONFIG_TOUCHSCREEN_TSC2007_IIO is not set
CONFIG_TOUCHSCREEN_RM_TS=y
CONFIG_TOUCHSCREEN_SILEAD=m
# CONFIG_TOUCHSCREEN_SIS_I2C is not set
# CONFIG_TOUCHSCREEN_ST1232 is not set
CONFIG_TOUCHSCREEN_STMPE=m
# CONFIG_TOUCHSCREEN_SX8654 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_TOUCHSCREEN_ZET6223=m
CONFIG_TOUCHSCREEN_ZFORCE=m
CONFIG_TOUCHSCREEN_COLIBRI_VF50=m
CONFIG_TOUCHSCREEN_ROHM_BU21023=y
# CONFIG_INPUT_MISC is not set
CONFIG_RMI4_CORE=m
CONFIG_RMI4_I2C=m
CONFIG_RMI4_SMB=m
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=m
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y
CONFIG_RMI4_F34=y
# CONFIG_RMI4_F54 is not set
# CONFIG_RMI4_F55 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=m
# CONFIG_SERIO_CT82C710 is not set
CONFIG_SERIO_PARKBD=m
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_SERIO_APBPS2 is not set
CONFIG_SERIO_OLPC_APSP=y
# CONFIG_USERIO is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=m
CONFIG_GAMEPORT_EMU10K1=m
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
CONFIG_CYCLADES=y
# CONFIG_CYZ_INTR is not set
# CONFIG_MOXA_INTELLIO is not set
CONFIG_MOXA_SMARTIO=m
CONFIG_SYNCLINK=m
# CONFIG_SYNCLINKMP is not set
CONFIG_SYNCLINK_GT=m
# CONFIG_NOZOMI is not set
CONFIG_ISI=m
CONFIG_N_HDLC=y
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=m
CONFIG_TRACE_SINK=m
# CONFIG_DEVMEM is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_FINTEK=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
# CONFIG_SERIAL_8250_PCI is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
# CONFIG_SERIAL_8250_SHARE_IRQ is not set
CONFIG_SERIAL_8250_DETECT_IRQ=y
# CONFIG_SERIAL_8250_RSA is not set
# CONFIG_SERIAL_8250_FSL is not set
CONFIG_SERIAL_8250_DW=y
CONFIG_SERIAL_8250_RT288X=y
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
CONFIG_SERIAL_8250_MOXA=m
CONFIG_SERIAL_OF_PLATFORM=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_UARTLITE=m
CONFIG_SERIAL_UARTLITE_NR_UARTS=1
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=m
CONFIG_SERIAL_SC16IS7XX_CORE=m
CONFIG_SERIAL_SC16IS7XX=m
CONFIG_SERIAL_SC16IS7XX_I2C=y
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=m
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ALTERA_UART_CONSOLE=y
# CONFIG_SERIAL_PCH_UART is not set
CONFIG_SERIAL_XILINX_PS_UART=y
# CONFIG_SERIAL_XILINX_PS_UART_CONSOLE is not set
CONFIG_SERIAL_ARC=m
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=m
CONFIG_SERIAL_CONEXANT_DIGICOLOR=m
# CONFIG_SERIAL_DEV_BUS is not set
# CONFIG_PRINTER is not set
CONFIG_PPDEV=m
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=m
CONFIG_IPMI_PANIC_EVENT=y
# CONFIG_IPMI_PANIC_STRING is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
CONFIG_IPMI_SSIF=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=m
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
# CONFIG_HW_RANDOM_GEODE is not set
CONFIG_HW_RANDOM_VIA=m
CONFIG_HW_RANDOM_VIRTIO=m
CONFIG_NVRAM=y
# CONFIG_DTLK is not set
CONFIG_R3964=y
CONFIG_APPLICOM=y
# CONFIG_SONYPI is not set
CONFIG_MWAVE=y
# CONFIG_PC8736x_GPIO is not set
# CONFIG_NSC_GPIO is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_LTC4306=m
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=m
# CONFIG_I2C_MUX_REG is not set
CONFIG_I2C_MUX_MLXCPLD=y
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=m

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
# CONFIG_I2C_ALGOPCF is not set
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=m
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
# CONFIG_I2C_AMD756 is not set
CONFIG_I2C_AMD8111=m
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
CONFIG_I2C_ISMT=m
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=m
# CONFIG_I2C_NFORCE2_S4985 is not set
CONFIG_I2C_SIS5595=m
CONFIG_I2C_SIS630=m
# CONFIG_I2C_SIS96X is not set
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=m
CONFIG_I2C_DESIGNWARE_PCI=y
# CONFIG_I2C_DESIGNWARE_BAYTRAIL is not set
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_EMEV2=m
CONFIG_I2C_GPIO=y
CONFIG_I2C_KEMPLD=m
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=m
CONFIG_I2C_PXA=m
CONFIG_I2C_PXA_PCI=y
CONFIG_I2C_RK3X=m
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=m
CONFIG_I2C_TAOS_EVM=m

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_PCA_ISA=m
CONFIG_I2C_CROS_EC_TUNNEL=m
# CONFIG_SCx200_ACB is not set
CONFIG_I2C_STUB=m
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_SPMI is not set
CONFIG_HSI=m
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
CONFIG_HSI_CHAR=m

#
# PPS support
#
CONFIG_PPS=m
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=m
CONFIG_PPS_CLIENT_PARPORT=m
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=m
CONFIG_GPIOLIB=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=m
CONFIG_GPIO_MAX730X=m

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_74XX_MMIO=m
CONFIG_GPIO_ALTERA=y
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_FTGPIO010 is not set
CONFIG_GPIO_GENERIC_PLATFORM=m
CONFIG_GPIO_GRGPIO=m
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_LYNXPOINT is not set
# CONFIG_GPIO_MOCKUP is not set
CONFIG_GPIO_SYSCON=y
CONFIG_GPIO_VX855=m
CONFIG_GPIO_XILINX=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_104_DIO_48E=y
CONFIG_GPIO_104_IDIO_16=m
CONFIG_GPIO_104_IDI_48=m
CONFIG_GPIO_F7188X=m
# CONFIG_GPIO_GPIO_MM is not set
CONFIG_GPIO_IT87=y
CONFIG_GPIO_SCH=y
# CONFIG_GPIO_SCH311X is not set
CONFIG_GPIO_WS16C48=m

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=m
CONFIG_GPIO_ADNP=m
CONFIG_GPIO_MAX7300=m
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=m
CONFIG_GPIO_PCF857X=m
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#
CONFIG_GPIO_CS5535=m
CONFIG_GPIO_DA9052=m
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_JANZ_TTL=m
# CONFIG_GPIO_KEMPLD is not set
CONFIG_GPIO_LP873X=m
# CONFIG_GPIO_MAX77620 is not set
CONFIG_GPIO_PALMAS=y
CONFIG_GPIO_STMPE=y
# CONFIG_GPIO_TIMBERDALE is not set
CONFIG_GPIO_TPS65086=y
# CONFIG_GPIO_TPS65910 is not set
CONFIG_GPIO_TPS65912=m
CONFIG_GPIO_WM831X=m
# CONFIG_GPIO_WM8994 is not set

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=y
# CONFIG_GPIO_BT8XX is not set
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_PCH=y
CONFIG_GPIO_PCI_IDIO_16=m
# CONFIG_GPIO_RDC321X is not set
# CONFIG_GPIO_SODAVILLE is not set

#
# SPI or I2C GPIO expanders
#
# CONFIG_GPIO_MCP23S08 is not set
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=m
# CONFIG_W1_MASTER_DS2482 is not set
CONFIG_W1_MASTER_DS1WM=m
CONFIG_W1_MASTER_GPIO=m

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=m
CONFIG_W1_SLAVE_DS2405=y
CONFIG_W1_SLAVE_DS2408=m
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
# CONFIG_W1_SLAVE_DS2413 is not set
# CONFIG_W1_SLAVE_DS2406 is not set
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
# CONFIG_W1_SLAVE_DS2438 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
# CONFIG_W1_SLAVE_BQ27000 is not set
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_AS3722 is not set
CONFIG_POWER_RESET_GPIO=y
CONFIG_POWER_RESET_GPIO_RESTART=y
CONFIG_POWER_RESET_LTC2952=y
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_RESET_SYSCON=y
# CONFIG_POWER_RESET_SYSCON_POWEROFF is not set
# CONFIG_SYSCON_REBOOT_MODE is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_MAX8925_POWER=y
CONFIG_WM831X_BACKUP=m
# CONFIG_WM831X_POWER is not set
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=m
CONFIG_BATTERY_ACT8945A=m
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
CONFIG_BATTERY_LEGO_EV3=y
CONFIG_BATTERY_OLPC=m
CONFIG_BATTERY_SBS=m
# CONFIG_CHARGER_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
CONFIG_BATTERY_DA9052=m
CONFIG_BATTERY_DA9150=m
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
CONFIG_CHARGER_88PM860X=m
CONFIG_CHARGER_PCF50633=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_LP8727=y
# CONFIG_CHARGER_GPIO is not set
CONFIG_CHARGER_MANAGER=y
CONFIG_CHARGER_MAX14577=m
CONFIG_CHARGER_DETECTOR_MAX14656=m
CONFIG_CHARGER_MAX8997=m
CONFIG_CHARGER_MAX8998=m
CONFIG_CHARGER_BQ2415X=m
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24257=y
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
CONFIG_CHARGER_SMB347=m
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
CONFIG_BATTERY_RT5033=m
CONFIG_CHARGER_RT9455=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=m
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=y
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=m
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=m
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_APPLESMC=m
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ASPEED is not set
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=m
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=m
CONFIG_SENSORS_DA9055=m
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_MC13783_ADC=m
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_GL518SM=m
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_G760A=m
CONFIG_SENSORS_G762=m
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_IBMAEM is not set
CONFIG_SENSORS_IBMPEX=m
# CONFIG_SENSORS_IIO_HWMON is not set
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=m
# CONFIG_SENSORS_LTC2945 is not set
CONFIG_SENSORS_LTC2990=m
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=m
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=y
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=m
CONFIG_SENSORS_MAX6639=m
CONFIG_SENSORS_MAX6642=m
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_TC654=m
CONFIG_SENSORS_MENF21BMC_HWMON=m
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=m
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=m
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=m
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=m
CONFIG_SENSORS_NCT7802=y
CONFIG_SENSORS_NCT7904=y
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_PMBUS is not set
CONFIG_SENSORS_PWM_FAN=y
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=m
# CONFIG_SENSORS_SHT3x is not set
CONFIG_SENSORS_SHTC1=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=m
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=m
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_STTS751=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=m
# CONFIG_SENSORS_ADS1015 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_INA3221=y
# CONFIG_SENSORS_TC74 is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP108=m
CONFIG_SENSORS_TMP401=m
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=y
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_OF=y
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_MAX77620_THERMAL is not set
# CONFIG_QORIQ_THERMAL is not set
# CONFIG_DA9062_THERMAL is not set
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
# CONFIG_GENERIC_ADC_THERMAL is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
# CONFIG_SSB_PCIHOST is not set
# CONFIG_SSB_DEBUG is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
CONFIG_MFD_ACT8945A=m
CONFIG_MFD_AS3711=y
CONFIG_MFD_AS3722=y
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_ATMEL_FLEXCOM=m
# CONFIG_MFD_ATMEL_HLCDC is not set
CONFIG_MFD_BCM590XX=m
# CONFIG_MFD_AXP20X_I2C is not set
CONFIG_MFD_CROS_EC=m
CONFIG_MFD_CROS_EC_I2C=m
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9062=m
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_DA9150=m
CONFIG_MFD_MC13XXX=m
CONFIG_MFD_MC13XXX_I2C=m
# CONFIG_MFD_HI6421_PMIC is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
# CONFIG_INTEL_SOC_PMIC is not set
CONFIG_MFD_INTEL_LPSS=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
CONFIG_MFD_INTEL_LPSS_PCI=y
CONFIG_MFD_JANZ_CMODIO=m
CONFIG_MFD_KEMPLD=m
CONFIG_MFD_88PM800=m
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=m
CONFIG_MFD_MAX77620=y
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=m
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
# CONFIG_MFD_MT6397 is not set
CONFIG_MFD_MENF21BMC=y
# CONFIG_MFD_RETU is not set
CONFIG_MFD_PCF50633=y
# CONFIG_PCF50633_ADC is not set
# CONFIG_PCF50633_GPIO is not set
# CONFIG_UCB1400_CORE is not set
# CONFIG_MFD_RDC321X is not set
CONFIG_MFD_RTSX_PCI=y
CONFIG_MFD_RT5033=m
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_RK808=m
# CONFIG_MFD_RN5T618 is not set
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=m
CONFIG_MFD_SM501=m
CONFIG_MFD_SM501_GPIO=y
CONFIG_MFD_SKY81452=m
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
CONFIG_STMPE_I2C=y
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_TI_LMU=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=m
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=m
CONFIG_MFD_TPS65086=y
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
CONFIG_MFD_TI_LP873X=m
# CONFIG_MFD_TPS65218 is not set
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=m
CONFIG_MFD_TPS65912_I2C=m
CONFIG_MFD_TPS80031=y
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=m
CONFIG_MFD_LM3533=m
CONFIG_MFD_TIMBERDALE=m
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=m
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=m
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PM800=m
# CONFIG_REGULATOR_88PM8607 is not set
# CONFIG_REGULATOR_ACT8865 is not set
# CONFIG_REGULATOR_ACT8945A is not set
# CONFIG_REGULATOR_AD5398 is not set
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AS3711=y
# CONFIG_REGULATOR_AS3722 is not set
# CONFIG_REGULATOR_BCM590XX is not set
CONFIG_REGULATOR_DA9052=y
CONFIG_REGULATOR_DA9055=y
# CONFIG_REGULATOR_DA9062 is not set
CONFIG_REGULATOR_DA9210=m
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_ISL9305=y
CONFIG_REGULATOR_ISL6271A=y
# CONFIG_REGULATOR_LM363X is not set
CONFIG_REGULATOR_LP3971=m
CONFIG_REGULATOR_LP3972=m
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP873X=m
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LTC3589=m
CONFIG_REGULATOR_LTC3676=m
CONFIG_REGULATOR_MAX14577=m
CONFIG_REGULATOR_MAX1586=m
# CONFIG_REGULATOR_MAX77620 is not set
CONFIG_REGULATOR_MAX8649=m
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8907 is not set
# CONFIG_REGULATOR_MAX8925 is not set
# CONFIG_REGULATOR_MAX8952 is not set
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8997=m
CONFIG_REGULATOR_MAX8998=m
CONFIG_REGULATOR_MC13XXX_CORE=m
CONFIG_REGULATOR_MC13783=m
CONFIG_REGULATOR_MC13892=m
CONFIG_REGULATOR_MT6311=m
CONFIG_REGULATOR_PALMAS=m
CONFIG_REGULATOR_PCF50633=m
CONFIG_REGULATOR_PFUZE100=m
CONFIG_REGULATOR_PV88060=m
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=m
CONFIG_REGULATOR_PWM=m
CONFIG_REGULATOR_RK808=m
CONFIG_REGULATOR_RT5033=m
# CONFIG_REGULATOR_SKY81452 is not set
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=m
CONFIG_REGULATOR_TPS62360=m
CONFIG_REGULATOR_TPS65023=m
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65086=m
CONFIG_REGULATOR_TPS65132=m
CONFIG_REGULATOR_TPS65910=m
CONFIG_REGULATOR_TPS65912=m
# CONFIG_REGULATOR_TPS80031 is not set
CONFIG_REGULATOR_VCTRL=m
CONFIG_REGULATOR_WM831X=m
# CONFIG_REGULATOR_WM8400 is not set
CONFIG_REGULATOR_WM8994=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
CONFIG_MEDIA_SDR_SUPPORT=y
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_MEDIA_CEC_SUPPORT=y
CONFIG_CEC_CORE=y
# CONFIG_MEDIA_CEC_DEBUG is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
# CONFIG_VIDEO_PCI_SKELETON is not set
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=y
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
CONFIG_V4L_MEM2MEM_DRIVERS=y
CONFIG_VIDEO_MEM2MEM_DEINTERLACE=m
CONFIG_VIDEO_SH_VEU=y
# CONFIG_V4L_TEST_DRIVERS is not set
CONFIG_CEC_PLATFORM_DRIVERS=y

#
# Supported MMC/SDIO adapters
#
# CONFIG_RADIO_ADAPTERS is not set

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
CONFIG_MEDIA_ATTACH=y

#
# I2C Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=y
CONFIG_VIDEO_TDA7432=y
CONFIG_VIDEO_TDA9840=y
CONFIG_VIDEO_TEA6415C=y
CONFIG_VIDEO_TEA6420=y
CONFIG_VIDEO_MSP3400=m
# CONFIG_VIDEO_CS3308 is not set
# CONFIG_VIDEO_CS5345 is not set
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_TLV320AIC23B=m
CONFIG_VIDEO_UDA1342=m
CONFIG_VIDEO_WM8775=m
# CONFIG_VIDEO_WM8739 is not set
CONFIG_VIDEO_VP27SMPX=y
# CONFIG_VIDEO_SONY_BTF_MPX is not set

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=y

#
# Video decoders
#
CONFIG_VIDEO_ADV7183=y
# CONFIG_VIDEO_BT819 is not set
CONFIG_VIDEO_BT856=m
# CONFIG_VIDEO_BT866 is not set
CONFIG_VIDEO_KS0127=y
CONFIG_VIDEO_ML86V7667=m
# CONFIG_VIDEO_SAA7110 is not set
CONFIG_VIDEO_SAA711X=y
# CONFIG_VIDEO_TVP514X is not set
CONFIG_VIDEO_TVP5150=m
CONFIG_VIDEO_TVP7002=y
# CONFIG_VIDEO_TW2804 is not set
# CONFIG_VIDEO_TW9903 is not set
CONFIG_VIDEO_TW9906=m
# CONFIG_VIDEO_VPX3220 is not set

#
# Video and audio decoders
#
# CONFIG_VIDEO_SAA717X is not set
CONFIG_VIDEO_CX25840=m

#
# Video encoders
#
# CONFIG_VIDEO_SAA7127 is not set
# CONFIG_VIDEO_SAA7185 is not set
CONFIG_VIDEO_ADV7170=y
# CONFIG_VIDEO_ADV7175 is not set
CONFIG_VIDEO_ADV7343=y
CONFIG_VIDEO_ADV7393=y
# CONFIG_VIDEO_AK881X is not set
# CONFIG_VIDEO_THS8200 is not set

#
# Camera sensor devices
#
CONFIG_VIDEO_OV2640=y
CONFIG_VIDEO_OV2659=y
CONFIG_VIDEO_OV7640=m
# CONFIG_VIDEO_OV7670 is not set
# CONFIG_VIDEO_VS6624 is not set
CONFIG_VIDEO_MT9M111=m
CONFIG_VIDEO_MT9V011=m
CONFIG_VIDEO_SR030PC30=y

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
CONFIG_VIDEO_UPD64083=m

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=y

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=y
CONFIG_VIDEO_M52790=m

#
# Sensors used on soc_camera driver
#

#
# SPI helper chips
#
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
CONFIG_MEDIA_TUNER_SIMPLE=m
# CONFIG_MEDIA_TUNER_TDA8290 is not set
CONFIG_MEDIA_TUNER_TDA827X=m
# CONFIG_MEDIA_TUNER_TDA18271 is not set
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_MT2060=m
# CONFIG_MEDIA_TUNER_MT2063 is not set
# CONFIG_MEDIA_TUNER_MT2266 is not set
CONFIG_MEDIA_TUNER_MT2131=m
# CONFIG_MEDIA_TUNER_QT1010 is not set
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
# CONFIG_MEDIA_TUNER_XC4000 is not set
CONFIG_MEDIA_TUNER_MXL5005S=y
# CONFIG_MEDIA_TUNER_MXL5007T is not set
# CONFIG_MEDIA_TUNER_MC44S803 is not set
CONFIG_MEDIA_TUNER_MAX2165=m
CONFIG_MEDIA_TUNER_TDA18218=m
# CONFIG_MEDIA_TUNER_FC0011 is not set
CONFIG_MEDIA_TUNER_FC0012=m
# CONFIG_MEDIA_TUNER_FC0013 is not set
# CONFIG_MEDIA_TUNER_TDA18212 is not set
CONFIG_MEDIA_TUNER_E4000=m
CONFIG_MEDIA_TUNER_FC2580=y
# CONFIG_MEDIA_TUNER_M88RS6000T is not set
# CONFIG_MEDIA_TUNER_TUA9001 is not set
# CONFIG_MEDIA_TUNER_SI2157 is not set
CONFIG_MEDIA_TUNER_IT913X=m
CONFIG_MEDIA_TUNER_R820T=y
CONFIG_MEDIA_TUNER_MXL301RF=y
CONFIG_MEDIA_TUNER_QM1D1C0042=m

#
# Customise DVB Frontends
#

#
# Tools to develop new frontends
#

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=m
CONFIG_DRM_DP_AUX_CHARDEV=y
# CONFIG_DRM_DEBUG_MM_SELFTEST is not set
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=m
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_VM=y

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
CONFIG_DRM_I2C_SIL164=m
CONFIG_DRM_I2C_NXP_TDA998X=m
CONFIG_DRM_RADEON=m
CONFIG_DRM_RADEON_USERPTR=y
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
CONFIG_DRM_VGEM=m
CONFIG_DRM_VMWGFX=m
# CONFIG_DRM_VMWGFX_FBCON is not set
CONFIG_DRM_GMA500=m
CONFIG_DRM_GMA600=y
CONFIG_DRM_GMA3600=y
# CONFIG_DRM_UDL is not set
CONFIG_DRM_AST=m
CONFIG_DRM_MGAG200=m
CONFIG_DRM_CIRRUS_QEMU=m
CONFIG_DRM_RCAR_DW_HDMI=m
# CONFIG_DRM_QXL is not set
CONFIG_DRM_BOCHS=m
CONFIG_DRM_VIRTIO_GPU=m
CONFIG_DRM_PANEL=y

#
# Display Panels
#
# CONFIG_DRM_PANEL_LVDS is not set
CONFIG_DRM_PANEL_SIMPLE=m
# CONFIG_DRM_PANEL_SAMSUNG_S6E8AA0 is not set
CONFIG_DRM_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
CONFIG_DRM_DUMB_VGA_DAC=m
CONFIG_DRM_LVDS_ENCODER=m
# CONFIG_DRM_MEGACHIPS_STDPXXXX_GE_B850V3_FW is not set
CONFIG_DRM_NXP_PTN3460=m
CONFIG_DRM_PARADE_PS8622=m
# CONFIG_DRM_SIL_SII8620 is not set
CONFIG_DRM_SII902X=m
CONFIG_DRM_TOSHIBA_TC358767=m
CONFIG_DRM_TI_TFP410=m
# CONFIG_DRM_I2C_ADV7511 is not set
CONFIG_DRM_DW_HDMI=m
CONFIG_DRM_DW_HDMI_AHB_AUDIO=m
CONFIG_DRM_DW_HDMI_I2S_AUDIO=m
CONFIG_DRM_ARCPGU=m
CONFIG_DRM_HISI_HIBMC=m
CONFIG_DRM_MXS=y
CONFIG_DRM_MXSFB=m
# CONFIG_DRM_TINYDRM is not set
CONFIG_DRM_LEGACY=y
# CONFIG_DRM_TDFX is not set
CONFIG_DRM_R128=m
CONFIG_DRM_MGA=m
# CONFIG_DRM_VIA is not set
CONFIG_DRM_SAVAGE=m
# CONFIG_DRM_LIB_RANDOM is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_PROVIDE_GET_FB_UNMAPPED_AREA is not set
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
CONFIG_FB_BIG_ENDIAN=y
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
CONFIG_FB_PM2=m
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=m
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=m
CONFIG_FB_NVIDIA=m
# CONFIG_FB_NVIDIA_I2C is not set
CONFIG_FB_NVIDIA_DEBUG=y
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
# CONFIG_FB_RIVA is not set
CONFIG_FB_I740=m
CONFIG_FB_LE80578=m
# CONFIG_FB_CARILLO_RANCH is not set
CONFIG_FB_MATROX=m
# CONFIG_FB_MATROX_MILLENIUM is not set
# CONFIG_FB_MATROX_MYSTIQUE is not set
CONFIG_FB_MATROX_G=y
# CONFIG_FB_MATROX_I2C is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
CONFIG_FB_ATY=m
CONFIG_FB_ATY_CT=y
# CONFIG_FB_ATY_GENERIC_LCD is not set
# CONFIG_FB_ATY_GX is not set
CONFIG_FB_ATY_BACKLIGHT=y
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=m
CONFIG_FB_SIS_300=y
# CONFIG_FB_SIS_315 is not set
CONFIG_FB_VIA=y
CONFIG_FB_VIA_DIRECT_PROCFS=y
CONFIG_FB_VIA_X_COMPATIBILITY=y
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
# CONFIG_FB_3DFX_I2C is not set
CONFIG_FB_VOODOO1=m
CONFIG_FB_VT8623=y
# CONFIG_FB_TRIDENT is not set
CONFIG_FB_ARK=y
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=m
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
CONFIG_FB_GEODE=y
# CONFIG_FB_GEODE_LX is not set
CONFIG_FB_GEODE_GX=y
CONFIG_FB_GEODE_GX1=y
# CONFIG_FB_SM501 is not set
# CONFIG_FB_IBM_GXT4500 is not set
CONFIG_FB_VIRTUAL=m
CONFIG_FB_METRONOME=m
CONFIG_FB_MB862XX=m
CONFIG_FB_MB862XX_PCI_GDC=y
# CONFIG_FB_MB862XX_I2C is not set
CONFIG_FB_BROADSHEET=m
CONFIG_FB_AUO_K190X=m
CONFIG_FB_AUO_K1900=m
# CONFIG_FB_AUO_K1901 is not set
# CONFIG_FB_SIMPLE is not set
# CONFIG_FB_SSD1307 is not set
CONFIG_FB_SM712=m
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
# CONFIG_BACKLIGHT_LM3533 is not set
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_MAX8925=m
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=m
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=m
CONFIG_BACKLIGHT_88PM860X=m
CONFIG_BACKLIGHT_PCF50633=y
# CONFIG_BACKLIGHT_LM3630A is not set
CONFIG_BACKLIGHT_LM3639=m
# CONFIG_BACKLIGHT_LP855X is not set
CONFIG_BACKLIGHT_SKY81452=m
# CONFIG_BACKLIGHT_AS3711 is not set
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=m
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_BACKLIGHT_ARCXCNN is not set
CONFIG_VGASTATE=y
CONFIG_VIDEOMODE_HELPERS=y
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
# CONFIG_VGACON_SOFT_SCROLLBACK_PERSISTENT_ENABLE_BY_DEFAULT is not set
CONFIG_MDA_CONSOLE=y
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_FRAMEBUFFER_CONSOLE=m
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
# CONFIG_LOGO is not set
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_PCM_ELD=y
CONFIG_SND_PCM_IEC958=y
CONFIG_SND_DMAENGINE_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
# CONFIG_SND_SEQUENCER is not set
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=m
# CONFIG_SND_PCM_OSS is not set
CONFIG_SND_PCM_TIMER=y
# CONFIG_SND_DYNAMIC_MINORS is not set
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_RAWMIDI_SEQ is not set
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_MPU401_UART=m
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_OPL4_LIB=m
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_DUMMY=m
CONFIG_SND_ALOOP=m
# CONFIG_SND_MTPAV is not set
# CONFIG_SND_MTS64 is not set
CONFIG_SND_SERIAL_U16550=m
CONFIG_SND_MPU401=m
CONFIG_SND_PORTMAN2X4=m
# CONFIG_SND_AC97_POWER_SAVE is not set
CONFIG_SND_WSS_LIB=m
CONFIG_SND_SB_COMMON=m
CONFIG_SND_SB8_DSP=m
CONFIG_SND_SB16_DSP=m
CONFIG_SND_ISA=y
CONFIG_SND_ADLIB=m
# CONFIG_SND_AD1816A is not set
CONFIG_SND_AD1848=m
# CONFIG_SND_ALS100 is not set
CONFIG_SND_AZT1605=m
CONFIG_SND_AZT2316=m
# CONFIG_SND_AZT2320 is not set
CONFIG_SND_CMI8328=m
CONFIG_SND_CMI8330=m
CONFIG_SND_CS4231=m
CONFIG_SND_CS4236=m
# CONFIG_SND_ES1688 is not set
CONFIG_SND_ES18XX=m
CONFIG_SND_SC6000=m
CONFIG_SND_GUSCLASSIC=m
CONFIG_SND_GUSEXTREME=m
CONFIG_SND_GUSMAX=m
# CONFIG_SND_INTERWAVE is not set
# CONFIG_SND_INTERWAVE_STB is not set
CONFIG_SND_JAZZ16=m
CONFIG_SND_OPL3SA2=m
CONFIG_SND_OPTI92X_AD1848=m
CONFIG_SND_OPTI92X_CS4231=m
CONFIG_SND_OPTI93X=m
CONFIG_SND_MIRO=m
CONFIG_SND_SB8=m
CONFIG_SND_SB16=m
# CONFIG_SND_SBAWE is not set
CONFIG_SND_SB16_CSP=y
CONFIG_SND_SSCAPE=m
# CONFIG_SND_WAVEFRONT is not set
CONFIG_SND_MSND_PINNACLE=m
# CONFIG_SND_MSND_CLASSIC is not set
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=m
CONFIG_SND_ALS300=m
CONFIG_SND_ALS4000=m
CONFIG_SND_ALI5451=m
CONFIG_SND_ASIHPI=m
CONFIG_SND_ATIIXP=m
CONFIG_SND_ATIIXP_MODEM=m
# CONFIG_SND_AU8810 is not set
CONFIG_SND_AU8820=m
# CONFIG_SND_AU8830 is not set
CONFIG_SND_AW2=m
CONFIG_SND_AZT3328=m
CONFIG_SND_BT87X=m
CONFIG_SND_BT87X_OVERCLOCK=y
CONFIG_SND_CA0106=m
# CONFIG_SND_CMIPCI is not set
CONFIG_SND_OXYGEN_LIB=m
CONFIG_SND_OXYGEN=m
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
CONFIG_SND_CS5530=m
CONFIG_SND_CS5535AUDIO=m
CONFIG_SND_CTXFI=m
CONFIG_SND_DARLA20=m
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
CONFIG_SND_MIA=m
CONFIG_SND_ECHO3G=m
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=m
CONFIG_SND_INDIGODJ=m
CONFIG_SND_INDIGOIOX=m
CONFIG_SND_INDIGODJX=m
# CONFIG_SND_EMU10K1 is not set
CONFIG_SND_EMU10K1X=m
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
CONFIG_SND_FM801=m
# CONFIG_SND_FM801_TEA575X_BOOL is not set
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=m
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
CONFIG_SND_INTEL8X0=m
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
CONFIG_SND_LOLA=m
CONFIG_SND_LX6464ES=m
# CONFIG_SND_MAESTRO3 is not set
CONFIG_SND_MIXART=m
# CONFIG_SND_NM256 is not set
CONFIG_SND_PCXHR=m
CONFIG_SND_RIPTIDE=m
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
# CONFIG_SND_SIS7019 is not set
CONFIG_SND_SONICVIBES=m
CONFIG_SND_TRIDENT=m
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
CONFIG_SND_VIRTUOSO=m
CONFIG_SND_VX222=m
CONFIG_SND_YMFPCI=m

#
# HD-Audio
#
CONFIG_SND_HDA=m
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_RECONFIG=y
# CONFIG_SND_HDA_INPUT_BEEP is not set
CONFIG_SND_HDA_PATCH_LOADER=y
CONFIG_SND_HDA_CODEC_REALTEK=m
CONFIG_SND_HDA_CODEC_ANALOG=m
CONFIG_SND_HDA_CODEC_SIGMATEL=m
# CONFIG_SND_HDA_CODEC_VIA is not set
# CONFIG_SND_HDA_CODEC_HDMI is not set
# CONFIG_SND_HDA_CODEC_CIRRUS is not set
CONFIG_SND_HDA_CODEC_CONEXANT=m
CONFIG_SND_HDA_CODEC_CA0110=m
CONFIG_SND_HDA_CODEC_CA0132=m
# CONFIG_SND_HDA_CODEC_CA0132_DSP is not set
# CONFIG_SND_HDA_CODEC_CMEDIA is not set
CONFIG_SND_HDA_CODEC_SI3054=m
CONFIG_SND_HDA_GENERIC=m
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDA_CORE=m
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=m
CONFIG_SND_DICE=m
CONFIG_SND_OXFW=m
CONFIG_SND_ISIGHT=m
CONFIG_SND_FIREWORKS=m
CONFIG_SND_BEBOB=m
CONFIG_SND_FIREWIRE_DIGI00X=m
# CONFIG_SND_FIREWIRE_TASCAM is not set
CONFIG_SND_FIREWIRE_MOTU=m
CONFIG_SND_FIREFACE=m
CONFIG_SND_SOC=m
CONFIG_SND_SOC_AC97_BUS=y
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
# CONFIG_SND_SOC_AMD_ACP is not set
CONFIG_SND_ATMEL_SOC=m
CONFIG_SND_DESIGNWARE_I2S=m
# CONFIG_SND_DESIGNWARE_PCM is not set

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
# CONFIG_SND_SOC_FSL_ASRC is not set
CONFIG_SND_SOC_FSL_SAI=m
CONFIG_SND_SOC_FSL_SSI=m
CONFIG_SND_SOC_FSL_SPDIF=m
CONFIG_SND_SOC_FSL_ESAI=m
CONFIG_SND_SOC_IMX_AUDMUX=m
CONFIG_SND_I2S_HI6210_I2S=m
CONFIG_SND_SOC_IMG=y
# CONFIG_SND_SOC_IMG_I2S_IN is not set
CONFIG_SND_SOC_IMG_I2S_OUT=m
CONFIG_SND_SOC_IMG_PARALLEL_OUT=m
CONFIG_SND_SOC_IMG_SPDIF_IN=m
CONFIG_SND_SOC_IMG_SPDIF_OUT=m
# CONFIG_SND_SOC_IMG_PISTACHIO_INTERNAL_DAC is not set
# CONFIG_SND_SOC_INTEL_BXT_DA7219_MAX98357A_MACH is not set
# CONFIG_SND_SOC_INTEL_BXT_RT298_MACH is not set
# CONFIG_SND_SOC_INTEL_BYTCR_RT5640_MACH is not set
# CONFIG_SND_SOC_INTEL_BYTCR_RT5651_MACH is not set
# CONFIG_SND_SOC_INTEL_SKL_RT286_MACH is not set
CONFIG_SND_SOC_XTFPGA_I2S=m
CONFIG_ZX_TDM=m
CONFIG_SND_SOC_I2C_AND_SPI=m

#
# CODEC drivers
#
CONFIG_SND_SOC_AC97_CODEC=m
CONFIG_SND_SOC_ADAU_UTILS=m
CONFIG_SND_SOC_ADAU1701=m
CONFIG_SND_SOC_ADAU17X1=m
CONFIG_SND_SOC_ADAU1761=m
CONFIG_SND_SOC_ADAU1761_I2C=m
CONFIG_SND_SOC_ADAU7002=m
CONFIG_SND_SOC_AK4554=m
CONFIG_SND_SOC_AK4613=m
CONFIG_SND_SOC_AK4642=m
CONFIG_SND_SOC_AK5386=m
CONFIG_SND_SOC_ALC5623=m
CONFIG_SND_SOC_BT_SCO=m
CONFIG_SND_SOC_CS35L32=m
CONFIG_SND_SOC_CS35L33=m
CONFIG_SND_SOC_CS35L34=m
CONFIG_SND_SOC_CS35L35=m
CONFIG_SND_SOC_CS42L42=m
CONFIG_SND_SOC_CS42L51=m
CONFIG_SND_SOC_CS42L51_I2C=m
CONFIG_SND_SOC_CS42L52=m
CONFIG_SND_SOC_CS42L56=m
CONFIG_SND_SOC_CS42L73=m
CONFIG_SND_SOC_CS4265=m
CONFIG_SND_SOC_CS4270=m
CONFIG_SND_SOC_CS4271=m
CONFIG_SND_SOC_CS4271_I2C=m
CONFIG_SND_SOC_CS42XX8=m
CONFIG_SND_SOC_CS42XX8_I2C=m
CONFIG_SND_SOC_CS4349=m
CONFIG_SND_SOC_CS53L30=m
CONFIG_SND_SOC_DIO2125=m
CONFIG_SND_SOC_HDMI_CODEC=m
CONFIG_SND_SOC_ES7134=m
CONFIG_SND_SOC_ES8328=m
CONFIG_SND_SOC_ES8328_I2C=m
CONFIG_SND_SOC_GTM601=m
CONFIG_SND_SOC_INNO_RK3036=m
CONFIG_SND_SOC_MAX98504=m
CONFIG_SND_SOC_MAX98927=m
CONFIG_SND_SOC_MAX9860=m
# CONFIG_SND_SOC_MSM8916_WCD_DIGITAL is not set
CONFIG_SND_SOC_PCM1681=m
CONFIG_SND_SOC_PCM179X=m
CONFIG_SND_SOC_PCM179X_I2C=m
CONFIG_SND_SOC_PCM3168A=m
CONFIG_SND_SOC_PCM3168A_I2C=m
CONFIG_SND_SOC_PCM512x=m
CONFIG_SND_SOC_PCM512x_I2C=m
CONFIG_SND_SOC_RL6231=m
CONFIG_SND_SOC_RT5616=m
CONFIG_SND_SOC_RT5631=m
# CONFIG_SND_SOC_RT5677_SPI is not set
CONFIG_SND_SOC_SGTL5000=m
CONFIG_SND_SOC_SIGMADSP=m
CONFIG_SND_SOC_SIGMADSP_I2C=m
CONFIG_SND_SOC_SIGMADSP_REGMAP=m
CONFIG_SND_SOC_SIRF_AUDIO_CODEC=m
CONFIG_SND_SOC_SPDIF=m
CONFIG_SND_SOC_SSM2602=m
CONFIG_SND_SOC_SSM2602_I2C=m
CONFIG_SND_SOC_SSM4567=m
CONFIG_SND_SOC_STA32X=m
CONFIG_SND_SOC_STA350=m
CONFIG_SND_SOC_STI_SAS=m
CONFIG_SND_SOC_TAS2552=m
CONFIG_SND_SOC_TAS5086=m
CONFIG_SND_SOC_TAS571X=m
CONFIG_SND_SOC_TAS5720=m
CONFIG_SND_SOC_TFA9879=m
CONFIG_SND_SOC_TLV320AIC23=m
CONFIG_SND_SOC_TLV320AIC23_I2C=m
CONFIG_SND_SOC_TLV320AIC31XX=m
CONFIG_SND_SOC_TLV320AIC3X=m
CONFIG_SND_SOC_TS3A227E=m
CONFIG_SND_SOC_WM8510=m
CONFIG_SND_SOC_WM8523=m
CONFIG_SND_SOC_WM8580=m
CONFIG_SND_SOC_WM8711=m
CONFIG_SND_SOC_WM8728=m
CONFIG_SND_SOC_WM8731=m
CONFIG_SND_SOC_WM8737=m
CONFIG_SND_SOC_WM8741=m
CONFIG_SND_SOC_WM8750=m
CONFIG_SND_SOC_WM8753=m
CONFIG_SND_SOC_WM8776=m
CONFIG_SND_SOC_WM8804=m
CONFIG_SND_SOC_WM8804_I2C=m
CONFIG_SND_SOC_WM8903=m
CONFIG_SND_SOC_WM8960=m
CONFIG_SND_SOC_WM8962=m
CONFIG_SND_SOC_WM8974=m
CONFIG_SND_SOC_WM8978=m
CONFIG_SND_SOC_WM8985=m
CONFIG_SND_SOC_NAU8540=m
CONFIG_SND_SOC_NAU8810=m
CONFIG_SND_SOC_NAU8824=m
CONFIG_SND_SOC_TPA6130A2=m
CONFIG_SND_SIMPLE_CARD_UTILS=m
CONFIG_SND_SIMPLE_CARD=m
CONFIG_SND_SIMPLE_SCU_CARD=m
CONFIG_SND_X86=y
CONFIG_AC97_BUS=m

#
# HID support
#
CONFIG_HID=m
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=m

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
CONFIG_HID_ACRUX=m
CONFIG_HID_ACRUX_FF=y
# CONFIG_HID_APPLE is not set
CONFIG_HID_ASUS=m
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=m
CONFIG_HID_CHERRY=m
# CONFIG_HID_CHICONY is not set
CONFIG_HID_PRODIKEYS=m
CONFIG_HID_CMEDIA=m
# CONFIG_HID_CYPRESS is not set
CONFIG_HID_DRAGONRISE=m
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=m
CONFIG_HID_ELECOM=m
CONFIG_HID_EZKEY=m
CONFIG_HID_GEMBIRD=m
CONFIG_HID_GFRM=m
CONFIG_HID_KEYTOUCH=m
CONFIG_HID_KYE=m
CONFIG_HID_WALTOP=m
CONFIG_HID_GYRATION=m
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
CONFIG_HID_LCPOWER=m
CONFIG_HID_LED=m
CONFIG_HID_LENOVO=m
CONFIG_HID_LOGITECH=m
CONFIG_HID_LOGITECH_DJ=m
CONFIG_HID_LOGITECH_HIDPP=m
CONFIG_LOGITECH_FF=y
CONFIG_LOGIRUMBLEPAD2_FF=y
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MAYFLASH is not set
CONFIG_HID_MICROSOFT=m
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTI=m
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=m
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PLANTRONICS=m
CONFIG_HID_PRIMAX=m
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=m
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_STEELSERIES=m
CONFIG_HID_SUNPLUS=m
CONFIG_HID_RMI=m
CONFIG_HID_GREENASIA=m
# CONFIG_GREENASIA_FF is not set
# CONFIG_HID_SMARTJOYPLUS is not set
CONFIG_HID_TIVO=m
CONFIG_HID_TOPSEED=m
CONFIG_HID_THINGM=m
CONFIG_HID_THRUSTMASTER=m
CONFIG_THRUSTMASTER_FF=y
# CONFIG_HID_UDRAW_PS3 is not set
CONFIG_HID_WACOM=m
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
CONFIG_HID_ZYDACRON=m
CONFIG_HID_SENSOR_HUB=m
CONFIG_HID_SENSOR_CUSTOM_SENSOR=m
CONFIG_HID_ALPS=m

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
CONFIG_USB_PCI=y

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_GADGET is not set

#
# USB Power Delivery and Type-C drivers
#
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
# CONFIG_UWB is not set
CONFIG_MMC=m
# CONFIG_MMC_DEBUG is not set
CONFIG_PWRSEQ_EMMC=m
CONFIG_PWRSEQ_SD8787=m
CONFIG_PWRSEQ_SIMPLE=m
# CONFIG_MMC_BLOCK is not set
CONFIG_SDIO_UART=m
CONFIG_MMC_TEST=m

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
CONFIG_MMC_WBSD=m
CONFIG_MMC_TIFM_SD=m
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_USDHI6ROL0=m
# CONFIG_MMC_REALTEK_PCI is not set
# CONFIG_MMC_TOSHIBA_PCI is not set
CONFIG_MMC_MTK=m
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y
# CONFIG_MSPRO_BLOCK is not set
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
CONFIG_MEMSTICK_JMICRON_38X=y
CONFIG_MEMSTICK_R592=y
CONFIG_MEMSTICK_REALTEK_PCI=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=m
CONFIG_LEDS_CLASS_FLASH=m
CONFIG_LEDS_BRIGHTNESS_HW_CHANGED=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=m
CONFIG_LEDS_BCM6328=m
CONFIG_LEDS_BCM6358=m
CONFIG_LEDS_LM3530=m
CONFIG_LEDS_LM3533=m
CONFIG_LEDS_LM3642=m
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=m
CONFIG_LEDS_LP3944=m
CONFIG_LEDS_LP3952=m
CONFIG_LEDS_LP55XX_COMMON=m
CONFIG_LEDS_LP5521=m
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_LP5562=m
CONFIG_LEDS_LP8501=m
CONFIG_LEDS_LP8860=m
CONFIG_LEDS_CLEVO_MAIL=m
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
CONFIG_LEDS_WM831X_STATUS=m
CONFIG_LEDS_DA9052=m
# CONFIG_LEDS_PWM is not set
CONFIG_LEDS_REGULATOR=m
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_INTEL_SS4200=m
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_MC13783 is not set
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_TLC591XX=m
CONFIG_LEDS_MAX8997=m
CONFIG_LEDS_LM355x=m
# CONFIG_LEDS_OT200 is not set
# CONFIG_LEDS_MENF21BMC is not set
CONFIG_LEDS_KTD2692=m
# CONFIG_LEDS_IS31FL319X is not set
CONFIG_LEDS_IS31FL32XX=m

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=m
CONFIG_LEDS_USER=m
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_DISK=y
CONFIG_LEDS_TRIGGER_MTD=y
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=m
CONFIG_LEDS_TRIGGER_CAMERA=m
# CONFIG_LEDS_TRIGGER_PANIC is not set
CONFIG_ACCESSIBILITY=y
# CONFIG_A11Y_BRAILLE_CONSOLE is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=m
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_AMD76X=m
# CONFIG_EDAC_E7XXX is not set
CONFIG_EDAC_E752X=m
CONFIG_EDAC_I82875P=m
# CONFIG_EDAC_I82975X is not set
CONFIG_EDAC_I3000=m
# CONFIG_EDAC_I3200 is not set
CONFIG_EDAC_IE31200=m
CONFIG_EDAC_X38=m
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I82860 is not set
CONFIG_EDAC_R82600=m
# CONFIG_EDAC_I5000 is not set
CONFIG_EDAC_I5100=m
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
CONFIG_DMADEVICES_VDEBUG=y

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y
CONFIG_FSL_EDMA=m
CONFIG_INTEL_IDMA64=m
CONFIG_PCH_DMA=m
CONFIG_TIMB_DMA=m
CONFIG_QCOM_HIDMA_MGMT=m
CONFIG_QCOM_HIDMA=m
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=m
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=m
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
# CONFIG_AUXDISPLAY is not set
CONFIG_CHARLCD=m
CONFIG_PANEL=m
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
CONFIG_UIO=m
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=m
CONFIG_UIO_DMEM_GENIRQ=m
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
CONFIG_UIO_PCI_GENERIC=m
CONFIG_UIO_NETX=m
CONFIG_UIO_PRUSS=m
CONFIG_UIO_MF624=m
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=m
# CONFIG_VIRTIO_PCI_LEGACY is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_HYPERV_TSCPAGE is not set
CONFIG_STAGING=y
CONFIG_COMEDI=y
CONFIG_COMEDI_DEBUG=y
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
# CONFIG_COMEDI_MISC_DRIVERS is not set
# CONFIG_COMEDI_ISA_DRIVERS is not set
# CONFIG_COMEDI_PCI_DRIVERS is not set
# CONFIG_COMEDI_8255_SA is not set
CONFIG_COMEDI_KCOMEDILIB=m
CONFIG_FB_OLPC_DCON=m
# CONFIG_FB_OLPC_DCON_1 is not set
CONFIG_FB_OLPC_DCON_1_5=y
# CONFIG_RTS5208 is not set

#
# IIO staging drivers
#

#
# Accelerometers
#

#
# Analog to digital converters
#
CONFIG_AD7606=y
CONFIG_AD7606_IFACE_PARALLEL=y

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
# CONFIG_ADT7316_I2C is not set

#
# Capacitance to digital converters
#
# CONFIG_AD7150 is not set
CONFIG_AD7152=y
CONFIG_AD7746=m

#
# Direct Digital Synthesis
#

#
# Digital gyroscope sensors
#

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=m

#
# Light sensors
#
CONFIG_SENSORS_ISL29028=m
# CONFIG_TSL2x7x is not set

#
# Active energy metering IC
#
# CONFIG_ADE7854 is not set

#
# Resolver to digital converters
#

#
# Triggers - standalone
#
# CONFIG_FB_SM750 is not set
CONFIG_FB_XGI=m

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
CONFIG_STAGING_BOARD=y
# CONFIG_FIREWIRE_SERIAL is not set
CONFIG_DGNC=y
CONFIG_GS_FPGABOOT=m
CONFIG_COMMON_CLK_XLNX_CLKWZRD=m
CONFIG_MOST=m
CONFIG_MOSTCORE=m
CONFIG_AIM_CDEV=m
# CONFIG_AIM_NETWORK is not set
CONFIG_AIM_SOUND=m
# CONFIG_AIM_V4L2 is not set
CONFIG_HDM_I2C=m
# CONFIG_KS7010 is not set
CONFIG_GREYBUS=m
CONFIG_GREYBUS_AUDIO=m
# CONFIG_GREYBUS_BOOTROM is not set
# CONFIG_GREYBUS_HID is not set
CONFIG_GREYBUS_LIGHT=m
# CONFIG_GREYBUS_LOG is not set
CONFIG_GREYBUS_LOOPBACK=m
# CONFIG_GREYBUS_POWER is not set
CONFIG_GREYBUS_RAW=m
# CONFIG_GREYBUS_VIBRATOR is not set
CONFIG_GREYBUS_BRIDGED_PHY=m
CONFIG_GREYBUS_GPIO=m
CONFIG_GREYBUS_I2C=m
CONFIG_GREYBUS_PWM=m
# CONFIG_GREYBUS_SDIO is not set
# CONFIG_GREYBUS_UART is not set

#
# USB Power Delivery and Type-C drivers
#
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_PMC_ATOM=y
CONFIG_CHROME_PLATFORMS=y
# CONFIG_CHROMEOS_LAPTOP is not set
CONFIG_CHROMEOS_PSTORE=m
CONFIG_CROS_EC_CHARDEV=m
CONFIG_CROS_EC_LPC=m
CONFIG_CROS_EC_PROTO=y
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_WM831X is not set
CONFIG_COMMON_CLK_MAX77686=y
CONFIG_COMMON_CLK_RK808=m
CONFIG_COMMON_CLK_SI5351=m
# CONFIG_COMMON_CLK_SI514 is not set
# CONFIG_COMMON_CLK_SI570 is not set
CONFIG_COMMON_CLK_CDCE706=m
CONFIG_COMMON_CLK_CDCE925=y
CONFIG_COMMON_CLK_CS2000_CP=m
# CONFIG_COMMON_CLK_NXP is not set
CONFIG_COMMON_CLK_PALMAS=m
# CONFIG_COMMON_CLK_PWM is not set
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set
CONFIG_COMMON_CLK_VC5=m

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#

#
# Broadcom SoC drivers
#

#
# i.MX SoC drivers
#
# CONFIG_SUNXI_SRAM is not set
CONFIG_SOC_TI=y
# CONFIG_SOC_ZTE is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=m
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=m
CONFIG_DEVFREQ_GOV_PASSIVE=y

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
CONFIG_EXTCON_GPIO=y
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_MAX14577 is not set
CONFIG_EXTCON_MAX3355=m
# CONFIG_EXTCON_MAX8997 is not set
CONFIG_EXTCON_PALMAS=y
# CONFIG_EXTCON_QCOM_SPMI_MISC is not set
CONFIG_EXTCON_RT8973A=y
CONFIG_EXTCON_SM5502=m
CONFIG_EXTCON_USB_GPIO=y
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=m
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
# CONFIG_IIO_SW_DEVICE is not set
CONFIG_IIO_SW_TRIGGER=m

#
# Accelerometers
#
CONFIG_ADXL345=y
CONFIG_ADXL345_I2C=y
# CONFIG_BMA180 is not set
CONFIG_BMC150_ACCEL=y
CONFIG_BMC150_ACCEL_I2C=y
CONFIG_DA280=y
CONFIG_DA311=m
CONFIG_DMARD06=m
CONFIG_DMARD09=m
CONFIG_DMARD10=m
# CONFIG_HID_SENSOR_ACCEL_3D is not set
CONFIG_KXSD9=m
# CONFIG_KXSD9_I2C is not set
CONFIG_KXCJK1013=m
CONFIG_MC3230=y
CONFIG_MMA7455=m
CONFIG_MMA7455_I2C=m
CONFIG_MMA7660=y
CONFIG_MMA8452=m
CONFIG_MMA9551_CORE=m
CONFIG_MMA9551=m
# CONFIG_MMA9553 is not set
# CONFIG_MXC4005 is not set
CONFIG_MXC6255=y
CONFIG_STK8312=y
CONFIG_STK8BA50=m

#
# Analog to digital converters
#
CONFIG_AD7291=y
CONFIG_AD799X=y
CONFIG_CC10001_ADC=m
# CONFIG_DA9150_GPADC is not set
CONFIG_ENVELOPE_DETECTOR=y
CONFIG_HX711=m
CONFIG_LTC2485=m
CONFIG_LTC2497=y
CONFIG_MAX1363=m
CONFIG_MAX9611=y
CONFIG_MCP3422=m
CONFIG_NAU7802=y
CONFIG_PALMAS_GPADC=y
CONFIG_STX104=y
# CONFIG_TI_ADC081C is not set
CONFIG_TI_ADS1015=y
CONFIG_VF610_ADC=y

#
# Amplifiers
#

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=y
# CONFIG_IAQCORE is not set
# CONFIG_VZ89X is not set
CONFIG_IIO_CROS_EC_SENSORS_CORE=m
CONFIG_IIO_CROS_EC_SENSORS=m

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=m
CONFIG_HID_SENSOR_IIO_TRIGGER=m
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Counters
#
# CONFIG_104_QUAD_8 is not set

#
# Digital to analog converters
#
# CONFIG_AD5064 is not set
CONFIG_AD5380=y
# CONFIG_AD5446 is not set
# CONFIG_AD5593R is not set
CONFIG_CIO_DAC=m
CONFIG_DPOT_DAC=m
CONFIG_M62332=m
CONFIG_MAX517=y
CONFIG_MAX5821=y
CONFIG_MCP4725=m
# CONFIG_VF610_DAC is not set

#
# IIO dummy driver
#

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#

#
# Phase-Locked Loop (PLL) frequency synthesizers
#

#
# Digital gyroscope sensors
#
CONFIG_BMG160=y
CONFIG_BMG160_I2C=y
# CONFIG_HID_SENSOR_GYRO_3D is not set
# CONFIG_MPU3050_I2C is not set
# CONFIG_IIO_ST_GYRO_3AXIS is not set
CONFIG_ITG3200=m

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4404=y
CONFIG_MAX30100=y
CONFIG_MAX30102=m

#
# Humidity sensors
#
CONFIG_AM2315=y
# CONFIG_DHT11 is not set
# CONFIG_HDC100X is not set
CONFIG_HID_SENSOR_HUMIDITY=m
CONFIG_HTS221=m
CONFIG_HTS221_I2C=m
CONFIG_HTU21=y
# CONFIG_SI7005 is not set
CONFIG_SI7020=y

#
# Inertial measurement units
#
CONFIG_BMI160=y
CONFIG_BMI160_I2C=y
CONFIG_KMX61=y
CONFIG_INV_MPU6050_IIO=y
CONFIG_INV_MPU6050_I2C=y
CONFIG_IIO_ST_LSM6DSX=y
CONFIG_IIO_ST_LSM6DSX_I2C=y

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
# CONFIG_ADJD_S311 is not set
# CONFIG_AL3320A is not set
CONFIG_APDS9300=y
CONFIG_APDS9960=y
# CONFIG_BH1750 is not set
CONFIG_BH1780=y
CONFIG_CM32181=y
# CONFIG_CM3232 is not set
CONFIG_CM3323=y
CONFIG_CM3605=y
# CONFIG_CM36651 is not set
CONFIG_IIO_CROS_EC_LIGHT_PROX=m
CONFIG_GP2AP020A00F=m
CONFIG_SENSORS_ISL29018=y
# CONFIG_ISL29125 is not set
CONFIG_HID_SENSOR_ALS=m
# CONFIG_HID_SENSOR_PROX is not set
CONFIG_JSA1212=m
CONFIG_RPR0521=m
CONFIG_SENSORS_LM3533=m
CONFIG_LTR501=y
CONFIG_MAX44000=m
CONFIG_OPT3001=m
# CONFIG_PA12203001 is not set
CONFIG_SI1145=y
CONFIG_STK3310=y
CONFIG_TCS3414=y
CONFIG_TCS3472=m
CONFIG_SENSORS_TSL2563=m
CONFIG_TSL2583=m
# CONFIG_TSL4531 is not set
# CONFIG_US5182D is not set
CONFIG_VCNL4000=y
CONFIG_VEML6070=y
CONFIG_VL6180=y

#
# Magnetometer sensors
#
# CONFIG_AK8974 is not set
CONFIG_AK8975=m
# CONFIG_AK09911 is not set
CONFIG_BMC150_MAGN=y
CONFIG_BMC150_MAGN_I2C=y
# CONFIG_MAG3110 is not set
CONFIG_HID_SENSOR_MAGNETOMETER_3D=m
CONFIG_MMC35240=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=m
# CONFIG_HID_SENSOR_DEVICE_ROTATION is not set

#
# Triggers - standalone
#
# CONFIG_IIO_HRTIMER_TRIGGER is not set
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
CONFIG_IIO_TIGHTLOOP_TRIGGER=m
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Digital potentiometers
#
CONFIG_DS1803=y
CONFIG_MCP4531=m
# CONFIG_TPL0102 is not set

#
# Digital potentiostats
#
CONFIG_LMP91000=y

#
# Pressure sensors
#
CONFIG_ABP060MG=m
CONFIG_BMP280=y
CONFIG_BMP280_I2C=y
CONFIG_IIO_CROS_EC_BARO=m
CONFIG_HID_SENSOR_PRESS=m
CONFIG_HP03=y
CONFIG_MPL115=y
CONFIG_MPL115_I2C=y
# CONFIG_MPL3115 is not set
CONFIG_MS5611=y
# CONFIG_MS5611_I2C is not set
CONFIG_MS5637=y
# CONFIG_IIO_ST_PRESS is not set
CONFIG_T5403=y
CONFIG_HP206C=m
CONFIG_ZPA2326=y
CONFIG_ZPA2326_I2C=y

#
# Lightning sensors
#

#
# Proximity and distance sensors
#
CONFIG_LIDAR_LITE_V2=m
CONFIG_SRF04=y
CONFIG_SX9500=y
# CONFIG_SRF08 is not set

#
# Temperature sensors
#
CONFIG_HID_SENSOR_TEMP=m
# CONFIG_MLX90614 is not set
CONFIG_TMP006=y
CONFIG_TMP007=m
# CONFIG_TSYS01 is not set
CONFIG_TSYS02D=m
CONFIG_NTB=y
# CONFIG_NTB_PINGPONG is not set
CONFIG_NTB_TOOL=y
CONFIG_NTB_PERF=m
CONFIG_NTB_TRANSPORT=y
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_CROS_EC=m
CONFIG_PWM_FSL_FTM=m
CONFIG_PWM_LPSS=m
CONFIG_PWM_LPSS_PCI=m
# CONFIG_PWM_LPSS_PLATFORM is not set
CONFIG_PWM_PCA9685=y
# CONFIG_PWM_STMPE is not set
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=m
CONFIG_BOARD_TPCI200=m
CONFIG_SERIAL_IPOCTAL=m
CONFIG_RESET_CONTROLLER=y
# CONFIG_RESET_ATH79 is not set
# CONFIG_RESET_BERLIN is not set
# CONFIG_RESET_IMX7 is not set
# CONFIG_RESET_LPC18XX is not set
# CONFIG_RESET_MESON is not set
# CONFIG_RESET_PISTACHIO is not set
# CONFIG_RESET_SOCFPGA is not set
# CONFIG_RESET_STM32 is not set
# CONFIG_RESET_SUNXI is not set
CONFIG_TI_SYSCON_RESET=m
# CONFIG_RESET_ZYNQ is not set
# CONFIG_RESET_TEGRA_BPMP is not set
CONFIG_FMC=m
# CONFIG_FMC_FAKEDEV is not set
CONFIG_FMC_TRIVIAL=m
CONFIG_FMC_WRITE_EEPROM=m
CONFIG_FMC_CHARDEV=m

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_BCM_KONA_USB2_PHY=m
CONFIG_POWERCAP=y
# CONFIG_INTEL_RAPL is not set
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_DAX=y
CONFIG_NVMEM=y
# CONFIG_STM is not set
CONFIG_INTEL_TH=m
CONFIG_INTEL_TH_PCI=m
# CONFIG_INTEL_TH_GTH is not set
# CONFIG_INTEL_TH_MSU is not set
CONFIG_INTEL_TH_PTI=m
CONFIG_INTEL_TH_DEBUG=y

#
# FPGA Configuration Support
#
# CONFIG_FPGA is not set

#
# FSI support
#
# CONFIG_FSI is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=m
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=m
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_FW_CFG_SYSFS is not set
# CONFIG_GOOGLE_FIRMWARE is not set
# CONFIG_EFI_DEV_PATH_PARSER is not set

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
# CONFIG_EXT4_FS is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_REISERFS_FS=m
CONFIG_REISERFS_CHECK=y
CONFIG_REISERFS_PROC_INFO=y
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=m
CONFIG_JFS_POSIX_ACL=y
CONFIG_JFS_SECURITY=y
CONFIG_JFS_DEBUG=y
CONFIG_JFS_STATISTICS=y
# CONFIG_XFS_FS is not set
CONFIG_GFS2_FS=y
CONFIG_OCFS2_FS=y
CONFIG_OCFS2_FS_O2CB=y
CONFIG_OCFS2_FS_STATS=y
# CONFIG_OCFS2_DEBUG_MASKLOG is not set
CONFIG_OCFS2_DEBUG_FS=y
CONFIG_BTRFS_FS=m
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
CONFIG_NILFS2_FS=m
CONFIG_F2FS_FS=m
# CONFIG_F2FS_STAT_FS is not set
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_POSIX_ACL=y
# CONFIG_F2FS_FS_SECURITY is not set
CONFIG_F2FS_CHECK_FS=y
CONFIG_F2FS_FS_ENCRYPTION=y
CONFIG_F2FS_FAULT_INJECTION=y
CONFIG_FS_DAX=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=m
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
# CONFIG_FUSE_FS is not set
CONFIG_OVERLAY_FS=y
# CONFIG_OVERLAY_FS_REDIRECT_DIR is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
CONFIG_FSCACHE_OBJECT_LIST=y
CONFIG_CACHEFILES=y
CONFIG_CACHEFILES_DEBUG=y
CONFIG_CACHEFILES_HISTOGRAM=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_FAT_DEFAULT_UTF8 is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
# CONFIG_PROC_CHILDREN is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
CONFIG_ADFS_FS=y
CONFIG_ADFS_FS_RW=y
# CONFIG_AFFS_FS is not set
CONFIG_ECRYPT_FS=y
CONFIG_ECRYPT_FS_MESSAGING=y
CONFIG_HFS_FS=y
CONFIG_HFSPLUS_FS=y
CONFIG_HFSPLUS_FS_POSIX_ACL=y
CONFIG_BEFS_FS=y
# CONFIG_BEFS_DEBUG is not set
# CONFIG_BFS_FS is not set
CONFIG_EFS_FS=m
CONFIG_JFFS2_FS=m
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
CONFIG_JFFS2_FS_WBUF_VERIFY=y
# CONFIG_JFFS2_SUMMARY is not set
# CONFIG_JFFS2_FS_XATTR is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
CONFIG_UBIFS_FS=m
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
# CONFIG_UBIFS_FS_LZO is not set
# CONFIG_UBIFS_FS_ZLIB is not set
CONFIG_UBIFS_ATIME_SUPPORT=y
CONFIG_UBIFS_FS_ENCRYPTION=y
# CONFIG_UBIFS_FS_SECURITY is not set
CONFIG_CRAMFS=m
CONFIG_SQUASHFS=y
# CONFIG_SQUASHFS_FILE_CACHE is not set
CONFIG_SQUASHFS_FILE_DIRECT=y
CONFIG_SQUASHFS_DECOMP_SINGLE=y
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
CONFIG_SQUASHFS_XATTR=y
# CONFIG_SQUASHFS_ZLIB is not set
CONFIG_SQUASHFS_LZ4=y
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
CONFIG_SQUASHFS_4K_DEVBLK_SIZE=y
CONFIG_SQUASHFS_EMBEDDED=y
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=m
CONFIG_MINIX_FS=m
# CONFIG_OMFS_FS is not set
CONFIG_HPFS_FS=y
CONFIG_QNX4FS_FS=y
CONFIG_QNX6FS_FS=y
CONFIG_QNX6FS_DEBUG=y
CONFIG_ROMFS_FS=m
# CONFIG_ROMFS_BACKED_BY_BLOCK is not set
# CONFIG_ROMFS_BACKED_BY_MTD is not set
CONFIG_ROMFS_BACKED_BY_BOTH=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_ZLIB_COMPRESS is not set
# CONFIG_PSTORE_LZO_COMPRESS is not set
CONFIG_PSTORE_LZ4_COMPRESS=y
CONFIG_PSTORE_CONSOLE=y
# CONFIG_PSTORE_PMSG is not set
CONFIG_PSTORE_RAM=m
# CONFIG_SYSV_FS is not set
CONFIG_UFS_FS=y
CONFIG_UFS_FS_WRITE=y
# CONFIG_UFS_DEBUG is not set
CONFIG_NETWORK_FILESYSTEMS=y
# CONFIG_NCP_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=m
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=m
# CONFIG_NLS_CODEPAGE_863 is not set
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=m
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=m
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=m
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=m
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=m
# CONFIG_NLS_MAC_CENTEURO is not set
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=m
CONFIG_NLS_MAC_GREEK=m
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=m
CONFIG_NLS_MAC_TURKISH=m
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
# CONFIG_MAGIC_SYSRQ_SERIAL is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_PAGE_REF is not set
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_PER_CPU_MAPS is not set
# CONFIG_DEBUG_HIGHMEM is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_DEBUG_TIMEKEEPING=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_WW_MUTEX_SELFTEST=m
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_TORTURE_TEST is not set
# CONFIG_RCU_PERF_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
# CONFIG_FUNCTION_TRACER is not set
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
# CONFIG_HWLAT_TRACER is not set
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
CONFIG_PROFILE_ALL_BRANCHES=y
# CONFIG_BRANCH_TRACER is not set
# CONFIG_STACK_TRACER is not set
# CONFIG_BLK_DEV_IO_TRACE is not set
CONFIG_UPROBE_EVENTS=y
CONFIG_PROBE_EVENTS=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_HIST_TRIGGERS is not set
CONFIG_TRACEPOINT_BENCHMARK=y
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
# CONFIG_TRACE_ENUM_MAP_FILE is not set
CONFIG_TRACING_EVENTS_GPIO=y

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
CONFIG_TEST_SORT=m
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PERCPU_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_TEST_HEXDUMP=m
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_TEST_PRINTF is not set
CONFIG_TEST_BITMAP=m
# CONFIG_TEST_UUID is not set
CONFIG_TEST_RHASHTABLE=y
CONFIG_TEST_HASH=y
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_LKM=m
# CONFIG_TEST_USER_COPY is not set
CONFIG_TEST_BPF=m
CONFIG_TEST_FIRMWARE=y
# CONFIG_TEST_UDELAY is not set
CONFIG_MEMTEST=y
CONFIG_TEST_STATIC_KEYS=m
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_EARLY_PRINTK_USB=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
# CONFIG_X86_PTDUMP_CORE is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_WX is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_BIG_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
# CONFIG_KEY_DH_OPERATIONS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
# CONFIG_SECURITY_WRITABLE_HOOKS is not set
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_PATH=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
# CONFIG_HARDENED_USERCOPY is not set
CONFIG_STATIC_USERMODEHELPER=y
CONFIG_STATIC_USERMODEHELPER_PATH="/sbin/usermode-helper"
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_SECURITY_LOADPIN=y
# CONFIG_SECURITY_LOADPIN_ENABLED is not set
CONFIG_SECURITY_YAMA=y
# CONFIG_INTEGRITY is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=m
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=m
CONFIG_CRYPTO_ACOMP2=y
# CONFIG_CRYPTO_RSA is not set
CONFIG_CRYPTO_DH=m
CONFIG_CRYPTO_ECDH=m
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER=m
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=m
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
# CONFIG_CRYPTO_ECHAINIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=m
CONFIG_CRYPTO_CTS=m
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=m
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_CRC32=m
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=m
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_586=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_SERPENT_SSE2_586=m
CONFIG_CRYPTO_TEA=m
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_TWOFISH_586 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_LZO is not set
CONFIG_CRYPTO_842=m
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_USER_API_RNG=m
CONFIG_CRYPTO_USER_API_AEAD=y
# CONFIG_CRYPTO_HW is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_BLACKLIST_KEYRING=y
CONFIG_SYSTEM_BLACKLIST_HASH_LIST=""
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
CONFIG_VHOST_NET=y
# CONFIG_VHOST_SCSI is not set
CONFIG_VHOST=y
CONFIG_VHOST_CROSS_ENDIAN_LEGACY=y
CONFIG_LGUEST=m
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=m
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=m
CONFIG_CRC8=y
CONFIG_AUDIT_GENERIC=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_842_COMPRESS=m
CONFIG_842_DECOMPRESS=m
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=m
CONFIG_BCH_CONST_PARAMS=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
# CONFIG_DMA_NOOP_OPS is not set
# CONFIG_DMA_VIRT_OPS is not set
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=m
CONFIG_LIBFDT=y
CONFIG_FONT_SUPPORT=m
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_SBITMAP=y

--=_592f2a0a.EQV0bEyfNLIWsOzPExW3PzqWDxmK3x/BnefmCm4Z+PUOQ1SI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
