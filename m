Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9516B0038
	for <linux-mm@kvack.org>; Sat,  2 May 2015 19:18:42 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so126180993pab.3
        for <linux-mm@kvack.org>; Sat, 02 May 2015 16:18:41 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id gy3si13730528pbb.86.2015.05.02.16.18.40
        for <linux-mm@kvack.org>;
        Sat, 02 May 2015 16:18:40 -0700 (PDT)
Date: Sun, 3 May 2015 07:18:28 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [CONFIG_MULTIUSER] init: error.c:320: Assertion failed in
 nih_error_get: CURRENT_CONTEXT->error != NULL
Message-ID: <20150502231828.GA25301@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="tKW2IUtsqtDRztdT"
Content-Disposition: inline
In-Reply-To: <20150428004320.GA19623@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Iulia Manda <iulia.manda21@gmail.com>
Cc: fengguang.wu@intel.com, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Iulia,

FYI, there are Ubuntu init error messages when CONFIG_MULTIUSER=n.
Since it's not embedded system and hence the target user of
CONFIG_MULTIUSER=n, it might be fine..

git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit 2813893f8b197a14f1e1ddb04d99bce46817c84a
Author:     Iulia Manda <iulia.manda21@gmail.com>
AuthorDate: Wed Apr 15 16:16:41 2015 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Wed Apr 15 16:35:22 2015 -0700

    kernel: conditionally support non-root users, groups and capabilities
    
    There are a lot of embedded systems that run most or all of their
    functionality in init, running as root:root.  For these systems,
    supporting multiple users is not necessary.
    
    This patch adds a new symbol, CONFIG_MULTIUSER, that makes support for
    non-root users, non-root groups, and capabilities optional.  It is enabled
    under CONFIG_EXPERT menu.
    
    When this symbol is not defined, UID and GID are zero in any possible case
    and processes always have all capabilities.
    
    The following syscalls are compiled out: setuid, setregid, setgid,
    setreuid, setresuid, getresuid, setresgid, getresgid, setgroups,
    getgroups, setfsuid, setfsgid, capget, capset.
    
    Also, groups.c is compiled out completely.
    
    In kernel/capability.c, capable function was moved in order to avoid
    adding two ifdef blocks.
    
    This change saves about 25 KB on a defconfig build.  The most minimal
    kernels have total text sizes in the high hundreds of kB rather than
    low MB.  (The 25k goes down a bit with allnoconfig, but not that much.
    
    The kernel was booted in Qemu.  All the common functionalities work.
    Adding users/groups is not possible, failing with -ENOSYS.
    
    Bloat-o-meter output:
    add/remove: 7/87 grow/shrink: 19/397 up/down: 1675/-26325 (-24650)
    
    [akpm@linux-foundation.org: coding-style fixes]
    Signed-off-by: Iulia Manda <iulia.manda21@gmail.com>
    Reviewed-by: Josh Triplett <josh@joshtriplett.org>
    Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
    Tested-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

+----------------------------------------+------------+------------+------------+
|                                        | c79574abe2 | 2813893f8b | 64fb1d0e97 |
+----------------------------------------+------------+------------+------------+
| boot_successes                         | 114        | 0          | 1          |
| boot_failures                          | 6          | 30         | 11         |
| Unexpected_close,not_stopping_watchdog | 5          | 2          |            |
| BUG:kernel_test_crashed                | 1          |            |            |
| Assertion_failed                       | 0          | 30         | 11         |
| Out_of_memory:Kill_process             | 0          | 5          | 1          |
| backtrace:vm_mmap_pgoff                | 0          | 2          | 1          |
| backtrace:SyS_mmap_pgoff               | 0          | 2          | 1          |
| backtrace:SyS_mmap                     | 0          | 2          | 1          |
| backtrace:do_sys_open                  | 0          | 1          |            |
| backtrace:SyS_open                     | 0          | 1          |            |
+----------------------------------------+------------+------------+------------+

mountall: Event failed
[    2.283321] init: Failed to create pty - disabling logging for job
[    2.284308] init: Temporary process spawn error: No space left on device
[    2.298763] init: error.c:320: Assertion failed in nih_error_get: CURRENT_CONTEXT->error != NULL
[    2.300054] init: Caught abort, core dumped
[    2.300861] init: Error while reading from descriptor: Bad file descriptor
[    2.301510] init: mounted-tmp main process (129) terminated with status 6
mountall: Event failed
[    2.309699] init: error.c:320: Assertion failed in nih_error_get: CURRENT_CONTEXT->error != NULL
[    2.310985] init: Caught abort, core dumped
[    2.315140] pt_chown (137) used greatest stack depth: 13152 bytes left
[    2.315795] init: error.c:320: Assertion failed in nih_error_get: CURRENT_CONTEXT->error != NULL
[    2.317078] init: Caught abort, core dumped
[    2.317839] init: Error while reading from descriptor: Bad file descriptor
[    2.318457] init: Error while reading from descriptor: Bad file descriptor
[    2.319085] init: mounted-run main process (133) terminated with status 6
[    2.319979] init: container-detect pre-start process (136) terminated with status 6
mountall: Event failed
[    2.342582] init: error.c:320: Assertion failed in nih_error_get: CURRENT_CONTEXT->error != NULL
[    2.344049] init: Caught abort, core dumped
[    2.348327] init: error.c:320: Assertion failed in nih_error_get: CURRENT_CONTEXT->error != NULL
[    2.349951] init: Caught abort, core dumped
[    2.351178] init: procps (virtual-filesystems) main process (141) terminated with status 6
[    2.352579] init: upstart-udev-bridge main process (144) terminated with status 6
[    2.353511] init: upstart-udev-bridge main process ended, respawning
[    2.358992] init: error.c:320: Assertion failed in nih_error_get: CURRENT_CONTEXT->error != NULL
[    2.360680] init: Caught abort, core dumped
[    2.362180] init: udev main process (147) terminated with status 6
[    2.362983] init: udev main process ended, respawning
[    2.368861] init: error.c:320: Assertion failed in nih_error_get: CURRENT_CONTEXT->error != NULL
[    2.370628] init: Caught abort, core dumped
[    2.373263] init: Error while reading from descriptor: Bad file descriptor
[    2.374299] init: module-init-tools main process (150) terminated with status 6
[    2.385182] init: error.c:320: Assertion failed in nih_error_get: CURRENT_CONTEXT->error != NULL
[    2.386982] init: Caught abort, core dumped
[    2.394122] init: error.c:320: Assertion failed in nih_error_get: CURRENT_CONTEXT->error != NULL
[    2.395884] init: Caught abort, core dumped
[    2.397272] init: plymouth-log main process (155) terminated with status 6
[    2.398418] init: flush-early-job-log main process (158) terminated with status 6

git bisect start 8608976e2bc9c1df090e1b346c65ec1405e9d03d v4.0 --
git bisect good d613896926be608796bb80454256a07b55fe0e87  # 09:07     30+      3  Merge tag 'upstream-4.1-rc1' of git://git.infradead.org/linux-ubifs
git bisect  bad 0e212e0a720601fabda102f7998d27625f9e144a  # 09:09      0-      1  checkpatch: don't ask for asm/file.h to linux/file.h unconditionally
git bisect  bad d38df34e3f0ea1e65c7db5d33d132dc14da0009a  # 09:12      0-     16  hwmon: (ina2xx) replace ina226_avg_bits() with find_closest()
git bisect  bad 34c9a0ffc75ad25b6a60f61e27c4a4b1189b8085  # 09:14      0-      2  crypto: fix broken crypto_register_instance() module handling
git bisect good 6d50ff91d9780263160262daeb6adfdda8ddbc6c  # 09:21     30+      1  Merge tag 'locks-v4.1-1' of git://git.samba.org/jlayton/linux
git bisect good e7c82412433a8039616c7314533a0a1c025d99bf  # 09:26     30+      2  Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kernel/git/cooloney/linux-leds
git bisect  bad eea3a00264cf243a28e4331566ce67b86059339d  # 09:28      0-     10  Merge branch 'akpm' (patches from Andrew)
git bisect good 248ca1b053c82fa22427d22b33ac51a24c88a86d  # 09:31     30+      0  zsmalloc: add fullness into stat
git bisect  bad 3ea8d440a86b85c63c2bb7f73988626e682db5f0  # 09:34      0-     30  lib/vsprintf.c: eliminate duplicate hex string array
git bisect good 160a117f0864871ae1bab26554a985a1d2861afd  # 09:39     30+      3  zsmalloc: remove extra cond_resched() in __zs_compact
git bisect  bad 96831c0a6738f88f89e7012f4df0a747514af0a0  # 09:41      0-      4  kernel/resource.c: remove deprecated __check_region() and friends
git bisect good 23f40a94d860449f39f00c3350bf850d15983e63  # 09:44     30+      3  include/linux: remove empty conditionals
git bisect good c79574abe2baddf569532e7e430e4977771dd25c  # 09:47     30+      2  lib/test-hexdump.c: fix initconst confusion
git bisect  bad 2813893f8b197a14f1e1ddb04d99bce46817c84a  # 09:50      0-      4  kernel: conditionally support non-root users, groups and capabilities
# first bad commit: [2813893f8b197a14f1e1ddb04d99bce46817c84a] kernel: conditionally support non-root users, groups and capabilities
git bisect good c79574abe2baddf569532e7e430e4977771dd25c  # 09:52     90+      6  lib/test-hexdump.c: fix initconst confusion
# extra tests on HEAD of linus/master
git bisect  bad 64fb1d0e975e92e012802d371e417266d6531676  # 09:52      0-     11  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc
# extra tests on tree/branch linus/master
git bisect  bad 64887b6882de36069c18ef2d9623484d6db7cd3a  # 09:54      0-      6  Merge branch 'for-linus-4.1' of git://git.kernel.org/pub/scm/linux/kernel/git/mason/linux-btrfs
# extra tests on tree/branch linus/master
git bisect  bad 64887b6882de36069c18ef2d9623484d6db7cd3a  # 09:54      0-      6  Merge branch 'for-linus-4.1' of git://git.kernel.org/pub/scm/linux/kernel/git/mason/linux-btrfs
# extra tests on tree/branch next/master
git bisect  bad ba5ed02bec86490224b8d162ef1911869516d51e  # 09:57      0-     16  Add linux-next specific files for 20150501


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=quantal-core-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu kvm64
	-kernel $kernel
	-initrd $initrd
	-m 300
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null 
)

