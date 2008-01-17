Date: Thu, 17 Jan 2008 20:54:56 +0100
From: Olaf Hering <olaf@aepfle.de>
Subject: Re: crash in kmem_cache_init
Message-ID: <20080117195456.GA24901@aepfle.de>
References: <20080115150949.GA14089@aepfle.de> <84144f020801170414q7d408a74uf47a84b777c36a4a@mail.gmail.com> <Pine.LNX.4.64.0801170628580.19208@schroedinger.engr.sgi.com> <20080117181222.GA24411@aepfle.de> <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="0F1p//8PRICkK4MW"
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Thu, Jan 17, Christoph Lameter wrote:

> > freeing bootmem node 1
> > Memory: 3496632k/3571712k available (6188k kernel code, 75080k reserved, 1324k data, 1220k bss, 304k init)
> > cache_grow(2781) swapper(0):c0,j4294937299 cp c0000000006a4fb8 !l3
> 
> Is there more backtrace information? What function called cache_grow?

I just put a 'if (!l3) return 0;' into cache_grow, the backtrace is the
one from the initial report.
Reverting 04231b3002ac53f8a64a7bd142fde3fa4b6808c6 does not change
anything.


Since -mm boots further, what patch should I try?

The kernel boots on a different p570.
See attached dmesg. huckleberry boots, cranberry crashes.


--- huckleberry.suse.de-2.6.16.57-0.5-ppc64.txt	2008-01-17 20:48:18.510309000 +0100
+++ cranberry.suse.de-2.6.16.57-0.5-ppc64.txt	2008-01-17 20:48:09.425402000 +0100
@@ -1,56 +1,55 @@
 Page orders: linear mapping = 24, others = 12
-Found initrd at 0xc000000002700000:0xc000000002a93000
+Found initrd at 0xc000000001300000:0xc0000000016e6c1e
 Partition configured for 8 cpus.
 Starting Linux PPC64 #1 SMP Wed Dec 5 09:02:21 UTC 2007
 -----------------------------------------------------
-ppc64_pft_size                = 0x1b
+ppc64_pft_size                = 0x1c
 ppc64_interrupt_controller    = 0x2
 platform                      = 0x101
-physicalMemorySize            = 0x158000000
+physicalMemorySize            = 0xda000000
 ppc64_caches.dcache_line_size = 0x80
 ppc64_caches.icache_line_size = 0x80
 htab_address                  = 0x0000000000000000
-htab_hash_mask                = 0xfffff
+htab_hash_mask                = 0x1fffff
 -----------------------------------------------------
 [boot]0100 MM Init
 [boot]0100 MM Init Done
 Linux version 2.6.16.57-0.5-ppc64 (geeko@buildhost) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #1 SMP Wed Dec 5 09:02:21 UTC 2007
 [boot]0012 Setup Arch
-Node 0 Memory: 0x0-0xb0000000
-Node 1 Memory: 0xb0000000-0x158000000
+Node 0 Memory:
+Node 1 Memory: 0x0-0xda000000
 EEH: PCI Enhanced I/O Error Handling Enabled
-PPC64 nvram contains 7168 bytes
+PPC64 nvram contains 8192 bytes
 Using dedicated idle loop
-On node 0 totalpages: 720896
-  DMA zone: 720896 pages, LIFO batch:31
+On node 0 totalpages: 0
+  DMA zone: 0 pages, LIFO batch:0
   DMA32 zone: 0 pages, LIFO batch:0
   Normal zone: 0 pages, LIFO batch:0
   HighMem zone: 0 pages, LIFO batch:0
-On node 1 totalpages: 688128
-  DMA zone: 688128 pages, LIFO batch:31
+On node 1 totalpages: 892928
+  DMA zone: 892928 pages, LIFO batch:31
   DMA32 zone: 0 pages, LIFO batch:0
   Normal zone: 0 pages, LIFO batch:0
   HighMem zone: 0 pages, LIFO batch:0
 [boot]0015 Setup Done
 Built 2 zonelists
