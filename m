Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 189466B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 17:39:51 -0400 (EDT)
Date: Fri, 21 Sep 2012 05:39:38 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/7] mm: add CONFIG_DEBUG_VM_RB build option
Message-ID: <20120920213938.GA7959@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="azLHFNyN32YCQGCU"
Content-Disposition: inline
In-Reply-To: <505449BF.5040000@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Dave Jones <davej@redhat.com>, Jiri Slaby <jslaby@suse.cz>


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Sep 15, 2012 at 11:26:23AM +0200, Sasha Levin wrote:
> On 09/15/2012 02:00 AM, Michel Lespinasse wrote:
> > All right. Hugh managed to reproduce the issue on his suse laptop, and
> > I came up with a fix.
> >
> > The problem was that in mremap, the new vma's vm_{start,end,pgoff}
> > fields need to be updated before calling anon_vma_clone() so that the
> > new vma will be properly indexed.
> >
> > Patch attached. I expect this should also explain Jiri's reported
> > failure involving splitting THP pages during mremap(), even though we
> > did not manage to reproduce that one.
>
> Initially I've stumbled on it by running trinity inside a KVM tools guest. fwiw,
> the guest is pretty custom and isn't based on suse.
>
> I re-ran tests with patch applied and looks like it fixed the issue, I haven't
> seen the warnings even though it runs for quite a while now.

Not sure if it's the same problem you are talking about, but I got the
below warning and it's still happening in linux-next 20120920:

[   38.482925] scsi_nl_rcv_msg: discarding partial skb
[   62.679879] ------------[ cut here ]------------
[   62.680380] WARNING: at /c/kernel-tests/src/linux/mm/interval_tree.c:109 anon_vma_interval_tree_verify+0x33/0x80()
[   62.681356] Pid: 195, comm: trinity-child0 Not tainted 3.6.0-rc6-next-20120918-08732-g3de9d1a #1
[   62.682130] Call Trace:
[   62.682356]  [<ffffffff810c249f>] ? anon_vma_interval_tree_verify+0x33/0x80
[   62.682968]  [<ffffffff81044356>] warn_slowpath_common+0x5d/0x74
[   62.683577]  [<ffffffff81044424>] warn_slowpath_null+0x15/0x19
[   62.684098]  [<ffffffff810c249f>] anon_vma_interval_tree_verify+0x33/0x80
[   62.684714]  [<ffffffff810ca57c>] validate_mm+0x32/0x15b
[   62.685202]  [<ffffffff810ca767>] vma_link+0x95/0xa4
[   62.685637]  [<ffffffff810cbc31>] copy_vma+0x1c7/0x1fe
[   62.686168]  [<ffffffff810cdd50>] move_vma+0x90/0x1ef
[   62.686614]  [<ffffffff810ce250>] sys_mremap+0x3a1/0x429
[   62.687094]  [<ffffffff813caafe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   62.687670]  [<ffffffff81b505b9>] system_call_fastpath+0x16/0x1b

Bisected down to 

commit cb58d445d2ec3a06f313e29d6f6af5bef6c9e43c
Author: Michel Lespinasse <walken@google.com>
Date:   Thu Sep 13 10:58:56 2012 +1000

    mm: add CONFIG_DEBUG_VM_RB build option

Thanks,
Fengguang

--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-fat-3559-2012-09-19-10-31-29-3.6.0-rc6-next-20120918-08732-g3de9d1a-1"

