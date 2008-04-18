Date: Fri, 18 Apr 2008 16:14:23 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] - Increase MAX_APICS for large configs
Message-ID: <20080418211423.GA4151@sgi.com>
References: <20080416163936.GA23099@sgi.com> <20080417110727.GA942@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20080417110727.GA942@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, mike travis <travis@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 01:07:27PM +0200, Ingo Molnar wrote:
> 
> * Jack Steiner <steiner@sgi.com> wrote:
> 
> > Increase the maximum number of apics when running very large 
> > configurations. This patch has no affect on most systems.
> 
> x86.git overnight random-qa testing found a boot crash and i bisected it 
> down to this patch. The config is:
> 
>  http://redhat.com/~mingo/misc/config-Thu_Apr_17_10_17_14_CEST_2008.bad
> 
> the failure is attached below. (I needed the exact boot parameters 
> listed in that bootup log to see this failure.)
> 
> it seems to be CONFIG_MAXSMP=y triggers the new more-apic-ids code and 
> that causes some breakage elsewhere. [btw., this again shows how useful 
> the CONFIG_MAXSMP debug feature is!]
> 
> 	Ingo
> 
> [    0.000000] Linux version 2.6.25-rc9-sched-devel.git-x86-latest.git (mingo@dione) (gcc version 4.2.3) #260 SMP Thu Apr 17 10:58:11 CEST 2008
> [    0.000000] Command line: root=/dev/sda6 console=ttyS0,115200 earlyprintk=serial,ttyS0,115200 debug initcall_debug apic=verbose sysrq_always_enabled ignore_loglevel selinux=0 nmi_watchdog=2 profile=0 nosmp highres=0 nolapic_timer hpet=disable idle=poll highmem=512m nopat acpi=off
> [    0.000000] BIOS-provided physical RAM map:

Has anyone seen this failure?? (Using git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git
from 4/18 AM).

I tried to reproduce the above failure on a small system & was not successful.

Switched to a larger system (XE310 Intel-based 8p, 6GB). All attempts to boot fail
with the following. I backed out the MAX_APIC change, & changed NR_CPUS=8. Still fails.

	...
	[   32.010000] ehci_hcd 0000:00:1d.7: port 6 high speed
	[   32.010000] ehci_hcd 0000:00:1d.7: GetStatus port 6 status 001005 POWER sig=se0 PE CONNECT
	[   32.054003] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
	[   32.058003] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
	[   32.062003] usb usb2: Product: UHCI Host Controller
	[   32.066004] usb usb2: Manufacturer: Linux 2.6.25-x86-latest.git uhci_hcd
	[   32.070004] usb usb2: SerialNumber: 0000:00:1d.0
	[   32.074004] PCI: Found IRQ 10 for device 0000:00:1d.1
	[   32.078004] PCI: Sharing IRQ 10 with 0000:00:1f.2
	[   32.082005] PCI: Sharing IRQ 10 with 0000:00:1f.3
	[   32.086005] PCI: Sharing IRQ 10 with 0000:04:00.1
	[   32.090005] PCI: Setting latency timer of device 0000:00:1d.1 to 64
	[   32.094005] uhci_hcd 0000:00:1d.1: UHCI Host Controller
	[   32.098006] usb 1-6: new high speed USB device using ehci_hcd and address 2
	[   32.102006] nommu_map_single: overflow 1af757720+8

Full log:


