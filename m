Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0E456B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 18:45:02 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id c2-v6so8226989pgw.9
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 15:45:02 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id h13-v6si11154628plk.47.2018.07.30.15.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 15:45:00 -0700 (PDT)
Date: Tue, 31 Jul 2018 06:44:25 +0800
From: kernel test robot <lkp@intel.com>
Subject: e181ae0c5d ("mm: zero unavailable pages before memmap init"):
  BUG: unable to handle kernel NULL pointer dereference at 00000000
Message-ID: <5b5f94c9.aY3c5w5Uv4pZ9JB7%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_5b5f94c9.q9pdPYkQ6W2pMzvP+GtZ6N10K9IJzsVjEud8//XUd07GA6JN"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is a multi-part message in MIME format.

--=_5b5f94c9.q9pdPYkQ6W2pMzvP+GtZ6N10K9IJzsVjEud8//XUd07GA6JN
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit e181ae0c5db9544de9c53239eb22bc012ce75033
Author:     Pavel Tatashin <pasha.tatashin@oracle.com>
AuthorDate: Sat Jul 14 09:15:07 2018 -0400
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Sat Jul 14 11:02:20 2018 -0700

    mm: zero unavailable pages before memmap init
    
    We must zero struct pages for memory that is not backed by physical
    memory, or kernel does not have access to.
    
    Recently, there was a change which zeroed all memmap for all holes in
    e820.  Unfortunately, it introduced a bug that is discussed here:
    
      https://www.spinics.net/lists/linux-mm/msg156764.html
    
    Linus, also saw this bug on his machine, and confirmed that reverting
    commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into
    memblock.reserved") fixes the issue.
    
    The problem is that we incorrectly zero some struct pages after they
    were setup.
    
    The fix is to zero unavailable struct pages prior to initializing of
    struct pages.
    
    A more detailed fix should come later that would avoid double zeroing
    cases: one in __init_single_page(), the other one in
    zero_resv_unavail().
    
    Fixes: 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into memblock.reserved")
    Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

2db39a2f49  Merge branch 'i2c/for-current' of git://git.kernel.org/pub/scm/linux/kernel/git/wsa/linux
e181ae0c5d  mm: zero unavailable pages before memmap init
+-----------------------------------------------------------------------------------+------------+------------+
|                                                                                   | 2db39a2f49 | e181ae0c5d |
+-----------------------------------------------------------------------------------+------------+------------+
| boot_successes                                                                    | 15         | 0          |
| boot_failures                                                                     | 8          | 48         |
| Mem-Info                                                                          | 7          |            |
| BUG:sleeping_function_called_from_invalid_context_at_include/linux/percpu-rwsem.h | 1          |            |
| BUG:unable_to_handle_kernel                                                       | 0          | 48         |
| Oops:#[##]                                                                        | 0          | 48         |
| EIP:zero_resv_unavail                                                             | 0          | 48         |
| Kernel_panic-not_syncing:Fatal_exception                                          | 0          | 48         |
| Kernel_panic-not_syncing:Fatal_exception]                                         | 0          | 48         |
+-----------------------------------------------------------------------------------+------------+------------+

