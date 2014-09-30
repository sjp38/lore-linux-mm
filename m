Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 78E846B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 03:56:47 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so4777697pdb.11
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 00:56:46 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id v5si14659906pdo.24.2014.09.30.00.56.44
        for <linux-mm@kvack.org>;
        Tue, 30 Sep 2014 00:56:46 -0700 (PDT)
Date: Tue, 30 Sep 2014 15:56:24 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mm/slab] BUG: unable to handle kernel paging request at 00010023
Message-ID: <20140930075624.GA9561@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="cNdxnHkX5QqsyA0e"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jet Chen <jet.chen@intel.com>, Su Tao <tao.su@intel.com>, Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Joonsoo,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit 36fbfebe776eb5871d61e7a755c9feb1c96cc4aa
Author:     Joonsoo Kim <iamjoonsoo.kim@lge.com>
AuthorDate: Tue Sep 23 11:52:35 2014 +1000
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Tue Sep 23 11:52:35 2014 +1000

    mm/slab: support slab merge
    
    Slab merge is good feature to reduce fragmentation.  If new creating slab
    have similar size and property with exsitent slab, this feature reuse it
    rather than creating new one.  As a result, objects are packed into fewer
    slabs so that fragmentation is reduced.
    
    Below is result of my testing.
    
    * After boot, sleep 20; cat /proc/meminfo | grep Slab
    
    <Before>
    Slab: 25136 kB
    
    <After>
    Slab: 24364 kB
    
    We can save 3% memory used by slab.
    
    For supporting this feature in SLAB, we need to implement SLAB specific
    kmem_cache_flag() and __kmem_cache_alias(), because SLUB implements some
    SLUB specific processing related to debug flag and object size change on
    these functions.
    
    Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
    Cc: Christoph Lameter <cl@linux.com>
    Cc: Pekka Enberg <penberg@kernel.org>
    Cc: David Rientjes <rientjes@google.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

+----------------------------------------------+------------+------------+---------------+
|                                              | 8c087489b8 | 36fbfebe77 | next-20140923 |
+----------------------------------------------+------------+------------+---------------+
| boot_successes                               | 60         | 0          | 1             |
| boot_failures                                | 0          | 20         | 314           |
| BUG:unable_to_handle_kernel                  | 0          | 20         | 312           |
| Oops                                         | 0          | 20         | 312           |
| EIP_is_at_kernfs_link_sibling                | 0          | 4          | 14            |
| Kernel_panic-not_syncing:Fatal_exception     | 0          | 20         | 312           |
| backtrace:acpi_bus_scan                      | 0          | 4          | 14            |
| backtrace:acpi_scan_init                     | 0          | 20         | 45            |
| backtrace:acpi_init                          | 0          | 20         | 45            |
| backtrace:kernel_init_freeable               | 0          | 20         | 312           |
| EIP_is_at_kernfs_add_one                     | 0          | 16         | 298           |
| backtrace:kobject_add_internal               | 0          | 16         | 31            |
| backtrace:kobject_init_and_add               | 0          | 16         | 31            |
| backtrace:acpi_scan_add_handler_with_hotplug | 0          | 16         | 31            |
| backtrace:acpi_pci_root_init                 | 0          | 16         | 31            |
| backtrace:tty_register_driver                | 0          | 0          | 106           |
| backtrace:pty_init                           | 0          | 0          | 106           |
| backtrace:acpi_bus_register_driver           | 0          | 0          | 1             |
| backtrace:acpi_button_driver_init            | 0          | 0          | 1             |
| BUG:kernel_boot_crashed                      | 0          | 0          | 1             |
| BUG:kernel_test_crashed                      | 0          | 0          | 1             |
| backtrace:subsys_system_register             | 0          | 0          | 160           |
| backtrace:container_dev_init                 | 0          | 0          | 160           |
| backtrace:driver_init                        | 0          | 0          | 160           |
+----------------------------------------------+------------+------------+---------------+

[    0.463788] ACPI: (supports S0 S5)
[    0.464003] ACPI: Using IOAPIC for interrupt routing
[    0.464738] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.466034] BUG: unable to handle kernel paging request at 00010023
[    0.466989] IP: [<c117dcf9>] kernfs_add_one+0x89/0x130
[    0.467812] *pdpt = 0000000000000000 *pde = f000ff53f000ff53 
[    0.468000] Oops: 0002 [#1] SMP 
[    0.468000] Modules linked in:
[    0.468000] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.17.0-rc6-00089-g36fbfeb #1
[    0.468000] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.468000] task: d303ec90 ti: d3040000 task.ti: d3040000
[    0.468000] EIP: 0060:[<c117dcf9>] EFLAGS: 00010286 CPU: 0
[    0.468000] EIP is at kernfs_add_one+0x89/0x130
[    0.468000] EAX: 542572cb EBX: 00010003 ECX: 00000008 EDX: 2c8de598
[    0.468000] ESI: d311de10 EDI: d311de70 EBP: d3041dd8 ESP: d3041db4
[    0.468000]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[    0.468000] CR0: 8005003b CR2: 00010023 CR3: 01a8a000 CR4: 000006f0
[    0.468000] Stack:
[    0.468000]  d3006f00 00000202 d311de70 d311de10 d3041dd8 c117dba0 d311de10 c159a5c0
[    0.468000]  c1862a00 d3041df0 c117f0f2 00000000 c18629f4 d311de70 00000000 d3041e2c
[    0.468000]  c117f8b5 00001000 00000000 c159a5c0 c18629f4 00000000 00000001 c1862a00
[    0.468000] Call Trace:
[    0.468000]  [<c117dba0>] ? kernfs_new_node+0x30/0x40
[    0.468000]  [<c117f0f2>] __kernfs_create_file+0x92/0xc0
[    0.468000]  [<c117f8b5>] sysfs_add_file_mode_ns+0x95/0x190
[    0.468000]  [<c117f9d7>] sysfs_create_file_ns+0x27/0x40
[    0.468000]  [<c1252ef6>] kobject_add_internal+0x136/0x2c0
[    0.468000]  [<c125e360>] ? kvasprintf+0x40/0x50
[    0.468000]  [<c1252a92>] ? kobject_set_name_vargs+0x42/0x60
[    0.468000]  [<c12530b5>] kobject_init_and_add+0x35/0x50
[    0.468000]  [<c12ad04f>] acpi_sysfs_add_hotplug_profile+0x24/0x4a
[    0.468000]  [<c12a7280>] acpi_scan_add_handler_with_hotplug+0x21/0x28
[    0.468000]  [<c18df524>] acpi_pci_root_init+0x20/0x22
[    0.468000]  [<c18df0e1>] acpi_scan_init+0x24/0x16d
[    0.468000]  [<c18def73>] acpi_init+0x20c/0x224
[    0.468000]  [<c18ded67>] ? acpi_sleep_init+0xab/0xab
[    0.468000]  [<c100041e>] do_one_initcall+0x7e/0x1b0
[    0.468000]  [<c18ded67>] ? acpi_sleep_init+0xab/0xab
[    0.468000]  [<c18b24ba>] ? repair_env_string+0x12/0x54
[    0.468000]  [<c18b24a8>] ? initcall_blacklist+0x7c/0x7c
[    0.468000]  [<c105e100>] ? parse_args+0x160/0x3f0
[    0.468000]  [<c18b2bd1>] kernel_init_freeable+0xfc/0x179
[    0.468000]  [<c156782b>] kernel_init+0xb/0xd0
[    0.468000]  [<c1574601>] ret_from_kernel_thread+0x21/0x30
[    0.468000]  [<c1567820>] ? rest_init+0xb0/0xb0
[    0.468000] Code: 26 00 83 e1 10 75 5b 8b 46 24 e8 b3 ea ff ff 89 46 38 89 f0 e8 d9 f9 ff ff 85 c0 89 c3 75 ca 8b 5f 5c 85 db 74 11 e8 97 90 f1 ff <89> 43 20 89 53 24 89 43 28 89 53 2c b8 c0 2f 85 c1 e8 d1 36 3f
[    0.468000] EIP: [<c117dcf9>] kernfs_add_one+0x89/0x130 SS:ESP 0068:d3041db4
[    0.468000] CR2: 0000000000010023
[    0.468000] ---[ end trace 4fa173691404b63f ]---
[    0.468000] Kernel panic - not syncing: Fatal exception

git bisect start 55f21306900abf9f9d2a087a127ff49c6d388ad2 0f33be009b89d2268e94194dc4fd01a7851b6d51 --
git bisect good 18c13e2d9b75e2760e6520f2fde00401192956f3  # 17:56     20+      0  Merge remote-tracking branch 'bluetooth/master'
git bisect good abf79495f38ba66f750566b3f0a8da8dd94b4dc3  # 18:03     20+      0  Merge remote-tracking branch 'ftrace/for-next'
git bisect good 0bed22034e26a3c37ee4407fccffa8c095d5e144  # 18:09     20+      0  Merge remote-tracking branch 'pinctrl/for-next'
git bisect good 15c9281a15ed7718868d115d4d00619b0b7a2624  # 18:14     20+      0  Merge remote-tracking branch 'clk/clk-next'
git bisect good 50939531dea1b913b7fa29f9bbc69feafefd090c  # 18:23     20+      0  Merge branch 'rd-docs/master'
git bisect good aa881e3c5e87c8aa23519f40554897d56f32b935  # 18:49     20+      0  Merge remote-tracking branch 'powerpc-mpe/next'
git bisect  bad 81b63d14db32bd7706c955d1e04e65b152b2277a  # 18:57      0-      2  Merge branch 'akpm-current/current'
git bisect  bad f313ca82d72066a3c44fd6c66cee57b25de43aa9  # 19:31      0-      1  introduce-dump_vma-fix
git bisect good 2c5fe9213048c5640b8e46407f5614038c03ad93  # 20:16     20+      0  mm: fix kmemcheck.c build errors
git bisect  bad 69454f8be7f621ac8c3c6c9763bb70e116988942  # 20:35      0-     18  block_dev: implement readpages() to optimize sequential read
git bisect  bad 66a31d528a1e3d483be2b1c993ec1268412f0074  # 20:40      0-      1  memory-hotplug-add-sysfs-zones_online_to-attribute-fix-2
git bisect good 5e8acb68610c077b08cb3f16305aa3cc22e5d2a8  # 21:07     20+      0  kernel/kthread.c: partial revert of 81c98869faa5 ("kthread: ensure locality of task_struct allocations")
git bisect  bad 36fbfebe776eb5871d61e7a755c9feb1c96cc4aa  # 22:06      0-     10  mm/slab: support slab merge
git bisect good 11e57381eced875ef5a6fea4005fdf72b6f68eff  # 22:19     20+      0  mm/slab_common: commonize slab merge logic
git bisect good 8c087489b8a32b9235f7f9417390c62d93aba522  # 22:24     20+      0  mm/slab_common: fix build failure if CONFIG_SLUB
# first bad commit: [36fbfebe776eb5871d61e7a755c9feb1c96cc4aa] mm/slab: support slab merge
git bisect good 8c087489b8a32b9235f7f9417390c62d93aba522  # 22:26     60+      0  mm/slab_common: fix build failure if CONFIG_SLUB
git bisect  bad 55f21306900abf9f9d2a087a127ff49c6d388ad2  # 22:26      0-    314  Add linux-next specific files for 20140923
git bisect good f4cb707e7ad9727a046b463232f2de166e327d3e  # 22:32     60+      0  Merge tag 'pm+acpi-3.17-rc7' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm
git bisect  bad 4d8426f9ac601db2a64fa7be64051d02b9c9fe01  # 22:36      0-     60  Add linux-next specific files for 20140926


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1

kvm=(
	qemu-system-x86_64
	-cpu kvm64
	-enable-kvm
	-kernel $kernel
	-m 320
	-smp 1
	-net nic,vlan=1,model=e1000
	-net user,vlan=1
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

--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-yocto-vp-27:20140926220610:i386-randconfig-ib1-09232303:3.17.0-rc6-00089-g36fbfeb:1"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Linux version 3.17.0-rc6-00089-g36fbfeb (kbuild@lkp-ib03) (g=
cc version 4.9.1 (Debian 4.9.1-11) ) #1 SMP Fri Sep 26 22:04:56 CST 2014
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x1000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] initial memory mapped: [mem 0x00000000-0x025fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x13a00000-0x13bfffff]
[    0.000000]  [mem 0x13a00000-0x13bfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x10000000-0x139fffff]
[    0.000000]  [mem 0x10000000-0x139fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x13c00000-0x13ffdfff]
[    0.000000]  [mem 0x13c00000-0x13dfffff] page 2M
[    0.000000]  [mem 0x13e00000-0x13ffdfff] page 4k
[    0.000000] BRK [0x0219a000, 0x0219afff] PGTABLE
[    0.000000] RAMDISK: [mem 0x13cbd000-0x13feffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000FD970 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x13FFE4B0 000034 (v01 BOCHS  BXPCRSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACP 0x13FFFF80 000074 (v01 BOCHS  BXPCFACP 00000001 B=
XPC 00000001)
[    0.000000] ACPI: DSDT 0x13FFE4F0 0011A9 (v01 BXPC   BXDSDT   00000001 I=
NTL 20100528)
[    0.000000] ACPI: FACS 0x13FFFF40 000040
[    0.000000] ACPI: SSDT 0x13FFF800 000735 (v01 BOCHS  BXPCSSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: APIC 0x13FFF6E0 000078 (v01 BOCHS  BXPCAPIC 00000001 B=
XPC 00000001)
[    0.000000] ACPI: HPET 0x13FFF6A0 000038 (v01 BOCHS  BXPCHPET 00000001 B=
XPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 13ffe000
[    0.000000]   low ram: 0 - 13ffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffd001, primary cpu clock
[    0.000000] BRK [0x0219b000, 0x0219bfff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x13ffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 608 pages used for memmap
[    0.000000]   Normal zone: 77822 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
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
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffb000 (fec00000)
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:1 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 334 pages/cpu @d370f000 s1345088 r0 d22976 =
u1368064
[    0.000000] pcpu-alloc: s1345088 r0 d22976 u1368064 alloc=3D334*4096
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 13711a00
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 81180
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/i386-r=
andconfig-ib1-09232303/next:master:36fbfebe776eb5871d61e7a755c9feb1c96cc4aa=
:bisect-linux-1/.vmlinuz-36fbfebe776eb5871d61e7a755c9feb1c96cc4aa-201409262=
20514-13-vp branch=3Dnext/master BOOT_IMAGE=3D/kernel/i386-randconfig-ib1-0=
9232303/36fbfebe776eb5871d61e7a755c9feb1c96cc4aa/vmlinuz-3.17.0-rc6-00089-g=
36fbfeb drbd.minor_count=3D8
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 299664K/327280K available (5591K kernel code, 552K r=
wdata, 2744K rodata, 1852K init, 7164K bss, 27616K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffe6e000 - 0xfffff000   (1604 kB)
[    0.000000]     pkmap   : 0xffa00000 - 0xffc00000   (2048 kB)
[    0.000000]     vmalloc : 0xd47fe000 - 0xff9fe000   ( 690 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xd3ffe000   ( 319 MB)
[    0.000000]       .init : 0xc18b2000 - 0xc1a81000   (1852 kB)
[    0.000000]       .data : 0xc15760ec - 0xc18b0300   (3304 kB)
[    0.000000]       .text : 0xc1000000 - 0xc15760ec   (5592 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D1
[    0.000000] NR_IRQS:2304 nr_irqs:256 0
[    0.000000] CPU 0 irqstacks, hard=3Dd3008000 soft=3Dd300a000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] Linux version 3.17.0-rc6-00089-g36fbfeb (kbuild@lkp-ib03) (g=
cc version 4.9.1 (Debian 4.9.1-11) ) #1 SMP Fri Sep 26 22:04:56 CST 2014
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x1000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] initial memory mapped: [mem 0x00000000-0x025fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x13a00000-0x13bfffff]
[    0.000000]  [mem 0x13a00000-0x13bfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x10000000-0x139fffff]
[    0.000000]  [mem 0x10000000-0x139fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x13c00000-0x13ffdfff]
[    0.000000]  [mem 0x13c00000-0x13dfffff] page 2M
[    0.000000]  [mem 0x13e00000-0x13ffdfff] page 4k
[    0.000000] BRK [0x0219a000, 0x0219afff] PGTABLE
[    0.000000] RAMDISK: [mem 0x13cbd000-0x13feffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000FD970 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x13FFE4B0 000034 (v01 BOCHS  BXPCRSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACP 0x13FFFF80 000074 (v01 BOCHS  BXPCFACP 00000001 B=
XPC 00000001)
[    0.000000] ACPI: DSDT 0x13FFE4F0 0011A9 (v01 BXPC   BXDSDT   00000001 I=
NTL 20100528)
[    0.000000] ACPI: FACS 0x13FFFF40 000040
[    0.000000] ACPI: SSDT 0x13FFF800 000735 (v01 BOCHS  BXPCSSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: APIC 0x13FFF6E0 000078 (v01 BOCHS  BXPCAPIC 00000001 B=
XPC 00000001)
[    0.000000] ACPI: HPET 0x13FFF6A0 000038 (v01 BOCHS  BXPCHPET 00000001 B=
XPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 13ffe000
[    0.000000]   low ram: 0 - 13ffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffd001, primary cpu clock
[    0.000000] BRK [0x0219b000, 0x0219bfff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x13ffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 608 pages used for memmap
[    0.000000]   Normal zone: 77822 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
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
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffb000 (fec00000)
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:1 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 334 pages/cpu @d370f000 s1345088 r0 d22976 =
u1368064
[    0.000000] pcpu-alloc: s1345088 r0 d22976 u1368064 alloc=3D334*4096
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 13711a00
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 81180
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/i386-r=
andconfig-ib1-09232303/next:master:36fbfebe776eb5871d61e7a755c9feb1c96cc4aa=
:bisect-linux-1/.vmlinuz-36fbfebe776eb5871d61e7a755c9feb1c96cc4aa-201409262=
20514-13-vp branch=3Dnext/master BOOT_IMAGE=3D/kernel/i386-randconfig-ib1-0=
9232303/36fbfebe776eb5871d61e7a755c9feb1c96cc4aa/vmlinuz-3.17.0-rc6-00089-g=
36fbfeb drbd.minor_count=3D8
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 299664K/327280K available (5591K kernel code, 552K r=
wdata, 2744K rodata, 1852K init, 7164K bss, 27616K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffe6e000 - 0xfffff000   (1604 kB)
[    0.000000]     pkmap   : 0xffa00000 - 0xffc00000   (2048 kB)
[    0.000000]     vmalloc : 0xd47fe000 - 0xff9fe000   ( 690 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xd3ffe000   ( 319 MB)
[    0.000000]       .init : 0xc18b2000 - 0xc1a81000   (1852 kB)
[    0.000000]       .data : 0xc15760ec - 0xc18b0300   (3304 kB)
[    0.000000]       .text : 0xc1000000 - 0xc15760ec   (5592 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D1
[    0.000000] NR_IRQS:2304 nr_irqs:256 0
[    0.000000] CPU 0 irqstacks, hard=3Dd3008000 soft=3Dd300a000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 5151 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]                      A-A deadlock:failed|failed|  ok  |faile=
d|failed|failed|
[    0.000000]                  A-B-B-A deadlock:failed|failed|  ok  |faile=
d|failed|failed|
[    0.000000]              A-B-B-C-C-A deadlock:failed|failed|  ok  |faile=
d|failed|failed|
[    0.000000]              A-B-C-A-B-C deadlock:failed|failed|  ok  |faile=
d|failed|failed|
[    0.000000]          A-B-B-C-C-D-D-A deadlock:failed|failed|  ok  |faile=
d|failed|failed|
[    0.000000]          A-B-C-D-B-D-D-A deadlock:failed|failed|  ok  |faile=
d|failed|failed|
[    0.000000]          A-B-C-D-B-C-D-A deadlock:failed|failed|  ok  |faile=
d|failed|failed|
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]               recursive read-lock:             |  ok  |     =
        |failed|
[    0.000000]            recursive read-lock #2:             |  ok  |     =
        |failed|
[    0.000000]             mixed read-write-lock:             |failed|     =
        |failed|
[    0.000000]             mixed write-read-lock:             |failed|     =
        |failed|
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:failed|failed|  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:failed|failed|  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:failed|failed|  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:failed|failed|  ok  |
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:failed|failed|  ok  |
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:failed|failed|  ok  |
[    0.000000]          hard-safe-A + irqs-on/12:failed|failed|  ok  |
[    0.000000]          soft-safe-A + irqs-on/12:failed|failed|  ok  |
[    0.000000]          hard-safe-A + irqs-on/21:failed|failed|  ok  |
[    0.000000]          soft-safe-A + irqs-on/21:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/123:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/123:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/132:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/132:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/213:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/213:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/231:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/231:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/312:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/312:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/321:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/321:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/123:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/123:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/132:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/132:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/213:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/213:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/231:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/231:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/312:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/312:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/321:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/321:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/123:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/123:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/132:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/132:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/213:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/213:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/231:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/231:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/312:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/312:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/321:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/321:failed|failed|  ok  |
[    0.000000]       hard-irq read-recursion/123:  ok  |
[    0.000000]       soft-irq read-recursion/123:  ok  |
[    0.000000]       hard-irq read-recursion/132:  ok  |
[    0.000000]       soft-irq read-recursion/132:  ok  |
[    0.000000]       hard-irq read-recursion/213:  ok  |
[    0.000000]       soft-irq read-recursion/213:  ok  |
[    0.000000]       hard-irq read-recursion/231:  ok  |
[    0.000000]       soft-irq read-recursion/231:  ok  |
[    0.000000]       hard-irq read-recursion/312:  ok  |
[    0.000000]       soft-irq read-recursion/312:  ok  |
[    0.000000]       hard-irq read-recursion/321:  ok  |
[    0.000000]       soft-irq read-recursion/321:  ok  |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   | Wound/wait tests |
[    0.000000]   ---------------------
[    0.000000]                   ww api failures:  ok  |  ok  |  ok  |
[    0.000000]                ww contexts mixing:failed|  ok  |
[    0.000000]              finishing ww context:  ok  |  ok  |  ok  |  ok =
 |
[    0.000000]                locking mismatches:  ok  |  ok  |  ok  |
[    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]            spinlock nest unlocked:  ok  |
[    0.000000]   -----------------------------------------------------
[    0.000000]                                  |block | try  |context|
[    0.000000]   -----------------------------------------------------
[    0.000000]                           context:failed|  ok  |  ok  |
[    0.000000]                               try:failed|  ok  |failed|
[    0.000000]                             block:failed|  ok  |failed|
[    0.000000]                          spinlock:failed|  ok  |failed|
[    0.000000] --------------------------------------------------------
[    0.000000] 141 out of 253 testcases failed, as expected. |
[    0.000000] ----------------------------------------------------
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.530 MHz processor
[    0.008000] Calibrating delay loop (skipped) preset value.. 5387.06 Bogo=
MIPS (lpj=3D10774120)
[    0.008000] pid_max: default: 32768 minimum: 301
[    0.008000] ACPI: Core revision 20140724
[    0.009602] ACPI: All ACPI Tables successfully acquired
[    0.010574] Security Framework initialized
[    0.011226] Smack:  Initializing.
[    0.011812] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.012008] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 by=
tes)
[    0.014083] mce: CPU supports 10 MCE banks
[    0.016065] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.016065] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.034963] Freeing SMP alternatives memory: 24K (c1a81000 - c1a87000)
[    0.040683] Getting VERSION: 50014
[    0.041391] Getting VERSION: 50014
[    0.041963] Getting ID: 0
[    0.042488] Getting ID: f000000
[    0.043054] Getting LVT0: 8700
[    0.043590] Getting LVT1: 8400
[    0.044005] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.044851] enabled ExtINT on CPU#0
[    0.046567] ENABLING IO-APIC IRQs
[    0.047162] init IO_APIC IRQs
[    0.047688]  apic 0 pin 0 not connected
[    0.048017] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.049245] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.050493] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.052020] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.053217] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.054427] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.055628] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.056019] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.057242] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.058452] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.060019] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.061242] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.062474] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.064020] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.065240] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.066474] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.068019]  apic 0 pin 16 not connected
[    0.068644]  apic 0 pin 17 not connected
[    0.069258]  apic 0 pin 18 not connected
[    0.072003]  apic 0 pin 19 not connected
[    0.072621]  apic 0 pin 20 not connected
[    0.073241]  apic 0 pin 21 not connected
[    0.073877]  apic 0 pin 22 not connected
[    0.074492]  apic 0 pin 23 not connected
[    0.075255] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.076004] smpboot: CPU0: Intel Common KVM processor (fam: 0f, model: 0=
6, stepping: 01)
[    0.077425] Using local APIC timer interrupts.
[    0.077425] calibrating APIC timer ...
[    0.080000] ... lapic delta =3D 6249806
[    0.080000] ... PM-Timer delta =3D 357968
[    0.080000] ... PM-Timer result ok
[    0.080000] ..... delta 6249806
[    0.080000] ..... mult: 268427123
[    0.080000] ..... calibration result: 3999875
[    0.080000] ..... CPU clock speed is 2693.2356 MHz.
[    0.080000] ..... host bus clock speed is 999.3875 MHz.
[    0.080121] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.083613] Testing tracer nop: PASSED
[    0.084652] x86: Booted up 1 node, 1 CPUs
[    0.085740] ----------------
[    0.086619] | NMI testsuite:
[    0.087504] --------------------
[    0.088003]   remote IPI:  ok  |
[    0.089158]    local IPI:  ok  |
[    0.090324] --------------------
[    0.091261] Good, all   2 testcases passed! |
[    0.092004] ---------------------------------
[    0.093157] smpboot: Total of 1 processors activated (5387.06 BogoMIPS)
[    0.096719] devtmpfs: initialized
[    0.099257] Testing tracer wakeup: ret =3D 0
[    0.204079] ftrace-test (12) used greatest stack depth: 7160 bytes left
[    0.205111] PASSED
[    0.205734] Testing tracer wakeup_rt: ret =3D 0
[    0.308081] PASSED
[    0.308819] Testing tracer wakeup_dl: ret =3D 0
[    0.412065] PASSED
[    0.413017] prandom: seed boundary self test passed
[    0.414583] prandom: 100 self tests passed
[    0.416220] regulator-dummy: no parameters
[    0.417294] NET: Registered protocol family 16
[    0.418797] cpuidle: using governor menu
[    0.419859] ACPI: bus type PCI registered
[    0.420180] PCI : PCI BIOS area is rw and x. Use pci=3Dnobios if you wan=
t it NX.
[    0.421687] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.422752] PCI: Using configuration type 1 for base access
[    0.432987] Running resizable hashtable tests...
[    0.433884]   Adding 2048 keys
[    0.435463]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    0.436159]   Table expansion iteration 0...
[    0.437453]   Verifying lookups...
[    0.438453]   Table expansion iteration 1...
[    0.440379]   Verifying lookups...
[    0.441018]   Table expansion iteration 2...
[    0.442612]   Verifying lookups...
[    0.443554]   Table expansion iteration 3...
[    0.444785]   Verifying lookups...
[    0.445889]   Table shrinkage iteration 0...
[    0.446822]   Verifying lookups...
[    0.448162]   Table shrinkage iteration 1...
[    0.449278]   Verifying lookups...
[    0.449913]   Table shrinkage iteration 2...
[    0.450669]   Verifying lookups...
[    0.451379]   Table shrinkage iteration 3...
[    0.452026]   Verifying lookups...
[    0.452692]   Deleting 2048 keys
[    0.453679] ACPI: Added _OSI(Module Device)
[    0.454393] ACPI: Added _OSI(Processor Device)
[    0.455054] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.455772] ACPI: Added _OSI(Processor Aggregator Device)
[    0.457697] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.463169] ACPI: Interpreter enabled
[    0.463788] ACPI: (supports S0 S5)
[    0.464003] ACPI: Using IOAPIC for interrupt routing
[    0.464738] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.466034] BUG: unable to handle kernel paging request at 00010023
[    0.466989] IP: [<c117dcf9>] kernfs_add_one+0x89/0x130
[    0.467812] *pdpt =3D 0000000000000000 *pde =3D f000ff53f000ff53=20
[    0.468000] Oops: 0002 [#1] SMP=20
[    0.468000] Modules linked in:
[    0.468000] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.17.0-rc6-00089-g=
36fbfeb #1
[    0.468000] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.468000] task: d303ec90 ti: d3040000 task.ti: d3040000
[    0.468000] EIP: 0060:[<c117dcf9>] EFLAGS: 00010286 CPU: 0
[    0.468000] EIP is at kernfs_add_one+0x89/0x130
[    0.468000] EAX: 542572cb EBX: 00010003 ECX: 00000008 EDX: 2c8de598
[    0.468000] ESI: d311de10 EDI: d311de70 EBP: d3041dd8 ESP: d3041db4
[    0.468000]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[    0.468000] CR0: 8005003b CR2: 00010023 CR3: 01a8a000 CR4: 000006f0
[    0.468000] Stack:
[    0.468000]  d3006f00 00000202 d311de70 d311de10 d3041dd8 c117dba0 d311d=
e10 c159a5c0
[    0.468000]  c1862a00 d3041df0 c117f0f2 00000000 c18629f4 d311de70 00000=
000 d3041e2c
[    0.468000]  c117f8b5 00001000 00000000 c159a5c0 c18629f4 00000000 00000=
001 c1862a00
[    0.468000] Call Trace:
[    0.468000]  [<c117dba0>] ? kernfs_new_node+0x30/0x40
[    0.468000]  [<c117f0f2>] __kernfs_create_file+0x92/0xc0
[    0.468000]  [<c117f8b5>] sysfs_add_file_mode_ns+0x95/0x190
[    0.468000]  [<c117f9d7>] sysfs_create_file_ns+0x27/0x40
[    0.468000]  [<c1252ef6>] kobject_add_internal+0x136/0x2c0
[    0.468000]  [<c125e360>] ? kvasprintf+0x40/0x50
[    0.468000]  [<c1252a92>] ? kobject_set_name_vargs+0x42/0x60
[    0.468000]  [<c12530b5>] kobject_init_and_add+0x35/0x50
[    0.468000]  [<c12ad04f>] acpi_sysfs_add_hotplug_profile+0x24/0x4a
[    0.468000]  [<c12a7280>] acpi_scan_add_handler_with_hotplug+0x21/0x28
[    0.468000]  [<c18df524>] acpi_pci_root_init+0x20/0x22
[    0.468000]  [<c18df0e1>] acpi_scan_init+0x24/0x16d
[    0.468000]  [<c18def73>] acpi_init+0x20c/0x224
[    0.468000]  [<c18ded67>] ? acpi_sleep_init+0xab/0xab
[    0.468000]  [<c100041e>] do_one_initcall+0x7e/0x1b0
[    0.468000]  [<c18ded67>] ? acpi_sleep_init+0xab/0xab
[    0.468000]  [<c18b24ba>] ? repair_env_string+0x12/0x54
[    0.468000]  [<c18b24a8>] ? initcall_blacklist+0x7c/0x7c
[    0.468000]  [<c105e100>] ? parse_args+0x160/0x3f0
[    0.468000]  [<c18b2bd1>] kernel_init_freeable+0xfc/0x179
[    0.468000]  [<c156782b>] kernel_init+0xb/0xd0
[    0.468000]  [<c1574601>] ret_from_kernel_thread+0x21/0x30
[    0.468000]  [<c1567820>] ? rest_init+0xb0/0xb0
[    0.468000] Code: 26 00 83 e1 10 75 5b 8b 46 24 e8 b3 ea ff ff 89 46 38 =
89 f0 e8 d9 f9 ff ff 85 c0 89 c3 75 ca 8b 5f 5c 85 db 74 11 e8 97 90 f1 ff =
<89> 43 20 89 53 24 89 43 28 89 53 2c b8 c0 2f 85 c1 e8 d1 36 3f
[    0.468000] EIP: [<c117dcf9>] kernfs_add_one+0x89/0x130 SS:ESP 0068:d304=
1db4
[    0.468000] CR2: 0000000000010023
[    0.468000] ---[ end trace 4fa173691404b63f ]---
[    0.468000] Kernel panic - not syncing: Fatal exception

Elapsed time: 5
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-i=
b1-09232303/36fbfebe776eb5871d61e7a755c9feb1c96cc4aa/vmlinuz-3.17.0-rc6-000=
89-g36fbfeb -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug a=
pic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=
=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=
=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal =
 root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-ib1=
-09232303/next:master:36fbfebe776eb5871d61e7a755c9feb1c96cc4aa:bisect-linux=
-1/.vmlinuz-36fbfebe776eb5871d61e7a755c9feb1c96cc4aa-20140926220514-13-vp b=
ranch=3Dnext/master BOOT_IMAGE=3D/kernel/i386-randconfig-ib1-09232303/36fbf=
ebe776eb5871d61e7a755c9feb1c96cc4aa/vmlinuz-3.17.0-rc6-00089-g36fbfeb drbd.=
minor_count=3D8'  -initrd /kernel-tests/initrd/yocto-minimal-i386.cgz -m 32=
0 -smp 1 -net nic,vlan=3D1,model=3De1000 -net user,vlan=3D1 -boot order=3Dn=
c -no-reboot -watchdog i6300esb -rtc base=3Dlocaltime -drive file=3D/fs/LAB=
EL=3DKVM/disk0-yocto-vp-27,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=
=3DKVM/disk1-yocto-vp-27,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=
=3DKVM/disk2-yocto-vp-27,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=
=3DKVM/disk3-yocto-vp-27,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=
=3DKVM/disk4-yocto-vp-27,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=
=3DKVM/disk5-yocto-vp-27,media=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/p=
id-yocto-vp-27 -serial file:/dev/shm/kboot/serial-yocto-vp-27 -daemonize -d=
isplay none -monitor null=20

--cNdxnHkX5QqsyA0e
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="i386-randconfig-ib1-09232303-55f21306900abf9f9d2a087a127ff49c6d388ad2-BUG:-unable-to-handle-kernel-108269.log"
Content-Transfer-Encoding: base64

