Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4D46B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 08:52:24 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id c9so6684257qcz.19
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 05:52:24 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1blp0182.outbound.protection.outlook.com. [207.46.163.182])
        by mx.google.com with ESMTPS id s10si7691218qak.106.2014.04.28.05.52.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 28 Apr 2014 05:52:23 -0700 (PDT)
From: "Deucher, Alexander" <Alexander.Deucher@amd.com>
Subject: RE: radeon: screen garbled after page allocator change, was: Re:
 [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Date: Mon, 28 Apr 2014 12:52:15 +0000
Message-ID: <A3397C8B8B789E45844E7EC5DEAD89D040EED229@satlexdag05.amd.com>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
 <87r45fajun.fsf@schwinge.name> <20140424133722.GD4107@cmpxchg.org>
 <20140427033110.GA15091@gmail.com> <20140427195527.GC9315@gmail.com>
 <535E0382.4080404@amd.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Koenig, Christian" <Christian.Koenig@amd.com>, Jerome Glisse <j.glisse@gmail.com>, Thomas Schwinge <thomas@codesourcery.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

> -----Original Message-----
> From: Deucher, Alexander
> Sent: Monday, April 28, 2014 8:50 AM
> To: Koenig, Christian; Jerome Glisse; Thomas Schwinge
> Cc: Bjorn Helgaas; linux-pci@vger.kernel.org; Johannes Weiner; Mel Gorman=
;
> Rik van Riel; Andrea Arcangeli; Zlatko Calusic; Minchan Kim; linux-
> mm@kvack.org; linux-kernel@vger.kernel.org; Andrew Morton; dri-
> devel@lists.freedesktop.org
> Subject: RE: radeon: screen garbled after page allocator change, was: Re:
> [patch v2 3/3] mm: page_alloc: fair zone allocator policy
>=20
> > -----Original Message-----
> > From: Koenig, Christian
> > Sent: Monday, April 28, 2014 3:30 AM
> > To: Jerome Glisse; Thomas Schwinge
> > Cc: Bjorn Helgaas; linux-pci@vger.kernel.org; Johannes Weiner; Mel
> Gorman;
> > Rik van Riel; Andrea Arcangeli; Zlatko Calusic; Minchan Kim; linux-
> > mm@kvack.org; linux-kernel@vger.kernel.org; Andrew Morton; Deucher,
> > Alexander; dri-devel@lists.freedesktop.org
> > Subject: Re: radeon: screen garbled after page allocator change, was: R=
e:
> > [patch v2 3/3] mm: page_alloc: fair zone allocator policy
> >
> > > +	/* We are living in a monstruous world in which you can have the pc=
i
> > > +	 * root complex behind an hypertransport link which can not address
> > > +	 * anything above 32bit (well hypertransport specification says 40b=
its
> > > +	 * but hardware such as SIS761 only support 32bits).
> > That looks more like a problem with this specific chipset rather than
> > something that needs a general solution like this.
> >
> > Maybe we should rather add the PCI-ID(s) of the thing to some kind of
> > quirks table for now so that the patch isn't so invasive and we can CC
> > stable as well?
>=20
> IIRC, there was someone on IRC with a similar problem with a similar SiS
> chipset a while back.  These SiS chipsets seem to be generally problemati=
c.

IIRC, in the IRC case, the fix was to limit the about of physical memory in=
 the system.

Alex

>=20
> Alex
>=20
> >
> > Just a thought,
> > Christian.
> >
> > Am 27.04.2014 21:55, schrieb Jerome Glisse:
> > > On Sat, Apr 26, 2014 at 11:31:11PM -0400, Jerome Glisse wrote:
> > >> On Thu, Apr 24, 2014 at 09:37:22AM -0400, Johannes Weiner wrote:
> > >>> Hi Thomas,
> > >>>
> > >>> On Wed, Apr 02, 2014 at 04:26:08PM +0200, Thomas Schwinge wrote:
> > >>>> Hi!
> > >>>>
> > >>>> On Fri,  2 Aug 2013 11:37:26 -0400, Johannes Weiner
> > <hannes@cmpxchg.org> wrote:
> > >>>>> Each zone that holds userspace pages of one workload must be
> aged
> > at a
> > >>>>> speed proportional to the zone size.  [...]
> > >>>>> Fix this with a very simple round robin allocator.  [...]
> > >>>> This patch, adding NR_ALLOC_BATCH, eventually landed in mainline
> as
> > >>>> commit 81c0a2bb515fd4daae8cab64352877480792b515 (2013-09-11).
> > >>>>
> > >>>> I recently upgraded a Debian testing system from a 3.11 kernel to
> 3.12,
> > >>>> and it started to exhibit "strange" issues, which I then bisected =
to this
> > >>>> patch.  I'm not saying that the patch is faulty, as it seems to be
> > >>>> working fine for everyone else, so I rather assume that something =
in
> a
> > >>>> (vastly?) different corner of the kernel (or my hardware?) is brok=
en.
> > >>>> ;-)
> > >>>>
> > >>>> The issue is that when X.org/lightdm starts up, there are "garbled=
"
> > >>>> section on the screen, for example, rectangular boxes that are jus=
t
> > black
> > >>>> or otherwise "distorted", and/or sets of glyphs (corresponding to =
a
> set
> > >>>> of characters; but not all characters) are displayed as rectangula=
r gray
> > >>>> or black boxes, and/or icons in a GNOME session are not displayed
> > >>>> properly, and so on.  (Can take a snapshot if that helps?)  Switch=
ing to
> > >>>> a Linux console, I can use that one fine.  Switching back to X, in=
 the
> > >>>> majority of all cases, the screen will be completely black, but wi=
th the
> > >>>> mouse cursor still rendered properly (done in hardware, I assume).
> > >>>>
> > >>>> Reverting commit 81c0a2bb515fd4daae8cab64352877480792b515, for
> > example on
> > >>>> top of v3.12, and everything is back to normal.  The problem also
> > >>>> persists with a v3.14 kernel that I just built.
> > >>>>
> > >>>> I will try to figure out what's going on, but will gladly take any
> > >>>> pointers, or suggestions about how to tackle such a problem.
> > >>>>
> > >>>> The hardware is a Fujitsu Siemens Esprimo E5600, mainboard D2264-
> A1,
> > CPU
> > >>>> AMD Sempron 3000+.  There is a on-board graphics thingy, but I'm
> not
> > >>>> using that; instead I put in a Sapphire Radeon HD 4350 card.
> > >>> I went over this code change repeatedly but I could not see anythin=
g
> > >>> directly that would explain it.  However, this patch DOES change th=
e
> > >>> way allocations are placed (while still respecting zone specifiers
> > >>> like __GFP_DMA etc.) and so it's possible that they unearthed a
> > >>> corruption, or a wrongly set dma mask in the drivers.
> > >>>
> > >>> Ccing the radeon driver guys.  Full quote follows.
> > >>>
> > >>>>      $ cat < /proc/cpuinfo
> > >>>>      processor       : 0
> > >>>>      vendor_id       : AuthenticAMD
> > >>>>      cpu family      : 15
> > >>>>      model           : 47
> > >>>>      model name      : AMD Sempron(tm) Processor 3000+
> > >>>>      stepping        : 2
> > >>>>      cpu MHz         : 1000.000
> > >>>>      cache size      : 128 KB
> > >>>>      physical id     : 0
> > >>>>      siblings        : 1
> > >>>>      core id         : 0
> > >>>>      cpu cores       : 1
> > >>>>      apicid          : 0
> > >>>>      initial apicid  : 0
> > >>>>      fpu             : yes
> > >>>>      fpu_exception   : yes
> > >>>>      cpuid level     : 1
> > >>>>      wp              : yes
> > >>>>      flags           : fpu vme de pse tsc msr pae mce cx8 apic sep=
 mtrr pge
> > mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext fxsr_opt
> lm
> > 3dnowext 3dnow rep_good nopl pni lahf_lm
> > >>>>      bogomips        : 2000.20
> > >>>>      TLB size        : 1024 4K pages
> > >>>>      clflush size    : 64
> > >>>>      cache_alignment : 64
> > >>>>      address sizes   : 40 bits physical, 48 bits virtual
> > >>>>      power management: ts fid vid ttp tm stc
> > >>>>      $ sudo lspci -nn -k -vv
> > >>>>      00:00.0 Host bridge [0600]: Silicon Integrated Systems [SiS]
> 761/M761
> > Host [1039:0761] (rev 01)
> > >>>>              Subsystem: Fujitsu Technology Solutions D2030-A1
> Motherboard
> > [1734:1099]
> > >>>>              Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > >>>>              Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dme=
dium
> > >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> > >>>>              Latency: 64
> > >>>>              Region 0: Memory at f0000000 (32-bit, non-prefetchabl=
e)
> > [size=3D32M]
> > >>>>              Capabilities: [a0] AGP version 3.0
> > >>>>                      Status: RQ=3D32 Iso- ArqSz=3D2 Cal=3D3 SBA+ I=
TACoh- GART64-
> > HTrans- 64bit- FW- AGP3+ Rate=3Dx4,x8
> > >>>>                      Command: RQ=3D1 ArqSz=3D0 Cal=3D0 SBA+ AGP- G=
ART64- 64bit-
> > FW- Rate=3D<none>
> > >>>>              Capabilities: [d0] HyperTransport: Slave or Primary I=
nterface
> > >>>>                      Command: BaseUnitID=3D0 UnitCnt=3D17 MastHost=
- DefDir-
> DUL-
> > >>>>                      Link Control 0: CFlE- CST- CFE- <LkFail- Init=
+ EOC- TXO-
> > <CRCErr=3D0 IsocEn- LSEn- ExtCTL- 64b-
> > >>>>                      Link Config 0: MLWI=3D16bit DwFcIn- MLWO=3D16=
bit DwFcOut-
> > LWI=3D16bit DwFcInEn- LWO=3D16bit DwFcOutEn-
> > >>>>                      Link Control 1: CFlE- CST- CFE- <LkFail+ Init=
- EOC+ TXO+
> > <CRCErr=3D0 IsocEn- LSEn- ExtCTL- 64b-
> > >>>>                      Link Config 1: MLWI=3DN/C DwFcIn- MLWO=3DN/C =
DwFcOut-
> > LWI=3DN/C DwFcInEn- LWO=3DN/C DwFcOutEn-
> > >>>>                      Revision ID: 1.05
> > >>>>                      Link Frequency 0: 800MHz
> > >>>>                      Link Error 0: <Prot- <Ovfl- <EOC- CTLTm-
> > >>>>                      Link Frequency Capability 0: 200MHz+ 300MHz- =
400MHz+
> > 500MHz- 600MHz+ 800MHz+ 1.0GHz+ 1.2GHz+ 1.4GHz- 1.6GHz- Vend-
> > >>>>                      Feature Capability: IsocFC- LDTSTOP+ CRCTM- E=
CTLT-
> 64bA+
> > UIDRD-
> > >>>>                      Link Frequency 1: 200MHz
> > >>>>                      Link Error 1: <Prot- <Ovfl- <EOC- CTLTm-
> > >>>>                      Link Frequency Capability 1: 200MHz- 300MHz- =
400MHz-
> > 500MHz- 600MHz- 800MHz- 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
> > >>>>                      Error Handling: PFlE- OFlE- PFE- OFE- EOCFE- =
RFE- CRCFE-
> > SERRFE- CF- RE- PNFE- ONFE- EOCNFE- RNFE- CRCNFE- SERRNFE-
> > >>>>                      Prefetchable memory behind bridge Upper: 00-0=
0
> > >>>>                      Bus Number: 00
> > >>>>              Capabilities: [f0] HyperTransport: Interrupt Discover=
y and
> > Configuration
> > >>>>              Capabilities: [5c] HyperTransport: Revision ID: 1.05
> > >>>>              Kernel driver in use: agpgart-amd64
> > >>>>
> > >>>>      00:01.0 PCI bridge [0604]: Silicon Integrated Systems [SiS] P=
CI-to-
> PCI
> > bridge [1039:0004] (prog-if 00 [Normal decode])
> > >>>>              Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > >>>>              Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Latency: 0, Cache Line Size: 64 bytes
> > >>>>              Bus: primary=3D00, secondary=3D01, subordinate=3D01, =
sec-latency=3D0
> > >>>>              I/O behind bridge: 00002000-00002fff
> > >>>>              Memory behind bridge: f2100000-f21fffff
> > >>>>              Prefetchable memory behind bridge: e0000000-efffffff
> > >>>>              Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfa=
st
> >TAbort-
> > <TAbort- <MAbort+ <SERR- <PERR-
> > >>>>              BridgeCtl: Parity+ SERR+ NoISA+ VGA+ MAbort- >Reset-
> > FastB2B-
> > >>>>                      PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrS=
ERREn-
> > >>>>              Capabilities: [d0] Express (v1) Root Port (Slot+), MS=
I 00
> > >>>>                      DevCap: MaxPayload 128 bytes, PhantFunc 0
> > >>>>                              ExtTag+ RBE-
> > >>>>                      DevCtl: Report errors: Correctable- Non-Fatal=
- Fatal-
> > Unsupported-
> > >>>>                              RlxdOrd+ ExtTag- PhantFunc- AuxPwr- N=
oSnoop+
> > >>>>                              MaxPayload 128 bytes, MaxReadReq 128 =
bytes
> > >>>>                      DevSta: CorrErr- UncorrErr- FatalErr- UnsuppR=
eq+ AuxPwr+
> > TransPend-
> > >>>>                      LnkCap: Port #0, Speed 2.5GT/s, Width x16, AS=
PM L0s L1,
> Exit
> > Latency L0s <1us, L1 <2us
> > >>>>                              ClockPM- Surprise- LLActRep+ BwNot-
> > >>>>                      LnkCtl: ASPM Disabled; RCB 64 bytes Disabled-=
 CommClk+
> > >>>>                              ExtSynch- ClockPM- AutWidDis- BWInt- =
AutBWInt-
> > >>>>                      LnkSta: Speed 2.5GT/s, Width x16, TrErr- Trai=
n- SlotClk+
> > DLActive+ BWMgmt- ABWMgmt-
> > >>>>                      SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrIn=
d- HotPlug-
> > Surprise-
> > >>>>                              Slot #0, PowerLimit 75.000W; Interloc=
k- NoCompl-
> > >>>>                      SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet=
- CmdCplt-
> > HPIrq- LinkChg-
> > >>>>                              Control: AttnInd Off, PwrInd Off, Pow=
er- Interlock-
> > >>>>                      SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCp=
lt- PresDet+
> > Interlock-
> > >>>>                              Changed: MRL- PresDet- LinkState-
> > >>>>                      RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFat=
al- PMEIntEna-
> > CRSVisible-
> > >>>>                      RootCap: CRSVisible-
> > >>>>                      RootSta: PME ReqID 0000, PMEStatus- PMEPendin=
g-
> > >>>>              Capabilities: [bc] HyperTransport: MSI Mapping Enable=
- Fixed+
> > >>>>              Capabilities: [a0] MSI: Enable- Count=3D1/1 Maskable-=
 64bit-
> > >>>>                      Address: 00000000  Data: 0000
> > >>>>              Capabilities: [f4] Power Management version 2
> > >>>>                      Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA =
PME(D0+,D1-
> > ,D2-,D3hot+,D3cold+)
> > >>>>                      Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > >>>>              Kernel driver in use: pcieport
> > >>>>
> > >>>>      00:02.0 ISA bridge [0601]: Silicon Integrated Systems [SiS] S=
iS965
> > [MuTIOL Media IO] [1039:0965] (rev 48)
> > >>>>              Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV-
> > VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > >>>>              Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dme=
dium
> > >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> > >>>>              Latency: 0
> > >>>>
> > >>>>      00:02.5 IDE interface [0101]: Silicon Integrated Systems [SiS=
] 5513
> IDE
> > Controller [1039:5513] (rev 01) (prog-if 80 [Master])
> > >>>>              Subsystem: Fujitsu Technology Solutions D2030-A1
> Motherboard
> > [1734:1095]
> > >>>>              Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > >>>>              Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dme=
dium
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Latency: 128
> > >>>>              Interrupt: pin ? routed to IRQ 16
> > >>>>              Region 0: I/O ports at 01f0 [size=3D8]
> > >>>>              Region 1: I/O ports at 03f4
> > >>>>              Region 2: I/O ports at 0170 [size=3D8]
> > >>>>              Region 3: I/O ports at 0374
> > >>>>              Region 4: I/O ports at 1c80 [size=3D16]
> > >>>>              Capabilities: [58] Power Management version 2
> > >>>>                      Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA =
PME(D0-,D1-
> > ,D2-,D3hot-,D3cold+)
> > >>>>                      Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > >>>>              Kernel driver in use: pata_sis
> > >>>>
> > >>>>      00:02.7 Multimedia audio controller [0401]: Silicon Integrate=
d
> > Systems [SiS] SiS7012 AC'97 Sound Controller [1039:7012] (rev a0)
> > >>>>              Subsystem: Fujitsu Technology Solutions Device [1734:=
109c]
> > >>>>              Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > >>>>              Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Latency: 173 (13000ns min, 2750ns max)
> > >>>>              Interrupt: pin C routed to IRQ 18
> > >>>>              Region 0: I/O ports at 1400 [size=3D256]
> > >>>>              Region 1: I/O ports at 1000 [size=3D128]
> > >>>>              Capabilities: [48] Power Management version 2
> > >>>>                      Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D55mA=
 PME(D0-
> ,D1-
> > ,D2-,D3hot+,D3cold+)
> > >>>>                      Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > >>>>              Kernel driver in use: snd_intel8x0
> > >>>>
> > >>>>      00:03.0 USB controller [0c03]: Silicon Integrated Systems [Si=
S] USB
> 1.1
> > Controller [1039:7001] (rev 0f) (prog-if 10 [OHCI])
> > >>>>              Subsystem: Fujitsu Technology Solutions D2030-A1
> Motherboard
> > [1734:1095]
> > >>>>              Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+
> > VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > >>>>              Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Latency: 64 (20000ns max)
> > >>>>              Interrupt: pin A routed to IRQ 20
> > >>>>              Region 0: Memory at f2000000 (32-bit, non-prefetchabl=
e)
> > [size=3D4K]
> > >>>>              Kernel driver in use: ohci-pci
> > >>>>
> > >>>>      00:03.1 USB controller [0c03]: Silicon Integrated Systems [Si=
S] USB
> 1.1
> > Controller [1039:7001] (rev 0f) (prog-if 10 [OHCI])
> > >>>>              Subsystem: Fujitsu Technology Solutions D2030-A1
> Motherboard
> > [1734:1095]
> > >>>>              Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+
> > VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > >>>>              Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Latency: 64 (20000ns max)
> > >>>>              Interrupt: pin B routed to IRQ 21
> > >>>>              Region 0: Memory at f2001000 (32-bit, non-prefetchabl=
e)
> > [size=3D4K]
> > >>>>              Kernel driver in use: ohci-pci
> > >>>>
> > >>>>      00:03.2 USB controller [0c03]: Silicon Integrated Systems [Si=
S] USB
> 1.1
> > Controller [1039:7001] (rev 0f) (prog-if 10 [OHCI])
> > >>>>              Subsystem: Fujitsu Technology Solutions D2030-A1
> Motherboard
> > [1734:1095]
> > >>>>              Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+
> > VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > >>>>              Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Latency: 64 (20000ns max)
> > >>>>              Interrupt: pin C routed to IRQ 22
> > >>>>              Region 0: Memory at f2002000 (32-bit, non-prefetchabl=
e)
> > [size=3D4K]
> > >>>>              Kernel driver in use: ohci-pci
> > >>>>
> > >>>>      00:03.3 USB controller [0c03]: Silicon Integrated Systems [Si=
S] USB
> 2.0
> > Controller [1039:7002] (prog-if 20 [EHCI])
> > >>>>              Subsystem: Fujitsu Technology Solutions D2030-A1 [173=
4:1095]
> > >>>>              Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > >>>>              Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Latency: 64 (20000ns max)
> > >>>>              Interrupt: pin D routed to IRQ 23
> > >>>>              Region 0: Memory at f2003000 (32-bit, non-prefetchabl=
e)
> > [size=3D4K]
> > >>>>              Capabilities: [50] Power Management version 2
> > >>>>                      Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375m=
A
> > PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > >>>>                      Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > >>>>              Kernel driver in use: ehci-pci
> > >>>>
> > >>>>      00:05.0 IDE interface [0101]: Silicon Integrated Systems [SiS=
] 182
> > SATA/RAID Controller [1039:0182] (rev 01) (prog-if 8f [Master SecP SecO
> PriP
> > PriO])
> > >>>>              Subsystem: Fujitsu Technology Solutions D2030-A1 [173=
4:1095]
> > >>>>              Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > >>>>              Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dme=
dium
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Latency: 64
> > >>>>              Interrupt: pin A routed to IRQ 17
> > >>>>              Region 0: I/O ports at 1cb0 [size=3D8]
> > >>>>              Region 1: I/O ports at 1ca4 [size=3D4]
> > >>>>              Region 2: I/O ports at 1ca8 [size=3D8]
> > >>>>              Region 3: I/O ports at 1ca0 [size=3D4]
> > >>>>              Region 4: I/O ports at 1c90 [size=3D16]
> > >>>>              Region 5: I/O ports at 1c00 [size=3D128]
> > >>>>              Capabilities: [58] Power Management version 2
> > >>>>                      Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA =
PME(D0-,D1-
> > ,D2-,D3hot-,D3cold+)
> > >>>>                      Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > >>>>              Kernel driver in use: sata_sis
> > >>>>
> > >>>>      00:06.0 PCI bridge [0604]: Silicon Integrated Systems [SiS] P=
CI-to-
> PCI
> > bridge [1039:000a] (prog-if 00 [Normal decode])
> > >>>>              Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> > >>>>              Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Latency: 0, Cache Line Size: 64 bytes
> > >>>>              Bus: primary=3D00, secondary=3D02, subordinate=3D02, =
sec-latency=3D0
> > >>>>              Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfa=
st
> >TAbort-
> > <TAbort- <MAbort- <SERR- <PERR-
> > >>>>              BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset-
> FastB2B-
> > >>>>                      PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrS=
ERREn-
> > >>>>              Capabilities: [b0] Subsystem: Silicon Integrated Syst=
ems [SiS]
> > Device [1039:0000]
> > >>>>              Capabilities: [c0] MSI: Enable+ Count=3D1/1 Maskable-=
 64bit-
> > >>>>                      Address: fee0100c  Data: 4181
> > >>>>              Capabilities: [d0] Express (v1) Root Port (Slot+), MS=
I 00
> > >>>>                      DevCap: MaxPayload 128 bytes, PhantFunc 0
> > >>>>                              ExtTag+ RBE-
> > >>>>                      DevCtl: Report errors: Correctable- Non-Fatal=
- Fatal-
> > Unsupported-
> > >>>>                              RlxdOrd+ ExtTag- PhantFunc- AuxPwr- N=
oSnoop+
> > >>>>                              MaxPayload 128 bytes, MaxReadReq 128 =
bytes
> > >>>>                      DevSta: CorrErr- UncorrErr- FatalErr- UnsuppR=
eq- AuxPwr+
> > TransPend-
> > >>>>                      LnkCap: Port #0, Speed 2.5GT/s, Width x16, AS=
PM L0s L1,
> Exit
> > Latency L0s <1us, L1 <2us
> > >>>>                              ClockPM- Surprise- LLActRep- BwNot-
> > >>>>                      LnkCtl: ASPM Disabled; RCB 64 bytes Disabled-=
 CommClk-
> > >>>>                              ExtSynch- ClockPM- AutWidDis- BWInt- =
AutBWInt-
> > >>>>                      LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train=
- SlotClk+
> > DLActive- BWMgmt- ABWMgmt-
> > >>>>                      SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrIn=
d- HotPlug-
> > Surprise-
> > >>>>                              Slot #0, PowerLimit 0.000W; Interlock=
- NoCompl-
> > >>>>                      SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet=
- CmdCplt-
> > HPIrq- LinkChg-
> > >>>>                              Control: AttnInd Off, PwrInd Off, Pow=
er- Interlock-
> > >>>>                      SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCp=
lt- PresDet+
> > Interlock-
> > >>>>                              Changed: MRL- PresDet- LinkState-
> > >>>>                      RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFat=
al- PMEIntEna-
> > CRSVisible-
> > >>>>                      RootCap: CRSVisible-
> > >>>>                      RootSta: PME ReqID 0000, PMEStatus- PMEPendin=
g-
> > >>>>              Capabilities: [f4] Power Management version 2
> > >>>>                      Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA =
PME(D0+,D1-
> > ,D2-,D3hot+,D3cold+)
> > >>>>                      Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > >>>>              Capabilities: [100 v1] Virtual Channel
> > >>>>                      Caps:   LPEVC=3D0 RefClk=3D100ns PATEntryBits=
=3D1
> > >>>>                      Arb:    Fixed- WRR32- WRR64- WRR128-
> > >>>>                      Ctrl:   ArbSelect=3DFixed
> > >>>>                      Status: InProgress-
> > >>>>                      VC0:    Caps:   PATOffset=3D00 MaxTimeSlots=
=3D1
> RejSnoopTrans-
> > >>>>                              Arb:    Fixed- WRR32- WRR64- WRR128- =
TWRR128-
> > WRR256-
> > >>>>                              Ctrl:   Enable+ ID=3D0 ArbSelect=3DFi=
xed TC/VC=3Dff
> > >>>>                              Status: NegoPending- InProgress-
> > >>>>              Capabilities: [130 v1] Advanced Error Reporting
> > >>>>                      UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAb=
rt-
> > UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >>>>                      UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAb=
rt-
> > UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > >>>>                      UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAb=
rt-
> > UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> > >>>>                      CESta:  RxErr- BadTLP- BadDLLP- Rollover- Tim=
eout-
> > NonFatalErr-
> > >>>>                      CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Tim=
eout-
> > NonFatalErr-
> > >>>>                      AERCap: First Error Pointer: 00, GenCap- CGen=
En- ChkCap-
> > ChkEn-
> > >>>>              Kernel driver in use: pcieport
> > >>>>
> > >>>>      00:09.0 Ethernet controller [0200]: Realtek Semiconductor Co.=
, Ltd.
> > RTL8169 PCI Gigabit Ethernet Controller [10ec:8169] (rev 10)
> > >>>>              Subsystem: Fujitsu Technology Solutions D2030-A1 [173=
4:1091]
> > >>>>              Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+
> > VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > >>>>              Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dme=
dium
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Latency: 64 (8000ns min, 16000ns max), Cache Line Siz=
e: 32
> bytes
> > >>>>              Interrupt: pin A routed to IRQ 19
> > >>>>              Region 0: I/O ports at 1800 [size=3D256]
> > >>>>              Region 1: Memory at f2004000 (32-bit, non-prefetchabl=
e)
> > [size=3D256]
> > >>>>              Capabilities: [dc] Power Management version 2
> > >>>>                      Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375m=
A PME(D0-
> > ,D1+,D2+,D3hot+,D3cold+)
> > >>>>                      Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > >>>>              Kernel driver in use: r8169
> > >>>>
> > >>>>      00:18.0 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD=
] K8
> > [Athlon64/Opteron] HyperTransport Technology Configuration [1022:1100]
> > >>>>              Control: I/O- Mem- BusMaster- SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > >>>>              Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Capabilities: [80] HyperTransport: Host or Secondary =
Interface
> > >>>>                      Command: WarmRst+ DblEnd- DevNum=3D0 ChainSid=
e-
> > HostHide+ Slave- <EOCErr- DUL-
> > >>>>                      Link Control: CFlE- CST- CFE- <LkFail- Init+ =
EOC- TXO-
> > <CRCErr=3D0 IsocEn- LSEn- ExtCTL- 64b-
> > >>>>                      Link Config: MLWI=3D16bit DwFcIn- MLWO=3D16bi=
t DwFcOut-
> > LWI=3D16bit DwFcInEn- LWO=3D16bit DwFcOutEn-
> > >>>>                      Revision ID: 1.02
> > >>>>                      Link Frequency: 800MHz
> > >>>>                      Link Error: <Prot- <Ovfl- <EOC- CTLTm-
> > >>>>                      Link Frequency Capability: 200MHz+ 300MHz- 40=
0MHz+
> > 500MHz- 600MHz+ 800MHz+ 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
> > >>>>                      Feature Capability: IsocFC- LDTSTOP+ CRCTM- E=
CTLT- 64bA-
> > UIDRD- ExtRS- UCnfE-
> > >>>>
> > >>>>      00:18.1 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD=
] K8
> > [Athlon64/Opteron] Address Map [1022:1101]
> > >>>>              Control: I/O- Mem- BusMaster- SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > >>>>              Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st
> >TAbort-
> > <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>
> > >>>>      00:18.2 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD=
] K8
> > [Athlon64/Opteron] DRAM Controller [1022:1102]
> > >>>>              Control: I/O- Mem- BusMaster- SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > >>>>              Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st
> >TAbort-
> > <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Kernel driver in use: amd64_edac
> > >>>>
> > >>>>      00:18.3 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD=
] K8
> > [Athlon64/Opteron] Miscellaneous Control [1022:1103]
> > >>>>              Control: I/O- Mem- BusMaster- SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > >>>>              Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st
> >TAbort-
> > <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Kernel driver in use: k8temp
> > >>>>
> > >>>>      01:00.0 VGA compatible controller [0300]: Advanced Micro Devi=
ces,
> > Inc. [AMD/ATI] RV710/M92 [Mobility Radeon HD 4530/4570/545v]
> > [1002:9553] (prog-if 00 [VGA controller])
> > >>>>              Subsystem: PC Partner Limited / Sapphire Technology D=
evice
> > [174b:3092]
> > >>>>              Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> > >>>>              Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st
> > >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> > >>>>              Latency: 0, Cache Line Size: 64 bytes
> > >>>>              Interrupt: pin A routed to IRQ 42
> > >>>>              Region 0: Memory at e0000000 (64-bit, prefetchable)
> > [size=3D256M]
> > >>>>              Region 2: Memory at f2100000 (64-bit, non-prefetchabl=
e)
> > [size=3D64K]
> > >>>>              Region 4: I/O ports at 2000 [size=3D256]
> > >>>>              [virtual] Expansion ROM at f2120000 [disabled] [size=
=3D128K]
> > >>>>              Capabilities: [50] Power Management version 3
> > >>>>                      Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA =
PME(D0-
> ,D1-
> > ,D2-,D3hot-,D3cold-)
> > >>>>                      Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > >>>>              Capabilities: [58] Express (v2) Legacy Endpoint, MSI =
00
> > >>>>                      DevCap: MaxPayload 128 bytes, PhantFunc 0, La=
tency L0s
> > <4us, L1 unlimited
> > >>>>                              ExtTag+ AttnBtn- AttnInd- PwrInd- RBE=
+ FLReset-
> > >>>>                      DevCtl: Report errors: Correctable- Non-Fatal=
- Fatal-
> > Unsupported-
> > >>>>                              RlxdOrd+ ExtTag- PhantFunc- AuxPwr- N=
oSnoop+
> > >>>>                              MaxPayload 128 bytes, MaxReadReq 128 =
bytes
> > >>>>                      DevSta: CorrErr- UncorrErr- FatalErr- UnsuppR=
eq- AuxPwr-
> > TransPend-
> > >>>>                      LnkCap: Port #0, Speed 2.5GT/s, Width x16, AS=
PM L0s L1,
> Exit
> > Latency L0s <64ns, L1 <1us
> > >>>>                              ClockPM- Surprise- LLActRep- BwNot-
> > >>>>                      LnkCtl: ASPM Disabled; RCB 64 bytes Disabled-=
 CommClk+
> > >>>>                              ExtSynch- ClockPM- AutWidDis- BWInt- =
AutBWInt-
> > >>>>                      LnkSta: Speed 2.5GT/s, Width x16, TrErr- Trai=
n- SlotClk+
> > DLActive- BWMgmt- ABWMgmt-
> > >>>>                      DevCap2: Completion Timeout: Not Supported,
> TimeoutDis-,
> > LTR-, OBFF Not Supported
> > >>>>                      DevCtl2: Completion Timeout: 50us to 50ms, Ti=
meoutDis-,
> > LTR-, OBFF Disabled
> > >>>>                      LnkCtl2: Target Link Speed: 2.5GT/s, EnterCom=
pliance-
> > SpeedDis-
> > >>>>                               Transmit Margin: Normal Operating Ra=
nge,
> > EnterModifiedCompliance- ComplianceSOS-
> > >>>>                               Compliance De-emphasis: -6dB
> > >>>>                      LnkSta2: Current De-emphasis Level: -6dB,
> > EqualizationComplete-, EqualizationPhase1-
> > >>>>                               EqualizationPhase2-, EqualizationPha=
se3-,
> > LinkEqualizationRequest-
> > >>>>              Capabilities: [a0] MSI: Enable+ Count=3D1/1 Maskable-=
 64bit+
> > >>>>                      Address: 00000000fee0100c  Data: 41e1
> > >>>>              Capabilities: [100 v1] Vendor Specific Information: I=
D=3D0001
> Rev=3D1
> > Len=3D010 <?>
> > >>>>              Kernel driver in use: radeon
> > >>>>
> > >>>>      01:00.1 Audio device [0403]: Advanced Micro Devices, Inc.
> > [AMD/ATI] RV710/730 HDMI Audio [Radeon HD 4000 series] [1002:aa38]
> > >>>>              Subsystem: PC Partner Limited / Sapphire Technology D=
evice
> > [174b:aa38]
> > >>>>              Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV-
> > VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> > >>>>              Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfa=
st
> > >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >>>>              Latency: 0, Cache Line Size: 64 bytes
> > >>>>              Interrupt: pin B routed to IRQ 41
> > >>>>              Region 0: Memory at f2110000 (64-bit, non-prefetchabl=
e)
> > [size=3D16K]
> > >>>>              Capabilities: [50] Power Management version 3
> > >>>>                      Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA =
PME(D0-
> ,D1-
> > ,D2-,D3hot-,D3cold-)
> > >>>>                      Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DS=
cale=3D0 PME-
> > >>>>              Capabilities: [58] Express (v2) Legacy Endpoint, MSI =
00
> > >>>>                      DevCap: MaxPayload 128 bytes, PhantFunc 0, La=
tency L0s
> > <4us, L1 unlimited
> > >>>>                              ExtTag+ AttnBtn- AttnInd- PwrInd- RBE=
+ FLReset-
> > >>>>                      DevCtl: Report errors: Correctable- Non-Fatal=
- Fatal-
> > Unsupported-
> > >>>>                              RlxdOrd+ ExtTag- PhantFunc- AuxPwr- N=
oSnoop+
> > >>>>                              MaxPayload 128 bytes, MaxReadReq 128 =
bytes
> > >>>>                      DevSta: CorrErr- UncorrErr- FatalErr- UnsuppR=
eq- AuxPwr-
> > TransPend-
> > >>>>                      LnkCap: Port #0, Speed 2.5GT/s, Width x16, AS=
PM L0s L1,
> Exit
> > Latency L0s <64ns, L1 <1us
> > >>>>                              ClockPM- Surprise- LLActRep- BwNot-
> > >>>>                      LnkCtl: ASPM Disabled; RCB 64 bytes Disabled-=
 CommClk+
> > >>>>                              ExtSynch- ClockPM- AutWidDis- BWInt- =
AutBWInt-
> > >>>>                      LnkSta: Speed 2.5GT/s, Width x16, TrErr- Trai=
n- SlotClk+
> > DLActive- BWMgmt- ABWMgmt-
> > >>>>                      DevCap2: Completion Timeout: Not Supported,
> TimeoutDis-,
> > LTR-, OBFF Not Supported
> > >>>>                      DevCtl2: Completion Timeout: 50us to 50ms, Ti=
meoutDis-,
> > LTR-, OBFF Disabled
> > >>>>                      LnkSta2: Current De-emphasis Level: -6dB,
> > EqualizationComplete-, EqualizationPhase1-
> > >>>>                               EqualizationPhase2-, EqualizationPha=
se3-,
> > LinkEqualizationRequest-
> > >>>>              Capabilities: [a0] MSI: Enable+ Count=3D1/1 Maskable-=
 64bit+
> > >>>>                      Address: 00000000fee0100c  Data: 41d1
> > >>>>              Capabilities: [100 v1] Vendor Specific Information: I=
D=3D0001
> Rev=3D1
> > Len=3D010 <?>
> > >>>>              Kernel driver in use: snd_hda_intel
> > >>>>
> > >>>>
> > >>>> Gr=FC=DFe,
> > >>>>   Thomas
> > >> Thomas can you provide output of lspci -t
> > >>
> > >> Also did you had a chance to test my ugly patch ?
> > >>
> > >> Cheers,
> > >> J=E9r=F4me
> > > If my ugly patch works does this quirk also work ?
> > >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