-Kernel command line: root=/dev/disk/by-id/scsi-SIBM_ST373453LC_3HW1CPW500007445Q010-part5  xmon=on sysrq=1 quiet 
+Kernel command line: root=/dev/system/root  xmon=on sysrq=1 quiet 
 [boot]0020 XICS Init
 xics: no ISA interrupt controller
 [boot]0021 XICS Done
 PID hash table entries: 4096 (order: 12, 131072 bytes)
-time_init: decrementer frequency = 207.052000 MHz
-time_init: processor frequency   = 1654.344000 MHz
+time_init: decrementer frequency = 275.070000 MHz
+time_init: processor frequency   = 2197.800000 MHz
 Console: colour dummy device 80x25
-Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
-Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
-freeing bootmem node 0
+Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
+Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
 freeing bootmem node 1
-Memory: 5524952k/5636096k available (4464k kernel code, 111144k reserved, 1992k data, 836k bss, 264k init)
-Calibrating delay loop... 413.69 BogoMIPS (lpj=2068480)
+Memory: 3494648k/3571712k available (4464k kernel code, 77064k reserved, 1992k data, 836k bss, 264k init)
+Calibrating delay loop... 548.86 BogoMIPS (lpj=2744320)
 Security Framework v1.0.0 initialized
 Mount-cache hash table entries: 256
 checking if image is initramfs... it is
-Freeing initrd memory: 3660k freed
+Freeing initrd memory: 3995k freed
 Processor 1 found.
 Processor 2 found.
 Processor 3 found.
@@ -61,7 +60,7 @@ Processor 7 found.
 Brought up 8 CPUs
 Node 0 CPUs: 0-3
 Node 1 CPUs: 4-7
-migration_cost=41,0,4308
+migration_cost=38,0,3225
 NET: Registered protocol family 16
 PCI: Probing PCI hardware
 IOMMU table initialized, virtual merging enabled

--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="huckleberry.suse.de-2.6.16.57-0.5-ppc64.txt"

Page orders: linear mapping = 24, others = 12
Found initrd at 0xc000000002700000:0xc000000002a93000
Partition configured for 8 cpus.
Starting Linux PPC64 #1 SMP Wed Dec 5 09:02:21 UTC 2007
-----------------------------------------------------
ppc64_pft_size                = 0x1b
ppc64_interrupt_controller    = 0x2
platform                      = 0x101
physicalMemorySize            = 0x158000000
ppc64_caches.dcache_line_size = 0x80
ppc64_caches.icache_line_size = 0x80
htab_address                  = 0x0000000000000000
htab_hash_mask                = 0xfffff
-----------------------------------------------------
[boot]0100 MM Init
[boot]0100 MM Init Done
Linux version 2.6.16.57-0.5-ppc64 (geeko@buildhost) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #1 SMP Wed Dec 5 09:02:21 UTC 2007
[boot]0012 Setup Arch
Node 0 Memory: 0x0-0xb0000000
Node 1 Memory: 0xb0000000-0x158000000
EEH: PCI Enhanced I/O Error Handling Enabled
PPC64 nvram contains 7168 bytes
Using dedicated idle loop
On node 0 totalpages: 720896
  DMA zone: 720896 pages, LIFO batch:31
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 0 pages, LIFO batch:0
  HighMem zone: 0 pages, LIFO batch:0
On node 1 totalpages: 688128
  DMA zone: 688128 pages, LIFO batch:31
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 0 pages, LIFO batch:0
  HighMem zone: 0 pages, LIFO batch:0
