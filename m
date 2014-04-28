Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id C220D6B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 04:04:02 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so5498375pbc.6
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 01:04:02 -0700 (PDT)
Received: from relay1.mentorg.com (relay1.mentorg.com. [192.94.38.131])
        by mx.google.com with ESMTPS id iv2si4913672pbd.469.2014.04.28.01.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 01:04:01 -0700 (PDT)
From: Thomas Schwinge <thomas@codesourcery.com>
Subject: Re: radeon: screen garbled after page allocator change, was: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
In-Reply-To: <20140425230321.GG5915@gmail.com>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org> <1375457846-21521-4-git-send-email-hannes@cmpxchg.org> <87r45fajun.fsf@schwinge.name> <20140424133722.GD4107@cmpxchg.org> <20140425214746.GC5915@gmail.com> <20140425215055.GD5915@gmail.com> <20140425230321.GG5915@gmail.com>
Date: Mon, 28 Apr 2014 10:03:46 +0200
Message-ID: <87sioxq3rx.fsf@schwinge.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="==-=-="; micalg=pgp-sha1;
	protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Andrea
 Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alex Deucher <alexander.deucher@amd.com>, Christian =?utf-8?Q?K=C3=B6nig?= <christian.koenig@amd.com>, dri-devel@lists.freedesktop.org

--==-=-=
Content-Type: multipart/mixed; boundary="=-=-="

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi!

On Fri, 25 Apr 2014 19:03:22 -0400, Jerome Glisse <j.glisse@gmail.com> wrot=
e:
> On Fri, Apr 25, 2014 at 05:50:57PM -0400, Jerome Glisse wrote:
> > On Fri, Apr 25, 2014 at 05:47:48PM -0400, Jerome Glisse wrote:
> > > On Thu, Apr 24, 2014 at 09:37:22AM -0400, Johannes Weiner wrote:

Guys, thanks for following up on that one!  We're currently renovating
our (new) home, and relocating, so not much time to look into this issue,
but I'll try my best, and here are some results:

> > > > On Wed, Apr 02, 2014 at 04:26:08PM +0200, Thomas Schwinge wrote:
> > > > > On Fri,  2 Aug 2013 11:37:26 -0400, Johannes Weiner <hannes@cmpxc=
hg.org> wrote:
> > > > > > Each zone that holds userspace pages of one workload must be ag=
ed at a
> > > > > > speed proportional to the zone size.  [...]
> > > > >=20
> > > > > > Fix this with a very simple round robin allocator.  [...]
> > > > >=20
> > > > > This patch, adding NR_ALLOC_BATCH, eventually landed in mainline =
as
> > > > > commit 81c0a2bb515fd4daae8cab64352877480792b515 (2013-09-11).
> > > > >=20
> > > > > I recently upgraded a Debian testing system from a 3.11 kernel to=
 3.12,
> > > > > and it started to exhibit "strange" issues, which I then bisected=
 to this
> > > > > patch.  I'm not saying that the patch is faulty, as it seems to be
> > > > > working fine for everyone else, so I rather assume that something=
 in a
> > > > > (vastly?) different corner of the kernel (or my hardware?) is bro=
ken.
> > > > > ;-)
> > > > >=20
> > > > > The issue is that when X.org/lightdm starts up, there are "garble=
d"
> > > > > section on the screen, for example, rectangular boxes that are ju=
st black
> > > > > or otherwise "distorted", and/or sets of glyphs (corresponding to=
 a set
> > > > > of characters; but not all characters) are displayed as rectangul=
ar gray
> > > > > or black boxes, and/or icons in a GNOME session are not displayed
> > > > > properly, and so on.  (Can take a snapshot if that helps?)  Switc=
hing to
> > > > > a Linux console, I can use that one fine.  Switching back to X, i=
n the
> > > > > majority of all cases, the screen will be completely black, but w=
ith the
> > > > > mouse cursor still rendered properly (done in hardware, I assume).
> > > > >=20
> > > > > Reverting commit 81c0a2bb515fd4daae8cab64352877480792b515, for ex=
ample on
> > > > > top of v3.12, and everything is back to normal.  The problem also
> > > > > persists with a v3.14 kernel that I just built.
> > > > >=20
> > > > > I will try to figure out what's going on, but will gladly take any
> > > > > pointers, or suggestions about how to tackle such a problem.
> > > > >=20
> > > > > The hardware is a Fujitsu Siemens Esprimo E5600, mainboard D2264-=
A1, CPU
> > > > > AMD Sempron 3000+.  There is a on-board graphics thingy, but I'm =
not
> > > > > using that; instead I put in a Sapphire Radeon HD 4350 card.
> > > >=20
> > > > I went over this code change repeatedly but I could not see anything
> > > > directly that would explain it.  However, this patch DOES change the
> > > > way allocations are placed (while still respecting zone specifiers
> > > > like __GFP_DMA etc.) and so it's possible that they unearthed a
> > > > corruption, or a wrongly set dma mask in the drivers.

OK, that was my impression too from reading the patch -- though, in
contrast to you, I'm not familiar with this Linux kernel code, so might
easily miss some "details".  ;-)

> > > Can we get a full dmesg, to know if thing like IOMMU are enabled or n=
ot.

Attached dmesg-v3.12 and dmesg-v3.14.

> > > This is even more puzzling as rv710 has 40bit dma mask iirc and thus =
you
> > > should be fine even without IOMMU. But given the patch you point to, =
it
> > > really can only be something that allocate page in place the GPU fails
> > > to access.
> > >=20
> > > Thomas how much memory do you have (again dmes will also provide mapp=
ing
> > > informations) ?

4 GiB; see dmesg.

> > > My guess is that the pcie bridge can only remap dma page with 32bit d=
ma
> > > mask while the gpu is fine with 40bit dma mask. I always thought that=
 the
> > > pcie/pci code did take care of such thing for us.
> >=20
> > Forgot to attach patch to test my theory. Does the attached patch fix
> > the issue ?

Unfortunately it does not.  :-/

> So this is likely it, the SIS chipset of this motherboard is a freak show.

Well, it has been a freak show before: system crash if I put into the CD
drive a specific audio CD:
<http://news.gmane.org/find-root.php?message_id=3D%3C87obojef7t.fsf%40schwi=
nge.name%3E>.
(This issue remains unresolved, unless it has "fixed itself" -- I have
not recently tried what happens now.)

> It support both PCIE and AGP at same time
>=20
> http://www.newegg.com/Product/Product.aspx?Item=3DN82E16813185068
>=20
> Why in hell ?
>=20
> So my guess is that the root pcie bridge is behind the AGP bridge which
> swallow any address > 32bit and thus the dma mask of the pcie radeon
> card is just believing that we are living in a sane world.

    $ lspci -vt
    -[0000:00]-+-00.0  Silicon Integrated Systems [SiS] 761/M761 Host
               +-01.0-[01]--+-00.0  Advanced Micro Devices, Inc. [AMD/ATI] =
RV710/M92 [Mobility Radeon HD 4530/4570/545v]
               |            \-00.1  Advanced Micro Devices, Inc. [AMD/ATI] =
RV710/730 HDMI Audio [Radeon HD 4000 series]
               +-02.0  Silicon Integrated Systems [SiS] SiS965 [MuTIOL Medi=
a IO]
               +-02.5  Silicon Integrated Systems [SiS] 5513 IDE Controller
               +-02.7  Silicon Integrated Systems [SiS] SiS7012 AC'97 Sound=
 Controller
               +-03.0  Silicon Integrated Systems [SiS] USB 1.1 Controller
               +-03.1  Silicon Integrated Systems [SiS] USB 1.1 Controller
               +-03.2  Silicon Integrated Systems [SiS] USB 1.1 Controller
               +-03.3  Silicon Integrated Systems [SiS] USB 2.0 Controller
               +-05.0  Silicon Integrated Systems [SiS] 182 SATA/RAID Contr=
oller
               +-06.0-[02]--
               +-09.0  Realtek Semiconductor Co., Ltd. RTL8169 PCI Gigabit =
Ethernet Controller
               +-18.0  Advanced Micro Devices, Inc. [AMD] K8 [Athlon64/Opte=
ron] HyperTransport Technology Configuration
               +-18.1  Advanced Micro Devices, Inc. [AMD] K8 [Athlon64/Opte=
ron] Address Map
               +-18.2  Advanced Micro Devices, Inc. [AMD] K8 [Athlon64/Opte=
ron] DRAM Controller
               \-18.3  Advanced Micro Devices, Inc. [AMD] K8 [Athlon64/Opte=
ron] Miscellaneous Control

Full quote follows:

> > > > >     $ cat < /proc/cpuinfo
> > > > >     processor       : 0
> > > > >     vendor_id       : AuthenticAMD
> > > > >     cpu family      : 15
> > > > >     model           : 47
> > > > >     model name      : AMD Sempron(tm) Processor 3000+
> > > > >     stepping        : 2
> > > > >     cpu MHz         : 1000.000
> > > > >     cache size      : 128 KB
> > > > >     physical id     : 0
> > > > >     siblings        : 1
> > > > >     core id         : 0
> > > > >     cpu cores       : 1
> > > > >     apicid          : 0
> > > > >     initial apicid  : 0
> > > > >     fpu             : yes
> > > > >     fpu_exception   : yes
> > > > >     cpuid level     : 1
> > > > >     wp              : yes
> > > > >     flags           : fpu vme de pse tsc msr pae mce cx8 apic sep=
 mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext fx=
sr_opt lm 3dnowext 3dnow rep_good nopl pni lahf_lm
> > > > >     bogomips        : 2000.20
> > > > >     TLB size        : 1024 4K pages
> > > > >     clflush size    : 64
> > > > >     cache_alignment : 64
> > > > >     address sizes   : 40 bits physical, 48 bits virtual
> > > > >     power management: ts fid vid ttp tm stc
> > > > >     $ sudo lspci -nn -k -vv
> > > > >     00:00.0 Host bridge [0600]: Silicon Integrated Systems [SiS] =
761/M761 Host [1039:0761] (rev 01)
> > > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 Moth=
erboard [1734:1099]
> > > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dme=
dium >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> > > > >             Latency: 64
> > > > >             Region 0: Memory at f0000000 (32-bit, non-prefetchabl=
e) [size=3D32M]
> > > > >             Capabilities: [a0] AGP version 3.0
> > > > >                     Status: RQ=3D32 Iso- ArqSz=3D2 Cal=3D3 SBA+ I=
TACoh- GART64- HTrans- 64bit- FW- AGP3+ Rate=3Dx4,x8
> > > > >                     Command: RQ=3D1 ArqSz=3D0 Cal=3D0 SBA+ AGP- G=
ART64- 64bit- FW- Rate=3D<none>
> > > > >             Capabilities: [d0] HyperTransport: Slave or Primary I=
nterface
> > > > >                     Command: BaseUnitID=3D0 UnitCnt=3D17 MastHost=
- DefDir- DUL-
> > > > >                     Link Control 0: CFlE- CST- CFE- <LkFail- Init=
+ EOC- TXO- <CRCErr=3D0 IsocEn- LSEn- ExtCTL- 64b-
> > > > >                     Link Config 0: MLWI=3D16bit DwFcIn- MLWO=3D16=
bit DwFcOut- LWI=3D16bit DwFcInEn- LWO=3D16bit DwFcOutEn-
> > > > >                     Link Control 1: CFlE- CST- CFE- <LkFail+ Init=
- EOC+ TXO+ <CRCErr=3D0 IsocEn- LSEn- ExtCTL- 64b-
> > > > >                     Link Config 1: MLWI=3DN/C DwFcIn- MLWO=3DN/C =
DwFcOut- LWI=3DN/C DwFcInEn- LWO=3DN/C DwFcOutEn-
> > > > >                     Revision ID: 1.05
> > > > >                     Link Frequency 0: 800MHz
> > > > >                     Link Error 0: <Prot- <Ovfl- <EOC- CTLTm-
> > > > >                     Link Frequency Capability 0: 200MHz+ 300MHz- =
400MHz+ 500MHz- 600MHz+ 800MHz+ 1.0GHz+ 1.2GHz+ 1.4GHz- 1.6GHz- Vend-
> > > > >                     Feature Capability: IsocFC- LDTSTOP+ CRCTM- E=
CTLT- 64bA+ UIDRD-
> > > > >                     Link Frequency 1: 200MHz
> > > > >                     Link Error 1: <Prot- <Ovfl- <EOC- CTLTm-
> > > > >                     Link Frequency Capability 1: 200MHz- 300MHz- =
400MHz- 500MHz- 600MHz- 800MHz- 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
> > > > >                     Error Handling: PFlE- OFlE- PFE- OFE- EOCFE- =
RFE- CRCFE- SERRFE- CF- RE- PNFE- ONFE- EOCNFE- RNFE- CRCNFE- SERRNFE-
> > > > >                     Prefetchable memory behind bridge Upper: 00-00
> > > > >                     Bus Number: 00
> > > > >             Capabilities: [f0] HyperTransport: Interrupt Discover=
y and Configuration
> > > > >             Capabilities: [5c] HyperTransport: Revision ID: 1.05
> > > > >             Kernel driver in use: agpgart-amd64
> > > > >=20=20=20=20=20
> > > > >     00:01.0 PCI bridge [0604]: Silicon Integrated Systems [SiS] P=
CI-to-PCI bridge [1039:0004] (prog-if 00 [Normal decode])
> > > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Latency: 0, Cache Line Size: 64 bytes
> > > > >             Bus: primary=3D00, secondary=3D01, subordinate=3D01, =
sec-latency=3D0
> > > > >             I/O behind bridge: 00002000-00002fff
> > > > >             Memory behind bridge: f2100000-f21fffff
> > > > >             Prefetchable memory behind bridge: e0000000-efffffff
> > > > >             Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfa=
st >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> > > > >             BridgeCtl: Parity+ SERR+ NoISA+ VGA+ MAbort- >Reset- =
FastB2B-
> > > > >                     PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrS=
ERREn-
> > > > >             Capabilities: [d0] Express (v1) Root Port (Slot+), MS=
I 00
> > > > >                     DevCap: MaxPayload 128 bytes, PhantFunc 0
> > > > >                             ExtTag+ RBE-
> > > > >                     DevCtl: Report errors: Correctable- Non-Fatal=
- Fatal- Unsupported-
> > > > >                             RlxdOrd+ ExtTag- PhantFunc- AuxPwr- N=
oSnoop+
> > > > >                             MaxPayload 128 bytes, MaxReadReq 128 =
bytes
> > > > >                     DevSta: CorrErr- UncorrErr- FatalErr- UnsuppR=
eq+ AuxPwr+ TransPend-
> > > > >                     LnkCap: Port #0, Speed 2.5GT/s, Width x16, AS=
PM L0s L1, Exit Latency L0s <1us, L1 <2us
> > > > >                             ClockPM- Surprise- LLActRep+ BwNot-
> > > > >                     LnkCtl: ASPM Disabled; RCB 64 bytes Disabled-=
 CommClk+
> > > > >                             ExtSynch- ClockPM- AutWidDis- BWInt- =
AutBWInt-
> > > > >                     LnkSta: Speed 2.5GT/s, Width x16, TrErr- Trai=
n- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
> > > > >                     SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrIn=
d- HotPlug- Surprise-
> > > > >                             Slot #0, PowerLimit 75.000W; Interloc=
k- NoCompl-
> > > > >                     SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet=
- CmdCplt- HPIrq- LinkChg-
> > > > >                             Control: AttnInd Off, PwrInd Off, Pow=
er- Interlock-
> > > > >                     SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCp=
lt- PresDet+ Interlock-
> > > > >                             Changed: MRL- PresDet- LinkState-
> > > > >                     RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFat=
al- PMEIntEna- CRSVisible-
> > > > >                     RootCap: CRSVisible-
> > > > >                     RootSta: PME ReqID 0000, PMEStatus- PMEPendin=
g-
> > > > >             Capabilities: [bc] HyperTransport: MSI Mapping Enable=
- Fixed+
> > > > >             Capabilities: [a0] MSI: Enable- Count=3D1/1 Maskable-=
 64bit-