SEVBRCBpcyBub3cgYXQgNTVmMjEzMC4uLiBBZGQgbGludXgtbmV4dCBzcGVjaWZpYyBmaWxl
cyBmb3IgMjAxNDA5MjMKZ2l0IGNoZWNrb3V0IDBmMzNiZTAwOWI4OWQyMjY4ZTk0MTk0ZGM0
ZmQwMWE3ODUxYjZkNTEKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYt
cmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvbmV4dDptYXN0ZXI6MGYzM2JlMDA5Yjg5ZDIyNjhl
OTQxOTRkYzRmZDAxYTc4NTFiNmQ1MTpiaXNlY3QtbGludXgtMQoKMjAxNC0wOS0yNiAxNzo0
OTo1MyAwZjMzYmUwMDliODlkMjI2OGU5NDE5NGRjNGZkMDFhNzg1MWI2ZDUxIHJldXNlIC9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy8wZjMzYmUwMDliODlkMjI2OGU5
NDE5NGRjNGZkMDFhNzg1MWI2ZDUxL3ZtbGludXotMy4xNy4wLXJjNgoKMjAxNC0wOS0yNiAx
Nzo0OTo1MyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLgk3CTIwIFNVQ0NFU1MKCmJpc2VjdDog
Z29vZCBjb21taXQgMGYzM2JlMDA5Yjg5ZDIyNjhlOTQxOTRkYzRmZDAxYTc4NTFiNmQ1MQpn
aXQgYmlzZWN0IHN0YXJ0IDU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhh
ZDIgMGYzM2JlMDA5Yjg5ZDIyNjhlOTQxOTRkYzRmZDAxYTc4NTFiNmQ1MSAtLQovYy9rZXJu
ZWwtdGVzdHMvbGluZWFyLWJpc2VjdDogWyItYiIsICI1NWYyMTMwNjkwMGFiZjlmOWQyYTA4
N2ExMjdmZjQ5YzZkMzg4YWQyIiwgIi1nIiwgIjBmMzNiZTAwOWI4OWQyMjY4ZTk0MTk0ZGM0
ZmQwMWE3ODUxYjZkNTEiLCAiL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFp
bHVyZS5zaCIsICIvYy9ib290LWJpc2VjdC9saW51eC0xL29iai1iaXNlY3QiXQpCaXNlY3Rp
bmc6IDc0NDYgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEz
IHN0ZXBzKQpbMThjMTNlMmQ5Yjc1ZTI3NjBlNjUyMGYyZmRlMDA0MDExOTI5NTZmM10gTWVy
Z2UgcmVtb3RlLXRyYWNraW5nIGJyYW5jaCAnYmx1ZXRvb3RoL21hc3RlcicKcnVubmluZyAv
Yy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlz
ZWN0L2xpbnV4LTEvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9r
dm0vaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy9uZXh0Om1hc3RlcjoxOGMxM2UyZDli
NzVlMjc2MGU2NTIwZjJmZGUwMDQwMTE5Mjk1NmYzOmJpc2VjdC1saW51eC0xCgoyMDE0LTA5
LTI2IDE3OjUxOjU3IDE4YzEzZTJkOWI3NWUyNzYwZTY1MjBmMmZkZTAwNDAxMTkyOTU2ZjMg
Y29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUvbGtwLWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy0xOGMxM2UyZDliNzVl
Mjc2MGU2NTIwZjJmZGUwMDQwMTE5Mjk1NmYzCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzE4YzEzZTJkOWI3NWUyNzYwZTY1MjBm
MmZkZTAwNDAxMTkyOTU2ZjMKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRl
c3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzLXNtb2tlL2kzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDMtMThjMTNlMmQ5Yjc1ZTI3NjBlNjUyMGYyZmRlMDA0MDExOTI5NTZmMwprZXJuZWw6
IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy8xOGMxM2UyZDliNzVlMjc2
MGU2NTIwZjJmZGUwMDQwMTE5Mjk1NmYzL3ZtbGludXotMy4xNy4wLXJjNi0wMzE2Ny1nMThj
MTNlMgoKMjAxNC0wOS0yNiAxNzo1NDo1NyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4JMjAg
U1VDQ0VTUwoKQmlzZWN0aW5nOiA0Mjc5IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIg
dGhpcyAocm91Z2hseSAxMyBzdGVwcykKW2FiZjc5NDk1ZjM4YmE2NmY3NTA1NjZiM2YwYThk
YThkZDk0YjRkYzNdIE1lcmdlIHJlbW90ZS10cmFja2luZyBicmFuY2ggJ2Z0cmFjZS9mb3It
bmV4dCcKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJl
LnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4LTEvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRl
c3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy9uZXh0Om1h
c3RlcjphYmY3OTQ5NWYzOGJhNjZmNzUwNTY2YjNmMGE4ZGE4ZGQ5NGI0ZGMzOmJpc2VjdC1s
aW51eC0xCgoyMDE0LTA5LTI2IDE3OjU3OjAwIGFiZjc5NDk1ZjM4YmE2NmY3NTA1NjZiM2Yw
YThkYThkZDk0YjRkYzMgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQt
dGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
My1hYmY3OTQ5NWYzOGJhNjZmNzUwNTY2YjNmMGE4ZGE4ZGQ5NGI0ZGMzCkNoZWNrIGZvciBr
ZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzL2FiZjc5NDk1
ZjM4YmE2NmY3NTA1NjZiM2YwYThkYThkZDk0YjRkYzMKd2FpdGluZyBmb3IgY29tcGxldGlv
biBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDMtYWJmNzk0OTVmMzhiYTY2Zjc1MDU2NmIzZjBhOGRhOGRkOTRiNGRj
MwobWzE7MzVtMjAxNC0wOS0yNiAxNzo1OTowMCBObyBidWlsZCBzZXJ2ZWQgZmlsZSAva2J1
aWxkLXRlc3RzL2J1aWxkLXNlcnZlZC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLWFi
Zjc5NDk1ZjM4YmE2NmY3NTA1NjZiM2YwYThkYThkZDk0YjRkYzMbWzBtClJldHJ5IGJ1aWxk
IC4uCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1
ZS9sa3AtaWIwMy1zbW9rZS9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLWFiZjc5NDk1
ZjM4YmE2NmY3NTA1NjZiM2YwYThkYThkZDk0YjRkYzMKa2VybmVsOiAva2VybmVsL2kzODYt
cmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvYWJmNzk0OTVmMzhiYTY2Zjc1MDU2NmIzZjBhOGRh
OGRkOTRiNGRjMy92bWxpbnV6LTMuMTcuMC1yYzYtMDUwMjktZ2FiZjc5NDkKCjIwMTQtMDkt
MjYgMTg6MDI6MDEgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLgkyMCBTVUNDRVNTCgpCaXNlY3Rp
bmc6IDI0MTcgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEy
IHN0ZXBzKQpbMGJlZDIyMDM0ZTI2YTNjMzdlZTQ0MDdmY2NmZmE4YzA5NWQ1ZTE0NF0gTWVy
Z2UgcmVtb3RlLXRyYWNraW5nIGJyYW5jaCAncGluY3RybC9mb3ItbmV4dCcKcnVubmluZyAv
Yy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlz
ZWN0L2xpbnV4LTEvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9r
dm0vaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy9uZXh0Om1hc3RlcjowYmVkMjIwMzRl
MjZhM2MzN2VlNDQwN2ZjY2ZmYThjMDk1ZDVlMTQ0OmJpc2VjdC1saW51eC0xCgoyMDE0LTA5
LTI2IDE4OjAzOjAzIDBiZWQyMjAzNGUyNmEzYzM3ZWU0NDA3ZmNjZmZhOGMwOTVkNWUxNDQg
Y29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUvbGtwLWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy0wYmVkMjIwMzRlMjZh
M2MzN2VlNDQwN2ZjY2ZmYThjMDk1ZDVlMTQ0CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzBiZWQyMjAzNGUyNmEzYzM3ZWU0NDA3
ZmNjZmZhOGMwOTVkNWUxNDQKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRl
c3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMt
MGJlZDIyMDM0ZTI2YTNjMzdlZTQ0MDdmY2NmZmE4YzA5NWQ1ZTE0NAobWzE7MzVtMjAxNC0w
OS0yNiAxODowNjowMyBObyBidWlsZCBzZXJ2ZWQgZmlsZSAva2J1aWxkLXRlc3RzL2J1aWxk
LXNlcnZlZC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLTBiZWQyMjAzNGUyNmEzYzM3
ZWU0NDA3ZmNjZmZhOGMwOTVkNWUxNDQbWzBtClJldHJ5IGJ1aWxkIC4uCndhaXRpbmcgZm9y
IGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy1zbW9r
ZS9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLTBiZWQyMjAzNGUyNmEzYzM3ZWU0NDA3
ZmNjZmZhOGMwOTVkNWUxNDQKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyMzIzMDMvMGJlZDIyMDM0ZTI2YTNjMzdlZTQ0MDdmY2NmZmE4YzA5NWQ1ZTE0NC92bWxp
bnV6LTMuMTcuMC1yYzYtMDY4NzItZzBiZWQyMjAKCjIwMTQtMDktMjYgMTg6MDg6MDMgZGV0
ZWN0aW5nIGJvb3Qgc3RhdGUgCTEJMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiA1NzQgcmV2aXNp
b25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEwIHN0ZXBzKQpbMTVjOTI4
MWExNWVkNzcxODg2OGQxMTVkNGQwMDYxOWIwYjdhMjYyNF0gTWVyZ2UgcmVtb3RlLXRyYWNr
aW5nIGJyYW5jaCAnY2xrL2Nsay1uZXh0JwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNl
Y3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXgtMS9vYmotYmlz
ZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzL25leHQ6bWFzdGVyOjE1YzkyODFhMTVlZDc3MTg4NjhkMTE1ZDRkMDA2
MTliMGI3YTI2MjQ6YmlzZWN0LWxpbnV4LTEKCjIwMTQtMDktMjYgMTg6MDk6MjkgMTVjOTI4
MWExNWVkNzcxODg2OGQxMTVkNGQwMDYxOWIwYjdhMjYyNCBjb21waWxpbmcKUXVldWVkIGJ1
aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLTE1YzkyODFhMTVlZDc3MTg4NjhkMTE1ZDRkMDA2MTli
MGI3YTI2MjQKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDMvMTVjOTI4MWExNWVkNzcxODg2OGQxMTVkNGQwMDYxOWIwYjdhMjYyNAp3
YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtw
LWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy0xNWM5MjgxYTE1ZWQ3NzE4ODY4
ZDExNWQ0ZDAwNjE5YjBiN2EyNjI0ChtbMTszNW0yMDE0LTA5LTI2IDE4OjExOjI5IE5vIGJ1
aWxkIHNlcnZlZCBmaWxlIC9rYnVpbGQtdGVzdHMvYnVpbGQtc2VydmVkL2kzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDMtMTVjOTI4MWExNWVkNzcxODg2OGQxMTVkNGQwMDYxOWIwYjdh
MjYyNBtbMG0KUmV0cnkgYnVpbGQgLi4Kd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1
aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzLXNtb2tlL2kzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDMtMTVjOTI4MWExNWVkNzcxODg2OGQxMTVkNGQwMDYxOWIwYjdhMjYyNApr
ZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy8xNWM5MjgxYTE1
ZWQ3NzE4ODY4ZDExNWQ0ZDAwNjE5YjBiN2EyNjI0L3ZtbGludXotMy4xNy4wLXJjNi0wNjk2
My1nMTVjOTI4MQoKMjAxNC0wOS0yNiAxODoxMzoyOSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAu
LgkyMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDQ4MyByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFm
dGVyIHRoaXMgKHJvdWdobHkgOSBzdGVwcykKWzUwOTM5NTMxZGVhMWI5MTNiN2ZhMjlmOWJi
YzY5ZmVhZmVmZDA5MGNdIE1lcmdlIGJyYW5jaCAncmQtZG9jcy9tYXN0ZXInCnJ1bm5pbmcg
L2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJp
c2VjdC9saW51eC0xL29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUv
a3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvbmV4dDptYXN0ZXI6NTA5Mzk1MzFk
ZWExYjkxM2I3ZmEyOWY5YmJjNjlmZWFmZWZkMDkwYzpiaXNlY3QtbGludXgtMQoKMjAxNC0w
OS0yNiAxODoxNTowMSA1MDkzOTUzMWRlYTFiOTEzYjdmYTI5ZjliYmM2OWZlYWZlZmQwOTBj
IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1
ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMtNTA5Mzk1MzFkZWEx
YjkxM2I3ZmEyOWY5YmJjNjlmZWFmZWZkMDkwYwpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81MDkzOTUzMWRlYTFiOTEzYjdmYTI5
ZjliYmM2OWZlYWZlZmQwOTBjCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10
ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
LTUwOTM5NTMxZGVhMWI5MTNiN2ZhMjlmOWJiYzY5ZmVhZmVmZDA5MGMKG1sxOzM1bTIwMTQt
MDktMjYgMTg6MTg6MDEgTm8gYnVpbGQgc2VydmVkIGZpbGUgL2tidWlsZC10ZXN0cy9idWls
ZC1zZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy01MDkzOTUzMWRlYTFiOTEz
YjdmYTI5ZjliYmM2OWZlYWZlZmQwOTBjG1swbQpSZXRyeSBidWlsZCAuLgp3YWl0aW5nIGZv
ciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMtc21v
a2UvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy01MDkzOTUzMWRlYTFiOTEzYjdmYTI5
ZjliYmM2OWZlYWZlZmQwOTBjCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzLzUwOTM5NTMxZGVhMWI5MTNiN2ZhMjlmOWJiYzY5ZmVhZmVmZDA5MGMvdm1s
aW51ei0zLjE3LjAtcmM2LTA2OTk3LWc1MDkzOTUzCgoyMDE0LTA5LTI2IDE4OjIwOjAxIGRl
dGVjdGluZyBib290IHN0YXRlIC4JMgkzLgk3CTE1CTIwIFNVQ0NFU1MKCkJpc2VjdGluZzog
NDQ5IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA5IHN0ZXBz
KQpbYWE4ODFlM2M1ZTg3YzhhYTIzNTE5ZjQwNTU0ODk3ZDU2ZjMyYjkzNV0gTWVyZ2UgcmVt
b3RlLXRyYWNraW5nIGJyYW5jaCAncG93ZXJwYy1tcGUvbmV4dCcKcnVubmluZyAvYy9rZXJu
ZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xp
bnV4LTEvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4
Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy9uZXh0Om1hc3RlcjphYTg4MWUzYzVlODdjOGFh
MjM1MTlmNDA1NTQ4OTdkNTZmMzJiOTM1OmJpc2VjdC1saW51eC0xCgoyMDE0LTA5LTI2IDE4
OjIzOjMyIGFhODgxZTNjNWU4N2M4YWEyMzUxOWY0MDU1NDg5N2Q1NmYzMmI5MzUgY29tcGls
aW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtw
LWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy1hYTg4MWUzYzVlODdjOGFhMjM1
MTlmNDA1NTQ4OTdkNTZmMzJiOTM1CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzL2FhODgxZTNjNWU4N2M4YWEyMzUxOWY0MDU1NDg5
N2Q1NmYzMmI5MzUKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1
aWxkLXF1ZXVlL2xrcC1pYjAzLXNtb2tlL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMt
YWE4ODFlM2M1ZTg3YzhhYTIzNTE5ZjQwNTU0ODk3ZDU2ZjMyYjkzNQprZXJuZWw6IC9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy9hYTg4MWUzYzVlODdjOGFhMjM1MTlm
NDA1NTQ4OTdkNTZmMzJiOTM1L3ZtbGludXotMy4xNy4wLXJjNi0wNzA3OS1nYWE4ODFlMwoK
MjAxNC0wOS0yNiAxODoyOTozMiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4uCTEuCTMuLi4J
NC4uLi4JNS4uLi4uLi4uLgk4Li4JOS4uLgkxMAkxMgkxNC4JMTcuCTE5CTIwIFNVQ0NFU1MK
CkJpc2VjdGluZzogMzY3IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91
Z2hseSA5IHN0ZXBzKQpbODFiNjNkMTRkYjMyYmQ3NzA2Yzk1NWQxZTA0ZTY1YjE1MmIyMjc3
YV0gTWVyZ2UgYnJhbmNoICdha3BtLWN1cnJlbnQvY3VycmVudCcKcnVubmluZyAvYy9rZXJu
ZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xp
bnV4LTEvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4
Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy9uZXh0Om1hc3Rlcjo4MWI2M2QxNGRiMzJiZDc3
MDZjOTU1ZDFlMDRlNjViMTUyYjIyNzdhOmJpc2VjdC1saW51eC0xCgoyMDE0LTA5LTI2IDE4
OjUwOjIxIDgxYjYzZDE0ZGIzMmJkNzcwNmM5NTVkMWUwNGU2NWIxNTJiMjI3N2EgY29tcGls
aW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtw
LWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy04MWI2M2QxNGRiMzJiZDc3MDZj
OTU1ZDFlMDRlNjViMTUyYjIyNzdhCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzgxYjYzZDE0ZGIzMmJkNzcwNmM5NTVkMWUwNGU2
NWIxNTJiMjI3N2EKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1
aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMtODFiNjNk
MTRkYjMyYmQ3NzA2Yzk1NWQxZTA0ZTY1YjE1MmIyMjc3YQobWzE7MzVtMjAxNC0wOS0yNiAx
ODo1MjoyMiBObyBidWlsZCBzZXJ2ZWQgZmlsZSAva2J1aWxkLXRlc3RzL2J1aWxkLXNlcnZl
ZC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLTgxYjYzZDE0ZGIzMmJkNzcwNmM5NTVk
MWUwNGU2NWIxNTJiMjI3N2EbWzBtClJldHJ5IGJ1aWxkIC4uCndhaXRpbmcgZm9yIGNvbXBs
ZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy1zbW9rZS9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLTgxYjYzZDE0ZGIzMmJkNzcwNmM5NTVkMWUwNGU2
NWIxNTJiMjI3N2EKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvODFiNjNkMTRkYjMyYmQ3NzA2Yzk1NWQxZTA0ZTY1YjE1MmIyMjc3YS92bWxpbnV6LTMu
MTcuMC1yYzYtMDczNzItZzgxYjYzZDEKCjIwMTQtMDktMjYgMTg6NTQ6MjIgZGV0ZWN0aW5n
IGJvb3Qgc3RhdGUgLi4uLi4uIFRFU1QgRkFJTFVSRQpbICAgIDAuMzQ0MDA2XSAtLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KWyAgICAwLjM0ODAwNV0gc21wYm9vdDogVG90
YWwgb2YgMSBwcm9jZXNzb3JzIGFjdGl2YXRlZCAoNDUyMS45OSBCb2dvTUlQUykKWyAgICAw
LjM1NjY4MF0gZGV2dG1wZnM6IGluaXRpYWxpemVkClsgICAgMC4zNTgxNDhdIEJVRzogdW5h
YmxlIHRvIGhhbmRsZSBrZXJuZWwgcGFnaW5nIHJlcXVlc3QgYXQgMjRhMDAwMjAKWyAgICAw
LjM2MDAwMF0gSVA6IFs8YzExODBiYzk+XSBrZXJuZnNfYWRkX29uZSsweDg5LzB4MTMwClsg
ICAgMC4zNjAwMDBdICpwZHB0ID0gMDAwMDAwMDAwMDAwMDAwMCAqcGRlID0gMDAwMDAwMDAw
MDAwMDAwMCAKWyAgICAwLjM2MDAwMF0gT29wczogMDAwMiBbIzFdIFNNUCAKWyAgICAwLjM2
MDAwMF0gTW9kdWxlcyBsaW5rZWQgaW46ClsgICAgMC4zNjAwMDBdIENQVTogMCBQSUQ6IDEg
Q29tbTogc3dhcHBlci8wIE5vdCB0YWludGVkIDMuMTcuMC1yYzYtMDczNzItZzgxYjYzZDEg
IzEKWyAgICAwLjM2MDAwMF0gSGFyZHdhcmUgbmFtZTogUUVNVSBTdGFuZGFyZCBQQyAoaTQ0
MEZYICsgUElJWCwgMTk5NiksIEJJT1MgMS43LjUtMjAxNDA1MzFfMDgzMDMwLWdhbmRhbGYg
MDQvMDEvMjAxNApbICAgIDAuMzYwMDAwXSB0YXNrOiBkMzAzYWM5MCB0aTogZDMwM2MwMDAg
dGFzay50aTogZDMwM2MwMDAKWyAgICAwLjM2MDAwMF0gRUlQOiAwMDYwOls8YzExODBiYzk+
XSBFRkxBR1M6IDAwMDEwMjgyIENQVTogMApbICAgIDAuMzYwMDAwXSBFSVAgaXMgYXQga2Vy
bmZzX2FkZF9vbmUrMHg4OS8weDEzMApbICAgIDAuMzYwMDAwXSBFQVg6IDU0MjU0NjY0IEVC
WDogMjRhMDAwMDAgRUNYOiAwMDAwMDAwOCBFRFg6IDFkNDQ2MDRmClsgICAgMC4zNjAwMDBd
IEVTSTogZDMwNjkwMzAgRURJOiBkMzA2OTA5MCBFQlA6IGQzMDNkZTU0IEVTUDogZDMwM2Rl
MzAKWyAgICAwLjM2MDAwMF0gIERTOiAwMDdiIEVTOiAwMDdiIEZTOiAwMGQ4IEdTOiAwMDAw
IFNTOiAwMDY4ClsgICAgMC4zNjAwMDBdIENSMDogODAwNTAwM2IgQ1IyOiAyNGEwMDAyMCBD
UjM6IDAxYTkyMDAwIENSNDogMDAwMDA2ZjAKWyAgICAwLjM2MDAwMF0gU3RhY2s6ClsgICAg
MC4zNjAwMDBdICBkMzAwNmYwMCAwMDAwMDIwMiBkMzA2OTA5MCBkMzA2OTAzMCBkMzAzZGU1
NCBjMTE4MGE3MCBkMzA2OTAzMCBjMTVhMDY4MApbICAgIDAuMzYwMDAwXSAgYzE4N2RhMmMg
ZDMwM2RlNmMgYzExODFmYzIgMDAwMDAwMDAgYzE4N2RhMjAgZDMwNjkwOTAgMDAwMDAwMDAg
ZDMwM2RlYTgKWyAgICAwLjM2MDAwMF0gIGMxMTgyNzg1IDAwMDAxMDAwIDAwMDAwMDAwIGMx
NWEwNjgwIGMxODdkYTIwIDAwMDAwMDAwIDAwMDAwMDAxIGMxODdkYTJjClsgICAgMC4zNjAw
MDBdIENhbGwgVHJhY2U6ClsgICAgMC4zNjAwMDBdICBbPGMxMTgwYTcwPl0gPyBrZXJuZnNf
bmV3X25vZGUrMHgzMC8weDQwClsgICAgMC4zNjAwMDBdICBbPGMxMTgxZmMyPl0gX19rZXJu
ZnNfY3JlYXRlX2ZpbGUrMHg5Mi8weGMwClsgICAgMC4zNjAwMDBdICBbPGMxMTgyNzg1Pl0g
c3lzZnNfYWRkX2ZpbGVfbW9kZV9ucysweDk1LzB4MTkwClsgICAgMC4zNjAwMDBdICBbPGMx
MTgyYTFlPl0gc3lzZnNfYWRkX2ZpbGUrMHgxZS8weDMwClsgICAgMC4zNjAwMDBdICBbPGMx
MTgzMDlhPl0gc3lzZnNfbWVyZ2VfZ3JvdXArMHg0YS8weGMwClsgICAgMC4zNjAwMDBdICBb
PGMxMzI5YTljPl0gZHBtX3N5c2ZzX2FkZCsweDVjLzB4YjAKWyAgICAwLjM2MDAwMF0gIFs8
YzEzMjJjZjY+XSBkZXZpY2VfYWRkKzB4NDQ2LzB4NTgwClsgICAgMC4zNjAwMDBdICBbPGMx
MzJjZTBhPl0gPyBwbV9ydW50aW1lX2luaXQrMHhlYS8weGYwClsgICAgMC4zNjAwMDBdICBb
PGMxMzIyZTQyPl0gZGV2aWNlX3JlZ2lzdGVyKzB4MTIvMHgyMApbICAgIDAuMzYwMDAwXSAg
WzxjMTMyNDVhNz5dIHN1YnN5c19yZWdpc3Rlci5wYXJ0LjYrMHg2Ny8weGIwClsgICAgMC4z
NjAwMDBdICBbPGMxMzI0NjE1Pl0gc3Vic3lzX3N5c3RlbV9yZWdpc3RlcisweDI1LzB4MzAK
WyAgICAwLjM2MDAwMF0gIFs8YzE4ZWUzMzI+XSBjb250YWluZXJfZGV2X2luaXQrMHhmLzB4
MjgKWyAgICAwLjM2MDAwMF0gIFs8YzE4ZWUzMjE+XSBkcml2ZXJfaW5pdCsweDMwLzB4MzIK
WyAgICAwLjM2MDAwMF0gIFs8YzE4YmFiNjE+XSBrZXJuZWxfaW5pdF9mcmVlYWJsZSsweDdk
LzB4MTc5ClsgICAgMC4zNjAwMDBdICBbPGMxNTZlMTRiPl0ga2VybmVsX2luaXQrMHhiLzB4
ZDAKWyAgICAwLjM2MDAwMF0gIFs8YzE1N2FmMDE+XSByZXRfZnJvbV9rZXJuZWxfdGhyZWFk
KzB4MjEvMHgzMApbICAgIDAuMzYwMDAwXSAgWzxjMTU2ZTE0MD5dID8gcmVzdF9pbml0KzB4
YjAvMHhiMApbICAgIDAuMzYwMDAwXSBDb2RlOiAyNiAwMCA4MyBlMSAxMCA3NSA1YiA4YiA0
NiAyNCBlOCBjMyBlYSBmZiBmZiA4OSA0NiAzOCA4OSBmMCBlOCBkOSBmOSBmZiBmZiA4NSBj
MCA4OSBjMyA3NSBjYSA4YiA1ZiA1YyA4NSBkYiA3NCAxMSBlOCA1NyA3NiBmMSBmZiA8ODk+
IDQzIDIwIDg5IDUzIDI0IDg5IDQzIDI4IDg5IDUzIDJjIGI4IGMwIGFlIDg1IGMxIGU4IDAx
IDcxIDNmClsgICAgMC4zNjAwMDBdIEVJUDogWzxjMTE4MGJjOT5dIGtlcm5mc19hZGRfb25l
KzB4ODkvMHgxMzAgU1M6RVNQIDAwNjg6ZDMwM2RlMzAKWyAgICAwLjM2MDAwMF0gQ1IyOiAw
MDAwMDAwMDI0YTAwMDIwClsgICAgMC4zNjAwMDBdIC0tLVsgZW5kIHRyYWNlIGRkMTFhOTU1
OWI1ZTg3ZmYgXS0tLQpbICAgIDAuMzYwMDAwXSBLZXJuZWwgcGFuaWMgLSBub3Qgc3luY2lu
ZzogRmF0YWwgZXhjZXB0aW9uCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
My84MWI2M2QxNGRiMzJiZDc3MDZjOTU1ZDFlMDRlNjViMTUyYjIyNzdhL2RtZXNnLXlvY3Rv
LWxrcC1uZXgwNC02OToyMDE0MDkyNjE4NTY0MzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzgxYjYzZDE0ZGIz
MmJkNzcwNmM5NTVkMWUwNGU2NWIxNTJiMjI3N2EvZG1lc2cteW9jdG8tbGtwLW5leDA0LTcz
OjIwMTQwOTI2MTg1NjUwOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6OgowOjI6MiBh
bGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwobWzE7MzVtMjAxNC0wOS0yNiAxODo1NzoyMiBS
RVBFQVQgQ09VTlQ6IDIwICAjIC9jL2Jvb3QtYmlzZWN0L2xpbnV4LTEvb2JqLWJpc2VjdC8u
cmVwZWF0G1swbQoKbGluZWFyLWJpc2VjdDogYmFkIGJyYW5jaCBtYXkgYmUgYnJhbmNoICdh
a3BtLWN1cnJlbnQvY3VycmVudCcKbGluZWFyLWJpc2VjdDogaGFuZGxlIG92ZXIgdG8gZ2l0
IGJpc2VjdApsaW5lYXItYmlzZWN0OiBnaXQgYmlzZWN0IHN0YXJ0IDgxYjYzZDE0ZGIzMmJk
NzcwNmM5NTVkMWUwNGU2NWIxNTJiMjI3N2EgYWE4ODFlM2M1ZTg3YzhhYTIzNTE5ZjQwNTU0
ODk3ZDU2ZjMyYjkzNSAtLQpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdhcyA4MWI2M2QxLi4u
IE1lcmdlIGJyYW5jaCAnYWtwbS1jdXJyZW50L2N1cnJlbnQnCkhFQUQgaXMgbm93IGF0IGI0
ZDMzMTguLi4gTWVyZ2UgcmVtb3RlLXRyYWNraW5nIGJyYW5jaCAnY3J5cHRvL21hc3RlcicK
QmlzZWN0aW5nOiAxNDYgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3Vn
aGx5IDcgc3RlcHMpCltmMzEzY2E4MmQ3MjA2NmEzYzQ0ZmQ2YzY2Y2VlNTdiMjVkZTQzYWE5
XSBpbnRyb2R1Y2UtZHVtcF92bWEtZml4CmxpbmVhci1iaXNlY3Q6IGdpdCBiaXNlY3QgcnVu
IC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1i
aXNlY3QvbGludXgtMS9vYmotYmlzZWN0CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2Vj
dC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eC0xL29iai1iaXNl
Y3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDMvbmV4dDptYXN0ZXI6ZjMxM2NhODJkNzIwNjZhM2M0NGZkNmM2NmNlZTU3
YjI1ZGU0M2FhOTpiaXNlY3QtbGludXgtMQoKMjAxNC0wOS0yNiAxOTowMToyMiBmMzEzY2E4
MmQ3MjA2NmEzYzQ0ZmQ2YzY2Y2VlNTdiMjVkZTQzYWE5IGNvbXBpbGluZwpRdWV1ZWQgYnVp
bGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMtZjMxM2NhODJkNzIwNjZhM2M0NGZkNmM2NmNlZTU3YjI1
ZGU0M2FhOQpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMy9mMzEzY2E4MmQ3MjA2NmEzYzQ0ZmQ2YzY2Y2VlNTdiMjVkZTQzYWE5Cndh
aXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3At
aWIwMy9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLWYzMTNjYTgyZDcyMDY2YTNjNDRm
ZDZjNjZjZWU1N2IyNWRlNDNhYTkKG1sxOzM1bTIwMTQtMDktMjYgMTk6Mjg6MjIgTm8gYnVp
bGQgc2VydmVkIGZpbGUgL2tidWlsZC10ZXN0cy9idWlsZC1zZXJ2ZWQvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy1mMzEzY2E4MmQ3MjA2NmEzYzQ0ZmQ2YzY2Y2VlNTdiMjVkZTQz
YWE5G1swbQpSZXRyeSBidWlsZCAuLgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVp
bGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMtc21va2UvaTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMy1mMzEzY2E4MmQ3MjA2NmEzYzQ0ZmQ2YzY2Y2VlNTdiMjVkZTQzYWE5Cmtl
cm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzL2YzMTNjYTgyZDcy
MDY2YTNjNDRmZDZjNjZjZWU1N2IyNWRlNDNhYTkvdm1saW51ei0zLjE3LjAtcmM2LTAwMTQ5
LWdmMzEzY2E4CgoyMDE0LTA5LTI2IDE5OjMxOjIyIGRldGVjdGluZyBib290IHN0YXRlIC4g
VEVTVCBGQUlMVVJFClsgICAgMC4xMTIwMDRdIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLQpbICAgIDAuMTEzMDU3XSBzbXBib290OiBUb3RhbCBvZiAxIHByb2Nlc3NvcnMg
YWN0aXZhdGVkICg1Mzg3LjA2IEJvZ29NSVBTKQpbICAgIDAuMTE1NDYzXSBkZXZ0bXBmczog
aW5pdGlhbGl6ZWQKWyAgICAwLjExNjQwOF0gQlVHOiB1bmFibGUgdG8gaGFuZGxlIGtlcm5l
bCBwYWdpbmcgcmVxdWVzdCBhdCAyNGUwMDAyMApbICAgIDAuMTE4MDA1XSBJUDogWzxjMTE3
ZGU1OT5dIGtlcm5mc19hZGRfb25lKzB4ODkvMHgxMzAKWyAgICAwLjExOTI3OV0gKnBkcHQg
PSAwMDAwMDAwMDAwMDAwMDAwICpwZGUgPSAwMDAwMDAwMDAwMDAwMDAwIApbICAgIDAuMTIw
MDAwXSBPb3BzOiAwMDAyIFsjMV0gU01QIApbICAgIDAuMTIwMDAwXSBNb2R1bGVzIGxpbmtl
ZCBpbjoKWyAgICAwLjEyMDAwMF0gQ1BVOiAwIFBJRDogMSBDb21tOiBzd2FwcGVyLzAgTm90
IHRhaW50ZWQgMy4xNy4wLXJjNi0wMDE0OS1nZjMxM2NhOCAjMQpbICAgIDAuMTIwMDAwXSBI
YXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAwMS8wMS8yMDExClsgICAg
MC4xMjAwMDBdIHRhc2s6IGQzMDNhYzkwIHRpOiBkMzAzYzAwMCB0YXNrLnRpOiBkMzAzYzAw
MApbICAgIDAuMTIwMDAwXSBFSVA6IDAwNjA6WzxjMTE3ZGU1OT5dIEVGTEFHUzogMDAwMTAy
ODIgQ1BVOiAwClsgICAgMC4xMjAwMDBdIEVJUCBpcyBhdCBrZXJuZnNfYWRkX29uZSsweDg5
LzB4MTMwClsgICAgMC4xMjAwMDBdIEVBWDogNTQyNTRlNjMgRUJYOiAyNGUwMDAwMCBFQ1g6
IDAwMDAwMDA4IEVEWDogMmQwNGNiMzgKWyAgICAwLjEyMDAwMF0gRVNJOiBkMzA2OTAzMCBF
REk6IGQzMDY5MDkwIEVCUDogZDMwM2RlNTQgRVNQOiBkMzAzZGUzMApbICAgIDAuMTIwMDAw
XSAgRFM6IDAwN2IgRVM6IDAwN2IgRlM6IDAwZDggR1M6IDAwMDAgU1M6IDAwNjgKWyAgICAw
LjEyMDAwMF0gQ1IwOiA4MDA1MDAzYiBDUjI6IDI0ZTAwMDIwIENSMzogMDFhOGEwMDAgQ1I0
OiAwMDAwMDZmMApbICAgIDAuMTIwMDAwXSBTdGFjazoKWyAgICAwLjEyMDAwMF0gIGQzMDA2
ZjAwIDAwMDAwMjAyIGQzMDY5MDkwIGQzMDY5MDMwIGQzMDNkZTU0IGMxMTdkZDAwIGQzMDY5
MDMwIGMxNTlhNWMwClsgICAgMC4xMjAwMDBdICBjMTg3NTNhYyBkMzAzZGU2YyBjMTE3ZjI1
MiAwMDAwMDAwMCBjMTg3NTNhMCBkMzA2OTA5MCAwMDAwMDAwMCBkMzAzZGVhOApbICAgIDAu
MTIwMDAwXSAgYzExN2ZhMTUgMDAwMDEwMDAgMDAwMDAwMDAgYzE1OWE1YzAgYzE4NzUzYTAg
MDAwMDAwMDAgMDAwMDAwMDEgYzE4NzUzYWMKWyAgICAwLjEyMDAwMF0gQ2FsbCBUcmFjZToK
WyAgICAwLjEyMDAwMF0gIFs8YzExN2RkMDA+XSA/IGtlcm5mc19uZXdfbm9kZSsweDMwLzB4
NDAKWyAgICAwLjEyMDAwMF0gIFs8YzExN2YyNTI+XSBfX2tlcm5mc19jcmVhdGVfZmlsZSsw
eDkyLzB4YzAKWyAgICAwLjEyMDAwMF0gIFs8YzExN2ZhMTU+XSBzeXNmc19hZGRfZmlsZV9t
b2RlX25zKzB4OTUvMHgxOTAKWyAgICAwLjEyMDAwMF0gIFs8YzExN2ZjYWU+XSBzeXNmc19h
ZGRfZmlsZSsweDFlLzB4MzAKWyAgICAwLjEyMDAwMF0gIFs8YzExODAzMmE+XSBzeXNmc19t
ZXJnZV9ncm91cCsweDRhLzB4YzAKWyAgICAwLjEyMDAwMF0gIFs8YzEzMjQ5ZWM+XSBkcG1f
c3lzZnNfYWRkKzB4NWMvMHhiMApbICAgIDAuMTIwMDAwXSAgWzxjMTMxZGM0Nj5dIGRldmlj
ZV9hZGQrMHg0NDYvMHg1ODAKWyAgICAwLjEyMDAwMF0gIFs8YzEzMjdjYWE+XSA/IHBtX3J1
bnRpbWVfaW5pdCsweGVhLzB4ZjAKWyAgICAwLjEyMDAwMF0gIFs8YzEzMWRkOTI+XSBkZXZp
Y2VfcmVnaXN0ZXIrMHgxMi8weDIwClsgICAgMC4xMjAwMDBdICBbPGMxMzFmNGY3Pl0gc3Vi
c3lzX3JlZ2lzdGVyLnBhcnQuNisweDY3LzB4YjAKWyAgICAwLjEyMDAwMF0gIFs8YzEzMWY1
NjU+XSBzdWJzeXNfc3lzdGVtX3JlZ2lzdGVyKzB4MjUvMHgzMApbICAgIDAuMTIwMDAwXSAg
WzxjMThlNWUxMD5dIGNvbnRhaW5lcl9kZXZfaW5pdCsweGYvMHgyOApbICAgIDAuMTIwMDAw
XSAgWzxjMThlNWRmZj5dIGRyaXZlcl9pbml0KzB4MzAvMHgzMgpbICAgIDAuMTIwMDAwXSAg
WzxjMThiMmI1Mj5dIGtlcm5lbF9pbml0X2ZyZWVhYmxlKzB4N2QvMHgxNzkKWyAgICAwLjEy
MDAwMF0gIFs8YzE1NjdiMmI+XSBrZXJuZWxfaW5pdCsweGIvMHhkMApbICAgIDAuMTIwMDAw
XSAgWzxjMTU3NDhjMT5dIHJldF9mcm9tX2tlcm5lbF90aHJlYWQrMHgyMS8weDMwClsgICAg
MC4xMjAwMDBdICBbPGMxNTY3YjIwPl0gPyByZXN0X2luaXQrMHhiMC8weGIwClsgICAgMC4x
MjAwMDBdIENvZGU6IDI2IDAwIDgzIGUxIDEwIDc1IDViIDhiIDQ2IDI0IGU4IGIzIGVhIGZm
IGZmIDg5IDQ2IDM4IDg5IGYwIGU4IGQ5IGY5IGZmIGZmIDg1IGMwIDg5IGMzIDc1IGNhIDhi
IDVmIDVjIDg1IGRiIDc0IDExIGU4IDQ3IDhmIGYxIGZmIDw4OT4gNDMgMjAgODkgNTMgMjQg
ODkgNDMgMjggODkgNTMgMmMgYjggNDAgMmYgODUgYzEgZTggNDEgMzggM2YKWyAgICAwLjEy
MDAwMF0gRUlQOiBbPGMxMTdkZTU5Pl0ga2VybmZzX2FkZF9vbmUrMHg4OS8weDEzMCBTUzpF
U1AgMDA2ODpkMzAzZGUzMApbICAgIDAuMTIwMDAwXSBDUjI6IDAwMDAwMDAwMjRlMDAwMjAK
WyAgICAwLjEyMDAwMF0gLS0tWyBlbmQgdHJhY2UgNjhmZDIxMDZlYjQwZTU1MyBdLS0tClsg
ICAgMC4xMjAwMDBdIEtlcm5lbCBwYW5pYyAtIG5vdCBzeW5jaW5nOiBGYXRhbCBleGNlcHRp
b24KL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzL2YzMTNjYTgyZDcyMDY2
YTNjNDRmZDZjNjZjZWU1N2IyNWRlNDNhYTkvZG1lc2cteW9jdG8tdnAtMzk6MjAxNDA5MjYx
OTMwNTA6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LTAwMTQ5LWdm
MzEzY2E4OjEKMDoxOjEgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKG1sxOzM1bTIwMTQt
MDktMjYgMTk6MzE6NTMgUkVQRUFUIENPVU5UOiAyMCAgIyAvYy9ib290LWJpc2VjdC9saW51
eC0xL29iai1iaXNlY3QvLnJlcGVhdBtbMG0KCkJpc2VjdGluZzogNzIgcmV2aXNpb25zIGxl
ZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDYgc3RlcHMpClsyYzVmZTkyMTMwNDhj
NTY0MGI4ZTQ2NDA3ZjU2MTQwMzhjMDNhZDkzXSBtbTogZml4IGttZW1jaGVjay5jIGJ1aWxk
IGVycm9ycwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1
cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXgtMS9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQt
dGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzL25leHQ6
bWFzdGVyOjJjNWZlOTIxMzA0OGM1NjQwYjhlNDY0MDdmNTYxNDAzOGMwM2FkOTM6YmlzZWN0
LWxpbnV4LTEKCjIwMTQtMDktMjYgMTk6MzE6NTQgMmM1ZmU5MjEzMDQ4YzU2NDBiOGU0NjQw
N2Y1NjE0MDM4YzAzYWQ5MyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWls
ZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzLTJjNWZlOTIxMzA0OGM1NjQwYjhlNDY0MDdmNTYxNDAzOGMwM2FkOTMKQ2hlY2sgZm9y
IGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvMmM1ZmU5
MjEzMDQ4YzU2NDBiOGU0NjQwN2Y1NjE0MDM4YzAzYWQ5Mwp3YWl0aW5nIGZvciBjb21wbGV0
aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy0yYzVmZTkyMTMwNDhjNTY0MGI4ZTQ2NDA3ZjU2MTQwMzhjMDNh
ZDkzChtbMTszNW0yMDE0LTA5LTI2IDE5OjM0OjU0IE5vIGJ1aWxkIHNlcnZlZCBmaWxlIC9r
YnVpbGQtdGVzdHMvYnVpbGQtc2VydmVkL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMt
MmM1ZmU5MjEzMDQ4YzU2NDBiOGU0NjQwN2Y1NjE0MDM4YzAzYWQ5MxtbMG0KUmV0cnkgYnVp
bGQgLi4Ka2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvMmM1
ZmU5MjEzMDQ4YzU2NDBiOGU0NjQwN2Y1NjE0MDM4YzAzYWQ5My92bWxpbnV6LTMuMTcuMC1y
YzYtMDAwNzYtZzJjNWZlOTIKCjIwMTQtMDktMjYgMTk6MzU6NTQgZGV0ZWN0aW5nIGJvb3Qg
c3RhdGUgLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4JMS4uLgk0CTUJNwkxMAkxMwkxNAkxNgkxOQkyMCBTVUND
RVNTCgpCaXNlY3Rpbmc6IDM2IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAo
cm91Z2hseSA1IHN0ZXBzKQpbNjk0NTRmOGJlN2Y2MjFhYzhjM2M2Yzk3NjNiYjcwZTExNjk4
ODk0Ml0gYmxvY2tfZGV2OiBpbXBsZW1lbnQgcmVhZHBhZ2VzKCkgdG8gb3B0aW1pemUgc2Vx
dWVudGlhbCByZWFkCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3Qt
ZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eC0xL29iai1iaXNlY3QKbHMgLWEgL2ti
dWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMv
bmV4dDptYXN0ZXI6Njk0NTRmOGJlN2Y2MjFhYzhjM2M2Yzk3NjNiYjcwZTExNjk4ODk0Mjpi
aXNlY3QtbGludXgtMQoKMjAxNC0wOS0yNiAyMDoxNjozMCA2OTQ1NGY4YmU3ZjYyMWFjOGMz
YzZjOTc2M2JiNzBlMTE2OTg4OTQyIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAv
a2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyMzIzMDMtNjk0NTRmOGJlN2Y2MjFhYzhjM2M2Yzk3NjNiYjcwZTExNjk4ODk0MgpDaGVj
ayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy82
OTQ1NGY4YmU3ZjYyMWFjOGMzYzZjOTc2M2JiNzBlMTE2OTg4OTQyCndhaXRpbmcgZm9yIGNv
bXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLTY5NDU0ZjhiZTdmNjIxYWM4YzNjNmM5NzYzYmI3MGUx
MTY5ODg5NDIKG1sxOzM1bTIwMTQtMDktMjYgMjA6MTg6MzAgTm8gYnVpbGQgc2VydmVkIGZp
bGUgL2tidWlsZC10ZXN0cy9idWlsZC1zZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy02OTQ1NGY4YmU3ZjYyMWFjOGMzYzZjOTc2M2JiNzBlMTE2OTg4OTQyG1swbQpSZXRy
eSBidWlsZCAuLgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVp
bGQtcXVldWUvbGtwLWliMDMtc21va2UvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy02
OTQ1NGY4YmU3ZjYyMWFjOGMzYzZjOTc2M2JiNzBlMTE2OTg4OTQyCmtlcm5lbDogL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzY5NDU0ZjhiZTdmNjIxYWM4YzNjNmM5
NzYzYmI3MGUxMTY5ODg5NDIvdm1saW51ei0zLjE3LjAtcmM2LTAwMTEyLWc2OTQ1NGY4Cgoy
MDE0LTA5LTI2IDIwOjM0OjMwIGRldGVjdGluZyBib290IHN0YXRlIC4gVEVTVCBGQUlMVVJF
ClsgICAgNi4zMTgxMTFdIEFDUEk6IFBvd2VyIEJ1dHRvbiBbUFdSRl0KWyAgICA2LjMzODI3
Ml0gaXNhcG5wOiBTY2FubmluZyBmb3IgUG5QIGNhcmRzLi4uClsgICAgNy4yMzIxMTJdIGlz
YXBucDogTm8gUGx1ZyAmIFBsYXkgZGV2aWNlIGZvdW5kClsgICAgNy4yNTkwMTZdIEJVRzog
dW5hYmxlIHRvIGhhbmRsZSBrZXJuZWwgcGFnaW5nIHJlcXVlc3QgYXQgNzA2NjAwMjAKWyAg
ICA3LjI2MDI1MF0gSVA6IFs8YzExN2RkMDk+XSBrZXJuZnNfYWRkX29uZSsweDg5LzB4MTMw
ClsgICAgNy4yNjAyNTBdICpwZHB0ID0gMDAwMDAwMDAwMDAwMDAwMCAqcGRlID0gMDAwMDAw
MDAwMDAwMDAwMCAKWyAgICA3LjI2MDI1MF0gT29wczogMDAwMiBbIzFdIFNNUCAKWyAgICA3
LjI2MDI1MF0gTW9kdWxlcyBsaW5rZWQgaW46ClsgICAgNy4yNjAyNTBdIENQVTogMSBQSUQ6
IDEgQ29tbTogc3dhcHBlci8wIE5vdCB0YWludGVkIDMuMTcuMC1yYzYtMDAxMTItZzY5NDU0
ZjggIzEKWyAgICA3LjI2MDI1MF0gSGFyZHdhcmUgbmFtZTogUUVNVSBTdGFuZGFyZCBQQyAo
aTQ0MEZYICsgUElJWCwgMTk5NiksIEJJT1MgMS43LjUtMjAxNDA1MzFfMDgzMDMwLWdhbmRh
bGYgMDQvMDEvMjAxNApbICAgIDcuMjYwMjUwXSB0YXNrOiBkMWM0NGM5MCB0aTogZDFjNDYw
MDAgdGFzay50aTogZDFjNDYwMDAKWyAgICA3LjI2MDI1MF0gRUlQOiAwMDYwOls8YzExN2Rk
MDk+XSBFRkxBR1M6IDAwMDEwMjg2IENQVTogMQpbICAgIDcuMjYwMjUwXSBFSVAgaXMgYXQg
a2VybmZzX2FkZF9vbmUrMHg4OS8weDEzMApbICAgIDcuMjYwMjUwXSBFQVg6IDU0MjU1ZDU3
IEVCWDogNzA2NjAwMDAgRUNYOiAwMDAwMDAxNyBFRFg6IDA0ZWU5MDlhClsgICAgNy4yNjAy
NTBdIEVTSTogYzAwMTJmMzAgRURJOiBjMDAxMmY5MCBFQlA6IGQxYzQ3ZDk0IEVTUDogZDFj
NDdkNzAKWyAgICA3LjI2MDI1MF0gIERTOiAwMDdiIEVTOiAwMDdiIEZTOiAwMGQ4IEdTOiAw
MDAwIFNTOiAwMDY4ClsgICAgNy4yNjAyNTBdIENSMDogODAwNTAwM2IgQ1IyOiA3MDY2MDAy
MCBDUjM6IDAxYThhMDAwIENSNDogMDAwMDA2ZjAKWyAgICA3LjI2MDI1MF0gU3RhY2s6Clsg
ICAgNy4yNjAyNTBdICBkMWMwNmYwMCAwMDAwMDIwMiBjMDAxMmY5MCBjMDAxMmYzMCBkMWM0
N2Q5NCBjMTE3ZGJiMCBjMDAxMmYzMCBjMTU5YTVjMApbICAgIDcuMjYwMjUwXSAgYzE4NzQ3
MzAgZDFjNDdkYWMgYzExN2YxMDIgMDAwMDAwMDAgYzE4NzQ3MjQgYzAwMTJmOTAgMDAwMDAw
MDAgZDFjNDdkZTgKWyAgICA3LjI2MDI1MF0gIGMxMTdmOGM1IDAwMDAxMDAwIDAwMDAwMDAw
IGMxNTlhNWMwIGMxODc0NzI0IDAwMDAwMDAwIDAwMDAwMDAxIGMxODc0NzMwClsgICAgNy4y
NjAyNTBdIENhbGwgVHJhY2U6ClsgICAgNy4yNjAyNTBdICBbPGMxMTdkYmIwPl0gPyBrZXJu
ZnNfbmV3X25vZGUrMHgzMC8weDQwClsgICAgNy4yNjAyNTBdICBbPGMxMTdmMTAyPl0gX19r
ZXJuZnNfY3JlYXRlX2ZpbGUrMHg5Mi8weGMwClsgICAgNy4yNjAyNTBdICBbPGMxMTdmOGM1
Pl0gc3lzZnNfYWRkX2ZpbGVfbW9kZV9ucysweDk1LzB4MTkwClsgICAgNy4yNjAyNTBdICBb
PGMxMTdmOWU3Pl0gc3lzZnNfY3JlYXRlX2ZpbGVfbnMrMHgyNy8weDQwClsgICAgNy4yNjAy
NTBdICBbPGMxMzFjMjU5Pl0gZGV2aWNlX2NyZWF0ZV9maWxlKzB4MzkvMHhiMApbICAgIDcu
MjYwMjUwXSAgWzxjMTJhNjNhZT5dID8gYWNwaV9wbGF0Zm9ybV9ub3RpZnkrMHgxOS8weDc4
ClsgICAgNy4yNjAyNTBdICBbPGMxMzFkN2FmPl0gZGV2aWNlX2FkZCsweGZmLzB4NTgwClsg
ICAgNy4yNjAyNTBdICBbPGMxMzI3YjVhPl0gPyBwbV9ydW50aW1lX2luaXQrMHhlYS8weGYw
ClsgICAgNy4yNjAyNTBdICBbPGMxMzFkYzQyPl0gZGV2aWNlX3JlZ2lzdGVyKzB4MTIvMHgy
MApbICAgIDcuMjYwMjUwXSAgWzxjMTJkZWY0Nj5dIHR0eV9yZWdpc3Rlcl9kZXZpY2VfYXR0
cisweGI2LzB4MjgwClsgICAgNy4yNjAyNTBdICBbPGMxNTcxNTY4Pl0gPyBtdXRleF91bmxv
Y2srMHg4LzB4MTAKWyAgICA3LjI2MDI1MF0gIFs8YzExMWViZDM+XSA/IGNkZXZfYWRkKzB4
NDMvMHg1MApbICAgIDcuMjYwMjUwXSAgWzxjMTJkZjIyNj5dIHR0eV9yZWdpc3Rlcl9kcml2
ZXIrMHhmNi8weDFiMApbICAgIDcuMjYwMjUwXSAgWzxjMThlMmFkNj5dIHB0eV9pbml0KzB4
MTJlLzB4MzI5ClsgICAgNy4yNjAyNTBdICBbPGMxOGUyOWE4Pl0gPyB0dHlfaW5pdCsweDEx
MC8weDExMApbICAgIDcuMjYwMjUwXSAgWzxjMTAwMDQxZT5dIGRvX29uZV9pbml0Y2FsbCsw
eDdlLzB4MWIwClsgICAgNy4yNjAyNTBdICBbPGMxOGUyOWE4Pl0gPyB0dHlfaW5pdCsweDEx
MC8weDExMApbICAgIDcuMjYwMjUwXSAgWzxjMThiMjRiYT5dID8gcmVwYWlyX2Vudl9zdHJp
bmcrMHgxMi8weDU0ClsgICAgNy4yNjAyNTBdICBbPGMxOGIyNGE4Pl0gPyBpbml0Y2FsbF9i
bGFja2xpc3QrMHg3Yy8weDdjClsgICAgNy4yNjAyNTBdICBbPGMxMDVlMTAwPl0gPyBwYXJz
ZV9hcmdzKzB4MTYwLzB4M2YwClsgICAgNy4yNjAyNTBdICBbPGMxOGIyYmQxPl0ga2VybmVs
X2luaXRfZnJlZWFibGUrMHhmYy8weDE3OQpbICAgIDcuMjYwMjUwXSAgWzxjMTU2NzlkYj5d
IGtlcm5lbF9pbml0KzB4Yi8weGQwClsgICAgNy4yNjAyNTBdICBbPGMxNTc0NzgxPl0gcmV0
X2Zyb21fa2VybmVsX3RocmVhZCsweDIxLzB4MzAKWyAgICA3LjI2MDI1MF0gIFs8YzE1Njc5
ZDA+XSA/IHJlc3RfaW5pdCsweGIwLzB4YjAKWyAgICA3LjI2MDI1MF0gQ29kZTogMjYgMDAg
ODMgZTEgMTAgNzUgNWIgOGIgNDYgMjQgZTggYjMgZWEgZmYgZmYgODkgNDYgMzggODkgZjAg
ZTggZDkgZjkgZmYgZmYgODUgYzAgODkgYzMgNzUgY2EgOGIgNWYgNWMgODUgZGIgNzQgMTEg
ZTggODcgOTAgZjEgZmYgPDg5PiA0MyAyMCA4OSA1MyAyNCA4OSA0MyAyOCA4OSA1MyAyYyBi
OCA4MCAyZiA4NSBjMSBlOCA0MSAzOCAzZgpbICAgIDcuMjYwMjUwXSBFSVA6IFs8YzExN2Rk
MDk+XSBrZXJuZnNfYWRkX29uZSsweDg5LzB4MTMwIFNTOkVTUCAwMDY4OmQxYzQ3ZDcwClsg
ICAgNy4yNjAyNTBdIENSMjogMDAwMDAwMDA3MDY2MDAyMApbICAgIDcuMjYwMjUwXSAtLS1b
IGVuZCB0cmFjZSBjYTYzNGIxNzFkNzE4MmIzIF0tLS0KWyAgICA3LjI2MDI1MF0gS2VybmVs
IHBhbmljIC0gbm90IHN5bmNpbmc6IEZhdGFsIGV4Y2VwdGlvbgova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMvNjk0NTRmOGJlN2Y2MjFhYzhjM2M2Yzk3NjNiYjcwZTEx
Njk4ODk0Mi9kbWVzZy1xdWFudGFsLXZwLTE0OjIwMTQwOTI2MjAzNDAyOmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi0wMDExMi1nNjk0NTRmODoxCi9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy82OTQ1NGY4YmU3ZjYyMWFjOGMzYzZjOTc2
M2JiNzBlMTE2OTg4OTQyL2RtZXNnLXF1YW50YWwtdnAtNToyMDE0MDkyNjIwMzQwMTppMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtMDAxMTItZzY5NDU0Zjg6MQov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNjk0NTRmOGJlN2Y2MjFhYzhj
M2M2Yzk3NjNiYjcwZTExNjk4ODk0Mi9kbWVzZy1xdWFudGFsLXZwLTc6MjAxNDA5MjYyMDM0
MDI6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LTAwMTEyLWc2OTQ1
NGY4OjEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzY5NDU0ZjhiZTdm
NjIxYWM4YzNjNmM5NzYzYmI3MGUxMTY5ODg5NDIvZG1lc2cteW9jdG8tdnAtMTg6MjAxNDA5
MjYyMDM0MDM6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LTAwMTEy
LWc2OTQ1NGY4OjEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzY5NDU0
ZjhiZTdmNjIxYWM4YzNjNmM5NzYzYmI3MGUxMTY5ODg5NDIvZG1lc2ctcXVhbnRhbC1sa3At
bmV4MDQtMTY3OjIwMTQwOTI2MjAzNDA5OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6
Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNjk0NTRmOGJlN2Y2MjFh
YzhjM2M2Yzk3NjNiYjcwZTExNjk4ODk0Mi9kbWVzZy1xdWFudGFsLXZwLTE1OjIwMTQwOTI2
MjAzNDExOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi0wMDExMi1n
Njk0NTRmODoxCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy82OTQ1NGY4
YmU3ZjYyMWFjOGMzYzZjOTc2M2JiNzBlMTE2OTg4OTQyL2RtZXNnLXF1YW50YWwtdnAtMjc6
MjAxNDA5MjYyMDM0MDk6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2
LTAwMTEyLWc2OTQ1NGY4OjEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
LzY5NDU0ZjhiZTdmNjIxYWM4YzNjNmM5NzYzYmI3MGUxMTY5ODg5NDIvZG1lc2cteW9jdG8t
bGtwLW5leDA0LTEyNjoyMDE0MDkyNjIwMzQyNTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzY5NDU0ZjhiZTdm
NjIxYWM4YzNjNmM5NzYzYmI3MGUxMTY5ODg5NDIvZG1lc2cteW9jdG8tbGtwLW5leDA0LTE1
NzoyMDE0MDkyNjIwMzQyMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzY5NDU0ZjhiZTdmNjIxYWM4YzNjNmM5
NzYzYmI3MGUxMTY5ODg5NDIvZG1lc2ctcXVhbnRhbC1sa3AtbmV4MDQtMTA6MjAxNDA5MjYy
MDM0Mzk6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMy82OTQ1NGY4YmU3ZjYyMWFjOGMzYzZjOTc2M2JiNzBlMTE2
OTg4OTQyL2RtZXNnLXF1YW50YWwtbGtwLW5leDA0LTEzMDoyMDE0MDkyNjIwMzQzOTppMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzLzY5NDU0ZjhiZTdmNjIxYWM4YzNjNmM5NzYzYmI3MGUxMTY5ODg5NDIvZG1l
c2ctcXVhbnRhbC1sa3AtbmV4MDQtMTUwOjIwMTQwOTI2MjAzNDM2OmkzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMv
Njk0NTRmOGJlN2Y2MjFhYzhjM2M2Yzk3NjNiYjcwZTExNjk4ODk0Mi9kbWVzZy1xdWFudGFs
LWxrcC1uZXgwNC0xODM6MjAxNDA5MjYyMDM0NDA6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy82OTQ1NGY4YmU3
ZjYyMWFjOGMzYzZjOTc2M2JiNzBlMTE2OTg4OTQyL2RtZXNnLXF1YW50YWwtbGtwLW5leDA0
LTM2OjIwMTQwOTI2MjAzNDQxOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNjk0NTRmOGJlN2Y2MjFhYzhjM2M2
Yzk3NjNiYjcwZTExNjk4ODk0Mi9kbWVzZy1xdWFudGFsLWxrcC1uZXgwNC00MzoyMDE0MDky
NjIwMzQzNjppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLzY5NDU0ZjhiZTdmNjIxYWM4YzNjNmM5NzYzYmI3MGUx
MTY5ODg5NDIvZG1lc2ctcXVhbnRhbC1sa3AtbmV4MDQtNjk6MjAxNDA5MjYyMDM0Mzk6aTM4
Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMy82OTQ1NGY4YmU3ZjYyMWFjOGMzYzZjOTc2M2JiNzBlMTE2OTg4OTQyL2Rt
ZXNnLXF1YW50YWwtbGtwLW5leDA0LTc3OjIwMTQwOTI2MjAzNDM3OmkzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMv
Njk0NTRmOGJlN2Y2MjFhYzhjM2M2Yzk3NjNiYjcwZTExNjk4ODk0Mi9kbWVzZy1xdWFudGFs
LWxrcC1uZXgwNC00OjIwMTQwOTI2MjAzNDQxOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDM6OgowOjE4OjE4IGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzChtbMTszNW0yMDE0LTA5
LTI2IDIwOjM1OjAxIFJFUEVBVCBDT1VOVDogMjAgICMgL2MvYm9vdC1iaXNlY3QvbGludXgt
MS9vYmotYmlzZWN0Ly5yZXBlYXQbWzBtCgpCaXNlY3Rpbmc6IDE3IHJldmlzaW9ucyBsZWZ0
IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA0IHN0ZXBzKQpbNjZhMzFkNTI4YTFlM2Q0
ODNiZTJiMWM5OTNlYzEyNjg0MTJmMDA3NF0gbWVtb3J5LWhvdHBsdWctYWRkLXN5c2ZzLXpv
bmVzX29ubGluZV90by1hdHRyaWJ1dGUtZml4LTIKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMv
YmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4LTEvb2Jq
LWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy9uZXh0Om1hc3Rlcjo2NmEzMWQ1MjhhMWUzZDQ4M2JlMmIxYzk5
M2VjMTI2ODQxMmYwMDc0OmJpc2VjdC1saW51eC0xCgoyMDE0LTA5LTI2IDIwOjM1OjAyIDY2
YTMxZDUyOGExZTNkNDgzYmUyYjFjOTkzZWMxMjY4NDEyZjAwNzQgY29tcGlsaW5nClF1ZXVl
ZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMvaTM4
Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy02NmEzMWQ1MjhhMWUzZDQ4M2JlMmIxYzk5M2Vj
MTI2ODQxMmYwMDc0CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzLzY2YTMxZDUyOGExZTNkNDgzYmUyYjFjOTkzZWMxMjY4NDEyZjAw
NzQKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVl
L2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMtNjZhMzFkNTI4YTFlM2Q0
ODNiZTJiMWM5OTNlYzEyNjg0MTJmMDA3NAobWzE7MzVtMjAxNC0wOS0yNiAyMDozODowMiBO
byBidWlsZCBzZXJ2ZWQgZmlsZSAva2J1aWxkLXRlc3RzL2J1aWxkLXNlcnZlZC9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLTY2YTMxZDUyOGExZTNkNDgzYmUyYjFjOTkzZWMxMjY4
NDEyZjAwNzQbWzBtClJldHJ5IGJ1aWxkIC4uCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2Yg
L2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy1zbW9rZS9pMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzLTY2YTMxZDUyOGExZTNkNDgzYmUyYjFjOTkzZWMxMjY4NDEyZjAw
NzQKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNjZhMzFk
NTI4YTFlM2Q0ODNiZTJiMWM5OTNlYzEyNjg0MTJmMDA3NC92bWxpbnV6LTMuMTcuMC1yYzYt
MDAwOTQtZzY2YTMxZDUKCjIwMTQtMDktMjYgMjA6NDA6MDIgZGV0ZWN0aW5nIGJvb3Qgc3Rh
dGUgLiBURVNUIEZBSUxVUkUKWyAgICAwLjE4MDAwM10gLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tClsgICAgMC4xODEyNjhdIHNtcGJvb3Q6IFRvdGFsIG9mIDEgcHJvY2Vz
c29ycyBhY3RpdmF0ZWQgKDQ1MjEuOTkgQm9nb01JUFMpClsgICAgMC4xODUxMjZdIGRldnRt
cGZzOiBpbml0aWFsaXplZApbICAgIDAuMTg4NDY3XSBCVUc6IHVuYWJsZSB0byBoYW5kbGUg
a2VybmVsIHBhZ2luZyByZXF1ZXN0IGF0IDI0YzAwMDIwClsgICAgMC4xOTAzMDJdIElQOiBb
PGMxMTdkYzc5Pl0ga2VybmZzX2FkZF9vbmUrMHg4OS8weDEzMApbICAgIDAuMTkyMDAwXSAq
cGRwdCA9IDAwMDAwMDAwMDAwMDAwMDAgKnBkZSA9IDAwMDAwMDAwMDAwMDAwMDAgClsgICAg
MC4xOTIwMDBdIE9vcHM6IDAwMDIgWyMxXSBTTVAgClsgICAgMC4xOTIwMDBdIE1vZHVsZXMg
bGlua2VkIGluOgpbICAgIDAuMTkyMDAwXSBDUFU6IDAgUElEOiAxIENvbW06IHN3YXBwZXIv
MCBOb3QgdGFpbnRlZCAzLjE3LjAtcmM2LTAwMDk0LWc2NmEzMWQ1ICMyClsgICAgMC4xOTIw
MDBdIEhhcmR3YXJlIG5hbWU6IFFFTVUgU3RhbmRhcmQgUEMgKGk0NDBGWCArIFBJSVgsIDE5
OTYpLCBCSU9TIDEuNy41LTIwMTQwNTMxXzA4MzAzMC1nYW5kYWxmIDA0LzAxLzIwMTQKWyAg
ICAwLjE5MjAwMF0gdGFzazogZDMwM2FjOTAgdGk6IGQzMDNjMDAwIHRhc2sudGk6IGQzMDNj
MDAwClsgICAgMC4xOTIwMDBdIEVJUDogMDA2MDpbPGMxMTdkYzc5Pl0gRUZMQUdTOiAwMDAx
MDI4MiBDUFU6IDAKWyAgICAwLjE5MjAwMF0gRUlQIGlzIGF0IGtlcm5mc19hZGRfb25lKzB4
ODkvMHgxMzAKWyAgICAwLjE5MjAwMF0gRUFYOiA1NDI1NWU5MCBFQlg6IDI0YzAwMDAwIEVD
WDogMDAwMDAwMDggRURYOiAyMWViNzNkMQpbICAgIDAuMTkyMDAwXSBFU0k6IGQzMDY5MDMw
IEVESTogZDMwNjkwOTAgRUJQOiBkMzAzZGU1NCBFU1A6IGQzMDNkZTMwClsgICAgMC4xOTIw
MDBdICBEUzogMDA3YiBFUzogMDA3YiBGUzogMDBkOCBHUzogMDAwMCBTUzogMDA2OApbICAg
IDAuMTkyMDAwXSBDUjA6IDgwMDUwMDNiIENSMjogMjRjMDAwMjAgQ1IzOiAwMWE4YTAwMCBD
UjQ6IDAwMDAwNmYwClsgICAgMC4xOTIwMDBdIFN0YWNrOgpbICAgIDAuMTkyMDAwXSAgZDMw
MDZmMDAgMDAwMDAyMDIgZDMwNjkwOTAgZDMwNjkwMzAgZDMwM2RlNTQgYzExN2RiMjAgZDMw
NjkwMzAgYzE1OWE1YzAKWyAgICAwLjE5MjAwMF0gIGMxODc1M2VjIGQzMDNkZTZjIGMxMTdm
MDcyIDAwMDAwMDAwIGMxODc1M2UwIGQzMDY5MDkwIDAwMDAwMDAwIGQzMDNkZWE4ClsgICAg
MC4xOTIwMDBdICBjMTE3ZjgzNSAwMDAwMTAwMCAwMDAwMDAwMCBjMTU5YTVjMCBjMTg3NTNl
MCAwMDAwMDAwMCAwMDAwMDAwMSBjMTg3NTNlYwpbICAgIDAuMTkyMDAwXSBDYWxsIFRyYWNl
OgpbICAgIDAuMTkyMDAwXSAgWzxjMTE3ZGIyMD5dID8ga2VybmZzX25ld19ub2RlKzB4MzAv
MHg0MApbICAgIDAuMTkyMDAwXSAgWzxjMTE3ZjA3Mj5dIF9fa2VybmZzX2NyZWF0ZV9maWxl
KzB4OTIvMHhjMApbICAgIDAuMTkyMDAwXSAgWzxjMTE3ZjgzNT5dIHN5c2ZzX2FkZF9maWxl
X21vZGVfbnMrMHg5NS8weDE5MApbICAgIDAuMTkyMDAwXSAgWzxjMTE3ZmFjZT5dIHN5c2Zz
X2FkZF9maWxlKzB4MWUvMHgzMApbICAgIDAuMTkyMDAwXSAgWzxjMTE4MDE0YT5dIHN5c2Zz
X21lcmdlX2dyb3VwKzB4NGEvMHhjMApbICAgIDAuMTkyMDAwXSAgWzxjMTMyNDgwYz5dIGRw
bV9zeXNmc19hZGQrMHg1Yy8weGIwClsgICAgMC4xOTIwMDBdICBbPGMxMzFkYTY2Pl0gZGV2
aWNlX2FkZCsweDQ0Ni8weDU4MApbICAgIDAuMTkyMDAwXSAgWzxjMTMyN2FjYT5dID8gcG1f
cnVudGltZV9pbml0KzB4ZWEvMHhmMApbICAgIDAuMTkyMDAwXSAgWzxjMTMxZGJiMj5dIGRl
dmljZV9yZWdpc3RlcisweDEyLzB4MjAKWyAgICAwLjE5MjAwMF0gIFs8YzEzMWYzMTc+XSBz
dWJzeXNfcmVnaXN0ZXIucGFydC42KzB4NjcvMHhiMApbICAgIDAuMTkyMDAwXSAgWzxjMTMx
ZjM4NT5dIHN1YnN5c19zeXN0ZW1fcmVnaXN0ZXIrMHgyNS8weDMwClsgICAgMC4xOTIwMDBd
ICBbPGMxOGU1ZTEwPl0gY29udGFpbmVyX2Rldl9pbml0KzB4Zi8weDI4ClsgICAgMC4xOTIw
MDBdICBbPGMxOGU1ZGZmPl0gZHJpdmVyX2luaXQrMHgzMC8weDMyClsgICAgMC4xOTIwMDBd
ICBbPGMxOGIyYjUyPl0ga2VybmVsX2luaXRfZnJlZWFibGUrMHg3ZC8weDE3OQpbICAgIDAu
MTkyMDAwXSAgWzxjMTU2NzdhYj5dIGtlcm5lbF9pbml0KzB4Yi8weGQwClsgICAgMC4xOTIw
MDBdICBbPGMxNTc0NTQxPl0gcmV0X2Zyb21fa2VybmVsX3RocmVhZCsweDIxLzB4MzAKWyAg
ICAwLjE5MjAwMF0gIFs8YzE1Njc3YTA+XSA/IHJlc3RfaW5pdCsweGIwLzB4YjAKWyAgICAw
LjE5MjAwMF0gQ29kZTogMjYgMDAgODMgZTEgMTAgNzUgNWIgOGIgNDYgMjQgZTggYjMgZWEg
ZmYgZmYgODkgNDYgMzggODkgZjAgZTggZDkgZjkgZmYgZmYgODUgYzAgODkgYzMgNzUgY2Eg
OGIgNWYgNWMgODUgZGIgNzQgMTEgZTggMTcgOTEgZjEgZmYgPDg5PiA0MyAyMCA4OSA1MyAy
NCA4OSA0MyAyOCA4OSA1MyAyYyBiOCA4MCAyZiA4NSBjMSBlOCBhMSAzNiAzZgpbICAgIDAu
MTkyMDAwXSBFSVA6IFs8YzExN2RjNzk+XSBrZXJuZnNfYWRkX29uZSsweDg5LzB4MTMwIFNT
OkVTUCAwMDY4OmQzMDNkZTMwClsgICAgMC4xOTIwMDBdIENSMjogMDAwMDAwMDAyNGMwMDAy
MApbICAgIDAuMTkyMDAwXSAtLS1bIGVuZCB0cmFjZSBjMzU3ODlhNDc4NjYxMzc3IF0tLS0K
WyAgICAwLjE5MjAwMF0gS2VybmVsIHBhbmljIC0gbm90IHN5bmNpbmc6IEZhdGFsIGV4Y2Vw
dGlvbgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNjZhMzFkNTI4YTFl
M2Q0ODNiZTJiMWM5OTNlYzEyNjg0MTJmMDA3NC9kbWVzZy15b2N0by1sa3AtbmV4MDQtMTA6
MjAxNDA5MjYyMDM5NTI6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6CjA6MToxIGFs
bF9nb29kOmJhZDphbGxfYmFkIGJvb3RzChtbMTszNW0yMDE0LTA5LTI2IDIwOjQwOjMzIFJF
UEVBVCBDT1VOVDogMjAgICMgL2MvYm9vdC1iaXNlY3QvbGludXgtMS9vYmotYmlzZWN0Ly5y
ZXBlYXQbWzBtCgpCaXNlY3Rpbmc6IDggcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0
aGlzIChyb3VnaGx5IDMgc3RlcHMpCls1ZThhY2I2ODYxMGMwNzdiMDhjYjNmMTYzMDVhYTNj
YzIyZTVkMmE4XSBrZXJuZWwva3RocmVhZC5jOiBwYXJ0aWFsIHJldmVydCBvZiA4MWM5ODg2
OWZhYTUgKCJrdGhyZWFkOiBlbnN1cmUgbG9jYWxpdHkgb2YgdGFza19zdHJ1Y3QgYWxsb2Nh
dGlvbnMiKQpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1
cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXgtMS9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQt
dGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzL25leHQ6
bWFzdGVyOjVlOGFjYjY4NjEwYzA3N2IwOGNiM2YxNjMwNWFhM2NjMjJlNWQyYTg6YmlzZWN0
LWxpbnV4LTEKCjIwMTQtMDktMjYgMjA6NDA6MzQgNWU4YWNiNjg2MTBjMDc3YjA4Y2IzZjE2
MzA1YWEzY2MyMmU1ZDJhOCBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWls
ZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzLTVlOGFjYjY4NjEwYzA3N2IwOGNiM2YxNjMwNWFhM2NjMjJlNWQyYTgKQ2hlY2sgZm9y
IGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNWU4YWNi
Njg2MTBjMDc3YjA4Y2IzZjE2MzA1YWEzY2MyMmU1ZDJhOAp3YWl0aW5nIGZvciBjb21wbGV0
aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy01ZThhY2I2ODYxMGMwNzdiMDhjYjNmMTYzMDVhYTNjYzIyZTVk
MmE4ChtbMTszNW0yMDE0LTA5LTI2IDIwOjUxOjM0IE5vIGJ1aWxkIHNlcnZlZCBmaWxlIC9r
YnVpbGQtdGVzdHMvYnVpbGQtc2VydmVkL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMt
NWU4YWNiNjg2MTBjMDc3YjA4Y2IzZjE2MzA1YWEzY2MyMmU1ZDJhOBtbMG0KUmV0cnkgYnVp
bGQgLi4Kd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1
ZXVlL2xrcC1pYjAzLXNtb2tlL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMtNWU4YWNi
Njg2MTBjMDc3YjA4Y2IzZjE2MzA1YWEzY2MyMmU1ZDJhOAprZXJuZWw6IC9rZXJuZWwvaTM4
Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81ZThhY2I2ODYxMGMwNzdiMDhjYjNmMTYzMDVh
YTNjYzIyZTVkMmE4L3ZtbGludXotMy4xNy4wLXJjNi0wMDA4NS1nNWU4YWNiNgoKMjAxNC0w
OS0yNiAyMDo1NjozNCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4uLi4uCTEuLi4uCTMuLgk0
Lgk1CTcJMTcJMTkJMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiA0IHJldmlzaW9ucyBsZWZ0IHRv
IHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAyIHN0ZXBzKQpbMzZmYmZlYmU3NzZlYjU4NzFk
NjFlN2E3NTVjOWZlYjFjOTZjYzRhYV0gbW0vc2xhYjogc3VwcG9ydCBzbGFiIG1lcmdlCnJ1
bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9i
b290LWJpc2VjdC9saW51eC0xL29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4t
cXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvbmV4dDptYXN0ZXI6MzZm
YmZlYmU3NzZlYjU4NzFkNjFlN2E3NTVjOWZlYjFjOTZjYzRhYTpiaXNlY3QtbGludXgtMQoK
MjAxNC0wOS0yNiAyMTowNzozNiAzNmZiZmViZTc3NmViNTg3MWQ2MWU3YTc1NWM5ZmViMWM5
NmNjNGFhIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1
aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMtMzZmYmZl
YmU3NzZlYjU4NzFkNjFlN2E3NTVjOWZlYjFjOTZjYzRhYQpDaGVjayBmb3Iga2VybmVsIGlu
IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy8zNmZiZmViZTc3NmViNTg3
MWQ2MWU3YTc1NWM5ZmViMWM5NmNjNGFhCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2ti
dWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzLTM2ZmJmZWJlNzc2ZWI1ODcxZDYxZTdhNzU1YzlmZWIxYzk2Y2M0YWEKG1sxOzM1
bTIwMTQtMDktMjYgMjI6MDM6MzYgTm8gYnVpbGQgc2VydmVkIGZpbGUgL2tidWlsZC10ZXN0
cy9idWlsZC1zZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy0zNmZiZmViZTc3
NmViNTg3MWQ2MWU3YTc1NWM5ZmViMWM5NmNjNGFhG1swbQpSZXRyeSBidWlsZCAuLgp3YWl0
aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWli
MDMtc21va2UvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy0zNmZiZmViZTc3NmViNTg3
MWQ2MWU3YTc1NWM5ZmViMWM5NmNjNGFhCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzLzM2ZmJmZWJlNzc2ZWI1ODcxZDYxZTdhNzU1YzlmZWIxYzk2Y2M0
YWEvdm1saW51ei0zLjE3LjAtcmM2LTAwMDg5LWczNmZiZmViCgoyMDE0LTA5LTI2IDIyOjA1
OjM2IGRldGVjdGluZyBib290IHN0YXRlIC4uIFRFU1QgRkFJTFVSRQpbICAgIDEuNDI4MDEz
XSBBQ1BJOiAoc3VwcG9ydHMgUzAgUzUpClsgICAgMS40Mjg1NzldIEFDUEk6IFVzaW5nIElP
QVBJQyBmb3IgaW50ZXJydXB0IHJvdXRpbmcKWyAgICAxLjQyOTMzOF0gUENJOiBVc2luZyBo
b3N0IGJyaWRnZSB3aW5kb3dzIGZyb20gQUNQSTsgaWYgbmVjZXNzYXJ5LCB1c2UgInBjaT1u
b2NycyIgYW5kIHJlcG9ydCBhIGJ1ZwpbICAgIDEuNDMyMDE0XSBCVUc6IHVuYWJsZSB0byBo
YW5kbGUga2VybmVsIHBhZ2luZyByZXF1ZXN0IGF0IDU0MjU3MmU3ClsgICAgMS40MzYwMDRd
IElQOiBbPGMxMTdkNmUzPl0ga2VybmZzX2xpbmtfc2libGluZysweDIzLzB4YzAKWyAgICAx
LjQzNjAwNF0gKnBkcHQgPSAwMDAwMDAwMDAwMDAwMDAwICpwZGUgPSAwMDAwMDAwMDAwMDAw
MDAwIApbICAgIDEuNDM2MDA0XSBPb3BzOiAwMDAwIFsjMV0gU01QIApbICAgIDEuNDM2MDA0
XSBNb2R1bGVzIGxpbmtlZCBpbjoKWyAgICAxLjQzNjAwNF0gQ1BVOiAxIFBJRDogMSBDb21t
OiBzd2FwcGVyLzAgTm90IHRhaW50ZWQgMy4xNy4wLXJjNi0wMDA4OS1nMzZmYmZlYiAjMQpb
ICAgIDEuNDM2MDA0XSBIYXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAw
MS8wMS8yMDExClsgICAgMS40MzYwMDRdIHRhc2s6IGQxYzQ4YzkwIHRpOiBkMWM0YTAwMCB0
YXNrLnRpOiBkMWM0YTAwMApbICAgIDEuNDM2MDA0XSBFSVA6IDAwNjA6WzxjMTE3ZDZlMz5d
IEVGTEFHUzogMDAwMTAyMDYgQ1BVOiAxClsgICAgMS40MzYwMDRdIEVJUCBpcyBhdCBrZXJu
ZnNfbGlua19zaWJsaW5nKzB4MjMvMHhjMApbICAgIDEuNDM2MDA0XSBFQVg6IGFkOGZkMTMz
IEVCWDogNTQyNTcyZDcgRUNYOiBkMWQ2MDk1OCBFRFg6IDAxYjU0NDBhClsgICAgMS40MzYw
MDRdIEVTSTogZDFkNjA2OTAgRURJOiBjMTc3MmE5OCBFQlA6IGQxYzRiY2QwIEVTUDogZDFj
NGJjYzQKWyAgICAxLjQzNjAwNF0gIERTOiAwMDdiIEVTOiAwMDdiIEZTOiAwMGQ4IEdTOiAw
MDAwIFNTOiAwMDY4ClsgICAgMS40MzYwMDRdIENSMDogODAwNTAwM2IgQ1IyOiA1NDI1NzJl
NyBDUjM6IDAxYThhMDAwIENSNDogMDAwMDA2ZjAKWyAgICAxLjQzNjAwNF0gU3RhY2s6Clsg
ICAgMS40MzYwMDRdICBmZmZmZmZlYSBkMWQ2MDY5MCBkMWQ2MGE1MCBkMWM0YmNmYyBjMTE3
ZGNlNyBkMWMwNmYwMCAwMDAwMDIwMiBkMWQ2MGE1MApbICAgIDEuNDM2MDA0XSAgZDFkNjA2
OTAgZDFjNGJjZmMgYzExN2RiYTAgZDFkNjA2OTAgYzE1OWE1YzAgYzE4NjFjYjQgZDFjNGJk
MTQgYzExN2YwZjIKWyAgICAxLjQzNjAwNF0gIDAwMDAwMDAwIGMxODYxY2E4IGQxZDYwYTUw
IDAwMDAwMDAwIGQxYzRiZDUwIGMxMTdmOGI1IDAwMDAxMDAwIDAwMDAwMDAwClsgICAgMS40
MzYwMDRdIENhbGwgVHJhY2U6ClsgICAgMS40MzYwMDRdICBbPGMxMTdkY2U3Pl0ga2VybmZz
X2FkZF9vbmUrMHg3Ny8weDEzMApbICAgIDEuNDM2MDA0XSAgWzxjMTE3ZGJhMD5dID8ga2Vy
bmZzX25ld19ub2RlKzB4MzAvMHg0MApbICAgIDEuNDM2MDA0XSAgWzxjMTE3ZjBmMj5dIF9f
a2VybmZzX2NyZWF0ZV9maWxlKzB4OTIvMHhjMApbICAgIDEuNDM2MDA0XSAgWzxjMTE3Zjhi
NT5dIHN5c2ZzX2FkZF9maWxlX21vZGVfbnMrMHg5NS8weDE5MApbICAgIDEuNDM2MDA0XSAg
WzxjMTE3ZjlkNz5dIHN5c2ZzX2NyZWF0ZV9maWxlX25zKzB4MjcvMHg0MApbICAgIDEuNDM2
MDA0XSAgWzxjMTMxYzI0OT5dIGRldmljZV9jcmVhdGVfZmlsZSsweDM5LzB4YjAKWyAgICAx
LjQzNjAwNF0gIFs8YzEyYTc1NmM+XSBhY3BpX2RldmljZV9hZGQrMHgyMzgvMHgzZWEKWyAg
ICAxLjQzNjAwNF0gIFs8YzEyYTc4MmI+XSA/IGFjcGlfZnJlZV9wbnBfaWRzKzB4M2MvMHgz
YwpbICAgIDEuNDM2MDA0XSAgWzxjMTJhODA3Nj5dIGFjcGlfYWRkX3NpbmdsZV9vYmplY3Qr
MHg0YzAvMHg1MjAKWyAgICAxLjQzNjAwNF0gIFs8YzEyYTQ5MTE+XSA/IGFjcGlfZXZhbHVh
dGVfaW50ZWdlcisweDI1LzB4NGYKWyAgICAxLjQzNjAwNF0gIFs8YzEyYTQ1Mjc+XSA/IGFj
cGlfb3Nfc2lnbmFsX3NlbWFwaG9yZSsweDFlLzB4MmEKWyAgICAxLjQzNjAwNF0gIFs8YzEy
YTgxOGM+XSBhY3BpX2J1c19jaGVja19hZGQrMHhiNi8weDEzNQpbICAgIDEuNDM2MDA0XSAg
WzxjMTJiZDg2NT5dIGFjcGlfbnNfd2Fsa19uYW1lc3BhY2UrMHhhZi8weDE3MgpbICAgIDEu
NDM2MDA0XSAgWzxjMTJiZGNiZj5dIGFjcGlfd2Fsa19uYW1lc3BhY2UrMHg2ZS8weDk4Clsg
ICAgMS40MzYwMDRdICBbPGMxMmE4MGQ2Pl0gPyBhY3BpX2FkZF9zaW5nbGVfb2JqZWN0KzB4
NTIwLzB4NTIwClsgICAgMS40MzYwMDRdICBbPGMxMmE4MzhjPl0gYWNwaV9idXNfc2Nhbisw
eDM1LzB4NTQKWyAgICAxLjQzNjAwNF0gIFs8YzEyYTgwZDY+XSA/IGFjcGlfYWRkX3Npbmds
ZV9vYmplY3QrMHg1MjAvMHg1MjAKWyAgICAxLjQzNjAwNF0gIFs8YzE4ZGYxMTg+XSBhY3Bp
X3NjYW5faW5pdCsweDViLzB4MTZkClsgICAgMS40MzYwMDRdICBbPGMxOGRlZjczPl0gYWNw
aV9pbml0KzB4MjBjLzB4MjI0ClsgICAgMS40MzYwMDRdICBbPGMxOGRlZDY3Pl0gPyBhY3Bp
X3NsZWVwX2luaXQrMHhhYi8weGFiClsgICAgMS40MzYwMDRdICBbPGMxMDAwNDFlPl0gZG9f
b25lX2luaXRjYWxsKzB4N2UvMHgxYjAKWyAgICAxLjQzNjAwNF0gIFs8YzE4ZGVkNjc+XSA/
IGFjcGlfc2xlZXBfaW5pdCsweGFiLzB4YWIKWyAgICAxLjQzNjAwNF0gIFs8YzE4YjI0YmE+
XSA/IHJlcGFpcl9lbnZfc3RyaW5nKzB4MTIvMHg1NApbICAgIDEuNDM2MDA0XSAgWzxjMThi
MjRhOD5dID8gaW5pdGNhbGxfYmxhY2tsaXN0KzB4N2MvMHg3YwpbICAgIDEuNDM2MDA0XSAg
WzxjMTA1ZTEwMD5dID8gcGFyc2VfYXJncysweDE2MC8weDNmMApbICAgIDEuNDM2MDA0XSAg
WzxjMThiMmJkMT5dIGtlcm5lbF9pbml0X2ZyZWVhYmxlKzB4ZmMvMHgxNzkKWyAgICAxLjQz
NjAwNF0gIFs8YzE1Njc4MmI+XSBrZXJuZWxfaW5pdCsweGIvMHhkMApbICAgIDEuNDM2MDA0
XSAgWzxjMTU3NDYwMT5dIHJldF9mcm9tX2tlcm5lbF90aHJlYWQrMHgyMS8weDMwClsgICAg
MS40MzYwMDRdICBbPGMxNTY3ODIwPl0gPyByZXN0X2luaXQrMHhiMC8weGIwClsgICAgMS40
MzYwMDRdIENvZGU6IDAwIDAwIDhkIGJmIDAwIDAwIDAwIDAwIDU1IDMxIGM5IDg5IGU1IDU3
IDU2IDg5IGM2IDUzIDhiIDQwIDIwIDhkIDUwIDQwIDhiIDFhIDg1IGRiIDc0IDMyIDhkIDc2
IDAwIDhkIGJjIDI3IDAwIDAwIDAwIDAwIDhiIDU2IDM4IDw4Yj4gNGIgMTAgOGIgNDYgMzQg
OGIgN2UgMjQgMzkgY2EgNzQgNTAgODkgZDAgMjkgYzggODUgYzAgOGQgNTMKWyAgICAxLjQz
NjAwNF0gRUlQOiBbPGMxMTdkNmUzPl0ga2VybmZzX2xpbmtfc2libGluZysweDIzLzB4YzAg
U1M6RVNQIDAwNjg6ZDFjNGJjYzQKWyAgICAxLjQzNjAwNF0gQ1IyOiAwMDAwMDAwMDU0MjU3
MmU3ClsgICAgMS40MzYwMDRdIC0tLVsgZW5kIHRyYWNlIGFhNDUwYzE4OWI0YTg3ZTMgXS0t
LQpbICAgIDEuNDM2MDA0XSBLZXJuZWwgcGFuaWMgLSBub3Qgc3luY2luZzogRmF0YWwgZXhj
ZXB0aW9uCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy8zNmZiZmViZTc3
NmViNTg3MWQ2MWU3YTc1NWM5ZmViMWM5NmNjNGFhL2RtZXNnLXF1YW50YWwtdnAtNzoyMDE0
MDkyNjIyMDYwMjppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtMDAw
ODktZzM2ZmJmZWI6MQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvMzZm
YmZlYmU3NzZlYjU4NzFkNjFlN2E3NTVjOWZlYjFjOTZjYzRhYS9kbWVzZy15b2N0by12cC0x
OToyMDE0MDkyNjIyMDYxMDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1y
YzYtMDAwODktZzM2ZmJmZWI6MQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvMzZmYmZlYmU3NzZlYjU4NzFkNjFlN2E3NTVjOWZlYjFjOTZjYzRhYS9kbWVzZy15b2N0
by12cC0yMToyMDE0MDkyNjIyMDYwNjppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMu
MTcuMC1yYzYtMDAwODktZzM2ZmJmZWI6MQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyMzIzMDMvMzZmYmZlYmU3NzZlYjU4NzFkNjFlN2E3NTVjOWZlYjFjOTZjYzRhYS9kbWVz
Zy15b2N0by12cC0yNzoyMDE0MDkyNjIyMDYxMDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzOjMuMTcuMC1yYzYtMDAwODktZzM2ZmJmZWI6MQova2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDMvMzZmYmZlYmU3NzZlYjU4NzFkNjFlN2E3NTVjOWZlYjFjOTZjYzRh
YS9kbWVzZy15b2N0by12cC0zNDoyMDE0MDkyNjIyMDYwNTppMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzOjMuMTcuMC1yYzYtMDAwODktZzM2ZmJmZWI6MQova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMvMzZmYmZlYmU3NzZlYjU4NzFkNjFlN2E3NTVjOWZlYjFj
OTZjYzRhYS9kbWVzZy15b2N0by12cC00NToyMDE0MDkyNjIyMDYwNjppMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtMDAwODktZzM2ZmJmZWI6MQova2VybmVsL2kz
ODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvMzZmYmZlYmU3NzZlYjU4NzFkNjFlN2E3NTVj
OWZlYjFjOTZjYzRhYS9kbWVzZy1xdWFudGFsLXZwLTEzOjIwMTQwOTI2MjIwNjE5OmkzODYt
cmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi0wMDA4OS1nMzZmYmZlYjoxCi9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy8zNmZiZmViZTc3NmViNTg3MWQ2
MWU3YTc1NWM5ZmViMWM5NmNjNGFhL2RtZXNnLXlvY3RvLXZwLTIxOjIwMTQwOTI2MjIwNjE3
OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi0wMDA4OS1nMzZmYmZl
YjoxCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy8zNmZiZmViZTc3NmVi
NTg3MWQ2MWU3YTc1NWM5ZmViMWM5NmNjNGFhL2RtZXNnLXlvY3RvLXZwLTE4OjIwMTQwOTI2
MjIwNjI1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi0wMDA4OS1n
MzZmYmZlYjoxCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy8zNmZiZmVi
ZTc3NmViNTg3MWQ2MWU3YTc1NWM5ZmViMWM5NmNjNGFhL2RtZXNnLXlvY3RvLXZwLTI1OjIw
MTQwOTI2MjIwNjIyOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi0w
MDA4OS1nMzZmYmZlYjoxCjA6MTA6MTAgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKG1sx
OzM1bTIwMTQtMDktMjYgMjI6MDY6MzcgUkVQRUFUIENPVU5UOiAyMCAgIyAvYy9ib290LWJp
c2VjdC9saW51eC0xL29iai1iaXNlY3QvLnJlcGVhdBtbMG0KCkJpc2VjdGluZzogMSByZXZp
c2lvbiBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxIHN0ZXApClsxMWU1NzM4
MWVjZWQ4NzVlZjVhNmZlYTQwMDVmZGY3MmI2ZjY4ZWZmXSBtbS9zbGFiX2NvbW1vbjogY29t
bW9uaXplIHNsYWIgbWVyZ2UgbG9naWMKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0
LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4LTEvb2JqLWJpc2Vj
dApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMy9uZXh0Om1hc3RlcjoxMWU1NzM4MWVjZWQ4NzVlZjVhNmZlYTQwMDVmZGY3
MmI2ZjY4ZWZmOmJpc2VjdC1saW51eC0xCgoyMDE0LTA5LTI2IDIyOjA2OjQxIDExZTU3Mzgx
ZWNlZDg3NWVmNWE2ZmVhNDAwNWZkZjcyYjZmNjhlZmYgY29tcGlsaW5nClF1ZXVlZCBidWls
ZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMy0xMWU1NzM4MWVjZWQ4NzVlZjVhNmZlYTQwMDVmZGY3MmI2
ZjY4ZWZmCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzLzExZTU3MzgxZWNlZDg3NWVmNWE2ZmVhNDAwNWZkZjcyYjZmNjhlZmYKd2Fp
dGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1p
YjAzLXNtb2tlL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMtMTFlNTczODFlY2VkODc1
ZWY1YTZmZWE0MDA1ZmRmNzJiNmY2OGVmZgprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy8xMWU1NzM4MWVjZWQ4NzVlZjVhNmZlYTQwMDVmZGY3MmI2ZjY4
ZWZmL3ZtbGludXotMy4xNy4wLXJjNi0wMDA4Ny1nMTFlNTczOAoKMjAxNC0wOS0yNiAyMjow
OTo0MSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4JNAk1Lgk3CTguLgk5Li4uLgkxNAkxNy4J
MjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAwIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIg
dGhpcyAocm91Z2hseSAwIHN0ZXBzKQpbOGMwODc0ODliOGEzMmI5MjM1ZjdmOTQxNzM5MGM2
MmQ5M2FiYTUyMl0gbW0vc2xhYl9jb21tb246IGZpeCBidWlsZCBmYWlsdXJlIGlmIENPTkZJ
R19TTFVCCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVy
ZS5zaCAvYy9ib290LWJpc2VjdC9saW51eC0xL29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10
ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvbmV4dDpt
YXN0ZXI6OGMwODc0ODliOGEzMmI5MjM1ZjdmOTQxNzM5MGM2MmQ5M2FiYTUyMjpiaXNlY3Qt
bGludXgtMQoKMjAxNC0wOS0yNiAyMjoxOToxMiA4YzA4NzQ4OWI4YTMyYjkyMzVmN2Y5NDE3
MzkwYzYyZDkzYWJhNTIyIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxk
LXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMtOGMwODc0ODliOGEzMmI5MjM1ZjdmOTQxNzM5MGM2MmQ5M2FiYTUyMgpDaGVjayBmb3Ig
a2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy84YzA4NzQ4
OWI4YTMyYjkyMzVmN2Y5NDE3MzkwYzYyZDkzYWJhNTIyCndhaXRpbmcgZm9yIGNvbXBsZXRp
b24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzLThjMDg3NDg5YjhhMzJiOTIzNWY3Zjk0MTczOTBjNjJkOTNhYmE1
MjIKG1sxOzM1bTIwMTQtMDktMjYgMjI6MjE6MTIgTm8gYnVpbGQgc2VydmVkIGZpbGUgL2ti
dWlsZC10ZXN0cy9idWlsZC1zZXJ2ZWQvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy04
YzA4NzQ4OWI4YTMyYjkyMzVmN2Y5NDE3MzkwYzYyZDkzYWJhNTIyG1swbQpSZXRyeSBidWls
ZCAuLgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUvbGtwLWliMDMtc21va2UvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy04YzA4NzQ4
OWI4YTMyYjkyMzVmN2Y5NDE3MzkwYzYyZDkzYWJhNTIyCmtlcm5lbDogL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzhjMDg3NDg5YjhhMzJiOTIzNWY3Zjk0MTczOTBj
NjJkOTNhYmE1MjIvdm1saW51ei0zLjE3LjAtcmM2LTAwMDg4LWc4YzA4NzQ4CgoyMDE0LTA5
LTI2IDIyOjIzOjEyIGRldGVjdGluZyBib290IHN0YXRlIC4JOQkyMCBTVUNDRVNTCgozNmZi
ZmViZTc3NmViNTg3MWQ2MWU3YTc1NWM5ZmViMWM5NmNjNGFhIGlzIHRoZSBmaXJzdCBiYWQg
Y29tbWl0CmNvbW1pdCAzNmZiZmViZTc3NmViNTg3MWQ2MWU3YTc1NWM5ZmViMWM5NmNjNGFh
CkF1dGhvcjogSm9vbnNvbyBLaW0gPGlhbWpvb25zb28ua2ltQGxnZS5jb20+CkRhdGU6ICAg
VHVlIFNlcCAyMyAxMTo1MjozNSAyMDE0ICsxMDAwCgogICAgbW0vc2xhYjogc3VwcG9ydCBz
bGFiIG1lcmdlCiAgICAKICAgIFNsYWIgbWVyZ2UgaXMgZ29vZCBmZWF0dXJlIHRvIHJlZHVj
ZSBmcmFnbWVudGF0aW9uLiAgSWYgbmV3IGNyZWF0aW5nIHNsYWIKICAgIGhhdmUgc2ltaWxh
ciBzaXplIGFuZCBwcm9wZXJ0eSB3aXRoIGV4c2l0ZW50IHNsYWIsIHRoaXMgZmVhdHVyZSBy
ZXVzZSBpdAogICAgcmF0aGVyIHRoYW4gY3JlYXRpbmcgbmV3IG9uZS4gIEFzIGEgcmVzdWx0
LCBvYmplY3RzIGFyZSBwYWNrZWQgaW50byBmZXdlcgogICAgc2xhYnMgc28gdGhhdCBmcmFn
bWVudGF0aW9uIGlzIHJlZHVjZWQuCiAgICAKICAgIEJlbG93IGlzIHJlc3VsdCBvZiBteSB0
ZXN0aW5nLgogICAgCiAgICAqIEFmdGVyIGJvb3QsIHNsZWVwIDIwOyBjYXQgL3Byb2MvbWVt
aW5mbyB8IGdyZXAgU2xhYgogICAgCiAgICA8QmVmb3JlPgogICAgU2xhYjogMjUxMzYga0IK
ICAgIAogICAgPEFmdGVyPgogICAgU2xhYjogMjQzNjQga0IKICAgIAogICAgV2UgY2FuIHNh
dmUgMyUgbWVtb3J5IHVzZWQgYnkgc2xhYi4KICAgIAogICAgRm9yIHN1cHBvcnRpbmcgdGhp
cyBmZWF0dXJlIGluIFNMQUIsIHdlIG5lZWQgdG8gaW1wbGVtZW50IFNMQUIgc3BlY2lmaWMK
ICAgIGttZW1fY2FjaGVfZmxhZygpIGFuZCBfX2ttZW1fY2FjaGVfYWxpYXMoKSwgYmVjYXVz
ZSBTTFVCIGltcGxlbWVudHMgc29tZQogICAgU0xVQiBzcGVjaWZpYyBwcm9jZXNzaW5nIHJl
bGF0ZWQgdG8gZGVidWcgZmxhZyBhbmQgb2JqZWN0IHNpemUgY2hhbmdlIG9uCiAgICB0aGVz
ZSBmdW5jdGlvbnMuCiAgICAKICAgIFNpZ25lZC1vZmYtYnk6IEpvb25zb28gS2ltIDxpYW1q
b29uc29vLmtpbUBsZ2UuY29tPgogICAgQ2M6IENocmlzdG9waCBMYW1ldGVyIDxjbEBsaW51
eC5jb20+CiAgICBDYzogUGVra2EgRW5iZXJnIDxwZW5iZXJnQGtlcm5lbC5vcmc+CiAgICBD
YzogRGF2aWQgUmllbnRqZXMgPHJpZW50amVzQGdvb2dsZS5jb20+CiAgICBTaWduZWQtb2Zm
LWJ5OiBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPgoKOjA0MDAw
MCAwNDAwMDAgYjdhNWFlN2ExNmU2M2Y5OTI5YWEyNmQwNzY0YWM3YmNhNzBhNzZkYyBhZmMz
MzZlNDBhYWI1MmU5ZTVjMjE0ZWRmMmI1YTA0ZjNlMjc5ZjBjIE0JbW0KYmlzZWN0IHJ1biBz
dWNjZXNzCkhFQUQgaXMgbm93IGF0IDhjMDg3NDguLi4gbW0vc2xhYl9jb21tb246IGZpeCBi
dWlsZCBmYWlsdXJlIGlmIENPTkZJR19TTFVCCmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1
ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzL25leHQ6bWFzdGVyOjhjMDg3
NDg5YjhhMzJiOTIzNWY3Zjk0MTczOTBjNjJkOTNhYmE1MjI6YmlzZWN0LWxpbnV4LTEKCjIw
MTQtMDktMjYgMjI6MjQ6NDIgOGMwODc0ODliOGEzMmI5MjM1ZjdmOTQxNzM5MGM2MmQ5M2Fi
YTUyMiByZXVzZSAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvOGMwODc0
ODliOGEzMmI5MjM1ZjdmOTQxNzM5MGM2MmQ5M2FiYTUyMi92bWxpbnV6LTMuMTcuMC1yYzYt
MDAwODgtZzhjMDg3NDgKCjIwMTQtMDktMjYgMjI6MjQ6NDIgZGV0ZWN0aW5nIGJvb3Qgc3Rh
dGUgLi4JNjAgU1VDQ0VTUwoKUHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgOGMwODc0OC4u
LiBtbS9zbGFiX2NvbW1vbjogZml4IGJ1aWxkIGZhaWx1cmUgaWYgQ09ORklHX1NMVUIKSEVB
RCBpcyBub3cgYXQgNTVmMjEzMC4uLiBBZGQgbGludXgtbmV4dCBzcGVjaWZpYyBmaWxlcyBm
b3IgMjAxNDA5MjMKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMvbmV4dDptYXN0ZXI6NTVmMjEzMDY5MDBhYmY5ZjlkMmEw
ODdhMTI3ZmY0OWM2ZDM4OGFkMjpiaXNlY3QtbGludXgtMQogVEVTVCBGQUlMVVJFClsgICAg
Mi4yMDIxNjhdIEFDUEk6IFBvd2VyIEJ1dHRvbiBbUFdSRl0KWyAgICAyLjIwMzEwOV0gaXNh
cG5wOiBTY2FubmluZyBmb3IgUG5QIGNhcmRzLi4uClsgICAgMi41NjAzNTddIGlzYXBucDog
Tm8gUGx1ZyAmIFBsYXkgZGV2aWNlIGZvdW5kClsgICAgMi41NjUyMTNdIEJVRzogdW5hYmxl
IHRvIGhhbmRsZSBrZXJuZWwgcGFnaW5nIHJlcXVlc3QgYXQgMTFlYzAwMWYKWyAgICAyLjU2
NjA3OV0gSVA6IFs8YzExODA5Zjk+XSBrZXJuZnNfYWRkX29uZSsweDg5LzB4MTMwClsgICAg
Mi41NjY3NDFdICpwZHB0ID0gMDAwMDAwMDAwMDAwMDAwMCAqcGRlID0gMDAwMDAwMGEwMDAw
MDAxNCAKWyAgICAyLjU2NzQ3OV0gT29wczogMDAwMiBbIzFdIFNNUCAKWyAgICAyLjU2ODAw
OF0gTW9kdWxlcyBsaW5rZWQgaW46ClsgICAgMi41NjgwMDhdIENQVTogMCBQSUQ6IDEgQ29t
bTogc3dhcHBlci8wIE5vdCB0YWludGVkIDMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMyAjODAy
ClsgICAgMi41NjgwMDhdIEhhcmR3YXJlIG5hbWU6IFFFTVUgU3RhbmRhcmQgUEMgKGk0NDBG
WCArIFBJSVgsIDE5OTYpLCBCSU9TIDEuNy41LTIwMTQwNTMxXzA4MzAzMC1nYW5kYWxmIDA0
LzAxLzIwMTQKWyAgICAyLjU2ODAwOF0gdGFzazogZDFjNDRjOTAgdGk6IGQxYzQ2MDAwIHRh
c2sudGk6IGQxYzQ2MDAwClsgICAgMi41NjgwMDhdIEVJUDogMDA2MDpbPGMxMTgwOWY5Pl0g
RUZMQUdTOiAwMDAxMDI4NiBDUFU6IDAKWyAgICAyLjU2ODAwOF0gRUlQIGlzIGF0IGtlcm5m
c19hZGRfb25lKzB4ODkvMHgxMzAKWyAgICAyLjU3MjAyMl0gRUFYOiA1NDIxOTcyYyBFQlg6
IDExZWJmZmZmIEVDWDogMDAwMDAwMTcgRURYOiAxYTEwOTgwYgpbICAgIDIuNTcyMDIyXSBF
U0k6IGMwMDEyZDUwIEVESTogYzAwMTJkYjAgRUJQOiBkMWM0N2Q4MCBFU1A6IGQxYzQ3ZDVj
ClsgICAgMi41NzIwMjJdICBEUzogMDA3YiBFUzogMDA3YiBGUzogMDBkOCBHUzogMDAwMCBT
UzogMDA2OApbICAgIDIuNTcyMDIyXSBDUjA6IDgwMDUwMDNiIENSMjogMTFlYzAwMWYgQ1Iz
OiAwMWE5MjAwMCBDUjQ6IDAwMDAwNmYwClsgICAgMi41NzIwMjJdIFN0YWNrOgpbICAgIDIu
NTcyMDIyXSAgZDFjMDZmMDAgMDAwMDAyMDIgYzAwMTJkYjAgYzAwMTJkNTAgZDFjNDdkODAg
YzExODA4YTAgYzAwMTJkNTAgYzE1YTA2ODAKWyAgICAyLjU3MjAyMl0gIGMxODdkYTZjIGQx
YzQ3ZDk4IGMxMTgxZGYyIDAwMDAwMDAwIGMxODdkYTYwIGMwMDEyZGIwIDAwMDAwMDAwIGQx
YzQ3ZGQ0ClsgICAgMi41NzIwMjJdICBjMTE4MjViNSAwMDAwMTAwMCAwMDAwMDAwMCBjMTVh
MDY4MCBjMTg3ZGE2MCAwMDAwMDAwMCAwMDAwMDAwMSBjMTg3ZGE2YwpbICAgIDIuNTcyMDIy
XSBDYWxsIFRyYWNlOgpbICAgIDIuNTcyMDIyXSAgWzxjMTE4MDhhMD5dID8ga2VybmZzX25l
d19ub2RlKzB4MzAvMHg0MApbICAgIDIuNTgwMDEwXSAgWzxjMTE4MWRmMj5dIF9fa2VybmZz
X2NyZWF0ZV9maWxlKzB4OTIvMHhjMApbICAgIDIuNTgwMDEwXSAgWzxjMTE4MjViNT5dIHN5
c2ZzX2FkZF9maWxlX21vZGVfbnMrMHg5NS8weDE5MApbICAgIDIuNTgwMDEwXSAgWzxjMTE4
Mjg0ZT5dIHN5c2ZzX2FkZF9maWxlKzB4MWUvMHgzMApbICAgIDIuNTgwMDEwXSAgWzxjMTE4
MmVjYT5dIHN5c2ZzX21lcmdlX2dyb3VwKzB4NGEvMHhjMApbICAgIDIuNTgwMDEwXSAgWzxj
MTMyOWM5Yz5dIGRwbV9zeXNmc19hZGQrMHg1Yy8weGIwClsgICAgMi41ODAwMTBdICBbPGMx
MzIyZWY2Pl0gZGV2aWNlX2FkZCsweDQ0Ni8weDU4MApbICAgIDIuNTgwMDEwXSAgWzxjMTMy
MzA0Mj5dIGRldmljZV9yZWdpc3RlcisweDEyLzB4MjAKWyAgICAyLjU4MDAxMF0gIFs8YzEy
ZTQwZDY+XSB0dHlfcmVnaXN0ZXJfZGV2aWNlX2F0dHIrMHhiNi8weDI4MApbICAgIDIuNTgw
MDEwXSAgWzxjMTU3N2ViOD5dID8gbXV0ZXhfdW5sb2NrKzB4OC8weDEwClsgICAgMi41ODAw
MTBdICBbPGMxMTIxMzMzPl0gPyBjZGV2X2FkZCsweDQzLzB4NTAKWyAgICAyLjU4MDAxMF0g
IFs8YzEyZTQzYjY+XSB0dHlfcmVnaXN0ZXJfZHJpdmVyKzB4ZjYvMHgxYjAKWyAgICAyLjU4
MDAxMF0gIFs8YzE4ZWIwMGE+XSBwdHlfaW5pdCsweDEyZS8weDMyOQpbICAgIDIuNTgwMDEw
XSAgWzxjMThlYWVkYz5dID8gdHR5X2luaXQrMHgxMTAvMHgxMTAKWyAgICAyLjU4MDAxMF0g
IFs8YzEwMDA0MWU+XSBkb19vbmVfaW5pdGNhbGwrMHg3ZS8weDFiMApbICAgIDIuNTgwMDEw
XSAgWzxjMThlYWVkYz5dID8gdHR5X2luaXQrMHgxMTAvMHgxMTAKWyAgICAyLjU4ODAxMV0g
IFs8YzE4YmE0YmE+XSA/IHJlcGFpcl9lbnZfc3RyaW5nKzB4MTIvMHg1NApbICAgIDIuNTg4
MDExXSAgWzxjMThiYTRhOD5dID8gaW5pdGNhbGxfYmxhY2tsaXN0KzB4N2MvMHg3YwpbICAg
IDIuNTg4MDExXSAgWzxjMTA1ZTkwMD5dID8gcGFyc2VfYXJncysweDFhMC8weDQyMApbICAg
IDIuNTg4MDExXSAgWzxjMThiYWJlMD5dIGtlcm5lbF9pbml0X2ZyZWVhYmxlKzB4ZmMvMHgx
NzkKWyAgICAyLjU4ODAxMV0gIFs8YzE1NmUzMWI+XSBrZXJuZWxfaW5pdCsweGIvMHhkMApb
ICAgIDIuNTg4MDExXSAgWzxjMTU3YjBjMT5dIHJldF9mcm9tX2tlcm5lbF90aHJlYWQrMHgy
MS8weDMwClsgICAgMi41ODgwMTFdICBbPGMxNTZlMzEwPl0gPyByZXN0X2luaXQrMHhiMC8w
eGIwClsgICAgMi41ODgwMTFdIENvZGU6IDI2IDAwIDgzIGUxIDEwIDc1IDViIDhiIDQ2IDI0
IGU4IGMzIGVhIGZmIGZmIDg5IDQ2IDM4IDg5IGYwIGU4IGQ5IGY5IGZmIGZmIDg1IGMwIDg5
IGMzIDc1IGNhIDhiIDVmIDVjIDg1IGRiIDc0IDExIGU4IDg3IDc4IGYxIGZmIDw4OT4gNDMg
MjAgODkgNTMgMjQgODkgNDMgMjggODkgNTMgMmMgYjggMDAgYWYgODUgYzEgZTggYTEgNzQg
M2YKWyAgICAyLjU4ODAxMV0gRUlQOiBbPGMxMTgwOWY5Pl0ga2VybmZzX2FkZF9vbmUrMHg4
OS8weDEzMCBTUzpFU1AgMDA2ODpkMWM0N2Q1YwpbICAgIDIuNTg4MDExXSBDUjI6IDAwMDAw
MDAwMTFlYzAwMWYKWyAgICAyLjU4ODAxMV0gLS0tWyBlbmQgdHJhY2UgODRlMzMxYzY4Njhh
ODcxZiBdLS0tClsgICAgMi41ODgwMTFdIEtlcm5lbCBwYW5pYyAtIG5vdCBzeW5jaW5nOiBG
YXRhbCBleGNlcHRpb24KL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1
ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZi
NDEtMjA6MjAxNDA5MjMyMzQ1MDM6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQy
YTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWtidWlsZC0yNjoyMDE0MDkyMzIz
NDgzMTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0
MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2
OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC12cC0xODoy
MDE0MDkyMzIzMzkzOTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYt
bmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
LzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRh
bC1pdmI0MS0yOToyMDE0MDkyMzIzNTMzNjppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
OjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJm
OWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMTA3OjIwMTQw
OTIzMjM1MDM3OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYt
cmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0
OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1rYnVpbGQtMjQ6MjAxNDA5MjMyMzUyMjk6aTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQy
YTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtNjM6MjAxNDA5MjMy
MzQzMDQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZk
Mzg4YWQyL2RtZXNnLXZtLXZwLXF1YW50YWwtaTM4Ni0xODoyMDE0MDkyMzIzMTgwMDppMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIK
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5
ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtNjoyMDE0MDkyMzIz
NDQwNTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRj
b25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQz
ODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMTAyOjIwMTQwOTIzMjM0NzM1OmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0
by1rYnVpbGQtNzoyMDE0MDkyMzIzMzAzODppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
OjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2cteW9jdG8taXZiNDEtOTM6MjAxNDA5MjMyMzQ4NDU6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYy
MTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQx
LTY4OjIwMTQwOTIzMjM0NzM1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEw
ODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1rYnVpbGQtMzoyMDE0MDkyMzIzNTIy
OTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDky
Mzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAw
YWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtNzoyMDE0
MDkyMzIzNDQwNzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2Zm
NDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtNzg6MjAxNDA5MjMyMzQ2MzU6aTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNn
LXF1YW50YWwtaXZiNDEtNjQ6MjAxNDA5MjMyMzUzMzY6aTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMw
NjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTU0
OjIwMTQwOTIzMjM0OTQ1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVs
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdh
MTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1rYnVpbGQtMTM6MjAxNDA5MjMyMzI1MzY6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6
ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFi
ZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtdnAtMTc6MjAxNDA5
MjMyMzM5NDA6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQt
MjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYy
MTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLXZwLTU5
OjIwMTQwOTIzMjM1MTM3OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJj
Ni1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFu
dGFsLXZwLTMwOjIwMTQwOTIzMjMyMTE1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6
My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9k
bWVzZy1xdWFudGFsLWl2YjQxLTE0OjIwMTQwOTIzMjM1MzM2OmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVm
MjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2
YjQxLTQxOjIwMTQwOTIzMjM0MTA0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5Zjlk
MmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTM6MjAxNDA5MjMy
MzQxMDQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZk
Mzg4YWQyL2RtZXNnLXlvY3RvLXZwLTQ1OjIwMTQwOTIzMjM1MTM2OmkzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kz
ODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3
ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0zNToyMDE0MDkyMzIzNDUwMzppMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1l
c2ctcXVhbnRhbC1pdmI0MS03ODoyMDE0MDkyMzIzNTIxNjppMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIx
MzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC12cC0y
NDoyMDE0MDkyMzIzMjAxMjppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1y
YzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVh
bnRhbC1pdmI0MS0xMTg6MjAxNDA5MjMyMzUyMTY6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkw
MGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMTI1
OjIwMTQwOTIzMjM1MTE3OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVs
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdh
MTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS01NjoyMDE0MDkyMzIzNDczNTpp
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2ctcXVhbnRhbC1pdmI0MS0zOjIwMTQwOTIzMjM0MDM0OmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVm
MjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0
MS01OjIwMTQwOTIzMjM0NTAzOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEw
ODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS05NzoyMDE0MDkyMzIzNDg0
NDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhh
ZDIvZG1lc2cteW9jdG8taXZiNDEtNDoyMDE0MDkyMzIzNDYzNDppMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1
ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8ta2J1
aWxkLTI6MjAxNDA5MjMyMzQ4NTQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3
LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNn
LXlvY3RvLWl2YjQxLTQxOjIwMTQwOTIzMjM0NjA1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5
MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTU4
OjIwMTQwOTIzMjM0MjAzOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVs
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdh
MTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0xMjA6MjAxNDA5MjMyMzQ4MDU6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQy
L2RtZXNnLXlvY3RvLWl2YjQxLTU0OjIwMTQwOTIzMjM0ODQ0OmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVm
MjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1rYnVp
bGQtMTQ6MjAxNDA5MjMyMzQyNTA6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3
LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNn
LXF1YW50YWwtaXZiNDEtNjE6MjAxNDA5MjMyMzQyMDQ6aTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMw
NjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtdnAtMjA6
MjAxNDA5MjMyMzIzMjI6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2
LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
My81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50
YWwta2J1aWxkLTE4OjIwMTQwOTIzMjMyMDU1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFk
Mi9kbWVzZy15b2N0by1pdmI0MS00NjoyMDE0MDkyMzIzNDcwNjppMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1
ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1p
dmI0MS00ODoyMDE0MDkyMzIzNDMzNDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoK
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5
ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS0zMToyMDE0MDky
MzIzNDEwNDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDlj
NmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMTU6MjAxNDA5MjMyMzQ1MDM6aTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1
YW50YWwtaXZiNDEtNTg6MjAxNDA5MjMyMzQzMDQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkw
MGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtNjg6
MjAxNDA5MjMyMzQzMzQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2Ex
MjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMjE6MjAxNDA5MjMyMzQxMDU6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQy
L2RtZXNnLXlvY3RvLWl2YjQxLTEyNToyMDE0MDkyMzIzNDg0NTppMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1
ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1p
dmI0MS0xNzoyMDE0MDkyMzIzNTExNjppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoK
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5
ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS01ODoyMDE0MDky
MzIzNDEzMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDlj
NmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS00MToyMDE0MDkyMzIzNDEzNDppMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ct
cXVhbnRhbC1pdmI0MS0xMTY6MjAxNDA5MjMyMzQzMzQ6aTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMw
NjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTEw
OjIwMTQwOTIzMjM1MDM3OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVs
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdh
MTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTE6MjAxNDA5MjMyMzUzMDY6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQy
L2RtZXNnLXlvY3RvLWl2YjQxLTczOjIwMTQwOTIzMjM0NjM1OmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVm
MjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2
YjQxLTgxOjIwMTQwOTIzMjM0MjM0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5Zjlk
MmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS01NDoyMDE0MDkyMzIz
NTAzNTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRj
b25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQz
ODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS0xMDQ6MjAxNDA5MjMyMzUzMDY6aTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1
YW50YWwtdnAtMTc6MjAxNDA5MjMyMzU1MDE6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
MzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQy
L2RtZXNnLXlvY3RvLWl2YjQxLTU1OjIwMTQwOTIzMjM0NjAzOmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVm
MjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0
MS0xMDI6MjAxNDA5MjMyMzQ4MDU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQy
YTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLXZwLTYzOjIwMTQwOTIzMjMyNjM4
OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIz
OjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBh
YmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0yMToyMDE0
MDkyMzIzNTAwNzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2Zm
NDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS0xMTQ6MjAxNDA5MjMyMzUzMzY6aTM4
Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2Rt
ZXNnLXlvY3RvLWl2YjQxLTEyNToyMDE0MDkyMzIzNDgwNDppMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIx
MzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEt
NTY6MjAxNDA5MjMyMzQ2MDU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4
N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLXZwLTI4OjIwMTQwOTIzMjMxNjUzOmkz
ODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgw
Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5
ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by12cC0zNDoyMDE0MDkyMzIz
MTY1MTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0
MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2
OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMToy
MDE0MDkyMzIzNDQwNTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEy
N2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS0yODoyMDE0MDkyMzIzNDAzMzpp
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2cteW9jdG8taXZiNDEtMTA6MjAxNDA5MjMyMzQ0MTM6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYy
MTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWtidWls
ZC0xNzoyMDE0MDkyMzIzNDgzMTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcu
MC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ct
eW9jdG8ta2J1aWxkLTU6MjAxNDA5MjMyMzQwMTk6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4
YWQyL2RtZXNnLXlvY3RvLWtidWlsZC0xMDoyMDE0MDkyMzIzNDAxOTppMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEy
N2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS03NjoyMDE0MDkyMzIzNDIzNDpp
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2cteW9jdG8tdnAtNjM6MjAxNDA5MjMyMzE2NTY6aTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZk
Mzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTcxOjIwMTQwOTIzMjM0OTQ0OmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0
by1pdmI0MS0xNToyMDE0MDkyMzIzNDQzODppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
OjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJm
OWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS03MToyMDE0
MDkyMzIzNDIwNDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2Zm
NDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMzA6MjAxNDA5MjMyMzQ4MDc6aTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNn
LXlvY3RvLWl2YjQxLTk1OjIwMTQwOTIzMjM0NzA2OmkzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5
MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTE6
MjAxNDA5MjMyMzQxMzQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2Ex
MjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTMzOjIwMTQwOTIzMjM0NTM0Omkz
ODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9k
bWVzZy1xdWFudGFsLWl2YjQxLTk0OjIwMTQwOTIzMjM1MzA2OmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVm
MjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2
YjQxLTg4OjIwMTQwOTIzMjM0MzAzOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5Zjlk
MmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTQzOjIwMTQwOTIz
MjM0MTAzOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2
ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0yNjoyMDE0MDkyMzIzNDk0NDppMzg2LXJhbmRj
b25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVh
bnRhbC1sa3AtbmV4MDQtODU6MjAxNDA5MjYxNzUwMTI6aTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMw
NjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEt
MTk6MjAxNDA5MjMyMzUyMTY6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4
N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLXZwLTQ0OjIwMTQwOTIzMjM1NTAxOmkz
ODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgw
Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5
ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0yMDoyMDE0MDky
MzIzNDQzMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDlj
NmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS0zODoyMDE0MDkyMzIzNTMzNjppMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ct
cXVhbnRhbC1pdmI0MS00MzoyMDE0MDkyMzIzNDEzMzppMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2
OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS01
OToyMDE0MDkyMzIzNTMwNjppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3
YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS01NjoyMDE0MDkyMzIzNDEz
NDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhh
ZDIvZG1lc2cteW9jdG8tdnAtMzoyMDE0MDkyMzIzNDQwMjppMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDlj
NmQzODhhZDIvZG1lc2cteW9jdG8tdnAtNTE6MjAxNDA5MjMyMzU0NTk6aTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2Ex
MjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTIxOjIwMTQwOTIzMjM1MDM3Omkz
ODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9k
bWVzZy15b2N0by1pdmI0MS0xMDc6MjAxNDA5MjMyMzQ4NDY6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYy
MTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWtidWls
ZC0yOjIwMTQwOTIzMjM0ODI1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4w
LXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1x
dWFudGFsLWl2YjQxLTg2OjIwMTQwOTIzMjM0MjM0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5
MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTEw
OjIwMTQwOTIzMjM0MTM1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVs
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdh
MTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0zMDoyMDE0MDkyMzIzNDYzNDpp
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2cteW9jdG8taXZiNDEtNzE6MjAxNDA5MjMyMzUwMzU6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYy
MTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQx
LTgxOjIwMTQwOTIzMjM1MDA2OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEw
ODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTExOjIwMTQwOTIzMjM0
MDM0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4
OGFkMi9kbWVzZy15b2N0by12cC0xOjIwMTQwOTIzMjM0NTA0OmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYt
cmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0
OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTIxOjIwMTQwOTIzMjM0MDM0OmkzODYt
cmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVz
Zy15b2N0by1pdmI0MS0zNzoyMDE0MDkyMzIzNDgwNzppMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2
OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS02
ODoyMDE0MDkyMzIzNDMwMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3
YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1rYnVpbGQtMjM6MjAxNDA5MjMyMzM1
MDU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5
MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkw
MGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMTE6
MjAxNDA5MjMyMzQxMDU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2Ex
MjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtOTg6MjAxNDA5MjMyMzUyMTY6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQy
L2RtZXNnLXF1YW50YWwtaXZiNDEtNDM6MjAxNDA5MjMyMzQyMDM6aTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81
NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwt
aXZiNDEtNDg6MjAxNDA5MjMyMzQzMDM6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6
Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlm
OWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTEwMDoyMDE0MDky
MzIzNTAwNzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDlj
NmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMjM6MjAxNDA5MjMyMzUwMzc6aTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlv
Y3RvLWl2YjQxLTkwOjIwMTQwOTIzMjM0NzM2OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBh
YmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWxrcC1uZXgwNC0z
ODoyMDE0MDkyNjE3NTAxMjppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3
YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtOToyMDE0MDkyMzIzNDUzMzpp
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2cteW9jdG8tdnAtMTk6MjAxNDA5MjMyMzI3NDI6aTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZk
Mzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTkyOjIwMTQwOTIzMjM1MDA2OmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFu
dGFsLWl2YjQxLTIzOjIwMTQwOTIzMjM1MzM2OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBh
YmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0zNjoyMDE0
MDkyMzIzNDUwNTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2Zm
NDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS0xMDM6MjAxNDA5MjMyMzUyMTY6aTM4
Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2Rt
ZXNnLXlvY3RvLXZwLTEwOjIwMTQwOTI2MTc1MDA1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4
OGFkMi9kbWVzZy15b2N0by1rYnVpbGQtNjoyMDE0MDkyNjE3NDY0ODppMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEy
N2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8tdnAtMjE6MjAxNDA5MjMyMzIxMTc6aTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQy
YTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMjg6MjAxNDA5MjMy
MzUzMzY6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZk
Mzg4YWQyL2RtZXNnLXlvY3RvLWtidWlsZC01OjIwMTQwOTIzMjMzMjM1OmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVs
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdh
MTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTUzOjIwMTQwOTIzMjM0MzA0
OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFk
Mi9kbWVzZy15b2N0by1pdmI0MS0xMDA6MjAxNDA5MjMyMzQ4NDY6aTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81
NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwt
dnAtMTI6MjAxNDA5MjMyMzU1MDA6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3
LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNn
LXF1YW50YWwtaXZiNDEtNDg6MjAxNDA5MjMyMzUxMTc6aTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMw
NjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEt
NzM6MjAxNDA5MjMyMzQyMzM6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4
N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTI4OjIwMTQwOTIzMjM0NTM0
OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFk
Mi9kbWVzZy15b2N0by1pdmI0MS0zMDoyMDE0MDkyMzIzNDYwNDppMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1
ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8tdnAt
Mzk6MjAxNDA5MjMyMzUxMzg6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAt
cmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlv
Y3RvLWl2YjQxLTg1OjIwMTQwOTIzMjM0NzM2OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBh
YmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by12cC02MjoyMDE0MDky
MzIzMjc0MjppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0y
MDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIx
MzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEt
NTU6MjAxNDA5MjMyMzQ3MzU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4
N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtNTE6MjAxNDA5MjMyMzQx
MzQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4
YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMTE4OjIwMTQwOTIzMjM0MzMzOmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0
by1pdmI0MS05MToyMDE0MDkyMzIzNDgwNzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
OjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJm
OWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC12cC0yNDoyMDE0MDky
MzIzNTUwMTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0y
MDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIx
MzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8ta2J1aWxk
LTE6MjAxNDA5MjYxNzQ3MjQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAt
cmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1
YW50YWwtaXZiNDEtODM6MjAxNDA5MjMyMzUzMzY6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkw
MGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTg6MjAx
NDA5MjMyMzQ1MDQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4
Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdm
ZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTEyMDoyMDE0MDkyMzIzNDg0NTppMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1l
c2cteW9jdG8taXZiNDEtNTY6MjAxNDA5MjMyMzQ3MDc6aTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMw
NjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLXZwLTEzOjIw
MTQwOTIzMjMxNjUyOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1u
ZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMv
NTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1p
dmI0MS0xMTU6MjAxNDA5MjMyMzQ4NDU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6
Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlm
OWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtNDM6MjAxNDA5
MjMyMzQyMzQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5
YzZkMzg4YWQyL2RtZXNnLXlvY3RvLXZwLTMyOjIwMTQwOTIzMjMzNTE5OmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVs
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdh
MTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS02ODoyMDE0MDkyMzIzNDcwODpp
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2cteW9jdG8taXZiNDEtODA6MjAxNDA5MjMyMzQ3MzY6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYy
MTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWtidWls
ZC0xMToyMDE0MDkyMzIzMTQzMTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcu
MC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ct
cXVhbnRhbC1pdmI0MS02NDoyMDE0MDkyMzIzNTMwNjppMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2
OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS02
MzoyMDE0MDkyMzIzNDIzMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3
YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtNzQ6MjAxNDA5MjMyMzQ3MDc6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQy
L2RtZXNnLXlvY3RvLXZwLTMyOjIwMTQwOTI2MTc1MDA3OmkzODYtcmFuZGNvbmZpZy1pYjEt
MDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2
ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS01OjIwMTQwOTIzMjM0NDAzOmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0
by1pdmI0MS0zMDoyMDE0MDkyMzIzNDUzMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
OjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJm
OWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS03MzoyMDE0
MDkyMzIzNDMwNDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2Zm
NDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMToyMDE0MDkyMzIzNDQzNTppMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ct
eW9jdG8tdnAtNTU6MjAxNDA5MjYxNzUwMDg6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
MzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQy
L2RtZXNnLXF1YW50YWwtaXZiNDEtNTg6MjAxNDA5MjMyMzQyMzM6aTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81
NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLXZw
LTQ6MjAxNDA5MjMyMzUxMzY6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAt
cmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlv
Y3RvLWl2YjQxLTQ4OjIwMTQwOTIzMjM0NTM0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBh
YmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0xMjE6MjAx
NDA5MjMyMzQ4MDc6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4
Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdm
ZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTY1OjIwMTQwOTIzMjM0NjAzOmkzODYt
cmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVz
Zy1xdWFudGFsLWl2YjQxLTEwNjoyMDE0MDkyMzIzNDMzNDppMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIx
MzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEt
ODA6MjAxNDA5MjMyMzQ2MzM6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4
N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMTk6MjAxNDA5MjMyMzQw
MzU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4
YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMTY6MjAxNDA5MjMyMzQxMDQ6aTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
My81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50
YWwtaXZiNDEtMzY6MjAxNDA5MjMyMzQxMzQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
Mzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFi
ZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMjQ6MjAx
NDA5MjMyMzQwMzU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4
Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdm
ZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLXZwLTYwOjIwMTQwOTIzMjM1MTM3OmkzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEw
ODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTExMzoyMDE0MDkyMzIz
NDMzNDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRj
b25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQz
ODhhZDIvZG1lc2cteW9jdG8ta2J1aWxkLTEwOjIwMTQwOTIzMjMzMzMxOmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVs
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdh
MTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0yODoyMDE0MDkyMzIzNDUwNDpp
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2ctcXVhbnRhbC1pdmI0MS03OToyMDE0MDkyMzIzNTMzNjppMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1
ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZi
NDEtMzc6MjAxNDA5MjMyMzQ2MzQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQy
YTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTk3OjIwMTQwOTIzMjM0
OTQ1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4
OGFkMi9kbWVzZy15b2N0by1pdmI0MS01OjIwMTQwOTIzMjM0NDEzOmkzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMv
NTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1p
dmI0MS04ODoyMDE0MDkyMzIzNDcwNzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoK
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5
ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8ta2J1aWxkLTI1OjIwMTQwOTIz
MjMzNzE0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIw
MTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEz
MDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1rYnVpbGQt
MTQ6MjAxNDA5MjMyMzQ4MzE6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAt
cmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1
YW50YWwtaXZiNDEtMTIzOjIwMTQwOTIzMjM1MjE2OmkzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5
MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1rYnVpbGQtMTE6
MjAxNDA5MjMyMzQ4MjQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2
LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
My81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3Rv
LWl2YjQxLTE5OjIwMTQwOTIzMjM0NDM2OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6
Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5
ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLXZwLTIyOjIwMTQwOTIz
MjMyMTE3OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIw
MTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEz
MDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS02
ODoyMDE0MDkyMzIzNDYzNTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3
YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMzA6MjAxNDA5MjMyMzQ3MDc6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQy
L2RtZXNnLXlvY3RvLWl2YjQxLTc5OjIwMTQwOTIzMjM0ODA3OmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVm
MjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0
MS0xMDc6MjAxNDA5MjMyMzUwMDc6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQy
YTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWtidWlsZC0xOjIwMTQwOTIzMjMx
NDA3OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQw
OTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5
MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLXZwLTI1OjIw
MTQwOTIzMjMzOTQwOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1u
ZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMv
NTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1p
dmI0MS05OjIwMTQwOTIzMjM0NjM0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5Zjlk
MmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy12bS12cC1xdWFudGFsLWkzODYtMzY6MjAx
NDA5MjMyMzE4MDA6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5l
eHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81
NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWti
dWlsZC0zOjIwMTQwOTIzMjMzMzM3OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4x
Ny4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVz
Zy15b2N0by1pdmI0MS01NDoyMDE0MDkyMzIzNDcwNzppMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2
OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMjY6
MjAxNDA5MjMyMzQ1MDU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2Ex
MjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTIwOjIwMTQwOTIzMjM0NjA1Omkz
ODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9k
bWVzZy15b2N0by1rYnVpbGQtMjU6MjAxNDA5MjMyMzM5NDk6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5
YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTU6MjAxNDA5MjMyMzQ0MzM6aTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlv
Y3RvLXZwLTI2OjIwMTQwOTIzMjMxNjUyOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6
My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9k
bWVzZy15b2N0by1rYnVpbGQtMTg6MjAxNDA5MjMyMzQ4MzE6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5
YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtdnAtMjY6MjAxNDA5MjMyMzU1MDA6aTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4
N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTEwODoyMDE0MDkyMzIzNDgw
NzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhh
ZDIvZG1lc2cteW9jdG8taXZiNDEtMTI1OjIwMTQwOTIzMjM0OTQ2OmkzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMv
NTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1p
dmI0MS00MzoyMDE0MDkyMzIzNDUzNDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoK
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5
ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS0zOjIwMTQwOTIz
MjMzOTQzOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2
ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0xNDoyMDE0MDkyMzIzNDcwNzppMzg2LXJhbmRj
b25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9j
dG8taXZiNDEtNDoyMDE0MDkyMzIzNDUzNDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
OjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJm
OWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS0zOjIwMTQw
OTIzMjMzOTUzOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYt
cmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0
OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTEwODoyMDE0MDkyMzIzNTIxNjppMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1l
c2ctcXVhbnRhbC1pdmI0MS0xMTk6MjAxNDA5MjMyMzUzMDY6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYy
MTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLXZwLTM4
OjIwMTQwOTI2MTc1MDA1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJj
Ni1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0
by12cC0xNDoyMDE0MDkyMzIzMTY1MzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMu
MTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1l
c2ctcXVhbnRhbC1pdmI0MS05MDoyMDE0MDkyMzIzNDMwNDppMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIx
MzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0
MS03OToyMDE0MDkyMzIzNTMwNjppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tl
cm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJh
MDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS02MzoyMDE0MDkyMzIz
NDMzNDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRj
b25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQz
ODhhZDIvZG1lc2cteW9jdG8taXZiNDEtNzQ6MjAxNDA5MjMyMzQ3MzU6aTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
My81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50
YWwtaXZiNDEtMjU6MjAxNDA5MjMyMzQyMDQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
Mzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFi
ZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMTI0OjIw
MTQwOTIzMjM1MzA2OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kz
ODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3
ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0xNDoyMDE0MDkyMzIzNDYwNDppMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1l
c2cteW9jdG8tdnAtNjM6MjAxNDA5MjMyMzU0NTk6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4
YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMTM6MjAxNDA5MjMyMzQxMDQ6aTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
My81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3Rv
LWl2YjQxLTU6MjAxNDA5MjMyMzQ1MzQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6
Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlm
OWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTU1OjIwMTQwOTIz
MjM0NjM0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2
ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0xOjIwMTQwOTIzMjM1MDA3OmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0
by1pdmI0MS0zOjIwMTQwOTIzMjM0NDA0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6
Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5
ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0xMToyMDE0MDky
MzIzNDQzNTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDlj
NmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMTE1OjIwMTQwOTIzMjM0OTQ1OmkzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15
b2N0by1pdmI0MS0xMTY6MjAxNDA5MjMyMzUwMDc6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkw
MGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLXZwLTE0OjIwMTQw
OTIzMjM1MTM2OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0
LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVm
MjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0
MS0zMzoyMDE0MDkyMzIzNDUwNDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tl
cm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJh
MDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMjE6MjAxNDA5MjMyMzQ0
MzU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4
YWQyL2RtZXNnLXlvY3RvLWtidWlsZC0xNToyMDE0MDkyMzIzNDgzMTppMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEy
N2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS03MzoyMDE0MDkyMzIzNDIwMzpp
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2cteW9jdG8taXZiNDEtMTIxOjIwMTQwOTIzMjM1MDM3OmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVm
MjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2
YjQxLTUzOjIwMTQwOTIzMjM0MjMzOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5Zjlk
MmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTI2OjIwMTQwOTIz
MjM0MDM0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2
ZDM4OGFkMi9kbWVzZy15b2N0by12cC01MzoyMDE0MDkyMzIzNTEzODppMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEy
N2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8tdnAtNTU6MjAxNDA5MjMyMzE2NTE6aTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQy
YTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLXZwLTI6MjAxNDA5MjMyMzUxMzY6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6
ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFi
ZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWtidWlsZC0yODoyMDE0
MDkyMzIzMzcxMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4
dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1
ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8ta2J1
aWxkLTIzOjIwMTQwOTIzMjMyNjM0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4x
Ny4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVz
Zy15b2N0by1pdmI0MS0xMjoyMDE0MDkyMzIzNDQzNzppMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2
OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtNjY6
MjAxNDA5MjMyMzQ2MDU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2Ex
MjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMjk6MjAxNDA5MjMyMzQwMzU6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQy
L2RtZXNnLXlvY3RvLWl2YjQxLTM5OjIwMTQwOTIzMjM1MDM1OmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVm
MjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by12cC0z
NzoyMDE0MDkyMzIzMzkzODppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1y
YzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVh
bnRhbC1pdmI0MS0xNjoyMDE0MDkyMzIzNDAzNDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAw
YWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8tdnAtNToyMDE0MDky
NjE3NTAwOTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0y
MDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIx
MzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEt
NTk6MjAxNDA5MjMyMzUwMDc6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4
N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtdnAtMTE6MjAxNDA5MjMyMzU1MDE6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6
ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFi
ZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWtidWlsZC0yNjoyMDE0
MDkyMzIzMTQwNzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4
dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1
ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZi
NDEtMToyMDE0MDkyMzIzNTAzNzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tl
cm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJh
MDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtNTI6MjAxNDA5MjMyMzUw
MDc6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4
YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTEwNToyMDE0MDkyMzIzNDg0NjppMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
LzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRh
bC1pdmI0MS0xMzoyMDE0MDkyMzIzNDAzMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
OjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJm
OWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS0zMzoyMDE0
MDkyMzIzNDMzMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2Zm
NDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMTA3OjIwMTQwOTIzMjM0NzM1OmkzODYt
cmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVz
Zy15b2N0by1pdmI0MS0xMzoyMDE0MDkyMzIzNDk0NTppMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2
OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMTI2
OjIwMTQwOTIzMjM0OTQ0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVs
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdh
MTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTc1OjIwMTQwOTIzMjM0MzMz
OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFk
Mi9kbWVzZy15b2N0by12cC00ODoyMDE0MDkyMzIzMjExNTppMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDlj
NmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS0xODoyMDE0MDkyMzIzNDIwNDppMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ct
eW9jdG8taXZiNDEtMjU6MjAxNDA5MjMyMzQ5NDU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkw
MGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtNTE6
MjAxNDA5MjMyMzQyMDU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2Ex
MjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtODg6MjAxNDA5MjMyMzQyMzM6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQy
L2RtZXNnLXlvY3RvLWl2YjQxLTg6MjAxNDA5MjMyMzQ0MzQ6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYy
MTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZi
NDEtMToyMDE0MDkyMzIzNDIwNDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tl
cm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJh
MDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtMjY6MjAxNDA5MjMyMzUw
MzU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4
YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTkzOjIwMTQwOTIzMjM0OTQ1OmkzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMv
NTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFs
LWtidWlsZC0yNToyMDE0MDkyMzIzMzMxMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
OjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2cteW9jdG8taXZiNDEtNTU6MjAxNDA5MjMyMzQ3MDc6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYy
MTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQx
LTE1OjIwMTQwOTIzMjM0NTM0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEw
ODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTg5OjIwMTQwOTIzMjM1
MzA2OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4
OGFkMi9kbWVzZy1xdWFudGFsLWtidWlsZC0yNToyMDE0MDkyMzIzMzQzODppMzg2LXJhbmRj
b25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3
YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtODoyMDE0MDkyMzIzNDQwOTpp
Mzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2ctcXVhbnRhbC12cC0xMToyMDE0MDkyMzIzMjUzNDppMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDlj
NmQzODhhZDIvZG1lc2cteW9jdG8taXZiNDEtNzY6MjAxNDA5MjMyMzQ4NDQ6aTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlv
Y3RvLWl2YjQxLTU2OjIwMTQwOTIzMjM0ODA1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBh
YmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by12cC05OjIwMTQwOTIz
MjM1MTM1OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIw
MTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEz
MDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQx
LTQ2OjIwMTQwOTIzMjM0MTM0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEw
ODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy1xdWFudGFsLXZwLTIyOjIwMTQwOTIzMjMxODA2
OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIz
OjgwMgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBh
YmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS05OjIwMTQw
OTIzMjM0NjA0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYt
cmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0
OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1rYnVpbGQtMTE6MjAxNDA5MjMyMzQ5MzI6aTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQy
YTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTE0OjIwMTQwOTIzMjM0
NjM0OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4
OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTExMToyMDE0MDkyMzIzNDMzNDppMzg2LXJhbmRj
b25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2ctcXVh
bnRhbC1pdmI0MS04OjIwMTQwOTIzMjM1MjE2OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBh
YmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15b2N0by1pdmI0MS0zMDoyMDE0
MDkyMzIzNDczNTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2Zm
NDljNmQzODhhZDIvZG1lc2ctcXVhbnRhbC1pdmI0MS05MzoyMDE0MDkyMzIzNTIxNjppMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1l
c2cteW9jdG8ta2J1aWxkLTIxOjIwMTQwOTIzMjMxMDE1OmkzODYtcmFuZGNvbmZpZy1pYjEt
MDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTIzOjgwMgova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2
ZDM4OGFkMi9kbWVzZy1xdWFudGFsLWl2YjQxLTk5OjIwMTQwOTIzMjM1MzA2OmkzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDMvNTVmMjEzMDY5MDBhYmY5ZjlkMmEwODdhMTI3ZmY0OWM2ZDM4OGFkMi9kbWVzZy15
b2N0by12cC01MToyMDE0MDkyMzIzNDQwMzppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
OjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyMzo4MDIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIv
ZG1lc2ctcXVhbnRhbC1pdmI0MS0zNjoyMDE0MDkyMzIzNDEwNDppMzg2LXJhbmRjb25maWct
aWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzU1
ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9jdG8taXZi
NDEtNjk6MjAxNDA5MjMyMzUwMDc6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQy
YTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMTU6MjAxNDA5MjMy
MzQxMDQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZk
Mzg4YWQyL2RtZXNnLXF1YW50YWwtaXZiNDEtMjoyMDE0MDkyMzIzNTMzNjppMzg2LXJhbmRj
b25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMy
MzAzLzU1ZjIxMzA2OTAwYWJmOWY5ZDJhMDg3YTEyN2ZmNDljNmQzODhhZDIvZG1lc2cteW9j
dG8tdnAtMjM6MjAxNDA5MjYxNzUwMDU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzoz
LjE3LjAtcmM2LW5leHQtMjAxNDA5MjM6ODAyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2Rt
ZXNnLXF1YW50YWwtaXZiNDEtMTM6MjAxNDA5MjMyMzQxMzQ6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYy
MTMwNjkwMGFiZjlmOWQyYTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXF1YW50YWwtaXZi
NDEtNjY6MjAxNDA5MjMyMzQyMDQ6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy81NWYyMTMwNjkwMGFiZjlmOWQy
YTA4N2ExMjdmZjQ5YzZkMzg4YWQyL2RtZXNnLXlvY3RvLWl2YjQxLTY6MjAxNDA5MjMyMzQ0
MzU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6CjE6MzEyOjMxNCBhbGxfZ29vZDpi
YWQ6YWxsX2JhZCBib290cwoKSEVBRCBpcyBub3cgYXQgNTVmMjEzMCBBZGQgbGludXgtbmV4
dCBzcGVjaWZpYyBmaWxlcyBmb3IgMjAxNDA5MjMKCj09PT09PT09PSBsaW51cy9tYXN0ZXIg
PT09PT09PT09Ck5vdGU6IGNoZWNraW5nIG91dCAnbGludXMvbWFzdGVyJy4KCllvdSBhcmUg
aW4gJ2RldGFjaGVkIEhFQUQnIHN0YXRlLiBZb3UgY2FuIGxvb2sgYXJvdW5kLCBtYWtlIGV4
cGVyaW1lbnRhbApjaGFuZ2VzIGFuZCBjb21taXQgdGhlbSwgYW5kIHlvdSBjYW4gZGlzY2Fy
ZCBhbnkgY29tbWl0cyB5b3UgbWFrZSBpbiB0aGlzCnN0YXRlIHdpdGhvdXQgaW1wYWN0aW5n
IGFueSBicmFuY2hlcyBieSBwZXJmb3JtaW5nIGFub3RoZXIgY2hlY2tvdXQuCgpJZiB5b3Ug
d2FudCB0byBjcmVhdGUgYSBuZXcgYnJhbmNoIHRvIHJldGFpbiBjb21taXRzIHlvdSBjcmVh
dGUsIHlvdSBtYXkKZG8gc28gKG5vdyBvciBsYXRlcikgYnkgdXNpbmcgLWIgd2l0aCB0aGUg
Y2hlY2tvdXQgY29tbWFuZCBhZ2Fpbi4gRXhhbXBsZToKCiAgZ2l0IGNoZWNrb3V0IC1iIG5l
d19icmFuY2hfbmFtZQoKSEVBRCBpcyBub3cgYXQgZjRjYjcwNy4uLiBNZXJnZSB0YWcgJ3Bt
K2FjcGktMy4xNy1yYzcnIG9mIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgv
a2VybmVsL2dpdC9yYWZhZWwvbGludXgtcG0KbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVl
dWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvbGludXM6bWFzdGVyOmY0Y2I3
MDdlN2FkOTcyN2EwNDZiNDYzMjMyZjJkZTE2NmUzMjdkM2U6YmlzZWN0LWxpbnV4LTEKCjIw
MTQtMDktMjYgMjI6MjY6MjMgZjRjYjcwN2U3YWQ5NzI3YTA0NmI0NjMyMzJmMmRlMTY2ZTMy
N2QzZSBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWls
ZC1xdWV1ZS9sa3AtaWIwMy9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLWY0Y2I3MDdl
N2FkOTcyN2EwNDZiNDYzMjMyZjJkZTE2NmUzMjdkM2UKQ2hlY2sgZm9yIGtlcm5lbCBpbiAv
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvZjRjYjcwN2U3YWQ5NzI3YTA0
NmI0NjMyMzJmMmRlMTY2ZTMyN2QzZQp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVp
bGQtdGVzdHMvYnVpbGQtcXVldWUvbGtwLWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy1mNGNiNzA3ZTdhZDk3MjdhMDQ2YjQ2MzIzMmYyZGUxNjZlMzI3ZDNlChtbMTszNW0y
MDE0LTA5LTI2IDIyOjI5OjIzIE5vIGJ1aWxkIHNlcnZlZCBmaWxlIC9rYnVpbGQtdGVzdHMv
YnVpbGQtc2VydmVkL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMtZjRjYjcwN2U3YWQ5
NzI3YTA0NmI0NjMyMzJmMmRlMTY2ZTMyN2QzZRtbMG0KUmV0cnkgYnVpbGQgLi4Kd2FpdGlu
ZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAz
LXNtb2tlL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMtZjRjYjcwN2U3YWQ5NzI3YTA0
NmI0NjMyMzJmMmRlMTY2ZTMyN2QzZQprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy9mNGNiNzA3ZTdhZDk3MjdhMDQ2YjQ2MzIzMmYyZGUxNjZlMzI3ZDNl
L3ZtbGludXotMy4xNy4wLXJjNi0wMDE1MS1nZjRjYjcwNwoKMjAxNC0wOS0yNiAyMjozMToy
MyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuCTkJNjAgU1VDQ0VTUwoKCj09PT09PT09PSBuZXh0
L21hc3RlciA9PT09PT09PT0KRnJvbSBnaXQ6Ly9naXRtaXJyb3IvbmV4dAogKyA0ODEwMGNh
Li4uNGYzN2FmMSBha3BtICAgICAgIC0+IG5leHQvYWtwbSAgKGZvcmNlZCB1cGRhdGUpCiAr
IDJjZjUwNzYuLi5hMjVjMWQ4IGFrcG0tYmFzZSAgLT4gbmV4dC9ha3BtLWJhc2UgIChmb3Jj
ZWQgdXBkYXRlKQogKyA4ZGQyYzgxLi4uNGQ4NDI2ZiBtYXN0ZXIgICAgIC0+IG5leHQvbWFz
dGVyICAoZm9yY2VkIHVwZGF0ZSkKICAgMDA1ZjgwMC4uZjRjYjcwNyAgc3RhYmxlICAgICAt
PiBuZXh0L3N0YWJsZQpGcm9tIGdpdDovL2dpdG1pcnJvci9uZXh0CiAqIFtuZXcgdGFnXSAg
ICAgICAgIG5leHQtMjAxNDA5MjYgLT4gbmV4dC0yMDE0MDkyNgpQcmV2aW91cyBIRUFEIHBv
c2l0aW9uIHdhcyBmNGNiNzA3Li4uIE1lcmdlIHRhZyAncG0rYWNwaS0zLjE3LXJjNycgb2Yg
Z2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L3JhZmFlbC9s
aW51eC1wbQpIRUFEIGlzIG5vdyBhdCA0ZDg0MjZmLi4uIEFkZCBsaW51eC1uZXh0IHNwZWNp
ZmljIGZpbGVzIGZvciAyMDE0MDkyNgpscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9r
dm0vaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy9uZXh0Om1hc3Rlcjo0ZDg0MjZmOWFj
NjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxOmJpc2VjdC1saW51eC0xCgoyMDE0LTA5
LTI2IDIyOjMzOjE3IDRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEg
Y29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUvbGtwLWliMDMvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy00ZDg0MjZmOWFjNjAx
ZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzRkODQyNmY5YWM2MDFkYjJhNjRmYTdi
ZTY0MDUxZDAyYjljOWZlMDEKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRl
c3RzL2J1aWxkLXF1ZXVlL2xrcC1pYjAzLXNtb2tlL2kzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDMtNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMQprZXJuZWw6
IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIy
YTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL3ZtbGludXotMy4xNy4wLXJjNi1uZXh0LTIwMTQw
OTI2CgoyMDE0LTA5LTI2IDIyOjM2OjE3IGRldGVjdGluZyBib290IHN0YXRlIC4gVEVTVCBG
QUlMVVJFClsgICAgMC4xNjIzMzldIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LQpbICAgIDAuMTY0MDA4XSBzbXBib290OiBUb3RhbCBvZiAxIHByb2Nlc3NvcnMgYWN0aXZh
dGVkICg0NTIxLjk5IEJvZ29NSVBTKQpbICAgIDAuMTY2OTgzXSBkZXZ0bXBmczogaW5pdGlh
bGl6ZWQKWyAgICAwLjE2ODU1MV0gQlVHOiB1bmFibGUgdG8gaGFuZGxlIGtlcm5lbCBwYWdp
bmcgcmVxdWVzdCBhdCAyNGEwMDAyMApbICAgIDAuMTcwNDcwXSBJUDogWzxjMTE4MTQwOT5d
IGtlcm5mc19hZGRfb25lKzB4ODkvMHgxMzAKWyAgICAwLjE3MjAwMF0gKnBkcHQgPSAwMDAw
MDAwMDAwMDAwMDAwICpwZGUgPSAwMDAwMDAwMDAwMDAwMDAwIApbICAgIDAuMTcyMDAwXSBP
b3BzOiAwMDAyIFsjMV0gU01QIApbICAgIDAuMTcyMDAwXSBNb2R1bGVzIGxpbmtlZCBpbjoK
WyAgICAwLjE3MjAwMF0gQ1BVOiAwIFBJRDogMSBDb21tOiBzd2FwcGVyLzAgTm90IHRhaW50
ZWQgMy4xNy4wLXJjNi1uZXh0LTIwMTQwOTI2ICMxClsgICAgMC4xNzIwMDBdIEhhcmR3YXJl
IG5hbWU6IFFFTVUgU3RhbmRhcmQgUEMgKGk0NDBGWCArIFBJSVgsIDE5OTYpLCBCSU9TIDEu
Ny41LTIwMTQwNTMxXzA4MzAzMC1nYW5kYWxmIDA0LzAxLzIwMTQKWyAgICAwLjE3MjAwMF0g
dGFzazogZDMwM2FjOTAgdGk6IGQzMDNjMDAwIHRhc2sudGk6IGQzMDNjMDAwClsgICAgMC4x
NzIwMDBdIEVJUDogMDA2MDpbPGMxMTgxNDA5Pl0gRUZMQUdTOiAwMDAxMDI4MiBDUFU6IDAK
WyAgICAwLjE3MjAwMF0gRUlQIGlzIGF0IGtlcm5mc19hZGRfb25lKzB4ODkvMHgxMzAKWyAg
ICAwLjE3MjAwMF0gRUFYOiA1NDI1NzliZiBFQlg6IDI0YTAwMDAwIEVDWDogMDAwMDAwMDgg
RURYOiAyYmE3ODQ1ZQpbICAgIDAuMTcyMDAwXSBFU0k6IGQzMDY5MDMwIEVESTogZDMwNjkw
OTAgRUJQOiBkMzAzZGU1NCBFU1A6IGQzMDNkZTMwClsgICAgMC4xNzIwMDBdICBEUzogMDA3
YiBFUzogMDA3YiBGUzogMDBkOCBHUzogMDAwMCBTUzogMDA2OApbICAgIDAuMTcyMDAwXSBD
UjA6IDgwMDUwMDNiIENSMjogMjRhMDAwMjAgQ1IzOiAwMWE5OTAwMCBDUjQ6IDAwMDAwNmYw
ClsgICAgMC4xNzIwMDBdIFN0YWNrOgpbICAgIDAuMTcyMDAwXSAgZDMwMDZmMDAgMDAwMDAy
MDIgZDMwNjkwOTAgZDMwNjkwMzAgZDMwM2RlNTQgYzExODEyYjAgZDMwNjkwMzAgYzE1YTNh
MDAKWyAgICAwLjE3MjAwMF0gIGMxODgxMmVjIGQzMDNkZTZjIGMxMTgyODAyIDAwMDAwMDAw
IGMxODgxMmUwIGQzMDY5MDkwIDAwMDAwMDAwIGQzMDNkZWE4ClsgICAgMC4xNzIwMDBdICBj
MTE4MmZjNSAwMDAwMTAwMCAwMDAwMDAwMCBjMTVhM2EwMCBjMTg4MTJlMCAwMDAwMDAwMCAw
MDAwMDAwMSBjMTg4MTJlYwpbICAgIDAuMTcyMDAwXSBDYWxsIFRyYWNlOgpbICAgIDAuMTcy
MDAwXSAgWzxjMTE4MTJiMD5dID8ga2VybmZzX25ld19ub2RlKzB4MzAvMHg0MApbICAgIDAu
MTcyMDAwXSAgWzxjMTE4MjgwMj5dIF9fa2VybmZzX2NyZWF0ZV9maWxlKzB4OTIvMHhjMApb
ICAgIDAuMTcyMDAwXSAgWzxjMTE4MmZjNT5dIHN5c2ZzX2FkZF9maWxlX21vZGVfbnMrMHg5
NS8weDE5MApbICAgIDAuMTcyMDAwXSAgWzxjMTE4MzI1ZT5dIHN5c2ZzX2FkZF9maWxlKzB4
MWUvMHgzMApbICAgIDAuMTcyMDAwXSAgWzxjMTE4MzhkYT5dIHN5c2ZzX21lcmdlX2dyb3Vw
KzB4NGEvMHhjMApbICAgIDAuMTcyMDAwXSAgWzxjMTMyYzBiYz5dIGRwbV9zeXNmc19hZGQr
MHg1Yy8weGIwClsgICAgMC4xNzIwMDBdICBbPGMxMzI1MmY2Pl0gZGV2aWNlX2FkZCsweDQ0
Ni8weDU4MApbICAgIDAuMTcyMDAwXSAgWzxjMTMyZjQ2YT5dID8gcG1fcnVudGltZV9pbml0
KzB4ZWEvMHhmMApbICAgIDAuMTcyMDAwXSAgWzxjMTMyNTQ0Mj5dIGRldmljZV9yZWdpc3Rl
cisweDEyLzB4MjAKWyAgICAwLjE3MjAwMF0gIFs8YzEzMjZiYTc+XSBzdWJzeXNfcmVnaXN0
ZXIucGFydC42KzB4NjcvMHhiMApbICAgIDAuMTcyMDAwXSAgWzxjMTMyNmMxNT5dIHN1YnN5
c19zeXN0ZW1fcmVnaXN0ZXIrMHgyNS8weDMwClsgICAgMC4xNzIwMDBdICBbPGMxOGYyM2Iy
Pl0gY29udGFpbmVyX2Rldl9pbml0KzB4Zi8weDI4ClsgICAgMC4xNzIwMDBdICBbPGMxOGYy
M2ExPl0gZHJpdmVyX2luaXQrMHgzMC8weDMyClsgICAgMC4xNzIwMDBdICBbPGMxOGJlYjYx
Pl0ga2VybmVsX2luaXRfZnJlZWFibGUrMHg3ZC8weDE3OQpbICAgIDAuMTcyMDAwXSAgWzxj
MTU3MDcwYj5dIGtlcm5lbF9pbml0KzB4Yi8weGQwClsgICAgMC4xNzIwMDBdICBbPGMxNTdk
NTQxPl0gcmV0X2Zyb21fa2VybmVsX3RocmVhZCsweDIxLzB4MzAKWyAgICAwLjE3MjAwMF0g
IFs8YzE1NzA3MDA+XSA/IHJlc3RfaW5pdCsweGIwLzB4YjAKWyAgICAwLjE3MjAwMF0gQ29k
ZTogMjYgMDAgODMgZTEgMTAgNzUgNWIgOGIgNDYgMjQgZTggYzMgZWEgZmYgZmYgODkgNDYg
MzggODkgZjAgZTggZDkgZjkgZmYgZmYgODUgYzAgODkgYzMgNzUgY2EgOGIgNWYgNWMgODUg
ZGIgNzQgMTEgZTggNjcgNzYgZjEgZmYgPDg5PiA0MyAyMCA4OSA1MyAyNCA4OSA0MyAyOCA4
OSA1MyAyYyBiOCA0MCBlNyA4NSBjMSBlOCAxMSA4ZiAzZgpbICAgIDAuMTcyMDAwXSBFSVA6
IFs8YzExODE0MDk+XSBrZXJuZnNfYWRkX29uZSsweDg5LzB4MTMwIFNTOkVTUCAwMDY4OmQz
MDNkZTMwClsgICAgMC4xNzIwMDBdIENSMjogMDAwMDAwMDAyNGEwMDAyMApbICAgIDAuMTcy
MDAwXSAtLS1bIGVuZCB0cmFjZSAwMTdjZmZhNGVmMDhhNzU1IF0tLS0KWyAgICAwLjE3MjAw
MF0gS2VybmVsIHBhbmljIC0gbm90IHN5bmNpbmc6IEZhdGFsIGV4Y2VwdGlvbgova2VybmVs
L2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2Jl
NjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by12cC0xNjoyMDE0MDkyNjIyMzUzODppMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4dC0yMDE0MDkyNjoxCi9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0
ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLXZwLTIzOjIwMTQwOTI2MjIzNTM5
OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJjNi1uZXh0LTIwMTQwOTI2
OjEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzRkODQyNmY5YWM2MDFk
YjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2cteW9jdG8tdnAtMzc6MjAxNDA5MjYy
MjM1MzU6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3LjAtcmM2LW5leHQtMjAx
NDA5MjY6MQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2Zjlh
YzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by12cC00NDoyMDE0
MDkyNjIyMzUzNjppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjMuMTcuMC1yYzYtbmV4
dC0yMDE0MDkyNjoxCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0
MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLXZwLTU1
OjIwMTQwOTI2MjIzNTM5OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6My4xNy4wLXJj
Ni1uZXh0LTIwMTQwOTI2OjEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
LzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2cteW9jdG8t
dnAtNjA6MjAxNDA5MjYyMjM1MzM6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzozLjE3
LjAtcmM2LW5leHQtMjAxNDA5MjY6MQova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15
b2N0by12cC04OjIwMTQwOTI2MjIzNTM3OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6
My4xNy4wLXJjNi1uZXh0LTIwMTQwOTI2OjEKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzLzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1l
c2cteW9jdG8tdnAtMTM6MjAxNDA5MjYyMjM1NDI6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzozLjE3LjAtcmM2LW5leHQtMjAxNDA5MjY6MQova2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUw
MS9kbWVzZy15b2N0by1sa3AtbmV4MDQtMTA4OjIwMTQwOTI2MjIzNTQ5OmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0
by1sa3AtbmV4MDQtMTEyOjIwMTQwOTI2MjIzNTQ5OmkzODYtcmFuZGNvbmZpZy1pYjEtMDky
MzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2Zjlh
YzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by1sa3AtbmV4MDQt
MTEzOjIwMTQwOTI2MjIzNTQ4OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZh
N2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by1sa3AtbmV4MDQtMTE3OjIwMTQwOTI2
MjIzNTQ5OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJi
OWM5ZmUwMS9kbWVzZy15b2N0by1sa3AtbmV4MDQtMTE5OjIwMTQwOTI2MjIzNTUxOmkzODYt
cmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEt
MDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVz
Zy15b2N0by1sa3AtbmV4MDQtMTMzOjIwMTQwOTI2MjIzNTQ5OmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4
NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by1sa3At
bmV4MDQtMTM1OjIwMTQwOTI2MjIzNTUwOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6
Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRi
MmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by1sa3AtbmV4MDQtMTM4OjIw
MTQwOTI2MjIzNTUwOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kz
ODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQw
NTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by1sa3AtbmV4MDQtMTQ0OjIwMTQwOTI2MjIzNTQ5
OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUw
MS9kbWVzZy15b2N0by1sa3AtbmV4MDQtMTQ6MjAxNDA5MjYyMjM1NTA6aTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
My80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3Rv
LWxrcC1uZXgwNC0xNTQ6MjAxNDA5MjYyMjM1NTA6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFj
NjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC0x
NTY6MjAxNDA5MjYyMjM1NTE6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3
YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC0xNTc6MjAxNDA5MjYy
MjM1NDg6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5
YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC0xNjM6MjAxNDA5MjYyMjM1NDg6aTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNn
LXlvY3RvLWxrcC1uZXgwNC0xNjg6MjAxNDA5MjYyMjM1NDk6aTM4Ni1yYW5kY29uZmlnLWli
MS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0
MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1u
ZXgwNC0xNjk6MjAxNDA5MjYyMjM1NTA6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6
Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIy
YTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC0xNzM6MjAx
NDA5MjYyMjM1NDk6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4
Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1
MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC0xNzQ6MjAxNDA5MjYyMjM1NTA6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAx
L2RtZXNnLXlvY3RvLWxrcC1uZXgwNC0xNzY6MjAxNDA5MjYyMjM1NDk6aTM4Ni1yYW5kY29u
ZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMw
My80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3Rv
LWxrcC1uZXgwNC0xNzc6MjAxNDA5MjYyMjM1NDk6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFj
NjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC0x
ODQ6MjAxNDA5MjYyMjM1NDk6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3
YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC0xODk6MjAxNDA5MjYy
MjM1NDk6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5
YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC0xODoyMDE0MDkyNjIyMzU0OTppMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzLzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2ct
eW9jdG8tbGtwLW5leDA0LTE6MjAxNDA5MjYyMjM1NDg6aTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZm
OWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgw
NC0yMzoyMDE0MDkyNjIyMzU1MDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tl
cm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzRkODQyNmY5YWM2MDFkYjJhNjRm
YTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2cteW9jdG8tbGtwLW5leDA0LTI0OjIwMTQwOTI2
MjIzNTUwOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJi
OWM5ZmUwMS9kbWVzZy15b2N0by1sa3AtbmV4MDQtMjg6MjAxNDA5MjYyMjM1NDk6aTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0w
OTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNn
LXlvY3RvLWxrcC1uZXgwNC0yOToyMDE0MDkyNjIyMzU0ODppMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzRkODQy
NmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2cteW9jdG8tbGtwLW5l
eDA0LTMwOjIwMTQwOTI2MjIzNTUwOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2
NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by1sa3AtbmV4MDQtMzE6MjAxNDA5
MjYyMjM1NTA6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQw
MmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC0zODoyMDE0MDkyNjIyMzU0OTppMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIx
LTA5MjMyMzAzLzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1l
c2cteW9jdG8tbGtwLW5leDA0LTM5OjIwMTQwOTI2MjIzNTQ5OmkzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4
NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by1sa3At
bmV4MDQtNDI6MjAxNDA5MjYyMjM1NDk6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6
Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIy
YTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC00MzoyMDE0
MDkyNjIyMzU1MDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUx
ZDAyYjljOWZlMDEvZG1lc2cteW9jdG8tbGtwLW5leDA0LTQ0OjIwMTQwOTI2MjIzNTUxOmkz
ODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1p
YjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9k
bWVzZy15b2N0by1sa3AtbmV4MDQtNTU6MjAxNDA5MjYyMjM1NTA6aTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80
ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxr
cC1uZXgwNC01NzoyMDE0MDkyNjIyMzU1MDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
OjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzRkODQyNmY5YWM2MDFk
YjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2cteW9jdG8tbGtwLW5leDA0LTU4OjIw
MTQwOTI2MjIzNTQ5OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kz
ODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQw
NTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by1sa3AtbmV4MDQtNjE6MjAxNDA5MjYyMjM1NTE6
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAx
L2RtZXNnLXlvY3RvLWxrcC1uZXgwNC02MjoyMDE0MDkyNjIyMzU1MDppMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAz
LzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2cteW9jdG8t
bGtwLW5leDA0LTY2OjIwMTQwOTI2MjIzNTQ5OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYw
MWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by1sa3AtbmV4MDQtNzM6
MjAxNDA5MjYyMjM1NDk6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2
NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC03NToyMDE0MDkyNjIyMzU1
MDppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctaWIxLTA5MjMyMzAzLzRkODQyNmY5YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZl
MDEvZG1lc2cteW9jdG8tbGtwLW5leDA0LTc3OjIwMTQwOTI2MjIzNTQ5OmkzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIz
MDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0
by1sa3AtbmV4MDQtODE6MjAxNDA5MjYyMjM1NTE6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFj
NjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC04
NToyMDE0MDkyNjIyMzU0OTppMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzOjoKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzRkODQyNmY5YWM2MDFkYjJhNjRmYTdi
ZTY0MDUxZDAyYjljOWZlMDEvZG1lc2cteW9jdG8tbGtwLW5leDA0LTg2OjIwMTQwOTI2MjIz
NTUxOmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2VybmVsL2kzODYtcmFuZGNv
bmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZhN2JlNjQwNTFkMDJiOWM5
ZmUwMS9kbWVzZy15b2N0by1sa3AtbmV4MDQtODk6MjAxNDA5MjYyMjM1NDk6aTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMS0wOTIz
MjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5YzlmZTAxL2RtZXNnLXlv
Y3RvLWxrcC1uZXgwNC05MzoyMDE0MDkyNjIyMzU1MDppMzg2LXJhbmRjb25maWctaWIxLTA5
MjMyMzAzOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIxLTA5MjMyMzAzLzRkODQyNmY5
YWM2MDFkYjJhNjRmYTdiZTY0MDUxZDAyYjljOWZlMDEvZG1lc2cteW9jdG8tbGtwLW5leDA0
LTk2OjIwMTQwOTI2MjIzNTQ5OmkzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDM6Ogova2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1pYjEtMDkyMzIzMDMvNGQ4NDI2ZjlhYzYwMWRiMmE2NGZh
N2JlNjQwNTFkMDJiOWM5ZmUwMS9kbWVzZy15b2N0by1sa3AtbmV4MDQtOTc6MjAxNDA5MjYy
MjM1NDg6aTM4Ni1yYW5kY29uZmlnLWliMS0wOTIzMjMwMzo6Ci9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWliMS0wOTIzMjMwMy80ZDg0MjZmOWFjNjAxZGIyYTY0ZmE3YmU2NDA1MWQwMmI5
YzlmZTAxL2RtZXNnLXlvY3RvLWxrcC1uZXgwNC05OToyMDE0MDkyNjIyMzU0ODppMzg2LXJh
bmRjb25maWctaWIxLTA5MjMyMzAzOjoKMDo2MDo2MCBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBi
b290cwoK

