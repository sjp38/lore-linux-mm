Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id CA3AA6B00F8
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 06:25:42 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so552391pac.5
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 03:25:42 -0700 (PDT)
Received: from va3outboundpool.messaging.microsoft.com (va3ehsobe002.messaging.microsoft.com. [216.32.180.12])
        by mx.google.com with ESMTPS id wj5si33948913pbc.22.2014.06.10.03.25.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 10 Jun 2014 03:25:41 -0700 (PDT)
From: "Steven Miao (Steven Miao)" <realmz6@gmail.com>
Subject: [PATCH] mm: nommu: per-thread vma cache fix
Date: Tue, 10 Jun 2014 18:28:48 +0800
Message-ID: <1402396130-22368-1-git-send-email-realmz6@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Steven Miao <realmz6@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Jerome Marchand <jmarchan@redhat.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <liuj97@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Davidlohr Bueso <davidlohr@hp.com>, Choi Gi-yong <yong@gnoy.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen@asianux.com>, Mitchel Humpherys <mitchelh@codeaurora.org>, linux-kernel@vger.kernel.org

From: Steven Miao <realmz6@gmail.com>

mm could be removed from current task struct, using previous vma->vm_mm

It will crash on blackfin after updated to Linux 3.15. The commit "mm: per-thread vma caching" caused the crash.
mm could be removed from current task struct before 
mmput()->
	exit_mmap()->
		   delete_vma_from_mm()

the detailed booting log:

## Booting kernel from Legacy Image at 01000000 ...
   Image Name:   bf609-0.0-3.15.0-ADI-2014R1-pre-
   Image Type:   Blackfin Linux Kernel Image (gzip compressed)
   Data Size:    10293222 Bytes = 9.8 MiB
   Load Address: 00001000
   Entry Point:  002e796c
   Verifying Checksum ... OK
   Uncompressing Kernel Image ... OK
Starting Kernel at = 002e796c
Linux version 3.15.0-ADI-2014R1-pre-00345-gea9f446 (steven@steven-OptiPlex-390) (gcc version 4.3.5 (ADI-trunk/svn-5962) ) #25 Tue Jun 10 17:47:46 CST 2014
register early platform devices
bootconsole [early_shadow0] enabled
ERROR: Not running on ADSP-BF609: unknown CPUID 0x0000 Rev 0.0
bootconsole [early_BFuart0] enabled
early printk enabled on early_BFuart0
Board Memory: 128MB
Kernel Managed Memory: 128MB
Memory map:
  fixedcode = 0x00000400-0x00000490
  text      = 0x00001000-0x001fa910
  rodata    = 0x001fa934-0x002a1ea8
  bss       = 0x002a2000-0x002b9bc0
  data      = 0x002b9bc0-0x002e4000
    stack   = 0x002e2000-0x002e4000
  init      = 0x002e4000-0x00b45000
  available = 0x00b45000-0x07f00000
  DMA Zone  = 0x07f00000-0x08000000
Hardware Trace active and enabled
Blackfin support (C) 2004-2010 Analog Devices, Inc.
Compiled for ADSP-BF609 Rev 0.0
Blackfin Linux support by http://blackfin.uclinux.org/
Processor Speed: 500 MHz core clock, 125 MHz SCLk, 125 MHz SCLK0, 125 MHz SCLK1 and 250 MHz DCLK
NOMPU: setting up cplb tables
Instruction Cache Enabled for CPU0
  External memory: cacheable in instruction cache
  L2 SRAM        : uncacheable in instruction cache
Data Cache Enabled for CPU0
  External memory: cacheable (write-back) in data cache
  L2 SRAM        : uncacheable in data cache
