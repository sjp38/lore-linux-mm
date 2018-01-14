Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CABF6B0038
	for <linux-mm@kvack.org>; Sun, 14 Jan 2018 06:54:36 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id b38so6358509otj.18
        for <linux-mm@kvack.org>; Sun, 14 Jan 2018 03:54:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y23si3533962otj.342.2018.01.14.03.54.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 14 Jan 2018 03:54:32 -0800 (PST)
Subject: Re: [mm 4.15-rc7] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201801112311.EHI90152.FLJMQOStVHFOFO@I-love.SAKURA.ne.jp>
	<20180111142148.GD1732@dhcp22.suse.cz>
	<201801120131.w0C1VJUN034283@www262.sakura.ne.jp>
	<CA+55aFx4pH4odYDfuGemm5TK-CS4E8pL_ipHCVzVBmsQkyWp1Q@mail.gmail.com>
	<201801122022.IDI35401.VOQOFOMLFSFtHJ@I-love.SAKURA.ne.jp>
In-Reply-To: <201801122022.IDI35401.VOQOFOMLFSFtHJ@I-love.SAKURA.ne.jp>
Message-Id: <201801142054.FAD95378.LVOOFQJOFtMFSH@I-love.SAKURA.ne.jp>
Date: Sun, 14 Jan 2018 20:54:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: x86@kernel.org, linux-fsdevel@vger.kernel.org, torvalds@linux-foundation.org, mhocko@kernel.org

This memory corruption bug occurs even on CONFIG_SMP=n CONFIG_PREEMPT_NONE=y
kernel. This bug highly depends on timing and thus too difficult to bisect.
This bug seems to exist at least since Linux 4.8 (judging from the traces, though
the cause might be different). None of debugging configuration gives me a clue.
So far only CONFIG_HIGHMEM=y CONFIG_DEBUG_PAGEALLOC=y kernel (with RAM enough to
use HighMem: zone) seems to hit this bug, but it might be just by chance caused
by timings. Thus, there is no evidence that 64bit kernels are not affected by
this bug. But I can't narrow down any more. Thus, I call for developers who can
narrow down / identify where the memory corruption bug is.



Depends on block device?

  Can't reproduce if executing reproducer from initramfs.
  But maybe this is due to timing dependent.

Depends on dynamic link?

  Can't reproduce if reproducer is statically linked.
  But maybe this is due to timing dependent.

Depends on hypervisor?

  Can reproduce on both VMware and QEMU.

Depends on filesystem?

  Can reproduce on xfs, ext4 and cramfs.



Below is complete procedure for reproducing this bug using minimal kernel
config tuned for QEMU running on x86_64 CentOS 7.4 host.

(1) Create a disk image with minimal contents.

qemu-img create -f raw /mnt/disk1.img 128M
mkfs.xfs /mnt/disk1.img
mount -o loop /mnt/disk1.img /mnt/
gcc -Wall -O3 -m32 -o /mnt/init -x c - << "EOF"
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mount.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
        int fd;
        mount("/proc", "/proc", "proc", 0, NULL);
        fd = open("/proc/sys/vm/oom_dump_tasks", O_WRONLY);
        write(fd, "0\n", 2);
        close(fd);
        while (1) {
                write(1, "Starting a.out\n", 15);
                if (fork() == 0) {
                        execlp("/a.out", "/a.out", NULL);
                        write(1, "Failed\n", 7);
                        _exit(0);
                }
                wait(NULL);
        }
        return 0;
}
EOF
gcc -Wall -O3 -m32 -o /mnt/a.out -x c - << "EOF"
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
        if (argc != 1) {
                unsigned long long size;
                char *buf = NULL;
                unsigned long long i;
                for (size = 1048576; size < 512ULL * (1 << 30); size += 1048576) {
                        char *cp = realloc(buf, size);
                        if (!cp) {
                                size -= 1048576;
                                break;
                        }
                        buf = cp;
                }
                for (i = 0; i < size; i += 4096)
                        buf[i] = 0;
                _exit(0);
        } else
                while (1)
                        if (fork() == 0)
                                execlp(argv[0], argv[0], "", NULL);
        return 0;
}
EOF
mkdir /mnt/lib /mnt/proc /mnt/dev
cp -pL /lib/libc.so.6 /lib/ld-linux.so.2 /mnt/lib/
umount -d /mnt/

(2) Build a 32bit kernel and boot it with the disk image.

cd /path/to/linux.git
wget -O .config http://I-love.SAKURA.ne.jp/tmp/config-4.15-rc7-min-qemu
make -s
/usr/libexec/qemu-kvm -no-kvm -machine pc -cpu kvm32 -smp 1 -m 2048 --no-reboot --kernel arch/x86/boot/bzImage --nographic --append "ro console=ttyS0,115200n8 root=/dev/vda init=/init" -drive file=/mnt/disk1.img,if=virtio

An example result is shown below.