[    0.000000] Linux version 2.6.25-x86-latest.git (root@cleopatra1) (gcc version 4.1.1 20070105 (Red Hat 4.1.1-52)) #2 SMP Fri Apr 18 09:36:33 CDT 2008
[    0.000000] Command line: root=/dev/sda2 console=ttyS1,38400n8 debug initcall_debug apic=verbose sysrq_always_enabled ignore_loglevel selinux=0 nmi_watchdog=2 profile=0 nosmp highres=0 nolapic_timer hpet=disable idle=poll highmem=512m nopat acpi=off
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009bc00 (usable)
[    0.000000]  BIOS-e820: 000000000009bc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000d0000 - 00000000000d8000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000cff60000 (usable)
[    0.000000]  BIOS-e820: 00000000cff60000 - 00000000cff69000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000cff69000 - 00000000cff80000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000cff80000 - 00000000d0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 00000001b0000000 (usable)
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] using polling idle threads.
[    0.000000] x86: PAT support disabled.
[    0.000000] Entering add_active_range(0, 0, 155) 0 entries of 256 used
[    0.000000] Entering add_active_range(0, 256, 851808) 1 entries of 256 used
[    0.000000] Entering add_active_range(0, 1048576, 1769472) 2 entries of 256 used
[    0.000000] max_pfn_mapped = 1769472
[    0.000000] x86: PAT support disabled.
[    0.000000] init_memory_mapping
[    0.000000] DMI present.
[    0.000000] Entering add_active_range(0, 0, 155) 0 entries of 256 used
[    0.000000] Entering add_active_range(0, 256, 851808) 1 entries of 256 used
[    0.000000] Entering add_active_range(0, 1048576, 1769472) 2 entries of 256 used
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-10d70eb] TEXT DATA BSS
[    0.000000]   early res: 3 [9bc00-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-ffff] PGTABLE
[    0.000000]  [ffffe20000000000-ffffe20005ffffff] PMD -> [ffff810028200000-ffff81002e1fffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1769472
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0:        0 ->      155
[    0.000000]     0:      256 ->   851808
[    0.000000]     0:  1048576 ->  1769472
[    0.000000] On node 0 totalpages: 1572603
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 113 pages reserved
[    0.000000]   DMA zone: 3826 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 833432 pages, LIFO batch:31
[    0.000000]   Normal zone: 9856 pages used for memmap
[    0.000000]   Normal zone: 711040 pages, LIFO batch:31
[    0.000000]   Movable zone: 0 pages used for memmap
[    0.000000] Intel MultiProcessor Specification v1.4
[    0.000000] MPTABLE: OEM ID: INTEL    Product ID: Bridge CRB   <6>MPTABLE: Product ID: Bridge CRB   <6>MPTABLE: APIC at: 0xFEE00000
[    0.000000] Processor #0 (Bootup-CPU)
[    0.000000] Processor #4
[    0.000000] Processor #1
[    0.000000] Processor #5
[    0.000000] Processor #2
[    0.000000] Processor #6
[    0.000000] Processor #3
[    0.000000] Processor #7
[    0.000000] I/O APIC #8 Version 32 at 0xFEC00000.
[    0.000000] I/O APIC #9 Version 32 at 0xFEC80000.
[    0.000000] Setting APIC routing to flat
[    0.000000] Processors: 8
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (00000000fec80000)
[    0.000000] Allocating PCI resources starting at d1000000 (gap: d0000000:10000000)
[    0.000000] SMP: Allowing 8 CPUs, 0 hotplug CPUs
[    0.000000] PERCPU: Allocating 22856 bytes of per cpu data
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1548298
[    0.000000] Kernel command line: root=/dev/sda2 console=ttyS1,38400n8 debug initcall_debug apic=verbose sysrq_always_enabled ignore_loglevel selinux=0 nmi_watchdog=2 profile=0 nosmp highres=0 nolapic_timer hpet=disable idle=poll highmem=512m nopat acpi=off
[    0.000000] debug: sysrq always enabled.
[    0.000000] kernel profiling enabled (shift: 0)
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[    0.000000] TSC calibrated against PIT
[    0.000000] time.c: Detected 2327.539 MHz processor.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [ttyS1] enabled
[    0.000000] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.000000] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] Memory: 6127676k/7077888k available (8955k kernel code, 162068k reserved, 3789k data, 520k init)
[    0.000000] CPA: page pool initialized 1 of 1 pages preallocated
[    0.084005] Calibrating delay using timer specific routine.. 4658.74 BogoMIPS (lpj=9317486)
[    0.092005] Security Framework initialized
[    0.096006] Capability LSM initialized
[    0.100006] Mount-cache hash table entries: 256
[    0.104006] Initializing cgroup subsys cpuacct
[    0.108006] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.116007] CPU: L2 cache: 4096K
[    0.120007] CPU: Physical Processor ID: 0
[    0.124007] CPU: Processor Core ID: 0
[    0.128008] CPU0: Thermal monitoring handled by SMI
[    0.132008] SMP alternatives: switching to UP code
[    0.144009] SMP mode deactivated,forcing use of dummy APIC emulation.
[    0.148009] SMP disabled
[    0.152009] Brought up 1 CPUs
[    0.156009] Total of 1 processors activated (4658.74 BogoMIPS).
[    0.164010] Calling initcall 0xffffffff80ee09f0: net_ns_init+0x0/0x170()
[    0.172010] net_namespace: 408 bytes
[    0.176011] initcall 0xffffffff80ee09f0: net_ns_init+0x0/0x170() returned 0.
[    0.188011] initcall 0xffffffff80ee09f0 ran for 3 msecs: net_ns_init+0x0/0x170()
[    0.196012] Calling initcall 0xffffffff80ab5020: init_smp_flush+0x0/0x78()
[    0.204012] initcall 0xffffffff80ab5020: init_smp_flush+0x0/0x78() returned 0.
[    0.216013] initcall 0xffffffff80ab5020 ran for 0 msecs: init_smp_flush+0x0/0x78()
[    0.224014] Calling initcall 0xffffffff80eb0e60: sysctl_init+0x0/0x5a()
[    0.236014] initcall 0xffffffff80eb0e60: sysctl_init+0x0/0x5a() returned 0.
[    0.248015] initcall 0xffffffff80eb0e60 ran for 0 msecs: sysctl_init+0x0/0x5a()
[    0.256016] Calling initcall 0xffffffff80eb1a70: ksysfs_init+0x0/0xdf()
[    0.264016] initcall 0xffffffff80eb1a70: ksysfs_init+0x0/0xdf() returned 0.
[    0.276017] initcall 0xffffffff80eb1a70 ran for 0 msecs: ksysfs_init+0x0/0xdf()
[    0.284017] Calling initcall 0xffffffff80eb1f50: init_jiffies_clocksource+0x0/0x39()
[    0.292018] initcall 0xffffffff80eb1f50: init_jiffies_clocksource+0x0/0x39() returned 0.
[    0.304019] initcall 0xffffffff80eb1f50 ran for 0 msecs: init_jiffies_clocksource+0x0/0x39()
[    0.312019] Calling initcall 0xffffffff80eb2200: pm_init+0x0/0x80()
[    0.320020] initcall 0xffffffff80eb2200: pm_init+0x0/0x80() returned 0.
[    0.332020] initcall 0xffffffff80eb2200 ran for 0 msecs: pm_init+0x0/0x80()
[    0.340021] Calling initcall 0xffffffff80eb5feb: filelock_init+0x0/0x65()
[    0.348021] initcall 0xffffffff80eb5feb: filelock_init+0x0/0x65() returned 0.
[    0.360022] initcall 0xffffffff80eb5feb ran for 0 msecs: filelock_init+0x0/0x65()
[    0.368023] Calling initcall 0xffffffff80eb6d35: init_script_binfmt+0x0/0x39()
[    0.376023] initcall 0xffffffff80eb6d35: init_script_binfmt+0x0/0x39() returned 0.
[    0.388024] initcall 0xffffffff80eb6d35 ran for 0 msecs: init_script_binfmt+0x0/0x39()
[    0.396024] Calling initcall 0xffffffff80eb6d6e: init_elf_binfmt+0x0/0x39()
[    0.408025] initcall 0xffffffff80eb6d6e: init_elf_binfmt+0x0/0x39() returned 0.
[    0.420026] initcall 0xffffffff80eb6d6e ran for 0 msecs: init_elf_binfmt+0x0/0x39()
[    0.428026] Calling initcall 0xffffffff80eb6da7: init_compat_elf_binfmt+0x0/0x39()
[    0.436027] initcall 0xffffffff80eb6da7: init_compat_elf_binfmt+0x0/0x39() returned 0.
[    0.444027] initcall 0xffffffff80eb6da7 ran for 0 msecs: init_compat_elf_binfmt+0x0/0x39()
[    0.452028] Calling initcall 0xffffffff80eba033: debugfs_init+0x0/0x7d()
[    0.460028] initcall 0xffffffff80eba033: debugfs_init+0x0/0x7d() returned 0.
[    0.472029] initcall 0xffffffff80eba033 ran for 0 msecs: debugfs_init+0x0/0x7d()
[    0.480030] Calling initcall 0xffffffff80ebaa06: securityfs_init+0x0/0x76()
[    0.488030] initcall 0xffffffff80ebaa06: securityfs_init+0x0/0x76() returned 0.
[    0.500031] initcall 0xffffffff80ebaa06 ran for 0 msecs: securityfs_init+0x0/0x76()
[    0.508031] Calling initcall 0xffffffff80ebbdc0: random32_init+0x0/0x85()
[    0.516032] initcall 0xffffffff80ebbdc0: random32_init+0x0/0x85() returned 0.
[    0.528033] initcall 0xffffffff80ebbdc0 ran for 0 msecs: random32_init+0x0/0x85()
[    0.536033] Calling initcall 0xffffffff808d6fe5: virtio_init+0x0/0x4f()
[    0.544034] initcall 0xffffffff808d6fe5: virtio_init+0x0/0x4f() returned 0.
[    0.556034] initcall 0xffffffff808d6fe5 ran for 0 msecs: virtio_init+0x0/0x4f()
[    0.564035] Calling initcall 0xffffffff80ee0810: sock_init+0x0/0x90()
[    0.572035] initcall 0xffffffff80ee0810: sock_init+0x0/0x90() returned 0.
[    0.584036] initcall 0xffffffff80ee0810 ran for 0 msecs: sock_init+0x0/0x90()
[    0.592037] Calling initcall 0xffffffff80ee1800: netpoll_init+0x0/0x60()
[    0.600037] initcall 0xffffffff80ee1800: netpoll_init+0x0/0x60() returned 0.
[    0.612038] initcall 0xffffffff80ee1800 ran for 0 msecs: netpoll_init+0x0/0x60()
[    0.620038] Calling initcall 0xffffffff80ee195c: netlink_proto_init+0x0/0x18d()
[    0.632039] NET: Registered protocol family 16
[    0.636039] initcall 0xffffffff80ee195c: netlink_proto_init+0x0/0x18d() returned 0.
[    0.648040] initcall 0xffffffff80ee195c ran for 3 msecs: netlink_proto_init+0x0/0x18d()
[    0.656041] Calling initcall 0xffffffff80ebbc30: kobject_uevent_init+0x0/0x6f()
[    0.664041] initcall 0xffffffff80ebbc30: kobject_uevent_init+0x0/0x6f() returned 0.
[    0.676042] initcall 0xffffffff80ebbc30 ran for 0 msecs: kobject_uevent_init+0x0/0x6f()
[    0.684042] Calling initcall 0xffffffff80ebbfaf: pcibus_class_init+0x0/0x39()
[    0.692043] initcall 0xffffffff80ebbfaf: pcibus_class_init+0x0/0x39() returned 0.
[    0.704044] initcall 0xffffffff80ebbfaf ran for 0 msecs: pcibus_class_init+0x0/0x39()
[    0.712044] Calling initcall 0xffffffff80ebc7fb: pci_driver_init+0x0/0x45()
[    0.720045] initcall 0xffffffff80ebc7fb: pci_driver_init+0x0/0x45() returned 0.
[    0.732045] initcall 0xffffffff80ebc7fb ran for 0 msecs: pci_driver_init+0x0/0x45()
[    0.740046] Calling initcall 0xffffffff80ebd23b: backlight_class_init+0x0/0x75()
[    0.748046] initcall 0xffffffff80ebd23b: backlight_class_init+0x0/0x75() returned 0.
[    0.760047] initcall 0xffffffff80ebd23b ran for 0 msecs: backlight_class_init+0x0/0x75()
[    0.768048] Calling initcall 0xffffffff80ebfbfb: video_output_class_init+0x0/0x39()
[    0.780048] initcall 0xffffffff80ebfbfb: video_output_class_init+0x0/0x39() returned 0.
[    0.792049] initcall 0xffffffff80ebfbfb ran for 0 msecs: video_output_class_init+0x0/0x39()
[    0.800050] Calling initcall 0xffffffff80ec1579: dock_init+0x0/0x78()
[    0.808050] ACPI Exception (utmutex-0263): AE_BAD_PARAMETER, Thread FFFF8101AFC5F750 could not acquire Mutex [1] [20070126]
[    0.820051] No dock devices found.
[    0.824051] initcall 0xffffffff80ec1579: dock_init+0x0/0x78() returned 0.
[    0.836052] initcall 0xffffffff80ec1579 ran for 15 msecs: dock_init+0x0/0x78()
[    0.844052] Calling initcall 0xffffffff80ec2c10: tty_class_init+0x0/0x52()
[    0.852053] initcall 0xffffffff80ec2c10: tty_class_init+0x0/0x52() returned 0.
[    0.864054] initcall 0xffffffff80ec2c10 ran for 0 msecs: tty_class_init+0x0/0x52()
[    0.872054] Calling initcall 0xffffffff80ec361d: vtconsole_class_init+0x0/0xf7()
[    0.880055] initcall 0xffffffff80ec361d: vtconsole_class_init+0x0/0xf7() returned 0.
[    0.892055] initcall 0xffffffff80ec361d ran for 0 msecs: vtconsole_class_init+0x0/0xf7()
[    0.900056] Calling initcall 0xffffffff80edffdf: early_fill_mp_bus_info+0x0/0x831()
[    0.908056] initcall 0xffffffff80edffdf: early_fill_mp_bus_info+0x0/0x831() returned 0.
[    0.920057] initcall 0xffffffff80edffdf ran for 0 msecs: early_fill_mp_bus_info+0x0/0x831()
[    0.928058] Calling initcall 0xffffffff80ea71d5: arch_kdebugfs_init+0x0/0x2e()
[    0.936058] initcall 0xffffffff80ea71d5: arch_kdebugfs_init+0x0/0x2e() returned 0.
[    0.948059] initcall 0xffffffff80ea71d5 ran for 0 msecs: arch_kdebugfs_init+0x0/0x2e()
[    0.956059] Calling initcall 0xffffffff80ea8340: mtrr_if_init+0x0/0xb0()
[    0.964060] initcall 0xffffffff80ea8340: mtrr_if_init+0x0/0xb0() returned 0.
[    0.976061] initcall 0xffffffff80ea8340 ran for 0 msecs: mtrr_if_init+0x0/0xb0()
[    0.984061] Calling initcall 0xffffffff80ebd020: acpi_pci_init+0x0/0x70()
[    0.992062] initcall 0xffffffff80ebd020: acpi_pci_init+0x0/0x70() returned 0.
[    1.004062] initcall 0xffffffff80ebd020 ran for 0 msecs: acpi_pci_init+0x0/0x70()
[    1.012063] Calling initcall 0xffffffff80ec10ef: init_acpi_device_notify+0x0/0x73()
[    1.020063] initcall 0xffffffff80ec10ef: init_acpi_device_notify+0x0/0x73() returned 0.
[    1.032064] initcall 0xffffffff80ec10ef ran for 0 msecs: init_acpi_device_notify+0x0/0x73()
[    1.040065] Calling initcall 0xffffffff80edee30: pci_access_init+0x0/0x6a()
[    1.048065] PCI: Using configuration type 1 for base access
[    1.052065] initcall 0xffffffff80edee30: pci_access_init+0x0/0x6a() returned 0.
[    1.064066] initcall 0xffffffff80edee30 ran for 3 msecs: pci_access_init+0x0/0x6a()
[    1.072067] Calling initcall 0xffffffff80ea7170: topology_init+0x0/0x65()
[    1.080067] initcall 0xffffffff80ea7170: topology_init+0x0/0x65() returned 0.
[    1.092068] initcall 0xffffffff80ea7170 ran for 0 msecs: topology_init+0x0/0x65()
[    1.100068] Calling initcall 0xffffffff80ea7f5d: mtrr_init_finialize+0x0/0x5f()
[    1.108069] initcall 0xffffffff80ea7f5d: mtrr_init_finialize+0x0/0x5f() returned 0.
[    1.120070] initcall 0xffffffff80ea7f5d ran for 0 msecs: mtrr_init_finialize+0x0/0x5f()
[    1.128070] Calling initcall 0xffffffff80eb154a: param_sysfs_init+0x0/0x222()
[    1.140071] initcall 0xffffffff80eb154a: param_sysfs_init+0x0/0x222() returned 0.
[    1.152072] initcall 0xffffffff80eb154a ran for 3 msecs: param_sysfs_init+0x0/0x222()
[    1.160072] Calling initcall 0xffffffff8027ed00: pm_sysrq_init+0x0/0x45()
[    1.168073] initcall 0xffffffff8027ed00: pm_sysrq_init+0x0/0x45() returned 0.
[    1.180073] initcall 0xffffffff8027ed00 ran for 0 msecs: pm_sysrq_init+0x0/0x45()
[    1.188074] Calling initcall 0xffffffff80eb5305: readahead_init+0x0/0x39()
[    1.196074] initcall 0xffffffff80eb5305: readahead_init+0x0/0x39() returned 0.
[    1.204075] initcall 0xffffffff80eb5305 ran for 0 msecs: readahead_init+0x0/0x39()
[    1.212075] Calling initcall 0xffffffff80eb68e0: init_bio+0x0/0xed()
[    1.220076] initcall 0xffffffff80eb68e0: init_bio+0x0/0xed() returned 0.
[    1.232077] initcall 0xffffffff80eb68e0 ran for 0 msecs: init_bio+0x0/0xed()
[    1.240077] Calling initcall 0xffffffff80ebb921: blk_settings_init+0x0/0x54()
[    1.252078] initcall 0xffffffff80ebb921: blk_settings_init+0x0/0x54() returned 0.
[    1.264079] initcall 0xffffffff80ebb921 ran for 0 msecs: blk_settings_init+0x0/0x54()
[    1.272079] Calling initcall 0xffffffff80ebb975: blk_ioc_init+0x0/0x52()
[    1.280080] initcall 0xffffffff80ebb975: blk_ioc_init+0x0/0x52() returned 0.
[    1.288080] initcall 0xffffffff80ebb975 ran for 0 msecs: <4>Clocksource tsc unstable (delta = 707367446 ns)
[    1.296081] blk_ioc_init+0x0/0x52()
[    1.300081] Calling initcall 0xffffffff80ebb9c7: genhd_device_init+0x0/0x78()
[    1.308081] initcall 0xffffffff80ebb9c7: genhd_device_init+0x0/0x78() returned 0.
[    1.320082] initcall 0xffffffff80ebb9c7 ran for 0 msecs: genhd_device_init+0x0/0x78()
[    1.328083] Calling initcall 0xffffffff80ebd13c: fbmem_init+0x0/0xc1()
[    1.336083] initcall 0xffffffff80ebd13c: fbmem_init+0x0/0xc1() returned 0.
[    1.348084] initcall 0xffffffff80ebd13c ran for 0 msecs: fbmem_init+0x0/0xc1()
[    1.356084] Calling initcall 0xffffffff80ec0eba: acpi_init+0x0/0x235()
[    1.364085] ACPI: Interpreter disabled.
[    1.368085] initcall 0xffffffff80ec0eba: acpi_init+0x0/0x235() returned -19.
[    1.380086] initcall 0xffffffff80ec0eba ran for 3 msecs: acpi_init+0x0/0x235()
[    1.388086] Calling initcall 0xffffffff80ec1162: acpi_scan_init+0x0/0x146()
[    1.400087] initcall 0xffffffff80ec1162: acpi_scan_init+0x0/0x146() returned 0.
[    1.412088] initcall 0xffffffff80ec1162 ran for 0 msecs: acpi_scan_init+0x0/0x146()
[    1.420088] Calling initcall 0xffffffff80ec12a8: acpi_ec_init+0x0/0x8b()
[    1.428089] initcall 0xffffffff80ec12a8: acpi_ec_init+0x0/0x8b() returned 0.
[    1.440090] initcall 0xffffffff80ec12a8 ran for 0 msecs: acpi_ec_init+0x0/0x8b()
[    1.448090] Calling initcall 0xffffffff80ec15f1: acpi_pci_root_init+0x0/0x50()
[    1.456091] initcall 0xffffffff80ec15f1: acpi_pci_root_init+0x0/0x50() returned 0.
[    1.468091] initcall 0xffffffff80ec15f1 ran for 0 msecs: acpi_pci_root_init+0x0/0x50()
[    1.476092] Calling initcall 0xffffffff80ec18dd: acpi_pci_link_init+0x0/0x70()
[    1.484092] initcall 0xffffffff80ec18dd: acpi_pci_link_init+0x0/0x70() returned 0.
[    1.496093] initcall 0xffffffff80ec18dd ran for 0 msecs: acpi_pci_link_init+0x0/0x70()
[    1.504094] Calling initcall 0xffffffff80ec194d: acpi_power_init+0x0/0x9f()
[    1.512094] initcall 0xffffffff80ec194d: acpi_power_init+0x0/0x9f() returned 0.
[    1.524095] initcall 0xffffffff80ec194d ran for 0 msecs: acpi_power_init+0x0/0x9f()
[    1.532095] Calling initcall 0xffffffff80ec1a54: acpi_system_init+0x0/0x1c4()
[    1.540096] initcall 0xffffffff80ec1a54: acpi_system_init+0x0/0x1c4() returned 0.
[    1.552097] initcall 0xffffffff80ec1a54 ran for 0 msecs: acpi_system_init+0x0/0x1c4()
[    1.560097] Calling initcall 0xffffffff80ec1d40: pnp_init+0x0/0x45()
[    1.568098] Linux Plug and Play Support v0.97 (c) Adam Belay
[    1.572098] initcall 0xffffffff80ec1d40: pnp_init+0x0/0x45() returned 0.
[    1.584099] initcall 0xffffffff80ec1d40 ran for 3 msecs: pnp_init+0x0/0x45()
[    1.592099] Calling initcall 0xffffffff80ec208f: pnpacpi_init+0x0/0xb6()
[    1.604100] pnp: PnP ACPI: disabled
[    1.608100] initcall 0xffffffff80ec208f: pnpacpi_init+0x0/0xb6() returned 0.
[    1.620101] initcall 0xffffffff80ec208f ran for 3 msecs: pnpacpi_init+0x0/0xb6()
[    1.628101] Calling initcall 0xffffffff80ec3200: misc_init+0x0/0xac()
[    1.636102] initcall 0xffffffff80ec3200: misc_init+0x0/0xac() returned 0.
[    1.648103] initcall 0xffffffff80ec3200 ran for 0 msecs: misc_init+0x0/0xac()
[    1.656103] Calling initcall 0xffffffff80ecd237: tifm_init+0x0/0x9c()
[    1.664104] initcall 0xffffffff80ecd237: tifm_init+0x0/0x9c() returned 0.
[    1.676104] initcall 0xffffffff80ecd237 ran for 0 msecs: tifm_init+0x0/0x9c()
[    1.684105] Calling initcall 0xffffffff80ed27ea: init_dvbdev+0x0/0xe6()
[    1.692105] initcall 0xffffffff80ed27ea: init_dvbdev+0x0/0xe6() returned 0.
[    1.704106] initcall 0xffffffff80ed27ea ran for 0 msecs: init_dvbdev+0x0/0xe6()
[    1.712107] Calling initcall 0xffffffff80ed2c60: init_scsi+0x0/0xc7()
[    1.720107] SCSI subsystem initialized
[    1.724107] initcall 0xffffffff80ed2c60: init_scsi+0x0/0xc7() returned 0.
[    1.736108] initcall 0xffffffff80ed2c60 ran for 3 msecs: init_scsi+0x0/0xc7()
[    1.744109] Calling initcall 0xffffffff80ed6a40: ata_init+0x0/0x3f7()
[    1.752109] libata version 3.00 loaded.
[    1.756109] initcall 0xffffffff80ed6a40: ata_init+0x0/0x3f7() returned 0.
[    1.764110] initcall 0xffffffff80ed6a40 ran for 3 msecs: ata_init+0x0/0x3f7()
[    1.772110] Calling initcall 0xffffffff80ed7a10: usb_init+0x0/0x135()
[    1.784111] usbcore: registered new interface driver usbfs
[    1.788111] usbcore: registered new interface driver hub
[    1.792112] usbcore: registered new device driver usb
[    1.796112] initcall 0xffffffff80ed7a10: usb_init+0x0/0x135() returned 0.
[    1.808113] initcall 0xffffffff80ed7a10 ran for 11 msecs: usb_init+0x0/0x135()
[    1.816113] Calling initcall 0xffffffff80ed91f0: serio_init+0x0/0xc0()
[    1.824114] initcall 0xffffffff80ed91f0: serio_init+0x0/0xc0() returned 0.
[    1.836114] initcall 0xffffffff80ed91f0 ran for 0 msecs: serio_init+0x0/0xc0()
[    1.844115] Calling initcall 0xffffffff80ed97db: gameport_init+0x0/0xb5()
[    1.852115] initcall 0xffffffff80ed97db: gameport_init+0x0/0xb5() returned 0.
[    1.864116] initcall 0xffffffff80ed97db ran for 0 msecs: gameport_init+0x0/0xb5()
[    1.872117] Calling initcall 0xffffffff80ed98e0: input_init+0x0/0x150()
[    1.880117] initcall 0xffffffff80ed98e0: input_init+0x0/0x150() returned 0.
[    1.892118] initcall 0xffffffff80ed98e0 ran for 0 msecs: input_init+0x0/0x150()
[    1.900118] Calling initcall 0xffffffff80edaaea: power_supply_class_init+0x0/0x58()
[    1.908119] initcall 0xffffffff80edaaea: power_supply_class_init+0x0/0x58() returned 0.
[    1.920120] initcall 0xffffffff80edaaea ran for 0 msecs: power_supply_class_init+0x0/0x58()
[    1.928120] Calling initcall 0xffffffff80edabc0: hwmon_init+0x0/0x70()
[    1.936121] initcall 0xffffffff80edabc0: hwmon_init+0x0/0x70() returned 0.
[    1.948121] initcall 0xffffffff80edabc0 ran for 0 msecs: hwmon_init+0x0/0x70()
[    1.956122] Calling initcall 0xffffffff80edc600: thermal_init+0x0/0x60()
[    1.964122] initcall 0xffffffff80edc600: thermal_init+0x0/0x60() returned 0.
[    1.976123] initcall 0xffffffff80edc600 ran for 0 msecs: thermal_init+0x0/0x60()
[    1.984124] Calling initcall 0xffffffff80edd310: mmc_init+0x0/0xa0()
[    1.996124] initcall 0xffffffff80edd310: mmc_init+0x0/0xa0() returned 0.
[    2.008125] initcall 0xffffffff80edd310 ran for 0 msecs: mmc_init+0x0/0xa0()
[    2.016126] Calling initcall 0xffffffff80edd534: leds_init+0x0/0x5c()
[    2.024126] initcall 0xffffffff80edd534: leds_init+0x0/0x5c() returned 0.
[    2.036127] initcall 0xffffffff80edd534 ran for 0 msecs: leds_init+0x0/0x5c()
[    2.044127] Calling initcall 0xffffffff80edee9a: pci_acpi_init+0x0/0xe6()
[    2.052128] initcall 0xffffffff80edee9a: pci_acpi_init+0x0/0xe6() returned 0.
[    2.064129] initcall 0xffffffff80edee9a ran for 0 msecs: pci_acpi_init+0x0/0xe6()
[    2.072129] Calling initcall 0xffffffff80edef80: pci_legacy_init+0x0/0x130()
[    2.080130] PCI: Probing PCI hardware
[    2.084130] PCI: Probing PCI hardware (bus 00)
[    2.088130] pci 0000:00:1f.0: Force enabled HPET at 0xfed00000
[    2.092130] PCI: Transparent bridge - 0000:00:1e.0
[    2.096131] initcall 0xffffffff80edef80: pci_legacy_init+0x0/0x130() returned 0.
[    2.108131] initcall 0xffffffff80edef80 ran for 15 msecs: pci_legacy_init+0x0/0x130()
[    2.116132] Calling initcall 0xffffffff80edf7c7: pcibios_irq_init+0x0/0x529()
[    2.124132] PCI: Using IRQ router PIIX/ICH [8086/2670] at 0000:00:1f.0
[    2.128133] PCI: setting IRQ 7 as level-triggered
[    2.132133] PCI: Found IRQ 7 for device 0000:00:00.0
[    2.136133] PCI: Sharing IRQ 7 with 0000:00:02.0
[    2.140133] PCI: Sharing IRQ 7 with 0000:00:04.0
[    2.144134] PCI: Sharing IRQ 7 with 0000:00:06.0
[    2.148134] PCI: Sharing IRQ 7 with 0000:00:08.0
[    2.152134] PCI: Sharing IRQ 7 with 0000:01:00.0
[    2.156134] PCI: Sharing IRQ 7 with 0000:02:00.0
[    2.160135] PCI: Sharing IRQ 7 with 0000:06:00.0
[    2.164135] initcall 0xffffffff80edf7c7: pcibios_irq_init+0x0/0x529() returned 0.
[    2.176136] initcall 0xffffffff80edf7c7 ran for 38 msecs: pcibios_irq_init+0x0/0x529()
[    2.184136] Calling initcall 0xffffffff80edfcf0: pcibios_init+0x0/0xa1()
[    2.192137] initcall 0xffffffff80edfcf0: pcibios_init+0x0/0xa1() returned 0.
[    2.204137] initcall 0xffffffff80edfcf0 ran for 0 msecs: pcibios_init+0x0/0xa1()
[    2.212138] Calling initcall 0xffffffff80ee0923: proto_init+0x0/0x56()
[    2.220138] initcall 0xffffffff80ee0923: proto_init+0x0/0x56() returned 0.
[    2.232139] initcall 0xffffffff80ee0923 ran for 0 msecs: proto_init+0x0/0x56()
[    2.240140] Calling initcall 0xffffffff80ee0e99: net_dev_init+0x0/0x172()
[    2.252140] initcall 0xffffffff80ee0e99: net_dev_init+0x0/0x172() returned 0.
[    2.264141] initcall 0xffffffff80ee0e99 ran for 0 msecs: net_dev_init+0x0/0x172()
[    2.272142] Calling initcall 0xffffffff80ee1140: neigh_init+0x0/0x99()
[    2.280142] initcall 0xffffffff80ee1140: neigh_init+0x0/0x99() returned 0.
[    2.292143] initcall 0xffffffff80ee1140 ran for 0 msecs: neigh_init+0x0/0x99()
[    2.300143] Calling initcall 0xffffffff80ee1ae9: genl_init+0x0/0xf7()
[    2.324145] initcall 0xffffffff80ee1ae9: genl_init+0x0/0xf7() returned 0.
[    2.336146] initcall 0xffffffff80ee1ae9 ran for 15 msecs: genl_init+0x0/0xf7()
[    2.344146] Calling initcall 0xffffffff80ee7810: wanrouter_init+0x0/0x76()
[    2.352147] Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Technologies Inc.
[    2.356147] initcall 0xffffffff80ee7810: wanrouter_init+0x0/0x76() returned 0.
[    2.368148] initcall 0xffffffff80ee7810 ran for 3 msecs: wanrouter_init+0x0/0x76()
[    2.376148] Calling initcall 0xffffffff80ee83a0: irda_init+0x0/0xe0()
[    2.388149] irda_init()
[    2.392149] NET: Registered protocol family 23
[    2.396149] initcall 0xffffffff80ee83a0: irda_init+0x0/0xe0() returned 0.
[    2.408150] initcall 0xffffffff80ee83a0 ran for 7 msecs: irda_init+0x0/0xe0()
[    2.416151] Calling initcall 0xffffffff80ee8a90: bt_init+0x0/0x85()
[    2.424151] Bluetooth: Core ver 2.11
[    2.428151] NET: Registered protocol family 31
[    2.432152] Bluetooth: HCI device and connection manager initialized
[    2.436152] Bluetooth: HCI socket layer initialized
[    2.440152] initcall 0xffffffff80ee8a90: bt_init+0x0/0x85() returned 0.
[    2.452153] initcall 0xffffffff80ee8a90 ran for 15 msecs: bt_init+0x0/0x85()
[    2.460153] Calling initcall 0xffffffff80ee9540: atm_init+0x0/0xd5()
[    2.468154] NET: Registered protocol family 8
[    2.472154] NET: Registered protocol family 20
[    2.476154] initcall 0xffffffff80ee9540: atm_init+0x0/0xd5() returned 0.
[    2.488155] initcall 0xffffffff80ee9540 ran for 7 msecs: atm_init+0x0/0xd5()
[    2.496156] Calling initcall 0xffffffff80eea92e: wireless_nlevent_init+0x0/0x62()
[    2.504156] initcall 0xffffffff80eea92e: wireless_nlevent_init+0x0/0x62() returned 0.
[    2.516157] initcall 0xffffffff80eea92e ran for 0 msecs: wireless_nlevent_init+0x0/0x62()
[    2.524157] Calling initcall 0xffffffff80a49300: cfg80211_init+0x0/0x75()
[    2.532158] initcall 0xffffffff80a49300: cfg80211_init+0x0/0x75() returned 0.
[    2.544159] initcall 0xffffffff80a49300 ran for 0 msecs: cfg80211_init+0x0/0x75()
[    2.552159] Calling initcall 0xffffffff80eea990: ieee80211_init+0x0/0x47()
[    2.560160] initcall 0xffffffff80eea990: ieee80211_init+0x0/0x47() returned 0.
[    2.572160] initcall 0xffffffff80eea990 ran for 0 msecs: ieee80211_init+0x0/0x47()
[    2.580161] Calling initcall 0xffffffff80eeaba0: sysctl_init+0x0/0x55()
[    2.588161] initcall 0xffffffff80eeaba0: sysctl_init+0x0/0x55() returned 0.
[    2.600162] initcall 0xffffffff80eeaba0 ran for 0 msecs: sysctl_init+0x0/0x55()
[    2.608163] Calling initcall 0xffffffff80ea6fd6: pci_iommu_init+0x0/0x35()
[    2.616163] initcall 0xffffffff80ea6fd6: pci_iommu_init+0x0/0x35() returned 0.
[    2.628164] initcall 0xffffffff80ea6fd6 ran for 0 msecs: pci_iommu_init+0x0/0x35()
[    2.636164] Calling initcall 0xffffffff80eaeae0: hpet_late_init+0x0/0x60()
[    2.644165] initcall 0xffffffff80eaeae0: hpet_late_init+0x0/0x60() returned -19.
[    2.656166] initcall 0xffffffff80eaeae0 ran for 0 msecs: hpet_late_init+0x0/0x60()
[    2.664166] Calling initcall 0xffffffff80eb1d90: clocksource_done_booting+0x0/0x38()
[    2.672167] initcall 0xffffffff80eb1d90: clocksource_done_booting+0x0/0x38() returned 0.
[    2.684167] initcall 0xffffffff80eb1d90 ran for 0 msecs: clocksource_done_booting+0x0/0x38()
[    2.692168] Calling initcall 0xffffffff80eb5f28: init_pipe_fs+0x0/0x71()
[    2.700168] initcall 0xffffffff80eb5f28: init_pipe_fs+0x0/0x71() returned 0.
[    2.708169] initcall 0xffffffff80eb5f28 ran for 0 msecs: init_pipe_fs+0x0/0x71()
[    2.716169] Calling initcall 0xffffffff80eb6a75: eventpoll_init+0x0/0xae()
[    2.724170] initcall 0xffffffff80eb6a75: eventpoll_init+0x0/0xae() returned 0.
[    2.736171] initcall 0xffffffff80eb6a75 ran for 0 msecs: eventpoll_init+0x0/0xae()
[    2.744171] Calling initcall 0xffffffff80eb6b23: anon_inode_init+0x0/0x15d()
[    2.756172] initcall 0xffffffff80eb6b23: anon_inode_init+0x0/0x15d() returned 0.
[    2.768173] initcall 0xffffffff80eb6b23 ran for 0 msecs: anon_inode_init+0x0/0x15d()
[    2.776173] Calling initcall 0xffffffff80ec1c18: acpi_event_init+0x0/0x7a()
[    2.784174] initcall 0xffffffff80ec1c18: acpi_event_init+0x0/0x7a() returned 0.
[    2.796174] initcall 0xffffffff80ec1c18 ran for 0 msecs: acpi_event_init+0x0/0x7a()
[    2.804175] Calling initcall 0xffffffff80ec1f01: pnp_system_init+0x0/0x3f()
[    2.812175] initcall 0xffffffff80ec1f01: pnp_system_init+0x0/0x3f() returned 0.
[    2.824176] initcall 0xffffffff80ec1f01 ran for 0 msecs: pnp_system_init+0x0/0x3f()
[    2.832177] Calling initcall 0xffffffff80ec2ab0: chr_dev_init+0x0/0xd0()
[    2.840177] initcall 0xffffffff80ec2ab0: chr_dev_init+0x0/0xd0() returned 0.
[    2.852178] initcall 0xffffffff80ec2ab0 ran for 0 msecs: chr_dev_init+0x0/0xd0()
[    2.860178] Calling initcall 0xffffffff80eca738: firmware_class_init+0x0/0x98()
[    2.868179] initcall 0xffffffff80eca738: firmware_class_init+0x0/0x98() returned 0.
[    2.880180] initcall 0xffffffff80eca738 ran for 0 msecs: firmware_class_init+0x0/0x98()
[    2.888180] Calling initcall 0xffffffff80ece6b6: loopback_init+0x0/0x39()
[    2.896181] initcall 0xffffffff80ece6b6: loopback_init+0x0/0x39() returned 0.
[    2.908181] initcall 0xffffffff80ece6b6 ran for 0 msecs: loopback_init+0x0/0x39()
[    2.916182] Calling initcall 0xffffffff80ede55a: init_acpi_pm_clocksource+0x0/0xec()
[    2.924182] initcall 0xffffffff80ede55a: init_acpi_pm_clocksource+0x0/0xec() returned -19.
[    2.936183] initcall 0xffffffff80ede55a ran for 0 msecs: init_acpi_pm_clocksource+0x0/0xec()
[    2.944184] Calling initcall 0xffffffff80ede680: ssb_modinit+0x0/0x73()
[    2.952184] initcall 0xffffffff80ede680: ssb_modinit+0x0/0x73() returned 0.
[    2.964185] initcall 0xffffffff80ede680 ran for 0 msecs: ssb_modinit+0x0/0x73()
[    2.972185] Calling initcall 0xffffffff80ede7b0: pcibios_assign_resources+0x0/0xaa()
[    2.980186] PCI: Bridge: 0000:02:00.0
[    2.984186]   IO window: disabled.
[    2.988186]   MEM window: disabled.
[    2.992187]   PREFETCH window: disabled.
[    2.996187] PCI: Bridge: 0000:02:02.0
[    3.000187]   IO window: 2000-2fff
[    3.004187]   MEM window: 0xd8a00000-0xd8afffff
[    3.008188]   PREFETCH window: disabled.
[    3.012188] PCI: Bridge: 0000:01:00.0
[    3.016188]   IO window: 2000-2fff
[    3.020188]   MEM window: 0xd8a00000-0xd8afffff
[    3.024189]   PREFETCH window: disabled.
[    3.028189] PCI: Bridge: 0000:01:00.3
[    3.032189]   IO window: disabled.
[    3.036189]   MEM window: disabled.
[    3.040190]   PREFETCH window: disabled.
[    3.044190] PCI: Bridge: 0000:00:02.0
[    3.048190]   IO window: 2000-2fff
[    3.052190]   MEM window: 0xd8900000-0xd8afffff
[    3.056191]   PREFETCH window: disabled.
[    3.060191] PCI: Bridge: 0000:00:04.0
[    3.064191]   IO window: disabled.
[    3.068191]   MEM window: 0xd8800000-0xd88fffff
[    3.072192]   PREFETCH window: 0x00000000d8000000-0x00000000d87fffff
[    3.076192] PCI: Bridge: 0000:00:06.0
[    3.080192]   IO window: disabled.
[    3.084192]   MEM window: disabled.
[    3.088193]   PREFETCH window: disabled.
[    3.092193] PCI: Bridge: 0000:00:1e.0
[    3.096193]   IO window: 3000-3fff
[    3.100193]   MEM window: 0xd8b00000-0xd8bfffff
[    3.104194]   PREFETCH window: 0x00000000d0000000-0x00000000d7ffffff
[    3.108194] PCI: Found IRQ 7 for device 0000:00:02.0
[    3.112194] PCI: Sharing IRQ 7 with 0000:00:00.0
[    3.116194] PCI: Sharing IRQ 7 with 0000:00:04.0
[    3.120195] PCI: Sharing IRQ 7 with 0000:00:06.0
[    3.124195] PCI: Sharing IRQ 7 with 0000:00:08.0
[    3.128195] PCI: Sharing IRQ 7 with 0000:01:00.0
[    3.132195] PCI: Sharing IRQ 7 with 0000:02:00.0
[    3.136196] PCI: Sharing IRQ 7 with 0000:06:00.0
[    3.140196] PCI: Setting latency timer of device 0000:00:02.0 to 64
[    3.144196] PCI: Found IRQ 7 for device 0000:01:00.0
[    3.148196] PCI: Sharing IRQ 7 with 0000:00:00.0
[    3.152197] PCI: Sharing IRQ 7 with 0000:00:02.0
[    3.156197] PCI: Sharing IRQ 7 with 0000:00:04.0
[    3.160197] PCI: Sharing IRQ 7 with 0000:00:06.0
[    3.164197] PCI: Sharing IRQ 7 with 0000:00:08.0
[    3.168198] PCI: Sharing IRQ 7 with 0000:02:00.0
[    3.172198] PCI: Sharing IRQ 7 with 0000:06:00.0
[    3.176198] PCI: Setting latency timer of device 0000:01:00.0 to 64
[    3.180198] PCI: Found IRQ 7 for device 0000:02:00.0
[    3.184199] PCI: Sharing IRQ 7 with 0000:00:00.0
[    3.188199] PCI: Sharing IRQ 7 with 0000:00:02.0
[    3.192199] PCI: Sharing IRQ 7 with 0000:00:04.0
[    3.196199] PCI: Sharing IRQ 7 with 0000:00:06.0
[    3.200200] PCI: Sharing IRQ 7 with 0000:00:08.0
[    3.204200] PCI: Sharing IRQ 7 with 0000:01:00.0
[    3.208200] PCI: Sharing IRQ 7 with 0000:06:00.0
[    3.212200] PCI: Setting latency timer of device 0000:02:00.0 to 64
[    3.216201] PCI: No IRQ known for interrupt pin A of device 0000:02:02.0. Please try using pci=biosirq.
[    3.220201] PCI: Setting latency timer of device 0000:02:02.0 to 64
[    3.224201] PCI: Setting latency timer of device 0000:01:00.3 to 64
[    3.228201] PCI: Found IRQ 7 for device 0000:00:04.0
[    3.232202] PCI: Sharing IRQ 7 with 0000:00:00.0
[    3.236202] PCI: Sharing IRQ 7 with 0000:00:02.0
[    3.240202] PCI: Sharing IRQ 7 with 0000:00:06.0
[    3.244202] PCI: Sharing IRQ 7 with 0000:00:08.0
[    3.248203] PCI: Sharing IRQ 7 with 0000:01:00.0
[    3.252203] PCI: Sharing IRQ 7 with 0000:02:00.0
[    3.256203] PCI: Sharing IRQ 7 with 0000:06:00.0
[    3.260203] PCI: Setting latency timer of device 0000:00:04.0 to 64
[    3.264204] PCI: Found IRQ 7 for device 0000:00:06.0
[    3.268204] PCI: Sharing IRQ 7 with 0000:00:00.0
[    3.272204] PCI: Sharing IRQ 7 with 0000:00:02.0
[    3.276204] PCI: Sharing IRQ 7 with 0000:00:04.0
[    3.280205] PCI: Sharing IRQ 7 with 0000:00:08.0
[    3.284205] PCI: Sharing IRQ 7 with 0000:01:00.0
[    3.288205] PCI: Sharing IRQ 7 with 0000:02:00.0
[    3.292205] PCI: Sharing IRQ 7 with 0000:06:00.0
[    3.296206] PCI: Setting latency timer of device 0000:00:06.0 to 64
[    3.300206] PCI: Setting latency timer of device 0000:00:1e.0 to 64
[    3.304206] initcall 0xffffffff80ede7b0: pcibios_assign_resources+0x0/0xaa() returned 0.
[    3.316207] initcall 0xffffffff80ede7b0 ran for 308 msecs: pcibios_assign_resources+0x0/0xaa()
[    3.324207] Calling initcall 0xffffffff80ee2b70: inet_init+0x0/0x3c0()
[    3.336208] NET: Registered protocol family 2
[    3.380211] IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    3.384211] TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
[    3.388211] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    3.392212] TCP: Hash tables configured (established 262144 bind 65536)
[    3.396212] TCP reno registered
[    3.412213] initcall 0xffffffff80ee2b70: inet_init+0x0/0x3c0() returned 0.
[    3.424214] initcall 0xffffffff80ee2b70 ran for 72 msecs: inet_init+0x0/0x3c0()
[    3.432214] Calling initcall 0xffffffff80ea3430: default_rootfs+0x0/0x8e()
[    3.440215] initcall 0xffffffff80ea3430: default_rootfs+0x0/0x8e() returned 0.
[    3.452215] initcall 0xffffffff80ea3430 ran for 0 msecs: default_rootfs+0x0/0x8e()
[    3.460216] Calling initcall 0xffffffff80ea38d5: vmx_init+0x0/0x15b()
[    3.468216] kvm: disabled by bios
[    3.472217] initcall 0xffffffff80ea38d5: vmx_init+0x0/0x15b() returned -95.
[    3.484217] initcall 0xffffffff80ea38d5 ran for 3 msecs: vmx_init+0x0/0x15b()
[    3.492218] initcall at 0xffffffff80ea38d5: vmx_init+0x0/0x15b(): returned with error code -95
[    3.504219] Calling initcall 0xffffffff80ea3a30: svm_init+0x0/0x40()
[    3.512219] has_svm: not amd
[    3.516219] kvm: no hardware support
[    3.520220] initcall 0xffffffff80ea3a30: svm_init+0x0/0x40() returned -95.
[    3.532220] initcall 0xffffffff80ea3a30 ran for 7 msecs: svm_init+0x0/0x40()
[    3.540221] initcall at 0xffffffff80ea3a30: svm_init+0x0/0x40(): returned with error code -95
[    3.552222] Calling initcall 0xffffffff80ea4f10: i8259A_init_sysfs+0x0/0x5e()
[    3.560222] initcall 0xffffffff80ea4f10: i8259A_init_sysfs+0x0/0x5e() returned 0.
[    3.572223] initcall 0xffffffff80ea4f10 ran for 0 msecs: i8259A_init_sysfs+0x0/0x5e()
[    3.580223] Calling initcall 0xffffffff80ea5588: vsyscall_init+0x0/0x38()
[    3.588224] initcall 0xffffffff80ea5588: vsyscall_init+0x0/0x38() returned 0.
[    3.600225] initcall 0xffffffff80ea5588 ran for 0 msecs: vsyscall_init+0x0/0x38()
[    3.608225] Calling initcall 0xffffffff80ea5747: sbf_init+0x0/0x119()
[    3.616226] initcall 0xffffffff80ea5747: sbf_init+0x0/0x119() returned 0.
[    3.628226] initcall 0xffffffff80ea5747 ran for 0 msecs: sbf_init+0x0/0x119()
[    3.636227] Calling initcall 0xffffffff80ea7110: i8237A_init_sysfs+0x0/0x60()
[    3.644227] initcall 0xffffffff80ea7110: i8237A_init_sysfs+0x0/0x60() returned 0.
[    3.656228] initcall 0xffffffff80ea7110 ran for 0 msecs: i8237A_init_sysfs+0x0/0x60()
[    3.664229] Calling initcall 0xffffffff80ab28da: cache_sysfs_init+0x0/0x85()
[    3.672229] initcall 0xffffffff80ab28da: cache_sysfs_init+0x0/0x85() returned 0.
[    3.680230] initcall 0xffffffff80ab28da ran for 0 msecs: cache_sysfs_init+0x0/0x85()
[    3.688230] Calling initcall 0xffffffff80ea7ced: mce_init_device+0x0/0xae()
[    3.700231] initcall 0xffffffff80ea7ced: mce_init_device+0x0/0xae() returned 0.
[    3.712232] initcall 0xffffffff80ea7ced ran for 3 msecs: mce_init_device+0x0/0xae()
[    3.720232] Calling initcall 0xffffffff80ea7bbb: periodic_mcheck_init+0x0/0x6e()
[    3.728233] initcall 0xffffffff80ea7bbb: periodic_mcheck_init+0x0/0x6e() returned 0.
[    3.740233] initcall 0xffffffff80ea7bbb ran for 0 msecs: periodic_mcheck_init+0x0/0x6e()
[    3.748234] Calling initcall 0xffffffff80ea7d9b: thermal_throttle_init_device+0x0/0xa5()
[    3.756234] initcall 0xffffffff80ea7d9b: thermal_throttle_init_device+0x0/0xa5() returned 0.
[    3.768235] initcall 0xffffffff80ea7d9b ran for 0 msecs: thermal_throttle_init_device+0x0/0xa5()
[    3.776236] Calling initcall 0xffffffff80ea7e40: threshold_init_device+0x0/0x80()
[    3.784236] initcall 0xffffffff80ea7e40: threshold_init_device+0x0/0x80() returned 0.
[    3.796237] initcall 0xffffffff80ea7e40 ran for 0 msecs: threshold_init_device+0x0/0x80()
[    3.804237] Calling initcall 0xffffffff80ea98e0: msr_init+0x0/0x130()
[    3.812238] initcall 0xffffffff80ea98e0: msr_init+0x0/0x130() returned 0.
[    3.824239] initcall 0xffffffff80ea98e0 ran for 0 msecs: msr_init+0x0/0x130()
[    3.832239] Calling initcall 0xffffffff80ea9a10: microcode_init+0x0/0xe4()
[    3.840240] IA-32 Microcode Update Driver: v1.14a <tigran@aivazian.fsnet.co.uk>
[    3.844240] initcall 0xffffffff80ea9a10: microcode_init+0x0/0xe4() returned 0.
[    3.856241] initcall 0xffffffff80ea9a10 ran for 3 msecs: microcode_init+0x0/0xe4()
[    3.864241] Calling initcall 0xffffffff80eab709: init_lapic_sysfs+0x0/0x67()
[    3.872242] initcall 0xffffffff80eab709: init_lapic_sysfs+0x0/0x67() returned 0.
[    3.884242] initcall 0xffffffff80eab709 ran for 0 msecs: init_lapic_sysfs+0x0/0x67()
[    3.892243] Calling initcall 0xffffffff80eac712: ioapic_init_sysfs+0x0/0xff()
[    3.900243] initcall 0xffffffff80eac712: ioapic_init_sysfs+0x0/0xff() returned 0.
[    3.912244] initcall 0xffffffff80eac712 ran for 0 msecs: ioapic_init_sysfs+0x0/0xff()
[    3.920245] Calling initcall 0xffffffff80eaed40: audit_classes_init+0x0/0xe0()
[    3.928245] initcall 0xffffffff80eaed40: audit_classes_init+0x0/0xe0() returned 0.
[    3.940246] initcall 0xffffffff80eaed40 ran for 0 msecs: audit_classes_init+0x0/0xe0()
[    3.948246] Calling initcall 0xffffffff80eaf595: aes_init+0x0/0x39()
[    3.956247] initcall 0xffffffff80eaf595: aes_init+0x0/0x39() returned 0.
[    3.964247] initcall 0xffffffff80eaf595 ran for 0 msecs: aes_init+0x0/0x39()
[    3.972248] Calling initcall 0xffffffff80eaf5ce: init+0x0/0x39()
[    3.980248] initcall 0xffffffff80eaf5ce: init+0x0/0x39() returned 0.
[    3.992249] initcall 0xffffffff80eaf5ce ran for 0 msecs: init+0x0/0x39()
[    4.000250] Calling initcall 0xffffffff80eaf607: init+0x0/0x39()
[    4.012250] initcall 0xffffffff80eaf607: init+0x0/0x39() returned 0.
[    4.024251] initcall 0xffffffff80eaf607 ran for 0 msecs: init+0x0/0x39()
[    4.032252] Calling initcall 0xffffffff80eaf67f: init_vdso_vars+0x0/0x231()
[    4.044252] initcall 0xffffffff80eaf67f: init_vdso_vars+0x0/0x231() returned 0.
[    4.056253] initcall 0xffffffff80eaf67f ran for 0 msecs: init_vdso_vars+0x0/0x231()
[    4.064254] Calling initcall 0xffffffff80eaf8f2: ia32_binfmt_init+0x0/0x3c()
[    4.072254] initcall 0xffffffff80eaf8f2: ia32_binfmt_init+0x0/0x3c() returned 0.
[    4.084255] initcall 0xffffffff80eaf8f2 ran for 0 msecs: ia32_binfmt_init+0x0/0x3c()
[    4.092255] Calling initcall 0xffffffff80eaf92e: sysenter_setup+0x0/0x322()
[    4.100256] initcall 0xffffffff80eaf92e: sysenter_setup+0x0/0x322() returned 0.
[    4.112257] initcall 0xffffffff80eaf92e ran for 0 msecs: sysenter_setup+0x0/0x322()
[    4.120257] Calling initcall 0xffffffff80eb098b: create_proc_profile+0x0/0x295()
[    4.132258] initcall 0xffffffff80eb098b: create_proc_profile+0x0/0x295() returned 0.
[    4.140258] initcall 0xffffffff80eb098b ran for 0 msecs: create_proc_profile+0x0/0x295()
[    4.148259] Calling initcall 0xffffffff80eb0ce5: ioresources_init+0x0/0x6a()
[    4.156259] initcall 0xffffffff80eb0ce5: ioresources_init+0x0/0x6a() returned 0.
[    4.168260] initcall 0xffffffff80eb0ce5 ran for 0 msecs: ioresources_init+0x0/0x6a()
[    4.176261] Calling initcall 0xffffffff80eb0fa5: uid_cache_init+0x0/0x9b()
[    4.184261] initcall 0xffffffff80eb0fa5: uid_cache_init+0x0/0x9b() returned 0.
[    4.196262] initcall 0xffffffff80eb0fa5 ran for 0 msecs: uid_cache_init+0x0/0x9b()
[    4.208263] Calling initcall 0xffffffff80eb176c: init_posix_timers+0x0/0xce()
[    4.216263] initcall 0xffffffff80eb176c: init_posix_timers+0x0/0xce() returned 0.
[    4.224264] initcall 0xffffffff80eb176c ran for 0 msecs: init_posix_timers+0x0/0xce()
[    4.232264] Calling initcall 0xffffffff80eb183a: init_posix_cpu_timers+0x0/0xee()
[    4.240265] initcall 0xffffffff80eb183a: init_posix_cpu_timers+0x0/0xee() returned 0.
[    4.252265] initcall 0xffffffff80eb183a ran for 0 msecs: init_posix_cpu_timers+0x0/0xee()
[    4.260266] Calling initcall 0xffffffff80eb1a0c: nsproxy_cache_init+0x0/0x64()
[    4.268266] initcall 0xffffffff80eb1a0c: nsproxy_cache_init+0x0/0x64() returned 0.
[    4.280267] initcall 0xffffffff80eb1a0c ran for 0 msecs: nsproxy_cache_init+0x0/0x64()
[    4.288268] Calling initcall 0xffffffff80eb1bf0: timekeeping_init_device+0x0/0x5e()
[    4.296268] initcall 0xffffffff80eb1bf0: timekeeping_init_device+0x0/0x5e() returned 0.
[    4.308269] initcall 0xffffffff80eb1bf0 ran for 0 msecs: timekeeping_init_device+0x0/0x5e()
[    4.316269] Calling initcall 0xffffffff80eb1dc8: init_clocksource_sysfs+0x0/0x8c()
[    4.324270] initcall 0xffffffff80eb1dc8: init_clocksource_sysfs+0x0/0x8c() returned 0.
[    4.336271] initcall 0xffffffff80eb1dc8 ran for 0 msecs: init_clocksource_sysfs+0x0/0x8c()
[    4.344271] Calling initcall 0xffffffff80eb1f89: init_timer_list_procfs+0x0/0x57()
[    4.352272] initcall 0xffffffff80eb1f89: init_timer_list_procfs+0x0/0x57() returned 0.
[    4.364272] initcall 0xffffffff80eb1f89 ran for 0 msecs: init_timer_list_procfs+0x0/0x57()
[    4.372273] Calling initcall 0xffffffff80eb2019: futex_init+0x0/0xd5()
[    4.380273] initcall 0xffffffff80eb2019: futex_init+0x0/0xd5() returned 0.
[    4.392274] initcall 0xffffffff80eb2019 ran for 0 msecs: futex_init+0x0/0xd5()
[    4.400275] Calling initcall 0xffffffff80eb20ee: proc_dma_init+0x0/0x4d()
[    4.408275] initcall 0xffffffff80eb20ee: proc_dma_init+0x0/0x4d() returned 0.
[    4.420276] initcall 0xffffffff80eb20ee ran for 0 msecs: proc_dma_init+0x0/0x4d()
[    4.428276] Calling initcall 0xffffffff80eb21a3: kallsyms_init+0x0/0x5d()
[    4.440277] initcall 0xffffffff80eb21a3: kallsyms_init+0x0/0x5d() returned 0.
[    4.452278] initcall 0xffffffff80eb21a3 ran for 0 msecs: kallsyms_init+0x0/0x5d()
[    4.460278] Calling initcall 0xffffffff80eb22ea: crash_save_vmcoreinfo_init+0x0/0x43c()
[    4.472279] initcall 0xffffffff80eb22ea: crash_save_vmcoreinfo_init+0x0/0x43c() returned 0.
[    4.484280] initcall 0xffffffff80eb22ea ran for 0 msecs: crash_save_vmcoreinfo_init+0x0/0x43c()
[    4.492280] Calling initcall 0xffffffff80eb2280: crash_notes_memory_init+0x0/0x6a()
[    4.500281] initcall 0xffffffff80eb2280: crash_notes_memory_init+0x0/0x6a() returned 0.
[    4.512282] initcall 0xffffffff80eb2280 ran for 0 msecs: crash_notes_memory_init+0x0/0x6a()
[    4.520282] Calling initcall 0xffffffff80eb2e09: ikconfig_init+0x0/0x67()
[    4.532283] initcall 0xffffffff80eb2e09: ikconfig_init+0x0/0x67() returned 0.
[    4.544284] initcall 0xffffffff80eb2e09 ran for 0 msecs: ikconfig_init+0x0/0x67()
[    4.552284] Calling initcall 0xffffffff80eb2f1a: audit_init+0x0/0x146()
[    4.560285] audit: initializing netlink socket (disabled)
[    4.564285] type=2000 audit(1208529567.564:1): initialized
[    4.568285] audit: cannot initialize inotify handle
[    4.572285] initcall 0xffffffff80eb2f1a: audit_init+0x0/0x146() returned 0.
[    4.584286] initcall 0xffffffff80eb2f1a ran for 11 msecs: audit_init+0x0/0x146()
[    4.592287] Calling initcall 0xffffffff80eb3340: relay_init+0x0/0x40()
[    4.600287] initcall 0xffffffff80eb3340: relay_init+0x0/0x40() returned 0.
[    4.612288] initcall 0xffffffff80eb3340 ran for 0 msecs: relay_init+0x0/0x40()
[    4.620288] Calling initcall 0xffffffff80eb3380: utsname_sysctl_init+0x0/0x40()
[    4.628289] initcall 0xffffffff80eb3380: utsname_sysctl_init+0x0/0x40() returned 0.
[    4.640290] initcall 0xffffffff80eb3380 ran for 0 msecs: utsname_sysctl_init+0x0/0x40()
[    4.648290] Calling initcall 0xffffffff80eb4e1d: init_per_zone_pages_min+0x0/0x7b()
[    4.660291] initcall 0xffffffff80eb4e1d: init_per_zone_pages_min+0x0/0x7b() returned 0.
[    4.672292] initcall 0xffffffff80eb4e1d ran for 0 msecs: init_per_zone_pages_min+0x0/0x7b()
[    4.680292] Calling initcall 0xffffffff80eb52c0: pdflush_init+0x0/0x45()
[    4.688293] initcall 0xffffffff80eb52c0: pdflush_init+0x0/0x45() returned 0.
[    4.700293] initcall 0xffffffff80eb52c0 ran for 0 msecs: pdflush_init+0x0/0x45()
[    4.708294] Calling initcall 0xffffffff80eb53a0: kswapd_init+0x0/0x50()
[    4.716294] initcall 0xffffffff80eb53a0: kswapd_init+0x0/0x50() returned 0.
[    4.728295] initcall 0xffffffff80eb53a0 ran for 0 msecs: kswapd_init+0x0/0x50()
[    4.736296] Calling initcall 0xffffffff80eb53f0: setup_vmstat+0x0/0x75()
[    4.748296] initcall 0xffffffff80eb53f0: setup_vmstat+0x0/0x75() returned 0.
[    4.760297] initcall 0xffffffff80eb53f0 ran for 0 msecs: setup_vmstat+0x0/0x75()
[    4.768298] Calling initcall 0xffffffff80eb58a2: init_tmpfs+0x0/0x5e()
[    4.776298] initcall 0xffffffff80eb58a2: init_tmpfs+0x0/0x5e() returned 0.
[    4.788299] initcall 0xffffffff80eb58a2 ran for 0 msecs: init_tmpfs+0x0/0x5e()
[    4.796299] Calling initcall 0xffffffff80eb59c6: cpucache_init+0x0/0x61()
[    4.804300] initcall 0xffffffff80eb59c6: cpucache_init+0x0/0x61() returned 0.
[    4.812300] initcall 0xffffffff80eb59c6 ran for 0 msecs: cpucache_init+0x0/0x61()
[    4.820301] Calling initcall 0xffffffff80eb5f99: fasync_init+0x0/0x52()
[    4.828301] initcall 0xffffffff80eb5f99: fasync_init+0x0/0x52() returned 0.
[    4.840302] initcall 0xffffffff80eb5f99 ran for 0 msecs: fasync_init+0x0/0x52()
[    4.848303] Calling initcall 0xffffffff80eb67a2: aio_setup+0x0/0x96()
[    4.860303] initcall 0xffffffff80eb67a2: aio_setup+0x0/0x96() returned 0.
[    4.872304] initcall 0xffffffff80eb67a2 ran for 0 msecs: aio_setup+0x0/0x96()
[    4.880305] Calling initcall 0xffffffff80eb6c80: init_sys32_ioctl+0x0/0xb5()
[    4.888305] initcall 0xffffffff80eb6c80: init_sys32_ioctl+0x0/0xb5() returned 0.
[    4.900306] initcall 0xffffffff80eb6c80 ran for 0 msecs: init_sys32_ioctl+0x0/0xb5()
[    4.908306] Calling initcall 0xffffffff80eb6de0: init_mbcache+0x0/0x3c()
[    4.916307] initcall 0xffffffff80eb6de0: init_mbcache+0x0/0x3c() returned 0.
[    4.928308] initcall 0xffffffff80eb6de0 ran for 0 msecs: init_mbcache+0x0/0x3c()
[    4.936308] Calling initcall 0xffffffff80eb6e1c: dquot_init+0x0/0x11a()
[    4.948309] VFS: Disk quotas dquot_6.5.1
[    4.952309] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    4.956309] initcall 0xffffffff80eb6e1c: dquot_init+0x0/0x11a() returned 0.
[    4.968310] initcall 0xffffffff80eb6e1c ran for 7 msecs: dquot_init+0x0/0x11a()
[    4.976311] Calling initcall 0xffffffff80eb6f36: init_v1_quota_format+0x0/0x39()
[    4.984311] initcall 0xffffffff80eb6f36: init_v1_quota_format+0x0/0x39() returned 0.
[    4.996312] initcall 0xffffffff80eb6f36 ran for 0 msecs: init_v1_quota_format+0x0/0x39()
[    5.004312] Calling initcall 0xffffffff80eb6f6f: init_v2_quota_format+0x0/0x39()
[    5.012313] initcall 0xffffffff80eb6f6f: init_v2_quota_format+0x0/0x39() returned 0.
[    5.024314] initcall 0xffffffff80eb6f6f ran for 0 msecs: init_v2_quota_format+0x0/0x39()
[    5.032314] Calling initcall 0xffffffff80eb6fa8: dnotify_init+0x0/0x58()
[    5.040315] initcall 0xffffffff80eb6fa8: dnotify_init+0x0/0x58() returned 0.
[    5.052315] initcall 0xffffffff80eb6fa8 ran for 0 msecs: dnotify_init+0x0/0x58()
[    5.060316] Calling initcall 0xffffffff80eb75fb: vmcore_init+0x0/0x9ec()
[    5.068316] initcall 0xffffffff80eb75fb: vmcore_init+0x0/0x9ec() returned 0.
[    5.080317] initcall 0xffffffff80eb75fb ran for 0 msecs: vmcore_init+0x0/0x9ec()
[    5.088318] Calling initcall 0xffffffff80eb8135: configfs_init+0x0/0xff()
[    5.096318] initcall 0xffffffff80eb8135: configfs_init+0x0/0xff() returned 0.
[    5.108319] initcall 0xffffffff80eb8135 ran for 0 msecs: configfs_init+0x0/0xff()
[    5.116319] Calling initcall 0xffffffff80eb8234: init_devpts_fs+0x0/0x6c()
[    5.124320] initcall 0xffffffff80eb8234: init_devpts_fs+0x0/0x6c() returned 0.
[    5.136321] initcall 0xffffffff80eb8234 ran for 0 msecs: init_devpts_fs+0x0/0x6c()
[    5.144321] Calling initcall 0xffffffff80eb83c0: init_dlm+0x0/0xc5()
[    5.152322] DLM (built Apr 18 2008 09:35:29) installed
[    5.156322] initcall 0xffffffff80eb83c0: init_dlm+0x0/0xc5() returned 0.
[    5.168323] initcall 0xffffffff80eb83c0 ran for 3 msecs: init_dlm+0x0/0xc5()
[    5.176323] Calling initcall 0xffffffff80eb8610: init_reiserfs_fs+0x0/0xb0()
[    5.188324] initcall 0xffffffff80eb8610: init_reiserfs_fs+0x0/0xb0() returned 0.
[    5.200325] initcall 0xffffffff80eb8610 ran for 0 msecs: init_reiserfs_fs+0x0/0xb0()
[    5.208325] Calling initcall 0xffffffff80eb86c0: init_ext3_fs+0x0/0x8b()
[    5.216326] initcall 0xffffffff80eb86c0: init_ext3_fs+0x0/0x8b() returned 0.
[    5.228326] initcall 0xffffffff80eb86c0 ran for 0 msecs: init_ext3_fs+0x0/0x8b()
[    5.236327] Calling initcall 0xffffffff80eb87b0: init_ext4_fs+0x0/0x8b()
[    5.244327] initcall 0xffffffff80eb87b0: init_ext4_fs+0x0/0x8b() returned 0.
[    5.256328] initcall 0xffffffff80eb87b0 ran for 0 msecs: init_ext4_fs+0x0/0x8b()
[    5.264329] Calling initcall 0xffffffff80eb89ac: journal_init+0x0/0x102()
[    5.272329] initcall 0xffffffff80eb89ac: journal_init+0x0/0x102() returned 0.
[    5.284330] initcall 0xffffffff80eb89ac ran for 0 msecs: journal_init+0x0/0x102()
[    5.292330] Calling initcall 0xffffffff80eb8b51: journal_init+0x0/0xdf()
[    5.300331] initcall 0xffffffff80eb8b51: journal_init+0x0/0xdf() returned 0.
[    5.312332] initcall 0xffffffff80eb8b51 ran for 0 msecs: journal_init+0x0/0xdf()
[    5.320332] Calling initcall 0xffffffff80eb8c30: init_ext2_fs+0x0/0x7c()
[    5.328333] initcall 0xffffffff80eb8c30: init_ext2_fs+0x0/0x7c() returned 0.
[    5.340333] initcall 0xffffffff80eb8c30 ran for 0 msecs: init_ext2_fs+0x0/0x7c()
[    5.348334] Calling initcall 0xffffffff80eb8cac: init_ramfs_fs+0x0/0x39()
[    5.356334] initcall 0xffffffff80eb8cac: init_ramfs_fs+0x0/0x39() returned 0.
[    5.368335] initcall 0xffffffff80eb8cac ran for 0 msecs: init_ramfs_fs+0x0/0x39()
[    5.376336] Calling initcall 0xffffffff80eb8db0: init_fat_fs+0x0/0x75()
[    5.388336] initcall 0xffffffff80eb8db0: init_fat_fs+0x0/0x75() returned 0.
[    5.400337] initcall 0xffffffff80eb8db0 ran for 0 msecs: init_fat_fs+0x0/0x75()
[    5.408338] Calling initcall 0xffffffff80eb8e25: init_vfat_fs+0x0/0x3b()
[    5.416338] initcall 0xffffffff80eb8e25: init_vfat_fs+0x0/0x3b() returned 0.
[    5.428339] initcall 0xffffffff80eb8e25 ran for 0 msecs: init_vfat_fs+0x0/0x3b()
[    5.436339] Calling initcall 0xffffffff80eb8e60: init_bfs_fs+0x0/0x80()
[    5.444340] initcall 0xffffffff80eb8e60: init_bfs_fs+0x0/0x80() returned 0.
[    5.452340] initcall 0xffffffff80eb8e60 ran for 0 msecs: init_bfs_fs+0x0/0x80()
[    5.460341] Calling initcall 0xffffffff80eb8ee0: init_iso9660_fs+0x0/0x8b()
[    5.468341] initcall 0xffffffff80eb8ee0: init_iso9660_fs+0x0/0x8b() returned 0.
[    5.480342] initcall 0xffffffff80eb8ee0 ran for 0 msecs: init_iso9660_fs+0x0/0x8b()
[    5.488343] Calling initcall 0xffffffff80eb8fb6: init_hfsplus_fs+0x0/0x82()
[    5.496343] initcall 0xffffffff80eb8fb6: init_hfsplus_fs+0x0/0x82() returned 0.
[    5.508344] initcall 0xffffffff80eb8fb6 ran for 0 msecs: init_hfsplus_fs+0x0/0x82()
[    5.516344] Calling initcall 0xffffffff80eb9038: init_hfs_fs+0x0/0x88()
[    5.524345] initcall 0xffffffff80eb9038: init_hfs_fs+0x0/0x88() returned 0.
[    5.536346] initcall 0xffffffff80eb9038 ran for 0 msecs: init_hfs_fs+0x0/0x88()
[    5.544346] Calling initcall 0xffffffff80eb90c0: ecryptfs_init+0x0/0x1d5()
[    5.552347] initcall 0xffffffff80eb90c0: ecryptfs_init+0x0/0x1d5() returned 0.
[    5.564347] initcall 0xffffffff80eb90c0 ran for 0 msecs: ecryptfs_init+0x0/0x1d5()
[    5.572348] Calling initcall 0xffffffff80eb9295: init_nls_cp437+0x0/0x39()
[    5.580348] initcall 0xffffffff80eb9295: init_nls_cp437+0x0/0x39() returned 0.
[    5.592349] initcall 0xffffffff80eb9295 ran for 0 msecs: init_nls_cp437+0x0/0x39()
[    5.600350] Calling initcall 0xffffffff80eb92ce: init_nls_cp857+0x0/0x39()
[    5.608350] initcall 0xffffffff80eb92ce: init_nls_cp857+0x0/0x39() returned 0.
[    5.620351] initcall 0xffffffff80eb92ce ran for 0 msecs: init_nls_cp857+0x0/0x39()
[    5.628351] Calling initcall 0xffffffff80eb9307: init_nls_cp865+0x0/0x39()
[    5.636352] initcall 0xffffffff80eb9307: init_nls_cp865+0x0/0x39() returned 0.
[    5.648353] initcall 0xffffffff80eb9307 ran for 0 msecs: init_nls_cp865+0x0/0x39()
[    5.656353] Calling initcall 0xffffffff80eb9340: init_nls_cp869+0x0/0x39()
[    5.664354] initcall 0xffffffff80eb9340: init_nls_cp869+0x0/0x39() returned 0.
[    5.672354] initcall 0xffffffff80eb9340 ran for 0 msecs: init_nls_cp869+0x0/0x39()
[    5.680355] Calling initcall 0xffffffff80eb9379: init_nls_cp936+0x0/0x39()
[    5.688355] initcall 0xffffffff80eb9379: init_nls_cp936+0x0/0x39() returned 0.
[    5.700356] initcall 0xffffffff80eb9379 ran for 0 msecs: init_nls_cp936+0x0/0x39()
[    5.708356] Calling initcall 0xffffffff80eb93b2: init_nls_cp949+0x0/0x39()
[    5.720357] initcall 0xffffffff80eb93b2: init_nls_cp949+0x0/0x39() returned 0.
[    5.732358] initcall 0xffffffff80eb93b2 ran for 0 msecs: init_nls_cp949+0x0/0x39()
[    5.740358] Calling initcall 0xffffffff80eb93eb: init_nls_cp1250+0x0/0x39()
[    5.748359] initcall 0xffffffff80eb93eb: init_nls_cp1250+0x0/0x39() returned 0.
[    5.756359] initcall 0xffffffff80eb93eb ran for 0 msecs: init_nls_cp1250+0x0/0x39()
[    5.764360] Calling initcall 0xffffffff80eb9424: init_nls_cp1251+0x0/0x39()
[    5.772360] initcall 0xffffffff80eb9424: init_nls_cp1251+0x0/0x39() returned 0.
[    5.784361] initcall 0xffffffff80eb9424 ran for 0 msecs: init_nls_cp1251+0x0/0x39()
[    5.792362] Calling initcall 0xffffffff80eb945d: init_nls_iso8859_7+0x0/0x39()
[    5.800362] initcall 0xffffffff80eb945d: init_nls_iso8859_7+0x0/0x39() returned 0.
[    5.812363] initcall 0xffffffff80eb945d ran for 0 msecs: init_nls_iso8859_7+0x0/0x39()
[    5.820363] Calling initcall 0xffffffff80eb9496: init_nls_iso8859_9+0x0/0x39()
[    5.828364] initcall 0xffffffff80eb9496: init_nls_iso8859_9+0x0/0x39() returned 0.
[    5.840365] initcall 0xffffffff80eb9496 ran for 0 msecs: init_nls_iso8859_9+0x0/0x39()
[    5.848365] Calling initcall 0xffffffff80eb94cf: init_nls_iso8859_14+0x0/0x39()
[    5.856366] initcall 0xffffffff80eb94cf: init_nls_iso8859_14+0x0/0x39() returned 0.
[    5.868366] initcall 0xffffffff80eb94cf ran for 0 msecs: init_nls_iso8859_14+0x0/0x39()
[    5.876367] Calling initcall 0xffffffff80eb9508: init_nls_iso8859_15+0x0/0x39()
[    5.888368] initcall 0xffffffff80eb9508: init_nls_iso8859_15+0x0/0x39() returned 0.
[    5.900368] initcall 0xffffffff80eb9508 ran for 0 msecs: init_nls_iso8859_15+0x0/0x39()
[    5.908369] Calling initcall 0xffffffff80eb9541: init_nls_utf8+0x0/0x4f()
[    5.916369] initcall 0xffffffff80eb9541: init_nls_utf8+0x0/0x4f() returned 0.
[    5.928370] initcall 0xffffffff80eb9541 ran for 0 msecs: init_nls_utf8+0x0/0x4f()
[    5.936371] Calling initcall 0xffffffff80eb95f0: init_sysv_fs+0x0/0x75()
[    5.944371] initcall 0xffffffff80eb95f0: init_sysv_fs+0x0/0x75() returned 0.
[    5.956372] initcall 0xffffffff80eb95f0 ran for 0 msecs: init_sysv_fs+0x0/0x75()
[    5.964372] Calling initcall 0xffffffff80eb9665: init_ntfs_fs+0x0/0x20b()
[    5.972373] NTFS driver 2.1.29 [Flags: R/O].
[    5.976373] initcall 0xffffffff80eb9665: init_ntfs_fs+0x0/0x20b() returned 0.
[    5.988374] initcall 0xffffffff80eb9665 ran for 3 msecs: init_ntfs_fs+0x0/0x20b()
[    5.996374] Calling initcall 0xffffffff80eb9870: init_affs_fs+0x0/0x80()
[    6.004375] initcall 0xffffffff80eb9870: init_affs_fs+0x0/0x80() returned 0.
[    6.016376] initcall 0xffffffff80eb9870 ran for 0 msecs: init_affs_fs+0x0/0x80()
[    6.024376] Calling initcall 0xffffffff80eb98f0: init_romfs_fs+0x0/0x80()
[    6.036377] initcall 0xffffffff80eb98f0: init_romfs_fs+0x0/0x80() returned 0.
[    6.048378] initcall 0xffffffff80eb98f0 ran for 0 msecs: init_romfs_fs+0x0/0x80()
[    6.056378] Calling initcall 0xffffffff80eb9970: init_qnx4_fs+0x0/0x90()
[    6.064379] QNX4 filesystem 0.2.3 registered.
[    6.068379] initcall 0xffffffff80eb9970: init_qnx4_fs+0x0/0x90() returned 0.
[    6.080380] initcall 0xffffffff80eb9970 ran for 3 msecs: init_qnx4_fs+0x0/0x90()
[    6.088380] Calling initcall 0xffffffff80eb9a00: init_adfs_fs+0x0/0x80()
[    6.096381] initcall 0xffffffff80eb9a00: init_adfs_fs+0x0/0x80() returned 0.
[    6.108381] initcall 0xffffffff80eb9a00 ran for 0 msecs: init_adfs_fs+0x0/0x80()
[    6.116382] Calling initcall 0xffffffff80eb9a80: init_udf_fs+0x0/0x80()
[    6.124382] initcall 0xffffffff80eb9a80: init_udf_fs+0x0/0x80() returned 0.
[    6.136383] initcall 0xffffffff80eb9a80 ran for 0 msecs: init_udf_fs+0x0/0x80()
[    6.144384] Calling initcall 0xffffffff80eb9f07: init_xfs_fs+0x0/0x99()
[    6.152384] SGI XFS with ACLs, security attributes, large block/inode numbers, no debug enabled
[    6.156384] SGI XFS Quota Management subsystem
[    6.160385] initcall 0xffffffff80eb9f07: init_xfs_fs+0x0/0x99() returned 0.
[    6.168385] initcall 0xffffffff80eb9f07 ran for 7 msecs: init_xfs_fs+0x0/0x99()
[    6.176386] Calling initcall 0xffffffff80eba190: init_gfs2_fs+0x0/0x173()
[    6.184386] GFS2 (built Apr 18 2008 09:35:43) installed
[    6.188386] initcall 0xffffffff80eba190: init_gfs2_fs+0x0/0x173() returned 0.
[    6.200387] initcall 0xffffffff80eba190 ran for 3 msecs: init_gfs2_fs+0x0/0x173()
[    6.208388] Calling initcall 0xffffffff80eba303: init_nolock+0x0/0x7d()
[    6.216388] Lock_Nolock (built Apr 18 2008 09:35:49) installed
[    6.220388] initcall 0xffffffff80eba303: init_nolock+0x0/0x7d() returned 0.
[    6.232389] initcall 0xffffffff80eba303 ran for 3 msecs: init_nolock+0x0/0x7d()
[    6.240390] Calling initcall 0xffffffff80eba380: init_lock_dlm+0x0/0xa0()
[    6.248390] Lock_DLM (built Apr 18 2008 09:35:48) installed
[    6.252390] initcall 0xffffffff80eba380: init_lock_dlm+0x0/0xa0() returned 0.
[    6.264391] initcall 0xffffffff80eba380 ran for 3 msecs: init_lock_dlm+0x0/0xa0()
[    6.272392] Calling initcall 0xffffffff80eba420: ipc_init+0x0/0x45()
[    6.280392] initcall 0xffffffff80eba420: ipc_init+0x0/0x45() returned 0.
[    6.292393] initcall 0xffffffff80eba420 ran for 0 msecs: ipc_init+0x0/0x45()
[    6.300393] Calling initcall 0xffffffff80eba620: ipc_sysctl_init+0x0/0x3c()
[    6.308394] initcall 0xffffffff80eba620: ipc_sysctl_init+0x0/0x3c() returned 0.
[    6.320395] initcall 0xffffffff80eba620 ran for 0 msecs: ipc_sysctl_init+0x0/0x3c()
[    6.328395] Calling initcall 0xffffffff80eba65c: init_mqueue_fs+0x0/0xf4()
[    6.336396] initcall 0xffffffff80eba65c: init_mqueue_fs+0x0/0xf4() returned 0.
[    6.348396] initcall 0xffffffff80eba65c ran for 0 msecs: init_mqueue_fs+0x0/0xf4()
[    6.356397] Calling initcall 0xffffffff80eba908: key_proc_init+0x0/0x88()
[    6.368398] initcall 0xffffffff80eba908: key_proc_init+0x0/0x88() returned 0.
[    6.380398] initcall 0xffffffff80eba908 ran for 0 msecs: key_proc_init+0x0/0x88()
[    6.388399] Calling initcall 0xffffffff80ebab50: crypto_algapi_init+0x0/0x35()
[    6.396399] initcall 0xffffffff80ebab50: crypto_algapi_init+0x0/0x35() returned 0.
[    6.408400] initcall 0xffffffff80ebab50 ran for 0 msecs: crypto_algapi_init+0x0/0x35()
[    6.416401] Calling initcall 0xffffffff80ebabd0: blkcipher_module_init+0x0/0x55()
[    6.424401] initcall 0xffffffff80ebabd0: blkcipher_module_init+0x0/0x55() returned 0.
[    6.436402] initcall 0xffffffff80ebabd0 ran for 0 msecs: blkcipher_module_init+0x0/0x55()
[    6.444402] Calling initcall 0xffffffff80ebac97: seqiv_module_init+0x0/0x39()
[    6.456403] initcall 0xffffffff80ebac97: seqiv_module_init+0x0/0x39() returned 0.
[    6.468404] initcall 0xffffffff80ebac97 ran for 0 msecs: seqiv_module_init+0x0/0x39()
[    6.476404] Calling initcall 0xffffffff80ebacd0: cryptomgr_init+0x0/0x39()
[    6.484405] initcall 0xffffffff80ebacd0: cryptomgr_init+0x0/0x39() returned 0.
[    6.496406] initcall 0xffffffff80ebacd0 ran for 0 msecs: cryptomgr_init+0x0/0x39()
[    6.504406] Calling initcall 0xffffffff80ebad09: hmac_module_init+0x0/0x39()
[    6.512407] initcall 0xffffffff80ebad09: hmac_module_init+0x0/0x39() returned 0.
[    6.524407] initcall 0xffffffff80ebad09 ran for 0 msecs: hmac_module_init+0x0/0x39()
[    6.532408] Calling initcall 0xffffffff80ebad42: crypto_xcbc_module_init+0x0/0x39()
[    6.540408] initcall 0xffffffff80ebad42: crypto_xcbc_module_init+0x0/0x39() returned 0.
[    6.552409] initcall 0xffffffff80ebad42 ran for 0 msecs: crypto_xcbc_module_init+0x0/0x39()
[    6.560410] Calling initcall 0xffffffff80ebad7b: init+0x0/0x39()
[    6.572410] initcall 0xffffffff80ebad7b: init+0x0/0x39() returned 0.
[    6.580411] initcall 0xffffffff80ebad7b ran for 0 msecs: init+0x0/0x39()
[    6.588411] Calling initcall 0xffffffff80ebadb4: init+0x0/0x39()
[    6.596412] initcall 0xffffffff80ebadb4: init+0x0/0x39() returned 0.
[    6.608413] initcall 0xffffffff80ebadb4 ran for 0 msecs: init+0x0/0x39()
[    6.616413] Calling initcall 0xffffffff80ebaded: init+0x0/0x64()
[    6.624414] initcall 0xffffffff80ebaded: init+0x0/0x64() returned 0.
[    6.636414] initcall 0xffffffff80ebaded ran for 0 msecs: init+0x0/0x64()
[    6.644415] Calling initcall 0xffffffff80ebae51: crypto_ecb_module_init+0x0/0x39()
[    6.652415] initcall 0xffffffff80ebae51: crypto_ecb_module_init+0x0/0x39() returned 0.
[    6.664416] initcall 0xffffffff80ebae51 ran for 0 msecs: crypto_ecb_module_init+0x0/0x39()
[    6.672417] Calling initcall 0xffffffff80ebae8a: crypto_cbc_module_init+0x0/0x39()
[    6.680417] initcall 0xffffffff80ebae8a: crypto_cbc_module_init+0x0/0x39() returned 0.
[    6.692418] initcall 0xffffffff80ebae8a ran for 0 msecs: crypto_cbc_module_init+0x0/0x39()
[    6.700418] Calling initcall 0xffffffff80ebaec3: crypto_pcbc_module_init+0x0/0x39()
[    6.712419] initcall 0xffffffff80ebaec3: crypto_pcbc_module_init+0x0/0x39() returned 0.
[    6.724420] initcall 0xffffffff80ebaec3 ran for 0 msecs: crypto_pcbc_module_init+0x0/0x39()
[    6.732420] Calling initcall 0xffffffff80ebaefc: crypto_module_init+0x0/0x39()
[    6.740421] initcall 0xffffffff80ebaefc: crypto_module_init+0x0/0x39() returned 0.
[    6.752422] initcall 0xffffffff80ebaefc ran for 0 msecs: crypto_module_init+0x0/0x39()
[    6.760422] Calling initcall 0xffffffff80ebaf35: crypto_ctr_module_init+0x0/0x64()
[    6.772423] initcall 0xffffffff80ebaf35: crypto_ctr_module_init+0x0/0x64() returned 0.
[    6.784424] initcall 0xffffffff80ebaf35 ran for 0 msecs: crypto_ctr_module_init+0x0/0x64()
[    6.796424] Calling initcall 0xffffffff80ebaf99: crypto_gcm_module_init+0x0/0x82()
[    6.804425] initcall 0xffffffff80ebaf99: crypto_gcm_module_init+0x0/0x82() returned 0.
[    6.812425] initcall 0xffffffff80ebaf99 ran for 0 msecs: crypto_gcm_module_init+0x0/0x82()
[    6.820426] Calling initcall 0xffffffff80ebb01b: crypto_ccm_module_init+0x0/0x82()
[    6.828426] initcall 0xffffffff80ebb01b: crypto_ccm_module_init+0x0/0x82() returned 0.
[    6.840427] initcall 0xffffffff80ebb01b ran for 0 msecs: crypto_ccm_module_init+0x0/0x82()
[    6.848428] Calling initcall 0xffffffff80ebb09d: init+0x0/0x64()
[    6.856428] initcall 0xffffffff80ebb09d: init+0x0/0x64() returned 0.
[    6.868429] initcall 0xffffffff80ebb09d ran for 0 msecs: init+0x0/0x64()
[    6.876429] Calling initcall 0xffffffff80ebb101: init+0x0/0x39()
[    6.884430] initcall 0xffffffff80ebb101: init+0x0/0x39() returned 0.
[    6.896431] initcall 0xffffffff80ebb101 ran for 0 msecs: init+0x0/0x39()
[    6.904431] Calling initcall 0xffffffff80ebb13a: init+0x0/0x39()
[    6.912432] initcall 0xffffffff80ebb13a: init+0x0/0x39() returned 0.
[    6.924432] initcall 0xffffffff80ebb13a ran for 0 msecs: init+0x0/0x39()
[    6.932433] Calling initcall 0xffffffff80ebb173: init+0x0/0x39()
[    6.940433] initcall 0xffffffff80ebb173: init+0x0/0x39() returned 0.
[    6.952434] initcall 0xffffffff80ebb173 ran for 0 msecs: init+0x0/0x39()
[    6.960435] Calling initcall 0xffffffff80ebb1ac: init+0x0/0x64()
[    6.968435] initcall 0xffffffff80ebb1ac: init+0x0/0x64() returned 0.
[    6.980436] initcall 0xffffffff80ebb1ac ran for 0 msecs: init+0x0/0x64()
[    6.988436] Calling initcall 0xffffffff80ebb210: aes_init+0x0/0x350()
[    6.996437] initcall 0xffffffff80ebb210: aes_init+0x0/0x350() returned 0.
[    7.008438] initcall 0xffffffff80ebb210 ran for 0 msecs: aes_init+0x0/0x350()
[    7.016438] Calling initcall 0xffffffff80ebb560: init+0x0/0x39()
[    7.024439] initcall 0xffffffff80ebb560: init+0x0/0x39() returned 0.
[    7.036439] initcall 0xffffffff80ebb560 ran for 0 msecs: init+0x0/0x39()
[    7.044440] Calling initcall 0xffffffff80ebb599: arc4_init+0x0/0x47()
[    7.052440] initcall 0xffffffff80ebb599: arc4_init+0x0/0x47() returned 0.
[    7.064441] initcall 0xffffffff80ebb599 ran for 0 msecs: arc4_init+0x0/0x47()
[    7.072442] Calling initcall 0xffffffff80ebb5e0: init+0x0/0x90()
[    7.080442] initcall 0xffffffff80ebb5e0: init+0x0/0x90() returned 0.
[    7.092443] initcall 0xffffffff80ebb5e0 ran for 0 msecs: init+0x0/0x90()
[    7.100443] Calling initcall 0xffffffff80ebb670: init+0x0/0x39()
[    7.108444] initcall 0xffffffff80ebb670: init+0x0/0x39() returned 0.
[    7.120445] initcall 0xffffffff80ebb670 ran for 0 msecs: init+0x0/0x39()
[    7.128445] Calling initcall 0xffffffff80ebb6a9: init+0x0/0x39()
[    7.136446] initcall 0xffffffff80ebb6a9: init+0x0/0x39() returned 0.
[    7.148446] initcall 0xffffffff80ebb6a9 ran for 0 msecs: init+0x0/0x39()
[    7.156447] Calling initcall 0xffffffff80ebb6e2: init+0x0/0x39()
[    7.164447] initcall 0xffffffff80ebb6e2: init+0x0/0x39() returned 0.
[    7.176448] initcall 0xffffffff80ebb6e2 ran for 0 msecs: init+0x0/0x39()
[    7.184449] Calling initcall 0xffffffff80ebb71b: crypto_authenc_module_init+0x0/0x39()
[    7.196449] initcall 0xffffffff80ebb71b: crypto_authenc_module_init+0x0/0x39() returned 0.
[    7.208450] initcall 0xffffffff80ebb71b ran for 0 msecs: crypto_authenc_module_init+0x0/0x39()
[    7.216451] Calling initcall 0xffffffff80ebb754: init+0x0/0x3c()
[    7.224451] initcall 0xffffffff80ebb754: init+0x0/0x3c() returned 0.
[    7.236452] initcall 0xffffffff80ebb754 ran for 0 msecs: init+0x0/0x3c()
[    7.244452] Calling initcall 0xffffffff80ebbbf0: noop_init+0x0/0x40()
[    7.252453] io scheduler noop registered (default)
[    7.256453] initcall 0xffffffff80ebbbf0: noop_init+0x0/0x40() returned 0.
[    7.268454] initcall 0xffffffff80ebbbf0 ran for 3 msecs: noop_init+0x0/0x40()
[    7.276454] Calling initcall 0xffffffff80ebbef0: percpu_counter_startup+0x0/0x40()
[    7.284455] initcall 0xffffffff80ebbef0: percpu_counter_startup+0x0/0x40() returned 0.
[    7.296456] initcall 0xffffffff80ebbef0 ran for 0 msecs: percpu_counter_startup+0x0/0x40()
[    7.304456] Calling initcall 0xffffffff80a73fc0: pci_init+0x0/0x60()
[    7.312457] pci 0000:00:1d.0: uhci_check_and_reset_hc: legsup = 0x003b
[    7.316457] pci 0000:00:1d.0: Performing full reset
[    7.320457] pci 0000:00:1d.1: uhci_check_and_reset_hc: legsup = 0x0010
[    7.324457] pci 0000:00:1d.1: Performing full reset
[    7.328458] pci 0000:00:1d.2: uhci_check_and_reset_hc: legsup = 0x0010
[    7.332458] pci 0000:00:1d.2: Performing full reset
[    7.336458] pci 0000:00:1d.7: EHCI: BIOS handoff
[   15.340958] pci 0000:00:1d.7: EHCI: BIOS handoff failed (BIOS bug?) 01010001
[   15.344959] pci 0000:08:01.0: Boot video device
[   15.348959] initcall 0xffffffff80a73fc0: pci_init+0x0/0x60() returned 0.
[   15.360960] initcall 0xffffffff80a73fc0 ran for 7663 msecs: pci_init+0x0/0x60()
[   15.368960] Calling initcall 0xffffffff80ebc8c0: pci_proc_init+0x0/0xa0()
[   15.376961] initcall 0xffffffff80ebc8c0: pci_proc_init+0x0/0xa0() returned 0.
[   15.388961] initcall 0xffffffff80ebc8c0 ran for 0 msecs: pci_proc_init+0x0/0xa0()
[   15.396962] Calling initcall 0xffffffff80ebc960: pci_hotplug_init+0x0/0xc1()
[   15.404962] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   15.408963] initcall 0xffffffff80ebc960: pci_hotplug_init+0x0/0xc1() returned 0.
[   15.420963] initcall 0xffffffff80ebc960 ran for 3 msecs: pci_hotplug_init+0x0/0xc1()
[   15.428964] Calling initcall 0xffffffff80ebca60: acpiphp_init+0x0/0x90()
[   15.436964] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[   15.440965] initcall 0xffffffff80ebca60: acpiphp_init+0x0/0x90() returned 0.
[   15.452965] initcall 0xffffffff80ebca60 ran for 3 msecs: acpiphp_init+0x0/0x90()
[   15.460966] Calling initcall 0xffffffff80ebcc2d: ibm_acpiphp_init+0x0/0x1bb()
[   15.468966] ACPI Exception (utmutex-0263): AE_BAD_PARAMETER, Thread FFFF8101AFC5F750 could not acquire Mutex [1] [20070126]
[   15.480967] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[   15.484967] initcall 0xffffffff80ebcc2d: ibm_acpiphp_init+0x0/0x1bb() returned -19.
[   15.496968] initcall 0xffffffff80ebcc2d ran for 15 msecs: ibm_acpiphp_init+0x0/0x1bb()
[   15.504969] Calling initcall 0xffffffff80ebcef0: zt5550_init+0x0/0xa0()
[   15.516969] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[   15.520970] initcall 0xffffffff80ebcef0: zt5550_init+0x0/0xa0() returned 0.
[   15.532970] initcall 0xffffffff80ebcef0 ran for 3 msecs: zt5550_init+0x0/0xa0()
[   15.540971] Calling initcall 0xffffffff80ebd2b0: display_class_init+0x0/0xa8()
[   15.548971] initcall 0xffffffff80ebd2b0: display_class_init+0x0/0xa8() returned 0.
[   15.560972] initcall 0xffffffff80ebd2b0 ran for 0 msecs: display_class_init+0x0/0xa8()
[   15.568973] Calling initcall 0xffffffff80ebd358: arcfb_init+0x0/0x9a()
[   15.576973] initcall 0xffffffff80ebd358: arcfb_init+0x0/0x9a() returned -6.
[   15.588974] initcall 0xffffffff80ebd358 ran for 0 msecs: arcfb_init+0x0/0x9a()
[   15.596974] initcall at 0xffffffff80ebd358: arcfb_init+0x0/0x9a(): returned with error code -6
[   15.608975] Calling initcall 0xffffffff80ebd787: cyber2000fb_init+0x0/0xf3()
[   15.616976] initcall 0xffffffff80ebd787: cyber2000fb_init+0x0/0xf3() returned 0.
[   15.624976] initcall 0xffffffff80ebd787 ran for 0 msecs: cyber2000fb_init+0x0/0xf3()
[   15.632977] Calling initcall 0xffffffff80ebd87a: pm2fb_init+0x0/0x176()
[   15.640977] initcall 0xffffffff80ebd87a: pm2fb_init+0x0/0x176() returned 0.
[   15.648978] initcall 0xffffffff80ebd87a ran for 0 msecs: pm2fb_init+0x0/0x176()
[   15.656978] Calling initcall 0xffffffff80ebd9f0: matroxfb_init+0x0/0x9e5()
[   15.664979] initcall 0xffffffff80ebd9f0: matroxfb_init+0x0/0x9e5() returned 0.
[   15.676979] initcall 0xffffffff80ebd9f0 ran for 0 msecs: matroxfb_init+0x0/0x9e5()
[   15.684980] Calling initcall 0xffffffff80a76050: aty128fb_init+0x0/0x15c()
[   15.692980] initcall 0xffffffff80a76050: aty128fb_init+0x0/0x15c() returned 0.
[   15.704981] initcall 0xffffffff80a76050 ran for 0 msecs: aty128fb_init+0x0/0x15c()
[   15.712982] Calling initcall 0xffffffff80ebe3d5: neofb_init+0x0/0x17b()
[   15.724982] initcall 0xffffffff80ebe3d5: neofb_init+0x0/0x17b() returned 0.
[   15.736983] initcall 0xffffffff80ebe3d5 ran for 3 msecs: neofb_init+0x0/0x17b()
[   15.744984] Calling initcall 0xffffffff80ebe550: imsttfb_init+0x0/0x145()
[   15.752984] initcall 0xffffffff80ebe550: imsttfb_init+0x0/0x145() returned 0.
[   15.764985] initcall 0xffffffff80ebe550 ran for 0 msecs: imsttfb_init+0x0/0x145()
[   15.772985] Calling initcall 0xffffffff80ebe695: vt8623fb_init+0x0/0x86()
[   15.780986] initcall 0xffffffff80ebe695: vt8623fb_init+0x0/0x86() returned 0.
[   15.792987] initcall 0xffffffff80ebe695 ran for 0 msecs: vt8623fb_init+0x0/0x86()
[   15.800987] Calling initcall 0xffffffff80ebe71b: vmlfb_init+0x0/0xbc()
[   15.808988] vmlfb: initializing
[   15.812988] initcall 0xffffffff80ebe71b: vmlfb_init+0x0/0xbc() returned 0.
[   15.824989] initcall 0xffffffff80ebe71b ran for 3 msecs: vmlfb_init+0x0/0xbc()
[   15.832989] Calling initcall 0xffffffff80ebe7d7: s3fb_init+0x0/0x119()
[   15.840990] initcall 0xffffffff80ebe7d7: s3fb_init+0x0/0x119() returned 0.
[   15.852990] initcall 0xffffffff80ebe7d7 ran for 0 msecs: s3fb_init+0x0/0x119()
[   15.860991] Calling initcall 0xffffffff80ebe8f0: hgafb_init+0x0/0x7b()
[   15.868991] hgafb: HGA card not detected.
[   15.872992] hgafb: probe of hgafb.0 failed with error -22
[   15.876992] initcall 0xffffffff80ebe8f0: hgafb_init+0x0/0x7b() returned 0.
[   15.888993] initcall 0xffffffff80ebe8f0 ran for 7 msecs: hgafb_init+0x0/0x7b()
[   15.896993] Calling initcall 0xffffffff80ebed20: s1d13xxxfb_init+0x0/0x67()
[   15.908994] initcall 0xffffffff80ebed20: s1d13xxxfb_init+0x0/0x67() returned 0.
[   15.920995] initcall 0xffffffff80ebed20 ran for 0 msecs: s1d13xxxfb_init+0x0/0x67()
[   15.928995] Calling initcall 0xffffffff80a795b7: sm501fb_init+0x0/0x39()
[   15.936996] initcall 0xffffffff80a795b7: sm501fb_init+0x0/0x39() returned 0.
[   15.948996] initcall 0xffffffff80a795b7 ran for 0 msecs: sm501fb_init+0x0/0x39()
[   15.956997] Calling initcall 0xffffffff80ebf9ed: imacfb_init+0x0/0x20e()
[   15.964997] initcall 0xffffffff80ebf9ed: imacfb_init+0x0/0x20e() returned -19.
[   15.976998] initcall 0xffffffff80ebf9ed ran for 0 msecs: imacfb_init+0x0/0x20e()
[   15.984999] Calling initcall 0xffffffff80ec02c1: acpi_reserve_resources+0x0/0x113()
[   15.996999] initcall 0xffffffff80ec02c1: acpi_reserve_resources+0x0/0x113() returned 0.
[   16.009000] initcall 0xffffffff80ec02c1 ran for 0 msecs: acpi_reserve_resources+0x0/0x113()
[   16.017001] Calling initcall 0xffffffff80ec14cf: acpi_battery_init+0x0/0x50()
[   16.025001] initcall 0xffffffff80ec14cf: acpi_battery_init+0x0/0x50() returned -19.
[   16.037002] initcall 0xffffffff80ec14cf ran for 0 msecs: acpi_battery_init+0x0/0x50()
[   16.045002] Calling initcall 0xffffffff80ec151f: acpi_fan_init+0x0/0x5a()
[   16.053003] initcall 0xffffffff80ec151f: acpi_fan_init+0x0/0x5a() returned -19.
[   16.065004] initcall 0xffffffff80ec151f ran for 0 msecs: acpi_fan_init+0x0/0x5a()
[   16.073004] Calling initcall 0xffffffff80ec17ab: irqrouter_init_sysfs+0x0/0x72()
[   16.085005] initcall 0xffffffff80ec17ab: irqrouter_init_sysfs+0x0/0x72() returned 0.
[   16.093005] initcall 0xffffffff80ec17ab ran for 0 msecs: irqrouter_init_sysfs+0x0/0x72()
[   16.101006] Calling initcall 0xffffffff80ec19ec: acpi_container_init+0x0/0x68()
[   16.109006] initcall 0xffffffff80ec19ec: acpi_container_init+0x0/0x68() returned -19.
[   16.121007] initcall 0xffffffff80ec19ec ran for 0 msecs: acpi_container_init+0x0/0x68()
[   16.129008] Calling initcall 0xffffffff80ec1c92: acpi_memory_device_init+0x0/0xae()
[   16.137008] initcall 0xffffffff80ec1c92: acpi_memory_device_init+0x0/0xae() returned -19.
[   16.149009] initcall 0xffffffff80ec1c92 ran for 0 msecs: acpi_memory_device_init+0x0/0xae()
[   16.157009] Calling initcall 0xffffffff80ec2b80: rand_initialize+0x0/0x55()
[   16.165010] initcall 0xffffffff80ec2b80: rand_initialize+0x0/0x55() returned 0.
[   16.177011] initcall 0xffffffff80ec2b80 ran for 0 msecs: rand_initialize+0x0/0x55()
[   16.185011] Calling initcall 0xffffffff80ec2c62: tty_init+0x0/0x211()
[   16.197012] initcall 0xffffffff80ec2c62: tty_init+0x0/0x211() returned 0.
[   16.209013] initcall 0xffffffff80ec2c62 ran for 3 msecs: tty_init+0x0/0x211()
[   16.217013] Calling initcall 0xffffffff80ec2ed5: pty_init+0x0/0x32b()
[   16.225014] initcall 0xffffffff80ec2ed5: pty_init+0x0/0x32b() returned 0.
[   16.237014] initcall 0xffffffff80ec2ed5 ran for 0 msecs: pty_init+0x0/0x32b()
[   16.245015] Calling initcall 0xffffffff80ec39d0: rp_init+0x0/0x1b56()
[   16.257016] RocketPort device driver module, version 2.09, 12-June-2003
[   16.265016] No rocketport ports found; unloading driver
[   16.269016] initcall 0xffffffff80ec39d0: rp_init+0x0/0x1b56() returned -6.
[   16.281017] initcall 0xffffffff80ec39d0 ran for 11 msecs: rp_init+0x0/0x1b56()
[   16.289018] initcall at 0xffffffff80ec39d0: rp_init+0x0/0x1b56(): returned with error code -6
[   16.301018] Calling initcall 0xffffffff80ec5526: nozomi_init+0x0/0x18a()
[   16.309019] Initializing Nozomi driver 2.1d (build date: Apr 18 2008 09:35:32)
[   16.313019] initcall 0xffffffff80ec5526: nozomi_init+0x0/0x18a() returned 0.
[   16.325020] initcall 0xffffffff80ec5526 ran for 3 msecs: nozomi_init+0x0/0x18a()
[   16.333020] Calling initcall 0xffffffff80ec56b0: mxser_module_init+0x0/0x8c0()
[   16.341021] MOXA Smartio/Industio family driver version 2.0.3
[   16.345021] initcall 0xffffffff80ec56b0: mxser_module_init+0x0/0x8c0() returned 0.
[   16.357022] initcall 0xffffffff80ec56b0 ran for 3 msecs: mxser_module_init+0x0/0x8c0()
[   16.365022] Calling initcall 0xffffffff80ec5f70: ip2_init+0x0/0x7e()
[   16.373023] Computone IntelliPort Plus multiport driver version 1.2.14
[   16.377023] initcall 0xffffffff80ec5f70: ip2_init+0x0/0x7e() returned 0.
[   16.389024] initcall 0xffffffff80ec5f70 ran for 3 msecs: ip2_init+0x0/0x7e()
[   16.397024] Calling initcall 0xffffffff80ec6076: isicom_init+0x0/0x20a()
[   16.405025] initcall 0xffffffff80ec6076: isicom_init+0x0/0x20a() returned 0.
[   16.413025] initcall 0xffffffff80ec6076 ran for 0 msecs: isicom_init+0x0/0x20a()
[   16.421026] Calling initcall 0xffffffff80ec6280: synclinkmp_init+0x0/0x1f0()
[   16.429026] SyncLink MultiPort driver $Revision: 4.38 $
[   16.437027] SyncLink MultiPort driver $Revision: 4.38 $, tty major#253
[   16.441027] initcall 0xffffffff80ec6280: synclinkmp_init+0x0/0x1f0() returned 0.
[   16.453028] initcall 0xffffffff80ec6280 ran for 11 msecs: synclinkmp_init+0x0/0x1f0()
[   16.461028] Calling initcall 0xffffffff80ec6470: n_hdlc_init+0x0/0xbd()
[   16.469029] HDLC line discipline: version $Revision: 4.8 $, maxframe=4096
[   16.473029] N_HDLC line discipline registered.
[   16.477029] initcall 0xffffffff80ec6470: n_hdlc_init+0x0/0xbd() returned 0.
[   16.489030] initcall 0xffffffff80ec6470 ran for 7 msecs: n_hdlc_init+0x0/0xbd()
[   16.497031] Calling initcall 0xffffffff80ec652d: sx_init+0x0/0x143()
[   16.505031] initcall 0xffffffff80ec652d: sx_init+0x0/0x143() returned 0.
[   16.517032] initcall 0xffffffff80ec652d ran for 0 msecs: sx_init+0x0/0x143()
[   16.525032] Calling initcall 0xffffffff80ec6670: rio_init+0x0/0x1274()
[   16.537033] initcall 0xffffffff80ec6670: rio_init+0x0/0x1274() returned -5.
[   16.549034] initcall 0xffffffff80ec6670 ran for 0 msecs: rio_init+0x0/0x1274()
[   16.557034] initcall at 0xffffffff80ec6670: rio_init+0x0/0x1274(): returned with error code -5
[   16.569035] Calling initcall 0xffffffff80ec78e4: raw_init+0x0/0xfc()
[   16.581036] initcall 0xffffffff80ec78e4: raw_init+0x0/0xfc() returned 0.
[   16.593037] initcall 0xffffffff80ec78e4 ran for 0 msecs: raw_init+0x0/0xfc()
[   16.601037] Calling initcall 0xffffffff80ec7b47: lp_init_module+0x0/0x299()
[   16.609038] lp: driver loaded but no devices found
[   16.613038] initcall 0xffffffff80ec7b47: lp_init_module+0x0/0x299() returned 0.
[   16.625039] initcall 0xffffffff80ec7b47 ran for 3 msecs: lp_init_module+0x0/0x299()
[   16.633039] Calling initcall 0xffffffff80ec7de0: r3964_init+0x0/0x70()
[   16.641040] r3964: Philips r3964 Driver $Revision: 1.10 $
[   16.645040] initcall 0xffffffff80ec7de0: r3964_init+0x0/0x70() returned 0.
[   16.657041] initcall 0xffffffff80ec7de0 ran for 3 msecs: r3964_init+0x0/0x70()
[   16.665041] Calling initcall 0xffffffff80ec7eb3: rtc_init+0x0/0x207()
[   16.673042] Real Time Clock Driver v1.12ac
[   16.677042] initcall 0xffffffff80ec7eb3: rtc_init+0x0/0x207() returned 0.
[   16.689043] initcall 0xffffffff80ec7eb3 ran for 3 msecs: rtc_init+0x0/0x207()
[   16.697043] Calling initcall 0xffffffff80ec80ba: nvram_init+0x0/0xb6()
[   16.705044] Non-volatile memory driver v1.2
[   16.709044] initcall 0xffffffff80ec80ba: nvram_init+0x0/0xb6() returned 0.
[   16.721045] initcall 0xffffffff80ec80ba ran for 3 msecs: nvram_init+0x0/0xb6()
[   16.729045] Calling initcall 0xffffffff80ec8170: i8k_init+0x0/0x250()
[   16.737046] initcall 0xffffffff80ec8170: i8k_init+0x0/0x250() returned -19.
[   16.749046] initcall 0xffffffff80ec8170 ran for 0 msecs: i8k_init+0x0/0x250()
[   16.757047] Calling initcall 0xffffffff80ec83c0: ppdev_init+0x0/0xe2()
[   16.765047] ppdev: user-space parallel port driver
[   16.769048] initcall 0xffffffff80ec83c0: ppdev_init+0x0/0xe2() returned 0.
[   16.781048] initcall 0xffffffff80ec83c0 ran for 3 msecs: ppdev_init+0x0/0xe2()
[   16.789049] Calling initcall 0xffffffff80ec84a2: tlclk_init+0x0/0x1ee()
[   16.797049] telclk_interrup = 0xf non-mcpbl0010 hw.
[   16.801050] initcall 0xffffffff80ec84a2: tlclk_init+0x0/0x1ee() returned -6.
[   16.813050] initcall 0xffffffff80ec84a2 ran for 3 msecs: tlclk_init+0x0/0x1ee()
[   16.821051] initcall at 0xffffffff80ec84a2: tlclk_init+0x0/0x1ee(): returned with error code -6
[   16.833052] Calling initcall 0xffffffff80ec8719: agp_init+0x0/0x57()
[   16.841052] Linux agpgart interface v0.103
[   16.845052] initcall 0xffffffff80ec8719: agp_init+0x0/0x57() returned 0.
[   16.857053] initcall 0xffffffff80ec8719 ran for 3 msecs: agp_init+0x0/0x57()
[   16.865054] Calling initcall 0xffffffff80ec8770: agp_amd64_init+0x0/0xf0()
[   16.873054] initcall 0xffffffff80ec8770: agp_amd64_init+0x0/0xf0() returned 0.
[   16.885055] initcall 0xffffffff80ec8770 ran for 0 msecs: agp_amd64_init+0x0/0xf0()
[   16.893055] Calling initcall 0xffffffff80ec8860: agp_intel_init+0x0/0x70()
[   16.901056] initcall 0xffffffff80ec8860: agp_intel_init+0x0/0x70() returned 0.
[   16.913057] initcall 0xffffffff80ec8860 ran for 0 msecs: agp_intel_init+0x0/0x70()
[   16.921057] Calling initcall 0xffffffff80ec88d0: agp_sis_init+0x0/0x70()
[   16.929058] initcall 0xffffffff80ec88d0: agp_sis_init+0x0/0x70() returned 0.
[   16.941058] initcall 0xffffffff80ec88d0 ran for 0 msecs: agp_sis_init+0x0/0x70()
[   16.949059] Calling initcall 0xffffffff80ec8940: agp_via_init+0x0/0x66()
[   16.957059] initcall 0xffffffff80ec8940: agp_via_init+0x0/0x66() returned 0.
[   16.969060] initcall 0xffffffff80ec8940 ran for 0 msecs: agp_via_init+0x0/0x66()
[   16.977061] Calling initcall 0xffffffff80ec89a6: drm_core_init+0x0/0x17e()
[   16.985061] [drm] Initialized drm 1.1.0 20060810
[   16.989061] initcall 0xffffffff80ec89a6: drm_core_init+0x0/0x17e() returned 0.
[   17.001062] initcall 0xffffffff80ec89a6 ran for 3 msecs: drm_core_init+0x0/0x17e()
[   17.009063] Calling initcall 0xffffffff80ec8b24: tdfx_init+0x0/0x39()
[   17.017063] initcall 0xffffffff80ec8b24: tdfx_init+0x0/0x39() returned 0.
[   17.029064] initcall 0xffffffff80ec8b24 ran for 0 msecs: tdfx_init+0x0/0x39()
[   17.037064] Calling initcall 0xffffffff80ec8b5d: r128_init+0x0/0x45()
[   17.049065] initcall 0xffffffff80ec8b5d: r128_init+0x0/0x45() returned 0.
[   17.061066] initcall 0xffffffff80ec8b5d ran for 0 msecs: r128_init+0x0/0x45()
[   17.069066] Calling initcall 0xffffffff80ec8ba2: mga_init+0x0/0x45()
[   17.077067] initcall 0xffffffff80ec8ba2: mga_init+0x0/0x45() returned 0.
[   17.089068] initcall 0xffffffff80ec8ba2 ran for 0 msecs: mga_init+0x0/0x45()
[   17.097068] Calling initcall 0xffffffff80ec8be7: i830_init+0x0/0x45()
[   17.105069] initcall 0xffffffff80ec8be7: i830_init+0x0/0x45() returned 0.
[   17.117069] initcall 0xffffffff80ec8be7 ran for 0 msecs: i830_init+0x0/0x45()
[   17.125070] Calling initcall 0xffffffff80ec8c2c: savage_init+0x0/0x54()
[   17.133070] initcall 0xffffffff80ec8c2c: savage_init+0x0/0x54() returned 0.
[   17.145071] initcall 0xffffffff80ec8c2c ran for 0 msecs: savage_init+0x0/0x54()
[   17.153072] Calling initcall 0xffffffff80ec8dc8: hangcheck_init+0x0/0xc3()
[   17.161072] Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin is 60 seconds).
[   17.165072] Hangcheck: Using get_cycles().
[   17.169073] initcall 0xffffffff80ec8dc8: hangcheck_init+0x0/0xc3() returned 0.
[   17.181073] initcall 0xffffffff80ec8dc8 ran for 7 msecs: hangcheck_init+0x0/0xc3()
[   17.189074] Calling initcall 0xffffffff80ec8e8b: init_atmel+0x0/0x1a1()
[   17.197074] initcall 0xffffffff80ec8e8b: init_atmel+0x0/0x1a1() returned -19.
[   17.209075] initcall 0xffffffff80ec8e8b ran for 0 msecs: init_atmel+0x0/0x1a1()
[   17.217076] Calling initcall 0xffffffff80ec902c: init_inf+0x0/0x44()
[   17.225076] initcall 0xffffffff80ec902c: init_inf+0x0/0x44() returned 0.
[   17.237077] initcall 0xffffffff80ec902c ran for 0 msecs: init_inf+0x0/0x44()
[   17.245077] Calling initcall 0xffffffff80ec946c: serial8250_init+0x0/0x169()
[   17.253078] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
[   17.513094] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
i? 1/2 [   17.773110] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[   17.777111] initcall 0xffffffff80ec946c: serial8250_init+0x0/0x169() returned 0.
[   17.789111] initcall 0xffffffff80ec946c ran for 499 msecs: serial8250_init+0x0/0x169()
[   17.797112] Calling initcall 0xffffffff80ec95d5: serial8250_pnp_init+0x0/0x3b()
[   17.805112] initcall 0xffffffff80ec95d5: serial8250_pnp_init+0x0/0x3b() returned 0.
[   17.817113] initcall 0xffffffff80ec95d5 ran for 0 msecs: serial8250_pnp_init+0x0/0x3b()
[   17.825114] Calling initcall 0xffffffff80ec9b80: parport_default_proc_register+0x0/0x50()
[   17.833114] initcall 0xffffffff80ec9b80: parport_default_proc_register+0x0/0x50() returned 0.
[   17.845115] initcall 0xffffffff80ec9b80 ran for 0 msecs: parport_default_proc_register+0x0/0x50()
[   17.853115] Calling initcall 0xffffffff80ec9f69: parport_pc_init+0x0/0x427()
[   17.861116] initcall 0xffffffff80ec9f69: parport_pc_init+0x0/0x427() returned 0.
[   17.873117] initcall 0xffffffff80ec9f69 ran for 0 msecs: parport_pc_init+0x0/0x427()
[   17.881117] Calling initcall 0xffffffff80ab74e2: topology_sysfs_init+0x0/0x75()
[   17.889118] initcall 0xffffffff80ab74e2: topology_sysfs_init+0x0/0x75() returned 0.
[   17.901118] initcall 0xffffffff80ab74e2 ran for 0 msecs: topology_sysfs_init+0x0/0x75()
[   17.909119] Calling initcall 0xffffffff80ecac80: floppy_init+0x0/0x1190()
[   20.933308] floppy0: no floppy controllers found
[   20.937308] initcall 0xffffffff80ecac80: floppy_init+0x0/0x1190() returned -19.
[   20.949309] initcall 0xffffffff80ecac80 ran for 2880 msecs: floppy_init+0x0/0x1190()
[   20.957309] Calling initcall 0xffffffff80ecbe81: brd_init+0x0/0x1af()
[   20.965310] brd: module loaded
[   20.969310] initcall 0xffffffff80ecbe81: brd_init+0x0/0x1af() returned 0.
[   20.981311] initcall 0xffffffff80ecbe81 ran for 3 msecs: brd_init+0x0/0x1af()
[   20.989311] Calling initcall 0xffffffff80ecc030: loop_init+0x0/0x1c2()
[   20.997312] loop: module loaded
[   21.001312] initcall 0xffffffff80ecc030: loop_init+0x0/0x1c2() returned 0.
[   21.009313] initcall 0xffffffff80ecc030 ran for 3 msecs: loop_init+0x0/0x1c2()
[   21.017313] Calling initcall 0xffffffff80ecc7c1: cpqarray_init+0x0/0x2b5()
[   21.025314] Compaq SMART2 Driver (v 2.6.0)
[   21.029314] initcall 0xffffffff80ecc7c1: cpqarray_init+0x0/0x2b5() returned 0.
[   21.041315] initcall 0xffffffff80ecc7c1 ran for 3 msecs: cpqarray_init+0x0/0x2b5()
[   21.049315] Calling initcall 0xffffffff80ecce55: cciss_init+0x0/0x5b()
[   21.057316] HP CISS Driver (v 3.6.14)
[   21.061316] initcall 0xffffffff80ecce55: cciss_init+0x0/0x5b() returned 0.
[   21.073317] initcall 0xffffffff80ecce55 ran for 3 msecs: cciss_init+0x0/0x5b()
[   21.081317] Calling initcall 0xffffffff80ecceb0: nbd_init+0x0/0x2f0()
[   21.089318] nbd: registered device at major 43
[   21.093318] initcall 0xffffffff80ecceb0: nbd_init+0x0/0x2f0() returned 0.
[   21.105319] initcall 0xffffffff80ecceb0 ran for 3 msecs: nbd_init+0x0/0x2f0()
[   21.113319] Calling initcall 0xffffffff80ecd1a0: init_cryptoloop+0x0/0x55()
[   21.125320] initcall 0xffffffff80ecd1a0: init_cryptoloop+0x0/0x55() returned 0.
[   21.137321] initcall 0xffffffff80ecd1a0 ran for 0 msecs: init_cryptoloop+0x0/0x55()
[   21.145321] Calling initcall 0xffffffff80ecd1f5: carm_init+0x0/0x42()
[   21.157322] initcall 0xffffffff80ecd1f5: carm_init+0x0/0x42() returned 0.
[   21.169323] initcall 0xffffffff80ecd1f5 ran for 0 msecs: carm_init+0x0/0x42()
[   21.177323] Calling initcall 0xffffffff80ecd2d3: sm501_base_init+0x0/0x5d()
[   21.185324] initcall 0xffffffff80ecd2d3: sm501_base_init+0x0/0x5d() returned 0.
[   21.197324] initcall 0xffffffff80ecd2d3 ran for 0 msecs: sm501_base_init+0x0/0x5d()
[   21.205325] Calling initcall 0xffffffff80ecd330: e1000_init_module+0x0/0xa8()
[   21.213325] Intel(R) PRO/1000 Network Driver - version 7.3.20-k2
[   21.217326] Copyright (c) 1999-2006 Intel Corporation.
[   21.221326] PCI: setting IRQ 11 as level-triggered
[   21.225326] PCI: Found IRQ 11 for device 0000:04:00.0
[   21.229326] PCI: Sharing IRQ 11 with 0000:00:1d.2
[   21.233327] PCI: Sharing IRQ 11 with 0000:08:01.0
[   21.237327] PCI: Setting latency timer of device 0000:04:00.0 to 64
[   21.265329] e1000: 0000:04:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4) 00:30:48:79:5c:52
[   21.273329] e1000: 0000:04:00.0: e1000_probe: This device (id 8086:1096) will no longer be supported by this driver in the future.
[   21.277329] e1000: 0000:04:00.0: e1000_probe: please use the "e1000e" driver instead.
[   21.317332] e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
[   21.321332] PCI: setting IRQ 10 as level-triggered
[   21.325332] PCI: Found IRQ 10 for device 0000:04:00.1
[   21.329333] PCI: Sharing IRQ 10 with 0000:00:1d.1
[   21.333333] PCI: Sharing IRQ 10 with 0000:00:1f.2
[   21.337333] PCI: Sharing IRQ 10 with 0000:00:1f.3
[   21.341333] PCI: Setting latency timer of device 0000:04:00.1 to 64
[   21.369335] e1000: 0000:04:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4) 00:30:48:79:5c:53
[   21.377336] e1000: 0000:04:00.1: e1000_probe: This device (id 8086:1096) will no longer be supported by this driver in the future.
[   21.381336] e1000: 0000:04:00.1: e1000_probe: please use the "e1000e" driver instead.
[   21.425339] e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
[   21.429339] initcall 0xffffffff80ecd330: e1000_init_module+0x0/0xa8() returned 0.
[   21.441340] initcall 0xffffffff80ecd330 ran for 205 msecs: e1000_init_module+0x0/0xa8()
[   21.449340] Calling initcall 0xffffffff80ecd3d8: igb_init_module+0x0/0x71()
[   21.457341] Intel(R) Gigabit Ethernet Network Driver - version 1.0.8-k2
[   21.461341] Copyright (c) 2007 Intel Corporation.
[   21.465341] initcall 0xffffffff80ecd3d8: igb_init_module+0x0/0x71() returned 0.
[   21.477342] initcall 0xffffffff80ecd3d8 ran for 7 msecs: igb_init_module+0x0/0x71()
[   21.485342] Calling initcall 0xffffffff80ecd449: ipg_init_module+0x0/0x47()
[   21.493343] initcall 0xffffffff80ecd449: ipg_init_module+0x0/0x47() returned 0.
[   21.505344] initcall 0xffffffff80ecd449 ran for 0 msecs: ipg_init_module+0x0/0x47()
[   21.513344] Calling initcall 0xffffffff80ecd490: bonding_init+0x0/0x91f()
[   21.521345] Ethernet Channel Bonding Driver: v3.2.5 (March 21, 2008)
[   21.525345] bonding: Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.
[   21.529345] initcall 0xffffffff80ecd490: bonding_init+0x0/0x91f() returned 0.
[   21.541346] initcall 0xffffffff80ecd490 ran for 7 msecs: bonding_init+0x0/0x91f()
[   21.549346] Calling initcall 0xffffffff80ecddaf: atl1_init_module+0x0/0x51()
[   21.557347] initcall 0xffffffff80ecddaf: atl1_init_module+0x0/0x51() returned 0.
[   21.569348] initcall 0xffffffff80ecddaf ran for 0 msecs: atl1_init_module+0x0/0x51()
[   21.577348] Calling initcall 0xffffffff80ecdee8: plip_init+0x0/0x9d()
[   21.585349] initcall 0xffffffff80ecdee8: plip_init+0x0/0x9d() returned 0.
[   21.593349] initcall 0xffffffff80ecdee8 ran for 0 msecs: plip_init+0x0/0x9d()
[   21.601350] Calling initcall 0xffffffff80ecdf85: rr_init_module+0x0/0x42()
[   21.609350] initcall 0xffffffff80ecdf85: rr_init_module+0x0/0x42() returned 0.
[   21.617351] initcall 0xffffffff80ecdf85 ran for 0 msecs: rr_init_module+0x0/0x42()
[   21.625351] Calling initcall 0xffffffff80ecdfc7: vortex_init+0x0/0xd7()
[   21.633352] initcall 0xffffffff80ecdfc7: vortex_init+0x0/0xd7() returned 0.
[   21.645352] initcall 0xffffffff80ecdfc7 ran for 0 msecs: vortex_init+0x0/0xd7()
[   21.653353] Calling initcall 0xffffffff80ece09e: typhoon_init+0x0/0x42()
[   21.661353] initcall 0xffffffff80ece09e: typhoon_init+0x0/0x42() returned 0.
[   21.673354] initcall 0xffffffff80ece09e ran for 0 msecs: typhoon_init+0x0/0x42()
[   21.681355] Calling initcall 0xffffffff80ece0e0: ne2k_pci_init+0x0/0x42()
[   21.689355] initcall 0xffffffff80ece0e0: ne2k_pci_init+0x0/0x42() returned 0.
[   21.701356] initcall 0xffffffff80ece0e0 ran for 0 msecs: ne2k_pci_init+0x0/0x42()
[   21.709356] Calling initcall 0xffffffff80ece122: eepro100_init_module+0x0/0x42()
[   21.717357] initcall 0xffffffff80ece122: eepro100_init_module+0x0/0x42() returned 0.
[   21.729358] initcall 0xffffffff80ece122 ran for 0 msecs: eepro100_init_module+0x0/0x42()
[   21.737358] Calling initcall 0xffffffff80ece164: e100_init_module+0x0/0x81()
[   21.749359] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[   21.753359] e100: Copyright(c) 1999-2006 Intel Corporation
[   21.757359] initcall 0xffffffff80ece164: e100_init_module+0x0/0x81() returned 0.
[   21.769360] initcall 0xffffffff80ece164 ran for 7 msecs: e100_init_module+0x0/0x81()
[   21.777361] Calling initcall 0xffffffff80ece1e5: epic_init+0x0/0x42()
[   21.785361] initcall 0xffffffff80ece1e5: epic_init+0x0/0x42() returned 0.
[   21.797362] initcall 0xffffffff80ece1e5 ran for 0 msecs: epic_init+0x0/0x42()
[   21.805362] Calling initcall 0xffffffff80ece227: yellowfin_init+0x0/0x42()
[   21.813363] initcall 0xffffffff80ece227: yellowfin_init+0x0/0x42() returned 0.
[   21.825364] initcall 0xffffffff80ece227 ran for 0 msecs: yellowfin_init+0x0/0x42()
[   21.833364] Calling initcall 0xffffffff80ece269: acenic_init+0x0/0x42()
[   21.845365] initcall 0xffffffff80ece269: acenic_init+0x0/0x42() returned 0.
[   21.853365] initcall 0xffffffff80ece269 ran for 0 msecs: acenic_init+0x0/0x42()
[   21.861366] Calling initcall 0xffffffff80ece2ab: natsemi_init_mod+0x0/0x42()
[   21.869366] initcall 0xffffffff80ece2ab: natsemi_init_mod+0x0/0x42() returned 0.
[   21.881367] initcall 0xffffffff80ece2ab ran for 0 msecs: natsemi_init_mod+0x0/0x42()
[   21.889368] Calling initcall 0xffffffff80ece2ed: ns83820_init+0x0/0x4e()
[   21.897368] ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
[   21.901368] initcall 0xffffffff80ece2ed: ns83820_init+0x0/0x4e() returned 0.
[   21.913369] initcall 0xffffffff80ece2ed ran for 3 msecs: ns83820_init+0x0/0x4e()
[   21.921370] Calling initcall 0xffffffff80ece33b: fealnx_init+0x0/0x42()
[   21.933370] initcall 0xffffffff80ece33b: fealnx_init+0x0/0x42() returned 0.
[   21.945371] initcall 0xffffffff80ece33b ran for 0 msecs: fealnx_init+0x0/0x42()
[   21.953372] Calling initcall 0xffffffff80ece37d: tg3_init+0x0/0x42()
[   21.961372] initcall 0xffffffff80ece37d: tg3_init+0x0/0x42() returned 0.
[   21.973373] initcall 0xffffffff80ece37d ran for 0 msecs: tg3_init+0x0/0x42()
[   21.981373] Calling initcall 0xffffffff80ece3bf: bnx2_init+0x0/0x42()
[   21.989374] initcall 0xffffffff80ece3bf: bnx2_init+0x0/0x42() returned 0.
[   22.001375] initcall 0xffffffff80ece3bf ran for 0 msecs: bnx2_init+0x0/0x42()
[   22.009375] Calling initcall 0xffffffff80ece401: skge_init+0x0/0x4e()
[   22.021376] sk98lin: driver has been replaced by the skge driver and is scheduled for removal
[   22.025376] initcall 0xffffffff80ece401: skge_init+0x0/0x4e() returned 0.
[   22.037377] initcall 0xffffffff80ece401 ran for 3 msecs: skge_init+0x0/0x4e()
[   22.045377] Calling initcall 0xffffffff80ece44f: rhine_init+0x0/0x94()
[   22.053378] initcall 0xffffffff80ece44f: rhine_init+0x0/0x94() returned 0.
[   22.065379] initcall 0xffffffff80ece44f ran for 0 msecs: rhine_init+0x0/0x94()
[   22.073379] Calling initcall 0xffffffff80ece4e3: sundance_init+0x0/0x42()
[   22.081380] initcall 0xffffffff80ece4e3: sundance_init+0x0/0x42() returned 0.
[   22.089380] initcall 0xffffffff80ece4e3 ran for 0 msecs: sundance_init+0x0/0x42()
[   22.097381] Calling initcall 0xffffffff80ece525: hamachi_init+0x0/0x4b()
[   22.105381] initcall 0xffffffff80ece525: hamachi_init+0x0/0x4b() returned 0.
[   22.117382] initcall 0xffffffff80ece525 ran for 0 msecs: hamachi_init+0x0/0x4b()
[   22.125382] Calling initcall 0xffffffff80ece5ed: net_olddevs_init+0x0/0xc9()
[   22.133383] initcall 0xffffffff80ece5ed: net_olddevs_init+0x0/0xc9() returned 0.
[   22.145384] initcall 0xffffffff80ece5ed ran for 0 msecs: net_olddevs_init+0x0/0xc9()
[   22.153384] Calling initcall 0xffffffff80ece791: sb1000_init+0x0/0x39()
[   22.165385] initcall 0xffffffff80ece791: sb1000_init+0x0/0x39() returned 0.
[   22.177386] initcall 0xffffffff80ece791 ran for 0 msecs: sb1000_init+0x0/0x39()
[   22.185386] Calling initcall 0xffffffff80ece7ca: init_nic+0x0/0x42()
[   22.193387] initcall 0xffffffff80ece7ca: init_nic+0x0/0x42() returned 0.
[   22.205387] initcall 0xffffffff80ece7ca ran for 0 msecs: init_nic+0x0/0x42()
[   22.213388] Calling initcall 0xffffffff80ece80c: ql3xxx_init_module+0x0/0x42()
[   22.221388] initcall 0xffffffff80ece80c: ql3xxx_init_module+0x0/0x42() returned 0.
[   22.233389] initcall 0xffffffff80ece80c ran for 0 msecs: ql3xxx_init_module+0x0/0x42()
[   22.241390] Calling initcall 0xffffffff80ece84e: dummy_init_module+0x0/0xf8()
[   22.249390] initcall 0xffffffff80ece84e: dummy_init_module+0x0/0xf8() returned 0.
[   22.261391] initcall 0xffffffff80ece84e ran for 0 msecs: dummy_init_module+0x0/0xf8()
[   22.269391] Calling initcall 0xffffffff80ece946: de600_init+0x0/0x3d1()
[   22.277392] eth%d: D-Link DE-600 pocket adapter: not at I/O 0x378.
[   22.285392] initcall 0xffffffff80ece946: de600_init+0x0/0x3d1() returned -19.
[   22.297393] initcall 0xffffffff80ece946 ran for 7 msecs: de600_init+0x0/0x3d1()
[   22.305394] Calling initcall 0xffffffff80eced17: rtl8139_init_module+0x0/0x42()
[   22.313394] initcall 0xffffffff80eced17: rtl8139_init_module+0x0/0x42() returned 0.
[   22.325395] initcall 0xffffffff80eced17 ran for 0 msecs: rtl8139_init_module+0x0/0x42()
[   22.333395] Calling initcall 0xffffffff80eced59: sc92031_init+0x0/0x4e()
[   22.341396] Silan SC92031 PCI Fast Ethernet Adapter driver 2.0c
[   22.345396] initcall 0xffffffff80eced59: sc92031_init+0x0/0x4e() returned 0.
[   22.357397] initcall 0xffffffff80eced59 ran for 3 msecs: sc92031_init+0x0/0x4e()
[   22.365397] Calling initcall 0xffffffff80eceda7: veth_init+0x0/0x45()
[   22.373398] initcall 0xffffffff80eceda7: veth_init+0x0/0x45() returned 0.
[   22.381398] initcall 0xffffffff80eceda7 ran for 0 msecs: veth_init+0x0/0x45()
[   22.389399] Calling initcall 0xffffffff80ecedec: rio_init+0x0/0x42()
[   22.401400] initcall 0xffffffff80ecedec: rio_init+0x0/0x42() returned 0.
[   22.413400] initcall 0xffffffff80ecedec ran for 0 msecs: rio_init+0x0/0x42()
[   22.421401] Calling initcall 0xffffffff80ecee2e: rtl8169_init_module+0x0/0x42()
[   22.429401] initcall 0xffffffff80ecee2e: rtl8169_init_module+0x0/0x42() returned 0.
[   22.441402] initcall 0xffffffff80ecee2e ran for 0 msecs: rtl8169_init_module+0x0/0x42()
[   22.449403] Calling initcall 0xffffffff80ecee70: amd8111e_init+0x0/0x42()
[   22.457403] initcall 0xffffffff80ecee70: amd8111e_init+0x0/0x42() returned 0.
[   22.469404] initcall 0xffffffff80ecee70 ran for 0 msecs: amd8111e_init+0x0/0x42()
[   22.477404] Calling initcall 0xffffffff80eceeb2: ipddp_init_module+0x0/0x16e()
[   22.485405] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[   22.489405] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[   22.493405] initcall 0xffffffff80eceeb2: ipddp_init_module+0x0/0x16e() returned 0.
[   22.505406] initcall 0xffffffff80eceeb2 ran for 7 msecs: ipddp_init_module+0x0/0x16e()
[   22.513407] Calling initcall 0xffffffff80ecf020: sync_ppp_init+0x0/0x8b()
[   22.521407] Cronyx Ltd, Synchronous PPP and CISCO HDLC (c) 1994
[   22.521407] Linux port (c) 1998 Building Number Three Ltd & Jan "Yenya" Kasprzak.
[   22.525407] initcall 0xffffffff80ecf020: sync_ppp_init+0x0/0x8b() returned 0.
[   22.537408] initcall 0xffffffff80ecf020 ran for 3 msecs: sync_ppp_init+0x0/0x8b()
[   22.545409] Calling initcall 0xffffffff80ecf0ab: init_lmc+0x0/0x45()
[   22.557409] initcall 0xffffffff80ecf0ab: init_lmc+0x0/0x45() returned 0.
[   22.569410] initcall 0xffffffff80ecf0ab ran for 0 msecs: init_lmc+0x0/0x45()
[   22.577411] Calling initcall 0xffffffff80ecf0f0: arcnet_init+0x0/0x86()
[   22.585411] arcnet loaded.
[   22.589411] initcall 0xffffffff80ecf0f0: arcnet_init+0x0/0x86() returned 0.
[   22.601412] initcall 0xffffffff80ecf0f0 ran for 3 msecs: arcnet_init+0x0/0x86()
[   22.609413] Calling initcall 0xffffffff80ecf176: arcnet_rfc1051_init+0x0/0x76()
[   22.617413] arcnet: RFC1051 "simple standard" (`s') encapsulation support loaded.
[   22.621413] initcall 0xffffffff80ecf176: arcnet_rfc1051_init+0x0/0x76() returned 0.
[   22.633414] initcall 0xffffffff80ecf176 ran for 3 msecs: arcnet_rfc1051_init+0x0/0x76()
[   22.641415] Calling initcall 0xffffffff80ecf1ec: arcnet_raw_init+0x0/0xa4()
[   22.649415] arcnet: raw mode (`r') encapsulation support loaded.
[   22.653415] initcall 0xffffffff80ecf1ec: arcnet_raw_init+0x0/0xa4() returned 0.
[   22.665416] initcall 0xffffffff80ecf1ec ran for 3 msecs: arcnet_raw_init+0x0/0xa4()
[   22.673417] Calling initcall 0xffffffff80ecf290: catc_init+0x0/0x65()
[   22.681417] usbcore: registered new interface driver catc
[   22.685417] drivers/net/usb/catc.c: v2.8 CATC EL1210A NetMate USB Ethernet driver
[   22.689418] initcall 0xffffffff80ecf290: catc_init+0x0/0x65() returned 0.
[   22.701418] initcall 0xffffffff80ecf290 ran for 7 msecs: catc_init+0x0/0x65()
[   22.709419] Calling initcall 0xffffffff80ecf2f5: kaweth_init+0x0/0x55()
[   22.717419] drivers/net/usb/kaweth.c: Driver loading
[   22.721420] usbcore: registered new interface driver kaweth
[   22.725420] initcall 0xffffffff80ecf2f5: kaweth_init+0x0/0x55() returned 0.
[   22.737421] initcall 0xffffffff80ecf2f5 ran for 7 msecs: kaweth_init+0x0/0x55()
[   22.745421] Calling initcall 0xffffffff80ecf34a: pegasus_init+0x0/0x1ec()
[   22.753422] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethernet driver
[   22.757422] usbcore: registered new interface driver pegasus
[   22.761422] initcall 0xffffffff80ecf34a: pegasus_init+0x0/0x1ec() returned 0.
[   22.773423] initcall 0xffffffff80ecf34a ran for 7 msecs: pegasus_init+0x0/0x1ec()
[   22.781423] Calling initcall 0xffffffff80ecf536: usb_rtl8150_init+0x0/0x55()
[   22.789424] drivers/net/usb/rtl8150.c: rtl8150 based usb-ethernet driver v0.6.2 (2004/08/27)
[   22.793424] usbcore: registered new interface driver rtl8150
[   22.797424] initcall 0xffffffff80ecf536: usb_rtl8150_init+0x0/0x55() returned 0.
[   22.805425] initcall 0xffffffff80ecf536 ran for 7 msecs: usb_rtl8150_init+0x0/0x55()
[   22.813425] Calling initcall 0xffffffff80ecf58b: dmfe_init_module+0x0/0x14c()
[   22.825426] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
[   22.829426] initcall 0xffffffff80ecf58b: dmfe_init_module+0x0/0x14c() returned 0.
[   22.841427] initcall 0xffffffff80ecf58b ran for 3 msecs: dmfe_init_module+0x0/0x14c()
[   22.849428] Calling initcall 0xffffffff80ecf6d7: de_init+0x0/0x42()
[   22.857428] initcall 0xffffffff80ecf6d7: de_init+0x0/0x42() returned 0.
[   22.869429] initcall 0xffffffff80ecf6d7 ran for 0 msecs: de_init+0x0/0x42()
[   22.877429] Calling initcall 0xffffffff80ecf719: tulip_init+0x0/0x5a()
[   22.885430] initcall 0xffffffff80ecf719: tulip_init+0x0/0x5a() returned 0.
[   22.897431] initcall 0xffffffff80ecf719 ran for 0 msecs: tulip_init+0x0/0x5a()
[   22.905431] Calling initcall 0xffffffff80ecf773: de4x5_module_init+0x0/0x42()
[   22.913432] initcall 0xffffffff80ecf773: de4x5_module_init+0x0/0x42() returned 0.
[   22.925432] initcall 0xffffffff80ecf773 ran for 0 msecs: de4x5_module_init+0x0/0x42()
[   22.933433] Calling initcall 0xffffffff80ecf7b5: uli526x_init_module+0x0/0xdb()
[   22.941433] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
[   22.945434] initcall 0xffffffff80ecf7b5: uli526x_init_module+0x0/0xdb() returned 0.
[   22.957434] initcall 0xffffffff80ecf7b5 ran for 3 msecs: uli526x_init_module+0x0/0xdb()
[   22.965435] Calling initcall 0xffffffff80ecf890: mkiss_init_driver+0x0/0x65()
[   22.973435] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[   22.977436] initcall 0xffffffff80ecf890: mkiss_init_driver+0x0/0x65() returned 0.
[   22.989436] initcall 0xffffffff80ecf890 ran for 3 msecs: mkiss_init_driver+0x0/0x65()
[   22.997437] Calling initcall 0xffffffff80ecf989: init_baycomserfdx+0x0/0x137()
[   23.005437] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   23.005437] baycom_ser_fdx: version 0.10 compiled 09:36:08 Apr 18 2008
[   23.009438] initcall 0xffffffff80ecf989: init_baycomserfdx+0x0/0x137() returned 0.
[   23.021438] initcall 0xffffffff80ecf989 ran for 3 msecs: init_baycomserfdx+0x0/0x137()
[   23.029439] Calling initcall 0xffffffff80ecfac0: hdlcdrv_init_driver+0x0/0x4a()
[   23.037439] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[   23.041440] hdlcdrv: version 0.8 compiled 09:36:08 Apr 18 2008
[   23.045440] initcall 0xffffffff80ecfac0: hdlcdrv_init_driver+0x0/0x4a() returned 0.
[   23.053440] initcall 0xffffffff80ecfac0 ran for 7 msecs: hdlcdrv_init_driver+0x0/0x4a()
[   23.061441] Calling initcall 0xffffffff80ecfb8c: init_baycomserhdx+0x0/0x11b()
[   23.069441] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   23.069441] baycom_ser_hdx: version 0.10 compiled 09:36:09 Apr 18 2008
[   23.073442] initcall 0xffffffff80ecfb8c: init_baycomserhdx+0x0/0x11b() returned 0.
[   23.085442] initcall 0xffffffff80ecfb8c ran for 3 msecs: init_baycomserhdx+0x0/0x11b()
[   23.093443] Calling initcall 0xffffffff80ecfd22: init_baycompar+0x0/0x10e()
[   23.101443] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   23.101443] baycom_par: version 0.9 compiled 09:36:09 Apr 18 2008
[   23.105444] initcall 0xffffffff80ecfd22: init_baycompar+0x0/0x10e() returned 0.
[   23.117444] initcall 0xffffffff80ecfd22 ran for 3 msecs: init_baycompar+0x0/0x10e()
[   23.125445] Calling initcall 0xffffffff80ecfe30: usb_irda_init+0x0/0x62()
[   23.133445] usbcore: registered new interface driver irda-usb
[   23.137446] USB IrDA support registered
[   23.141446] initcall 0xffffffff80ecfe30: usb_irda_init+0x0/0x62() returned 0.
[   23.153447] initcall 0xffffffff80ecfe30 ran for 7 msecs: usb_irda_init+0x0/0x62()
[   23.161447] Calling initcall 0xffffffff80ecfe92: stir_init+0x0/0x4e()
[   23.169448] usbcore: registered new interface driver stir4200
[   23.173448] initcall 0xffffffff80ecfe92: stir_init+0x0/0x4e() returned 0.
[   23.185449] initcall 0xffffffff80ecfe92 ran for 3 msecs: stir_init+0x0/0x4e()
[   23.193449] Calling initcall 0xffffffff80ecfee0: w83977af_init+0x0/0x5c0()
[   23.201450] w83977af_init()
[   23.205450] w83977af_open()
[   23.209450] w83977af_probe()
[   23.213450] w83977af_probe(), Wrong chip version<7>w83977af_probe()
[   23.221451] w83977af_probe(), Wrong chip versioninitcall 0xffffffff80ecfee0: w83977af_init+0x0/0x5c0() returned -19.
[   23.237452] initcall 0xffffffff80ecfee0 ran for 22 msecs: w83977af_init+0x0/0x5c0()
[   23.245452] Calling initcall 0xffffffff80ed13ee: smsc_ircc_init+0x0/0x6cb()
[   23.253453] initcall 0xffffffff80ed13ee: smsc_ircc_init+0x0/0x6cb() returned -19.
[   23.265454] initcall 0xffffffff80ed13ee ran for 0 msecs: smsc_ircc_init+0x0/0x6cb()
[   23.273454] Calling initcall 0xffffffff80ed1f90: vlsi_mod_init+0x0/0x160()
[   23.281455] initcall 0xffffffff80ed1f90: vlsi_mod_init+0x0/0x160() returned 0.
[   23.293455] initcall 0xffffffff80ed1f90 ran for 0 msecs: vlsi_mod_init+0x0/0x160()
[   23.301456] Calling initcall 0xffffffff80ed20f0: via_ircc_init+0x0/0x90()
[   23.309456] initcall 0xffffffff80ed20f0: via_ircc_init+0x0/0x90() returned 0.
[   23.321457] initcall 0xffffffff80ed20f0 ran for 0 msecs: via_ircc_init+0x0/0x90()
[   23.329458] Calling initcall 0xffffffff80ed2180: irtty_sir_init+0x0/0x64()
[   23.337458] initcall 0xffffffff80ed2180: irtty_sir_init+0x0/0x64() returned 0.
[   23.349459] initcall 0xffffffff80ed2180 ran for 0 msecs: irtty_sir_init+0x0/0x64()
[   23.357459] Calling initcall 0xffffffff80ed21e4: sir_wq_init+0x0/0x56()
[   23.365460] initcall 0xffffffff80ed21e4: sir_wq_init+0x0/0x56() returned 0.
[   23.377461] initcall 0xffffffff80ed21e4 ran for 0 msecs: sir_wq_init+0x0/0x56()
[   23.385461] Calling initcall 0xffffffff80ed223a: esi_sir_init+0x0/0x39()
[   23.393462] irda_register_dongle : registering dongle "JetEye PC ESI-9680 PC" (1).
[   23.397462] initcall 0xffffffff80ed223a: esi_sir_init+0x0/0x39() returned 0.
[   23.409463] initcall 0xffffffff80ed223a ran for 3 msecs: esi_sir_init+0x0/0x39()
[   23.417463] Calling initcall 0xffffffff80ed2273: tekram_sir_init+0x0/0x78()
[   23.425464] irda_register_dongle : registering dongle "Tekram IR-210B" (0).
[   23.429464] initcall 0xffffffff80ed2273: tekram_sir_init+0x0/0x78() returned 0.
[   23.441465] initcall 0xffffffff80ed2273 ran for 3 msecs: tekram_sir_init+0x0/0x78()
[   23.449465] Calling initcall 0xffffffff80ed22eb: actisys_sir_init+0x0/0x66()
[   23.457466] irda_register_dongle : registering dongle "Actisys ACT-220L" (2).
[   23.461466] irda_register_dongle : registering dongle "Actisys ACT-220L+" (3).
[   23.465466] initcall 0xffffffff80ed22eb: actisys_sir_init+0x0/0x66() returned 0.
[   23.477467] initcall 0xffffffff80ed22eb ran for 7 msecs: actisys_sir_init+0x0/0x66()
[   23.485467] Calling initcall 0xffffffff80ed2351: old_belkin_sir_init+0x0/0x39()
[   23.493468] irda_register_dongle : registering dongle "Old Belkin SmartBeam" (7).
[   23.497468] initcall 0xffffffff80ed2351: old_belkin_sir_init+0x0/0x39() returned 0.
[   23.509469] initcall 0xffffffff80ed2351 ran for 3 msecs: old_belkin_sir_init+0x0/0x39()
[   23.517469] Calling initcall 0xffffffff80ed238a: act200l_sir_init+0x0/0x39()
[   23.525470] irda_register_dongle : registering dongle "ACTiSYS ACT-IR200L" (10).
[   23.529470] initcall 0xffffffff80ed238a: act200l_sir_init+0x0/0x39() returned 0.
[   23.541471] initcall 0xffffffff80ed238a ran for 3 msecs: act200l_sir_init+0x0/0x39()
[   23.549471] Calling initcall 0xffffffff80ed23c3: ma600_sir_init+0x0/0x55()
[   23.557472] irda_register_dongle : registering dongle "MA600" (11).
[   23.561472] initcall 0xffffffff80ed23c3: ma600_sir_init+0x0/0x55() returned 0.
[   23.573473] initcall 0xffffffff80ed23c3 ran for 3 msecs: ma600_sir_init+0x0/0x55()
[   23.581473] Calling initcall 0xffffffff80ed2418: toim3232_sir_init+0x0/0x78()
[   23.589474] irda_register_dongle : registering dongle "Vishay TOIM3232" (12).
[   23.593474] initcall 0xffffffff80ed2418: toim3232_sir_init+0x0/0x78() returned 0.
[   23.605475] initcall 0xffffffff80ed2418 ran for 3 msecs: toim3232_sir_init+0x0/0x78()
[   23.613475] Calling initcall 0xffffffff80ed2490: kingsun_init+0x0/0x50()
[   23.621476] usbcore: registered new interface driver kingsun-sir
[   23.625476] initcall 0xffffffff80ed2490: kingsun_init+0x0/0x50() returned 0.
[   23.637477] initcall 0xffffffff80ed2490 ran for 3 msecs: kingsun_init+0x0/0x50()
[   23.645477] Calling initcall 0xffffffff80ed2527: init_netconsole+0x0/0x28a()
[   23.653478] console [netcon0] enabled
[   23.657478] netconsole: network logging started
[   23.661478] initcall 0xffffffff80ed2527: init_netconsole+0x0/0x28a() returned 0.
[   23.673479] initcall 0xffffffff80ed2527 ran for 7 msecs: init_netconsole+0x0/0x28a()
[   23.681480] Calling initcall 0xffffffff80ed27b1: init+0x0/0x39()
[   23.689480] initcall 0xffffffff80ed27b1: init+0x0/0x39() returned 0.
[   23.701481] initcall 0xffffffff80ed27b1 ran for 0 msecs: init+0x0/0x39()
[   23.709481] Calling initcall 0xffffffff80ed28d0: zatm_init_module+0x0/0x42()
[   23.717482] initcall 0xffffffff80ed28d0: zatm_init_module+0x0/0x42() returned 0.
[   23.729483] initcall 0xffffffff80ed28d0 ran for 0 msecs: zatm_init_module+0x0/0x42()
[   23.737483] Calling initcall 0xffffffff80ed2912: uPD98402_module_init+0x0/0x2e()
[   23.745484] initcall 0xffffffff80ed2912: uPD98402_module_init+0x0/0x2e() returned 0.
[   23.757484] initcall 0xffffffff80ed2912 ran for 0 msecs: uPD98402_module_init+0x0/0x2e()
[   23.765485] Calling initcall 0xffffffff80ed2a63: fore200e_module_init+0x0/0x14f()
[   23.773485] fore200e: FORE Systems 200E-series ATM driver - version 0.3e
[   23.777486] initcall 0xffffffff80ed2a63: fore200e_module_init+0x0/0x14f() returned 0.
[   23.789486] initcall 0xffffffff80ed2a63 ran for 3 msecs: fore200e_module_init+0x0/0x14f()
[   23.797487] Calling initcall 0xffffffff80ed2bb2: firestream_init_module+0x0/0x4e()
[   23.805487] initcall 0xffffffff80ed2bb2: firestream_init_module+0x0/0x4e() returned 0.
[   23.817488] initcall 0xffffffff80ed2bb2 ran for 0 msecs: firestream_init_module+0x0/0x4e()
[   23.825489] Calling initcall 0xffffffff80ed2c00: lanai_module_init+0x0/0x60()
[   23.833489] initcall 0xffffffff80ed2c00: lanai_module_init+0x0/0x60() returned 0.
[   23.845490] initcall 0xffffffff80ed2c00 ran for 0 msecs: lanai_module_init+0x0/0x60()
[   23.853490] Calling initcall 0xffffffff80ed303c: scsi_tgt_init+0x0/0xa1()
[   23.861491] initcall 0xffffffff80ed303c: scsi_tgt_init+0x0/0xa1() returned 0.
[   23.873492] initcall 0xffffffff80ed303c ran for 0 msecs: scsi_tgt_init+0x0/0xa1()
[   23.881492] Calling initcall 0xffffffff80ed30dd: raid_init+0x0/0x43()
[   23.889493] initcall 0xffffffff80ed30dd: raid_init+0x0/0x43() returned 0.
[   23.901493] initcall 0xffffffff80ed30dd ran for 0 msecs: raid_init+0x0/0x43()
[   23.909494] Calling initcall 0xffffffff80ed3120: spi_transport_init+0x0/0x70()
[   23.917494] initcall 0xffffffff80ed3120: spi_transport_init+0x0/0x70() returned 0.
[   23.929495] initcall 0xffffffff80ed3120 ran for 0 msecs: spi_transport_init+0x0/0x70()
[   23.937496] Calling initcall 0xffffffff80ed3190: fc_transport_init+0x0/0x90()
[   23.945496] initcall 0xffffffff80ed3190: fc_transport_init+0x0/0x90() returned 0.
[   23.957497] initcall 0xffffffff80ed3190 ran for 0 msecs: fc_transport_init+0x0/0x90()
[   23.965497] Calling initcall 0xffffffff80ed3220: iscsi_transport_init+0x0/0x145()
[   23.973498] Loading iSCSI transport class v2.0-869.
[   23.977498] initcall 0xffffffff80ed3220: iscsi_transport_init+0x0/0x145() returned 0.
[   23.989499] initcall 0xffffffff80ed3220 ran for 3 msecs: iscsi_transport_init+0x0/0x145()
[   23.997499] Calling initcall 0xffffffff80ed3365: sas_transport_init+0x0/0xe6()
[   24.005500] initcall 0xffffffff80ed3365: sas_transport_init+0x0/0xe6() returned 0.
[   24.017501] initcall 0xffffffff80ed3365 ran for 0 msecs: sas_transport_init+0x0/0xe6()
[   24.025501] Calling initcall 0xffffffff80ed344b: sas_class_init+0x0/0x65()
[   24.033502] initcall 0xffffffff80ed344b: sas_class_init+0x0/0x65() returned 0.
[   24.045502] initcall 0xffffffff80ed344b ran for 0 msecs: sas_class_init+0x0/0x65()
[   24.053503] Calling initcall 0xffffffff80738287: arcmsr_module_init+0x0/0x42()
[   24.061503] initcall 0xffffffff80738287: arcmsr_module_init+0x0/0x42() returned 0.
[   24.073504] initcall 0xffffffff80738287 ran for 0 msecs: arcmsr_module_init+0x0/0x42()
[   24.081505] Calling initcall 0xffffffff80ed34b0: ahc_linux_init+0x0/0x85()
[   24.093505] initcall 0xffffffff80ed34b0: ahc_linux_init+0x0/0x85() returned 0.
[   24.105506] initcall 0xffffffff80ed34b0 ran for 0 msecs: ahc_linux_init+0x0/0x85()
[   24.113507] Calling initcall 0xffffffff80ed3535: aac_init+0x0/0x92()
[   24.121507] Adaptec aacraid driver 1.1-5[2455]-ms
[   24.125507] initcall 0xffffffff80ed3535: aac_init+0x0/0x92() returned 0.
[   24.137508] initcall 0xffffffff80ed3535 ran for 3 msecs: aac_init+0x0/0x92()
[   24.145509] Calling initcall 0xffffffff80ed35c7: init_this_scsi_driver+0x0/0x129()
[   24.153509] initcall 0xffffffff80ed35c7: init_this_scsi_driver+0x0/0x129() returned -19.
[   24.165510] initcall 0xffffffff80ed35c7 ran for 0 msecs: init_this_scsi_driver+0x0/0x129()
[   24.173510] Calling initcall 0xffffffff80ed36f0: ips_module_init+0x0/0x220()
[   24.185511] initcall 0xffffffff80ed36f0: ips_module_init+0x0/0x220() returned -19.
[   24.197512] initcall 0xffffffff80ed36f0 ran for 0 msecs: ips_module_init+0x0/0x220()
[   24.205512] Calling initcall 0xffffffff80ed3b1c: qla1280_init+0x0/0x42()
[   24.213513] initcall 0xffffffff80ed3b1c: qla1280_init+0x0/0x42() returned 0.
[   24.221513] initcall 0xffffffff80ed3b1c ran for 0 msecs: qla1280_init+0x0/0x42()
[   24.229514] Calling initcall 0xffffffff80ed3b5e: qla4xxx_module_init+0x0/0x13b()
[   24.241515] iscsi: registered transport (qla4xxx)
[   24.245515] QLogic iSCSI HBA Driver
[   24.249515] initcall 0xffffffff80ed3b5e: qla4xxx_module_init+0x0/0x13b() returned 0.
[   24.261516] initcall 0xffffffff80ed3b5e ran for 7 msecs: qla4xxx_module_init+0x0/0x13b()
[   24.269516] Calling initcall 0xffffffff80ed3c99: lpfc_init+0x0/0xee()
[   24.277517] Emulex LightPulse Fibre Channel SCSI driver 8.2.5
[   24.281517] Copyright(c) 2004-2008 Emulex.  All rights reserved.
[   24.285517] initcall 0xffffffff80ed3c99: lpfc_init+0x0/0xee() returned 0.
[   24.297518] initcall 0xffffffff80ed3c99 ran for 7 msecs: lpfc_init+0x0/0xee()
[   24.305519] Calling initcall 0xffffffff80ed3d87: init_this_scsi_driver+0x0/0x11a()
[   24.313519] initcall 0xffffffff80ed3d87: init_this_scsi_driver+0x0/0x11a() returned -19.
[   24.325520] initcall 0xffffffff80ed3d87 ran for 0 msecs: init_this_scsi_driver+0x0/0x11a()
[   24.333520] Calling initcall 0xffffffff80ed3ea1: dc390_module_init+0x0/0xbb()
[   24.341521] DC390: clustering now enabled by default. If you get problems load
[   24.341521]  with "disable_clustering=1" and report to maintainers
[   24.345521] initcall 0xffffffff80ed3ea1: dc390_module_init+0x0/0xbb() returned 0.
[   24.357522] initcall 0xffffffff80ed3ea1 ran for 3 msecs: dc390_module_init+0x0/0xbb()
[   24.365522] Calling initcall 0xffffffff80ed3fe0: megaraid_init+0x0/0x100()
[   24.373523] initcall 0xffffffff80ed3fe0: megaraid_init+0x0/0x100() returned 0.
[   24.385524] initcall 0xffffffff80ed3fe0 ran for 0 msecs: megaraid_init+0x0/0x100()
[   24.393524] Calling initcall 0xffffffff80ed5289: gdth_init+0x0/0x1119()
[   24.401525] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[   24.405525] GDT-HA: Found 0 PCI Storage RAID Controllers
[   24.409525] initcall 0xffffffff80ed5289: gdth_init+0x0/0x1119() returned -19.
[   24.421526] initcall 0xffffffff80ed5289 ran for 7 msecs: gdth_init+0x0/0x1119()
[   24.429526] Calling initcall 0xffffffff80ed63a2: twa_init+0x0/0x55()
[   24.437527] 3ware 9000 Storage Controller device driver for Linux v2.26.02.010.
[   24.441527] initcall 0xffffffff80ed63a2: twa_init+0x0/0x55() returned 0.
[   24.453528] initcall 0xffffffff80ed63a2 ran for 3 msecs: twa_init+0x0/0x55()
[   24.461528] Calling initcall 0xffffffff80ed63f7: ppa_driver_init+0x0/0x4c()
[   24.469529] ppa: Version 2.07 (for Linux 2.4.x)
[   24.473529] initcall 0xffffffff80ed63f7: ppa_driver_init+0x0/0x4c() returned 0.
[   24.485530] initcall 0xffffffff80ed63f7 ran for 3 msecs: ppa_driver_init+0x0/0x4c()
[   24.493530] Calling initcall 0xffffffff80ed6443: stex_init+0x0/0x5d()
[   24.505531] stex: Promise SuperTrak EX Driver version: 3.6.0000.1
[   24.509531] initcall 0xffffffff80ed6443: stex_init+0x0/0x5d() returned 0.
[   24.521532] initcall 0xffffffff80ed6443 ran for 3 msecs: stex_init+0x0/0x5d()
[   24.529533] Calling initcall 0xffffffff80ed6601: init_st+0x0/0x1c6()
[   24.537533] st: Version 20080221, fixed bufsize 32768, s/g segs 256
[   24.541533] Driver 'st' needs updating - please use bus_type methods
[   24.545534] initcall 0xffffffff80ed6601: init_st+0x0/0x1c6() returned 0.
[   24.557534] initcall 0xffffffff80ed6601 ran for 7 msecs: init_st+0x0/0x1c6()
[   24.565535] Calling initcall 0xffffffff80ed67c7: init_sd+0x0/0xe7()
[   24.573535] Driver 'sd' needs updating - please use bus_type methods
[   24.577536] initcall 0xffffffff80ed67c7: init_sd+0x0/0xe7() returned 0.
[   24.589536] initcall 0xffffffff80ed67c7 ran for 3 msecs: init_sd+0x0/0xe7()
[   24.597537] Calling initcall 0xffffffff80ed68ae: init_sg+0x0/0x192()
[   24.605537] initcall 0xffffffff80ed68ae: init_sg+0x0/0x192() returned 0.
[   24.617538] initcall 0xffffffff80ed68ae ran for 0 msecs: init_sg+0x0/0x192()
[   24.625539] Calling initcall 0xffffffff80ed6e37: ahci_init+0x0/0x42()
[   24.633539] ahci 0000:00:1f.2: version 3.0
[   24.637539] PCI: Found IRQ 10 for device 0000:00:1f.2
[   24.641540] PCI: Sharing IRQ 10 with 0000:00:1d.1
[   24.645540] PCI: Sharing IRQ 10 with 0000:00:1f.3
[   24.649540] PCI: Sharing IRQ 10 with 0000:04:00.1
[   25.657603] ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
[   25.661603] ahci 0000:00:1f.2: flags: 64bit ncq pm led pmp slum part
[   25.665604] PCI: Setting latency timer of device 0000:00:1f.2 to 64
[   25.669604] scsi0 : ahci
[   25.673604] scsi1 : ahci
[   25.677604] scsi2 : ahci
[   25.681605] scsi3 : ahci
[   25.685605] scsi4 : ahci
[   25.689605] scsi5 : ahci
[   25.693605] ata1: SATA max UDMA/133 abar m1024@0xd8e00400 port 0xd8e00500 irq 10
[   25.697606] ata2: SATA max UDMA/133 abar m1024@0xd8e00400 port 0xd8e00580 irq 10
[   25.701606] ata3: SATA max UDMA/133 abar m1024@0xd8e00400 port 0xd8e00600 irq 10
[   25.705606] ata4: SATA max UDMA/133 abar m1024@0xd8e00400 port 0xd8e00680 irq 10
[   25.709606] ata5: SATA max UDMA/133 abar m1024@0xd8e00400 port 0xd8e00700 irq 10
[   25.713607] ata6: SATA max UDMA/133 abar m1024@0xd8e00400 port 0xd8e00780 irq 10
[   27.365710] ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[   27.385711] ata1.00: ATA-7: HDT722525DLA380, V44OA9BA, max UDMA/133
[   27.389711] ata1.00: 488397168 sectors, multi 0: LBA48 NCQ (depth 31/32)
[   27.397712] ata1.00: configured for UDMA/133
[   29.049815] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[   29.073817] ata2.00: ATA-7: HDT722525DLA380, V44OA9BA, max UDMA/133
[   29.077817] ata2.00: 488397168 sectors, multi 0: LBA48 NCQ (depth 31/32)
[   29.081817] ata2.00: configured for UDMA/133
[   29.405837] ata3: SATA link down (SStatus 0 SControl 300)
[   29.729858] ata4: SATA link down (SStatus 0 SControl 300)
[   30.053878] ata5: SATA link down (SStatus 0 SControl 300)
[   30.377898] ata6: SATA link down (SStatus 0 SControl 300)
[   30.381898] scsi 0:0:0:0: Direct-Access     ATA      HDT722525DLA380  V44O PQ: 0 ANSI: 5
[   30.385899] sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors (250059 MB)
[   30.389899] sd 0:0:0:0: [sda] Write Protect is off
[   30.393899] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   30.397899] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[   30.401900] sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors (250059 MB)
[   30.405900] sd 0:0:0:0: [sda] Write Protect is off
[   30.409900] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   30.413900] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[   30.417901]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 sda8 >
[   30.497906] sd 0:0:0:0: [sda] Attached SCSI disk
[   30.501906] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   30.505906] scsi 1:0:0:0: Direct-Access     ATA      HDT722525DLA380  V44O PQ: 0 ANSI: 5
[   30.509906] sd 1:0:0:0: [sdb] 488397168 512-byte hardware sectors (250059 MB)
[   30.513907] sd 1:0:0:0: [sdb] Write Protect is off
[   30.517907] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[   30.521907] sd 1:0:0:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[   30.525907] sd 1:0:0:0: [sdb] 488397168 512-byte hardware sectors (250059 MB)
[   30.529908] sd 1:0:0:0: [sdb] Write Protect is off
[   30.533908] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[   30.537908] sd 1:0:0:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[   30.541908]  sdb: sdb1
[   30.557909] sd 1:0:0:0: [sdb] Attached SCSI disk
[   30.561910] sd 1:0:0:0: Attached scsi generic sg1 type 0
[   30.565910] initcall 0xffffffff80ed6e37: ahci_init+0x0/0x42() returned 0.
[   30.573910] initcall 0xffffffff80ed6e37 ran for 5657 msecs: ahci_init+0x0/0x42()
[   30.581911] Calling initcall 0xffffffff80ed6e79: k2_sata_init+0x0/0x42()
[   30.589911] initcall 0xffffffff80ed6e79: k2_sata_init+0x0/0x42() returned 0.
[   30.601912] initcall 0xffffffff80ed6e79 ran for 0 msecs: k2_sata_init+0x0/0x42()
[   30.609913] Calling initcall 0xffffffff80ed6ebb: piix_init+0x0/0x54()
[   30.617913] initcall 0xffffffff80ed6ebb: piix_init+0x0/0x54() returned 0.
[   30.629914] initcall 0xffffffff80ed6ebb ran for 0 msecs: piix_init+0x0/0x54()
[   30.637914] Calling initcall 0xffffffff80ed6f0f: vsc_sata_init+0x0/0x42()
[   30.645915] initcall 0xffffffff80ed6f0f: vsc_sata_init+0x0/0x42() returned 0.
[   30.657916] initcall 0xffffffff80ed6f0f ran for 0 msecs: vsc_sata_init+0x0/0x42()
[   30.665916] Calling initcall 0xffffffff80ed6f51: pdc_sata_init+0x0/0x42()
[   30.673917] initcall 0xffffffff80ed6f51: pdc_sata_init+0x0/0x42() returned 0.
[   30.685917] initcall 0xffffffff80ed6f51 ran for 0 msecs: pdc_sata_init+0x0/0x42()
[   30.693918] Calling initcall 0xffffffff80ed6f93: uli_init+0x0/0x42()
[   30.701918] initcall 0xffffffff80ed6f93: uli_init+0x0/0x42() returned 0.
[   30.713919] initcall 0xffffffff80ed6f93 ran for 0 msecs: uli_init+0x0/0x42()
[   30.721920] Calling initcall 0xffffffff80ed6fd5: mv_init+0x0/0x6d()
[   30.729920] initcall 0xffffffff80ed6fd5: mv_init+0x0/0x6d() returned 0.
[   30.741921] initcall 0xffffffff80ed6fd5 ran for 0 msecs: mv_init+0x0/0x6d()
[   30.749921] Calling initcall 0xffffffff80ed7042: ali_init+0x0/0x42()
[   30.757922] initcall 0xffffffff80ed7042: ali_init+0x0/0x42() returned 0.
[   30.769923] initcall 0xffffffff80ed7042 ran for 0 msecs: ali_init+0x0/0x42()
[   30.777923] Calling initcall 0xffffffff80ed7084: amd_init+0x0/0x42()
[   30.785924] initcall 0xffffffff80ed7084: amd_init+0x0/0x42() returned 0.
[   30.793924] initcall 0xffffffff80ed7084 ran for 0 msecs: amd_init+0x0/0x42()
[   30.801925] Calling initcall 0xffffffff80ed70c6: artop_init+0x0/0x42()
[   30.809925] initcall 0xffffffff80ed70c6: artop_init+0x0/0x42() returned 0.
[   30.821926] initcall 0xffffffff80ed70c6 ran for 0 msecs: artop_init+0x0/0x42()
[   30.829926] Calling initcall 0xffffffff80ed7108: cmd64x_init+0x0/0x42()
[   30.837927] initcall 0xffffffff80ed7108: cmd64x_init+0x0/0x42() returned 0.
[   30.845927] initcall 0xffffffff80ed7108 ran for 0 msecs: cmd64x_init+0x0/0x42()
[   30.853928] Calling initcall 0xffffffff80ed714a: cy82c693_init+0x0/0x42()
[   30.861928] initcall 0xffffffff80ed714a: cy82c693_init+0x0/0x42() returned 0.
[   30.869929] initcall 0xffffffff80ed714a ran for 0 msecs: cy82c693_init+0x0/0x42()
[   30.877929] Calling initcall 0xffffffff80ed718c: hpt36x_init+0x0/0x42()
[   30.885930] initcall 0xffffffff80ed718c: hpt36x_init+0x0/0x42() returned 0.
[   30.897931] initcall 0xffffffff80ed718c ran for 0 msecs: hpt36x_init+0x0/0x42()
[   30.905931] Calling initcall 0xffffffff80ed71ce: hpt37x_init+0x0/0x42()
[   30.913932] initcall 0xffffffff80ed71ce: hpt37x_init+0x0/0x42() returned 0.
[   30.925932] initcall 0xffffffff80ed71ce ran for 0 msecs: hpt37x_init+0x0/0x42()
[   30.933933] Calling initcall 0xffffffff80ed7210: hpt3x3_init+0x0/0x42()
[   30.941933] initcall 0xffffffff80ed7210: hpt3x3_init+0x0/0x42() returned 0.
[   30.953934] initcall 0xffffffff80ed7210 ran for 0 msecs: hpt3x3_init+0x0/0x42()
[   30.961935] Calling initcall 0xffffffff80ed7252: it821x_init+0x0/0x42()
[   30.969935] initcall 0xffffffff80ed7252: it821x_init+0x0/0x42() returned 0.
[   30.981936] initcall 0xffffffff80ed7252 ran for 0 msecs: it821x_init+0x0/0x42()
[   30.989936] Calling initcall 0xffffffff80ed7294: netcell_init+0x0/0x42()
[   30.997937] initcall 0xffffffff80ed7294: netcell_init+0x0/0x42() returned 0.
[   31.009938] initcall 0xffffffff80ed7294 ran for 0 msecs: netcell_init+0x0/0x42()
[   31.017938] Calling initcall 0xffffffff80ed72d6: ninja32_init+0x0/0x42()
[   31.025939] initcall 0xffffffff80ed72d6: ninja32_init+0x0/0x42() returned 0.
[   31.037939] initcall 0xffffffff80ed72d6 ran for 0 msecs: ninja32_init+0x0/0x42()
[   31.045940] Calling initcall 0xffffffff80ed7318: ns87410_init+0x0/0x42()
[   31.053940] initcall 0xffffffff80ed7318: ns87410_init+0x0/0x42() returned 0.
[   31.065941] initcall 0xffffffff80ed7318 ran for 0 msecs: ns87410_init+0x0/0x42()
[   31.073942] Calling initcall 0xffffffff80ed735a: oldpiix_init+0x0/0x42()
[   31.085942] initcall 0xffffffff80ed735a: oldpiix_init+0x0/0x42() returned 0.
[   31.097943] initcall 0xffffffff80ed735a ran for 0 msecs: oldpiix_init+0x0/0x42()
[   31.105944] Calling initcall 0xffffffff80ed739c: pdc202xx_init+0x0/0x42()
[   31.117944] initcall 0xffffffff80ed739c: pdc202xx_init+0x0/0x42() returned 0.
[   31.129945] initcall 0xffffffff80ed739c ran for 0 msecs: pdc202xx_init+0x0/0x42()
[   31.137946] Calling initcall 0xffffffff80ed73de: rz1000_init+0x0/0x42()
[   31.149946] initcall 0xffffffff80ed73de: rz1000_init+0x0/0x42() returned 0.
[   31.161947] initcall 0xffffffff80ed73de ran for 0 msecs: rz1000_init+0x0/0x42()
[   31.169948] Calling initcall 0xffffffff80ed7420: sil680_init+0x0/0x42()
[   31.177948] initcall 0xffffffff80ed7420: sil680_init+0x0/0x42() returned 0.
[   31.185949] initcall 0xffffffff80ed7420 ran for 0 msecs: sil680_init+0x0/0x42()
[   31.193949] Calling initcall 0xffffffff80ed7462: via_init+0x0/0x42()
[   31.201950] initcall 0xffffffff80ed7462: via_init+0x0/0x42() returned 0.
[   31.213950] initcall 0xffffffff80ed7462 ran for 0 msecs: via_init+0x0/0x42()
[   31.221951] Calling initcall 0xffffffff80ed74a4: sis_init+0x0/0x42()
[   31.229951] initcall 0xffffffff80ed74a4: sis_init+0x0/0x42() returned 0.
[   31.241952] initcall 0xffffffff80ed74a4 ran for 0 msecs: sis_init+0x0/0x42()
[   31.249953] Calling initcall 0xffffffff80ed74e6: triflex_init+0x0/0x42()
[   31.257953] initcall 0xffffffff80ed74e6: triflex_init+0x0/0x42() returned 0.
[   31.269954] initcall 0xffffffff80ed74e6 ran for 0 msecs: triflex_init+0x0/0x42()
[   31.277954] Calling initcall 0xffffffff80ed7528: pacpi_init+0x0/0x48()
[   31.285955] initcall 0xffffffff80ed7528: pacpi_init+0x0/0x48() returned 0.
[   31.297956] initcall 0xffffffff80ed7528 ran for 0 msecs: pacpi_init+0x0/0x48()
[   31.305956] Calling initcall 0xffffffff80ed7570: ks0108_init+0x0/0xe2()
[   31.313957] ks0108: ERROR: parport didn't find 888 port
[   31.317957] initcall 0xffffffff80ed7570: ks0108_init+0x0/0xe2() returned -22.
[   31.329958] initcall 0xffffffff80ed7570 ran for 3 msecs: ks0108_init+0x0/0xe2()
[   31.337958] initcall at 0xffffffff80ed7570: ks0108_init+0x0/0xe2(): returned with error code -22
[   31.349959] Calling initcall 0xffffffff80ed7652: cfag12864b_init+0x0/0x17e()
[   31.357959] cfag12864b: ERROR: ks0108 is not initialized
[   31.361960] initcall 0xffffffff80ed7652: cfag12864b_init+0x0/0x17e() returned -22.
[   31.373960] initcall 0xffffffff80ed7652 ran for 3 msecs: cfag12864b_init+0x0/0x17e()
[   31.381961] initcall at 0xffffffff80ed7652: cfag12864b_init+0x0/0x17e(): returned with error code -22
[   31.393962] Calling initcall 0xffffffff80ed77d0: cfag12864bfb_init+0x0/0xcc()
[   31.401962] cfag12864bfb: ERROR: cfag12864b is not initialized
[   31.405962] initcall 0xffffffff80ed77d0: cfag12864bfb_init+0x0/0xcc() returned -22.
[   31.417963] initcall 0xffffffff80ed77d0 ran for 3 msecs: cfag12864bfb_init+0x0/0xcc()
[   31.425964] initcall at 0xffffffff80ed77d0: cfag12864bfb_init+0x0/0xcc(): returned with error code -22
[   31.437964] Calling initcall 0xffffffff80ed7c10: mon_init+0x0/0x135()
[   31.445965] initcall 0xffffffff80ed7c10: mon_init+0x0/0x135() returned 0.
[   31.457966] initcall 0xffffffff80ed7c10 ran for 0 msecs: mon_init+0x0/0x135()
[   31.465966] Calling initcall 0xffffffff80ed7ea0: ehci_hcd_init+0x0/0xae()
[   31.477967] ehci_hcd: block sizes: qh 160 qtd 96 itd 192 sitd 96
[   31.481967] PCI: setting IRQ 5 as level-triggered
[   31.485967] PCI: Found IRQ 5 for device 0000:00:1d.7
[   31.489968] PCI: Sharing IRQ 5 with 0000:00:1d.0
[   31.493968] PCI: Setting latency timer of device 0000:00:1d.7 to 64
[   31.501968] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[   31.505969] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[   31.509969] ehci_hcd 0000:00:1d.7: reset hcs_params 0x103206 dbg=1 cc=3 pcc=2 ordered !ppc ports=6
[   31.513969] ehci_hcd 0000:00:1d.7: reset hcc_params 6871 thresh 7 uframes 1024 64 bit addr
[   31.517969] ehci_hcd 0000:00:1d.7: reset command 080022 (park)=0 ithresh=8 Async period=1024 Reset HALT
[   31.525970] ehci_hcd 0000:00:1d.7: debug port 1
[   31.529970] PCI: cache line size of 32 is not supported by device 0000:00:1d.7
[   31.533970] ehci_hcd 0000:00:1d.7: supports USB remote wakeup
[   31.537971] ehci_hcd 0000:00:1d.7: irq 5, io mem 0xd8e00000
[   31.541971] ehci_hcd 0000:00:1d.7: reset command 080002 (park)=0 ithresh=8 period=1024 Reset HALT
[   31.549971] ehci_hcd 0000:00:1d.7: init command 010001 (park)=0 ithresh=1 period=1024 RUN
[   31.565972] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
[   31.569973] usb usb1: default language 0x0409
[   31.573973] usb usb1: uevent
[   31.577973] usb usb1: usb_probe_device
[   31.581973] usb usb1: configuration #1 chosen from 1 choice
[   31.585974] usb usb1: adding 1-0:1.0 (config #1, interface 0)
[   31.589974] usb 1-0:1.0: uevent
[   31.593974] hub 1-0:1.0: usb_probe_interface
[   31.597974] hub 1-0:1.0: usb_probe_interface - got id
[   31.601975] hub 1-0:1.0: USB hub found
[   31.605975] hub 1-0:1.0: 6 ports detected
[   31.609975] hub 1-0:1.0: standalone hub
[   31.613975] hub 1-0:1.0: no power switching (usb 1.0)
[   31.617976] hub 1-0:1.0: individual port over-current protection
[   31.621976] hub 1-0:1.0: Single TT
[   31.625976] hub 1-0:1.0: TT requires at most 8 FS bit times (666 ns)
[   31.629976] hub 1-0:1.0: power on to power good time: 20ms
[   31.633977] hub 1-0:1.0: local power source is good
[   31.637977] hub 1-0:1.0: trying to enable port power on non-switchable hub
[   31.745984] hub 1-0:1.0: state 7 ports 6 chg 0000 evt 0000
[   31.749984] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[   31.753984] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   31.757984] usb usb1: Product: EHCI Host Controller
[   31.761985] usb usb1: Manufacturer: Linux 2.6.25-x86-latest.git ehci_hcd
[   31.765985] usb usb1: SerialNumber: 0000:00:1d.7
[   31.769985] ehci_hcd 0000:00:1d.7: GetStatus port 6 status 001803 POWER sig=j CSC CONNECT
[   31.773985] hub 1-0:1.0: port 6, status 0501, change 0001, 480 Mb/s
[   31.777986] initcall 0xffffffff80ed7ea0: ehci_hcd_init+0x0/0xae() returned 0.
[   31.789986] initcall 0xffffffff80ed7ea0 ran for 286 msecs: ehci_hcd_init+0x0/0xae()
[   31.797987] Calling initcall 0xffffffff80ed7f4e: ohci_hcd_mod_init+0x0/0xee()
[   31.809988] ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
[   31.813988] ohci_hcd: block sizes: ed 80 td 96
[   31.817988] initcall 0xffffffff80ed7f4e: ohci_hcd_mod_init+0x0/0xee() returned 0.
[   31.829989] initcall 0xffffffff80ed7f4e ran for 7 msecs: ohci_hcd_mod_init+0x0/0xee()
[   31.837989] Calling initcall 0xffffffff80ed803c: uhci_hcd_init+0x0/0x114()
[   31.845990] USB Universal Host Controller Interface driver v3.0
[   31.849990] PCI: Found IRQ 5 for device 0000:00:1d.0
[   31.853990] PCI: Sharing IRQ 5 with 0000:00:1d.7
[   31.857991] PCI: Setting latency timer of device 0000:00:1d.0 to 64
[   31.861991] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[   31.865991] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[   31.869991] uhci_hcd 0000:00:1d.0: detected 2 ports
[   31.873992] uhci_hcd 0000:00:1d.0: uhci_check_and_reset_hc: cmd = 0x0000
[   31.877992] uhci_hcd 0000:00:1d.0: Performing full reset
[   31.881992] uhci_hcd 0000:00:1d.0: irq 5, io base 0x00001800
[   31.885992] usb usb2: default language 0x0409
[   31.889993] usb usb2: uevent
[   31.893993] usb usb2: usb_probe_device
[   31.897993] usb usb2: configuration #1 chosen from 1 choice
[   31.901993] usb usb2: adding 2-0:1.0 (config #1, interface 0)
[   31.905994] usb 2-0:1.0: uevent
[   31.909994] hub 2-0:1.0: usb_probe_interface
[   31.913994] hub 2-0:1.0: usb_probe_interface - got id
[   31.917994] hub 2-0:1.0: USB hub found
[   31.921995] hub 2-0:1.0: 2 ports detected
[   31.925995] hub 2-0:1.0: standalone hub
[   31.929995] hub 2-0:1.0: no power switching (usb 1.0)
[   31.933995] hub 2-0:1.0: individual port over-current protection
[   31.937996] hub 2-0:1.0: power on to power good time: 2ms
[   31.941996] hub 2-0:1.0: local power source is good
[   31.945996] hub 2-0:1.0: trying to enable port power on non-switchable hub
[   31.949996] hub 1-0:1.0: debounce: port 6: total 100ms stable 100ms status 0x501
[   32.010000] ehci_hcd 0000:00:1d.7: port 6 high speed
[   32.010000] ehci_hcd 0000:00:1d.7: GetStatus port 6 status 001005 POWER sig=se0 PE CONNECT
[   32.054003] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[   32.058003] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   32.062003] usb usb2: Product: UHCI Host Controller
[   32.066004] usb usb2: Manufacturer: Linux 2.6.25-x86-latest.git uhci_hcd
[   32.070004] usb usb2: SerialNumber: 0000:00:1d.0
[   32.074004] PCI: Found IRQ 10 for device 0000:00:1d.1
[   32.078004] PCI: Sharing IRQ 10 with 0000:00:1f.2
[   32.082005] PCI: Sharing IRQ 10 with 0000:00:1f.3
[   32.086005] PCI: Sharing IRQ 10 with 0000:04:00.1
[   32.090005] PCI: Setting latency timer of device 0000:00:1d.1 to 64
[   32.094005] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[   32.098006] usb 1-6: new high speed USB device using ehci_hcd and address 2
[   32.102006] nommu_map_single: overflow 1af757720+8Error: No response to keepalive - Terminating session

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