append=(
	hung_task_panic=1
	earlyprintk=ttyS0,115200
	rd.udev.log-priority=err
	systemd.log_target=journal
	systemd.log_level=warning
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
	drbd.minor_count=8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

Thanks,
Fengguang

--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-ivb41-35:20150502095005:x86_64-randconfig-ib0-04200039:4.0.0-05819-g2813893:16"
Content-Transfer-Encoding: quoted-printable

early console in setup code
Probing EDD (edd=3Doff to disable)... ok
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.0.0-05819-g2813893 (kbuild@lkp-ib04) (gcc ve=
rsion 4.9.2 (Debian 4.9.2-10) ) #16 SMP Sat May 2 09:48:25 CST 2015
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log_level=
=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_t=
imeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpa=
nic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtt=
y0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86=
_64-randconfig-ib0-04200039/linus:master:2813893f8b197a14f1e1ddb04d99bce468=
17c84a:bisect-linux-4/.vmlinuz-2813893f8b197a14f1e1ddb04d99bce46817c84a-201=
50502094838-25-ivb41 branch=3Dlinus/master BOOT_IMAGE=3D/kernel/x86_64-rand=
config-ib0-04200039/2813893f8b197a14f1e1ddb04d99bce46817c84a/vmlinuz-4.0.0-=
05819-g2813893 drbd.minor_count=3D8
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000012bdffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000012be0000-0x0000000012bfffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x12be0 max_arch_pfn =3D 0x400000000
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x02722000, 0x02722fff] PGTABLE
[    0.000000] BRK [0x02723000, 0x02723fff] PGTABLE
[    0.000000] BRK [0x02724000, 0x02724fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x11200000-0x113fffff]
[    0.000000]  [mem 0x11200000-0x113fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x111fffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x111fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x11400000-0x12bdffff]
[    0.000000]  [mem 0x11400000-0x129fffff] page 2M
[    0.000000]  [mem 0x12a00000-0x12bdffff] page 4k
[    0.000000] BRK [0x02725000, 0x02725fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x11525000-0x12bd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0C60 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000012BE18BD 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000012BE0B37 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000012BE0040 000AF7 (v01 BOCHS  BXPCDSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x0000000012BE0000 000040
[    0.000000] ACPI: SSDT 0x0000000012BE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000012BE1805 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000012BE1885 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] cma: dma_contiguous_reserve(limit 12be0000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:12bdf001, primary cpu clock
[    0.000000] clocksource kvm-clock: mask: 0xffffffffffffffff max_cycles: =
0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000000001000-0x0000000012bdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000012bdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000012bdf=
fff]
[    0.000000] On node 0 totalpages: 76670
[    0.000000]   DMA32 zone: 1050 pages used for memmap
[    0.000000]   DMA32 zone: 21 pages reserved
[    0.000000]   DMA32 zone: 76670 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] e820: [mem 0x12c00000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource refined-jiffies: mask: 0xffffffff max_cycles: 0x=
ffffffff, max_idle_ns: 19112604462750000 ns
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff880011200000 s79232 r0 d3=
1360 u1048576
[    0.000000] pcpu-alloc: s79232 r0 d31360 u1048576 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 1=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1120cd80
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 75599
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log=
_level=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_s=
tall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oop=
s=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/k=
vm/x86_64-randconfig-ib0-04200039/linus:master:2813893f8b197a14f1e1ddb04d99=
bce46817c84a:bisect-linux-4/.vmlinuz-2813893f8b197a14f1e1ddb04d99bce46817c8=
4a-20150502094838-25-ivb41 branch=3Dlinus/master BOOT_IMAGE=3D/kernel/x86_6=
4-randconfig-ib0-04200039/2813893f8b197a14f1e1ddb04d99bce46817c84a/vmlinuz-=
4.0.0-05819-g2813893 drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] Memory: 252952K/306680K available (5105K kernel code, 958K r=
wdata, 2312K rodata, 744K init, 14544K bss, 53728K reserved, 0K cma-reserve=
d)
[    0.000000] Running RCU self tests
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D2
[    0.000000] NR_IRQS:4352 nr_irqs:440 16
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.0.0-05819-g2813893 (kbuild@lkp-ib04) (gcc ve=
rsion 4.9.2 (Debian 4.9.2-10) ) #16 SMP Sat May 2 09:48:25 CST 2015
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log_level=
=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_t=
imeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpa=
nic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtt=
y0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86=
_64-randconfig-ib0-04200039/linus:master:2813893f8b197a14f1e1ddb04d99bce468=
17c84a:bisect-linux-4/.vmlinuz-2813893f8b197a14f1e1ddb04d99bce46817c84a-201=
50502094838-25-ivb41 branch=3Dlinus/master BOOT_IMAGE=3D/kernel/x86_64-rand=
config-ib0-04200039/2813893f8b197a14f1e1ddb04d99bce46817c84a/vmlinuz-4.0.0-=
05819-g2813893 drbd.minor_count=3D8
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000012bdffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000012be0000-0x0000000012bfffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x12be0 max_arch_pfn =3D 0x400000000
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x02722000, 0x02722fff] PGTABLE
[    0.000000] BRK [0x02723000, 0x02723fff] PGTABLE
[    0.000000] BRK [0x02724000, 0x02724fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x11200000-0x113fffff]
[    0.000000]  [mem 0x11200000-0x113fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x111fffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x111fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x11400000-0x12bdffff]
[    0.000000]  [mem 0x11400000-0x129fffff] page 2M
[    0.000000]  [mem 0x12a00000-0x12bdffff] page 4k
[    0.000000] BRK [0x02725000, 0x02725fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x11525000-0x12bd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0C60 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000012BE18BD 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000012BE0B37 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000012BE0040 000AF7 (v01 BOCHS  BXPCDSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x0000000012BE0000 000040
[    0.000000] ACPI: SSDT 0x0000000012BE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000012BE1805 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000012BE1885 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] cma: dma_contiguous_reserve(limit 12be0000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:12bdf001, primary cpu clock
[    0.000000] clocksource kvm-clock: mask: 0xffffffffffffffff max_cycles: =
0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000000001000-0x0000000012bdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000012bdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000012bdf=
fff]
[    0.000000] On node 0 totalpages: 76670
[    0.000000]   DMA32 zone: 1050 pages used for memmap
[    0.000000]   DMA32 zone: 21 pages reserved
[    0.000000]   DMA32 zone: 76670 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] e820: [mem 0x12c00000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource refined-jiffies: mask: 0xffffffff max_cycles: 0x=
ffffffff, max_idle_ns: 19112604462750000 ns
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff880011200000 s79232 r0 d3=
1360 u1048576
[    0.000000] pcpu-alloc: s79232 r0 d31360 u1048576 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 1=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1120cd80
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 75599
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log=
_level=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_s=
tall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oop=
s=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/k=
vm/x86_64-randconfig-ib0-04200039/linus:master:2813893f8b197a14f1e1ddb04d99=
bce46817c84a:bisect-linux-4/.vmlinuz-2813893f8b197a14f1e1ddb04d99bce46817c8=
4a-20150502094838-25-ivb41 branch=3Dlinus/master BOOT_IMAGE=3D/kernel/x86_6=
4-randconfig-ib0-04200039/2813893f8b197a14f1e1ddb04d99bce46817c84a/vmlinuz-=
4.0.0-05819-g2813893 drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] Memory: 252952K/306680K available (5105K kernel code, 958K r=
wdata, 2312K rodata, 744K init, 14544K bss, 53728K reserved, 0K cma-reserve=
d)
[    0.000000] Running RCU self tests
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D2
[    0.000000] NR_IRQS:4352 nr_irqs:440 16
[    0.000000] console [ttyS0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8159 kB
[    0.000000]  memory used by lock dependency info: 8159 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] ODEBUG: selftest passed
[    0.000000] ODEBUG: selftest passed
[    0.000000] clocksource hpet: mask: 0xffffffff max_cycles: 0xffffffff, m=
ax_idle_ns: 19112604467 ns
[    0.000000] clocksource hpet: mask: 0xffffffff max_cycles: 0xffffffff, m=
ax_idle_ns: 19112604467 ns
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.508 MHz processor
[    0.000000] tsc: Detected 2693.508 MHz processor
[    0.020000] Calibrating delay loop (skipped) preset value..=20
[    0.020000] Calibrating delay loop (skipped) preset value.. 5387.01 Bogo=
MIPS (lpj=3D26935080)
5387.01 BogoMIPS (lpj=3D26935080)
[    0.020000] pid_max: default: 4096 minimum: 301
[    0.020000] pid_max: default: 4096 minimum: 301
[    0.020000] ACPI: Core revision 20150204
[    0.020000] ACPI: Core revision 20150204
[    0.020000] ACPI:=20
[    0.020000] ACPI: All ACPI Tables successfully acquiredAll ACPI Tables s=
uccessfully acquired

