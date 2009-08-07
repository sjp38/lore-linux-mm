Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8A6C46B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 11:06:24 -0400 (EDT)
Message-ID: <4A7C42DD.20300@online.de>
Date: Fri, 07 Aug 2009 17:06:05 +0200
From: Juergen Keidel <wizant.keidel@online.de>
Reply-To: wizant.keidel@online.de
MIME-Version: 1.0
Subject: mapping kernel memory from driver to user-space crashes
Content-Type: multipart/mixed;
 boundary="------------060800090304080207060806"
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rusty@rustcorp.com.au
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060800090304080207060806
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

[1.] mapping kernel memory from driver to user-space crashes
[2.] Full description of the problem/report:
Device drivers will map their allocated memory to user-space via mmap,
using the
(.nopage) .fault-method. When doing this, the system goes into different
forms of
crash. When the application starts with writing to the mapped space, the
system
freezes, hard reboot needed, when first access is a read, the page-fault
function
of the driver is called in an endless loop, even if the application is
aborted and
the driver unloaded! A soft reboot is needed.
The detailed effects are different between kmall allocated space,
vmalloc allocated
and get_zeroed_page() allocated, but in each case crashing the system.
This is tested with several drivers, which where running stable before.
The attached example is a dummy driver, used to teach students at
university.

[3.] kernel mmap driver

