Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3A4C6B0340
	for <linux-mm@kvack.org>; Sat, 27 Oct 2018 22:10:48 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f5-v6so245661pfn.17
        for <linux-mm@kvack.org>; Sat, 27 Oct 2018 19:10:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g13-v6si16158123pgk.21.2018.10.27.19.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Oct 2018 19:10:46 -0700 (PDT)
Date: Sun, 28 Oct 2018 10:09:51 +0800
From: kernel test robot <lkp@intel.com>
Subject: a31acd3ee8 ("x86/mm: Page size aware flush_tlb_mm_range()"):
  BUG: KASAN: stack-out-of-bounds in __unwind_start
Message-ID: <5bd51a6f.m0mtSuTpPRKtQJDc%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_5bd51a6f.Ln1YTaUptZFfGOcNryfmD5tQym5yFbSvZbKUZDgFYZDVmS1H"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

This is a multi-part message in MIME format.

--=_5bd51a6f.Ln1YTaUptZFfGOcNryfmD5tQym5yFbSvZbKUZDgFYZDVmS1H
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542
Author:     Peter Zijlstra <peterz@infradead.org>
AuthorDate: Sun Aug 26 12:56:48 2018 +0200
Commit:     Peter Zijlstra <peterz@infradead.org>
CommitDate: Tue Oct 9 16:51:11 2018 +0200

    x86/mm: Page size aware flush_tlb_mm_range()
    
    Use the new tlb_get_unmap_shift() to determine the stride of the
    INVLPG loop.
    
    Cc: Nick Piggin <npiggin@gmail.com>
    Cc: Will Deacon <will.deacon@arm.com>
    Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
    Cc: Andrew Morton <akpm@linux-foundation.org>
    Cc: Dave Hansen <dave.hansen@linux.intel.com>
    Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

a5b966ae42  Merge branch 'tlb/asm-generic' of git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux into x86/mm
a31acd3ee8  x86/mm: Page size aware flush_tlb_mm_range()
69d5b97c59  HID: we do not randomly make new drivers 'default y'
8c60c36d0b  Add linux-next specific files for 20181019
+-----------------------------------------------------+------------+------------+------------+---------------+
|                                                     | a5b966ae42 | a31acd3ee8 | 69d5b97c59 | next-20181019 |
+-----------------------------------------------------+------------+------------+------------+---------------+
| boot_successes                                      | 26         | 0          | 0          | 0             |
| boot_failures                                       | 0          | 11         | 11         | 11            |
| BUG:KASAN:stack-out-of-bounds_in__unwind_start      | 0          | 11         | 11         | 11            |
| WARNING:at_kernel/locking/lockdep.c:#lock_downgrade | 0          | 0          | 11         | 11            |
| RIP:lock_downgrade                                  | 0          | 0          | 11         | 11            |
+-----------------------------------------------------+------------+------------+------------+---------------+

[  378.192588] Freeing unused kernel image memory: 1440K
[  378.288842] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[  378.289798] rodata_test: all tests were successful
[  378.290495] Run /init as init process
[  378.298833] ==================================================================
[  378.299979] BUG: KASAN: stack-out-of-bounds in __unwind_start+0x92/0x370
[  378.300898] Write of size 88 at addr ffff880000337918 by task init/1
[  378.301983] 
[  378.302240] CPU: 0 PID: 1 Comm: init Not tainted 4.19.0-rc5-00035-ga31acd3 #1
[  378.303196] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[  378.304311] Call Trace:
[  378.304679]  dump_stack+0x164/0x21b
[  378.305182]  ? printk+0xbd/0xe4
[  378.305644]  ? arch_local_irq_restore+0x37/0x37
[  378.306313]  ? rcu_read_unlock_sched_notrace+0x1d/0x1d
[  378.307035]  ? preempt_trace+0x8/0x1c
[  378.307579]  ? __unwind_start+0x92/0x370
[  378.308147]  print_address_description+0x55/0x228
[  378.308826]  ? __unwind_start+0x92/0x370
[  378.309416]  kasan_report+0x249/0x287
[  378.309949]  memset+0x1f/0x31
[  378.311062]  __unwind_start+0x92/0x370
[  378.311616]  ? unwind_next_frame+0x85f/0x85f
[  378.312235]  ? free_unref_page_list+0x35a/0x39e
[  378.312878]  ? flush_tlb_mm_range+0x23f/0x28d
[  378.313509]  ? clear_sched_clock_stable+0xff/0xff
[  378.314192]  ? lock_is_held_type+0x78/0x88
[  378.314783]  ? free_unref_page+0x6e/0x6e
[  378.315384]  __save_stack_trace+0x65/0xe8
[  378.315970]  ? release_pages+0x3c4/0x409
[  378.316582]  save_stack+0x32/0xa3
[  378.317078]  ? tlb_flush_mmu_tlbonly+0xbf/0x123
[  378.317722]  ? __tlb_reset_range+0xcd/0xdc
[  378.318310]  ? tlb_flush_mmu_free+0x69/0x92
[  378.318893]  ? preempt_trace+0x8/0x1c
[  378.319435]  ? tracer_preempt_on+0x23/0x50
[  378.320008]  ? preempt_count_sub+0x11/0x1d
[  378.320608]  ? trace_preempt_on+0x1d0/0x213
[  378.321196]  ? trace_hardirqs_off_caller+0x60/0x60
[  378.321865]  ? trace_preempt_on+0x213/0x213
[  378.322456]  ? tlb_gather_mmu+0x5f/0x5f
[  378.323021]  ? trace_irq_enable_rcuidle+0x1af/0x1f2
[  378.323709]  ? trace_irq_disable_rcuidle+0x1f2/0x1f2
[  378.324407]  ? hlock_class+0x6f/0x8d
[  378.324929]  ? mark_lock+0x2b/0x26e
[  378.325449]  ? __phys_addr+0x8c/0x92
[  378.325972]  __kasan_slab_free+0x102/0x124
[  378.326557]  slab_free_freelist_hook+0x92/0xe0
[  378.327191]  kmem_cache_free+0x76/0x1dc
[  378.327737]  ? remove_vma+0xbc/0xc4
[  378.328235]  remove_vma+0xbc/0xc4
[  378.328708]  do_munmap+0x530/0x563
[  378.329204]  vm_munmap+0xd9/0x130
[  378.329679]  ? __x64_sys_brk+0x33e/0x33e
[  378.330241]  ? write_seqcount_end+0x1f/0x23
[  378.330832]  __x64_sys_munmap+0x31/0x36
[  378.331396]  do_syscall_64+0x3eb/0x44b
[  378.331926]  ? syscall_return_slowpath+0x3dd/0x3dd
[  378.332605]  ? context_tracking_is_enabled+0x83/0xaf
[  378.333298]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
[  378.334044]  ? trace_irq_disable_rcuidle+0x1af/0x1f2
[  378.334781]  ? cpumask_test_cpu+0x28/0x28
[  378.335509]  ? rcu_read_unlock_sched_notrace+0x5/0x1d
[  378.336236]  ? prepare_exit_to_usermode+0x2b0/0x2f3
[  378.336939]  ? enter_from_user_mode+0x57/0x57
[  378.337580]  ? kvm_read_and_reset_pf_reason+0x25/0x25
[  378.338309]  ? mark_held_locks+0x67/0x81
[  378.338878]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
[  378.339635]  ? lockdep_hardirqs_off+0xf2/0xfb
[  378.342306]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  378.342985]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  378.343701] RIP: 0033:0x7f0939e95a17
[  378.344248] Code: f0 ff ff 73 01 c3 48 8d 0d 8a a7 20 00 31 d2 48 29 c2 89 11 48 83 c8 ff eb eb 90 90 90 90 90 90 90 90 90 b8 0b 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8d 0d 5d a7 20 00 31 d2 48 29 c2 89
[  378.346800] RSP: 002b:00007ffc1cb77d78 EFLAGS: 00000203 ORIG_RAX: 000000000000000b
[  378.347887] RAX: ffffffffffffffda RBX: 00007f093a0a01c8 RCX: 00007f0939e95a17
[  378.348889] RDX: 000000000001dd00 RSI: 0000000000000413 RDI: 00007f093a09c000
[  378.349887] RBP: 00007ffc1cb77ec0 R08: 0000000000000001 R09: 0000000000000007
[  378.350879] R10: 00007f0939e90717 R11: 0000000000000203 R12: 000000e532dcfbe4
[  378.351871] R13: 000000e532c785e7 R14: 00007f093a09a700 R15: 00007f093a09f9d8
[  378.352864] 
[  378.353105] The buggy address belongs to the page:
[  378.353782] page:ffffea000000cdc0 count:0 mapcount:0 mapping:0000000000000000 index:0x0

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start dd5e791be1fe7870ef7d5e68ac19bf7d9460a1d1 84df9525b0c27f3ebc2ebb1864fa62a97fdedb7d --
git bisect  bad dc7875563b7fb1d58d8ea66860690d809b892082  # 01:50  B      0     2   16   0  Merge 'block/mq-maps' into devel-spot-201810252124
git bisect  bad ce6c97b2e33b8df9718712879667185f9e47a192  # 02:14  B      0     1   15   0  Merge 'vireshk-pm/opp/genpd/required-opps' into devel-spot-201810252124
git bisect  bad 6a401649772a60e0295c309a72d7d02c4407b759  # 02:38  B      0     5   19   0  Merge 'vincent.guittot/sched/pelt' into devel-spot-201810252124
git bisect  bad e1100c624b286bd26c8a9fd7c623dc7620780dbf  # 03:03  B      0     2   16   0  Merge 'linux-review/Andrew-Lunn/net-phy-genphy_10g_driver-Avoid-NULL-pointer-dereference/20181025-204453' into devel-spot-201810252124
git bisect good a7797cd3410d7561d1f93cf40ea631b31a3d1b3a  # 03:31  G     11     0    3   3  Merge 'drm-tip/drm-tip' into devel-spot-201810252124
git bisect good 385380978d5b8809131747835aa8dd6fcd832742  # 03:47  G     11     0    5   5  Merge 'abelloni/rtc-next' into devel-spot-201810252124
git bisect good 3f80e08f40cdb308589a49077c87632fa4508b21  # 04:21  G     11     0    3   3  tcp: add tcp_reset_xmit_timer() helper
git bisect good 58a0228707870c8330917f919804986855443a19  # 04:42  G     11     0    3   3  Merge tag 'acpi-4.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm
git bisect good 382d72a9aa525b56ab8453ce61751fa712414d3d  # 05:05  G     11     0    5   5  Merge branch 'x86-hyperv-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect  bad 44adbac8f7217040be97928cd19998259d9d4418  # 05:21  B      0     3   17   0  Merge branch 'work.tty-ioctl' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs
git bisect  bad a978a5b8d83f795e107a2ff759b28643739be70e  # 05:44  B      0     6   20   0  net/kconfig: Make QCOM_QMI_HELPERS available when COMPILE_TEST
git bisect  bad d7197a5ad8528642cb70f1d27d4d5c7332a2b395  # 05:59  B      0     4   18   0  Merge branch 'x86-platform-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect  bad 164477c2331be75d9bd57fb76704e676b2bcd1cd  # 06:21  B      0     5   19   0  x86/mm: Clarify hardware vs. software "error_code"
git bisect good 7904ba8a66f400182a204893c92098994e22a88d  # 06:45  G     10     0    2   2  x86/mm/cpa: Optimize __cpa_flush_range()
git bisect good cf089611f4c446285046fcd426d90c18f37d2905  # 07:18  G     10     0    3   3  proc/vmcore: Fix i386 build error of missing copy_oldmem_page_encrypted()
git bisect  bad c3f7f2c7eba1a53d2e5ffbc2dcc9a20c5f094890  # 07:33  B      0     2   16   0  smp: use __cpumask_set_cpu in on_each_cpu_cond
git bisect  bad a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542  # 07:56  B      0     3   17   0  x86/mm: Page size aware flush_tlb_mm_range()
git bisect good a5b966ae42a70b194b03eaa5eaea70d8b3790c40  # 08:37  G     11     0    5   5  Merge branch 'tlb/asm-generic' of git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux into x86/mm
# first bad commit: [a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542] x86/mm: Page size aware flush_tlb_mm_range()
git bisect good a5b966ae42a70b194b03eaa5eaea70d8b3790c40  # 08:59  G     31     0    6  11  Merge branch 'tlb/asm-generic' of git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux into x86/mm
# extra tests with debug options
git bisect  bad a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542  # 09:16  B      0     2   16   0  x86/mm: Page size aware flush_tlb_mm_range()
# extra tests on HEAD of linux-devel/devel-spot-201810252124
git bisect  bad dd5e791be1fe7870ef7d5e68ac19bf7d9460a1d1  # 09:22  B      0    13   30   0  0day head guard for 'devel-spot-201810252124'
# extra tests on tree/branch linus/master
git bisect  bad 69d5b97c597307773fe6c59775a5d5a88bb7e6b3  # 09:39  B      0     1   15   0  HID: we do not randomly make new drivers 'default y'
# extra tests on tree/branch linux-next/master
git bisect  bad 8c60c36d0b8c92599b8f0ec391b5250bc40e8e05  # 10:02  B      0     1   15   0  Add linux-next specific files for 20181019

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_5bd51a6f.Ln1YTaUptZFfGOcNryfmD5tQym5yFbSvZbKUZDgFYZDVmS1H
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-lkp-hsw01-68:20181028075736:x86_64-randconfig-s5-10261033:4.19.0-rc5-00035-ga31acd3:1.gz"

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

--=_5bd51a6f.Ln1YTaUptZFfGOcNryfmD5tQym5yFbSvZbKUZDgFYZDVmS1H
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-lkp-hsw01-102:20181028083450:x86_64-randconfig-s5-10261033:4.19.0-rc5-00034-ga5b966a:1.gz"

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
/bkNAwA=

--=_5bd51a6f.Ln1YTaUptZFfGOcNryfmD5tQym5yFbSvZbKUZDgFYZDVmS1H
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="reproduce-yocto-lkp-hsw01-68:20181028075736:x86_64-randconfig-s5-10261033:4.19.0-rc5-00035-ga31acd3:1"

#!/bin/bash

kernel=$1
initrd=yocto-trinity-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/yocto/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 512
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

--=_5bd51a6f.Ln1YTaUptZFfGOcNryfmD5tQym5yFbSvZbKUZDgFYZDVmS1H
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-4.19.0-rc5-00035-ga31acd3"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.19.0-rc5 Kernel Configuration
#

#
# Compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
#
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION=70300
CONFIG_CLANG_VERSION=0
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_BUILD_SALT=""
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
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_MIGRATION=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_DEBUGFS=y
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
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ_FULL is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set
# CONFIG_CPU_ISOLATION is not set