[    0.020000] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.020000] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.020000] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.020000] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.020542] Initializing cgroup subsys devices
[    0.020542] Initializing cgroup subsys devices
[    0.021285] Initializing cgroup subsys freezer
[    0.021285] Initializing cgroup subsys freezer
[    0.022342] Initializing cgroup subsys hugetlb
[    0.022342] Initializing cgroup subsys hugetlb
[    0.023482] Initializing cgroup subsys debug
[    0.023482] Initializing cgroup subsys debug
[    0.024620] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.024620] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.025942] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.025942] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.027609] Freeing SMP alternatives memory: 12K (ffffffff818eb000 - fff=
fffff818ee000)
[    0.027609] Freeing SMP alternatives memory: 12K (ffffffff818eb000 - fff=
fffff818ee000)
[    0.033123] enabled ExtINT on CPU#0
[    0.033123] enabled ExtINT on CPU#0
[    0.034961] ENABLING IO-APIC IRQs
[    0.034961] ENABLING IO-APIC IRQs
[    0.035816] init IO_APIC IRQs
[    0.035816] init IO_APIC IRQs
[    0.036612]  apic 0 pin 0 not connected
[    0.036612]  apic 0 pin 0 not connected
[    0.037570] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.037570] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.039554] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.039554] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.040032] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.040032] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.042026] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.042026] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.043988] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.043988] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.045955] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.045955] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.047924] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.047924] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.050030] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.050030] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.052009] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.052009] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.053977] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.053977] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.056018] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.056018] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.058102] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.058102] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.060027] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.060027] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.062014] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.062014] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.064011] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.064011] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.066000] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.066000] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.068013]  apic 0 pin 16 not connected
[    0.068013]  apic 0 pin 16 not connected
[    0.070004]  apic 0 pin 17 not connected
[    0.070004]  apic 0 pin 17 not connected
[    0.070966]  apic 0 pin 18 not connected
[    0.070966]  apic 0 pin 18 not connected
[    0.071923]  apic 0 pin 19 not connected
[    0.071923]  apic 0 pin 19 not connected
[    0.072907]  apic 0 pin 20 not connected
[    0.072907]  apic 0 pin 20 not connected
[    0.073857]  apic 0 pin 21 not connected
[    0.073857]  apic 0 pin 21 not connected
[    0.074812]  apic 0 pin 22 not connected
[    0.074812]  apic 0 pin 22 not connected
[    0.075793]  apic 0 pin 23 not connected
[    0.075793]  apic 0 pin 23 not connected
[    0.076894] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.076894] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.078570] Using local APIC timer interrupts.
[    0.078570] calibrating APIC timer ...
[    0.078570] Using local APIC timer interrupts.
[    0.078570] calibrating APIC timer ...
[    0.090000] ... lapic delta =3D 6250380
[    0.090000] ... lapic delta =3D 6250380
[    0.090000] ... PM-Timer delta =3D 357968
[    0.090000] ... PM-Timer delta =3D 357968
[    0.090000] ... PM-Timer result ok
[    0.090000] ... PM-Timer result ok
[    0.090000] ..... delta 6250380
[    0.090000] ..... delta 6250380
[    0.090000] ..... mult: 268451776
[    0.090000] ..... mult: 268451776
[    0.090000] ..... calibration result: 10000608
[    0.090000] ..... calibration result: 10000608
[    0.090000] ..... CPU clock speed is 2693.4845 MHz.
[    0.090000] ..... CPU clock speed is 2693.4845 MHz.
[    0.090000] ..... host bus clock speed is 1000.0608 MHz.
[    0.090000] ..... host bus clock speed is 1000.0608 MHz.
[    0.090084] smpboot: CPU0:=20
[    0.090084] smpboot: CPU0: Intel Intel Common KVM processorCommon KVM pr=
ocessor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.092987] Performance Events:=20
[    0.092987] Performance Events: unsupported Netburst CPU model 6 unsuppo=
rted Netburst CPU model 6 no PMU driver, software events only.
no PMU driver, software events only.
[    0.097885] x86: Booting SMP configuration:
[    0.097885] x86: Booting SMP configuration:
[    0.099434] .... node  #0, CPUs: =20
[    0.099434] .... node  #0, CPUs:         #1 #1
[    0.097337] kvm-clock: cpu 1, msr 0:12bdf041, secondary cpu clock
[    0.097337] masked ExtINT on CPU#1
[    0.120088] x86: Booted up 1 node, 2 CPUs
[    0.120088] x86: Booted up 1 node, 2 CPUs
[    0.120072] KVM setup async PF for cpu 1
[    0.120072] KVM setup async PF for cpu 1
[    0.120072] kvm-stealtime: cpu 1, msr 1130cd80
[    0.120072] kvm-stealtime: cpu 1, msr 1130cd80
[    0.122072] smpboot: Total of 2 processors activated (10774.03 BogoMIPS)
[    0.122072] smpboot: Total of 2 processors activated (10774.03 BogoMIPS)
[    0.123442] devtmpfs: initialized
[    0.123442] devtmpfs: initialized
[    0.130310] clocksource jiffies: mask: 0xffffffff max_cycles: 0xffffffff=
, max_idle_ns: 19112604462750000 ns
[    0.130310] clocksource jiffies: mask: 0xffffffff max_cycles: 0xffffffff=
, max_idle_ns: 19112604462750000 ns
[    0.131959] prandom: seed boundary self test passed
[    0.131959] prandom: seed boundary self test passed
[    0.131959] prandom: 100 self tests passed
[    0.131959] prandom: 100 self tests passed
[    0.132561] NET: Registered protocol family 16
[    0.132561] NET: Registered protocol family 16
[    0.160043] cpuidle: using governor ladder
[    0.160043] cpuidle: using governor ladder
[    0.190026] cpuidle: using governor menu
[    0.190026] cpuidle: using governor menu
[    0.191201] ACPI: bus type PCI registered
[    0.191201] ACPI: bus type PCI registered
[    0.192198] PCI: Using configuration type 1 for base access
[    0.192198] PCI: Using configuration type 1 for base access
[    0.230528] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.230528] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.231522] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.231522] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.233276] ACPI: Added _OSI(Module Device)
[    0.233276] ACPI: Added _OSI(Module Device)
[    0.234292] ACPI: Added _OSI(Processor Device)
[    0.234292] ACPI: Added _OSI(Processor Device)
[    0.235345] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.235345] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.236767] ACPI: Added _OSI(Processor Aggregator Device)
[    0.236767] ACPI: Added _OSI(Processor Aggregator Device)
[    0.241939] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:3)
[    0.241939] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:3)
[    0.251141] ACPI: Interpreter enabled
[    0.251141] ACPI: Interpreter enabled
[    0.252100] ACPI: (supports S0 S5)
[    0.252100] ACPI: (supports S0 S5)
[    0.252949] ACPI: Using IOAPIC for interrupt routing
[    0.252949] ACPI: Using IOAPIC for interrupt routing
[    0.254271] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.254271] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.274209] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.274209] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.275778] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.275778] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.277238] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.277238] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.280495] PCI host bridge to bus 0000:00
[    0.280495] PCI host bridge to bus 0000:00
[    0.281530] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.281530] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.282885] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.282885] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.284563] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff window]
[    0.284563] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff window]
[    0.286254] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff window]
[    0.286254] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff window]
[    0.290009] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf window]
[    0.290009] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf window]
[    0.291690] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff window]
[    0.291690] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff window]
[    0.293363] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    0.293363] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    0.295200] pci_bus 0000:00: root bus resource [mem 0x12c00000-0xfebffff=
f window]
[    0.295200] pci_bus 0000:00: root bus resource [mem 0x12c00000-0xfebffff=
f window]
[    0.297177] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.297177] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.300448] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.300448] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.302887] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.302887] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.324811] pci 0000:00:01.1: reg 0x20: [io  0xc200-0xc20f]
[    0.324811] pci 0000:00:01.1: reg 0x20: [io  0xc200-0xc20f]
[    0.333317] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.333317] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.335079] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.335079] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.336699] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.336699] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.338459] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.338459] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.340594] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.340594] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.342542] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.342542] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.344346] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.344346] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.346680] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.346680] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.353372] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.353372] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.363418] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.363418] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.400022] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.400022] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.402468] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.402468] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.413278] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.413278] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.420010] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.420010] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.453280] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.453280] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.455547] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.455547] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.463219] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.463219] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.470011] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.470011] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.506569] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.506569] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.513165] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.513165] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.520008] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.520008] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.550678] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.550678] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.558388] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.558388] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.566036] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.566036] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.596784] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.596784] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.606139] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.606139] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.613053] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.613053] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.636816] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.636816] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.642142] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.642142] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.647276] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.647276] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.670525] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.670525] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.676294] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.676294] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.682495] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.682495] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.710458] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.710458] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.715976] pci 0000:00:0a.0: reg 0x10: [io  0xc1c0-0xc1ff]
[    0.715976] pci 0000:00:0a.0: reg 0x10: [io  0xc1c0-0xc1ff]
[    0.720013] pci 0000:00:0a.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
[    0.720013] pci 0000:00:0a.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
[    0.742580] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.742580] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.745675] pci 0000:00:0b.0: reg 0x10: [mem 0xfebf8000-0xfebf800f]
[    0.745675] pci 0000:00:0b.0: reg 0x10: [mem 0xfebf8000-0xfebf800f]
[    0.761500] pci_bus 0000:00: on NUMA node 0
[    0.761500] pci_bus 0000:00: on NUMA node 0
[    0.763193] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    0.763193] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    0.764332] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    0.764332] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    0.765454] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    0.765454] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    0.766574] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    0.766574] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    0.767601] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    0.767601] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    0.769264] ACPI:=20
[    0.769264] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    0.770935] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.770935] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.771815] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.771815] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.771815] vgaarb: loaded
[    0.771815] vgaarb: loaded
[    0.771815] vgaarb: bridge control possible 0000:00:02.0
[    0.771815] vgaarb: bridge control possible 0000:00:02.0
[    0.773168] pps_core: LinuxPPS API ver. 1 registered
[    0.773168] pps_core: LinuxPPS API ver. 1 registered
[    0.774482] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.774482] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.780164] PCI: Using ACPI for IRQ routing
[    0.780164] PCI: Using ACPI for IRQ routing
[    0.780164] PCI: pci_cache_line_size set to 64 bytes
[    0.780164] PCI: pci_cache_line_size set to 64 bytes
[    0.781600] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.781600] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.783170] e820: reserve RAM buffer [mem 0x12be0000-0x13ffffff]
[    0.783170] e820: reserve RAM buffer [mem 0x12be0000-0x13ffffff]
[    0.785970] Switched to clocksource kvm-clock
[    0.785970] Switched to clocksource kvm-clock
[    0.787611] pnp: PnP ACPI init
[    0.787611] pnp: PnP ACPI init
[    0.788628] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.788628] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.788628] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.788628] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.788628] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.788628] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.788888] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.788888] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.790676] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.790676] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.793604] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.793604] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.795391] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.795391] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.797491] pnp 00:03: [dma 2]
[    0.797491] pnp 00:03: [dma 2]
[    0.798377] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.798377] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.800243] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    0.800243] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    0.802437] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.802437] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.804233] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    0.804233] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    0.806397] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.806397] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.808940] pnp: PnP ACPI: found 6 devices
[    0.808940] pnp: PnP ACPI: found 6 devices
[    0.815833] clocksource acpi_pm: mask: 0xffffff max_cycles: 0xffffff, ma=
x_idle_ns: 2085701024 ns
[    0.815833] clocksource acpi_pm: mask: 0xffffff max_cycles: 0xffffff, ma=
x_idle_ns: 2085701024 ns
[    0.818389] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.818389] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.820005] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff window]
[    0.820005] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff window]
[    0.821639] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff window]
[    0.821639] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff window]
[    0.823247] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf window]
[    0.823247] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf window]
[    0.824874] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff window]
[    0.824874] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff window]
[    0.826490] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff windo=
w]
[    0.826490] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff windo=
w]
[    0.828276] pci_bus 0000:00: resource 10 [mem 0x12c00000-0xfebfffff wind=
ow]
[    0.828276] pci_bus 0000:00: resource 10 [mem 0x12c00000-0xfebfffff wind=
ow]
[    0.830206] NET: Registered protocol family 1
[    0.830206] NET: Registered protocol family 1
[    0.831407] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.831407] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.832970] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.832970] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.834515] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.834515] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.836138] pci 0000:00:02.0: Video device with shadowed ROM
[    0.836138] pci 0000:00:02.0: Video device with shadowed ROM
[    0.837723] PCI: CLS 0 bytes, default 64
[    0.837723] PCI: CLS 0 bytes, default 64
[    0.839035] Unpacking initramfs...
[    0.839035] Unpacking initramfs...
[    1.650875] Freeing initrd memory: 23244K (ffff880011525000 - ffff880012=
bd8000)
[    1.650875] Freeing initrd memory: 23244K (ffff880011525000 - ffff880012=
bd8000)
[    1.655211] cryptomgr_test (25) used greatest stack depth: 14400 bytes l=
eft
[    1.655211] cryptomgr_test (25) used greatest stack depth: 14400 bytes l=
eft
[    1.656983] camellia-x86_64: performance on this CPU would be suboptimal=
: disabling camellia-x86_64.
[    1.656983] camellia-x86_64: performance on this CPU would be suboptimal=
: disabling camellia-x86_64.
[    1.661795] PCLMULQDQ-NI instructions are not detected.
[    1.661795] PCLMULQDQ-NI instructions are not detected.
[    1.663324] AVX or AES-NI instructions are not detected.
[    1.663324] AVX or AES-NI instructions are not detected.
[    1.664790] AVX instructions are not detected.
[    1.664790] AVX instructions are not detected.
[    1.666029] AVX instructions are not detected.
[    1.666029] AVX instructions are not detected.
[    1.667196] AVX2 instructions are not detected.
[    1.667196] AVX2 instructions are not detected.
[    1.668648] rcu-torture:--- Start of test: nreaders=3D1 nfakewriters=3D4=
 stat_interval=3D60 verbose=3D1 test_no_idle_hz=3D1 shuffle_interval=3D3 st=