> > > > >                     Address: 00000000  Data: 0000
> > > > >             Capabilities: [f4] Power Management version 2
> > > > >                     Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA =
PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > > > >             Kernel driver in use: pcieport
> > > > >=20=20=20=20=20
> > > > >     00:02.0 ISA bridge [0601]: Silicon Integrated Systems [SiS] S=
iS965 [MuTIOL Media IO] [1039:0965] (rev 48)
> > > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGA=
Snoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > > >             Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dme=
dium >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> > > > >             Latency: 0
> > > > >=20=20=20=20=20
> > > > >     00:02.5 IDE interface [0101]: Silicon Integrated Systems [SiS=
] 5513 IDE Controller [1039:5513] (rev 01) (prog-if 80 [Master])
> > > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 Moth=
erboard [1734:1095]
> > > > >             Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dme=
dium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Latency: 128
> > > > >             Interrupt: pin ? routed to IRQ 16
> > > > >             Region 0: I/O ports at 01f0 [size=3D8]
> > > > >             Region 1: I/O ports at 03f4
> > > > >             Region 2: I/O ports at 0170 [size=3D8]
> > > > >             Region 3: I/O ports at 0374
> > > > >             Region 4: I/O ports at 1c80 [size=3D16]
> > > > >             Capabilities: [58] Power Management version 2
> > > > >                     Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA =
PME(D0-,D1-,D2-,D3hot-,D3cold+)
> > > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > > > >             Kernel driver in use: pata_sis
> > > > >=20=20=20=20=20
> > > > >     00:02.7 Multimedia audio controller [0401]: Silicon Integrate=
d Systems [SiS] SiS7012 AC'97 Sound Controller [1039:7012] (rev a0)
> > > > >             Subsystem: Fujitsu Technology Solutions Device [1734:=
109c]
> > > > >             Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > > >             Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Latency: 173 (13000ns min, 2750ns max)
> > > > >             Interrupt: pin C routed to IRQ 18
> > > > >             Region 0: I/O ports at 1400 [size=3D256]
> > > > >             Region 1: I/O ports at 1000 [size=3D128]
> > > > >             Capabilities: [48] Power Management version 2
> > > > >                     Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D55mA=
 PME(D0-,D1-,D2-,D3hot+,D3cold+)
> > > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > > > >             Kernel driver in use: snd_intel8x0
> > > > >=20=20=20=20=20
> > > > >     00:03.0 USB controller [0c03]: Silicon Integrated Systems [Si=
S] USB 1.1 Controller [1039:7001] (rev 0f) (prog-if 10 [OHCI])
> > > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 Moth=
erboard [1734:1095]
> > > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGA=
Snoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > > >             Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Latency: 64 (20000ns max)
> > > > >             Interrupt: pin A routed to IRQ 20
> > > > >             Region 0: Memory at f2000000 (32-bit, non-prefetchabl=
e) [size=3D4K]
> > > > >             Kernel driver in use: ohci-pci
> > > > >=20=20=20=20=20
> > > > >     00:03.1 USB controller [0c03]: Silicon Integrated Systems [Si=
S] USB 1.1 Controller [1039:7001] (rev 0f) (prog-if 10 [OHCI])
> > > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 Moth=
erboard [1734:1095]
> > > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGA=
Snoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > > >             Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Latency: 64 (20000ns max)
> > > > >             Interrupt: pin B routed to IRQ 21
> > > > >             Region 0: Memory at f2001000 (32-bit, non-prefetchabl=
e) [size=3D4K]
> > > > >             Kernel driver in use: ohci-pci
> > > > >=20=20=20=20=20
> > > > >     00:03.2 USB controller [0c03]: Silicon Integrated Systems [Si=
S] USB 1.1 Controller [1039:7001] (rev 0f) (prog-if 10 [OHCI])
> > > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 Moth=
erboard [1734:1095]
> > > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGA=
Snoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > > >             Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Latency: 64 (20000ns max)
> > > > >             Interrupt: pin C routed to IRQ 22
> > > > >             Region 0: Memory at f2002000 (32-bit, non-prefetchabl=
e) [size=3D4K]
> > > > >             Kernel driver in use: ohci-pci
> > > > >=20=20=20=20=20
> > > > >     00:03.3 USB controller [0c03]: Silicon Integrated Systems [Si=
S] USB 2.0 Controller [1039:7002] (prog-if 20 [EHCI])
> > > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 [173=
4:1095]
> > > > >             Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > > >             Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Latency: 64 (20000ns max)
> > > > >             Interrupt: pin D routed to IRQ 23
> > > > >             Region 0: Memory at f2003000 (32-bit, non-prefetchabl=
e) [size=3D4K]
> > > > >             Capabilities: [50] Power Management version 2
> > > > >                     Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375m=
A PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > > > >             Kernel driver in use: ehci-pci
> > > > >=20=20=20=20=20
> > > > >     00:05.0 IDE interface [0101]: Silicon Integrated Systems [SiS=
] 182 SATA/RAID Controller [1039:0182] (rev 01) (prog-if 8f [Master SecP Se=
cO PriP PriO])
> > > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 [173=
4:1095]
> > > > >             Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dme=
dium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Latency: 64
> > > > >             Interrupt: pin A routed to IRQ 17
> > > > >             Region 0: I/O ports at 1cb0 [size=3D8]
> > > > >             Region 1: I/O ports at 1ca4 [size=3D4]
> > > > >             Region 2: I/O ports at 1ca8 [size=3D8]
> > > > >             Region 3: I/O ports at 1ca0 [size=3D4]
> > > > >             Region 4: I/O ports at 1c90 [size=3D16]
> > > > >             Region 5: I/O ports at 1c00 [size=3D128]
> > > > >             Capabilities: [58] Power Management version 2
> > > > >                     Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA =
PME(D0-,D1-,D2-,D3hot-,D3cold+)
> > > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > > > >             Kernel driver in use: sata_sis
> > > > >=20=20=20=20=20
> > > > >     00:06.0 PCI bridge [0604]: Silicon Integrated Systems [SiS] P=
CI-to-PCI bridge [1039:000a] (prog-if 00 [Normal decode])
> > > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> > > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Latency: 0, Cache Line Size: 64 bytes
> > > > >             Bus: primary=3D00, secondary=3D02, subordinate=3D02, =
sec-latency=3D0
> > > > >             Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfa=
st >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> > > > >             BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- =
FastB2B-
> > > > >                     PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrS=
ERREn-
> > > > >             Capabilities: [b0] Subsystem: Silicon Integrated Syst=
ems [SiS] Device [1039:0000]
> > > > >             Capabilities: [c0] MSI: Enable+ Count=3D1/1 Maskable-=
 64bit-
> > > > >                     Address: fee0100c  Data: 4181
> > > > >             Capabilities: [d0] Express (v1) Root Port (Slot+), MS=
I 00
> > > > >                     DevCap: MaxPayload 128 bytes, PhantFunc 0
> > > > >                             ExtTag+ RBE-
> > > > >                     DevCtl: Report errors: Correctable- Non-Fatal=
- Fatal- Unsupported-
> > > > >                             RlxdOrd+ ExtTag- PhantFunc- AuxPwr- N=
oSnoop+
> > > > >                             MaxPayload 128 bytes, MaxReadReq 128 =
bytes
> > > > >                     DevSta: CorrErr- UncorrErr- FatalErr- UnsuppR=
eq- AuxPwr+ TransPend-
> > > > >                     LnkCap: Port #0, Speed 2.5GT/s, Width x16, AS=
PM L0s L1, Exit Latency L0s <1us, L1 <2us
> > > > >                             ClockPM- Surprise- LLActRep- BwNot-
> > > > >                     LnkCtl: ASPM Disabled; RCB 64 bytes Disabled-=
 CommClk-
> > > > >                             ExtSynch- ClockPM- AutWidDis- BWInt- =
AutBWInt-
> > > > >                     LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train=
- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> > > > >                     SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrIn=
d- HotPlug- Surprise-
> > > > >                             Slot #0, PowerLimit 0.000W; Interlock=
- NoCompl-
> > > > >                     SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet=
- CmdCplt- HPIrq- LinkChg-
> > > > >                             Control: AttnInd Off, PwrInd Off, Pow=
er- Interlock-
> > > > >                     SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCp=
lt- PresDet+ Interlock-
> > > > >                             Changed: MRL- PresDet- LinkState-
> > > > >                     RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFat=
al- PMEIntEna- CRSVisible-
> > > > >                     RootCap: CRSVisible-
> > > > >                     RootSta: PME ReqID 0000, PMEStatus- PMEPendin=
g-
> > > > >             Capabilities: [f4] Power Management version 2
> > > > >                     Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA =
PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > > > >             Capabilities: [100 v1] Virtual Channel
> > > > >                     Caps:   LPEVC=3D0 RefClk=3D100ns PATEntryBits=
=3D1
> > > > >                     Arb:    Fixed- WRR32- WRR64- WRR128-
> > > > >                     Ctrl:   ArbSelect=3DFixed
> > > > >                     Status: InProgress-
> > > > >                     VC0:    Caps:   PATOffset=3D00 MaxTimeSlots=
=3D1 RejSnoopTrans-
> > > > >                             Arb:    Fixed- WRR32- WRR64- WRR128- =
TWRR128- WRR256-
> > > > >                             Ctrl:   Enable+ ID=3D0 ArbSelect=3DFi=
xed TC/VC=3Dff
> > > > >                             Status: NegoPending- InProgress-
> > > > >             Capabilities: [130 v1] Advanced Error Reporting
> > > > >                     UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAb=
rt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > > > >                     UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAb=
rt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > > > >                     UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAb=
rt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> > > > >                     CESta:  RxErr- BadTLP- BadDLLP- Rollover- Tim=
eout- NonFatalErr-
> > > > >                     CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Tim=
eout- NonFatalErr-
> > > > >                     AERCap: First Error Pointer: 00, GenCap- CGen=
En- ChkCap- ChkEn-
> > > > >             Kernel driver in use: pcieport
> > > > >=20=20=20=20=20
> > > > >     00:09.0 Ethernet controller [0200]: Realtek Semiconductor Co.=
, Ltd. RTL8169 PCI Gigabit Ethernet Controller [10ec:8169] (rev 10)
> > > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 [173=
4:1091]
> > > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGA=
Snoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > > >             Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Latency: 64 (8000ns min, 16000ns max), Cache Line Siz=
e: 32 bytes
> > > > >             Interrupt: pin A routed to IRQ 19
> > > > >             Region 0: I/O ports at 1800 [size=3D256]
> > > > >             Region 1: Memory at f2004000 (32-bit, non-prefetchabl=
e) [size=3D256]
> > > > >             Capabilities: [dc] Power Management version 2
> > > > >                     Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375m=
A PME(D0-,D1+,D2+,D3hot+,D3cold+)
> > > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > > > >             Kernel driver in use: r8169
> > > > >=20=20=20=20=20
> > > > >     00:18.0 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD=
] K8 [Athlon64/Opteron] HyperTransport Technology Configuration [1022:1100]
> > > > >             Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Capabilities: [80] HyperTransport: Host or Secondary =
Interface
> > > > >                     Command: WarmRst+ DblEnd- DevNum=3D0 ChainSid=
e- HostHide+ Slave- <EOCErr- DUL-
> > > > >                     Link Control: CFlE- CST- CFE- <LkFail- Init+ =
EOC- TXO- <CRCErr=3D0 IsocEn- LSEn- ExtCTL- 64b-
> > > > >                     Link Config: MLWI=3D16bit DwFcIn- MLWO=3D16bi=
t DwFcOut- LWI=3D16bit DwFcInEn- LWO=3D16bit DwFcOutEn-
> > > > >                     Revision ID: 1.02
> > > > >                     Link Frequency: 800MHz
> > > > >                     Link Error: <Prot- <Ovfl- <EOC- CTLTm-
> > > > >                     Link Frequency Capability: 200MHz+ 300MHz- 40=
0MHz+ 500MHz- 600MHz+ 800MHz+ 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
> > > > >                     Feature Capability: IsocFC- LDTSTOP+ CRCTM- E=
CTLT- 64bA- UIDRD- ExtRS- UCnfE-
> > > > >=20=20=20=20=20
> > > > >     00:18.1 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD=
] K8 [Athlon64/Opteron] Address Map [1022:1101]
> > > > >             Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > > >             Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >=20=20=20=20=20
> > > > >     00:18.2 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD=
] K8 [Athlon64/Opteron] DRAM Controller [1022:1102]
> > > > >             Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > > >             Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Kernel driver in use: amd64_edac
> > > > >=20=20=20=20=20
> > > > >     00:18.3 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD=
] K8 [Athlon64/Opteron] Miscellaneous Control [1022:1103]
> > > > >             Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > > >             Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Kernel driver in use: k8temp
> > > > >=20=20=20=20=20
> > > > >     01:00.0 VGA compatible controller [0300]: Advanced Micro Devi=
ces, Inc. [AMD/ATI] RV710/M92 [Mobility Radeon HD 4530/4570/545v] [1002:955=
3] (prog-if 00 [VGA controller])
> > > > >             Subsystem: PC Partner Limited / Sapphire Technology D=
evice [174b:3092]
> > > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> > > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> > > > >             Latency: 0, Cache Line Size: 64 bytes
> > > > >             Interrupt: pin A routed to IRQ 42
> > > > >             Region 0: Memory at e0000000 (64-bit, prefetchable) [=
size=3D256M]
> > > > >             Region 2: Memory at f2100000 (64-bit, non-prefetchabl=
e) [size=3D64K]
> > > > >             Region 4: I/O ports at 2000 [size=3D256]
> > > > >             [virtual] Expansion ROM at f2120000 [disabled] [size=
=3D128K]
> > > > >             Capabilities: [50] Power Management version 3
> > > > >                     Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA =
PME(D0-,D1-,D2-,D3hot-,D3cold-)
> > > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > > > >             Capabilities: [58] Express (v2) Legacy Endpoint, MSI =
00
> > > > >                     DevCap: MaxPayload 128 bytes, PhantFunc 0, La=
tency L0s <4us, L1 unlimited
> > > > >                             ExtTag+ AttnBtn- AttnInd- PwrInd- RBE=
+ FLReset-
> > > > >                     DevCtl: Report errors: Correctable- Non-Fatal=
- Fatal- Unsupported-
> > > > >                             RlxdOrd+ ExtTag- PhantFunc- AuxPwr- N=
oSnoop+
> > > > >                             MaxPayload 128 bytes, MaxReadReq 128 =
bytes
> > > > >                     DevSta: CorrErr- UncorrErr- FatalErr- UnsuppR=
eq- AuxPwr- TransPend-
> > > > >                     LnkCap: Port #0, Speed 2.5GT/s, Width x16, AS=
PM L0s L1, Exit Latency L0s <64ns, L1 <1us
> > > > >                             ClockPM- Surprise- LLActRep- BwNot-
> > > > >                     LnkCtl: ASPM Disabled; RCB 64 bytes Disabled-=
 CommClk+
> > > > >                             ExtSynch- ClockPM- AutWidDis- BWInt- =
AutBWInt-
> > > > >                     LnkSta: Speed 2.5GT/s, Width x16, TrErr- Trai=
n- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> > > > >                     DevCap2: Completion Timeout: Not Supported, T=
imeoutDis-, LTR-, OBFF Not Supported
> > > > >                     DevCtl2: Completion Timeout: 50us to 50ms, Ti=
meoutDis-, LTR-, OBFF Disabled
> > > > >                     LnkCtl2: Target Link Speed: 2.5GT/s, EnterCom=
pliance- SpeedDis-
> > > > >                              Transmit Margin: Normal Operating Ra=
nge, EnterModifiedCompliance- ComplianceSOS-
> > > > >                              Compliance De-emphasis: -6dB
> > > > >                     LnkSta2: Current De-emphasis Level: -6dB, Equ=
alizationComplete-, EqualizationPhase1-
> > > > >                              EqualizationPhase2-, EqualizationPha=
se3-, LinkEqualizationRequest-
> > > > >             Capabilities: [a0] MSI: Enable+ Count=3D1/1 Maskable-=
 64bit+