[boot]0015 Setup Done
Built 2 zonelists
Kernel command line: root=/dev/disk/by-id/scsi-SIBM_ST373453LC_3HW1CPW500007445Q010-part5  xmon=on sysrq=1 quiet 
[boot]0020 XICS Init
xics: no ISA interrupt controller
[boot]0021 XICS Done
PID hash table entries: 4096 (order: 12, 131072 bytes)
time_init: decrementer frequency = 207.052000 MHz
time_init: processor frequency   = 1654.344000 MHz
Console: colour dummy device 80x25
Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
freeing bootmem node 0
freeing bootmem node 1
Memory: 5524952k/5636096k available (4464k kernel code, 111144k reserved, 1992k data, 836k bss, 264k init)
Calibrating delay loop... 413.69 BogoMIPS (lpj=2068480)
Security Framework v1.0.0 initialized
Mount-cache hash table entries: 256
checking if image is initramfs... it is
Freeing initrd memory: 3660k freed
Processor 1 found.
Processor 2 found.
Processor 3 found.
Processor 4 found.
Processor 5 found.
Processor 6 found.
Processor 7 found.
Brought up 8 CPUs
Node 0 CPUs: 0-3
Node 1 CPUs: 4-7
migration_cost=41,0,4308
NET: Registered protocol family 16
PCI: Probing PCI hardware
IOMMU table initialized, virtual merging enabled
mapping IO 3fe00100000 -> d000080000000000, size: 100000
mapping IO 3fe00600000 -> d000080000100000, size: 100000
mapping IO 3fe00300000 -> d000080000200000, size: 100000
PCI: Probing PCI hardware done
Registering pmac pic with sysfs...
usbcore: registered new driver usbfs
usbcore: registered new driver hub
IBM eBus Device Driver
RTAS daemon started
RTAS: event: 109, Type: Platform Error, Severity: 2
probe_bus_pseries: processing c000000157ff7058
probe_bus_pseries: processing c000000157ff7228
probe_bus_pseries: processing c000000157ff7378
probe_bus_pseries: processing c000000157ff74e8
probe_bus_pseries: processing c000000157ff7658
audit: initializing netlink socket (disabled)
audit(1200599258.200:1): initialized
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
Initializing Cryptographic API
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
rpaphp: RPA HOT Plug PCI Controller Driver version: 0.1
rpaphp: Slot [0001:00:02.0](PCI location=U7879.001.DQD02EK-P1-C3) registered
rpaphp: Slot [0001:00:02.2](PCI location=U7879.001.DQD02EK-P1-C4) registered
rpaphp: Slot [0001:00:02.4](PCI location=U7879.001.DQD02EK-P1-C5) registered
rpaphp: Slot [0001:00:02.6](PCI location=U7879.001.DQD02EK-P1-C6) registered
rpaphp: Slot [0002:00:02.0](PCI location=U7879.001.DQD02EK-P1-C1) registered
rpaphp: Slot [0002:00:02.6](PCI location=U7879.001.DQD02EK-P1-C2) registered
matroxfb: Matrox G450 detected
PInS data found at offset 31168
PInS memtype = 5
matroxfb: 640x480x8bpp (virtual: 640x26214)
matroxfb: framebuffer at 0x400C0000000, mapped to 0xd000080080004000, size 33554432
Console: switching to colour frame buffer device 80x30
fb0: MATROX frame buffer device
matroxfb_crtc2: secondary head of fb0 was registered as fb1
vio_register_driver: driver hvc_console registering
HVSI: registered 0 devices
Generic RTC Driver v1.07
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
pmac_zilog: 0.6 (Benjamin Herrenschmidt <benh@kernel.crashing.org>)
RAMDISK driver initialized: 16 RAM disks of 123456K size 1024 blocksize
input: Macintosh mouse button emulation as /class/input/input0
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ehci_hcd 0000:c8:01.2: EHCI Host Controller
ehci_hcd 0000:c8:01.2: new USB bus registered, assigned bus number 1
ehci_hcd 0000:c8:01.2: irq 101, io mem 0x400a0002000
ehci_hcd 0000:c8:01.2: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: new device found, idVendor=0000, idProduct=0000
usb usb1: new device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.16.57-0.5-ppc64 ehci_hcd
usb usb1: SerialNumber: 0000:c8:01.2
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 5 ports detected
ohci_hcd: 2005 April 22 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
ohci_hcd 0000:c8:01.0: OHCI Host Controller
ohci_hcd 0000:c8:01.0: new USB bus registered, assigned bus number 2
ohci_hcd 0000:c8:01.0: irq 101, io mem 0x400a0001000
usb usb2: new device found, idVendor=0000, idProduct=0000
usb usb2: new device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: OHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.16.57-0.5-ppc64 ohci_hcd
usb usb2: SerialNumber: 0000:c8:01.0
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 3 ports detected
hub 2-0:1.0: over-current change on port 1
ohci_hcd 0000:c8:01.1: OHCI Host Controller
ohci_hcd 0000:c8:01.1: new USB bus registered, assigned bus number 3
ohci_hcd 0000:c8:01.1: irq 101, io mem 0x400a0000000
usb usb3: new device found, idVendor=0000, idProduct=0000
usb usb3: new device strings: Mfr=3, Product=2, SerialNumber=1
usb usb3: Product: OHCI Host Controller
usb usb3: Manufacturer: Linux 2.6.16.57-0.5-ppc64 ohci_hcd
usb usb3: SerialNumber: 0000:c8:01.1
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
hub 3-0:1.0: over-current change on port 1
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.6:USB HID core driver
mice: PS/2 mouse device common for all mice
md: md driver 0.90.3 MAX_MD_DEVS=256, MD_SB_DISKS=27
md: bitmap version 4.39
oprofile: using ppc64/power5 performance monitoring.
NET: Registered protocol family 2
IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
NET: Registered protocol family 1
NET: Registered protocol family 17
NET: Registered protocol family 15
Freeing unused kernel memory: 264k freed
SCSI subsystem initialized
libata version 2.00 loaded.
ipr: IBM Power RAID SCSI Device Driver version: 2.2.0.2 (November 14, 2007)
ipr 0000:c0:01.0: Found IOA with IRQ: 99
ipr 0000:c0:01.0: Starting IOA initialization sequence.
ipr 0000:c0:01.0: Adapter firmware version: 020A004E
ipr 0000:c0:01.0: IOA initialized.
scsi0 : IBM 570B Storage Adapter
  Vendor: IBM       Model: ST373453LC        Rev: C51A
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sda: 143374000 512-byte hdwr sectors (73407 MB)
sda: Write Protect is off
sda: Mode Sense: cb 00 10 08
SCSI device sda: drive cache: write through w/ FUA
SCSI device sda: 143374000 512-byte hdwr sectors (73407 MB)
sda: Write Protect is off
sda: Mode Sense: cb 00 10 08
SCSI device sda: drive cache: write through w/ FUA
 sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