utter=3D5 irqreader=3D1 fqs_duration=3D0 fqs_holdoff=3D0 fqs_stutter=3D3 te=
st_boost=3D1/0 test_boost_interval=3D7 test_boost_duration=3D4 shutdown_sec=
s=3D0 stall_cpu=3D0 stall_cpu_holdoff=3D10 n_barrier_cbs=3D0 onoff_interval=
=3D0 onoff_holdoff=3D0
[    1.668648] rcu-torture:--- Start of test: nreaders=3D1 nfakewriters=3D4=
 stat_interval=3D60 verbose=3D1 test_no_idle_hz=3D1 shuffle_interval=3D3 st=
utter=3D5 irqreader=3D1 fqs_duration=3D0 fqs_holdoff=3D0 fqs_stutter=3D3 te=
st_boost=3D1/0 test_boost_interval=3D7 test_boost_duration=3D4 shutdown_sec=
s=3D0 stall_cpu=3D0 stall_cpu_holdoff=3D10 n_barrier_cbs=3D0 onoff_interval=
=3D0 onoff_holdoff=3D0
[    1.677646] rcu-torture: Creating rcu_torture_writer task
[    1.677646] rcu-torture: Creating rcu_torture_writer task
[    1.679057] rcu-torture: Creating rcu_torture_fakewriter task
[    1.679057] rcu-torture: Creating rcu_torture_fakewriter task
[    1.680541] rcu-torture: rcu_torture_writer task started
[    1.680541] rcu-torture: rcu_torture_writer task started
[    1.681816] rcu-torture: Grace periods expedited from boot/sysfs for rcu,
[    1.681816] rcu-torture: Grace periods expedited from boot/sysfs for rcu,
[    1.683430] rcu-torture: Testing of dynamic grace-period expediting diab=
led.
[    1.683430] rcu-torture: Testing of dynamic grace-period expediting diab=
led.
[    1.685159] rcu-torture: Creating rcu_torture_fakewriter task
[    1.685159] rcu-torture: Creating rcu_torture_fakewriter task
[    1.685172] rcu-torture: rcu_torture_fakewriter task started
[    1.685172] rcu-torture: rcu_torture_fakewriter task started
[    1.688781] rcu-torture: Creating rcu_torture_fakewriter task
[    1.688781] rcu-torture: Creating rcu_torture_fakewriter task
[    1.690222] rcu-torture: rcu_torture_fakewriter task started
[    1.690222] rcu-torture: rcu_torture_fakewriter task started
[    1.691651] rcu-torture: Creating rcu_torture_fakewriter task
[    1.691651] rcu-torture: Creating rcu_torture_fakewriter task
[    1.691663] rcu-torture: rcu_torture_fakewriter task started
[    1.691663] rcu-torture: rcu_torture_fakewriter task started
[    1.694463] rcu-torture: Creating rcu_torture_reader task
[    1.694463] rcu-torture: Creating rcu_torture_reader task
[    1.695747] rcu-torture: rcu_torture_fakewriter task started
[    1.695747] rcu-torture: rcu_torture_fakewriter task started
[    1.697179] rcu-torture: Creating rcu_torture_stats task
[    1.697179] rcu-torture: Creating rcu_torture_stats task
[    1.698658] rcu-torture: rcu_torture_reader task started
[    1.698658] rcu-torture: rcu_torture_reader task started
[    1.698679] rcu-torture: Creating torture_shuffle task
[    1.698679] rcu-torture: Creating torture_shuffle task
[    1.698689] rcu-torture: rcu_torture_stats task started
[    1.698689] rcu-torture: rcu_torture_stats task started
[    1.702713] rcu-torture: Creating torture_stutter task
[    1.702713] rcu-torture: Creating torture_stutter task
[    1.703954] rcu-torture: torture_shuffle task started
[    1.703954] rcu-torture: torture_shuffle task started
[    1.705164] rcu-torture: Creating rcu_torture_cbflood task
[    1.705164] rcu-torture: Creating rcu_torture_cbflood task
[    1.706461] rcu-torture: torture_stutter task started
[    1.706461] rcu-torture: torture_stutter task started
[    1.709917] futex hash table entries: 16 (order: -1, 2048 bytes)
[    1.709917] futex hash table entries: 16 (order: -1, 2048 bytes)
[    1.711449] Initialise system trusted keyring
[    1.711449] Initialise system trusted keyring
[    1.713232] rcu-torture: rcu_torture_cbflood task started
[    1.713232] rcu-torture: rcu_torture_cbflood task started
[    1.714590] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.714590] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.716170] page_owner is disabled
[    1.716170] page_owner is disabled
[    1.718130] VFS: Disk quotas dquot_6.5.2
[    1.718130] VFS: Disk quotas dquot_6.5.2
[    1.719131] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 byte=
s)
[    1.719131] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 byte=
s)
[    1.722799] fuse init (API version 7.23)
[    1.722799] fuse init (API version 7.23)
[    1.733487] Key type asymmetric registered
[    1.733487] Key type asymmetric registered
[    1.734518] Asymmetric key parser 'x509' registered
[    1.734518] Asymmetric key parser 'x509' registered
[    1.736458] test_string_helpers: Running tests...
[    1.736458] test_string_helpers: Running tests...
[    1.737887] test_hexdump: Running tests...
[    1.737887] test_hexdump: Running tests...
[    1.740177] crc32: CRC_LE_BITS =3D 64, CRC_BE BITS =3D 64
[    1.740177] crc32: CRC_LE_BITS =3D 64, CRC_BE BITS =3D 64
[    1.741416] crc32: self tests passed, processed 225944 bytes in 160083 n=
sec
[    1.741416] crc32: self tests passed, processed 225944 bytes in 160083 n=
sec
[    1.743200] crc32c: CRC_LE_BITS =3D 64
[    1.743200] crc32c: CRC_LE_BITS =3D 64
[    1.744064] crc32c: self tests passed, processed 225944 bytes in 82203 n=
sec
[    1.744064] crc32c: self tests passed, processed 225944 bytes in 82203 n=
sec
[    1.762559] crc32_combine: 8373 self tests passed
[    1.762559] crc32_combine: 8373 self tests passed
[    1.778015] crc32c_combine: 8373 self tests passed
[    1.778015] crc32c_combine: 8373 self tests passed
[    1.779501] xz_dec_test: module loaded
[    1.779501] xz_dec_test: module loaded
[    1.780351] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
250 0' and write .xz files to it.
[    1.780351] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
250 0' and write .xz files to it.
[    1.783059] no IO addresses supplied
[    1.783059] no IO addresses supplied
[    1.784047] hgafb: HGA card not detected.
[    1.784047] hgafb: HGA card not detected.
[    1.784958] hgafb: probe of hgafb.0 failed with error -22
[    1.784958] hgafb: probe of hgafb.0 failed with error -22
[    1.786670] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    1.786670] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    1.788333] ACPI: Power Button [PWRF]
[    1.788333] ACPI: Power Button [PWRF]
[    1.870284] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.870284] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.897183] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    1.897183] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    1.901867] lp: driver loaded but no devices found
[    1.901867] lp: driver loaded but no devices found
[    1.903161] Non-volatile memory driver v1.3
[    1.903161] Non-volatile memory driver v1.3
[    1.904194] ppdev: user-space parallel port driver
[    1.904194] ppdev: user-space parallel port driver
[    1.905341] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    1.905341] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    1.906552] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    1.906552] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    1.909452] [drm] Initialized drm 1.1.0 20060810
[    1.909452] [drm] Initialized drm 1.1.0 20060810
[    1.910676] parport_pc 00:04: reported by Plug and Play ACPI
[    1.910676] parport_pc 00:04: reported by Plug and Play ACPI
[    1.912161] parport0: PC-style at 0x378
[    1.912161] parport0: PC-style at 0x378, irq 7, irq 7 [ [PCSPPPCSPP,TRIS=
TATE,TRISTATE]
]
[    1.991479] lp0: using parport0 (interrupt-driven).
[    1.991479] lp0: using parport0 (interrupt-driven).
[    1.994822] dummy-irq: no IRQ given.  Use irq=3DN
[    1.994822] dummy-irq: no IRQ given.  Use irq=3DN
[    1.997685] HSI/SSI char device loaded
[    1.997685] HSI/SSI char device loaded
[    1.999763] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    1.999763] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    2.003297] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.003297] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.004679] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.004679] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.006090] parport0: cannot grant exclusive access for device parkbd
[    2.006090] parport0: cannot grant exclusive access for device parkbd
[    2.017832] mousedev: PS/2 mouse device common for all mice
[    2.017832] mousedev: PS/2 mouse device common for all mice
[    2.021747] mk712: device not present
[    2.021747] mk712: device not present
[    2.023295] i2c-parport: adapter type unspecified
[    2.023295] i2c-parport: adapter type unspecified
[    2.024454] i2c-parport-light: adapter type unspecified
[    2.024454] i2c-parport-light: adapter type unspecified
[    2.027000] pps_parport: parallel port PPS client
[    2.027000] pps_parport: parallel port PPS client
[    2.028165] parport0: cannot grant exclusive access for device pps_parpo=
rt
[    2.028165] parport0: cannot grant exclusive access for device pps_parpo=
rt
[    2.029815] pps_parport: couldn't register with parport0
[    2.029815] pps_parport: couldn't register with parport0
[    2.031111] Driver for 1-wire Dallas network protocol.
[    2.031111] Driver for 1-wire Dallas network protocol.
[    2.032524] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    2.032524] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    2.034319] power_supply test_ac: uevent
[    2.034319] power_supply test_ac: uevent
[    2.035287] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[    2.035287] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[    2.036751] power_supply test_ac: prop ONLINE=3D1
[    2.036751] power_supply test_ac: prop ONLINE=3D1
[    2.037832] power_supply test_ac: power_supply_changed
[    2.037832] power_supply test_ac: power_supply_changed
[    2.039281] power_supply test_battery: uevent
[    2.039281] power_supply test_battery: uevent
[    2.040347] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[    2.040347] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[    2.041889] power_supply test_battery: prop STATUS=3DDischarging
[    2.041889] power_supply test_battery: prop STATUS=3DDischarging
[    2.043256] power_supply test_battery: prop CHARGE_TYPE=3DFast
[    2.043256] power_supply test_battery: prop CHARGE_TYPE=3DFast
[    2.044579] power_supply test_battery: prop HEALTH=3DGood
[    2.044579] power_supply test_battery: prop HEALTH=3DGood
[    2.045842] power_supply test_battery: prop PRESENT=3D1
[    2.045842] power_supply test_battery: prop PRESENT=3D1
[    2.047088] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[    2.047088] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[    2.048430] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[    2.048430] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[    2.049899] power_supply test_battery: prop CHARGE_FULL=3D100
[    2.049899] power_supply test_battery: prop CHARGE_FULL=3D100
[    2.051212] power_supply test_battery: prop CHARGE_NOW=3D50
[    2.051212] power_supply test_battery: prop CHARGE_NOW=3D50
[    2.052550] power_supply test_battery: prop CAPACITY=3D50
[    2.052550] power_supply test_battery: prop CAPACITY=3D50
[    2.053775] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[    2.053775] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[    2.055285] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[    2.055285] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[    2.056802] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[    2.056802] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[    2.058274] power_supply test_battery: prop MODEL_NAME=3DTest battery
[    2.058274] power_supply test_battery: prop MODEL_NAME=3DTest battery
[    2.059742] power_supply test_battery: prop MANUFACTURER=3DLinux
[    2.059742] power_supply test_battery: prop MANUFACTURER=3DLinux
[    2.061154] power_supply test_battery: prop SERIAL_NUMBER=3D4.0.0-05819-=
g2813893
[    2.061154] power_supply test_battery: prop SERIAL_NUMBER=3D4.0.0-05819-=
g2813893
[    2.062870] power_supply test_battery: prop TEMP=3D26
[    2.062870] power_supply test_battery: prop TEMP=3D26
[    2.063995] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[    2.063995] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[    2.065610] power_supply test_battery: power_supply_changed
[    2.065610] power_supply test_battery: power_supply_changed
[    2.067099] power_supply test_usb: uevent
[    2.067099] power_supply test_usb: uevent
[    2.068018] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[    2.068018] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[    2.069452] power_supply test_usb: prop ONLINE=3D1
[    2.069452] power_supply test_usb: prop ONLINE=3D1
[    2.070558] power_supply test_usb: power_supply_changed
[    2.070558] power_supply test_usb: power_supply_changed
[    2.076084] intel_powerclamp: Intel powerclamp does not run on family 15=
 model 6