[4.] Kernel information
[4.1.] Linux version 2.6.27.25-0.1-pae (geeko@buildhost) (gcc version
4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #1 SMP 2009-07-01
15:37:09 +0200
[5.] recent kernel version which did not have the bug: 2.6.27.21
[7.] attached driver + application as .tgz

[8.1.]
keidel@wizant1:/usr/src/linux> sh scripts/ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux wizant1 2.6.27.25-0.1-pae #1 SMP 2009-07-01 15:37:09 +0200 i686
i686 i386                GNU/Linux
 
Gnu C                  4.3
Gnu make               3.81
binutils               11.1
2.19
util-linux             scripts/ver_linux: line 23: fdformat: command not
found
mount                  support
module-init-tools      found
Linux C Library        2.9
Dynamic linker (ldd)   2.9
Procps                 3.2.7
Kbd                    1.14.1
Sh-utils               6.12
udev                   128
Modules Loaded         michael_mic arc4 ecb crypto_blkcipher
ieee80211_crypt_tki               p af_packet binfmt_misc snd_pcm_oss
snd_mixer_oss snd_seq snd_seq_device ipv6 cp              
ufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq
speedstep_li               b fuse reiserfs ext2 loop dm_mod b44
snd_intel8x0m snd_intel8x0 sdhci_pci snd_ac               97_codec ssb
sdhci video yenta_socket ac97_bus output ipw2200 ohci1394
rsrc_nons               tatic pcmcia ieee80211 snd_pcm iTCO_wdt
pcmcia_core mmc_core ieee1394 ieee80211_               crypt mii
snd_timer iTCO_vendor_support usbhid battery ac fglrx i2c_i801
button                snd soundcore rtc_cmos hid intel_agp sr_mod
rtc_core i2c_core rtc_lib snd_page_a               lloc pcspkr joydev
cdrom agpgart serio_raw ff_memless sg sd_mod crc_t10dif
ehci_               hcd uhci_hcd usbcore edd ext3 mbcache jbd fan
ide_pci_generic piix ide_core ata_               generic ata_piix libata
scsi_mod dock thermal processor thermal_sys hwmon
[8.2.] processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 13
model name      : Intel(R) Pentium(R) M processor 1.73GHz
stepping        : 8
cpu MHz         : 800.000
cache size      : 2048 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat clflush dts acpi mmx fxsr sse sse2 ss tm pbe up bts est tm2
bogomips        : 1596.29
clflush size    : 64
power management:
[8.3.] keidel@wizant1:/usr/src/linux> cat /proc/modules
michael_mic 2240 6 - Live 0xf9000000
arc4 1728 6 - Live 0xf8ffe000
ecb 2672 6 - Live 0xf8efe000
crypto_blkcipher 16940 1 ecb, Live 0xf9409000
ieee80211_crypt_tkip 8612 3 - Live 0xf8ffa000
af_packet 16412 2 - Live 0xf93fb000
binfmt_misc 7732 1 - Live 0xf8ff7000
snd_pcm_oss 43024 0 - Live 0xf8e94000
snd_mixer_oss 14288 1 snd_pcm_oss, Live 0xf8e8f000
snd_seq 51924 0 - Live 0xf8eb1000
snd_seq_device 7168 1 snd_seq, Live 0xf8e85000
ipv6 241840 28 - Live 0xf9800000
cpufreq_conservative 6476 0 - Live 0xf93f8000
cpufreq_userspace 3112 0 - Live 0xf93f0000
cpufreq_powersave 1640 0 - Live 0xf93f2000
acpi_cpufreq 6796 0 - Live 0xf93b4000
speedstep_lib 3884 0 - Live 0xf93ee000
fuse 50604 1 - Live 0xf93a6000
reiserfs 216072 3 - Live 0xf93b8000
ext2 60484 1 - Live 0xf92a3000
loop 14064 0 - Live 0xf91fd000
dm_mod 62616 0 - Live 0xf9365000
b44 25976 0 - Live 0xf9285000
snd_intel8x0m 13848 1 - Live 0xf9250000
snd_intel8x0 28352 4 - Live 0xf9255000
sdhci_pci 7444 0 - Live 0xf9202000
snd_ac97_codec 99764 2 snd_intel8x0m,snd_intel8x0, Live 0xf926b000
ssb 38396 1 b44, Live 0xf921a000
sdhci 17108 1 sdhci_pci, Live 0xf9214000
video 20308 0 - Live 0xf920e000
yenta_socket 22884 1 - Live 0xf9207000
ac97_bus 1584 1 snd_ac97_codec, Live 0xf91ec000
output 2736 1 video, Live 0xf91ef000
ipw2200 133252 0 - Live 0xf9227000 (N)
ohci1394 27656 0 - Live 0xf91f5000
rsrc_nonstatic 10936 1 yenta_socket, Live 0xf91ae000
pcmcia 32684 1 ssb, Live 0xf91d8000
ieee80211 26656 1 ipw2200, Live 0xf91e2000
snd_pcm 76904 5 snd_pcm_oss,snd_intel8x0m,snd_intel8x0,snd_ac97_codec,
Live 0xf919a000
iTCO_wdt 10016 0 - Live 0xf915e000
pcmcia_core 33164 4 ssb,yenta_socket,rsrc_nonstatic,pcmcia, Live 0xf917f000
mmc_core 54968 1 sdhci, Live 0xf91c9000
ieee1394 83764 1 ohci1394, Live 0xf91b3000
ieee80211_crypt 5212 2 ieee80211_crypt_tkip,ieee80211, Live 0xf917c000
mii 4968 1 b44, Live 0xf9179000
snd_timer 20204 3 snd_seq,snd_pcm, Live 0xf9164000
iTCO_vendor_support 3368 1 iTCO_wdt, Live 0xf887e000
usbhid 45604 0 - Live 0xf918a000
battery 11176 0 - Live 0xf9156000
ac 4480 0 - Live 0xf9131000
fglrx 2052260 22 - Live 0xf9456000 (PX)
i2c_i801 10508 0 - Live 0xf9127000
button 6568 0 - Live 0xf912e000
snd 56816 17
snd_pcm_oss,snd_mixer_oss,snd_seq,snd_seq_device,snd_intel8x0m,snd_intel8x0,snd_ac97_codec,snd_pcm,snd_timer,
Live 0xf916a000
soundcore 6660 1 snd, Live 0xf912b000
rtc_cmos 10896 0 - Live 0xf911a000
hid 35568 1 usbhid, Live 0xf9143000
intel_agp 24776 0 - Live 0xf914e000
sr_mod 13360 0 - Live 0xf9112000
rtc_core 17384 1 rtc_cmos, Live 0xf913d000
i2c_core 29900 1 i2c_i801, Live 0xf9134000
rtc_lib 2816 1 rtc_core, Live 0xf9011000
snd_page_alloc 8184 3 snd_intel8x0m,snd_intel8x0,snd_pcm, Live 0xf9117000
pcspkr 2344 0 - Live 0xf8852000
joydev 8944 0 - Live 0xf9030000
cdrom 32292 1 sr_mod, Live 0xf911e000
agpgart 32308 2 fglrx,intel_agp, Live 0xf9037000
serio_raw 5092 0 - Live 0xf9034000
ff_memless 7132 1 usbhid, Live 0xf9018000
sg 29408 0 - Live 0xf9109000
sd_mod 31624 9 - Live 0xf9100000
crc_t10dif 1704 1 sd_mod, Live 0xf9013000
ehci_hcd 48160 0 - Live 0xf90f3000
uhci_hcd 23072 0 - Live 0xf901b000
usbcore 165892 4 usbhid,ehci_hcd,uhci_hcd, Live 0xf90a9000
edd 8616 0 - Live 0xf8849000
ext3 123932 3 - Live 0xf90d3000
mbcache 7592 2 ext2,ext3, Live 0xf900e000
jbd 52888 1 ext3, Live 0xf9022000
fan 4712 0 - Live 0xf887b000
ide_pci_generic 3428 0 - Live 0xf8850000
piix 5868 0 - Live 0xf884d000
ide_core 97492 2 ide_pci_generic,piix, Live 0xf9090000
ata_generic 4484 0 - Live 0xf8830000
ata_piix 16652 8 - Live 0xf883f000
libata 160940 2 ata_generic,ata_piix, Live 0xf9067000
scsi_mod 149680 4 sr_mod,sg,sd_mod,libata, Live 0xf9041000
dock 11804 1 libata, Live 0xf8845000
thermal 19976 0 - Live 0xf8835000
processor 43728 3 acpi_cpufreq,thermal, Live 0xf9002000
thermal_sys 11364 4 video,fan,thermal,processor, Live 0xf883b000
hwmon 2916 1 thermal_sys, Live 0xf8833000

[8.4.] keidel@wizant1:/usr/src/linux> cat /proc/ioports
0000-001f : dma1
0020-0021 : pic1
0040-0043 : timer0
0050-0053 : timer1
0060-0060 : keyboard
0064-0064 : keyboard
0070-0077 : rtc0
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : 0000:00:1f.1
  0170-0177 : ata_piix
01f0-01f7 : 0000:00:1f.1
  01f0-01f7 : ata_piix
0376-0376 : 0000:00:1f.1
  0376-0376 : ata_piix
03c0-03df : vesafb
03f6-03f6 : 0000:00:1f.1
  03f6-03f6 : ata_piix
0680-06ff : pnp 00:06
0800-080f : pnp 00:06
0900-090f : pnp 00:06
0cf8-0cff : PCI conf1
1000-107f : 0000:00:1f.0
  1000-107f : pnp 00:06
    1000-1003 : ACPI PM1a_EVT_BLK
    1004-1005 : ACPI PM1a_CNT_BLK
    1008-100b : ACPI PM_TMR
    1010-1015 : ACPI CPU throttle
    1020-1020 : ACPI PM2_CNT_BLK
    1028-102f : ACPI GPE0_BLK
    1060-107f : iTCO_wdt
1180-11bf : 0000:00:1f.0
  1180-11bf : pnp 00:06
1640-164f : pnp 00:06
1800-181f : 0000:00:1d.0
  1800-181f : uhci_hcd
1820-183f : 0000:00:1d.1
  1820-183f : uhci_hcd
1840-185f : 0000:00:1d.2
  1840-185f : uhci_hcd
1860-187f : 0000:00:1d.3
  1860-187f : uhci_hcd
1880-18bf : 0000:00:1e.2
  1880-18bf : Intel ICH6
18c0-18cf : 0000:00:1f.1
  18c0-18cf : ata_piix
18e0-18ff : 0000:00:1f.3
  18e0-18ff : i801_smbus
1c00-1cff : 0000:00:1e.2
  1c00-1cff : Intel ICH6
2000-207f : 0000:00:1e.3
  2000-207f : Intel ICH6 Modem
2400-24ff : 0000:00:1e.3
  2400-24ff : Intel ICH6 Modem
3000-3fff : PCI Bus 0000:01
  3000-30ff : 0000:01:00.0
4000-4fff : PCI Bus 0000:02
5000-5fff : PCI Bus 0000:06
  5000-50ff : PCI CardBus 0000:07
  5400-54ff : PCI CardBus 0000:07

keidel@wizant1:/usr/src/linux> cat /proc/iomem
00000000-0009f7ff : System RAM
0009f800-0009ffff : reserved
000a0000-000bffff : Video RAM area
000c0000-000cffff : Video ROM
000d0000-000d7fff : reserved
  000d0000-000d3fff : Adapter ROM
  000d4000-000d4fff : Adapter ROM
000dc000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-3fe9ffff : System RAM
  00100000-0034dd94 : Kernel code
  0034dd95-005301cf : Kernel data
  00582000-0065445b : Kernel bss
3fea0000-3feb0fff : ACPI Tables
3feb1000-3fefffff : ACPI Non-volatile Storage
3ff00000-3fffffff : reserved
50000000-53ffffff : PCI Bus 0000:06
  50000000-53ffffff : PCI CardBus 0000:07
54000000-57ffffff : PCI CardBus 0000:07
c0000000-c00003ff : 0000:00:1d.7
  c0000000-c00003ff : ehci_hcd
c0000400-c00004ff : 0000:00:1e.2
  c0000400-c00004ff : Intel ICH6
c0000800-c00009ff : 0000:00:1e.2
  c0000800-c00009ff : Intel ICH6
c0100000-c01fffff : PCI Bus 0000:01
  c0100000-c010ffff : 0000:01:00.0
  c0120000-c013ffff : 0000:01:00.0
c4000000-c7ffffff : PCI Bus 0000:02
c8000000-c80fffff : PCI Bus 0000:06
  c8000000-c8000fff : 0000:06:07.0
    c8000000-c8000fff : ipw2200
  c8001000-c80017ff : 0000:06:09.1
    c8001000-c80017ff : ohci1394
  c8001800-c80018ff : 0000:06:09.2
    c8001800-c80018ff : mmc0
  c8001c00-c8001cff : 0000:06:09.3
  c8002000-c80020ff : 0000:06:09.4
  c8003000-c8003fff : 0000:06:09.0
    c8003000-c8003fff : yenta_socket
  c8004000-c8005fff : 0000:06:05.0
    c8004000-c8005fff : 0000:06:05.0
d0000000-d7ffffff : PCI Bus 0000:01
  d0000000-d7ffffff : 0000:01:00.0
    d0000000-d3ffffff : vesafb
d8000000-dbffffff : PCI Bus 0000:02
e0000000-f0005fff : reserved
  e0000000-efffffff : PCI MMCONFIG 0
f0008000-f000bfff : reserved
fed00000-fed003ff : HPET 0
  fed00000-fed003ff : reserved
fed20000-fed8ffff : reserved
fee00000-fee00fff : Local APIC
ff000000-ffffffff : reserved

[8.5.] lspci -vvv
00:00.0 Host bridge: Intel Corporation Mobile 915GM/PM/GMS/910GML
Express Processor to DRAM Controller (rev 03)
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ >SERR- <PERR- INTx-
    Latency: 0
    Capabilities: [e0] Vendor Specific Information <?>
    Kernel modules: intel-agp

00:01.0 PCI bridge: Intel Corporation Mobile 915GM/PM Express PCI
Express Root Port (rev 03) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 32 bytes
    Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
    I/O behind bridge: 00003000-00003fff
    Memory behind bridge: c0100000-c01fffff
    Prefetchable memory behind bridge: d0000000-d7ffffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [88] Subsystem: Samsung Electronics Co Ltd Device b035
    Capabilities: [80] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [90] Message Signalled Interrupts: Mask- 64bit-
Count=1/1 Enable+
        Address: fee0100c  Data: 41c1
    Capabilities: [a0] Express (v1) Root Port (Slot+), MSI 00
        DevCap:    MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns,
L1 <1us
            ExtTag- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
            MaxPayload 128 bytes, MaxReadReq 128 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-
TransPend-
        LnkCap:    Port #2, Speed 2.5GT/s, Width x16, ASPM L0s L1,
Latency L0 <256ns, L1 <4us
            ClockPM- Suprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
            Slot #  1, PowerLimit 75.000000; Interlock- NoCompl-
        SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt-
HPIrq- LinkChg-
            Control: AttnInd Off, PwrInd On, Power- Interlock-
        SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+
Interlock-
            Changed: MRL- PresDet+ LinkState-
        RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna-
CRSVisible-
        RootCap: CRSVisible-
        RootSta: PME ReqID 0000, PMEStatus- PMEPending-
    Capabilities: [100] Virtual Channel <?>
    Capabilities: [140] Root Complex Link <?>
    Kernel driver in use: pcieport-driver
    Kernel modules: shpchp

00:1c.0 PCI bridge: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6
Family) PCI Express Port 1 (rev 03) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 32 bytes
    Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
    I/O behind bridge: 00004000-00004fff
    Memory behind bridge: c4000000-c7ffffff
    Prefetchable memory behind bridge: 00000000d8000000-00000000dbffffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
        DevCap:    MaxPayload 128 bytes, PhantFunc 0, Latency L0s