[    0.000000] Linux version 4.15.0-rc7+ (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC)) #220 Sun Jan 14 20:36:37 JST 2018
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007fffbfff] usable
[    0.000000] BIOS-e820: [mem 0x000000007fffc000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] Notice: NX (Execute Disable) protection missing in CPU!
[    0.000000] random: fast init done
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Red Hat KVM, BIOS 0.5.1 01/01/2011
[    0.000000] e820: last_pfn = 0x7fffc max_arch_pfn = 0x100000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC
[    0.000000] found SMP MP-table at [mem 0x000f7300-0x000f730f] mapped at [(ptrval)]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F7160 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000007FFFFA9B 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000007FFFF177 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000007FFFE040 001137 (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000007FFFE000 000040
[    0.000000] ACPI: SSDT 0x000000007FFFF1EB 000838 (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000007FFFFA23 000078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] 1159MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x00000000377fdfff]
[    0.000000]   HighMem  [mem 0x00000000377fe000-0x000000007fffbfff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000007fffbfff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000007fffbfff]
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0 already used, trying 1
[    0.000000] IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] e820: [mem 0x80000000-0xfffbffff] available for PCI devices
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 521966
[    0.000000] Kernel command line: ro console=ttyS0,115200n8 root=/dev/vda init=/init
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (000377fe:0007fffc)
[    0.000000] Initializing Movable for node 0 (00000000:00000000)
[    0.000000] Memory: 2064228K/2096744K available (3330K kernel code, 256K rwdata, 916K rodata, 380K init, 5308K bss, 32516K reserved, 0K cma-reserved, 1187832K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffa4000 - 0xfffff000   ( 364 kB)
[    0.000000]   cpu_entry : 0xffc00000 - 0xffc28000   ( 160 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc1474000 - 0xc14d3000   ( 380 kB)
[    0.000000]       .data : 0xc1340b0a - 0xc14693a0   (1186 kB)
[    0.000000]       .text : 0xc1000000 - 0xc1340b0a   (3330 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: HWalign=128, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] NR_IRQS: 2304, nr_irqs: 256, preallocated irqs: 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [ttyS0] enabled
[    0.000000] ACPI: Core revision 20170831
[    0.000000] ACPI: 2 ACPI AML tables successfully acquired and loaded
[    0.002000] APIC: Switch to symmetric I/O mode setup
[    0.002000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.003000] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.008000] tsc: Fast TSC calibration using PIT
[    0.009000] tsc: Detected 2793.513 MHz processor
[    0.010000] Calibrating delay loop (skipped), value calculated using timer frequency.. 5587.02 BogoMIPS (lpj=2793513)
[    0.010000] pid_max: default: 32768 minimum: 301
[    0.011243] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.011590] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.019489] mce: CPU supports 10 MCE banks
[    0.020000] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.020000] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.020000] CPU: Intel Common 32-bit KVM processor (family: 0xf, model: 0x6, stepping: 0x1)
[    0.029000] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
[    0.032000] APIC calibration not consistent with PM-Timer: 193ms instead of 100ms
[    0.032000] APIC delta adjusted to PM-Timer: 6250001 (12069151)
[    0.035000] devtmpfs: initialized
[    0.037160] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    0.037567] futex hash table entries: 256 (order: -1, 3072 bytes)
[    0.042266] cpuidle: using governor menu
[    0.043000] ACPI: bus type PCI registered
[    0.044933] PCI: PCI BIOS revision 2.10 entry at 0xfd54b, last bus=0
[    0.045000] PCI: Using configuration type 1 for base access
[    0.051898] HugeTLB registered 4.00 MiB page size, pre-allocated 0 pages
[    0.054220] ACPI: Added _OSI(Module Device)
[    0.054416] ACPI: Added _OSI(Processor Device)
[    0.054553] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.054696] ACPI: Added _OSI(Processor Aggregator Device)
[    0.071000] ACPI: Interpreter enabled
[    0.071000] ACPI: (supports S0 S5)
[    0.071000] ACPI: Using IOAPIC for interrupt routing
[    0.071516] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.073000] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.094000] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.094000] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI]
[    0.094128] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.095318] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.099000] PCI host bridge to bus 0000:00
[    0.099211] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.099484] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.099616] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.099731] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebfffff window]
[    0.099926] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.106000] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.106078] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.106325] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.106486] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.108636] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    0.108866] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    0.127454] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.128000] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.128508] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.129000] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.129574] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.134000] pci 0000:00:02.0: vgaarb: setting as boot VGA device
[    0.134000] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.134068] pci 0000:00:02.0: vgaarb: bridge control possible
[    0.134233] vgaarb: loaded
[    0.135514] SCSI subsystem initialized
[    0.136526] PCI: Using ACPI for IRQ routing
[    0.137000] clocksource: Switched to clocksource refined-jiffies
[    0.138266] ACPI: Failed to create genetlink family for ACPI event
[    0.139337] pnp: PnP ACPI init
[    0.144998] pnp: PnP ACPI: found 5 devices
[    0.172994] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.173217] clocksource: Switched to clocksource acpi_pm
[    0.173994] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.173994] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.173994] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.173994] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.183369] Scanning for low memory corruption every 60 seconds
[    0.189392] workingset: timestamp_bits=14 max_order=19 bucket_order=5
[    0.204712] zbud: loaded
[    0.210911] SGI XFS with ACLs, security attributes, no debug enabled
[    0.220200] bounce: pool size: 64 pages
[    0.220200] io scheduler noop registered (default)
[    0.229848] atomic64_test: passed for i586+ platform with CX8 and with SSE
[    0.236151] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.237081] ACPI: Power Button [PWRF]
[    0.248193] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    0.248193] virtio-pci 0000:00:04.0: virtio_pci: leaving for legacy driver
[    0.254507] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.277797] 00:04: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    0.293374] Non-volatile memory driver v1.3
[    0.337929] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    0.342766] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.344004] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.347349] Using IPI Shortcut mode
[    0.347732] sched_clock: Marking stable (347235515, 0)->(709645618, -362410103)
[    0.350608] page_owner is disabled
[    0.375161] XFS (vda): Mounting V5 Filesystem
[    0.434199] XFS (vda): Ending clean mount
[    0.466036] VFS: Mounted root (xfs filesystem) readonly on device 254:0.
[    0.468423] devtmpfs: mounted
[    0.469817] debug: unmapping init [mem 0xc1474000-0xc14d2fff]
[    0.471908] Write protecting the kernel text: 3332k
[    0.472225] Write protecting the kernel read-only data: 928k
Starting a.out
[    1.184498] tsc: Refined TSC clocksource calibration: 2793.541 MHz
[    1.184788] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x28446b3c7b0, max_idle_ns: 440795331399 ns
[    2.262012] clocksource: Switched to clocksource tsc
/a.out: error while loading shared libraries: cannot create cache for search path: Cannot allocate memory
/a.out: error while loading shared libraries: libc.so.6: failed to map segment from shared object: Cannot allocate memory
/a.out: error while loading shared libraries: libc.so.6: failed to map segment from shared object: Cannot allocate memory
cannot allocate TLS data structures for initial thread/a.out: error while loading shared libraries: cannot create cache for search path: Cannot allocate memory
/a.out: error while loading shared libraries: libc.so.6: failed to map segment from shared object: Cannot allocate memory
/a.out: error while loading shared libraries: libc.so.6: failed to map segment from shared object: Cannot allocate memory
/a.out: error while loading shared libraries: libc.so.6: failed to map segment from shared object: Cannot allocate memory
[   40.328889] a.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[   40.329204] CPU: 0 PID: 144 Comm: a.out Not tainted 4.15.0-rc7+ #220
[   40.329371] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[   40.329676] Call Trace:
[   40.330675]  dump_stack+0x16/0x24
[   40.330901]  dump_header+0x64/0x211
[   40.330991]  ? irq_exit+0x2a/0x90
[   40.331052]  ? smp_apic_timer_interrupt+0x45/0x80
[   40.331122]  oom_kill_process+0x1ec/0x400
[   40.331183]  ? has_capability_noaudit+0x1f/0x30
[   40.331248]  ? oom_badness+0xc6/0x140
[   40.331365]  ? oom_evaluate_task+0xa2/0xe0
[   40.331561]  out_of_memory+0xe0/0x270
[   40.331625]  __alloc_pages_nodemask+0x6a3/0x830
[   40.331697]  handle_mm_fault+0xa5e/0xdd0
[   40.331768]  ? slow_virt_to_phys+0x2b/0x90
[   40.331886]  __do_page_fault+0x194/0x420
[   40.331969]  ? vmalloc_sync_all+0x150/0x150
[   40.332040]  do_page_fault+0xb/0xd
[   40.332093]  common_exception+0x6d/0x72
[   40.332599] EIP: 0x8048437
[   40.332948] EFLAGS: 00000202 CPU: 0
[   40.333046] EAX: 007a3000 EBX: 7ff00000 ECX: 3862e008 EDX: 00000000
[   40.333479] ESI: 7ff00000 EDI: 00000000 EBP: bfd4b908 ESP: bfd4b8d0
[   40.333643]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   40.333995] Mem-Info:
[   40.334767] active_anon:483450 inactive_anon:0 isolated_anon:0
[   40.334767]  active_file:0 inactive_file:10 isolated_file:55
[   40.334767]  unevictable:0 dirty:0 writeback:0 unstable:0
[   40.334767]  slab_reclaimable:26 slab_unreclaimable:919
[   40.334767]  mapped:40 shmem:0 pagetables:8018 bounce:0
[   40.334767]  free:22250 free_pcp:190 free_cma:0
[   40.335681] Node 0 active_anon:1933800kB inactive_anon:0kB active_file:0kB inactive_file:40kB unevictable:0kB isolated(anon):0kB isolated(file):220kB mapped:160kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   40.336482] DMA free:8788kB min:788kB low:984kB high:1180kB active_anon:7128kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15916kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   40.336893] lowmem_reserve[]: 0 840 2000 2000
[   40.337028] Normal free:79804kB min:42744kB low:53428kB high:64112kB active_anon:739736kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:892920kB managed:860480kB mlocked:0kB kernel_stack:2400kB pagetables:32072kB bounce:0kB free_pcp:640kB local_pcp:640kB free_cma:0kB
[   40.337567] lowmem_reserve[]: 0 0 9279 9279
[   40.337666] HighMem free:408kB min:512kB low:15260kB high:30008kB active_anon:1186936kB inactive_anon:0kB active_file:0kB inactive_file:40kB unevictable:0kB writepending:0kB present:1187832kB managed:1187832kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:120kB local_pcp:120kB free_cma:0kB
[   40.338051] lowmem_reserve[]: 0 0 0 0
[   40.338159] DMA: 1*4kB (U) 2*8kB (UM) 0*16kB 2*32kB (UM) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 2*1024kB (UM) 1*2048kB (U) 1*4096kB (M) = 8788kB
[   40.338781] Normal: 11*4kB (U) 14*8kB (UE) 6*16kB (UME) 2*32kB (UM) 0*64kB 1*128kB (E) 2*256kB (ME) 2*512kB (ME) 2*1024kB (ME) 1*2048kB (E) 18*4096kB (UM) = 79804kB
[   40.339083] HighMem: 2*4kB (U) 2*8kB (UM) 2*16kB (U) 1*32kB (M) 1*64kB (M) 0*128kB 1*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 408kB
[   40.339563] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=4096kB
[   40.339724] 39 total pagecache pages
[   40.339945] 524186 pages RAM
[   40.340032] 296958 pages HighMem/MovableOnly
[   40.340380] 8129 pages reserved
[   40.340526] Out of memory: Kill process 41 (a.out) score 12 or sacrifice child
[   40.341733] Killed process 41 (a.out) total-vm:2099260kB, anon-rss:26664kB, file-rss:64kB, shmem-rss:0kB
[   40.351554] clocksource: timekeeping watchdog on CPU0: Marking clocksource 'tsc' as unstable because the skew is too large:
[   40.351854] clocksource:                       'acpi_pm' wd_now: ea5383 wd_last: 1125e2 mask: ffffff
[   40.352083] clocksource:                       'tsc' cs_now: 1b2db1039e cs_last: 158b342a09 mask: ffffffffffffffff
[   40.352476] tsc: Marking TSC unstable due to clocksource watchdog
[   40.353017] TSC found unstable after boot, most likely due to broken BIOS. Use 'tsc=unstable'.
[   40.353325] sched_clock: Marking unstable (40352968436, 26691)<-(40715409249, -362410103)
[   40.392298] clocksource: Switched to clocksource acpi_pm
[   40.683413] a.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[   40.683680] CPU: 0 PID: 131 Comm: a.out Not tainted 4.15.0-rc7+ #220
[   40.683766] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[   40.683842] Call Trace:
[   40.683901]  dump_stack+0x16/0x24
[   40.683959]  dump_header+0x64/0x211
[   40.684016]  ? irq_exit+0x2a/0x90
[   40.684219]  ? smp_apic_timer_interrupt+0x45/0x80
[   40.684356]  oom_kill_process+0x1ec/0x400
[   40.684520]  ? has_capability_noaudit+0x1f/0x30
[   40.684694]  ? oom_badness+0xc6/0x140
[   40.684752]  ? oom_evaluate_task+0x14/0xe0
[   40.684813]  out_of_memory+0xe0/0x270
[   40.684871]  __alloc_pages_nodemask+0x6a3/0x830
[   40.684942]  handle_mm_fault+0xa5e/0xdd0
[   40.685002]  ? slow_virt_to_phys+0x2b/0x90
[   40.685410]  __do_page_fault+0x194/0x420
[   40.685486]  ? vmalloc_sync_all+0x150/0x150
[   40.685692]  do_page_fault+0xb/0xd
[   40.685777]  common_exception+0x6d/0x72
[   40.685848] EIP: 0x8048437
[   40.685910] EFLAGS: 00000202 CPU: 0
[   40.685981] EAX: 009f9000 EBX: 7ff00000 ECX: 38876008 EDX: 00000000
[   40.686533] ESI: 7ff00000 EDI: 00000000 EBP: bfc00b38 ESP: bfc00b00
[   40.686715]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   40.686831] Mem-Info:
[   40.686919] active_anon:483543 inactive_anon:0 isolated_anon:0
[   40.686919]  active_file:31 inactive_file:25 isolated_file:35
[   40.686919]  unevictable:0 dirty:0 writeback:0 unstable:0
[   40.686919]  slab_reclaimable:26 slab_unreclaimable:919
[   40.686919]  mapped:83 shmem:0 pagetables:7986 bounce:0
[   40.686919]  free:22233 free_pcp:120 free_cma:0
[   40.687885] Node 0 active_anon:1934172kB inactive_anon:0kB active_file:124kB inactive_file:100kB unevictable:0kB isolated(anon):0kB isolated(file):140kB mapped:332kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   40.689342] DMA free:8788kB min:788kB low:984kB high:1180kB active_anon:7128kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15916kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   40.689842] lowmem_reserve[]: 0 840 2000 2000
[   40.689972] Normal free:79744kB min:42744kB low:53428kB high:64112kB active_anon:740068kB inactive_anon:0kB active_file:88kB inactive_file:28kB unevictable:0kB writepending:0kB present:892920kB managed:860480kB mlocked:0kB kernel_stack:2408kB pagetables:31944kB bounce:0kB free_pcp:296kB local_pcp:296kB free_cma:0kB
[   40.690726] lowmem_reserve[]: 0 0 9279 9279
[   40.690828] HighMem free:400kB min:512kB low:15260kB high:30008kB active_anon:1186976kB inactive_anon:0kB active_file:36kB inactive_file:72kB unevictable:0kB writepending:0kB present:1187832kB managed:1187832kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:184kB local_pcp:184kB free_cma:0kB
[   40.691461] lowmem_reserve[]: 0 0 0 0
[   40.691579] DMA: 1*4kB (U) 2*8kB (UM) 0*16kB 2*32kB (UM) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 2*1024kB (UM) 1*2048kB (U) 1*4096kB (M) = 8788kB
[   40.691832] Normal: 42*4kB (UM) 35*8kB (UME) 12*16kB (UE) 6*32kB (UM) 1*64kB (M) 2*128kB (ME) 1*256kB (E) 1*512kB (E) 2*1024kB (ME) 1*2048kB (E) 18*4096kB (UM) = 79744kB
[   40.692432] HighMem: 2*4kB (U) 1*8kB (U) 2*16kB (U) 1*32kB (M) 1*64kB (M) 0*128kB 1*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 400kB
[   40.692714] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=4096kB
[   40.692831] 82 total pagecache pages
[   40.692887] 524186 pages RAM
[   40.692971] 296958 pages HighMem/MovableOnly
[   40.693033] 8129 pages reserved
[   40.693528] Out of memory: Kill process 50 (a.out) score 10 or sacrifice child
[   40.693705] Killed process 50 (a.out) total-vm:2099260kB, anon-rss:22284kB, file-rss:40kB, shmem-rss:0kB
[   41.251822] a.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[   41.252049] CPU: 0 PID: 217 Comm: a.out Not tainted 4.15.0-rc7+ #220
[   41.252139] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[   41.252215] Call Trace:
[   41.252274]  dump_stack+0x16/0x24
[   41.252331]  dump_header+0x64/0x211
[   41.252387]  ? irq_exit+0x2a/0x90
[   41.252500]  ? smp_apic_timer_interrupt+0x45/0x80
[   41.253033]  oom_kill_process+0x1ec/0x400
[   41.253128]  ? has_capability_noaudit+0x1f/0x30
[   41.253220]  ? oom_badness+0xc6/0x140
[   41.253299]  ? oom_evaluate_task+0x14/0xe0
[   41.253374]  out_of_memory+0xe0/0x270
[   41.253489]  __alloc_pages_nodemask+0x6a3/0x830
[   41.253747]  handle_mm_fault+0xa5e/0xdd0
[   41.253825]  ? slow_virt_to_phys+0x2b/0x90
[   41.253897]  __do_page_fault+0x194/0x420
[   41.253985]  ? vmalloc_sync_all+0x150/0x150
[   41.254055]  do_page_fault+0xb/0xd
[   41.254116]  common_exception+0x6d/0x72
[   41.254181] EIP: 0x8048437
[   41.254228] EFLAGS: 00000202 CPU: 0
[   41.254357] EAX: 00196000 EBX: 7ff00000 ECX: 37fe4008 EDX: 00000000
[   41.254764] ESI: 7ff00000 EDI: 00000000 EBP: bfd59aa8 ESP: bfd59a70
[   41.254917]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   41.255018] Mem-Info:
[   41.255121] active_anon:483725 inactive_anon:0 isolated_anon:0
[   41.255121]  active_file:0 inactive_file:0 isolated_file:1
[   41.255121]  unevictable:0 dirty:0 writeback:0 unstable:0
[   41.255121]  slab_reclaimable:26 slab_unreclaimable:919
[   41.255121]  mapped:2 shmem:0 pagetables:7936 bounce:0
[   41.255121]  free:22269 free_pcp:60 free_cma:0
[   41.256137] Node 0 active_anon:1934900kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):4kB mapped:8kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   41.256637] DMA free:8788kB min:788kB low:984kB high:1180kB active_anon:7128kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15916kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   41.257064] lowmem_reserve[]: 0 840 2000 2000
[   41.257346] Normal free:79808kB min:42744kB low:53428kB high:64112kB active_anon:740620kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:892920kB managed:860480kB mlocked:0kB kernel_stack:2344kB pagetables:31744kB bounce:0kB free_pcp:120kB local_pcp:120kB free_cma:0kB
[   41.257816] lowmem_reserve[]: 0 0 9279 9279
[   41.257934] HighMem free:480kB min:512kB low:15260kB high:30008kB active_anon:1187152kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:1187832kB managed:1187832kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:120kB local_pcp:120kB free_cma:0kB
[   41.258204] lowmem_reserve[]: 0 0 0 0
[   41.258204] DMA: 1*4kB (U) 2*8kB (UM) 0*16kB 2*32kB (UM) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 2*1024kB (UM) 1*2048kB (U) 1*4096kB (M) = 8788kB
[   41.259035] Normal: 98*4kB (UM) 43*8kB (UE) 16*16kB (UME) 5*32kB (U) 1*64kB (U) 2*128kB (ME) 2*256kB (ME) 2*512kB (ME) 1*1024kB (E) 1*2048kB (E) 18*4096kB (UM) = 79808kB
[   41.259312] HighMem: 2*4kB (U) 1*8kB (U) 3*16kB (UM) 1*32kB (M) 0*64kB 1*128kB (M) 1*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 480kB
[   41.259782] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=4096kB
[   41.259903] 1 total pagecache pages
[   41.259975] 524186 pages RAM
[   41.260022] 296958 pages HighMem/MovableOnly
[   41.260084] 8129 pages reserved
[   41.260137] Out of memory: Kill process 53 (a.out) score 10 or sacrifice child
[   41.260259] Killed process 53 (a.out) total-vm:2099260kB, anon-rss:21276kB, file-rss:8kB, shmem-rss:0kB
[   42.305105] a.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[   42.305302] CPU: 0 PID: 224 Comm: a.out Not tainted 4.15.0-rc7+ #220
[   42.305388] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[   42.305667] Call Trace:
[   42.305732]  dump_stack+0x16/0x24
[   42.305790]  dump_header+0x64/0x211
[   42.305847]  ? get_page_from_freelist+0x106/0xb30
[   42.305932]  oom_kill_process+0x1ec/0x400
[   42.305995]  ? has_capability_noaudit+0x1f/0x30
[   42.306060]  ? oom_badness+0xc6/0x140
[   42.306115]  ? oom_evaluate_task+0x14/0xe0
[   42.306175]  out_of_memory+0xe0/0x270
[   42.306231]  __alloc_pages_nodemask+0x6a3/0x830
[   42.306302]  handle_mm_fault+0xa5e/0xdd0
[   42.306361]  ? slow_virt_to_phys+0x2b/0x90
[   42.306485]  __do_page_fault+0x194/0x420
[   42.306725]  ? vmalloc_sync_all+0x150/0x150
[   42.306795]  do_page_fault+0xb/0xd
[   42.306870]  common_exception+0x6d/0x72
[   42.306961] EIP: 0x8048437
[   42.307003] EFLAGS: 00000202 CPU: 0
[   42.307053] EAX: 0009c000 EBX: 7e600000 ECX: 37f31008 EDX: 00000000
[   42.307133] ESI: 7e600000 EDI: 00000000 EBP: bf8660b8 ESP: bf866080
[   42.307215]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   42.307287] Mem-Info:
[   42.307391] active_anon:483682 inactive_anon:0 isolated_anon:0
[   42.307391]  active_file:0 inactive_file:3 isolated_file:17
[   42.307391]  unevictable:0 dirty:1 writeback:0 unstable:0
[   42.307391]  slab_reclaimable:26 slab_unreclaimable:919
[   42.307391]  mapped:17 shmem:0 pagetables:7904 bounce:0
[   42.307391]  free:22274 free_pcp:125 free_cma:0
[   42.308066] Node 0 active_anon:1934728kB inactive_anon:0kB active_file:0kB inactive_file:12kB unevictable:0kB isolated(anon):0kB isolated(file):68kB mapped:68kB dirty:4kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   42.308390] DMA free:8788kB min:788kB low:984kB high:1180kB active_anon:7128kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15916kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   42.308810] lowmem_reserve[]: 0 840 2000 2000
[   42.308948] Normal free:79832kB min:42744kB low:53428kB high:64112kB active_anon:740776kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:892920kB managed:860480kB mlocked:0kB kernel_stack:2328kB pagetables:31616kB bounce:0kB free_pcp:124kB local_pcp:124kB free_cma:0kB
[   42.309038] lowmem_reserve[]: 0 0 9279 9279
[   42.309823] HighMem free:476kB min:512kB low:15260kB high:30008kB active_anon:1186824kB inactive_anon:0kB active_file:0kB inactive_file:12kB unevictable:0kB writepending:4kB present:1187832kB managed:1187832kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:376kB local_pcp:376kB free_cma:0kB
[   42.310231] lowmem_reserve[]: 0 0 0 0
[   42.310338] DMA: 1*4kB (U) 2*8kB (UM) 0*16kB 2*32kB (UM) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 2*1024kB (UM) 1*2048kB (U) 1*4096kB (M) = 8788kB
[   42.310838] Normal: 104*4kB (U) 47*8kB (UME) 18*16kB (UME) 7*32kB (U) 1*64kB (U) 1*128kB (E) 2*256kB (ME) 2*512kB (ME) 1*1024kB (E) 1*2048kB (E) 18*4096kB (UM) = 79832kB
[   42.311455] HighMem: 3*4kB (UM) 2*8kB (UM) 2*16kB (U) 1*32kB (M) 0*64kB 1*128kB (M) 1*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 476kB
[   42.311775] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=4096kB
[   42.311935] 20 total pagecache pages
[   42.312011] 524186 pages RAM
[   42.312090] 296958 pages HighMem/MovableOnly
[   42.312319] 8129 pages reserved
[   42.312413] Out of memory: Kill process 36 (a.out) score 9 or sacrifice child
[   42.312583] Killed process 36 (a.out) total-vm:2099260kB, anon-rss:21080kB, file-rss:4kB, shmem-rss:0kB
[   42.366107] BUG: unable to handle kernel NULL pointer dereference at 00000200
[   42.366346] IP: mpage_readpages+0x8b/0x160
[   42.366431] *pde = 00000000
[   42.366599] Oops: 0000 [#1] DEBUG_PAGEALLOC
[   42.366599] CPU: 0 PID: 308 Comm: a.out Not tainted 4.15.0-rc7+ #220
[   42.366599] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[   42.366599] EIP: mpage_readpages+0x8b/0x160
[   42.366599] EFLAGS: 00000206 CPU: 0
[   42.366599] EAX: d85afe28 EBX: 00000200 ECX: d85afe30 EDX: 00000100
[   42.366599] ESI: 00000011 EDI: 000001ec EBP: d85afdf0 ESP: d85afd74
[   42.366599]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
[   42.366599] CR0: 80050033 CR2: 00000200 CR3: 185a0000 CR4: 000006d0
[   42.366599] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[   42.366599] DR6: 00000000 DR7: 00000000
[   42.366599] Call Trace:
[   42.366599]  ? xfs_setfilesize_trans_alloc.isra.29+0x80/0x80
[   42.366599]  ? xfs_setfilesize_trans_alloc.isra.29+0x80/0x80
[   42.366599]  ? __radix_tree_lookup+0x6e/0xd0
[   42.366599]  ? xfs_map_at_offset+0x30/0x30
[   42.366599]  xfs_vm_readpages+0x19/0x20
[   42.366599]  ? xfs_setfilesize_trans_alloc.isra.29+0x80/0x80
[   42.366599]  __do_page_cache_readahead+0x158/0x1f0
[   42.366599]  filemap_fault+0x299/0x510
[   42.366599]  ? page_add_file_rmap+0xfb/0x150
[   42.366599]  ? unlock_page+0x30/0x30
[   42.366599]  ? filemap_map_pages+0x265/0x2e0
[   42.366599]  __xfs_filemap_fault.isra.18+0x2d/0xb0
[   42.366599]  xfs_filemap_fault+0xa/0x10
[   42.366599]  __do_fault+0x11/0x30
[   42.366599]  ? unlock_page+0x30/0x30
[   42.366599]  handle_mm_fault+0x7d4/0xdd0
[   42.366599]  __do_page_fault+0x194/0x420
[   42.366599]  ? vmalloc_sync_all+0x150/0x150
[   42.366599]  do_page_fault+0xb/0xd
[   42.366599]  common_exception+0x6d/0x72
[   42.366599] EIP: 0xb7efd1e0
[   42.366599] EFLAGS: 00000246 CPU: 0
[   42.366599] EAX: b7e42790 EBX: b7f85000 ECX: bfe5d02c EDX: bfe5d030
[   42.366599] ESI: 00000000 EDI: b7f85404 EBP: bfe5d058 ESP: bfe5cffc
[   42.366599]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   42.366599] Code: 00 00 eb 1a 8d 74 26 00 8b 03 a8 01 0f 85 cc 00 00 00 89 f8 ff 48 10 74 77 83 ee 01 74 7c 8b 45 a4 8b 58 04 8d 7b ec 8d 74 26 00 <8b> 13 8b 43 04 89 42 04 89 10 8b 45 a8 8b 4b f4 8b 55 a0 c7 03
[   42.366599] EIP: mpage_readpages+0x8b/0x160 SS:ESP: 0068:d85afd74
[   42.366599] CR2: 0000000000000200
[   42.371210] ---[ end trace c88beaeceebe4c9b ]---
[   42.371357] Kernel panic - not syncing: Fatal exception
[   42.371508] Kernel Offset: disabled
[   42.371617] Rebooting in 1 seconds..