[    2.076084] intel_powerclamp: Intel powerclamp does not run on family 15=
 model 6
[    2.077466] acquirewdt: WDT driver for Acquire single board computer ini=
tialising
[    2.077466] acquirewdt: WDT driver for Acquire single board computer ini=
tialising
[    2.078765] acquirewdt: I/O address 0x0043 already in use
[    2.078765] acquirewdt: I/O address 0x0043 already in use
[    2.079643] acquirewdt: probe of acquirewdt failed with error -5
[    2.079643] acquirewdt: probe of acquirewdt failed with error -5
[    2.080663] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[    2.080663] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[    2.082680] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    2.082680] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    2.087162] power_supply test_ac: power_supply_changed_work
[    2.087162] power_supply test_ac: power_supply_changed_work
[    2.088531] power_supply test_ac: uevent
[    2.088531] power_supply test_ac: uevent
[    2.089158] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[    2.089158] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[    2.090072] power_supply test_ac: prop ONLINE=3D1
[    2.090072] power_supply test_ac: prop ONLINE=3D1
[    2.090818] power_supply test_battery: power_supply_changed_work
[    2.090818] power_supply test_battery: power_supply_changed_work
[    2.091819] power_supply test_battery: uevent
[    2.091819] power_supply test_battery: uevent
[    2.092527] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[    2.092527] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[    2.093576] power_supply test_battery: prop STATUS=3DDischarging
[    2.093576] power_supply test_battery: prop STATUS=3DDischarging
[    2.094545] power_supply test_battery: prop CHARGE_TYPE=3DFast
[    2.094545] power_supply test_battery: prop CHARGE_TYPE=3DFast
[    2.095448] power_supply test_battery: prop HEALTH=3DGood
[    2.095448] power_supply test_battery: prop HEALTH=3DGood
[    2.096276] power_supply test_battery: prop PRESENT=3D1
[    2.096276] power_supply test_battery: prop PRESENT=3D1
[    2.097091] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[    2.097091] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[    2.098004] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[    2.098004] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[    2.098985] power_supply test_battery: prop CHARGE_FULL=3D100
[    2.098985] power_supply test_battery: prop CHARGE_FULL=3D100
[    2.099870] power_supply test_battery: prop CHARGE_NOW=3D50
[    2.099870] power_supply test_battery: prop CHARGE_NOW=3D50
[    2.100740] power_supply test_battery: prop CAPACITY=3D50
[    2.100740] power_supply test_battery: prop CAPACITY=3D50
[    2.101576] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[    2.101576] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[    2.102545] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[    2.102545] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[    2.103530] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[    2.103530] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[    2.104544] power_supply test_battery: prop MODEL_NAME=3DTest battery
[    2.104544] power_supply test_battery: prop MODEL_NAME=3DTest battery
[    2.105545] power_supply test_battery: prop MANUFACTURER=3DLinux
[    2.105545] power_supply test_battery: prop MANUFACTURER=3DLinux
[    2.106476] power_supply test_battery: prop SERIAL_NUMBER=3D4.0.0-05819-=
g2813893
[    2.106476] power_supply test_battery: prop SERIAL_NUMBER=3D4.0.0-05819-=
g2813893
[    2.107622] power_supply test_battery: prop TEMP=3D26
[    2.107622] power_supply test_battery: prop TEMP=3D26
[    2.108395] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[    2.108395] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[    2.109306] power_supply test_usb: power_supply_changed_work
[    2.109306] power_supply test_usb: power_supply_changed_work
[    2.110223] power_supply test_usb: uevent
[    2.110223] power_supply test_usb: uevent
[    2.110868] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[    2.110868] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[    2.111783] power_supply test_usb: prop ONLINE=3D1
[    2.111783] power_supply test_usb: prop ONLINE=3D1
[    2.112573] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)
[    2.112573] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)
[    2.113636] wafer5823wdt: WDT driver for Wafer 5823 single board compute=
r initialising
[    2.113636] wafer5823wdt: WDT driver for Wafer 5823 single board compute=
r initialising
[    2.114914] wafer5823wdt: I/O address 0x0443 already in use
[    2.114914] wafer5823wdt: I/O address 0x0443 already in use
[    2.115848] it87_wdt: no device
[    2.115848] it87_wdt: no device
[    2.116347] sc1200wdt: build 20020303
[    2.116347] sc1200wdt: build 20020303
[    2.116965] sc1200wdt: io parameter must be specified
[    2.116965] sc1200wdt: io parameter must be specified
[    2.117798] pc87413_wdt: Version 1.1 at io 0x2E
[    2.117798] pc87413_wdt: Version 1.1 at io 0x2E
[    2.118522] pc87413_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    2.118522] pc87413_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    2.119565] sbc60xxwdt: I/O address 0x0443 already in use
[    2.119565] sbc60xxwdt: I/O address 0x0443 already in use
[    2.120444] cpu5wdt: misc_register failed
[    2.120444] cpu5wdt: misc_register failed
[    2.121115] w83977f_wdt: driver v1.00
[    2.121115] w83977f_wdt: driver v1.00
[    2.121698] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    2.121698] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    2.122745] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    2.122745] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    2.123709] machzwd: no ZF-Logic found
[    2.123709] machzwd: no ZF-Logic found
[    2.124303] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[    2.124303] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[    2.125557] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    2.125557] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    2.126834] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    2.126834] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    2.128687] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[    2.128687] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[    2.131897] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    2.131897] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    2.137881]  fake-fmc-carrier: mezzanine 0
[    2.137881]  fake-fmc-carrier: mezzanine 0
[    2.138991]       Manufacturer: fake-vendor
[    2.138991]       Manufacturer: fake-vendor
[    2.140115]       Product name: fake-design-for-testing
[    2.140115]       Product name: fake-design-for-testing
[    2.141638] fmc fake-design-for-testing-f001: Driver has no ID: matches =
all
[    2.141638] fmc fake-design-for-testing-f001: Driver has no ID: matches =
all
[    2.143566] fmc_trivial: probe of fake-design-for-testing-f001 failed wi=
th error -95
[    2.143566] fmc_trivial: probe of fake-design-for-testing-f001 failed wi=
th error -95
[    2.145489] fmc fake-design-for-testing-f001: Driver has no ID: matches =
all
[    2.145489] fmc fake-design-for-testing-f001: Driver has no ID: matches =
all
[    2.147840] fmc_chardev fake-design-for-testing-f001: Created misc devic=
e "fake-design-for-testing-f001"
[    2.147840] fmc_chardev fake-design-for-testing-f001: Created misc devic=
e "fake-design-for-testing-f001"
[    2.150044] ... APIC ID:      00000000 (0)
[    2.150044] ... APIC ID:      00000000 (0)
[    2.151781] ... APIC VERSION: 01050014
[    2.151781] ... APIC VERSION: 01050014
[    2.152861] 00000000
[    2.152861] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    2.154302] 00000000
[    2.154302] 000000000e2000000e200000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    2.155560] 00000000
[    2.155560] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    2.156812]=20
[    2.156812]=20
[    2.157059] number of MP IRQ sources: 15.
[    2.157059] number of MP IRQ sources: 15.
[    2.157738] number of IO-APIC #0 registers: 24.
[    2.157738] number of IO-APIC #0 registers: 24.
[    2.158451] testing the IO APIC.......................
[    2.158451] testing the IO APIC.......................
[    2.159261] IO APIC #0......
[    2.159261] IO APIC #0......
[    2.159726] .... register #00: 00000000
[    2.159726] .... register #00: 00000000
[    2.160347] .......    : physical APIC id: 00
[    2.160347] .......    : physical APIC id: 00
[    2.161101] .......    : Delivery Type: 0
[    2.161101] .......    : Delivery Type: 0
[    2.162021] .......    : LTS          : 0
[    2.162021] .......    : LTS          : 0
[    2.163069] .... register #01: 00170011
[    2.163069] .... register #01: 00170011
[    2.163964] .......     : max redirection entries: 17
[    2.163964] .......     : max redirection entries: 17
[    2.165061] .......     : PRQ implemented: 0
[    2.165061] .......     : PRQ implemented: 0
[    2.165994] .......     : IO APIC version: 11
[    2.165994] .......     : IO APIC version: 11
[    2.166942] .... register #02: 00000000
[    2.166942] .... register #02: 00000000
[    2.167776] .......     : arbitration: 00
[    2.167776] .......     : arbitration: 00
[    2.168649] .... IRQ redirection table:
[    2.168649] .... IRQ redirection table:
[    2.169496] 1    0    0   0   0    0    0    00
[    2.169496] 1    0    0   0   0    0    0    00
[    2.170502] 0    0    0   0   0    1    1    31
[    2.170502] 0    0    0   0   0    1    1    31
[    2.171503] 0    0    0   0   0    1    1    30
[    2.171503] 0    0    0   0   0    1    1    30
[    2.172497] 0    0    0   0   0    1    1    33
[    2.172497] 0    0    0   0   0    1    1    33
[    2.173492] 1    0    0   0   0    1    1    34
[    2.173492] 1    0    0   0   0    1    1    34
[    2.174483] 1    1    0   0   0    1    1    35
[    2.174483] 1    1    0   0   0    1    1    35
[    2.175475] 0    0    0   0   0    1    1    36
[    2.175475] 0    0    0   0   0    1    1    36
[    2.176472] 0    0    0   0   0    1    1    37
[    2.176472] 0    0    0   0   0    1    1    37
[    2.177468] 0    0    0   0   0    1    1    38
[    2.177468] 0    0    0   0   0    1    1    38
[    2.178457] 0    1    0   0   0    1    1    39
[    2.178457] 0    1    0   0   0    1    1    39
[    2.179448] 1    1    0   0   0    1    1    3A
[    2.179448] 1    1    0   0   0    1    1    3A
[    2.180456] 1    1    0   0   0    1    1    3B
[    2.180456] 1    1    0   0   0    1    1    3B
[    2.181456] 0    0    0   0   0    1    1    3C
[    2.181456] 0    0    0   0   0    1    1    3C
[    2.182453] 0    0    0   0   0    1    1    3D
[    2.182453] 0    0    0   0   0    1    1    3D
[    2.183450] 0    0    0   0   0    1    1    3E
[    2.183450] 0    0    0   0   0    1    1    3E
[    2.184272] 0    0    0   0   0    1    1    3F
[    2.184272] 0    0    0   0   0    1    1    3F
[    2.184994] 1    0    0   0   0    0    0    00
[    2.184994] 1    0    0   0   0    0    0    00
[    2.185712] 1    0    0   0   0    0    0    00
[    2.185712] 1    0    0   0   0    0    0    00
[    2.186434] 1    0    0   0   0    0    0    00
[    2.186434] 1    0    0   0   0    0    0    00
[    2.187204] 1    0    0   0   0    0    0    00
[    2.187204] 1    0    0   0   0    0    0    00
[    2.188119] 1    0    0   0   0    0    0    00
[    2.188119] 1    0    0   0   0    0    0    00
[    2.188843] 1    0    0   0   0    0    0    00
[    2.188843] 1    0    0   0   0    0    0    00
[    2.189564] 1    0    0   0   0    0    0    00
[    2.189564] 1    0    0   0   0    0    0    00
[    2.190291] 1    0    0   0   0    0    0    00
[    2.190291] 1    0    0   0   0    0    0    00
[    2.191010] IRQ to pin mappings:
[    2.191010] IRQ to pin mappings:
[    2.191527] IRQ0=20
[    2.191527] IRQ0 -> 0:2-> 0:2