#
# RCU Subsystem
#
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_CONTEXT_TRACKING=y
CONFIG_CONTEXT_TRACKING_FORCE=y
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_BOOST is not set
CONFIG_RCU_NOCB_CPU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_NUMA_BALANCING=y
# CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is not set
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
# CONFIG_NAMESPACES is not set
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
# CONFIG_RD_XZ is not set
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
# CONFIG_SYSFS_SYSCALL is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
CONFIG_SHMEM=y
# CONFIG_AIO is not set
# CONFIG_ADVISE_SYSCALLS is not set
CONFIG_MEMBARRIER=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
# CONFIG_BPF_SYSCALL is not set
CONFIG_USERFAULTFD=y
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
# CONFIG_RSEQ is not set
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y
CONFIG_PC104=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLAB_MERGE_DEFAULT=y
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SLAB_FREELIST_HARDENED is not set
CONFIG_SLUB_CPU_PARTIAL=y
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
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
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_CC_HAS_SANE_STACKPROTECTOR=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_X2APIC is not set
# CONFIG_X86_MPPARSE is not set
# CONFIG_GOLDFISH is not set
CONFIG_RETPOLINE=y
CONFIG_INTEL_RDT=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_INTEL_LPSS=y
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
CONFIG_PARAVIRT_DEBUG=y
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
CONFIG_MPSC=y
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=7
CONFIG_X86_L1_CACHE_SHIFT=7
CONFIG_X86_P6_NOP=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
CONFIG_CPU_SUP_INTEL=y
# CONFIG_CPU_SUP_AMD is not set
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS_RANGE_BEGIN=2
CONFIG_NR_CPUS_RANGE_END=512
CONFIG_NR_CPUS_DEFAULT=64
CONFIG_NR_CPUS=64
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
CONFIG_SCHED_MC_PRIO=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
# CONFIG_X86_MCELOG_LEGACY is not set
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_INJECT=y

#
# Performance monitoring
#
# CONFIG_PERF_EVENTS_INTEL_UNCORE is not set
# CONFIG_PERF_EVENTS_INTEL_RAPL is not set
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
# CONFIG_X86_16BIT is not set
CONFIG_X86_VSYSCALL_EMULATION=y
# CONFIG_I8K is not set
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_X86_MSR is not set
CONFIG_X86_CPUID=y
# CONFIG_X86_5LEVEL is not set
# CONFIG_X86_CPA_STATISTICS is not set
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
CONFIG_NUMA_EMU=y
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_X86_PMEM_LEGACY_DEVICE=y
CONFIG_X86_PMEM_LEGACY=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
# CONFIG_X86_SMAP is not set
CONFIG_X86_INTEL_UMIP=y
CONFIG_X86_INTEL_MPX=y
# CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS is not set
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_KEXEC_FILE=y
CONFIG_ARCH_HAS_KEXEC_PURGATORY=y
CONFIG_KEXEC_VERIFY_SIG=y
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_RANDOMIZE_MEMORY is not set
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
CONFIG_DEBUG_HOTPLUG_CPU0=y
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_ADVANCED_DEBUG is not set
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ARCH_SUPPORTS_ACPI=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
CONFIG_ACPI_DEBUGGER=y
CONFIG_ACPI_DEBUGGER_USER=y
CONFIG_ACPI_SPCR_TABLE=y
CONFIG_ACPI_LPIT=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_REV_OVERRIDE_POSSIBLE is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_TAD=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_CPPC_LIB=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_TABLE_UPGRADE is not set
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=y
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
# CONFIG_ACPI_APEI_PCIEAER is not set
# CONFIG_ACPI_APEI_MEMORY_FAILURE is not set
CONFIG_ACPI_APEI_EINJ=y
CONFIG_ACPI_APEI_ERST_DEBUG=y
CONFIG_DPTF_POWER=y
CONFIG_PMIC_OPREGION=y
# CONFIG_CRC_PMIC_OPREGION is not set
# CONFIG_BXT_WC_PMIC_OPREGION is not set
CONFIG_CHT_DC_TI_PMIC_OPREGION=y
CONFIG_ACPI_CONFIGFS=y
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y

#
# CPU frequency scaling drivers
#
CONFIG_CPUFREQ_DT=y
CONFIG_CPUFREQ_DT_PLATDEV=y
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_X86_POWERNOW_K8=y
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_MMCONF_FAM10H=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
CONFIG_PCIEAER_INJECT=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEASPM is not set
CONFIG_PCIE_PME=y
CONFIG_PCIE_DPC=y
# CONFIG_PCIE_PTM is not set
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
CONFIG_PCI_PF_STUB=y
CONFIG_PCI_ATS=y
CONFIG_PCI_ECAM=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
CONFIG_PCI_HYPERV=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI controller drivers
#

#
# Cadence PCIe controllers support
#
# CONFIG_PCIE_CADENCE_HOST is not set
CONFIG_PCI_FTPCI100=y
CONFIG_PCI_HOST_COMMON=y
CONFIG_PCI_HOST_GENERIC=y
CONFIG_PCIE_XILINX=y
# CONFIG_VMD is not set

#
# DesignWare PCI Core Support
#
CONFIG_PCIE_DW=y
CONFIG_PCIE_DW_HOST=y
CONFIG_PCIE_DW_PLAT=y
CONFIG_PCIE_DW_PLAT_HOST=y

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
CONFIG_PCI_SW_SWITCHTEC=y
# CONFIG_ISA_BUS is not set
# CONFIG_ISA_DMA_API is not set
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
# CONFIG_CARDBUS is not set

#
# PC-card bridges
#
CONFIG_YENTA=y
# CONFIG_YENTA_O2 is not set
# CONFIG_YENTA_RICOH is not set
CONFIG_YENTA_TI=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_PD6729 is not set
CONFIG_I82092=y
CONFIG_PCCARD_NONSTATIC=y
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_TSI721=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS=y
# CONFIG_RAPIDIO_DMA_ENGINE is not set
CONFIG_RAPIDIO_DEBUG=y
CONFIG_RAPIDIO_ENUM_BASIC=y
CONFIG_RAPIDIO_CHMAN=y
CONFIG_RAPIDIO_MPORT_CDEV=y

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=y
# CONFIG_RAPIDIO_CPS_XX is not set
CONFIG_RAPIDIO_TSI568=y
CONFIG_RAPIDIO_CPS_GEN2=y
CONFIG_RAPIDIO_RXS_GEN3=y
# CONFIG_X86_SYSFB is not set

#
# Binary Emulations
#
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_HAVE_GENERIC_GUP=y

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
CONFIG_DCDBAS=y
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
# CONFIG_ISCSI_IBFT is not set
# CONFIG_FW_CFG_SYSFS is not set
CONFIG_GOOGLE_FIRMWARE=y
# CONFIG_GOOGLE_COREBOOT_TABLE_ACPI is not set
# CONFIG_GOOGLE_COREBOOT_TABLE_OF is not set
CONFIG_GOOGLE_MEMCONSOLE=y
CONFIG_GOOGLE_MEMCONSOLE_X86_LEGACY=y
CONFIG_UEFI_CPER=y
CONFIG_UEFI_CPER_X86=y

#
# Tegra firmware driver
#
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set

#
# General architecture-dependent options
#
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_HOTPLUG_SMT=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
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
CONFIG_HAVE_RCU_TABLE_INVALIDATE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_STACKPROTECTOR=y
CONFIG_CC_HAS_STACKPROTECTOR_NONE=y
CONFIG_STACKPROTECTOR=y
CONFIG_STACKPROTECTOR_STRONG=y
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_HAVE_RELIABLE_STACKTRACE=y
CONFIG_ISA_BUS_API=y
CONFIG_COMPAT_32BIT_TIME=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set
CONFIG_HAVE_ARCH_PREL32_RELOCATIONS=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_PLUGIN_HOSTCC="g++"
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_ZONED is not set
CONFIG_BLK_CMDLINE_PARSER=y
# CONFIG_BLK_WBT is not set
CONFIG_BLK_DEBUG_FS=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
CONFIG_ACORN_PARTITION_CUMANA=y
CONFIG_ACORN_PARTITION_EESOX=y
CONFIG_ACORN_PARTITION_ICS=y
CONFIG_ACORN_PARTITION_ADFS=y
CONFIG_ACORN_PARTITION_POWERTEC=y
CONFIG_ACORN_PARTITION_RISCIX=y
CONFIG_AIX_PARTITION=y
# CONFIG_OSF_PARTITION is not set
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
# CONFIG_MINIX_SUBPARTITION is not set
# CONFIG_SOLARIS_X86_PARTITION is not set
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
CONFIG_ULTRIX_PARTITION=y
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
# CONFIG_EFI_PARTITION is not set
# CONFIG_SYSV68_PARTITION is not set
CONFIG_CMDLINE_PARTITION=y
CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
# CONFIG_MQ_IOSCHED_DEADLINE is not set
CONFIG_MQ_IOSCHED_KYBER=y
# CONFIG_IOSCHED_BFQ is not set
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y
CONFIG_FREEZER=y

#
# Executable file formats
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y

#
# Memory Management options
#
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
# CONFIG_CLEANCACHE is not set
# CONFIG_CMA is not set
# CONFIG_MEM_SOFT_DIRTY is not set
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=y
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
# CONFIG_PERCPU_STATS is not set
# CONFIG_GUP_BENCHMARK is not set
CONFIG_ARCH_HAS_PTE_SPECIAL=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_TLS is not set
CONFIG_XFRM=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_INTERFACE is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
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
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NET_PTP_CLASSIFY=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_BPFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_NET_NSH is not set
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
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
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_DROP_MONITOR is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
# CONFIG_FAILOVER is not set
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
CONFIG_DEVTMPFS_MOUNT=y
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set

#
# Firmware loader
#
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_WANT_DEV_COREDUMP=y
CONFIG_ALLOW_DEV_COREDUMP=y
CONFIG_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_SPMI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y

#
# Bus devices
#
CONFIG_SIMPLE_PM_BUS=y
# CONFIG_CONNECTOR is not set
# CONFIG_GNSS is not set
# CONFIG_MTD is not set
CONFIG_DTC=y
CONFIG_OF=y
CONFIG_OF_UNITTEST=y
CONFIG_OF_FLATTREE=y
CONFIG_OF_EARLY_FLATTREE=y
CONFIG_OF_KOBJ=y
CONFIG_OF_DYNAMIC=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_RESOLVE=y
CONFIG_OF_OVERLAY=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_SERIAL=y
CONFIG_PARPORT_PC_FIFO=y
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_PC_PCMCIA is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=y
CONFIG_BLK_DEV_NULL_BLK_FAULT_INJECTION=y
CONFIG_CDROM=y
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
CONFIG_BLK_DEV_DAC960=y
# CONFIG_BLK_DEV_UMEM is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=y
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SKD is not set
CONFIG_BLK_DEV_SX8=y
# CONFIG_BLK_DEV_RAM is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_CDROM_PKTCDVD_WCACHE=y
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# NVME Support
#
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
CONFIG_NVME_MULTIPATH=y
CONFIG_NVME_FABRICS=y
CONFIG_NVME_FC=y
# CONFIG_NVME_TARGET is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
# CONFIG_AD525X_DPOT_I2C is not set
CONFIG_AD525X_DPOT_SPI=y
# CONFIG_DUMMY_IRQ is not set
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
# CONFIG_VMWARE_BALLOON is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
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
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_93XX46=y
# CONFIG_EEPROM_IDT_89HPESX is not set
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y
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
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

