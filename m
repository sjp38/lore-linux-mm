Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id C93796B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 11:44:52 -0400 (EDT)
Received: by qkx62 with SMTP id 62so8650968qkx.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 08:44:52 -0700 (PDT)
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [2001:4b98:c:538::195])
        by mx.google.com with ESMTPS id k39si6098255qgd.40.2015.05.06.08.44.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 06 May 2015 08:44:50 -0700 (PDT)
Date: Wed, 6 May 2015 08:44:30 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [CONFIG_MULTIUSER] BUG: unable to handle kernel paging request
 at ffffffee
Message-ID: <20150506154429.GA21798@x>
References: <20150428004320.GA19623@wfg-t540p.sh.intel.com>
 <20150506090850.GA30187@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20150506090850.GA30187@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Iulia Manda <iulia.manda21@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org

On Wed, May 06, 2015 at 05:08:50PM +0800, Fengguang Wu wrote:
> FYI, the reported bug is still not fixed in linux-next 20150506.

This isn't the same bug.  The previous one you mentioned was a userspace
assertion failure in libnih, likely caused because some part of upstart
didn't have appropriate error handling for some syscall returning
ENOSYS; that one wasn't an issue, since CONFIG_MULTIUSER=3Dn is not
expected to boot a standard Linux distribution.

This one, on the other hand, is a kernel panic, and does need fixing.

> commit 2813893f8b197a14f1e1ddb04d99bce46817c84a
>=20
> +-----------------------------------------------------------+------------=
+------------+------------+
> |                                                           | c79574abe2 =
| 2813893f8b | cbdacaf0c1 |
> +-----------------------------------------------------------+------------=
+------------+------------+
> | boot_successes                                            | 60         =
| 0          | 0          |
> | boot_failures                                             | 0          =
| 22         | 1064       |
> | BUG:unable_to_handle_kernel                               | 0          =
| 22         | 1032       |
> | Oops                                                      | 0          =
| 22         | 1032       |
> | EIP_is_at_devpts_new_index                                | 0          =
| 22         | 1032       |
> | Kernel_panic-not_syncing:Fatal_exception                  | 0          =
| 22         | 1032       |
> | backtrace:do_sys_open                                     | 0          =
| 22         | 1032       |
> | backtrace:SyS_open                                        | 0          =
| 22         | 1032       |
> | WARNING:at_arch/x86/kernel/fpu/core.c:#fpu__clear()       | 0          =
| 0          | 32         |
> | Kernel_panic-not_syncing:Attempted_to_kill_init!exitcode=3D | 0        =
  | 0          | 32         |
> +-----------------------------------------------------------+------------=
+------------+------------+

Is this table saying the number of times the type of error in the first
column occurred in each commit?

In any case, investigating.  Iulia, can you look at this as well?

I'm digging through the call stack, and I'm having a hard time seeing
how the CONFIG_MULTIUSER patch could affect anything here.

- Josh Triplett