sd 0:0:4:0: Attached scsi disk sda
  Vendor: IBM       Model: VSBPD3E   U4SCSI  Rev: 4812
  Type:   Enclosure                          ANSI SCSI revision: 02
sd 0:0:4:0: Attached scsi generic sg0 type 0
 0:0:15:0: Attached scsi generic sg1 type 13
scsi: unknown device type 31
  Vendor: IBM       Model: 570B001           Rev: 0150
  Type:   Unknown                            ANSI SCSI revision: 00
 0:255:255:255: Attached scsi generic sg2 type 31
ipr 0002:c8:01.0: Found IOA with IRQ: 133
ipr 0002:c8:01.0: Starting IOA initialization sequence.
ipr 0002:c8:01.0: Adapter firmware version: 020A004E
ipr 0002:c8:01.0: IOA initialized.
scsi1 : IBM 570B Storage Adapter
  Vendor: IBM       Model: IC35L073UCDY10-0  Rev: S28G
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sdb: 143374000 512-byte hdwr sectors (73407 MB)
sdb: Write Protect is off
sdb: Mode Sense: cb 00 00 08
SCSI device sdb: drive cache: write through
SCSI device sdb: 143374000 512-byte hdwr sectors (73407 MB)
sdb: Write Protect is off
sdb: Mode Sense: cb 00 00 08
SCSI device sdb: drive cache: write through
 sdb: sdb1