#
# VOP Bus Driver
#
CONFIG_VOP_BUS=y

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
# CONFIG_VOP is not set
CONFIG_GENWQE=y
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
CONFIG_ECHO=y
# CONFIG_MISC_RTSX_PCI is not set
CONFIG_MISC_RTSX_USB=y
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_BLK_DEV_IDE_SATA=y
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
CONFIG_IDE_GD_ATAPI=y
# CONFIG_BLK_DEV_IDECS is not set
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
CONFIG_BLK_DEV_IDETAPE=y
CONFIG_BLK_DEV_IDEACPI=y
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
CONFIG_BLK_DEV_CMD640=y
CONFIG_BLK_DEV_CMD640_ENHANCED=y
CONFIG_BLK_DEV_IDEPNP=y
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
# CONFIG_IDEPCI_PCIBUS_ORDER is not set
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
CONFIG_BLK_DEV_OPTI621=y
CONFIG_BLK_DEV_RZ1000=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
CONFIG_BLK_DEV_ATIIXP=y
CONFIG_BLK_DEV_CMD64X=y
CONFIG_BLK_DEV_TRIFLEX=y
CONFIG_BLK_DEV_HPT366=y
CONFIG_BLK_DEV_JMICRON=y
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
# CONFIG_BLK_DEV_IT8213 is not set
CONFIG_BLK_DEV_IT821X=y
CONFIG_BLK_DEV_NS87415=y
CONFIG_BLK_DEV_PDC202XX_OLD=y
CONFIG_BLK_DEV_PDC202XX_NEW=y
# CONFIG_BLK_DEV_SVWKS is not set
CONFIG_BLK_DEV_SIIMAGE=y
CONFIG_BLK_DEV_SIS5513=y
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
CONFIG_BLK_DEV_TC86C001=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_MQ_DEFAULT is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
# CONFIG_CHR_DEV_SG is not set
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=y
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
CONFIG_SCSI_HPSA=y
# CONFIG_SCSI_3W_9XXX is not set
CONFIG_SCSI_3W_SAS=y
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
# CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
# CONFIG_AIC79XX_BUILD_FIRMWARE is not set
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
CONFIG_AIC79XX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC94XX=y
CONFIG_AIC94XX_DEBUG=y
CONFIG_SCSI_MVSAS=y
CONFIG_SCSI_MVSAS_DEBUG=y
# CONFIG_SCSI_MVSAS_TASKLET is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
CONFIG_SCSI_ESAS2R=y
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
# CONFIG_MEGARAID_SAS is not set
CONFIG_SCSI_MPT3SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_SMARTPQI=y
CONFIG_SCSI_UFSHCD=y
CONFIG_SCSI_UFSHCD_PCI=y
CONFIG_SCSI_UFS_DWC_TC_PCI=y
CONFIG_SCSI_UFSHCD_PLATFORM=y
CONFIG_SCSI_UFS_DWC_TC_PLATFORM=y
CONFIG_SCSI_HPTIOP=y
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_HYPERV_STORAGE is not set
# CONFIG_SCSI_SNIC is not set
CONFIG_SCSI_DMX3191D=y
CONFIG_SCSI_ISCI=y
CONFIG_SCSI_IPS=y
# CONFIG_SCSI_INITIO is not set
CONFIG_SCSI_INIA100=y
CONFIG_SCSI_PPA=y
CONFIG_SCSI_IMM=y
CONFIG_SCSI_IZIP_EPP16=y
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
# CONFIG_SCSI_STEX is not set
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
# CONFIG_SCSI_SYM53C8XX_MMIO is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_DC395x is not set
CONFIG_SCSI_AM53C974=y
CONFIG_SCSI_WD719X=y
CONFIG_SCSI_DEBUG=y
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
# CONFIG_SCSI_DH is not set
CONFIG_SCSI_OSD_INITIATOR=y
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
# CONFIG_ATA is not set
# CONFIG_MD is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
CONFIG_FIREWIRE_SBP2=y
# CONFIG_FIREWIRE_NET is not set
CONFIG_FIREWIRE_NOSY=y
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_RIONET is not set
# CONFIG_TUN is not set
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
# CONFIG_VIRTIO_NET is not set
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
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
# CONFIG_ENA_ETHERNET is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_PCMCIA_NMCLAN is not set
# CONFIG_AMD_XGBE is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
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
CONFIG_NET_VENDOR_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
CONFIG_CAVIUM_PTP=y
# CONFIG_LIQUIDIO is not set
# CONFIG_LIQUIDIO_VF is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
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
# CONFIG_HINIC is not set
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
# CONFIG_IXGBEVF is not set
# CONFIG_I40E is not set
# CONFIG_I40EVF is not set
# CONFIG_ICE is not set
# CONFIG_FM10K is not set
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
CONFIG_NET_VENDOR_NETERION=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_NETRONOME=y
# CONFIG_NFP is not set
CONFIG_NET_VENDOR_NI=y
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_ETHOC is not set
CONFIG_NET_VENDOR_PACKET_ENGINES=y
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
# CONFIG_NET_SB1000 is not set
# CONFIG_MDIO_DEVICE is not set
# CONFIG_PHYLIB is not set
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PLIP is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
CONFIG_USB_NET_DRIVERS=y
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_RTL8152 is not set
# CONFIG_USB_LAN78XX is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_IPHETH is not set
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
CONFIG_WLAN_VENDOR_ADMTEK=y
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_WLAN_VENDOR_ATMEL=y
CONFIG_WLAN_VENDOR_BROADCOM=y
CONFIG_WLAN_VENDOR_CISCO=y
CONFIG_WLAN_VENDOR_INTEL=y
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
CONFIG_WLAN_VENDOR_MEDIATEK=y
CONFIG_WLAN_VENDOR_RALINK=y
CONFIG_WLAN_VENDOR_REALTEK=y
CONFIG_WLAN_VENDOR_RSI=y
CONFIG_WLAN_VENDOR_ST=y
CONFIG_WLAN_VENDOR_TI=y
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_WLAN_VENDOR_QUANTENNA=y
# CONFIG_PCMCIA_RAYCS is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_THUNDERBOLT_NET is not set
# CONFIG_HYPERV_NET is not set
# CONFIG_NETDEVSIM is not set
# CONFIG_NET_FAILOVER is not set
# CONFIG_ISDN is not set
CONFIG_NVM=y
# CONFIG_NVM_PBLK is not set

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
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADC=y
CONFIG_KEYBOARD_ADP5520=y
CONFIG_KEYBOARD_ADP5588=y
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_DLINK_DIR685=y
CONFIG_KEYBOARD_LKKBD=y
CONFIG_KEYBOARD_GPIO=y
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=y
# CONFIG_KEYBOARD_TCA8418 is not set
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
CONFIG_KEYBOARD_LM8333=y
# CONFIG_KEYBOARD_MAX7359 is not set
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
# CONFIG_KEYBOARD_SAMSUNG is not set
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
# CONFIG_KEYBOARD_OMAP4 is not set
CONFIG_KEYBOARD_TM2_TOUCHKEY=y
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
CONFIG_KEYBOARD_CAP11XX=y
CONFIG_KEYBOARD_BCM=y
# CONFIG_KEYBOARD_MTK_PMIC is not set
# CONFIG_INPUT_MOUSE is not set
CONFIG_INPUT_JOYSTICK=y
# CONFIG_JOYSTICK_ANALOG is not set
CONFIG_JOYSTICK_A3D=y
CONFIG_JOYSTICK_ADI=y
CONFIG_JOYSTICK_COBRA=y
# CONFIG_JOYSTICK_GF2K is not set
# CONFIG_JOYSTICK_GRIP is not set
CONFIG_JOYSTICK_GRIP_MP=y
# CONFIG_JOYSTICK_GUILLEMOT is not set
CONFIG_JOYSTICK_INTERACT=y
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
CONFIG_JOYSTICK_IFORCE=y
CONFIG_JOYSTICK_IFORCE_USB=y
CONFIG_JOYSTICK_IFORCE_232=y
# CONFIG_JOYSTICK_WARRIOR is not set
# CONFIG_JOYSTICK_MAGELLAN is not set
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=y
# CONFIG_JOYSTICK_TWIDJOY is not set
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_DB9=y
CONFIG_JOYSTICK_GAMECON=y
# CONFIG_JOYSTICK_TURBOGRAFX is not set
CONFIG_JOYSTICK_AS5011=y
CONFIG_JOYSTICK_JOYDUMP=y
# CONFIG_JOYSTICK_XPAD is not set
# CONFIG_JOYSTICK_WALKERA0701 is not set
# CONFIG_JOYSTICK_PSXPAD_SPI is not set
CONFIG_JOYSTICK_PXRC=y
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
CONFIG_TABLET_USB_AIPTEK=y
CONFIG_TABLET_USB_GTCO=y
CONFIG_TABLET_USB_HANWANG=y
CONFIG_TABLET_USB_KBTAB=y
CONFIG_TABLET_USB_PEGASUS=y
CONFIG_TABLET_SERIAL_WACOM4=y
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_AD714X=y
CONFIG_INPUT_AD714X_I2C=y
# CONFIG_INPUT_AD714X_SPI is not set
# CONFIG_INPUT_ATMEL_CAPTOUCH is not set
# CONFIG_INPUT_BMA150 is not set
CONFIG_INPUT_E3X0_BUTTON=y
CONFIG_INPUT_PCSPKR=y
CONFIG_INPUT_MAX77693_HAPTIC=y
CONFIG_INPUT_MC13783_PWRBUTTON=y
CONFIG_INPUT_MMA8450=y
CONFIG_INPUT_APANEL=y
# CONFIG_INPUT_GP2A is not set
# CONFIG_INPUT_GPIO_BEEPER is not set
# CONFIG_INPUT_GPIO_DECODER is not set
# CONFIG_INPUT_CPCAP_PWRBUTTON is not set
CONFIG_INPUT_ATLAS_BTNS=y
# CONFIG_INPUT_ATI_REMOTE2 is not set
CONFIG_INPUT_KEYSPAN_REMOTE=y
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_REGULATOR_HAPTIC=y
CONFIG_INPUT_RETU_PWRBUTTON=y
# CONFIG_INPUT_TPS65218_PWRBUTTON is not set
CONFIG_INPUT_TWL6040_VIBRA=y
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PALMAS_PWRBUTTON=y
# CONFIG_INPUT_PCF50633_PMU is not set
CONFIG_INPUT_PCF8574=y
# CONFIG_INPUT_PWM_BEEPER is not set
CONFIG_INPUT_PWM_VIBRA=y
CONFIG_INPUT_RK805_PWRKEY=y
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
# CONFIG_INPUT_DA9052_ONKEY is not set
CONFIG_INPUT_DA9055_ONKEY=y
CONFIG_INPUT_DA9063_ONKEY=y
CONFIG_INPUT_WM831X_ON=y
# CONFIG_INPUT_PCAP is not set
CONFIG_INPUT_ADXL34X=y
# CONFIG_INPUT_ADXL34X_I2C is not set
CONFIG_INPUT_ADXL34X_SPI=y
CONFIG_INPUT_IMS_PCU=y
CONFIG_INPUT_CMA3000=y
# CONFIG_INPUT_CMA3000_I2C is not set
CONFIG_INPUT_IDEAPAD_SLIDEBAR=y
# CONFIG_INPUT_SOC_BUTTON_ARRAY is not set
CONFIG_INPUT_DRV260X_HAPTICS=y
CONFIG_INPUT_DRV2665_HAPTICS=y
# CONFIG_INPUT_DRV2667_HAPTICS is not set
CONFIG_INPUT_RAVE_SP_PWRBUTTON=y
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_SERIO_APBPS2=y
CONFIG_HYPERV_KEYBOARD=y
# CONFIG_SERIO_GPIO_PS2 is not set
CONFIG_USERIO=y
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
# CONFIG_GAMEPORT_L4 is not set
# CONFIG_GAMEPORT_EMU10K1 is not set
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
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
# CONFIG_DEVMEM is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
CONFIG_SERIAL_8250_ASPEED_VUART=y
CONFIG_SERIAL_8250_DW=y
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
CONFIG_SERIAL_8250_MOXA=y
# CONFIG_SERIAL_OF_PLATFORM is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_UARTLITE=y
CONFIG_SERIAL_UARTLITE_CONSOLE=y
CONFIG_SERIAL_UARTLITE_NR_UARTS=1
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
CONFIG_SERIAL_SCCNXP_CONSOLE=y
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_SC16IS7XX_I2C=y
# CONFIG_SERIAL_SC16IS7XX_SPI is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
CONFIG_SERIAL_IFX6X60=y
# CONFIG_SERIAL_XILINX_PS_UART is not set
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
CONFIG_SERIAL_CONEXANT_DIGICOLOR=y
# CONFIG_SERIAL_CONEXANT_DIGICOLOR_CONSOLE is not set
CONFIG_SERIAL_DEV_BUS=y
# CONFIG_SERIAL_DEV_CTRL_TTYPORT is not set
CONFIG_TTY_PRINTK=y
CONFIG_PRINTER=y
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_DMI_DECODE=y
CONFIG_IPMI_PANIC_EVENT=y
# CONFIG_IPMI_PANIC_STRING is not set
# CONFIG_IPMI_DEVICE_INTERFACE is not set
CONFIG_IPMI_SI=y
# CONFIG_IPMI_SSIF is not set
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
CONFIG_R3964=y
CONFIG_APPLICOM=y

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=y
# CONFIG_CARDMAN_4040 is not set
# CONFIG_SCR24X is not set
# CONFIG_IPWIRELESS is not set
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
# CONFIG_HW_RANDOM_TPM is not set
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_SPI is not set
CONFIG_TCG_TIS_I2C_ATMEL=y
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
CONFIG_TCG_CRB=y
# CONFIG_TCG_VTPM_PROXY is not set
# CONFIG_TCG_TIS_ST33ZP24_I2C is not set
# CONFIG_TCG_TIS_ST33ZP24_SPI is not set
CONFIG_TELCLOCK=y
# CONFIG_DEVPORT is not set
CONFIG_XILLYBUS=y
CONFIG_XILLYBUS_PCIE=y
# CONFIG_XILLYBUS_OF is not set
# CONFIG_RANDOM_TRUST_CPU is not set

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
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_GPMUX=y
CONFIG_I2C_MUX_LTC4306=y
CONFIG_I2C_MUX_PCA9541=y
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_MUX_PINCTRL is not set
# CONFIG_I2C_MUX_REG is not set
# CONFIG_I2C_DEMUX_PINCTRL is not set
CONFIG_I2C_MUX_MLXCPLD=y
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
# CONFIG_I2C_ALGOPCF is not set
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
CONFIG_I2C_AMD756_S4882=y
CONFIG_I2C_AMD8111=y
# CONFIG_I2C_I801 is not set
CONFIG_I2C_ISCH=y
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
CONFIG_I2C_SIS5595=y
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_DESIGNWARE_BAYTRAIL=y
# CONFIG_I2C_EMEV2 is not set
# CONFIG_I2C_GPIO is not set
CONFIG_I2C_KEMPLD=y
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_RK3X is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_ROBOTFUZZ_OSIF=y
CONFIG_I2C_TAOS_EVM=y
CONFIG_I2C_TINY_USB=y
CONFIG_I2C_VIPERBOARD=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_MLXCPLD is not set
CONFIG_I2C_CROS_EC_TUNNEL=y
# CONFIG_I2C_SLAVE is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y
# CONFIG_SPI_MEM is not set

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
# CONFIG_SPI_AXI_SPI_ENGINE is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
CONFIG_SPI_CADENCE=y
# CONFIG_SPI_DESIGNWARE is not set
CONFIG_SPI_GPIO=y
CONFIG_SPI_LM70_LLP=y
# CONFIG_SPI_FSL_SPI is not set
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_ROCKCHIP is not set
CONFIG_SPI_SC18IS602=y
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
CONFIG_SPI_ZYNQMP_GQSPI=y

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
# CONFIG_SPI_SLAVE is not set
CONFIG_SPMI=y
# CONFIG_HSI is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
CONFIG_PPS_CLIENT_LDISC=y
# CONFIG_PPS_CLIENT_PARPORT is not set
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_KVM=y
CONFIG_PINCTRL=y
CONFIG_GENERIC_PINCTRL_GROUPS=y
CONFIG_PINMUX=y
CONFIG_GENERIC_PINMUX_FUNCTIONS=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
CONFIG_DEBUG_PINCTRL=y
# CONFIG_PINCTRL_AS3722 is not set
# CONFIG_PINCTRL_AMD is not set
# CONFIG_PINCTRL_MCP23S08 is not set
CONFIG_PINCTRL_SINGLE=y
# CONFIG_PINCTRL_SX150X is not set
# CONFIG_PINCTRL_PALMAS is not set
# CONFIG_PINCTRL_RK805 is not set
# CONFIG_PINCTRL_BAYTRAIL is not set
# CONFIG_PINCTRL_CHERRYVIEW is not set
CONFIG_PINCTRL_INTEL=y
# CONFIG_PINCTRL_BROXTON is not set
CONFIG_PINCTRL_CANNONLAKE=y
CONFIG_PINCTRL_CEDARFORK=y
CONFIG_PINCTRL_DENVERTON=y
# CONFIG_PINCTRL_GEMINILAKE is not set
# CONFIG_PINCTRL_ICELAKE is not set
# CONFIG_PINCTRL_LEWISBURG is not set
# CONFIG_PINCTRL_SUNRISEPOINT is not set
CONFIG_PINCTRL_MADERA=y
CONFIG_PINCTRL_CS47L85=y
CONFIG_PINCTRL_CS47L90=y
CONFIG_GPIOLIB=y
CONFIG_GPIOLIB_FASTPATH_LIMIT=512
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_74XX_MMIO=y
CONFIG_GPIO_ALTERA=y
# CONFIG_GPIO_AMDPT is not set
CONFIG_GPIO_DWAPB=y
CONFIG_GPIO_EXAR=y
CONFIG_GPIO_FTGPIO010=y
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_GRGPIO is not set
CONFIG_GPIO_HLWD=y
CONFIG_GPIO_ICH=y
CONFIG_GPIO_LYNXPOINT=y
# CONFIG_GPIO_MB86S7X is not set
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_SYSCON is not set
CONFIG_GPIO_VX855=y
CONFIG_GPIO_XILINX=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_104_DIO_48E=y
CONFIG_GPIO_104_IDIO_16=y
CONFIG_GPIO_104_IDI_48=y
# CONFIG_GPIO_F7188X is not set
CONFIG_GPIO_GPIO_MM=y
# CONFIG_GPIO_IT87 is not set
CONFIG_GPIO_SCH=y
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_WINBOND is not set
# CONFIG_GPIO_WS16C48 is not set

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
# CONFIG_GPIO_ADNP is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=y
CONFIG_GPIO_ARIZONA=y
# CONFIG_GPIO_BD9571MWV is not set
# CONFIG_GPIO_CRYSTAL_COVE is not set
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_JANZ_TTL=y
CONFIG_GPIO_KEMPLD=y
CONFIG_GPIO_LP3943=y
# CONFIG_GPIO_LP87565 is not set
# CONFIG_GPIO_MADERA is not set
CONFIG_GPIO_PALMAS=y
CONFIG_GPIO_TPS65086=y
# CONFIG_GPIO_TPS6586X is not set
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL6040=y
CONFIG_GPIO_WHISKEY_COVE=y
CONFIG_GPIO_WM831X=y
CONFIG_GPIO_WM8350=y
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=y
# CONFIG_GPIO_BT8XX is not set
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_PCI_IDIO_16 is not set
CONFIG_GPIO_PCIE_IDIO_24=y
# CONFIG_GPIO_RDC321X is not set
# CONFIG_GPIO_SODAVILLE is not set

