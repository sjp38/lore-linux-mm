Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 66D206B0044
	for <linux-mm@kvack.org>; Wed,  9 May 2012 16:54:15 -0400 (EDT)
Message-ID: <4FAAD976.4080004@code42.com>
Date: Wed, 9 May 2012 15:54:14 -0500
From: Richard Berg <richardb@code42.com>
MIME-Version: 1.0
Subject: Re: RCU stalls in merge-window (v3.3-6946-gf1d38e4)
References: <E1SBSEB-0008Mf-4s@tytso-glaptop.cam.corp.google.com>
In-Reply-To: <E1SBSEB-0008Mf-4s@tytso-glaptop.cam.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 03/24/2012 09:45 AM, Theodore Ts'o wrote:
> I've been running xfstests of my ext4 dev branch merged in with
> v3.3-6946-gf1d38e3 --- the latest from Linus's tree as of this morning
> --- as a last minute check before sending a pull request to Linus, and
> I'm seeing that xfstests #76 is quite reliably causing an rcu_sched
> self-detecting stall warning, followed by a wedged kernel.
>
> A quick web search shows that Dan Carpenter noticed a similar problem
> about two weeks ago, but there was no follow-up as far as I could tell:
>
> 	https://lkml.org/lkml/2012/3/13/360
>
> Since Dan reported that "light e-mail and the occasional git pull" on
> his netbook is sufficient to reproduce this problem, it seems rather
> serious...
>
> Any updates on this issue?
>
> 					- Ted
>
>
> 076	[  216.353320] INFO: rcu_sched self-detected stall on CPU { 0}  (t=18000 jiffies)
> [  216.353321] Pid: 623, comm: kswapd0 Not tainted 3.3.0-07010-g1a897e3 #36
> [  216.353321] Call Trace:
> [  216.353321]  [<c01b91be>] __rcu_pending+0x9e/0x34e
> [  216.353321]  [<c01b948f>] rcu_pending+0x21/0x4d
> [  216.353321]  [<c01b9956>] rcu_check_callbacks+0x79/0x97
> [  216.353321]  [<c0163869>] update_process_times+0x32/0x5d
> [  216.353321]  [<c019349b>] tick_sched_timer+0x6d/0x9b
> [  216.353321]  [<c01744f2>] __run_hrtimer+0xa7/0x11e
> [  216.353321]  [<c019342e>] ? tick_nohz_handler+0xd9/0xd9
> [  216.353321]  [<c0174773>] hrtimer_interrupt+0xe6/0x1ec
> [  216.353321]  [<c0147f7a>] smp_apic_timer_interrupt+0x6c/0x7f
> [  216.353321]  [<c06db117>] apic_timer_interrupt+0x2f/0x34
> [  216.353321]  [<c01dfa12>] ? zone_watermark_ok_safe+0x22/0x85
> [  216.353321]  [<c01e9eb5>] kswapd+0x3d8/0x7f9
> [  216.353321]  [<c0170d68>] ? wake_up_bit+0x60/0x60
> [  216.353321]  [<c01e9add>] ? shrink_all_memory+0xa8/0xa8
> [  216.353321]  [<c01709e6>] kthread+0x6c/0x71
> [  216.353321]  [<c017097a>] ? __init_kthread_worker+0x47/0x47
> [  216.353321]  [<c06e08ba>] kernel_thread_helper+0x6/0x10
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message tomajordomo@vger.kernel.org
> More majordomo info athttp://vger.kernel.org/majordomo-info.html
> Please read the FAQ athttp://www.tux.org/lkml/
>
Hi
I have been running into this while testing a 3.2 kernel for internal 
release.
I can reliably cause it to happen by running  phoronix-test-suite 
benchmark pts/dbench with 48 clients on xfs or just dbench 48. (I know 
dbench isnt a great test. but I needed a general burn in)

Please CC me if there is anything I can do to help.
Thanks,
Richard Berg