Another example is shown below.

[   31.067600] BUG: Bad page state in process a.out  pfn:7fe84
[   31.067817] page:f63884a0 count:0 mapcount:2 mapping:f5818f94 index:0x1
[   31.067955] flags: 0x7e000000()
[   31.068198] raw: 7e000000 f5818f94 00000001 00000001 00000000 00000100 00000200 00000000
[   31.068198] raw: 00000000 00000000
[   31.068198] page dumped because: non-NULL mapping
[   31.068198] CPU: 0 PID: 47 Comm: a.out Not tainted 4.15.0-rc7+ #220
[   31.068198] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[   31.068198] Call Trace:
[   31.068198]  dump_stack+0x16/0x24
[   31.068198]  bad_page+0x106/0x122
[   31.068198]  free_pages_check_bad+0x5b/0x5e
[   31.068198]  free_pcppages_bulk+0x3c4/0x3d0
[   31.068198]  free_unref_page_commit.isra.117+0x6c/0x80
[   31.068198]  free_unref_page_list+0xd9/0x110
[   31.068198]  release_pages+0x208/0x2c0
[   31.068198]  tlb_flush_mmu_free+0x2f/0x50
[   31.068198]  arch_tlb_finish_mmu+0x30/0x60
[   31.068198]  tlb_finish_mmu+0x24/0x40
[   31.068198]  exit_mmap+0x99/0x130
[   31.068198]  mmput+0x36/0xb0
[   31.068198]  do_exit+0x199/0x8d0
[   31.068198]  ? recalc_sigpending+0x11/0x40
[   31.068198]  ? __alloc_pages_nodemask+0x1d8/0x830
[   31.068198]  do_group_exit+0x2a/0x70
[   31.068198]  get_signal+0x121/0x460
[   31.068198]  ? ktime_get+0x47/0xf0
[   31.068198]  do_signal+0x24/0x590
[   31.068198]  ? native_sched_clock+0x35/0x100
[   31.068198]  ? __phys_addr+0x32/0x70
[   31.068198]  ? __schedule+0x126/0x36b
[   31.068198]  ? __do_page_fault+0x1b0/0x420
[   31.068198]  exit_to_usermode_loop+0x32/0x5e
[   31.068198]  ? vmalloc_sync_all+0x150/0x150
[   31.068198]  prepare_exit_to_usermode+0x43/0x70
[   31.068198]  ? vmalloc_sync_all+0x150/0x150
[   31.068198]  resume_userspace+0x8/0xd
[   31.068198] EIP: 0x8048437
[   31.068198] EFLAGS: 00000202 CPU: 0
[   31.068198] EAX: 01659000 EBX: 7ff00000 ECX: 394f7008 EDX: 00000000
[   31.068198] ESI: 7ff00000 EDI: 00000000 EBP: bff1d698 ESP: bff1d660
[   31.068198]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   31.068198] Disabling lock debugging due to kernel taint