#
# SPI GPIO expanders
#
CONFIG_GPIO_74X164=y
CONFIG_GPIO_MAX3191X=y
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MC33880 is not set
CONFIG_GPIO_PISOSR=y
CONFIG_GPIO_XRA1403=y

#
# USB GPIO expanders
#
# CONFIG_GPIO_VIPERBOARD is not set
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2405=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2805 is not set
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2438=y
CONFIG_W1_SLAVE_DS2780=y
# CONFIG_W1_SLAVE_DS2781 is not set
CONFIG_W1_SLAVE_DS28E04=y
# CONFIG_W1_SLAVE_DS28E17 is not set
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_AS3722 is not set
# CONFIG_POWER_RESET_GPIO is not set
# CONFIG_POWER_RESET_GPIO_RESTART is not set
# CONFIG_POWER_RESET_LTC2952 is not set
CONFIG_POWER_RESET_RESTART=y
CONFIG_POWER_RESET_SYSCON=y
# CONFIG_POWER_RESET_SYSCON_POWEROFF is not set
CONFIG_REBOOT_MODE=y
CONFIG_SYSCON_REBOOT_MODE=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
# CONFIG_WM831X_BACKUP is not set
CONFIG_WM831X_POWER=y
CONFIG_WM8350_POWER=y
# CONFIG_TEST_POWER is not set
# CONFIG_CHARGER_ADP5061 is not set
CONFIG_BATTERY_ACT8945A=y
CONFIG_BATTERY_CPCAP=y
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_LEGO_EV3=y
CONFIG_BATTERY_SBS=y
CONFIG_CHARGER_SBS=y
CONFIG_MANAGER_SBS=y
CONFIG_BATTERY_BQ27XXX=y
CONFIG_BATTERY_BQ27XXX_I2C=y
# CONFIG_BATTERY_BQ27XXX_HDQ is not set
CONFIG_BATTERY_BQ27XXX_DT_UPDATES_NVM=y
# CONFIG_BATTERY_DA9030 is not set
# CONFIG_BATTERY_DA9052 is not set
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_BATTERY_MAX1721X is not set
CONFIG_CHARGER_PCF50633=y
CONFIG_CHARGER_ISP1704=y
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_LP8788=y
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_LTC3651=y
CONFIG_CHARGER_MAX14577=y
CONFIG_CHARGER_DETECTOR_MAX14656=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
# CONFIG_CHARGER_SMB347 is not set
CONFIG_CHARGER_TPS65217=y
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
CONFIG_CHARGER_RT9455=y
CONFIG_CHARGER_CROS_USBPD=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
# CONFIG_SENSORS_ABITUGURU3 is not set
CONFIG_SENSORS_AD7314=y
CONFIG_SENSORS_AD7414=y
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
CONFIG_SENSORS_ADM1025=y
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=y
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ASPEED=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_MC13783_ADC=y
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
# CONFIG_SENSORS_IIO_HWMON is not set
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
# CONFIG_SENSORS_POWR1220 is not set
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_MAX16065=y
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_MAX31722=y
CONFIG_SENSORS_MAX6621=y
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_MAX6697=y
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_TC654=y
CONFIG_SENSORS_MENF21BMC_HWMON=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM70=y
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=y
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
# CONFIG_SENSORS_NCT6775 is not set
CONFIG_SENSORS_NCT7802=y
# CONFIG_SENSORS_NCT7904 is not set
# CONFIG_SENSORS_NPCM7XX is not set
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_PWM_FAN is not set
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHT3x=y
CONFIG_SENSORS_SHTC1=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_STTS751 is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_INA3221=y
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
# CONFIG_SENSORS_TMP102 is not set
CONFIG_SENSORS_TMP103=y
# CONFIG_SENSORS_TMP108 is not set
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
# CONFIG_SENSORS_VT1211 is not set
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83773G=y
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
# CONFIG_SENSORS_WM831X is not set
CONFIG_SENSORS_WM8350=y
# CONFIG_SENSORS_XGENE is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
CONFIG_THERMAL_STATISTICS=y
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
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
# CONFIG_CLOCK_THERMAL is not set
CONFIG_DEVFREQ_THERMAL=y
CONFIG_THERMAL_EMULATION=y
# CONFIG_DA9062_THERMAL is not set
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=y
CONFIG_ACPI_THERMAL_REL=y
CONFIG_INT3406_THERMAL=y
CONFIG_INTEL_BXT_PMIC_THERMAL=y
CONFIG_INTEL_PCH_THERMAL=y
# CONFIG_QCOM_SPMI_TEMP_ALARM is not set
# CONFIG_GENERIC_ADC_THERMAL is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
# CONFIG_SSB_PCMCIAHOST is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_ACT8945A=y
CONFIG_MFD_AS3711=y
CONFIG_MFD_AS3722=y
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_ATMEL_FLEXCOM=y
# CONFIG_MFD_ATMEL_HLCDC is not set
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_BD9571MWV=y
# CONFIG_MFD_AXP20X_I2C is not set
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_CHARDEV=y
CONFIG_MFD_MADERA=y
CONFIG_MFD_MADERA_I2C=y
# CONFIG_MFD_MADERA_SPI is not set
# CONFIG_MFD_CS47L35 is not set
CONFIG_MFD_CS47L85=y
CONFIG_MFD_CS47L90=y
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
# CONFIG_MFD_DA9150 is not set
# CONFIG_MFD_DLN2 is not set
CONFIG_MFD_MC13XXX=y
# CONFIG_MFD_MC13XXX_SPI is not set
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_MFD_HI6421_PMIC=y
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_INTEL_SOC_PMIC=y
CONFIG_INTEL_SOC_PMIC_BXTWC=y
# CONFIG_INTEL_SOC_PMIC_CHTWC is not set
CONFIG_INTEL_SOC_PMIC_CHTDC_TI=y
CONFIG_MFD_INTEL_LPSS=y
CONFIG_MFD_INTEL_LPSS_ACPI=y
# CONFIG_MFD_INTEL_LPSS_PCI is not set
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_KEMPLD=y
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77620 is not set
CONFIG_MFD_MAX77686=y
# CONFIG_MFD_MAX77693 is not set
CONFIG_MFD_MAX77843=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
CONFIG_EZX_PCAP=y
CONFIG_MFD_CPCAP=y
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
CONFIG_MFD_RDC321X=y
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_RK808=y
CONFIG_MFD_RN5T618=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SKY81452=y
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
CONFIG_MFD_TI_LMU=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65086=y
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS68470 is not set
# CONFIG_MFD_TI_LP873X is not set
CONFIG_MFD_TI_LP87565=y
# CONFIG_MFD_TPS65218 is not set
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TC3589X is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_CS47L24=y
# CONFIG_MFD_WM5102 is not set
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8998=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_MFD_ROHM_BD718XX=y
CONFIG_RAVE_SP_CORE=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PG86X=y
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_ACT8945A=y
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AS3711=y
# CONFIG_REGULATOR_AS3722 is not set
# CONFIG_REGULATOR_BCM590XX is not set
CONFIG_REGULATOR_BD718XX=y
CONFIG_REGULATOR_BD9571MWV=y
# CONFIG_REGULATOR_CPCAP is not set
# CONFIG_REGULATOR_DA903X is not set
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_DA9055 is not set
# CONFIG_REGULATOR_DA9062 is not set
CONFIG_REGULATOR_DA9063=y
# CONFIG_REGULATOR_DA9210 is not set
# CONFIG_REGULATOR_DA9211 is not set
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
CONFIG_REGULATOR_HI6421=y
CONFIG_REGULATOR_HI6421V530=y
# CONFIG_REGULATOR_ISL9305 is not set
# CONFIG_REGULATOR_ISL6271A is not set
# CONFIG_REGULATOR_LM363X is not set
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
# CONFIG_REGULATOR_LP87565 is not set
CONFIG_REGULATOR_LP8788=y
# CONFIG_REGULATOR_LTC3589 is not set
CONFIG_REGULATOR_LTC3676=y
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX77686=y
CONFIG_REGULATOR_MAX77693=y
# CONFIG_REGULATOR_MAX77802 is not set
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
# CONFIG_REGULATOR_MC13892 is not set
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_MT6323=y
# CONFIG_REGULATOR_MT6397 is not set
# CONFIG_REGULATOR_PALMAS is not set
CONFIG_REGULATOR_PCAP=y
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
# CONFIG_REGULATOR_PV88090 is not set
CONFIG_REGULATOR_PWM=y
# CONFIG_REGULATOR_QCOM_SPMI is not set
CONFIG_REGULATOR_RK808=y
CONFIG_REGULATOR_RN5T618=y
CONFIG_REGULATOR_SKY81452=y
# CONFIG_REGULATOR_SY8106A is not set
CONFIG_REGULATOR_TPS51632=y
# CONFIG_REGULATOR_TPS6105X is not set
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65086=y
CONFIG_REGULATOR_TPS65132=y
# CONFIG_REGULATOR_TPS65217 is not set
# CONFIG_REGULATOR_TPS6524X is not set
# CONFIG_REGULATOR_TPS6586X is not set
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_VCTRL=y
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8350=y
CONFIG_REGULATOR_WM8400=y
# CONFIG_REGULATOR_WM8994 is not set
CONFIG_CEC_CORE=y
CONFIG_CEC_NOTIFIER=y
CONFIG_RC_CORE=y
# CONFIG_RC_MAP is not set
CONFIG_LIRC=y
# CONFIG_RC_DECODERS is not set
CONFIG_RC_DEVICES=y
CONFIG_RC_ATI_REMOTE=y
# CONFIG_IR_ENE is not set
CONFIG_IR_HIX5HD2=y
CONFIG_IR_IMON=y
CONFIG_IR_IMON_RAW=y
CONFIG_IR_MCEUSB=y
CONFIG_IR_ITE_CIR=y
CONFIG_IR_FINTEK=y
CONFIG_IR_NUVOTON=y
CONFIG_IR_REDRAT3=y
CONFIG_IR_SPI=y
CONFIG_IR_STREAMZAP=y
# CONFIG_IR_WINBOND_CIR is not set
# CONFIG_IR_IGORPLUGUSB is not set
# CONFIG_IR_IGUANA is not set
CONFIG_IR_TTUSBIR=y
CONFIG_RC_LOOPBACK=y
CONFIG_IR_GPIO_CIR=y
# CONFIG_IR_GPIO_TX is not set
# CONFIG_IR_PWM_TX is not set
CONFIG_IR_SERIAL=y
# CONFIG_IR_SERIAL_TRANSMITTER is not set
CONFIG_IR_SIR=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
CONFIG_MEDIA_SDR_SUPPORT=y
# CONFIG_MEDIA_CEC_SUPPORT is not set
# CONFIG_MEDIA_CEC_RC is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
# CONFIG_VIDEO_PCI_SKELETON is not set
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_V4L2_FWNODE=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_DMA_SG=y

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#
CONFIG_VIDEO_TW5864=y
CONFIG_VIDEO_TW68=y
CONFIG_V4L_PLATFORM_DRIVERS=y
CONFIG_VIDEO_CAFE_CCIC=y
CONFIG_VIDEO_VIA_CAMERA=y
# CONFIG_VIDEO_CADENCE is not set
# CONFIG_SOC_CAMERA is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIVID=y
# CONFIG_VIDEO_VIVID_CEC is not set
CONFIG_VIDEO_VIVID_MAX_DEVS=64
CONFIG_VIDEO_VIM2M=y
CONFIG_SDR_PLATFORM_DRIVERS=y

#
# Supported MMC/SDIO adapters
#
# CONFIG_RADIO_ADAPTERS is not set
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_V4L2=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_VIDEOBUF2_DMA_SG=y
CONFIG_VIDEO_V4L2_TPG=y

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
# CONFIG_VIDEO_IR_I2C is not set

#
# I2C Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
# CONFIG_VIDEO_TVAUDIO is not set
# CONFIG_VIDEO_TDA7432 is not set
# CONFIG_VIDEO_TDA9840 is not set
CONFIG_VIDEO_TEA6415C=y
CONFIG_VIDEO_TEA6420=y
CONFIG_VIDEO_MSP3400=y
# CONFIG_VIDEO_CS3308 is not set
# CONFIG_VIDEO_CS5345 is not set
CONFIG_VIDEO_CS53L32A=y
# CONFIG_VIDEO_TLV320AIC23B is not set
CONFIG_VIDEO_UDA1342=y
# CONFIG_VIDEO_WM8775 is not set
# CONFIG_VIDEO_WM8739 is not set
CONFIG_VIDEO_VP27SMPX=y
CONFIG_VIDEO_SONY_BTF_MPX=y

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=y

#
# Video decoders
#
# CONFIG_VIDEO_ADV7183 is not set
CONFIG_VIDEO_BT819=y
CONFIG_VIDEO_BT856=y
# CONFIG_VIDEO_BT866 is not set
CONFIG_VIDEO_KS0127=y
CONFIG_VIDEO_ML86V7667=y
CONFIG_VIDEO_SAA7110=y
CONFIG_VIDEO_SAA711X=y
CONFIG_VIDEO_TVP514X=y
CONFIG_VIDEO_TVP5150=y
CONFIG_VIDEO_TVP7002=y
CONFIG_VIDEO_TW2804=y
CONFIG_VIDEO_TW9903=y
CONFIG_VIDEO_TW9906=y
CONFIG_VIDEO_TW9910=y
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=y
# CONFIG_VIDEO_CX25840 is not set

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=y
CONFIG_VIDEO_SAA7185=y
CONFIG_VIDEO_ADV7170=y
CONFIG_VIDEO_ADV7175=y
CONFIG_VIDEO_ADV7343=y
CONFIG_VIDEO_ADV7393=y
CONFIG_VIDEO_AK881X=y
# CONFIG_VIDEO_THS8200 is not set

#
# Camera sensor devices
#
CONFIG_VIDEO_OV2640=y
CONFIG_VIDEO_OV2659=y
CONFIG_VIDEO_OV6650=y
CONFIG_VIDEO_OV5695=y
CONFIG_VIDEO_OV772X=y
CONFIG_VIDEO_OV7640=y
CONFIG_VIDEO_OV7670=y
# CONFIG_VIDEO_OV7740 is not set
CONFIG_VIDEO_VS6624=y
CONFIG_VIDEO_MT9M111=y
CONFIG_VIDEO_MT9T112=y
# CONFIG_VIDEO_MT9V011 is not set
CONFIG_VIDEO_MT9V111=y
# CONFIG_VIDEO_SR030PC30 is not set
CONFIG_VIDEO_RJ54N1=y

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=y
CONFIG_VIDEO_UPD64083=y

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=y

#
# SDR tuner chips
#
# CONFIG_SDR_MAX2175 is not set

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=y
# CONFIG_VIDEO_M52790 is not set
CONFIG_VIDEO_I2C=y

#
# Sensors used on soc_camera driver
#

#
# SPI helper chips
#

