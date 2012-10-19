Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 7A0916B00A7
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:51:02 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id k6so477914lbo.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 07:51:00 -0700 (PDT)
Date: Fri, 19 Oct 2012 20:50:55 +0600
From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup" (xfrm)
 in 3.5+ kernels
Message-ID: <20121019205055.2b258d09@sacrilege>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/=zTb78BcsR/.bKSuZHQNMfx"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: paul@paul-moore.com, netdev@vger.kernel.org

--Sig_/=zTb78BcsR/.bKSuZHQNMfx
Content-Type: multipart/mixed; boundary="MP_/1ApBtlCwpXP4l0kRHUq_A8X"

--MP_/1ApBtlCwpXP4l0kRHUq_A8X
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Good day,

There seem to be a large slab memory leak in standard (kernel.org)
kernel with the specific configuration and workload I have here.
=46rom what I can tell at the moment, it appears to be a leak in
IPSec-related xfrm code.


It was really noticeable on several different physical machines
with same kernel configuration but different worloads since I've
upgraded to kernel 3.5.0.

Graph of total slab usage (+ total available RAM) on these machines:

  http://i.imgur.com/IyPqA.png

Presence of some leak can clearly be seen over time, and it caused
near-OOM condition several times now.
Sharp drops in memory usage indicates reboot, which, I'm afraid, with
such condition, has to be done at the regular intervals.

Initially I thought that it was triggered by heavy filesystem load, but
today finally got around to reboot one of the machines with
slub_debug=3DU and it doesn't seem to be the case.

slabtop showed "kmalloc-64" being the 99% offender in the past, but
with recent kernels (3.6.1), it has changed to "secpath_cache",
alloc_calls in /sys/kernel/slab/secpath_cache/ lists only the following:

  2779138 secpath_dup+0x1b/0x5a age=3D400/169538/326767 pid=3D0-1543 cpus=
=3D0-3

And free_calls lists these two lines:

  2543886 <not-available> age=3D4295223985 pid=3D0 cpus=3D0
  235252 __secpath_destroy+0x3e/0x43 age=3D1651/174629/327902 pid=3D0-1519 =
cpus=3D0-3

Contents of all paths available in /sys/kernel/slab/secpath_cache/
and "slabtop -o" output should be attached to this mail.
These were taken after heavy network + fs i/o load (rsync from a
different machine over network) after ~10-20min.

"secpath_dup" seem to be ipsec-related call, and all machines in
question communicate over IPSec almost exclusively all the time
(openswan-2.6.37 userspace at the moment).

As noted, the problem is highly reproducible - all I have to do is to
run rsync or something similar between these nodes for a few minutes.
All machines in question have x86_64 kernel 3.6.1 now, but I'll
probably update it to 3.6.2 in a moment.


Keywords:
linux kernel networking mm slub slab secpath_dup secpath_cache xfrm
ipsec 3.5 3.6 memory leak oom slabtop x86 x86_64 amd64


/proc/version:=20
  Linux version 3.6.1-fg.mf_master (root@anathema) (gcc version 4.6.3
  (Exherbo gcc-4.6.3-r1) ) #1 SMP Sat Oct 13 04:21:08 YEKT 2012

Other information about the system (as per REPORTING-BUGS) is
attached, also including slabtop and slub_debug-related /sys paths
output/contents.


--=20
Mike Kazantsev // fraggod.net

--MP_/1ApBtlCwpXP4l0kRHUq_A8X
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=cpuinfo.txt

processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 28
model name	: Intel(R) Atom(TM) CPU D510   @ 1.66GHz
stepping	: 10
microcode	: 0x107
cpu MHz		: 1666.683
cache size	: 512 KB
physical id	: 0
siblings	: 4
core id		: 0
cpu cores	: 2
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat =
pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constan=
t_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 monitor ds_=
cpl tm2 ssse3 cx16 xtpr pdcm movbe lahf_lm dtherm
bogomips	: 3334.25
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 28
model name	: Intel(R) Atom(TM) CPU D510   @ 1.66GHz
stepping	: 10
microcode	: 0x107
cpu MHz		: 1666.683
cache size	: 512 KB
physical id	: 0
siblings	: 4
core id		: 0
cpu cores	: 2
apicid		: 1
initial apicid	: 1
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat =
pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constan=
t_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 monitor ds_=
cpl tm2 ssse3 cx16 xtpr pdcm movbe lahf_lm dtherm
bogomips	: 3334.25
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 2
vendor_id	: GenuineIntel
cpu family	: 6
model		: 28
model name	: Intel(R) Atom(TM) CPU D510   @ 1.66GHz
stepping	: 10
microcode	: 0x107
cpu MHz		: 1666.683
cache size	: 512 KB
physical id	: 0
siblings	: 4
core id		: 1
cpu cores	: 2
apicid		: 2
initial apicid	: 2
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat =
pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constan=
t_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 monitor ds_=
cpl tm2 ssse3 cx16 xtpr pdcm movbe lahf_lm dtherm
bogomips	: 3334.25
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 3
vendor_id	: GenuineIntel
cpu family	: 6
model		: 28
model name	: Intel(R) Atom(TM) CPU D510   @ 1.66GHz
stepping	: 10
microcode	: 0x107
cpu MHz		: 1666.683
cache size	: 512 KB
physical id	: 0
siblings	: 4
core id		: 1
cpu cores	: 2
apicid		: 3
initial apicid	: 3
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat =
pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constan=
t_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 monitor ds_=
cpl tm2 ssse3 cx16 xtpr pdcm movbe lahf_lm dtherm
bogomips	: 3334.25
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:


--MP_/1ApBtlCwpXP4l0kRHUq_A8X
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=iomem.txt

00000000-0000ffff : reserved
00010000-0008efff : System RAM
0008f000-0008ffff : reserved
00090000-0009ebff : System RAM
0009ec00-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000c7fff : Video ROM
000ce000-000ce7ff : Adapter ROM
000e0000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-3eebcfff : System RAM
  01000000-014dfd69 : Kernel code
  014dfd6a-018613bf : Kernel data
  018f2000-0198bfff : Kernel bss
3eebd000-3eebefff : reserved
3eebf000-3ef46fff : System RAM
3ef47000-3efbefff : ACPI Non-volatile Storage
3efbf000-3eff0fff : System RAM
3eff1000-3effefff : ACPI Tables
3efff000-3effffff : System RAM
3f000000-3fffffff : reserved
d0000000-f7ffffff : PCI Bus 0000:00
  d0000000-d04fffff : PCI Bus 0000:01
  d0500000-d06fffff : PCI Bus 0000:02
  d0700000-d08fffff : PCI Bus 0000:02
  d0900000-d0afffff : PCI Bus 0000:03
  d0b00000-d0cfffff : PCI Bus 0000:03
  d0d00000-d0efffff : PCI Bus 0000:04
  d0f00000-d10fffff : PCI Bus 0000:04
  e0000000-efffffff : 0000:00:02.0
  f0000000-f00fffff : PCI Bus 0000:01
    f0000000-f0003fff : 0000:01:00.0
      f0000000-f0003fff : r8169
    f0004000-f0004fff : 0000:01:00.0
      f0004000-f0004fff : r8169
    f0020000-f003ffff : 0000:01:00.0
  f0100000-f01fffff : PCI Bus 0000:05
    f0100000-f01000ff : 0000:05:00.0
      f0100000-f01000ff : via-rhine
  f0200000-f02fffff : 0000:00:02.0
  f0300000-f037ffff : 0000:00:02.0
  f0380000-f0383fff : 0000:00:1b.0
    f0380000-f0383fff : ICH HD audio
  f0384000-f03843ff : 0000:00:1f.2
    f0384000-f03843ff : ahci
  f0384400-f03847ff : 0000:00:1d.7
    f0384400-f03847ff : ehci_hcd
f8000000-fbffffff : PCI MMCONFIG 0000 [bus 00-3f]
  f8000000-fbffffff : reserved
    f8000000-fbffffff : pnp 00:01