sd 1:0:3:0: Attached scsi disk sdb
sd 1:0:3:0: Attached scsi generic sg3 type 0
  Vendor: IBM       Model: ST373453LC        Rev: C51A
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sdc: 143374000 512-byte hdwr sectors (73407 MB)
sdc: Write Protect is off
sdc: Mode Sense: cb 00 10 08
SCSI device sdc: drive cache: write through w/ FUA
SCSI device sdc: 143374000 512-byte hdwr sectors (73407 MB)
sdc: Write Protect is off
sdc: Mode Sense: cb 00 10 08
SCSI device sdc: drive cache: write through w/ FUA
 sdc: sdc1
sd 1:0:5:0: Attached scsi disk sdc
sd 1:0:5:0: Attached scsi generic sg4 type 0
  Vendor: IBM       Model: VSBPD3E   U4SCSI  Rev: 4812
  Type:   Enclosure                          ANSI SCSI revision: 02
 1:0:15:0: Attached scsi generic sg5 type 13
scsi: unknown device type 31
  Vendor: IBM       Model: 570B001           Rev: 0150
  Type:   Unknown                            ANSI SCSI revision: 00
 1:255:255:255: Attached scsi generic sg6 type 31
pata_pdc2027x 0002:d0:01.0: version 0.74-ac5
PCI: Enabling device: (0002:d0:01.0), cmd 3
pata_pdc2027x 0002:d0:01.0: PLL input clock 32760 kHz
ata1: PATA max UDMA/133 cmd 0xD0000800820887C0 ctl 0xD000080082088FDA bmdma 0xD000080082088000 irq 135
ata2: PATA max UDMA/133 cmd 0xD0000800820885C0 ctl 0xD000080082088DDA bmdma 0xD000080082088008 irq 135
scsi2 : pata_pdc2027x
ata1.00: ATAPI, max UDMA/33
ata1.00: configured for UDMA/33
scsi3 : pata_pdc2027x
ATA: abnormal status 0x8 on port 0xD0000800820885DF
  Vendor: IBM       Model: DROM00205         Rev: NR38
  Type:   CD-ROM                             ANSI SCSI revision: 02
 2:0:0:0: Attached scsi generic sg7 type 5
sr0: scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 2:0:0:0: Attached scsi CD-ROM sr0
ReiserFS: sda5: found reiserfs format "3.6" with standard journal
ReiserFS: sda5: using ordered data mode
reiserfs: using flush barriers
ReiserFS: sda5: journal params: device sda5, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
ReiserFS: sda5: checking transaction log (sda5)
ReiserFS: sda5: Using r5 hash to sort names
Adding 1050616k swap on /dev/disk/by-label/vscsi_swap.  Priority:-1 extents:1 across:1050616k
Intel(R) PRO/1000 Network Driver - version 7.6.9.1-NAPI
Copyright (c) 1999-2007 Intel Corporation.
PCI: Enabling device: (0000:d0:01.0), cmd 3
e1000: 0000:d0:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:09:6b:dd:0e:78
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
PCI: Enabling device: (0000:d0:01.1), cmd 3
e1000: 0000:d0:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:09:6b:dd:0e:79
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
PCI: Enabling device: (0001:c0:01.0), cmd 3
e1000: 0001:c0:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:11:25:c0:5a:13
e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
PCI: Enabling device: (0001:c8:01.0), cmd 3
e1000: 0001:c8:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:09:6b:6e:1b:ee
e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
PCI: Enabling device: (0001:c8:01.1), cmd 3
e1000: 0001:c8:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:09:6b:6e:1b:ef
e1000: eth4: e1000_probe: Intel(R) PRO/1000 Network Connection
md: md0 stopped.
device-mapper: 4.7.0-ioctl (2006-06-24) initialised: dm-devel@redhat.com
dm-netlink version 0.0.2 loaded
md: bind<sdc1>
md: bind<sdb1>
md: raid0 personality registered for level 0
md0: setting max_sectors to 64, segment boundary to 16383
raid0: looking at sdb1
raid0:   comparing sdb1(71673856) with sdb1(71673856)
raid0:   END
raid0:   ==> UNIQUE
raid0: 1 zones
raid0: looking at sdc1
raid0:   comparing sdc1(71673856) with sdb1(71673856)
raid0:   EQUAL
raid0: FINAL 1 zones
raid0: done.
raid0 : md_size is 143347712 blocks.
raid0 : conf->hash_spacing is 143347712 blocks.
raid0 : nb_zone is 1.
raid0 : Allocating 8 bytes for hash.
loop: loaded (max 8 devices)
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
ReiserFS: sda6: found reiserfs format "3.6" with standard journal
ReiserFS: sda6: using ordered data mode
reiserfs: using flush barriers
ReiserFS: sda6: journal params: device sda6, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
ReiserFS: sda6: checking transaction log (sda6)
ReiserFS: sda6: Using r5 hash to sort names
AppArmor: AppArmor (version 2.0-19.43r6320) initialized
audit(1200599270.450:2): AppArmor (version 2.0-19.43r6320) initialized

