Received: from megami.veritas.com (megami.veritas.com [192.203.46.101])
	by pallas.veritas.com (8.9.1a/8.9.1) with SMTP id JAA15969
	for <linux-mm@kvack.org>; Thu, 17 Aug 2000 09:01:06 -0700 (PDT)
Received: from saturn.homenet([192.168.225.173]) (15402 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <tigran@veritas.com>)
	id <m13PS1A-0000MfC@megami.veritas.com>
	for <linux-mm@kvack.org>; Thu, 17 Aug 2000 08:55:44 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #4 built 1999-Aug-24)
Date: Thu, 17 Aug 2000 17:02:22 +0100 (BST)
From: Tigran Aivazian <tigran@veritas.com>
Subject: [OT-linux-kernel] who is generating my irq 16???
Message-ID: <Pine.LNX.4.21.0008171656430.1106-100000@saturn.homenet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi guys,

My PCI/MP configuration is such that one of the ports of dual-port
eepro100 card and the sound card would share irq 16. So I compiled
soundmodule (es11371) as a module in order to avoid shared irq processing
and slow down eepro100. However, I still get irq 16 generated somehow even
though 0 packets were ever received/transmitted on the relevant interface.

Any ideas? I definitely didn't load es1371 module...

$ cat /proc/interrupts 
           CPU0       CPU1       
  0:     223982     233949    IO-APIC-edge  timer
  1:       9786       8588    IO-APIC-edge  keyboard
  2:          0          0          XT-PIC  cascade
  5:        551        615    IO-APIC-edge  NE2000
  7:          0          0    IO-APIC-edge  parport0
  8:          1          0    IO-APIC-edge  rtc
 12:       2286       2707    IO-APIC-edge  PS/2 Mouse
 13:          1          0          XT-PIC  fpu
 14:       8421      18869    IO-APIC-edge  ide0
 15:          3          9    IO-APIC-edge  ide1
 16:       1326        914   IO-APIC-level  eth2
 17:         26         26   IO-APIC-level  aic7xxx
 18:          0          0   IO-APIC-level  bttv
 19:        983       1258   IO-APIC-level  eth1
NMI:     457835     457835 
LOC:     457777     457773 
ERR:          0

$ cat /proc/net/dev
Inter-|   Receive                                                |
Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes
packets errs drop fifo colls carrier compressed
    lo:   38172     196    0    0    0     0          0         0    38172
196    0    0    0     0       0          0
  eth0:   74931     520    0    0    0     0          0         2    45111
646    0    0    0     0       0          0
  eth1:       0       0    0    0    0     0          0         0        0
0    0    0    0     0       0          0
  eth2:       0       0    0    0    0     0          0         0        0
0    0    0    0     0       0          0
vmnet1:       0       0    0    0    0     0          0         0        0
57    0    0    0     0       0          0

$ ifconfig
eth0      Link encap:Ethernet  HWaddr 00:48:45:80:6D:38  
          inet addr:192.168.2.1  Bcast:192.168.2.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:520 errors:0 dropped:0 overruns:0 frame:0
          TX packets:646 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          Interrupt:5 Base address:0x220 

eth1      Link encap:Ethernet  HWaddr 00:D0:B7:61:37:E2  
          inet addr:192.168.3.1  Bcast:192.168.3.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          Interrupt:19 Base address:0xb000 

eth2      Link encap:Ethernet  HWaddr 00:D0:B7:61:37:E3  
          inet addr:192.168.4.1  Bcast:192.168.4.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          Interrupt:16 Base address:0xd000 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16192  Metric:1
          RX packets:196 errors:0 dropped:0 overruns:0 frame:0
          TX packets:196 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 

vmnet1    Link encap:Ethernet  HWaddr 00:50:56:01:00:00  
          inet addr:172.16.6.1  Bcast:172.16.6.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:57 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 