unlimited, L1 unlimited
            ExtTag+ RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
            MaxPayload 128 bytes, MaxReadReq 128 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+
TransPend-
        LnkCap:    Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <1us, L1 <4us
            ClockPM- Suprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
            Slot #  2, PowerLimit 6.500000; Interlock- NoCompl-
        SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt-
HPIrq- LinkChg-
            Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
        SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet-
Interlock-
            Changed: MRL- PresDet- LinkState-
        RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna-
CRSVisible-
        RootCap: CRSVisible-
        RootSta: PME ReqID 0000, PMEStatus- PMEPending-
    Capabilities: [80] Message Signalled Interrupts: Mask- 64bit-
Count=1/1 Enable+
        Address: fee0100c  Data: 41c9
    Capabilities: [90] Subsystem: Samsung Electronics Co Ltd Device b035
    Capabilities: [a0] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [100] Virtual Channel <?>
    Capabilities: [180] Root Complex Link <?>
    Kernel driver in use: pcieport-driver
    Kernel modules: shpchp

00:1d.0 USB Controller: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6
Family) USB UHCI #1 (rev 03) (prog-if 00 [UHCI])
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 23
    Region 4: I/O ports at 1800 [size=32]
    Kernel driver in use: uhci_hcd
    Kernel modules: uhci-hcd

