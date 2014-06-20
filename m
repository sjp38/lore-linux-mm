Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3826B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 06:27:16 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so2953172pac.19
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 03:27:16 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id au5si9165916pbc.93.2014.06.20.03.27.13
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 03:27:15 -0700 (PDT)
Date: Fri, 20 Jun 2014 18:27:04 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [memcontrol] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28
 res_counter_uncharge_locked()
Message-ID: <20140620102704.GA8912@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="yrj/dFKFPuw6o+aM"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jet Chen <jet.chen@intel.com>, Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit ddc5bfec501f4be3f9e89084c2db270c0c45d1d6
Author:     Johannes Weiner <hannes@cmpxchg.org>
AuthorDate: Fri Jun 20 10:27:58 2014 +1000
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Fri Jun 20 10:27:58 2014 +1000

    mm: memcontrol: rewrite uncharge API
    
    The memcg uncharging code that is involved towards the end of a page's
    lifetime - truncation, reclaim, swapout, migration - is impressively
    complicated and fragile.
    
    Because anonymous and file pages were always charged before they had their
    page->mapping established, uncharges had to happen when the page type
    could still be known from the context; as in unmap for anonymous, page
    cache removal for file and shmem pages, and swap cache truncation for swap
    pages.  However, these operations happen well before the page is actually
    freed, and so a lot of synchronization is necessary:
    
    - Charging, uncharging, page migration, and charge migration all need
      to take a per-page bit spinlock as they could race with uncharging.
    
    - Swap cache truncation happens during both swap-in and swap-out, and
      possibly repeatedly before the page is actually freed.  This means
      that the memcg swapout code is called from many contexts that make
      no sense and it has to figure out the direction from page state to
      make sure memory and memory+swap are always correctly charged.
    
    - On page migration, the old page might be unmapped but then reused,
      so memcg code has to prevent untimely uncharging in that case.
      Because this code - which should be a simple charge transfer - is so
      special-cased, it is not reusable for replace_page_cache().
    
    But now that charged pages always have a page->mapping, introduce
    mem_cgroup_uncharge(), which is called after the final put_page(), when we
    know for sure that nobody is looking at the page anymore.
    
    For page migration, introduce mem_cgroup_migrate(), which is called after
    the migration is successful and the new page is fully rmapped.  Because
    the old page is no longer uncharged after migration, prevent double
    charges by decoupling the page's memcg association (PCG_USED and
    pc->mem_cgroup) from the page holding an actual charge.  The new bits
    PCG_MEM and PCG_MEMSW represent the respective charges and are transferred
    to the new page during migration.
    
    mem_cgroup_migrate() is suitable for replace_page_cache() as well, which
    gets rid of mem_cgroup_replace_page_cache().
    
    Swap accounting is massively simplified: because the page is no longer
    uncharged as early as swap cache deletion, a new mem_cgroup_swapout() can
    transfer the page's memory+swap charge (PCG_MEMSW) to the swap entry
    before the final put_page() in page reclaim.
    
    Finally, page_cgroup changes are now protected by whatever protection the
    page itself offers: anonymous pages are charged under the page table lock,
    whereas page cache insertions, swapin, and migration hold the page lock.
    Uncharging happens under full exclusion with no outstanding references.
    Charging and uncharging also ensure that the page is off-LRU, which
    serializes against charge migration.  Remove the very costly page_cgroup
    lock and set pc->flags non-atomically.
    
    Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
    Cc: Michal Hocko <mhocko@suse.cz>
    Cc: Hugh Dickins <hughd@google.com>
    Cc: Tejun Heo <tj@kernel.org>
    Cc: Vladimir Davydov <vdavydov@parallels.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

+-----------------------------------------------------------------------+------------+------------+---------------+
|                                                                       | 5b647620c6 | ddc5bfec50 | next-20140620 |
+-----------------------------------------------------------------------+------------+------------+---------------+
| boot_successes                                                        | 60         | 0          | 0             |
| boot_failures                                                         | 0          | 20         | 13            |
| WARNING:CPU:PID:at_kernel/res_counter.c:res_counter_uncharge_locked() | 0          | 20         | 13            |
| backtrace:vm_munmap                                                   | 0          | 20         | 13            |
| backtrace:SyS_munmap                                                  | 0          | 20         | 13            |
| backtrace:do_sys_open                                                 | 0          | 20         | 13            |
| backtrace:SyS_open                                                    | 0          | 20         | 13            |
| backtrace:do_execve                                                   | 0          | 20         | 13            |
| backtrace:SyS_execve                                                  | 0          | 20         | 13            |
| backtrace:do_group_exit                                               | 0          | 20         | 13            |
| backtrace:SyS_exit_group                                              | 0          | 20         | 13            |
| backtrace:SYSC_renameat2                                              | 0          | 11         | 8             |
| backtrace:SyS_rename                                                  | 0          | 11         | 8             |
| backtrace:do_munmap                                                   | 0          | 11         | 8             |
| backtrace:SyS_brk                                                     | 0          | 11         | 8             |
| Out_of_memory:Kill_process                                            | 0          | 1          |               |
| backtrace:do_unlinkat                                                 | 0          | 9          | 5             |
| backtrace:SyS_unlink                                                  | 0          | 9          | 5             |
| backtrace:SYSC_umount                                                 | 0          | 9          |               |
| backtrace:SyS_umount                                                  | 0          | 9          |               |
| backtrace:cleanup_mnt_work                                            | 0          | 0          | 5             |
+-----------------------------------------------------------------------+------------+------------+---------------+

[    2.747397] debug: unmapping init [mem 0xffff880001a3a000-0xffff880001bfffff]
[    2.748630] debug: unmapping init [mem 0xffff8800021ad000-0xffff8800021fffff]
[    2.752857] ------------[ cut here ]------------
[    2.753355] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counter_uncharge_locked+0x48/0x74()
[    2.753355] CPU: 0 PID: 1 Comm: init Not tainted 3.16.0-rc1-00238-gddc5bfe #1
[    2.753355] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    2.753355]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff880012073c88
[    2.753355]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff88001200fa50
[    2.753355]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff810bc84b
[    2.753355] Call Trace:
[    2.753355]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    2.753355]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    2.753355]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    2.753355]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    2.753355]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    2.753355]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    2.753355]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    2.753355]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    2.753355]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    2.753355]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    2.753355]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    2.753355]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    2.753355]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    2.753355]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    2.753355]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    2.753355]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    2.753355]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    2.753355]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    2.753355] ---[ end trace cfeb07101f6fbdfb ]---
[    2.780913] ------------[ cut here ]------------

git bisect start 633594bb2d3890711a887897f2003f41735f0dfa 71d273fa769ea21f2422a18482e002a07ab9f8f3 --
git bisect  bad df2c04c68831d13d505c127b5aa172361a17c7e3  # 14:51      0-      4  Revert "mm, CMA: change cma_declare_contiguous() to obey coding convention"
git bisect  bad dc8a26d69d2039a81985549b00fc7e7e2bd34dd4  # 14:58      0-      2  Merge branch 'akpm/master'
git bisect  bad fe297b4d6987d04e8b3878b3ee47efd26b95114d  # 15:16      0-      8  Merge branch 'akpm-current/current'
git bisect good 6b11d02e25c79a8961983a966b7fafcdc36c7a91  # 15:24     20+      0  slab: do not keep free objects/slabs on dead memcg caches
git bisect  bad 11709212b3a5479fcc63dda3160f4f4b0251f914  # 16:02      0-      4  mm/util.c: add kstrimdup()
git bisect good d070bd175fccaab0616d8aec75acbde480531fee  # 16:11     20+      0  mm: memcontrol: catch root bypass in move precharge
git bisect  bad e77f4c327c7aa19d2c9ea28ebeb3a7166db418ad  # 16:27      0-     12  m68k: call find_vma with the mmap_sem held in sys_cacheflush()
git bisect  bad ddc5bfec501f4be3f9e89084c2db270c0c45d1d6  # 16:48      0-      1  mm: memcontrol: rewrite uncharge API
git bisect good 737f5b9367a254a3b3149b3abae65470f5ed941e  # 17:10     20+      0  mm: memcontrol: do not acquire page_cgroup lock for kmem pages
git bisect good 5b647620c6cae14cc27782c3491c2da0f1cf245c  # 17:40     20+      0  mm-memcontrol-rewrite-charge-api-fix
# first bad commit: [ddc5bfec501f4be3f9e89084c2db270c0c45d1d6] mm: memcontrol: rewrite uncharge API
git bisect good 5b647620c6cae14cc27782c3491c2da0f1cf245c  # 17:43     60+      0  mm-memcontrol-rewrite-charge-api-fix
git bisect  bad 633594bb2d3890711a887897f2003f41735f0dfa  # 17:43      0-     13  Add linux-next specific files for 20140620
git bisect good 3c8fb50445833b93f69b6b703a29aae3523cad0c  # 18:06     60+      0  Merge tag 'pm+acpi-3.16-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm
git bisect  bad 633594bb2d3890711a887897f2003f41735f0dfa  # 18:06      0-     13  Add linux-next specific files for 20140620


This script may reproduce the error.

-----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=quantal-core-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/blob/master/initrd/$initrd

kvm=(
	qemu-system-x86_64 -cpu kvm64 -enable-kvm 
	-kernel $kernel
	-initrd $initrd
	-smp 2
	-m 256M
	-net nic,vlan=0,macaddr=00:00:00:00:00:00,model=virtio
	-net user,vlan=0
	-net nic,vlan=1,model=e1000
	-net user,vlan=1
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-serial stdio
	-display none
	-monitor null
)

append=(
	debug
	sched_debug
	apic=debug
	ignore_loglevel
	sysrq_always_enabled
	panic=10
	prompt_ramdisk=0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
)

"${kvm[@]}" --append "${append[*]}"
-----------------------------------------------------------------------------

Thanks,
Fengguang

--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-ivb44-77:20140620164934:x86_64-randconfig-wa0-06201428:3.16.0-rc1-00238-gddc5bfe:1"
Content-Transfer-Encoding: quoted-printable

early console in setup code
Probing EDD (edd=3Doff to disable)... ok
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.16.0-rc1-00238-gddc5bfe (kbuild@waimea) (gcc=
 version 4.8.2 (Debian 4.8.2-18) ) #1 Fri Jun 20 16:47:43 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0=
 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw li=
nk=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-wa0-06201428/next:master=
:ddc5bfec501f4be3f9e89084c2db270c0c45d1d6:bisect-linux/.vmlinuz-ddc5bfec501=
f4be3f9e89084c2db270c0c45d1d6-20140620164751-3-ivb44 branch=3Dnext/master B=
OOT_IMAGE=3D/kernel/x86_64-randconfig-wa0-06201428/ddc5bfec501f4be3f9e89084=
c2db270c0c45d1d6/vmlinuz-3.16.0-rc1-00238-gddc5bfe drbd.minor_count=3D8
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
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x400000000
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
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef] mapped at =
[ffff8800000fdae0]
[    0.000000]   mpc: fdaf0-fdbe4
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0348c000, 0x0348cfff] PGTABLE
[    0.000000] BRK [0x0348d000, 0x0348dfff] PGTABLE
[    0.000000] BRK [0x0348e000, 0x0348efff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12600000-0x127fffff]
[    0.000000]  [mem 0x12600000-0x127fffff] page 4k
[    0.000000] BRK [0x0348f000, 0x0348ffff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x10000000-0x125fffff]
[    0.000000]  [mem 0x10000000-0x125fffff] page 4k
[    0.000000] BRK [0x03490000, 0x03490fff] PGTABLE
[    0.000000] BRK [0x03491000, 0x03491fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x0fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12800000-0x13ffdfff]
[    0.000000]  [mem 0x12800000-0x13ffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x1293d000-0x13feffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000FD950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000013FFE450 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000013FFFF80 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000013FFE490 0011A9 (v01 BXPC   BXDSDT   00=
000001 INTL 20100528)
[    0.000000] ACPI: FACS 0x0000000013FFFF40 000040
[    0.000000] ACPI: SSDT 0x0000000013FFF7A0 000796 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000013FFF680 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000013FFF640 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffd001, primary cpu clock
[    0.000000]  [ffffea0000000000-ffffea00005fffff] PMD -> [ffff88001180000=
0-ffff880011dfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77822 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
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
[    0.000000] ACPI: IRQ2 used by override.
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
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 223b600
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80519
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramd=
isk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram=
0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-wa0-06201428/next=
:master:ddc5bfec501f4be3f9e89084c2db270c0c45d1d6:bisect-linux/.vmlinuz-ddc5=
bfec501f4be3f9e89084c2db270c0c45d1d6-20140620164751-3-ivb44 branch=3Dnext/m=
aster BOOT_IMAGE=3D/kernel/x86_64-randconfig-wa0-06201428/ddc5bfec501f4be3f=
9e89084c2db270c0c45d1d6/vmlinuz-3.16.0-rc1-00238-gddc5bfe drbd.minor_count=
=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] Memory: 258312K/327280K available (10460K kernel code, 2530K=
 rwdata, 5812K rodata, 1348K init, 15104K bss, 68968K reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, N=
odes=3D1
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.16.0-rc1-00238-gddc5bfe (kbuild@waimea) (gcc=
 version 4.8.2 (Debian 4.8.2-18) ) #1 Fri Jun 20 16:47:43 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0=
 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw li=
nk=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-wa0-06201428/next:master=
:ddc5bfec501f4be3f9e89084c2db270c0c45d1d6:bisect-linux/.vmlinuz-ddc5bfec501=
f4be3f9e89084c2db270c0c45d1d6-20140620164751-3-ivb44 branch=3Dnext/master B=
OOT_IMAGE=3D/kernel/x86_64-randconfig-wa0-06201428/ddc5bfec501f4be3f9e89084=
c2db270c0c45d1d6/vmlinuz-3.16.0-rc1-00238-gddc5bfe drbd.minor_count=3D8
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
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x400000000
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
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef] mapped at =
[ffff8800000fdae0]
[    0.000000]   mpc: fdaf0-fdbe4
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0348c000, 0x0348cfff] PGTABLE
[    0.000000] BRK [0x0348d000, 0x0348dfff] PGTABLE
[    0.000000] BRK [0x0348e000, 0x0348efff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12600000-0x127fffff]
[    0.000000]  [mem 0x12600000-0x127fffff] page 4k
[    0.000000] BRK [0x0348f000, 0x0348ffff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x10000000-0x125fffff]
[    0.000000]  [mem 0x10000000-0x125fffff] page 4k
[    0.000000] BRK [0x03490000, 0x03490fff] PGTABLE
[    0.000000] BRK [0x03491000, 0x03491fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x0fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12800000-0x13ffdfff]
[    0.000000]  [mem 0x12800000-0x13ffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x1293d000-0x13feffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000FD950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000013FFE450 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000013FFFF80 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000013FFE490 0011A9 (v01 BXPC   BXDSDT   00=
000001 INTL 20100528)
[    0.000000] ACPI: FACS 0x0000000013FFFF40 000040
[    0.000000] ACPI: SSDT 0x0000000013FFF7A0 000796 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000013FFF680 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000013FFF640 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffd001, primary cpu clock
[    0.000000]  [ffffea0000000000-ffffea00005fffff] PMD -> [ffff88001180000=
0-ffff880011dfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77822 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
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
[    0.000000] ACPI: IRQ2 used by override.
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
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 223b600
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80519
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramd=
isk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram=
0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-wa0-06201428/next=
:master:ddc5bfec501f4be3f9e89084c2db270c0c45d1d6:bisect-linux/.vmlinuz-ddc5=
bfec501f4be3f9e89084c2db270c0c45d1d6-20140620164751-3-ivb44 branch=3Dnext/m=
aster BOOT_IMAGE=3D/kernel/x86_64-randconfig-wa0-06201428/ddc5bfec501f4be3f=
9e89084c2db270c0c45d1d6/vmlinuz-3.16.0-rc1-00238-gddc5bfe drbd.minor_count=
=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] Memory: 258312K/327280K available (10460K kernel code, 2530K=
 rwdata, 5812K rodata, 1348K init, 15104K bss, 68968K reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, N=
odes=3D1
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
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
[    0.000000]  memory used by lock dependency info: 8159 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] allocated 1572864 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't wan=
t memory cgroups
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.456 MHz processor
[    0.006666] Calibrating delay loop (skipped) preset value.. 5389.36 Bogo=
MIPS (lpj=3D8978186)
[    0.006666] pid_max: default: 32768 minimum: 301
[    0.006699] ACPI: Core revision 20140424
[    0.010824] ACPI: All ACPI Tables successfully acquired
[    0.011870] Security Framework initialized
[    0.012542] Yama: becoming mindful.
[    0.013194] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.013345] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.014941] Initializing cgroup subsys memory
[    0.015710] Initializing cgroup subsys devices
[    0.016700] Initializing cgroup subsys freezer
[    0.017434] Initializing cgroup subsys net_prio
[    0.018180] Initializing cgroup subsys hugetlb
[    0.018899] Initializing cgroup subsys debug
[    0.020114] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.020114] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.020114] tlb_flushall_shift: 6
[    0.022227] CPU: Intel Common KVM processor (fam: 0f, model: 06, steppin=
g: 01)
[    0.025177] ftrace: allocating 41916 entries in 164 pages
[    0.033595] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.037926] Getting VERSION: 50014
[    0.038529] Getting VERSION: 50014
[    0.039123] Getting ID: 0
[    0.039627] Getting ID: ff000000
[    0.040011] Getting LVT0: 8700
[    0.040563] Getting LVT1: 8400
[    0.041137] enabled ExtINT on CPU#0
[    0.042395] ENABLING IO-APIC IRQs
[    0.042976] init IO_APIC IRQs
[    0.043340]  apic 0 pin 0 not connected
[    0.043992] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.045234] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.046688] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.047936] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.049171] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.050020] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.051263] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.052503] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.053353] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.054592] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.056687] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.057949] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.059214] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.060020] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.061288] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.063337]  apic 0 pin 16 not connected
[    0.063989]  apic 0 pin 17 not connected
[    0.064631]  apic 0 pin 18 not connected
[    0.065274]  apic 0 pin 19 not connected
[    0.065921]  apic 0 pin 20 not connected
[    0.066563]  apic 0 pin 21 not connected
[    0.066671]  apic 0 pin 22 not connected
[    0.067314]  apic 0 pin 23 not connected
[    0.068106] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.069089] Using local APIC timer interrupts.
[    0.069089] calibrating APIC timer ...
[    0.073333] ... lapic delta =3D 6249967
[    0.073333] ... PM-Timer delta =3D 357952
[    0.073333] ... PM-Timer result ok
[    0.073333] ..... delta 6249967
[    0.073333] ..... mult: 268434065
[    0.073333] ..... calibration result: 3333315
[    0.073333] ..... CPU clock speed is 2693.2326 MHz.
[    0.073333] ..... host bus clock speed is 1000.0315 MHz.
[    0.073844] devtmpfs: initialized
[    0.080483] xor: measuring software checksum speed
[    0.113336]    prefetch64-sse: 11086.800 MB/sec
[    0.146671]    generic_sse:  9229.200 MB/sec
[    0.147452] xor: using function: prefetch64-sse (11086.800 MB/sec)
[    0.148881] regulator-dummy: no parameters
[    0.149893] NET: Registered protocol family 16
[    0.150780] cpuidle: using governor ladder
[    0.151535] cpuidle: using governor menu
[    0.153371] ACPI: bus type PCI registered
[    0.154227] PCI: Using configuration type 1 for base access
[    0.220004] raid6: sse2x1    7795 MB/s
[    0.276676] raid6: sse2x2    9570 MB/s
[    0.333337] raid6: sse2x4   11073 MB/s
[    0.334036] raid6: using algorithm sse2x4 (11073 MB/s)
[    0.334898] raid6: using intx1 recovery algorithm
[    0.335782] ACPI: Added _OSI(Module Device)
[    0.336532] ACPI: Added _OSI(Processor Device)
[    0.336672] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.337481] ACPI: Added _OSI(Processor Aggregator Device)
[    0.344789] ACPI: Interpreter enabled
[    0.345488] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_] (20140424/hwxface-580)
[    0.347167] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20140424/hwxface-580)
[    0.348865] ACPI: (supports S0 S3 S5)
[    0.349543] ACPI: Using IOAPIC for interrupt routing
[    0.350052] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.359838] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.360013] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.360957] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.363390] PCI host bridge to bus 0000:00
[    0.364142] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.365052] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.366051] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.366673] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.367762] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.368901] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.370530] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.372143] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.375624] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.377352] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.378474] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.379518] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.380006] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.381336] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.383458] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.384734] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.386199] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.390588] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.392874] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.399409] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.400694] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.403339] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.405170] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.410005] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.411400] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.412828] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.417153] pci_bus 0000:00: on NUMA node 0
[    0.418868] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.420531] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.422043] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.423535] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.424949] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.426666] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.427863] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.430005] vgaarb: loaded
[    0.430571] vgaarb: bridge control possible 0000:00:02.0
[    0.432271] SCSI subsystem initialized
[    0.433400] libata version 3.00 loaded.
[    0.434292] pps_core: LinuxPPS API ver. 1 registered
[    0.435138] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.436691] PTP clock support registered
[    0.437636] Advanced Linux Sound Architecture Driver Initialized.
[    0.438666] PCI: Using ACPI for IRQ routing
[    0.439409] PCI: pci_cache_line_size set to 64 bytes
[    0.440115] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.441098] e820: reserve RAM buffer [mem 0x13ffe000-0x13ffffff]
[    0.442700] irda_init()
[    0.443411] NET: Registered protocol family 23
[    0.444260] Bluetooth: Core ver 2.19
[    0.444964] NET: Registered protocol family 31
[    0.445749] Bluetooth: HCI device and connection manager initialized
[    0.446691] Bluetooth: HCI socket layer initialized
[    0.447536] Bluetooth: L2CAP socket layer initialized
[    0.450049] Bluetooth: SCO socket layer initialized
[    0.450906] NetLabel: Initializing
[    0.451551] NetLabel:  domain hash size =3D 128
[    0.453337] NetLabel:  protocols =3D UNLABELED CIPSOv4
[    0.454251] NetLabel:  unlabeled traffic allowed by default
[    0.455868] Switched to clocksource kvm-clock
[    0.455868] Warning: could not register annotated branches stats
[    0.492483] FS-Cache: Loaded
[    0.493197] CacheFiles: Loaded
[    0.493902] pnp: PnP ACPI init
[    0.494530] ACPI: bus type PNP registered
[    0.495319] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.496795] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.497882] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.499305] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.500399] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.501865] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.502972] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.504365] pnp 00:03: [dma 2]
[    0.505020] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.506132] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.507560] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.508668] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.510122] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.511252] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.512671] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.514139] pnp: PnP ACPI: found 7 devices
[    0.514875] ACPI: bus type PNP unregistered
[    0.524948] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.525897] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.526831] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.527840] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    0.528946] NET: Registered protocol family 2
[    0.530162] TCP established hash table entries: 4096 (order: 3, 32768 by=
tes)
[    0.531356] TCP bind hash table entries: 4096 (order: 6, 262144 bytes)
[    0.532777] TCP: Hash tables configured (established 4096 bind 4096)
[    0.533905] TCP: reno registered
[    0.534565] UDP hash table entries: 256 (order: 3, 40960 bytes)
[    0.535620] UDP-Lite hash table entries: 256 (order: 3, 40960 bytes)
[    0.536941] NET: Registered protocol family 1
[    0.537752] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.538730] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.539678] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.540713] pci 0000:00:02.0: Boot video device
[    0.541525] PCI: CLS 0 bytes, default 64
[    0.542512] Unpacking initramfs...
[    1.235239] debug: unmapping init [mem 0xffff88001293d000-0xffff880013fe=
ffff]
[    1.237437] kvm: no hardware support
[    1.238126] has_svm: not amd
[    1.238692] kvm: no hardware support
[    1.240199] cryptomgr_test (19) used greatest stack depth: 14520 bytes l=
eft
[    1.241293] camellia-x86_64: performance on this CPU would be suboptimal=
: disabling camellia-x86_64.
[    1.242786] blowfish-x86_64: performance on this CPU would be suboptimal=
: disabling blowfish-x86_64.
[    1.244529] twofish-x86_64-3way: performance on this CPU would be subopt=
imal: disabling twofish-x86_64-3way.
[    1.246181] sha1_ssse3: Neither AVX nor AVX2 nor SSSE3 is available/usab=
le.
[    1.247298] sha256_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.248307] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.249306] AVX or AES-NI instructions are not detected.
[    1.250188] AVX instructions are not detected.
[    1.250951] AVX instructions are not detected.
[    1.251699] AVX instructions are not detected.
[    1.252453] AVX instructions are not detected.
[    1.253671] futex hash table entries: 256 (order: 2, 20480 bytes)
[    1.255208] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.271348] VFS: Disk quotas dquot_6.5.2
[    1.272322] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.274381] DLM installed
[    1.281244] ntfs: driver 2.1.30 [Flags: R/W].
[    1.283139] QNX4 filesystem 0.2.3 registered.
[    1.284135] QNX6 filesystem 1.0.0 registered.
[    1.285241] fuse init (API version 7.23)
[    1.287286] JFS: nTxBlock =3D 2018, nTxLock =3D 16144
[    1.290486] SGI XFS with ACLs, security attributes, large block/inode nu=
mbers, no debug enabled
[    1.294442] NILFS version 2 loaded
[    1.296762] gfs2: GFS2 installed
[    1.297629] msgmni has been set to 504
[    1.298692] Key type big_key registered
[    1.299979] cryptomgr_test (38) used greatest stack depth: 13832 bytes l=
eft
[    1.306415] cryptomgr_test (66) used greatest stack depth: 13632 bytes l=
eft
[    1.309208] cryptomgr_test (73) used greatest stack depth: 13560 bytes l=
eft
[    1.310694] alg: No test for crc32 (crc32-table)
[    1.311853] alg: No test for lz4 (lz4-generic)
[    1.312680] alg: No test for lz4hc (lz4hc-generic)
[    1.313569] alg: No test for stdrng (krng)
[    1.314515] NET: Registered protocol family 38
[    1.315531] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[    1.316864] io scheduler noop registered
[    1.317558] io scheduler deadline registered
[    1.318524] io scheduler cfq registered (default)
[    1.319344] test_string_helpers: Running tests...
[    1.320369] rbtree testing -> 8770 cycles
[    1.701676] augmented rbtree testing -> 12943 cycles
[    2.257144] no IO addresses supplied
[    2.257949] hgafb: HGA card not detected.
[    2.258664] hgafb: probe of hgafb.0 failed with error -22
[    2.259846] tsc: Refined TSC clocksource calibration: 2693.449 MHz
[    2.261110] uvesafb: failed to execute /sbin/v86d
[    2.261922] uvesafb: make sure that the v86d helper is installed and exe=
cutable
[    2.263181] uvesafb: Getting VBE info block failed (eax=3D0x4f00, err=3D=
-2)
[    2.264241] uvesafb: vbe_init() failed with -22
[    2.265035] uvesafb: probe of uvesafb.0 failed with error -22
[    2.265999] ipmi message handler version 39.2
[    2.266780] ipmi device interface
[    2.267462] IPMI System Interface driver.
[    2.268257] ipmi_si: Adding default-specified kcs state machine
[    2.269296] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[    2.270894] ipmi_si: Interface detection failed
[    2.271663] ipmi_si: Adding default-specified smic state machine
[    2.272684] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[    2.274292] ipmi_si: Interface detection failed
[    2.275079] ipmi_si: Adding default-specified bt state machine
[    2.276096] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[    2.277671] ipmi_si: Interface detection failed
[    2.278567] ipmi_si: Unable to find any System Interface(s)
[    2.279460] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[    2.281001] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    2.282297] ACPI: Power Button [PWRF]
[    2.310672] r3964: Philips r3964 Driver $Revision: 1.10 $
[    2.311570] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    2.338307] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    2.341017] serial: Freescale lpuart driver
[    2.341982] lp: driver loaded but no devices found
[    2.342834] ppdev: user-space parallel port driver
[    2.343698] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    2.344589] smapi::smapi_init, ERROR invalid usSmapiID
[    2.345457] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[    2.346995] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[    2.348256] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    2.349305] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    2.350815] Hangcheck: Using getrawmonotonic().
[    2.351640] [drm] Initialized drm 1.1.0 20060810
[    2.352527] parport_pc 00:04: reported by Plug and Play ACPI
[    2.353549] parport0: PC-style at 0x378, irq 7 [PCSPP(,...)]
[    2.355305] lp0: using parport0 (interrupt-driven).
[    2.356158] lp0: console ready
[    2.357359] dummy-irq: no IRQ given.  Use irq=3DN
[    2.358191] lkdtm: No crash points registered, enable through debugfs
[    2.359337] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    2.360739] mic_init not running on X100 ret -19
[    2.361761] Uniform Multi-Platform E-IDE driver
[    2.362993] ide_generic: please use "probe_mask=3D0x3f" module parameter=
 for probing all legacy ISA IDE ports
[    2.364806] rdac: device handler registered
[    2.365646] hp_sw: device handler registered
[    2.366415] emc: device handler registered
[    2.367170] alua: device handler registered
[    2.367924] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    2.369098] SCSI Media Changer driver v0.25=20
[    2.369945] osd: LOADED open-osd 0.2.1
[    2.370677] HSI/SSI char device loaded
[    2.371384] slcan: serial line CAN interface driver
[    2.372211] slcan: 10 dynamic interface channels.
[    2.373025] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[    2.373899] AX.25: 6pack driver, Revision: 0.3.0
[    2.374694] YAM driver version 0.8 by F1OAT/F6FBB
[    2.376631] AX.25: bpqether driver version 004
[    2.377439] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    2.377439] baycom_ser_fdx: version 0.10
[    2.385902] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    2.386871] hdlcdrv: version 0.8
[    2.387496] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    2.387496] baycom_ser_hdx: version 0.10
[    2.390231] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    2.390231] baycom_par: version 0.9
[    2.393468] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    2.395572] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.396450] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.398006] mousedev: PS/2 mouse device common for all mice
[    2.400020] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    2.402937] parport0: cannot grant exclusive access for device walkera07=
01
[    2.404056] walkera0701: failed to register parport device
[    2.405815] rtc (null): invalid alarm value: 1900-1-20 0:0:0
[    2.406832] rtc-test rtc-test.0: rtc core: registered test as rtc0
[    2.407931] rtc (null): invalid alarm value: 1900-1-20 0:0:0
[    2.408944] rtc-test rtc-test.1: rtc core: registered test as rtc1
[    2.410061] i2c /dev entries driver
[    2.410818] i2c-parport: adapter type unspecified
[    2.411632] i2c-parport-light: adapter type unspecified
[    2.414315] pps pps0: new PPS source ktimer
[    2.415075] pps pps0: ktimer PPS source registered
[    2.415901] pps_ldisc: PPS line discipline registered
[    2.416783] pps_parport: parallel port PPS client
[    2.417600] parport0: cannot grant exclusive access for device pps_parpo=
rt
[    2.418686] pps_parport: couldn't register with parport0
[    2.419580] Driver for 1-wire Dallas network protocol.
[    2.420557] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    2.421614] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 20=
04-2005, Szabolcs Gyurko
[    2.423257] power_supply test_ac: uevent
[    2.423990] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[    2.424923] power_supply test_ac: prop ONLINE=3D1
[    2.425751] power_supply test_ac: power_supply_changed
[    2.426801] power_supply test_battery: uevent
[    2.427571] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[    2.428607] power_supply test_battery: prop STATUS=3DDischarging
[    2.429569] power_supply test_battery: prop CHARGE_TYPE=3DFast
[    2.430520] power_supply test_battery: prop HEALTH=3DGood
[    2.431400] power_supply test_battery: prop PRESENT=3D1
[    2.432250] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[    2.433185] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[    2.434196] power_supply test_battery: prop CHARGE_FULL=3D100
[    2.435119] power_supply test_battery: prop CHARGE_NOW=3D50
[    2.436018] power_supply test_battery: prop CAPACITY=3D50
[    2.436907] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[    2.437889] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[    2.438881] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[    2.439860] power_supply test_battery: prop MODEL_NAME=3DTest battery
[    2.440877] power_supply test_battery: prop MANUFACTURER=3DLinux
[    2.441835] power_supply test_battery: prop SERIAL_NUMBER=3D3.16.0-rc1-0=
0238-gddc5bfe
[    2.443153] power_supply test_battery: prop TEMP=3D26
[    2.443995] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[    2.445091] power_supply test_battery: power_supply_changed
[    2.446086] power_supply test_usb: uevent
[    2.446831] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[    2.447783] power_supply test_usb: prop ONLINE=3D1
[    2.448593] power_supply test_usb: power_supply_changed
[    2.449975] applesmc: supported laptop not found!
[    2.450800] applesmc: driver init failed (ret=3D-19)!
[    2.452463] pc87360: PC8736x not detected, module not inserted
[    2.453511] sch56xx_common: Unsupported device id: 0xff
[    2.454398] sch56xx_common: Unsupported device id: 0xff
[    2.455834] it87_wdt: no device
[    2.456473] sc1200wdt: build 20020303
[    2.457208] sc1200wdt: io parameter must be specified
[    2.458088] pc87413_wdt: Version 1.1 at io 0x2E
[    2.458929] power_supply test_ac: power_supply_changed_work
[    2.459877] power_supply test_ac: power_supply_update_gen_leds 1
[    2.460875] power_supply test_ac: uevent
[    2.461589] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[    2.462517] power_supply test_ac: prop ONLINE=3D1
[    2.463389] pc87413_wdt: initialized. timeout=3D1 min
[    2.464275] pc87413_wdt: cannot request SWC region at 0xffff
[    2.465445] cpu5wdt: init success
[    2.466144] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[    2.468571] smsc37b787_wdt: Unable to register miscdev on minor 130
[    2.469631] w83877f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    2.470710] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[    2.471873] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    2.473261] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    2.474715] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[    2.476475] Bluetooth: Virtual HCI driver ver 1.4
[    2.477379] Bluetooth: HCI UART driver ver 2.2
[    2.478173] Bluetooth: HCI BCSP protocol initialized
[    2.479021] Bluetooth: HCILL protocol initialized
[    2.479835] Bluetooth: HCIATH3K protocol initialized
[    2.481624] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    2.484092] power_supply test_battery: power_supply_changed_work
[    2.485090] power_supply test_battery: power_supply_update_bat_leds 2
[    2.486126] power_supply test_battery: uevent
[    2.486914] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[    2.487962] power_supply test_battery: prop STATUS=3DDischarging
[    2.488925] power_supply test_battery: prop CHARGE_TYPE=3DFast
[    2.489867] power_supply test_battery: prop HEALTH=3DGood
[    2.490760] power_supply test_battery: prop PRESENT=3D1
[    2.491617] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[    2.492562] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[    2.493572] power_supply test_battery: prop CHARGE_FULL=3D100
[    2.494501] power_supply test_battery: prop CHARGE_NOW=3D50
[    2.495402] power_supply test_battery: prop CAPACITY=3D50
[    2.496278] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[    2.497275] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[    2.498275] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[    2.499261] power_supply test_battery: prop MODEL_NAME=3DTest battery
[    2.500287] power_supply test_battery: prop MANUFACTURER=3DLinux
[    2.501243] power_supply test_battery: prop SERIAL_NUMBER=3D3.16.0-rc1-0=
0238-gddc5bfe
[    2.502553] power_supply test_battery: prop TEMP=3D26
[    2.503406] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[    2.504582] power_supply test_usb: power_supply_changed_work
[    2.505518] power_supply test_usb: power_supply_update_gen_leds 1
[    2.506509] power_supply test_usb: uevent
[    2.507245] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[    2.508194] power_supply test_usb: prop ONLINE=3D1
[    2.587068] panel: driver version 0.9.5 registered on parport0 (io=3D0x3=
78).
[    2.589086] logger: created 256K log 'log_main'
[    2.590133] logger: created 256K log 'log_events'
[    2.591154] logger: created 256K log 'log_radio'
[    2.592181] logger: created 256K log 'log_system'
[    2.593167] FPGA DOWNLOAD --->
[    2.593799] FPGA image file name: xlinx_fpga_firmware.bit
[    2.594759] GPIO INIT FAIL!!
[    2.596527] Audio Excel DSP 16 init driver Copyright (C) Riccardo Facche=
tti 1995-98
[    2.597870] aedsp16: I/O, IRQ and DMA are mandatory
[    2.598707] pss: mss_io, mss_dma, mss_irq and pss_io must be set.
[    2.599696] ad1848/cs4248 codec driver Copyright (C) by Hannu Savolainen=
 1993-1996
[    2.601021] ad1848: No ISAPnP cards found, trying standard ones...
[    2.602020] Pro Audio Spectrum driver Copyright (C) by Hannu Savolainen =
1993-1996
[    2.603321] I/O, IRQ, DMA and type are mandatory
[    2.604135] sb: Init: Starting Probe...
[    2.604866] sb: Init: Done
[    2.605450] uart6850: irq and io must be set.
[    2.606220] YM3812 and OPL-3 driver Copyright (C) by Hannu Savolainen, R=
ob Hooft 1993-1996
[    2.607683] MIDI Loopback device driver
[    2.610278] snd_dummy snd_dummy.0: unable to register OSS PCM device 0:0
[    2.612600] no UART detected at 0x1
[    2.613595] MTVAP port 0x378 is busy
[    2.614344] snd_mtpav: probe of snd_mtpav failed with error -16
[    2.616391] oprofile: using NMI interrupt.
[    2.617190] drop_monitor: Initializing network drop monitor service
[    2.618319] NET: Registered protocol family 26
[    2.619149] GACT probability NOT on
[    2.619825] Mirror/redirect action on
[    2.620548] netem: version 1.3
[    2.621198] u32 classifier
[    2.621767]     Performance counters on
[    2.622473]     Actions configured
[    2.623246] ipip: IPv4 over IPv4 tunneling driver
[    2.624500] TCP: cubic registered
[    2.625184] Initializing XFRM netlink socket
[    2.626895] NET: Registered protocol family 10
[    2.629002] mip6: Mobile IPv6
[    2.630343] NET: Registered protocol family 17
[    2.631181] NET: Registered protocol family 15
[    2.632045] NET: Registered protocol family 5
[    2.632875] NET: Registered protocol family 9
[    2.633661] X25: Linux Version 0.2
[    2.634348] NET: Registered protocol family 3
[    2.635145] can: controller area network core (rev 20120528 abi 9)
[    2.636218] NET: Registered protocol family 29
[    2.637030] can: broadcast manager protocol (rev 20120528 t)
[    2.637996] can: netlink gateway (rev 20130117) max_hops=3D1
[    2.639722] Bluetooth: RFCOMM TTY layer initialized
[    2.640587] Bluetooth: RFCOMM socket layer initialized
[    2.641478] Bluetooth: RFCOMM ver 1.11
[    2.642185] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[    2.648970] Bluetooth: HIDP socket layer initialized
[    2.650089] NET: Registered protocol family 33
[    2.650876] Key type rxrpc registered
[    2.651553] Key type rxrpc_s registered
[    2.652296] l2tp_core: L2TP core driver, V2.0
[    2.653093] l2tp_debugfs: L2TP debugfs support
[    2.653897] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[    2.655581] DECnet: Routing cache hash table of 256 buckets, 16Kbytes
[    2.656648] NET: Registered protocol family 12
[    2.657490] NET: Registered protocol family 35
[    2.658325] 8021q: 802.1Q VLAN Support v1.8
[    2.659550] DCCP: Activated CCID 2 (TCP-like)
[    2.660366] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[    2.662531] sctp: Hash tables configured (established 1170 bind 1024)
[    2.663791] 9pnet: Installing 9P2000 support
[    2.664651] NET: Registered protocol family 37
[    2.665522] Key type dns_resolver registered
[    2.666307] Key type ceph registered
[    2.667478] libceph: loaded (mon/osd proto 15/24)
[    2.668302] openvswitch: Open vSwitch switching datapath
[    2.669304] mpls_gso: MPLS GSO support
[    2.670466]=20
[    2.670466] printing PIC contents
[    2.671433] ... PIC  IMR: ffff
[    2.672055] ... PIC  IRR: 1013
[    2.672658] ... PIC  ISR: 0000
[    2.673267] ... PIC ELCR: 0c00
[    2.673883] printing local APIC contents on CPU#0/0:
[    2.674733] ... APIC ID:      00000000 (0)
[    2.675463] ... APIC VERSION: 00050014
[    2.676153] ... APIC TASKPRI: 00000000 (00)
[    2.676900] ... APIC PROCPRI: 00000000
[    2.677206] ... APIC LDR: 01000000
[    2.677206] ... APIC DFR: ffffffff
[    2.677206] ... APIC SPIV: 000001ff
[    2.677206] ... APIC ISR field:
[    2.677206] 000000000000000000000000000000000000000000000000000000000000=
0000
[    2.677206] ... APIC TMR field:
[    2.677206] 000000000200000000000000000000000000000000000000000000000000=
0000
[    2.677206] ... APIC IRR field:
[    2.677206] 000000000000000000000000000000000000000000000000000000000000=
8000
[    2.677206] ... APIC ESR: 00000000
[    2.677206] ... APIC ICR: 00000831
[    2.677206] ... APIC ICR2: 01000000
[    2.677206] ... APIC LVTT: 000000ef
[    2.677206] ... APIC LVTPC: 00010000
[    2.677206] ... APIC LVT0: 00010700
[    2.677206] ... APIC LVT1: 00000400
[    2.677206] ... APIC LVTERR: 000000fe
[    2.677206] ... APIC TMICT: 0002a981
[    2.677206] ... APIC TMCCT: 00000000
[    2.677206] ... APIC TDCR: 00000003
[    2.677206]=20
[    2.694188] number of MP IRQ sources: 15.
[    2.694911] number of IO-APIC #0 registers: 24.
[    2.695688] testing the IO APIC.......................
[    2.696558] IO APIC #0......
[    2.697149] .... register #00: 00000000
[    2.697849] .......    : physical APIC id: 00
[    2.698604] .......    : Delivery Type: 0
[    2.699321] .......    : LTS          : 0
[    2.700052] .... register #01: 00170011
[    2.700756] .......     : max redirection entries: 17
[    2.701601] .......     : PRQ implemented: 0
[    2.702357] .......     : IO APIC version: 11
[    2.703128] .... register #02: 00000000
[    2.703842] .......     : arbitration: 00
[    2.704559] .... IRQ redirection table:
[    2.705265] 1    0    0   0   0    0    0    00
[    2.706060] 0    0    0   0   0    1    1    31
[    2.706871] 0    0    0   0   0    1    1    30
[    2.707660] 0    0    0   0   0    1    1    33
[    2.708453] 1    0    0   0   0    1    1    34
[    2.709244] 1    1    0   0   0    1    1    35
[    2.710049] 0    0    0   0   0    1    1    36
[    2.710846] 0    0    0   0   0    1    1    37
[    2.711631] 0    0    0   0   0    1    1    38
[    2.712428] 0    1    0   0   0    1    1    39
[    2.713217] 1    1    0   0   0    1    1    3A
[    2.714049] 1    1    0   0   0    1    1    3B
[    2.714847] 0    0    0   0   0    1    1    3C
[    2.715634] 0    0    0   0   0    1    1    3D
[    2.716429] 0    0    0   0   0    1    1    3E
[    2.717230] 0    0    0   0   0    1    1    3F
[    2.718027] 1    0    0   0   0    0    0    00
[    2.718817] 1    0    0   0   0    0    0    00
[    2.719600] 1    0    0   0   0    0    0    00
[    2.720399] 1    0    0   0   0    0    0    00
[    2.721191] 1    0    0   0   0    0    0    00
[    2.721982] 1    0    0   0   0    0    0    00
[    2.722777] 1    0    0   0   0    0    0    00
[    2.723579] 1    0    0   0   0    0    0    00
[    2.724365] IRQ to pin mappings:
[    2.724987] IRQ0 -> 0:2
[    2.725663] IRQ1 -> 0:1
[    2.726340] IRQ3 -> 0:3
[    2.727033] IRQ4 -> 0:4
[    2.727711] IRQ5 -> 0:5
[    2.728384] IRQ6 -> 0:6
[    2.729063] IRQ7 -> 0:7
[    2.729744] IRQ8 -> 0:8
[    2.730431] IRQ9 -> 0:9
[    2.731109] IRQ10 -> 0:10
[    2.731810] IRQ11 -> 0:11
[    2.732506] IRQ12 -> 0:12
[    2.733206] IRQ13 -> 0:13
[    2.733951] IRQ14 -> 0:14
[    2.734644] IRQ15 -> 0:15
[    2.735344] .................................... done.
[    2.736610] registered taskstats version 1
[    2.737965] Key type encrypted registered
[    2.739245] rtc-test rtc-test.0: setting system clock to 2014-06-20 08:4=
8:24 UTC (1403254104)
[    2.740787] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    2.741766] EDD information not available.
[    2.742600] ALSA device list:
[    2.743202]   #0: Dummy 1
[    2.743766]   #1: Loopback 1
[    2.744578] debug: unmapping init [mem 0xffffffff8247a000-0xffffffff825c=
afff]
[    2.745810] Write protecting the kernel read-only data: 18432k
[    2.747397] debug: unmapping init [mem 0xffff880001a3a000-0xffff880001bf=
ffff]
[    2.748630] debug: unmapping init [mem 0xffff8800021ad000-0xffff8800021f=
ffff]
[    2.752857] ------------[ cut here ]------------
[    2.753355] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    2.753355] CPU: 0 PID: 1 Comm: init Not tainted 3.16.0-rc1-00238-gddc5b=
fe #1
[    2.753355] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    2.753355]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    2.753355]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    2.753355]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    2.753355] Call Trace:
[    2.753355]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    2.753355]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    2.753355]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    2.753355]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    2.753355]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    2.753355]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    2.753355]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    2.753355]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    2.753355]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    2.753355]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    2.753355]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    2.753355]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    2.753355]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    2.753355]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    2.753355]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    2.753355]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    2.753355]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    2.753355]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    2.753355] ---[ end trace cfeb07101f6fbdfb ]---
[    2.780913] ------------[ cut here ]------------
[    2.781724] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    2.783432] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    2.783976] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    2.783976]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    2.783976]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    2.783976]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    2.783976] Call Trace:
[    2.783976]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    2.783976]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    2.783976]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    2.783976]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    2.783976]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    2.783976]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    2.783976]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    2.783976]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    2.783976]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    2.783976]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    2.783976]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    2.783976]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    2.783976]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    2.783976]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    2.783976]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    2.783976]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    2.783976]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    2.783976]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    2.783976] ---[ end trace cfeb07101f6fbdfc ]---
[    2.814881] ------------[ cut here ]------------
[    2.815688] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    2.817398] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    2.818033] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    2.818033]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    2.818033]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    2.818033]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    2.818033] Call Trace:
[    2.818033]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    2.818033]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    2.818033]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    2.818033]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    2.818033]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    2.818033]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    2.818033]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    2.818033]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    2.818033]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    2.818033]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    2.818033]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    2.818033]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    2.818033]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    2.818033]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    2.818033]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    2.818033]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    2.818033]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    2.818033]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    2.818033] ---[ end trace cfeb07101f6fbdfd ]---
[    2.843564] ------------[ cut here ]------------
[    2.844375] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    2.846079] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    2.846681] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    2.846681]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    2.846681]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    2.846681]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    2.846681] Call Trace:
[    2.846681]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    2.846681]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    2.846681]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    2.846681]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    2.846681]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    2.846681]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    2.846681]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    2.846681]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    2.846681]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    2.846681]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    2.846681]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    2.846681]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    2.846681]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    2.846681]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    2.846681]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    2.846681]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    2.846681]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    2.846681]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    2.846681] ---[ end trace cfeb07101f6fbdfe ]---
[    2.871615] ------------[ cut here ]------------
[    2.872429] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    2.874145] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    2.874766] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    2.874766]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    2.874766]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    2.874766]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    2.874766] Call Trace:
[    2.874766]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    2.874766]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    2.874766]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    2.874766]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    2.874766]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    2.874766]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    2.874766]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    2.874766]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    2.874766]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    2.874766]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    2.874766]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    2.874766]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    2.874766]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    2.874766]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    2.874766]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    2.874766]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    2.874766]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    2.874766]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    2.874766] ---[ end trace cfeb07101f6fbdff ]---
[    2.899720] ------------[ cut here ]------------
[    2.900527] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    2.902230] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    2.902899] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    2.902899]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    2.902899]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    2.902899]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    2.902899] Call Trace:
[    2.902899]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    2.902899]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    2.902899]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    2.902899]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    2.902899]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    2.902899]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    2.902899]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    2.902899]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    2.902899]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    2.902899]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    2.902899]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    2.902899]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    2.902899]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    2.902899]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    2.902899]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    2.902899]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    2.902899]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    2.902899]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    2.902899] ---[ end trace cfeb07101f6fbe00 ]---
[    2.927802] ------------[ cut here ]------------
[    2.928610] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    2.930322] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    2.930985] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    2.930985]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    2.930985]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    2.930985]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    2.930985] Call Trace:
[    2.930985]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    2.930985]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    2.930985]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    2.930985]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    2.930985]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    2.930985]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    2.930985]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    2.930985]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    2.930985]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    2.930985]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    2.930985]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    2.930985]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    2.930985]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    2.930985]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    2.930985]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    2.930985]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    2.930985]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    2.930985]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    2.930985] ---[ end trace cfeb07101f6fbe01 ]---
[    2.955638] ------------[ cut here ]------------
[    2.956426] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    2.958090] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    2.958753] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    2.958753]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    2.958753]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    2.958753]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    2.958753] Call Trace:
[    2.958753]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    2.958753]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    2.958753]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    2.958753]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    2.958753]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    2.958753]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    2.958753]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    2.958753]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    2.958753]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    2.958753]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    2.958753]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    2.958753]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    2.958753]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    2.958753]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    2.958753]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    2.958753]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    2.958753]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    2.958753]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    2.958753] ---[ end trace cfeb07101f6fbe02 ]---
[    2.988339] ------------[ cut here ]------------
[    2.989133] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    2.990816] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    2.991536] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    2.991536]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    2.991536]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    2.991536]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    2.991536] Call Trace:
[    2.991536]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    2.991536]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    2.991536]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    2.991536]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    2.991536]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    2.991536]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    2.991536]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    2.991536]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    2.991536]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    2.991536]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    2.991536]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    2.991536]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    2.991536]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    2.991536]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    2.991536]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    2.991536]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    2.991536]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    2.991536]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    2.991536] ---[ end trace cfeb07101f6fbe03 ]---
[    3.015645] ------------[ cut here ]------------
[    3.016435] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.018100] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.018833] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.018833]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.018833]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.018833]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.018833] Call Trace:
[    3.018833]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.018833]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.018833]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.018833]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.018833]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.018833]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.018833]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.018833]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.018833]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.018833]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.018833]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.018833]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.018833]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.018833]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.018833]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.018833]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.018833]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.018833]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.018833] ---[ end trace cfeb07101f6fbe04 ]---
[    3.042898] ------------[ cut here ]------------
[    3.043683] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.045340] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.046094] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.046094]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.046094]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.046094]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.046094] Call Trace:
[    3.046094]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.046094]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.046094]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.046094]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.046094]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.046094]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.046094]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.046094]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.046094]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.046094]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.046094]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.046094]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.046094]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.046094]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.046094]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.046094]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.046094]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.046094]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.046094] ---[ end trace cfeb07101f6fbe05 ]---
[    3.070308] ------------[ cut here ]------------
[    3.071104] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.072758] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.073338] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.073338]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.073338]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.073338]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.073338] Call Trace:
[    3.073338]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.073338]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.073338]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.073338]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.073338]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.073338]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.073338]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.073338]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.073338]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.073338]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.073338]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.073338]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.073338]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.073338]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.073338]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.073338]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.073338]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.073338]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.073338] ---[ end trace cfeb07101f6fbe06 ]---
[    3.097558] ------------[ cut here ]------------
[    3.098345] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.100019] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.100740] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.100740]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.100740]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.100740]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.100740] Call Trace:
[    3.100740]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.100740]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.100740]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.100740]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.100740]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.100740]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.100740]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.100740]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.100740]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.100740]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.100740]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.100740]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.100740]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.100740]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.100740]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.100740]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.100740]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.100740]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.100740] ---[ end trace cfeb07101f6fbe07 ]---
[    3.125050] ------------[ cut here ]------------
[    3.125842] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.128105] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.128105] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.128105]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.128105]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.128105]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.128105] Call Trace:
[    3.128105]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.128105]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.128105]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.128105]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.128105]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.128105]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.128105]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.128105]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.128105]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.128105]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.128105]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.128105]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.128105]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.128105]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.128105]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.128105]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.128105]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.128105]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.128105] ---[ end trace cfeb07101f6fbe08 ]---
[    3.157699] ------------[ cut here ]------------
[    3.158490] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.160166] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.160865] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.160865]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.160865]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.160865]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.160865] Call Trace:
[    3.160865]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.160865]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.160865]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.160865]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.160865]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.160865]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.160865]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.160865]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.160865]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.160865]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.160865]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.160865]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.160865]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.160865]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.160865]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.160865]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.160865]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.160865]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.160865] ---[ end trace cfeb07101f6fbe09 ]---
[    3.185128] ------------[ cut here ]------------
[    3.185921] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.187593] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.188312] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.188312]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.188312]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.188312]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.188312] Call Trace:
[    3.188312]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.188312]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.188312]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.188312]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.188312]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.188312]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.188312]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.188312]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.188312]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.188312]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.188312]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.188312]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.188312]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.188312]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.188312]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.188312]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.188312]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.188312]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.188312] ---[ end trace cfeb07101f6fbe0a ]---
[    3.212448] ------------[ cut here ]------------
[    3.213246] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.214902] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.215650] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.215650]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.215650]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.215650]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.215650] Call Trace:
[    3.215650]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.215650]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.215650]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.215650]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.215650]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.215650]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.215650]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.215650]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.215650]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.215650]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.215650]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.215650]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.215650]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.215650]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.215650]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.215650]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.215650]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.215650]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.215650] ---[ end trace cfeb07101f6fbe0b ]---
[    3.239879] ------------[ cut here ]------------
[    3.240657] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.242307] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.243065] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.243065]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.243065]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.243065]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.243065] Call Trace:
[    3.243065]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.243065]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.243065]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.243065]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.243065]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.243065]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.243065]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.243065]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.243065]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.243065]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.243065]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.243065]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.243065]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.243065]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.243065]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.243065]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.243065]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.243065]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.243065] ---[ end trace cfeb07101f6fbe0c ]---
[    3.267308] ------------[ cut here ]------------
[    3.268101] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.269759] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.270333] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.270333]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.270333]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.270333]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.270333] Call Trace:
[    3.270333]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.270333]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.270333]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.270333]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.270333]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.270333]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.270333]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.270333]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.270333]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.270333]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.270333]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.270333]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.270333]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.270333]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.270333]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.270333]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.270333]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.270333]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.270333] ---[ end trace cfeb07101f6fbe0d ]---
[    3.300170] ------------[ cut here ]------------
[    3.300968] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.302624] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.303343] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.303343]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.303343]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.303343]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.303343] Call Trace:
[    3.303343]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.303343]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.303343]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.303343]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.303343]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.303343]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.303343]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.303343]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.303343]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.303343]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.303343]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.303343]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.303343]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.303343]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.303343]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.303343]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.303343]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.303343]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.303343] ---[ end trace cfeb07101f6fbe0e ]---
[    3.328619] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input3
[    3.330587] ------------[ cut here ]------------
[    3.331380] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.333022] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.333422] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.333422]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.333422]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.333422]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.333422] Call Trace:
[    3.333422]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.333422]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.333422]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.333422]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.333422]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.333422]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.333422]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.333422]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.333422]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.333422]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.333422]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.333422]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.333422]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.333422]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.333422]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.333422]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.333422]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.333422]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.333422] ---[ end trace cfeb07101f6fbe0f ]---
[    3.358571] ------------[ cut here ]------------
[    3.359373] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.361069] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.361688] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.361688]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.361688]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.361688]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.361688] Call Trace:
[    3.361688]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.361688]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.361688]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.361688]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.361688]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.361688]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.361688]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.361688]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.361688]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.361688]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.361688]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.361688]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.361688]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.361688]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.361688]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.361688]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.361688]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.361688]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.361688] ---[ end trace cfeb07101f6fbe10 ]---
[    3.386501] ------------[ cut here ]------------
[    3.387310] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.389010] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.389662] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.389662]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.389662]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.389662]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.389662] Call Trace:
[    3.389662]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.389662]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.389662]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.389662]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.389662]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.389662]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.389662]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.389662]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.389662]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.389662]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.389662]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.389662]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.389662]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.389662]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.389662]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.389662]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.389662]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.389662]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.389662] ---[ end trace cfeb07101f6fbe11 ]---
[    3.414541] ------------[ cut here ]------------
[    3.415348] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.417059] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.417713] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.417713]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.417713]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.417713]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.417713] Call Trace:
[    3.417713]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.417713]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.417713]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.417713]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.417713]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.417713]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.417713]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.417713]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.417713]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.417713]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.417713]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.417713]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.417713]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.417713]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.417713]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.417713]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.417713]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.417713]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.417713] ---[ end trace cfeb07101f6fbe12 ]---
[    3.442563] ------------[ cut here ]------------
[    3.443375] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.445081] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.445660] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.445660]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.445660]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.445660]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.445660] Call Trace:
[    3.445660]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.445660]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.445660]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.445660]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.445660]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.445660]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.445660]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.445660]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.445660]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.445660]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.445660]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.445660]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.445660]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.445660]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.445660]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.445660]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.445660]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.445660]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.445660] ---[ end trace cfeb07101f6fbe13 ]---
[    3.476342] ------------[ cut here ]------------
[    3.477159] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.478855] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.479530] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.479530]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.479530]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.479530]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.479530] Call Trace:
[    3.479530]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.479530]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.479530]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.479530]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.479530]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.479530]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.479530]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.479530]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.479530]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.479530]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.479530]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.479530]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.479530]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.479530]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.479530]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.479530]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.479530]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.479530]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.479530] ---[ end trace cfeb07101f6fbe14 ]---
[    3.504333] ------------[ cut here ]------------
[    3.505146] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.506852] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.507503] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.507503]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.507503]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.507503]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.507503] Call Trace:
[    3.507503]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.507503]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.507503]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.507503]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.507503]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.507503]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.507503]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.507503]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.507503]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.507503]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.507503]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.507503]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.507503]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.507503]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.507503]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.507503]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.507503]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.507503]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.507503] ---[ end trace cfeb07101f6fbe15 ]---
[    3.532356] ------------[ cut here ]------------
[    3.533168] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.534876] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.535497] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.535497]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.535497]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.535497]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.535497] Call Trace:
[    3.535497]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.535497]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.535497]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.535497]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.535497]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.535497]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.535497]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.535497]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.535497]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.535497]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.535497]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.535497]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.535497]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.535497]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.535497]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.535497]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.535497]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.535497]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.535497] ---[ end trace cfeb07101f6fbe16 ]---
[    3.560422] ------------[ cut here ]------------
[    3.561231] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.562947] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.563596] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.563596]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.563596]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.563596]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.563596] Call Trace:
[    3.563596]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.563596]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.563596]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.563596]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.563596]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.563596]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.563596]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.563596]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.563596]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.563596]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.563596]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.563596]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.563596]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.563596]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.563596]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.563596]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.563596]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.563596]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.563596] ---[ end trace cfeb07101f6fbe17 ]---
[    3.588495] ------------[ cut here ]------------
[    3.589312] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.591033] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.591664] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.591664]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.591664]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.591664]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.591664] Call Trace:
[    3.591664]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.591664]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.591664]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.591664]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.591664]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.591664]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.591664]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.591664]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.591664]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.591664]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.591664]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.591664]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.591664]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.591664]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.591664]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.591664]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.591664]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.591664]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.591664] ---[ end trace cfeb07101f6fbe18 ]---
[    3.622327] ------------[ cut here ]------------
[    3.623139] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.624839] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.625501] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.625501]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.625501]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.625501]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.625501] Call Trace:
[    3.625501]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.625501]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.625501]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.625501]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.625501]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.625501]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.625501]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.625501]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.625501]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.625501]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.625501]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.625501]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.625501]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.625501]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.625501]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.625501]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.625501]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.625501]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.625501] ---[ end trace cfeb07101f6fbe19 ]---
[    3.650369] ------------[ cut here ]------------
[    3.651182] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.652886] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.653523] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.653523]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.653523]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.653523]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.653523] Call Trace:
[    3.653523]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.653523]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.653523]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.653523]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.653523]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.653523]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.653523]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.653523]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.653523]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.653523]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.653523]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.653523]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.653523]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.653523]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.653523]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.653523]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.653523]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.653523]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.653523] ---[ end trace cfeb07101f6fbe1a ]---
[    3.678417] ------------[ cut here ]------------
[    3.679222] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.680922] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.681592] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.681592]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.681592]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.681592]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.681592] Call Trace:
[    3.681592]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.681592]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.681592]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.681592]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.681592]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.681592]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.681592]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.681592]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.681592]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.681592]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.681592]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.681592]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.681592]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.681592]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.681592]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.681592]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.681592]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.681592]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.681592] ---[ end trace cfeb07101f6fbe1b ]---
[    3.706417] ------------[ cut here ]------------
[    3.707229] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.708938] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.709598] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.709598]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.709598]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.709598]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.709598] Call Trace:
[    3.709598]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.709598]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.709598]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.709598]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.709598]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.709598]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.709598]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.709598]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.709598]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.709598]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.709598]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.709598]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.709598]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.709598]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.709598]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.709598]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.709598]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.709598]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.709598] ---[ end trace cfeb07101f6fbe1c ]---
[    3.734430] ------------[ cut here ]------------
[    3.735242] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.736947] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.737623] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.737623]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.737623]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.737623]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.737623] Call Trace:
[    3.737623]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.737623]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.737623]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.737623]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.737623]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.737623]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.737623]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.737623]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.737623]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.737623]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.737623]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.737623]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.737623]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.737623]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.737623]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.737623]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.737623]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.737623]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.737623] ---[ end trace cfeb07101f6fbe1d ]---
[    3.762399] ------------[ cut here ]------------
[    3.763215] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.764929] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.765574] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.765574]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.765574]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.765574]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.765574] Call Trace:
[    3.765574]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.765574]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.765574]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.765574]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.765574]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.765574]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.765574]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.765574]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.765574]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.765574]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.765574]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.765574]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.765574]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.765574]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.765574]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.765574]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.765574]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.765574]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.765574] ---[ end trace cfeb07101f6fbe1e ]---
[    3.796172] ------------[ cut here ]------------
[    3.796988] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.798682] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.799353] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.799353]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.799353]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.799353]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.799353] Call Trace:
[    3.799353]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.799353]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.799353]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.799353]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.799353]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.799353]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.799353]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.799353]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.799353]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.799353]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.799353]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.799353]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.799353]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.799353]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.799353]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.799353]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.799353]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.799353]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.799353] ---[ end trace cfeb07101f6fbe1f ]---
[    3.824182] ------------[ cut here ]------------
[    3.824992] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.826694] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.827354] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.827354]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.827354]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.827354]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.827354] Call Trace:
[    3.827354]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.827354]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.827354]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.827354]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.827354]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.827354]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.827354]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.827354]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.827354]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.827354]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.827354]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.827354]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.827354]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.827354]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.827354]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.827354]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.827354]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.827354]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.827354] ---[ end trace cfeb07101f6fbe20 ]---
[    3.852223] ------------[ cut here ]------------
[    3.853087] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.854765] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.855400] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.855400]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.855400]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.855400]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.855400] Call Trace:
[    3.855400]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.855400]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.855400]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.855400]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.855400]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.855400]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.855400]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.855400]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.855400]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.855400]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.855400]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.855400]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.855400]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.855400]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.855400]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.855400]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.855400]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.855400]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.855400] ---[ end trace cfeb07101f6fbe21 ]---
[    3.879650] ------------[ cut here ]------------
[    3.880441] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.882093] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.882801] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.882801]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.882801]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.882801]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.882801] Call Trace:
[    3.882801]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.882801]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.882801]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.882801]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.882801]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.882801]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.882801]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.882801]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.882801]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.882801]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.882801]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.882801]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.882801]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.882801]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.882801]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.882801]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.882801]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.882801]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.882801] ---[ end trace cfeb07101f6fbe22 ]---
[    3.907044] ------------[ cut here ]------------
[    3.907831] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.909482] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.910226] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.910226]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.910226]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.910226]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.910226] Call Trace:
[    3.910226]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.910226]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.910226]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.910226]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.910226]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.910226]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.910226]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.910226]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.910226]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.910226]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.910226]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.910226]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.910226]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.910226]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.910226]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.910226]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.910226]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.910226]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.910226] ---[ end trace cfeb07101f6fbe23 ]---
[    3.934439] ------------[ cut here ]------------
[    3.935229] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.936902] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.937600] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.937600]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.937600]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.937600]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.937600] Call Trace:
[    3.937600]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.937600]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.937600]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.937600]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.937600]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.937600]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.937600]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.937600]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.937600]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.937600]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.937600]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.937600]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.937600]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.937600]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.937600]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.937600]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.937600]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.937600]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.937600] ---[ end trace cfeb07101f6fbe24 ]---
[    3.967080] ------------[ cut here ]------------
[    3.967871] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.969539] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.970253] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.970253]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.970253]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.970253]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.970253] Call Trace:
[    3.970253]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.970253]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.970253]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.970253]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.970253]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.970253]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.970253]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.970253]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.970253]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.970253]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.970253]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.970253]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.970253]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.970253]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.970253]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.970253]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.970253]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.970253]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.970253] ---[ end trace cfeb07101f6fbe25 ]---
[    3.994400] ------------[ cut here ]------------
[    3.995187] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    3.996865] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    3.997585] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.997585]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    3.997585]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    3.997585]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    3.997585] Call Trace:
[    3.997585]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    3.997585]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    3.997585]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    3.997585]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    3.997585]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    3.997585]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    3.997585]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    3.997585]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    3.997585]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    3.997585]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    3.997585]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    3.997585]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    3.997585]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    3.997585]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    3.997585]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    3.997585]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    3.997585]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    3.997585]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    3.997585] ---[ end trace cfeb07101f6fbe26 ]---
[    4.021692] ------------[ cut here ]------------
[    4.022473] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.024133] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.024867] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.024867]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    4.024867]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.024867]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    4.024867] Call Trace:
[    4.024867]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.024867]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.024867]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.024867]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.024867]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.024867]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.024867]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.024867]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.024867]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.024867]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.024867]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.024867]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.024867]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.024867]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.024867]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.024867]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.024867]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.024867]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.024867] ---[ end trace cfeb07101f6fbe27 ]---
[    4.048950] ------------[ cut here ]------------
[    4.049733] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.051400] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.052132] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.052132]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    4.052132]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.052132]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    4.052132] Call Trace:
[    4.052132]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.052132]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.052132]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.052132]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.052132]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.052132]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.052132]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.052132]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.052132]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.052132]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.052132]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.052132]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.052132]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.052132]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.052132]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.052132]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.052132]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.052132]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.052132] ---[ end trace cfeb07101f6fbe28 ]---
[    4.076332] ------------[ cut here ]------------
[    4.077121] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.078774] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.079511] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.079511]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    4.079511]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.079511]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    4.079511] Call Trace:
[    4.079511]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.079511]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.079511]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.079511]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.079511]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.079511]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.079511]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.079511]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.079511]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.079511]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.079511]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.079511]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.079511]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.079511]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.079511]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.079511]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.079511]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.079511]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.079511] ---[ end trace cfeb07101f6fbe29 ]---
[    4.108935] ------------[ cut here ]------------
[    4.109723] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.111380] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.112106] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.112106]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    4.112106]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.112106]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    4.112106] Call Trace:
[    4.112106]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.112106]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.112106]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.112106]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.112106]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.112106]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.112106]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.112106]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.112106]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.112106]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.112106]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.112106]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.112106]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.112106]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.112106]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.112106]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.112106]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.112106]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.112106] ---[ end trace cfeb07101f6fbe2a ]---
[    4.136334] random: init urandom read with 5 bits of entropy available
[    4.138026] ------------[ cut here ]------------
[    4.138826] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.140485] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.140698] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.140698]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    4.140698]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.140698]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    4.140698] Call Trace:
[    4.140698]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.140698]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.140698]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.140698]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.140698]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.140698]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.140698]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.140698]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.140698]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.140698]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.140698]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.140698]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.140698]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.140698]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.140698]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.140698]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.140698]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.140698]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.140698] ---[ end trace cfeb07101f6fbe2b ]---
[    4.165312] ------------[ cut here ]------------
[    4.166107] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.167804] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.168550] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.168550]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    4.168550]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.168550]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    4.168550] Call Trace:
[    4.168550]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.168550]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.168550]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.168550]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.168550]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.168550]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.168550]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.168550]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.168550]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.168550]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    4.168550]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    4.168550]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    4.168550]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    4.168550]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    4.168550]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    4.168550]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    4.168550]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    4.168550]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    4.168550]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    4.168550]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    4.168550]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    4.168550]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    4.168550]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    4.168550]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    4.168550]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    4.168550]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    4.168550]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    4.168550]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    4.168550]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    4.168550]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    4.168550]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    4.168550]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.168550] ---[ end trace cfeb07101f6fbe2c ]---
[    4.205577] ------------[ cut here ]------------
[    4.206363] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.208021] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.208804] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.208804]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    4.208804]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.208804]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    4.208804] Call Trace:
[    4.208804]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.208804]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.208804]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.208804]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.208804]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.208804]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.208804]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.208804]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.208804]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.208804]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.208804]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.208804]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.208804]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.208804]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.208804]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.208804]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.208804]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.208804]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.208804] ---[ end trace cfeb07101f6fbe2d ]---
[    4.233803] ------------[ cut here ]------------
[    4.234607] WARNING: CPU: 0 PID: 100 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.236289] CPU: 0 PID: 100 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    4.236676] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.236676]  0000000000000000 ffff88000b7cf9c0 ffffffff81a23b9d ffff8800=
0b7cf9f8
[    4.236676]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[    4.236676]  0000000000000001 ffff88001200fa01 ffff88000b7cfa08 ffffffff=
810bc84b
[    4.236676] Call Trace:
[    4.236676]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.236676]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.236676]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.236676]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.236676]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.236676]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.236676]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.236676]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.236676]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.236676]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.236676]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.236676]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.236676]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    4.236676]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    4.236676]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    4.236676]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    4.236676]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    4.236676]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    4.236676]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    4.236676]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    4.236676]  [<ffffffff811dd4bd>] load_script+0x1e6/0x208
[    4.236676]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    4.236676]  [<ffffffff810f78bf>] ? do_raw_read_unlock+0x2b/0x44
[    4.236676]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    4.236676]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    4.236676]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    4.236676]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    4.236676]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    4.236676] ---[ end trace cfeb07101f6fbe2e ]---
[    4.276034] ------------[ cut here ]------------
[    4.276846] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.278504] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.278835] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.278835]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    4.278835]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.278835]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    4.278835] Call Trace:
[    4.278835]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.278835]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.278835]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.278835]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.278835]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.278835]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.278835]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.278835]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.278835]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.278835]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    4.278835]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    4.278835]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    4.278835]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    4.278835]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    4.278835]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    4.278835]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    4.278835]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    4.278835]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    4.278835]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    4.278835]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    4.278835]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    4.278835]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    4.278835]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    4.278835]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    4.278835]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    4.278835]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    4.278835]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    4.278835]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    4.278835]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    4.278835]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    4.278835]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    4.278835]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.278835] ---[ end trace cfeb07101f6fbe2f ]---
[    4.317675] ------------[ cut here ]------------
[    4.318482] WARNING: CPU: 0 PID: 100 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.320010] CPU: 0 PID: 100 Comm: rc.local Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    4.320010] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.320010]  0000000000000000 ffff88000b7cfc50 ffffffff81a23b9d ffff8800=
0b7cfc88
[    4.320010]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.320010]  0000000000000001 ffff88001200fa01 ffff88000b7cfc98 ffffffff=
810bc84b
[    4.320010] Call Trace:
[    4.320010]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.320010]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.320010]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.320010]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.320010]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.320010]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.320010]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.320010]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.320010]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.320010]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.320010]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.320010]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.320010]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.320010]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.320010]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.320010]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.320010]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.320010]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.320010] ---[ end trace cfeb07101f6fbe30 ]---
[    4.345994] ------------[ cut here ]------------
[    4.346815] WARNING: CPU: 0 PID: 100 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.348525] CPU: 0 PID: 100 Comm: rc.local Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    4.348753] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.348753]  0000000000000000 ffff88000b7cfc50 ffffffff81a23b9d ffff8800=
0b7cfc88
[    4.348753]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.348753]  0000000000000001 ffff88001200fa01 ffff88000b7cfc98 ffffffff=
810bc84b
[    4.348753] Call Trace:
[    4.348753]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.348753]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.348753]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.348753]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.348753]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.348753]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.348753]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.348753]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.348753]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.348753]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.348753]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.348753]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.348753]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.348753]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.348753]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.348753]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.348753]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.348753]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.348753] ---[ end trace cfeb07101f6fbe31 ]---
[    4.374143] ------------[ cut here ]------------
[    4.374955] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.376662] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.377315] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.377315]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    4.377315]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.377315]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    4.377315] Call Trace:
[    4.377315]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.377315]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.377315]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.377315]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.377315]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.377315]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.377315]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.377315]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.377315]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.377315]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.377315]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.377315]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.377315]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.377315]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.377315]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.377315]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.377315]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.377315]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.377315] ---[ end trace cfeb07101f6fbe32 ]---
[    4.404656] ------------[ cut here ]------------
[    4.405467] WARNING: CPU: 0 PID: 101 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.406691] CPU: 0 PID: 101 Comm: rc.local Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    4.406691] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.406691]  0000000000000000 ffff88000b7ebaa8 ffffffff81a23b9d ffff8800=
0b7ebae0
[    4.406691]  ffffffff810bc765 ffffffff8111fac8 0000000000013000 ffff8800=
1200fa50
[    4.406691]  0000000000000001 ffff88001200fa01 ffff88000b7ebaf0 ffffffff=
810bc84b
[    4.406691] Call Trace:
[    4.406691]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.406691]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.406691]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.406691]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.406691]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.406691]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.406691]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.406691]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.406691]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.406691]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.406691]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.406691]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.406691]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    4.406691]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    4.406691]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    4.406691]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    4.406691]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    4.406691]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    4.406691]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    4.406691]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    4.406691]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    4.406691]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    4.406691]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    4.406691]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    4.406691] ---[ end trace cfeb07101f6fbe33 ]---
[    4.442869] ------------[ cut here ]------------
[    4.443652] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.445312] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.445996] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.445996]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    4.445996]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.445996]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    4.445996] Call Trace:
[    4.445996]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.445996]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.445996]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.445996]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.445996]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.445996]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.445996]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.445996]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.445996]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.445996]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    4.445996]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    4.445996]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    4.445996]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    4.445996]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    4.445996]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    4.445996]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    4.445996]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    4.445996]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    4.445996]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    4.445996]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    4.445996]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    4.445996]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    4.445996]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    4.445996]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    4.445996]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    4.445996]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    4.445996]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    4.445996]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    4.445996]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    4.445996]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    4.445996]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    4.445996]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.445996] ---[ end trace cfeb07101f6fbe34 ]---
[    4.484094] ------------[ cut here ]------------
[    4.484904] WARNING: CPU: 0 PID: 102 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.486584] CPU: 0 PID: 102 Comm: run-parts Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[    4.486677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.486677]  0000000000000000 ffff88000b0139c0 ffffffff81a23b9d ffff8800=
0b0139f8
[    4.486677]  ffffffff810bc765 ffffffff8111fac8 0000000000002000 ffff8800=
1200fa50
[    4.486677]  0000000000000001 ffff88001200fa01 ffff88000b013a08 ffffffff=
810bc84b
[    4.486677] Call Trace:
[    4.486677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.486677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.486677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.486677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.486677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.486677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.486677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.486677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.486677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.486677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.486677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.486677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.486677]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    4.486677]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    4.486677]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    4.486677]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    4.486677]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    4.486677]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    4.486677]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    4.486677]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    4.486677]  [<ffffffff811dd4bd>] load_script+0x1e6/0x208
[    4.486677]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    4.486677]  [<ffffffff810f78bf>] ? do_raw_read_unlock+0x2b/0x44
[    4.486677]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    4.486677]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    4.486677]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    4.486677]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    4.486677]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    4.486677] ---[ end trace cfeb07101f6fbe35 ]---
[    4.520420] ------------[ cut here ]------------
[    4.521202] WARNING: CPU: 0 PID: 102 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.522884] CPU: 0 PID: 102 Comm: run-parts Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[    4.523706] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.523706]  0000000000000000 ffff88000b0139c0 ffffffff81a23b9d ffff8800=
0b0139f8
[    4.523706]  ffffffff810bc765 ffffffff8111fac8 0000000000006000 ffff8800=
1200fa50
[    4.523706]  0000000000000001 ffff88001200fa01 ffff88000b013a08 ffffffff=
810bc84b
[    4.523706] Call Trace:
[    4.523706]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.523706]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.523706]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.523706]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.523706]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.523706]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.523706]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.523706]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.523706]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.523706]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.523706]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.523706]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.523706]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    4.523706]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    4.523706]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    4.523706]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    4.523706]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    4.523706]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    4.523706]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    4.523706]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    4.523706]  [<ffffffff811dd4bd>] load_script+0x1e6/0x208
[    4.523706]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    4.523706]  [<ffffffff810f78bf>] ? do_raw_read_unlock+0x2b/0x44
[    4.523706]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    4.523706]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    4.523706]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    4.523706]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    4.523706]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    4.523706] ---[ end trace cfeb07101f6fbe36 ]---
[    4.556778] ------------[ cut here ]------------
[    4.557555] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.559227] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.560008] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.560008]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    4.560008]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.560008]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    4.560008] Call Trace:
[    4.560008]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.560008]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.560008]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.560008]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.560008]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.560008]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.560008]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.560008]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.560008]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.560008]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.560008]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.560008]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.560008]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.560008]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.560008]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.560008]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.560008]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.560008]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.560008] ---[ end trace cfeb07101f6fbe37 ]---
[    4.584765] ------------[ cut here ]------------
[    4.585549] WARNING: CPU: 0 PID: 103 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.587240] CPU: 0 PID: 103 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    4.587289] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.587289]  0000000000000000 ffff88000b027aa8 ffffffff81a23b9d ffff8800=
0b027ae0
[    4.587289]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[    4.587289]  0000000000000001 ffff88001200fa01 ffff88000b027af0 ffffffff=
810bc84b
[    4.587289] Call Trace:
[    4.587289]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.587289]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.587289]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.587289]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.587289]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.587289]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.587289]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.587289]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.587289]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.587289]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.587289]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.587289]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.587289]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    4.587289]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    4.587289]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    4.587289]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    4.587289]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    4.587289]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    4.587289]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    4.587289]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    4.587289]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    4.587289]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    4.587289]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    4.587289]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    4.587289] ---[ end trace cfeb07101f6fbe38 ]---
[    4.623216] ------------[ cut here ]------------
[    4.624016] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.625666] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.626088] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.626088]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    4.626088]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.626088]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    4.626088] Call Trace:
[    4.626088]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.626088]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.626088]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.626088]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.626088]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.626088]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.626088]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.626088]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.626088]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.626088]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    4.626088]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    4.626088]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    4.626088]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    4.626088]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    4.626088]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    4.626088]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    4.626088]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    4.626088]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    4.626088]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    4.626088]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    4.626088]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    4.626088]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    4.626088]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    4.626088]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    4.626088]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    4.626088]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    4.626088]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    4.626088]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    4.626088]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    4.626088]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    4.626088]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    4.626088]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.626088] ---[ end trace cfeb07101f6fbe39 ]---
[    4.664219] ------------[ cut here ]------------
[    4.665023] WARNING: CPU: 0 PID: 103 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.666674] CPU: 0 PID: 103 Comm: hostname Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    4.666674] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.666674]  0000000000000000 ffff88000b027c50 ffffffff81a23b9d ffff8800=
0b027c88
[    4.666674]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.666674]  0000000000000001 ffff88001200fa01 ffff88000b027c98 ffffffff=
810bc84b
[    4.666674] Call Trace:
[    4.666674]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.666674]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.666674]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.666674]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.666674]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.666674]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.666674]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.666674]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.666674]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.666674]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.666674]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.666674]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.666674]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.666674]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.666674]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.666674]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.666674]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.666674]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.666674] ---[ end trace cfeb07101f6fbe3a ]---
[    4.693253] ------------[ cut here ]------------
[    4.694058] WARNING: CPU: 0 PID: 102 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.695155] CPU: 0 PID: 102 Comm: 99-trinity Tainted: G        W     3.1=
6.0-rc1-00238-gddc5bfe #1
[    4.695155] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.695155]  0000000000000000 ffff88000b013c50 ffffffff81a23b9d ffff8800=
0b013c88
[    4.695155]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.695155]  0000000000000001 ffff88001200fa01 ffff88000b013c98 ffffffff=
810bc84b
[    4.695155] Call Trace:
[    4.695155]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.695155]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.695155]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.695155]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.695155]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.695155]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.695155]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.695155]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.695155]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.695155]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.695155]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.695155]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.695155]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.695155]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.695155]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.695155]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.695155]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.695155]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.695155] ---[ end trace cfeb07101f6fbe3b ]---
[    4.720863] ------------[ cut here ]------------
[    4.721655] WARNING: CPU: 0 PID: 103 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.723347] CPU: 0 PID: 103 Comm: hostname Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    4.723916] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.723916]  0000000000000000 ffff88000b027c48 ffffffff81a23b9d ffff8800=
0b027c80
[    4.723916]  ffffffff810bc765 ffffffff8111fac8 0000000000003000 ffff8800=
1200fa50
[    4.723916]  0000000000000001 ffff88001200fa01 ffff88000b027c90 ffffffff=
810bc84b
[    4.723916] Call Trace:
[    4.723916]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.723916]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.723916]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.723916]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.723916]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.723916]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.723916]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.723916]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.723916]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.723916]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.723916]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.723916]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.723916]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    4.723916]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    4.723916]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    4.723916]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    4.723916]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    4.723916]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    4.723916]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.723916] ---[ end trace cfeb07101f6fbe3c ]---
[    4.748905] ------------[ cut here ]------------
[    4.749678] WARNING: CPU: 0 PID: 103 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.751359] CPU: 0 PID: 103 Comm: hostname Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    4.752185] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.752185]  0000000000000000 ffff88000b027c48 ffffffff81a23b9d ffff8800=
0b027c80
[    4.752185]  ffffffff810bc765 ffffffff8111fac8 0000000000015000 ffff8800=
1200fa50
[    4.752185]  0000000000000001 ffff88001200fa01 ffff88000b027c90 ffffffff=
810bc84b
[    4.752185] Call Trace:
[    4.752185]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.752185]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.752185]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.752185]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.752185]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.752185]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.752185]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.752185]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.752185]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.752185]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.752185]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.752185]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.752185]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    4.752185]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    4.752185]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    4.752185]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    4.752185]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    4.752185]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    4.752185]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.752185] ---[ end trace cfeb07101f6fbe3d ]---
[    4.782511] ------------[ cut here ]------------
[    4.783310] WARNING: CPU: 0 PID: 102 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.785001] CPU: 0 PID: 102 Comm: 99-trinity Tainted: G        W     3.1=
6.0-rc1-00238-gddc5bfe #1
[    4.785457] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.785457]  0000000000000000 ffff88000b013c50 ffffffff81a23b9d ffff8800=
0b013c88
[    4.785457]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.785457]  0000000000000001 ffff88001200fa01 ffff88000b013c98 ffffffff=
810bc84b
[    4.785457] Call Trace:
[    4.785457]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.785457]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.785457]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.785457]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.785457]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.785457]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.785457]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.785457]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.785457]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.785457]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.785457]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.785457]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.785457]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.785457]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.785457]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.785457]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.785457]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.785457]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.785457] ---[ end trace cfeb07101f6fbe3e ]---
[    4.809998] ------------[ cut here ]------------
[    4.810790] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.812445] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.813209] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.813209]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    4.813209]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.813209]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    4.813209] Call Trace:
[    4.813209]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.813209]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.813209]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.813209]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.813209]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.813209]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.813209]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.813209]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.813209]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.813209]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.813209]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.813209]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.813209]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.813209]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.813209]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.813209]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.813209]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.813209]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.813209] ---[ end trace cfeb07101f6fbe3f ]---
[    4.839268] ------------[ cut here ]------------
[    4.840079] WARNING: CPU: 0 PID: 104 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.840631] CPU: 0 PID: 104 Comm: 99-trinity Tainted: G        W     3.1=
6.0-rc1-00238-gddc5bfe #1
[    4.840631] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.840631]  0000000000000000 ffff88000b03baa8 ffffffff81a23b9d ffff8800=
0b03bae0
[    4.840631]  ffffffff810bc765 ffffffff8111fac8 0000000000014000 ffff8800=
1200fa50
[    4.840631]  0000000000000001 ffff88001200fa01 ffff88000b03baf0 ffffffff=
810bc84b
[    4.840631] Call Trace:
[    4.840631]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.840631]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.840631]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.840631]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.840631]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.840631]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.840631]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.840631]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.840631]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.840631]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.840631]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.840631]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.840631]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    4.840631]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    4.840631]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    4.840631]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    4.840631]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    4.840631]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    4.840631]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    4.840631]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    4.840631]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    4.840631]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    4.840631]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    4.840631]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    4.840631] ---[ end trace cfeb07101f6fbe40 ]---
[    4.872302] ------------[ cut here ]------------
[    4.873095] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.874773] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.875434] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.875434]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    4.875434]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.875434]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    4.875434] Call Trace:
[    4.875434]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.875434]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.875434]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.875434]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.875434]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.875434]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.875434]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.875434]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.875434]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.875434]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    4.875434]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    4.875434]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    4.875434]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    4.875434]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    4.875434]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    4.875434]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    4.875434]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    4.875434]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    4.875434]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    4.875434]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    4.875434]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    4.875434]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    4.875434]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    4.875434]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    4.875434]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    4.875434]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    4.875434]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    4.875434]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    4.875434]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    4.875434]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    4.875434]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    4.875434]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.875434] ---[ end trace cfeb07101f6fbe41 ]---
[    4.912501] hostname (103) used greatest stack depth: 13320 bytes left
[    4.914645] ------------[ cut here ]------------
[    4.915445] WARNING: CPU: 0 PID: 104 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.916857] CPU: 0 PID: 104 Comm: grep Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    4.916857] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.916857]  0000000000000000 ffff88000b03bc48 ffffffff81a23b9d ffff8800=
0b03bc80
[    4.916857]  ffffffff810bc765 ffffffff8111fac8 000000000001d000 ffff8800=
1200fa50
[    4.916857]  0000000000000001 ffff88001200fa01 ffff88000b03bc90 ffffffff=
810bc84b
[    4.916857] Call Trace:
[    4.916857]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.916857]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.916857]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.916857]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.916857]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.916857]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.916857]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.916857]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.916857]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.916857]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.916857]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.916857]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.916857]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    4.916857]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    4.916857]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    4.916857]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    4.916857]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    4.916857]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    4.916857]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.916857] ---[ end trace cfeb07101f6fbe42 ]---
[    4.948010] ------------[ cut here ]------------
[    4.948804] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    4.950449] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    4.951108] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.951108]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    4.951108]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    4.951108]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    4.951108] Call Trace:
[    4.951108]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.951108]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.951108]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.951108]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.951108]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.951108]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.951108]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.951108]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.951108]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.951108]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.951108]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.951108]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.951108]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    4.951108]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    4.951108]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    4.951108]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    4.951108]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    4.951108]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    4.951108] ---[ end trace cfeb07101f6fbe43 ]---
[    4.977391] ------------[ cut here ]------------
[    4.978188] WARNING: CPU: 0 PID: 107 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    4.979869] CPU: 0 PID: 107 Comm: 99-trinity Tainted: G        W     3.1=
6.0-rc1-00238-gddc5bfe #1
[    4.980012] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.980012]  0000000000000000 ffff88000b067aa8 ffffffff81a23b9d ffff8800=
0b067ae0
[    4.980012]  ffffffff810bc765 ffffffff8111fac8 0000000000013000 ffff8800=
1200fa50
[    4.980012]  0000000000000001 ffff88001200fa01 ffff88000b067af0 ffffffff=
810bc84b
[    4.980012] Call Trace:
[    4.980012]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    4.980012]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    4.980012]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    4.980012]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    4.980012]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    4.980012]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    4.980012]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    4.980012]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    4.980012]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    4.980012]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    4.980012]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    4.980012]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    4.980012]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    4.980012]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    4.980012]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    4.980012]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    4.980012]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    4.980012]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    4.980012]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    4.980012]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    4.980012]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    4.980012]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    4.980012]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    4.980012]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    4.980012] ---[ end trace cfeb07101f6fbe44 ]---
[    5.010800] ------------[ cut here ]------------
[    5.011584] WARNING: CPU: 0 PID: 108 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.013276] CPU: 0 PID: 108 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    5.013339] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.013339]  0000000000000000 ffff88000b08baa8 ffffffff81a23b9d ffff8800=
0b08bae0
[    5.013339]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[    5.013339]  0000000000000001 ffff88001200fa01 ffff88000b08baf0 ffffffff=
810bc84b
[    5.013339] Call Trace:
[    5.013339]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.013339]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.013339]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.013339]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.013339]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.013339]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.013339]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.013339]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.013339]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.013339]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.013339]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.013339]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.013339]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.013339]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.013339]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    5.013339]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    5.013339]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    5.013339]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    5.013339]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    5.013339]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    5.013339]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    5.013339]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    5.013339]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    5.013339]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    5.013339] ---[ end trace cfeb07101f6fbe45 ]---
[    5.043734] ------------[ cut here ]------------
[    5.044524] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    5.046200] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.046674] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.046674]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    5.046674]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.046674]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    5.046674] Call Trace:
[    5.046674]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.046674]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.046674]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.046674]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.046674]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.046674]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.046674]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.046674]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.046674]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.046674]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    5.046674]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    5.046674]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    5.046674]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    5.046674]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    5.046674]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    5.046674]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    5.046674]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    5.046674]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    5.046674]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    5.046674]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    5.046674]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    5.046674]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    5.046674]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    5.046674]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    5.046674]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    5.046674]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    5.046674]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    5.046674]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    5.046674]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    5.046674]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    5.046674]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    5.046674]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.046674] ---[ end trace cfeb07101f6fbe46 ]---
[    5.089990] ------------[ cut here ]------------
[    5.090789] WARNING: CPU: 0 PID: 106 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.092482] CPU: 0 PID: 106 Comm: 99-trinity Tainted: G        W     3.1=
6.0-rc1-00238-gddc5bfe #1
[    5.092727] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.092727]  0000000000000000 ffff88000b03baa8 ffffffff81a23b9d ffff8800=
0b03bae0
[    5.092727]  ffffffff810bc765 ffffffff8111fac8 0000000000014000 ffff8800=
1200fa50
[    5.092727]  0000000000000001 ffff88001200fa01 ffff88000b03baf0 ffffffff=
810bc84b
[    5.092727] Call Trace:
[    5.092727]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.092727]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.092727]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.092727]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.092727]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.092727]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.092727]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.092727]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.092727]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.092727]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.092727]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.092727]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.092727]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.092727]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.092727]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    5.092727]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    5.092727]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    5.092727]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    5.092727]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    5.092727]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    5.092727]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    5.092727]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    5.092727]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    5.092727]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    5.092727] ---[ end trace cfeb07101f6fbe47 ]---
[    5.124478] ------------[ cut here ]------------
[    5.125280] WARNING: CPU: 0 PID: 106 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.126678] CPU: 0 PID: 106 Comm: grep Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    5.126678] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.126678]  0000000000000000 ffff88000b03bc48 ffffffff81a23b9d ffff8800=
0b03bc80
[    5.126678]  ffffffff810bc765 ffffffff8111fac8 000000000001e000 ffff8800=
1200fa50
[    5.126678]  0000000000000001 ffff88001200fa01 ffff88000b03bc90 ffffffff=
810bc84b
[    5.126678] Call Trace:
[    5.126678]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.126678]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.126678]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.126678]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.126678]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.126678]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.126678]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.126678]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.126678]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.126678]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.126678]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.126678]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.126678]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.126678]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.126678]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    5.126678]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    5.126678]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    5.126678]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    5.126678]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.126678] ---[ end trace cfeb07101f6fbe48 ]---
[    5.152891] ------------[ cut here ]------------
[    5.153671] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    5.155344] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.155999] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.155999]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    5.155999]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.155999]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    5.155999] Call Trace:
[    5.155999]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.155999]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.155999]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.155999]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.155999]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.155999]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.155999]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.155999]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.155999]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.155999]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.155999]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.155999]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.155999]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    5.155999]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    5.155999]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    5.155999]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    5.155999]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    5.155999]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.155999] ---[ end trace cfeb07101f6fbe49 ]---
[    5.180661] ------------[ cut here ]------------
[    5.181457] WARNING: CPU: 0 PID: 107 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.183159] CPU: 0 PID: 107 Comm: cut Tainted: G        W     3.16.0-rc1=
-00238-gddc5bfe #1
[    5.183523] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.183523]  0000000000000000 ffff88000b067c48 ffffffff81a23b9d ffff8800=
0b067c80
[    5.183523]  ffffffff810bc765 ffffffff8111fac8 0000000000016000 ffff8800=
1200fa50
[    5.183523]  0000000000000001 ffff88001200fa01 ffff88000b067c90 ffffffff=
810bc84b
[    5.183523] Call Trace:
[    5.183523]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.183523]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.183523]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.183523]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.183523]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.183523]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.183523]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.183523]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.183523]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.183523]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.183523]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.183523]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.183523]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.183523]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.183523]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    5.183523]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    5.183523]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    5.183523]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    5.183523]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.183523] ---[ end trace cfeb07101f6fbe4a ]---
[    5.208824] ------------[ cut here ]------------
[    5.209602] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    5.211265] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.211987] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.211987]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    5.211987]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.211987]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    5.211987] Call Trace:
[    5.211987]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.211987]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.211987]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.211987]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.211987]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.211987]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.211987]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.211987]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.211987]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.211987]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    5.211987]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    5.211987]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    5.211987]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    5.211987]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    5.211987]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    5.211987]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    5.211987]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    5.211987]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    5.211987]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    5.211987]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    5.211987]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    5.211987]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    5.211987]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    5.211987]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    5.211987]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    5.211987]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    5.211987]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    5.211987]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    5.211987]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    5.211987]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    5.211987]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    5.211987]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.211987] ---[ end trace cfeb07101f6fbe4b ]---
[    5.254888] ------------[ cut here ]------------
[    5.255676] WARNING: CPU: 0 PID: 105 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.257370] CPU: 0 PID: 105 Comm: 99-trinity Tainted: G        W     3.1=
6.0-rc1-00238-gddc5bfe #1
[    5.257611] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.257611]  0000000000000000 ffff88000b04fc48 ffffffff81a23b9d ffff8800=
0b04fc80
[    5.257611]  ffffffff810bc765 ffffffff8111fac8 000000000001c000 ffff8800=
1200fa50
[    5.257611]  0000000000000001 ffff88001200fa01 ffff88000b04fc90 ffffffff=
810bc84b
[    5.257611] Call Trace:
[    5.257611]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.257611]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.257611]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.257611]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.257611]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.257611]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.257611]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.257611]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.257611]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.257611]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.257611]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.257611]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.257611]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.257611]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.257611]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    5.257611]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    5.257611]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    5.257611]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    5.257611]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.257611] ---[ end trace cfeb07101f6fbe4c ]---
[    5.283090] ------------[ cut here ]------------
[    5.283878] WARNING: CPU: 0 PID: 105 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.285557] CPU: 0 PID: 105 Comm: 99-trinity Tainted: G        W     3.1=
6.0-rc1-00238-gddc5bfe #1
[    5.286334] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.286334]  0000000000000000 ffff88000b04fc48 ffffffff81a23b9d ffff8800=
0b04fc80
[    5.286334]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[    5.286334]  0000000000000001 ffff88001200fa01 ffff88000b04fc90 ffffffff=
810bc84b
[    5.286334] Call Trace:
[    5.286334]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.286334]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.286334]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.286334]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.286334]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.286334]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.286334]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.286334]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.286334]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.286334]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.286334]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.286334]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.286334]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.286334]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.286334]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    5.286334]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    5.286334]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    5.286334]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    5.286334]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.286334] ---[ end trace cfeb07101f6fbe4d ]---
[    5.311325] ------------[ cut here ]------------
[    5.312124] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    5.313794] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.314455] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.314455]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    5.314455]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.314455]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    5.314455] Call Trace:
[    5.314455]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.314455]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.314455]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.314455]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.314455]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.314455]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.314455]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.314455]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.314455]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.314455]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.314455]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.314455]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.314455]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    5.314455]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    5.314455]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    5.314455]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    5.314455]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    5.314455]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.314455] ---[ end trace cfeb07101f6fbe4e ]---
[    5.339310] ------------[ cut here ]------------
[    5.340124] WARNING: CPU: 0 PID: 109 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.341954] CPU: 0 PID: 109 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    5.342037] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.342037]  0000000000000000 ffff88000b03baa8 ffffffff81a23b9d ffff8800=
0b03bae0
[    5.342037]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[    5.342037]  0000000000000001 ffff88001200fa01 ffff88000b03baf0 ffffffff=
810bc84b
[    5.342037] Call Trace:
[    5.342037]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.342037]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.342037]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.342037]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.342037]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.342037]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.342037]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.342037]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.342037]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.342037]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.342037]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.342037]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.342037]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.342037]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.342037]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    5.342037]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    5.342037]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    5.342037]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    5.342037]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    5.342037]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    5.342037]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    5.342037]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    5.342037]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    5.342037]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    5.342037] ---[ end trace cfeb07101f6fbe4f ]---
[    5.374077] ------------[ cut here ]------------
[    5.374898] WARNING: CPU: 0 PID: 110 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.376635] CPU: 0 PID: 110 Comm: 99-trinity Tainted: G        W     3.1=
6.0-rc1-00238-gddc5bfe #1
[    5.376678] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.376678]  0000000000000000 ffff88000b067aa8 ffffffff81a23b9d ffff8800=
0b067ae0
[    5.376678]  ffffffff810bc765 ffffffff8111fac8 0000000000014000 ffff8800=
1200fa50
[    5.376678]  0000000000000001 ffff88001200fa01 ffff88000b067af0 ffffffff=
810bc84b
[    5.376678] Call Trace:
[    5.376678]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.376678]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.376678]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.376678]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.376678]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.376678]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.376678]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.376678]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.376678]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.376678]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.376678]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.376678]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.376678]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.376678]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.376678]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    5.376678]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    5.376678]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    5.376678]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    5.376678]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    5.376678]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    5.376678]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    5.376678]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    5.376678]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    5.376678]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    5.376678] ---[ end trace cfeb07101f6fbe50 ]---
[    5.415403] ------------[ cut here ]------------
[    5.416226] WARNING: CPU: 0 PID: 108 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.416739] CPU: 0 PID: 108 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.416739] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.416739]  0000000000000000 ffff88000b08bc50 ffffffff81a23b9d ffff8800=
0b08bc88
[    5.416739]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.416739]  0000000000000001 ffff88001200fa01 ffff88000b08bc98 ffffffff=
810bc84b
[    5.416739] Call Trace:
[    5.416739]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.416739]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.416739]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.416739]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.416739]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.416739]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.416739]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.416739]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.416739]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.416739]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.416739]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.416739]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.416739]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    5.416739]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    5.416739]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    5.416739]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    5.416739]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    5.416739]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.416739] ---[ end trace cfeb07101f6fbe51 ]---
[    5.444507] ------------[ cut here ]------------
[    5.445318] WARNING: CPU: 0 PID: 109 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.446673] CPU: 0 PID: 109 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.446673] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.446673]  0000000000000000 ffff88000b03bc50 ffffffff81a23b9d ffff8800=
0b03bc88
[    5.446673]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.446673]  0000000000000001 ffff88001200fa01 ffff88000b03bc98 ffffffff=
810bc84b
[    5.446673] Call Trace:
[    5.446673]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.446673]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.446673]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.446673]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.446673]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.446673]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.446673]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.446673]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.446673]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.446673]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.446673]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.446673]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.446673]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    5.446673]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    5.446673]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    5.446673]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    5.446673]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    5.446673]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.446673] ---[ end trace cfeb07101f6fbe52 ]---
[    5.474178] ------------[ cut here ]------------
[    5.475003] WARNING: CPU: 0 PID: 110 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.476680] CPU: 0 PID: 110 Comm: umount Tainted: G        W     3.16.0-=
rc1-00238-gddc5bfe #1
[    5.476680] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.476680]  0000000000000000 ffff88000b067c50 ffffffff81a23b9d ffff8800=
0b067c88
[    5.476680]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.476680]  0000000000000001 ffff88001200fa01 ffff88000b067c98 ffffffff=
810bc84b
[    5.476680] Call Trace:
[    5.476680]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.476680]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.476680]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.476680]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.476680]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.476680]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.476680]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.476680]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.476680]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.476680]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.476680]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.476680]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.476680]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    5.476680]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    5.476680]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    5.476680]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    5.476680]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    5.476680]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.476680] ---[ end trace cfeb07101f6fbe53 ]---
[    5.502488] ------------[ cut here ]------------
[    5.503309] WARNING: CPU: 0 PID: 108 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.505035] CPU: 0 PID: 108 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.505448] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.505448]  0000000000000000 ffff88000b08bc50 ffffffff81a23b9d ffff8800=
0b08bc88
[    5.505448]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.505448]  0000000000000001 ffff88001200fa01 ffff88000b08bc98 ffffffff=
810bc84b
[    5.505448] Call Trace:
[    5.505448]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.505448]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.505448]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.505448]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.505448]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.505448]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.505448]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.505448]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.505448]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.505448]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.505448]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.505448]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.505448]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    5.505448]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    5.505448]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    5.505448]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    5.505448]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    5.505448]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.505448] ---[ end trace cfeb07101f6fbe54 ]---
[    5.530731] ------------[ cut here ]------------
[    5.531534] WARNING: CPU: 0 PID: 109 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.533263] CPU: 0 PID: 109 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.533707] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.533707]  0000000000000000 ffff88000b03bc50 ffffffff81a23b9d ffff8800=
0b03bc88
[    5.533707]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.533707]  0000000000000001 ffff88001200fa01 ffff88000b03bc98 ffffffff=
810bc84b
[    5.533707] Call Trace:
[    5.533707]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.533707]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.533707]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.533707]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.533707]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.533707]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.533707]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.533707]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.533707]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.533707]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.533707]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.533707]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.533707]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    5.533707]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    5.533707]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    5.533707]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    5.533707]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    5.533707]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.533707] ---[ end trace cfeb07101f6fbe55 ]---
[    5.558993] ------------[ cut here ]------------
[    5.559809] WARNING: CPU: 0 PID: 110 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.561537] CPU: 0 PID: 110 Comm: umount Tainted: G        W     3.16.0-=
rc1-00238-gddc5bfe #1
[    5.561953] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.561953]  0000000000000000 ffff88000b067c50 ffffffff81a23b9d ffff8800=
0b067c88
[    5.561953]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.561953]  0000000000000001 ffff88001200fa01 ffff88000b067c98 ffffffff=
810bc84b
[    5.561953] Call Trace:
[    5.561953]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.561953]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.561953]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.561953]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.561953]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.561953]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.561953]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.561953]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.561953]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.561953]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.561953]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.561953]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.561953]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    5.561953]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    5.561953]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    5.561953]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    5.561953]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    5.561953]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.561953] ---[ end trace cfeb07101f6fbe56 ]---
[    5.594560] ------------[ cut here ]------------
[    5.595377] WARNING: CPU: 0 PID: 108 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.596677] CPU: 0 PID: 108 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.596677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.596677]  0000000000000000 ffff88000b08baa8 ffffffff81a23b9d ffff8800=
0b08bae0
[    5.596677]  ffffffff810bc765 ffffffff8111fac8 0000000000021000 ffff8800=
1200fa50
[    5.596677]  0000000000000001 ffff88001200fa01 ffff88000b08baf0 ffffffff=
810bc84b
[    5.596677] Call Trace:
[    5.596677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.596677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.596677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.596677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.596677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.596677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.596677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.596677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.596677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.596677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.596677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.596677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.596677]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.596677]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.596677]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    5.596677]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    5.596677]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    5.596677]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    5.596677]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    5.596677]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    5.596677]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    5.596677]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    5.596677]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    5.596677]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    5.596677] ---[ end trace cfeb07101f6fbe57 ]---
[    5.627692] ------------[ cut here ]------------
[    5.628473] WARNING: CPU: 0 PID: 108 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.630163] CPU: 0 PID: 108 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.630897] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.630897]  0000000000000000 ffff88000b08baa8 ffffffff81a23b9d ffff8800=
0b08bae0
[    5.630897]  ffffffff810bc765 ffffffff8111fac8 000000000001e000 ffff8800=
1200fa50
[    5.630897]  0000000000000001 ffff88001200fa01 ffff88000b08baf0 ffffffff=
810bc84b
[    5.630897] Call Trace:
[    5.630897]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.630897]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.630897]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.630897]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.630897]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.630897]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.630897]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.630897]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.630897]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.630897]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.630897]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.630897]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.630897]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.630897]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.630897]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    5.630897]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    5.630897]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    5.630897]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    5.630897]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    5.630897]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    5.630897]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    5.630897]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    5.630897]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    5.630897]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    5.630897] ---[ end trace cfeb07101f6fbe58 ]---
[    5.662222] ------------[ cut here ]------------
[    5.663032] WARNING: CPU: 0 PID: 109 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.663600] CPU: 0 PID: 109 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.663600] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.663600]  0000000000000000 ffff88000b03baa8 ffffffff81a23b9d ffff8800=
0b03bae0
[    5.663600]  ffffffff810bc765 ffffffff8111fac8 0000000000021000 ffff8800=
1200fa50
[    5.663600]  0000000000000001 ffff88001200fa01 ffff88000b03baf0 ffffffff=
810bc84b
[    5.663600] Call Trace:
[    5.663600]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.663600]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.663600]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.663600]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.663600]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.663600]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.663600]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.663600]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.663600]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.663600]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.663600]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.663600]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.663600]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.663600]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.663600]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    5.663600]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    5.663600]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    5.663600]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    5.663600]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    5.663600]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    5.663600]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    5.663600]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    5.663600]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    5.663600]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    5.663600] ---[ end trace cfeb07101f6fbe59 ]---
[    5.694928] ------------[ cut here ]------------
[    5.695708] WARNING: CPU: 0 PID: 109 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.697386] CPU: 0 PID: 109 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.698102] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.698102]  0000000000000000 ffff88000b03baa8 ffffffff81a23b9d ffff8800=
0b03bae0
[    5.698102]  ffffffff810bc765 ffffffff8111fac8 000000000001f000 ffff8800=
1200fa50
[    5.698102]  0000000000000001 ffff88001200fa01 ffff88000b03baf0 ffffffff=
810bc84b
[    5.698102] Call Trace:
[    5.698102]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.698102]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.698102]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.698102]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.698102]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.698102]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.698102]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.698102]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.698102]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.698102]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.698102]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.698102]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.698102]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.698102]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.698102]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    5.698102]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    5.698102]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    5.698102]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    5.698102]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    5.698102]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    5.698102]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    5.698102]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    5.698102]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    5.698102]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    5.698102] ---[ end trace cfeb07101f6fbe5a ]---
[    5.728155] ------------[ cut here ]------------
[    5.728959] WARNING: CPU: 0 PID: 110 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.730649] CPU: 0 PID: 110 Comm: umount Tainted: G        W     3.16.0-=
rc1-00238-gddc5bfe #1
[    5.730729] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.730729]  0000000000000000 ffff88000b067c48 ffffffff81a23b9d ffff8800=
0b067c80
[    5.730729]  ffffffff810bc765 ffffffff8111fac8 0000000000029000 ffff8800=
1200fa50
[    5.730729]  0000000000000001 ffff88001200fa01 ffff88000b067c90 ffffffff=
810bc84b
[    5.730729] Call Trace:
[    5.730729]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.730729]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.730729]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.730729]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.730729]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.730729]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.730729]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.730729]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.730729]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.730729]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.730729]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.730729]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.730729]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.730729]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.730729]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    5.730729]  [<ffffffff81197b8c>] ? fsnotify_modify+0x58/0x5f
[    5.730729]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    5.730729]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    5.730729]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    5.730729]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.730729] ---[ end trace cfeb07101f6fbe5b ]---
[    5.764127] ------------[ cut here ]------------
[    5.764929] WARNING: CPU: 0 PID: 112 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.766622] CPU: 0 PID: 112 Comm: 99-trinity Tainted: G        W     3.1=
6.0-rc1-00238-gddc5bfe #1
[    5.766678] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.766678]  0000000000000000 ffff88000b06baa8 ffffffff81a23b9d ffff8800=
0b06bae0
[    5.766678]  ffffffff810bc765 ffffffff8111fac8 0000000000013000 ffff8800=
1200fa50
[    5.766678]  0000000000000001 ffff88001200fa01 ffff88000b06baf0 ffffffff=
810bc84b
[    5.766678] Call Trace:
[    5.766678]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.766678]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.766678]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.766678]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.766678]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.766678]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.766678]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.766678]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.766678]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.766678]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.766678]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.766678]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.766678]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.766678]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.766678]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    5.766678]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    5.766678]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    5.766678]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    5.766678]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    5.766678]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    5.766678]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    5.766678]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    5.766678]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    5.766678]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    5.766678] ---[ end trace cfeb07101f6fbe5c ]---
[    5.799750] ------------[ cut here ]------------
[    5.800181] WARNING: CPU: 0 PID: 114 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.800181] CPU: 0 PID: 114 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    5.800181] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.800181]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[    5.800181]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[    5.800181]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[    5.800181] Call Trace:
[    5.800181]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.800181]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.800181]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.800181]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.800181]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.800181]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.800181]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.800181]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.800181]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.800181]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.800181]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.800181]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.800181]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.800181]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.800181]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    5.800181]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    5.800181]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    5.800181]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    5.800181]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    5.800181]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    5.800181]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    5.800181]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    5.800181]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    5.800181]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    5.800181] ---[ end trace cfeb07101f6fbe5d ]---
[    5.834567] ------------[ cut here ]------------
[    5.835374] WARNING: CPU: 0 PID: 109 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.836679] CPU: 0 PID: 109 Comm: hwclock Tainted: G        W     3.16.0=
-rc1-00238-gddc5bfe #1
[    5.836679] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.836679]  0000000000000000 ffff88000b03bc50 ffffffff81a23b9d ffff8800=
0b03bc88
[    5.836679]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.836679]  0000000000000001 ffff88001200fa01 ffff88000b03bc98 ffffffff=
810bc84b
[    5.836679] Call Trace:
[    5.836679]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.836679]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.836679]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.836679]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.836679]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.836679]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.836679]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.836679]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.836679]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.836679]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.836679]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.836679]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.836679]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    5.836679]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    5.836679]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    5.836679]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    5.836679]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    5.836679]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.836679] ---[ end trace cfeb07101f6fbe5e ]---
[    5.862260] ------------[ cut here ]------------
[    5.863049] WARNING: CPU: 0 PID: 113 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.864739] CPU: 0 PID: 113 Comm: plymouthd Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[    5.865259] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.865259]  0000000000000000 ffff88000b093a80 ffffffff81a23b9d ffff8800=
0b093ab8
[    5.865259]  ffffffff810bc765 ffffffff8111fac8 0000000000017000 ffff8800=
1200fa50
[    5.865259]  0000000000000001 ffff88001200fa01 ffff88000b093ac8 ffffffff=
810bc84b
[    5.865259] Call Trace:
[    5.865259]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.865259]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.865259]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.865259]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.865259]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.865259]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.865259]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.865259]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.865259]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.865259]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.865259]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.865259]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.865259]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.865259]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.865259]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    5.865259]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    5.865259]  [<ffffffff810ccc3b>] get_signal_to_deliver+0x670/0x745
[    5.865259]  [<ffffffff8103fd83>] do_signal+0x48/0x551
[    5.865259]  [<ffffffff81049a26>] ? __restore_xstate_sig+0x351/0x37c
[    5.865259]  [<ffffffff810402a4>] do_notify_resume+0x18/0x6d
[    5.865259]  [<ffffffff81a3181a>] int_signal+0x12/0x17
[    5.865259] ---[ end trace cfeb07101f6fbe5f ]---
[    5.892842] ------------[ cut here ]------------
[    5.893638] WARNING: CPU: 0 PID: 111 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.895339] CPU: 0 PID: 111 Comm: 99-trinity Tainted: G        W     3.1=
6.0-rc1-00238-gddc5bfe #1
[    5.895521] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.895521]  0000000000000000 ffff88000b077aa8 ffffffff81a23b9d ffff8800=
0b077ae0
[    5.895521]  ffffffff810bc765 ffffffff8111fac8 0000000000016000 ffff8800=
1200fa50
[    5.895521]  0000000000000001 ffff88001200fa01 ffff88000b077af0 ffffffff=
810bc84b
[    5.895521] Call Trace:
[    5.895521]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.895521]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.895521]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.895521]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.895521]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.895521]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.895521]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.895521]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.895521]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.895521]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.895521]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.895521]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.895521]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.895521]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.895521]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    5.895521]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    5.895521]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    5.895521]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    5.895521]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    5.895521]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    5.895521]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    5.895521]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    5.895521]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    5.895521]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    5.895521] ---[ end trace cfeb07101f6fbe60 ]---
[    5.931157] ------------[ cut here ]------------
[    5.931953] WARNING: CPU: 0 PID: 109 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.933625] CPU: 0 PID: 109 Comm: hwclock Tainted: G        W     3.16.0=
-rc1-00238-gddc5bfe #1
[    5.934210] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.934210]  0000000000000000 ffff88000b03bc48 ffffffff81a23b9d ffff8800=
0b03bc80
[    5.934210]  ffffffff810bc765 ffffffff8111fac8 0000000000016000 ffff8800=
1200fa50
[    5.934210]  0000000000000001 ffff88001200fa01 ffff88000b03bc90 ffffffff=
810bc84b
[    5.934210] Call Trace:
[    5.934210]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.934210]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.934210]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.934210]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.934210]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.934210]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.934210]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.934210]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.934210]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.934210]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.934210]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.934210]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.934210]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.934210]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.934210]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    5.934210]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    5.934210]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    5.934210]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    5.934210]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.934210] ---[ end trace cfeb07101f6fbe61 ]---
[    5.960504] ------------[ cut here ]------------
[    5.961303] WARNING: CPU: 0 PID: 114 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.963017] CPU: 0 PID: 114 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    5.963343] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.963343]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[    5.963343]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    5.963343]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[    5.963343] Call Trace:
[    5.963343]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.963343]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.963343]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.963343]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.963343]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.963343]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.963343]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.963343]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.963343]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.963343]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.963343]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.963343]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.963343]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    5.963343]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    5.963343]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    5.963343]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    5.963343]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    5.963343]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.963343] ---[ end trace cfeb07101f6fbe62 ]---
[    5.988235] ------------[ cut here ]------------
[    5.989030] WARNING: CPU: 0 PID: 108 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    5.990731] CPU: 0 PID: 108 Comm: plymouthd Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[    5.991211] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    5.991211]  0000000000000000 ffff88000b08bc48 ffffffff81a23b9d ffff8800=
0b08bc80
[    5.991211]  ffffffff810bc765 ffffffff8111fac8 0000000000028000 ffff8800=
1200fa50
[    5.991211]  0000000000000001 ffff88001200fa01 ffff88000b08bc90 ffffffff=
810bc84b
[    5.991211] Call Trace:
[    5.991211]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    5.991211]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    5.991211]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    5.991211]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    5.991211]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    5.991211]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    5.991211]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    5.991211]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    5.991211]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    5.991211]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    5.991211]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    5.991211]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    5.991211]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    5.991211]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    5.991211]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    5.991211]  [<ffffffff81197b8c>] ? fsnotify_modify+0x58/0x5f
[    5.991211]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    5.991211]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    5.991211]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    5.991211]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    5.991211] ---[ end trace cfeb07101f6fbe63 ]---
[    6.018006] ------------[ cut here ]------------
[    6.018816] WARNING: CPU: 0 PID: 114 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.020508] CPU: 0 PID: 114 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    6.020559] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.020559]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[    6.020559]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.020559]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[    6.020559] Call Trace:
[    6.020559]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.020559]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.020559]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.020559]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.020559]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.020559]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.020559]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.020559]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.020559]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.020559]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.020559]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.020559]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.020559]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.020559]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.020559]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.020559]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.020559]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.020559]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.020559] ---[ end trace cfeb07101f6fbe64 ]---
[    6.045539] plymouthd (113) used greatest stack depth: 13280 bytes left
[    6.046770] ------------[ cut here ]------------
[    6.047566] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    6.049224] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    6.050009] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.050009]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    6.050009]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.050009]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    6.050009] Call Trace:
[    6.050009]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.050009]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.050009]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.050009]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.050009]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.050009]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.050009]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.050009]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.050009]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.050009]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    6.050009]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    6.050009]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    6.050009]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    6.050009]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    6.050009]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    6.050009]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    6.050009]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    6.050009]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    6.050009]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    6.050009]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    6.050009]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    6.050009]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    6.050009]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    6.050009]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    6.050009]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    6.050009]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    6.050009]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    6.050009]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    6.050009]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    6.050009]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    6.050009]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    6.050009]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.050009] ---[ end trace cfeb07101f6fbe65 ]---
[    6.096499] ------------[ cut here ]------------
[    6.096678] WARNING: CPU: 0 PID: 111 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.096678] CPU: 0 PID: 111 Comm: trinity Tainted: G        W     3.16.0=
-rc1-00238-gddc5bfe #1
[    6.096678] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.096678]  0000000000000000 ffff88000b077c50 ffffffff81a23b9d ffff8800=
0b077c88
[    6.096678]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.096678]  0000000000000001 ffff88001200fa01 ffff88000b077c98 ffffffff=
810bc84b
[    6.096678] Call Trace:
[    6.096678]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.096678]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.096678]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.096678]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.096678]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.096678]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.096678]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.096678]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.096678]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.096678]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.096678]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.096678]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.096678]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.096678]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.096678]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.096678]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.096678]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.096678]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.096678] ---[ end trace cfeb07101f6fbe66 ]---
[    6.125194] ------------[ cut here ]------------
[    6.126001] WARNING: CPU: 0 PID: 114 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.127089] CPU: 0 PID: 114 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    6.127089] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.127089]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[    6.127089]  ffffffff810bc765 ffffffff8111fac8 0000000000020000 ffff8800=
1200fa50
[    6.127089]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[    6.127089] Call Trace:
[    6.127089]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.127089]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.127089]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.127089]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.127089]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.127089]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.127089]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.127089]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.127089]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.127089]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.127089]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.127089]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.127089]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    6.127089]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    6.127089]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    6.127089]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    6.127089]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    6.127089]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    6.127089]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.127089] ---[ end trace cfeb07101f6fbe67 ]---
[    6.153220] ------------[ cut here ]------------
[    6.154004] WARNING: CPU: 0 PID: 114 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.155671] CPU: 0 PID: 114 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    6.156454] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.156454]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[    6.156454]  ffffffff810bc765 ffffffff8111fac8 000000000001e000 ffff8800=
1200fa50
[    6.156454]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[    6.156454] Call Trace:
[    6.156454]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.156454]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.156454]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.156454]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.156454]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.156454]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.156454]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.156454]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.156454]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.156454]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.156454]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.156454]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.156454]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    6.156454]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    6.156454]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    6.156454]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    6.156454]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    6.156454]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    6.156454]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.156454] ---[ end trace cfeb07101f6fbe68 ]---
[    6.181449] ------------[ cut here ]------------
[    6.182238] WARNING: CPU: 0 PID: 111 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.183942] CPU: 0 PID: 111 Comm: trinity Tainted: G        W     3.16.0=
-rc1-00238-gddc5bfe #1
[    6.184386] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.184386]  0000000000000000 ffff88000b077c50 ffffffff81a23b9d ffff8800=
0b077c88
[    6.184386]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.184386]  0000000000000001 ffff88001200fa01 ffff88000b077c98 ffffffff=
810bc84b
[    6.184386] Call Trace:
[    6.184386]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.184386]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.184386]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.184386]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.184386]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.184386]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.184386]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.184386]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.184386]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.184386]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.184386]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.184386]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.184386]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.184386]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.184386]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.184386]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.184386]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.184386]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.184386] ---[ end trace cfeb07101f6fbe69 ]---
[    6.209059] ------------[ cut here ]------------
[    6.209870] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    6.211525] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    6.212268] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.212268]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    6.212268]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.212268]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    6.212268] Call Trace:
[    6.212268]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.212268]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.212268]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.212268]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.212268]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.212268]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.212268]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.212268]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.212268]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.212268]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.212268]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.212268]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.212268]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.212268]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.212268]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.212268]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.212268]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.212268]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.212268] ---[ end trace cfeb07101f6fbe6a ]---
[    6.241859] ------------[ cut here ]------------
[    6.242645] WARNING: CPU: 0 PID: 111 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.244341] CPU: 0 PID: 111 Comm: trinity Tainted: G        W     3.16.0=
-rc1-00238-gddc5bfe #1
[    6.244945] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.244945]  0000000000000000 ffff88000b077c50 ffffffff81a23b9d ffff8800=
0b077c88
[    6.244945]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.244945]  0000000000000001 ffff88001200fa01 ffff88000b077c98 ffffffff=
810bc84b
[    6.244945] Call Trace:
[    6.244945]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.244945]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.244945]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.244945]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.244945]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.244945]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.244945]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.244945]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.244945]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.244945]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.244945]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.244945]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.244945]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.244945]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.244945]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.244945]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.244945]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.244945]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.244945] ---[ end trace cfeb07101f6fbe6b ]---
[    6.269886] ------------[ cut here ]------------
[    6.270679] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.272351] CPU: 0 PID: 115 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    6.272481] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.272481]  0000000000000000 ffff88000b08baa8 ffffffff81a23b9d ffff8800=
0b08bae0
[    6.272481]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[    6.272481]  0000000000000001 ffff88001200fa01 ffff88000b08baf0 ffffffff=
810bc84b
[    6.272481] Call Trace:
[    6.272481]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.272481]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.272481]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.272481]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.272481]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.272481]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.272481]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.272481]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.272481]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.272481]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.272481]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.272481]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.272481]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    6.272481]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    6.272481]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    6.272481]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    6.272481]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    6.272481]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    6.272481]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    6.272481]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    6.272481]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    6.272481]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    6.272481]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    6.272481]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    6.272481] ---[ end trace cfeb07101f6fbe6c ]---
[    6.302911] ------------[ cut here ]------------
[    6.303701] WARNING: CPU: 0 PID: 111 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.305384] CPU: 0 PID: 111 Comm: trinity Tainted: G        W     3.16.0=
-rc1-00238-gddc5bfe #1
[    6.305849] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.305849]  0000000000000000 ffff88000b077c50 ffffffff81a23b9d ffff8800=
0b077c88
[    6.305849]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.305849]  0000000000000001 ffff88001200fa01 ffff88000b077c98 ffffffff=
810bc84b
[    6.305849] Call Trace:
[    6.305849]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.305849]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.305849]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.305849]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.305849]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.305849]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.305849]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.305849]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.305849]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.305849]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.305849]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.305849]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.305849]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.305849]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.305849]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.305849]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.305849]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.305849]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.305849] ---[ end trace cfeb07101f6fbe6d ]---
[    6.332038] ------------[ cut here ]------------
[    6.332851] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.333655] CPU: 0 PID: 115 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    6.333655] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.333655]  0000000000000000 ffff88000b08bc50 ffffffff81a23b9d ffff8800=
0b08bc88
[    6.333655]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.333655]  0000000000000001 ffff88001200fa01 ffff88000b08bc98 ffffffff=
810bc84b
[    6.333655] Call Trace:
[    6.333655]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.333655]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.333655]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.333655]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.333655]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.333655]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.333655]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.333655]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.333655]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.333655]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.333655]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.333655]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.333655]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.333655]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.333655]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.333655]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.333655]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.333655]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.333655] ---[ end trace cfeb07101f6fbe6e ]---
[    6.360215] ------------[ cut here ]------------
[    6.361029] WARNING: CPU: 0 PID: 111 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.362760] CPU: 0 PID: 111 Comm: trinity Tainted: G        W     3.16.0=
-rc1-00238-gddc5bfe #1
[    6.363343] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.363343]  0000000000000000 ffff88000b077c50 ffffffff81a23b9d ffff8800=
0b077c88
[    6.363343]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.363343]  0000000000000001 ffff88001200fa01 ffff88000b077c98 ffffffff=
810bc84b
[    6.363343] Call Trace:
[    6.363343]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.363343]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.363343]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.363343]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.363343]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.363343]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.363343]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.363343]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.363343]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.363343]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.363343]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.363343]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.363343]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.363343]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.363343]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.363343]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.363343]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.363343]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.363343] ---[ end trace cfeb07101f6fbe6f ]---
[    6.388608] ------------[ cut here ]------------
[    6.389429] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.391180] CPU: 0 PID: 115 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    6.391601] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.391601]  0000000000000000 ffff88000b08bc50 ffffffff81a23b9d ffff8800=
0b08bc88
[    6.391601]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.391601]  0000000000000001 ffff88001200fa01 ffff88000b08bc98 ffffffff=
810bc84b
[    6.391601] Call Trace:
[    6.391601]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.391601]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.391601]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.391601]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.391601]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.391601]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.391601]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.391601]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.391601]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.391601]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.391601]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.391601]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.391601]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.391601]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.391601]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.391601]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.391601]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.391601]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.391601] ---[ end trace cfeb07101f6fbe70 ]---
[    6.423230] ------------[ cut here ]------------
[    6.424055] WARNING: CPU: 0 PID: 111 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.425793] CPU: 0 PID: 111 Comm: trinity Tainted: G        W     3.16.0=
-rc1-00238-gddc5bfe #1
[    6.426340] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.426340]  0000000000000000 ffff88000b077c50 ffffffff81a23b9d ffff8800=
0b077c88
[    6.426340]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.426340]  0000000000000001 ffff88001200fa01 ffff88000b077c98 ffffffff=
810bc84b
[    6.426340] Call Trace:
[    6.426340]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.426340]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.426340]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.426340]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.426340]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.426340]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.426340]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.426340]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.426340]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.426340]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.426340]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.426340]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.426340]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.426340]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.426340]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.426340]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.426340]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.426340]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.426340] ---[ end trace cfeb07101f6fbe71 ]---
[    6.453571] ------------[ cut here ]------------
[    6.454412] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.456185] CPU: 0 PID: 115 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    6.456676] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.456676]  0000000000000000 ffff88000b08baa8 ffffffff81a23b9d ffff8800=
0b08bae0
[    6.456676]  ffffffff810bc765 ffffffff8111fac8 0000000000023000 ffff8800=
1200fa50
[    6.456676]  0000000000000001 ffff88001200fa01 ffff88000b08baf0 ffffffff=
810bc84b
[    6.456676] Call Trace:
[    6.456676]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.456676]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.456676]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.456676]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.456676]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.456676]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.456676]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.456676]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.456676]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.456676]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.456676]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.456676]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.456676]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    6.456676]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    6.456676]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    6.456676]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    6.456676]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    6.456676]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    6.456676]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    6.456676]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    6.456676]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    6.456676]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    6.456676]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    6.456676]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    6.456676] ---[ end trace cfeb07101f6fbe72 ]---
[    6.487594] ------------[ cut here ]------------
[    6.488408] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.490171] CPU: 0 PID: 115 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    6.490810] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.490810]  0000000000000000 ffff88000b08baa8 ffffffff81a23b9d ffff8800=
0b08bae0
[    6.490810]  ffffffff810bc765 ffffffff8111fac8 000000000001e000 ffff8800=
1200fa50
[    6.490810]  0000000000000001 ffff88001200fa01 ffff88000b08baf0 ffffffff=
810bc84b
[    6.490810] Call Trace:
[    6.490810]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.490810]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.490810]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.490810]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.490810]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.490810]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.490810]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.490810]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.490810]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.490810]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.490810]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.490810]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.490810]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    6.490810]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    6.490810]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    6.490810]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    6.490810]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    6.490810]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    6.490810]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    6.490810]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    6.490810]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    6.490810]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    6.490810]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    6.490810]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    6.490810] ---[ end trace cfeb07101f6fbe73 ]---
[    6.524359] ------------[ cut here ]------------
[    6.525196] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.526676] CPU: 0 PID: 115 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.526676] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.526676]  0000000000000000 ffff88000b08bc50 ffffffff81a23b9d ffff8800=
0b08bc88
[    6.526676]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.526676]  0000000000000001 ffff88001200fa01 ffff88000b08bc98 ffffffff=
810bc84b
[    6.526676] Call Trace:
[    6.526676]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.526676]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.526676]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.526676]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.526676]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.526676]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.526676]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.526676]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.526676]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.526676]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.526676]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.526676]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.526676]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.526676]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.526676]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.526676]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.526676]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.526676]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.526676] ---[ end trace cfeb07101f6fbe74 ]---
[    6.553338] ------------[ cut here ]------------
[    6.554163] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.555929] CPU: 0 PID: 115 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.556232] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.556232]  0000000000000000 ffff88000b08bc50 ffffffff81a23b9d ffff8800=
0b08bc88
[    6.556232]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.556232]  0000000000000001 ffff88001200fa01 ffff88000b08bc98 ffffffff=
810bc84b
[    6.556232] Call Trace:
[    6.556232]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.556232]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.556232]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.556232]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.556232]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.556232]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.556232]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.556232]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.556232]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.556232]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.556232]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.556232]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.556232]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.556232]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.556232]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.556232]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.556232]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.556232]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.556232] ---[ end trace cfeb07101f6fbe75 ]---
[    6.587341] ------------[ cut here ]------------
[    6.588156] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.589904] CPU: 0 PID: 115 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.590491] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.590491]  0000000000000000 ffff88000b08bc50 ffffffff81a23b9d ffff8800=
0b08bc88
[    6.590491]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.590491]  0000000000000001 ffff88001200fa01 ffff88000b08bc98 ffffffff=
810bc84b
[    6.590491] Call Trace:
[    6.590491]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.590491]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.590491]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.590491]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.590491]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.590491]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.590491]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.590491]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.590491]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.590491]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.590491]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.590491]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.590491]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.590491]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.590491]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.590491]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.590491]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.590491]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.590491] ---[ end trace cfeb07101f6fbe76 ]---
[    6.615499] ------------[ cut here ]------------
[    6.616284] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.617972] CPU: 0 PID: 115 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.618672] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.618672]  0000000000000000 ffff88000b08bc50 ffffffff81a23b9d ffff8800=
0b08bc88
[    6.618672]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.618672]  0000000000000001 ffff88001200fa01 ffff88000b08bc98 ffffffff=
810bc84b
[    6.618672] Call Trace:
[    6.618672]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.618672]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.618672]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.618672]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.618672]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.618672]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.618672]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.618672]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.618672]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.618672]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.618672]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.618672]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.618672]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.618672]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.618672]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.618672]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.618672]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.618672]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.618672] ---[ end trace cfeb07101f6fbe77 ]---
[    6.643795] ------------[ cut here ]------------
[    6.644590] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.646292] CPU: 0 PID: 115 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.646677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.646677]  0000000000000000 ffff88000b08bc48 ffffffff81a23b9d ffff8800=
0b08bc80
[    6.646677]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.646677]  0000000000000001 ffff88001200fa01 ffff88000b08bc90 ffffffff=
810bc84b
[    6.646677] Call Trace:
[    6.646677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.646677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.646677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.646677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.646677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.646677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.646677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.646677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.646677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.646677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.646677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.646677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.646677]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    6.646677]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    6.646677]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    6.646677]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    6.646677]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    6.646677]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    6.646677]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.646677] ---[ end trace cfeb07101f6fbe78 ]---
[    6.671951] ------------[ cut here ]------------
[    6.672725] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.674396] CPU: 0 PID: 115 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.675187] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.675187]  0000000000000000 ffff88000b08bc48 ffffffff81a23b9d ffff8800=
0b08bc80
[    6.675187]  ffffffff810bc765 ffffffff8111fac8 000000000000c000 ffff8800=
1200fa50
[    6.675187]  0000000000000001 ffff88001200fa01 ffff88000b08bc90 ffffffff=
810bc84b
[    6.675187] Call Trace:
[    6.675187]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.675187]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.675187]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.675187]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.675187]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.675187]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.675187]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.675187]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.675187]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.675187]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.675187]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.675187]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.675187]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    6.675187]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    6.675187]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    6.675187]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    6.675187]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    6.675187]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    6.675187]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.675187] ---[ end trace cfeb07101f6fbe79 ]---
[    6.699950] ------------[ cut here ]------------
[    6.700737] WARNING: CPU: 0 PID: 115 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.702411] CPU: 0 PID: 115 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.703220] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.703220]  0000000000000000 ffff88000b08bc48 ffffffff81a23b9d ffff8800=
0b08bc80
[    6.703220]  ffffffff810bc765 ffffffff8111fac8 000000000000b000 ffff8800=
1200fa50
[    6.703220]  0000000000000001 ffff88001200fa01 ffff88000b08bc90 ffffffff=
810bc84b
[    6.703220] Call Trace:
[    6.703220]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.703220]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.703220]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.703220]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.703220]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.703220]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.703220]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.703220]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.703220]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.703220]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.703220]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.703220]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.703220]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    6.703220]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    6.703220]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    6.703220]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    6.703220]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    6.703220]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    6.703220]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.703220] ---[ end trace cfeb07101f6fbe7a ]---
[    6.728967] ------------[ cut here ]------------
[    6.729778] WARNING: CPU: 0 PID: 116 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.731186] CPU: 0 PID: 116 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.731186] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.731186]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[    6.731186]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.731186]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[    6.731186] Call Trace:
[    6.731186]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.731186]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.731186]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.731186]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.731186]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.731186]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.731186]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.731186]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.731186]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.731186]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.731186]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.731186]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.731186]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    6.731186]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    6.731186]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    6.731186]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    6.731186]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    6.731186]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    6.731186]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.731186] ---[ end trace cfeb07101f6fbe7b ]---
[    6.762402] ------------[ cut here ]------------
[    6.763177] WARNING: CPU: 0 PID: 116 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.764853] CPU: 0 PID: 116 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.765681] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.765681]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[    6.765681]  ffffffff810bc765 ffffffff8111fac8 0000000000017000 ffff8800=
1200fa50
[    6.765681]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[    6.765681] Call Trace:
[    6.765681]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.765681]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.765681]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.765681]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.765681]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.765681]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.765681]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.765681]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.765681]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.765681]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.765681]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.765681]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.765681]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    6.765681]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    6.765681]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    6.765681]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    6.765681]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    6.765681]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    6.765681]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.765681] ---[ end trace cfeb07101f6fbe7c ]---
[    6.790863] ------------[ cut here ]------------
[    6.791650] WARNING: CPU: 0 PID: 117 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.793339] CPU: 0 PID: 117 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.793720] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.793720]  0000000000000000 ffff88000b093c50 ffffffff81a23b9d ffff8800=
0b093c88
[    6.793720]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.793720]  0000000000000001 ffff88001200fa01 ffff88000b093c98 ffffffff=
810bc84b
[    6.793720] Call Trace:
[    6.793720]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.793720]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.793720]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.793720]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.793720]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.793720]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.793720]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.793720]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.793720]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.793720]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.793720]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.793720]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.793720]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.793720]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.793720]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.793720]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.793720]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.793720]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.793720] ---[ end trace cfeb07101f6fbe7d ]---
[    6.818744] ------------[ cut here ]------------
[    6.819535] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    6.821208] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    6.821501] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.821501]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    6.821501]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.821501]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    6.821501] Call Trace:
[    6.821501]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.821501]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.821501]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.821501]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.821501]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.821501]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.821501]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.821501]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.821501]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.821501]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.821501]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.821501]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.821501]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.821501]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.821501]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.821501]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.821501]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.821501]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.821501] ---[ end trace cfeb07101f6fbe7e ]---
[    6.847506] ------------[ cut here ]------------
[    6.848313] WARNING: CPU: 0 PID: 117 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.849997] CPU: 0 PID: 117 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.850011] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.850011]  0000000000000000 ffff88000b093908 ffffffff81a23b9d ffff8800=
0b093940
[    6.850011]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.850011]  0000000000000001 ffff88001200fa01 ffff88000b093950 ffffffff=
810bc84b
[    6.850011] Call Trace:
[    6.850011]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.850011]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.850011]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.850011]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.850011]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.850011]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.850011]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.850011]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.850011]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.850011]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    6.850011]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    6.850011]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    6.850011]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    6.850011]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    6.850011]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    6.850011]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    6.850011]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    6.850011]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    6.850011]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    6.850011]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    6.850011]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    6.850011]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    6.850011]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    6.850011]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    6.850011]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    6.850011]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    6.850011]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    6.850011]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    6.850011]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    6.850011]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    6.850011]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    6.850011]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.850011] ---[ end trace cfeb07101f6fbe7f ]---
[    6.888638] ------------[ cut here ]------------
[    6.889429] WARNING: CPU: 0 PID: 118 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.891019] CPU: 0 PID: 118 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    6.891019] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.891019]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[    6.891019]  ffffffff810bc765 ffffffff8111fac8 000000000000d000 ffff8800=
1200fa50
[    6.891019]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[    6.891019] Call Trace:
[    6.891019]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.891019]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.891019]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.891019]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.891019]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.891019]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.891019]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.891019]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.891019]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.891019]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.891019]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.891019]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.891019]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    6.891019]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    6.891019]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    6.891019]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    6.891019]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    6.891019]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    6.891019]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    6.891019]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    6.891019]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    6.891019]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    6.891019]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    6.891019]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    6.891019] ---[ end trace cfeb07101f6fbe80 ]---
[    6.928265] ------------[ cut here ]------------
[    6.929068] WARNING: CPU: 0 PID: 118 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.930007] CPU: 0 PID: 118 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    6.930007] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.930007]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[    6.930007]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.930007]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[    6.930007] Call Trace:
[    6.930007]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.930007]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.930007]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.930007]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.930007]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.930007]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.930007]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.930007]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.930007]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.930007]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.930007]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.930007]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.930007]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.930007]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.930007]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.930007]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.930007]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.930007]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.930007] ---[ end trace cfeb07101f6fbe81 ]---
[    6.956188] ------------[ cut here ]------------
[    6.956999] WARNING: CPU: 0 PID: 118 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.958674] CPU: 0 PID: 118 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    6.958886] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.958886]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[    6.958886]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.958886]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[    6.958886] Call Trace:
[    6.958886]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.958886]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.958886]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.958886]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.958886]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.958886]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.958886]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.958886]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.958886]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.958886]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    6.958886]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    6.958886]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    6.958886]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    6.958886]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    6.958886]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    6.958886]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    6.958886]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    6.958886]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.958886] ---[ end trace cfeb07101f6fbe82 ]---
[    6.983808] ------------[ cut here ]------------
[    6.984607] WARNING: CPU: 0 PID: 118 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    6.986300] CPU: 0 PID: 118 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    6.986925] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    6.986925]  0000000000000000 ffff88000b0a79e0 ffffffff81a23b9d ffff8800=
0b0a7a18
[    6.986925]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    6.986925]  0000000000000001 ffff88001200fa01 ffff88000b0a7a28 ffffffff=
810bc84b
[    6.986925] Call Trace:
[    6.986925]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    6.986925]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    6.986925]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    6.986925]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    6.986925]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    6.986925]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    6.986925]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    6.986925]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    6.986925]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    6.986925]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    6.986925]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    6.986925]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    6.986925]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    6.986925]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[    6.986925]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    6.986925]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    6.986925]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[    6.986925]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[    6.986925]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[    6.986925]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[    6.986925]  [<ffffffff811acaca>] dput+0x244/0x316
[    6.986925]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[    6.986925]  [<ffffffff8117347a>] ? validate_mm+0x211/0x224
[    6.986925]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    6.986925]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    6.986925]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[    6.986925]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[    6.986925]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    6.986925] ---[ end trace cfeb07101f6fbe83 ]---
[    7.020957] ------------[ cut here ]------------
[    7.021752] WARNING: CPU: 0 PID: 118 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.023450] CPU: 0 PID: 118 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.023996] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.023996]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[    7.023996]  ffffffff810bc765 ffffffff8111fac8 0000000000027000 ffff8800=
1200fa50
[    7.023996]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[    7.023996] Call Trace:
[    7.023996]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.023996]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.023996]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.023996]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.023996]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.023996]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.023996]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.023996]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.023996]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.023996]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.023996]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.023996]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.023996]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    7.023996]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    7.023996]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    7.023996]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    7.023996]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    7.023996]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    7.023996]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    7.023996]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.023996] ---[ end trace cfeb07101f6fbe84 ]---
[    7.050074] mount (118) used greatest stack depth: 13120 bytes left
[    7.051957] ------------[ cut here ]------------
[    7.052755] WARNING: CPU: 0 PID: 119 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.053341] CPU: 0 PID: 119 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    7.053341] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.053341]  0000000000000000 ffff88000b0bbaa8 ffffffff81a23b9d ffff8800=
0b0bbae0
[    7.053341]  ffffffff810bc765 ffffffff8111fac8 000000000000d000 ffff8800=
1200fa50
[    7.053341]  0000000000000001 ffff88001200fa01 ffff88000b0bbaf0 ffffffff=
810bc84b
[    7.053341] Call Trace:
[    7.053341]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.053341]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.053341]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.053341]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.053341]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.053341]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.053341]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.053341]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.053341]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.053341]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.053341]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.053341]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.053341]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    7.053341]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    7.053341]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    7.053341]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    7.053341]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    7.053341]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    7.053341]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    7.053341]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    7.053341]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    7.053341]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    7.053341]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    7.053341]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    7.053341] ---[ end trace cfeb07101f6fbe85 ]---
[    7.091960] ------------[ cut here ]------------
[    7.092767] WARNING: CPU: 0 PID: 119 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.093785] CPU: 0 PID: 119 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.093785] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.093785]  0000000000000000 ffff88000b0bbc50 ffffffff81a23b9d ffff8800=
0b0bbc88
[    7.093785]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.093785]  0000000000000001 ffff88001200fa01 ffff88000b0bbc98 ffffffff=
810bc84b
[    7.093785] Call Trace:
[    7.093785]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.093785]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.093785]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.093785]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.093785]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.093785]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.093785]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.093785]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.093785]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.093785]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.093785]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.093785]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.093785]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.093785]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.093785]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.093785]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.093785]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.093785]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.093785] ---[ end trace cfeb07101f6fbe86 ]---
[    7.119490] ------------[ cut here ]------------
[    7.120287] WARNING: CPU: 0 PID: 119 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.121961] CPU: 0 PID: 119 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.122574] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.122574]  0000000000000000 ffff88000b0bbc50 ffffffff81a23b9d ffff8800=
0b0bbc88
[    7.122574]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.122574]  0000000000000001 ffff88001200fa01 ffff88000b0bbc98 ffffffff=
810bc84b
[    7.122574] Call Trace:
[    7.122574]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.122574]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.122574]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.122574]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.122574]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.122574]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.122574]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.122574]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.122574]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.122574]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.122574]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.122574]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.122574]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.122574]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.122574]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.122574]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.122574]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.122574]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.122574] ---[ end trace cfeb07101f6fbe87 ]---
[    7.147189] ------------[ cut here ]------------
[    7.147987] WARNING: CPU: 0 PID: 119 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.149670] CPU: 0 PID: 119 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.150257] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.150257]  0000000000000000 ffff88000b0bbc50 ffffffff81a23b9d ffff8800=
0b0bbc88
[    7.150257]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.150257]  0000000000000001 ffff88001200fa01 ffff88000b0bbc98 ffffffff=
810bc84b
[    7.150257] Call Trace:
[    7.150257]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.150257]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.150257]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.150257]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.150257]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.150257]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.150257]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.150257]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.150257]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.150257]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.150257]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.150257]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.150257]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.150257]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.150257]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.150257]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.150257]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.150257]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.150257] ---[ end trace cfeb07101f6fbe88 ]---
[    7.174767] ------------[ cut here ]------------
[    7.175556] WARNING: CPU: 0 PID: 119 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.177262] CPU: 0 PID: 119 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.177909] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.177909]  0000000000000000 ffff88000b0bbc50 ffffffff81a23b9d ffff8800=
0b0bbc88
[    7.177909]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.177909]  0000000000000001 ffff88001200fa01 ffff88000b0bbc98 ffffffff=
810bc84b
[    7.177909] Call Trace:
[    7.177909]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.177909]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.177909]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.177909]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.177909]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.177909]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.177909]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.177909]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.177909]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.177909]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.177909]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.177909]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.177909]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.177909]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.177909]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.177909]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.177909]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.177909]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.177909] ---[ end trace cfeb07101f6fbe89 ]---
[    7.202269] ------------[ cut here ]------------
[    7.203064] WARNING: CPU: 0 PID: 119 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.204746] CPU: 0 PID: 119 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.205525] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.205525]  0000000000000000 ffff88000b0bb9e0 ffffffff81a23b9d ffff8800=
0b0bba18
[    7.205525]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.205525]  0000000000000001 ffff88001200fa01 ffff88000b0bba28 ffffffff=
810bc84b
[    7.205525] Call Trace:
[    7.205525]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.205525]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.205525]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.205525]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.205525]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.205525]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.205525]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.205525]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.205525]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.205525]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    7.205525]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    7.205525]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    7.205525]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    7.205525]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[    7.205525]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    7.205525]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    7.205525]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[    7.205525]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[    7.205525]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[    7.205525]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[    7.205525]  [<ffffffff811acaca>] dput+0x244/0x316
[    7.205525]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[    7.205525]  [<ffffffff8117347a>] ? validate_mm+0x211/0x224
[    7.205525]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    7.205525]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    7.205525]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[    7.205525]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[    7.205525]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.205525] ---[ end trace cfeb07101f6fbe8a ]---
[    7.244909] ------------[ cut here ]------------
[    7.245700] WARNING: CPU: 0 PID: 119 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.247406] CPU: 0 PID: 119 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.247952] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.247952]  0000000000000000 ffff88000b0bbc48 ffffffff81a23b9d ffff8800=
0b0bbc80
[    7.247952]  ffffffff810bc765 ffffffff8111fac8 000000000001a000 ffff8800=
1200fa50
[    7.247952]  0000000000000001 ffff88001200fa01 ffff88000b0bbc90 ffffffff=
810bc84b
[    7.247952] Call Trace:
[    7.247952]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.247952]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.247952]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.247952]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.247952]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.247952]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.247952]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.247952]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.247952]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.247952]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.247952]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.247952]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.247952]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    7.247952]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    7.247952]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    7.247952]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    7.247952]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    7.247952]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    7.247952]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    7.247952]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.247952] ---[ end trace cfeb07101f6fbe8b ]---
[    7.274063] ------------[ cut here ]------------
[    7.274842] WARNING: CPU: 0 PID: 119 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.276524] CPU: 0 PID: 119 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.277312] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.277312]  0000000000000000 ffff88000b0bbc48 ffffffff81a23b9d ffff8800=
0b0bbc80
[    7.277312]  ffffffff810bc765 ffffffff8111fac8 000000000000d000 ffff8800=
1200fa50
[    7.277312]  0000000000000001 ffff88001200fa01 ffff88000b0bbc90 ffffffff=
810bc84b
[    7.277312] Call Trace:
[    7.277312]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.277312]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.277312]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.277312]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.277312]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.277312]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.277312]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.277312]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.277312]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.277312]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.277312]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.277312]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.277312]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    7.277312]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    7.277312]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    7.277312]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    7.277312]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    7.277312]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    7.277312]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    7.277312]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.277312] ---[ end trace cfeb07101f6fbe8c ]---
[    7.304077] ------------[ cut here ]------------
[    7.304884] WARNING: CPU: 0 PID: 120 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.306588] CPU: 0 PID: 120 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    7.306677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.306677]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    7.306677]  ffffffff810bc765 ffffffff8111fac8 000000000000d000 ffff8800=
1200fa50
[    7.306677]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    7.306677] Call Trace:
[    7.306677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.306677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.306677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.306677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.306677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.306677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.306677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.306677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.306677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.306677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.306677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.306677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.306677]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    7.306677]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    7.306677]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    7.306677]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    7.306677]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    7.306677]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    7.306677]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    7.306677]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    7.306677]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    7.306677]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    7.306677]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    7.306677]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    7.306677] ---[ end trace cfeb07101f6fbe8d ]---
[    7.338636] ------------[ cut here ]------------
[    7.339437] WARNING: CPU: 0 PID: 120 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.340463] CPU: 0 PID: 120 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.340463] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.340463]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    7.340463]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.340463]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    7.340463] Call Trace:
[    7.340463]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.340463]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.340463]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.340463]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.340463]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.340463]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.340463]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.340463]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.340463]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.340463]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.340463]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.340463]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.340463]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.340463]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.340463]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.340463]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.340463]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.340463]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.340463] ---[ end trace cfeb07101f6fbe8e ]---
[    7.366927] ------------[ cut here ]------------
[    7.367737] WARNING: CPU: 0 PID: 120 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.369452] CPU: 0 PID: 120 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.370009] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.370009]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    7.370009]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.370009]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    7.370009] Call Trace:
[    7.370009]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.370009]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.370009]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.370009]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.370009]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.370009]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.370009]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.370009]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.370009]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.370009]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.370009]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.370009]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.370009]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.370009]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.370009]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.370009]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.370009]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.370009]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.370009] ---[ end trace cfeb07101f6fbe8f ]---
[    7.401124] ------------[ cut here ]------------
[    7.401940] WARNING: CPU: 0 PID: 120 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.403667] CPU: 0 PID: 120 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.404129] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.404129]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    7.404129]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.404129]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    7.404129] Call Trace:
[    7.404129]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.404129]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.404129]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.404129]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.404129]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.404129]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.404129]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.404129]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.404129]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.404129]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.404129]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.404129]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.404129]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.404129]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.404129]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.404129]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.404129]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.404129]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.404129] ---[ end trace cfeb07101f6fbe90 ]---
[    7.429565] ------------[ cut here ]------------
[    7.430402] WARNING: CPU: 0 PID: 120 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.432166] CPU: 0 PID: 120 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.432709] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.432709]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    7.432709]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.432709]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    7.432709] Call Trace:
[    7.432709]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.432709]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.432709]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.432709]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.432709]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.432709]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.432709]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.432709]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.432709]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.432709]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.432709]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.432709]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.432709]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.432709]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.432709]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.432709]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.432709]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.432709]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.432709] ---[ end trace cfeb07101f6fbe91 ]---
[    7.458050] ------------[ cut here ]------------
[    7.458871] WARNING: CPU: 0 PID: 120 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.460624] CPU: 0 PID: 120 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.461293] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.461293]  0000000000000000 ffff88000b0979e0 ffffffff81a23b9d ffff8800=
0b097a18
[    7.461293]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.461293]  0000000000000001 ffff88001200fa01 ffff88000b097a28 ffffffff=
810bc84b
[    7.461293] Call Trace:
[    7.461293]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.461293]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.461293]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.461293]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.461293]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.461293]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.461293]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.461293]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.461293]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.461293]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    7.461293]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    7.461293]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    7.461293]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    7.461293]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[    7.461293]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    7.461293]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    7.461293]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[    7.461293]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[    7.461293]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[    7.461293]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[    7.461293]  [<ffffffff811acaca>] dput+0x244/0x316
[    7.461293]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[    7.461293]  [<ffffffff8117347a>] ? validate_mm+0x211/0x224
[    7.461293]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    7.461293]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    7.461293]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[    7.461293]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[    7.461293]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.461293] ---[ end trace cfeb07101f6fbe92 ]---
[    7.496468] ------------[ cut here ]------------
[    7.497296] WARNING: CPU: 0 PID: 120 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.499051] CPU: 0 PID: 120 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.499516] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.499516]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    7.499516]  ffffffff810bc765 ffffffff8111fac8 000000000002b000 ffff8800=
1200fa50
[    7.499516]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    7.499516] Call Trace:
[    7.499516]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.499516]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.499516]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.499516]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.499516]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.499516]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.499516]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.499516]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.499516]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.499516]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.499516]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.499516]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.499516]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    7.499516]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    7.499516]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    7.499516]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    7.499516]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    7.499516]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    7.499516]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    7.499516]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.499516] ---[ end trace cfeb07101f6fbe93 ]---
[    7.527532] ------------[ cut here ]------------
[    7.528370] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    7.530009] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    7.530009] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.530009]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    7.530009]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.530009]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    7.530009] Call Trace:
[    7.530009]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.530009]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.530009]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.530009]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.530009]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.530009]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.530009]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.530009]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.530009]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.530009]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    7.530009]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    7.530009]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    7.530009]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    7.530009]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    7.530009]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    7.530009]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    7.530009]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    7.530009]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    7.530009]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    7.530009]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    7.530009]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    7.530009]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    7.530009]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    7.530009]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    7.530009]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    7.530009]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    7.530009]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    7.530009]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    7.530009]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    7.530009]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    7.530009]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    7.530009]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.530009] ---[ end trace cfeb07101f6fbe94 ]---
[    7.575361] ------------[ cut here ]------------
[    7.576213] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    7.577949] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    7.578480] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.578480]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    7.578480]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.578480]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    7.578480] Call Trace:
[    7.578480]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.578480]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.578480]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.578480]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.578480]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.578480]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.578480]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.578480]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.578480]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.578480]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.578480]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.578480]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.578480]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.578480]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.578480]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.578480]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.578480]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.578480]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.578480] ---[ end trace cfeb07101f6fbe95 ]---
[    7.603743] ------------[ cut here ]------------
[    7.604544] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    7.606298] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    7.606964] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.606964]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    7.606964]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.606964]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    7.606964] Call Trace:
[    7.606964]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.606964]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.606964]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.606964]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.606964]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.606964]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.606964]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.606964]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.606964]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.606964]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    7.606964]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    7.606964]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    7.606964]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    7.606964]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    7.606964]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    7.606964]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    7.606964]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    7.606964]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    7.606964]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    7.606964]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    7.606964]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    7.606964]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    7.606964]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    7.606964]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    7.606964]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    7.606964]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    7.606964]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    7.606964]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    7.606964]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    7.606964]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    7.606964]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    7.606964]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.606964] ---[ end trace cfeb07101f6fbe96 ]---
[    7.645450] ------------[ cut here ]------------
[    7.646273] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    7.648002] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    7.648661] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.648661]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    7.648661]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.648661]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    7.648661] Call Trace:
[    7.648661]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.648661]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.648661]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.648661]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.648661]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.648661]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.648661]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.648661]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.648661]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.648661]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.648661]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.648661]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.648661]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.648661]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.648661]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.648661]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.648661]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.648661]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.648661] ---[ end trace cfeb07101f6fbe97 ]---
[    7.674462] ------------[ cut here ]------------
[    7.675293] WARNING: CPU: 0 PID: 121 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.677020] CPU: 0 PID: 121 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    7.677020] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.677020]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    7.677020]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[    7.677020]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    7.677020] Call Trace:
[    7.677020]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.677020]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.677020]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.677020]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.677020]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.677020]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.677020]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.677020]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.677020]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.677020]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.677020]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.677020]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.677020]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    7.677020]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    7.677020]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    7.677020]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    7.677020]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    7.677020]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    7.677020]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    7.677020]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    7.677020]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    7.677020]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    7.677020]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    7.677020]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    7.677020] ---[ end trace cfeb07101f6fbe98 ]---
[    7.709998] ------------[ cut here ]------------
[    7.710839] WARNING: CPU: 0 PID: 121 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.711712] CPU: 0 PID: 121 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    7.711712] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.711712]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    7.711712]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.711712]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    7.711712] Call Trace:
[    7.711712]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.711712]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.711712]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.711712]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.711712]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.711712]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.711712]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.711712]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.711712]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.711712]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.711712]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.711712]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.711712]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.711712]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.711712]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.711712]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.711712]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.711712]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.711712] ---[ end trace cfeb07101f6fbe99 ]---
[    7.744517] ------------[ cut here ]------------
[    7.745337] WARNING: CPU: 0 PID: 121 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.747115] CPU: 0 PID: 121 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    7.747528] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.747528]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    7.747528]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.747528]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    7.747528] Call Trace:
[    7.747528]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.747528]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.747528]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.747528]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.747528]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.747528]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.747528]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.747528]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.747528]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.747528]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.747528]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.747528]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.747528]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.747528]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.747528]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.747528]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.747528]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.747528]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.747528] ---[ end trace cfeb07101f6fbe9a ]---
[    7.774210] ------------[ cut here ]------------
[    7.775033] WARNING: CPU: 0 PID: 121 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.776676] CPU: 0 PID: 121 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    7.776676] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.776676]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    7.776676]  ffffffff810bc765 ffffffff8111fac8 000000000001f000 ffff8800=
1200fa50
[    7.776676]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    7.776676] Call Trace:
[    7.776676]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.776676]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.776676]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.776676]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.776676]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.776676]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.776676]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.776676]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.776676]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.776676]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.776676]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.776676]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.776676]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    7.776676]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    7.776676]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    7.776676]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    7.776676]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    7.776676]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    7.776676]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    7.776676]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    7.776676]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    7.776676]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    7.776676]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    7.776676]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    7.776676] ---[ end trace cfeb07101f6fbe9b ]---
[    7.808163] ------------[ cut here ]------------
[    7.808962] WARNING: CPU: 0 PID: 121 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.810677] CPU: 0 PID: 121 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    7.811392] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.811392]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    7.811392]  ffffffff810bc765 ffffffff8111fac8 000000000001f000 ffff8800=
1200fa50
[    7.811392]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    7.811392] Call Trace:
[    7.811392]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.811392]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.811392]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.811392]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.811392]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.811392]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.811392]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.811392]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.811392]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.811392]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.811392]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.811392]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.811392]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    7.811392]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    7.811392]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    7.811392]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    7.811392]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    7.811392]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    7.811392]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    7.811392]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    7.811392]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    7.811392]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    7.811392]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    7.811392]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    7.811392] ---[ end trace cfeb07101f6fbe9c ]---
[    7.842863] ------------[ cut here ]------------
[    7.843676] WARNING: CPU: 0 PID: 121 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.845213] CPU: 0 PID: 121 Comm: chmod Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.845213] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.845213]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    7.845213]  ffffffff810bc765 ffffffff8111fac8 0000000000017000 ffff8800=
1200fa50
[    7.845213]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    7.845213] Call Trace:
[    7.845213]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.845213]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.845213]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.845213]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.845213]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.845213]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.845213]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.845213]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.845213]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.845213]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.845213]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.845213]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.845213]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    7.845213]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    7.845213]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    7.845213]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    7.845213]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    7.845213]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    7.845213]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.845213] ---[ end trace cfeb07101f6fbe9d ]---
[    7.873893] ------------[ cut here ]------------
[    7.874714] WARNING: CPU: 0 PID: 122 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.876442] CPU: 0 PID: 122 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    7.876678] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.876678]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    7.876678]  ffffffff810bc765 ffffffff8111fac8 000000000000c000 ffff8800=
1200fa50
[    7.876678]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    7.876678] Call Trace:
[    7.876678]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.876678]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.876678]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.876678]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.876678]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.876678]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.876678]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.876678]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.876678]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.876678]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.876678]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.876678]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.876678]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    7.876678]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    7.876678]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    7.876678]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    7.876678]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    7.876678]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    7.876678]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    7.876678]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    7.876678]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    7.876678]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    7.876678]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    7.876678]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    7.876678] ---[ end trace cfeb07101f6fbe9e ]---
[    7.914114] ------------[ cut here ]------------
[    7.914924] WARNING: CPU: 0 PID: 122 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.916594] CPU: 0 PID: 122 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.916677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.916677]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    7.916677]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.916677]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    7.916677] Call Trace:
[    7.916677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.916677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.916677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.916677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.916677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.916677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.916677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.916677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.916677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.916677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.916677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.916677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.916677]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.916677]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.916677]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.916677]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.916677]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.916677]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.916677] ---[ end trace cfeb07101f6fbe9f ]---
[    7.942143] ------------[ cut here ]------------
[    7.942950] WARNING: CPU: 0 PID: 122 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.944633] CPU: 0 PID: 122 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.944774] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.944774]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    7.944774]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.944774]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    7.944774] Call Trace:
[    7.944774]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.944774]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.944774]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.944774]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.944774]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.944774]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.944774]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.944774]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.944774]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.944774]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.944774]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.944774]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.944774]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.944774]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.944774]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.944774]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.944774]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.944774]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.944774] ---[ end trace cfeb07101f6fbea0 ]---
[    7.969763] ------------[ cut here ]------------
[    7.970551] WARNING: CPU: 0 PID: 122 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.972240] CPU: 0 PID: 122 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    7.972935] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.972935]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    7.972935]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    7.972935]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    7.972935] Call Trace:
[    7.972935]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    7.972935]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    7.972935]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    7.972935]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    7.972935]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    7.972935]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    7.972935]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    7.972935]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    7.972935]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    7.972935]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    7.972935]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    7.972935]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    7.972935]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    7.972935]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    7.972935]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    7.972935]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    7.972935]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    7.972935]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    7.972935] ---[ end trace cfeb07101f6fbea1 ]---
[    7.997145] ------------[ cut here ]------------
[    7.997930] WARNING: CPU: 0 PID: 122 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    7.999617] CPU: 0 PID: 122 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.000399] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.000399]  0000000000000000 ffff88000b0979e0 ffffffff81a23b9d ffff8800=
0b097a18
[    8.000399]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.000399]  0000000000000001 ffff88001200fa01 ffff88000b097a28 ffffffff=
810bc84b
[    8.000399] Call Trace:
[    8.000399]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.000399]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.000399]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.000399]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.000399]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.000399]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.000399]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.000399]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.000399]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.000399]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    8.000399]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    8.000399]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    8.000399]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    8.000399]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[    8.000399]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    8.000399]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    8.000399]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[    8.000399]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[    8.000399]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[    8.000399]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[    8.000399]  [<ffffffff811acaca>] dput+0x244/0x316
[    8.000399]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[    8.000399]  [<ffffffff8117347a>] ? validate_mm+0x211/0x224
[    8.000399]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    8.000399]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    8.000399]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[    8.000399]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[    8.000399]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.000399] ---[ end trace cfeb07101f6fbea2 ]---
[    8.034003] ------------[ cut here ]------------
[    8.034790] WARNING: CPU: 0 PID: 122 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.036466] CPU: 0 PID: 122 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.037062] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.037062]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    8.037062]  ffffffff810bc765 ffffffff8111fac8 000000000002a000 ffff8800=
1200fa50
[    8.037062]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    8.037062] Call Trace:
[    8.037062]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.037062]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.037062]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.037062]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.037062]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.037062]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.037062]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.037062]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.037062]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.037062]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.037062]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.037062]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.037062]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.037062]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.037062]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    8.037062]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    8.037062]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    8.037062]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    8.037062]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    8.037062]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.037062] ---[ end trace cfeb07101f6fbea3 ]---
[    8.070071] ------------[ cut here ]------------
[    8.070868] WARNING: CPU: 0 PID: 123 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.072544] CPU: 0 PID: 123 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    8.073345] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.073345]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    8.073345]  ffffffff810bc765 ffffffff8111fac8 000000000000e000 ffff8800=
1200fa50
[    8.073345]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    8.073345] Call Trace:
[    8.073345]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.073345]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.073345]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.073345]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.073345]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.073345]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.073345]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.073345]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.073345]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.073345]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.073345]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.073345]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.073345]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.073345]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.073345]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    8.073345]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    8.073345]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    8.073345]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    8.073345]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    8.073345]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    8.073345]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    8.073345]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    8.073345]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    8.073345]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    8.073345] ---[ end trace cfeb07101f6fbea4 ]---
[    8.104081] ------------[ cut here ]------------
[    8.104879] WARNING: CPU: 0 PID: 123 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.106553] CPU: 0 PID: 123 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.106678] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.106678]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    8.106678]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.106678]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    8.106678] Call Trace:
[    8.106678]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.106678]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.106678]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.106678]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.106678]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.106678]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.106678]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.106678]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.106678]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.106678]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.106678]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.106678]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.106678]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.106678]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.106678]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.106678]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.106678]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.106678]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.106678] ---[ end trace cfeb07101f6fbea5 ]---
[    8.131814] ------------[ cut here ]------------
[    8.132606] WARNING: CPU: 0 PID: 123 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.134291] CPU: 0 PID: 123 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.134548] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.134548]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    8.134548]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.134548]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    8.134548] Call Trace:
[    8.134548]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.134548]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.134548]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.134548]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.134548]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.134548]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.134548]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.134548]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.134548]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.134548]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.134548]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.134548]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.134548]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.134548]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.134548]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.134548]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.134548]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.134548]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.134548] ---[ end trace cfeb07101f6fbea6 ]---
[    8.159142] ------------[ cut here ]------------
[    8.159941] WARNING: CPU: 0 PID: 123 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.161604] CPU: 0 PID: 123 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.162296] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.162296]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    8.162296]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.162296]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    8.162296] Call Trace:
[    8.162296]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.162296]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.162296]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.162296]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.162296]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.162296]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.162296]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.162296]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.162296]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.162296]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.162296]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.162296]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.162296]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.162296]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.162296]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.162296]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.162296]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.162296]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.162296] ---[ end trace cfeb07101f6fbea7 ]---
[    8.186415] ------------[ cut here ]------------
[    8.187200] WARNING: CPU: 0 PID: 123 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.188878] CPU: 0 PID: 123 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.189670] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.189670]  0000000000000000 ffff88000b0979e0 ffffffff81a23b9d ffff8800=
0b097a18
[    8.189670]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.189670]  0000000000000001 ffff88001200fa01 ffff88000b097a28 ffffffff=
810bc84b
[    8.189670] Call Trace:
[    8.189670]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.189670]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.189670]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.189670]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.189670]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.189670]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.189670]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.189670]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.189670]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.189670]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    8.189670]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    8.189670]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    8.189670]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    8.189670]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[    8.189670]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    8.189670]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    8.189670]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[    8.189670]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[    8.189670]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[    8.189670]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[    8.189670]  [<ffffffff811acaca>] dput+0x244/0x316
[    8.189670]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[    8.189670]  [<ffffffff8117347a>] ? validate_mm+0x211/0x224
[    8.189670]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    8.189670]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    8.189670]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[    8.189670]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[    8.189670]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.189670] ---[ end trace cfeb07101f6fbea8 ]---
[    8.223235] ------------[ cut here ]------------
[    8.226296] WARNING: CPU: 0 PID: 123 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.226296] CPU: 0 PID: 123 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.226296] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.226296]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    8.226296]  ffffffff810bc765 ffffffff8111fac8 000000000002a000 ffff8800=
1200fa50
[    8.226296]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    8.226296] Call Trace:
[    8.226296]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.226296]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.226296]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.226296]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.226296]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.226296]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.226296]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.226296]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.226296]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.226296]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.226296]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.226296]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.226296]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.226296]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.226296]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    8.226296]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    8.226296]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    8.226296]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    8.226296]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    8.226296]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.226296] ---[ end trace cfeb07101f6fbea9 ]---
[    8.259154] ------------[ cut here ]------------
[    8.259968] WARNING: CPU: 0 PID: 124 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.260729] CPU: 0 PID: 124 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    8.260729] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.260729]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    8.260729]  ffffffff810bc765 ffffffff8111fac8 000000000000e000 ffff8800=
1200fa50
[    8.260729]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    8.260729] Call Trace:
[    8.260729]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.260729]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.260729]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.260729]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.260729]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.260729]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.260729]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.260729]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.260729]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.260729]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.260729]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.260729]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.260729]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.260729]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.260729]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    8.260729]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    8.260729]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    8.260729]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    8.260729]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    8.260729]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    8.260729]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    8.260729]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    8.260729]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    8.260729]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    8.260729] ---[ end trace cfeb07101f6fbeaa ]---
[    8.293327] ------------[ cut here ]------------
[    8.294129] WARNING: CPU: 0 PID: 124 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.295168] CPU: 0 PID: 124 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.295168] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.295168]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    8.295168]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.295168]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    8.295168] Call Trace:
[    8.295168]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.295168]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.295168]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.295168]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.295168]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.295168]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.295168]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.295168]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.295168]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.295168]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.295168]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.295168]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.295168]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.295168]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.295168]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.295168]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.295168]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.295168]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.295168] ---[ end trace cfeb07101f6fbeab ]---
[    8.321067] ------------[ cut here ]------------
[    8.321867] WARNING: CPU: 0 PID: 124 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.323551] CPU: 0 PID: 124 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.323887] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.323887]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    8.323887]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.323887]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    8.323887] Call Trace:
[    8.323887]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.323887]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.323887]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.323887]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.323887]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.323887]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.323887]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.323887]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.323887]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.323887]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.323887]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.323887]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.323887]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.323887]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.323887]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.323887]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.323887]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.323887]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.323887] ---[ end trace cfeb07101f6fbeac ]---
[    8.348883] ------------[ cut here ]------------
[    8.349697] WARNING: CPU: 0 PID: 124 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.351431] CPU: 0 PID: 124 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.352013] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.352013]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    8.352013]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.352013]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    8.352013] Call Trace:
[    8.352013]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.352013]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.352013]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.352013]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.352013]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.352013]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.352013]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.352013]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.352013]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.352013]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.352013]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.352013]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.352013]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.352013]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.352013]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.352013]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.352013]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.352013]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.352013] ---[ end trace cfeb07101f6fbead ]---
[    8.376913] ------------[ cut here ]------------
[    8.377720] WARNING: CPU: 0 PID: 124 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.379435] CPU: 0 PID: 124 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.380159] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.380159]  0000000000000000 ffff88000b0979e0 ffffffff81a23b9d ffff8800=
0b097a18
[    8.380159]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.380159]  0000000000000001 ffff88001200fa01 ffff88000b097a28 ffffffff=
810bc84b
[    8.380159] Call Trace:
[    8.380159]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.380159]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.380159]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.380159]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.380159]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.380159]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.380159]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.380159]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.380159]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.380159]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    8.380159]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    8.380159]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    8.380159]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    8.380159]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[    8.380159]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    8.380159]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    8.380159]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[    8.380159]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[    8.380159]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[    8.380159]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[    8.380159]  [<ffffffff811acaca>] dput+0x244/0x316
[    8.380159]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[    8.380159]  [<ffffffff8117347a>] ? validate_mm+0x211/0x224
[    8.380159]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    8.380159]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    8.380159]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[    8.380159]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[    8.380159]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.380159] ---[ end trace cfeb07101f6fbeae ]---
[    8.420856] ------------[ cut here ]------------
[    8.421654] WARNING: CPU: 0 PID: 124 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.423402] CPU: 0 PID: 124 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.423867] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.423867]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    8.423867]  ffffffff810bc765 ffffffff8111fac8 000000000002a000 ffff8800=
1200fa50
[    8.423867]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    8.423867] Call Trace:
[    8.423867]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.423867]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.423867]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.423867]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.423867]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.423867]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.423867]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.423867]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.423867]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.423867]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.423867]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.423867]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.423867]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.423867]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.423867]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    8.423867]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    8.423867]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    8.423867]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    8.423867]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    8.423867]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.423867] ---[ end trace cfeb07101f6fbeaf ]---
[    8.451509] ------------[ cut here ]------------
[    8.452346] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    8.454018] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    8.454018] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.454018]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    8.454018]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.454018]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    8.454018] Call Trace:
[    8.454018]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.454018]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.454018]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.454018]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.454018]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.454018]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.454018]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.454018]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.454018]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.454018]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    8.454018]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    8.454018]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    8.454018]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    8.454018]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    8.454018]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    8.454018]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    8.454018]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    8.454018]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    8.454018]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    8.454018]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    8.454018]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    8.454018]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    8.454018]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    8.454018]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    8.454018]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    8.454018]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    8.454018]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    8.454018]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    8.454018]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    8.454018]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    8.454018]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    8.454018]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.454018] ---[ end trace cfeb07101f6fbeb0 ]---
[    8.493386] ------------[ cut here ]------------
[    8.494211] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    8.495946] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    8.496677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.496677]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    8.496677]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.496677]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    8.496677] Call Trace:
[    8.496677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.496677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.496677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.496677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.496677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.496677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.496677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.496677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.496677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.496677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.496677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.496677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.496677]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.496677]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.496677]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.496677]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.496677]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.496677]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.496677] ---[ end trace cfeb07101f6fbeb1 ]---
[    8.521725] ------------[ cut here ]------------
[    8.522530] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    8.524276] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    8.524943] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.524943]  0000000000000000 ffff880012073908 ffffffff81a23b9d ffff8800=
12073940
[    8.524943]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.524943]  0000000000000001 ffff88001200fa01 ffff880012073950 ffffffff=
810bc84b
[    8.524943] Call Trace:
[    8.524943]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.524943]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.524943]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.524943]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.524943]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.524943]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.524943]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.524943]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.524943]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.524943]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    8.524943]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    8.524943]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    8.524943]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    8.524943]  [<ffffffff81a2f909>] ? __mutex_unlock_slowpath+0x144/0x153
[    8.524943]  [<ffffffff81a2f911>] ? __mutex_unlock_slowpath+0x14c/0x153
[    8.524943]  [<ffffffff81a2f926>] ? mutex_unlock+0xe/0x10
[    8.524943]  [<ffffffff8116ec17>] ? unmap_mapping_range+0x144/0x186
[    8.524943]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    8.524943]  [<ffffffff81158719>] truncate_pagecache+0x40/0x59
[    8.524943]  [<ffffffff81158744>] truncate_setsize+0x12/0x14
[    8.524943]  [<ffffffff811ba8fd>] simple_setattr+0x33/0x52
[    8.524943]  [<ffffffff811b1bfd>] notify_change+0x227/0x345
[    8.524943]  [<ffffffff81196a4f>] do_truncate+0x6b/0x92
[    8.524943]  [<ffffffff811a4e12>] do_last.isra.17+0xa6f/0xc09
[    8.524943]  [<ffffffff811a526c>] path_openat+0x2c0/0x667
[    8.524943]  [<ffffffff810f3bdf>] ? lock_is_held+0x4f/0x61
[    8.524943]  [<ffffffff811a5651>] do_filp_open+0x3e/0xd1
[    8.524943]  [<ffffffff81a30962>] ? _raw_spin_unlock+0x27/0x31
[    8.524943]  [<ffffffff811b2f21>] ? __alloc_fd+0x13c/0x14e
[    8.524943]  [<ffffffff81197573>] do_sys_open+0x8b/0x133
[    8.524943]  [<ffffffff81197639>] SyS_open+0x1e/0x20
[    8.524943]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.524943] ---[ end trace cfeb07101f6fbeb2 ]---
[    8.569399] ------------[ cut here ]------------
[    8.570206] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    8.571911] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    8.572589] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.572589]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    8.572589]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.572589]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    8.572589] Call Trace:
[    8.572589]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.572589]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.572589]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.572589]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.572589]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.572589]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.572589]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.572589]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.572589]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.572589]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.572589]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.572589]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.572589]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.572589]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.572589]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.572589]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.572589]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.572589]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.572589] ---[ end trace cfeb07101f6fbeb3 ]---
[    8.598027] ------------[ cut here ]------------
[    8.598841] WARNING: CPU: 0 PID: 125 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.600567] CPU: 0 PID: 125 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    8.600607] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.600607]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    8.600607]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[    8.600607]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    8.600607] Call Trace:
[    8.600607]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.600607]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.600607]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.600607]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.600607]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.600607]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.600607]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.600607]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.600607]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.600607]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.600607]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.600607]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.600607]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.600607]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.600607]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    8.600607]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    8.600607]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    8.600607]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    8.600607]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    8.600607]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    8.600607]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    8.600607]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    8.600607]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    8.600607]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    8.600607] ---[ end trace cfeb07101f6fbeb4 ]---
[    8.632960] ------------[ cut here ]------------
[    8.633784] WARNING: CPU: 0 PID: 125 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.634745] CPU: 0 PID: 125 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    8.634745] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.634745]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    8.634745]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.634745]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    8.634745] Call Trace:
[    8.634745]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.634745]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.634745]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.634745]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.634745]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.634745]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.634745]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.634745]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.634745]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.634745]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.634745]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.634745]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.634745]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.634745]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.634745]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.634745]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.634745]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.634745]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.634745] ---[ end trace cfeb07101f6fbeb5 ]---
[    8.661285] ------------[ cut here ]------------
[    8.662102] WARNING: CPU: 0 PID: 125 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.663827] CPU: 0 PID: 125 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    8.664308] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.664308]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    8.664308]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.664308]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    8.664308] Call Trace:
[    8.664308]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.664308]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.664308]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.664308]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.664308]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.664308]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.664308]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.664308]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.664308]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.664308]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.664308]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.664308]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.664308]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.664308]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.664308]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.664308]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.664308]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.664308]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.664308] ---[ end trace cfeb07101f6fbeb6 ]---
[    8.691154] ------------[ cut here ]------------
[    8.691968] WARNING: CPU: 0 PID: 126 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.693344] CPU: 0 PID: 126 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    8.693344] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.693344]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[    8.693344]  ffffffff810bc765 ffffffff8111fac8 0000000000012000 ffff8800=
1200fa50
[    8.693344]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[    8.693344] Call Trace:
[    8.693344]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.693344]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.693344]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.693344]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.693344]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.693344]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.693344]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.693344]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.693344]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.693344]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.693344]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.693344]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.693344]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.693344]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.693344]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    8.693344]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    8.693344]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    8.693344]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    8.693344]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    8.693344]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    8.693344]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    8.693344]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    8.693344]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    8.693344]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    8.693344] ---[ end trace cfeb07101f6fbeb7 ]---
[    8.725573] ------------[ cut here ]------------
[    8.727899] WARNING: CPU: 0 PID: 126 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.727899] CPU: 0 PID: 126 Comm: chmod Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.727899] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.727899]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[    8.727899]  ffffffff810bc765 ffffffff8111fac8 0000000000018000 ffff8800=
1200fa50
[    8.727899]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[    8.727899] Call Trace:
[    8.727899]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.727899]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.727899]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.727899]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.727899]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.727899]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.727899]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.727899]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.727899]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.727899]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.727899]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.727899]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.727899]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.727899]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.727899]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    8.727899]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    8.727899]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    8.727899]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    8.727899]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.727899] ---[ end trace cfeb07101f6fbeb8 ]---
[    8.760427] ------------[ cut here ]------------
[    8.761216] WARNING: CPU: 0 PID: 125 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.762887] CPU: 0 PID: 125 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    8.763341] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.763341]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    8.763341]  ffffffff810bc765 ffffffff8111fac8 000000000001f000 ffff8800=
1200fa50
[    8.763341]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    8.763341] Call Trace:
[    8.763341]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.763341]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.763341]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.763341]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.763341]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.763341]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.763341]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.763341]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.763341]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.763341]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.763341]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.763341]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.763341]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.763341]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.763341]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    8.763341]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    8.763341]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    8.763341]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    8.763341]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.763341] ---[ end trace cfeb07101f6fbeb9 ]---
[    8.788361] ------------[ cut here ]------------
[    8.789146] WARNING: CPU: 0 PID: 125 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.790827] CPU: 0 PID: 125 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    8.791571] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.791571]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    8.791571]  ffffffff810bc765 ffffffff8111fac8 000000000001e000 ffff8800=
1200fa50
[    8.791571]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    8.791571] Call Trace:
[    8.791571]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.791571]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.791571]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.791571]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.791571]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.791571]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.791571]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.791571]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.791571]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.791571]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.791571]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.791571]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.791571]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.791571]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.791571]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    8.791571]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    8.791571]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    8.791571]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    8.791571]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.791571] ---[ end trace cfeb07101f6fbeba ]---
[    8.818032] ------------[ cut here ]------------
[    8.818849] WARNING: CPU: 0 PID: 127 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.820011] CPU: 0 PID: 127 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    8.820011] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.820011]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    8.820011]  ffffffff810bc765 ffffffff8111fac8 000000000000e000 ffff8800=
1200fa50
[    8.820011]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    8.820011] Call Trace:
[    8.820011]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.820011]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.820011]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.820011]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.820011]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.820011]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.820011]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.820011]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.820011]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.820011]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.820011]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.820011]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.820011]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.820011]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.820011]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    8.820011]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    8.820011]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    8.820011]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    8.820011]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    8.820011]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    8.820011]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    8.820011]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    8.820011]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    8.820011]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    8.820011] ---[ end trace cfeb07101f6fbebb ]---
[    8.852164] ------------[ cut here ]------------
[    8.852978] WARNING: CPU: 0 PID: 127 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.854005] CPU: 0 PID: 127 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.854005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.854005]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    8.854005]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.854005]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    8.854005] Call Trace:
[    8.854005]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.854005]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.854005]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.854005]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.854005]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.854005]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.854005]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.854005]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.854005]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.854005]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.854005]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.854005]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.854005]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.854005]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.854005]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.854005]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.854005]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.854005]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.854005] ---[ end trace cfeb07101f6fbebc ]---
[    8.880107] ------------[ cut here ]------------
[    8.880912] WARNING: CPU: 0 PID: 127 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.882601] CPU: 0 PID: 127 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.883344] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.883344]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    8.883344]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.883344]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    8.883344] Call Trace:
[    8.883344]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.883344]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.883344]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.883344]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.883344]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.883344]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.883344]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.883344]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.883344]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.883344]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.883344]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.883344]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.883344]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.883344]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.883344]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.883344]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.883344]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.883344]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.883344] ---[ end trace cfeb07101f6fbebd ]---
[    8.913134] ------------[ cut here ]------------
[    8.913924] WARNING: CPU: 0 PID: 127 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.915606] CPU: 0 PID: 127 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.916311] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.916311]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    8.916311]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.916311]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    8.916311] Call Trace:
[    8.916311]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.916311]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.916311]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.916311]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.916311]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.916311]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.916311]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.916311]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.916311]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.916311]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.916311]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.916311]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.916311]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    8.916311]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    8.916311]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    8.916311]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    8.916311]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    8.916311]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.916311] ---[ end trace cfeb07101f6fbebe ]---
[    8.940594] ------------[ cut here ]------------
[    8.941377] WARNING: CPU: 0 PID: 127 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.943076] CPU: 0 PID: 127 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.943849] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.943849]  0000000000000000 ffff88000b0979e0 ffffffff81a23b9d ffff8800=
0b097a18
[    8.943849]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    8.943849]  0000000000000001 ffff88001200fa01 ffff88000b097a28 ffffffff=
810bc84b
[    8.943849] Call Trace:
[    8.943849]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.943849]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.943849]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.943849]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.943849]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.943849]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.943849]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.943849]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.943849]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.943849]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    8.943849]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    8.943849]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    8.943849]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    8.943849]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[    8.943849]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    8.943849]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    8.943849]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[    8.943849]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[    8.943849]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[    8.943849]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[    8.943849]  [<ffffffff811acaca>] dput+0x244/0x316
[    8.943849]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[    8.943849]  [<ffffffff8117347a>] ? validate_mm+0x211/0x224
[    8.943849]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    8.943849]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    8.943849]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[    8.943849]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[    8.943849]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.943849] ---[ end trace cfeb07101f6fbebf ]---
[    8.977617] ------------[ cut here ]------------
[    8.978409] WARNING: CPU: 0 PID: 127 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    8.980138] CPU: 0 PID: 127 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    8.980678] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    8.980678]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    8.980678]  ffffffff810bc765 ffffffff8111fac8 000000000002a000 ffff8800=
1200fa50
[    8.980678]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    8.980678] Call Trace:
[    8.980678]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    8.980678]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    8.980678]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    8.980678]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    8.980678]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    8.980678]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    8.980678]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    8.980678]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    8.980678]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    8.980678]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    8.980678]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    8.980678]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    8.980678]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    8.980678]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    8.980678]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    8.980678]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    8.980678]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    8.980678]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    8.980678]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    8.980678]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    8.980678] ---[ end trace cfeb07101f6fbec0 ]---
[    9.008364] ------------[ cut here ]------------
[    9.009181] WARNING: CPU: 0 PID: 128 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.010007] CPU: 0 PID: 128 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    9.010007] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.010007]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    9.010007]  ffffffff810bc765 ffffffff8111fac8 000000000000e000 ffff8800=
1200fa50
[    9.010007]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    9.010007] Call Trace:
[    9.010007]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.010007]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.010007]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.010007]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.010007]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.010007]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.010007]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.010007]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.010007]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.010007]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.010007]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.010007]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.010007]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.010007]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.010007]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    9.010007]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    9.010007]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    9.010007]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    9.010007]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    9.010007]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    9.010007]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    9.010007]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    9.010007]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    9.010007]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    9.010007] ---[ end trace cfeb07101f6fbec1 ]---
[    9.042717] ------------[ cut here ]------------
[    9.043523] WARNING: CPU: 0 PID: 128 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.044514] CPU: 0 PID: 128 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.044514] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.044514]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    9.044514]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.044514]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    9.044514] Call Trace:
[    9.044514]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.044514]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.044514]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.044514]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.044514]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.044514]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.044514]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.044514]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.044514]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.044514]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.044514]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.044514]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.044514]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.044514]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.044514]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.044514]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.044514]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.044514]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.044514] ---[ end trace cfeb07101f6fbec2 ]---
[    9.076053] ------------[ cut here ]------------
[    9.076852] WARNING: CPU: 0 PID: 128 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.078548] CPU: 0 PID: 128 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.078848] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.078848]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    9.078848]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.078848]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    9.078848] Call Trace:
[    9.078848]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.078848]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.078848]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.078848]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.078848]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.078848]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.078848]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.078848]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.078848]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.078848]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.078848]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.078848]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.078848]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.078848]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.078848]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.078848]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.078848]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.078848]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.078848] ---[ end trace cfeb07101f6fbec3 ]---
[    9.103669] ------------[ cut here ]------------
[    9.104457] WARNING: CPU: 0 PID: 128 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.106158] CPU: 0 PID: 128 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.106849] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.106849]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    9.106849]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.106849]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    9.106849] Call Trace:
[    9.106849]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.106849]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.106849]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.106849]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.106849]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.106849]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.106849]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.106849]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.106849]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.106849]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.106849]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.106849]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.106849]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.106849]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.106849]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.106849]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.106849]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.106849]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.106849] ---[ end trace cfeb07101f6fbec4 ]---
[    9.131063] ------------[ cut here ]------------
[    9.131849] WARNING: CPU: 0 PID: 128 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.133523] CPU: 0 PID: 128 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.134310] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.134310]  0000000000000000 ffff88000b0979e0 ffffffff81a23b9d ffff8800=
0b097a18
[    9.134310]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.134310]  0000000000000001 ffff88001200fa01 ffff88000b097a28 ffffffff=
810bc84b
[    9.134310] Call Trace:
[    9.134310]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.134310]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.134310]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.134310]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.134310]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.134310]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.134310]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.134310]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.134310]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.134310]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    9.134310]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    9.134310]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    9.134310]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    9.134310]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[    9.134310]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    9.134310]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    9.134310]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[    9.134310]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[    9.134310]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[    9.134310]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[    9.134310]  [<ffffffff811acaca>] dput+0x244/0x316
[    9.134310]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[    9.134310]  [<ffffffff8117347a>] ? validate_mm+0x211/0x224
[    9.134310]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    9.134310]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    9.134310]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[    9.134310]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[    9.134310]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.134310] ---[ end trace cfeb07101f6fbec5 ]---
[    9.167932] ------------[ cut here ]------------
[    9.168731] WARNING: CPU: 0 PID: 128 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.170425] CPU: 0 PID: 128 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.170983] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.170983]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    9.170983]  ffffffff810bc765 ffffffff8111fac8 000000000001b000 ffff8800=
1200fa50
[    9.170983]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    9.170983] Call Trace:
[    9.170983]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.170983]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.170983]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.170983]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.170983]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.170983]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.170983]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.170983]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.170983]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.170983]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.170983]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.170983]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.170983]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.170983]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.170983]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    9.170983]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    9.170983]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    9.170983]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    9.170983]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    9.170983]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.170983] ---[ end trace cfeb07101f6fbec6 ]---
[    9.196901] ------------[ cut here ]------------
[    9.197668] WARNING: CPU: 0 PID: 128 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.199354] CPU: 0 PID: 128 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.200150] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.200150]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    9.200150]  ffffffff810bc765 ffffffff8111fac8 000000000000f000 ffff8800=
1200fa50
[    9.200150]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    9.200150] Call Trace:
[    9.200150]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.200150]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.200150]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.200150]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.200150]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.200150]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.200150]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.200150]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.200150]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.200150]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.200150]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.200150]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.200150]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.200150]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.200150]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    9.200150]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    9.200150]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    9.200150]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    9.200150]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    9.200150]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.200150] ---[ end trace cfeb07101f6fbec7 ]---
[    9.231537] ------------[ cut here ]------------
[    9.232330] WARNING: CPU: 0 PID: 117 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.234025] CPU: 0 PID: 117 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    9.234325] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.234325]  0000000000000000 ffff88000b093c50 ffffffff81a23b9d ffff8800=
0b093c88
[    9.234325]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.234325]  0000000000000001 ffff88001200fa01 ffff88000b093c98 ffffffff=
810bc84b
[    9.234325] Call Trace:
[    9.234325]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.234325]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.234325]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.234325]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.234325]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.234325]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.234325]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.234325]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.234325]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.234325]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.234325]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.234325]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.234325]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.234325]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.234325]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.234325]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.234325]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.234325]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.234325] ---[ end trace cfeb07101f6fbec8 ]---
[    9.259552] init: Failed to create pty - disabling logging for job
[    9.260612] ------------[ cut here ]------------
[    9.261406] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    9.263072] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.263889] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.263889]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    9.263889]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.263889]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    9.263889] Call Trace:
[    9.263889]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.263889]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.263889]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.263889]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.263889]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.263889]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.263889]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.263889]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.263889]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.263889]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.263889]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.263889]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.263889]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.263889]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.263889]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.263889]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.263889]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.263889]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.263889] ---[ end trace cfeb07101f6fbec9 ]---
[    9.288222] init: Temporary process spawn error: No space left on device
[    9.289300] ------------[ cut here ]------------
[    9.290093] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counte=
r_uncharge_locked+0x48/0x74()
[    9.291348] CPU: 0 PID: 1 Comm: init Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.291348] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.291348]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff8800=
12073c88
[    9.291348]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.291348]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff=
810bc84b
[    9.291348] Call Trace:
[    9.291348]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.291348]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.291348]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.291348]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.291348]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.291348]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.291348]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.291348]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.291348]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.291348]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.291348]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.291348]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.291348]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.291348]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.291348]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.291348]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.291348]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.291348]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.291348] ---[ end trace cfeb07101f6fbeca ]---
[    9.317380] ------------[ cut here ]------------
[    9.318181] WARNING: CPU: 0 PID: 129 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.319878] CPU: 0 PID: 129 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    9.320007] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.320007]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    9.320007]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[    9.320007]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    9.320007] Call Trace:
[    9.320007]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.320007]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.320007]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.320007]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.320007]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.320007]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.320007]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.320007]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.320007]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.320007]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.320007]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.320007]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.320007]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.320007]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.320007]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    9.320007]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    9.320007]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    9.320007]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    9.320007]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    9.320007]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    9.320007]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    9.320007]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    9.320007]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    9.320007]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    9.320007] ---[ end trace cfeb07101f6fbecb ]---
[    9.352136] ------------[ cut here ]------------
[    9.352963] WARNING: CPU: 0 PID: 129 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.353740] CPU: 0 PID: 129 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.353740] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.353740]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    9.353740]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.353740]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    9.353740] Call Trace:
[    9.353740]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.353740]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.353740]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.353740]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.353740]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.353740]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.353740]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.353740]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.353740]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.353740]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.353740]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.353740]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.353740]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.353740]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.353740]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.353740]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.353740]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.353740]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.353740] ---[ end trace cfeb07101f6fbecc ]---
[    9.386268] ------------[ cut here ]------------
[    9.387092] WARNING: CPU: 0 PID: 129 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.388826] CPU: 0 PID: 129 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.389289] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.389289]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    9.389289]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.389289]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    9.389289] Call Trace:
[    9.389289]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.389289]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.389289]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.389289]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.389289]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.389289]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.389289]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.389289]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.389289]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.389289]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.389289]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.389289]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.389289]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.389289]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.389289]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.389289]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.389289]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.389289]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.389289] ---[ end trace cfeb07101f6fbecd ]---
[    9.416377] ------------[ cut here ]------------
[    9.417203] WARNING: CPU: 0 PID: 130 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.417558] CPU: 0 PID: 130 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.417558] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.417558]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[    9.417558]  ffffffff810bc765 ffffffff8111fac8 0000000000011000 ffff8800=
1200fa50
[    9.417558]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[    9.417558] Call Trace:
[    9.417558]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.417558]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.417558]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.417558]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.417558]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.417558]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.417558]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.417558]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.417558]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.417558]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.417558]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.417558]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.417558]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.417558]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.417558]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    9.417558]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    9.417558]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    9.417558]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    9.417558]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    9.417558]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    9.417558]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    9.417558]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    9.417558]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    9.417558]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    9.417558] ---[ end trace cfeb07101f6fbece ]---
[    9.450816] ------------[ cut here ]------------
[    9.451625] WARNING: CPU: 0 PID: 130 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.453341] CPU: 0 PID: 130 Comm: ln Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.453341] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.453341]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[    9.453341]  ffffffff810bc765 ffffffff8111fac8 0000000000016000 ffff8800=
1200fa50
[    9.453341]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[    9.453341] Call Trace:
[    9.453341]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.453341]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.453341]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.453341]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.453341]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.453341]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.453341]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.453341]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.453341]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.453341]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.453341]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.453341]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.453341]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.453341]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.453341]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    9.453341]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    9.453341]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    9.453341]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    9.453341]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.453341] ---[ end trace cfeb07101f6fbecf ]---
[    9.480144] ------------[ cut here ]------------
[    9.480965] WARNING: CPU: 0 PID: 129 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.482683] CPU: 0 PID: 129 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.483344] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.483344]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    9.483344]  ffffffff810bc765 ffffffff8111fac8 0000000000021000 ffff8800=
1200fa50
[    9.483344]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    9.483344] Call Trace:
[    9.483344]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.483344]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.483344]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.483344]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.483344]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.483344]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.483344]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.483344]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.483344]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.483344]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.483344]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.483344]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.483344]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.483344]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.483344]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    9.483344]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    9.483344]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    9.483344]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    9.483344]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.483344] ---[ end trace cfeb07101f6fbed0 ]---
[    9.508867] ------------[ cut here ]------------
[    9.509667] WARNING: CPU: 0 PID: 129 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.511399] CPU: 0 PID: 129 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.512086] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.512086]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    9.512086]  ffffffff810bc765 ffffffff8111fac8 000000000001e000 ffff8800=
1200fa50
[    9.512086]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    9.512086] Call Trace:
[    9.512086]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.512086]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.512086]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.512086]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.512086]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.512086]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.512086]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.512086]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.512086]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.512086]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.512086]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.512086]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.512086]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.512086]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.512086]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    9.512086]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[    9.512086]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    9.512086]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    9.512086]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.512086] ---[ end trace cfeb07101f6fbed1 ]---
[    9.539240] ------------[ cut here ]------------
[    9.540067] WARNING: CPU: 0 PID: 131 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.540772] CPU: 0 PID: 131 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[    9.540772] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.540772]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    9.540772]  ffffffff810bc765 ffffffff8111fac8 000000000000f000 ffff8800=
1200fa50
[    9.540772]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    9.540772] Call Trace:
[    9.540772]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.540772]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.540772]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.540772]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.540772]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.540772]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.540772]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.540772]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.540772]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.540772]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.540772]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.540772]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.540772]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.540772]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.540772]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    9.540772]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    9.540772]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    9.540772]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    9.540772]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    9.540772]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    9.540772]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    9.540772]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    9.540772]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    9.540772]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    9.540772] ---[ end trace cfeb07101f6fbed2 ]---
[    9.580248] ------------[ cut here ]------------
[    9.581076] WARNING: CPU: 0 PID: 131 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.582815] CPU: 0 PID: 131 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.583343] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.583343]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    9.583343]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.583343]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    9.583343] Call Trace:
[    9.583343]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.583343]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.583343]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.583343]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.583343]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.583343]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.583343]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.583343]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.583343]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.583343]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.583343]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.583343]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.583343]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.583343]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.583343]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.583343]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.583343]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.583343]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.583343] ---[ end trace cfeb07101f6fbed3 ]---
[    9.608619] ------------[ cut here ]------------
[    9.609438] WARNING: CPU: 0 PID: 131 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.611166] CPU: 0 PID: 131 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.611650] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.611650]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    9.611650]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.611650]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    9.611650] Call Trace:
[    9.611650]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.611650]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.611650]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.611650]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.611650]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.611650]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.611650]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.611650]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.611650]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.611650]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.611650]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.611650]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.611650]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.611650]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.611650]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.611650]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.611650]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.611650]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.611650] ---[ end trace cfeb07101f6fbed4 ]---
[    9.637958] ------------[ cut here ]------------
[    9.638785] WARNING: CPU: 0 PID: 131 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.640030] CPU: 0 PID: 131 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.640030] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.640030]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    9.640030]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.640030]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    9.640030] Call Trace:
[    9.640030]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.640030]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.640030]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.640030]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.640030]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.640030]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.640030]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.640030]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.640030]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.640030]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.640030]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.640030]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.640030]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.640030]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.640030]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.640030]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.640030]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.640030]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.640030] ---[ end trace cfeb07101f6fbed5 ]---
[    9.666190] ------------[ cut here ]------------
[    9.667006] WARNING: CPU: 0 PID: 131 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.668734] CPU: 0 PID: 131 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.669356] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.669356]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    9.669356]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.669356]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    9.669356] Call Trace:
[    9.669356]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.669356]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.669356]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.669356]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.669356]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.669356]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.669356]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.669356]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.669356]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.669356]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.669356]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.669356]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.669356]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.669356]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.669356]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.669356]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.669356]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.669356]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.669356] ---[ end trace cfeb07101f6fbed6 ]---
[    9.694324] ------------[ cut here ]------------
[    9.695137] WARNING: CPU: 0 PID: 131 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.696877] CPU: 0 PID: 131 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.697572] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.697572]  0000000000000000 ffff88000b0979e0 ffffffff81a23b9d ffff8800=
0b097a18
[    9.697572]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.697572]  0000000000000001 ffff88001200fa01 ffff88000b097a28 ffffffff=
810bc84b
[    9.697572] Call Trace:
[    9.697572]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.697572]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.697572]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.697572]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.697572]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.697572]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.697572]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.697572]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.697572]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.697572]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[    9.697572]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[    9.697572]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[    9.697572]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[    9.697572]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[    9.697572]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    9.697572]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[    9.697572]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[    9.697572]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[    9.697572]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[    9.697572]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[    9.697572]  [<ffffffff811acaca>] dput+0x244/0x316
[    9.697572]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[    9.697572]  [<ffffffff8117347a>] ? validate_mm+0x211/0x224
[    9.697572]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    9.697572]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[    9.697572]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[    9.697572]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[    9.697572]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.697572] ---[ end trace cfeb07101f6fbed7 ]---
[    9.738164] ------------[ cut here ]------------
[    9.738976] WARNING: CPU: 0 PID: 131 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.740713] CPU: 0 PID: 131 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.741180] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.741180]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    9.741180]  ffffffff810bc765 ffffffff8111fac8 0000000000024000 ffff8800=
1200fa50
[    9.741180]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    9.741180] Call Trace:
[    9.741180]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.741180]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.741180]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.741180]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.741180]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.741180]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.741180]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.741180]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.741180]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.741180]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.741180]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.741180]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.741180]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.741180]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.741180]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    9.741180]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    9.741180]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    9.741180]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    9.741180]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    9.741180]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.741180] ---[ end trace cfeb07101f6fbed8 ]---
[    9.768016] ------------[ cut here ]------------
[    9.768822] WARNING: CPU: 0 PID: 131 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.770544] CPU: 0 PID: 131 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[    9.771244] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.771244]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[    9.771244]  ffffffff810bc765 ffffffff8111fac8 0000000000013000 ffff8800=
1200fa50
[    9.771244]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[    9.771244] Call Trace:
[    9.771244]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.771244]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.771244]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.771244]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.771244]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.771244]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.771244]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.771244]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.771244]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.771244]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.771244]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.771244]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.771244]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.771244]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.771244]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[    9.771244]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[    9.771244]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[    9.771244]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[    9.771244]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[    9.771244]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.771244] ---[ end trace cfeb07101f6fbed9 ]---
[    9.800522] ------------[ cut here ]------------
[    9.801346] WARNING: CPU: 0 PID: 132 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.803070] CPU: 0 PID: 132 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    9.803344] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.803344]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    9.803344]  ffffffff810bc765 ffffffff8111fac8 0000000000011000 ffff8800=
1200fa50
[    9.803344]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    9.803344] Call Trace:
[    9.803344]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.803344]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.803344]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.803344]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.803344]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.803344]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.803344]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.803344]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.803344]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.803344]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.803344]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.803344]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.803344]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.803344]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.803344]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    9.803344]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    9.803344]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    9.803344]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    9.803344]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    9.803344]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    9.803344]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    9.803344]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    9.803344]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    9.803344]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    9.803344] ---[ end trace cfeb07101f6fbeda ]---
[    9.833955] ------------[ cut here ]------------
[    9.834758] WARNING: CPU: 0 PID: 132 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.836484] CPU: 0 PID: 132 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[    9.837210] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.837210]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[    9.837210]  ffffffff810bc765 ffffffff8111fac8 0000000000009000 ffff8800=
1200fa50
[    9.837210]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[    9.837210] Call Trace:
[    9.837210]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.837210]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.837210]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.837210]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.837210]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.837210]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.837210]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.837210]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.837210]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.837210]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.837210]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.837210]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.837210]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.837210]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.837210]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    9.837210]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    9.837210]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    9.837210]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    9.837210]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    9.837210]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    9.837210]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    9.837210]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    9.837210]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    9.837210]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    9.837210] ---[ end trace cfeb07101f6fbedb ]---
[    9.869004] ------------[ cut here ]------------
[    9.869831] WARNING: CPU: 0 PID: 132 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.870629] CPU: 0 PID: 132 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.870629] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.870629]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    9.870629]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.870629]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    9.870629] Call Trace:
[    9.870629]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.870629]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.870629]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.870629]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.870629]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.870629]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.870629]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.870629]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.870629]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.870629]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.870629]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.870629]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.870629]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.870629]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.870629]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.870629]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.870629]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.870629]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.870629] ---[ end trace cfeb07101f6fbedc ]---
[    9.903054] ------------[ cut here ]------------
[    9.903871] WARNING: CPU: 0 PID: 132 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.905598] CPU: 0 PID: 132 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.906082] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.906082]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[    9.906082]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.906082]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[    9.906082] Call Trace:
[    9.906082]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.906082]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.906082]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.906082]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.906082]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.906082]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.906082]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.906082]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.906082]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.906082]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.906082]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.906082]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.906082]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.906082]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[    9.906082]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.906082]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[    9.906082]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[    9.906082]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.906082] ---[ end trace cfeb07101f6fbedd ]---
[    9.932666] ------------[ cut here ]------------
[    9.933495] WARNING: CPU: 0 PID: 132 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.934326] CPU: 0 PID: 132 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.934326] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.934326]  0000000000000000 ffff88000b097c68 ffffffff81a23b9d ffff8800=
0b097ca0
[    9.934326]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[    9.934326]  0000000000000001 ffff88001200fa01 ffff88000b097cb0 ffffffff=
810bc84b
[    9.934326] Call Trace:
[    9.934326]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.934326]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.934326]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.934326]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.934326]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.934326]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.934326]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.934326]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.934326]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.934326]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.934326]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.934326]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.934326]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.934326]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.934326]  [<ffffffff81175596>] SyS_brk+0xbb/0x163
[    9.934326]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.934326] ---[ end trace cfeb07101f6fbede ]---
[    9.958718] ------------[ cut here ]------------
[    9.959516] WARNING: CPU: 0 PID: 132 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.961245] CPU: 0 PID: 132 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.961990] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.961990]  0000000000000000 ffff88000b097c68 ffffffff81a23b9d ffff8800=
0b097ca0
[    9.961990]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[    9.961990]  0000000000000001 ffff88001200fa01 ffff88000b097cb0 ffffffff=
810bc84b
[    9.961990] Call Trace:
[    9.961990]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.961990]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.961990]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.961990]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.961990]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.961990]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.961990]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.961990]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.961990]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.961990]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.961990]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.961990]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.961990]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[    9.961990]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[    9.961990]  [<ffffffff81175596>] SyS_brk+0xbb/0x163
[    9.961990]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[    9.961990] ---[ end trace cfeb07101f6fbedf ]---
[    9.985748] ------------[ cut here ]------------
[    9.986555] WARNING: CPU: 0 PID: 133 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[    9.988064] CPU: 0 PID: 133 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[    9.988064] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    9.988064]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[    9.988064]  ffffffff810bc765 ffffffff8111fac8 0000000000014000 ffff8800=
1200fa50
[    9.988064]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[    9.988064] Call Trace:
[    9.988064]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[    9.988064]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[    9.988064]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[    9.988064]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[    9.988064]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[    9.988064]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[    9.988064]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[    9.988064]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[    9.988064]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[    9.988064]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[    9.988064]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[    9.988064]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[    9.988064]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[    9.988064]  [<ffffffff810b9d42>] mmput+0x43/0xca
[    9.988064]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[    9.988064]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[    9.988064]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[    9.988064]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[    9.988064]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[    9.988064]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[    9.988064]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[    9.988064]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[    9.988064]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[    9.988064]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[    9.988064] ---[ end trace cfeb07101f6fbee0 ]---
[   10.020075] ------------[ cut here ]------------
[   10.020900] WARNING: CPU: 0 PID: 133 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.022630] CPU: 0 PID: 133 Comm: rm Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.023344] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.023344]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[   10.023344]  ffffffff810bc765 ffffffff8111fac8 0000000000016000 ffff8800=
1200fa50
[   10.023344]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[   10.023344] Call Trace:
[   10.023344]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.023344]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.023344]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.023344]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.023344]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.023344]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.023344]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.023344]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.023344]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.023344]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.023344]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.023344]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.023344]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.023344]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.023344]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.023344]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   10.023344]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.023344]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.023344]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.023344] ---[ end trace cfeb07101f6fbee1 ]---
[   10.050844] ------------[ cut here ]------------
[   10.051654] WARNING: CPU: 0 PID: 134 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.053343] CPU: 0 PID: 134 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.053343] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.053343]  0000000000000000 ffff88000b0d7aa8 ffffffff81a23b9d ffff8800=
0b0d7ae0
[   10.053343]  ffffffff810bc765 ffffffff8111fac8 0000000000016000 ffff8800=
1200fa50
[   10.053343]  0000000000000001 ffff88001200fa01 ffff88000b0d7af0 ffffffff=
810bc84b
[   10.053343] Call Trace:
[   10.053343]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.053343]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.053343]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.053343]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.053343]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.053343]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.053343]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.053343]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.053343]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.053343]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.053343]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.053343]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.053343]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.053343]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.053343]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   10.053343]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   10.053343]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   10.053343]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   10.053343]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   10.053343]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   10.053343]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   10.053343]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   10.053343]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   10.053343]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   10.053343] ---[ end trace cfeb07101f6fbee2 ]---
[   10.091822] ------------[ cut here ]------------
[   10.092636] WARNING: CPU: 0 PID: 134 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.093448] CPU: 0 PID: 134 Comm: find Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   10.093448] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.093448]  0000000000000000 ffff88000b0d7c48 ffffffff81a23b9d ffff8800=
0b0d7c80
[   10.093448]  ffffffff810bc765 ffffffff8111fac8 0000000000028000 ffff8800=
1200fa50
[   10.093448]  0000000000000001 ffff88001200fa01 ffff88000b0d7c90 ffffffff=
810bc84b
[   10.093448] Call Trace:
[   10.093448]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.093448]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.093448]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.093448]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.093448]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.093448]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.093448]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.093448]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.093448]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.093448]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.093448]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.093448]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.093448]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.093448]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.093448]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.093448]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   10.093448]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.093448]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.093448]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.093448] ---[ end trace cfeb07101f6fbee3 ]---
[   10.121675] ------------[ cut here ]------------
[   10.122500] WARNING: CPU: 0 PID: 135 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.123809] CPU: 0 PID: 135 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.123809] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.123809]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[   10.123809]  ffffffff810bc765 ffffffff8111fac8 0000000000017000 ffff8800=
1200fa50
[   10.123809]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[   10.123809] Call Trace:
[   10.123809]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.123809]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.123809]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.123809]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.123809]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.123809]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.123809]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.123809]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.123809]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.123809]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.123809]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.123809]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.123809]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.123809]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.123809]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   10.123809]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   10.123809]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   10.123809]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   10.123809]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   10.123809]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   10.123809]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   10.123809]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   10.123809]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   10.123809]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   10.123809] ---[ end trace cfeb07101f6fbee4 ]---
[   10.156642] ------------[ cut here ]------------
[   10.157454] WARNING: CPU: 0 PID: 135 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.158421] CPU: 0 PID: 135 Comm: find Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   10.158421] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.158421]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[   10.158421]  ffffffff810bc765 ffffffff8111fac8 0000000000028000 ffff8800=
1200fa50
[   10.158421]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[   10.158421] Call Trace:
[   10.158421]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.158421]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.158421]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.158421]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.158421]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.158421]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.158421]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.158421]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.158421]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.158421]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.158421]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.158421]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.158421]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.158421]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.158421]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.158421]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   10.158421]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.158421]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.158421]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.158421] ---[ end trace cfeb07101f6fbee5 ]---
[   10.188122] ------------[ cut here ]------------
[   10.188942] WARNING: CPU: 0 PID: 138 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.190010] CPU: 0 PID: 138 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.190010] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.190010]  0000000000000000 ffff88000b0f3aa8 ffffffff81a23b9d ffff8800=
0b0f3ae0
[   10.190010]  ffffffff810bc765 ffffffff8111fac8 0000000000014000 ffff8800=
1200fa50
[   10.190010]  0000000000000001 ffff88001200fa01 ffff88000b0f3af0 ffffffff=
810bc84b
[   10.190010] Call Trace:
[   10.190010]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.190010]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.190010]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.190010]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.190010]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.190010]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.190010]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.190010]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.190010]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.190010]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.190010]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.190010]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.190010]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.190010]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.190010]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   10.190010]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   10.190010]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   10.190010]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   10.190010]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   10.190010]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   10.190010]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   10.190010]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   10.190010]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   10.190010]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   10.190010] ---[ end trace cfeb07101f6fbee6 ]---
[   10.222857] ------------[ cut here ]------------
[   10.223666] WARNING: CPU: 0 PID: 137 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.225434] CPU: 0 PID: 137 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.225434] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.225434]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[   10.225434]  ffffffff810bc765 ffffffff8111fac8 0000000000014000 ffff8800=
1200fa50
[   10.225434]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[   10.225434] Call Trace:
[   10.225434]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.225434]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.225434]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.225434]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.225434]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.225434]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.225434]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.225434]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.225434]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.225434]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.225434]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.225434]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.225434]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.225434]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.225434]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   10.225434]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   10.225434]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   10.225434]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   10.225434]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   10.225434]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   10.225434]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   10.225434]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   10.225434]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   10.225434]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   10.225434] ---[ end trace cfeb07101f6fbee7 ]---
[   10.264644] ------------[ cut here ]------------
[   10.265496] WARNING: CPU: 0 PID: 137 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.266677] CPU: 0 PID: 137 Comm: df Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.266677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.266677]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[   10.266677]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   10.266677]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[   10.266677] Call Trace:
[   10.266677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.266677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.266677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.266677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.266677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.266677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.266677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.266677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.266677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.266677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.266677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.266677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.266677]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   10.266677]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   10.266677]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   10.266677]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   10.266677]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   10.266677]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.266677] ---[ end trace cfeb07101f6fbee8 ]---
[   10.293654] ------------[ cut here ]------------
[   10.294490] WARNING: CPU: 0 PID: 138 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.296273] CPU: 0 PID: 138 Comm: awk Tainted: G        W     3.16.0-rc1=
-00238-gddc5bfe #1
[   10.296722] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.296722]  0000000000000000 ffff88000b0f3c50 ffffffff81a23b9d ffff8800=
0b0f3c88
[   10.296722]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   10.296722]  0000000000000001 ffff88001200fa01 ffff88000b0f3c98 ffffffff=
810bc84b
[   10.296722] Call Trace:
[   10.296722]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.296722]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.296722]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.296722]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.296722]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.296722]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.296722]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.296722]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.296722]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.296722]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.296722]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.296722]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.296722]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   10.296722]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   10.296722]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   10.296722]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   10.296722]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   10.296722]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.296722] ---[ end trace cfeb07101f6fbee9 ]---
[   10.322262] ------------[ cut here ]------------
[   10.323108] WARNING: CPU: 0 PID: 137 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.324843] CPU: 0 PID: 137 Comm: df Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.325518] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.325518]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[   10.325518]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   10.325518]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[   10.325518] Call Trace:
[   10.325518]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.325518]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.325518]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.325518]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.325518]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.325518]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.325518]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.325518]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.325518]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.325518]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.325518]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.325518]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.325518]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   10.325518]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   10.325518]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   10.325518]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   10.325518]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   10.325518]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.325518] ---[ end trace cfeb07101f6fbeea ]---
[   10.350960] ------------[ cut here ]------------
[   10.351783] WARNING: CPU: 0 PID: 138 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.353539] CPU: 0 PID: 138 Comm: awk Tainted: G        W     3.16.0-rc1=
-00238-gddc5bfe #1
[   10.354087] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.354087]  0000000000000000 ffff88000b0f3c48 ffffffff81a23b9d ffff8800=
0b0f3c80
[   10.354087]  ffffffff810bc765 ffffffff8111fac8 0000000000020000 ffff8800=
1200fa50
[   10.354087]  0000000000000001 ffff88001200fa01 ffff88000b0f3c90 ffffffff=
810bc84b
[   10.354087] Call Trace:
[   10.354087]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.354087]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.354087]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.354087]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.354087]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.354087]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.354087]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.354087]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.354087]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.354087]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.354087]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.354087]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.354087]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.354087]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.354087]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.354087]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   10.354087]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.354087]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.354087]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.354087] ---[ end trace cfeb07101f6fbeeb ]---
[   10.380487] ------------[ cut here ]------------
[   10.381311] WARNING: CPU: 0 PID: 137 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.383093] CPU: 0 PID: 137 Comm: df Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.383559] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.383559]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[   10.383559]  ffffffff810bc765 ffffffff8111fac8 000000000001a000 ffff8800=
1200fa50
[   10.383559]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[   10.383559] Call Trace:
[   10.383559]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.383559]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.383559]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.383559]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.383559]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.383559]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.383559]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.383559]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.383559]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.383559]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.383559]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.383559]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.383559]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.383559]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.383559]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.383559]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   10.383559]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.383559]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.383559]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.383559] ---[ end trace cfeb07101f6fbeec ]---
[   10.416357] ------------[ cut here ]------------
[   10.417208] WARNING: CPU: 0 PID: 136 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.418968] CPU: 0 PID: 136 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.418990] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.418990]  0000000000000000 ffff88000b0d7c48 ffffffff81a23b9d ffff8800=
0b0d7c80
[   10.418990]  ffffffff810bc765 ffffffff8111fac8 0000000000017000 ffff8800=
1200fa50
[   10.418990]  0000000000000001 ffff88001200fa01 ffff88000b0d7c90 ffffffff=
810bc84b
[   10.418990] Call Trace:
[   10.418990]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.418990]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.418990]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.418990]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.418990]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.418990]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.418990]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.418990]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.418990]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.418990]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.418990]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.418990]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.418990]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.418990]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.418990]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.418990]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   10.418990]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.418990]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.418990]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.418990] ---[ end trace cfeb07101f6fbeed ]---
[   10.445610] ------------[ cut here ]------------
[   10.446435] WARNING: CPU: 0 PID: 136 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.448240] CPU: 0 PID: 136 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.448861] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.448861]  0000000000000000 ffff88000b0d7c48 ffffffff81a23b9d ffff8800=
0b0d7c80
[   10.448861]  ffffffff810bc765 ffffffff8111fac8 000000000000e000 ffff8800=
1200fa50
[   10.448861]  0000000000000001 ffff88001200fa01 ffff88000b0d7c90 ffffffff=
810bc84b
[   10.448861] Call Trace:
[   10.448861]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.448861]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.448861]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.448861]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.448861]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.448861]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.448861]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.448861]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.448861]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.448861]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.448861]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.448861]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.448861]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.448861]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.448861]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.448861]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   10.448861]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.448861]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.448861]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.448861] ---[ end trace cfeb07101f6fbeee ]---
[   10.476254] ------------[ cut here ]------------
[   10.477081] WARNING: CPU: 0 PID: 139 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.478273] CPU: 0 PID: 139 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.478273] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.478273]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[   10.478273]  ffffffff810bc765 ffffffff8111fac8 0000000000014000 ffff8800=
1200fa50
[   10.478273]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[   10.478273] Call Trace:
[   10.478273]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.478273]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.478273]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.478273]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.478273]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.478273]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.478273]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.478273]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.478273]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.478273]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.478273]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.478273]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.478273]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.478273]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.478273]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   10.478273]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   10.478273]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   10.478273]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   10.478273]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   10.478273]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   10.478273]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   10.478273]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   10.478273]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   10.478273]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   10.478273] ---[ end trace cfeb07101f6fbeef ]---
[   10.511816] ------------[ cut here ]------------
[   10.512631] WARNING: CPU: 0 PID: 139 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.513658] CPU: 0 PID: 139 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   10.513658] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.513658]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[   10.513658]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   10.513658]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[   10.513658] Call Trace:
[   10.513658]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.513658]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.513658]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.513658]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.513658]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.513658]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.513658]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.513658]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.513658]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.513658]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.513658]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.513658]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.513658]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   10.513658]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   10.513658]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   10.513658]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   10.513658]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   10.513658]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.513658] ---[ end trace cfeb07101f6fbef0 ]---
[   10.540610] ------------[ cut here ]------------
[   10.541428] WARNING: CPU: 0 PID: 139 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.543163] CPU: 0 PID: 139 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   10.543413] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.543413]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[   10.543413]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   10.543413]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[   10.543413] Call Trace:
[   10.543413]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.543413]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.543413]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.543413]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.543413]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.543413]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.543413]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.543413]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.543413]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.543413]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.543413]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.543413]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.543413]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   10.543413]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   10.543413]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   10.543413]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   10.543413]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   10.543413]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.543413] ---[ end trace cfeb07101f6fbef1 ]---
[   10.574504] ------------[ cut here ]------------
[   10.575321] WARNING: CPU: 0 PID: 139 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.577058] CPU: 0 PID: 139 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   10.577676] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.577676]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[   10.577676]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   10.577676]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[   10.577676] Call Trace:
[   10.577676]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.577676]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.577676]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.577676]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.577676]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.577676]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.577676]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.577676]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.577676]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.577676]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.577676]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.577676]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.577676]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   10.577676]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   10.577676]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   10.577676]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   10.577676]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   10.577676]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.577676] ---[ end trace cfeb07101f6fbef2 ]---
[   10.602612] ------------[ cut here ]------------
[   10.603425] WARNING: CPU: 0 PID: 139 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.605154] CPU: 0 PID: 139 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   10.605809] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.605809]  0000000000000000 ffff88000b0a79e0 ffffffff81a23b9d ffff8800=
0b0a7a18
[   10.605809]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   10.605809]  0000000000000001 ffff88001200fa01 ffff88000b0a7a28 ffffffff=
810bc84b
[   10.605809] Call Trace:
[   10.605809]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.605809]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.605809]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.605809]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.605809]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.605809]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.605809]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.605809]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.605809]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.605809]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[   10.605809]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[   10.605809]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[   10.605809]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[   10.605809]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[   10.605809]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[   10.605809]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[   10.605809]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[   10.605809]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[   10.605809]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[   10.605809]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[   10.605809]  [<ffffffff811acaca>] dput+0x244/0x316
[   10.605809]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[   10.605809]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[   10.605809]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[   10.605809]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   10.605809]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[   10.605809]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   10.605809]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[   10.605809]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.605809] ---[ end trace cfeb07101f6fbef3 ]---
[   10.641616] ------------[ cut here ]------------
[   10.642431] WARNING: CPU: 0 PID: 139 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.644183] CPU: 0 PID: 139 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   10.644668] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.644668]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[   10.644668]  ffffffff810bc765 ffffffff8111fac8 000000000001c000 ffff8800=
1200fa50
[   10.644668]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[   10.644668] Call Trace:
[   10.644668]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.644668]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.644668]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.644668]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.644668]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.644668]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.644668]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.644668]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.644668]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.644668]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.644668]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.644668]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.644668]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.644668]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.644668]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.644668]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[   10.644668]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   10.644668]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.644668]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.644668]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.644668] ---[ end trace cfeb07101f6fbef4 ]---
[   10.671317] ------------[ cut here ]------------
[   10.672117] WARNING: CPU: 0 PID: 139 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.673854] CPU: 0 PID: 139 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   10.674561] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.674561]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[   10.674561]  ffffffff810bc765 ffffffff8111fac8 000000000000e000 ffff8800=
1200fa50
[   10.674561]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[   10.674561] Call Trace:
[   10.674561]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.674561]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.674561]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.674561]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.674561]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.674561]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.674561]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.674561]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.674561]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.674561]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.674561]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.674561]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.674561]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.674561]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.674561]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.674561]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[   10.674561]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   10.674561]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.674561]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.674561]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.674561] ---[ end trace cfeb07101f6fbef5 ]---
[   10.701417] ------------[ cut here ]------------
[   10.702234] WARNING: CPU: 0 PID: 132 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.703973] CPU: 0 PID: 132 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.704223] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.704223]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[   10.704223]  ffffffff810bc765 ffffffff8111fac8 0000000000023000 ffff8800=
1200fa50
[   10.704223]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[   10.704223] Call Trace:
[   10.704223]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.704223]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.704223]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.704223]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.704223]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.704223]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.704223]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.704223]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.704223]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.704223]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.704223]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.704223]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.704223]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.704223]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.704223]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.704223]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   10.704223]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.704223]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.704223]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.704223] ---[ end trace cfeb07101f6fbef6 ]---
[   10.735963] ------------[ cut here ]------------
[   10.736770] WARNING: CPU: 0 PID: 132 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.738478] CPU: 0 PID: 132 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   10.739180] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.739180]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[   10.739180]  ffffffff810bc765 ffffffff8111fac8 000000000001e000 ffff8800=
1200fa50
[   10.739180]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[   10.739180] Call Trace:
[   10.739180]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.739180]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.739180]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.739180]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.739180]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.739180]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.739180]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.739180]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.739180]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.739180]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.739180]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.739180]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.739180]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.739180]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.739180]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.739180]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   10.739180]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.739180]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.739180]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.739180] ---[ end trace cfeb07101f6fbef7 ]---
[   10.766735] ------------[ cut here ]------------
[   10.767550] WARNING: CPU: 0 PID: 140 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.769285] CPU: 0 PID: 140 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[   10.770012] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.770012]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[   10.770012]  ffffffff810bc765 ffffffff8111fac8 000000000000e000 ffff8800=
1200fa50
[   10.770012]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[   10.770012] Call Trace:
[   10.770012]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.770012]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.770012]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.770012]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.770012]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.770012]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.770012]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.770012]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.770012]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.770012]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.770012]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.770012]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.770012]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.770012]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.770012]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   10.770012]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   10.770012]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   10.770012]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   10.770012]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   10.770012]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   10.770012]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   10.770012]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   10.770012]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   10.770012]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   10.770012] ---[ end trace cfeb07101f6fbef8 ]---
[   10.801782] ------------[ cut here ]------------
[   10.802596] WARNING: CPU: 0 PID: 140 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.803600] CPU: 0 PID: 140 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   10.803600] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.803600]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[   10.803600]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   10.803600]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[   10.803600] Call Trace:
[   10.803600]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.803600]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.803600]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.803600]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.803600]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.803600]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.803600]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.803600]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.803600]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.803600]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.803600]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.803600]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.803600]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   10.803600]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   10.803600]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   10.803600]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   10.803600]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   10.803600]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.803600] ---[ end trace cfeb07101f6fbef9 ]---
[   10.830339] ------------[ cut here ]------------
[   10.831164] WARNING: CPU: 0 PID: 140 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.832909] CPU: 0 PID: 140 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   10.833343] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.833343]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[   10.833343]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   10.833343]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[   10.833343] Call Trace:
[   10.833343]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.833343]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.833343]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.833343]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.833343]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.833343]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.833343]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.833343]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.833343]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.833343]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.833343]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.833343]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.833343]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   10.833343]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   10.833343]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   10.833343]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   10.833343]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   10.833343]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.833343] ---[ end trace cfeb07101f6fbefa ]---
[   10.858607] ------------[ cut here ]------------
[   10.859421] WARNING: CPU: 0 PID: 140 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.861155] CPU: 0 PID: 140 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   10.861783] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.861783]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[   10.861783]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   10.861783]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[   10.861783] Call Trace:
[   10.861783]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.861783]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.861783]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.861783]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.861783]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.861783]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.861783]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.861783]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.861783]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.861783]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.861783]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.861783]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.861783]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   10.861783]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   10.861783]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   10.861783]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   10.861783]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   10.861783]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.861783] ---[ end trace cfeb07101f6fbefb ]---
[   10.886653] ------------[ cut here ]------------
[   10.887465] WARNING: CPU: 0 PID: 140 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.889206] CPU: 0 PID: 140 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   10.889908] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.889908]  0000000000000000 ffff88000b0979e0 ffffffff81a23b9d ffff8800=
0b097a18
[   10.889908]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   10.889908]  0000000000000001 ffff88001200fa01 ffff88000b097a28 ffffffff=
810bc84b
[   10.889908] Call Trace:
[   10.889908]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.889908]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.889908]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.889908]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.889908]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.889908]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.889908]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.889908]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.889908]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.889908]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[   10.889908]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[   10.889908]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[   10.889908]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[   10.889908]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[   10.889908]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[   10.889908]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[   10.889908]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[   10.889908]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[   10.889908]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[   10.889908]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[   10.889908]  [<ffffffff811acaca>] dput+0x244/0x316
[   10.889908]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[   10.889908]  [<ffffffff8117347a>] ? validate_mm+0x211/0x224
[   10.889908]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   10.889908]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[   10.889908]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   10.889908]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[   10.889908]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.889908] ---[ end trace cfeb07101f6fbefc ]---
[   10.930479] ------------[ cut here ]------------
[   10.931297] WARNING: CPU: 0 PID: 140 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.933046] CPU: 0 PID: 140 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   10.933495] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.933495]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[   10.933495]  ffffffff810bc765 ffffffff8111fac8 000000000002a000 ffff8800=
1200fa50
[   10.933495]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[   10.933495] Call Trace:
[   10.933495]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.933495]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.933495]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.933495]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.933495]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.933495]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.933495]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.933495]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.933495]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.933495]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.933495]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.933495]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.933495]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.933495]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.933495]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   10.933495]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[   10.933495]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   10.933495]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   10.933495]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   10.933495]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   10.933495] ---[ end trace cfeb07101f6fbefd ]---
[   10.962398] ------------[ cut here ]------------
[   10.963220] WARNING: CPU: 0 PID: 141 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.963565] CPU: 0 PID: 141 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   10.963565] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.963565]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[   10.963565]  ffffffff810bc765 ffffffff8111fac8 0000000000011000 ffff8800=
1200fa50
[   10.963565]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[   10.963565] Call Trace:
[   10.963565]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.963565]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.963565]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.963565]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.963565]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.963565]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.963565]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.963565]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.963565]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.963565]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.963565]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.963565]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.963565]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.963565]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.963565]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   10.963565]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   10.963565]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   10.963565]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   10.963565]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   10.963565]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   10.963565]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   10.963565]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   10.963565]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   10.963565]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   10.963565] ---[ end trace cfeb07101f6fbefe ]---
[   10.995894] ------------[ cut here ]------------
[   10.996699] WARNING: CPU: 0 PID: 141 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   10.998417] CPU: 0 PID: 141 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   10.999134] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   10.999134]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[   10.999134]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[   10.999134]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[   10.999134] Call Trace:
[   10.999134]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   10.999134]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   10.999134]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   10.999134]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   10.999134]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   10.999134]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   10.999134]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   10.999134]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   10.999134]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   10.999134]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   10.999134]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   10.999134]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   10.999134]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   10.999134]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   10.999134]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   10.999134]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   10.999134]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   10.999134]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   10.999134]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   10.999134]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   10.999134]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   10.999134]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   10.999134]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   10.999134]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   10.999134] ---[ end trace cfeb07101f6fbeff ]---
[   11.031304] ------------[ cut here ]------------
[   11.032129] WARNING: CPU: 0 PID: 142 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.033344] CPU: 0 PID: 142 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   11.033344] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.033344]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[   11.033344]  ffffffff810bc765 ffffffff8111fac8 0000000000011000 ffff8800=
1200fa50
[   11.033344]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[   11.033344] Call Trace:
[   11.033344]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.033344]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.033344]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.033344]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.033344]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.033344]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.033344]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.033344]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.033344]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.033344]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.033344]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.033344]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.033344]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.033344]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.033344]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.033344]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.033344]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.033344]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.033344]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.033344]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.033344]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.033344]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.033344]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.033344]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.033344] ---[ end trace cfeb07101f6fbf00 ]---
[   11.064804] ------------[ cut here ]------------
[   11.065600] WARNING: CPU: 0 PID: 142 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.068059] CPU: 0 PID: 142 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   11.068059] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.068059]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[   11.068059]  ffffffff810bc765 ffffffff8111fac8 000000000000a000 ffff8800=
1200fa50
[   11.068059]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[   11.068059] Call Trace:
[   11.068059]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.068059]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.068059]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.068059]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.068059]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.068059]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.068059]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.068059]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.068059]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.068059]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.068059]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.068059]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.068059]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.068059]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.068059]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.068059]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.068059]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.068059]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.068059]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.068059]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.068059]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.068059]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.068059]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.068059]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.068059] ---[ end trace cfeb07101f6fbf01 ]---
[   11.105188] ------------[ cut here ]------------
[   11.106014] WARNING: CPU: 0 PID: 141 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.107282] CPU: 0 PID: 141 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.107282] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.107282]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[   11.107282]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   11.107282]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[   11.107282] Call Trace:
[   11.107282]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.107282]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.107282]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.107282]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.107282]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.107282]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.107282]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.107282]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.107282]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.107282]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.107282]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.107282]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.107282]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   11.107282]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   11.107282]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   11.107282]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   11.107282]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   11.107282]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.107282] ---[ end trace cfeb07101f6fbf02 ]---
[   11.133506] ------------[ cut here ]------------
[   11.134331] WARNING: CPU: 0 PID: 141 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.136071] CPU: 0 PID: 141 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.136682] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.136682]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[   11.136682]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   11.136682]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[   11.136682] Call Trace:
[   11.136682]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.136682]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.136682]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.136682]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.136682]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.136682]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.136682]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.136682]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.136682]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.136682]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.136682]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.136682]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.136682]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   11.136682]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   11.136682]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   11.136682]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   11.136682]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   11.136682]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.136682] ---[ end trace cfeb07101f6fbf03 ]---
[   11.164004] ------------[ cut here ]------------
[   11.164827] WARNING: CPU: 0 PID: 143 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.166550] CPU: 0 PID: 143 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.166677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.166677]  0000000000000000 ffff88000b0dfaa8 ffffffff81a23b9d ffff8800=
0b0dfae0
[   11.166677]  ffffffff810bc765 ffffffff8111fac8 0000000000011000 ffff8800=
1200fa50
[   11.166677]  0000000000000001 ffff88001200fa01 ffff88000b0dfaf0 ffffffff=
810bc84b
[   11.166677] Call Trace:
[   11.166677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.166677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.166677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.166677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.166677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.166677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.166677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.166677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.166677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.166677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.166677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.166677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.166677]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.166677]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.166677]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.166677]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.166677]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.166677]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.166677]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.166677]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.166677]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.166677]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.166677]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.166677]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.166677] ---[ end trace cfeb07101f6fbf04 ]---
[   11.198644] ------------[ cut here ]------------
[   11.199456] WARNING: CPU: 0 PID: 142 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.200804] CPU: 0 PID: 142 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.200804] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.200804]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[   11.200804]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   11.200804]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[   11.200804] Call Trace:
[   11.200804]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.200804]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.200804]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.200804]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.200804]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.200804]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.200804]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.200804]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.200804]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.200804]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.200804]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.200804]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.200804]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   11.200804]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   11.200804]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   11.200804]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   11.200804]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   11.200804]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.200804] ---[ end trace cfeb07101f6fbf05 ]---
[   11.226933] ------------[ cut here ]------------
[   11.227760] WARNING: CPU: 0 PID: 142 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.229501] CPU: 0 PID: 142 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.230009] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.230009]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[   11.230009]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   11.230009]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[   11.230009] Call Trace:
[   11.230009]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.230009]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.230009]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.230009]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.230009]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.230009]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.230009]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.230009]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.230009]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.230009]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.230009]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.230009]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.230009]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   11.230009]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   11.230009]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   11.230009]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   11.230009]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   11.230009]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.230009] ---[ end trace cfeb07101f6fbf06 ]---
[   11.261607] ------------[ cut here ]------------
[   11.262417] WARNING: CPU: 0 PID: 143 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.264096] CPU: 0 PID: 143 Comm: chmod Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   11.264096] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.264096]  0000000000000000 ffff88000b0dfc48 ffffffff81a23b9d ffff8800=
0b0dfc80
[   11.264096]  ffffffff810bc765 ffffffff8111fac8 0000000000017000 ffff8800=
1200fa50
[   11.264096]  0000000000000001 ffff88001200fa01 ffff88000b0dfc90 ffffffff=
810bc84b
[   11.264096] Call Trace:
[   11.264096]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.264096]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.264096]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.264096]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.264096]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.264096]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.264096]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.264096]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.264096]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.264096]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.264096]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.264096]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.264096]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.264096]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.264096]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   11.264096]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   11.264096]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   11.264096]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   11.264096]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.264096] ---[ end trace cfeb07101f6fbf07 ]---
[   11.291347] ------------[ cut here ]------------
[   11.292169] WARNING: CPU: 0 PID: 144 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.293584] CPU: 0 PID: 144 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.293584] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.293584]  0000000000000000 ffff88000b0e3aa8 ffffffff81a23b9d ffff8800=
0b0e3ae0
[   11.293584]  ffffffff810bc765 ffffffff8111fac8 0000000000012000 ffff8800=
1200fa50
[   11.293584]  0000000000000001 ffff88001200fa01 ffff88000b0e3af0 ffffffff=
810bc84b
[   11.293584] Call Trace:
[   11.293584]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.293584]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.293584]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.293584]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.293584]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.293584]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.293584]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.293584]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.293584]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.293584]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.293584]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.293584]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.293584]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.293584]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.293584]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.293584]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.293584]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.293584]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.293584]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.293584]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.293584]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.293584]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.293584]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.293584]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.293584] ---[ end trace cfeb07101f6fbf08 ]---
[   11.329084] ------------[ cut here ]------------
[   11.329919] WARNING: CPU: 0 PID: 147 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.330010] CPU: 0 PID: 147 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.330010] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.330010]  0000000000000000 ffff88000b12baa8 ffffffff81a23b9d ffff8800=
0b12bae0
[   11.330010]  ffffffff810bc765 ffffffff8111fac8 0000000000013000 ffff8800=
1200fa50
[   11.330010]  0000000000000001 ffff88001200fa01 ffff88000b12baf0 ffffffff=
810bc84b
[   11.330010] Call Trace:
[   11.330010]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.330010]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.330010]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.330010]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.330010]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.330010]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.330010]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.330010]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.330010]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.330010]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.330010]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.330010]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.330010]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.330010]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.330010]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.330010]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.330010]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.330010]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.330010]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.330010]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.330010]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.330010]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.330010]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.330010]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.330010] ---[ end trace cfeb07101f6fbf09 ]---
[   11.363537] ------------[ cut here ]------------
[   11.364353] WARNING: CPU: 0 PID: 144 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.366090] CPU: 0 PID: 144 Comm: chgrp Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   11.366677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.366677]  0000000000000000 ffff88000b0e3c50 ffffffff81a23b9d ffff8800=
0b0e3c88
[   11.366677]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   11.366677]  0000000000000001 ffff88001200fa01 ffff88000b0e3c98 ffffffff=
810bc84b
[   11.366677] Call Trace:
[   11.366677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.366677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.366677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.366677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.366677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.366677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.366677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.366677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.366677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.366677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.366677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.366677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.366677]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   11.366677]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   11.366677]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   11.366677]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   11.366677]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   11.366677]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.366677] ---[ end trace cfeb07101f6fbf0a ]---
[   11.392077] ------------[ cut here ]------------
[   11.392895] WARNING: CPU: 0 PID: 146 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.394618] CPU: 0 PID: 146 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.394741] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.394741]  0000000000000000 ffff88000b117aa8 ffffffff81a23b9d ffff8800=
0b117ae0
[   11.394741]  ffffffff810bc765 ffffffff8111fac8 0000000000013000 ffff8800=
1200fa50
[   11.394741]  0000000000000001 ffff88001200fa01 ffff88000b117af0 ffffffff=
810bc84b
[   11.394741] Call Trace:
[   11.394741]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.394741]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.394741]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.394741]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.394741]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.394741]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.394741]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.394741]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.394741]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.394741]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.394741]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.394741]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.394741]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.394741]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.394741]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.394741]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.394741]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.394741]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.394741]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.394741]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.394741]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.394741]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.394741]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.394741]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.394741] ---[ end trace cfeb07101f6fbf0b ]---
[   11.432285] ------------[ cut here ]------------
[   11.433110] WARNING: CPU: 0 PID: 144 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.434634] CPU: 0 PID: 144 Comm: chgrp Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   11.434634] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.434634]  0000000000000000 ffff88000b0e3c48 ffffffff81a23b9d ffff8800=
0b0e3c80
[   11.434634]  ffffffff810bc765 ffffffff8111fac8 0000000000025000 ffff8800=
1200fa50
[   11.434634]  0000000000000001 ffff88001200fa01 ffff88000b0e3c90 ffffffff=
810bc84b
[   11.434634] Call Trace:
[   11.434634]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.434634]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.434634]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.434634]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.434634]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.434634]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.434634]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.434634]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.434634]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.434634]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.434634]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.434634]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.434634]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.434634]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.434634]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   11.434634]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   11.434634]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   11.434634]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   11.434634]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.434634] ---[ end trace cfeb07101f6fbf0c ]---
[   11.461698] ------------[ cut here ]------------
[   11.462504] WARNING: CPU: 0 PID: 148 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.464237] CPU: 0 PID: 148 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.464293] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.464293]  0000000000000000 ffff88000b14faa8 ffffffff81a23b9d ffff8800=
0b14fae0
[   11.464293]  ffffffff810bc765 ffffffff8111fac8 0000000000013000 ffff8800=
1200fa50
[   11.464293]  0000000000000001 ffff88001200fa01 ffff88000b14faf0 ffffffff=
810bc84b
[   11.464293] Call Trace:
[   11.464293]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.464293]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.464293]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.464293]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.464293]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.464293]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.464293]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.464293]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.464293]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.464293]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.464293]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.464293]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.464293]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.464293]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.464293]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.464293]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.464293]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.464293]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.464293]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.464293]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.464293]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.464293]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.464293]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.464293]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.464293] ---[ end trace cfeb07101f6fbf0d ]---
[   11.496544] ------------[ cut here ]------------
[   11.497378] WARNING: CPU: 0 PID: 149 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.498526] CPU: 0 PID: 149 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.498526] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.498526]  0000000000000000 ffff88000b16baa8 ffffffff81a23b9d ffff8800=
0b16bae0
[   11.498526]  ffffffff810bc765 ffffffff8111fac8 0000000000012000 ffff8800=
1200fa50
[   11.498526]  0000000000000001 ffff88001200fa01 ffff88000b16baf0 ffffffff=
810bc84b
[   11.498526] Call Trace:
[   11.498526]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.498526]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.498526]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.498526]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.498526]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.498526]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.498526]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.498526]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.498526]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.498526]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.498526]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.498526]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.498526]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.498526]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.498526]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.498526]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.498526]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.498526]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.498526]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.498526]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.498526]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.498526]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.498526]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.498526]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.498526] ---[ end trace cfeb07101f6fbf0e ]---
[   11.533069] ------------[ cut here ]------------
[   11.533677] WARNING: CPU: 0 PID: 147 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.533677] CPU: 0 PID: 147 Comm: grep Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   11.533677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.533677]  0000000000000000 ffff88000b12bc48 ffffffff81a23b9d ffff8800=
0b12bc80
[   11.533677]  ffffffff810bc765 ffffffff8111fac8 000000000001f000 ffff8800=
1200fa50
[   11.533677]  0000000000000001 ffff88001200fa01 ffff88000b12bc90 ffffffff=
810bc84b
[   11.533677] Call Trace:
[   11.533677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.533677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.533677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.533677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.533677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.533677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.533677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.533677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.533677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.533677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.533677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.533677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.533677]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.533677]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.533677]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   11.533677]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   11.533677]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   11.533677]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   11.533677]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.533677] ---[ end trace cfeb07101f6fbf0f ]---
[   11.563297] ------------[ cut here ]------------
[   11.564137] WARNING: CPU: 0 PID: 149 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.565509] CPU: 0 PID: 149 Comm: mkdir Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   11.565509] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.565509]  0000000000000000 ffff88000b16bc50 ffffffff81a23b9d ffff8800=
0b16bc88
[   11.565509]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   11.565509]  0000000000000001 ffff88001200fa01 ffff88000b16bc98 ffffffff=
810bc84b
[   11.565509] Call Trace:
[   11.565509]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.565509]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.565509]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.565509]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.565509]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.565509]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.565509]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.565509]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.565509]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.565509]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.565509]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.565509]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.565509]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   11.565509]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   11.565509]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   11.565509]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   11.565509]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   11.565509]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.565509] ---[ end trace cfeb07101f6fbf10 ]---
[   11.597729] ------------[ cut here ]------------
[   11.598544] WARNING: CPU: 0 PID: 148 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.600307] CPU: 0 PID: 148 Comm: cut Tainted: G        W     3.16.0-rc1=
-00238-gddc5bfe #1
[   11.600837] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.600837]  0000000000000000 ffff88000b14fc48 ffffffff81a23b9d ffff8800=
0b14fc80
[   11.600837]  ffffffff810bc765 ffffffff8111fac8 0000000000017000 ffff8800=
1200fa50
[   11.600837]  0000000000000001 ffff88001200fa01 ffff88000b14fc90 ffffffff=
810bc84b
[   11.600837] Call Trace:
[   11.600837]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.600837]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.600837]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.600837]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.600837]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.600837]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.600837]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.600837]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.600837]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.600837]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.600837]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.600837]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.600837]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.600837]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.600837]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   11.600837]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   11.600837]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   11.600837]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   11.600837]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.600837] ---[ end trace cfeb07101f6fbf11 ]---
[   11.627199] ------------[ cut here ]------------
[   11.628016] WARNING: CPU: 0 PID: 149 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.629772] CPU: 0 PID: 149 Comm: mkdir Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   11.630129] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.630129]  0000000000000000 ffff88000b16bc48 ffffffff81a23b9d ffff8800=
0b16bc80
[   11.630129]  ffffffff810bc765 ffffffff8111fac8 000000000001c000 ffff8800=
1200fa50
[   11.630129]  0000000000000001 ffff88001200fa01 ffff88000b16bc90 ffffffff=
810bc84b
[   11.630129] Call Trace:
[   11.630129]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.630129]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.630129]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.630129]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.630129]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.630129]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.630129]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.630129]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.630129]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.630129]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.630129]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.630129]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.630129]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.630129]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.630129]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   11.630129]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   11.630129]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   11.630129]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   11.630129]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.630129] ---[ end trace cfeb07101f6fbf12 ]---
[   11.656551] ------------[ cut here ]------------
[   11.657379] WARNING: CPU: 0 PID: 146 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.659136] CPU: 0 PID: 146 Comm: cat Tainted: G        W     3.16.0-rc1=
-00238-gddc5bfe #1
[   11.659633] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.659633]  0000000000000000 ffff88000b117c48 ffffffff81a23b9d ffff8800=
0b117c80
[   11.659633]  ffffffff810bc765 ffffffff8111fac8 0000000000019000 ffff8800=
1200fa50
[   11.659633]  0000000000000001 ffff88001200fa01 ffff88000b117c90 ffffffff=
810bc84b
[   11.659633] Call Trace:
[   11.659633]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.659633]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.659633]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.659633]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.659633]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.659633]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.659633]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.659633]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.659633]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.659633]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.659633]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.659633]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.659633]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.659633]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.659633]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   11.659633]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   11.659633]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   11.659633]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   11.659633]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.659633] ---[ end trace cfeb07101f6fbf13 ]---
[   11.686834] ------------[ cut here ]------------
[   11.687625] WARNING: CPU: 0 PID: 141 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.689302] CPU: 0 PID: 141 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.690011] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.690011]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[   11.690011]  ffffffff810bc765 ffffffff8111fac8 0000000000013000 ffff8800=
1200fa50
[   11.690011]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[   11.690011] Call Trace:
[   11.690011]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.690011]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.690011]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.690011]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.690011]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.690011]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.690011]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.690011]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.690011]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.690011]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.690011]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.690011]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.690011]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.690011]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.690011]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   11.690011]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   11.690011]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   11.690011]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   11.690011]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.690011] ---[ end trace cfeb07101f6fbf14 ]---
[   11.714788] ------------[ cut here ]------------
[   11.715560] WARNING: CPU: 0 PID: 141 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.717242] CPU: 0 PID: 141 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.718044] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.718044]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[   11.718044]  ffffffff810bc765 ffffffff8111fac8 000000000000c000 ffff8800=
1200fa50
[   11.718044]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[   11.718044] Call Trace:
[   11.718044]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.718044]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.718044]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.718044]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.718044]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.718044]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.718044]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.718044]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.718044]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.718044]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.718044]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.718044]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.718044]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.718044]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.718044]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   11.718044]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   11.718044]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   11.718044]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   11.718044]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.718044] ---[ end trace cfeb07101f6fbf15 ]---
[   11.743384] ------------[ cut here ]------------
[   11.746677] WARNING: CPU: 0 PID: 145 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.746677] CPU: 0 PID: 145 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.746677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.746677]  0000000000000000 ffff88000b113c48 ffffffff81a23b9d ffff8800=
0b113c80
[   11.746677]  ffffffff810bc765 ffffffff8111fac8 0000000000016000 ffff8800=
1200fa50
[   11.746677]  0000000000000001 ffff88001200fa01 ffff88000b113c90 ffffffff=
810bc84b
[   11.746677] Call Trace:
[   11.746677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.746677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.746677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.746677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.746677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.746677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.746677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.746677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.746677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.746677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.746677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.746677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.746677]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.746677]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.746677]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   11.746677]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   11.746677]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   11.746677]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   11.746677]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.746677] ---[ end trace cfeb07101f6fbf16 ]---
[   11.776772] ------------[ cut here ]------------
[   11.777540] WARNING: CPU: 0 PID: 145 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.779217] CPU: 0 PID: 145 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.780009] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.780009]  0000000000000000 ffff88000b113c48 ffffffff81a23b9d ffff8800=
0b113c80
[   11.780009]  ffffffff810bc765 ffffffff8111fac8 000000000000e000 ffff8800=
1200fa50
[   11.780009]  0000000000000001 ffff88001200fa01 ffff88000b113c90 ffffffff=
810bc84b
[   11.780009] Call Trace:
[   11.780009]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.780009]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.780009]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.780009]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.780009]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.780009]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.780009]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.780009]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.780009]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.780009]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.780009]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.780009]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.780009]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.780009]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.780009]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   11.780009]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   11.780009]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   11.780009]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   11.780009]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.780009] ---[ end trace cfeb07101f6fbf17 ]---
[   11.806055] ------------[ cut here ]------------
[   11.806863] WARNING: CPU: 0 PID: 151 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.807982] CPU: 0 PID: 151 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.807982] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.807982]  0000000000000000 ffff88000b117aa8 ffffffff81a23b9d ffff8800=
0b117ae0
[   11.807982]  ffffffff810bc765 ffffffff8111fac8 0000000000013000 ffff8800=
1200fa50
[   11.807982]  0000000000000001 ffff88001200fa01 ffff88000b117af0 ffffffff=
810bc84b
[   11.807982] Call Trace:
[   11.807982]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.807982]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.807982]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.807982]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.807982]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.807982]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.807982]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.807982]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.807982]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.807982]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.807982]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.807982]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.807982]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.807982]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.807982]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.807982]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.807982]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.807982]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.807982]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.807982]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.807982]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.807982]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.807982]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.807982]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.807982] ---[ end trace cfeb07101f6fbf18 ]---
[   11.840274] ------------[ cut here ]------------
[   11.841087] WARNING: CPU: 0 PID: 152 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.842784] CPU: 0 PID: 152 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.843344] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.843344]  0000000000000000 ffff88000b12baa8 ffffffff81a23b9d ffff8800=
0b12bae0
[   11.843344]  ffffffff810bc765 ffffffff8111fac8 0000000000012000 ffff8800=
1200fa50
[   11.843344]  0000000000000001 ffff88001200fa01 ffff88000b12baf0 ffffffff=
810bc84b
[   11.843344] Call Trace:
[   11.843344]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.843344]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.843344]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.843344]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.843344]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.843344]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.843344]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.843344]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.843344]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.843344]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.843344]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.843344]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.843344]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.843344]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.843344]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.843344]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.843344]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.843344]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.843344]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.843344]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.843344]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.843344]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.843344]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.843344]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.843344] ---[ end trace cfeb07101f6fbf19 ]---
[   11.874569] ------------[ cut here ]------------
[   11.875368] WARNING: CPU: 0 PID: 153 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.876676] CPU: 0 PID: 153 Comm: run-parts Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[   11.876676] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.876676]  0000000000000000 ffff88000b1139c0 ffffffff81a23b9d ffff8800=
0b1139f8
[   11.876676]  ffffffff810bc765 ffffffff8111fac8 0000000000002000 ffff8800=
1200fa50
[   11.876676]  0000000000000001 ffff88001200fa01 ffff88000b113a08 ffffffff=
810bc84b
[   11.876676] Call Trace:
[   11.876676]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.876676]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.876676]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.876676]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.876676]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.876676]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.876676]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.876676]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.876676]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.876676]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.876676]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.876676]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.876676]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.876676]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.876676]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.876676]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.876676]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.876676]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.876676]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.876676]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.876676]  [<ffffffff811dd4bd>] load_script+0x1e6/0x208
[   11.876676]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.876676]  [<ffffffff810f78bf>] ? do_raw_read_unlock+0x2b/0x44
[   11.876676]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.876676]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.876676]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.876676]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.876676]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.876676] ---[ end trace cfeb07101f6fbf1a ]---
[   11.916335] ------------[ cut here ]------------
[   11.917127] WARNING: CPU: 0 PID: 153 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.918794] CPU: 0 PID: 153 Comm: run-parts Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[   11.919619] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.919619]  0000000000000000 ffff88000b1139c0 ffffffff81a23b9d ffff8800=
0b1139f8
[   11.919619]  ffffffff810bc765 ffffffff8111fac8 0000000000006000 ffff8800=
1200fa50
[   11.919619]  0000000000000001 ffff88001200fa01 ffff88000b113a08 ffffffff=
810bc84b
[   11.919619] Call Trace:
[   11.919619]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.919619]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.919619]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.919619]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.919619]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.919619]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.919619]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.919619]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.919619]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.919619]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.919619]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.919619]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.919619]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.919619]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.919619]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.919619]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.919619]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.919619]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.919619]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.919619]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.919619]  [<ffffffff811dd4bd>] load_script+0x1e6/0x208
[   11.919619]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.919619]  [<ffffffff810f78bf>] ? do_raw_read_unlock+0x2b/0x44
[   11.919619]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.919619]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.919619]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.919619]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.919619]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.919619] ---[ end trace cfeb07101f6fbf1b ]---
[   11.953576] ------------[ cut here ]------------
[   11.954372] WARNING: CPU: 0 PID: 152 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.956063] CPU: 0 PID: 152 Comm: rm Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.956677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.956677]  0000000000000000 ffff88000b12bc48 ffffffff81a23b9d ffff8800=
0b12bc80
[   11.956677]  ffffffff810bc765 ffffffff8111fac8 0000000000017000 ffff8800=
1200fa50
[   11.956677]  0000000000000001 ffff88001200fa01 ffff88000b12bc90 ffffffff=
810bc84b
[   11.956677] Call Trace:
[   11.956677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.956677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.956677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.956677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.956677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.956677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.956677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.956677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.956677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.956677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.956677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.956677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.956677]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.956677]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.956677]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   11.956677]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   11.956677]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   11.956677]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   11.956677]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   11.956677] ---[ end trace cfeb07101f6fbf1c ]---
[   11.982610] ------------[ cut here ]------------
[   11.983405] WARNING: CPU: 0 PID: 154 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   11.984861] CPU: 0 PID: 154 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   11.984861] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   11.984861]  0000000000000000 ffff88000b11faa8 ffffffff81a23b9d ffff8800=
0b11fae0
[   11.984861]  ffffffff810bc765 ffffffff8111fac8 0000000000012000 ffff8800=
1200fa50
[   11.984861]  0000000000000001 ffff88001200fa01 ffff88000b11faf0 ffffffff=
810bc84b
[   11.984861] Call Trace:
[   11.984861]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   11.984861]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   11.984861]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   11.984861]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   11.984861]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   11.984861]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   11.984861]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   11.984861]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   11.984861]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   11.984861]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   11.984861]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   11.984861]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   11.984861]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   11.984861]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   11.984861]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   11.984861]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   11.984861]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   11.984861]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   11.984861]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   11.984861]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   11.984861]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   11.984861]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   11.984861]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   11.984861]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   11.984861] ---[ end trace cfeb07101f6fbf1d ]---
[   12.018721] ------------[ cut here ]------------
[   12.019529] WARNING: CPU: 0 PID: 153 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.020010] CPU: 0 PID: 153 Comm: 00-header Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[   12.020010] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.020010]  0000000000000000 ffff88000b113c50 ffffffff81a23b9d ffff8800=
0b113c88
[   12.020010]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.020010]  0000000000000001 ffff88001200fa01 ffff88000b113c98 ffffffff=
810bc84b
[   12.020010] Call Trace:
[   12.020010]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.020010]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.020010]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.020010]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.020010]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.020010]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.020010]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.020010]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.020010]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.020010]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.020010]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.020010]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.020010]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   12.020010]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   12.020010]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   12.020010]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   12.020010]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   12.020010]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.020010] ---[ end trace cfeb07101f6fbf1e ]---
[   12.047533] ------------[ cut here ]------------
[   12.048337] WARNING: CPU: 0 PID: 154 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.050010] CPU: 0 PID: 154 Comm: initctl Tainted: G        W     3.16.0=
-rc1-00238-gddc5bfe #1
[   12.050010] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.050010]  0000000000000000 ffff88000b11fc48 ffffffff81a23b9d ffff8800=
0b11fc80
[   12.050010]  ffffffff810bc765 ffffffff8111fac8 0000000000029000 ffff8800=
1200fa50
[   12.050010]  0000000000000001 ffff88001200fa01 ffff88000b11fc90 ffffffff=
810bc84b
[   12.050010] Call Trace:
[   12.050010]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.050010]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.050010]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.050010]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.050010]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.050010]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.050010]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.050010]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.050010]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.050010]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.050010]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.050010]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.050010]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.050010]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.050010]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.050010]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   12.050010]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.050010]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.050010]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.050010] ---[ end trace cfeb07101f6fbf1f ]---
[   12.081485] ------------[ cut here ]------------
[   12.082289] WARNING: CPU: 0 PID: 153 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.083989] CPU: 0 PID: 153 Comm: 00-header Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[   12.084382] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.084382]  0000000000000000 ffff88000b113c50 ffffffff81a23b9d ffff8800=
0b113c88
[   12.084382]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.084382]  0000000000000001 ffff88001200fa01 ffff88000b113c98 ffffffff=
810bc84b
[   12.084382] Call Trace:
[   12.084382]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.084382]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.084382]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.084382]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.084382]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.084382]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.084382]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.084382]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.084382]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.084382]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.084382]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.084382]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.084382]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   12.084382]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   12.084382]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   12.084382]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   12.084382]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   12.084382]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.084382] ---[ end trace cfeb07101f6fbf20 ]---
[   12.110100] ------------[ cut here ]------------
[   12.110911] WARNING: CPU: 0 PID: 155 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.112592] CPU: 0 PID: 155 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   12.113354] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.113354]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[   12.113354]  ffffffff810bc765 ffffffff8111fac8 0000000000012000 ffff8800=
1200fa50
[   12.113354]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[   12.113354] Call Trace:
[   12.113354]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.113354]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.113354]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.113354]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.113354]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.113354]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.113354]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.113354]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.113354]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.113354]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.113354]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.113354]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.113354]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.113354]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.113354]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   12.113354]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   12.113354]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   12.113354]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   12.113354]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   12.113354]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   12.113354]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   12.113354]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   12.113354]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   12.113354]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   12.113354] ---[ end trace cfeb07101f6fbf21 ]---
[   12.145303] ------------[ cut here ]------------
[   12.146115] WARNING: CPU: 0 PID: 156 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.146677] CPU: 0 PID: 156 Comm: 00-header Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[   12.146677] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.146677]  0000000000000000 ffff88000b11faa8 ffffffff81a23b9d ffff8800=
0b11fae0
[   12.146677]  ffffffff810bc765 ffffffff8111fac8 0000000000017000 ffff8800=
1200fa50
[   12.146677]  0000000000000001 ffff88001200fa01 ffff88000b11faf0 ffffffff=
810bc84b
[   12.146677] Call Trace:
[   12.146677]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.146677]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.146677]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.146677]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.146677]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.146677]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.146677]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.146677]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.146677]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.146677]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.146677]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.146677]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.146677]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.146677]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.146677]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   12.146677]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   12.146677]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   12.146677]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   12.146677]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   12.146677]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   12.146677]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   12.146677]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   12.146677]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   12.146677]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   12.146677] ---[ end trace cfeb07101f6fbf22 ]---
[   12.182097] ------------[ cut here ]------------
[   12.182915] WARNING: CPU: 0 PID: 157 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.183344] CPU: 0 PID: 157 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[   12.183344] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.183344]  0000000000000000 ffff88000b0e3aa8 ffffffff81a23b9d ffff8800=
0b0e3ae0
[   12.183344]  ffffffff810bc765 ffffffff8111fac8 000000000000e000 ffff8800=
1200fa50
[   12.183344]  0000000000000001 ffff88001200fa01 ffff88000b0e3af0 ffffffff=
810bc84b
[   12.183344] Call Trace:
[   12.183344]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.183344]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.183344]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.183344]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.183344]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.183344]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.183344]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.183344]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.183344]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.183344]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.183344]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.183344]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.183344]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.183344]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.183344]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   12.183344]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   12.183344]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   12.183344]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   12.183344]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   12.183344]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   12.183344]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   12.183344]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   12.183344]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   12.183344]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   12.183344] ---[ end trace cfeb07101f6fbf23 ]---
[   12.215972] ------------[ cut here ]------------
[   12.216782] WARNING: CPU: 0 PID: 155 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.218330] CPU: 0 PID: 155 Comm: stop Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   12.218330] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.218330]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[   12.218330]  ffffffff810bc765 ffffffff8111fac8 0000000000020000 ffff8800=
1200fa50
[   12.218330]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[   12.218330] Call Trace:
[   12.218330]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.218330]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.218330]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.218330]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.218330]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.218330]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.218330]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.218330]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.218330]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.218330]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.218330]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.218330]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.218330]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.218330]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.218330]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.218330]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   12.218330]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.218330]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.218330]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.218330] ---[ end trace cfeb07101f6fbf24 ]---
[   12.249481] ------------[ cut here ]------------
[   12.250264] WARNING: CPU: 0 PID: 155 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.251941] CPU: 0 PID: 155 Comm: stop Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   12.252720] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.252720]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[   12.252720]  ffffffff810bc765 ffffffff8111fac8 000000000000c000 ffff8800=
1200fa50
[   12.252720]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[   12.252720] Call Trace:
[   12.252720]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.252720]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.252720]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.252720]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.252720]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.252720]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.252720]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.252720]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.252720]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.252720]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.252720]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.252720]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.252720]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.252720]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.252720]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.252720]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   12.252720]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.252720]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.252720]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.252720] ---[ end trace cfeb07101f6fbf25 ]---
[   12.278418] ------------[ cut here ]------------
[   12.279218] WARNING: CPU: 0 PID: 156 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.280859] CPU: 0 PID: 156 Comm: uname Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.280859] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.280859]  0000000000000000 ffff88000b11fc50 ffffffff81a23b9d ffff8800=
0b11fc88
[   12.280859]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.280859]  0000000000000001 ffff88001200fa01 ffff88000b11fc98 ffffffff=
810bc84b
[   12.280859] Call Trace:
[   12.280859]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.280859]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.280859]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.280859]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.280859]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.280859]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.280859]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.280859]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.280859]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.280859]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.280859]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.280859]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.280859]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   12.280859]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   12.280859]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   12.280859]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   12.280859]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   12.280859]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.280859] ---[ end trace cfeb07101f6fbf26 ]---
[   12.307358] ------------[ cut here ]------------
[   12.308159] WARNING: CPU: 0 PID: 157 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.309859] CPU: 0 PID: 157 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.310011] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.310011]  0000000000000000 ffff88000b0e3c50 ffffffff81a23b9d ffff8800=
0b0e3c88
[   12.310011]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.310011]  0000000000000001 ffff88001200fa01 ffff88000b0e3c98 ffffffff=
810bc84b
[   12.310011] Call Trace:
[   12.310011]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.310011]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.310011]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.310011]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.310011]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.310011]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.310011]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.310011]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.310011]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.310011]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.310011]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.310011]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.310011]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   12.310011]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   12.310011]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   12.310011]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   12.310011]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   12.310011]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.310011] ---[ end trace cfeb07101f6fbf27 ]---
[   12.335201] ------------[ cut here ]------------
[   12.336004] WARNING: CPU: 0 PID: 156 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.337718] CPU: 0 PID: 156 Comm: uname Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.338313] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.338313]  0000000000000000 ffff88000b11fc48 ffffffff81a23b9d ffff8800=
0b11fc80
[   12.338313]  ffffffff810bc765 ffffffff8111fac8 0000000000002000 ffff8800=
1200fa50
[   12.338313]  0000000000000001 ffff88001200fa01 ffff88000b11fc90 ffffffff=
810bc84b
[   12.338313] Call Trace:
[   12.338313]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.338313]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.338313]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.338313]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.338313]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.338313]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.338313]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.338313]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.338313]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.338313]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.338313]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.338313]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.338313]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.338313]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.338313]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.338313]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   12.338313]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.338313]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.338313]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.338313] ---[ end trace cfeb07101f6fbf28 ]---
[   12.363770] ------------[ cut here ]------------
[   12.364545] WARNING: CPU: 0 PID: 156 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.366287] CPU: 0 PID: 156 Comm: uname Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.367010] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.367010]  0000000000000000 ffff88000b11fc48 ffffffff81a23b9d ffff8800=
0b11fc80
[   12.367010]  ffffffff810bc765 ffffffff8111fac8 0000000000015000 ffff8800=
1200fa50
[   12.367010]  0000000000000001 ffff88001200fa01 ffff88000b11fc90 ffffffff=
810bc84b
[   12.367010] Call Trace:
[   12.367010]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.367010]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.367010]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.367010]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.367010]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.367010]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.367010]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.367010]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.367010]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.367010]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.367010]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.367010]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.367010]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.367010]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.367010]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.367010]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   12.367010]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.367010]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.367010]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.367010] ---[ end trace cfeb07101f6fbf29 ]---
[   12.392857] ------------[ cut here ]------------
[   12.393646] WARNING: CPU: 0 PID: 157 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.395380] CPU: 0 PID: 157 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.395417] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.395417]  0000000000000000 ffff88000b0e3c50 ffffffff81a23b9d ffff8800=
0b0e3c88
[   12.395417]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.395417]  0000000000000001 ffff88001200fa01 ffff88000b0e3c98 ffffffff=
810bc84b
[   12.395417] Call Trace:
[   12.395417]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.395417]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.395417]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.395417]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.395417]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.395417]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.395417]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.395417]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.395417]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.395417]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.395417]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.395417]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.395417]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   12.395417]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   12.395417]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   12.395417]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   12.395417]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   12.395417]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.395417] ---[ end trace cfeb07101f6fbf2a ]---
[   12.427038] ------------[ cut here ]------------
[   12.427891] WARNING: CPU: 0 PID: 142 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.429612] CPU: 0 PID: 142 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   12.430009] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.430009]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[   12.430009]  ffffffff810bc765 ffffffff8111fac8 0000000000021000 ffff8800=
1200fa50
[   12.430009]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[   12.430009] Call Trace:
[   12.430009]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.430009]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.430009]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.430009]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.430009]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.430009]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.430009]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.430009]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.430009]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.430009]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.430009]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.430009]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.430009]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.430009]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.430009]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.430009]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   12.430009]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.430009]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.430009]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.430009] ---[ end trace cfeb07101f6fbf2b ]---
[   12.456142] ------------[ cut here ]------------
[   12.456946] WARNING: CPU: 0 PID: 142 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.458657] CPU: 0 PID: 142 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   12.459348] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.459348]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[   12.459348]  ffffffff810bc765 ffffffff8111fac8 000000000001e000 ffff8800=
1200fa50
[   12.459348]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[   12.459348] Call Trace:
[   12.459348]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.459348]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.459348]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.459348]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.459348]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.459348]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.459348]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.459348]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.459348]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.459348]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.459348]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.459348]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.459348]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.459348]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.459348]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.459348]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   12.459348]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.459348]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.459348]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.459348] ---[ end trace cfeb07101f6fbf2c ]---
[   12.484522] ------------[ cut here ]------------
[   12.485332] WARNING: CPU: 0 PID: 157 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.487017] CPU: 0 PID: 157 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.487554] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.487554]  0000000000000000 ffff88000b0e3c50 ffffffff81a23b9d ffff8800=
0b0e3c88
[   12.487554]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.487554]  0000000000000001 ffff88001200fa01 ffff88000b0e3c98 ffffffff=
810bc84b
[   12.487554] Call Trace:
[   12.487554]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.487554]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.487554]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.487554]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.487554]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.487554]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.487554]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.487554]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.487554]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.487554]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.487554]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.487554]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.487554]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   12.487554]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   12.487554]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   12.487554]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   12.487554]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   12.487554]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.487554] ---[ end trace cfeb07101f6fbf2d ]---
[   12.512655] ------------[ cut here ]------------
[   12.513472] WARNING: CPU: 0 PID: 158 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.514826] CPU: 0 PID: 158 Comm: 00-header Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[   12.514826] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.514826]  0000000000000000 ffff88000b0a7aa8 ffffffff81a23b9d ffff8800=
0b0a7ae0
[   12.514826]  ffffffff810bc765 ffffffff8111fac8 0000000000017000 ffff8800=
1200fa50
[   12.514826]  0000000000000001 ffff88001200fa01 ffff88000b0a7af0 ffffffff=
810bc84b
[   12.514826] Call Trace:
[   12.514826]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.514826]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.514826]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.514826]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.514826]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.514826]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.514826]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.514826]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.514826]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.514826]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.514826]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.514826]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.514826]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.514826]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.514826]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   12.514826]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   12.514826]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   12.514826]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   12.514826]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   12.514826]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   12.514826]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   12.514826]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   12.514826]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   12.514826]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   12.514826] ---[ end trace cfeb07101f6fbf2e ]---
[   12.545823] ------------[ cut here ]------------
[   12.546587] WARNING: CPU: 0 PID: 157 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.548281] CPU: 0 PID: 157 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.548281] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.548281]  0000000000000000 ffff88000b0e39e0 ffffffff81a23b9d ffff8800=
0b0e3a18
[   12.548281]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.548281]  0000000000000001 ffff88001200fa01 ffff88000b0e3a28 ffffffff=
810bc84b
[   12.548281] Call Trace:
[   12.548281]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.548281]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.548281]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.548281]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.548281]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.548281]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.548281]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.548281]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.548281]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.548281]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[   12.548281]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[   12.548281]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[   12.548281]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[   12.548281]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[   12.548281]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[   12.548281]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[   12.548281]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[   12.548281]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[   12.548281]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[   12.548281]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[   12.548281]  [<ffffffff811acaca>] dput+0x244/0x316
[   12.548281]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[   12.548281]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[   12.548281]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[   12.548281]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   12.548281]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[   12.548281]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   12.548281]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[   12.548281]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.548281] ---[ end trace cfeb07101f6fbf2f ]---
[   12.589760] ------------[ cut here ]------------
[   12.590521] WARNING: CPU: 0 PID: 158 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.592181] CPU: 0 PID: 158 Comm: uname Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.592251] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.592251]  0000000000000000 ffff88000b0a7c50 ffffffff81a23b9d ffff8800=
0b0a7c88
[   12.592251]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.592251]  0000000000000001 ffff88001200fa01 ffff88000b0a7c98 ffffffff=
810bc84b
[   12.592251] Call Trace:
[   12.592251]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.592251]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.592251]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.592251]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.592251]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.592251]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.592251]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.592251]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.592251]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.592251]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.592251]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.592251]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.592251]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   12.592251]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   12.592251]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   12.592251]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   12.592251]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   12.592251]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.592251] ---[ end trace cfeb07101f6fbf30 ]---
[   12.617154] ------------[ cut here ]------------
[   12.617948] WARNING: CPU: 0 PID: 157 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.619579] CPU: 0 PID: 157 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.620178] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.620178]  0000000000000000 ffff88000b0e3c48 ffffffff81a23b9d ffff8800=
0b0e3c80
[   12.620178]  ffffffff810bc765 ffffffff8111fac8 000000000002a000 ffff8800=
1200fa50
[   12.620178]  0000000000000001 ffff88001200fa01 ffff88000b0e3c90 ffffffff=
810bc84b
[   12.620178] Call Trace:
[   12.620178]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.620178]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.620178]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.620178]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.620178]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.620178]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.620178]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.620178]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.620178]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.620178]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.620178]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.620178]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.620178]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.620178]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.620178]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.620178]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[   12.620178]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   12.620178]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.620178]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.620178]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.620178] ---[ end trace cfeb07101f6fbf31 ]---
[   12.646041] ------------[ cut here ]------------
[   12.646828] WARNING: CPU: 0 PID: 158 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.648495] CPU: 0 PID: 158 Comm: uname Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.649043] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.649043]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[   12.649043]  ffffffff810bc765 ffffffff8111fac8 0000000000002000 ffff8800=
1200fa50
[   12.649043]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[   12.649043] Call Trace:
[   12.649043]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.649043]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.649043]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.649043]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.649043]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.649043]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.649043]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.649043]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.649043]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.649043]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.649043]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.649043]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.649043]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.649043]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.649043]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.649043]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   12.649043]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.649043]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.649043]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.649043] ---[ end trace cfeb07101f6fbf32 ]---
[   12.673718] ------------[ cut here ]------------
[   12.674466] WARNING: CPU: 0 PID: 158 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.676133] CPU: 0 PID: 158 Comm: uname Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.676985] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.676985]  0000000000000000 ffff88000b0a7c48 ffffffff81a23b9d ffff8800=
0b0a7c80
[   12.676985]  ffffffff810bc765 ffffffff8111fac8 0000000000014000 ffff8800=
1200fa50
[   12.676985]  0000000000000001 ffff88001200fa01 ffff88000b0a7c90 ffffffff=
810bc84b
[   12.676985] Call Trace:
[   12.676985]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.676985]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.676985]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.676985]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.676985]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.676985]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.676985]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.676985]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.676985]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.676985]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.676985]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.676985]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.676985]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.676985]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.676985]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.676985]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   12.676985]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.676985]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.676985]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.676985] ---[ end trace cfeb07101f6fbf33 ]---
[   12.703129] ------------[ cut here ]------------
[   12.703949] WARNING: CPU: 0 PID: 159 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.704598] CPU: 0 PID: 159 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[   12.704598] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.704598]  0000000000000000 ffff88000b0e3aa8 ffffffff81a23b9d ffff8800=
0b0e3ae0
[   12.704598]  ffffffff810bc765 ffffffff8111fac8 000000000000e000 ffff8800=
1200fa50
[   12.704598]  0000000000000001 ffff88001200fa01 ffff88000b0e3af0 ffffffff=
810bc84b
[   12.704598] Call Trace:
[   12.704598]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.704598]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.704598]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.704598]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.704598]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.704598]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.704598]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.704598]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.704598]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.704598]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.704598]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.704598]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.704598]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.704598]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.704598]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   12.704598]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   12.704598]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   12.704598]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   12.704598]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   12.704598]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   12.704598]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   12.704598]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   12.704598]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   12.704598]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   12.704598] ---[ end trace cfeb07101f6fbf34 ]---
[   12.742619] ------------[ cut here ]------------
[   12.743427] WARNING: CPU: 0 PID: 159 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.744424] CPU: 0 PID: 159 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.744424] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.744424]  0000000000000000 ffff88000b0e3c50 ffffffff81a23b9d ffff8800=
0b0e3c88
[   12.744424]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.744424]  0000000000000001 ffff88001200fa01 ffff88000b0e3c98 ffffffff=
810bc84b
[   12.744424] Call Trace:
[   12.744424]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.744424]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.744424]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.744424]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.744424]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.744424]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.744424]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.744424]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.744424]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.744424]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.744424]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.744424]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.744424]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   12.744424]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   12.744424]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   12.744424]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   12.744424]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   12.744424]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.744424] ---[ end trace cfeb07101f6fbf35 ]---
[   12.770792] ------------[ cut here ]------------
[   12.771557] WARNING: CPU: 0 PID: 160 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.773241] CPU: 0 PID: 160 Comm: 00-header Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[   12.773356] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.773356]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[   12.773356]  ffffffff810bc765 ffffffff8111fac8 0000000000017000 ffff8800=
1200fa50
[   12.773356]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[   12.773356] Call Trace:
[   12.773356]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.773356]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.773356]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.773356]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.773356]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.773356]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.773356]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.773356]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.773356]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.773356]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.773356]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.773356]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.773356]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.773356]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.773356]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   12.773356]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   12.773356]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   12.773356]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   12.773356]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   12.773356]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   12.773356]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   12.773356]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   12.773356]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   12.773356]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   12.773356] ---[ end trace cfeb07101f6fbf36 ]---
[   12.803855] ------------[ cut here ]------------
[   12.804627] WARNING: CPU: 0 PID: 159 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.806330] CPU: 0 PID: 159 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.806673] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.806673]  0000000000000000 ffff88000b0e3c50 ffffffff81a23b9d ffff8800=
0b0e3c88
[   12.806673]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.806673]  0000000000000001 ffff88001200fa01 ffff88000b0e3c98 ffffffff=
810bc84b
[   12.806673] Call Trace:
[   12.806673]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.806673]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.806673]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.806673]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.806673]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.806673]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.806673]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.806673]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.806673]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.806673]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.806673]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.806673]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.806673]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   12.806673]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   12.806673]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   12.806673]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   12.806673]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   12.806673]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.806673] ---[ end trace cfeb07101f6fbf37 ]---
[   12.831651] ------------[ cut here ]------------
[   12.832434] WARNING: CPU: 0 PID: 160 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.834134] CPU: 0 PID: 160 Comm: uname Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.834234] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.834234]  0000000000000000 ffff88000b097c50 ffffffff81a23b9d ffff8800=
0b097c88
[   12.834234]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.834234]  0000000000000001 ffff88001200fa01 ffff88000b097c98 ffffffff=
810bc84b
[   12.834234] Call Trace:
[   12.834234]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.834234]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.834234]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.834234]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.834234]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.834234]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.834234]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.834234]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.834234]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.834234]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.834234]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.834234]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.834234]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   12.834234]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   12.834234]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   12.834234]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   12.834234]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   12.834234]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.834234] ---[ end trace cfeb07101f6fbf38 ]---
[   12.858803] ------------[ cut here ]------------
[   12.859562] WARNING: CPU: 0 PID: 159 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.861225] CPU: 0 PID: 159 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.861960] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.861960]  0000000000000000 ffff88000b0e3c50 ffffffff81a23b9d ffff8800=
0b0e3c88
[   12.861960]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.861960]  0000000000000001 ffff88001200fa01 ffff88000b0e3c98 ffffffff=
810bc84b
[   12.861960] Call Trace:
[   12.861960]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.861960]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.861960]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.861960]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.861960]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.861960]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.861960]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.861960]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.861960]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.861960]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.861960]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.861960]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.861960]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   12.861960]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   12.861960]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   12.861960]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   12.861960]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   12.861960]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.861960] ---[ end trace cfeb07101f6fbf39 ]---
[   12.885849] ------------[ cut here ]------------
[   12.886602] WARNING: CPU: 0 PID: 160 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.888313] CPU: 0 PID: 160 Comm: uname Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.889016] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.889016]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[   12.889016]  ffffffff810bc765 ffffffff8111fac8 0000000000002000 ffff8800=
1200fa50
[   12.889016]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[   12.889016] Call Trace:
[   12.889016]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.889016]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.889016]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.889016]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.889016]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.889016]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.889016]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.889016]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.889016]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.889016]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.889016]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.889016]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.889016]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.889016]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.889016]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.889016]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   12.889016]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.889016]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.889016]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.889016] ---[ end trace cfeb07101f6fbf3a ]---
[   12.919282] ------------[ cut here ]------------
[   12.920059] WARNING: CPU: 0 PID: 160 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.921671] CPU: 0 PID: 160 Comm: uname Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.922568] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.922568]  0000000000000000 ffff88000b097c48 ffffffff81a23b9d ffff8800=
0b097c80
[   12.922568]  ffffffff810bc765 ffffffff8111fac8 0000000000015000 ffff8800=
1200fa50
[   12.922568]  0000000000000001 ffff88001200fa01 ffff88000b097c90 ffffffff=
810bc84b
[   12.922568] Call Trace:
[   12.922568]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.922568]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.922568]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.922568]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.922568]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.922568]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.922568]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.922568]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.922568]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.922568]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.922568]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.922568]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.922568]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.922568]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.922568]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.922568]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   12.922568]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.922568]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.922568]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.922568] ---[ end trace cfeb07101f6fbf3b ]---
[   12.947031] ------------[ cut here ]------------
[   12.947830] WARNING: CPU: 0 PID: 159 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.949467] CPU: 0 PID: 159 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.950226] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.950226]  0000000000000000 ffff88000b0e39e0 ffffffff81a23b9d ffff8800=
0b0e3a18
[   12.950226]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   12.950226]  0000000000000001 ffff88001200fa01 ffff88000b0e3a28 ffffffff=
810bc84b
[   12.950226] Call Trace:
[   12.950226]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.950226]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.950226]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.950226]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.950226]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.950226]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.950226]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.950226]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.950226]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.950226]  [<ffffffff8115789e>] __pagevec_release+0x27/0x31
[   12.950226]  [<ffffffff8115796d>] pagevec_release+0xe/0x10
[   12.950226]  [<ffffffff81157e7f>] truncate_inode_pages_range+0x168/0x46c
[   12.950226]  [<ffffffff810f33e4>] ? mark_held_locks+0x50/0x6e
[   12.950226]  [<ffffffff81a309f1>] ? _raw_spin_unlock_irq+0x2c/0x3b
[   12.950226]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[   12.950226]  [<ffffffff81158195>] truncate_inode_pages+0x12/0x14
[   12.950226]  [<ffffffff811581db>] truncate_inode_pages_final+0x44/0x49
[   12.950226]  [<ffffffff811aff3b>] evict+0xef/0x1a1
[   12.950226]  [<ffffffff811b0b55>] iput+0x198/0x1e4
[   12.950226]  [<ffffffff811ac4b7>] __dentry_kill+0x121/0x1be
[   12.950226]  [<ffffffff811acaca>] dput+0x244/0x316
[   12.950226]  [<ffffffff811a6f9a>] SYSC_renameat2+0x2cc/0x3ad
[   12.950226]  [<ffffffff8118a071>] ? kmem_cache_free+0x212/0x2ba
[   12.950226]  [<ffffffff810b9cba>] ? __mmdrop+0xd9/0xe4
[   12.950226]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   12.950226]  [<ffffffff810f3545>] ? trace_hardirqs_on_caller+0x143/0x19d
[   12.950226]  [<ffffffff814a673b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   12.950226]  [<ffffffff811a70bc>] SyS_rename+0x1e/0x20
[   12.950226]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.950226] ---[ end trace cfeb07101f6fbf3c ]---
[   12.984307] ------------[ cut here ]------------
[   12.985107] WARNING: CPU: 0 PID: 159 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   12.986779] CPU: 0 PID: 159 Comm: mount Tainted: G        W     3.16.0-r=
c1-00238-gddc5bfe #1
[   12.987386] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   12.987386]  0000000000000000 ffff88000b0e3c48 ffffffff81a23b9d ffff8800=
0b0e3c80
[   12.987386]  ffffffff810bc765 ffffffff8111fac8 000000000002a000 ffff8800=
1200fa50
[   12.987386]  0000000000000001 ffff88001200fa01 ffff88000b0e3c90 ffffffff=
810bc84b
[   12.987386] Call Trace:
[   12.987386]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   12.987386]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   12.987386]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   12.987386]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   12.987386]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   12.987386]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   12.987386]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   12.987386]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   12.987386]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   12.987386]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   12.987386]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   12.987386]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   12.987386]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   12.987386]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   12.987386]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   12.987386]  [<ffffffff810f35ac>] ? trace_hardirqs_on+0xd/0xf
[   12.987386]  [<ffffffff81a31593>] ? sysret_check+0x22/0x5c
[   12.987386]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   12.987386]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   12.987386]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   12.987386] ---[ end trace cfeb07101f6fbf3d ]---
[   13.013457] ------------[ cut here ]------------
[   13.014262] WARNING: CPU: 0 PID: 153 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.015950] CPU: 0 PID: 153 Comm: 00-header Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[   13.016676] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.016676]  0000000000000000 ffff88000b113c48 ffffffff81a23b9d ffff8800=
0b113c80
[   13.016676]  ffffffff810bc765 ffffffff8111fac8 0000000000022000 ffff8800=
1200fa50
[   13.016676]  0000000000000001 ffff88001200fa01 ffff88000b113c90 ffffffff=
810bc84b
[   13.016676] Call Trace:
[   13.016676]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.016676]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.016676]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.016676]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.016676]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.016676]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.016676]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.016676]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.016676]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.016676]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.016676]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.016676]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.016676]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.016676]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.016676]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   13.016676]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   13.016676]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   13.016676]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   13.016676]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.016676] ---[ end trace cfeb07101f6fbf3e ]---
[   13.041311] ------------[ cut here ]------------
[   13.042081] WARNING: CPU: 0 PID: 153 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.043759] CPU: 0 PID: 153 Comm: 00-header Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[   13.044537] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.044537]  0000000000000000 ffff88000b113c48 ffffffff81a23b9d ffff8800=
0b113c80
[   13.044537]  ffffffff810bc765 ffffffff8111fac8 000000000001e000 ffff8800=
1200fa50
[   13.044537]  0000000000000001 ffff88001200fa01 ffff88000b113c90 ffffffff=
810bc84b
[   13.044537] Call Trace:
[   13.044537]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.044537]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.044537]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.044537]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.044537]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.044537]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.044537]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.044537]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.044537]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.044537]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.044537]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.044537]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.044537]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.044537]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.044537]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   13.044537]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   13.044537]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   13.044537]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   13.044537]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.044537] ---[ end trace cfeb07101f6fbf3f ]---
[   13.077054] ------------[ cut here ]------------
[   13.077881] WARNING: CPU: 0 PID: 161 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.079523] CPU: 0 PID: 161 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   13.080009] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.080009]  0000000000000000 ffff88000b0e3aa8 ffffffff81a23b9d ffff8800=
0b0e3ae0
[   13.080009]  ffffffff810bc765 ffffffff8111fac8 0000000000010000 ffff8800=
1200fa50
[   13.080009]  0000000000000001 ffff88001200fa01 ffff88000b0e3af0 ffffffff=
810bc84b
[   13.080009] Call Trace:
[   13.080009]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.080009]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.080009]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.080009]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.080009]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.080009]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.080009]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.080009]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.080009]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.080009]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.080009]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.080009]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.080009]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.080009]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.080009]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.080009]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.080009]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.080009]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.080009]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.080009]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.080009]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.080009]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.080009]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.080009]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.080009] ---[ end trace cfeb07101f6fbf40 ]---
[   13.109375] ------------[ cut here ]------------
[   13.110149] WARNING: CPU: 0 PID: 161 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.111774] CPU: 0 PID: 161 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   13.112640] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.112640]  0000000000000000 ffff88000b0e3aa8 ffffffff81a23b9d ffff8800=
0b0e3ae0
[   13.112640]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[   13.112640]  0000000000000001 ffff88001200fa01 ffff88000b0e3af0 ffffffff=
810bc84b
[   13.112640] Call Trace:
[   13.112640]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.112640]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.112640]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.112640]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.112640]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.112640]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.112640]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.112640]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.112640]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.112640]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.112640]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.112640]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.112640]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.112640]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.112640]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.112640]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.112640]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.112640]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.112640]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.112640]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.112640]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.112640]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.112640]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.112640]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.112640] ---[ end trace cfeb07101f6fbf41 ]---
[   13.141905] 00-header (153) used greatest stack depth: 13088 bytes left
[   13.143417] ------------[ cut here ]------------
[   13.144220] WARNING: CPU: 0 PID: 162 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.145872] CPU: 0 PID: 162 Comm: run-parts Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[   13.146676] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.146676]  0000000000000000 ffff88000b0879c0 ffffffff81a23b9d ffff8800=
0b0879f8
[   13.146676]  ffffffff810bc765 ffffffff8111fac8 0000000000002000 ffff8800=
1200fa50
[   13.146676]  0000000000000001 ffff88001200fa01 ffff88000b087a08 ffffffff=
810bc84b
[   13.146676] Call Trace:
[   13.146676]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.146676]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.146676]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.146676]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.146676]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.146676]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.146676]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.146676]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.146676]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.146676]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.146676]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.146676]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.146676]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.146676]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.146676]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.146676]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.146676]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.146676]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.146676]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.146676]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.146676]  [<ffffffff811dd4bd>] load_script+0x1e6/0x208
[   13.146676]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.146676]  [<ffffffff810f78bf>] ? do_raw_read_unlock+0x2b/0x44
[   13.146676]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.146676]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.146676]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.146676]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.146676]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.146676] ---[ end trace cfeb07101f6fbf42 ]---
[   13.179335] ------------[ cut here ]------------
[   13.180113] WARNING: CPU: 0 PID: 162 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.181743] CPU: 0 PID: 162 Comm: run-parts Tainted: G        W     3.16=
=2E0-rc1-00238-gddc5bfe #1
[   13.182623] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.182623]  0000000000000000 ffff88000b0879c0 ffffffff81a23b9d ffff8800=
0b0879f8
[   13.182623]  ffffffff810bc765 ffffffff8111fac8 0000000000006000 ffff8800=
1200fa50
[   13.182623]  0000000000000001 ffff88001200fa01 ffff88000b087a08 ffffffff=
810bc84b
[   13.182623] Call Trace:
[   13.182623]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.182623]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.182623]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.182623]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.182623]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.182623]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.182623]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.182623]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.182623]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.182623]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.182623]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.182623]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.182623]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.182623]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.182623]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.182623]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.182623]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.182623]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.182623]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.182623]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.182623]  [<ffffffff811dd4bd>] load_script+0x1e6/0x208
[   13.182623]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.182623]  [<ffffffff810f78bf>] ? do_raw_read_unlock+0x2b/0x44
[   13.182623]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.182623]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.182623]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.182623]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.182623]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.182623] ---[ end trace cfeb07101f6fbf43 ]---
[   13.222117] ------------[ cut here ]------------
[   13.222895] WARNING: CPU: 0 PID: 163 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.223711] CPU: 0 PID: 163 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   13.223711] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.223711]  0000000000000000 ffff88000b113aa8 ffffffff81a23b9d ffff8800=
0b113ae0
[   13.223711]  ffffffff810bc765 ffffffff8111fac8 0000000000010000 ffff8800=
1200fa50
[   13.223711]  0000000000000001 ffff88001200fa01 ffff88000b113af0 ffffffff=
810bc84b
[   13.223711] Call Trace:
[   13.223711]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.223711]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.223711]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.223711]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.223711]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.223711]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.223711]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.223711]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.223711]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.223711]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.223711]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.223711]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.223711]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.223711]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.223711]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.223711]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.223711]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.223711]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.223711]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.223711]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.223711]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.223711]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.223711]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.223711]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.223711] ---[ end trace cfeb07101f6fbf44 ]---
[   13.254345] ------------[ cut here ]------------
[   13.255131] WARNING: CPU: 0 PID: 163 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.256800] CPU: 0 PID: 163 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   13.257608] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.257608]  0000000000000000 ffff88000b113aa8 ffffffff81a23b9d ffff8800=
0b113ae0
[   13.257608]  ffffffff810bc765 ffffffff8111fac8 0000000000009000 ffff8800=
1200fa50
[   13.257608]  0000000000000001 ffff88001200fa01 ffff88000b113af0 ffffffff=
810bc84b
[   13.257608] Call Trace:
[   13.257608]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.257608]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.257608]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.257608]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.257608]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.257608]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.257608]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.257608]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.257608]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.257608]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.257608]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.257608]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.257608]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.257608]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.257608]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.257608]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.257608]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.257608]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.257608]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.257608]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.257608]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.257608]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.257608]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.257608]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.257608] ---[ end trace cfeb07101f6fbf45 ]---
[   13.287731] ------------[ cut here ]------------
[   13.288517] WARNING: CPU: 0 PID: 161 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.290008] CPU: 0 PID: 161 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   13.290008] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.290008]  0000000000000000 ffff88000b0e3c50 ffffffff81a23b9d ffff8800=
0b0e3c88
[   13.290008]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   13.290008]  0000000000000001 ffff88001200fa01 ffff88000b0e3c98 ffffffff=
810bc84b
[   13.290008] Call Trace:
[   13.290008]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.290008]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.290008]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.290008]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.290008]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.290008]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.290008]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.290008]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.290008]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.290008]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.290008]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.290008]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.290008]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   13.290008]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   13.290008]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   13.290008]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   13.290008]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   13.290008]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.290008] ---[ end trace cfeb07101f6fbf46 ]---
[   13.315058] ------------[ cut here ]------------
[   13.315860] WARNING: CPU: 0 PID: 161 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.317569] CPU: 0 PID: 161 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   13.318061] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.318061]  0000000000000000 ffff88000b0e3c50 ffffffff81a23b9d ffff8800=
0b0e3c88
[   13.318061]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   13.318061]  0000000000000001 ffff88001200fa01 ffff88000b0e3c98 ffffffff=
810bc84b
[   13.318061] Call Trace:
[   13.318061]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.318061]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.318061]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.318061]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.318061]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.318061]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.318061]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.318061]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.318061]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.318061]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.318061]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.318061]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.318061]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   13.318061]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   13.318061]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   13.318061]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   13.318061]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   13.318061]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.318061] ---[ end trace cfeb07101f6fbf47 ]---
[   13.343976] ------------[ cut here ]------------
[   13.344807] WARNING: CPU: 0 PID: 164 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.346506] CPU: 0 PID: 164 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   13.346678] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.346678]  0000000000000000 ffff88000b143c68 ffffffff81a23b9d ffff8800=
0b143ca0
[   13.346678]  ffffffff810bc765 ffffffff8111fac8 0000000000008000 ffff8800=
1200fa50
[   13.346678]  0000000000000001 ffff88001200fa01 ffff88000b143cb0 ffffffff=
810bc84b
[   13.346678] Call Trace:
[   13.346678]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.346678]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.346678]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.346678]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.346678]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.346678]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.346678]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.346678]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.346678]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.346678]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.346678]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.346678]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.346678]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   13.346678]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   13.346678]  [<ffffffff81175596>] SyS_brk+0xbb/0x163
[   13.346678]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.346678] ---[ end trace cfeb07101f6fbf48 ]---
[   13.369943] ------------[ cut here ]------------
[   13.370733] WARNING: CPU: 0 PID: 164 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.372403] CPU: 0 PID: 164 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   13.373216] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.373216]  0000000000000000 ffff88000b143c68 ffffffff81a23b9d ffff8800=
0b143ca0
[   13.373216]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   13.373216]  0000000000000001 ffff88001200fa01 ffff88000b143cb0 ffffffff=
810bc84b
[   13.373216] Call Trace:
[   13.373216]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.373216]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.373216]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.373216]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.373216]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.373216]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.373216]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.373216]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.373216]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.373216]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.373216]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.373216]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.373216]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   13.373216]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   13.373216]  [<ffffffff81175596>] SyS_brk+0xbb/0x163
[   13.373216]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.373216] ---[ end trace cfeb07101f6fbf49 ]---
[   13.403717] ------------[ cut here ]------------
[   13.404486] WARNING: CPU: 0 PID: 117 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.406160] CPU: 0 PID: 117 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[   13.406676] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.406676]  0000000000000000 ffff88000b093c48 ffffffff81a23b9d ffff8800=
0b093c80
[   13.406676]  ffffffff810bc765 ffffffff8111fac8 0000000000002000 ffff8800=
1200fa50
[   13.406676]  0000000000000001 ffff88001200fa01 ffff88000b093c90 ffffffff=
810bc84b
[   13.406676] Call Trace:
[   13.406676]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.406676]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.406676]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.406676]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.406676]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.406676]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.406676]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.406676]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.406676]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.406676]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.406676]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.406676]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.406676]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.406676]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.406676]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   13.406676]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   13.406676]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   13.406676]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   13.406676]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.406676] ---[ end trace cfeb07101f6fbf4a ]---
[   13.431497] ------------[ cut here ]------------
[   13.432273] WARNING: CPU: 0 PID: 117 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.433953] CPU: 0 PID: 117 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[   13.434778] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.434778]  0000000000000000 ffff88000b093c48 ffffffff81a23b9d ffff8800=
0b093c80
[   13.434778]  ffffffff810bc765 ffffffff8111fac8 000000000001f000 ffff8800=
1200fa50
[   13.434778]  0000000000000001 ffff88001200fa01 ffff88000b093c90 ffffffff=
810bc84b
[   13.434778] Call Trace:
[   13.434778]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.434778]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.434778]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.434778]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.434778]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.434778]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.434778]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.434778]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.434778]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.434778]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.434778]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.434778]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.434778]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.434778]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.434778]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   13.434778]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   13.434778]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   13.434778]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   13.434778]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.434778] ---[ end trace cfeb07101f6fbf4b ]---
[   13.459414] ------------[ cut here ]------------
[   13.460191] WARNING: CPU: 0 PID: 117 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.461827] CPU: 0 PID: 117 Comm: mountall Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[   13.462654] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.462654]  0000000000000000 ffff88000b093c48 ffffffff81a23b9d ffff8800=
0b093c80
[   13.462654]  ffffffff810bc765 ffffffff8111fac8 000000000002e000 ffff8800=
1200fa50
[   13.462654]  0000000000000001 ffff88001200fa01 ffff88000b093c90 ffffffff=
810bc84b
[   13.462654] Call Trace:
[   13.462654]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.462654]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.462654]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.462654]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.462654]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.462654]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.462654]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.462654]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.462654]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.462654]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.462654]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.462654]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.462654]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.462654]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.462654]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   13.462654]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   13.462654]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   13.462654]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   13.462654]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.462654] ---[ end trace cfeb07101f6fbf4c ]---
[   13.488032] ------------[ cut here ]------------
[   13.488820] WARNING: CPU: 0 PID: 166 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.490411] CPU: 0 PID: 166 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   13.490411] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.490411]  0000000000000000 ffff88000b11faa8 ffffffff81a23b9d ffff8800=
0b11fae0
[   13.490411]  ffffffff810bc765 ffffffff8111fac8 0000000000010000 ffff8800=
1200fa50
[   13.490411]  0000000000000001 ffff88001200fa01 ffff88000b11faf0 ffffffff=
810bc84b
[   13.490411] Call Trace:
[   13.490411]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.490411]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.490411]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.490411]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.490411]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.490411]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.490411]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.490411]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.490411]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.490411]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.490411]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.490411]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.490411]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.490411]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.490411]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.490411]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.490411]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.490411]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.490411]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.490411]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.490411]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.490411]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.490411]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.490411]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.490411] ---[ end trace cfeb07101f6fbf4d ]---
[   13.520403] ------------[ cut here ]------------
[   13.521171] WARNING: CPU: 0 PID: 166 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.522803] CPU: 0 PID: 166 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   13.523668] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.523668]  0000000000000000 ffff88000b11faa8 ffffffff81a23b9d ffff8800=
0b11fae0
[   13.523668]  ffffffff810bc765 ffffffff8111fac8 0000000000009000 ffff8800=
1200fa50
[   13.523668]  0000000000000001 ffff88001200fa01 ffff88000b11faf0 ffffffff=
810bc84b
[   13.523668] Call Trace:
[   13.523668]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.523668]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.523668]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.523668]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.523668]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.523668]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.523668]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.523668]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.523668]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.523668]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.523668]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.523668]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.523668]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.523668]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.523668]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.523668]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.523668]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.523668]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.523668]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.523668]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.523668]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.523668]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.523668]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.523668]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.523668] ---[ end trace cfeb07101f6fbf4e ]---
[   13.560382] ------------[ cut here ]------------
[   13.561206] WARNING: CPU: 0 PID: 162 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.562921] CPU: 0 PID: 162 Comm: 10-help-text Tainted: G        W     3=
=2E16.0-rc1-00238-gddc5bfe #1
[   13.563342] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.563342]  0000000000000000 ffff88000b087c50 ffffffff81a23b9d ffff8800=
0b087c88
[   13.563342]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   13.563342]  0000000000000001 ffff88001200fa01 ffff88000b087c98 ffffffff=
810bc84b
[   13.563342] Call Trace:
[   13.563342]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.563342]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.563342]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.563342]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.563342]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.563342]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.563342]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.563342]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.563342]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.563342]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.563342]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.563342]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.563342]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   13.563342]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   13.563342]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   13.563342]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   13.563342]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   13.563342]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.563342] ---[ end trace cfeb07101f6fbf4f ]---
[   13.588025] ------------[ cut here ]------------
[   13.588800] WARNING: CPU: 0 PID: 162 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.590446] CPU: 0 PID: 162 Comm: 10-help-text Tainted: G        W     3=
=2E16.0-rc1-00238-gddc5bfe #1
[   13.591060] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.591060]  0000000000000000 ffff88000b087c50 ffffffff81a23b9d ffff8800=
0b087c88
[   13.591060]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff8800=
1200fa50
[   13.591060]  0000000000000001 ffff88001200fa01 ffff88000b087c98 ffffffff=
810bc84b
[   13.591060] Call Trace:
[   13.591060]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.591060]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.591060]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.591060]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.591060]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.591060]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.591060]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.591060]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.591060]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.591060]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.591060]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.591060]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.591060]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
[   13.591060]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
[   13.591060]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
[   13.591060]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
[   13.591060]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
[   13.591060]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.591060] ---[ end trace cfeb07101f6fbf50 ]---
[   13.615785] ------------[ cut here ]------------
[   13.616550] WARNING: CPU: 0 PID: 165 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.618293] CPU: 0 PID: 165 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   13.618446] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.618446]  0000000000000000 ffff88000b097aa8 ffffffff81a23b9d ffff8800=
0b097ae0
[   13.618446]  ffffffff810bc765 ffffffff8111fac8 0000000000013000 ffff8800=
1200fa50
[   13.618446]  0000000000000001 ffff88001200fa01 ffff88000b097af0 ffffffff=
810bc84b
[   13.618446] Call Trace:
[   13.618446]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.618446]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.618446]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.618446]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.618446]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.618446]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.618446]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.618446]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.618446]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.618446]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.618446]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.618446]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.618446]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.618446]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.618446]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.618446]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.618446]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.618446]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.618446]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.618446]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.618446]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.618446]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.618446]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.618446]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.618446] ---[ end trace cfeb07101f6fbf51 ]---
[   13.651185] ------------[ cut here ]------------
[   13.651963] WARNING: CPU: 0 PID: 168 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.653343] CPU: 0 PID: 168 Comm: 10-help-text Tainted: G        W     3=
=2E16.0-rc1-00238-gddc5bfe #1
[   13.653343] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.653343]  0000000000000000 ffff88000b18faa8 ffffffff81a23b9d ffff8800=
0b18fae0
[   13.653343]  ffffffff810bc765 ffffffff8111fac8 0000000000015000 ffff8800=
1200fa50
[   13.653343]  0000000000000001 ffff88001200fa01 ffff88000b18faf0 ffffffff=
810bc84b
[   13.653343] Call Trace:
[   13.653343]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.653343]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.653343]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.653343]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.653343]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.653343]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.653343]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.653343]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.653343]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.653343]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.653343]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.653343]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.653343]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.653343]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.653343]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.653343]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.653343]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.653343]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.653343]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.653343]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.653343]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.653343]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.653343]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.653343]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.653343] ---[ end trace cfeb07101f6fbf52 ]---
[   13.685559] ------------[ cut here ]------------
[   13.686352] WARNING: CPU: 0 PID: 169 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.686845] CPU: 0 PID: 169 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   13.686845] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.686845]  0000000000000000 ffff88000b1afaa8 ffffffff81a23b9d ffff8800=
0b1afae0
[   13.686845]  ffffffff810bc765 ffffffff8111fac8 0000000000010000 ffff8800=
1200fa50
[   13.686845]  0000000000000001 ffff88001200fa01 ffff88000b1afaf0 ffffffff=
810bc84b
[   13.686845] Call Trace:
[   13.686845]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.686845]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.686845]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.686845]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.686845]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.686845]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.686845]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.686845]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.686845]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.686845]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.686845]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.686845]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.686845]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.686845]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.686845]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.686845]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.686845]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.686845]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.686845]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.686845]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.686845]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.686845]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.686845]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.686845]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.686845] ---[ end trace cfeb07101f6fbf53 ]---
[   13.723497] ------------[ cut here ]------------
[   13.724293] WARNING: CPU: 0 PID: 169 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.725942] CPU: 0 PID: 169 Comm: init Tainted: G        W     3.16.0-rc=
1-00238-gddc5bfe #1
[   13.726754] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.726754]  0000000000000000 ffff88000b1afaa8 ffffffff81a23b9d ffff8800=
0b1afae0
[   13.726754]  ffffffff810bc765 ffffffff8111fac8 0000000000009000 ffff8800=
1200fa50
[   13.726754]  0000000000000001 ffff88001200fa01 ffff88000b1afaf0 ffffffff=
810bc84b
[   13.726754] Call Trace:
[   13.726754]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.726754]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.726754]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.726754]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.726754]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.726754]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.726754]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.726754]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.726754]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.726754]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.726754]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.726754]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.726754]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.726754]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.726754]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.726754]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.726754]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.726754]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.726754]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.726754]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.726754]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.726754]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.726754]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.726754]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.726754] ---[ end trace cfeb07101f6fbf54 ]---
[   13.757299] mountall (117) used greatest stack depth: 12904 bytes left
[   13.759453] ------------[ cut here ]------------
[   13.760013] WARNING: CPU: 0 PID: 164 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.760013] CPU: 0 PID: 164 Comm: sh Tainted: G        W     3.16.0-rc1-=
00238-gddc5bfe #1
[   13.760013] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.760013]  0000000000000000 ffff88000b143aa8 ffffffff81a23b9d ffff8800=
0b143ae0
[   13.760013]  ffffffff810bc765 ffffffff8111fac8 0000000000014000 ffff8800=
1200fa50
[   13.760013]  0000000000000001 ffff88001200fa01 ffff88000b143af0 ffffffff=
810bc84b
[   13.760013] Call Trace:
[   13.760013]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.760013]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.760013]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.760013]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.760013]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.760013]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.760013]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.760013]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.760013]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.760013]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.760013]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.760013]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.760013]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.760013]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.760013]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.760013]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.760013]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.760013]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.760013]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.760013]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.760013]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.760013]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.760013]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.760013]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.760013] ---[ end trace cfeb07101f6fbf55 ]---
[   13.791948] ------------[ cut here ]------------
[   13.792719] WARNING: CPU: 0 PID: 166 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.794391] CPU: 0 PID: 166 Comm: plymouth Tainted: G        W     3.16.=
0-rc1-00238-gddc5bfe #1
[   13.794921] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.794921]  0000000000000000 ffff88000b11fc48 ffffffff81a23b9d ffff8800=
0b11fc80
[   13.794921]  ffffffff810bc765 ffffffff8111fac8 0000000000025000 ffff8800=
1200fa50
[   13.794921]  0000000000000001 ffff88001200fa01 ffff88000b11fc90 ffffffff=
810bc84b
[   13.794921] Call Trace:
[   13.794921]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.794921]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.794921]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.794921]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.794921]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.794921]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.794921]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.794921]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.794921]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.794921]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.794921]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.794921]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.794921]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.794921]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.794921]  [<ffffffff810be8ad>] do_exit+0x3cf/0xb1d
[   13.794921]  [<ffffffff81a32118>] ? retint_swapgs+0x13/0x1b
[   13.794921]  [<ffffffff810bf0c7>] do_group_exit+0x96/0xd5
[   13.794921]  [<ffffffff810bf11a>] SyS_exit_group+0x14/0x14
[   13.794921]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
[   13.794921] ---[ end trace cfeb07101f6fbf56 ]---
[   13.819888] ------------[ cut here ]------------
[   13.820642] WARNING: CPU: 0 PID: 167 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
[   13.822291] CPU: 0 PID: 167 Comm: 10-help-text Tainted: G        W     3=
=2E16.0-rc1-00238-gddc5bfe #1
[   13.822955] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.822955]  0000000000000000 ffff88000b18baa8 ffffffff81a23b9d ffff8800=
0b18bae0
[   13.822955]  ffffffff810bc765 ffffffff8111fac8 0000000000014000 ffff8800=
1200fa50
[   13.822955]  0000000000000001 ffff88001200fa01 ffff88000b18baf0 ffffffff=
810bc84b
[   13.822955] Call Trace:
[   13.822955]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
[   13.822955]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
[   13.822955]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
[   13.822955]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
[   13.822955]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
[   13.822955]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
[   13.822955]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
[   13.822955]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
[   13.822955]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
[   13.822955]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
[   13.822955]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
[   13.822955]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
[   13.822955]  [<ffffffff81174de8>] exit_mmap+0xe4/0x167
[   13.822955]  [<ffffffff810b9d42>] mmput+0x43/0xca
[   13.822955]  [<ffffffff8119e439>] flush_old_exec+0x67f/0x77a
[   13.822955]  [<ffffffff811deed3>] load_elf_binary+0x2cc/0x16fc
[   13.822955]  [<ffffffff81a30bec>] ? _raw_read_unlock+0x27/0x31
[   13.822955]  [<ffffffff811dc949>] ? load_misc_binary+0x13d/0x328
[   13.822955]  [<ffffffff810f5804>] ? lock_acquire+0x11e/0x14f
[   13.822955]  [<ffffffff8119e943>] search_binary_handler+0x59/0xb3
[   13.822955]  [<ffffffff8119edc9>] do_execve_common.isra.21+0x42c/0x62b
[   13.822955]  [<ffffffff8119efe0>] do_execve+0x18/0x1a
[   13.822955]  [<ffffffff8119f286>] SyS_execve+0x2a/0x2e
[   13.822955]  [<ffffffff81a31b08>] stub_execve+0x68/0xa0
[   13.822955] ---[ end trace cfeb07101f6fbf57 ]---
Kernel tests: Boot OK!
[   66.551947] reboot: Restarting system
Elapsed time: 75
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/x86_64-randconfig=
-wa0-06201428/ddc5bfec501f4be3f9e89084c2db270c0c45d1d6/vmlinuz-3.16.0-rc1-0=
0238-gddc5bfe -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug=
 apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 pan=
ic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 conso=
le=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/=
kbuild-tests/run-queue/kvm/x86_64-randconfig-wa0-06201428/next:master:ddc5b=
fec501f4be3f9e89084c2db270c0c45d1d6:bisect-linux/.vmlinuz-ddc5bfec501f4be3f=
9e89084c2db270c0c45d1d6-20140620164751-3-ivb44 branch=3Dnext/master BOOT_IM=
AGE=3D/kernel/x86_64-randconfig-wa0-06201428/ddc5bfec501f4be3f9e89084c2db27=
0c0c45d1d6/vmlinuz-3.16.0-rc1-00238-gddc5bfe drbd.minor_count=3D8'  -initrd=
 /kernel-tests/initrd/quantal-core-x86_64.cgz -m 320 -smp 2 -net nic,vlan=
=3D1,model=3De1000 -net user,vlan=3D1 -boot order=3Dnc -no-reboot -watchdog=
 i6300esb -rtc base=3Dlocaltime -pidfile /dev/shm/kboot/pid-quantal-ivb44-7=
7 -serial file:/dev/shm/kboot/serial-quantal-ivb44-77 -daemonize -display n=
one -monitor null=20

--yrj/dFKFPuw6o+aM
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="x86_64-randconfig-wa0-06201428-633594bb2d3890711a887897f2003f41735f0dfa-WARNING:---at----res_counter_uncharge_locked+-x-125186.log"
Content-Transfer-Encoding: base64

SEVBRCBpcyBub3cgYXQgNjMzNTk0Yi4uLiBBZGQgbGludXgtbmV4dCBzcGVjaWZpYyBmaWxl
cyBmb3IgMjAxNDA2MjAKZ2l0IGNoZWNrb3V0IDcxZDI3M2ZhNzY5ZWEyMWYyNDIyYTE4NDgy
ZTAwMmEwN2FiOWY4ZjMKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82
NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC9uZXh0Om1hc3Rlcjo3MWQyNzNmYTc2OWVhMjFm
MjQyMmExODQ4MmUwMDJhMDdhYjlmOGYzOmJpc2VjdC1saW51eAoKMjAxNC0wNi0yMC0xNDoz
ODo0MyA3MWQyNzNmYTc2OWVhMjFmMjQyMmExODQ4MmUwMDJhMDdhYjlmOGYzIGNvbXBpbGlu
ZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82
NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC03MWQyNzNmYTc2OWVhMjFmMjQyMmExODQ4MmUw
MDJhMDdhYjlmOGYzCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC94ODZfNjQtcmFuZGNv
bmZpZy13YTAtMDYyMDE0MjgvNzFkMjczZmE3NjllYTIxZjI0MjJhMTg0ODJlMDAyYTA3YWI5
ZjhmMwp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LTcxZDI3M2ZhNzY5ZWEyMWYyNDIy
YTE4NDgyZTAwMmEwN2FiOWY4ZjMKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxk
LXRlc3RzL2J1aWxkLXF1ZXVlLy54ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgtNzFk
MjczZmE3NjllYTIxZjI0MjJhMTg0ODJlMDAyYTA3YWI5ZjhmMwprZXJuZWw6IC9rZXJuZWwv
eDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LzcxZDI3M2ZhNzY5ZWEyMWYyNDIyYTE4
NDgyZTAwMmEwN2FiOWY4ZjMvdm1saW51ei0zLjE2LjAtcmMxLTAxODM2LWc3MWQyNzNmCgoy
MDE0LTA2LTIwLTE0OjQzOjQzIGRldGVjdGluZyBib290IHN0YXRlIC4JMgkyMCBTVUNDRVNT
CgpiaXNlY3Q6IGdvb2QgY29tbWl0IDcxZDI3M2ZhNzY5ZWEyMWYyNDIyYTE4NDgyZTAwMmEw
N2FiOWY4ZjMKZ2l0IGJpc2VjdCBzdGFydCA2MzM1OTRiYjJkMzg5MDcxMWE4ODc4OTdmMjAw
M2Y0MTczNWYwZGZhIDcxZDI3M2ZhNzY5ZWEyMWYyNDIyYTE4NDgyZTAwMmEwN2FiOWY4ZjMg
LS0KL2Mva2VybmVsLXRlc3RzL2xpbmVhci1iaXNlY3Q6IFsiLWIiLCAiNjMzNTk0YmIyZDM4
OTA3MTFhODg3ODk3ZjIwMDNmNDE3MzVmMGRmYSIsICItZyIsICI3MWQyNzNmYTc2OWVhMjFm
MjQyMmExODQ4MmUwMDJhMDdhYjlmOGYzIiwgIi9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVz
dC1ib290LWZhaWx1cmUuc2giLCAiL2MvYm9vdC1iaXNlY3QvbGludXgvb2JqLWJpc2VjdCJd
CkJpc2VjdGluZzogMjE3IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91
Z2hseSA4IHN0ZXBzKQpbZGYyYzA0YzY4ODMxZDEzZDUwNWMxMjdiNWFhMTcyMzYxYTE3Yzdl
M10gUmV2ZXJ0ICJtbSwgQ01BOiBjaGFuZ2UgY21hX2RlY2xhcmVfY29udGlndW91cygpIHRv
IG9iZXkgY29kaW5nIGNvbnZlbnRpb24iCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2Vj
dC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eC9vYmotYmlzZWN0
CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy13
YTAtMDYyMDE0MjgvbmV4dDptYXN0ZXI6ZGYyYzA0YzY4ODMxZDEzZDUwNWMxMjdiNWFhMTcy
MzYxYTE3YzdlMzpiaXNlY3QtbGludXgKCjIwMTQtMDYtMjAtMTQ6NDU6MTQgZGYyYzA0YzY4
ODMxZDEzZDUwNWMxMjdiNWFhMTcyMzYxYTE3YzdlMyBjb21waWxpbmcKUXVldWVkIGJ1aWxk
IHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS94ODZfNjQtcmFuZGNvbmZpZy13
YTAtMDYyMDE0MjgtZGYyYzA0YzY4ODMxZDEzZDUwNWMxMjdiNWFhMTcyMzYxYTE3YzdlMwpD
aGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAx
NDI4L2RmMmMwNGM2ODgzMWQxM2Q1MDVjMTI3YjVhYTE3MjM2MWExN2M3ZTMKd2FpdGluZyBm
b3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5k
Y29uZmlnLXdhMC0wNjIwMTQyOC1kZjJjMDRjNjg4MzFkMTNkNTA1YzEyN2I1YWExNzIzNjFh
MTdjN2UzCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1x
dWV1ZS8ueDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LWRmMmMwNGM2ODgzMWQxM2Q1
MDVjMTI3YjVhYTE3MjM2MWExN2M3ZTMKa2VybmVsOiAva2VybmVsL3g4Nl82NC1yYW5kY29u
ZmlnLXdhMC0wNjIwMTQyOC9kZjJjMDRjNjg4MzFkMTNkNTA1YzEyN2I1YWExNzIzNjFhMTdj
N2UzL3ZtbGludXotMy4xNi4wLXJjMS0wMjA0OS1nZGYyYzA0YwoKMjAxNC0wNi0yMC0xNDo1
MDoxNCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4gVEVTVCBGQUlMVVJFClsgICAgMi43Njcx
ODBdIGRlYnVnOiB1bm1hcHBpbmcgaW5pdCBbbWVtIDB4ZmZmZjg4MDAwMWE0NDAwMC0weGZm
ZmY4ODAwMDFiZmZmZmZdClsgICAgMi43NjgzODBdIGRlYnVnOiB1bm1hcHBpbmcgaW5pdCBb
bWVtIDB4ZmZmZjg4MDAwMjFiMzAwMC0weGZmZmY4ODAwMDIxZmZmZmZdClsgICAgMi43NzI2
OTNdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbICAgIDIuNzczMzQ2
XSBXQVJOSU5HOiBDUFU6IDAgUElEOiAxIGF0IC9rYnVpbGQvc3JjL3Ntb2tlL2tlcm5lbC9y
ZXNfY291bnRlci5jOjI4IHJlc19jb3VudGVyX3VuY2hhcmdlX2xvY2tlZCsweDQ4LzB4NzQo
KQpbICAgIDIuNzczMzQ2XSBDUFU6IDAgUElEOiAxIENvbW06IGluaXQgTm90IHRhaW50ZWQg
My4xNi4wLXJjMS0wMjA0OS1nZGYyYzA0YyAjMQpbICAgIDIuNzczMzQ2XSBIYXJkd2FyZSBu
YW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAwMS8wMS8yMDExClsgICAgMi43NzMzNDZd
ICAwMDAwMDAwMDAwMDAwMDAwIGZmZmY4ODAwMTIwNzNjNTAgZmZmZmZmZmY4MWEyZDY4YiBm
ZmZmODgwMDEyMDczYzg4ClsgICAgMi43NzMzNDZdICBmZmZmZmZmZjgxMGJjZGIyIGZmZmZm
ZmZmODExMjAyMTMgMDAwMDAwMDAwMDAwMTAwMCBmZmZmODgwMDEyMDBmYTUwClsgICAgMi43
NzMzNDZdICAwMDAwMDAwMDAwMDAwMDAxIGZmZmY4ODAwMTIwMGZhMDEgZmZmZjg4MDAxMjA3
M2M5OCBmZmZmZmZmZjgxMGJjZTk4ClsgICAgMi43NzMzNDZdIENhbGwgVHJhY2U6ClsgICAg
Mi43NzMzNDZdICBbPGZmZmZmZmZmODFhMmQ2OGI+XSBkdW1wX3N0YWNrKzB4MTkvMHgxYgpb
ICAgIDIuNzczMzQ2XSAgWzxmZmZmZmZmZjgxMGJjZGIyPl0gd2Fybl9zbG93cGF0aF9jb21t
b24rMHg3My8weDhjClsgICAgMi43NzMzNDZdICBbPGZmZmZmZmZmODExMjAyMTM+XSA/IHJl
c19jb3VudGVyX3VuY2hhcmdlX2xvY2tlZCsweDQ4LzB4NzQKWyAgICAyLjc3MzM0Nl0gIFs8
ZmZmZmZmZmY4MTBiY2U5OD5dIHdhcm5fc2xvd3BhdGhfbnVsbCsweDFhLzB4MWMKWyAgICAy
Ljc3MzM0Nl0gIFs8ZmZmZmZmZmY4MTEyMDIxMz5dIHJlc19jb3VudGVyX3VuY2hhcmdlX2xv
Y2tlZCsweDQ4LzB4NzQKWyAgICAyLjc3MzM0Nl0gIFs8ZmZmZmZmZmY4MTEyMDQ0ZD5dIHJl
c19jb3VudGVyX3VuY2hhcmdlX3VudGlsKzB4NGUvMHhhOQpbICAgIDIuNzczMzQ2XSAgWzxm
ZmZmZmZmZjgxMTIwNGJiPl0gcmVzX2NvdW50ZXJfdW5jaGFyZ2UrMHgxMy8weDE1ClsgICAg
Mi43NzMzNDZdICBbPGZmZmZmZmZmODExOTRlYTc+XSBtZW1fY2dyb3VwX3VuY2hhcmdlX2Vu
ZCsweDczLzB4OGQKWyAgICAyLjc3MzM0Nl0gIFs8ZmZmZmZmZmY4MTE1N2JjMj5dIHJlbGVh
c2VfcGFnZXMrMHgxZjIvMHgyMGQKWyAgICAyLjc3MzM0Nl0gIFs8ZmZmZmZmZmY4MTE2Y2Vk
OD5dIHRsYl9mbHVzaF9tbXVfZnJlZSsweDI4LzB4NDMKWyAgICAyLjc3MzM0Nl0gIFs8ZmZm
ZmZmZmY4MTE2ZDg4Mz5dIHRsYl9mbHVzaF9tbXUrMHgyMC8weDIzClsgICAgMi43NzMzNDZd
ICBbPGZmZmZmZmZmODExNmQ4OWE+XSB0bGJfZmluaXNoX21tdSsweDE0LzB4MzkKWyAgICAy
Ljc3MzM0Nl0gIFs8ZmZmZmZmZmY4MTE3MzM1Zj5dIHVubWFwX3JlZ2lvbisweGNkLzB4ZGYK
WyAgICAyLjc3MzM0Nl0gIFs8ZmZmZmZmZmY4MTE3MmRhYz5dID8gdm1hX2dhcF9jYWxsYmFj
a3NfcHJvcGFnYXRlKzB4MTgvMHgzMwpbICAgIDIuNzczMzQ2XSAgWzxmZmZmZmZmZjgxMTc0
ZThmPl0gZG9fbXVubWFwKzB4MjUyLzB4MmUwClsgICAgMi43NzMzNDZdICBbPGZmZmZmZmZm
ODExNzRmNjE+XSB2bV9tdW5tYXArMHg0NC8weDVjClsgICAgMi43NzMzNDZdICBbPGZmZmZm
ZmZmODExNzRmOWM+XSBTeVNfbXVubWFwKzB4MjMvMHgyOQpbICAgIDIuNzczMzQ2XSAgWzxm
ZmZmZmZmZjgxYTNiMDY3Pl0gc3lzdGVtX2NhbGxfZmFzdHBhdGgrMHgxNi8weDFiClsgICAg
Mi43NzMzNDZdIC0tLVsgZW5kIHRyYWNlIGU2MjQ1YzZlOWJmZmFlYzUgXS0tLQpbICAgIDIu
Nzk5ODg4XSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KL2tlcm5lbC94
ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvZGYyYzA0YzY4ODMxZDEzZDUwNWMxMjdi
NWFhMTcyMzYxYTE3YzdlMy9kbWVzZy1xdWFudGFsLWl2YjQ0LTEwNDoyMDE0MDYyMDE0NTEy
Mjp4ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS0wMjA0OS1nZGYy
YzA0YzoxCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4L2RmMmMwNGM2
ODgzMWQxM2Q1MDVjMTI3YjVhYTE3MjM2MWExN2M3ZTMvZG1lc2ctcXVhbnRhbC1pdmI0NC0x
MTM6MjAxNDA2MjAxNDUxMTk6eDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4OjMuMTYu
MC1yYzEtMDIwNDktZ2RmMmMwNGM6MQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0w
NjIwMTQyOC9kZjJjMDRjNjg4MzFkMTNkNTA1YzEyN2I1YWExNzIzNjFhMTdjN2UzL2RtZXNn
LXF1YW50YWwtaXZiNDQtMzM6MjAxNDA2MjAxNDUxMTk6eDg2XzY0LXJhbmRjb25maWctd2Ew
LTA2MjAxNDI4OjMuMTYuMC1yYzEtMDIwNDktZ2RmMmMwNGM6MQova2VybmVsL3g4Nl82NC1y
YW5kY29uZmlnLXdhMC0wNjIwMTQyOC9kZjJjMDRjNjg4MzFkMTNkNTA1YzEyN2I1YWExNzIz
NjFhMTdjN2UzL2RtZXNnLXF1YW50YWwtaXZiNDItODk6MjAxNDA2MjAxNDUxMzA6eDg2XzY0
LXJhbmRjb25maWctd2EwLTA2MjAxNDI4OjMuMTYuMC1yYzEtMDIwNDktZ2RmMmMwNGM6MQow
OjQ6NCBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwobWzE7MzVtMjAxNC0wNi0yMCAxNDo1
MTo0NSBSRVBFQVQgQ09VTlQ6IDIwICAjIC9jL2Jvb3QtYmlzZWN0L2xpbnV4L29iai1iaXNl
Y3QvLnJlcGVhdBtbMG0KCkJpc2VjdGluZzogMjEzIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3Qg
YWZ0ZXIgdGhpcyAocm91Z2hseSA4IHN0ZXBzKQpbZGM4YTI2ZDY5ZDIwMzlhODE5ODU1NDli
MDBmYzdlN2UyYmQzNGRkNF0gTWVyZ2UgYnJhbmNoICdha3BtL21hc3RlcicKcnVubmluZyAv
Yy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlz
ZWN0L2xpbnV4L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3Zt
L3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC9uZXh0Om1hc3RlcjpkYzhhMjZkNjlk
MjAzOWE4MTk4NTU0OWIwMGZjN2U3ZTJiZDM0ZGQ0OmJpc2VjdC1saW51eAoKMjAxNC0wNi0y
MC0xNDo1MTo0NSBkYzhhMjZkNjlkMjAzOWE4MTk4NTU0OWIwMGZjN2U3ZTJiZDM0ZGQ0IGNv
bXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVl
L3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC1kYzhhMjZkNjlkMjAzOWE4MTk4NTU0
OWIwMGZjN2U3ZTJiZDM0ZGQ0CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC94ODZfNjQt
cmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvZGM4YTI2ZDY5ZDIwMzlhODE5ODU1NDliMDBmYzdl
N2UyYmQzNGRkNAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVp
bGQtcXVldWUveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LWRjOGEyNmQ2OWQyMDM5
YTgxOTg1NTQ5YjAwZmM3ZTdlMmJkMzRkZDQKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAv
a2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlLy54ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0
MjgtZGM4YTI2ZDY5ZDIwMzlhODE5ODU1NDliMDBmYzdlN2UyYmQzNGRkNAprZXJuZWw6IC9r
ZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4L2RjOGEyNmQ2OWQyMDM5YTgx
OTg1NTQ5YjAwZmM3ZTdlMmJkMzRkZDQvdm1saW51ei0zLjE2LjAtcmMxLTAyMDQ3LWdkYzhh
MjZkCgoyMDE0LTA2LTIwLTE0OjU3OjQ2IGRldGVjdGluZyBib290IHN0YXRlIC4uIFRFU1Qg
RkFJTFVSRQpbICAgIDIuNzE5NTg1XSBkZWJ1ZzogdW5tYXBwaW5nIGluaXQgW21lbSAweGZm
ZmY4ODAwMDFhNDQwMDAtMHhmZmZmODgwMDAxYmZmZmZmXQpbICAgIDIuNzIwODI2XSBkZWJ1
ZzogdW5tYXBwaW5nIGluaXQgW21lbSAweGZmZmY4ODAwMDIxYjMwMDAtMHhmZmZmODgwMDAy
MWZmZmZmXQpbICAgIDIuNzI1MDI5XSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0t
LS0tLS0KWyAgICAyLjcyNTc5Nl0gV0FSTklORzogQ1BVOiAwIFBJRDogMSBhdCAva2J1aWxk
L3NyYy9zbW9rZS9rZXJuZWwvcmVzX2NvdW50ZXIuYzoyOCByZXNfY291bnRlcl91bmNoYXJn
ZV9sb2NrZWQrMHg0OC8weDc0KCkKWyAgICAyLjcyNjY3N10gQ1BVOiAwIFBJRDogMSBDb21t
OiBpbml0IE5vdCB0YWludGVkIDMuMTYuMC1yYzEtMDIwNDctZ2RjOGEyNmQgIzEKWyAgICAy
LjcyNjY3N10gSGFyZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMsIEJJT1MgQm9jaHMgMDEvMDEv
MjAxMQpbICAgIDIuNzI2Njc3XSAgMDAwMDAwMDAwMDAwMDAwMCBmZmZmODgwMDEyMDczYzUw
IGZmZmZmZmZmODFhMmQ2OGIgZmZmZjg4MDAxMjA3M2M4OApbICAgIDIuNzI2Njc3XSAgZmZm
ZmZmZmY4MTBiY2RiMiBmZmZmZmZmZjgxMTIwMjEzIDAwMDAwMDAwMDAwMDEwMDAgZmZmZjg4
MDAxMjAwZmE1MApbICAgIDIuNzI2Njc3XSAgMDAwMDAwMDAwMDAwMDAwMSBmZmZmODgwMDEy
MDBmYTAxIGZmZmY4ODAwMTIwNzNjOTggZmZmZmZmZmY4MTBiY2U5OApbICAgIDIuNzI2Njc3
XSBDYWxsIFRyYWNlOgpbICAgIDIuNzI2Njc3XSAgWzxmZmZmZmZmZjgxYTJkNjhiPl0gZHVt
cF9zdGFjaysweDE5LzB4MWIKWyAgICAyLjcyNjY3N10gIFs8ZmZmZmZmZmY4MTBiY2RiMj5d
IHdhcm5fc2xvd3BhdGhfY29tbW9uKzB4NzMvMHg4YwpbICAgIDIuNzI2Njc3XSAgWzxmZmZm
ZmZmZjgxMTIwMjEzPl0gPyByZXNfY291bnRlcl91bmNoYXJnZV9sb2NrZWQrMHg0OC8weDc0
ClsgICAgMi43MjY2NzddICBbPGZmZmZmZmZmODEwYmNlOTg+XSB3YXJuX3Nsb3dwYXRoX251
bGwrMHgxYS8weDFjClsgICAgMi43MjY2NzddICBbPGZmZmZmZmZmODExMjAyMTM+XSByZXNf
Y291bnRlcl91bmNoYXJnZV9sb2NrZWQrMHg0OC8weDc0ClsgICAgMi43MjY2NzddICBbPGZm
ZmZmZmZmODExMjA0NGQ+XSByZXNfY291bnRlcl91bmNoYXJnZV91bnRpbCsweDRlLzB4YTkK
WyAgICAyLjcyNjY3N10gIFs8ZmZmZmZmZmY4MTEyMDRiYj5dIHJlc19jb3VudGVyX3VuY2hh
cmdlKzB4MTMvMHgxNQpbICAgIDIuNzI2Njc3XSAgWzxmZmZmZmZmZjgxMTk0ZWE3Pl0gbWVt
X2Nncm91cF91bmNoYXJnZV9lbmQrMHg3My8weDhkClsgICAgMi43MjY2NzddICBbPGZmZmZm
ZmZmODExNTdiYzI+XSByZWxlYXNlX3BhZ2VzKzB4MWYyLzB4MjBkClsgICAgMi43MjY2Nzdd
ICBbPGZmZmZmZmZmODExNmNlZDg+XSB0bGJfZmx1c2hfbW11X2ZyZWUrMHgyOC8weDQzClsg
ICAgMi43MjY2NzddICBbPGZmZmZmZmZmODExNmQ4ODM+XSB0bGJfZmx1c2hfbW11KzB4MjAv
MHgyMwpbICAgIDIuNzI2Njc3XSAgWzxmZmZmZmZmZjgxMTZkODlhPl0gdGxiX2ZpbmlzaF9t
bXUrMHgxNC8weDM5ClsgICAgMi43MjY2NzddICBbPGZmZmZmZmZmODExNzMzNWY+XSB1bm1h
cF9yZWdpb24rMHhjZC8weGRmClsgICAgMi43MjY2NzddICBbPGZmZmZmZmZmODExNzJkYWM+
XSA/IHZtYV9nYXBfY2FsbGJhY2tzX3Byb3BhZ2F0ZSsweDE4LzB4MzMKWyAgICAyLjcyNjY3
N10gIFs8ZmZmZmZmZmY4MTE3NGU4Zj5dIGRvX211bm1hcCsweDI1Mi8weDJlMApbICAgIDIu
NzI2Njc3XSAgWzxmZmZmZmZmZjgxMTc0ZjYxPl0gdm1fbXVubWFwKzB4NDQvMHg1YwpbICAg
IDIuNzI2Njc3XSAgWzxmZmZmZmZmZjgxMTc0ZjljPl0gU3lTX211bm1hcCsweDIzLzB4MjkK
WyAgICAyLjcyNjY3N10gIFs8ZmZmZmZmZmY4MWEzYjA2Nz5dIHN5c3RlbV9jYWxsX2Zhc3Rw
YXRoKzB4MTYvMHgxYgpbICAgIDIuNzI2Njc3XSAtLS1bIGVuZCB0cmFjZSA0ZjI3NThmNzEw
YWI4MDczIF0tLS0KWyAgICAyLjc1MTQwMV0gLS0tLS0tLS0tLS0tWyBjdXQgaGVyZSBdLS0t
LS0tLS0tLS0tCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4L2RjOGEy
NmQ2OWQyMDM5YTgxOTg1NTQ5YjAwZmM3ZTdlMmJkMzRkZDQvZG1lc2ctcXVhbnRhbC1pdmI0
MS0xMTQ6MjAxNDA2MjAxNDU4MzY6eDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4OjMu
MTYuMC1yYzEtMDIwNDctZ2RjOGEyNmQ6MQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdh
MC0wNjIwMTQyOC9kYzhhMjZkNjlkMjAzOWE4MTk4NTU0OWIwMGZjN2U3ZTJiZDM0ZGQ0L2Rt
ZXNnLXF1YW50YWwtaXZiNDItNDI6MjAxNDA2MjAxNDU4MzY6eDg2XzY0LXJhbmRjb25maWct
d2EwLTA2MjAxNDI4OjMuMTYuMC1yYzEtMDIwNDctZ2RjOGEyNmQ6MQowOjI6MiBhbGxfZ29v
ZDpiYWQ6YWxsX2JhZCBib290cwobWzE7MzVtMjAxNC0wNi0yMCAxNDo1ODo0NiBSRVBFQVQg
Q09VTlQ6IDIwICAjIC9jL2Jvb3QtYmlzZWN0L2xpbnV4L29iai1iaXNlY3QvLnJlcGVhdBtb
MG0KCkJpc2VjdGluZzogMjExIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAo
cm91Z2hseSA4IHN0ZXBzKQpbZmUyOTdiNGQ2OTg3ZDA0ZThiMzg3OGIzZWU0N2VmZDI2Yjk1
MTE0ZF0gTWVyZ2UgYnJhbmNoICdha3BtLWN1cnJlbnQvY3VycmVudCcKcnVubmluZyAvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0
L2xpbnV4L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4
Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC9uZXh0Om1hc3RlcjpmZTI5N2I0ZDY5ODdk
MDRlOGIzODc4YjNlZTQ3ZWZkMjZiOTUxMTRkOmJpc2VjdC1saW51eAoKMjAxNC0wNi0yMC0x
NDo1ODo0NyBmZTI5N2I0ZDY5ODdkMDRlOGIzODc4YjNlZTQ3ZWZkMjZiOTUxMTRkIGNvbXBp
bGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL3g4
Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC1mZTI5N2I0ZDY5ODdkMDRlOGIzODc4YjNl
ZTQ3ZWZkMjZiOTUxMTRkCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC94ODZfNjQtcmFu
ZGNvbmZpZy13YTAtMDYyMDE0MjgvZmUyOTdiNGQ2OTg3ZDA0ZThiMzg3OGIzZWU0N2VmZDI2
Yjk1MTE0ZAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQt
cXVldWUveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LWZlMjk3YjRkNjk4N2QwNGU4
YjM4NzhiM2VlNDdlZmQyNmI5NTExNGQKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1
aWxkLXRlc3RzL2J1aWxkLXF1ZXVlLy54ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjgt
ZmUyOTdiNGQ2OTg3ZDA0ZThiMzg3OGIzZWU0N2VmZDI2Yjk1MTE0ZAprZXJuZWw6IC9rZXJu
ZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4L2ZlMjk3YjRkNjk4N2QwNGU4YjM4
NzhiM2VlNDdlZmQyNmI5NTExNGQvdm1saW51ei0zLjE2LjAtcmMxLTAyMDI0LWdmZTI5N2I0
CgoyMDE0LTA2LTIwLTE1OjE0OjQ3IGRldGVjdGluZyBib290IHN0YXRlIC4uLiBURVNUIEZB
SUxVUkUKWyAgICAyLjc3ODkzMF0gZGVidWc6IHVubWFwcGluZyBpbml0IFttZW0gMHhmZmZm
ODgwMDAxYTQ0MDAwLTB4ZmZmZjg4MDAwMWJmZmZmZl0KWyAgICAyLjc4MDE5NF0gZGVidWc6
IHVubWFwcGluZyBpbml0IFttZW0gMHhmZmZmODgwMDAyMWI0MDAwLTB4ZmZmZjg4MDAwMjFm
ZmZmZl0KWyAgICAyLjc4NDU3N10gLS0tLS0tLS0tLS0tWyBjdXQgaGVyZSBdLS0tLS0tLS0t
LS0tClsgICAgMi43ODU0MjJdIFdBUk5JTkc6IENQVTogMCBQSUQ6IDEgYXQgL2tidWlsZC9z
cmMvY29uc3VtZXIva2VybmVsL3Jlc19jb3VudGVyLmM6MjggcmVzX2NvdW50ZXJfdW5jaGFy
Z2VfbG9ja2VkKzB4NDgvMHg3NCgpClsgICAgMi43ODY2NzhdIENQVTogMCBQSUQ6IDEgQ29t
bTogaW5pdCBOb3QgdGFpbnRlZCAzLjE2LjAtcmMxLTAyMDI0LWdmZTI5N2I0ICMxClsgICAg
Mi43ODY2NzhdIEhhcmR3YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAx
LzIwMTEKWyAgICAyLjc4NjY3OF0gIDAwMDAwMDAwMDAwMDAwMDAgZmZmZjg4MDAxMjA3M2M1
MCBmZmZmZmZmZjgxYTJkNjliIGZmZmY4ODAwMTIwNzNjODgKWyAgICAyLjc4NjY3OF0gIGZm
ZmZmZmZmODEwYmNkYjIgZmZmZmZmZmY4MTEyMDIxMyAwMDAwMDAwMDAwMDAxMDAwIGZmZmY4
ODAwMTIwMGZhNTAKWyAgICAyLjc4NjY3OF0gIDAwMDAwMDAwMDAwMDAwMDEgZmZmZjg4MDAx
MjAwZmEwMSBmZmZmODgwMDEyMDczYzk4IGZmZmZmZmZmODEwYmNlOTgKWyAgICAyLjc4NjY3
OF0gQ2FsbCBUcmFjZToKWyAgICAyLjc4NjY3OF0gIFs8ZmZmZmZmZmY4MWEyZDY5Yj5dIGR1
bXBfc3RhY2srMHgxOS8weDFiClsgICAgMi43ODY2NzhdICBbPGZmZmZmZmZmODEwYmNkYjI+
XSB3YXJuX3Nsb3dwYXRoX2NvbW1vbisweDczLzB4OGMKWyAgICAyLjc4NjY3OF0gIFs8ZmZm
ZmZmZmY4MTEyMDIxMz5dID8gcmVzX2NvdW50ZXJfdW5jaGFyZ2VfbG9ja2VkKzB4NDgvMHg3
NApbICAgIDIuNzg2Njc4XSAgWzxmZmZmZmZmZjgxMGJjZTk4Pl0gd2Fybl9zbG93cGF0aF9u
dWxsKzB4MWEvMHgxYwpbICAgIDIuNzg2Njc4XSAgWzxmZmZmZmZmZjgxMTIwMjEzPl0gcmVz
X2NvdW50ZXJfdW5jaGFyZ2VfbG9ja2VkKzB4NDgvMHg3NApbICAgIDIuNzg2Njc4XSAgWzxm
ZmZmZmZmZjgxMTIwNDRkPl0gcmVzX2NvdW50ZXJfdW5jaGFyZ2VfdW50aWwrMHg0ZS8weGE5
ClsgICAgMi43ODY2NzhdICBbPGZmZmZmZmZmODExMjA0YmI+XSByZXNfY291bnRlcl91bmNo
YXJnZSsweDEzLzB4MTUKWyAgICAyLjc4NjY3OF0gIFs8ZmZmZmZmZmY4MTE5NTIyZD5dIG1l
bV9jZ3JvdXBfdW5jaGFyZ2VfZW5kKzB4NzMvMHg4ZApbICAgIDIuNzg2Njc4XSAgWzxmZmZm
ZmZmZjgxMTU3YmJjPl0gcmVsZWFzZV9wYWdlcysweDFmMi8weDIwZApbICAgIDIuNzg2Njc4
XSAgWzxmZmZmZmZmZjgxMTZkNGFhPl0gdGxiX2ZsdXNoX21tdV9mcmVlKzB4MjgvMHg0Mwpb
ICAgIDIuNzg2Njc4XSAgWzxmZmZmZmZmZjgxMTZkZTU1Pl0gdGxiX2ZsdXNoX21tdSsweDIw
LzB4MjMKWyAgICAyLjc4NjY3OF0gIFs8ZmZmZmZmZmY4MTE2ZGU2Yz5dIHRsYl9maW5pc2hf
bW11KzB4MTQvMHgzOQpbICAgIDIuNzg2Njc4XSAgWzxmZmZmZmZmZjgxMTczOTMxPl0gdW5t
YXBfcmVnaW9uKzB4Y2QvMHhkZgpbICAgIDIuNzg2Njc4XSAgWzxmZmZmZmZmZjgxMTczMzdl
Pl0gPyB2bWFfZ2FwX2NhbGxiYWNrc19wcm9wYWdhdGUrMHgxOC8weDMzClsgICAgMi43ODY2
NzhdICBbPGZmZmZmZmZmODExNzU0NjE+XSBkb19tdW5tYXArMHgyNTIvMHgyZTAKWyAgICAy
Ljc4NjY3OF0gIFs8ZmZmZmZmZmY4MTE3NTUzMz5dIHZtX211bm1hcCsweDQ0LzB4NWMKWyAg
ICAyLjc4NjY3OF0gIFs8ZmZmZmZmZmY4MTE3NTU2ZT5dIFN5U19tdW5tYXArMHgyMy8weDI5
ClsgICAgMi43ODY2NzhdICBbPGZmZmZmZmZmODFhM2IwNjc+XSBzeXN0ZW1fY2FsbF9mYXN0
cGF0aCsweDE2LzB4MWIKWyAgICAyLjc4NjY3OF0gLS0tWyBlbmQgdHJhY2UgYjRiOWU0ODhm
MmYwYmUxZiBdLS0tClsgICAgMi44MTI3ODldIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0t
LS0tLS0tLS0tLQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC9mZTI5
N2I0ZDY5ODdkMDRlOGIzODc4YjNlZTQ3ZWZkMjZiOTUxMTRkL2RtZXNnLXF1YW50YWwtaXZi
NDItMTE5OjIwMTQwNjIwMTUxNTQ3Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODoz
LjE2LjAtcmMxLTAyMDI0LWdmZTI5N2I0OjEKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13
YTAtMDYyMDE0MjgvZmUyOTdiNGQ2OTg3ZDA0ZThiMzg3OGIzZWU0N2VmZDI2Yjk1MTE0ZC9k
bWVzZy1xdWFudGFsLWl2YjQyLTQzOjIwMTQwNjIwMTUxNTQ3Ong4Nl82NC1yYW5kY29uZmln
LXdhMC0wNjIwMTQyODozLjE2LjAtcmMxLTAyMDI0LWdmZTI5N2I0OjEKL2tlcm5lbC94ODZf
NjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvZmUyOTdiNGQ2OTg3ZDA0ZThiMzg3OGIzZWU0
N2VmZDI2Yjk1MTE0ZC9kbWVzZy1xdWFudGFsLWl2YjQ0LTI2OjIwMTQwNjIwMTUxNTQ1Ong4
Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMxLTAyMDI0LWdmZTI5N2I0
OjEKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvZmUyOTdiNGQ2OTg3
ZDA0ZThiMzg3OGIzZWU0N2VmZDI2Yjk1MTE0ZC9kbWVzZy1xdWFudGFsLWl2YjQ0LTc0OjIw
MTQwNjIwMTUxNTM4Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMx
LTAyMDI0LWdmZTI5N2I0OjEKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0
MjgvZmUyOTdiNGQ2OTg3ZDA0ZThiMzg3OGIzZWU0N2VmZDI2Yjk1MTE0ZC9kbWVzZy1xdWFu
dGFsLWl2YjQ0LTg6MjAxNDA2MjAxNTE1NDU6eDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAx
NDI4OjMuMTYuMC1yYzEtMDIwMjQtZ2ZlMjk3YjQ6MQova2VybmVsL3g4Nl82NC1yYW5kY29u
ZmlnLXdhMC0wNjIwMTQyOC9mZTI5N2I0ZDY5ODdkMDRlOGIzODc4YjNlZTQ3ZWZkMjZiOTUx
MTRkL2RtZXNnLXF1YW50YWwtaXZiNDEtMTEzOjIwMTQwNjIwMTUxNjAzOng4Nl82NC1yYW5k
Y29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMxLTAyMDI0LWdmZTI5N2I0OjEKL2tlcm5l
bC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvZmUyOTdiNGQ2OTg3ZDA0ZThiMzg3
OGIzZWU0N2VmZDI2Yjk1MTE0ZC9kbWVzZy1xdWFudGFsLWl2YjQ0LTI6MjAxNDA2MjAxNTE1
NTk6eDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4OjMuMTYuMC1yYzEtMDIwMjQtZ2Zl
Mjk3YjQ6MQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC9mZTI5N2I0
ZDY5ODdkMDRlOGIzODc4YjNlZTQ3ZWZkMjZiOTUxMTRkL2RtZXNnLXF1YW50YWwtaXZiNDEt
NDI6MjAxNDA2MjAxNTE2MDg6eDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4OjMuMTYu
MC1yYzEtMDIwMjQtZ2ZlMjk3YjQ6MQowOjg6OCBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290
cwobWzE7MzVtMjAxNC0wNi0yMCAxNToxNjoxOCBSRVBFQVQgQ09VTlQ6IDIwICAjIC9jL2Jv
b3QtYmlzZWN0L2xpbnV4L29iai1iaXNlY3QvLnJlcGVhdBtbMG0KCmxpbmVhci1iaXNlY3Q6
IGJhZCBicmFuY2ggbWF5IGJlIGJyYW5jaCAnYWtwbS1jdXJyZW50L2N1cnJlbnQnCmxpbmVh
ci1iaXNlY3Q6IGhhbmRsZSBvdmVyIHRvIGdpdCBiaXNlY3QKbGluZWFyLWJpc2VjdDogZ2l0
IGJpc2VjdCBzdGFydCBmZTI5N2I0ZDY5ODdkMDRlOGIzODc4YjNlZTQ3ZWZkMjZiOTUxMTRk
IDcxZDI3M2ZhNzY5ZWEyMWYyNDIyYTE4NDgyZTAwMmEwN2FiOWY4ZjMgLS0KUHJldmlvdXMg
SEVBRCBwb3NpdGlvbiB3YXMgZmUyOTdiNC4uLiBNZXJnZSBicmFuY2ggJ2FrcG0tY3VycmVu
dC9jdXJyZW50JwpIRUFEIGlzIG5vdyBhdCBmY2IyMTMzLi4uIE1lcmdlICdqYmFybmVzL2Fz
eW5jLWZiLXByb2JlJyBpbnRvIGRldmVsLXJvYW0taTM4Ni0yMDE0MDUzMDAyMDEKQmlzZWN0
aW5nOiA5NSByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNyBz
dGVwcykKWzZiMTFkMDJlMjVjNzlhODk2MTk4M2E5NjZiN2ZhZmNkYzM2YzdhOTFdIHNsYWI6
IGRvIG5vdCBrZWVwIGZyZWUgb2JqZWN0cy9zbGFicyBvbiBkZWFkIG1lbWNnIGNhY2hlcwps
aW5lYXItYmlzZWN0OiBnaXQgYmlzZWN0IHJ1biAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRl
c3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4L29iai1iaXNlY3QKcnVu
bmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jv
b3QtYmlzZWN0L2xpbnV4L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVl
dWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC9uZXh0Om1hc3Rlcjo2YjEx
ZDAyZTI1Yzc5YTg5NjE5ODNhOTY2YjdmYWZjZGMzNmM3YTkxOmJpc2VjdC1saW51eAoKMjAx
NC0wNi0yMC0xNToxNjoyNSA2YjExZDAyZTI1Yzc5YTg5NjE5ODNhOTY2YjdmYWZjZGMzNmM3
YTkxIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxk
LXF1ZXVlL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC02YjExZDAyZTI1Yzc5YTg5
NjE5ODNhOTY2YjdmYWZjZGMzNmM3YTkxCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC94
ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvNmIxMWQwMmUyNWM3OWE4OTYxOTgzYTk2
NmI3ZmFmY2RjMzZjN2E5MQp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVz
dHMvYnVpbGQtcXVldWUveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LTZiMTFkMDJl
MjVjNzlhODk2MTk4M2E5NjZiN2ZhZmNkYzM2YzdhOTEKd2FpdGluZyBmb3IgY29tcGxldGlv
biBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlLy54ODZfNjQtcmFuZGNvbmZpZy13YTAt
MDYyMDE0MjgtNmIxMWQwMmUyNWM3OWE4OTYxOTgzYTk2NmI3ZmFmY2RjMzZjN2E5MQprZXJu
ZWw6IC9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LzZiMTFkMDJlMjVj
NzlhODk2MTk4M2E5NjZiN2ZhZmNkYzM2YzdhOTEvdm1saW51ei0zLjE2LjAtcmMxLTAwMjA4
LWc2YjExZDAyCgoyMDE0LTA2LTIwLTE1OjIzOjI1IGRldGVjdGluZyBib290IHN0YXRlIC4J
NAkyMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDQ3IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0
ZXIgdGhpcyAocm91Z2hseSA2IHN0ZXBzKQpbMTE3MDkyMTJiM2E1NDc5ZmNjNjNkZGEzMTYw
ZjRmNGIwMjUxZjkxNF0gbW0vdXRpbC5jOiBhZGQga3N0cmltZHVwKCkKcnVubmluZyAvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0
L2xpbnV4L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4
Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC9uZXh0Om1hc3RlcjoxMTcwOTIxMmIzYTU0
NzlmY2M2M2RkYTMxNjBmNGY0YjAyNTFmOTE0OmJpc2VjdC1saW51eAoKMjAxNC0wNi0yMC0x
NToyNDo1NSAxMTcwOTIxMmIzYTU0NzlmY2M2M2RkYTMxNjBmNGY0YjAyNTFmOTE0IGNvbXBp
bGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL3g4
Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC0xMTcwOTIxMmIzYTU0NzlmY2M2M2RkYTMx
NjBmNGY0YjAyNTFmOTE0CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC94ODZfNjQtcmFu
ZGNvbmZpZy13YTAtMDYyMDE0MjgvMTE3MDkyMTJiM2E1NDc5ZmNjNjNkZGEzMTYwZjRmNGIw
MjUxZjkxNAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQt
cXVldWUveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LTExNzA5MjEyYjNhNTQ3OWZj
YzYzZGRhMzE2MGY0ZjRiMDI1MWY5MTQKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1
aWxkLXRlc3RzL2J1aWxkLXF1ZXVlLy54ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjgt
MTE3MDkyMTJiM2E1NDc5ZmNjNjNkZGEzMTYwZjRmNGIwMjUxZjkxNAprZXJuZWw6IC9rZXJu
ZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LzExNzA5MjEyYjNhNTQ3OWZjYzYz
ZGRhMzE2MGY0ZjRiMDI1MWY5MTQvdm1saW51ei0zLjE2LjAtcmMxLTAwMjU2LWcxMTcwOTIx
CgoyMDE0LTA2LTIwLTE2OjAwOjU1IGRldGVjdGluZyBib290IHN0YXRlIC4uLiBURVNUIEZB
SUxVUkUKWyAgICAyLjcyNjQ3N10gZGVidWc6IHVubWFwcGluZyBpbml0IFttZW0gMHhmZmZm
ODgwMDAxYTNiMDAwLTB4ZmZmZjg4MDAwMWJmZmZmZl0KWyAgICAyLjcyNzY5Ml0gZGVidWc6
IHVubWFwcGluZyBpbml0IFttZW0gMHhmZmZmODgwMDAyMWFmMDAwLTB4ZmZmZjg4MDAwMjFm
ZmZmZl0KWyAgICAyLjczMTc5NF0gLS0tLS0tLS0tLS0tWyBjdXQgaGVyZSBdLS0tLS0tLS0t
LS0tClsgICAgMi43MzI2MDhdIFdBUk5JTkc6IENQVTogMCBQSUQ6IDEgYXQgL2tidWlsZC9z
cmMvY29uc3VtZXIva2VybmVsL3Jlc19jb3VudGVyLmM6MjggcmVzX2NvdW50ZXJfdW5jaGFy
Z2VfbG9ja2VkKzB4NDgvMHg3NCgpClsgICAgMi43MzMzNDldIENQVTogMCBQSUQ6IDEgQ29t
bTogaW5pdCBOb3QgdGFpbnRlZCAzLjE2LjAtcmMxLTAwMjU2LWcxMTcwOTIxICMyClsgICAg
Mi43MzMzNDldIEhhcmR3YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAx
LzIwMTEKWyAgICAyLjczMzM0OV0gIDAwMDAwMDAwMDAwMDAwMDAgZmZmZjg4MDAxMjA3M2M1
MCBmZmZmZmZmZjgxYTI0MDg5IGZmZmY4ODAwMTIwNzNjODgKWyAgICAyLjczMzM0OV0gIGZm
ZmZmZmZmODEwYmM4NDUgZmZmZmZmZmY4MTExZmJkZSAwMDAwMDAwMDAwMDAxMDAwIGZmZmY4
ODAwMTIwMGZhNTAKWyAgICAyLjczMzM0OV0gIDAwMDAwMDAwMDAwMDAwMDEgZmZmZjg4MDAx
MjAwZmEwMSBmZmZmODgwMDEyMDczYzk4IGZmZmZmZmZmODEwYmM5MmIKWyAgICAyLjczMzM0
OV0gQ2FsbCBUcmFjZToKWyAgICAyLjczMzM0OV0gIFs8ZmZmZmZmZmY4MWEyNDA4OT5dIGR1
bXBfc3RhY2srMHgxOS8weDFiClsgICAgMi43MzMzNDldICBbPGZmZmZmZmZmODEwYmM4NDU+
XSB3YXJuX3Nsb3dwYXRoX2NvbW1vbisweDczLzB4OGMKWyAgICAyLjczMzM0OV0gIFs8ZmZm
ZmZmZmY4MTExZmJkZT5dID8gcmVzX2NvdW50ZXJfdW5jaGFyZ2VfbG9ja2VkKzB4NDgvMHg3
NApbICAgIDIuNzMzMzQ5XSAgWzxmZmZmZmZmZjgxMGJjOTJiPl0gd2Fybl9zbG93cGF0aF9u
dWxsKzB4MWEvMHgxYwpbICAgIDIuNzMzMzQ5XSAgWzxmZmZmZmZmZjgxMTFmYmRlPl0gcmVz
X2NvdW50ZXJfdW5jaGFyZ2VfbG9ja2VkKzB4NDgvMHg3NApbICAgIDIuNzMzMzQ5XSAgWzxm
ZmZmZmZmZjgxMTFmZTE4Pl0gcmVzX2NvdW50ZXJfdW5jaGFyZ2VfdW50aWwrMHg0ZS8weGE5
ClsgICAgMi43MzMzNDldICBbPGZmZmZmZmZmODExMWZlODY+XSByZXNfY291bnRlcl91bmNo
YXJnZSsweDEzLzB4MTUKWyAgICAyLjczMzM0OV0gIFs8ZmZmZmZmZmY4MTE5NGIzMD5dIG1l
bV9jZ3JvdXBfdW5jaGFyZ2VfZW5kKzB4NzMvMHg4ZApbICAgIDIuNzMzMzQ5XSAgWzxmZmZm
ZmZmZjgxMTU3NDcwPl0gcmVsZWFzZV9wYWdlcysweDFmMi8weDIwZApbICAgIDIuNzMzMzQ5
XSAgWzxmZmZmZmZmZjgxMTZjZGJkPl0gdGxiX2ZsdXNoX21tdV9mcmVlKzB4MjgvMHg0Mwpb
ICAgIDIuNzMzMzQ5XSAgWzxmZmZmZmZmZjgxMTZkNzY4Pl0gdGxiX2ZsdXNoX21tdSsweDIw
LzB4MjMKWyAgICAyLjczMzM0OV0gIFs8ZmZmZmZmZmY4MTE2ZDc3Zj5dIHRsYl9maW5pc2hf
bW11KzB4MTQvMHgzOQpbICAgIDIuNzMzMzQ5XSAgWzxmZmZmZmZmZjgxMTczMjQ0Pl0gdW5t
YXBfcmVnaW9uKzB4Y2QvMHhkZgpbICAgIDIuNzMzMzQ5XSAgWzxmZmZmZmZmZjgxMTcyYzkx
Pl0gPyB2bWFfZ2FwX2NhbGxiYWNrc19wcm9wYWdhdGUrMHgxOC8weDMzClsgICAgMi43MzMz
NDldICBbPGZmZmZmZmZmODExNzRkNzQ+XSBkb19tdW5tYXArMHgyNTIvMHgyZTAKWyAgICAy
LjczMzM0OV0gIFs8ZmZmZmZmZmY4MTE3NGU0Nj5dIHZtX211bm1hcCsweDQ0LzB4NWMKWyAg
ICAyLjczMzM0OV0gIFs8ZmZmZmZmZmY4MTE3NGU4MT5dIFN5U19tdW5tYXArMHgyMy8weDI5
ClsgICAgMi43MzMzNDldICBbPGZmZmZmZmZmODFhMzFhMjc+XSBzeXN0ZW1fY2FsbF9mYXN0
cGF0aCsweDE2LzB4MWIKWyAgICAyLjczMzM0OV0gLS0tWyBlbmQgdHJhY2UgNmYwMDMzNGIz
YTU4ZDdkZSBdLS0tClsgICAgMi43NTkxNTddIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0t
LS0tLS0tLS0tLQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC8xMTcw
OTIxMmIzYTU0NzlmY2M2M2RkYTMxNjBmNGY0YjAyNTFmOTE0L2RtZXNnLXF1YW50YWwtaXZi
NDItMzoyMDE0MDYyMDE2MDIwNzp4ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4x
Ni4wLXJjMS0wMDI1Ni1nMTE3MDkyMToyCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2Ew
LTA2MjAxNDI4LzExNzA5MjEyYjNhNTQ3OWZjYzYzZGRhMzE2MGY0ZjRiMDI1MWY5MTQvZG1l
c2ctcXVhbnRhbC1pdmI0NC0xNjoyMDE0MDYyMDE2MDIxNjp4ODZfNjQtcmFuZGNvbmZpZy13
YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS0wMDI1Ni1nMTE3MDkyMToyCi9rZXJuZWwveDg2XzY0
LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LzExNzA5MjEyYjNhNTQ3OWZjYzYzZGRhMzE2MGY0
ZjRiMDI1MWY5MTQvZG1lc2cteW9jdG8taXZiNDItMTAyOjIwMTQwNjIwMTYwMjE5Ong4Nl82
NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMxLTAwMjU2LWcxMTcwOTIxOjIK
L2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvMTE3MDkyMTJiM2E1NDc5
ZmNjNjNkZGEzMTYwZjRmNGIwMjUxZjkxNC9kbWVzZy15b2N0by1pdmI0MS0xMjoyMDE0MDYy
MDE2MDIxODp4ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS0wMDI1
Ni1nMTE3MDkyMToyCjA6NDo0IGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzChtbMTszNW0y
MDE0LTA2LTIwIDE2OjAyOjI2IFJFUEVBVCBDT1VOVDogMjAgICMgL2MvYm9vdC1iaXNlY3Qv
bGludXgvb2JqLWJpc2VjdC8ucmVwZWF0G1swbQoKQmlzZWN0aW5nOiAyMyByZXZpc2lvbnMg
bGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNSBzdGVwcykKW2QwNzBiZDE3NWZj
Y2FhYjA2MTZkOGFlYzc1YWNiZGU0ODA1MzFmZWVdIG1tOiBtZW1jb250cm9sOiBjYXRjaCBy
b290IGJ5cGFzcyBpbiBtb3ZlIHByZWNoYXJnZQpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9i
aXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXgvb2JqLWJp
c2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25m
aWctd2EwLTA2MjAxNDI4L25leHQ6bWFzdGVyOmQwNzBiZDE3NWZjY2FhYjA2MTZkOGFlYzc1
YWNiZGU0ODA1MzFmZWU6YmlzZWN0LWxpbnV4CgoyMDE0LTA2LTIwLTE2OjAyOjI3IGQwNzBi
ZDE3NWZjY2FhYjA2MTZkOGFlYzc1YWNiZGU0ODA1MzFmZWUgY29tcGlsaW5nClF1ZXVlZCBi
dWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUveDg2XzY0LXJhbmRjb25m
aWctd2EwLTA2MjAxNDI4LWQwNzBiZDE3NWZjY2FhYjA2MTZkOGFlYzc1YWNiZGU0ODA1MzFm
ZWUKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0w
NjIwMTQyOC9kMDcwYmQxNzVmY2NhYWIwNjE2ZDhhZWM3NWFjYmRlNDgwNTMxZmVlCndhaXRp
bmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS94ODZfNjQt
cmFuZGNvbmZpZy13YTAtMDYyMDE0MjgtZDA3MGJkMTc1ZmNjYWFiMDYxNmQ4YWVjNzVhY2Jk
ZTQ4MDUzMWZlZQp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVp
bGQtcXVldWUvLng4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC1kMDcwYmQxNzVmY2Nh
YWIwNjE2ZDhhZWM3NWFjYmRlNDgwNTMxZmVlCmtlcm5lbDogL2tlcm5lbC94ODZfNjQtcmFu
ZGNvbmZpZy13YTAtMDYyMDE0MjgvZDA3MGJkMTc1ZmNjYWFiMDYxNmQ4YWVjNzVhY2JkZTQ4
MDUzMWZlZS92bWxpbnV6LTMuMTYuMC1yYzEtMDAyMzItZ2QwNzBiZDEKCjIwMTQtMDYtMjAt
MTY6MTA6MjcgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4JMjAgU1VDQ0VTUwoKQmlzZWN0aW5n
OiAxMSByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNCBzdGVw
cykKW2U3N2Y0YzMyN2M3YWExOWQyYzllYTI4ZWJlYjNhNzE2NmRiNDE4YWRdIG02OGs6IGNh
bGwgZmluZF92bWEgd2l0aCB0aGUgbW1hcF9zZW0gaGVsZCBpbiBzeXNfY2FjaGVmbHVzaCgp
CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAv
Yy9ib290LWJpc2VjdC9saW51eC9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVu
LXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvbmV4dDptYXN0ZXI6
ZTc3ZjRjMzI3YzdhYTE5ZDJjOWVhMjhlYmViM2E3MTY2ZGI0MThhZDpiaXNlY3QtbGludXgK
CjIwMTQtMDYtMjAtMTY6MTE6NTcgZTc3ZjRjMzI3YzdhYTE5ZDJjOWVhMjhlYmViM2E3MTY2
ZGI0MThhZCBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9i
dWlsZC1xdWV1ZS94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgtZTc3ZjRjMzI3Yzdh
YTE5ZDJjOWVhMjhlYmViM2E3MTY2ZGI0MThhZApDaGVjayBmb3Iga2VybmVsIGluIC9rZXJu
ZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4L2U3N2Y0YzMyN2M3YWExOWQyYzll
YTI4ZWJlYjNhNzE2NmRiNDE4YWQKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxk
LXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC1lNzdm
NGMzMjdjN2FhMTlkMmM5ZWEyOGViZWIzYTcxNjZkYjQxOGFkCndhaXRpbmcgZm9yIGNvbXBs
ZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS8ueDg2XzY0LXJhbmRjb25maWct
d2EwLTA2MjAxNDI4LWU3N2Y0YzMyN2M3YWExOWQyYzllYTI4ZWJlYjNhNzE2NmRiNDE4YWQK
a2VybmVsOiAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC9lNzdmNGMz
MjdjN2FhMTlkMmM5ZWEyOGViZWIzYTcxNjZkYjQxOGFkL3ZtbGludXotMy4xNi4wLXJjMS0w
MDI0NC1nZTc3ZjRjMwoKMjAxNC0wNi0yMC0xNjoyNTo1NyBkZXRlY3RpbmcgYm9vdCBzdGF0
ZSAuLi4gVEVTVCBGQUlMVVJFClsgICAgMi43NDIwMjBdIGRlYnVnOiB1bm1hcHBpbmcgaW5p
dCBbbWVtIDB4ZmZmZjg4MDAwMWEzYTAwMC0weGZmZmY4ODAwMDFiZmZmZmZdClsgICAgMi43
NDMyMTddIGRlYnVnOiB1bm1hcHBpbmcgaW5pdCBbbWVtIDB4ZmZmZjg4MDAwMjFhZDAwMC0w
eGZmZmY4ODAwMDIxZmZmZmZdClsgICAgMi43NDc0OTRdIC0tLS0tLS0tLS0tLVsgY3V0IGhl
cmUgXS0tLS0tLS0tLS0tLQpbICAgIDIuNzQ4MzAxXSBXQVJOSU5HOiBDUFU6IDAgUElEOiAx
IGF0IC9rYnVpbGQvc3JjL3Ntb2tlL2tlcm5lbC9yZXNfY291bnRlci5jOjI4IHJlc19jb3Vu
dGVyX3VuY2hhcmdlX2xvY2tlZCsweDQ4LzB4NzQoKQpbICAgIDIuNzQ5OTY0XSBDUFU6IDAg
UElEOiAxIENvbW06IGluaXQgTm90IHRhaW50ZWQgMy4xNi4wLXJjMS0wMDI0NC1nZTc3ZjRj
MyAjMQpbICAgIDIuNzUwMDE4XSBIYXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBC
b2NocyAwMS8wMS8yMDExClsgICAgMi43NTAwMThdICAwMDAwMDAwMDAwMDAwMDAwIGZmZmY4
ODAwMTIwNzNjNTAgZmZmZmZmZmY4MWEyM2JkZCBmZmZmODgwMDEyMDczYzg4ClsgICAgMi43
NTAwMThdICBmZmZmZmZmZjgxMGJjNzY1IGZmZmZmZmZmODExMWZhYzggMDAwMDAwMDAwMDAw
MTAwMCBmZmZmODgwMDEyMDBmYTUwClsgICAgMi43NTAwMThdICAwMDAwMDAwMDAwMDAwMDAx
IGZmZmY4ODAwMTIwMGZhMDEgZmZmZjg4MDAxMjA3M2M5OCBmZmZmZmZmZjgxMGJjODRiClsg
ICAgMi43NTAwMThdIENhbGwgVHJhY2U6ClsgICAgMi43NTAwMThdICBbPGZmZmZmZmZmODFh
MjNiZGQ+XSBkdW1wX3N0YWNrKzB4MTkvMHgxYgpbICAgIDIuNzUwMDE4XSAgWzxmZmZmZmZm
ZjgxMGJjNzY1Pl0gd2Fybl9zbG93cGF0aF9jb21tb24rMHg3My8weDhjClsgICAgMi43NTAw
MThdICBbPGZmZmZmZmZmODExMWZhYzg+XSA/IHJlc19jb3VudGVyX3VuY2hhcmdlX2xvY2tl
ZCsweDQ4LzB4NzQKWyAgICAyLjc1MDAxOF0gIFs8ZmZmZmZmZmY4MTBiYzg0Yj5dIHdhcm5f
c2xvd3BhdGhfbnVsbCsweDFhLzB4MWMKWyAgICAyLjc1MDAxOF0gIFs8ZmZmZmZmZmY4MTEx
ZmFjOD5dIHJlc19jb3VudGVyX3VuY2hhcmdlX2xvY2tlZCsweDQ4LzB4NzQKWyAgICAyLjc1
MDAxOF0gIFs8ZmZmZmZmZmY4MTExZmQwMj5dIHJlc19jb3VudGVyX3VuY2hhcmdlX3VudGls
KzB4NGUvMHhhOQpbICAgIDIuNzUwMDE4XSAgWzxmZmZmZmZmZjgxMTFmZDcwPl0gcmVzX2Nv
dW50ZXJfdW5jaGFyZ2UrMHgxMy8weDE1ClsgICAgMi43NTAwMThdICBbPGZmZmZmZmZmODEx
OTQ5OWM+XSBtZW1fY2dyb3VwX3VuY2hhcmdlX2VuZCsweDczLzB4OGQKWyAgICAyLjc1MDAx
OF0gIFs8ZmZmZmZmZmY4MTE1NzM1ZT5dIHJlbGVhc2VfcGFnZXMrMHgxZjIvMHgyMGQKWyAg
ICAyLjc1MDAxOF0gIFs8ZmZmZmZmZmY4MTE2Y2MzYT5dIHRsYl9mbHVzaF9tbXVfZnJlZSsw
eDI4LzB4NDMKWyAgICAyLjc1MDAxOF0gIFs8ZmZmZmZmZmY4MTE2ZDVlNT5dIHRsYl9mbHVz
aF9tbXUrMHgyMC8weDIzClsgICAgMi43NTAwMThdICBbPGZmZmZmZmZmODExNmQ1ZmM+XSB0
bGJfZmluaXNoX21tdSsweDE0LzB4MzkKWyAgICAyLjc1MDAxOF0gIFs8ZmZmZmZmZmY4MTE3
MzBjMT5dIHVubWFwX3JlZ2lvbisweGNkLzB4ZGYKWyAgICAyLjc1MDAxOF0gIFs8ZmZmZmZm
ZmY4MTE3MmIwZT5dID8gdm1hX2dhcF9jYWxsYmFja3NfcHJvcGFnYXRlKzB4MTgvMHgzMwpb
ICAgIDIuNzUwMDE4XSAgWzxmZmZmZmZmZjgxMTc0YmYxPl0gZG9fbXVubWFwKzB4MjUyLzB4
MmUwClsgICAgMi43NTAwMThdICBbPGZmZmZmZmZmODExNzRjYzM+XSB2bV9tdW5tYXArMHg0
NC8weDVjClsgICAgMi43NTAwMThdICBbPGZmZmZmZmZmODExNzRjZmU+XSBTeVNfbXVubWFw
KzB4MjMvMHgyOQpbICAgIDIuNzUwMDE4XSAgWzxmZmZmZmZmZjgxYTMxNWE3Pl0gc3lzdGVt
X2NhbGxfZmFzdHBhdGgrMHgxNi8weDFiClsgICAgMi43NTAwMThdIC0tLVsgZW5kIHRyYWNl
IGQyZDMyZDRlMjY2NTUwZDEgXS0tLQpbICAgIDIuNzc0ODk2XSAtLS0tLS0tLS0tLS1bIGN1
dCBoZXJlIF0tLS0tLS0tLS0tLS0KL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYy
MDE0MjgvZTc3ZjRjMzI3YzdhYTE5ZDJjOWVhMjhlYmViM2E3MTY2ZGI0MThhZC9kbWVzZy1x
dWFudGFsLWl2YjQxLTU0OjIwMTQwNjIwMTYyNzA1Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0w
NjIwMTQyODozLjE2LjAtcmMxLTAwMjQ0LWdlNzdmNGMzOjEKL2tlcm5lbC94ODZfNjQtcmFu
ZGNvbmZpZy13YTAtMDYyMDE0MjgvZTc3ZjRjMzI3YzdhYTE5ZDJjOWVhMjhlYmViM2E3MTY2
ZGI0MThhZC9kbWVzZy1xdWFudGFsLWl2YjQxLTU1OjIwMTQwNjIwMTYyNzA2Ong4Nl82NC1y
YW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMxLTAwMjQ0LWdlNzdmNGMzOjEKL2tl
cm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvZTc3ZjRjMzI3YzdhYTE5ZDJj
OWVhMjhlYmViM2E3MTY2ZGI0MThhZC9kbWVzZy1xdWFudGFsLWl2YjQxLTYzOjIwMTQwNjIw
MTYyNzA0Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMxLTAwMjQ0
LWdlNzdmNGMzOjEKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvZTc3
ZjRjMzI3YzdhYTE5ZDJjOWVhMjhlYmViM2E3MTY2ZGI0MThhZC9kbWVzZy1xdWFudGFsLWl2
YjQyLTU5OjIwMTQwNjIwMTYyNzA4Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODoz
LjE2LjAtcmMxLTAwMjQ0LWdlNzdmNGMzOjEKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13
YTAtMDYyMDE0MjgvZTc3ZjRjMzI3YzdhYTE5ZDJjOWVhMjhlYmViM2E3MTY2ZGI0MThhZC9k
bWVzZy1xdWFudGFsLWl2YjQyLTk6MjAxNDA2MjAxNjI3MTg6eDg2XzY0LXJhbmRjb25maWct
d2EwLTA2MjAxNDI4OjMuMTYuMC1yYzEtMDAyNDQtZ2U3N2Y0YzM6MQova2VybmVsL3g4Nl82
NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC9lNzdmNGMzMjdjN2FhMTlkMmM5ZWEyOGViZWIz
YTcxNjZkYjQxOGFkL2RtZXNnLXF1YW50YWwtaXZiNDQtMTExOjIwMTQwNjIwMTYyNzE1Ong4
Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMxLTAwMjQ0LWdlNzdmNGMz
OjEKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvZTc3ZjRjMzI3Yzdh
YTE5ZDJjOWVhMjhlYmViM2E3MTY2ZGI0MThhZC9kbWVzZy1xdWFudGFsLWl2YjQ0LTEyMjoy
MDE0MDYyMDE2MjcxNjp4ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJj
MS0wMDI0NC1nZTc3ZjRjMzoxCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAx
NDI4L2U3N2Y0YzMyN2M3YWExOWQyYzllYTI4ZWJlYjNhNzE2NmRiNDE4YWQvZG1lc2ctcXVh
bnRhbC1pdmI0NC00MjoyMDE0MDYyMDE2MjcxODp4ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYy
MDE0Mjg6My4xNi4wLXJjMS0wMDI0NC1nZTc3ZjRjMzoxCi9rZXJuZWwveDg2XzY0LXJhbmRj
b25maWctd2EwLTA2MjAxNDI4L2U3N2Y0YzMyN2M3YWExOWQyYzllYTI4ZWJlYjNhNzE2NmRi
NDE4YWQvZG1lc2ctcXVhbnRhbC1pdmI0NC01ODoyMDE0MDYyMDE2MjcxNjp4ODZfNjQtcmFu
ZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS0wMDI0NC1nZTc3ZjRjMzoxCi9rZXJu
ZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4L2U3N2Y0YzMyN2M3YWExOWQyYzll
YTI4ZWJlYjNhNzE2NmRiNDE4YWQvZG1lc2ctcXVhbnRhbC1pdmI0NC03MzoyMDE0MDYyMDE2
MjcxNTp4ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS0wMDI0NC1n
ZTc3ZjRjMzoxCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4L2U3N2Y0
YzMyN2M3YWExOWQyYzllYTI4ZWJlYjNhNzE2NmRiNDE4YWQvZG1lc2ctcXVhbnRhbC1pdmI0
NC03NzoyMDE0MDYyMDE2MjcxNjp4ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4x
Ni4wLXJjMS0wMDI0NC1nZTc3ZjRjMzoxCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2Ew
LTA2MjAxNDI4L2U3N2Y0YzMyN2M3YWExOWQyYzllYTI4ZWJlYjNhNzE2NmRiNDE4YWQvZG1l
c2ctcXVhbnRhbC1pdmI0NC05ODoyMDE0MDYyMDE2MjcxNzp4ODZfNjQtcmFuZGNvbmZpZy13
YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS0wMDI0NC1nZTc3ZjRjMzoxCjA6MTI6MTIgYWxsX2dv
b2Q6YmFkOmFsbF9iYWQgYm9vdHMKG1sxOzM1bTIwMTQtMDYtMjAgMTY6Mjc6MjggUkVQRUFU
IENPVU5UOiAyMCAgIyAvYy9ib290LWJpc2VjdC9saW51eC9vYmotYmlzZWN0Ly5yZXBlYXQb
WzBtCgpCaXNlY3Rpbmc6IDUgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChy
b3VnaGx5IDMgc3RlcHMpCltkZGM1YmZlYzUwMWY0YmUzZjllODkwODRjMmRiMjcwYzBjNDVk
MWQ2XSBtbTogbWVtY29udHJvbDogcmV3cml0ZSB1bmNoYXJnZSBBUEkKcnVubmluZyAvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0
L2xpbnV4L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4
Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC9uZXh0Om1hc3RlcjpkZGM1YmZlYzUwMWY0
YmUzZjllODkwODRjMmRiMjcwYzBjNDVkMWQ2OmJpc2VjdC1saW51eAoKMjAxNC0wNi0yMC0x
NjoyNzoyOSBkZGM1YmZlYzUwMWY0YmUzZjllODkwODRjMmRiMjcwYzBjNDVkMWQ2IGNvbXBp
bGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL3g4
Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC1kZGM1YmZlYzUwMWY0YmUzZjllODkwODRj
MmRiMjcwYzBjNDVkMWQ2CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC94ODZfNjQtcmFu
ZGNvbmZpZy13YTAtMDYyMDE0MjgvZGRjNWJmZWM1MDFmNGJlM2Y5ZTg5MDg0YzJkYjI3MGMw
YzQ1ZDFkNgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQt
cXVldWUveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LWRkYzViZmVjNTAxZjRiZTNm
OWU4OTA4NGMyZGIyNzBjMGM0NWQxZDYKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1
aWxkLXRlc3RzL2J1aWxkLXF1ZXVlLy54ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjgt
ZGRjNWJmZWM1MDFmNGJlM2Y5ZTg5MDg0YzJkYjI3MGMwYzQ1ZDFkNgprZXJuZWw6IC9rZXJu
ZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4L2RkYzViZmVjNTAxZjRiZTNmOWU4
OTA4NGMyZGIyNzBjMGM0NWQxZDYvdm1saW51ei0zLjE2LjAtcmMxLTAwMjM4LWdkZGM1YmZl
CgoyMDE0LTA2LTIwLTE2OjQ4OjI5IGRldGVjdGluZyBib290IHN0YXRlIC4gVEVTVCBGQUlM
VVJFClsgICAgMi43NzQ1MTFdIGRlYnVnOiB1bm1hcHBpbmcgaW5pdCBbbWVtIDB4ZmZmZjg4
MDAwMWEzYTAwMC0weGZmZmY4ODAwMDFiZmZmZmZdClsgICAgMi43NzU3NjBdIGRlYnVnOiB1
bm1hcHBpbmcgaW5pdCBbbWVtIDB4ZmZmZjg4MDAwMjFhZDAwMC0weGZmZmY4ODAwMDIxZmZm
ZmZdClsgICAgMi43ODAyNTddIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0t
LQpbICAgIDIuNzgxMTEzXSBXQVJOSU5HOiBDUFU6IDAgUElEOiAxIGF0IC9rYnVpbGQvc3Jj
L3Ntb2tlL2tlcm5lbC9yZXNfY291bnRlci5jOjI4IHJlc19jb3VudGVyX3VuY2hhcmdlX2xv
Y2tlZCsweDQ4LzB4NzQoKQpbICAgIDIuNzgyODY4XSBDUFU6IDAgUElEOiAxIENvbW06IGlu
aXQgTm90IHRhaW50ZWQgMy4xNi4wLXJjMS0wMDIzOC1nZGRjNWJmZSAjMQpbICAgIDIuNzgz
MzQ1XSBIYXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAwMS8wMS8yMDEx
ClsgICAgMi43ODMzNDVdICAwMDAwMDAwMDAwMDAwMDAwIGZmZmY4ODAwMTIwNzNjNTAgZmZm
ZmZmZmY4MWEyM2I5ZCBmZmZmODgwMDEyMDczYzg4ClsgICAgMi43ODMzNDVdICBmZmZmZmZm
ZjgxMGJjNzY1IGZmZmZmZmZmODExMWZhYzggMDAwMDAwMDAwMDAwMTAwMCBmZmZmODgwMDEy
MDBmYTUwClsgICAgMi43ODMzNDVdICAwMDAwMDAwMDAwMDAwMDAxIGZmZmY4ODAwMTIwMGZh
MDEgZmZmZjg4MDAxMjA3M2M5OCBmZmZmZmZmZjgxMGJjODRiClsgICAgMi43ODMzNDVdIENh
bGwgVHJhY2U6ClsgICAgMi43ODMzNDVdICBbPGZmZmZmZmZmODFhMjNiOWQ+XSBkdW1wX3N0
YWNrKzB4MTkvMHgxYgpbICAgIDIuNzgzMzQ1XSAgWzxmZmZmZmZmZjgxMGJjNzY1Pl0gd2Fy
bl9zbG93cGF0aF9jb21tb24rMHg3My8weDhjClsgICAgMi43ODMzNDVdICBbPGZmZmZmZmZm
ODExMWZhYzg+XSA/IHJlc19jb3VudGVyX3VuY2hhcmdlX2xvY2tlZCsweDQ4LzB4NzQKWyAg
ICAyLjc4MzM0NV0gIFs8ZmZmZmZmZmY4MTBiYzg0Yj5dIHdhcm5fc2xvd3BhdGhfbnVsbCsw
eDFhLzB4MWMKWyAgICAyLjc4MzM0NV0gIFs8ZmZmZmZmZmY4MTExZmFjOD5dIHJlc19jb3Vu
dGVyX3VuY2hhcmdlX2xvY2tlZCsweDQ4LzB4NzQKWyAgICAyLjc4MzM0NV0gIFs8ZmZmZmZm
ZmY4MTExZmQwMj5dIHJlc19jb3VudGVyX3VuY2hhcmdlX3VudGlsKzB4NGUvMHhhOQpbICAg
IDIuNzgzMzQ1XSAgWzxmZmZmZmZmZjgxMTFmZDcwPl0gcmVzX2NvdW50ZXJfdW5jaGFyZ2Ur
MHgxMy8weDE1ClsgICAgMi43ODMzNDVdICBbPGZmZmZmZmZmODExOTQ5OWM+XSBtZW1fY2dy
b3VwX3VuY2hhcmdlX2VuZCsweDczLzB4OGQKWyAgICAyLjc4MzM0NV0gIFs8ZmZmZmZmZmY4
MTE1NzM1ZT5dIHJlbGVhc2VfcGFnZXMrMHgxZjIvMHgyMGQKWyAgICAyLjc4MzM0NV0gIFs8
ZmZmZmZmZmY4MTE2Y2MzYT5dIHRsYl9mbHVzaF9tbXVfZnJlZSsweDI4LzB4NDMKWyAgICAy
Ljc4MzM0NV0gIFs8ZmZmZmZmZmY4MTE2ZDVlNT5dIHRsYl9mbHVzaF9tbXUrMHgyMC8weDIz
ClsgICAgMi43ODMzNDVdICBbPGZmZmZmZmZmODExNmQ1ZmM+XSB0bGJfZmluaXNoX21tdSsw
eDE0LzB4MzkKWyAgICAyLjc4MzM0NV0gIFs8ZmZmZmZmZmY4MTE3MzBjMT5dIHVubWFwX3Jl
Z2lvbisweGNkLzB4ZGYKWyAgICAyLjc4MzM0NV0gIFs8ZmZmZmZmZmY4MTE3MmIwZT5dID8g
dm1hX2dhcF9jYWxsYmFja3NfcHJvcGFnYXRlKzB4MTgvMHgzMwpbICAgIDIuNzgzMzQ1XSAg
WzxmZmZmZmZmZjgxMTc0YmYxPl0gZG9fbXVubWFwKzB4MjUyLzB4MmUwClsgICAgMi43ODMz
NDVdICBbPGZmZmZmZmZmODExNzRjYzM+XSB2bV9tdW5tYXArMHg0NC8weDVjClsgICAgMi43
ODMzNDVdICBbPGZmZmZmZmZmODExNzRjZmU+XSBTeVNfbXVubWFwKzB4MjMvMHgyOQpbICAg
IDIuNzgzMzQ1XSAgWzxmZmZmZmZmZjgxYTMxNTY3Pl0gc3lzdGVtX2NhbGxfZmFzdHBhdGgr
MHgxNi8weDFiClsgICAgMi43ODMzNDVdIC0tLVsgZW5kIHRyYWNlIDkwZjk5ZmYyNjgwNzJi
ZDQgXS0tLQpbICAgIDIuODA4OTQ1XSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0t
LS0tLS0KL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvZGRjNWJmZWM1
MDFmNGJlM2Y5ZTg5MDg0YzJkYjI3MGMwYzQ1ZDFkNi9kbWVzZy1xdWFudGFsLWl2YjQ0LTEw
NToyMDE0MDYyMDE2NDg0NDp4ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4w
LXJjMS0wMDIzOC1nZGRjNWJmZToxCjA6MToxIGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3Rz
ChtbMTszNW0yMDE0LTA2LTIwIDE2OjQ5OjAwIFJFUEVBVCBDT1VOVDogMjAgICMgL2MvYm9v
dC1iaXNlY3QvbGludXgvb2JqLWJpc2VjdC8ucmVwZWF0G1swbQoKQmlzZWN0aW5nOiAyIHJl
dmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAyIHN0ZXBzKQpbNzM3
ZjViOTM2N2EyNTRhM2IzMTQ5YjNhYmFlNjU0NzBmNWVkOTQxZV0gbW06IG1lbWNvbnRyb2w6
IGRvIG5vdCBhY3F1aXJlIHBhZ2VfY2dyb3VwIGxvY2sgZm9yIGttZW0gcGFnZXMKcnVubmlu
ZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3Qt
YmlzZWN0L2xpbnV4L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUv
a3ZtL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC9uZXh0Om1hc3Rlcjo3MzdmNWI5
MzY3YTI1NGEzYjMxNDliM2FiYWU2NTQ3MGY1ZWQ5NDFlOmJpc2VjdC1saW51eAoKMjAxNC0w
Ni0yMC0xNjo0OTowMCA3MzdmNWI5MzY3YTI1NGEzYjMxNDliM2FiYWU2NTQ3MGY1ZWQ5NDFl
IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1
ZXVlL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC03MzdmNWI5MzY3YTI1NGEzYjMx
NDliM2FiYWU2NTQ3MGY1ZWQ5NDFlCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC94ODZf
NjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvNzM3ZjViOTM2N2EyNTRhM2IzMTQ5YjNhYmFl
NjU0NzBmNWVkOTQxZQp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMv
YnVpbGQtcXVldWUveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LTczN2Y1YjkzNjdh
MjU0YTNiMzE0OWIzYWJhZTY1NDcwZjVlZDk0MWUKd2FpdGluZyBmb3IgY29tcGxldGlvbiBv
ZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlLy54ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYy
MDE0MjgtNzM3ZjViOTM2N2EyNTRhM2IzMTQ5YjNhYmFlNjU0NzBmNWVkOTQxZQprZXJuZWw6
IC9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LzczN2Y1YjkzNjdhMjU0
YTNiMzE0OWIzYWJhZTY1NDcwZjVlZDk0MWUvdm1saW51ei0zLjE2LjAtcmMxLTAwMjM1LWc3
MzdmNWI5CgoyMDE0LTA2LTIwLTE3OjA4OjAwIGRldGVjdGluZyBib290IHN0YXRlIC4uCTE3
CTIwIFNVQ0NFU1MKCkJpc2VjdGluZzogMCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVy
IHRoaXMgKHJvdWdobHkgMSBzdGVwKQpbNWI2NDc2MjBjNmNhZTE0Y2MyNzc4MmMzNDkxYzJk
YTBmMWNmMjQ1Y10gbW0tbWVtY29udHJvbC1yZXdyaXRlLWNoYXJnZS1hcGktZml4CnJ1bm5p
bmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290
LWJpc2VjdC9saW51eC9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVl
L2t2bS94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvbmV4dDptYXN0ZXI6NWI2NDc2
MjBjNmNhZTE0Y2MyNzc4MmMzNDkxYzJkYTBmMWNmMjQ1YzpiaXNlY3QtbGludXgKCjIwMTQt
MDYtMjAtMTc6MTA6MDEgNWI2NDc2MjBjNmNhZTE0Y2MyNzc4MmMzNDkxYzJkYTBmMWNmMjQ1
YyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1x
dWV1ZS94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgtNWI2NDc2MjBjNmNhZTE0Y2My
Nzc4MmMzNDkxYzJkYTBmMWNmMjQ1YwpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwveDg2
XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LzViNjQ3NjIwYzZjYWUxNGNjMjc3ODJjMzQ5
MWMyZGEwZjFjZjI0NWMKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3Rz
L2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC01YjY0NzYyMGM2
Y2FlMTRjYzI3NzgyYzM0OTFjMmRhMGYxY2YyNDVjCndhaXRpbmcgZm9yIGNvbXBsZXRpb24g
b2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS8ueDg2XzY0LXJhbmRjb25maWctd2EwLTA2
MjAxNDI4LTViNjQ3NjIwYzZjYWUxNGNjMjc3ODJjMzQ5MWMyZGEwZjFjZjI0NWMKa2VybmVs
OiAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC81YjY0NzYyMGM2Y2Fl
MTRjYzI3NzgyYzM0OTFjMmRhMGYxY2YyNDVjL3ZtbGludXotMy4xNi4wLXJjMS0wMDIzNy1n
NWI2NDc2MgoKMjAxNC0wNi0yMC0xNzozODowMSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLgk4
CTE5CTIwIFNVQ0NFU1MKCmRkYzViZmVjNTAxZjRiZTNmOWU4OTA4NGMyZGIyNzBjMGM0NWQx
ZDYgaXMgdGhlIGZpcnN0IGJhZCBjb21taXQKY29tbWl0IGRkYzViZmVjNTAxZjRiZTNmOWU4
OTA4NGMyZGIyNzBjMGM0NWQxZDYKQXV0aG9yOiBKb2hhbm5lcyBXZWluZXIgPGhhbm5lc0Bj
bXB4Y2hnLm9yZz4KRGF0ZTogICBGcmkgSnVuIDIwIDEwOjI3OjU4IDIwMTQgKzEwMDAKCiAg
ICBtbTogbWVtY29udHJvbDogcmV3cml0ZSB1bmNoYXJnZSBBUEkKICAgIAogICAgVGhlIG1l
bWNnIHVuY2hhcmdpbmcgY29kZSB0aGF0IGlzIGludm9sdmVkIHRvd2FyZHMgdGhlIGVuZCBv
ZiBhIHBhZ2UncwogICAgbGlmZXRpbWUgLSB0cnVuY2F0aW9uLCByZWNsYWltLCBzd2Fwb3V0
LCBtaWdyYXRpb24gLSBpcyBpbXByZXNzaXZlbHkKICAgIGNvbXBsaWNhdGVkIGFuZCBmcmFn
aWxlLgogICAgCiAgICBCZWNhdXNlIGFub255bW91cyBhbmQgZmlsZSBwYWdlcyB3ZXJlIGFs
d2F5cyBjaGFyZ2VkIGJlZm9yZSB0aGV5IGhhZCB0aGVpcgogICAgcGFnZS0+bWFwcGluZyBl
c3RhYmxpc2hlZCwgdW5jaGFyZ2VzIGhhZCB0byBoYXBwZW4gd2hlbiB0aGUgcGFnZSB0eXBl
CiAgICBjb3VsZCBzdGlsbCBiZSBrbm93biBmcm9tIHRoZSBjb250ZXh0OyBhcyBpbiB1bm1h
cCBmb3IgYW5vbnltb3VzLCBwYWdlCiAgICBjYWNoZSByZW1vdmFsIGZvciBmaWxlIGFuZCBz
aG1lbSBwYWdlcywgYW5kIHN3YXAgY2FjaGUgdHJ1bmNhdGlvbiBmb3Igc3dhcAogICAgcGFn
ZXMuICBIb3dldmVyLCB0aGVzZSBvcGVyYXRpb25zIGhhcHBlbiB3ZWxsIGJlZm9yZSB0aGUg
cGFnZSBpcyBhY3R1YWxseQogICAgZnJlZWQsIGFuZCBzbyBhIGxvdCBvZiBzeW5jaHJvbml6
YXRpb24gaXMgbmVjZXNzYXJ5OgogICAgCiAgICAtIENoYXJnaW5nLCB1bmNoYXJnaW5nLCBw
YWdlIG1pZ3JhdGlvbiwgYW5kIGNoYXJnZSBtaWdyYXRpb24gYWxsIG5lZWQKICAgICAgdG8g
dGFrZSBhIHBlci1wYWdlIGJpdCBzcGlubG9jayBhcyB0aGV5IGNvdWxkIHJhY2Ugd2l0aCB1
bmNoYXJnaW5nLgogICAgCiAgICAtIFN3YXAgY2FjaGUgdHJ1bmNhdGlvbiBoYXBwZW5zIGR1
cmluZyBib3RoIHN3YXAtaW4gYW5kIHN3YXAtb3V0LCBhbmQKICAgICAgcG9zc2libHkgcmVw
ZWF0ZWRseSBiZWZvcmUgdGhlIHBhZ2UgaXMgYWN0dWFsbHkgZnJlZWQuICBUaGlzIG1lYW5z
CiAgICAgIHRoYXQgdGhlIG1lbWNnIHN3YXBvdXQgY29kZSBpcyBjYWxsZWQgZnJvbSBtYW55
IGNvbnRleHRzIHRoYXQgbWFrZQogICAgICBubyBzZW5zZSBhbmQgaXQgaGFzIHRvIGZpZ3Vy
ZSBvdXQgdGhlIGRpcmVjdGlvbiBmcm9tIHBhZ2Ugc3RhdGUgdG8KICAgICAgbWFrZSBzdXJl
IG1lbW9yeSBhbmQgbWVtb3J5K3N3YXAgYXJlIGFsd2F5cyBjb3JyZWN0bHkgY2hhcmdlZC4K
ICAgIAogICAgLSBPbiBwYWdlIG1pZ3JhdGlvbiwgdGhlIG9sZCBwYWdlIG1pZ2h0IGJlIHVu
bWFwcGVkIGJ1dCB0aGVuIHJldXNlZCwKICAgICAgc28gbWVtY2cgY29kZSBoYXMgdG8gcHJl
dmVudCB1bnRpbWVseSB1bmNoYXJnaW5nIGluIHRoYXQgY2FzZS4KICAgICAgQmVjYXVzZSB0
aGlzIGNvZGUgLSB3aGljaCBzaG91bGQgYmUgYSBzaW1wbGUgY2hhcmdlIHRyYW5zZmVyIC0g
aXMgc28KICAgICAgc3BlY2lhbC1jYXNlZCwgaXQgaXMgbm90IHJldXNhYmxlIGZvciByZXBs
YWNlX3BhZ2VfY2FjaGUoKS4KICAgIAogICAgQnV0IG5vdyB0aGF0IGNoYXJnZWQgcGFnZXMg
YWx3YXlzIGhhdmUgYSBwYWdlLT5tYXBwaW5nLCBpbnRyb2R1Y2UKICAgIG1lbV9jZ3JvdXBf
dW5jaGFyZ2UoKSwgd2hpY2ggaXMgY2FsbGVkIGFmdGVyIHRoZSBmaW5hbCBwdXRfcGFnZSgp
LCB3aGVuIHdlCiAgICBrbm93IGZvciBzdXJlIHRoYXQgbm9ib2R5IGlzIGxvb2tpbmcgYXQg
dGhlIHBhZ2UgYW55bW9yZS4KICAgIAogICAgRm9yIHBhZ2UgbWlncmF0aW9uLCBpbnRyb2R1
Y2UgbWVtX2Nncm91cF9taWdyYXRlKCksIHdoaWNoIGlzIGNhbGxlZCBhZnRlcgogICAgdGhl
IG1pZ3JhdGlvbiBpcyBzdWNjZXNzZnVsIGFuZCB0aGUgbmV3IHBhZ2UgaXMgZnVsbHkgcm1h
cHBlZC4gIEJlY2F1c2UKICAgIHRoZSBvbGQgcGFnZSBpcyBubyBsb25nZXIgdW5jaGFyZ2Vk
IGFmdGVyIG1pZ3JhdGlvbiwgcHJldmVudCBkb3VibGUKICAgIGNoYXJnZXMgYnkgZGVjb3Vw
bGluZyB0aGUgcGFnZSdzIG1lbWNnIGFzc29jaWF0aW9uIChQQ0dfVVNFRCBhbmQKICAgIHBj
LT5tZW1fY2dyb3VwKSBmcm9tIHRoZSBwYWdlIGhvbGRpbmcgYW4gYWN0dWFsIGNoYXJnZS4g
IFRoZSBuZXcgYml0cwogICAgUENHX01FTSBhbmQgUENHX01FTVNXIHJlcHJlc2VudCB0aGUg
cmVzcGVjdGl2ZSBjaGFyZ2VzIGFuZCBhcmUgdHJhbnNmZXJyZWQKICAgIHRvIHRoZSBuZXcg
cGFnZSBkdXJpbmcgbWlncmF0aW9uLgogICAgCiAgICBtZW1fY2dyb3VwX21pZ3JhdGUoKSBp
cyBzdWl0YWJsZSBmb3IgcmVwbGFjZV9wYWdlX2NhY2hlKCkgYXMgd2VsbCwgd2hpY2gKICAg
IGdldHMgcmlkIG9mIG1lbV9jZ3JvdXBfcmVwbGFjZV9wYWdlX2NhY2hlKCkuCiAgICAKICAg
IFN3YXAgYWNjb3VudGluZyBpcyBtYXNzaXZlbHkgc2ltcGxpZmllZDogYmVjYXVzZSB0aGUg
cGFnZSBpcyBubyBsb25nZXIKICAgIHVuY2hhcmdlZCBhcyBlYXJseSBhcyBzd2FwIGNhY2hl
IGRlbGV0aW9uLCBhIG5ldyBtZW1fY2dyb3VwX3N3YXBvdXQoKSBjYW4KICAgIHRyYW5zZmVy
IHRoZSBwYWdlJ3MgbWVtb3J5K3N3YXAgY2hhcmdlIChQQ0dfTUVNU1cpIHRvIHRoZSBzd2Fw
IGVudHJ5CiAgICBiZWZvcmUgdGhlIGZpbmFsIHB1dF9wYWdlKCkgaW4gcGFnZSByZWNsYWlt
LgogICAgCiAgICBGaW5hbGx5LCBwYWdlX2Nncm91cCBjaGFuZ2VzIGFyZSBub3cgcHJvdGVj
dGVkIGJ5IHdoYXRldmVyIHByb3RlY3Rpb24gdGhlCiAgICBwYWdlIGl0c2VsZiBvZmZlcnM6
IGFub255bW91cyBwYWdlcyBhcmUgY2hhcmdlZCB1bmRlciB0aGUgcGFnZSB0YWJsZSBsb2Nr
LAogICAgd2hlcmVhcyBwYWdlIGNhY2hlIGluc2VydGlvbnMsIHN3YXBpbiwgYW5kIG1pZ3Jh
dGlvbiBob2xkIHRoZSBwYWdlIGxvY2suCiAgICBVbmNoYXJnaW5nIGhhcHBlbnMgdW5kZXIg
ZnVsbCBleGNsdXNpb24gd2l0aCBubyBvdXRzdGFuZGluZyByZWZlcmVuY2VzLgogICAgQ2hh
cmdpbmcgYW5kIHVuY2hhcmdpbmcgYWxzbyBlbnN1cmUgdGhhdCB0aGUgcGFnZSBpcyBvZmYt
TFJVLCB3aGljaAogICAgc2VyaWFsaXplcyBhZ2FpbnN0IGNoYXJnZSBtaWdyYXRpb24uICBS
ZW1vdmUgdGhlIHZlcnkgY29zdGx5IHBhZ2VfY2dyb3VwCiAgICBsb2NrIGFuZCBzZXQgcGMt
PmZsYWdzIG5vbi1hdG9taWNhbGx5LgogICAgCiAgICBTaWduZWQtb2ZmLWJ5OiBKb2hhbm5l
cyBXZWluZXIgPGhhbm5lc0BjbXB4Y2hnLm9yZz4KICAgIENjOiBNaWNoYWwgSG9ja28gPG1o
b2Nrb0BzdXNlLmN6PgogICAgQ2M6IEh1Z2ggRGlja2lucyA8aHVnaGRAZ29vZ2xlLmNvbT4K
ICAgIENjOiBUZWp1biBIZW8gPHRqQGtlcm5lbC5vcmc+CiAgICBDYzogVmxhZGltaXIgRGF2
eWRvdiA8dmRhdnlkb3ZAcGFyYWxsZWxzLmNvbT4KICAgIFNpZ25lZC1vZmYtYnk6IEFuZHJl
dyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+Cgo6MDQwMDAwIDA0MDAwMCAx
OTkwYmFjOTdiNDFhNzM1MzBhNTc1MDJjN2VmNmU0YzljZDY4NTZlIDM5ODgyY2NkOTYzM2E0
YThlNzE0OTQ5YzViNzg5NjY4NGJjMjVlZjYgTQlEb2N1bWVudGF0aW9uCjowNDAwMDAgMDQw
MDAwIDc1ZGViYmY3NTZkY2I0N2ZkMjRhNjFjYTE2NzExYjQ0YjUwZWJlZWUgMGZmZDZiNzZi
YjFkZjQ4ZmZjYmU4ODZmODIyMTEyMWVkNDJlYzA2OCBNCWluY2x1ZGUKOjA0MDAwMCAwNDAw
MDAgNDVkOTE1NTc2ZWVjYjkxOTM0ZTE3NzAwOTFlMmNkNWM4NmYzZTAyZSBlNDYyMzdmYjJk
NzY0MjEzZTFjZDUzZmVjYzU2MDQ5NmU4ZjBhZTRhIE0JbW0KYmlzZWN0IHJ1biBzdWNjZXNz
CkhFQUQgaXMgbm93IGF0IDViNjQ3NjIuLi4gbW0tbWVtY29udHJvbC1yZXdyaXRlLWNoYXJn
ZS1hcGktZml4CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFu
ZGNvbmZpZy13YTAtMDYyMDE0MjgvbmV4dDptYXN0ZXI6NWI2NDc2MjBjNmNhZTE0Y2MyNzc4
MmMzNDkxYzJkYTBmMWNmMjQ1YzpiaXNlY3QtbGludXgKCjIwMTQtMDYtMjAtMTc6NDA6MzEg
NWI2NDc2MjBjNmNhZTE0Y2MyNzc4MmMzNDkxYzJkYTBmMWNmMjQ1YyByZXVzZSAva2VybmVs
L3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC81YjY0NzYyMGM2Y2FlMTRjYzI3Nzgy
YzM0OTFjMmRhMGYxY2YyNDVjL3ZtbGludXotMy4xNi4wLXJjMS0wMDIzNy1nNWI2NDc2MgoK
MjAxNC0wNi0yMC0xNzo0MDozMSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLgkyMgk0OAk2MCBT
VUNDRVNTCgpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdhcyA1YjY0NzYyLi4uIG1tLW1lbWNv
bnRyb2wtcmV3cml0ZS1jaGFyZ2UtYXBpLWZpeApIRUFEIGlzIG5vdyBhdCA2MzM1OTRiLi4u
IEFkZCBsaW51eC1uZXh0IHNwZWNpZmljIGZpbGVzIGZvciAyMDE0MDYyMApscyAtYSAva2J1
aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4
L25leHQ6bWFzdGVyOjYzMzU5NGJiMmQzODkwNzExYTg4Nzg5N2YyMDAzZjQxNzM1ZjBkZmE6
YmlzZWN0LWxpbnV4CiBURVNUIEZBSUxVUkUKWyAgICAyLjczOTE0Nl0gZGVidWc6IHVubWFw
cGluZyBpbml0IFttZW0gMHhmZmZmODgwMDAxYTQ0MDAwLTB4ZmZmZjg4MDAwMWJmZmZmZl0K
WyAgICAyLjc0MDQxNV0gZGVidWc6IHVubWFwcGluZyBpbml0IFttZW0gMHhmZmZmODgwMDAy
MWIzMDAwLTB4ZmZmZjg4MDAwMjFmZmZmZl0KWyAgICAyLjc0NDcxOF0gLS0tLS0tLS0tLS0t
WyBjdXQgaGVyZSBdLS0tLS0tLS0tLS0tClsgICAgMi43NDU1NDldIFdBUk5JTkc6IENQVTog
MCBQSUQ6IDEgYXQgL2tidWlsZC9zcmMvc21va2Uva2VybmVsL3Jlc19jb3VudGVyLmM6Mjgg
cmVzX2NvdW50ZXJfdW5jaGFyZ2VfbG9ja2VkKzB4NDgvMHg3NCgpClsgICAgMi43NDY2Nzdd
IENQVTogMCBQSUQ6IDEgQ29tbTogaW5pdCBOb3QgdGFpbnRlZCAzLjE2LjAtcmMxLW5leHQt
MjAxNDA2MjAgIzMKWyAgICAyLjc0NjY3N10gSGFyZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMs
IEJJT1MgQm9jaHMgMDEvMDEvMjAxMQpbICAgIDIuNzQ2Njc3XSAgMDAwMDAwMDAwMDAwMDAw
MCBmZmZmODgwMDEyMDczYzUwIGZmZmZmZmZmODFhMmQ2OGIgZmZmZjg4MDAxMjA3M2M4OApb
ICAgIDIuNzQ2Njc3XSAgZmZmZmZmZmY4MTBiY2RiMiBmZmZmZmZmZjgxMTIwMjEzIDAwMDAw
MDAwMDAwMDEwMDAgZmZmZjg4MDAxMjAwZmE1MApbICAgIDIuNzQ2Njc3XSAgMDAwMDAwMDAw
MDAwMDAwMSBmZmZmODgwMDEyMDBmYTAxIGZmZmY4ODAwMTIwNzNjOTggZmZmZmZmZmY4MTBi
Y2U5OApbICAgIDIuNzQ2Njc3XSBDYWxsIFRyYWNlOgpbICAgIDIuNzQ2Njc3XSAgWzxmZmZm
ZmZmZjgxYTJkNjhiPl0gZHVtcF9zdGFjaysweDE5LzB4MWIKWyAgICAyLjc0NjY3N10gIFs8
ZmZmZmZmZmY4MTBiY2RiMj5dIHdhcm5fc2xvd3BhdGhfY29tbW9uKzB4NzMvMHg4YwpbICAg
IDIuNzQ2Njc3XSAgWzxmZmZmZmZmZjgxMTIwMjEzPl0gPyByZXNfY291bnRlcl91bmNoYXJn
ZV9sb2NrZWQrMHg0OC8weDc0ClsgICAgMi43NDY2NzddICBbPGZmZmZmZmZmODEwYmNlOTg+
XSB3YXJuX3Nsb3dwYXRoX251bGwrMHgxYS8weDFjClsgICAgMi43NDY2NzddICBbPGZmZmZm
ZmZmODExMjAyMTM+XSByZXNfY291bnRlcl91bmNoYXJnZV9sb2NrZWQrMHg0OC8weDc0Clsg
ICAgMi43NDY2NzddICBbPGZmZmZmZmZmODExMjA0NGQ+XSByZXNfY291bnRlcl91bmNoYXJn
ZV91bnRpbCsweDRlLzB4YTkKWyAgICAyLjc0NjY3N10gIFs8ZmZmZmZmZmY4MTEyMDRiYj5d
IHJlc19jb3VudGVyX3VuY2hhcmdlKzB4MTMvMHgxNQpbICAgIDIuNzQ2Njc3XSAgWzxmZmZm
ZmZmZjgxMTk0ZWE3Pl0gbWVtX2Nncm91cF91bmNoYXJnZV9lbmQrMHg3My8weDhkClsgICAg
Mi43NDY2NzddICBbPGZmZmZmZmZmODExNTdiYzI+XSByZWxlYXNlX3BhZ2VzKzB4MWYyLzB4
MjBkClsgICAgMi43NDY2NzddICBbPGZmZmZmZmZmODExNmNlZDg+XSB0bGJfZmx1c2hfbW11
X2ZyZWUrMHgyOC8weDQzClsgICAgMi43NDY2NzddICBbPGZmZmZmZmZmODExNmQ4ODM+XSB0
bGJfZmx1c2hfbW11KzB4MjAvMHgyMwpbICAgIDIuNzQ2Njc3XSAgWzxmZmZmZmZmZjgxMTZk
ODlhPl0gdGxiX2ZpbmlzaF9tbXUrMHgxNC8weDM5ClsgICAgMi43NDY2NzddICBbPGZmZmZm
ZmZmODExNzMzNWY+XSB1bm1hcF9yZWdpb24rMHhjZC8weGRmClsgICAgMi43NDY2NzddICBb
PGZmZmZmZmZmODExNzJkYWM+XSA/IHZtYV9nYXBfY2FsbGJhY2tzX3Byb3BhZ2F0ZSsweDE4
LzB4MzMKWyAgICAyLjc0NjY3N10gIFs8ZmZmZmZmZmY4MTE3NGU4Zj5dIGRvX211bm1hcCsw
eDI1Mi8weDJlMApbICAgIDIuNzQ2Njc3XSAgWzxmZmZmZmZmZjgxMTc0ZjYxPl0gdm1fbXVu
bWFwKzB4NDQvMHg1YwpbICAgIDIuNzQ2Njc3XSAgWzxmZmZmZmZmZjgxMTc0ZjljPl0gU3lT
X211bm1hcCsweDIzLzB4MjkKWyAgICAyLjc0NjY3N10gIFs8ZmZmZmZmZmY4MWEzYjA2Nz5d
IHN5c3RlbV9jYWxsX2Zhc3RwYXRoKzB4MTYvMHgxYgpbICAgIDIuNzQ2Njc3XSAtLS1bIGVu
ZCB0cmFjZSBkM2QzMjBiN2VlOTU3NDNjIF0tLS0KWyAgICAyLjc3MjY0NF0gLS0tLS0tLS0t
LS0tWyBjdXQgaGVyZSBdLS0tLS0tLS0tLS0tCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWct
d2EwLTA2MjAxNDI4LzYzMzU5NGJiMmQzODkwNzExYTg4Nzg5N2YyMDAzZjQxNzM1ZjBkZmEv
ZG1lc2cteW9jdG8taXZiNDQtMzM6MjAxNDA2MjAxNDM4NTQ6eDg2XzY0LXJhbmRjb25maWct
d2EwLTA2MjAxNDI4OjMuMTYuMC1yYzEtbmV4dC0yMDE0MDYyMDozCi9rZXJuZWwveDg2XzY0
LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LzYzMzU5NGJiMmQzODkwNzExYTg4Nzg5N2YyMDAz
ZjQxNzM1ZjBkZmEvZG1lc2ctcXVhbnRhbC1pdmI0MS0xMDk6MjAxNDA2MjAxNDM4NDQ6eDg2
XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4OjMuMTYuMC1yYzEtbmV4dC0yMDE0MDYyMDoz
Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LzYzMzU5NGJiMmQzODkw
NzExYTg4Nzg5N2YyMDAzZjQxNzM1ZjBkZmEvZG1lc2cteW9jdG8taXZiNDEtMTExOjIwMTQw
NjIwMTQzODU0Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMxLW5l
eHQtMjAxNDA2MjA6Mwova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC82
MzM1OTRiYjJkMzg5MDcxMWE4ODc4OTdmMjAwM2Y0MTczNWYwZGZhL2RtZXNnLXF1YW50YWwt
aXZiNDEtMjI6MjAxNDA2MjAxNDM4MzE6eDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4
OjMuMTYuMC1yYzEtbmV4dC0yMDE0MDYyMDozCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWct
d2EwLTA2MjAxNDI4LzYzMzU5NGJiMmQzODkwNzExYTg4Nzg5N2YyMDAzZjQxNzM1ZjBkZmEv
ZG1lc2ctcXVhbnRhbC1pdmI0MS0zMjoyMDE0MDYyMDE0MzQzNDp4ODZfNjQtcmFuZGNvbmZp
Zy13YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS1uZXh0LTIwMTQwNjIwOjMKL2tlcm5lbC94ODZf
NjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvNjMzNTk0YmIyZDM4OTA3MTFhODg3ODk3ZjIw
MDNmNDE3MzVmMGRmYS9kbWVzZy1xdWFudGFsLWl2YjQyLTExMzoyMDE0MDYyMDE0MzQ0NDp4
ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS1uZXh0LTIwMTQwNjIw
OjMKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvNjMzNTk0YmIyZDM4
OTA3MTFhODg3ODk3ZjIwMDNmNDE3MzVmMGRmYS9kbWVzZy1xdWFudGFsLWl2YjQxLTEyMDoy
MDE0MDYyMDE0MzgzODp4ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJj
MS1uZXh0LTIwMTQwNjIwOjMKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0
MjgvNjMzNTk0YmIyZDM4OTA3MTFhODg3ODk3ZjIwMDNmNDE3MzVmMGRmYS9kbWVzZy1xdWFu
dGFsLWl2YjQxLTg5OjIwMTQwNjIwMTQzNDM0Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIw
MTQyODozLjE2LjAtcmMxLW5leHQtMjAxNDA2MjA6Mwova2VybmVsL3g4Nl82NC1yYW5kY29u
ZmlnLXdhMC0wNjIwMTQyOC82MzM1OTRiYjJkMzg5MDcxMWE4ODc4OTdmMjAwM2Y0MTczNWYw
ZGZhL2RtZXNnLXlvY3RvLWl2YjQ0LTEwMToyMDE0MDYyMDE0MzkwOTp4ODZfNjQtcmFuZGNv
bmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS1uZXh0LTIwMTQwNjIwOjMKL2tlcm5lbC94
ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvNjMzNTk0YmIyZDM4OTA3MTFhODg3ODk3
ZjIwMDNmNDE3MzVmMGRmYS9kbWVzZy1xdWFudGFsLWl2YjQ0LTE1OjIwMTQwNjIwMTQzODM4
Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMxLW5leHQtMjAxNDA2
MjA6Mwova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC82MzM1OTRiYjJk
Mzg5MDcxMWE4ODc4OTdmMjAwM2Y0MTczNWYwZGZhL2RtZXNnLXlvY3RvLWl2YjQxLTQ2OjIw
MTQwNjIwMTQzOTA5Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMx
LW5leHQtMjAxNDA2MjA6Mwova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQy
OC82MzM1OTRiYjJkMzg5MDcxMWE4ODc4OTdmMjAwM2Y0MTczNWYwZGZhL2RtZXNnLXF1YW50
YWwtaXZiNDQtNzg6MjAxNDA2MjAxNDM4MjM6eDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAx
NDI4OjMuMTYuMC1yYzEtbmV4dC0yMDE0MDYyMDozCi9rZXJuZWwveDg2XzY0LXJhbmRjb25m
aWctd2EwLTA2MjAxNDI4LzYzMzU5NGJiMmQzODkwNzExYTg4Nzg5N2YyMDAzZjQxNzM1ZjBk
ZmEvZG1lc2cteW9jdG8taXZiNDQtOTY6MjAxNDA2MjAxNDM4NTQ6eDg2XzY0LXJhbmRjb25m
aWctd2EwLTA2MjAxNDI4OjMuMTYuMC1yYzEtbmV4dC0yMDE0MDYyMDozCjA6MTM6MTMgYWxs
X2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKCkhFQUQgaXMgbm93IGF0IDYzMzU5NGIgQWRkIGxp
bnV4LW5leHQgc3BlY2lmaWMgZmlsZXMgZm9yIDIwMTQwNjIwCgo9PT09PT09PT0gdXBzdHJl
YW0gPT09PT09PT09ClByZXZpb3VzIEhFQUQgcG9zaXRpb24gd2FzIDYzMzU5NGIuLi4gQWRk
IGxpbnV4LW5leHQgc3BlY2lmaWMgZmlsZXMgZm9yIDIwMTQwNjIwCkhFQUQgaXMgbm93IGF0
IDNjOGZiNTAuLi4gTWVyZ2UgdGFnICdwbSthY3BpLTMuMTYtcmMyJyBvZiBnaXQ6Ly9naXQu
a2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvcmFmYWVsL2xpbnV4LXBtCmxz
IC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy13YTAt
MDYyMDE0MjgvbGludXM6bWFzdGVyOjNjOGZiNTA0NDU4MzNiOTNmNjliNmI3MDNhMjlhYWUz
NTIzY2FkMGM6YmlzZWN0LWxpbnV4CgoyMDE0LTA2LTIwLTE3OjQzOjA2IDNjOGZiNTA0NDU4
MzNiOTNmNjliNmI3MDNhMjlhYWUzNTIzY2FkMGMgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0
YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUveDg2XzY0LXJhbmRjb25maWctd2Ew
LTA2MjAxNDI4LTNjOGZiNTA0NDU4MzNiOTNmNjliNmI3MDNhMjlhYWUzNTIzY2FkMGMKQ2hl
Y2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQy
OC8zYzhmYjUwNDQ1ODMzYjkzZjY5YjZiNzAzYTI5YWFlMzUyM2NhZDBjCndhaXRpbmcgZm9y
IGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS94ODZfNjQtcmFuZGNv
bmZpZy13YTAtMDYyMDE0MjgtM2M4ZmI1MDQ0NTgzM2I5M2Y2OWI2YjcwM2EyOWFhZTM1MjNj
YWQwYwp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUvLng4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC0zYzhmYjUwNDQ1ODMzYjkzZjY5
YjZiNzAzYTI5YWFlMzUyM2NhZDBjCmtlcm5lbDogL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZp
Zy13YTAtMDYyMDE0MjgvM2M4ZmI1MDQ0NTgzM2I5M2Y2OWI2YjcwM2EyOWFhZTM1MjNjYWQw
Yy92bWxpbnV6LTMuMTYuMC1yYzEtMDAyMTUtZzNjOGZiNTAKCjIwMTQtMDYtMjAtMTg6MDQ6
MDYgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLgkzNwk1Ngk2MCBTVUNDRVNTCgoKPT09PT09PT09
IGxpbnV4LW5leHQgPT09PT09PT09ClByZXZpb3VzIEhFQUQgcG9zaXRpb24gd2FzIDNjOGZi
NTAuLi4gTWVyZ2UgdGFnICdwbSthY3BpLTMuMTYtcmMyJyBvZiBnaXQ6Ly9naXQua2VybmVs
Lm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvcmFmYWVsL2xpbnV4LXBtCkhFQUQgaXMg
bm93IGF0IDYzMzU5NGIuLi4gQWRkIGxpbnV4LW5leHQgc3BlY2lmaWMgZmlsZXMgZm9yIDIw
MTQwNjIwCmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNv
bmZpZy13YTAtMDYyMDE0MjgvbmV4dDptYXN0ZXI6NjMzNTk0YmIyZDM4OTA3MTFhODg3ODk3
ZjIwMDNmNDE3MzVmMGRmYTpiaXNlY3QtbGludXgKIFRFU1QgRkFJTFVSRQpbICAgIDIuNzM5
MTQ2XSBkZWJ1ZzogdW5tYXBwaW5nIGluaXQgW21lbSAweGZmZmY4ODAwMDFhNDQwMDAtMHhm
ZmZmODgwMDAxYmZmZmZmXQpbICAgIDIuNzQwNDE1XSBkZWJ1ZzogdW5tYXBwaW5nIGluaXQg
W21lbSAweGZmZmY4ODAwMDIxYjMwMDAtMHhmZmZmODgwMDAyMWZmZmZmXQpbICAgIDIuNzQ0
NzE4XSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAgICAyLjc0NTU0
OV0gV0FSTklORzogQ1BVOiAwIFBJRDogMSBhdCAva2J1aWxkL3NyYy9zbW9rZS9rZXJuZWwv
cmVzX2NvdW50ZXIuYzoyOCByZXNfY291bnRlcl91bmNoYXJnZV9sb2NrZWQrMHg0OC8weDc0
KCkKWyAgICAyLjc0NjY3N10gQ1BVOiAwIFBJRDogMSBDb21tOiBpbml0IE5vdCB0YWludGVk
IDMuMTYuMC1yYzEtbmV4dC0yMDE0MDYyMCAjMwpbICAgIDIuNzQ2Njc3XSBIYXJkd2FyZSBu
YW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAwMS8wMS8yMDExClsgICAgMi43NDY2Nzdd
ICAwMDAwMDAwMDAwMDAwMDAwIGZmZmY4ODAwMTIwNzNjNTAgZmZmZmZmZmY4MWEyZDY4YiBm
ZmZmODgwMDEyMDczYzg4ClsgICAgMi43NDY2NzddICBmZmZmZmZmZjgxMGJjZGIyIGZmZmZm
ZmZmODExMjAyMTMgMDAwMDAwMDAwMDAwMTAwMCBmZmZmODgwMDEyMDBmYTUwClsgICAgMi43
NDY2NzddICAwMDAwMDAwMDAwMDAwMDAxIGZmZmY4ODAwMTIwMGZhMDEgZmZmZjg4MDAxMjA3
M2M5OCBmZmZmZmZmZjgxMGJjZTk4ClsgICAgMi43NDY2NzddIENhbGwgVHJhY2U6ClsgICAg
Mi43NDY2NzddICBbPGZmZmZmZmZmODFhMmQ2OGI+XSBkdW1wX3N0YWNrKzB4MTkvMHgxYgpb
ICAgIDIuNzQ2Njc3XSAgWzxmZmZmZmZmZjgxMGJjZGIyPl0gd2Fybl9zbG93cGF0aF9jb21t
b24rMHg3My8weDhjClsgICAgMi43NDY2NzddICBbPGZmZmZmZmZmODExMjAyMTM+XSA/IHJl
c19jb3VudGVyX3VuY2hhcmdlX2xvY2tlZCsweDQ4LzB4NzQKWyAgICAyLjc0NjY3N10gIFs8
ZmZmZmZmZmY4MTBiY2U5OD5dIHdhcm5fc2xvd3BhdGhfbnVsbCsweDFhLzB4MWMKWyAgICAy
Ljc0NjY3N10gIFs8ZmZmZmZmZmY4MTEyMDIxMz5dIHJlc19jb3VudGVyX3VuY2hhcmdlX2xv
Y2tlZCsweDQ4LzB4NzQKWyAgICAyLjc0NjY3N10gIFs8ZmZmZmZmZmY4MTEyMDQ0ZD5dIHJl
c19jb3VudGVyX3VuY2hhcmdlX3VudGlsKzB4NGUvMHhhOQpbICAgIDIuNzQ2Njc3XSAgWzxm
ZmZmZmZmZjgxMTIwNGJiPl0gcmVzX2NvdW50ZXJfdW5jaGFyZ2UrMHgxMy8weDE1ClsgICAg
Mi43NDY2NzddICBbPGZmZmZmZmZmODExOTRlYTc+XSBtZW1fY2dyb3VwX3VuY2hhcmdlX2Vu
ZCsweDczLzB4OGQKWyAgICAyLjc0NjY3N10gIFs8ZmZmZmZmZmY4MTE1N2JjMj5dIHJlbGVh
c2VfcGFnZXMrMHgxZjIvMHgyMGQKWyAgICAyLjc0NjY3N10gIFs8ZmZmZmZmZmY4MTE2Y2Vk
OD5dIHRsYl9mbHVzaF9tbXVfZnJlZSsweDI4LzB4NDMKWyAgICAyLjc0NjY3N10gIFs8ZmZm
ZmZmZmY4MTE2ZDg4Mz5dIHRsYl9mbHVzaF9tbXUrMHgyMC8weDIzClsgICAgMi43NDY2Nzdd
ICBbPGZmZmZmZmZmODExNmQ4OWE+XSB0bGJfZmluaXNoX21tdSsweDE0LzB4MzkKWyAgICAy
Ljc0NjY3N10gIFs8ZmZmZmZmZmY4MTE3MzM1Zj5dIHVubWFwX3JlZ2lvbisweGNkLzB4ZGYK
WyAgICAyLjc0NjY3N10gIFs8ZmZmZmZmZmY4MTE3MmRhYz5dID8gdm1hX2dhcF9jYWxsYmFj
a3NfcHJvcGFnYXRlKzB4MTgvMHgzMwpbICAgIDIuNzQ2Njc3XSAgWzxmZmZmZmZmZjgxMTc0
ZThmPl0gZG9fbXVubWFwKzB4MjUyLzB4MmUwClsgICAgMi43NDY2NzddICBbPGZmZmZmZmZm
ODExNzRmNjE+XSB2bV9tdW5tYXArMHg0NC8weDVjClsgICAgMi43NDY2NzddICBbPGZmZmZm
ZmZmODExNzRmOWM+XSBTeVNfbXVubWFwKzB4MjMvMHgyOQpbICAgIDIuNzQ2Njc3XSAgWzxm
ZmZmZmZmZjgxYTNiMDY3Pl0gc3lzdGVtX2NhbGxfZmFzdHBhdGgrMHgxNi8weDFiClsgICAg
Mi43NDY2NzddIC0tLVsgZW5kIHRyYWNlIGQzZDMyMGI3ZWU5NTc0M2MgXS0tLQpbICAgIDIu
NzcyNjQ0XSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KL2tlcm5lbC94
ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvNjMzNTk0YmIyZDM4OTA3MTFhODg3ODk3
ZjIwMDNmNDE3MzVmMGRmYS9kbWVzZy15b2N0by1pdmI0NC0zMzoyMDE0MDYyMDE0Mzg1NDp4
ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS1uZXh0LTIwMTQwNjIw
OjMKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvNjMzNTk0YmIyZDM4
OTA3MTFhODg3ODk3ZjIwMDNmNDE3MzVmMGRmYS9kbWVzZy1xdWFudGFsLWl2YjQxLTEwOToy
MDE0MDYyMDE0Mzg0NDp4ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJj
MS1uZXh0LTIwMTQwNjIwOjMKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0
MjgvNjMzNTk0YmIyZDM4OTA3MTFhODg3ODk3ZjIwMDNmNDE3MzVmMGRmYS9kbWVzZy15b2N0
by1pdmI0MS0xMTE6MjAxNDA2MjAxNDM4NTQ6eDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAx
NDI4OjMuMTYuMC1yYzEtbmV4dC0yMDE0MDYyMDozCi9rZXJuZWwveDg2XzY0LXJhbmRjb25m
aWctd2EwLTA2MjAxNDI4LzYzMzU5NGJiMmQzODkwNzExYTg4Nzg5N2YyMDAzZjQxNzM1ZjBk
ZmEvZG1lc2ctcXVhbnRhbC1pdmI0MS0yMjoyMDE0MDYyMDE0MzgzMTp4ODZfNjQtcmFuZGNv
bmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS1uZXh0LTIwMTQwNjIwOjMKL2tlcm5lbC94
ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvNjMzNTk0YmIyZDM4OTA3MTFhODg3ODk3
ZjIwMDNmNDE3MzVmMGRmYS9kbWVzZy1xdWFudGFsLWl2YjQxLTMyOjIwMTQwNjIwMTQzNDM0
Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMxLW5leHQtMjAxNDA2
MjA6Mwova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC82MzM1OTRiYjJk
Mzg5MDcxMWE4ODc4OTdmMjAwM2Y0MTczNWYwZGZhL2RtZXNnLXF1YW50YWwtaXZiNDItMTEz
OjIwMTQwNjIwMTQzNDQ0Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAt
cmMxLW5leHQtMjAxNDA2MjA6Mwova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIw
MTQyOC82MzM1OTRiYjJkMzg5MDcxMWE4ODc4OTdmMjAwM2Y0MTczNWYwZGZhL2RtZXNnLXF1
YW50YWwtaXZiNDEtMTIwOjIwMTQwNjIwMTQzODM4Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0w
NjIwMTQyODozLjE2LjAtcmMxLW5leHQtMjAxNDA2MjA6Mwova2VybmVsL3g4Nl82NC1yYW5k
Y29uZmlnLXdhMC0wNjIwMTQyOC82MzM1OTRiYjJkMzg5MDcxMWE4ODc4OTdmMjAwM2Y0MTcz
NWYwZGZhL2RtZXNnLXF1YW50YWwtaXZiNDEtODk6MjAxNDA2MjAxNDM0MzQ6eDg2XzY0LXJh
bmRjb25maWctd2EwLTA2MjAxNDI4OjMuMTYuMC1yYzEtbmV4dC0yMDE0MDYyMDozCi9rZXJu
ZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4LzYzMzU5NGJiMmQzODkwNzExYTg4
Nzg5N2YyMDAzZjQxNzM1ZjBkZmEvZG1lc2cteW9jdG8taXZiNDQtMTAxOjIwMTQwNjIwMTQz
OTA5Ong4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyODozLjE2LjAtcmMxLW5leHQtMjAx
NDA2MjA6Mwova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLXdhMC0wNjIwMTQyOC82MzM1OTRi
YjJkMzg5MDcxMWE4ODc4OTdmMjAwM2Y0MTczNWYwZGZhL2RtZXNnLXF1YW50YWwtaXZiNDQt
MTU6MjAxNDA2MjAxNDM4Mzg6eDg2XzY0LXJhbmRjb25maWctd2EwLTA2MjAxNDI4OjMuMTYu
MC1yYzEtbmV4dC0yMDE0MDYyMDozCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctd2EwLTA2
MjAxNDI4LzYzMzU5NGJiMmQzODkwNzExYTg4Nzg5N2YyMDAzZjQxNzM1ZjBkZmEvZG1lc2ct
eW9jdG8taXZiNDEtNDY6MjAxNDA2MjAxNDM5MDk6eDg2XzY0LXJhbmRjb25maWctd2EwLTA2
MjAxNDI4OjMuMTYuMC1yYzEtbmV4dC0yMDE0MDYyMDozCi9rZXJuZWwveDg2XzY0LXJhbmRj
b25maWctd2EwLTA2MjAxNDI4LzYzMzU5NGJiMmQzODkwNzExYTg4Nzg5N2YyMDAzZjQxNzM1
ZjBkZmEvZG1lc2ctcXVhbnRhbC1pdmI0NC03ODoyMDE0MDYyMDE0MzgyMzp4ODZfNjQtcmFu
ZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS1uZXh0LTIwMTQwNjIwOjMKL2tlcm5l
bC94ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0MjgvNjMzNTk0YmIyZDM4OTA3MTFhODg3
ODk3ZjIwMDNmNDE3MzVmMGRmYS9kbWVzZy15b2N0by1pdmI0NC05NjoyMDE0MDYyMDE0Mzg1
NDp4ODZfNjQtcmFuZGNvbmZpZy13YTAtMDYyMDE0Mjg6My4xNi4wLXJjMS1uZXh0LTIwMTQw
NjIwOjMKMDoxMzoxMyBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwoK

--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.16.0-rc1-00238-gddc5bfe"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.16.0-rc1 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
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
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
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
CONFIG_KERNEL_BZIP2=y
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
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
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
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
# CONFIG_TASK_IO_ACCOUNTING is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
CONFIG_MEMCG=y
CONFIG_MEMCG_KMEM=y
CONFIG_CGROUP_HUGETLB=y
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
# CONFIG_IPC_NS is not set
CONFIG_USER_NS=y
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
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
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
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
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_OPROFILE=y
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_USER_RETURN_NOTIFIER=y
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
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
# CONFIG_GCOV_PROFILE_ALL is not set
# CONFIG_GCOV_FORMAT_AUTODETECT is not set
CONFIG_GCOV_FORMAT_3_4=y
# CONFIG_GCOV_FORMAT_4_7 is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
# CONFIG_BLK_DEV_BSGLIB is not set
# CONFIG_BLK_DEV_INTEGRITY is not set
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_AMIGA_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y
CONFIG_BLOCK_COMPAT=y

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
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_USE_QUEUE_RWLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
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
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
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
# CONFIG_I8K is not set
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_MICROCODE_INTEL_EARLY is not set
CONFIG_MICROCODE_AMD_EARLY=y
CONFIG_MICROCODE_EARLY=y
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
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
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
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
# CONFIG_ACPI_APEI is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

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
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_IOSF_MBI=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
# CONFIG_IP_ADVANCED_ROUTER is not set
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_IP_MROUTE is not set
# CONFIG_SYN_COOKIES is not set
CONFIG_INET_AH=y
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
CONFIG_INET6_ESP=y
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
# CONFIG_INET6_XFRM_MODE_BEET is not set
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
CONFIG_IPV6_VTI=y
# CONFIG_IPV6_SIT is not set
CONFIG_IPV6_TUNNEL=y
# CONFIG_IPV6_GRE is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
CONFIG_NETLABEL=y
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NET_PTP_CLASSIFY=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
CONFIG_IP_DCCP_CCID3_DEBUG=y
CONFIG_IP_DCCP_TFRC_LIB=y
CONFIG_IP_DCCP_TFRC_DEBUG=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_IP_SCTP=y
CONFIG_SCTP_DBG_OBJCNT=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
# CONFIG_SCTP_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
CONFIG_L2TP=y
CONFIG_L2TP_DEBUGFS=y
# CONFIG_L2TP_V3 is not set
CONFIG_STP=y
CONFIG_BRIDGE=y
# CONFIG_BRIDGE_IGMP_SNOOPING is not set
# CONFIG_BRIDGE_VLAN_FILTERING is not set
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_VLAN_8021Q_MVRP is not set
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
CONFIG_LLC2=y
# CONFIG_IPX is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
# CONFIG_IPDDP is not set
CONFIG_X25=y
CONFIG_LAPB=y
CONFIG_PHONET=y
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=y
CONFIG_NET_SCH_RED=y
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
# CONFIG_NET_SCH_TEQL is not set
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
# CONFIG_NET_SCH_DRR is not set
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
# CONFIG_NET_SCH_CODEL is not set
CONFIG_NET_SCH_FQ_CODEL=y
CONFIG_NET_SCH_FQ=y
CONFIG_NET_SCH_HHF=y
CONFIG_NET_SCH_PIE=y
CONFIG_NET_SCH_INGRESS=y
# CONFIG_NET_SCH_PLUG is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_TCINDEX=y
# CONFIG_NET_CLS_ROUTE4 is not set
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
# CONFIG_NET_CLS_FLOW is not set
# CONFIG_NET_CLS_CGROUP is not set
CONFIG_NET_CLS_BPF=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
# CONFIG_NET_EMATCH_CMP is not set
# CONFIG_NET_EMATCH_NBYTE is not set
CONFIG_NET_EMATCH_U32=y
CONFIG_NET_EMATCH_META=y
CONFIG_NET_EMATCH_TEXT=y
CONFIG_NET_EMATCH_CANID=y
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=y
# CONFIG_GACT_PROB is not set
CONFIG_NET_ACT_MIRRED=y
# CONFIG_NET_ACT_NAT is not set
# CONFIG_NET_ACT_PEDIT is not set
# CONFIG_NET_ACT_SIMP is not set
CONFIG_NET_ACT_SKBEDIT=y
CONFIG_NET_ACT_CSUM=y
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=y
CONFIG_VSOCKETS=y
# CONFIG_NETLINK_MMAP is not set
CONFIG_NETLINK_DIAG=y
CONFIG_NET_MPLS_GSO=y
CONFIG_HSR=y
CONFIG_CGROUP_NET_PRIO=y
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
CONFIG_NET_DROP_MONITOR=y
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
CONFIG_AX25_DAMA_SLAVE=y
# CONFIG_NETROM is not set
# CONFIG_ROSE is not set

#
# AX.25 network device drivers
#
CONFIG_MKISS=y
CONFIG_6PACK=y
CONFIG_BPQETHER=y
CONFIG_BAYCOM_SER_FDX=y
CONFIG_BAYCOM_SER_HDX=y
CONFIG_BAYCOM_PAR=y
CONFIG_YAM=y
CONFIG_CAN=y
# CONFIG_CAN_RAW is not set
CONFIG_CAN_BCM=y
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
# CONFIG_CAN_VCAN is not set
CONFIG_CAN_SLCAN=y
# CONFIG_CAN_DEV is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
# CONFIG_IRCOMM is not set
# CONFIG_IRDA_ULTRA is not set

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
CONFIG_IRTTY_SIR=y

#
# Dongle support
#
# CONFIG_DONGLE is not set

#
# FIR device drivers
#
# CONFIG_NSC_FIR is not set
# CONFIG_WINBOND_FIR is not set
CONFIG_SMC_IRCC_FIR=y
CONFIG_ALI_FIR=y
# CONFIG_VLSI_FIR is not set
# CONFIG_VIA_FIR is not set
CONFIG_BT=y
# CONFIG_BT_6LOWPAN is not set
CONFIG_BT_RFCOMM=y
CONFIG_BT_RFCOMM_TTY=y
# CONFIG_BT_BNEP is not set
CONFIG_BT_HIDP=y

#
# Bluetooth device drivers
#
CONFIG_BT_HCIUART=y
# CONFIG_BT_HCIUART_H4 is not set
CONFIG_BT_HCIUART_BCSP=y
CONFIG_BT_HCIUART_ATH3K=y
CONFIG_BT_HCIUART_LL=y
# CONFIG_BT_HCIUART_3WIRE is not set
CONFIG_BT_HCIDTL1=y
CONFIG_BT_HCIBT3C=y
CONFIG_BT_HCIBLUECARD=y
# CONFIG_BT_HCIBTUART is not set
CONFIG_BT_HCIVHCI=y
# CONFIG_BT_MRVL is not set
CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_DEBUG=y
# CONFIG_RXKAD is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
CONFIG_RFKILL_REGULATOR=y
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_NET_9P_DEBUG=y
CONFIG_CAIF=y
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=y
CONFIG_CAIF_USB=y
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
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
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_FW_LOADER_USER_HELPER is not set
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
# CONFIG_MTD is not set
CONFIG_PARPORT=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=y
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_FD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SKD is not set
# CONFIG_BLK_DEV_OSD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_SRAM is not set
CONFIG_C2PORT=y
# CONFIG_C2PORT_DURAMAR_2150 is not set

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
# Intel MIC Host Driver
#
# CONFIG_INTEL_MIC_HOST is not set

#
# Intel MIC Card Driver
#
CONFIG_INTEL_MIC_CARD=y
# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_BLK_DEV_IDE_SATA=y
# CONFIG_IDE_GD is not set
CONFIG_BLK_DEV_IDECS=y
# CONFIG_BLK_DEV_DELKIN is not set
# CONFIG_BLK_DEV_IDECD is not set
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_PLATFORM is not set
CONFIG_BLK_DEV_CMD640=y
CONFIG_BLK_DEV_CMD640_ENHANCED=y
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
# CONFIG_BLK_DEV_IDEDMA is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
# CONFIG_SCSI_MULTI_LUN is not set
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
CONFIG_SCSI_FC_ATTRS=y
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=y
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=y
CONFIG_SCSI_OSD_ULD=y
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
# CONFIG_ATA_VERBOSE_ERROR is not set
CONFIG_ATA_ACPI=y
# CONFIG_SATA_PMP is not set

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_ATA_SFF is not set
# CONFIG_MD is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
# CONFIG_NETDEVICES is not set
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5588=y
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
CONFIG_KEYBOARD_QT2160=y
# CONFIG_KEYBOARD_LKKBD is not set
CONFIG_KEYBOARD_TCA6416=y
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_LM8323 is not set
CONFIG_KEYBOARD_LM8333=y
CONFIG_KEYBOARD_MAX7359=y
CONFIG_KEYBOARD_MCS=y
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_KEYBOARD_OPENCORES=y
CONFIG_KEYBOARD_STOWAWAY=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TC3589X is not set
CONFIG_KEYBOARD_XTKBD=y
# CONFIG_KEYBOARD_CROS_EC is not set
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_VSXXXAA is not set
CONFIG_MOUSE_SYNAPTICS_I2C=y
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
# CONFIG_JOYSTICK_ANALOG is not set
CONFIG_JOYSTICK_A3D=y
CONFIG_JOYSTICK_ADI=y
# CONFIG_JOYSTICK_COBRA is not set
CONFIG_JOYSTICK_GF2K=y
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
CONFIG_JOYSTICK_SIDEWINDER=y
# CONFIG_JOYSTICK_TMDC is not set
CONFIG_JOYSTICK_IFORCE=y
# CONFIG_JOYSTICK_IFORCE_232 is not set
# CONFIG_JOYSTICK_WARRIOR is not set
CONFIG_JOYSTICK_MAGELLAN=y
# CONFIG_JOYSTICK_SPACEORB is not set
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=y
CONFIG_JOYSTICK_TWIDJOY=y
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_DB9=y
# CONFIG_JOYSTICK_GAMECON is not set
# CONFIG_JOYSTICK_TURBOGRAFX is not set
CONFIG_JOYSTICK_AS5011=y
CONFIG_JOYSTICK_JOYDUMP=y
# CONFIG_JOYSTICK_XPAD is not set
CONFIG_JOYSTICK_WALKERA0701=y
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
# CONFIG_GAMEPORT_L4 is not set
# CONFIG_GAMEPORT_EMU10K1 is not set
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
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
# CONFIG_N_HDLC is not set
CONFIG_N_GSM=y
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y
CONFIG_SERIAL_8250_DW=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ALTERA_UART_CONSOLE=y
CONFIG_SERIAL_ARC=y
# CONFIG_SERIAL_ARC_CONSOLE is not set
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
CONFIG_SERIAL_MEN_Z135=y
CONFIG_PRINTER=y
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_SI_PROBE_DEFAULTS=y
# CONFIG_IPMI_WATCHDOG is not set
CONFIG_IPMI_POWEROFF=y
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
CONFIG_R3964=y
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
# CONFIG_CARDMAN_4000 is not set
CONFIG_CARDMAN_4040=y
CONFIG_MWAVE=y
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y

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
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_CROS_EC_TUNNEL=y
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

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
CONFIG_PPS_CLIENT_LDISC=y
CONFIG_PPS_CLIENT_PARPORT=y
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
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2431 is not set
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_MAX8925_POWER=y
CONFIG_TEST_POWER=y
# CONFIG_BATTERY_88PM860X is not set
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27x00 is not set
CONFIG_BATTERY_DA9030=y
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_PCF50633 is not set
CONFIG_CHARGER_MAX8903=y
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_MANAGER=y
CONFIG_CHARGER_MAX14577=y
# CONFIG_CHARGER_MAX8998 is not set
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_SMB347=y
CONFIG_CHARGER_TPS65090=y
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_MC13783_ADC=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
# CONFIG_SENSORS_IIO_HWMON is not set
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_HTU21 is not set
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
# CONFIG_SENSORS_NCT6683 is not set
# CONFIG_SENSORS_NCT6775 is not set
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
# CONFIG_SENSORS_PMBUS is not set
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_MAX16064 is not set
CONFIG_SENSORS_MAX34440=y
# CONFIG_SENSORS_MAX8688 is not set
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SHTC1 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
CONFIG_SENSORS_SCH5636=y
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_ACPI_INT3403_THERMAL is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

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
CONFIG_XILINX_WATCHDOG=y
CONFIG_DW_WATCHDOG=y
# CONFIG_RETU_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=y
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
# CONFIG_HP_WATCHDOG is not set
CONFIG_KEMPLD_WDT=y
CONFIG_SC1200_WDT=y
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83877F_WDT=y
# CONFIG_W83977F_WDT is not set
# CONFIG_MACHZ_WDT is not set
CONFIG_SBC_EPX_C3_WATCHDOG=y

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
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
CONFIG_MFD_AS3711=y
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_BCM590XX=y
# CONFIG_MFD_AXP20X is not set
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_I2C is not set
CONFIG_MFD_DA9055=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77686=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
# CONFIG_PCF50633_GPIO is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP3943 is not set
CONFIG_MFD_LP8788=y
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS65218 is not set
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=y
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PM800=y
CONFIG_REGULATOR_88PM8607=y
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_ANATOP is not set
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_BCM590XX=y
CONFIG_REGULATOR_DA903X=y
CONFIG_REGULATOR_DA9055=y
# CONFIG_REGULATOR_DA9210 is not set
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_ISL6271A=y
# CONFIG_REGULATOR_LP3971 is not set
# CONFIG_REGULATOR_LP3972 is not set
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LP8788=y
# CONFIG_REGULATOR_LTC3589 is not set
# CONFIG_REGULATOR_MAX14577 is not set
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8925=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8973=y
CONFIG_REGULATOR_MAX8998=y
CONFIG_REGULATOR_MAX77686=y
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_PFUZE100 is not set
CONFIG_REGULATOR_RC5T583=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
# CONFIG_REGULATOR_TPS6507X is not set
CONFIG_REGULATOR_TPS65090=y
CONFIG_REGULATOR_TPS65217=y
# CONFIG_REGULATOR_TPS6586X is not set
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
CONFIG_FIRMWARE_EDID=y
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
# CONFIG_FB_TILEBLITTING is not set

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
CONFIG_FB_UVESA=y
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
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
# CONFIG_FB_VIRTUAL is not set
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_FB_AUO_K190X=y
CONFIG_FB_AUO_K1900=y
CONFIG_FB_AUO_K1901=y
# CONFIG_FB_SIMPLE is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_DA903X=y
CONFIG_BACKLIGHT_MAX8925=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_TPS65217=y
CONFIG_BACKLIGHT_AS3711=y
CONFIG_BACKLIGHT_LV5207LP=y
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_VGASTATE is not set
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
# CONFIG_FRAMEBUFFER_CONSOLE is not set
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_DMAENGINE_PCM=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_COMPRESS_OFFLOAD=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
CONFIG_SND_PCM_OSS=y
# CONFIG_SND_PCM_OSS_PLUGINS is not set
# CONFIG_SND_SEQUENCER_OSS is not set
CONFIG_SND_HRTIMER=y
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
CONFIG_SND_SUPPORT_OLD_API=y
# CONFIG_SND_VERBOSE_PROCFS is not set
# CONFIG_SND_VERBOSE_PRINTK is not set
CONFIG_SND_DEBUG=y
# CONFIG_SND_DEBUG_VERBOSE is not set
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=y
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_MPU401_UART=y
CONFIG_SND_DRIVERS=y
# CONFIG_SND_PCSP is not set
CONFIG_SND_DUMMY=y
CONFIG_SND_ALOOP=y
# CONFIG_SND_VIRMIDI is not set
CONFIG_SND_MTPAV=y
# CONFIG_SND_MTS64 is not set
CONFIG_SND_SERIAL_U16550=y
CONFIG_SND_MPU401=y
# CONFIG_SND_PORTMAN2X4 is not set
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
CONFIG_SND_PCMCIA=y
# CONFIG_SND_VXPOCKET is not set
CONFIG_SND_PDAUDIOCF=y
CONFIG_SND_SOC=y
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
CONFIG_SND_ATMEL_SOC=y

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
CONFIG_SND_SOC_FSL_SAI=y
CONFIG_SND_SOC_FSL_SSI=y
CONFIG_SND_SOC_FSL_SPDIF=y
# CONFIG_SND_SOC_FSL_ESAI is not set
CONFIG_SND_SOC_IMX_AUDMUX=y
CONFIG_SND_SOC_INTEL_SST=y
CONFIG_SND_SOC_INTEL_SST_ACPI=y
CONFIG_SND_SOC_I2C_AND_SPI=y

#
# CODEC drivers
#
CONFIG_SND_SOC_ADAU1701=y
CONFIG_SND_SOC_AK4554=y
CONFIG_SND_SOC_AK4642=y
CONFIG_SND_SOC_AK5386=y
CONFIG_SND_SOC_ALC5623=y
CONFIG_SND_SOC_CS42L52=y
# CONFIG_SND_SOC_CS42L56 is not set
CONFIG_SND_SOC_CS42L73=y
CONFIG_SND_SOC_CS4270=y
CONFIG_SND_SOC_CS4271=y
CONFIG_SND_SOC_CS42XX8=y
CONFIG_SND_SOC_CS42XX8_I2C=y
# CONFIG_SND_SOC_HDMI_CODEC is not set
CONFIG_SND_SOC_PCM1681=y
CONFIG_SND_SOC_PCM512x=y
CONFIG_SND_SOC_PCM512x_I2C=y
CONFIG_SND_SOC_SGTL5000=y
CONFIG_SND_SOC_SIGMADSP=y
CONFIG_SND_SOC_SIRF_AUDIO_CODEC=y
CONFIG_SND_SOC_SPDIF=y
CONFIG_SND_SOC_STA350=y
CONFIG_SND_SOC_TAS5086=y
# CONFIG_SND_SOC_TLV320AIC3X is not set
# CONFIG_SND_SOC_WM8510 is not set
# CONFIG_SND_SOC_WM8523 is not set
CONFIG_SND_SOC_WM8580=y
# CONFIG_SND_SOC_WM8711 is not set
CONFIG_SND_SOC_WM8728=y
CONFIG_SND_SOC_WM8731=y
# CONFIG_SND_SOC_WM8737 is not set
# CONFIG_SND_SOC_WM8741 is not set
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=y
CONFIG_SND_SOC_WM8776=y
CONFIG_SND_SOC_WM8804=y
# CONFIG_SND_SOC_WM8903 is not set
# CONFIG_SND_SOC_WM8962 is not set
# CONFIG_SND_SOC_TPA6130A2 is not set
CONFIG_SND_SIMPLE_CARD=y
CONFIG_SOUND_PRIME=y
CONFIG_SOUND_OSS=y
# CONFIG_SOUND_TRACEINIT is not set
CONFIG_SOUND_DMAP=y
CONFIG_SOUND_VMIDI=y
# CONFIG_SOUND_TRIX is not set
# CONFIG_SOUND_MSS is not set
CONFIG_SOUND_MPU401=y
CONFIG_SOUND_PAS=y
# CONFIG_PAS_JOYSTICK is not set
CONFIG_SOUND_PSS=y
CONFIG_PSS_MIXER=y
# CONFIG_PSS_HAVE_BOOT is not set
CONFIG_SOUND_SB=y
CONFIG_SOUND_YM3812=y
CONFIG_SOUND_UART6850=y
CONFIG_SOUND_AEDSP16=y
CONFIG_SC6600=y
# CONFIG_SC6600_JOY is not set
CONFIG_SC6600_CDROM=4
CONFIG_SC6600_CDROMBASE=0
# CONFIG_SOUND_KAHLUA is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
# CONFIG_HIDRAW is not set
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_PRODIKEYS is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
CONFIG_HID_EZKEY=y
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
CONFIG_HID_LENOVO_TPKBD=y
CONFIG_HID_LOGITECH=y
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PETALYNX is not set
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PRIMAX=y
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
# CONFIG_HID_GREENASIA is not set
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=y
# CONFIG_HID_WIIMOTE is not set
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
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_88PM860X is not set
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_LP8788=y
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_REGULATOR=y
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_MC13783=y
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_LM355x is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=y
CONFIG_ACCESSIBILITY=y
CONFIG_A11Y_BRAILLE_CONSOLE=y
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
CONFIG_EDAC_DEBUG=y
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
# CONFIG_RTC_SYSTOHC is not set
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
# CONFIG_RTC_INTF_PROC is not set
# CONFIG_RTC_INTF_DEV is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_88PM860X is not set
CONFIG_RTC_DRV_88PM80X=y
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_DS3232=y
# CONFIG_RTC_DRV_LP8788 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
CONFIG_RTC_DRV_MAX8925=y
CONFIG_RTC_DRV_MAX8998=y
CONFIG_RTC_DRV_MAX77686=y
CONFIG_RTC_DRV_RS5C372=y
# CONFIG_RTC_DRV_ISL1208 is not set
CONFIG_RTC_DRV_ISL12022=y
CONFIG_RTC_DRV_ISL12057=y
CONFIG_RTC_DRV_X1205=y
# CONFIG_RTC_DRV_PCF2127 is not set
# CONFIG_RTC_DRV_PCF8523 is not set
CONFIG_RTC_DRV_PCF8563=y
# CONFIG_RTC_DRV_PCF8583 is not set
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_TPS6586X is not set
# CONFIG_RTC_DRV_RC5T583 is not set
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
# CONFIG_RTC_DRV_RX8581 is not set
CONFIG_RTC_DRV_RX8025=y
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV3029C2=y

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
# CONFIG_RTC_DRV_DS1553 is not set
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DA9055=y
# CONFIG_RTC_DRV_STK17TA8 is not set
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
# CONFIG_RTC_DRV_M48T59 is not set
CONFIG_RTC_DRV_MSM6242=y
# CONFIG_RTC_DRV_BQ4802 is not set
CONFIG_RTC_DRV_RP5C01=y
# CONFIG_RTC_DRV_V3020 is not set
CONFIG_RTC_DRV_DS2404=y
# CONFIG_RTC_DRV_PCF50633 is not set

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_MC13XXX=y
CONFIG_RTC_DRV_MOXART=y
CONFIG_RTC_DRV_XGENE=y

#
# HID Sensor RTC drivers
#
# CONFIG_DMADEVICES is not set
CONFIG_AUXDISPLAY=y
# CONFIG_KS0108 is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_MF624 is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
# CONFIG_PANEL_CHANGE_MESSAGE is not set
# CONFIG_RTS5208 is not set
# CONFIG_DX_SEP is not set

#
# IIO staging drivers
#

#
# Accelerometers
#

#
# Analog to digital converters
#
CONFIG_AD7291=y

#
# Analog digital bi-direction converters
#

#
# Capacitance to digital converters
#
# CONFIG_AD7150 is not set
# CONFIG_AD7152 is not set
CONFIG_AD7746=y

#
# Direct Digital Synthesis
#

#
# Digital gyroscope sensors
#

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=y

#
# Light sensors
#
CONFIG_SENSORS_ISL29018=y
CONFIG_SENSORS_ISL29028=y
CONFIG_TSL2583=y
CONFIG_TSL2x7x=y

#
# Magnetometer sensors
#
# CONFIG_SENSORS_HMC5843 is not set

#
# Active energy metering IC
#
CONFIG_ADE7854=y
# CONFIG_ADE7854_I2C is not set

#
# Resolver to digital converters
#

#
# Triggers - standalone
#
CONFIG_IIO_PERIODIC_RTC_TRIGGER=y
CONFIG_IIO_SIMPLE_DUMMY=y
# CONFIG_IIO_SIMPLE_DUMMY_EVENTS is not set
CONFIG_IIO_SIMPLE_DUMMY_BUFFER=y
# CONFIG_CRYSTALHD is not set
# CONFIG_FB_XGI is not set
# CONFIG_ACPI_QUICKSTART is not set
CONFIG_FT1000=y
# CONFIG_FT1000_PCMCIA is not set

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
CONFIG_STAGING_MEDIA=y

#
# Android
#
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
# CONFIG_ASHMEM is not set
CONFIG_ANDROID_LOGGER=y
CONFIG_ANDROID_TIMED_OUTPUT=y
CONFIG_ANDROID_LOW_MEMORY_KILLER=y
# CONFIG_ANDROID_INTF_ALARM_DEV is not set
# CONFIG_SYNC is not set
# CONFIG_ION is not set
CONFIG_DGRP=y
# CONFIG_XILLYBUS is not set
# CONFIG_DGNC is not set
# CONFIG_DGAP is not set
CONFIG_GS_FPGABOOT=y
CONFIG_CRYPTO_SKEIN=y
CONFIG_CRYPTO_THREEFISH=y
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_LAPTOP=y
# CONFIG_DELL_SMO8800 is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_AMILO_RFKILL is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_COMPAL_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_IDEAPAD_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=y
# CONFIG_INTEL_OAKTRAIL is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
CONFIG_CHROME_PLATFORMS=y
# CONFIG_CHROMEOS_LAPTOP is not set
CONFIG_CHROMEOS_PSTORE=y

#
# SOC (System On Chip) specific Drivers
#

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_ADC_JACK is not set
CONFIG_EXTCON_MAX14577=y
CONFIG_EXTCON_MAX77693=y
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
CONFIG_BMA180=y
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y
# CONFIG_MMA8452 is not set

#
# Analog to digital converters
#
CONFIG_AD799X=y
# CONFIG_LP8788_ADC is not set
CONFIG_MAX1363=y
# CONFIG_MCP3422 is not set
CONFIG_MEN_Z188_ADC=y
CONFIG_NAU7802=y
CONFIG_TI_ADC081C=y
CONFIG_TI_AM335X_ADC=y

#
# Amplifiers
#

#
# Hid Sensor IIO Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5380=y
CONFIG_AD5446=y
# CONFIG_MAX517 is not set
CONFIG_MCP4725=y

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
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
CONFIG_ITG3200=y

#
# Humidity sensors
#
CONFIG_SI7005=y

#
# Inertial measurement units
#
CONFIG_INV_MPU6050_IIO=y

#
# Light sensors
#
CONFIG_ADJD_S311=y
# CONFIG_APDS9300 is not set
CONFIG_CM32181=y
CONFIG_CM36651=y
# CONFIG_GP2AP020A00F is not set
# CONFIG_SENSORS_LM3533 is not set
CONFIG_LTR501=y
CONFIG_TCS3472=y
CONFIG_SENSORS_TSL2563=y
CONFIG_TSL4531=y
# CONFIG_VCNL4000 is not set

#
# Magnetometer sensors
#
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
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Pressure sensors
#
CONFIG_MPL115=y
# CONFIG_MPL3115 is not set
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y

#
# Lightning sensors
#

#
# Temperature sensors
#
# CONFIG_MLX90614 is not set
CONFIG_TMP006=y
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
CONFIG_SERIAL_IPOCTAL=y
# CONFIG_RESET_CONTROLLER is not set
CONFIG_FMC=y
# CONFIG_FMC_FAKEDEV is not set
# CONFIG_FMC_TRIVIAL is not set
CONFIG_FMC_WRITE_EEPROM=y
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_BCM_KONA_USB2_PHY is not set
CONFIG_PHY_SAMSUNG_USB2=y
CONFIG_POWERCAP=y
# CONFIG_INTEL_RAPL is not set
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set

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
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
# CONFIG_EXT2_FS_POSIX_ACL is not set
# CONFIG_EXT2_FS_SECURITY is not set
CONFIG_EXT2_FS_XIP=y
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
# CONFIG_EXT4_FS_POSIX_ACL is not set
# CONFIG_EXT4_FS_SECURITY is not set
# CONFIG_EXT4_DEBUG is not set
CONFIG_FS_XIP=y
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
CONFIG_REISERFS_CHECK=y
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
# CONFIG_REISERFS_FS_POSIX_ACL is not set
# CONFIG_REISERFS_FS_SECURITY is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
# CONFIG_JFS_SECURITY is not set
CONFIG_JFS_DEBUG=y
CONFIG_JFS_STATISTICS=y
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
# CONFIG_XFS_WARN is not set
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=y
CONFIG_GFS2_FS_LOCKING_DLM=y
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
# CONFIG_INOTIFY_USER is not set
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
CONFIG_QUOTA_DEBUG=y
CONFIG_QFMT_V1=y
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
CONFIG_FSCACHE_DEBUG=y
CONFIG_FSCACHE_OBJECT_LIST=y
CONFIG_CACHEFILES=y
# CONFIG_CACHEFILES_DEBUG is not set
CONFIG_CACHEFILES_HISTOGRAM=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ADFS_FS=y
# CONFIG_ADFS_FS_RW is not set
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
# CONFIG_ECRYPT_FS_MESSAGING is not set
# CONFIG_HFS_FS is not set
CONFIG_HFSPLUS_FS=y
# CONFIG_HFSPLUS_FS_POSIX_ACL is not set
# CONFIG_BEFS_FS is not set
CONFIG_BFS_FS=y
# CONFIG_EFS_FS is not set
# CONFIG_LOGFS is not set
# CONFIG_CRAMFS is not set
# CONFIG_SQUASHFS is not set
CONFIG_VXFS_FS=y
# CONFIG_MINIX_FS is not set
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
CONFIG_UFS_DEBUG=y
CONFIG_EXOFS_FS=y
CONFIG_EXOFS_DEBUG=y
# CONFIG_F2FS_FS is not set
CONFIG_ORE=y
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=y
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=y
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
CONFIG_DLM=y
# CONFIG_DLM_DEBUG is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
CONFIG_DEBUG_OBJECTS_FREE=y
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_SLUB_DEBUG_ON is not set
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_VMACACHE=y
CONFIG_DEBUG_VM_RB=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_MEMORY_NOTIFIER_ERROR_INJECT is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_PROVE_RCU_REPEATEDLY=y
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_TORTURE_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
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
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
CONFIG_PROFILE_ANNOTATED_BRANCHES=y
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_TRACING_BRANCHES=y
CONFIG_BRANCH_TRACER=y
# CONFIG_STACK_TRACER is not set
# CONFIG_BLK_DEV_IO_TRACE is not set
# CONFIG_UPROBE_EVENT is not set
# CONFIG_PROBE_EVENTS is not set
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACEPOINT_BENCHMARK=y
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
CONFIG_LKDTM=y
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
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
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_STATIC_CPU_HAS=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
CONFIG_SECURITY_PATH=y
CONFIG_SECURITY_SMACK=y
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_SECURITY_YAMA=y
CONFIG_SECURITY_YAMA_STACKED=y
# CONFIG_IMA is not set
# CONFIG_EVM is not set
# CONFIG_DEFAULT_SECURITY_SMACK is not set
# CONFIG_DEFAULT_SECURITY_YAMA is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
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
CONFIG_CRYPTO_USER=y
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
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
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_X86_64=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_KVM_AMD=y
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
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
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CORDIC=y
# CONFIG_DDR is not set

--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--yrj/dFKFPuw6o+aM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