#
# Media SPI Adapters
#
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA18250=y
# CONFIG_MEDIA_TUNER_TDA8290 is not set
# CONFIG_MEDIA_TUNER_TDA827X is not set
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
# CONFIG_MEDIA_TUNER_TEA5761 is not set
CONFIG_MEDIA_TUNER_TEA5767=y
# CONFIG_MEDIA_TUNER_MSI001 is not set
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_MT2060=y
# CONFIG_MEDIA_TUNER_MT2063 is not set
CONFIG_MEDIA_TUNER_MT2266=y
# CONFIG_MEDIA_TUNER_MT2131 is not set
CONFIG_MEDIA_TUNER_QT1010=y
# CONFIG_MEDIA_TUNER_XC2028 is not set
CONFIG_MEDIA_TUNER_XC5000=y
# CONFIG_MEDIA_TUNER_XC4000 is not set
CONFIG_MEDIA_TUNER_MXL5005S=y
CONFIG_MEDIA_TUNER_MXL5007T=y
# CONFIG_MEDIA_TUNER_MC44S803 is not set
CONFIG_MEDIA_TUNER_MAX2165=y
# CONFIG_MEDIA_TUNER_TDA18218 is not set
# CONFIG_MEDIA_TUNER_FC0011 is not set
CONFIG_MEDIA_TUNER_FC0012=y
CONFIG_MEDIA_TUNER_FC0013=y
# CONFIG_MEDIA_TUNER_TDA18212 is not set
# CONFIG_MEDIA_TUNER_E4000 is not set
CONFIG_MEDIA_TUNER_FC2580=y
CONFIG_MEDIA_TUNER_M88RS6000T=y
# CONFIG_MEDIA_TUNER_TUA9001 is not set
# CONFIG_MEDIA_TUNER_SI2157 is not set
CONFIG_MEDIA_TUNER_IT913X=y
# CONFIG_MEDIA_TUNER_R820T is not set
CONFIG_MEDIA_TUNER_MXL301RF=y
# CONFIG_MEDIA_TUNER_QM1D1C0042 is not set
# CONFIG_MEDIA_TUNER_QM1D1B0004 is not set

#
# Customise DVB Frontends
#

#
# Tools to develop new frontends
#

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=y
CONFIG_DRM_MIPI_DSI=y
# CONFIG_DRM_DP_AUX_CHARDEV is not set
# CONFIG_DRM_DEBUG_MM is not set
CONFIG_DRM_DEBUG_SELFTEST=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_FBDEV_EMULATION is not set
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_DP_CEC=y
CONFIG_DRM_TTM=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_VM=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
CONFIG_DRM_I2C_SIL164=y
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_I2C_NXP_TDA9950=y
CONFIG_DRM_RADEON=y
CONFIG_DRM_RADEON_USERPTR=y
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
CONFIG_NOUVEAU_DEBUG_MMU=y
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
CONFIG_DRM_I915=y
CONFIG_DRM_I915_ALPHA_SUPPORT=y
# CONFIG_DRM_I915_CAPTURE_ERROR is not set
# CONFIG_DRM_I915_USERPTR is not set
CONFIG_DRM_I915_GVT=y

#
# drm/i915 Debugging
#
CONFIG_DRM_I915_WERROR=y
# CONFIG_DRM_I915_DEBUG is not set
# CONFIG_DRM_I915_DEBUG_GEM is not set
# CONFIG_DRM_I915_SW_FENCE_DEBUG_OBJECTS is not set
# CONFIG_DRM_I915_SW_FENCE_CHECK_DAG is not set
# CONFIG_DRM_I915_DEBUG_GUC is not set
CONFIG_DRM_I915_SELFTEST=y
# CONFIG_DRM_I915_LOW_LEVEL_TRACEPOINTS is not set
CONFIG_DRM_I915_DEBUG_VBLANK_EVADE=y
# CONFIG_DRM_VGEM is not set
# CONFIG_DRM_VKMS is not set
CONFIG_DRM_VMWGFX=y
CONFIG_DRM_VMWGFX_FBCON=y
CONFIG_DRM_GMA500=y
CONFIG_DRM_GMA600=y
CONFIG_DRM_GMA3600=y
CONFIG_DRM_UDL=y
CONFIG_DRM_AST=y
CONFIG_DRM_MGAG200=y
CONFIG_DRM_CIRRUS_QEMU=y
# CONFIG_DRM_RCAR_DW_HDMI is not set
# CONFIG_DRM_RCAR_LVDS is not set
CONFIG_DRM_QXL=y
CONFIG_DRM_BOCHS=y
CONFIG_DRM_VIRTIO_GPU=y
CONFIG_DRM_PANEL=y

#
# Display Panels
#
# CONFIG_DRM_PANEL_ARM_VERSATILE is not set
# CONFIG_DRM_PANEL_LVDS is not set
CONFIG_DRM_PANEL_SIMPLE=y
CONFIG_DRM_PANEL_ILITEK_IL9322=y
CONFIG_DRM_PANEL_ILITEK_ILI9881C=y
# CONFIG_DRM_PANEL_INNOLUX_P079ZCA is not set
# CONFIG_DRM_PANEL_JDI_LT070ME05000 is not set
CONFIG_DRM_PANEL_SAMSUNG_LD9040=y
# CONFIG_DRM_PANEL_LG_LG4573 is not set
CONFIG_DRM_PANEL_ORISETECH_OTM8009A=y
# CONFIG_DRM_PANEL_PANASONIC_VVX10F034N00 is not set
CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN=y
CONFIG_DRM_PANEL_RAYDIUM_RM68200=y
# CONFIG_DRM_PANEL_SAMSUNG_S6E3HA2 is not set
# CONFIG_DRM_PANEL_SAMSUNG_S6E63J0X03 is not set
CONFIG_DRM_PANEL_SAMSUNG_S6E8AA0=y
# CONFIG_DRM_PANEL_SEIKO_43WVF1G is not set
CONFIG_DRM_PANEL_SHARP_LQ101R1SX01=y
# CONFIG_DRM_PANEL_SHARP_LS043T1LE01 is not set
# CONFIG_DRM_PANEL_SITRONIX_ST7789V is not set
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_ANALOGIX_ANX78XX=y
# CONFIG_DRM_CDNS_DSI is not set
CONFIG_DRM_DUMB_VGA_DAC=y
CONFIG_DRM_LVDS_ENCODER=y
# CONFIG_DRM_MEGACHIPS_STDPXXXX_GE_B850V3_FW is not set
CONFIG_DRM_NXP_PTN3460=y
CONFIG_DRM_PARADE_PS8622=y
CONFIG_DRM_SIL_SII8620=y
# CONFIG_DRM_SII902X is not set
CONFIG_DRM_SII9234=y
CONFIG_DRM_THINE_THC63LVD1024=y
CONFIG_DRM_TOSHIBA_TC358767=y
CONFIG_DRM_TI_TFP410=y
CONFIG_DRM_I2C_ADV7511=y
# CONFIG_DRM_I2C_ADV7533 is not set
# CONFIG_DRM_I2C_ADV7511_CEC is not set
CONFIG_DRM_ARCPGU=y
CONFIG_DRM_HISI_HIBMC=y
# CONFIG_DRM_MXSFB is not set
# CONFIG_DRM_TINYDRM is not set
# CONFIG_DRM_LEGACY is not set
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y
CONFIG_DRM_LIB_RANDOM=y

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
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
CONFIG_FB_PM2_FIFO_DISCONNECT=y
CONFIG_FB_CYBER2000=y
# CONFIG_FB_CYBER2000_DDC is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
CONFIG_FB_IMSTT=y
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=y
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
CONFIG_FB_NVIDIA_DEBUG=y
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
CONFIG_FB_RIVA=y
CONFIG_FB_RIVA_I2C=y
CONFIG_FB_RIVA_DEBUG=y
CONFIG_FB_RIVA_BACKLIGHT=y
CONFIG_FB_I740=y
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
CONFIG_FB_MATROX=y
CONFIG_FB_MATROX_MILLENIUM=y
CONFIG_FB_MATROX_MYSTIQUE=y
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=y
# CONFIG_FB_MATROX_MAVEN is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
CONFIG_FB_S3=y
CONFIG_FB_S3_DDC=y
CONFIG_FB_SAVAGE=y
CONFIG_FB_SAVAGE_I2C=y
# CONFIG_FB_SAVAGE_ACCEL is not set
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
# CONFIG_FB_SIS_315 is not set
CONFIG_FB_VIA=y
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
CONFIG_FB_VIA_X_COMPATIBILITY=y
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
# CONFIG_FB_3DFX_I2C is not set
CONFIG_FB_VOODOO1=y
# CONFIG_FB_VT8623 is not set
CONFIG_FB_TRIDENT=y
# CONFIG_FB_ARK is not set
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=y
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
# CONFIG_FB_SMSCUFX is not set
CONFIG_FB_UDL=y
CONFIG_FB_IBM_GXT4500=y
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_HYPERV is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_FB_SSD1307=y
CONFIG_FB_SM712=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_L4F00242T03=y
# CONFIG_LCD_LMS283GF05 is not set
CONFIG_LCD_LTV350QV=y
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_S6E63M0=y
CONFIG_LCD_LD9040=y
CONFIG_LCD_AMS369FG06=y
CONFIG_LCD_LMS501KF03=y
CONFIG_LCD_HX8357=y
CONFIG_LCD_OTM3225A=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_CARILLO_RANCH=y
CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_DA903X=y
# CONFIG_BACKLIGHT_DA9052 is not set
CONFIG_BACKLIGHT_APPLE=y
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP5520=y
CONFIG_BACKLIGHT_ADP8860=y
# CONFIG_BACKLIGHT_ADP8870 is not set
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_LM3630A=y
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_LP855X is not set
CONFIG_BACKLIGHT_LP8788=y
# CONFIG_BACKLIGHT_SKY81452 is not set
# CONFIG_BACKLIGHT_TPS65217 is not set
# CONFIG_BACKLIGHT_AS3711 is not set
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
CONFIG_BACKLIGHT_ARCXCNN=y
# CONFIG_BACKLIGHT_RAVE_SP is not set
CONFIG_VGASTATE=y
CONFIG_VIDEOMODE_HELPERS=y
CONFIG_HDMI=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=y
# CONFIG_SND is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACCUTOUCH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_APPLEIR is not set
CONFIG_HID_ASUS=y
CONFIG_HID_AUREAL=y
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_BETOP_FF is not set
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_CORSAIR is not set
CONFIG_HID_COUGAR=y
CONFIG_HID_CMEDIA=y
CONFIG_HID_CP2112=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
CONFIG_HID_EMS_FF=y
# CONFIG_HID_ELAN is not set
CONFIG_HID_ELECOM=y
CONFIG_HID_ELO=y
CONFIG_HID_EZKEY=y
CONFIG_HID_GEMBIRD=y
# CONFIG_HID_GFRM is not set
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_GOOGLE_HAMMER is not set
# CONFIG_HID_GT683R is not set
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=y
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_ITE=y
CONFIG_HID_JABRA=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
CONFIG_HID_LENOVO=y
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MAYFLASH=y
CONFIG_HID_REDRAGON=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_NTI=y
# CONFIG_HID_NTRIG is not set
CONFIG_HID_ORTEK=y
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PENMOUNT is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
CONFIG_HID_PRIMAX=y
CONFIG_HID_RETRODE=y
CONFIG_HID_ROCCAT=y
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
# CONFIG_HID_SONY is not set
CONFIG_HID_SPEEDLINK=y
# CONFIG_HID_STEAM is not set
CONFIG_HID_STEELSERIES=y
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_RMI is not set
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_HYPERV_MOUSE=y
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_UDRAW_PS3=y
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set
CONFIG_HID_ALPS=y

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set

#
# Intel ISH HID support
#
CONFIG_INTEL_ISH_HID=y
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
CONFIG_USB_DYNAMIC_MINORS=y
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_LEDS_TRIGGER_USBPORT is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_DBGCAP=y
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_FOTG210_HCD=y
CONFIG_USB_MAX3421_HCD=y
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_HCD_PCI is not set
# CONFIG_USB_OHCI_HCD_SSB is not set
CONFIG_USB_OHCI_HCD_PLATFORM=y
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_U132_HCD is not set
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=y
CONFIG_USB_R8A66597_HCD=y
CONFIG_USB_WHCI_HCD=y
CONFIG_USB_HWA_HCD=y
CONFIG_USB_HCD_SSB=y
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
# CONFIG_USB_WDM is not set
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
CONFIG_USB_STORAGE_DEBUG=y
# CONFIG_USB_STORAGE_REALTEK is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
CONFIG_USB_STORAGE_ONETOUCH=y
CONFIG_USB_STORAGE_KARMA=y
CONFIG_USB_STORAGE_CYPRESS_ATACB=y
# CONFIG_USB_STORAGE_ENE_UB6250 is not set
CONFIG_USB_UAS=y

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
CONFIG_USB_MICROTEK=y
# CONFIG_USBIP_CORE is not set
# CONFIG_USB_MUSB_HDRC is not set
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_ULPI=y
# CONFIG_USB_DWC3_HOST is not set
# CONFIG_USB_DWC3_GADGET is not set
CONFIG_USB_DWC3_DUAL_ROLE=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
# CONFIG_USB_DWC3_HAPS is not set
# CONFIG_USB_DWC3_OF_SIMPLE is not set
CONFIG_USB_DWC2=y
# CONFIG_USB_DWC2_HOST is not set

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
CONFIG_USB_DWC2_PERIPHERAL=y
# CONFIG_USB_DWC2_DUAL_ROLE is not set
# CONFIG_USB_DWC2_PCI is not set
# CONFIG_USB_DWC2_DEBUG is not set
# CONFIG_USB_DWC2_TRACK_MISSED_SOFS is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_ISP1760 is not set