--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.17.0-rc6-00089-g36fbfeb"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.17.0-rc6 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
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
# CONFIG_ZONE_DMA32 is not set
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
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
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_KERNEL_LZ4=y
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
# CONFIG_SYSVIPC is not set
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_FHANDLE is not set
# CONFIG_USELIB is not set
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
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
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
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_RCU_FAST_NO_HZ is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_RCU_NOCB_CPU=y
CONFIG_RCU_NOCB_CPU_NONE=y
# CONFIG_RCU_NOCB_CPU_ZERO is not set
# CONFIG_RCU_NOCB_CPU_ALL is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
# CONFIG_CGROUPS is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
# CONFIG_NET_NS is not set
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
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_COMPAT_BRK=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
CONFIG_SYSTEM_TRUSTED_KEYRING=y
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
CONFIG_JUMP_LABEL=y
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
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
# CONFIG_GCOV_PROFILE_ALL is not set
# CONFIG_GCOV_FORMAT_AUTODETECT is not set
# CONFIG_GCOV_FORMAT_3_4 is not set
CONFIG_GCOV_FORMAT_4_7=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
CONFIG_MODVERSIONS=y
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_MODULE_SIG=y
# CONFIG_MODULE_SIG_FORCE is not set
# CONFIG_MODULE_SIG_ALL is not set
# CONFIG_MODULE_SIG_SHA1 is not set
CONFIG_MODULE_SIG_SHA224=y
# CONFIG_MODULE_SIG_SHA256 is not set
# CONFIG_MODULE_SIG_SHA384 is not set
# CONFIG_MODULE_SIG_SHA512 is not set
CONFIG_MODULE_SIG_HASH="sha224"
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_LBDAF=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUE_RWLOCK=y
CONFIG_QUEUE_RWLOCK=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
# CONFIG_X86_MPPARSE is not set
# CONFIG_X86_BIGSMP is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_32_IRIS=m
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
CONFIG_MK8=y
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
CONFIG_NR_CPUS=8
# CONFIG_SCHED_SMT is not set
# CONFIG_SCHED_MC is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_ANCIENT_MCE=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=m
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_VM86=y
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX32=y
CONFIG_TOSHIBA=m
CONFIG_I8K=m
# CONFIG_X86_REBOOTFIXUPS is not set
# CONFIG_MICROCODE is not set
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_X86_MSR=m
# CONFIG_X86_CPUID is not set
# CONFIG_NOHIGHMEM is not set
# CONFIG_HIGHMEM4G is not set
CONFIG_HIGHMEM64G=y
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_HIGHMEM=y
CONFIG_X86_PAE=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_NEED_NODE_MEMMAP_SIZE=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_NEED_BOUNCE_POOL=y
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
# CONFIG_ZPOOL is not set
# CONFIG_ZBUD is not set
CONFIG_ZSMALLOC=m
# CONFIG_PGTABLE_MAPPING is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_HIGHPTE is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MATH_EMULATION is not set
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_HOTPLUG_CPU is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
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
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_ACPI_EXTLOG is not set
CONFIG_SFI=y

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
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
# CONFIG_EISA is not set
CONFIG_SCx200=m
CONFIG_SCx200HR_TIMER=m
CONFIG_ALIX=y
# CONFIG_NET5501 is not set
# CONFIG_GEOS is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=m
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_I82365 is not set
# CONFIG_TCIC is not set
CONFIG_PCMCIA_PROBE=y
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_IOSF_MBI=m
CONFIG_PMC_ATOM=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=m
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=m
CONFIG_NET_KEY=m
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
# CONFIG_IP_ADVANCED_ROUTER is not set
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=m
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_IP_MROUTE is not set
# CONFIG_SYN_COOKIES is not set
CONFIG_NET_IPVTI=y
# CONFIG_NET_UDP_TUNNEL is not set
CONFIG_INET_AH=m
CONFIG_INET_ESP=y
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=m
CONFIG_INET_LRO=m
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
CONFIG_INET_UDP_DIAG=m
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=m
CONFIG_TCP_CONG_CUBIC=m
CONFIG_TCP_CONG_WESTWOOD=m
# CONFIG_TCP_CONG_HTCP is not set
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
# CONFIG_TCP_CONG_YEAH is not set
# CONFIG_TCP_CONG_ILLINOIS is not set
CONFIG_DEFAULT_HYBLA=y
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="hybla"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=m
CONFIG_IPV6_ROUTER_PREF=y
# CONFIG_IPV6_ROUTE_INFO is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
CONFIG_INET6_IPCOMP=m
CONFIG_IPV6_MIP6=m
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
# CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=m
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=m
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
CONFIG_IPV6_GRE=m
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
CONFIG_IP_SCTP=m
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
CONFIG_ATM=m
# CONFIG_ATM_CLIP is not set
CONFIG_ATM_LANE=m
CONFIG_ATM_MPOA=m
# CONFIG_ATM_BR2684 is not set
# CONFIG_L2TP is not set
CONFIG_MRP=y
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=m
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
CONFIG_VLAN_8021Q_MVRP=y
CONFIG_DECNET=m
CONFIG_DECNET_ROUTER=y
CONFIG_LLC=m
CONFIG_LLC2=m
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
CONFIG_X25=y
CONFIG_LAPB=m
CONFIG_PHONET=m
# CONFIG_6LOWPAN is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=m
CONFIG_BATMAN_ADV_BLA=y
# CONFIG_BATMAN_ADV_DAT is not set
CONFIG_BATMAN_ADV_NC=y
# CONFIG_BATMAN_ADV_MCAST is not set
CONFIG_BATMAN_ADV_DEBUG=y
# CONFIG_OPENVSWITCH is not set
CONFIG_VSOCKETS=m
CONFIG_NETLINK_MMAP=y
CONFIG_NETLINK_DIAG=m
CONFIG_NET_MPLS_GSO=y
CONFIG_HSR=y
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=y
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
CONFIG_IRDA=m

