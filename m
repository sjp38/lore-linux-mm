Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3CE6B0032
	for <linux-mm@kvack.org>; Sat, 24 Jan 2015 23:36:26 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id fl12so5648269pdb.6
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 20:36:26 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id hz4si7751274pbb.8.2015.01.24.20.36.24
        for <linux-mm@kvack.org>;
        Sat, 24 Jan 2015 20:36:25 -0800 (PST)
Date: Sat, 24 Jan 2015 20:36:08 -0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mm] WARNING: CPU: 1 PID: 681 at mm/mmap.c:2858 exit_mmap()
Message-ID: <20150125043608.GB6109@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="jq0ap7NbKX2Kqbes"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--jq0ap7NbKX2Kqbes
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit f7a7b53a90f7a489c4e435d1300db121f6b42776
Author:     Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
AuthorDate: Fri Jan 23 10:11:34 2015 +1100
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Fri Jan 23 10:11:34 2015 +1100

    mm: account pmd page tables to the process
    
    Dave noticed that unprivileged process can allocate significant amount of
    memory -- >500 MiB on x86_64 -- and stay unnoticed by oom-killer and
    memory cgroup.  The trick is to allocate a lot of PMD page tables.  Linux
    kernel doesn't account PMD tables to the process, only PTE.
    
    The use-cases below use few tricks to allocate a lot of PMD page tables
    while keeping VmRSS and VmPTE low.  oom_score for the process will be 0.
    
    	#include <errno.h>
    	#include <stdio.h>
    	#include <stdlib.h>
    	#include <unistd.h>
    	#include <sys/mman.h>
    	#include <sys/prctl.h>
    
    	#define PUD_SIZE (1UL << 30)
    	#define PMD_SIZE (1UL << 21)
    
    	#define NR_PUD 130000
    
    	int main(void)
    	{
    		char *addr = NULL;
    		unsigned long i;
    
    		prctl(PR_SET_THP_DISABLE);
    		for (i = 0; i < NR_PUD ; i++) {
    			addr = mmap(addr + PUD_SIZE, PUD_SIZE, PROT_WRITE|PROT_READ,
    					MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
    			if (addr == MAP_FAILED) {
    				perror("mmap");
    				break;
    			}
    			*addr = 'x';
    			munmap(addr, PMD_SIZE);
    			mmap(addr, PMD_SIZE, PROT_WRITE|PROT_READ,
    					MAP_ANONYMOUS|MAP_PRIVATE|MAP_FIXED, -1, 0);
    			if (addr == MAP_FAILED)
    				perror("re-mmap"), exit(1);
    		}
    		printf("PID %d consumed %lu KiB in PMD page tables\n",
    				getpid(), i * 4096 >> 10);
    		return pause();
    	}
    
    The patch addresses the issue by account PMD tables to the process the
    same way we account PTE.
    
    The main place where PMD tables is accounted is __pmd_alloc() and
    free_pmd_range(). But there're few corner cases:
    
     - HugeTLB can share PMD page tables. The patch handles by accounting
       the table to all processes who share it.
    
     - x86 PAE pre-allocates few PMD tables on fork.
    
     - Architectures with FIRST_USER_ADDRESS > 0. We need to adjust sanity
       check on exit(2).
    
    Accounting only happens on configuration where PMD page table's level is
    present (PMD is not folded).  As with nr_ptes we use per-mm counter.  The
    counter value is used to calculate baseline for badness score by
    oom-killer.
    
    Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
    Reported-by: Dave Hansen <dave.hansen@linux.intel.com>
    Cc: Hugh Dickins <hughd@google.com>
    Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>
    Cc: Pavel Emelyanov <xemul@openvz.org>
    Cc: David Rientjes <rientjes@google.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

+-----------------------------------+------------+------------+---------------+
|                                   | fe888c1f62 | f7a7b53a90 | next-20150123 |
+-----------------------------------+------------+------------+---------------+
| boot_successes                    | 1364       | 142        | 25            |
| boot_failures                     | 5          | 227        | 19            |
| BUG:kernel_test_crashed           | 5          |            |               |
| WARNING:at_mm/mmap.c:#exit_mmap() | 0          | 227        | 19            |
| backtrace:do_execve               | 0          | 227        | 19            |
| backtrace:SyS_execve              | 0          | 227        | 19            |
| backtrace:do_group_exit           | 0          | 227        | 19            |
| backtrace:SyS_exit_group          | 0          | 227        | 19            |
| backtrace:do_execveat_common      | 0          | 3          |               |
| backtrace:do_exit                 | 0          | 5          |               |
+-----------------------------------+------------+------------+---------------+

[   17.687075] Freeing unused kernel memory: 1716K (c190d000 - c1aba000)
[   17.808897] random: init urandom read with 5 bits of entropy available
[   17.828360] ------------[ cut here ]------------
[   17.828989] WARNING: CPU: 1 PID: 681 at mm/mmap.c:2858 exit_mmap+0x197/0x1ad()
[   17.830086] Modules linked in:
[   17.830549] CPU: 1 PID: 681 Comm: init Not tainted 3.19.0-rc5-gf7a7b53 #19
[   17.831339]  00000001 00000000 00000001 d388bd4c c14341a1 00000000 00000001 c16ebf08
[   17.832421]  d388bd68 c1056987 00000b2a c1150db8 00000001 00000001 00000000 d388bd78
[   17.833488]  c1056a11 00000009 00000000 d388bdd0 c1150db8 d3858380 ffffffff ffffffff
[   17.841323] Call Trace:
[   17.844215]  [<c14341a1>] dump_stack+0x78/0xa8
[   17.844700]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   17.847797]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   17.850955]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   17.854131]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   17.854629]  [<c10537ff>] mmput+0x52/0xef
[   17.857584]  [<c1175602>] flush_old_exec+0x923/0x99d
[   17.860806]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   17.861378]  [<c108559f>] ? local_clock+0x2f/0x39
[   17.865327]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   17.866002]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   17.866588]  [<c11ac7e5>] load_script+0x339/0x355
[   17.874149]  [<c108550c>] ? sched_clock_cpu+0x188/0x1a3
[   17.874718]  [<c108559f>] ? local_clock+0x2f/0x39
[   17.878580]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   17.879355]  [<c109c1bf>] ? do_raw_read_unlock+0x28/0x53
[   17.879997]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   17.887644]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   17.890904]  [<c11762eb>] do_execve+0x19/0x1b
[   17.891389]  [<c1176586>] SyS_execve+0x21/0x25
[   17.895168]  [<c143be92>] syscall_call+0x7/0x7
[   17.895653] ---[ end trace 6a7094e9a1d04ce0 ]---
[   17.909585] ------------[ cut here ]------------

git bisect start de3d2c5b941c632685ab58613f981bf14a42676f ec6f34e5b552fb0a52e6aae1a5afbbb1605cc6cc --
git bisect good 505c8f8b41aaae2239941fc1c25bc8d4aa9188a6  # 08:42    369+      1  Merge remote-tracking branch 'kbuild/for-next'
git bisect good 5cdfab738b22d402bc764e9f5f93824ff5f3800f  # 08:46    369+      0  Merge remote-tracking branch 'audit/next'
git bisect good 551aa38a4d27c7e71791ded0ee4a746abe954f9b  # 08:53    369+      0  Merge remote-tracking branch 'usb-gadget/next'
git bisect good bf26a22140410ca8fee8de8d74d9b69eeac450d1  # 08:58    369+      3  Merge remote-tracking branch 'pwm/for-next'
git bisect good 522698e0cdb31f34ef897d463ddbe4d289a83b16  # 09:05    369+      1  Merge remote-tracking branch 'y2038/y2038'
git bisect good 879b01ab025b80f0350b3181f2eb86f1a3deadc2  # 09:10    369+      0  Merge remote-tracking branch 'livepatching/for-next'
git bisect  bad d347062b744695e0490a53c199fac1a184870d29  # 09:10      0-    156  Merge branch 'akpm-current/current'
git bisect  bad f7a7b53a90f7a489c4e435d1300db121f6b42776  # 09:34      0-      5  mm: account pmd page tables to the process
git bisect good 905d130bf8d5622c4dfa1667414993bb214d3a1e  # 10:50    369+      1  x86: drop _PAGE_FILE and pte_file()-related helpers
git bisect good daba3b6a1f18fc36eb6fe15eca008c3e658a8f72  # 11:39    369+      1  mm: numa: add paranoid check around pte_protnone_numa
git bisect good 077ccc6a5a442a0460aba99085a6b84578a01faf  # 12:21    369+      2  memcg: add BUILD_BUG_ON() for string tables
git bisect good 76c365c2fe9bc89844dee698b7d3382faa9afc75  # 12:31    369+      1  oom, PM: make OOM detection in the freezer path raceless
git bisect good 10c7667f091d0ab62b13d31f33bef469dc6683b4  # 13:27    369+      2  fs: shrinker: always scan at least one object of each type
git bisect good 8aac135aaf196fd1a0b8f9c08d3514b64cefc4b3  # 13:47    369+      1  mm: make FIRST_USER_ADDRESS unsigned long on all archs
git bisect good fe888c1f6277ea1b0d18dda12fff1dac4617905a  # 14:05    369+      1  arm: define __PAGETABLE_PMD_FOLDED for !LPAE
# first bad commit: [f7a7b53a90f7a489c4e435d1300db121f6b42776] mm: account pmd page tables to the process
git bisect good fe888c1f6277ea1b0d18dda12fff1dac4617905a  # 14:26   1000+      5  arm: define __PAGETABLE_PMD_FOLDED for !LPAE
# extra tests with DEBUG_INFO
git bisect good f7a7b53a90f7a489c4e435d1300db121f6b42776  # 14:46   1000+      0  mm: account pmd page tables to the process
# extra tests on HEAD of next/master
git bisect  bad de3d2c5b941c632685ab58613f981bf14a42676f  # 14:46      0-     19  Add linux-next specific files for 20150123
# extra tests on tree/branch next/master
git bisect  bad de3d2c5b941c632685ab58613f981bf14a42676f  # 14:46      0-     19  Add linux-next specific files for 20150123
# extra tests on tree/branch linus/master
git bisect good c4e00f1d31c4c83d15162782491689229bd92527  # 16:42   1000+      3  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mason/linux-btrfs
# extra tests on tree/branch next/master
git bisect  bad de3d2c5b941c632685ab58613f981bf14a42676f  # 16:43      0-     19  Add linux-next specific files for 20150123


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=quantal-core-i386.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-cpu kvm64
	-enable-kvm
	-kernel $kernel
	-initrd $initrd
	-m 320
	-smp 2
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

--jq0ap7NbKX2Kqbes
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-client9-17:20150124102932:i386-randconfig-x1-01141042:3.19.0-rc5-gf7a7b53:19"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.19.0-rc5-gf7a7b53 (kbuild@xian) (gcc version=
 4.9.1 (Debian 4.9.1-19) ) #19 SMP Sat Jan 24 09:29:59 CST 2015
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013fdffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013fe0000-0x0000000013ffffff] reser=
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
[    0.000000] e820: last_pfn =3D 0x13fe0 max_arch_pfn =3D 0x1000000
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
[    0.000000] PAT configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC =20
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0eb0-0x000f0ebf] mapped at =
[c00f0eb0]
[    0.000000]   mpc: f0ec0-f0fa4
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x025fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12400000-0x125fffff]
[    0.000000]  [mem 0x12400000-0x125fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x123fffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x123fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x12600000-0x13fdffff]
[    0.000000]  [mem 0x12600000-0x13dfffff] page 2M
[    0.000000]  [mem 0x13e00000-0x13fdffff] page 4k
[    0.000000] BRK [0x020e6000, 0x020e6fff] PGTABLE
[    0.000000] BRK [0x020e7000, 0x020e8fff] PGTABLE
[    0.000000] BRK [0x020e9000, 0x020e9fff] PGTABLE
[    0.000000] BRK [0x020ea000, 0x020eafff] PGTABLE
[    0.000000] RAMDISK: [mem 0x12793000-0x13fd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000F0C90 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x13FE18BD 000034 (v01 BOCHS  BXPCRSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACP 0x13FE0B37 000074 (v01 BOCHS  BXPCFACP 00000001 B=
XPC 00000001)
[    0.000000] ACPI: DSDT 0x13FE0040 000AF7 (v01 BOCHS  BXPCDSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACS 0x13FE0000 000040
[    0.000000] ACPI: SSDT 0x13FE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: APIC 0x13FE1805 000080 (v01 BOCHS  BXPCAPIC 00000001 B=
XPC 00000001)
[    0.000000] ACPI: HPET 0x13FE1885 000038 (v01 BOCHS  BXPCHPET 00000001 B=
XPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 13fe0000
[    0.000000]   low ram: 0 - 13fe0000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13fdf001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x0000000013fdffff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000013fdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000013fdf=
fff]
[    0.000000] On node 0 totalpages: 81790
[    0.000000] free_area_init_node: node 0, pgdat c17b2540, node_mem_map d2=
4c3024
[    0.000000]   DMA zone: 36 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 684 pages used for memmap
[    0.000000]   Normal zone: 77792 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
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
[    0.000000] mapped IOAPIC to ffffb000 (fec00000)
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_=
node_ids:1
[    0.000000] PERCPU: Embedded 336 pages/cpu @d2221000 s1346560 r0 d29696 =
u1376256
[    0.000000] pcpu-alloc: s1346560 r0 d29696 u1376256 alloc=3D336*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 12224780
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 81070
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/i386-r=
andconfig-x1-01141042/next:master:f7a7b53a90f7a489c4e435d1300db121f6b42776:=
bisect-linux-3/.vmlinuz-f7a7b53a90f7a489c4e435d1300db121f6b42776-2015012409=
3102-332-client9 branch=3Dnext/master BOOT_IMAGE=3D/kernel/i386-randconfig-=
x1-01141042/f7a7b53a90f7a489c4e435d1300db121f6b42776/vmlinuz-3.19.0-rc5-gf7=
a7b53 drbd.minor_count=3D8
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 278912K/327160K available (4340K kernel code, 1731K =
rwdata, 3184K rodata, 1716K init, 6236K bss, 48248K reserved, 0K cma-reserv=
ed, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffd36000 - 0xfffff000   (2852 kB)
[    0.000000]     pkmap   : 0xffa00000 - 0xffc00000   (2048 kB)
[    0.000000]     vmalloc : 0xd47e0000 - 0xff9fe000   ( 690 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xd3fe0000   ( 319 MB)
[    0.000000]       .init : 0xc190d000 - 0xc1aba000   (1716 kB)
[    0.000000]       .data : 0xc143d624 - 0xc190be80   (4922 kB)
[    0.000000]       .text : 0xc1000000 - 0xc143d624   (4341 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D2
[    0.000000] Testing tracer nop: PASSED
[    0.000000] NR_IRQS:2304 nr_irqs:440 16
[    0.000000] CPU 0 irqstacks, hard=3Dd1c1c000 soft=3Dd1c1e000
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.19.0-rc5-gf7a7b53 (kbuild@xian) (gcc version=
 4.9.1 (Debian 4.9.1-19) ) #19 SMP Sat Jan 24 09:29:59 CST 2015
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013fdffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013fe0000-0x0000000013ffffff] reser=
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
[    0.000000] e820: last_pfn =3D 0x13fe0 max_arch_pfn =3D 0x1000000
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
[    0.000000] PAT configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC =20
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0eb0-0x000f0ebf] mapped at =
[c00f0eb0]
[    0.000000]   mpc: f0ec0-f0fa4
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x025fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12400000-0x125fffff]
[    0.000000]  [mem 0x12400000-0x125fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x123fffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x123fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x12600000-0x13fdffff]
[    0.000000]  [mem 0x12600000-0x13dfffff] page 2M
[    0.000000]  [mem 0x13e00000-0x13fdffff] page 4k
[    0.000000] BRK [0x020e6000, 0x020e6fff] PGTABLE
[    0.000000] BRK [0x020e7000, 0x020e8fff] PGTABLE
[    0.000000] BRK [0x020e9000, 0x020e9fff] PGTABLE
[    0.000000] BRK [0x020ea000, 0x020eafff] PGTABLE
[    0.000000] RAMDISK: [mem 0x12793000-0x13fd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000F0C90 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x13FE18BD 000034 (v01 BOCHS  BXPCRSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACP 0x13FE0B37 000074 (v01 BOCHS  BXPCFACP 00000001 B=
XPC 00000001)
[    0.000000] ACPI: DSDT 0x13FE0040 000AF7 (v01 BOCHS  BXPCDSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACS 0x13FE0000 000040
[    0.000000] ACPI: SSDT 0x13FE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: APIC 0x13FE1805 000080 (v01 BOCHS  BXPCAPIC 00000001 B=
XPC 00000001)
[    0.000000] ACPI: HPET 0x13FE1885 000038 (v01 BOCHS  BXPCHPET 00000001 B=
XPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 13fe0000
[    0.000000]   low ram: 0 - 13fe0000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13fdf001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x0000000013fdffff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000013fdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000013fdf=
fff]
[    0.000000] On node 0 totalpages: 81790
[    0.000000] free_area_init_node: node 0, pgdat c17b2540, node_mem_map d2=
4c3024
[    0.000000]   DMA zone: 36 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 684 pages used for memmap
[    0.000000]   Normal zone: 77792 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
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
[    0.000000] mapped IOAPIC to ffffb000 (fec00000)
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_=
node_ids:1
[    0.000000] PERCPU: Embedded 336 pages/cpu @d2221000 s1346560 r0 d29696 =
u1376256
[    0.000000] pcpu-alloc: s1346560 r0 d29696 u1376256 alloc=3D336*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 12224780
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 81070
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/i386-r=
andconfig-x1-01141042/next:master:f7a7b53a90f7a489c4e435d1300db121f6b42776:=
bisect-linux-3/.vmlinuz-f7a7b53a90f7a489c4e435d1300db121f6b42776-2015012409=
3102-332-client9 branch=3Dnext/master BOOT_IMAGE=3D/kernel/i386-randconfig-=
x1-01141042/f7a7b53a90f7a489c4e435d1300db121f6b42776/vmlinuz-3.19.0-rc5-gf7=
a7b53 drbd.minor_count=3D8
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 278912K/327160K available (4340K kernel code, 1731K =
rwdata, 3184K rodata, 1716K init, 6236K bss, 48248K reserved, 0K cma-reserv=
ed, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffd36000 - 0xfffff000   (2852 kB)
[    0.000000]     pkmap   : 0xffa00000 - 0xffc00000   (2048 kB)
[    0.000000]     vmalloc : 0xd47e0000 - 0xff9fe000   ( 690 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xd3fe0000   ( 319 MB)
[    0.000000]       .init : 0xc190d000 - 0xc1aba000   (1716 kB)
[    0.000000]       .data : 0xc143d624 - 0xc190be80   (4922 kB)
[    0.000000]       .text : 0xc1000000 - 0xc143d624   (4341 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D2
[    0.000000] Testing tracer nop: PASSED
[    0.000000] NR_IRQS:2304 nr_irqs:440 16
[    0.000000] CPU 0 irqstacks, hard=3Dd1c1c000 soft=3Dd1c1e000
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
[    0.000000]  memory used by lock dependency info: 5151 kB
[    0.000000]  memory used by lock dependency info: 5151 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] ------------------------
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] | Locking API testsuite:
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]                      A-A deadlock:
[    0.000000]                      A-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]                  A-B-B-A deadlock:
[    0.000000]                  A-B-B-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]              A-B-B-C-C-A deadlock:
[    0.000000]              A-B-B-C-C-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]              A-B-C-A-B-C deadlock:
[    0.000000]              A-B-C-A-B-C deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-B-C-C-D-D-A deadlock:
[    0.000000]          A-B-B-C-C-D-D-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-C-D-B-D-D-A deadlock:
[    0.000000]          A-B-C-D-B-D-D-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-C-D-B-C-D-A deadlock:
[    0.000000]          A-B-C-D-B-C-D-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]                     double unlock:
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                   initialize held:
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                  bad unlock order:
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]               recursive read-lock:
[    0.000000]               recursive read-lock:             |            =
 |  ok  |  ok  |             |             |failed|failed|

[    0.000000]            recursive read-lock #2:
[    0.000000]            recursive read-lock #2:             |            =
 |  ok  |  ok  |             |             |failed|failed|

[    0.000000]             mixed read-write-lock:
[    0.000000]             mixed read-write-lock:             |            =
 |failed|failed|             |             |failed|failed|

[    0.000000]             mixed write-read-lock:
[    0.000000]             mixed write-read-lock:             |            =
 |failed|failed|             |             |failed|failed|

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:
[    0.000000]      hard-irqs-on + irq-safe-A/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/12:
[    0.000000]      soft-irqs-on + irq-safe-A/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]      hard-irqs-on + irq-safe-A/21:
[    0.000000]      hard-irqs-on + irq-safe-A/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/21:
[    0.000000]      soft-irqs-on + irq-safe-A/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/12:
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/21:
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/12:
[    0.000000]          hard-safe-A + irqs-on/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/12:
[    0.000000]          soft-safe-A + irqs-on/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/21:
[    0.000000]          hard-safe-A + irqs-on/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/21:
[    0.000000]          soft-safe-A + irqs-on/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/123:
[    0.000000]     hard-safe-A + unsafe-B #1/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/123:
[    0.000000]     soft-safe-A + unsafe-B #1/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/132:
[    0.000000]     hard-safe-A + unsafe-B #1/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/132:
[    0.000000]     soft-safe-A + unsafe-B #1/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/213:
[    0.000000]     hard-safe-A + unsafe-B #1/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/213:
[    0.000000]     soft-safe-A + unsafe-B #1/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/231:
[    0.000000]     hard-safe-A + unsafe-B #1/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/231:
[    0.000000]     soft-safe-A + unsafe-B #1/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/312:
[    0.000000]     hard-safe-A + unsafe-B #1/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/312:
[    0.000000]     soft-safe-A + unsafe-B #1/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/321:
[    0.000000]     hard-safe-A + unsafe-B #1/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/321:
[    0.000000]     soft-safe-A + unsafe-B #1/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/123:
[    0.000000]     hard-safe-A + unsafe-B #2/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/123:
[    0.000000]     soft-safe-A + unsafe-B #2/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/132:
[    0.000000]     hard-safe-A + unsafe-B #2/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/132:
[    0.000000]     soft-safe-A + unsafe-B #2/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/213:
[    0.000000]     hard-safe-A + unsafe-B #2/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/213:
[    0.000000]     soft-safe-A + unsafe-B #2/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/231:
[    0.000000]     hard-safe-A + unsafe-B #2/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/231:
[    0.000000]     soft-safe-A + unsafe-B #2/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/312:
[    0.000000]     hard-safe-A + unsafe-B #2/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/312:
[    0.000000]     soft-safe-A + unsafe-B #2/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/321:
[    0.000000]     hard-safe-A + unsafe-B #2/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/321:
[    0.000000]     soft-safe-A + unsafe-B #2/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/123:
[    0.000000]       hard-irq lock-inversion/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/123:
[    0.000000]       soft-irq lock-inversion/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/132:
[    0.000000]       hard-irq lock-inversion/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/132:
[    0.000000]       soft-irq lock-inversion/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/213:
[    0.000000]       hard-irq lock-inversion/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/213:
[    0.000000]       soft-irq lock-inversion/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/231:
[    0.000000]       hard-irq lock-inversion/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/231:
[    0.000000]       soft-irq lock-inversion/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/312:
[    0.000000]       hard-irq lock-inversion/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/312:
[    0.000000]       soft-irq lock-inversion/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/321:
[    0.000000]       hard-irq lock-inversion/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/321:
[    0.000000]       soft-irq lock-inversion/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/123:
[    0.000000]       hard-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/123:
[    0.000000]       soft-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/132:
[    0.000000]       hard-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/132:
[    0.000000]       soft-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/213:
[    0.000000]       hard-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/213:
[    0.000000]       soft-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/231:
[    0.000000]       hard-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/231:
[    0.000000]       soft-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/312:
[    0.000000]       hard-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/312:
[    0.000000]       soft-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/321:
[    0.000000]       hard-irq read-recursion/321:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/321:
[    0.000000]       soft-irq read-recursion/321:  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   | Wound/wait tests |
[    0.000000]   | Wound/wait tests |
[    0.000000]   ---------------------
[    0.000000]   ---------------------
[    0.000000]                   ww api failures:
[    0.000000]                   ww api failures:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                ww contexts mixing:
[    0.000000]                ww contexts mixing:failed|failed|  ok  |  ok =
 |

[    0.000000]              finishing ww context:
[    0.000000]              finishing ww context:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                locking mismatches:
[    0.000000]                locking mismatches:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                  EDEADLK handling:
[    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]            spinlock nest unlocked:
[    0.000000]            spinlock nest unlocked:  ok  |  ok  |

[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                                  |block | try  |context|
[    0.000000]                                  |block | try  |context|
[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                           context:
[    0.000000]                           context:failed|failed|  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                               try:
[    0.000000]                               try:failed|failed|  ok  |  ok =
 |failed|failed|

[    0.000000]                             block:
[    0.000000]                             block:failed|failed|  ok  |  ok =
 |failed|failed|

[    0.000000]                          spinlock:
[    0.000000]                          spinlock:failed|failed|  ok  |  ok =
 |failed|failed|

[    0.000000] --------------------------------------------------------
[    0.000000] --------------------------------------------------------
[    0.000000] 141 out of 253 testcases failed, as expected. |
[    0.000000] 141 out of 253 testcases failed, as expected. |
[    0.000000] ----------------------------------------------------
[    0.000000] ----------------------------------------------------
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2925.998 MHz processor
[    0.000000] tsc: Detected 2925.998 MHz processor
[    0.006666] Calibrating delay loop (skipped) preset value..=20
[    0.006666] Calibrating delay loop (skipped) preset value.. 5854.82 Bogo=
MIPS (lpj=3D9753326)
5854.82 BogoMIPS (lpj=3D9753326)
[    0.006682] pid_max: default: 32768 minimum: 301
[    0.006682] pid_max: default: 32768 minimum: 301
[    0.007767] ACPI: Core revision 20141107
[    0.007767] ACPI: Core revision 20141107
[    0.028993] ACPI:=20
[    0.028993] ACPI: All ACPI Tables successfully acquiredAll ACPI Tables s=
uccessfully acquired

[    0.030232] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.030232] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.033344] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 by=
tes)
[    0.033344] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 by=
tes)
[    0.035457] Initializing cgroup subsys memory
[    0.035457] Initializing cgroup subsys memory
[    0.036465] Initializing cgroup subsys devices
[    0.036465] Initializing cgroup subsys devices
[    0.036710] Initializing cgroup subsys freezer
[    0.036710] Initializing cgroup subsys freezer
[    0.037878] Initializing cgroup subsys perf_event
[    0.037878] Initializing cgroup subsys perf_event
[    0.040025] Initializing cgroup subsys hugetlb
[    0.040025] Initializing cgroup subsys hugetlb
[    0.041299] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.041299] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.041299] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.041299] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.043762] Freeing SMP alternatives memory: 8K (c1aba000 - c1abc000)
[    0.043762] Freeing SMP alternatives memory: 8K (c1aba000 - c1abc000)
[    0.047312] Getting VERSION: 1050014
[    0.047312] Getting VERSION: 1050014
[    0.048158] Getting VERSION: 1050014
[    0.048158] Getting VERSION: 1050014
[    0.049111] Getting ID: 0
[    0.049111] Getting ID: 0
[    0.049750] Getting ID: f000000
[    0.049750] Getting ID: f000000
[    0.050027] Getting LVT0: 8700
[    0.050027] Getting LVT0: 8700
[    0.050850] Getting LVT1: 8400
[    0.050850] Getting LVT1: 8400
[    0.051621] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.051621] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.053431] enabled ExtINT on CPU#0
[    0.053431] enabled ExtINT on CPU#0
[    0.055441] ENABLING IO-APIC IRQs
[    0.055441] ENABLING IO-APIC IRQs
[    0.056403] init IO_APIC IRQs
[    0.056403] init IO_APIC IRQs
[    0.060010]  apic 0 pin 0 not connected
[    0.060010]  apic 0 pin 0 not connected
[    0.060899] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.060899] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.062880] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.062880] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.063376] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.063376] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.066709] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.066709] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.068670] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.068670] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.070058] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.070058] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.073382] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.073382] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.075395] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.075395] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.076724] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.076724] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.080036] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.080036] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.083375] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.083375] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.086714] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.086714] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.088633] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.088633] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.090052] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.090052] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.092086] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.092086] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.093391] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.093391] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.096705]  apic 0 pin 16 not connected
[    0.096705]  apic 0 pin 16 not connected
[    0.097606]  apic 0 pin 17 not connected
[    0.097606]  apic 0 pin 17 not connected
[    0.100009]  apic 0 pin 18 not connected
[    0.100009]  apic 0 pin 18 not connected
[    0.100909]  apic 0 pin 19 not connected
[    0.100909]  apic 0 pin 19 not connected
[    0.101917]  apic 0 pin 20 not connected
[    0.101917]  apic 0 pin 20 not connected
[    0.103349]  apic 0 pin 21 not connected
[    0.103349]  apic 0 pin 21 not connected
[    0.106672]  apic 0 pin 22 not connected
[    0.106672]  apic 0 pin 22 not connected
[    0.107557]  apic 0 pin 23 not connected
[    0.107557]  apic 0 pin 23 not connected
[    0.108632] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.108632] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.110013] smpboot: CPU0:=20
[    0.110013] smpboot: CPU0: Intel Intel Common KVM processorCommon KVM pr=
ocessor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.117243] Using local APIC timer interrupts.
[    0.117243] calibrating APIC timer ...
[    0.117243] Using local APIC timer interrupts.
[    0.117243] calibrating APIC timer ...
[    0.123333] ... lapic delta =3D 12083431
[    0.123333] ... lapic delta =3D 12083431
[    0.123333] ... PM-Timer delta =3D 692054
[    0.123333] ... PM-Timer delta =3D 692054
[    0.123333] APIC calibration not consistent with PM-Timer: 193ms instead=
 of 100ms
[    0.123333] APIC calibration not consistent with PM-Timer: 193ms instead=
 of 100ms
[    0.123333] APIC delta adjusted to PM-Timer: 6249963 (12083431)
[    0.123333] APIC delta adjusted to PM-Timer: 6249963 (12083431)
[    0.123333] TSC delta adjusted to PM-Timer: 292599887 (565700964)
[    0.123333] TSC delta adjusted to PM-Timer: 292599887 (565700964)
[    0.123333] ..... delta 6249963
[    0.123333] ..... delta 6249963
[    0.123333] ..... mult: 268433893
[    0.123333] ..... mult: 268433893
[    0.123333] ..... calibration result: 3333313
[    0.123333] ..... calibration result: 3333313
[    0.123333] ..... CPU clock speed is 2926.0971 MHz.
[    0.123333] ..... CPU clock speed is 2926.0971 MHz.
[    0.123333] ..... host bus clock speed is 1000.0313 MHz.
[    0.123333] ..... host bus clock speed is 1000.0313 MHz.
[    0.123474] Performance Events:=20
[    0.123474] Performance Events: unsupported Netburst CPU model 6 unsuppo=
rted Netburst CPU model 6 no PMU driver, software events only.
no PMU driver, software events only.
[    0.134523] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.134523] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.137204] CPU 1 irqstacks, hard=3Dd1ccc000 soft=3Dd1cce000
[    0.137204] CPU 1 irqstacks, hard=3Dd1ccc000 soft=3Dd1cce000
[    0.140008] x86: Booting SMP configuration:
[    0.140008] x86: Booting SMP configuration:
[    0.143347] .... node  #0, CPUs: =20
[    0.143347] .... node  #0, CPUs:         #1 #1
[    0.003333] Initializing CPU#1
[    0.006666] kvm-clock: cpu 1, msr 0:13fdf041, secondary cpu clock
[    0.006666] masked ExtINT on CPU#1
[    0.186766] x86: Booted up 1 node, 2 CPUs
[    0.186766] x86: Booted up 1 node, 2 CPUs
[    0.187653] smpboot: Total of 2 processors activated (11708.65 BogoMIPS)
[    0.187653] smpboot: Total of 2 processors activated (11708.65 BogoMIPS)
[    0.190991] devtmpfs: initialized
[    0.190991] devtmpfs: initialized
[    0.186680] KVM setup async PF for cpu 1
[    0.186680] KVM setup async PF for cpu 1
[    0.186680] kvm-stealtime: cpu 1, msr 12374780
[    0.186680] kvm-stealtime: cpu 1, msr 12374780
[    0.246697] Testing tracer function:=20
[    0.246697] Testing tracer function: PASSED
PASSED
[    0.401476] Testing ftrace regs(no arch support):=20
[    0.401476] Testing ftrace regs(no arch support): PASSED
PASSED
[    0.496690] Testing tracer irqsoff:=20
[    0.496690] Testing tracer irqsoff: PASSED
PASSED
[    0.620598] prandom: seed boundary self test passed
[    0.620598] prandom: seed boundary self test passed
[    0.622566] prandom: 100 self tests passed
[    0.622566] prandom: 100 self tests passed
[    0.624602] NET: Registered protocol family 16
[    0.624602] NET: Registered protocol family 16
[    0.640022] cpuidle: using governor ladder
[    0.640022] cpuidle: using governor ladder
[    0.653355] cpuidle: using governor menu
[    0.653355] cpuidle: using governor menu
[    0.654694] ACPI: bus type PCI registered
[    0.654694] ACPI: bus type PCI registered
[    0.658639] PCI : PCI BIOS area is rw and x. Use pci=3Dnobios if you wan=
t it NX.
[    0.658639] PCI : PCI BIOS area is rw and x. Use pci=3Dnobios if you wan=
t it NX.
[    0.660015] PCI: PCI BIOS revision 2.10 entry at 0xfd456, last bus=3D0
[    0.660015] PCI: PCI BIOS revision 2.10 entry at 0xfd456, last bus=3D0
[    0.661427] PCI: Using configuration type 1 for base access
[    0.661427] PCI: Using configuration type 1 for base access
[    0.720090] Running resizable hashtable tests...
[    0.720090] Running resizable hashtable tests...
[    0.721106]   Adding 2048 keys
[    0.721106]   Adding 2048 keys
[    1.085811]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    1.085811]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    1.086957]   Table expansion iteration 0...
[    1.086957]   Table expansion iteration 0...
[    1.136732]   Verifying lookups...
[    1.136732]   Verifying lookups...
[    1.137899]   Table expansion iteration 1...
[    1.137899]   Table expansion iteration 1...
[    1.176765]   Verifying lookups...
[    1.176765]   Verifying lookups...
[    1.177873]   Table expansion iteration 2...
[    1.177873]   Table expansion iteration 2...
[    1.203492]   Verifying lookups...
[    1.203492]   Verifying lookups...
[    1.204594]   Table expansion iteration 3...
[    1.204594]   Table expansion iteration 3...
[    1.230279]   Verifying lookups...
[    1.230279]   Verifying lookups...
[    1.231311]   Table shrinkage iteration 0...
[    1.231311]   Table shrinkage iteration 0...
[    1.243368]   Verifying lookups...
[    1.243368]   Verifying lookups...
[    1.244510]   Table shrinkage iteration 1...
[    1.244510]   Table shrinkage iteration 1...
[    1.256702]   Verifying lookups...
[    1.256702]   Verifying lookups...
[    1.257737]   Table shrinkage iteration 2...
[    1.257737]   Table shrinkage iteration 2...
[    1.270028]   Verifying lookups...
[    1.270028]   Verifying lookups...
[    1.271022]   Table shrinkage iteration 3...
[    1.271022]   Table shrinkage iteration 3...
[    1.283360]   Verifying lookups...
[    1.283360]   Verifying lookups...
[    1.284635]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    1.284635]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    1.286323]   Deleting 2048 keys
[    1.286323]   Deleting 2048 keys
[    1.417235] ACPI: Added _OSI(Module Device)
[    1.417235] ACPI: Added _OSI(Module Device)
[    1.418324] ACPI: Added _OSI(Processor Device)
[    1.418324] ACPI: Added _OSI(Processor Device)
[    1.419431] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.419431] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.420011] ACPI: Added _OSI(Processor Aggregator Device)
[    1.420011] ACPI: Added _OSI(Processor Aggregator Device)
[    1.425683] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:3)
[    1.425683] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:3)
[    1.444927] ACPI: Interpreter enabled
[    1.444927] ACPI: Interpreter enabled
[    1.446703] ACPI: (supports S0 S5)
[    1.446703] ACPI: (supports S0 S5)
[    1.447598] ACPI: Using IOAPIC for interrupt routing
[    1.447598] ACPI: Using IOAPIC for interrupt routing
[    1.448998] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    1.448998] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    1.494068] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.494068] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.496684] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    1.496684] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    1.498078] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.498078] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.500751] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    1.500751] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    1.503562] PCI host bridge to bus 0000:00
[    1.503562] PCI host bridge to bus 0000:00
[    1.506681] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.506681] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.507843] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.507843] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.510011] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff]
[    1.510011] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff]
[    1.511344] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff]
[    1.511344] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff]
[    1.513346] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf]
[    1.513346] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf]
[    1.514668] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff]
[    1.514668] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff]
[    1.516679] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    1.516679] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    1.518132] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebffff=
f]
[    1.518132] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebffff=
f]
[    1.520084] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.520084] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.524486] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.524486] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.536916] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.536916] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.544303] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    1.544303] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    1.547934] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    1.547934] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    1.550008] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.550008] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.553341] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    1.553341] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    1.556674] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.556674] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.563532] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    1.563532] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    1.565257] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    1.565257] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    1.566687] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    1.566687] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    1.570890] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    1.570890] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    1.574663] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    1.574663] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    1.580577] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    1.580577] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    1.591864] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    1.591864] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    1.594147] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    1.594147] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    1.600148] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    1.600148] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    1.602501] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    1.602501] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    1.613345] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    1.613345] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    1.617505] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    1.617505] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    1.623669] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    1.623669] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    1.632709] pci_bus 0000:00: on NUMA node 0
[    1.632709] pci_bus 0000:00: on NUMA node 0
[    1.635469] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    1.635469] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    1.637568] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    1.637568] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    1.643525] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    1.643525] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    1.645440] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    1.645440] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    1.650412] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    1.650412] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    1.657524] ACPI:=20
[    1.657524] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    1.667024] vgaarb: setting as boot device: PCI:0000:00:02.0
[    1.667024] vgaarb: setting as boot device: PCI:0000:00:02.0
[    1.668413] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    1.668413] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    1.670012] vgaarb: loaded
[    1.670012] vgaarb: loaded
[    1.670600] vgaarb: bridge control possible 0000:00:02.0
[    1.670600] vgaarb: bridge control possible 0000:00:02.0
[    1.677037] Linux video capture interface: v2.00
[    1.677037] Linux video capture interface: v2.00
[    1.680056] pps_core: LinuxPPS API ver. 1 registered
[    1.680056] pps_core: LinuxPPS API ver. 1 registered
[    1.681080] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    1.681080] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    1.687160] PCI: Using ACPI for IRQ routing
[    1.687160] PCI: Using ACPI for IRQ routing
[    1.690009] PCI: pci_cache_line_size set to 64 bytes
[    1.690009] PCI: pci_cache_line_size set to 64 bytes
[    1.691647] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.691647] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.693349] e820: reserve RAM buffer [mem 0x13fe0000-0x13ffffff]
[    1.693349] e820: reserve RAM buffer [mem 0x13fe0000-0x13ffffff]
[    1.697825] Switched to clocksource kvm-clock
[    1.697825] Switched to clocksource kvm-clock
[    1.706637] Warning: could not register all branches stats
[    1.706637] Warning: could not register all branches stats
[    1.711317] Warning: could not register annotated branches stats
[    1.711317] Warning: could not register annotated branches stats
[    1.803462] pnp: PnP ACPI init
[    1.803462] pnp: PnP ACPI init
[    1.804544] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    1.804544] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    1.809198] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.809198] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.816921] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    1.816921] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    1.819438] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.819438] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.825967] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    1.825967] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    1.832296] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.832296] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.838782] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    1.838782] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    1.844697] pnp 00:03: [dma 2]
[    1.844697] pnp 00:03: [dma 2]
[    1.848233] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.848233] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.849930] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    1.849930] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    1.858639] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.858639] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.864556] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    1.864556] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    1.869039] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.869039] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.879046] pnp: PnP ACPI: found 6 devices
[    1.879046] pnp: PnP ACPI: found 6 devices
[    1.930344] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.930344] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.932236] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff]
[    1.932236] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff]
[    1.940920] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff]
[    1.940920] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff]
[    1.945228] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf]
[    1.945228] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf]
[    1.946393] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff]
[    1.946393] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff]
[    1.953743] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff]
[    1.953743] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff]
[    1.957126] pci_bus 0000:00: resource 10 [mem 0x14000000-0xfebfffff]
[    1.957126] pci_bus 0000:00: resource 10 [mem 0x14000000-0xfebfffff]
[    1.959220] NET: Registered protocol family 1
[    1.959220] NET: Registered protocol family 1
[    1.966757] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.966757] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.970138] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.970138] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.972196] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.972196] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.977817] pci 0000:00:02.0: Video device with shadowed ROM
[    1.977817] pci 0000:00:02.0: Video device with shadowed ROM
[    1.981751] PCI: CLS 0 bytes, default 64
[    1.981751] PCI: CLS 0 bytes, default 64
[    1.985119] Unpacking initramfs...
[    1.985119] Unpacking initramfs...
[    6.640678] Freeing initrd memory: 24852K (d2793000 - d3fd8000)
[    6.640678] Freeing initrd memory: 24852K (d2793000 - d3fd8000)
[    6.642899] Scanning for low memory corruption every 60 seconds
[    6.642899] Scanning for low memory corruption every 60 seconds
[    6.664288] cryptomgr_test (26) used greatest stack depth: 7088 bytes le=
ft
[    6.664288] cryptomgr_test (26) used greatest stack depth: 7088 bytes le=
ft
[    6.680724] PCLMULQDQ-NI instructions are not detected.
[    6.680724] PCLMULQDQ-NI instructions are not detected.
[    6.681956] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[    6.681956] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[    6.683997] spin_lock-torture:--- Start of test [debug]: nwriters_stress=
=3D4 nreaders_stress=3D0 stat_interval=3D60 verbose=3D1 shuffle_interval=3D=
3 stutter=3D5 shutdown_secs=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    6.683997] spin_lock-torture:--- Start of test [debug]: nwriters_stress=
=3D4 nreaders_stress=3D0 stat_interval=3D60 verbose=3D1 shuffle_interval=3D=
3 stutter=3D5 shutdown_secs=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    6.694269] spin_lock-torture: Creating torture_shuffle task
[    6.694269] spin_lock-torture: Creating torture_shuffle task
[    6.696799] spin_lock-torture: torture_shuffle task started
[    6.696799] spin_lock-torture: torture_shuffle task started
[    6.698045] spin_lock-torture: Creating torture_stutter task
[    6.698045] spin_lock-torture: Creating torture_stutter task
[    6.703459] spin_lock-torture: torture_stutter task started
[    6.703459] spin_lock-torture: torture_stutter task started
[    6.706857] spin_lock-torture: Creating lock_torture_writer task
[    6.706857] spin_lock-torture: Creating lock_torture_writer task
[    6.708335] spin_lock-torture: lock_torture_writer task started
[    6.708335] spin_lock-torture: lock_torture_writer task started
[    6.714969] spin_lock-torture: Creating lock_torture_writer task
[    6.714969] spin_lock-torture: Creating lock_torture_writer task
[    6.723217] spin_lock-torture: lock_torture_writer task started
[    6.723217] spin_lock-torture: lock_torture_writer task started
[    6.740097] spin_lock-torture: Creating lock_torture_writer task
[    6.740097] spin_lock-torture: Creating lock_torture_writer task
[    6.743456] spin_lock-torture: lock_torture_writer task started
[    6.743456] spin_lock-torture: lock_torture_writer task started
[    6.751966] spin_lock-torture: Creating lock_torture_writer task
[    6.751966] spin_lock-torture: Creating lock_torture_writer task
[    6.767216] spin_lock-torture: Creating lock_torture_stats task
[    6.767216] spin_lock-torture: Creating lock_torture_stats task
[    6.768683] spin_lock-torture: lock_torture_writer task started
[    6.768683] spin_lock-torture: lock_torture_writer task started
[    6.775057] torture_init_begin: refusing rcu init: spin_lock running
[    6.775057] torture_init_begin: refusing rcu init: spin_lock running

[    6.778172] futex hash table entries: 512 (order: 3, 32768 bytes)
[    6.778172] futex hash table entries: 512 (order: 3, 32768 bytes)
[    6.779673] Initialise system trusted keyring
[    6.779673] Initialise system trusted keyring
[    6.780876] Kprobe smoke test: started
[    6.780876] Kprobe smoke test: started
[    6.802243] spin_lock-torture: lock_torture_stats task started
[    6.802243] spin_lock-torture: lock_torture_stats task started
[    6.910223] Kprobe smoke test: passed successfully
[    6.910223] Kprobe smoke test: passed successfully
[    6.912403] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    6.912403] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    6.913867] page_owner is disabled
[    6.913867] page_owner is disabled
[    6.919029] Key type asymmetric registered
[    6.919029] Key type asymmetric registered
[    6.919955] Asymmetric key parser 'x509' registered
[    6.919955] Asymmetric key parser 'x509' registered
[    6.921044] start plist test
[    6.921044] start plist test
[    6.949816] end plist test
[    6.949816] end plist test
[    6.957267] test_string_helpers: Running tests...
[    6.957267] test_string_helpers: Running tests...
[    6.987163] xz_dec_test: module loaded
[    6.987163] xz_dec_test: module loaded
[    6.988051] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
251 0' and write .xz files to it.
[    6.988051] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
251 0' and write .xz files to it.
[    6.997136] ipmi message handler version 39.2
[    6.997136] ipmi message handler version 39.2
[    6.998175] IPMI SSIF Interface driver
[    6.998175] IPMI SSIF Interface driver
[    6.999872] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    6.999872] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    7.008276] ACPI: Power Button [PWRF]
[    7.008276] ACPI: Power Button [PWRF]
[    7.379445] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    7.379445] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    7.457001] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    7.457001] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    7.471197] [drm] Initialized drm 1.1.0 20060810
[    7.471197] [drm] Initialized drm 1.1.0 20060810
[    7.472385] dummy-irq: no IRQ given.  Use irq=3DN
[    7.472385] dummy-irq: no IRQ given.  Use irq=3DN
[    7.485799] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    7.485799] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    7.521289] serio: i8042 KBD port at 0x60,0x64 irq 1
[    7.521289] serio: i8042 KBD port at 0x60,0x64 irq 1
[    7.522483] serio: i8042 AUX port at 0x60,0x64 irq 12
[    7.522483] serio: i8042 AUX port at 0x60,0x64 irq 12
[    7.792045] tsc: Refined TSC clocksource calibration: 2925.999 MHz
[    7.792045] tsc: Refined TSC clocksource calibration: 2925.999 MHz
[    7.807697] mousedev: PS/2 mouse device common for all mice
[    7.807697] mousedev: PS/2 mouse device common for all mice
[    7.810505] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    7.810505] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    7.846843] rtc (null): invalid alarm value: 1900-1-24 0:0:0
[    7.846843] rtc (null): invalid alarm value: 1900-1-24 0:0:0
[    7.866089] rtc-test rtc-test.0: rtc core: registered test as rtc0
[    7.866089] rtc-test rtc-test.0: rtc core: registered test as rtc0
[    7.875161] rtc (null): invalid alarm value: 1900-1-24 0:0:0
[    7.875161] rtc (null): invalid alarm value: 1900-1-24 0:0:0
[    7.876615] rtc-test rtc-test.1: rtc core: registered test as rtc1
[    7.876615] rtc-test rtc-test.1: rtc core: registered test as rtc1
[    7.884811] i2c /dev entries driver
[    7.884811] i2c /dev entries driver
[    7.903929] Driver for 1-wire Dallas network protocol.
[    7.903929] Driver for 1-wire Dallas network protocol.
[    7.914196] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    7.914196] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    7.915653] 1-Wire driver for the DS2760 battery monitor chip - (c) 2004=
-2005, Szabolcs Gyurko
[    7.915653] 1-Wire driver for the DS2760 battery monitor chip - (c) 2004=
-2005, Szabolcs Gyurko
[    7.920486] sbc8360: Timeout set at 60000 ms
[    7.920486] sbc8360: Timeout set at 60000 ms
[    7.949054] cpu5wdt: misc_register failed
[    7.949054] cpu5wdt: misc_register failed
[    7.949907] w83877f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    7.949907] w83877f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    7.951433] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[    7.951433] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[    7.953068] wbsd: Winbond W83L51xD SD/MMC card interface driver
[    7.953068] wbsd: Winbond W83L51xD SD/MMC card interface driver
[    7.974437] wbsd: Copyright(c) Pierre Ossman
[    7.974437] wbsd: Copyright(c) Pierre Ossman
[    7.976470] ledtrig-cpu: registered to indicate activity on CPUs
[    7.976470] ledtrig-cpu: registered to indicate activity on CPUs
[    7.978604] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    7.978604] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    8.006178] ... APIC ID:      00000000 (0)
[    8.006178] ... APIC ID:      00000000 (0)
[    8.007078] ... APIC VERSION: 01050014
[    8.007078] ... APIC VERSION: 01050014
[    8.007913] 00000000
[    8.007913] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    8.008611] 00000000
[    8.008611] 000000000e2000000e200000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    8.008611] 00000000
[    8.008611] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000800000008000

[    8.008611]=20
[    8.008611]=20
[    8.027319] number of MP IRQ sources: 15.
[    8.027319] number of MP IRQ sources: 15.
[    8.028243] number of IO-APIC #0 registers: 24.
[    8.028243] number of IO-APIC #0 registers: 24.
[    8.029202] testing the IO APIC.......................
[    8.029202] testing the IO APIC.......................
[    8.030330] IO APIC #0......
[    8.030330] IO APIC #0......
[    8.051020] .... register #00: 00000000
[    8.051020] .... register #00: 00000000
[    8.051871] .......    : physical APIC id: 00
[    8.051871] .......    : physical APIC id: 00
[    8.052813] .......    : Delivery Type: 0
[    8.052813] .......    : Delivery Type: 0
[    8.053707] .......    : LTS          : 0
[    8.053707] .......    : LTS          : 0
[    8.054613] .... register #01: 00170011
[    8.054613] .... register #01: 00170011
[    8.055432] .......     : max redirection entries: 17
[    8.055432] .......     : max redirection entries: 17
[    8.056539] .......     : PRQ implemented: 0
[    8.056539] .......     : PRQ implemented: 0
[    8.057476] .......     : IO APIC version: 11
[    8.057476] .......     : IO APIC version: 11
[    8.079612] .... register #02: 00000000
[    8.079612] .... register #02: 00000000
[    8.080653] .......     : arbitration: 00
[    8.080653] .......     : arbitration: 00
[    8.087924] .... IRQ redirection table:
[    8.087924] .... IRQ redirection table:
[    8.088947] 1    0    0   0   0    0    0    00
[    8.088947] 1    0    0   0   0    0    0    00
[    8.090163] 0    0    0   0   0    1    1    31
[    8.090163] 0    0    0   0   0    1    1    31
[    8.091179] 0    0    0   0   0    1    1    30
[    8.091179] 0    0    0   0   0    1    1    30
[    8.092161] 0    0    0   0   0    1    1    33
[    8.092161] 0    0    0   0   0    1    1    33
[    8.093145] 1    0    0   0   0    1    1    34
[    8.093145] 1    0    0   0   0    1    1    34
[    8.115191] 1    1    0   0   0    1    1    35
[    8.115191] 1    1    0   0   0    1    1    35
[    8.116178] 0    0    0   0   0    1    1    36
[    8.116178] 0    0    0   0   0    1    1    36
[    8.117197] 0    0    0   0   0    1    1    37
[    8.117197] 0    0    0   0   0    1    1    37
[    8.118345] 0    0    0   0   0    1    1    38
[    8.118345] 0    0    0   0   0    1    1    38
[    8.119576] 0    1    0   0   0    1    1    39
[    8.119576] 0    1    0   0   0    1    1    39
[    8.120664] 1    1    0   0   0    1    1    3A
[    8.120664] 1    1    0   0   0    1    1    3A
[    8.121651] 1    1    0   0   0    1    1    3B
[    8.121651] 1    1    0   0   0    1    1    3B
[    8.142834] 0    0    0   0   0    1    1    3C
[    8.142834] 0    0    0   0   0    1    1    3C
[    8.143918] 0    0    0   0   0    1    1    3D
[    8.143918] 0    0    0   0   0    1    1    3D
[    8.144905] 0    0    0   0   0    1    1    3E
[    8.144905] 0    0    0   0   0    1    1    3E
[    8.145865] 0    0    0   0   0    1    1    3F
[    8.145865] 0    0    0   0   0    1    1    3F
[    8.146854] 1    0    0   0   0    0    0    00
[    8.146854] 1    0    0   0   0    0    0    00
[    8.147861] 1    0    0   0   0    0    0    00
[    8.147861] 1    0    0   0   0    0    0    00
[    8.148874] 1    0    0   0   0    0    0    00
[    8.148874] 1    0    0   0   0    0    0    00
[    8.168119] 1    0    0   0   0    0    0    00
[    8.168119] 1    0    0   0   0    0    0    00
[    8.172452] 1    0    0   0   0    0    0    00
[    8.172452] 1    0    0   0   0    0    0    00
[    8.173469] 1    0    0   0   0    0    0    00
[    8.173469] 1    0    0   0   0    0    0    00
[    8.177969] 1    0    0   0   0    0    0    00
[    8.177969] 1    0    0   0   0    0    0    00
[    8.182310] 1    0    0   0   0    0    0    00
[    8.182310] 1    0    0   0   0    0    0    00
[    8.183298] IRQ to pin mappings:
[    8.183298] IRQ to pin mappings:
[    8.187555] IRQ0=20
[    8.187555] IRQ0 -> 0:2-> 0:2

[    8.188262] IRQ1=20
[    8.188262] IRQ1 -> 0:1-> 0:1

[    8.192264] IRQ3=20
[    8.192264] IRQ3 -> 0:3-> 0:3

[    8.192817] IRQ4=20
[    8.192817] IRQ4 -> 0:4-> 0:4

[    8.193397] IRQ5=20
[    8.193397] IRQ5 -> 0:5-> 0:5

[    8.198760] IRQ6=20
[    8.198760] IRQ6 -> 0:6-> 0:6

[    8.199343] IRQ7=20
[    8.199343] IRQ7 -> 0:7-> 0:7

[    8.199895] IRQ8=20
[    8.199895] IRQ8 -> 0:8-> 0:8

[    8.205180] IRQ9=20
[    8.205180] IRQ9 -> 0:9-> 0:9

[    8.205737] IRQ10=20
[    8.205737] IRQ10 -> 0:10-> 0:10

[    8.206341] IRQ11=20
[    8.206341] IRQ11 -> 0:11-> 0:11

[    8.210577] IRQ12=20
[    8.210577] IRQ12 -> 0:12-> 0:12

[    8.211198] IRQ13=20
[    8.211198] IRQ13 -> 0:13-> 0:13

[    8.214115] IRQ14=20
[    8.214115] IRQ14 -> 0:14-> 0:14

[    8.214844] IRQ15=20
[    8.214844] IRQ15 -> 0:15-> 0:15

[    8.217785] .................................... done.
[    8.217785] .................................... done.
[    8.222236] Using IPI Shortcut mode
[    8.222236] Using IPI Shortcut mode
[    8.247707] bootconsole [earlyser0] disabled
[    8.247707] bootconsole [earlyser0] disabled
[    8.248762] Loading compiled-in X.509 certificates
[    8.267645] Loaded X.509 cert 'Magrathea: Glacier signing key: eeb1b05cf=
6d1f0cc4de758239197d7c73071b5a3'
[    8.269190] Running tests on trace events:
[    8.269648] Testing event thermal_apic_exit:=20
[    8.300236] test-events (69) used greatest stack depth: 7008 bytes left
[    8.301267] OK
[    8.301462] Testing event thermal_apic_entry:=20
[    8.320183] test-events (71) used greatest stack depth: 6904 bytes left
[    8.321145] OK
[    8.321347] Testing event threshold_apic_exit: OK
[    8.347001] Testing event threshold_apic_entry: OK
[    8.360372] Testing event call_function_single_exit: OK
[    8.373723] Testing event call_function_single_entry: OK
[    8.390297] Testing event call_function_exit: OK
[    8.410345] Testing event call_function_entry: OK
[    8.423727] Testing event irq_work_exit: OK
[    8.440336] Testing event irq_work_entry: OK
[    8.456971] Testing event x86_platform_ipi_exit: OK
[    8.473658] Testing event x86_platform_ipi_entry: OK
[    8.487028] Testing event error_apic_exit: OK
[    8.500375] Testing event error_apic_entry: OK
[    8.516985] Testing event spurious_apic_exit: OK
[    8.530269] Testing event spurious_apic_entry: OK
[    8.546994] Testing event reschedule_exit: OK
[    8.563718] Testing event reschedule_entry: OK
[    8.587007] Testing event local_timer_exit: OK
[    8.610307] Testing event local_timer_entry: OK
[    8.636981] Testing event nmi_handler: OK
[    8.650320] Testing event sys_exit: OK
[    8.663585] Testing event sys_enter: OK
[    8.680348] Testing event tlb_flush: OK
[    8.693891] Testing event page_fault_kernel: OK
[    8.706983] Testing event page_fault_user: OK
[    8.730345] Testing event task_rename: OK
[    8.743606] Testing event task_newtask: OK
[    8.756978] Testing event softirq_raise: OK
[    8.770429] Testing event softirq_exit: OK
[    8.783695] Testing event softirq_entry: OK
[    8.797007] Testing event irq_handler_exit: OK
[    8.810279] Testing event irq_handler_entry: OK
[    8.823618] Testing event signal_deliver: OK
[    8.836982] Testing event signal_generate: OK
[    8.850321] Testing event workqueue_execute_end: OK
[    8.863660] Testing event workqueue_execute_start: OK
[    8.876945] Testing event workqueue_activate_work: OK
[    8.890264] Testing event workqueue_queue_work:=20
[    8.896761] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input3
[    8.903548] OK
[    8.903778] Testing event sched_wake_idle_without_ipi: OK
[    8.923643] Testing event sched_swap_numa: OK
[    8.936965] Testing event sched_stick_numa: OK
[    8.950359] Testing event sched_move_numa: OK
[    8.963670] Testing event sched_process_hang: OK
[    8.976965] Testing event sched_pi_setprio: OK
[    8.990272] Testing event sched_stat_runtime:=20
[    9.003512] test-events (117) used greatest stack depth: 6880 bytes left
[    9.004398] OK
[    9.004600] Testing event sched_stat_blocked: OK
[    9.017010] Testing event sched_stat_iowait: OK
[    9.030324] Testing event sched_stat_sleep: OK
[    9.043628] Testing event sched_stat_wait: OK
[    9.056957] Testing event sched_process_exec: OK
[    9.070274] Testing event sched_process_fork: OK
[    9.083715] Testing event sched_process_wait: OK
[    9.097029] Testing event sched_wait_task: OK
[    9.110319] Testing event sched_process_exit: OK
[    9.123654] Testing event sched_process_free: OK
[    9.136993] Testing event sched_migrate_task: OK
[    9.150374] Testing event sched_switch: OK
[    9.163707] Testing event sched_wakeup_new: OK
[    9.176969] Testing event sched_wakeup: OK
[    9.190312] Testing event sched_kthread_stop_ret: OK
[    9.203659] Testing event sched_kthread_stop: OK
[    9.217055] Testing event lock_acquired: OK
[    9.230470] Testing event lock_contended: OK
[    9.243644] Testing event lock_release:=20
[    9.256935] test-events (136) used greatest stack depth: 6848 bytes left
[    9.257804] OK
[    9.258017] Testing event lock_acquire:=20
[    9.270257] test-events (137) used greatest stack depth: 6832 bytes left
[    9.271153] OK
[    9.271352] Testing event console: OK
[    9.283711] Testing event rcu_barrier: OK
[    9.297054] Testing event rcu_torture_read: OK
[    9.310278] Testing event rcu_batch_end: OK
[    9.323638] Testing event rcu_invoke_kfree_callback: OK
[    9.337090] Testing event rcu_invoke_callback: OK
[    9.350401] Testing event rcu_batch_start: OK
[    9.363681] Testing event rcu_kfree_callback: OK
[    9.376968] Testing event rcu_callback: OK
[    9.390299] Testing event rcu_prep_idle: OK
[    9.403631] Testing event rcu_dyntick: OK
[    9.417044] Testing event rcu_fqs: OK
[    9.430331] Testing event rcu_quiescent_state_report: OK
[    9.443621] Testing event rcu_unlock_preempted_task: OK
[    9.456973] Testing event rcu_preempt_task: OK
[    9.470276] Testing event rcu_nocb_wake: OK
[    9.483672] Testing event rcu_grace_period_init: OK
[    9.500317] Testing event rcu_future_grace_period: OK
[    9.513671] Testing event rcu_grace_period: OK
[    9.527513] Testing event rcu_utilization: OK
[    9.540293] Testing event itimer_expire: OK
[    9.553643] Testing event itimer_state: OK
[    9.566964] Testing event hrtimer_cancel: OK
[    9.583637] Testing event hrtimer_expire_exit: OK
[    9.597001] Testing event hrtimer_expire_entry: OK
[    9.610382] Testing event hrtimer_start: OK
[    9.623704] Testing event hrtimer_init: OK
[    9.636985] Testing event timer_cancel: OK
[    9.650320] Testing event timer_expire_exit: OK
[    9.663672] Testing event timer_expire_entry: OK
[    9.677013] Testing event timer_start: OK
[    9.690371] Testing event timer_init: OK
[    9.703665] Testing event module_request: OK
[    9.717004] Testing event module_free: OK
[    9.730340] Testing event module_load: OK
[    9.743673] Testing event ftrace_test_filter: OK
[    9.757027] Testing event dev_pm_qos_remove_request: OK
[    9.770294] Testing event dev_pm_qos_update_request: OK
[    9.783665] Testing event dev_pm_qos_add_request: OK
[    9.797005] Testing event pm_qos_update_flags: OK
[    9.810348] Testing event pm_qos_update_target: OK
[    9.823682] Testing event pm_qos_update_request_timeout: OK
[    9.836963] Testing event pm_qos_remove_request: OK
[    9.850319] Testing event pm_qos_update_request: OK
[    9.863621] Testing event pm_qos_add_request: OK
[    9.877044] Testing event power_domain_target: OK
[    9.890349] Testing event clock_set_rate: OK
[    9.903648] Testing event clock_disable: OK
[    9.916981] Testing event clock_enable: OK
[    9.930331] Testing event wakeup_source_deactivate: OK
[    9.943676] Testing event wakeup_source_activate: OK
[    9.957042] Testing event suspend_resume: OK
[    9.970308] Testing event device_pm_callback_end: OK
[    9.983652] Testing event device_pm_callback_start: OK
[    9.997014] Testing event cpu_frequency: OK
[   10.010342] Testing event pstate_sample: OK
[   10.023679] Testing event cpu_idle: OK
[   10.037023] Testing event benchmark_event: OK
[   10.143641] Testing event mm_filemap_add_to_page_cache: OK
[   10.157014] Testing event mm_filemap_delete_from_page_cache: OK
[   10.170323] Testing event oom_score_adj_update: OK
[   10.183658] Testing event mm_lru_activate: OK
[   10.197019] Testing event mm_lru_insertion: OK
[   10.210340] Testing event mm_vmscan_lru_shrink_inactive: OK
[   10.223675] Testing event mm_vmscan_writepage: OK
[   10.236998] Testing event mm_vmscan_memcg_isolate: OK
[   10.250286] Testing event mm_vmscan_lru_isolate: OK
[   10.263701] Testing event mm_shrink_slab_end: OK
[   10.277897] Testing event mm_shrink_slab_start: OK
[   10.290345] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   10.303628] Testing event mm_vmscan_memcg_reclaim_end: OK
[   10.317005] Testing event mm_vmscan_direct_reclaim_end: OK
[   10.330306] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   10.343711] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   10.357027] Testing event mm_vmscan_direct_reclaim_begin: OK
[   10.370319] Testing event mm_vmscan_wakeup_kswapd: OK
[   10.383664] Testing event mm_vmscan_kswapd_wake: OK
[   10.396973] Testing event mm_vmscan_kswapd_sleep: OK
[   10.410319] Testing event mm_page_alloc_extfrag: OK
[   10.423730] Testing event mm_page_pcpu_drain: OK
[   10.436950] Testing event mm_page_alloc_zone_locked: OK
[   10.450271] Testing event mm_page_alloc: OK
[   10.463676] Testing event mm_page_free_batched: OK
[   10.477035] Testing event mm_page_free: OK
[   10.490328] Testing event kmem_cache_free: OK
[   10.503606] Testing event kfree: OK
[   10.516986] Testing event kmem_cache_alloc_node: OK
[   10.530282] Testing event kmalloc_node: OK
[   10.543659] Testing event kmem_cache_alloc: OK
[   10.557038] Testing event kmalloc: OK
[   10.570269] Testing event writeback_single_inode: OK
[   10.583630] Testing event writeback_single_inode_start: OK
[   10.596952] Testing event writeback_wait_iff_congested: OK
[   10.610345] Testing event writeback_congestion_wait: OK
[   10.623644] Testing event writeback_sb_inodes_requeue: OK
[   10.636950] Testing event balance_dirty_pages: OK
[   10.650300] Testing event bdi_dirty_ratelimit: OK
[   10.663659] Testing event global_dirty_state: OK
[   10.677089] Testing event writeback_queue_io: OK
[   10.690368] Testing event wbc_writepage: OK
[   10.703618] Testing event writeback_bdi_unregister: OK
[   10.716961] Testing event writeback_bdi_register: OK
[   10.730305] Testing event writeback_wake_background: OK
[   10.743672] Testing event writeback_nowork: OK
[   10.757003] Testing event writeback_pages_written: OK
[   10.770306] Testing event writeback_wait: OK
[   10.783622] Testing event writeback_written: OK
[   10.797001] Testing event writeback_start: OK
[   10.810348] Testing event writeback_exec: OK
[   10.823654] Testing event writeback_queue: OK
[   10.836951] Testing event writeback_write_inode: OK
[   10.850287] Testing event writeback_write_inode_start: OK
[   10.863624] Testing event writeback_dirty_inode: OK
[   10.876973] Testing event writeback_dirty_inode_start: OK
[   10.890330] Testing event writeback_dirty_page: OK
[   10.903645] Testing event gpio_value: OK
[   10.917162] Testing event gpio_direction: OK
[   10.930278] Testing event regulator_set_voltage_complete: OK
[   10.943676] Testing event regulator_set_voltage: OK
[   10.956998] Testing event regulator_disable_complete: OK
[   10.970302] Testing event regulator_disable: OK
[   10.983675] Testing event regulator_enable_complete: OK
[   10.996980] Testing event regulator_enable_delay: OK
[   11.010338] Testing event regulator_enable: OK
[   11.023667] Testing event urandom_read: OK
[   11.037041] Testing event random_read: OK
[   11.050280] Testing event extract_entropy_user: OK
[   11.063701] Testing event extract_entropy: OK
[   11.077047] Testing event get_random_bytes_arch: OK
[   11.090375] Testing event get_random_bytes: OK
[   11.103713] Testing event xfer_secondary_pool: OK
[   11.116994] Testing event add_disk_randomness: OK
[   11.130328] Testing event add_input_randomness: OK
[   11.143669] Testing event debit_entropy: OK
[   11.157029] Testing event push_to_pool: OK
[   11.170302] Testing event credit_entropy_bits: OK
[   11.183641] Testing event mix_pool_bytes_nolock: OK
[   11.197005] Testing event mix_pool_bytes: OK
[   11.210342] Testing event add_device_randomness: OK
[   11.223680] Testing event drm_vblank_event_delivered: OK
[   11.236939] Testing event drm_vblank_event_queued: OK
[   11.250308] Testing event drm_vblank_event: OK
[   11.263619] Testing event regcache_drop_region: OK
[   11.277013] Testing event regmap_async_complete_done: OK
[   11.290311] Testing event regmap_async_complete_start: OK
[   11.303625] Testing event regmap_async_io_complete: OK
[   11.317002] Testing event regmap_async_write_start: OK
[   11.330273] Testing event regmap_cache_bypass: OK
[   11.343712] Testing event regmap_cache_only: OK
[   11.356986] Testing event regcache_sync: OK
[   11.370318] Testing event regmap_hw_write_done: OK
[   11.383609] Testing event regmap_hw_write_start: OK
[   11.396958] Testing event regmap_hw_read_done: OK
[   11.410351] Testing event regmap_hw_read_start: OK
[   11.423649] Testing event regmap_reg_read_cache: OK
[   11.436974] Testing event regmap_reg_read: OK
[   11.450317] Testing event regmap_reg_write: OK
[   11.463610] Testing event fence_wait_end: OK
[   11.477022] Testing event fence_wait_start: OK
[   11.490319] Testing event fence_signaled: OK
[   11.503591] Testing event fence_enable_signal: OK
[   11.516970] Testing event fence_destroy: OK
[   11.530302] Testing event fence_init: OK
[   11.543650] Testing event fence_emit: OK
[   11.556992] Testing event fence_annotate_wait_on: OK
[   11.570286] Testing event smbus_result: OK
[   11.583620] Testing event smbus_reply: OK
[   11.596956] Testing event smbus_read: OK
[   11.610493] Testing event smbus_write: OK
[   11.623729] Testing event i2c_result: OK
[   11.637005] Testing event i2c_reply: OK
[   11.650311] Testing event i2c_read: OK
[   11.663625] Testing event i2c_write: OK
[   11.677008] Testing event v4l2_qbuf: OK
[   11.690355] Testing event v4l2_dqbuf: OK
[   11.703640] Testing event thermal_zone_trip: OK
[   11.716980] Testing event cdev_update: OK
[   11.730300] Testing event thermal_temperature: OK
[   11.743684] Testing event udp_fail_queue_rcv_skb: OK
[   11.757044] Testing event sock_exceed_buf_limit: OK
[   11.770276] Testing event sock_rcvqueue_full: OK
[   11.783628] Testing event napi_poll: OK
[   11.796988] Testing event netif_rx_ni_entry: OK
[   11.810312] Testing event netif_rx_entry: OK
[   11.823656] Testing event netif_receive_skb_entry: OK
[   11.836943] Testing event napi_gro_receive_entry: OK
[   11.850299] Testing event napi_gro_frags_entry: OK
[   11.863657] Testing event netif_rx: OK
[   11.877037] Testing event netif_receive_skb: OK
[   11.890347] Testing event net_dev_queue: OK
[   11.903646] Testing event net_dev_xmit: OK
[   11.916979] Testing event net_dev_start_xmit: OK
[   11.930305] Testing event skb_copy_datagram_iovec: OK
[   11.943653] Testing event consume_skb: OK
[   11.957041] Testing event kfree_skb: OK
[   11.970306] Running tests on trace event systems:
[   11.970891] Testing event system skb: OK
[   11.983632] Testing event system net: OK
[   11.997003] Testing event system napi: OK
[   12.010362] Testing event system sock: OK
[   12.023676] Testing event system udp: OK
[   12.037685] Testing event system thermal: OK
[   12.050305] Testing event system v4l2: OK
[   12.063643] Testing event system i2c: OK
[   12.077101] Testing event system fence: OK
[   12.090334] Testing event system regmap: OK
[   12.107064] Testing event system drm: OK
[   12.120346] Testing event system random: OK
[   12.133661] Testing event system regulator: OK
[   12.147027] Testing event system gpio: OK
[   12.160317] Testing event system writeback: OK
[   12.173753] Testing event system kmem: OK
[   12.187112] Testing event system vmscan: OK
[   12.200305] Testing event system pagemap: OK
[   12.213609] Testing event system oom: OK
[   12.226973] Testing event system filemap: OK
[   12.240387] Testing event system benchmark: OK
[   12.350297] Testing event system power: OK
[   12.367024] Testing event system test: OK
[   12.380376] Testing event system module: OK
[   12.393684] Testing event system timer: OK
[   12.407104] Testing event system rcu: OK
[   12.423768] Testing event system printk: OK
[   12.437171] Testing event system lock: OK
[   12.450658] Testing event system sched: OK
[   12.463688] Testing event system workqueue: OK
[   12.477085] Testing event system signal: OK
[   12.490323] Testing event system irq: OK
[   12.503804] Testing event system task: OK
[   12.517068] Testing event system exceptions: OK
[   12.530331] Testing event system tlb: OK
[   12.543666] Testing event system raw_syscalls: OK
[   12.557011] Testing event system nmi: OK
[   12.570415] Testing event system irq_vectors: OK
[   12.583774] Running tests on all trace events:
[   12.584310] Testing all events: OK
[   12.703902] Running tests again, along with the function tracer
[   12.704763] Running tests on trace events:
[   12.705373] Testing event thermal_apic_exit: OK
[   12.720826] Testing event thermal_apic_entry:=20
[   12.747442] test-events (376) used greatest stack depth: 6560 bytes left
[   12.748659] OK
[   12.748961] Testing event threshold_apic_exit: OK
[   12.770836] Testing event threshold_apic_entry: OK
[   12.797422] Testing event call_function_single_exit: OK
[   12.817439] Testing event call_function_single_entry:=20
[   12.836656] test-events (380) used greatest stack depth: 6496 bytes left
[   12.838223] OK
[   12.838527] Testing event call_function_exit: OK
[   12.877797] Testing event call_function_entry: OK
[   12.905680] Testing event irq_work_exit: OK
[   12.920826] Testing event irq_work_entry: OK
[   12.944320] Testing event x86_platform_ipi_exit: OK
[   12.978428] Testing event x86_platform_ipi_entry: OK
[   12.990822] Testing event error_apic_exit: OK
[   13.004242] Testing event error_apic_entry: OK
[   13.021006] Testing event spurious_apic_exit: OK
[   13.050824] Testing event spurious_apic_entry: OK
[   13.067807] Testing event reschedule_exit: OK
[   13.094158] Testing event reschedule_entry: OK
[   13.117476] Testing event local_timer_exit: OK
[   13.150829] Testing event local_timer_entry: OK
[   13.181007] Testing event nmi_handler: OK
[   13.197462] Testing event sys_exit: OK
[   13.210810] Testing event sys_enter: OK
[   13.224355] Testing event tlb_flush: OK
[   13.237632] Testing event page_fault_kernel: OK
[   13.250784] Testing event page_fault_user: OK
[   13.274353] Testing event task_rename: OK
[   13.287446] Testing event task_newtask: OK
[   13.300760] Testing event softirq_raise: OK
[   13.314178] Testing event softirq_exit: OK
[   13.327768] Testing event softirq_entry: OK
[   13.341389] Testing event irq_handler_exit: OK
[   13.354001] Testing event irq_handler_entry: OK
[   13.371008] Testing event signal_deliver: OK
[   13.384201] Testing event signal_generate: OK
[   13.397554] Testing event workqueue_execute_end: OK
[   13.410840] Testing event workqueue_execute_start: OK
[   13.424322] Testing event workqueue_activate_work: OK
[   13.437664] Testing event workqueue_queue_work: OK
[   13.454200] Testing event sched_wake_idle_without_ipi: OK
[   13.471050] Testing event sched_swap_numa: OK
[   13.484143] Testing event sched_stick_numa: OK
[   13.497493] Testing event sched_move_numa: OK
[   13.510834] Testing event sched_process_hang: OK
[   13.524426] Testing event sched_pi_setprio: OK
[   13.537731] Testing event sched_stat_runtime: OK
[   13.550812] Testing event sched_stat_blocked: OK
[   13.564151] Testing event sched_stat_iowait: OK
[   13.577488] Testing event sched_stat_sleep: OK
[   13.591031] Testing event sched_stat_wait: OK
[   13.604412] Testing event sched_process_exec: OK
[   13.617482] Testing event sched_process_fork: OK
[   13.630816] Testing event sched_process_wait: OK
[   13.647720] Testing event sched_wait_task: OK
[   13.660784] Testing event sched_process_exit: OK
[   13.677508] Testing event sched_process_free: OK
[   13.690993] Testing event sched_migrate_task: OK
[   13.704431] Testing event sched_switch: OK
[   13.717581] Testing event sched_wakeup_new: OK
[   13.730819] Testing event sched_wakeup: OK
[   13.744008] Testing event sched_kthread_stop_ret: OK
[   13.760869] Testing event sched_kthread_stop: OK
[   13.774234] Testing event lock_acquired: OK
[   13.787833] Testing event lock_contended: OK
[   13.800968] Testing event lock_release: OK
[   13.814337] Testing event lock_acquire: OK
[   13.827616] Testing event console: OK
[   13.840797] Testing event rcu_barrier: OK
[   13.854419] Testing event rcu_torture_read: OK
[   13.867681] Testing event rcu_batch_end: OK
[   13.880844] Testing event rcu_invoke_kfree_callback: OK
[   13.897706] Testing event rcu_invoke_callback: OK
[   13.910874] Testing event rcu_batch_start: OK
[   13.924048] Testing event rcu_kfree_callback: OK
[   13.940853] Testing event rcu_callback: OK
[   13.957714] Testing event rcu_prep_idle: OK
[   13.974223] Testing event rcu_dyntick: OK
[   13.987402] Testing event rcu_fqs: OK
[   14.004223] Testing event rcu_quiescent_state_report: OK
[   14.017430] Testing event rcu_unlock_preempted_task: OK
[   14.034165] Testing event rcu_preempt_task: OK
[   14.047425] Testing event rcu_nocb_wake: OK
[   14.060882] Testing event rcu_grace_period_init: OK
[   14.074409] Testing event rcu_future_grace_period: OK
[   14.087728] Testing event rcu_grace_period: OK
[   14.100757] Testing event rcu_utilization: OK
[   14.114217] Testing event itimer_expire: OK
[   14.127528] Testing event itimer_state: OK
[   14.141087] Testing event hrtimer_cancel: OK
[   14.154334] Testing event hrtimer_expire_exit: OK
[   14.167458] Testing event hrtimer_expire_entry: OK
[   14.180764] Testing event hrtimer_start: OK
[   14.194067] Testing event hrtimer_init: OK
[   14.210806] Testing event timer_cancel: OK
[   14.224082] Testing event timer_expire_exit: OK
[   14.237751] Testing event timer_expire_entry: OK
[   14.254242] Testing event timer_start: OK
[   14.267631] Testing event timer_init: OK
[   14.284237] Testing event module_request: OK
[   14.297678] Testing event module_free: OK
[   14.311030] Testing event module_load: OK
[   14.324110] Testing event ftrace_test_filter: OK
[   14.337569] Testing event dev_pm_qos_remove_request: OK
[   14.354381] Testing event dev_pm_qos_update_request: OK
[   14.367564] Testing event dev_pm_qos_add_request: OK
[   14.380843] Testing event pm_qos_update_flags: OK
[   14.394294] Testing event pm_qos_update_target: OK
[   14.410900] Testing event pm_qos_update_request_timeout: OK
[   14.424258] Testing event pm_qos_remove_request: OK
[   14.440908] Testing event pm_qos_update_request: OK
[   14.454324] Testing event pm_qos_add_request: OK
[   14.470800] Testing event power_domain_target: OK
[   14.484415] Testing event clock_set_rate: OK
[   14.497694] Testing event clock_disable: OK
[   14.514066] Testing event clock_enable: OK
[   14.530836] Testing event wakeup_source_deactivate: OK
[   14.544161] Testing event wakeup_source_activate: OK
[   14.557469] Testing event suspend_resume: OK
[   14.574202] Testing event device_pm_callback_end: OK
[   14.587500] Testing event device_pm_callback_start: OK
[   14.600793] Testing event cpu_frequency: OK
[   14.614302] Testing event pstate_sample: OK
[   14.627708] Testing event cpu_idle: OK
[   14.640864] Testing event benchmark_event: OK
[   14.744151] Testing event mm_filemap_add_to_page_cache: OK
[   14.757626] Testing event mm_filemap_delete_from_page_cache: OK
[   14.780813] Testing event oom_score_adj_update: OK
[   14.794241] Testing event mm_lru_activate: OK
[   14.807758] Testing event mm_lru_insertion: OK
[   14.821012] Testing event mm_vmscan_lru_shrink_inactive: OK
[   14.841168] Testing event mm_vmscan_writepage: OK
[   14.854438] Testing event mm_vmscan_memcg_isolate: OK
[   14.867466] Testing event mm_vmscan_lru_isolate: OK
[   14.880800] Testing event mm_shrink_slab_end: OK
[   14.894116] Testing event mm_shrink_slab_start: OK
[   14.910975] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   14.924224] Testing event mm_vmscan_memcg_reclaim_end: OK
[   14.937696] Testing event mm_vmscan_direct_reclaim_end: OK
[   14.951088] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   14.964010] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   14.980988] Testing event mm_vmscan_direct_reclaim_begin: OK
[   14.994094] Testing event mm_vmscan_wakeup_kswapd: OK
[   15.007425] Testing event mm_vmscan_kswapd_wake: OK
[   15.024118] Testing event mm_vmscan_kswapd_sleep: OK
[   15.037494] Testing event mm_page_alloc_extfrag: OK
[   15.050814] Testing event mm_page_pcpu_drain: OK
[   15.064317] Testing event mm_page_alloc_zone_locked: OK
[   15.080761] Testing event mm_page_alloc: OK
[   15.094334] Testing event mm_page_free_batched: OK
[   15.107615] Testing event mm_page_free: OK
[   15.120799] Testing event kmem_cache_free: OK
[   15.134135] Testing event kfree: OK
[   15.147543] Testing event kmem_cache_alloc_node: OK
[   15.160995] Testing event kmalloc_node: OK
[   15.174159] Testing event kmem_cache_alloc: OK
[   15.187398] Testing event kmalloc: OK
[   15.200774] Testing event writeback_single_inode: OK
[   15.214179] Testing event writeback_single_inode_start: OK
[   15.227672] Testing event writeback_wait_iff_congested: OK
[   15.241011] Testing event writeback_congestion_wait: OK
[   15.254153] Testing event writeback_sb_inodes_requeue: OK
[   15.267471] Testing event balance_dirty_pages: OK
[   15.287463] Testing event bdi_dirty_ratelimit: OK
[   15.300811] Testing event global_dirty_state: OK
[   15.314160] Testing event writeback_queue_io: OK
[   15.327690] Testing event wbc_writepage: OK
[   15.341093] Testing event writeback_bdi_unregister: OK
[   15.354106] Testing event writeback_bdi_register: OK
[   15.367386] Testing event writeback_wake_background: OK
[   15.384189] Testing event writeback_nowork: OK
[   15.397511] Testing event writeback_pages_written: OK
[   15.410750] Testing event writeback_wait: OK
[   15.424386] Testing event writeback_written: OK
[   15.437703] Testing event writeback_start: OK
[   15.450771] Testing event writeback_exec: OK
[   15.464083] Testing event writeback_queue: OK
[   15.500838] Testing event writeback_write_inode:=20
[   15.514221] test-events (552) used greatest stack depth: 6464 bytes left
[   15.517548] OK
[   15.517819] Testing event writeback_write_inode_start: OK
[   15.530781] Testing event writeback_dirty_inode: OK
[   15.544406] Testing event writeback_dirty_inode_start: OK
[   15.557706] Testing event writeback_dirty_page:=20
[   15.570547] test-events (556) used greatest stack depth: 6448 bytes left
[   15.571676] OK
[   15.571952] Testing event gpio_value: OK
[   15.584121] Testing event gpio_direction: OK
[   15.597448] Testing event regulator_set_voltage_complete: OK
[   15.611056] Testing event regulator_set_voltage: OK
[   15.624328] Testing event regulator_disable_complete: OK
[   15.637445] Testing event regulator_disable: OK
[   15.650808] Testing event regulator_enable_complete: OK
[   15.664069] Testing event regulator_enable_delay: OK
[   15.680885] Testing event regulator_enable: OK
[   15.697467] Testing event urandom_read: OK
[   15.710973] Testing event random_read: OK
[   15.724305] Testing event extract_entropy_user: OK
[   15.737415] Testing event extract_entropy: OK
[   15.750853] Testing event get_random_bytes_arch: OK
[   15.764144] Testing event get_random_bytes: OK
[   15.777645] Testing event xfer_secondary_pool: OK
[   15.790964] Testing event add_disk_randomness: OK
[   15.804109] Testing event add_input_randomness: OK
[   15.817498] Testing event debit_entropy: OK
[   15.830839] Testing event push_to_pool: OK
[   15.844327] Testing event credit_entropy_bits: OK
[   15.857641] Testing event mix_pool_bytes_nolock: OK
[   15.870746] Testing event mix_pool_bytes: OK
[   15.884147] Testing event add_device_randomness: OK
[   15.897500] Testing event drm_vblank_event_delivered: OK
[   15.910966] Testing event drm_vblank_event_queued: OK
[   15.924295] Testing event drm_vblank_event: OK
[   15.937452] Testing event regcache_drop_region: OK
[   15.950835] Testing event regmap_async_complete_done: OK
[   15.964166] Testing event regmap_async_complete_start: OK
[   15.977673] Testing event regmap_async_io_complete: OK
[   15.991001] Testing event regmap_async_write_start: OK
[   16.004088] Testing event regmap_cache_bypass: OK
[   16.017531] Testing event regmap_cache_only: OK
[   16.030857] Testing event regcache_sync: OK
[   16.044289] Testing event regmap_hw_write_done: OK
[   16.057621] Testing event regmap_hw_write_start: OK
[   16.070755] Testing event regmap_hw_read_done: OK
[   16.084152] Testing event regmap_hw_read_start: OK
[   16.097425] Testing event regmap_reg_read_cache: OK
[   16.114187] Testing event regmap_reg_read: OK
[   16.127519] Testing event regmap_reg_write: OK
[   16.141141] Testing event fence_wait_end: OK
[   16.157457] Testing event fence_wait_start: OK
[   16.170984] Testing event fence_signaled: OK
[   16.184389] Testing event fence_enable_signal: OK
[   16.197441] Testing event fence_destroy: OK
[   16.210783] Testing event fence_init: OK
[   16.224120] Testing event fence_emit: OK
[   16.237743] Testing event fence_annotate_wait_on: OK
[   16.254241] Testing event smbus_result: OK
[   16.267626] Testing event smbus_reply: OK
[   16.284183] Testing event smbus_read: OK
[   16.297774] Testing event smbus_write: OK
[   16.310690] Testing event i2c_result: OK
[   16.324121] Testing event i2c_reply: OK
[   16.337774] Testing event i2c_read: OK
[   16.350769] Testing event i2c_write: OK
[   16.364105] Testing event v4l2_qbuf: OK
[   16.377506] Testing event v4l2_dqbuf: OK
[   16.391224] Testing event thermal_zone_trip: OK
[   16.404351] Testing event cdev_update: OK
[   16.417888] Testing event thermal_temperature: OK
[   16.430805] Testing event udp_fail_queue_rcv_skb: OK
[   16.444168] Testing event sock_exceed_buf_limit: OK
[   16.457703] Testing event sock_rcvqueue_full: OK
[   16.471000] Testing event napi_poll: OK
[   16.484098] Testing event netif_rx_ni_entry: OK
[   16.497479] Testing event netif_rx_entry: OK
[   16.510808] Testing event netif_receive_skb_entry: OK
[   16.524367] Testing event napi_gro_receive_entry: OK
[   16.540913] Testing event napi_gro_frags_entry: OK
[   16.554368] Testing event netif_rx: OK
[   16.570839] Testing event netif_receive_skb: OK
[   16.584347] Testing event net_dev_queue: OK
[   16.597638] Testing event net_dev_xmit: OK
[   16.610816] Testing event net_dev_start_xmit: OK
[   16.624098] Testing event skb_copy_datagram_iovec: OK
[   16.637578] Testing event consume_skb: OK
[   16.650800] Testing event kfree_skb: OK
[   16.664160] Running tests on trace event systems:
[   16.664897] Testing event system skb: OK
[   16.677839] Testing event system net: OK
[   16.691160] Testing event system napi: OK
[   16.704396] Testing event system sock: OK
[   16.717553] Testing event system udp: OK
[   16.734370] Testing event system thermal: OK
[   16.751292] Testing event system v4l2: OK
[   16.764228] Testing event system i2c: OK
[   16.777646] Testing event system fence: OK
[   16.791240] Testing event system regmap: OK
[   16.804588] Testing event system drm: OK
[   16.817957] Testing event system random: OK
[   16.831013] Testing event system regulator: OK
[   16.851196] Testing event system gpio: OK
[   16.864462] Testing event system writeback: OK
[   16.881688] Testing event system kmem: OK
[   16.947078] Testing event system vmscan: OK
[   16.961114] Testing event system pagemap: OK
[   16.974382] Testing event system oom: OK
[   16.994283] Testing event system filemap: OK
[   17.007686] Testing event system benchmark: OK
[   17.114295] Testing event system power: OK
[   17.128183] Testing event system test: OK
[   17.141041] Testing event system module: OK
[   17.154164] Testing event system timer: OK
[   17.170982] Testing event system rcu: OK
[   17.184398] Testing event system printk: OK
[   17.197695] Testing event system lock: OK
[   17.211750] Testing event system sched: OK
[   17.227904] Testing event system workqueue: OK
[   17.241324] Testing event system signal: OK
[   17.254461] Testing event system irq: OK
[   17.267626] Testing event system task: OK
[   17.281027] Testing event system exceptions: OK
[   17.294391] Testing event system tlb: OK
[   17.307856] Testing event system raw_syscalls: OK
[   17.321277] Testing event system nmi: OK
[   17.334369] Testing event system irq_vectors: OK
[   17.351772] Running tests on all trace events:
[   17.352627] Testing all events: OK
[   17.627764] Testing ftrace filter: OK
[   17.687075] Freeing unused kernel memory: 1716K (c190d000 - c1aba000)
[   17.808897] random: init urandom read with 5 bits of entropy available
[   17.828360] ------------[ cut here ]------------
[   17.828989] WARNING: CPU: 1 PID: 681 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   17.830086] Modules linked in:
[   17.830549] CPU: 1 PID: 681 Comm: init Not tainted 3.19.0-rc5-gf7a7b53 #=
19
[   17.831339]  00000001 00000000 00000001 d388bd4c c14341a1 00000000 00000=
001 c16ebf08
[   17.832421]  d388bd68 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d388bd78
[   17.833488]  c1056a11 00000009 00000000 d388bdd0 c1150db8 d3858380 fffff=
fff ffffffff
[   17.841323] Call Trace:
[   17.844215]  [<c14341a1>] dump_stack+0x78/0xa8
[   17.844700]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   17.847797]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   17.850955]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   17.854131]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   17.854629]  [<c10537ff>] mmput+0x52/0xef
[   17.857584]  [<c1175602>] flush_old_exec+0x923/0x99d
[   17.860806]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   17.861378]  [<c108559f>] ? local_clock+0x2f/0x39
[   17.865327]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   17.866002]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   17.866588]  [<c11ac7e5>] load_script+0x339/0x355
[   17.874149]  [<c108550c>] ? sched_clock_cpu+0x188/0x1a3
[   17.874718]  [<c108559f>] ? local_clock+0x2f/0x39
[   17.878580]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   17.879355]  [<c109c1bf>] ? do_raw_read_unlock+0x28/0x53
[   17.879997]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   17.887644]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   17.890904]  [<c11762eb>] do_execve+0x19/0x1b
[   17.891389]  [<c1176586>] SyS_execve+0x21/0x25
[   17.895168]  [<c143be92>] syscall_call+0x7/0x7
[   17.895653] ---[ end trace 6a7094e9a1d04ce0 ]---
[   17.909585] ------------[ cut here ]------------
[   17.910276] WARNING: CPU: 1 PID: 682 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   17.915843] Modules linked in:
[   17.916219] CPU: 1 PID: 682 Comm: init Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   17.923893]  00000001 00000000 00000002 d388de08 c14341a1 00000000 00000=
001 c16ebf08
[   17.925945]  d388de24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d388de34
[   17.933819]  c1056a11
[   17.934189] ------------[ cut here ]------------
[   17.934195] WARNING: CPU: 0 PID: 683 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   17.934197] Modules linked in:

[   17.944606]  00000009 00000000 d388de8c c1150db8 d3857380 ffffffff fffff=
fff
[   17.949281] Call Trace:
[   17.949716]  [<c14341a1>] dump_stack+0x78/0xa8
[   17.957194]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   17.958694]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   17.959208]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   17.959758]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   17.960273]  [<c10537ff>] mmput+0x52/0xef
[   17.968448]  [<c1175602>] flush_old_exec+0x923/0x99d
[   17.968998]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   17.969553]  [<c108559f>] ? local_clock+0x2f/0x39
[   17.970088]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   17.978544]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   17.979212]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   17.979876]  [<c11762eb>] do_execve+0x19/0x1b
[   17.987165]  [<c1176586>] SyS_execve+0x21/0x25
[   17.988877]  [<c143be92>] syscall_call+0x7/0x7
[   17.989642] ---[ end trace 6a7094e9a1d04ce1 ]---
[   17.989645] CPU: 0 PID: 683 Comm: rc.local Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   17.989654]  00000001 00000000 00000003 d3899e08 c14341a1 00000000 00000=
000 c16ebf08
[   17.989661]  d3899e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3899e34
[   17.989668]  c1056a11 00000009 00000000 d3899e8c c1150db8 d3895900 fffff=
fff ffffffff
[   17.989669] Call Trace:
[   17.989674]  [<c14341a1>] dump_stack+0x78/0xa8
[   17.989679]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   17.989683]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   17.989686]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   17.989690]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   17.989694]  [<c10537ff>] mmput+0x52/0xef
[   17.989698]  [<c1175602>] flush_old_exec+0x923/0x99d
[   17.989703]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   17.989707]  [<c108559f>] ? local_clock+0x2f/0x39
[   17.989711]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   17.989716]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   17.989720]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   17.989724]  [<c11762eb>] do_execve+0x19/0x1b
[   17.989727]  [<c1176586>] SyS_execve+0x21/0x25
[   17.989731]  [<c143be92>] syscall_call+0x7/0x7
[   17.989734] ---[ end trace 6a7094e9a1d04ce2 ]---
[   18.041103] ------------[ cut here ]------------
[   18.041111] WARNING: CPU: 0 PID: 683 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.041113] Modules linked in:
[   18.041117] CPU: 0 PID: 683 Comm: mount Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   18.041124]  00000001 00000000 00000004 d3899ea8 c14341a1 00000000 00000=
000 c16ebf08
[   18.041130]  d3899ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3899ed4
[   18.041137]  c1056a11 00000009 00000000 d3899f2c c1150db8 d3895d00 fffff=
fff ffffffff
[   18.041138] Call Trace:
[   18.041145]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.041149]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.041153]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.041156]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.041159]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.041163]  [<c10537ff>] mmput+0x52/0xef
[   18.041167]  [<c105955b>] do_exit+0x5bc/0xee9
[   18.041172]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   18.041176]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   18.041179]  [<c143becb>] ? restore_all+0xf/0xf
[   18.041183]  [<c1059fe4>] do_group_exit+0x113/0x113
[   18.041186]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   18.041189]  [<c143be92>] syscall_call+0x7/0x7
[   18.041192] ---[ end trace 6a7094e9a1d04ce3 ]---
[   18.044698] ------------[ cut here ]------------
[   18.044703] WARNING: CPU: 0 PID: 686 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.044705] Modules linked in:
[   18.044708] CPU: 0 PID: 686 Comm: rc.local Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   18.044715]  00000001 00000000 00000005 d38bde08 c14341a1 00000000 00000=
000 c16ebf08
[   18.044721]  d38bde24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38bde34
[   18.044727]  c1056a11 00000009 00000000 d38bde8c c1150db8 d38a7380 fffff=
fff ffffffff
[   18.044728] Call Trace:
[   18.044732]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.044736]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.044739]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.044742]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.044745]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.044749]  [<c10537ff>] mmput+0x52/0xef
[   18.044753]  [<c1175602>] flush_old_exec+0x923/0x99d
[   18.044757]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   18.044762]  [<c108559f>] ? local_clock+0x2f/0x39
[   18.044766]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   18.044770]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   18.044774]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   18.044777]  [<c11762eb>] do_execve+0x19/0x1b
[   18.044780]  [<c1176586>] SyS_execve+0x21/0x25
[   18.044783]  [<c143be92>] syscall_call+0x7/0x7
[   18.044786] ---[ end trace 6a7094e9a1d04ce4 ]---
[   18.048720] ------------[ cut here ]------------
[   18.048728] WARNING: CPU: 0 PID: 687 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.048730] Modules linked in:
[   18.048734] CPU: 0 PID: 687 Comm: run-parts Tainted: G        W      3.1=
9.0-rc5-gf7a7b53 #19
[   18.048743]  00000001 00000000 00000006 d38bfd4c c14341a1 00000000 00000=
000 c16ebf08
[   18.048751]  d38bfd68 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38bfd78
[   18.048758]  c1056a11 00000009 00000000 d38bfdd0 c1150db8 d38b2380 fffff=
fff ffffffff
[   18.048759] Call Trace:
[   18.048765]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.048770]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.048778]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.048782]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.048786]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.048791]  [<c10537ff>] mmput+0x52/0xef
[   18.048795]  [<c1175602>] flush_old_exec+0x923/0x99d
[   18.048800]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   18.048804]  [<c108559f>] ? local_clock+0x2f/0x39
[   18.048809]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   18.048814]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   18.048818]  [<c11ac7e5>] load_script+0x339/0x355
[   18.048822]  [<c108550c>] ? sched_clock_cpu+0x188/0x1a3
[   18.048827]  [<c108559f>] ? local_clock+0x2f/0x39
[   18.048831]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   18.048836]  [<c109c1bf>] ? do_raw_read_unlock+0x28/0x53
[   18.048840]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   18.048844]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   18.048848]  [<c11762eb>] do_execve+0x19/0x1b
[   18.048852]  [<c1176586>] SyS_execve+0x21/0x25
[   18.048856]  [<c143be92>] syscall_call+0x7/0x7
[   18.048860] ---[ end trace 6a7094e9a1d04ce5 ]---
[   18.101807] ------------[ cut here ]------------
[   18.101816] WARNING: CPU: 0 PID: 688 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.101818] Modules linked in:
[   18.101822] CPU: 0 PID: 688 Comm: 99-trinity Tainted: G        W      3.=
19.0-rc5-gf7a7b53 #19
[   18.101829]  00000001 00000000 00000007 d38d1e08 c14341a1 00000000 00000=
000 c16ebf08
[   18.101835]  d38d1e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d1e34
[   18.101841]  c1056a11 00000009 00000000 d38d1e8c c1150db8 d389d380 fffff=
fff ffffffff
[   18.101842] Call Trace:
[   18.101849]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.101854]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.101860]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.101863]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.101866]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.101870]  [<c10537ff>] mmput+0x52/0xef
[   18.101875]  [<c1175602>] flush_old_exec+0x923/0x99d
[   18.101879]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   18.101884]  [<c108559f>] ? local_clock+0x2f/0x39
[   18.101889]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   18.101893]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   18.101896]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   18.101900]  [<c11762eb>] do_execve+0x19/0x1b
[   18.101903]  [<c1176586>] SyS_execve+0x21/0x25
[   18.101906]  [<c143be92>] syscall_call+0x7/0x7
[   18.101909] ---[ end trace 6a7094e9a1d04ce6 ]---
[   18.117239] ------------[ cut here ]------------
[   18.117247] WARNING: CPU: 0 PID: 688 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.117249] Modules linked in:
[   18.117253] CPU: 0 PID: 688 Comm: grep Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   18.117260]  00000001 00000000 00000008 d38d1ea8 c14341a1 00000000 00000=
000 c16ebf08
[   18.117267]  d38d1ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d1ed4
[   18.117273]  c1056a11 00000009 00000000 d38d1f2c c1150db8 d389d780 fffff=
fff ffffffff
[   18.117274] Call Trace:
[   18.117280]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.117284]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.117288]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.117291]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.117295]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.117299]  [<c10537ff>] mmput+0x52/0xef
[   18.117302]  [<c105955b>] do_exit+0x5bc/0xee9
[   18.117307]  [<c143becb>] ? restore_all+0xf/0xf
[   18.117311]  [<c1059fe4>] do_group_exit+0x113/0x113
[   18.117314]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   18.117318]  [<c143be92>] syscall_call+0x7/0x7
[   18.117320] ---[ end trace 6a7094e9a1d04ce7 ]---
[   18.156306] ------------[ cut here ]------------
[   18.156315] WARNING: CPU: 0 PID: 690 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.156318] Modules linked in:
[   18.156322] CPU: 0 PID: 690 Comm: 99-trinity Tainted: G        W      3.=
19.0-rc5-gf7a7b53 #19
[   18.156334]  00000001 00000000 00000009 d38e3e08 c14341a1 00000000 00000=
000 c16ebf08
[   18.156343]  d38e3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38e3e34
[   18.156351]  c1056a11 00000009 00000000 d38e3e8c c1150db8 d38d6380 fffff=
fff ffffffff
[   18.156353] Call Trace:
[   18.156360]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.156366]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.156370]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.156374]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.156378]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.156383]  [<c10537ff>] mmput+0x52/0xef
[   18.156388]  [<c1175602>] flush_old_exec+0x923/0x99d
[   18.156395]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   18.156400]  [<c108559f>] ? local_clock+0x2f/0x39
[   18.156405]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   18.156410]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   18.156414]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   18.156419]  [<c11762eb>] do_execve+0x19/0x1b
[   18.156423]  [<c1176586>] SyS_execve+0x21/0x25
[   18.156427]  [<c143be92>] syscall_call+0x7/0x7
[   18.156431] ---[ end trace 6a7094e9a1d04ce8 ]---
[   18.172569] ------------[ cut here ]------------
[   18.172577] WARNING: CPU: 0 PID: 690 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.172579] Modules linked in:
[   18.172583] CPU: 0 PID: 690 Comm: grep Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   18.172590]  00000001 00000000 0000000a d38e3ea8 c14341a1 00000000 00000=
000 c16ebf08
[   18.172597]  d38e3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38e3ed4
[   18.172603]  c1056a11 00000009 00000000 d38e3f2c c1150db8 c001f000 fffff=
fff ffffffff
[   18.172604] Call Trace:
[   18.172611]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.172615]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.172618]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.172622]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.172625]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.172629]  [<c10537ff>] mmput+0x52/0xef
[   18.172633]  [<c105955b>] do_exit+0x5bc/0xee9
[   18.172637]  [<c143becb>] ? restore_all+0xf/0xf
[   18.172641]  [<c1059fe4>] do_group_exit+0x113/0x113
[   18.172644]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   18.172647]  [<c143be92>] syscall_call+0x7/0x7
[   18.172649] ---[ end trace 6a7094e9a1d04ce9 ]---
[   18.191226] ------------[ cut here ]------------
[   18.191233] WARNING: CPU: 0 PID: 691 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.191235] Modules linked in:
[   18.191239] CPU: 0 PID: 691 Comm: 99-trinity Tainted: G        W      3.=
19.0-rc5-gf7a7b53 #19
[   18.191246]  00000001 00000000 0000000b d38f5e08 c14341a1 00000000 00000=
000 c16ebf08
[   18.191253]  d38f5e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38f5e34
[   18.191259]  c1056a11 00000009 00000000 d38f5e8c c1150db8 d38d6c80 fffff=
fff ffffffff
[   18.191260] Call Trace:
[   18.191267]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.191271]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.191274]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.191277]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.191281]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.191285]  [<c10537ff>] mmput+0x52/0xef
[   18.191289]  [<c1175602>] flush_old_exec+0x923/0x99d
[   18.191294]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   18.191298]  [<c108559f>] ? local_clock+0x2f/0x39
[   18.191303]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   18.191307]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   18.191311]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   18.191314]  [<c11762eb>] do_execve+0x19/0x1b
[   18.191317]  [<c1176586>] SyS_execve+0x21/0x25
[   18.191321]  [<c143be92>] syscall_call+0x7/0x7
[   18.191324] ---[ end trace 6a7094e9a1d04cea ]---
[   18.196403] ------------[ cut here ]------------
[   18.196409] WARNING: CPU: 0 PID: 691 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.196411] Modules linked in:
[   18.196414] CPU: 0 PID: 691 Comm: cut Tainted: G        W      3.19.0-rc=
5-gf7a7b53 #19
[   18.196422]  00000001 00000000 0000000c d38f5ea8 c14341a1 00000000 00000=
000 c16ebf08
[   18.196430]  d38f5ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38f5ed4
[   18.196438]  c1056a11 00000009 00000000 d38f5f2c c1150db8 c001fd00 fffff=
fff ffffffff
[   18.196439] Call Trace:
[   18.196444]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.196448]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.196452]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.196455]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.196459]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.196464]  [<c10537ff>] mmput+0x52/0xef
[   18.196467]  [<c105955b>] do_exit+0x5bc/0xee9
[   18.196472]  [<c143becb>] ? restore_all+0xf/0xf
[   18.196476]  [<c1059fe4>] do_group_exit+0x113/0x113
[   18.196479]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   18.196483]  [<c143be92>] syscall_call+0x7/0x7
[   18.196486] ---[ end trace 6a7094e9a1d04ceb ]---
[   18.207829] ------------[ cut here ]------------
[   18.207835] WARNING: CPU: 0 PID: 689 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.207837] Modules linked in:
[   18.207841] CPU: 0 PID: 689 Comm: 99-trinity Tainted: G        W      3.=
19.0-rc5-gf7a7b53 #19
[   18.207848]  00000001 00000000 0000000d d38e1ea8 c14341a1 00000000 00000=
000 c16ebf08
[   18.207854]  d38e1ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38e1ed4
[   18.207860]  c1056a11 00000009 00000000 d38e1f2c c1150db8 d38cf380 fffff=
fff ffffffff
[   18.207861] Call Trace:
[   18.207868]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.207872]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.207875]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.207878]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.207881]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.207886]  [<c10537ff>] mmput+0x52/0xef
[   18.207889]  [<c105955b>] do_exit+0x5bc/0xee9
[   18.207894]  [<c10034fa>] ? do_device_not_available+0xa6/0xac
[   18.207897]  [<c143becb>] ? restore_all+0xf/0xf
[   18.207901]  [<c1059fe4>] do_group_exit+0x113/0x113
[   18.207904]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   18.207907]  [<c143be92>] syscall_call+0x7/0x7
[   18.207910] ---[ end trace 6a7094e9a1d04cec ]---
[   18.224763] ------------[ cut here ]------------
[   18.224771] WARNING: CPU: 0 PID: 692 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.224774] Modules linked in:
[   18.224778] CPU: 0 PID: 692 Comm: 99-trinity Tainted: G        W      3.=
19.0-rc5-gf7a7b53 #19
[   18.224786]  00000001 00000000 0000000e d38f7e08 c14341a1 00000000 00000=
000 c16ebf08
[   18.224793]  d38f7e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38f7e34
[   18.224801]  c1056a11 00000009 00000000 d38f7e8c c1150db8 d38d6380 fffff=
fff ffffffff
[   18.224803] Call Trace:
[   18.224809]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.224814]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.224817]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.224821]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.224825]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.224830]  [<c10537ff>] mmput+0x52/0xef
[   18.224834]  [<c1175602>] flush_old_exec+0x923/0x99d
[   18.224840]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   18.224845]  [<c108559f>] ? local_clock+0x2f/0x39
[   18.224851]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   18.224855]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   18.224859]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   18.224863]  [<c11762eb>] do_execve+0x19/0x1b
[   18.224867]  [<c1176586>] SyS_execve+0x21/0x25
[   18.224872]  [<c143be92>] syscall_call+0x7/0x7
[   18.224875] ---[ end trace 6a7094e9a1d04ced ]---
[   18.242976] ------------[ cut here ]------------
[   18.242985] WARNING: CPU: 0 PID: 692 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.242988] Modules linked in:
[   18.242992] CPU: 0 PID: 692 Comm: umount Tainted: G        W      3.19.0=
-rc5-gf7a7b53 #19
[   18.243000]  00000001 00000000 0000000f d38f7ea8 c14341a1 00000000 00000=
000 c16ebf08
[   18.243008]  d38f7ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38f7ed4
[   18.243015]  c1056a11 00000009 00000000 d38f7f2c c1150db8 d38d6c80 fffff=
fff ffffffff
[   18.243016] Call Trace:
[   18.243023]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.243028]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.243031]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.243035]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.243039]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.243043]  [<c10537ff>] mmput+0x52/0xef
[   18.243047]  [<c105955b>] do_exit+0x5bc/0xee9
[   18.243053]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   18.243057]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   18.243061]  [<c143becb>] ? restore_all+0xf/0xf
[   18.243065]  [<c1059fe4>] do_group_exit+0x113/0x113
[   18.243068]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   18.243071]  [<c143be92>] syscall_call+0x7/0x7
[   18.243074] ---[ end trace 6a7094e9a1d04cee ]---
[   18.275843] ------------[ cut here ]------------
[   18.275852] WARNING: CPU: 0 PID: 693 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.275855] Modules linked in:
[   18.275859] CPU: 0 PID: 693 Comm: 99-trinity Tainted: G        W      3.=
19.0-rc5-gf7a7b53 #19
[   18.275870]  00000001 00000000 00000010 d38f9e08 c14341a1 00000000 00000=
000 c16ebf08
[   18.275877]  d38f9e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38f9e34
[   18.275884]  c1056a11 00000009 00000000 d38f9e8c c1150db8 d38d3000 fffff=
fff ffffffff
[   18.275886] Call Trace:
[   18.275893]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.275899]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.275902]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.275907]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.275910]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.275915]  [<c10537ff>] mmput+0x52/0xef
[   18.275920]  [<c1175602>] flush_old_exec+0x923/0x99d
[   18.275932]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   18.275937]  [<c108559f>] ? local_clock+0x2f/0x39
[   18.275942]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   18.275948]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   18.275951]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   18.275956]  [<c11762eb>] do_execve+0x19/0x1b
[   18.275960]  [<c1176586>] SyS_execve+0x21/0x25
[   18.275964]  [<c143be92>] syscall_call+0x7/0x7
[   18.275967] ---[ end trace 6a7094e9a1d04cef ]---
[   18.292199] ------------[ cut here ]------------
[   18.292206] WARNING: CPU: 0 PID: 694 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   18.292209] Modules linked in:
[   18.292213] CPU: 0 PID: 694 Comm: 99-trinity Tainted: G        W      3.=
19.0-rc5-gf7a7b53 #19
[   18.292221]  00000001 00000000 00000011 c0025e08 c14341a1 00000000 00000=
000 c16ebf08
[   18.292228]  c0025e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0025e34
[   18.292235]  c1056a11 00000009 00000000 c0025e8c c1150db8 d38d3900 fffff=
fff ffffffff
[   18.292236] Call Trace:
[   18.292242]  [<c14341a1>] dump_stack+0x78/0xa8
[   18.292246]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   18.292250]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   18.292254]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   18.292257]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   18.292262]  [<c10537ff>] mmput+0x52/0xef
[   18.292266]  [<c1175602>] flush_old_exec+0x923/0x99d
[   18.292271]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   18.292275]  [<c108559f>] ? local_clock+0x2f/0x39
[   18.292280]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   18.292285]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   18.292288]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   18.292292]  [<c11762eb>] do_execve+0x19/0x1b
[   18.292296]  [<c1176586>] SyS_execve+0x21/0x25
[   18.292300]  [<c143be92>] syscall_call+0x7/0x7
[   18.292303] ---[ end trace 6a7094e9a1d04cf0 ]---
[   19.039645] ------------[ cut here ]------------
[   19.040237] WARNING: CPU: 0 PID: 682 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.041513] Modules linked in:
[   19.041902] CPU: 0 PID: 682 Comm: hostname Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   19.042798]  00000001 00000000 00000012 d388dea8 c14341a1 00000000 00000=
000 c16ebf08
[   19.043919]  d388dec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d388ded4
[   19.045055]  c1056a11 00000009 00000000 d388df2c c1150db8 d3858380 fffff=
fff ffffffff
[   19.046128] Call Trace:
[   19.046480]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.055491] ------------[ cut here ]------------
[   19.055498] WARNING: CPU: 1 PID: 695 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.055500] Modules linked in:
[   19.059165]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.059798]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.070513]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.071158]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.071738]  [<c10537ff>] mmput+0x52/0xef
[   19.072205]  [<c105955b>] do_exit+0x5bc/0xee9
[   19.072681]  [<c1096c79>] ? up_write+0x1b/0x37
[   19.073169]  [<c143becb>] ? restore_all+0xf/0xf
[   19.073691]  [<c1059fe4>] do_group_exit+0x113/0x113
[   19.087966]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   19.088552]  [<c143be92>] syscall_call+0x7/0x7
[   19.089038] ---[ end trace 6a7094e9a1d04cf1 ]---
[   19.090690] CPU: 1 PID: 695 Comm: init Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   19.094200]  00000001 00000000 00000013 d3909e08 c14341a1 00000000 00000=
001 c16ebf08
[   19.098490]  d3909e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3909e34
[   19.099462]  c1056a11 00000009 00000000 d3909e8c c1150db8 d384b380 fffff=
fff ffffffff
[   19.107469] Call Trace:
[   19.107759]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.111600]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.112257]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.112852]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.113540]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.121104]  [<c10537ff>] mmput+0x52/0xef
[   19.124212]  [<c1175602>] flush_old_exec+0x923/0x99d
[   19.127345]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   19.127903]  [<c108559f>] ? local_clock+0x2f/0x39
[   19.131766]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   19.132535]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   19.133207]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   19.140821]  [<c11762eb>] do_execve+0x19/0x1b
[   19.141366]  [<c1176586>] SyS_execve+0x21/0x25
[   19.145185]  [<c143be92>] syscall_call+0x7/0x7
[   19.145670] ---[ end trace 6a7094e9a1d04cf2 ]---
[   19.157383] ------------[ cut here ]------------
[   19.157913] WARNING: CPU: 1 PID: 696 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.158988] Modules linked in:
[   19.159348] CPU: 1 PID: 696 Comm: init Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   19.160278]  00000001 00000000 00000014 d390be08 c14341a1 00000000 00000=
001 c16ebf08
[   19.171777]  d390be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d390be34
[   19.172911]  c1056a11 00000009 00000000 d390be8c c1150db8 d3857680 fffff=
fff ffffffff
[   19.181815] Call Trace:
[   19.182134]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.182674]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.183316]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.191567]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.192200]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.192756]  [<c10537ff>] mmput+0x52/0xef
[   19.193269]  [<c1175602>] flush_old_exec+0x923/0x99d
[   19.201528]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   19.202182]  [<c108559f>] ? local_clock+0x2f/0x39
[   19.202776]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   19.203610]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   19.211987]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   19.212680]  [<c11762eb>] do_execve+0x19/0x1b
[   19.213246]  [<c1176586>] SyS_execve+0x21/0x25
[   19.220532]  [<c143be92>] syscall_call+0x7/0x7
[   19.221981] ---[ end trace 6a7094e9a1d04cf3 ]---
[   19.227518] ------------[ cut here ]------------
[   19.228052] WARNING: CPU: 0 PID: 696 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.229030] Modules linked in:
[   19.229389] CPU: 0 PID: 696 Comm: sh Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   19.230277]  00000001 00000000 00000015 d390bea8 c14341a1 00000000 00000=
000 c16ebf08
[   19.231362]  d390bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d390bed4
[   19.232365]  c1056a11 00000009 00000000 d390bf2c c1150db8 d389e580 fffff=
fff ffffffff
[   19.233370] Call Trace:
[   19.233648]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.234376]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.235061]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.235570]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.236142]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.236653]  [<c10537ff>] mmput+0x52/0xef
[   19.244431] ------------[ cut here ]------------
[   19.244437] WARNING: CPU: 1 PID: 695 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.244439] Modules linked in:
[   19.249127]  [<c105955b>] do_exit+0x5bc/0xee9
[   19.249644]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   19.250263]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   19.261005]  [<c143becb>] ? restore_all+0xf/0xf
[   19.261592]  [<c1059fe4>] do_group_exit+0x113/0x113
[   19.262153]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   19.262670]  [<c143be92>] syscall_call+0x7/0x7
[   19.263155] ---[ end trace 6a7094e9a1d04cf4 ]---
[   19.268256] CPU: 1 PID: 695 Comm: sh Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   19.269211]  00000001 00000000 00000016 d3909ea8 c14341a1 00000000 00000=
001 c16ebf08
[   19.270338]  d3909ec4
[   19.273944] sh (696) used greatest stack depth: 6432 bytes left

[   19.280991]  c1056987 00000b2a c1150db8 00000001 00000001 00000000 d3909=
ed4
[   19.284583]  c1056a11 00000009 00000000 d3909f2c c1150db8 d384bb00 fffff=
fff ffffffff
[   19.289064] Call Trace:
[   19.289354]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.289834]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.297240]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.297799]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.301022]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.304208]  [<c10537ff>] mmput+0x52/0xef
[   19.304676]  [<c105955b>] do_exit+0x5bc/0xee9
[   19.307761]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   19.310947]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   19.314895]  [<c143becb>] ? restore_all+0xf/0xf
[   19.315431]  [<c1059fe4>] do_group_exit+0x113/0x113
[   19.315968]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   19.316488]  [<c143be92>] syscall_call+0x7/0x7
[   19.317012] ---[ end trace 6a7094e9a1d04cf5 ]---
[   19.332268] ------------[ cut here ]------------
[   19.332858] WARNING: CPU: 1 PID: 697 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.341560] Modules linked in:
[   19.341931] CPU: 1 PID: 697 Comm: init Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   19.342787]  00000001 00000000 00000017 d384fe08 c14341a1 00000000 00000=
001 c16ebf08
[   19.350772]  d384fe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d384fe34
[   19.355226]  c1056a11 00000009 00000000 d384fe8c c1150db8 d38ecd80 fffff=
fff ffffffff
[   19.356199] Call Trace:
[   19.356480]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.364020]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.367136]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.368591]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.369165]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.369663]  [<c10537ff>] mmput+0x52/0xef
[   19.370143]  [<c1175602>] flush_old_exec+0x923/0x99d
[   19.377656]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   19.381536]  [<c108559f>] ? local_clock+0x2f/0x39
[   19.382063]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   19.382745]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   19.383371]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   19.391025]  [<c11762eb>] do_execve+0x19/0x1b
[   19.394171]  [<c1176586>] SyS_execve+0x21/0x25
[   19.394685]  [<c143be92>] syscall_call+0x7/0x7
[   19.397763] ---[ end trace 6a7094e9a1d04cf6 ]---
/bin/sh: /proc/self/fd/9: No such file or directory
[   19.407410] ------------[ cut here ]------------
[   19.408000] WARNING: CPU: 0 PID: 697 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.409115] Modules linked in:
[   19.409509] CPU: 0 PID: 697 Comm: sh Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   19.410600]  00000001 00000000 00000018 d384fea8 c14341a1 00000000 00000=
000 c16ebf08
[   19.411641]  d384fec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d384fed4
[   19.412615]  c1056a11 00000009 00000000 d384ff2c c1150db8 d384c980 fffff=
fff ffffffff
[   19.413657] Call Trace:
[   19.414087]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.414576]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.415227]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.415801]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.416458]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.417071]  [<c10537ff>] mmput+0x52/0xef
[   19.431831]  [<c105955b>] do_exit+0x5bc/0xee9
[   19.432369]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   19.432936]  [<c143becb>] ? restore_all+0xf/0xf
[   19.440210]  [<c1059fe4>] do_group_exit+0x113/0x113
[   19.441059]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   19.445136]  [<c143be92>] syscall_call+0x7/0x7
[   19.445630] ---[ end trace 6a7094e9a1d04cf7 ]---
[   19.472501] ------------[ cut here ]------------
[   19.473049] WARNING: CPU: 1 PID: 698 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.481746] Modules linked in:
[   19.482149] CPU: 1 PID: 698 Comm: init Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   19.483060]  00000001 00000000 00000019 d388de08 c14341a1 00000000 00000=
001 c16ebf08
[   19.493568]  d388de24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d388de34
[   19.494722]  c1056a11 00000009 00000000 d388de8c c1150db8 d38d6380 fffff=
fff ffffffff
[   19.501689] Call Trace:
[   19.501981]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.502472]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.503060]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.510462]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.512049]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.512582]  [<c10537ff>] mmput+0x52/0xef
[   19.513072]  [<c1175602>] flush_old_exec+0x923/0x99d
[   19.520538]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   19.522219]  [<c108559f>] ? local_clock+0x2f/0x39
[   19.522814]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   19.530318]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   19.531985]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   19.532572]  [<c11762eb>] do_execve+0x19/0x1b
[   19.533061]  [<c1176586>] SyS_execve+0x21/0x25
[   19.540311]  [<c143be92>] syscall_call+0x7/0x7
[   19.541782] ---[ end trace 6a7094e9a1d04cf8 ]---
[   19.611991] ------------[ cut here ]------------
[   19.612635] WARNING: CPU: 0 PID: 699 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.613878] Modules linked in:
[   19.614322] CPU: 0 PID: 699 Comm: sh Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   19.615168]  00000001 00000000 0000001a d384fe08 c14341a1 00000000 00000=
000 c16ebf08
[   19.616134]  d384fe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d384fe34
[   19.640246]  c1056a11 00000009 00000000 d384fe8c c1150db8 d3857380 fffff=
fff ffffffff
[   19.641377] Call Trace:
[   19.641676]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.642195]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.642771]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.643320]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.655534]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.656124]  [<c10537ff>] mmput+0x52/0xef
[   19.656662]  [<c1175602>] flush_old_exec+0x923/0x99d
[   19.665301]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   19.665938]  [<c108559f>] ? local_clock+0x2f/0x39
[   19.666532]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   19.674588]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   19.678616]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   19.679230]  [<c11762eb>] do_execve+0x19/0x1b
[   19.679754]  [<c1176586>] SyS_execve+0x21/0x25
[   19.687117]  [<c143be92>] syscall_call+0x7/0x7
[   19.688520] ---[ end trace 6a7094e9a1d04cf9 ]---
[   19.697684] ------------[ cut here ]------------
[   19.700847] WARNING: CPU: 0 PID: 699 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.720576] Modules linked in:
[   19.724254] CPU: 0 PID: 699 Comm: rm Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   19.725127]  00000001 00000000 0000001b d384fea8 c14341a1 00000000 00000=
000 c16ebf08
[   19.726114]  d384fec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d384fed4
[   19.740214]  c1056a11 00000009 00000000 d384ff2c c1150db8 d3857a80 fffff=
fff ffffffff
[   19.741563] Call Trace:
[   19.741853]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.742354]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.742941]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.753418]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.754354]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.754947]  [<c10537ff>] mmput+0x52/0xef
[   19.755522]  [<c105955b>] do_exit+0x5bc/0xee9
[   19.756128]  [<c143becb>] ? restore_all+0xf/0xf
[   19.764095]  [<c1059fe4>] do_group_exit+0x113/0x113
[   19.764656]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   19.765307]  [<c143be92>] syscall_call+0x7/0x7
[   19.765902] ---[ end trace 6a7094e9a1d04cfa ]---
[   19.804438] ------------[ cut here ]------------
[   19.805044] WARNING: CPU: 1 PID: 698 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.805996] Modules linked in:
[   19.806353] CPU: 1 PID: 698 Comm: sh Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   19.814679]  00000001 00000000 0000001c d388dea8 c14341a1 00000000 00000=
001 c16ebf08
[   19.815824]  d388dec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d388ded4
[   19.827107]  c1056a11 00000009 00000000 d388df2c c1150db8 d38ffa00 fffff=
fff ffffffff
[   19.828202] Call Trace:
[   19.828511]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.829055]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.829662]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.840302]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.841073]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.841661]  [<c10537ff>] mmput+0x52/0xef
[   19.842194]  [<c105955b>] do_exit+0x5bc/0xee9
[   19.842777]  [<c10034fa>] ? do_device_not_available+0xa6/0xac
[   19.853673]  [<c143becb>] ? restore_all+0xf/0xf
[   19.854505]  [<c1059fe4>] do_group_exit+0x113/0x113
[   19.855123]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   19.855702]  [<c143be92>] syscall_call+0x7/0x7
[   19.856243] ---[ end trace 6a7094e9a1d04cfb ]---
[   19.887704] ------------[ cut here ]------------
[   19.888335] WARNING: CPU: 1 PID: 700 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   19.889431] Modules linked in:
[   19.889856] CPU: 1 PID: 700 Comm: init Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   19.901069]  00000001 00000000 0000001d d384fe08 c14341a1 00000000 00000=
001 c16ebf08
[   19.902277]  d384fe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d384fe34
[   19.903498]  c1056a11 00000009 00000000 d384fe8c c1150db8 d38d3900 fffff=
fff ffffffff
[   19.914454] Call Trace:
[   19.914742]  [<c14341a1>] dump_stack+0x78/0xa8
[   19.915232]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   19.915806]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   19.916333]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   19.927128]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   19.927761]  [<c10537ff>] mmput+0x52/0xef
[   19.928263]  [<c1175602>] flush_old_exec+0x923/0x99d
[   19.928851]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   19.929414]  [<c108559f>] ? local_clock+0x2f/0x39
[   19.929923]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   19.939602]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   19.940974]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   19.944352]  [<c11762eb>] do_execve+0x19/0x1b
[   19.944830]  [<c1176586>] SyS_execve+0x21/0x25
[   19.945324]  [<c143be92>] syscall_call+0x7/0x7
[   19.945805] ---[ end trace 6a7094e9a1d04cfc ]---
[   19.992096] ------------[ cut here ]------------
[   19.992763] WARNING: CPU: 0 PID: 700 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   20.013460] Modules linked in:
[   20.014034] CPU: 0 PID: 700 Comm: sh Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   20.014876]  00000001 00000000 0000001e d384fea8 c14341a1 00000000 00000=
000 c16ebf08
[   20.015880]  d384fec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d384fed4
[   20.026962]  c1056a11 00000009 00000000 d384ff2c c1150db8 d3858380 fffff=
fff ffffffff
[   20.031296] Call Trace:
[   20.031578]  [<c14341a1>] dump_stack+0x78/0xa8
[   20.032068]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   20.032669]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   20.033206]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   20.044840]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   20.045473]  [<c10537ff>] mmput+0x52/0xef
[   20.045992]  [<c105955b>] do_exit+0x5bc/0xee9
[   20.046518]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   20.054521]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   20.055096]  [<c143becb>] ? restore_all+0xf/0xf
[   20.055638]  [<c1059fe4>] do_group_exit+0x113/0x113
[   20.056247]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   20.073576]  [<c143be92>] syscall_call+0x7/0x7
[   20.074146] ---[ end trace 6a7094e9a1d04cfd ]---
[   20.080701] ------------[ cut here ]------------
[   20.081259] WARNING: CPU: 1 PID: 701 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   20.082418] Modules linked in:
[   20.082835] CPU: 1 PID: 701 Comm: init Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   20.084242]  00000001 00000000 0000001f d388de08 c14341a1 00000000 00000=
001 c16ebf08
[   20.085308]  d388de24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d388de34
[   20.086283]  c1056a11 00000009 00000000 d388de8c c1150db8 d389e900 fffff=
fff ffffffff
[   20.087583] Call Trace:
[   20.087865]  [<c14341a1>] dump_stack+0x78/0xa8
[   20.088394]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   20.088985]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   20.089507]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   20.090146]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   20.091035]  [<c10537ff>] mmput+0x52/0xef
[   20.091606]  [<c1175602>] flush_old_exec+0x923/0x99d
[   20.092240]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   20.092823]  [<c108559f>] ? local_clock+0x2f/0x39
[   20.093395]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   20.101095]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   20.105142]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   20.105729]  [<c11762eb>] do_execve+0x19/0x1b
[   20.106215]  [<c1176586>] SyS_execve+0x21/0x25
[   20.106742]  [<c143be92>] syscall_call+0x7/0x7
[   20.117572] ---[ end trace 6a7094e9a1d04cfe ]---
/bin/sh: /proc/self/fd/9: No such file or directory
[   20.129523] ------------[ cut here ]------------
[   20.130122] WARNING: CPU: 0 PID: 701 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   20.131243] Modules linked in:
[   20.131739] CPU: 0 PID: 701 Comm: sh Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   20.132729]  00000001 00000000 00000020 d388dea8 c14341a1 00000000 00000=
000 c16ebf08
[   20.133932]  d388dec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d388ded4
[   20.145127]  c1056a11 00000009 00000000 d388df2c c1150db8 d38d6580 fffff=
fff ffffffff
[   20.146141] Call Trace:
[   20.146423]  [<c14341a1>] dump_stack+0x78/0xa8
[   20.146961]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   20.147597]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   20.158389]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   20.158976]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   20.159496]  [<c10537ff>] mmput+0x52/0xef
[   20.164889]  [<c105955b>] do_exit+0x5bc/0xee9
[   20.165385]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   20.165948]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   20.166464]  [<c143becb>] ? restore_all+0xf/0xf
[   20.167014]  [<c1059fe4>] do_group_exit+0x113/0x113
[   20.167601]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   20.178248]  [<c143be92>] syscall_call+0x7/0x7
[   20.178741] ---[ end trace 6a7094e9a1d04cff ]---
[   20.179612] sh (701) used greatest stack depth: 6064 bytes left
[   20.187659] ------------[ cut here ]------------
[   20.188231] WARNING: CPU: 1 PID: 702 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   20.189198] Modules linked in:
[   20.189553] CPU: 1 PID: 702 Comm: init Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   20.190862]  00000001 00000000 00000021 d384fe08 c14341a1 00000000 00000=
001 c16ebf08
[   20.191932]  d384fe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d384fe34
[   20.193061]  c1056a11 00000009 00000000 d384fe8c c1150db8 d38ecd80 fffff=
fff ffffffff
[   20.194492] Call Trace:
[   20.194843]  [<c14341a1>] dump_stack+0x78/0xa8
[   20.195404]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   20.196045]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   20.196582]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   20.197383]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   20.197891]  [<c10537ff>] mmput+0x52/0xef
[   20.198366]  [<c1175602>] flush_old_exec+0x923/0x99d
[   20.198920]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   20.199495]  [<c108559f>] ? local_clock+0x2f/0x39
[   20.200049]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   20.211000]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   20.211629]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   20.212217]  [<c11762eb>] do_execve+0x19/0x1b
[   20.212695]  [<c1176586>] SyS_execve+0x21/0x25
[   20.213199]  [<c143be92>] syscall_call+0x7/0x7
[   20.224024] ---[ end trace 6a7094e9a1d04d00 ]---
/bin/sh: /proc/self/fd/9: No such file or directory
[   20.230910] ------------[ cut here ]------------
[   20.231438] WARNING: CPU: 0 PID: 702 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   20.232480] Modules linked in:
[   20.232851] CPU: 0 PID: 702 Comm: sh Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   20.233818]  00000001 00000000 00000022 d384fea8 c14341a1 00000000 00000=
000 c16ebf08
[   20.235080]  d384fec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d384fed4
[   20.236062]  c1056a11 00000009 00000000 d384ff2c c1150db8 d3858380 fffff=
fff ffffffff
[   20.237161] Call Trace:
[   20.237484]  [<c14341a1>] dump_stack+0x78/0xa8
[   20.238033]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   20.248802]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   20.251923]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   20.252574]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   20.253160]  [<c10537ff>] mmput+0x52/0xef
[   20.253661]  [<c105955b>] do_exit+0x5bc/0xee9
[   20.254211]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   20.264933]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   20.265534]  [<c143becb>] ? restore_all+0xf/0xf
[   20.266094]  [<c1059fe4>] do_group_exit+0x113/0x113
[   20.266712]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   20.267303]  [<c143be92>] syscall_call+0x7/0x7
[   20.267792] ---[ end trace 6a7094e9a1d04d01 ]---
[   28.338345] ------------[ cut here ]------------
[   28.343824] WARNING: CPU: 0 PID: 704 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   28.344901] Modules linked in:
[   28.345320] CPU: 0 PID: 704 Comm: trinity-main Tainted: G        W      =
3.19.0-rc5-gf7a7b53 #19
[   28.346444]  00000001 00000000 00000023 d388dea8 c14341a1 00000000 00000=
000 c16ebf08
[   28.400827]  d388dec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d388ded4
[   28.401826]  c1056a11 00000009 00000000 d388df2c c1150db8 d38ab380 fffff=
fff ffffffff
[   28.402783] Call Trace:
[   28.403067]  [<c14341a1>] dump_stack+0x78/0xa8
[   28.403573]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   28.423685]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   28.430255]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   28.431089]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   28.431638]  [<c10537ff>] mmput+0x52/0xef
[   28.432128]  [<c105955b>] do_exit+0x5bc/0xee9
[   28.436816]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   28.443566]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   28.444195]  [<c143becb>] ? restore_all+0xf/0xf
[   28.444693]  [<c1059fe4>] do_group_exit+0x113/0x113
[   28.445233]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   28.445762]  [<c143be92>] syscall_call+0x7/0x7
[   28.446257] ---[ end trace 6a7094e9a1d04d02 ]---
[   66.803434] Writes:  Total: 4  Max/Min: 0/0   Fail: 0=20
[   78.293952] ------------[ cut here ]------------
[   78.295244] WARNING: CPU: 0 PID: 694 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   78.296315] Modules linked in:
[   78.296782] CPU: 0 PID: 694 Comm: sleep Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   78.298069]  00000001 00000000 00000024 c0025ea8 c14341a1 00000000 00000=
000 c16ebf08
[   78.299152]  c0025ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0025ed4
[   78.300164]  c1056a11 00000009 00000000 c0025f2c c1150db8 d38ec980 fffff=
fff ffffffff
[   78.301120] Call Trace:
[   78.301399]  [<c14341a1>] dump_stack+0x78/0xa8
[   78.301965]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   78.302542]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   78.303059]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   78.303718]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   78.304220]  [<c10537ff>] mmput+0x52/0xef
[   78.304656]  [<c105955b>] do_exit+0x5bc/0xee9
[   78.305200]  [<c143becb>] ? restore_all+0xf/0xf
[   78.305695]  [<c1059fe4>] do_group_exit+0x113/0x113
[   78.306251]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   78.307850]  [<c143be92>] syscall_call+0x7/0x7
[   78.310231] ---[ end trace 6a7094e9a1d04d03 ]---
[   78.311575] ------------[ cut here ]------------
[   78.317210] WARNING: CPU: 0 PID: 687 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   78.318157] Modules linked in:
[   78.323651] CPU: 0 PID: 687 Comm: 99-trinity Tainted: G        W      3.=
19.0-rc5-gf7a7b53 #19
[   78.324701]  00000001 00000000 00000025 d38bfea8 c14341a1 00000000 00000=
000 c16ebf08
[   78.332506]  d38bfec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38bfed4
[   78.340204]  c1056a11 00000009 00000000 d38bff2c c1150db8 d38b2780 fffff=
fff ffffffff
[   78.341165] Call Trace:
[   78.341442]  [<c14341a1>] dump_stack+0x78/0xa8
[   78.348839]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   78.349499]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   78.356058]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   78.356623]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   78.362304]  [<c10537ff>] mmput+0x52/0xef
[   78.362741]  [<c105955b>] do_exit+0x5bc/0xee9
[   78.363222]  [<c116e776>] ? __vfs_read+0x32/0x9a
[   78.368937]  [<c10034fa>] ? do_device_not_available+0xa6/0xac
[   78.369555]  [<c143becb>] ? restore_all+0xf/0xf
[   78.376800]  [<c1059fe4>] do_group_exit+0x113/0x113
[   78.377413]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   78.378024]  [<c143be92>] syscall_call+0x7/0x7
[   78.385361] ---[ end trace 6a7094e9a1d04d04 ]---
[   78.437226] ------------[ cut here ]------------
[   78.437765] WARNING: CPU: 0 PID: 686 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   78.449488] Modules linked in:
[   78.449902] CPU: 0 PID: 686 Comm: run-parts Tainted: G        W      3.1=
9.0-rc5-gf7a7b53 #19
[   78.450879]  00000001 00000000 00000026 d38bdea8 c14341a1 00000000 00000=
000 c16ebf08
[   78.451925]  d38bdec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38bded4
[   78.452996]  c1056a11 00000009 00000000 d38bdf2c c1150db8 d38a7780 fffff=
fff ffffffff
[   78.454099] Call Trace:
[   78.454405]  [<c14341a1>] dump_stack+0x78/0xa8
[   78.454918]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   78.455538]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   78.483137]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   78.483710]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   78.484211]  [<c10537ff>] mmput+0x52/0xef
[   78.484648]  [<c105955b>] do_exit+0x5bc/0xee9
[   78.485190]  [<c143becb>] ? restore_all+0xf/0xf
[   78.485776]  [<c1059fe4>] do_group_exit+0x113/0x113
[   78.486384]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   78.487001]  [<c143be92>] syscall_call+0x7/0x7
[   78.487547] ---[ end trace 6a7094e9a1d04d05 ]---
[   78.501961] ------------[ cut here ]------------
[   78.502542] WARNING: CPU: 1 PID: 705 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   78.503617] Modules linked in:
[   78.504018] CPU: 1 PID: 705 Comm: rc.local Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   78.505029]  00000001 00000000 00000027 d38cbe08 c14341a1 00000000 00000=
001 c16ebf08
[   78.506057]  d38cbe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38cbe34
[   78.520172]  c1056a11 00000009 00000000 d38cbe8c c1150db8 d38b2500 fffff=
fff ffffffff
[   78.521266] Call Trace:
[   78.521588]  [<c14341a1>] dump_stack+0x78/0xa8
[   78.522122]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   78.522694]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   78.523211]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   78.523791]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   78.540469]  [<c10537ff>] mmput+0x52/0xef
[   78.540979]  [<c1175602>] flush_old_exec+0x923/0x99d
[   78.541591]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   78.542201]  [<c108559f>] ? local_clock+0x2f/0x39
[   78.542731]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   78.548135]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   78.548884]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   78.549553]  [<c11762eb>] do_execve+0x19/0x1b
[   78.556853]  [<c1176586>] SyS_execve+0x21/0x25
[   78.557412]  [<c143be92>] syscall_call+0x7/0x7
[   78.557951] ---[ end trace 6a7094e9a1d04d06 ]---
[   78.595950] ------------[ cut here ]------------
[   78.596494] WARNING: CPU: 0 PID: 705 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   78.607631] Modules linked in:
[   78.608054] CPU: 0 PID: 705 Comm: reboot Tainted: G        W      3.19.0=
-rc5-gf7a7b53 #19
[   78.608988]  00000001 00000000 00000028 d38cbe08 c14341a1 00000000 00000=
000 c16ebf08
[   78.609974]  d38cbe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38cbe34
[   78.621071]  c1056a11 00000009 00000000 d38cbe8c c1150db8 d38ec800 fffff=
fff ffffffff
[   78.622141] Call Trace:
[   78.622511]  [<c14341a1>] dump_stack+0x78/0xa8
[   78.623036]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   78.633761]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   78.634355]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   78.635029]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   78.635555]  [<c10537ff>] mmput+0x52/0xef
[   78.635998]  [<c1175602>] flush_old_exec+0x923/0x99d
[   78.636538]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   78.648957]  [<c108559f>] ? local_clock+0x2f/0x39
[   78.649472]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   78.650197]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   78.650870]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   78.651545]  [<c11762eb>] do_execve+0x19/0x1b
[   78.664680]  [<c1176586>] SyS_execve+0x21/0x25
[   78.668755]  [<c143be92>] syscall_call+0x7/0x7
[   78.669329] ---[ end trace 6a7094e9a1d04d07 ]---
[   78.722477] ------------[ cut here ]------------
[   78.722530] ------------[ cut here ]------------
[   78.722539] WARNING: CPU: 0 PID: 705 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   78.722542] Modules linked in:
[   78.722545] CPU: 0 PID: 705 Comm: shutdown Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   78.722554]  00000001 00000000 00000029 d38cbea8 c14341a1 00000000 00000=
000 c16ebf08
[   78.722561]  d38cbec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38cbed4
[   78.722568]  c1056a11 00000009 00000000 d38cbf2c c1150db8 d38d3600 fffff=
fff ffffffff
[   78.722569] Call Trace:
[   78.722577]  [<c14341a1>] dump_stack+0x78/0xa8
[   78.722582]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   78.722586]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   78.722590]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   78.722593]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   78.722598]  [<c10537ff>] mmput+0x52/0xef
[   78.722602]  [<c105955b>] do_exit+0x5bc/0xee9
[   78.722607]  [<c143becb>] ? restore_all+0xf/0xf
[   78.722611]  [<c1059fe4>] do_group_exit+0x113/0x113
[   78.722615]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   78.722618]  [<c143be92>] syscall_call+0x7/0x7
[   78.722621] ---[ end trace 6a7094e9a1d04d08 ]---
[   78.723527] ------------[ cut here ]------------
[   78.723532] WARNING: CPU: 0 PID: 681 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   78.723534] Modules linked in:
[   78.723537] CPU: 0 PID: 681 Comm: rc.local Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   78.723545]  00000001 00000000 0000002a d388bea8 c14341a1 00000000 00000=
000 c16ebf08
[   78.723552]  d388bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d388bed4
[   78.723558]  c1056a11 00000009 00000000 d388bf2c c1150db8 d3858b00 fffff=
fff ffffffff
[   78.723559] Call Trace:
[   78.723564]  [<c14341a1>] dump_stack+0x78/0xa8
[   78.723568]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   78.723572]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   78.723576]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   78.723579]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   78.723584]  [<c10537ff>] mmput+0x52/0xef
[   78.723588]  [<c105955b>] do_exit+0x5bc/0xee9
[   78.723593]  [<c10fead5>] ? trace_hardirqs_on+0x31/0x33
[   78.723598]  [<c106582e>] ? sigprocmask+0x99/0xaa
[   78.723602]  [<c143becb>] ? restore_all+0xf/0xf
[   78.723606]  [<c1059fe4>] do_group_exit+0x113/0x113
[   78.723609]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   78.723613]  [<c143be92>] syscall_call+0x7/0x7
[   78.723615] ---[ end trace 6a7094e9a1d04d09 ]---
[   78.851617] WARNING: CPU: 1 PID: 706 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   78.851620] Modules linked in:
[   78.851624] CPU: 1 PID: 706 Comm: shutdown Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   78.851634]  00000001 00000000 0000002b d3863ea8 c14341a1 00000000 00000=
001 c16ebf08
[   78.851640]  d3863ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3863ed4
[   78.851647]  c1056a11 00000009 00000000 d3863f2c c1150db8 d384ca00 fffff=
fff ffffffff
[   78.851648] Call Trace:
[   78.851660]  [<c14341a1>] dump_stack+0x78/0xa8
[   78.851665]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   78.851669]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   78.851673]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   78.851676]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   78.851682]  [<c10537ff>] mmput+0x52/0xef
[   78.851686]  [<c105955b>] do_exit+0x5bc/0xee9
[   78.851691]  [<c143becb>] ? restore_all+0xf/0xf
[   78.851696]  [<c1059fe4>] do_group_exit+0x113/0x113
[   78.851700]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   78.851703]  [<c143be92>] syscall_call+0x7/0x7
[   78.851706] ---[ end trace 6a7094e9a1d04d0a ]---
[   78.870045] ------------[ cut here ]------------
[   78.870709] WARNING: CPU: 0 PID: 707 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   78.881989] Modules linked in:
[   78.882353] CPU: 0 PID: 707 Comm: init Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   78.883233]  00000001 00000000 0000002c c0021e08 c14341a1 00000000 00000=
000 c16ebf08
[   78.884268]  c0021e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0021e34
[   78.898841]  c1056a11 00000009 00000000 c0021e8c c1150db8 d3858380 fffff=
fff ffffffff
[   78.899973] Call Trace:
[   78.900304]  [<c14341a1>] dump_stack+0x78/0xa8
[   78.900796]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   78.901382]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   78.915359]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   78.915920]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   78.916427]  [<c10537ff>] mmput+0x52/0xef
[   78.916928]  [<c1175602>] flush_old_exec+0x923/0x99d
[   78.917539]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   78.932060]  [<c108559f>] ? local_clock+0x2f/0x39
[   78.932575]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   78.933256]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   78.933888]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   78.934477]  [<c11762eb>] do_execve+0x19/0x1b
[   78.934958]  [<c1176586>] SyS_execve+0x21/0x25
[   78.948972]  [<c143be92>] syscall_call+0x7/0x7
[   78.949537] ---[ end trace 6a7094e9a1d04d0b ]---
[   78.975986] ------------[ cut here ]------------
[   78.976624] WARNING: CPU: 0 PID: 708 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   78.977801] Modules linked in:
[   78.978227] CPU: 0 PID: 708 Comm: init Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   78.979133]  00000001 00000000 0000002d d38fbe08 c14341a1 00000000 00000=
000
[   78.998320] ------------[ cut here ]------------
[   78.998330] WARNING: CPU: 1 PID: 707 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   78.998331] Modules linked in:

[   79.001890]  c16ebf08
[   79.002219]  d38fbe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbe34
[   79.003206]  c1056a11 00000009 00000000 d38fbe8c c1150db8 d384cd80 fffff=
fff ffffffff
[   79.004207] Call Trace:
[   79.004497]  [<c14341a1>] dump_stack+0x78/0xa8
[   79.025089]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   79.025705]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   79.026231]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   79.026822]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   79.027351]  [<c10537ff>] mmput+0x52/0xef
[   79.027813]  [<c1175602>] flush_old_exec+0x923/0x99d
[   79.028378]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   79.028973]  [<c108559f>] ? local_clock+0x2f/0x39
[   79.029492]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   79.050483]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   79.051517]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   79.052180]  [<c11762eb>] do_execve+0x19/0x1b
[   79.052657]  [<c1176586>] SyS_execve+0x21/0x25
[   79.053154]  [<c143be92>] syscall_call+0x7/0x7
[   79.053666] ---[ end trace 6a7094e9a1d04d0c ]---
[   79.065081] CPU: 1 PID: 707 Comm: sh Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   79.065937]  00000001 00000000 0000002e c0021d4c c14341a1 00000000 00000=
001 c16ebf08
[   79.066915]  c0021d68 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0021d78
[   79.067879]  c1056a11 00000009 00000000
[   79.080190] ------------[ cut here ]------------
[   79.080198] WARNING: CPU: 0 PID: 708 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   79.080199] Modules linked in:

[   79.098450]  c0021dd0 c1150db8 d38a7000 ffffffff ffffffff
[   79.099189] Call Trace:
[   79.099470]  [<c14341a1>] dump_stack+0x78/0xa8
[   79.099962]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   79.100555]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   79.101087]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   79.115213]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   79.115767]  [<c10537ff>] mmput+0x52/0xef
[   79.116267]  [<c1175602>] flush_old_exec+0x923/0x99d
[   79.116887]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   79.117521]  [<c108559f>] ? local_clock+0x2f/0x39
[   79.118106]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   79.137829]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   79.138438]  [<c11ac7e5>] load_script+0x339/0x355
[   79.139123]  [<c108550c>] ? sched_clock_cpu+0x188/0x1a3
[   79.139769]  [<c108559f>] ? local_clock+0x2f/0x39
[   79.140325]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   79.148106]  [<c109c1bf>] ? do_raw_read_unlock+0x28/0x53
[   79.148817]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   79.149508]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   79.150132]  [<c11762eb>] do_execve+0x19/0x1b
[   79.150610]  [<c1176586>] SyS_execve+0x21/0x25
[   79.161302]  [<c143be92>] syscall_call+0x7/0x7
[   79.161805] ---[ end trace 6a7094e9a1d04d0d ]---
[   79.161809] CPU: 0 PID: 708 Comm: sh Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   79.161820]  00000001 00000000 0000002f d38fbea8 c14341a1 00000000 00000=
000 c16ebf08
[   79.161828]  d38fbec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbed4
[   79.161834]  c1056a11 00000009 00000000 d38fbf2c c1150db8 d38a2500 fffff=
fff ffffffff
[   79.161836] Call Trace:
[   79.161843]  [<c14341a1>] dump_stack+0x78/0xa8
[   79.161848]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   79.161853]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   79.161856]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   79.161860]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   79.161865]  [<c10537ff>] mmput+0x52/0xef
[   79.161869]  [<c105955b>] do_exit+0x5bc/0xee9
[   79.161875]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   79.161879]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   79.161883]  [<c143becb>] ? restore_all+0xf/0xf
[   79.161887]  [<c1059fe4>] do_group_exit+0x113/0x113
[   79.161890]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   79.161894]  [<c143be92>] syscall_call+0x7/0x7
[   79.161897] ---[ end trace 6a7094e9a1d04d0e ]---
[   79.223273] ------------[ cut here ]------------
[   79.223892] WARNING: CPU: 0 PID: 709 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   79.224953] Modules linked in:
[   79.225334] CPU: 0 PID: 709 Comm: init Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   79.226226]  00000001 00000000 00000030 d3861e08 c14341a1 00000000 00000=
000 c16ebf08
[   79.227241]  d3861e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3861e34
[   79.228210]  c1056a11 00000009 00000000 d3861e8c c1150db8 d14dad00 fffff=
fff ffffffff
[   79.229355] Call Trace:
[   79.229696]  [<c14341a1>] dump_stack+0x78/0xa8
[   79.230287]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   79.230969]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   79.231586]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   79.232246]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   79.232809]  [<c10537ff>] mmput+0x52/0xef
[   79.233376]  [<c1175602>] flush_old_exec+0x923/0x99d
[   79.241045]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   79.241694]  [<c108559f>] ? local_clock+0x2f/0x39
[   79.242325]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   79.243112]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   79.243778]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   79.244367]  [<c11762eb>] do_execve+0x19/0x1b
[   79.244856]  [<c1176586>] SyS_execve+0x21/0x25
[   79.245495]  [<c143be92>] syscall_call+0x7/0x7
[   79.246142] ---[ end trace 6a7094e9a1d04d0f ]---
[   79.270792] ------------[ cut here ]------------
[   79.280510] WARNING: CPU: 1 PID: 710 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   79.285060] Modules linked in:
[   79.285515] CPU: 1 PID: 710 Comm: rc Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   79.286621]  00000001 00000000 00000031 d386de08 c14341a1 00000000 00000=
001 c16ebf08
plymouth-upstart-bridge: ply-event-loop.c:497: ply_event_loop_new: Assertio=
n `loop->epoll_fd >=3D 0' failed.
[   79.298751] ------------[ cut here ]------------
[   79.298758] WARNING: CPU: 0 PID: 709 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   79.298760] Modules linked in:
[   79.312007]  d386de24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d386de34
[   79.315200]  c1056a11 00000009 00000000 d386de8c c1150db8 d3892000 fffff=
fff ffffffff
[   79.316528] Call Trace:
[   79.316827]  [<c14341a1>] dump_stack+0x78/0xa8
[   79.317324]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   79.317965]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   79.333046]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   79.333648]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   79.334177]  [<c10537ff>] mmput+0x52/0xef
[   79.334666]  [<c1175602>] flush_old_exec+0x923/0x99d
[   79.345355]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   79.349627]  [<c108559f>] ? local_clock+0x2f/0x39
[   79.350297]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   79.351119]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   79.351737]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   79.368111]  [<c11762eb>] do_execve+0x19/0x1b
[   79.369127]  [<c1176586>] SyS_execve+0x21/0x25
[   79.369709]  [<c143be92>] syscall_call+0x7/0x7
[   79.370320] ---[ end trace 6a7094e9a1d04d10 ]---
[   79.378999] CPU: 0 PID: 709 Comm: plymouth-upstar Tainted: G        W   =
   3.19.0-rc5-gf7a7b53 #19
[   79.398188]  00000001 00000000 00000032 d3861db8 c14341a1 00000000 00000=
000 c16ebf08
[   79.399222]  d3861dd4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3861de4
[   79.400232] ------------[ cut here ]------------
[   79.400240] WARNING: CPU: 1 PID: 710 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   79.400241] Modules linked in:

[   79.402229]=20
[   79.402464]  c1056a11 00000009 00000000 d3861e3c c1150db8 d3858380 fffff=
fff ffffffff
[   79.403597] Call Trace:
[   79.403916]  [<c14341a1>] dump_stack+0x78/0xa8
[   79.404485]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   79.405187]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   79.405764]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   79.413458]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   79.414079]  [<c10537ff>] mmput+0x52/0xef
[   79.414625]  [<c105955b>] do_exit+0x5bc/0xee9
[   79.415214]  [<c1059fe4>] do_group_exit+0x113/0x113
[   79.415824]  [<c10653f7>] get_signal+0x89d/0x966
[   79.416442]  [<c10027f7>] do_signal+0x1e/0x12c
[   79.417156]  [<c1063c88>] ? do_tkill+0x81/0x89
[   79.417814]  [<c1002950>] do_notify_resume+0x4b/0xcb
[   79.418460]  [<c143bfa0>] work_notifysig+0x2b/0x3b
[   79.419003] ---[ end trace 6a7094e9a1d04d11 ]---
[   79.424448] CPU: 1 PID: 710 Comm: stty Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   79.425470]  00000001 00000000 00000033 d386dea8 c14341a1 00000000 00000=
001 c16ebf08
[   79.426516]  d386dec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d386ded4
[   79.427522]  c1056a11 00000009 00000000 d386df2c c1150db8 d3892700 fffff=
fff ffffffff
[   79.438640] Call Trace:
[   79.438989]  [<c14341a1>] dump_stack+0x78/0xa8
[   79.439616]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   79.440385]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   79.451117]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   79.451680]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   79.452295]  [<c10537ff>] mmput+0x52/0xef
[   79.452832]  [<c105955b>] do_exit+0x5bc/0xee9
[   79.453460]  [<c143becb>] ? restore_all+0xf/0xf
[   79.454100]  [<c1059fe4>] do_group_exit+0x113/0x113
[   79.464812]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   79.465375]  [<c143be92>] syscall_call+0x7/0x7
[   79.465980] ---[ end trace 6a7094e9a1d04d12 ]---
[   79.548545] ------------[ cut here ]------------
[   79.549084] WARNING: CPU: 0 PID: 711 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   79.556819] Modules linked in:
[   79.557208] CPU: 0 PID: 711 Comm: rc Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   79.558064]  00000001 00000000 00000034 d38fbe08 c14341a1 00000000 00000=
000 c16ebf08
[   79.559166]  d38fbe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbe34
[   79.567002]  c1056a11 00000009 00000000 d38fbe8c c1150db8 d38d3000 fffff=
fff ffffffff
[   79.567972] Call Trace:
[   79.568255]  [<c14341a1>] dump_stack+0x78/0xa8
[   79.568838]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   79.569450]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   79.569980]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   79.577393]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   79.577991]  [<c10537ff>] mmput+0x52/0xef
[   79.578504]  [<c1175602>] flush_old_exec+0x923/0x99d
[   79.579054]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   79.579618]  [<c108559f>] ? local_clock+0x2f/0x39
[   79.586904]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   79.587671]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   79.588350]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   79.589073]  [<c11762eb>] do_execve+0x19/0x1b
[   79.589670]  [<c1176586>] SyS_execve+0x21/0x25
[   79.596997]  [<c143be92>] syscall_call+0x7/0x7
[   79.597486] ---[ end trace 6a7094e9a1d04d13 ]---
[   79.599650] ------------[ cut here ]------------
[   79.606972] WARNING: CPU: 0 PID: 711 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   79.607923] Modules linked in:
[   79.608289] CPU: 0 PID: 711 Comm: startpar Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   79.609352]  00000001 00000000 00000035 d38fbea8 c14341a1 00000000 00000=
000 c16ebf08
[   79.617169]  d38fbec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbed4
[   79.618140]  c1056a11 00000009 00000000 d38fbf2c c1150db8 d14dad00 fffff=
fff ffffffff
[   79.619151] Call Trace:
[   79.619435]  [<c14341a1>] dump_stack+0x78/0xa8
[   79.619926]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   79.625703]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   79.626360]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   79.633715]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   79.634225]  [<c10537ff>] mmput+0x52/0xef
[   79.634669]  [<c105955b>] do_exit+0x5bc/0xee9
[   79.635214]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   79.635855]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   79.636441]  [<c143becb>] ? restore_all+0xf/0xf
[   79.643723]  [<c1059fe4>] do_group_exit+0x113/0x113
[   79.644281]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   79.644805]  [<c143be92>] syscall_call+0x7/0x7
[   79.645386] ---[ end trace 6a7094e9a1d04d14 ]---
[   79.711284] ------------[ cut here ]------------
[   79.711974] WARNING: CPU: 1 PID: 712 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   79.722033] Modules linked in:
[   79.722463] CPU: 1 PID: 712 Comm: rc Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   79.733550]  00000001 00000000 00000036 d386dd4c c14341a1 00000000 00000=
001 c16ebf08
[   79.734701]  d386dd68 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d386dd78
[   79.735815]  c1056a11 00000009 00000000 d386ddd0 c1150db8 d3858380 fffff=
fff ffffffff
[   79.747021] Call Trace:
[   79.747355]  [<c14341a1>] dump_stack+0x78/0xa8
[   79.747967]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   79.748715]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   79.749384]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   79.760162]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   79.760718]  [<c10537ff>] mmput+0x52/0xef
[   79.761222]  [<c1175602>] flush_old_exec+0x923/0x99d
[   79.761852]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   79.762521]  [<c108559f>] ? local_clock+0x2f/0x39
[   79.763167]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   79.774106]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   79.774843]  [<c11ac7e5>] load_script+0x339/0x355
[   79.775425]  [<c108550c>] ? sched_clock_cpu+0x188/0x1a3
[   79.776002]  [<c108559f>] ? local_clock+0x2f/0x39
[   79.776521]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   79.787297]  [<c109c1bf>] ? do_raw_read_unlock+0x28/0x53
[   79.787880]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   79.788536]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   79.789218]  [<c11762eb>] do_execve+0x19/0x1b
[   79.789841]  [<c1176586>] SyS_execve+0x21/0x25
[   79.800534]  [<c143be92>] syscall_call+0x7/0x7
[   79.801137] ---[ end trace 6a7094e9a1d04d15 ]---
[   79.931535] ------------[ cut here ]------------
[   79.932165] WARNING: CPU: 0 PID: 716 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   79.933215] Modules linked in:
[   79.933640] CPU: 0 PID: 716 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   79.934670]  00000001
[   79.941261] ------------[ cut here ]------------
[   79.941269] WARNING: CPU: 1 PID: 715 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   79.941270] Modules linked in:

[   79.961185]  00000000 00000037 d3849e08 c14341a1 00000000 00000000 c16eb=
f08
[   79.962321]  d3849e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3849e34
[   79.963456]  c1056a11 00000009 00000000 d3849e8c c1150db8 d38a7d80 fffff=
fff ffffffff
[   79.979658] Call Trace:
[   79.980034]  [<c14341a1>] dump_stack+0x78/0xa8
[   79.980616]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   79.981308]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   79.981923]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   79.982550]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   79.983159]  [<c10537ff>] mmput+0x52/0xef
[   79.983744]  [<c1175602>] flush_old_exec+0x923/0x99d
[   80.003438]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   80.004092]  [<c108559f>] ? local_clock+0x2f/0x39
[   80.004668]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   80.005430]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   80.006050]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   80.006656]  [<c11762eb>] do_execve+0x19/0x1b
[   80.007173]  [<c1176586>] SyS_execve+0x21/0x25
[   80.007742]  [<c143be92>] syscall_call+0x7/0x7
[   80.030386] ---[ end trace 6a7094e9a1d04d16 ]---
[   80.034742] ------------[ cut here ]------------
[   80.049988] CPU: 1 PID: 715 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   80.050015]  00000001 00000000 00000038 d388be08 c14341a1 00000000 00000=
001 c16ebf08
[   80.050022]  d388be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d388be34
[   80.050029]  c1056a11 00000009 00000000 d388be8c c1150db8 d3895a00 fffff=
fff ffffffff
[   80.050030] Call Trace:
[   80.050039]  [<c14341a1>] dump_stack+0x78/0xa8
[   80.050044]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   80.050050]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   80.050053]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   80.050057]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   80.050062]  [<c10537ff>] mmput+0x52/0xef
[   80.050066]  [<c1175602>] flush_old_exec+0x923/0x99d
[   80.050072]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   80.050076]  [<c108559f>] ? local_clock+0x2f/0x39
[   80.050082]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   80.050086]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   80.050090]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   80.050094]  [<c11762eb>] do_execve+0x19/0x1b
[   80.050098]  [<c1176586>] SyS_execve+0x21/0x25
[   80.050101]  [<c143be92>] syscall_call+0x7/0x7
[   80.050104] ---[ end trace 6a7094e9a1d04d17 ]---
[   80.106024] WARNING: CPU: 0 PID: 714 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   80.107118] Modules linked in:
[   80.107503] CPU: 0 PID: 714 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   80.108556]  00000001 00000000 00000039 c0025e08 c14341a1 00000000 00000=
000 c16ebf08
[   80.109732]  c0025e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0025e34
[   80.110926]  c1056a11 00000009 00000000 c0025e8c c1150db8 d38b6000 fffff=
fff ffffffff
[   80.136180] Call Trace:
[   80.136526]  [<c14341a1>] dump_stack+0x78/0xa8
[   80.137132]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   80.137790]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   80.138415]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   80.139145]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   80.139781]  [<c10537ff>] mmput+0x52/0xef
[   80.140319]  [<c1175602>] flush_old_exec+0x923/0x99d
[   80.140876]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   80.156692]  [<c108559f>] ? local_clock+0x2f/0x39
[   80.157369]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   80.158097]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   80.158803]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   80.159469]  [<c11762eb>] do_execve+0x19/0x1b
[   80.160051]  [<c1176586>] SyS_execve+0x21/0x25
[   80.160559]  [<c143be92>] syscall_call+0x7/0x7
[   80.161059] ---[ end trace 6a7094e9a1d04d18 ]---
[   80.254769] ------------[ cut here ]------------
[   80.255618] WARNING: CPU: 1 PID: 714 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   80.256599] Modules linked in:
[   80.257001] CPU: 1 PID: 714 Comm: initctl Tainted: G        W      3.19.=
0-rc5-gf7a7b53 #19
[   80.257888]  00000001 00000000 0000003a c0025ea8 c14341a1 00000000 00000=
001 c16ebf08
[   80.267688]  c0025ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0025ed4
[   80.273846]  c1056a11 00000009 00000000 c0025f2c c1150db8 d38a7d80 fffff=
fff ffffffff
[   80.274842] Call Trace:
[   80.280226]  [<c14341a1>] dump_stack+0x78/0xa8
[   80.280718]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   80.281306]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   80.290240]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   80.290802]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   80.291314]  [<c10537ff>] mmput+0x52/0xef
[   80.296885]  [<c105955b>] do_exit+0x5bc/0xee9
[   80.297400]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   80.297924]  [<c143becb>] ? restore_all+0xf/0xf
[   80.303596]  [<c1059fe4>] do_group_exit+0x113/0x113
[   80.304232]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   80.304863]  [<c143be92>] syscall_call+0x7/0x7
[   80.308881] ---[ end trace 6a7094e9a1d04d19 ]---
[   80.335821] ------------[ cut here ]------------
[   80.336367] WARNING: CPU: 1 PID: 715 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   80.337393] Modules linked in:
[   80.337771] CPU: 1 PID: 715 Comm: grep Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   80.341312] ------------[ cut here ]------------
[   80.341317] WARNING: CPU: 0 PID: 716 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   80.341320] Modules linked in:
[   80.344295]  00000001 00000000 0000003b d388bea8 c14341a1 00000000 00000=
001 c16ebf08
[   80.358833]  d388bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d388bed4
[   80.359809]  c1056a11 00000009 00000000 d388bf2c c1150db8 d3858380 fffff=
fff ffffffff
[   80.360843] Call Trace:
[   80.361135]  [<c14341a1>] dump_stack+0x78/0xa8
[   80.361626]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   80.375821]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   80.376590]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   80.377511]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   80.388540]  [<c10537ff>] mmput+0x52/0xef
[   80.389063]  [<c105955b>] do_exit+0x5bc/0xee9
[   80.389600]  [<c143becb>] ? restore_all+0xf/0xf
[   80.390198]  [<c1059fe4>] do_group_exit+0x113/0x113
[   80.390821]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   80.391377]  [<c143be92>] syscall_call+0x7/0x7
[   80.401035] ---[ end trace 6a7094e9a1d04d1a ]---
[   80.415990] CPU: 0 PID: 716 Comm: sed Tainted: G        W      3.19.0-rc=
5-gf7a7b53 #19
[   80.416975]  00000001 00000000 0000003c d3849ea8 c14341a1 00000000 00000=
000 c16ebf08
[   80.418053]  d3849ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3849ed4
[   80.419214]  c1056a11 00000009 00000000 d3849f2c c1150db8 d14dad00 fffff=
fff ffffffff
[   80.420341] Call Trace:
[   80.420625]  [<c14341a1>] dump_stack+0x78/0xa8
[   80.427525]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   80.428224]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   80.428818]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   80.429470]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   80.430032]  [<c10537ff>] mmput+0x52/0xef
[   80.430503]  [<c105955b>] do_exit+0x5bc/0xee9
[   80.430990]  [<c143becb>] ? restore_all+0xf/0xf
[   80.431489]  [<c1059fe4>] do_group_exit+0x113/0x113
[   80.451817]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   80.452449]  [<c143be92>] syscall_call+0x7/0x7
[   80.453032] ---[ end trace 6a7094e9a1d04d1b ]---
[   80.454702] ------------[ cut here ]------------
[   80.455243] WARNING: CPU: 1 PID: 713 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   80.456234] Modules linked in:
[   80.456597] CPU: 1 PID: 713 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   80.457574]  00000001 00000000 0000003d d38fbea8 c14341a1 00000000 00000=
001 c16ebf08
[   80.458747]  d38fbec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbed4
[   80.459740]  c1056a11 00000009 00000000 d38fbf2c c1150db8 d38d3000 fffff=
fff ffffffff
[   80.460794] Call Trace:
[   80.461088]  [<c14341a1>] dump_stack+0x78/0xa8
[   80.461578]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   80.462272]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   80.462811]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   80.463445]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   80.463961]  [<c10537ff>] mmput+0x52/0xef
[   80.464418]  [<c105955b>] do_exit+0x5bc/0xee9
[   80.464922]  [<c10034fa>] ? do_device_not_available+0xa6/0xac
[   80.465652]  [<c143becb>] ? restore_all+0xf/0xf
[   80.466215]  [<c1059fe4>] do_group_exit+0x113/0x113
[   80.466831]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   80.467439]  [<c143be92>] syscall_call+0x7/0x7
[   80.468017] ---[ end trace 6a7094e9a1d04d1c ]---
[   80.503465] ------------[ cut here ]------------
[   80.504090] WARNING: CPU: 0 PID: 717 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   80.505237] Modules linked in:
[   80.505630] CPU: 0 PID: 717 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   80.506599]  00000001 00000000 0000003e d381be08 c14341a1 00000000 00000=
000 c16ebf08
[   80.518078]  d381be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381be34
[   80.519121]  c1056a11 00000009 00000000 d381be8c c1150db8 d38d3000 fffff=
fff ffffffff
[   80.530193] Call Trace:
[   80.530488]  [<c14341a1>] dump_stack+0x78/0xa8
[   80.530999]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   80.531581]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   80.532193]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   80.532868]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   80.543574]  [<c10537ff>] mmput+0x52/0xef
[   80.544131]  [<c1175602>] flush_old_exec+0x923/0x99d
[   80.544805]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   80.545468]  [<c108559f>] ? local_clock+0x2f/0x39
[   80.546108]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   80.560320]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   80.560922]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   80.561515]  [<c11762eb>] do_execve+0x19/0x1b
[   80.562059]  [<c1176586>] SyS_execve+0x21/0x25
[   80.562601]  [<c143be92>] syscall_call+0x7/0x7
[   80.563147] ---[ end trace 6a7094e9a1d04d1d ]---
[   80.572106] ------------[ cut here ]------------
[   80.572690] WARNING: CPU: 0 PID: 717 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   80.583849] Modules linked in:
[   80.584237] CPU: 0 PID: 717 Comm: sync Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   80.585167]  00000001 00000000 0000003f d381bea8 c14341a1 00000000 00000=
000 c16ebf08
[   80.586300]  d381bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bed4
[   80.600721]  c1056a11 00000009 00000000 d381bf2c c1150db8 d38d3600 fffff=
fff ffffffff
[   80.601711] Call Trace:
[   80.602039]  [<c14341a1>] dump_stack+0x78/0xa8
[   80.602531]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   80.603124]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   80.613817]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   80.614492]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   80.615097]  [<c10537ff>] mmput+0x52/0xef
[   80.615608]  [<c105955b>] do_exit+0x5bc/0xee9
[   80.616186]  [<c143becb>] ? restore_all+0xf/0xf
[   80.626858]  [<c1059fe4>] do_group_exit+0x113/0x113
[   80.627422]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   80.627958]  [<c143be92>] syscall_call+0x7/0x7
[   80.628503] ---[ end trace 6a7094e9a1d04d1e ]---
[   80.681828] ------------[ cut here ]------------
[   80.682457] WARNING: CPU: 0 PID: 718 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   80.683565] Modules linked in:
[   80.683928] CPU: 0 PID: 718 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   80.684857]  00000001 00000000 00000040 d38fbe08 c14341a1 00000000 00000=
000 c16ebf08
[   80.696848]  d38fbe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbe34
[   80.697859]  c1056a11 00000009 00000000 d38fbe8c c1150db8 d38b6000 fffff=
fff ffffffff
[   80.698946] Call Trace:
[   80.699279]  [<c14341a1>] dump_stack+0x78/0xa8
[   80.699860]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   80.711515]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   80.712137]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   80.712745]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   80.723031]  [<c10537ff>] mmput+0x52/0xef
[   80.723685]  [<c1175602>] flush_old_exec+0x923/0x99d
[   80.727100]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   80.727667]  [<c108559f>] ? local_clock+0x2f/0x39
[   80.728217]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   80.728960]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   80.729560]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   80.740261]  [<c11762eb>] do_execve+0x19/0x1b
[   80.740743]  [<c1176586>] SyS_execve+0x21/0x25
[   80.741241]  [<c143be92>] syscall_call+0x7/0x7
[   80.741760] ---[ end trace 6a7094e9a1d04d1f ]---
[   80.798252] ------------[ cut here ]------------
[   80.798847] WARNING: CPU: 1 PID: 718 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   80.799918] Modules linked in:
[   80.810465] CPU: 1 PID: 718 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   80.811559]  00000001 00000000 00000041 d38fbea8 c14341a1 00000000 00000=
001 c16ebf08
[   80.812775]  d38fbec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbed4
[   80.823920]  c1056a11 00000009 00000000 d38fbf2c c1150db8 d38b6d00 fffff=
fff ffffffff
[   80.824912] Call Trace:
[   80.825231]  [<c14341a1>] dump_stack+0x78/0xa8
[   80.825803]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   80.826458]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   80.836878]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   80.837456]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   80.837965]  [<c10537ff>] mmput+0x52/0xef
[   80.838442]  [<c105955b>] do_exit+0x5bc/0xee9
[   80.839019]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   80.839681]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   80.850424]  [<c143becb>] ? restore_all+0xf/0xf
[   80.851049]  [<c1059fe4>] do_group_exit+0x113/0x113
[   80.851708]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   80.852353]  [<c143be92>] syscall_call+0x7/0x7
[   80.852957] ---[ end trace 6a7094e9a1d04d20 ]---
[   80.884283] ------------[ cut here ]------------
[   80.884929] WARNING: CPU: 0 PID: 719 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   80.886058] Modules linked in:
[   80.886487] CPU: 0 PID: 719 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   80.887618]  00000001 00000000 00000042 d381be08 c14341a1 00000000 00000=
000 c16ebf08
[   80.900914]  d381be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381be34
[   80.901959]  c1056a11 00000009 00000000 d381be8c c1150db8 d38a7d80 fffff=
fff ffffffff
[   80.902936] Call Trace:
[   80.903220]  [<c14341a1>] dump_stack+0x78/0xa8
[   80.913800]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   80.914391]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   80.914909]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   80.915535]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   80.916064]  [<c10537ff>] mmput+0x52/0xef
[   80.916527]  [<c1175602>] flush_old_exec+0x923/0x99d
[   80.927168]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   80.927732]  [<c108559f>] ? local_clock+0x2f/0x39
[   80.928258]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   80.936761]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   80.937427]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   80.938063]  [<c11762eb>] do_execve+0x19/0x1b
[   80.938626]  [<c1176586>] SyS_execve+0x21/0x25
[   80.939231]  [<c143be92>] syscall_call+0x7/0x7
[   80.939816] ---[ end trace 6a7094e9a1d04d21 ]---
[   80.986166] ------------[ cut here ]------------
[   80.996818] WARNING: CPU: 1 PID: 719 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   80.997775] Modules linked in:
[   80.998140] CPU: 1 PID: 719 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   80.999147]  00000001 00000000 00000043 d381bea8 c14341a1 00000000 00000=
001 c16ebf08
[   81.010333]  d381bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bed4
[   81.011314]  c1056a11 00000009 00000000 d381bf2c c1150db8 d38b2500 fffff=
fff ffffffff
[   81.012476] Call Trace:
[   81.012813]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.013312]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.022726]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.023326]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.027482]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.028081]  [<c10537ff>] mmput+0x52/0xef
[   81.028595]  [<c105955b>] do_exit+0x5bc/0xee9
[   81.029115]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   81.029685]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   81.040414]  [<c143becb>] ? restore_all+0xf/0xf
[   81.040962]  [<c1059fe4>] do_group_exit+0x113/0x113
[   81.041544]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   81.042133]  [<c143be92>] syscall_call+0x7/0x7
[   81.042727] ---[ end trace 6a7094e9a1d04d22 ]---
[   81.070714] ------------[ cut here ]------------
[   81.071342] WARNING: CPU: 0 PID: 720 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.072441] Modules linked in:
[   81.072853] CPU: 0 PID: 720 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   81.073834]  00000001 00000000 00000044 d38fbe08 c14341a1 00000000 00000=
000 c16ebf08
[   81.087835]  d38fbe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbe34
[   81.088927]  c1056a11 00000009 00000000 d38fbe8c c1150db8 d38d3000 fffff=
fff ffffffff
[   81.089907] Call Trace:
[   81.100291]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.100808]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.101396]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.101978]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.102644]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.103266]  [<c10537ff>] mmput+0x52/0xef
[   81.117218]  [<c1175602>] flush_old_exec+0x923/0x99d
[   81.117876]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   81.118584]  [<c108559f>] ? local_clock+0x2f/0x39
[   81.119209]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   81.119939]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   81.130679]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   81.131316]  [<c11762eb>] do_execve+0x19/0x1b
[   81.131870]  [<c1176586>] SyS_execve+0x21/0x25
[   81.132464]  [<c143be92>] syscall_call+0x7/0x7
[   81.140163] ---[ end trace 6a7094e9a1d04d23 ]---
[   81.158655] ------------[ cut here ]------------
[   81.159296] WARNING: CPU: 1 PID: 720 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.160467] Modules linked in:
[   81.160909] CPU: 1 PID: 720 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   81.177141]  00000001 00000000 00000045 d38fbea8 c14341a1 00000000 00000=
001 c16ebf08
[   81.178166]  d38fbec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbed4
[   81.179326]  c1056a11 00000009 00000000 d38fbf2c c1150db8 d14dad00 fffff=
fff ffffffff
[   81.180395] Call Trace:
[   81.180738]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.202349]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.202940]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.203529]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.204214]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.204814]  [<c10537ff>] mmput+0x52/0xef
[   81.205312]  [<c105955b>] do_exit+0x5bc/0xee9
[   81.205889]  [<c143becb>] ? restore_all+0xf/0xf
[   81.206430]  [<c1059fe4>] do_group_exit+0x113/0x113
[   81.222084]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   81.222651]  [<c143be92>] syscall_call+0x7/0x7
[   81.223192] ---[ end trace 6a7094e9a1d04d24 ]---
[   81.254184] ------------[ cut here ]------------
[   81.254718] WARNING: CPU: 1 PID: 721 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.262547] Modules linked in:
[   81.262926] CPU: 1 PID: 721 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   81.263944]  00000001 00000000 00000046 d381be08 c14341a1 00000000 00000=
001 c16ebf08
[   81.271863]  d381be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381be34
[   81.274277]  c1056a11 00000009 00000000 d381be8c c1150db8 d38b6d00 fffff=
fff ffffffff
[   81.279321] Call Trace:
[   81.279605]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.282147]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.282727]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.283248]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.286408]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.290352]  [<c10537ff>] mmput+0x52/0xef
[   81.290798]  [<c1175602>] flush_old_exec+0x923/0x99d
[   81.291400]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   81.296638]  [<c108559f>] ? local_clock+0x2f/0x39
[   81.299543]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   81.301970]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   81.304029]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   81.304619]  [<c11762eb>] do_execve+0x19/0x1b
[   81.308629]  [<c1176586>] SyS_execve+0x21/0x25
[   81.309207]  [<c143be92>] syscall_call+0x7/0x7
[   81.309738] ---[ end trace 6a7094e9a1d04d25 ]---
[   81.337353] ------------[ cut here ]------------
[   81.337885] WARNING: CPU: 0 PID: 721 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.346599] Modules linked in:
[   81.348822] CPU: 0 PID: 721 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   81.349790]  00000001 00000000 00000047 d381bea8 c14341a1 00000000 00000=
000 c16ebf08
[   81.355971]  d381bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bed4
[   81.360198]  c1056a11 00000009 00000000 d381bf2c c1150db8 d38a2380 fffff=
fff ffffffff
[   81.361264] Call Trace:
[   81.361559]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.366051]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.366638]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.370598]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.371197]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.378495]  [<c10537ff>] mmput+0x52/0xef
[   81.379719]  [<c105955b>] do_exit+0x5bc/0xee9
[   81.380349]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   81.380869]  [<c143becb>] ? restore_all+0xf/0xf
[   81.381372]  [<c1059fe4>] do_group_exit+0x113/0x113
[   81.386315]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   81.390248]  [<c143be92>] syscall_call+0x7/0x7
[   81.390738] ---[ end trace 6a7094e9a1d04d26 ]---
[   81.414298] ------------[ cut here ]------------
[   81.414835] WARNING: CPU: 1 PID: 722 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.423166] Modules linked in:
[   81.423604] CPU: 1 PID: 722 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   81.424671]  00000001 00000000 00000048 d38fbe08 c14341a1 00000000 00000=
001 c16ebf08
[   81.427589]  d38fbe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbe34
[   81.432370]  c1056a11 00000009 00000000 d38fbe8c c1150db8 d38a7d80 fffff=
fff ffffffff
[   81.436790] Call Trace:
[   81.437097]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.437622]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.438267]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.443648]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.444221]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.444721]  [<c10537ff>] mmput+0x52/0xef
[   81.449495]  [<c1175602>] flush_old_exec+0x923/0x99d
[   81.452188]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   81.452859]  [<c108559f>] ? local_clock+0x2f/0x39
[   81.456893]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   81.457582]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   81.458191]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   81.463630]  [<c11762eb>] do_execve+0x19/0x1b
[   81.464142]  [<c1176586>] SyS_execve+0x21/0x25
[   81.464660]  [<c143be92>] syscall_call+0x7/0x7
[   81.469313] ---[ end trace 6a7094e9a1d04d27 ]---
[   81.493517] ------------[ cut here ]------------
[   81.494070] WARNING: CPU: 0 PID: 722 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.500150] Modules linked in:
[   81.500525] CPU: 0 PID: 722 Comm: expr Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   81.501404]  00000001 00000000 00000049 d38fbea8 c14341a1 00000000 00000=
000 c16ebf08
[   81.507589]  d38fbec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbed4
[   81.513519]  c1056a11 00000009 00000000 d38fbf2c c1150db8 d38b2500 fffff=
fff ffffffff
[   81.514508] Call Trace:
[   81.514789]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.520083]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.520665]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.521190]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.525214]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.527138]  [<c10537ff>] mmput+0x52/0xef
[   81.527583]  [<c105955b>] do_exit+0x5bc/0xee9
[   81.528083]  [<c143becb>] ? restore_all+0xf/0xf
[   81.532111]  [<c1059fe4>] do_group_exit+0x113/0x113
[   81.532726]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   81.536746]  [<c143be92>] syscall_call+0x7/0x7
[   81.537243] ---[ end trace 6a7094e9a1d04d28 ]---
[   81.566245] ------------[ cut here ]------------
[   81.566792] WARNING: CPU: 1 PID: 723 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.567744] Modules linked in:
[   81.568107] CPU: 1 PID: 723 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   81.573183]  00000001 00000000 0000004a d381be08 c14341a1 00000000 00000=
001 c16ebf08
[   81.575995]  d381be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381be34
[   81.580407]  c1056a11 00000009 00000000 d381be8c c1150db8 d38d3000 fffff=
fff ffffffff
[   81.581382] Call Trace:
[   81.585130]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.586436]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.589135]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.589732]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.592917]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.596822]  [<c10537ff>] mmput+0x52/0xef
[   81.597276]  [<c1175602>] flush_old_exec+0x923/0x99d
[   81.597824]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   81.601853]  [<c108559f>] ? local_clock+0x2f/0x39
[   81.603791]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   81.604493]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   81.608533]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   81.610619]  [<c11762eb>] do_execve+0x19/0x1b
[   81.611161]  [<c1176586>] SyS_execve+0x21/0x25
[   81.615146]  [<c143be92>] syscall_call+0x7/0x7
[   81.617079] ---[ end trace 6a7094e9a1d04d29 ]---
[   81.651865] ------------[ cut here ]------------
[   81.652436] WARNING: CPU: 0 PID: 723 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.656042] Modules linked in:
[   81.656405] CPU: 0 PID: 723 Comm: plymouth Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   81.659354]  00000001 00000000 0000004b d381bdb8 c14341a1 00000000 00000=
000 c16ebf08
[   81.665481]  d381bdd4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bde4
[   81.666601]  c1056a11 00000009 00000000 d381be3c c1150db8 d14dad00 fffff=
fff ffffffff
[   81.672971] Call Trace:
[   81.673254]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.680185]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.680796]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.681321]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.689791]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.690427]  [<c10537ff>] mmput+0x52/0xef
[   81.690898]  [<c105955b>] do_exit+0x5bc/0xee9
[   81.691389]  [<c1059fe4>] do_group_exit+0x113/0x113
[   81.697076]  [<c10653f7>] get_signal+0x89d/0x966
[   81.697643]  [<c10027f7>] do_signal+0x1e/0x12c
[   81.698197]  [<c1063c88>] ? do_tkill+0x81/0x89
[   81.706852]  [<c1002950>] do_notify_resume+0x4b/0xcb
[   81.707440]  [<c143bfa0>] work_notifysig+0x2b/0x3b
[   81.707979] ---[ end trace 6a7094e9a1d04d2a ]---
/etc/lsb-base-logging.sh: line 5:   723 Aborted                 plymouth --=
ping > /dev/null 2>&1
 * Asking all remaining processes to terminate...      =20
[   81.756294] ------------[ cut here ]------------
[   81.756929] WARNING: CPU: 1 PID: 724 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.757994] Modules linked in:
[   81.761944] CPU: 1 PID: 724 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   81.765230]  00000001 00000000 0000004c c0025e08 c14341a1 00000000 00000=
001 c16ebf08
[   81.767652]  c0025e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0025e34
[   81.776275]  c1056a11 00000009 00000000 c0025e8c c1150db8 d38b6d00 fffff=
fff ffffffff
[   81.778668] Call Trace:
[   81.778964]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.779455]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.780075]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.780594]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.781162]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.781669]  [<c10537ff>] mmput+0x52/0xef
[   81.782219]  [<c1175602>] flush_old_exec+0x923/0x99d
[   81.782901]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   81.783587]  [<c108559f>] ? local_clock+0x2f/0x39
[   81.784109]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   81.784812]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   81.806499]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   81.807191]  [<c11762eb>] do_execve+0x19/0x1b
[   81.807776]  [<c1176586>] SyS_execve+0x21/0x25
[   81.808394]  [<c143be92>] syscall_call+0x7/0x7
[   81.808966] ---[ end trace 6a7094e9a1d04d2b ]---
[   81.811126] ------------[ cut here ]------------
[   81.811671] WARNING: CPU: 0 PID: 724 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.812631] Modules linked in:
[   81.813008] CPU: 0 PID: 724 Comm: expr Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   81.813916]  00000001 00000000 0000004d c0025ea8 c14341a1 00000000 00000=
000 c16ebf08
[   81.815120]  c0025ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0025ed4
[   81.816822]  c1056a11 00000009 00000000 c0025f2c c1150db8 d38a2380 fffff=
fff ffffffff
[   81.817792] Call Trace:
[   81.818079]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.818717]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.819327]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.819851]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.820437]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.820940]  [<c10537ff>] mmput+0x52/0xef
[   81.821386]  [<c105955b>] do_exit+0x5bc/0xee9
[   81.821940]  [<c143becb>] ? restore_all+0xf/0xf
[   81.823101]  [<c1059fe4>] do_group_exit+0x113/0x113
[   81.823678]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   81.824211]  [<c143be92>] syscall_call+0x7/0x7
[   81.824709] ---[ end trace 6a7094e9a1d04d2c ]---
[   81.838102] ------------[ cut here ]------------
[   81.838691] WARNING: CPU: 1 PID: 725 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.839688] Modules linked in:
[   81.840078] CPU: 1 PID: 725 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   81.841008]  00000001 00000000 0000004e d381be08 c14341a1 00000000 00000=
001 c16ebf08
[   81.842049]  d381be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381be34
[   81.849251]  c1056a11 00000009 00000000 d381be8c c1150db8 d38a7d80 fffff=
fff ffffffff
[   81.850299] Call Trace:
[   81.850580]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.851076]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.851663]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.852229]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.852801]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.853361]  [<c10537ff>] mmput+0x52/0xef
[   81.853920]  [<c1175602>] flush_old_exec+0x923/0x99d
[   81.854573]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   81.855226]  [<c108559f>] ? local_clock+0x2f/0x39
[   81.855857]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   81.878634]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   81.879378]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   81.880114]  [<c11762eb>] do_execve+0x19/0x1b
[   81.880593]  [<c1176586>] SyS_execve+0x21/0x25
[   81.881087]  [<c143be92>] syscall_call+0x7/0x7
[   81.881577] ---[ end trace 6a7094e9a1d04d2d ]---
[   81.910736] WARNING: CPU: 0 PID: 725 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   81.921053] Modules linked in:
[   81.921417] CPU: 0 PID: 725 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   81.922995]  00000001 00000000 0000004f d381bea8 c14341a1 00000000 00000=
000 c16ebf08
[   81.924019]  d381bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bed4
[   81.935144]  c1056a11 00000009 00000000 d381bf2c c1150db8 d38b2500 fffff=
fff ffffffff
[   81.936841] Call Trace:
[   81.937165]  [<c14341a1>] dump_stack+0x78/0xa8
[   81.937713]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   81.948539]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   81.949828]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   81.950467]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   81.950999]  [<c10537ff>] mmput+0x52/0xef
[   81.951458]  [<c105955b>] do_exit+0x5bc/0xee9
[   81.961914]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   81.963111]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   81.963696]  [<c143becb>] ? restore_all+0xf/0xf
[   81.964227]  [<c1059fe4>] do_group_exit+0x113/0x113
[   81.964816]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   81.973891]  [<c143be92>] syscall_call+0x7/0x7
[   81.974500] ---[ end trace 6a7094e9a1d04d2e ]---
=20
[   82.046199] ------------[ cut here ]------------
[   82.068558] WARNING: CPU: 0 PID: 726 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.069702] Modules linked in:
[   82.076845] CPU: 0 PID: 726 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   82.077827]  00000001 00000000 00000050 d38fbe08 c14341a1 00000000 00000=
000 c16ebf08
[   82.078870]  d38fbe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbe34
[   82.079888]  c1056a11 00000009 00000000 d38fbe8c c1150db8 d38d3000 fffff=
fff ffffffff
[   82.085442] Call Trace:
[   82.085737]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.086251]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.093592]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.094140]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.094702]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.095254]  [<c10537ff>] mmput+0x52/0xef
[   82.095724]  [<c1175602>] flush_old_exec+0x923/0x99d
[   82.096317]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   82.101829]  [<c108559f>] ? local_clock+0x2f/0x39
[   82.102374]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   82.103062]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   82.110405]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   82.111021]  [<c11762eb>] do_execve+0x19/0x1b
[   82.111506]  [<c1176586>] SyS_execve+0x21/0x25
[   82.112043]  [<c143be92>] syscall_call+0x7/0x7
[   82.112555] ---[ end trace 6a7094e9a1d04d2f ]---
[   82.168742] ------------[ cut here ]------------
[   82.169284] WARNING: CPU: 0 PID: 727 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.170258] Modules linked in:
[   82.170619] CPU: 0 PID: 727 Comm: killall5 Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   82.171526]  00000001 00000000 00000051 d382be08 c14341a1 00000000 00000=
000 c16ebf08
[   82.172524]  d382be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382be34
[   82.173521]  c1056a11 00000009 00000000 d382be8c c1150db8 d38b6000 fffff=
fff ffffffff
[   82.192755] Call Trace:
[   82.193081]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.200332]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.200945]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.201485]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.202110]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.202630]  [<c10537ff>] mmput+0x52/0xef
[   82.203100]  [<c1175602>] flush_old_exec+0x923/0x99d
[   82.213734]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   82.214311]  [<c108559f>] ? local_clock+0x2f/0x39
[   82.214830]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   82.215579]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   82.216215]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   82.226886]  [<c11762eb>] do_execve+0x19/0x1b
[   82.227380]  [<c1176586>] SyS_execve+0x21/0x25
[   82.227882]  [<c143be92>] syscall_call+0x7/0x7
[   82.228421] ---[ end trace 6a7094e9a1d04d30 ]---
[   82.261587] ------------[ cut here ]------------
mount: proc has wrong device number or fs type proc not supported
[   82.277886] WARNING: CPU: 0 PID: 727 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.278972] Modules linked in:
[   82.279385] CPU: 0 PID: 727 Comm: mount Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   82.280395]  00000001 00000000 00000052 d382bea8 c14341a1 00000000 00000=
000 c16ebf08
[   82.290498]  d382bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bed4
[   82.291497]  c1056a11 00000009 00000000 d382bf2c c1150db8 d38b6d00 fffff=
fff ffffffff
[   82.292521] Call Trace:
[   82.292804]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.293302]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.304094]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.304710]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.305424]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.306103]  [<c10537ff>] mmput+0x52/0xef
[   82.316733]  [<c105955b>] do_exit+0x5bc/0xee9
[   82.317257]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   82.317812]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   82.318348]  [<c143becb>] ? restore_all+0xf/0xf
[   82.318984]  [<c1059fe4>] do_group_exit+0x113/0x113
[   82.319679]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   82.330350]  [<c143be92>] syscall_call+0x7/0x7
[   82.330840] ---[ end trace 6a7094e9a1d04d31 ]---
[   82.374762] ------------[ cut here ]------------
[   82.382242] WARNING: CPU: 1 PID: 726 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.383192] Modules linked in:
[   82.383623] CPU: 1 PID: 726 Comm: killall5 Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   82.384668]  00000001 00000000 00000053 d38fbea8 c14341a1 00000000 00000=
001 c16ebf08
[   82.399215]  d38fbec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbed4
[   82.400214]  c1056a11 00000009 00000000 d38fbf2c c1150db8 d38d3600 fffff=
fff ffffffff
[   82.401178] Call Trace:
[   82.401461]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.417105]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.417717]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.418242]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.423962]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.424526]  [<c10537ff>] mmput+0x52/0xef
[   82.431816]  [<c105955b>] do_exit+0x5bc/0xee9
[   82.432317]  [<c143becb>] ? restore_all+0xf/0xf
[   82.432822]  [<c1059fe4>] do_group_exit+0x113/0x113
[   82.433393]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   82.433995]  [<c143be92>] syscall_call+0x7/0x7
[   82.434544] ---[ end trace 6a7094e9a1d04d32 ]---
[   82.451310] ------------[ cut here ]------------
[   82.451948] WARNING: CPU: 0 PID: 730 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.452886] Modules linked in:
[   82.453251] CPU: 0 PID: 730 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   82.454219]  00000001 00000000 00000054 d381be08 c14341a1 00000000 00000=
000 c16ebf08
[   82.455260]  d381be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381be34
[   82.456230]  c1056a11 00000009 00000000 d381be8c c1150db8 d38d3600 fffff=
fff ffffffff
[   82.457249] Call Trace:
[   82.457543]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.458059]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.458722]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.459426]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.460166]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.460752]  [<c10537ff>] mmput+0x52/0xef
[   82.466361]  [<c1175602>] flush_old_exec+0x923/0x99d
[   82.467068]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   82.467736]  [<c108559f>] ? local_clock+0x2f/0x39
[   82.468384]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   82.469121]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   82.469723]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   82.470353]  [<c11762eb>] do_execve+0x19/0x1b
[   82.470856]  [<c1176586>] SyS_execve+0x21/0x25
[   82.488472]  [<c143be92>] syscall_call+0x7/0x7
[   82.489127] ---[ end trace 6a7094e9a1d04d33 ]---
[   82.492520] ------------[ cut here ]------------
[   82.493207] WARNING: CPU: 1 PID: 730 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.494407] Modules linked in:
[   82.494772] CPU: 1 PID: 730 Comm: plymouth Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   82.495717]  00000001 00000000 00000055 d381bdb8 c14341a1 00000000 00000=
001 c16ebf08
[   82.496712]  d381bdd4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bde4
[   82.497704]  c1056a11 00000009 00000000 d381be3c c1150db8 d14dad00 fffff=
fff ffffffff
[   82.498899] Call Trace:
[   82.501323]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.501862]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.502492]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.503016]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.503598]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.504104]  [<c10537ff>] mmput+0x52/0xef
[   82.504624]  [<c105955b>] do_exit+0x5bc/0xee9
[   82.505247]  [<c1059fe4>] do_group_exit+0x113/0x113
[   82.505887]  [<c10653f7>] get_signal+0x89d/0x966
[   82.552663]  [<c10027f7>] do_signal+0x1e/0x12c
[   82.555670]  [<c1063c88>] ? do_tkill+0x81/0x89
[   82.556280]  [<c1002950>] do_notify_resume+0x4b/0xcb
[   82.556948]  [<c143bfa0>] work_notifysig+0x2b/0x3b
[   82.557569] ---[ end trace 6a7094e9a1d04d34 ]---
/etc/lsb-base-logging.sh: line 5:   730 Aborted                 plymouth --=
ping > /dev/null 2>&1
[   82.571760] WARNING: CPU: 0 PID: 731 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.572876] Modules linked in:
[   82.573304] CPU: 0 PID: 731 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   82.574431]  00000001 00000000 00000056 c0025e08 c14341a1 00000000 00000=
000 c16ebf08
[   82.575604]  c0025e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0025e34
[   82.576763]  c1056a11 00000009 00000000 c0025e8c c1150db8 d38b6000 fffff=
fff ffffffff
[   82.577753] Call Trace:
[   82.578053]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.578587]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.579298]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.579899]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.580555]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.581099]  [<c10537ff>] mmput+0x52/0xef
[   82.581582]  [<c1175602>] flush_old_exec+0x923/0x99d
[   82.592280]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   82.592968]  [<c108559f>] ? local_clock+0x2f/0x39
[   82.593607]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   82.594448]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   82.595183]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   82.595898]  [<c11762eb>] do_execve+0x19/0x1b
[   82.596510]  [<c1176586>] SyS_execve+0x21/0x25
[   82.617104]  [<c143be92>] syscall_call+0x7/0x7
[   82.617671] ---[ end trace 6a7094e9a1d04d35 ]---
[   82.621413] WARNING: CPU: 0 PID: 731 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.638743] Modules linked in:
[   82.639140] CPU: 0 PID: 731 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   82.640059]  00000001 00000000 00000057 c0025ea8 c14341a1 00000000 00000=
000 c16ebf08
[   82.641028]  c0025ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0025ed4
[   82.650184]  c1056a11 00000009 00000000 c0025f2c c1150db8 d38b6d00 fffff=
fff ffffffff
[   82.651269] Call Trace:
[   82.651552]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.656801]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.657401]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.657917]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.663181]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.663722]  [<c10537ff>] mmput+0x52/0xef
[   82.664207]  [<c105955b>] do_exit+0x5bc/0xee9
[   82.664732]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   82.673036]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   82.673565]  [<c143becb>] ? restore_all+0xf/0xf
[   82.674070]  [<c1059fe4>] do_group_exit+0x113/0x113
[   82.674601]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   82.681962]  [<c143be92>] syscall_call+0x7/0x7
[   82.683451] ---[ end trace 6a7094e9a1d04d36 ]---
[ OK ]
[   82.710028] ------------[ cut here ]------------
[   82.710572] WARNING: CPU: 1 PID: 733 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.713803] ------------[ cut here ]------------
[   82.713809] WARNING: CPU: 0 PID: 735 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.713811] Modules linked in:
[   82.713815] CPU: 0 PID: 735 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   82.713822]  00000001 00000000 00000058 d382be08 c14341a1 00000000 00000=
000 c16ebf08
[   82.713829]  d382be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382be34
[   82.713835]  c1056a11 00000009 00000000 d382be8c c1150db8 d3873380 fffff=
fff ffffffff
[   82.713836] Call Trace:
[   82.713842]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.713847]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.713850]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.713856]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.713859]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.713864]  [<c10537ff>] mmput+0x52/0xef
[   82.713868]  [<c1175602>] flush_old_exec+0x923/0x99d
[   82.713873]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   82.713877]  [<c108559f>] ? local_clock+0x2f/0x39
[   82.713882]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   82.713886]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   82.713889]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   82.713893]  [<c11762eb>] do_execve+0x19/0x1b
[   82.713896]  [<c1176586>] SyS_execve+0x21/0x25
[   82.713900]  [<c143be92>] syscall_call+0x7/0x7
[   82.713902] ---[ end trace 6a7094e9a1d04d37 ]---
[   82.733229] ------------[ cut here ]------------
[   82.733239] WARNING: CPU: 0 PID: 734 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.733241] Modules linked in:
[   82.733245] CPU: 0 PID: 734 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   82.733253]  00000001 00000000 00000059 d38fbe08 c14341a1 00000000 00000=
000 c16ebf08
[   82.733260]  d38fbe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbe34
[   82.733267]  c1056a11 00000009 00000000 d38fbe8c c1150db8 d14dad00 fffff=
fff ffffffff
[   82.733268] Call Trace:
[   82.733275]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.733280]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.733283]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.733287]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.733290]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.733295]  [<c10537ff>] mmput+0x52/0xef
[   82.733299]  [<c1175602>] flush_old_exec+0x923/0x99d
[   82.733305]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   82.733309]  [<c108559f>] ? local_clock+0x2f/0x39
[   82.733314]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   82.733319]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   82.733323]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   82.733327]  [<c11762eb>] do_execve+0x19/0x1b
[   82.733334]  [<c1176586>] SyS_execve+0x21/0x25
[   82.733374]  [<c143be92>] syscall_call+0x7/0x7
[   82.733377] ---[ end trace 6a7094e9a1d04d38 ]---
[   82.835451] Modules linked in:
[   82.835815] CPU: 1 PID: 733 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   82.836759]  00000001 00000000 0000005a d3875e08 c14341a1 00000000 00000=
001 c16ebf08
[   82.845236]  d3875e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3875e34
[   82.846297]  c1056a11 00000009 00000000 d3875e8c c1150db8 d38ec800 fffff=
fff ffffffff
[   82.847317] Call Trace:
[   82.847599]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.854978]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.855922]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.856538]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.862014]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.864956]  [<c10537ff>] mmput+0x52/0xef
[   82.867889]  [<c1175602>] flush_old_exec+0x923/0x99d
[   82.868657]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   82.869482]  [<c108559f>] ? local_clock+0x2f/0x39
[   82.870136]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   82.870928]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   82.878390]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   82.879211]  [<c11762eb>] do_execve+0x19/0x1b
[   82.879696]  [<c1176586>] SyS_execve+0x21/0x25
[   82.880224]  [<c143be92>] syscall_call+0x7/0x7
[   82.880733] ---[ end trace 6a7094e9a1d04d39 ]---
[   82.951050] ------------[ cut here ]------------
[   82.951593] WARNING: CPU: 0 PID: 733 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   82.961894] Modules linked in:
[   82.963363] CPU: 0 PID: 733 Comm: initctl Tainted: G        W      3.19.=
0-rc5-gf7a7b53 #19
[   82.964276]  00000001 00000000 0000005b d3875ea8 c14341a1 00000000 00000=
000 c16ebf08
[   82.969807]  d3875ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3875ed4
[   82.970959]  c1056a11 00000009 00000000 d3875f2c c1150db8 d3873600 fffff=
fff ffffffff
[   82.977858] Call Trace:
[   82.978146]  [<c14341a1>] dump_stack+0x78/0xa8
[   82.983824]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   82.984419]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   82.984941]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   82.990051]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   82.990551]  [<c10537ff>] mmput+0x52/0xef
[   82.991020]  [<c105955b>] do_exit+0x5bc/0xee9
[   82.991523]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   82.994531]  [<c143becb>] ? restore_all+0xf/0xf
[   82.998846]  [<c1059fe4>] do_group_exit+0x113/0x113
[   82.999450]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   83.000065]  [<c143be92>] syscall_call+0x7/0x7
[   83.000611] ---[ end trace 6a7094e9a1d04d3a ]---
[   83.008271] ------------[ cut here ]------------
[   83.010718] ------------[ cut here ]------------
[   83.010725] WARNING: CPU: 1 PID: 735 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.010727] Modules linked in:
[   83.010731] CPU: 1 PID: 735 Comm: sed Tainted: G        W      3.19.0-rc=
5-gf7a7b53 #19
[   83.010739]  00000001 00000000 0000005c d382bea8 c14341a1 00000000 00000=
001 c16ebf08
[   83.010745]  d382bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bed4
[   83.010751]  c1056a11 00000009 00000000 d382bf2c c1150db8 d3873c80 fffff=
fff ffffffff
[   83.010753] Call Trace:
[   83.010759]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.010763]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.010766]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.010770]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.010773]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.010777]  [<c10537ff>] mmput+0x52/0xef
[   83.010780]  [<c105955b>] do_exit+0x5bc/0xee9
[   83.010785]  [<c143becb>] ? restore_all+0xf/0xf
[   83.010788]  [<c1059fe4>] do_group_exit+0x113/0x113
[   83.010792]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   83.010795]  [<c143be92>] syscall_call+0x7/0x7
[   83.010797] ---[ end trace 6a7094e9a1d04d3b ]---
[   83.060380] WARNING: CPU: 0 PID: 734 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.061369] Modules linked in:
[   83.071955] CPU: 0 PID: 734 Comm: grep Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   83.072869]  00000001 00000000 0000005d d38fbea8 c14341a1 00000000 00000=
000 c16ebf08
[   83.073976]  d38fbec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbed4
[   83.083385]  c1056a11 00000009 00000000 d38fbf2c c1150db8 d3858380 fffff=
fff ffffffff
[   83.084360] Call Trace:
[   83.084644]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.089992]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.090606]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.091133]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.098486]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.099070]  [<c10537ff>] mmput+0x52/0xef
[   83.099528]  [<c105955b>] do_exit+0x5bc/0xee9
[   83.100060]  [<c143becb>] ? restore_all+0xf/0xf
[   83.100574]  [<c1059fe4>] do_group_exit+0x113/0x113
[   83.101115]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   83.108550]  [<c143be92>] syscall_call+0x7/0x7
[   83.110313] ---[ end trace 6a7094e9a1d04d3c ]---
[   83.112375] ------------[ cut here ]------------
[   83.112901] WARNING: CPU: 1 PID: 732 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.113904] Modules linked in:
[   83.114287] CPU: 1 PID: 732 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   83.117380]  00000001 00000000 0000005e d381bea8 c14341a1 00000000 00000=
001 c16ebf08
[   83.118799]  d381bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bed4
[   83.119972]  c1056a11 00000009 00000000 d381bf2c c1150db8 d38a7d80 fffff=
fff ffffffff
[   83.121269] Call Trace:
[   83.121609]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.122392]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.123076]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.123728]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.124529]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.125215]  [<c10537ff>] mmput+0x52/0xef
[   83.125941]  [<c105955b>] do_exit+0x5bc/0xee9
[   83.126453]  [<c10034fa>] ? do_device_not_available+0xa6/0xac
[   83.127112]  [<c143becb>] ? restore_all+0xf/0xf
[   83.127625]  [<c1059fe4>] do_group_exit+0x113/0x113
[   83.135978]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   83.136538]  [<c143be92>] syscall_call+0x7/0x7
[   83.137051] ---[ end trace 6a7094e9a1d04d3d ]---
[   83.163206] ------------[ cut here ]------------
[   83.163782] WARNING: CPU: 0 PID: 736 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.164773] Modules linked in:
[   83.175263] CPU: 0 PID: 736 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   83.176294]  00000001 00000000 0000005f d38fbe08 c14341a1 00000000 00000=
000 c16ebf08
[   83.182369]  d38fbe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbe34
[   83.186436]  c1056a11 00000009 00000000 d38fbe8c c1150db8 d38a2900 fffff=
fff ffffffff
[   83.189185] Call Trace:
[   83.189465]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.189972]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.196736]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.197271]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.197835]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.202086]  [<c10537ff>] mmput+0x52/0xef
[   83.202528]  [<c1175602>] flush_old_exec+0x923/0x99d
[   83.203076]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   83.206630]  [<c108559f>] ? local_clock+0x2f/0x39
[   83.210305]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   83.211104]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   83.218524]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   83.220356]  [<c11762eb>] do_execve+0x19/0x1b
[   83.220837]  [<c1176586>] SyS_execve+0x21/0x25
[   83.221355]  [<c143be92>] syscall_call+0x7/0x7
[   83.235270] ---[ end trace 6a7094e9a1d04d3e ]---
[   83.240659] ------------[ cut here ]------------
[   83.241670] WARNING: CPU: 0 PID: 737 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.242779] Modules linked in:
[   83.243210] CPU: 0 PID: 737 Comm: killall5 Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   83.244333]  00000001 00000000 00000060 d381fe08 c14341a1 00000000 00000=
000 c16ebf08
[   83.245382]  d381fe24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381fe34
[   83.246413]  c1056a11 00000009 00000000 d381fe8c c1150db8 d38d3000 fffff=
fff ffffffff
[   83.268578] Call Trace:
[   83.268941]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.269553]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.270274]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.270907]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.271596]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.272213]  [<c10537ff>] mmput+0x52/0xef
[   83.272755]  [<c1175602>] flush_old_exec+0x923/0x99d
[   83.273444]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   83.274101]  [<c108559f>] ? local_clock+0x2f/0x39
[   83.274683]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   83.295484]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   83.296091]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   83.296707]  [<c11762eb>] do_execve+0x19/0x1b
[   83.297216]  [<c1176586>] SyS_execve+0x21/0x25
[   83.297738]  [<c143be92>] syscall_call+0x7/0x7
[   83.298359] ---[ end trace 6a7094e9a1d04d3f ]---
mount: proc has wrong device number or fs type proc not supported
[   83.316276] ------------[ cut here ]------------
[   83.316817] WARNING: CPU: 1 PID: 737 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.317788] Modules linked in:
[   83.318206] CPU: 1 PID: 737 Comm: mount Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   83.319732]  00000001 00000000 00000061 d381fea8 c14341a1 00000000 00000=
001 c16ebf08
[   83.321045]  d381fec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381fed4
[   83.322317]  c1056a11 00000009 00000000 d381ff2c c1150db8 d14dad00 fffff=
fff ffffffff
[   83.323478] Call Trace:
[   83.323799]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.324351]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.338459]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.339308]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.342121]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.342624]  [<c10537ff>] mmput+0x52/0xef
[   83.343095]  [<c105955b>] do_exit+0x5bc/0xee9
[   83.343624]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   83.344190]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   83.344710]  [<c143becb>] ? restore_all+0xf/0xf
[   83.356227]  [<c1059fe4>] do_group_exit+0x113/0x113
[   83.356786]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   83.357343]  [<c143be92>] syscall_call+0x7/0x7
[   83.357851] ---[ end trace 6a7094e9a1d04d40 ]---
[   83.367986] ------------[ cut here ]------------
[   83.369383] WARNING: CPU: 0 PID: 736 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.370481] Modules linked in:
[   83.370918] CPU: 0 PID: 736 Comm: killall5 Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   83.371997]  00000001 00000000 00000062 d38fbea8 c14341a1 00000000 00000=
000 c16ebf08
[   83.372992]  d38fbec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38fbed4
[   83.373983]  c1056a11 00000009 00000000 d38fbf2c c1150db8 d38a7d80 fffff=
fff ffffffff
[   83.374994] Call Trace:
[   83.375334]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.375947]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.376619]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.377270]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.377956]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.378466]  [<c10537ff>] mmput+0x52/0xef
[   83.386100]  [<c105955b>] do_exit+0x5bc/0xee9
[   83.386661]  [<c143becb>] ? restore_all+0xf/0xf
[   83.387306]  [<c1059fe4>] do_group_exit+0x113/0x113
[   83.387990]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   83.388603]  [<c143be92>] syscall_call+0x7/0x7
[   83.389206] ---[ end trace 6a7094e9a1d04d41 ]---
[   83.408439] ------------[ cut here ]------------
[   83.409088] WARNING: CPU: 0 PID: 742 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.410331] Modules linked in:
[   83.410792] CPU: 0 PID: 742 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   83.411912]  00000001 00000000 00000063 d3875e08 c14341a1 00000000 00000=
000 c16ebf08
[   83.427112] ------------[ cut here ]------------
[   83.427120] WARNING: CPU: 1 PID: 741 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.427121] Modules linked in:

[   83.439560]=20
[   83.439775]  d3875e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3875e34
[   83.440808]  c1056a11 00000009 00000000 d3875e8c c1150db8 d38a7d80 fffff=
fff ffffffff
[   83.441921] Call Trace:
[   83.456341]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.457000]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.457729]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.458301]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.458964]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.459463]  [<c10537ff>] mmput+0x52/0xef
[   83.459904]  [<c1175602>] flush_old_exec+0x923/0x99d
[   83.478183]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   83.478896]  [<c108559f>] ? local_clock+0x2f/0x39
[   83.479443]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   83.480148]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   83.480742]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   83.481405]  [<c11762eb>] do_execve+0x19/0x1b
[   83.481976]  [<c1176586>] SyS_execve+0x21/0x25
[   83.482486]  [<c143be92>] syscall_call+0x7/0x7
[   83.482979] ---[ end trace 6a7094e9a1d04d42 ]---
[   83.483984] CPU: 1 PID: 741 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   83.485097]  00000001 00000000 00000064 d382be08 c14341a1 00000000 00000=
001 c16ebf08
[   83.486317]  d382be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382be34
[   83.487513]  c1056a11 00000009 00000000 d382be8c c1150db8 d38b6000 fffff=
fff ffffffff
[   83.488660] Call Trace:
[   83.489003]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.489517]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.490131]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.490653]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.508416]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.508998]  [<c10537ff>] mmput+0x52/0xef
[   83.509462]  [<c1175602>] flush_old_exec+0x923/0x99d
[   83.513434]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   83.514016]  [<c108559f>] ? local_clock+0x2f/0x39
[   83.514593]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   83.515406]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   83.516116]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   83.523586]  [<c11762eb>] do_execve+0x19/0x1b
[   83.524143]  [<c1176586>] SyS_execve+0x21/0x25
[   83.524704]  [<c143be92>] syscall_call+0x7/0x7
[   83.525226] ---[ end trace 6a7094e9a1d04d43 ]---
[   83.623050] ------------[ cut here ]------------
[   83.630426] WARNING: CPU: 0 PID: 741 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.631508] Modules linked in:
[   83.631922] CPU: 0 PID: 741 Comm: initctl Tainted: G        W      3.19.=
0-rc5-gf7a7b53 #19
[   83.632870]  00000001 00000000 00000065 d382bea8 c14341a1 00000000 00000=
000 c16ebf08
[   83.639622]  d382bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bed4
[   83.647402]  c1056a11 00000009 00000000 d382bf2c c1150db8 d3858380 fffff=
fff ffffffff
[   83.648568] Call Trace:
[   83.648910]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.649488]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.656889]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.657441]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.658058]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.658597]  [<c10537ff>] mmput+0x52/0xef
[   83.659140]  [<c105955b>] do_exit+0x5bc/0xee9
[   83.659728]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   83.667038]  [<c143becb>] ? restore_all+0xf/0xf
[   83.667538]  [<c1059fe4>] do_group_exit+0x113/0x113
[   83.668176]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   83.668853]  [<c143be92>] syscall_call+0x7/0x7
[   83.669373] ---[ end trace 6a7094e9a1d04d44 ]---
[   83.675500] ------------[ cut here ]------------
[   83.676149] WARNING: CPU: 0 PID: 742 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.684050] Modules linked in:
[   83.684476] CPU: 0 PID: 742 Comm: grep Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   83.685424]  00000001 00000000 00000066 d3875ea8 c14341a1 00000000 00000=
000 c16ebf08
[   83.686544]  d3875ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3875ed4
[   83.694456]  c1056a11 00000009 00000000 d3875f2c c1150db8 d38acd00 fffff=
fff ffffffff
[   83.695536] Call Trace:
[   83.695875]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.696418]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.707167]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.707761]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.708329]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.708907]  [<c10537ff>] mmput+0x52/0xef
[   83.709375]  [<c105955b>] do_exit+0x5bc/0xee9
[   83.709867]  [<c143becb>] ? restore_all+0xf/0xf
[   83.717237]  [<c1059fe4>] do_group_exit+0x113/0x113
[   83.717897]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   83.718477]  [<c143be92>] syscall_call+0x7/0x7
[   83.719038] ---[ end trace 6a7094e9a1d04d45 ]---
[   83.742180] ------------[ cut here ]------------
[   83.742795] WARNING: CPU: 1 PID: 740 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.743928] Modules linked in:
[   83.744381] CPU: 1 PID: 740 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   83.753541]  00000001 00000000 00000067 d381bea8 c14341a1 00000000 00000=
001 c16ebf08
[   83.754725]  d381bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bed4
[   83.755806]  c1056a11 00000009 00000000 d381bf2c c1150db8 d38d3000 fffff=
fff ffffffff
[   83.763601] Call Trace:
[   83.763949]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.764531]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.770355]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.770892]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.771576]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.772153]  [<c10537ff>] mmput+0x52/0xef
[   83.772677]  [<c105955b>] do_exit+0x5bc/0xee9
[   83.773164]  [<c10034fa>] ? do_device_not_available+0xa6/0xac
[   83.784017]  [<c143becb>] ? restore_all+0xf/0xf
[   83.784582]  [<c1059fe4>] do_group_exit+0x113/0x113
[   83.785133]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   83.785739]  [<c143be92>] syscall_call+0x7/0x7
[   83.786236] ---[ end trace 6a7094e9a1d04d46 ]---
[   83.819026] ------------[ cut here ]------------
[   83.819667] WARNING: CPU: 0 PID: 743 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.827425] Modules linked in:
[   83.829504] CPU: 0 PID: 743 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   83.834022]  00000001 00000000 00000068 d382be08 c14341a1 00000000 00000=
000 c16ebf08
[   83.835094]  d382be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382be34
[   83.836132]  c1056a11 00000009 00000000 d382be8c c1150db8 d38b6000 fffff=
fff ffffffff
[   83.843925] Call Trace:
[   83.844283]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.844899]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.845622]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.846217]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.853597]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.854187]  [<c10537ff>] mmput+0x52/0xef
[   83.854713]  [<c1175602>] flush_old_exec+0x923/0x99d
[   83.855334]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   83.855985]  [<c108559f>] ? local_clock+0x2f/0x39
[   83.856548]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   83.864284]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   83.865000]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   83.865676]  [<c11762eb>] do_execve+0x19/0x1b
[   83.866186]  [<c1176586>] SyS_execve+0x21/0x25
[   83.873434]  [<c143be92>] syscall_call+0x7/0x7
[   83.874034] ---[ end trace 6a7094e9a1d04d47 ]---
[   83.900925] ------------[ cut here ]------------
[   83.901594] WARNING: CPU: 0 PID: 743 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.902686] Modules linked in:
[   83.903119] CPU: 0 PID: 743 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   83.904085]  00000001 00000000 00000069 d382bea8 c14341a1 00000000 00000=
000 c16ebf08
[   83.918343]  d382bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bed4
[   83.919437]  c1056a11 00000009 00000000 d382bf2c c1150db8 d38b6d00 fffff=
fff ffffffff
[   83.920451] Call Trace:
[   83.920733]  [<c14341a1>] dump_stack+0x78/0xa8
[   83.921270]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   83.921890]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   83.930471]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   83.931090]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   83.931594]  [<c10537ff>] mmput+0x52/0xef
[   83.932130]  [<c105955b>] do_exit+0x5bc/0xee9
[   83.932720]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   83.940124]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   83.940641]  [<c143becb>] ? restore_all+0xf/0xf
[   83.941179]  [<c1059fe4>] do_group_exit+0x113/0x113
[   83.941716]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   83.942385]  [<c143be92>] syscall_call+0x7/0x7
[   83.942981] ---[ end trace 6a7094e9a1d04d48 ]---
[   83.976281] ------------[ cut here ]------------
[   83.976942] WARNING: CPU: 0 PID: 744 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   83.978077] Modules linked in:
[   83.978512] CPU: 0 PID: 744 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   83.979600]  00000001 00000000 0000006a d381be08 c14341a1 00000000 00000=
000 c16ebf08
[   83.990900]  d381be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381be34
[   83.992053]  c1056a11 00000009 00000000 d381be8c c1150db8 d38a7d80 fffff=
fff ffffffff
[   83.993251] Call Trace:
[   84.004454]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.004951]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.008270]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.011559]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.014258]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.015791]  [<c10537ff>] mmput+0x52/0xef
[   84.016249]  [<c1175602>] flush_old_exec+0x923/0x99d
[   84.016875]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   84.017466]  [<c108559f>] ? local_clock+0x2f/0x39
[   84.025725]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   84.026455]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   84.027094]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   84.035321]  [<c11762eb>] do_execve+0x19/0x1b
[   84.038154]  [<c1176586>] SyS_execve+0x21/0x25
[   84.039020]  [<c143be92>] syscall_call+0x7/0x7
[   84.039530] ---[ end trace 6a7094e9a1d04d49 ]---
[   84.042268] ------------[ cut here ]------------
[   84.042807] WARNING: CPU: 1 PID: 744 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.043785] Modules linked in:
[   84.044151] CPU: 1 PID: 744 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   84.045196]  00000001 00000000 0000006b d381bea8 c14341a1 00000000 00000=
001 c16ebf08
[   84.046370]  d381bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bed4
[   84.047532]  c1056a11 00000009 00000000 d381bf2c c1150db8 d38b2500 fffff=
fff ffffffff
[   84.048744] Call Trace:
[   84.049103]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.049698]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.050425]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.051055]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.051677]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.052330]  [<c10537ff>] mmput+0x52/0xef
[   84.052881]  [<c105955b>] do_exit+0x5bc/0xee9
[   84.062580]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   84.063227]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   84.063806]  [<c143becb>] ? restore_all+0xf/0xf
[   84.064321]  [<c1059fe4>] do_group_exit+0x113/0x113
[   84.064985]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   84.065624]  [<c143be92>] syscall_call+0x7/0x7
[   84.066119] ---[ end trace 6a7094e9a1d04d4a ]---
[   84.069288] ------------[ cut here ]------------
[   84.069810] WARNING: CPU: 0 PID: 745 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.070803] Modules linked in:
[   84.071253] CPU: 0 PID: 745 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   84.072341]  00000001 00000000 0000006c d382be08 c14341a1 00000000 00000=
000 c16ebf08
[   84.073386]  d382be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382be34
[   84.078665]  c1056a11 00000009 00000000 d382be8c c1150db8 d38d3000 fffff=
fff ffffffff
[   84.079744] Call Trace:
[   84.080064]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.080577]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.088122]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.091343]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.094632]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.097773]  [<c10537ff>] mmput+0x52/0xef
[   84.098899]  [<c1175602>] flush_old_exec+0x923/0x99d
[   84.099462]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   84.100067]  [<c108559f>] ? local_clock+0x2f/0x39
[   84.100597]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   84.109100]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   84.109699]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   84.110355]  [<c11762eb>] do_execve+0x19/0x1b
[   84.110861]  [<c1176586>] SyS_execve+0x21/0x25
[   84.121366]  [<c143be92>] syscall_call+0x7/0x7
[   84.124498] ---[ end trace 6a7094e9a1d04d4b ]---
[   84.127417] ------------[ cut here ]------------
[   84.128021] WARNING: CPU: 1 PID: 745 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.129142] Modules linked in:
[   84.129558] CPU: 1 PID: 745 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   84.130623]  00000001 00000000 0000006d d382bea8 c14341a1 00000000 00000=
001 c16ebf08
[   84.131806]  d382bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bed4
[   84.132892]  c1056a11 00000009 00000000 d382bf2c c1150db8 d14dad00 fffff=
fff ffffffff
[   84.135392] Call Trace:
[   84.135732]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.136315]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.137067]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.137660]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.138357]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.138979]  [<c10537ff>] mmput+0x52/0xef
[   84.139423]  [<c105955b>] do_exit+0x5bc/0xee9
[   84.139901]  [<c143becb>] ? restore_all+0xf/0xf
[   84.140542]  [<c1059fe4>] do_group_exit+0x113/0x113
[   84.141213]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   84.141833]  [<c143be92>] syscall_call+0x7/0x7
[   84.157549] ---[ end trace 6a7094e9a1d04d4c ]---
[   84.204536] ------------[ cut here ]------------
[   84.207715] WARNING: CPU: 0 PID: 746 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.209720] Modules linked in:
[   84.210124] CPU: 0 PID: 746 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   84.218662]  00000001 00000000 0000006e d381be08 c14341a1 00000000 00000=
000 c16ebf08
[   84.224751]  d381be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381be34
[   84.226103]  c1056a11 00000009 00000000 d381be8c c1150db8 d38b6d00 fffff=
fff ffffffff
[   84.227114] Call Trace:
[   84.227400]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.235531]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.236129]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.236661]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.240679]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.245538]  [<c10537ff>] mmput+0x52/0xef
[   84.245997]  [<c1175602>] flush_old_exec+0x923/0x99d
[   84.246555]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   84.252525]  [<c108559f>] ? local_clock+0x2f/0x39
[   84.253060]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   84.258164]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   84.260467]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   84.265321]  [<c11762eb>] do_execve+0x19/0x1b
[   84.265998]  [<c1176586>] SyS_execve+0x21/0x25
[   84.266508]  [<c143be92>] syscall_call+0x7/0x7
[   84.270402] ---[ end trace 6a7094e9a1d04d4d ]---
[   84.302554] ------------[ cut here ]------------
[   84.303112] WARNING: CPU: 1 PID: 746 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.304145] Modules linked in:
[   84.312216] CPU: 1 PID: 746 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   84.313116]  00000001 00000000 0000006f d381bea8 c14341a1 00000000 00000=
001 c16ebf08
[   84.314132]  d381bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bed4
[   84.322870]  c1056a11 00000009 00000000 d381bf2c c1150db8 d38a2380 fffff=
fff ffffffff
[   84.323938] Call Trace:
[   84.324229]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.332517]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.333145]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.333761]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.342040]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.342656]  [<c10537ff>] mmput+0x52/0xef
[   84.343108]  [<c105955b>] do_exit+0x5bc/0xee9
[   84.343637]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   84.344162]  [<c143becb>] ? restore_all+0xf/0xf
[   84.352428]  [<c1059fe4>] do_group_exit+0x113/0x113
[   84.353027]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   84.353625]  [<c143be92>] syscall_call+0x7/0x7
[   84.354142] ---[ end trace 6a7094e9a1d04d4e ]---
[   84.365117] ------------[ cut here ]------------
[   84.365746] WARNING: CPU: 0 PID: 747 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.366871] Modules linked in:
[   84.367295] CPU: 0 PID: 747 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   84.368417]  00000001 00000000 00000070 d382be08 c14341a1 00000000 00000=
000 c16ebf08
[   84.369484]  d382be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382be34
[   84.370480]  c1056a11 00000009 00000000 d382be8c c1150db8 d38a7d80 fffff=
fff ffffffff
[   84.371614] Call Trace:
[   84.371992]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.372601]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.373287]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.373912]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.374621]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.375259]  [<c10537ff>] mmput+0x52/0xef
[   84.375779]  [<c1175602>] flush_old_exec+0x923/0x99d
[   84.386489]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   84.387187]  [<c108559f>] ? local_clock+0x2f/0x39
[   84.387822]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   84.395603]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   84.396209]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   84.396851]  [<c11762eb>] do_execve+0x19/0x1b
[   84.397423]  [<c1176586>] SyS_execve+0x21/0x25
[   84.398101]  [<c143be92>] syscall_call+0x7/0x7
[   84.398764] ---[ end trace 6a7094e9a1d04d4f ]---
[   84.420127] ------------[ cut here ]------------
[   84.420656] WARNING: CPU: 1 PID: 747 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.429301] Modules linked in:
[   84.429662] CPU: 1 PID: 747 Comm: expr Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   84.430566]  00000001 00000000 00000071 d382bea8 c14341a1 00000000 00000=
001 c16ebf08
[   84.439194]  d382bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bed4
[   84.440200]  c1056a11 00000009 00000000 d382bf2c c1150db8 d38b2500 fffff=
fff ffffffff
[   84.451174] Call Trace:
[   84.451459]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.452306]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.452901]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.453477]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.454061]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.462241]  [<c10537ff>] mmput+0x52/0xef
[   84.462687]  [<c105955b>] do_exit+0x5bc/0xee9
[   84.463196]  [<c143becb>] ? restore_all+0xf/0xf
[   84.463761]  [<c1059fe4>] do_group_exit+0x113/0x113
[   84.471868]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   84.474785]  [<c143be92>] syscall_call+0x7/0x7
[   84.477912] ---[ end trace 6a7094e9a1d04d50 ]---
[   84.508621] ------------[ cut here ]------------
[   84.509256] WARNING: CPU: 0 PID: 748 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.510389] Modules linked in:
[   84.510806] CPU: 0 PID: 748 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   84.523486]  00000001 00000000 00000072 d381be08 c14341a1 00000000 00000=
000 c16ebf08
[   84.524676]  d381be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381be34
[   84.525836]  c1056a11 00000009 00000000 d381be8c c1150db8 d38ec800 fffff=
fff ffffffff
[   84.537097] Call Trace:
[   84.537432]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.538002]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.538632]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.539281]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.539911]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.550512]  [<c10537ff>] mmput+0x52/0xef
[   84.550965]  [<c1175602>] flush_old_exec+0x923/0x99d
[   84.551648]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   84.552380]  [<c108559f>] ? local_clock+0x2f/0x39
[   84.552986]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   84.563880]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   84.564636]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   84.565366]  [<c11762eb>] do_execve+0x19/0x1b
[   84.565879]  [<c1176586>] SyS_execve+0x21/0x25
[   84.566382]  [<c143be92>] syscall_call+0x7/0x7
[   84.575571] ---[ end trace 6a7094e9a1d04d51 ]---
[   84.591940] ------------[ cut here ]------------
[   84.592634] WARNING: CPU: 0 PID: 748 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.595920] Modules linked in:
[   84.596324] CPU: 0 PID: 748 Comm: plymouth Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   84.597320]  00000001 00000000 00000073 d381bdb8 c14341a1 00000000 00000=
000 c16ebf08
[   84.611074]  d381bdd4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bde4
[   84.614741]  c1056a11 00000009 00000000 d381be3c c1150db8 d38d3000 fffff=
fff ffffffff
[   84.616182] Call Trace:
[   84.616477]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.617025]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.617606]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.628015]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.631303]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.634460]  [<c10537ff>] mmput+0x52/0xef
[   84.634921]  [<c105955b>] do_exit+0x5bc/0xee9
[   84.635802]  [<c1059fe4>] do_group_exit+0x113/0x113
[   84.636350]  [<c10653f7>] get_signal+0x89d/0x966
[   84.636897]  [<c10027f7>] do_signal+0x1e/0x12c
[   84.637396]  [<c1063c88>] ? do_tkill+0x81/0x89
[   84.647824]  [<c1002950>] do_notify_resume+0x4b/0xcb
[   84.648382]  [<c143bfa0>] work_notifysig+0x2b/0x3b
[   84.649294] ---[ end trace 6a7094e9a1d04d52 ]---
/etc/lsb-base-logging.sh: line 5:   748 Aborted                 plymouth --=
ping > /dev/null 2>&1
 * All processes ended within 1 seconds....      =20
[   84.654212] ------------[ cut here ]------------
[   84.664970] WARNING: CPU: 0 PID: 749 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.670902] Modules linked in:
[   84.671359] CPU: 0 PID: 749 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   84.672562]  00000001 00000000 00000074 d382be08 c14341a1 00000000 00000=
000 c16ebf08
[   84.683839]  d382be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382be34
[   84.684921]  c1056a11 00000009 00000000 d382be8c c1150db8 d38b6000 fffff=
fff ffffffff
[   84.685938] Call Trace:
[   84.686223]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.696785]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.697373]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.697962]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.698671]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.699297]  [<c10537ff>] mmput+0x52/0xef
[   84.699841]  [<c1175602>] flush_old_exec+0x923/0x99d
[   84.710525]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   84.711161]  [<c108559f>] ? local_clock+0x2f/0x39
[   84.711764]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   84.712625]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   84.720091]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   84.720807]  [<c11762eb>] do_execve+0x19/0x1b
[   84.721408]  [<c1176586>] SyS_execve+0x21/0x25
[   84.722005]  [<c143be92>] syscall_call+0x7/0x7
[   84.722588] ---[ end trace 6a7094e9a1d04d53 ]---
[   84.773522] ------------[ cut here ]------------
[   84.774066] WARNING: CPU: 1 PID: 749 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.785479] Modules linked in:
[   84.785845] CPU: 1 PID: 749 Comm: expr Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   84.786762]  00000001 00000000 00000075 d382bea8 c14341a1 00000000 00000=
001 c16ebf08
[   84.795492]  d382bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bed4
[   84.796515]  c1056a11 00000009 00000000 d382bf2c c1150db8 d38b6d00 fffff=
fff ffffffff
[   84.797532] Call Trace:
[   84.804639]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.808691]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.809505]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.810069]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.810647]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.818789]  [<c10537ff>] mmput+0x52/0xef
[   84.819254]  [<c105955b>] do_exit+0x5bc/0xee9
[   84.819740]  [<c143becb>] ? restore_all+0xf/0xf
[   84.820284]  [<c1059fe4>] do_group_exit+0x113/0x113
[   84.820837]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   84.829172]  [<c143be92>] syscall_call+0x7/0x7
[   84.829672] ---[ end trace 6a7094e9a1d04d54 ]---
[   84.832161] ------------[ cut here ]------------
[   84.832767] WARNING: CPU: 0 PID: 750 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.833892] Modules linked in:
[   84.834317] CPU: 0 PID: 750 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   84.835364]  00000001 00000000 00000076 d381be08 c14341a1 00000000 00000=
000 c16ebf08
[   84.836440]  d381be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381be34
[   84.837494]  c1056a11 00000009 00000000 d381be8c c1150db8 d38a7d80 fffff=
fff ffffffff
[   84.838668] Call Trace:
[   84.839018]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.839562]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.840252]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.840879]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.841567]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.842184]  [<c10537ff>] mmput+0x52/0xef
[   84.842706]  [<c1175602>] flush_old_exec+0x923/0x99d
[   84.847417]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   84.848101]  [<c108559f>] ? local_clock+0x2f/0x39
[   84.848717]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   84.849569]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   84.850373]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   84.851123]  [<c11762eb>] do_execve+0x19/0x1b
[   84.851639]  [<c1176586>] SyS_execve+0x21/0x25
[   84.871304]  [<c143be92>] syscall_call+0x7/0x7
[   84.871920] ---[ end trace 6a7094e9a1d04d55 ]---
[   84.875663] WARNING: CPU: 0 PID: 750 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.876751] Modules linked in:
[   84.896260] CPU: 0 PID: 750 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   84.897304]  00000001 00000000 00000077 d381bea8 c14341a1 00000000 00000=
000 c16ebf08
[   84.898373]  d381bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bed4
[   84.899428]  c1056a11 00000009 00000000 d381bf2c c1150db8 d38b2500 fffff=
fff ffffffff
[   84.900517] Call Trace:
[   84.900869]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.914499]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.915135]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.915816]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.916547]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.917206]  [<c10537ff>] mmput+0x52/0xef
[   84.917735]  [<c105955b>] do_exit+0x5bc/0xee9
[   84.918233]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   84.918845]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   84.919458]  [<c143becb>] ? restore_all+0xf/0xf
[   84.919965]  [<c1059fe4>] do_group_exit+0x113/0x113
[   84.920621]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   84.939331]  [<c143be92>] syscall_call+0x7/0x7
[   84.939900] ---[ end trace 6a7094e9a1d04d56 ]---
=20
[   84.955698] ------------[ cut here ]------------
[   84.956346] WARNING: CPU: 0 PID: 751 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   84.957403] Modules linked in:
[   84.957816] CPU: 0 PID: 751 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   84.958969]  00000001 00000000 00000078 d382be08 c14341a1 00000000 00000=
000 c16ebf08
[   84.974197]  d382be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382be34
[   84.975354]  c1056a11 00000009 00000000 d382be8c c1150db8 d38d3000 fffff=
fff ffffffff
[   84.976527] Call Trace:
[   84.976895]  [<c14341a1>] dump_stack+0x78/0xa8
[   84.977395]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   84.978054]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   84.978672]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   84.979374]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   84.994053]  [<c10537ff>] mmput+0x52/0xef
[   84.994556]  [<c1175602>] flush_old_exec+0x923/0x99d
[   84.995209]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   84.995867]  [<c108559f>] ? local_clock+0x2f/0x39
[   84.996458]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   85.014316]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   85.015058]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   85.015770]  [<c11762eb>] do_execve+0x19/0x1b
[   85.016357]  [<c1176586>] SyS_execve+0x21/0x25
[   85.016991]  [<c143be92>] syscall_call+0x7/0x7
[   85.017560] ---[ end trace 6a7094e9a1d04d57 ]---
[   85.032893] ------------[ cut here ]------------
[   85.033531] WARNING: CPU: 0 PID: 751 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.034571] Modules linked in:
[   85.035030] CPU: 0 PID: 751 Comm: plymouth Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   85.036103]  00000001 00000000 00000079 d382bdb8 c14341a1 00000000 00000=
000 c16ebf08
[   85.037225]  d382bdd4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bde4
[   85.056464]  c1056a11 00000009 00000000 d382be3c c1150db8 d14dad00 fffff=
fff ffffffff
[   85.057531] Call Trace:
[   85.057856]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.058472]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.059163]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.059779]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.060446]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.060976]  [<c10537ff>] mmput+0x52/0xef
[   85.061506]  [<c105955b>] do_exit+0x5bc/0xee9
[   85.062105]  [<c1059fe4>] do_group_exit+0x113/0x113
[   85.062757]  [<c10653f7>] get_signal+0x89d/0x966
[   85.087455]  [<c10027f7>] do_signal+0x1e/0x12c
[   85.088025]  [<c1063c88>] ? do_tkill+0x81/0x89
[   85.088552]  [<c1002950>] do_notify_resume+0x4b/0xcb
[   85.089175]  [<c143bfa0>] work_notifysig+0x2b/0x3b
[   85.089720] ---[ end trace 6a7094e9a1d04d58 ]---
/etc/lsb-base-logging.sh: line 5:   751 Aborted                 plymouth --=
ping > /dev/null 2>&1
[   85.116960] WARNING: CPU: 1 PID: 752 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.118014] Modules linked in:
[   85.118377] CPU: 1 PID: 752 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   85.119533]  00000001 00000000 0000007a d381be08 c14341a1 00000000 00000=
001 c16ebf08
[   85.120553]  d381be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381be34
[   85.128387]  c1056a11 00000009 00000000 d381be8c c1150db8 d38b6000 fffff=
fff ffffffff
[   85.132454] Call Trace:
[   85.132738]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.133236]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.133877]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.142009]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.142756]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.143261]  [<c10537ff>] mmput+0x52/0xef
[   85.143772]  [<c1175602>] flush_old_exec+0x923/0x99d
[   85.152034]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   85.152732]  [<c108559f>] ? local_clock+0x2f/0x39
[   85.153262]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   85.154011]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   85.162419]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   85.163016]  [<c11762eb>] do_execve+0x19/0x1b
[   85.163535]  [<c1176586>] SyS_execve+0x21/0x25
[   85.164032]  [<c143be92>] syscall_call+0x7/0x7
[   85.172284] ---[ end trace 6a7094e9a1d04d59 ]---
[   85.178918] WARNING: CPU: 0 PID: 752 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.180165] Modules linked in:
[   85.180618] CPU: 0 PID: 752 Comm: tput Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   85.181633]  00000001 00000000 0000007b d381bea8 c14341a1 00000000 00000=
000 c16ebf08
[   85.182688]  d381bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bed4
[   85.183826]  c1056a11 00000009 00000000 d381bf2c c1150db8 d38b6d00 fffff=
fff ffffffff
[   85.184957] Call Trace:
[   85.185277]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.185801]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.186389]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.187016]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.187714]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.208339]  [<c10537ff>] mmput+0x52/0xef
[   85.208926]  [<c105955b>] do_exit+0x5bc/0xee9
[   85.209494]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   85.210172]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   85.210711]  [<c143becb>] ? restore_all+0xf/0xf
[   85.211276]  [<c1059fe4>] do_group_exit+0x113/0x113
[   85.211920]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   85.212479]  [<c143be92>] syscall_call+0x7/0x7
[   85.230080] ---[ end trace 6a7094e9a1d04d5a ]---
[ OK ]
[   85.232013] ------------[ cut here ]------------

[   85.232591] WARNING: CPU: 1 PID: 712 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.233572] Modules linked in:
[   85.234172] CPU: 1 PID: 712 Comm: S20sendsigs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   85.235329]  00000001 00000000 0000007c d386dea8 c14341a1 00000000 00000=
001 c16ebf08
[   85.236411]  d386dec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d386ded4
[   85.237434]  c1056a11 00000009 00000000 d386df2c c1150db8 d384c680 fffff=
fff ffffffff
[   85.238693] Call Trace:
[   85.239148]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.239637]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.240245]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.240761]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.241422]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.242141]  [<c10537ff>] mmput+0x52/0xef
[   85.242711]  [<c105955b>] do_exit+0x5bc/0xee9
[   85.243319]  [<c116e776>] ? __vfs_read+0x32/0x9a
[   85.243969]  [<c143becb>] ? restore_all+0xf/0xf
[   85.248113]  [<c1059fe4>] do_group_exit+0x113/0x113
[   85.251409]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   85.254125]  [<c143be92>] syscall_call+0x7/0x7
[   85.254694] ---[ end trace 6a7094e9a1d04d5b ]---
[   85.273677] ------------[ cut here ]------------
[   85.274282] WARNING: CPU: 0 PID: 753 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.282923] Modules linked in:
[   85.283305] CPU: 0 PID: 753 Comm: rc Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   85.287878]  00000001 00000000 0000007d d382bd4c c14341a1 00000000 00000=
000 c16ebf08
[   85.290374]  d382bd68 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bd78
[   85.292620]  c1056a11 00000009 00000000 d382bdd0 c1150db8 d38a7d80 fffff=
fff ffffffff
[   85.298016] Call Trace:
[   85.298308]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.300311]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.300916]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.302599]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.305732]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.306329]  [<c10537ff>] mmput+0x52/0xef
[   85.315228]  [<c1175602>] flush_old_exec+0x923/0x99d
[   85.315833]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   85.316432]  [<c108559f>] ? local_clock+0x2f/0x39
[   85.317046]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   85.317812]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   85.318431]  [<c11ac7e5>] load_script+0x339/0x355
[   85.319083]  [<c108550c>] ? sched_clock_cpu+0x188/0x1a3
[   85.319786]  [<c108559f>] ? local_clock+0x2f/0x39
[   85.341460]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   85.342247]  [<c109c1bf>] ? do_raw_read_unlock+0x28/0x53
[   85.342847]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   85.343549]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   85.344225]  [<c11762eb>] do_execve+0x19/0x1b
[   85.344844]  [<c1176586>] SyS_execve+0x21/0x25
[   85.345437]  [<c143be92>] syscall_call+0x7/0x7
[   85.370047] ---[ end trace 6a7094e9a1d04d5c ]---
[   85.383884] ------------[ cut here ]------------
[   85.385475] WARNING: CPU: 1 PID: 754 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.386445] Modules linked in:
[   85.386826] CPU: 1 PID: 754 Comm: S30urandom Tainted: G        W      3.=
19.0-rc5-gf7a7b53 #19
[   85.394533]  00000001 00000000 0000007e d386de08 c14341a1 00000000 00000=
001 c16ebf08
[   85.395915]  d386de24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d386de34
[   85.396954]  c1056a11 00000009 00000000 d386de8c c1150db8 d38a2900 fffff=
fff ffffffff
[   85.404721] Call Trace:
[   85.405041]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.408070]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.411143]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.411661]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.412503]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.413108]  [<c10537ff>] mmput+0x52/0xef
[   85.413666]  [<c1175602>] flush_old_exec+0x923/0x99d
[   85.422261]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   85.422843]  [<c108559f>] ? local_clock+0x2f/0x39
[   85.423389]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   85.432016]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   85.432687]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   85.433283]  [<c11762eb>] do_execve+0x19/0x1b
[   85.433792]  [<c1176586>] SyS_execve+0x21/0x25
[   85.434295]  [<c143be92>] syscall_call+0x7/0x7
[   85.445253] ---[ end trace 6a7094e9a1d04d5d ]---
[   85.454741] ------------[ cut here ]------------
[   85.458047] WARNING: CPU: 1 PID: 754 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.461955] Modules linked in:
[   85.462434] CPU: 1 PID: 754 Comm: dd Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   85.463321]  00000001 00000000 0000007f d386dea8 c14341a1 00000000 00000=
001 c16ebf08
[   85.467772]  d386dec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d386ded4
[   85.472554]  c1056a11 00000009 00000000 d386df2c c1150db8 d38a7600 fffff=
fff ffffffff
[   85.478092] Call Trace:
[   85.478382]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.479295]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.479885]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.484252]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.485899]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.486430]  [<c10537ff>] mmput+0x52/0xef
[   85.490313]  [<c105955b>] do_exit+0x5bc/0xee9
[   85.490797]  [<c143becb>] ? restore_all+0xf/0xf
[   85.492481]  [<c1059fe4>] do_group_exit+0x113/0x113
[   85.493028]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   85.498055]  [<c143be92>] syscall_call+0x7/0x7
[   85.501238] ---[ end trace 6a7094e9a1d04d5e ]---
[   85.521659] ------------[ cut here ]------------
[   85.522510] WARNING: CPU: 1 PID: 753 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.523483] Modules linked in:
[   85.523843] CPU: 1 PID: 753 Comm: S30urandom Tainted: G        W      3.=
19.0-rc5-gf7a7b53 #19
[   85.529126]  00000001 00000000 00000080 d382bea8 c14341a1 00000000 00000=
001 c16ebf08
[   85.534559]  d382bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bed4
[   85.537266]  c1056a11 00000009 00000000 d382bf2c c1150db8 d38b2500 fffff=
fff ffffffff
[   85.540719] Call Trace:
[   85.544469]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.544974]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.548030]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.548654]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.550620]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.552433]  [<c10537ff>] mmput+0x52/0xef
[   85.555204]  [<c105955b>] do_exit+0x5bc/0xee9
[   85.555818]  [<c116e776>] ? __vfs_read+0x32/0x9a
[   85.556356]  [<c143becb>] ? restore_all+0xf/0xf
[   85.560272]  [<c1059fe4>] do_group_exit+0x113/0x113
[   85.560807]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   85.564886]  [<c143be92>] syscall_call+0x7/0x7
[   85.566953] ---[ end trace 6a7094e9a1d04d5f ]---
[   85.597294] ------------[ cut here ]------------
[   85.602372] WARNING: CPU: 0 PID: 755 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.603369] Modules linked in:
[   85.603745] CPU: 0 PID: 755 Comm: rc Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   85.610430]  00000001 00000000 00000081 d381bd4c c14341a1 00000000 00000=
000 c16ebf08
[   85.612565]  d381bd68 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bd78
[   85.617077]  c1056a11 00000009 00000000 d381bdd0 c1150db8 d38d3480 fffff=
fff ffffffff
[   85.620550] Call Trace:
[   85.620834]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.622509]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.623098]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.627081]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.632236]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.632832]  [<c10537ff>] mmput+0x52/0xef
[   85.633321]  [<c1175602>] flush_old_exec+0x923/0x99d
[   85.637295]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   85.641395]  [<c108559f>] ? local_clock+0x2f/0x39
[   85.642011]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   85.645057]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   85.650077]  [<c11ac7e5>] load_script+0x339/0x355
[   85.650604]  [<c108550c>] ? sched_clock_cpu+0x188/0x1a3
[   85.653500]  [<c108559f>] ? local_clock+0x2f/0x39
[   85.654121]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   85.657402]  [<c109c1bf>] ? do_raw_read_unlock+0x28/0x53
[   85.659234]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   85.659831]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   85.667769]  [<c11762eb>] do_execve+0x19/0x1b
[   85.668285]  [<c1176586>] SyS_execve+0x21/0x25
[   85.671541]  [<c143be92>] syscall_call+0x7/0x7
[   85.674583] ---[ end trace 6a7094e9a1d04d60 ]---
[   85.723861] ------------[ cut here ]------------
[   85.728970] WARNING: CPU: 0 PID: 756 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.729951] Modules linked in:
[   85.730337] CPU: 0 PID: 756 Comm: S31umountnfs.sh Tainted: G        W   =
   3.19.0-rc5-gf7a7b53 #19
[   85.737184]  00000001 00000000 00000082 d382be08 c14341a1 00000000 00000=
000 c16ebf08
[   85.740720]  d382be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382be34
[   85.745080]  c1056a11 00000009 00000000 d382be8c c1150db8 d38a7600 fffff=
fff ffffffff
[   85.747564] Call Trace:
[   85.749039]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.749629]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.754713]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.755369]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.756028]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.756531]  [<c10537ff>] mmput+0x52/0xef
[   85.761436]  [<c1175602>] flush_old_exec+0x923/0x99d
[   85.762464]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   85.765354]  [<c108559f>] ? local_clock+0x2f/0x39
[   85.766066]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   85.771183]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   85.771962]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   85.773941]  [<c11762eb>] do_execve+0x19/0x1b
[   85.775633]  [<c1176586>] SyS_execve+0x21/0x25
[   85.778064]  [<c143be92>] syscall_call+0x7/0x7
[   85.781298] ---[ end trace 6a7094e9a1d04d61 ]---
[   85.807170] ------------[ cut here ]------------
[   85.811352] WARNING: CPU: 1 PID: 756 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.815055] Modules linked in:
[   85.815970] CPU: 1 PID: 756 Comm: uname Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   85.820301]  00000001 00000000 00000083 d382bea8 c14341a1 00000000 00000=
001 c16ebf08
[   85.823768]  d382bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bed4
[   85.827843]  c1056a11 00000009 00000000 d382bf2c c1150db8 d38a7a00 fffff=
fff ffffffff
[   85.829318] Call Trace:
[   85.829600]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.834589]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.835616]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.836240]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.841291]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.841897]  [<c10537ff>] mmput+0x52/0xef
[   85.844792]  [<c105955b>] do_exit+0x5bc/0xee9
[   85.845667]  [<c143becb>] ? restore_all+0xf/0xf
[   85.846204]  [<c1059fe4>] do_group_exit+0x113/0x113
[   85.877902]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   85.881068]  [<c143be92>] syscall_call+0x7/0x7
[   85.881576] ---[ end trace 6a7094e9a1d04d62 ]---
[   85.909763] ------------[ cut here ]------------
[   85.910417] WARNING: CPU: 1 PID: 757 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.918357] Modules linked in:
[   85.920215] CPU: 1 PID: 757 Comm: S31umountnfs.sh Tainted: G        W   =
   3.19.0-rc5-gf7a7b53 #19
[   85.921451]  00000001 00000000 00000084 d38c3e08 c14341a1 00000000 00000=
001 c16ebf08
[   85.927862]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   85.929250]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d3858000 fffff=
fff ffffffff
[   85.933857] Call Trace:
[   85.934223]  [<c14341a1>] dump_stack+0x78/0xa8
[   85.937210]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   85.938675]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   85.940575]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   85.942406]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   85.942911]  [<c10537ff>] mmput+0x52/0xef
[   85.947777]  [<c1175602>] flush_old_exec+0x923/0x99d
[   85.948365]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   85.950431]  [<c108559f>] ? local_clock+0x2f/0x39
[   85.952131]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   85.952833]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   85.956911]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   85.957500]  [<c11762eb>] do_execve+0x19/0x1b
[   85.960442]  [<c1176586>] SyS_execve+0x21/0x25
[   85.962962]  [<c143be92>] syscall_call+0x7/0x7
[   85.964621] ---[ end trace 6a7094e9a1d04d63 ]---
[   85.986982] ------------[ cut here ]------------
[   85.987512] WARNING: CPU: 0 PID: 757 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   85.992812] Modules linked in:
[   85.993192] CPU: 0 PID: 757 Comm: uname Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   85.996318]  00000001 00000000 00000085 d38c3ea8 c14341a1 00000000 00000=
000 c16ebf08
[   86.001928]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   86.005626]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d384c680 fffff=
fff ffffffff
[   86.011152] Call Trace:
[   86.011435]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.012306]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.012885]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.017847]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.018565]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.020460]  [<c10537ff>] mmput+0x52/0xef
[   86.020905]  [<c105955b>] do_exit+0x5bc/0xee9
[   86.022557]  [<c1059fe4>] do_group_exit+0x113/0x113
[   86.023101]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   86.027116]  [<c143be92>] syscall_call+0x7/0x7
[   86.031114] ---[ end trace 6a7094e9a1d04d64 ]---
[   86.079370] ------------[ cut here ]------------
[   86.080005] WARNING: CPU: 0 PID: 758 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.087912] Modules linked in:
[   86.088293] CPU: 0 PID: 758 Comm: S31umountnfs.sh Tainted: G        W   =
   3.19.0-rc5-gf7a7b53 #19
[   86.089707]  00000001 00000000 00000086 d382be08 c14341a1 00000000 00000=
000 c16ebf08
[   86.092893]  d382be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382be34
[   86.096233]  c1056a11 00000009 00000000 d382be8c c1150db8 d3895a00 fffff=
fff ffffffff
[   86.101857] Call Trace:
[   86.102363]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.102946]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.107018]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.107558]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.110622]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.113600]  [<c10537ff>] mmput+0x52/0xef
[   86.114055]  [<c1175602>] flush_old_exec+0x923/0x99d
[   86.115845]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   86.116419]  [<c108559f>] ? local_clock+0x2f/0x39
[   86.120344]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   86.123520]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   86.124155]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   86.127078]  [<c11762eb>] do_execve+0x19/0x1b
[   86.130136]  [<c1176586>] SyS_execve+0x21/0x25
[   86.130657]  [<c143be92>] syscall_call+0x7/0x7
[   86.132344] ---[ end trace 6a7094e9a1d04d65 ]---
[   86.160248] ------------[ cut here ]------------
[   86.160802] WARNING: CPU: 1 PID: 758 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.167865] Modules linked in:
[   86.168238] CPU: 1 PID: 758 Comm: halt Tainted: G        W      3.19.0-r=
c5-gf7a7b53 #19
[   86.171987]  00000001 00000000 00000087 d382bea8 c14341a1 00000000 00000=
001 c16ebf08
[   86.175718]  d382bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d382bed4
[   86.191202]  c1056a11 00000009 00000000 d382bf2c c1150db8 d38a7000 fffff=
fff ffffffff
[   86.192565] Call Trace:
[   86.192852]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.193378]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.193971]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.201389]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.203672]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.204181]  [<c10537ff>] mmput+0x52/0xef
[   86.204701]  [<c105955b>] do_exit+0x5bc/0xee9
[   86.206858]  [<c143becb>] ? restore_all+0xf/0xf
[   86.207473]  [<c1059fe4>] do_group_exit+0x113/0x113
[   86.211555]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   86.213772]  [<c143be92>] syscall_call+0x7/0x7
[   86.214289] ---[ end trace 6a7094e9a1d04d66 ]---
[   86.236035] ------------[ cut here ]------------
[   86.236607] WARNING: CPU: 1 PID: 759 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.241764] Modules linked in:
[   86.242507] CPU: 1 PID: 759 Comm: S31umountnfs.sh Tainted: G        W   =
   3.19.0-rc5-gf7a7b53 #19
[   86.247029]  00000001 00000000 00000088 d38c3e08 c14341a1 00000000 00000=
001 c16ebf08
[   86.250478]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   86.252616]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d38eca00 fffff=
fff ffffffff
[   86.258007] Call Trace:
[   86.258290]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.261274]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.262122]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.262648]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.263227]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.268283]  [<c10537ff>] mmput+0x52/0xef
[   86.270286]  [<c1175602>] flush_old_exec+0x923/0x99d
[   86.270957]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   86.272785]  [<c108559f>] ? local_clock+0x2f/0x39
[   86.277777]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   86.278537]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   86.281518]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   86.284477]  [<c11762eb>] do_execve+0x19/0x1b
[   86.284968]  [<c1176586>] SyS_execve+0x21/0x25
[   86.287133]  [<c143be92>] syscall_call+0x7/0x7
[   86.287631] ---[ end trace 6a7094e9a1d04d67 ]---
[   86.319046] ------------[ cut here ]------------
[   86.319628] WARNING: CPU: 0 PID: 759 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.322800] Modules linked in:
[   86.323208] CPU: 0 PID: 759 Comm: rm Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   86.328148]  00000001 00000000 00000089 d38c3ea8 c14341a1 00000000 00000=
000 c16ebf08
[   86.332235]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   86.333236]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d38d3480 fffff=
fff ffffffff
[   86.341535] Call Trace:
[   86.343536]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.344037]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.348135]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.350094]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.350664]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.352384]  [<c10537ff>] mmput+0x52/0xef
[   86.352832]  [<c105955b>] do_exit+0x5bc/0xee9
[   86.357745]  [<c143becb>] ? restore_all+0xf/0xf
[   86.358267]  [<c1059fe4>] do_group_exit+0x113/0x113
[   86.359015]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   86.359564]  [<c143be92>] syscall_call+0x7/0x7
[   86.364583] ---[ end trace 6a7094e9a1d04d68 ]---
[   86.385314] ------------[ cut here ]------------
[   86.387509] WARNING: CPU: 0 PID: 760 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.389617] Modules linked in:
[   86.390100] CPU: 0 PID: 760 Comm: S31umountnfs.sh Tainted: G        W   =
   3.19.0-rc5-gf7a7b53 #19
[   86.398007]  00000001 00000000 0000008a d3819e08 c14341a1 00000000 00000=
000 c16ebf08
[   86.399513]  d3819e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3819e34
[   86.403759]  c1056a11 00000009 00000000 d3819e8c c1150db8 d3858380 fffff=
fff ffffffff
[   86.405798] Call Trace:
[   86.407963]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.410348]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.412206]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.412732]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.413313]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.418322]  [<c10537ff>] mmput+0x52/0xef
[   86.419091]  [<c1175602>] flush_old_exec+0x923/0x99d
[   86.419733]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   86.424817]  [<c108559f>] ? local_clock+0x2f/0x39
[   86.426898]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   86.427607]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   86.429403]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   86.429992]  [<c11762eb>] do_execve+0x19/0x1b
[   86.434928]  [<c1176586>] SyS_execve+0x21/0x25
[   86.436912]  [<c143be92>] syscall_call+0x7/0x7
[   86.437406] ---[ end trace 6a7094e9a1d04d69 ]---
[   86.472188] ------------[ cut here ]------------
[   86.472744] WARNING: CPU: 1 PID: 760 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.475906] Modules linked in:
[   86.476351] CPU: 1 PID: 760 Comm: initctl Tainted: G        W      3.19.=
0-rc5-gf7a7b53 #19
[   86.480743]  00000001 00000000 0000008b d3819ea8 c14341a1 00000000 00000=
001 c16ebf08
[   86.484807]  d3819ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3819ed4
[   86.487463]  c1056a11 00000009 00000000 d3819f2c c1150db8 d384c680 fffff=
fff ffffffff
[   86.489605] Call Trace:
[   86.489891]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.494834]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.495893]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.496442]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.500429]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.500951]  [<c10537ff>] mmput+0x52/0xef
[   86.502636]  [<c105955b>] do_exit+0x5bc/0xee9
[   86.503227]  [<c143becb>] ? restore_all+0xf/0xf
[   86.509174]  [<c1059fe4>] do_group_exit+0x113/0x113
[   86.509735]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   86.513088]  [<c143be92>] syscall_call+0x7/0x7
[   86.515634] ---[ end trace 6a7094e9a1d04d6a ]---
[   86.539033] ------------[ cut here ]------------
[   86.539678] WARNING: CPU: 1 PID: 755 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.540808] Modules linked in:
[   86.541298] CPU: 1 PID: 755 Comm: S31umountnfs.sh Tainted: G        W   =
   3.19.0-rc5-gf7a7b53 #19
[   86.542370]  00000001 00000000 0000008c d381bea8 c14341a1 00000000 00000=
001 c16ebf08
[   86.543372]  d381bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d381bed4
[   86.544402]  c1056a11 00000009 00000000 d381bf2c c1150db8 d14dad00 fffff=
fff ffffffff
[   86.545659] Call Trace:
[   86.565473]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.566104]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.566813]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.567340]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.567969]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.568540]  [<c10537ff>] mmput+0x52/0xef
[   86.569020]  [<c105955b>] do_exit+0x5bc/0xee9
[   86.569502]  [<c116e776>] ? __vfs_read+0x32/0x9a
[   86.570039]  [<c143becb>] ? restore_all+0xf/0xf
[   86.570647]  [<c1059fe4>] do_group_exit+0x113/0x113
[   86.601378]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   86.602021]  [<c143be92>] syscall_call+0x7/0x7
[   86.602540] ---[ end trace 6a7094e9a1d04d6b ]---
[   86.633400] ------------[ cut here ]------------
[   86.633975] WARNING: CPU: 0 PID: 761 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.644062] Modules linked in:
[   86.645343] CPU: 0 PID: 761 Comm: rc Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   86.649548]  00000001 00000000 0000008d d3819d4c c14341a1 00000000 00000=
000 c16ebf08
[   86.652714]  d3819d68 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3819d78
[   86.659108]  c1056a11 00000009 00000000 d3819dd0 c1150db8 d38b2980 fffff=
fff ffffffff
[   86.664503] Call Trace:
[   86.664790]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.668010]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.670252]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.670789]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.674840]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.678946]  [<c10537ff>] mmput+0x52/0xef
[   86.679413]  [<c1175602>] flush_old_exec+0x923/0x99d
[   86.679978]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   86.683990]  [<c108559f>] ? local_clock+0x2f/0x39
[   86.688848]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   86.689552]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   86.694598]  [<c11ac7e5>] load_script+0x339/0x355
[   86.697772]  [<c108550c>] ? sched_clock_cpu+0x188/0x1a3
[   86.698413]  [<c108559f>] ? local_clock+0x2f/0x39
[   86.701659]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   86.704016]  [<c109c1bf>] ? do_raw_read_unlock+0x28/0x53
[   86.708332]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   86.710605]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   86.714641]  [<c11762eb>] do_execve+0x19/0x1b
[   86.716826]  [<c1176586>] SyS_execve+0x21/0x25
[   86.717333]  [<c143be92>] syscall_call+0x7/0x7
[   86.726209] ---[ end trace 6a7094e9a1d04d6c ]---
/etc/rc6.d/S40umountfs: line 20: /proc/mounts: No such file or directory
[   86.737711] ------------[ cut here ]------------
[   86.738247] WARNING: CPU: 1 PID: 761 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.739428] Modules linked in:
[   86.739791] CPU: 1 PID: 761 Comm: S40umountfs Tainted: G        W      3=
=2E19.0-rc5-gf7a7b53 #19
[   86.740768]  00000001 00000000 0000008e d3819ea8 c14341a1 00000000 00000=
001 c16ebf08
[   86.751287]  d3819ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3819ed4
[   86.754784]  c1056a11 00000009 00000000 d3819f2c c1150db8 d38b2d80 fffff=
fff ffffffff
[   86.759365] Call Trace:
[   86.759651]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.760197]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.760786]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.765836]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.766430]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.766969]  [<c10537ff>] mmput+0x52/0xef
[   86.767435]  [<c105955b>] do_exit+0x5bc/0xee9
[   86.775941]  [<c10fead5>] ? trace_hardirqs_on+0x31/0x33
[   86.776545]  [<c106582e>] ? sigprocmask+0x99/0xaa
[   86.777135]  [<c143becb>] ? restore_all+0xf/0xf
[   86.785253]  [<c1059fe4>] do_group_exit+0x113/0x113
[   86.788224]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   86.789147]  [<c143be92>] syscall_call+0x7/0x7
[   86.789651] ---[ end trace 6a7094e9a1d04d6d ]---
[   86.798215] ------------[ cut here ]------------
[   86.798864] WARNING: CPU: 0 PID: 762 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.799963] Modules linked in:
[   86.800421] CPU: 0 PID: 762 Comm: rc Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   86.801457]  00000001 00000000 0000008f d38afd4c c14341a1 00000000 00000=
000 c16ebf08
[   86.802685]  d38afd68 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38afd78
[   86.803874]  c1056a11 00000009 00000000 d38afdd0 c1150db8 d38a2700 fffff=
fff ffffffff
[   86.804976] Call Trace:
[   86.805303]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.805856]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.806469]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.807025]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.807603]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.808234]  [<c10537ff>] mmput+0x52/0xef
[   86.808780]  [<c1175602>] flush_old_exec+0x923/0x99d
[   86.823477]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   86.824047]  [<c108559f>] ? local_clock+0x2f/0x39
[   86.824623]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   86.825434]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   86.826184]  [<c11ac7e5>] load_script+0x339/0x355
[   86.826822]  [<c108550c>] ? sched_clock_cpu+0x188/0x1a3
[   86.827400]  [<c108559f>] ? local_clock+0x2f/0x39
[   86.827987]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   86.828814]  [<c109c1bf>] ? do_raw_read_unlock+0x28/0x53
[   86.829431]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   86.839561]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   86.840308]  [<c11762eb>] do_execve+0x19/0x1b
[   86.840864]  [<c1176586>] SyS_execve+0x21/0x25
[   86.841419]  [<c143be92>] syscall_call+0x7/0x7
[   86.841947] ---[ end trace 6a7094e9a1d04d6e ]---
[   86.926159] ------------[ cut here ]------------
[   86.926821] WARNING: CPU: 0 PID: 763 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.927956] Modules linked in:
[   86.928315] CPU: 0 PID: 763 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   86.929426]  00000001 00000000 00000090 d3821e08 c14341a1 00000000 00000=
000 c16ebf08
[   86.930660]  d3821e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3821e34
[   86.931749]  c1056a11 00000009 00000000 d3821e8c c1150db8 d14dad00 fffff=
fff ffffffff
[   86.932816] Call Trace:
[   86.933119]  [<c14341a1>] dump_stack+0x78/0xa8
[   86.933655]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   86.934343]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   86.934956]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   86.935631]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   86.936232]  [<c10537ff>] mmput+0x52/0xef
[   86.936798]  [<c1175602>] flush_old_exec+0x923/0x99d
[   86.937449]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   86.938128]  [<c108559f>] ? local_clock+0x2f/0x39
[   86.938724]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   86.939477]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   86.940132]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   86.940713]  [<c11762eb>] do_execve+0x19/0x1b
[   86.941256]  [<c1176586>] SyS_execve+0x21/0x25
[   86.941867]  [<c143be92>] syscall_call+0x7/0x7
[   86.971853] ---[ end trace 6a7094e9a1d04d6f ]---
cat: /proc/1/maps: No such file or directory
[   86.981944] ------------[ cut here ]------------
[   86.982498] WARNING: CPU: 0 PID: 763 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   86.989589] Modules linked in:
[   86.990044] CPU: 0 PID: 763 Comm: cat Tainted: G        W      3.19.0-rc=
5-gf7a7b53 #19
[   86.991047]  00000001 00000000 00000091 d3821ea8 c14341a1 00000000 00000=
000 c16ebf08
[   86.992041]  d3821ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3821ed4
[   86.993259]  c1056a11 00000009 00000000 d3821f2c c1150db8 d3858000 fffff=
fff ffffffff
[   86.994282] Call Trace:
[   86.994629]  [<c14341a1>] dump_stack+0x78/0xa8
[   87.013305]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   87.014043]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   87.014687]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   87.015338]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   87.028475]  [<c10537ff>] mmput+0x52/0xef
[   87.029035]  [<c105955b>] do_exit+0x5bc/0xee9
[   87.029596]  [<c143becb>] ? restore_all+0xf/0xf
[   87.030220]  [<c1059fe4>] do_group_exit+0x113/0x113
[   87.030842]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   87.031414]  [<c143be92>] syscall_call+0x7/0x7
[   87.031968] ---[ end trace 6a7094e9a1d04d70 ]---
[   87.043240] ------------[ cut here ]------------
[   87.043931] WARNING: CPU: 0 PID: 764 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   87.045109] Modules linked in:
[   87.045557] CPU: 0 PID: 764 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   87.046668]  00000001 00000000 00000092 d3881e08 c14341a1 00000000 00000=
000 c16ebf08
[   87.047912]  d3881e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3881e34
[   87.069154]  c1056a11 00000009 00000000 d3881e8c c1150db8 d38b0000 fffff=
fff ffffffff
[   87.070322] Call Trace:
[   87.070618]  [<c14341a1>] dump_stack+0x78/0xa8
[   87.071161]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   87.071849]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   87.072445]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   87.073035]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   87.073622]  [<c10537ff>] mmput+0x52/0xef
[   87.074198]  [<c1175602>] flush_old_exec+0x923/0x99d
[   87.074866]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   87.075582]  [<c108559f>] ? local_clock+0x2f/0x39
[   87.100267]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   87.100991]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   87.101681]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   87.102373]  [<c11762eb>] do_execve+0x19/0x1b
[   87.102873]  [<c1176586>] SyS_execve+0x21/0x25
[   87.103403]  [<c143be92>] syscall_call+0x7/0x7
[   87.103991] ---[ end trace 6a7094e9a1d04d71 ]---
[   87.122511] ------------[ cut here ]------------
[   87.123181] WARNING: CPU: 0 PID: 1 at mm/mmap.c:2858 exit_mmap+0x197/0x1=
ad()
[   87.124202] Modules linked in:
[   87.124644] CPU: 0 PID: 1 Comm: init Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   87.125723]  00000001 00000000 00000093 d1c3fe08 c14341a1 00000000 00000=
000 c16ebf08
[   87.126804]  d1c3fe24
[   87.130499] ------------[ cut here ]------------
[   87.130505] WARNING: CPU: 1 PID: 764 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   87.130506] Modules linked in:

[   87.150286]  c1056987 00000b2a c1150db8 00000001 00000001 00000000 d1c3f=
e34
[   87.151548]  c1056a11 00000009 00000000 d1c3fe8c c1150db8 d3812d00 fffff=
fff ffffffff
[   87.152706] Call Trace:
[   87.153005]  [<c14341a1>] dump_stack+0x78/0xa8
[   87.153523]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   87.154108]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   87.154839]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   87.175596]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   87.176124]  [<c10537ff>] mmput+0x52/0xef
[   87.176575]  [<c1175602>] flush_old_exec+0x923/0x99d
[   87.177156]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   87.177799]  [<c108559f>] ? local_clock+0x2f/0x39
[   87.178456]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   87.179343]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   87.180037]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   87.180761]  [<c11762eb>] do_execve+0x19/0x1b
[   87.198626]  [<c1176586>] SyS_execve+0x21/0x25
[   87.199234]  [<c143be92>] syscall_call+0x7/0x7
[   87.199824] ---[ end trace 6a7094e9a1d04d72 ]---
[   87.201130] CPU: 1 PID: 764 Comm: telinit Tainted: G        W      3.19.=
0-rc5-gf7a7b53 #19
[   87.202563]  00000001 00000000 00000094 d3881ea8 c14341a1 00000000 00000=
001 c16ebf08
[   87.203745]  d3881ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3881ed4
[   87.212806]  c1056a11 00000009 00000000 d3881f2c c1150db8 d38b0400 fffff=
fff ffffffff
[   87.213814] Call Trace:
[   87.214107]  [<c14341a1>] dump_stack+0x78/0xa8
[   87.224754]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   87.228173]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   87.228864]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   87.229441]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   87.229953]  [<c10537ff>] mmput+0x52/0xef
[   87.230423]  [<c105955b>] do_exit+0x5bc/0xee9
[   87.230926]  [<c1077958>] ? put_cred+0x15/0x40
[   87.239376]  [<c143becb>] ? restore_all+0xf/0xf
[   87.239897]  [<c1059fe4>] do_group_exit+0x113/0x113
[   87.240484]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   87.248606]  [<c143be92>] syscall_call+0x7/0x7
[   87.249245] ---[ end trace 6a7094e9a1d04d73 ]---
[   87.262630] ------------[ cut here ]------------
[   87.263203] WARNING: CPU: 1 PID: 767 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   87.264192] Modules linked in:
[   87.272541] CPU: 1 PID: 767 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   87.273537]  00000001 00000000 00000095 d3827e08 c14341a1 00000000 00000=
001 c16ebf08
[   87.282241]  d3827e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3827e34
[   87.283251]  c1056a11 00000009 00000000 d3827e8c c1150db8 d3858380 fffff=
fff ffffffff
[   87.284286] Call Trace:
[   87.292411]  [<c14341a1>] dump_stack+0x78/0xa8
[   87.295235]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   87.295901]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   87.296430]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   87.297052]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   87.297555]  [<c10537ff>] mmput+0x52/0xef
[   87.305984]  [<c1175602>] flush_old_exec+0x923/0x99d
[   87.306559]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   87.307272]  [<c108559f>] ? local_clock+0x2f/0x39
[   87.317737]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   87.318784]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   87.319422]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   87.320063]  [<c11762eb>] do_execve+0x19/0x1b
[   87.320548]  [<c1176586>] SyS_execve+0x21/0x25
[   87.328672]  [<c143be92>] syscall_call+0x7/0x7
[   87.329269] ---[ end trace 6a7094e9a1d04d74 ]---
[   88.365831] ------------[ cut here ]------------
[   88.366902] WARNING: CPU: 0 PID: 767 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   88.367955] Modules linked in:
[   88.368398] CPU: 0 PID: 767 Comm: sleep Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   88.369473]  00000001 00000000 00000096 d3827ea8 c14341a1 00000000 00000=
000 c16ebf08
[   88.370779]  d3827ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3827ed4
[   88.371840]  c1056a11 00000009 00000000 d3827f2c c1150db8 d384aa00 fffff=
fff ffffffff
[   88.372844] Call Trace:
[   88.373143]  [<c14341a1>] dump_stack+0x78/0xa8
[   88.373754]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   88.374369]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   88.375026]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   88.375733]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   88.376353]  [<c10537ff>] mmput+0x52/0xef
[   88.376989]  [<c105955b>] do_exit+0x5bc/0xee9
[   88.377585]  [<c143becb>] ? restore_all+0xf/0xf
[   88.378200]  [<c1059fe4>] do_group_exit+0x113/0x113
[   88.378826]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   88.379472]  [<c143be92>] syscall_call+0x7/0x7
[   88.390107] ---[ end trace 6a7094e9a1d04d75 ]---
[   88.428709] ------------[ cut here ]------------
[   88.429288] WARNING: CPU: 0 PID: 768 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   88.430293] Modules linked in:
[   88.430655] CPU: 0 PID: 768 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   88.431732]  00000001 00000000 00000097 d38c3e08 c14341a1 00000000 00000=
000 c16ebf08
[   88.432966]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   88.455162]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d38b6780 fffff=
fff ffffffff
[   88.456313] Call Trace:
[   88.456638]  [<c14341a1>] dump_stack+0x78/0xa8
[   88.457193]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   88.457816]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   88.458452]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   88.459113]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   88.459622]  [<c10537ff>] mmput+0x52/0xef
[   88.460116]  [<c1175602>] flush_old_exec+0x923/0x99d
[   88.460789]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   88.475569]  [<c108559f>] ? local_clock+0x2f/0x39
[   88.476118]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   88.476867]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   88.477571]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   88.478278]  [<c11762eb>] do_execve+0x19/0x1b
[   88.478866]  [<c1176586>] SyS_execve+0x21/0x25
[   88.479470]  [<c143be92>] syscall_call+0x7/0x7
[   88.480057] ---[ end trace 6a7094e9a1d04d76 ]---
cat: /proc/1/maps: No such file or directory
[   88.510885] ------------[ cut here ]------------
[   88.519196] WARNING: CPU: 1 PID: 768 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   88.520216] Modules linked in:
[   88.520575] CPU: 1 PID: 768 Comm: cat Tainted: G        W      3.19.0-rc=
5-gf7a7b53 #19
[   88.529176]  00000001 00000000 00000098 d38c3ea8 c14341a1 00000000 00000=
001 c16ebf08
[   88.530214]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   88.538910]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d38a2700 fffff=
fff ffffffff
[   88.539927] Call Trace:
[   88.540250]  [<c14341a1>] dump_stack+0x78/0xa8
[   88.540738]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   88.551300]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   88.552249]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   88.552844]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   88.553371]  [<c10537ff>] mmput+0x52/0xef
[   88.553827]  [<c105955b>] do_exit+0x5bc/0xee9
[   88.561175]  [<c143becb>] ? restore_all+0xf/0xf
[   88.561702]  [<c1059fe4>] do_group_exit+0x113/0x113
[   88.564891]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   88.568948]  [<c143be92>] syscall_call+0x7/0x7
[   88.569465] ---[ end trace 6a7094e9a1d04d77 ]---
[   88.572306] ------------[ cut here ]------------
[   88.572926] WARNING: CPU: 0 PID: 769 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   88.574144] Modules linked in:
[   88.574601] CPU: 0 PID: 769 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   88.575746]  00000001 00000000 00000099 d38d5e08 c14341a1 00000000 00000=
000 c16ebf08
[   88.576927]  d38d5e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5e34
[   88.578033]  c1056a11 00000009 00000000 d38d5e8c c1150db8 d38d3480 fffff=
fff ffffffff
[   88.579124] Call Trace:
[   88.579450]  [<c14341a1>] dump_stack+0x78/0xa8
[   88.580055]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   88.580729]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   88.581372]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   88.581996]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   88.582576]  [<c10537ff>] mmput+0x52/0xef
[   88.583065]  [<c1175602>] flush_old_exec+0x923/0x99d
[   88.583659]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   88.584245]  [<c108559f>] ? local_clock+0x2f/0x39
[   88.584866]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   88.604706]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   88.605486]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   88.606232]  [<c11762eb>] do_execve+0x19/0x1b
[   88.606816]  [<c1176586>] SyS_execve+0x21/0x25
[   88.607314]  [<c143be92>] syscall_call+0x7/0x7
[   88.607843] ---[ end trace 6a7094e9a1d04d78 ]---
[   88.622561] ------------[ cut here ]------------
[   88.623112] WARNING: CPU: 0 PID: 769 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   88.624259] Modules linked in:
[   88.624705] CPU: 0 PID: 769 Comm: logger Tainted: G        W      3.19.0=
-rc5-gf7a7b53 #19
[   88.625761]  00000001 00000000 0000009a d38d5ea8 c14341a1 00000000 00000=
000 c16ebf08
[   88.626916]  d38d5ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5ed4
[   88.644979]  c1056a11 00000009 00000000 d38d5f2c c1150db8 d3812b80 fffff=
fff ffffffff
[   88.646135] Call Trace:
[   88.646473]  [<c14341a1>] dump_stack+0x78/0xa8
[   88.647050]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   88.647632]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   88.648256]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   88.648954]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   88.649471]  [<c10537ff>] mmput+0x52/0xef
[   88.649910]  [<c105955b>] do_exit+0x5bc/0xee9
[   88.668551]  [<c143becb>] ? restore_all+0xf/0xf
[   88.669154]  [<c1059fe4>] do_group_exit+0x113/0x113
[   88.669774]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   88.682471]  [<c143be92>] syscall_call+0x7/0x7
[   88.683062] ---[ end trace 6a7094e9a1d04d79 ]---
[   88.689289] ------------[ cut here ]------------
[   88.689828] WARNING: CPU: 0 PID: 770 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   88.690986] Modules linked in:
[   88.691449] CPU: 0 PID: 770 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   88.692701]  00000001 00000000 0000009b d38c3e08 c14341a1 00000000 00000=
000 c16ebf08
[   88.707003]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   88.708157]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d3832600 fffff=
fff ffffffff
[   88.709398] Call Trace:
[   88.709733]  [<c14341a1>] dump_stack+0x78/0xa8
[   88.710348]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   88.711034]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   88.711569]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   88.712231]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   88.712828]  [<c10537ff>] mmput+0x52/0xef
[   88.713371]  [<c1175602>] flush_old_exec+0x923/0x99d
[   88.740995]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   88.741622]  [<c108559f>] ? local_clock+0x2f/0x39
[   88.742233]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   88.742925]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   88.743623]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   88.744344]  [<c11762eb>] do_execve+0x19/0x1b
[   88.744914]  [<c1176586>] SyS_execve+0x21/0x25
[   88.745518]  [<c143be92>] syscall_call+0x7/0x7
[   88.746087] ---[ end trace 6a7094e9a1d04d7a ]---
[   89.748345] ------------[ cut here ]------------
[   89.748912] WARNING: CPU: 1 PID: 770 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   89.749908] Modules linked in:
[   89.750321] CPU: 1 PID: 770 Comm: sleep Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   89.751210]  00000001 00000000 0000009c d38c3ea8 c14341a1 00000000 00000=
001 c16ebf08
[   89.752626]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   89.753698]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d384a880 fffff=
fff ffffffff
[   89.754844] Call Trace:
[   89.755253]  [<c14341a1>] dump_stack+0x78/0xa8
[   89.755809]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   89.756415]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   89.757053]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   89.757625]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   89.758207]  [<c10537ff>] mmput+0x52/0xef
[   89.758809]  [<c105955b>] do_exit+0x5bc/0xee9
[   89.759327]  [<c143becb>] ? restore_all+0xf/0xf
[   89.759824]  [<c1059fe4>] do_group_exit+0x113/0x113
[   89.760421]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   89.760952]  [<c143be92>] syscall_call+0x7/0x7
[   89.762426] ---[ end trace 6a7094e9a1d04d7b ]---
[   89.787381] ------------[ cut here ]------------
[   89.795834] WARNING: CPU: 0 PID: 771 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   89.796834] Modules linked in:
[   89.797201] CPU: 0 PID: 771 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   89.804907]  00000001 00000000 0000009d d38d5e08 c14341a1 00000000 00000=
000 c16ebf08
[   89.810279]  d38d5e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5e34
[   89.815651]  c1056a11 00000009 00000000 d38d5e8c c1150db8 d38b0380 fffff=
fff ffffffff
[   89.816637] Call Trace:
[   89.820311]  [<c14341a1>] dump_stack+0x78/0xa8
[   89.820818]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   89.825722]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   89.826270]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   89.831307]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   89.834459]  [<c10537ff>] mmput+0x52/0xef
[   89.834904]  [<c1175602>] flush_old_exec+0x923/0x99d
[   89.837106]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   89.841912]  [<c108559f>] ? local_clock+0x2f/0x39
[   89.842575]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   89.843268]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   89.848310]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   89.850552]  [<c11762eb>] do_execve+0x19/0x1b
[   89.855280]  [<c1176586>] SyS_execve+0x21/0x25
[   89.855892]  [<c143be92>] syscall_call+0x7/0x7
[   89.856409] ---[ end trace 6a7094e9a1d04d7c ]---
cat:=20
[   89.866943] ------------[ cut here ]------------
/proc/1/maps: No such file or directory
[   89.867804] WARNING: CPU: 1 PID: 771 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   89.868871] Modules linked in:
[   89.869256] CPU: 1 PID: 771 Comm: cat Tainted: G        W      3.19.0-rc=
5-gf7a7b53 #19
[   89.870182]  00000001 00000000 0000009e d38d5ea8 c14341a1 00000000 00000=
001 c16ebf08
[   89.871257]  d38d5ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5ed4
[   89.872352]  c1056a11 00000009 00000000 d38d5f2c c1150db8 d38b6000 fffff=
fff ffffffff
[   89.873437] Call Trace:
[   89.873731]  [<c14341a1>] dump_stack+0x78/0xa8
[   89.874238]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   89.884900]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   89.885472]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   89.886049]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   89.886550]  [<c10537ff>] mmput+0x52/0xef
[   89.887037]  [<c105955b>] do_exit+0x5bc/0xee9
[   89.887517]  [<c143becb>] ? restore_all+0xf/0xf
[   89.898110]  [<c1059fe4>] do_group_exit+0x113/0x113
[   89.898669]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   89.899246]  [<c143be92>] syscall_call+0x7/0x7
[   89.899735] ---[ end trace 6a7094e9a1d04d7d ]---
[   89.913419] ------------[ cut here ]------------
[   89.914053] WARNING: CPU: 0 PID: 772 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   89.915400] Modules linked in:
[   89.915766] CPU: 0 PID: 772 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   89.916809]  00000001 00000000 0000009f d38c3e08 c14341a1 00000000 00000=
000 c16ebf08
[   89.918155]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   89.919507]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d38d3480 fffff=
fff ffffffff
[   89.920626] Call Trace:
[   89.920944]  [<c14341a1>] dump_stack+0x78/0xa8
[   89.921621]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   89.922457]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   89.923052]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   89.923722]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   89.924246]  [<c10537ff>] mmput+0x52/0xef
[   89.924802]  [<c1175602>] flush_old_exec+0x923/0x99d
[   89.929347]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   89.929939]  [<c108559f>] ? local_clock+0x2f/0x39
[   89.930598]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   89.938172]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   89.939331]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   89.940044]  [<c11762eb>] do_execve+0x19/0x1b
[   89.940541]  [<c1176586>] SyS_execve+0x21/0x25
[   89.951195]  [<c143be92>] syscall_call+0x7/0x7
[   89.952959] ---[ end trace 6a7094e9a1d04d7e ]---
[   89.955381] ------------[ cut here ]------------
[   89.955925] WARNING: CPU: 1 PID: 772 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   89.956901] Modules linked in:
[   89.957267] CPU: 1 PID: 772 Comm: logger Tainted: G        W      3.19.0=
-rc5-gf7a7b53 #19
[   89.958223]  00000001 00000000 000000a0 d38c3ea8 c14341a1 00000000 00000=
001 c16ebf08
[   89.959336]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   89.960338]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d3812b80 fffff=
fff ffffffff
[   89.961453] Call Trace:
[   89.961760]  [<c14341a1>] dump_stack+0x78/0xa8
[   89.962350]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   89.962970]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   89.963528]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   89.964095]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   89.964696]  [<c10537ff>] mmput+0x52/0xef
[   89.965170]  [<c105955b>] do_exit+0x5bc/0xee9
[   89.965699]  [<c143becb>] ? restore_all+0xf/0xf
[   89.971402]  [<c1059fe4>] do_group_exit+0x113/0x113
[   89.972023]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   89.972639]  [<c143be92>] syscall_call+0x7/0x7
[   89.973155] ---[ end trace 6a7094e9a1d04d7f ]---
[   89.986139] ------------[ cut here ]------------
[   89.986811] WARNING: CPU: 0 PID: 773 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   89.987976] Modules linked in:
[   89.988339] CPU: 0 PID: 773 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   89.989468]  00000001 00000000 000000a1 d38d5e08 c14341a1 00000000 00000=
000 c16ebf08
[   89.990489]  d38d5e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5e34
[   89.991733]  c1056a11 00000009 00000000 d38d5e8c c1150db8 d3832600 fffff=
fff ffffffff
[   89.993263] Call Trace:
[   89.993630]  [<c14341a1>] dump_stack+0x78/0xa8
[   89.994230]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   90.004553]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   90.006052]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   90.006621]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   90.007261]  [<c10537ff>] mmput+0x52/0xef
[   90.014596]  [<c1175602>] flush_old_exec+0x923/0x99d
[   90.017939]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   90.018984]  [<c108559f>] ? local_clock+0x2f/0x39
[   90.019502]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   90.020261]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   90.028560]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   90.031527]  [<c11762eb>] do_execve+0x19/0x1b
[   90.035606]  [<c1176586>] SyS_execve+0x21/0x25
[   90.036195]  [<c143be92>] syscall_call+0x7/0x7
[   90.036804] ---[ end trace 6a7094e9a1d04d80 ]---
[   91.043993] ------------[ cut here ]------------
[   91.044555] WARNING: CPU: 1 PID: 773 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   91.045519] Modules linked in:
[   91.045878] CPU: 1 PID: 773 Comm: sleep Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   91.047402]  00000001 00000000 000000a2 d38d5ea8 c14341a1 00000000 00000=
001 c16ebf08
[   91.048846]  d38d5ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5ed4
[   91.057388]  c1056a11 00000009 00000000 d38d5f2c c1150db8 d384a880 fffff=
fff ffffffff
[   91.059068] Call Trace:
[   91.059361]  [<c14341a1>] dump_stack+0x78/0xa8
[   91.059872]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   91.060509]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   91.061163]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   91.061750]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   91.062481]  [<c10537ff>] mmput+0x52/0xef
[   91.062924]  [<c105955b>] do_exit+0x5bc/0xee9
[   91.063518]  [<c143becb>] ? restore_all+0xf/0xf
[   91.064041]  [<c1059fe4>] do_group_exit+0x113/0x113
[   91.065343]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   91.067283]  [<c143be92>] syscall_call+0x7/0x7
[   91.070227] ---[ end trace 6a7094e9a1d04d81 ]---
[   91.096004] ------------[ cut here ]------------
[   91.096672] WARNING: CPU: 0 PID: 774 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   91.105051] Modules linked in:
[   91.107359] CPU: 0 PID: 774 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   91.110795]  00000001 00000000 000000a3 d38c3e08 c14341a1 00000000 00000=
000 c16ebf08
[   91.116903]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   91.122240]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d38b0380 fffff=
fff ffffffff
[   91.128680] Call Trace:
[   91.129101]  [<c14341a1>] dump_stack+0x78/0xa8
[   91.129734]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   91.134795]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   91.137025]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   91.137588]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   91.142410]  [<c10537ff>] mmput+0x52/0xef
[   91.142872]  [<c1175602>] flush_old_exec+0x923/0x99d
[   91.148695]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   91.149572]  [<c108559f>] ? local_clock+0x2f/0x39
[   91.153214]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   91.157257]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   91.160388]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   91.165222]  [<c11762eb>] do_execve+0x19/0x1b
[   91.165853]  [<c1176586>] SyS_execve+0x21/0x25
[   91.167205]  [<c143be92>] syscall_call+0x7/0x7
[   91.172033] ---[ end trace 6a7094e9a1d04d82 ]---
cat:=20
[   91.214802] ------------[ cut here ]------------
[   91.221494] WARNING: CPU: 1 PID: 774 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   91.226219] Modules linked in:
[   91.226651] CPU: 1 PID: 774 Comm: cat Tainted: G        W      3.19.0-rc=
5-gf7a7b53 #19
[   91.237785]  00000001 00000000 000000a4 d38c3ea8 c14341a1 00000000 00000=
001 c16ebf08
[   91.240348]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   91.244860]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d38b6000 fffff=
fff ffffffff
[   91.253074] Call Trace:
[   91.253394]  [<c14341a1>] dump_stack+0x78/0xa8
[   91.253885]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   91.261278]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   91.265329]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   91.266074]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   91.266655]  [<c10537ff>] mmput+0x52/0xef
[   91.267206]  [<c105955b>] do_exit+0x5bc/0xee9
[   91.278874]  [<c143becb>] ? restore_all+0xf/0xf
[   91.279487]  [<c1059fe4>] do_group_exit+0x113/0x113
[   91.280188]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   91.280793]  [<c143be92>] syscall_call+0x7/0x7
[   91.289298] ---[ end trace 6a7094e9a1d04d83 ]---
/proc/1/maps: No such file or directory
[   91.296634] ------------[ cut here ]------------
[   91.297211] WARNING: CPU: 0 PID: 775 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   91.306047] Modules linked in:
[   91.306470] CPU: 0 PID: 775 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   91.316010]  00000001 00000000 000000a5 d38d5e08 c14341a1 00000000 00000=
000 c16ebf08
[   91.317119]  d38d5e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5e34
[   91.318280]  c1056a11 00000009 00000000 d38d5e8c c1150db8 d38d3480 fffff=
fff ffffffff
[   91.319422] Call Trace:
[   91.319733]  [<c14341a1>] dump_stack+0x78/0xa8
[   91.320284]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   91.320884]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   91.342675]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   91.343249]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   91.349028]  [<c10537ff>] mmput+0x52/0xef
[   91.349473]  [<c1175602>] flush_old_exec+0x923/0x99d
[   91.355602]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   91.356226]  [<c108559f>] ? local_clock+0x2f/0x39
[   91.362344]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   91.363204]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   91.369530]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   91.384174]  [<c11762eb>] do_execve+0x19/0x1b
[   91.384743]  [<c1176586>] SyS_execve+0x21/0x25
[   91.385360]  [<c143be92>] syscall_call+0x7/0x7
[   91.385892] ---[ end trace 6a7094e9a1d04d84 ]---
[   91.388594] ------------[ cut here ]------------
[   91.389151] WARNING: CPU: 1 PID: 775 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   91.390445] Modules linked in:
[   91.390821] CPU: 1 PID: 775 Comm: logger Tainted: G        W      3.19.0=
-rc5-gf7a7b53 #19
[   91.391883]  00000001 00000000 000000a6 d38d5ea8 c14341a1 00000000 00000=
001 c16ebf08
[   91.393021]  d38d5ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5ed4
[   91.394020]  c1056a11 00000009 00000000 d38d5f2c c1150db8 d3812b80 fffff=
fff ffffffff
[   91.395253] Call Trace:
[   91.395621]  [<c14341a1>] dump_stack+0x78/0xa8
[   91.396150]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   91.396749]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   91.397289]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   91.397961]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   91.398578]  [<c10537ff>] mmput+0x52/0xef
[   91.399149]  [<c105955b>] do_exit+0x5bc/0xee9
[   91.399650]  [<c143becb>] ? restore_all+0xf/0xf
[   91.400197]  [<c1059fe4>] do_group_exit+0x113/0x113
[   91.400732]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   91.412350]  [<c143be92>] syscall_call+0x7/0x7
[   91.412864] ---[ end trace 6a7094e9a1d04d85 ]---
[   91.426799] ------------[ cut here ]------------
[   91.427448] WARNING: CPU: 1 PID: 776 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   91.438730] Modules linked in:
[   91.439099] CPU: 1 PID: 776 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   91.440081]  00000001 00000000 000000a7 d38c3e08 c14341a1 00000000 00000=
001 c16ebf08
[   91.441091]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   91.455735]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d3832600 fffff=
fff ffffffff
[   91.456825] Call Trace:
[   91.457116]  [<c14341a1>] dump_stack+0x78/0xa8
[   91.457606]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   91.468360]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   91.468889]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   91.469462]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   91.469971]  [<c10537ff>] mmput+0x52/0xef
[   91.470436]  [<c1175602>] flush_old_exec+0x923/0x99d
[   91.470993]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   91.479288]  [<c108559f>] ? local_clock+0x2f/0x39
[   91.479817]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   91.480533]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   91.481148]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   91.486013]  [<c11762eb>] do_execve+0x19/0x1b
[   91.486590]  [<c1176586>] SyS_execve+0x21/0x25
[   91.487221]  [<c143be92>] syscall_call+0x7/0x7
[   91.487819] ---[ end trace 6a7094e9a1d04d86 ]---
[   92.501086] ------------[ cut here ]------------
[   92.501643] WARNING: CPU: 1 PID: 776 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   92.502615] Modules linked in:
[   92.502981] CPU: 1 PID: 776 Comm: sleep Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   92.503885]  00000001 00000000 000000a8 d38c3ea8 c14341a1 00000000 00000=
001 c16ebf08
[   92.504901]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   92.506357]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d384a880 fffff=
fff ffffffff
[   92.507607] Call Trace:
[   92.508039]  [<c14341a1>] dump_stack+0x78/0xa8
[   92.508642]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   92.509273]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   92.509792]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   92.510475]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   92.510982]  [<c10537ff>] mmput+0x52/0xef
[   92.511521]  [<c105955b>] do_exit+0x5bc/0xee9
[   92.512099]  [<c143becb>] ? restore_all+0xf/0xf
[   92.512656]  [<c1059fe4>] do_group_exit+0x113/0x113
[   92.513266]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   92.515350]  [<c143be92>] syscall_call+0x7/0x7
[   92.515857] ---[ end trace 6a7094e9a1d04d87 ]---
[   92.536474] ------------[ cut here ]------------
[   92.537051] WARNING: CPU: 0 PID: 777 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   92.541419] Modules linked in:
[   92.541827] CPU: 0 PID: 777 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   92.542961]  00000001 00000000 000000a9 d38d5e08 c14341a1 00000000 00000=
000 c16ebf08
[   92.547475]  d38d5e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5e34
[   92.548744]  c1056a11 00000009 00000000 d38d5e8c c1150db8 d38b0380 fffff=
fff ffffffff
[   92.549776] Call Trace:
[   92.553480]  [<c14341a1>] dump_stack+0x78/0xa8
[   92.553978]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   92.554561]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   92.555205]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   92.555900]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   92.560439]  [<c10537ff>] mmput+0x52/0xef
[   92.560888]  [<c1175602>] flush_old_exec+0x923/0x99d
[   92.561620]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   92.563773]  [<c108559f>] ? local_clock+0x2f/0x39
[   92.564360]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   92.567259]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   92.570069]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   92.570681]  [<c11762eb>] do_execve+0x19/0x1b
[   92.571169]  [<c1176586>] SyS_execve+0x21/0x25
[   92.573977]  [<c143be92>] syscall_call+0x7/0x7
[   92.574490] ---[ end trace 6a7094e9a1d04d88 ]---
[   92.619040] ------------[ cut here ]------------
[   92.619626] WARNING: CPU: 1 PID: 777 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   92.620635] Modules linked in:
[   92.621039] CPU: 1 PID: 777 Comm: cat Tainted: G        W      3.19.0-rc=
5-gf7a7b53 #19
[   92.632115]  00000001 00000000 000000aa d38d5ea8 c14341a1 00000000 00000=
001 c16ebf08
[   92.633093]  d38d5ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5ed4
[   92.634101]  c1056a11 00000009 00000000 d38d5f2c c1150db8 d38b6000 fffff=
fff ffffffff
[   92.648657] Call Trace:
[   92.648993]  [<c14341a1>] dump_stack+0x78/0xa8
[   92.649565]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   92.650254]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   92.650827]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   92.664906]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   92.665494]  [<c10537ff>] mmput+0x52/0xef
[   92.666004]  [<c105955b>] do_exit+0x5bc/0xee9
[   92.666568]  [<c143becb>] ? restore_all+0xf/0xf
[   92.667172]  [<c1059fe4>] do_group_exit+0x113/0x113
[   92.667767]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   92.678945]  [<c143be92>] syscall_call+0x7/0x7
[   92.679459] ---[ end trace 6a7094e9a1d04d89 ]---
cat: /proc/1/maps: No such file or directory
[   92.684309] ------------[ cut here ]------------
[   92.694503] WARNING: CPU: 0 PID: 778 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   92.699095] Modules linked in:
[   92.699461] CPU: 0 PID: 778 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   92.700425]  00000001 00000000 000000ab d38c3e08 c14341a1 00000000 00000=
000 c16ebf08
[   92.711539]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   92.712661]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d38d3480 fffff=
fff ffffffff
[   92.713813] Call Trace:
[   92.714129]  [<c14341a1>] dump_stack+0x78/0xa8
[   92.728103]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   92.728740]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   92.729265]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   92.729824]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   92.730385]  [<c10537ff>] mmput+0x52/0xef
[   92.730846]  [<c1175602>] flush_old_exec+0x923/0x99d
[   92.741937]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   92.742513]  [<c108559f>] ? local_clock+0x2f/0x39
[   92.743057]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   92.743837]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   92.744525]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   92.755325]  [<c11762eb>] do_execve+0x19/0x1b
[   92.755814]  [<c1176586>] SyS_execve+0x21/0x25
[   92.756311]  [<c143be92>] syscall_call+0x7/0x7
[   92.756858] ---[ end trace 6a7094e9a1d04d8a ]---
[   92.763486] ------------[ cut here ]------------
[   92.764066] WARNING: CPU: 1 PID: 778 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   92.765409] Modules linked in:
[   92.765879] CPU: 1 PID: 778 Comm: logger Tainted: G        W      3.19.0=
-rc5-gf7a7b53 #19
[   92.767062]  00000001 00000000 000000ac d38c3ea8 c14341a1 00000000 00000=
001 c16ebf08
[   92.768463]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   92.769445]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d3812b80 fffff=
fff ffffffff
[   92.770586] Call Trace:
[   92.770954]  [<c14341a1>] dump_stack+0x78/0xa8
[   92.782034]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   92.782625]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   92.783171]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   92.783910]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   92.784563]  [<c10537ff>] mmput+0x52/0xef
[   92.798942]  [<c105955b>] do_exit+0x5bc/0xee9
[   92.799531]  [<c143becb>] ? restore_all+0xf/0xf
[   92.800141]  [<c1059fe4>] do_group_exit+0x113/0x113
[   92.800675]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   92.801207]  [<c143be92>] syscall_call+0x7/0x7
[   92.815161] ---[ end trace 6a7094e9a1d04d8b ]---
[   92.820684] ------------[ cut here ]------------
[   92.821337] WARNING: CPU: 0 PID: 779 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   92.822366] Modules linked in:
[   92.822723] CPU: 0 PID: 779 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   92.823786]  00000001 00000000 000000ad d38d5e08 c14341a1 00000000 00000=
000 c16ebf08
[   92.824869]  d38d5e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5e34
[   92.825911]  c1056a11 00000009 00000000 d38d5e8c c1150db8 d384cd00 fffff=
fff ffffffff
[   92.826961] Call Trace:
[   92.827244]  [<c14341a1>] dump_stack+0x78/0xa8
[   92.827735]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   92.828447]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   92.829071]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   92.829719]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   92.830307]  [<c10537ff>] mmput+0x52/0xef
[   92.830802]  [<c1175602>] flush_old_exec+0x923/0x99d
[   92.831525]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   92.832231]  [<c108559f>] ? local_clock+0x2f/0x39
[   92.832848]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   92.833719]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   92.834446]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   92.845296]  [<c11762eb>] do_execve+0x19/0x1b
[   92.845855]  [<c1176586>] SyS_execve+0x21/0x25
[   92.846414]  [<c143be92>] syscall_call+0x7/0x7
[   92.846983] ---[ end trace 6a7094e9a1d04d8c ]---
[   93.849268] ------------[ cut here ]------------
[   93.849809] WARNING: CPU: 1 PID: 779 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   93.850789] Modules linked in:
[   93.851159] CPU: 1 PID: 779 Comm: sleep Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   93.852426]  00000001 00000000 000000ae d38d5ea8 c14341a1 00000000 00000=
001 c16ebf08
[   93.853806]  d38d5ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5ed4
[   93.855065]  c1056a11 00000009 00000000 d38d5f2c c1150db8 d3832600 fffff=
fff ffffffff
[   93.856034] Call Trace:
[   93.856322]  [<c14341a1>] dump_stack+0x78/0xa8
[   93.856963]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   93.857567]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   93.858142]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   93.858924]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   93.859450]  [<c10537ff>] mmput+0x52/0xef
[   93.859898]  [<c105955b>] do_exit+0x5bc/0xee9
[   93.860469]  [<c143becb>] ? restore_all+0xf/0xf
[   93.860978]  [<c1059fe4>] do_group_exit+0x113/0x113
[   93.861598]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   93.865589]  [<c143be92>] syscall_call+0x7/0x7
[   93.866087] ---[ end trace 6a7094e9a1d04d8d ]---
[   93.868836] ------------[ cut here ]------------
[   93.869362] WARNING: CPU: 0 PID: 780 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   93.870439] Modules linked in:
[   93.870813] CPU: 0 PID: 780 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   93.872037]  00000001 00000000 000000af d38c3e08 c14341a1 00000000 00000=
000 c16ebf08
[   93.873292]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   93.874625]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d38b0380 fffff=
fff ffffffff
[   93.875892] Call Trace:
[   93.876195]  [<c14341a1>] dump_stack+0x78/0xa8
[   93.876717]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   93.877305]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   93.877821]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   93.878511]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   93.879034]  [<c10537ff>] mmput+0x52/0xef
[   93.879497]  [<c1175602>] flush_old_exec+0x923/0x99d
[   93.880067]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   93.880642]  [<c108559f>] ? local_clock+0x2f/0x39
[   93.881190]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   93.895634]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   93.896252]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   93.896859]  [<c11762eb>] do_execve+0x19/0x1b
[   93.897353]  [<c1176586>] SyS_execve+0x21/0x25
[   93.897867]  [<c143be92>] syscall_call+0x7/0x7
[   93.914908] ---[ end trace 6a7094e9a1d04d8e ]---
cat:=20
[   93.931820] ------------[ cut here ]------------
[   93.932385] WARNING: CPU: 0 PID: 780 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   93.945137] Modules linked in:
[   93.945568] CPU: 0 PID: 780 Comm: cat Tainted: G        W      3.19.0-rc=
5-gf7a7b53 #19
[   93.946577]  00000001 00000000 000000b0 d38c3ea8 c14341a1 00000000 00000=
000 c16ebf08
[   93.947756]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   93.961045]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d38b6000 fffff=
fff ffffffff
[   93.965558] Call Trace:
[   93.965844]  [<c14341a1>] dump_stack+0x78/0xa8
[   93.966343]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   93.966961]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   93.967502]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   93.981550]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   93.982101]  [<c10537ff>] mmput+0x52/0xef
[   93.982562]  [<c105955b>] do_exit+0x5bc/0xee9
[   93.983080]  [<c143becb>] ? restore_all+0xf/0xf
[   93.983648]  [<c1059fe4>] do_group_exit+0x113/0x113
[   93.984231]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   93.998255]  [<c143be92>] syscall_call+0x7/0x7
[   93.998860] ---[ end trace 6a7094e9a1d04d8f ]---
/proc/1/maps: No such file or directory
[   94.013481] ------------[ cut here ]------------
[   94.014102] WARNING: CPU: 1 PID: 781 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   94.025367] Modules linked in:
[   94.025810] CPU: 1 PID: 781 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   94.032261]  00000001 00000000 000000b1 d385be08 c14341a1 00000000 00000=
001 c16ebf08
[   94.038003]  d385be24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d385be34
[   94.039045]  c1056a11 00000009 00000000 d385be8c c1150db8 d38d3480 fffff=
fff ffffffff
[   94.046840] Call Trace:
[   94.047137]  [<c14341a1>] dump_stack+0x78/0xa8
[   94.047637]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   94.051694]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   94.052274]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   94.052866]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   94.061454]  [<c10537ff>] mmput+0x52/0xef
[   94.061954]  [<c1175602>] flush_old_exec+0x923/0x99d
[   94.062567]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   94.063220]  [<c108559f>] ? local_clock+0x2f/0x39
[   94.070535]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   94.073477]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   94.074223]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   94.078347]  [<c11762eb>] do_execve+0x19/0x1b
[   94.078835]  [<c1176586>] SyS_execve+0x21/0x25
[   94.079340]  [<c143be92>] syscall_call+0x7/0x7
[   94.079850] ---[ end trace 6a7094e9a1d04d90 ]---
[   94.127722] ------------[ cut here ]------------
[   94.130887] WARNING: CPU: 0 PID: 781 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   94.133035] Modules linked in:
[   94.136926] CPU: 0 PID: 781 Comm: logger Tainted: G        W      3.19.0=
-rc5-gf7a7b53 #19
[   94.137822]  00000001 00000000 000000b2 d385bea8 c14341a1 00000000 00000=
000 c16ebf08
[   94.142761]  d385bec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d385bed4
[   94.149371]  c1056a11 00000009 00000000 d385bf2c c1150db8 d3812b80 fffff=
fff ffffffff
[   94.155569] Call Trace:
[   94.155853]  [<c14341a1>] dump_stack+0x78/0xa8
[   94.156371]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   94.162233]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   94.162749]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   94.168522]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   94.169091]  [<c10537ff>] mmput+0x52/0xef
[   94.169588]  [<c105955b>] do_exit+0x5bc/0xee9
[   94.175358]  [<c143becb>] ? restore_all+0xf/0xf
[   94.180224]  [<c1059fe4>] do_group_exit+0x113/0x113
[   94.180787]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   94.185335]  [<c143be92>] syscall_call+0x7/0x7
[   94.185822] ---[ end trace 6a7094e9a1d04d91 ]---
[   94.212669] ------------[ cut here ]------------
[   94.213234] WARNING: CPU: 1 PID: 782 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   94.214210] Modules linked in:
[   94.214572] CPU: 1 PID: 782 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   94.228439]  00000001 00000000 000000b3 d38c3e08 c14341a1 00000000 00000=
001 c16ebf08
[   94.229414]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   94.235877]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d384cd00 fffff=
fff ffffffff
[   94.241879] Call Trace:
[   94.242182]  [<c14341a1>] dump_stack+0x78/0xa8
[   94.242680]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   94.243269]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   94.250603]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   94.251235]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   94.255550]  [<c10537ff>] mmput+0x52/0xef
[   94.256002]  [<c1175602>] flush_old_exec+0x923/0x99d
[   94.256557]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   94.262564]  [<c108559f>] ? local_clock+0x2f/0x39
[   94.263146]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   94.268913]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   94.269522]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   94.275348]  [<c11762eb>] do_execve+0x19/0x1b
[   94.275915]  [<c1176586>] SyS_execve+0x21/0x25
[   94.276499]  [<c143be92>] syscall_call+0x7/0x7
[   94.282148] ---[ end trace 6a7094e9a1d04d92 ]---
[   94.320825] ------------[ cut here ]------------
[   94.321908] WARNING: CPU: 0 PID: 782 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   94.322866] Modules linked in:
[   94.323245] CPU: 0 PID: 782 Comm: logger Tainted: G        W      3.19.0=
-rc5-gf7a7b53 #19
[   94.344266]  00000001 00000000 000000b4 d38c3ea8 c14341a1 00000000 00000=
000 c16ebf08
[   94.345380]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   94.346514]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d3832600 fffff=
fff ffffffff
[   94.347591] Call Trace:
[   94.347888]  [<c14341a1>] dump_stack+0x78/0xa8
[   94.348412]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   94.363500]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   94.364055]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   94.368144]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   94.368678]  [<c10537ff>] mmput+0x52/0xef
[   94.369155]  [<c105955b>] do_exit+0x5bc/0xee9
[   94.369636]  [<c143becb>] ? restore_all+0xf/0xf
[   94.376908]  [<c1059fe4>] do_group_exit+0x113/0x113
[   94.377551]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   94.381634]  [<c143be92>] syscall_call+0x7/0x7
[   94.382204] ---[ end trace 6a7094e9a1d04d93 ]---
[   94.406805] ------------[ cut here ]------------
[   94.407495] WARNING: CPU: 0 PID: 783 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   94.418913] Modules linked in:
[   94.419346] CPU: 0 PID: 783 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   94.420423]  00000001 00000000 000000b5 d38d5e08 c14341a1 00000000 00000=
000 c16ebf08
[   94.430382]  d38d5e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5e34
[   94.436983]  c1056a11 00000009 00000000 d38d5e8c c1150db8 d38b0000 fffff=
fff ffffffff
[   94.441415] Call Trace:
[   94.441712]  [<c14341a1>] dump_stack+0x78/0xa8
[   94.442232]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   94.442825]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   94.450130]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   94.450693]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   94.451198]  [<c10537ff>] mmput+0x52/0xef
[   94.455163]  [<c1175602>] flush_old_exec+0x923/0x99d
[   94.455716]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   94.456289]  [<c108559f>] ? local_clock+0x2f/0x39
[   94.463584]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   94.464338]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   94.468458]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   94.469049]  [<c11762eb>] do_execve+0x19/0x1b
[   94.469535]  [<c1176586>] SyS_execve+0x21/0x25
[   94.477078]  [<c143be92>] syscall_call+0x7/0x7
[   94.477647] ---[ end trace 6a7094e9a1d04d94 ]---
[   94.530128] ------------[ cut here ]------------
[   94.530733] WARNING: CPU: 1 PID: 783 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   94.531745] Modules linked in:
[   94.532123] CPU: 1 PID: 783 Comm: mkdir Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   94.533003]  00000001 00000000 000000b6 d38d5ea8 c14341a1 00000000 00000=
001 c16ebf08
[   94.554139]  d38d5ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38d5ed4
[   94.555276]  c1056a11 00000009 00000000 d38d5f2c c1150db8 d38b0400 fffff=
fff ffffffff
[   94.556281] Call Trace:
[   94.556563]  [<c14341a1>] dump_stack+0x78/0xa8
[   94.557094]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   94.557675]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   94.558255]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   94.558908]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   94.579569]  [<c10537ff>] mmput+0x52/0xef
[   94.580143]  [<c105955b>] do_exit+0x5bc/0xee9
[   94.580669]  [<c143becb>] ? restore_all+0xf/0xf
[   94.581224]  [<c1059fe4>] do_group_exit+0x113/0x113
[   94.581806]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   94.582357]  [<c143be92>] syscall_call+0x7/0x7
[   94.582843] ---[ end trace 6a7094e9a1d04d95 ]---
[   94.612858] ------------[ cut here ]------------
[   94.613428] WARNING: CPU: 1 PID: 784 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   94.614384] Modules linked in:
[   94.624971] CPU: 1 PID: 784 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   94.626126]  00000001 00000000 000000b7 d38c3e08 c14341a1 00000000 00000=
001 c16ebf08
[   94.627310]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   94.638547]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d38d3480 fffff=
fff ffffffff
[   94.639527] Call Trace:
[   94.639821]  [<c14341a1>] dump_stack+0x78/0xa8
[   94.647092]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   94.647695]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   94.651810]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   94.652512]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   94.653113]  [<c10537ff>] mmput+0x52/0xef
[   94.660408]  [<c1175602>] flush_old_exec+0x923/0x99d
[   94.661033]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   94.665129]  [<c108559f>] ? local_clock+0x2f/0x39
[   94.665661]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   94.666381]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   94.673820]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   94.674518]  [<c11762eb>] do_execve+0x19/0x1b
[   94.678442]  [<c1176586>] SyS_execve+0x21/0x25
[   94.678959]  [<c143be92>] syscall_call+0x7/0x7
[   94.679468] ---[ end trace 6a7094e9a1d04d96 ]---
[   94.728722] ------------[ cut here ]------------
[   94.729284] WARNING: CPU: 0 PID: 784 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   94.737081] Modules linked in:
[   94.737507] CPU: 0 PID: 784 Comm: mkdir Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   94.742030]  00000001 00000000 000000b8 d38c3ea8 c14341a1 00000000 00000=
000 c16ebf08
[   94.743168]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   94.750899]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d3812b80 fffff=
fff ffffffff
[   94.755346] Call Trace:
[   94.755628]  [<c14341a1>] dump_stack+0x78/0xa8
[   94.756131]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   94.760147]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   94.760784]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   94.763666]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   94.764275]  [<c10537ff>] mmput+0x52/0xef
[   94.768252]  [<c105955b>] do_exit+0x5bc/0xee9
[   94.768837]  [<c143becb>] ? restore_all+0xf/0xf
[   94.769444]  [<c1059fe4>] do_group_exit+0x113/0x113
[   94.773754]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   94.778169]  [<c143be92>] syscall_call+0x7/0x7
[   94.778683] ---[ end trace 6a7094e9a1d04d97 ]---
[   94.817060] ------------[ cut here ]------------
[   94.817688] WARNING: CPU: 1 PID: 785 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   94.819003] Modules linked in:
[   94.819416] CPU: 1 PID: 785 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   94.820490]  00000001 00000000 000000b9 c0035e08 c14341a1 00000000 00000=
001 c16ebf08
[   94.828447]  c0035e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0035e34
[   94.829643]  c1056a11 00000009 00000000 c0035e8c c1150db8 d384ca00 fffff=
fff ffffffff
[   94.834083] Call Trace:
[   94.834367]  [<c14341a1>] dump_stack+0x78/0xa8
[   94.837072]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   94.837680]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   94.841640]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   94.842215]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   94.842728]  [<c10537ff>] mmput+0x52/0xef
[   94.843198]  [<c1175602>] flush_old_exec+0x923/0x99d
[   94.847255]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   94.850126]  [<c108559f>] ? local_clock+0x2f/0x39
[   94.850705]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   94.854978]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   94.855697]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   94.856414]  [<c11762eb>] do_execve+0x19/0x1b
[   94.860347]  [<c1176586>] SyS_execve+0x21/0x25
[   94.860835]  [<c143be92>] syscall_call+0x7/0x7
[   94.864825] ---[ end trace 6a7094e9a1d04d98 ]---
[   94.888002] ------------[ cut here ]------------
umount: /var/run: not mounted
[   94.888787] WARNING: CPU: 0 PID: 785 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   94.889732] Modules linked in:
[   94.890147] CPU: 0 PID: 785 Comm: umount Tainted: G        W      3.19.0=
-rc5-gf7a7b53 #19
[   94.912116]  00000001 00000000 000000ba c0035ea8 c14341a1 00000000 00000=
000 c16ebf08
[   94.913129]  c0035ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 c0035ed4
[   94.914146]  c1056a11 00000009 00000000 c0035f2c c1150db8 d3832600 fffff=
fff ffffffff
[   94.915153] Call Trace:
[   94.915446]  [<c14341a1>] dump_stack+0x78/0xa8
[   94.915962]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   94.916547]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   94.917102]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   94.917663]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   94.918225]  [<c10537ff>] mmput+0x52/0xef
[   94.918686]  [<c105955b>] do_exit+0x5bc/0xee9
[   94.941229]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   94.941815]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   94.942338]  [<c143becb>] ? restore_all+0xf/0xf
[   94.942835]  [<c1059fe4>] do_group_exit+0x113/0x113
[   94.943410]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   94.943950]  [<c143be92>] syscall_call+0x7/0x7
[   94.944457] ---[ end trace 6a7094e9a1d04d99 ]---
[   94.970305] ------------[ cut here ]------------
[   94.970924] WARNING: CPU: 0 PID: 786 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   94.978702] Modules linked in:
[   94.979076] CPU: 0 PID: 786 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   94.983431]  00000001 00000000 000000bb d38c3e08 c14341a1 00000000 00000=
000 c16ebf08
[   94.984547]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   94.989066]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d38b6780 fffff=
fff ffffffff
[   94.994964] Call Trace:
[   94.995307]  [<c14341a1>] dump_stack+0x78/0xa8
[   94.995940]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.000056]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.000582]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.001154]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.003836]  [<c10537ff>] mmput+0x52/0xef
[   95.004295]  [<c1175602>] flush_old_exec+0x923/0x99d
[   95.008338]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   95.008977]  [<c108559f>] ? local_clock+0x2f/0x39
[   95.009558]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   95.013752]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   95.014491]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   95.018713]  [<c11762eb>] do_execve+0x19/0x1b
[   95.019319]  [<c1176586>] SyS_execve+0x21/0x25
[   95.019929]  [<c143be92>] syscall_call+0x7/0x7
[   95.023937] ---[ end trace 6a7094e9a1d04d9a ]---
[   95.060532] ------------[ cut here ]------------
[   95.061087] WARNING: CPU: 1 PID: 786 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.065567] Modules linked in:
[   95.065989] CPU: 1 PID: 786 Comm: rm Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   95.070453]  00000001 00000000 000000bc d38c3ea8 c14341a1 00000000 00000=
001 c16ebf08
[   95.073840]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   95.078458]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d38a2700 fffff=
fff ffffffff
[   95.079605] Call Trace:
[   95.079943]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.083878]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.084471]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.088467]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.089061]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.089560]  [<c10537ff>] mmput+0x52/0xef
[   95.093467]  [<c105955b>] do_exit+0x5bc/0xee9
[   95.094060]  [<c143becb>] ? restore_all+0xf/0xf
[   95.098092]  [<c1059fe4>] do_group_exit+0x113/0x113
[   95.098782]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   95.099445]  [<c143be92>] syscall_call+0x7/0x7
[   95.103459] ---[ end trace 6a7094e9a1d04d9b ]---
[   95.128489] ------------[ cut here ]------------
[   95.129142] WARNING: CPU: 1 PID: 787 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.130324] Modules linked in:
[   95.130748] CPU: 1 PID: 787 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   95.138642]  00000001 00000000 000000bd d3893e08 c14341a1 00000000 00000=
001 c16ebf08
[   95.139652]  d3893e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893e34
[   95.140674]  c1056a11 00000009 00000000 d3893e8c c1150db8 d38d3480 fffff=
fff ffffffff
[   95.147233] Call Trace:
[   95.147548]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.150274]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.150925]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.155022]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.155731]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.156350]  [<c10537ff>] mmput+0x52/0xef
[   95.161599]  [<c1175602>] flush_old_exec+0x923/0x99d
[   95.162163]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   95.162735]  [<c108559f>] ? local_clock+0x2f/0x39
[   95.163268]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   95.167534]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   95.170438]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   95.171123]  [<c11762eb>] do_execve+0x19/0x1b
[   95.175105]  [<c1176586>] SyS_execve+0x21/0x25
[   95.175660]  [<c143be92>] syscall_call+0x7/0x7
[   95.176215] ---[ end trace 6a7094e9a1d04d9c ]---
[   95.216308] ------------[ cut here ]------------
[   95.221601] WARNING: CPU: 0 PID: 787 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.222734] Modules linked in:
[   95.223181] CPU: 0 PID: 787 Comm: ln Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   95.227540]  00000001 00000000 000000be d3893ea8 c14341a1 00000000 00000=
000 c16ebf08
[   95.230866]  d3893ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893ed4
[   95.235457]  c1056a11 00000009 00000000 d3893f2c c1150db8 d3812b80 fffff=
fff ffffffff
[   95.236650] Call Trace:
[   95.240334]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.240825]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.244830]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.245363]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.245951]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.246559]  [<c10537ff>] mmput+0x52/0xef
[   95.251843]  [<c105955b>] do_exit+0x5bc/0xee9
[   95.252423]  [<c143becb>] ? restore_all+0xf/0xf
[   95.253034]  [<c1059fe4>] do_group_exit+0x113/0x113
[   95.258351]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   95.258966]  [<c143be92>] syscall_call+0x7/0x7
[   95.259509] ---[ end trace 6a7094e9a1d04d9d ]---
[   95.287144] ------------[ cut here ]------------
[   95.287744] WARNING: CPU: 1 PID: 788 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.294364] Modules linked in:
[   95.294866] CPU: 1 PID: 788 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   95.295843]  00000001 00000000 000000bf d38c3e08 c14341a1 00000000 00000=
001 c16ebf08
[   95.301525]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   95.302626]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d384ca00 fffff=
fff ffffffff
[   95.308500] Call Trace:
[   95.308835]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.309401]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.314737]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.315336]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.315976]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.316585]  [<c10537ff>] mmput+0x52/0xef
[   95.320534]  [<c1175602>] flush_old_exec+0x923/0x99d
[   95.321194]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   95.325278]  [<c108559f>] ? local_clock+0x2f/0x39
[   95.325798]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   95.326485]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   95.330602]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   95.334788]  [<c11762eb>] do_execve+0x19/0x1b
[   95.335378]  [<c1176586>] SyS_execve+0x21/0x25
[   95.335988]  [<c143be92>] syscall_call+0x7/0x7
[   95.336576] ---[ end trace 6a7094e9a1d04d9e ]---
umount: /var/lock: not mounted
[   95.382919] ------------[ cut here ]------------

[   95.383555] WARNING: CPU: 0 PID: 788 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.394728] Modules linked in:
[   95.395182] CPU: 0 PID: 788 Comm: umount Tainted: G        W      3.19.0=
-rc5-gf7a7b53 #19
[   95.396246]  00000001 00000000 000000c0 d38c3ea8 c14341a1 00000000 00000=
000 c16ebf08
[   95.397442]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   95.408634]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d3832600 fffff=
fff ffffffff
[   95.409608] Call Trace:
[   95.409891]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.410409]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.411037]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.425185]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.425826]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.426413]  [<c10537ff>] mmput+0x52/0xef
[   95.426975]  [<c105955b>] do_exit+0x5bc/0xee9
[   95.427560]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   95.434978]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   95.435500]  [<c143becb>] ? restore_all+0xf/0xf
[   95.436023]  [<c1059fe4>] do_group_exit+0x113/0x113
[   95.436582]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   95.437177]  [<c143be92>] syscall_call+0x7/0x7
[   95.437751] ---[ end trace 6a7094e9a1d04d9f ]---
[   95.462950] ------------[ cut here ]------------
[   95.463510] WARNING: CPU: 1 PID: 789 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.464494] Modules linked in:
[   95.471904] CPU: 1 PID: 789 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   95.473079]  00000001 00000000 000000c1 d3893e08 c14341a1 00000000 00000=
001 c16ebf08
[   95.474251]  d3893e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893e34
[   95.478977]  c1056a11 00000009 00000000 d3893e8c c1150db8 d38b6780 fffff=
fff ffffffff
[   95.484867] Call Trace:
[   95.485200]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.485768]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.486426]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.491725]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.492306]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.492812]  [<c10537ff>] mmput+0x52/0xef
[   95.493306]  [<c1175602>] flush_old_exec+0x923/0x99d
[   95.498768]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   95.499459]  [<c108559f>] ? local_clock+0x2f/0x39
[   95.503532]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   95.504413]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   95.508532]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   95.509198]  [<c11762eb>] do_execve+0x19/0x1b
[   95.509736]  [<c1176586>] SyS_execve+0x21/0x25
[   95.513703]  [<c143be92>] syscall_call+0x7/0x7
[   95.514265] ---[ end trace 6a7094e9a1d04da0 ]---
[   95.549496] ------------[ cut here ]------------
[   95.556795] WARNING: CPU: 0 PID: 789 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.561386] Modules linked in:
[   95.561789] CPU: 0 PID: 789 Comm: rm Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   95.562733]  00000001 00000000 000000c2 d3893ea8 c14341a1 00000000 00000=
000 c16ebf08
[   95.571625]  d3893ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893ed4
[   95.572797]  c1056a11 00000009 00000000 d3893f2c c1150db8 d38a2700 fffff=
fff ffffffff
[   95.573981] Call Trace:
[   95.587776]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.588339]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.589064]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.589660]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.590339]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.590922]  [<c10537ff>] mmput+0x52/0xef
[   95.601655]  [<c105955b>] do_exit+0x5bc/0xee9
[   95.602253]  [<c143becb>] ? restore_all+0xf/0xf
[   95.602832]  [<c1059fe4>] do_group_exit+0x113/0x113
[   95.603488]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   95.604132]  [<c143be92>] syscall_call+0x7/0x7
[   95.613397] ---[ end trace 6a7094e9a1d04da1 ]---
[   95.616745] ------------[ cut here ]------------
[   95.617302] WARNING: CPU: 1 PID: 790 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.618332] Modules linked in:
[   95.618728] CPU: 1 PID: 790 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   95.619976]  00000001 00000000 000000c3 d38c3e08 c14341a1 00000000 00000=
001 c16ebf08
[   95.621154]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   95.622383]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d38d3480 fffff=
fff ffffffff
[   95.623564] Call Trace:
[   95.623900]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.624498]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.625362]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.625986]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.626623]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.627239]  [<c10537ff>] mmput+0x52/0xef
[   95.627758]  [<c1175602>] flush_old_exec+0x923/0x99d
[   95.635229]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   95.635820]  [<c108559f>] ? local_clock+0x2f/0x39
[   95.636345]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   95.637057]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   95.637657]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   95.645091]  [<c11762eb>] do_execve+0x19/0x1b
[   95.645573]  [<c1176586>] SyS_execve+0x21/0x25
[   95.646069]  [<c143be92>] syscall_call+0x7/0x7
[   95.646556] ---[ end trace 6a7094e9a1d04da2 ]---
[   95.684024] ------------[ cut here ]------------
[   95.684831] WARNING: CPU: 0 PID: 790 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.685978] Modules linked in:
[   95.686417] CPU: 0 PID: 790 Comm: ln Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   95.695215]  00000001 00000000 000000c4 d38c3ea8 c14341a1 00000000 00000=
000 c16ebf08
[   95.696255]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   95.705197]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d3812b80 fffff=
fff ffffffff
[   95.706319] Call Trace:
[   95.707842]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.714011]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.718262]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.718875]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.719451]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.719961]  [<c10537ff>] mmput+0x52/0xef
[   95.728244]  [<c105955b>] do_exit+0x5bc/0xee9
[   95.728861]  [<c143becb>] ? restore_all+0xf/0xf
[   95.729409]  [<c1059fe4>] do_group_exit+0x113/0x113
[   95.731552]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   95.738115]  [<c143be92>] syscall_call+0x7/0x7
[   95.738647] ---[ end trace 6a7094e9a1d04da3 ]---
[   95.766785] ------------[ cut here ]------------
[   95.767445] WARNING: CPU: 1 PID: 791 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.775396] Modules linked in:
[   95.775834] CPU: 1 PID: 791 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   95.784821]  00000001 00000000 000000c5 d3893e08 c14341a1 00000000 00000=
001 c16ebf08
[   95.785889]  d3893e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893e34
[   95.793669]  c1056a11 00000009 00000000 d3893e8c c1150db8 d384cd00 fffff=
fff ffffffff
[   95.797251] Call Trace:
[   95.797552]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.801558]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.802268]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.802858]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.811291]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.811892]  [<c10537ff>] mmput+0x52/0xef
[   95.812459]  [<c1175602>] flush_old_exec+0x923/0x99d
[   95.813115]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   95.820453]  [<c108559f>] ? local_clock+0x2f/0x39
[   95.823463]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   95.824264]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   95.828418]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   95.829092]  [<c11762eb>] do_execve+0x19/0x1b
[   95.829570]  [<c1176586>] SyS_execve+0x21/0x25
[   95.836875]  [<c143be92>] syscall_call+0x7/0x7
[   95.837418] ---[ end trace 6a7094e9a1d04da4 ]---
[   95.891811] ------------[ cut here ]------------
[   95.892516] WARNING: CPU: 0 PID: 791 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.893669] Modules linked in:
[   95.894094] CPU: 0 PID: 791 Comm: umount Tainted: G        W      3.19.0=
-rc5-gf7a7b53 #19
[   95.911224]  00000001 00000000 000000c6 d3893ea8 c14341a1 00000000 00000=
000 c16ebf08
[   95.912410]  d3893ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893ed4
[   95.913632]  c1056a11 00000009 00000000 d3893f2c c1150db8 d3832600 fffff=
fff ffffffff
[   95.931736] Call Trace:
[   95.934522]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.935028]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   95.935733]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   95.936340]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   95.937056]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   95.951239]  [<c10537ff>] mmput+0x52/0xef
[   95.951774]  [<c105955b>] do_exit+0x5bc/0xee9
[   95.952400]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   95.953053]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   95.953685]  [<c143becb>] ? restore_all+0xf/0xf
umount: /dev/shm: not mounted
[   95.957000]  [<c1059fe4>] do_group_exit+0x113/0x113
[   95.965597]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   95.966130]  [<c143be92>] syscall_call+0x7/0x7
[   95.966626] ---[ end trace 6a7094e9a1d04da5 ]---
[   95.978563] ------------[ cut here ]------------
[   95.979208] WARNING: CPU: 1 PID: 792 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   95.980342] Modules linked in:
[   95.980762] CPU: 1 PID: 792 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   95.985405]  00000001 00000000 000000c7 d38c3e08 c14341a1 00000000 00000=
001 c16ebf08
[   95.988496]  d38c3e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3e34
[   95.989732]  c1056a11 00000009 00000000 d38c3e8c c1150db8 d38b6780 fffff=
fff ffffffff
[   95.995444] Call Trace:
[   95.995800]  [<c14341a1>] dump_stack+0x78/0xa8
[   95.996428]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.001561]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.002164]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.002725]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.003229]  [<c10537ff>] mmput+0x52/0xef
[   96.010495]  [<c1175602>] flush_old_exec+0x923/0x99d
[   96.011222]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   96.011905]  [<c108559f>] ? local_clock+0x2f/0x39
[   96.012460]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   96.013158]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   96.020636]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   96.021428]  [<c11762eb>] do_execve+0x19/0x1b
[   96.022021]  [<c1176586>] SyS_execve+0x21/0x25
[   96.022629]  [<c143be92>] syscall_call+0x7/0x7
[   96.023235] ---[ end trace 6a7094e9a1d04da6 ]---
[   96.059637] ------------[ cut here ]------------
[   96.064680] WARNING: CPU: 0 PID: 792 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.065752] Modules linked in:
[   96.066186] CPU: 0 PID: 792 Comm: rm Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   96.071613]  00000001 00000000 000000c8 d38c3ea8 c14341a1 00000000 00000=
000 c16ebf08
[   96.072687]  d38c3ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38c3ed4
[   96.078240]  c1056a11 00000009 00000000 d38c3f2c c1150db8 d38a2700 fffff=
fff ffffffff
[   96.079444] Call Trace:
[   96.079772]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.087189]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.087981]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.088616]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.089220]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.089738]  [<c10537ff>] mmput+0x52/0xef
[   96.096985]  [<c105955b>] do_exit+0x5bc/0xee9
[   96.097544]  [<c143becb>] ? restore_all+0xf/0xf
[   96.101567]  [<c1059fe4>] do_group_exit+0x113/0x113
[   96.102225]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   96.102836]  [<c143be92>] syscall_call+0x7/0x7
[   96.111201] ---[ end trace 6a7094e9a1d04da7 ]---
[   96.139461] ------------[ cut here ]------------
[   96.146877] WARNING: CPU: 1 PID: 793 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.151452] Modules linked in:
[   96.151840] CPU: 1 PID: 793 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   96.153088]  00000001 00000000 000000c9 d3893e08 c14341a1 00000000 00000=
001 c16ebf08
[   96.161906]  d3893e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893e34
[   96.163177]  c1056a11 00000009 00000000 d3893e8c c1150db8 d38d3480 fffff=
fff ffffffff
[   96.172279] Call Trace:
[   96.172646]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.173289]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.180712]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.184798]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.185466]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.187869]  [<c10537ff>] mmput+0x52/0xef
[   96.188392]  [<c1175602>] flush_old_exec+0x923/0x99d
[   96.189114]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   96.189730]  [<c108559f>] ? local_clock+0x2f/0x39
[   96.198332]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   96.199128]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   96.199792]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   96.208203]  [<c11762eb>] do_execve+0x19/0x1b
[   96.208766]  [<c1176586>] SyS_execve+0x21/0x25
[   96.209411]  [<c143be92>] syscall_call+0x7/0x7
[   96.217911] ---[ end trace 6a7094e9a1d04da8 ]---
[   96.236142] ------------[ cut here ]------------
[   96.236852] WARNING: CPU: 1 PID: 793 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.245611] Modules linked in:
[   96.246095] CPU: 1 PID: 793 Comm: ln Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   96.251585]  00000001 00000000 000000ca d3893ea8 c14341a1 00000000 00000=
001 c16ebf08
[   96.252700]  d3893ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893ed4
[   96.263813]  c1056a11 00000009 00000000 d3893f2c c1150db8 d3812b80 fffff=
fff ffffffff
[   96.267356] Call Trace:
[   96.270213]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.270786]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.273923]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.277938]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.278547]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.281367]  [<c10537ff>] mmput+0x52/0xef
[   96.281901]  [<c105955b>] do_exit+0x5bc/0xee9
[   96.282497]  [<c143becb>] ? restore_all+0xf/0xf
[   96.283108]  [<c1059fe4>] do_group_exit+0x113/0x113
[   96.293892]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   96.297383]  [<c143be92>] syscall_call+0x7/0x7
[   96.300308] ---[ end trace 6a7094e9a1d04da9 ]---
[   96.328090] ------------[ cut here ]------------
[   96.328706] WARNING: CPU: 1 PID: 794 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.329837] Modules linked in:
[   96.330307] CPU: 1 PID: 794 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   96.341656]  00000001 00000000 000000cb d3871e08 c14341a1 00000000 00000=
001 c16ebf08
[   96.342884]  d3871e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3871e34
[   96.344053]  c1056a11 00000009 00000000 d3871e8c c1150db8 d384ac00 fffff=
fff ffffffff
[   96.352168] Call Trace:
[   96.352519]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.353102]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.360547]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.363651]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.364227]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.370412]  [<c10537ff>] mmput+0x52/0xef
[   96.370931]  [<c1175602>] flush_old_exec+0x923/0x99d
[   96.373942]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   96.375059]  [<c108559f>] ? local_clock+0x2f/0x39
[   96.375674]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   96.376506]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   96.385071]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   96.385737]  [<c11762eb>] do_execve+0x19/0x1b
[   96.391377]  [<c1176586>] SyS_execve+0x21/0x25
[   96.391905]  [<c143be92>] syscall_call+0x7/0x7
[   96.392501] ---[ end trace 6a7094e9a1d04daa ]---
[   96.442840] ------------[ cut here ]------------
[   96.451300] WARNING: CPU: 0 PID: 794 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.452365] Modules linked in:
[   96.452781] CPU: 0 PID: 794 Comm: readlink Tainted: G        W      3.19=
=2E0-rc5-gf7a7b53 #19
[   96.460518]  00000001 00000000 000000cc d3871ea8 c14341a1 00000000 00000=
000 c16ebf08
[   96.462608]  d3871ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3871ed4
[   96.470437]  c1056a11 00000009 00000000 d3871f2c c1150db8 d382d000 fffff=
fff ffffffff
[   96.473989] Call Trace:
[   96.476510]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.478188]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.478904]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.479446]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.487762]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.488353]  [<c10537ff>] mmput+0x52/0xef
[   96.488864]  [<c105955b>] do_exit+0x5bc/0xee9
[   96.491498]  [<c143becb>] ? restore_all+0xf/0xf
[   96.492072]  [<c1059fe4>] do_group_exit+0x113/0x113
[   96.492732]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   96.505357]  [<c143be92>] syscall_call+0x7/0x7
[   96.505959] ---[ end trace 6a7094e9a1d04dab ]---
[   96.529821] ------------[ cut here ]------------
[   96.530507] WARNING: CPU: 0 PID: 795 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.541762] Modules linked in:
[   96.542197] CPU: 0 PID: 795 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   96.543168]  00000001 00000000 000000cd d3893e08 c14341a1 00000000 00000=
000 c16ebf08
[   96.550887]  d3893e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893e34
[   96.556843]  c1056a11 00000009 00000000 d3893e8c c1150db8 d38b6780 fffff=
fff ffffffff
[   96.562553] Call Trace:
[   96.562845]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.563397]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.564003]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.564538]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.575203]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.575781]  [<c10537ff>] mmput+0x52/0xef
[   96.576253]  [<c1175602>] flush_old_exec+0x923/0x99d
[   96.576881]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   96.577578]  [<c108559f>] ? local_clock+0x2f/0x39
[   96.578134]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   96.589143]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   96.589742]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   96.590396]  [<c11762eb>] do_execve+0x19/0x1b
[   96.590897]  [<c1176586>] SyS_execve+0x21/0x25
[   96.591495]  [<c143be92>] syscall_call+0x7/0x7
[   96.605649] ---[ end trace 6a7094e9a1d04dac ]---
[   96.630225] ------------[ cut here ]------------
[   96.630797] WARNING: CPU: 1 PID: 795 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.641938] Modules linked in:
[   96.642545] CPU: 1 PID: 795 Comm: uname Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   96.643606]  00000001 00000000 000000ce d3893ea8 c14341a1 00000000 00000=
001 c16ebf08
[   96.644629]  d3893ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893ed4
[   96.652784]  c1056a11 00000009 00000000 d3893f2c c1150db8 d38a2700 fffff=
fff ffffffff
[   96.653922] Call Trace:
[   96.654264]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.654790]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.665791]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.666402]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.667064]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.667580]  [<c10537ff>] mmput+0x52/0xef
[   96.668074]  [<c105955b>] do_exit+0x5bc/0xee9
[   96.678943]  [<c143becb>] ? restore_all+0xf/0xf
[   96.679554]  [<c1059fe4>] do_group_exit+0x113/0x113
[   96.680201]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   96.680737]  [<c143be92>] syscall_call+0x7/0x7
[   96.681275] ---[ end trace 6a7094e9a1d04dad ]---
[   96.698956] ------------[ cut here ]------------
[   96.699602] WARNING: CPU: 1 PID: 796 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.708464] Modules linked in:
[   96.708916] CPU: 1 PID: 796 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   96.709889]  00000001 00000000 000000cf d3871e08 c14341a1 00000000 00000=
001 c16ebf08
[   96.718828]  d3871e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3871e34
[   96.719878]  c1056a11 00000009 00000000 d3871e8c c1150db8 d38d3480 fffff=
fff ffffffff
[   96.728807] Call Trace:
[   96.729098]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.729588]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.737992]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.738630]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.739230]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.739729]  [<c10537ff>] mmput+0x52/0xef
[   96.746289]  [<c1175602>] flush_old_exec+0x923/0x99d
[   96.748028]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   96.748673]  [<c108559f>] ? local_clock+0x2f/0x39
[   96.749265]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   96.749980]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   96.758668]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   96.762514]  [<c11762eb>] do_execve+0x19/0x1b
[   96.763025]  [<c1176586>] SyS_execve+0x21/0x25
[   96.763577]  [<c143be92>] syscall_call+0x7/0x7
[   96.764148] ---[ end trace 6a7094e9a1d04dae ]---
[   96.768389] ------------[ cut here ]------------
[   96.769115] WARNING: CPU: 0 PID: 796 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.770302] Modules linked in:
[   96.770720] CPU: 0 PID: 796 Comm: mount Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   96.771828]  00000001 00000000 000000d0 d3871ea8 c14341a1 00000000 00000=
000 c16ebf08
[   96.772910]  d3871ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3871ed4
[   96.773937]  c1056a11 00000009 00000000 d3871f2c c1150db8 d3812b80 fffff=
fff ffffffff
[   96.774980] Call Trace:
[   96.775310]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.775896]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.776629]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.777277]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.782314]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.782840]  [<c10537ff>] mmput+0x52/0xef
[   96.783301]  [<c105955b>] do_exit+0x5bc/0xee9
[   96.783802]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   96.791174]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   96.791824]  [<c143becb>] ? restore_all+0xf/0xf
[   96.792449]  [<c1059fe4>] do_group_exit+0x113/0x113
[   96.793104]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   96.793755]  [<c143be92>] syscall_call+0x7/0x7
[   96.804728] ---[ end trace 6a7094e9a1d04daf ]---
[   96.808173] ------------[ cut here ]------------
[   96.808918] WARNING: CPU: 1 PID: 797 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.809877] Modules linked in:
[   96.810294] CPU: 1 PID: 797 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   96.811318]  00000001 00000000 000000d1 d3893e08 c14341a1 00000000 00000=
001 c16ebf08
[   96.812640]  d3893e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893e34
[   96.813812]  c1056a11 00000009 00000000 d3893e8c c1150db8 d3832600 fffff=
fff ffffffff
[   96.814958] Call Trace:
[   96.815317]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.815972]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.816575]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.817141]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.817737]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.818357]  [<c10537ff>] mmput+0x52/0xef
[   96.825830]  [<c1175602>] flush_old_exec+0x923/0x99d
[   96.826502]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   96.827212]  [<c108559f>] ? local_clock+0x2f/0x39
[   96.827764]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   96.838596]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   96.839314]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   96.839892]  [<c11762eb>] do_execve+0x19/0x1b
[   96.840419]  [<c1176586>] SyS_execve+0x21/0x25
[   96.840928]  [<c143be92>] syscall_call+0x7/0x7
[   96.841528] ---[ end trace 6a7094e9a1d04db0 ]---
[   96.855673] ------------[ cut here ]------------
[   96.856230] WARNING: CPU: 0 PID: 797 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.857310] Modules linked in:
[   96.857729] CPU: 0 PID: 797 Comm: mount Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   96.858669]  00000001 00000000 000000d2 d3893ea8 c14341a1 00000000 00000=
000 c16ebf08
[   96.859734]  d3893ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3893ed4
[   96.860797]  c1056a11 00000009 00000000 d3893f2c c1150db8 d384a880 fffff=
fff ffffffff
[   96.861893] Call Trace:
[   96.862214]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.862732]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.863412]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.863976]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.864728]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.865292]  [<c10537ff>] mmput+0x52/0xef
[   96.865792]  [<c105955b>] do_exit+0x5bc/0xee9
[   96.866320]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   96.866923]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   96.867472]  [<c143becb>] ? restore_all+0xf/0xf
[   96.877433]  [<c1059fe4>] do_group_exit+0x113/0x113
[   96.884796]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   96.885381]  [<c143be92>] syscall_call+0x7/0x7
[   96.885890] ---[ end trace 6a7094e9a1d04db1 ]---
[   96.896321] ------------[ cut here ]------------
[   96.896884] WARNING: CPU: 1 PID: 798 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   96.897914] Modules linked in:
[   96.898352] CPU: 1 PID: 798 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   96.899691]  00000001 00000000 000000d3 d3871e08 c14341a1 00000000 00000=
001 c16ebf08
[   96.900914]  d3871e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3871e34
[   96.912255]  c1056a11 00000009 00000000 d3871e8c c1150db8 d38b6780 fffff=
fff ffffffff
[   96.913436] Call Trace:
[   96.913724]  [<c14341a1>] dump_stack+0x78/0xa8
[   96.914240]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   96.914867]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   96.924686]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   96.925317]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   96.925922]  [<c10537ff>] mmput+0x52/0xef
[   96.926448]  [<c1175602>] flush_old_exec+0x923/0x99d
[   96.934875]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   96.935535]  [<c108559f>] ? local_clock+0x2f/0x39
[   96.936144]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   96.944771]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   96.945563]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   96.946290]  [<c11762eb>] do_execve+0x19/0x1b
[   96.954665]  [<c1176586>] SyS_execve+0x21/0x25
[   96.955302]  [<c143be92>] syscall_call+0x7/0x7
[   96.955945] ---[ end trace 6a7094e9a1d04db2 ]---
mount: / is busy
[   97.012597] ------------[ cut here ]------------
[   97.013128] WARNING: CPU: 0 PID: 798 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   97.014143] Modules linked in:

[   97.025633] CPU: 0 PID: 798 Comm: mount Tainted: G        W      3.19.0-=
rc5-gf7a7b53 #19
[   97.026665]  00000001 00000000 000000d4 d3871ea8 c14341a1 00000000 00000=
000 c16ebf08
[   97.027727]  d3871ec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3871ed4
[   97.039071]  c1056a11 00000009 00000000 d3871f2c c1150db8 d38b6d00 fffff=
fff ffffffff
[   97.040099] Call Trace:
[   97.040396]  [<c14341a1>] dump_stack+0x78/0xa8
[   97.040886]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   97.041492]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   97.052275]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   97.052845]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   97.053387]  [<c10537ff>] mmput+0x52/0xef
[   97.053900]  [<c105955b>] do_exit+0x5bc/0xee9
[   97.054506]  [<c116dd59>] ? fsnotify_modify+0x7f/0x8a
[   97.062253]  [<c116e3b1>] ? vfs_write+0x183/0x194
[   97.062852]  [<c143becb>] ? restore_all+0xf/0xf
[   97.063463]  [<c1059fe4>] do_group_exit+0x113/0x113
[   97.064003]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   97.064574]  [<c143be92>] syscall_call+0x7/0x7
[   97.065066] ---[ end trace 6a7094e9a1d04db3 ]---
[   97.081297] ------------[ cut here ]------------
[   97.081940] WARNING: CPU: 0 PID: 762 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   97.083079] Modules linked in:
[   97.093603] CPU: 0 PID: 762 Comm: S60umountroot Tainted: G        W     =
 3.19.0-rc5-gf7a7b53 #19
[   97.097169]  00000001 00000000 000000d5 d38afea8 c14341a1 00000000 00000=
000 c16ebf08
[   97.099569]  d38afec4 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d38afed4
[   97.105180]  c1056a11 00000009 00000000 d38aff2c c1150db8 d3895a00 fffff=
fff ffffffff
[   97.106212] Call Trace:
[   97.106495]  [<c14341a1>] dump_stack+0x78/0xa8
[   97.114798]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   97.115475]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   97.116000]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   97.116560]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   97.124863]  [<c10537ff>] mmput+0x52/0xef
[   97.125373]  [<c105955b>] do_exit+0x5bc/0xee9
[   97.125876]  [<c116e776>] ? __vfs_read+0x32/0x9a
[   97.126389]  [<c143becb>] ? restore_all+0xf/0xf
[   97.133660]  [<c1059fe4>] do_group_exit+0x113/0x113
[   97.137740]  [<c1059ffa>] SyS_exit_group+0x16/0x16
[   97.138299]  [<c143be92>] syscall_call+0x7/0x7
[   97.138914] ---[ end trace 6a7094e9a1d04db4 ]---
[   97.168243] ------------[ cut here ]------------
[   97.168811] WARNING: CPU: 0 PID: 799 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   97.169758] Modules linked in:
[   97.170143] CPU: 0 PID: 799 Comm: rc Tainted: G        W      3.19.0-rc5=
-gf7a7b53 #19
[   97.170987]  00000001 00000000 000000d6 d3849d4c c14341a1 00000000 00000=
000 c16ebf08
[   97.171989]  d3849d68 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3849d78
[   97.180085]  c1056a11 00000009 00000000 d3849dd0 c1150db8 d38d3480 fffff=
fff ffffffff
[   97.181098] Call Trace:
[   97.181385]  [<c14341a1>] dump_stack+0x78/0xa8
[   97.181897]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   97.182505]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   97.183052]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   97.190426]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   97.191048]  [<c10537ff>] mmput+0x52/0xef
[   97.191619]  [<c1175602>] flush_old_exec+0x923/0x99d
[   97.192254]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   97.192839]  [<c108559f>] ? local_clock+0x2f/0x39
[   97.200126]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   97.200974]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   97.201704]  [<c11ac7e5>] load_script+0x339/0x355
[   97.202231]  [<c108550c>] ? sched_clock_cpu+0x188/0x1a3
[   97.202825]  [<c108559f>] ? local_clock+0x2f/0x39
[   97.210111]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   97.210822]  [<c109c1bf>] ? do_raw_read_unlock+0x28/0x53
[   97.211435]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   97.212137]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   97.212847]  [<c11762eb>] do_execve+0x19/0x1b
[   97.220155]  [<c1176586>] SyS_execve+0x21/0x25
[   97.220657]  [<c143be92>] syscall_call+0x7/0x7
[   97.221158] ---[ end trace 6a7094e9a1d04db5 ]---
 * Will now restart
[   97.273641] ------------[ cut here ]------------
[   97.274169] WARNING: CPU: 1 PID: 800 at mm/mmap.c:2858 exit_mmap+0x197/0=
x1ad()
[   97.275155] Modules linked in:
[   97.275574] CPU: 1 PID: 800 Comm: S90reboot Tainted: G        W      3.1=
9.0-rc5-gf7a7b53 #19
[   97.276714]  00000001 00000000 000000d7 d3871e08 c14341a1 00000000 00000=
001 c16ebf08
[   97.277876]  d3871e24 c1056987 00000b2a c1150db8 00000001 00000001 00000=
000 d3871e34
[   97.291031]  c1056a11 00000009 00000000 d3871e8c c1150db8 d38b6780 fffff=
fff ffffffff
[   97.292058] Call Trace:
[   97.292355]  [<c14341a1>] dump_stack+0x78/0xa8
[   97.292864]  [<c1056987>] warn_slowpath_common+0xb7/0xce
[   97.296912]  [<c1150db8>] ? exit_mmap+0x197/0x1ad
[   97.297525]  [<c1056a11>] warn_slowpath_null+0x14/0x18
[   97.298217]  [<c1150db8>] exit_mmap+0x197/0x1ad
[   97.298793]  [<c10537ff>] mmput+0x52/0xef
[   97.299284]  [<c1175602>] flush_old_exec+0x923/0x99d
[   97.299879]  [<c11aea1e>] load_elf_binary+0x430/0x11af
[   97.307385]  [<c108559f>] ? local_clock+0x2f/0x39
[   97.308055]  [<c109817f>] ? lock_release_holdtime+0x60/0x6d
[   97.308828]  [<c1174159>] search_binary_handler+0x9c/0x20f
[   97.309436]  [<c1176054>] do_execveat_common+0x6d6/0x954
[   97.316776]  [<c11762eb>] do_execve+0x19/0x1b
[   97.317274]  [<c1176586>] SyS_execve+0x21/0x25
[   97.317763]  [<c143be92>] syscall_call+0x7/0x7
[   97.318256] ---[ end trace 6a7094e9a1d04db6 ]---
[   97.352582] Unregister pv shared memory for cpu 1
[   97.360083] Unregister pv shared memory for cpu 0
[   97.360648] spin_lock-torture: Unscheduled system shutdown detected
[   97.375011] torture thread torture_stutter parking due to system shutdown
[   97.375786] torture thread lock_torture_writer parking due to system shu=
tdown
[   97.376556] torture thread lock_torture_writer parking due to system shu=
tdown
[   97.377355] torture thread lock_torture_writer parking due to system shu=
tdown
[   97.378148] torture thread lock_torture_writer parking due to system shu=
tdown
[   97.378962] torture thread torture_shuffle parking due to system shutdown
[   97.394438] reboot: Restarting system
[   97.394879] reboot: machine restart
Elapsed time: 110
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-x=
1-01141042/f7a7b53a90f7a489c4e435d1300db121f6b42776/vmlinuz-3.19.0-rc5-gf7a=
7b53 -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug apic=3Dd=
ebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D-1 s=
oftlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 prom=
pt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/=
dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-x1-01141042/=
next:master:f7a7b53a90f7a489c4e435d1300db121f6b42776:bisect-linux-3/.vmlinu=
z-f7a7b53a90f7a489c4e435d1300db121f6b42776-20150124093102-332-client9 branc=
h=3Dnext/master BOOT_IMAGE=3D/kernel/i386-randconfig-x1-01141042/f7a7b53a90=
f7a489c4e435d1300db121f6b42776/vmlinuz-3.19.0-rc5-gf7a7b53 drbd.minor_count=
=3D8'  -initrd /kernel-tests/initrd/quantal-core-i386.cgz -m 320 -smp 2 -ne=
t nic,vlan=3D1,model=3De1000 -net user,vlan=3D1 -boot order=3Dnc -no-reboot=
 -watchdog i6300esb -rtc base=3Dlocaltime -pidfile /dev/shm/kboot/pid-quant=
al-client9-17 -serial file:/dev/shm/kboot/serial-quantal-client9-17 -daemon=
ize -display none -monitor null=20

--jq0ap7NbKX2Kqbes
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.19.0-rc5-gf7a7b53"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.19.0-rc5 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
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
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
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
CONFIG_SYSVIPC=y
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
CONFIG_IRQ_DOMAIN_DEBUG=y
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
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ=y
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
# CONFIG_TASKS_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_TREE_RCU_TRACE=y
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
CONFIG_IPC_NS=y
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
# CONFIG_RD_LZ4 is not set
CONFIG_INIT_FALLBACK=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
# CONFIG_SGETMASK_SYSCALL is not set
CONFIG_SYSFS_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
# CONFIG_EPOLL is not set
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
# CONFIG_BPF_SYSCALL is not set
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_ADVISE_SYSCALLS=y
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
CONFIG_SYSTEM_TRUSTED_KEYRING=y
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
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
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
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
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
# CONFIG_MODULE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
CONFIG_MODULE_SRCVERSION_ALL=y
CONFIG_MODULE_SIG=y
CONFIG_MODULE_SIG_FORCE=y
CONFIG_MODULE_SIG_ALL=y
CONFIG_MODULE_SIG_SHA1=y
# CONFIG_MODULE_SIG_SHA224 is not set
# CONFIG_MODULE_SIG_SHA256 is not set
# CONFIG_MODULE_SIG_SHA384 is not set
# CONFIG_MODULE_SIG_SHA512 is not set
CONFIG_MODULE_SIG_HASH="sha1"
CONFIG_MODULE_COMPRESS=y
CONFIG_MODULE_COMPRESS_GZIP=y
# CONFIG_MODULE_COMPRESS_XZ is not set
# CONFIG_BLOCK is not set
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUE_RWLOCK=y
CONFIG_QUEUE_RWLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_BIGSMP=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_IOSF_MBI is not set
# CONFIG_X86_RDC321X is not set
CONFIG_X86_32_NON_STANDARD=y
# CONFIG_STA2X11 is not set
CONFIG_X86_32_IRIS=y
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
# CONFIG_MEMTEST is not set
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
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
CONFIG_MVIAC3_2=y
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_ALIGNMENT_16=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
CONFIG_CPU_SUP_INTEL=y
# CONFIG_CPU_SUP_CYRIX_32 is not set
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
# CONFIG_CPU_SUP_UMC_32 is not set
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
CONFIG_NR_CPUS=32
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
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX32=y
CONFIG_TOSHIBA=m
# CONFIG_I8K is not set
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
# CONFIG_MICROCODE_EARLY is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
# CONFIG_NOHIGHMEM is not set
# CONFIG_HIGHMEM4G is not set
CONFIG_HIGHMEM64G=y
CONFIG_VMSPLIT_3G=y
# CONFIG_VMSPLIT_2G is not set
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_HIGHMEM=y
CONFIG_X86_PAE=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
# CONFIG_NUMA is not set
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
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_MEMORY_BALLOON=y
# CONFIG_COMPACTION is not set
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_CLEANCACHE is not set
# CONFIG_CMA is not set
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=m
CONFIG_ZSMALLOC=m
# CONFIG_PGTABLE_MAPPING is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_HIGHPTE=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
# CONFIG_X86_SMAP is not set
# CONFIG_X86_INTEL_MPX is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_HOTPLUG_CPU is not set
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_PM is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
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
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
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
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
# CONFIG_CPU_FREQ_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=m

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
CONFIG_X86_POWERNOW_K6=y
# CONFIG_X86_POWERNOW_K7 is not set
# CONFIG_X86_GX_SUSPMOD is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_SPEEDSTEP_ICH=y
CONFIG_X86_SPEEDSTEP_SMI=m
# CONFIG_X86_P4_CLOCKMOD is not set
# CONFIG_X86_CPUFREQ_NFORCE2 is not set
CONFIG_X86_LONGRUN=m
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
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
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
# CONFIG_SCx200 is not set
CONFIG_ALIX=y
# CONFIG_NET5501 is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=m
CONFIG_PCMCIA=m
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
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
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
# CONFIG_NET_MPLS_GSO is not set
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
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
# CONFIG_ALLOW_DEV_COREDUMP is not set
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
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
# CONFIG_PARPORT_SERIAL is not set
CONFIG_PARPORT_PC_FIFO=y
CONFIG_PARPORT_PC_SUPERIO=y
CONFIG_PARPORT_PC_PCMCIA=m
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=m
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
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
# CONFIG_ISL29003 is not set
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=m
CONFIG_SENSORS_BH1780=m
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=m
CONFIG_HMC6352=m
CONFIG_DS1682=m
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
CONFIG_EEPROM_AT24=m
CONFIG_EEPROM_LEGACY=m
CONFIG_EEPROM_MAX6875=y
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=m
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
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
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_NETDEVICES is not set
# CONFIG_VHOST_NET is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

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
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_ELAN_I2C is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_GPIO is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
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
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=m
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

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
# CONFIG_DEVKMEM is not set

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
# CONFIG_SERIAL_8250_CS is not set
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
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_MEN_Z135 is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=m
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=m
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
# CONFIG_IPMI_DEVICE_INTERFACE is not set
CONFIG_IPMI_SI=m
CONFIG_IPMI_SI_PROBE_DEFAULTS=y
CONFIG_IPMI_SSIF=y
# CONFIG_IPMI_WATCHDOG is not set
# CONFIG_IPMI_POWEROFF is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
CONFIG_NSC_GPIO=m
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_TCG_TPM=m
CONFIG_TCG_TIS=m
# CONFIG_TCG_TIS_I2C_ATMEL is not set
CONFIG_TCG_TIS_I2C_INFINEON=m
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_ST33_I2C is not set
CONFIG_TELCLOCK=m
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=m

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_PCA9541 is not set
CONFIG_I2C_MUX_PCA954x=m
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=m
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=m

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
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_GPIO is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=m
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_CROS_EC_TUNNEL is not set
# CONFIG_SCx200_ACB is not set
# CONFIG_I2C_STUB is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_SPMI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=m
CONFIG_PPS_CLIENT_GPIO=y

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
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=m
CONFIG_GPIO_DA9052=m
# CONFIG_GPIO_DA9055 is not set

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=m
CONFIG_GPIO_IT8761E=m
# CONFIG_GPIO_F7188X is not set
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_MAX7300 is not set
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_RC5T583 is not set
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TC3589X=y
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_WM831X=y
CONFIG_GPIO_WM8994=m
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
# CONFIG_GPIO_MCP23S08 is not set

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#

#
# MODULbus GPIO expanders:
#

#
# USB GPIO expanders:
#
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=m
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2406=y
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=m
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2760=y
# CONFIG_W1_SLAVE_DS2780 is not set
CONFIG_W1_SLAVE_DS2781=m
CONFIG_W1_SLAVE_DS28E04=m
CONFIG_W1_SLAVE_BQ27000=m
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_88PM860X is not set
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_DA9030 is not set
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_MAX14577 is not set
# CONFIG_CHARGER_MAX8997 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=m
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=m
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DA9052_ADC=m
# CONFIG_SENSORS_DA9055 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_FSCHMD=m
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=m
CONFIG_SENSORS_G760A=m
CONFIG_SENSORS_G762=m
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_IBMAEM is not set
CONFIG_SENSORS_IBMPEX=m
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=m
CONFIG_SENSORS_POWR1220=m
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LTC2945=m
CONFIG_SENSORS_LTC4151=m
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4222 is not set
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=m
CONFIG_SENSORS_MAX16065=m
CONFIG_SENSORS_MAX1619=m
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=m
CONFIG_SENSORS_MAX6639=m
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_MAX6697=m
CONFIG_SENSORS_HTU21=m
CONFIG_SENSORS_MCP3021=m
# CONFIG_SENSORS_MENF21BMC_HWMON is not set
CONFIG_SENSORS_LM63=m
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_LM95234=m
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=m
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_NTC_THERMISTOR=m
CONFIG_SENSORS_NCT6683=m
CONFIG_SENSORS_NCT6775=m
CONFIG_SENSORS_NCT7802=m
CONFIG_SENSORS_PCF8591=m
CONFIG_PMBUS=m
CONFIG_SENSORS_PMBUS=m
CONFIG_SENSORS_ADM1275=m
CONFIG_SENSORS_LM25066=m
# CONFIG_SENSORS_LTC2978 is not set
CONFIG_SENSORS_MAX16064=m
# CONFIG_SENSORS_MAX34440 is not set
CONFIG_SENSORS_MAX8688=m
CONFIG_SENSORS_TPS40422=m
CONFIG_SENSORS_UCD9000=m
CONFIG_SENSORS_UCD9200=m
# CONFIG_SENSORS_ZL6100 is not set
CONFIG_SENSORS_SHT15=m
CONFIG_SENSORS_SHT21=m
CONFIG_SENSORS_SHTC1=m
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=m
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=m
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
CONFIG_SENSORS_SCH56XX_COMMON=m
CONFIG_SENSORS_SCH5627=m
CONFIG_SENSORS_SCH5636=m
CONFIG_SENSORS_SMM665=m
# CONFIG_SENSORS_ADC128D818 is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=m
CONFIG_SENSORS_TMP103=m
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=m
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_WM831X=m

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_EMULATION=y
# CONFIG_INTEL_POWERCLAMP is not set
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
CONFIG_SOFT_WATCHDOG=m
CONFIG_DA9052_WATCHDOG=y
CONFIG_DA9055_WATCHDOG=y
CONFIG_DA9063_WATCHDOG=y
CONFIG_MENF21BMC_WATCHDOG=y
# CONFIG_WM831X_WATCHDOG is not set
CONFIG_XILINX_WATCHDOG=m
CONFIG_DW_WATCHDOG=m
CONFIG_RETU_WATCHDOG=m
CONFIG_ACQUIRE_WDT=m
CONFIG_ADVANTECH_WDT=m
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_F71808E_WDT=m
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=m
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=m
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=m
CONFIG_IT87_WDT=m
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
CONFIG_PC87413_WDT=m
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=m
CONFIG_SBC8360_WDT=y
CONFIG_SBC7240_WDT=m
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=m
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
CONFIG_W83877F_WDT=y
# CONFIG_W83977F_WDT is not set
CONFIG_MACHZ_WDT=m
CONFIG_SBC_EPX_C3_WATCHDOG=y
# CONFIG_MEN_A21_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set
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
CONFIG_MFD_BCM590XX=m
CONFIG_MFD_AXP20X=y
CONFIG_MFD_CROS_EC=m
CONFIG_MFD_CROS_EC_I2C=m
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9063=y
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=m
CONFIG_HTC_I2CPLD=y
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=m
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77686=y
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MENF21BMC=y
CONFIG_MFD_RETU=m
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_RN5T618 is not set
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=m
CONFIG_MFD_SM501_GPIO=y
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
CONFIG_AB3100_OTP=y
# CONFIG_MFD_SYSCON is not set
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=m
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
CONFIG_MFD_TPS65218=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS80031=y
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=m
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=m
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=m
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=m
CONFIG_REGULATOR_88PM800=m
CONFIG_REGULATOR_88PM8607=m
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_AD5398=m
# CONFIG_REGULATOR_AAT2870 is not set
CONFIG_REGULATOR_AB3100=m
CONFIG_REGULATOR_AXP20X=y
CONFIG_REGULATOR_BCM590XX=m
CONFIG_REGULATOR_DA903X=m
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_DA9055 is not set
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
# CONFIG_REGULATOR_FAN53555 is not set
CONFIG_REGULATOR_GPIO=m
CONFIG_REGULATOR_ISL9305=m
CONFIG_REGULATOR_ISL6271A=m
CONFIG_REGULATOR_LP3971=m
# CONFIG_REGULATOR_LP3972 is not set
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8997=m
CONFIG_REGULATOR_MAX77686=y
CONFIG_REGULATOR_MAX77802=y
CONFIG_REGULATOR_PFUZE100=y
# CONFIG_REGULATOR_RC5T583 is not set
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS6105X=m
CONFIG_REGULATOR_TPS62360=m
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=m
CONFIG_REGULATOR_TPS65912=m
CONFIG_REGULATOR_TPS80031=m
# CONFIG_REGULATOR_WM831X is not set
CONFIG_REGULATOR_WM8400=y
CONFIG_REGULATOR_WM8994=m
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
# CONFIG_MEDIA_RADIO_SUPPORT is not set
CONFIG_MEDIA_SDR_SUPPORT=y
# CONFIG_MEDIA_RC_SUPPORT is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_V4L2_MEM2MEM_DEV=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
# CONFIG_MEDIA_PCI_SUPPORT is not set
CONFIG_V4L_PLATFORM_DRIVERS=y
# CONFIG_VIDEO_CAFE_CCIC is not set
# CONFIG_SOC_CAMERA is not set
CONFIG_V4L_MEM2MEM_DRIVERS=y
# CONFIG_VIDEO_MEM2MEM_DEINTERLACE is not set
# CONFIG_VIDEO_SH_VEU is not set
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIVID=m
CONFIG_VIDEO_VIM2M=m

#
# Supported MMC/SDIO adapters
#

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set

#
# Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
# CONFIG_VIDEO_TVAUDIO is not set
# CONFIG_VIDEO_TDA7432 is not set
CONFIG_VIDEO_TDA9840=m
# CONFIG_VIDEO_TEA6415C is not set
CONFIG_VIDEO_TEA6420=m
CONFIG_VIDEO_MSP3400=y
CONFIG_VIDEO_CS5345=m
# CONFIG_VIDEO_CS53L32A is not set
CONFIG_VIDEO_TLV320AIC23B=m
CONFIG_VIDEO_UDA1342=y
CONFIG_VIDEO_WM8775=y
CONFIG_VIDEO_WM8739=y
CONFIG_VIDEO_VP27SMPX=m
CONFIG_VIDEO_SONY_BTF_MPX=y

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_ADV7180=y
# CONFIG_VIDEO_ADV7183 is not set
CONFIG_VIDEO_BT819=m
CONFIG_VIDEO_BT856=m
CONFIG_VIDEO_BT866=y
CONFIG_VIDEO_KS0127=m
# CONFIG_VIDEO_ML86V7667 is not set
CONFIG_VIDEO_SAA7110=y
CONFIG_VIDEO_SAA711X=y
CONFIG_VIDEO_TVP514X=y
CONFIG_VIDEO_TVP5150=m
CONFIG_VIDEO_TVP7002=y
CONFIG_VIDEO_TW2804=y
# CONFIG_VIDEO_TW9903 is not set
# CONFIG_VIDEO_TW9906 is not set
# CONFIG_VIDEO_VPX3220 is not set

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=m
# CONFIG_VIDEO_CX25840 is not set

#
# Video encoders
#
# CONFIG_VIDEO_SAA7127 is not set
# CONFIG_VIDEO_SAA7185 is not set
CONFIG_VIDEO_ADV7170=m
CONFIG_VIDEO_ADV7175=m
# CONFIG_VIDEO_ADV7343 is not set
# CONFIG_VIDEO_ADV7393 is not set
CONFIG_VIDEO_AK881X=y
CONFIG_VIDEO_THS8200=y

#
# Camera sensor devices
#
CONFIG_VIDEO_OV7640=m
CONFIG_VIDEO_OV7670=y
# CONFIG_VIDEO_VS6624 is not set
CONFIG_VIDEO_MT9V011=m
# CONFIG_VIDEO_SR030PC30 is not set

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
CONFIG_VIDEO_UPD64083=y

#
# Audio/Video compression chips
#
# CONFIG_VIDEO_SAA6752HS is not set

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=y
CONFIG_VIDEO_M52790=y

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=y
# CONFIG_MEDIA_TUNER_TEA5761 is not set
# CONFIG_MEDIA_TUNER_TEA5767 is not set
# CONFIG_MEDIA_TUNER_MT20XX is not set
CONFIG_MEDIA_TUNER_MT2060=m
# CONFIG_MEDIA_TUNER_MT2063 is not set
CONFIG_MEDIA_TUNER_MT2266=y
# CONFIG_MEDIA_TUNER_MT2131 is not set
CONFIG_MEDIA_TUNER_QT1010=m
# CONFIG_MEDIA_TUNER_XC2028 is not set
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_MEDIA_TUNER_XC4000=m
CONFIG_MEDIA_TUNER_MXL5005S=y
CONFIG_MEDIA_TUNER_MXL5007T=m
# CONFIG_MEDIA_TUNER_MC44S803 is not set
CONFIG_MEDIA_TUNER_MAX2165=y
CONFIG_MEDIA_TUNER_TDA18218=y
# CONFIG_MEDIA_TUNER_FC0011 is not set
CONFIG_MEDIA_TUNER_FC0012=m
# CONFIG_MEDIA_TUNER_FC0013 is not set
# CONFIG_MEDIA_TUNER_TDA18212 is not set
CONFIG_MEDIA_TUNER_E4000=m
CONFIG_MEDIA_TUNER_FC2580=m
# CONFIG_MEDIA_TUNER_M88TS2022 is not set
# CONFIG_MEDIA_TUNER_M88RS6000T is not set
# CONFIG_MEDIA_TUNER_TUA9001 is not set
CONFIG_MEDIA_TUNER_SI2157=m
CONFIG_MEDIA_TUNER_IT913X=m
CONFIG_MEDIA_TUNER_R820T=y
CONFIG_MEDIA_TUNER_MXL301RF=m
# CONFIG_MEDIA_TUNER_QM1D1C0042 is not set

#
# Customise DVB Frontends
#
CONFIG_DVB_AU8522=y
CONFIG_DVB_AU8522_V4L=y
# CONFIG_DVB_TUNER_DIB0070 is not set
# CONFIG_DVB_TUNER_DIB0090 is not set

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
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=m
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_ADV7511 is not set
CONFIG_DRM_I2C_CH7006=m
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_DRM_I2C_NXP_TDA998X is not set
CONFIG_DRM_PTN3460=m
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
CONFIG_FB=m
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
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
# CONFIG_FB_ARC is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_N411=m
CONFIG_FB_HGA=m
CONFIG_FB_OPENCORES=m
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
# CONFIG_FB_GEODE is not set
# CONFIG_FB_SM501 is not set
CONFIG_FB_VIRTUAL=m
CONFIG_FB_METRONOME=m
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_FB_AUO_K190X=m
CONFIG_FB_AUO_K1900=m
CONFIG_FB_AUO_K1901=m
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=m
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_LM3533=m
# CONFIG_BACKLIGHT_DA903X is not set
CONFIG_BACKLIGHT_DA9052=m
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=m
CONFIG_BACKLIGHT_WM831X=m
CONFIG_BACKLIGHT_ADP5520=m
CONFIG_BACKLIGHT_ADP8860=m
CONFIG_BACKLIGHT_ADP8870=m
# CONFIG_BACKLIGHT_88PM860X is not set
CONFIG_BACKLIGHT_AAT2870=m
CONFIG_BACKLIGHT_LM3639=m
CONFIG_BACKLIGHT_GPIO=m
CONFIG_BACKLIGHT_LV5207LP=m
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_VGASTATE is not set
CONFIG_HDMI=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
# CONFIG_LOGO_LINUX_VGA16 is not set
# CONFIG_LOGO_LINUX_CLUT224 is not set
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_DMAENGINE_PCM=m
CONFIG_SND_COMPRESS_OFFLOAD=m
CONFIG_SND_JACK=y
# CONFIG_SND_SEQUENCER is not set
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=m
CONFIG_SND_PCM_OSS=m
# CONFIG_SND_PCM_OSS_PLUGINS is not set
CONFIG_SND_HRTIMER=m
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_VERBOSE_PRINTK=y
CONFIG_SND_DEBUG=y
# CONFIG_SND_DEBUG_VERBOSE is not set
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_RAWMIDI_SEQ is not set
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
# CONFIG_SND_DRIVERS is not set
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
# CONFIG_SND_PCMCIA is not set
CONFIG_SND_SOC=m
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
CONFIG_SND_ATMEL_SOC=m

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
CONFIG_SND_SOC_FSL_ASRC=m
# CONFIG_SND_SOC_FSL_SAI is not set
# CONFIG_SND_SOC_FSL_SSI is not set
CONFIG_SND_SOC_FSL_SPDIF=m
CONFIG_SND_SOC_FSL_ESAI=m
CONFIG_SND_SOC_IMX_AUDMUX=m
CONFIG_SND_SST_MFLD_PLATFORM=m
CONFIG_SND_SST_IPC=m
CONFIG_SND_SST_IPC_ACPI=m
# CONFIG_SND_SOC_INTEL_SST is not set
CONFIG_SND_SOC_INTEL_BYTCR_RT5640_MACH=m
CONFIG_SND_SOC_I2C_AND_SPI=m

#
# CODEC drivers
#
CONFIG_SND_SOC_ADAU1701=m
CONFIG_SND_SOC_AK4554=m
CONFIG_SND_SOC_AK4642=m
CONFIG_SND_SOC_AK5386=m
# CONFIG_SND_SOC_ALC5623 is not set
CONFIG_SND_SOC_CS35L32=m
CONFIG_SND_SOC_CS42L51=m
CONFIG_SND_SOC_CS42L51_I2C=m
# CONFIG_SND_SOC_CS42L52 is not set
# CONFIG_SND_SOC_CS42L56 is not set
CONFIG_SND_SOC_CS42L73=m
CONFIG_SND_SOC_CS4265=m
CONFIG_SND_SOC_CS4270=m
# CONFIG_SND_SOC_CS4271_I2C is not set
# CONFIG_SND_SOC_CS42XX8_I2C is not set
CONFIG_SND_SOC_HDMI_CODEC=m
CONFIG_SND_SOC_ES8328=m
# CONFIG_SND_SOC_PCM1681 is not set
# CONFIG_SND_SOC_PCM512x_I2C is not set
CONFIG_SND_SOC_RL6231=m
CONFIG_SND_SOC_RT5631=m
CONFIG_SND_SOC_RT5640=m
# CONFIG_SND_SOC_RT5677_SPI is not set
# CONFIG_SND_SOC_SGTL5000 is not set
CONFIG_SND_SOC_SIGMADSP=m
CONFIG_SND_SOC_SIGMADSP_I2C=m
CONFIG_SND_SOC_SIRF_AUDIO_CODEC=m
# CONFIG_SND_SOC_SPDIF is not set
# CONFIG_SND_SOC_SSM2602_I2C is not set
CONFIG_SND_SOC_SSM4567=m
CONFIG_SND_SOC_STA350=m
CONFIG_SND_SOC_TAS2552=m
CONFIG_SND_SOC_TAS5086=m
CONFIG_SND_SOC_TFA9879=m
CONFIG_SND_SOC_TLV320AIC23=m
CONFIG_SND_SOC_TLV320AIC23_I2C=m
CONFIG_SND_SOC_TLV320AIC31XX=m
CONFIG_SND_SOC_TLV320AIC3X=m
CONFIG_SND_SOC_TS3A227E=m
# CONFIG_SND_SOC_WM8510 is not set
CONFIG_SND_SOC_WM8523=m
CONFIG_SND_SOC_WM8580=m
CONFIG_SND_SOC_WM8711=m
# CONFIG_SND_SOC_WM8728 is not set
# CONFIG_SND_SOC_WM8731 is not set
CONFIG_SND_SOC_WM8737=m
# CONFIG_SND_SOC_WM8741 is not set
CONFIG_SND_SOC_WM8750=m
CONFIG_SND_SOC_WM8753=m
CONFIG_SND_SOC_WM8776=m
# CONFIG_SND_SOC_WM8804 is not set
# CONFIG_SND_SOC_WM8903 is not set
# CONFIG_SND_SOC_WM8962 is not set
CONFIG_SND_SOC_WM8978=m
# CONFIG_SND_SOC_TPA6130A2 is not set
CONFIG_SND_SIMPLE_CARD=m
CONFIG_SOUND_PRIME=m
CONFIG_SOUND_OSS=m
CONFIG_SOUND_TRACEINIT=y
CONFIG_SOUND_DMAP=y
# CONFIG_SOUND_VMIDI is not set
CONFIG_SOUND_TRIX=m
CONFIG_SOUND_MSS=m
CONFIG_SOUND_MPU401=m
CONFIG_SOUND_PAS=m
# CONFIG_SOUND_PSS is not set
CONFIG_SOUND_SB=m
# CONFIG_SOUND_YM3812 is not set
CONFIG_SOUND_UART6850=m
# CONFIG_SOUND_AEDSP16 is not set
CONFIG_SOUND_KAHLUA=m

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_PRODIKEYS is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_RMI is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
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
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
CONFIG_MMC_CLKGATE=y

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=m

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=m
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=m
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_USDHI6ROL0=m
# CONFIG_MMC_TOSHIBA_PCI is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=m
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=m
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=m
CONFIG_LEDS_LP5523=m
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_LP8860 is not set
CONFIG_LEDS_PCA955X=m
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_WM831X_STATUS is not set
# CONFIG_LEDS_DA903X is not set
# CONFIG_LEDS_DA9052 is not set
CONFIG_LEDS_REGULATOR=m
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_LT3593=m
CONFIG_LEDS_ADP5520=y
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_MAX8997=m
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_OT200=y
CONFIG_LEDS_MENF21BMC=m

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=m

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=m
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
CONFIG_EDAC_DEBUG=y
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM860X=y
# CONFIG_RTC_DRV_88PM80X is not set
# CONFIG_RTC_DRV_DS1307 is not set
CONFIG_RTC_DRV_DS1374=y
# CONFIG_RTC_DRV_DS1374_WDT is not set
CONFIG_RTC_DRV_DS1672=m
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
CONFIG_RTC_DRV_MAX8997=y
CONFIG_RTC_DRV_MAX77686=y
CONFIG_RTC_DRV_MAX77802=y
CONFIG_RTC_DRV_RS5C372=m
CONFIG_RTC_DRV_ISL1208=m
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_ISL12057=y
CONFIG_RTC_DRV_X1205=m
CONFIG_RTC_DRV_PCF2127=m
CONFIG_RTC_DRV_PCF8523=y
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF85063 is not set
CONFIG_RTC_DRV_PCF8583=y
# CONFIG_RTC_DRV_M41T80 is not set
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_TPS80031=m
CONFIG_RTC_DRV_RC5T583=m
CONFIG_RTC_DRV_S35390A=m
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
CONFIG_RTC_DRV_EM3027=y
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=m
CONFIG_RTC_DRV_DS1286=m
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=m
CONFIG_RTC_DRV_DS1742=y
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_DA9052=m
CONFIG_RTC_DRV_DA9055=y
CONFIG_RTC_DRV_DA9063=m
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=m
CONFIG_RTC_DRV_M48T35=m
# CONFIG_RTC_DRV_M48T59 is not set
CONFIG_RTC_DRV_MSM6242=m
CONFIG_RTC_DRV_BQ4802=m
CONFIG_RTC_DRV_RP5C01=m
# CONFIG_RTC_DRV_V3020 is not set
CONFIG_RTC_DRV_WM831X=m
# CONFIG_RTC_DRV_AB3100 is not set

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_XGENE=y

#
# HID Sensor RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=m
# CONFIG_DW_DMAC_PCI is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=m
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
# CONFIG_VIRT_DRIVERS is not set
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
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_DELL_LAPTOP is not set
# CONFIG_DELL_SMO8800 is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
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
CONFIG_SOC_TI=y

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
CONFIG_IOMMU_SUPPORT=y

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
CONFIG_DEVFREQ_GOV_POWERSAVE=m
CONFIG_DEVFREQ_GOV_USERSPACE=m

#
# DEVFREQ Drivers
#
CONFIG_EXTCON=m

#
# Extcon Device Drivers
#
CONFIG_EXTCON_GPIO=m
CONFIG_EXTCON_MAX14577=m
# CONFIG_EXTCON_MAX8997 is not set
# CONFIG_EXTCON_RT8973A is not set
CONFIG_EXTCON_SM5502=m
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_IPACK_BUS=m
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
# CONFIG_RESET_CONTROLLER is not set
CONFIG_FMC=m
CONFIG_FMC_FAKEDEV=m
CONFIG_FMC_TRIVIAL=m
CONFIG_FMC_WRITE_EEPROM=m
CONFIG_FMC_CHARDEV=m

#
# PHY Subsystem
#
# CONFIG_GENERIC_PHY is not set
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_FS_POSIX_ACL is not set
CONFIG_EXPORTFS=y
# CONFIG_FILE_LOCKING is not set
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=m
# CONFIG_CUSE is not set
CONFIG_OVERLAY_FS=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# Pseudo filesystems
#
# CONFIG_PROC_FS is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
# CONFIG_TMPFS is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=m
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=m
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=m
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=m
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=m
CONFIG_NLS_MAC_CENTEURO=m
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=m
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=m
CONFIG_NLS_MAC_INUIT=m
# CONFIG_NLS_MAC_ROMANIAN is not set
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
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
CONFIG_DEBUG_VM_RB=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_PER_CPU_MAPS is not set
# CONFIG_DEBUG_HIGHMEM is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_STACK_END_CHECK=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_TORTURE_TEST=y
CONFIG_RCU_TORTURE_TEST=y
CONFIG_RCU_TORTURE_TEST_RUNNABLE=y
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_CPU_STALL_INFO=y
CONFIG_RCU_TRACE=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAIL_PAGE_ALLOC is not set
# CONFIG_FAIL_MMC_REQUEST is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
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
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_IRQSOFF_TRACER=y
# CONFIG_SCHED_TRACER is not set
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
CONFIG_PROFILE_ALL_BRANCHES=y
# CONFIG_BRANCH_TRACER is not set
# CONFIG_STACK_TRACER is not set
# CONFIG_KPROBE_EVENT is not set
# CONFIG_UPROBE_EVENT is not set
# CONFIG_PROBE_EVENTS is not set
# CONFIG_DYNAMIC_FTRACE is not set
CONFIG_FUNCTION_PROFILER=y
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
# CONFIG_TEST_LIST_SORT is not set
CONFIG_KPROBES_SANITY_TEST=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=m
CONFIG_INTERVAL_TREE_TEST=m
CONFIG_PERCPU_TEST=m
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=m
CONFIG_TEST_RHASHTABLE=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_LKM=m
# CONFIG_TEST_USER_COPY is not set
# CONFIG_TEST_BPF is not set
CONFIG_TEST_FIRMWARE=m
CONFIG_TEST_UDELAY=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP=y
# CONFIG_DEBUG_RODATA is not set
CONFIG_DEBUG_SET_MODULE_RONX=y
CONFIG_DEBUG_NX_TEST=m
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_STATIC_CPU_HAS=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_TRUSTED_KEYS is not set
CONFIG_ENCRYPTED_KEYS=m
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
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
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=m
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=m
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=m
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=m
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_VMAC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=m
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_CRC32=m
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=m
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=m
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=m
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAST_COMMON=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_FCRYPT=m
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_586=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
CONFIG_CRYPTO_TEA=m
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
# CONFIG_CRYPTO_ZLIB is not set
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=m
# CONFIG_CRYPTO_DRBG_HMAC is not set
# CONFIG_CRYPTO_DRBG_HASH is not set
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=m
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_CRYPTO_DEV_GEODE is not set
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
# CONFIG_LGUEST is not set
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
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=m
CONFIG_LIBCRC32C=m
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
# CONFIG_XZ_DEC_POWERPC is not set
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_INTERVAL_TREE=y
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
CONFIG_CORDIC=m
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=m
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y
CONFIG_ARCH_HAS_SG_CHAIN=y

--jq0ap7NbKX2Kqbes
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--jq0ap7NbKX2Kqbes--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