Yet another example is shown below.

[   28.211801] BUG: unable to handle kernel paging request at 1a8a306a
[   28.212034] IP: page_remove_rmap+0x17/0x280
[   28.212269] *pde = 00000000
[   28.212447] Oops: 0000 [#1] DEBUG_PAGEALLOC
[   28.212614] CPU: 0 PID: 54 Comm: a.out Not tainted 4.15.0-rc7+ #220
[   28.212767] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[   28.212901] EIP: page_remove_rmap+0x17/0x280
[   28.212981] EFLAGS: 00000206 CPU: 0
[   28.213061] EAX: 1a8a3066 EBX: f52c2210 ECX: 00000051 EDX: 00000000
[   28.213203] ESI: 148da045 EDI: f63884c8 EBP: f5ea1b10 ESP: f5ea1b04
[   28.213410]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
[   28.213562] CR0: 80050033 CR2: 1a8a306a CR3: 35404000 CR4: 000006d0
[   28.213762] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[   28.213942] DR6: 00000000 DR7: 00000000
[   28.214082] Call Trace:
[   28.214228]  try_to_unmap_one+0x1ca/0x410
[   28.214341]  rmap_walk_file+0xf0/0x1e0
[   28.214433]  rmap_walk+0x32/0x60
[   28.214524]  try_to_unmap+0x4d/0xd0
[   28.214608]  ? page_remove_rmap+0x280/0x280
[   28.214715]  ? page_not_mapped+0x10/0x10
[   28.214816]  ? page_get_anon_vma+0x80/0x80
[   28.214918]  shrink_page_list+0x293/0xcd0
[   28.215037]  shrink_inactive_list+0x1a3/0x450
[   28.215137]  shrink_node_memcg+0x2b0/0x350
[   28.215263]  shrink_node+0xbb/0x2c0
[   28.215370]  do_try_to_free_pages+0x92/0x2c0
[   28.215480]  try_to_free_pages+0x1fb/0x320
[   28.215589]  __alloc_pages_nodemask+0x351/0x830
[   28.215689]  ? tick_program_event+0x3a/0x80
[   28.215853]  ? SyS_readahead+0xa0/0xa0
[   28.215957]  ? mem_cgroup_commit_charge+0x6e/0xb0
[   28.216068]  ? page_add_new_anon_rmap+0x6c/0xa0
[   28.216202]  handle_mm_fault+0xa5e/0xdd0
[   28.216304]  __do_page_fault+0x194/0x420
[   28.216396]  ? vmalloc_sync_all+0x150/0x150
[   28.216498]  do_page_fault+0xb/0xd
[   28.216591]  common_exception+0x6d/0x72
[   28.216697] EIP: 0x8048437
[   28.216766] EFLAGS: 00000202 CPU: 0
[   28.216843] EAX: 01267000 EBX: 7ff00000 ECX: 3910e008 EDX: 00000000
[   28.216981] ESI: 7ff00000 EDI: 00000000 EBP: bfc0cf08 ESP: bfc0ced0
[   28.217098]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   28.217199] Code: b1 83 e8 01 e9 55 ff ff ff 83 e8 01 e9 37 ff ff ff 8d 76 00 55 89 e5 56 53 89 c3 83 ec 04 8b 40 14 a8 01 0f 85 10 02 00 00 89 d8 <f6> 40 04 01 74 6b 84 d2 0f 85 5b 01 00 00 83 43 0c ff 78 0d 83
[   28.217849] EIP: page_remove_rmap+0x17/0x280 SS:ESP: 0068:f5ea1b04
[   28.217973] CR2: 000000001a8a306a
[   28.218377] ---[ end trace 118e4d2be9e69f8a ]---
[   28.218661] Kernel panic - not syncing: Fatal exception
[   28.218808] Kernel Offset: disabled
[   28.218931] Rebooting in 1 seconds..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