> > > > >                     Address: 00000000fee0100c  Data: 41e1
> > > > >             Capabilities: [100 v1] Vendor Specific Information: I=
D=3D0001 Rev=3D1 Len=3D010 <?>
> > > > >             Kernel driver in use: radeon
> > > > >=20=20=20=20=20
> > > > >     01:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AM=
D/ATI] RV710/730 HDMI Audio [Radeon HD 4000 series] [1002:aa38]
> > > > >             Subsystem: PC Partner Limited / Sapphire Technology D=
evice [174b:aa38]
> > > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> > > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > > >             Latency: 0, Cache Line Size: 64 bytes
> > > > >             Interrupt: pin B routed to IRQ 41
> > > > >             Region 0: Memory at f2110000 (64-bit, non-prefetchabl=
e) [size=3D16K]
> > > > >             Capabilities: [50] Power Management version 3
> > > > >                     Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA =
PME(D0-,D1-,D2-,D3hot-,D3cold-)
> > > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > > > >             Capabilities: [58] Express (v2) Legacy Endpoint, MSI =
00
> > > > >                     DevCap: MaxPayload 128 bytes, PhantFunc 0, La=
tency L0s <4us, L1 unlimited
> > > > >                             ExtTag+ AttnBtn- AttnInd- PwrInd- RBE=
+ FLReset-
> > > > >                     DevCtl: Report errors: Correctable- Non-Fatal=
- Fatal- Unsupported-
> > > > >                             RlxdOrd+ ExtTag- PhantFunc- AuxPwr- N=
oSnoop+
> > > > >                             MaxPayload 128 bytes, MaxReadReq 128 =
bytes
> > > > >                     DevSta: CorrErr- UncorrErr- FatalErr- UnsuppR=
eq- AuxPwr- TransPend-
> > > > >                     LnkCap: Port #0, Speed 2.5GT/s, Width x16, AS=
PM L0s L1, Exit Latency L0s <64ns, L1 <1us
> > > > >                             ClockPM- Surprise- LLActRep- BwNot-
> > > > >                     LnkCtl: ASPM Disabled; RCB 64 bytes Disabled-=
 CommClk+
> > > > >                             ExtSynch- ClockPM- AutWidDis- BWInt- =
AutBWInt-
> > > > >                     LnkSta: Speed 2.5GT/s, Width x16, TrErr- Trai=
n- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> > > > >                     DevCap2: Completion Timeout: Not Supported, T=
imeoutDis-, LTR-, OBFF Not Supported
> > > > >                     DevCtl2: Completion Timeout: 50us to 50ms, Ti=
meoutDis-, LTR-, OBFF Disabled
> > > > >                     LnkSta2: Current De-emphasis Level: -6dB, Equ=
alizationComplete-, EqualizationPhase1-
> > > > >                              EqualizationPhase2-, EqualizationPha=
se3-, LinkEqualizationRequest-
> > > > >             Capabilities: [a0] MSI: Enable+ Count=3D1/1 Maskable-=
 64bit+
> > > > >                     Address: 00000000fee0100c  Data: 41d1
> > > > >             Capabilities: [100 v1] Vendor Specific Information: I=
D=3D0001 Rev=3D1 Len=3D010 <?>
> > > > >             Kernel driver in use: snd_hda_intel


Gr=C3=BC=C3=9Fe,
 Thomas



--=-=-=
Content-Disposition: inline; filename=dmesg-v3.12
Content-Transfer-Encoding: quoted-printable

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.12.0 (thomas@hertz) (gcc version 4.8.1 (Ubun=
tu/Linaro 4.8.1-10ubuntu9) ) #4 SMP Mon Apr 28 07:50:11 CEST 2014
[    0.000000] Command line: BOOT_IMAGE=3D/boot/vmlinuz-3.12.0 root=3D/dev/=
mapper/vg0-boole--root ro
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009dfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009e000-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000e4000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000cfedffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000cfee0000-0x00000000cfeeefff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x00000000cfeef000-0x00000000cfefffff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x00000000cff00000-0x00000000cfffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec0ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fff00000-0x00000000ffffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000012fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.34 present.
[    0.000000] DMI: FUJITSU SIEMENS D2264-A1            /D2264-A1, BIOS 5.0=
0 R1.07-01.2264.A1            06/07/2006
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] AGP bridge at 00:00:00
[    0.000000] Aperture from AGP @ f0000000 old size 32 MB
[    0.000000] Aperture from AGP @ f0000000 size 32 MB (APSIZE f38)
[    0.000000] e820: last_pfn =3D 0x130000 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-D3FFF write-protect
[    0.000000]   D4000-E3FFF uncachable
[    0.000000]   E4000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0000000000 mask FF80000000 write-back
[    0.000000]   1 base 0100000000 mask FFE0000000 write-back
[    0.000000]   2 base 0120000000 mask FFF0000000 write-back
[    0.000000]   3 base 0080000000 mask FFC0000000 write-back
[    0.000000]   4 base 00C0000000 mask FFF0000000 write-back
[    0.000000]   5 base 00CFF00000 mask FFFFF00000 uncachable
[    0.000000]   6 base 00F0000000 mask FFFE000000 write-combining
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x701060007=
0106
[    0.000000] e820: last_pfn =3D 0xcfee0 max_arch_pfn =3D 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000f73b0-0x000f73bf] mapped at =
[ffff8800000f73b0]
[    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01a93000, 0x01a93fff] PGTABLE
[    0.000000] BRK [0x01a94000, 0x01a94fff] PGTABLE
[    0.000000] BRK [0x01a95000, 0x01a95fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12fe00000-0x12fffffff]
[    0.000000]  [mem 0x12fe00000-0x12fffffff] page 2M
[    0.000000] BRK [0x01a96000, 0x01a96fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12c000000-0x12fdfffff]
[    0.000000]  [mem 0x12c000000-0x12fdfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x100000000-0x12bffffff]
[    0.000000]  [mem 0x100000000-0x12bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0xcfedffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0xcfdfffff] page 2M
[    0.000000]  [mem 0xcfe00000-0xcfedffff] page 4k
[    0.000000] RAMDISK: [mem 0x3640c000-0x371fdfff]
[    0.000000] ACPI: RSDP 00000000000f7350 00024 (v02 PTLTD )
[    0.000000] ACPI: XSDT 00000000cfeeb7e4 0004C (v01 PTLTD  ? XSDT   00050=
000  LTP 00000000)
[    0.000000] ACPI: FACP 00000000cfeeb8a4 000F4 (v03 FSC       \xfffffff7P=
?-? 00050000      000F4240)
[    0.000000] ACPI: DSDT 00000000cfeeb998 034FB (v01 FSC    D2030    00050=
000 MSFT 02000002)
[    0.000000] ACPI: FACS 00000000cfeeffc0 00040
[    0.000000] ACPI: SSDT 00000000cfeeee93 000B5 (v01 PTLTD  POWERNOW 00050=
000  LTP 00000001)
[    0.000000] ACPI: APIC 00000000cfeeef48 00050 (v01 PTLTD  ? APIC   00050=
000  LTP 00000000)
[    0.000000] ACPI: MCFG 00000000cfeeef98 00040 (v01 PTLTD    MCFG   00050=
000  LTP 00000000)
[    0.000000] ACPI: BOOT 00000000cfeeefd8 00028 (v01 PTLTD  $SBFTBL$ 00050=
000  LTP 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] Scanning NUMA topology in Northbridge 24
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000012fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x12fffffff]
[    0.000000]   NODE_DATA [mem 0x12fff8000-0x12fffbfff]
[    0.000000]  [ffffea0000000000-ffffea00043fffff] PMD -> [ffff88012b60000=
0-ffff88012effffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x12fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009dfff]
[    0.000000]   node   0: [mem 0x00100000-0xcfedffff]
[    0.000000]   node   0: [mem 0x100000000-0x12fffffff]
[    0.000000] On node 0 totalpages: 1048189
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 11589 pages used for memmap
[    0.000000]   DMA32 zone: 847584 pages, LIFO batch:31
[    0.000000]   Normal zone: 2688 pages used for memmap
[    0.000000]   Normal zone: 196608 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xf008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 20, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000e3fff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e4000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xcfee0000-0xcfeeefff]
[    0.000000] PM: Registered nosave memory: [mem 0xcfeef000-0xcfefffff]
[    0.000000] PM: Registered nosave memory: [mem 0xcff00000-0xcfffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xd0000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfec0ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec10000-0xfedfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfee00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee01000-0xffefffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfff00000-0xffffffff]
[    0.000000] e820: [mem 0xd0000000-0xfebfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:1 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88012fc00000 s85888 r8192=
 d20608 u2097152
[    0.000000] pcpu-alloc: s85888 r8192 d20608 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 1033835
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=3D/boot/vmlinuz-3.12.0 root=
=3D/dev/mapper/vg0-boole--root ro
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] AGP bridge at 00:00:00
[    0.000000] Aperture from AGP @ f0000000 old size 32 MB
[    0.000000] Aperture from AGP @ f0000000 size 32 MB (APSIZE f38)
[    0.000000] Node 0: aperture @ f0000000 size 64 MB
[    0.000000] Memory: 4041704K/4192756K available (4725K kernel code, 680K=
 rwdata, 1576K rodata, 972K init, 948K bss, 151052K reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=3D512 to nr_cpu_ids=3D1.
[    0.000000] NR_IRQS:33024 nr_irqs:256 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] allocated 16777216 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't wan=
t memory cgroups
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 1800.195 MHz processor
[    0.008003] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 3600.39 BogoMIPS (lpj=3D7200780)
[    0.008076] pid_max: default: 32768 minimum: 301
[    0.008153] Security Framework initialized
[    0.008194] AppArmor: AppArmor disabled by boot time parameter
[    0.008230] Yama: becoming mindful.
[    0.008631] Dentry cache hash table entries: 524288 (order: 10, 4194304 =
bytes)
[    0.014121] Inode-cache hash table entries: 262144 (order: 9, 2097152 by=
tes)
[    0.015473] Mount-cache hash table entries: 256
[    0.015786] Initializing cgroup subsys memory
[    0.015851] Initializing cgroup subsys devices
[    0.015888] Initializing cgroup subsys freezer
[    0.015926] Initializing cgroup subsys net_cls
[    0.015962] Initializing cgroup subsys blkio
[    0.016009] Initializing cgroup subsys perf_event
[    0.016074] tseg: 00cff00000
[    0.016078] mce: CPU supports 5 MCE banks
[    0.016126] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 4
[    0.016126] Last level dTLB entries: 4KB 512, 2MB 8, 4MB 4
[    0.016126] tlb_flushall_shift: 4
[    0.022089] Freeing SMP alternatives memory: 20K (ffffffff8199f000 - fff=
fffff819a4000)
[    0.023084] ACPI: Core revision 20130725
[    0.024776] ACPI: All ACPI Tables successfully acquired
[    0.026673] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D0 pin2=3D0
[    0.066408] smpboot: CPU0: AMD Sempron(tm) Processor 3000+ (fam: 0f, mod=
el: 2f, stepping: 02)
[    0.068000] Performance Events: AMD PMU driver.
[    0.068000] ... version:                0
[    0.068000] ... bit width:              48
[    0.068000] ... generic registers:      4
[    0.068000] ... value mask:             0000ffffffffffff
[    0.068000] ... max period:             00007fffffffffff
[    0.068000] ... fixed-purpose events:   0
[    0.068000] ... event mask:             000000000000000f
[    0.068000] Brought up 1 CPUs
[    0.068000] smpboot: Total of 1 processors activated (3600.39 BogoMIPS)
[    0.068000] NMI watchdog: enabled on all CPUs, permanently consumes one =
hw-PMU counter.
[    0.068000] devtmpfs: initialized
[    0.070632] PM: Registering ACPI NVS region [mem 0xcfeef000-0xcfefffff] =
(69632 bytes)
[    0.070914] NET: Registered protocol family 16
[    0.071105] cpuidle: using governor ladder
[    0.071142] cpuidle: using governor menu
[    0.071184] node 0 link 0: io port [0, fffff]
[    0.071187] TOM: 00000000d0000000 aka 3328M
[    0.071225] node 0 link 0: mmio [d0000000, dfffffff]
[    0.071229] node 0 link 0: mmio [a0000, bffff]
[    0.071232] node 0 link 0: mmio [d0000000, fe0bffff]
[    0.071234] TOM2: 0000000130000000 aka 4864M
[    0.071271] bus: [bus 00-ff] on node 0 link 0
[    0.071274] bus: 00 [io  0x0000-0xffff]
[    0.071276] bus: 00 [mem 0xd0000000-0xffffffff]
[    0.071278] bus: 00 [mem 0x000a0000-0x000bffff]
[    0.071280] bus: 00 [mem 0x130000000-0xfcffffffff]
[    0.071317] ACPI: bus type PCI registered
[    0.071355] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.071468] PCI: MMCONFIG for domain 0000 [bus 00-01] at [mem 0xd0000000=
-0xd01fffff] (base 0xd0000000)
[    0.071509] PCI: not using MMCONFIG
[    0.071545] PCI: Using configuration type 1 for base access
[    0.072527] bio: create slab <bio-0> at 0
[    0.072683] ACPI: Added _OSI(Module Device)
[    0.072721] ACPI: Added _OSI(Processor Device)
[    0.072757] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.072793] ACPI: Added _OSI(Processor Aggregator Device)
[    0.073249] ACPI: EC: Look up EC in DSDT
[    0.075115] ACPI: Interpreter enabled
[    0.075165] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20130725/hwxface-571)
[    0.075281] ACPI: (supports S0 S1 S3 S4 S5)
[    0.075317] ACPI: Using IOAPIC for interrupt routing
[    0.075378] PCI: MMCONFIG for domain 0000 [bus 00-01] at [mem 0xd0000000=
-0xd01fffff] (base 0xd0000000)
[    0.075830] PCI: MMCONFIG at [mem 0xd0000000-0xd01fffff] reserved in ACP=
I motherboard resources
[    0.076036] PCI: Ignoring host bridge windows from ACPI; if necessary, u=
se "pci=3Duse_crs" and report a bug
[    0.076198] ACPI: No dock devices found.
[    0.081585] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.081633] acpi PNP0A03:00: ACPI _OSC support notification failed, disa=
bling PCIe ASPM
[    0.081673] acpi PNP0A03:00: Unable to request _OSC control (_OSC suppor=
t mask: 0x08)
[    0.081811] acpi PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ign=
ored)
[    0.081814] acpi PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ign=
ored)
[    0.081817] acpi PNP0A03:00: host bridge window [mem 0x000a0000-0x000bff=
ff] (ignored)
[    0.081820] acpi PNP0A03:00: host bridge window [mem 0x000c8000-0x000dff=
ff] (ignored)
[    0.081823] acpi PNP0A03:00: host bridge window [mem 0xd0000000-0xfebfff=
ff] (ignored)
[    0.081826] acpi PNP0A03:00: host bridge window [mem 0xfed00000-0xfedfff=
ff] (ignored)
[    0.081829] acpi PNP0A03:00: host bridge window [mem 0xfef00000-0xff77ff=
ff] (ignored)
[    0.081832] PCI: root bus 00: hardware-probed resources
[    0.081838] acpi PNP0A03:00: [Firmware Info]: MMCONFIG for domain 0000 [=
bus 00-01] only partially covers this bridge
[    0.082073] PCI host bridge to bus 0000:00
[    0.082111] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.082148] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.082185] pci_bus 0000:00: root bus resource [mem 0xd0000000-0xfffffff=
f]
[    0.082223] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.082260] pci_bus 0000:00: root bus resource [mem 0x130000000-0xfcffff=
ffff]
[    0.082310] pci 0000:00:00.0: [1039:0761] type 00 class 0x060000
[    0.082320] pci 0000:00:00.0: reg 0x10: [mem 0xf0000000-0xf1ffffff]
[    0.082449] pci 0000:00:01.0: [1039:0004] type 01 class 0x060400
[    0.082500] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.082549] pci 0000:00:01.0: System wakeup disabled by ACPI
[    0.082628] pci 0000:00:02.0: [1039:0965] type 00 class 0x060100
[    0.082746] pci 0000:00:02.5: [1039:5513] type 00 class 0x01018a
[    0.082769] pci 0000:00:02.5: reg 0x10: [io  0x01f0-0x01f7]
[    0.082777] pci 0000:00:02.5: reg 0x14: [io  0x03f4-0x03f7]
[    0.082784] pci 0000:00:02.5: reg 0x18: [io  0x0170-0x0177]
[    0.082791] pci 0000:00:02.5: reg 0x1c: [io  0x0374-0x0377]
[    0.082799] pci 0000:00:02.5: reg 0x20: [io  0x1c80-0x1c8f]
[    0.082827] pci 0000:00:02.5: PME# supported from D3cold
[    0.082910] pci 0000:00:02.7: [1039:7012] type 00 class 0x040100
[    0.082923] pci 0000:00:02.7: reg 0x10: [io  0x1400-0x14ff]
[    0.082931] pci 0000:00:02.7: reg 0x14: [io  0x1000-0x107f]
[    0.082975] pci 0000:00:02.7: supports D1 D2
[    0.082977] pci 0000:00:02.7: PME# supported from D3hot D3cold
[    0.083021] pci 0000:00:02.7: System wakeup disabled by ACPI
[    0.083926] pci 0000:00:03.0: [1039:7001] type 00 class 0x0c0310
[    0.083937] pci 0000:00:03.0: reg 0x10: [mem 0xf2000000-0xf2000fff]
[    0.084082] pci 0000:00:03.0: System wakeup disabled by ACPI
[    0.084163] pci 0000:00:03.1: [1039:7001] type 00 class 0x0c0310
[    0.084174] pci 0000:00:03.1: reg 0x10: [mem 0xf2001000-0xf2001fff]
[    0.084287] pci 0000:00:03.1: System wakeup disabled by ACPI
[    0.084368] pci 0000:00:03.2: [1039:7001] type 00 class 0x0c0310
[    0.084378] pci 0000:00:03.2: reg 0x10: [mem 0xf2002000-0xf2002fff]
[    0.084489] pci 0000:00:03.2: System wakeup disabled by ACPI
[    0.084576] pci 0000:00:03.3: [1039:7002] type 00 class 0x0c0320
[    0.084589] pci 0000:00:03.3: reg 0x10: [mem 0xf2003000-0xf2003fff]
[    0.084634] pci 0000:00:03.3: PME# supported from D0 D3hot D3cold
[    0.084679] pci 0000:00:03.3: System wakeup disabled by ACPI
[    0.084765] pci 0000:00:05.0: [1039:0182] type 00 class 0x01018f
[    0.084777] pci 0000:00:05.0: reg 0x10: [io  0x1cb0-0x1cb7]
[    0.084784] pci 0000:00:05.0: reg 0x14: [io  0x1ca4-0x1ca7]
[    0.084792] pci 0000:00:05.0: reg 0x18: [io  0x1ca8-0x1caf]
[    0.084799] pci 0000:00:05.0: reg 0x1c: [io  0x1ca0-0x1ca3]
[    0.084806] pci 0000:00:05.0: reg 0x20: [io  0x1c90-0x1c9f]
[    0.084813] pci 0000:00:05.0: reg 0x24: [io  0x1c00-0x1c7f]
[    0.084837] pci 0000:00:05.0: PME# supported from D3cold
[    0.084925] pci 0000:00:06.0: [1039:000a] type 01 class 0x060400
[    0.084980] pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
[    0.085030] pci 0000:00:06.0: System wakeup disabled by ACPI
[    0.085114] pci 0000:00:09.0: [10ec:8169] type 00 class 0x020000
[    0.085127] pci 0000:00:09.0: reg 0x10: [io  0x1800-0x18ff]
[    0.085135] pci 0000:00:09.0: reg 0x14: [mem 0xf2004000-0xf20040ff]
[    0.085179] pci 0000:00:09.0: supports D1 D2
[    0.085182] pci 0000:00:09.0: PME# supported from D1 D2 D3hot D3cold
[    0.085273] pci 0000:00:18.0: [1022:1100] type 00 class 0x060000
[    0.085356] pci 0000:00:18.1: [1022:1101] type 00 class 0x060000
[    0.085435] pci 0000:00:18.2: [1022:1102] type 00 class 0x060000
[    0.085515] pci 0000:00:18.3: [1022:1103] type 00 class 0x060000
[    0.085672] pci 0000:01:00.0: [1002:9553] type 00 class 0x030000
[    0.085686] pci 0000:01:00.0: reg 0x10: [mem 0xe0000000-0xefffffff 64bit=
 pref]