ib_core: module not supported by Novell, setting U taint flag.
ib_mad: module not supported by Novell, setting U taint flag.
ib_mthca: module not supported by Novell, setting U taint flag.
ib_umad: module not supported by Novell, setting U taint flag.
ib_uverbs: module not supported by Novell, setting U taint flag.
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
IPv6 over IPv4 tunneling driver
ib_sa: module not supported by Novell, setting U taint flag.
ib_cm: module not supported by Novell, setting U taint flag.
ib_ipoib: module not supported by Novell, setting U taint flag.
iw_cm: module not supported by Novell, setting U taint flag.
ib_addr: module not supported by Novell, setting U taint flag.
rdma_cm: module not supported by Novell, setting U taint flag.
ib_sdp: module not supported by Novell, setting U taint flag.
NET: Registered protocol family 27
ib_srp: module not supported by Novell, setting U taint flag.
rdma_ucm: module not supported by Novell, setting U taint flag.
ADDRCONF(NETDEV_UP): eth0: link is not ready
e1000: eth0: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
audit(1200599280.383:3): audit_pid=3972 old=0 by auid=4294967295
sd 0:0:4:0: queue not ready for req c000000157bdb2a8
sd 0:0:4:0: queue not ready for req c000000157bdb2a8
sd 0:0:4:0: queue not ready for req c000000156d3b2a8
sd 0:0:4:0: queue not ready for req c000000156d3b2a8
sd 0:0:4:0: queue not ready for req c0000000b35ed2a8
sd 0:0:4:0: queue not ready for req c0000000b35ed2a8
sd 0:0:4:0: queue not ready for req c00000000fc71728
sd 0:0:4:0: queue not ready for req c00000000fc713c8
sd 0:0:4:0: queue not ready for req c000000156082188
sd 0:0:4:0: queue not ready for req c000000156082188
sd 0:0:4:0: queue not ready for req c00000000fc712a8
sd 0:0:4:0: queue not ready for req c00000000fc714e8
sd 0:0:4:0: queue not ready for req c00000000fc714e8
sd 0:0:4:0: queue not ready for req c00000000fc71608
sd 0:0:4:0: queue not ready for req c00000000fc71608
sd 0:0:4:0: queue not ready for req c00000000fd6c848
sd 0:0:4:0: queue not ready for req c00000000fd6c3c8
sd 0:0:4:0: queue not ready for req c00000000fd6c068
sd 0:0:4:0: queue not ready for req c00000000fd6c728
sd 0:0:4:0: queue not ready for req c0000001560824e8
sd 0:0:4:0: queue not ready for req c000000156082968
sd 0:0:4:0: queue not ready for req c000000003364728
sd 0:0:4:0: queue not ready for req c00000000fe41188
sd 0:0:4:0: queue not ready for req c00000000f8e0968

--0F1p//8PRICkK4MW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