#
# IrDA protocols
#
CONFIG_IRLAN=m
# CONFIG_IRNET is not set
# CONFIG_IRCOMM is not set
CONFIG_IRDA_ULTRA=y

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
# CONFIG_IRDA_FAST_RR is not set
CONFIG_IRDA_DEBUG=y

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=m

#
# Dongle support
#
# CONFIG_DONGLE is not set
CONFIG_KINGSUN_DONGLE=m
CONFIG_KSDAZZLE_DONGLE=m
# CONFIG_KS959_DONGLE is not set

#
# FIR device drivers
#
CONFIG_USB_IRDA=m
CONFIG_SIGMATEL_FIR=m
CONFIG_NSC_FIR=m
CONFIG_WINBOND_FIR=m
# CONFIG_TOSHIBA_FIR is not set
# CONFIG_SMC_IRCC_FIR is not set
# CONFIG_ALI_FIR is not set
# CONFIG_VLSI_FIR is not set
# CONFIG_VIA_FIR is not set
CONFIG_MCS_FIR=m
# CONFIG_BT is not set
CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_DEBUG=y
# CONFIG_RXKAD is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
# CONFIG_CFG80211 is not set
CONFIG_LIB80211=m
# CONFIG_LIB80211_DEBUG is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_WIMAX=m
CONFIG_WIMAX_DEBUG_LEVEL=8
# CONFIG_RFKILL is not set
CONFIG_RFKILL_REGULATOR=y
# CONFIG_NET_9P is not set
CONFIG_CAIF=y
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=y
CONFIG_CAIF_USB=y
# CONFIG_CEPH_LIB is not set
CONFIG_NFC=m
CONFIG_NFC_DIGITAL=m
# CONFIG_NFC_NCI is not set
CONFIG_NFC_HCI=m
CONFIG_NFC_SHDLC=y

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_PN533=m
CONFIG_NFC_SIM=m
CONFIG_NFC_PORT100=m
CONFIG_NFC_PN544=m
CONFIG_NFC_PN544_I2C=m
CONFIG_NFC_MICROREAD=m
CONFIG_NFC_MICROREAD_I2C=m
CONFIG_NFC_ST21NFCA=m
CONFIG_NFC_ST21NFCA_I2C=m

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_FENCE_TRACE=y

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=m
CONFIG_MTD_TESTS=m
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=m
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=m
# CONFIG_MTD_BLOCK is not set
CONFIG_MTD_BLOCK_RO=m
# CONFIG_FTL is not set
CONFIG_NFTL=m
# CONFIG_NFTL_RW is not set
CONFIG_INFTL=m
CONFIG_RFD_FTL=m
# CONFIG_SSFDC is not set
CONFIG_SM_FTL=m
CONFIG_MTD_OOPS=m

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
CONFIG_MTD_JEDECPROBE=m
CONFIG_MTD_GEN_PROBE=m
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=m
CONFIG_MTD_CFI_AMDSTD=m
CONFIG_MTD_CFI_STAA=m
CONFIG_MTD_CFI_UTIL=m
# CONFIG_MTD_RAM is not set
# CONFIG_MTD_ROM is not set
CONFIG_MTD_ABSENT=m

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
# CONFIG_MTD_PHYSMAP is not set
CONFIG_MTD_SCx200_DOCFLASH=m
# CONFIG_MTD_AMD76XROM is not set
CONFIG_MTD_ICHXROM=m
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
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
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=m
CONFIG_MTD_NAND_BCH=m
CONFIG_MTD_NAND_ECC_BCH=y
# CONFIG_MTD_SM_COMMON is not set
CONFIG_MTD_NAND_DENALI=m
# CONFIG_MTD_NAND_DENALI_PCI is not set
# CONFIG_MTD_NAND_GPIO is not set
CONFIG_MTD_NAND_IDS=m
# CONFIG_MTD_NAND_RICOH is not set
CONFIG_MTD_NAND_DISKONCHIP=m
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_HIGH is not set
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
CONFIG_MTD_NAND_DOCG4=m
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_CS553X=m
CONFIG_MTD_NAND_NANDSIM=m
CONFIG_MTD_NAND_PLATFORM=m
# CONFIG_MTD_ONENAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_SPI_NOR=m
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
CONFIG_MTD_UBI_GLUEBI=m
# CONFIG_MTD_UBI_BLOCK is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=m
# CONFIG_PARPORT_SERIAL is not set
CONFIG_PARPORT_PC_FIFO=y
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=m
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_ISAPNP=y
CONFIG_PNPBIOS=y
# CONFIG_PNPBIOS_PROC_FS is not set
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
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=m
CONFIG_AD525X_DPOT=m
CONFIG_AD525X_DPOT_I2C=m
CONFIG_DUMMY_IRQ=m
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=m
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=m
CONFIG_ISL29003=m
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
CONFIG_SENSORS_BH1770=m
CONFIG_SENSORS_APDS990X=m
CONFIG_HMC6352=y
CONFIG_DS1682=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=m
# CONFIG_SRAM is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_LEGACY=m
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=m
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y
CONFIG_SENSORS_LIS3_I2C=m

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
CONFIG_ECHO=m
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
CONFIG_BLK_DEV_IDECS=m
# CONFIG_BLK_DEV_DELKIN is not set
CONFIG_BLK_DEV_IDECD=m
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
CONFIG_BLK_DEV_IDETAPE=m
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
# CONFIG_IDE_PROC_FS is not set