[    2.191942] IRQ1=20
[    2.191942] IRQ1 -> 0:1-> 0:1

[    2.192386] IRQ3=20
[    2.192386] IRQ3 -> 0:3-> 0:3

[    2.192838] IRQ4=20
[    2.192838] IRQ4 -> 0:4-> 0:4

[    2.193252] IRQ5=20
[    2.193252] IRQ5 -> 0:5-> 0:5

[    2.193700] IRQ6=20
[    2.193700] IRQ6 -> 0:6-> 0:6

[    2.194115] IRQ7=20
[    2.194115] IRQ7 -> 0:7-> 0:7

[    2.194536] IRQ8=20
[    2.194536] IRQ8 -> 0:8-> 0:8

[    2.194950] IRQ9=20
[    2.194950] IRQ9 -> 0:9-> 0:9

[    2.195362] IRQ10=20
[    2.195362] IRQ10 -> 0:10-> 0:10

[    2.195815] IRQ11=20
[    2.195815] IRQ11 -> 0:11-> 0:11

[    2.196254] IRQ12=20
[    2.196254] IRQ12 -> 0:12-> 0:12

[    2.196701] IRQ13=20
[    2.196701] IRQ13 -> 0:13-> 0:13

[    2.197139] IRQ14=20
[    2.197139] IRQ14 -> 0:14-> 0:14

[    2.197584] IRQ15=20
[    2.197584] IRQ15 -> 0:15-> 0:15

[    2.198025] .................................... done.
[    2.198025] .................................... done.
[    2.201457] bootconsole [earlyser0] disabled
[    2.201457] bootconsole [earlyser0] disabled
[    2.202433] Loading compiled-in X.509 certificates
[    2.203818] BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
[    2.205806] Freeing unused kernel memory: 744K (ffffffff81831000 - fffff=
fff818eb000)
[    2.212428] random: init urandom read with 3 bits of entropy available
[    2.219710] hostname (100) used greatest stack depth: 13840 bytes left
[    2.225202] hwclock (103) used greatest stack depth: 13760 bytes left
[    2.232140] plymouthd (105) used greatest stack depth: 13440 bytes left
[    2.244980] mountall (109) used greatest stack depth: 13184 bytes left
mountall: Event failed
[    2.283321] init: Failed to create pty - disabling logging for job
[    2.284308] init: Temporary process spawn error: No space left on device
[    2.298763] init: error.c:320: Assertion failed in nih_error_get: CURREN=
T_CONTEXT->error !=3D NULL
[    2.300054] init: Caught abort, core dumped
[    2.300861] init: Error while reading from descriptor: Bad file descript=
or
[    2.301510] init: mounted-tmp main process (129) terminated with status 6
mountall: Event failed
[    2.309699] init: error.c:320: Assertion failed in nih_error_get: CURREN=
T_CONTEXT->error !=3D NULL
[    2.310985] init: Caught abort, core dumped
[    2.315140] pt_chown (137) used greatest stack depth: 13152 bytes left
[    2.315795] init: error.c:320: Assertion failed in nih_error_get: CURREN=
T_CONTEXT->error !=3D NULL
[    2.317078] init: Caught abort, core dumped
[    2.317839] init: Error while reading from descriptor: Bad file descript=
or
[    2.318457] init: Error while reading from descriptor: Bad file descript=
or
[    2.319085] init: mounted-run main process (133) terminated with status 6
[    2.319979] init: container-detect pre-start process (136) terminated wi=
th status 6
mountall: Event failed
[    2.342582] init: error.c:320: Assertion failed in nih_error_get: CURREN=
T_CONTEXT->error !=3D NULL
[    2.344049] init: Caught abort, core dumped
[    2.348327] init: error.c:320: Assertion failed in nih_error_get: CURREN=
T_CONTEXT->error !=3D NULL
[    2.349951] init: Caught abort, core dumped
[    2.351178] init: procps (virtual-filesystems) main process (141) termin=
ated with status 6
[    2.352579] init: upstart-udev-bridge main process (144) terminated with=
 status 6