00:1d.1 USB Controller: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6
Family) USB UHCI #2 (rev 03) (prog-if 00 [UHCI])
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin B routed to IRQ 19
    Region 4: I/O ports at 1820 [size=32]
    Kernel driver in use: uhci_hcd
    Kernel modules: uhci-hcd

00:1d.2 USB Controller: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6
Family) USB UHCI #3 (rev 03) (prog-if 00 [UHCI])
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin C routed to IRQ 18
    Region 4: I/O ports at 1840 [size=32]
    Kernel driver in use: uhci_hcd
    Kernel modules: uhci-hcd

00:1d.3 USB Controller: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6
Family) USB UHCI #4 (rev 03) (prog-if 00 [UHCI])
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin D routed to IRQ 16
    Region 4: I/O ports at 1860 [size=32]
    Kernel driver in use: uhci_hcd
    Kernel modules: uhci-hcd

00:1d.7 USB Controller: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6
Family) USB2 EHCI Controller (rev 03) (prog-if 20 [EHCI])
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 23
    Region 0: Memory at c0000000 (32-bit, non-prefetchable) [size=1K]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [58] Debug port: BAR=1 offset=00a0
    Kernel driver in use: ehci_hcd
    Kernel modules: ehci-hcd

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev d3)
(prog-if 01 [Subtractive decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Bus: primary=00, secondary=06, subordinate=0a, sec-latency=32
    I/O behind bridge: 00005000-00005fff
    Memory behind bridge: c8000000-c80fffff
    Prefetchable memory behind bridge: 0000000050000000-0000000053ffffff
    Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [50] Subsystem: Gammagraphx, Inc. (or missing ID)
Device 0000

00:1e.2 Multimedia audio controller: Intel Corporation
82801FB/FBM/FR/FW/FRW (ICH6 Family) AC'97 Audio Controller (rev 03)
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 17
    Region 0: I/O ports at 1c00 [size=256]
    Region 1: I/O ports at 1880 [size=64]
    Region 2: Memory at c0000800 (32-bit, non-prefetchable) [size=512]
    Region 3: Memory at c0000400 (32-bit, non-prefetchable) [size=256]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Kernel driver in use: Intel ICH
    Kernel modules: snd-intel8x0

00:1e.3 Modem: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family)
AC'97 Modem Controller (rev 03) (prog-if 00 [Generic])
    Subsystem: Samsung Electronics Co Ltd Device 2115
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin B routed to IRQ 20
    Region 0: I/O ports at 2400 [size=256]
    Region 1: I/O ports at 2000 [size=128]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Kernel driver in use: Intel ICH Modem
    Kernel modules: snd-intel8x0m

00:1f.0 ISA bridge: Intel Corporation 82801FBM (ICH6M) LPC Interface
Bridge (rev 03)
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Kernel modules: iTCO_wdt, intel-rng

00:1f.1 IDE interface: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6
Family) IDE Controller (rev 03) (prog-if 8a [Master SecP PriP])
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 18
    Region 0: I/O ports at 01f0 [size=8]
    Region 1: I/O ports at 03f4 [size=1]
    Region 2: I/O ports at 0170 [size=8]
    Region 3: I/O ports at 0374 [size=1]
    Region 4: I/O ports at 18c0 [size=16]
    Kernel driver in use: ata_piix
    Kernel modules: piix, ata_piix

