Date: Tue, 23 May 2000 06:08:18 -0400
From: Mike Simons <msimons@moria.simons-clan.com>
Subject: Multiple Disk IDE performance problems...
Message-ID: <20000523060818.A23557@moria.simons-clan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andre@linux-ide.org, Linux Memory Management List <linux-mm@kvack.org>
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi all,

  I've been doing some bonnie benchmarks with the same hard drives on the 
same machine under a few kernels.  I found that a single IDE drive can 
be very fast once tuned with hdparm (23 MBps block I/O).  But when two 
drives on different IDE channels are both used at the same time some 
major bottleneck is hit... performance of *both* drives together is 
just slightly better than one drive by itself.

  - Has anyone else has seen similar problems?
  - What could be limiting the two disk drive performance so much?
    (hardware controller?  IDE disk driver?  kernel I/O system?)
  - Suggestions to improve performance of multi-disk I/O?


  Quintela's VM patches work wonderfully here preventing "VM: killing 
process X", system lockups, and allow bonnie tests to actually run to 
completion (instead of erroring out which started in -pre7).  The system 
is slightly hard to use when heavy disk I/O is happening, but *much* 
better than recent 2.3.* kernels.

  Since 2.3.99-pre* the VM issues aren't solved yet I'm mainly pointing 
this out as an observation so someone can look into heavy disk I/O 
performance in 2.3.* after the VM problems are fixed.

  - Disk _output_ appears to have been affected by the first patch set...
  - With the newest Quintela patch set _output_ is slowed more and block
    _input_ is also being affected.

  This poor performance _could_ be caused by addition swap activity under 
the patched kernels, but I do not have vmstat runs to match all of the 
bonnie tests to verify the swap activity is new and is enough to be 
responsible for the single disk performance losses.  

    Later,
      Mike Simons


  Both drives were initialized at boot via "hdparm -m 16 -u 1 -c 1 -d 1"

  Bonnie++ was found at http://www.coker.com.au/bonnie++/
all tests used "-d . -s 256 -n 0" as the options to bonnie.
"-p 2" and "-y" were used to start the multi-disk tests.

  Quintela's patches as I have applied them are available 
(for a limited time only ;) at http://moria.simons-clan.com/~msimons/


[note: these numbers are not the true average of several runs... 
 they are just the output of a sample run.  the actual averages should
 appear to be within 10% of the numbers shown below which is good enough
 to get the point across.]

Version 1.00a   ------Sequential Output------ --Sequential Input- --Random-
                -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
             MB K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP

2.2.14      ===============================================================
hda         256  7774  97 24267  21 10049  21  8069  95 23229  21  47.5   0
hdc         256  7866  98 22830  20  5702  10  7194  95 18741  15  40.0   0
hda *and*   256  3791  47 11090   9  5684  12  3723  49 13454  11  25.8   0
hdc *and*   256  3869  48 11179   9  5505  12  3705  49 13187  12  25.6   0
===========================================================================

2.3.99-pre9-pre1 + quintela patch set 1 ===================================
hda         256  7621  96 14375  13  8091  12  6616  78 21686  21  42.2   0
hdc         256  7690  97 18216  16  7556  11  6398  84 22133  21  41.1   0
hda *and*   256  3194  40  9984   8  5393   8  3801  50 13266  14  23.5   0
hdc *and*   256  3467  43  9832   8  5381   8  3769  50 13842  14  23.9   0
===========================================================================

2.3.99-pre9-pre3 + quintela patch set 2 ===================================
hda         256  7140  90 16162  14  8179  12  7090  83 20079  19  43.5   0
hdc         256  7432  93 16418  14  6607  10  6646  78 14330  13  39.2   0
hda *and*   256  3540  44  6581   5  5167   7  4025  47 11184  11  24.6   0
hdc *and*   256  3192  40  6582   5  5051   8  4003  47 10440  11  23.4   0
===========================================================================