[    0.085697] pci 0000:01:00.0: reg 0x18: [mem 0xf2100000-0xf210ffff 64bit]
[    0.085704] pci 0000:01:00.0: reg 0x20: [io  0x2000-0x20ff]
[    0.085717] pci 0000:01:00.0: reg 0x30: [mem 0x00000000-0x0001ffff pref]
[    0.085746] pci 0000:01:00.0: supports D1 D2
[    0.085797] pci 0000:01:00.1: [1002:aa38] type 00 class 0x040300
[    0.085810] pci 0000:01:00.1: reg 0x10: [mem 0xf2110000-0xf2113fff 64bit]
[    0.085862] pci 0000:01:00.1: supports D1 D2
[    0.092017] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.092061] pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
[    0.092065] pci 0000:00:01.0:   bridge window [mem 0xf2100000-0xf21fffff]
[    0.092069] pci 0000:00:01.0:   bridge window [mem 0xe0000000-0xefffffff=
 pref]
[    0.092129] pci 0000:00:06.0: PCI bridge to [bus 02]
[    0.092439] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12 =
14 15)
[    0.092960] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *9 10 11 12 =
14 15)
[    0.093477] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11 12 =
14 15)
[    0.093994] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11 12 =
14 15)
[    0.094509] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 *9 10 11 12 =
14 15)
[    0.095026] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11 12 =
14 15)
[    0.095548] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 *10 11 12 =
14 15)
[    0.096075] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 *5 6 7 9 10 11 12 =
14 15)
[    0.096936] ACPI: \_SB_.PCI0: notify handler is installed
[    0.096967] Found 1 acpi root devices
[    0.097107] vgaarb: device added: PCI:0000:01:00.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.097150] vgaarb: loaded
[    0.097186] vgaarb: bridge control possible 0000:01:00.0
[    0.097278] PCI: Using ACPI for IRQ routing
[    0.097317] PCI: pci_cache_line_size set to 64 bytes
[    0.097326] pci 0000:00:01.0: address space collision: [mem 0xf2100000-0=
xf21fffff] conflicts with GART [mem 0xf0000000-0xf3ffffff]
[    0.097370] pci 0000:00:00.0: address space collision: [mem 0xf0000000-0=
xf1ffffff] conflicts with GART [mem 0xf0000000-0xf3ffffff]
[    0.097416] pci 0000:01:00.0: no compatible bridge window for [mem 0xf21=
00000-0xf210ffff 64bit]
[    0.097458] pci 0000:01:00.1: no compatible bridge window for [mem 0xf21=
10000-0xf2113fff 64bit]
[    0.097505] pci 0000:00:03.0: address space collision: [mem 0xf2000000-0=
xf2000fff] conflicts with GART [mem 0xf0000000-0xf3ffffff]
[    0.097549] pci 0000:00:03.1: address space collision: [mem 0xf2001000-0=
xf2001fff] conflicts with GART [mem 0xf0000000-0xf3ffffff]
[    0.097592] pci 0000:00:03.2: address space collision: [mem 0xf2002000-0=
xf2002fff] conflicts with GART [mem 0xf0000000-0xf3ffffff]
[    0.097636] pci 0000:00:03.3: address space collision: [mem 0xf2003000-0=
xf2003fff] conflicts with GART [mem 0xf0000000-0xf3ffffff]
[    0.097684] pci 0000:00:09.0: address space collision: [mem 0xf2004000-0=
xf20040ff] conflicts with GART [mem 0xf0000000-0xf3ffffff]
[    0.097742] e820: reserve RAM buffer [mem 0x0009e000-0x0009ffff]
[    0.097745] e820: reserve RAM buffer [mem 0xcfee0000-0xcfffffff]
[    0.097935] Switched to clocksource refined-jiffies
[    0.100342] pnp: PnP ACPI init
[    0.100402] ACPI: bus type PNP registered
[    0.100829] system 00:00: [io  0x0480-0x048f] has been reserved
[    0.100870] system 00:00: [io  0x04d0-0x04d1] has been reserved
[    0.100909] system 00:00: [io  0xf000-0xf0fe] could not be reserved
[    0.100946] system 00:00: [io  0xf200-0xf2fe] has been reserved
[    0.100987] system 00:00: [io  0x0800-0x087f] has been reserved
[    0.101025] system 00:00: [io  0xfe00] has been reserved
[    0.101064] system 00:00: [mem 0xfec00000-0xfecfffff] could not be reser=
ved
[    0.101102] system 00:00: [mem 0xfee00000-0xfeefffff] could not be reser=
ved
[    0.101140] system 00:00: [mem 0xff780000-0xffefffff] has been reserved
[    0.101178] system 00:00: [mem 0xd0000000-0xdfffffff] has been reserved
[    0.101217] system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.101238] pnp 00:01: [dma 4]
[    0.101266] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.101325] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.101374] pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.101412] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.101467] pnp 00:05: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.101566] pnp 00:06: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.101902] pnp 00:07: [dma 3]
[    0.101963] pnp 00:07: Plug and Play ACPI device, IDs PNP0401 (active)
[    0.102177] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.102391] pnp 00:09: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.102397] pnp: PnP ACPI: found 10 devices
[    0.102436] ACPI: bus type PNP unregistered
[    0.108846] Switched to clocksource acpi_pm
[    0.108921] pci 0000:00:01.0: BAR 14: assigned [mem 0xf4000000-0xf40ffff=
f]
[    0.108960] pci 0000:00:03.0: BAR 0: assigned [mem 0xf4100000-0xf4100fff]
[    0.109001] pci 0000:00:03.1: BAR 0: assigned [mem 0xf4101000-0xf4101fff]
[    0.109040] pci 0000:00:03.2: BAR 0: assigned [mem 0xf4102000-0xf4102fff]
[    0.109080] pci 0000:00:03.3: BAR 0: assigned [mem 0xf4103000-0xf4103fff]
[    0.109119] pci 0000:00:09.0: BAR 1: assigned [mem 0xf4104000-0xf41040ff]
[    0.109161] pci 0000:01:00.0: BAR 6: assigned [mem 0xf4000000-0xf401ffff=
 pref]
[    0.109201] pci 0000:01:00.0: BAR 2: assigned [mem 0xf4020000-0xf402ffff=
 64bit]
[    0.109247] pci 0000:01:00.1: BAR 0: assigned [mem 0xf4030000-0xf4033fff=
 64bit]
[    0.109292] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.109329] pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
[    0.109368] pci 0000:00:01.0:   bridge window [mem 0xf4000000-0xf40fffff]
[    0.109407] pci 0000:00:01.0:   bridge window [mem 0xe0000000-0xefffffff=
 pref]
[    0.109449] pci 0000:00:06.0: PCI bridge to [bus 02]
[    0.109493] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    0.109496] pci_bus 0000:00: resource 5 [mem 0xd0000000-0xffffffff]
[    0.109499] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.109502] pci_bus 0000:00: resource 7 [mem 0x130000000-0xfcffffffff]
[    0.109505] pci_bus 0000:01: resource 0 [io  0x2000-0x2fff]
[    0.109508] pci_bus 0000:01: resource 1 [mem 0xf4000000-0xf40fffff]
[    0.109511] pci_bus 0000:01: resource 2 [mem 0xe0000000-0xefffffff pref]
[    0.109557] NET: Registered protocol family 2
[    0.109860] TCP established hash table entries: 32768 (order: 7, 524288 =
bytes)
[    0.110226] TCP bind hash table entries: 32768 (order: 7, 524288 bytes)
[    0.110580] TCP: Hash tables configured (established 32768 bind 32768)
[    0.110707] TCP: reno registered
[    0.110753] UDP hash table entries: 2048 (order: 4, 65536 bytes)
[    0.110845] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
[    0.111028] NET: Registered protocol family 1
[    1.876017] pci 0000:00:03.3: EHCI: BIOS handoff failed (BIOS bug?) 0101=
0001
[    1.876300] pci 0000:01:00.0: Boot video device
[    1.876306] PCI: CLS 64 bytes, default 64
[    1.876367] Unpacking initramfs...
[    2.293981] Freeing initrd memory: 14280K (ffff88003640c000 - ffff880037=
1fe000)
[    2.294122] agpgart-amd64 0000:00:00.0: AGP bridge [1039/0761]
[    2.296137] agpgart-amd64 0000:00:00.0: AGP aperture is 64M @ 0xf0000000
[    2.296294] init_memory_mapping: [mem 0xf0000000-0xf3ffffff]
[    2.296332]  [mem 0xf0000000-0xf3ffffff] page 2M
[    2.296344] PCI-DMA: using GART IOMMU.
[    2.296380] PCI-DMA: Warning: Small IOMMU 32MB. Consider increasing the =
AGP aperture in BIOS
[    2.296424] PCI-DMA: Reserving 32MB of IOMMU area in the AGP aperture
[    2.299625] Simple Boot Flag at 0x69 set to 0x1
[    2.299781] microcode: AMD CPU family 0xf not supported
[    2.300139] audit: initializing netlink socket (disabled)
[    2.300196] type=3D2000 audit(1398667332.299:1): initialized
[    2.316984] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    2.317520] VFS: Disk quotas dquot_6.5.2
[    2.317593] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    2.317742] msgmni has been set to 8050
[    2.318075] alg: No test for stdrng (krng)
[    2.318146] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 252)
[    2.318221] io scheduler noop registered
[    2.318258] io scheduler deadline registered
[    2.318299] io scheduler cfq registered (default)
[    2.318474] pcieport 0000:00:06.0: irq 40 for MSI/MSI-X
[    2.318561] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    2.318617] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    2.318718] GHES: HEST is not enabled!
[    2.318829] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    2.339228] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    2.359636] 00:09: ttyS1 at I/O 0x2f8 (irq =3D 3, base_baud =3D 115200) =
is a 16550A
[    2.359992] Linux agpgart interface v0.103
[    2.360161] i8042: PNP: PS/2 Controller [PNP0303:KEYB,PNP0f13:PS2M] at 0=
x60,0x64 irq 1,12
[    2.362984] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.363027] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.363215] mousedev: PS/2 mouse device common for all mice
[    2.363310] rtc_cmos 00:02: RTC can wake from S4
[    2.363483] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[    2.363548] rtc_cmos 00:02: alarms up to one year, y3k, 114 bytes nvram
[    2.363601] AMD IOMMUv2 driver by Joerg Roedel <joerg.roedel@amd.com>
[    2.363637] AMD IOMMUv2 functionality not available on this system
[    2.363771] TCP: cubic registered
[    2.363825] NET: Registered protocol family 10
[    2.364133] mip6: Mobile IPv6
[    2.364176] NET: Registered protocol family 17
[    2.364214] mpls_gso: MPLS GSO support
[    2.364511] registered taskstats version 1
[    2.365109] rtc_cmos 00:02: setting system clock to 2014-04-28 06:42:13 =
UTC (1398667333)
[    2.365208] PM: Hibernation image not present or could not be loaded.
[    2.366657] Freeing unused kernel memory: 972K (ffffffff818ac000 - fffff=
fff8199f000)
[    2.366703] Write protecting the kernel read-only data: 8192k
[    2.372247] Freeing unused kernel memory: 1408K (ffff8800014a0000 - ffff=
880001600000)
[    2.374105] Freeing unused kernel memory: 472K (ffff88000178a000 - ffff8=
80001800000)
[    2.395542] systemd-udevd[51]: starting version 204
[    2.407450] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input0
[    2.461736] SCSI subsystem initialized
[    2.462915] ACPI: bus type USB registered
[    2.462984] usbcore: registered new interface driver usbfs
[    2.463035] usbcore: registered new interface driver hub
[    2.466948] usbcore: registered new device driver usb
[    2.467619] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.468361] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    2.468667] ohci-pci: OHCI PCI platform driver
[    2.468961] ohci-pci 0000:00:03.0: OHCI PCI host controller
[    2.469007] ohci-pci 0000:00:03.0: new USB bus registered, assigned bus =
number 1
[    2.469082] ohci-pci 0000:00:03.0: irq 20, io mem 0xf4100000
[    2.475564] libata version 3.00 loaded.
[    2.485829] ehci-pci: EHCI PCI platform driver
[    2.526123] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[    2.526169] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    2.526209] usb usb1: Product: OHCI PCI host controller
[    2.526246] usb usb1: Manufacturer: Linux 3.12.0 ohci_hcd
[    2.526283] usb usb1: SerialNumber: 0000:00:03.0
[    2.526485] hub 1-0:1.0: USB hub found
[    2.526532] hub 1-0:1.0: 3 ports detected
[    2.528275] ohci-pci 0000:00:03.1: OHCI PCI host controller
[    2.528330] ohci-pci 0000:00:03.1: new USB bus registered, assigned bus =
number 2
[    2.528408] ohci-pci 0000:00:03.1: irq 21, io mem 0xf4101000
[    2.586119] usb usb2: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[    2.586165] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    2.587036] usb usb2: Product: OHCI PCI host controller
[    2.587073] usb usb2: Manufacturer: Linux 3.12.0 ohci_hcd
[    2.587110] usb usb2: SerialNumber: 0000:00:03.1
[    2.588184] hub 2-0:1.0: USB hub found
[    2.588235] hub 2-0:1.0: 3 ports detected
[    2.589256] ohci-pci 0000:00:03.2: OHCI PCI host controller
[    2.589310] ohci-pci 0000:00:03.2: new USB bus registered, assigned bus =
number 3
[    2.589386] ohci-pci 0000:00:03.2: irq 22, io mem 0xf4102000
[    2.646096] usb usb3: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[    2.646142] usb usb3: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    2.646182] usb usb3: Product: OHCI PCI host controller
[    2.646219] usb usb3: Manufacturer: Linux 3.12.0 ohci_hcd
[    2.646256] usb usb3: SerialNumber: 0000:00:03.2
[    2.646457] hub 3-0:1.0: USB hub found
[    2.646505] hub 3-0:1.0: 2 ports detected
[    2.647090] pata_sis 0000:00:02.5: version 0.5.2
[    2.650939] scsi0 : pata_sis
[    2.652058] scsi1 : pata_sis
[    2.652177] ata1: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0x1c80 irq=
 14