fec00000-fec003ff : IOAPIC 0
fed00000-fed003ff : HPET 0
fed14000-fed17fff : pnp 00:01
fed18000-fed18fff : pnp 00:01
fed19000-fed19fff : pnp 00:01
fed1c000-fed1ffff : pnp 00:01
fee00000-fee00fff : Local APIC
fff00000-ffffffff : reserved
  fff00000-ffffffff : pnp 00:01

--MP_/1ApBtlCwpXP4l0kRHUq_A8X
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=ioports.txt

0000-0cf7 : PCI Bus 0000:00
  0000-001f : dma1
  0020-0021 : pic1
  0040-0043 : timer0
  0050-0053 : timer1
  0060-0060 : keyboard
  0064-0064 : keyboard
  0070-0071 : rtc0
  0080-008f : dma page reg
  00a0-00a1 : pic2
  00c0-00df : dma2
  00f0-00ff : fpu
  0295-0296 : w83627hf
    0295-0296 : w83627hf
  0378-037a : parport0
  03c0-03df : vga+
  0400-047f : pnp 00:06
    0400-0403 : ACPI PM1a_EVT_BLK
    0404-0405 : ACPI PM1a_CNT_BLK
    0408-040b : ACPI PM_TMR
    0410-0415 : ACPI CPU throttle
    0420-0420 : ACPI PM2_CNT_BLK
    0428-042f : ACPI GPE0_BLK
  0500-053f : pnp 00:06
  0680-06ff : pnp 00:06
0cf8-0cff : PCI conf1
0d00-ffff : PCI Bus 0000:00
  1000-1fff : PCI Bus 0000:05
    1000-10ff : 0000:05:00.0
      1000-10ff : via-rhine
  2000-2fff : PCI Bus 0000:01
    2000-20ff : 0000:01:00.0
      2000-20ff : r8169
  3000-301f : 0000:00:1f.3
    3000-301f : i801_smbus
  3020-303f : 0000:00:1d.3
    3020-303f : uhci_hcd
  3040-305f : 0000:00:1d.2
    3040-305f : uhci_hcd
  3060-307f : 0000:00:1d.1
    3060-307f : uhci_hcd
  3080-309f : 0000:00:1d.0
    3080-309f : uhci_hcd
  30a0-30af : 0000:00:1f.2
    30a0-30af : ahci
  30b0-30b7 : 0000:00:1f.2
    30b0-30b7 : ahci
  30b8-30bf : 0000:00:1f.2
    30b8-30bf : ahci
  30c0-30c7 : 0000:00:02.0
  30c8-30cb : 0000:00:1f.2
    30c8-30cb : ahci
  30cc-30cf : 0000:00:1f.2
    30cc-30cf : ahci
  4000-4fff : PCI Bus 0000:02
  5000-5fff : PCI Bus 0000:03
  6000-6fff : PCI Bus 0000:04

--MP_/1ApBtlCwpXP4l0kRHUq_A8X
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=lspci.txt

00:00.0 Host bridge: Intel Corporation Atom Processor D4xx/D5xx/N4xx/N5xx D=
MI Bridge (rev 02)
	Subsystem: Intel Corporation DeskTop Board D510MO
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=3D08 <?>

00:02.0 VGA compatible controller: Intel Corporation Atom Processor D4xx/D5=
xx/N4xx/N5xx Integrated Graphics Controller (rev 02) (prog-if 00 [VGA contr=
oller])
	Subsystem: Intel Corporation DeskTop Board D510MO
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f0300000 (32-bit, non-prefetchable) [size=3D512K]
	Region 1: I/O ports at 30c0 [size=3D8]
	Region 2: Memory at e0000000 (32-bit, prefetchable) [size=3D256M]
	Region 3: Memory at f0200000 (32-bit, non-prefetchable) [size=3D1M]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [90] MSI: Enable- Count=3D1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-