Machine specs:
  Pentium III 500 Mhz, 128 Megs RAM

from kernel config:
  CONFIG_BLK_DEV_IDEPCI=y
  CONFIG_IDEPCI_SHARE_IRQ=y
  CONFIG_BLK_DEV_IDEDMA_PCI=y
  CONFIG_IDEDMA_PCI_AUTO=y
  CONFIG_BLK_DEV_IDEDMA=y
  CONFIG_IDEDMA_PCI_EXPERIMENTAL=y
  CONFIG_BLK_DEV_PIIX=y
  CONFIG_PIIX_TUNING=y

/proc/interrupts
 14:     100689          XT-PIC  ide0
 15:     115092          XT-PIC  ide1

/proc/ioports
  ffa0-ffaf : Intel Corporation 82371AB PIIX4 IDE
    ffa0-ffa7 : ide0
    ffa8-ffaf : ide1

/proc/pci
  Bus  0, device   0, function  0:
    Host bridge: Intel Corporation 440BX/ZX - 82443BX/ZX Host bridge (rev 3).
      Master Capable.  Latency=64.  
      Prefetchable 32 bit memory at 0xf0000000 [0xf3ffffff].
  Bus  0, device   7, function  1:
    IDE interface: Intel Corporation 82371AB PIIX4 IDE (rev 1).
      Master Capable.  Latency=32.  
      I/O at 0xffa0 [0xffaf].

lspci -vvv:
  00:00.0 Host bridge: Intel Corporation 440BX/ZX - 82443BX/ZX Host bridge \
      (rev 03)
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- \
             ParErr- Stepping- SERR+ FastB2B-
    Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium \
            >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
    Latency: 64 set
    Region 0: Memory at f0000000 (32-bit, prefetchable) [size=64M]
    Capabilities: [a0] AGP version 1.0
        Status: RQ=31 SBA+ 64bit- FW- Rate=21
        Command: RQ=0 SBA- AGP- 64bit- FW- Rate=

  
  00:07.1 IDE interface: Intel Corporation 82371AB PIIX4 IDE (rev 01) \
      (prog-if 80 [Master])
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- \
             ParErr- Stepping- SERR- FastB2B-
    Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium \
            >TAbort- <TAbort- <MAbort- >SERR- <PERR-
    Latency: 32 set
    Region 4: I/O ports at ffa0 [size=16]

from dmesg:
  Uniform Multi-Platform E-IDE driver Revision: 6.30
  ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
  PIIX4: IDE controller on PCI bus 00 dev 39
  PIIX4: chipset revision 1
  PIIX4: not 100% native mode: will probe irqs later
      ide0: BM-DMA at 0xffa0-0xffa7, BIOS settings: hda:DMA, hdb:pio
      ide1: BM-DMA at 0xffa8-0xffaf, BIOS settings: hdc:DMA, hdd:DMA

  hda: WDC WD102BA, ATA DISK drive             (hdparm -i -> FwRev=16.13M16)
  hdc: WDC WD43AA, ATA DISK drive              (hdparm -i -> FwRev=29.05T29)
  hdd: CRD-8400B, ATAPI CDROM drive
  hda: 20028960 sectors (10255 MB) w/2048KiB Cache, CHS=1246/255/63, UDMA(33)
  hdc: 8421840 sectors (4312 MB) w/2048KiB Cache, CHS=8355/16/63, UDMA(33)
  hdd: ATAPI 48X CD-ROM drive, 128kB Cache, UDMA(33)

===========
fizban:/proc/ide# cat piix 

                                Intel PIIX4 Ultra 33 Chipset.
--------------- Primary Channel ---------------- Secondary Channel -------------
                 enabled                          enabled
--------------- drive0 --------- drive1 -------- drive0 ---------- drive1 ------
DMA enabled:    yes              no              yes               yes
UDMA enabled:   yes              no              yes               yes
UDMA enabled:   2                X               2                 2
UDMA
DMA
PIO

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