[    2.652215] ata2: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0x1c88 irq=
 15
[    2.816241] ata1.00: ATAPI: HL-DT-STDVD-ROM GDR8164B, 0F08, max UDMA/33
[    2.832225] ata1.00: configured for UDMA/33
[    2.844173] ehci-pci 0000:00:03.3: EHCI Host Controller
[    2.844224] ehci-pci 0000:00:03.3: new USB bus registered, assigned bus =
number 4
[    2.844303] ehci-pci 0000:00:03.3: cache line size of 64 is not supported
[    2.844330] ehci-pci 0000:00:03.3: irq 23, io mem 0xf4103000
[    2.852434] scsi 0:0:0:0: CD-ROM            HL-DT-ST DVD-ROM GDR8164B 0F=
08 PQ: 0 ANSI: 5
[    2.856057] ehci-pci 0000:00:03.3: USB 2.0 started, EHCI 1.00
[    2.856163] usb usb4: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[    2.856202] usb usb4: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    2.856242] usb usb4: Product: EHCI Host Controller
[    2.856279] usb usb4: Manufacturer: Linux 3.12.0 ehci_hcd
[    2.856316] usb usb4: SerialNumber: 0000:00:03.3
[    2.856517] hub 4-0:1.0: USB hub found
[    2.856566] hub 4-0:1.0: 8 ports detected
[    2.869752] sr0: scsi3-mmc drive: 32x/32x cd/rw xa/form2 cdda tray
[    2.869797] cdrom: Uniform CD-ROM driver Revision: 3.20
[    2.870423] sr 0:0:0:0: Attached scsi CD-ROM sr0
[    2.874060] sr 0:0:0:0: Attached scsi generic sg0 type 5
[    2.920096] hub 1-0:1.0: USB hub found
[    2.920150] hub 1-0:1.0: 3 ports detected
[    2.984094] hub 2-0:1.0: USB hub found
[    2.984149] hub 2-0:1.0: 3 ports detected
[    3.048101] hub 3-0:1.0: USB hub found
[    3.048154] hub 3-0:1.0: 2 ports detected
[    3.048531] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    3.048824] r8169 0000:00:09.0 (unregistered net_device): not PCI Express
[    3.049187] r8169 0000:00:09.0 eth0: RTL8110s at 0xffffc9000063c000, 00:=
30:05:d3:3e:73, XID 04000000 IRQ 19
[    3.049231] r8169 0000:00:09.0 eth0: jumbo features [frames: 7152 bytes,=
 tx checksumming: ok]
[    3.049750] sata_sis 0000:00:05.0: version 1.0
[    3.050193] sata_sis 0000:00:05.0: Detected SiS 182/965L chipset
[    3.053205] scsi2 : sata_sis
[    3.055921] scsi3 : sata_sis
[    3.056092] ata3: SATA max UDMA/133 cmd 0x1cb0 ctl 0x1ca4 bmdma 0x1c90 i=
rq 17
[    3.056132] ata4: SATA max UDMA/133 cmd 0x1ca8 ctl 0x1ca0 bmdma 0x1c98 i=
rq 17
[    3.296016] tsc: Refined TSC clocksource calibration: 1800.063 MHz
[    3.376045] ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    3.384292] ata3.00: ATA-7: WDC WD800JD-55MUA1, 10.01E01, max UDMA/133
[    3.384330] ata3.00: 156301488 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    3.392299] ata3.00: configured for UDMA/133
[    3.392474] scsi 2:0:0:0: Direct-Access     ATA      WDC WD800JD-55MU 10=
.0 PQ: 0 ANSI: 5
[    3.392682] scsi 2:0:0:0: Attached scsi generic sg1 type 0
[    3.400467] sd 2:0:0:0: [sda] 156301488 512-byte logical blocks: (80.0 G=
B/74.5 GiB)
[    3.400571] sd 2:0:0:0: [sda] Write Protect is off
[    3.400609] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    3.400635] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[    3.412492]  sda: sda1
[    3.412888] sd 2:0:0:0: [sda] Attached SCSI disk
[    3.712042] ata4: SATA link down (SStatus 0 SControl 300)
[    4.296083] Switched to clocksource tsc
[    5.552031] floppy0: no floppy controllers found
[    5.552084] work still pending
[    5.575286] device-mapper: uevent: version 1.0.3
[    5.575976] device-mapper: ioctl: 4.26.0-ioctl (2013-08-15) initialised:=
 dm-devel@redhat.com