[    2.353511] init: upstart-udev-bridge main process ended, respawning
[    2.358992] init: error.c:320: Assertion failed in nih_error_get: CURREN=
T_CONTEXT->error !=3D NULL
[    2.360680] init: Caught abort, core dumped
[    2.362180] init: udev main process (147) terminated with status 6
[    2.362983] init: udev main process ended, respawning
[    2.368861] init: error.c:320: Assertion failed in nih_error_get: CURREN=
T_CONTEXT->error !=3D NULL
[    2.370628] init: Caught abort, core dumped
[    2.373263] init: Error while reading from descriptor: Bad file descript=
or
[    2.374299] init: module-init-tools main process (150) terminated with s=
tatus 6
[    2.385182] init: error.c:320: Assertion failed in nih_error_get: CURREN=
T_CONTEXT->error !=3D NULL
[    2.386982] init: Caught abort, core dumped
[    2.394122] init: error.c:320: Assertion failed in nih_error_get: CURREN=
T_CONTEXT->error !=3D NULL
[    2.395884] init: Caught abort, core dumped
[    2.397272] init: plymouth-log main process (155) terminated with status=
 6
[    2.398418] init: flush-early-job-log main process (158) terminated with=
 status 6
[    2.650207] tsc: Refined TSC clocksource calibration: 2693.503 MHz
[    2.651018] clocksource tsc: mask: 0xffffffffffffffff max_cycles: 0x26d3=
451f606, max_idle_ns: 440795333933 ns
[   12.248387] sock: process `trinity-main' is using obsolete setsockopt SO=
_BSDCOMPAT
[   19.470490] Bits 55-60 of /proc/PID/pagemap entries are about to stop be=
ing page-shift some time soon. See the linux/Documentation/vm/pagemap.txt f=
or details.
[   19.541715] mmap: trinity-c1 (175) uses deprecated remap_file_pages() sy=
scall. See Documentation/vm/remap_file_pages.txt.
[   25.066973] tty ttydc: uevent: unknown action-string
[   26.532146] tty ttyxe: uevent: unknown action-string
[   26.651839] advantechwdt: Unexpected close, not stopping watchdog!
[   28.878864] warning: process `trinity-c0' used the deprecated sysctl sys=
tem call with=20
[   52.465805] tty ptybd: uevent: unknown action-string
[   61.690034] rcu-torture: rtc: ffffffff825de8e0 ver: 572 tfle: 0 rta: 572=
 rtaf: 0 rtf: 563 rtmbe: 0 rtbke: 0 rtbre: 0 rtbf: 0 rtb: 0 nt: 2044 onoff:=
 0/0:0/0 -1,0:-1,0 0:0 (HZ=3D100) barrier: 0/0:0 cbflood: 30
[   61.692931] rcu-torture: Reader Pipe:  19105559 66 0 0 0 0 0 0 0 0 0
[   61.694172] rcu-torture: Reader Batch:  18792966 312659 0 0 0 0 0 0 0 0 0
[   61.695375] rcu-torture: Free-Block Circulation:  571 571 570 569 568 56=
7 566 565 564 563 0
[   62.274007] init: error.c:320: Assertion failed in nih_error_get: CURREN=
T_CONTEXT->error !=3D NULL
[   62.275390] init: Caught abort, core dumped
[   62.277249] init: Error while reading from descriptor: Bad file descript=
or
[   62.278581] init: hwclock-save main process (2414) terminated with statu=
s 6
[   62.281120] init: plymouth-upstart-bridge main process (2418) terminated=
 with status 1
umount: /run/lock: not mounted
 * Will now restart
[   62.536968] Unregister pv shared memory for cpu 1
[   62.537375] Unregister pv shared memory for cpu 0
[   62.537828] rcu-torture: Unscheduled system shutdown detected
[   62.539151] reboot: Restarting system
[   62.539459] reboot: machine restart
Elapsed time: 65
qemu-system-x86_64 -enable-kvm -cpu kvm64 -kernel /kernel/x86_64-randconfig=
-ib0-04200039/2813893f8b197a14f1e1ddb04d99bce46817c84a/vmlinuz-4.0.0-05819-=
g2813893 -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 rd.udev.lo=
g-priority=3Derr systemd.log_target=3Djournal systemd.log_level=3Dwarning d=
ebug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100=
 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ram=
disk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnor=
mal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randconf=
ig-ib0-04200039/linus:master:2813893f8b197a14f1e1ddb04d99bce46817c84a:bisec=
t-linux-4/.vmlinuz-2813893f8b197a14f1e1ddb04d99bce46817c84a-20150502094838-=
25-ivb41 branch=3Dlinus/master BOOT_IMAGE=3D/kernel/x86_64-randconfig-ib0-0=
4200039/2813893f8b197a14f1e1ddb04d99bce46817c84a/vmlinuz-4.0.0-05819-g28138=
93 drbd.minor_count=3D8'  -initrd /kernel-tests/initrd/quantal-core-x86_64.=
cgz -m 300 -smp 2 -device e1000,netdev=3Dnet0 -netdev user,id=3Dnet0 -boot =
order=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocaltime -drive file=
=3D/fs/vdisk/disk0-quantal-ivb41-35,media=3Ddisk,if=3Dvirtio -drive file=3D=
/fs/vdisk/disk1-quantal-ivb41-35,media=3Ddisk,if=3Dvirtio -drive file=3D/fs=
/vdisk/disk2-quantal-ivb41-35,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/vd=
isk/disk3-quantal-ivb41-35,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/vdisk=
/disk4-quantal-ivb41-35,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/vdisk/di=
sk5-quantal-ivb41-35,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/vdisk/disk6=
-quantal-ivb41-35,media=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-quan=
tal-ivb41-35 -serial file:/dev/shm/kboot/serial-quantal-ivb41-35 -daemonize=
 -display none -monitor null=20

--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.0.0-05819-g2813893"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.0.0 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
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
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

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
CONFIG_KERNEL_LZMA=y
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_LEGACY_ALLOC_HWIRQ=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
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
# CONFIG_NO_HZ_FULL is not set
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
CONFIG_SRCU=y
# CONFIG_TASKS_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_CONTEXT_TRACKING=y
CONFIG_RCU_USER_QS=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_RCU_FANOUT_EXACT=y
# CONFIG_RCU_FAST_NO_HZ is not set
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_KTHREAD_PRIO=0
# CONFIG_RCU_NOCB_CPU is not set
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
# CONFIG_PROC_PID_CPUSET is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_PAGE_COUNTER=y
# CONFIG_MEMCG is not set
CONFIG_CGROUP_HUGETLB=y
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
# CONFIG_FAIR_GROUP_SCHED is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
# CONFIG_RD_LZO is not set
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
# CONFIG_MULTIUSER is not set
# CONFIG_SGETMASK_SYSCALL is not set
CONFIG_SYSFS_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
# CONFIG_BPF_SYSCALL is not set
# CONFIG_SHMEM is not set
# CONFIG_AIO is not set
CONFIG_ADVISE_SYSCALLS=y
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
CONFIG_SYSTEM_TRUSTED_KEYRING=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_PROFILE_ALL is not set
CONFIG_GCOV_FORMAT_AUTODETECT=y
# CONFIG_GCOV_FORMAT_3_4 is not set
# CONFIG_GCOV_FORMAT_4_7 is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
# CONFIG_BLOCK is not set
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUE_RWLOCK=y
CONFIG_QUEUE_RWLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_MPPARSE is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
# CONFIG_IOSF_MBI is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=8
# CONFIG_SCHED_SMT is not set
# CONFIG_SCHED_MC is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
# CONFIG_I8K is not set
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_AMD_EARLY=y
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=0
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CLEANCACHE=y
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
CONFIG_MEM_SOFT_DIRTY=y
# CONFIG_ZPOOL is not set
# CONFIG_ZBUD is not set
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_MPX=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
CONFIG_DEBUG_HOTPLUG_CPU0=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_PM is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_PMIC_OPREGION is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_STAT_DETAILS is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
# CONFIG_COREDUMP is not set
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_PMC_ATOM=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NET_PTP_CLASSIFY is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_DNS_RESOLVER is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_HSR is not set
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
# CONFIG_BT is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPMI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_FENCE_TRACE is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
CONFIG_CMA_SIZE_SEL_MIN=y
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
CONFIG_PARPORT_PC_FIFO=y
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
# CONFIG_AD525X_DPOT_I2C is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
# CONFIG_ISL29003 is not set
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_SRAM=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
# CONFIG_GENWQE is not set
CONFIG_ECHO=y
# CONFIG_CXL_BASE is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_NETDEVICES is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
CONFIG_KEYBOARD_QT2160=y
# CONFIG_KEYBOARD_LKKBD is not set
CONFIG_KEYBOARD_GPIO=y
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
# CONFIG_KEYBOARD_MATRIX is not set
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
CONFIG_KEYBOARD_MAX7359=y
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_KEYBOARD_SUNKBD=y
# CONFIG_KEYBOARD_TWL4030 is not set
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_88PM860X=y
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP4_I2C=y
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
CONFIG_TOUCHSCREEN_FUJITSU=y
# CONFIG_TOUCHSCREEN_GOODIX is not set
# CONFIG_TOUCHSCREEN_ILI210X is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
# CONFIG_TOUCHSCREEN_ELAN is not set
# CONFIG_TOUCHSCREEN_ELO is not set
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
# CONFIG_TOUCHSCREEN_WACOM_I2C is not set
CONFIG_TOUCHSCREEN_MAX11801=y
# CONFIG_TOUCHSCREEN_MCS5000 is not set
CONFIG_TOUCHSCREEN_MMS114=y
# CONFIG_TOUCHSCREEN_MTOUCH is not set
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
CONFIG_TOUCHSCREEN_PENMOUNT=y
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WM831X=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_MC13783=y
CONFIG_TOUCHSCREEN_TOUCHIT213=y
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC2007=y
# CONFIG_TOUCHSCREEN_ST1232 is not set
CONFIG_TOUCHSCREEN_SX8654=y
CONFIG_TOUCHSCREEN_TPS6507X=y
CONFIG_TOUCHSCREEN_ZFORCE=y
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=y
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVMEM=y
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_FINTEK is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_MEN_Z135 is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=y
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_TIS_I2C_ST33 is not set
# CONFIG_TCG_CRB is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
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
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_GPIO=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_CROS_EC_TUNNEL is not set
# CONFIG_I2C_SLAVE is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_SPMI=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
CONFIG_HSI_CHAR=y

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=y
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
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_IT8761E is not set
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_LP3943 is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
# CONFIG_GPIO_PCA953X is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_RC5T583=y
CONFIG_GPIO_SX150X=y
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL4030=y
CONFIG_GPIO_WM831X=y
# CONFIG_GPIO_WM8994 is not set
# CONFIG_GPIO_ADP5520 is not set
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_INTEL_MID is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MCP23S08=y

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
# CONFIG_GPIO_PALMAS is not set
# CONFIG_GPIO_TPS65910 is not set