[    0.000000] Linux version 3.6.0-rc6-next-20120918-08732-g3de9d1a (kbuild@inn) (gcc version 4.7.1 (Debian 4.7.1-6) ) #1 SMP Wed Sep 19 10:24:03 CST 2012
[    0.000000] Command line: trinity=5m hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 branch=internal-wfg/0day log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=vmlinuz-2012-09-19-10-25-19-internal-wfg:0day:3de9d1a-3de9d1a-x86_64-randconfig-i013-9-fat BOOT_IMAGE=kernel-tests/kernels/x86_64-randconfig-i013/3de9d1a/vmlinuz-3.6.0-rc6-next-20120918-08732-g3de9d1a
[    0.000000] KERNEL supported cpus:
[    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
[    0.000000] CPU: Your system may be unstable.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093bff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000093c00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0xfffe max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 00E0000000 mask FFE0000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
[    0.000000] Base memory trampoline at [ffff88000008d000] 8d000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x0fffdfff]
[    0.000000]  [mem 0x00000000-0x0fffdfff] page 4k
[    0.000000] kernel direct mapping tables up to 0xfffdfff @ [mem 0x0e854000-0x0e8d5fff]
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 128332(97%)
[    0.000000] RAMDISK: [mem 0x0e8d6000-0x0ffeffff]
[    0.000000] ACPI: RSDP 00000000000fd920 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000000fffe550 00038 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000000fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000000fffe590 01121 (v01   BXPC   BXDSDT 00000001 INTL 20100528)
[    0.000000] ACPI: FACS 000000000fffff40 00040
[    0.000000] ACPI: SSDT 000000000ffffe40 000FF (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000000ffffd50 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000000ffffd10 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: SSDT 000000000ffff6c0 00644 (v01   BXPC BXSSDTPC 00000001 INTL 20100528)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000000fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x0fffdfff]
[    0.000000]   NODE_DATA [mem 0x0e023000-0x0e053fff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:27b79c1, boot clock
[    0.000000]  [ffffea0000000000-ffffea00003fffff] PMD -> [ffff88000d400000-ffff88000d7fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x00092fff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65409
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3901 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 960 pages used for memmap
[    0.000000]   DMA32 zone: 60478 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 2, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 2, APIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 2, APIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 2, APIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 2, APIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 2, APIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 2, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 2, APIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 2, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 2, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 2, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 2, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 2, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 2, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 2, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 0000000000093000 - 0000000000094000
[    0.000000] PM: Registered nosave memory: 0000000000094000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:4096 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 474 pages/cpu @ffff88000dc00000 s1918656 r0 d22848 u2097152
[    0.000000] pcpu-alloc: s1918656 r0 d22848 u2097152 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1 
[    0.000000] kvm-clock: cpu 0, msr 0:ddd39c1, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr dc0ec00
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 64379
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: trinity=5m hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 branch=internal-wfg/0day log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=vmlinuz-2012-09-19-10-25-19-internal-wfg:0day:3de9d1a-3de9d1a-x86_64-randconfig-i013-9-fat BOOT_IMAGE=kernel-tests/kernels/x86_64-randconfig-i013/3de9d1a/vmlinuz-3.6.0-rc6-next-20120918-08732-g3de9d1a
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Memory: 183604k/262136k available (11599k kernel code, 500k absent, 78032k reserved, 10812k data, 2592k init)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 
[    0.000000] 
[    0.000000] 
[    0.000000] NR_IRQS:262400 nr_irqs:512 16
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ODEBUG: 7 of 7 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 3200.304 MHz processor
[    0.000000] tsc: Marking TSC unstable due to TSCs unsynchronized
[    0.020000] Calibrating delay loop (skipped) preset value.. 6400.60 BogoMIPS (lpj=32003040)
[    0.020000] pid_max: default: 4096 minimum: 301
[    0.020000] Security Framework initialized
[    0.020000] Dentry cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.020000] Inode-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.020000] Mount-cache hash table entries: 256
[    0.020000] mce: CPU supports 10 MCE banks
[    0.020000] mce: unknown CPU type - not enabling MCE support
[    0.020000] numa_add_cpu cpu 0 node 0: mask now 0
[    0.020000] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.020000] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.020000] tlb_flushall_shift: -1
[    0.020000] debug: unmapping init [mem 0xffffffff8286c000-0xffffffff82875fff]
[    0.021695] ACPI: Core revision 20120711
[    0.026982] Getting VERSION: 50014
[    0.027379] Getting VERSION: 50014
[    0.027690] Getting ID: 0
[    0.027933] Getting ID: ff000000
[    0.028231] Getting LVT0: 8700
[    0.028510] Getting LVT1: 8400
[    0.028823] enabled ExtINT on CPU#0
[    0.029880] ENABLING IO-APIC IRQs
[    0.030008] init IO_APIC IRQs
[    0.030281]  apic 2 pin 0 not connected
[    0.030642] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.031448] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    0.032173] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
[    0.032972] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.033698] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
[    0.034426] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.035222] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.035947] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.036667] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
[    0.037481] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    0.038225] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    0.039038] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.040022] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
[    0.040751] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
[    0.041560] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
[    0.042285]  apic 2 pin 16 not connected
[    0.042636]  apic 2 pin 17 not connected
[    0.043062]  apic 2 pin 18 not connected
[    0.043410]  apic 2 pin 19 not connected
[    0.043758]  apic 2 pin 20 not connected
[    0.044111]  apic 2 pin 21 not connected
[    0.044459]  apic 2 pin 22 not connected
[    0.044808]  apic 2 pin 23 not connected
[    0.045374] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.046072] smpboot: CPU0: GenuineIntel Common KVM processor stepping 01
[    0.046903] Using local APIC timer interrupts.
[    0.046903] calibrating APIC timer ...
[    0.050000] ... lapic delta = 6252978
[    0.050000] ... PM-Timer delta = 358141
[    0.050000] ... PM-Timer result ok
[    0.050000] ..... delta 6252978
[    0.050000] ..... mult: 268563360
[    0.050000] ..... calibration result: 10004764
[    0.050000] ..... CPU clock speed is 3201.7764 MHz.
[    0.050000] ..... host bus clock speed is 1000.4764 MHz.
[    0.050000] Performance Events: 
[    0.050000] SMP alternatives: lockdep: fixing up alternatives
[    0.050000] smpboot: Booting Node   0, Processors  #1 OK
[    0.020000] kvm-clock: cpu 1, msr 0:dfd39c1, secondary cpu clock
[    0.020000] masked ExtINT on CPU#1
[    0.020000] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.054734] Brought up 2 CPUs
[    0.054734] KVM setup async PF for cpu 1
[    0.054734] kvm-stealtime: cpu 1, msr de0ec00
[    0.054734] ----------------
[    0.054734] | NMI testsuite:
[    0.054734] --------------------
[    0.054734]   remote IPI:  ok  |
[    0.054734]    local IPI:  ok  |
[    0.100023] --------------------
[    0.100376] Good, all   2 testcases passed! |
[    0.100779] ---------------------------------
[    0.101185] smpboot: Total of 2 processors activated (12801.21 BogoMIPS)
[    0.102098] devtmpfs: initialized
[    0.102098] device: 'platform': device_add
[    0.102098] PM: Adding info for No Bus:platform
[    0.102098] bus: 'platform': registered
[    0.102098] bus: 'cpu': registered
[    0.102098] device: 'cpu': device_add
[    0.102098] PM: Adding info for No Bus:cpu
[    0.102098] EVM: security.ima
[    0.102098] EVM: security.capability
[    0.104288] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.104288] bus: 'virtio': registered
[    0.104288] device class 'regulator': registering
[    0.104288] Registering platform device 'reg-dummy'. Parent at platform
[    0.104288] device: 'reg-dummy': device_add
[    0.104288] bus: 'platform': add device reg-dummy
[    0.104288] PM: Adding info for platform:reg-dummy
[    0.104288] bus: 'platform': add driver reg-dummy
[    0.104634] bus: 'platform': driver_probe_device: matched device reg-dummy with driver reg-dummy
[    0.105490] bus: 'platform': really_probe: probing driver reg-dummy with device reg-dummy
[    0.106283] device: 'regulator.0': device_add
[    0.106752] PM: Adding info for No Bus:regulator.0
[    0.107310] regulator-dummy: no parameters
[    0.110083] driver: 'reg-dummy': driver_bound: bound to device 'reg-dummy'
[    0.114666] bus: 'platform': really_probe: bound device reg-dummy to driver reg-dummy
[    0.114666] NET: Registered protocol family 16
[    0.114666] device class 'bdi': registering
[    0.114666] device class 'pci_bus': registering
[    0.114666] bus: 'pci': registered
[    0.114666] device: 'rapidio': device_add
[    0.114666] PM: Adding info for No Bus:rapidio
[    0.114692] bus: 'rapidio': registered
[    0.115037] device class 'backlight': registering
[    0.115482] device class 'video_output': registering
[    0.116029] device class 'tty': registering
[    0.116465] bus: 'node': registered
[    0.116793] device: 'node': device_add
[    0.117159] PM: Adding info for No Bus:node
[    0.117646] bus: 'hsi': registered
[    0.140658] ACPI: bus type pci registered
[    0.141030] device class 'dma': registering
[    0.141466] PCI: Using configuration type 1 for base access
[    0.142392] device: 'node0': device_add
[    0.142840] bus: 'node': add device node0
[    0.143212] PM: Adding info for node:node0
[    0.143623] device: 'cpu0': device_add
[    0.143979] bus: 'cpu': add device cpu0
[    0.144343] PM: Adding info for cpu:cpu0
[    0.144812] device: 'cpu1': device_add
[    0.145157] bus: 'cpu': add device cpu1
[    0.145527] PM: Adding info for cpu:cpu1
[    0.170622] device: 'default': device_add
[    0.171026] PM: Adding info for No Bus:default
[    0.175929] bio: create slab <bio-0> at 0
[    0.175929] device class 'block': registering
[    0.175929] ACPI: Added _OSI(Module Device)
[    0.175929] ACPI: Added _OSI(Processor Device)
[    0.175929] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.175929] ACPI: Added _OSI(Processor Aggregator Device)
[    0.175929] ACPI: EC: Look up EC in DSDT
[    0.190009] ACPI: Interpreter enabled
[    0.190009] ACPI: (supports S0 S4 S5)
[    0.190425] ACPI: Using IOAPIC for interrupt routing
[    0.190912] bus: 'acpi': registered
[    0.191232] bus: 'acpi': add driver power
[    0.191764] device: 'LNXSYSTM:00': device_add
[    0.192169] bus: 'acpi': add device LNXSYSTM:00
[    0.192586] PM: Adding info for acpi:LNXSYSTM:00
[    0.193161] device: 'device:00': device_add
[    0.193655] bus: 'acpi': add device device:00
[    0.194065] PM: Adding info for acpi:device:00
[    0.194577] device: 'PNP0A03:00': device_add
[    0.194975] bus: 'acpi': add device PNP0A03:00
[    0.195385] PM: Adding info for acpi:PNP0A03:00
[    0.196881] device: 'device:01': device_add
[    0.197299] bus: 'acpi': add device device:01
[    0.197789] PM: Adding info for acpi:device:01
[    0.198298] device: 'device:02': device_add
[    0.198689] bus: 'acpi': add device device:02
[    0.199090] PM: Adding info for acpi:device:02
[    0.199687] device: 'PNP0B00:00': device_add
[    0.200010] bus: 'acpi': add device PNP0B00:00
[    0.200457] PM: Adding info for acpi:PNP0B00:00
[    0.201017] device: 'PNP0303:00': device_add
[    0.201411] bus: 'acpi': add device PNP0303:00
[    0.201895] PM: Adding info for acpi:PNP0303:00
[    0.202464] device: 'PNP0F13:00': device_add
[    0.202889] bus: 'acpi': add device PNP0F13:00
[    0.203297] PM: Adding info for acpi:PNP0F13:00
[    0.203939] device: 'PNP0700:00': device_add
[    0.204331] bus: 'acpi': add device PNP0700:00
[    0.204818] PM: Adding info for acpi:PNP0700:00
[    0.205703] device: 'PNP0400:00': device_add
[    0.206101] bus: 'acpi': add device PNP0400:00
[    0.206513] PM: Adding info for acpi:PNP0400:00
[    0.207193] device: 'PNP0501:00': device_add
[    0.207673] bus: 'acpi': add device PNP0501:00
[    0.208079] PM: Adding info for acpi:PNP0501:00
[    0.208721] device: 'device:03': device_add
[    0.209106] bus: 'acpi': add device device:03
[    0.209589] PM: Adding info for acpi:device:03
[    0.210131] device: 'device:04': device_add
[    0.210518] bus: 'acpi': add device device:04
[    0.210914] PM: Adding info for acpi:device:04
[    0.211517] device: 'device:05': device_add
[    0.211924] bus: 'acpi': add device device:05
[    0.212327] PM: Adding info for acpi:device:05
[    0.212928] device: 'device:06': device_add
[    0.213312] bus: 'acpi': add device device:06
[    0.213798] PM: Adding info for acpi:device:06
[    0.214331] device: 'device:07': device_add
[    0.214751] bus: 'acpi': add device device:07
[    0.215153] PM: Adding info for acpi:device:07
[    0.215742] device: 'device:08': device_add
[    0.216125] bus: 'acpi': add device device:08
[    0.216529] PM: Adding info for acpi:device:08
[    0.217061] device: 'device:09': device_add
[    0.217547] bus: 'acpi': add device device:09
[    0.217953] PM: Adding info for acpi:device:09
[    0.218479] device: 'device:0a': device_add
[    0.218865] bus: 'acpi': add device device:0a
[    0.219267] PM: Adding info for acpi:device:0a
[    0.220072] device: 'device:0b': device_add
[    0.220488] bus: 'acpi': add device device:0b
[    0.220974] PM: Adding info for acpi:device:0b
[    0.221494] device: 'device:0c': device_add
[    0.221963] bus: 'acpi': add device device:0c
[    0.222364] PM: Adding info for acpi:device:0c
[    0.222905] device: 'device:0d': device_add
[    0.223319] bus: 'acpi': add device device:0d
[    0.223806] PM: Adding info for acpi:device:0d
[    0.224327] device: 'device:0e': device_add
[    0.224719] bus: 'acpi': add device device:0e
[    0.225121] PM: Adding info for acpi:device:0e
[    0.225729] device: 'device:0f': device_add
[    0.226145] bus: 'acpi': add device device:0f
[    0.226547] PM: Adding info for acpi:device:0f
[    0.227071] device: 'device:10': device_add
[    0.227455] bus: 'acpi': add device device:10
[    0.227941] PM: Adding info for acpi:device:10
[    0.228475] device: 'device:11': device_add
[    0.228974] bus: 'acpi': add device device:11
[    0.229385] PM: Adding info for acpi:device:11
[    0.229982] device: 'device:12': device_add
[    0.230010] bus: 'acpi': add device device:12
[    0.230416] PM: Adding info for acpi:device:12
[    0.230949] device: 'device:13': device_add
[    0.231442] bus: 'acpi': add device device:13
[    0.231844] PM: Adding info for acpi:device:13
[    0.232370] device: 'device:14': device_add
[    0.232756] bus: 'acpi': add device device:14
[    0.233154] PM: Adding info for acpi:device:14
[    0.233766] device: 'device:15': device_add
[    0.234179] bus: 'acpi': add device device:15
[    0.234587] PM: Adding info for acpi:device:15
[    0.235105] device: 'device:16': device_add
[    0.235520] bus: 'acpi': add device device:16
[    0.235919] PM: Adding info for acpi:device:16
[    0.236530] device: 'device:17': device_add
[    0.236943] bus: 'acpi': add device device:17
[    0.237429] PM: Adding info for acpi:device:17
[    0.237949] device: 'device:18': device_add
[    0.238340] bus: 'acpi': add device device:18
[    0.238739] PM: Adding info for acpi:device:18
[    0.239270] device: 'device:19': device_add
[    0.240043] bus: 'acpi': add device device:19
[    0.240450] PM: Adding info for acpi:device:19
[    0.240988] device: 'device:1a': device_add
[    0.241387] bus: 'acpi': add device device:1a
[    0.241840] PM: Adding info for acpi:device:1a
[    0.242372] device: 'device:1b': device_add
[    0.242792] bus: 'acpi': add device device:1b
[    0.243195] PM: Adding info for acpi:device:1b
[    0.243750] device: 'device:1c': device_add
[    0.244133] bus: 'acpi': add device device:1c
[    0.244533] PM: Adding info for acpi:device:1c
[    0.245153] device: 'device:1d': device_add
[    0.245594] bus: 'acpi': add device device:1d
[    0.246001] PM: Adding info for acpi:device:1d
[    0.246528] device: 'device:1e': device_add
[    0.246990] bus: 'acpi': add device device:1e
[    0.247391] PM: Adding info for acpi:device:1e
[    0.247946] device: 'device:1f': device_add
[    0.248360] bus: 'acpi': add device device:1f
[    0.248768] PM: Adding info for acpi:device:1f
[    0.249288] device: 'device:20': device_add
[    0.249751] bus: 'acpi': add device device:20
[    0.250013] PM: Adding info for acpi:device:20
[    0.250560] device: 'device:21': device_add
[    0.250975] bus: 'acpi': add device device:21
[    0.251379] PM: Adding info for acpi:device:21
[    0.251930] device: 'device:22': device_add
[    0.252316] bus: 'acpi': add device device:22
[    0.252793] PM: Adding info for acpi:device:22
[    0.253766] device: 'PNP0103:00': device_add
[    0.254193] bus: 'acpi': add device PNP0103:00
[    0.254685] PM: Adding info for acpi:PNP0103:00
[    0.255449] device: 'PNP0C0F:00': device_add
[    0.255847] bus: 'acpi': add device PNP0C0F:00
[    0.256248] PM: Adding info for acpi:PNP0C0F:00
[    0.257038] device: 'PNP0C0F:01': device_add
[    0.257505] bus: 'acpi': add device PNP0C0F:01
[    0.257913] PM: Adding info for acpi:PNP0C0F:01
[    0.258694] device: 'PNP0C0F:02': device_add
[    0.259087] bus: 'acpi': add device PNP0C0F:02
[    0.259502] PM: Adding info for acpi:PNP0C0F:02
[    0.260311] device: 'PNP0C0F:03': device_add
[    0.260782] bus: 'acpi': add device PNP0C0F:03
[    0.261182] PM: Adding info for acpi:PNP0C0F:03
[    0.261962] device: 'PNP0C0F:04': device_add
[    0.262355] bus: 'acpi': add device PNP0C0F:04
[    0.262872] PM: Adding info for acpi:PNP0C0F:04
[    0.263471] device: 'LNXCPU:00': device_add
[    0.263873] bus: 'acpi': add device LNXCPU:00
[    0.264270] PM: Adding info for acpi:LNXCPU:00
[    0.264949] device: 'LNXCPU:01': device_add
[    0.265375] bus: 'acpi': add device LNXCPU:01
[    0.265818] PM: Adding info for acpi:LNXCPU:01
[    0.266345] device: 'device:23': device_add
[    0.266803] bus: 'acpi': add device device:23
[    0.267199] PM: Adding info for acpi:device:23
[    0.267693] device: 'LNXPWRBN:00': device_add
[    0.268100] bus: 'acpi': add device LNXPWRBN:00
[    0.268593] PM: Adding info for acpi:LNXPWRBN:00
[    0.269241] bus: 'acpi': add driver ec
[    0.272080] ACPI: No dock devices found.
[    0.272438] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.273319] bus: 'acpi': add driver pci_root
[    0.273785] bus: 'acpi': driver_probe_device: matched device PNP0A03:00 with driver pci_root
[    0.274521] bus: 'acpi': really_probe: probing driver pci_root with device PNP0A03:00
[    0.275322] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.275952] device: 'pci0000:00': device_add
[    0.276400] PM: Adding info for No Bus:pci0000:00
[    0.276923] device: '0000:00': device_add
[    0.277316] PM: Adding info for No Bus:0000:00
[    0.277842] PCI host bridge to bus 0000:00
[    0.278214] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.278789] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.279330] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.279889] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.280005] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xfebfffff]
[    0.280682] pci_bus 0000:00: scanning bus
[    0.281087] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.281707] pci 0000:00:00.0: calling quirk_mmio_always_on+0x0/0xa
[    0.282637] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.283595] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.285919] pci 0000:00:01.1: reg 20: [io  0xc1c0-0xc1cf]
[    0.287273] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.287819] pci 0000:00:01.3: calling acpi_pm_check_blacklist+0x0/0x38
[    0.288826] pci 0000:00:01.3: calling quirk_piix4_acpi+0x0/0x154
[    0.289455] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.290087] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.290765] pci 0000:00:01.3: calling pci_fixup_piix4_acpi+0x0/0x10
[    0.291441] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.294472] pci 0000:00:02.0: reg 10: [mem 0xfc000000-0xfdffffff pref]
[    0.295964] pci 0000:00:02.0: reg 14: [mem 0xfebf4000-0xfebf4fff]
[    0.301283] pci 0000:00:02.0: reg 30: [mem 0xfebe0000-0xfebeffff pref]
[    0.302152] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.303378] pci 0000:00:03.0: reg 10: [mem 0xfeba0000-0xfebbffff]
[    0.304616] pci 0000:00:03.0: reg 14: [io  0xc000-0xc03f]
[    0.308221] pci 0000:00:03.0: reg 30: [mem 0xfebc0000-0xfebdffff pref]
[    0.309008] pci 0000:00:04.0: [8086:2668] type 00 class 0x040300
[    0.310008] pci 0000:00:04.0: reg 10: [mem 0xfebf0000-0xfebf3fff]
[    0.312934] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.314199] pci 0000:00:05.0: reg 10: [io  0xc040-0xc07f]
[    0.315378] pci 0000:00:05.0: reg 14: [mem 0xfebf5000-0xfebf5fff]
[    0.319428] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.320735] pci 0000:00:06.0: reg 10: [io  0xc080-0xc0bf]
[    0.321911] pci 0000:00:06.0: reg 14: [mem 0xfebf6000-0xfebf6fff]
[    0.325942] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.327201] pci 0000:00:07.0: reg 10: [io  0xc0c0-0xc0ff]
[    0.328295] pci 0000:00:07.0: reg 14: [mem 0xfebf7000-0xfebf7fff]
[    0.332461] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.333795] pci 0000:00:08.0: reg 10: [io  0xc100-0xc13f]
[    0.334960] pci 0000:00:08.0: reg 14: [mem 0xfebf8000-0xfebf8fff]
[    0.339039] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.340005] pci 0000:00:09.0: reg 10: [io  0xc140-0xc17f]
[    0.341169] pci 0000:00:09.0: reg 14: [mem 0xfebf9000-0xfebf9fff]
[    0.345215] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.346490] pci 0000:00:0a.0: reg 10: [io  0xc180-0xc1bf]
[    0.347584] pci 0000:00:0a.0: reg 14: [mem 0xfebfa000-0xfebfafff]
[    0.351843] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.352789] pci 0000:00:0b.0: reg 10: [mem 0xfebfb000-0xfebfb00f]
[    0.355642] pci_bus 0000:00: fixups for bus
[    0.356023] pci_bus 0000:00: bus scan returning with max=00
[    0.356552] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.360888]  pci0000:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    0.361569]  pci0000:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.362344] device: '0000:00:00.0': device_add
[    0.364778] bus: 'pci': add device 0000:00:00.0
[    0.365292] PM: Adding info for pci:0000:00:00.0
[    0.365787] device: '0000:00:01.0': device_add
[    0.368090] bus: 'pci': add device 0000:00:01.0
[    0.368694] PM: Adding info for pci:0000:00:01.0
[    0.369139] device: '0000:00:01.1': device_add
[    0.371492] bus: 'pci': add device 0000:00:01.1
[    0.371986] PM: Adding info for pci:0000:00:01.1
[    0.372425] device: '0000:00:01.3': device_add
[    0.374890] bus: 'pci': add device 0000:00:01.3
[    0.375418] PM: Adding info for pci:0000:00:01.3
[    0.375877] device: '0000:00:02.0': device_add
[    0.378213] bus: 'pci': add device 0000:00:02.0
[    0.378789] PM: Adding info for pci:0000:00:02.0
[    0.379226] device: '0000:00:03.0': device_add
[    0.381569] bus: 'pci': add device 0000:00:03.0
[    0.382134] PM: Adding info for pci:0000:00:03.0
[    0.382635] device: '0000:00:04.0': device_add
[    0.384958] bus: 'pci': add device 0000:00:04.0
[    0.385486] PM: Adding info for pci:0000:00:04.0
[    0.385942] device: '0000:00:05.0': device_add
[    0.388218] bus: 'pci': add device 0000:00:05.0
[    0.388788] PM: Adding info for pci:0000:00:05.0
[    0.389231] device: '0000:00:06.0': device_add
[    0.391683] bus: 'pci': add device 0000:00:06.0
[    0.392275] PM: Adding info for pci:0000:00:06.0
[    0.392791] device: '0000:00:07.0': device_add
[    0.395180] bus: 'pci': add device 0000:00:07.0
[    0.395685] PM: Adding info for pci:0000:00:07.0
[    0.396174] device: '0000:00:08.0': device_add
[    0.398510] bus: 'pci': add device 0000:00:08.0
[    0.399078] PM: Adding info for pci:0000:00:08.0
[    0.399517] device: '0000:00:09.0': device_add
[    0.401915] bus: 'pci': add device 0000:00:09.0
[    0.402447] PM: Adding info for pci:0000:00:09.0
[    0.402972] device: '0000:00:0a.0': device_add
[    0.405290] bus: 'pci': add device 0000:00:0a.0
[    0.405799] PM: Adding info for pci:0000:00:0a.0
[    0.406237] device: '0000:00:0b.0': device_add
[    0.408655] bus: 'pci': add device 0000:00:0b.0
[    0.409154] PM: Adding info for pci:0000:00:0b.0
[    0.409670] driver: 'PNP0A03:00': driver_bound: bound to device 'pci_root'
[    0.410009] bus: 'acpi': really_probe: bound device PNP0A03:00 to driver pci_root
[    0.410805] bus: 'acpi': add driver pci_link
[    0.411216] bus: 'acpi': driver_probe_device: matched device PNP0C0F:00 with driver pci_link
[    0.411968] bus: 'acpi': really_probe: probing driver pci_link with device PNP0C0F:00
[    0.412935] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.413660] driver: 'PNP0C0F:00': driver_bound: bound to device 'pci_link'
[    0.414270] bus: 'acpi': really_probe: bound device PNP0C0F:00 to driver pci_link
[    0.415004] bus: 'acpi': driver_probe_device: matched device PNP0C0F:01 with driver pci_link
[    0.415755] bus: 'acpi': really_probe: probing driver pci_link with device PNP0C0F:01
[    0.416759] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.417475] driver: 'PNP0C0F:01': driver_bound: bound to device 'pci_link'
[    0.418085] bus: 'acpi': really_probe: bound device PNP0C0F:01 to driver pci_link
[    0.418830] bus: 'acpi': driver_probe_device: matched device PNP0C0F:02 with driver pci_link
[    0.419573] bus: 'acpi': really_probe: probing driver pci_link with device PNP0C0F:02
[    0.420241] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.420880] driver: 'PNP0C0F:02': driver_bound: bound to device 'pci_link'
[    0.421572] bus: 'acpi': really_probe: bound device PNP0C0F:02 to driver pci_link
[    0.422306] bus: 'acpi': driver_probe_device: matched device PNP0C0F:03 with driver pci_link
[    0.423048] bus: 'acpi': really_probe: probing driver pci_link with device PNP0C0F:03
[    0.423887] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.424595] driver: 'PNP0C0F:03': driver_bound: bound to device 'pci_link'
[    0.425235] bus: 'acpi': really_probe: bound device PNP0C0F:03 to driver pci_link
[    0.425891] bus: 'acpi': driver_probe_device: matched device PNP0C0F:04 with driver pci_link
[    0.426710] bus: 'acpi': really_probe: probing driver pci_link with device PNP0C0F:04
[    0.427573] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    0.428236] driver: 'PNP0C0F:04': driver_bound: bound to device 'pci_link'
[    0.428848] bus: 'acpi': really_probe: bound device PNP0C0F:04 to driver pci_link
[    0.430097] bus: 'pnp': registered
[    0.430528] bus: 'xen-backend': registered
[    0.430971] bus: 'xen': registered
[    0.431292] bus: 'platform': add driver gpio-regulator
[    0.431856] device class 'misc': registering
[    0.436930] bus: 'tifm': registered
[    0.436930] device class 'tifm_adapter': registering
[    0.436930] device class 'scsi_host': registering
[    0.436930] bus: 'scsi': registered
[    0.436930] device class 'scsi_device': registering
[    0.436930] SCSI subsystem initialized
[    0.436930] ACPI: bus type scsi registered
[    0.440582] device class 'ata_link': registering
[    0.440595] device class 'ata_port': registering
[    0.441022] device class 'ata_device': registering
[    0.441569] libata version 3.00 loaded.
[    0.441922] device class 'mdio_bus': registering
[    0.442508] bus: 'mdio_bus': registered
[    0.442863] bus: 'mdio_bus': add driver Generic PHY
[    0.443395] device class 'pcmcia_socket': registering
[    0.443395] ACPI: bus type usb registered
[    0.443395] bus: 'usb': registered
[    0.443395] bus: 'usb': add driver usbfs
[    0.443395] usbcore: registered new interface driver usbfs
[    0.443395] bus: 'usb': add driver hub
[    0.443395] usbcore: registered new interface driver hub
[    0.446881] bus: 'usb': add driver usb
[    0.446881] usbcore: registered new device driver usb
[    0.446881] device class 'udc': registering
[    0.446881] bus: 'serio': registered
[    0.446881] bus: 'gameport': registered
[    0.446881] device class 'input': registering
[    0.446881] device class 'rtc': registering
[    0.446881] Linux video capture interface: v2.00
[    0.446881] device class 'video4linux': registering
[    0.446881] device class 'power_supply': registering
[    0.446881] device class 'hwmon': registering
[    0.452789] bus: 'mmc': registered
[    0.452789] device class 'mmc_host': registering
[    0.452789] bus: 'sdio': registered
[    0.452789] device class 'leds': registering
[    0.452789] device class 'devfreq': registering
[    0.452789] bus: 'iio': registered
[    0.452789] device class 'sound': registering
[    0.452789] PCI: Using ACPI for IRQ routing
[    0.452789] PCI: pci_cache_line_size set to 64 bytes
[    0.452789] pci 0000:00:01.1: BAR 0: reserving [io  0x01f0-0x01f7 flags 0x110] (d=0, p=0)
[    0.453056] pci 0000:00:01.1: BAR 1: reserving [io  0x03f6 flags 0x110] (d=0, p=0)
[    0.453802] pci 0000:00:01.1: BAR 2: reserving [io  0x0170-0x0177 flags 0x110] (d=0, p=0)
[    0.454598] pci 0000:00:01.1: BAR 3: reserving [io  0x0376 flags 0x110] (d=0, p=0)
[    0.455261] pci 0000:00:01.1: BAR 4: reserving [io  0xc1c0-0xc1cf flags 0x40101] (d=0, p=0)
[    0.456022] pci 0000:00:02.0: BAR 0: reserving [mem 0xfc000000-0xfdffffff flags 0x42208] (d=0, p=0)
[    0.456897] pci 0000:00:02.0: BAR 1: reserving [mem 0xfebf4000-0xfebf4fff flags 0x40200] (d=0, p=0)
[    0.457777] pci 0000:00:03.0: BAR 0: reserving [mem 0xfeba0000-0xfebbffff flags 0x40200] (d=0, p=0)
[    0.458647] pci 0000:00:03.0: BAR 1: reserving [io  0xc000-0xc03f flags 0x40101] (d=0, p=0)
[    0.459469] pci 0000:00:04.0: BAR 0: reserving [mem 0xfebf0000-0xfebf3fff flags 0x40200] (d=0, p=0)
[    0.460016] pci 0000:00:05.0: BAR 0: reserving [io  0xc040-0xc07f flags 0x40101] (d=0, p=0)
[    0.460837] pci 0000:00:05.0: BAR 1: reserving [mem 0xfebf5000-0xfebf5fff flags 0x40200] (d=0, p=0)
[    0.461717] pci 0000:00:06.0: BAR 0: reserving [io  0xc080-0xc0bf flags 0x40101] (d=0, p=0)
[    0.462531] pci 0000:00:06.0: BAR 1: reserving [mem 0xfebf6000-0xfebf6fff flags 0x40200] (d=0, p=0)
[    0.463422] pci 0000:00:07.0: BAR 0: reserving [io  0xc0c0-0xc0ff flags 0x40101] (d=0, p=0)
[    0.464238] pci 0000:00:07.0: BAR 1: reserving [mem 0xfebf7000-0xfebf7fff flags 0x40200] (d=0, p=0)
[    0.465045] pci 0000:00:08.0: BAR 0: reserving [io  0xc100-0xc13f flags 0x40101] (d=0, p=0)
[    0.470004] pci 0000:00:08.0: BAR 1: reserving [mem 0xfebf8000-0xfebf8fff flags 0x40200] (d=0, p=0)
[    0.470004] pci 0000:00:09.0: BAR 0: reserving [io  0xc140-0xc17f flags 0x40101] (d=0, p=0)
[    0.470004] pci 0000:00:09.0: BAR 1: reserving [mem 0xfebf9000-0xfebf9fff flags 0x40200] (d=0, p=0)
[    0.470004] pci 0000:00:0a.0: BAR 0: reserving [io  0xc180-0xc1bf flags 0x40101] (d=0, p=0)
[    0.470004] pci 0000:00:0a.0: BAR 1: reserving [mem 0xfebfa000-0xfebfafff flags 0x40200] (d=0, p=0)
[    0.470016] pci 0000:00:0b.0: BAR 0: reserving [mem 0xfebfb000-0xfebfb00f flags 0x40200] (d=0, p=0)
[    0.471005] e820: reserve RAM buffer [mem 0x00093c00-0x0009ffff]
[    0.471625] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.472247] device class 'net': registering
[    0.472752] device: 'lo': device_add
[    0.473429] PM: Adding info for No Bus:lo
[    0.474246] NET: Registered protocol family 23
[    0.474678] NetLabel: Initializing
[    0.474989] NetLabel:  domain hash size = 128
[    0.475399] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.475917] NetLabel:  unlabeled traffic allowed by default
[    0.476504] nfc: nfc_init: NFC Core ver 0.1
[    0.476882] device class 'nfc': registering
[    0.477485] NET: Registered protocol family 39
[    0.478532] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.479247] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.480137] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.490051] Switching to clocksource kvm-clock
[    0.490607] bus: 'pnp': add driver system
[    0.490713] pnp: PnP ACPI init
[    0.491019] device: 'pnp0': device_add
[    0.491382] PM: Adding info for No Bus:pnp0
[    0.491801] ACPI: bus type pnp registered
[    0.492214] pnp 00:00: [bus 00-ff]
[    0.492566] pnp 00:00: [io  0x0cf8-0x0cff]
[    0.492945] pnp 00:00: [io  0x0000-0x0cf7 window]
[    0.493378] pnp 00:00: [io  0x0d00-0xffff window]
[    0.493843] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    0.494329] pnp 00:00: [mem 0xe0000000-0xfebfffff window]
[    0.494936] device: '00:00': device_add
[    0.495357] bus: 'pnp': add device 00:00
[    0.495803] PM: Adding info for pnp:00:00
[    0.496196] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
[    0.496897] pnp 00:01: [io  0x0070-0x0071]
[    0.497282] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:3)
[    0.498069] pnp 00:01: [irq 8]
[    0.498345] pnp 00:01: [io  0x0072-0x0077]
[    0.498789] device: '00:01': device_add
[    0.499154] bus: 'pnp': add device 00:01
[    0.499604] PM: Adding info for pnp:00:01
[    0.499988] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.500746] pnp 00:02: [io  0x0060]
[    0.501063] pnp 00:02: [io  0x0064]
[    0.501437] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:3)
[    0.502154] pnp 00:02: [irq 1]
[    0.502510] device: '00:02': device_add
[    0.502873] bus: 'pnp': add device 00:02
[    0.503234] PM: Adding info for pnp:00:02
[    0.503688] pnp 00:02: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.504349] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:3)
[    0.505148] pnp 00:03: [irq 12]
[    0.505553] device: '00:03': device_add
[    0.505923] bus: 'pnp': add device 00:03
[    0.506291] PM: Adding info for pnp:00:03
[    0.506751] pnp 00:03: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.507479] pnp 00:04: [io  0x03f2-0x03f5]
[    0.507854] pnp 00:04: [io  0x03f7]
[    0.508173] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:3)
[    0.508963] pnp 00:04: [irq 6]
[    0.509244] pnp 00:04: [dma 2]
[    0.509605] device: '00:04': device_add
[    0.509973] bus: 'pnp': add device 00:04
[    0.510480] PM: Adding info for pnp:00:04
[    0.510866] pnp 00:04: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.511657] pnp 00:05: [io  0x0378-0x037f]
[    0.512032] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:3)
[    0.512819] pnp 00:05: [irq 7]
[    0.513097] device: '00:05': device_add
[    0.513549] bus: 'pnp': add device 00:05
[    0.513957] PM: Adding info for pnp:00:05
[    0.514339] pnp 00:05: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.515131] pnp 00:06: [io  0x03f8-0x03ff]
[    0.515583] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:3)
[    0.516284] pnp 00:06: [irq 4]
[    0.516640] device: '00:06': device_add
[    0.517009] bus: 'pnp': add device 00:06
[    0.517373] PM: Adding info for pnp:00:06
[    0.517827] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.518985] pnp 00:07: [mem 0xfed00000-0xfed003ff]
[    0.519532] device: '00:07': device_add
[    0.519985] bus: 'pnp': add device 00:07
[    0.520365] PM: Adding info for pnp:00:07
[    0.520818] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.521855] pnp: PnP ACPI: found 8 devices
[    0.522222] ACPI: ACPI bus type pnp unregistered
[    0.522712] bus: 'pci': add driver Intel MID DMA
[    0.523173] bus: 'pci': add driver pciback
[    0.523676] bus: 'pci': driver_probe_device: matched device 0000:00:00.0 with driver pciback
[    0.524489] bus: 'pci': really_probe: probing driver pciback with device 0000:00:00.0
[    0.525211] pciback: probe of 0000:00:00.0 rejects match -19
[    0.525792] bus: 'pci': driver_probe_device: matched device 0000:00:01.0 with driver pciback
[    0.526605] bus: 'pci': really_probe: probing driver pciback with device 0000:00:01.0
[    0.527297] pciback: probe of 0000:00:01.0 rejects match -19
[    0.527884] bus: 'pci': driver_probe_device: matched device 0000:00:01.1 with driver pciback
[    0.528694] bus: 'pci': really_probe: probing driver pciback with device 0000:00:01.1
[    0.529459] pciback: probe of 0000:00:01.1 rejects match -19
[    0.529965] bus: 'pci': driver_probe_device: matched device 0000:00:01.3 with driver pciback
[    0.530793] bus: 'pci': really_probe: probing driver pciback with device 0000:00:01.3
[    0.531570] pciback: probe of 0000:00:01.3 rejects match -19
[    0.532082] bus: 'pci': driver_probe_device: matched device 0000:00:02.0 with driver pciback
[    0.532899] bus: 'pci': really_probe: probing driver pciback with device 0000:00:02.0
[    0.533671] pciback: probe of 0000:00:02.0 rejects match -19
[    0.534167] bus: 'pci': driver_probe_device: matched device 0000:00:03.0 with driver pciback
[    0.534975] bus: 'pci': really_probe: probing driver pciback with device 0000:00:03.0
[    0.535700] pciback: probe of 0000:00:03.0 rejects match -19
[    0.536201] bus: 'pci': driver_probe_device: matched device 0000:00:04.0 with driver pciback
[    0.537020] bus: 'pci': really_probe: probing driver pciback with device 0000:00:04.0
[    0.537793] pciback: probe of 0000:00:04.0 rejects match -19
[    0.538293] bus: 'pci': driver_probe_device: matched device 0000:00:05.0 with driver pciback
[    0.539099] bus: 'pci': really_probe: probing driver pciback with device 0000:00:05.0
[    0.539792] pciback: probe of 0000:00:05.0 rejects match -19
[    0.540306] bus: 'pci': driver_probe_device: matched device 0000:00:06.0 with driver pciback
[    0.541115] bus: 'pci': really_probe: probing driver pciback with device 0000:00:06.0
[    0.541886] pciback: probe of 0000:00:06.0 rejects match -19
[    0.542461] bus: 'pci': driver_probe_device: matched device 0000:00:07.0 with driver pciback
[    0.543199] bus: 'pci': really_probe: probing driver pciback with device 0000:00:07.0
[    0.543898] pciback: probe of 0000:00:07.0 rejects match -19
[    0.544476] bus: 'pci': driver_probe_device: matched device 0000:00:08.0 with driver pciback
[    0.545214] bus: 'pci': really_probe: probing driver pciback with device 0000:00:08.0
[    0.545988] pciback: probe of 0000:00:08.0 rejects match -19
[    0.546568] bus: 'pci': driver_probe_device: matched device 0000:00:09.0 with driver pciback
[    0.547297] bus: 'pci': really_probe: probing driver pciback with device 0000:00:09.0
[    0.547993] pciback: probe of 0000:00:09.0 rejects match -19
[    0.548576] bus: 'pci': driver_probe_device: matched device 0000:00:0a.0 with driver pciback
[    0.549334] bus: 'pci': really_probe: probing driver pciback with device 0000:00:0a.0
[    0.550125] pciback: probe of 0000:00:0a.0 rejects match -19
[    0.550706] bus: 'pci': driver_probe_device: matched device 0000:00:0b.0 with driver pciback
[    0.551447] bus: 'pci': really_probe: probing driver pciback with device 0000:00:0b.0
[    0.552141] pciback: probe of 0000:00:0b.0 rejects match -19
[    0.552776] device class 'mem': registering
[    0.553175] device: 'mem': device_add
[    0.554067] PM: Adding info for No Bus:mem
[    0.554582] device: 'kmem': device_add
[    0.555225] PM: Adding info for No Bus:kmem
[    0.555660] device: 'null': device_add
[    0.556340] PM: Adding info for No Bus:null
[    0.556793] device: 'port': device_add
[    0.557438] PM: Adding info for No Bus:port
[    0.557870] device: 'zero': device_add
[    0.558530] PM: Adding info for No Bus:zero
[    0.558974] device: 'full': device_add
[    0.559538] PM: Adding info for No Bus:full
[    0.559975] device: 'random': device_add
[    0.560671] PM: Adding info for No Bus:random
[    0.561123] device: 'urandom': device_add
[    0.561784] PM: Adding info for No Bus:urandom
[    0.562233] device: 'kmsg': device_add
[    0.562852] PM: Adding info for No Bus:kmsg
[    0.563240] device: 'oldmem': device_add
[    0.563747] PM: Adding info for No Bus:oldmem
[    0.564166] device: 'tty': device_add
[    0.564792] PM: Adding info for No Bus:tty
[    0.565189] device: 'console': device_add
[    0.565702] PM: Adding info for No Bus:console
[    0.566174] device class 'firmware': registering
[    0.571316] bus: 'bcma': registered
[    0.571639] bus: 'pci': add driver bcma-pci-bridge
[    0.572162] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.572745] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.573237] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.573795] pci_bus 0000:00: resource 7 [mem 0xe0000000-0xfebfffff]
[    0.574480] NET: Registered protocol family 2
[    0.575167] TCP established hash table entries: 8192 (order: 5, 131072 bytes)
[    0.576060] TCP bind hash table entries: 8192 (order: 7, 655360 bytes)
[    0.577330] TCP: Hash tables configured (established 8192 bind 8192)
[    0.578005] TCP: reno registered
[    0.578320] UDP hash table entries: 128 (order: 2, 24576 bytes)
[    0.578959] UDP-Lite hash table entries: 128 (order: 2, 24576 bytes)
[    0.579653] NET: Registered protocol family 1
[    0.580541] RPC: Registered named UNIX socket transport module.
[    0.581066] RPC: Registered udp transport module.
[    0.581484] RPC: Registered tcp transport module.
[    0.581895] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.582553] pci 0000:00:00.0: calling quirk_natoma+0x0/0x2b
[    0.583044] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.583576] pci 0000:00:00.0: calling quirk_passive_release+0x0/0x7b
[    0.584139] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.584744] pci 0000:00:01.0: calling quirk_isa_dma_hangs+0x0/0x2e
[    0.585282] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.585843] pci 0000:00:02.0: calling pci_fixup_video+0x0/0x97
[    0.586357] pci 0000:00:02.0: Boot video device
[    0.586846] pci 0000:00:03.0: calling quirk_e100_interrupt+0x0/0x155
[    0.587477] PCI: CLS 0 bytes, default 64
[    0.588087] Unpacking initramfs...
[    1.898134] debug: unmapping init [mem 0xffff88000e8d6000-0xffff88000ffeffff]
[    1.899714] Machine check injector initialized
[    1.900171] Registering platform device 'pcspkr'. Parent at platform
[    1.900822] device: 'pcspkr': device_add
[    1.901189] bus: 'platform': add device pcspkr
[    1.901754] PM: Adding info for platform:pcspkr
[    1.902174] microcode: no support for this CPU vendor
[    1.903512] cryptomgr_test (28) used greatest stack depth: 6200 bytes left
[    1.905347] cryptomgr_test (29) used greatest stack depth: 6024 bytes left
[    1.907183] cryptomgr_test (30) used greatest stack depth: 5672 bytes left
[    1.913956] device: 'snapshot': device_add
[    1.914529] PM: Adding info for No Bus:snapshot
[    1.915208] bus: 'clocksource': registered
[    1.915671] device: 'clocksource': device_add
[    1.916073] PM: Adding info for No Bus:clocksource
[    1.916583] device: 'clocksource0': device_add
[    1.916985] bus: 'clocksource': add device clocksource0
[    1.917544] PM: Adding info for clocksource:clocksource0
[    1.918103] bus: 'platform': add driver alarmtimer
[    1.918798] Registering platform device 'alarmtimer'. Parent at platform
[    1.919479] device: 'alarmtimer': device_add
[    1.919869] bus: 'platform': add device alarmtimer
[    1.920414] PM: Adding info for platform:alarmtimer
[    1.920907] bus: 'platform': driver_probe_device: matched device alarmtimer with driver alarmtimer
[    1.921779] bus: 'platform': really_probe: probing driver alarmtimer with device alarmtimer
[    1.922607] driver: 'alarmtimer': driver_bound: bound to device 'alarmtimer'
[    1.923235] bus: 'platform': really_probe: bound device alarmtimer to driver alarmtimer
[    1.924276] bus: 'event_source': registered
[    1.924750] device: 'breakpoint': device_add
[    1.925144] bus: 'event_source': add device breakpoint
[    1.925705] PM: Adding info for event_source:breakpoint
[    1.926246] device: 'software': device_add
[    1.926708] bus: 'event_source': add device software
[    1.927266] PM: Adding info for event_source:software
[    1.928787] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.930291] VFS: Disk quotas dquot_6.5.2
[    1.930707] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.932424] device: 'dlm-control': device_add
[    1.933056] PM: Adding info for No Bus:dlm-control
[    1.933666] device: 'dlm-monitor': device_add
[    1.934835] PM: Adding info for No Bus:dlm-monitor
[    1.935371] device: 'dlm_plock': device_add
[    1.935991] PM: Adding info for No Bus:dlm_plock
[    1.936496] DLM installed
[    1.937755] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    1.939047] device: 'ecryptfs': device_add
[    1.939998] PM: Adding info for No Bus:ecryptfs
[    1.941799] NFS: Registering the id_resolver key type
[    1.942521] Key type id_resolver registered
[    1.942899] Key type id_legacy registered
[    1.943254] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    1.946998] NTFS driver 2.1.30 [Flags: R/W DEBUG].
[    1.947544] ROMFS MTD (C) 2007 Red Hat, Inc.
[    1.947938] QNX4 filesystem 0.2.3 registered.
[    1.948334] SGI XFS with security attributes, large block/inode numbers, no debug enabled
[    1.950121] 9p: Installing v9fs 9p2000 file system support
[    1.950695] OCFS2 1.5.0
[    1.951308] ocfs2 stack glue: unable to register sysctl
[    1.951800] ocfs2: Registered cluster interface o2cb
[    1.952237] OCFS2 DLMFS 1.5.0
[    1.952807] OCFS2 User DLM kernel interface loaded
[    1.953268] OCFS2 Node Manager 1.5.0
[    1.957873] OCFS2 DLM 1.5.0
[    1.958208] ceph: loaded (mds proto 32)
[    1.958641] msgmni has been set to 358
[    1.959797] alg: No test for cipher_null (cipher_null-generic)
[    1.960645] alg: No test for ecb(cipher_null) (ecb-cipher_null)
[    1.961826] alg: No test for compress_null (compress_null-generic)
[    1.963076] alg: No test for digest_null (digest_null-generic)
[    1.966380] cryptomgr_test (61) used greatest stack depth: 5560 bytes left
[    1.968807] alg: No test for fcrypt (fcrypt-generic)
[    1.973745] cryptomgr_test (84) used greatest stack depth: 5432 bytes left
[    1.974804] alg: No test for stdrng (krng)
[    1.975568] cryptomgr_test (87) used greatest stack depth: 5400 bytes left
[    1.976230] NET: Registered protocol family 38
[    1.976677] device class 'bsg': registering
[    1.977294] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    1.978021] io scheduler noop registered
[    1.978426] io scheduler deadline registered (default)
[    1.978915] io scheduler cfq registered
[    1.979944] crc32: CRC_LE_BITS = 64, CRC_BE BITS = 64
[    1.980471] crc32: self tests passed, processed 225944 bytes in 134274 nsec
[    1.981244] crc32c: CRC_LE_BITS = 64
[    1.981610] crc32c: self tests passed, processed 225944 bytes in 67926 nsec
[    1.983807] bus: 'platform': add driver omap-ocp2scp
[    1.984349] bus: 'platform': add driver basic-mmio-gpio
[    1.984918] bus: 'pci': add driver bt8xxgpio
[    1.985742] bus: 'pci': add driver langwell_gpio
[    1.986253] bus: 'platform': add driver wp_gpio
[    1.986771] bus: 'pci': add driver pch_gpio
[    1.987378] bus: 'platform': add driver rdc321x-gpio
[    1.987909] bus: 'platform': add driver sch_gpio
[    1.988411] bus: 'platform': add driver vx855_gpio
[    1.989022] bus: 'pci': add driver ioapic
[    1.989511] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.990049] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[    1.990714] bus: 'pci': add driver zt5550_hc
[    1.991297] bus: 'pci': add driver shpchp
[    1.991788] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    1.992408] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    1.993369] pci_bus 0000:00: dev 03, created physical slot 3
[    1.994098] acpiphp: Slot [3] registered
[    1.994560] pci_bus 0000:00: dev 04, created physical slot 4
[    1.995154] acpiphp: Slot [4] registered
[    1.995717] pci_bus 0000:00: dev 05, created physical slot 5
[    1.996319] acpiphp: Slot [5] registered
[    1.996746] pci_bus 0000:00: dev 06, created physical slot 6
[    1.997477] acpiphp: Slot [6] registered
[    1.997905] pci_bus 0000:00: dev 07, created physical slot 7
[    1.998537] acpiphp: Slot [7] registered
[    1.999067] pci_bus 0000:00: dev 08, created physical slot 8
[    1.999700] acpiphp: Slot [8] registered
[    2.000142] pci_bus 0000:00: dev 09, created physical slot 9
[    2.000840] acpiphp: Slot [9] registered
[    2.001267] pci_bus 0000:00: dev 0a, created physical slot 10
[    2.001904] acpiphp: Slot [10] registered
[    2.002476] pci_bus 0000:00: dev 0b, created physical slot 11
[    2.003085] acpiphp: Slot [11] registered
[    2.003552] pci_bus 0000:00: dev 0c, created physical slot 12
[    2.004151] acpiphp: Slot [12] registered
[    2.004691] pci_bus 0000:00: dev 0d, created physical slot 13
[    2.005292] acpiphp: Slot [13] registered
[    2.005762] pci_bus 0000:00: dev 0e, created physical slot 14
[    2.006498] acpiphp: Slot [14] registered
[    2.006936] pci_bus 0000:00: dev 0f, created physical slot 15
[    2.007573] acpiphp: Slot [15] registered
[    2.008110] pci_bus 0000:00: dev 10, created physical slot 16
[    2.008720] acpiphp: Slot [16] registered
[    2.009152] pci_bus 0000:00: dev 11, created physical slot 17
[    2.009885] acpiphp: Slot [17] registered
[    2.010404] pci_bus 0000:00: dev 12, created physical slot 18
[    2.010983] acpiphp: Slot [18] registered
[    2.011580] pci_bus 0000:00: dev 13, created physical slot 19
[    2.012164] acpiphp: Slot [19] registered
[    2.012588] pci_bus 0000:00: dev 14, created physical slot 20
[    2.013266] acpiphp: Slot [20] registered
[    2.013765] pci_bus 0000:00: dev 15, created physical slot 21
[    2.014419] acpiphp: Slot [21] registered
[    2.014943] pci_bus 0000:00: dev 16, created physical slot 22
[    2.015605] acpiphp: Slot [22] registered
[    2.016022] pci_bus 0000:00: dev 17, created physical slot 23
[    2.016706] acpiphp: Slot [23] registered
[    2.017121] pci_bus 0000:00: dev 18, created physical slot 24
[    2.017777] acpiphp: Slot [24] registered
[    2.018295] pci_bus 0000:00: dev 19, created physical slot 25
[    2.018985] acpiphp: Slot [25] registered
[    2.019491] pci_bus 0000:00: dev 1a, created physical slot 26
[    2.020204] acpiphp: Slot [26] registered
[    2.020631] pci_bus 0000:00: dev 1b, created physical slot 27
[    2.021213] acpiphp: Slot [27] registered
[    2.021814] pci_bus 0000:00: dev 1c, created physical slot 28
[    2.022474] acpiphp: Slot [28] registered
[    2.022889] pci_bus 0000:00: dev 1d, created physical slot 29
[    2.023651] acpiphp: Slot [29] registered
[    2.024068] pci_bus 0000:00: dev 1e, created physical slot 30
[    2.024650] acpiphp: Slot [30] registered
[    2.025183] pci_bus 0000:00: dev 1f, created physical slot 31
[    2.025845] acpiphp: Slot [31] registered
[    2.030086] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[    2.030745] bus: 'acpi': add driver ac
[    2.031166] bus: 'acpi': add driver button
[    2.031653] bus: 'acpi': driver_probe_device: matched device LNXPWRBN:00 with driver button
[    2.032401] bus: 'acpi': really_probe: probing driver button with device LNXPWRBN:00
[    2.033581] device: 'input0': device_add
[    2.034119] PM: Adding info for No Bus:input0
[    2.034646] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    2.035391] ACPI: Power Button [PWRF]
[    2.035756] driver: 'LNXPWRBN:00': driver_bound: bound to device 'button'
[    2.036359] bus: 'acpi': really_probe: bound device LNXPWRBN:00 to driver button
[    2.037025] bus: 'platform': add driver virtio-mmio
[    2.037667] bus: 'pci': add driver virtio-pci
[    2.038078] bus: 'pci': driver_probe_device: matched device 0000:00:05.0 with driver virtio-pci
[    2.038924] bus: 'pci': really_probe: probing driver virtio-pci with device 0000:00:05.0
[    2.040287] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    2.040833] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:3)
[    2.041672] virtio-pci 0000:00:05.0: enabling bus mastering
[    2.042179] virtio-pci 0000:00:05.0: setting latency timer to 64
[    2.043051] device: 'virtio0': device_add
[    2.043502] bus: 'virtio': add device virtio0
[    2.044033] PM: Adding info for virtio:virtio0
[    2.044469] driver: '0000:00:05.0': driver_bound: bound to device 'virtio-pci'
[    2.045110] bus: 'pci': really_probe: bound device 0000:00:05.0 to driver virtio-pci
[    2.045876] bus: 'pci': driver_probe_device: matched device 0000:00:06.0 with driver virtio-pci
[    2.046725] bus: 'pci': really_probe: probing driver virtio-pci with device 0000:00:06.0
[    2.048028] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 11
[    2.048557] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:3)
[    2.049359] virtio-pci 0000:00:06.0: enabling bus mastering
[    2.049888] virtio-pci 0000:00:06.0: setting latency timer to 64
[    2.050723] device: 'virtio1': device_add
[    2.051091] bus: 'virtio': add device virtio1
[    2.051580] PM: Adding info for virtio:virtio1
[    2.051988] driver: '0000:00:06.0': driver_bound: bound to device 'virtio-pci'
[    2.052631] bus: 'pci': really_probe: bound device 0000:00:06.0 to driver virtio-pci
[    2.053391] bus: 'pci': driver_probe_device: matched device 0000:00:07.0 with driver virtio-pci
[    2.054156] bus: 'pci': really_probe: probing driver virtio-pci with device 0000:00:07.0
[    2.055863] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    2.056406] virtio-pci 0000:00:07.0: enabling bus mastering
[    2.056918] virtio-pci 0000:00:07.0: setting latency timer to 64
[    2.057709] device: 'virtio2': device_add
[    2.058075] bus: 'virtio': add device virtio2
[    2.058561] PM: Adding info for virtio:virtio2
[    2.058968] driver: '0000:00:07.0': driver_bound: bound to device 'virtio-pci'
[    2.059683] bus: 'pci': really_probe: bound device 0000:00:07.0 to driver virtio-pci
[    2.060387] bus: 'pci': driver_probe_device: matched device 0000:00:08.0 with driver virtio-pci
[    2.061145] bus: 'pci': really_probe: probing driver virtio-pci with device 0000:00:08.0
[    2.062713] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
[    2.063246] virtio-pci 0000:00:08.0: enabling bus mastering
[    2.063840] virtio-pci 0000:00:08.0: setting latency timer to 64
[    2.064667] device: 'virtio3': device_add
[    2.065146] bus: 'virtio': add device virtio3
[    2.065644] PM: Adding info for virtio:virtio3
[    2.066055] driver: '0000:00:08.0': driver_bound: bound to device 'virtio-pci'
[    2.066778] bus: 'pci': really_probe: bound device 0000:00:08.0 to driver virtio-pci
[    2.067549] bus: 'pci': driver_probe_device: matched device 0000:00:09.0 with driver virtio-pci
[    2.068317] bus: 'pci': really_probe: probing driver virtio-pci with device 0000:00:09.0
[    2.069262] virtio-pci 0000:00:09.0: enabling bus mastering
[    2.069860] virtio-pci 0000:00:09.0: setting latency timer to 64
[    2.070665] device: 'virtio4': device_add
[    2.071034] bus: 'virtio': add device virtio4
[    2.071647] PM: Adding info for virtio:virtio4
[    2.072065] driver: '0000:00:09.0': driver_bound: bound to device 'virtio-pci'
[    2.072710] bus: 'pci': really_probe: bound device 0000:00:09.0 to driver virtio-pci
[    2.073478] bus: 'pci': driver_probe_device: matched device 0000:00:0a.0 with driver virtio-pci
[    2.074242] bus: 'pci': really_probe: probing driver virtio-pci with device 0000:00:0a.0
[    2.075130] virtio-pci 0000:00:0a.0: enabling bus mastering
[    2.075718] virtio-pci 0000:00:0a.0: setting latency timer to 64
[    2.076425] device: 'virtio5': device_add
[    2.076794] bus: 'virtio': add device virtio5
[    2.077380] PM: Adding info for virtio:virtio5
[    2.077798] driver: '0000:00:0a.0': driver_bound: bound to device 'virtio-pci'
[    2.078518] bus: 'pci': really_probe: bound device 0000:00:0a.0 to driver virtio-pci
[    2.079226] bus: 'pci': add driver xen-platform-pci
[    2.079777] bus: 'platform': add driver reg-userspace-consumer
[    2.080480] device: 'ptmx': device_add
[    2.080877] PM: Adding info for No Bus:ptmx
[    2.081428] HDLC line discipline maxframe=4096
[    2.081833] N_HDLC line discipline registered.
[    2.082465] r3964: Philips r3964 Driver $Revision: 1.10 $
[    2.082952] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    2.083655] Registering platform device 'serial8250'. Parent at platform
[    2.084361] device: 'serial8250': device_add
[    2.084755] bus: 'platform': add device serial8250
[    2.085205] PM: Adding info for platform:serial8250