[    5.601289] bio: create slab <bio-1> at 1
[    5.882737] PM: Starting manual resume from disk
[    5.882786] PM: Hibernation image partition 254:1 present
[    5.882788] PM: Looking for hibernation image.
[    5.883039] PM: Image not found (code -22)
[    5.883042] PM: Hibernation image not present or could not be loaded.
[    5.900556] EXT4-fs (dm-0): mounting ext3 file system using the ext4 sub=
system
[    5.941200] EXT4-fs (dm-0): mounted filesystem with ordered data mode. O=
pts: (null)
[    9.486729] systemd-udevd[335]: starting version 204
[   11.527699] parport_pc 00:07: reported by Plug and Play ACPI
[   11.527800] parport0: PC-style at 0x378 (0x778), irq 7 [PCSPP,TRISTATE]
[   11.541020] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0=
C:00/input/input2
[   11.541070] ACPI: Power Button [PWRB]
[   11.541185] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input3
[   11.541226] ACPI: Power Button [PWRF]
[   12.099115] EDAC MC: Ver: 3.0.0
[   12.103144] MCE: In-kernel MCE decoding enabled.
[   12.292250] AMD64 EDAC driver v3.4.0
[   12.292332] EDAC amd64: DRAM ECC enabled.
[   12.292372] EDAC amd64: K8 revE or earlier detected (node 0).
[   12.292450] EDAC amd64: CS0: Double data rate SDRAM
[   12.292486] EDAC amd64: CS1: Double data rate SDRAM
[   12.292522] EDAC amd64: CS2: Double data rate SDRAM
[   12.292708] EDAC MC0: Giving out device to 'amd64_edac' 'K8': DEV 0000:0=
0:18.2
[   12.296104] EDAC PCI0: Giving out device to module 'amd64_edac' controll=
er 'EDAC PCI controller': DEV '0000:00:18.2' (POLLED)
[   12.350811] input: PC Speaker as /devices/platform/pcspkr/input/input4
[   12.572410] powernow-k8: fid 0xa (1800 MHz), vid 0x6
[   12.572453] powernow-k8: fid 0x2 (1000 MHz), vid 0x12
[   12.572526] powernow-k8: Found 1 AMD Sempron(tm) Processor 3000+ (1 cpu =
cores) (version 2.20.00)
[   12.772190] tsc: Marking TSC unstable due to cpufreq changes
[   12.772293] Switched to clocksource acpi_pm
[   13.056057] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input5
[   13.181017] [drm] Initialized drm 1.1.0 20060810
[   13.292755] pcieport 0000:00:01.0: driver skip pci_set_master, fix it!
[   13.292936] hda-intel 0000:01:00.1: Handle VGA-switcheroo audio client
[   13.293041] snd_hda_intel 0000:01:00.1: irq 41 for MSI/MSI-X
[   13.295413] Uhhuh. NMI received for unknown reason 21 on CPU 0.
[   13.295459] Do you have a strange power saving mode enabled?
[   13.295500] Dazed and confused, but trying to continue
[   13.688040] intel8x0_measure_ac97_clock: measured 53910 usecs (2594 samp=
les)
[   13.688092] intel8x0: clocking to 48000
[   14.092331] [drm] radeon kernel modesetting enabled.
[   14.300022] hda-intel 0000:01:00.1: Codec #0 probe error; disabling it...
[   14.302316] Uhhuh. NMI received for unknown reason 31 on CPU 0.
[   14.302358] Do you have a strange power saving mode enabled?
[   14.302399] Dazed and confused, but trying to continue
[   15.496053] floppy0: no floppy controllers found
[   15.496115] work still pending
[   19.328027] hda-intel 0000:01:00.1: no codecs initialized
[   19.329223] [drm] initializing kernel modesetting (RV710 0x1002:0x9553 0=
x174B:0x3092).
[   19.329300] [drm] register mmio base: 0xF4020000
[   19.329342] [drm] register mmio size: 65536
[   19.329509] ATOM BIOS: 113
[   19.329620] radeon 0000:01:00.0: VRAM: 512M 0x0000000000000000 - 0x00000=
0001FFFFFFF (512M used)
[   19.329670] radeon 0000:01:00.0: GTT: 1024M 0x0000000020000000 - 0x00000=
0005FFFFFFF
[   19.329716] [drm] Detected VRAM RAM=3D512M, BAR=3D256M
[   19.329757] [drm] RAM width 64bits DDR
[   19.330933] [TTM] Zone  kernel: Available graphics memory: 2062404 kiB
[   19.330983] [TTM] Initializing pool allocator
[   19.331030] [TTM] Initializing DMA pool allocator
[   19.331113] [drm] radeon: 512M of VRAM memory ready
[   19.331155] [drm] radeon: 1024M of GTT memory ready.
[   19.408479] [drm] GART: num cpu pages 262144, num gpu pages 262144
[   19.432512] [drm] Loading RV710 Microcode
[   19.451947] [drm] PCIE GART of 1024M enabled (table at 0x000000000025D00=
0).
[   19.455506] radeon 0000:01:00.0: WB enabled
[   19.455562] radeon 0000:01:00.0: fence driver on ring 0 use gpu addr 0x0=
000000020000c00 and cpu addr 0xffff8800cdf82c00
[   19.455611] radeon 0000:01:00.0: fence driver on ring 3 use gpu addr 0x0=
000000020000c0c and cpu addr 0xffff8800cdf82c0c
[   19.456662] radeon 0000:01:00.0: fence driver on ring 5 use gpu addr 0x0=
00000000005c598 and cpu addr 0xffffc90000a9c598
[   19.457325] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[   19.457377] [drm] Driver supports precise vblank timestamp query.
[   19.457460] radeon 0000:01:00.0: irq 41 for MSI/MSI-X
[   19.457484] radeon 0000:01:00.0: radeon: using MSI.
[   19.457564] [drm] radeon: irq initialized.
[   19.505671] [drm] ring test on 0 succeeded in 1 usecs
[   19.506626] [drm] ring test on 3 succeeded in 1 usecs
[   19.701848] [drm] ring test on 5 succeeded in 1 usecs
[   19.701899] [drm] UVD initialized successfully.
[   19.702138] [drm] Enabling audio 0 support
[   19.702206] [drm] ib test on ring 0 succeeded in 0 usecs
[   19.702266] [drm] ib test on ring 3 succeeded in 0 usecs
[   19.861668] Uhhuh. NMI received for unknown reason 21 on CPU 0.
[   19.861694] Do you have a strange power saving mode enabled?
[   19.861717] Dazed and confused, but trying to continue
[   19.864027] [drm] ib test on ring 5 succeeded
[   19.864416] [drm] Radeon Display Connectors
[   19.864457] [drm] Connector 0:
[   19.864492] [drm]   DVI-I-1
[   19.864527] [drm]   HPD1
[   19.864563] [drm]   DDC: 0x7f10 0x7f10 0x7f14 0x7f14 0x7f18 0x7f18 0x7f1=
c 0x7f1c
[   19.864601] [drm]   Encoders:
[   19.864636] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[   19.864672] [drm]     DFP2: INTERNAL_UNIPHY2
[   19.864707] [drm] Connector 1:
[   19.864742] [drm]   HDMI-A-1
[   19.864777] [drm]   HPD4
[   19.864812] [drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5=
c 0x7e5c
[   19.864850] [drm]   Encoders:
[   19.864885] [drm]     DFP1: INTERNAL_UNIPHY
[   19.864920] [drm] Connector 2:
[   19.864955] [drm]   VGA-1
[   19.864991] [drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4=
c 0x7e4c
[   19.865029] [drm]   Encoders:
[   19.865064] [drm]     CRT2: INTERNAL_KLDSCP_DAC2
[   19.865131] [drm] Internal thermal controller with fan control
[   19.865218] [drm] radeon: power management initialized
[   19.932248] [drm] fb mappable at 0xE0460000
[   19.932291] [drm] vram apper at 0xE0000000
[   19.932326] [drm] size 9216000
[   19.932361] [drm] fb depth is 24
[   19.932396] [drm]    pitch is 7680
[   19.932603] fbcon: radeondrmfb (fb0) is primary device
[   20.177755] Console: switching to colour frame buffer device 180x56
[   20.191116] radeon 0000:01:00.0: fb0: radeondrmfb frame buffer device
[   20.191220] radeon 0000:01:00.0: registered panic notifier
[   20.191318] [drm] Initialized radeon 2.34.0 20080528 for 0000:01:00.0 on=
 minor 0
[   21.402354] EXT4-fs (dm-0): re-mounted. Opts: (null)
[   21.702829] EXT4-fs (dm-0): re-mounted. Opts: errors=3Dremount-ro
[   22.571971] lp0: using parport0 (interrupt-driven).
[   22.633161] ppdev: user-space parallel port driver
[   23.067419] loop: module loaded
[   23.224405] fuse init (API version 7.22)
[   23.489987] Adding 4194300k swap on /dev/mapper/vg0-boole--swap.  Priori=
ty:-1 extents:1 across:4194300k=20
[  190.181570] EXT4-fs (dm-2): mounting ext3 file system using the ext4 sub=
system
[  190.196503] EXT4-fs (dm-2): mounted filesystem with ordered data mode. O=
pts: (null)
[  191.732400] Bridge firewalling registered
[  191.778953] device eth0 entered promiscuous mode
[  191.804792] r8169 0000:00:09.0 eth0: link down
[  191.808532] r8169 0000:00:09.0 eth0: link down
[  191.813136] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[  191.818405] IPv6: ADDRCONF(NETDEV_UP): br0: link is not ready
[  193.312000] r8169 0000:00:09.0 eth0: link up
[  193.315701] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  193.319857] br0: port 1(eth0) entered forwarding state
[  193.323574] br0: port 1(eth0) entered forwarding state
[  193.327219] IPv6: ADDRCONF(NETDEV_CHANGE): br0: link becomes ready
[  196.685577] RPC: Registered named UNIX socket transport module.
[  196.689409] RPC: Registered udp transport module.
[  196.693246] RPC: Registered tcp transport module.
[  196.697024] RPC: Registered tcp NFSv4.1 backchannel transport module.
[  196.799039] FS-Cache: Loaded
[  196.951974] FS-Cache: Netfs 'nfs' registered for caching
[  197.170487] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[  197.460781] Key type dns_resolver registered
[  197.552757] NFS: Registering the id_resolver key type
[  197.556582] Key type id_resolver registered
[  197.560327] Key type id_legacy registered
[  208.352016] br0: port 1(eth0) entered forwarding state
[  212.596025] RPC: AUTH_GSS upcall timed out.
[  212.596025] Please check user daemon is running.
[  235.366798] Bluetooth: Core ver 2.16
[  235.370750] NET: Registered protocol family 31
[  235.374411] Bluetooth: HCI device and connection manager initialized
[  235.378699] Bluetooth: HCI socket layer initialized
[  235.382541] Bluetooth: L2CAP socket layer initialized
[  235.386939] Bluetooth: SCO socket layer initialized
[  235.468132] Bluetooth: RFCOMM TTY layer initialized
[  235.471700] Bluetooth: RFCOMM socket layer initialized
[  235.475217] Bluetooth: RFCOMM ver 1.11
[  235.611676] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[  235.615268] Bluetooth: BNEP filters: protocol multicast
[  235.619866] Bluetooth: BNEP socket layer initialized
[  252.305905] systemd-logind[3430]: New seat seat0.
[  252.322656] systemd-logind[3430]: Watching system buttons on /dev/input/=
event2 (Power Button)
[  252.322851] systemd-logind[3430]: Watching system buttons on /dev/input/=
event1 (Power Button)
[  252.325298] systemd-logind[3430]: New session c1 of user lightdm.
[  252.325591] systemd-logind[3430]: Linked /tmp/.X11-unix/X0 to /run/user/=
108/X11-display.
[  294.429883] systemd-logind[3430]: New session c2 of user thomas.

--=-=-=
Content-Disposition: inline; filename=dmesg-v3.14
Content-Transfer-Encoding: quoted-printable

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.14.0 (thomas@hertz) (gcc version 4.8.1 (Ubun=
tu/Linaro 4.8.1-10ubuntu9) ) #2 SMP Mon Apr 28 08:09:41 CEST 2014
[    0.000000] Command line: BOOT_IMAGE=3D/boot/vmlinuz-3.14.0 root=3D/dev/=
mapper/vg0-boole--root ro
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009dfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009e000-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000e4000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000cfedffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000cfee0000-0x00000000cfeeefff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x00000000cfeef000-0x00000000cfefffff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x00000000cff00000-0x00000000cfffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec0ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fff00000-0x00000000ffffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000012fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.34 present.
[    0.000000] DMI: FUJITSU SIEMENS D2264-A1            /D2264-A1, BIOS 5.0=
0 R1.07-01.2264.A1            06/07/2006
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] AGP bridge at 00:00:00
[    0.000000] Aperture from AGP @ f0000000 old size 32 MB
[    0.000000] Aperture from AGP @ f0000000 size 32 MB (APSIZE f38)
[    0.000000] e820: last_pfn =3D 0x130000 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-D3FFF write-protect
[    0.000000]   D4000-E3FFF uncachable
[    0.000000]   E4000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0000000000 mask FF80000000 write-back
[    0.000000]   1 base 0100000000 mask FFE0000000 write-back
[    0.000000]   2 base 0120000000 mask FFF0000000 write-back
[    0.000000]   3 base 0080000000 mask FFC0000000 write-back
[    0.000000]   4 base 00C0000000 mask FFF0000000 write-back
[    0.000000]   5 base 00CFF00000 mask FFFFF00000 uncachable
[    0.000000]   6 base 00F0000000 mask FFFE000000 write-combining
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x701060007=
0106
[    0.000000] e820: last_pfn =3D 0xcfee0 max_arch_pfn =3D 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000f73b0-0x000f73bf] mapped at =
[ffff8800000f73b0]
[    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01aa1000, 0x01aa1fff] PGTABLE
[    0.000000] BRK [0x01aa2000, 0x01aa2fff] PGTABLE
[    0.000000] BRK [0x01aa3000, 0x01aa3fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12fe00000-0x12fffffff]
[    0.000000]  [mem 0x12fe00000-0x12fffffff] page 2M
[    0.000000] BRK [0x01aa4000, 0x01aa4fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12c000000-0x12fdfffff]
[    0.000000]  [mem 0x12c000000-0x12fdfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x100000000-0x12bffffff]
[    0.000000]  [mem 0x100000000-0x12bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0xcfedffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0xcfdfffff] page 2M
[    0.000000]  [mem 0xcfe00000-0xcfedffff] page 4k
[    0.000000] RAMDISK: [mem 0x36392000-0x371c0fff]
[    0.000000] ACPI: RSDP 00000000000f7350 000024 (v02 PTLTD )
[    0.000000] ACPI: XSDT 00000000cfeeb7e4 00004C (v01 PTLTD  ? XSDT   0005=
0000  LTP 00000000)
[    0.000000] ACPI: FACP 00000000cfeeb8a4 0000F4 (v03 FSC       \xfffffff7=
P?-? 00050000      000F4240)
[    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/Pm1a=
ControlBlock: 16/32 (20131218/tbfadt-603)
[    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/PmTi=
merBlock: 32/24 (20131218/tbfadt-603)
[    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/Gpe0=
Block: 32/16 (20131218/tbfadt-603)
[    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/Gpe1=
Block: 32/16 (20131218/tbfadt-603)
[    0.000000] ACPI BIOS Warning (bug): Invalid length for FADT/Pm1aControl=
Block: 32, using default 16 (20131218/tbfadt-684)
[    0.000000] ACPI BIOS Warning (bug): Invalid length for FADT/PmTimerBloc=
k: 24, using default 32 (20131218/tbfadt-684)
[    0.000000] ACPI: DSDT 00000000cfeeb998 0034FB (v01 FSC    D2030    0005=
0000 MSFT 02000002)
[    0.000000] ACPI: FACS 00000000cfeeffc0 000040
[    0.000000] ACPI: SSDT 00000000cfeeee93 0000B5 (v01 PTLTD  POWERNOW 0005=
0000  LTP 00000001)
[    0.000000] ACPI: APIC 00000000cfeeef48 000050 (v01 PTLTD  ? APIC   0005=
0000  LTP 00000000)
[    0.000000] ACPI: MCFG 00000000cfeeef98 000040 (v01 PTLTD    MCFG   0005=
0000  LTP 00000000)
[    0.000000] ACPI: BOOT 00000000cfeeefd8 000028 (v01 PTLTD  $SBFTBL$ 0005=
0000  LTP 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] Scanning NUMA topology in Northbridge 24
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000012fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x12fffffff]
[    0.000000]   NODE_DATA [mem 0x12fff7000-0x12fffbfff]
[    0.000000]  [ffffea0000000000-ffffea00043fffff] PMD -> [ffff88012b60000=
0-ffff88012effffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x12fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009dfff]
[    0.000000]   node   0: [mem 0x00100000-0xcfedffff]
[    0.000000]   node   0: [mem 0x100000000-0x12fffffff]
[    0.000000] On node 0 totalpages: 1048189
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 11589 pages used for memmap
[    0.000000]   DMA32 zone: 847584 pages, LIFO batch:31
[    0.000000]   Normal zone: 2688 pages used for memmap
[    0.000000]   Normal zone: 196608 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xf008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 20, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000e3fff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e4000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xcfee0000-0xcfeeefff]
[    0.000000] PM: Registered nosave memory: [mem 0xcfeef000-0xcfefffff]
[    0.000000] PM: Registered nosave memory: [mem 0xcff00000-0xcfffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xd0000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfec0ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec10000-0xfedfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfee00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee01000-0xffefffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfff00000-0xffffffff]
[    0.000000] e820: [mem 0xd0000000-0xfebfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:1 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88012fc00000 s86016 r8192=
 d20480 u2097152
[    0.000000] pcpu-alloc: s86016 r8192 d20480 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 1033835
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=3D/boot/vmlinuz-3.14.0 root=
=3D/dev/mapper/vg0-boole--root ro
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] AGP bridge at 00:00:00
[    0.000000] Aperture from AGP @ f0000000 old size 32 MB
[    0.000000] Aperture from AGP @ f0000000 size 32 MB (APSIZE f38)
[    0.000000] Node 0: aperture @ f0000000 size 64 MB
[    0.000000] Memory: 4041400K/4192756K available (4880K kernel code, 702K=
 rwdata, 1624K rodata, 996K init, 960K bss, 151356K reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=3D512 to nr_cpu_ids=3D1.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D1
[    0.000000] NR_IRQS:33024 nr_irqs:256 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] allocated 16777216 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't wan=
t memory cgroups
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 1799.970 MHz processor
[    0.008013] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 3599.94 BogoMIPS (lpj=3D7199880)
[    0.008086] pid_max: default: 32768 minimum: 301
[    0.008134] ACPI: Core revision 20131218
[    0.013040] ACPI: All ACPI Tables successfully acquired
[    0.014533] Security Framework initialized
[    0.014574] AppArmor: AppArmor disabled by boot time parameter
[    0.014611] Yama: becoming mindful.
[    0.015046] Dentry cache hash table entries: 524288 (order: 10, 4194304 =
bytes)
[    0.017849] Inode-cache hash table entries: 262144 (order: 9, 2097152 by=
tes)
[    0.019209] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.019254] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 b=
ytes)
[    0.019635] Initializing cgroup subsys memory
[    0.019682] Initializing cgroup subsys devices
[    0.019719] Initializing cgroup subsys freezer
[    0.019755] Initializing cgroup subsys net_cls
[    0.019792] Initializing cgroup subsys blkio
[    0.019828] Initializing cgroup subsys perf_event
[    0.019894] tseg: 00cff00000
[    0.019898] mce: CPU supports 5 MCE banks
[    0.019945] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 4
[    0.019945] Last level dTLB entries: 4KB 512, 2MB 8, 4MB 4, 1GB 0
[    0.019945] tlb_flushall_shift: 6
[    0.025016] Freeing SMP alternatives memory: 20K (ffffffff819aa000 - fff=
fffff819af000)
[    0.026481] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D0 pin2=3D0
[    0.066206] smpboot: CPU0: AMD Sempron(tm) Processor 3000+ (fam: 0f, mod=
el: 2f, stepping: 02)
[    0.068000] Performance Events: AMD PMU driver.
[    0.068000] ... version:                0
[    0.068000] ... bit width:              48
[    0.068000] ... generic registers:      4
[    0.068000] ... value mask:             0000ffffffffffff
[    0.068000] ... max period:             00007fffffffffff
[    0.068000] ... fixed-purpose events:   0
[    0.068000] ... event mask:             000000000000000f
[    0.068000] x86: Booted up 1 node, 1 CPUs
[    0.068000] smpboot: Total of 1 processors activated (3599.94 BogoMIPS)
[    0.068000] devtmpfs: initialized
[    0.070871] NMI watchdog: enabled on all CPUs, permanently consumes one =
hw-PMU counter.
[    0.070991] PM: Registering ACPI NVS region [mem 0xcfeef000-0xcfefffff] =
(69632 bytes)
[    0.071315] NET: Registered protocol family 16
[    0.071537] cpuidle: using governor ladder
[    0.071574] cpuidle: using governor menu
[    0.071615] node 0 link 0: io port [0, fffff]
[    0.071618] TOM: 00000000d0000000 aka 3328M
[    0.071655] node 0 link 0: mmio [d0000000, dfffffff]
[    0.071659] node 0 link 0: mmio [a0000, bffff]
[    0.071662] node 0 link 0: mmio [d0000000, fe0bffff]
[    0.071664] TOM2: 0000000130000000 aka 4864M
[    0.071701] bus: [bus 00-ff] on node 0 link 0
[    0.071703] bus: 00 [io  0x0000-0xffff]
[    0.071705] bus: 00 [mem 0xd0000000-0xffffffff]
[    0.071707] bus: 00 [mem 0x000a0000-0x000bffff]
[    0.071709] bus: 00 [mem 0x130000000-0xfcffffffff]
[    0.071750] ACPI: bus type PCI registered
[    0.071787] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.071932] PCI: MMCONFIG for domain 0000 [bus 00-01] at [mem 0xd0000000=
-0xd01fffff] (base 0xd0000000)
[    0.071973] PCI: not using MMCONFIG
[    0.072016] PCI: Using configuration type 1 for base access
[    0.073347] bio: create slab <bio-0> at 0
[    0.073503] ACPI: Added _OSI(Module Device)
[    0.073541] ACPI: Added _OSI(Processor Device)
[    0.073576] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.073612] ACPI: Added _OSI(Processor Aggregator Device)
[    0.076055] ACPI: Interpreter enabled
[    0.076108] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20131218/hwxface-580)
[    0.076223] ACPI: (supports S0 S1 S3 S4 S5)
[    0.076259] ACPI: Using IOAPIC for interrupt routing
[    0.076324] PCI: MMCONFIG for domain 0000 [bus 00-01] at [mem 0xd0000000=
-0xd01fffff] (base 0xd0000000)
[    0.076728] PCI: MMCONFIG at [mem 0xd0000000-0xd01fffff] reserved in ACP=
I motherboard resources
[    0.076908] PCI: Ignoring host bridge windows from ACPI; if necessary, u=
se "pci=3Duse_crs" and report a bug
[    0.077065] ACPI: No dock devices found.
[    0.082861] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.083740] acpi PNP0A03:00: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    0.083784] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.083919] acpi PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ign=
ored)
[    0.083922] acpi PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ign=
ored)
[    0.083925] acpi PNP0A03:00: host bridge window [mem 0x000a0000-0x000bff=
ff] (ignored)
[    0.083928] acpi PNP0A03:00: host bridge window [mem 0x000c8000-0x000dff=
ff] (ignored)
[    0.083931] acpi PNP0A03:00: host bridge window [mem 0xd0000000-0xfebfff=
ff] (ignored)
[    0.083934] acpi PNP0A03:00: host bridge window [mem 0xfed00000-0xfedfff=
ff] (ignored)
[    0.083937] acpi PNP0A03:00: host bridge window [mem 0xfef00000-0xff77ff=
ff] (ignored)
[    0.083939] PCI: root bus 00: hardware-probed resources
[    0.083945] acpi PNP0A03:00: [Firmware Info]: MMCONFIG for domain 0000 [=
bus 00-01] only partially covers this bridge
[    0.084187] PCI host bridge to bus 0000:00
[    0.084226] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.084263] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.084300] pci_bus 0000:00: root bus resource [mem 0xd0000000-0xfffffff=
f]
[    0.084338] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.084375] pci_bus 0000:00: root bus resource [mem 0x130000000-0xfcffff=
ffff]
[    0.084426] pci 0000:00:00.0: [1039:0761] type 00 class 0x060000
[    0.084435] pci 0000:00:00.0: reg 0x10: [mem 0xf0000000-0xf1ffffff]
[    0.084569] pci 0000:00:01.0: [1039:0004] type 01 class 0x060400
[    0.084623] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.084664] pci 0000:00:01.0: System wakeup disabled by ACPI
[    0.084755] pci 0000:00:02.0: [1039:0965] type 00 class 0x060100
[    0.084877] pci 0000:00:02.5: [1039:5513] type 00 class 0x01018a
[    0.084899] pci 0000:00:02.5: reg 0x10: [io  0x01f0-0x01f7]
[    0.084906] pci 0000:00:02.5: reg 0x14: [io  0x03f4-0x03f7]
[    0.084913] pci 0000:00:02.5: reg 0x18: [io  0x0170-0x0177]
[    0.084920] pci 0000:00:02.5: reg 0x1c: [io  0x0374-0x0377]
[    0.084928] pci 0000:00:02.5: reg 0x20: [io  0x1c80-0x1c8f]
[    0.084957] pci 0000:00:02.5: PME# supported from D3cold
[    0.085045] pci 0000:00:02.7: [1039:7012] type 00 class 0x040100
[    0.085058] pci 0000:00:02.7: reg 0x10: [io  0x1400-0x14ff]
[    0.085065] pci 0000:00:02.7: reg 0x14: [io  0x1000-0x107f]
[    0.085110] pci 0000:00:02.7: supports D1 D2
[    0.085113] pci 0000:00:02.7: PME# supported from D3hot D3cold
[    0.085149] pci 0000:00:02.7: System wakeup disabled by ACPI
[    0.085238] pci 0000:00:03.0: [1039:7001] type 00 class 0x0c0310
[    0.085248] pci 0000:00:03.0: reg 0x10: [mem 0xf2000000-0xf2000fff]
[    0.085371] pci 0000:00:03.0: System wakeup disabled by ACPI
[    0.085469] pci 0000:00:03.1: [1039:7001] type 00 class 0x0c0310
[    0.085479] pci 0000:00:03.1: reg 0x10: [mem 0xf2001000-0xf2001fff]
[    0.085595] pci 0000:00:03.1: System wakeup disabled by ACPI
[    0.085695] pci 0000:00:03.2: [1039:7001] type 00 class 0x0c0310
[    0.085705] pci 0000:00:03.2: reg 0x10: [mem 0xf2002000-0xf2002fff]
[    0.085814] pci 0000:00:03.2: System wakeup disabled by ACPI
[    0.085914] pci 0000:00:03.3: [1039:7002] type 00 class 0x0c0320
[    0.085926] pci 0000:00:03.3: reg 0x10: [mem 0xf2003000-0xf2003fff]
[    0.085973] pci 0000:00:03.3: PME# supported from D0 D3hot D3cold
[    0.086012] pci 0000:00:03.3: System wakeup disabled by ACPI
[    0.086115] pci 0000:00:05.0: [1039:0182] type 00 class 0x01018f
[    0.086127] pci 0000:00:05.0: reg 0x10: [io  0x1cb0-0x1cb7]
[    0.086135] pci 0000:00:05.0: reg 0x14: [io  0x1ca4-0x1ca7]
[    0.086142] pci 0000:00:05.0: reg 0x18: [io  0x1ca8-0x1caf]
[    0.086149] pci 0000:00:05.0: reg 0x1c: [io  0x1ca0-0x1ca3]
[    0.086156] pci 0000:00:05.0: reg 0x20: [io  0x1c90-0x1c9f]
[    0.086164] pci 0000:00:05.0: reg 0x24: [io  0x1c00-0x1c7f]
[    0.086188] pci 0000:00:05.0: PME# supported from D3cold
[    0.086288] pci 0000:00:06.0: [1039:000a] type 01 class 0x060400
[    0.086349] pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
[    0.086393] pci 0000:00:06.0: System wakeup disabled by ACPI
[    0.086493] pci 0000:00:09.0: [10ec:8169] type 00 class 0x020000
[    0.086506] pci 0000:00:09.0: reg 0x10: [io  0x1800-0x18ff]
[    0.086514] pci 0000:00:09.0: reg 0x14: [mem 0xf2004000-0xf20040ff]
[    0.086559] pci 0000:00:09.0: supports D1 D2
[    0.086561] pci 0000:00:09.0: PME# supported from D1 D2 D3hot D3cold
[    0.086665] pci 0000:00:18.0: [1022:1100] type 00 class 0x060000
[    0.086756] pci 0000:00:18.1: [1022:1101] type 00 class 0x060000
[    0.086843] pci 0000:00:18.2: [1022:1102] type 00 class 0x060000
[    0.086932] pci 0000:00:18.3: [1022:1103] type 00 class 0x060000
[    0.087089] pci 0000:01:00.0: [1002:9553] type 00 class 0x030000
[    0.087103] pci 0000:01:00.0: reg 0x10: [mem 0xe0000000-0xefffffff 64bit=
 pref]
