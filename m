Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0B6766B01AC
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 08:51:52 -0400 (EDT)
Received: by pva4 with SMTP id 4so501716pva.14
        for <linux-mm@kvack.org>; Mon, 05 Jul 2010 05:51:50 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] slob: Get lock before getting slob_list
Date: Mon,  5 Jul 2010 20:51:37 +0800
Message-Id: <1278334297-6952-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mpm@selenic.com, hannes@cmpxchg.org, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

If get lock after getting slob_list, the partially free page list maybe
changed before list_for_each_entry().

And maybe trigger a NULL pointer access Bug like this:
==========
bio: create slab <bio-0> at 0
NULL pointer access
Kernel OOPS in progress
Deferred Exception context
CURRENT PROCESS:
COMM=swapper PID=1  CPU=0
invalid mm
return address: [0x0004442a]; contents of:
0x00044400:  0034  61f8  0040  9162  324a  6f41  a188  0854
0x00044410:  186c  0c41  1856  3228  640d  c682  8ffd  67fd
0x00044420:  6006  6f45  200b  3255  6cc2 [a1a8] 0854  1826
0x00044430:  0c45  1847  324d  3228  6f45  a908  09b8  1ff4

ADSP-BF527-0.0 525(MHz CCLK) 131(MHz SCLK) (mpu off)
Linux version 2.6.34-ADI-2010R1-pre-svn8955 (root@adam-desktop) (gcc
version 4.3.5 (ADI-trunk/svn-4637) ) #68 Mon Jul 5 11:53:28 CST 2010

SEQUENCER STATUS:               Not tainted
SEQSTAT: 00000027  IPEND: 8008  IMASK: 003f  SYSCFG: 0006
Peripheral interrupts masked off
Kernel interrupts masked off
EXCAUSE   : 0x27
physical IVG3 asserted : <0xffa00794> { _trap + 0x0 }
physical IVG15 asserted : <0xffa00fdc> { _evt_system_call + 0x0 }
logical irq   6 mapped  : <0xffa00390> { _bfin_coretmr_interrupt + 0x0
}
RETE: <0x00000000> /* Maybe null pointer? */
RETN: <0x0200bebc> /* kernel dynamic memory (maybe user-space) */
RETX: <0x00000480> /* Maybe fixed code section */
RETS: <0x00044450> { _slob_alloc + 0x6c }
PC  : <0x0004442a> { _slob_alloc + 0x46 }
DCPLB_FAULT_ADDR: <0x00000000> /* Maybe null pointer? */
ICPLB_FAULT_ADDR: <0x0004442a> { _slob_alloc + 0x46 }
PROCESSOR STATE:
 R0 : 00000000    R1 : 00081000    R2 : 0000e800    R3 : ffffe800
 R4 : 0000ffff    R5 : 00000048    R6 : 00000000    R7 : 00000024
 P0 : 0008181f    P1 : 00084000    P2 : 00000000    P3 : ffffffff
 P4 : 001efda8    P5 : ffffffe8    FP : 0200bec8    SP : 0200bde0
 LB0: ffa0165c    LT0: ffa01656    LC0: 00000000
 LB1: 000536b6    LT1: 000536a6    LC1: 00000000
 B0 : 00000000    L0 : 00000000    M0 : 00000000    I0 : 00000fff
 B1 : 00000000    L1 : 00000000    M1 : 00000000    I1 : 00000001
 B2 : 00000000    L2 : 00000000    M2 : 00000000    I2 : 00000001
 B3 : 00000000    L3 : 00000000    M3 : 00000000    I3 : ffffffe0
A0.w: 00000000   A0.x: 00000000   A1.w: 00000000   A1.x: 00000000
USP : 00000000  ASTAT: 00003025

Hardware Trace:
  0 Target : <0x00003e84> { _trap_c + 0x0 }
    Source : <0xffa00728> { _exception_to_level5 + 0xb0 } CALL pcrel
  1 Target : <0xffa00678> { _exception_to_level5 + 0x0 }
    Source : <0xffa00520> { _bfin_return_from_exception + 0x18 } RTX
  2 Target : <0xffa00508> { _bfin_return_from_exception + 0x0 }
    Source : <0xffa005c4> { _ex_trap_c + 0x74 } JUMP.S
  3 Target : <0xffa00550> { _ex_trap_c + 0x0 }
    Source : <0xffa007ee> { _trap + 0x5a } JUMP (P4)
  4 Target : <0xffa00794> { _trap + 0x0 }
     FAULT : <0x0004442a> { _slob_alloc + 0x46 } P0 = W[P5 + 6]
    Source : <0x00044428> { _slob_alloc + 0x44 } 0x6cc2
  5 Target : <0x00044426> { _slob_alloc + 0x42 }
    Source : <0x00044454> { _slob_alloc + 0x70 } IF CC JUMP pcrel (BP)
  6 Target : <0x00044450> { _slob_alloc + 0x6c }
    Source : <0x00044368> { _slob_page_alloc + 0x174 } RTS
  7 Target : <0x00044360> { _slob_page_alloc + 0x16c }
    Source : <0x0004423a> { _slob_page_alloc + 0x46 } IF CC JUMP pcrel
  8 Target : <0x0004422a> { _slob_page_alloc + 0x36 }
    Source : <0x0004428a> { _slob_page_alloc + 0x96 } JUMP.S
  9 Target : <0x00044226> { _slob_page_alloc + 0x32 }
    Source : <0x00044286> { _slob_page_alloc + 0x92 } IF !CC JUMP pcrel
(BP)
 10 Target : <0x00044248> { _slob_page_alloc + 0x54 }
    Source : <0x0004428e> { _slob_page_alloc + 0x9a } JUMP.S
 11 Target : <0x0004428c> { _slob_page_alloc + 0x98 }
    Source : <0x0004423e> { _slob_page_alloc + 0x4a } IF CC JUMP pcrel
 12 Target : <0x0004422a> { _slob_page_alloc + 0x36 }
    Source : <0x0004428a> { _slob_page_alloc + 0x96 } JUMP.S
 13 Target : <0x00044252> { _slob_page_alloc + 0x5e }
    Source : <0x00044224> { _slob_page_alloc + 0x30 } JUMP.S
 14 Target : <0x000441f4> { _slob_page_alloc + 0x0 }
    Source : <0x0004444c> { _slob_alloc + 0x68 } JUMP.L
 15 Target : <0x00044426> { _slob_alloc + 0x42 }
    Source : <0x00044454> { _slob_alloc + 0x70 } IF CC JUMP pcrel (BP)
==========

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/slob.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 3f19a34..c391f55 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -326,6 +326,8 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 	slob_t *b = NULL;
 	unsigned long flags;
 
+	spin_lock_irqsave(&slob_lock, flags);
+
 	if (size < SLOB_BREAK1)
 		slob_list = &free_slob_small;
 	else if (size < SLOB_BREAK2)
@@ -333,7 +335,6 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 	else
 		slob_list = &free_slob_large;
 
-	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
 	list_for_each_entry(sp, slob_list, list) {
 #ifdef CONFIG_NUMA
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