[    2.381107] device: 'ttyS0': device_add
[    2.381674] PM: Adding info for No Bus:ttyS0
[    2.382227] device: 'ttyS1': device_add
[    2.382711] PM: Adding info for No Bus:ttyS1
[    2.383200] device: 'ttyS2': device_add
[    2.383722] PM: Adding info for No Bus:ttyS2
[    2.384212] device: 'ttyS3': device_add
[    2.385109] PM: Adding info for No Bus:ttyS3
[    2.385654] bus: 'platform': add driver serial8250
[    2.386096] bus: 'platform': driver_probe_device: matched device serial8250 with driver serial8250
[    2.386966] bus: 'platform': really_probe: probing driver serial8250 with device serial8250
[    2.387720] driver: 'serial8250': driver_bound: bound to device 'serial8250'
[    2.388429] bus: 'platform': really_probe: bound device serial8250 to driver serial8250
[    2.389150] bus: 'pci': add driver serial
[    2.389737] bus: 'pci': add driver jsm
[    2.390179] bus: 'platform': add driver altera_uart
[    2.392204] bus: 'pci': add driver HSU serial
[    2.392883] MOXA Intellio family driver version 6.0k
[    2.393625] bus: 'pci': add driver moxa
[    2.394097] MOXA Smartio/Industio family driver version 2.0.5
[    2.394691] bus: 'pci': add driver mxser
[    2.395238] RocketPort device driver module, version 2.09, 12-June-2003
[    2.395987] No rocketport ports found; unloading driver
[    2.396557] SyncLink GT
[    2.396828] SyncLink GT, tty major#250
[    2.397170] bus: 'pci': add driver synclink_gt
[    2.397646] SyncLink GT no devices found
[    2.398003] SyncLink MultiPort driver $Revision: 4.38 $
[    2.398547] bus: 'pci': add driver synclinkmp
[    2.399416] device: 'ttySLM0': device_add
[    2.399828] PM: Adding info for No Bus:ttySLM0
[    2.400404] device: 'ttySLM1': device_add
[    2.401237] PM: Adding info for No Bus:ttySLM1
[    2.401662] device: 'ttySLM2': device_add
[    2.402065] PM: Adding info for No Bus:ttySLM2
[    2.402611] device: 'ttySLM3': device_add
[    2.403435] PM: Adding info for No Bus:ttySLM3
[    2.403854] device: 'ttySLM4': device_add
[    2.404256] PM: Adding info for No Bus:ttySLM4
[    2.404802] device: 'ttySLM5': device_add
[    2.405637] PM: Adding info for No Bus:ttySLM5
[    2.406056] device: 'ttySLM6': device_add
[    2.406545] PM: Adding info for No Bus:ttySLM6
[    2.407044] device: 'ttySLM7': device_add
[    2.407876] PM: Adding info for No Bus:ttySLM7
[    2.408370] device: 'ttySLM8': device_add
[    2.408787] PM: Adding info for No Bus:ttySLM8
[    2.409271] device: 'ttySLM9': device_add
[    2.410134] PM: Adding info for No Bus:ttySLM9
[    2.410635] device: 'ttySLM10': device_add
[    2.411046] PM: Adding info for No Bus:ttySLM10
[    2.411535] device: 'ttySLM11': device_add
[    2.412443] PM: Adding info for No Bus:ttySLM11
[    2.412869] device: 'ttySLM12': device_add
[    2.413285] PM: Adding info for No Bus:ttySLM12
[    2.413762] device: 'ttySLM13': device_add
[    2.414663] PM: Adding info for No Bus:ttySLM13
[    2.415089] device: 'ttySLM14': device_add
[    2.415504] PM: Adding info for No Bus:ttySLM14
[    2.415988] device: 'ttySLM15': device_add
[    2.416899] PM: Adding info for No Bus:ttySLM15
[    2.417330] device: 'ttySLM16': device_add
[    2.417741] PM: Adding info for No Bus:ttySLM16
[    2.418212] device: 'ttySLM17': device_add
[    2.419112] PM: Adding info for No Bus:ttySLM17
[    2.419546] device: 'ttySLM18': device_add
[    2.419963] PM: Adding info for No Bus:ttySLM18
[    2.420557] device: 'ttySLM19': device_add
[    2.421398] PM: Adding info for No Bus:ttySLM19
[    2.421824] device: 'ttySLM20': device_add
[    2.422233] PM: Adding info for No Bus:ttySLM20
[    2.422782] device: 'ttySLM21': device_add
[    2.423608] PM: Adding info for No Bus:ttySLM21
[    2.424037] device: 'ttySLM22': device_add
[    2.424529] PM: Adding info for No Bus:ttySLM22
[    2.424997] device: 'ttySLM23': device_add
[    2.425828] PM: Adding info for No Bus:ttySLM23
[    2.426264] device: 'ttySLM24': device_add
[    2.426759] PM: Adding info for No Bus:ttySLM24
[    2.427227] device: 'ttySLM25': device_add
[    2.428056] PM: Adding info for No Bus:ttySLM25
[    2.428564] device: 'ttySLM26': device_add
[    2.428987] PM: Adding info for No Bus:ttySLM26
[    2.429472] device: 'ttySLM27': device_add
[    2.430409] PM: Adding info for No Bus:ttySLM27
[    2.430834] device: 'ttySLM28': device_add
[    2.431246] PM: Adding info for No Bus:ttySLM28
[    2.431731] device: 'ttySLM29': device_add
[    2.432624] PM: Adding info for No Bus:ttySLM29
[    2.433054] device: 'ttySLM30': device_add
[    2.433486] PM: Adding info for No Bus:ttySLM30
[    2.433953] device: 'ttySLM31': device_add
[    2.434856] PM: Adding info for No Bus:ttySLM31
[    2.435288] device: 'ttySLM32': device_add
[    2.435700] PM: Adding info for No Bus:ttySLM32
[    2.436170] device: 'ttySLM33': device_add
[    2.437075] PM: Adding info for No Bus:ttySLM33
[    2.437508] device: 'ttySLM34': device_add
[    2.437920] PM: Adding info for No Bus:ttySLM34
[    2.438473] device: 'ttySLM35': device_add
[    2.439304] PM: Adding info for No Bus:ttySLM35
[    2.439732] device: 'ttySLM36': device_add
[    2.440179] PM: Adding info for No Bus:ttySLM36
[    2.440699] device: 'ttySLM37': device_add
[    2.441530] PM: Adding info for No Bus:ttySLM37
[    2.441957] device: 'ttySLM38': device_add
[    2.442453] PM: Adding info for No Bus:ttySLM38
[    2.442922] device: 'ttySLM39': device_add
[    2.443761] PM: Adding info for No Bus:ttySLM39
[    2.444188] device: 'ttySLM40': device_add
[    2.444685] PM: Adding info for No Bus:ttySLM40
[    2.445158] device: 'ttySLM41': device_add
[    2.445996] PM: Adding info for No Bus:ttySLM41
[    2.446512] device: 'ttySLM42': device_add
[    2.446924] PM: Adding info for No Bus:ttySLM42
[    2.447399] device: 'ttySLM43': device_add
[    2.448232] PM: Adding info for No Bus:ttySLM43
[    2.448744] device: 'ttySLM44': device_add
[    2.449156] PM: Adding info for No Bus:ttySLM44
[    2.449630] device: 'ttySLM45': device_add
[    2.450552] PM: Adding info for No Bus:ttySLM45
[    2.450979] device: 'ttySLM46': device_add
[    2.451395] PM: Adding info for No Bus:ttySLM46
[    2.451874] device: 'ttySLM47': device_add
[    2.452783] PM: Adding info for No Bus:ttySLM47
[    2.453210] device: 'ttySLM48': device_add
[    2.453626] PM: Adding info for No Bus:ttySLM48
[    2.454093] device: 'ttySLM49': device_add
[    2.454999] PM: Adding info for No Bus:ttySLM49
[    2.455430] device: 'ttySLM50': device_add
[    2.455840] PM: Adding info for No Bus:ttySLM50
[    2.456381] device: 'ttySLM51': device_add
[    2.457211] PM: Adding info for No Bus:ttySLM51
[    2.457642] device: 'ttySLM52': device_add
[    2.458050] PM: Adding info for No Bus:ttySLM52
[    2.458603] device: 'ttySLM53': device_add
[    2.459436] PM: Adding info for No Bus:ttySLM53
[    2.459864] device: 'ttySLM54': device_add
[    2.460343] PM: Adding info for No Bus:ttySLM54
[    2.460822] device: 'ttySLM55': device_add
[    2.461655] PM: Adding info for No Bus:ttySLM55
[    2.462084] device: 'ttySLM56': device_add
[    2.462578] PM: Adding info for No Bus:ttySLM56
[    2.463046] device: 'ttySLM57': device_add
[    2.463880] PM: Adding info for No Bus:ttySLM57
[    2.464390] device: 'ttySLM58': device_add
[    2.464805] PM: Adding info for No Bus:ttySLM58
[    2.465274] device: 'ttySLM59': device_add
[    2.466106] PM: Adding info for No Bus:ttySLM59
[    2.466613] device: 'ttySLM60': device_add
[    2.467026] PM: Adding info for No Bus:ttySLM60
[    2.467500] device: 'ttySLM61': device_add
[    2.468406] PM: Adding info for No Bus:ttySLM61
[    2.468837] device: 'ttySLM62': device_add
[    2.469252] PM: Adding info for No Bus:ttySLM62
[    2.469724] device: 'ttySLM63': device_add
[    2.470650] PM: Adding info for No Bus:ttySLM63
[    2.471076] device: 'ttySLM64': device_add
[    2.471493] PM: Adding info for No Bus:ttySLM64
[    2.471967] device: 'ttySLM65': device_add
[    2.472887] PM: Adding info for No Bus:ttySLM65
[    2.473319] device: 'ttySLM66': device_add
[    2.473730] PM: Adding info for No Bus:ttySLM66
[    2.474200] device: 'ttySLM67': device_add
[    2.475109] PM: Adding info for No Bus:ttySLM67
[    2.475542] device: 'ttySLM68': device_add
[    2.475953] PM: Adding info for No Bus:ttySLM68
[    2.476505] device: 'ttySLM69': device_add
[    2.477340] PM: Adding info for No Bus:ttySLM69
[    2.477766] device: 'ttySLM70': device_add
[    2.478175] PM: Adding info for No Bus:ttySLM70
[    2.478722] device: 'ttySLM71': device_add
[    2.479557] PM: Adding info for No Bus:ttySLM71
[    2.479984] device: 'ttySLM72': device_add
[    2.480511] PM: Adding info for No Bus:ttySLM72
[    2.480989] device: 'ttySLM73': device_add
[    2.481832] PM: Adding info for No Bus:ttySLM73
[    2.482257] device: 'ttySLM74': device_add
[    2.482746] PM: Adding info for No Bus:ttySLM74
[    2.483221] device: 'ttySLM75': device_add
[    2.484064] PM: Adding info for No Bus:ttySLM75
[    2.484570] device: 'ttySLM76': device_add
[    2.484981] PM: Adding info for No Bus:ttySLM76
[    2.485460] device: 'ttySLM77': device_add
[    2.486371] PM: Adding info for No Bus:ttySLM77
[    2.486800] device: 'ttySLM78': device_add
[    2.487213] PM: Adding info for No Bus:ttySLM78
[    2.487695] device: 'ttySLM79': device_add
[    2.488614] PM: Adding info for No Bus:ttySLM79
[    2.489040] device: 'ttySLM80': device_add
[    2.489466] PM: Adding info for No Bus:ttySLM80
[    2.489941] device: 'ttySLM81': device_add
[    2.490888] PM: Adding info for No Bus:ttySLM81
[    2.491323] device: 'ttySLM82': device_add
[    2.491734] PM: Adding info for No Bus:ttySLM82
[    2.492209] device: 'ttySLM83': device_add
[    2.493130] PM: Adding info for No Bus:ttySLM83
[    2.493559] device: 'ttySLM84': device_add
[    2.493970] PM: Adding info for No Bus:ttySLM84
[    2.494532] device: 'ttySLM85': device_add
[    2.495378] PM: Adding info for No Bus:ttySLM85
[    2.495804] device: 'ttySLM86': device_add
[    2.496214] PM: Adding info for No Bus:ttySLM86
[    2.496767] device: 'ttySLM87': device_add
[    2.497614] PM: Adding info for No Bus:ttySLM87
[    2.498040] device: 'ttySLM88': device_add
[    2.498534] PM: Adding info for No Bus:ttySLM88
[    2.499006] device: 'ttySLM89': device_add
[    2.499854] PM: Adding info for No Bus:ttySLM89
[    2.500382] device: 'ttySLM90': device_add
[    2.500828] PM: Adding info for No Bus:ttySLM90
[    2.501311] device: 'ttySLM91': device_add
[    2.502171] PM: Adding info for No Bus:ttySLM91
[    2.502679] device: 'ttySLM92': device_add
[    2.503090] PM: Adding info for No Bus:ttySLM92
[    2.503572] device: 'ttySLM93': device_add
[    2.504487] PM: Adding info for No Bus:ttySLM93
[    2.504913] device: 'ttySLM94': device_add
[    2.505331] PM: Adding info for No Bus:ttySLM94
[    2.505808] device: 'ttySLM95': device_add
[    2.506729] PM: Adding info for No Bus:ttySLM95
[    2.507157] device: 'ttySLM96': device_add
[    2.507574] PM: Adding info for No Bus:ttySLM96
[    2.508049] device: 'ttySLM97': device_add
[    2.508977] PM: Adding info for No Bus:ttySLM97
[    2.509406] device: 'ttySLM98': device_add
[    2.509817] PM: Adding info for No Bus:ttySLM98
[    2.510394] device: 'ttySLM99': device_add
[    2.511245] PM: Adding info for No Bus:ttySLM99
[    2.511689] device: 'ttySLM100': device_add
[    2.512108] PM: Adding info for No Bus:ttySLM100
[    2.512671] device: 'ttySLM101': device_add
[    2.513532] PM: Adding info for No Bus:ttySLM101
[    2.513967] device: 'ttySLM102': device_add
[    2.514464] PM: Adding info for No Bus:ttySLM102
[    2.514952] device: 'ttySLM103': device_add
[    2.515819] PM: Adding info for No Bus:ttySLM103
[    2.516250] device: 'ttySLM104': device_add
[    2.516755] PM: Adding info for No Bus:ttySLM104
[    2.517234] device: 'ttySLM105': device_add
[    2.518099] PM: Adding info for No Bus:ttySLM105
[    2.518614] device: 'ttySLM106': device_add
[    2.519033] PM: Adding info for No Bus:ttySLM106
[    2.519521] device: 'ttySLM107': device_add
[    2.520438] PM: Adding info for No Bus:ttySLM107
[    2.520872] device: 'ttySLM108': device_add
[    2.521294] PM: Adding info for No Bus:ttySLM108
[    2.521778] device: 'ttySLM109': device_add
[    2.522706] PM: Adding info for No Bus:ttySLM109
[    2.523141] device: 'ttySLM110': device_add
[    2.523564] PM: Adding info for No Bus:ttySLM110
[    2.524045] device: 'ttySLM111': device_add
[    2.524983] PM: Adding info for No Bus:ttySLM111
[    2.525421] device: 'ttySLM112': device_add
[    2.525838] PM: Adding info for No Bus:ttySLM112
[    2.526388] device: 'ttySLM113': device_add
[    2.527245] PM: Adding info for No Bus:ttySLM113
[    2.527683] device: 'ttySLM114': device_add
[    2.528098] PM: Adding info for No Bus:ttySLM114
[    2.528661] device: 'ttySLM115': device_add
[    2.529515] PM: Adding info for No Bus:ttySLM115
[    2.529947] device: 'ttySLM116': device_add
[    2.530471] PM: Adding info for No Bus:ttySLM116
[    2.530956] device: 'ttySLM117': device_add
[    2.531816] PM: Adding info for No Bus:ttySLM117
[    2.532246] device: 'ttySLM118': device_add
[    2.532747] PM: Adding info for No Bus:ttySLM118
[    2.533238] device: 'ttySLM119': device_add
[    2.534098] PM: Adding info for No Bus:ttySLM119
[    2.534609] device: 'ttySLM120': device_add
[    2.535025] PM: Adding info for No Bus:ttySLM120
[    2.535513] device: 'ttySLM121': device_add
[    2.536440] PM: Adding info for No Bus:ttySLM121
[    2.536881] device: 'ttySLM122': device_add
[    2.537306] PM: Adding info for No Bus:ttySLM122
[    2.537787] device: 'ttySLM123': device_add
[    2.538723] PM: Adding info for No Bus:ttySLM123
[    2.539156] device: 'ttySLM124': device_add
[    2.539582] PM: Adding info for No Bus:ttySLM124
[    2.540095] device: 'ttySLM125': device_add
[    2.540985] PM: Adding info for No Bus:ttySLM125
[    2.541566] device: 'ttySLM126': device_add
[    2.541987] PM: Adding info for No Bus:ttySLM126
[    2.542566] device: 'ttySLM127': device_add
[    2.543445] PM: Adding info for No Bus:ttySLM127
[    2.543873] SyncLink MultiPort driver $Revision: 4.38 $, tty major#249
[    2.544527] SyncLink serial driver $Revision: 4.38 $
[    2.544967] bus: 'pci': add driver synclink
[    2.545685] device: 'ttySL0': device_add
[    2.546236] PM: Adding info for No Bus:ttySL0
[    2.546784] device: 'ttySL1': device_add
[    2.547489] PM: Adding info for No Bus:ttySL1
[    2.548059] device: 'ttySL2': device_add
[    2.548698] PM: Adding info for No Bus:ttySL2
[    2.549171] device: 'ttySL3': device_add
[    2.549870] PM: Adding info for No Bus:ttySL3
[    2.550390] device: 'ttySL4': device_add
[    2.550934] PM: Adding info for No Bus:ttySL4
[    2.551549] device: 'ttySL5': device_add
[    2.552256] PM: Adding info for No Bus:ttySL5
[    2.552745] device: 'ttySL6': device_add
[    2.553301] PM: Adding info for No Bus:ttySL6
[    2.553764] device: 'ttySL7': device_add
[    2.554542] PM: Adding info for No Bus:ttySL7
[    2.555106] device: 'ttySL8': device_add
[    2.555675] PM: Adding info for No Bus:ttySL8
[    2.556148] device: 'ttySL9': device_add
[    2.556922] PM: Adding info for No Bus:ttySL9
[    2.557338] device: 'ttySL10': device_add
[    2.557886] PM: Adding info for No Bus:ttySL10
[    2.558587] device: 'ttySL11': device_add
[    2.559306] PM: Adding info for No Bus:ttySL11
[    2.559723] device: 'ttySL12': device_add
[    2.560360] PM: Adding info for No Bus:ttySL12
[    2.560834] device: 'ttySL13': device_add
[    2.561541] PM: Adding info for No Bus:ttySL13
[    2.562116] device: 'ttySL14': device_add
[    2.562770] PM: Adding info for No Bus:ttySL14
[    2.563251] device: 'ttySL15': device_add
[    2.563959] PM: Adding info for No Bus:ttySL15
[    2.564457] device: 'ttySL16': device_add
[    2.565009] PM: Adding info for No Bus:ttySL16
[    2.565630] device: 'ttySL17': device_add
[    2.566422] PM: Adding info for No Bus:ttySL17
[    2.566844] device: 'ttySL18': device_add
[    2.567413] PM: Adding info for No Bus:ttySL18
[    2.567885] device: 'ttySL19': device_add
[    2.568662] PM: Adding info for No Bus:ttySL19
[    2.569230] device: 'ttySL20': device_add
[    2.569805] PM: Adding info for No Bus:ttySL20
[    2.570380] device: 'ttySL21': device_add
[    2.571085] PM: Adding info for No Bus:ttySL21
[    2.571505] device: 'ttySL22': device_add
[    2.572053] PM: Adding info for No Bus:ttySL22
[    2.572749] device: 'ttySL23': device_add
[    2.573467] PM: Adding info for No Bus:ttySL23
[    2.573882] device: 'ttySL24': device_add
[    2.574520] PM: Adding info for No Bus:ttySL24
[    2.574994] device: 'ttySL25': device_add
[    2.575707] PM: Adding info for No Bus:ttySL25
[    2.576347] device: 'ttySL26': device_add
[    2.576929] PM: Adding info for No Bus:ttySL26
[    2.577413] device: 'ttySL27': device_add
[    2.578114] PM: Adding info for No Bus:ttySL27
[    2.578611] device: 'ttySL28': device_add
[    2.579163] PM: Adding info for No Bus:ttySL28
[    2.579789] device: 'ttySL29': device_add
[    2.580578] PM: Adding info for No Bus:ttySL29
[    2.580996] device: 'ttySL30': device_add
[    2.581568] PM: Adding info for No Bus:ttySL30
[    2.582039] device: 'ttySL31': device_add
[    2.582821] PM: Adding info for No Bus:ttySL31
[    2.583400] device: 'ttySL32': device_add
[    2.583968] PM: Adding info for No Bus:ttySL32
[    2.584524] device: 'ttySL33': device_add
[    2.585225] PM: Adding info for No Bus:ttySL33
[    2.585647] device: 'ttySL34': device_add
[    2.586200] PM: Adding info for No Bus:ttySL34
[    2.586890] device: 'ttySL35': device_add
[    2.587607] PM: Adding info for No Bus:ttySL35
[    2.588024] device: 'ttySL36': device_add
[    2.588678] PM: Adding info for No Bus:ttySL36
[    2.589150] device: 'ttySL37': device_add
[    2.589858] PM: Adding info for No Bus:ttySL37
[    2.590531] device: 'ttySL38': device_add
[    2.591106] PM: Adding info for No Bus:ttySL38
[    2.591592] device: 'ttySL39': device_add
[    2.592372] PM: Adding info for No Bus:ttySL39
[    2.592796] device: 'ttySL40': device_add
[    2.593358] PM: Adding info for No Bus:ttySL40
[    2.593975] device: 'ttySL41': device_add
[    2.594773] PM: Adding info for No Bus:ttySL41
[    2.595189] device: 'ttySL42': device_add
[    2.595761] PM: Adding info for No Bus:ttySL42
[    2.596233] device: 'ttySL43': device_add
[    2.597023] PM: Adding info for No Bus:ttySL43
[    2.597600] device: 'ttySL44': device_add
[    2.598173] PM: Adding info for No Bus:ttySL44
[    2.598728] device: 'ttySL45': device_add
[    2.599439] PM: Adding info for No Bus:ttySL45
[    2.599860] device: 'ttySL46': device_add
[    2.600517] PM: Adding info for No Bus:ttySL46
[    2.601145] device: 'ttySL47': device_add
[    2.601869] PM: Adding info for No Bus:ttySL47
[    2.602367] device: 'ttySL48': device_add
[    2.602936] PM: Adding info for No Bus:ttySL48
[    2.603412] device: 'ttySL49': device_add
[    2.604115] PM: Adding info for No Bus:ttySL49
[    2.604766] device: 'ttySL50': device_add
[    2.605345] PM: Adding info for No Bus:ttySL50
[    2.605824] device: 'ttySL51': device_add
[    2.606602] PM: Adding info for No Bus:ttySL51
[    2.607022] device: 'ttySL52': device_add
[    2.607585] PM: Adding info for No Bus:ttySL52
[    2.608201] device: 'ttySL53': device_add
[    2.608995] PM: Adding info for No Bus:ttySL53
[    2.609418] device: 'ttySL54': device_add
[    2.609989] PM: Adding info for No Bus:ttySL54
[    2.610556] device: 'ttySL55': device_add
[    2.611259] PM: Adding info for No Bus:ttySL55
[    2.611832] device: 'ttySL56': device_add
[    2.612492] PM: Adding info for No Bus:ttySL56
[    2.612968] device: 'ttySL57': device_add
[    2.613682] PM: Adding info for No Bus:ttySL57
[    2.614103] device: 'ttySL58': device_add
[    2.614743] PM: Adding info for No Bus:ttySL58
[    2.615365] device: 'ttySL59': device_add
[    2.616081] PM: Adding info for No Bus:ttySL59
[    2.616585] device: 'ttySL60': device_add
[    2.617155] PM: Adding info for No Bus:ttySL60
[    2.617629] device: 'ttySL61': device_add
[    2.618417] PM: Adding info for No Bus:ttySL61
[    2.618986] device: 'ttySL62': device_add
[    2.619570] PM: Adding info for No Bus:ttySL62
[    2.620066] device: 'ttySL63': device_add
[    2.620849] PM: Adding info for No Bus:ttySL63
[    2.621271] device: 'ttySL64': device_add
[    2.621829] PM: Adding info for No Bus:ttySL64
[    2.622526] device: 'ttySL65': device_add
[    2.623242] PM: Adding info for No Bus:ttySL65
[    2.623663] device: 'ttySL66': device_add
[    2.624233] PM: Adding info for No Bus:ttySL66
[    2.624785] device: 'ttySL67': device_add
[    2.625495] PM: Adding info for No Bus:ttySL67
[    2.626065] device: 'ttySL68': device_add
[    2.626727] PM: Adding info for No Bus:ttySL68
[    2.627205] device: 'ttySL69': device_add
[    2.627915] PM: Adding info for No Bus:ttySL69
[    2.628412] device: 'ttySL70': device_add
[    2.628973] PM: Adding info for No Bus:ttySL70
[    2.629595] device: 'ttySL71': device_add
[    2.630403] PM: Adding info for No Bus:ttySL71
[    2.630818] device: 'ttySL72': device_add
[    2.631393] PM: Adding info for No Bus:ttySL72
[    2.631862] device: 'ttySL73': device_add
[    2.632640] PM: Adding info for No Bus:ttySL73
[    2.633214] device: 'ttySL74': device_add
[    2.633799] PM: Adding info for No Bus:ttySL74
[    2.634349] device: 'ttySL75': device_add
[    2.635065] PM: Adding info for No Bus:ttySL75
[    2.635488] device: 'ttySL76': device_add
[    2.636047] PM: Adding info for No Bus:ttySL76
[    2.636749] device: 'ttySL77': device_add
[    2.637474] PM: Adding info for No Bus:ttySL77
[    2.637893] device: 'ttySL78': device_add
[    2.638544] PM: Adding info for No Bus:ttySL78
[    2.639016] device: 'ttySL79': device_add
[    2.639732] PM: Adding info for No Bus:ttySL79
[    2.640395] device: 'ttySL80': device_add
[    2.640977] PM: Adding info for No Bus:ttySL80
[    2.641461] device: 'ttySL81': device_add
[    2.642167] PM: Adding info for No Bus:ttySL81
[    2.642666] device: 'ttySL82': device_add
[    2.643228] PM: Adding info for No Bus:ttySL82
[    2.643859] device: 'ttySL83': device_add
[    2.644651] PM: Adding info for No Bus:ttySL83
[    2.645071] device: 'ttySL84': device_add
[    2.645654] PM: Adding info for No Bus:ttySL84
[    2.646125] device: 'ttySL85': device_add
[    2.646913] PM: Adding info for No Bus:ttySL85
[    2.647489] device: 'ttySL86': device_add
[    2.648067] PM: Adding info for No Bus:ttySL86
[    2.648628] device: 'ttySL87': device_add
[    2.649340] PM: Adding info for No Bus:ttySL87
[    2.649757] device: 'ttySL88': device_add
[    2.650418] PM: Adding info for No Bus:ttySL88
[    2.651038] device: 'ttySL89': device_add
[    2.651763] PM: Adding info for No Bus:ttySL89
[    2.652181] device: 'ttySL90': device_add
[    2.652837] PM: Adding info for No Bus:ttySL90
[    2.653309] device: 'ttySL91': device_add
[    2.654013] PM: Adding info for No Bus:ttySL91
[    2.654666] device: 'ttySL92': device_add
[    2.655248] PM: Adding info for No Bus:ttySL92
[    2.655733] device: 'ttySL93': device_add
[    2.656512] PM: Adding info for No Bus:ttySL93
[    2.656926] device: 'ttySL94': device_add
[    2.657493] PM: Adding info for No Bus:ttySL94
[    2.658111] device: 'ttySL95': device_add
[    2.658908] PM: Adding info for No Bus:ttySL95
[    2.659327] device: 'ttySL96': device_add
[    2.659901] PM: Adding info for No Bus:ttySL96
[    2.660472] device: 'ttySL97': device_add
[    2.661185] PM: Adding info for No Bus:ttySL97
[    2.661761] device: 'ttySL98': device_add
[    2.662439] PM: Adding info for No Bus:ttySL98
[    2.663062] device: 'ttySL99': device_add
[    2.663796] PM: Adding info for No Bus:ttySL99
[    2.664214] device: 'ttySL100': device_add
[    2.664894] PM: Adding info for No Bus:ttySL100
[    2.665380] device: 'ttySL101': device_add
[    2.666093] PM: Adding info for No Bus:ttySL101
[    2.666741] device: 'ttySL102': device_add
[    2.667345] PM: Adding info for No Bus:ttySL102
[    2.667834] device: 'ttySL103': device_add
[    2.668623] PM: Adding info for No Bus:ttySL103
[    2.669050] device: 'ttySL104': device_add
[    2.669629] PM: Adding info for No Bus:ttySL104
[    2.670352] device: 'ttySL105': device_add
[    2.671085] PM: Adding info for No Bus:ttySL105
[    2.671516] device: 'ttySL106': device_add
[    2.672101] PM: Adding info for No Bus:ttySL106
[    2.672657] device: 'ttySL107': device_add
[    2.673378] PM: Adding info for No Bus:ttySL107
[    2.673958] device: 'ttySL108': device_add
[    2.674631] PM: Adding info for No Bus:ttySL108
[    2.675119] device: 'ttySL109': device_add
[    2.675840] PM: Adding info for No Bus:ttySL109
[    2.676338] device: 'ttySL110': device_add
[    2.676920] PM: Adding info for No Bus:ttySL110
[    2.677552] device: 'ttySL111': device_add
[    2.678356] PM: Adding info for No Bus:ttySL111
[    2.678785] device: 'ttySL112': device_add
[    2.679378] PM: Adding info for No Bus:ttySL112
[    2.679859] device: 'ttySL113': device_add
[    2.680675] PM: Adding info for No Bus:ttySL113
[    2.681257] device: 'ttySL114': device_add
[    2.681851] PM: Adding info for No Bus:ttySL114
[    2.682427] device: 'ttySL115': device_add
[    2.683145] PM: Adding info for No Bus:ttySL115
[    2.683582] device: 'ttySL116': device_add
[    2.684159] PM: Adding info for No Bus:ttySL116
[    2.684869] device: 'ttySL117': device_add
[    2.685603] PM: Adding info for No Bus:ttySL117
[    2.686030] device: 'ttySL118': device_add
[    2.686708] PM: Adding info for No Bus:ttySL118
[    2.687187] device: 'ttySL119': device_add
[    2.687909] PM: Adding info for No Bus:ttySL119
[    2.688579] device: 'ttySL120': device_add
[    2.689171] PM: Adding info for No Bus:ttySL120
[    2.689661] device: 'ttySL121': device_add
[    2.690477] PM: Adding info for No Bus:ttySL121
[    2.690902] device: 'ttySL122': device_add
[    2.691481] PM: Adding info for No Bus:ttySL122
[    2.692111] device: 'ttySL123': device_add
[    2.692929] PM: Adding info for No Bus:ttySL123
[    2.693364] device: 'ttySL124': device_add
[    2.693956] PM: Adding info for No Bus:ttySL124
[    2.694520] device: 'ttySL125': device_add
[    2.695234] PM: Adding info for No Bus:ttySL125
[    2.695821] device: 'ttySL126': device_add
[    2.696495] PM: Adding info for No Bus:ttySL126
[    2.696983] device: 'ttySL127': device_add
[    2.697708] PM: Adding info for No Bus:ttySL127
[    2.698128] SyncLink serial driver $Revision: 4.38 $, tty major#248
[    2.698801] device: 'ttyprintk': device_add
[    2.699392] PM: Adding info for No Bus:ttyprintk
[    2.699875] device class 'virtio-ports': registering
[    2.700943] bus: 'virtio': add driver virtio_console
[    2.701418] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[    2.702056] ac.o: No PCI boards found.
[    2.702476] ac.o: For an ISA board you must supply memory and irq parameters.
[    2.703116] device: 'hpet': device_add
[    2.703697] PM: Adding info for No Bus:hpet
[    2.704149] bus: 'acpi': add driver hpet
[    2.704612] bus: 'acpi': driver_probe_device: matched device PNP0103:00 with driver hpet
[    2.705328] bus: 'acpi': really_probe: probing driver hpet with device PNP0103:00
[    2.706109] hpet: probe of PNP0103:00 rejects match -19
[    2.706727] device: 'nvram': device_add
[    2.707431] PM: Adding info for No Bus:nvram
[    2.707841] Non-volatile memory driver v1.3
[    2.708232] bus: 'virtio': add driver virtio_rng
[    2.708905] Linux agpgart interface v0.103
[    2.709287] bus: 'pci': add driver agpgart-sis
[    2.709715] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[    2.710596] Hangcheck: Using getrawmonotonic().
[    2.711013] bus: 'pnp': add driver tpm_tis
[    2.711580] bus: 'platform': add driver tpm_atmel
[    2.712083] bus: 'platform': remove driver tpm_atmel
[    2.712615] driver: 'tpm_atmel': driver_release
[    2.713019] bus: 'pnp': add driver tpm_inf_pnp
[    2.713811] device: 'loop-control': device_add
[    2.714338] PM: Adding info for No Bus:loop-control
[    2.715356] device: '7:0': device_add
[    2.715802] PM: Adding info for No Bus:7:0
[    2.715906] bus: 'platform': add driver floppy
[    2.716068] Floppy drive(s): fd0 is 1.44M
[    2.717247] device: 'loop0': device_add
[    2.717869] PM: Adding info for No Bus:loop0
[    2.718897] device: '7:1': device_add
[    2.719433] PM: Adding info for No Bus:7:1
[    2.720227] device: 'loop1': device_add
[    2.721192] PM: Adding info for No Bus:loop1
[    2.722359] device: '7:2': device_add
[    2.722723] PM: Adding info for No Bus:7:2
[    2.723428] device: 'loop2': device_add
[    2.724018] PM: Adding info for No Bus:loop2
[    2.725165] device: '7:3': device_add
[    2.725693] PM: Adding info for No Bus:7:3
[    2.726543] device: 'loop3': device_add
[    2.727439] PM: Adding info for No Bus:loop3
[    2.728459] device: '7:4': device_add
[    2.728993] PM: Adding info for No Bus:7:4
[    2.729715] device: 'loop4': device_add
[    2.730379] PM: Adding info for No Bus:loop4
[    2.731164] FDC 0 is a S82078B
[    2.731512] device: '7:5': device_add
[    2.731995] PM: Adding info for No Bus:7:5
[    2.732047] Registering platform device 'floppy.0'. Parent at platform
[    2.732052] device: 'floppy.0': device_add
[    2.732066] bus: 'platform': add device floppy.0
[    2.732279] PM: Adding info for platform:floppy.0
[    2.732363] bus: 'platform': driver_probe_device: matched device floppy.0 with driver floppy
[    2.732364] bus: 'platform': really_probe: probing driver floppy with device floppy.0
[    2.732374] driver: 'floppy.0': driver_bound: bound to device 'floppy'
[    2.732377] bus: 'platform': really_probe: bound device floppy.0 to driver floppy
[    2.732564] device: '2:0': device_add
[    2.732599] PM: Adding info for No Bus:2:0
[    2.733019] device: 'fd0': device_add
[    2.738464] device: 'loop5': device_add
[    2.739602] PM: Adding info for No Bus:loop5
[    2.739605] PM: Adding info for No Bus:fd0
[    2.741191] device: '7:6': device_add
[    2.741560] PM: Adding info for No Bus:7:6
[    2.742390] device: 'loop6': device_add
[    2.743323] PM: Adding info for No Bus:loop6
[    2.744521] device: '7:7': device_add
[    2.745052] PM: Adding info for No Bus:7:7
[    2.745778] device: 'loop7': device_add
[    2.746456] PM: Adding info for No Bus:loop7
[    2.747125] loop: module loaded
[    2.747422] Compaq SMART2 Driver (v 2.6.0)
[    2.747790] bus: 'pci': add driver cpqarray
[    2.748519] bus: 'pci': remove driver cpqarray
[    2.748976] driver: 'cpqarray': driver_release
[    2.749417] device class 'pktcdvd': registering
[    2.750644] device: 'pktcdvd': device_add
[    2.751413] PM: Adding info for No Bus:pktcdvd
[    2.751827] device class 'osdblk': registering
[    2.752672] bus: 'virtio': add driver virtio_blk
[    2.753097] bus: 'virtio': driver_probe_device: matched device virtio0 with driver virtio_blk
[    2.753850] bus: 'virtio': really_probe: probing driver virtio_blk with device virtio0
[    2.754891] virtio-pci 0000:00:05.0: irq 40 for MSI/MSI-X
[    2.755419] virtio-pci 0000:00:05.0: irq 41 for MSI/MSI-X
[    2.769656] device: '252:0': device_add
[    2.770054] PM: Adding info for No Bus:252:0
[    2.770500] device: 'vda': device_add
[    2.771537] PM: Adding info for No Bus:vda
[    2.772864]  vda: unknown partition table
[    2.774037] driver: 'virtio0': driver_bound: bound to device 'virtio_blk'
[    2.774654] bus: 'virtio': really_probe: bound device virtio0 to driver virtio_blk
[    2.775404] bus: 'virtio': driver_probe_device: matched device virtio1 with driver virtio_blk
[    2.776157] bus: 'virtio': really_probe: probing driver virtio_blk with device virtio1
[    2.777411] virtio-pci 0000:00:06.0: irq 42 for MSI/MSI-X
[    2.777934] virtio-pci 0000:00:06.0: irq 43 for MSI/MSI-X
[    2.792211] device: '252:16': device_add
[    2.792908] PM: Adding info for No Bus:252:16
[    2.793345] device: 'vdb': device_add
[    2.794344] PM: Adding info for No Bus:vdb
[    2.795361]  vdb: unknown partition table
[    2.796434] driver: 'virtio1': driver_bound: bound to device 'virtio_blk'
[    2.797043] bus: 'virtio': really_probe: bound device virtio1 to driver virtio_blk
[    2.797729] bus: 'virtio': driver_probe_device: matched device virtio2 with driver virtio_blk
[    2.798555] bus: 'virtio': really_probe: probing driver virtio_blk with device virtio2
[    2.799737] virtio-pci 0000:00:07.0: irq 44 for MSI/MSI-X
[    2.800499] virtio-pci 0000:00:07.0: irq 45 for MSI/MSI-X
[    2.815149] device: '252:32': device_add
[    2.815812] PM: Adding info for No Bus:252:32
[    2.816614] device: 'vdc': device_add
[    2.817206] PM: Adding info for No Bus:vdc
[    2.818313]  vdc: unknown partition table
[    2.819953] driver: 'virtio2': driver_bound: bound to device 'virtio_blk'
[    2.820598] bus: 'virtio': really_probe: bound device virtio2 to driver virtio_blk
[    2.821343] bus: 'virtio': driver_probe_device: matched device virtio3 with driver virtio_blk
[    2.822104] bus: 'virtio': really_probe: probing driver virtio_blk with device virtio3
[    2.823140] virtio-pci 0000:00:08.0: irq 46 for MSI/MSI-X
[    2.823859] virtio-pci 0000:00:08.0: irq 47 for MSI/MSI-X
[    2.838129] device: '252:48': device_add
[    2.838592] PM: Adding info for No Bus:252:48
[    2.839373] device: 'vdd': device_add
[    2.840588] PM: Adding info for No Bus:vdd
[    2.841264]  vdd: unknown partition table
[    2.842224] driver: 'virtio3': driver_bound: bound to device 'virtio_blk'
[    2.842909] bus: 'virtio': really_probe: bound device virtio3 to driver virtio_blk
[    2.843583] bus: 'virtio': driver_probe_device: matched device virtio4 with driver virtio_blk
[    2.844409] bus: 'virtio': really_probe: probing driver virtio_blk with device virtio4
[    2.845482] virtio-pci 0000:00:09.0: irq 48 for MSI/MSI-X
[    2.846114] virtio-pci 0000:00:09.0: irq 49 for MSI/MSI-X
[    2.859818] device: '252:64': device_add
[    2.860229] PM: Adding info for No Bus:252:64
[    2.861381] device: 'vde': device_add
[    2.861973] PM: Adding info for No Bus:vde
[    2.863236]  vde: unknown partition table
[    2.864327] driver: 'virtio4': driver_bound: bound to device 'virtio_blk'
[    2.864949] bus: 'virtio': really_probe: bound device virtio4 to driver virtio_blk
[    2.865642] bus: 'virtio': driver_probe_device: matched device virtio5 with driver virtio_blk
[    2.866443] bus: 'virtio': really_probe: probing driver virtio_blk with device virtio5
[    2.868058] virtio-pci 0000:00:0a.0: irq 50 for MSI/MSI-X
[    2.868736] virtio-pci 0000:00:0a.0: irq 51 for MSI/MSI-X
[    2.882756] device: '252:80': device_add
[    2.883552] PM: Adding info for No Bus:252:80
[    2.884361] device: 'vdf': device_add
[    2.885498] PM: Adding info for No Bus:vdf
[    2.886354]  vdf: unknown partition table
[    2.887471] driver: 'virtio5': driver_bound: bound to device 'virtio_blk'
[    2.888068] bus: 'virtio': really_probe: bound device virtio5 to driver virtio_blk
[    2.888959] bus: 'pci': add driver pciPTI
[    2.889813] lkdtm: No crash points registered, enable through debugfs
[    2.890412] device class 'enclosure': registering
[    2.891070] device class 'iLO': registering
[    2.891584] bus: 'pci': add driver hpilo
[    2.892205] bus: 'pci': add driver cb710
[    2.892650] bus: 'pci': add driver pch_phub
[    2.893099] bus: 'platform': add driver kim
[    2.893782] bus: 'platform': add driver pasic3
[    2.894249] bus: 'platform': remove driver pasic3
[    2.894719] driver: 'pasic3': driver_release
[    2.895101] bus: 'pci': add driver lpc_sch
[    2.895626] bus: 'pci': add driver lpc_ich
[    2.896228] bus: 'pci': add driver RDC321x Southbridge
[    2.896768] bus: 'pci': add driver vx855
[    2.897193] bus: 'usb': add driver pn533
[    2.897849] usbcore: registered new interface driver pn533
[    2.898340] Uniform Multi-Platform E-IDE driver
[    2.898807] bus: 'ide': registered
[    2.899115] device class 'ide_port': registering
[    2.899694] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    2.901150] piix 0000:00:01.1: not 100% native mode: will probe irqs later
[    2.901860] pci 0000:00:01.1: enabling bus mastering
[    2.902312] pci 0000:00:01.1: setting latency timer to 64
[    2.902798]     ide0: BM-DMA at 0xc1c0-0xc1c7
[    2.903201]     ide1: BM-DMA at 0xc1c8-0xc1cf
[    2.903672] Probing IDE interface ide0...
[    3.510289] device: 'ide0': device_add
[    3.511076] PM: Adding info for No Bus:ide0
[    3.511469] device: 'ide0': device_add
[    3.511826] PM: Adding info for No Bus:ide0
[    3.512336] Probing IDE interface ide1...
[    4.300316] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[    5.020252] device: 'ide1': device_add
[    5.020609] PM: Adding info for No Bus:ide1
[    5.020991] device: 'ide1': device_add
[    5.021681] PM: Adding info for No Bus:ide1
[    5.022073] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[    5.022702] hdc: MWDMA2 mode selected
[    5.023599] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    5.024179] ide1 at 0x170-0x177,0x376 on irq 15
[    5.024918] device: '1.0': device_add
[    5.025368] bus: 'ide': add device 1.0
[    5.025949] PM: Adding info for ide:1.0
[    5.026478] bus: 'pci': add driver AEC62xx_IDE
[    5.026951] bus: 'pci': add driver ALI15x3_IDE
[    5.027676] bus: 'pci': add driver AMD_IDE
[    5.028122] bus: 'pci': add driver SC1200_IDE
[    5.028750] bus: 'pci': add driver HPT366_IDE
[    5.029300] bus: 'pci': add driver JMicron IDE
[    5.029925] bus: 'pci': add driver NS87415_IDE
[    5.030426] bus: 'pci': add driver Opti621_IDE
[    5.030893] bus: 'pci': add driver PIIX_IDE
[    5.031513] bus: 'pci': driver_probe_device: matched device 0000:00:01.1 with driver PIIX_IDE
[    5.032262] bus: 'pci': really_probe: probing driver PIIX_IDE with device 0000:00:01.1
[    5.032960] driver: '0000:00:01.1': driver_bound: bound to device 'PIIX_IDE'
[    5.033652] bus: 'pci': really_probe: bound device 0000:00:01.1 to driver PIIX_IDE
[    5.034387] bus: 'pci': add driver RZ1000_IDE
[    5.034849] bus: 'pci': add driver SiI_IDE
[    5.035519] bus: 'pci': add driver SIS_IDE
[    5.035961] bus: 'pci': add driver SLC90e66_IDE
[    5.036603] bus: 'pci': add driver TC86C001
[    5.037531] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[    5.038383] bus: 'platform': add driver pata_platform
[    5.039046] device class 'raid_devices': registering
[    5.039631] device class 'spi_transport': registering
[    5.040159] device class 'spi_host': registering
[    5.040625] device class 'fc_host': registering
[    5.041329] device class 'fc_vports': registering
[    5.041803] device class 'fc_remote_ports': registering
[    5.042324] device class 'fc_transport': registering
[    5.042816] Loading iSCSI transport class v2.0-870.
[    5.043332] device class 'iscsi_transport': registering
[    5.043961] device class 'iscsi_endpoint': registering
[    5.044475] device class 'iscsi_iface': registering
[    5.044961] device class 'iscsi_host': registering
[    5.045525] device class 'iscsi_connection': registering
[    5.046163] device class 'iscsi_session': registering
[    5.047699] device class 'sas_host': registering
[    5.048440] device class 'sas_phy': registering
[    5.049056] device class 'sas_port': registering
[    5.049606] device class 'sas_device': registering
[    5.050120] device class 'sas_end_device': registering
[    5.050635] device class 'sas_expander': registering
[    5.051326] device class 'srp_host': registering
[    5.051795] device class 'srp_remote_ports': registering
[    5.054302] bus: 'fcoe': registered
[    5.054624] fnic: Cisco FCoE HBA Driver, ver 1.5.0.2
[    5.055524] bus: 'pci': add driver fnic
[    5.055943] bnx2fc: Broadcom NetXtreme II FCoE Driver bnx2fc v1.0.12 (Jun 04, 2012)
[    5.058002] bus: 'pci': add driver advansys
[    5.058459] Loading Adaptec I2O RAID: Version 2.4 Build 5go
[    5.058951] Detecting Adaptec I2O RAID controllers...
[    5.059491] bus: 'pci': add driver arcmsr
[    5.060200] bus: 'pci': add driver aic79xx
[    5.060655] bus: 'pci': add driver ips
[    5.061325] bus: 'pci': remove driver ips
[    5.061739] driver: 'ips': driver_release
[    5.062164] scsi: <fdomain> Detection failed (no card)
[    5.062944] device: 'qla4xxx': device_add
[    5.063597] PM: Adding info for No Bus:qla4xxx
[    5.064028] iscsi: registered transport (qla4xxx)
[    5.064454] bus: 'pci': add driver qla4xxx
[    5.064847] QLogic iSCSI HBA Driver
[    5.065241] Brocade BFA FC/FCOE SCSI driver - version: 3.1.2.0
[    5.065869] bus: 'pci': add driver bfa
[    5.066415] bus: 'pci': add driver dmx3191d
[    5.066820] bus: 'pci': add driver hpsa
[    5.067463] bus: 'pci': add driver sym53c8xx
[    5.068098] bus: 'pci': add driver dc395x
[    5.068494] mpt2sas version 14.100.00.00 loaded
[    5.068993] device: 'mpt2ctl': device_add
[    5.069913] PM: Adding info for No Bus:mpt2ctl
[    5.070434] bus: 'pci': add driver mpt2sas
[    5.070874] bus: 'pci': add driver inia100
[    5.071582] 3ware Storage Controller device driver for Linux v1.26.02.003.
[    5.072191] bus: 'pci': add driver 3w-xxxx
[    5.072625] 3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
[    5.073351] bus: 'pci': add driver 3w-9xxx
[    5.073954] LSI 3ware SAS/SATA-RAID Controller device driver for Linux v3.26.02.000.
[    5.074644] bus: 'pci': add driver 3w-sas
[    5.075086] ipr: IBM Power RAID SCSI Device Driver version: 2.5.4 (July 11, 2012)
[    5.075837] bus: 'pci': add driver ipr
[    5.076249] RocketRAID 3xxx/4xxx Controller driver v1.6 (091225)
[    5.076781] bus: 'pci': add driver hptiop
[    5.077463] stex: Promise SuperTrak EX Driver version: 4.6.0000.4
[    5.078000] bus: 'pci': add driver stex
[    5.078421] libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits, age 0xf, 4 bits.
[    5.079161] libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx 0.
[    5.079786] Chelsio T4 iSCSI Driver cxgb4i v0.9.1 (Aug. 2010)
[    5.080619] device: 'cxgb4i': device_add
[    5.081252] PM: Adding info for No Bus:cxgb4i
[    5.081658] iscsi: registered transport (cxgb4i)
[    5.082085] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.2.2 (Apr 25, 2012)
[    5.082714] device: 'bnx2i': device_add
[    5.083070] PM: Adding info for No Bus:bnx2i
[    5.083604] iscsi: registered transport (bnx2i)
[    5.084857] device: 'be2iscsi': device_add
[    5.085515] PM: Adding info for No Bus:be2iscsi
[    5.085935] iscsi: registered transport (be2iscsi)
[    5.086360] In beiscsi_module_init, tt=ffffffff8253edd0
[    5.086818] bus: 'pci': add driver be2iscsi
[    5.087305] device class 'pmcsas': registering
[    5.087888] bus: 'pci': add driver PMC MaxRAID
[    5.089220] bus: 'virtio': add driver virtio_scsi
[    5.089665] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    5.090231] device class 'scsi_tape': registering
[    5.090835] bus: 'scsi': add driver st
[    5.091466] osst :I: Tape driver with OnStream support version 0.99.4
[    5.091466] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    5.092602] device class 'onstream_tape': registering
[    5.093066] bus: 'scsi': add driver osst
[    5.093517] device class 'scsi_generic': registering
[    5.093979] SCSI Media Changer driver v0.25 
[    5.094364] device class 'scsi_changer': registering
[    5.094979] bus: 'scsi': add driver ch
[    5.095415] bus: 'scsi': add driver ses
[    5.095772] device class 'scsi_osd': registering
[    5.096346] bus: 'scsi': add driver osd
[    5.096899] osd: LOADED open-osd 0.2.1
[    5.104129] device: 'pseudo_0': device_add
[    5.104527] PM: Adding info for No Bus:pseudo_0
[    5.104951] bus: 'pseudo': registered
[    5.105355] bus: 'pseudo': add driver scsi_debug
[    5.107195] device: 'adapter0': device_add
[    5.107577] bus: 'pseudo': add device adapter0
[    5.107975] PM: Adding info for pseudo:adapter0
[    5.108386] bus: 'pseudo': driver_probe_device: matched device adapter0 with driver scsi_debug
[    5.109208] bus: 'pseudo': really_probe: probing driver scsi_debug with device adapter0
[    5.110308] scsi_debug: host protection
[    5.110685] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=8, opts=0x0
[    5.111456] device: 'host0': device_add
[    5.111810] bus: 'scsi': add device host0
[    5.112185] PM: Adding info for scsi:host0
[    5.112804] device: 'host0': device_add
[    5.113461] PM: Adding info for No Bus:host0
[    5.114750] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       0004 PQ: 0 ANSI: 5
[    5.115553] device: 'target0:0:0': device_add
[    5.116074] bus: 'scsi': add device target0:0:0
[    5.116502] PM: Adding info for scsi:target0:0:0
[    5.117002] device: '0:0:0:0': device_add
[    5.117857] bus: 'scsi': add device 0:0:0:0
[    5.118258] PM: Adding info for scsi:0:0:0:0
[    5.118704] bus: 'scsi': driver_probe_device: matched device 0:0:0:0 with driver st
[    5.119456] bus: 'scsi': really_probe: probing driver st with device 0:0:0:0
[    5.120115] st: probe of 0:0:0:0 rejects match -19
[    5.120542] bus: 'scsi': driver_probe_device: matched device 0:0:0:0 with driver osst
[    5.121303] bus: 'scsi': really_probe: probing driver osst with device 0:0:0:0
[    5.121944] osst: probe of 0:0:0:0 rejects match -19
[    5.122392] bus: 'scsi': driver_probe_device: matched device 0:0:0:0 with driver ch
[    5.123058] bus: 'scsi': really_probe: probing driver ch with device 0:0:0:0
[    5.123772] ch: probe of 0:0:0:0 rejects match -19
[    5.124203] bus: 'scsi': driver_probe_device: matched device 0:0:0:0 with driver ses
[    5.124874] bus: 'scsi': really_probe: probing driver ses with device 0:0:0:0
[    5.125587] ses: probe of 0:0:0:0 rejects match -19
[    5.126042] bus: 'scsi': driver_probe_device: matched device 0:0:0:0 with driver osd
[    5.126724] bus: 'scsi': really_probe: probing driver osd with device 0:0:0:0
[    5.127443] osd: probe of 0:0:0:0 rejects match -19
[    5.127877] device: '0:0:0:0': device_add
[    5.128272] PM: Adding info for No Bus:0:0:0:0
[    5.129266] device: 'sg0': device_add
[    5.130147] PM: Adding info for No Bus:sg0
[    5.130705] scsi 0:0:0:0: Attached scsi generic sg0 type 0
[    5.131737] device: '0:0:0:0': device_add
[    5.133034] PM: Adding info for No Bus:0:0:0:0
[    5.133615] driver: 'adapter0': driver_bound: bound to device 'scsi_debug'
[    5.134230] bus: 'pseudo': really_probe: bound device adapter0 to driver scsi_debug
[    5.134916] bus: 'platform': add driver ahci
[    5.135453] bus: 'platform': remove driver ahci
[    5.135908] driver: 'ahci': driver_release
[    5.136285] bus: 'pci': add driver sata_inic162x
[    5.136769] bus: 'pci': add driver sata_sil24
[    5.137528] bus: 'pci': add driver sata_sx4
[    5.137982] bus: 'pci': add driver sata_promise
[    5.138640] bus: 'pci': add driver sata_sis
[    5.139182] bus: 'pci': add driver sata_via
[    5.139646] bus: 'pci': add driver pata_artop
[    5.140315] bus: 'pci': add driver pata_atiixp
[    5.140788] bus: 'pci': add driver pata_cs5520
[    5.141522] bus: 'pci': add driver pata_cs5530
[    5.141999] bus: 'pci': add driver pata_cs5536
[    5.142645] bus: 'pci': add driver pata_cypress
[    5.143215] bus: 'pci': add driver pata_efar
[    5.143672] bus: 'pci': add driver pata_hpt366
[    5.144321] bus: 'pci': add driver pata_it8213
[    5.144794] bus: 'pci': add driver pata_it821x
[    5.145527] bus: 'pci': add driver pata_marvell
[    5.146003] bus: 'pci': add driver pata_netcell
[    5.146667] bus: 'pci': add driver pata_ninja32
[    5.147227] bus: 'pci': add driver pata_ns87415
[    5.147875] bus: 'pci': add driver pata_pdc202xx_old
[    5.148407] bus: 'pci': add driver pata_radisys
[    5.148888] bus: 'pci': add driver pata_sc1200
[    5.149614] bus: 'pci': add driver pata_sch
[    5.150078] bus: 'pci': add driver pata_sis
[    5.150709] bus: 'pci': add driver pata_piccolo
[    5.151278] bus: 'pci': add driver pata_triflex
[    5.151926] bus: 'pci': add driver pata_via
[    5.152396] bus: 'pci': add driver pata_sl82c105
[    5.152885] bus: 'pci': add driver pata_cmd640
[    5.153611] bus: 'pci': add driver pata_mpiix
[    5.154076] bus: 'pci': add driver pata_rz1000
[    5.154733] bus: 'pci': add driver pata_acpi
[    5.157462] Rounding down aligned max_sectors from 4294967295 to 8388600
[    5.158427] device: 'tcm_loop_0': device_add
[    5.159259] PM: Adding info for No Bus:tcm_loop_0
[    5.160160] bus: 'tcm_loop_bus': registered
[    5.160528] bus: 'tcm_loop_bus': add driver tcm_loop
[    5.161462] device class 'mtd': registering
[    5.161919] device: 'mtd-unmap': device_add
[    5.162534] PM: Adding info for No Bus:mtd-unmap
[    5.163600] device: 'mtd-romap': device_add
[    5.163997] PM: Adding info for No Bus:mtd-romap
[    5.164762] device: 'mtd-rwmap': device_add
[    5.165469] PM: Adding info for No Bus:mtd-rwmap
[    5.166267] SSFDC read-only Flash Translation layer
[    5.167313] L440GX flash mapping: failed to find PIIX4 ISA bridge, cannot continue
[    5.167995] device id = 2440
[    5.168346] device id = 2480
[    5.168610] device id = 24c0
[    5.168873] device id = 24d0
[    5.169214] device id = 25a1
[    5.169481] device id = 2670
[    5.169796] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[    5.170498] bus: 'pci': add driver MTD PCI
[    5.170894] bus: 'platform': add driver gpio-addr-flash
[    5.171588] bus: 'platform': add driver docg3
[    5.171999] bus: 'platform': remove driver docg3
[    5.172452] driver: 'docg3': driver_release
[    5.172827] slram: not enough parameters.
[    5.173274] Ramix PMC551 PCI Mezzanine Ram Driver. (C) 1999,2000 Nortel Networks.
[    5.173926] pmc551: not detected
[    5.200032] onenand_wait: timeout! ctrl=0x0000 intr=0x0000
[    5.200607] OneNAND Manufacturer: Samsung (0xec)
[    5.201011] OneNAND 16MB 1.8V 16-bit (0x04)
[    5.201459] OneNAND version = 0x001e
[    5.201773] Lock scheme is Continuous Lock
[    5.202618] Scanning device for bad blocks
[    5.203727] Creating 1 MTD partitions on "OneNAND simulator":
[    5.204320] 0x000000000000-0x000001000000 : "OneNAND simulator partition"
[    5.205779] device: 'mtd0': device_add
[    5.206763] PM: Adding info for No Bus:mtd0
[    5.208146] device: '31:0': device_add
[    5.208792] PM: Adding info for No Bus:31:0
[    5.209684] device: 'mtdblock0': device_add
[    5.210570] PM: Adding info for No Bus:mtdblock0
[    5.211508] bus: 'hsi': add driver hsi_char
[    5.211950] HSI/SSI char device loaded
[    5.212372] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[    5.213584] device: 'bond0': device_add
[    5.215063] PM: Adding info for No Bus:bond0
[    5.220307] device: 'dummy0': device_add
[    5.221417] PM: Adding info for No Bus:dummy0
[    5.222373] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)
[    5.223210] device: 'eql': device_add
[    5.224261] PM: Adding info for No Bus:eql
[    5.225823] bus: 'mdio_bus': add driver Marvell 88E1101
[    5.226614] bus: 'mdio_bus': add driver Marvell 88E1112
[    5.227142] bus: 'mdio_bus': add driver Marvell 88E1111
[    5.227664] bus: 'mdio_bus': add driver Marvell 88E1118
[    5.228456] bus: 'mdio_bus': add driver Marvell 88E1121R
[    5.228986] bus: 'mdio_bus': add driver Marvell 88E1318S
[    5.229595] bus: 'mdio_bus': add driver Marvell 88E1145
[    5.230385] bus: 'mdio_bus': add driver Marvell 88E1149R
[    5.230915] bus: 'mdio_bus': add driver Marvell 88E1240
[    5.231443] bus: 'mdio_bus': add driver Davicom DM9161E
[    5.232233] bus: 'mdio_bus': add driver Davicom DM9161A
[    5.232754] bus: 'mdio_bus': add driver Davicom DM9131
[    5.233353] bus: 'mdio_bus': add driver Broadcom BCM5411
[    5.234072] bus: 'mdio_bus': add driver Broadcom BCM5421
[    5.234680] bus: 'mdio_bus': add driver Broadcom BCM5461
[    5.235212] bus: 'mdio_bus': add driver Broadcom BCM5464
[    5.235737] bus: 'mdio_bus': add driver Broadcom BCM5481
[    5.236533] bus: 'mdio_bus': add driver Broadcom BCM5482
[    5.237066] bus: 'mdio_bus': add driver Broadcom BCM50610
[    5.237682] bus: 'mdio_bus': add driver Broadcom BCM50610M
[    5.238496] bus: 'mdio_bus': add driver Broadcom BCM57780
[    5.239033] bus: 'mdio_bus': add driver Broadcom BCMAC131
[    5.239575] bus: 'mdio_bus': add driver Broadcom BCM5241
[    5.240563] Registering platform device 'Fixed MDIO bus.0'. Parent at platform
[    5.241283] device: 'Fixed MDIO bus.0': device_add
[    5.241708] bus: 'platform': add device Fixed MDIO bus.0
[    5.242276] PM: Adding info for platform:Fixed MDIO bus.0
[    5.242829] device: 'fixed-0': device_add
[    5.243435] PM: Adding info for No Bus:fixed-0
[    5.243957] libphy: Fixed MDIO Bus: probed
[    5.244404] bus: 'mdio_bus': add driver STe101p
[    5.244863] bus: 'mdio_bus': add driver STe100p
[    5.245406] bus: 'mdio_bus': add driver Micrel KS8737
[    5.246192] bus: 'mdio_bus': add driver Micrel KS8041
[    5.246700] bus: 'mdio_bus': add driver Micrel KS8051
[    5.247213] bus: 'mdio_bus': add driver Micrel KS8001 or KS8721
[    5.247792] bus: 'mdio_bus': add driver Micrel KSZ9021 Gigabit PHY
[    5.248680] tun: Universal TUN/TAP device driver, 1.6
[    5.249169] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    5.249727] device: 'tun': device_add
[    5.250317] PM: Adding info for No Bus:tun
[    5.250737] bus: 'virtio': add driver virtio_net
[    5.251466] arcnet loaded.
[    5.251716] arcnet: raw mode (`r') encapsulation support loaded.
[    5.252342] arcnet: COM90xx IO-mapped mode support (by David Woodhouse et el.)
[    5.252976] E-mail me if you actually test this driver, please!
[    5.253582]  arc%d: No autoprobe for IO mapped cards; you must specify the base address!
[    5.254392] arcnet: RIM I (entirely mem-mapped) support
[    5.254851] E-mail me if you actually test the RIM I driver, please!
[    5.255408] Given: node 00h, shmem 0h, irq 0
[    5.255781] No autoprobe for RIM I; you must specify the shmem and irq!
[    5.256444] arcnet: COM20020 PCI support
[    5.256798] bus: 'pci': add driver com20020
[    5.257667] vcan: Virtual CAN interface driver
[    5.258069] slcan: serial line CAN interface driver
[    5.258577] slcan: 10 dynamic interface channels.
[    5.258994] CAN device driver interface
[    5.259341] bus: 'usb': add driver ems_usb
[    5.259724] usbcore: registered new interface driver ems_usb
[    5.260328] bus: 'usb': add driver peak_usb
[    5.260940] usbcore: registered new interface driver peak_usb
[    5.261539] bus: 'platform': add driver softing
[    5.261965] sja1000 CAN netdevice driver
[    5.262393] sja1000_isa: insufficient parameters supplied
[    5.262869] bus: 'pci': add driver kvaser_pci
[    5.263492] bus: 'pci': add driver sja1000_plx_pci
[    5.263950] cc770: CAN netdevice driver
[    5.264394] bus: 'pci': add driver amd8111e
[    5.264985] bus: 'pci': add driver atl1
[    5.265447] bus: 'pci': add driver ATL1E
[    5.265845] bus: 'pci': add driver bnx2
[    5.266493] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.13 (Sep 07, 2012)
[    5.267872] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.72.51-0 (2012/06/18)
[    5.269359] bus: 'pci': add driver bnx2x
[    5.270037] bus: 'platform': add driver calxedaxgmac
[    5.270580] bus: 'pci': add driver cxgb
[    5.270954] bus: 'pci': add driver cxgb3
[    5.272029] bus: 'pci': add driver cxgb4
[    5.272531] bus: 'platform': add driver dnet
[    5.273272] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
[    5.273878] bus: 'pci': add driver dmfe
[    5.274379] bus: 'pci': add driver de2104x
[    5.274821] bus: 'pci': add driver tulip
[    5.275456] bus: 'pci': add driver de4x5
[    5.275881] ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver - version 2.6.0-k
[    5.276763] ixgbevf: Copyright (c) 2009 - 2012 Intel Corporation.
[    5.277377] bus: 'pci': add driver ixgbevf
[    5.278088] bus: 'pci': add driver Sundance Technology IPG Triple-Speed Ethernet
[    5.278885] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    5.279403] bus: 'pci': add driver jme
[    5.280024] sky2: driver version 1.30
[    5.280770] bus: 'pci': add driver sky2
[    5.281888] bus: 'pci': add driver mlx4_core
[    5.282656] bus: 'pci': add driver ksz884xp
[    5.283064] myri10ge: Version 1.5.3-1.534
[    5.283427] bus: 'pci': add driver myri10ge
[    5.284024] bus: 'platform': add driver ethoc
[    5.284521] bus: 'pci': add driver hamachi
[    5.284922] bus: 'pci': add driver 8139cp
[    5.285596] bus: 'pci': add driver 8139too
[    5.286007] bus: 'pci': add driver hme
[    5.286659] bus: 'pci': add driver gem
[    5.287026] bus: 'pci': add driver cassini
[    5.287427] bus: 'pci': add driver defxx
[    5.287989] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[    5.288522] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    5.288522] baycom_ser_fdx: version 0.10
[    5.289524] device: 'bcsf0': device_add
[    5.290642] PM: Adding info for No Bus:bcsf0
[    5.291331] device: 'bcsf1': device_add
[    5.292940] PM: Adding info for No Bus:bcsf1
[    5.293709] device: 'bcsf2': device_add
[    5.294800] PM: Adding info for No Bus:bcsf2
[    5.295476] device: 'bcsf3': device_add
[    5.296563] PM: Adding info for No Bus:bcsf3
[    5.297321] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    5.297842] hdlcdrv: version 0.8
[    5.298206] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    5.298206] baycom_ser_hdx: version 0.10
[    5.299256] device: 'bcsh0': device_add
[    5.300408] PM: Adding info for No Bus:bcsh0
[    5.301325] device: 'bcsh1': device_add
[    5.302473] PM: Adding info for No Bus:bcsh1
[    5.303152] device: 'bcsh2': device_add
[    5.304261] PM: Adding info for No Bus:bcsh2
[    5.304935] device: 'bcsh3': device_add
[    5.306067] PM: Adding info for No Bus:bcsh3
[    5.306807] bus: 'platform': add driver nsc-ircc
[    5.307252] bus: 'pnp': add driver nsc-ircc
[    5.307705] bus: 'platform': remove driver nsc-ircc
[    5.308220] driver: 'nsc-ircc': driver_release
[    5.308621] bus: 'pnp': remove driver nsc-ircc
[    5.309019] driver: 'nsc-ircc': driver_release
[    5.309636] bus: 'pci': add driver vlsi_ir
[    5.310042] bus: 'pci': add driver via-ircc
[    5.311463] bus: 'usb': add driver kingsun-sir
[    5.311874] usbcore: registered new interface driver kingsun-sir
[    5.312481] bus: 'usb': add driver ksdazzle-sir
[    5.313230] usbcore: registered new interface driver ksdazzle-sir
[    5.313783] Loaded prism54 driver, version 1.2
[    5.314257] bus: 'pci': add driver prism54
[    5.314650] bus: 'usb': add driver zd1201
[    5.315246] usbcore: registered new interface driver zd1201
[    5.315741] VMware vmxnet3 virtual NIC driver - version 1.1.29.0-k-NAPI
[    5.316400] bus: 'pci': add driver vmxnet3
[    5.316795] bus: 'usb': add driver catc
[    5.317243] usbcore: registered new interface driver catc
[    5.317721] bus: 'usb': add driver kaweth
[    5.318373] usbcore: registered new interface driver kaweth
[    5.318873] hv_vmbus: registering driver hv_netvsc
[    5.319307] device class 'uio': registering
[    5.319694] bus: 'pci': add driver hilscher
[    5.320195] bus: 'platform': add driver uio_pdrv
[    5.320836] bus: 'platform': add driver uio_pdrv_genirq
[    5.321403] bus: 'pci': add driver aectc
[    5.321794] Generic UIO driver for PCI 2.3 devices version: 0.01.0
[    5.322418] bus: 'pci': add driver uio_pci_generic
[    5.323076] bus: 'pci': add driver netx
[    5.323461] device class 'aoe': registering
[    5.324045] device: 'err': device_add
[    5.325006] PM: Adding info for No Bus:err
[    5.325627] device: 'discover': device_add
[    5.326416] PM: Adding info for No Bus:discover
[    5.326920] device: 'interfaces': device_add
[    5.327754] PM: Adding info for No Bus:interfaces
[    5.328276] device: 'revalidate': device_add
[    5.329022] PM: Adding info for No Bus:revalidate
[    5.329783] device: 'flush': device_add
[    5.330552] PM: Adding info for No Bus:flush
[    5.331938] aoe: AoE v49 initialised.
[    5.332719] device class 'uwb_rc': registering
[    5.333493] bus: 'umc': registered
[    5.333806] bus: 'pci': add driver whci
[    5.334301] bus: 'umc': add driver whc-rc
[    5.334983] bus: 'usb': add driver hwa-rc
[    5.335412] usbcore: registered new interface driver hwa-rc
[    5.335904] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    5.336554] bus: 'pci': add driver ehci_hcd
[    5.337004] bus: 'platform': add driver oxu210hp-hcd
[    5.337810] uhci_hcd: USB Universal Host Controller Interface driver
[    5.338465] bus: 'pci': add driver uhci_hcd
[    5.338915] bus: 'platform': add driver sl811-hcd
[    5.339622] driver u132_hcd
[    5.340208] bus: 'platform': add driver u132_hcd
[    5.340687] bus: 'platform': add driver r8a66597_hcd
[    5.341275] bus: 'usb': add driver hwa-hc
[    5.341955] usbcore: registered new interface driver hwa-hc
[    5.342533] bus: 'platform': add driver c67x00
[    5.343268] bus: 'usb': add driver cdc_acm
[    5.343931] usbcore: registered new interface driver cdc_acm
[    5.344512] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[    5.345283] bus: 'usb': add driver usblp
[    5.345701] usbcore: registered new interface driver usblp
[    5.346268] Initializing USB Mass Storage driver...
[    5.346694] bus: 'usb': add driver usb-storage
[    5.347149] usbcore: registered new interface driver usb-storage
[    5.347674] USB Mass Storage support registered.
[    5.348142] bus: 'usb': add driver ums-alauda
[    5.348826] usbcore: registered new interface driver ums-alauda
[    5.349429] bus: 'usb': add driver ums-cypress
[    5.349878] usbcore: registered new interface driver ums-cypress
[    5.350447] bus: 'usb': add driver ums-datafab
[    5.350899] usbcore: registered new interface driver ums-datafab
[    5.351435] bus: 'usb': add driver ums_eneub6250
[    5.352204] usbcore: registered new interface driver ums_eneub6250
[    5.352764] bus: 'usb': add driver ums-freecom
[    5.353299] usbcore: registered new interface driver ums-freecom
[    5.353831] bus: 'usb': add driver ums-jumpshot
[    5.354369] usbcore: registered new interface driver ums-jumpshot
[    5.354905] bus: 'usb': add driver ums-onetouch
[    5.355592] usbcore: registered new interface driver ums-onetouch
[    5.356212] bus: 'usb': add driver ums-sddr55
[    5.356653] usbcore: registered new interface driver ums-sddr55
[    5.357264] bus: 'usb': add driver ums-usbat
[    5.357700] usbcore: registered new interface driver ums-usbat
[    5.358300] bus: 'usb': add driver cytherm
[    5.358950] usbcore: registered new interface driver cytherm
[    5.359456] driver ftdi-elan
[    5.360674] bus: 'usb': add driver ftdi-elan
[    5.361468] usbcore: registered new interface driver ftdi-elan
[    5.361986] bus: 'usb': add driver iowarrior
[    5.362521] usbcore: registered new interface driver iowarrior
[    5.363038] bus: 'usb': add driver isight_firmware
[    5.363529] usbcore: registered new interface driver isight_firmware
[    5.364168] bus: 'usb': add driver legousbtower
[    5.364871] usbcore: registered new interface driver legousbtower
[    5.365496] bus: 'usb': add driver rio500
[    5.365925] usbcore: registered new interface driver rio500
[    5.366501] bus: 'usb': add driver usbtest
[    5.367166] usbcore: registered new interface driver usbtest
[    5.367668] bus: 'usb': add driver yurex
[    5.368141] usbcore: registered new interface driver yurex
[    5.368648] bus: 'platform': add driver omap-usb2
[    5.369199] musb-hdrc: version 6.0, ?dma?, otg (peripheral+host)
[    5.369726] bus: 'platform': add driver musb-hdrc
[    5.370562] bus: 'platform': add driver musb-tusb
[    5.371046] bus: 'platform': add driver ci_hdrc
[    5.371522] bus: 'platform': add driver msm_hsusb
[    5.372308] bus: 'pci': add driver ci13xxx_pci
[    5.372789] bus: 'platform': add driver dummy_hcd
[    5.373353] bus: 'platform': add driver dummy_udc
[    5.374065] Registering platform device 'dummy_hcd'. Parent at platform
[    5.374737] device: 'dummy_hcd': device_add
[    5.375117] bus: 'platform': add device dummy_hcd
[    5.375542] PM: Adding info for platform:dummy_hcd
[    5.376033] bus: 'platform': driver_probe_device: matched device dummy_hcd with driver dummy_hcd
[    5.376881] bus: 'platform': really_probe: probing driver dummy_hcd with device dummy_hcd
[    5.377684] dummy_hcd dummy_hcd: USB Host+Gadget Emulator, driver 02 May 2005
[    5.378417] dummy_hcd dummy_hcd: Dummy host controller
[    5.378908] dummy_hcd dummy_hcd: new USB bus registered, assigned bus number 1
[    5.379999] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    5.380696] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.381404] usb usb1: Product: Dummy host controller
[    5.381840] usb usb1: Manufacturer: Linux 3.6.0-rc6-next-20120918-08732-g3de9d1a dummy_hcd
[    5.382641] usb usb1: SerialNumber: dummy_hcd
[    5.383038] device: 'usb1': device_add
[    5.385261] bus: 'usb': add device usb1
[    5.385649] PM: Adding info for usb:usb1
[    5.386062] bus: 'usb': driver_probe_device: matched device usb1 with driver usb
[    5.386787] bus: 'usb': really_probe: probing driver usb with device usb1
[    5.387855] device: '1-0:1.0': device_add
[    5.388325] bus: 'usb': add device 1-0:1.0
[    5.388698] PM: Adding info for usb:1-0:1.0
[    5.389189] bus: 'usb': driver_probe_device: matched device 1-0:1.0 with driver hub
[    5.389857] bus: 'usb': really_probe: probing driver hub with device 1-0:1.0
[    5.390861] hub 1-0:1.0: USB hub found
[    5.391256] hub 1-0:1.0: 1 port detected
[    5.391680] device: 'port1': device_add
[    5.392042] PM: Adding info for No Bus:port1
[    5.392534] driver: '1-0:1.0': driver_bound: bound to device 'hub'
[    5.393077] bus: 'usb': really_probe: bound device 1-0:1.0 to driver hub
[    5.393762] device: 'ep_81': device_add
[    5.394438] PM: Adding info for No Bus:ep_81
[    5.394830] driver: 'usb1': driver_bound: bound to device 'usb'
[    5.395364] bus: 'usb': really_probe: bound device usb1 to driver usb
[    5.396180] device: 'ep_00': device_add
[    5.396557] PM: Adding info for No Bus:ep_00
[    5.397271] driver: 'dummy_hcd': driver_bound: bound to device 'dummy_hcd'
[    5.397880] bus: 'platform': really_probe: bound device dummy_hcd to driver dummy_hcd
[    5.398651] Registering platform device 'dummy_udc'. Parent at platform
[    5.399235] device: 'dummy_udc': device_add
[    5.399614] bus: 'platform': add device dummy_udc
[    5.400057] PM: Adding info for platform:dummy_udc
[    5.400580] bus: 'platform': driver_probe_device: matched device dummy_udc with driver dummy_udc
[    5.401422] bus: 'platform': really_probe: probing driver dummy_udc with device dummy_udc
[    5.402221] device: 'gadget': device_add
[    5.402581] PM: Adding info for No Bus:gadget
[    5.403003] device: 'dummy_udc': device_add
[    5.403681] PM: Adding info for No Bus:dummy_udc
[    5.404443] driver: 'dummy_udc': driver_bound: bound to device 'dummy_udc'
[    5.405052] bus: 'platform': really_probe: bound device dummy_udc to driver dummy_udc
[    5.405820] bus: 'pci': add driver net2272
[    5.406298] bus: 'platform': add driver net2272
[    5.406721] bus: 'pci': add driver net2280
[    5.407344] bus: 'platform': add driver m66592_udc
[    5.407791] bus: 'platform': remove driver m66592_udc
[    5.408324] driver: 'm66592_udc': driver_release
[    5.408733] bus: 'platform': add driver r8a66597_udc
[    5.409268] bus: 'platform': remove driver r8a66597_udc
[    5.409735] driver: 'r8a66597_udc': driver_release
[    5.410262] bus: 'pci': add driver pch_udc
[    5.410658] bus: 'pnp': add driver i8042 kbd
[    5.411045] bus: 'pnp': driver_probe_device: matched device 00:02 with driver i8042 kbd
[    5.411746] bus: 'pnp': really_probe: probing driver i8042 kbd with device 00:02
[    5.412488] driver: '00:02': driver_bound: bound to device 'i8042 kbd'
[    5.413068] bus: 'pnp': really_probe: bound device 00:02 to driver i8042 kbd
[    5.414164] bus: 'pnp': add driver i8042 aux
[    5.414568] bus: 'pnp': driver_probe_device: matched device 00:03 with driver i8042 aux
[    5.415272] bus: 'pnp': really_probe: probing driver i8042 aux with device 00:03
[    5.415927] driver: '00:03': driver_bound: bound to device 'i8042 aux'
[    5.416580] bus: 'pnp': really_probe: bound device 00:03 to driver i8042 aux
[    5.417335] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    5.418054] Registering platform device 'i8042'. Parent at platform
[    5.418679] device: 'i8042': device_add
[    5.419026] bus: 'platform': add device i8042
[    5.419425] PM: Adding info for platform:i8042
[    5.419887] bus: 'platform': add driver i8042
[    5.420541] bus: 'platform': driver_probe_device: matched device i8042 with driver i8042
[    5.421328] bus: 'platform': really_probe: probing driver i8042 with device i8042
[    5.423144] serio: i8042 KBD port at 0x60,0x64 irq 1
[    5.423657] serio: i8042 AUX port at 0x60,0x64 irq 12
[    5.424166] driver: 'i8042': driver_bound: bound to device 'i8042'
[    5.424730] bus: 'platform': really_probe: bound device i8042 to driver i8042
[    5.425445] bus: 'serio': add driver ps2mult
[    5.425874] bus: 'pci': add driver Emu10k1_gameport
[    5.426728] device: 'event0': device_add
[    5.427555] device: 'serio0': device_add
[    5.427965] bus: 'serio': add device serio0
[    5.428674] PM: Adding info for serio:serio0
[    5.429157] device: 'serio1': device_add
[    5.429546] bus: 'serio': add device serio1
[    5.430434] PM: Adding info for No Bus:event0
[    5.430437] PM: Adding info for serio:serio1
[    5.431250] bus: 'serio': add driver atkbd
[    5.431659] bus: 'usb': add driver bcm5974
[    5.432045] usbcore: registered new interface driver bcm5974
[    5.432626] bus: 'platform': add driver gpio_mouse
[    5.433355] bus: 'serio': driver_probe_device: matched device serio0 with driver atkbd
[    5.434055] bus: 'serio': really_probe: probing driver atkbd with device serio0
[    5.436166] bus: 'serio': add driver psmouse
[    5.437304] bus: 'serio': add driver sermouse
[    5.437605] device: 'input1': device_add
[    5.437971] PM: Adding info for No Bus:input1
[    5.438014] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    5.438038] device: 'event1': device_add
[    5.438376] PM: Adding info for No Bus:event1
[    5.438496] driver: 'serio0': driver_bound: bound to device 'atkbd'
[    5.438500] bus: 'serio': really_probe: bound device serio0 to driver atkbd
[    5.438505] bus: 'serio': driver_probe_device: matched device serio1 with driver atkbd
[    5.438506] bus: 'serio': really_probe: probing driver atkbd with device serio1
[    5.442914] bus: 'gameport': add driver adc
[    5.442954] atkbd: probe of serio1 rejects match -19
[    5.442961] bus: 'serio': driver_probe_device: matched device serio1 with driver psmouse
[    5.442962] bus: 'serio': really_probe: probing driver psmouse with device serio1
[    5.445764] bus: 'gameport': add driver adi
[    5.446254] bus: 'gameport': add driver gf2k
[    5.447004] bus: 'gameport': add driver grip
[    5.447481] bus: 'gameport': add driver grip_mp
[    5.447967] bus: 'serio': add driver magellan
[    5.448753] bus: 'gameport': add driver sidewinder
[    5.449302] bus: 'serio': add driver spaceball
[    5.450157] bus: 'serio': add driver spaceorb
[    5.450627] bus: 'gameport': add driver tmdc
[    5.451118] bus: 'serio': add driver zhenhua
[    5.451854] bus: 'usb': add driver usb_acecad
[    5.452416] usbcore: registered new interface driver usb_acecad
[    5.452993] bus: 'usb': add driver aiptek
[    5.453722] usbcore: registered new interface driver aiptek
[    5.454381] bus: 'usb': add driver gtco
[    5.454798] usbcore: registered new interface driver gtco
[    5.455343] bus: 'usb': add driver hanwang
[    5.456153] usbcore: registered new interface driver hanwang
[    5.456734] bus: 'usb': add driver kbtab
[    5.457203] usbcore: registered new interface driver kbtab
[    5.457814] bus: 'usb': add driver wacom
[    5.458285] usbcore: registered new interface driver wacom
[    5.458857] bus: 'serio': add driver hampshire
[    5.459606] bus: 'serio': add driver elo
[    5.460059] mk712: device not present
[    5.460509] bus: 'usb': add driver usbtouchscreen
[    5.461308] usbcore: registered new interface driver usbtouchscreen
[    5.461933] bus: 'serio': add driver tsc40
[    5.462463] bus: 'platform': add driver rtc-bq4802
[    5.463269] bus: 'pnp': add driver rtc_cmos
[    5.463733] bus: 'pnp': driver_probe_device: matched device 00:01 with driver rtc_cmos
[    5.464542] bus: 'pnp': really_probe: probing driver rtc_cmos with device 00:01
[    5.465355] rtc_cmos 00:01: RTC can wake from S4
[    5.465826] device: 'input2': device_add
[    5.467178] device: 'rtc0': device_add
[    5.467190] PM: Adding info for No Bus:input2
[    5.467323] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input2
[    5.467660] device: 'event2': device_add
[    5.467760] PM: Adding info for No Bus:event2
[    5.467934] driver: 'serio1': driver_bound: bound to device 'psmouse'
[    5.467937] bus: 'serio': really_probe: bound device serio1 to driver psmouse
[    5.471209] PM: Adding info for No Bus:rtc0
[    5.471709] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    5.472415] rtc0: alarms up to one day, 114 bytes nvram, hpet irqs
[    5.473022] driver: '00:01': driver_bound: bound to device 'rtc_cmos'
[    5.473645] bus: 'pnp': really_probe: bound device 00:01 to driver rtc_cmos
[    5.474388] bus: 'platform': add driver rtc-ds1286
[    5.474903] bus: 'platform': add driver rtc-m48t35
[    5.475428] bus: 'platform': add driver rtc-m48t59
[    5.476241] bus: 'platform': add driver rtc-m48t86
[    5.476762] bus: 'platform': add driver rtc-msm6242
[    5.477320] bus: 'platform': remove driver rtc-msm6242
[    5.477854] driver: 'rtc-msm6242': driver_release
[    5.478333] bus: 'platform': add driver rtc-rp5c01
[    5.478846] bus: 'platform': remove driver rtc-rp5c01
[    5.479380] driver: 'rtc-rp5c01': driver_release
[    5.479816] bus: 'platform': add driver stk17ta8
[    5.480364] bus: 'platform': add driver rtc-test
[    5.481157] Registering platform device 'rtc-test.0'. Parent at platform
[    5.481780] device: 'rtc-test.0': device_add
[    5.482222] bus: 'platform': add device rtc-test.0
[    5.482680] PM: Adding info for platform:rtc-test.0
[    5.483214] bus: 'platform': driver_probe_device: matched device rtc-test.0 with driver rtc-test
[    5.484019] bus: 'platform': really_probe: probing driver rtc-test with device rtc-test.0
[    5.485199] device: 'rtc1': device_add
[    5.485859] PM: Adding info for No Bus:rtc1
[    5.486304] rtc-test rtc-test.0: rtc core: registered test as rtc1
[    5.486874] driver: 'rtc-test.0': driver_bound: bound to device 'rtc-test'
[    5.487508] bus: 'platform': really_probe: bound device rtc-test.0 to driver rtc-test
[    5.488337] Registering platform device 'rtc-test.1'. Parent at platform
[    5.488951] device: 'rtc-test.1': device_add
[    5.489383] bus: 'platform': add device rtc-test.1
[    5.489820] PM: Adding info for platform:rtc-test.1
[    5.490337] bus: 'platform': driver_probe_device: matched device rtc-test.1 with driver rtc-test
[    5.491194] bus: 'platform': really_probe: probing driver rtc-test with device rtc-test.1
[    5.491933] device: 'rtc2': device_add
[    5.492633] PM: Adding info for No Bus:rtc2
[    5.493171] rtc-test rtc-test.1: rtc core: registered test as rtc2
[    5.493737] driver: 'rtc-test.1': driver_bound: bound to device 'rtc-test'
[    5.494429] bus: 'platform': really_probe: bound device rtc-test.1 to driver rtc-test
[    5.495198] bus: 'platform': add driver v3020
[    5.495729] device class 'rc': registering
[    5.496453] IR NEC protocol handler initialized
[    5.496862] IR RC6 protocol handler initialized
[    5.497347] IR JVC protocol handler initialized
[    5.497753] IR SANYO protocol handler initialized
[    5.498266] bus: 'usb': add driver ati_remote
[    5.499015] usbcore: registered new interface driver ati_remote
[    5.499627] bus: 'pnp': add driver ite-cir
[    5.500100] bus: 'usb': add driver mceusb
[    5.500546] usbcore: registered new interface driver mceusb
[    5.501053] bus: 'pnp': add driver fintek-cir
[    5.501842] bus: 'pnp': add driver nuvoton-cir
[    5.502401] bus: 'usb': add driver streamzap
[    5.503089] usbcore: registered new interface driver streamzap
[    5.503738] bus: 'pnp': add driver Winbond CIR
[    5.504623] Registered IR keymap rc-empty
[    5.505015] device: 'rc0': device_add
[    5.505488] PM: Adding info for No Bus:rc0
[    5.505985] device: 'input3': device_add
[    5.506988] PM: Adding info for No Bus:input3
[    5.507553] input: rc-core loopback device as /devices/virtual/rc/rc0/input3
[    5.508585] device: 'event3': device_add
[    5.509419] PM: Adding info for No Bus:event3
[    5.509924] rc0: rc-core loopback device as /devices/virtual/rc/rc0
[    5.510745] bus: 'usb': add driver hdpvr
[    5.511262] usbcore: registered new interface driver hdpvr
[    5.511749] Driver for 1-wire Dallas network protocol.
[    5.512605] bus: 'w1': registered
[    5.512916] bus: 'w1': add driver w1_master_driver
[    5.513504] bus: 'w1': add driver w1_slave_driver
[    5.513994] bus: 'pci': add driver matrox_w1
[    5.514797] bus: 'usb': add driver DS9490R
[    5.515320] usbcore: registered new interface driver DS9490R
[    5.515828] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    5.516443] bus: 'platform': add driver ds1wm
[    5.516902] bus: 'platform': add driver w1-gpio
[    5.517711] bus: 'platform': remove driver w1-gpio
[    5.518284] driver: 'w1-gpio': driver_release
[    5.518684] bus: 'platform': add driver omap_hdq
[    5.519537] device: 'test_ac': device_add
[    5.519941] PM: Adding info for No Bus:test_ac
[    5.520504] power_supply test_ac: uevent
[    5.520868] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[    5.521450] power_supply test_ac: prop ONLINE=1
[    5.521913] power_supply test_ac: power_supply_changed
[    5.522458] device: 'test_battery': device_add
[    5.523474] PM: Adding info for No Bus:test_battery
[    5.523987] power_supply test_battery: uevent
[    5.524469] power_supply test_battery: POWER_SUPPLY_NAME=test_battery
[    5.525048] power_supply test_battery: prop STATUS=Discharging
[    5.525645] power_supply test_battery: prop CHARGE_TYPE=Fast
[    5.526234] power_supply test_battery: prop HEALTH=Good
[    5.526702] power_supply test_battery: prop PRESENT=1
[    5.527239] power_supply test_battery: prop TECHNOLOGY=Li-ion
[    5.527752] power_supply test_battery: prop CHARGE_FULL_DESIGN=100
[    5.528384] power_supply test_battery: prop CHARGE_FULL=100
[    5.528881] power_supply test_battery: prop CHARGE_NOW=50
[    5.529448] power_supply test_battery: prop CAPACITY=50
[    5.529918] power_supply test_battery: prop CAPACITY_LEVEL=Normal
[    5.530497] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3600
[    5.531044] power_supply test_battery: prop TIME_TO_FULL_NOW=3600
[    5.531673] power_supply test_battery: prop MODEL_NAME=Test battery
[    5.532319] power_supply test_battery: prop MANUFACTURER=Linux
[    5.532836] power_supply test_battery: prop SERIAL_NUMBER=3.6.0-rc6-next-20120918-08732-g3de9d1a
[    5.533692] power_supply test_battery: prop TEMP=26
[    5.534213] power_supply test_battery: prop VOLTAGE_NOW=3300
[    5.534735] power_supply test_battery: power_supply_changed
[    5.535351] device: 'test_usb': device_add
[    5.535745] PM: Adding info for No Bus:test_usb
[    5.536281] power_supply test_usb: uevent
[    5.536643] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[    5.537239] power_supply test_usb: prop ONLINE=1
[    5.537668] power_supply test_usb: power_supply_changed
[    5.538220] bus: 'platform': add driver ds2781-battery
[    5.538991] bus: 'platform': add driver max8903-charger
[    5.539615] applesmc: supported laptop not found!
[    5.540057] applesmc: driver init failed (ret=-19)!
[    5.540615] bus: 'platform': add driver gpio-fan
[    5.541231] bus: 'pci': add driver k8temp
[    5.541934] bus: 'pci': add driver k10temp
[    5.542471] bus: 'platform': add driver ntc-thermistor
[    5.543362] pc87360: PC8736x not detected, module not inserted
[    5.543886] bus: 'pci': add driver sis5595
[    5.544429] cpuidle: using governor ladder
[    5.544812] cpuidle: using governor menu
[    5.545246] bus: 'mmc': add driver mmc_test
[    5.545881] bus: 'sdio': add driver sdio_uart
[    5.546718] sdhci: Secure Digital Host Controller Interface driver
[    5.547351] sdhci: Copyright(c) Pierre Ossman
[    5.547741] bus: 'platform': add driver cb710-mmc
[    5.548263] VUB300 Driver rom wait states = 1C irqpoll timeout = 0400[    5.548864] power_supply test_ac: power_supply_changed_work
[    5.549402] power_supply test_ac: power_supply_update_gen_leds 1
[    5.550029] power_supply test_ac: uevent
[    5.550473] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[    5.550988] power_supply test_ac: prop ONLINE=1
[    5.551510] power_supply test_battery: power_supply_changed_work
[    5.552059] power_supply test_battery: power_supply_update_bat_leds 2
[    5.552776] power_supply test_battery: uevent
[    5.553187] power_supply test_battery: POWER_SUPPLY_NAME=test_battery
[    5.553774] power_supply test_battery: prop STATUS=Discharging
[    5.554389] power_supply test_battery: prop CHARGE_TYPE=Fast
[    5.554906] power_supply test_battery: prop HEALTH=Good
[    5.555467] power_supply test_battery: prop PRESENT=1
[    5.555930] power_supply test_battery: prop TECHNOLOGY=Li-ion
[    5.556538] power_supply test_battery: prop CHARGE_FULL_DESIGN=100
[    5.557108] power_supply test_battery: prop CHARGE_FULL=100
[    5.557616] power_supply test_battery: prop CHARGE_NOW=50
[    5.558184] power_supply test_battery: prop CAPACITY=50
[    5.558668] power_supply test_battery: prop CAPACITY_LEVEL=Normal
[    5.559303] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3600
[    5.559863] power_supply test_battery: prop TIME_TO_FULL_NOW=3600
[    5.560511] power_supply test_battery: prop MODEL_NAME=Test battery
[    5.561074] power_supply test_battery: prop MANUFACTURER=Linux
[    5.561615] power_supply test_battery: prop SERIAL_NUMBER=3.6.0-rc6-next-20120918-08732-g3de9d1a
[    5.562489] power_supply test_battery: prop TEMP=26
[    5.562935] power_supply test_battery: prop VOLTAGE_NOW=3300
[    5.563535] power_supply test_usb: power_supply_changed_work
[    5.564049] power_supply test_usb: power_supply_update_gen_leds 1
[    5.564722] power_supply test_usb: uevent
[    5.565100] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[    5.565627] power_supply test_usb: prop ONLINE=1

[    5.566864] bus: 'usb': add driver vub300
[    5.567662] usbcore: registered new interface driver vub300
[    5.568241] bus: 'usb': add driver ushc
[    5.568652] usbcore: registered new interface driver ushc
[    5.569145] bus: 'platform': add driver leds-gpio
[    5.569634] bus: 'platform': add driver leds-regulator
[    5.570515] bus: 'platform': add driver leds-lt3593
[    5.571061] ledtrig-cpu: registered to indicate activity on CPUs
[    5.571617] device class 'infiniband': registering
[    5.573712] device class 'infiniband_cm': registering
[    5.577016] device class 'infiniband_verbs': registering
[    5.577684] device: 'rdma_cm': device_add
[    5.578981] PM: Adding info for No Bus:rdma_cm
[    5.579443] rdma_ucm: couldn't register sysctl paths
[    5.579922] device: 'rdma_cm': device_unregister
[    5.580437] PM: Removing info for No Bus:rdma_cm
[    5.581293] device: 'rdma_cm': device_create_release
[    5.581756] device class 'ipath': registering
[    5.583276] bus: 'pci': add driver ib_qib
[    5.586948] device class 'infiniband_srp': registering
[    5.588241] device: 'iser': device_add
[    5.588610] PM: Adding info for No Bus:iser
[    5.589002] iscsi: registered transport (iser)
[    5.589577] Registering platform device 'dell_rbu'. Parent at platform
[    5.590212] device: 'dell_rbu': device_add
[    5.590592] bus: 'platform': add device dell_rbu
[    5.591017] PM: Adding info for platform:dell_rbu
[    5.591827] bus: 'hid': registered
[    5.592248] bus: 'hid': add driver hid-generic
[    5.592668] bus: 'hid': add driver a4tech
[    5.593304] bus: 'hid': add driver belkin
[    5.593691] bus: 'hid': add driver cherry
[    5.594395] bus: 'hid': add driver cypress
[    5.594793] bus: 'hid': add driver hkems
[    5.595171] bus: 'hid': add driver ezkey
[    5.595788] bus: 'hid': add driver holtek_kbd
[    5.596287] bus: 'hid': add driver holtek
[    5.596671] bus: 'hid': add driver kensington
[    5.597332] bus: 'hid': add driver keytouch
[    5.597735] bus: 'hid': add driver kye
[    5.598374] bus: 'hid': add driver lenovo_tpkbd
[    5.598807] bus: 'hid': add driver hid-multitouch
[    5.599253] bus: 'hid': add driver ntrig
[    5.599876] bus: 'hid': add driver pantherlord
[    5.600402] bus: 'hid': add driver petalynx
[    5.600798] bus: 'hid': add driver primax
[    5.601430] device class 'arvo': registering
[    5.601830] bus: 'hid': add driver arvo
[    5.602282] device class 'isku': registering
[    5.602679] bus: 'hid': add driver isku
[    5.603299] device class 'kone': registering
[    5.603700] bus: 'hid': add driver kone
[    5.604066] device class 'koneplus': registering
[    5.604752] bus: 'hid': add driver koneplus
[    5.605436] device class 'kovaplus': registering
[    5.605868] bus: 'hid': add driver kovaplus
[    5.606348] device class 'pyra': registering
[    5.606748] bus: 'hid': add driver pyra
[    5.607370] device class 'savu': registering
[    5.607772] bus: 'hid': add driver savu
[    5.608221] bus: 'hid': add driver speedlink
[    5.608880] bus: 'hid': add driver sunplus
[    5.609279] bus: 'hid': add driver greenasia
[    5.609681] bus: 'hid': add driver thrustmaster
[    5.610452] bus: 'hid': add driver topseed
[    5.610848] bus: 'hid': add driver twinhan
[    5.611251] bus: 'hid': add driver zeroplus
[    5.611897] bus: 'hid': add driver waltop
[    5.612363] bus: 'hid': add driver hid-sensor-hub
[    5.613055] bus: 'usb': add driver usbhid
[    5.613454] usbcore: registered new interface driver usbhid
[    5.613950] usbhid: USB HID core driver
[    5.614378] bus: 'platform': add driver asus_laptop
[    5.614834] bus: 'acpi': add driver Asus Laptop Support
[    5.615609] bus: 'acpi': remove driver Asus Laptop Support
[    5.616191] driver: 'Asus Laptop Support': driver_release
[    5.616689] bus: 'platform': remove driver asus_laptop
[    5.617163] driver: 'asus_laptop': driver_release
[    5.617590] bus: 'platform': add driver eeepc
[    5.618004] bus: 'acpi': add driver Eee PC Hotkey Driver
[    5.618847] bus: 'acpi': remove driver Eee PC Hotkey Driver
[    5.619366] driver: 'Eee PC Hotkey Driver': driver_release
[    5.619867] bus: 'platform': remove driver eeepc
[    5.620333] driver: 'eeepc': driver_release
[    5.620711] hdaps: supported laptop not found!
[    5.621114] hdaps: driver init failed (ret=-19)!
[    5.621522] bus: 'acpi': add driver Panasonic Laptop Support
[    5.622063] bus: 'acpi': add driver Toshiba BT
[    5.622830] bus: 'pci': add driver intel ips
[    5.623261] bus: 'acpi': add driver xo15-ebook
[    5.623702] bus: 'pnp': add driver apple-gmux
[    5.624397] hv_utils: Registering HyperV Utility Driver
[    5.624866] hv_vmbus: registering driver hv_util
[    5.625286] bus: 'platform': add driver HID-SENSOR-200073
[    5.625788] bus: 'platform': add driver HID-SENSOR-200041
[    5.626378] bus: 'platform': add driver HID-SENSOR-200083
[    5.627330] bus: 'vme': registered
[    5.627653] bus: 'pci': add driver vme_tsi148
[    5.628855] NET: Registered protocol family 26
[    5.629291] Netfilter messages via NETLINK v0.30.
[    5.630176] nf_conntrack version 0.5.0 (1434 buckets, 5736 max)
[    5.630819] IPVS: Registered protocols (UDP, SCTP, AH, ESP)
[    5.631342] IPVS: Connection hash table configured (size=4096, memory=64Kbytes)
[    5.632058] IPVS: Creating netns size=2264 id=0
[    5.632606] IPVS: ipvs loaded.
[    5.632897] IPVS: [rr] scheduler registered.
[    5.633285] IPVS: [wrr] scheduler registered.
[    5.633674] IPVS: [lc] scheduler registered.
[    5.634058] IPVS: [lblc] scheduler registered.
[    5.634534] IPVS: [lblcr] scheduler registered.
[    5.634940] IPVS: [sh] scheduler registered.
[    5.635327] IPVS: [nq] scheduler registered.
[    5.635710] IPv4 over IPv4 tunneling driver
[    5.636247] device: 'tunl0': device_add
[    5.637530] PM: Adding info for No Bus:tunl0
[    5.638520] IPv4 over IPSec tunneling driver
[    5.638987] device: 'ip_vti0': device_add
[    5.640319] PM: Adding info for No Bus:ip_vti0
[    5.641339] ip_tables: (C) 2000-2006 Netfilter Core Team
[    5.642558] TCP: bic registered
[    5.642853] TCP: cubic registered
[    5.643160] TCP: highspeed registered
[    5.643493] TCP: lp registered
[    5.643769] Initializing XFRM netlink socket
[    5.644568] bus: 'platform': add driver dsa
[    5.645298] NET: Registered protocol family 4
[    5.645728] NET: Registered protocol family 3
[    5.646206] can: controller area network core (rev 20120528 abi 9)
[    5.646770] can: failed to create /proc/net/can . CONFIG_PROC_FS missing?
[    5.647380] NET: Registered protocol family 29
[    5.647790] IrCOMM protocol (Dag Brattli)
[    5.648309] device: 'ircomm0': device_add
[    5.648987] PM: Adding info for No Bus:ircomm0
[    5.649968] device: 'ircomm1': device_add
[    5.650636] PM: Adding info for No Bus:ircomm1
[    5.651157] device: 'ircomm2': device_add
[    5.652152] PM: Adding info for No Bus:ircomm2
[    5.652900] device: 'ircomm3': device_add
[    5.653506] PM: Adding info for No Bus:ircomm3
[    5.654281] device: 'ircomm4': device_add
[    5.655259] PM: Adding info for No Bus:ircomm4
[    5.655997] device: 'ircomm5': device_add
[    5.656677] PM: Adding info for No Bus:ircomm5
[    5.657215] device: 'ircomm6': device_add
[    5.658171] PM: Adding info for No Bus:ircomm6
[    5.659148] device: 'ircomm7': device_add
[    5.659760] PM: Adding info for No Bus:ircomm7
[    5.660404] device: 'ircomm8': device_add
[    5.661434] PM: Adding info for No Bus:ircomm8
[    5.662154] device: 'ircomm9': device_add
[    5.662747] PM: Adding info for No Bus:ircomm9
[    5.663534] device: 'ircomm10': device_add
[    5.664549] PM: Adding info for No Bus:ircomm10
[    5.665372] device: 'ircomm11': device_add
[    5.665975] PM: Adding info for No Bus:ircomm11
[    5.666520] device: 'ircomm12': device_add
[    5.667559] PM: Adding info for No Bus:ircomm12
[    5.668557] device: 'ircomm13': device_add
[    5.669206] PM: Adding info for No Bus:ircomm13
[    5.669757] device: 'ircomm14': device_add
[    5.670746] PM: Adding info for No Bus:ircomm14
[    5.671545] device: 'ircomm15': device_add
[    5.672193] PM: Adding info for No Bus:ircomm15
[    5.672907] device: 'ircomm16': device_add
[    5.673955] PM: Adding info for No Bus:ircomm16
[    5.674707] device: 'ircomm17': device_add
[    5.675373] PM: Adding info for No Bus:ircomm17
[    5.675900] device: 'ircomm18': device_add
[    5.676942] PM: Adding info for No Bus:ircomm18
[    5.677937] device: 'ircomm19': device_add
[    5.678464] PM: Adding info for No Bus:ircomm19
[    5.678966] device: 'ircomm20': device_add
[    5.679881] PM: Adding info for No Bus:ircomm20
[    5.680676] device: 'ircomm21': device_add
[    5.681223] PM: Adding info for No Bus:ircomm21
[    5.681892] device: 'ircomm22': device_add
[    5.682746] PM: Adding info for No Bus:ircomm22
[    5.683551] device: 'ircomm23': device_add
[    5.684068] PM: Adding info for No Bus:ircomm23
[    5.684593] device: 'ircomm24': device_add
[    5.685462] PM: Adding info for No Bus:ircomm24
[    5.686372] device: 'ircomm25': device_add
[    5.686895] PM: Adding info for No Bus:ircomm25
[    5.687476] device: 'ircomm26': device_add
[    5.688352] PM: Adding info for No Bus:ircomm26
[    5.689053] device: 'ircomm27': device_add
[    5.689661] PM: Adding info for No Bus:ircomm27
[    5.690361] device: 'ircomm28': device_add
[    5.691239] PM: Adding info for No Bus:ircomm28
[    5.691985] device: 'ircomm29': device_add
[    5.692495] PM: Adding info for No Bus:ircomm29
[    5.692989] device: 'ircomm30': device_add
[    5.693902] PM: Adding info for No Bus:ircomm30
[    5.694816] device: 'ircomm31': device_add
[    5.695416] PM: Adding info for No Bus:ircomm31
[    5.695996] RPC: Registered rdma transport module.
[    5.696544] NET: Registered protocol family 33
[    5.696943] Key type rxrpc registered
[    5.697355] Key type rxrpc_s registered
[    5.698252] RxRPC: Registered security type 2 'rxkad'
[    5.698759] l2tp_core: L2TP core driver, V2.0
[    5.699571] l2tp_debugfs: L2TP debugfs support
[    5.700236] sctp: Hash tables configured (established 819 bind 819)
[    5.701259] 9pnet: Installing 9P2000 support
[    5.701667] bus: 'virtio': add driver 9pnet_virtio
[    5.702560] NET: Registered protocol family 37
[    5.703010] Key type dns_resolver registered
[    5.703803] Key type ceph registered
[    5.704220] libceph: loaded (mon/osd proto 15/24, osdmap 5/6 5/6)
[    5.705770] batman_adv: B.A.T.M.A.N. advanced 2012.4.0 (compatibility version 14) loaded
[    5.707372] 
[    5.707372] printing PIC contents
[    5.707810] ... PIC  IMR: ffff
[    5.708164] ... PIC  IRR: 1153
[    5.708449] ... PIC  ISR: 0000
[    5.708725] ... PIC ELCR: 0c00
[    5.709052] printing local APIC contents on CPU#0/0:
[    5.709537] ... APIC ID:      00000000 (0)
[    5.709914] ... APIC VERSION: 00050014
[    5.710267] ... APIC TASKPRI: 00000000 (00)
[    5.710650] ... APIC PROCPRI: 00000000
[    5.710995] ... APIC LDR: 01000000
[    5.711315] ... APIC DFR: ffffffff
[    5.711630] ... APIC SPIV: 000001ff
[    5.711950] ... APIC ISR field:
[    5.712250] 0000000000000000000000000000000000000000000000000000000000000000
[    5.713018] ... APIC TMR field:
[    5.713318] 0000000000000000000000000000000000000000000000000000000000000000
[    5.714087] ... APIC IRR field:
[    5.714381] 0000000000000000000000000000000000000000000000000000000020000000
[    5.715152] ... APIC ESR: 00000000
[    5.715467] ... APIC ICR: 000008fd
[    5.715779] ... APIC ICR2: 02000000
[    5.716105] ... APIC LVTT: 000000ef
[    5.716426] ... APIC LVTPC: 00010000
[    5.716754] ... APIC LVT0: 00010700
[    5.717076] ... APIC LVT1: 00000400
[    5.717398] ... APIC LVTERR: 000000fe
[    5.717735] ... APIC TMICT: 17af3ba4
[    5.718068] ... APIC TMCCT: 17a306ec
[    5.718399] ... APIC TDCR: 00000003
[    5.718718] 
[    5.718881] number of MP IRQ sources: 15.
[    5.719324] number of IO-APIC #2 registers: 24.
[    5.719722] testing the IO APIC.......................
[    5.720274] IO APIC #2......
[    5.720534] .... register #00: 00000000
[    5.720872] .......    : physical APIC id: 00
[    5.721340] .......    : Delivery Type: 0
[    5.721694] .......    : LTS          : 0
[    5.722050] .... register #01: 00170011
[    5.722396] .......     : max redirection entries: 17
[    5.722841] .......     : PRQ implemented: 0
[    5.723297] .......     : IO APIC version: 11
[    5.723681] .... register #02: 00000000
[    5.724022] .......     : arbitration: 00
[    5.724455] .... IRQ redirection table:
[    5.724795]  NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:
[    5.725365]  00 00  1    0    0   0   0    0    0    00
[    5.725847]  01 03  0    0    0   0   0    1    1    31
[    5.726334]  02 03  0    0    0   0   0    1    1    30
[    5.726815]  03 03  1    0    0   0   0    1    1    33
[    5.727377]  04 03  1    0    0   0   0    1    1    34
[    5.727858]  05 03  1    1    0   0   0    1    1    35
[    5.728418]  06 03  0    0    0   0   0    1    1    36
[    5.728899]  07 03  1    0    0   0   0    1    1    37
[    5.729464]  08 03  0    0    0   0   0    1    1    38
[    5.729946]  09 03  0    1    0   0   0    1    1    39
[    5.730461]  0a 03  1    1    0   0   0    1    1    3A
[    5.730947]  0b 03  1    1    0   0   0    1    1    3B
[    5.731513]  0c 03  0    0    0   0   0    1    1    3C
[    5.732000]  0d 03  1    0    0   0   0    1    1    3D
[    5.732563]  0e 03  0    0    0   0   0    1    1    3E
[    5.733057]  0f 03  0    0    0   0   0    1    1    3F
[    5.733617]  10 00  1    0    0   0   0    0    0    00
[    5.734106]  11 00  1    0    0   0   0    0    0    00
[    5.734589]  12 00  1    0    0   0   0    0    0    00
[    5.735137]  13 00  1    0    0   0   0    0    0    00
[    5.735636]  14 00  1    0    0   0   0    0    0    00
[    5.736199]  15 00  1    0    0   0   0    0    0    00
[    5.736698]  16 00  1    0    0   0   0    0    0    00
[    5.737259]  17 00  1    0    0   0   0    0    0    00
[    5.737735] IRQ to pin mappings:
[    5.738025] IRQ0 -> 0:2
[    5.738278] IRQ1 -> 0:1
[    5.738528] IRQ3 -> 0:3
[    5.738777] IRQ4 -> 0:4
[    5.739027] IRQ5 -> 0:5
[    5.739359] IRQ6 -> 0:6
[    5.739609] IRQ7 -> 0:7
[    5.739858] IRQ8 -> 0:8
[    5.740182] IRQ9 -> 0:9
[    5.740432] IRQ10 -> 0:10
[    5.740696] IRQ11 -> 0:11
[    5.740960] IRQ12 -> 0:12
[    5.741301] IRQ13 -> 0:13
[    5.741565] IRQ14 -> 0:14
[    5.741829] IRQ15 -> 0:15
[    5.742097] .................................... done.
[    5.743492] device: 'cpu_dma_latency': device_add
[    5.744075] PM: Adding info for No Bus:cpu_dma_latency
[    5.744663] device: 'network_latency': device_add
[    5.745714] PM: Adding info for No Bus:network_latency
[    5.746504] device: 'network_throughput': device_add
[    5.747132] PM: Adding info for No Bus:network_throughput
[    5.748568] Key type encrypted registered
[    5.749556] IMA: No TPM chip found, activating TPM-bypass!
[    5.753710] device class 'ubi': registering
[    5.754405] device: 'ubi_ctrl': device_add
[    5.755619] PM: Adding info for No Bus:ubi_ctrl
[    5.756439] console [netcon0] enabled
[    5.756779] netconsole: network logging started
[    5.758663] debug: unmapping init [mem 0xffffffff825e4000-0xffffffff8286bfff]
[    5.813510] mount (146) used greatest stack depth: 5280 bytes left
/bin/sh: /proc/self/fd/9: No such file or directory
/bin/sh: /proc/self/fd/9: No such file or directory
[    5.876425] sh (162) used greatest stack depth: 4800 bytes left
/bin/sh: /proc/self/fd/9: No such file or directory
[   20.196199] trinity-child0 (165): Using mlock ulimits for SHM_HUGETLB is deprecated
[   20.202010] warning: process `trinity-child1' used the deprecated sysctl system call with 
[   32.425603] trinity-child0 (171) used greatest stack depth: 4560 bytes left
[   38.482925] scsi_nl_rcv_msg: discarding partial skb
[   62.679879] ------------[ cut here ]------------
[   62.680380] WARNING: at /c/kernel-tests/src/linux/mm/interval_tree.c:109 anon_vma_interval_tree_verify+0x33/0x80()
[   62.681356] Pid: 195, comm: trinity-child0 Not tainted 3.6.0-rc6-next-20120918-08732-g3de9d1a #1
[   62.682130] Call Trace:
[   62.682356]  [<ffffffff810c249f>] ? anon_vma_interval_tree_verify+0x33/0x80
[   62.682968]  [<ffffffff81044356>] warn_slowpath_common+0x5d/0x74
[   62.683577]  [<ffffffff81044424>] warn_slowpath_null+0x15/0x19
[   62.684098]  [<ffffffff810c249f>] anon_vma_interval_tree_verify+0x33/0x80
[   62.684714]  [<ffffffff810ca57c>] validate_mm+0x32/0x15b
[   62.685202]  [<ffffffff810ca767>] vma_link+0x95/0xa4
[   62.685637]  [<ffffffff810cbc31>] copy_vma+0x1c7/0x1fe
[   62.686168]  [<ffffffff810cdd50>] move_vma+0x90/0x1ef
[   62.686614]  [<ffffffff810ce250>] sys_mremap+0x3a1/0x429
[   62.687094]  [<ffffffff813caafe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   62.687670]  [<ffffffff81b505b9>] system_call_fastpath+0x16/0x1b
[   62.688267] ---[ end trace 8a8dcc9932b93523 ]---
[   62.688670] ------------[ cut here ]------------
[   62.689082] WARNING: at /c/kernel-tests/src/linux/mm/interval_tree.c:110 anon_vma_interval_tree_verify+0x75/0x80()
[   62.689988] Pid: 195, comm: trinity-child0 Tainted: G        W    3.6.0-rc6-next-20120918-08732-g3de9d1a #1
[   62.690941] Call Trace:
[   62.691187]  [<ffffffff810c24e1>] ? anon_vma_interval_tree_verify+0x75/0x80
[   62.691801]  [<ffffffff81044356>] warn_slowpath_common+0x5d/0x74
[   62.692403]  [<ffffffff81044424>] warn_slowpath_null+0x15/0x19
[   62.692913]  [<ffffffff810c24e1>] anon_vma_interval_tree_verify+0x75/0x80
[   62.693578]  [<ffffffff810ca57c>] validate_mm+0x32/0x15b
[   62.694110]  [<ffffffff810ca767>] vma_link+0x95/0xa4
[   62.694549]  [<ffffffff810cbc31>] copy_vma+0x1c7/0x1fe
[   62.695007]  [<ffffffff810cdd50>] move_vma+0x90/0x1ef
[   62.695534]  [<ffffffff810ce250>] sys_mremap+0x3a1/0x429
[   62.696001]  [<ffffffff813caafe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   62.696645]  [<ffffffff81b505b9>] system_call_fastpath+0x16/0x1b
[   62.697242] ---[ end trace 8a8dcc9932b93524 ]---

--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.6.0-rc6-next-20120918-08732-g3de9d1a"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.6.0-rc6 Kernel Configuration
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
CONFIG_GENERIC_GPIO=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
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
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
CONFIG_KERNEL_LZMA=y
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
# CONFIG_POSIX_MQUEUE is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_FHANDLE=y
# CONFIG_TASKSTATS is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
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
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_USER_QS is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_ANON_INODES=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
# CONFIG_EPOLL is not set
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
# CONFIG_SHMEM is not set
# CONFIG_AIO is not set
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_PCI_QUIRKS=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
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
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_RCU_USER_QS=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_AMIGA_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BLOCK_COMPAT=y

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
CONFIG_PADATA=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
# CONFIG_X86_X2APIC is not set
# CONFIG_X86_MPPARSE is not set
CONFIG_X86_EXTENDED_PLATFORM=y
CONFIG_X86_VSMP=y
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_KVMTOOL_TEST_ENABLE=y
CONFIG_PARAVIRT_GUEST=y
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PRIVILEGED_GUEST=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_MAX_DOMAIN_MEMORY=500
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
CONFIG_KVM_GUEST=y
CONFIG_PARAVIRT=y
CONFIG_PARAVIRT_SPINLOCKS=y
CONFIG_PARAVIRT_CLOCK=y
CONFIG_PARAVIRT_DEBUG=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=12
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
# CONFIG_CPU_SUP_AMD is not set
# CONFIG_CPU_SUP_CENTAUR is not set
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=4096
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
CONFIG_IRQ_TIME_ACCOUNTING=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
# CONFIG_X86_MCE_INTEL is not set
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_INJECT=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
# CONFIG_AMD_NUMA is not set
# CONFIG_X86_64_ACPI_NUMA is not set
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
# CONFIG_SUSPEND is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
# CONFIG_ACPI_FAN is not set
CONFIG_ACPI_DOCK=y
# CONFIG_ACPI_PROCESSOR is not set
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_DEBUG_FUNC_TRACE is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
CONFIG_ACPI_BGRT=y
CONFIG_ACPI_APEI=y
# CONFIG_ACPI_APEI_GHES is not set
# CONFIG_ACPI_APEI_MEMORY_FAILURE is not set
# CONFIG_ACPI_APEI_EINJ is not set
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_CNB20LE_QUIRK=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
CONFIG_PCI_DEBUG=y
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_XEN_PCIDEV_FRONTEND=y
# CONFIG_HT_IRQ is not set
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
# CONFIG_CARDBUS is not set

#
# PC-card bridges
#
# CONFIG_YENTA is not set
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=y
CONFIG_HOTPLUG_PCI_CPCI=y
CONFIG_HOTPLUG_PCI_CPCI_ZT5550=y
# CONFIG_HOTPLUG_PCI_CPCI_GENERIC is not set
CONFIG_HOTPLUG_PCI_SHPC=y
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
CONFIG_RAPIDIO_DMA_ENGINE=y
# CONFIG_RAPIDIO_DEBUG is not set
CONFIG_RAPIDIO_TSI57X=y
CONFIG_RAPIDIO_CPS_XX=y
CONFIG_RAPIDIO_TSI568=y
CONFIG_RAPIDIO_CPS_GEN2=y
# CONFIG_RAPIDIO_TSI500 is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
# CONFIG_COREDUMP is not set
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_IP_MROUTE=y
# CONFIG_IP_MROUTE_MULTIPLE_TABLES is not set
CONFIG_IP_PIMSM_V1=y
# CONFIG_IP_PIMSM_V2 is not set
CONFIG_ARPD=y
# CONFIG_SYN_COOKIES is not set
CONFIG_NET_IPVTI=y
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
# CONFIG_INET_XFRM_MODE_BEET is not set
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=y
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=y
# CONFIG_TCP_CONG_WESTWOOD is not set
# CONFIG_TCP_CONG_HTCP is not set
CONFIG_TCP_CONG_HSTCP=y
# CONFIG_TCP_CONG_HYBLA is not set
# CONFIG_TCP_CONG_VEGAS is not set
# CONFIG_TCP_CONG_SCALABLE is not set
CONFIG_TCP_CONG_LP=y
# CONFIG_TCP_CONG_VENO is not set
# CONFIG_TCP_CONG_YEAH is not set
# CONFIG_TCP_CONG_ILLINOIS is not set
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
CONFIG_NETLABEL=y
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NETWORK_PHY_TIMESTAMPING=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_DEBUG=y
# CONFIG_NETFILTER_ADVANCED is not set

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
# CONFIG_NF_CONNTRACK_FTP is not set
# CONFIG_NF_CONNTRACK_IRC is not set
# CONFIG_NF_CONNTRACK_NETBIOS_NS is not set
# CONFIG_NF_CONNTRACK_SIP is not set
# CONFIG_NF_CT_NETLINK is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
# CONFIG_NETFILTER_XT_MARK is not set

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_LOG=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
# CONFIG_NETFILTER_XT_MATCH_POLICY is not set
# CONFIG_NETFILTER_XT_MATCH_STATE is not set
# CONFIG_IP_SET is not set
CONFIG_IP_VS=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
# CONFIG_IP_VS_PROTO_TCP is not set
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=y
CONFIG_IP_VS_WRR=y
CONFIG_IP_VS_LC=y
# CONFIG_IP_VS_WLC is not set
CONFIG_IP_VS_LBLC=y
CONFIG_IP_VS_LBLCR=y
# CONFIG_IP_VS_DH is not set
CONFIG_IP_VS_SH=y
# CONFIG_IP_VS_SED is not set
CONFIG_IP_VS_NQ=y

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
# CONFIG_IP_VS_NFCT is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_IP_NF_IPTABLES=y
# CONFIG_IP_NF_FILTER is not set
CONFIG_IP_NF_TARGET_ULOG=y
# CONFIG_NF_NAT_IPV4 is not set
CONFIG_IP_NF_MANGLE=y
# CONFIG_IP_NF_RAW is not set
# CONFIG_IP_DCCP is not set
CONFIG_IP_SCTP=y
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_HMAC_NONE is not set
# CONFIG_SCTP_HMAC_SHA1 is not set
CONFIG_SCTP_HMAC_MD5=y
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
CONFIG_L2TP=y
CONFIG_L2TP_DEBUGFS=y
# CONFIG_L2TP_V3 is not set
# CONFIG_BRIDGE is not set
CONFIG_NET_DSA=y
# CONFIG_NET_DSA_TAG_DSA is not set
CONFIG_NET_DSA_TAG_EDSA=y
CONFIG_NET_DSA_TAG_TRAILER=y
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
CONFIG_LAPB=y
# CONFIG_WAN_ROUTER is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BLA=y
# CONFIG_BATMAN_ADV_DEBUG is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_BQL=y

#
# Network testing
#
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
# CONFIG_AX25_DAMA_SLAVE is not set
# CONFIG_NETROM is not set
# CONFIG_ROSE is not set

#
# AX.25 network device drivers
#
CONFIG_MKISS=y
# CONFIG_6PACK is not set
# CONFIG_BPQETHER is not set
CONFIG_BAYCOM_SER_FDX=y
CONFIG_BAYCOM_SER_HDX=y
# CONFIG_YAM is not set
CONFIG_CAN=y
# CONFIG_CAN_RAW is not set
# CONFIG_CAN_BCM is not set
# CONFIG_CAN_GW is not set

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_SLCAN=y
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_PCH_CAN is not set
CONFIG_CAN_SJA1000=y
CONFIG_CAN_SJA1000_ISA=y
# CONFIG_CAN_SJA1000_PLATFORM is not set
# CONFIG_CAN_EMS_PCI is not set
# CONFIG_CAN_PEAK_PCI is not set
CONFIG_CAN_KVASER_PCI=y
CONFIG_CAN_PLX_PCI=y
CONFIG_CAN_C_CAN=y
# CONFIG_CAN_C_CAN_PLATFORM is not set
# CONFIG_CAN_C_CAN_PCI is not set
CONFIG_CAN_CC770=y
# CONFIG_CAN_CC770_ISA is not set
# CONFIG_CAN_CC770_PLATFORM is not set

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=y
# CONFIG_CAN_ESD_USB2 is not set
CONFIG_CAN_PEAK_USB=y
CONFIG_CAN_SOFTING=y
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
# CONFIG_IRLAN is not set
CONFIG_IRCOMM=y
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
# CONFIG_IRDA_DEBUG is not set

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
CONFIG_DONGLE=y
CONFIG_ESI_DONGLE=y
# CONFIG_ACTISYS_DONGLE is not set
# CONFIG_TEKRAM_DONGLE is not set
# CONFIG_TOIM3232_DONGLE is not set
# CONFIG_LITELINK_DONGLE is not set
# CONFIG_MA600_DONGLE is not set
# CONFIG_GIRBIL_DONGLE is not set
# CONFIG_MCP2120_DONGLE is not set
CONFIG_OLD_BELKIN_DONGLE=y
# CONFIG_ACT200L_DONGLE is not set
CONFIG_KINGSUN_DONGLE=y
CONFIG_KSDAZZLE_DONGLE=y
# CONFIG_KS959_DONGLE is not set

#
# FIR device drivers
#
# CONFIG_USB_IRDA is not set
# CONFIG_SIGMATEL_FIR is not set
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
# CONFIG_SMC_IRCC_FIR is not set
# CONFIG_ALI_FIR is not set
CONFIG_VLSI_FIR=y
CONFIG_VIA_FIR=y
# CONFIG_MCS_FIR is not set
# CONFIG_BT is not set
CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_DEBUG=y
CONFIG_RXKAD=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
# CONFIG_RFKILL is not set
CONFIG_RFKILL_REGULATOR=y
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_RDMA is not set
# CONFIG_NET_9P_DEBUG is not set
CONFIG_CAIF=y
CONFIG_CAIF_DEBUG=y
# CONFIG_CAIF_NETDEV is not set
# CONFIG_CAIF_USB is not set
CONFIG_CEPH_LIB=y
CONFIG_CEPH_LIB_PRETTYDEBUG=y
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
CONFIG_NFC=y
CONFIG_NFC_NCI=y
# CONFIG_NFC_HCI is not set
# CONFIG_NFC_LLCP is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_PN533=y
# CONFIG_NFC_WILINK is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_DEBUG_DRIVER=y
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
# CONFIG_DMA_SHARED_BUFFER is not set

#
# Bus devices
#
CONFIG_OMAP_OCP2SCP=y
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
# CONFIG_MTD_CHAR is not set
CONFIG_HAVE_MTD_OTP=y
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
# CONFIG_FTL is not set
CONFIG_NFTL=y
# CONFIG_NFTL_RW is not set
# CONFIG_INFTL is not set
# CONFIG_RFD_FTL is not set
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
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
CONFIG_MTD_CFI_INTELEXT=y
# CONFIG_MTD_CFI_AMDSTD is not set
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=y
# CONFIG_MTD_RAM is not set
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
# CONFIG_MTD_SC520CDP is not set
# CONFIG_MTD_NETSC520 is not set
# CONFIG_MTD_TS5500 is not set
CONFIG_MTD_SBC_GXX=y
CONFIG_MTD_AMD76XROM=y
# CONFIG_MTD_ICHXROM is not set
CONFIG_MTD_ESB2ROM=y
CONFIG_MTD_CK804XROM=y
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
CONFIG_MTD_PCI=y
CONFIG_MTD_GPIO_ADDR=y
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set
# CONFIG_MTD_LATCH_ADDR is not set

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
# CONFIG_MTD_PMC551_BUGFIX is not set
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=y
CONFIG_MTD_NAND_ECC_SMC=y
# CONFIG_MTD_NAND is not set
CONFIG_MTD_ONENAND=y
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
# CONFIG_MTD_ONENAND_GENERIC is not set
CONFIG_MTD_ONENAND_OTP=y
CONFIG_MTD_ONENAND_2X_PROGRAM=y
CONFIG_MTD_ONENAND_SIM=y

#
# LPDDR flash memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=y
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
CONFIG_BLK_CPQ_DA=y
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=y

#
# DRBD disabled because PROC_FS, INET or CONNECTOR not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
CONFIG_BLK_DEV_OSD=y
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_CDROM_PKTCDVD_WCACHE=y
CONFIG_ATA_OVER_ETH=y
CONFIG_XEN_BLKDEV_FRONTEND=y
CONFIG_XEN_BLKDEV_BACKEND=y
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_INTEL_MID_PTI=y
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=y
# CONFIG_TIFM_7XX1 is not set
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=y
CONFIG_VMWARE_BALLOON=y
CONFIG_PCH_PHUB=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_93CX6=y
CONFIG_CB710_CORE=y
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y

#
# Altera FPGA firmware download module
#
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
# CONFIG_BLK_DEV_IDE_SATA is not set
# CONFIG_IDE_GD is not set
# CONFIG_BLK_DEV_IDECD is not set
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
CONFIG_BLK_DEV_CMD640=y
# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
CONFIG_BLK_DEV_OPTI621=y
CONFIG_BLK_DEV_RZ1000=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
CONFIG_BLK_DEV_ALI15X3=y
CONFIG_BLK_DEV_AMD74XX=y
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
CONFIG_BLK_DEV_HPT366=y
CONFIG_BLK_DEV_JMICRON=y
CONFIG_BLK_DEV_SC1200=y
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
CONFIG_BLK_DEV_NS87415=y
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
CONFIG_BLK_DEV_SIIMAGE=y
CONFIG_BLK_DEV_SIS5513=y
CONFIG_BLK_DEV_SLC90E66=y
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
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=y
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=y
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
# CONFIG_SCSI_SAS_LIBSAS is not set
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_CXGB3_ISCSI is not set
CONFIG_SCSI_CXGB4_ISCSI=y
CONFIG_SCSI_BNX2_ISCSI=y
CONFIG_SCSI_BNX2X_FCOE=y
CONFIG_BE2ISCSI=y
CONFIG_BLK_DEV_3W_XXXX_RAID=y
CONFIG_SCSI_HPSA=y
CONFIG_SCSI_3W_9XXX=y
CONFIG_SCSI_3W_SAS=y
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
# CONFIG_AIC79XX_BUILD_FIRMWARE is not set
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
CONFIG_SCSI_DPT_I2O=y
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=y
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_HYPERV_STORAGE is not set
CONFIG_LIBFC=y
CONFIG_LIBFCOE=y
CONFIG_FCOE=y
CONFIG_FCOE_FNIC=y
CONFIG_SCSI_DMX3191D=y
CONFIG_SCSI_EATA=y
CONFIG_SCSI_EATA_TAGGED_QUEUE=y
CONFIG_SCSI_EATA_LINKED_COMMANDS=y
CONFIG_SCSI_EATA_MAX_TAGS=16
CONFIG_SCSI_FUTURE_DOMAIN=y
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_ISCI is not set
CONFIG_SCSI_IPS=y
# CONFIG_SCSI_INITIO is not set
CONFIG_SCSI_INIA100=y
CONFIG_SCSI_STEX=y
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
# CONFIG_SCSI_SYM53C8XX_MMIO is not set
CONFIG_SCSI_IPR=y
CONFIG_SCSI_IPR_TRACE=y
CONFIG_SCSI_IPR_DUMP=y
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_DC395x=y
# CONFIG_SCSI_DC390T is not set
CONFIG_SCSI_DEBUG=y
CONFIG_SCSI_PMCRAID=y
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
CONFIG_SCSI_BFA_FC=y
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_DH is not set
CONFIG_SCSI_OSD_INITIATOR=y
CONFIG_SCSI_OSD_ULD=y
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_PMP is not set

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
CONFIG_SATA_AHCI_PLATFORM=y
CONFIG_SATA_INIC162X=y
# CONFIG_SATA_ACARD_AHCI is not set
CONFIG_SATA_SIL24=y
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
CONFIG_SATA_SX4=y
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
# CONFIG_ATA_PIIX is not set
# CONFIG_SATA_HIGHBANK is not set
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
CONFIG_SATA_PROMISE=y
# CONFIG_SATA_SIL is not set
CONFIG_SATA_SIS=y
# CONFIG_SATA_SVW is not set
# CONFIG_SATA_ULI is not set
CONFIG_SATA_VIA=y
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARASAN_CF is not set
CONFIG_PATA_ARTOP=y
CONFIG_PATA_ATIIXP=y
# CONFIG_PATA_ATP867X is not set
# CONFIG_PATA_CMD64X is not set
CONFIG_PATA_CS5520=y
CONFIG_PATA_CS5530=y
CONFIG_PATA_CS5536=y
CONFIG_PATA_CYPRESS=y
CONFIG_PATA_EFAR=y
CONFIG_PATA_HPT366=y
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
CONFIG_PATA_IT8213=y
CONFIG_PATA_IT821X=y
# CONFIG_PATA_JMICRON is not set
CONFIG_PATA_MARVELL=y
CONFIG_PATA_NETCELL=y
CONFIG_PATA_NINJA32=y
CONFIG_PATA_NS87415=y
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
CONFIG_PATA_PDC_OLD=y
CONFIG_PATA_RADISYS=y
# CONFIG_PATA_RDC is not set
CONFIG_PATA_SC1200=y
CONFIG_PATA_SCH=y
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_SIL680 is not set
CONFIG_PATA_SIS=y
CONFIG_PATA_TOSHIBA=y
CONFIG_PATA_TRIFLEX=y
CONFIG_PATA_VIA=y
CONFIG_PATA_WINBOND=y

#
# PIO-only SFF controllers
#
CONFIG_PATA_CMD640_PCI=y
CONFIG_PATA_MPIIX=y
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_PLATFORM is not set
CONFIG_PATA_RZ1000=y

#
# Generic fallback / legacy drivers
#
CONFIG_PATA_ACPI=y
# CONFIG_ATA_GENERIC is not set
CONFIG_PATA_LEGACY=y
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
# CONFIG_MD_LINEAR is not set
# CONFIG_MD_RAID0 is not set
# CONFIG_MD_RAID1 is not set
# CONFIG_MD_RAID10 is not set
# CONFIG_MD_RAID456 is not set
# CONFIG_MD_MULTIPATH is not set
# CONFIG_MD_FAULTY is not set
# CONFIG_BLK_DEV_DM is not set
CONFIG_TARGET_CORE=y
# CONFIG_TCM_IBLOCK is not set
# CONFIG_TCM_FILEIO is not set
CONFIG_TCM_PSCSI=y
CONFIG_LOOPBACK_TARGET=y
CONFIG_TCM_FC=y
# CONFIG_ISCSI_TARGET is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
CONFIG_BONDING=y
CONFIG_DUMMY=y
CONFIG_EQUALIZER=y
# CONFIG_NET_FC is not set
CONFIG_MII=y
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
CONFIG_NETCONSOLE=y
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_RIONET is not set
CONFIG_TUN=y
CONFIG_VETH=y
CONFIG_VIRTIO_NET=y
CONFIG_SUNGEM_PHY=y
CONFIG_ARCNET=y
# CONFIG_ARCNET_1201 is not set
# CONFIG_ARCNET_1051 is not set
CONFIG_ARCNET_RAW=y
# CONFIG_ARCNET_CAP is not set
# CONFIG_ARCNET_COM90xx is not set
CONFIG_ARCNET_COM90xxIO=y
CONFIG_ARCNET_RIM_I=y
CONFIG_ARCNET_COM20020=y
CONFIG_ARCNET_COM20020_PCI=y

#
# CAIF transport drivers
#
CONFIG_CAIF_TTY=y
# CONFIG_CAIF_SPI_SLAVE is not set
CONFIG_CAIF_HSI=y

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=y
CONFIG_NET_DSA_MV88E6060=y
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
CONFIG_NET_DSA_MV88E6123_61_65=y
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
# CONFIG_NET_VENDOR_ALTEON is not set
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=y
# CONFIG_PCNET32 is not set
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
CONFIG_ATL1=y
CONFIG_ATL1E=y
# CONFIG_ATL1C is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
CONFIG_CNIC=y
# CONFIG_TIGON3 is not set
CONFIG_BNX2X=y
# CONFIG_NET_VENDOR_BROCADE is not set
CONFIG_NET_CALXEDA_XGMAC=y
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=y
CONFIG_CHELSIO_T1_1G=y
CONFIG_CHELSIO_T3=y
CONFIG_CHELSIO_T4=y
# CONFIG_CHELSIO_T4VF is not set
# CONFIG_NET_VENDOR_CISCO is not set
CONFIG_DNET=y
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=y
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
# CONFIG_TULIP_MMIO is not set
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=y
# CONFIG_WINBOND_840 is not set
CONFIG_DM9102=y
# CONFIG_ULI526X is not set
# CONFIG_NET_VENDOR_DLINK is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
# CONFIG_NET_VENDOR_EXAR is not set
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
# CONFIG_E1000 is not set
# CONFIG_E1000E is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
# CONFIG_IXGBE is not set
CONFIG_IXGBEVF=y
CONFIG_NET_VENDOR_I825XX=y
CONFIG_ZNET=y
CONFIG_IP1000=y
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_SKGE is not set
CONFIG_SKY2=y
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=y
CONFIG_MLX4_CORE=y
CONFIG_MLX4_DEBUG=y
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851_MLL is not set
CONFIG_KSZ884X_PCI=y
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=y
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
# CONFIG_NET_VENDOR_OKI is not set
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
CONFIG_HAMACHI=y
# CONFIG_YELLOWFIN is not set
# CONFIG_NET_VENDOR_QLOGIC is not set
CONFIG_NET_VENDOR_REALTEK=y
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
CONFIG_8139TOO_TUNE_TWISTER=y
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
# CONFIG_R8169 is not set
# CONFIG_NET_VENDOR_RDC is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_SEEQ8005=y
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
# CONFIG_SFC is not set
# CONFIG_NET_VENDOR_SMSC is not set
# CONFIG_NET_VENDOR_STMICRO is not set
CONFIG_NET_VENDOR_SUN=y
CONFIG_HAPPYMEAL=y
CONFIG_SUNGEM=y
CONFIG_CASSINI=y
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
CONFIG_FDDI=y
CONFIG_DEFXX=y
# CONFIG_DEFXX_MMIO is not set
# CONFIG_SKFP is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AMD_PHY is not set
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
# CONFIG_QSEMI_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_CICADA_PHY is not set
# CONFIG_VITESSE_PHY is not set
# CONFIG_SMSC_PHY is not set
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM87XX_PHY is not set
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
CONFIG_STE10XP=y
# CONFIG_LSI_ET1011C_PHY is not set
CONFIG_MICREL_PHY=y
CONFIG_FIXED_PHY=y
# CONFIG_MDIO_BITBANG is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# USB Network Adapters
#
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_IPHETH is not set
CONFIG_WLAN=y
# CONFIG_AIRO is not set
CONFIG_ATMEL=y
# CONFIG_PCI_ATMEL is not set
CONFIG_PRISM54=y
CONFIG_USB_ZD1201=y
# CONFIG_HOSTAP is not set
CONFIG_WL_TI=y

#
# WiMAX Wireless Broadband devices
#
# CONFIG_WIMAX_I2400M_USB is not set
CONFIG_WAN=y
# CONFIG_HDLC is not set
# CONFIG_DLCI is not set
CONFIG_SBNI=y
# CONFIG_SBNI_MULTILINE is not set
CONFIG_XEN_NETDEV_FRONTEND=y
# CONFIG_XEN_NETDEV_BACKEND is not set
CONFIG_VMXNET3=y
CONFIG_HYPERV_NET=y
# CONFIG_ISDN is not set

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
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
# CONFIG_MOUSE_PS2_ALPS is not set
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
# CONFIG_MOUSE_PS2_TRACKPOINT is not set
CONFIG_MOUSE_PS2_ELANTECH=y
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=y
# CONFIG_MOUSE_APPLETOUCH is not set
CONFIG_MOUSE_BCM5974=y
# CONFIG_MOUSE_VSXXXAA is not set
CONFIG_MOUSE_GPIO=y
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
# CONFIG_JOYSTICK_ANALOG is not set
CONFIG_JOYSTICK_A3D=y
CONFIG_JOYSTICK_ADI=y
# CONFIG_JOYSTICK_COBRA is not set
CONFIG_JOYSTICK_GF2K=y
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
# CONFIG_JOYSTICK_GUILLEMOT is not set
# CONFIG_JOYSTICK_INTERACT is not set
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
# CONFIG_JOYSTICK_IFORCE is not set
# CONFIG_JOYSTICK_WARRIOR is not set
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
# CONFIG_JOYSTICK_STINGER is not set
# CONFIG_JOYSTICK_TWIDJOY is not set
CONFIG_JOYSTICK_ZHENHUA=y
# CONFIG_JOYSTICK_JOYDUMP is not set
# CONFIG_JOYSTICK_XPAD is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
CONFIG_TABLET_USB_AIPTEK=y
CONFIG_TABLET_USB_GTCO=y
CONFIG_TABLET_USB_HANWANG=y
CONFIG_TABLET_USB_KBTAB=y
CONFIG_TABLET_USB_WACOM=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_AD7879=y
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
CONFIG_TOUCHSCREEN_ELO=y
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
# CONFIG_TOUCHSCREEN_MTOUCH is not set
# CONFIG_TOUCHSCREEN_INEXIO is not set
CONFIG_TOUCHSCREEN_MK712=y
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
CONFIG_TOUCHSCREEN_USB_EGALAX=y
CONFIG_TOUCHSCREEN_USB_PANJIT=y
# CONFIG_TOUCHSCREEN_USB_3M is not set
# CONFIG_TOUCHSCREEN_USB_ITM is not set
CONFIG_TOUCHSCREEN_USB_ETURBO=y
# CONFIG_TOUCHSCREEN_USB_GUNZE is not set
# CONFIG_TOUCHSCREEN_USB_DMC_TSC10 is not set
# CONFIG_TOUCHSCREEN_USB_IRTOUCH is not set
# CONFIG_TOUCHSCREEN_USB_IDEALTEK is not set
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
# CONFIG_TOUCHSCREEN_USB_GOTOP is not set
CONFIG_TOUCHSCREEN_USB_JASTEC=y
CONFIG_TOUCHSCREEN_USB_ELO=y
# CONFIG_TOUCHSCREEN_USB_E2I is not set
# CONFIG_TOUCHSCREEN_USB_ZYTRONIC is not set
CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=y
CONFIG_TOUCHSCREEN_USB_NEXIO=y
CONFIG_TOUCHSCREEN_USB_EASYTOUCH=y
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
CONFIG_TOUCHSCREEN_TSC_SERIO=y
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
# CONFIG_GAMEPORT_L4 is not set
CONFIG_GAMEPORT_EMU10K1=y
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
# CONFIG_CYCLADES is not set
CONFIG_MOXA_INTELLIO=y
CONFIG_MOXA_SMARTIO=y
CONFIG_SYNCLINK=y
CONFIG_SYNCLINKMP=y
CONFIG_SYNCLINK_GT=y
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
CONFIG_N_GSM=y
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
CONFIG_DEVKMEM=y
# CONFIG_STALDRV is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_PNP is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
# CONFIG_SERIAL_8250_SHARE_IRQ is not set
CONFIG_SERIAL_8250_DETECT_IRQ=y
# CONFIG_SERIAL_8250_RSA is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MFD_HSU=y
CONFIG_SERIAL_MFD_HSU_CONSOLE=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_CONSOLE_POLL=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ALTERA_UART_CONSOLE=y
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
CONFIG_TTY_PRINTK=y
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
# CONFIG_HVC_XEN_FRONTEND is not set
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
# CONFIG_HW_RANDOM_INTEL is not set
CONFIG_HW_RANDOM_AMD=y
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_HW_RANDOM_VIRTIO=y
# CONFIG_HW_RANDOM_TPM is not set
CONFIG_NVRAM=y
CONFIG_R3964=y
CONFIG_APPLICOM=y
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
# CONFIG_HPET_MMAP is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_I2C is not set
# CONFIG_SPI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
CONFIG_HSI_CHAR=y

#
# PPS support
#
# CONFIG_PPS is not set

#
# PPS generators support
#

#
# PTP clock support
#

#
# Enable Device Drivers -> PPS to see the PTP clock options.
#
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_DEBUG_GPIO=y
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_IT8761E is not set
CONFIG_GPIO_SCH=y
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_VX855=y

#
# I2C GPIO expanders:
#

#
# PCI GPIO expanders:
#
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_AMD8111=y
CONFIG_GPIO_LANGWELL=y
CONFIG_GPIO_PCH=y
# CONFIG_GPIO_ML_IOH is not set
CONFIG_GPIO_RDC321X=y

#
# SPI GPIO expanders:
#

#
# AC97 GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y
CONFIG_HDQ_MASTER_OMAP=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
# CONFIG_W1_SLAVE_DS2760 is not set
# CONFIG_W1_SLAVE_DS2780 is not set
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
# CONFIG_PDA_POWER is not set
CONFIG_TEST_POWER=y
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_BQ27x00=y
# CONFIG_BATTERY_BQ27X00_PLATFORM is not set
# CONFIG_CHARGER_ISP1704 is not set
CONFIG_CHARGER_MAX8903=y
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SIS5595=y
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
CONFIG_SENSORS_APPLESMC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
# CONFIG_THERMAL is not set
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
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_HTC_PASIC3=y
# CONFIG_MFD_TMIO is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_LPC_SCH=y
CONFIG_LPC_ICH=y
CONFIG_MFD_RDC321X=y
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_VX855=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_DUMMY=y
# CONFIG_REGULATOR_FIXED_VOLTAGE is not set
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_GPIO=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
# CONFIG_MEDIA_RADIO_SUPPORT is not set
CONFIG_MEDIA_RC_SUPPORT=y
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y

#
# Media drivers
#
CONFIG_RC_CORE=y
CONFIG_RC_MAP=y
CONFIG_RC_DECODERS=y
# CONFIG_LIRC is not set
CONFIG_IR_NEC_DECODER=y
# CONFIG_IR_RC5_DECODER is not set
CONFIG_IR_RC6_DECODER=y
CONFIG_IR_JVC_DECODER=y
# CONFIG_IR_SONY_DECODER is not set
# CONFIG_IR_RC5_SZ_DECODER is not set
CONFIG_IR_SANYO_DECODER=y
# CONFIG_IR_MCE_KBD_DECODER is not set
CONFIG_RC_DEVICES=y
CONFIG_RC_ATI_REMOTE=y
# CONFIG_IR_ENE is not set
# CONFIG_IR_IMON is not set
CONFIG_IR_MCEUSB=y
CONFIG_IR_ITE_CIR=y
CONFIG_IR_FINTEK=y
CONFIG_IR_NUVOTON=y
# CONFIG_IR_REDRAT3 is not set
CONFIG_IR_STREAMZAP=y
CONFIG_IR_WINBOND_CIR=y
# CONFIG_IR_IGUANA is not set
# CONFIG_IR_TTUSBIR is not set
CONFIG_RC_LOOPBACK=y
# CONFIG_IR_GPIO_CIR is not set
CONFIG_MEDIA_USB_SUPPORT=y

#
# Analog TV USB devices
#
CONFIG_VIDEO_HDPVR=y

#
# Analog/digital TV USB devices
#

#
# Webcam, TV (analog/digital) USB devices
#
# CONFIG_MEDIA_PCI_SUPPORT is not set

#
# Supported MMC/SDIO adapters
#

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#

#
# Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# MPEG video encoders
#
# CONFIG_VIDEO_CX2341X is not set

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
# Miscelaneous helper chips
#

#
# Sensors used on soc_camera driver
#

#
# Customize TV tuners
#

#
# Customise DVB Frontends
#

#
# Tools to develop new frontends
#
CONFIG_DVB_DUMMY_FE=y

#
# Graphics support
#
CONFIG_AGP=y
# CONFIG_AGP_INTEL is not set
CONFIG_AGP_SIS=y
# CONFIG_AGP_VIA is not set
# CONFIG_VGA_ARB is not set
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
# CONFIG_STUB_POULSBO is not set
# CONFIG_VGASTATE is not set
CONFIG_VIDEO_OUTPUT_CONTROL=y
# CONFIG_FB is not set
CONFIG_EXYNOS_VIDEO=y
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_SOUND=y
# CONFIG_SOUND_OSS_CORE is not set
# CONFIG_SND is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_EZKEY=y
CONFIG_HID_HOLTEK=y
CONFIG_HOLTEK_FF=y
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
CONFIG_HID_WALTOP=y
# CONFIG_HID_GYRATION is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
CONFIG_HID_LENOVO_TPKBD=y
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_NTRIG=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PRIMAX=y
CONFIG_HID_ROCCAT=y
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SONY is not set
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
# CONFIG_HID_HYPERV_MOUSE is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG_WHITELIST=y
CONFIG_USB_OTG_BLACKLIST_HUB=y
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_MON is not set
CONFIG_USB_WUSB=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_OXU210HP_HCD=y
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_R8A66597_HCD=y
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=y
# CONFIG_USB_HCD_BCMA is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_TUSB6010=y
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_UDC=y
CONFIG_USB_CHIPIDEA_HOST=y
CONFIG_USB_CHIPIDEA_DEBUG=y
# CONFIG_USB_RENESAS_USBHS is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
CONFIG_USB_STORAGE_DEBUG=y
# CONFIG_USB_STORAGE_REALTEK is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
# CONFIG_USB_STORAGE_ISD200 is not set
CONFIG_USB_STORAGE_USBAT=y
# CONFIG_USB_STORAGE_SDDR09 is not set
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
CONFIG_USB_STORAGE_ONETOUCH=y
# CONFIG_USB_STORAGE_KARMA is not set
CONFIG_USB_STORAGE_CYPRESS_ATACB=y
CONFIG_USB_STORAGE_ENE_UB6250=y
# CONFIG_USB_UAS is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
CONFIG_USB_RIO500=y
CONFIG_USB_LEGOTOWER=y
# CONFIG_USB_LCD is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
CONFIG_USB_CYTHERM=y
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y

#
# USB Physical Layer drivers
#
CONFIG_OMAP_USB2=y
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_R8A66597=y
# CONFIG_USB_MV_UDC is not set
CONFIG_USB_GADGET_MUSB_HDRC=y
CONFIG_USB_M66592=y
# CONFIG_USB_AMD5536UDC is not set
CONFIG_USB_NET2272=y
CONFIG_USB_NET2272_DMA=y
CONFIG_USB_NET2280=y
# CONFIG_USB_GOKU is not set
CONFIG_USB_EG20T=y
CONFIG_USB_DUMMY_HCD=y
CONFIG_USB_LIBCOMPOSITE=y
# CONFIG_USB_ZERO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_FILE_STORAGE is not set
# CONFIG_USB_MASS_STORAGE is not set
CONFIG_USB_GADGET_TARGET=y
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set

#
# OTG and related infrastructure
#
CONFIG_USB_OTG_UTILS=y
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_NOP_USB_XCEIV is not set
CONFIG_UWB=y
CONFIG_UWB_HWA=y
CONFIG_UWB_WHCI=y
# CONFIG_UWB_I1480U is not set
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
# CONFIG_MMC_UNSAFE_RESUME is not set
CONFIG_MMC_CLKGATE=y

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_MMC_BLOCK is not set
CONFIG_SDIO_UART=y
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
# CONFIG_MMC_WBSD is not set
# CONFIG_MMC_TIFM_SD is not set
CONFIG_MMC_CB710=y
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_VUB300=y
CONFIG_MMC_USHC=y
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_LT3593=y
# CONFIG_LEDS_OT200 is not set
CONFIG_LEDS_TRIGGERS=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=y
# CONFIG_INFINIBAND_USER_MAD is not set
CONFIG_INFINIBAND_USER_ACCESS=y
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ADDR_TRANS=y
# CONFIG_INFINIBAND_MTHCA is not set
CONFIG_INFINIBAND_QIB=y
# CONFIG_INFINIBAND_AMSO1100 is not set
CONFIG_INFINIBAND_CXGB3=y
CONFIG_INFINIBAND_CXGB3_DEBUG=y
# CONFIG_INFINIBAND_CXGB4 is not set
CONFIG_MLX4_INFINIBAND=y
# CONFIG_INFINIBAND_NES is not set
# CONFIG_INFINIBAND_OCRDMA is not set
CONFIG_INFINIBAND_IPOIB=y
# CONFIG_INFINIBAND_IPOIB_CM is not set
# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
CONFIG_INFINIBAND_SRP=y
CONFIG_INFINIBAND_SRPT=y
CONFIG_INFINIBAND_ISER=y
CONFIG_EDAC=y

#
# Reporting subsystems
#
CONFIG_EDAC_LEGACY_SYSFS=y
CONFIG_EDAC_DEBUG=y
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
# CONFIG_RTC_INTF_DEV is not set
CONFIG_RTC_DRV_TEST=y

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
# CONFIG_RTC_DRV_DS2404 is not set

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_INTEL_MID_DMAC=y
# CONFIG_INTEL_IOATDMA is not set
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
CONFIG_ASYNC_TX_DMA=y
# CONFIG_DMATEST is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV=y
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_AEC=y
# CONFIG_UIO_SERCOS3 is not set
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
# CONFIG_VFIO is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
# CONFIG_VIRTIO_BALLOON is not set
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=y
CONFIG_HYPERV_UTILS=y

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_SCRUB_PAGES is not set
# CONFIG_XEN_DEV_EVTCHN is not set
CONFIG_XEN_BACKEND=y
# CONFIG_XENFS is not set
# CONFIG_XEN_SYS_HYPERVISOR is not set
CONFIG_XEN_XENBUS_FRONTEND=y
# CONFIG_XEN_GNTDEV is not set
# CONFIG_XEN_GRANT_DEV_ALLOC is not set
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_PCIDEV_BACKEND=y
CONFIG_XEN_PRIVCMD=y
# CONFIG_XEN_MCE_LOG is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ASUS_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
CONFIG_PANASONIC_LAPTOP=y
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
CONFIG_EEEPC_LAPTOP=y
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
CONFIG_TOSHIBA_BT_RFKILL=y
# CONFIG_ACPI_CMPC is not set
CONFIG_INTEL_IPS=y
CONFIG_IBM_RTL=y
CONFIG_XO15_EBOOK=y
CONFIG_SAMSUNG_LAPTOP=y
# CONFIG_SAMSUNG_Q10 is not set
CONFIG_APPLE_GMUX=y

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y
# CONFIG_AMD_IOMMU is not set
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers (EXPERIMENTAL)
#

#
# Rpmsg drivers (EXPERIMENTAL)
#
CONFIG_VIRT_DRIVERS=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
CONFIG_DEVFREQ_GOV_USERSPACE=y

#
# DEVFREQ Drivers
#
# CONFIG_EXTCON is not set
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
CONFIG_HID_SENSOR_ACCEL_3D=y

#
# Analog to digital converters
#

#
# Amplifiers
#

#
# Light sensors
#
CONFIG_HID_SENSOR_ALS=y

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
# Digital to analog converters
#

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_ENUM_BASE_QUIRKS=y

#
# Digital gyroscope sensors
#
# CONFIG_HID_SENSOR_GYRO_3D is not set

#
# Light sensors
#

#
# Magnetometer sensors
#
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
# CONFIG_VME_CA91CX42 is not set
CONFIG_VME_TSI148=y

#
# VME Board Drivers
#
# CONFIG_VMIVME_7805 is not set

#
# VME Device Drivers
#
# CONFIG_PWM is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
CONFIG_EXT2_FS_XIP=y
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
# CONFIG_EXT4_FS is not set
CONFIG_FS_XIP=y
CONFIG_JBD=y
CONFIG_JBD_DEBUG=y
CONFIG_JBD2=y
CONFIG_JBD2_DEBUG=y
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
CONFIG_REISERFS_CHECK=y
CONFIG_REISERFS_FS_XATTR=y
# CONFIG_REISERFS_FS_POSIX_ACL is not set
# CONFIG_REISERFS_FS_SECURITY is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
# CONFIG_XFS_POSIX_ACL is not set
# CONFIG_XFS_RT is not set
# CONFIG_XFS_DEBUG is not set
# CONFIG_GFS2_FS is not set
CONFIG_OCFS2_FS=y
CONFIG_OCFS2_FS_O2CB=y
# CONFIG_OCFS2_FS_USERSPACE_CLUSTER is not set
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
# CONFIG_BTRFS_FS is not set
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
# CONFIG_VFAT_FS is not set
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_NTFS_FS=y
CONFIG_NTFS_DEBUG=y
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
# CONFIG_PROC_FS is not set
CONFIG_SYSFS=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
CONFIG_HFS_FS=y
CONFIG_HFSPLUS_FS=y
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_JFFS2_FS is not set
# CONFIG_UBIFS_FS is not set
# CONFIG_LOGFS is not set
# CONFIG_CRAMFS is not set
CONFIG_SQUASHFS=y
# CONFIG_SQUASHFS_XATTR is not set
# CONFIG_SQUASHFS_ZLIB is not set
# CONFIG_SQUASHFS_LZO is not set
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
CONFIG_SQUASHFS_EMBEDDED=y
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
CONFIG_MINIX_FS=y
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
CONFIG_QNX4FS_FS=y
# CONFIG_QNX6FS_FS is not set
CONFIG_ROMFS_FS=y
# CONFIG_ROMFS_BACKED_BY_BLOCK is not set
CONFIG_ROMFS_BACKED_BY_MTD=y
# CONFIG_ROMFS_BACKED_BY_BOTH is not set
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_RAM is not set
CONFIG_SYSV_FS=y
# CONFIG_UFS_FS is not set
# CONFIG_EXOFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
# CONFIG_NFS_V2 is not set
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
CONFIG_ROOT_NFS=y
CONFIG_NFS_USE_LEGACY_DNS=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_SUNRPC_XPRT_RDMA=y
CONFIG_RPCSEC_GSS_KRB5=y
CONFIG_CEPH_FS=y
CONFIG_CIFS=y
CONFIG_CIFS_STATS=y
# CONFIG_CIFS_STATS2 is not set
CONFIG_CIFS_WEAK_PW_HASH=y
# CONFIG_CIFS_UPCALL is not set
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG2=y
# CONFIG_CIFS_DFS_UPCALL is not set
CONFIG_NCP_FS=y
CONFIG_NCPFS_PACKET_SIGNING=y
# CONFIG_NCPFS_IOCTL_LOCKING is not set
# CONFIG_NCPFS_STRONG is not set
CONFIG_NCPFS_NFS_NS=y
# CONFIG_NCPFS_OS2_NS is not set
# CONFIG_NCPFS_SMALLDOS is not set
# CONFIG_NCPFS_NLS is not set
CONFIG_NCPFS_EXTRAS=y
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_9P_FS=y
# CONFIG_9P_FS_POSIX_ACL is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=y
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=y
# CONFIG_NLS_MAC_ROMANIAN is not set
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y
CONFIG_DLM=y
# CONFIG_DLM_DEBUG is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
# CONFIG_LOCKUP_DETECTOR is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
CONFIG_DEBUG_OBJECTS_FREE=y
CONFIG_DEBUG_OBJECTS_TIMERS=y
# CONFIG_DEBUG_OBJECTS_WORK is not set
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_RB=y
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_WRITECOUNT is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
# CONFIG_DEBUG_LIST is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
CONFIG_RCU_CPU_STALL_INFO=y
# CONFIG_RCU_TRACE is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_LKDTM=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_CPU_NOTIFIER_ERROR_INJECT=y
# CONFIG_PM_NOTIFIER_ERROR_INJECT is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DYNAMIC_DEBUG is not set
# CONFIG_DMA_API_DEBUG is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_KGDB=y
CONFIG_KGDB_SERIAL_CONSOLE=y
# CONFIG_KGDB_TESTS is not set
CONFIG_KGDB_LOW_LEVEL_TRAP=y
CONFIG_KGDB_KDB=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_STRICT_DEVMEM is not set
# CONFIG_X86_VERBOSE_BOOTUP is not set
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
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
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_DEBUG_NMI_SELFTEST=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
CONFIG_SECURITY_PATH=y
CONFIG_INTEL_TXT=y
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
# CONFIG_INTEGRITY_SIGNATURE is not set
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_APPRAISE=y
CONFIG_EVM=y
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
CONFIG_CRYPTO_USER=y
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
CONFIG_CRYPTO_SHA256=y
# CONFIG_CRYPTO_SHA512 is not set
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
# CONFIG_CRYPTO_CAST6 is not set
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES_SPARC64 is not set
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=y
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
# CONFIG_CRYPTO_LZO is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
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
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
# CONFIG_XZ_DEC_ARMTHUMB is not set
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set

--azLHFNyN32YCQGCU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