[    0.087114] pci 0000:01:00.0: reg 0x18: [mem 0xf2100000-0xf210ffff 64bit]
[    0.087121] pci 0000:01:00.0: reg 0x20: [io  0x2000-0x20ff]
[    0.087134] pci 0000:01:00.0: reg 0x30: [mem 0x00000000-0x0001ffff pref]
[    0.087166] pci 0000:01:00.0: supports D1 D2
[    0.087230] pci 0000:01:00.1: [1002:aa38] type 00 class 0x040300
[    0.087243] pci 0000:01:00.1: reg 0x10: [mem 0xf2110000-0xf2113fff 64bit]
[    0.087297] pci 0000:01:00.1: supports D1 D2
[    0.092016] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.092058] pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
[    0.092062] pci 0000:00:01.0:   bridge window [mem 0xf2100000-0xf21fffff]
[    0.092066] pci 0000:00:01.0:   bridge window [mem 0xe0000000-0xefffffff=
 pref]
[    0.092128] pci 0000:00:06.0: PCI bridge to [bus 02]
[    0.092359] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12 =
14 15)
[    0.092880] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *9 10 11 12 =
14 15)
[    0.093395] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11 12 =
14 15)
[    0.093909] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11 12 =
14 15)
[    0.094423] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 *9 10 11 12 =
14 15)
[    0.094937] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11 12 =
14 15)
[    0.095458] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 *10 11 12 =
14 15)
[    0.095976] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 *5 6 7 9 10 11 12 =
14 15)
[    0.096986] vgaarb: device added: PCI:0000:01:00.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.097030] vgaarb: loaded
[    0.097065] vgaarb: bridge control possible 0000:01:00.0
[    0.097165] PCI: Using ACPI for IRQ routing
[    0.097204] PCI: pci_cache_line_size set to 64 bytes
[    0.097246] e820: reserve RAM buffer [mem 0x0009e000-0x0009ffff]
[    0.097249] e820: reserve RAM buffer [mem 0xcfee0000-0xcfffffff]
[    0.097452] Switched to clocksource refined-jiffies
[    0.100654] pnp: PnP ACPI init
[    0.100718] ACPI: bus type PNP registered
[    0.101152] system 00:00: [io  0x0480-0x048f] has been reserved
[    0.101194] system 00:00: [io  0x04d0-0x04d1] has been reserved
[    0.101232] system 00:00: [io  0xf000-0xf0fe] could not be reserved
[    0.101270] system 00:00: [io  0xf200-0xf2fe] has been reserved
[    0.101308] system 00:00: [io  0x0800-0x087f] has been reserved
[    0.101346] system 00:00: [io  0xfe00] has been reserved
[    0.101384] system 00:00: [mem 0xfec00000-0xfecfffff] could not be reser=
ved
[    0.101422] system 00:00: [mem 0xfee00000-0xfeefffff] could not be reser=
ved
[    0.101460] system 00:00: [mem 0xff780000-0xffefffff] has been reserved
[    0.101498] system 00:00: [mem 0xd0000000-0xdfffffff] has been reserved
[    0.101537] system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.101558] pnp 00:01: [dma 4]
[    0.101594] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.101656] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.101712] pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.101763] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.101832] pnp 00:05: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.101943] pnp 00:06: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.102314] pnp 00:07: [dma 3]
[    0.102380] pnp 00:07: Plug and Play ACPI device, IDs PNP0401 (active)
[    0.102599] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.102832] pnp 00:09: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.102839] pnp: PnP ACPI: found 10 devices
[    0.102878] ACPI: bus type PNP unregistered
[    0.109813] Switched to clocksource acpi_pm
[    0.109888] pci 0000:01:00.0: BAR 6: assigned [mem 0xf2120000-0xf213ffff=
 pref]
[    0.109929] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.109966] pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
[    0.110006] pci 0000:00:01.0:   bridge window [mem 0xf2100000-0xf21fffff]
[    0.110044] pci 0000:00:01.0:   bridge window [mem 0xe0000000-0xefffffff=
 pref]
[    0.110086] pci 0000:00:06.0: PCI bridge to [bus 02]
[    0.110130] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    0.110133] pci_bus 0000:00: resource 5 [mem 0xd0000000-0xffffffff]
[    0.110136] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.110138] pci_bus 0000:00: resource 7 [mem 0x130000000-0xfcffffffff]
[    0.110142] pci_bus 0000:01: resource 0 [io  0x2000-0x2fff]
[    0.110144] pci_bus 0000:01: resource 1 [mem 0xf2100000-0xf21fffff]
[    0.110147] pci_bus 0000:01: resource 2 [mem 0xe0000000-0xefffffff pref]
[    0.110195] NET: Registered protocol family 2
[    0.110470] TCP established hash table entries: 32768 (order: 6, 262144 =
bytes)
[    0.110710] TCP bind hash table entries: 32768 (order: 7, 524288 bytes)
[    0.111038] TCP: Hash tables configured (established 32768 bind 32768)
[    0.111166] TCP: reno registered
[    0.111215] UDP hash table entries: 2048 (order: 4, 65536 bytes)
[    0.111303] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
[    0.111489] NET: Registered protocol family 1
[    1.876017] pci 0000:00:03.3: EHCI: BIOS handoff failed (BIOS bug?) 0101=
0001
[    1.876296] pci 0000:01:00.0: Boot video device
[    1.876303] PCI: CLS 64 bytes, default 64
[    1.876376] Unpacking initramfs...
[    2.300568] Freeing initrd memory: 14524K (ffff880036392000 - ffff880037=
1c1000)
[    2.300712] agpgart-amd64 0000:00:00.0: AGP bridge [1039/0761]
[    2.300756] agpgart: Aperture conflicts with PCI mapping.
[    2.300793] agpgart-amd64 0000:00:00.0: aperture from AGP @ f0000000 siz=
e 32 MB
[    2.301901] agpgart-amd64 0000:00:00.0: AGP aperture is 32M @ 0xf0000000
[    2.302025] init_memory_mapping: [mem 0xf0000000-0xf1ffffff]
[    2.302062]  [mem 0xf0000000-0xf1ffffff] page 2M
[    2.302074] PCI-DMA: using GART IOMMU.
[    2.302109] PCI-DMA: Warning: Small IOMMU 16MB. Consider increasing the =
AGP aperture in BIOS
[    2.302151] PCI-DMA: Reserving 16MB of IOMMU area in the AGP aperture
[    2.305387] Simple Boot Flag at 0x69 set to 0x1
[    2.305502] microcode: AMD CPU family 0xf not supported
[    2.305863] futex hash table entries: 256 (order: 2, 16384 bytes)
[    2.305967] audit: initializing netlink subsys (disabled)
[    2.306031] audit: type=3D2000 audit(1398668250.303:1): initialized
[    2.323183] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    2.323410] VFS: Disk quotas dquot_6.5.2
[    2.323474] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    2.323592] msgmni has been set to 8050
[    2.323938] alg: No test for stdrng (krng)
[    2.324034] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 252)
[    2.324126] io scheduler noop registered
[    2.324163] io scheduler deadline registered
[    2.324205] io scheduler cfq registered (default)
[    2.324385] pcieport 0000:00:06.0: irq 40 for MSI/MSI-X
[    2.324491] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    2.324550] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    2.324670] GHES: HEST is not enabled!
[    2.324795] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    2.345190] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    2.365622] 00:09: ttyS1 at I/O 0x2f8 (irq =3D 3, base_baud =3D 115200) =
is a 16550A
[    2.366025] Linux agpgart interface v0.103
[    2.366180] i8042: PNP: PS/2 Controller [PNP0303:KEYB,PNP0f13:PS2M] at 0=
x60,0x64 irq 1,12
[    2.369012] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.369057] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.369276] mousedev: PS/2 mouse device common for all mice
[    2.369373] rtc_cmos 00:02: RTC can wake from S4
[    2.369556] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[    2.369621] rtc_cmos 00:02: alarms up to one year, y3k, 114 bytes nvram
[    2.369672] AMD IOMMUv2 driver by Joerg Roedel <joerg.roedel@amd.com>
[    2.369708] AMD IOMMUv2 functionality not available on this system
[    2.369890] TCP: cubic registered
[    2.369943] NET: Registered protocol family 10
[    2.370299] mip6: Mobile IPv6
[    2.370341] NET: Registered protocol family 17
[    2.370380] mpls_gso: MPLS GSO support
[    2.370724] registered taskstats version 1
[    2.371193] rtc_cmos 00:02: setting system clock to 2014-04-28 06:57:31 =
UTC (1398668251)
[    2.371300] PM: Hibernation image not present or could not be loaded.
[    2.372807] Freeing unused kernel memory: 996K (ffffffff818b1000 - fffff=
fff819aa000)
[    2.372854] Write protecting the kernel read-only data: 8192k
[    2.377630] Freeing unused kernel memory: 1252K (ffff8800014c7000 - ffff=
880001600000)
[    2.379281] Freeing unused kernel memory: 424K (ffff880001796000 - ffff8=
80001800000)
[    2.400281] systemd-udevd[52]: starting version 204
[    2.412851] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input0
[    2.459507] ACPI: bus type USB registered
[    2.459584] usbcore: registered new interface driver usbfs
[    2.459634] usbcore: registered new interface driver hub
[    2.462619] SCSI subsystem initialized
[    2.464551] usbcore: registered new device driver usb
[    2.465231] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.465718] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    2.466023] ohci-pci: OHCI PCI platform driver
[    2.466292] ohci-pci 0000:00:03.0: OHCI PCI host controller
[    2.466339] ohci-pci 0000:00:03.0: new USB bus registered, assigned bus =
number 1
[    2.466431] ohci-pci 0000:00:03.0: irq 20, io mem 0xf2000000
[    2.475263] libata version 3.00 loaded.
[    2.522123] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[    2.522168] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    2.522208] usb usb1: Product: OHCI PCI host controller
[    2.522245] usb usb1: Manufacturer: Linux 3.14.0 ohci_hcd
[    2.522281] usb usb1: SerialNumber: 0000:00:03.0
[    2.522511] hub 1-0:1.0: USB hub found
[    2.522560] hub 1-0:1.0: 3 ports detected
[    2.522753] pata_sis 0000:00:02.5: version 0.5.2
[    2.531336] scsi0 : pata_sis
[    2.536093] scsi1 : pata_sis
[    2.536233] ata1: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0x1c80 irq=
 14
[    2.536271] ata2: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0x1c88 irq=
 15
[    2.536704] ohci-pci 0000:00:03.1: OHCI PCI host controller
[    2.536754] ohci-pci 0000:00:03.1: new USB bus registered, assigned bus =
number 2
[    2.536845] ohci-pci 0000:00:03.1: irq 21, io mem 0xf2001000
[    2.554325] ehci-pci: EHCI PCI platform driver
[    2.594093] usb usb2: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[    2.594138] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    2.594177] usb usb2: Product: OHCI PCI host controller
[    2.594214] usb usb2: Manufacturer: Linux 3.14.0 ohci_hcd
[    2.594250] usb usb2: SerialNumber: 0000:00:03.1
[    2.594479] hub 2-0:1.0: USB hub found
[    2.594527] hub 2-0:1.0: 3 ports detected
[    2.595145] ehci-pci 0000:00:03.3: EHCI Host Controller
[    2.595197] ehci-pci 0000:00:03.3: new USB bus registered, assigned bus =
number 3
[    2.596176] ehci-pci 0000:00:03.3: cache line size of 64 is not supported
[    2.596203] ehci-pci 0000:00:03.3: irq 23, io mem 0xf2003000
[    2.608068] ehci-pci 0000:00:03.3: USB 2.0 started, EHCI 1.00
[    2.608162] usb usb3: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[    2.608200] usb usb3: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    2.608240] usb usb3: Product: EHCI Host Controller
[    2.608276] usb usb3: Manufacturer: Linux 3.14.0 ehci_hcd
[    2.608313] usb usb3: SerialNumber: 0000:00:03.3
[    2.608533] hub 3-0:1.0: USB hub found
[    2.608578] hub 3-0:1.0: 8 ports detected
[    2.672146] hub 1-0:1.0: USB hub found
[    2.672199] hub 1-0:1.0: 3 ports detected
[    2.700238] ata1.00: ATAPI: HL-DT-STDVD-ROM GDR8164B, 0F08, max UDMA/33
[    2.716227] ata1.00: configured for UDMA/33
[    2.736103] hub 2-0:1.0: USB hub found
[    2.736154] hub 2-0:1.0: 3 ports detected
[    2.736559] sata_sis 0000:00:05.0: version 1.0
[    2.736779] sata_sis 0000:00:05.0: Detected SiS 182/965L chipset
[    2.736949] scsi 0:0:0:0: CD-ROM            HL-DT-ST DVD-ROM GDR8164B 0F=
08 PQ: 0 ANSI: 5
[    2.741397] scsi2 : sata_sis
[    2.741705] scsi3 : sata_sis
[    2.741831] ata3: SATA max UDMA/133 cmd 0x1cb0 ctl 0x1ca4 bmdma 0x1c90 i=
rq 17
[    2.741870] ata4: SATA max UDMA/133 cmd 0x1ca8 ctl 0x1ca0 bmdma 0x1c98 i=
rq 17
[    2.741949] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.742220] r8169 0000:00:09.0 (unregistered net_device): not PCI Express
[    2.742587] r8169 0000:00:09.0 eth0: RTL8110s at 0xffffc9000092c000, 00:=
30:05:d3:3e:73, XID 04000000 IRQ 19
[    2.742631] r8169 0000:00:09.0 eth0: jumbo features [frames: 7152 bytes,=
 tx checksumming: ok]
