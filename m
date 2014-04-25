Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id C85EC6B0036
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 19:03:27 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id q108so4669669qgd.17
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 16:03:27 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id k5si4645533qgf.166.2014.04.25.16.03.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 16:03:27 -0700 (PDT)
Received: by mail-qg0-f51.google.com with SMTP id f51so4714239qge.24
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 16:03:26 -0700 (PDT)
Date: Fri, 25 Apr 2014 19:03:22 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: radeon: screen garbled after page allocator change, was: Re:
 [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20140425230321.GG5915@gmail.com>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
 <87r45fajun.fsf@schwinge.name>
 <20140424133722.GD4107@cmpxchg.org>
 <20140425214746.GC5915@gmail.com>
 <20140425215055.GD5915@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140425215055.GD5915@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Thomas Schwinge <thomas@codesourcery.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alex Deucher <alexander.deucher@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, dri-devel@lists.freedesktop.org

On Fri, Apr 25, 2014 at 05:50:57PM -0400, Jerome Glisse wrote:
> On Fri, Apr 25, 2014 at 05:47:48PM -0400, Jerome Glisse wrote:
> > On Thu, Apr 24, 2014 at 09:37:22AM -0400, Johannes Weiner wrote:
> > > Hi Thomas,
> > > 
> > > On Wed, Apr 02, 2014 at 04:26:08PM +0200, Thomas Schwinge wrote:
> > > > Hi!
> > > > 
> > > > On Fri,  2 Aug 2013 11:37:26 -0400, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > > > Each zone that holds userspace pages of one workload must be aged at a
> > > > > speed proportional to the zone size.  [...]
> > > > 
> > > > > Fix this with a very simple round robin allocator.  [...]
> > > > 
> > > > This patch, adding NR_ALLOC_BATCH, eventually landed in mainline as
> > > > commit 81c0a2bb515fd4daae8cab64352877480792b515 (2013-09-11).
> > > > 
> > > > I recently upgraded a Debian testing system from a 3.11 kernel to 3.12,
> > > > and it started to exhibit "strange" issues, which I then bisected to this
> > > > patch.  I'm not saying that the patch is faulty, as it seems to be
> > > > working fine for everyone else, so I rather assume that something in a
> > > > (vastly?) different corner of the kernel (or my hardware?) is broken.
> > > > ;-)
> > > > 
> > > > The issue is that when X.org/lightdm starts up, there are "garbled"
> > > > section on the screen, for example, rectangular boxes that are just black
> > > > or otherwise "distorted", and/or sets of glyphs (corresponding to a set
> > > > of characters; but not all characters) are displayed as rectangular gray
> > > > or black boxes, and/or icons in a GNOME session are not displayed
> > > > properly, and so on.  (Can take a snapshot if that helps?)  Switching to
> > > > a Linux console, I can use that one fine.  Switching back to X, in the
> > > > majority of all cases, the screen will be completely black, but with the
> > > > mouse cursor still rendered properly (done in hardware, I assume).
> > > > 
> > > > Reverting commit 81c0a2bb515fd4daae8cab64352877480792b515, for example on
> > > > top of v3.12, and everything is back to normal.  The problem also
> > > > persists with a v3.14 kernel that I just built.
> > > > 
> > > > I will try to figure out what's going on, but will gladly take any
> > > > pointers, or suggestions about how to tackle such a problem.
> > > > 
> > > > The hardware is a Fujitsu Siemens Esprimo E5600, mainboard D2264-A1, CPU
> > > > AMD Sempron 3000+.  There is a on-board graphics thingy, but I'm not
> > > > using that; instead I put in a Sapphire Radeon HD 4350 card.
> > > 
> > > I went over this code change repeatedly but I could not see anything
> > > directly that would explain it.  However, this patch DOES change the
> > > way allocations are placed (while still respecting zone specifiers
> > > like __GFP_DMA etc.) and so it's possible that they unearthed a
> > > corruption, or a wrongly set dma mask in the drivers.
> > > 
> > > Ccing the radeon driver guys.  Full quote follows.
> > 
> > Can we get a full dmesg, to know if thing like IOMMU are enabled or not.
> > This is even more puzzling as rv710 has 40bit dma mask iirc and thus you
> > should be fine even without IOMMU. But given the patch you point to, it
> > really can only be something that allocate page in place the GPU fails
> > to access.
> > 
> > Thomas how much memory do you have (again dmes will also provide mapping
> > informations) ?
> > 
> > My guess is that the pcie bridge can only remap dma page with 32bit dma
> > mask while the gpu is fine with 40bit dma mask. I always thought that the
> > pcie/pci code did take care of such thing for us.
> > 
> > Cheers,
> > Jerome Glisse
> 
> Forgot to attach patch to test my theory. Does the attached patch fix
> the issue ?