[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000127dffff]
[    0.000000] BUG: unable to handle kernel NULL pointer dereference at 00000000
[    0.000000] *pde = 00000000 
[    0.000000] Oops: 0002 [#1]
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.18.0-rc4-00148-ge181ae0 #2
[    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[    0.000000] EIP: zero_resv_unavail+0x8b/0xde
[    0.000000] Code: 3b 55 e0 76 2f 8b 55 e0 81 e2 00 fc ff ff 3b 15 a8 97 a9 7a 73 19 6b 55 e0 24 03 15 a4 97 a9 7a b9 09 00 00 00 89 d7 83 c3 01 <f3> ab 83 d6 00 ff 45 e0 eb c0 8d 45 e8 6a 00 50 8d 45 e4 50 31 c9 
[    0.000000] EAX: 00000000 EBX: 00000001 ECX: 00000009 EDX: 00000000
[    0.000000] ESI: 00000000 EDI: 00000000 EBP: 7a241ebc ESP: 7a241e9c
[    0.000000] DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068 EFLAGS: 00210002
[    0.000000] CR0: 80050033 CR2: 00000000 CR3: 02497000 CR4: 00000690
[    0.000000] Call Trace:
[    0.000000]  ? free_area_init_nodes+0x423/0x457
[    0.000000]  ? pmd_page_vaddr+0xb/0x2c
[    0.000000]  ? zone_sizes_init+0x3b/0x3d
[    0.000000]  ? paging_init+0x83/0x86
[    0.000000]  ? native_pagetable_init+0x7c/0x11c
[    0.000000]  ? setup_arch+0x8d1/0x993
[    0.000000]  ? start_kernel+0x50/0x3a8
[    0.000000]  ? i386_start_kernel+0x97/0x9b
[    0.000000]  ? startup_32_smp+0x15f/0x170
[    0.000000] CR2: 0000000000000000
[    0.000000] random: get_random_bytes called from init_oops_id+0x28/0x3f with crng_init=0
[    0.000000] ---[ end trace 125fd0d953e92c7b ]---
[    0.000000] EIP: zero_resv_unavail+0x8b/0xde

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_5b5f94c9.q9pdPYkQ6W2pMzvP+GtZ6N10K9IJzsVjEud8//XUd07GA6JN
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-openwrt-lkp-nhm-dp2-13:20180730212429:i386-randconfig-n0-201830:4.18.0-rc4-00148-ge181ae0:2.gz"

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

--=_5b5f94c9.q9pdPYkQ6W2pMzvP+GtZ6N10K9IJzsVjEud8//XUd07GA6JN
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-ivb41-103:20180730215353:i386-randconfig-n0-201830:4.18.0-rc4-00147-g2db39a2:1.gz"

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

--=_5b5f94c9.q9pdPYkQ6W2pMzvP+GtZ6N10K9IJzsVjEud8//XUd07GA6JN
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="reproduce-openwrt-lkp-nhm-dp2-13:20180730212429:i386-randconfig-n0-201830:4.18.0-rc4-00148-ge181ae0:2"

#!/bin/bash

kernel=$1

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-kernel $kernel
	-m 296
	-smp 1
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
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"

--=_5b5f94c9.q9pdPYkQ6W2pMzvP+GtZ6N10K9IJzsVjEud8//XUd07GA6JN
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-4.18.0-rc4-00148-ge181ae0"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 4.18.0-rc4 Kernel Configuration
#

#
# Compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
#
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
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_FILTER_PGPROT=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=2
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION=70300
CONFIG_CLANG_VERSION=0
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_USELIB is not set
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
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
# CONFIG_GENERIC_IRQ_DEBUGFS is not set
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
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TINY_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
# CONFIG_BLK_CGROUP is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
CONFIG_CGROUP_RDMA=y
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_HUGETLB=y
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
# CONFIG_PCSPKR_PLATFORM is not set
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_ADVISE_SYSCALLS=y
CONFIG_MEMBARRIER=y
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
# CONFIG_BPF_SYSCALL is not set
CONFIG_USERFAULTFD=y
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
CONFIG_RSEQ=y
CONFIG_DEBUG_RSEQ=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_COMPAT_BRK=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
CONFIG_SLAB_MERGE_DEFAULT=y
CONFIG_SLAB_FREELIST_RANDOM=y
CONFIG_SYSTEM_DATA_VERIFICATION=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_UPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_RSEQ=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_PLUGIN_HOSTCC="g++"
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_STACKPROTECTOR=y
CONFIG_CC_HAS_STACKPROTECTOR_NONE=y
# CONFIG_STACKPROTECTOR is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_ISA_BUS_API=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
# CONFIG_LBDAF is not set
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_ZONED is not set
CONFIG_BLK_CMDLINE_PARSER=y
CONFIG_BLK_WBT=y
CONFIG_BLK_WBT_SQ=y
CONFIG_BLK_WBT_MQ=y
# CONFIG_BLK_DEBUG_FS is not set
CONFIG_BLK_SED_OPAL=y

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
# CONFIG_MINIX_SUBPARTITION is not set
# CONFIG_SOLARIS_X86_PARTITION is not set
CONFIG_UNIXWARE_DISKLABEL=y
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
# CONFIG_SGI_PARTITION is not set
CONFIG_ULTRIX_PARTITION=y
CONFIG_SUN_PARTITION=y
# CONFIG_KARMA_PARTITION is not set
# CONFIG_EFI_PARTITION is not set
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_MQ_IOSCHED_DEADLINE=y
# CONFIG_MQ_IOSCHED_KYBER is not set
CONFIG_IOSCHED_BFQ=y
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_CC_HAS_SANE_STACKPROTECTOR=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
CONFIG_RETPOLINE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
CONFIG_IOSF_MBI_DEBUG=y
# CONFIG_X86_RDC321X is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
CONFIG_M586MMX=y
# CONFIG_M686 is not set
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
# CONFIG_X86_GENERIC is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=5
CONFIG_X86_L1_CACHE_SHIFT=5
CONFIG_X86_F00F_BUG=y
CONFIG_X86_ALIGNMENT_16=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
# CONFIG_CPU_SUP_UMC_32 is not set
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_NR_CPUS_RANGE_BEGIN=1
CONFIG_NR_CPUS_RANGE_END=1
CONFIG_NR_CPUS_DEFAULT=1
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_UP_APIC=y
# CONFIG_X86_UP_IOAPIC is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
# CONFIG_X86_MCELOG_LEGACY is not set
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_ANCIENT_MCE=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_AMD_POWER=y
CONFIG_X86_LEGACY_VM86=y
CONFIG_VM86=y
# CONFIG_X86_16BIT is not set
CONFIG_TOSHIBA=y
CONFIG_I8K=y
# CONFIG_X86_REBOOTFIXUPS is not set
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_VMSPLIT_3G is not set
# CONFIG_VMSPLIT_3G_OPT is not set
# CONFIG_VMSPLIT_2G is not set
CONFIG_VMSPLIT_2G_OPT=y
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0x78000000
CONFIG_HIGHMEM=y
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
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
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_MEMORY_BALLOON=y
# CONFIG_BALLOON_COMPACTION is not set
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
# CONFIG_ZPOOL is not set
# CONFIG_ZBUD is not set
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_FRAME_VECTOR=y
# CONFIG_PERCPU_STATS is not set
CONFIG_GUP_BENCHMARK=y
CONFIG_ARCH_HAS_PTE_SPECIAL=y
CONFIG_HIGHPTE=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MATH_EMULATION is not set
# CONFIG_MTRR is not set
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SPCR_TABLE=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
# CONFIG_ACPI_CONTAINER is not set
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
CONFIG_X86_PM_TIMER=y
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOOLPC=y
# CONFIG_PCI_GOANY is not set
CONFIG_PCI_DIRECT=y
CONFIG_PCI_OLPC=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_CNB20LE_QUIRK=y
CONFIG_PCIEPORTBUS=y
# CONFIG_PCIEAER is not set
# CONFIG_PCIEASPM is not set
CONFIG_PCIE_PME=y
# CONFIG_PCIE_PTM is not set
# CONFIG_PCI_MSI is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
CONFIG_PCI_PF_STUB=y
CONFIG_PCI_ATS=y
CONFIG_PCI_ECAM=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
# CONFIG_PCI_PRI is not set
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI controller drivers
#

#
# Cadence PCIe controllers support
#
CONFIG_PCIE_CADENCE=y
CONFIG_PCIE_CADENCE_HOST=y
CONFIG_PCI_FTPCI100=y
CONFIG_PCI_HOST_COMMON=y
CONFIG_PCI_HOST_GENERIC=y

#
# DesignWare PCI Core Support
#

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
CONFIG_PCI_SW_SWITCHTEC=y
# CONFIG_ISA_BUS is not set
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
# CONFIG_EISA is not set
CONFIG_SCx200=y
CONFIG_SCx200HR_TIMER=y
CONFIG_OLPC=y
# CONFIG_OLPC_XO15_SCI is not set
CONFIG_ALIX=y
# CONFIG_NET5501 is not set
# CONFIG_GEOS is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
# CONFIG_YENTA_RICOH is not set
# CONFIG_YENTA_TI is not set
# CONFIG_YENTA_TOSHIBA is not set
# CONFIG_PD6729 is not set
CONFIG_I82092=y
# CONFIG_I82365 is not set
# CONFIG_TCIC is not set
CONFIG_PCMCIA_PROBE=y
CONFIG_PCCARD_NONSTATIC=y
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
# CONFIG_BINFMT_MISC is not set
# CONFIG_COREDUMP is not set
CONFIG_COMPAT_32=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y
CONFIG_NET_INGRESS=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=y
# CONFIG_TLS is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_USER is not set
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_SYN_COOKIES is not set
# CONFIG_NET_IPVTI is not set
# CONFIG_NET_FOU is not set
# CONFIG_NET_FOU_IP_TUNNELS is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_IPV6_ILA is not set
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
# CONFIG_NETLABEL is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_FAMILY_BRIDGE=y
# CONFIG_NETFILTER_NETLINK_ACCT is not set
# CONFIG_NETFILTER_NETLINK_QUEUE is not set
# CONFIG_NETFILTER_NETLINK_LOG is not set
# CONFIG_NF_CONNTRACK is not set
# CONFIG_NF_LOG_NETDEV is not set
# CONFIG_NF_TABLES is not set
# CONFIG_NETFILTER_XTABLES is not set
# CONFIG_IP_SET is not set
# CONFIG_IP_VS is not set

#
# IP: Netfilter Configuration
#
# CONFIG_NF_SOCKET_IPV4 is not set
# CONFIG_NF_TPROXY_IPV4 is not set
# CONFIG_NF_DUP_IPV4 is not set
# CONFIG_NF_LOG_ARP is not set
# CONFIG_NF_LOG_IPV4 is not set
# CONFIG_NF_REJECT_IPV4 is not set
# CONFIG_IP_NF_IPTABLES is not set
# CONFIG_IP_NF_ARPTABLES is not set

#
# IPv6: Netfilter Configuration
#
# CONFIG_NF_SOCKET_IPV6 is not set
# CONFIG_NF_TPROXY_IPV6 is not set
# CONFIG_NF_DUP_IPV6 is not set
# CONFIG_NF_REJECT_IPV6 is not set
# CONFIG_NF_LOG_IPV6 is not set
# CONFIG_IP6_NF_IPTABLES is not set
# CONFIG_BPFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
CONFIG_STP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
CONFIG_LAPB=y
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
CONFIG_IEEE802154=y
CONFIG_IEEE802154_NL802154_EXPERIMENTAL=y
CONFIG_IEEE802154_SOCKET=y
# CONFIG_MAC802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BATMAN_V=y
CONFIG_BATMAN_ADV_BLA=y
CONFIG_BATMAN_ADV_DAT=y
CONFIG_BATMAN_ADV_NC=y
# CONFIG_BATMAN_ADV_MCAST is not set
CONFIG_BATMAN_ADV_DEBUGFS=y
# CONFIG_BATMAN_ADV_DEBUG is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
CONFIG_NETLINK_DIAG=y
# CONFIG_MPLS is not set
CONFIG_NET_NSH=y
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_DROP_MONITOR is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
CONFIG_BT=y
# CONFIG_BT_BREDR is not set
CONFIG_BT_LE=y
# CONFIG_BT_LEDS is not set
# CONFIG_BT_SELFTEST is not set
# CONFIG_BT_DEBUGFS is not set

#
# Bluetooth device drivers
#
CONFIG_BT_INTEL=y
CONFIG_BT_BCM=y
CONFIG_BT_RTL=y
CONFIG_BT_QCA=y
CONFIG_BT_HCIBTUSB=y
# CONFIG_BT_HCIBTUSB_AUTOSUSPEND is not set
CONFIG_BT_HCIBTUSB_BCM=y
CONFIG_BT_HCIBTUSB_RTL=y
CONFIG_BT_HCIBTSDIO=y
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_SERDEV=y
CONFIG_BT_HCIUART_H4=y
# CONFIG_BT_HCIUART_NOKIA is not set
CONFIG_BT_HCIUART_BCSP=y
# CONFIG_BT_HCIUART_ATH3K is not set
# CONFIG_BT_HCIUART_LL is not set
# CONFIG_BT_HCIUART_3WIRE is not set
# CONFIG_BT_HCIUART_INTEL is not set
CONFIG_BT_HCIUART_BCM=y
CONFIG_BT_HCIUART_QCA=y
# CONFIG_BT_HCIUART_AG6XX is not set
CONFIG_BT_HCIUART_MRVL=y
CONFIG_BT_HCIBCM203X=y
CONFIG_BT_HCIBPA10X=y
# CONFIG_BT_HCIBFUSB is not set
# CONFIG_BT_HCIDTL1 is not set
# CONFIG_BT_HCIBT3C is not set
CONFIG_BT_HCIBLUECARD=y
CONFIG_BT_HCIVHCI=y
# CONFIG_BT_MRVL is not set
CONFIG_BT_ATH3K=y
CONFIG_BT_WILINK=y
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_REQUIRE_SIGNED_REGDB=y
CONFIG_CFG80211_USE_KERNEL_REGDB_KEYS=y
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=y
CONFIG_LIB80211_DEBUG=y
# CONFIG_MAC80211 is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
# CONFIG_RFKILL is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_NET_9P_DEBUG=y
CONFIG_CAIF=y
CONFIG_CAIF_DEBUG=y
# CONFIG_CAIF_NETDEV is not set
CONFIG_CAIF_USB=y
# CONFIG_CEPH_LIB is not set
CONFIG_NFC=y
CONFIG_NFC_DIGITAL=y
CONFIG_NFC_NCI=y
# CONFIG_NFC_NCI_SPI is not set
CONFIG_NFC_NCI_UART=y
CONFIG_NFC_HCI=y
# CONFIG_NFC_SHDLC is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_TRF7970A=y
CONFIG_NFC_MEI_PHY=y
CONFIG_NFC_SIM=y
CONFIG_NFC_PORT100=y
# CONFIG_NFC_FDP is not set
# CONFIG_NFC_PN544_MEI is not set
# CONFIG_NFC_PN533_USB is not set
# CONFIG_NFC_PN533_I2C is not set
# CONFIG_NFC_MICROREAD_MEI is not set
CONFIG_NFC_MRVL=y
CONFIG_NFC_MRVL_USB=y
CONFIG_NFC_MRVL_UART=y
CONFIG_NFC_MRVL_I2C=y
# CONFIG_NFC_ST_NCI_I2C is not set
# CONFIG_NFC_ST_NCI_SPI is not set
CONFIG_NFC_NXP_NCI=y
# CONFIG_NFC_NXP_NCI_I2C is not set
CONFIG_NFC_S3FWRN5=y
CONFIG_NFC_S3FWRN5_I2C=y
CONFIG_NFC_ST95HF=y
CONFIG_PSAMPLE=y
CONFIG_NET_IFE=y
CONFIG_LWTUNNEL=y
# CONFIG_LWTUNNEL_BPF is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
CONFIG_NET_DEVLINK=y
CONFIG_MAY_USE_DEVLINK=y
CONFIG_FAILOVER=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set

#
# Firmware loader
#
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_WANT_DEV_COREDUMP=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_W1=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_SIMPLE_PM_BUS=y
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
CONFIG_OF=y
# CONFIG_OF_UNITTEST is not set
CONFIG_OF_PROMTREE=y
CONFIG_OF_KOBJ=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_MDIO=y
# CONFIG_OF_OVERLAY is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
CONFIG_PARPORT_AX88796=y
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
# CONFIG_ISAPNP is not set
# CONFIG_PNPBIOS is not set
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
CONFIG_BLK_DEV_FD=y
CONFIG_CDROM=y
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
# CONFIG_ZRAM is not set
CONFIG_BLK_DEV_DAC960=y
CONFIG_BLK_DEV_UMEM=y
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=y
# CONFIG_BLK_DEV_DRBD is not set
CONFIG_BLK_DEV_NBD=y
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=y
CONFIG_VIRTIO_BLK=y
# CONFIG_VIRTIO_BLK_SCSI is not set
# CONFIG_BLK_DEV_RBD is not set
CONFIG_BLK_DEV_RSXX=y

#
# NVME Support
#
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
# CONFIG_NVME_MULTIPATH is not set
# CONFIG_NVME_FC is not set
# CONFIG_NVME_TARGET is not set

#
# Misc devices
#
CONFIG_AD525X_DPOT=y
# CONFIG_AD525X_DPOT_I2C is not set
# CONFIG_AD525X_DPOT_SPI is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_CS5535_MFGPT is not set
CONFIG_HP_ILO=y
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_PCH_PHUB=y
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_LATTICE_ECP3_CONFIG is not set
# CONFIG_SRAM is not set
CONFIG_PCI_ENDPOINT_TEST=y
CONFIG_MISC_RTSX=y
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
# CONFIG_EEPROM_93XX46 is not set
CONFIG_EEPROM_IDT_89HPESX=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y
# CONFIG_SENSORS_LIS3_I2C is not set
# CONFIG_ALTERA_STAPL is not set
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
# CONFIG_INTEL_MEI_TXE is not set
CONFIG_VMWARE_VMCI=y

#
# Intel MIC & related support
#

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
# CONFIG_ECHO is not set
CONFIG_MISC_RTSX_PCI=y
# CONFIG_MISC_RTSX_USB is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_IDE_LEGACY=y
CONFIG_BLK_DEV_IDE_SATA=y
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
# CONFIG_IDE_GD_ATAPI is not set
CONFIG_BLK_DEV_IDECS=y
# CONFIG_BLK_DEV_DELKIN is not set
CONFIG_BLK_DEV_IDECD=y
# CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS is not set
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
# CONFIG_BLK_DEV_CMD640 is not set
CONFIG_BLK_DEV_IDEPNP=y
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
CONFIG_BLK_DEV_OPTI621=y
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
CONFIG_BLK_DEV_ALI15X3=y
CONFIG_BLK_DEV_AMD74XX=y
CONFIG_BLK_DEV_ATIIXP=y
CONFIG_BLK_DEV_CMD64X=y
CONFIG_BLK_DEV_TRIFLEX=y
CONFIG_BLK_DEV_CS5520=y
CONFIG_BLK_DEV_CS5530=y
CONFIG_BLK_DEV_CS5535=y
CONFIG_BLK_DEV_CS5536=y
# CONFIG_BLK_DEV_HPT366 is not set
CONFIG_BLK_DEV_JMICRON=y
CONFIG_BLK_DEV_SC1200=y
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
CONFIG_BLK_DEV_IT8213=y
# CONFIG_BLK_DEV_IT821X is not set
CONFIG_BLK_DEV_NS87415=y
CONFIG_BLK_DEV_PDC202XX_OLD=y
CONFIG_BLK_DEV_PDC202XX_NEW=y
CONFIG_BLK_DEV_SVWKS=y
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
CONFIG_BLK_DEV_TRM290=y
# CONFIG_BLK_DEV_VIA82CXXX is not set
CONFIG_BLK_DEV_TC86C001=y

#
# Other IDE chipsets support
#

#
# Note: most of these also require special kernel boot parameters
#
# CONFIG_BLK_DEV_4DRIVES is not set
CONFIG_BLK_DEV_ALI14XX=y
CONFIG_BLK_DEV_DTC2278=y
CONFIG_BLK_DEV_HT6560B=y
CONFIG_BLK_DEV_QD65XX=y
CONFIG_BLK_DEV_UMC8672=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
# CONFIG_SCSI is not set
# CONFIG_ATA is not set
CONFIG_MD=y
# CONFIG_BLK_DEV_MD is not set
# CONFIG_BCACHE is not set
# CONFIG_BLK_DEV_DM is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
# CONFIG_FIREWIRE_NET is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
# CONFIG_NET_CORE is not set
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
CONFIG_ARCNET_1051=y
CONFIG_ARCNET_RAW=y
# CONFIG_ARCNET_CAP is not set
# CONFIG_ARCNET_COM90xx is not set
CONFIG_ARCNET_COM90xxIO=y
CONFIG_ARCNET_RIM_I=y
# CONFIG_ARCNET_COM20020 is not set

#
# CAIF transport drivers
#
CONFIG_CAIF_TTY=y
CONFIG_CAIF_SPI_SLAVE=y
# CONFIG_CAIF_SPI_SYNC is not set
CONFIG_CAIF_HSI=y
# CONFIG_CAIF_VIRTIO is not set

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_EL3 is not set
# CONFIG_3C515 is not set
# CONFIG_PCMCIA_3C574 is not set
# CONFIG_PCMCIA_3C589 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_LANCE is not set
# CONFIG_PCNET32 is not set
# CONFIG_PCMCIA_NMCLAN is not set
# CONFIG_NI65 is not set
# CONFIG_AMD_XGBE is not set
CONFIG_NET_VENDOR_AQUANTIA=y
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
CONFIG_NET_VENDOR_AURORA=y
# CONFIG_AURORA_NB8800 is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
# CONFIG_BCMGENET is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_CAVIUM=y
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CIRRUS=y
# CONFIG_CS89x0 is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_GEMINI_ETHERNET is not set
# CONFIG_CX_ECAT is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
# CONFIG_EZCHIP_NPS_MANAGEMENT_ENET is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_HUAWEI=y
CONFIG_NET_VENDOR_I825XX=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
# CONFIG_ENCX24J600 is not set
# CONFIG_LAN743X is not set
CONFIG_NET_VENDOR_MICROSEMI=y
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_NETRONOME=y
CONFIG_NET_VENDOR_NI=y
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
# CONFIG_NE2000 is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_PCMCIA_PCNET is not set
# CONFIG_ULTRA is not set
# CONFIG_WD80x3 is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCA7000_SPI is not set
# CONFIG_QCA7000_UART is not set
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_SMC9194 is not set
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_SOCIONEXT=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_ALE is not set
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
CONFIG_NET_SB1000=y
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BUS=y
CONFIG_MDIO_BCM_UNIMAC=y
# CONFIG_MDIO_BITBANG is not set
CONFIG_MDIO_BUS_MUX=y
CONFIG_MDIO_BUS_MUX_GPIO=y
CONFIG_MDIO_BUS_MUX_MMIOREG=y
CONFIG_MDIO_HISI_FEMAC=y
CONFIG_MDIO_MSCC_MIIM=y
CONFIG_PHYLIB=y
CONFIG_SWPHY=y
# CONFIG_LED_TRIGGER_PHY is not set

#
# MII PHY device drivers
#
# CONFIG_AMD_PHY is not set
CONFIG_AQUANTIA_PHY=y
CONFIG_ASIX_PHY=y
CONFIG_AT803X_PHY=y
# CONFIG_BCM7XXX_PHY is not set
CONFIG_BCM87XX_PHY=y
CONFIG_BCM_NET_PHYLIB=y
CONFIG_BROADCOM_PHY=y
CONFIG_CICADA_PHY=y
CONFIG_CORTINA_PHY=y
# CONFIG_DAVICOM_PHY is not set
# CONFIG_DP83822_PHY is not set
CONFIG_DP83TC811_PHY=y
CONFIG_DP83848_PHY=y
CONFIG_DP83867_PHY=y
CONFIG_FIXED_PHY=y
CONFIG_ICPLUS_PHY=y
CONFIG_INTEL_XWAY_PHY=y
CONFIG_LSI_ET1011C_PHY=y
CONFIG_LXT_PHY=y
CONFIG_MARVELL_PHY=y
CONFIG_MARVELL_10G_PHY=y
CONFIG_MICREL_PHY=y
CONFIG_MICROCHIP_PHY=y
CONFIG_MICROCHIP_T1_PHY=y
CONFIG_MICROSEMI_PHY=y
CONFIG_NATIONAL_PHY=y
# CONFIG_QSEMI_PHY is not set
# CONFIG_REALTEK_PHY is not set
CONFIG_RENESAS_PHY=y
CONFIG_ROCKCHIP_PHY=y
# CONFIG_SMSC_PHY is not set
CONFIG_STE10XP=y
# CONFIG_TERANETICS_PHY is not set
CONFIG_VITESSE_PHY=y
CONFIG_XILINX_GMII2RGMII=y
CONFIG_MICREL_KS8995MA=y
# CONFIG_PLIP is not set
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
CONFIG_PPP_DEFLATE=y
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=y
CONFIG_PPP_MULTILINK=y
# CONFIG_PPPOE is not set
CONFIG_PPP_ASYNC=y
CONFIG_PPP_SYNC_TTY=y
# CONFIG_SLIP is not set
CONFIG_SLHC=y
CONFIG_USB_NET_DRIVERS=y
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
# CONFIG_USB_RTL8150 is not set
CONFIG_USB_RTL8152=y
CONFIG_USB_LAN78XX=y
CONFIG_USB_USBNET=y
# CONFIG_USB_NET_AX8817X is not set
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_NET_CDCETHER=y
# CONFIG_USB_NET_CDC_EEM is not set
CONFIG_USB_NET_CDC_NCM=y
CONFIG_USB_NET_HUAWEI_CDC_NCM=y
CONFIG_USB_NET_CDC_MBIM=y
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
CONFIG_USB_NET_SR9800=y
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
# CONFIG_USB_NET_GL620A is not set
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
# CONFIG_USB_NET_CDC_SUBSET is not set
# CONFIG_USB_NET_ZAURUS is not set
CONFIG_USB_NET_CX82310_ETH=y
CONFIG_USB_NET_KALMIA=y
CONFIG_USB_NET_QMI_WWAN=y
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
CONFIG_USB_VL600=y
# CONFIG_USB_NET_CH9200 is not set
CONFIG_WLAN=y
CONFIG_WIRELESS_WDS=y
CONFIG_WLAN_VENDOR_ADMTEK=y
CONFIG_WLAN_VENDOR_ATH=y
CONFIG_ATH_DEBUG=y
# CONFIG_ATH_TRACEPOINTS is not set
CONFIG_ATH5K_PCI=y
CONFIG_ATH6KL=y
CONFIG_ATH6KL_SDIO=y
CONFIG_ATH6KL_USB=y
# CONFIG_ATH6KL_DEBUG is not set
CONFIG_ATH6KL_TRACING=y
CONFIG_WIL6210=y
# CONFIG_WIL6210_ISR_COR is not set
# CONFIG_WIL6210_TRACING is not set
CONFIG_WIL6210_DEBUGFS=y
CONFIG_WLAN_VENDOR_ATMEL=y
CONFIG_ATMEL=y
CONFIG_PCI_ATMEL=y
# CONFIG_PCMCIA_ATMEL is not set
CONFIG_WLAN_VENDOR_BROADCOM=y
CONFIG_BRCMUTIL=y
CONFIG_BRCMFMAC=y
CONFIG_BRCMFMAC_PROTO_BCDC=y
CONFIG_BRCMFMAC_PROTO_MSGBUF=y
CONFIG_BRCMFMAC_SDIO=y
# CONFIG_BRCMFMAC_USB is not set
CONFIG_BRCMFMAC_PCIE=y
CONFIG_BRCM_TRACING=y
# CONFIG_BRCMDBG is not set
# CONFIG_WLAN_VENDOR_CISCO is not set
# CONFIG_WLAN_VENDOR_INTEL is not set
# CONFIG_WLAN_VENDOR_INTERSIL is not set
CONFIG_WLAN_VENDOR_MARVELL=y
CONFIG_LIBERTAS=y
CONFIG_LIBERTAS_USB=y
CONFIG_LIBERTAS_CS=y
# CONFIG_LIBERTAS_SDIO is not set
CONFIG_LIBERTAS_SPI=y
# CONFIG_LIBERTAS_DEBUG is not set
# CONFIG_LIBERTAS_MESH is not set
CONFIG_MWIFIEX=y
CONFIG_MWIFIEX_SDIO=y
CONFIG_MWIFIEX_PCIE=y
CONFIG_MWIFIEX_USB=y
CONFIG_WLAN_VENDOR_MEDIATEK=y
CONFIG_WLAN_VENDOR_RALINK=y
# CONFIG_WLAN_VENDOR_REALTEK is not set
# CONFIG_WLAN_VENDOR_RSI is not set
# CONFIG_WLAN_VENDOR_ST is not set
# CONFIG_WLAN_VENDOR_TI is not set
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_USB_ZD1201=y
CONFIG_WLAN_VENDOR_QUANTENNA=y
# CONFIG_QTNFMAC_PEARL_PCIE is not set
CONFIG_PCMCIA_RAYCS=y
CONFIG_PCMCIA_WL3501=y
CONFIG_USB_NET_RNDIS_WLAN=y

#
# WiMAX Wireless Broadband devices
#
CONFIG_WIMAX_I2400M=y
CONFIG_WIMAX_I2400M_USB=y
CONFIG_WIMAX_I2400M_DEBUG_LEVEL=8
CONFIG_WAN=y
CONFIG_LANMEDIA=y
CONFIG_HDLC=y
# CONFIG_HDLC_RAW is not set
CONFIG_HDLC_RAW_ETH=y
CONFIG_HDLC_CISCO=y
# CONFIG_HDLC_FR is not set
CONFIG_HDLC_PPP=y
# CONFIG_HDLC_X25 is not set
CONFIG_PCI200SYN=y
CONFIG_WANXL=y
# CONFIG_WANXL_BUILD_FIRMWARE is not set
CONFIG_PC300TOO=y
# CONFIG_N2 is not set
# CONFIG_C101 is not set
CONFIG_FARSYNC=y
# CONFIG_DLCI is not set
CONFIG_SBNI=y
# CONFIG_SBNI_MULTILINE is not set
CONFIG_IEEE802154_DRIVERS=y
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_THUNDERBOLT_NET is not set
# CONFIG_NETDEVSIM is not set
# CONFIG_NET_FAILOVER is not set
# CONFIG_ISDN is not set
CONFIG_NVM=y
# CONFIG_NVM_DEBUG is not set
CONFIG_NVM_PBLK=y

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
CONFIG_INPUT_JOYDEV=y
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADC is not set
# CONFIG_KEYBOARD_ADP5520 is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
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
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_KEYBOARD_BCM is not set
# CONFIG_KEYBOARD_MTK_PMIC is not set
# CONFIG_INPUT_MOUSE is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=y
CONFIG_JOYSTICK_ADI=y
CONFIG_JOYSTICK_COBRA=y
# CONFIG_JOYSTICK_GF2K is not set
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
# CONFIG_JOYSTICK_SIDEWINDER is not set
# CONFIG_JOYSTICK_TMDC is not set
# CONFIG_JOYSTICK_IFORCE is not set
CONFIG_JOYSTICK_WARRIOR=y
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
# CONFIG_JOYSTICK_SPACEBALL is not set
CONFIG_JOYSTICK_STINGER=y
# CONFIG_JOYSTICK_TWIDJOY is not set
# CONFIG_JOYSTICK_ZHENHUA is not set
# CONFIG_JOYSTICK_DB9 is not set
# CONFIG_JOYSTICK_GAMECON is not set
CONFIG_JOYSTICK_TURBOGRAFX=y
CONFIG_JOYSTICK_AS5011=y
CONFIG_JOYSTICK_JOYDUMP=y
CONFIG_JOYSTICK_XPAD=y
# CONFIG_JOYSTICK_XPAD_FF is not set
# CONFIG_JOYSTICK_XPAD_LEDS is not set
# CONFIG_JOYSTICK_WALKERA0701 is not set
CONFIG_JOYSTICK_PSXPAD_SPI=y
CONFIG_JOYSTICK_PSXPAD_SPI_FF=y
CONFIG_JOYSTICK_PXRC=y
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set
CONFIG_RMI4_CORE=y
CONFIG_RMI4_I2C=y
CONFIG_RMI4_SPI=y
CONFIG_RMI4_SMB=y
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=y
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y
# CONFIG_RMI4_F34 is not set
# CONFIG_RMI4_F54 is not set
# CONFIG_RMI4_F55 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_SERIO_APBPS2 is not set
# CONFIG_SERIO_OLPC_APSP is not set
CONFIG_SERIO_GPIO_PS2=y
CONFIG_USERIO=y
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
CONFIG_GAMEPORT_L4=y
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=y
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
# CONFIG_SERIAL_8250_PNP is not set
CONFIG_SERIAL_8250_FINTEK=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_EXAR is not set
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
CONFIG_SERIAL_8250_ASPEED_VUART=y
CONFIG_SERIAL_8250_DW=y
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
# CONFIG_SERIAL_8250_MID is not set
CONFIG_SERIAL_8250_MOXA=y
CONFIG_SERIAL_OF_PLATFORM=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
# CONFIG_SERIAL_MAX310X is not set
CONFIG_SERIAL_UARTLITE=y
# CONFIG_SERIAL_UARTLITE_CONSOLE is not set
CONFIG_SERIAL_UARTLITE_NR_UARTS=1
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ALTERA_UART_CONSOLE=y
CONFIG_SERIAL_IFX6X60=y
CONFIG_SERIAL_PCH_UART=y
# CONFIG_SERIAL_PCH_UART_CONSOLE is not set
CONFIG_SERIAL_XILINX_PS_UART=y
CONFIG_SERIAL_XILINX_PS_UART_CONSOLE=y
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
CONFIG_SERIAL_CONEXANT_DIGICOLOR=y
# CONFIG_SERIAL_CONEXANT_DIGICOLOR_CONSOLE is not set
CONFIG_SERIAL_DEV_BUS=y
CONFIG_SERIAL_DEV_CTRL_TTYPORT=y
CONFIG_TTY_PRINTK=y
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
# CONFIG_DTLK is not set
CONFIG_R3964=y
CONFIG_APPLICOM=y
CONFIG_SONYPI=y

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=y
# CONFIG_CARDMAN_4040 is not set
CONFIG_SCR24X=y
CONFIG_IPWIRELESS=y
CONFIG_MWAVE=y
# CONFIG_SCx200_GPIO is not set
# CONFIG_PC8736x_GPIO is not set
CONFIG_NSC_GPIO=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_SPI is not set
# CONFIG_TCG_TIS_I2C_ATMEL is not set
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_TIS_I2C_NUVOTON=y
# CONFIG_TCG_NSC is not set
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
# CONFIG_TCG_VTPM_PROXY is not set
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
CONFIG_TCG_TIS_ST33ZP24_SPI=y
CONFIG_TELCLOCK=y
# CONFIG_DEVPORT is not set
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_ARB_GPIO_CHALLENGE is not set
CONFIG_I2C_MUX_GPIO=y
# CONFIG_I2C_MUX_GPMUX is not set
# CONFIG_I2C_MUX_LTC4306 is not set
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_MUX_REG=y
CONFIG_I2C_MUX_MLXCPLD=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
# CONFIG_I2C_ALI15X3 is not set
CONFIG_I2C_AMD756=y
CONFIG_I2C_AMD756_S4882=y
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
# CONFIG_I2C_NFORCE2_S4985 is not set
# CONFIG_I2C_SIS5595 is not set
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
CONFIG_I2C_DESIGNWARE_PCI=y
# CONFIG_I2C_DESIGNWARE_BAYTRAIL is not set
CONFIG_I2C_EG20T=y
CONFIG_I2C_EMEV2=y
CONFIG_I2C_GPIO=y
CONFIG_I2C_GPIO_FAULT_INJECTOR=y
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
CONFIG_I2C_PXA=y
CONFIG_I2C_PXA_PCI=y
# CONFIG_I2C_RK3X is not set
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_DLN2=y
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y
CONFIG_I2C_VIPERBOARD=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_ELEKTOR=y
CONFIG_I2C_PCA_ISA=y
CONFIG_I2C_CROS_EC_TUNNEL=y
# CONFIG_SCx200_ACB is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y
CONFIG_SPI_MEM=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
CONFIG_SPI_AXI_SPI_ENGINE=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
# CONFIG_SPI_CADENCE is not set
CONFIG_SPI_DESIGNWARE=y
CONFIG_SPI_DW_PCI=y
CONFIG_SPI_DW_MID_DMA=y
# CONFIG_SPI_DW_MMIO is not set
CONFIG_SPI_DLN2=y
CONFIG_SPI_GPIO=y
CONFIG_SPI_LM70_LLP=y
# CONFIG_SPI_FSL_SPI is not set
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
CONFIG_SPI_ROCKCHIP=y
CONFIG_SPI_SC18IS602=y
CONFIG_SPI_TOPCLIFF_PCH=y
# CONFIG_SPI_XCOMM is not set
CONFIG_SPI_XILINX=y
CONFIG_SPI_ZYNQMP_GQSPI=y

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
CONFIG_SPI_SLAVE=y
CONFIG_SPI_SLAVE_TIME=y
CONFIG_SPI_SLAVE_SYSTEM_CONTROL=y
# CONFIG_SPMI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
CONFIG_HSI_CHAR=y
# CONFIG_PPS is not set

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
# CONFIG_PINCTRL is not set
CONFIG_GPIOLIB=y
CONFIG_GPIOLIB_FASTPATH_LIMIT=512
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_74XX_MMIO is not set
CONFIG_GPIO_ALTERA=y
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_FTGPIO010 is not set
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_GRGPIO=y
# CONFIG_GPIO_HLWD is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MB86S7X=y
CONFIG_GPIO_MOCKUP=y
CONFIG_GPIO_SYSCON=y
CONFIG_GPIO_VX855=y
CONFIG_GPIO_XILINX=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=y
# CONFIG_GPIO_IT87 is not set
CONFIG_GPIO_SCH=y
# CONFIG_GPIO_SCH311X is not set
CONFIG_GPIO_WINBOND=y
CONFIG_GPIO_WS16C48=y

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
CONFIG_GPIO_ADNP=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
# CONFIG_GPIO_PCA953X is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=y
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_BD9571MWV=y
CONFIG_GPIO_CS5535=y
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_DLN2=y
CONFIG_GPIO_KEMPLD=y
CONFIG_GPIO_LP3943=y
CONFIG_GPIO_LP873X=y
# CONFIG_GPIO_MAX77620 is not set
# CONFIG_GPIO_PALMAS is not set
CONFIG_GPIO_RC5T583=y
# CONFIG_GPIO_TIMBERDALE is not set
CONFIG_GPIO_TPS65218=y
# CONFIG_GPIO_TPS6586X is not set
CONFIG_GPIO_TPS65910=y
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL4030=y
CONFIG_GPIO_TWL6040=y
CONFIG_GPIO_WM831X=y

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_PCH=y
CONFIG_GPIO_PCI_IDIO_16=y
CONFIG_GPIO_PCIE_IDIO_24=y
CONFIG_GPIO_RDC321X=y
CONFIG_GPIO_SODAVILLE=y

#
# SPI GPIO expanders
#
CONFIG_GPIO_74X164=y
# CONFIG_GPIO_MAX3191X is not set
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MC33880 is not set
CONFIG_GPIO_PISOSR=y
CONFIG_GPIO_XRA1403=y

#
# USB GPIO expanders
#
# CONFIG_GPIO_VIPERBOARD is not set
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2490 is not set
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2405=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2805 is not set
# CONFIG_W1_SLAVE_DS2431 is not set
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2438=y
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
# CONFIG_W1_SLAVE_DS28E17 is not set
# CONFIG_POWER_AVS is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
# CONFIG_GENERIC_ADC_BATTERY is not set
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_ACT8945A is not set
CONFIG_BATTERY_DS2760=y
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_LEGO_EV3=y
CONFIG_BATTERY_OLPC=y
CONFIG_BATTERY_SBS=y
# CONFIG_CHARGER_SBS is not set
CONFIG_MANAGER_SBS=y
CONFIG_BATTERY_BQ27XXX=y
# CONFIG_BATTERY_BQ27XXX_I2C is not set
CONFIG_BATTERY_BQ27XXX_HDQ=y
CONFIG_BATTERY_DA9150=y
CONFIG_AXP20X_POWER=y
CONFIG_AXP288_CHARGER=y
CONFIG_AXP288_FUEL_GAUGE=y
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_MAX1721X=y
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_TWL4030=y
CONFIG_CHARGER_LP8727=y
# CONFIG_CHARGER_GPIO is not set
CONFIG_CHARGER_MANAGER=y
CONFIG_CHARGER_LTC3651=y
CONFIG_CHARGER_DETECTOR_MAX14656=y
CONFIG_CHARGER_MAX77693=y
CONFIG_CHARGER_MAX8997=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24257=y
CONFIG_CHARGER_BQ24735=y
# CONFIG_CHARGER_BQ25890 is not set
CONFIG_CHARGER_SMB347=y
CONFIG_CHARGER_TPS65217=y
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
CONFIG_CHARGER_RT9455=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_ABITUGURU3=y
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=y
# CONFIG_SENSORS_ASC7621 is not set
CONFIG_SENSORS_K8TEMP=y
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ASPEED is not set
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_FTSTEUTATES=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_IIO_HWMON is not set
CONFIG_SENSORS_I5500=y
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX31722 is not set
CONFIG_SENSORS_MAX6621=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_TC654=y
CONFIG_SENSORS_MENF21BMC_HWMON=y
CONFIG_SENSORS_ADCXX=y
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=y
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
CONFIG_SENSORS_PWM_FAN=y
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHT3x=y
# CONFIG_SENSORS_SHTC1 is not set
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
CONFIG_SENSORS_SCH5636=y
CONFIG_SENSORS_STTS751=y
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_ADC128D818=y
# CONFIG_SENSORS_ADS1015 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_ADS7871 is not set
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=y
# CONFIG_SENSORS_INA3221 is not set
CONFIG_SENSORS_TC74=y
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP103=y
# CONFIG_SENSORS_TMP108 is not set
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83773G=y
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
# CONFIG_THERMAL_OF is not set
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
CONFIG_CLOCK_THERMAL=y
CONFIG_DEVFREQ_THERMAL=y
CONFIG_THERMAL_EMULATION=y
CONFIG_MAX77620_THERMAL=y
CONFIG_DA9062_THERMAL=y
CONFIG_X86_PKG_TEMP_THERMAL=y
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
CONFIG_INTEL_SOC_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=y
CONFIG_GENERIC_ADC_THERMAL=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
CONFIG_WATCHDOG_NOWAYOUT=y
CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED=y
CONFIG_WATCHDOG_SYSFS=y

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_DA9055_WATCHDOG=y
# CONFIG_DA9063_WATCHDOG is not set
# CONFIG_DA9062_WATCHDOG is not set
CONFIG_GPIO_WATCHDOG=y
# CONFIG_GPIO_WATCHDOG_ARCH_INITCALL is not set
CONFIG_MENF21BMC_WATCHDOG=y
# CONFIG_WDAT_WDT is not set
# CONFIG_WM831X_WATCHDOG is not set
CONFIG_XILINX_WATCHDOG=y
CONFIG_ZIIRAVE_WATCHDOG=y
CONFIG_CADENCE_WATCHDOG=y
CONFIG_DW_WATCHDOG=y
CONFIG_RN5T618_WATCHDOG=y
CONFIG_TWL4030_WATCHDOG=y
CONFIG_MAX63XX_WATCHDOG=y
CONFIG_MAX77620_WATCHDOG=y
CONFIG_RETU_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_EBC_C384_WDT=y
CONFIG_F71808E_WDT=y
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
# CONFIG_I6300ESB_WDT is not set
CONFIG_IE6XX_WDT=y
CONFIG_ITCO_WDT=y
# CONFIG_ITCO_VENDOR_SUPPORT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
CONFIG_HP_WATCHDOG=y
CONFIG_KEMPLD_WDT=y
# CONFIG_HPWDT_NMI_DECODING is not set
CONFIG_SC1200_WDT=y
CONFIG_SCx200_WDT=y
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=y
# CONFIG_SBC8360_WDT is not set
CONFIG_SBC7240_WDT=y
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
CONFIG_INTEL_MEI_WDT=y
# CONFIG_NI903X_WDT is not set
# CONFIG_NIC7018_WDT is not set
CONFIG_MEN_A21_WDT=y

#
# ISA-based Watchdog Cards
#
CONFIG_PCWATCHDOG=y
CONFIG_MIXCOMWD=y
# CONFIG_WDT is not set

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=y

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set

#
# Watchdog Pretimeout Governors
#
# CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
# CONFIG_SSB_PCIHOST is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
# CONFIG_SSB_PCMCIAHOST is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
# CONFIG_SSB_SDIOHOST is not set
# CONFIG_SSB_SILENT is not set
CONFIG_SSB_DEBUG=y
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
# CONFIG_BCMA_HOST_PCI is not set
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
CONFIG_MFD_ACT8945A=y
CONFIG_MFD_AS3711=y
CONFIG_MFD_AS3722=y
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
# CONFIG_MFD_ATMEL_FLEXCOM is not set
CONFIG_MFD_ATMEL_HLCDC=y
# CONFIG_MFD_BCM590XX is not set
CONFIG_MFD_BD9571MWV=y
CONFIG_MFD_AXP20X=y
CONFIG_MFD_AXP20X_I2C=y
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
CONFIG_MFD_CROS_EC_SPI=y
CONFIG_MFD_CROS_EC_CHARDEV=y
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
CONFIG_MFD_DLN2=y
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_MFD_HI6421_PMIC is not set
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_INTEL_SOC_PMIC_CHTWC is not set
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
CONFIG_MFD_INTEL_LPSS=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
CONFIG_MFD_INTEL_LPSS_PCI=y
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
CONFIG_MFD_MAX77620=y
CONFIG_MFD_MAX77686=y
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
CONFIG_EZX_PCAP=y
# CONFIG_MFD_CPCAP is not set
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
CONFIG_MFD_RDC321X=y
# CONFIG_MFD_RT5033 is not set
CONFIG_MFD_RC5T583=y
CONFIG_MFD_RK808=y
CONFIG_MFD_RN5T618=y
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SKY81452 is not set
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_TI_LMU is not set
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS68470 is not set
CONFIG_MFD_TI_LP873X=y
# CONFIG_MFD_TI_LP87565 is not set
CONFIG_MFD_TPS65218=y
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
CONFIG_MFD_TIMBERDALE=y
# CONFIG_MFD_TC3589X is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_CS47L24=y
# CONFIG_MFD_WM5102 is not set
CONFIG_MFD_WM5110=y
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8998=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_RAVE_SP_CORE is not set
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PG86X=y
CONFIG_REGULATOR_88PM800=y
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_ACT8945A=y
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_ANATOP is not set
CONFIG_REGULATOR_AAT2870=y
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_AS3722=y
# CONFIG_REGULATOR_AXP20X is not set
# CONFIG_REGULATOR_BD9571MWV is not set
CONFIG_REGULATOR_DA9055=y
CONFIG_REGULATOR_DA9062=y
# CONFIG_REGULATOR_DA9063 is not set
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
# CONFIG_REGULATOR_FAN53555 is not set
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_ISL9305 is not set
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP873X=y
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LTC3589=y
# CONFIG_REGULATOR_LTC3676 is not set
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX77620=y
# CONFIG_REGULATOR_MAX8649 is not set
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8997=y
CONFIG_REGULATOR_MAX77686=y
CONFIG_REGULATOR_MAX77693=y
# CONFIG_REGULATOR_MAX77802 is not set
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_MT6323=y
# CONFIG_REGULATOR_MT6397 is not set
# CONFIG_REGULATOR_PALMAS is not set
CONFIG_REGULATOR_PCAP=y
CONFIG_REGULATOR_PFUZE100=y
# CONFIG_REGULATOR_PV88060 is not set
CONFIG_REGULATOR_PV88080=y
# CONFIG_REGULATOR_PV88090 is not set
CONFIG_REGULATOR_PWM=y
CONFIG_REGULATOR_RC5T583=y
# CONFIG_REGULATOR_RK808 is not set
CONFIG_REGULATOR_RN5T618=y
CONFIG_REGULATOR_S2MPA01=y
# CONFIG_REGULATOR_S2MPS11 is not set
CONFIG_REGULATOR_S5M8767=y
# CONFIG_REGULATOR_SY8106A is not set
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
# CONFIG_REGULATOR_TPS6507X is not set
# CONFIG_REGULATOR_TPS65132 is not set
CONFIG_REGULATOR_TPS65217=y
CONFIG_REGULATOR_TPS65218=y
CONFIG_REGULATOR_TPS6524X=y
# CONFIG_REGULATOR_TPS6586X is not set
CONFIG_REGULATOR_TPS65910=y
# CONFIG_REGULATOR_TPS65912 is not set
# CONFIG_REGULATOR_TWL4030 is not set
# CONFIG_REGULATOR_VCTRL is not set
CONFIG_REGULATOR_WM831X=y
# CONFIG_REGULATOR_WM8400 is not set
CONFIG_CEC_CORE=y
# CONFIG_RC_CORE is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
CONFIG_MEDIA_SDR_SUPPORT=y
CONFIG_MEDIA_CEC_SUPPORT=y
CONFIG_MEDIA_CONTROLLER=y
CONFIG_MEDIA_CONTROLLER_DVB=y
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2_SUBDEV_API=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_VIDEO_TUNER=y
CONFIG_V4L2_FWNODE=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_VMALLOC=y
CONFIG_DVB_CORE=y
# CONFIG_DVB_MMAP is not set
CONFIG_DVB_NET=y
CONFIG_DVB_MAX_ADAPTERS=16
# CONFIG_DVB_DYNAMIC_MINORS is not set
CONFIG_DVB_DEMUX_SECTION_LOSS_LOG=y
CONFIG_DVB_ULE_DEBUG=y

#
# Media drivers
#
CONFIG_MEDIA_USB_SUPPORT=y

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_AU0828=y
CONFIG_VIDEO_AU0828_V4L2=y
CONFIG_VIDEO_CX231XX=y
# CONFIG_VIDEO_CX231XX_DVB is not set

#
# Digital TV USB devices
#
# CONFIG_DVB_USB_V2 is not set
CONFIG_DVB_TTUSB_BUDGET=y
CONFIG_DVB_TTUSB_DEC=y
CONFIG_SMS_USB_DRV=y
CONFIG_DVB_B2C2_FLEXCOP_USB=y
# CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG is not set
CONFIG_DVB_AS102=y

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=y
CONFIG_VIDEO_EM28XX_V4L2=y
CONFIG_VIDEO_EM28XX_DVB=y

#
# Software defined radio USB devices
#
CONFIG_USB_AIRSPY=y
CONFIG_USB_HACKRF=y
CONFIG_USB_MSI2500=y

#
# USB HDMI CEC adapters
#
# CONFIG_USB_PULSE8_CEC is not set
CONFIG_USB_RAINSHADOW_CEC=y
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_DVB_PLATFORM_DRIVERS is not set
# CONFIG_CEC_PLATFORM_DRIVERS is not set
CONFIG_SDR_PLATFORM_DRIVERS=y

#
# Supported MMC/SDIO adapters
#
# CONFIG_SMS_SDIO_DRV is not set
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=y
# CONFIG_RADIO_SI470X is not set
CONFIG_RADIO_SI4713=y
CONFIG_USB_SI4713=y
CONFIG_PLATFORM_SI4713=y
CONFIG_I2C_SI4713=y
CONFIG_USB_MR800=y
CONFIG_USB_DSBR=y
CONFIG_RADIO_MAXIRADIO=y
# CONFIG_RADIO_SHARK is not set
CONFIG_RADIO_SHARK2=y
# CONFIG_USB_KEENE is not set
# CONFIG_USB_RAREMONO is not set
# CONFIG_USB_MA901 is not set
CONFIG_RADIO_TEA5764=y
# CONFIG_RADIO_TEA5764_XTAL is not set
CONFIG_RADIO_SAA7706H=y
CONFIG_RADIO_TEF6862=y
CONFIG_RADIO_TIMBERDALE=y
# CONFIG_RADIO_WL1273 is not set

#
# Texas Instruments WL128x FM driver (ST based)
#
# CONFIG_V4L_RADIO_ISA_DRIVERS is not set

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=y
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_CX2341X=y
CONFIG_VIDEO_TVEEPROM=y
# CONFIG_CYPRESS_FIRMWARE is not set
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_V4L2=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_DVB_B2C2_FLEXCOP=y
CONFIG_SMS_SIANO_MDTV=y

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_MSP3400=y

#
# RDS decoders
#

#
# Video decoders
#
CONFIG_VIDEO_SAA711X=y
CONFIG_VIDEO_TVP5150=y

#
# Video and audio decoders
#
CONFIG_VIDEO_CX25840=y

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# SDR tuner chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#

#
# Media SPI Adapters
#
# CONFIG_CXD2880_SPI_DRV is not set
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MSI001=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_QT1010=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5007T=y
CONFIG_MEDIA_TUNER_MC44S803=y
CONFIG_MEDIA_TUNER_TDA18212=y
CONFIG_MEDIA_TUNER_SI2157=y
CONFIG_MEDIA_TUNER_QM1D1C0042=y

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_M88DS3103=y

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=y
CONFIG_DVB_TDA18271C2DD=y

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24123=y
CONFIG_DVB_MT312=y
CONFIG_DVB_S5H1420=y
CONFIG_DVB_STV0299=y
CONFIG_DVB_TDA8083=y
CONFIG_DVB_TUNER_ITD1000=y
CONFIG_DVB_TUNER_CX24113=y
CONFIG_DVB_CX24120=y
CONFIG_DVB_TS2020=y
CONFIG_DVB_TDA10071=y

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_CX22700=y
CONFIG_DVB_DRXD=y
CONFIG_DVB_TDA1004X=y
CONFIG_DVB_MT352=y
CONFIG_DVB_ZL10353=y
CONFIG_DVB_CXD2820R=y
CONFIG_DVB_SI2168=y
CONFIG_DVB_AS102_FE=y

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
CONFIG_DVB_TDA10023=y
CONFIG_DVB_STV0297=y

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
CONFIG_DVB_BCM3510=y
CONFIG_DVB_LGDT330X=y
CONFIG_DVB_LGDT3305=y
CONFIG_DVB_LGDT3306A=y
CONFIG_DVB_S5H1409=y
CONFIG_DVB_AU8522=y
CONFIG_DVB_AU8522_DTV=y
CONFIG_DVB_AU8522_V4L=y

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=y
CONFIG_DVB_MB86A20S=y

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=y

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=y
CONFIG_DVB_LNBP21=y
CONFIG_DVB_ISL6421=y
CONFIG_DVB_A8293=y

#
# Common Interface (EN50221) controller drivers
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
# CONFIG_DRM is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_SVGALIB=y
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
CONFIG_FB_PM2=y
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
# CONFIG_FB_OPENCORES is not set
# CONFIG_FB_S1D13XXX is not set
CONFIG_FB_NVIDIA=y
CONFIG_FB_NVIDIA_I2C=y
CONFIG_FB_NVIDIA_DEBUG=y
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=y
CONFIG_FB_RIVA_I2C=y
# CONFIG_FB_RIVA_DEBUG is not set
CONFIG_FB_RIVA_BACKLIGHT=y
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
# CONFIG_FB_RADEON_BACKLIGHT is not set
CONFIG_FB_RADEON_DEBUG=y
CONFIG_FB_ATY128=y
# CONFIG_FB_ATY128_BACKLIGHT is not set
CONFIG_FB_ATY=y
CONFIG_FB_ATY_CT=y
CONFIG_FB_ATY_GENERIC_LCD=y
# CONFIG_FB_ATY_GX is not set
CONFIG_FB_ATY_BACKLIGHT=y
CONFIG_FB_S3=y
# CONFIG_FB_S3_DDC is not set
CONFIG_FB_SAVAGE=y
CONFIG_FB_SAVAGE_I2C=y
CONFIG_FB_SAVAGE_ACCEL=y
# CONFIG_FB_SIS is not set
CONFIG_FB_VIA=y
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
CONFIG_FB_VIA_X_COMPATIBILITY=y
# CONFIG_FB_NEOMAGIC is not set
CONFIG_FB_KYRO=y
# CONFIG_FB_3DFX is not set
CONFIG_FB_VOODOO1=y
CONFIG_FB_VT8623=y
# CONFIG_FB_TRIDENT is not set
CONFIG_FB_ARK=y
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=y
CONFIG_FB_CARMINE_DRAM_EVAL=y
# CONFIG_CARMINE_DRAM_CUSTOM is not set
CONFIG_FB_GEODE=y
# CONFIG_FB_GEODE_LX is not set
# CONFIG_FB_GEODE_GX is not set
# CONFIG_FB_GEODE_GX1 is not set
# CONFIG_FB_SMSCUFX is not set
CONFIG_FB_UDL=y
CONFIG_FB_IBM_GXT4500=y
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
CONFIG_FB_SIMPLE=y
CONFIG_FB_SSD1307=y
CONFIG_FB_SM712=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_L4F00242T03=y
CONFIG_LCD_LMS283GF05=y
CONFIG_LCD_LTV350QV=y
# CONFIG_LCD_ILI922X is not set
CONFIG_LCD_ILI9320=y
# CONFIG_LCD_TDO24M is not set
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_S6E63M0=y
CONFIG_LCD_LD9040=y
CONFIG_LCD_AMS369FG06=y
# CONFIG_LCD_LMS501KF03 is not set
CONFIG_LCD_HX8357=y
CONFIG_LCD_OTM3225A=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_PWM=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP5520=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3630A=y
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=y
# CONFIG_BACKLIGHT_PANDORA is not set
CONFIG_BACKLIGHT_TPS65217=y
CONFIG_BACKLIGHT_AS3711=y
CONFIG_BACKLIGHT_GPIO=y
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
CONFIG_BACKLIGHT_ARCXCNN=y
CONFIG_VGASTATE=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
CONFIG_LOGO_LINUX_VGA16=y
# CONFIG_LOGO_LINUX_CLUT224 is not set
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=y
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACCUTOUCH is not set
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_APPLEIR=y
CONFIG_HID_ASUS=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_BETOP_FF=y
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CORSAIR is not set
CONFIG_HID_CMEDIA=y
# CONFIG_HID_CP2112 is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELAN=y
CONFIG_HID_ELECOM=y
CONFIG_HID_ELO=y
# CONFIG_HID_EZKEY is not set
CONFIG_HID_GEMBIRD=y
CONFIG_HID_GFRM=y
CONFIG_HID_HOLTEK=y
# CONFIG_HOLTEK_FF is not set
CONFIG_HID_GOOGLE_HAMMER=y
# CONFIG_HID_GT683R is not set
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=y
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
# CONFIG_HID_ITE is not set
CONFIG_HID_JABRA=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
CONFIG_HID_LENOVO=y
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MAYFLASH is not set
CONFIG_HID_REDRAGON=y
CONFIG_HID_MICROSOFT=y
# CONFIG_HID_MONTEREY is not set
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_NTI=y
CONFIG_HID_NTRIG=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PENMOUNT=y
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PLANTRONICS=y
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_RETRODE=y
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
CONFIG_SONY_FF=y
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEAM=y
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_UDRAW_PS3=y
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
# CONFIG_HID_ZEROPLUS is not set
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set
# CONFIG_HID_ALPS is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_PCI=y
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_OTG is not set
CONFIG_USB_OTG_WHITELIST=y
CONFIG_USB_OTG_BLACKLIST_HUB=y
# CONFIG_USB_LEDS_TRIGGER_USBPORT is not set
# CONFIG_USB_MON is not set
CONFIG_USB_WUSB_CBAF=y
CONFIG_USB_WUSB_CBAF_DEBUG=y

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_FOTG210_HCD=y
CONFIG_USB_MAX3421_HCD=y
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_HCD_PCI is not set
# CONFIG_USB_OHCI_HCD_SSB is not set
CONFIG_USB_OHCI_HCD_PLATFORM=y
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=y
# CONFIG_USB_R8A66597_HCD is not set
CONFIG_USB_HCD_BCMA=y
# CONFIG_USB_HCD_SSB is not set
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
# CONFIG_USBIP_CORE is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
# CONFIG_MUSB_PIO_ONLY is not set
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_ULPI=y
CONFIG_USB_DWC3_HOST=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
CONFIG_USB_DWC3_OF_SIMPLE=y
CONFIG_USB_DWC2=y
CONFIG_USB_DWC2_HOST=y

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
# CONFIG_USB_DWC2_PCI is not set
CONFIG_USB_DWC2_DEBUG=y
CONFIG_USB_DWC2_VERBOSE=y
CONFIG_USB_DWC2_TRACK_MISSED_SOFS=y
# CONFIG_USB_DWC2_DEBUG_PERIODIC is not set
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_OF=y
CONFIG_USB_CHIPIDEA_PCI=y
CONFIG_USB_CHIPIDEA_HOST=y
CONFIG_USB_CHIPIDEA_ULPI=y
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y

#
# USB port drivers
#
CONFIG_USB_USS720=y
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
# CONFIG_USB_SERIAL_GENERIC is not set
CONFIG_USB_SERIAL_SIMPLE=y
# CONFIG_USB_SERIAL_AIRCABLE is not set
# CONFIG_USB_SERIAL_ARK3116 is not set
CONFIG_USB_SERIAL_BELKIN=y
CONFIG_USB_SERIAL_CH341=y
CONFIG_USB_SERIAL_WHITEHEAT=y
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=y
CONFIG_USB_SERIAL_CP210X=y
CONFIG_USB_SERIAL_CYPRESS_M8=y
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
# CONFIG_USB_SERIAL_VISOR is not set
# CONFIG_USB_SERIAL_IPAQ is not set
CONFIG_USB_SERIAL_IR=y
CONFIG_USB_SERIAL_EDGEPORT=y
CONFIG_USB_SERIAL_EDGEPORT_TI=y
CONFIG_USB_SERIAL_F81232=y
CONFIG_USB_SERIAL_F8153X=y
# CONFIG_USB_SERIAL_GARMIN is not set
CONFIG_USB_SERIAL_IPW=y
CONFIG_USB_SERIAL_IUU=y
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
CONFIG_USB_SERIAL_KEYSPAN=y
CONFIG_USB_SERIAL_KLSI=y
CONFIG_USB_SERIAL_KOBIL_SCT=y
CONFIG_USB_SERIAL_MCT_U232=y
CONFIG_USB_SERIAL_METRO=y
# CONFIG_USB_SERIAL_MOS7720 is not set
CONFIG_USB_SERIAL_MOS7840=y
CONFIG_USB_SERIAL_MXUPORT=y
# CONFIG_USB_SERIAL_NAVMAN is not set
CONFIG_USB_SERIAL_PL2303=y
# CONFIG_USB_SERIAL_OTI6858 is not set
CONFIG_USB_SERIAL_QCAUX=y
CONFIG_USB_SERIAL_QUALCOMM=y
CONFIG_USB_SERIAL_SPCP8X5=y
CONFIG_USB_SERIAL_SAFE=y
CONFIG_USB_SERIAL_SAFE_PADDED=y
CONFIG_USB_SERIAL_SIERRAWIRELESS=y
# CONFIG_USB_SERIAL_SYMBOL is not set
# CONFIG_USB_SERIAL_TI is not set
CONFIG_USB_SERIAL_CYBERJACK=y
CONFIG_USB_SERIAL_XIRCOM=y
CONFIG_USB_SERIAL_WWAN=y
CONFIG_USB_SERIAL_OPTION=y
# CONFIG_USB_SERIAL_OMNINET is not set
CONFIG_USB_SERIAL_OPTICON=y
CONFIG_USB_SERIAL_XSENS_MT=y
CONFIG_USB_SERIAL_WISHBONE=y
# CONFIG_USB_SERIAL_SSU100 is not set
CONFIG_USB_SERIAL_QT2=y
CONFIG_USB_SERIAL_UPD78F0730=y
CONFIG_USB_SERIAL_DEBUG=y

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
# CONFIG_USB_EMI26 is not set
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
CONFIG_USB_HUB_USB251XB=y
CONFIG_USB_HSIC_USB3503=y
# CONFIG_USB_HSIC_USB4604 is not set
CONFIG_USB_LINK_LAYER_TEST=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_GPIO_VBUS=y
CONFIG_TAHVO_USB=y
CONFIG_TAHVO_USB_HOST_BY_DEFAULT=y
CONFIG_USB_ISP1301=y
# CONFIG_USB_GADGET is not set
# CONFIG_TYPEC is not set
# CONFIG_USB_ROLES_INTEL_XHCI is not set
# CONFIG_USB_LED_TRIG is not set
CONFIG_USB_ULPI_BUS=y
CONFIG_USB_ROLE_SWITCH=y
# CONFIG_UWB is not set
CONFIG_MMC=y
CONFIG_PWRSEQ_EMMC=y
CONFIG_PWRSEQ_SD8787=y
CONFIG_PWRSEQ_SIMPLE=y
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_SDIO_UART=y
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PCI=y
# CONFIG_MMC_RICOH_MMC is not set
# CONFIG_MMC_SDHCI_ACPI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
# CONFIG_MMC_SPI is not set
CONFIG_MMC_SDRICOH_CS=y
# CONFIG_MMC_CB710 is not set
CONFIG_MMC_VIA_SDMMC=y
# CONFIG_MMC_VUB300 is not set
CONFIG_MMC_USHC=y
CONFIG_MMC_USDHI6ROL0=y
CONFIG_MMC_REALTEK_PCI=y
CONFIG_MMC_CQHCI=y
CONFIG_MMC_TOSHIBA_PCI=y
CONFIG_MMC_MTK=y
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
# CONFIG_LEDS_APU is not set
CONFIG_LEDS_BCM6328=y
# CONFIG_LEDS_BCM6358 is not set
# CONFIG_LEDS_CR0014114 is not set
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_LM3692X=y
CONFIG_LEDS_MT6323=y
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP5562 is not set
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_LP8860=y
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA955X_GPIO is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_WM831X_STATUS is not set
# CONFIG_LEDS_DAC124S085 is not set
CONFIG_LEDS_PWM=y
CONFIG_LEDS_REGULATOR=y
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_INTEL_SS4200=y
# CONFIG_LEDS_LT3593 is not set
CONFIG_LEDS_ADP5520=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_TLC591XX=y
CONFIG_LEDS_MAX8997=y
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_OT200=y
# CONFIG_LEDS_MENF21BMC is not set
CONFIG_LEDS_IS31FL319X=y
CONFIG_LEDS_IS31FL32XX=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
# CONFIG_LEDS_SYSCON is not set
CONFIG_LEDS_MLXCPLD=y
CONFIG_LEDS_MLXREG=y
# CONFIG_LEDS_USER is not set
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
# CONFIG_LEDS_TRIGGER_CPU is not set
CONFIG_LEDS_TRIGGER_ACTIVITY=y
CONFIG_LEDS_TRIGGER_GPIO=y
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_LEDS_TRIGGER_PANIC is not set
CONFIG_LEDS_TRIGGER_NETDEV=y
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set
# CONFIG_RTC_NVMEM is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
# CONFIG_RTC_INTF_DEV is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM80X=y
CONFIG_RTC_DRV_ABB5ZES3=y
# CONFIG_RTC_DRV_ABX80X is not set
# CONFIG_RTC_DRV_AS3722 is not set
CONFIG_RTC_DRV_DS1307=y
# CONFIG_RTC_DRV_DS1307_HWMON is not set
# CONFIG_RTC_DRV_DS1307_CENTURY is not set
CONFIG_RTC_DRV_DS1374=y
# CONFIG_RTC_DRV_DS1374_WDT is not set
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_HYM8563=y
CONFIG_RTC_DRV_MAX6900=y
# CONFIG_RTC_DRV_MAX8907 is not set
CONFIG_RTC_DRV_MAX8997=y
CONFIG_RTC_DRV_MAX77686=y
CONFIG_RTC_DRV_RK808=y
# CONFIG_RTC_DRV_RS5C372 is not set
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_ISL12026=y
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PCF8523=y
CONFIG_RTC_DRV_PCF85063=y
CONFIG_RTC_DRV_PCF85363=y
CONFIG_RTC_DRV_PCF8563=y
# CONFIG_RTC_DRV_PCF8583 is not set
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_TWL4030=y
# CONFIG_RTC_DRV_PALMAS is not set
CONFIG_RTC_DRV_TPS6586X=y
# CONFIG_RTC_DRV_TPS65910 is not set
CONFIG_RTC_DRV_RC5T583=y
CONFIG_RTC_DRV_S35390A=y
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8010 is not set
CONFIG_RTC_DRV_RX8581=y
# CONFIG_RTC_DRV_RX8025 is not set
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV8803=y
CONFIG_RTC_DRV_S5M=y

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
# CONFIG_RTC_DRV_M41T94 is not set
CONFIG_RTC_DRV_DS1302=y
CONFIG_RTC_DRV_DS1305=y
CONFIG_RTC_DRV_DS1343=y
CONFIG_RTC_DRV_DS1347=y
CONFIG_RTC_DRV_DS1390=y
# CONFIG_RTC_DRV_MAX6916 is not set
CONFIG_RTC_DRV_R9701=y
# CONFIG_RTC_DRV_RX4581 is not set
CONFIG_RTC_DRV_RX6110=y
# CONFIG_RTC_DRV_RS5C348 is not set
# CONFIG_RTC_DRV_MAX6902 is not set
CONFIG_RTC_DRV_PCF2123=y
CONFIG_RTC_DRV_MCP795=y
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=y
CONFIG_RTC_DRV_DS3232_HWMON=y
# CONFIG_RTC_DRV_PCF2127 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1685_FAMILY=y
# CONFIG_RTC_DRV_DS1685 is not set
CONFIG_RTC_DRV_DS1689=y
# CONFIG_RTC_DRV_DS17285 is not set
# CONFIG_RTC_DRV_DS17485 is not set
# CONFIG_RTC_DRV_DS17885 is not set
# CONFIG_RTC_DS1685_PROC_REGS is not set
# CONFIG_RTC_DS1685_SYSFS_REGS is not set
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DS2404=y
# CONFIG_RTC_DRV_DA9055 is not set
CONFIG_RTC_DRV_DA9063=y
# CONFIG_RTC_DRV_STK17TA8 is not set
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
# CONFIG_RTC_DRV_RP5C01 is not set
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_WM831X=y
# CONFIG_RTC_DRV_ZYNQMP is not set
CONFIG_RTC_DRV_CROS_EC=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_FTRTC010=y
# CONFIG_RTC_DRV_PCAP is not set
CONFIG_RTC_DRV_SNVS=y
# CONFIG_RTC_DRV_MT6397 is not set
# CONFIG_RTC_DRV_R7301 is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
# CONFIG_DMADEVICES_VDEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y
CONFIG_ALTERA_MSGDMA=y
CONFIG_DW_AXI_DMAC=y
# CONFIG_FSL_EDMA is not set
CONFIG_INTEL_IDMA64=y
CONFIG_PCH_DMA=y
# CONFIG_TIMB_DMA is not set
CONFIG_QCOM_HIDMA_MGMT=y
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
# CONFIG_DW_DMAC is not set
CONFIG_DW_DMAC_PCI=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
# CONFIG_SYNC_FILE is not set
CONFIG_AUXDISPLAY=y
# CONFIG_HD44780 is not set
CONFIG_IMG_ASCII_LCD=y
CONFIG_HT16K33=y
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
CONFIG_CHARLCD=y
# CONFIG_UIO is not set
CONFIG_IRQ_BYPASS_MANAGER=y
CONFIG_VIRT_DRIVERS=y
CONFIG_VBOXGUEST=y
CONFIG_VIRTIO=y
CONFIG_VIRTIO_MENU=y
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_INPUT is not set
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_PRISM2_USB is not set
CONFIG_COMEDI=y
# CONFIG_COMEDI_DEBUG is not set
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
# CONFIG_COMEDI_MISC_DRIVERS is not set
CONFIG_COMEDI_ISA_DRIVERS=y
# CONFIG_COMEDI_PCL711 is not set
CONFIG_COMEDI_PCL724=y
CONFIG_COMEDI_PCL726=y
# CONFIG_COMEDI_PCL730 is not set
# CONFIG_COMEDI_PCL812 is not set
# CONFIG_COMEDI_PCL816 is not set
# CONFIG_COMEDI_PCL818 is not set
CONFIG_COMEDI_PCM3724=y
CONFIG_COMEDI_AMPLC_DIO200_ISA=y
# CONFIG_COMEDI_AMPLC_PC236_ISA is not set
CONFIG_COMEDI_AMPLC_PC263_ISA=y
# CONFIG_COMEDI_RTI800 is not set
CONFIG_COMEDI_RTI802=y
CONFIG_COMEDI_DAC02=y
CONFIG_COMEDI_DAS16M1=y
# CONFIG_COMEDI_DAS08_ISA is not set
# CONFIG_COMEDI_DAS16 is not set
CONFIG_COMEDI_DAS800=y
CONFIG_COMEDI_DAS1800=y
CONFIG_COMEDI_DAS6402=y
# CONFIG_COMEDI_DT2801 is not set
CONFIG_COMEDI_DT2811=y
# CONFIG_COMEDI_DT2814 is not set
CONFIG_COMEDI_DT2815=y
CONFIG_COMEDI_DT2817=y
CONFIG_COMEDI_DT282X=y
CONFIG_COMEDI_DMM32AT=y
# CONFIG_COMEDI_FL512 is not set
# CONFIG_COMEDI_AIO_AIO12_8 is not set
# CONFIG_COMEDI_AIO_IIRO_16 is not set
CONFIG_COMEDI_II_PCI20KC=y
# CONFIG_COMEDI_C6XDIGIO is not set
# CONFIG_COMEDI_MPC624 is not set
CONFIG_COMEDI_ADQ12B=y
CONFIG_COMEDI_NI_AT_A2150=y
CONFIG_COMEDI_NI_AT_AO=y
CONFIG_COMEDI_NI_ATMIO=y
CONFIG_COMEDI_NI_ATMIO16D=y
# CONFIG_COMEDI_NI_LABPC_ISA is not set
CONFIG_COMEDI_PCMAD=y
CONFIG_COMEDI_PCMDA12=y
CONFIG_COMEDI_PCMMIO=y
# CONFIG_COMEDI_PCMUIO is not set
CONFIG_COMEDI_MULTIQ3=y
CONFIG_COMEDI_S526=y
CONFIG_COMEDI_PCI_DRIVERS=y
CONFIG_COMEDI_8255_PCI=y
CONFIG_COMEDI_ADDI_WATCHDOG=y
CONFIG_COMEDI_ADDI_APCI_1032=y
CONFIG_COMEDI_ADDI_APCI_1500=y
# CONFIG_COMEDI_ADDI_APCI_1516 is not set
CONFIG_COMEDI_ADDI_APCI_1564=y
# CONFIG_COMEDI_ADDI_APCI_16XX is not set
# CONFIG_COMEDI_ADDI_APCI_2032 is not set
CONFIG_COMEDI_ADDI_APCI_2200=y
CONFIG_COMEDI_ADDI_APCI_3120=y
CONFIG_COMEDI_ADDI_APCI_3501=y
CONFIG_COMEDI_ADDI_APCI_3XXX=y
# CONFIG_COMEDI_ADL_PCI6208 is not set
CONFIG_COMEDI_ADL_PCI7X3X=y
# CONFIG_COMEDI_ADL_PCI8164 is not set
# CONFIG_COMEDI_ADL_PCI9111 is not set
# CONFIG_COMEDI_ADL_PCI9118 is not set
# CONFIG_COMEDI_ADV_PCI1710 is not set
CONFIG_COMEDI_ADV_PCI1720=y
# CONFIG_COMEDI_ADV_PCI1723 is not set
CONFIG_COMEDI_ADV_PCI1724=y
CONFIG_COMEDI_ADV_PCI1760=y
CONFIG_COMEDI_ADV_PCI_DIO=y
# CONFIG_COMEDI_AMPLC_DIO200_PCI is not set
CONFIG_COMEDI_AMPLC_PC236_PCI=y
CONFIG_COMEDI_AMPLC_PC263_PCI=y
CONFIG_COMEDI_AMPLC_PCI224=y
CONFIG_COMEDI_AMPLC_PCI230=y
CONFIG_COMEDI_CONTEC_PCI_DIO=y
CONFIG_COMEDI_DAS08_PCI=y
# CONFIG_COMEDI_DT3000 is not set
CONFIG_COMEDI_DYNA_PCI10XX=y
# CONFIG_COMEDI_GSC_HPDI is not set
CONFIG_COMEDI_MF6X4=y
CONFIG_COMEDI_ICP_MULTI=y
# CONFIG_COMEDI_DAQBOARD2000 is not set
CONFIG_COMEDI_JR3_PCI=y
CONFIG_COMEDI_KE_COUNTER=y
# CONFIG_COMEDI_CB_PCIDAS64 is not set
CONFIG_COMEDI_CB_PCIDAS=y
# CONFIG_COMEDI_CB_PCIDDA is not set
CONFIG_COMEDI_CB_PCIMDAS=y
# CONFIG_COMEDI_CB_PCIMDDA is not set
# CONFIG_COMEDI_ME4000 is not set
CONFIG_COMEDI_ME_DAQ=y
# CONFIG_COMEDI_NI_6527 is not set
CONFIG_COMEDI_NI_65XX=y
CONFIG_COMEDI_NI_660X=y
CONFIG_COMEDI_NI_670X=y
CONFIG_COMEDI_NI_LABPC_PCI=y
CONFIG_COMEDI_NI_PCIDIO=y
CONFIG_COMEDI_NI_PCIMIO=y
CONFIG_COMEDI_RTD520=y
# CONFIG_COMEDI_S626 is not set
CONFIG_COMEDI_MITE=y
CONFIG_COMEDI_NI_TIOCMD=y
CONFIG_COMEDI_PCMCIA_DRIVERS=y
CONFIG_COMEDI_CB_DAS16_CS=y
CONFIG_COMEDI_DAS08_CS=y
# CONFIG_COMEDI_NI_DAQ_700_CS is not set
CONFIG_COMEDI_NI_DAQ_DIO24_CS=y
CONFIG_COMEDI_NI_LABPC_CS=y
CONFIG_COMEDI_NI_MIO_CS=y
# CONFIG_COMEDI_QUATECH_DAQP_CS is not set
CONFIG_COMEDI_USB_DRIVERS=y
CONFIG_COMEDI_DT9812=y
# CONFIG_COMEDI_NI_USB6501 is not set
# CONFIG_COMEDI_USBDUX is not set
# CONFIG_COMEDI_USBDUXFAST is not set
CONFIG_COMEDI_USBDUXSIGMA=y
CONFIG_COMEDI_VMK80XX=y
CONFIG_COMEDI_8254=y
CONFIG_COMEDI_8255=y
CONFIG_COMEDI_8255_SA=y
CONFIG_COMEDI_KCOMEDILIB=y
CONFIG_COMEDI_AMPLC_DIO200=y
CONFIG_COMEDI_AMPLC_PC236=y
CONFIG_COMEDI_DAS08=y
CONFIG_COMEDI_ISADMA=y
CONFIG_COMEDI_NI_LABPC=y
CONFIG_COMEDI_NI_TIO=y
CONFIG_FB_OLPC_DCON=y
# CONFIG_FB_OLPC_DCON_1 is not set
CONFIG_FB_OLPC_DCON_1_5=y
# CONFIG_R8712U is not set

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16203=y
CONFIG_ADIS16240=y

#
# Analog to digital converters
#
CONFIG_AD7606=y
CONFIG_AD7606_IFACE_PARALLEL=y
CONFIG_AD7606_IFACE_SPI=y
# CONFIG_AD7780 is not set
CONFIG_AD7816=y
CONFIG_AD7192=y
# CONFIG_AD7280 is not set

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
# CONFIG_ADT7316_SPI is not set
# CONFIG_ADT7316_I2C is not set

#
# Capacitance to digital converters
#
# CONFIG_AD7150 is not set
CONFIG_AD7152=y
# CONFIG_AD7746 is not set

#
# Direct Digital Synthesis
#
# CONFIG_AD9832 is not set
# CONFIG_AD9834 is not set

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16060 is not set

#
# Network Analyzer, Impedance Converters
#
# CONFIG_AD5933 is not set

#
# Active energy metering IC
#
CONFIG_ADE7854=y
CONFIG_ADE7854_I2C=y
# CONFIG_ADE7854_SPI is not set

#
# Resolver to digital converters
#
CONFIG_AD2S90=y
CONFIG_AD2S1210=y
CONFIG_FB_SM750=y
# CONFIG_FB_XGI is not set

#
# Speakup console speech
#
CONFIG_STAGING_MEDIA=y
# CONFIG_I2C_BCM2048 is not set
# CONFIG_VIDEO_ZORAN is not set

#
# Android
#
# CONFIG_ASHMEM is not set
CONFIG_ION=y
# CONFIG_ION_SYSTEM_HEAP is not set
CONFIG_ION_CARVEOUT_HEAP=y
CONFIG_ION_CHUNK_HEAP=y
# CONFIG_ION_CMA_HEAP is not set
# CONFIG_STAGING_BOARD is not set
CONFIG_FIREWIRE_SERIAL=y
CONFIG_FWTTY_MAX_TOTAL_PORTS=64
CONFIG_FWTTY_MAX_CARD_PORTS=32
CONFIG_DGNC=y
CONFIG_GS_FPGABOOT=y
CONFIG_UNISYSSPAR=y
# CONFIG_COMMON_CLK_XLNX_CLKWZRD is not set
CONFIG_FB_TFT=y
CONFIG_FB_TFT_AGM1264K_FL=y
CONFIG_FB_TFT_BD663474=y
CONFIG_FB_TFT_HX8340BN=y
CONFIG_FB_TFT_HX8347D=y
CONFIG_FB_TFT_HX8353D=y
CONFIG_FB_TFT_HX8357D=y
CONFIG_FB_TFT_ILI9163=y
CONFIG_FB_TFT_ILI9320=y
CONFIG_FB_TFT_ILI9325=y
CONFIG_FB_TFT_ILI9340=y
# CONFIG_FB_TFT_ILI9341 is not set
CONFIG_FB_TFT_ILI9481=y
CONFIG_FB_TFT_ILI9486=y
CONFIG_FB_TFT_PCD8544=y
CONFIG_FB_TFT_RA8875=y
# CONFIG_FB_TFT_S6D02A1 is not set
CONFIG_FB_TFT_S6D1121=y
# CONFIG_FB_TFT_SH1106 is not set
CONFIG_FB_TFT_SSD1289=y
CONFIG_FB_TFT_SSD1305=y
CONFIG_FB_TFT_SSD1306=y
CONFIG_FB_TFT_SSD1331=y
# CONFIG_FB_TFT_SSD1351 is not set
CONFIG_FB_TFT_ST7735R=y
CONFIG_FB_TFT_ST7789V=y
CONFIG_FB_TFT_TINYLCD=y
CONFIG_FB_TFT_TLS8204=y
# CONFIG_FB_TFT_UC1611 is not set
CONFIG_FB_TFT_UC1701=y
# CONFIG_FB_TFT_UPD161704 is not set
CONFIG_FB_TFT_WATTEROTT=y
# CONFIG_FB_FLEX is not set
CONFIG_FB_TFT_FBTFT_DEVICE=y
# CONFIG_WILC1000_SDIO is not set
# CONFIG_WILC1000_SPI is not set
CONFIG_MOST=y
CONFIG_MOST_CDEV=y
CONFIG_MOST_NET=y
CONFIG_MOST_VIDEO=y
# CONFIG_MOST_DIM2 is not set
CONFIG_MOST_I2C=y
# CONFIG_MOST_USB is not set
CONFIG_KS7010=y
# CONFIG_GREYBUS is not set

#
# USB Power Delivery and Type-C drivers
#
CONFIG_PI433=y
CONFIG_MTK_MMC=y
CONFIG_MTK_AEE_KDUMP=y
# CONFIG_MTK_MMC_CD_POLL is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_PMC_ATOM=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=y
# CONFIG_CHROMEOS_PSTORE is not set
# CONFIG_CHROMEOS_TBMC is not set
CONFIG_CROS_EC_CTL=y
# CONFIG_CROS_EC_LPC is not set
CONFIG_CROS_EC_PROTO=y
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set
CONFIG_MELLANOX_PLATFORM=y
# CONFIG_MLXREG_HOTPLUG is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_WM831X=y
CONFIG_CLK_HSDK=y
# CONFIG_COMMON_CLK_MAX77686 is not set
CONFIG_COMMON_CLK_RK808=y
# CONFIG_COMMON_CLK_SI5351 is not set
CONFIG_COMMON_CLK_SI514=y
CONFIG_COMMON_CLK_SI544=y
CONFIG_COMMON_CLK_SI570=y
CONFIG_COMMON_CLK_CDCE706=y
CONFIG_COMMON_CLK_CDCE925=y
CONFIG_COMMON_CLK_CS2000_CP=y
# CONFIG_COMMON_CLK_S2MPS11 is not set
CONFIG_CLK_TWL6040=y
# CONFIG_COMMON_CLK_PALMAS is not set
CONFIG_COMMON_CLK_PWM=y
CONFIG_COMMON_CLK_VC5=y
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
# CONFIG_PLATFORM_MHU is not set
# CONFIG_PCC is not set
# CONFIG_ALTERA_MBOX is not set
# CONFIG_MAILBOX_TEST is not set
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
# CONFIG_RPMSG_QCOM_GLINK_RPM is not set
# CONFIG_RPMSG_VIRTIO is not set
CONFIG_SOUNDWIRE=y

#
# SoundWire Devices
#

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Broadcom SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
CONFIG_SOC_TI=y

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
CONFIG_DEVFREQ_GOV_USERSPACE=y
# CONFIG_DEVFREQ_GOV_PASSIVE is not set

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_ADC_JACK is not set
CONFIG_EXTCON_AXP288=y
CONFIG_EXTCON_GPIO=y
# CONFIG_EXTCON_INTEL_INT3496 is not set
CONFIG_EXTCON_MAX3355=y
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_MAX8997=y
# CONFIG_EXTCON_PALMAS is not set
# CONFIG_EXTCON_RT8973A is not set
CONFIG_EXTCON_SM5502=y
CONFIG_EXTCON_USB_GPIO=y
# CONFIG_EXTCON_USBC_CROS_EC is not set
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_BUFFER_HW_CONSUMER=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
CONFIG_IIO_SW_DEVICE=y
CONFIG_IIO_SW_TRIGGER=y
CONFIG_IIO_TRIGGERED_EVENT=y

#
# Accelerometers
#
# CONFIG_ADIS16201 is not set
CONFIG_ADIS16209=y
# CONFIG_ADXL345_I2C is not set
# CONFIG_ADXL345_SPI is not set
CONFIG_BMA180=y
CONFIG_BMA220=y
# CONFIG_BMC150_ACCEL is not set
CONFIG_DA280=y
# CONFIG_DA311 is not set
CONFIG_DMARD06=y
# CONFIG_DMARD09 is not set
# CONFIG_DMARD10 is not set
CONFIG_IIO_CROS_EC_ACCEL_LEGACY=y
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
# CONFIG_KXSD9 is not set
CONFIG_KXCJK1013=y
CONFIG_MC3230=y
CONFIG_MMA7455=y
CONFIG_MMA7455_I2C=y
CONFIG_MMA7455_SPI=y
CONFIG_MMA7660=y
# CONFIG_MMA8452 is not set
CONFIG_MMA9551_CORE=y
CONFIG_MMA9551=y
CONFIG_MMA9553=y
CONFIG_MXC4005=y
CONFIG_MXC6255=y
CONFIG_SCA3000=y
# CONFIG_STK8312 is not set
CONFIG_STK8BA50=y

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
# CONFIG_AD7266 is not set
CONFIG_AD7291=y
# CONFIG_AD7298 is not set
# CONFIG_AD7476 is not set
CONFIG_AD7766=y
CONFIG_AD7791=y
CONFIG_AD7793=y
CONFIG_AD7887=y
CONFIG_AD7923=y
CONFIG_AD799X=y
# CONFIG_AXP20X_ADC is not set
CONFIG_AXP288_ADC=y
CONFIG_CC10001_ADC=y
# CONFIG_DA9150_GPADC is not set
CONFIG_DLN2_ADC=y
CONFIG_ENVELOPE_DETECTOR=y
CONFIG_HI8435=y
CONFIG_HX711=y
CONFIG_LTC2471=y
CONFIG_LTC2485=y
# CONFIG_LTC2497 is not set
CONFIG_MAX1027=y
CONFIG_MAX11100=y
CONFIG_MAX1118=y
CONFIG_MAX1363=y
CONFIG_MAX9611=y
CONFIG_MCP320X=y
CONFIG_MCP3422=y
CONFIG_NAU7802=y
CONFIG_PALMAS_GPADC=y
CONFIG_SD_ADC_MODULATOR=y
CONFIG_TI_ADC081C=y
CONFIG_TI_ADC0832=y
CONFIG_TI_ADC084S021=y
# CONFIG_TI_ADC12138 is not set
CONFIG_TI_ADC108S102=y
CONFIG_TI_ADC128S052=y
# CONFIG_TI_ADC161S626 is not set
CONFIG_TI_ADS1015=y
CONFIG_TI_ADS7950=y
CONFIG_TI_ADS8688=y
CONFIG_TI_TLC4541=y
# CONFIG_TWL4030_MADC is not set
CONFIG_TWL6030_GPADC=y
# CONFIG_VF610_ADC is not set
CONFIG_VIPERBOARD_ADC=y

#
# Analog Front Ends
#
CONFIG_IIO_RESCALE=y

#
# Amplifiers
#
# CONFIG_AD8366 is not set

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=y
# CONFIG_CCS811 is not set
# CONFIG_IAQCORE is not set
CONFIG_VZ89X=y
CONFIG_IIO_CROS_EC_SENSORS_CORE=y
# CONFIG_IIO_CROS_EC_SENSORS is not set

#
# Hid Sensor IIO Common
#
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
CONFIG_IIO_SSP_SENSORS_COMMONS=y
CONFIG_IIO_SSP_SENSORHUB=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Counters
#

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5360=y
CONFIG_AD5380=y
CONFIG_AD5421=y
# CONFIG_AD5446 is not set
CONFIG_AD5449=y
CONFIG_AD5592R_BASE=y
CONFIG_AD5592R=y
# CONFIG_AD5593R is not set
CONFIG_AD5504=y
# CONFIG_AD5624R_SPI is not set
CONFIG_LTC2632=y
CONFIG_AD5686=y
CONFIG_AD5686_SPI=y
CONFIG_AD5696_I2C=y
CONFIG_AD5755=y
CONFIG_AD5761=y
CONFIG_AD5764=y
CONFIG_AD5791=y
CONFIG_AD7303=y
CONFIG_AD8801=y
CONFIG_DPOT_DAC=y
CONFIG_DS4424=y
CONFIG_M62332=y
# CONFIG_MAX517 is not set
# CONFIG_MAX5821 is not set
CONFIG_MCP4725=y
CONFIG_MCP4922=y
CONFIG_TI_DAC082S085=y
CONFIG_TI_DAC5571=y
CONFIG_VF610_DAC=y

#
# IIO dummy driver
#
CONFIG_IIO_SIMPLE_DUMMY=y
# CONFIG_IIO_SIMPLE_DUMMY_EVENTS is not set
# CONFIG_IIO_SIMPLE_DUMMY_BUFFER is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
CONFIG_AD9523=y

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=y

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16080 is not set
CONFIG_ADIS16130=y
# CONFIG_ADIS16136 is not set
# CONFIG_ADIS16260 is not set
CONFIG_ADXRS450=y
# CONFIG_BMG160 is not set
# CONFIG_MPU3050_I2C is not set
# CONFIG_IIO_ST_GYRO_3AXIS is not set
# CONFIG_ITG3200 is not set

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4403=y
# CONFIG_AFE4404 is not set
CONFIG_MAX30100=y
# CONFIG_MAX30102 is not set

#
# Humidity sensors
#
CONFIG_AM2315=y
CONFIG_DHT11=y
# CONFIG_HDC100X is not set
CONFIG_HTS221=y
CONFIG_HTS221_I2C=y
CONFIG_HTS221_SPI=y
CONFIG_HTU21=y
CONFIG_SI7005=y
CONFIG_SI7020=y

#
# Inertial measurement units
#
# CONFIG_ADIS16400 is not set
CONFIG_ADIS16480=y
CONFIG_BMI160=y
CONFIG_BMI160_I2C=y
CONFIG_BMI160_SPI=y
# CONFIG_KMX61 is not set
CONFIG_INV_MPU6050_IIO=y
# CONFIG_INV_MPU6050_I2C is not set
CONFIG_INV_MPU6050_SPI=y
# CONFIG_IIO_ST_LSM6DSX is not set
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
CONFIG_ADJD_S311=y
CONFIG_AL3320A=y
CONFIG_APDS9300=y
CONFIG_APDS9960=y
CONFIG_BH1750=y
CONFIG_BH1780=y
CONFIG_CM32181=y
CONFIG_CM3232=y
# CONFIG_CM3323 is not set
# CONFIG_CM3605 is not set
CONFIG_CM36651=y
CONFIG_IIO_CROS_EC_LIGHT_PROX=y
CONFIG_GP2AP020A00F=y
# CONFIG_SENSORS_ISL29018 is not set
# CONFIG_SENSORS_ISL29028 is not set
CONFIG_ISL29125=y
# CONFIG_JSA1212 is not set
CONFIG_RPR0521=y
CONFIG_SENSORS_LM3533=y
CONFIG_LTR501=y
CONFIG_LV0104CS=y
CONFIG_MAX44000=y
CONFIG_OPT3001=y
CONFIG_PA12203001=y
# CONFIG_SI1145 is not set
CONFIG_STK3310=y
# CONFIG_ST_UVIS25 is not set
CONFIG_TCS3414=y
CONFIG_TCS3472=y
# CONFIG_SENSORS_TSL2563 is not set
# CONFIG_TSL2583 is not set
CONFIG_TSL2772=y
CONFIG_TSL4531=y
CONFIG_US5182D=y
# CONFIG_VCNL4000 is not set
# CONFIG_VEML6070 is not set
# CONFIG_VL6180 is not set
CONFIG_ZOPT2201=y

#
# Magnetometer sensors
#
CONFIG_AK8974=y
CONFIG_AK8975=y
# CONFIG_AK09911 is not set
CONFIG_BMC150_MAGN=y
CONFIG_BMC150_MAGN_I2C=y
# CONFIG_BMC150_MAGN_SPI is not set
CONFIG_MAG3110=y
CONFIG_MMC35240=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_IIO_ST_MAGN_SPI_3AXIS=y
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y
CONFIG_SENSORS_HMC5843_SPI=y

#
# Multiplexers
#
# CONFIG_IIO_MUX is not set

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
# CONFIG_IIO_HRTIMER_TRIGGER is not set
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
CONFIG_IIO_TIGHTLOOP_TRIGGER=y
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Digital potentiometers
#
CONFIG_AD5272=y
CONFIG_DS1803=y
# CONFIG_MAX5481 is not set
# CONFIG_MAX5487 is not set
CONFIG_MCP4018=y
# CONFIG_MCP4131 is not set
# CONFIG_MCP4531 is not set
CONFIG_TPL0102=y

#
# Digital potentiostats
#
CONFIG_LMP91000=y

#
# Pressure sensors
#
CONFIG_ABP060MG=y
CONFIG_BMP280=y
CONFIG_BMP280_I2C=y
CONFIG_BMP280_SPI=y
# CONFIG_IIO_CROS_EC_BARO is not set
# CONFIG_HP03 is not set
CONFIG_MPL115=y
CONFIG_MPL115_I2C=y
CONFIG_MPL115_SPI=y
CONFIG_MPL3115=y
# CONFIG_MS5611 is not set
CONFIG_MS5637=y
# CONFIG_IIO_ST_PRESS is not set
CONFIG_T5403=y
CONFIG_HP206C=y
CONFIG_ZPA2326=y
CONFIG_ZPA2326_I2C=y
CONFIG_ZPA2326_SPI=y

#
# Lightning sensors
#
CONFIG_AS3935=y

#
# Proximity and distance sensors
#
CONFIG_LIDAR_LITE_V2=y
# CONFIG_RFD77402 is not set
CONFIG_SRF04=y
CONFIG_SX9500=y
# CONFIG_SRF08 is not set

#
# Resolver to digital converters
#
# CONFIG_AD2S1200 is not set

#
# Temperature sensors
#
CONFIG_MAXIM_THERMOCOUPLE=y
CONFIG_MLX90614=y
CONFIG_MLX90632=y
CONFIG_TMP006=y
# CONFIG_TMP007 is not set
# CONFIG_TSYS01 is not set
CONFIG_TSYS02D=y
CONFIG_NTB=y
# CONFIG_NTB_IDT is not set
CONFIG_NTB_SWITCHTEC=y
CONFIG_NTB_PINGPONG=y
CONFIG_NTB_TOOL=y
CONFIG_NTB_PERF=y
CONFIG_NTB_TRANSPORT=y
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_ATMEL_HLCDC_PWM is not set
# CONFIG_PWM_CROS_EC is not set
CONFIG_PWM_FSL_FTM=y
# CONFIG_PWM_LP3943 is not set
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
CONFIG_PWM_PCA9685=y
# CONFIG_PWM_TWL is not set
# CONFIG_PWM_TWL_LED is not set

#
# IRQ chip support
#
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
CONFIG_RESET_TI_SYSCON=y
CONFIG_FMC=y
# CONFIG_FMC_FAKEDEV is not set
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=y
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_PHY_CPCAP_USB=y
# CONFIG_PHY_MAPPHONE_MDM6600 is not set
CONFIG_PHY_QCOM_USB_HS=y
CONFIG_PHY_QCOM_USB_HSIC=y
CONFIG_PHY_SAMSUNG_USB2=y
CONFIG_PHY_TUSB1210=y
CONFIG_POWERCAP=y
# CONFIG_INTEL_RAPL is not set
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
CONFIG_RAS_CEC=y
CONFIG_THUNDERBOLT=y

#
# Android
#
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"
CONFIG_ANDROID_BINDER_IPC_SELFTEST=y
CONFIG_DAX=y
CONFIG_DEV_DAX=y
CONFIG_NVMEM=y

#
# HW tracing support
#
CONFIG_STM=y
# CONFIG_STM_DUMMY is not set
# CONFIG_STM_SOURCE_CONSOLE is not set
# CONFIG_STM_SOURCE_HEARTBEAT is not set
CONFIG_STM_SOURCE_FTRACE=y
# CONFIG_INTEL_TH is not set
CONFIG_FPGA=y
CONFIG_ALTERA_PR_IP_CORE=y
CONFIG_ALTERA_PR_IP_CORE_PLAT=y
CONFIG_FPGA_MGR_ALTERA_PS_SPI=y
CONFIG_FPGA_MGR_ALTERA_CVP=y
CONFIG_FPGA_MGR_XILINX_SPI=y
# CONFIG_FPGA_MGR_ICE40_SPI is not set
# CONFIG_FPGA_MGR_MACHXO2_SPI is not set
CONFIG_FPGA_BRIDGE=y
CONFIG_XILINX_PR_DECOUPLER=y
CONFIG_FPGA_REGION=y
CONFIG_OF_FPGA_REGION=y
CONFIG_FSI=y
# CONFIG_FSI_MASTER_GPIO is not set
CONFIG_FSI_MASTER_HUB=y
CONFIG_FSI_SCOM=y
CONFIG_PM_OPP=y
# CONFIG_SIOX is not set
# CONFIG_SLIMBUS is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_DMIID is not set
# CONFIG_DMI_SYSFS is not set
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
# CONFIG_FW_CFG_SYSFS_CMDLINE is not set
# CONFIG_GOOGLE_FIRMWARE is not set

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
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT2=y
# CONFIG_EXT4_FS_POSIX_ACL is not set
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_ENCRYPTION is not set
CONFIG_EXT4_DEBUG=y
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
CONFIG_JFS_SECURITY=y
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
CONFIG_OCFS2_FS=y
# CONFIG_OCFS2_FS_O2CB is not set
CONFIG_OCFS2_FS_STATS=y
# CONFIG_OCFS2_DEBUG_MASKLOG is not set
# CONFIG_OCFS2_DEBUG_FS is not set
# CONFIG_BTRFS_FS is not set
CONFIG_NILFS2_FS=y
CONFIG_F2FS_FS=y
CONFIG_F2FS_STAT_FS=y
CONFIG_F2FS_FS_XATTR=y
# CONFIG_F2FS_FS_POSIX_ACL is not set
CONFIG_F2FS_FS_SECURITY=y
# CONFIG_F2FS_CHECK_FS is not set
# CONFIG_F2FS_FS_ENCRYPTION is not set
# CONFIG_F2FS_IO_TRACE is not set
CONFIG_F2FS_FAULT_INJECTION=y
CONFIG_FS_DAX=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
# CONFIG_FS_ENCRYPTION is not set
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
CONFIG_AUTOFS_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=y
CONFIG_CACHEFILES_DEBUG=y
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
CONFIG_UDF_FS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_FAT_DEFAULT_UTF8=y
CONFIG_NTFS_FS=y
CONFIG_NTFS_DEBUG=y
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_VMCORE=y
# CONFIG_PROC_VMCORE_DEVICE_DUMP is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_MEMFD_CREATE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
CONFIG_ADFS_FS=y
CONFIG_ADFS_FS_RW=y
# CONFIG_AFFS_FS is not set
CONFIG_ECRYPT_FS=y
# CONFIG_ECRYPT_FS_MESSAGING is not set
# CONFIG_HFS_FS is not set
CONFIG_HFSPLUS_FS=y
CONFIG_HFSPLUS_FS_POSIX_ACL=y
CONFIG_BEFS_FS=y
# CONFIG_BEFS_DEBUG is not set
CONFIG_BFS_FS=y
# CONFIG_EFS_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_SQUASHFS is not set
# CONFIG_VXFS_FS is not set
CONFIG_MINIX_FS=y
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=y
CONFIG_QNX4FS_FS=y
CONFIG_QNX6FS_FS=y
# CONFIG_QNX6FS_DEBUG is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_PSTORE is not set
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=y
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

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
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_PAGE_REF is not set
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_DEBUG_SLAB is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_VMACACHE=y
# CONFIG_DEBUG_VM_RB is not set
# CONFIG_DEBUG_VM_PGFLAGS is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
CONFIG_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_DEBUG_HIGHMEM=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_CC_HAS_SANCOV_TRACE_PC=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_WQ_WATCHDOG=y
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_DEBUG_TIMEKEEPING=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_WW_MUTEX_SELFTEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_EQS_DEBUG=y
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
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
CONFIG_FUNCTION_TRACER=y
# CONFIG_PREEMPTIRQ_EVENTS is not set
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
# CONFIG_HWLAT_TRACER is not set
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=y
# CONFIG_BLK_DEV_IO_TRACE is not set
CONFIG_UPROBE_EVENTS=y
CONFIG_PROBE_EVENTS=y
# CONFIG_DYNAMIC_FTRACE is not set
CONFIG_FUNCTION_PROFILER=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
CONFIG_TRACEPOINT_BENCHMARK=y
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
CONFIG_TRACE_EVAL_MAP_FILE=y
# CONFIG_TRACING_EVENTS_GPIO is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_RUNTIME_TESTING_MENU is not set
# CONFIG_MEMTEST is not set
CONFIG_BUG_ON_DATA_CORRUPTION=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
# CONFIG_UBSAN_NULL is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_EARLY_PRINTK_USB=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
# CONFIG_DEBUG_WX is not set
CONFIG_DOUBLEFAULT=y
CONFIG_DEBUG_TLBFLUSH=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_FPU is not set
CONFIG_PUNIT_ATOM_DEBUG=y
CONFIG_UNWINDER_FRAME_POINTER=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
CONFIG_SECURITY_PATH=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
# CONFIG_HARDENED_USERCOPY is not set
# CONFIG_FORTIFY_SOURCE is not set
# CONFIG_STATIC_USERMODEHELPER is not set
# CONFIG_SECURITY_SELINUX is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
CONFIG_SECURITY_APPARMOR_HASH=y
CONFIG_SECURITY_APPARMOR_HASH_DEFAULT=y
# CONFIG_SECURITY_APPARMOR_DEBUG is not set
# CONFIG_SECURITY_LOADPIN is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_INTEGRITY is not set
CONFIG_DEFAULT_SECURITY_APPARMOR=y
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="apparmor"
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
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
CONFIG_CRYPTO_GCM=y
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_AEGIS128=y
CONFIG_CRYPTO_AEGIS128L=y
# CONFIG_CRYPTO_AEGIS256 is not set
CONFIG_CRYPTO_MORUS640=y
CONFIG_CRYPTO_MORUS1280=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CFB is not set
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
CONFIG_CRYPTO_AES_586=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAST_COMMON=y
# CONFIG_CRYPTO_CAST5 is not set
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_CHACHA20 is not set
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
CONFIG_CRYPTO_SM4=y
# CONFIG_CRYPTO_SPECK is not set
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=y
CONFIG_CRYPTO_ZSTD=y

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
CONFIG_CRYPTO_USER_API_RNG=y
CONFIG_CRYPTO_USER_API_AEAD=y
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_GEODE is not set
CONFIG_CRYPTO_DEV_HIFN_795X=y
# CONFIG_CRYPTO_DEV_HIFN_795X_RNG is not set
CONFIG_CRYPTO_DEV_CCP=y
CONFIG_CRYPTO_DEV_CCP_DD=y
# CONFIG_CRYPTO_DEV_SP_CCP is not set
CONFIG_CRYPTO_DEV_QAT=y
CONFIG_CRYPTO_DEV_QAT_DH895xCC=y
CONFIG_CRYPTO_DEV_QAT_C3XXX=y
CONFIG_CRYPTO_DEV_QAT_C62X=y
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
CONFIG_CRYPTO_DEV_QAT_C3XXXVF=y
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
# CONFIG_CRYPTO_DEV_VIRTIO is not set
CONFIG_CRYPTO_DEV_CCREE=y
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y
# CONFIG_PKCS7_TEST_KEY is not set
CONFIG_SIGNED_PE_FILE_VERIFICATION=y

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
CONFIG_SYSTEM_EXTRA_CERTIFICATE=y
CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE=4096
CONFIG_SECONDARY_TRUSTED_KEYRING=y
# CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQFD=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y
CONFIG_HAVE_KVM_IRQ_BYPASS=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_AMD=y
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_VHOST_NET=y
CONFIG_VHOST=y
CONFIG_VHOST_CROSS_ENDIAN_LEGACY=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
CONFIG_CRC4=y
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_XXHASH=y
CONFIG_AUDIT_GENERIC=y
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=y
CONFIG_ZSTD_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_DMA_DIRECT_OPS=y
CONFIG_SGL_ALLOC=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_STACKDEPOT=y
CONFIG_SBITMAP=y
CONFIG_STRING_SELFTEST=y

--=_5b5f94c9.q9pdPYkQ6W2pMzvP+GtZ6N10K9IJzsVjEud8//XUd07GA6JN--