[    2.743241] ohci-pci 0000:00:03.2: OHCI PCI host controller
[    2.743294] ohci-pci 0000:00:03.2: new USB bus registered, assigned bus =
number 4
[    2.743385] ohci-pci 0000:00:03.2: irq 22, io mem 0xf2002000
[    2.798068] usb usb4: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[    2.798112] usb usb4: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    2.798152] usb usb4: Product: OHCI PCI host controller
[    2.798188] usb usb4: Manufacturer: Linux 3.14.0 ohci_hcd
[    2.798225] usb usb4: SerialNumber: 0000:00:03.2
[    2.798617] hub 4-0:1.0: USB hub found
[    2.798672] hub 4-0:1.0: 2 ports detected
[    3.060045] ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    3.084305] ata3.00: ATA-7: WDC WD800JD-55MUA1, 10.01E01, max UDMA/133
[    3.084344] ata3.00: 156301488 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    3.092283] ata3.00: configured for UDMA/133
[    3.092455] scsi 2:0:0:0: Direct-Access     ATA      WDC WD800JD-55MU 10=
.0 PQ: 0 ANSI: 5
[    3.320017] tsc: Refined TSC clocksource calibration: 1800.063 MHz
[    3.412037] ata4: SATA link down (SStatus 0 SControl 300)
[    3.436540] sr0: scsi3-mmc drive: 32x/32x cd/rw xa/form2 cdda tray
[    3.436585] cdrom: Uniform CD-ROM driver Revision: 3.20
[    3.437247] sr 0:0:0:0: Attached scsi CD-ROM sr0
[    3.437795] sd 2:0:0:0: [sda] 156301488 512-byte logical blocks: (80.0 G=
B/74.5 GiB)
[    3.437892] sd 2:0:0:0: [sda] Write Protect is off
[    3.437931] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    3.437954] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[    3.442309] sr 0:0:0:0: Attached scsi generic sg0 type 5
[    3.442485] sd 2:0:0:0: Attached scsi generic sg1 type 0
[    3.455579]  sda: sda1
[    3.455977] sd 2:0:0:0: [sda] Attached SCSI disk
[    4.320080] Switched to clocksource tsc
[    5.536028] floppy0: no floppy controllers found
[    5.536079] work still pending
[    5.559188] device-mapper: uevent: version 1.0.3
[    5.559887] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised:=
 dm-devel@redhat.com
[    5.566766] random: lvm urandom read with 39 bits of entropy available
[    5.585082] bio: create slab <bio-1> at 1
[    5.867330] PM: Starting manual resume from disk
[    5.867379] PM: Hibernation image partition 254:1 present
[    5.867380] PM: Looking for hibernation image.
[    5.867632] PM: Image not found (code -22)
[    5.867636] PM: Hibernation image not present or could not be loaded.
[    5.885318] EXT4-fs (dm-0): mounting ext3 file system using the ext4 sub=
system
[    5.926062] EXT4-fs (dm-0): mounted filesystem with ordered data mode. O=
pts: (null)
[    7.436776] random: nonblocking pool is initialized
[    9.484243] systemd-udevd[339]: starting version 204
[   11.847543] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0=
C:00/input/input2
[   11.847592] ACPI: Power Button [PWRB]
[   11.849721] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input3
[   11.849769] ACPI: Power Button [PWRF]
[   12.055559] parport_pc 00:07: reported by Plug and Play ACPI
[   12.055657] parport0: PC-style at 0x378 (0x778), irq 7 [PCSPP,TRISTATE]
[   12.495906] input: PC Speaker as /devices/platform/pcspkr/input/input4
[   12.527830] EDAC MC: Ver: 3.0.0
[   12.531982] MCE: In-kernel MCE decoding enabled.
[   12.794771] powernow-k8: fid 0xa (1800 MHz), vid 0x6
[   12.794814] powernow-k8: fid 0x2 (1000 MHz), vid 0x12
[   12.794894] powernow-k8: Found 1 AMD Sempron(tm) Processor 3000+ (1 cpu =
cores) (version 2.20.00)
[   12.859656] AMD64 EDAC driver v3.4.0
[   12.859733] EDAC amd64: DRAM ECC enabled.
[   12.859772] EDAC amd64: K8 revE or earlier detected (node 0).
[   12.859854] EDAC amd64: CS0: Double data rate SDRAM
[   12.859890] EDAC amd64: CS1: Double data rate SDRAM
[   12.859925] EDAC amd64: CS2: Double data rate SDRAM
[   12.860213] EDAC MC0: Giving out device to module amd64_edac controller =
K8: DEV 0000:00:18.2 (INTERRUPT)
[   12.860301] EDAC PCI0: Giving out device to module amd64_edac controller=
 EDAC PCI controller: DEV 0000:00:18.2 (POLLED)
[   13.008258] tsc: Marking TSC unstable due to cpufreq changes
[   13.008481] Switched to clocksource acpi_pm
[   13.300867] [drm] Initialized drm 1.1.0 20060810
[   13.308032] intel8x0_measure_ac97_clock: measured 55148 usecs (2653 samp=
les)
[   13.308082] intel8x0: clocking to 48000
[   13.389668] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input5
[   13.688636] hda-intel 0000:01:00.1: Handle VGA-switcheroo audio client
[   13.688770] snd_hda_intel 0000:01:00.1: irq 41 for MSI/MSI-X
[   13.691171] Uhhuh. NMI received for unknown reason 31 on CPU 0.
[   13.691220] Do you have a strange power saving mode enabled?
[   13.691261] Dazed and confused, but trying to continue
[   14.696081] hda-intel 0000:01:00.1: Codec #0 probe error; disabling it...
[   14.697373] [drm] radeon kernel modesetting enabled.
[   14.698209] [drm] initializing kernel modesetting (RV710 0x1002:0x9553 0=
x174B:0x3092).
[   14.698289] [drm] register mmio base: 0xF2100000
[   14.698330] [drm] register mmio size: 65536
[   14.698406] Uhhuh. NMI received for unknown reason 31 on CPU 0.
[   14.698447] Do you have a strange power saving mode enabled?
[   14.698487] Dazed and confused, but trying to continue
[   14.704144] ATOM BIOS: 113
[   14.704267] radeon 0000:01:00.0: VRAM: 512M 0x0000000000000000 - 0x00000=
0001FFFFFFF (512M used)
[   14.704315] radeon 0000:01:00.0: GTT: 1024M 0x0000000020000000 - 0x00000=
0005FFFFFFF
[   14.704361] [drm] Detected VRAM RAM=3D512M, BAR=3D256M
[   14.704402] [drm] RAM width 64bits DDR
[   14.704551] [TTM] Zone  kernel: Available graphics memory: 2062284 kiB
[   14.704594] [TTM] Initializing pool allocator
[   14.704642] [TTM] Initializing DMA pool allocator
[   14.704724] [drm] radeon: 512M of VRAM memory ready
[   14.704766] [drm] radeon: 1024M of GTT memory ready.
[   14.704830] [drm] Loading RV710 Microcode
[   15.006859] [drm] Internal thermal controller with fan control
[   15.008579] [drm] radeon: dpm initialized
[   15.058523] [drm] GART: num cpu pages 262144, num gpu pages 262144
[   15.071087] [drm] PCIE GART of 1024M enabled (table at 0x000000000025D00=
0).
[   15.071196] radeon 0000:01:00.0: WB enabled
[   15.071242] radeon 0000:01:00.0: fence driver on ring 0 use gpu addr 0x0=
000000020000c00 and cpu addr 0xffff8800cba86c00
[   15.071291] radeon 0000:01:00.0: fence driver on ring 3 use gpu addr 0x0=
000000020000c0c and cpu addr 0xffff8800cba86c0c
[   15.072315] radeon 0000:01:00.0: fence driver on ring 5 use gpu addr 0x0=
00000000005c598 and cpu addr 0xffffc90000a1c598
[   15.072375] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[   15.072416] [drm] Driver supports precise vblank timestamp query.
[   15.072495] radeon 0000:01:00.0: irq 42 for MSI/MSI-X
[   15.072518] radeon 0000:01:00.0: radeon: using MSI.
[   15.072594] [drm] radeon: irq initialized.
[   15.121095] [drm] ring test on 0 succeeded in 1 usecs
[   15.121204] [drm] ring test on 3 succeeded in 1 usecs
[   15.316350] floppy0: no floppy controllers found
[   15.316411] work still pending
[   15.318285] [drm] ring test on 5 succeeded in 1 usecs
[   15.318338] [drm] UVD initialized successfully.
[   15.318644] [drm] ib test on ring 0 succeeded in 0 usecs
[   15.318707] [drm] ib test on ring 3 succeeded in 0 usecs
[   15.479327] Uhhuh. NMI received for unknown reason 21 on CPU 0.
[   15.479377] Do you have a strange power saving mode enabled?
[   15.479417] Dazed and confused, but trying to continue
[   15.485566] [drm] ib test on ring 5 succeeded
[   15.486020] [drm] Radeon Display Connectors
[   15.486060] [drm] Connector 0:
[   15.486095] [drm]   DVI-I-1
[   15.486958] [drm]   HPD1
[   15.486994] [drm]   DDC: 0x7f10 0x7f10 0x7f14 0x7f14 0x7f18 0x7f18 0x7f1=
c 0x7f1c
[   15.487032] [drm]   Encoders:
[   15.487067] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[   15.487103] [drm]     DFP2: INTERNAL_UNIPHY2
[   15.487138] [drm] Connector 1:
[   15.487173] [drm]   HDMI-A-1
[   15.487207] [drm]   HPD4
[   15.487243] [drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5=
c 0x7e5c
[   15.487281] [drm]   Encoders:
[   15.487316] [drm]     DFP1: INTERNAL_UNIPHY
[   15.487351] [drm] Connector 2:
[   15.487386] [drm]   VGA-1
[   15.487422] [drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4=
c 0x7e4c
[   15.487460] [drm]   Encoders:
[   15.487495] [drm]     CRT2: INTERNAL_KLDSCP_DAC2
[   15.558258] [drm] fb mappable at 0xE045E000
[   15.558300] [drm] vram apper at 0xE0000000
[   15.558335] [drm] size 9216000
[   15.558370] [drm] fb depth is 24
[   15.558405] [drm]    pitch is 7680
[   15.558638] fbcon: radeondrmfb (fb0) is primary device
[   15.663729] Console: switching to colour frame buffer device 180x56
[   15.671446] radeon 0000:01:00.0: fb0: radeondrmfb frame buffer device
[   15.671505] radeon 0000:01:00.0: registered panic notifier
[   15.671596] [drm] Initialized radeon 2.37.0 20080528 for 0000:01:00.0 on=
 minor 0
[   18.940778] EXT4-fs (dm-0): re-mounted. Opts: (null)
[   19.249142] EXT4-fs (dm-0): re-mounted. Opts: errors=3Dremount-ro
[   19.728055] hda-intel 0000:01:00.1: no codecs initialized
[   20.093351] lp0: using parport0 (interrupt-driven).
[   20.152786] ppdev: user-space parallel port driver
[   20.337814] loop: module loaded
[   20.596144] fuse init (API version 7.22)
[   20.928341] Adding 4194300k swap on /dev/mapper/vg0-boole--swap.  Priori=
ty:-1 extents:1 across:4194300k=20
[   21.730349] EXT4-fs (dm-2): mounting ext3 file system using the ext4 sub=
system
[   21.740918] EXT4-fs (dm-2): mounted filesystem with ordered data mode. O=
pts: (null)
[   23.233000] Bridge firewalling registered
[   23.279480] device eth0 entered promiscuous mode
[   23.304652] r8169 0000:00:09.0 eth0: link down
[   23.308281] r8169 0000:00:09.0 eth0: link down
[   23.311927] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   23.320170] IPv6: ADDRCONF(NETDEV_UP): br0: link is not ready
[   24.849581] r8169 0000:00:09.0 eth0: link up
[   24.853246] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   24.857312] br0: port 1(eth0) entered forwarding state
[   24.860949] br0: port 1(eth0) entered forwarding state
[   24.864660] IPv6: ADDRCONF(NETDEV_CHANGE): br0: link becomes ready
[   28.118954] RPC: Registered named UNIX socket transport module.
[   28.122728] RPC: Registered udp transport module.
[   28.126508] RPC: Registered tcp transport module.
[   28.130226] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   28.219068] FS-Cache: Loaded
[   28.414277] FS-Cache: Netfs 'nfs' registered for caching
[   28.617823] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   28.912813] Key type dns_resolver registered
[   29.006074] NFS: Registering the id_resolver key type
[   29.009837] Key type id_resolver registered
[   29.013497] Key type id_legacy registered
[   39.904028] br0: port 1(eth0) entered forwarding state
[   51.466888] Bluetooth: Core ver 2.18
[   51.470835] NET: Registered protocol family 31
[   51.474469] Bluetooth: HCI device and connection manager initialized
[   51.478720] Bluetooth: HCI socket layer initialized
[   51.482622] Bluetooth: L2CAP socket layer initialized
[   51.487198] Bluetooth: SCO socket layer initialized
[   51.584588] Bluetooth: RFCOMM TTY layer initialized
[   51.588558] Bluetooth: RFCOMM socket layer initialized
[   51.592337] Bluetooth: RFCOMM ver 1.11
[   51.677716] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   51.681263] Bluetooth: BNEP filters: protocol multicast
[   51.685084] Bluetooth: BNEP socket layer initialized
[   68.647926] systemd-logind[2925]: New seat seat0.
[   68.664737] systemd-logind[2925]: Watching system buttons on /dev/input/=
event2 (Power Button)
[   68.664940] systemd-logind[2925]: Watching system buttons on /dev/input/=
event1 (Power Button)
[   68.667194] systemd-logind[2925]: New session c1 of user lightdm.
[   68.667479] systemd-logind[2925]: Linked /tmp/.X11-unix/X0 to /run/user/=
108/X11-display.
[   95.553342] systemd-logind[2925]: New session c2 of user thomas.

--=-=-=--

--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAEBAgAGBQJTXgtjAAoJENuKOtuXzphJUL0IAJXsGJUYLOatA4ZQ+1T1DhtN
JeDvKYxUakE4NKl3doLD4N1m7X1ZwYyZlwB8rYCxKwFHcmMo+zsLdpB4LbfHHUui
V+hdSLjAohkkmxYcJi8CKAi9KHSKZRPAilKNHBLnuOhPFWccndMIL4BsLAl9YqU8
X+DjVp4+iyS4s0vVbD5yfycGyZVJQUrhupDHj88T7GrOZgjd+5yrJupYDdbQhv9c
D9iXnQ3qDTXJBspfbEL3DmqPRw0kkZDa8xR1H+U9IXfBJfkwM7bAGlGgFkoPtnBj
cP16XNVPVerANG2kOl2ouXOACqK8PrVSMo3IcA3eGlxXfJPT6wwYhO9JG62f+9M=
=2Vfp
-----END PGP SIGNATURE-----
--==-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