#
# IDE chipset support/bugfixes
#
# CONFIG_IDE_GENERIC is not set
CONFIG_BLK_DEV_PLATFORM=y
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_IDEPNP is not set

#
# PCI IDE chipsets support
#
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_CS5535 is not set
# CONFIG_BLK_DEV_CS5536 is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
# CONFIG_BLK_DEV_PIIX is not set
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set

#
# Other IDE chipsets support
#

#
# Note: most of these also require special kernel boot parameters
#
# CONFIG_BLK_DEV_4DRIVES is not set
# CONFIG_BLK_DEV_ALI14XX is not set
CONFIG_BLK_DEV_DTC2278=m
CONFIG_BLK_DEV_HT6560B=m
# CONFIG_BLK_DEV_QD65XX is not set
CONFIG_BLK_DEV_UMC8672=m
# CONFIG_BLK_DEV_IDEDMA is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
# CONFIG_CHR_DEV_ST is not set
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=m
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=y
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=y
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
CONFIG_ISCSI_BOOT_SYSFS=m
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_SCSI_BNX2X_FCOE is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
CONFIG_SCSI_7000FASST=m
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AHA152X=y
CONFIG_SCSI_AHA1542=m
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_IN2000=y
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_UFSHCD is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
CONFIG_LIBFC=m
CONFIG_LIBFCOE=m
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
CONFIG_SCSI_DTC3280=y
# CONFIG_SCSI_EATA is not set
CONFIG_SCSI_FUTURE_DOMAIN=y
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_ISCI is not set
CONFIG_SCSI_GENERIC_NCR5380=m
CONFIG_SCSI_GENERIC_NCR5380_MMIO=y
# CONFIG_SCSI_GENERIC_NCR53C400 is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
CONFIG_SCSI_PPA=m
CONFIG_SCSI_IMM=m
CONFIG_SCSI_IZIP_EPP16=y
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
CONFIG_SCSI_NCR53C406A=y
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_PAS16=y
CONFIG_SCSI_QLOGIC_FAS=m
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_SYM53C416=y
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
CONFIG_SCSI_T128=m
# CONFIG_SCSI_U14_34F is not set
# CONFIG_SCSI_ULTRASTOR is not set
# CONFIG_SCSI_NSP32 is not set
CONFIG_SCSI_DEBUG=y
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_BFA_FC is not set
# CONFIG_SCSI_CHELSIO_FCOE is not set
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
CONFIG_SCSI_DH=m
CONFIG_SCSI_DH_RDAC=m
CONFIG_SCSI_DH_HP_SW=m
CONFIG_SCSI_DH_EMC=m
# CONFIG_SCSI_DH_ALUA is not set
CONFIG_SCSI_OSD_INITIATOR=m
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
CONFIG_SCSI_OSD_DEBUG=y
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
# CONFIG_ATA_VERBOSE_ERROR is not set
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
CONFIG_SATA_AHCI_PLATFORM=y
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_SX4 is not set
# CONFIG_ATA_BMDMA is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_ISAPNP is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PCMCIA=m
CONFIG_PATA_QDI=y
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_WINBOND_VLB is not set