#
# USB GPIO expanders:
#
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2482 is not set
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
# CONFIG_GENERIC_ADC_BATTERY is not set
CONFIG_MAX8925_POWER=y
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=y
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_SBS is not set
CONFIG_BATTERY_BQ27x00=y
# CONFIG_BATTERY_BQ27X00_I2C is not set
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_CHARGER_DA9150=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_TWL4030_MADC=y
CONFIG_CHARGER_88PM860X=y
CONFIG_BATTERY_RX51=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_TWL4030=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_MAX14577=y
# CONFIG_CHARGER_BQ2415X is not set
CONFIG_CHARGER_BQ24190=y
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_SMB347=y
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
CONFIG_SENSORS_ADM1025=y
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=y
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_MC13783_ADC=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4260=y
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_MAX16065=y
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_HTU21=y
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_MENF21BMC_HWMON=y
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
# CONFIG_SENSORS_NCT6683 is not set
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_LTC2978_REGULATOR is not set
CONFIG_SENSORS_MAX16064=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_TPS40422 is not set
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=y
# CONFIG_SENSORS_ZL6100 is not set
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHTC1=y
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
# CONFIG_SENSORS_SCH5636 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP103=y
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_TWL4030_MADC=y
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
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
CONFIG_THERMAL_HWMON=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=y
# CONFIG_INT340X_THERMAL is not set

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_DA9055_WATCHDOG=y
# CONFIG_MENF21BMC_WATCHDOG is not set
CONFIG_WM831X_WATCHDOG=y
CONFIG_XILINX_WATCHDOG=y
# CONFIG_DW_WATCHDOG is not set
CONFIG_RN5T618_WATCHDOG=y
CONFIG_TWL4030_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_F71808E_WDT=y
# CONFIG_SP5100_TCO is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
# CONFIG_HP_WATCHDOG is not set
CONFIG_SC1200_WDT=y
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=y
CONFIG_CPU5_WDT=y
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
# CONFIG_W83877F_WDT is not set
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=y
CONFIG_MEN_A21_WDT=y

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
# CONFIG_BCMA_DRIVER_GPIO is not set
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_AS3711=y
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_AXP20X is not set
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
CONFIG_MFD_DA9055=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_DA9150=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
CONFIG_MFD_88PM800=y
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RT5033 is not set
CONFIG_MFD_RC5T583=y
CONFIG_MFD_RN5T618=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
# CONFIG_MFD_SKY81452 is not set
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
# CONFIG_AB3100_OTP is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
CONFIG_MFD_TPS65218=y
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
# CONFIG_MFD_TWL4030_AUDIO is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PM800=y
CONFIG_REGULATOR_88PM8607=y
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_ANATOP is not set
# CONFIG_REGULATOR_AAT2870 is not set
CONFIG_REGULATOR_AB3100=y
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_DA9055=y
# CONFIG_REGULATOR_DA9210 is not set
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_ISL9305=y
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8907 is not set
# CONFIG_REGULATOR_MAX8925 is not set
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8973=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
# CONFIG_REGULATOR_MT6397 is not set
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PFUZE100=y
# CONFIG_REGULATOR_RC5T583 is not set
CONFIG_REGULATOR_RN5T618=y
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65910=y
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TPS80031=y
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8994=y
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set

#
# Direct Rendering Manager
#
CONFIG_DRM=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
# CONFIG_FB_BIG_ENDIAN is not set
CONFIG_FB_LITTLE_ENDIAN=y
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
# CONFIG_FB_OPENCORES is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
CONFIG_FB_SM501=y
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
# CONFIG_BACKLIGHT_MAX8925 is not set
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=y
# CONFIG_BACKLIGHT_WM831X is not set
CONFIG_BACKLIGHT_ADP5520=y
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_88PM860X is not set
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_PANDORA is not set
# CONFIG_BACKLIGHT_AS3711 is not set
CONFIG_BACKLIGHT_GPIO=y
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_VGASTATE is not set
CONFIG_HDMI=y
# CONFIG_LOGO is not set
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
CONFIG_HID_ACRUX=y
CONFIG_HID_ACRUX_FF=y
# CONFIG_HID_APPLE is not set
CONFIG_HID_AUREAL=y
# CONFIG_HID_BELKIN is not set
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
CONFIG_HID_EMS_FF=y
# CONFIG_HID_ELECOM is not set
CONFIG_HID_EZKEY=y
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_HIDPP=y
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
CONFIG_HID_SAITEK=y
# CONFIG_HID_SAMSUNG is not set
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
# CONFIG_HID_SMARTJOYPLUS is not set
CONFIG_HID_TIVO=y
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

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
CONFIG_UWB=y
# CONFIG_UWB_WHCI is not set
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
CONFIG_LEDS_GPIO=y
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_LP8860=y
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_WM831X_STATUS is not set
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_LT3593 is not set
CONFIG_LEDS_ADP5520=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_MENF21BMC=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=y
# CONFIG_UIO_DMEM_GENIRQ is not set
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_MF624 is not set
CONFIG_VIRT_DRIVERS=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
# CONFIG_CHROME_PLATFORMS is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
# CONFIG_ALTERA_MBOX is not set
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_AMD_IOMMU is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_SOC_TI is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_ADC_JACK is not set
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_MAX14577=y
CONFIG_EXTCON_PALMAS=y
# CONFIG_EXTCON_RT8973A is not set
CONFIG_EXTCON_SM5502=y
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
# CONFIG_IIO_BUFFER_CB is not set
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
CONFIG_BMA180=y
# CONFIG_BMC150_ACCEL is not set
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y
CONFIG_MMA8452=y
# CONFIG_KXCJK1013 is not set
CONFIG_MMA9551_CORE=y
CONFIG_MMA9551=y
CONFIG_MMA9553=y

#
# Analog to digital converters
#
CONFIG_AD7291=y
CONFIG_AD799X=y
CONFIG_DA9150_GPADC=y
CONFIG_CC10001_ADC=y
CONFIG_MAX1363=y
CONFIG_MCP3422=y
# CONFIG_MEN_Z188_ADC is not set
CONFIG_NAU7802=y
CONFIG_QCOM_SPMI_IADC=y
CONFIG_QCOM_SPMI_VADC=y
# CONFIG_TI_ADC081C is not set
CONFIG_TI_AM335X_ADC=y
CONFIG_TWL4030_MADC=y
# CONFIG_TWL6030_GPADC is not set

#
# Amplifiers
#

#
# Hid Sensor IIO Common
#

#
# SSP Sensor Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5380=y
CONFIG_AD5446=y
CONFIG_MAX517=y
# CONFIG_MCP4725 is not set

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
# CONFIG_BMG160 is not set
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
CONFIG_ITG3200=y

#
# Humidity sensors
#
# CONFIG_DHT11 is not set
CONFIG_SI7005=y
# CONFIG_SI7020 is not set

#
# Inertial measurement units
#
# CONFIG_KMX61 is not set
CONFIG_INV_MPU6050_IIO=y

#
# Light sensors
#
# CONFIG_ADJD_S311 is not set
CONFIG_AL3320A=y
CONFIG_APDS9300=y
CONFIG_CM32181=y
CONFIG_CM3232=y
CONFIG_CM3323=y
# CONFIG_CM36651 is not set
# CONFIG_GP2AP020A00F is not set
# CONFIG_ISL29125 is not set
# CONFIG_JSA1212 is not set
CONFIG_SENSORS_LM3533=y
CONFIG_LTR501=y
CONFIG_TCS3414=y
# CONFIG_TCS3472 is not set
CONFIG_SENSORS_TSL2563=y
CONFIG_TSL4531=y
# CONFIG_VCNL4000 is not set

#
# Magnetometer sensors
#
CONFIG_AK8975=y
# CONFIG_AK09911 is not set
CONFIG_MAG3110=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Pressure sensors
#
# CONFIG_BMP280 is not set
CONFIG_MPL115=y
CONFIG_MPL3115=y
# CONFIG_MS5611 is not set
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_T5403=y

#
# Lightning sensors
#

#
# Proximity sensors
#
# CONFIG_SX9500 is not set

#
# Temperature sensors
#
# CONFIG_MLX90614 is not set
# CONFIG_TMP006 is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
CONFIG_FMC_TRIVIAL=y
# CONFIG_FMC_WRITE_EEPROM is not set
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_FS_POSIX_ACL is not set
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
# CONFIG_PROC_VMCORE is not set
# CONFIG_PROC_SYSCTL is not set
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=y
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
# CONFIG_NLS_ISO8859_1 is not set
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
# CONFIG_NLS_UTF8 is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
CONFIG_DEBUG_OBJECTS_WORK=y
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_VMACACHE=y
# CONFIG_DEBUG_VM_RB is not set
CONFIG_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_MEMORY_INIT is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
# CONFIG_PROVE_RCU_REPEATEDLY is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
CONFIG_RCU_TORTURE_TEST=y
CONFIG_RCU_TORTURE_TEST_RUNNABLE=y
CONFIG_RCU_TORTURE_TEST_SLOW_INIT=y
CONFIG_RCU_TORTURE_TEST_SLOW_INIT_DELAY=3
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_CPU_STALL_INFO=y
CONFIG_RCU_TRACE=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAIL_PAGE_ALLOC is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_TEST_HEXDUMP=y
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_TEST_FIRMWARE is not set
CONFIG_TEST_UDELAY=y
# CONFIG_MEMTEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
CONFIG_DOUBLEFAULT=y
CONFIG_DEBUG_TLBFLUSH=y
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_STATIC_CPU_HAS=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_TRUSTED_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
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
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
# CONFIG_CRYPTO_CRCT10DIF is not set
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA1_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
# CONFIG_CRYPTO_ARC4 is not set
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
# CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_LZ4=y
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_X509_CERTIFICATE_PARSER=y
# CONFIG_PKCS7_MESSAGE_PARSER is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_ARCH_HAS_SG_CHAIN=y

--tKW2IUtsqtDRztdT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