#
# USB port drivers
#
# CONFIG_USB_USS720 is not set
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
# CONFIG_USB_SERIAL_CYPRESS_M8 is not set
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
CONFIG_USB_SERIAL_VISOR=y
# CONFIG_USB_SERIAL_IPAQ is not set
CONFIG_USB_SERIAL_IR=y
# CONFIG_USB_SERIAL_EDGEPORT is not set
CONFIG_USB_SERIAL_EDGEPORT_TI=y
CONFIG_USB_SERIAL_F81232=y
CONFIG_USB_SERIAL_F8153X=y
CONFIG_USB_SERIAL_GARMIN=y
CONFIG_USB_SERIAL_IPW=y
CONFIG_USB_SERIAL_IUU=y
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
CONFIG_USB_SERIAL_KEYSPAN=y
CONFIG_USB_SERIAL_KLSI=y
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
CONFIG_USB_SERIAL_MCT_U232=y
CONFIG_USB_SERIAL_METRO=y
# CONFIG_USB_SERIAL_MOS7720 is not set
CONFIG_USB_SERIAL_MOS7840=y
# CONFIG_USB_SERIAL_MXUPORT is not set
# CONFIG_USB_SERIAL_NAVMAN is not set
# CONFIG_USB_SERIAL_PL2303 is not set
CONFIG_USB_SERIAL_OTI6858=y
# CONFIG_USB_SERIAL_QCAUX is not set
# CONFIG_USB_SERIAL_QUALCOMM is not set
# CONFIG_USB_SERIAL_SPCP8X5 is not set
CONFIG_USB_SERIAL_SAFE=y
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
# CONFIG_USB_SERIAL_SYMBOL is not set
# CONFIG_USB_SERIAL_TI is not set
CONFIG_USB_SERIAL_CYBERJACK=y
CONFIG_USB_SERIAL_XIRCOM=y
CONFIG_USB_SERIAL_WWAN=y
# CONFIG_USB_SERIAL_OPTION is not set
CONFIG_USB_SERIAL_OMNINET=y
# CONFIG_USB_SERIAL_OPTICON is not set
# CONFIG_USB_SERIAL_XSENS_MT is not set
# CONFIG_USB_SERIAL_WISHBONE is not set
CONFIG_USB_SERIAL_SSU100=y
CONFIG_USB_SERIAL_QT2=y
CONFIG_USB_SERIAL_UPD78F0730=y
CONFIG_USB_SERIAL_DEBUG=y

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
CONFIG_USB_LEGOTOWER=y
# CONFIG_USB_LCD is not set
CONFIG_USB_CYPRESS_CY7C63=y
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
CONFIG_USB_EHSET_TEST_FIXTURE=y
# CONFIG_USB_ISIGHTFW is not set
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
CONFIG_USB_HUB_USB251XB=y
CONFIG_USB_HSIC_USB3503=y
# CONFIG_USB_HSIC_USB4604 is not set
# CONFIG_USB_LINK_LAYER_TEST is not set
CONFIG_USB_CHAOSKEY=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
# CONFIG_NOP_USB_XCEIV is not set
CONFIG_USB_GPIO_VBUS=y
CONFIG_TAHVO_USB=y
CONFIG_TAHVO_USB_HOST_BY_DEFAULT=y
CONFIG_USB_ISP1301=y
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
CONFIG_USB_GADGET_DEBUG_FS=y
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2
# CONFIG_U_SERIAL_CONSOLE is not set

#
# USB Peripheral Controller
#
CONFIG_USB_FOTG210_UDC=y
CONFIG_USB_GR_UDC=y
CONFIG_USB_R8A66597=y
CONFIG_USB_PXA27X=y
CONFIG_USB_MV_UDC=y
CONFIG_USB_MV_U3D=y
CONFIG_USB_SNP_CORE=y
# CONFIG_USB_SNP_UDC_PLAT is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_BDC_UDC is not set
CONFIG_USB_AMD5536UDC=y
CONFIG_USB_NET2272=y
CONFIG_USB_NET2272_DMA=y
# CONFIG_USB_NET2280 is not set
CONFIG_USB_GOKU=y
CONFIG_USB_EG20T=y
# CONFIG_USB_GADGET_XILINX is not set
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_LIBCOMPOSITE=y
CONFIG_USB_F_ACM=y
CONFIG_USB_F_SS_LB=y
CONFIG_USB_U_SERIAL=y
CONFIG_USB_F_OBEX=y
CONFIG_USB_F_MASS_STORAGE=y
CONFIG_USB_F_FS=y
CONFIG_USB_F_UVC=y
CONFIG_USB_CONFIGFS=y
# CONFIG_USB_CONFIGFS_SERIAL is not set
CONFIG_USB_CONFIGFS_ACM=y
CONFIG_USB_CONFIGFS_OBEX=y
# CONFIG_USB_CONFIGFS_NCM is not set
# CONFIG_USB_CONFIGFS_ECM is not set
# CONFIG_USB_CONFIGFS_ECM_SUBSET is not set
# CONFIG_USB_CONFIGFS_RNDIS is not set
# CONFIG_USB_CONFIGFS_EEM is not set
CONFIG_USB_CONFIGFS_MASS_STORAGE=y
CONFIG_USB_CONFIGFS_F_LB_SS=y
CONFIG_USB_CONFIGFS_F_FS=y
# CONFIG_USB_CONFIGFS_F_HID is not set
CONFIG_USB_CONFIGFS_F_UVC=y
# CONFIG_USB_CONFIGFS_F_PRINTER is not set
CONFIG_TYPEC=y
CONFIG_TYPEC_TCPM=y
CONFIG_TYPEC_TCPCI=y
CONFIG_TYPEC_RT1711H=y
CONFIG_TYPEC_FUSB302=y
CONFIG_TYPEC_UCSI=y
# CONFIG_UCSI_ACPI is not set
# CONFIG_TYPEC_TPS6598X is not set

#
# USB Type-C Multiplexer/DeMultiplexer Switch support
#
CONFIG_TYPEC_MUX_PI3USB30532=y

#
# USB Type-C Alternate Mode drivers
#
CONFIG_TYPEC_DP_ALTMODE=y
CONFIG_USB_ROLES_INTEL_XHCI=y
CONFIG_USB_LED_TRIG=y
CONFIG_USB_ULPI_BUS=y
CONFIG_USB_ROLE_SWITCH=y
CONFIG_UWB=y
CONFIG_UWB_HWA=y
CONFIG_UWB_WHCI=y
CONFIG_UWB_I1480U=y
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y
CONFIG_MSPRO_BLOCK=y
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
CONFIG_MEMSTICK_JMICRON_38X=y
# CONFIG_MEMSTICK_R592 is not set
CONFIG_MEMSTICK_REALTEK_USB=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
# CONFIG_LEDS_AAT1290 is not set
CONFIG_LEDS_APU=y
CONFIG_LEDS_AS3645A=y
CONFIG_LEDS_BCM6328=y
CONFIG_LEDS_BCM6358=y
# CONFIG_LEDS_CPCAP is not set
# CONFIG_LEDS_CR0014114 is not set
CONFIG_LEDS_LM3530=y
# CONFIG_LEDS_LM3642 is not set
CONFIG_LEDS_LM3692X=y
CONFIG_LEDS_LM3601X=y
# CONFIG_LEDS_MT6323 is not set
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_LP8788 is not set
# CONFIG_LEDS_LP8860 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA955X_GPIO is not set
CONFIG_LEDS_PCA963X=y
# CONFIG_LEDS_WM831X_STATUS is not set
CONFIG_LEDS_WM8350=y
# CONFIG_LEDS_DA903X is not set
CONFIG_LEDS_DA9052=y
# CONFIG_LEDS_DAC124S085 is not set
# CONFIG_LEDS_PWM is not set
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
# CONFIG_LEDS_ADP5520 is not set
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_TLC591XX is not set
# CONFIG_LEDS_LM355x is not set
# CONFIG_LEDS_MENF21BMC is not set
CONFIG_LEDS_KTD2692=y
# CONFIG_LEDS_IS31FL319X is not set
# CONFIG_LEDS_IS31FL32XX is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
# CONFIG_LEDS_SYSCON is not set
# CONFIG_LEDS_MLXCPLD is not set
# CONFIG_LEDS_MLXREG is not set
# CONFIG_LEDS_USER is not set
CONFIG_LEDS_NIC78BX=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_ACTIVITY is not set
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
CONFIG_LEDS_TRIGGER_PANIC=y
# CONFIG_LEDS_TRIGGER_NETDEV is not set
CONFIG_ACCESSIBILITY=y
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
# CONFIG_SW_SYNC is not set
CONFIG_AUXDISPLAY=y
CONFIG_HD44780=y
# CONFIG_KS0108 is not set
CONFIG_IMG_ASCII_LCD=y
CONFIG_HT16K33=y
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
# CONFIG_PANEL_CHANGE_MESSAGE is not set
CONFIG_CHARLCD=y
# CONFIG_UIO is not set
# CONFIG_VFIO is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y
# CONFIG_VIRTIO_MENU is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=y
CONFIG_HYPERV_TSCPAGE=y
CONFIG_HYPERV_BALLOON=y
CONFIG_STAGING=y
CONFIG_COMEDI=y
# CONFIG_COMEDI_DEBUG is not set
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
CONFIG_COMEDI_MISC_DRIVERS=y
CONFIG_COMEDI_BOND=y
CONFIG_COMEDI_TEST=y
# CONFIG_COMEDI_PARPORT is not set
# CONFIG_COMEDI_ISA_DRIVERS is not set
CONFIG_COMEDI_PCI_DRIVERS=y
CONFIG_COMEDI_8255_PCI=y
CONFIG_COMEDI_ADDI_WATCHDOG=y
CONFIG_COMEDI_ADDI_APCI_1032=y
CONFIG_COMEDI_ADDI_APCI_1500=y
CONFIG_COMEDI_ADDI_APCI_1516=y
# CONFIG_COMEDI_ADDI_APCI_1564 is not set
# CONFIG_COMEDI_ADDI_APCI_16XX is not set
CONFIG_COMEDI_ADDI_APCI_2032=y
CONFIG_COMEDI_ADDI_APCI_2200=y
# CONFIG_COMEDI_ADDI_APCI_3120 is not set
# CONFIG_COMEDI_ADDI_APCI_3501 is not set
CONFIG_COMEDI_ADDI_APCI_3XXX=y
# CONFIG_COMEDI_ADL_PCI6208 is not set
# CONFIG_COMEDI_ADL_PCI7X3X is not set
CONFIG_COMEDI_ADL_PCI8164=y
# CONFIG_COMEDI_ADL_PCI9111 is not set
CONFIG_COMEDI_ADL_PCI9118=y
CONFIG_COMEDI_ADV_PCI1710=y
CONFIG_COMEDI_ADV_PCI1720=y
CONFIG_COMEDI_ADV_PCI1723=y
CONFIG_COMEDI_ADV_PCI1724=y
CONFIG_COMEDI_ADV_PCI1760=y
CONFIG_COMEDI_ADV_PCI_DIO=y
CONFIG_COMEDI_AMPLC_DIO200_PCI=y
CONFIG_COMEDI_AMPLC_PC236_PCI=y
CONFIG_COMEDI_AMPLC_PC263_PCI=y
CONFIG_COMEDI_AMPLC_PCI224=y
# CONFIG_COMEDI_AMPLC_PCI230 is not set
# CONFIG_COMEDI_CONTEC_PCI_DIO is not set
CONFIG_COMEDI_DAS08_PCI=y
CONFIG_COMEDI_DT3000=y
CONFIG_COMEDI_DYNA_PCI10XX=y
CONFIG_COMEDI_GSC_HPDI=y
CONFIG_COMEDI_MF6X4=y
# CONFIG_COMEDI_ICP_MULTI is not set
CONFIG_COMEDI_DAQBOARD2000=y
CONFIG_COMEDI_JR3_PCI=y
CONFIG_COMEDI_KE_COUNTER=y
CONFIG_COMEDI_CB_PCIDAS64=y
CONFIG_COMEDI_CB_PCIDAS=y
CONFIG_COMEDI_CB_PCIDDA=y
CONFIG_COMEDI_CB_PCIMDAS=y
CONFIG_COMEDI_CB_PCIMDDA=y
CONFIG_COMEDI_ME4000=y
CONFIG_COMEDI_ME_DAQ=y
CONFIG_COMEDI_NI_6527=y
# CONFIG_COMEDI_NI_65XX is not set
# CONFIG_COMEDI_NI_660X is not set
CONFIG_COMEDI_NI_670X=y
CONFIG_COMEDI_NI_LABPC_PCI=y
CONFIG_COMEDI_NI_PCIDIO=y
# CONFIG_COMEDI_NI_PCIMIO is not set
# CONFIG_COMEDI_RTD520 is not set
# CONFIG_COMEDI_S626 is not set
CONFIG_COMEDI_MITE=y
CONFIG_COMEDI_PCMCIA_DRIVERS=y
CONFIG_COMEDI_CB_DAS16_CS=y
CONFIG_COMEDI_DAS08_CS=y
CONFIG_COMEDI_NI_DAQ_700_CS=y
CONFIG_COMEDI_NI_DAQ_DIO24_CS=y
CONFIG_COMEDI_NI_LABPC_CS=y
CONFIG_COMEDI_NI_MIO_CS=y
CONFIG_COMEDI_QUATECH_DAQP_CS=y
CONFIG_COMEDI_USB_DRIVERS=y
# CONFIG_COMEDI_DT9812 is not set
CONFIG_COMEDI_NI_USB6501=y
CONFIG_COMEDI_USBDUX=y
CONFIG_COMEDI_USBDUXFAST=y
CONFIG_COMEDI_USBDUXSIGMA=y
# CONFIG_COMEDI_VMK80XX is not set
CONFIG_COMEDI_8254=y
CONFIG_COMEDI_8255=y
CONFIG_COMEDI_8255_SA=y
CONFIG_COMEDI_KCOMEDILIB=y
CONFIG_COMEDI_AMPLC_DIO200=y
CONFIG_COMEDI_AMPLC_PC236=y
CONFIG_COMEDI_DAS08=y
CONFIG_COMEDI_NI_LABPC=y
CONFIG_COMEDI_NI_TIO=y
# CONFIG_R8712U is not set
# CONFIG_RTS5208 is not set

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
# CONFIG_AD7606 is not set
CONFIG_AD7780=y
CONFIG_AD7816=y
CONFIG_AD7192=y
CONFIG_AD7280=y

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
CONFIG_ADT7316_SPI=y
# CONFIG_ADT7316_I2C is not set

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
CONFIG_AD7152=y
CONFIG_AD7746=y

#
# Direct Digital Synthesis
#
CONFIG_AD9832=y
CONFIG_AD9834=y

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=y

#
# Active energy metering IC
#
# CONFIG_ADE7854 is not set

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
CONFIG_VIDEO_ZORAN=y
# CONFIG_VIDEO_ZORAN_DC30 is not set
# CONFIG_VIDEO_ZORAN_ZR36060 is not set

#
# Android
#
# CONFIG_ASHMEM is not set
# CONFIG_ANDROID_VSOC is not set
# CONFIG_ION is not set
CONFIG_STAGING_BOARD=y
CONFIG_FIREWIRE_SERIAL=y
CONFIG_FWTTY_MAX_TOTAL_PORTS=64
CONFIG_FWTTY_MAX_CARD_PORTS=32
CONFIG_DGNC=y
# CONFIG_GS_FPGABOOT is not set
CONFIG_UNISYSSPAR=y
# CONFIG_COMMON_CLK_XLNX_CLKWZRD is not set
CONFIG_FB_TFT=y
# CONFIG_FB_TFT_AGM1264K_FL is not set
CONFIG_FB_TFT_BD663474=y
CONFIG_FB_TFT_HX8340BN=y
CONFIG_FB_TFT_HX8347D=y
# CONFIG_FB_TFT_HX8353D is not set
# CONFIG_FB_TFT_HX8357D is not set
# CONFIG_FB_TFT_ILI9163 is not set
CONFIG_FB_TFT_ILI9320=y
# CONFIG_FB_TFT_ILI9325 is not set
# CONFIG_FB_TFT_ILI9340 is not set
CONFIG_FB_TFT_ILI9341=y
# CONFIG_FB_TFT_ILI9481 is not set
# CONFIG_FB_TFT_ILI9486 is not set
# CONFIG_FB_TFT_PCD8544 is not set
CONFIG_FB_TFT_RA8875=y
CONFIG_FB_TFT_S6D02A1=y
# CONFIG_FB_TFT_S6D1121 is not set
CONFIG_FB_TFT_SH1106=y
CONFIG_FB_TFT_SSD1289=y
CONFIG_FB_TFT_SSD1305=y
CONFIG_FB_TFT_SSD1306=y
CONFIG_FB_TFT_SSD1331=y
CONFIG_FB_TFT_SSD1351=y
CONFIG_FB_TFT_ST7735R=y
CONFIG_FB_TFT_ST7789V=y
# CONFIG_FB_TFT_TINYLCD is not set
# CONFIG_FB_TFT_TLS8204 is not set
CONFIG_FB_TFT_UC1611=y
CONFIG_FB_TFT_UC1701=y
CONFIG_FB_TFT_UPD161704=y
CONFIG_FB_TFT_WATTEROTT=y
CONFIG_FB_FLEX=y
CONFIG_FB_TFT_FBTFT_DEVICE=y
# CONFIG_MOST is not set
CONFIG_GREYBUS=y
# CONFIG_GREYBUS_ES2 is not set
CONFIG_GREYBUS_AUDIO=y
CONFIG_GREYBUS_BOOTROM=y
# CONFIG_GREYBUS_FIRMWARE is not set
# CONFIG_GREYBUS_HID is not set
CONFIG_GREYBUS_LIGHT=y
# CONFIG_GREYBUS_LOG is not set
# CONFIG_GREYBUS_LOOPBACK is not set
CONFIG_GREYBUS_POWER=y
CONFIG_GREYBUS_RAW=y
CONFIG_GREYBUS_VIBRATOR=y
CONFIG_GREYBUS_BRIDGED_PHY=y
# CONFIG_GREYBUS_GPIO is not set
CONFIG_GREYBUS_I2C=y
CONFIG_GREYBUS_PWM=y
CONFIG_GREYBUS_SPI=y
CONFIG_GREYBUS_UART=y
CONFIG_GREYBUS_USB=y
# CONFIG_DRM_VBOXVIDEO is not set
CONFIG_PI433=y