#
# Generic fallback / legacy drivers
#
CONFIG_PATA_LEGACY=y
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
# CONFIG_MD_LINEAR is not set
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=y
# CONFIG_MD_RAID456 is not set
# CONFIG_MD_MULTIPATH is not set
# CONFIG_MD_FAULTY is not set
CONFIG_BCACHE=m
# CONFIG_BCACHE_DEBUG is not set
CONFIG_BCACHE_CLOSURES_DEBUG=y
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=m
CONFIG_DM_DEBUG=y
CONFIG_DM_BUFIO=m
CONFIG_DM_BIO_PRISON=m
CONFIG_DM_PERSISTENT_DATA=m
CONFIG_DM_DEBUG_BLOCK_STACK_TRACING=y
# CONFIG_DM_CRYPT is not set
# CONFIG_DM_SNAPSHOT is not set
CONFIG_DM_THIN_PROVISIONING=m
CONFIG_DM_CACHE=m
# CONFIG_DM_CACHE_MQ is not set
# CONFIG_DM_CACHE_CLEANER is not set
CONFIG_DM_ERA=m
# CONFIG_DM_MIRROR is not set
# CONFIG_DM_RAID is not set
# CONFIG_DM_ZERO is not set
# CONFIG_DM_MULTIPATH is not set
CONFIG_DM_DELAY=m
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=m
# CONFIG_DM_VERITY is not set
# CONFIG_DM_SWITCH is not set
CONFIG_TARGET_CORE=y
CONFIG_TCM_IBLOCK=y
CONFIG_TCM_FILEIO=y
CONFIG_TCM_PSCSI=m
CONFIG_LOOPBACK_TARGET=m
CONFIG_TCM_FC=m
# CONFIG_ISCSI_TARGET is not set
# CONFIG_SBP_TARGET is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
# CONFIG_FIREWIRE_OHCI is not set
# CONFIG_FIREWIRE_SBP2 is not set
CONFIG_FIREWIRE_NET=m
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_MII=m
# CONFIG_NET_CORE is not set
CONFIG_ARCNET=m
CONFIG_ARCNET_1201=m
CONFIG_ARCNET_1051=m
CONFIG_ARCNET_RAW=m
CONFIG_ARCNET_CAP=m
CONFIG_ARCNET_COM90xx=m
CONFIG_ARCNET_COM90xxIO=m
CONFIG_ARCNET_RIM_I=m
CONFIG_ARCNET_COM20020=m
CONFIG_ARCNET_COM20020_ISA=m
# CONFIG_ARCNET_COM20020_PCI is not set
CONFIG_ARCNET_COM20020_CS=m
# CONFIG_ATM_DRIVERS is not set

