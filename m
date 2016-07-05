Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9D906B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 23:00:23 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g8so224856772itb.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 20:00:23 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id u62si997619oia.208.2016.07.04.20.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 20:00:22 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id u201so213092266oie.0
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 20:00:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <577A84B4.8020505@linux.intel.com>
References: <577A7203.9010305@linux.intel.com> <CAJZ5v0ji9pVgAZZJT+RG83RNE4-GgJAp88Mw2ddVt3H6eHG72g@mail.gmail.com>
 <577A7B0A.4090107@linux.intel.com> <20160704152131.GA2766@wunner.de> <577A84B4.8020505@linux.intel.com>
From: AceLan Kao <acelan@gmail.com>
Date: Tue, 5 Jul 2016 11:00:21 +0800
Message-ID: <CAMz9Wg9wEhjH9izB_11xoNe954urJcRhrjbbyk9b45+42Vx6bg@mail.gmail.com>
Subject: Re: kmem_cache_alloc fail with unable to handle paging request after
 pci hotplug remove.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathias Nyman <mathias.nyman@linux.intel.com>
Cc: Lukas Wunner <lukas@wunner.de>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, USB <linux-usb@vger.kernel.org>

Hi,

These are logs from my machine.

*** Before plug-in the USB key

u@u-XPS-13-9xxx:~$ sudo lspci -vvvv -s 00:1c.0
00:1c.0 PCI bridge: Intel Corporation Device 9d10 (rev f1) (prog-if 00
[Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0
        Interrupt: pin A routed to IRQ 16
        Bus: primary=00, secondary=01, subordinate=39, sec-latency=0
        I/O behind bridge: 00002000-00002fff
        Memory behind bridge: c4000000-da0fffff
        Prefetchable memory behind bridge: 00000000a0000000-00000000c1ffffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0
                        ExtTag- RBE+
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #1, Speed 8GT/s, Width x2, ASPM L1, Exit
Latency L0s unlimited, L1 <16us
                        ClockPM- Surprise- LLActRep+ BwNot+ ASPMOptComp+
                LnkCtl: ASPM L1 Enabled; RCB 64 bytes Disabled- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train-
SlotClk+ DLActive- BWMgmt- ABWMgmt-
                SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd-
HotPlug+ Surprise+
                        Slot #4, PowerLimit 25.000W; Interlock- NoCompl+
                SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+
CmdCplt- HPIrq- LinkChg-
                        Control: AttnInd Unknown, PwrInd Unknown,
Power- Interlock-
                SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
PresDet- Interlock-
                        Changed: MRL- PresDet- LinkState-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
PMEIntEna- CRSVisible-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
PMEIntEna- CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
                DevCap2: Completion Timeout: Range ABC, TimeoutDis+,
LTR+, OBFF Not Supported ARIFwd+
                DevCtl2: Completion Timeout: 50us to 50ms,
TimeoutDis-, LTR-, OBFF Disabled ARIFwd-
                LnkCtl2: Target Link Speed: 8GT/s, EnterCompliance- SpeedDis-
                         Transmit Margin: Normal Operating Range,
EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -3.5dB,
EqualizationComplete-, EqualizationPhase1-
                         EqualizationPhase2-, EqualizationPhase3-,
LinkEqualizationRequest-
        Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
                Address: 00000000  Data: 0000
        Capabilities: [90] Subsystem: Dell Device 075b
        Capabilities: [a0] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO+ CmpltAbrt-
UnxCmplt+ RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
        Capabilities: [140 v1] Access Control Services
                ACSCap: SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+
UpstreamFwd- EgressCtrl- DirectTrans-
                ACSCtl: SrcValid- TransBlk- ReqRedir- CmpltRedir-
UpstreamFwd- EgressCtrl- DirectTrans-
        Capabilities: [220 v1] #19
        Kernel driver in use: pcieport
        Kernel modules: shpchp

*** Plug-in the USB key

u@u-XPS-13-9xxx:~$ lspci -t
-[0000:00]-+-00.0
           +-02.0
           +-04.0
           +-14.0
           +-14.2
           +-15.0
           +-15.1
           +-16.0
           +-17.0
           +-1c.0-[01-39]----00.0-[02-39]--+-00.0-[03]--
           |                               +-01.0-[04-38]--
           |                               \-02.0-[39]----00.0
           +-1c.4-[3a]----00.0
           +-1c.5-[3b]----00.0
           +-1f.0
           +-1f.2
           +-1f.3
           \-1f.4

u@u-XPS-13-9xxx:~$ lspci
00:00.0 Host bridge: Intel Corporation Device 5904 (rev 02)
00:02.0 VGA compatible controller: Intel Corporation Device 5916 (rev 02)
00:04.0 Signal processing controller: Intel Corporation Skylake
Processor Thermal Subsystem (rev 02)
00:14.0 USB controller: Intel Corporation Sunrise Point-LP USB 3.0
xHCI Controller (rev 21)
00:14.2 Signal processing controller: Intel Corporation Sunrise
Point-LP Thermal subsystem (rev 21)
00:15.0 Signal processing controller: Intel Corporation Sunrise
Point-LP Serial IO I2C Controller (rev 21)
00:15.1 Signal processing controller: Intel Corporation Sunrise
Point-LP Serial IO I2C Controller (rev 21)
00:16.0 Communication controller: Intel Corporation Sunrise Point-LP
CSME HECI (rev 21)
00:17.0 SATA controller: Intel Corporation Sunrise Point-LP SATA
Controller [AHCI mode] (rev 21)
00:1c.0 PCI bridge: Intel Corporation Device 9d10 (rev f1)
00:1c.4 PCI bridge: Intel Corporation Sunrise Point-LP PCI Express
Root Port (rev f1)
00:1c.5 PCI bridge: Intel Corporation Sunrise Point-LP PCI Express
Root Port (rev f1)
00:1f.0 ISA bridge: Intel Corporation Device 9d58 (rev 21)
00:1f.2 Memory controller: Intel Corporation Sunrise Point-LP PMC (rev 21)
00:1f.3 Audio device: Intel Corporation Device 9d71 (rev 21)
00:1f.4 SMBus: Intel Corporation Sunrise Point-LP SMBus (rev 21)
01:00.0 PCI bridge: Intel Corporation Device 1576
02:00.0 PCI bridge: Intel Corporation Device 1576
02:01.0 PCI bridge: Intel Corporation Device 1576
02:02.0 PCI bridge: Intel Corporation Device 1576
39:00.0 USB controller: Intel Corporation Device 15b5
3a:00.0 Network controller: Qualcomm Atheros QCA6174 802.11ac Wireless
Network Adapter (rev 32)
3b:00.0 Unassigned class [ff00]: Realtek Semiconductor Co., Ltd.
RTS525A PCI Express Card Reader (rev 01)

*** Remove the USB key

u@u-XPS-13-9xxx:~$ lspci -t
-[0000:00]-+-00.0
           +-02.0
           +-04.0
           +-14.0
           +-14.2
           +-15.0
           +-15.1
           +-16.0
           +-17.0
           +-1c.0-[01-39]--
           +-1c.4-[3a]----00.0
           +-1c.5-[3b]----00.0
           +-1f.0
           +-1f.2
           +-1f.3
           \-1f.4

u@u-XPS-13-9xxx:~$ lspci
00:00.0 Host bridge: Intel Corporation Device 5904 (rev 02)
00:02.0 VGA compatible controller: Intel Corporation Device 5916 (rev 02)
00:04.0 Signal processing controller: Intel Corporation Skylake
Processor Thermal Subsystem (rev 02)
00:14.0 USB controller: Intel Corporation Sunrise Point-LP USB 3.0
xHCI Controller (rev 21)
00:14.2 Signal processing controller: Intel Corporation Sunrise
Point-LP Thermal subsystem (rev 21)
00:15.0 Signal processing controller: Intel Corporation Sunrise
Point-LP Serial IO I2C Controller (rev 21)
00:15.1 Signal processing controller: Intel Corporation Sunrise
Point-LP Serial IO I2C Controller (rev 21)
00:16.0 Communication controller: Intel Corporation Sunrise Point-LP
CSME HECI (rev 21)
00:17.0 SATA controller: Intel Corporation Sunrise Point-LP SATA
Controller [AHCI mode] (rev 21)
00:1c.0 PCI bridge: Intel Corporation Device 9d10 (rev f1)
00:1c.4 PCI bridge: Intel Corporation Sunrise Point-LP PCI Express
Root Port (rev f1)
00:1c.5 PCI bridge: Intel Corporation Sunrise Point-LP PCI Express
Root Port (rev f1)
00:1f.0 ISA bridge: Intel Corporation Device 9d58 (rev 21)
00:1f.2 Memory controller: Intel Corporation Sunrise Point-LP PMC (rev 21)
00:1f.3 Audio device: Intel Corporation Device 9d71 (rev 21)
00:1f.4 SMBus: Intel Corporation Sunrise Point-LP SMBus (rev 21)
3a:00.0 Network controller: Qualcomm Atheros QCA6174 802.11ac Wireless
Network Adapter (rev 32)
3b:00.0 Unassigned class [ff00]: Realtek Semiconductor Co., Ltd.
RTS525A PCI Express Card Reader (rev 01)

u@u-XPS-13-9xxx:~$ sudo lspci -vvvv -s 00:1c.0
00:1c.0 PCI bridge: Intel Corporation Device 9d10 (rev f1) (prog-if 00
[Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0
        Interrupt: pin A routed to IRQ 16
        Bus: primary=00, secondary=01, subordinate=39, sec-latency=0
        I/O behind bridge: 00002000-00002fff
        Memory behind bridge: c4000000-da0fffff
        Prefetchable memory behind bridge: 00000000a0000000-00000000c1ffffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0
                        ExtTag- RBE+
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #1, Speed 8GT/s, Width x2, ASPM L1, Exit
Latency L0s <1us, L1 <16us
                        ClockPM- Surprise- LLActRep+ BwNot+ ASPMOptComp+
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x2, TrErr- Train-
SlotClk+ DLActive- BWMgmt+ ABWMgmt-
                SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd-
HotPlug+ Surprise+
                        Slot #4, PowerLimit 25.000W; Interlock- NoCompl+
                SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+
CmdCplt- HPIrq- LinkChg-
                        Control: AttnInd Unknown, PwrInd Unknown,
Power- Interlock-
                SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
PresDet- Interlock-
                        Changed: MRL- PresDet- LinkState+
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
PMEIntEna- CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
                DevCap2: Completion Timeout: Range ABC, TimeoutDis+,
LTR+, OBFF Not Supported ARIFwd+
                DevCtl2: Completion Timeout: 50us to 50ms,
TimeoutDis-, LTR-, OBFF Disabled ARIFwd-
                LnkCtl2: Target Link Speed: 8GT/s, EnterCompliance- SpeedDis-
                         Transmit Margin: Normal Operating Range,
EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -3.5dB,
EqualizationComplete-, EqualizationPhase1-
                         EqualizationPhase2-, EqualizationPhase3-,
LinkEqualizationRequest-
        Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
                Address: 00000000  Data: 0000
        Capabilities: [90] Subsystem: Dell Device 075b
        Capabilities: [a0] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO+ CmpltAbrt-
UnxCmplt+ RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr+ BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
        Capabilities: [140 v1] Access Control Services
                ACSCap: SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+
UpstreamFwd- EgressCtrl- DirectTrans-
                ACSCtl: SrcValid- TransBlk- ReqRedir- CmpltRedir-
UpstreamFwd- EgressCtrl- DirectTrans-
        Capabilities: [220 v1] #19
        Kernel driver in use: pcieport
        Kernel modules: shpchp

2016-07-04 23:45 GMT+08:00 Mathias Nyman <mathias.nyman@linux.intel.com>:
> On 04.07.2016 18:21, Lukas Wunner wrote:
>>
>> On Mon, Jul 04, 2016 at 06:04:42PM +0300, Mathias Nyman wrote:
>>>
>>> On 04.07.2016 17:25, Rafael J. Wysocki wrote:
>>>>
>>>> On Mon, Jul 4, 2016 at 4:26 PM, Mathias Nyman
>>>> <mathias.nyman@linux.intel.com> wrote:
>>>>>
>>>>> AceLan Kao can get his DELL XPS 13 laptop to hang by
>>>>> plugging/un-plugging
>>>>> a USB 3.1 key via thunderbolt port.
>>>>>
>>>>> Allocating memory fails after this, always pointing to NULL pointer or
>>>>> page request failing in get_freepointer() called by
>>>>> kmalloc/kmem_cache_alloc.
>>>>>
>>>>> Unplugging a usb type-c device from the thunderbolt port on Alpine
>>>>> Ridge
>>>>> based systems like this one will hotplug remove PCI bridges together
>>>>> with the USB xhci controller behind them.
>>
>>
>> Yes, that matches with the lspci output you've posted, the whole
>> Thunderbolt controller is gone after unplug. Perhaps it's powered
>> down? What does "lspci -vvvv -s 00:1d.6" say? (Does the root port
>> still have a link to the Thunderbolt controller?)
>>
>
>
> "lspci -vvvv -s 00:1d.6" after unplug (on my working DELL XPS)
>
>
> 00:1d.6 PCI bridge: Intel Corporation Sunrise Point-H PCI Express Root Port
> #15 (rev f1) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin C routed to IRQ 18
>         Bus: primary=00, secondary=06, subordinate=3e, sec-latency=0
>         I/O behind bridge: 00002000-00002fff
>         Memory behind bridge: c4000000-da0fffff
>         Prefetchable memory behind bridge: 0000000080000000-00000000a1ffffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort+ <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
>                 DevCap: MaxPayload 256 bytes, PhantFunc 0
>                         ExtTag- RBE+
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr+
> TransPend-
>                 LnkCap: Port #15, Speed 8GT/s, Width x2, ASPM L0s L1, Exit
> Latency L0s <1us, L1 <16us
>                         ClockPM- Surprise- LLActRep+ BwNot+ ASPMOptComp+
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x2, TrErr- Train- SlotClk+
> DLActive- BWMgmt+ ABWMgmt-
>                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+
> Surprise+
>                         Slot #18, PowerLimit 25.000W; Interlock- NoCompl+
>                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt-
> HPIrq- LinkChg-
>                         Control: AttnInd Unknown, PwrInd Unknown, Power-
> Interlock-
>                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet-
> Interlock-
>                         Changed: MRL- PresDet- LinkState+
>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna-
> CRSVisible-
>                 RootCap: CRSVisible-
>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>                 DevCap2: Completion Timeout: Range ABC, TimeoutDis+, LTR+,
> OBFF Not Supported ARIFwd+
>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,
> LTR-, OBFF Disabled ARIFwd-
>                 LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance-
> SpeedDis-
>                          Transmit Margin: Normal Operating Range,
> EnterModifiedCompliance- ComplianceSOS-
>                          Compliance De-emphasis: -6dB
>                 LnkSta2: Current De-emphasis Level: -3.5dB,
> EqualizationComplete-, EqualizationPhase1-
>                          EqualizationPhase2-, EqualizationPhase3-,
> LinkEqualizationRequest-
>         Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
>                 Address: 00000000  Data: 0000
>         Capabilities: [90] Subsystem: Dell Sunrise Point-H PCI Express Root
> Port
>         Capabilities: [a0] Power Management version 3
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [100 v1] Advanced Error Reporting
>                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
> RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO+ CmpltAbrt- UnxCmplt+
> RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                 UESvrt: DLP+ SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
> RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>                 CESta:  RxErr+ BadTLP- BadDLLP- Rollover+ Timeout+
> NonFatalErr+
>                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> NonFatalErr+
>                 AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap-
> ChkEn-
>         Capabilities: [140 v1] Access Control Services
>                 ACSCap: SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+
> UpstreamFwd- EgressCtrl- DirectTrans-
>                 ACSCtl: SrcValid- TransBlk- ReqRedir- CmpltRedir-
> UpstreamFwd- EgressCtrl- DirectTrans-
>         Capabilities: [200 v1] L1 PM Substates
>                 L1SubCap: PCI-PM_L1.2+ PCI-PM_L1.1+ ASPM_L1.2+ ASPM_L1.1+
> L1_PM_Substates+
>                           PortCommonModeRestoreTime=40us
> PortTPowerOnTime=10us
>         Capabilities: [220 v1] #19
>         Kernel driver in use: pcieport
>         Kernel modules: shpchp
>
>
> AceLan Kao, can you confirm your lspci output looks similar on the failing
> DELL XPS?
>
> -Mathias



-- 
Chia-Lin Kao(AceLan)
http://blog.acelan.idv.tw/
E-Mail: acelan.kaoATcanonical.com (s/AT/@/)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