#
# Gasket devices
#
CONFIG_STAGING_GASKET_FRAMEWORK=y
CONFIG_STAGING_APEX_DRIVER=y
CONFIG_XIL_AXIS_FIFO=y
# CONFIG_EROFS_FS is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
CONFIG_ACER_WIRELESS=y
CONFIG_ACERHDF=y
CONFIG_ALIENWARE_WMI=y
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_SMBIOS=y
CONFIG_DELL_SMBIOS_WMI=y
# CONFIG_DELL_SMBIOS_SMM is not set
CONFIG_DELL_LAPTOP=y
CONFIG_DELL_WMI=y
CONFIG_DELL_WMI_DESCRIPTOR=y
CONFIG_DELL_WMI_AIO=y
CONFIG_DELL_WMI_LED=y
CONFIG_DELL_SMO8800=y
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_GPD_POCKET_FAN is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
CONFIG_HP_WMI=y
# CONFIG_PANASONIC_LAPTOP is not set
CONFIG_SURFACE3_WMI=y
CONFIG_THINKPAD_ACPI=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
CONFIG_THINKPAD_ACPI_UNSAFE_LEDS=y
# CONFIG_THINKPAD_ACPI_VIDEO is not set
# CONFIG_THINKPAD_ACPI_HOTKEY_POLL is not set
CONFIG_SENSORS_HDAPS=y
CONFIG_INTEL_MENLOW=y
# CONFIG_ASUS_WIRELESS is not set
CONFIG_ACPI_WMI=y
CONFIG_WMI_BMOF=y
CONFIG_INTEL_WMI_THUNDERBOLT=y
CONFIG_MSI_WMI=y
CONFIG_PEAQ_WMI=y
# CONFIG_TOPSTAR_LAPTOP is not set
CONFIG_ACPI_TOSHIBA=y
CONFIG_TOSHIBA_BT_RFKILL=y
CONFIG_TOSHIBA_HAPS=y
CONFIG_TOSHIBA_WMI=y
# CONFIG_ACPI_CMPC is not set
CONFIG_INTEL_CHT_INT33FE=y
CONFIG_INTEL_INT0002_VGPIO=y
CONFIG_INTEL_HID_EVENT=y
CONFIG_INTEL_VBTN=y
# CONFIG_INTEL_IPS is not set
CONFIG_INTEL_PMC_CORE=y
CONFIG_IBM_RTL=y
# CONFIG_SAMSUNG_LAPTOP is not set
CONFIG_MXM_WMI=y
CONFIG_SAMSUNG_Q10=y
# CONFIG_APPLE_GMUX is not set
CONFIG_INTEL_RST=y
# CONFIG_INTEL_SMARTCONNECT is not set
CONFIG_PVPANIC=y
CONFIG_INTEL_PMC_IPC=y
CONFIG_INTEL_BXTWC_PMIC_TMU=y
CONFIG_SURFACE_PRO3_BUTTON=y
CONFIG_SURFACE_3_BUTTON=y
CONFIG_INTEL_PUNIT_IPC=y
CONFIG_INTEL_TELEMETRY=y
CONFIG_MLX_PLATFORM=y
# CONFIG_INTEL_TURBO_MAX_3 is not set
CONFIG_INTEL_CHTDC_TI_PWRBTN=y
CONFIG_I2C_MULTI_INSTANTIATE=y
CONFIG_PMC_ATOM=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=y
CONFIG_CHROMEOS_PSTORE=y
CONFIG_CHROMEOS_TBMC=y
CONFIG_CROS_EC_CTL=y
# CONFIG_CROS_EC_I2C is not set
CONFIG_CROS_EC_SPI=y
CONFIG_CROS_EC_LPC=y
# CONFIG_CROS_EC_LPC_MEC is not set
CONFIG_CROS_EC_PROTO=y
CONFIG_CROS_KBD_LED_BACKLIGHT=y
# CONFIG_MELLANOX_PLATFORM is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_WM831X=y
# CONFIG_CLK_HSDK is not set
CONFIG_COMMON_CLK_MAX77686=y
CONFIG_COMMON_CLK_MAX9485=y
CONFIG_COMMON_CLK_RK808=y
CONFIG_COMMON_CLK_SI5351=y
CONFIG_COMMON_CLK_SI514=y
# CONFIG_COMMON_CLK_SI544 is not set
CONFIG_COMMON_CLK_SI570=y
# CONFIG_COMMON_CLK_CDCE706 is not set
CONFIG_COMMON_CLK_CDCE925=y
CONFIG_COMMON_CLK_CS2000_CP=y
# CONFIG_CLK_TWL6040 is not set
CONFIG_COMMON_CLK_PALMAS=y
CONFIG_COMMON_CLK_PWM=y
CONFIG_COMMON_CLK_VC5=y
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
# CONFIG_PLATFORM_MHU is not set
CONFIG_PCC=y
# CONFIG_ALTERA_MBOX is not set
CONFIG_MAILBOX_TEST=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_IOMMU_DEBUGFS is not set
# CONFIG_IOMMU_DEFAULT_PASSTHROUGH is not set
CONFIG_IOMMU_IOVA=y
CONFIG_OF_IOMMU=y
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_V2=y
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_SVM is not set
CONFIG_INTEL_IOMMU_DEFAULT_ON=y
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
# CONFIG_IRQ_REMAP is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#
CONFIG_RPMSG=y
# CONFIG_RPMSG_CHAR is not set
CONFIG_RPMSG_QCOM_GLINK_NATIVE=y
CONFIG_RPMSG_QCOM_GLINK_RPM=y
CONFIG_RPMSG_VIRTIO=y
# CONFIG_SOUNDWIRE is not set

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
# NXP/Freescale QorIQ SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
# CONFIG_SOC_TI is not set

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
CONFIG_DEVFREQ_GOV_USERSPACE=y
CONFIG_DEVFREQ_GOV_PASSIVE=y

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
# CONFIG_EXTCON_GPIO is not set
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_MAX14577 is not set
# CONFIG_EXTCON_MAX3355 is not set
CONFIG_EXTCON_MAX77843=y
CONFIG_EXTCON_PALMAS=y
CONFIG_EXTCON_RT8973A=y
CONFIG_EXTCON_SM5502=y
# CONFIG_EXTCON_USB_GPIO is not set
CONFIG_EXTCON_USBC_CROS_EC=y
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
# CONFIG_IIO_SW_DEVICE is not set
# CONFIG_IIO_SW_TRIGGER is not set
CONFIG_IIO_TRIGGERED_EVENT=y

#
# Accelerometers
#
CONFIG_ADIS16201=y
CONFIG_ADIS16209=y
CONFIG_BMA180=y
CONFIG_BMA220=y
# CONFIG_BMC150_ACCEL is not set
CONFIG_DA280=y
CONFIG_DA311=y
CONFIG_DMARD06=y
CONFIG_DMARD09=y
# CONFIG_DMARD10 is not set
CONFIG_IIO_CROS_EC_ACCEL_LEGACY=y
CONFIG_KXSD9=y
CONFIG_KXSD9_SPI=y
# CONFIG_KXSD9_I2C is not set
CONFIG_KXCJK1013=y
# CONFIG_MC3230 is not set
CONFIG_MMA7455=y
CONFIG_MMA7455_I2C=y
# CONFIG_MMA7455_SPI is not set
CONFIG_MMA7660=y
CONFIG_MMA8452=y
CONFIG_MMA9551_CORE=y
CONFIG_MMA9551=y
# CONFIG_MMA9553 is not set
CONFIG_MXC4005=y
# CONFIG_MXC6255 is not set
# CONFIG_SCA3000 is not set
CONFIG_STK8312=y
CONFIG_STK8BA50=y

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
CONFIG_AD7291=y
CONFIG_AD7298=y
# CONFIG_AD7476 is not set
CONFIG_AD7766=y
CONFIG_AD7791=y
CONFIG_AD7793=y
CONFIG_AD7887=y
CONFIG_AD7923=y
# CONFIG_AD799X is not set
CONFIG_CC10001_ADC=y
CONFIG_CPCAP_ADC=y
CONFIG_ENVELOPE_DETECTOR=y
CONFIG_HI8435=y
CONFIG_HX711=y
# CONFIG_INA2XX_ADC is not set
CONFIG_LP8788_ADC=y
CONFIG_LTC2471=y
CONFIG_LTC2485=y
# CONFIG_LTC2497 is not set
CONFIG_MAX1027=y
# CONFIG_MAX11100 is not set
CONFIG_MAX1118=y
# CONFIG_MAX1363 is not set
# CONFIG_MAX9611 is not set
CONFIG_MCP320X=y
CONFIG_MCP3422=y
# CONFIG_NAU7802 is not set
CONFIG_PALMAS_GPADC=y
CONFIG_QCOM_VADC_COMMON=y
CONFIG_QCOM_SPMI_IADC=y
CONFIG_QCOM_SPMI_VADC=y
# CONFIG_SD_ADC_MODULATOR is not set
# CONFIG_STX104 is not set
CONFIG_TI_ADC081C=y
CONFIG_TI_ADC0832=y
CONFIG_TI_ADC084S021=y
CONFIG_TI_ADC12138=y
# CONFIG_TI_ADC108S102 is not set
CONFIG_TI_ADC128S052=y
# CONFIG_TI_ADC161S626 is not set
CONFIG_TI_ADS7950=y
CONFIG_TI_ADS8688=y
# CONFIG_TI_AM335X_ADC is not set
CONFIG_TI_TLC4541=y
CONFIG_VF610_ADC=y
CONFIG_VIPERBOARD_ADC=y

#
# Analog Front Ends
#
CONFIG_IIO_RESCALE=y

#
# Amplifiers
#
CONFIG_AD8366=y

#
# Chemical Sensors
#
# CONFIG_ATLAS_PH_SENSOR is not set
CONFIG_BME680=y
CONFIG_BME680_I2C=y
CONFIG_BME680_SPI=y
CONFIG_CCS811=y
CONFIG_IAQCORE=y
CONFIG_VZ89X=y
CONFIG_IIO_CROS_EC_SENSORS_CORE=y
CONFIG_IIO_CROS_EC_SENSORS=y

#
# Hid Sensor IIO Common
#
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
# CONFIG_IIO_SSP_SENSORS_COMMONS is not set
CONFIG_IIO_SSP_SENSORHUB=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Counters
#
CONFIG_104_QUAD_8=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5360=y
# CONFIG_AD5380 is not set
CONFIG_AD5421=y
# CONFIG_AD5446 is not set
CONFIG_AD5449=y
CONFIG_AD5592R_BASE=y
CONFIG_AD5592R=y
# CONFIG_AD5593R is not set
# CONFIG_AD5504 is not set
CONFIG_AD5624R_SPI=y
CONFIG_LTC2632=y
CONFIG_AD5686=y
CONFIG_AD5686_SPI=y
# CONFIG_AD5696_I2C is not set
CONFIG_AD5755=y
CONFIG_AD5758=y
# CONFIG_AD5761 is not set
CONFIG_AD5764=y
CONFIG_AD5791=y
CONFIG_AD7303=y
CONFIG_CIO_DAC=y
# CONFIG_AD8801 is not set
# CONFIG_DPOT_DAC is not set
CONFIG_DS4424=y
# CONFIG_M62332 is not set
# CONFIG_MAX517 is not set
CONFIG_MAX5821=y
CONFIG_MCP4725=y
CONFIG_MCP4922=y
CONFIG_TI_DAC082S085=y
CONFIG_TI_DAC5571=y
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
# CONFIG_AD9523 is not set

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=y

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=y
CONFIG_ADIS16130=y
# CONFIG_ADIS16136 is not set
CONFIG_ADIS16260=y
# CONFIG_ADXRS450 is not set
# CONFIG_BMG160 is not set
CONFIG_MPU3050=y
CONFIG_MPU3050_I2C=y
# CONFIG_IIO_ST_GYRO_3AXIS is not set
CONFIG_ITG3200=y

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4403=y
# CONFIG_AFE4404 is not set
CONFIG_MAX30100=y
CONFIG_MAX30102=y

#
# Humidity sensors
#
CONFIG_AM2315=y
CONFIG_DHT11=y
# CONFIG_HDC100X is not set
CONFIG_HTS221=y
CONFIG_HTS221_I2C=y
CONFIG_HTS221_SPI=y
# CONFIG_HTU21 is not set
# CONFIG_SI7005 is not set
CONFIG_SI7020=y

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
CONFIG_ADIS16480=y
# CONFIG_BMI160_I2C is not set
# CONFIG_BMI160_SPI is not set
# CONFIG_KMX61 is not set
CONFIG_INV_MPU6050_IIO=y
# CONFIG_INV_MPU6050_I2C is not set
CONFIG_INV_MPU6050_SPI=y
CONFIG_IIO_ST_LSM6DSX=y
CONFIG_IIO_ST_LSM6DSX_I2C=y
CONFIG_IIO_ST_LSM6DSX_SPI=y
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
# CONFIG_BH1750 is not set
# CONFIG_BH1780 is not set
# CONFIG_CM32181 is not set
CONFIG_CM3232=y
CONFIG_CM3323=y
CONFIG_CM3605=y
CONFIG_CM36651=y
# CONFIG_IIO_CROS_EC_LIGHT_PROX is not set
# CONFIG_GP2AP020A00F is not set
CONFIG_SENSORS_ISL29018=y
CONFIG_SENSORS_ISL29028=y
CONFIG_ISL29125=y
CONFIG_JSA1212=y
CONFIG_RPR0521=y
CONFIG_LTR501=y
CONFIG_LV0104CS=y
CONFIG_MAX44000=y
# CONFIG_OPT3001 is not set
CONFIG_PA12203001=y
# CONFIG_SI1133 is not set
# CONFIG_SI1145 is not set
# CONFIG_STK3310 is not set
CONFIG_ST_UVIS25=y
CONFIG_ST_UVIS25_I2C=y
CONFIG_ST_UVIS25_SPI=y
CONFIG_TCS3414=y
CONFIG_TCS3472=y
# CONFIG_SENSORS_TSL2563 is not set
# CONFIG_TSL2583 is not set
CONFIG_TSL2772=y
CONFIG_TSL4531=y
# CONFIG_US5182D is not set
# CONFIG_VCNL4000 is not set
# CONFIG_VEML6070 is not set
CONFIG_VL6180=y
CONFIG_ZOPT2201=y