This log is with the 3.3 git as this morning.
[   94.087546] Loglevel set to 9
[  790.676530] INFO: rcu_sched self-detected stall on CPU { 4}  (t=15000 
jiffies)
[  790.677020] Pid: 4980, comm: dbench Not tainted 3.4.0-rc6-c42.37 #2
[  790.677174] Call Trace:
[  790.677318] <IRQ>  [<ffffffff811111ca>] __rcu_pending+0x19a/0x4d0
[  790.677535]  [<ffffffff81111b60>] rcu_check_callbacks+0xb0/0x1a0
[  790.677692]  [<ffffffff810b0053>] update_process_times+0x43/0x80
[  790.677848]  [<ffffffff810ea57f>] tick_sched_timer+0x5f/0xb0
[  790.678002]  [<ffffffff810c475d>] __run_hrtimer+0x7d/0x1e0
[  790.678155]  [<ffffffff810ea520>] ? tick_nohz_handler+0xf0/0xf0
[  790.678333]  [<ffffffff8105fcc9>] ? read_tsc+0x9/0x20
[  790.678484]  [<ffffffff810c53a3>] hrtimer_interrupt+0xe3/0x200
[  790.678643]  [<ffffffff819e421c>] ? call_softirq+0x1c/0x30
[  790.678797]  [<ffffffff81077754>] smp_apic_timer_interrupt+0x64/0xa0
[  790.678953]  [<ffffffff819e38ca>] apic_timer_interrupt+0x6a/0x70
[  790.679106] <EOI>  [<ffffffff819e21bd>] ? _raw_spin_lock+0x1d/0x30
[  790.679319]  [<ffffffff813e1318>] xlog_state_get_iclog_space+0x58/0x2c0
[  790.679499]  [<ffffffff810cd3c1>] ? 
ttwu_do_activate.constprop.86+0x61/0x70
[  790.679657]  [<ffffffff810d039a>] ? try_to_wake_up+0x1fa/0x290
[  790.679811]  [<ffffffff813e184b>] xlog_write+0x16b/0x6f0
[  790.679962]  [<ffffffff810d0460>] ? wake_up_process+0x10/0x20
[  790.680117]  [<ffffffff814727fd>] ? __rwsem_do_wake+0xed/0x1d0
[  790.680270]  [<ffffffff813e319a>] xlog_cil_push+0x21a/0x370
[  790.680423]  [<ffffffff813e3ab0>] xlog_cil_force_lsn+0x100/0x110
[  790.680524] INFO: rcu_sched self-detected stall on CPU { 0}  (t=15001 
jiffies)
[  790.680531] Pid: 5050, comm: kworker/0:9 Not tainted 3.4.0-rc6-c42.37 #2
[  790.680533] Call Trace:
[  790.680535] <IRQ>  [<ffffffff811111ca>] __rcu_pending+0x19a/0x4d0
[  790.680546]  [<ffffffff81111b60>] rcu_check_callbacks+0xb0/0x1a0
[  790.680552]  [<ffffffff810b0053>] update_process_times+0x43/0x80
[  790.680556]  [<ffffffff810ea57f>] tick_sched_timer+0x5f/0xb0
[  790.680559]  [<ffffffff810c475d>] __run_hrtimer+0x7d/0x1e0
[  790.680562]  [<ffffffff810ea520>] ? tick_nohz_handler+0xf0/0xf0
[  790.680567]  [<ffffffff8105fcc9>] ? read_tsc+0x9/0x20
[  790.680570]  [<ffffffff810c53a3>] hrtimer_interrupt+0xe3/0x200
[  790.680575]  [<ffffffff819e421c>] ? call_softirq+0x1c/0x30
[  790.680580]  [<ffffffff8138d560>] ? xfs_buf_get+0x1d0/0x1d0
[  790.680585]  [<ffffffff81077754>] smp_apic_timer_interrupt+0x64/0xa0
[  790.680589]  [<ffffffff819e38ca>] apic_timer_interrupt+0x6a/0x70
[  790.680590] <EOI>  [<ffffffff819e21bd>] ? _raw_spin_lock+0x1d/0x30
[  790.680596]  [<ffffffff813e4b56>] xfs_buf_iodone+0x26/0x50
[  790.680599]  [<ffffffff813e3b5c>] xfs_buf_do_callbacks+0x3c/0x50
[  790.680602]  [<ffffffff813e3cf1>] xfs_buf_iodone_callbacks+0x41/0x230
[  790.680604]  [<ffffffff8138d560>] ? xfs_buf_get+0x1d0/0x1d0
[  790.680607]  [<ffffffff8138d57e>] xfs_buf_iodone_work+0x1e/0x50
[  790.680610]  [<ffffffff810ba569>] process_one_work+0x119/0x470
[  790.680612]  [<ffffffff810bb54f>] worker_thread+0x15f/0x350
[  790.680615]  [<ffffffff810bb3f0>] ? manage_workers.isra.29+0x220/0x220
[  790.680618]  [<ffffffff810c051e>] kthread+0x8e/0xa0
[  790.680621]  [<ffffffff819e4124>] kernel_thread_helper+0x4/0x10
[  790.680624]  [<ffffffff810c0490>] ? kthread_flush_work_fn+0x10/0x10
[  790.680627]  [<ffffffff819e4120>] ? gs_change+0x13/0x13
[  790.684973]  [<ffffffff813e21d8>] _xfs_log_force_lsn+0x48/0x2d0
[  790.685130]  [<ffffffff8114202c>] ? do_writepages+0x1c/0x30
[  790.685285]  [<ffffffff819e0901>] ? down_read+0x11/0x30
[  790.685439]  [<ffffffff81393a9c>] ? xfs_iunlock+0x9c/0xf0
[  790.685614]  [<ffffffff813905ba>] xfs_file_fsync+0x14a/0x1f0
[  790.685770]  [<ffffffff811b5331>] do_fsync+0x51/0x80
[  790.685920]  [<ffffffff811b569b>] sys_fsync+0xb/0x10
[  790.686071]  [<ffffffff819e2e39>] system_call_fastpath+0x16/0x1b