#
# CAIF transport drivers
#
# CONFIG_CAIF_TTY is not set
CONFIG_CAIF_SPI_SLAVE=y
# CONFIG_CAIF_SPI_SYNC is not set
CONFIG_CAIF_HSI=m
# CONFIG_CAIF_VIRTIO is not set
# CONFIG_VHOST_NET is not set
CONFIG_VHOST_SCSI=m
CONFIG_VHOST_RING=m
CONFIG_VHOST=m

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=m
# CONFIG_NET_DSA_MV88E6060 is not set
CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=y
CONFIG_NET_DSA_MV88E6131=m
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
# CONFIG_ETHERNET is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
CONFIG_AT803X_PHY=y
# CONFIG_AMD_PHY is not set
CONFIG_MARVELL_PHY=m
# CONFIG_DAVICOM_PHY is not set
# CONFIG_QSEMI_PHY is not set
CONFIG_LXT_PHY=y
CONFIG_CICADA_PHY=m
CONFIG_VITESSE_PHY=m
# CONFIG_SMSC_PHY is not set
CONFIG_BROADCOM_PHY=m
CONFIG_BCM7XXX_PHY=y
CONFIG_BCM87XX_PHY=m
CONFIG_ICPLUS_PHY=m
# CONFIG_REALTEK_PHY is not set
CONFIG_NATIONAL_PHY=m
CONFIG_STE10XP=y
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MICREL_PHY is not set
# CONFIG_FIXED_PHY is not set
CONFIG_MDIO_BITBANG=m
# CONFIG_MDIO_GPIO is not set
CONFIG_PLIP=y
CONFIG_PPP=m
CONFIG_PPP_BSDCOMP=m
# CONFIG_PPP_DEFLATE is not set
# CONFIG_PPP_FILTER is not set
# CONFIG_PPP_MPPE is not set
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOATM=m
# CONFIG_PPPOE is not set
CONFIG_PPP_ASYNC=m
# CONFIG_PPP_SYNC_TTY is not set
# CONFIG_SLIP is not set
CONFIG_SLHC=m

#
# Host-side USB support is needed for USB Network Adapter support
#
CONFIG_USB_NET_DRIVERS=m
CONFIG_USB_CATC=m
# CONFIG_USB_KAWETH is not set
CONFIG_USB_PEGASUS=m
CONFIG_USB_RTL8150=m
CONFIG_USB_RTL8152=m
CONFIG_USB_USBNET=m
CONFIG_USB_NET_AX8817X=m
CONFIG_USB_NET_AX88179_178A=m
CONFIG_USB_NET_CDCETHER=m
CONFIG_USB_NET_CDC_EEM=m
CONFIG_USB_NET_CDC_NCM=m
CONFIG_USB_NET_HUAWEI_CDC_NCM=m
CONFIG_USB_NET_CDC_MBIM=m
CONFIG_USB_NET_DM9601=m
CONFIG_USB_NET_SR9700=m
CONFIG_USB_NET_SR9800=m
# CONFIG_USB_NET_SMSC75XX is not set
CONFIG_USB_NET_SMSC95XX=m
CONFIG_USB_NET_GL620A=m
# CONFIG_USB_NET_NET1080 is not set
CONFIG_USB_NET_PLUSB=m
CONFIG_USB_NET_MCS7830=m
CONFIG_USB_NET_RNDIS_HOST=m
CONFIG_USB_NET_CDC_SUBSET=m
CONFIG_USB_ALI_M5632=y
# CONFIG_USB_AN2720 is not set
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
# CONFIG_USB_EPSON2888 is not set
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=m
CONFIG_USB_NET_CX82310_ETH=m
CONFIG_USB_NET_KALMIA=m
CONFIG_USB_NET_QMI_WWAN=m
# CONFIG_USB_NET_INT51X1 is not set
CONFIG_USB_CDC_PHONET=m
CONFIG_USB_IPHETH=m
CONFIG_USB_SIERRA_NET=m
CONFIG_USB_VL600=m
CONFIG_WLAN=y
CONFIG_PCMCIA_RAYCS=m
# CONFIG_PRISM54 is not set
# CONFIG_HOSTAP is not set
CONFIG_WL_TI=y

#
# WiMAX Wireless Broadband devices
#
# CONFIG_WIMAX_I2400M_USB is not set
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
CONFIG_ISDN_CAPI=m
CONFIG_CAPI_TRACE=y
CONFIG_ISDN_CAPI_CAPI20=m
CONFIG_ISDN_CAPI_MIDDLEWARE=y

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
# CONFIG_ISDN_DRV_AVMB1_B1ISA is not set
# CONFIG_ISDN_DRV_AVMB1_B1PCI is not set
CONFIG_ISDN_DRV_AVMB1_T1ISA=m
# CONFIG_ISDN_DRV_AVMB1_B1PCMCIA is not set
# CONFIG_ISDN_DRV_AVMB1_T1PCI is not set
# CONFIG_ISDN_DRV_AVMB1_C4 is not set
# CONFIG_CAPI_EICON is not set
CONFIG_ISDN_DRV_GIGASET=m
CONFIG_GIGASET_CAPI=y
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_BASE=m
# CONFIG_GIGASET_M105 is not set
# CONFIG_GIGASET_M101 is not set
CONFIG_GIGASET_DEBUG=y
# CONFIG_HYSDN is not set
# CONFIG_MISDN is not set

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
CONFIG_INPUT_MOUSEDEV=m
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=m
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
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
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TC3589X is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
CONFIG_INPUT_LEDS=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=m
CONFIG_SERIO_CT82C710=m
CONFIG_SERIO_PARKBD=m
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=m
CONFIG_SERIO_ARC_PS2=m
CONFIG_GAMEPORT=m
CONFIG_GAMEPORT_NS558=m
CONFIG_GAMEPORT_L4=m
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=m
CONFIG_CYCLADES=y
CONFIG_CYZ_INTR=y
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
CONFIG_N_GSM=m
# CONFIG_TRACE_SINK is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_CS=m
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_FOURPORT=m
CONFIG_SERIAL_8250_ACCENT=m
# CONFIG_SERIAL_8250_BOCA is not set
CONFIG_SERIAL_8250_EXAR_ST16C554=m
# CONFIG_SERIAL_8250_HUB6 is not set
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y
CONFIG_SERIAL_8250_DW=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
CONFIG_SERIAL_SCCNXP_CONSOLE=y
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_TIMBERDALE is not set
CONFIG_SERIAL_ALTERA_JTAGUART=m
CONFIG_SERIAL_ALTERA_UART=m
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_PCH_UART is not set
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
CONFIG_SERIAL_FSL_LPUART_CONSOLE=y
CONFIG_SERIAL_MEN_Z135=m
CONFIG_PRINTER=y
CONFIG_LP_CONSOLE=y
# CONFIG_PPDEV is not set
CONFIG_HVC_DRIVER=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_TPM=m
CONFIG_NVRAM=m
# CONFIG_DTLK is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=m
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
CONFIG_IPWIRELESS=m
CONFIG_MWAVE=y
CONFIG_SCx200_GPIO=m
CONFIG_PC8736x_GPIO=m
CONFIG_NSC_GPIO=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=m
CONFIG_TCG_TIS=m
CONFIG_TCG_TIS_I2C_ATMEL=m
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
CONFIG_TCG_INFINEON=m
CONFIG_TCG_ST33_I2C=m
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=m
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
CONFIG_I2C_CBUS_GPIO=m
CONFIG_I2C_DESIGNWARE_CORE=m
CONFIG_I2C_DESIGNWARE_PLATFORM=m
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_GPIO=y
CONFIG_I2C_KEMPLD=m
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=m
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_ROBOTFUZZ_OSIF=m
CONFIG_I2C_TAOS_EVM=m
CONFIG_I2C_TINY_USB=m
# CONFIG_I2C_VIPERBOARD is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_PCA_ISA=y
CONFIG_I2C_CROS_EC_TUNNEL=y
# CONFIG_SCx200_ACB is not set
CONFIG_I2C_STUB=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_SPMI=m
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
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_PARPORT is not set
# CONFIG_PPS_CLIENT_GPIO is not set

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
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_GENERIC_PLATFORM is not set
CONFIG_GPIO_IT8761E=y
CONFIG_GPIO_F7188X=m
CONFIG_GPIO_SCH311X=m
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
CONFIG_GPIO_ARIZONA=m
CONFIG_GPIO_CRYSTAL_COVE=m
CONFIG_GPIO_LP3943=m
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TC3589X=y
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL6040=y
CONFIG_GPIO_ADP5520=y
# CONFIG_GPIO_ADP5588 is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_INTEL_MID is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#
# CONFIG_GPIO_KEMPLD is not set

#
# MODULbus GPIO expanders:
#

#
# USB GPIO expanders:
#
CONFIG_GPIO_VIPERBOARD=m
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=m
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2406=m
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=m
CONFIG_W1_SLAVE_DS2433_CRC=y
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=m
# CONFIG_W1_SLAVE_DS28E04 is not set
# CONFIG_W1_SLAVE_BQ27000 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=m
CONFIG_GENERIC_ADC_BATTERY=m
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=y
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=m
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
CONFIG_BATTERY_DA9030=m
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_BATTERY_MAX17042=y
# CONFIG_CHARGER_88PM860X is not set
# CONFIG_CHARGER_PCF50633 is not set
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_LP8727=m
CONFIG_CHARGER_GPIO=m
# CONFIG_CHARGER_BQ2415X is not set
CONFIG_CHARGER_BQ24190=m
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_SMB347 is not set
CONFIG_CHARGER_TPS65090=y
CONFIG_POWER_RESET=y
CONFIG_POWER_AVS=y
CONFIG_HWMON=m
CONFIG_HWMON_VID=m
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
CONFIG_SENSORS_ABITUGURU3=m
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=m
# CONFIG_SENSORS_ADM1021 is not set
CONFIG_SENSORS_ADM1025=m
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=m
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=m
CONFIG_SENSORS_ADT7410=m
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_APPLESMC=m
CONFIG_SENSORS_ASB100=m
CONFIG_SENSORS_ATXP1=m
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=m
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=m
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_FSCHMD=m
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=m
CONFIG_SENSORS_G760A=m
CONFIG_SENSORS_G762=m
CONFIG_SENSORS_GPIO_FAN=m
CONFIG_SENSORS_HIH6130=m
CONFIG_SENSORS_IIO_HWMON=m
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=m
CONFIG_SENSORS_JC42=m
CONFIG_SENSORS_POWR1220=m
CONFIG_SENSORS_LINEAGE=m
CONFIG_SENSORS_LTC2945=m
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
CONFIG_SENSORS_LTC4222=m
CONFIG_SENSORS_LTC4245=m
CONFIG_SENSORS_LTC4260=m
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_MAX16065=m
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=m
CONFIG_SENSORS_MAX6650=m
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_HTU21 is not set
CONFIG_SENSORS_MCP3021=m
CONFIG_SENSORS_LM63=m
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=m
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=m
CONFIG_SENSORS_LM95241=m
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_NTC_THERMISTOR=m
CONFIG_SENSORS_NCT6683=m
# CONFIG_SENSORS_NCT6775 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT15=m
CONFIG_SENSORS_SHT21=m
CONFIG_SENSORS_SHTC1=m
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=m
# CONFIG_SENSORS_EMC1403 is not set
CONFIG_SENSORS_EMC2103=m
CONFIG_SENSORS_EMC6W201=m
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_SMM665=m
CONFIG_SENSORS_ADC128D818=m
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=m
CONFIG_SENSORS_AMC6821=m
CONFIG_SENSORS_INA209=m
CONFIG_SENSORS_INA2XX=m
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=m
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_VIA_CPUTEMP=m
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=m
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=m
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=m

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=m
CONFIG_X86_PKG_TEMP_THERMAL=m
# CONFIG_ACPI_INT3403_THERMAL is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# Texas Instruments thermal drivers
#
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=m
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_GMAC_CMN=y
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_AXP20X=y
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9063=y
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
CONFIG_INTEL_SOC_PMIC=y
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=m
CONFIG_MFD_88PM800=m
CONFIG_MFD_88PM805=m
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX14577 is not set
CONFIG_MFD_MAX77686=y
# CONFIG_MFD_MAX77693 is not set
CONFIG_MFD_MAX8907=m
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
CONFIG_MFD_VIPERBOARD=m
CONFIG_MFD_RETU=m
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RTSX_USB is not set
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=m
CONFIG_MFD_SM501=m
CONFIG_MFD_SM501_GPIO=y
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
CONFIG_AB3100_OTP=m
# CONFIG_MFD_SYSCON is not set
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=m
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=m
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS65218=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=m
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
# CONFIG_MFD_WM8997 is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=m
CONFIG_REGULATOR_USERSPACE_CONSUMER=m
# CONFIG_REGULATOR_88PM800 is not set
CONFIG_REGULATOR_88PM8607=m
CONFIG_REGULATOR_ACT8865=m
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_AAT2870=y
CONFIG_REGULATOR_AB3100=m
# CONFIG_REGULATOR_AXP20X is not set
CONFIG_REGULATOR_BCM590XX=m
CONFIG_REGULATOR_DA903X=y
# CONFIG_REGULATOR_DA9063 is not set
CONFIG_REGULATOR_DA9210=m
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=m
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=m
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
# CONFIG_REGULATOR_LTC3589 is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=m
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
# CONFIG_REGULATOR_MAX8998 is not set
CONFIG_REGULATOR_MAX77686=m
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=m
CONFIG_REGULATOR_S2MPA01=y
CONFIG_REGULATOR_S2MPS11=m
# CONFIG_REGULATOR_S5M8767 is not set
# CONFIG_REGULATOR_TPS51632 is not set
# CONFIG_REGULATOR_TPS6105X is not set
# CONFIG_REGULATOR_TPS62360 is not set
# CONFIG_REGULATOR_TPS65023 is not set
CONFIG_REGULATOR_TPS6507X=m
# CONFIG_REGULATOR_TPS65090 is not set
# CONFIG_REGULATOR_TPS65217 is not set
CONFIG_REGULATOR_TPS65912=m
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
CONFIG_MEDIA_RC_SUPPORT=y
CONFIG_MEDIA_CONTROLLER=y
CONFIG_VIDEO_DEV=y
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_VMALLOC=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
CONFIG_RC_CORE=y
# CONFIG_RC_MAP is not set
CONFIG_RC_DECODERS=y
CONFIG_LIRC=m
CONFIG_IR_LIRC_CODEC=m
# CONFIG_IR_NEC_DECODER is not set
# CONFIG_IR_RC5_DECODER is not set
CONFIG_IR_RC6_DECODER=m
CONFIG_IR_JVC_DECODER=y
CONFIG_IR_SONY_DECODER=y
CONFIG_IR_SANYO_DECODER=y
CONFIG_IR_SHARP_DECODER=m
CONFIG_IR_MCE_KBD_DECODER=m
# CONFIG_IR_XMP_DECODER is not set
# CONFIG_RC_DEVICES is not set
CONFIG_MEDIA_USB_SUPPORT=y

#
# Webcam devices
#
CONFIG_USB_VIDEO_CLASS=m
# CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV is not set
CONFIG_USB_GSPCA=m
CONFIG_USB_M5602=m
# CONFIG_USB_STV06XX is not set
CONFIG_USB_GL860=m
CONFIG_USB_GSPCA_BENQ=m
CONFIG_USB_GSPCA_CONEX=m
# CONFIG_USB_GSPCA_CPIA1 is not set
CONFIG_USB_GSPCA_DTCS033=m
CONFIG_USB_GSPCA_ETOMS=m
# CONFIG_USB_GSPCA_FINEPIX is not set
CONFIG_USB_GSPCA_JEILINJ=m
CONFIG_USB_GSPCA_JL2005BCD=m
CONFIG_USB_GSPCA_KINECT=m
CONFIG_USB_GSPCA_KONICA=m
CONFIG_USB_GSPCA_MARS=m
# CONFIG_USB_GSPCA_MR97310A is not set
CONFIG_USB_GSPCA_NW80X=m
# CONFIG_USB_GSPCA_OV519 is not set
CONFIG_USB_GSPCA_OV534=m
CONFIG_USB_GSPCA_OV534_9=m
CONFIG_USB_GSPCA_PAC207=m
CONFIG_USB_GSPCA_PAC7302=m
CONFIG_USB_GSPCA_PAC7311=m
CONFIG_USB_GSPCA_SE401=m
# CONFIG_USB_GSPCA_SN9C2028 is not set
# CONFIG_USB_GSPCA_SN9C20X is not set
CONFIG_USB_GSPCA_SONIXB=m
# CONFIG_USB_GSPCA_SONIXJ is not set
CONFIG_USB_GSPCA_SPCA500=m
CONFIG_USB_GSPCA_SPCA501=m
CONFIG_USB_GSPCA_SPCA505=m
CONFIG_USB_GSPCA_SPCA506=m
CONFIG_USB_GSPCA_SPCA508=m
CONFIG_USB_GSPCA_SPCA561=m
# CONFIG_USB_GSPCA_SPCA1528 is not set
CONFIG_USB_GSPCA_SQ905=m
CONFIG_USB_GSPCA_SQ905C=m
CONFIG_USB_GSPCA_SQ930X=m
CONFIG_USB_GSPCA_STK014=m
CONFIG_USB_GSPCA_STK1135=m
CONFIG_USB_GSPCA_STV0680=m
# CONFIG_USB_GSPCA_SUNPLUS is not set
CONFIG_USB_GSPCA_T613=m
# CONFIG_USB_GSPCA_TOPRO is not set
# CONFIG_USB_GSPCA_TV8532 is not set
CONFIG_USB_GSPCA_VC032X=m
CONFIG_USB_GSPCA_VICAM=m
# CONFIG_USB_GSPCA_XIRLINK_CIT is not set
CONFIG_USB_GSPCA_ZC3XX=m
CONFIG_USB_PWC=m
CONFIG_USB_PWC_DEBUG=y
CONFIG_USB_PWC_INPUT_EVDEV=y
# CONFIG_VIDEO_CPIA2 is not set
# CONFIG_USB_ZR364XX is not set
CONFIG_USB_STKWEBCAM=m
CONFIG_USB_S2255=m
CONFIG_VIDEO_USBTV=m