#
# Magnetometer sensors
#
CONFIG_AK8974=y
CONFIG_AK8975=y
CONFIG_AK09911=y
CONFIG_BMC150_MAGN=y
# CONFIG_BMC150_MAGN_I2C is not set
CONFIG_BMC150_MAGN_SPI=y
# CONFIG_MAG3110 is not set
CONFIG_MMC35240=y
# CONFIG_IIO_ST_MAGN_3AXIS is not set
# CONFIG_SENSORS_HMC5843_I2C is not set
# CONFIG_SENSORS_HMC5843_SPI is not set

#
# Multiplexers
#
CONFIG_IIO_MUX=y

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Digital potentiometers
#
# CONFIG_AD5272 is not set
# CONFIG_DS1803 is not set
CONFIG_MAX5481=y
CONFIG_MAX5487=y
# CONFIG_MCP4018 is not set
CONFIG_MCP4131=y
CONFIG_MCP4531=y
# CONFIG_TPL0102 is not set

#
# Digital potentiostats
#
# CONFIG_LMP91000 is not set

#
# Pressure sensors
#
# CONFIG_ABP060MG is not set
CONFIG_BMP280=y
CONFIG_BMP280_I2C=y
CONFIG_BMP280_SPI=y
CONFIG_IIO_CROS_EC_BARO=y
CONFIG_HP03=y
CONFIG_MPL115=y
# CONFIG_MPL115_I2C is not set
CONFIG_MPL115_SPI=y
# CONFIG_MPL3115 is not set
CONFIG_MS5611=y
CONFIG_MS5611_I2C=y
# CONFIG_MS5611_SPI is not set
# CONFIG_MS5637 is not set
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_IIO_ST_PRESS_SPI=y
CONFIG_T5403=y
# CONFIG_HP206C is not set
# CONFIG_ZPA2326 is not set

#
# Lightning sensors
#
CONFIG_AS3935=y

#
# Proximity and distance sensors
#
CONFIG_ISL29501=y
CONFIG_LIDAR_LITE_V2=y
# CONFIG_RFD77402 is not set
CONFIG_SRF04=y
CONFIG_SX9500=y
CONFIG_SRF08=y

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
CONFIG_TMP007=y
CONFIG_TSYS01=y
CONFIG_TSYS02D=y
# CONFIG_NTB is not set
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
CONFIG_VME_TSI148=y
# CONFIG_VME_FAKE is not set

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=y

#
# VME Device Drivers
#
CONFIG_VME_USER=y
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_CRC=y
CONFIG_PWM_CROS_EC=y
# CONFIG_PWM_FSL_FTM is not set
CONFIG_PWM_LP3943=y
CONFIG_PWM_LPSS=y
CONFIG_PWM_LPSS_PCI=y
CONFIG_PWM_LPSS_PLATFORM=y
CONFIG_PWM_PCA9685=y

#
# IRQ chip support
#
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
# CONFIG_PHY_CPCAP_USB is not set
# CONFIG_PHY_MAPPHONE_MDM6600 is not set
CONFIG_PHY_QCOM_USB_HS=y
CONFIG_PHY_QCOM_USB_HSIC=y
CONFIG_PHY_SAMSUNG_USB2=y
# CONFIG_PHY_TUSB1210 is not set
# CONFIG_POWERCAP is not set
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
# CONFIG_ANDROID_BINDER_IPC is not set
CONFIG_LIBNVDIMM=y
CONFIG_BLK_DEV_PMEM=y
CONFIG_ND_BLK=y
# CONFIG_BTT is not set
# CONFIG_OF_PMEM is not set
CONFIG_DAX_DRIVER=y
CONFIG_DAX=y
CONFIG_NVMEM=y
# CONFIG_RAVE_SP_EEPROM is not set

#
# HW tracing support
#
CONFIG_STM=y
CONFIG_STM_DUMMY=y
CONFIG_STM_SOURCE_CONSOLE=y
CONFIG_STM_SOURCE_HEARTBEAT=y
CONFIG_STM_SOURCE_FTRACE=y
# CONFIG_INTEL_TH is not set
CONFIG_FPGA=y
CONFIG_ALTERA_PR_IP_CORE=y
# CONFIG_ALTERA_PR_IP_CORE_PLAT is not set
# CONFIG_FPGA_MGR_ALTERA_PS_SPI is not set
CONFIG_FPGA_MGR_ALTERA_CVP=y
CONFIG_FPGA_MGR_XILINX_SPI=y
CONFIG_FPGA_MGR_ICE40_SPI=y
CONFIG_FPGA_MGR_MACHXO2_SPI=y
CONFIG_FPGA_BRIDGE=y
# CONFIG_XILINX_PR_DECOUPLER is not set
CONFIG_FPGA_REGION=y
CONFIG_OF_FPGA_REGION=y
CONFIG_FPGA_DFL=y
CONFIG_FPGA_DFL_FME=y
CONFIG_FPGA_DFL_FME_MGR=y
CONFIG_FPGA_DFL_FME_BRIDGE=y
# CONFIG_FPGA_DFL_FME_REGION is not set
CONFIG_FPGA_DFL_AFU=y
CONFIG_FPGA_DFL_PCI=y
# CONFIG_FSI is not set
CONFIG_MULTIPLEXER=y

#
# Multiplexer drivers
#
CONFIG_MUX_ADG792A=y
CONFIG_MUX_ADGS1408=y
# CONFIG_MUX_GPIO is not set
# CONFIG_MUX_MMIO is not set
CONFIG_PM_OPP=y
# CONFIG_UNISYS_VISORBUS is not set
CONFIG_SIOX=y
CONFIG_SIOX_BUS_GPIO=y
# CONFIG_SLIMBUS is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_ENCRYPTION=y
CONFIG_EXT4_FS_ENCRYPTION=y
CONFIG_EXT4_DEBUG=y
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
CONFIG_BTRFS_DEBUG=y
# CONFIG_BTRFS_ASSERT is not set
CONFIG_BTRFS_FS_REF_VERIFY=y
CONFIG_NILFS2_FS=y
CONFIG_F2FS_FS=y
CONFIG_F2FS_STAT_FS=y
# CONFIG_F2FS_FS_XATTR is not set
# CONFIG_F2FS_CHECK_FS is not set
# CONFIG_F2FS_IO_TRACE is not set
CONFIG_F2FS_FAULT_INJECTION=y
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_AUTOFS_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=y
CONFIG_OVERLAY_FS_REDIRECT_DIR=y
# CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW is not set
# CONFIG_OVERLAY_FS_INDEX is not set
# CONFIG_OVERLAY_FS_XINO_AUTO is not set
CONFIG_OVERLAY_FS_METACOPY=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
# CONFIG_VFAT_FS is not set
CONFIG_FAT_DEFAULT_CODEPAGE=437
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_TMPFS_XATTR=y
# CONFIG_HUGETLBFS is not set
CONFIG_MEMFD_CREATE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
CONFIG_ADFS_FS=y
# CONFIG_ADFS_FS_RW is not set
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
# CONFIG_ECRYPT_FS_MESSAGING is not set
CONFIG_HFS_FS=y
# CONFIG_HFSPLUS_FS is not set
CONFIG_BEFS_FS=y
# CONFIG_BEFS_DEBUG is not set
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
# CONFIG_CRAMFS is not set
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
# CONFIG_SQUASHFS_DECOMP_SINGLE is not set
CONFIG_SQUASHFS_DECOMP_MULTI=y
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
CONFIG_SQUASHFS_XATTR=y
# CONFIG_SQUASHFS_ZLIB is not set
# CONFIG_SQUASHFS_LZ4 is not set
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_ZSTD is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
CONFIG_SQUASHFS_EMBEDDED=y
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=y
CONFIG_OMFS_FS=y
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
CONFIG_QNX6FS_FS=y
# CONFIG_QNX6FS_DEBUG is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_BLOCK=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_PSTORE=y
CONFIG_PSTORE_DEFLATE_COMPRESS=y
CONFIG_PSTORE_LZO_COMPRESS=y
CONFIG_PSTORE_LZ4_COMPRESS=y
CONFIG_PSTORE_LZ4HC_COMPRESS=y
# CONFIG_PSTORE_842_COMPRESS is not set
CONFIG_PSTORE_ZSTD_COMPRESS=y
CONFIG_PSTORE_COMPRESS=y
CONFIG_PSTORE_DEFLATE_COMPRESS_DEFAULT=y
# CONFIG_PSTORE_LZO_COMPRESS_DEFAULT is not set
# CONFIG_PSTORE_LZ4_COMPRESS_DEFAULT is not set
# CONFIG_PSTORE_LZ4HC_COMPRESS_DEFAULT is not set
# CONFIG_PSTORE_ZSTD_COMPRESS_DEFAULT is not set
CONFIG_PSTORE_COMPRESS_DEFAULT="deflate"
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_PMSG is not set
# CONFIG_PSTORE_FTRACE is not set
CONFIG_PSTORE_RAM=y
CONFIG_SYSV_FS=y
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFSD is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=y
# CONFIG_CIFS_STATS2 is not set
CONFIG_CIFS_ALLOW_INSECURE_LEGACY=y
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
# CONFIG_9P_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=y
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
# CONFIG_NLS_MAC_CENTEURO is not set
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
# CONFIG_PERSISTENT_KEYRINGS is not set
CONFIG_BIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEY_DH_OPERATIONS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
# CONFIG_PAGE_TABLE_ISOLATION is not set
CONFIG_INTEL_TXT=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HARDENED_USERCOPY=y
CONFIG_HARDENED_USERCOPY_FALLBACK=y
# CONFIG_HARDENED_USERCOPY_PAGESPAN is not set
CONFIG_FORTIFY_SOURCE=y
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
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
# CONFIG_CRYPTO_RSA is not set
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_AEGIS128=y
CONFIG_CRYPTO_AEGIS128L=y
CONFIG_CRYPTO_AEGIS256=y
CONFIG_CRYPTO_AEGIS128_AESNI_SSE2=y
CONFIG_CRYPTO_AEGIS128L_AESNI_SSE2=y
CONFIG_CRYPTO_AEGIS256_AESNI_SSE2=y
# CONFIG_CRYPTO_MORUS640 is not set
# CONFIG_CRYPTO_MORUS640_SSE2 is not set
CONFIG_CRYPTO_MORUS1280=y
# CONFIG_CRYPTO_MORUS1280_SSE2 is not set
# CONFIG_CRYPTO_MORUS1280_AVX2 is not set
CONFIG_CRYPTO_SEQIV=y
# CONFIG_CRYPTO_ECHAINIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CFB is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
# CONFIG_CRYPTO_LRW is not set
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA1_MB=y
CONFIG_CRYPTO_SHA256_MB=y
CONFIG_CRYPTO_SHA512_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_SHA3 is not set
# CONFIG_CRYPTO_SM3 is not set
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=y
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
CONFIG_CRYPTO_AES_X86_64=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_DES3_EDE_X86_64=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_CHACHA20=y
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
CONFIG_CRYPTO_SM4=y
# CONFIG_CRYPTO_SPECK is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y
CONFIG_CRYPTO_ZSTD=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
CONFIG_SYSTEM_EXTRA_CERTIFICATE=y
CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE=4096
CONFIG_SECONDARY_TRUSTED_KEYRING=y
# CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC64 is not set
# CONFIG_CRC4 is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_XXHASH=y
CONFIG_RANDOM32_SELFTEST=y
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=y
CONFIG_ZSTD_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
# CONFIG_XZ_DEC_POWERPC is not set
# CONFIG_XZ_DEC_IA64 is not set
CONFIG_XZ_DEC_ARM=y
# CONFIG_XZ_DEC_ARMTHUMB is not set
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DMA_DIRECT_OPS=y
CONFIG_SWIOTLB=y
CONFIG_SGL_ALLOC=y
CONFIG_IOMMU_HELPER=y
CONFIG_CHECK_SIGNATURE=y
# CONFIG_CPUMASK_OFFSTACK is not set
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_LIBFDT=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=y
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_ARCH_HAS_UACCESS_MCSAFE=y
CONFIG_STACKDEPOT=y
CONFIG_SBITMAP=y
CONFIG_PRIME_NUMBERS=y
CONFIG_STRING_SELFTEST=y

#
# Kernel hacking
#

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_CONSOLE_LOGLEVEL_QUIET=4
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
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=8192
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_STACK_VALIDATION=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
# CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT is not set
# CONFIG_PAGE_POISONING is not set
CONFIG_DEBUG_PAGE_REF=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_KASAN=y
CONFIG_KASAN_EXTRA=y
CONFIG_KASAN_OUTLINE=y
# CONFIG_KASAN_INLINE is not set
CONFIG_ARCH_HAS_KCOV=y
CONFIG_CC_HAS_SANCOV_TRACE_PC=y
CONFIG_KCOV=y
CONFIG_KCOV_INSTRUMENT_ALL=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_WQ_WATCHDOG=y
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set
# CONFIG_DEBUG_PREEMPT is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_RWSEMS=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_WW_MUTEX_SELFTEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
CONFIG_WARN_ALL_UNSEEDED_RANDOM=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_EQS_DEBUG=y
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_CPU_HOTPLUG_STATE_CONTROL=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
CONFIG_OF_RECONFIG_NOTIFIER_ERROR_INJECT=y
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
CONFIG_FAIL_MAKE_REQUEST=y
# CONFIG_FAIL_IO_TIMEOUT is not set
# CONFIG_FAIL_FUTEX is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_PREEMPTIRQ_TRACEPOINTS=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
# CONFIG_FUNCTION_GRAPH_TRACER is not set
CONFIG_TRACE_PREEMPT_TOGGLE=y
CONFIG_PREEMPTIRQ_EVENTS=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_PREEMPT_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_HWLAT_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
CONFIG_STACK_TRACER=y
CONFIG_BLK_DEV_IO_TRACE=y
# CONFIG_UPROBE_EVENTS is not set
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_HIST_TRIGGERS is not set
CONFIG_TRACEPOINT_BENCHMARK=y
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
CONFIG_TRACE_EVAL_MAP_FILE=y
CONFIG_TRACING_EVENTS_GPIO=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_RUNTIME_TESTING_MENU is not set
# CONFIG_MEMTEST is not set
CONFIG_BUG_ON_DATA_CORRUPTION=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP_CORE=y
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
CONFIG_DEBUG_ENTRY=y
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=y
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set

--=_5bd51a6f.Ln1YTaUptZFfGOcNryfmD5tQym5yFbSvZbKUZDgFYZDVmS1H--