ver_linux
Linux dom0 3.4.0-rc6-c42.37 #2 SMP Wed May 9 10:26:52 CDT 2012 x86_64 
GNU/Linux

Gnu C                  4.4.5
Gnu make               3.81
binutils               2.20.1
util-linux             2.17.2
mount                  support
module-init-tools      3.12
e2fsprogs              1.41.12
xfsprogs               3.1.4
Linux C Library        2.11.3
Dynamic linker (ldd)   2.11.3
Procps                 3.2.8
Net-tools              1.60
Kbd                    1.15.2
Sh-utils               8.5

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.4.0-rc6 Kernel Configuration
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set           support
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y           support
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi 
-fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 
-fcall-saved-r10 -fcall-saved-r11"
# CONFIG_KTIME_SCALAR is not set
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
# CONFIG_FHANDLE is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
# CONFIG_AUDIT_LOGINUID_IMMUTABLE is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_FANOUT=64
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_RCU_FAST_NO_HZ is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=18
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_RESOURCE_COUNTERS=y
# CONFIG_CGROUP_MEM_RES_CTLR is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_PERF_COUNTERS is not set
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
# CONFIG_BLK_DEV_BSGLIB is not set
# CONFIG_BLK_DEV_INTEGRITY is not set
# CONFIG_BLK_DEV_THROTTLING is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
# CONFIG_MINIX_SUBPARTITION is not set
# CONFIG_SOLARIS_X86_PARTITION is not set
# CONFIG_UNIXWARE_DISKLABEL is not set
# CONFIG_LDM_PARTITION is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_CFQ_GROUP_IOSCHED is not set
# CONFIG_DEFAULT_DEADLINE is not set




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