#
# Analog TV USB devices
#
CONFIG_VIDEO_PVRUSB2=m
# CONFIG_VIDEO_PVRUSB2_SYSFS is not set
CONFIG_VIDEO_HDPVR=m
# CONFIG_VIDEO_USBVISION is not set
# CONFIG_VIDEO_STK1160_COMMON is not set
# CONFIG_VIDEO_GO7007 is not set

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_CX231XX=m
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_CX231XX_ALSA=m
CONFIG_VIDEO_TM6000=m
# CONFIG_VIDEO_TM6000_ALSA is not set

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=m
CONFIG_VIDEO_EM28XX_V4L2=m
CONFIG_VIDEO_EM28XX_ALSA=m
# CONFIG_VIDEO_EM28XX_RC is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_V4L_TEST_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
# CONFIG_MEDIA_PARPORT_SUPPORT is not set
# CONFIG_RADIO_ADAPTERS is not set
CONFIG_VIDEO_CX2341X=m
CONFIG_VIDEO_TVEEPROM=m
# CONFIG_CYPRESS_FIRMWARE is not set

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y
CONFIG_VIDEO_IR_I2C=y

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_MSP3400=m
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_WM8775=m

#
# RDS decoders
#

#
# Video decoders
#
CONFIG_VIDEO_SAA711X=m
CONFIG_VIDEO_TVP5150=m

#
# Video and audio decoders
#
CONFIG_VIDEO_CX25840=m

#
# Video encoders
#

#
# Camera sensor devices
#
CONFIG_VIDEO_MT9V011=m

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
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

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
CONFIG_DRM=m
CONFIG_DRM_USB=m
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=m
CONFIG_DRM_I2C_SIL164=m
CONFIG_DRM_I2C_NXP_TDA998X=m
# CONFIG_DRM_PTN3460 is not set
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
CONFIG_DRM_UDL=m
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set

#
# Frame buffer Devices
#
CONFIG_FB=m
CONFIG_FIRMWARE_EDID=y
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=m
CONFIG_FB_CFB_COPYAREA=m
CONFIG_FB_CFB_IMAGEBLIT=m
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=m
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
CONFIG_FB_ARC=m
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
CONFIG_FB_N411=m
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=m
CONFIG_FB_S1D13XXX=m
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
# CONFIG_FB_GEODE is not set
CONFIG_FB_SM501=m
CONFIG_FB_SMSCUFX=m
CONFIG_FB_UDL=m
CONFIG_FB_VIRTUAL=m
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_FB_AUO_K190X=m
CONFIG_FB_AUO_K1900=m
# CONFIG_FB_AUO_K1901 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=m
CONFIG_BACKLIGHT_CLASS_DEVICE=m
CONFIG_BACKLIGHT_GENERIC=m
# CONFIG_BACKLIGHT_PWM is not set
# CONFIG_BACKLIGHT_DA903X is not set
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=m
CONFIG_BACKLIGHT_ADP5520=m
CONFIG_BACKLIGHT_ADP8860=m
CONFIG_BACKLIGHT_ADP8870=m
CONFIG_BACKLIGHT_88PM860X=m
CONFIG_BACKLIGHT_PCF50633=m
CONFIG_BACKLIGHT_AAT2870=m
CONFIG_BACKLIGHT_LM3630A=m
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=m
CONFIG_BACKLIGHT_TPS65217=m
CONFIG_BACKLIGHT_GPIO=m
CONFIG_BACKLIGHT_LV5207LP=m
CONFIG_BACKLIGHT_BD6107=m
# CONFIG_VGASTATE is not set
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
# CONFIG_MDA_CONSOLE is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=m
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
# CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
# CONFIG_LOGO_LINUX_CLUT224 is not set
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
# CONFIG_SND_SEQUENCER is not set
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=m
# CONFIG_SND_PCM_OSS is not set
CONFIG_SND_HRTIMER=m
# CONFIG_SND_DYNAMIC_MINORS is not set
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_VERBOSE_PRINTK=y
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
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=m
CONFIG_SND_DUMMY=m
CONFIG_SND_ALOOP=m
CONFIG_SND_MTPAV=m
# CONFIG_SND_MTS64 is not set
CONFIG_SND_SERIAL_U16550=m
CONFIG_SND_MPU401=m
CONFIG_SND_PORTMAN2X4=m
CONFIG_SND_WSS_LIB=m
CONFIG_SND_SB_COMMON=m
CONFIG_SND_SB8_DSP=m
CONFIG_SND_SB16_DSP=m
CONFIG_SND_ISA=y
CONFIG_SND_ADLIB=m
# CONFIG_SND_AD1816A is not set
CONFIG_SND_AD1848=m
CONFIG_SND_ALS100=m
# CONFIG_SND_AZT1605 is not set
CONFIG_SND_AZT2316=m
CONFIG_SND_AZT2320=m
CONFIG_SND_CMI8328=m
CONFIG_SND_CMI8330=m
CONFIG_SND_CS4231=m
# CONFIG_SND_CS4236 is not set
CONFIG_SND_ES1688=m
# CONFIG_SND_ES18XX is not set
CONFIG_SND_SC6000=m
CONFIG_SND_GUSCLASSIC=m
CONFIG_SND_GUSEXTREME=m
CONFIG_SND_GUSMAX=m
CONFIG_SND_INTERWAVE=m
CONFIG_SND_INTERWAVE_STB=m
CONFIG_SND_JAZZ16=m
CONFIG_SND_OPL3SA2=m
# CONFIG_SND_OPTI92X_AD1848 is not set
CONFIG_SND_OPTI92X_CS4231=m
CONFIG_SND_OPTI93X=m
# CONFIG_SND_MIRO is not set
# CONFIG_SND_SB8 is not set
CONFIG_SND_SB16=m
CONFIG_SND_SBAWE=m
# CONFIG_SND_SB16_CSP is not set
CONFIG_SND_SSCAPE=m
# CONFIG_SND_WAVEFRONT is not set
CONFIG_SND_MSND_PINNACLE=m
CONFIG_SND_MSND_CLASSIC=m
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CS5530 is not set
# CONFIG_SND_CS5535AUDIO is not set
# CONFIG_SND_CTXFI is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SIS7019 is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
# CONFIG_SND_HDA_INTEL is not set
CONFIG_SND_USB=y
# CONFIG_SND_USB_AUDIO is not set
# CONFIG_SND_USB_UA101 is not set
# CONFIG_SND_USB_USX2Y is not set
# CONFIG_SND_USB_CAIAQ is not set
CONFIG_SND_USB_US122L=m
CONFIG_SND_USB_6FIRE=m
CONFIG_SND_USB_HIFACE=m
CONFIG_SND_BCD2000=m
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=m
CONFIG_SND_DICE=m
# CONFIG_SND_FIREWIRE_SPEAKERS is not set
CONFIG_SND_ISIGHT=m
CONFIG_SND_SCS1X=m
CONFIG_SND_FIREWORKS=m
CONFIG_SND_BEBOB=m
# CONFIG_SND_PCMCIA is not set
# CONFIG_SND_SOC is not set
CONFIG_SOUND_PRIME=m
# CONFIG_SOUND_MSNDCLAS is not set
# CONFIG_SOUND_MSNDPIN is not set
CONFIG_SOUND_OSS=m
# CONFIG_SOUND_TRACEINIT is not set
# CONFIG_SOUND_DMAP is not set
CONFIG_SOUND_VMIDI=m
# CONFIG_SOUND_TRIX is not set
CONFIG_SOUND_MSS=m
# CONFIG_SOUND_MPU401 is not set
CONFIG_SOUND_PAS=m
CONFIG_SOUND_PSS=m
CONFIG_PSS_MIXER=y
# CONFIG_PSS_HAVE_BOOT is not set
CONFIG_SOUND_SB=m
CONFIG_SOUND_YM3812=m
CONFIG_SOUND_UART6850=m
CONFIG_SOUND_AEDSP16=m
CONFIG_SC6600=y
# CONFIG_SC6600_JOY is not set
CONFIG_SC6600_CDROM=4
CONFIG_SC6600_CDROMBASE=0
CONFIG_SOUND_KAHLUA=m

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
CONFIG_UHID=y
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_APPLEIR=m
CONFIG_HID_AUREAL=m
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_PRODIKEYS=m
CONFIG_HID_CP2112=m
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=m
CONFIG_HID_ELECOM=m
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
CONFIG_HID_HOLTEK=m
# CONFIG_HOLTEK_FF is not set
CONFIG_HID_GT683R=m
CONFIG_HID_HUION=m
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=m
CONFIG_HID_UCLOGIC=y
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=m
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
# CONFIG_HID_LENOVO is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=m
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_LOGIG940_FF=y
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_NTRIG=m
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=m
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PICOLCD_CIR=y
CONFIG_HID_PRIMAX=m
CONFIG_HID_ROCCAT=m
CONFIG_HID_SAITEK=m
# CONFIG_HID_SAMSUNG is not set
CONFIG_HID_SONY=m
# CONFIG_SONY_FF is not set
CONFIG_HID_SPEEDLINK=m
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
CONFIG_HID_RMI=m
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
# CONFIG_HID_SMARTJOYPLUS is not set
CONFIG_HID_TIVO=y
# CONFIG_HID_TOPSEED is not set
CONFIG_HID_THINGM=m
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_WACOM=y
# CONFIG_HID_WIIMOTE is not set
CONFIG_HID_XINMO=y
# CONFIG_HID_ZEROPLUS is not set
CONFIG_HID_ZYDACRON=y
CONFIG_HID_SENSOR_HUB=y

#
# USB HID support
#
CONFIG_USB_HID=m
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=m
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=m
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_DYNAMIC_MINORS=y
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_FSM is not set
CONFIG_USB_MON=m
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=m
# CONFIG_USB_XHCI_HCD is not set
# CONFIG_USB_EHCI_HCD is not set
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=m
CONFIG_USB_ISP1760_HCD=m
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FUSBH200_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_U132_HCD=m
CONFIG_USB_SL811_HCD=m
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=m
# CONFIG_USB_R8A66597_HCD is not set
CONFIG_USB_HCD_BCMA=m
# CONFIG_USB_HCD_TEST_MODE is not set
# CONFIG_USB_RENESAS_USBHS is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
# CONFIG_USB_PRINTER is not set
CONFIG_USB_WDM=m
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
# CONFIG_USB_STORAGE is not set

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
# CONFIG_USB_MICROTEK is not set
CONFIG_USBIP_CORE=m
CONFIG_USBIP_VHCI_HCD=m
CONFIG_USBIP_HOST=m
CONFIG_USBIP_DEBUG=y
CONFIG_USB_MUSB_HDRC=m
# CONFIG_USB_MUSB_HOST is not set
# CONFIG_USB_MUSB_GADGET is not set
CONFIG_USB_MUSB_DUAL_ROLE=y
CONFIG_USB_MUSB_TUSB6010=m
CONFIG_USB_MUSB_UX500=m
CONFIG_USB_UX500_DMA=y
# CONFIG_MUSB_PIO_ONLY is not set
CONFIG_USB_DWC3=m
CONFIG_USB_DWC3_HOST=y
# CONFIG_USB_DWC3_GADGET is not set
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=m

#
# Debugging features
#
CONFIG_USB_DWC3_DEBUG=y
# CONFIG_USB_DWC3_VERBOSE is not set
CONFIG_DWC3_HOST_USB3_LPM_ENABLE=y
CONFIG_USB_DWC2=y
CONFIG_USB_DWC2_HOST=m
# CONFIG_USB_DWC2_PLATFORM is not set
CONFIG_USB_DWC2_PCI=y

#
# Gadget mode requires USB Gadget support to be enabled
#
CONFIG_USB_DWC2_PERIPHERAL=m
# CONFIG_USB_DWC2_DEBUG is not set
CONFIG_USB_DWC2_TRACK_MISSED_SOFS=y
CONFIG_USB_CHIPIDEA=m
CONFIG_USB_CHIPIDEA_UDC=y
# CONFIG_USB_CHIPIDEA_DEBUG is not set

#
# USB port drivers
#
CONFIG_USB_USS720=m
CONFIG_USB_SERIAL=m
CONFIG_USB_SERIAL_GENERIC=y
CONFIG_USB_SERIAL_SIMPLE=m
# CONFIG_USB_SERIAL_AIRCABLE is not set
# CONFIG_USB_SERIAL_ARK3116 is not set
CONFIG_USB_SERIAL_BELKIN=m
CONFIG_USB_SERIAL_CH341=m
# CONFIG_USB_SERIAL_WHITEHEAT is not set
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
CONFIG_USB_SERIAL_CP210X=m
CONFIG_USB_SERIAL_CYPRESS_M8=m
# CONFIG_USB_SERIAL_EMPEG is not set
# CONFIG_USB_SERIAL_FTDI_SIO is not set
# CONFIG_USB_SERIAL_VISOR is not set
CONFIG_USB_SERIAL_IPAQ=m
CONFIG_USB_SERIAL_IR=m
CONFIG_USB_SERIAL_EDGEPORT=m
CONFIG_USB_SERIAL_EDGEPORT_TI=m
CONFIG_USB_SERIAL_F81232=m
CONFIG_USB_SERIAL_GARMIN=m
# CONFIG_USB_SERIAL_IPW is not set
CONFIG_USB_SERIAL_IUU=m
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
# CONFIG_USB_SERIAL_KEYSPAN is not set
CONFIG_USB_SERIAL_KLSI=m
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
CONFIG_USB_SERIAL_MCT_U232=m
CONFIG_USB_SERIAL_METRO=m
CONFIG_USB_SERIAL_MOS7720=m
# CONFIG_USB_SERIAL_MOS7715_PARPORT is not set
CONFIG_USB_SERIAL_MOS7840=m
CONFIG_USB_SERIAL_MXUPORT=m
# CONFIG_USB_SERIAL_NAVMAN is not set
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_OTI6858=m
# CONFIG_USB_SERIAL_QCAUX is not set
CONFIG_USB_SERIAL_QUALCOMM=m
# CONFIG_USB_SERIAL_SPCP8X5 is not set
CONFIG_USB_SERIAL_SAFE=m
CONFIG_USB_SERIAL_SAFE_PADDED=y
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
CONFIG_USB_SERIAL_SYMBOL=m
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_SERIAL_WWAN=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
CONFIG_USB_SERIAL_OPTICON=m
CONFIG_USB_SERIAL_XSENS_MT=m
# CONFIG_USB_SERIAL_WISHBONE is not set
CONFIG_USB_SERIAL_ZTE=m
CONFIG_USB_SERIAL_SSU100=m
CONFIG_USB_SERIAL_QT2=m
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
# CONFIG_USB_ADUTUX is not set
CONFIG_USB_SEVSEG=m
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
CONFIG_USB_LCD=m
CONFIG_USB_LED=m
# CONFIG_USB_CYPRESS_CY7C63 is not set
CONFIG_USB_CYTHERM=m
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=m
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
CONFIG_USB_LD=m
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
CONFIG_USB_TEST=m
CONFIG_USB_EHSET_TEST_FIXTURE=m
CONFIG_USB_ISIGHTFW=m
CONFIG_USB_YUREX=m
CONFIG_USB_EZUSB_FX2=m
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_LINK_LAYER_TEST=m
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
CONFIG_USB_UEAGLEATM=m
CONFIG_USB_XUSBATM=m

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_SAMSUNG_USBPHY=y
CONFIG_SAMSUNG_USB2PHY=y
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_TAHVO_USB=m
# CONFIG_TAHVO_USB_HOST_BY_DEFAULT is not set
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_GADGET=m
CONFIG_USB_GADGET_DEBUG=y
CONFIG_USB_GADGET_VERBOSE=y
CONFIG_USB_GADGET_DEBUG_FILES=y
CONFIG_USB_GADGET_DEBUG_FS=y
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_FOTG210_UDC is not set
CONFIG_USB_GR_UDC=m
CONFIG_USB_R8A66597=m
CONFIG_USB_PXA27X=m
CONFIG_USB_MV_UDC=m
# CONFIG_USB_MV_U3D is not set
CONFIG_USB_M66592=m
# CONFIG_USB_AMD5536UDC is not set
CONFIG_USB_NET2272=m
# CONFIG_USB_NET2272_DMA is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_LIBCOMPOSITE=m
CONFIG_USB_F_ACM=m
CONFIG_USB_F_SS_LB=m
CONFIG_USB_U_SERIAL=m
CONFIG_USB_U_ETHER=m
CONFIG_USB_F_SERIAL=m
CONFIG_USB_F_OBEX=m
CONFIG_USB_F_NCM=m
CONFIG_USB_F_ECM=m
CONFIG_USB_F_PHONET=m
CONFIG_USB_F_EEM=m
CONFIG_USB_F_SUBSET=m
CONFIG_USB_F_RNDIS=m
CONFIG_USB_F_MASS_STORAGE=m
CONFIG_USB_CONFIGFS=m
CONFIG_USB_CONFIGFS_SERIAL=y
# CONFIG_USB_CONFIGFS_ACM is not set
# CONFIG_USB_CONFIGFS_OBEX is not set
CONFIG_USB_CONFIGFS_NCM=y
# CONFIG_USB_CONFIGFS_ECM is not set
# CONFIG_USB_CONFIGFS_ECM_SUBSET is not set
CONFIG_USB_CONFIGFS_RNDIS=y
# CONFIG_USB_CONFIGFS_EEM is not set
# CONFIG_USB_CONFIGFS_PHONET is not set
# CONFIG_USB_CONFIGFS_MASS_STORAGE is not set
# CONFIG_USB_CONFIGFS_F_LB_SS is not set
# CONFIG_USB_CONFIGFS_F_FS is not set
CONFIG_USB_ZERO=m
# CONFIG_USB_AUDIO is not set
CONFIG_USB_ETH=m
CONFIG_USB_ETH_RNDIS=y
CONFIG_USB_ETH_EEM=y
# CONFIG_USB_G_NCM is not set
CONFIG_USB_GADGETFS=m
# CONFIG_USB_FUNCTIONFS is not set
CONFIG_USB_MASS_STORAGE=m
CONFIG_USB_GADGET_TARGET=m
CONFIG_USB_G_SERIAL=m
CONFIG_USB_MIDI_GADGET=m
CONFIG_USB_G_PRINTER=m
CONFIG_USB_CDC_COMPOSITE=m
CONFIG_USB_G_NOKIA=m
CONFIG_USB_G_ACM_MS=m
CONFIG_USB_G_MULTI=m
CONFIG_USB_G_MULTI_RNDIS=y
CONFIG_USB_G_MULTI_CDC=y
CONFIG_USB_G_HID=m
CONFIG_USB_G_DBGP=m
CONFIG_USB_G_DBGP_PRINTK=y
# CONFIG_USB_G_DBGP_SERIAL is not set
# CONFIG_USB_G_WEBCAM is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_88PM860X is not set
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_NET48XX=m
CONFIG_LEDS_WRAP=m
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_CLEVO_MAIL=m
CONFIG_LEDS_PCA955X=m
CONFIG_LEDS_PCA963X=m
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_PWM=m
CONFIG_LEDS_REGULATOR=m
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
# CONFIG_LEDS_ADP5520 is not set
CONFIG_LEDS_TCA6507=m
CONFIG_LEDS_LM355x=m
CONFIG_LEDS_OT200=m

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=m

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
# CONFIG_LEDS_TRIGGER_CAMERA is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=m
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=m
CONFIG_UIO_DMEM_GENIRQ=m
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
CONFIG_STAGING=y
# CONFIG_ET131X is not set
# CONFIG_SLICOSS is not set
CONFIG_COMEDI=m
# CONFIG_COMEDI_DEBUG is not set
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
# CONFIG_COMEDI_MISC_DRIVERS is not set
# CONFIG_COMEDI_ISA_DRIVERS is not set
# CONFIG_COMEDI_PCI_DRIVERS is not set
# CONFIG_COMEDI_PCMCIA_DRIVERS is not set
CONFIG_COMEDI_USB_DRIVERS=y
CONFIG_COMEDI_DT9812=m
# CONFIG_COMEDI_USBDUX is not set
CONFIG_COMEDI_USBDUXFAST=m
CONFIG_COMEDI_USBDUXSIGMA=m
CONFIG_COMEDI_VMK80XX=m
CONFIG_COMEDI_8255=m
CONFIG_COMEDI_FC=m
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
# CONFIG_RTL8192U is not set
CONFIG_RTLLIB=m
CONFIG_RTLLIB_CRYPTO_CCMP=m
CONFIG_RTLLIB_CRYPTO_TKIP=m
CONFIG_RTLLIB_CRYPTO_WEP=m
# CONFIG_RTL8192E is not set
# CONFIG_R8712U is not set
CONFIG_R8188EU=m
CONFIG_88EU_AP_MODE=y
# CONFIG_RTS5208 is not set
CONFIG_LINE6_USB=m
# CONFIG_LINE6_USB_IMPULSE_RESPONSE is not set
# CONFIG_VT6655 is not set

#
# IIO staging drivers
#

#
# Accelerometers
#

#
# Analog to digital converters
#
CONFIG_AD7606=m
# CONFIG_AD7606_IFACE_PARALLEL is not set

#
# Analog digital bi-direction converters
#
# CONFIG_ADT7316 is not set

#
# Capacitance to digital converters
#
CONFIG_AD7150=m
CONFIG_AD7152=m
# CONFIG_AD7746 is not set

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
# CONFIG_SENSORS_ISL29018 is not set
# CONFIG_SENSORS_ISL29028 is not set
CONFIG_TSL2583=m
# CONFIG_TSL2x7x is not set

#
# Magnetometer sensors
#
CONFIG_SENSORS_HMC5843=m
CONFIG_SENSORS_HMC5843_I2C=m

#
# Active energy metering IC
#
CONFIG_ADE7854=m
# CONFIG_ADE7854_I2C is not set

#
# Resolver to digital converters
#

#
# Triggers - standalone
#
# CONFIG_IIO_SIMPLE_DUMMY is not set
# CONFIG_FB_XGI is not set
# CONFIG_BCM_WIMAX is not set
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
CONFIG_SPEAKUP=y
CONFIG_SPEAKUP_SYNTH_ACNTSA=y
CONFIG_SPEAKUP_SYNTH_ACNTPC=m
# CONFIG_SPEAKUP_SYNTH_APOLLO is not set
# CONFIG_SPEAKUP_SYNTH_AUDPTR is not set
CONFIG_SPEAKUP_SYNTH_BNS=y
CONFIG_SPEAKUP_SYNTH_DECTLK=m
CONFIG_SPEAKUP_SYNTH_DECEXT=m
# CONFIG_SPEAKUP_SYNTH_DECPC is not set
CONFIG_SPEAKUP_SYNTH_DTLK=m
CONFIG_SPEAKUP_SYNTH_KEYPC=y
# CONFIG_SPEAKUP_SYNTH_LTLK is not set
CONFIG_SPEAKUP_SYNTH_SOFT=m
CONFIG_SPEAKUP_SYNTH_SPKOUT=m
CONFIG_SPEAKUP_SYNTH_TXPRT=y
CONFIG_SPEAKUP_SYNTH_DUMMY=y
CONFIG_TOUCHSCREEN_CLEARPAD_TM1217=m
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_USB_WPAN_HCD is not set
# CONFIG_WIMAX_GDM72XX is not set
CONFIG_LTE_GDM724X=m
CONFIG_FIREWIRE_SERIAL=m
CONFIG_FWTTY_MAX_TOTAL_PORTS=64
CONFIG_FWTTY_MAX_CARD_PORTS=32
CONFIG_LUSTRE_FS=m
CONFIG_LUSTRE_OBD_MAX_IOCTL_BUFFER=8192
CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK=y
CONFIG_LUSTRE_LLITE_LLOOP=m
CONFIG_LNET=m
CONFIG_LNET_MAX_PAYLOAD=1048576
# CONFIG_LNET_SELFTEST is not set
# CONFIG_XILLYBUS is not set
# CONFIG_DGNC is not set
# CONFIG_DGAP is not set
CONFIG_GS_FPGABOOT=m
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_DELL_SMO8800 is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=m
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_CHROME_PLATFORMS is not set

#
# SOC (System On Chip) specific Drivers
#

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
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=m
CONFIG_EXTCON_GPIO=m
CONFIG_EXTCON_SM5502=m
# CONFIG_MEMORY is not set
CONFIG_IIO=m
CONFIG_IIO_BUFFER=y
# CONFIG_IIO_BUFFER_CB is not set
CONFIG_IIO_KFIFO_BUF=m
CONFIG_IIO_TRIGGERED_BUFFER=m
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
CONFIG_BMA180=m
CONFIG_HID_SENSOR_ACCEL_3D=m
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
CONFIG_MMA8452=m
CONFIG_KXCJK1013=m

#
# Analog to digital converters
#
CONFIG_AD7291=m
# CONFIG_AD799X is not set
CONFIG_MAX1363=m
# CONFIG_MCP3422 is not set
# CONFIG_MEN_Z188_ADC is not set
CONFIG_NAU7802=m
CONFIG_TI_ADC081C=m
CONFIG_TI_AM335X_ADC=m
CONFIG_VIPERBOARD_ADC=m

#
# Amplifiers
#

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=m
CONFIG_HID_SENSOR_IIO_TRIGGER=m
CONFIG_IIO_ST_SENSORS_I2C=m
CONFIG_IIO_ST_SENSORS_CORE=m

#
# Digital to analog converters
#
# CONFIG_AD5064 is not set
CONFIG_AD5380=m
CONFIG_AD5446=m
CONFIG_MAX517=m
CONFIG_MCP4725=m

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
# CONFIG_HID_SENSOR_GYRO_3D is not set
CONFIG_IIO_ST_GYRO_3AXIS=m
CONFIG_IIO_ST_GYRO_I2C_3AXIS=m
CONFIG_ITG3200=m

#
# Humidity sensors
#
CONFIG_DHT11=m
CONFIG_SI7005=m

#
# Inertial measurement units
#
# CONFIG_INV_MPU6050_IIO is not set

#
# Light sensors
#
CONFIG_ADJD_S311=m
CONFIG_APDS9300=m
# CONFIG_CM32181 is not set
CONFIG_CM36651=m
CONFIG_GP2AP020A00F=m
CONFIG_ISL29125=m
CONFIG_HID_SENSOR_ALS=m
# CONFIG_HID_SENSOR_PROX is not set
CONFIG_LTR501=m
CONFIG_TCS3414=m
CONFIG_TCS3472=m
# CONFIG_SENSORS_TSL2563 is not set
CONFIG_TSL4531=m
CONFIG_VCNL4000=m

#
# Magnetometer sensors
#
# CONFIG_AK8975 is not set
# CONFIG_AK09911 is not set
CONFIG_MAG3110=m
# CONFIG_HID_SENSOR_MAGNETOMETER_3D is not set
CONFIG_IIO_ST_MAGN_3AXIS=m
CONFIG_IIO_ST_MAGN_I2C_3AXIS=m

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=m
CONFIG_HID_SENSOR_DEVICE_ROTATION=m

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=m
CONFIG_IIO_SYSFS_TRIGGER=m

#
# Pressure sensors
#
CONFIG_HID_SENSOR_PRESS=m
CONFIG_MPL115=m
# CONFIG_MPL3115 is not set
CONFIG_IIO_ST_PRESS=m
CONFIG_IIO_ST_PRESS_I2C=m
CONFIG_T5403=m

#
# Lightning sensors
#

#
# Temperature sensors
#
CONFIG_MLX90614=m
CONFIG_TMP006=m
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_LP3943=m
# CONFIG_PWM_LPSS is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=m
# CONFIG_PHY_SAMSUNG_USB2 is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y
CONFIG_MCB=m
# CONFIG_MCB_PCI is not set
# CONFIG_THUNDERBOLT is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
# CONFIG_DMIID is not set
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
# CONFIG_GOOGLE_MEMCONSOLE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=m
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
# CONFIG_EXT2_FS_SECURITY is not set
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
# CONFIG_EXT3_FS_XATTR is not set
# CONFIG_EXT4_FS is not set
CONFIG_JBD=y
CONFIG_JBD_DEBUG=y
CONFIG_JBD2=m
CONFIG_JBD2_DEBUG=y
CONFIG_FS_MBCACHE=m
CONFIG_REISERFS_FS=m
CONFIG_REISERFS_CHECK=y
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=m
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
CONFIG_XFS_DEBUG=y
CONFIG_GFS2_FS=m
CONFIG_OCFS2_FS=m
CONFIG_OCFS2_FS_O2CB=m
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
# CONFIG_BTRFS_FS is not set
CONFIG_NILFS2_FS=m
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=m
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=m
CONFIG_CUSE=m

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
CONFIG_FSCACHE_HISTOGRAM=y
CONFIG_FSCACHE_DEBUG=y
CONFIG_FSCACHE_OBJECT_LIST=y
# CONFIG_CACHEFILES is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ADFS_FS=y
CONFIG_ADFS_FS_RW=y
# CONFIG_AFFS_FS is not set
CONFIG_ECRYPT_FS=m
CONFIG_ECRYPT_FS_MESSAGING=y
CONFIG_HFS_FS=y
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
CONFIG_EFS_FS=y
CONFIG_JFFS2_FS=m
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
# CONFIG_JFFS2_SUMMARY is not set
CONFIG_JFFS2_FS_XATTR=y
# CONFIG_JFFS2_FS_POSIX_ACL is not set
# CONFIG_JFFS2_FS_SECURITY is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
# CONFIG_UBIFS_FS is not set
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
# CONFIG_SQUASHFS_DECOMP_SINGLE is not set
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU=y
# CONFIG_SQUASHFS_XATTR is not set
# CONFIG_SQUASHFS_ZLIB is not set
# CONFIG_SQUASHFS_LZO is not set
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
CONFIG_SQUASHFS_EMBEDDED=y
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=m
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=y
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_BLOCK=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_RAM is not set
# CONFIG_SYSV_FS is not set
CONFIG_UFS_FS=m
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_F2FS_FS=y
CONFIG_F2FS_STAT_FS=y
# CONFIG_F2FS_FS_XATTR is not set
CONFIG_F2FS_CHECK_FS=y
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=m
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=m
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=y
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=m
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=m
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=m
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=m
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
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
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
# CONFIG_DEBUG_OBJECTS_FREE is not set
CONFIG_DEBUG_OBJECTS_TIMERS=y
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_DEBUG_SLAB is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=m
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_DEBUG_HIGHMEM=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_CPU_STALL_INFO=y
# CONFIG_RCU_TRACE is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
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
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
# CONFIG_FUNCTION_TRACER is not set
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
# CONFIG_BLK_DEV_IO_TRACE is not set
# CONFIG_UPROBE_EVENT is not set
# CONFIG_PROBE_EVENTS is not set
CONFIG_FTRACE_SELFTEST=y
CONFIG_FTRACE_STARTUP_TEST=y
# CONFIG_EVENT_TRACE_TEST_SYSCALLS is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACEPOINT_BENCHMARK=y
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
CONFIG_LKDTM=y
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=m
CONFIG_INTERVAL_TREE_TEST=m
# CONFIG_PERCPU_TEST is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=y
CONFIG_TEST_RHASHTABLE=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_MODULE=m
# CONFIG_TEST_USER_COPY is not set
CONFIG_TEST_BPF=m
# CONFIG_TEST_FIRMWARE is not set
CONFIG_TEST_UDELAY=m
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP=y
# CONFIG_DEBUG_RODATA is not set
CONFIG_DEBUG_SET_MODULE_RONX=y
CONFIG_DEBUG_NX_TEST=m
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_STRESS is not set
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
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_STATIC_CPU_HAS=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=m
CONFIG_ENCRYPTED_KEYS=m
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
CONFIG_SECURITY_PATH=y
CONFIG_SECURITY_SMACK=y
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_IMA is not set
# CONFIG_EVM is not set
CONFIG_DEFAULT_SECURITY_SMACK=y
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="smack"
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
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=m
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=m
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=m

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
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_VMAC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=m
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_CRC32=m
CONFIG_CRYPTO_CRC32_PCLMUL=m
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=m
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=m
# CONFIG_CRYPTO_CAST5 is not set
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=m
# CONFIG_CRYPTO_SALSA20_586 is not set
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_SERPENT_SSE2_586=m
CONFIG_CRYPTO_TEA=m
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_TWOFISH_586 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
# CONFIG_CRYPTO_ZLIB is not set
CONFIG_CRYPTO_LZO=m
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=m

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
# CONFIG_CRYPTO_DRBG_HMAC is not set
CONFIG_CRYPTO_DRBG_HASH=y
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_USER_API=m
# CONFIG_CRYPTO_USER_API_HASH is not set
CONFIG_CRYPTO_USER_API_SKCIPHER=m
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_GEODE is not set
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y
CONFIG_PKCS7_TEST_KEY=m
CONFIG_SIGNED_PE_FILE_VERIFICATION=y
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
CONFIG_LGUEST=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
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
CONFIG_CRC7=y
CONFIG_LIBCRC32C=m
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4HC_COMPRESS=m
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
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=m
CONFIG_BCH_CONST_PARAMS=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=m
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=m
CONFIG_FONTS=y
# CONFIG_FONT_8x8 is not set
CONFIG_FONT_8x16=y
CONFIG_FONT_6x11=y
CONFIG_FONT_7x14=y
CONFIG_FONT_PEARL_8x8=y
# CONFIG_FONT_ACORN_8x8 is not set
CONFIG_FONT_MINI_4x6=y
CONFIG_FONT_SUN8x16=y
# CONFIG_FONT_SUN12x22 is not set
CONFIG_FONT_10x18=y
CONFIG_ARCH_HAS_SG_CHAIN=y

--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--cNdxnHkX5QqsyA0e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
