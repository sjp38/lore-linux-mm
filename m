Date: Thu, 17 Apr 2008 13:07:27 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] - Increase MAX_APICS for large configs
Message-ID: <20080417110727.GA942@elte.hu>
References: <20080416163936.GA23099@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080416163936.GA23099@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> Increase the maximum number of apics when running very large 
> configurations. This patch has no affect on most systems.

x86.git overnight random-qa testing found a boot crash and i bisected it 
down to this patch. The config is:

 http://redhat.com/~mingo/misc/config-Thu_Apr_17_10_17_14_CEST_2008.bad

the failure is attached below. (I needed the exact boot parameters 
listed in that bootup log to see this failure.)

it seems to be CONFIG_MAXSMP=y triggers the new more-apic-ids code and 
that causes some breakage elsewhere. [btw., this again shows how useful 
the CONFIG_MAXSMP debug feature is!]

	Ingo

[    0.000000] Linux version 2.6.25-rc9-sched-devel.git-x86-latest.git (mingo@dione) (gcc version 4.2.3) #260 SMP Thu Apr 17 10:58:11 CEST 2008
[    0.000000] Command line: root=/dev/sda6 console=ttyS0,115200 earlyprintk=serial,ttyS0,115200 debug initcall_debug apic=verbose sysrq_always_enabled ignore_loglevel selinux=0 nmi_watchdog=2 profile=0 nosmp highres=0 nolapic_timer hpet=disable idle=poll highmem=512m nopat acpi=off
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003fff0000 (usable)
[    0.000000]  BIOS-e820: 000000003fff0000 - 000000003fff3000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003fff3000 - 0000000040000000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
[    0.000000] console [earlyser0] enabled
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] using polling idle threads.
[    0.000000] x86: PAT support disabled.
[    0.000000] Entering add_active_range(0, 0, 159) 0 entries of 25600 used
[    0.000000] Entering add_active_range(0, 256, 262128) 1 entries of 25600 used
[    0.000000] max_pfn_mapped = 1048576
[    0.000000] x86: PAT support disabled.
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.3 present.
[    0.000000] Entering add_active_range(0, 0, 159) 0 entries of 25600 used
[    0.000000] Entering add_active_range(0, 256, 262128) 1 entries of 25600 used
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-1cec66b] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-afff] PGTABLE
[    0.000000]  [ffffe20000000000-ffffe20000dfffff] PMD -> [ffff810001e00000-ffff810002bfffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   262128
[    0.000000] On node 0 totalpages: 262031
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 104 pages reserved
[    0.000000]   DMA zone: 3839 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 3527 pages used for memmap
[    0.000000]   DMA32 zone: 254505 pages, LIFO batch:31
[    0.000000]   Normal zone: 0 pages used for memmap
[    0.000000]   Movable zone: 0 pages used for memmap
[    0.000000] Nvidia board detected. Ignoring ACPI timer override.
[    0.000000] If you got timer trouble try acpi_use_timer_override
[    0.000000] Intel MultiProcessor Specification v1.4
[    0.000000] MPTABLE: OEM ID: OEM00000 Product ID: PROD00000000 <6>MPTABLE: Product ID: PROD00000000 <6>MPTABLE: APIC at: 0xFEE00000
[    0.000000] Processor #0 (Bootup-CPU)
[    0.000000] Processor #1
[    0.000000] I/O APIC #2 Version 17 at 0xFEC00000.
[    0.000000] Setting APIC routing to flat
[    0.000000] Processors: 2
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] Allocating PCI resources starting at 50000000 (gap: 40000000:a0000000)
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] PERCPU: Allocating 43592 bytes of per cpu data
[    0.000000] NR_CPUS: 4096, nr_cpu_ids: 2
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 258344
[    0.000000] Kernel command line: root=/dev/sda6 console=ttyS0,115200 earlyprintk=serial,ttyS0,115200 debug initcall_debug apic=verbose sysrq_always_enabled ignore_loglevel selinux=0 nmi_watchdog=2 profile=0 nosmp highres=0 nolapic_timer hpet=disable idle=poll highmem=512m nopat acpi=off
[    0.000000] debug: sysrq always enabled.
[    0.000000] kernel profiling enabled (shift: 0)
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[    0.000000] TSC calibrated against PIT
[    0.000000] Marking TSC unstable due to TSCs unsynchronized
[    0.000000] time.c: Detected 2010.306 MHz processor.
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console handover: boot [earlyser0] -> real [ttyS0]
[    0.000000] Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.000000] Memory: 971356k/1048512k available (8142k kernel code, 76252k reserved, 6594k data, 656k init)
[    0.000000] CPA: page pool initialized 1 of 1 pages preallocated
[    0.084005] Calibrating delay using timer specific routine.. 4023.95 BogoMIPS (lpj=8047909)
[    0.092005] Security Framework initialized
[    0.096006] Capability LSM initialized
[    0.100006] Mount-cache hash table entries: 256
[    0.104006] Initializing cgroup subsys cpuacct
[    0.108006] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
[    0.112007] CPU: L2 Cache: 512K (64 bytes/line)
[    0.116007] CPU: Physical Processor ID: 0
[    0.120007] CPU: Processor Core ID: 0
[    0.124007] SMP alternatives: switching to UP code
[    0.160010] SMP mode deactivated,forcing use of dummy APIC emulation.
[    0.164010] SMP disabled
[    0.168010] Brought up 1 CPUs
[    0.172010] Total of 1 processors activated (4023.95 BogoMIPS).
[    0.180011] Calling initcall 0xffffffff81a50e82: net_ns_init+0x0/0x15e()
[    0.184011] net_namespace: 408 bytes
[    0.188011] initcall 0xffffffff81a50e82: net_ns_init+0x0/0x15e() returned 0.
[    0.196012] initcall 0xffffffff81a50e82 ran for 3 msecs: net_ns_init+0x0/0x15e()
[    0.204012] Calling initcall 0xffffffff809ea96c: init_smp_flush+0x0/0x64()
[    0.208013] initcall 0xffffffff809ea96c: init_smp_flush+0x0/0x64() returned 0.
[    0.216013] initcall 0xffffffff809ea96c ran for 0 msecs: init_smp_flush+0x0/0x64()
[    0.220013] Calling initcall 0xffffffff81a26c98: sysctl_init+0x0/0x37()
[    0.228014] initcall 0xffffffff81a26c98: sysctl_init+0x0/0x37() returned 0.
[    0.236014] initcall 0xffffffff81a26c98 ran for 0 msecs: sysctl_init+0x0/0x37()
[    0.240015] Calling initcall 0xffffffff81a27660: ksysfs_init+0x0/0xc0()
[    0.244015] initcall 0xffffffff81a27660: ksysfs_init+0x0/0xc0() returned 0.
[    0.252015] initcall 0xffffffff81a27660 ran for 0 msecs: ksysfs_init+0x0/0xc0()
[    0.260016] Calling initcall 0xffffffff81a27a2f: init_jiffies_clocksource+0x0/0x17()
[    0.268016] initcall 0xffffffff81a27a2f: init_jiffies_clocksource+0x0/0x17() returned 0.
[    0.276017] initcall 0xffffffff81a27a2f ran for 0 msecs: init_jiffies_clocksource+0x0/0x17()
[    0.284017] Calling initcall 0xffffffff81a27c38: pm_init+0x0/0x48()
[    0.288018] initcall 0xffffffff81a27c38: pm_init+0x0/0x48() returned 0.
[    0.296018] initcall 0xffffffff81a27c38 ran for 0 msecs: pm_init+0x0/0x48()
[    0.304019] Calling initcall 0xffffffff81a28ca1: ftrace_dynamic_init+0x0/0xef()
[    0.312019] initcall 0xffffffff81a28ca1: ftrace_dynamic_init+0x0/0xef() returned 0.
[    0.320020] initcall 0xffffffff81a28ca1 ran for 0 msecs: ftrace_dynamic_init+0x0/0xef()
[    0.328020] Calling initcall 0xffffffff81a2bb17: filelock_init+0x0/0x39()
[    0.332020] initcall 0xffffffff81a2bb17: filelock_init+0x0/0x39() returned 0.
[    0.340021] initcall 0xffffffff81a2bb17 ran for 0 msecs: filelock_init+0x0/0x39()
[    0.344021] Calling initcall 0xffffffff81a2c677: init_script_binfmt+0x0/0x17()
[    0.352022] initcall 0xffffffff81a2c677: init_script_binfmt+0x0/0x17() returned 0.
[    0.360022] initcall 0xffffffff81a2c677 ran for 0 msecs: init_script_binfmt+0x0/0x17()
[    0.368023] Calling initcall 0xffffffff81a2c68e: init_elf_binfmt+0x0/0x17()
[    0.376023] initcall 0xffffffff81a2c68e: init_elf_binfmt+0x0/0x17() returned 0.
[    0.384024] initcall 0xffffffff81a2c68e ran for 0 msecs: init_elf_binfmt+0x0/0x17()
[    0.388024] Calling initcall 0xffffffff81a2c6a5: init_compat_elf_binfmt+0x0/0x17()
[    0.392024] initcall 0xffffffff81a2c6a5: init_compat_elf_binfmt+0x0/0x17() returned 0.
[    0.400025] initcall 0xffffffff81a2c6a5 ran for 0 msecs: init_compat_elf_binfmt+0x0/0x17()
[    0.404025] Calling initcall 0xffffffff81a2f015: debugfs_init+0x0/0x6b()
[    0.408025] initcall 0xffffffff81a2f015: debugfs_init+0x0/0x6b() returned 0.
[    0.416026] initcall 0xffffffff81a2f015 ran for 0 msecs: debugfs_init+0x0/0x6b()
[    0.424026] Calling initcall 0xffffffff81a2f810: securityfs_init+0x0/0x62()
[    0.432027] initcall 0xffffffff81a2f810: securityfs_init+0x0/0x62() returned 0.
[    0.436027] initcall 0xffffffff81a2f810 ran for 0 msecs: securityfs_init+0x0/0x62()
[    0.440027] Calling initcall 0xffffffff81a30652: random32_init+0x0/0x67()
[    0.448028] initcall 0xffffffff81a30652: random32_init+0x0/0x67() returned 0.
[    0.456028] initcall 0xffffffff81a30652 ran for 0 msecs: random32_init+0x0/0x67()
[    0.464029] Calling initcall 0xffffffff8083949f: virtio_init+0x0/0x2b()
[    0.468029] initcall 0xffffffff8083949f: virtio_init+0x0/0x2b() returned 0.
[    0.476029] initcall 0xffffffff8083949f ran for 0 msecs: virtio_init+0x0/0x2b()
[    0.480030] Calling initcall 0xffffffff81a50d40: sock_init+0x0/0x60()
[    0.488030] initcall 0xffffffff81a50d40: sock_init+0x0/0x60() returned 0.
[    0.492030] initcall 0xffffffff81a50d40 ran for 0 msecs: sock_init+0x0/0x60()
[    0.496031] Calling initcall 0xffffffff81a51aed: netpoll_init+0x0/0x36()
[    0.504031] initcall 0xffffffff81a51aed: netpoll_init+0x0/0x36() returned 0.
[    0.512032] initcall 0xffffffff81a51aed ran for 0 msecs: netpoll_init+0x0/0x36()
[    0.520032] Calling initcall 0xffffffff81a51bab: netlink_proto_init+0x0/0x17b()
[    0.524032] NET: Registered protocol family 16
[    0.528033] initcall 0xffffffff81a51bab: netlink_proto_init+0x0/0x17b() returned 0.
[    0.536033] initcall 0xffffffff81a51bab ran for 3 msecs: netlink_proto_init+0x0/0x17b()
[    0.544034] Calling initcall 0xffffffff81a30525: kobject_uevent_init+0x0/0x4c()
[    0.548034] initcall 0xffffffff81a30525: kobject_uevent_init+0x0/0x4c() returned 0.
[    0.556034] initcall 0xffffffff81a30525 ran for 0 msecs: kobject_uevent_init+0x0/0x4c()
[    0.560035] Calling initcall 0xffffffff81a307b7: pcibus_class_init+0x0/0x17()
[    0.568035] initcall 0xffffffff81a307b7: pcibus_class_init+0x0/0x17() returned 0.
[    0.576036] initcall 0xffffffff81a307b7 ran for 0 msecs: pcibus_class_init+0x0/0x17()
[    0.584036] Calling initcall 0xffffffff81a30eb8: pci_driver_init+0x0/0x17()
[    0.592037] initcall 0xffffffff81a30eb8: pci_driver_init+0x0/0x17() returned 0.
[    0.600037] initcall 0xffffffff81a30eb8 ran for 0 msecs: pci_driver_init+0x0/0x17()
[    0.608038] Calling initcall 0xffffffff81a31701: backlight_class_init+0x0/0x4e()
[    0.616038] initcall 0xffffffff81a31701: backlight_class_init+0x0/0x4e() returned 0.
[    0.624039] initcall 0xffffffff81a31701 ran for 0 msecs: backlight_class_init+0x0/0x4e()
[    0.632039] Calling initcall 0xffffffff81a33e76: video_output_class_init+0x0/0x17()
[    0.640040] initcall 0xffffffff81a33e76: video_output_class_init+0x0/0x17() returned 0.
[    0.648040] initcall 0xffffffff81a33e76 ran for 0 msecs: video_output_class_init+0x0/0x17()
[    0.656041] Calling initcall 0xffffffff81a352b7: dock_init+0x0/0x56()
[    0.660041] ACPI Exception (utmutex-0263): AE_BAD_PARAMETER, Thread FFFF81003FB5F0C0 could not acquire Mutex [1] [20070126]
[    0.668041] No dock devices found.
[    0.672042] initcall 0xffffffff81a352b7: dock_init+0x0/0x56() returned 0.
[    0.680042] initcall 0xffffffff81a352b7 ran for 11 msecs: dock_init+0x0/0x56()
[    0.688043] Calling initcall 0xffffffff81a36581: tty_class_init+0x0/0x2f()
[    0.692043] initcall 0xffffffff81a36581: tty_class_init+0x0/0x2f() returned 0.
[    0.700043] initcall 0xffffffff81a36581 ran for 0 msecs: tty_class_init+0x0/0x2f()
[    0.708044] Calling initcall 0xffffffff81a36e5b: vtconsole_class_init+0x0/0xd9()
[    0.716044] initcall 0xffffffff81a36e5b: vtconsole_class_init+0x0/0xd9() returned 0.
[    0.724045] initcall 0xffffffff81a36e5b ran for 0 msecs: vtconsole_class_init+0x0/0xd9()
[    0.732045] Calling initcall 0xffffffff81a504e1: early_fill_mp_bus_info+0x0/0x85f()
[    0.740046] node 0 link 0: io port [1000, fffff]
[    0.744046] TOM: 0000000040000000 aka 1024M
[    0.748046] node 0 link 0: mmio [e0000000, efffffff]
[    0.752047] node 0 link 0: mmio [feb00000, fec0ffff]
[    0.756047] node 0 link 0: mmio [a0000, bffff]
[    0.760047] node 0 link 0: mmio [40000000, fed3ffff]
[    0.764047] bus: [00,ff] on node 0 link 0
[    0.768048] bus: 00 index 0 io port: [0, ffff]
[    0.772048] bus: 00 index 1 mmio: [40000000, fcffffffff]
[    0.776048] bus: 00 index 2 mmio: [feb00000, fec0ffff]
[    0.780048] bus: 00 index 3 mmio: [a0000, bffff]
[    0.784049] initcall 0xffffffff81a504e1: early_fill_mp_bus_info+0x0/0x85f() returned 0.
[    0.792049] initcall 0xffffffff81a504e1 ran for 41 msecs: early_fill_mp_bus_info+0x0/0x85f()
[    0.800050] Calling initcall 0xffffffff81a1e4c3: arch_kdebugfs_init+0x0/0xd()
[    0.808050] initcall 0xffffffff81a1e4c3: arch_kdebugfs_init+0x0/0xd() returned 0.
[    0.816051] initcall 0xffffffff81a1e4c3 ran for 0 msecs: arch_kdebugfs_init+0x0/0xd()
[    0.824051] Calling initcall 0xffffffff81a1f2fa: mtrr_if_init+0x0/0x86()
[    0.828051] initcall 0xffffffff81a1f2fa: mtrr_if_init+0x0/0x86() returned 0.
[    0.836052] initcall 0xffffffff81a1f2fa ran for 0 msecs: mtrr_if_init+0x0/0x86()
[    0.840052] Calling initcall 0xffffffff81a31568: acpi_pci_init+0x0/0x48()
[    0.848053] initcall 0xffffffff81a31568: acpi_pci_init+0x0/0x48() returned 0.
[    0.856053] initcall 0xffffffff81a31568 ran for 0 msecs: acpi_pci_init+0x0/0x48()
[    0.864054] Calling initcall 0xffffffff81a34f33: init_acpi_device_notify+0x0/0x50()
[    0.868054] initcall 0xffffffff81a34f33: init_acpi_device_notify+0x0/0x50() returned 0.
[    0.876054] initcall 0xffffffff81a34f33 ran for 0 msecs: init_acpi_device_notify+0x0/0x50()
[    0.884055] Calling initcall 0xffffffff81a4f5d0: pci_access_init+0x0/0x47()
[    0.888055] PCI: Using configuration type 1 for base access
[    0.892055] initcall 0xffffffff81a4f5d0: pci_access_init+0x0/0x47() returned 0.
[    0.900056] initcall 0xffffffff81a4f5d0 ran for 3 msecs: pci_access_init+0x0/0x47()
[    0.908056] Calling initcall 0xffffffff81a1e479: topology_init+0x0/0x4a()
[    0.912057] initcall 0xffffffff81a1e479: topology_init+0x0/0x4a() returned 0.
[    0.920057] initcall 0xffffffff81a1e479 ran for 0 msecs: topology_init+0x0/0x4a()
[    0.928058] Calling initcall 0xffffffff81a1efb9: mtrr_init_finialize+0x0/0x3b()
[    0.936058] initcall 0xffffffff81a1efb9: mtrr_init_finialize+0x0/0x3b() returned 0.
[    0.944059] initcall 0xffffffff81a1efb9 ran for 0 msecs: mtrr_init_finialize+0x0/0x3b()
[    0.952059] Calling initcall 0xffffffff81a271b3: param_sysfs_init+0x0/0x21e()
[    0.980061] initcall 0xffffffff81a271b3: param_sysfs_init+0x0/0x21e() returned 0.
[    0.988061] initcall 0xffffffff81a271b3 ran for 19 msecs: param_sysfs_init+0x0/0x21e()
[    0.996062] Calling initcall 0xffffffff80270cfc: pm_sysrq_init+0x0/0x1e()
[    1.004062] initcall 0xffffffff80270cfc: pm_sysrq_init+0x0/0x1e() returned 0.
[    1.008063] initcall 0xffffffff80270cfc ran for 0 msecs: pm_sysrq_init+0x0/0x1e()
[    1.012063] Calling initcall 0xffffffff81a2af4e: readahead_init+0x0/0x17()
[    1.020063] initcall 0xffffffff81a2af4e: readahead_init+0x0/0x17() returned 0.
[    1.028064] initcall 0xffffffff81a2af4e ran for 0 msecs: readahead_init+0x0/0x17()
[    1.036064] Calling initcall 0xffffffff81a2c2aa: init_bio+0x0/0x100()
[    1.040065] initcall 0xffffffff81a2c2aa: init_bio+0x0/0x100() returned 0.
[    1.048065] initcall 0xffffffff81a2c2aa ran for 0 msecs: init_bio+0x0/0x100()
[    1.052065] Calling initcall 0xffffffff81a302d4: blk_settings_init+0x0/0x31()
[    1.060066] initcall 0xffffffff81a302d4: blk_settings_init+0x0/0x31() returned 0.
[    1.068066] initcall 0xffffffff81a302d4 ran for 0 msecs: blk_settings_init+0x0/0x31()
[    1.076067] Calling initcall 0xffffffff81a30305: blk_ioc_init+0x0/0x2f()
[    1.080067] initcall 0xffffffff81a30305: blk_ioc_init+0x0/0x2f() returned 0.
[    1.088068] initcall 0xffffffff81a30305 ran for 0 msecs: blk_ioc_init+0x0/0x2f()
[    1.096068] Calling initcall 0xffffffff81a30334: genhd_device_init+0x0/0x48()
[    1.104069] initcall 0xffffffff81a30334: genhd_device_init+0x0/0x48() returned 0.
[    1.112069] initcall 0xffffffff81a30334 ran for 0 msecs: genhd_device_init+0x0/0x48()
[    1.120070] Calling initcall 0xffffffff81a31645: fbmem_init+0x0/0x9e()
[    1.128070] initcall 0xffffffff81a31645: fbmem_init+0x0/0x9e() returned 0.
[    1.132070] initcall 0xffffffff81a31645 ran for 3 msecs: fbmem_init+0x0/0x9e()
[    1.136071] Calling initcall 0xffffffff81a34d12: acpi_init+0x0/0x221()
[    1.144071] ACPI: Interpreter disabled.
[    1.148071] initcall 0xffffffff81a34d12: acpi_init+0x0/0x221() returned -19.
[    1.156072] initcall 0xffffffff81a34d12 ran for 3 msecs: acpi_init+0x0/0x221()
[    1.160072] Calling initcall 0xffffffff81a34f83: acpi_scan_init+0x0/0x115()
[    1.168073] initcall 0xffffffff81a34f83: acpi_scan_init+0x0/0x115() returned 0.
[    1.176073] initcall 0xffffffff81a34f83 ran for 0 msecs: acpi_scan_init+0x0/0x115()
[    1.184074] Calling initcall 0xffffffff81a35098: acpi_ec_init+0x0/0x66()
[    1.192074] initcall 0xffffffff81a35098: acpi_ec_init+0x0/0x66() returned 0.
[    1.196074] initcall 0xffffffff81a35098 ran for 0 msecs: acpi_ec_init+0x0/0x66()
[    1.200075] Calling initcall 0xffffffff81a3530d: acpi_pci_root_init+0x0/0x2d()
[    1.208075] initcall 0xffffffff81a3530d: acpi_pci_root_init+0x0/0x2d() returned 0.
[    1.216076] initcall 0xffffffff81a3530d ran for 0 msecs: acpi_pci_root_init+0x0/0x2d()
[    1.224076] Calling initcall 0xffffffff81a354dc: acpi_pci_link_init+0x0/0x4d()
[    1.232077] initcall 0xffffffff81a354dc: acpi_pci_link_init+0x0/0x4d() returned 0.
[    1.240077] initcall 0xffffffff81a354dc ran for 0 msecs: acpi_pci_link_init+0x0/0x4d()
[    1.248078] Calling initcall 0xffffffff81a35529: acpi_power_init+0x0/0x7c()
[    1.252078] initcall 0xffffffff81a35529: acpi_power_init+0x0/0x7c() returned 0.
[    1.260078] initcall 0xffffffff81a35529 ran for 0 msecs: acpi_power_init+0x0/0x7c()
[    1.264079] Calling initcall 0xffffffff81a355ec: acpi_system_init+0x0/0x1b3()
[    1.272079] initcall 0xffffffff81a355ec: acpi_system_init+0x0/0x1b3() returned 0.
[    1.280080] initcall 0xffffffff81a355ec ran for 0 msecs: acpi_system_init+0x0/0x1b3()
[    1.288080] Calling initcall 0xffffffff81a35880: pnp_init+0x0/0x25()
[    1.296081] Linux Plug and Play Support v0.97 (c) Adam Belay
[    1.300081] initcall 0xffffffff81a35880: pnp_init+0x0/0x25() returned 0.
[    1.308081] initcall 0xffffffff81a35880 ran for 3 msecs: pnp_init+0x0/0x25()
[    1.312082] Calling initcall 0xffffffff81a35ace: pnpacpi_init+0x0/0x95()
[    1.316082] pnp: PnP ACPI: disabled
[    1.320082] initcall 0xffffffff81a35ace: pnpacpi_init+0x0/0x95() returned 0.
[    1.328083] initcall 0xffffffff81a35ace ran for 3 msecs: pnpacpi_init+0x0/0x95()
[    1.336083] Calling initcall 0xffffffff81a36ae7: misc_init+0x0/0x87()
[    1.340083] initcall 0xffffffff81a36ae7: misc_init+0x0/0x87() returned 0.
[    1.348084] initcall 0xffffffff81a36ae7 ran for 0 msecs: misc_init+0x0/0x87()
[    1.356084] Calling initcall 0xffffffff81a3feba: tifm_init+0x0/0x81()
[    1.364085] initcall 0xffffffff81a3feba: tifm_init+0x0/0x81() returned 0.
[    1.368085] initcall 0xffffffff81a3feba ran for 3 msecs: tifm_init+0x0/0x81()
[    1.372085] Calling initcall 0xffffffff81a44837: init_dvbdev+0x0/0xd9()
[    1.380086] initcall 0xffffffff81a44837: init_dvbdev+0x0/0xd9() returned 0.
[    1.388086] initcall 0xffffffff81a44837 ran for 0 msecs: init_dvbdev+0x0/0xd9()
[    1.392087] Calling initcall 0xffffffff81a44bf0: init_scsi+0x0/0xac()
[    1.396087] SCSI subsystem initialized
[    1.400087] initcall 0xffffffff81a44bf0: init_scsi+0x0/0xac() returned 0.
[    1.408088] initcall 0xffffffff81a44bf0 ran for 3 msecs: init_scsi+0x0/0xac()
[    1.416088] Calling initcall 0xffffffff81a48672: ata_init+0x0/0x3d0()
[    1.420088] libata version 3.00 loaded.
[    1.424089] initcall 0xffffffff81a48672: ata_init+0x0/0x3d0() returned 0.
[    1.432089] initcall 0xffffffff81a48672 ran for 3 msecs: ata_init+0x0/0x3d0()
[    1.440090] Calling initcall 0xffffffff81a49220: usb_init+0x0/0x113()
[    1.448090] usbcore: registered new interface driver usbfs
[    1.452090] usbcore: registered new interface driver hub
[    1.456091] usbcore: registered new device driver usb
[    1.460091] initcall 0xffffffff81a49220: usb_init+0x0/0x113() returned 0.
[    1.464091] initcall 0xffffffff81a49220 ran for 11 msecs: usb_init+0x0/0x113()
[    1.468091] Calling initcall 0xffffffff81a4a5f0: serio_init+0x0/0xa0()
[    1.476092] initcall 0xffffffff81a4a5f0: serio_init+0x0/0xa0() returned 0.
[    1.484092] initcall 0xffffffff81a4a5f0 ran for 0 msecs: serio_init+0x0/0xa0()
[    1.492093] Calling initcall 0xffffffff81a4ab0e: gameport_init+0x0/0x9d()
[    1.496093] initcall 0xffffffff81a4ab0e: gameport_init+0x0/0x9d() returned 0.
[    1.504094] initcall 0xffffffff81a4ab0e ran for 0 msecs: gameport_init+0x0/0x9d()
[    1.512094] Calling initcall 0xffffffff81a4abd0: input_init+0x0/0x132()
[    1.520095] initcall 0xffffffff81a4abd0: input_init+0x0/0x132() returned 0.
[    1.524095] initcall 0xffffffff81a4abd0 ran for 0 msecs: input_init+0x0/0x132()
[    1.528095] Calling initcall 0xffffffff81a4b952: power_supply_class_init+0x0/0x35()
[    1.536096] initcall 0xffffffff81a4b952: power_supply_class_init+0x0/0x35() returned 0.
[    1.544096] initcall 0xffffffff81a4b952 ran for 0 msecs: power_supply_class_init+0x0/0x35()
[    1.552097] Calling initcall 0xffffffff81a4b9c0: hwmon_init+0x0/0x40()
[    1.560097] initcall 0xffffffff81a4b9c0: hwmon_init+0x0/0x40() returned 0.
[    1.568098] initcall 0xffffffff81a4b9c0 ran for 0 msecs: hwmon_init+0x0/0x40()
[    1.572098] Calling initcall 0xffffffff81a4d268: thermal_init+0x0/0x41()
[    1.576098] initcall 0xffffffff81a4d268: thermal_init+0x0/0x41() returned 0.
[    1.584099] initcall 0xffffffff81a4d268 ran for 0 msecs: thermal_init+0x0/0x41()
[    1.592099] Calling initcall 0xffffffff81a4ddb0: mmc_init+0x0/0x80()
[    1.596099] initcall 0xffffffff81a4ddb0: mmc_init+0x0/0x80() returned 0.
[    1.604100] initcall 0xffffffff81a4ddb0 ran for 0 msecs: mmc_init+0x0/0x80()
[    1.612100] Calling initcall 0xffffffff81a4df47: leds_init+0x0/0x39()
[    1.616101] initcall 0xffffffff81a4df47: leds_init+0x0/0x39() returned 0.
[    1.624101] initcall 0xffffffff81a4df47 ran for 0 msecs: leds_init+0x0/0x39()
[    1.632102] Calling initcall 0xffffffff81a4f617: pci_acpi_init+0x0/0xc9()
[    1.640102] initcall 0xffffffff81a4f617: pci_acpi_init+0x0/0xc9() returned 0.
[    1.644102] initcall 0xffffffff81a4f617 ran for 0 msecs: pci_acpi_init+0x0/0xc9()
[    1.648103] Calling initcall 0xffffffff81a4f6e0: pci_legacy_init+0x0/0x120()
[    1.656103] PCI: Probing PCI hardware
[    1.660103] PCI: Probing PCI hardware (bus 00)
[    1.664104] PCI: Transparent bridge - 0000:00:09.0
[    1.668104] initcall 0xffffffff81a4f6e0: pci_legacy_init+0x0/0x120() returned 0.
[    1.676104] initcall 0xffffffff81a4f6e0 ran for 11 msecs: pci_legacy_init+0x0/0x120()
[    1.684105] Calling initcall 0xffffffff81a4fd5b: pcibios_irq_init+0x0/0x535()
[    1.692105] PCI: Using IRQ router default [10de/005e] at 0000:00:00.0
[    1.696106] initcall 0xffffffff81a4fd5b: pcibios_irq_init+0x0/0x535() returned 0.
[    1.704106] initcall 0xffffffff81a4fd5b ran for 3 msecs: pcibios_irq_init+0x0/0x535()
[    1.712107] Calling initcall 0xffffffff81a50290: pcibios_init+0x0/0x72()
[    1.720107] initcall 0xffffffff81a50290: pcibios_init+0x0/0x72() returned 0.
[    1.728108] initcall 0xffffffff81a50290 ran for 0 msecs: pcibios_init+0x0/0x72()
[    1.732108] Calling initcall 0xffffffff81a50e00: proto_init+0x0/0x33()
[    1.736108] initcall 0xffffffff81a50e00: proto_init+0x0/0x33() returned 0.
[    1.744109] initcall 0xffffffff81a50e00 ran for 0 msecs: proto_init+0x0/0x33()
[    1.752109] Calling initcall 0xffffffff81a5128e: net_dev_init+0x0/0x157()
[    1.756109] initcall 0xffffffff81a5128e: net_dev_init+0x0/0x157() returned 0.
[    1.764110] initcall 0xffffffff81a5128e ran for 0 msecs: net_dev_init+0x0/0x157()
[    1.772110] Calling initcall 0xffffffff81a51495: neigh_init+0x0/0x76()
[    1.780111] initcall 0xffffffff81a51495: neigh_init+0x0/0x76() returned 0.
[    1.784111] initcall 0xffffffff81a51495 ran for 0 msecs: neigh_init+0x0/0x76()
[    1.788111] Calling initcall 0xffffffff81a51d26: genl_init+0x0/0xea()
[    1.812113] initcall 0xffffffff81a51d26: genl_init+0x0/0xea() returned 0.
[    1.816113] initcall 0xffffffff81a51d26 ran for 15 msecs: genl_init+0x0/0xea()
[    1.820113] Calling initcall 0xffffffff81a56d3a: wanrouter_init+0x0/0x5d()
[    1.828114] Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Technologies Inc.
[    1.832114] initcall 0xffffffff81a56d3a: wanrouter_init+0x0/0x5d() returned 0.
[    1.836114] initcall 0xffffffff81a56d3a ran for 3 msecs: wanrouter_init+0x0/0x5d()
[    1.840115] Calling initcall 0xffffffff81a57700: irda_init+0x0/0xbe()
[    1.848115] irda_init()
[    1.852115] NET: Registered protocol family 23
[    1.856116] initcall 0xffffffff81a57700: irda_init+0x0/0xbe() returned 0.
[    1.860116] initcall 0xffffffff81a57700 ran for 7 msecs: irda_init+0x0/0xbe()
[    1.864116] Calling initcall 0xffffffff81a57d50: bt_init+0x0/0x6c()
[    1.872117] Bluetooth: Core ver 2.11
[    1.876117] NET: Registered protocol family 31
[    1.880117] Bluetooth: HCI device and connection manager initialized
[    1.884117] Bluetooth: HCI socket layer initialized
[    1.888118] initcall 0xffffffff81a57d50: bt_init+0x0/0x6c() returned 0.
[    1.892118] initcall 0xffffffff81a57d50 ran for 15 msecs: bt_init+0x0/0x6c()
[    1.896118] Calling initcall 0xffffffff81a58630: atm_init+0x0/0xc6()
[    1.904119] NET: Registered protocol family 8
[    1.908119] NET: Registered protocol family 20
[    1.912119] initcall 0xffffffff81a58630: atm_init+0x0/0xc6() returned 0.
[    1.916119] initcall 0xffffffff81a58630 ran for 7 msecs: atm_init+0x0/0xc6()
[    1.920120] Calling initcall 0xffffffff81a597a3: wireless_nlevent_init+0x0/0x36()
[    1.928120] initcall 0xffffffff81a597a3: wireless_nlevent_init+0x0/0x36() returned 0.
[    1.936121] initcall 0xffffffff81a597a3 ran for 0 msecs: wireless_nlevent_init+0x0/0x36()
[    1.944121] Calling initcall 0xffffffff80983d60: cfg80211_init+0x0/0x60()
[    1.952122] initcall 0xffffffff80983d60: cfg80211_init+0x0/0x60() returned 0.
[    1.960122] initcall 0xffffffff80983d60 ran for 0 msecs: cfg80211_init+0x0/0x60()
[    1.968123] Calling initcall 0xffffffff81a597d9: ieee80211_init+0x0/0x2c()
[    1.972123] initcall 0xffffffff81a597d9: ieee80211_init+0x0/0x2c() returned 0.
[    1.980123] initcall 0xffffffff81a597d9 ran for 0 msecs: ieee80211_init+0x0/0x2c()
[    1.988124] Calling initcall 0xffffffff81a5991e: sysctl_init+0x0/0x35()
[    1.996124] initcall 0xffffffff81a5991e: sysctl_init+0x0/0x35() returned 0.
[    2.000125] initcall 0xffffffff81a5991e ran for 0 msecs: sysctl_init+0x0/0x35()
[    2.004125] Calling initcall 0xffffffff81a1e327: pci_iommu_init+0x0/0x12()
[    2.012125] initcall 0xffffffff81a1e327: pci_iommu_init+0x0/0x12() returned 0.
[    2.020126] initcall 0xffffffff81a1e327 ran for 0 msecs: pci_iommu_init+0x0/0x12()
[    2.028126] Calling initcall 0xffffffff81a24e0f: hpet_late_init+0x0/0x61()
[    2.032127] initcall 0xffffffff81a24e0f: hpet_late_init+0x0/0x61() returned -19.
[    2.040127] initcall 0xffffffff81a24e0f ran for 0 msecs: hpet_late_init+0x0/0x61()
[    2.044127] Calling initcall 0xffffffff81a2790e: clocksource_done_booting+0x0/0x17()
[    2.052128] initcall 0xffffffff81a2790e: clocksource_done_booting+0x0/0x17() returned 0.
[    2.060128] initcall 0xffffffff81a2790e ran for 0 msecs: clocksource_done_booting+0x0/0x17()
[    2.068129] Calling initcall 0xffffffff81a28c20: ftrace_init_debugfs+0x0/0x81()
[    2.076129] initcall 0xffffffff81a28c20: ftrace_init_debugfs+0x0/0x81() returned 0.
[    2.084130] initcall 0xffffffff81a28c20 ran for 0 msecs: ftrace_init_debugfs+0x0/0x81()
[    2.092130] Calling initcall 0xffffffff81a28dbe: tracer_alloc_buffers+0x0/0x681()
[    2.100131] tracer: 898 pages allocated for 65536<6> entries of 56 bytes
[    2.108131]    actual entries 65554
[    2.112132] initcall 0xffffffff81a28dbe: tracer_alloc_buffers+0x0/0x681() returned 0.
[    2.120132] initcall 0xffffffff81a28dbe ran for 11 msecs: tracer_alloc_buffers+0x0/0x681()
[    2.128133] Calling initcall 0xffffffff81a2ba92: init_pipe_fs+0x0/0x56()
[    2.136133] initcall 0xffffffff81a2ba92: init_pipe_fs+0x0/0x56() returned 0.
[    2.140133] initcall 0xffffffff81a2ba92 ran for 3 msecs: init_pipe_fs+0x0/0x56()
[    2.144134] Calling initcall 0xffffffff81a2c42f: eventpoll_init+0x0/0x8a()
[    2.152134] initcall 0xffffffff81a2c42f: eventpoll_init+0x0/0x8a() returned 0.
[    2.160135] initcall 0xffffffff81a2c42f ran for 0 msecs: eventpoll_init+0x0/0x8a()
[    2.168135] Calling initcall 0xffffffff81a2c4b9: anon_inode_init+0x0/0x131()
[    2.172135] initcall 0xffffffff81a2c4b9: anon_inode_init+0x0/0x131() returned 0.
[    2.180136] initcall 0xffffffff81a2c4b9 ran for 0 msecs: anon_inode_init+0x0/0x131()
[    2.184136] Calling initcall 0xffffffff81a3579f: acpi_event_init+0x0/0x57()
[    2.192137] initcall 0xffffffff81a3579f: acpi_event_init+0x0/0x57() returned 0.
[    2.200137] initcall 0xffffffff81a3579f ran for 0 msecs: acpi_event_init+0x0/0x57()
[    2.208138] Calling initcall 0xffffffff81a359cd: pnp_system_init+0x0/0x23()
[    2.212138] initcall 0xffffffff81a359cd: pnp_system_init+0x0/0x23() returned 0.
[    2.220138] initcall 0xffffffff81a359cd ran for 0 msecs: pnp_system_init+0x0/0x23()
[    2.224139] Calling initcall 0xffffffff81a36470: chr_dev_init+0x0/0xcc()
[    2.232139] initcall 0xffffffff81a36470: chr_dev_init+0x0/0xcc() returned 0.
[    2.240140] initcall 0xffffffff81a36470 ran for 0 msecs: chr_dev_init+0x0/0xcc()
[    2.248140] Calling initcall 0xffffffff81a3d5c7: firmware_class_init+0x0/0x81()
[    2.252140] initcall 0xffffffff81a3d5c7: firmware_class_init+0x0/0x81() returned 0.
[    2.260141] initcall 0xffffffff81a3d5c7 ran for 0 msecs: firmware_class_init+0x0/0x81()
[    2.264141] Calling initcall 0xffffffff81a40fe4: loopback_init+0x0/0x17()
[    2.272142] initcall 0xffffffff81a40fe4: loopback_init+0x0/0x17() returned 0.
[    2.280142] initcall 0xffffffff81a40fe4 ran for 0 msecs: loopback_init+0x0/0x17()
[    2.288143] Calling initcall 0xffffffff81a4ed7a: init_acpi_pm_clocksource+0x0/0xe6()
[    2.296143] initcall 0xffffffff81a4ed7a: init_acpi_pm_clocksource+0x0/0xe6() returned -19.
[    2.304144] initcall 0xffffffff81a4ed7a ran for 0 msecs: init_acpi_pm_clocksource+0x0/0xe6()
[    2.312144] Calling initcall 0xffffffff81a4eeb4: ssb_modinit+0x0/0x57()
[    2.320145] initcall 0xffffffff81a4eeb4: ssb_modinit+0x0/0x57() returned 0.
[    2.324145] initcall 0xffffffff81a4eeb4 ran for 0 msecs: ssb_modinit+0x0/0x57()
[    2.328145] Calling initcall 0xffffffff81a4ef90: pcibios_assign_resources+0x0/0x8f()
[    2.336146] PCI: Bridge: 0000:00:09.0
[    2.340146]   IO window: c000-cfff
[    2.344146]   MEM window: 0xda000000-0xda0fffff
[    2.348146]   PREFETCH window: disabled.
[    2.352147] PCI: Bridge: 0000:00:0b.0
[    2.356147]   IO window: disabled.
[    2.360147]   MEM window: disabled.
[    2.364147]   PREFETCH window: disabled.
[    2.368148] PCI: Bridge: 0000:00:0c.0
[    2.372148]   IO window: disabled.
[    2.372148]   MEM window: disabled.
[    2.376148]   PREFETCH window: disabled.
[    2.380148] PCI: Bridge: 0000:00:0d.0
[    2.384149]   IO window: disabled.
[    2.388149]   MEM window: disabled.
[    2.392149]   PREFETCH window: disabled.
[    2.396149] PCI: Bridge: 0000:00:0e.0
[    2.400150]   IO window: b000-bfff
[    2.404150]   MEM window: 0xd8000000-0xd9ffffff
[    2.408150]   PREFETCH window: 0x00000000d0000000-0x00000000d7ffffff
[    2.412150] PCI: Setting latency timer of device 0000:00:09.0 to 64
[    2.416151] PCI: Setting latency timer of device 0000:00:0b.0 to 64
[    2.420151] PCI: Setting latency timer of device 0000:00:0c.0 to 64
[    2.424151] PCI: Setting latency timer of device 0000:00:0d.0 to 64
[    2.428151] PCI: Setting latency timer of device 0000:00:0e.0 to 64
[    2.432152] initcall 0xffffffff81a4ef90: pcibios_assign_resources+0x0/0x8f() returned 0.
[    2.440152] initcall 0xffffffff81a4ef90 ran for 91 msecs: pcibios_assign_resources+0x0/0x8f()
[    2.444152] Calling initcall 0xffffffff81a52b10: inet_init+0x0/0x388()
[    2.452153] NET: Registered protocol family 2
[    2.500156] IP route cache hash table entries: 32768 (order: 6, 262144 bytes)
[    2.504156] TCP established hash table entries: 131072 (order: 9, 2097152 bytes)
[    2.512157] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    2.516157] TCP: Hash tables configured (established 131072 bind 65536)
[    2.520157] TCP reno registered
[    2.536158] initcall 0xffffffff81a52b10: inet_init+0x0/0x388() returned 0.
[    2.540158] initcall 0xffffffff81a52b10 ran for 80 msecs: inet_init+0x0/0x388()
[    2.544159] Calling initcall 0xffffffff81a1af34: default_rootfs+0x0/0x7a()
[    2.552159] Failed to create a rootfs
[    2.556159] initcall 0xffffffff81a1af34: default_rootfs+0x0/0x7a() returned -14.
[    2.564160] initcall 0xffffffff81a1af34 ran for 3 msecs: default_rootfs+0x0/0x7a()
[    2.568160] initcall at 0xffffffff81a1af34: default_rootfs+0x0/0x7a(): returned with error code -14
[    2.580161] Calling initcall 0xffffffff81a1b2b6: vmx_init+0x0/0x136()
[    2.584161] kvm: no hardware support
[    2.588161] initcall 0xffffffff81a1b2b6: vmx_init+0x0/0x136() returned -95.
[    2.596162] initcall 0xffffffff81a1b2b6 ran for 3 msecs: vmx_init+0x0/0x136()
[    2.604162] initcall at 0xffffffff81a1b2b6: vmx_init+0x0/0x136(): returned with error code -95
[    2.612163] Calling initcall 0xffffffff81a1b3ec: svm_init+0x0/0x1e()
[    2.620163] has_svm: svm not available
[    2.624164] kvm: no hardware support
[    2.624164] initcall 0xffffffff81a1b3ec: svm_init+0x0/0x1e() returned -95.
[    2.632164] initcall 0xffffffff81a1b3ec ran for 3 msecs: svm_init+0x0/0x1e()
[    2.640165] initcall at 0xffffffff81a1b3ec: svm_init+0x0/0x1e(): returned with error code -95
[    2.648165] Calling initcall 0xffffffff81a1c670: i8259A_init_sysfs+0x0/0x29()
[    2.656166] initcall 0xffffffff81a1c670: i8259A_init_sysfs+0x0/0x29() returned 0.
[    2.664166] initcall 0xffffffff81a1c670 ran for 0 msecs: i8259A_init_sysfs+0x0/0x29()
[    2.672167] Calling initcall 0xffffffff81a1cc9c: vsyscall_init+0x0/0x3a()
[    2.676167] initcall 0xffffffff81a1cc9c: vsyscall_init+0x0/0x3a() returned 0.
[    2.684167] initcall 0xffffffff81a1cc9c ran for 0 msecs: vsyscall_init+0x0/0x3a()
[    2.688168] Calling initcall 0xffffffff81a1ce0c: sbf_init+0x0/0xe4()
[    2.696168] initcall 0xffffffff81a1ce0c: sbf_init+0x0/0xe4() returned 0.
[    2.700168] initcall 0xffffffff81a1ce0c ran for 0 msecs: sbf_init+0x0/0xe4()
[    2.704169] Calling initcall 0xffffffff81a1e450: i8237A_init_sysfs+0x0/0x29()
[    2.712169] initcall 0xffffffff81a1e450: i8237A_init_sysfs+0x0/0x29() returned 0.
[    2.720170] initcall 0xffffffff81a1e450 ran for 0 msecs: i8237A_init_sysfs+0x0/0x29()
[    2.728170] Calling initcall 0xffffffff809e83aa: cache_sysfs_init+0x0/0x6e()
[    2.736171] initcall 0xffffffff809e83aa: cache_sysfs_init+0x0/0x6e() returned 0.
[    2.740171] initcall 0xffffffff809e83aa ran for 0 msecs: cache_sysfs_init+0x0/0x6e()
[    2.744171] Calling initcall 0xffffffff81a1edc8: mce_init_device+0x0/0xa1()
[    2.748171] initcall 0xffffffff81a1edc8: mce_init_device+0x0/0xa1() returned 0.
[    2.756172] initcall 0xffffffff81a1edc8 ran for 0 msecs: mce_init_device+0x0/0xa1()
[    2.764172] Calling initcall 0xffffffff81a1ecd5: periodic_mcheck_init+0x0/0x4b()
[    2.772173] initcall 0xffffffff81a1ecd5: periodic_mcheck_init+0x0/0x4b() returned 0.
[    2.780173] initcall 0xffffffff81a1ecd5 ran for 0 msecs: periodic_mcheck_init+0x0/0x4b()
[    2.788174] Calling initcall 0xffffffff81a1ee69: thermal_throttle_init_device+0x0/0x89()
[    2.796174] initcall 0xffffffff81a1ee69: thermal_throttle_init_device+0x0/0x89() returned 0.
[    2.804175] initcall 0xffffffff81a1ee69 ran for 0 msecs: thermal_throttle_init_device+0x0/0x89()
[    2.812175] Calling initcall 0xffffffff81a1eef2: threshold_init_device+0x0/0x6e()
[    2.820176] initcall 0xffffffff81a1eef2: threshold_init_device+0x0/0x6e() returned 0.
[    2.828176] initcall 0xffffffff81a1eef2 ran for 0 msecs: threshold_init_device+0x0/0x6e()
[    2.836177] Calling initcall 0xffffffff81a2051e: msr_init+0x0/0x118()
[    2.844177] initcall 0xffffffff81a2051e: msr_init+0x0/0x118() returned 0.
[    2.848178] initcall 0xffffffff81a2051e ran for 0 msecs: msr_init+0x0/0x118()
[    2.852178] Calling initcall 0xffffffff81a20636: microcode_init+0x0/0xd0()
[    2.860178] microcode: CPU0 not a capable Intel processor
[    2.864179] IA-32 Microcode Update Driver: v1.14a <tigran@aivazian.fsnet.co.uk>
[    2.868179] initcall 0xffffffff81a20636: microcode_init+0x0/0xd0() returned 0.
[    2.876179] initcall 0xffffffff81a20636 ran for 7 msecs: microcode_init+0x0/0xd0()
[    2.884180] Calling initcall 0xffffffff81a21e51: init_lapic_sysfs+0x0/0x34()
[    2.892180] initcall 0xffffffff81a21e51: init_lapic_sysfs+0x0/0x34() returned 0.
[    2.896181] initcall 0xffffffff81a21e51 ran for 0 msecs: init_lapic_sysfs+0x0/0x34()
[    2.900181] Calling initcall 0xffffffff81a22bdd: ioapic_init_sysfs+0x0/0xd0()
[    2.904181] initcall 0xffffffff81a22bdd: ioapic_init_sysfs+0x0/0xd0() returned 0.
[    2.912182] initcall 0xffffffff81a22bdd ran for 0 msecs: ioapic_init_sysfs+0x0/0xd0()
[    2.920182] Calling initcall 0xffffffff81a24fdc: audit_classes_init+0x0/0xb4()
[    2.928183] initcall 0xffffffff81a24fdc: audit_classes_init+0x0/0xb4() returned 0.
[    2.936183] initcall 0xffffffff81a24fdc ran for 0 msecs: audit_classes_init+0x0/0xb4()
[    2.944184] Calling initcall 0xffffffff81a25668: aes_init+0x0/0x17()
[    2.948184] initcall 0xffffffff81a25668: aes_init+0x0/0x17() returned 0.
[    2.956184] initcall 0xffffffff81a25668 ran for 0 msecs: aes_init+0x0/0x17()
[    2.964185] Calling initcall 0xffffffff81a2567f: init+0x0/0x17()
[    2.968185] initcall 0xffffffff81a2567f: init+0x0/0x17() returned 0.
[    2.976186] initcall 0xffffffff81a2567f ran for 0 msecs: init+0x0/0x17()
[    2.984186] Calling initcall 0xffffffff81a25696: init+0x0/0x1a()
[    2.988186] initcall 0xffffffff81a25696: init+0x0/0x1a() returned 0.
[    2.996187] initcall 0xffffffff81a25696 ran for 0 msecs: init+0x0/0x1a()
[    3.000187] Calling initcall 0xffffffff81a256cc: init_vdso_vars+0x0/0x224()
[    3.004187] initcall 0xffffffff81a256cc: init_vdso_vars+0x0/0x224() returned 0.
[    3.012188] initcall 0xffffffff81a256cc ran for 0 msecs: init_vdso_vars+0x0/0x224()
[    3.020188] Calling initcall 0xffffffff81a2590f: ia32_binfmt_init+0x0/0x19()
[    3.028189] initcall 0xffffffff81a2590f: ia32_binfmt_init+0x0/0x19() returned 0.
[    3.036189] initcall 0xffffffff81a2590f ran for 0 msecs: ia32_binfmt_init+0x0/0x19()
[    3.040190] Calling initcall 0xffffffff81a25928: sysenter_setup+0x0/0x318()
[    3.044190] initcall 0xffffffff81a25928: sysenter_setup+0x0/0x318() returned 0.
[    3.052190] initcall 0xffffffff81a25928 ran for 0 msecs: sysenter_setup+0x0/0x318()
[    3.060191] Calling initcall 0xffffffff81a267cd: create_proc_profile+0x0/0x29a()
[    3.068191] initcall 0xffffffff81a267cd: create_proc_profile+0x0/0x29a() returned 0.
[    3.076192] initcall 0xffffffff81a267cd ran for 0 msecs: create_proc_profile+0x0/0x29a()
[    3.084192] Calling initcall 0xffffffff81a26b55: ioresources_init+0x0/0x47()
[    3.092193] initcall 0xffffffff81a26b55: ioresources_init+0x0/0x47() returned 0.
[    3.096193] initcall 0xffffffff81a26b55 ran for 0 msecs: ioresources_init+0x0/0x47()
[    3.100193] Calling initcall 0xffffffff81a26d55: uid_cache_init+0x0/0x83()
[    3.108194] initcall 0xffffffff81a26d55: uid_cache_init+0x0/0x83() returned 0.
[    3.116194] initcall 0xffffffff81a26d55 ran for 0 msecs: uid_cache_init+0x0/0x83()
[    3.124195] Calling initcall 0xffffffff81a273d1: init_posix_timers+0x0/0xbb()
[    3.132195] initcall 0xffffffff81a273d1: init_posix_timers+0x0/0xbb() returned 0.
[    3.140196] initcall 0xffffffff81a273d1 ran for 0 msecs: init_posix_timers+0x0/0xbb()
[    3.148196] Calling initcall 0xffffffff81a2748c: init_kthread+0x0/0x20()
[    3.152197] initcall 0xffffffff81a2748c: init_kthread+0x0/0x20() returned 0.
[    3.160197] initcall 0xffffffff81a2748c ran for 0 msecs: init_kthread+0x0/0x20()
[    3.168198] Calling initcall 0xffffffff81a274ac: init_posix_cpu_timers+0x0/0xd9()
[    3.176198] initcall 0xffffffff81a274ac: init_posix_cpu_timers+0x0/0xd9() returned 0.
[    3.184199] initcall 0xffffffff81a274ac ran for 0 msecs: init_posix_cpu_timers+0x0/0xd9()
[    3.192199] Calling initcall 0xffffffff81a27624: nsproxy_cache_init+0x0/0x3c()
[    3.200200] initcall 0xffffffff81a27624: nsproxy_cache_init+0x0/0x3c() returned 0.
[    3.204200] initcall 0xffffffff81a27624 ran for 0 msecs: nsproxy_cache_init+0x0/0x3c()
[    3.208200] Calling initcall 0xffffffff81a277c0: timekeeping_init_device+0x0/0x29()
[    3.212200] initcall 0xffffffff81a277c0: timekeeping_init_device+0x0/0x29() returned 0.
[    3.220201] initcall 0xffffffff81a277c0 ran for 0 msecs: timekeeping_init_device+0x0/0x29()
[    3.224201] Calling initcall 0xffffffff81a27925: init_clocksource_sysfs+0x0/0x57()
[    3.228201] initcall 0xffffffff81a27925: init_clocksource_sysfs+0x0/0x57() returned 0.
[    3.236202] initcall 0xffffffff81a27925 ran for 0 msecs: init_clocksource_sysfs+0x0/0x57()
[    3.240202] Calling initcall 0xffffffff81a27a46: init_timer_list_procfs+0x0/0x34()
[    3.244202] initcall 0xffffffff81a27a46: init_timer_list_procfs+0x0/0x34() returned 0.
[    3.252203] initcall 0xffffffff81a27a46 ran for 0 msecs: init_timer_list_procfs+0x0/0x34()
[    3.256203] Calling initcall 0xffffffff81a27a91: futex_init+0x0/0x10a()
[    3.264204] initcall 0xffffffff81a27a91: futex_init+0x0/0x10a() returned 0.
[    3.272204] initcall 0xffffffff81a27a91 ran for 0 msecs: futex_init+0x0/0x10a()
[    3.280205] Calling initcall 0xffffffff81a27b9b: proc_dma_init+0x0/0x2a()
[    3.284205] initcall 0xffffffff81a27b9b: proc_dma_init+0x0/0x2a() returned 0.
[    3.292205] initcall 0xffffffff81a27b9b ran for 0 msecs: proc_dma_init+0x0/0x2a()
[    3.300206] Calling initcall 0xffffffff81a27c0b: kallsyms_init+0x0/0x2d()
[    3.308206] initcall 0xffffffff81a27c0b: kallsyms_init+0x0/0x2d() returned 0.
[    3.316207] initcall 0xffffffff81a27c0b ran for 0 msecs: kallsyms_init+0x0/0x2d()
[    3.320207] Calling initcall 0xffffffff81a27cc4: crash_save_vmcoreinfo_init+0x0/0x41a()
[    3.324207] initcall 0xffffffff81a27cc4: crash_save_vmcoreinfo_init+0x0/0x41a() returned 0.
[    3.336208] initcall 0xffffffff81a27cc4 ran for 0 msecs: crash_save_vmcoreinfo_init+0x0/0x41a()
[    3.344209] Calling initcall 0xffffffff81a27c80: crash_notes_memory_init+0x0/0x44()
[    3.352209] initcall 0xffffffff81a27c80: crash_notes_memory_init+0x0/0x44() returned 0.
[    3.360210] initcall 0xffffffff81a27c80 ran for 0 msecs: crash_notes_memory_init+0x0/0x44()
[    3.368210] Calling initcall 0xffffffff81a287e3: ikconfig_init+0x0/0x41()
[    3.372210] initcall 0xffffffff81a287e3: ikconfig_init+0x0/0x41() returned 0.
[    3.380211] initcall 0xffffffff81a287e3 ran for 0 msecs: ikconfig_init+0x0/0x41()
[    3.384211] Calling initcall 0xffffffff81a288ab: audit_init+0x0/0x125()
[    3.392212] audit: initializing netlink socket (disabled)
[    3.396212] type=2000 audit(1208427056.396:1): initialized
[    3.400212] audit: cannot initialize inotify handle
[    3.404212] initcall 0xffffffff81a288ab: audit_init+0x0/0x125() returned 0.
[    3.408213] initcall 0xffffffff81a288ab ran for 11 msecs: audit_init+0x0/0x125()
[    3.412213] Calling initcall 0xffffffff81a28a73: init_irq+0x0/0x20()
[    3.420213] initcall 0xffffffff81a28a73: init_irq+0x0/0x20() returned 0.
[    3.428214] initcall 0xffffffff81a28a73 ran for 0 msecs: init_irq+0x0/0x20()
[    3.432214] Calling initcall 0xffffffff81a28beb: relay_init+0x0/0x19()
[    3.440215] initcall 0xffffffff81a28beb: relay_init+0x0/0x19() returned 0.
[    3.448215] initcall 0xffffffff81a28beb ran for 0 msecs: relay_init+0x0/0x19()
[    3.456216] Calling initcall 0xffffffff81a28c04: utsname_sysctl_init+0x0/0x1c()
[    3.460216] initcall 0xffffffff81a28c04: utsname_sysctl_init+0x0/0x1c() returned 0.
[    3.468216] initcall 0xffffffff81a28c04 ran for 0 msecs: utsname_sysctl_init+0x0/0x1c()
[    3.472217] Calling initcall 0xffffffff81a2943f: init_sched_switch_trace+0x0/0x12()
[    3.480217] initcall 0xffffffff81a2943f: init_sched_switch_trace+0x0/0x12() returned 0.
[    3.488218] initcall 0xffffffff81a2943f ran for 0 msecs: init_sched_switch_trace+0x0/0x12()
[    3.492218] Calling initcall 0xffffffff81a29451: init_function_trace+0x0/0x12()
[    3.500218] initcall 0xffffffff81a29451: init_function_trace+0x0/0x12() returned 0.
[    3.508219] initcall 0xffffffff81a29451 ran for 0 msecs: init_function_trace+0x0/0x12()
[    3.516219] Calling initcall 0xffffffff81a29463: init_irqsoff_tracer+0x0/0x14()
[    3.524220] initcall 0xffffffff81a29463: init_irqsoff_tracer+0x0/0x14() returned 0.
[    3.532220] initcall 0xffffffff81a29463 ran for 0 msecs: init_irqsoff_tracer+0x0/0x14()
[    3.540221] Calling initcall 0xffffffff81a29477: init_wakeup_tracer+0x0/0x19()
[    3.548221] initcall 0xffffffff81a29477: init_wakeup_tracer+0x0/0x19() returned 0.
[    3.556222] initcall 0xffffffff81a29477 ran for 0 msecs: init_wakeup_tracer+0x0/0x19()
[    3.564222] Calling initcall 0xffffffff81a2ab40: init_per_zone_pages_min+0x0/0x5b()
[    3.572223] initcall 0xffffffff81a2ab40: init_per_zone_pages_min+0x0/0x5b() returned 0.
[    3.580223] initcall 0xffffffff81a2ab40 ran for 0 msecs: init_per_zone_pages_min+0x0/0x5b()
[    3.588224] Calling initcall 0xffffffff81a2af37: pdflush_init+0x0/0x17()
[    3.592224] initcall 0xffffffff81a2af37: pdflush_init+0x0/0x17() returned 0.
[    3.600225] initcall 0xffffffff81a2af37 ran for 0 msecs: pdflush_init+0x0/0x17()
[    3.608225] Calling initcall 0xffffffff81a2af96: kswapd_init+0x0/0x70()
[    3.616226] initcall 0xffffffff81a2af96: kswapd_init+0x0/0x70() returned 0.
[    3.620226] initcall 0xffffffff81a2af96 ran for 0 msecs: kswapd_init+0x0/0x70()
[    3.624226] Calling initcall 0xffffffff81a2b006: setup_vmstat+0x0/0x5b()
[    3.632227] initcall 0xffffffff81a2b006: setup_vmstat+0x0/0x5b() returned 0.
[    3.640227] initcall 0xffffffff81a2b006 ran for 0 msecs: setup_vmstat+0x0/0x5b()
[    3.648228] Calling initcall 0xffffffff81a2b404: init_tmpfs+0x0/0x2e()
[    3.652228] initcall 0xffffffff81a2b404: init_tmpfs+0x0/0x2e() returned 0.
[    3.660228] initcall 0xffffffff81a2b404 ran for 0 msecs: init_tmpfs+0x0/0x2e()
[    3.668229] Calling initcall 0xffffffff81a2b44c: cpucache_init+0x0/0x4a()
[    3.672229] initcall 0xffffffff81a2b44c: cpucache_init+0x0/0x4a() returned 0.
[    3.680230] initcall 0xffffffff81a2b44c ran for 0 msecs: cpucache_init+0x0/0x4a()
[    3.684230] Calling initcall 0xffffffff81a2bae8: fasync_init+0x0/0x2f()
[    3.692230] initcall 0xffffffff81a2bae8: fasync_init+0x0/0x2f() returned 0.
[    3.700231] initcall 0xffffffff81a2bae8 ran for 0 msecs: fasync_init+0x0/0x2f()
[    3.704231] Calling initcall 0xffffffff81a2c1b1: aio_setup+0x0/0x73()
[    3.712232] initcall 0xffffffff81a2c1b1: aio_setup+0x0/0x73() returned 0.
[    3.720232] initcall 0xffffffff81a2c1b1 ran for 0 msecs: aio_setup+0x0/0x73()
[    3.728233] Calling initcall 0xffffffff81a2c5ea: init_sys32_ioctl+0x0/0x8d()
[    3.732233] initcall 0xffffffff81a2c5ea: init_sys32_ioctl+0x0/0x8d() returned 0.
[    3.740233] initcall 0xffffffff81a2c5ea ran for 0 msecs: init_sys32_ioctl+0x0/0x8d()
[    3.748234] Calling initcall 0xffffffff81a2c6bc: init_mbcache+0x0/0x19()
[    3.756234] initcall 0xffffffff81a2c6bc: init_mbcache+0x0/0x19() returned 0.
[    3.764235] initcall 0xffffffff81a2c6bc ran for 0 msecs: init_mbcache+0x0/0x19()
[    3.768235] Calling initcall 0xffffffff81a2c6d5: dquot_init+0x0/0xef()
[    3.776236] VFS: Disk quotas dquot_6.5.1
[    3.780236] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    3.784236] initcall 0xffffffff81a2c6d5: dquot_init+0x0/0xef() returned 0.
[    3.788236] initcall 0xffffffff81a2c6d5 ran for 7 msecs: dquot_init+0x0/0xef()
[    3.792237] Calling initcall 0xffffffff81a2c7c4: init_v1_quota_format+0x0/0x17()
[    3.800237] initcall 0xffffffff81a2c7c4: init_v1_quota_format+0x0/0x17() returned 0.
[    3.808238] initcall 0xffffffff81a2c7c4 ran for 0 msecs: init_v1_quota_format+0x0/0x17()
[    3.816238] Calling initcall 0xffffffff81a2c7db: init_v2_quota_format+0x0/0x17()
[    3.824239] initcall 0xffffffff81a2c7db: init_v2_quota_format+0x0/0x17() returned 0.
[    3.832239] initcall 0xffffffff81a2c7db ran for 0 msecs: init_v2_quota_format+0x0/0x17()
[    3.840240] Calling initcall 0xffffffff81a2c7f2: dnotify_init+0x0/0x3e()
[    3.848240] initcall 0xffffffff81a2c7f2: dnotify_init+0x0/0x3e() returned 0.
[    3.852240] initcall 0xffffffff81a2c7f2 ran for 0 msecs: dnotify_init+0x0/0x3e()
[    3.856241] Calling initcall 0xffffffff81a2cd18: vmcore_init+0x0/0xa34()
[    3.864241] initcall 0xffffffff81a2cd18: vmcore_init+0x0/0xa34() returned 0.
[    3.872242] initcall 0xffffffff81a2cd18 ran for 0 msecs: vmcore_init+0x0/0xa34()
[    3.876242] Calling initcall 0xffffffff81a2d838: configfs_init+0x0/0xe5()
[    3.880242] initcall 0xffffffff81a2d838: configfs_init+0x0/0xe5() returned 0.
[    3.888243] initcall 0xffffffff81a2d838 ran for 0 msecs: configfs_init+0x0/0xe5()
[    3.896243] Calling initcall 0xffffffff81a2d91d: init_devpts_fs+0x0/0x53()
[    3.904244] initcall 0xffffffff81a2d91d: init_devpts_fs+0x0/0x53() returned 0.
[    3.908244] initcall 0xffffffff81a2d91d ran for 0 msecs: init_devpts_fs+0x0/0x53()
[    3.912244] Calling initcall 0xffffffff81a2da40: init_dlm+0x0/0x9e()
[    3.920245] DLM (built Apr 17 2008 10:53:43) installed
[    3.924245] initcall 0xffffffff81a2da40: init_dlm+0x0/0x9e() returned 0.
[    3.932245] initcall 0xffffffff81a2da40 ran for 3 msecs: init_dlm+0x0/0x9e()
[    3.940246] Calling initcall 0xffffffff81a2dbde: init_reiserfs_fs+0x0/0x90()
[    3.944246] initcall 0xffffffff81a2dbde: init_reiserfs_fs+0x0/0x90() returned 0.
[    3.952247] initcall 0xffffffff81a2dbde ran for 0 msecs: init_reiserfs_fs+0x0/0x90()
[    3.956247] Calling initcall 0xffffffff81a2dc6e: init_ext3_fs+0x0/0x77()
[    3.964247] initcall 0xffffffff81a2dc6e: init_ext3_fs+0x0/0x77() returned 0.
[    3.972248] initcall 0xffffffff81a2dc6e ran for 0 msecs: init_ext3_fs+0x0/0x77()
[    3.980248] Calling initcall 0xffffffff81a2dd1e: init_ext4_fs+0x0/0x77()
[    3.984249] initcall 0xffffffff81a2dd1e: init_ext4_fs+0x0/0x77() returned 0.
[    3.992249] initcall 0xffffffff81a2dd1e ran for 0 msecs: init_ext4_fs+0x0/0x77()
[    4.000250] Calling initcall 0xffffffff81a2dec0: journal_init+0x0/0xe1()
[    4.008250] initcall 0xffffffff81a2dec0: journal_init+0x0/0xe1() returned 0.
[    4.012250] initcall 0xffffffff81a2dec0 ran for 0 msecs: journal_init+0x0/0xe1()
[    4.016251] Calling initcall 0xffffffff81a2e021: journal_init+0x0/0xb6()
[    4.024251] initcall 0xffffffff81a2e021: journal_init+0x0/0xb6() returned 0.
[    4.032252] initcall 0xffffffff81a2e021 ran for 0 msecs: journal_init+0x0/0xb6()
[    4.040252] Calling initcall 0xffffffff81a2e0d7: init_ext2_fs+0x0/0x67()
[    4.044252] initcall 0xffffffff81a2e0d7: init_ext2_fs+0x0/0x67() returned 0.
[    4.052253] initcall 0xffffffff81a2e0d7 ran for 0 msecs: init_ext2_fs+0x0/0x67()
[    4.060253] Calling initcall 0xffffffff81a2e13e: init_ramfs_fs+0x0/0x17()
[    4.068254] initcall 0xffffffff81a2e13e: init_ramfs_fs+0x0/0x17() returned 0.
[    4.072254] initcall 0xffffffff81a2e13e ran for 0 msecs: init_ramfs_fs+0x0/0x17()
[    4.076254] Calling initcall 0xffffffff81a2e1df: init_fat_fs+0x0/0x59()
[    4.084255] initcall 0xffffffff81a2e1df: init_fat_fs+0x0/0x59() returned 0.
[    4.092255] initcall 0xffffffff81a2e1df ran for 0 msecs: init_fat_fs+0x0/0x59()
[    4.100256] Calling initcall 0xffffffff81a2e238: init_vfat_fs+0x0/0x17()
[    4.104256] initcall 0xffffffff81a2e238: init_vfat_fs+0x0/0x17() returned 0.
[    4.112257] initcall 0xffffffff81a2e238 ran for 0 msecs: init_vfat_fs+0x0/0x17()
[    4.120257] Calling initcall 0xffffffff81a2e24f: init_bfs_fs+0x0/0x71()
[    4.128258] initcall 0xffffffff81a2e24f: init_bfs_fs+0x0/0x71() returned 0.
[    4.132258] initcall 0xffffffff81a2e24f ran for 0 msecs: init_bfs_fs+0x0/0x71()
[    4.136258] Calling initcall 0xffffffff81a2e2c0: init_iso9660_fs+0x0/0x75()
[    4.144259] initcall 0xffffffff81a2e2c0: init_iso9660_fs+0x0/0x75() returned 0.
[    4.152259] initcall 0xffffffff81a2e2c0 ran for 0 msecs: init_iso9660_fs+0x0/0x75()
[    4.160260] Calling initcall 0xffffffff81a2e35d: init_hfsplus_fs+0x0/0x6e()
[    4.164260] initcall 0xffffffff81a2e35d: init_hfsplus_fs+0x0/0x6e() returned 0.
[    4.172260] initcall 0xffffffff81a2e35d ran for 0 msecs: init_hfsplus_fs+0x0/0x6e()
[    4.176261] Calling initcall 0xffffffff81a2e3cb: init_hfs_fs+0x0/0x75()
[    4.184261] initcall 0xffffffff81a2e3cb: init_hfs_fs+0x0/0x75() returned 0.
[    4.192262] initcall 0xffffffff81a2e3cb ran for 0 msecs: init_hfs_fs+0x0/0x75()
[    4.196262] Calling initcall 0xffffffff81a2e440: ecryptfs_init+0x0/0x1b6()
[    4.200262] initcall 0xffffffff81a2e440: ecryptfs_init+0x0/0x1b6() returned 0.
[    4.208263] initcall 0xffffffff81a2e440 ran for 0 msecs: ecryptfs_init+0x0/0x1b6()
[    4.216263] Calling initcall 0xffffffff81a2e5f6: init_nls_cp437+0x0/0x17()
[    4.224264] initcall 0xffffffff81a2e5f6: init_nls_cp437+0x0/0x17() returned 0.
[    4.232264] initcall 0xffffffff81a2e5f6 ran for 0 msecs: init_nls_cp437+0x0/0x17()
[    4.236264] Calling initcall 0xffffffff81a2e60d: init_nls_cp857+0x0/0x17()
[    4.240265] initcall 0xffffffff81a2e60d: init_nls_cp857+0x0/0x17() returned 0.
[    4.248265] initcall 0xffffffff81a2e60d ran for 0 msecs: init_nls_cp857+0x0/0x17()
[    4.256266] Calling initcall 0xffffffff81a2e624: init_nls_cp865+0x0/0x17()
[    4.264266] initcall 0xffffffff81a2e624: init_nls_cp865+0x0/0x17() returned 0.
[    4.268266] initcall 0xffffffff81a2e624 ran for 0 msecs: init_nls_cp865+0x0/0x17()
[    4.272267] Calling initcall 0xffffffff81a2e63b: init_nls_cp869+0x0/0x17()
[    4.280267] initcall 0xffffffff81a2e63b: init_nls_cp869+0x0/0x17() returned 0.
[    4.288268] initcall 0xffffffff81a2e63b ran for 0 msecs: init_nls_cp869+0x0/0x17()
[    4.296268] Calling initcall 0xffffffff81a2e652: init_nls_cp936+0x0/0x17()
[    4.304269] initcall 0xffffffff81a2e652: init_nls_cp936+0x0/0x17() returned 0.
[    4.308269] initcall 0xffffffff81a2e652 ran for 0 msecs: init_nls_cp936+0x0/0x17()
[    4.312269] Calling initcall 0xffffffff81a2e669: init_nls_cp949+0x0/0x17()
[    4.320270] initcall 0xffffffff81a2e669: init_nls_cp949+0x0/0x17() returned 0.
[    4.328270] initcall 0xffffffff81a2e669 ran for 0 msecs: init_nls_cp949+0x0/0x17()
[    4.336271] Calling initcall 0xffffffff81a2e680: init_nls_cp1250+0x0/0x17()
[    4.340271] initcall 0xffffffff81a2e680: init_nls_cp1250+0x0/0x17() returned 0.
[    4.348271] initcall 0xffffffff81a2e680 ran for 0 msecs: init_nls_cp1250+0x0/0x17()
[    4.352272] Calling initcall 0xffffffff81a2e697: init_nls_cp1251+0x0/0x17()
[    4.360272] initcall 0xffffffff81a2e697: init_nls_cp1251+0x0/0x17() returned 0.
[    4.368273] initcall 0xffffffff81a2e697 ran for 0 msecs: init_nls_cp1251+0x0/0x17()
[    4.376273] Calling initcall 0xffffffff81a2e6ae: init_nls_iso8859_7+0x0/0x17()
[    4.384274] initcall 0xffffffff81a2e6ae: init_nls_iso8859_7+0x0/0x17() returned 0.
[    4.388274] initcall 0xffffffff81a2e6ae ran for 0 msecs: init_nls_iso8859_7+0x0/0x17()
[    4.392274] Calling initcall 0xffffffff81a2e6c5: init_nls_iso8859_9+0x0/0x17()
[    4.400275] initcall 0xffffffff81a2e6c5: init_nls_iso8859_9+0x0/0x17() returned 0.
[    4.408275] initcall 0xffffffff81a2e6c5 ran for 0 msecs: init_nls_iso8859_9+0x0/0x17()
[    4.416276] Calling initcall 0xffffffff81a2e6dc: init_nls_iso8859_14+0x0/0x17()
[    4.424276] initcall 0xffffffff81a2e6dc: init_nls_iso8859_14+0x0/0x17() returned 0.
[    4.432277] initcall 0xffffffff81a2e6dc ran for 0 msecs: init_nls_iso8859_14+0x0/0x17()
[    4.440277] Calling initcall 0xffffffff81a2e6f3: init_nls_iso8859_15+0x0/0x17()
[    4.448278] initcall 0xffffffff81a2e6f3: init_nls_iso8859_15+0x0/0x17() returned 0.
[    4.456278] initcall 0xffffffff81a2e6f3 ran for 0 msecs: init_nls_iso8859_15+0x0/0x17()
[    4.464279] Calling initcall 0xffffffff81a2e70a: init_nls_utf8+0x0/0x35()
[    4.468279] initcall 0xffffffff81a2e70a: init_nls_utf8+0x0/0x35() returned 0.
[    4.476279] initcall 0xffffffff81a2e70a ran for 0 msecs: init_nls_utf8+0x0/0x35()
[    4.484280] Calling initcall 0xffffffff81a2e779: init_sysv_fs+0x0/0x60()
[    4.492280] initcall 0xffffffff81a2e779: init_sysv_fs+0x0/0x60() returned 0.
[    4.496281] initcall 0xffffffff81a2e779 ran for 0 msecs: init_sysv_fs+0x0/0x60()
[    4.500281] Calling initcall 0xffffffff81a2e7d9: init_ntfs_fs+0x0/0x1f3()
[    4.508281] NTFS driver 2.1.29 [Flags: R/O].
[    4.512282] initcall 0xffffffff81a2e7d9: init_ntfs_fs+0x0/0x1f3() returned 0.
[    4.520282] initcall 0xffffffff81a2e7d9 ran for 3 msecs: init_ntfs_fs+0x0/0x1f3()
[    4.528283] Calling initcall 0xffffffff81a2e9cc: init_affs_fs+0x0/0x67()
[    4.536283] initcall 0xffffffff81a2e9cc: init_affs_fs+0x0/0x67() returned 0.
[    4.540283] initcall 0xffffffff81a2e9cc ran for 0 msecs: init_affs_fs+0x0/0x67()
[    4.544284] Calling initcall 0xffffffff81a2ea33: init_romfs_fs+0x0/0x67()
[    4.552284] initcall 0xffffffff81a2ea33: init_romfs_fs+0x0/0x67() returned 0.
[    4.560285] initcall 0xffffffff81a2ea33 ran for 0 msecs: init_romfs_fs+0x0/0x67()
[    4.568285] Calling initcall 0xffffffff81a2ea9a: init_qnx4_fs+0x0/0x75()
[    4.572285] QNX4 filesystem 0.2.3 registered.
[    4.576286] initcall 0xffffffff81a2ea9a: init_qnx4_fs+0x0/0x75() returned 0.
[    4.584286] initcall 0xffffffff81a2ea9a ran for 3 msecs: init_qnx4_fs+0x0/0x75()
[    4.592287] Calling initcall 0xffffffff81a2eb0f: init_adfs_fs+0x0/0x67()
[    4.600287] initcall 0xffffffff81a2eb0f: init_adfs_fs+0x0/0x67() returned 0.
[    4.604287] initcall 0xffffffff81a2eb0f ran for 0 msecs: init_adfs_fs+0x0/0x67()
[    4.608288] Calling initcall 0xffffffff81a2eb76: init_udf_fs+0x0/0x6a()
[    4.616288] initcall 0xffffffff81a2eb76: init_udf_fs+0x0/0x6a() returned 0.
[    4.624289] initcall 0xffffffff81a2eb76 ran for 0 msecs: init_udf_fs+0x0/0x6a()
[    4.632289] Calling initcall 0xffffffff81a2ef53: init_xfs_fs+0x0/0x6c()
[    4.636289] SGI XFS with ACLs, security attributes, large block/inode numbers, no debug enabled
[    4.644290] SGI XFS Quota Management subsystem
[    4.648290] initcall 0xffffffff81a2ef53: init_xfs_fs+0x0/0x6c() returned 0.
[    4.652290] initcall 0xffffffff81a2ef53 ran for 11 msecs: init_xfs_fs+0x0/0x6c()
[    4.656291] Calling initcall 0xffffffff81a2f160: init_gfs2_fs+0x0/0x155()
[    4.668291] GFS2 (built Apr 17 2008 10:53:47) installed
[    4.672292] initcall 0xffffffff81a2f160: init_gfs2_fs+0x0/0x155() returned 0.
[    4.676292] initcall 0xffffffff81a2f160 ran for 7 msecs: init_gfs2_fs+0x0/0x155()
[    4.680292] Calling initcall 0xffffffff81a2f2b5: init_nolock+0x0/0x5e()
[    4.688293] Lock_Nolock (built Apr 17 2008 10:53:53) installed
[    4.692293] initcall 0xffffffff81a2f2b5: init_nolock+0x0/0x5e() returned 0.
[    4.700293] initcall 0xffffffff81a2f2b5 ran for 3 msecs: init_nolock+0x0/0x5e()
[    4.704294] Calling initcall 0xffffffff81a2f313: init_lock_dlm+0x0/0x9d()
[    4.712294] Lock_DLM (built Apr 17 2008 10:53:53) installed
[    4.716294] initcall 0xffffffff81a2f313: init_lock_dlm+0x0/0x9d() returned 0.
[    4.724295] initcall 0xffffffff81a2f313 ran for 3 msecs: init_lock_dlm+0x0/0x9d()
[    4.732295] Calling initcall 0xffffffff81a2f3b0: ipc_init+0x0/0x1c()
[    4.736296] initcall 0xffffffff81a2f3b0: ipc_init+0x0/0x1c() returned 0.
[    4.744296] initcall 0xffffffff81a2f3b0 ran for 0 msecs: ipc_init+0x0/0x1c()
[    4.752297] Calling initcall 0xffffffff81a2f4ee: ipc_sysctl_init+0x0/0x19()
[    4.760297] initcall 0xffffffff81a2f4ee: ipc_sysctl_init+0x0/0x19() returned 0.
[    4.764297] initcall 0xffffffff81a2f4ee ran for 0 msecs: ipc_sysctl_init+0x0/0x19()
[    4.768298] Calling initcall 0xffffffff81a2f507: init_mqueue_fs+0x0/0xd9()
[    4.776298] initcall 0xffffffff81a2f507: init_mqueue_fs+0x0/0xd9() returned 0.
[    4.784299] initcall 0xffffffff81a2f507 ran for 0 msecs: init_mqueue_fs+0x0/0xd9()
[    4.792299] Calling initcall 0xffffffff81a2f754: key_proc_init+0x0/0x5f()
[    4.800300] initcall 0xffffffff81a2f754: key_proc_init+0x0/0x5f() returned 0.
[    4.804300] initcall 0xffffffff81a2f754 ran for 0 msecs: key_proc_init+0x0/0x5f()
[    4.808300] Calling initcall 0xffffffff81a2f919: crypto_algapi_init+0x0/0x12()
[    4.816301] initcall 0xffffffff81a2f919: crypto_algapi_init+0x0/0x12() returned 0.
[    4.824301] initcall 0xffffffff81a2f919 ran for 0 msecs: crypto_algapi_init+0x0/0x12()
[    4.832302] Calling initcall 0xffffffff81a2f953: blkcipher_module_init+0x0/0x3b()
[    4.840302] initcall 0xffffffff81a2f953: blkcipher_module_init+0x0/0x3b() returned 0.
[    4.848303] initcall 0xffffffff81a2f953 ran for 0 msecs: blkcipher_module_init+0x0/0x3b()
[    4.856303] Calling initcall 0xffffffff81a2f9bc: seqiv_module_init+0x0/0x17()
[    4.864304] initcall 0xffffffff81a2f9bc: seqiv_module_init+0x0/0x17() returned 0.
[    4.872304] initcall 0xffffffff81a2f9bc ran for 0 msecs: seqiv_module_init+0x0/0x17()
[    4.876304] Calling initcall 0xffffffff81a2f9d3: cryptomgr_init+0x0/0x17()
[    4.880305] initcall 0xffffffff81a2f9d3: cryptomgr_init+0x0/0x17() returned 0.
[    4.888305] initcall 0xffffffff81a2f9d3 ran for 0 msecs: cryptomgr_init+0x0/0x17()
[    4.896306] Calling initcall 0xffffffff81a2f9ea: hmac_module_init+0x0/0x17()
[    4.904306] initcall 0xffffffff81a2f9ea: hmac_module_init+0x0/0x17() returned 0.
[    4.912307] initcall 0xffffffff81a2f9ea ran for 0 msecs: hmac_module_init+0x0/0x17()
[    4.916307] Calling initcall 0xffffffff81a2fa01: crypto_xcbc_module_init+0x0/0x17()
[    4.920307] initcall 0xffffffff81a2fa01: crypto_xcbc_module_init+0x0/0x17() returned 0.
[    4.928308] initcall 0xffffffff81a2fa01 ran for 0 msecs: crypto_xcbc_module_init+0x0/0x17()
[    4.936308] Calling initcall 0xffffffff81a2fa18: init+0x0/0x17()
[    4.940308] initcall 0xffffffff81a2fa18: init+0x0/0x17() returned 0.
[    4.948309] initcall 0xffffffff81a2fa18 ran for 0 msecs: init+0x0/0x17()
[    4.952309] Calling initcall 0xffffffff81a2fa2f: init+0x0/0x17()
[    4.960310] initcall 0xffffffff81a2fa2f: init+0x0/0x17() returned 0.
[    4.964310] initcall 0xffffffff81a2fa2f ran for 0 msecs: init+0x0/0x17()
[    4.968310] Calling initcall 0xffffffff81a2fa46: init+0x0/0x50()
[    4.976311] initcall 0xffffffff81a2fa46: init+0x0/0x50() returned 0.
[    4.980311] initcall 0xffffffff81a2fa46 ran for 0 msecs: init+0x0/0x50()
[    4.984311] Calling initcall 0xffffffff81a2fa96: crypto_ecb_module_init+0x0/0x17()
[    4.992312] initcall 0xffffffff81a2fa96: crypto_ecb_module_init+0x0/0x17() returned 0.
[    5.000312] initcall 0xffffffff81a2fa96 ran for 0 msecs: crypto_ecb_module_init+0x0/0x17()
[    5.008313] Calling initcall 0xffffffff81a2faad: crypto_cbc_module_init+0x0/0x17()
[    5.016313] initcall 0xffffffff81a2faad: crypto_cbc_module_init+0x0/0x17() returned 0.
[    5.024314] initcall 0xffffffff81a2faad ran for 0 msecs: crypto_cbc_module_init+0x0/0x17()
[    5.032314] Calling initcall 0xffffffff81a2fac4: crypto_pcbc_module_init+0x0/0x17()
[    5.040315] initcall 0xffffffff81a2fac4: crypto_pcbc_module_init+0x0/0x17() returned 0.
[    5.048315] initcall 0xffffffff81a2fac4 ran for 0 msecs: crypto_pcbc_module_init+0x0/0x17()
[    5.056316] Calling initcall 0xffffffff81a2fadb: crypto_module_init+0x0/0x17()
[    5.064316] initcall 0xffffffff81a2fadb: crypto_module_init+0x0/0x17() returned 0.
[    5.072317] initcall 0xffffffff81a2fadb ran for 0 msecs: crypto_module_init+0x0/0x17()
[    5.080317] Calling initcall 0xffffffff81a2faf2: crypto_ctr_module_init+0x0/0x50()
[    5.084317] initcall 0xffffffff81a2faf2: crypto_ctr_module_init+0x0/0x50() returned 0.
[    5.092318] initcall 0xffffffff81a2faf2 ran for 0 msecs: crypto_ctr_module_init+0x0/0x50()
[    5.100318] Calling initcall 0xffffffff81a2fb42: crypto_gcm_module_init+0x0/0x6e()
[    5.104319] initcall 0xffffffff81a2fb42: crypto_gcm_module_init+0x0/0x6e() returned 0.
[    5.112319] initcall 0xffffffff81a2fb42 ran for 0 msecs: crypto_gcm_module_init+0x0/0x6e()
[    5.116319] Calling initcall 0xffffffff81a2fbb0: crypto_ccm_module_init+0x0/0x6e()
[    5.120320] initcall 0xffffffff81a2fbb0: crypto_ccm_module_init+0x0/0x6e() returned 0.
[    5.128320] initcall 0xffffffff81a2fbb0 ran for 0 msecs: crypto_ccm_module_init+0x0/0x6e()
[    5.132320] Calling initcall 0xffffffff81a2fc1e: init+0x0/0x50()
[    5.136321] initcall 0xffffffff81a2fc1e: init+0x0/0x50() returned 0.
[    5.144321] initcall 0xffffffff81a2fc1e ran for 0 msecs: init+0x0/0x50()
[    5.148321] Calling initcall 0xffffffff81a2fc6e: init+0x0/0x17()
[    5.156322] initcall 0xffffffff81a2fc6e: init+0x0/0x17() returned 0.
[    5.160322] initcall 0xffffffff81a2fc6e ran for 0 msecs: init+0x0/0x17()
[    5.164322] Calling initcall 0xffffffff81a2fc85: init+0x0/0x17()
[    5.172323] initcall 0xffffffff81a2fc85: init+0x0/0x17() returned 0.
[    5.176323] initcall 0xffffffff81a2fc85 ran for 0 msecs: init+0x0/0x17()
[    5.184324] Calling initcall 0xffffffff81a2fc9c: init+0x0/0x17()
[    5.188324] initcall 0xffffffff81a2fc9c: init+0x0/0x17() returned 0.
[    5.196324] initcall 0xffffffff81a2fc9c ran for 0 msecs: init+0x0/0x17()
[    5.204325] Calling initcall 0xffffffff81a2fcb3: init+0x0/0x50()
[    5.208325] initcall 0xffffffff81a2fcb3: init+0x0/0x50() returned 0.
[    5.216326] initcall 0xffffffff81a2fcb3 ran for 0 msecs: init+0x0/0x50()
[    5.220326] Calling initcall 0xffffffff81a2fd03: aes_init+0x0/0x351()
[    5.228326] initcall 0xffffffff81a2fd03: aes_init+0x0/0x351() returned 0.
[    5.236327] initcall 0xffffffff81a2fd03 ran for 0 msecs: aes_init+0x0/0x351()
[    5.244327] Calling initcall 0xffffffff81a30054: init+0x0/0x17()
[    5.248328] initcall 0xffffffff81a30054: init+0x0/0x17() returned 0.
[    5.256328] initcall 0xffffffff81a30054 ran for 0 msecs: init+0x0/0x17()
[    5.260328] Calling initcall 0xffffffff81a3006b: arc4_init+0x0/0x17()
[    5.268329] initcall 0xffffffff81a3006b: arc4_init+0x0/0x17() returned 0.
[    5.276329] initcall 0xffffffff81a3006b ran for 0 msecs: arc4_init+0x0/0x17()
[    5.280330] Calling initcall 0xffffffff81a30082: init+0x0/0x83()
[    5.288330] initcall 0xffffffff81a30082: init+0x0/0x83() returned 0.
[    5.296331] initcall 0xffffffff81a30082 ran for 0 msecs: init+0x0/0x83()
[    5.300331] Calling initcall 0xffffffff81a30105: init+0x0/0x17()
[    5.308331] initcall 0xffffffff81a30105: init+0x0/0x17() returned 0.
[    5.312332] initcall 0xffffffff81a30105 ran for 0 msecs: init+0x0/0x17()
[    5.316332] Calling initcall 0xffffffff81a3011c: init+0x0/0x17()
[    5.324332] initcall 0xffffffff81a3011c: init+0x0/0x17() returned 0.
[    5.328333] initcall 0xffffffff81a3011c ran for 0 msecs: init+0x0/0x17()
[    5.336333] Calling initcall 0xffffffff81a30133: init+0x0/0x17()
[    5.340333] initcall 0xffffffff81a30133: init+0x0/0x17() returned 0.
[    5.348334] initcall 0xffffffff81a30133 ran for 0 msecs: init+0x0/0x17()
[    5.356334] Calling initcall 0xffffffff81a3014a: crypto_authenc_module_init+0x0/0x17()
[    5.364335] initcall 0xffffffff81a3014a: crypto_authenc_module_init+0x0/0x17() returned 0.
[    5.372335] initcall 0xffffffff81a3014a ran for 0 msecs: crypto_authenc_module_init+0x0/0x17()
[    5.380336] Calling initcall 0xffffffff81a30161: init+0x0/0x17()
[    5.384336] initcall 0xffffffff81a30161: init+0x0/0x17() returned 0.
[    5.392337] initcall 0xffffffff81a30161 ran for 0 msecs: init+0x0/0x17()
[    5.400337] Calling initcall 0xffffffff81a3050c: noop_init+0x0/0x19()
[    5.404337] io scheduler noop registered (default)
[    5.408338] initcall 0xffffffff81a3050c: noop_init+0x0/0x19() returned 0.
[    5.416338] initcall 0xffffffff81a3050c ran for 3 msecs: noop_init+0x0/0x19()
[    5.424339] Calling initcall 0xffffffff81a30741: percpu_counter_startup+0x0/0x1f()
[    5.432339] initcall 0xffffffff81a30741: percpu_counter_startup+0x0/0x1f() returned 0.
[    5.440340] initcall 0xffffffff81a30741 ran for 0 msecs: percpu_counter_startup+0x0/0x1f()
[    5.448340] Calling initcall 0xffffffff809aabd5: pci_init+0x0/0x4b()
[    5.472342] pci 0000:01:00.0: Boot video device
[    5.476342] initcall 0xffffffff809aabd5: pci_init+0x0/0x4b() returned 0.
[    5.480342] initcall 0xffffffff809aabd5 ran for 22 msecs: pci_init+0x0/0x4b()
[    5.484342] Calling initcall 0xffffffff81a30f25: pci_proc_init+0x0/0x7c()
[    5.492343] initcall 0xffffffff81a30f25: pci_proc_init+0x0/0x7c() returned 0.
[    5.500343] initcall 0xffffffff81a30f25 ran for 0 msecs: pci_proc_init+0x0/0x7c()
[    5.508344] Calling initcall 0xffffffff81a30fa1: pci_hotplug_init+0x0/0xad()
[    5.512344] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    5.516344] initcall 0xffffffff81a30fa1: pci_hotplug_init+0x0/0xad() returned 0.
[    5.524345] initcall 0xffffffff81a30fa1 ran for 3 msecs: pci_hotplug_init+0x0/0xad()
[    5.528345] Calling initcall 0xffffffff81a31061: acpiphp_init+0x0/0x6a()
[    5.532345] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    5.536346] initcall 0xffffffff81a31061: acpiphp_init+0x0/0x6a() returned 0.
[    5.544346] initcall 0xffffffff81a31061 ran for 3 msecs: acpiphp_init+0x0/0x6a()
[    5.548346] Calling initcall 0xffffffff81a311d4: ibm_acpiphp_init+0x0/0x1a9()
[    5.556347] ACPI Exception (utmutex-0263): AE_BAD_PARAMETER, Thread FFFF81003FB5F0C0 could not acquire Mutex [1] [20070126]
[    5.564347] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[    5.568348] initcall 0xffffffff81a311d4: ibm_acpiphp_init+0x0/0x1a9() returned -19.
[    5.576348] initcall 0xffffffff81a311d4 ran for 11 msecs: ibm_acpiphp_init+0x0/0x1a9()
[    5.580348] Calling initcall 0xffffffff81a31478: zt5550_init+0x0/0x8d()
[    5.584349] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[    5.588349] initcall 0xffffffff81a31478: zt5550_init+0x0/0x8d() returned 0.
[    5.596349] initcall 0xffffffff81a31478 ran for 3 msecs: zt5550_init+0x0/0x8d()
[    5.600350] Calling initcall 0xffffffff81a3174f: display_class_init+0x0/0x85()
[    5.604350] initcall 0xffffffff81a3174f: display_class_init+0x0/0x85() returned 0.
[    5.612350] initcall 0xffffffff81a3174f ran for 0 msecs: display_class_init+0x0/0x85()
[    5.620351] Calling initcall 0xffffffff81a317d4: arcfb_init+0x0/0x7f()
[    5.628351] initcall 0xffffffff81a317d4: arcfb_init+0x0/0x7f() returned -6.
[    5.636352] initcall 0xffffffff81a317d4 ran for 0 msecs: arcfb_init+0x0/0x7f()
[    5.640352] initcall at 0xffffffff81a317d4: arcfb_init+0x0/0x7f(): returned with error code -6
[    5.652353] Calling initcall 0xffffffff81a31bd5: cyber2000fb_init+0x0/0xd5()
[    5.656353] initcall 0xffffffff81a31bd5: cyber2000fb_init+0x0/0xd5() returned 0.
[    5.664354] initcall 0xffffffff81a31bd5 ran for 0 msecs: cyber2000fb_init+0x0/0xd5()
[    5.672354] Calling initcall 0xffffffff81a31caa: pm2fb_init+0x0/0x16b()
[    5.680355] initcall 0xffffffff81a31caa: pm2fb_init+0x0/0x16b() returned 0.
[    5.688355] initcall 0xffffffff81a31caa ran for 0 msecs: pm2fb_init+0x0/0x16b()
[    5.692355] Calling initcall 0xffffffff81a31e15: matroxfb_init+0x0/0x9dd()
[    5.700356] initcall 0xffffffff81a31e15: matroxfb_init+0x0/0x9dd() returned 0.
[    5.708356] initcall 0xffffffff81a31e15 ran for 0 msecs: matroxfb_init+0x0/0x9dd()
[    5.716357] Calling initcall 0xffffffff809ac810: aty128fb_init+0x0/0x151()
[    5.724357] initcall 0xffffffff809ac810: aty128fb_init+0x0/0x151() returned 0.
[    5.728358] initcall 0xffffffff809ac810 ran for 0 msecs: aty128fb_init+0x0/0x151()
[    5.732358] Calling initcall 0xffffffff81a327f2: neofb_init+0x0/0x16e()
[    5.740358] initcall 0xffffffff81a327f2: neofb_init+0x0/0x16e() returned 0.
[    5.748359] initcall 0xffffffff81a327f2 ran for 0 msecs: neofb_init+0x0/0x16e()
[    5.756359] Calling initcall 0xffffffff81a32960: imsttfb_init+0x0/0x110()
[    5.760360] initcall 0xffffffff81a32960: imsttfb_init+0x0/0x110() returned 0.
[    5.768360] initcall 0xffffffff81a32960 ran for 0 msecs: imsttfb_init+0x0/0x110()
[    5.776361] Calling initcall 0xffffffff81a32a70: vt8623fb_init+0x0/0x60()
[    5.784361] initcall 0xffffffff81a32a70: vt8623fb_init+0x0/0x60() returned 0.
[    5.788361] initcall 0xffffffff81a32a70 ran for 0 msecs: vt8623fb_init+0x0/0x60()
[    5.792362] Calling initcall 0xffffffff81a32ad0: vmlfb_init+0x0/0x9b()
[    5.800362] vmlfb: initializing
[    5.804362] initcall 0xffffffff81a32ad0: vmlfb_init+0x0/0x9b() returned 0.
[    5.808363] initcall 0xffffffff81a32ad0 ran for 3 msecs: vmlfb_init+0x0/0x9b()
[    5.812363] Calling initcall 0xffffffff81a32b6b: s3fb_init+0x0/0xf1()
[    5.820363] initcall 0xffffffff81a32b6b: s3fb_init+0x0/0xf1() returned 0.
[    5.828364] initcall 0xffffffff81a32b6b ran for 0 msecs: s3fb_init+0x0/0xf1()
[    5.832364] Calling initcall 0xffffffff81a32c5c: hgafb_init+0x0/0x60()
[    5.836364] hgafb: HGA card not detected.
[    5.840365] hgafb: probe of hgafb.0 failed with error -22
[    5.844365] initcall 0xffffffff81a32c5c: hgafb_init+0x0/0x60() returned 0.
[    5.852365] initcall 0xffffffff81a32c5c ran for 7 msecs: hgafb_init+0x0/0x60()
[    5.860366] Calling initcall 0xffffffff81a33051: s1d13xxxfb_init+0x0/0x3f()
[    5.868366] initcall 0xffffffff81a33051: s1d13xxxfb_init+0x0/0x3f() returned 0.
[    5.876367] initcall 0xffffffff81a33051 ran for 0 msecs: s1d13xxxfb_init+0x0/0x3f()
[    5.880367] Calling initcall 0xffffffff809afe35: sm501fb_init+0x0/0x17()
[    5.884367] initcall 0xffffffff809afe35: sm501fb_init+0x0/0x17() returned 0.
[    5.892368] initcall 0xffffffff809afe35 ran for 0 msecs: sm501fb_init+0x0/0x17()
[    5.900368] Calling initcall 0xffffffff81a33c80: imacfb_init+0x0/0x1f6()
[    5.904369] initcall 0xffffffff81a33c80: imacfb_init+0x0/0x1f6() returned -19.
[    5.912369] initcall 0xffffffff81a33c80 ran for 0 msecs: imacfb_init+0x0/0x1f6()
[    5.916369] Calling initcall 0xffffffff81a3436d: acpi_reserve_resources+0x0/0xf0()
[    5.924370] initcall 0xffffffff81a3436d: acpi_reserve_resources+0x0/0xf0() returned 0.
[    5.932370] initcall 0xffffffff81a3436d ran for 0 msecs: acpi_reserve_resources+0x0/0xf0()
[    5.940371] Calling initcall 0xffffffff81a35253: acpi_battery_init+0x0/0x2d()
[    5.948371] initcall 0xffffffff81a35253: acpi_battery_init+0x0/0x2d() returned -19.
[    5.956372] initcall 0xffffffff81a35253 ran for 0 msecs: acpi_battery_init+0x0/0x2d()
[    5.964372] Calling initcall 0xffffffff81a35280: acpi_fan_init+0x0/0x37()
[    5.972373] initcall 0xffffffff81a35280: acpi_fan_init+0x0/0x37() returned -19.
[    5.976373] initcall 0xffffffff81a35280 ran for 0 msecs: acpi_fan_init+0x0/0x37()
[    5.980373] Calling initcall 0xffffffff81a35416: irqrouter_init_sysfs+0x0/0x3d()
[    5.988374] initcall 0xffffffff81a35416: irqrouter_init_sysfs+0x0/0x3d() returned 0.
[    5.996374] initcall 0xffffffff81a35416 ran for 0 msecs: irqrouter_init_sysfs+0x0/0x3d()
[    6.004375] Calling initcall 0xffffffff81a355a5: acpi_container_init+0x0/0x47()
[    6.012375] initcall 0xffffffff81a355a5: acpi_container_init+0x0/0x47() returned -19.
[    6.020376] initcall 0xffffffff81a355a5 ran for 0 msecs: acpi_container_init+0x0/0x47()
[    6.028376] Calling initcall 0xffffffff81a357f6: acpi_memory_device_init+0x0/0x8a()
[    6.036377] initcall 0xffffffff81a357f6: acpi_memory_device_init+0x0/0x8a() returned -19.
[    6.044377] initcall 0xffffffff81a357f6 ran for 0 msecs: acpi_memory_device_init+0x0/0x8a()
[    6.052378] Calling initcall 0xffffffff81a3653c: rand_initialize+0x0/0x31()
[    6.060378] initcall 0xffffffff81a3653c: rand_initialize+0x0/0x31() returned 0.
[    6.068379] initcall 0xffffffff81a3653c ran for 0 msecs: rand_initialize+0x0/0x31()
[    6.072379] Calling initcall 0xffffffff81a365b0: tty_init+0x0/0x1ee()
[    6.080380] initcall 0xffffffff81a365b0: tty_init+0x0/0x1ee() returned 0.
[    6.084380] initcall 0xffffffff81a365b0 ran for 3 msecs: tty_init+0x0/0x1ee()
[    6.088380] Calling initcall 0xffffffff81a367e2: pty_init+0x0/0x305()
[    6.096381] initcall 0xffffffff81a367e2: pty_init+0x0/0x305() returned 0.
[    6.104381] initcall 0xffffffff81a367e2 ran for 0 msecs: pty_init+0x0/0x305()
[    6.108381] Calling initcall 0xffffffff81a371b0: rp_init+0x0/0x1a99()
[    6.116382] RocketPort device driver module, version 2.09, 12-June-2003
[    6.120382] No rocketport ports found; unloading driver
[    6.124382] initcall 0xffffffff81a371b0: rp_init+0x0/0x1a99() returned -6.
[    6.132383] initcall 0xffffffff81a371b0 ran for 7 msecs: rp_init+0x0/0x1a99()
[    6.136383] initcall at 0xffffffff81a371b0: rp_init+0x0/0x1a99(): returned with error code -6
[    6.148384] Calling initcall 0xffffffff81a38c49: nozomi_init+0x0/0x177()
[    6.152384] Initializing Nozomi driver 2.1d (build date: Apr 17 2008 10:53:54)
[    6.156384] initcall 0xffffffff81a38c49: nozomi_init+0x0/0x177() returned 0.
[    6.164385] initcall 0xffffffff81a38c49 ran for 3 msecs: nozomi_init+0x0/0x177()
[    6.172385] Calling initcall 0xffffffff81a38dc0: mxser_module_init+0x0/0x7ac()
[    6.180386] MOXA Smartio/Industio family driver version 2.0.3
[    6.184386] initcall 0xffffffff81a38dc0: mxser_module_init+0x0/0x7ac() returned 0.
[    6.192387] initcall 0xffffffff81a38dc0 ran for 3 msecs: mxser_module_init+0x0/0x7ac()
[    6.200387] Calling initcall 0xffffffff81a3956c: ip2_init+0x0/0x5c()
[    6.208388] Computone IntelliPort Plus multiport driver version 1.2.14
[    6.212388] initcall 0xffffffff81a3956c: ip2_init+0x0/0x5c() returned 0.
[    6.220388] initcall 0xffffffff81a3956c ran for 3 msecs: ip2_init+0x0/0x5c()
[    6.228389] Calling initcall 0xffffffff81a39636: isicom_init+0x0/0x1e9()
[    6.232389] initcall 0xffffffff81a39636: isicom_init+0x0/0x1e9() returned 0.
[    6.240390] initcall 0xffffffff81a39636 ran for 0 msecs: isicom_init+0x0/0x1e9()
[    6.248390] Calling initcall 0xffffffff81a3981f: synclinkmp_init+0x0/0x1e3()
[    6.256391] SyncLink MultiPort driver $Revision: 4.38 $
[    6.264391] SyncLink MultiPort driver $Revision: 4.38 $, tty major#253
[    6.268391] initcall 0xffffffff81a3981f: synclinkmp_init+0x0/0x1e3() returned 0.
[    6.276392] initcall 0xffffffff81a3981f ran for 11 msecs: synclinkmp_init+0x0/0x1e3()
[    6.284392] Calling initcall 0xffffffff81a39a02: n_hdlc_init+0x0/0xa9()
[    6.288393] HDLC line discipline: version $Revision: 4.8 $, maxframe=4096
[    6.292393] N_HDLC line discipline registered.
[    6.296393] initcall 0xffffffff81a39a02: n_hdlc_init+0x0/0xa9() returned 0.
[    6.304394] initcall 0xffffffff81a39a02 ran for 7 msecs: n_hdlc_init+0x0/0xa9()
[    6.312394] Calling initcall 0xffffffff81a39aab: sx_init+0x0/0x125()
[    6.316394] initcall 0xffffffff81a39aab: sx_init+0x0/0x125() returned 0.
[    6.324395] initcall 0xffffffff81a39aab ran for 0 msecs: sx_init+0x0/0x125()
[    6.332395] Calling initcall 0xffffffff81a39bd0: rio_init+0x0/0x12c1()
[    6.340396] initcall 0xffffffff81a39bd0: rio_init+0x0/0x12c1() returned -5.
[    6.344396] initcall 0xffffffff81a39bd0 ran for 0 msecs: rio_init+0x0/0x12c1()
[    6.348396] initcall at 0xffffffff81a39bd0: rio_init+0x0/0x12c1(): returned with error code -5
[    6.356397] Calling initcall 0xffffffff81a3ae91: raw_init+0x0/0xe6()
[    6.360397] initcall 0xffffffff81a3ae91: raw_init+0x0/0xe6() returned 0.
[    6.368398] initcall 0xffffffff81a3ae91 ran for 0 msecs: raw_init+0x0/0xe6()
[    6.376398] Calling initcall 0xffffffff81a3b0ae: lp_init_module+0x0/0x26c()
[    6.380398] lp: driver loaded but no devices found
[    6.384399] initcall 0xffffffff81a3b0ae: lp_init_module+0x0/0x26c() returned 0.
[    6.392399] initcall 0xffffffff81a3b0ae ran for 3 msecs: lp_init_module+0x0/0x26c()
[    6.396399] Calling initcall 0xffffffff81a3b31a: r3964_init+0x0/0x56()
[    6.404400] r3964: Philips r3964 Driver $Revision: 1.10 $
[    6.408400] initcall 0xffffffff81a3b31a: r3964_init+0x0/0x56() returned 0.
[    6.416401] initcall 0xffffffff81a3b31a ran for 3 msecs: r3964_init+0x0/0x56()
[    6.424401] Calling initcall 0xffffffff81a3b3af: rtc_init+0x0/0x1f5()
[    6.428401] Real Time Clock Driver v1.12ac
[    6.432402] initcall 0xffffffff81a3b3af: rtc_init+0x0/0x1f5() returned 0.
[    6.440402] initcall 0xffffffff81a3b3af ran for 3 msecs: rtc_init+0x0/0x1f5()
[    6.448403] Calling initcall 0xffffffff81a3b5a4: nvram_init+0x0/0x9c()
[    6.456403] Non-volatile memory driver v1.2
[    6.460403] initcall 0xffffffff81a3b5a4: nvram_init+0x0/0x9c() returned 0.
[    6.464404] initcall 0xffffffff81a3b5a4 ran for 3 msecs: nvram_init+0x0/0x9c()
[    6.468404] Calling initcall 0xffffffff81a3b640: i8k_init+0x0/0x25e()
[    6.476404] initcall 0xffffffff81a3b640: i8k_init+0x0/0x25e() returned -19.
[    6.484405] initcall 0xffffffff81a3b640 ran for 0 msecs: i8k_init+0x0/0x25e()
[    6.488405] Calling initcall 0xffffffff81a3b89e: ppdev_init+0x0/0xc2()
[    6.496406] ppdev: user-space parallel port driver
[    6.500406] initcall 0xffffffff81a3b89e: ppdev_init+0x0/0xc2() returned 0.
[    6.508406] initcall 0xffffffff81a3b89e ran for 3 msecs: ppdev_init+0x0/0xc2()
[    6.516407] Calling initcall 0xffffffff81a3b960: tlclk_init+0x0/0x1e0()
[    6.520407] telclk_interrup = 0xf non-mcpbl0010 hw.
[    6.524407] initcall 0xffffffff81a3b960: tlclk_init+0x0/0x1e0() returned -6.
[    6.528408] initcall 0xffffffff81a3b960 ran for 3 msecs: tlclk_init+0x0/0x1e0()
[    6.532408] initcall at 0xffffffff81a3b960: tlclk_init+0x0/0x1e0(): returned with error code -6
[    6.540408] Calling initcall 0xffffffff81a3bb8f: agp_init+0x0/0x31()
[    6.548409] Linux agpgart interface v0.103
[    6.552409] initcall 0xffffffff81a3bb8f: agp_init+0x0/0x31() returned 0.
[    6.560410] initcall 0xffffffff81a3bb8f ran for 3 msecs: agp_init+0x0/0x31()
[    6.564410] Calling initcall 0xffffffff81a3bbc0: agp_amd64_init+0x0/0xe1()
[    6.568410] initcall 0xffffffff81a3bbc0: agp_amd64_init+0x0/0xe1() returned 0.
[    6.576411] initcall 0xffffffff81a3bbc0 ran for 0 msecs: agp_amd64_init+0x0/0xe1()
[    6.584411] Calling initcall 0xffffffff81a3bca1: agp_intel_init+0x0/0x33()
[    6.592412] initcall 0xffffffff81a3bca1: agp_intel_init+0x0/0x33() returned 0.
[    6.596412] initcall 0xffffffff81a3bca1 ran for 0 msecs: agp_intel_init+0x0/0x33()
[    6.600412] Calling initcall 0xffffffff81a3bcd4: agp_sis_init+0x0/0x31()
[    6.608413] initcall 0xffffffff81a3bcd4: agp_sis_init+0x0/0x31() returned 0.
[    6.616413] initcall 0xffffffff81a3bcd4 ran for 0 msecs: agp_sis_init+0x0/0x31()
[    6.624414] Calling initcall 0xffffffff81a3bd05: agp_via_init+0x0/0x31()
[    6.628414] initcall 0xffffffff81a3bd05: agp_via_init+0x0/0x31() returned 0.
[    6.636414] initcall 0xffffffff81a3bd05 ran for 0 msecs: agp_via_init+0x0/0x31()
[    6.644415] Calling initcall 0xffffffff81a3bd36: drm_core_init+0x0/0x15d()
[    6.652415] [drm] Initialized drm 1.1.0 20060810
[    6.656416] initcall 0xffffffff81a3bd36: drm_core_init+0x0/0x15d() returned 0.
[    6.664416] initcall 0xffffffff81a3bd36 ran for 3 msecs: drm_core_init+0x0/0x15d()
[    6.672417] Calling initcall 0xffffffff81a3be93: tdfx_init+0x0/0x17()
[    6.676417] initcall 0xffffffff81a3be93: tdfx_init+0x0/0x17() returned 0.
[    6.684417] initcall 0xffffffff81a3be93 ran for 0 msecs: tdfx_init+0x0/0x17()
[    6.692418] Calling initcall 0xffffffff81a3beaa: r128_init+0x0/0x23()
[    6.696418] initcall 0xffffffff81a3beaa: r128_init+0x0/0x23() returned 0.
[    6.704419] initcall 0xffffffff81a3beaa ran for 0 msecs: r128_init+0x0/0x23()
[    6.712419] Calling initcall 0xffffffff81a3becd: mga_init+0x0/0x23()
[    6.716419] initcall 0xffffffff81a3becd: mga_init+0x0/0x23() returned 0.
[    6.724420] initcall 0xffffffff81a3becd ran for 0 msecs: mga_init+0x0/0x23()
[    6.732420] Calling initcall 0xffffffff81a3bef0: i830_init+0x0/0x23()
[    6.740421] initcall 0xffffffff81a3bef0: i830_init+0x0/0x23() returned 0.
[    6.744421] initcall 0xffffffff81a3bef0 ran for 0 msecs: i830_init+0x0/0x23()
[    6.748421] Calling initcall 0xffffffff81a3bf13: savage_init+0x0/0x23()
[    6.756422] initcall 0xffffffff81a3bf13: savage_init+0x0/0x23() returned 0.
[    6.760422] initcall 0xffffffff81a3bf13 ran for 0 msecs: savage_init+0x0/0x23()
[    6.764422] Calling initcall 0xffffffff81a3bffe: hangcheck_init+0x0/0xa2()
[    6.772423] Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin is 60 seconds).
[    6.776423] Hangcheck: Using get_cycles().
[    6.780423] initcall 0xffffffff81a3bffe: hangcheck_init+0x0/0xa2() returned 0.
[    6.788424] initcall 0xffffffff81a3bffe ran for 7 msecs: hangcheck_init+0x0/0xa2()
[    6.796424] Calling initcall 0xffffffff81a3c0a0: init_atmel+0x0/0x17c()
[    6.804425] initcall 0xffffffff81a3c0a0: init_atmel+0x0/0x17c() returned -19.
[    6.808425] initcall 0xffffffff81a3c0a0 ran for 0 msecs: init_atmel+0x0/0x17c()
[    6.812425] Calling initcall 0xffffffff81a3c21c: init_inf+0x0/0x24()
[    6.820426] initcall 0xffffffff81a3c21c: init_inf+0x0/0x24() returned 0.
[    6.828426] initcall 0xffffffff81a3c21c ran for 0 msecs: init_inf+0x0/0x24()
[    6.832427] Calling initcall 0xffffffff81a3c5ae: serial8250_init+0x0/0x164()
[    6.840427] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
[    7.100443] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    7.108444] initcall 0xffffffff81a3c5ae: serial8250_init+0x0/0x164() returned 0.
[    7.112444] initcall 0xffffffff81a3c5ae ran for 255 msecs: serial8250_init+0x0/0x164()
[    7.116444] Calling initcall 0xffffffff81a3c712: serial8250_pnp_init+0x0/0x17()
[    7.124445] initcall 0xffffffff81a3c712: serial8250_pnp_init+0x0/0x17() returned 0.
[    7.132445] initcall 0xffffffff81a3c712 ran for 0 msecs: serial8250_pnp_init+0x0/0x17()
[    7.140446] Calling initcall 0xffffffff81a3cbd0: parport_default_proc_register+0x0/0x20()
[    7.148446] initcall 0xffffffff81a3cbd0: parport_default_proc_register+0x0/0x20() returned 0.
[    7.156447] initcall 0xffffffff81a3cbd0 ran for 0 msecs: parport_default_proc_register+0x0/0x20()
[    7.164447] Calling initcall 0xffffffff81a3ceff: parport_pc_init+0x0/0x401()
[    7.168448] IT8712 SuperIO detected.
[    7.172448] parport0: PC-style at 0x378 (0x778) [PCSPP,TRISTATE]
[    7.312457] parport0: irq 7 detected
[    7.412463] lp0: using parport0 (polling).
[    7.416463] lp0: console ready
[    7.416463] initcall 0xffffffff81a3ceff: parport_pc_init+0x0/0x401() returned 0.
[    7.424464] initcall 0xffffffff81a3ceff ran for 236 msecs: parport_pc_init+0x0/0x401()
[    7.428464] Calling initcall 0xffffffff809ecc20: topology_sysfs_init+0x0/0x63()
[    7.436464] initcall 0xffffffff809ecc20: topology_sysfs_init+0x0/0x63() returned 0.
[    7.444465] initcall 0xffffffff809ecc20 ran for 0 msecs: topology_sysfs_init+0x0/0x63()
[    7.452465] Calling initcall 0xffffffff81a3da37: floppy_init+0x0/0x1169()
[    7.460466] Floppy drive(s): fd0 is 1.44M
[    7.480467] FDC 0 is a post-1991 82077
[    7.488468] initcall 0xffffffff81a3da37: floppy_init+0x0/0x1169() returned 0.
[    7.492468] initcall 0xffffffff81a3da37 ran for 26 msecs: floppy_init+0x0/0x1169()
[    7.496468] Calling initcall 0xffffffff81a3ebcf: brd_init+0x0/0x191()
[    7.504469] brd: module loaded
[    7.508469] initcall 0xffffffff81a3ebcf: brd_init+0x0/0x191() returned 0.
[    7.516469] initcall 0xffffffff81a3ebcf ran for 3 msecs: brd_init+0x0/0x191()
[    7.520470] Calling initcall 0xffffffff81a3ed60: loop_init+0x0/0x1aa()
[    7.528470] loop: module loaded
[    7.532470] initcall 0xffffffff81a3ed60: loop_init+0x0/0x1aa() returned 0.
[    7.540471] initcall 0xffffffff81a3ed60 ran for 3 msecs: loop_init+0x0/0x1aa()
[    7.544471] Calling initcall 0xffffffff81a3f4f8: cpqarray_init+0x0/0x29f()
[    7.548471] Compaq SMART2 Driver (v 2.6.0)
[    7.552472] initcall 0xffffffff81a3f4f8: cpqarray_init+0x0/0x29f() returned 0.
[    7.560472] initcall 0xffffffff81a3f4f8 ran for 3 msecs: cpqarray_init+0x0/0x29f()
[    7.568473] Calling initcall 0xffffffff81a3fb65: cciss_init+0x0/0x3b()
[    7.576473] HP CISS Driver (v 3.6.14)
[    7.576473] initcall 0xffffffff81a3fb65: cciss_init+0x0/0x3b() returned 0.
[    7.584474] initcall 0xffffffff81a3fb65 ran for 0 msecs: cciss_init+0x0/0x3b()
[    7.592474] Calling initcall 0xffffffff81a3fba0: nbd_init+0x0/0x2c3()
[    7.600475] nbd: registered device at major 43
[    7.604475] initcall 0xffffffff81a3fba0: nbd_init+0x0/0x2c3() returned 0.
[    7.612475] initcall 0xffffffff81a3fba0 ran for 3 msecs: nbd_init+0x0/0x2c3()
[    7.616476] Calling initcall 0xffffffff81a3fe63: init_cryptoloop+0x0/0x37()
[    7.620476] initcall 0xffffffff81a3fe63: init_cryptoloop+0x0/0x37() returned 0.
[    7.628476] initcall 0xffffffff81a3fe63 ran for 0 msecs: init_cryptoloop+0x0/0x37()
[    7.636477] Calling initcall 0xffffffff81a3fe9a: carm_init+0x0/0x20()
[    7.644477] initcall 0xffffffff81a3fe9a: carm_init+0x0/0x20() returned 0.
[    7.648478] initcall 0xffffffff81a3fe9a ran for 0 msecs: carm_init+0x0/0x20()
[    7.652478] Calling initcall 0xffffffff81a3ff3b: sm501_base_init+0x0/0x35()
[    7.660478] initcall 0xffffffff81a3ff3b: sm501_base_init+0x0/0x35() returned 0.
[    7.668479] initcall 0xffffffff81a3ff3b ran for 0 msecs: sm501_base_init+0x0/0x35()
[    7.676479] Calling initcall 0xffffffff81a3ff70: e1000_init_module+0x0/0x96()
[    7.680480] Intel(R) PRO/1000 Network Driver - version 7.3.20-k2
[    7.684480] Copyright (c) 1999-2006 Intel Corporation.
[    7.688480] initcall 0xffffffff81a3ff70: e1000_init_module+0x0/0x96() returned 0.
[    7.696481] initcall 0xffffffff81a3ff70 ran for 7 msecs: e1000_init_module+0x0/0x96()
[    7.704481] Calling initcall 0xffffffff81a40006: igb_init_module+0x0/0x51()
[    7.712482] Intel(R) Gigabit Ethernet Network Driver - version 1.0.8-k2
[    7.716482] Copyright (c) 2007 Intel Corporation.
[    7.720482] initcall 0xffffffff81a40006: igb_init_module+0x0/0x51() returned 0.
[    7.724482] initcall 0xffffffff81a40006 ran for 7 msecs: igb_init_module+0x0/0x51()
[    7.728483] Calling initcall 0xffffffff81a40057: ipg_init_module+0x0/0x29()
[    7.736483] initcall 0xffffffff81a40057: ipg_init_module+0x0/0x29() returned 0.
[    7.744484] initcall 0xffffffff81a40057 ran for 0 msecs: ipg_init_module+0x0/0x29()
[    7.752484] Calling initcall 0xffffffff81a40080: bonding_init+0x0/0x93b()
[    7.760485] Ethernet Channel Bonding Driver: v3.2.5 (March 21, 2008)
[    7.764485] bonding: Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.
[    7.772485] initcall 0xffffffff81a40080: bonding_init+0x0/0x93b() returned 0.
[    7.776486] initcall 0xffffffff81a40080 ran for 11 msecs: bonding_init+0x0/0x93b()
[    7.780486] Calling initcall 0xffffffff81a409bb: atl1_init_module+0x0/0x20()
[    7.788486] initcall 0xffffffff81a409bb: atl1_init_module+0x0/0x20() returned 0.
[    7.796487] initcall 0xffffffff81a409bb ran for 0 msecs: atl1_init_module+0x0/0x20()
[    7.804487] Calling initcall 0xffffffff81a40ac9: plip_init+0x0/0x76()
[    7.808488] plip: parport0 has no IRQ. Using IRQ-less mode,which is fairly inefficient!
[    7.816488] NET3 PLIP version 2.4-parport gniibe@mri.co.jp
[    7.820488] plip0: Parallel port at 0x378, not using IRQ.
[    7.824489] initcall 0xffffffff81a40ac9: plip_init+0x0/0x76() returned 0.
[    7.832489] initcall 0xffffffff81a40ac9 ran for 15 msecs: plip_init+0x0/0x76()
[    7.840490] Calling initcall 0xffffffff81a40b3f: rr_init_module+0x0/0x20()
[    7.848490] initcall 0xffffffff81a40b3f: rr_init_module+0x0/0x20() returned 0.
[    7.852490] initcall 0xffffffff81a40b3f ran for 0 msecs: rr_init_module+0x0/0x20()
[    7.856491] Calling initcall 0xffffffff81a40b5f: vortex_init+0x0/0xb5()
[    7.864491] initcall 0xffffffff81a40b5f: vortex_init+0x0/0xb5() returned 0.
[    7.872492] initcall 0xffffffff81a40b5f ran for 0 msecs: vortex_init+0x0/0xb5()
[    7.880492] Calling initcall 0xffffffff81a40c14: typhoon_init+0x0/0x20()
[    7.884492] initcall 0xffffffff81a40c14: typhoon_init+0x0/0x20() returned 0.
[    7.892493] initcall 0xffffffff81a40c14 ran for 0 msecs: typhoon_init+0x0/0x20()
[    7.900493] Calling initcall 0xffffffff81a40c34: ne2k_pci_init+0x0/0x20()
[    7.908494] initcall 0xffffffff81a40c34: ne2k_pci_init+0x0/0x20() returned 0.
[    7.912494] initcall 0xffffffff81a40c34 ran for 0 msecs: ne2k_pci_init+0x0/0x20()
[    7.916494] Calling initcall 0xffffffff81a40c54: eepro100_init_module+0x0/0x20()
[    7.924495] initcall 0xffffffff81a40c54: eepro100_init_module+0x0/0x20() returned 0.
[    7.932495] initcall 0xffffffff81a40c54 ran for 0 msecs: eepro100_init_module+0x0/0x20()
[    7.940496] Calling initcall 0xffffffff81a40c74: e100_init_module+0x0/0x62()
[    7.948496] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[    7.952497] e100: Copyright(c) 1999-2006 Intel Corporation
[    7.956497] initcall 0xffffffff81a40c74: e100_init_module+0x0/0x62() returned 0.
[    7.964497] initcall 0xffffffff81a40c74 ran for 7 msecs: e100_init_module+0x0/0x62()
[    7.972498] Calling initcall 0xffffffff81a40cd6: epic_init+0x0/0x20()
[    7.976498] initcall 0xffffffff81a40cd6: epic_init+0x0/0x20() returned 0.
[    7.984499] initcall 0xffffffff81a40cd6 ran for 0 msecs: epic_init+0x0/0x20()
[    7.992499] Calling initcall 0xffffffff81a40cf6: yellowfin_init+0x0/0x20()
[    7.996499] initcall 0xffffffff81a40cf6: yellowfin_init+0x0/0x20() returned 0.
[    8.004500] initcall 0xffffffff81a40cf6 ran for 0 msecs: yellowfin_init+0x0/0x20()
[    8.008500] Calling initcall 0xffffffff81a40d16: acenic_init+0x0/0x20()
[    8.016501] initcall 0xffffffff81a40d16: acenic_init+0x0/0x20() returned 0.
[    8.024501] initcall 0xffffffff81a40d16 ran for 0 msecs: acenic_init+0x0/0x20()
[    8.028501] Calling initcall 0xffffffff81a40d36: natsemi_init_mod+0x0/0x20()
[    8.036502] initcall 0xffffffff81a40d36: natsemi_init_mod+0x0/0x20() returned 0.
[    8.044502] initcall 0xffffffff81a40d36 ran for 0 msecs: natsemi_init_mod+0x0/0x20()
[    8.052503] Calling initcall 0xffffffff81a40d56: ns83820_init+0x0/0x2e()
[    8.060503] ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
[    8.064504] initcall 0xffffffff81a40d56: ns83820_init+0x0/0x2e() returned 0.
[    8.072504] initcall 0xffffffff81a40d56 ran for 3 msecs: ns83820_init+0x0/0x2e()
[    8.080505] Calling initcall 0xffffffff81a40d84: fealnx_init+0x0/0x20()
[    8.088505] initcall 0xffffffff81a40d84: fealnx_init+0x0/0x20() returned 0.
[    8.092505] initcall 0xffffffff81a40d84 ran for 0 msecs: fealnx_init+0x0/0x20()
[    8.096506] Calling initcall 0xffffffff81a40da4: tg3_init+0x0/0x20()
[    8.104506] initcall 0xffffffff81a40da4: tg3_init+0x0/0x20() returned 0.
[    8.112507] initcall 0xffffffff81a40da4 ran for 0 msecs: tg3_init+0x0/0x20()
[    8.116507] Calling initcall 0xffffffff81a40dc4: bnx2_init+0x0/0x20()
[    8.124507] initcall 0xffffffff81a40dc4: bnx2_init+0x0/0x20() returned 0.
[    8.132508] initcall 0xffffffff81a40dc4 ran for 0 msecs: bnx2_init+0x0/0x20()
[    8.136508] Calling initcall 0xffffffff81a40de4: skge_init+0x0/0x2e()
[    8.140508] sk98lin: driver has been replaced by the skge driver and is scheduled for removal
[    8.144509] initcall 0xffffffff81a40de4: skge_init+0x0/0x2e() returned 0.
[    8.152509] initcall 0xffffffff81a40de4 ran for 3 msecs: skge_init+0x0/0x2e()
[    8.160510] Calling initcall 0xffffffff81a40e12: rhine_init+0x0/0x72()
[    8.164510] initcall 0xffffffff81a40e12: rhine_init+0x0/0x72() returned 0.
[    8.172510] initcall 0xffffffff81a40e12 ran for 0 msecs: rhine_init+0x0/0x72()
[    8.180511] Calling initcall 0xffffffff81a40e84: sundance_init+0x0/0x20()
[    8.188511] initcall 0xffffffff81a40e84: sundance_init+0x0/0x20() returned 0.
[    8.192512] initcall 0xffffffff81a40e84 ran for 0 msecs: sundance_init+0x0/0x20()
[    8.196512] Calling initcall 0xffffffff81a40ea4: hamachi_init+0x0/0x2c()
[    8.204512] initcall 0xffffffff81a40ea4: hamachi_init+0x0/0x2c() returned 0.
[    8.212513] initcall 0xffffffff81a40ea4 ran for 0 msecs: hamachi_init+0x0/0x2c()
[    8.220513] Calling initcall 0xffffffff81a40f39: net_olddevs_init+0x0/0xab()
[    8.224514] initcall 0xffffffff81a40f39: net_olddevs_init+0x0/0xab() returned 0.
[    8.232514] initcall 0xffffffff81a40f39 ran for 0 msecs: net_olddevs_init+0x0/0xab()
[    8.236514] Calling initcall 0xffffffff81a41091: sb1000_init+0x0/0x17()
[    8.244515] initcall 0xffffffff81a41091: sb1000_init+0x0/0x17() returned 0.
[    8.252515] initcall 0xffffffff81a41091 ran for 0 msecs: sb1000_init+0x0/0x17()
[    8.256516] Calling initcall 0xffffffff81a410a8: init_nic+0x0/0x20()
[    8.260516] forcedeth: Reverse Engineered nForce ethernet driver. Version 0.61.
[    8.264516] PCI: Setting latency timer of device 0000:00:0a.0 to 64
[    8.792549] forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x5043 @ 1, addr 00:13:d4:dc:41:12
[    8.796549] forcedeth 0000:00:0a.0: highdma csum timirq gbit lnktim desc-v3
[    8.800550] initcall 0xffffffff81a410a8: init_nic+0x0/0x20() returned 0.
[    8.808550] initcall 0xffffffff81a410a8 ran for 514 msecs: init_nic+0x0/0x20()
[    8.816551] Calling initcall 0xffffffff81a410c8: ql3xxx_init_module+0x0/0x20()
[    8.824551] initcall 0xffffffff81a410c8: ql3xxx_init_module+0x0/0x20() returned 0.
[    8.832552] initcall 0xffffffff81a410c8 ran for 0 msecs: ql3xxx_init_module+0x0/0x20()
[    8.840552] Calling initcall 0xffffffff81a410e8: dummy_init_module+0x0/0xe6()
[    8.848553] initcall 0xffffffff81a410e8: dummy_init_module+0x0/0xe6() returned 0.
[    8.852553] initcall 0xffffffff81a410e8 ran for 3 msecs: dummy_init_module+0x0/0xe6()
[    8.856553] Calling initcall 0xffffffff81a411ce: de600_init+0x0/0x39c()
[    8.864554] DE600: port 0x378 busy
[    8.868554] initcall 0xffffffff81a411ce: de600_init+0x0/0x39c() returned -16.
[    8.876554] initcall 0xffffffff81a411ce ran for 3 msecs: de600_init+0x0/0x39c()
[    8.884555] initcall at 0xffffffff81a411ce: de600_init+0x0/0x39c(): returned with error code -16
[    8.892555] Calling initcall 0xffffffff81a4156a: rtl8139_init_module+0x0/0x20()
[    8.900556] 8139too Fast Ethernet driver 0.9.28
[    8.904556] eth1: RealTek RTL8139 at 0xc000, 00:c0:df:03:68:5d, IRQ 11
[    8.908556] eth1:  Identified 8139 chip type 'RTL-8139B'
[    8.912557] initcall 0xffffffff81a4156a: rtl8139_init_module+0x0/0x20() returned 0.
[    8.920557] initcall 0xffffffff81a4156a ran for 11 msecs: rtl8139_init_module+0x0/0x20()
[    8.928558] Calling initcall 0xffffffff81a4158a: sc92031_init+0x0/0x2e()
[    8.932558] Silan SC92031 PCI Fast Ethernet Adapter driver 2.0c
[    8.936558] initcall 0xffffffff81a4158a: sc92031_init+0x0/0x2e() returned 0.
[    8.944559] initcall 0xffffffff81a4158a ran for 3 msecs: sc92031_init+0x0/0x2e()
[    8.952559] Calling initcall 0xffffffff81a415b8: veth_init+0x0/0x23()
[    8.956559] initcall 0xffffffff81a415b8: veth_init+0x0/0x23() returned 0.
[    8.964560] initcall 0xffffffff81a415b8 ran for 0 msecs: veth_init+0x0/0x23()
[    8.972560] Calling initcall 0xffffffff81a415db: rio_init+0x0/0x20()
[    8.976561] initcall 0xffffffff81a415db: rio_init+0x0/0x20() returned 0.
[    8.984561] initcall 0xffffffff81a415db ran for 0 msecs: rio_init+0x0/0x20()
[    8.992562] Calling initcall 0xffffffff81a415fb: rtl8169_init_module+0x0/0x20()
[    9.000562] initcall 0xffffffff81a415fb: rtl8169_init_module+0x0/0x20() returned 0.
[    9.008563] initcall 0xffffffff81a415fb ran for 0 msecs: rtl8169_init_module+0x0/0x20()
[    9.016563] Calling initcall 0xffffffff81a4161b: amd8111e_init+0x0/0x20()
[    9.020563] initcall 0xffffffff81a4161b: amd8111e_init+0x0/0x20() returned 0.
[    9.028564] initcall 0xffffffff81a4161b ran for 0 msecs: amd8111e_init+0x0/0x20()
[    9.036564] Calling initcall 0xffffffff81a4163b: ipddp_init_module+0x0/0x127()
[    9.044565] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[    9.048565] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[    9.052565] initcall 0xffffffff81a4163b: ipddp_init_module+0x0/0x127() returned 0.
[    9.060566] initcall 0xffffffff81a4163b ran for 7 msecs: ipddp_init_module+0x0/0x127()
[    9.068566] Calling initcall 0xffffffff81a41762: sync_ppp_init+0x0/0x65()
[    9.072567] Cronyx Ltd, Synchronous PPP and CISCO HDLC (c) 1994
[    9.072567] Linux port (c) 1998 Building Number Three Ltd & Jan "Yenya" Kasprzak.
[    9.076567] initcall 0xffffffff81a41762: sync_ppp_init+0x0/0x65() returned 0.
[    9.084567] initcall 0xffffffff81a41762 ran for 3 msecs: sync_ppp_init+0x0/0x65()
[    9.092568] Calling initcall 0xffffffff81a417c7: init_lmc+0x0/0x20()
[    9.096568] initcall 0xffffffff81a417c7: init_lmc+0x0/0x20() returned 0.
[    9.104569] initcall 0xffffffff81a417c7 ran for 0 msecs: init_lmc+0x0/0x20()
[    9.112569] Calling initcall 0xffffffff81a417e7: arcnet_init+0x0/0x71()
[    9.116569] arcnet loaded.
[    9.120570] initcall 0xffffffff81a417e7: arcnet_init+0x0/0x71() returned 0.
[    9.128570] initcall 0xffffffff81a417e7 ran for 3 msecs: arcnet_init+0x0/0x71()
[    9.136571] Calling initcall 0xffffffff81a41858: arcnet_rfc1051_init+0x0/0x50()
[    9.140571] arcnet: RFC1051 "simple standard" (`s') encapsulation support loaded.
[    9.144571] initcall 0xffffffff81a41858: arcnet_rfc1051_init+0x0/0x50() returned 0.
[    9.152572] initcall 0xffffffff81a41858 ran for 3 msecs: arcnet_rfc1051_init+0x0/0x50()
[    9.160572] Calling initcall 0xffffffff81a418a8: arcnet_raw_init+0x0/0x82()
[    9.168573] arcnet: raw mode (`r') encapsulation support loaded.
[    9.172573] initcall 0xffffffff81a418a8: arcnet_raw_init+0x0/0x82() returned 0.
[    9.180573] initcall 0xffffffff81a418a8 ran for 3 msecs: arcnet_raw_init+0x0/0x82()
[    9.184574] Calling initcall 0xffffffff81a4192a: catc_init+0x0/0x47()
[    9.192574] usbcore: registered new interface driver catc
[    9.196574] drivers/net/usb/catc.c: v2.8 CATC EL1210A NetMate USB Ethernet driver
[    9.200575] initcall 0xffffffff81a4192a: catc_init+0x0/0x47() returned 0.
[    9.208575] initcall 0xffffffff81a4192a ran for 7 msecs: catc_init+0x0/0x47()
[    9.212575] Calling initcall 0xffffffff81a41971: kaweth_init+0x0/0x35()
[    9.216576] drivers/net/usb/kaweth.c: Driver loading
[    9.220576] usbcore: registered new interface driver kaweth
[    9.224576] initcall 0xffffffff81a41971: kaweth_init+0x0/0x35() returned 0.
[    9.232577] initcall 0xffffffff81a41971 ran for 7 msecs: kaweth_init+0x0/0x35()
[    9.236577] Calling initcall 0xffffffff81a419a6: pegasus_init+0x0/0x1da()
[    9.244577] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethernet driver
[    9.248578] usbcore: registered new interface driver pegasus
[    9.252578] initcall 0xffffffff81a419a6: pegasus_init+0x0/0x1da() returned 0.
[    9.260578] initcall 0xffffffff81a419a6 ran for 7 msecs: pegasus_init+0x0/0x1da()
[    9.268579] Calling initcall 0xffffffff81a41b80: usb_rtl8150_init+0x0/0x35()
[    9.276579] drivers/net/usb/rtl8150.c: rtl8150 based usb-ethernet driver v0.6.2 (2004/08/27)
[    9.280580] usbcore: registered new interface driver rtl8150
[    9.284580] initcall 0xffffffff81a41b80: usb_rtl8150_init+0x0/0x35() returned 0.
[    9.292580] initcall 0xffffffff81a41b80 ran for 7 msecs: usb_rtl8150_init+0x0/0x35()
[    9.296581] Calling initcall 0xffffffff81a41bb5: dmfe_init_module+0x0/0xfc()
[    9.304581] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
[    9.308581] initcall 0xffffffff81a41bb5: dmfe_init_module+0x0/0xfc() returned 0.
[    9.312582] initcall 0xffffffff81a41bb5 ran for 3 msecs: dmfe_init_module+0x0/0xfc()
[    9.316582] Calling initcall 0xffffffff81a41cb1: de_init+0x0/0x20()
[    9.320582] initcall 0xffffffff81a41cb1: de_init+0x0/0x20() returned 0.
[    9.328583] initcall 0xffffffff81a41cb1 ran for 0 msecs: de_init+0x0/0x20()
[    9.332583] Calling initcall 0xffffffff81a41cd1: tulip_init+0x0/0x38()
[    9.340583] initcall 0xffffffff81a41cd1: tulip_init+0x0/0x38() returned 0.
[    9.348584] initcall 0xffffffff81a41cd1 ran for 0 msecs: tulip_init+0x0/0x38()
[    9.356584] Calling initcall 0xffffffff81a41d09: de4x5_module_init+0x0/0x20()
[    9.360585] initcall 0xffffffff81a41d09: de4x5_module_init+0x0/0x20() returned 0.
[    9.368585] initcall 0xffffffff81a41d09 ran for 0 msecs: de4x5_module_init+0x0/0x20()
[    9.372585] Calling initcall 0xffffffff81a41d29: uli526x_init_module+0x0/0xb7()
[    9.380586] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
[    9.384586] initcall 0xffffffff81a41d29: uli526x_init_module+0x0/0xb7() returned 0.
[    9.392587] initcall 0xffffffff81a41d29 ran for 3 msecs: uli526x_init_module+0x0/0xb7()
[    9.400587] Calling initcall 0xffffffff81a41de0: mkiss_init_driver+0x0/0x50()
[    9.408588] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[    9.412588] initcall 0xffffffff81a41de0: mkiss_init_driver+0x0/0x50() returned 0.
[    9.420588] initcall 0xffffffff81a41de0 ran for 3 msecs: mkiss_init_driver+0x0/0x50()
[    9.428589] Calling initcall 0xffffffff81a41ea3: init_baycomserfdx+0x0/0x119()
[    9.432589] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    9.432589] baycom_ser_fdx: version 0.10 compiled 10:54:14 Apr 17 2008
[    9.436589] initcall 0xffffffff81a41ea3: init_baycomserfdx+0x0/0x119() returned 0.
[    9.444590] initcall 0xffffffff81a41ea3 ran for 3 msecs: init_baycomserfdx+0x0/0x119()
[    9.452590] Calling initcall 0xffffffff81a41fbc: hdlcdrv_init_driver+0x0/0x34()
[    9.460591] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    9.464591] hdlcdrv: version 0.8 compiled 10:54:12 Apr 17 2008
[    9.468591] initcall 0xffffffff81a41fbc: hdlcdrv_init_driver+0x0/0x34() returned 0.
[    9.476592] initcall 0xffffffff81a41fbc ran for 7 msecs: hdlcdrv_init_driver+0x0/0x34()
[    9.484592] Calling initcall 0xffffffff81a42052: init_baycomserhdx+0x0/0x10e()
[    9.488593] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    9.488593] baycom_ser_hdx: version 0.10 compiled 10:54:12 Apr 17 2008
[    9.492593] initcall 0xffffffff81a42052: init_baycomserhdx+0x0/0x10e() returned 0.
[    9.500593] initcall 0xffffffff81a42052 ran for 3 msecs: init_baycomserhdx+0x0/0x10e()
[    9.508594] Calling initcall 0xffffffff81a421bc: init_baycompar+0x0/0x104()
[    9.516594] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    9.516594] baycom_par: version 0.9 compiled 10:54:13 Apr 17 2008
[    9.520595] initcall 0xffffffff81a421bc: init_baycompar+0x0/0x104() returned 0.
[    9.528595] initcall 0xffffffff81a421bc ran for 3 msecs: init_baycompar+0x0/0x104()
[    9.536596] Calling initcall 0xffffffff81a422c0: usb_irda_init+0x0/0x43()
[    9.544596] usbcore: registered new interface driver irda-usb
[    9.548596] USB IrDA support registered
[    9.552597] initcall 0xffffffff81a422c0: usb_irda_init+0x0/0x43() returned 0.
[    9.560597] initcall 0xffffffff81a422c0 ran for 7 msecs: usb_irda_init+0x0/0x43()
[    9.568598] Calling initcall 0xffffffff81a42303: stir_init+0x0/0x2d()
[    9.572598] usbcore: registered new interface driver stir4200
[    9.576598] initcall 0xffffffff81a42303: stir_init+0x0/0x2d() returned 0.
[    9.580598] initcall 0xffffffff81a42303 ran for 3 msecs: stir_init+0x0/0x2d()
[    9.584599] Calling initcall 0xffffffff81a42330: w83977af_init+0x0/0x590()
[    9.592599] w83977af_init()
[    9.596599] w83977af_open()
[    9.596599] w83977af_probe()
[    9.600600] w83977af_probe(), Wrong chip version<7>w83977af_probe()
[    9.608600] w83977af_probe(), Wrong chip versioninitcall 0xffffffff81a42330: w83977af_init+0x0/0x590() returned -19.
[    9.616601] initcall 0xffffffff81a42330 ran for 19 msecs: w83977af_init+0x0/0x590()
[    9.620601] Calling initcall 0xffffffff81a436ad: smsc_ircc_init+0x0/0x68c()
[    9.628601] initcall 0xffffffff81a436ad: smsc_ircc_init+0x0/0x68c() returned -19.
[    9.636602] initcall 0xffffffff81a436ad ran for 0 msecs: smsc_ircc_init+0x0/0x68c()
[    9.644602] Calling initcall 0xffffffff81a441d0: vlsi_mod_init+0x0/0x151()
[    9.652603] initcall 0xffffffff81a441d0: vlsi_mod_init+0x0/0x151() returned 0.
[    9.656603] initcall 0xffffffff81a441d0 ran for 0 msecs: vlsi_mod_init+0x0/0x151()
[    9.660603] Calling initcall 0xffffffff81a44321: via_ircc_init+0x0/0x64()
[    9.668604] initcall 0xffffffff81a44321: via_ircc_init+0x0/0x64() returned 0.
[    9.676604] initcall 0xffffffff81a44321 ran for 0 msecs: via_ircc_init+0x0/0x64()
[    9.684605] Calling initcall 0xffffffff81a44385: irtty_sir_init+0x0/0x50()
[    9.688605] initcall 0xffffffff81a44385: irtty_sir_init+0x0/0x50() returned 0.
[    9.696606] initcall 0xffffffff81a44385 ran for 0 msecs: irtty_sir_init+0x0/0x50()
[    9.700606] Calling initcall 0xffffffff81a443d5: sir_wq_init+0x0/0x33()
[    9.708606] initcall 0xffffffff81a443d5: sir_wq_init+0x0/0x33() returned 0.
[    9.716607] initcall 0xffffffff81a443d5 ran for 0 msecs: sir_wq_init+0x0/0x33()
[    9.720607] Calling initcall 0xffffffff81a44408: esi_sir_init+0x0/0x17()
[    9.724607] irda_register_dongle : registering dongle "JetEye PC ESI-9680 PC" (1).
[    9.728608] initcall 0xffffffff81a44408: esi_sir_init+0x0/0x17() returned 0.
[    9.736608] initcall 0xffffffff81a44408 ran for 3 msecs: esi_sir_init+0x0/0x17()
[    9.744609] Calling initcall 0xffffffff81a4441f: tekram_sir_init+0x0/0x56()
[    9.748609] irda_register_dongle : registering dongle "Tekram IR-210B" (0).
[    9.752609] initcall 0xffffffff81a4441f: tekram_sir_init+0x0/0x56() returned 0.
[    9.760610] initcall 0xffffffff81a4441f ran for 3 msecs: tekram_sir_init+0x0/0x56()
[    9.768610] Clocksource tsc unstable (delta = 95409664 ns)
[    9.772610] Calling initcall 0xffffffff81a44475: actisys_sir_init+0x0/0x52()
[    9.780611] irda_register_dongle : registering dongle "Actisys ACT-220L" (2).
[    9.784611] irda_register_dongle : registering dongle "Actisys ACT-220L+" (3).
[    9.788611] initcall 0xffffffff81a44475: actisys_sir_init+0x0/0x52() returned 0.
[    9.792612] initcall 0xffffffff81a44475 ran for 7 msecs: actisys_sir_init+0x0/0x52()
[    9.796612] Calling initcall 0xffffffff81a444c7: old_belkin_sir_init+0x0/0x17()
[    9.800612] irda_register_dongle : registering dongle "Old Belkin SmartBeam" (7).
[    9.804612] initcall 0xffffffff81a444c7: old_belkin_sir_init+0x0/0x17() returned 0.
[    9.812613] initcall 0xffffffff81a444c7 ran for 3 msecs: old_belkin_sir_init+0x0/0x17()
[    9.820613] Calling initcall 0xffffffff81a444de: act200l_sir_init+0x0/0x17()
[    9.828614] irda_register_dongle : registering dongle "ACTiSYS ACT-IR200L" (10).
[    9.832614] initcall 0xffffffff81a444de: act200l_sir_init+0x0/0x17() returned 0.
[    9.840615] initcall 0xffffffff81a444de ran for 3 msecs: act200l_sir_init+0x0/0x17()
[    9.844615] Calling initcall 0xffffffff81a444f5: ma600_sir_init+0x0/0x35()
[    9.848615] irda_register_dongle : registering dongle "MA600" (11).
[    9.852615] initcall 0xffffffff81a444f5: ma600_sir_init+0x0/0x35() returned 0.
[    9.860616] initcall 0xffffffff81a444f5 ran for 3 msecs: ma600_sir_init+0x0/0x35()
[    9.864616] Calling initcall 0xffffffff81a4452a: toim3232_sir_init+0x0/0x56()
[    9.868616] irda_register_dongle : registering dongle "Vishay TOIM3232" (12).
[    9.872617] initcall 0xffffffff81a4452a: toim3232_sir_init+0x0/0x56() returned 0.
[    9.880617] initcall 0xffffffff81a4452a ran for 3 msecs: toim3232_sir_init+0x0/0x56()
[    9.888618] Calling initcall 0xffffffff81a44580: kingsun_init+0x0/0x20()
[    9.896618] usbcore: registered new interface driver kingsun-sir
[    9.900618] initcall 0xffffffff81a44580: kingsun_init+0x0/0x20() returned 0.
[    9.908619] initcall 0xffffffff81a44580 ran for 3 msecs: kingsun_init+0x0/0x20()
[    9.916619] Calling initcall 0xffffffff81a445c4: init_netconsole+0x0/0x25c()
[    9.924620] console [netcon0] enabled
[    9.928620] netconsole: network logging started
[    9.932620] initcall 0xffffffff81a445c4: init_netconsole+0x0/0x25c() returned 0.
[    9.940621] initcall 0xffffffff81a445c4 ran for 7 msecs: init_netconsole+0x0/0x25c()
[    9.948621] Calling initcall 0xffffffff81a44820: init+0x0/0x17()
[    9.952622] initcall 0xffffffff81a44820: init+0x0/0x17() returned 0.
[    9.960622] initcall 0xffffffff81a44820 ran for 0 msecs: init+0x0/0x17()
[    9.964622] Calling initcall 0xffffffff81a44910: zatm_init_module+0x0/0x20()
[    9.968623] initcall 0xffffffff81a44910: zatm_init_module+0x0/0x20() returned 0.
[    9.976623] initcall 0xffffffff81a44910 ran for 0 msecs: zatm_init_module+0x0/0x20()
[    9.984624] Calling initcall 0xffffffff81a44930: uPD98402_module_init+0x0/0x10()
[    9.992624] initcall 0xffffffff81a44930: uPD98402_module_init+0x0/0x10() returned 0.
[   10.000625] initcall 0xffffffff81a44930 ran for 0 msecs: uPD98402_module_init+0x0/0x10()
[   10.008625] Calling initcall 0xffffffff81a44a48: fore200e_module_init+0x0/0x13a()
[   10.016626] fore200e: FORE Systems 200E-series ATM driver - version 0.3e
[   10.020626] initcall 0xffffffff81a44a48: fore200e_module_init+0x0/0x13a() returned 0.
[   10.028626] initcall 0xffffffff81a44a48 ran for 3 msecs: fore200e_module_init+0x0/0x13a()
[   10.032627] Calling initcall 0xffffffff81a44b82: firestream_init_module+0x0/0x20()
[   10.036627] initcall 0xffffffff81a44b82: firestream_init_module+0x0/0x20() returned 0.
[   10.044627] initcall 0xffffffff81a44b82 ran for 0 msecs: firestream_init_module+0x0/0x20()
[   10.048628] Calling initcall 0xffffffff81a44ba2: lanai_module_init+0x0/0x4e()
[   10.052628] initcall 0xffffffff81a44ba2: lanai_module_init+0x0/0x4e() returned 0.
[   10.060628] initcall 0xffffffff81a44ba2 ran for 0 msecs: lanai_module_init+0x0/0x4e()
[   10.068629] Calling initcall 0xffffffff81a44f29: scsi_tgt_init+0x0/0x8d()
[   10.076629] initcall 0xffffffff81a44f29: scsi_tgt_init+0x0/0x8d() returned 0.
[   10.084630] initcall 0xffffffff81a44f29 ran for 0 msecs: scsi_tgt_init+0x0/0x8d()
[   10.088630] Calling initcall 0xffffffff81a44fb6: raid_init+0x0/0x17()
[   10.092630] initcall 0xffffffff81a44fb6: raid_init+0x0/0x17() returned 0.
[   10.100631] initcall 0xffffffff81a44fb6 ran for 0 msecs: raid_init+0x0/0x17()
[   10.108631] Calling initcall 0xffffffff81a44fcd: spi_transport_init+0x0/0x35()
[   10.112632] initcall 0xffffffff81a44fcd: spi_transport_init+0x0/0x35() returned 0.
[   10.120632] initcall 0xffffffff81a44fcd ran for 0 msecs: spi_transport_init+0x0/0x35()
[   10.124632] Calling initcall 0xffffffff81a45002: fc_transport_init+0x0/0x53()
[   10.132633] initcall 0xffffffff81a45002: fc_transport_init+0x0/0x53() returned 0.
[   10.140633] initcall 0xffffffff81a45002 ran for 0 msecs: fc_transport_init+0x0/0x53()
[   10.148634] Calling initcall 0xffffffff81a45055: iscsi_transport_init+0x0/0x129()
[   10.156634] Loading iSCSI transport class v2.0-869.
[   10.160635] initcall 0xffffffff81a45055: iscsi_transport_init+0x0/0x129() returned 0.
[   10.168635] initcall 0xffffffff81a45055 ran for 3 msecs: iscsi_transport_init+0x0/0x129()
[   10.176636] Calling initcall 0xffffffff81a4517e: sas_transport_init+0x0/0xc8()
[   10.184636] initcall 0xffffffff81a4517e: sas_transport_init+0x0/0xc8() returned 0.
[   10.192637] initcall 0xffffffff81a4517e ran for 0 msecs: sas_transport_init+0x0/0xc8()
[   10.200637] Calling initcall 0xffffffff81a45246: sas_class_init+0x0/0x36()
[   10.208638] initcall 0xffffffff81a45246: sas_class_init+0x0/0x36() returned 0.
[   10.212638] initcall 0xffffffff81a45246 ran for 0 msecs: sas_class_init+0x0/0x36()
[   10.216638] Calling initcall 0xffffffff806bcc53: arcmsr_module_init+0x0/0x20()
[   10.224639] initcall 0xffffffff806bcc53: arcmsr_module_init+0x0/0x20() returned 0.
[   10.232639] initcall 0xffffffff806bcc53 ran for 0 msecs: arcmsr_module_init+0x0/0x20()
[   10.240640] Calling initcall 0xffffffff81a4527c: ahc_linux_init+0x0/0x5e()
[   10.248640] initcall 0xffffffff81a4527c: ahc_linux_init+0x0/0x5e() returned 0.
[   10.256641] initcall 0xffffffff81a4527c ran for 0 msecs: ahc_linux_init+0x0/0x5e()
[   10.264641] Calling initcall 0xffffffff81a452da: aac_init+0x0/0x73()
[   10.268641] Adaptec aacraid driver 1.1-5[2455]-ms
[   10.272642] initcall 0xffffffff81a452da: aac_init+0x0/0x73() returned 0.
[   10.280642] initcall 0xffffffff81a452da ran for 3 msecs: aac_init+0x0/0x73()
[   10.288643] Calling initcall 0xffffffff81a4534d: init_this_scsi_driver+0x0/0x113()
[   10.296643] initcall 0xffffffff81a4534d: init_this_scsi_driver+0x0/0x113() returned -19.
[   10.304644] initcall 0xffffffff81a4534d ran for 0 msecs: init_this_scsi_driver+0x0/0x113()
[   10.312644] Calling initcall 0xffffffff81a45460: ips_module_init+0x0/0x220()
[   10.320645] initcall 0xffffffff81a45460: ips_module_init+0x0/0x220() returned -19.
[   10.324645] initcall 0xffffffff81a45460 ran for 0 msecs: ips_module_init+0x0/0x220()
[   10.328645] Calling initcall 0xffffffff81a45876: qla1280_init+0x0/0x20()
[   10.332645] initcall 0xffffffff81a45876: qla1280_init+0x0/0x20() returned 0.
[   10.340646] initcall 0xffffffff81a45876 ran for 0 msecs: qla1280_init+0x0/0x20()
[   10.348646] Calling initcall 0xffffffff81a45896: qla4xxx_module_init+0x0/0x12e()
[   10.356647] iscsi: registered transport (qla4xxx)
[   10.360647] QLogic iSCSI HBA Driver
[   10.364647] initcall 0xffffffff81a45896: qla4xxx_module_init+0x0/0x12e() returned 0.
[   10.372648] initcall 0xffffffff81a45896 ran for 7 msecs: qla4xxx_module_init+0x0/0x12e()
[   10.380648] Calling initcall 0xffffffff81a459c4: lpfc_init+0x0/0xdc()
[   10.384649] Emulex LightPulse Fibre Channel SCSI driver 8.2.5
[   10.388649] Copyright(c) 2004-2008 Emulex.  All rights reserved.
[   10.392649] initcall 0xffffffff81a459c4: lpfc_init+0x0/0xdc() returned 0.
[   10.400650] initcall 0xffffffff81a459c4 ran for 7 msecs: lpfc_init+0x0/0xdc()
[   10.408650] Calling initcall 0xffffffff81a45aa0: init_this_scsi_driver+0x0/0x105()
[   10.416651] initcall 0xffffffff81a45aa0: init_this_scsi_driver+0x0/0x105() returned -19.
[   10.424651] initcall 0xffffffff81a45aa0 ran for 0 msecs: init_this_scsi_driver+0x0/0x105()
[   10.432652] Calling initcall 0xffffffff81a45ba5: dc390_module_init+0x0/0x97()
[   10.440652] DC390: clustering now enabled by default. If you get problems load
[   10.440652] 	with "disable_clustering=1" and report to maintainers
[   10.444652] initcall 0xffffffff81a45ba5: dc390_module_init+0x0/0x97() returned 0.
[   10.452653] initcall 0xffffffff81a45ba5 ran for 3 msecs: dc390_module_init+0x0/0x97()
[   10.460653] Calling initcall 0xffffffff81a45c9d: megaraid_init+0x0/0xd3()
[   10.464654] initcall 0xffffffff81a45c9d: megaraid_init+0x0/0xd3() returned 0.
[   10.472654] initcall 0xffffffff81a45c9d ran for 0 msecs: megaraid_init+0x0/0xd3()
[   10.476654] Calling initcall 0xffffffff81a46f10: gdth_init+0x0/0x1176()
[   10.484655] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[   10.488655] GDT-HA: Found 0 PCI Storage RAID Controllers
[   10.492655] initcall 0xffffffff81a46f10: gdth_init+0x0/0x1176() returned -19.
[   10.496656] initcall 0xffffffff81a46f10 ran for 7 msecs: gdth_init+0x0/0x1176()
[   10.500656] Calling initcall 0xffffffff81a48086: twa_init+0x0/0x35()
[   10.508656] 3ware 9000 Storage Controller device driver for Linux v2.26.02.010.
[   10.512657] initcall 0xffffffff81a48086: twa_init+0x0/0x35() returned 0.
[   10.516657] initcall 0xffffffff81a48086 ran for 3 msecs: twa_init+0x0/0x35()
[   10.520657] Calling initcall 0xffffffff81a480bb: ppa_driver_init+0x0/0x2c()
[   10.528658] ppa: Version 2.07 (for Linux 2.4.x)
[   10.536658] initcall 0xffffffff81a480bb: ppa_driver_init+0x0/0x2c() returned 0.
[   10.540658] initcall 0xffffffff81a480bb ran for 7 msecs: ppa_driver_init+0x0/0x2c()
[   10.544659] Calling initcall 0xffffffff81a480e7: stex_init+0x0/0x39()
[   10.552659] stex: Promise SuperTrak EX Driver version: 3.6.0000.1
[   10.556659] initcall 0xffffffff81a480e7: stex_init+0x0/0x39() returned 0.
[   10.560660] initcall 0xffffffff81a480e7 ran for 3 msecs: stex_init+0x0/0x39()
[   10.564660] Calling initcall 0xffffffff81a4825f: init_st+0x0/0x1a7()
[   10.572660] st: Version 20080221, fixed bufsize 32768, s/g segs 256
[   10.576661] Driver 'st' needs updating - please use bus_type methods
[   10.580661] initcall 0xffffffff81a4825f: init_st+0x0/0x1a7() returned 0.
[   10.584661] initcall 0xffffffff81a4825f ran for 7 msecs: init_st+0x0/0x1a7()
[   10.588661] Calling initcall 0xffffffff81a48406: init_sd+0x0/0xf5()
[   10.596662] Driver 'sd' needs updating - please use bus_type methods
[   10.600662] initcall 0xffffffff81a48406: init_sd+0x0/0xf5() returned 0.
[   10.608663] initcall 0xffffffff81a48406 ran for 3 msecs: init_sd+0x0/0xf5()
[   10.616663] Calling initcall 0xffffffff81a484fb: init_sg+0x0/0x177()
[   10.620663] initcall 0xffffffff81a484fb: init_sg+0x0/0x177() returned 0.
[   10.628664] initcall 0xffffffff81a484fb ran for 0 msecs: init_sg+0x0/0x177()
[   10.636664] Calling initcall 0xffffffff81a48a42: ahci_init+0x0/0x20()
[   10.644665] initcall 0xffffffff81a48a42: ahci_init+0x0/0x20() returned 0.
[   10.648665] initcall 0xffffffff81a48a42 ran for 0 msecs: ahci_init+0x0/0x20()
[   10.652665] Calling initcall 0xffffffff81a48a62: k2_sata_init+0x0/0x20()
[   10.660666] initcall 0xffffffff81a48a62: k2_sata_init+0x0/0x20() returned 0.
[   10.668666] initcall 0xffffffff81a48a62 ran for 0 msecs: k2_sata_init+0x0/0x20()
[   10.672667] Calling initcall 0xffffffff81a48a82: piix_init+0x0/0x2e()
[   10.680667] initcall 0xffffffff81a48a82: piix_init+0x0/0x2e() returned 0.
[   10.688668] initcall 0xffffffff81a48a82 ran for 0 msecs: piix_init+0x0/0x2e()
[   10.692668] Calling initcall 0xffffffff81a48ab0: vsc_sata_init+0x0/0x20()
[   10.696668] initcall 0xffffffff81a48ab0: vsc_sata_init+0x0/0x20() returned 0.
[   10.704669] initcall 0xffffffff81a48ab0 ran for 0 msecs: vsc_sata_init+0x0/0x20()
[   10.712669] Calling initcall 0xffffffff81a48ad0: pdc_sata_init+0x0/0x20()
[   10.720670] initcall 0xffffffff81a48ad0: pdc_sata_init+0x0/0x20() returned 0.
[   10.724670] initcall 0xffffffff81a48ad0 ran for 0 msecs: pdc_sata_init+0x0/0x20()
[   10.728670] Calling initcall 0xffffffff81a48af0: uli_init+0x0/0x20()
[   10.736671] initcall 0xffffffff81a48af0: uli_init+0x0/0x20() returned 0.
[   10.744671] initcall 0xffffffff81a48af0 ran for 0 msecs: uli_init+0x0/0x20()
[   10.748671] Calling initcall 0xffffffff81a48b10: mv_init+0x0/0x59()
[   10.756672] initcall 0xffffffff81a48b10: mv_init+0x0/0x59() returned 0.
[   10.764672] initcall 0xffffffff81a48b10 ran for 0 msecs: mv_init+0x0/0x59()
[   10.768673] Calling initcall 0xffffffff81a48b69: ali_init+0x0/0x20()
[   10.776673] initcall 0xffffffff81a48b69: ali_init+0x0/0x20() returned 0.
[   10.784674] initcall 0xffffffff81a48b69 ran for 0 msecs: ali_init+0x0/0x20()
[   10.788674] Calling initcall 0xffffffff81a48b89: amd_init+0x0/0x20()
[   10.796674] pata_amd 0000:00:06.0: version 0.3.10
[   10.800675] PCI: Setting latency timer of device 0000:00:06.0 to 64
[   10.804675] scsi0 : pata_amd
[   10.808675] scsi1 : pata_amd
[   10.808675] ata1: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf000 irq 14
[   10.812675] ata2: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xf008 irq 15
[   10.988686] ata1.00: ATA-6: HDS722525VLAT80, V36OA60A, max UDMA/100
[   10.992687] ata1.00: 488397168 sectors, multi 1: LBA48 
[   10.996687] ata1: nv_mode_filter: 0x3f39f&0x3f07f->0x3f01f, BIOS=0x3f000 (0xc60000c0) ACPI=0x0
[   11.024689] ata1.00: configured for UDMA/100
[   11.364710] ata2.01: ATAPI: DVDRW IDE 16X, VER A079, max UDMA/66
[   11.368710] ata2: nv_mode_filter: 0x1f39f&0x707f->0x701f, BIOS=0x7000 (0xc60000c0) ACPI=0x0
[   11.544721] ata2.01: configured for UDMA/33
[   11.548721] scsi 0:0:0:0: Direct-Access     ATA      HDS722525VLAT80  V36O PQ: 0 ANSI: 5
[   11.552722] sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors (250059 MB)
[   11.556722] sd 0:0:0:0: [sda] Write Protect is off
[   11.560722] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   11.564722] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   11.568723] sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors (250059 MB)
[   11.572723] sd 0:0:0:0: [sda] Write Protect is off
[   11.576723] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   11.580723] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   11.584724]  sda: sda1 sda2 sda3 < sda5 sda6 sda7 sda8 sda9 sda10 >
[   11.680730] sd 0:0:0:0: [sda] Attached SCSI disk
[   11.684730] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   11.688730] scsi 1:0:1:0: CD-ROM            DVDRW    IDE 16X          A079 PQ: 0 ANSI: 5
[   11.692730] scsi 1:0:1:0: Attached scsi generic sg1 type 5
[   11.696731] initcall 0xffffffff81a48b89: amd_init+0x0/0x20() returned 0.
[   11.704731] initcall 0xffffffff81a48b89 ran for 858 msecs: amd_init+0x0/0x20()
[   11.712732] Calling initcall 0xffffffff81a48ba9: artop_init+0x0/0x20()
[   11.716732] initcall 0xffffffff81a48ba9: artop_init+0x0/0x20() returned 0.
[   11.724732] initcall 0xffffffff81a48ba9 ran for 0 msecs: artop_init+0x0/0x20()
[   11.732733] Calling initcall 0xffffffff81a48bc9: cmd64x_init+0x0/0x20()
[   11.736733] initcall 0xffffffff81a48bc9: cmd64x_init+0x0/0x20() returned 0.
[   11.744734] initcall 0xffffffff81a48bc9 ran for 0 msecs: cmd64x_init+0x0/0x20()
[   11.752734] Calling initcall 0xffffffff81a48be9: cy82c693_init+0x0/0x20()
[   11.760735] initcall 0xffffffff81a48be9: cy82c693_init+0x0/0x20() returned 0.
[   11.768735] initcall 0xffffffff81a48be9 ran for 0 msecs: cy82c693_init+0x0/0x20()
[   11.772735] Calling initcall 0xffffffff81a48c09: hpt36x_init+0x0/0x20()
[   11.780736] initcall 0xffffffff81a48c09: hpt36x_init+0x0/0x20() returned 0.
[   11.788736] initcall 0xffffffff81a48c09 ran for 0 msecs: hpt36x_init+0x0/0x20()
[   11.796737] Calling initcall 0xffffffff81a48c29: hpt37x_init+0x0/0x20()
[   11.800737] initcall 0xffffffff81a48c29: hpt37x_init+0x0/0x20() returned 0.
[   11.808738] initcall 0xffffffff81a48c29 ran for 0 msecs: hpt37x_init+0x0/0x20()
[   11.816738] Calling initcall 0xffffffff81a48c49: hpt3x3_init+0x0/0x20()
[   11.824739] initcall 0xffffffff81a48c49: hpt3x3_init+0x0/0x20() returned 0.
[   11.828739] initcall 0xffffffff81a48c49 ran for 0 msecs: hpt3x3_init+0x0/0x20()
[   11.832739] Calling initcall 0xffffffff81a48c69: it821x_init+0x0/0x20()
[   11.840740] initcall 0xffffffff81a48c69: it821x_init+0x0/0x20() returned 0.
[   11.848740] initcall 0xffffffff81a48c69 ran for 0 msecs: it821x_init+0x0/0x20()
[   11.852740] Calling initcall 0xffffffff81a48c89: netcell_init+0x0/0x20()
[   11.856741] initcall 0xffffffff81a48c89: netcell_init+0x0/0x20() returned 0.
[   11.864741] initcall 0xffffffff81a48c89 ran for 0 msecs: netcell_init+0x0/0x20()
[   11.872742] Calling initcall 0xffffffff81a48ca9: ninja32_init+0x0/0x20()
[   11.876742] initcall 0xffffffff81a48ca9: ninja32_init+0x0/0x20() returned 0.
[   11.884742] initcall 0xffffffff81a48ca9 ran for 0 msecs: ninja32_init+0x0/0x20()
[   11.888743] Calling initcall 0xffffffff81a48cc9: ns87410_init+0x0/0x20()
[   11.896743] initcall 0xffffffff81a48cc9: ns87410_init+0x0/0x20() returned 0.
[   11.904744] initcall 0xffffffff81a48cc9 ran for 0 msecs: ns87410_init+0x0/0x20()
[   11.908744] Calling initcall 0xffffffff81a48ce9: oldpiix_init+0x0/0x20()
[   11.912744] initcall 0xffffffff81a48ce9: oldpiix_init+0x0/0x20() returned 0.
[   11.920745] initcall 0xffffffff81a48ce9 ran for 0 msecs: oldpiix_init+0x0/0x20()
[   11.928745] Calling initcall 0xffffffff81a48d09: pdc202xx_init+0x0/0x20()
[   11.932745] initcall 0xffffffff81a48d09: pdc202xx_init+0x0/0x20() returned 0.
[   11.940746] initcall 0xffffffff81a48d09 ran for 0 msecs: pdc202xx_init+0x0/0x20()
[   11.944746] Calling initcall 0xffffffff81a48d29: rz1000_init+0x0/0x20()
[   11.952747] initcall 0xffffffff81a48d29: rz1000_init+0x0/0x20() returned 0.
[   11.960747] initcall 0xffffffff81a48d29 ran for 0 msecs: rz1000_init+0x0/0x20()
[   11.964747] Calling initcall 0xffffffff81a48d49: sil680_init+0x0/0x20()
[   11.968748] initcall 0xffffffff81a48d49: sil680_init+0x0/0x20() returned 0.
[   11.976748] initcall 0xffffffff81a48d49 ran for 0 msecs: sil680_init+0x0/0x20()
[   11.984749] Calling initcall 0xffffffff81a48d69: via_init+0x0/0x20()
[   11.988749] initcall 0xffffffff81a48d69: via_init+0x0/0x20() returned 0.
[   11.996749] initcall 0xffffffff81a48d69 ran for 0 msecs: via_init+0x0/0x20()
[   12.004750] Calling initcall 0xffffffff81a48d89: sis_init+0x0/0x20()
[   12.008750] initcall 0xffffffff81a48d89: sis_init+0x0/0x20() returned 0.
[   12.016751] initcall 0xffffffff81a48d89 ran for 0 msecs: sis_init+0x0/0x20()
[   12.024751] Calling initcall 0xffffffff81a48da9: triflex_init+0x0/0x20()
[   12.028751] initcall 0xffffffff81a48da9: triflex_init+0x0/0x20() returned 0.
[   12.036752] initcall 0xffffffff81a48da9 ran for 0 msecs: triflex_init+0x0/0x20()
[   12.040752] Calling initcall 0xffffffff81a48dc9: pacpi_init+0x0/0x20()
[   12.048753] initcall 0xffffffff81a48dc9: pacpi_init+0x0/0x20() returned 0.
[   12.052753] initcall 0xffffffff81a48dc9 ran for 0 msecs: pacpi_init+0x0/0x20()
[   12.056753] Calling initcall 0xffffffff81a48de9: ks0108_init+0x0/0xd2()
[   12.064754] parport0: cannot grant exclusive access for device ks0108
[   12.068754] ks0108: ERROR: parport didn't register new device
[   12.072754] initcall 0xffffffff81a48de9: ks0108_init+0x0/0xd2() returned -22.
[   12.080755] initcall 0xffffffff81a48de9 ran for 7 msecs: ks0108_init+0x0/0xd2()
[   12.088755] initcall at 0xffffffff81a48de9: ks0108_init+0x0/0xd2(): returned with error code -22
[   12.096756] Calling initcall 0xffffffff81a48ebb: cfag12864b_init+0x0/0x168()
[   12.104756] cfag12864b: ERROR: ks0108 is not initialized
[   12.108756] initcall 0xffffffff81a48ebb: cfag12864b_init+0x0/0x168() returned -22.
[   12.116757] initcall 0xffffffff81a48ebb ran for 3 msecs: cfag12864b_init+0x0/0x168()
[   12.124757] initcall at 0xffffffff81a48ebb: cfag12864b_init+0x0/0x168(): returned with error code -22
[   12.132758] Calling initcall 0xffffffff81a49023: cfag12864bfb_init+0x0/0xa8()
[   12.140758] cfag12864bfb: ERROR: cfag12864b is not initialized
[   12.144759] initcall 0xffffffff81a49023: cfag12864bfb_init+0x0/0xa8() returned -22.
[   12.152759] initcall 0xffffffff81a49023 ran for 3 msecs: cfag12864bfb_init+0x0/0xa8()
[   12.156759] initcall at 0xffffffff81a49023: cfag12864bfb_init+0x0/0xa8(): returned with error code -22
[   12.168760] Calling initcall 0xffffffff81a493dc: mon_init+0x0/0x113()
[   12.172760] initcall 0xffffffff81a493dc: mon_init+0x0/0x113() returned 0.
[   12.180761] initcall 0xffffffff81a493dc ran for 0 msecs: mon_init+0x0/0x113()
[   12.188761] Calling initcall 0xffffffff81a49604: ehci_hcd_init+0x0/0x9c()
[   12.192762] ehci_hcd: block sizes: qh 160 qtd 96 itd 192 sitd 96
[   12.196762] PCI: No IRQ known for interrupt pin B of device 0000:00:02.1. Please try using pci=biosirq.
[   12.200762] ehci_hcd 0000:00:02.1: Found HC with no IRQ.  Check BIOS/PCI 0000:00:02.1 setup!
[   12.204762] ehci_hcd 0000:00:02.1: init 0000:00:02.1 fail, -19
[   12.208763] initcall 0xffffffff81a49604: ehci_hcd_init+0x0/0x9c() returned 0.
[   12.216763] initcall 0xffffffff81a49604 ran for 15 msecs: ehci_hcd_init+0x0/0x9c()
[   12.224764] Calling initcall 0xffffffff81a496a0: ohci_hcd_mod_init+0x0/0xd3()
[   12.228764] ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
[   12.232764] ohci_hcd: block sizes: ed 80 td 96
[   12.236764] PCI: No IRQ known for interrupt pin A of device 0000:00:02.0. Please try using pci=biosirq.
[   12.240765] ohci_hcd 0000:00:02.0: Found HC with no IRQ.  Check BIOS/PCI 0000:00:02.0 setup!
[   12.244765] ohci_hcd 0000:00:02.0: init 0000:00:02.0 fail, -19
[   12.248765] initcall 0xffffffff81a496a0: ohci_hcd_mod_init+0x0/0xd3() returned 0.
[   12.256766] initcall 0xffffffff81a496a0 ran for 19 msecs: ohci_hcd_mod_init+0x0/0xd3()
[   12.264766] Calling initcall 0xffffffff81a49773: uhci_hcd_init+0x0/0xfb()
[   12.272767] USB Universal Host Controller Interface driver v3.0
[   12.276767] initcall 0xffffffff81a49773: uhci_hcd_init+0x0/0xfb() returned 0.
[   12.284767] initcall 0xffffffff81a49773 ran for 3 msecs: uhci_hcd_init+0x0/0xfb()
[   12.292768] Calling initcall 0xffffffff81a4986e: r8a66597_init+0x0/0x4a()
[   12.300768] drivers/usb/host/r8a66597-hcd.c: driver r8a66597_hcd, 29 May 2007
[   12.304769] initcall 0xffffffff81a4986e: r8a66597_init+0x0/0x4a() returned 0.
[   12.308769] initcall 0xffffffff81a4986e ran for 3 msecs: r8a66597_init+0x0/0x4a()
[   12.312769] Calling initcall 0xffffffff81a49b8d: acm_init+0x0/0x157()
[   12.320770] usbcore: registered new interface driver cdc_acm
[   12.324770] drivers/usb/class/cdc-acm.c: v0.25:USB Abstract Control Model driver for USB modems and ISDN adapters
[   12.328770] initcall 0xffffffff81a49b8d: acm_init+0x0/0x157() returned 0.
[   12.332770] initcall 0xffffffff81a49b8d ran for 7 msecs: acm_init+0x0/0x157()
[   12.336771] Calling initcall 0xffffffff81a49ce4: usb_stor_init+0x0/0x58()
[   12.344771] Initializing USB Mass Storage driver...
[   12.348771] usbcore: registered new interface driver usb-storage
[   12.352772] USB Mass Storage support registered.
[   12.356772] initcall 0xffffffff81a49ce4: usb_stor_init+0x0/0x58() returned 0.
[   12.364772] initcall 0xffffffff81a49ce4 ran for 11 msecs: usb_stor_init+0x0/0x58()
[   12.372773] Calling initcall 0xffffffff81a49d3c: usb_usual_init+0x0/0x62()
[   12.376773] usbcore: registered new interface driver libusual
[   12.380773] initcall 0xffffffff81a49d3c: usb_usual_init+0x0/0x62() returned 0.
[   12.388774] initcall 0xffffffff81a49d3c ran for 3 msecs: usb_usual_init+0x0/0x62()
[   12.392774] Calling initcall 0xffffffff81a49d9e: usb_mdc800_init+0x0/0x26a()
[   12.396774] usbcore: registered new interface driver mdc800
[   12.400775] drivers/usb/image/mdc800.c: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Digital Camera
[   12.404775] initcall 0xffffffff81a49d9e: usb_mdc800_init+0x0/0x26a() returned 0.
[   12.412775] initcall 0xffffffff81a49d9e ran for 7 msecs: usb_mdc800_init+0x0/0x26a()
[   12.420776] Calling initcall 0xffffffff81a4a008: microtek_drv_init+0x0/0x20()
[   12.428776] usbcore: registered new interface driver microtekX6
[   12.432777] initcall 0xffffffff81a4a008: microtek_drv_init+0x0/0x20() returned 0.
[   12.440777] initcall 0xffffffff81a4a008 ran for 3 msecs: microtek_drv_init+0x0/0x20()
[   12.448778] Calling initcall 0xffffffff81a4a028: adu_init+0x0/0xb3()
[   12.456778] drivers/usb/misc/adutux.c :  adu_init : enter 
[   12.460778] usbcore: registered new interface driver adutux
[   12.464779] drivers/usb/misc/adutux.c: adutux adutux (see www.ontrak.net) v0.0.13
[   12.468779] drivers/usb/misc/adutux.c: adutux is an experimental driver. Use at your own risk
[   12.472779] drivers/usb/misc/adutux.c :  adu_init : leave, return value 0 
[   12.476779] initcall 0xffffffff81a4a028: adu_init+0x0/0xb3() returned 0.
[   12.484780] initcall 0xffffffff81a4a028 ran for 19 msecs: adu_init+0x0/0xb3()
[   12.488780] Calling initcall 0xffffffff81a4a0db: usb_cytherm_init+0x0/0x67()
[   12.492780] usbcore: registered new interface driver cytherm
[   12.496781] drivers/usb/misc/cytherm.c: v1.0:Cypress USB Thermometer driver
[   12.500781] initcall 0xffffffff81a4a0db: usb_cytherm_init+0x0/0x67() returned 0.
[   12.508781] initcall 0xffffffff81a4a0db ran for 7 msecs: usb_cytherm_init+0x0/0x67()
[   12.512782] Calling initcall 0xffffffff81a4a142: emi26_init+0x0/0x20()
[   12.520782] usbcore: registered new interface driver emi26 - firmware loader
[   12.524782] initcall 0xffffffff81a4a142: emi26_init+0x0/0x20() returned 0.
[   12.528783] initcall 0xffffffff81a4a142 ran for 3 msecs: emi26_init+0x0/0x20()
[   12.532783] Calling initcall 0xffffffff81a4a162: emi62_init+0x0/0x40()
[   12.540783] usbcore: registered new interface driver emi62 - firmware loader
[   12.544784] initcall 0xffffffff81a4a162: emi62_init+0x0/0x40() returned 0.
[   12.548784] initcall 0xffffffff81a4a162 ran for 3 msecs: emi62_init+0x0/0x40()
[   12.552784] Calling initcall 0xffffffff81a4a1a2: usb_idmouse_init+0x0/0x5e()
[   12.560785] drivers/usb/misc/idmouse.c: Siemens ID Mouse FingerTIP Sensor Driver 0.6
[   12.564785] usbcore: registered new interface driver idmouse
[   12.568785] initcall 0xffffffff81a4a1a2: usb_idmouse_init+0x0/0x5e() returned 0.
[   12.576786] initcall 0xffffffff81a4a1a2 ran for 7 msecs: usb_idmouse_init+0x0/0x5e()
[   12.584786] Calling initcall 0xffffffff81a4a200: iowarrior_init+0x0/0x20()
[   12.592787] usbcore: registered new interface driver iowarrior
[   12.596787] initcall 0xffffffff81a4a200: iowarrior_init+0x0/0x20() returned 0.
[   12.604787] initcall 0xffffffff81a4a200 ran for 3 msecs: iowarrior_init+0x0/0x20()
[   12.612788] Calling initcall 0xffffffff81a4a220: usb_led_init+0x0/0x49()
[   12.620788] usbcore: registered new interface driver usbled
[   12.624789] initcall 0xffffffff81a4a220: usb_led_init+0x0/0x49() returned 0.
[   12.632789] initcall 0xffffffff81a4a220 ran for 3 msecs: usb_led_init+0x0/0x49()
[   12.640790] Calling initcall 0xffffffff81a4a269: init_phidget+0x0/0x2f()
[   12.644790] initcall 0xffffffff81a4a269: init_phidget+0x0/0x2f() returned 0.
[   12.652790] initcall 0xffffffff81a4a269 ran for 0 msecs: init_phidget+0x0/0x2f()
[   12.660791] Calling initcall 0xffffffff81a4a298: interfacekit_init+0x0/0x49()
[   12.668791] usbcore: registered new interface driver phidgetkit
[   12.672792] initcall 0xffffffff81a4a298: interfacekit_init+0x0/0x49() returned 0.
[   12.680792] initcall 0xffffffff81a4a298 ran for 3 msecs: interfacekit_init+0x0/0x49()
[   12.688793] Calling initcall 0xffffffff81a4a2e1: motorcontrol_init+0x0/0x49()
[   12.696793] usbcore: registered new interface driver phidgetmotorcontrol
[   12.700793] initcall 0xffffffff81a4a2e1: motorcontrol_init+0x0/0x49() returned 0.
[   12.704794] initcall 0xffffffff81a4a2e1 ran for 3 msecs: motorcontrol_init+0x0/0x49()
[   12.708794] Calling initcall 0xffffffff81a4a32a: uss720_init+0x0/0x86()
[   12.712794] usbcore: registered new interface driver uss720
[   12.716794] drivers/usb/misc/uss720.c: v0.6:USB Parport Cable driver for Cables using the Lucent Technologies USS720 Chip
[   12.720795] drivers/usb/misc/uss720.c: NOTE: this is a special purpose driver to allow nonstandard
[   12.724795] drivers/usb/misc/uss720.c: protocols (eg. bitbang) over USS720 usb to parallel cables
[   12.728795] drivers/usb/misc/uss720.c: If you just want to connect to a printer, use usblp instead
[   12.732795] initcall 0xffffffff81a4a32a: uss720_init+0x0/0x86() returned 0.
[   12.740796] initcall 0xffffffff81a4a32a ran for 19 msecs: uss720_init+0x0/0x86()
[   12.748796] Calling initcall 0xffffffff81a4a3b0: usb_sisusb_init+0x0/0x25()
[   12.752797] usbcore: registered new interface driver sisusb
[   12.756797] initcall 0xffffffff81a4a3b0: usb_sisusb_init+0x0/0x25() returned 0.
[   12.764797] initcall 0xffffffff81a4a3b0 ran for 3 msecs: usb_sisusb_init+0x0/0x25()
[   12.768798] Calling initcall 0xffffffff81a4a410: uea_init+0x0/0x30()
[   12.772798] [ueagle-atm] driver ueagle 1.4 loaded
[   12.776798] usbcore: registered new interface driver ueagle-atm
[   12.780798] initcall 0xffffffff81a4a410: uea_init+0x0/0x30() returned 0.
[   12.784799] initcall 0xffffffff81a4a410 ran for 7 msecs: uea_init+0x0/0x30()
[   12.788799] Calling initcall 0xffffffff81a4a440: usbatm_usb_init+0x0/0x6b()
[   12.796799] drivers/usb/atm/usbatm.c: usbatm_usb_init: driver version 1.10
[   12.800800] initcall 0xffffffff81a4a440: usbatm_usb_init+0x0/0x6b() returned 0.
[   12.804800] initcall 0xffffffff81a4a440 ran for 3 msecs: usbatm_usb_init+0x0/0x6b()
[   12.808800] Calling initcall 0xffffffff81a4a4ab: xusbatm_init+0x0/0x145()
[   12.816801] drivers/usb/atm/xusbatm.c: xusbatm_init
[   12.820801] drivers/usb/atm/xusbatm.c: malformed module parameters
[   12.824801] initcall 0xffffffff81a4a4ab: xusbatm_init+0x0/0x145() returned -22.
[   12.832802] initcall 0xffffffff81a4a4ab ran for 7 msecs: xusbatm_init+0x0/0x145()
[   12.840802] initcall at 0xffffffff81a4a4ab: xusbatm_init+0x0/0x145(): returned with error code -22
[   12.848803] Calling initcall 0xffffffff81a4a690: i8042_init+0x0/0x402()
[   12.852803] PNP: No PS/2 controller found. Probing ports directly.
[   12.860803] serio: i8042 KBD port at 0x60,0x64 irq 1
[   12.864804] serio: i8042 AUX port at 0x60,0x64 irq 12
[   12.868804] initcall 0xffffffff81a4a690: i8042_init+0x0/0x402() returned 0.
[   12.876804] initcall 0xffffffff81a4a690 ran for 15 msecs: i8042_init+0x0/0x402()
[   12.884805] Calling initcall 0xffffffff81a4aa92: serport_init+0x0/0x3c()
[   12.892805] initcall 0xffffffff81a4aa92: serport_init+0x0/0x3c() returned 0.
[   12.896806] initcall 0xffffffff81a4aa92 ran for 0 msecs: serport_init+0x0/0x3c()
[   12.900806] Calling initcall 0xffffffff81a4aace: pcips2_init+0x0/0x20()
[   12.908806] initcall 0xffffffff81a4aace: pcips2_init+0x0/0x20() returned 0.
[   12.916807] initcall 0xffffffff81a4aace ran for 0 msecs: pcips2_init+0x0/0x20()
[   12.920807] Calling initcall 0xffffffff81a4aaee: serio_raw_init+0x0/0x20()
[   12.924807] initcall 0xffffffff81a4aaee: serio_raw_init+0x0/0x20() returned 0.
[   12.932808] initcall 0xffffffff81a4aaee ran for 0 msecs: serio_raw_init+0x0/0x20()
[   12.940808] Calling initcall 0xffffffff81a4abab: fm801_gp_init+0x0/0x25()
[   12.948809] initcall 0xffffffff81a4abab: fm801_gp_init+0x0/0x25() returned 0.
[   12.952809] initcall 0xffffffff81a4abab ran for 0 msecs: fm801_gp_init+0x0/0x25()
[   12.956809] Calling initcall 0xffffffff81a4ad02: mousedev_init+0x0/0x9e()
[   12.964810] mice: PS/2 mouse device common for all mice
[   12.968810] initcall 0xffffffff81a4ad02: mousedev_init+0x0/0x9e() returned 0.
[   12.976811] initcall 0xffffffff81a4ad02 ran for 3 msecs: mousedev_init+0x0/0x9e()
[   12.984811] Calling initcall 0xffffffff81a4ada0: joydev_init+0x0/0x17()
[   12.992812] initcall 0xffffffff81a4ada0: joydev_init+0x0/0x17() returned 0.
[   12.996812] initcall 0xffffffff81a4ada0 ran for 0 msecs: joydev_init+0x0/0x17()
[   13.000812] Calling initcall 0xffffffff81a4adb7: evdev_init+0x0/0x17()
[   13.008813] initcall 0xffffffff81a4adb7: evdev_init+0x0/0x17() returned 0.
[   13.016813] initcall 0xffffffff81a4adb7 ran for 0 msecs: evdev_init+0x0/0x17()
[   13.020813] Calling initcall 0xffffffff81a4adce: evbug_init+0x0/0x17()
[   13.028814] initcall 0xffffffff81a4adce: evbug_init+0x0/0x17() returned 0.
[   13.036814] initcall 0xffffffff81a4adce ran for 0 msecs: evbug_init+0x0/0x17()
[   13.044815] Calling initcall 0xffffffff81a4adfd: atkbd_init+0x0/0x2c()
[   13.048815] initcall 0xffffffff81a4adfd: atkbd_init+0x0/0x2c() returned 0.
[   13.056816] initcall 0xffffffff81a4adfd ran for 0 msecs: atkbd_init+0x0/0x2c()
[   13.064816] Calling initcall 0xffffffff81a4ae29: sunkbd_init+0x0/0x20()
[   13.068816] initcall 0xffffffff81a4ae29: sunkbd_init+0x0/0x20() returned 0.
[   13.076817] initcall 0xffffffff81a4ae29 ran for 0 msecs: sunkbd_init+0x0/0x20()
[   13.080817] Calling initcall 0xffffffff81a4ae49: xtkbd_init+0x0/0x20()
[   13.104819] input: AT Translated Set 2 keyboard as /class/input/input0
[   13.148821] evbug.c: Connected device: "AT Translated Set 2 keyboard", isa0060/serio0/input0
[   13.156822] initcall 0xffffffff81a4ae49: xtkbd_init+0x0/0x20() returned 0.
[   13.164822] initcall 0xffffffff81a4ae49 ran for 64 msecs: xtkbd_init+0x0/0x20()
[   13.168823] Calling initcall 0xffffffff81a4ae69: skbd_init+0x0/0x27()
[   13.176823] initcall 0xffffffff81a4ae69: skbd_init+0x0/0x27() returned 0.
[   13.184824] initcall 0xffffffff81a4ae69 ran for 0 msecs: skbd_init+0x0/0x27()
[   13.192824] Calling initcall 0xffffffff81a4ae90: a3d_init+0x0/0x20()
[   13.196824] initcall 0xffffffff81a4ae90: a3d_init+0x0/0x20() returned 0.
[   13.204825] initcall 0xffffffff81a4ae90 ran for 0 msecs: a3d_init+0x0/0x20()
[   13.212825] Calling initcall 0xffffffff81a4aeb0: db9_init+0x0/0x4d5()
[   13.216826] initcall 0xffffffff81a4aeb0: db9_init+0x0/0x4d5() returned -19.
[   13.224826] initcall 0xffffffff81a4aeb0 ran for 0 msecs: db9_init+0x0/0x4d5()
[   13.232827] Calling initcall 0xffffffff81a4b385: grip_init+0x0/0x1b()
[   13.236827] initcall 0xffffffff81a4b385: grip_init+0x0/0x1b() returned 0.
[   13.244827] initcall 0xffffffff81a4b385 ran for 0 msecs: grip_init+0x0/0x1b()
[   13.252828] Calling initcall 0xffffffff81a4b3a0: interact_init+0x0/0x1b()
[   13.260828] initcall 0xffffffff81a4b3a0: interact_init+0x0/0x1b() returned 0.
[   13.264829] initcall 0xffffffff81a4b3a0 ran for 0 msecs: interact_init+0x0/0x1b()
[   13.268829] Calling initcall 0xffffffff81a4b3bb: sw_init+0x0/0x1b()
[   13.276829] initcall 0xffffffff81a4b3bb: sw_init+0x0/0x1b() returned 0.
[   13.280830] initcall 0xffffffff81a4b3bb ran for 0 msecs: sw_init+0x0/0x1b()
[   13.284830] Calling initcall 0xffffffff81a4b3d6: spaceball_init+0x0/0x20()
[   13.292830] initcall 0xffffffff81a4b3d6: spaceball_init+0x0/0x20() returned 0.
[   13.300831] initcall 0xffffffff81a4b3d6 ran for 0 msecs: spaceball_init+0x0/0x20()
[   13.308831] Calling initcall 0xffffffff81a4b3f6: spaceorb_init+0x0/0x20()
[   13.312832] initcall 0xffffffff81a4b3f6: spaceorb_init+0x0/0x20() returned 0.
[   13.320832] initcall 0xffffffff81a4b3f6 ran for 0 msecs: spaceorb_init+0x0/0x20()
[   13.324832] Calling initcall 0xffffffff81a4b416: stinger_init+0x0/0x20()
[   13.332833] initcall 0xffffffff81a4b416: stinger_init+0x0/0x20() returned 0.
[   13.340833] initcall 0xffffffff81a4b416 ran for 0 msecs: stinger_init+0x0/0x20()
[   13.344834] Calling initcall 0xffffffff81a4b436: tmdc_init+0x0/0x1b()
[   13.352834] initcall 0xffffffff81a4b436: tmdc_init+0x0/0x1b() returned 0.
[   13.360835] initcall 0xffffffff81a4b436 ran for 0 msecs: tmdc_init+0x0/0x1b()
[   13.368835] Calling initcall 0xffffffff81a4b451: twidjoy_init+0x0/0x20()
[   13.372835] initcall 0xffffffff81a4b451: twidjoy_init+0x0/0x20() returned 0.
[   13.380836] initcall 0xffffffff81a4b451 ran for 0 msecs: twidjoy_init+0x0/0x20()
[   13.388836] Calling initcall 0xffffffff81a4b471: atlas_acpi_init+0x0/0x43()
[   13.396837] initcall 0xffffffff81a4b471: atlas_acpi_init+0x0/0x43() returned -19.
[   13.400837] initcall 0xffffffff81a4b471 ran for 0 msecs: atlas_acpi_init+0x0/0x43()
[   13.404837] Calling initcall 0xffffffff81a4b4b4: ati_remote2_init+0x0/0x59()
[   13.412838] usbcore: registered new interface driver ati_remote2
[   13.416838] ati_remote2: ATI/Philips USB RF remote driver 0.2
[   13.420838] initcall 0xffffffff81a4b4b4: ati_remote2_init+0x0/0x59() returned 0.
[   13.428839] initcall 0xffffffff81a4b4b4 ran for 7 msecs: ati_remote2_init+0x0/0x59()
[   13.436839] Calling initcall 0xffffffff81a4b50d: powermate_init+0x0/0x20()
[   13.444840] usbcore: registered new interface driver powermate
[   13.448840] initcall 0xffffffff81a4b50d: powermate_init+0x0/0x20() returned 0.
[   13.456841] initcall 0xffffffff81a4b50d ran for 3 msecs: powermate_init+0x0/0x20()
[   13.464841] Calling initcall 0xffffffff81a4b52d: yealink_dev_init+0x0/0x47()
[   13.472842] usbcore: registered new interface driver yealink
[   13.476842] drivers/input/misc/yealink.c: Yealink phone driver:yld-20051230
[   13.480842] initcall 0xffffffff81a4b52d: yealink_dev_init+0x0/0x47() returned 0.
[   13.488843] initcall 0xffffffff81a4b52d ran for 7 msecs: yealink_dev_init+0x0/0x47()
[   13.496843] Calling initcall 0xffffffff81a4b574: uinput_init+0x0/0x17()
[   13.500843] initcall 0xffffffff81a4b574: uinput_init+0x0/0x17() returned 0.
[   13.508844] initcall 0xffffffff81a4b574 ran for 0 msecs: uinput_init+0x0/0x17()
[   13.516844] Calling initcall 0xffffffff81a4b58b: i2o_iop_init+0x0/0x59()
[   13.524845] I2O subsystem v1.325
[   13.524845] i2o: max drivers = 8
[   13.528845] initcall 0xffffffff81a4b58b: i2o_iop_init+0x0/0x59() returned 0.
[   13.536846] initcall 0xffffffff81a4b58b ran for 3 msecs: i2o_iop_init+0x0/0x59()
[   13.544846] Calling initcall 0xffffffff81a4b702: i2o_bus_init+0x0/0x4c()
[   13.548846] I2O Bus Adapter OSM v1.317
[   13.552847] initcall 0xffffffff81a4b702: i2o_bus_init+0x0/0x4c() returned 0.
[   13.560847] initcall 0xffffffff81a4b702 ran for 3 msecs: i2o_bus_init+0x0/0x4c()
[   13.568848] Calling initcall 0xffffffff81a4b74e: i2o_block_init+0x0/0x137()
[   13.576848] I2O Block Device OSM v1.325
[   13.580848] initcall 0xffffffff81a4b74e: i2o_block_init+0x0/0x137() returned 0.
[   13.588849] initcall 0xffffffff81a4b74e ran for 3 msecs: i2o_block_init+0x0/0x137()
[   13.596849] Calling initcall 0xffffffff81a4b885: i2o_scsi_init+0x0/0x4c()
[   13.600850] I2O SCSI Peripheral OSM v1.316
[   13.604850] initcall 0xffffffff81a4b885: i2o_scsi_init+0x0/0x4c() returned 0.
[   13.612850] initcall 0xffffffff81a4b885 ran for 3 msecs: i2o_scsi_init+0x0/0x4c()
[   13.620851] Calling initcall 0xffffffff807e6ad3: w1_init+0x0/0x10c()
[   13.628851] Driver for 1-wire Dallas network protocol.
[   13.632852] initcall 0xffffffff807e6ad3: w1_init+0x0/0x10c() returned 0.
[   13.640852] initcall 0xffffffff807e6ad3 ran for 3 msecs: w1_init+0x0/0x10c()
[   13.644852] Calling initcall 0xffffffff81a4b8d1: w1_smem_init+0x0/0x50()
[   13.652853] initcall 0xffffffff81a4b8d1: w1_smem_init+0x0/0x50() returned 0.
[   13.660853] initcall 0xffffffff81a4b8d1 ran for 0 msecs: w1_smem_init+0x0/0x50()
[   13.668854] Calling initcall 0xffffffff81a4b921: w1_ds2760_init+0x0/0x31()
[   13.672854] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 2004-2005, Szabolcs Gyurko
[   13.676854] initcall 0xffffffff81a4b921: w1_ds2760_init+0x0/0x31() returned 0.
[   13.680855] initcall 0xffffffff81a4b921 ran for 3 msecs: w1_ds2760_init+0x0/0x31()
[   13.684855] Calling initcall 0xffffffff81a4b987: pda_power_init+0x0/0x17()
[   13.692855] initcall 0xffffffff81a4b987: pda_power_init+0x0/0x17() returned 0.
[   13.700856] initcall 0xffffffff81a4b987 ran for 0 msecs: pda_power_init+0x0/0x17()
[   13.708856] Calling initcall 0xffffffff81a4b99e: ds2760_battery_init+0x0/0x22()
[   13.716857] initcall 0xffffffff81a4b99e: ds2760_battery_init+0x0/0x22() returned 0.
[   13.720857] initcall 0xffffffff81a4b99e ran for 0 msecs: ds2760_battery_init+0x0/0x22()
[   13.724857] Calling initcall 0xffffffff81a4bc2d: sensors_w83627hf_init+0x0/0x183()
[   13.728858] initcall 0xffffffff81a4bc2d: sensors_w83627hf_init+0x0/0x183() returned -19.
[   13.736858] initcall 0xffffffff81a4bc2d ran for 0 msecs: sensors_w83627hf_init+0x0/0x183()
[   13.744859] Calling initcall 0xffffffff81a4bdb0: applesmc_init+0x0/0x613()
[   13.748859] applesmc: supported laptop not found!
[   13.752859] applesmc: driver init failed (ret=-19)!
[   13.756859] initcall 0xffffffff81a4bdb0: applesmc_init+0x0/0x613() returned -19.
[   13.760860] initcall 0xffffffff81a4bdb0 ran for 7 msecs: applesmc_init+0x0/0x613()
[   13.764860] Calling initcall 0xffffffff81a4c57a: f71882fg_init+0x0/0x11a()
[   13.772860] f71882fg: Not a Fintek device
[   13.776861] f71882fg: Not a Fintek device
[   13.780861] initcall 0xffffffff81a4c57a: f71882fg_init+0x0/0x11a() returned -19.
[   13.788861] initcall 0xffffffff81a4c57a ran for 7 msecs: f71882fg_init+0x0/0x11a()
[   13.796862] Calling initcall 0xffffffff81a4c6ee: hdaps_init+0x0/0x1fa()
[   13.804862] hdaps: supported laptop not found!
[   13.808863] hdaps: driver init failed (ret=-19)!
[   13.812863] initcall 0xffffffff81a4c6ee: hdaps_init+0x0/0x1fa() returned -19.
[   13.820863] initcall 0xffffffff81a4c6ee ran for 7 msecs: hdaps_init+0x0/0x1fa()
[   13.824864] Calling initcall 0xffffffff81a4c8e8: k8temp_init+0x0/0x20()
[   13.828864] initcall 0xffffffff81a4c8e8: k8temp_init+0x0/0x20() returned 0.
[   13.836864] initcall 0xffffffff81a4c8e8 ran for 0 msecs: k8temp_init+0x0/0x20()
[   13.844865] Calling initcall 0xffffffff81a4cb8c: pc87360_init+0x0/0x1a9()
[   13.848865] pc87360: PC8736x not detected, module not inserted.
[   13.852865] initcall 0xffffffff81a4cb8c: pc87360_init+0x0/0x1a9() returned -19.
[   13.860866] initcall 0xffffffff81a4cb8c ran for 3 msecs: pc87360_init+0x0/0x1a9()
[   13.868866] Calling initcall 0xffffffff81a4cd35: smsc47b397_init+0x0/0x1c3()
[   13.872867] initcall 0xffffffff81a4cd35: smsc47b397_init+0x0/0x1c3() returned -19.
[   13.880867] initcall 0xffffffff81a4cd35 ran for 0 msecs: smsc47b397_init+0x0/0x1c3()
[   13.884867] Calling initcall 0xffffffff81a4cef8: sm_vt8231_init+0x0/0x28()
[   13.892868] initcall 0xffffffff81a4cef8: sm_vt8231_init+0x0/0x28() returned 0.
[   13.900868] initcall 0xffffffff81a4cef8 ran for 0 msecs: sm_vt8231_init+0x0/0x28()
[   13.908869] Calling initcall 0xffffffff81a4d0f1: sensors_w83627ehf_init+0x0/0x177()
[   13.916869] initcall 0xffffffff81a4d0f1: sensors_w83627ehf_init+0x0/0x177() returned -19.
[   13.924870] initcall 0xffffffff81a4d0f1 ran for 0 msecs: sensors_w83627ehf_init+0x0/0x177()
[   13.932870] Calling initcall 0xffffffff81a4d2a9: vhci_init+0x0/0x60()
[   13.936871] Bluetooth: Virtual HCI driver ver 1.2
[   13.940871] initcall 0xffffffff81a4d2a9: vhci_init+0x0/0x60() returned 0.
[   13.944871] initcall 0xffffffff81a4d2a9 ran for 3 msecs: vhci_init+0x0/0x60()
[   13.948871] Calling initcall 0xffffffff81a4d309: bcm203x_init+0x0/0x65()
[   13.956872] Bluetooth: Broadcom Blutonium firmware driver ver 1.1
[   13.960872] usbcore: registered new interface driver bcm203x
[   13.964872] initcall 0xffffffff81a4d309: bcm203x_init+0x0/0x65() returned 0.
[   13.972873] initcall 0xffffffff81a4d309 ran for 7 msecs: bcm203x_init+0x0/0x65()
[   13.976873] Calling initcall 0xffffffff81a4d36e: bpa10x_init+0x0/0x35()
[   13.984874] Bluetooth: Digianswer Bluetooth USB driver ver 0.9
[   13.988874] usbcore: registered new interface driver bpa10x
[   13.992874] initcall 0xffffffff81a4d36e: bpa10x_init+0x0/0x35() returned 0.
[   14.000875] initcall 0xffffffff81a4d36e ran for 7 msecs: bpa10x_init+0x0/0x35()
[   14.004875] Calling initcall 0xffffffff81a4d3a3: btusb_init+0x0/0x35()
[   14.008875] Bluetooth: Generic Bluetooth USB driver ver 0.1
[   14.016876] usbcore: registered new interface driver btusb
[   14.020876] initcall 0xffffffff81a4d3a3: btusb_init+0x0/0x35() returned 0.
[   14.028876] initcall 0xffffffff81a4d3a3 ran for 11 msecs: btusb_init+0x0/0x35()
[   14.032877] Calling initcall 0xffffffff81a4d3d8: btsdio_init+0x0/0x38()
[   14.036877] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[   14.040877] initcall 0xffffffff81a4d3d8: btsdio_init+0x0/0x38() returned 0.
[   14.044877] initcall 0xffffffff81a4d3d8 ran for 3 msecs: btsdio_init+0x0/0x38()
[   14.048878] Calling initcall 0xffffffff81a4d410: isdn_init+0x0/0x340()
[   14.056878] ISDN subsystem Rev: 1.1.2.3/1.1.2.3/1.1.2.2/1.1.2.3/none/1.1.2.2
[   14.064879] initcall 0xffffffff81a4d410: isdn_init+0x0/0x340() returned 0.
[   14.068879] initcall 0xffffffff81a4d410 ran for 7 msecs: isdn_init+0x0/0x340()
[   14.072879] Calling initcall 0xffffffff81a4d750: kcapi_init+0x0/0xa2()
[   14.080880] CAPI Subsystem Rev 1.1.2.8
[   14.084880] initcall 0xffffffff81a4d750: kcapi_init+0x0/0xa2() returned 0.
[   14.088880] initcall 0xffffffff81a4d750 ran for 3 msecs: kcapi_init+0x0/0xa2()
[   14.092880] Calling initcall 0xffffffff81a4d890: capidrv_init+0x0/0x1a0()
[   14.100881] capidrv: Rev 1.1.2.2: loaded
[   14.104881] initcall 0xffffffff81a4d890: capidrv_init+0x0/0x1a0() returned 0.
[   14.112882] initcall 0xffffffff81a4d890 ran for 3 msecs: capidrv_init+0x0/0x1a0()
[   14.120882] Calling initcall 0xffffffff81a4da30: t1pci_init+0x0/0xd0()
[   14.124882] t1pci: revision 1.1.2.2
[   14.128883] initcall 0xffffffff81a4da30: t1pci_init+0x0/0xd0() returned 0.
[   14.136883] initcall 0xffffffff81a4da30 ran for 3 msecs: t1pci_init+0x0/0xd0()
[   14.144884] Calling initcall 0xffffffff81a4db00: b1_init+0x0/0x90()
[   14.148884] b1: revision 1.1.2.2
[   14.152884] initcall 0xffffffff81a4db00: b1_init+0x0/0x90() returned 0.
[   14.160885] initcall 0xffffffff81a4db00 ran for 3 msecs: b1_init+0x0/0x90()
[   14.168885] Calling initcall 0xffffffff81a4db90: b1dma_init+0x0/0x82()
[   14.172885] b1dma: revision 1.1.2.3
[   14.176886] initcall 0xffffffff81a4db90: b1dma_init+0x0/0x82() returned 0.
[   14.184886] initcall 0xffffffff81a4db90 ran for 3 msecs: b1dma_init+0x0/0x82()
[   14.192887] Calling initcall 0xffffffff81a4dc12: gigaset_init_module+0x0/0x3c()
[   14.196887] gigaset: Hansjoerg Lipp <hjlipp@web.de>, Tilman Schmidt <tilman@imap.cc>, Stefan Eilers
[   14.200887] gigaset: Driver for Gigaset 307x
[   14.204887] initcall 0xffffffff81a4dc12: gigaset_init_module+0x0/0x3c() returned 0.
[   14.212888] initcall 0xffffffff81a4dc12 ran for 7 msecs: gigaset_init_module+0x0/0x3c()
[   14.220888] Calling initcall 0xffffffff81a4dc4e: usb_gigaset_init+0x0/0xaa()
[   14.224889] usbcore: registered new interface driver usb_gigaset
[   14.228889] usb_gigaset: Hansjoerg Lipp <hjlipp@web.de>, Stefan Eilers
[   14.232889] usb_gigaset: USB Driver for Gigaset 307x using M105
[   14.236889] initcall 0xffffffff81a4dc4e: usb_gigaset_init+0x0/0xaa() returned 0.
[   14.244890] initcall 0xffffffff81a4dc4e ran for 11 msecs: usb_gigaset_init+0x0/0xaa()
[   14.252890] Calling initcall 0xffffffff81a4dcf8: bas_gigaset_init+0x0/0xb8()
[   14.260891] usbcore: registered new interface driver bas_gigaset
[   14.264891] bas_gigaset: Tilman Schmidt <tilman@imap.cc>, Hansjoerg Lipp <hjlipp@web.de>, Stefan Eilers
[   14.268891] bas_gigaset: USB Driver for Gigaset 307x
[   14.272892] initcall 0xffffffff81a4dcf8: bas_gigaset_init+0x0/0xb8() returned 0.
[   14.280892] initcall 0xffffffff81a4dcf8 ran for 11 msecs: bas_gigaset_init+0x0/0xb8()
[   14.288893] Calling initcall 0xffffffff81a4de30: mmc_blk_init+0x0/0x2e()
[   14.292893] initcall 0xffffffff81a4de30: mmc_blk_init+0x0/0x2e() returned 0.
[   14.300893] initcall 0xffffffff81a4de30 ran for 0 msecs: mmc_blk_init+0x0/0x2e()
[   14.308894] Calling initcall 0xffffffff81a4de5e: wbsd_drv_init+0x0/0xd2()
[   14.316894] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   14.320895] wbsd: Copyright(c) Pierre Ossman
[   14.324895] initcall 0xffffffff81a4de5e: wbsd_drv_init+0x0/0xd2() returned 0.
[   14.332895] initcall 0xffffffff81a4de5e ran for 7 msecs: wbsd_drv_init+0x0/0xd2()
[   14.340896] Calling initcall 0xffffffff81a4df30: tifm_sd_init+0x0/0x17()
[   14.348896] initcall 0xffffffff81a4df30: tifm_sd_init+0x0/0x17() returned 0.
[   14.352897] initcall 0xffffffff81a4df30 ran for 0 msecs: tifm_sd_init+0x0/0x17()
[   14.356897] Calling initcall 0xffffffff81a4eb62: efivars_init+0x0/0x1fe()
[   14.364897] initcall 0xffffffff81a4eb62: efivars_init+0x0/0x1fe() returned -19.
[   14.372898] initcall 0xffffffff81a4eb62 ran for 0 msecs: efivars_init+0x0/0x1fe()
[   14.380898] Calling initcall 0xffffffff809e1312: hifn_init+0x0/0xb7()
[   14.384899] Driver for HIFN 795x crypto accelerator chip has been successfully registered.
[   14.388899] initcall 0xffffffff809e1312: hifn_init+0x0/0xb7() returned 0.
[   14.396899] initcall 0xffffffff809e1312 ran for 3 msecs: hifn_init+0x0/0xb7()
[   14.404900] Calling initcall 0xffffffff81a4ee60: hid_init+0x0/0xd()
[   14.408900] initcall 0xffffffff81a4ee60: hid_init+0x0/0xd() returned 0.
[   14.416901] initcall 0xffffffff81a4ee60 ran for 0 msecs: hid_init+0x0/0xd()
[   14.424901] Calling initcall 0xffffffff81a4ee6d: usb_mouse_init+0x0/0x47()
[   14.432902] usbcore: registered new interface driver usbmouse
[   14.436902] drivers/hid/usbhid/usbmouse.c: v1.6:USB HID Boot Protocol mouse driver
[   14.440902] initcall 0xffffffff81a4ee6d: usb_mouse_init+0x0/0x47() returned 0.
[   14.448903] initcall 0xffffffff81a4ee6d ran for 11 msecs: usb_mouse_init+0x0/0x47()
[   14.456903] Calling initcall 0xffffffff81a4ef0b: init+0x0/0x17()
[   14.460903] initcall 0xffffffff81a4ef0b: init+0x0/0x17() returned 0.
[   14.468904] initcall 0xffffffff81a4ef0b ran for 0 msecs: init+0x0/0x17()
[   14.472904] Calling initcall 0xffffffff81a4ef22: init_soundcore+0x0/0x6e()
[   14.480905] initcall 0xffffffff81a4ef22: init_soundcore+0x0/0x6e() returned 0.
[   14.488905] initcall 0xffffffff81a4ef22 ran for 0 msecs: init_soundcore+0x0/0x6e()
[   14.496906] Calling initcall 0xffffffff81a50fe0: sysctl_core_init+0x0/0x17()
[   14.504906] initcall 0xffffffff81a50fe0: sysctl_core_init+0x0/0x17() returned 0.
[   14.508906] initcall 0xffffffff81a50fe0 ran for 0 msecs: sysctl_core_init+0x0/0x17()
[   14.512907] Calling initcall 0xffffffff81a51620: flow_cache_init+0x0/0x1d5()
[   14.516907] initcall 0xffffffff81a51620: flow_cache_init+0x0/0x1d5() returned 0.
[   14.524907] initcall 0xffffffff81a51620 ran for 0 msecs: flow_cache_init+0x0/0x1d5()
[   14.532908] Calling initcall 0xffffffff81a517f5: pg_init+0x0/0x2f8()
[   14.540908] pktgen v2.69: Packet Generator for packet performance testing.
[   14.544909] initcall 0xffffffff81a517f5: pg_init+0x0/0x2f8() returned 0.
[   14.552909] initcall 0xffffffff81a517f5 ran for 3 msecs: pg_init+0x0/0x2f8()
[   14.560910] Calling initcall 0xffffffff81a51b23: llc_init+0x0/0x25()
[   14.564910] initcall 0xffffffff81a51b23: llc_init+0x0/0x25() returned 0.
[   14.572910] initcall 0xffffffff81a51b23 ran for 0 msecs: llc_init+0x0/0x25()
[   14.580911] Calling initcall 0xffffffff81a51b48: snap_init+0x0/0x3a()
[   14.584911] initcall 0xffffffff81a51b48: snap_init+0x0/0x3a() returned 0.
[   14.592912] initcall 0xffffffff81a51b48 ran for 0 msecs: snap_init+0x0/0x3a()
[   14.600912] Calling initcall 0xffffffff81a530a5: sysctl_ipv4_init+0x0/0x27()
[   14.608913] initcall 0xffffffff81a530a5: sysctl_ipv4_init+0x0/0x27() returned 0.
[   14.616913] initcall 0xffffffff81a530a5 ran for 0 msecs: sysctl_ipv4_init+0x0/0x27()
[   14.624914] Calling initcall 0xffffffff81a53289: ipgre_init+0x0/0xb9()
[   14.628914] GRE over IPv4 tunneling driver
[   14.636914] initcall 0xffffffff81a53289: ipgre_init+0x0/0xb9() returned 0.
[   14.640915] initcall 0xffffffff81a53289 ran for 7 msecs: ipgre_init+0x0/0xb9()
[   14.644915] Calling initcall 0xffffffff81a533a0: ah4_init+0x0/0x72()
[   14.652915] initcall 0xffffffff81a533a0: ah4_init+0x0/0x72() returned 0.
[   14.656916] initcall 0xffffffff81a533a0 ran for 0 msecs: ah4_init+0x0/0x72()
[   14.660916] Calling initcall 0xffffffff81a53412: esp4_init+0x0/0x72()
[   14.668916] initcall 0xffffffff81a53412: esp4_init+0x0/0x72() returned 0.
[   14.672917] initcall 0xffffffff81a53412 ran for 0 msecs: esp4_init+0x0/0x72()
[   14.676917] Calling initcall 0xffffffff81a53484: ipcomp4_init+0x0/0x72()
[   14.684917] initcall 0xffffffff81a53484: ipcomp4_init+0x0/0x72() returned 0.
[   14.692918] initcall 0xffffffff81a53484 ran for 0 msecs: ipcomp4_init+0x0/0x72()
[   14.700918] Calling initcall 0xffffffff81a534f6: ipip_init+0x0/0xc0()
[   14.704919] initcall 0xffffffff81a534f6: ipip_init+0x0/0xc0() returned 0.
[   14.712919] initcall 0xffffffff81a534f6 ran for 0 msecs: ipip_init+0x0/0xc0()
[   14.720920] Calling initcall 0xffffffff81a535b6: xfrm4_beet_init+0x0/0x1c()
[   14.724920] initcall 0xffffffff81a535b6: xfrm4_beet_init+0x0/0x1c() returned 0.
[   14.732920] initcall 0xffffffff81a535b6 ran for 0 msecs: xfrm4_beet_init+0x0/0x1c()
[   14.736921] Calling initcall 0xffffffff81a535d2: tunnel4_init+0x0/0x7e()
[   14.744921] initcall 0xffffffff81a535d2: tunnel4_init+0x0/0x7e() returned 0.
[   14.752922] initcall 0xffffffff81a535d2 ran for 0 msecs: tunnel4_init+0x0/0x7e()
[   14.756922] Calling initcall 0xffffffff81a54fd2: inet_diag_init+0x0/0x70()
[   14.760922] initcall 0xffffffff81a54fd2: inet_diag_init+0x0/0x70() returned 0.
[   14.768923] initcall 0xffffffff81a54fd2 ran for 0 msecs: inet_diag_init+0x0/0x70()
[   14.776923] Calling initcall 0xffffffff81a55042: tcp_diag_init+0x0/0x17()
[   14.784924] initcall 0xffffffff81a55042: tcp_diag_init+0x0/0x17() returned 0.
[   14.788924] initcall 0xffffffff81a55042 ran for 0 msecs: tcp_diag_init+0x0/0x17()
[   14.792924] Calling initcall 0xffffffff81a55059: cubictcp_register+0x0/0x93()
[   14.800925] TCP cubic registered
[   14.804925] initcall 0xffffffff81a55059: cubictcp_register+0x0/0x93() returned 0.
[   14.812925] initcall 0xffffffff81a55059 ran for 3 msecs: cubictcp_register+0x0/0x93()
[   14.820926] Calling initcall 0xffffffff81a550ec: hstcp_register+0x0/0x17()
[   14.824926] TCP highspeed registered
[   14.828926] initcall 0xffffffff81a550ec: hstcp_register+0x0/0x17() returned 0.
[   14.836927] initcall 0xffffffff81a550ec ran for 3 msecs: hstcp_register+0x0/0x17()
[   14.844927] Calling initcall 0xffffffff81a55103: tcp_vegas_register+0x0/0x19()
[   14.852928] TCP vegas registered
[   14.856928] initcall 0xffffffff81a55103: tcp_vegas_register+0x0/0x19() returned 0.
[   14.864929] initcall 0xffffffff81a55103 ran for 3 msecs: tcp_vegas_register+0x0/0x19()
[   14.872929] Calling initcall 0xffffffff81a5511c: tcp_scalable_register+0x0/0x17()
[   14.876929] TCP scalable registered
[   14.880930] initcall 0xffffffff81a5511c: tcp_scalable_register+0x0/0x17() returned 0.
[   14.888930] initcall 0xffffffff81a5511c ran for 3 msecs: tcp_scalable_register+0x0/0x17()
[   14.892930] Calling initcall 0xffffffff81a55133: tcp_yeah_register+0x0/0x19()
[   14.900931] TCP yeah registered
[   14.904931] initcall 0xffffffff81a55133: tcp_yeah_register+0x0/0x19() returned 0.
[   14.912932] initcall 0xffffffff81a55133 ran for 3 msecs: tcp_yeah_register+0x0/0x19()
[   14.920932] Calling initcall 0xffffffff81a5537f: af_unix_init+0x0/0x71()
[   14.924932] NET: Registered protocol family 1
[   14.928933] initcall 0xffffffff81a5537f: af_unix_init+0x0/0x71() returned 0.
[   14.932933] initcall 0xffffffff81a5537f ran for 3 msecs: af_unix_init+0x0/0x71()
[   14.936933] Calling initcall 0xffffffff81a553f0: inet6_init+0x0/0x37c()
[   14.944934] NET: Registered protocol family 10
[   14.948934] lo: Disabled Privacy Extensions
[   14.956934] initcall 0xffffffff81a553f0: inet6_init+0x0/0x37c() returned 0.
[   14.964935] initcall 0xffffffff81a553f0 ran for 11 msecs: inet6_init+0x0/0x37c()
[   14.972935] Calling initcall 0xffffffff81a5630f: ah6_init+0x0/0x72()
[   14.976936] initcall 0xffffffff81a5630f: ah6_init+0x0/0x72() returned 0.
[   14.984936] initcall 0xffffffff81a5630f ran for 0 msecs: ah6_init+0x0/0x72()
[   14.992937] Calling initcall 0xffffffff81a56381: esp6_init+0x0/0x72()
[   14.996937] initcall 0xffffffff81a56381: esp6_init+0x0/0x72() returned 0.
[   15.004937] initcall 0xffffffff81a56381 ran for 0 msecs: esp6_init+0x0/0x72()
[   15.012938] Calling initcall 0xffffffff81a563f3: tunnel6_init+0x0/0x70()
[   15.020938] initcall 0xffffffff81a563f3: tunnel6_init+0x0/0x70() returned 0.
[   15.024939] initcall 0xffffffff81a563f3 ran for 0 msecs: tunnel6_init+0x0/0x70()
[   15.028939] Calling initcall 0xffffffff81a56463: xfrm6_mode_tunnel_init+0x0/0x1c()
[   15.036939] initcall 0xffffffff81a56463: xfrm6_mode_tunnel_init+0x0/0x1c() returned 0.
[   15.044940] initcall 0xffffffff81a56463 ran for 0 msecs: xfrm6_mode_tunnel_init+0x0/0x1c()
[   15.052940] Calling initcall 0xffffffff81a5647f: xfrm6_beet_init+0x0/0x1c()
[   15.060941] initcall 0xffffffff81a5647f: xfrm6_beet_init+0x0/0x1c() returned 0.
[   15.068941] initcall 0xffffffff81a5647f ran for 0 msecs: xfrm6_beet_init+0x0/0x1c()
[   15.076942] Calling initcall 0xffffffff81a5649b: mip6_init+0x0/0xc6()
[   15.080942] Mobile IPv6
[   15.084942] initcall 0xffffffff81a5649b: mip6_init+0x0/0xc6() returned 0.
[   15.092943] initcall 0xffffffff81a5649b ran for 3 msecs: mip6_init+0x0/0xc6()
[   15.096943] Calling initcall 0xffffffff81a56561: sit_init+0x0/0xb9()
[   15.104944] IPv6 over IPv4 tunneling driver
[   15.108944] sit0: Disabled Privacy Extensions
[   15.116944] initcall 0xffffffff81a56561: sit_init+0x0/0xb9() returned 0.
[   15.120945] initcall 0xffffffff81a56561 ran for 11 msecs: sit_init+0x0/0xb9()
[   15.124945] Calling initcall 0xffffffff81a56675: ip6_tunnel_init+0x0/0xeb()
[   15.132945] ip6tnl0: Disabled Privacy Extensions
[   15.136946] initcall 0xffffffff81a56675: ip6_tunnel_init+0x0/0xeb() returned 0.
[   15.144946] initcall 0xffffffff81a56675 ran for 3 msecs: ip6_tunnel_init+0x0/0xeb()
[   15.152947] Calling initcall 0xffffffff81a56760: packet_init+0x0/0x4f()
[   15.160947] NET: Registered protocol family 17
[   15.164947] initcall 0xffffffff81a56760: packet_init+0x0/0x4f() returned 0.
[   15.172948] initcall 0xffffffff81a56760 ran for 3 msecs: packet_init+0x0/0x4f()
[   15.176948] Calling initcall 0xffffffff81a567af: ipsec_pfkey_init+0x0/0xa1()
[   15.184949] NET: Registered protocol family 15
[   15.188949] initcall 0xffffffff81a567af: ipsec_pfkey_init+0x0/0xa1() returned 0.
[   15.196949] initcall 0xffffffff81a567af ran for 3 msecs: ipsec_pfkey_init+0x0/0xa1()
[   15.204950] Calling initcall 0xffffffff81a56850: ipx_init+0x0/0x112()
[   15.212950] NET: Registered protocol family 4
[   15.232952] initcall 0xffffffff81a56850: ipx_init+0x0/0x112() returned 0.
[   15.236952] initcall 0xffffffff81a56850 ran for 19 msecs: ipx_init+0x0/0x112()
[   15.240952] Calling initcall 0xffffffff81a56ad0: atalk_init+0x0/0xa0()
[   15.248953] NET: Registered protocol family 5
[   15.276954] initcall 0xffffffff81a56ad0: atalk_init+0x0/0xa0() returned 0.
[   15.280955] initcall 0xffffffff81a56ad0 ran for 26 msecs: atalk_init+0x0/0xa0()
[   15.284955] Calling initcall 0xffffffff81a56d97: nr_proto_init+0x0/0x268()
[   15.292955] NET: Registered protocol family 6
[   15.296956] initcall 0xffffffff81a56d97: nr_proto_init+0x0/0x268() returned 0.
[   15.300956] initcall 0xffffffff81a56d97 ran for 3 msecs: nr_proto_init+0x0/0x268()
[   15.304956] Calling initcall 0xffffffff81a57058: ax25_init+0x0/0xb5()
[   15.312957] NET: Registered protocol family 3
[   15.316957] initcall 0xffffffff81a57058: ax25_init+0x0/0xb5() returned 0.
[   15.324957] initcall 0xffffffff81a57058 ran for 3 msecs: ax25_init+0x0/0xb5()
[   15.332958] Calling initcall 0xffffffff81a5710d: can_init+0x0/0x112()
[   15.336958] can: controller area network core (rev 20071116 abi 8)
[   15.340958] NET: Registered protocol family 29
[   15.344959] initcall 0xffffffff81a5710d: can_init+0x0/0x112() returned 0.
[   15.352959] initcall 0xffffffff81a5710d ran for 7 msecs: can_init+0x0/0x112()
[   15.356959] Calling initcall 0xffffffff81a5721f: bcm_module_init+0x0/0x81()
[   15.364960] can: broadcast manager protocol (rev 20071116)
[   15.368960] initcall 0xffffffff81a5721f: bcm_module_init+0x0/0x81() returned 0.
[   15.376961] initcall 0xffffffff81a5721f ran for 3 msecs: bcm_module_init+0x0/0x81()
[   15.380961] Calling initcall 0xffffffff81a5786f: irlan_init+0x0/0x2c1()
[   15.388961] initcall 0xffffffff81a5786f: irlan_init+0x0/0x2c1() returned 0.
[   15.396962] initcall 0xffffffff81a5786f ran for 0 msecs: irlan_init+0x0/0x2c1()
[   15.404962] Calling initcall 0xffffffff81a57b30: ircomm_init+0x0/0xa0()
[   15.408963] IrCOMM protocol (Dag Brattli)
[   15.412963] initcall 0xffffffff81a57b30: ircomm_init+0x0/0xa0() returned 0.
[   15.420963] initcall 0xffffffff81a57b30 ran for 3 msecs: ircomm_init+0x0/0xa0()
[   15.424964] Calling initcall 0xffffffff81a57bd0: ircomm_tty_init+0x0/0x180()
[   15.432964] initcall 0xffffffff81a57bd0: ircomm_tty_init+0x0/0x180() returned 0.
[   15.440965] initcall 0xffffffff81a57bd0 ran for 0 msecs: ircomm_tty_init+0x0/0x180()
[   15.448965] Calling initcall 0xffffffff81a57f40: l2cap_init+0x0/0xf3()
[   15.456966] Bluetooth: L2CAP ver 2.9
[   15.456966] Bluetooth: L2CAP socket layer initialized
[   15.460966] initcall 0xffffffff81a57f40: l2cap_init+0x0/0xf3() returned 0.
[   15.464966] initcall 0xffffffff81a57f40 ran for 3 msecs: l2cap_init+0x0/0xf3()
[   15.468966] Calling initcall 0xffffffff81a58033: sco_init+0x0/0xfd()
[   15.476967] Bluetooth: SCO (Voice Link) ver 0.5
[   15.480967] Bluetooth: SCO socket layer initialized
[   15.484967] initcall 0xffffffff81a58033: sco_init+0x0/0xfd() returned 0.
[   15.492968] initcall 0xffffffff81a58033 ran for 7 msecs: sco_init+0x0/0xfd()
[   15.500968] Calling initcall 0xffffffff81a58130: rfcomm_init+0x0/0xc5()
[   15.504969] Bluetooth: RFCOMM socket layer initialized
[   15.508969] Bluetooth: RFCOMM TTY layer initialized
[   15.512969] Bluetooth: RFCOMM ver 1.8
[   15.516969] initcall 0xffffffff81a58130: rfcomm_init+0x0/0xc5() returned 0.
[   15.524970] initcall 0xffffffff81a58130 ran for 11 msecs: rfcomm_init+0x0/0xc5()
[   15.528970] Calling initcall 0xffffffff81a5829f: bnep_init+0x0/0x62()
[   15.536971] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[   15.540971] initcall 0xffffffff81a5829f: bnep_init+0x0/0x62() returned 0.
[   15.548971] initcall 0xffffffff81a5829f ran for 3 msecs: bnep_init+0x0/0x62()
[   15.556972] Calling initcall 0xffffffff81a5836f: hidp_init+0x0/0x2a()
[   15.560972] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[   15.564972] initcall 0xffffffff81a5836f: hidp_init+0x0/0x2a() returned 0.
[   15.572973] initcall 0xffffffff81a5836f ran for 3 msecs: hidp_init+0x0/0x2a()
[   15.576973] Calling initcall 0xffffffff81a58407: af_rxrpc_init+0x0/0x1b8()
[   15.580973] NET: Registered protocol family 33
[   15.584974] initcall 0xffffffff81a58407: af_rxrpc_init+0x0/0x1b8() returned 0.
[   15.592974] initcall 0xffffffff81a58407 ran for 3 msecs: af_rxrpc_init+0x0/0x1b8()
[   15.600975] Calling initcall 0xffffffff81a585bf: rxkad_init+0x0/0x41()
[   15.608975] RxRPC: Registered security type 2 'rxkad'
[   15.612975] initcall 0xffffffff81a585bf: rxkad_init+0x0/0x41() returned 0.
[   15.620976] initcall 0xffffffff81a585bf ran for 3 msecs: rxkad_init+0x0/0x41()
[   15.624976] Calling initcall 0xffffffff81a587b9: atm_clip_init+0x0/0xa8()
[   15.628976] initcall 0xffffffff81a587b9: atm_clip_init+0x0/0xa8() returned 0.
[   15.636977] initcall 0xffffffff81a587b9 ran for 0 msecs: atm_clip_init+0x0/0xa8()
[   15.644977] Calling initcall 0xffffffff81a58861: br2684_init+0x0/0x41()
[   15.652978] initcall 0xffffffff81a58861: br2684_init+0x0/0x41() returned 0.
[   15.656978] initcall 0xffffffff81a58861 ran for 0 msecs: br2684_init+0x0/0x41()
[   15.660978] Calling initcall 0xffffffff81a588a2: lane_module_init+0x0/0x5e()
[   15.668979] lec.c: Apr 17 2008 10:53:47 initialized
[   15.672979] initcall 0xffffffff81a588a2: lane_module_init+0x0/0x5e() returned 0.
[   15.680980] initcall 0xffffffff81a588a2 ran for 3 msecs: lane_module_init+0x0/0x5e()
[   15.688980] Calling initcall 0xffffffff81a58900: econet_proto_init+0x0/0x50()
[   15.696981] NET: Registered protocol family 19
[   15.700981] initcall 0xffffffff81a58900: econet_proto_init+0x0/0x50() returned 0.
[   15.708981] initcall 0xffffffff81a58900 ran for 3 msecs: econet_proto_init+0x0/0x50()
[   15.716982] Calling initcall 0xffffffff81a58950: dccp_init+0x0/0x3e2()
[   15.724982] initcall 0xffffffff81a58950: dccp_init+0x0/0x3e2() returned 0.
[   15.732983] initcall 0xffffffff81a58950 ran for 3 msecs: dccp_init+0x0/0x3e2()
[   15.736983] Calling initcall 0xffffffff81a58e11: dccp_v4_init+0x0/0xa4()
[   15.760985] initcall 0xffffffff81a58e11: dccp_v4_init+0x0/0xa4() returned 0.
[   15.764985] initcall 0xffffffff81a58e11 ran for 15 msecs: dccp_v4_init+0x0/0xa4()
[   15.768985] Calling initcall 0xffffffff81a58eb5: dccp_v6_init+0x0/0xa4()
[   15.776986] initcall 0xffffffff81a58eb5: dccp_v6_init+0x0/0xa4() returned 0.
[   15.784986] initcall 0xffffffff81a58eb5 ran for 0 msecs: dccp_v6_init+0x0/0xa4()
[   15.788986] Calling initcall 0xffffffff81a58f59: dccp_diag_init+0x0/0x17()
[   15.792987] initcall 0xffffffff81a58f59: dccp_diag_init+0x0/0x17() returned 0.
[   15.800987] initcall 0xffffffff81a58f59 ran for 0 msecs: dccp_diag_init+0x0/0x17()
[   15.808988] Calling initcall 0xffffffff81a58f70: ccid2_module_init+0x0/0x20()
[   15.816988] CCID: Registered CCID 2 (TCP-like)
[   15.820988] initcall 0xffffffff81a58f70: ccid2_module_init+0x0/0x20() returned 0.
[   15.828989] initcall 0xffffffff81a58f70 ran for 3 msecs: ccid2_module_init+0x0/0x20()
[   15.836989] Calling initcall 0xffffffff81a58f90: sctp_init+0x0/0x77a()
[   15.844990] SCTP: Hash tables configured (established 65536 bind 65536)
[   15.872992] sctp_init_sock(sk: ffff81003f0bd9c0)
[   15.876992] initcall 0xffffffff81a58f90: sctp_init+0x0/0x77a() returned 0.
[   15.880992] initcall 0xffffffff81a58f90 ran for 34 msecs: sctp_init+0x0/0x77a()
[   15.884992] Calling initcall 0xffffffff81a5981c: ieee80211_init+0x0/0xbd()
[   15.892993] ieee80211: 802.11 data/management/control stack, git-1.1.13
[   15.896993] ieee80211: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
[   15.900993] initcall 0xffffffff81a5981c: ieee80211_init+0x0/0xbd() returned 0.
[   15.908994] initcall 0xffffffff81a5981c ran for 7 msecs: ieee80211_init+0x0/0xbd()
[   15.912994] Calling initcall 0xffffffff81a598d9: ieee80211_crypto_init+0x0/0x17()
[   15.916994] ieee80211_crypt: registered algorithm 'NULL'
[   15.920995] initcall 0xffffffff81a598d9: ieee80211_crypto_init+0x0/0x17() returned 0.
[   15.928995] initcall 0xffffffff81a598d9 ran for 3 msecs: ieee80211_crypto_init+0x0/0x17()
[   15.936996] Calling initcall 0xffffffff81a598f0: ieee80211_crypto_wep_init+0x0/0x17()
[   15.944996] ieee80211_crypt: registered algorithm 'WEP'
[   15.948996] initcall 0xffffffff81a598f0: ieee80211_crypto_wep_init+0x0/0x17() returned 0.
[   15.956997] initcall 0xffffffff81a598f0 ran for 3 msecs: ieee80211_crypto_wep_init+0x0/0x17()
[   15.964997] Calling initcall 0xffffffff81a59907: ieee80211_crypto_ccmp_init+0x0/0x17()
[   15.972998] ieee80211_crypt: registered algorithm 'CCMP'
[   15.976998] initcall 0xffffffff81a59907: ieee80211_crypto_ccmp_init+0x0/0x17() returned 0.
[   15.988999] initcall 0xffffffff81a59907 ran for 3 msecs: ieee80211_crypto_ccmp_init+0x0/0x17()
[   15.996999] Calling initcall 0xffffffff81a1f7f2: hpet_insert_resource+0x0/0x2a()
[   16.005000] initcall 0xffffffff81a1f7f2: hpet_insert_resource+0x0/0x2a() returned 1.
[   16.009000] initcall 0xffffffff81a1f7f2 ran for 0 msecs: hpet_insert_resource+0x0/0x2a()
[   16.013000] initcall at 0xffffffff81a1f7f2: hpet_insert_resource+0x0/0x2a(): returned with error code 1
[   16.025001] Calling initcall 0xffffffff81a21d96: lapic_insert_resource+0x0/0x47()
[   16.033002] initcall 0xffffffff81a21d96: lapic_insert_resource+0x0/0x47() returned 0.
[   16.041002] initcall 0xffffffff81a21d96 ran for 0 msecs: lapic_insert_resource+0x0/0x47()
[   16.049003] Calling initcall 0xffffffff81a225a2: init_lapic_nmi_sysfs+0x0/0x3e()
[   16.057003] initcall 0xffffffff81a225a2: init_lapic_nmi_sysfs+0x0/0x3e() returned 0.
[   16.065004] initcall 0xffffffff81a225a2 ran for 0 msecs: init_lapic_nmi_sysfs+0x0/0x3e()
[   16.073004] Calling initcall 0xffffffff81a22cad: ioapic_insert_resources+0x0/0x63()
[   16.081005] initcall 0xffffffff81a22cad: ioapic_insert_resources+0x0/0x63() returned 0.
[   16.089005] initcall 0xffffffff81a22cad ran for 0 msecs: ioapic_insert_resources+0x0/0x63()
[   16.097006] Calling initcall 0xffffffff8024f28e: __stack_chk_test+0x0/0x43()
[   16.101006] Testing -fstack-protector-all feature
[   16.105006] No -fstack-protector-stack-frame!
[   16.109006] -fstack-protector-all test failed
[   16.113007] initcall 0xffffffff8024f28e: __stack_chk_test+0x0/0x43() returned 0.
[   16.121007] initcall 0xffffffff8024f28e ran for 11 msecs: __stack_chk_test+0x0/0x43()
[   16.129008] Calling initcall 0xffffffff8024f227: init_oops_id+0x0/0x28()
[   16.133008] initcall 0xffffffff8024f227: init_oops_id+0x0/0x28() returned 0.
[   16.141008] initcall 0xffffffff8024f227 ran for 0 msecs: init_oops_id+0x0/0x28()
[   16.149009] Calling initcall 0xffffffff81a263be: disable_boot_consoles+0x0/0x3f()
[   16.157009] initcall 0xffffffff81a263be: disable_boot_consoles+0x0/0x3f() returned 0.
[   16.165010] initcall 0xffffffff81a263be ran for 0 msecs: disable_boot_consoles+0x0/0x3f()
[   16.173010] Calling initcall 0xffffffff81a27720: pm_qos_power_init+0x0/0xa0()
[   16.181011] initcall 0xffffffff81a27720: pm_qos_power_init+0x0/0xa0() returned 0.
[   16.189011] initcall 0xffffffff81a27720 ran for 0 msecs: pm_qos_power_init+0x0/0xa0()
[   16.193012] Calling initcall 0xffffffff81a306b9: random32_reseed+0x0/0x88()
[   16.197012] initcall 0xffffffff81a306b9: random32_reseed+0x0/0x88() returned 0.
[   16.205012] initcall 0xffffffff81a306b9 ran for 0 msecs: random32_reseed+0x0/0x88()
[   16.213013] Calling initcall 0xffffffff81a30ecf: pci_sysfs_init+0x0/0x56()
[   16.221013] initcall 0xffffffff81a30ecf: pci_sysfs_init+0x0/0x56() returned 0.
[   16.229014] initcall 0xffffffff81a30ecf ran for 0 msecs: pci_sysfs_init+0x0/0x56()
[   16.233014] Calling initcall 0xffffffff81a34ae9: acpi_wakeup_device_init+0x0/0xac()
[   16.237014] initcall 0xffffffff81a34ae9: acpi_wakeup_device_init+0x0/0xac() returned 0.
[   16.245015] initcall 0xffffffff81a34ae9 ran for 0 msecs: acpi_wakeup_device_init+0x0/0xac()
[   16.249015] Calling initcall 0xffffffff81a3656d: seqgen_init+0x0/0x14()
[   16.253015] initcall 0xffffffff81a3656d: seqgen_init+0x0/0x14() returned 0.
[   16.261016] initcall 0xffffffff81a3656d ran for 0 msecs: seqgen_init+0x0/0x14()
[   16.269016] Calling initcall 0xffffffff806a2494: scsi_complete_async_scans+0x0/0x11a()
[   16.277017] initcall 0xffffffff806a2494: scsi_complete_async_scans+0x0/0x11a() returned 0.
[   16.285017] initcall 0xffffffff806a2494 ran for 0 msecs: scsi_complete_async_scans+0x0/0x11a()
[   16.293018] Calling initcall 0xffffffff81a4e8a0: edd_init+0x0/0x2c2()
[   16.301018] BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
[   16.305019] initcall 0xffffffff81a4e8a0: edd_init+0x0/0x2c2() returned 0.
[   16.313019] initcall 0xffffffff81a4e8a0 ran for 3 msecs: edd_init+0x0/0x2c2()
[   16.321020] Calling initcall 0xffffffff81a525ee: tcp_congestion_default+0x0/0x17()
[   16.329020] initcall 0xffffffff81a525ee: tcp_congestion_default+0x0/0x17() returned 0.
[   16.337021] initcall 0xffffffff81a525ee ran for 0 msecs: tcp_congestion_default+0x0/0x17()
[   16.345021] Calling initcall 0xffffffff81a53afd: ip_auto_config+0x0/0xf61()
[   16.349021] initcall 0xffffffff81a53afd: ip_auto_config+0x0/0xf61() returned 0.
[   16.357022] initcall 0xffffffff81a53afd ran for 0 msecs: ip_auto_config+0x0/0xf61()
[   16.365022] VFS: Cannot open root device "sda6" or unknown-block(8,6)
[   16.369023] Please append a correct "root=" boot option; here are the available partitions:
[   16.373023] 0100       4096 ram0 (driver?)
[   16.377023] 0101       4096 ram1 (driver?)
[   16.381023] 0102       4096 ram2 (driver?)
[   16.385024] 0103       4096 ram3 (driver?)
[   16.389024] 0104       4096 ram4 (driver?)
[   16.393024] 0105       4096 ram5 (driver?)
[   16.397024] 0106       4096 ram6 (driver?)
[   16.401025] 0107       4096 ram7 (driver?)
[   16.405025] 0108       4096 ram8 (driver?)
[   16.409025] 0109       4096 ram9 (driver?)
[   16.413025] 010a       4096 ram10 (driver?)
[   16.417026] 010b       4096 ram11 (driver?)
[   16.421026] 010c       4096 ram12 (driver?)
[   16.425026] 010d       4096 ram13 (driver?)
[   16.429026] 010e       4096 ram14 (driver?)
[   16.433027] 010f       4096 ram15 (driver?)
[   16.437027] 0800  244198584 sda driver: sd
[   16.441027]   0801   30716248 sda1
[   16.445027]   0802    3911827 sda2
[   16.449028]   0803          1 sda3
[   16.453028]   0805   48837568 sda5
[   16.457028]   0806   29302528 sda6
[   16.461028]   0807   29302528 sda7
[   16.465029]   0808   29302528 sda8
[   16.465029]   0809   29302528 sda9
[   16.469029]   080a   29302528 sda10
[   16.473029] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(8,6)
[   16.477029] Rebooting in 10 seconds..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