Built 1 zonelists in Zone order, mobility grouping off.  Total pages: 32258
Kernel command line: root=/dev/mtdblock0 rw clkin_hz=(25000000) earlyprintk=serial,uart0,57600 console=ttyBF0,57600 ip=10.99.24.159:10.99.24.86:10.99.24.1:255.255.255.0:"bf609-ezkit":eth0:off
PID hash table entries: 512 (order: -1, 2048 bytes)
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
Memory: 117340K/130048K available (2022K kernel code, 169K rwdata, 669K rodata, 8580K init, 94K bss, 12708K reserved, 1024K DMA)
NR_IRQS:291
Configuring Blackfin Priority Driven Interrupts
Console: colour dummy device 80x25
Calibrating delay loop... 995.32 BogoMIPS (lpj=1990656)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
devtmpfs: initialized
Blackfin Scratchpad data SRAM: 4 KB
Blackfin L1 Data A SRAM: 16 KB (9 KB free)
Blackfin L1 Data B SRAM: 16 KB (16 KB free)
Blackfin L1 Instruction SRAM: 64 KB (49 KB free)
Blackfin L2 SRAM: 256 KB (256 KB free)
pinctrl core: initialized pinctrl subsystem
NET: Registered protocol family 16
Blackfin DMA Controller
ezkit_init(): registering device resources
SCSI subsystem initialized
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
i2c-bfin-twi i2c-bfin-twi.0: Blackfin on-chip I2C TWI Contoller, regs_base@ffc01e00
i2c-bfin-twi i2c-bfin-twi.1: Blackfin on-chip I2C TWI Contoller, regs_base@ffc01f00
pps_core: LinuxPPS API ver. 1 registered
pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
PTP clock support registered
NET: Registered protocol family 23
Switched to clocksource bfin_cs_cycles
NET: Registered protocol family 2
TCP established hash table entries: 1024 (order: 0, 4096 bytes)
TCP bind hash table entries: 1024 (order: 0, 4096 bytes)
TCP: Hash tables configured (established 1024 bind 1024)
TCP: reno registered
UDP hash table entries: 256 (order: 0, 4096 bytes)
UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
NET: Registered protocol family 1
msgmni has been set to 229
io scheduler noop registered (default)
bfin-uart: Blackfin serial driver
bfin-uart.0: ttyBF0 at MMIO 0xffc02000 (irq = 88, base_baud = 7812500) is a BFIN-UART
console [ttyBF0] enabled
console [ttyBF0] enabled
bootconsole [early_BFuart0] disabled
bootconsole [early_BFuart0] disabled
bootconsole [early_shadow0] disabled
CAN device driver interface
bfin_can bfin_can.0: bfin_can device registered(&reg_base=ffc00a00, rx_irq=47, tx_irq=48, err_irq=49, sclk=125000000)
stmmaceth stmmaceth.0: no reset control found
stmmac - user ID: 0x10, Synopsys ID: 0x36
 Ring mode enabled
 DMA HW capability register supported
 Enhanced/Alternate descriptors
	Enabled extended descriptors
 RX Checksum Offload Engine supported (type 2)
 Wake-Up On Lan supported
 Enable RX Mitigation via HW Watchdog Timer
NULL pointer access
Kernel OOPS in progress
Deferred Exception context
CURRENT PROCESS:
COMM=modprobe PID=278  CPU=0
invalid mm
return address: [0x000531de]; contents of:
0x000531b0:  c727  acea  0c42  181d  0000  0000  0000  a0a8 
0x000531c0:  b090  acaa  0c42  1806  0000  0000  0000  a0e8 
0x000531d0:  b0d0  e801  0000  05b3  0010  e522  0046 [a090]
0x000531e0:  6408  b090  0c00  17cc  3042  e3ff  f37b  2fc8 

CPU: 0 PID: 278 Comm: modprobe Not tainted 3.15.0-ADI-2014R1-pre-00345-gea9f446 #25
task: 0572b720 ti: 0569e000 task.ti: 0569e000
Compiled for cpu family 0x27fe (Rev 0), but running on:0x0000 (Rev 0)
ADSP-BF609-0.0 500(MHz CCLK) 125(MHz SCLK) (mpu off)
Linux version 3.15.0-ADI-2014R1-pre-00345-gea9f446 (steven@steven-OptiPlex-390) (gcc version 4.3.5 (ADI-trunk/svn-5962) ) #25 Tue Jun 10 17:47:46 CST 2014

SEQUENCER STATUS:		Not tainted
 SEQSTAT: 00000027  IPEND: 8008  IMASK: ffff  SYSCFG: 2806
  EXCAUSE   : 0x27
  physical IVG3 asserted : <0xffa00744> { _trap + 0x0 }
  physical IVG15 asserted : <0xffa00d68> { _evt_system_call + 0x0 }
  logical irq   6 mapped  : <0xffa003bc> { _bfin_coretmr_interrupt + 0x0 }
  logical irq   7 mapped  : <0x00008828> { _bfin_fault_routine + 0x0 }
  logical irq  11 mapped  : <0x00007724> { _l2_ecc_err + 0x0 }
  logical irq  13 mapped  : <0x00008828> { _bfin_fault_routine + 0x0 }
  logical irq  39 mapped  : <0x00150788> { _bfin_twi_interrupt_entry + 0x0 }
  logical irq  40 mapped  : <0x00150788> { _bfin_twi_interrupt_entry + 0x0 }
 RETE: <0x00000000> /* Maybe null pointer? */
 RETN: <0x0569fe50> /* kernel dynamic memory (maybe user-space) */
 RETX: <0x00000480> /* Maybe fixed code section */
 RETS: <0x00053384> { _exit_mmap + 0x28 }
 PC  : <0x000531de> { _delete_vma_from_mm + 0x92 }
DCPLB_FAULT_ADDR: <0x00000008> /* Maybe null pointer? */
ICPLB_FAULT_ADDR: <0x000531de> { _delete_vma_from_mm + 0x92 }
PROCESSOR STATE:
 R0 : 00000004    R1 : 0569e000    R2 : 00bf3db4    R3 : 00000000
 R4 : 057f9800    R5 : 00000001    R6 : 0569ddd0    R7 : 0572b720
 P0 : 0572b854    P1 : 00000004    P2 : 00000000    P3 : 0569dda0
 P4 : 0572b720    P5 : 0566c368    FP : 0569fe5c    SP : 0569fd74
 LB0: 057f523f    LT0: 057f523e    LC0: 00000000
 LB1: 0005317c    LT1: 00053172    LC1: 00000002
 B0 : 00000000    L0 : 00000000    M0 : 0566f5bc    I0 : 00000000
 B1 : 00000000    L1 : 00000000    M1 : 00000000    I1 : ffffffff
 B2 : 00000001    L2 : 00000000    M2 : 00000000    I2 : 00000000
 B3 : 00000000    L3 : 00000000    M3 : 00000000    I3 : 057f8000