00:1f.3 SMBus: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family)
SMBus Controller (rev 03)
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Interrupt: pin B routed to IRQ 19
    Region 4: I/O ports at 18e0 [size=32]
    Kernel driver in use: i801_smbus
    Kernel modules: i2c-i801

01:00.0 VGA compatible controller: ATI Technologies Inc M22 [Mobility
Radeon X300] (prog-if 00 [VGA controller])
    Subsystem: Samsung Electronics Co Ltd Device e000
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 32 bytes
    Interrupt: pin A routed to IRQ 16
    Region 0: Memory at d0000000 (32-bit, prefetchable) [size=128M]
    Region 1: I/O ports at 3000 [size=256]
    Region 2: Memory at c0100000 (32-bit, non-prefetchable) [size=64K]
    [virtual] Expansion ROM at c0120000 [disabled] [size=128K]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [58] Express (v1) Endpoint, MSI 00
        DevCap:    MaxPayload 128 bytes, PhantFunc 0, Latency L0s
<256ns, L1 <4us
            ExtTag+ AttnBtn- AttnInd- PwrInd- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
            RlxdOrd+ ExtTag+ PhantFunc- AuxPwr- NoSnoop+
            MaxPayload 128 bytes, MaxReadReq 128 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-
TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1,
Latency L0 <256ns, L1 <2us
            ClockPM- Suprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
    Capabilities: [80] Message Signalled Interrupts: Mask- 64bit+