> [    2.632019] EDD information not available.
> [    2.633108] Freeing unused kernel memory: 564K (c1bc3000 - c1c50000)
> [    2.642276] random: init urandom read with 4 bits of entropy available
> [    2.643278] BUG: unable to handle kernel paging request at ffffffee
> [    2.643807] IP: [<c11ed93e>] devpts_new_index+0x25/0x1bd
> [    2.644249] *pdpt =3D 0000000001c50001 *pde =3D 0000000001c51063 *pte =
=3D 0000000000000000=20
> [    2.644897] Oops: 0000 [#1]=20
> [    2.645141] Modules linked in:
> [    2.645400] CPU: 0 PID: 1 Comm: init Not tainted 4.0.0-05819-g2813893 =
#11
> [    2.645932] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S 1.7.5-20140531_083030-gandalf 04/01/2014
> [    2.646719] task: d084c010 ti: d084e000 task.ti: d084e000
> [    2.647147] EIP: 0060:[<c11ed93e>] EFLAGS: 00010246 CPU: 0
> [    2.647579] EIP is at devpts_new_index+0x25/0x1bd
> [    2.647964] EAX: ffffffea EBX: 00000000 ECX: c1384a75 EDX: 00000000
> [    2.648455] ESI: c23afc38 EDI: cd284cc0 EBP: d084fe00 ESP: d084fdf4
> [    2.648967]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
> [    2.649393] CR0: 80050033 CR2: ffffffee CR3: 124432e0 CR4: 000006b0
> [    2.649891] Stack:
> [    2.650047]  c1384a75 00000000 c23afc38 d084fe18 c1384a8b d0426b60 000=
00000 c23afc38
> [    2.650047]  d0426b60 d084fe38 c1172c22 00000000 cd284cc0 00000000 cd2=
84cc0 d0426b60
> [    2.650047]  00000000 d084fe58 c1169521 00000026 cd284cc8 c11729de cd2=
84cc0 d084ff04
> [    2.650047] Call Trace:
> [    2.650047]  [<c1384a75>] ? ptmx_open+0x6b/0x28b
> [    2.650047]  [<c1384a8b>] ptmx_open+0x81/0x28b
> [    2.650047]  [<c1172c22>] chrdev_open+0x244/0x270
> [    2.650047]  [<c1169521>] do_dentry_open+0x358/0x512
> [    2.650047]  [<c11729de>] ? cdev_put+0x38/0x38
> [    2.650047]  [<c1169739>] vfs_open+0x5e/0x71
> [    2.650047]  [<c1181c8f>] do_last+0xa34/0xde9
> [    2.650047]  [<c11823b1>] path_openat+0x36d/0x89b
> [    2.650047]  [<c1183c10>] do_filp_open+0x33/0xb4
> [    2.650047]  [<c11981ba>] ? __alloc_fd+0x1b5/0x1cd
> [    2.650047]  [<c116b2cf>] do_sys_open+0x22e/0x31e
> [    2.650047]  [<c11982dd>] ? fd_install+0x28/0x39
> [    2.650047]  [<c116b3e5>] SyS_open+0x26/0x44
> [    2.650047]  [<c162f782>] sysenter_do_call+0x12/0x12
> [    2.650047] Code: f4 5b 5e 5f 5d c3 55 89 e5 56 53 51 8b 40 14 81 78 3=
4 d1 1c 00 00 74 16 a1 50 8e 31 c2 83 05 c0 8b 31 c2 01 83 15 c4 8b 31 c2 0=
0 <8b> 40 04 83 05 c8 8b 31 c2 01 83 15 cc 8b 31 c2 00 8b 98 d0 02
> [    2.650047] EIP: [<c11ed93e>] devpts_new_index+0x25/0x1bd SS:ESP 0068:=
d084fdf4
> [    2.650047] CR2: 00000000ffffffee
> [    2.650047] ---[ end trace e7d6454dfe4d6c7f ]---
> [    2.650047] Kernel panic - not syncing: Fatal exception
>=20
> git bisect start 5ebe6afaf0057ac3eaeb98defd5456894b446d22 v4.0 --
> git bisect  bad 96b90f27bcf22f1d06cc16d9475cefa6ea4c4718  # 10:06      0-=
     22  Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/tip
> git bisect good 1dcf58d6e6e6eb7ec10e9abc56887b040205b06f  # 10:14     20+=
      0  Merge branch 'akpm' (patches from Andrew)
> git bisect  bad 497a5df7bf6ffd136ae21c49d1a01292930d7ca2  # 10:22      0-=
     20  Merge tag 'stable/for-linus-4.1-rc0-tag' of git://git.kernel.org/p=
ub/scm/linux/kernel/git/xen/tip
> git bisect good b422b75875a3663f08a9ab5aeb265ed2383cbe2f  # 10:31     20+=
      0  Merge branch 'kbuild' of git://git.kernel.org/pub/scm/linux/kernel=
/git/mmarek/kbuild
> git bisect good 6d50ff91d9780263160262daeb6adfdda8ddbc6c  # 10:40     20+=
      0  Merge tag 'locks-v4.1-1' of git://git.samba.org/jlayton/linux
> git bisect  bad eea3a00264cf243a28e4331566ce67b86059339d  # 10:47      0-=
     20  Merge branch 'akpm' (patches from Andrew)
> git bisect good d0a3997c0c3f9351e24029349dee65dd1d9e8d84  # 10:55     20+=
      0  Merge tag 'sound-4.1-rc1' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/tiwai/sound
> git bisect good e7c82412433a8039616c7314533a0a1c025d99bf  # 11:08     20+=
      0  Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kern=
el/git/cooloney/linux-leds
> git bisect good 248ca1b053c82fa22427d22b33ac51a24c88a86d  # 11:22     20+=
      0  zsmalloc: add fullness into stat
> git bisect  bad 3ea8d440a86b85c63c2bb7f73988626e682db5f0  # 11:29      0-=
     22  lib/vsprintf.c: eliminate duplicate hex string array
> git bisect good 160a117f0864871ae1bab26554a985a1d2861afd  # 11:38     20+=
      0  zsmalloc: remove extra cond_resched() in __zs_compact
> git bisect  bad 96831c0a6738f88f89e7012f4df0a747514af0a0  # 11:45      0-=
     22  kernel/resource.c: remove deprecated __check_region() and friends
> git bisect good 23f40a94d860449f39f00c3350bf850d15983e63  # 11:56     20+=
      0  include/linux: remove empty conditionals
> git bisect good c79574abe2baddf569532e7e430e4977771dd25c  # 12:27     20+=
      0  lib/test-hexdump.c: fix initconst confusion
> git bisect  bad 2813893f8b197a14f1e1ddb04d99bce46817c84a  # 12:34      0-=
      6  kernel: conditionally support non-root users, groups and capabilit=
ies
> # first bad commit: [2813893f8b197a14f1e1ddb04d99bce46817c84a] kernel: co=
nditionally support non-root users, groups and capabilities
> git bisect good c79574abe2baddf569532e7e430e4977771dd25c  # 12:42     60+=
      0  lib/test-hexdump.c: fix initconst confusion
> # extra tests with DEBUG_INFO
> # extra tests on HEAD of tip/tmp.fpu
> git bisect  bad a9a0b36aa770f32a191bd415b23971db5cdeb93b  # 12:48      0-=
    132  x86/fpu: Reorganize fpu/internal.h
> # extra tests on tree/branch linus/master
> git bisect  bad 5198b44374adb3f6143459a03c37f103f8a09548  # 12:52      0-=
     60  Merge tag 'for-linus-4.1-1' of git://git.code.sf.net/p/openipmi/li=
nux-ipmi
> # extra tests with first bad commit reverted
> # extra tests on tree/branch linus/master
> git bisect  bad 5198b44374adb3f6143459a03c37f103f8a09548  # 12:55      0-=
     62  Merge tag 'for-linus-4.1-1' of git://git.code.sf.net/p/openipmi/li=
nux-ipmi
> # extra tests on tree/branch next/master
> git bisect  bad cab98a65216d98e631fd7209210b1275cc7e6ef9  # 13:17      0-=
     60  Add linux-next specific files for 20150506
>=20
>=20
> This script may reproduce the error.
>=20
> -------------------------------------------------------------------------=
---
> #!/bin/bash
>=20
> kernel=3D$1
> initrd=3Dquantal-core-i386.cgz
>=20
> wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/m=
aster/initrd/$initrd
>=20
> kvm=3D(
> 	qemu-system-x86_64
> 	-enable-kvm
> 	-cpu kvm64
> 	-kernel $kernel
> 	-initrd $initrd
> 	-m 300
> 	-smp 2
> 	-device e1000,netdev=3Dnet0
> 	-netdev user,id=3Dnet0
> 	-boot order=3Dnc
> 	-no-reboot
> 	-watchdog i6300esb
> 	-rtc base=3Dlocaltime
> 	-serial stdio
> 	-display none
> 	-monitor null=20
> )
>=20
> append=3D(
> 	hung_task_panic=3D1
> 	earlyprintk=3DttyS0,115200
> 	rd.udev.log-priority=3Derr
> 	systemd.log_target=3Djournal
> 	systemd.log_level=3Dwarning
> 	debug
> 	apic=3Ddebug
> 	sysrq_always_enabled
> 	rcupdate.rcu_cpu_stall_timeout=3D100
> 	panic=3D-1
> 	softlockup_panic=3D1
> 	nmi_watchdog=3Dpanic
> 	oops=3Dpanic
> 	load_ramdisk=3D2
> 	prompt_ramdisk=3D0
> 	console=3DttyS0,115200
> 	console=3Dtty0
> 	vga=3Dnormal
> 	root=3D/dev/ram0
> 	rw
> 	drbd.minor_count=3D8
> )
>=20
> "${kvm[@]}" --append "${append[*]}"
> -------------------------------------------------------------------------=
---
>=20
> Thanks,
> Fengguang

> early console in setup code
> early console in decompress_kernel
>=20
> Decompressing Linux... Parsing ELF... No relocation needed... done.
> Booting the kernel.
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 4.0.0-05819-g2813893 (kbuild@roam) (gcc vers=
ion 4.9.2 (Debian 4.9.2-10) ) #11 Wed May 6 12:30:40 CST 2015
> [    0.000000] KERNEL supported cpus:
> [    0.000000]   AMD AuthenticAMD
> [    0.000000]   NSC Geode by NSC
> [    0.000000]   Cyrix CyrixInstead
> [    0.000000]   Centaur CentaurHauls
> [    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
> [    0.000000] CPU: Your system may be unstable.
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usa=
ble
> [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000012bdffff] usa=
ble
> [    0.000000] BIOS-e820: [mem 0x0000000012be0000-0x0000000012bfffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] res=
erved
> [    0.000000] bootconsole [earlyser0] enabled
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] SMBIOS 2.8 present.
> [    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20=
140531_083030-gandalf 04/01/2014
> [    0.000000] Hypervisor detected: KVM
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> re=
served
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] e820: last_pfn =3D 0x12be0 max_arch_pfn =3D 0x1000000
> [    0.000000] Scanning 1 areas for low memory corruption
> [    0.000000] initial memory mapped: [mem 0x00000000-0x029fffff]
> [    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
> [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
> [    0.000000]  [mem 0x00000000-0x000fffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x11000000-0x111fffff]
> [    0.000000]  [mem 0x11000000-0x111fffff] page 2M
> [    0.000000] init_memory_mapping: [mem 0x00100000-0x10ffffff]
> [    0.000000]  [mem 0x00100000-0x001fffff] page 4k
> [    0.000000]  [mem 0x00200000-0x10ffffff] page 2M
> [    0.000000] init_memory_mapping: [mem 0x11200000-0x12bdffff]
> [    0.000000]  [mem 0x11200000-0x129fffff] page 2M
> [    0.000000]  [mem 0x12a00000-0x12bdffff] page 4k
> [    0.000000] BRK [0x024d3000, 0x024d3fff] PGTABLE
> [    0.000000] BRK [0x024d4000, 0x024d4fff] PGTABLE
> [    0.000000] RAMDISK: [mem 0x11393000-0x12bd7fff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x000F0C60 000014 (v00 BOCHS )
> [    0.000000] ACPI: RSDT 0x12BE18BD 000034 (v01 BOCHS  BXPCRSDT 00000001=
 BXPC 00000001)
> [    0.000000] ACPI: FACP 0x12BE0B37 000074 (v01 BOCHS  BXPCFACP 00000001=
 BXPC 00000001)
> [    0.000000] ACPI: DSDT 0x12BE0040 000AF7 (v01 BOCHS  BXPCDSDT 00000001=
 BXPC 00000001)
> [    0.000000] ACPI: FACS 0x12BE0000 000040
> [    0.000000] ACPI: SSDT 0x12BE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00000001=
 BXPC 00000001)
> [    0.000000] ACPI: APIC 0x12BE1805 000080 (v01 BOCHS  BXPCAPIC 00000001=
 BXPC 00000001)
> [    0.000000] ACPI: HPET 0x12BE1885 000038 (v01 BOCHS  BXPCHPET 00000001=
 BXPC 00000001)
> [    0.000000] 0MB HIGHMEM available.
> [    0.000000] 299MB LOWMEM available.
> [    0.000000]   mapped low ram: 0 - 12be0000
> [    0.000000]   low ram: 0 - 12be0000
> [    0.000000] cma: dma_contiguous_reserve(limit 12be0000)
> [    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
> [    0.000000] kvm-clock: cpu 0, msr 0:12bdf001, primary cpu clock
> [    0.000000] clocksource kvm-clock: mask: 0xffffffffffffffff max_cycles=
: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   Normal   [mem 0x0000000001000000-0x0000000012bdffff]
> [    0.000000]   HighMem  empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x0000000012bdffff]
> [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000012b=
dffff]
> [    0.000000] On node 0 totalpages: 76670
> [    0.000000]   DMA zone: 36 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 3998 pages, LIFO batch:0
> [    0.000000]   Normal zone: 639 pages used for memmap
> [    0.000000]   Normal zone: 72672 pages, LIFO batch:15
> [    0.000000] ACPI: PM-Timer IO Port: 0x608
> [    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
> [    0.000000] KVM setup async PF for cpu 0
> [    0.000000] kvm-stealtime: cpu 0, msr 1981fc0
> [    0.000000] e820: [mem 0x12c00000-0xfeffbfff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on KVM
> [    0.000000] clocksource refined-jiffies: mask: 0xffffffff max_cycles: =
0xffffffff, max_idle_ns: 19112604462750000 ns
> [    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
> [    0.000000] pcpu-alloc: [0] 0=20
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  To=
tal pages: 75995
> [    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3Dtty=
S0,115200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.l=
og_level=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu=
_stall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic o=
ops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 cons=
ole=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue=
/kvm/i386-randconfig-r1-0505/tip:tmp.fpu:2813893f8b197a14f1e1ddb04d99bce468=
17c84a:bisect-linux-5/.vmlinuz-2813893f8b197a14f1e1ddb04d99bce46817c84a-201=
50506123323-20-ivb41 branch=3Dtip/tmp.fpu BOOT_IMAGE=3D/kernel/i386-randcon=
fig-r1-0505/2813893f8b197a14f1e1ddb04d99bce46817c84a/vmlinuz-4.0.0-05819-g2=
813893 drbd.minor_count=3D8
> [    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
> [    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 b=
ytes)
> [    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 by=
tes)
> [    0.000000] Initializing CPU#0
> [    0.000000] Initializing HighMem for node 0 (00000000:00000000)
> [    0.000000] Memory: 255336K/306680K available (6339K kernel code, 2397=
K rwdata, 3272K rodata, 564K init, 8628K bss, 51344K reserved, 0K cma-reser=
ved, 0K highmem)
> [    0.000000] virtual kernel memory layout:
> [    0.000000]     fixmap  : 0xfffce000 - 0xfffff000   ( 196 kB)
> [    0.000000]     pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
> [    0.000000]     vmalloc : 0xd33e0000 - 0xffbfe000   ( 712 MB)
> [    0.000000]     lowmem  : 0xc0000000 - 0xd2be0000   ( 299 MB)
> [    0.000000]       .init : 0xc1bc3000 - 0xc1c50000   ( 564 kB)
> [    0.000000]       .data : 0xc16310d8 - 0xc1bc1540   (5697 kB)
> [    0.000000]       .text : 0xc1000000 - 0xc16310d8   (6340 kB)
> [    0.000000] Checking if this processor honours the WP bit even in supe=
rvisor mode...Ok.
> [    0.000000] NR_IRQS:16 nr_irqs:16 16
> [    0.000000] CPU 0 irqstacks, hard=3Dd0808000 soft=3Dd080a000
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 4.0.0-05819-g2813893 (kbuild@roam) (gcc vers=
ion 4.9.2 (Debian 4.9.2-10) ) #11 Wed May 6 12:30:40 CST 2015
> [    0.000000] KERNEL supported cpus:
> [    0.000000]   AMD AuthenticAMD
> [    0.000000]   NSC Geode by NSC
> [    0.000000]   Cyrix CyrixInstead
> [    0.000000]   Centaur CentaurHauls
> [    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
> [    0.000000] CPU: Your system may be unstable.
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usa=
ble
> [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000012bdffff] usa=
ble
> [    0.000000] BIOS-e820: [mem 0x0000000012be0000-0x0000000012bfffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] res=
erved
> [    0.000000] bootconsole [earlyser0] enabled
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] SMBIOS 2.8 present.
> [    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20=
140531_083030-gandalf 04/01/2014
> [    0.000000] Hypervisor detected: KVM
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> re=
served
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] e820: last_pfn =3D 0x12be0 max_arch_pfn =3D 0x1000000
> [    0.000000] Scanning 1 areas for low memory corruption
> [    0.000000] initial memory mapped: [mem 0x00000000-0x029fffff]
> [    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
> [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
> [    0.000000]  [mem 0x00000000-0x000fffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x11000000-0x111fffff]
> [    0.000000]  [mem 0x11000000-0x111fffff] page 2M
> [    0.000000] init_memory_mapping: [mem 0x00100000-0x10ffffff]
> [    0.000000]  [mem 0x00100000-0x001fffff] page 4k
> [    0.000000]  [mem 0x00200000-0x10ffffff] page 2M
> [    0.000000] init_memory_mapping: [mem 0x11200000-0x12bdffff]
> [    0.000000]  [mem 0x11200000-0x129fffff] page 2M
> [    0.000000]  [mem 0x12a00000-0x12bdffff] page 4k
> [    0.000000] BRK [0x024d3000, 0x024d3fff] PGTABLE
> [    0.000000] BRK [0x024d4000, 0x024d4fff] PGTABLE
> [    0.000000] RAMDISK: [mem 0x11393000-0x12bd7fff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x000F0C60 000014 (v00 BOCHS )
> [    0.000000] ACPI: RSDT 0x12BE18BD 000034 (v01 BOCHS  BXPCRSDT 00000001=
 BXPC 00000001)
> [    0.000000] ACPI: FACP 0x12BE0B37 000074 (v01 BOCHS  BXPCFACP 00000001=
 BXPC 00000001)
> [    0.000000] ACPI: DSDT 0x12BE0040 000AF7 (v01 BOCHS  BXPCDSDT 00000001=
 BXPC 00000001)
> [    0.000000] ACPI: FACS 0x12BE0000 000040
> [    0.000000] ACPI: SSDT 0x12BE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00000001=
 BXPC 00000001)
> [    0.000000] ACPI: APIC 0x12BE1805 000080 (v01 BOCHS  BXPCAPIC 00000001=
 BXPC 00000001)
> [    0.000000] ACPI: HPET 0x12BE1885 000038 (v01 BOCHS  BXPCHPET 00000001=
 BXPC 00000001)
> [    0.000000] 0MB HIGHMEM available.
> [    0.000000] 299MB LOWMEM available.
> [    0.000000]   mapped low ram: 0 - 12be0000
> [    0.000000]   low ram: 0 - 12be0000
> [    0.000000] cma: dma_contiguous_reserve(limit 12be0000)
> [    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
> [    0.000000] kvm-clock: cpu 0, msr 0:12bdf001, primary cpu clock
> [    0.000000] clocksource kvm-clock: mask: 0xffffffffffffffff max_cycles=
: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   Normal   [mem 0x0000000001000000-0x0000000012bdffff]
> [    0.000000]   HighMem  empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x0000000012bdffff]
> [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000012b=
dffff]
> [    0.000000] On node 0 totalpages: 76670
> [    0.000000]   DMA zone: 36 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 3998 pages, LIFO batch:0
> [    0.000000]   Normal zone: 639 pages used for memmap
> [    0.000000]   Normal zone: 72672 pages, LIFO batch:15
> [    0.000000] ACPI: PM-Timer IO Port: 0x608
> [    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
> [    0.000000] KVM setup async PF for cpu 0
> [    0.000000] kvm-stealtime: cpu 0, msr 1981fc0
> [    0.000000] e820: [mem 0x12c00000-0xfeffbfff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on KVM
> [    0.000000] clocksource refined-jiffies: mask: 0xffffffff max_cycles: =
0xffffffff, max_idle_ns: 19112604462750000 ns
> [    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
> [    0.000000] pcpu-alloc: [0] 0=20
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  To=
tal pages: 75995
> [    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3Dtty=
S0,115200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.l=
og_level=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu=
_stall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic o=
ops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 cons=
ole=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue=
/kvm/i386-randconfig-r1-0505/tip:tmp.fpu:2813893f8b197a14f1e1ddb04d99bce468=
17c84a:bisect-linux-5/.vmlinuz-2813893f8b197a14f1e1ddb04d99bce46817c84a-201=
50506123323-20-ivb41 branch=3Dtip/tmp.fpu BOOT_IMAGE=3D/kernel/i386-randcon=
fig-r1-0505/2813893f8b197a14f1e1ddb04d99bce46817c84a/vmlinuz-4.0.0-05819-g2=
813893 drbd.minor_count=3D8
> [    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
> [    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 b=
ytes)
> [    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 by=
tes)
> [    0.000000] Initializing CPU#0
> [    0.000000] Initializing HighMem for node 0 (00000000:00000000)
> [    0.000000] Memory: 255336K/306680K available (6339K kernel code, 2397=
K rwdata, 3272K rodata, 564K init, 8628K bss, 51344K reserved, 0K cma-reser=
ved, 0K highmem)
> [    0.000000] virtual kernel memory layout:
> [    0.000000]     fixmap  : 0xfffce000 - 0xfffff000   ( 196 kB)
> [    0.000000]     pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
> [    0.000000]     vmalloc : 0xd33e0000 - 0xffbfe000   ( 712 MB)
> [    0.000000]     lowmem  : 0xc0000000 - 0xd2be0000   ( 299 MB)
> [    0.000000]       .init : 0xc1bc3000 - 0xc1c50000   ( 564 kB)
> [    0.000000]       .data : 0xc16310d8 - 0xc1bc1540   (5697 kB)
> [    0.000000]       .text : 0xc1000000 - 0xc16310d8   (6340 kB)
> [    0.000000] Checking if this processor honours the WP bit even in supe=
rvisor mode...Ok.
> [    0.000000] NR_IRQS:16 nr_irqs:16 16
> [    0.000000] CPU 0 irqstacks, hard=3Dd0808000 soft=3Dd080a000
> [    0.000000] console [ttyS0] enabled
> [    0.000000] console [ttyS0] enabled
> [    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc=
=2E, Ingo Molnar
> [    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc=
=2E, Ingo Molnar
> [    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000000] ... MAX_LOCK_DEPTH:          48
> [    0.000000] ... MAX_LOCK_DEPTH:          48
> [    0.000000] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000000] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000000] ... CLASSHASH_SIZE:          4096
> [    0.000000] ... CLASSHASH_SIZE:          4096
> [    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
> [    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
> [    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
> [    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
> [    0.000000] ... CHAINHASH_SIZE:          32768
> [    0.000000] ... CHAINHASH_SIZE:          32768
> [    0.000000]  memory used by lock dependency info: 5151 kB
> [    0.000000]  memory used by lock dependency info: 5151 kB
> [    0.000000]  per task-struct memory footprint: 1920 bytes
> [    0.000000]  per task-struct memory footprint: 1920 bytes
> [    0.000000] ------------------------
> [    0.000000] ------------------------
> [    0.000000] | Locking API testsuite:
> [    0.000000] | Locking API testsuite:
> [    0.000000] ----------------------------------------------------------=
------------------
> [    0.000000] ----------------------------------------------------------=
------------------
> [    0.000000]                                  | spin |wlock |rlock |mut=
ex | wsem | rsem |
> [    0.000000]                                  | spin |wlock |rlock |mut=
ex | wsem | rsem |
> [    0.000000]   --------------------------------------------------------=
------------------
> [    0.000000]   --------------------------------------------------------=
------------------
> [    0.000000]                      A-A deadlock:
> [    0.000000]                      A-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|
>=20
> [    0.000000]                  A-B-B-A deadlock:
> [    0.000000]                  A-B-B-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|
>=20
> [    0.000000]              A-B-B-C-C-A deadlock:
> [    0.000000]              A-B-B-C-C-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|
>=20
> [    0.000000]              A-B-C-A-B-C deadlock:
> [    0.000000]              A-B-C-A-B-C deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|
>=20
> [    0.000000]          A-B-B-C-C-D-D-A deadlock:
> [    0.000000]          A-B-B-C-C-D-D-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|
>=20
> [    0.000000]          A-B-C-D-B-D-D-A deadlock:
> [    0.000000]          A-B-C-D-B-D-D-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|
>=20
> [    0.000000]          A-B-C-D-B-C-D-A deadlock:
> [    0.000000]          A-B-C-D-B-C-D-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|
>=20
> [    0.000000]                     double unlock:
> [    0.000000]                     double unlock:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
>=20
> [    0.000000]                   initialize held:
> [    0.000000]                   initialize held:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
>=20
> [    0.000000]                  bad unlock order:
> [    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
>=20
> [    0.000000]   --------------------------------------------------------=
------------------
> [    0.000000]   --------------------------------------------------------=
------------------
> [    0.000000]               recursive read-lock:
> [    0.000000]               recursive read-lock:             |          =
   |  ok  |  ok  |             |             |failed|failed|
>=20
> [    0.000000]            recursive read-lock #2:
> [    0.000000]            recursive read-lock #2:             |          =
   |  ok  |  ok  |             |             |failed|failed|
>=20
> [    0.000000]             mixed read-write-lock:
> [    0.000000]             mixed read-write-lock:             |          =
   |failed|failed|             |             |failed|failed|
>=20
> [    0.000000]             mixed write-read-lock:
> [    0.000000]             mixed write-read-lock:             |          =
   |failed|failed|             |             |failed|failed|
>=20
> [    0.000000]   --------------------------------------------------------=
------------------
> [    0.000000]   --------------------------------------------------------=
------------------
> [    0.000000]      hard-irqs-on + irq-safe-A/12:
> [    0.000000]      hard-irqs-on + irq-safe-A/12:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]      soft-irqs-on + irq-safe-A/12:
> [    0.000000]      soft-irqs-on + irq-safe-A/12:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]      hard-irqs-on + irq-safe-A/21:
> [    0.000000]      hard-irqs-on + irq-safe-A/21:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]      soft-irqs-on + irq-safe-A/21:
> [    0.000000]      soft-irqs-on + irq-safe-A/21:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]        sirq-safe-A =3D> hirqs-on/12:
> [    0.000000]        sirq-safe-A =3D> hirqs-on/12:failed|failed|failed|f=
ailed|  ok  |  ok  |
>=20
> [    0.000000]        sirq-safe-A =3D> hirqs-on/21:
> [    0.000000]        sirq-safe-A =3D> hirqs-on/21:failed|failed|failed|f=
ailed|  ok  |  ok  |
>=20
> [    0.000000]          hard-safe-A + irqs-on/12:
> [    0.000000]          hard-safe-A + irqs-on/12:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]          soft-safe-A + irqs-on/12:
> [    0.000000]          soft-safe-A + irqs-on/12:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]          hard-safe-A + irqs-on/21:
> [    0.000000]          hard-safe-A + irqs-on/21:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]          soft-safe-A + irqs-on/21:
> [    0.000000]          soft-safe-A + irqs-on/21:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #1/123:
> [    0.000000]     hard-safe-A + unsafe-B #1/123:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #1/123:
> [    0.000000]     soft-safe-A + unsafe-B #1/123:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #1/132:
> [    0.000000]     hard-safe-A + unsafe-B #1/132:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #1/132:
> [    0.000000]     soft-safe-A + unsafe-B #1/132:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #1/213:
> [    0.000000]     hard-safe-A + unsafe-B #1/213:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #1/213:
> [    0.000000]     soft-safe-A + unsafe-B #1/213:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #1/231:
> [    0.000000]     hard-safe-A + unsafe-B #1/231:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #1/231:
> [    0.000000]     soft-safe-A + unsafe-B #1/231:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #1/312:
> [    0.000000]     hard-safe-A + unsafe-B #1/312:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #1/312:
> [    0.000000]     soft-safe-A + unsafe-B #1/312:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #1/321:
> [    0.000000]     hard-safe-A + unsafe-B #1/321:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #1/321:
> [    0.000000]     soft-safe-A + unsafe-B #1/321:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #2/123:
> [    0.000000]     hard-safe-A + unsafe-B #2/123:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #2/123:
> [    0.000000]     soft-safe-A + unsafe-B #2/123:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #2/132:
> [    0.000000]     hard-safe-A + unsafe-B #2/132:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #2/132:
> [    0.000000]     soft-safe-A + unsafe-B #2/132:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #2/213:
> [    0.000000]     hard-safe-A + unsafe-B #2/213:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #2/213:
> [    0.000000]     soft-safe-A + unsafe-B #2/213:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #2/231:
> [    0.000000]     hard-safe-A + unsafe-B #2/231:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #2/231:
> [    0.000000]     soft-safe-A + unsafe-B #2/231:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #2/312:
> [    0.000000]     hard-safe-A + unsafe-B #2/312:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #2/312:
> [    0.000000]     soft-safe-A + unsafe-B #2/312:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     hard-safe-A + unsafe-B #2/321:
> [    0.000000]     hard-safe-A + unsafe-B #2/321:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]     soft-safe-A + unsafe-B #2/321:
> [    0.000000]     soft-safe-A + unsafe-B #2/321:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       hard-irq lock-inversion/123:
> [    0.000000]       hard-irq lock-inversion/123:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       soft-irq lock-inversion/123:
> [    0.000000]       soft-irq lock-inversion/123:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       hard-irq lock-inversion/132:
> [    0.000000]       hard-irq lock-inversion/132:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       soft-irq lock-inversion/132:
> [    0.000000]       soft-irq lock-inversion/132:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       hard-irq lock-inversion/213:
> [    0.000000]       hard-irq lock-inversion/213:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       soft-irq lock-inversion/213:
> [    0.000000]       soft-irq lock-inversion/213:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       hard-irq lock-inversion/231:
> [    0.000000]       hard-irq lock-inversion/231:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       soft-irq lock-inversion/231:
> [    0.000000]       soft-irq lock-inversion/231:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       hard-irq lock-inversion/312:
> [    0.000000]       hard-irq lock-inversion/312:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       soft-irq lock-inversion/312:
> [    0.000000]       soft-irq lock-inversion/312:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       hard-irq lock-inversion/321:
> [    0.000000]       hard-irq lock-inversion/321:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       soft-irq lock-inversion/321:
> [    0.000000]       soft-irq lock-inversion/321:failed|failed|failed|fai=
led|  ok  |  ok  |
>=20
> [    0.000000]       hard-irq read-recursion/123:
> [    0.000000]       hard-irq read-recursion/123:  ok  |  ok  |
>=20
> [    0.000000]       soft-irq read-recursion/123:
> [    0.000000]       soft-irq read-recursion/123:  ok  |  ok  |
>=20
> [    0.000000]       hard-irq read-recursion/132:
> [    0.000000]       hard-irq read-recursion/132:  ok  |  ok  |
>=20
> [    0.000000]       soft-irq read-recursion/132:
> [    0.000000]       soft-irq read-recursion/132:  ok  |  ok  |
>=20
> [    0.000000]       hard-irq read-recursion/213:
> [    0.000000]       hard-irq read-recursion/213:  ok  |  ok  |
>=20
> [    0.000000]       soft-irq read-recursion/213:
> [    0.000000]       soft-irq read-recursion/213:  ok  |  ok  |
>=20
> [    0.000000]       hard-irq read-recursion/231:
> [    0.000000]       hard-irq read-recursion/231:  ok  |  ok  |
>=20
> [    0.000000]       soft-irq read-recursion/231:
> [    0.000000]       soft-irq read-recursion/231:  ok  |  ok  |
>=20
> [    0.000000]       hard-irq read-recursion/312:
> [    0.000000]       hard-irq read-recursion/312:  ok  |  ok  |
>=20
> [    0.000000]       soft-irq read-recursion/312:
> [    0.000000]       soft-irq read-recursion/312:  ok  |  ok  |
>=20
> [    0.000000]       hard-irq read-recursion/321:
> [    0.000000]       hard-irq read-recursion/321:  ok  |  ok  |
>=20
> [    0.000000]       soft-irq read-recursion/321:
> [    0.000000]       soft-irq read-recursion/321:  ok  |  ok  |
>=20
> [    0.000000]   --------------------------------------------------------=
------------------
> [    0.000000]   --------------------------------------------------------=
------------------
> [    0.000000]   | Wound/wait tests |
> [    0.000000]   | Wound/wait tests |
> [    0.000000]   ---------------------
> [    0.000000]   ---------------------
> [    0.000000]                   ww api failures:
> [    0.000000]                   ww api failures:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |
>=20
> [    0.000000]                ww contexts mixing:
> [    0.000000]                ww contexts mixing:failed|failed|  ok  |  o=
k  |
>=20
> [    0.000000]              finishing ww context:
> [    0.000000]              finishing ww context:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |
>=20
> [    0.000000]                locking mismatches:
> [    0.000000]                locking mismatches:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |
>=20
> [    0.000000]                  EDEADLK handling:
> [    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  | =
 ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
>=20
> [    0.000000]            spinlock nest unlocked:
> [    0.000000]            spinlock nest unlocked:  ok  |  ok  |
>=20
> [    0.000000]   -----------------------------------------------------
> [    0.000000]   -----------------------------------------------------
> [    0.000000]                                  |block | try  |context|
> [    0.000000]                                  |block | try  |context|
> [    0.000000]   -----------------------------------------------------
> [    0.000000]   -----------------------------------------------------
> [    0.000000]                           context:
> [    0.000000]                           context:failed|failed|  ok  |  o=
k  |  ok  |  ok  |
>=20
> [    0.000000]                               try:
> [    0.000000]                               try:failed|failed|  ok  |  o=
k  |failed|failed|
>=20
> [    0.000000]                             block:
> [    0.000000]                             block:failed|failed|  ok  |  o=
k  |failed|failed|
>=20
> [    0.000000]                          spinlock:
> [    0.000000]                          spinlock:failed|failed|  ok  |  o=
k  |failed|failed|
>=20
> [    0.000000] --------------------------------------------------------
> [    0.000000] --------------------------------------------------------
> [    0.000000] 141 out of 253 testcases failed, as expected. |
> [    0.000000] 141 out of 253 testcases failed, as expected. |
> [    0.000000] ----------------------------------------------------
> [    0.000000] ----------------------------------------------------
> [    0.000000] clocksource hpet: mask: 0xffffffff max_cycles: 0xffffffff,=
 max_idle_ns: 19112604467 ns
> [    0.000000] clocksource hpet: mask: 0xffffffff max_cycles: 0xffffffff,=
 max_idle_ns: 19112604467 ns
> [    0.000000] hpet clockevent registered
> [    0.000000] hpet clockevent registered
> [    0.000000] tsc: Detected 2693.508 MHz processor
> [    0.000000] tsc: Detected 2693.508 MHz processor
> [    0.020000] Calibrating delay loop (skipped) preset value..=20
> [    0.020000] Calibrating delay loop (skipped) preset value.. 5387.01 Bo=
goMIPS (lpj=3D26935080)
> 5387.01 BogoMIPS (lpj=3D26935080)
> [    0.020000] pid_max: default: 4096 minimum: 301
> [    0.020000] pid_max: default: 4096 minimum: 301
> [    0.020000] ACPI: Core revision 20150204
> [    0.020000] ACPI: Core revision 20150204
> [    0.020000] ACPI:=20
> [    0.020000] ACPI: All ACPI Tables successfully acquiredAll ACPI Tables=
 successfully acquired
>=20
> [    0.020000] ACPI: setting ELCR to 0200 (from 0c00)
> [    0.020000] ACPI: setting ELCR to 0200 (from 0c00)
> [    0.020014] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
> [    0.020014] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
> [    0.021055] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 =
bytes)
> [    0.021055] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 =
bytes)
> [    0.022937] Initializing cgroup subsys memory
> [    0.022937] Initializing cgroup subsys memory
> [    0.023664] Initializing cgroup subsys perf_event
> [    0.023664] Initializing cgroup subsys perf_event
> [    0.024415] Initializing cgroup subsys hugetlb
> [    0.024415] Initializing cgroup subsys hugetlb
> [    0.025127] Initializing cgroup subsys debug
> [    0.025127] Initializing cgroup subsys debug
> [    0.025872] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
> [    0.025872] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
> [    0.026711] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
> [    0.026711] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
> [    0.027642] CPU:=20
> [    0.027642] CPU: GenuineIntel GenuineIntel Common KVM processorCommon =
KVM processor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
> , stepping: 01)
> [    0.031349] Performance Events:=20
> [    0.031349] Performance Events: no PMU driver, software events only.
> no PMU driver, software events only.
> [    0.033423] devtmpfs: initialized
> [    0.033423] devtmpfs: initialized
> [    0.034704] gcov: version magic: 0x3430392a
> [    0.034704] gcov: version magic: 0x3430392a
> [    0.036761] clocksource jiffies: mask: 0xffffffff max_cycles: 0xffffff=
ff, max_idle_ns: 19112604462750000 ns
> [    0.036761] clocksource jiffies: mask: 0xffffffff max_cycles: 0xffffff=
ff, max_idle_ns: 19112604462750000 ns
> [    0.038450] atomic64_test: passed for i586+ platform with CX8 and with=
 SSE
> [    0.038450] atomic64_test: passed for i586+ platform with CX8 and with=
 SSE
> [    0.040250] RTC time: 12:34:40, date: 05/06/15
> [    0.040250] RTC time: 12:34:40, date: 05/06/15
> [    0.041519] NET: Registered protocol family 16
> [    0.041519] NET: Registered protocol family 16
> [    0.043060] EISA bus registered
> [    0.043060] EISA bus registered
> [    0.043581] cpuidle: using governor ladder
> [    0.043581] cpuidle: using governor ladder
> [    0.044239] cpuidle: using governor menu
> [    0.044239] cpuidle: using governor menu
> [    0.045135] ACPI: bus type PCI registered
> [    0.045135] ACPI: bus type PCI registered
> [    0.045955] PCI : PCI BIOS area is rw and x. Use pci=3Dnobios if you w=
ant it NX.
> [    0.045955] PCI : PCI BIOS area is rw and x. Use pci=3Dnobios if you w=
ant it NX.
> [    0.047095] PCI: PCI BIOS revision 2.10 entry at 0xfd456, last bus=3D0
> [    0.047095] PCI: PCI BIOS revision 2.10 entry at 0xfd456, last bus=3D0
> [    0.048088] PCI: Using configuration type 1 for base access
> [    0.048088] PCI: Using configuration type 1 for base access
> [    0.055391] ACPI: Added _OSI(Module Device)
> [    0.055391] ACPI: Added _OSI(Module Device)
> [    0.056059] ACPI: Added _OSI(Processor Device)
> [    0.056059] ACPI: Added _OSI(Processor Device)
> [    0.056763] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.056763] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.057504] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.057504] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.064639] ACPI: Interpreter enabled
> [    0.064639] ACPI: Interpreter enabled
> [    0.065232] ACPI Exception: AE_NOT_FOUND,=20
> [    0.065232] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State=
 [\_S1_]While evaluating Sleep State [\_S1_] (20150204/hwxface-580)
>  (20150204/hwxface-580)
> [    0.066712] ACPI Exception: AE_NOT_FOUND,=20
> [    0.066712] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State=
 [\_S2_]While evaluating Sleep State [\_S2_] (20150204/hwxface-580)
>  (20150204/hwxface-580)
> [    0.068214] ACPI: (supports S0 S3 S5)
> [    0.068214] ACPI: (supports S0 S3 S5)
> [    0.068798] ACPI: Using PIC for interrupt routing
> [    0.068798] ACPI: Using PIC for interrupt routing
> [    0.069608] PCI: Using host bridge windows from ACPI; if necessary, us=
e "pci=3Dnocrs" and report a bug
> [    0.069608] PCI: Using host bridge windows from ACPI; if necessary, us=
e "pci=3Dnocrs" and report a bug
> [    0.086154] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> [    0.086154] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> [    0.087161] acpi PNP0A03:00: _OSC: OS supports [Segments]
> [    0.087161] acpi PNP0A03:00: _OSC: OS supports [Segments]
> [    0.088045] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    0.088045] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    0.089248] acpi PNP0A03:00: fail to add MMCONFIG information, can't a=
ccess extended PCI configuration space under this bridge.
> [    0.089248] acpi PNP0A03:00: fail to add MMCONFIG information, can't a=
ccess extended PCI configuration space under this bridge.
> [    0.090295] PCI host bridge to bus 0000:00
> [    0.090295] PCI host bridge to bus 0000:00
> [    0.090964] pci_bus 0000:00: root bus resource [bus 00-ff]
> [    0.090964] pci_bus 0000:00: root bus resource [bus 00-ff]
> [    0.091830] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 wind=
ow]
> [    0.091830] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 wind=
ow]
> [    0.092902] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff wind=
ow]
> [    0.092902] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff wind=
ow]
> [    0.093972] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff wind=
ow]
> [    0.093972] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff wind=
ow]
> [    0.095044] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf wind=
ow]
> [    0.095044] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf wind=
ow]
> [    0.096109] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff wind=
ow]
> [    0.096109] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff wind=
ow]
> [    0.097188] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bf=
fff window]
> [    0.097188] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bf=
fff window]
> [    0.098346] pci_bus 0000:00: root bus resource [mem 0x12c00000-0xfebff=
fff window]
> [    0.098346] pci_bus 0000:00: root bus resource [mem 0x12c00000-0xfebff=
fff window]
> [    0.100071] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
> [    0.100071] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
> [    0.101709] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
> [    0.101709] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
> [    0.103423] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
> [    0.103423] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
> [    0.116355] pci 0000:00:01.1: reg 0x20: [io  0xc200-0xc20f]
> [    0.116355] pci 0000:00:01.1: reg 0x20: [io  0xc200-0xc20f]
> [    0.121088] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-=
0x01f7]
> [    0.121088] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-=
0x01f7]
> [    0.122225] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
> [    0.122225] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
> [    0.123254] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-=
0x0177]
> [    0.123254] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-=
0x0177]
> [    0.124367] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
> [    0.124367] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
> [    0.125854] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
> [    0.125854] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
> [    0.127084] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PI=
IX4 ACPI
> [    0.127084] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PI=
IX4 ACPI
> [    0.128225] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PI=
IX4 SMB
> [    0.128225] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PI=
IX4 SMB
> [    0.130395] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
> [    0.130395] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
> [    0.135783] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pre=
f]
> [    0.135783] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pre=
f]
> [    0.140000] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
> [    0.140000] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
> [    0.162165] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pre=
f]
> [    0.162165] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pre=
f]
> [    0.163782] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
> [    0.163782] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
> [    0.168931] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
> [    0.168931] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
> [    0.174186] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
> [    0.174186] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
> [    0.196282] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pre=
f]
> [    0.196282] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pre=
f]
> [    0.197883] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
> [    0.197883] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
> [    0.204264] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
> [    0.204264] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
> [    0.209394] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
> [    0.209394] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
> [    0.230591] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
> [    0.230591] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
> [    0.235792] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
> [    0.235792] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
> [    0.242110] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
> [    0.242110] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
> [    0.264844] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
> [    0.264844] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
> [    0.270000] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
> [    0.270000] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
> [    0.274213] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
> [    0.274213] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
> [    0.296911] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
> [    0.296911] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
> [    0.302132] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
> [    0.302132] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
> [    0.307221] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
> [    0.307221] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
> [    0.330620] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
> [    0.330620] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
> [    0.335825] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
> [    0.335825] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
> [    0.340000] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
> [    0.340000] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
> [    0.364794] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
> [    0.364794] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
> [    0.370000] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
> [    0.370000] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
> [    0.374256] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
> [    0.374256] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
> [    0.396946] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
> [    0.396946] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
> [    0.402125] pci 0000:00:0a.0: reg 0x10: [io  0xc1c0-0xc1ff]
> [    0.402125] pci 0000:00:0a.0: reg 0x10: [io  0xc1c0-0xc1ff]
> [    0.407224] pci 0000:00:0a.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
> [    0.407224] pci 0000:00:0a.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
> [    0.430596] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
> [    0.430596] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
> [    0.433668] pci 0000:00:0b.0: reg 0x10: [mem 0xfebf8000-0xfebf800f]
> [    0.433668] pci 0000:00:0b.0: reg 0x10: [mem 0xfebf8000-0xfebf800f]
> [    0.447960] pci_bus 0000:00: on NUMA node 0
> [    0.447960] pci_bus 0000:00: on NUMA node 0
> [    0.450202] ACPI: PCI Interrupt Link [LNKA] (IRQs
> [    0.450202] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))
>=20
> [    0.451355] ACPI: PCI Interrupt Link [LNKB] (IRQs
> [    0.451355] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))
>=20
> [    0.452496] ACPI: PCI Interrupt Link [LNKC] (IRQs
> [    0.452496] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))
>=20
> [    0.453646] ACPI: PCI Interrupt Link [LNKD] (IRQs
> [    0.453646] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))
>=20
> [    0.454690] ACPI: PCI Interrupt Link [LNKS] (IRQs
> [    0.454690] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))
>=20
> [    0.456347] ACPI:=20
> [    0.456347] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in =
block 00 to 0F
>=20
> [    0.458016] vgaarb: setting as boot device: PCI:0000:00:02.0
> [    0.458016] vgaarb: setting as boot device: PCI:0000:00:02.0
> [    0.458909] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,ow=
ns=3Dio+mem,locks=3Dnone
> [    0.458909] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,ow=
ns=3Dio+mem,locks=3Dnone
> [    0.460013] vgaarb: loaded
> [    0.460013] vgaarb: loaded
> [    0.460457] vgaarb: bridge control possible 0000:00:02.0
> [    0.460457] vgaarb: bridge control possible 0000:00:02.0
> [    0.462127] ACPI: bus type USB registered
> [    0.462127] ACPI: bus type USB registered
> [    0.462925] usbcore: registered new interface driver usbfs
> [    0.462925] usbcore: registered new interface driver usbfs
> [    0.463873] usbcore: registered new interface driver hub
> [    0.463873] usbcore: registered new interface driver hub
> [    0.464772] usbcore: registered new device driver usb
> [    0.464772] usbcore: registered new device driver usb
> [    0.466050] PCI: Using ACPI for IRQ routing
> [    0.466050] PCI: Using ACPI for IRQ routing
> [    0.466721] PCI: pci_cache_line_size set to 64 bytes
> [    0.466721] PCI: pci_cache_line_size set to 64 bytes
> [    0.467679] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
> [    0.467679] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
> [    0.468630] e820: reserve RAM buffer [mem 0x12be0000-0x13ffffff]
> [    0.468630] e820: reserve RAM buffer [mem 0x12be0000-0x13ffffff]
> [    0.470794] Switched to clocksource kvm-clock
> [    0.470794] Switched to clocksource kvm-clock
> [    0.471823] pnp: PnP ACPI init
> [    0.471823] pnp: PnP ACPI init
> [    0.472619] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
> [    0.472619] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
> [    0.473853] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
> [    0.473853] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
> [    0.475080] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
> [    0.475080] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
> [    0.476202] pnp 00:03: [dma 2]
> [    0.476202] pnp 00:03: [dma 2]
> [    0.476851] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
> [    0.476851] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
> [    0.478107] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
> [    0.478107] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
> [    0.479362] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
> [    0.479362] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
> [    0.480386] pnp: PnP ACPI: found 6 devices
> [    0.480386] pnp: PnP ACPI: found 6 devices
> [    0.517475] clocksource acpi_pm: mask: 0xffffff max_cycles: 0xffffff, =
max_idle_ns: 2085701024 ns
> [    0.517475] clocksource acpi_pm: mask: 0xffffff max_cycles: 0xffffff, =
max_idle_ns: 2085701024 ns
> [    0.519029] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
> [    0.519029] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
> [    0.520009] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff window]
> [    0.520009] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff window]
> [    0.520994] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff window]
> [    0.520994] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff window]
> [    0.522007] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf window]
> [    0.522007] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf window]
> [    0.522980] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff window]
> [    0.522980] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff window]
> [    0.523957] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff win=
dow]
> [    0.523957] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff win=
dow]
> [    0.525037] pci_bus 0000:00: resource 10 [mem 0x12c00000-0xfebfffff wi=
ndow]
> [    0.525037] pci_bus 0000:00: resource 10 [mem 0x12c00000-0xfebfffff wi=
ndow]
> [    0.526188] NET: Registered protocol family 1
> [    0.526188] NET: Registered protocol family 1
> [    0.526909] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
> [    0.526909] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
> [    0.527860] pci 0000:00:01.0: PIIX3: Enabling Passive Release
> [    0.527860] pci 0000:00:01.0: PIIX3: Enabling Passive Release
> [    0.528772] pci 0000:00:01.0: Activating ISA DMA hang workarounds
> [    0.528772] pci 0000:00:01.0: Activating ISA DMA hang workarounds
> [    0.529749] pci 0000:00:02.0: Video device with shadowed ROM
> [    0.529749] pci 0000:00:02.0: Video device with shadowed ROM
> [    0.530759] PCI: CLS 0 bytes, default 64
> [    0.530759] PCI: CLS 0 bytes, default 64
> [    0.532095] Unpacking initramfs...
> [    0.532095] Unpacking initramfs...
> [    1.541950] Freeing initrd memory: 24852K (d1393000 - d2bd8000)
> [    1.541950] Freeing initrd memory: 24852K (d1393000 - d2bd8000)
> [    1.543690] Scanning for low memory corruption every 60 seconds
> [    1.543690] Scanning for low memory corruption every 60 seconds
> [    1.545232] NatSemi SCx200 Driver
> [    1.545232] NatSemi SCx200 Driver
> [    1.546771] futex hash table entries: 16 (order: -3, 832 bytes)
> [    1.546771] futex hash table entries: 16 (order: -3, 832 bytes)
> [    1.547726] Initialise system trusted keyring
> [    1.547726] Initialise system trusted keyring
> [    1.677168] HugeTLB registered 2 MB page size, pre-allocated 0 pages
> [    1.677168] HugeTLB registered 2 MB page size, pre-allocated 0 pages
> [    1.678292] zbud: loaded
> [    1.678292] zbud: loaded
> [    1.678827] VFS: Disk quotas dquot_6.5.2
> [    1.678827] VFS: Disk quotas dquot_6.5.2
> [    1.679482] VFS: Dquot-cache hash table entries: 1024 (order 0, 4096 b=
ytes)
> [    1.679482] VFS: Dquot-cache hash table entries: 1024 (order 0, 4096 b=
ytes)
> [    1.683003] Key type asymmetric registered
> [    1.683003] Key type asymmetric registered
> [    1.683667] Asymmetric key parser 'x509' registered
> [    1.683667] Asymmetric key parser 'x509' registered
> [    1.684445] start plist test
> [    1.684445] start plist test
> [    1.687290] end plist test
> [    1.687290] end plist test
> [    1.704312] crc32: CRC_LE_BITS =3D 1, CRC_BE BITS =3D 1
> [    1.704312] crc32: CRC_LE_BITS =3D 1, CRC_BE BITS =3D 1
> [    1.705112] crc32: self tests passed, processed 225944 bytes in 821828=
5 nsec
> [    1.705112] crc32: self tests passed, processed 225944 bytes in 821828=
5 nsec
> [    1.714411] crc32c: CRC_LE_BITS =3D 1
> [    1.714411] crc32c: CRC_LE_BITS =3D 1
> [    1.714976] crc32c: self tests passed, processed 225944 bytes in 40688=
39 nsec
> [    1.714976] crc32c: self tests passed, processed 225944 bytes in 40688=
39 nsec
> [    2.062703] crc32_combine: 8373 self tests passed
> [    2.062703] crc32_combine: 8373 self tests passed
> [    2.407880] crc32c_combine: 8373 self tests passed
> [    2.407880] crc32c_combine: 8373 self tests passed
> [    2.409465] hgafb: HGA card not detected.
> [    2.409465] hgafb: HGA card not detected.
> [    2.410230] hgafb: probe of hgafb.0 failed with error -22
> [    2.410230] hgafb: probe of hgafb.0 failed with error -22
> [    2.411222] usbcore: registered new interface driver smscufx
> [    2.411222] usbcore: registered new interface driver smscufx
> [    2.412672] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/in=
put/input0
> [    2.412672] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/in=
put/input0
> [    2.413880] ACPI: Power Button [PWRF]
> [    2.413880] ACPI: Power Button [PWRF]
> [    2.415559] HDLC line discipline maxframe=3D4096
> [    2.415559] HDLC line discipline maxframe=3D4096
> [    2.416271] N_HDLC line discipline registered.
> [    2.416271] N_HDLC line discipline registered.
> [    2.416973] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
> [    2.416973] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
> [    2.440788] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200=
) is a 16550A
> [    2.440788] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200=
) is a 16550A
> [    2.446784] Cyclades driver 2.6
> [    2.446784] Cyclades driver 2.6
> [    2.468142] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initi=
alizing
> [    2.468142] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initi=
alizing
> [    2.469287] platform pc8736x_gpio.0: no device found
> [    2.469287] platform pc8736x_gpio.0: no device found
> [    2.470216] nsc_gpio initializing
> [    2.470216] nsc_gpio initializing
> [    2.470759] smapi::smapi_init, ERROR invalid usSmapiID
> [    2.470759] smapi::smapi_init, ERROR invalid usSmapiID
> [    2.471564] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI =
is not available on this machine
> [    2.471564] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI =
is not available on this machine
> [    2.473012] mwave: mwavedd::mwave_init: Error: Failed to initialize bo=
ard data
> [    2.473012] mwave: mwavedd::mwave_init: Error: Failed to initialize bo=
ard data
> [    2.474128] mwave: mwavedd::mwave_init: Error: Failed to initialize
> [    2.474128] mwave: mwavedd::mwave_init: Error: Failed to initialize
> [    2.475154] [drm] Initialized drm 1.1.0 20060810
> [    2.475154] [drm] Initialized drm 1.1.0 20060810
> [    2.475974] usbcore: registered new interface driver udl
> [    2.475974] usbcore: registered new interface driver udl
> [    2.478325] driver u132_hcd
> [    2.478325] driver u132_hcd
> [    2.479080] usbcore: registered new interface driver wusb-cbaf
> [    2.479080] usbcore: registered new interface driver wusb-cbaf
> [    2.480117] usbcore: registered new interface driver cdc_acm
> [    2.480117] usbcore: registered new interface driver cdc_acm
> [    2.480999] cdc_acm: USB Abstract Control Model driver for USB modems =
and ISDN adapters
> [    2.480999] cdc_acm: USB Abstract Control Model driver for USB modems =
and ISDN adapters
> [    2.482300] usbcore: registered new interface driver cdc_wdm
> [    2.482300] usbcore: registered new interface driver cdc_wdm
> [    2.483247] usbcore: registered new interface driver adutux
> [    2.483247] usbcore: registered new interface driver adutux
> [    2.484194] usbcore: registered new interface driver emi26 - firmware =
loader
> [    2.484194] usbcore: registered new interface driver emi26 - firmware =
loader
> [    2.485356] usbcore: registered new interface driver emi62 - firmware =
loader
> [    2.485356] usbcore: registered new interface driver emi62 - firmware =
loader
> [    2.486456] ftdi_elan: driver ftdi-elan
> [    2.486456] ftdi_elan: driver ftdi-elan
> [    2.487344] usbcore: registered new interface driver ftdi-elan
> [    2.487344] usbcore: registered new interface driver ftdi-elan
> [    2.488322] usbcore: registered new interface driver idmouse
> [    2.488322] usbcore: registered new interface driver idmouse
> [    2.489295] usbcore: registered new interface driver ldusb
> [    2.489295] usbcore: registered new interface driver ldusb
> [    2.490265] usbcore: registered new interface driver usbled
> [    2.490265] usbcore: registered new interface driver usbled
> [    2.491213] usbcore: registered new interface driver legousbtower
> [    2.491213] usbcore: registered new interface driver legousbtower
> [    2.492231] usbcore: registered new interface driver rio500
> [    2.492231] usbcore: registered new interface driver rio500
> [    2.493167] usbcore: registered new interface driver yurex
> [    2.493167] usbcore: registered new interface driver yurex
> [    2.494109] usbcore: registered new interface driver chaoskey
> [    2.494109] usbcore: registered new interface driver chaoskey
> [    2.495079] usbcore: registered new interface driver lvs
> [    2.495079] usbcore: registered new interface driver lvs
> [    2.496066] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0=
x60,0x64 irq 1,12
> [    2.496066] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0=
x60,0x64 irq 1,12
> [    2.498047] serio: i8042 KBD port at 0x60,0x64 irq 1
> [    2.498047] serio: i8042 KBD port at 0x60,0x64 irq 1
> [    2.498866] serio: i8042 AUX port at 0x60,0x64 irq 12
> [    2.498866] serio: i8042 AUX port at 0x60,0x64 irq 12
> [    2.535692] mousedev: PS/2 mouse device common for all mice
> [    2.535692] mousedev: PS/2 mouse device common for all mice
> [    2.536602] evbug: Connected device: input0 (Power Button at LNXPWRBN/=
button/input0)
> [    2.536602] evbug: Connected device: input0 (Power Button at LNXPWRBN/=
button/input0)
> [    2.538239] usbcore: registered new interface driver appletouch
> [    2.538239] usbcore: registered new interface driver appletouch
> [    2.539278] usbcore: registered new interface driver bcm5974
> [    2.539278] usbcore: registered new interface driver bcm5974
> [    2.540670] usbcore: registered new interface driver xpad
> [    2.540670] usbcore: registered new interface driver xpad
> [    2.541725] usbcore: registered new interface driver gtco
> [    2.541725] usbcore: registered new interface driver gtco
> [    2.542644] usbcore: registered new interface driver kbtab
> [    2.542644] usbcore: registered new interface driver kbtab
> [    2.544155] input: PC Speaker as /devices/platform/pcspkr/input/input1
> [    2.544155] input: PC Speaker as /devices/platform/pcspkr/input/input1
> [    2.545189] evbug: Connected device: input1 (PC Speaker at isa0061/inp=
ut0)
> [    2.545189] evbug: Connected device: input1 (PC Speaker at isa0061/inp=
ut0)
> [    2.546365] usbcore: registered new interface driver powermate
> [    2.546365] usbcore: registered new interface driver powermate
> [    2.548112] input: AT Translated Set 2 keyboard as /devices/platform/i=
8042/serio0/input/input2
> [    2.548112] input: AT Translated Set 2 keyboard as /devices/platform/i=
8042/serio0/input/input2
> [    2.549466] evbug: Connected device: input2 (AT Translated Set 2 keybo=
ard at isa0060/serio0/input0)
> [    2.549466] evbug: Connected device: input2 (AT Translated Set 2 keybo=
ard at isa0060/serio0/input0)
> [    2.551153] tsc: Refined TSC clocksource calibration: 2693.508 MHz
> [    2.551153] tsc: Refined TSC clocksource calibration: 2693.508 MHz
> [    2.552132] clocksource tsc: mask: 0xffffffffffffffff max_cycles: 0x26=
d349e8249, max_idle_ns: 440795288087 ns
> [    2.552132] clocksource tsc: mask: 0xffffffffffffffff max_cycles: 0x26=
d349e8249, max_idle_ns: 440795288087 ns
> [    2.553728] wistron_btns: System unknown
> [    2.553728] wistron_btns: System unknown
> [    2.555332] usbcore: registered new interface driver i2c-diolan-u2c
> [    2.555332] usbcore: registered new interface driver i2c-diolan-u2c
> [    2.556325] i2c-parport-light: adapter type unspecified
> [    2.556325] i2c-parport-light: adapter type unspecified
> [    2.557217] usbcore: registered new interface driver RobotFuzz Open So=
urce InterFace, OSIF
> [    2.557217] usbcore: registered new interface driver RobotFuzz Open So=
urce InterFace, OSIF
> [    2.558670] isa i2c-pca-isa.0: Please specify I/O base
> [    2.558670] isa i2c-pca-isa.0: Please specify I/O base
> [    2.559609] Driver for 1-wire Dallas network protocol.
> [    2.559609] Driver for 1-wire Dallas network protocol.
> [    2.560671] usbcore: registered new interface driver DS9490R
> [    2.560671] usbcore: registered new interface driver DS9490R
> [    2.561571] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
> [    2.561571] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
> [    2.562602] 1-Wire driver for the DS2760 battery monitor chip - (c) 20=
04-2005, Szabolcs Gyurko
> [    2.562602] 1-Wire driver for the DS2760 battery monitor chip - (c) 20=
04-2005, Szabolcs Gyurko
> [    2.564227] power_supply test_ac: uevent
> [    2.564227] power_supply test_ac: uevent
> [    2.564862] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
> [    2.564862] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
> [    2.565738] power_supply test_ac: prop ONLINE=3D1
> [    2.565738] power_supply test_ac: prop ONLINE=3D1
> [    2.566469] power_supply test_ac: power_supply_changed
> [    2.566469] power_supply test_ac: power_supply_changed
> [    2.567601] power_supply test_battery: uevent
> [    2.567601] power_supply test_battery: uevent
> [    2.568303] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
> [    2.568303] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
> [    2.569311] power_supply test_battery: prop STATUS=3DDischarging
> [    2.569311] power_supply test_battery: prop STATUS=3DDischarging
> [    2.570268] power_supply test_battery: prop CHARGE_TYPE=3DFast
> [    2.570268] power_supply test_battery: prop CHARGE_TYPE=3DFast
> [    2.571157] power_supply test_battery: prop HEALTH=3DGood
> [    2.571157] power_supply test_battery: prop HEALTH=3DGood
> [    2.571980] power_supply test_battery: prop PRESENT=3D1
> [    2.571980] power_supply test_battery: prop PRESENT=3D1
> [    2.572772] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
> [    2.572772] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
> [    2.573668] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
> [    2.573668] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
> [    2.574647] power_supply test_battery: prop CHARGE_FULL=3D100
> [    2.574647] power_supply test_battery: prop CHARGE_FULL=3D100
> [    2.575521] power_supply test_battery: prop CHARGE_NOW=3D50
> [    2.575521] power_supply test_battery: prop CHARGE_NOW=3D50
> [    2.576382] power_supply test_battery: prop CAPACITY=3D50
> [    2.576382] power_supply test_battery: prop CAPACITY=3D50
> [    2.577202] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
> [    2.577202] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
> [    2.578169] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
> [    2.578169] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
> [    2.579144] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
> [    2.579144] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
> [    2.580145] power_supply test_battery: prop MODEL_NAME=3DTest battery
> [    2.580145] power_supply test_battery: prop MODEL_NAME=3DTest battery
> [    2.581123] power_supply test_battery: prop MANUFACTURER=3DLinux
> [    2.581123] power_supply test_battery: prop MANUFACTURER=3DLinux
> [    2.582054] power_supply test_battery: prop SERIAL_NUMBER=3D4.0.0-0581=
9-g2813893
> [    2.582054] power_supply test_battery: prop SERIAL_NUMBER=3D4.0.0-0581=
9-g2813893
> [    2.583191] power_supply test_battery: prop TEMP=3D26
> [    2.583191] power_supply test_battery: prop TEMP=3D26
> [    2.583964] power_supply test_battery: prop VOLTAGE_NOW=3D3300
> [    2.583964] power_supply test_battery: prop VOLTAGE_NOW=3D3300
> [    2.585011] power_supply test_battery: power_supply_changed
> [    2.585011] power_supply test_battery: power_supply_changed
> [    2.586078] power_supply test_usb: uevent
> [    2.586078] power_supply test_usb: uevent
> [    2.586716] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
> [    2.586716] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
> [    2.587622] power_supply test_usb: prop ONLINE=3D1
> [    2.587622] power_supply test_usb: prop ONLINE=3D1
> [    2.588361] power_supply test_usb: power_supply_changed
> [    2.588361] power_supply test_usb: power_supply_changed
> [    2.590780] dcdbas dcdbas: Dell Systems Management Base Driver (versio=
n 5.6.0-3.2)
> [    2.590780] dcdbas dcdbas: Dell Systems Management Base Driver (versio=
n 5.6.0-3.2)
> [    2.592958] FPGA DOWNLOAD --->
> [    2.592958] FPGA DOWNLOAD --->
> [    2.593444] FPGA image file name: xlinx_fpga_firmware.bit
> [    2.593444] FPGA image file name: xlinx_fpga_firmware.bit
> [    2.594427] GPIO INIT FAIL!!
> [    2.594427] GPIO INIT FAIL!!
> [    2.595183] power_supply test_ac: power_supply_changed_work
> [    2.595183] power_supply test_ac: power_supply_changed_work
> [    2.596081] power_supply test_ac: uevent
> [    2.596081] power_supply test_ac: uevent
> [    2.596698] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
> [    2.596698] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
> [    2.597577] power_supply test_ac: prop ONLINE=3D1
> [    2.597577] power_supply test_ac: prop ONLINE=3D1
> [    2.598305] power_supply test_battery: power_supply_changed_work
> [    2.598305] power_supply test_battery: power_supply_changed_work
> [    2.599282] power_supply test_battery: uevent
> [    2.599282] power_supply test_battery: uevent
> [    2.599967] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
> [    2.599967] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
> [    2.600994] power_supply test_battery: prop STATUS=3DDischarging
> [    2.600994] power_supply test_battery: prop STATUS=3DDischarging
> [    2.601920] power_supply test_battery: prop CHARGE_TYPE=3DFast
> [    2.601920] power_supply test_battery: prop CHARGE_TYPE=3DFast
> [    2.602801] power_supply test_battery: prop HEALTH=3DGood
> [    2.602801] power_supply test_battery: prop HEALTH=3DGood
> [    2.603614] power_supply test_battery: prop PRESENT=3D1
> [    2.603614] power_supply test_battery: prop PRESENT=3D1
> [    2.604403] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
> [    2.604403] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
> [    2.605301] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
> [    2.605301] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
> [    2.606275] power_supply test_battery: prop CHARGE_FULL=3D100
> [    2.606275] power_supply test_battery: prop CHARGE_FULL=3D100
> [    2.607145] power_supply test_battery: prop CHARGE_NOW=3D50
> [    2.607145] power_supply test_battery: prop CHARGE_NOW=3D50
> [    2.607999] power_supply test_battery: prop CAPACITY=3D50
> [    2.607999] power_supply test_battery: prop CAPACITY=3D50
> [    2.608818] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
> [    2.608818] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
> [    2.609789] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
> [    2.609789] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
> [    2.611137] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
> [    2.611137] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
> [    2.612143] power_supply test_battery: prop MODEL_NAME=3DTest battery
> [    2.612143] power_supply test_battery: prop MODEL_NAME=3DTest battery
> [    2.613135] power_supply test_battery: prop MANUFACTURER=3DLinux
> [    2.613135] power_supply test_battery: prop MANUFACTURER=3DLinux
> [    2.614046] power_supply test_battery: prop SERIAL_NUMBER=3D4.0.0-0581=
9-g2813893
> [    2.614046] power_supply test_battery: prop SERIAL_NUMBER=3D4.0.0-0581=
9-g2813893
> [    2.615176] power_supply test_battery: prop TEMP=3D26
> [    2.615176] power_supply test_battery: prop TEMP=3D26
> [    2.615947] power_supply test_battery: prop VOLTAGE_NOW=3D3300
> [    2.615947] power_supply test_battery: prop VOLTAGE_NOW=3D3300
> [    2.616934] power_supply test_usb: power_supply_changed_work
> [    2.616934] power_supply test_usb: power_supply_changed_work
> [    2.617834] power_supply test_usb: uevent
> [    2.617834] power_supply test_usb: uevent
> [    2.618461] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
> [    2.618461] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
> [    2.619349] power_supply test_usb: prop ONLINE=3D1
> [    2.619349] power_supply test_usb: prop ONLINE=3D1
> [    2.621360] bootconsole [earlyser0] disabled
> [    2.621360] bootconsole [earlyser0] disabled
> [    2.622083] Loading compiled-in X.509 certificates
> [    2.627835] Loaded X.509 cert 'Magrathea: Glacier signing key: c251bf8=
ae0681a79ad6afff17cbd53c67bc2662c'
> [    2.629787] Key type encrypted registered
> [    2.631010]   Magic number: 15:743:581
> [    2.631531] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
> [    2.632019] EDD information not available.
> [    2.633108] Freeing unused kernel memory: 564K (c1bc3000 - c1c50000)
> [    2.642276] random: init urandom read with 4 bits of entropy available
> [    2.643278] BUG: unable to handle kernel paging request at ffffffee
> [    2.643807] IP: [<c11ed93e>] devpts_new_index+0x25/0x1bd
> [    2.644249] *pdpt =3D 0000000001c50001 *pde =3D 0000000001c51063 *pte =
=3D 0000000000000000=20
> [    2.644897] Oops: 0000 [#1]=20
> [    2.645141] Modules linked in:
> [    2.645400] CPU: 0 PID: 1 Comm: init Not tainted 4.0.0-05819-g2813893 =
#11
> [    2.645932] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S 1.7.5-20140531_083030-gandalf 04/01/2014
> [    2.646719] task: d084c010 ti: d084e000 task.ti: d084e000
> [    2.647147] EIP: 0060:[<c11ed93e>] EFLAGS: 00010246 CPU: 0
> [    2.647579] EIP is at devpts_new_index+0x25/0x1bd
> [    2.647964] EAX: ffffffea EBX: 00000000 ECX: c1384a75 EDX: 00000000
> [    2.648455] ESI: c23afc38 EDI: cd284cc0 EBP: d084fe00 ESP: d084fdf4
> [    2.648967]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
> [    2.649393] CR0: 80050033 CR2: ffffffee CR3: 124432e0 CR4: 000006b0
> [    2.649891] Stack:
> [    2.650047]  c1384a75 00000000 c23afc38 d084fe18 c1384a8b d0426b60 000=
00000 c23afc38
> [    2.650047]  d0426b60 d084fe38 c1172c22 00000000 cd284cc0 00000000 cd2=
84cc0 d0426b60
> [    2.650047]  00000000 d084fe58 c1169521 00000026 cd284cc8 c11729de cd2=
84cc0 d084ff04
> [    2.650047] Call Trace:
> [    2.650047]  [<c1384a75>] ? ptmx_open+0x6b/0x28b
> [    2.650047]  [<c1384a8b>] ptmx_open+0x81/0x28b
> [    2.650047]  [<c1172c22>] chrdev_open+0x244/0x270
> [    2.650047]  [<c1169521>] do_dentry_open+0x358/0x512
> [    2.650047]  [<c11729de>] ? cdev_put+0x38/0x38
> [    2.650047]  [<c1169739>] vfs_open+0x5e/0x71
> [    2.650047]  [<c1181c8f>] do_last+0xa34/0xde9
> [    2.650047]  [<c11823b1>] path_openat+0x36d/0x89b
> [    2.650047]  [<c1183c10>] do_filp_open+0x33/0xb4
> [    2.650047]  [<c11981ba>] ? __alloc_fd+0x1b5/0x1cd
> [    2.650047]  [<c116b2cf>] do_sys_open+0x22e/0x31e
> [    2.650047]  [<c11982dd>] ? fd_install+0x28/0x39
> [    2.650047]  [<c116b3e5>] SyS_open+0x26/0x44
> [    2.650047]  [<c162f782>] sysenter_do_call+0x12/0x12
> [    2.650047] Code: f4 5b 5e 5f 5d c3 55 89 e5 56 53 51 8b 40 14 81 78 3=
4 d1 1c 00 00 74 16 a1 50 8e 31 c2 83 05 c0 8b 31 c2 01 83 15 c4 8b 31 c2 0=
0 <8b> 40 04 83 05 c8 8b 31 c2 01 83 15 cc 8b 31 c2 00 8b 98 d0 02
> [    2.650047] EIP: [<c11ed93e>] devpts_new_index+0x25/0x1bd SS:ESP 0068:=
d084fdf4
> [    2.650047] CR2: 00000000ffffffee
> [    2.650047] ---[ end trace e7d6454dfe4d6c7f ]---
> [    2.650047] Kernel panic - not syncing: Fatal exception
> [    2.650047] Kernel Offset: disabled
>=20
> Elapsed time: 5
> qemu-system-x86_64 -enable-kvm -cpu kvm64 -kernel /kernel/i386-randconfig=
-r1-0505/2813893f8b197a14f1e1ddb04d99bce46817c84a/vmlinuz-4.0.0-05819-g2813=
893 -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 rd.udev.log-pri=
ority=3Derr systemd.log_target=3Djournal systemd.log_level=3Dwarning debug =
apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 pani=
c=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=
=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal =
 root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-r1-=
0505/tip:tmp.fpu:2813893f8b197a14f1e1ddb04d99bce46817c84a:bisect-linux-5/.v=
mlinuz-2813893f8b197a14f1e1ddb04d99bce46817c84a-20150506123323-20-ivb41 bra=
nch=3Dtip/tmp.fpu BOOT_IMAGE=3D/kernel/i386-randconfig-r1-0505/2813893f8b19=
7a14f1e1ddb04d99bce46817c84a/vmlinuz-4.0.0-05819-g2813893 drbd.minor_count=
=3D8'  -initrd /kernel-tests/initrd/quantal-core-i386.cgz -m 300 -smp 2 -de=
vice e1000,netdev=3Dnet0 -netdev user,id=3Dnet0 -boot order=3Dnc -no-reboot=
 -watchdog i6300esb -rtc base=3Dlocaltime -drive file=3D/fs/vdisk/disk0-qua=
ntal-ivb41-96,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/vdisk/disk1-quanta=
l-ivb41-96,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/vdisk/disk2-quantal-i=
vb41-96,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/vdisk/disk3-quantal-ivb4=
1-96,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/vdisk/disk4-quantal-ivb41-9=
6,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/vdisk/disk5-quantal-ivb41-96,m=
edia=3Ddisk,if=3Dvirtio -drive file=3D/fs/vdisk/disk6-quantal-ivb41-96,medi=
a=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-quantal-ivb41-96 -serial f=
ile:/dev/shm/kboot/serial-quantal-ivb41-96 -daemonize -display none -monito=
r null=20

> #
> # Automatically generated file; DO NOT EDIT.
> # Linux/i386 4.0.0 Kernel Configuration
> #
> # CONFIG_64BIT is not set
> CONFIG_X86_32=3Dy
> CONFIG_X86=3Dy
> CONFIG_INSTRUCTION_DECODER=3Dy
> CONFIG_OUTPUT_FORMAT=3D"elf32-i386"
> CONFIG_ARCH_DEFCONFIG=3D"arch/x86/configs/i386_defconfig"
> CONFIG_LOCKDEP_SUPPORT=3Dy
> CONFIG_STACKTRACE_SUPPORT=3Dy
> CONFIG_HAVE_LATENCYTOP_SUPPORT=3Dy
> CONFIG_MMU=3Dy
> CONFIG_NEED_SG_DMA_LENGTH=3Dy
> CONFIG_GENERIC_ISA_DMA=3Dy
> CONFIG_GENERIC_BUG=3Dy
> CONFIG_GENERIC_HWEIGHT=3Dy
> CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
> CONFIG_RWSEM_XCHGADD_ALGORITHM=3Dy
> CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
> CONFIG_ARCH_HAS_CPU_RELAX=3Dy
> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=3Dy
> CONFIG_HAVE_SETUP_PER_CPU_AREA=3Dy
> CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=3Dy
> CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=3Dy
> CONFIG_ARCH_HIBERNATION_POSSIBLE=3Dy
> CONFIG_ARCH_SUSPEND_POSSIBLE=3Dy
> CONFIG_ARCH_WANT_HUGE_PMD_SHARE=3Dy
> CONFIG_ARCH_WANT_GENERAL_HUGETLB=3Dy
> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=3Dy
> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=3Dy
> CONFIG_ARCH_HWEIGHT_CFLAGS=3D"-fcall-saved-ecx -fcall-saved-edx"
> CONFIG_ARCH_SUPPORTS_UPROBES=3Dy
> CONFIG_FIX_EARLYCON_MEM=3Dy
> CONFIG_PGTABLE_LEVELS=3D3
> CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"
> CONFIG_CONSTRUCTORS=3Dy
> CONFIG_IRQ_WORK=3Dy
> CONFIG_BUILDTIME_EXTABLE_SORT=3Dy
>=20
> #
> # General setup
> #
> CONFIG_BROKEN_ON_SMP=3Dy
> CONFIG_INIT_ENV_ARG_LIMIT=3D32
> CONFIG_CROSS_COMPILE=3D""
> # CONFIG_COMPILE_TEST is not set
> CONFIG_LOCALVERSION=3D""
> CONFIG_LOCALVERSION_AUTO=3Dy
> CONFIG_HAVE_KERNEL_GZIP=3Dy
> CONFIG_HAVE_KERNEL_BZIP2=3Dy
> CONFIG_HAVE_KERNEL_LZMA=3Dy
> CONFIG_HAVE_KERNEL_XZ=3Dy
> CONFIG_HAVE_KERNEL_LZO=3Dy
> CONFIG_HAVE_KERNEL_LZ4=3Dy
> # CONFIG_KERNEL_GZIP is not set
> # CONFIG_KERNEL_BZIP2 is not set
> CONFIG_KERNEL_LZMA=3Dy
> # CONFIG_KERNEL_XZ is not set
> # CONFIG_KERNEL_LZO is not set
> # CONFIG_KERNEL_LZ4 is not set
> CONFIG_DEFAULT_HOSTNAME=3D"(none)"
> CONFIG_SYSVIPC=3Dy
> CONFIG_SYSVIPC_SYSCTL=3Dy
> # CONFIG_POSIX_MQUEUE is not set
> CONFIG_CROSS_MEMORY_ATTACH=3Dy
> CONFIG_FHANDLE=3Dy
> CONFIG_USELIB=3Dy
> # CONFIG_AUDIT is not set
> CONFIG_HAVE_ARCH_AUDITSYSCALL=3Dy
>=20
> #
> # IRQ subsystem
> #
> CONFIG_GENERIC_IRQ_PROBE=3Dy
> CONFIG_GENERIC_IRQ_SHOW=3Dy
> CONFIG_IRQ_DOMAIN=3Dy
> CONFIG_IRQ_DOMAIN_DEBUG=3Dy
> CONFIG_IRQ_FORCED_THREADING=3Dy
> CONFIG_SPARSE_IRQ=3Dy
> CONFIG_CLOCKSOURCE_WATCHDOG=3Dy
> CONFIG_ARCH_CLOCKSOURCE_DATA=3Dy
> CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=3Dy
> CONFIG_GENERIC_TIME_VSYSCALL=3Dy
> CONFIG_GENERIC_CLOCKEVENTS=3Dy
> CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=3Dy
> CONFIG_GENERIC_CMOS_UPDATE=3Dy
>=20
> #
> # Timers subsystem
> #
> CONFIG_TICK_ONESHOT=3Dy
> CONFIG_NO_HZ_COMMON=3Dy
> # CONFIG_HZ_PERIODIC is not set
> CONFIG_NO_HZ_IDLE=3Dy
> # CONFIG_NO_HZ is not set
> CONFIG_HIGH_RES_TIMERS=3Dy
>=20
> #
> # CPU/Task time and stats accounting
> #
> CONFIG_TICK_CPU_ACCOUNTING=3Dy
> # CONFIG_IRQ_TIME_ACCOUNTING is not set
>=20
> #
> # RCU Subsystem
> #
> CONFIG_TINY_RCU=3Dy
> CONFIG_SRCU=3Dy
> # CONFIG_TASKS_RCU is not set
> CONFIG_RCU_STALL_COMMON=3Dy
> # CONFIG_TREE_RCU_TRACE is not set
> CONFIG_RCU_KTHREAD_PRIO=3D0
> # CONFIG_RCU_EXPEDITE_BOOT is not set
> CONFIG_BUILD_BIN2C=3Dy
> CONFIG_IKCONFIG=3Dy
> CONFIG_IKCONFIG_PROC=3Dy
> CONFIG_LOG_BUF_SHIFT=3D17
> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=3Dy
> CONFIG_CGROUPS=3Dy
> CONFIG_CGROUP_DEBUG=3Dy
> # CONFIG_CGROUP_FREEZER is not set
> # CONFIG_CGROUP_DEVICE is not set
> CONFIG_CPUSETS=3Dy
> # CONFIG_PROC_PID_CPUSET is not set
> # CONFIG_CGROUP_CPUACCT is not set
> CONFIG_PAGE_COUNTER=3Dy
> CONFIG_MEMCG=3Dy
> # CONFIG_MEMCG_KMEM is not set
> CONFIG_CGROUP_HUGETLB=3Dy
> CONFIG_CGROUP_PERF=3Dy
> CONFIG_CGROUP_SCHED=3Dy
> CONFIG_FAIR_GROUP_SCHED=3Dy
> CONFIG_CFS_BANDWIDTH=3Dy
> # CONFIG_RT_GROUP_SCHED is not set
> # CONFIG_CHECKPOINT_RESTORE is not set
> CONFIG_SCHED_AUTOGROUP=3Dy
> # CONFIG_SYSFS_DEPRECATED is not set
> CONFIG_RELAY=3Dy
> CONFIG_BLK_DEV_INITRD=3Dy
> CONFIG_INITRAMFS_SOURCE=3D""
> CONFIG_RD_GZIP=3Dy
> CONFIG_RD_BZIP2=3Dy
> CONFIG_RD_LZMA=3Dy
> CONFIG_RD_XZ=3Dy
> CONFIG_RD_LZO=3Dy
> CONFIG_RD_LZ4=3Dy
> CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy
> CONFIG_SYSCTL=3Dy
> CONFIG_ANON_INODES=3Dy
> CONFIG_HAVE_UID16=3Dy
> CONFIG_SYSCTL_EXCEPTION_TRACE=3Dy
> CONFIG_HAVE_PCSPKR_PLATFORM=3Dy
> CONFIG_BPF=3Dy
> CONFIG_EXPERT=3Dy
> # CONFIG_MULTIUSER is not set
> # CONFIG_SGETMASK_SYSCALL is not set
> # CONFIG_SYSFS_SYSCALL is not set
> # CONFIG_SYSCTL_SYSCALL is not set
> CONFIG_KALLSYMS=3Dy
> CONFIG_KALLSYMS_ALL=3Dy
> CONFIG_PRINTK=3Dy
> CONFIG_BUG=3Dy
> # CONFIG_ELF_CORE is not set
> CONFIG_PCSPKR_PLATFORM=3Dy
> # CONFIG_BASE_FULL is not set
> CONFIG_FUTEX=3Dy
> CONFIG_EPOLL=3Dy
> CONFIG_SIGNALFD=3Dy
> CONFIG_TIMERFD=3Dy
> CONFIG_EVENTFD=3Dy
> # CONFIG_BPF_SYSCALL is not set
> # CONFIG_SHMEM is not set
> # CONFIG_AIO is not set
> CONFIG_ADVISE_SYSCALLS=3Dy
> CONFIG_PCI_QUIRKS=3Dy
> CONFIG_EMBEDDED=3Dy
> CONFIG_HAVE_PERF_EVENTS=3Dy
>=20
> #
> # Kernel Performance Events And Counters
> #
> CONFIG_PERF_EVENTS=3Dy
> # CONFIG_DEBUG_PERF_USE_VMALLOC is not set
> # CONFIG_VM_EVENT_COUNTERS is not set
> CONFIG_COMPAT_BRK=3Dy
> CONFIG_SLAB=3Dy
> # CONFIG_SLUB is not set
> # CONFIG_SLOB is not set
> CONFIG_SYSTEM_TRUSTED_KEYRING=3Dy
> # CONFIG_PROFILING is not set
> CONFIG_HAVE_OPROFILE=3Dy
> CONFIG_OPROFILE_NMI_TIMER=3Dy
> CONFIG_KPROBES=3Dy
> # CONFIG_JUMP_LABEL is not set
> CONFIG_OPTPROBES=3Dy
> # CONFIG_UPROBES is not set
> # CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=3Dy
> CONFIG_ARCH_USE_BUILTIN_BSWAP=3Dy
> CONFIG_KRETPROBES=3Dy
> CONFIG_HAVE_IOREMAP_PROT=3Dy
> CONFIG_HAVE_KPROBES=3Dy
> CONFIG_HAVE_KRETPROBES=3Dy
> CONFIG_HAVE_OPTPROBES=3Dy
> CONFIG_HAVE_KPROBES_ON_FTRACE=3Dy
> CONFIG_HAVE_ARCH_TRACEHOOK=3Dy
> CONFIG_HAVE_DMA_ATTRS=3Dy
> CONFIG_HAVE_DMA_CONTIGUOUS=3Dy
> CONFIG_GENERIC_SMP_IDLE_THREAD=3Dy
> CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=3Dy
> CONFIG_HAVE_DMA_API_DEBUG=3Dy
> CONFIG_HAVE_HW_BREAKPOINT=3Dy
> CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=3Dy
> CONFIG_HAVE_USER_RETURN_NOTIFIER=3Dy
> CONFIG_HAVE_PERF_EVENTS_NMI=3Dy
> CONFIG_HAVE_PERF_REGS=3Dy
> CONFIG_HAVE_PERF_USER_STACK_DUMP=3Dy
> CONFIG_HAVE_ARCH_JUMP_LABEL=3Dy
> CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=3Dy
> CONFIG_HAVE_CMPXCHG_LOCAL=3Dy
> CONFIG_HAVE_CMPXCHG_DOUBLE=3Dy
> CONFIG_ARCH_WANT_IPC_PARSE_VERSION=3Dy
> CONFIG_HAVE_ARCH_SECCOMP_FILTER=3Dy
> CONFIG_HAVE_CC_STACKPROTECTOR=3Dy
> CONFIG_CC_STACKPROTECTOR=3Dy
> # CONFIG_CC_STACKPROTECTOR_NONE is not set
> CONFIG_CC_STACKPROTECTOR_REGULAR=3Dy
> # CONFIG_CC_STACKPROTECTOR_STRONG is not set
> CONFIG_HAVE_IRQ_TIME_ACCOUNTING=3Dy
> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=3Dy
> CONFIG_HAVE_ARCH_HUGE_VMAP=3Dy
> CONFIG_MODULES_USE_ELF_REL=3Dy
> CONFIG_ARCH_HAS_ELF_RANDOMIZE=3Dy
> CONFIG_CLONE_BACKWARDS=3Dy
> CONFIG_OLD_SIGSUSPEND3=3Dy
> CONFIG_OLD_SIGACTION=3Dy
>=20
> #
> # GCOV-based kernel profiling
> #
> CONFIG_GCOV_KERNEL=3Dy
> CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=3Dy
> CONFIG_GCOV_PROFILE_ALL=3Dy
> # CONFIG_GCOV_FORMAT_AUTODETECT is not set
> # CONFIG_GCOV_FORMAT_3_4 is not set
> CONFIG_GCOV_FORMAT_4_7=3Dy
> CONFIG_HAVE_GENERIC_DMA_COHERENT=3Dy
> CONFIG_SLABINFO=3Dy
> CONFIG_RT_MUTEXES=3Dy
> CONFIG_BASE_SMALL=3D1
> CONFIG_MODULES=3Dy
> # CONFIG_MODULE_FORCE_LOAD is not set
> # CONFIG_MODULE_UNLOAD is not set
> CONFIG_MODVERSIONS=3Dy
> # CONFIG_MODULE_SRCVERSION_ALL is not set
> CONFIG_MODULE_SIG=3Dy
> CONFIG_MODULE_SIG_FORCE=3Dy
> CONFIG_MODULE_SIG_ALL=3Dy
> # CONFIG_MODULE_SIG_SHA1 is not set
> CONFIG_MODULE_SIG_SHA224=3Dy
> # CONFIG_MODULE_SIG_SHA256 is not set
> # CONFIG_MODULE_SIG_SHA384 is not set
> # CONFIG_MODULE_SIG_SHA512 is not set
> CONFIG_MODULE_SIG_HASH=3D"sha224"
> # CONFIG_MODULE_COMPRESS is not set
> # CONFIG_BLOCK is not set
> CONFIG_ASN1=3Dy
> CONFIG_UNINLINE_SPIN_UNLOCK=3Dy
> CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=3Dy
> CONFIG_ARCH_USE_QUEUE_RWLOCK=3Dy
> CONFIG_FREEZER=3Dy
>=20
> #
> # Processor type and features
> #
> CONFIG_ZONE_DMA=3Dy
> # CONFIG_SMP is not set
> CONFIG_X86_FEATURE_NAMES=3Dy
> CONFIG_X86_EXTENDED_PLATFORM=3Dy
> # CONFIG_X86_GOLDFISH is not set
> # CONFIG_X86_INTEL_LPSS is not set
> # CONFIG_X86_AMD_PLATFORM_DEVICE is not set
> # CONFIG_IOSF_MBI is not set
> CONFIG_X86_RDC321X=3Dy
> CONFIG_X86_32_IRIS=3Dm
> # CONFIG_SCHED_OMIT_FRAME_POINTER is not set
> CONFIG_HYPERVISOR_GUEST=3Dy
> CONFIG_PARAVIRT=3Dy
> # CONFIG_PARAVIRT_DEBUG is not set
> # CONFIG_XEN is not set
> CONFIG_KVM_GUEST=3Dy
> # CONFIG_KVM_DEBUG_FS is not set
> # CONFIG_LGUEST_GUEST is not set
> # CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
> CONFIG_PARAVIRT_CLOCK=3Dy
> CONFIG_NO_BOOTMEM=3Dy
> # CONFIG_M486 is not set
> # CONFIG_M586 is not set
> # CONFIG_M586TSC is not set
> # CONFIG_M586MMX is not set
> # CONFIG_M686 is not set
> # CONFIG_MPENTIUMII is not set
> # CONFIG_MPENTIUMIII is not set
> # CONFIG_MPENTIUMM is not set
> # CONFIG_MPENTIUM4 is not set
> # CONFIG_MK6 is not set
> # CONFIG_MK7 is not set
> # CONFIG_MK8 is not set
> # CONFIG_MCRUSOE is not set
> # CONFIG_MEFFICEON is not set
> # CONFIG_MWINCHIPC6 is not set
> # CONFIG_MWINCHIP3D is not set
> # CONFIG_MELAN is not set
> CONFIG_MGEODEGX1=3Dy
> # CONFIG_MGEODE_LX is not set
> # CONFIG_MCYRIXIII is not set
> # CONFIG_MVIAC3_2 is not set
> # CONFIG_MVIAC7 is not set
> # CONFIG_MCORE2 is not set
> # CONFIG_MATOM is not set
> CONFIG_X86_GENERIC=3Dy
> CONFIG_X86_INTERNODE_CACHE_SHIFT=3D6
> CONFIG_X86_L1_CACHE_SHIFT=3D6
> CONFIG_X86_PPRO_FENCE=3Dy
> CONFIG_X86_ALIGNMENT_16=3Dy
> CONFIG_X86_INTEL_USERCOPY=3Dy
> CONFIG_X86_TSC=3Dy
> CONFIG_X86_CMPXCHG64=3Dy
> CONFIG_X86_MINIMUM_CPU_FAMILY=3D5
> CONFIG_X86_DEBUGCTLMSR=3Dy
> CONFIG_PROCESSOR_SELECT=3Dy
> # CONFIG_CPU_SUP_INTEL is not set
> CONFIG_CPU_SUP_CYRIX_32=3Dy
> CONFIG_CPU_SUP_AMD=3Dy
> CONFIG_CPU_SUP_CENTAUR=3Dy
> # CONFIG_CPU_SUP_TRANSMETA_32 is not set
> # CONFIG_CPU_SUP_UMC_32 is not set
> CONFIG_HPET_TIMER=3Dy
> CONFIG_DMI=3Dy
> CONFIG_NR_CPUS=3D1
> CONFIG_PREEMPT_NONE=3Dy
> # CONFIG_PREEMPT_VOLUNTARY is not set
> # CONFIG_PREEMPT is not set
> CONFIG_PREEMPT_COUNT=3Dy
> # CONFIG_X86_UP_APIC is not set
> # CONFIG_X86_MCE is not set
> CONFIG_VM86=3Dy
> CONFIG_X86_16BIT=3Dy
> CONFIG_X86_ESPFIX32=3Dy
> CONFIG_TOSHIBA=3Dm
> CONFIG_I8K=3Dm
> CONFIG_X86_REBOOTFIXUPS=3Dy
> # CONFIG_MICROCODE is not set
> # CONFIG_X86_MSR is not set
> CONFIG_X86_CPUID=3Dy
> # CONFIG_NOHIGHMEM is not set
> # CONFIG_HIGHMEM4G is not set
> CONFIG_HIGHMEM64G=3Dy
> CONFIG_VMSPLIT_3G=3Dy
> # CONFIG_VMSPLIT_2G is not set
> # CONFIG_VMSPLIT_1G is not set
> CONFIG_PAGE_OFFSET=3D0xC0000000
> CONFIG_HIGHMEM=3Dy
> CONFIG_X86_PAE=3Dy
> CONFIG_ARCH_PHYS_ADDR_T_64BIT=3Dy
> CONFIG_ARCH_DMA_ADDR_T_64BIT=3Dy
> CONFIG_NEED_NODE_MEMMAP_SIZE=3Dy
> CONFIG_ARCH_FLATMEM_ENABLE=3Dy
> CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
> CONFIG_ARCH_SELECT_MEMORY_MODEL=3Dy
> CONFIG_ILLEGAL_POINTER_VALUE=3D0
> CONFIG_SELECT_MEMORY_MODEL=3Dy
> # CONFIG_FLATMEM_MANUAL is not set
> CONFIG_SPARSEMEM_MANUAL=3Dy
> CONFIG_SPARSEMEM=3Dy
> CONFIG_HAVE_MEMORY_PRESENT=3Dy
> CONFIG_SPARSEMEM_STATIC=3Dy
> CONFIG_HAVE_MEMBLOCK=3Dy
> CONFIG_HAVE_MEMBLOCK_NODE_MAP=3Dy
> CONFIG_ARCH_DISCARD_MEMBLOCK=3Dy
> CONFIG_MEMORY_ISOLATION=3Dy
> # CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
> # CONFIG_MEMORY_HOTPLUG is not set
> CONFIG_SPLIT_PTLOCK_CPUS=3D4
> CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=3Dy
> CONFIG_COMPACTION=3Dy
> CONFIG_MIGRATION=3Dy
> CONFIG_PHYS_ADDR_T_64BIT=3Dy
> CONFIG_ZONE_DMA_FLAG=3D1
> CONFIG_VIRT_TO_BUS=3Dy
> CONFIG_KSM=3Dy
> CONFIG_DEFAULT_MMAP_MIN_ADDR=3D4096
> # CONFIG_TRANSPARENT_HUGEPAGE is not set
> CONFIG_NEED_PER_CPU_KM=3Dy
> CONFIG_CLEANCACHE=3Dy
> CONFIG_CMA=3Dy
> CONFIG_CMA_DEBUG=3Dy
> CONFIG_CMA_DEBUGFS=3Dy
> CONFIG_CMA_AREAS=3D7
> # CONFIG_ZPOOL is not set
> CONFIG_ZBUD=3Dy
> # CONFIG_ZSMALLOC is not set
> CONFIG_GENERIC_EARLY_IOREMAP=3Dy
> # CONFIG_HIGHPTE is not set
> CONFIG_X86_CHECK_BIOS_CORRUPTION=3Dy
> CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=3Dy
> CONFIG_X86_RESERVE_LOW=3D64
> # CONFIG_MATH_EMULATION is not set
> # CONFIG_MTRR is not set
> # CONFIG_ARCH_RANDOM is not set
> CONFIG_X86_SMAP=3Dy
> # CONFIG_EFI is not set
> # CONFIG_SECCOMP is not set
> CONFIG_HZ_100=3Dy
> # CONFIG_HZ_250 is not set
> # CONFIG_HZ_300 is not set
> # CONFIG_HZ_1000 is not set
> CONFIG_HZ=3D100
> CONFIG_SCHED_HRTICK=3Dy
> # CONFIG_KEXEC is not set
> # CONFIG_CRASH_DUMP is not set
> CONFIG_PHYSICAL_START=3D0x1000000
> CONFIG_RELOCATABLE=3Dy
> # CONFIG_RANDOMIZE_BASE is not set
> CONFIG_X86_NEED_RELOCS=3Dy
> CONFIG_PHYSICAL_ALIGN=3D0x200000
> # CONFIG_COMPAT_VDSO is not set
> # CONFIG_CMDLINE_BOOL is not set
> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy
>=20
> #
> # Power management and ACPI options
> #
> CONFIG_SUSPEND=3Dy
> CONFIG_SUSPEND_FREEZER=3Dy
> CONFIG_PM_SLEEP=3Dy
> # CONFIG_PM_AUTOSLEEP is not set
> # CONFIG_PM_WAKELOCKS is not set
> CONFIG_PM=3Dy
> CONFIG_PM_DEBUG=3Dy
> CONFIG_PM_ADVANCED_DEBUG=3Dy
> # CONFIG_PM_TEST_SUSPEND is not set
> CONFIG_PM_SLEEP_DEBUG=3Dy
> CONFIG_PM_TRACE=3Dy
> CONFIG_PM_TRACE_RTC=3Dy
> CONFIG_WQ_POWER_EFFICIENT_DEFAULT=3Dy
> CONFIG_ACPI=3Dy
> CONFIG_ACPI_LEGACY_TABLES_LOOKUP=3Dy
> CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=3Dy
> CONFIG_ACPI_SLEEP=3Dy
> # CONFIG_ACPI_PROCFS_POWER is not set
> # CONFIG_ACPI_EC_DEBUGFS is not set
> CONFIG_ACPI_AC=3Dy
> CONFIG_ACPI_BATTERY=3Dy
> CONFIG_ACPI_BUTTON=3Dy
> # CONFIG_ACPI_VIDEO is not set
> CONFIG_ACPI_FAN=3Dy
> # CONFIG_ACPI_DOCK is not set
> CONFIG_ACPI_PROCESSOR=3Dy
> # CONFIG_ACPI_IPMI is not set
> # CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
> CONFIG_ACPI_THERMAL=3Dy
> # CONFIG_ACPI_CUSTOM_DSDT is not set
> # CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
> # CONFIG_ACPI_DEBUG is not set
> # CONFIG_ACPI_PCI_SLOT is not set
> CONFIG_X86_PM_TIMER=3Dy
> # CONFIG_ACPI_CONTAINER is not set
> # CONFIG_ACPI_SBS is not set
> # CONFIG_ACPI_HED is not set
> # CONFIG_ACPI_CUSTOM_METHOD is not set
> # CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
> CONFIG_HAVE_ACPI_APEI=3Dy
> CONFIG_HAVE_ACPI_APEI_NMI=3Dy
> # CONFIG_ACPI_APEI is not set
> # CONFIG_PMIC_OPREGION is not set
> CONFIG_SFI=3Dy
> CONFIG_X86_APM_BOOT=3Dy
> CONFIG_APM=3Dm
> # CONFIG_APM_IGNORE_USER_SUSPEND is not set
> CONFIG_APM_DO_ENABLE=3Dy
> # CONFIG_APM_CPU_IDLE is not set
> # CONFIG_APM_DISPLAY_BLANK is not set
> CONFIG_APM_ALLOW_INTS=3Dy
>=20
> #
> # CPU Frequency scaling
> #
> # CONFIG_CPU_FREQ is not set
>=20
> #
> # CPU Idle
> #
> CONFIG_CPU_IDLE=3Dy
> CONFIG_CPU_IDLE_GOV_LADDER=3Dy
> CONFIG_CPU_IDLE_GOV_MENU=3Dy
> # CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
>=20
> #
> # Bus options (PCI etc.)
> #
> CONFIG_PCI=3Dy
> # CONFIG_PCI_GOBIOS is not set
> # CONFIG_PCI_GOMMCONFIG is not set
> # CONFIG_PCI_GODIRECT is not set
> CONFIG_PCI_GOANY=3Dy
> CONFIG_PCI_BIOS=3Dy
> CONFIG_PCI_DIRECT=3Dy
> CONFIG_PCI_MMCONFIG=3Dy
> CONFIG_PCI_DOMAINS=3Dy
> # CONFIG_PCI_CNB20LE_QUIRK is not set
> # CONFIG_PCIEPORTBUS is not set
> # CONFIG_PCI_MSI is not set
> # CONFIG_PCI_DEBUG is not set
> # CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
> # CONFIG_PCI_STUB is not set
> # CONFIG_PCI_IOV is not set
> # CONFIG_PCI_PRI is not set
> # CONFIG_PCI_PASID is not set
> CONFIG_PCI_LABEL=3Dy
>=20
> #
> # PCI host controller drivers
> #
> CONFIG_ISA_DMA_API=3Dy
> CONFIG_ISA=3Dy
> CONFIG_EISA=3Dy
> CONFIG_EISA_VLB_PRIMING=3Dy
> CONFIG_EISA_PCI_EISA=3Dy
> # CONFIG_EISA_VIRTUAL_ROOT is not set
> # CONFIG_EISA_NAMES is not set
> CONFIG_SCx200=3Dy
> CONFIG_SCx200HR_TIMER=3Dm
> CONFIG_ALIX=3Dy
> CONFIG_NET5501=3Dy
> CONFIG_GEOS=3Dy
> CONFIG_AMD_NB=3Dy
> # CONFIG_PCCARD is not set
> # CONFIG_HOTPLUG_PCI is not set
> # CONFIG_RAPIDIO is not set
> CONFIG_X86_SYSFB=3Dy
>=20
> #
> # Executable file formats / Emulations
> #
> CONFIG_BINFMT_ELF=3Dy
> CONFIG_BINFMT_SCRIPT=3Dy
> CONFIG_HAVE_AOUT=3Dy
> CONFIG_BINFMT_AOUT=3Dm
> CONFIG_BINFMT_MISC=3Dy
> CONFIG_COREDUMP=3Dy
> CONFIG_HAVE_ATOMIC_IOMAP=3Dy
> CONFIG_PMC_ATOM=3Dy
> CONFIG_NET=3Dy
>=20
> #
> # Networking options
> #
> # CONFIG_PACKET is not set
> CONFIG_UNIX=3Dy
> # CONFIG_UNIX_DIAG is not set
> # CONFIG_NET_KEY is not set
> # CONFIG_INET is not set
> # CONFIG_NETWORK_SECMARK is not set
> # CONFIG_NET_PTP_CLASSIFY is not set
> # CONFIG_NETWORK_PHY_TIMESTAMPING is not set
> # CONFIG_NETFILTER is not set
> # CONFIG_ATM is not set
> # CONFIG_BRIDGE is not set
> # CONFIG_VLAN_8021Q is not set
> # CONFIG_DECNET is not set
> # CONFIG_LLC2 is not set
> # CONFIG_IPX is not set
> # CONFIG_ATALK is not set
> # CONFIG_X25 is not set
> # CONFIG_LAPB is not set
> # CONFIG_PHONET is not set
> # CONFIG_IEEE802154 is not set
> # CONFIG_NET_SCHED is not set
> # CONFIG_DCB is not set
> # CONFIG_DNS_RESOLVER is not set
> # CONFIG_BATMAN_ADV is not set
> # CONFIG_VSOCKETS is not set
> # CONFIG_NETLINK_MMAP is not set
> # CONFIG_NETLINK_DIAG is not set
> # CONFIG_MPLS is not set
> # CONFIG_HSR is not set
> # CONFIG_CGROUP_NET_PRIO is not set
> # CONFIG_CGROUP_NET_CLASSID is not set
> CONFIG_NET_RX_BUSY_POLL=3Dy
> CONFIG_BQL=3Dy
>=20
> #
> # Network testing
> #
> # CONFIG_HAMRADIO is not set
> # CONFIG_CAN is not set
> # CONFIG_IRDA is not set
> # CONFIG_BT is not set
> CONFIG_WIRELESS=3Dy
> # CONFIG_CFG80211 is not set
> # CONFIG_LIB80211 is not set
>=20
> #
> # CFG80211 needs to be enabled for MAC80211
> #
> # CONFIG_WIMAX is not set
> # CONFIG_RFKILL is not set
> # CONFIG_RFKILL_REGULATOR is not set
> # CONFIG_NET_9P is not set
> # CONFIG_CAIF is not set
> # CONFIG_NFC is not set
>=20
> #
> # Device Drivers
> #
>=20
> #
> # Generic Driver Options
> #
> CONFIG_UEVENT_HELPER=3Dy
> CONFIG_UEVENT_HELPER_PATH=3D""
> CONFIG_DEVTMPFS=3Dy
> # CONFIG_DEVTMPFS_MOUNT is not set
> CONFIG_STANDALONE=3Dy
> CONFIG_PREVENT_FIRMWARE_BUILD=3Dy
> CONFIG_FW_LOADER=3Dy
> CONFIG_FIRMWARE_IN_KERNEL=3Dy
> CONFIG_EXTRA_FIRMWARE=3D""
> CONFIG_FW_LOADER_USER_HELPER=3Dy
> # CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
> # CONFIG_ALLOW_DEV_COREDUMP is not set
> # CONFIG_DEBUG_DRIVER is not set
> CONFIG_DEBUG_DEVRES=3Dy
> # CONFIG_SYS_HYPERVISOR is not set
> # CONFIG_GENERIC_CPU_DEVICES is not set
> CONFIG_GENERIC_CPU_AUTOPROBE=3Dy
> CONFIG_REGMAP=3Dy
> CONFIG_REGMAP_I2C=3Dy
> CONFIG_REGMAP_SPI=3Dy
> CONFIG_REGMAP_MMIO=3Dy
> CONFIG_REGMAP_IRQ=3Dy
> CONFIG_DMA_SHARED_BUFFER=3Dy
> CONFIG_FENCE_TRACE=3Dy
> CONFIG_DMA_CMA=3Dy
>=20
> #
> # Default contiguous memory area size:
> #
> CONFIG_CMA_SIZE_MBYTES=3D0
> CONFIG_CMA_SIZE_SEL_MBYTES=3Dy
> # CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
> # CONFIG_CMA_SIZE_SEL_MIN is not set
> # CONFIG_CMA_SIZE_SEL_MAX is not set
> CONFIG_CMA_ALIGNMENT=3D8
>=20
> #
> # Bus devices
> #
> # CONFIG_CONNECTOR is not set
> CONFIG_MTD=3Dm
> CONFIG_MTD_TESTS=3Dm
> CONFIG_MTD_REDBOOT_PARTS=3Dm
> CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=3D-1
> # CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
> CONFIG_MTD_REDBOOT_PARTS_READONLY=3Dy
> # CONFIG_MTD_CMDLINE_PARTS is not set
> # CONFIG_MTD_AR7_PARTS is not set
>=20
> #
> # User Modules And Translation Layers
> #
> # CONFIG_MTD_OOPS is not set
>=20
> #
> # RAM/ROM/Flash chip drivers
> #
> # CONFIG_MTD_CFI is not set
> CONFIG_MTD_JEDECPROBE=3Dm
> CONFIG_MTD_GEN_PROBE=3Dm
> # CONFIG_MTD_CFI_ADV_OPTIONS is not set
> CONFIG_MTD_MAP_BANK_WIDTH_1=3Dy
> CONFIG_MTD_MAP_BANK_WIDTH_2=3Dy
> CONFIG_MTD_MAP_BANK_WIDTH_4=3Dy
> # CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
> # CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
> # CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
> CONFIG_MTD_CFI_I1=3Dy
> CONFIG_MTD_CFI_I2=3Dy
> # CONFIG_MTD_CFI_I4 is not set
> # CONFIG_MTD_CFI_I8 is not set
> CONFIG_MTD_CFI_INTELEXT=3Dm
> CONFIG_MTD_CFI_AMDSTD=3Dm
> # CONFIG_MTD_CFI_STAA is not set
> CONFIG_MTD_CFI_UTIL=3Dm
> CONFIG_MTD_RAM=3Dm
> # CONFIG_MTD_ROM is not set
> CONFIG_MTD_ABSENT=3Dm
>=20
> #
> # Mapping drivers for chip access
> #
> # CONFIG_MTD_COMPLEX_MAPPINGS is not set
> CONFIG_MTD_PHYSMAP=3Dm
> CONFIG_MTD_PHYSMAP_COMPAT=3Dy
> CONFIG_MTD_PHYSMAP_START=3D0x8000000
> CONFIG_MTD_PHYSMAP_LEN=3D0
> CONFIG_MTD_PHYSMAP_BANKWIDTH=3D2
> # CONFIG_MTD_AMD76XROM is not set
> CONFIG_MTD_ICHXROM=3Dm
> # CONFIG_MTD_ESB2ROM is not set
> # CONFIG_MTD_CK804XROM is not set
> # CONFIG_MTD_SCB2_FLASH is not set
> # CONFIG_MTD_NETtel is not set
> # CONFIG_MTD_L440GX is not set
> # CONFIG_MTD_INTEL_VR_NOR is not set
> # CONFIG_MTD_PLATRAM is not set
>=20
> #
> # Self-contained MTD device drivers
> #
> # CONFIG_MTD_PMC551 is not set
> CONFIG_MTD_DATAFLASH=3Dm
> # CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
> # CONFIG_MTD_DATAFLASH_OTP is not set
> CONFIG_MTD_M25P80=3Dm
> CONFIG_MTD_SST25L=3Dm
> CONFIG_MTD_SLRAM=3Dm
> CONFIG_MTD_PHRAM=3Dm
> CONFIG_MTD_MTDRAM=3Dm
> CONFIG_MTDRAM_TOTAL_SIZE=3D4096
> CONFIG_MTDRAM_ERASE_SIZE=3D128
>=20
> #
> # Disk-On-Chip Device Drivers
> #
> CONFIG_MTD_DOCG3=3Dm
> CONFIG_BCH_CONST_M=3D14
> CONFIG_BCH_CONST_T=3D4
> # CONFIG_MTD_NAND is not set
> CONFIG_MTD_ONENAND=3Dm
> CONFIG_MTD_ONENAND_VERIFY_WRITE=3Dy
> CONFIG_MTD_ONENAND_GENERIC=3Dm
> CONFIG_MTD_ONENAND_OTP=3Dy
> CONFIG_MTD_ONENAND_2X_PROGRAM=3Dy
>=20
> #
> # LPDDR & LPDDR2 PCM memory drivers
> #
> # CONFIG_MTD_LPDDR is not set
> CONFIG_MTD_SPI_NOR=3Dm
> CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=3Dy
> CONFIG_MTD_UBI=3Dm
> CONFIG_MTD_UBI_WL_THRESHOLD=3D4096
> CONFIG_MTD_UBI_BEB_LIMIT=3D20
> CONFIG_MTD_UBI_FASTMAP=3Dy
> # CONFIG_MTD_UBI_GLUEBI is not set
> CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=3Dy
> # CONFIG_PARPORT is not set
> CONFIG_PNP=3Dy
> CONFIG_PNP_DEBUG_MESSAGES=3Dy
>=20
> #
> # Protocols
> #
> # CONFIG_ISAPNP is not set
> # CONFIG_PNPBIOS is not set
> CONFIG_PNPACPI=3Dy
>=20
> #
> # Misc devices
> #
> CONFIG_SENSORS_LIS3LV02D=3Dm
> # CONFIG_AD525X_DPOT is not set
> # CONFIG_DUMMY_IRQ is not set
> # CONFIG_IBM_ASM is not set
> # CONFIG_PHANTOM is not set
> # CONFIG_SGI_IOC4 is not set
> # CONFIG_TIFM_CORE is not set
> # CONFIG_ICS932S401 is not set
> CONFIG_ENCLOSURE_SERVICES=3Dy
> # CONFIG_HP_ILO is not set
> CONFIG_APDS9802ALS=3Dm
> # CONFIG_ISL29003 is not set
> # CONFIG_ISL29020 is not set
> # CONFIG_SENSORS_TSL2550 is not set
> # CONFIG_SENSORS_BH1780 is not set
> # CONFIG_SENSORS_BH1770 is not set
> # CONFIG_SENSORS_APDS990X is not set
> CONFIG_HMC6352=3Dy
> # CONFIG_DS1682 is not set
> # CONFIG_TI_DAC7512 is not set
> CONFIG_VMWARE_BALLOON=3Dm
> # CONFIG_BMP085_I2C is not set
> # CONFIG_BMP085_SPI is not set
> # CONFIG_PCH_PHUB is not set
> CONFIG_USB_SWITCH_FSA9480=3Dm
> # CONFIG_LATTICE_ECP3_CONFIG is not set
> # CONFIG_SRAM is not set
> # CONFIG_C2PORT is not set
>=20
> #
> # EEPROM support
> #
> # CONFIG_EEPROM_AT24 is not set
> # CONFIG_EEPROM_AT25 is not set
> # CONFIG_EEPROM_LEGACY is not set
> CONFIG_EEPROM_MAX6875=3Dy
> # CONFIG_EEPROM_93CX6 is not set
> # CONFIG_EEPROM_93XX46 is not set
> # CONFIG_CB710_CORE is not set
>=20
> #
> # Texas Instruments shared transport line discipline
> #
> # CONFIG_TI_ST is not set
> CONFIG_SENSORS_LIS3_I2C=3Dm
>=20
> #
> # Altera FPGA firmware download module
> #
> # CONFIG_ALTERA_STAPL is not set
> # CONFIG_VMWARE_VMCI is not set
>=20
> #
> # Intel MIC Bus Driver
> #
>=20
> #
> # Intel MIC Host Driver
> #
>=20
> #
> # Intel MIC Card Driver
> #
> CONFIG_ECHO=3Dm
> # CONFIG_CXL_BASE is not set
> CONFIG_HAVE_IDE=3Dy
>=20
> #
> # SCSI device support
> #
> CONFIG_SCSI_MOD=3Dy
> # CONFIG_SCSI_DMA is not set
> # CONFIG_SCSI_NETLINK is not set
> # CONFIG_FUSION is not set
>=20
> #
> # IEEE 1394 (FireWire) support
> #
> CONFIG_FIREWIRE=3Dy
> # CONFIG_FIREWIRE_OHCI is not set
> # CONFIG_FIREWIRE_NOSY is not set
> # CONFIG_MACINTOSH_DRIVERS is not set
> # CONFIG_NETDEVICES is not set
> # CONFIG_VHOST_NET is not set
>=20
> #
> # Input device support
> #
> CONFIG_INPUT=3Dy
> CONFIG_INPUT_FF_MEMLESS=3Dy
> CONFIG_INPUT_POLLDEV=3Dy
> CONFIG_INPUT_SPARSEKMAP=3Dy
> CONFIG_INPUT_MATRIXKMAP=3Dy
>=20
> #
> # Userland interfaces
> #
> CONFIG_INPUT_MOUSEDEV=3Dy
> # CONFIG_INPUT_MOUSEDEV_PSAUX is not set
> CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024
> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768
> # CONFIG_INPUT_JOYDEV is not set
> CONFIG_INPUT_EVDEV=3Dm
> CONFIG_INPUT_EVBUG=3Dy
>=20
> #
> # Input Device Drivers
> #
> CONFIG_INPUT_KEYBOARD=3Dy
> CONFIG_KEYBOARD_ADP5588=3Dm
> CONFIG_KEYBOARD_ADP5589=3Dy
> CONFIG_KEYBOARD_ATKBD=3Dy
> CONFIG_KEYBOARD_QT1070=3Dy
> CONFIG_KEYBOARD_QT2160=3Dm
> # CONFIG_KEYBOARD_LKKBD is not set
> CONFIG_KEYBOARD_GPIO=3Dy
> # CONFIG_KEYBOARD_GPIO_POLLED is not set
> # CONFIG_KEYBOARD_TCA6416 is not set
> CONFIG_KEYBOARD_TCA8418=3Dy
> CONFIG_KEYBOARD_MATRIX=3Dm
> CONFIG_KEYBOARD_LM8323=3Dm
> CONFIG_KEYBOARD_LM8333=3Dm
> # CONFIG_KEYBOARD_MAX7359 is not set
> CONFIG_KEYBOARD_MCS=3Dy
> CONFIG_KEYBOARD_MPR121=3Dm
> CONFIG_KEYBOARD_NEWTON=3Dm
> CONFIG_KEYBOARD_OPENCORES=3Dy
> # CONFIG_KEYBOARD_STOWAWAY is not set
> # CONFIG_KEYBOARD_SUNKBD is not set
> CONFIG_KEYBOARD_TWL4030=3Dm
> # CONFIG_KEYBOARD_XTKBD is not set
> # CONFIG_KEYBOARD_CROS_EC is not set
> CONFIG_INPUT_MOUSE=3Dy
> CONFIG_MOUSE_PS2=3Dm
> # CONFIG_MOUSE_PS2_ALPS is not set
> # CONFIG_MOUSE_PS2_LOGIPS2PP is not set
> CONFIG_MOUSE_PS2_SYNAPTICS=3Dy
> # CONFIG_MOUSE_PS2_CYPRESS is not set
> # CONFIG_MOUSE_PS2_LIFEBOOK is not set
> # CONFIG_MOUSE_PS2_TRACKPOINT is not set
> CONFIG_MOUSE_PS2_ELANTECH=3Dy
> # CONFIG_MOUSE_PS2_SENTELIC is not set
> CONFIG_MOUSE_PS2_TOUCHKIT=3Dy
> CONFIG_MOUSE_PS2_FOCALTECH=3Dy
> # CONFIG_MOUSE_SERIAL is not set
> CONFIG_MOUSE_APPLETOUCH=3Dy
> CONFIG_MOUSE_BCM5974=3Dy
> # CONFIG_MOUSE_CYAPA is not set
> # CONFIG_MOUSE_ELAN_I2C is not set
> CONFIG_MOUSE_INPORT=3Dm
> CONFIG_MOUSE_ATIXL=3Dy
> # CONFIG_MOUSE_LOGIBM is not set
> CONFIG_MOUSE_PC110PAD=3Dy
> # CONFIG_MOUSE_VSXXXAA is not set
> # CONFIG_MOUSE_GPIO is not set
> CONFIG_MOUSE_SYNAPTICS_I2C=3Dm
> # CONFIG_MOUSE_SYNAPTICS_USB is not set
> CONFIG_INPUT_JOYSTICK=3Dy
> CONFIG_JOYSTICK_ANALOG=3Dm
> CONFIG_JOYSTICK_A3D=3Dm
> # CONFIG_JOYSTICK_ADI is not set
> CONFIG_JOYSTICK_COBRA=3Dm
> CONFIG_JOYSTICK_GF2K=3Dy
> CONFIG_JOYSTICK_GRIP=3Dm
> CONFIG_JOYSTICK_GRIP_MP=3Dy
> # CONFIG_JOYSTICK_GUILLEMOT is not set
> CONFIG_JOYSTICK_INTERACT=3Dm
> # CONFIG_JOYSTICK_SIDEWINDER is not set
> CONFIG_JOYSTICK_TMDC=3Dm
> CONFIG_JOYSTICK_IFORCE=3Dm
> CONFIG_JOYSTICK_IFORCE_USB=3Dy
> CONFIG_JOYSTICK_IFORCE_232=3Dy
> CONFIG_JOYSTICK_WARRIOR=3Dy
> CONFIG_JOYSTICK_MAGELLAN=3Dm
> CONFIG_JOYSTICK_SPACEORB=3Dy
> CONFIG_JOYSTICK_SPACEBALL=3Dm
> CONFIG_JOYSTICK_STINGER=3Dy
> CONFIG_JOYSTICK_TWIDJOY=3Dy
> CONFIG_JOYSTICK_ZHENHUA=3Dy
> # CONFIG_JOYSTICK_AS5011 is not set
> CONFIG_JOYSTICK_JOYDUMP=3Dm
> CONFIG_JOYSTICK_XPAD=3Dy
> CONFIG_JOYSTICK_XPAD_FF=3Dy
> CONFIG_JOYSTICK_XPAD_LEDS=3Dy
> CONFIG_INPUT_TABLET=3Dy
> # CONFIG_TABLET_USB_ACECAD is not set
> CONFIG_TABLET_USB_AIPTEK=3Dm
> CONFIG_TABLET_USB_GTCO=3Dy
> # CONFIG_TABLET_USB_HANWANG is not set
> CONFIG_TABLET_USB_KBTAB=3Dy
> CONFIG_TABLET_SERIAL_WACOM4=3Dm
> # CONFIG_INPUT_TOUCHSCREEN is not set
> CONFIG_INPUT_MISC=3Dy
> # CONFIG_INPUT_88PM80X_ONKEY is not set
> # CONFIG_INPUT_AD714X is not set
> CONFIG_INPUT_BMA150=3Dy
> # CONFIG_INPUT_E3X0_BUTTON is not set
> CONFIG_INPUT_PCSPKR=3Dy
> # CONFIG_INPUT_MAX8925_ONKEY is not set
> CONFIG_INPUT_MAX8997_HAPTIC=3Dy
> CONFIG_INPUT_MC13783_PWRBUTTON=3Dm
> CONFIG_INPUT_MMA8450=3Dm
> # CONFIG_INPUT_MPU3050 is not set
> # CONFIG_INPUT_APANEL is not set
> CONFIG_INPUT_GP2A=3Dy
> # CONFIG_INPUT_GPIO_BEEPER is not set
> CONFIG_INPUT_GPIO_TILT_POLLED=3Dm
> CONFIG_INPUT_WISTRON_BTNS=3Dy
> # CONFIG_INPUT_ATLAS_BTNS is not set
> # CONFIG_INPUT_ATI_REMOTE2 is not set
> CONFIG_INPUT_KEYSPAN_REMOTE=3Dm
> CONFIG_INPUT_KXTJ9=3Dy
> # CONFIG_INPUT_KXTJ9_POLLED_MODE is not set
> CONFIG_INPUT_POWERMATE=3Dy
> CONFIG_INPUT_YEALINK=3Dm
> CONFIG_INPUT_CM109=3Dm
> # CONFIG_INPUT_REGULATOR_HAPTIC is not set
> CONFIG_INPUT_TPS65218_PWRBUTTON=3Dm
> CONFIG_INPUT_AXP20X_PEK=3Dm
> CONFIG_INPUT_TWL4030_PWRBUTTON=3Dy
> # CONFIG_INPUT_TWL4030_VIBRA is not set
> CONFIG_INPUT_UINPUT=3Dy
> # CONFIG_INPUT_PALMAS_PWRBUTTON is not set
> # CONFIG_INPUT_PCF50633_PMU is not set
> CONFIG_INPUT_PCF8574=3Dy
> CONFIG_INPUT_PWM_BEEPER=3Dm
> CONFIG_INPUT_GPIO_ROTARY_ENCODER=3Dm
> CONFIG_INPUT_DA9052_ONKEY=3Dm
> # CONFIG_INPUT_DA9055_ONKEY is not set
> CONFIG_INPUT_PCAP=3Dm
> CONFIG_INPUT_ADXL34X=3Dm
> CONFIG_INPUT_ADXL34X_I2C=3Dm
> CONFIG_INPUT_ADXL34X_SPI=3Dm
> CONFIG_INPUT_IMS_PCU=3Dm
> # CONFIG_INPUT_CMA3000 is not set
> CONFIG_INPUT_IDEAPAD_SLIDEBAR=3Dm
> # CONFIG_INPUT_SOC_BUTTON_ARRAY is not set
> CONFIG_INPUT_DRV260X_HAPTICS=3Dy
> CONFIG_INPUT_DRV2667_HAPTICS=3Dy
>=20
> #
> # Hardware I/O ports
> #
> CONFIG_SERIO=3Dy
> CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=3Dy
> CONFIG_SERIO_I8042=3Dy
> CONFIG_SERIO_SERPORT=3Dm
> # CONFIG_SERIO_CT82C710 is not set
> # CONFIG_SERIO_PCIPS2 is not set
> CONFIG_SERIO_LIBPS2=3Dy
> # CONFIG_SERIO_RAW is not set
> # CONFIG_SERIO_ALTERA_PS2 is not set
> CONFIG_SERIO_PS2MULT=3Dy
> # CONFIG_SERIO_ARC_PS2 is not set
> CONFIG_GAMEPORT=3Dy
> CONFIG_GAMEPORT_NS558=3Dy
> # CONFIG_GAMEPORT_L4 is not set
> # CONFIG_GAMEPORT_EMU10K1 is not set
> # CONFIG_GAMEPORT_FM801 is not set
>=20
> #
> # Character devices
> #
> CONFIG_TTY=3Dy
> # CONFIG_VT is not set
> CONFIG_UNIX98_PTYS=3Dy
> CONFIG_DEVPTS_MULTIPLE_INSTANCES=3Dy
> # CONFIG_LEGACY_PTYS is not set
> CONFIG_SERIAL_NONSTANDARD=3Dy
> # CONFIG_ROCKETPORT is not set
> CONFIG_CYCLADES=3Dy
> CONFIG_CYZ_INTR=3Dy
> CONFIG_MOXA_INTELLIO=3Dm
> # CONFIG_MOXA_SMARTIO is not set
> # CONFIG_SYNCLINK is not set
> # CONFIG_SYNCLINKMP is not set
> # CONFIG_SYNCLINK_GT is not set
> # CONFIG_NOZOMI is not set
> # CONFIG_ISI is not set
> CONFIG_N_HDLC=3Dy
> # CONFIG_N_GSM is not set
> # CONFIG_TRACE_SINK is not set
> # CONFIG_DEVMEM is not set
> CONFIG_DEVKMEM=3Dy
>=20
> #
> # Serial drivers
> #
> CONFIG_SERIAL_EARLYCON=3Dy
> CONFIG_SERIAL_8250=3Dy
> CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=3Dy
> CONFIG_SERIAL_8250_PNP=3Dy
> CONFIG_SERIAL_8250_CONSOLE=3Dy
> CONFIG_SERIAL_8250_PCI=3Dy
> CONFIG_SERIAL_8250_NR_UARTS=3D4
> CONFIG_SERIAL_8250_RUNTIME_UARTS=3D4
> CONFIG_SERIAL_8250_EXTENDED=3Dy
> CONFIG_SERIAL_8250_MANY_PORTS=3Dy
> # CONFIG_SERIAL_8250_FOURPORT is not set
> CONFIG_SERIAL_8250_ACCENT=3Dm
> # CONFIG_SERIAL_8250_BOCA is not set
> CONFIG_SERIAL_8250_EXAR_ST16C554=3Dy
> # CONFIG_SERIAL_8250_HUB6 is not set
> # CONFIG_SERIAL_8250_SHARE_IRQ is not set
> CONFIG_SERIAL_8250_DETECT_IRQ=3Dy
> # CONFIG_SERIAL_8250_RSA is not set
> CONFIG_SERIAL_8250_DW=3Dy
> # CONFIG_SERIAL_8250_FINTEK is not set
>=20
> #
> # Non-8250 serial port support
> #
> # CONFIG_SERIAL_MAX3100 is not set
> # CONFIG_SERIAL_MAX310X is not set
> # CONFIG_SERIAL_MFD_HSU is not set
> CONFIG_SERIAL_CORE=3Dy
> CONFIG_SERIAL_CORE_CONSOLE=3Dy
> # CONFIG_SERIAL_JSM is not set
> CONFIG_SERIAL_SCCNXP=3Dy
> # CONFIG_SERIAL_SCCNXP_CONSOLE is not set
> # CONFIG_SERIAL_SC16IS7XX is not set
> # CONFIG_SERIAL_TIMBERDALE is not set
> CONFIG_SERIAL_ALTERA_JTAGUART=3Dm
> CONFIG_SERIAL_ALTERA_UART=3Dm
> CONFIG_SERIAL_ALTERA_UART_MAXPORTS=3D4
> CONFIG_SERIAL_ALTERA_UART_BAUDRATE=3D115200
> CONFIG_SERIAL_IFX6X60=3Dm
> # CONFIG_SERIAL_PCH_UART is not set
> # CONFIG_SERIAL_ARC is not set
> # CONFIG_SERIAL_RP2 is not set
> CONFIG_SERIAL_FSL_LPUART=3Dm
> # CONFIG_SERIAL_MEN_Z135 is not set
> CONFIG_TTY_PRINTK=3Dm
> CONFIG_HVC_DRIVER=3Dy
> CONFIG_VIRTIO_CONSOLE=3Dm
> CONFIG_IPMI_HANDLER=3Dm
> CONFIG_IPMI_PANIC_EVENT=3Dy
> # CONFIG_IPMI_PANIC_STRING is not set
> # CONFIG_IPMI_DEVICE_INTERFACE is not set
> CONFIG_IPMI_SI=3Dm
> # CONFIG_IPMI_SI_PROBE_DEFAULTS is not set
> CONFIG_IPMI_SSIF=3Dm
> CONFIG_IPMI_WATCHDOG=3Dm
> # CONFIG_IPMI_POWEROFF is not set
> CONFIG_HW_RANDOM=3Dy
> CONFIG_HW_RANDOM_TIMERIOMEM=3Dy
> CONFIG_HW_RANDOM_INTEL=3Dy
> CONFIG_HW_RANDOM_AMD=3Dy
> CONFIG_HW_RANDOM_GEODE=3Dy
> CONFIG_HW_RANDOM_VIA=3Dm
> CONFIG_HW_RANDOM_VIRTIO=3Dm
> # CONFIG_NVRAM is not set
> # CONFIG_DTLK is not set
> # CONFIG_R3964 is not set
> # CONFIG_APPLICOM is not set
> # CONFIG_SONYPI is not set
> CONFIG_MWAVE=3Dy
> # CONFIG_SCx200_GPIO is not set
> CONFIG_PC8736x_GPIO=3Dy
> CONFIG_NSC_GPIO=3Dy
> # CONFIG_HPET is not set
> # CONFIG_HANGCHECK_TIMER is not set
> # CONFIG_TCG_TPM is not set
> # CONFIG_TELCLOCK is not set
> CONFIG_DEVPORT=3Dy
> # CONFIG_XILLYBUS is not set
>=20
> #
> # I2C support
> #
> CONFIG_I2C=3Dy
> CONFIG_ACPI_I2C_OPREGION=3Dy
> CONFIG_I2C_BOARDINFO=3Dy
> # CONFIG_I2C_COMPAT is not set
> # CONFIG_I2C_CHARDEV is not set
> CONFIG_I2C_MUX=3Dm
>=20
> #
> # Multiplexer I2C Chip support
> #
> # CONFIG_I2C_MUX_GPIO is not set
> CONFIG_I2C_MUX_PCA9541=3Dm
> CONFIG_I2C_MUX_PCA954x=3Dm
> # CONFIG_I2C_HELPER_AUTO is not set
> CONFIG_I2C_SMBUS=3Dy
>=20
> #
> # I2C Algorithms
> #
> CONFIG_I2C_ALGOBIT=3Dy
> CONFIG_I2C_ALGOPCF=3Dy
> CONFIG_I2C_ALGOPCA=3Dy
>=20
> #
> # I2C Hardware Bus support
> #
>=20
> #
> # PC SMBus host controller drivers
> #
> # CONFIG_I2C_ALI1535 is not set
> # CONFIG_I2C_ALI1563 is not set
> # CONFIG_I2C_ALI15X3 is not set
> # CONFIG_I2C_AMD756 is not set
> # CONFIG_I2C_AMD8111 is not set
> # CONFIG_I2C_I801 is not set
> # CONFIG_I2C_ISCH is not set
> # CONFIG_I2C_ISMT is not set
> # CONFIG_I2C_PIIX4 is not set
> # CONFIG_I2C_NFORCE2 is not set
> # CONFIG_I2C_SIS5595 is not set
> # CONFIG_I2C_SIS630 is not set
> # CONFIG_I2C_SIS96X is not set
> # CONFIG_I2C_VIA is not set
> # CONFIG_I2C_VIAPRO is not set
>=20
> #
> # ACPI drivers
> #
> # CONFIG_I2C_SCMI is not set
>=20
> #
> # I2C system bus drivers (mostly embedded / system-on-chip)
> #
> # CONFIG_I2C_CBUS_GPIO is not set
> # CONFIG_I2C_DESIGNWARE_PCI is not set
> # CONFIG_I2C_EG20T is not set
> CONFIG_I2C_GPIO=3Dy
> CONFIG_I2C_OCORES=3Dm
> CONFIG_I2C_PCA_PLATFORM=3Dm
> # CONFIG_I2C_PXA_PCI is not set
> # CONFIG_I2C_SIMTEC is not set
> # CONFIG_I2C_XILINX is not set
>=20
> #
> # External I2C/SMBus adapter drivers
> #
> CONFIG_I2C_DIOLAN_U2C=3Dy
> # CONFIG_I2C_DLN2 is not set
> CONFIG_I2C_PARPORT_LIGHT=3Dy
> CONFIG_I2C_ROBOTFUZZ_OSIF=3Dy
> # CONFIG_I2C_TAOS_EVM is not set
> # CONFIG_I2C_TINY_USB is not set
>=20
> #
> # Other I2C/SMBus bus drivers
> #
> # CONFIG_I2C_ELEKTOR is not set
> CONFIG_I2C_PCA_ISA=3Dy
> CONFIG_I2C_CROS_EC_TUNNEL=3Dm
> # CONFIG_SCx200_ACB is not set
> CONFIG_I2C_STUB=3Dm
> CONFIG_I2C_SLAVE=3Dy
> CONFIG_I2C_SLAVE_EEPROM=3Dm
> # CONFIG_I2C_DEBUG_CORE is not set
> # CONFIG_I2C_DEBUG_ALGO is not set
> # CONFIG_I2C_DEBUG_BUS is not set
> CONFIG_SPI=3Dy
> CONFIG_SPI_DEBUG=3Dy
> CONFIG_SPI_MASTER=3Dy
>=20
> #
> # SPI Master Controller Drivers
> #
> CONFIG_SPI_ALTERA=3Dy
> CONFIG_SPI_BITBANG=3Dy
> # CONFIG_SPI_CADENCE is not set
> CONFIG_SPI_DLN2=3Dm
> CONFIG_SPI_GPIO=3Dy
> CONFIG_SPI_OC_TINY=3Dm
> # CONFIG_SPI_PXA2XX is not set
> # CONFIG_SPI_PXA2XX_PCI is not set
> # CONFIG_SPI_SC18IS602 is not set
> # CONFIG_SPI_TOPCLIFF_PCH is not set
> CONFIG_SPI_XCOMM=3Dm
> # CONFIG_SPI_XILINX is not set
> CONFIG_SPI_DESIGNWARE=3Dy
> # CONFIG_SPI_DW_PCI is not set
> # CONFIG_SPI_DW_MMIO is not set
>=20
> #
> # SPI Protocol Masters
> #
> CONFIG_SPI_SPIDEV=3Dy
> # CONFIG_SPI_TLE62X0 is not set
> # CONFIG_SPMI is not set
> CONFIG_HSI=3Dm
> CONFIG_HSI_BOARDINFO=3Dy
>=20
> #
> # HSI controllers
> #
>=20
> #
> # HSI clients
> #
> CONFIG_HSI_CHAR=3Dm
>=20
> #
> # PPS support
> #
> # CONFIG_PPS is not set
>=20
> #
> # PPS generators support
> #
>=20
> #
> # PTP clock support
> #
> # CONFIG_PTP_1588_CLOCK is not set
>=20
> #
> # Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
> #
> # CONFIG_PTP_1588_CLOCK_PCH is not set
> CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=3Dy
> CONFIG_GPIOLIB=3Dy
> CONFIG_GPIO_DEVRES=3Dy
> CONFIG_GPIO_ACPI=3Dy
> CONFIG_GPIOLIB_IRQCHIP=3Dy
> # CONFIG_DEBUG_GPIO is not set
> # CONFIG_GPIO_SYSFS is not set
> CONFIG_GPIO_DA9052=3Dm
> CONFIG_GPIO_DA9055=3Dm
> CONFIG_GPIO_MAX730X=3Dy
>=20
> #
> # Memory mapped GPIO drivers:
> #
> # CONFIG_GPIO_GENERIC_PLATFORM is not set
> CONFIG_GPIO_IT8761E=3Dm
> CONFIG_GPIO_F7188X=3Dy
> CONFIG_GPIO_SCH311X=3Dm
> # CONFIG_GPIO_SCH is not set
> # CONFIG_GPIO_ICH is not set
> # CONFIG_GPIO_VX855 is not set
> # CONFIG_GPIO_LYNXPOINT is not set
>=20
> #
> # I2C GPIO expanders:
> #
> CONFIG_GPIO_ARIZONA=3Dm
> # CONFIG_GPIO_CRYSTAL_COVE is not set
> # CONFIG_GPIO_MAX7300 is not set
> # CONFIG_GPIO_MAX732X is not set
> CONFIG_GPIO_PCA953X=3Dm
> CONFIG_GPIO_PCF857X=3Dy
> CONFIG_GPIO_RC5T583=3Dy
> # CONFIG_GPIO_SX150X is not set
> CONFIG_GPIO_TWL4030=3Dy
> # CONFIG_GPIO_WM8350 is not set
> # CONFIG_GPIO_ADP5588 is not set
>=20
> #
> # PCI GPIO expanders:
> #
> # CONFIG_GPIO_BT8XX is not set
> # CONFIG_GPIO_AMD8111 is not set
> # CONFIG_GPIO_INTEL_MID is not set
> # CONFIG_GPIO_PCH is not set
> # CONFIG_GPIO_ML_IOH is not set
> # CONFIG_GPIO_RDC321X is not set
>=20
> #
> # SPI GPIO expanders:
> #
> CONFIG_GPIO_MAX7301=3Dy
> CONFIG_GPIO_MCP23S08=3Dy
> CONFIG_GPIO_MC33880=3Dm
>=20
> #
> # AC97 GPIO expanders:
> #
>=20
> #
> # LPC GPIO expanders:
> #
>=20
> #
> # MODULbus GPIO expanders:
> #
> # CONFIG_GPIO_PALMAS is not set
> CONFIG_GPIO_TPS6586X=3Dy
>=20
> #
> # USB GPIO expanders:
> #
> CONFIG_GPIO_DLN2=3Dm
> CONFIG_W1=3Dy
>=20
> #
> # 1-wire Bus Masters
> #
> # CONFIG_W1_MASTER_MATROX is not set
> CONFIG_W1_MASTER_DS2490=3Dy
> # CONFIG_W1_MASTER_DS2482 is not set
> CONFIG_W1_MASTER_DS1WM=3Dy
> CONFIG_W1_MASTER_GPIO=3Dm
>=20
> #
> # 1-wire Slaves
> #
> # CONFIG_W1_SLAVE_THERM is not set
> CONFIG_W1_SLAVE_SMEM=3Dm
> # CONFIG_W1_SLAVE_DS2408 is not set
> CONFIG_W1_SLAVE_DS2413=3Dy
> # CONFIG_W1_SLAVE_DS2406 is not set
> CONFIG_W1_SLAVE_DS2423=3Dm
> # CONFIG_W1_SLAVE_DS2431 is not set
> CONFIG_W1_SLAVE_DS2433=3Dm
> CONFIG_W1_SLAVE_DS2433_CRC=3Dy
> CONFIG_W1_SLAVE_DS2760=3Dy
> CONFIG_W1_SLAVE_DS2780=3Dy
> CONFIG_W1_SLAVE_DS2781=3Dy
> CONFIG_W1_SLAVE_DS28E04=3Dy
> CONFIG_W1_SLAVE_BQ27000=3Dy
> CONFIG_POWER_SUPPLY=3Dy
> CONFIG_POWER_SUPPLY_DEBUG=3Dy
> CONFIG_PDA_POWER=3Dy
> CONFIG_GENERIC_ADC_BATTERY=3Dm
> # CONFIG_MAX8925_POWER is not set
> # CONFIG_WM8350_POWER is not set
> CONFIG_TEST_POWER=3Dy
> CONFIG_BATTERY_DS2760=3Dy
> CONFIG_BATTERY_DS2780=3Dy
> CONFIG_BATTERY_DS2781=3Dy
> CONFIG_BATTERY_DS2782=3Dy
> CONFIG_BATTERY_SBS=3Dy
> CONFIG_BATTERY_BQ27x00=3Dm
> # CONFIG_BATTERY_BQ27X00_I2C is not set
> # CONFIG_BATTERY_BQ27X00_PLATFORM is not set
> # CONFIG_BATTERY_DA9030 is not set
> # CONFIG_BATTERY_DA9052 is not set
> CONFIG_AXP288_FUEL_GAUGE=3Dm
> CONFIG_BATTERY_MAX17040=3Dy
> CONFIG_BATTERY_MAX17042=3Dm
> # CONFIG_CHARGER_PCF50633 is not set
> CONFIG_CHARGER_ISP1704=3Dm
> CONFIG_CHARGER_MAX8903=3Dy
> CONFIG_CHARGER_TWL4030=3Dy
> # CONFIG_CHARGER_LP8727 is not set
> CONFIG_CHARGER_GPIO=3Dy
> CONFIG_CHARGER_MANAGER=3Dy
> CONFIG_CHARGER_MAX14577=3Dy
> CONFIG_CHARGER_BQ2415X=3Dm
> CONFIG_CHARGER_BQ24190=3Dm
> CONFIG_CHARGER_BQ24735=3Dy
> CONFIG_CHARGER_SMB347=3Dm
> CONFIG_BATTERY_GAUGE_LTC2941=3Dy
> CONFIG_BATTERY_RT5033=3Dm
> # CONFIG_POWER_RESET is not set
> CONFIG_POWER_AVS=3Dy
> CONFIG_HWMON=3Dm
> CONFIG_HWMON_VID=3Dm
> # CONFIG_HWMON_DEBUG_CHIP is not set
>=20
> #
> # Native drivers
> #
> CONFIG_SENSORS_ABITUGURU=3Dm
> CONFIG_SENSORS_ABITUGURU3=3Dm
> CONFIG_SENSORS_AD7314=3Dm
> CONFIG_SENSORS_AD7414=3Dm
> # CONFIG_SENSORS_AD7418 is not set
> CONFIG_SENSORS_ADM1021=3Dm
> CONFIG_SENSORS_ADM1025=3Dm
> CONFIG_SENSORS_ADM1026=3Dm
> CONFIG_SENSORS_ADM1029=3Dm
> CONFIG_SENSORS_ADM1031=3Dm
> CONFIG_SENSORS_ADM9240=3Dm
> CONFIG_SENSORS_ADT7X10=3Dm
> CONFIG_SENSORS_ADT7310=3Dm
> CONFIG_SENSORS_ADT7410=3Dm
> CONFIG_SENSORS_ADT7411=3Dm
> CONFIG_SENSORS_ADT7462=3Dm
> CONFIG_SENSORS_ADT7470=3Dm
> CONFIG_SENSORS_ADT7475=3Dm
> # CONFIG_SENSORS_ASC7621 is not set
> # CONFIG_SENSORS_K8TEMP is not set
> # CONFIG_SENSORS_K10TEMP is not set
> # CONFIG_SENSORS_FAM15H_POWER is not set
> CONFIG_SENSORS_APPLESMC=3Dm
> # CONFIG_SENSORS_ASB100 is not set
> # CONFIG_SENSORS_ATXP1 is not set
> # CONFIG_SENSORS_DS620 is not set
> # CONFIG_SENSORS_DS1621 is not set
> CONFIG_SENSORS_DA9052_ADC=3Dm
> # CONFIG_SENSORS_DA9055 is not set
> # CONFIG_SENSORS_I5K_AMB is not set
> # CONFIG_SENSORS_F71805F is not set
> CONFIG_SENSORS_F71882FG=3Dm
> # CONFIG_SENSORS_F75375S is not set
> CONFIG_SENSORS_MC13783_ADC=3Dm
> # CONFIG_SENSORS_FSCHMD is not set
> # CONFIG_SENSORS_GL518SM is not set
> CONFIG_SENSORS_GL520SM=3Dm
> # CONFIG_SENSORS_G760A is not set
> CONFIG_SENSORS_G762=3Dm
> CONFIG_SENSORS_GPIO_FAN=3Dm
> CONFIG_SENSORS_HIH6130=3Dm
> CONFIG_SENSORS_IBMAEM=3Dm
> CONFIG_SENSORS_IBMPEX=3Dm
> CONFIG_SENSORS_IIO_HWMON=3Dm
> # CONFIG_SENSORS_I5500 is not set
> CONFIG_SENSORS_CORETEMP=3Dm
> # CONFIG_SENSORS_IT87 is not set
> CONFIG_SENSORS_JC42=3Dm
> CONFIG_SENSORS_POWR1220=3Dm
> CONFIG_SENSORS_LINEAGE=3Dm
> CONFIG_SENSORS_LTC2945=3Dm
> CONFIG_SENSORS_LTC4151=3Dm
> # CONFIG_SENSORS_LTC4215 is not set
> CONFIG_SENSORS_LTC4222=3Dm
> CONFIG_SENSORS_LTC4245=3Dm
> CONFIG_SENSORS_LTC4260=3Dm
> # CONFIG_SENSORS_LTC4261 is not set
> CONFIG_SENSORS_MAX1111=3Dm
> # CONFIG_SENSORS_MAX16065 is not set
> CONFIG_SENSORS_MAX1619=3Dm
> # CONFIG_SENSORS_MAX1668 is not set
> # CONFIG_SENSORS_MAX197 is not set
> CONFIG_SENSORS_MAX6639=3Dm
> # CONFIG_SENSORS_MAX6642 is not set
> CONFIG_SENSORS_MAX6650=3Dm
> CONFIG_SENSORS_MAX6697=3Dm
> CONFIG_SENSORS_HTU21=3Dm
> CONFIG_SENSORS_MCP3021=3Dm
> # CONFIG_SENSORS_MENF21BMC_HWMON is not set
> CONFIG_SENSORS_ADCXX=3Dm
> CONFIG_SENSORS_LM63=3Dm
> CONFIG_SENSORS_LM70=3Dm
> CONFIG_SENSORS_LM73=3Dm
> CONFIG_SENSORS_LM75=3Dm
> CONFIG_SENSORS_LM77=3Dm
> CONFIG_SENSORS_LM78=3Dm
> CONFIG_SENSORS_LM80=3Dm
> CONFIG_SENSORS_LM83=3Dm
> CONFIG_SENSORS_LM85=3Dm
> CONFIG_SENSORS_LM87=3Dm
> # CONFIG_SENSORS_LM90 is not set
> CONFIG_SENSORS_LM92=3Dm
> # CONFIG_SENSORS_LM93 is not set
> CONFIG_SENSORS_LM95234=3Dm
> # CONFIG_SENSORS_LM95241 is not set
> # CONFIG_SENSORS_LM95245 is not set
> CONFIG_SENSORS_PC87360=3Dm
> CONFIG_SENSORS_PC87427=3Dm
> # CONFIG_SENSORS_NTC_THERMISTOR is not set
> CONFIG_SENSORS_NCT6683=3Dm
> CONFIG_SENSORS_NCT6775=3Dm
> # CONFIG_SENSORS_NCT7802 is not set
> CONFIG_SENSORS_NCT7904=3Dm
> CONFIG_SENSORS_PCF8591=3Dm
> CONFIG_PMBUS=3Dm
> # CONFIG_SENSORS_PMBUS is not set
> CONFIG_SENSORS_ADM1275=3Dm
> CONFIG_SENSORS_LM25066=3Dm
> # CONFIG_SENSORS_LTC2978 is not set
> # CONFIG_SENSORS_MAX16064 is not set
> CONFIG_SENSORS_MAX34440=3Dm
> CONFIG_SENSORS_MAX8688=3Dm
> CONFIG_SENSORS_TPS40422=3Dm
> # CONFIG_SENSORS_UCD9000 is not set
> # CONFIG_SENSORS_UCD9200 is not set
> # CONFIG_SENSORS_ZL6100 is not set
> CONFIG_SENSORS_SHT15=3Dm
> # CONFIG_SENSORS_SHT21 is not set
> # CONFIG_SENSORS_SHTC1 is not set
> # CONFIG_SENSORS_SIS5595 is not set
> CONFIG_SENSORS_DME1737=3Dm
> # CONFIG_SENSORS_EMC1403 is not set
> CONFIG_SENSORS_EMC2103=3Dm
> # CONFIG_SENSORS_EMC6W201 is not set
> CONFIG_SENSORS_SMSC47M1=3Dm
> CONFIG_SENSORS_SMSC47M192=3Dm
> CONFIG_SENSORS_SMSC47B397=3Dm
> # CONFIG_SENSORS_SCH56XX_COMMON is not set
> CONFIG_SENSORS_SMM665=3Dm
> CONFIG_SENSORS_ADC128D818=3Dm
> CONFIG_SENSORS_ADS1015=3Dm
> CONFIG_SENSORS_ADS7828=3Dm
> # CONFIG_SENSORS_ADS7871 is not set
> CONFIG_SENSORS_AMC6821=3Dm
> CONFIG_SENSORS_INA209=3Dm
> CONFIG_SENSORS_INA2XX=3Dm
> CONFIG_SENSORS_THMC50=3Dm
> CONFIG_SENSORS_TMP102=3Dm
> CONFIG_SENSORS_TMP103=3Dm
> CONFIG_SENSORS_TMP401=3Dm
> # CONFIG_SENSORS_TMP421 is not set
> CONFIG_SENSORS_VIA_CPUTEMP=3Dm
> # CONFIG_SENSORS_VIA686A is not set
> CONFIG_SENSORS_VT1211=3Dm
> # CONFIG_SENSORS_VT8231 is not set
> # CONFIG_SENSORS_W83781D is not set
> # CONFIG_SENSORS_W83791D is not set
> CONFIG_SENSORS_W83792D=3Dm
> CONFIG_SENSORS_W83793=3Dm
> CONFIG_SENSORS_W83795=3Dm
> CONFIG_SENSORS_W83795_FANCTRL=3Dy
> CONFIG_SENSORS_W83L785TS=3Dm
> # CONFIG_SENSORS_W83L786NG is not set
> CONFIG_SENSORS_W83627HF=3Dm
> CONFIG_SENSORS_W83627EHF=3Dm
> # CONFIG_SENSORS_WM8350 is not set
>=20
> #
> # ACPI drivers
> #
> # CONFIG_SENSORS_ACPI_POWER is not set
> # CONFIG_SENSORS_ATK0110 is not set
> CONFIG_THERMAL=3Dy
> # CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
> # CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
> CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=3Dy
> CONFIG_THERMAL_GOV_FAIR_SHARE=3Dy
> # CONFIG_THERMAL_GOV_STEP_WISE is not set
> # CONFIG_THERMAL_GOV_BANG_BANG is not set
> CONFIG_THERMAL_GOV_USER_SPACE=3Dy
> # CONFIG_THERMAL_EMULATION is not set
> # CONFIG_INT340X_THERMAL is not set
>=20
> #
> # Texas Instruments thermal drivers
> #
> # CONFIG_WATCHDOG is not set
> CONFIG_SSB_POSSIBLE=3Dy
>=20
> #
> # Sonics Silicon Backplane
> #
> # CONFIG_SSB is not set
> CONFIG_BCMA_POSSIBLE=3Dy
>=20
> #
> # Broadcom specific AMBA
> #
> CONFIG_BCMA=3Dy
> CONFIG_BCMA_HOST_PCI_POSSIBLE=3Dy
> CONFIG_BCMA_HOST_PCI=3Dy
> CONFIG_BCMA_HOST_SOC=3Dy
> CONFIG_BCMA_DRIVER_PCI=3Dy
> CONFIG_BCMA_DRIVER_GMAC_CMN=3Dy
> CONFIG_BCMA_DRIVER_GPIO=3Dy
> CONFIG_BCMA_DEBUG=3Dy
>=20
> #
> # Multifunction device drivers
> #
> CONFIG_MFD_CORE=3Dy
> # CONFIG_MFD_CS5535 is not set
> # CONFIG_MFD_AS3711 is not set
> # CONFIG_PMIC_ADP5520 is not set
> CONFIG_MFD_AAT2870_CORE=3Dy
> CONFIG_MFD_BCM590XX=3Dm
> CONFIG_MFD_AXP20X=3Dy
> CONFIG_MFD_CROS_EC=3Dy
> # CONFIG_MFD_CROS_EC_I2C is not set
> CONFIG_PMIC_DA903X=3Dy
> CONFIG_PMIC_DA9052=3Dy
> CONFIG_MFD_DA9052_SPI=3Dy
> # CONFIG_MFD_DA9052_I2C is not set
> CONFIG_MFD_DA9055=3Dy
> # CONFIG_MFD_DA9063 is not set
> CONFIG_MFD_DA9150=3Dm
> CONFIG_MFD_DLN2=3Dm
> CONFIG_MFD_MC13XXX=3Dy
> CONFIG_MFD_MC13XXX_SPI=3Dy
> CONFIG_MFD_MC13XXX_I2C=3Dy
> CONFIG_HTC_PASIC3=3Dy
> # CONFIG_HTC_I2CPLD is not set
> # CONFIG_LPC_ICH is not set
> # CONFIG_LPC_SCH is not set
> CONFIG_INTEL_SOC_PMIC=3Dy
> # CONFIG_MFD_JANZ_CMODIO is not set
> # CONFIG_MFD_KEMPLD is not set
> CONFIG_MFD_88PM800=3Dm
> CONFIG_MFD_88PM805=3Dm
> # CONFIG_MFD_88PM860X is not set
> CONFIG_MFD_MAX14577=3Dy
> # CONFIG_MFD_MAX77693 is not set
> # CONFIG_MFD_MAX77843 is not set
> # CONFIG_MFD_MAX8907 is not set
> CONFIG_MFD_MAX8925=3Dy
> CONFIG_MFD_MAX8997=3Dy
> # CONFIG_MFD_MAX8998 is not set
> CONFIG_MFD_MT6397=3Dy
> CONFIG_MFD_MENF21BMC=3Dy
> CONFIG_EZX_PCAP=3Dy
> # CONFIG_MFD_VIPERBOARD is not set
> # CONFIG_MFD_RETU is not set
> CONFIG_MFD_PCF50633=3Dy
> CONFIG_PCF50633_ADC=3Dm
> CONFIG_PCF50633_GPIO=3Dy
> # CONFIG_MFD_RDC321X is not set
> # CONFIG_MFD_RTSX_PCI is not set
> CONFIG_MFD_RT5033=3Dm
> CONFIG_MFD_RTSX_USB=3Dm
> CONFIG_MFD_RC5T583=3Dy
> CONFIG_MFD_RN5T618=3Dy
> CONFIG_MFD_SEC_CORE=3Dy
> # CONFIG_MFD_SI476X_CORE is not set
> CONFIG_MFD_SM501=3Dy
> CONFIG_MFD_SM501_GPIO=3Dy
> CONFIG_MFD_SKY81452=3Dm
> # CONFIG_MFD_SMSC is not set
> CONFIG_ABX500_CORE=3Dy
> CONFIG_AB3100_CORE=3Dy
> CONFIG_AB3100_OTP=3Dm
> CONFIG_MFD_SYSCON=3Dy
> # CONFIG_MFD_TI_AM335X_TSCADC is not set
> # CONFIG_MFD_LP3943 is not set
> # CONFIG_MFD_LP8788 is not set
> CONFIG_MFD_PALMAS=3Dy
> CONFIG_TPS6105X=3Dm
> # CONFIG_TPS65010 is not set
> CONFIG_TPS6507X=3Dy
> # CONFIG_MFD_TPS65090 is not set
> CONFIG_MFD_TPS65217=3Dm
> CONFIG_MFD_TPS65218=3Dy
> CONFIG_MFD_TPS6586X=3Dy
> # CONFIG_MFD_TPS65910 is not set
> # CONFIG_MFD_TPS65912 is not set
> # CONFIG_MFD_TPS65912_I2C is not set
> # CONFIG_MFD_TPS65912_SPI is not set
> # CONFIG_MFD_TPS80031 is not set
> CONFIG_TWL4030_CORE=3Dy
> # CONFIG_MFD_TWL4030_AUDIO is not set
> # CONFIG_TWL6040_CORE is not set
> CONFIG_MFD_WL1273_CORE=3Dm
> CONFIG_MFD_LM3533=3Dm
> # CONFIG_MFD_TIMBERDALE is not set
> # CONFIG_MFD_TMIO is not set
> # CONFIG_MFD_VX855 is not set
> CONFIG_MFD_ARIZONA=3Dy
> # CONFIG_MFD_ARIZONA_I2C is not set
> CONFIG_MFD_ARIZONA_SPI=3Dy
> # CONFIG_MFD_WM5102 is not set
> # CONFIG_MFD_WM5110 is not set
> CONFIG_MFD_WM8997=3Dy
> # CONFIG_MFD_WM8400 is not set
> # CONFIG_MFD_WM831X_I2C is not set
> # CONFIG_MFD_WM831X_SPI is not set
> CONFIG_MFD_WM8350=3Dy
> CONFIG_MFD_WM8350_I2C=3Dy
> # CONFIG_MFD_WM8994 is not set
> CONFIG_REGULATOR=3Dy
> # CONFIG_REGULATOR_DEBUG is not set
> CONFIG_REGULATOR_FIXED_VOLTAGE=3Dm
> # CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
> CONFIG_REGULATOR_USERSPACE_CONSUMER=3Dm
> CONFIG_REGULATOR_88PM800=3Dm
> CONFIG_REGULATOR_ACT8865=3Dm
> CONFIG_REGULATOR_AD5398=3Dm
> CONFIG_REGULATOR_ANATOP=3Dm
> # CONFIG_REGULATOR_AAT2870 is not set
> CONFIG_REGULATOR_AB3100=3Dm
> CONFIG_REGULATOR_AXP20X=3Dm
> # CONFIG_REGULATOR_BCM590XX is not set
> CONFIG_REGULATOR_DA903X=3Dm
> CONFIG_REGULATOR_DA9052=3Dy
> # CONFIG_REGULATOR_DA9055 is not set
> CONFIG_REGULATOR_DA9210=3Dm
> # CONFIG_REGULATOR_DA9211 is not set
> CONFIG_REGULATOR_FAN53555=3Dy
> CONFIG_REGULATOR_GPIO=3Dm
> CONFIG_REGULATOR_ISL9305=3Dy
> # CONFIG_REGULATOR_ISL6271A is not set
> # CONFIG_REGULATOR_LP3971 is not set
> # CONFIG_REGULATOR_LP3972 is not set
> CONFIG_REGULATOR_LP872X=3Dy
> # CONFIG_REGULATOR_LP8755 is not set
> CONFIG_REGULATOR_LTC3589=3Dy
> CONFIG_REGULATOR_MAX14577=3Dm
> CONFIG_REGULATOR_MAX1586=3Dm
> CONFIG_REGULATOR_MAX8649=3Dy
> # CONFIG_REGULATOR_MAX8660 is not set
> # CONFIG_REGULATOR_MAX8925 is not set
> CONFIG_REGULATOR_MAX8952=3Dy
> # CONFIG_REGULATOR_MAX8973 is not set
> # CONFIG_REGULATOR_MAX8997 is not set
> CONFIG_REGULATOR_MC13XXX_CORE=3Dy
> # CONFIG_REGULATOR_MC13783 is not set
> CONFIG_REGULATOR_MC13892=3Dy
> # CONFIG_REGULATOR_MT6397 is not set
> CONFIG_REGULATOR_PALMAS=3Dy
> CONFIG_REGULATOR_PCAP=3Dm
> CONFIG_REGULATOR_PCF50633=3Dy
> CONFIG_REGULATOR_PFUZE100=3Dy
> CONFIG_REGULATOR_PWM=3Dm
> # CONFIG_REGULATOR_RC5T583 is not set
> # CONFIG_REGULATOR_RN5T618 is not set
> CONFIG_REGULATOR_RT5033=3Dm
> CONFIG_REGULATOR_S2MPA01=3Dm
> # CONFIG_REGULATOR_S2MPS11 is not set
> CONFIG_REGULATOR_S5M8767=3Dm
> CONFIG_REGULATOR_SKY81452=3Dm
> # CONFIG_REGULATOR_TPS51632 is not set
> CONFIG_REGULATOR_TPS6105X=3Dm
> CONFIG_REGULATOR_TPS62360=3Dm
> # CONFIG_REGULATOR_TPS65023 is not set
> # CONFIG_REGULATOR_TPS6507X is not set
> CONFIG_REGULATOR_TPS65217=3Dm
> CONFIG_REGULATOR_TPS6524X=3Dy
> CONFIG_REGULATOR_TPS6586X=3Dm
> CONFIG_REGULATOR_TWL4030=3Dy
> CONFIG_REGULATOR_WM8350=3Dy
> CONFIG_MEDIA_SUPPORT=3Dm
>=20
> #
> # Multimedia core support
> #
> # CONFIG_MEDIA_CAMERA_SUPPORT is not set
> # CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
> CONFIG_MEDIA_DIGITAL_TV_SUPPORT=3Dy
> # CONFIG_MEDIA_RADIO_SUPPORT is not set
> # CONFIG_MEDIA_SDR_SUPPORT is not set
> # CONFIG_MEDIA_RC_SUPPORT is not set
> CONFIG_VIDEO_ADV_DEBUG=3Dy
> # CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
> CONFIG_DVB_CORE=3Dm
> # CONFIG_TTPCI_EEPROM is not set
> CONFIG_DVB_MAX_ADAPTERS=3D8
> CONFIG_DVB_DYNAMIC_MINORS=3Dy
>=20
> #
> # Media drivers
> #
> CONFIG_MEDIA_USB_SUPPORT=3Dy
>=20
> #
> # Analog/digital TV USB devices
> #
> # CONFIG_VIDEO_AU0828 is not set
>=20
> #
> # Digital TV USB devices
> #
> CONFIG_DVB_USB_V2=3Dm
> CONFIG_DVB_USB_AF9015=3Dm
> CONFIG_DVB_USB_AF9035=3Dm
> CONFIG_DVB_USB_ANYSEE=3Dm
> CONFIG_DVB_USB_AU6610=3Dm
> # CONFIG_DVB_USB_AZ6007 is not set
> CONFIG_DVB_USB_CE6230=3Dm
> CONFIG_DVB_USB_EC168=3Dm
> # CONFIG_DVB_USB_GL861 is not set
> CONFIG_DVB_USB_MXL111SF=3Dm
> CONFIG_DVB_USB_RTL28XXU=3Dm
> # CONFIG_DVB_USB_DVBSKY is not set
> # CONFIG_DVB_TTUSB_BUDGET is not set
> # CONFIG_DVB_TTUSB_DEC is not set
> CONFIG_SMS_USB_DRV=3Dm
> CONFIG_DVB_B2C2_FLEXCOP_USB=3Dm
> # CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG is not set
> CONFIG_DVB_AS102=3Dm
>=20
> #
> # Webcam, TV (analog/digital) USB devices
> #
> # CONFIG_MEDIA_PCI_SUPPORT is not set
>=20
> #
> # Supported MMC/SDIO adapters
> #
> CONFIG_SMS_SDIO_DRV=3Dm
>=20
> #
> # Supported FireWire (IEEE 1394) Adapters
> #
> CONFIG_DVB_FIREDTV=3Dm
> CONFIG_DVB_FIREDTV_INPUT=3Dy
> CONFIG_MEDIA_COMMON_OPTIONS=3Dy
>=20
> #
> # common driver options
> #
> CONFIG_VIDEO_TVEEPROM=3Dm
> # CONFIG_CYPRESS_FIRMWARE is not set
> CONFIG_DVB_B2C2_FLEXCOP=3Dm
> CONFIG_SMS_SIANO_MDTV=3Dm
> # CONFIG_SMS_SIANO_DEBUGFS is not set
>=20
> #
> # Media ancillary drivers (tuners, sensors, i2c, frontends)
> #
> # CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
> CONFIG_MEDIA_ATTACH=3Dy
> CONFIG_MEDIA_TUNER=3Dm
>=20
> #
> # Customize TV tuners
> #
> CONFIG_MEDIA_TUNER_SIMPLE=3Dm
> # CONFIG_MEDIA_TUNER_TDA8290 is not set
> CONFIG_MEDIA_TUNER_TDA827X=3Dm
> # CONFIG_MEDIA_TUNER_TDA18271 is not set
> CONFIG_MEDIA_TUNER_TDA9887=3Dm
> CONFIG_MEDIA_TUNER_TEA5761=3Dm
> # CONFIG_MEDIA_TUNER_TEA5767 is not set
> CONFIG_MEDIA_TUNER_MT20XX=3Dm
> # CONFIG_MEDIA_TUNER_MT2060 is not set
> CONFIG_MEDIA_TUNER_MT2063=3Dm
> CONFIG_MEDIA_TUNER_MT2266=3Dm
> CONFIG_MEDIA_TUNER_MT2131=3Dm
> # CONFIG_MEDIA_TUNER_QT1010 is not set
> CONFIG_MEDIA_TUNER_XC2028=3Dm
> CONFIG_MEDIA_TUNER_XC5000=3Dm
> CONFIG_MEDIA_TUNER_XC4000=3Dm
> # CONFIG_MEDIA_TUNER_MXL5005S is not set
> CONFIG_MEDIA_TUNER_MXL5007T=3Dm
> # CONFIG_MEDIA_TUNER_MC44S803 is not set
> # CONFIG_MEDIA_TUNER_MAX2165 is not set
> # CONFIG_MEDIA_TUNER_TDA18218 is not set
> CONFIG_MEDIA_TUNER_FC0011=3Dm
> CONFIG_MEDIA_TUNER_FC0012=3Dm
> CONFIG_MEDIA_TUNER_FC0013=3Dm
> CONFIG_MEDIA_TUNER_TDA18212=3Dm
> CONFIG_MEDIA_TUNER_E4000=3Dm
> CONFIG_MEDIA_TUNER_FC2580=3Dm
> CONFIG_MEDIA_TUNER_M88TS2022=3Dm
> # CONFIG_MEDIA_TUNER_M88RS6000T is not set
> CONFIG_MEDIA_TUNER_TUA9001=3Dm
> # CONFIG_MEDIA_TUNER_SI2157 is not set
> # CONFIG_MEDIA_TUNER_IT913X is not set
> # CONFIG_MEDIA_TUNER_R820T is not set
> # CONFIG_MEDIA_TUNER_MXL301RF is not set
> CONFIG_MEDIA_TUNER_QM1D1C0042=3Dm
>=20
> #
> # Customise DVB Frontends
> #
>=20
> #
> # Multistandard (satellite) frontends
> #
> # CONFIG_DVB_STB0899 is not set
> CONFIG_DVB_STB6100=3Dm
> CONFIG_DVB_STV090x=3Dm
> CONFIG_DVB_STV6110x=3Dm
> CONFIG_DVB_M88DS3103=3Dm
>=20
> #
> # Multistandard (cable + terrestrial) frontends
> #
> # CONFIG_DVB_DRXK is not set
> CONFIG_DVB_TDA18271C2DD=3Dm
> # CONFIG_DVB_SI2165 is not set
>=20
> #
> # DVB-S (satellite) frontends
> #
> CONFIG_DVB_CX24110=3Dm
> CONFIG_DVB_CX24123=3Dm
> CONFIG_DVB_MT312=3Dm
> CONFIG_DVB_ZL10036=3Dm
> CONFIG_DVB_ZL10039=3Dm
> # CONFIG_DVB_S5H1420 is not set
> CONFIG_DVB_STV0288=3Dm
> # CONFIG_DVB_STB6000 is not set
> CONFIG_DVB_STV0299=3Dm
> CONFIG_DVB_STV6110=3Dm
> CONFIG_DVB_STV0900=3Dm
> CONFIG_DVB_TDA8083=3Dm
> # CONFIG_DVB_TDA10086 is not set
> CONFIG_DVB_TDA8261=3Dm
> CONFIG_DVB_VES1X93=3Dm
> CONFIG_DVB_TUNER_ITD1000=3Dm
> CONFIG_DVB_TUNER_CX24113=3Dm
> # CONFIG_DVB_TDA826X is not set
> CONFIG_DVB_TUA6100=3Dm
> # CONFIG_DVB_CX24116 is not set
> CONFIG_DVB_CX24117=3Dm
> # CONFIG_DVB_SI21XX is not set
> CONFIG_DVB_TS2020=3Dm
> CONFIG_DVB_DS3000=3Dm
> # CONFIG_DVB_MB86A16 is not set
> # CONFIG_DVB_TDA10071 is not set
>=20
> #
> # DVB-T (terrestrial) frontends
> #
> # CONFIG_DVB_SP8870 is not set
> # CONFIG_DVB_SP887X is not set
> # CONFIG_DVB_CX22700 is not set
> CONFIG_DVB_CX22702=3Dm
> # CONFIG_DVB_S5H1432 is not set
> # CONFIG_DVB_DRXD is not set
> # CONFIG_DVB_L64781 is not set
> CONFIG_DVB_TDA1004X=3Dm
> # CONFIG_DVB_NXT6000 is not set
> CONFIG_DVB_MT352=3Dm
> CONFIG_DVB_ZL10353=3Dm
> CONFIG_DVB_DIB3000MB=3Dm
> CONFIG_DVB_DIB3000MC=3Dm
> CONFIG_DVB_DIB7000M=3Dm
> CONFIG_DVB_DIB7000P=3Dm
> CONFIG_DVB_DIB9000=3Dm
> CONFIG_DVB_TDA10048=3Dm
> CONFIG_DVB_AF9013=3Dm
> CONFIG_DVB_EC100=3Dm
> CONFIG_DVB_HD29L2=3Dm
> CONFIG_DVB_STV0367=3Dm
> CONFIG_DVB_CXD2820R=3Dm
> CONFIG_DVB_RTL2830=3Dm
> CONFIG_DVB_RTL2832=3Dm
> CONFIG_DVB_SI2168=3Dm
> CONFIG_DVB_AS102_FE=3Dm
>=20
> #
> # DVB-C (cable) frontends
> #
> # CONFIG_DVB_VES1820 is not set
> CONFIG_DVB_TDA10021=3Dm
> # CONFIG_DVB_TDA10023 is not set
> CONFIG_DVB_STV0297=3Dm
>=20
> #
> # ATSC (North American/Korean Terrestrial/Cable DTV) frontends
> #
> CONFIG_DVB_NXT200X=3Dm
> CONFIG_DVB_OR51211=3Dm
> CONFIG_DVB_OR51132=3Dm
> CONFIG_DVB_BCM3510=3Dm
> CONFIG_DVB_LGDT330X=3Dm
> CONFIG_DVB_LGDT3305=3Dm
> # CONFIG_DVB_LG2160 is not set
> CONFIG_DVB_S5H1409=3Dm
> CONFIG_DVB_AU8522=3Dm
> CONFIG_DVB_AU8522_DTV=3Dm
> # CONFIG_DVB_S5H1411 is not set
>=20
> #
> # ISDB-T (terrestrial) frontends
> #
> CONFIG_DVB_S921=3Dm
> CONFIG_DVB_DIB8000=3Dm
> # CONFIG_DVB_MB86A20S is not set
>=20
> #
> # ISDB-S (satellite) & ISDB-T (terrestrial) frontends
> #
> # CONFIG_DVB_TC90522 is not set
>=20
> #
> # Digital terrestrial only tuners/PLL
> #
> # CONFIG_DVB_PLL is not set
> CONFIG_DVB_TUNER_DIB0070=3Dm
> # CONFIG_DVB_TUNER_DIB0090 is not set
>=20
> #
> # SEC control devices for DVB-S
> #
> # CONFIG_DVB_DRX39XYJ is not set
> CONFIG_DVB_LNBP21=3Dm
> CONFIG_DVB_LNBP22=3Dm
> CONFIG_DVB_ISL6405=3Dm
> # CONFIG_DVB_ISL6421 is not set
> CONFIG_DVB_ISL6423=3Dm
> CONFIG_DVB_A8293=3Dm
> # CONFIG_DVB_SP2 is not set
> CONFIG_DVB_LGS8GL5=3Dm
> CONFIG_DVB_LGS8GXX=3Dm
> CONFIG_DVB_ATBM8830=3Dm
> CONFIG_DVB_TDA665x=3Dm
> CONFIG_DVB_IX2505V=3Dm
> CONFIG_DVB_M88RS2000=3Dm
> CONFIG_DVB_AF9033=3Dm
>=20
> #
> # Tools to develop new frontends
> #
> CONFIG_DVB_DUMMY_FE=3Dm
>=20
> #
> # Graphics support
> #
> # CONFIG_AGP is not set
> CONFIG_VGA_ARB=3Dy
> CONFIG_VGA_ARB_MAX_GPUS=3D16
> # CONFIG_VGA_SWITCHEROO is not set
>=20
> #
> # Direct Rendering Manager
> #
> CONFIG_DRM=3Dy
> CONFIG_DRM_KMS_HELPER=3Dy
> CONFIG_DRM_KMS_FB_HELPER=3Dy
> # CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
>=20
> #
> # I2C encoder or helper chips
> #
> # CONFIG_DRM_I2C_ADV7511 is not set
> # CONFIG_DRM_I2C_CH7006 is not set
> # CONFIG_DRM_I2C_SIL164 is not set
> CONFIG_DRM_I2C_NXP_TDA998X=3Dy
> # CONFIG_DRM_TDFX is not set
> # CONFIG_DRM_R128 is not set
> # CONFIG_DRM_RADEON is not set
> # CONFIG_DRM_NOUVEAU is not set
> # CONFIG_DRM_I915 is not set
> # CONFIG_DRM_MGA is not set
> # CONFIG_DRM_VIA is not set
> # CONFIG_DRM_SAVAGE is not set
> # CONFIG_DRM_VMWGFX is not set
> # CONFIG_DRM_GMA500 is not set
> CONFIG_DRM_UDL=3Dy
> # CONFIG_DRM_AST is not set
> # CONFIG_DRM_MGAG200 is not set
> # CONFIG_DRM_CIRRUS_QEMU is not set
> # CONFIG_DRM_QXL is not set
> # CONFIG_DRM_BOCHS is not set
>=20
> #
> # Frame buffer Devices
> #
> CONFIG_FB=3Dy
> CONFIG_FIRMWARE_EDID=3Dy
> CONFIG_FB_CMDLINE=3Dy
> # CONFIG_FB_DDC is not set
> CONFIG_FB_BOOT_VESA_SUPPORT=3Dy
> CONFIG_FB_CFB_FILLRECT=3Dy
> CONFIG_FB_CFB_COPYAREA=3Dy
> CONFIG_FB_CFB_IMAGEBLIT=3Dy
> # CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
> CONFIG_FB_SYS_FILLRECT=3Dy
> CONFIG_FB_SYS_COPYAREA=3Dy
> CONFIG_FB_SYS_IMAGEBLIT=3Dy
> CONFIG_FB_FOREIGN_ENDIAN=3Dy
> # CONFIG_FB_BOTH_ENDIAN is not set
> CONFIG_FB_BIG_ENDIAN=3Dy
> # CONFIG_FB_LITTLE_ENDIAN is not set
> CONFIG_FB_SYS_FOPS=3Dy
> CONFIG_FB_DEFERRED_IO=3Dy
> # CONFIG_FB_SVGALIB is not set
> # CONFIG_FB_MACMODES is not set
> CONFIG_FB_BACKLIGHT=3Dy
> CONFIG_FB_MODE_HELPERS=3Dy
> # CONFIG_FB_TILEBLITTING is not set
>=20
> #
> # Frame buffer hardware drivers
> #
> # CONFIG_FB_CIRRUS is not set
> # CONFIG_FB_PM2 is not set
> # CONFIG_FB_CYBER2000 is not set
> # CONFIG_FB_ARC is not set
> # CONFIG_FB_ASILIANT is not set
> # CONFIG_FB_IMSTT is not set
> # CONFIG_FB_VGA16 is not set
> CONFIG_FB_VESA=3Dy
> # CONFIG_FB_N411 is not set
> CONFIG_FB_HGA=3Dy
> CONFIG_FB_OPENCORES=3Dy
> # CONFIG_FB_S1D13XXX is not set
> # CONFIG_FB_NVIDIA is not set
> # CONFIG_FB_RIVA is not set
> # CONFIG_FB_I740 is not set
> # CONFIG_FB_LE80578 is not set
> # CONFIG_FB_MATROX is not set
> # CONFIG_FB_RADEON is not set
> # CONFIG_FB_ATY128 is not set
> # CONFIG_FB_ATY is not set
> # CONFIG_FB_S3 is not set
> # CONFIG_FB_SAVAGE is not set
> # CONFIG_FB_SIS is not set
> # CONFIG_FB_VIA is not set
> # CONFIG_FB_NEOMAGIC is not set
> # CONFIG_FB_KYRO is not set
> # CONFIG_FB_3DFX is not set
> # CONFIG_FB_VOODOO1 is not set
> # CONFIG_FB_VT8623 is not set
> # CONFIG_FB_TRIDENT is not set
> # CONFIG_FB_ARK is not set
> # CONFIG_FB_PM3 is not set
> # CONFIG_FB_CARMINE is not set
> # CONFIG_FB_GEODE is not set
> CONFIG_FB_SM501=3Dy
> CONFIG_FB_SMSCUFX=3Dy
> # CONFIG_FB_UDL is not set
> # CONFIG_FB_VIRTUAL is not set
> # CONFIG_FB_METRONOME is not set
> # CONFIG_FB_MB862XX is not set
> # CONFIG_FB_BROADSHEET is not set
> # CONFIG_FB_AUO_K190X is not set
> # CONFIG_FB_SIMPLE is not set
> CONFIG_BACKLIGHT_LCD_SUPPORT=3Dy
> CONFIG_LCD_CLASS_DEVICE=3Dy
> CONFIG_LCD_L4F00242T03=3Dm
> CONFIG_LCD_LMS283GF05=3Dm
> CONFIG_LCD_LTV350QV=3Dm
> CONFIG_LCD_ILI922X=3Dy
> CONFIG_LCD_ILI9320=3Dy
> CONFIG_LCD_TDO24M=3Dy
> CONFIG_LCD_VGG2432A4=3Dm
> CONFIG_LCD_PLATFORM=3Dm
> CONFIG_LCD_S6E63M0=3Dm
> # CONFIG_LCD_LD9040 is not set
> CONFIG_LCD_AMS369FG06=3Dy
> CONFIG_LCD_LMS501KF03=3Dy
> # CONFIG_LCD_HX8357 is not set
> CONFIG_BACKLIGHT_CLASS_DEVICE=3Dy
> CONFIG_BACKLIGHT_GENERIC=3Dm
> CONFIG_BACKLIGHT_LM3533=3Dm
> CONFIG_BACKLIGHT_PWM=3Dm
> CONFIG_BACKLIGHT_DA903X=3Dm
> CONFIG_BACKLIGHT_DA9052=3Dy
> # CONFIG_BACKLIGHT_MAX8925 is not set
> # CONFIG_BACKLIGHT_APPLE is not set
> # CONFIG_BACKLIGHT_SAHARA is not set
> # CONFIG_BACKLIGHT_ADP8860 is not set
> # CONFIG_BACKLIGHT_ADP8870 is not set
> CONFIG_BACKLIGHT_PCF50633=3Dm
> CONFIG_BACKLIGHT_AAT2870=3Dm
> CONFIG_BACKLIGHT_LM3630A=3Dm
> # CONFIG_BACKLIGHT_LM3639 is not set
> CONFIG_BACKLIGHT_LP855X=3Dm
> CONFIG_BACKLIGHT_PANDORA=3Dm
> # CONFIG_BACKLIGHT_SKY81452 is not set
> CONFIG_BACKLIGHT_TPS65217=3Dm
> # CONFIG_BACKLIGHT_GPIO is not set
> CONFIG_BACKLIGHT_LV5207LP=3Dy
> CONFIG_BACKLIGHT_BD6107=3Dy
> # CONFIG_VGASTATE is not set
> CONFIG_HDMI=3Dy
> CONFIG_LOGO=3Dy
> # CONFIG_LOGO_LINUX_MONO is not set
> CONFIG_LOGO_LINUX_VGA16=3Dy
> # CONFIG_LOGO_LINUX_CLUT224 is not set
> # CONFIG_SOUND is not set
>=20
> #
> # HID support
> #
> CONFIG_HID=3Dy
> CONFIG_HID_BATTERY_STRENGTH=3Dy
> # CONFIG_HIDRAW is not set
> CONFIG_UHID=3Dm
> CONFIG_HID_GENERIC=3Dm
>=20
> #
> # Special HID drivers
> #
> CONFIG_HID_A4TECH=3Dy
> CONFIG_HID_ACRUX=3Dm
> CONFIG_HID_ACRUX_FF=3Dy
> # CONFIG_HID_APPLE is not set
> CONFIG_HID_APPLEIR=3Dm
> CONFIG_HID_AUREAL=3Dy
> # CONFIG_HID_BELKIN is not set
> # CONFIG_HID_BETOP_FF is not set
> CONFIG_HID_CHERRY=3Dm
> CONFIG_HID_CHICONY=3Dy
> # CONFIG_HID_CP2112 is not set
> # CONFIG_HID_CYPRESS is not set
> CONFIG_HID_DRAGONRISE=3Dm
> CONFIG_DRAGONRISE_FF=3Dy
> # CONFIG_HID_EMS_FF is not set
> CONFIG_HID_ELECOM=3Dm
> CONFIG_HID_ELO=3Dm
> CONFIG_HID_EZKEY=3Dm
> CONFIG_HID_HOLTEK=3Dm
> # CONFIG_HOLTEK_FF is not set
> CONFIG_HID_GT683R=3Dm
> CONFIG_HID_KEYTOUCH=3Dy
> # CONFIG_HID_KYE is not set
> CONFIG_HID_UCLOGIC=3Dm
> # CONFIG_HID_WALTOP is not set
> CONFIG_HID_GYRATION=3Dy
> CONFIG_HID_ICADE=3Dm
> CONFIG_HID_TWINHAN=3Dm
> CONFIG_HID_KENSINGTON=3Dm
> # CONFIG_HID_LCPOWER is not set
> # CONFIG_HID_LENOVO is not set
> CONFIG_HID_LOGITECH=3Dy
> CONFIG_HID_LOGITECH_HIDPP=3Dy
> # CONFIG_LOGITECH_FF is not set
> # CONFIG_LOGIRUMBLEPAD2_FF is not set
> # CONFIG_LOGIG940_FF is not set
> CONFIG_LOGIWHEELS_FF=3Dy
> CONFIG_HID_MAGICMOUSE=3Dm
> CONFIG_HID_MICROSOFT=3Dy
> CONFIG_HID_MONTEREY=3Dm
> CONFIG_HID_MULTITOUCH=3Dm
> CONFIG_HID_NTRIG=3Dm
> CONFIG_HID_ORTEK=3Dy
> # CONFIG_HID_PANTHERLORD is not set
> # CONFIG_HID_PENMOUNT is not set
> CONFIG_HID_PETALYNX=3Dm
> # CONFIG_HID_PICOLCD is not set
> CONFIG_HID_PLANTRONICS=3Dy
> CONFIG_HID_PRIMAX=3Dm
> # CONFIG_HID_ROCCAT is not set
> # CONFIG_HID_SAITEK is not set
> CONFIG_HID_SAMSUNG=3Dm
> CONFIG_HID_SONY=3Dm
> CONFIG_SONY_FF=3Dy
> # CONFIG_HID_SPEEDLINK is not set
> CONFIG_HID_STEELSERIES=3Dy
> # CONFIG_HID_SUNPLUS is not set
> CONFIG_HID_RMI=3Dm
> CONFIG_HID_GREENASIA=3Dy
> # CONFIG_GREENASIA_FF is not set
> CONFIG_HID_SMARTJOYPLUS=3Dm
> CONFIG_SMARTJOYPLUS_FF=3Dy
> CONFIG_HID_TIVO=3Dy
> # CONFIG_HID_TOPSEED is not set
> CONFIG_HID_THINGM=3Dm
> CONFIG_HID_THRUSTMASTER=3Dm
> # CONFIG_THRUSTMASTER_FF is not set
> CONFIG_HID_WACOM=3Dm
> CONFIG_HID_WIIMOTE=3Dy
> CONFIG_HID_XINMO=3Dy
> # CONFIG_HID_ZEROPLUS is not set
> # CONFIG_HID_ZYDACRON is not set
> CONFIG_HID_SENSOR_HUB=3Dy
> CONFIG_HID_SENSOR_CUSTOM_SENSOR=3Dm
>=20
> #
> # USB HID support
> #
> CONFIG_USB_HID=3Dm
> # CONFIG_HID_PID is not set
> CONFIG_USB_HIDDEV=3Dy
>=20
> #
> # USB HID Boot Protocol drivers
> #
> # CONFIG_USB_KBD is not set
> CONFIG_USB_MOUSE=3Dm
>=20
> #
> # I2C HID support
> #
> CONFIG_I2C_HID=3Dm
> CONFIG_USB_OHCI_LITTLE_ENDIAN=3Dy
> CONFIG_USB_SUPPORT=3Dy
> CONFIG_USB_COMMON=3Dy
> CONFIG_USB_ARCH_HAS_HCD=3Dy
> CONFIG_USB=3Dy
> # CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set
>=20
> #
> # Miscellaneous USB options
> #
> CONFIG_USB_DEFAULT_PERSIST=3Dy
> CONFIG_USB_DYNAMIC_MINORS=3Dy
> # CONFIG_USB_OTG is not set
> # CONFIG_USB_OTG_WHITELIST is not set
> CONFIG_USB_OTG_BLACKLIST_HUB=3Dy
> # CONFIG_USB_OTG_FSM is not set
> CONFIG_USB_MON=3Dm
> CONFIG_USB_WUSB=3Dy
> CONFIG_USB_WUSB_CBAF=3Dy
> # CONFIG_USB_WUSB_CBAF_DEBUG is not set
>=20
> #
> # USB Host Controller Drivers
> #
> CONFIG_USB_C67X00_HCD=3Dm
> # CONFIG_USB_XHCI_HCD is not set
> CONFIG_USB_EHCI_HCD=3Dm
> CONFIG_USB_EHCI_ROOT_HUB_TT=3Dy
> # CONFIG_USB_EHCI_TT_NEWSCHED is not set
> CONFIG_USB_EHCI_PCI=3Dm
> # CONFIG_USB_EHCI_HCD_PLATFORM is not set
> # CONFIG_USB_OXU210HP_HCD is not set
> CONFIG_USB_ISP116X_HCD=3Dy
> # CONFIG_USB_ISP1362_HCD is not set
> # CONFIG_USB_FUSBH200_HCD is not set
> # CONFIG_USB_FOTG210_HCD is not set
> # CONFIG_USB_MAX3421_HCD is not set
> CONFIG_USB_OHCI_HCD=3Dm
> CONFIG_USB_OHCI_HCD_PCI=3Dm
> # CONFIG_USB_OHCI_HCD_PLATFORM is not set
> # CONFIG_USB_UHCI_HCD is not set
> CONFIG_USB_U132_HCD=3Dy
> # CONFIG_USB_SL811_HCD is not set
> CONFIG_USB_R8A66597_HCD=3Dy
> # CONFIG_USB_WHCI_HCD is not set
> CONFIG_USB_HWA_HCD=3Dm
> # CONFIG_USB_HCD_BCMA is not set
> # CONFIG_USB_HCD_TEST_MODE is not set
>=20
> #
> # USB Device Class drivers
> #
> CONFIG_USB_ACM=3Dy
> CONFIG_USB_PRINTER=3Dm
> CONFIG_USB_WDM=3Dy
> CONFIG_USB_TMC=3Dm
>=20
> #
> # NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
> #
>=20
> #
> # also be needed; see USB_STORAGE Help for more info
> #
>=20
> #
> # USB Imaging devices
> #
> CONFIG_USB_MDC800=3Dm
> # CONFIG_USBIP_CORE is not set
> # CONFIG_USB_MUSB_HDRC is not set
> # CONFIG_USB_DWC3 is not set
> CONFIG_USB_DWC2=3Dy
> CONFIG_USB_DWC2_HOST=3Dy
>=20
> #
> # Gadget/Dual-role mode requires USB Gadget support to be enabled
> #
> CONFIG_USB_DWC2_PLATFORM=3Dy
> # CONFIG_USB_DWC2_PCI is not set
> CONFIG_USB_DWC2_DEBUG=3Dy
> # CONFIG_USB_DWC2_VERBOSE is not set
> # CONFIG_USB_DWC2_TRACK_MISSED_SOFS is not set
> CONFIG_USB_DWC2_DEBUG_PERIODIC=3Dy
> CONFIG_USB_CHIPIDEA=3Dm
> CONFIG_USB_CHIPIDEA_PCI=3Dm
> CONFIG_USB_CHIPIDEA_HOST=3Dy
> CONFIG_USB_CHIPIDEA_DEBUG=3Dy
> # CONFIG_USB_ISP1760 is not set
>=20
> #
> # USB port drivers
> #
> CONFIG_USB_SERIAL=3Dm
> CONFIG_USB_SERIAL_GENERIC=3Dy
> CONFIG_USB_SERIAL_SIMPLE=3Dm
> # CONFIG_USB_SERIAL_AIRCABLE is not set
> CONFIG_USB_SERIAL_ARK3116=3Dm
> CONFIG_USB_SERIAL_BELKIN=3Dm
> # CONFIG_USB_SERIAL_CH341 is not set
> CONFIG_USB_SERIAL_WHITEHEAT=3Dm
> CONFIG_USB_SERIAL_DIGI_ACCELEPORT=3Dm
> CONFIG_USB_SERIAL_CP210X=3Dm
> CONFIG_USB_SERIAL_CYPRESS_M8=3Dm
> # CONFIG_USB_SERIAL_EMPEG is not set
> # CONFIG_USB_SERIAL_FTDI_SIO is not set
> # CONFIG_USB_SERIAL_VISOR is not set
> CONFIG_USB_SERIAL_IPAQ=3Dm
> CONFIG_USB_SERIAL_IR=3Dm
> CONFIG_USB_SERIAL_EDGEPORT=3Dm
> CONFIG_USB_SERIAL_EDGEPORT_TI=3Dm
> CONFIG_USB_SERIAL_F81232=3Dm
> CONFIG_USB_SERIAL_GARMIN=3Dm
> # CONFIG_USB_SERIAL_IPW is not set
> CONFIG_USB_SERIAL_IUU=3Dm
> CONFIG_USB_SERIAL_KEYSPAN_PDA=3Dm
> CONFIG_USB_SERIAL_KEYSPAN=3Dm
> CONFIG_USB_SERIAL_KEYSPAN_MPR=3Dy
> CONFIG_USB_SERIAL_KEYSPAN_USA28=3Dy
> CONFIG_USB_SERIAL_KEYSPAN_USA28X=3Dy
> # CONFIG_USB_SERIAL_KEYSPAN_USA28XA is not set
> # CONFIG_USB_SERIAL_KEYSPAN_USA28XB is not set
> # CONFIG_USB_SERIAL_KEYSPAN_USA19 is not set
> # CONFIG_USB_SERIAL_KEYSPAN_USA18X is not set
> CONFIG_USB_SERIAL_KEYSPAN_USA19W=3Dy
> CONFIG_USB_SERIAL_KEYSPAN_USA19QW=3Dy
> CONFIG_USB_SERIAL_KEYSPAN_USA19QI=3Dy
> # CONFIG_USB_SERIAL_KEYSPAN_USA49W is not set
> # CONFIG_USB_SERIAL_KEYSPAN_USA49WLC is not set
> CONFIG_USB_SERIAL_KLSI=3Dm
> # CONFIG_USB_SERIAL_KOBIL_SCT is not set
> CONFIG_USB_SERIAL_MCT_U232=3Dm
> CONFIG_USB_SERIAL_METRO=3Dm
> CONFIG_USB_SERIAL_MOS7720=3Dm
> CONFIG_USB_SERIAL_MOS7840=3Dm
> CONFIG_USB_SERIAL_MXUPORT=3Dm
> CONFIG_USB_SERIAL_NAVMAN=3Dm
> CONFIG_USB_SERIAL_PL2303=3Dm
> CONFIG_USB_SERIAL_OTI6858=3Dm
> # CONFIG_USB_SERIAL_QCAUX is not set
> # CONFIG_USB_SERIAL_QUALCOMM is not set
> # CONFIG_USB_SERIAL_SPCP8X5 is not set
> # CONFIG_USB_SERIAL_SAFE is not set
> # CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
> # CONFIG_USB_SERIAL_SYMBOL is not set
> # CONFIG_USB_SERIAL_TI is not set
> # CONFIG_USB_SERIAL_CYBERJACK is not set
> # CONFIG_USB_SERIAL_XIRCOM is not set
> CONFIG_USB_SERIAL_WWAN=3Dm
> CONFIG_USB_SERIAL_OPTION=3Dm
> # CONFIG_USB_SERIAL_OMNINET is not set
> CONFIG_USB_SERIAL_OPTICON=3Dm
> CONFIG_USB_SERIAL_XSENS_MT=3Dm
> CONFIG_USB_SERIAL_WISHBONE=3Dm
> # CONFIG_USB_SERIAL_SSU100 is not set
> # CONFIG_USB_SERIAL_QT2 is not set
> CONFIG_USB_SERIAL_DEBUG=3Dm
>=20
> #
> # USB Miscellaneous drivers
> #
> CONFIG_USB_EMI62=3Dy
> CONFIG_USB_EMI26=3Dy
> CONFIG_USB_ADUTUX=3Dy
> # CONFIG_USB_SEVSEG is not set
> CONFIG_USB_RIO500=3Dy
> CONFIG_USB_LEGOTOWER=3Dy
> CONFIG_USB_LCD=3Dm
> CONFIG_USB_LED=3Dy
> # CONFIG_USB_CYPRESS_CY7C63 is not set
> # CONFIG_USB_CYTHERM is not set
> CONFIG_USB_IDMOUSE=3Dy
> CONFIG_USB_FTDI_ELAN=3Dy
> # CONFIG_USB_APPLEDISPLAY is not set
> CONFIG_USB_SISUSBVGA=3Dm
> CONFIG_USB_LD=3Dy
> # CONFIG_USB_TRANCEVIBRATOR is not set
> # CONFIG_USB_IOWARRIOR is not set
> CONFIG_USB_TEST=3Dm
> CONFIG_USB_EHSET_TEST_FIXTURE=3Dm
> CONFIG_USB_ISIGHTFW=3Dm
> CONFIG_USB_YUREX=3Dy
> CONFIG_USB_EZUSB_FX2=3Dy
> # CONFIG_USB_HSIC_USB3503 is not set
> CONFIG_USB_LINK_LAYER_TEST=3Dy
> CONFIG_USB_CHAOSKEY=3Dy
>=20
> #
> # USB Physical Layer drivers
> #
> CONFIG_USB_PHY=3Dy
> CONFIG_NOP_USB_XCEIV=3Dy
> CONFIG_USB_GPIO_VBUS=3Dm
> CONFIG_USB_ISP1301=3Dy
> # CONFIG_USB_GADGET is not set
> CONFIG_UWB=3Dy
> CONFIG_UWB_HWA=3Dm
> # CONFIG_UWB_WHCI is not set
> CONFIG_UWB_I1480U=3Dm
> CONFIG_MMC=3Dm
> # CONFIG_MMC_DEBUG is not set
> CONFIG_MMC_CLKGATE=3Dy
>=20
> #
> # MMC/SD/SDIO Card Drivers
> #
> CONFIG_SDIO_UART=3Dm
> CONFIG_MMC_TEST=3Dm
>=20
> #
> # MMC/SD/SDIO Host Controller Drivers
> #
> CONFIG_MMC_SDHCI=3Dm
> # CONFIG_MMC_SDHCI_PCI is not set
> # CONFIG_MMC_SDHCI_ACPI is not set
> CONFIG_MMC_SDHCI_PLTFM=3Dm
> CONFIG_MMC_WBSD=3Dm
> # CONFIG_MMC_TIFM_SD is not set
> # CONFIG_MMC_CB710 is not set
> # CONFIG_MMC_VIA_SDMMC is not set
> CONFIG_MMC_VUB300=3Dm
> # CONFIG_MMC_USHC is not set
> # CONFIG_MMC_USDHI6ROL0 is not set
> CONFIG_MMC_REALTEK_USB=3Dm
> # CONFIG_MMC_TOSHIBA_PCI is not set
> # CONFIG_MEMSTICK is not set
> CONFIG_NEW_LEDS=3Dy
> CONFIG_LEDS_CLASS=3Dy
> # CONFIG_LEDS_CLASS_FLASH is not set
>=20
> #
> # LED drivers
> #
> CONFIG_LEDS_LM3530=3Dy
> CONFIG_LEDS_LM3533=3Dm
> CONFIG_LEDS_LM3642=3Dy
> # CONFIG_LEDS_PCA9532 is not set
> # CONFIG_LEDS_GPIO is not set
> CONFIG_LEDS_LP3944=3Dy
> CONFIG_LEDS_LP55XX_COMMON=3Dy
> CONFIG_LEDS_LP5521=3Dy
> CONFIG_LEDS_LP5523=3Dm
> # CONFIG_LEDS_LP5562 is not set
> CONFIG_LEDS_LP8501=3Dy
> # CONFIG_LEDS_LP8860 is not set
> CONFIG_LEDS_CLEVO_MAIL=3Dy
> CONFIG_LEDS_PCA955X=3Dm
> CONFIG_LEDS_PCA963X=3Dm
> CONFIG_LEDS_WM8350=3Dy
> CONFIG_LEDS_DA903X=3Dm
> CONFIG_LEDS_DA9052=3Dy
> CONFIG_LEDS_DAC124S085=3Dy
> CONFIG_LEDS_PWM=3Dm
> CONFIG_LEDS_REGULATOR=3Dy
> # CONFIG_LEDS_BD2802 is not set
> # CONFIG_LEDS_INTEL_SS4200 is not set
> CONFIG_LEDS_LT3593=3Dm
> CONFIG_LEDS_MC13783=3Dm
> # CONFIG_LEDS_TCA6507 is not set
> # CONFIG_LEDS_MAX8997 is not set
> CONFIG_LEDS_LM355x=3Dm
> # CONFIG_LEDS_OT200 is not set
> CONFIG_LEDS_MENF21BMC=3Dy
>=20
> #
> # LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_T=
HINGM)
> #
> CONFIG_LEDS_BLINKM=3Dy
>=20
> #
> # LED Triggers
> #
> # CONFIG_LEDS_TRIGGERS is not set
> # CONFIG_ACCESSIBILITY is not set
> CONFIG_EDAC=3Dy
> CONFIG_EDAC_LEGACY_SYSFS=3Dy
> CONFIG_EDAC_DEBUG=3Dy
> # CONFIG_EDAC_MM_EDAC is not set
> CONFIG_RTC_LIB=3Dy
> CONFIG_RTC_CLASS=3Dy
> # CONFIG_RTC_HCTOSYS is not set
> # CONFIG_RTC_SYSTOHC is not set
> # CONFIG_RTC_DEBUG is not set
>=20
> #
> # RTC interfaces
> #
> CONFIG_RTC_INTF_SYSFS=3Dy
> CONFIG_RTC_INTF_PROC=3Dy
> # CONFIG_RTC_INTF_DEV is not set
> CONFIG_RTC_DRV_TEST=3Dm
>=20
> #
> # I2C RTC drivers
> #
> CONFIG_RTC_DRV_88PM80X=3Dm
> CONFIG_RTC_DRV_ABB5ZES3=3Dm
> # CONFIG_RTC_DRV_DS1307 is not set
> # CONFIG_RTC_DRV_DS1374 is not set
> CONFIG_RTC_DRV_DS1672=3Dm
> # CONFIG_RTC_DRV_DS3232 is not set
> # CONFIG_RTC_DRV_MAX6900 is not set
> CONFIG_RTC_DRV_MAX8925=3Dy
> # CONFIG_RTC_DRV_MAX8997 is not set
> CONFIG_RTC_DRV_RS5C372=3Dy
> # CONFIG_RTC_DRV_ISL1208 is not set
> CONFIG_RTC_DRV_ISL12022=3Dm
> CONFIG_RTC_DRV_ISL12057=3Dm
> # CONFIG_RTC_DRV_X1205 is not set
> CONFIG_RTC_DRV_PALMAS=3Dm
> CONFIG_RTC_DRV_PCF2127=3Dm
> # CONFIG_RTC_DRV_PCF8523 is not set
> CONFIG_RTC_DRV_PCF8563=3Dm
> CONFIG_RTC_DRV_PCF85063=3Dm
> CONFIG_RTC_DRV_PCF8583=3Dm
> # CONFIG_RTC_DRV_M41T80 is not set
> # CONFIG_RTC_DRV_BQ32K is not set
> # CONFIG_RTC_DRV_TWL4030 is not set
> CONFIG_RTC_DRV_TPS6586X=3Dm
> CONFIG_RTC_DRV_RC5T583=3Dm
> CONFIG_RTC_DRV_S35390A=3Dy
> CONFIG_RTC_DRV_FM3130=3Dm
> # CONFIG_RTC_DRV_RX8581 is not set
> CONFIG_RTC_DRV_RX8025=3Dy
> CONFIG_RTC_DRV_EM3027=3Dy
> CONFIG_RTC_DRV_RV3029C2=3Dm
> # CONFIG_RTC_DRV_S5M is not set
>=20
> #
> # SPI RTC drivers
> #
> CONFIG_RTC_DRV_M41T93=3Dy
> # CONFIG_RTC_DRV_M41T94 is not set
> CONFIG_RTC_DRV_DS1305=3Dm
> CONFIG_RTC_DRV_DS1343=3Dm
> CONFIG_RTC_DRV_DS1347=3Dm
> CONFIG_RTC_DRV_DS1390=3Dm
> CONFIG_RTC_DRV_MAX6902=3Dm
> # CONFIG_RTC_DRV_R9701 is not set
> CONFIG_RTC_DRV_RS5C348=3Dy
> CONFIG_RTC_DRV_DS3234=3Dm
> CONFIG_RTC_DRV_PCF2123=3Dy
> # CONFIG_RTC_DRV_RX4581 is not set
> # CONFIG_RTC_DRV_MCP795 is not set
>=20
> #
> # Platform RTC drivers
> #
> # CONFIG_RTC_DRV_CMOS is not set
> CONFIG_RTC_DRV_DS1286=3Dy
> CONFIG_RTC_DRV_DS1511=3Dm
> # CONFIG_RTC_DRV_DS1553 is not set
> CONFIG_RTC_DRV_DS1685_FAMILY=3Dy
> # CONFIG_RTC_DRV_DS1685 is not set
> CONFIG_RTC_DRV_DS1689=3Dy
> # CONFIG_RTC_DRV_DS17285 is not set
> # CONFIG_RTC_DRV_DS17485 is not set
> # CONFIG_RTC_DRV_DS17885 is not set
> CONFIG_RTC_DS1685_PROC_REGS=3Dy
> # CONFIG_RTC_DS1685_SYSFS_REGS is not set
> CONFIG_RTC_DRV_DS1742=3Dy
> CONFIG_RTC_DRV_DS2404=3Dm
> CONFIG_RTC_DRV_DA9052=3Dy
> CONFIG_RTC_DRV_DA9055=3Dy
> # CONFIG_RTC_DRV_STK17TA8 is not set
> CONFIG_RTC_DRV_M48T86=3Dy
> # CONFIG_RTC_DRV_M48T35 is not set
> CONFIG_RTC_DRV_M48T59=3Dy
> # CONFIG_RTC_DRV_MSM6242 is not set
> # CONFIG_RTC_DRV_BQ4802 is not set
> CONFIG_RTC_DRV_RP5C01=3Dy
> CONFIG_RTC_DRV_V3020=3Dy
> # CONFIG_RTC_DRV_WM8350 is not set
> CONFIG_RTC_DRV_PCF50633=3Dy
> # CONFIG_RTC_DRV_AB3100 is not set
>=20
> #
> # on-CPU RTC drivers
> #
> CONFIG_RTC_DRV_PCAP=3Dm
> # CONFIG_RTC_DRV_MC13XXX is not set
> CONFIG_RTC_DRV_XGENE=3Dm
>=20
> #
> # HID Sensor RTC drivers
> #
> CONFIG_RTC_DRV_HID_SENSOR_TIME=3Dm
> # CONFIG_DMADEVICES is not set
> # CONFIG_AUXDISPLAY is not set
> CONFIG_UIO=3Dm
> # CONFIG_UIO_CIF is not set
> # CONFIG_UIO_PDRV_GENIRQ is not set
> CONFIG_UIO_DMEM_GENIRQ=3Dm
> # CONFIG_UIO_AEC is not set
> # CONFIG_UIO_SERCOS3 is not set
> # CONFIG_UIO_PCI_GENERIC is not set
> # CONFIG_UIO_NETX is not set
> # CONFIG_UIO_MF624 is not set
> CONFIG_VIRT_DRIVERS=3Dy
> CONFIG_VIRTIO=3Dm
>=20
> #
> # Virtio drivers
> #
> # CONFIG_VIRTIO_PCI is not set
> # CONFIG_VIRTIO_BALLOON is not set
> CONFIG_VIRTIO_MMIO=3Dm
> CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=3Dy
>=20
> #
> # Microsoft Hyper-V guest support
> #
> CONFIG_STAGING=3Dy
> # CONFIG_SLICOSS is not set
> # CONFIG_COMEDI is not set
>=20
> #
> # IIO staging drivers
> #
>=20
> #
> # Accelerometers
> #
> # CONFIG_ADIS16201 is not set
> CONFIG_ADIS16203=3Dm
> CONFIG_ADIS16204=3Dm
> CONFIG_ADIS16209=3Dm
> CONFIG_ADIS16220=3Dm
> # CONFIG_ADIS16240 is not set
> CONFIG_LIS3L02DQ=3Dm
> CONFIG_SCA3000=3Dm
>=20
> #
> # Analog to digital converters
> #
> CONFIG_AD7606=3Dm
> # CONFIG_AD7606_IFACE_PARALLEL is not set
> # CONFIG_AD7606_IFACE_SPI is not set
> CONFIG_AD7780=3Dm
> # CONFIG_AD7816 is not set
> CONFIG_AD7192=3Dm
> CONFIG_AD7280=3Dm
>=20
> #
> # Analog digital bi-direction converters
> #
> # CONFIG_ADT7316 is not set
>=20
> #
> # Capacitance to digital converters
> #
> CONFIG_AD7150=3Dm
> CONFIG_AD7152=3Dm
> CONFIG_AD7746=3Dm
>=20
> #
> # Direct Digital Synthesis
> #
> CONFIG_AD9832=3Dm
> CONFIG_AD9834=3Dm
>=20
> #
> # Digital gyroscope sensors
> #
> CONFIG_ADIS16060=3Dm
>=20
> #
> # Network Analyzer, Impedance Converters
> #
> CONFIG_AD5933=3Dm
>=20
> #
> # Light sensors
> #
> CONFIG_SENSORS_ISL29018=3Dm
> # CONFIG_SENSORS_ISL29028 is not set
> CONFIG_TSL2583=3Dm
> CONFIG_TSL2x7x=3Dm
>=20
> #
> # Magnetometer sensors
> #
> CONFIG_SENSORS_HMC5843=3Dm
> CONFIG_SENSORS_HMC5843_I2C=3Dm
> # CONFIG_SENSORS_HMC5843_SPI is not set
>=20
> #
> # Active energy metering IC
> #
> CONFIG_ADE7753=3Dm
> CONFIG_ADE7754=3Dm
> CONFIG_ADE7758=3Dm
> CONFIG_ADE7759=3Dm
> CONFIG_ADE7854=3Dm
> CONFIG_ADE7854_I2C=3Dm
> CONFIG_ADE7854_SPI=3Dm
>=20
> #
> # Resolver to digital converters
> #
> # CONFIG_AD2S90 is not set
> CONFIG_AD2S1200=3Dm
> # CONFIG_AD2S1210 is not set
>=20
> #
> # Triggers - standalone
> #
> # CONFIG_IIO_PERIODIC_RTC_TRIGGER is not set
> CONFIG_IIO_SIMPLE_DUMMY=3Dm
> # CONFIG_IIO_SIMPLE_DUMMY_EVENTS is not set
> CONFIG_IIO_SIMPLE_DUMMY_BUFFER=3Dy
> # CONFIG_FB_SM7XX is not set
> # CONFIG_FB_SM750 is not set
> # CONFIG_FB_XGI is not set
> CONFIG_FT1000=3Dm
> # CONFIG_FT1000_USB is not set
>=20
> #
> # Speakup console speech
> #
> # CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
> # CONFIG_STAGING_MEDIA is not set
>=20
> #
> # Android
> #
> CONFIG_ANDROID_TIMED_OUTPUT=3Dy
> CONFIG_ANDROID_TIMED_GPIO=3Dm
> # CONFIG_ANDROID_LOW_MEMORY_KILLER is not set
> CONFIG_SYNC=3Dy
> CONFIG_SW_SYNC=3Dy
> # CONFIG_SW_SYNC_USER is not set
> CONFIG_ION=3Dy
> CONFIG_ION_TEST=3Dm
> # CONFIG_ION_DUMMY is not set
> # CONFIG_USB_WPAN_HCD is not set
> # CONFIG_WIMAX_GDM72XX is not set
> # CONFIG_LTE_GDM724X is not set
> CONFIG_FIREWIRE_SERIAL=3Dm
> CONFIG_FWTTY_MAX_TOTAL_PORTS=3D64
> CONFIG_FWTTY_MAX_CARD_PORTS=3D32
> # CONFIG_DGNC is not set
> # CONFIG_DGAP is not set
> CONFIG_GS_FPGABOOT=3Dy
> CONFIG_FB_TFT=3Dm
> CONFIG_FB_TFT_AGM1264K_FL=3Dm
> CONFIG_FB_TFT_BD663474=3Dm
> # CONFIG_FB_TFT_HX8340BN is not set
> # CONFIG_FB_TFT_HX8347D is not set
> CONFIG_FB_TFT_HX8353D=3Dm
> CONFIG_FB_TFT_ILI9163=3Dm
> CONFIG_FB_TFT_ILI9320=3Dm
> # CONFIG_FB_TFT_ILI9325 is not set
> CONFIG_FB_TFT_ILI9340=3Dm
> # CONFIG_FB_TFT_ILI9341 is not set
> CONFIG_FB_TFT_ILI9481=3Dm
> CONFIG_FB_TFT_ILI9486=3Dm
> CONFIG_FB_TFT_PCD8544=3Dm
> CONFIG_FB_TFT_RA8875=3Dm
> CONFIG_FB_TFT_S6D02A1=3Dm
> CONFIG_FB_TFT_S6D1121=3Dm
> # CONFIG_FB_TFT_SSD1289 is not set
> CONFIG_FB_TFT_SSD1306=3Dm
> CONFIG_FB_TFT_SSD1331=3Dm
> CONFIG_FB_TFT_SSD1351=3Dm
> CONFIG_FB_TFT_ST7735R=3Dm
> CONFIG_FB_TFT_TINYLCD=3Dm
> # CONFIG_FB_TFT_TLS8204 is not set
> # CONFIG_FB_TFT_UC1701 is not set
> # CONFIG_FB_TFT_UPD161704 is not set
> # CONFIG_FB_TFT_WATTEROTT is not set
> CONFIG_FB_FLEX=3Dm
> # CONFIG_FB_TFT_FBTFT_DEVICE is not set
> # CONFIG_I2O is not set
> # CONFIG_X86_PLATFORM_DEVICES is not set
> CONFIG_CHROME_PLATFORMS=3Dy
> # CONFIG_CHROMEOS_LAPTOP is not set
> CONFIG_CHROMEOS_PSTORE=3Dy
>=20
> #
> # Hardware Spinlock drivers
> #
>=20
> #
> # Clock Source drivers
> #
> CONFIG_CLKSRC_I8253=3Dy
> CONFIG_CLKEVT_I8253=3Dy
> CONFIG_I8253_LOCK=3Dy
> CONFIG_CLKBLD_I8253=3Dy
> # CONFIG_ATMEL_PIT is not set
> # CONFIG_SH_TIMER_CMT is not set
> # CONFIG_SH_TIMER_MTU2 is not set
> # CONFIG_SH_TIMER_TMU is not set
> # CONFIG_EM_TIMER_STI is not set
> # CONFIG_MAILBOX is not set
> # CONFIG_IOMMU_SUPPORT is not set
>=20
> #
> # Remoteproc drivers
> #
> CONFIG_REMOTEPROC=3Dm
> CONFIG_STE_MODEM_RPROC=3Dm
>=20
> #
> # Rpmsg drivers
> #
>=20
> #
> # SOC (System On Chip) specific Drivers
> #
> CONFIG_SOC_TI=3Dy
> # CONFIG_PM_DEVFREQ is not set
> CONFIG_EXTCON=3Dy
>=20
> #
> # Extcon Device Drivers
> #
> # CONFIG_EXTCON_ADC_JACK is not set
> # CONFIG_EXTCON_GPIO is not set
> CONFIG_EXTCON_MAX14577=3Dm
> CONFIG_EXTCON_MAX8997=3Dm
> # CONFIG_EXTCON_PALMAS is not set
> CONFIG_EXTCON_RT8973A=3Dy
> CONFIG_EXTCON_SM5502=3Dy
> CONFIG_MEMORY=3Dy
> CONFIG_IIO=3Dm
> CONFIG_IIO_BUFFER=3Dy
> # CONFIG_IIO_BUFFER_CB is not set
> CONFIG_IIO_KFIFO_BUF=3Dm
> CONFIG_IIO_TRIGGERED_BUFFER=3Dm
> CONFIG_IIO_TRIGGER=3Dy
> CONFIG_IIO_CONSUMERS_PER_TRIGGER=3D2
>=20
> #
> # Accelerometers
> #
> # CONFIG_BMA180 is not set
> CONFIG_BMC150_ACCEL=3Dm
> CONFIG_HID_SENSOR_ACCEL_3D=3Dm
> # CONFIG_IIO_ST_ACCEL_3AXIS is not set
> CONFIG_KXSD9=3Dm
> CONFIG_MMA8452=3Dm
> # CONFIG_KXCJK1013 is not set
> CONFIG_MMA9551_CORE=3Dm
> CONFIG_MMA9551=3Dm
> # CONFIG_MMA9553 is not set
>=20
> #
> # Analog to digital converters
> #
> CONFIG_AD_SIGMA_DELTA=3Dm
> # CONFIG_AD7266 is not set
> CONFIG_AD7291=3Dm
> # CONFIG_AD7298 is not set
> CONFIG_AD7476=3Dm
> CONFIG_AD7791=3Dm
> CONFIG_AD7793=3Dm
> CONFIG_AD7887=3Dm
> CONFIG_AD7923=3Dm
> # CONFIG_AD799X is not set
> CONFIG_AXP288_ADC=3Dm
> # CONFIG_DA9150_GPADC is not set
> CONFIG_CC10001_ADC=3Dm
> CONFIG_MAX1027=3Dm
> CONFIG_MAX1363=3Dm
> CONFIG_MCP320X=3Dm
> CONFIG_MCP3422=3Dm
> CONFIG_MEN_Z188_ADC=3Dm
> CONFIG_NAU7802=3Dm
> CONFIG_TI_ADC081C=3Dm
> # CONFIG_TI_ADC128S052 is not set
> # CONFIG_TWL4030_MADC is not set
> # CONFIG_TWL6030_GPADC is not set
>=20
> #
> # Amplifiers
> #
> CONFIG_AD8366=3Dm
>=20
> #
> # Hid Sensor IIO Common
> #
> CONFIG_HID_SENSOR_IIO_COMMON=3Dm
> CONFIG_HID_SENSOR_IIO_TRIGGER=3Dm
>=20
> #
> # SSP Sensor Common
> #
> CONFIG_IIO_SSP_SENSORS_COMMONS=3Dm
> CONFIG_IIO_SSP_SENSORHUB=3Dm
>=20
> #
> # Digital to analog converters
> #
> CONFIG_AD5064=3Dm
> CONFIG_AD5360=3Dm
> # CONFIG_AD5380 is not set
> CONFIG_AD5421=3Dm
> CONFIG_AD5446=3Dm
> # CONFIG_AD5449 is not set
> # CONFIG_AD5504 is not set
> CONFIG_AD5624R_SPI=3Dm
> # CONFIG_AD5686 is not set
> CONFIG_AD5755=3Dm
> CONFIG_AD5764=3Dm
> CONFIG_AD5791=3Dm
> CONFIG_AD7303=3Dm
> CONFIG_MAX517=3Dm
> CONFIG_MCP4725=3Dm
> CONFIG_MCP4922=3Dm
>=20
> #
> # Frequency Synthesizers DDS/PLL
> #
>=20
> #
> # Clock Generator/Distribution
> #
> # CONFIG_AD9523 is not set
>=20
> #
> # Phase-Locked Loop (PLL) frequency synthesizers
> #
> CONFIG_ADF4350=3Dm
>=20
> #
> # Digital gyroscope sensors
> #
> CONFIG_ADIS16080=3Dm
> # CONFIG_ADIS16130 is not set
> CONFIG_ADIS16136=3Dm
> CONFIG_ADIS16260=3Dm
> CONFIG_ADXRS450=3Dm
> # CONFIG_BMG160 is not set
> CONFIG_HID_SENSOR_GYRO_3D=3Dm
> # CONFIG_IIO_ST_GYRO_3AXIS is not set
> CONFIG_ITG3200=3Dm
>=20
> #
> # Humidity sensors
> #
> CONFIG_DHT11=3Dm
> # CONFIG_SI7005 is not set
> CONFIG_SI7020=3Dm
>=20
> #
> # Inertial measurement units
> #
> CONFIG_ADIS16400=3Dm
> CONFIG_ADIS16480=3Dm
> CONFIG_KMX61=3Dm
> # CONFIG_INV_MPU6050_IIO is not set
> CONFIG_IIO_ADIS_LIB=3Dm
> CONFIG_IIO_ADIS_LIB_BUFFER=3Dy
>=20
> #
> # Light sensors
> #
> # CONFIG_ADJD_S311 is not set
> # CONFIG_AL3320A is not set
> # CONFIG_APDS9300 is not set
> CONFIG_CM32181=3Dm
> # CONFIG_CM3232 is not set
> CONFIG_CM3323=3Dm
> CONFIG_CM36651=3Dm
> # CONFIG_GP2AP020A00F is not set
> # CONFIG_ISL29125 is not set
> CONFIG_HID_SENSOR_ALS=3Dm
> CONFIG_HID_SENSOR_PROX=3Dm
> CONFIG_JSA1212=3Dm
> CONFIG_SENSORS_LM3533=3Dm
> CONFIG_LTR501=3Dm
> CONFIG_TCS3414=3Dm
> CONFIG_TCS3472=3Dm
> CONFIG_SENSORS_TSL2563=3Dm
> CONFIG_TSL4531=3Dm
> # CONFIG_VCNL4000 is not set
>=20
> #
> # Magnetometer sensors
> #
> CONFIG_AK8975=3Dm
> CONFIG_AK09911=3Dm
> CONFIG_MAG3110=3Dm
> CONFIG_HID_SENSOR_MAGNETOMETER_3D=3Dm
> # CONFIG_IIO_ST_MAGN_3AXIS is not set
>=20
> #
> # Inclinometer sensors
> #
> # CONFIG_HID_SENSOR_INCLINOMETER_3D is not set
> # CONFIG_HID_SENSOR_DEVICE_ROTATION is not set
>=20
> #
> # Triggers - standalone
> #
> CONFIG_IIO_INTERRUPT_TRIGGER=3Dm
> # CONFIG_IIO_SYSFS_TRIGGER is not set
>=20
> #
> # Pressure sensors
> #
> CONFIG_BMP280=3Dm
> # CONFIG_HID_SENSOR_PRESS is not set
> # CONFIG_MPL115 is not set
> CONFIG_MPL3115=3Dm
> CONFIG_MS5611=3Dm
> CONFIG_MS5611_I2C=3Dm
> CONFIG_MS5611_SPI=3Dm
> # CONFIG_IIO_ST_PRESS is not set
> # CONFIG_T5403 is not set
>=20
> #
> # Lightning sensors
> #
> # CONFIG_AS3935 is not set
>=20
> #
> # Proximity sensors
> #
> # CONFIG_SX9500 is not set
>=20
> #
> # Temperature sensors
> #
> CONFIG_MLX90614=3Dm
> # CONFIG_TMP006 is not set
> # CONFIG_NTB is not set
> # CONFIG_VME_BUS is not set
> CONFIG_PWM=3Dy
> CONFIG_PWM_SYSFS=3Dy
> CONFIG_PWM_LPSS=3Dy
> # CONFIG_PWM_LPSS_PCI is not set
> # CONFIG_PWM_LPSS_PLATFORM is not set
> CONFIG_PWM_TWL=3Dy
> # CONFIG_PWM_TWL_LED is not set
> CONFIG_IPACK_BUS=3Dy
> # CONFIG_BOARD_TPCI200 is not set
> CONFIG_SERIAL_IPOCTAL=3Dm
> CONFIG_RESET_CONTROLLER=3Dy
> # CONFIG_FMC is not set
>=20
> #
> # PHY Subsystem
> #
> CONFIG_GENERIC_PHY=3Dy
> # CONFIG_BCM_KONA_USB2_PHY is not set
> # CONFIG_PHY_SAMSUNG_USB2 is not set
> CONFIG_POWERCAP=3Dy
> CONFIG_MCB=3Dm
> # CONFIG_MCB_PCI is not set
> # CONFIG_THUNDERBOLT is not set
>=20
> #
> # Android
> #
> CONFIG_ANDROID=3Dy
> CONFIG_ANDROID_BINDER_IPC=3Dy
> CONFIG_ANDROID_BINDER_IPC_32BIT=3Dy
>=20
> #
> # Firmware Drivers
> #
> CONFIG_EDD=3Dy
> CONFIG_EDD_OFF=3Dy
> # CONFIG_FIRMWARE_MEMMAP is not set
> CONFIG_DELL_RBU=3Dy
> CONFIG_DCDBAS=3Dy
> # CONFIG_DMIID is not set
> # CONFIG_DMI_SYSFS is not set
> CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=3Dy
> # CONFIG_ISCSI_IBFT_FIND is not set
> CONFIG_GOOGLE_FIRMWARE=3Dy
>=20
> #
> # Google Firmware Drivers
> #
> # CONFIG_GOOGLE_MEMCONSOLE is not set
>=20
> #
> # File systems
> #
> CONFIG_DCACHE_WORD_ACCESS=3Dy
> # CONFIG_FS_POSIX_ACL is not set
> CONFIG_EXPORTFS=3Dy
> CONFIG_FILE_LOCKING=3Dy
> CONFIG_FSNOTIFY=3Dy
> # CONFIG_DNOTIFY is not set
> CONFIG_INOTIFY_USER=3Dy
> # CONFIG_FANOTIFY is not set
> CONFIG_QUOTA=3Dy
> # CONFIG_QUOTA_NETLINK_INTERFACE is not set
> # CONFIG_PRINT_QUOTA_WARNING is not set
> # CONFIG_QUOTA_DEBUG is not set
> CONFIG_QUOTA_TREE=3Dm
> CONFIG_QFMT_V1=3Dm
> CONFIG_QFMT_V2=3Dm
> CONFIG_QUOTACTL=3Dy
> CONFIG_AUTOFS4_FS=3Dm
> CONFIG_FUSE_FS=3Dm
> CONFIG_CUSE=3Dm
> CONFIG_OVERLAY_FS=3Dy
>=20
> #
> # Caches
> #
> CONFIG_FSCACHE=3Dm
> CONFIG_FSCACHE_STATS=3Dy
> CONFIG_FSCACHE_HISTOGRAM=3Dy
> # CONFIG_FSCACHE_DEBUG is not set
> # CONFIG_FSCACHE_OBJECT_LIST is not set
>=20
> #
> # Pseudo filesystems
> #
> CONFIG_PROC_FS=3Dy
> # CONFIG_PROC_KCORE is not set
> CONFIG_PROC_SYSCTL=3Dy
> CONFIG_PROC_PAGE_MONITOR=3Dy
> CONFIG_KERNFS=3Dy
> CONFIG_SYSFS=3Dy
> CONFIG_HUGETLBFS=3Dy
> CONFIG_HUGETLB_PAGE=3Dy
> # CONFIG_CONFIGFS_FS is not set
> CONFIG_MISC_FILESYSTEMS=3Dy
> # CONFIG_ECRYPT_FS is not set
> # CONFIG_JFFS2_FS is not set
> # CONFIG_UBIFS_FS is not set
> # CONFIG_LOGFS is not set
> # CONFIG_ROMFS_FS is not set
> # CONFIG_PSTORE is not set
> CONFIG_NETWORK_FILESYSTEMS=3Dy
> CONFIG_NLS=3Dy
> CONFIG_NLS_DEFAULT=3D"iso8859-1"
> # CONFIG_NLS_CODEPAGE_437 is not set
> # CONFIG_NLS_CODEPAGE_737 is not set
> CONFIG_NLS_CODEPAGE_775=3Dy
> CONFIG_NLS_CODEPAGE_850=3Dm
> CONFIG_NLS_CODEPAGE_852=3Dm
> CONFIG_NLS_CODEPAGE_855=3Dy
> CONFIG_NLS_CODEPAGE_857=3Dm
> # CONFIG_NLS_CODEPAGE_860 is not set
> # CONFIG_NLS_CODEPAGE_861 is not set
> # CONFIG_NLS_CODEPAGE_862 is not set
> CONFIG_NLS_CODEPAGE_863=3Dy
> CONFIG_NLS_CODEPAGE_864=3Dy
> # CONFIG_NLS_CODEPAGE_865 is not set
> CONFIG_NLS_CODEPAGE_866=3Dy
> # CONFIG_NLS_CODEPAGE_869 is not set
> CONFIG_NLS_CODEPAGE_936=3Dy
> # CONFIG_NLS_CODEPAGE_950 is not set
> CONFIG_NLS_CODEPAGE_932=3Dm
> # CONFIG_NLS_CODEPAGE_949 is not set
> # CONFIG_NLS_CODEPAGE_874 is not set
> # CONFIG_NLS_ISO8859_8 is not set
> # CONFIG_NLS_CODEPAGE_1250 is not set
> CONFIG_NLS_CODEPAGE_1251=3Dm
> CONFIG_NLS_ASCII=3Dy
> # CONFIG_NLS_ISO8859_1 is not set
> CONFIG_NLS_ISO8859_2=3Dm
> CONFIG_NLS_ISO8859_3=3Dm
> # CONFIG_NLS_ISO8859_4 is not set
> CONFIG_NLS_ISO8859_5=3Dy
> CONFIG_NLS_ISO8859_6=3Dy
> CONFIG_NLS_ISO8859_7=3Dm
> # CONFIG_NLS_ISO8859_9 is not set
> # CONFIG_NLS_ISO8859_13 is not set
> CONFIG_NLS_ISO8859_14=3Dy
> # CONFIG_NLS_ISO8859_15 is not set
> CONFIG_NLS_KOI8_R=3Dy
> # CONFIG_NLS_KOI8_U is not set
> CONFIG_NLS_MAC_ROMAN=3Dm
> CONFIG_NLS_MAC_CELTIC=3Dm
> CONFIG_NLS_MAC_CENTEURO=3Dy
> # CONFIG_NLS_MAC_CROATIAN is not set
> CONFIG_NLS_MAC_CYRILLIC=3Dm
> CONFIG_NLS_MAC_GAELIC=3Dy
> CONFIG_NLS_MAC_GREEK=3Dy
> CONFIG_NLS_MAC_ICELAND=3Dy
> # CONFIG_NLS_MAC_INUIT is not set
> CONFIG_NLS_MAC_ROMANIAN=3Dy
> CONFIG_NLS_MAC_TURKISH=3Dm
> # CONFIG_NLS_UTF8 is not set
>=20
> #
> # Kernel hacking
> #
> CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
>=20
> #
> # printk and dmesg options
> #
> CONFIG_PRINTK_TIME=3Dy
> CONFIG_MESSAGE_LOGLEVEL_DEFAULT=3D4
> # CONFIG_BOOT_PRINTK_DELAY is not set
> # CONFIG_DYNAMIC_DEBUG is not set
>=20
> #
> # Compile-time checks and compiler options
> #
> # CONFIG_DEBUG_INFO is not set
> CONFIG_ENABLE_WARN_DEPRECATED=3Dy
> CONFIG_ENABLE_MUST_CHECK=3Dy
> CONFIG_FRAME_WARN=3D1024
> # CONFIG_STRIP_ASM_SYMS is not set
> # CONFIG_READABLE_ASM is not set
> CONFIG_UNUSED_SYMBOLS=3Dy
> # CONFIG_PAGE_OWNER is not set
> CONFIG_DEBUG_FS=3Dy
> CONFIG_HEADERS_CHECK=3Dy
> CONFIG_DEBUG_SECTION_MISMATCH=3Dy
> CONFIG_ARCH_WANT_FRAME_POINTERS=3Dy
> CONFIG_FRAME_POINTER=3Dy
> CONFIG_DEBUG_FORCE_WEAK_PER_CPU=3Dy
> # CONFIG_MAGIC_SYSRQ is not set
> CONFIG_DEBUG_KERNEL=3Dy
>=20
> #
> # Memory Debugging
> #
> # CONFIG_PAGE_EXTENSION is not set
> # CONFIG_DEBUG_PAGEALLOC is not set
> # CONFIG_DEBUG_OBJECTS is not set
> CONFIG_DEBUG_SLAB=3Dy
> CONFIG_DEBUG_SLAB_LEAK=3Dy
> CONFIG_HAVE_DEBUG_KMEMLEAK=3Dy
> # CONFIG_DEBUG_KMEMLEAK is not set
> # CONFIG_DEBUG_STACK_USAGE is not set
> # CONFIG_DEBUG_VM is not set
> # CONFIG_DEBUG_VIRTUAL is not set
> # CONFIG_DEBUG_MEMORY_INIT is not set
> CONFIG_DEBUG_HIGHMEM=3Dy
> CONFIG_HAVE_DEBUG_STACKOVERFLOW=3Dy
> # CONFIG_DEBUG_STACKOVERFLOW is not set
> CONFIG_HAVE_ARCH_KMEMCHECK=3Dy
> CONFIG_DEBUG_SHIRQ=3Dy
>=20
> #
> # Debug Lockups and Hangs
> #
> CONFIG_LOCKUP_DETECTOR=3Dy
> CONFIG_HARDLOCKUP_DETECTOR=3Dy
> # CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
> CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=3D0
> # CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
> CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=3D0
> CONFIG_DETECT_HUNG_TASK=3Dy
> CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=3D120
> # CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
> CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=3D0
> # CONFIG_PANIC_ON_OOPS is not set
> CONFIG_PANIC_ON_OOPS_VALUE=3D0
> CONFIG_PANIC_TIMEOUT=3D0
> CONFIG_SCHED_DEBUG=3Dy
> CONFIG_SCHEDSTATS=3Dy
> # CONFIG_SCHED_STACK_END_CHECK is not set
> # CONFIG_DEBUG_TIMEKEEPING is not set
> # CONFIG_TIMER_STATS is not set
>=20
> #
> # Lock Debugging (spinlocks, mutexes, etc...)
> #
> CONFIG_DEBUG_RT_MUTEXES=3Dy
> CONFIG_DEBUG_SPINLOCK=3Dy
> CONFIG_DEBUG_MUTEXES=3Dy
> CONFIG_DEBUG_WW_MUTEX_SLOWPATH=3Dy
> CONFIG_DEBUG_LOCK_ALLOC=3Dy
> # CONFIG_PROVE_LOCKING is not set
> CONFIG_LOCKDEP=3Dy
> CONFIG_LOCK_STAT=3Dy
> # CONFIG_DEBUG_LOCKDEP is not set
> CONFIG_DEBUG_ATOMIC_SLEEP=3Dy
> CONFIG_DEBUG_LOCKING_API_SELFTESTS=3Dy
> CONFIG_LOCK_TORTURE_TEST=3Dm
> CONFIG_STACKTRACE=3Dy
> # CONFIG_DEBUG_KOBJECT is not set
> CONFIG_DEBUG_BUGVERBOSE=3Dy
> CONFIG_DEBUG_LIST=3Dy
> CONFIG_DEBUG_PI_LIST=3Dy
> CONFIG_DEBUG_SG=3Dy
> CONFIG_DEBUG_NOTIFIERS=3Dy
> CONFIG_DEBUG_CREDENTIALS=3Dy
>=20
> #
> # RCU Debugging
> #
> # CONFIG_PROVE_RCU is not set
> # CONFIG_SPARSE_RCU_POINTER is not set
> CONFIG_TORTURE_TEST=3Dm
> # CONFIG_RCU_TORTURE_TEST is not set
> CONFIG_RCU_TORTURE_TEST_SLOW_INIT_DELAY=3D3
> CONFIG_RCU_CPU_STALL_TIMEOUT=3D21
> CONFIG_RCU_TRACE=3Dy
> CONFIG_NOTIFIER_ERROR_INJECTION=3Dy
> CONFIG_PM_NOTIFIER_ERROR_INJECT=3Dm
> CONFIG_FAULT_INJECTION=3Dy
> # CONFIG_FAILSLAB is not set
> # CONFIG_FAIL_PAGE_ALLOC is not set
> CONFIG_FAIL_MMC_REQUEST=3Dy
> # CONFIG_FAULT_INJECTION_DEBUG_FS is not set
> CONFIG_LATENCYTOP=3Dy
> CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=3Dy
> # CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
> CONFIG_USER_STACKTRACE_SUPPORT=3Dy
> CONFIG_HAVE_FUNCTION_TRACER=3Dy
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=3Dy
> CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=3Dy
> CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
> CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=3Dy
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=3Dy
> CONFIG_HAVE_SYSCALL_TRACEPOINTS=3Dy
> CONFIG_HAVE_C_RECORDMCOUNT=3Dy
> CONFIG_TRACE_CLOCK=3Dy
> CONFIG_TRACING_SUPPORT=3Dy
> # CONFIG_FTRACE is not set
>=20
> #
> # Runtime Testing
> #
> # CONFIG_TEST_LIST_SORT is not set
> # CONFIG_KPROBES_SANITY_TEST is not set
> # CONFIG_BACKTRACE_SELF_TEST is not set
> # CONFIG_RBTREE_TEST is not set
> CONFIG_INTERVAL_TREE_TEST=3Dm
> CONFIG_PERCPU_TEST=3Dm
> CONFIG_ATOMIC64_SELFTEST=3Dy
> # CONFIG_TEST_HEXDUMP is not set
> # CONFIG_TEST_STRING_HELPERS is not set
> # CONFIG_TEST_KSTRTOX is not set
> CONFIG_TEST_RHASHTABLE=3Dm
> # CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
> CONFIG_BUILD_DOCSRC=3Dy
> # CONFIG_DMA_API_DEBUG is not set
> CONFIG_TEST_LKM=3Dm
> CONFIG_TEST_USER_COPY=3Dm
> # CONFIG_TEST_BPF is not set
> CONFIG_TEST_FIRMWARE=3Dm
> # CONFIG_TEST_UDELAY is not set
> CONFIG_MEMTEST=3Dy
> # CONFIG_SAMPLES is not set
> CONFIG_HAVE_ARCH_KGDB=3Dy
> # CONFIG_KGDB is not set
> CONFIG_STRICT_DEVMEM=3Dy
> CONFIG_X86_VERBOSE_BOOTUP=3Dy
> CONFIG_EARLY_PRINTK=3Dy
> # CONFIG_EARLY_PRINTK_DBGP is not set
> # CONFIG_X86_PTDUMP is not set
> # CONFIG_DEBUG_RODATA is not set
> # CONFIG_DEBUG_SET_MODULE_RONX is not set
> CONFIG_DEBUG_NX_TEST=3Dm
> CONFIG_DOUBLEFAULT=3Dy
> CONFIG_DEBUG_TLBFLUSH=3Dy
> CONFIG_IOMMU_STRESS=3Dy
> CONFIG_HAVE_MMIOTRACE_SUPPORT=3Dy
> # CONFIG_X86_DECODER_SELFTEST is not set
> CONFIG_IO_DELAY_TYPE_0X80=3D0
> CONFIG_IO_DELAY_TYPE_0XED=3D1
> CONFIG_IO_DELAY_TYPE_UDELAY=3D2
> CONFIG_IO_DELAY_TYPE_NONE=3D3
> CONFIG_IO_DELAY_0X80=3Dy
> # CONFIG_IO_DELAY_0XED is not set
> # CONFIG_IO_DELAY_UDELAY is not set
> # CONFIG_IO_DELAY_NONE is not set
> CONFIG_DEFAULT_IO_DELAY_TYPE=3D0
> CONFIG_DEBUG_BOOT_PARAMS=3Dy
> # CONFIG_CPA_DEBUG is not set
> # CONFIG_OPTIMIZE_INLINING is not set
> # CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set
>=20
> #
> # Security options
> #
> CONFIG_KEYS=3Dy
> # CONFIG_PERSISTENT_KEYRINGS is not set
> CONFIG_ENCRYPTED_KEYS=3Dy
> CONFIG_SECURITY_DMESG_RESTRICT=3Dy
> # CONFIG_SECURITYFS is not set
> CONFIG_DEFAULT_SECURITY_DAC=3Dy
> CONFIG_DEFAULT_SECURITY=3D""
> CONFIG_CRYPTO=3Dy
>=20
> #
> # Crypto core or helper
> #
> CONFIG_CRYPTO_ALGAPI=3Dy
> CONFIG_CRYPTO_ALGAPI2=3Dy
> CONFIG_CRYPTO_AEAD=3Dy
> CONFIG_CRYPTO_AEAD2=3Dy
> CONFIG_CRYPTO_BLKCIPHER=3Dy
> CONFIG_CRYPTO_BLKCIPHER2=3Dy
> CONFIG_CRYPTO_HASH=3Dy
> CONFIG_CRYPTO_HASH2=3Dy
> CONFIG_CRYPTO_RNG=3Dy
> CONFIG_CRYPTO_RNG2=3Dy
> CONFIG_CRYPTO_PCOMP=3Dy
> CONFIG_CRYPTO_PCOMP2=3Dy
> CONFIG_CRYPTO_MANAGER=3Dy
> CONFIG_CRYPTO_MANAGER2=3Dy
> # CONFIG_CRYPTO_USER is not set
> CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=3Dy
> CONFIG_CRYPTO_GF128MUL=3Dy
> CONFIG_CRYPTO_NULL=3Dm
> CONFIG_CRYPTO_WORKQUEUE=3Dy
> # CONFIG_CRYPTO_CRYPTD is not set
> # CONFIG_CRYPTO_MCRYPTD is not set
> # CONFIG_CRYPTO_AUTHENC is not set
> CONFIG_CRYPTO_TEST=3Dm
>=20
> #
> # Authenticated Encryption with Associated Data
> #
> # CONFIG_CRYPTO_CCM is not set
> # CONFIG_CRYPTO_GCM is not set
> CONFIG_CRYPTO_SEQIV=3Dy
>=20
> #
> # Block modes
> #
> CONFIG_CRYPTO_CBC=3Dy
> CONFIG_CRYPTO_CTR=3Dy
> CONFIG_CRYPTO_CTS=3Dm
> CONFIG_CRYPTO_ECB=3Dm
> CONFIG_CRYPTO_LRW=3Dm
> CONFIG_CRYPTO_PCBC=3Dy
> CONFIG_CRYPTO_XTS=3Dy
>=20
> #
> # Hash modes
> #
> # CONFIG_CRYPTO_CMAC is not set
> CONFIG_CRYPTO_HMAC=3Dy
> CONFIG_CRYPTO_XCBC=3Dm
> CONFIG_CRYPTO_VMAC=3Dm
>=20
> #
> # Digest
> #
> CONFIG_CRYPTO_CRC32C=3Dy
> CONFIG_CRYPTO_CRC32C_INTEL=3Dm
> CONFIG_CRYPTO_CRC32=3Dy
> CONFIG_CRYPTO_CRC32_PCLMUL=3Dm
> CONFIG_CRYPTO_CRCT10DIF=3Dy
> CONFIG_CRYPTO_GHASH=3Dy
> CONFIG_CRYPTO_MD4=3Dy
> CONFIG_CRYPTO_MD5=3Dy
> CONFIG_CRYPTO_MICHAEL_MIC=3Dy
> CONFIG_CRYPTO_RMD128=3Dy
> CONFIG_CRYPTO_RMD160=3Dm
> # CONFIG_CRYPTO_RMD256 is not set
> CONFIG_CRYPTO_RMD320=3Dm
> CONFIG_CRYPTO_SHA1=3Dm
> CONFIG_CRYPTO_SHA256=3Dy
> CONFIG_CRYPTO_SHA512=3Dm
> # CONFIG_CRYPTO_TGR192 is not set
> CONFIG_CRYPTO_WP512=3Dm
>=20
> #
> # Ciphers
> #
> CONFIG_CRYPTO_AES=3Dy
> CONFIG_CRYPTO_AES_586=3Dy
> # CONFIG_CRYPTO_AES_NI_INTEL is not set
> CONFIG_CRYPTO_ANUBIS=3Dy
> CONFIG_CRYPTO_ARC4=3Dm
> CONFIG_CRYPTO_BLOWFISH=3Dm
> CONFIG_CRYPTO_BLOWFISH_COMMON=3Dm
> CONFIG_CRYPTO_CAMELLIA=3Dy
> CONFIG_CRYPTO_CAST_COMMON=3Dy
> CONFIG_CRYPTO_CAST5=3Dy
> CONFIG_CRYPTO_CAST6=3Dy
> CONFIG_CRYPTO_DES=3Dm
> # CONFIG_CRYPTO_FCRYPT is not set
> CONFIG_CRYPTO_KHAZAD=3Dm
> # CONFIG_CRYPTO_SALSA20 is not set
> CONFIG_CRYPTO_SALSA20_586=3Dy
> # CONFIG_CRYPTO_SEED is not set
> CONFIG_CRYPTO_SERPENT=3Dm
> # CONFIG_CRYPTO_SERPENT_SSE2_586 is not set
> CONFIG_CRYPTO_TEA=3Dm
> CONFIG_CRYPTO_TWOFISH=3Dy
> CONFIG_CRYPTO_TWOFISH_COMMON=3Dy
> CONFIG_CRYPTO_TWOFISH_586=3Dy
>=20
> #
> # Compression
> #
> # CONFIG_CRYPTO_DEFLATE is not set
> CONFIG_CRYPTO_ZLIB=3Dy
> CONFIG_CRYPTO_LZO=3Dy
> # CONFIG_CRYPTO_LZ4 is not set
> CONFIG_CRYPTO_LZ4HC=3Dm
>=20
> #
> # Random Number Generation
> #
> # CONFIG_CRYPTO_ANSI_CPRNG is not set
> CONFIG_CRYPTO_DRBG_MENU=3Dy
> CONFIG_CRYPTO_DRBG_HMAC=3Dy
> # CONFIG_CRYPTO_DRBG_HASH is not set
> # CONFIG_CRYPTO_DRBG_CTR is not set
> CONFIG_CRYPTO_DRBG=3Dy
> # CONFIG_CRYPTO_USER_API_HASH is not set
> # CONFIG_CRYPTO_USER_API_SKCIPHER is not set
> # CONFIG_CRYPTO_USER_API_RNG is not set
> CONFIG_CRYPTO_HASH_INFO=3Dy
> CONFIG_CRYPTO_HW=3Dy
> CONFIG_CRYPTO_DEV_PADLOCK=3Dm
> CONFIG_CRYPTO_DEV_PADLOCK_AES=3Dm
> CONFIG_CRYPTO_DEV_PADLOCK_SHA=3Dm
> # CONFIG_CRYPTO_DEV_GEODE is not set
> # CONFIG_CRYPTO_DEV_CCP is not set
> # CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
> CONFIG_ASYMMETRIC_KEY_TYPE=3Dy
> CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=3Dy
> CONFIG_PUBLIC_KEY_ALGO_RSA=3Dy
> CONFIG_X509_CERTIFICATE_PARSER=3Dy
> CONFIG_PKCS7_MESSAGE_PARSER=3Dy
> # CONFIG_PKCS7_TEST_KEY is not set
> CONFIG_SIGNED_PE_FILE_VERIFICATION=3Dy
> CONFIG_HAVE_KVM=3Dy
> CONFIG_VIRTUALIZATION=3Dy
> # CONFIG_KVM is not set
> # CONFIG_LGUEST is not set
> # CONFIG_BINARY_PRINTF is not set
>=20
> #
> # Library routines
> #
> CONFIG_BITREVERSE=3Dy
> # CONFIG_HAVE_ARCH_BITREVERSE is not set
> CONFIG_GENERIC_STRNCPY_FROM_USER=3Dy
> CONFIG_GENERIC_STRNLEN_USER=3Dy
> CONFIG_GENERIC_NET_UTILS=3Dy
> CONFIG_GENERIC_FIND_FIRST_BIT=3Dy
> CONFIG_GENERIC_PCI_IOMAP=3Dy
> CONFIG_GENERIC_IOMAP=3Dy
> CONFIG_GENERIC_IO=3Dy
> CONFIG_ARCH_HAS_FAST_MULTIPLIER=3Dy
> CONFIG_CRC_CCITT=3Dy
> CONFIG_CRC16=3Dy
> CONFIG_CRC_T10DIF=3Dy
> CONFIG_CRC_ITU_T=3Dy
> CONFIG_CRC32=3Dy
> CONFIG_CRC32_SELFTEST=3Dy
> # CONFIG_CRC32_SLICEBY8 is not set
> # CONFIG_CRC32_SLICEBY4 is not set
> # CONFIG_CRC32_SARWATE is not set
> CONFIG_CRC32_BIT=3Dy
> # CONFIG_CRC7 is not set
> # CONFIG_LIBCRC32C is not set
> CONFIG_CRC8=3Dm
> # CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
> # CONFIG_RANDOM32_SELFTEST is not set
> CONFIG_ZLIB_INFLATE=3Dy
> CONFIG_ZLIB_DEFLATE=3Dy
> CONFIG_LZO_COMPRESS=3Dy
> CONFIG_LZO_DECOMPRESS=3Dy
> CONFIG_LZ4HC_COMPRESS=3Dm
> CONFIG_LZ4_DECOMPRESS=3Dy
> CONFIG_XZ_DEC=3Dy
> # CONFIG_XZ_DEC_X86 is not set
> CONFIG_XZ_DEC_POWERPC=3Dy
> # CONFIG_XZ_DEC_IA64 is not set
> CONFIG_XZ_DEC_ARM=3Dy
> # CONFIG_XZ_DEC_ARMTHUMB is not set
> CONFIG_XZ_DEC_SPARC=3Dy
> CONFIG_XZ_DEC_BCJ=3Dy
> CONFIG_XZ_DEC_TEST=3Dm
> CONFIG_DECOMPRESS_GZIP=3Dy
> CONFIG_DECOMPRESS_BZIP2=3Dy
> CONFIG_DECOMPRESS_LZMA=3Dy
> CONFIG_DECOMPRESS_XZ=3Dy
> CONFIG_DECOMPRESS_LZO=3Dy
> CONFIG_DECOMPRESS_LZ4=3Dy
> CONFIG_GENERIC_ALLOCATOR=3Dy
> CONFIG_BCH=3Dm
> CONFIG_BCH_CONST_PARAMS=3Dy
> CONFIG_INTERVAL_TREE=3Dy
> CONFIG_ASSOCIATIVE_ARRAY=3Dy
> CONFIG_HAS_IOMEM=3Dy
> CONFIG_HAS_IOPORT_MAP=3Dy
> CONFIG_HAS_DMA=3Dy
> CONFIG_CHECK_SIGNATURE=3Dy
> CONFIG_DQL=3Dy
> CONFIG_NLATTR=3Dy
> CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=3Dy
> # CONFIG_AVERAGE is not set
> CONFIG_CLZ_TAB=3Dy
> CONFIG_CORDIC=3Dm
> # CONFIG_DDR is not set
> CONFIG_MPILIB=3Dy
> CONFIG_OID_REGISTRY=3Dy
> CONFIG_ARCH_HAS_SG_CHAIN=3Dy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