A0.w: 00000000   A0.x: 00000000   A1.w: 00000000   A1.x: 00000000
USP : 056ffcf8  ASTAT: 02003024

Hardware Trace:
   0 Target : <0x00003fb8> { _trap_c + 0x0 }
     Source : <0xffa006d8> { _exception_to_level5 + 0xa0 } JUMP.L
   1 Target : <0xffa00638> { _exception_to_level5 + 0x0 }
     Source : <0xffa004f2> { _bfin_return_from_exception + 0x6 } RTX
   2 Target : <0xffa004ec> { _bfin_return_from_exception + 0x0 }
     Source : <0xffa00590> { _ex_trap_c + 0x70 } JUMP.S
   3 Target : <0xffa00520> { _ex_trap_c + 0x0 }
     Source : <0xffa0076e> { _trap + 0x2a } JUMP (P4)
   4 Target : <0xffa00744> { _trap + 0x0 }
      FAULT : <0x000531de> { _delete_vma_from_mm + 0x92 } P0 = W[P2 + 2]
     Source : <0x000531da> { _delete_vma_from_mm + 0x8e } P2 = [P4 + 0x18]
   5 Target : <0x000531da> { _delete_vma_from_mm + 0x8e }
     Source : <0x00053176> { _delete_vma_from_mm + 0x2a } IF CC JUMP pcrel 
   6 Target : <0x0005314c> { _delete_vma_from_mm + 0x0 }
     Source : <0x00053380> { _exit_mmap + 0x24 } JUMP.L
   7 Target : <0x00053378> { _exit_mmap + 0x1c }
     Source : <0x00053394> { _exit_mmap + 0x38 } IF !CC JUMP pcrel (BP)
   8 Target : <0x00053390> { _exit_mmap + 0x34 }
     Source : <0xffa020e0> { __cond_resched + 0x20 } RTS
   9 Target : <0xffa020c0> { __cond_resched + 0x0 }
     Source : <0x0005338c> { _exit_mmap + 0x30 } JUMP.L
  10 Target : <0x0005338c> { _exit_mmap + 0x30 }
     Source : <0x0005333a> { _delete_vma + 0xb2 } RTS
  11 Target : <0x00053334> { _delete_vma + 0xac }
     Source : <0x0005507a> { _kmem_cache_free + 0xba } RTS
  12 Target : <0x00055068> { _kmem_cache_free + 0xa8 }
     Source : <0x0005505e> { _kmem_cache_free + 0x9e } IF !CC JUMP pcrel (BP)
  13 Target : <0x00055052> { _kmem_cache_free + 0x92 }
     Source : <0x0005501a> { _kmem_cache_free + 0x5a } IF CC JUMP pcrel 
  14 Target : <0x00054ff4> { _kmem_cache_free + 0x34 }
     Source : <0x00054fce> { _kmem_cache_free + 0xe } IF CC JUMP pcrel (BP)
  15 Target : <0x00054fc0> { _kmem_cache_free + 0x0 }
     Source : <0x00053330> { _delete_vma + 0xa8 } JUMP.L
Kernel Stack
Stack info:
 SP: [0x0569ff24] <0x0569ff24> /* kernel dynamic memory (maybe user-space) */
 Memory from 0x0569ff20 to 056a0000
0569ff20: 00000001 [04e8da5a] 00008000  00000000  00000000  056a0000  04e8da5a  04e8da5a 
0569ff40: 04eb9eea  ffa00dce  02003025  04ea09c5  057f523f  04ea09c4  057f523e  00000000 
0569ff60: 00000000  00000000  00000000  00000000  00000000  00000000  00000001  00000000 
0569ff80: 00000000  00000000  00000000  00000000  00000000  00000000  00000000  00000000 
0569ffa0: 0566f5bc  057f8000  057f8000  00000001  04ec0170  056ffcf8  056ffd04  057f9800 
0569ffc0: 04d1d498  057f9800  057f8fe4  057f8ef0  00000001  057f928c  00000001  00000001 
0569ffe0: 057f9800  00000000  00000008  00000007  00000001  00000001  00000001 <00002806>
Return addresses in stack:
    address : <0x00002806> { _show_cpuinfo + 0x2d2 }
Modules linked in:
Kernel panic - not syncing: Kernel exception
---[ end Kernel panic - not syncing: Kernel exception


Signed-off-by: Steven Miao <realmz6@gmail.com>
---
 mm/nommu.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index b78e3a8..4a852f6 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -786,7 +786,7 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 	for (i = 0; i < VMACACHE_SIZE; i++) {
 		/* if the vma is cached, invalidate the entire cache */
 		if (curr->vmacache[i] == vma) {
-			vmacache_invalidate(curr->mm);
+			vmacache_invalidate(mm);
 			break;
 		}
 	}
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