Count=1/1 Enable-
        Address: 0000000000000000  Data: 0000
    Capabilities: [100] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
RxOF- MalfTLP- ECRC- UnsupReq- ACSVoil-
        UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
RxOF- MalfTLP- ECRC- UnsupReq- ACSVoil-
        UESvrt:    DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt-
RxOF+ MalfTLP+ ECRC- UnsupReq- ACSVoil-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
        AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
    Kernel driver in use: fglrx_pci
    Kernel modules: fglrx, radeonfb

06:05.0 Ethernet controller: Broadcom Corporation BCM4401-B0 100Base-TX
(rev 02)
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 32
    Interrupt: pin A routed to IRQ 22
    Region 0: Memory at c8004000 (32-bit, non-prefetchable) [size=8K]
    Capabilities: [40] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=2 PME-
    Kernel driver in use: b44
    Kernel modules: b44

06:07.0 Network controller: Intel Corporation PRO/Wireless 2200BG
[Calexico2] Network Connection (rev 05)
    Subsystem: Intel Corporation Samsung P35 integrated WLAN
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 32 (750ns min, 6000ns max), Cache Line Size: 32 bytes
    Interrupt: pin A routed to IRQ 20
    Region 0: Memory at c8000000 (32-bit, non-prefetchable) [size=4K]
    Capabilities: [dc] Power Management version 2
        Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=1 PME-
    Kernel driver in use: ipw2200
    Kernel modules: ipw2200