So this is likely it, the SIS chipset of this motherboard is a freak show.
It support both PCIE and AGP at same time

http://www.newegg.com/Product/Product.aspx?Item=N82E16813185068

Why in hell ?

So my guess is that the root pcie bridge is behind the AGP bridge which
swallow any address > 32bit and thus the dma mask of the pcie radeon
card is just believing that we are living in a sane world.

Cheers,
Jerome Glisse

> 
> > 
> > > 
> > > >     $ cat < /proc/cpuinfo
> > > >     processor       : 0
> > > >     vendor_id       : AuthenticAMD
> > > >     cpu family      : 15
> > > >     model           : 47
> > > >     model name      : AMD Sempron(tm) Processor 3000+
> > > >     stepping        : 2
> > > >     cpu MHz         : 1000.000
> > > >     cache size      : 128 KB
> > > >     physical id     : 0
> > > >     siblings        : 1
> > > >     core id         : 0
> > > >     cpu cores       : 1
> > > >     apicid          : 0
> > > >     initial apicid  : 0
> > > >     fpu             : yes
> > > >     fpu_exception   : yes
> > > >     cpuid level     : 1
> > > >     wp              : yes
> > > >     flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext fxsr_opt lm 3dnowext 3dnow rep_good nopl pni lahf_lm
> > > >     bogomips        : 2000.20
> > > >     TLB size        : 1024 4K pages
> > > >     clflush size    : 64
> > > >     cache_alignment : 64
> > > >     address sizes   : 40 bits physical, 48 bits virtual
> > > >     power management: ts fid vid ttp tm stc
> > > >     $ sudo lspci -nn -k -vv
> > > >     00:00.0 Host bridge [0600]: Silicon Integrated Systems [SiS] 761/M761 Host [1039:0761] (rev 01)
> > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 Motherboard [1734:1099]
> > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> > > >             Latency: 64
> > > >             Region 0: Memory at f0000000 (32-bit, non-prefetchable) [size=32M]
> > > >             Capabilities: [a0] AGP version 3.0
> > > >                     Status: RQ=32 Iso- ArqSz=2 Cal=3 SBA+ ITACoh- GART64- HTrans- 64bit- FW- AGP3+ Rate=x4,x8
> > > >                     Command: RQ=1 ArqSz=0 Cal=0 SBA+ AGP- GART64- 64bit- FW- Rate=<none>
> > > >             Capabilities: [d0] HyperTransport: Slave or Primary Interface
> > > >                     Command: BaseUnitID=0 UnitCnt=17 MastHost- DefDir- DUL-
> > > >                     Link Control 0: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0 IsocEn- LSEn- ExtCTL- 64b-
> > > >                     Link Config 0: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=16bit DwFcInEn- LWO=16bit DwFcOutEn-
> > > >                     Link Control 1: CFlE- CST- CFE- <LkFail+ Init- EOC+ TXO+ <CRCErr=0 IsocEn- LSEn- ExtCTL- 64b-
> > > >                     Link Config 1: MLWI=N/C DwFcIn- MLWO=N/C DwFcOut- LWI=N/C DwFcInEn- LWO=N/C DwFcOutEn-
> > > >                     Revision ID: 1.05
> > > >                     Link Frequency 0: 800MHz
> > > >                     Link Error 0: <Prot- <Ovfl- <EOC- CTLTm-
> > > >                     Link Frequency Capability 0: 200MHz+ 300MHz- 400MHz+ 500MHz- 600MHz+ 800MHz+ 1.0GHz+ 1.2GHz+ 1.4GHz- 1.6GHz- Vend-
> > > >                     Feature Capability: IsocFC- LDTSTOP+ CRCTM- ECTLT- 64bA+ UIDRD-
> > > >                     Link Frequency 1: 200MHz
> > > >                     Link Error 1: <Prot- <Ovfl- <EOC- CTLTm-
> > > >                     Link Frequency Capability 1: 200MHz- 300MHz- 400MHz- 500MHz- 600MHz- 800MHz- 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
> > > >                     Error Handling: PFlE- OFlE- PFE- OFE- EOCFE- RFE- CRCFE- SERRFE- CF- RE- PNFE- ONFE- EOCNFE- RNFE- CRCNFE- SERRNFE-
> > > >                     Prefetchable memory behind bridge Upper: 00-00
> > > >                     Bus Number: 00
> > > >             Capabilities: [f0] HyperTransport: Interrupt Discovery and Configuration
> > > >             Capabilities: [5c] HyperTransport: Revision ID: 1.05
> > > >             Kernel driver in use: agpgart-amd64
> > > >     
> > > >     00:01.0 PCI bridge [0604]: Silicon Integrated Systems [SiS] PCI-to-PCI bridge [1039:0004] (prog-if 00 [Normal decode])
> > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Latency: 0, Cache Line Size: 64 bytes
> > > >             Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
> > > >             I/O behind bridge: 00002000-00002fff
> > > >             Memory behind bridge: f2100000-f21fffff
> > > >             Prefetchable memory behind bridge: e0000000-efffffff
> > > >             Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> > > >             BridgeCtl: Parity+ SERR+ NoISA+ VGA+ MAbort- >Reset- FastB2B-
> > > >                     PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> > > >             Capabilities: [d0] Express (v1) Root Port (Slot+), MSI 00
> > > >                     DevCap: MaxPayload 128 bytes, PhantFunc 0
> > > >                             ExtTag+ RBE-
> > > >                     DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> > > >                             RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> > > >                             MaxPayload 128 bytes, MaxReadReq 128 bytes
> > > >                     DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
> > > >                     LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Exit Latency L0s <1us, L1 <2us
> > > >                             ClockPM- Surprise- LLActRep+ BwNot-
> > > >                     LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
> > > >                             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > > >                     LnkSta: Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
> > > >                     SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
> > > >                             Slot #0, PowerLimit 75.000W; Interlock- NoCompl-
> > > >                     SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> > > >                             Control: AttnInd Off, PwrInd Off, Power- Interlock-
> > > >                     SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> > > >                             Changed: MRL- PresDet- LinkState-
> > > >                     RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
> > > >                     RootCap: CRSVisible-
> > > >                     RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> > > >             Capabilities: [bc] HyperTransport: MSI Mapping Enable- Fixed+
> > > >             Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
> > > >                     Address: 00000000  Data: 0000
> > > >             Capabilities: [f4] Power Management version 2
> > > >                     Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> > > >             Kernel driver in use: pcieport
> > > >     
> > > >     00:02.0 ISA bridge [0601]: Silicon Integrated Systems [SiS] SiS965 [MuTIOL Media IO] [1039:0965] (rev 48)
> > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > >             Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> > > >             Latency: 0
> > > >     
> > > >     00:02.5 IDE interface [0101]: Silicon Integrated Systems [SiS] 5513 IDE Controller [1039:5513] (rev 01) (prog-if 80 [Master])
> > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 Motherboard [1734:1095]
> > > >             Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Latency: 128
> > > >             Interrupt: pin ? routed to IRQ 16
> > > >             Region 0: I/O ports at 01f0 [size=8]
> > > >             Region 1: I/O ports at 03f4
> > > >             Region 2: I/O ports at 0170 [size=8]
> > > >             Region 3: I/O ports at 0374
> > > >             Region 4: I/O ports at 1c80 [size=16]
> > > >             Capabilities: [58] Power Management version 2
> > > >                     Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold+)
> > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> > > >             Kernel driver in use: pata_sis
> > > >     
> > > >     00:02.7 Multimedia audio controller [0401]: Silicon Integrated Systems [SiS] SiS7012 AC'97 Sound Controller [1039:7012] (rev a0)
> > > >             Subsystem: Fujitsu Technology Solutions Device [1734:109c]
> > > >             Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > >             Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Latency: 173 (13000ns min, 2750ns max)
> > > >             Interrupt: pin C routed to IRQ 18
> > > >             Region 0: I/O ports at 1400 [size=256]
> > > >             Region 1: I/O ports at 1000 [size=128]
> > > >             Capabilities: [48] Power Management version 2
> > > >                     Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=55mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
> > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> > > >             Kernel driver in use: snd_intel8x0
> > > >     
> > > >     00:03.0 USB controller [0c03]: Silicon Integrated Systems [SiS] USB 1.1 Controller [1039:7001] (rev 0f) (prog-if 10 [OHCI])
> > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 Motherboard [1734:1095]
> > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > >             Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Latency: 64 (20000ns max)
> > > >             Interrupt: pin A routed to IRQ 20
> > > >             Region 0: Memory at f2000000 (32-bit, non-prefetchable) [size=4K]
> > > >             Kernel driver in use: ohci-pci
> > > >     
> > > >     00:03.1 USB controller [0c03]: Silicon Integrated Systems [SiS] USB 1.1 Controller [1039:7001] (rev 0f) (prog-if 10 [OHCI])
> > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 Motherboard [1734:1095]
> > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > >             Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Latency: 64 (20000ns max)
> > > >             Interrupt: pin B routed to IRQ 21
> > > >             Region 0: Memory at f2001000 (32-bit, non-prefetchable) [size=4K]
> > > >             Kernel driver in use: ohci-pci
> > > >     
> > > >     00:03.2 USB controller [0c03]: Silicon Integrated Systems [SiS] USB 1.1 Controller [1039:7001] (rev 0f) (prog-if 10 [OHCI])
> > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 Motherboard [1734:1095]
> > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > >             Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Latency: 64 (20000ns max)
> > > >             Interrupt: pin C routed to IRQ 22
> > > >             Region 0: Memory at f2002000 (32-bit, non-prefetchable) [size=4K]
> > > >             Kernel driver in use: ohci-pci
> > > >     
> > > >     00:03.3 USB controller [0c03]: Silicon Integrated Systems [SiS] USB 2.0 Controller [1039:7002] (prog-if 20 [EHCI])
> > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 [1734:1095]
> > > >             Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > >             Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Latency: 64 (20000ns max)
> > > >             Interrupt: pin D routed to IRQ 23
> > > >             Region 0: Memory at f2003000 (32-bit, non-prefetchable) [size=4K]
> > > >             Capabilities: [50] Power Management version 2
> > > >                     Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> > > >             Kernel driver in use: ehci-pci
> > > >     
> > > >     00:05.0 IDE interface [0101]: Silicon Integrated Systems [SiS] 182 SATA/RAID Controller [1039:0182] (rev 01) (prog-if 8f [Master SecP SecO PriP PriO])
> > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 [1734:1095]
> > > >             Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Latency: 64
> > > >             Interrupt: pin A routed to IRQ 17
> > > >             Region 0: I/O ports at 1cb0 [size=8]
> > > >             Region 1: I/O ports at 1ca4 [size=4]
> > > >             Region 2: I/O ports at 1ca8 [size=8]
> > > >             Region 3: I/O ports at 1ca0 [size=4]
> > > >             Region 4: I/O ports at 1c90 [size=16]
> > > >             Region 5: I/O ports at 1c00 [size=128]
> > > >             Capabilities: [58] Power Management version 2
> > > >                     Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold+)
> > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> > > >             Kernel driver in use: sata_sis
> > > >     
> > > >     00:06.0 PCI bridge [0604]: Silicon Integrated Systems [SiS] PCI-to-PCI bridge [1039:000a] (prog-if 00 [Normal decode])
> > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Latency: 0, Cache Line Size: 64 bytes
> > > >             Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
> > > >             Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> > > >             BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
> > > >                     PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> > > >             Capabilities: [b0] Subsystem: Silicon Integrated Systems [SiS] Device [1039:0000]
> > > >             Capabilities: [c0] MSI: Enable+ Count=1/1 Maskable- 64bit-
> > > >                     Address: fee0100c  Data: 4181
> > > >             Capabilities: [d0] Express (v1) Root Port (Slot+), MSI 00
> > > >                     DevCap: MaxPayload 128 bytes, PhantFunc 0
> > > >                             ExtTag+ RBE-
> > > >                     DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> > > >                             RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> > > >                             MaxPayload 128 bytes, MaxReadReq 128 bytes
> > > >                     DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> > > >                     LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Exit Latency L0s <1us, L1 <2us
> > > >                             ClockPM- Surprise- LLActRep- BwNot-
> > > >                     LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
> > > >                             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > > >                     LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> > > >                     SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
> > > >                             Slot #0, PowerLimit 0.000W; Interlock- NoCompl-
> > > >                     SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> > > >                             Control: AttnInd Off, PwrInd Off, Power- Interlock-
> > > >                     SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> > > >                             Changed: MRL- PresDet- LinkState-
> > > >                     RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
> > > >                     RootCap: CRSVisible-
> > > >                     RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> > > >             Capabilities: [f4] Power Management version 2
> > > >                     Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> > > >             Capabilities: [100 v1] Virtual Channel
> > > >                     Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
> > > >                     Arb:    Fixed- WRR32- WRR64- WRR128-
> > > >                     Ctrl:   ArbSelect=Fixed
> > > >                     Status: InProgress-
> > > >                     VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> > > >                             Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> > > >                             Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
> > > >                             Status: NegoPending- InProgress-
> > > >             Capabilities: [130 v1] Advanced Error Reporting
> > > >                     UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > > >                     UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> > > >                     UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> > > >                     CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
> > > >                     CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
> > > >                     AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
> > > >             Kernel driver in use: pcieport
> > > >     
> > > >     00:09.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8169 PCI Gigabit Ethernet Controller [10ec:8169] (rev 10)
> > > >             Subsystem: Fujitsu Technology Solutions D2030-A1 [1734:1091]
> > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> > > >             Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
> > > >             Interrupt: pin A routed to IRQ 19
> > > >             Region 0: I/O ports at 1800 [size=256]
> > > >             Region 1: Memory at f2004000 (32-bit, non-prefetchable) [size=256]
> > > >             Capabilities: [dc] Power Management version 2
> > > >                     Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
> > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> > > >             Kernel driver in use: r8169
> > > >     
> > > >     00:18.0 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration [1022:1100]
> > > >             Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Capabilities: [80] HyperTransport: Host or Secondary Interface
> > > >                     Command: WarmRst+ DblEnd- DevNum=0 ChainSide- HostHide+ Slave- <EOCErr- DUL-
> > > >                     Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0 IsocEn- LSEn- ExtCTL- 64b-
> > > >                     Link Config: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=16bit DwFcInEn- LWO=16bit DwFcOutEn-
> > > >                     Revision ID: 1.02
> > > >                     Link Frequency: 800MHz
> > > >                     Link Error: <Prot- <Ovfl- <EOC- CTLTm-
> > > >                     Link Frequency Capability: 200MHz+ 300MHz- 400MHz+ 500MHz- 600MHz+ 800MHz+ 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
> > > >                     Feature Capability: IsocFC- LDTSTOP+ CRCTM- ECTLT- 64bA- UIDRD- ExtRS- UCnfE-
> > > >     
> > > >     00:18.1 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] K8 [Athlon64/Opteron] Address Map [1022:1101]
> > > >             Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > >             Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >     
> > > >     00:18.2 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] K8 [Athlon64/Opteron] DRAM Controller [1022:1102]
> > > >             Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > >             Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Kernel driver in use: amd64_edac
> > > >     
> > > >     00:18.3 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] K8 [Athlon64/Opteron] Miscellaneous Control [1022:1103]
> > > >             Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> > > >             Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Kernel driver in use: k8temp
> > > >     
> > > >     01:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] RV710/M92 [Mobility Radeon HD 4530/4570/545v] [1002:9553] (prog-if 00 [VGA controller])
> > > >             Subsystem: PC Partner Limited / Sapphire Technology Device [174b:3092]
> > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> > > >             Latency: 0, Cache Line Size: 64 bytes
> > > >             Interrupt: pin A routed to IRQ 42
> > > >             Region 0: Memory at e0000000 (64-bit, prefetchable) [size=256M]
> > > >             Region 2: Memory at f2100000 (64-bit, non-prefetchable) [size=64K]
> > > >             Region 4: I/O ports at 2000 [size=256]
> > > >             [virtual] Expansion ROM at f2120000 [disabled] [size=128K]
> > > >             Capabilities: [50] Power Management version 3
> > > >                     Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> > > >             Capabilities: [58] Express (v2) Legacy Endpoint, MSI 00
> > > >                     DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
> > > >                             ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> > > >                     DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> > > >                             RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> > > >                             MaxPayload 128 bytes, MaxReadReq 128 bytes
> > > >                     DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> > > >                     LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Exit Latency L0s <64ns, L1 <1us
> > > >                             ClockPM- Surprise- LLActRep- BwNot-
> > > >                     LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
> > > >                             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > > >                     LnkSta: Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> > > >                     DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, OBFF Not Supported
> > > >                     DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
> > > >                     LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
> > > >                              Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> > > >                              Compliance De-emphasis: -6dB
> > > >                     LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
> > > >                              EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> > > >             Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
> > > >                     Address: 00000000fee0100c  Data: 41e1
> > > >             Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
> > > >             Kernel driver in use: radeon
> > > >     
> > > >     01:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] RV710/730 HDMI Audio [Radeon HD 4000 series] [1002:aa38]
> > > >             Subsystem: PC Partner Limited / Sapphire Technology Device [174b:aa38]
> > > >             Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> > > >             Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > > >             Latency: 0, Cache Line Size: 64 bytes
> > > >             Interrupt: pin B routed to IRQ 41
> > > >             Region 0: Memory at f2110000 (64-bit, non-prefetchable) [size=16K]
> > > >             Capabilities: [50] Power Management version 3
> > > >                     Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> > > >                     Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> > > >             Capabilities: [58] Express (v2) Legacy Endpoint, MSI 00
> > > >                     DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
> > > >                             ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> > > >                     DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> > > >                             RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> > > >                             MaxPayload 128 bytes, MaxReadReq 128 bytes
> > > >                     DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> > > >                     LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Exit Latency L0s <64ns, L1 <1us
> > > >                             ClockPM- Surprise- LLActRep- BwNot-
> > > >                     LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
> > > >                             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> > > >                     LnkSta: Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> > > >                     DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, OBFF Not Supported
> > > >                     DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
> > > >                     LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
> > > >                              EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> > > >             Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
> > > >                     Address: 00000000fee0100c  Data: 41d1
> > > >             Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
> > > >             Kernel driver in use: snd_hda_intel
> > > > 
> > > > 
> > > > Grusse,
> > > >  Thomas
> > > 
> > > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

> diff --git a/drivers/gpu/drm/radeon/radeon_device.c b/drivers/gpu/drm/radeon/radeon_device.c
> index 511fe26..632f796 100644
> --- a/drivers/gpu/drm/radeon/radeon_device.c
> +++ b/drivers/gpu/drm/radeon/radeon_device.c
> @@ -1244,6 +1244,7 @@ int radeon_device_init(struct radeon_device *rdev,
>  		rdev->need_dma32 = true;
>  
>  	dma_bits = rdev->need_dma32 ? 32 : 40;
> +	dma_bits = 32;
>  	r = pci_set_dma_mask(rdev->pdev, DMA_BIT_MASK(dma_bits));
>  	if (r) {
>  		rdev->need_dma32 = true;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