00:1b.0 Audio device: Intel Corporation N10/ICH 7 Family High Definition Au=
dio Controller (rev 01)
	Subsystem: Intel Corporation DeskTop Board D510MO
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 46
	Region 0: Memory at f0380000 (64-bit, non-prefetchable) [size=3D16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D55mA PME(D0+,D1-,D2-,D3hot+,D3co=
ld+)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [60] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
		Address: 00000000fee0f00c  Data: 4152
	Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 <64ns,=
 L1 <1us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- BWMgmt-=
 ABWMgmt-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=3DFixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=3D1 ArbSelect=3DFixed TC/VC=3D80
			Status:	NegoPending- InProgress-
	Capabilities: [130 v1] Root Complex Link
		Desc:	PortNumber=3D0f ComponentID=3D02 EltType=3DConfig
		Link0:	Desc:	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DM=
emMapped LinkValid+
			Addr:	00000000fed1c000
	Kernel driver in use: snd_hda_intel
	Kernel modules: snd-hda-intel

00:1c.0 PCI bridge: Intel Corporation N10/ICH 7 Family PCI Express Port 1 (=
rev 01) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=3D0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: d0000000-d04fffff
	Prefetchable memory behind bridge: 00000000f0000000-00000000f00fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unli=
mited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns,=
 L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt-=
 ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #1, PowerLimit 10.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 4191
	Capabilities: [90] Subsystem: Intel Corporation Device 4f4d
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3col=
d+)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=3DFixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=3D01 ComponentID=3D02 EltType=3DConfig
		Link0:	Desc:	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DM=
emMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1c.1 PCI bridge: Intel Corporation N10/ICH 7 Family PCI Express Port 2 (=
rev 01) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latency=3D0
	I/O behind bridge: 00004000-00004fff
	Memory behind bridge: d0500000-d06fffff
	Prefetchable memory behind bridge: 00000000d0700000-00000000d08fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unli=
mited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L=
1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #2, PowerLimit 10.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 41a1
	Capabilities: [90] Subsystem: Intel Corporation Device 4f4d
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3col=
d+)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=3DFixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=3D02 ComponentID=3D02 EltType=3DConfig
		Link0:	Desc:	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DM=
emMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1c.2 PCI bridge: Intel Corporation N10/ICH 7 Family PCI Express Port 3 (=
rev 01) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=3D00, secondary=3D03, subordinate=3D03, sec-latency=3D0
	I/O behind bridge: 00005000-00005fff
	Memory behind bridge: d0900000-d0afffff
	Prefetchable memory behind bridge: 00000000d0b00000-00000000d0cfffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unli=
mited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L=
1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #3, PowerLimit 10.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 41b1
	Capabilities: [90] Subsystem: Intel Corporation Device 4f4d
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3col=
d+)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=3DFixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=3D03 ComponentID=3D02 EltType=3DConfig
		Link0:	Desc:	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DM=
emMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1c.3 PCI bridge: Intel Corporation N10/ICH 7 Family PCI Express Port 4 (=
rev 01) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=3D00, secondary=3D04, subordinate=3D04, sec-latency=3D0
	I/O behind bridge: 00006000-00006fff
	Memory behind bridge: d0d00000-d0efffff
	Prefetchable memory behind bridge: 00000000d0f00000-00000000d10fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unli=
mited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L=
1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #4, PowerLimit 10.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 41c1
	Capabilities: [90] Subsystem: Intel Corporation Device 4f4d
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3col=
d+)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=3DFixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=3D04 ComponentID=3D02 EltType=3DConfig
		Link0:	Desc:	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DM=
emMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1d.0 USB controller: Intel Corporation N10/ICH 7 Family USB UHCI Control=
ler #1 (rev 01) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation DeskTop Board D510MO
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at 3080 [size=3D32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd

00:1d.1 USB controller: Intel Corporation N10/ICH 7 Family USB UHCI Control=
ler #2 (rev 01) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation DeskTop Board D510MO
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 3060 [size=3D32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd

00:1d.2 USB controller: Intel Corporation N10/ICH 7 Family USB UHCI Control=
ler #3 (rev 01) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation DeskTop Board D510MO
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 3040 [size=3D32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd

00:1d.3 USB controller: Intel Corporation N10/ICH 7 Family USB UHCI Control=
ler #4 (rev 01) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation DeskTop Board D510MO
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 16
	Region 4: I/O ports at 3020 [size=3D32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd

00:1d.7 USB controller: Intel Corporation N10/ICH 7 Family USB2 EHCI Contro=
ller (rev 01) (prog-if 20 [EHCI])
	Subsystem: Intel Corporation DeskTop Board D510MO
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at f0384400 (32-bit, non-prefetchable) [size=3D1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375mA PME(D0+,D1-,D2-,D3hot+,D3c=
old+)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [58] Debug port: BAR=3D1 offset=3D00a0
	Kernel driver in use: ehci_hcd

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev e1) (pro=
g-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=3D00, secondary=3D05, subordinate=3D05, sec-latency=3D0
	I/O behind bridge: 00001000-00001fff
	Memory behind bridge: f0100000-f01fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Intel Corporation Device 4f4d

00:1f.0 ISA bridge: Intel Corporation NM10 Family LPC Controller (rev 01)
	Subsystem: Intel Corporation DeskTop Board D510MO
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=3D0c <?>

00:1f.2 SATA controller: Intel Corporation N10/ICH7 Family SATA Controller =
[AHCI mode] (rev 01) (prog-if 01 [AHCI 1.0])
	Subsystem: Intel Corporation DeskTop Board D510MO
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 44
	Region 0: I/O ports at 30b8 [size=3D8]
	Region 1: I/O ports at 30cc [size=3D4]
	Region 2: I/O ports at 30b0 [size=3D8]
	Region 3: I/O ports at 30c8 [size=3D4]
	Region 4: I/O ports at 30a0 [size=3D16]
	Region 5: Memory at f0384000 (32-bit, non-prefetchable) [size=3D1K]
	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 41d1
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot+,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: ahci

00:1f.3 SMBus: Intel Corporation N10/ICH 7 Family SMBus Controller (rev 01)
	Subsystem: Intel Corporation DeskTop Board D510MO
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 3000 [size=3D32]
	Kernel driver in use: i801_smbus
	Kernel modules: i2c-i801

01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B =
PCI Express Gigabit Ethernet controller (rev 03)
	Subsystem: Intel Corporation Desktop Board D510MO
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 45
	Region 0: I/O ports at 2000 [size=3D256]
	Region 2: Memory at f0004000 (64-bit, prefetchable) [size=3D4K]
	Region 4: Memory at f0000000 (64-bit, prefetchable) [size=3D16K]
	Expansion ROM at f0020000 [disabled] [size=3D128K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0+,D1+,D2+,D3hot+,D3c=
old+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [50] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
		Address: 00000000fee0f00c  Data: 41e1
	Capabilities: [70] Express (v2) Endpoint, MSI 01
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns,=
 L1 <64us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF Not S=
upported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabl=
ed
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- Compl=
ianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, Equaliza=
tionPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [ac] MSI-X: Enable- Count=3D4 Masked-
		Vector table: BAR=3D4 offset=3D00000000
		PBA: BAR=3D4 offset=3D00000800
	Capabilities: [cc] Vital Product Data
		Unknown small resource type 00, will not decode more.
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- =
ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- =
ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+=
 ECRC- UnsupReq- ACSViol-
		CESta:	RxErr+ BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140 v1] Virtual Channel
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=3DFixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 03-00-00-00-68-4c-e0-00
	Kernel driver in use: r8169

05:00.0 Ethernet controller: VIA Technologies, Inc. VT6105/VT6106S [Rhine-I=
II] (rev 8b)
	Subsystem: D-Link System Inc Device 1405
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Steppi=
ng+ SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 32 (750ns min, 2000ns max), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 21
	Region 0: I/O ports at 1000 [size=3D256]
	Region 1: Memory at f0100000 (32-bit, non-prefetchable) [size=3D256]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D3col=
d+)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: via-rhine
	Kernel modules: via-rhine


--MP_/1ApBtlCwpXP4l0kRHUq_A8X
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=modules.txt

nfsv4 142867 2 - Live 0xffffffffa02c9000
crypto_null 2468 0 - Live 0xffffffffa02c5000
camellia_generic 18121 0 - Live 0xffffffffa02bd000
camellia_x86_64 43731 0 - Live 0xffffffffa02af000
cast6 8321 0 - Live 0xffffffffa02a9000
cast5 14309 0 - Live 0xffffffffa02a2000
cts 3664 0 - Live 0xffffffffa029e000
gcm 10963 0 - Live 0xffffffffa0297000
ccm 6870 0 - Live 0xffffffffa0292000
twofish_generic 6065 0 - Live 0xffffffffa0280000
xcbc 2285 0 - Live 0xffffffffa026f000
ah6 4896 0 - Live 0xffffffffa026a000
ah4 4552 0 - Live 0xffffffffa0265000
esp6 5009 16 - Live 0xffffffffa0260000
esp4 5309 18 - Live 0xffffffffa025b000
xfrm4_mode_beet 1731 0 - Live 0xffffffffa0257000
xfrm4_tunnel 1633 0 - Live 0xffffffffa0253000
tunnel4 1949 1 xfrm4_tunnel, Live 0xffffffffa024f000
xfrm4_mode_tunnel 2060 0 - Live 0xffffffffa024b000
xfrm4_mode_transport 1186 36 - Live 0xffffffffa0247000
xfrm6_mode_transport 1250 32 - Live 0xffffffffa0243000
xfrm6_mode_ro 1062 0 - Live 0xffffffffa023f000
xfrm6_mode_beet 1618 0 - Live 0xffffffffa023b000
xfrm6_mode_tunnel 1544 0 - Live 0xffffffffa0237000
ipcomp 1772 0 - Live 0xffffffffa0233000
ipcomp6 1788 0 - Live 0xffffffffa022f000
xfrm_ipcomp 3191 2 ipcomp,ipcomp6, Live 0xffffffffa022b000
xfrm6_tunnel 2935 1 ipcomp6, Live 0xffffffffa0227000
tunnel6 1864 1 xfrm6_tunnel, Live 0xffffffffa0223000
xt_policy 2098 4 - Live 0xffffffffa021f000
xt_pkttype 947 6 - Live 0xffffffffa021b000
xt_recent 7118 2 - Live 0xffffffffa0215000
w83627hf 18739 0 - Live 0xffffffffa020b000
hwmon_vid 1916 1 w83627hf, Live 0xffffffffa0207000
nfsd 201168 11 - Live 0xffffffffa0187000
tcp_lp 1642 0 - Live 0xffffffffa0183000
tun 13568 0 - Live 0xffffffffa017b000
nfs_acl 1959 1 nfsd, Live 0xffffffffa0177000
auth_rpcgss 26056 2 nfsv4,nfsd, Live 0xffffffffa016b000
nfs 104535 3 nfsv4, Live 0xffffffffa0142000
snd_hda_codec_realtek 48800 1 - Live 0xffffffffa012f000
fscache 24055 1 nfs, Live 0xffffffffa0123000
lockd 52521 2 nfsd,nfs, Live 0xffffffffa010f000
snd_hda_intel 19431 0 - Live 0xffffffffa0105000
snd_hda_codec 64188 2 snd_hda_codec_realtek,snd_hda_intel, Live 0xffffffffa=
00ec000
snd_hwdep 4734 1 snd_hda_codec, Live 0xffffffffa00e7000
sunrpc 146486 35 nfsv4,nfsd,nfs_acl,auth_rpcgss,nfs,lockd, Live 0xffffffffa=
00b1000
uhci_hcd 17432 0 - Live 0xffffffffa0093000
via_rhine 17698 0 - Live 0xffffffffa0083000
i2c_i801 8220 0 - Live 0xffffffffa007c000
coretemp 4512 0 - Live 0xffffffffa006b000
snd_pcm 58586 2 snd_hda_intel,snd_hda_codec, Live 0xffffffffa0051000
snd_timer 15400 1 snd_pcm, Live 0xffffffffa0049000
snd 40912 6 snd_hda_codec_realtek,snd_hda_intel,snd_hda_codec,snd_hwdep,snd=
_pcm,snd_timer, Live 0xffffffffa0037000
soundcore 832 1 snd, Live 0xffffffffa0033000
hwmon 1201 2 w83627hf,coretemp, Live 0xffffffffa0023000
ppdev 5262 0 - Live 0xffffffffa001e000
snd_page_alloc 5905 2 snd_hda_intel,snd_pcm, Live 0xffffffffa0019000
parport_pc 27504 0 - Live 0xffffffffa000c000
parport 26359 2 ppdev,parport_pc, Live 0xffffffffa0000000

--MP_/1ApBtlCwpXP4l0kRHUq_A8X
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=slabtop_output.txt

 Active / Total Objects (% used)    : 2985963 / 3024520 (98.7%)
 Active / Total Slabs (% used)      : 96586 / 96586 (100.0%)
 Active / Total Caches (% used)     : 135 / 219 (61.6%)
 Active / Total Size (% used)       : 395495.66K / 405044.92K (97.6%)
 Minimum / Average / Maximum Object : 0.05K / 0.13K / 8.05K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                =
  =20
2779072 2779011  99%    0.12K  86846       32    347384K secpath_cache     =
    =20
 93106  73207  78%    0.15K   3581       26     14324K buffer_head         =
  =20
 24288  24280  99%    0.18K   1104       22      4416K ext4_groupinfo_4k   =
  =20
 21811  16993  77%    0.23K   1283       17      5132K dentry              =
  =20
 18575  18563  99%    0.16K    743       25      2972K sysfs_dir_cache     =
  =20
  7738   6532  84%    0.05K    106       73       424K kmalloc-8           =
  =20
  7124   5141  72%    0.59K    274       26      4384K inode_cache         =
  =20
  6579   5532  84%    0.08K    129       51       516K kmalloc-32          =
  =20
  6156   5064  82%    0.11K    171       36       684K kmalloc-64          =
  =20
  4930   4388  89%    0.91K    290       17      4640K ext4_inode_cache    =
  =20
  4738   4608  97%    0.09K    103       46       412K dm_io               =
  =20
  4704   4608  97%    0.07K     84       56       336K dm_target_io        =
  =20
  4576   3081  67%    0.60K    176       26      2816K radix_tree_node     =
  =20
  3520   3461  98%    0.06K     55       64       220K kmalloc-16          =
  =20
  3096   3077  99%    0.66K    129       24      2064K shmem_inode_cache   =
  =20
  3024   2961  97%    0.21K    168       18       672K vm_area_struct      =
  =20

--MP_/1ApBtlCwpXP4l0kRHUq_A8X
Content-Type: application/x-gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename=slub_leak_secpath_dup_slub_debug.tar.gz

H4sIAHZlgVAAA+2c3U7bMBSAe81T5HLThOp/J9LYq1hu4tGM0ET5YcDTL2nRBkXiJDF4m3y+m1YB
ZLXmOz4+PklXDTtTOXtjOpc3tt+bYmhMN10t3G643m78ISNayuPryPnr8T1lRBCmmKRiQ6hiim8S
+Q5jgwxdb9sk2bR13b/1e9DP/1M6aP7vbFUWtnceY0wTrISYMf9SUDVep1pP80/e7VO+Ac7/2/Nv
q6rOTT6+dGvHgOaf0mfzL9WGjO8lxfkPAdM6ozxNns3+F3JPd1tyL21ir92VIGRLVSZ5uuVMaaWT
piyuyCWVgid5M3Tje37xtz8Hsg7Q/++tc376g/4zwp/5ryf/ORHofwjGr5ynqUq+Hur+0t7ZsrK7
yn07mc8yyRjPUnlS/sn2i4RxySRLzJ//Gdf1bf0wRg7uxsgxBobp76mSdEu1UCwbQ4fOCPsdOmiG
oeOfAPS/3v3oTOPa8ZrdrRsDzv/4y/yP0TEpQP9DwBn6FzOg/60rzGN9+Nj9Hzvzn6D/gSCof9TM
2P+XtnPrk//NQv+n/T/VijH0PwTof9yA/jd12dUHrzEWr/9US4L13yCg/3ED+n9bHkxj27601dox
lq3/x/qfxPw/DBL9jxrQ/6nsZ7ry0aMAAPsvzvf/FM//wkBZihEgYmD/9215uPEaA/b/Vf+H0AT9
DwE4/3kzHI9+PCpAi+s/U/zH898g4P4vbmblf17V3zn+q/P4j/0fgUhVKjKMAdECr/823ztT3Nr1
Y6xY/4mS6H8IcP2Pmzn9Xy7vP/b8l77a/ymG638Qnvq/MQpEyqz9f9DzH3U6/0H/g4Drf9yA/j+1
9pvdg2nzYdUYy/yfzn8p4wr9DwH6Hzcz+r/zypa3xuZ5PRxWKbDI/9P9Hxzz/zCg/3Ezp//72q/9
c9n9X6f+b6bR/yAogQEgZuD9f1+3nmPA/pOX+T/VVGj0PwTg/O9/nk6APNaB5fs/oiXu/4JAMfxH
zdzzH58a8KL872n/J/D+vyBwzP+iBu7/GvM/Z4bOrc8Cl9d/CFe4/gcB1/+4ge//9Tv7nVjsP9WK
Y/9/EPDxP3Ezr//beHWBwP7L8/xf4fofBvKJfMYQEC+g/33d28p4dYGC/p/3fzJKGNZ/g3Ds/1TY
/xkrcP2vLTy2/kdW5P+coP9BwP6PuIHX/9bmPg//3Kzyn2ms/wcB/Y+bGf2fnWvvXOExxor6P6H4
/L8goP9xA9f/7KHsH0y+d/nNR+3/X/d/E4b+BwH9j5uZ/T9eTwCE/T/v/yFC4/MfgiAVBgAEQZAY
+QVmp+9bAHgAAA==

--MP_/1ApBtlCwpXP4l0kRHUq_A8X
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=ver_linux.txt

If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
=20
Linux anathema 3.6.1-fg.mf_master #1 SMP Sat Oct 13 04:21:08 YEKT 2012 x86_=
64 GNU/Linux
=20
Gnu C                  4.6.3
Gnu make               3.82
binutils               2.22
util-linux             2.21.2
mount                  support
module-init-tools      3.16
e2fsprogs              1.42.5
reiserfsprogs          3.6.21
xfsprogs               3.1.8
PPP                    2.4.5
Linux C Library        2.16
Dynamic linker (ldd)   2.16
Linux C++ Library      6..
Procps                 3.3.3
Net-tools              1.60_p20120127084908
Kbd                    1.15.3
Sh-utils               8.19
Modules Loaded         nfsv4 crypto_null camellia_generic camellia_x86_64 c=
ast6 cast5 cts gcm ccm twofish_generic xcbc ah6 ah4 esp6 esp4 xfrm4_mode_be=
et xfrm4_tunnel tunnel4 xfrm4_mode_tunnel xfrm4_mode_transport xfrm6_mode_t=
ransport xfrm6_mode_ro xfrm6_mode_beet xfrm6_mode_tunnel ipcomp ipcomp6 xfr=
m_ipcomp xfrm6_tunnel tunnel6 xt_policy xt_pkttype xt_recent w83627hf hwmon=
_vid nfsd tcp_lp tun nfs_acl auth_rpcgss nfs snd_hda_codec_realtek fscache =
lockd snd_hda_intel snd_hda_codec snd_hwdep sunrpc uhci_hcd via_rhine i2c_i=
801 coretemp snd_pcm snd_timer snd soundcore hwmon ppdev snd_page_alloc par=
port_pc parport

--MP_/1ApBtlCwpXP4l0kRHUq_A8X--

--Sig_/=zTb78BcsR/.bKSuZHQNMfx
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCBaM8ACgkQASbOZpzyXnFTiwCfRJDBcKn0jwmzJGMJ5BUO9JYw
OEEAn0+xvDUUorp2Vwhz7IKtLAW+m73s
=+bGO
-----END PGP SIGNATURE-----

--Sig_/=zTb78BcsR/.bKSuZHQNMfx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