06:09.0 CardBus bridge: Ricoh Co Ltd RL5c476 II (rev b3)
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 168
    Interrupt: pin A routed to IRQ 16
    Region 0: Memory at c8003000 (32-bit, non-prefetchable) [size=4K]
    Bus: primary=06, secondary=07, subordinate=0a, sec-latency=176
    Memory window 0: 50000000-53fff000 (prefetchable)
    Memory window 1: 54000000-57fff000
    I/O window 0: 00005000-000050ff
    I/O window 1: 00005400-000054ff
    BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset- 16bInt+ PostWrite+
    16-bit legacy interface ports at 0001
    Kernel driver in use: yenta_cardbus
    Kernel modules: yenta_socket

06:09.1 FireWire (IEEE 1394): Ricoh Co Ltd R5C552 IEEE 1394 Controller
(rev 08) (prog-if 10 [OHCI])
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64 (500ns min, 1000ns max)
    Interrupt: pin B routed to IRQ 17
    Region 0: Memory at c8001000 (32-bit, non-prefetchable) [size=2K]
    Capabilities: [dc] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=2 PME+
    Kernel driver in use: ohci1394
    Kernel modules: ohci1394

06:09.2 SD Host controller: Ricoh Co Ltd R5C822 SD/SDIO/MMC/MS/MSPro
Host Adapter (rev 17)
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 32
    Interrupt: pin C routed to IRQ 18
    Region 0: Memory at c8001800 (32-bit, non-prefetchable) [size=256]
    Capabilities: [80] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=2 PME-
    Kernel driver in use: sdhci-pci
    Kernel modules: sdhci-pci

06:09.3 System peripheral: Ricoh Co Ltd R5C592 Memory Stick Bus Host
Adapter (rev 08)
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Interrupt: pin C routed to IRQ 255
    Region 0: Memory at c8001c00 (32-bit, non-prefetchable) [size=256]
    Capabilities: [80] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=2 PME-

06:09.4 System peripheral: Ricoh Co Ltd xD-Picture Card Controller (rev 03)
    Subsystem: Samsung Electronics Co Ltd Device b035
    Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Interrupt: pin C routed to IRQ 255
    Region 0: Memory at c8002000 (32-bit, non-prefetchable) [size=256]
    Capabilities: [80] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=2 PME-
        
[8.6.] cat /proc/scsi/scsi
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: FUJITSU MHV2080A Rev: 0000
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi0 Channel: 00 Id: 01 Lun: 00
  Vendor: TEAC     Model: DV-W28EA         Rev: S.0A
  Type:   CD-ROM                           ANSI  SCSI revision: 05



--------------060800090304080207060806
Content-Type: application/x-compressed-tar;
 name="mmap_problem.tgz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="mmap_problem.tgz"

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

--------------060800090304080207060806--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