00:00.0 Host bridge: Intel Corporation 440BX/ZX - 82443BX/ZX Host bridge (rev 03)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 64 set
	Region 0: Memory at e0000000 (32-bit, prefetchable) [size=64M]
	Capabilities: [a0] AGP version 1.0
		Status: RQ=31 SBA+ 64bit- FW- Rate=x1,x2
		Command: RQ=0 SBA- AGP- 64bit- FW- Rate=<none>
00: 86 80 90 71 06 00 10 22 03 00 00 06 00 40 00 00
10: 08 00 00 e0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 a0 00 00 00 00 00 00 00 00 00 00 00

00:01.0 PCI bridge: Intel Corporation 440BX/ZX - 82443BX/ZX AGP bridge (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 set
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: e4000000-e7ffffff
	Prefetchable memory behind bridge: ee000000-eeffffff
	BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B+
00: 86 80 91 71 07 01 20 02 03 00 04 06 00 40 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 40 c0 c0 a0 22
20: 00 e4 f0 e7 00 ee f0 ee 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 88 00

00:07.0 ISA bridge: Intel Corporation 82371AB PIIX4 ISA (rev 02)
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 set
00: 86 80 10 71 0f 00 80 02 02 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:07.1 IDE interface: Intel Corporation 82371AB PIIX4 IDE (rev 01) (prog-if 80 [Master])
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 set
	Region 4: I/O ports at f000 [size=16]
00: 86 80 11 71 05 00 80 02 01 80 01 01 00 40 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:07.2 USB Controller: Intel Corporation 82371AB PIIX4 USB (rev 01) (prog-if 00 [UHCI])
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 set
	Interrupt: pin D routed to IRQ 0
	Region 4: I/O ports at e400 [size=32]
00: 86 80 12 71 05 00 80 02 01 00 03 0c 00 40 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 e4 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 ff 04 00 00

00:07.3 Bridge: Intel Corporation 82371AB PIIX4 ACPI (rev 02)
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
00: 86 80 13 71 03 00 80 02 02 00 80 06 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:08.0 Multimedia video controller: 3Dfx Interactive, Inc. Voodoo 2 (rev 02)
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Region 0: Memory at ec000000 (32-bit, prefetchable) [size=16M]
00: 1a 12 02 00 02 00 80 00 02 00 00 04 00 00 00 00
10: 08 00 00 ec 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 ff 00 00 00

00:09.0 SCSI storage controller: Adaptec AHA-294x / AIC-7871 (rev 03)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 8 min, 8 max, 64 set, cache line size 08
	Interrupt: pin A routed to IRQ 17
	Region 0: I/O ports at e000 [size=256]
	Region 1: Memory at ef101000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at ed000000 [disabled] [size=64K]
00: 04 90 78 71 07 00 80 02 03 00 00 01 08 40 00 00
10: 01 e0 00 00 00 10 10 ef 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 ed 00 00 00 00 00 00 00 00 0b 01 08 08

00:0a.0 Multimedia video controller: Brooktree Corporation Bt878 (rev 02)
	Subsystem: Hauppage computer works Inc.: Unknown device 13eb
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 16 min, 40 max, 64 set
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at ef102000 (32-bit, prefetchable) [size=4K]
00: 9e 10 6e 03 06 00 80 02 02 00 00 04 00 40 80 00
10: 08 20 10 ef 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 70 00 eb 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 01 10 28

00:0a.1 Multimedia controller: Brooktree Corporation Bt878 (rev 02)
	Subsystem: Hauppage computer works Inc.: Unknown device 13eb
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 4 min, 255 max, 64 set
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at ef100000 (32-bit, prefetchable) [size=4K]
00: 9e 10 78 08 06 00 80 02 02 00 80 04 00 40 80 00
10: 08 00 10 ef 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 70 00 eb 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 01 04 ff

00:0b.0 PCI bridge: Digital Equipment Corporation DECchip 21152 (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 set, cache line size 02
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=64
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: e8000000-ebffffff
	Prefetchable memory behind bridge: 00000000ef000000-00000000ef000000
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- AuxPwr- DSI- D1- D2- PME-
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 11 10 24 00 07 01 90 02 03 00 04 06 02 40 01 00
10: 00 00 00 00 00 00 00 00 00 02 02 40 d1 d1 80 22
20: 00 e8 f0 eb 01 ef 01 ef 00 00 00 00 00 00 00 00
30: 00 00 00 00 dc 00 00 00 00 00 00 00 00 00 06 00

00:0c.0 Multimedia audio controller: Ensoniq ES1371 [AudioPCI-97] (rev 06)
	Subsystem: Ensoniq: Unknown device 1371
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 12 min, 128 max, 64 set
	Interrupt: pin A routed to IRQ 16
	Region 0: I/O ports at e800 [size=64]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- AuxPwr+ DSI+ D1- D2+ PME+
		Status: D3 PME-Enable- DSel=0 DScale=0 PME-
00: 74 12 71 13 05 00 10 04 06 00 01 04 00 40 00 00
10: 01 e8 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 74 12 71 13
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0b 01 0c 80

01:00.0 VGA compatible controller: Matrox Graphics, Inc. MGA G200 AGP (rev 01) (prog-if 00 [VGA])
	Subsystem: Matrox Graphics, Inc. Millennium G200 AGP
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 16 min, 32 max, 64 set, cache line size 08
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at ee000000 (32-bit, prefetchable) [size=16M]
	Region 1: Memory at e4000000 (32-bit, non-prefetchable) [size=16K]
	Region 2: Memory at e5000000 (32-bit, non-prefetchable) [size=8M]
	Expansion ROM at <unassigned> [disabled] [size=64K]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- AuxPwr- DSI+ D1- D2- PME-
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [f0] AGP version 1.0
		Status: RQ=31 SBA+ 64bit- FW- Rate=x1,x2
		Command: RQ=31 SBA+ AGP+ 64bit- FW- Rate=x2
00: 2b 10 21 05 07 00 90 02 01 00 00 03 08 40 00 00
10: 08 00 00 ee 00 00 00 e4 00 00 00 e5 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 2b 10 03 ff
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0b 01 10 20

02:04.0 Ethernet controller: Intel Corporation 82557 [Ethernet Pro 100] (rev 05)
	Subsystem: Intel Corporation EtherExpress PRO/100+ Dual Port Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 8 min, 56 max, 64 set, cache line size 08
	Interrupt: pin A routed to IRQ 19
	Region 0: Memory at ef000000 (32-bit, prefetchable) [size=4K]
	Region 1: I/O ports at d000 [size=32]
	Region 2: Memory at ea100000 (32-bit, non-prefetchable) [size=1M]
	Expansion ROM at e8000000 [disabled] [size=1M]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- AuxPwr- DSI+ D1+ D2+ PME+
		Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
00: 86 80 29 12 07 00 90 02 05 00 00 02 08 40 00 00
10: 08 00 00 ef 01 d0 00 00 00 00 10 ea 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 f0 10
30: 00 00 00 e8 dc 00 00 00 00 00 00 00 0b 01 08 38

02:05.0 Ethernet controller: Intel Corporation 82557 [Ethernet Pro 100] (rev 05)
	Subsystem: Intel Corporation EtherExpress PRO/100+ Dual Port Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 8 min, 56 max, 64 set, cache line size 08
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at ef001000 (32-bit, prefetchable) [size=4K]
	Region 1: I/O ports at d400 [size=32]
	Region 2: Memory at ea000000 (32-bit, non-prefetchable) [size=1M]
	Expansion ROM at e9000000 [disabled] [size=1M]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- AuxPwr- DSI+ D1+ D2+ PME+
		Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
00: 86 80 29 12 07 00 90 02 05 00 00 02 08 40 00 00
10: 08 10 00 ef 01 d4 00 00 00 00 00 ea 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 f0 10
30: 00 00 00 e9 dc 00 00 00 00 00 00 00 0b 01 08 38


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
