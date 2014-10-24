Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C36CC6B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 05:02:13 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so1113792pdj.27
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 02:02:13 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id fr3si3764160pbd.34.2014.10.24.02.02.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 24 Oct 2014 02:02:12 -0700 (PDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NDX00ESBYFMCX70@mailout1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Oct 2014 18:02:10 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] x86, cma: reserve dma contiguous area after initmem_init()
Date: Fri, 24 Oct 2014 17:00:34 +0800
Message-id: <000101cfef69$31e528a0$95af79e0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org
Cc: tglx@linutronix.de, hpa@zytor.com, fengguang.wu@intel.com, m.szyprowski@samsung.com, mina86@mina86.com, iamjoonsoo.kim@lge.com, 'Andrew Morton' <akpm@linux-foundation.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

Fengguang Wu reported a BUG: Int 6: CR2 (null) on x86 platform in
0-day Linux Kernel Performance Test:

[    0.000000] BRK [0x025ee000, 0x025eefff] PGTABLE
[    0.000000] cma: dma_contiguous_reserve(limit 13ffe000)
[    0.000000] cma: dma_contiguous_reserve: reserving 31 MiB for global area
[    0.000000] BUG: Int 6: CR2   (null)
[    0.000000]      EDI c0000000  ESI   (null)  EBP 41c11ea4  EBX 425cc101
[    0.000000]      ESP 41c11e98   ES 0000007b   DS 0000007b
[    0.000000]      EDX 00000001  ECX   (null)  EAX 41cd8150
[    0.000000]      vec 00000006  err   (null)  EIP 41072227   CS 00000060  flg 00210002
[    0.000000] Stack: 425cc150   (null)   (null) 41c11ef4 41d4ee4d   (null) 13ffe000 41c11ec4
[    0.000000]        41c2d900   (null) 13ffe000   (null) 4185793e 0000002e 410c2982 41c11f00
[    0.000000]        410c2df5   (null)   (null)   (null) 425cc150 00013efe   (null) 41c11f28
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.17.0-next-20141008 #815
[    0.000000]  00000000 425cc101 41c11e48 41850786 41c11ea4 41d2b1db 41d95f71 00000006
[    0.000000]  00000000 c0000000 00000000 41c11ea4 425cc101 41c11e98 0000007b 0000007b
[    0.000000]  00000001 00000000 41cd8150 00000006 00000000 41072227 00000060 00210002
[    0.000000] Call Trace:
[    0.000000]  [<41850786>] dump_stack+0x16/0x18
[    0.000000]  [<41d2b1db>] early_idt_handler+0x6b/0x6b
[    0.000000]  [<41072227>] ? __phys_addr+0x2e/0xca
[    0.000000]  [<41d4ee4d>] cma_declare_contiguous+0x3c/0x2d7
[    0.000000]  [<4185793e>] ? _raw_spin_unlock_irqrestore+0x59/0x91
[    0.000000]  [<410c2982>] ? wake_up_klogd+0x8/0x33
[    0.000000]  [<410c2df5>] ? console_unlock+0x448/0x461
[    0.000000]  [<41d6d359>] dma_contiguous_reserve_area+0x27/0x47
[    0.000000]  [<41d6d4d1>] dma_contiguous_reserve+0x158/0x163
[    0.000000]  [<41d33e0f>] setup_arch+0x79b/0xc68
[    0.000000]  [<4184c0b4>] ? printk+0x1c/0x1e
[    0.000000]  [<41d2b7cf>] start_kernel+0x9c/0x456
[    0.000000]  [<41d2b2ca>] i386_start_kernel+0x79/0x7d

see detail: https://lkml.org/lkml/2014/10/8/708

It is because dma_contiguous_reserve() is called before initmem_init() in x86,
the variable high_memory is not initialized but accessed by __pa(high_memory)
in dma_contiguous_reserve().

This patch moves dma_contiguous_reserve() after initmem_init() so that
high_memory is initialized before accessed.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 arch/x86/kernel/setup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 235cfd3..ab08aa2 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1128,7 +1128,6 @@ void __init setup_arch(char **cmdline_p)
 	setup_real_mode();
 
 	memblock_set_current_limit(get_max_mapped());
-	dma_contiguous_reserve(max_pfn_mapped << PAGE_SHIFT);
 
 	/*
 	 * NOTE: On x86-32, only from this point on, fixmaps are ready for use.
@@ -1159,6 +1158,7 @@ void __init setup_arch(char **cmdline_p)
 	early_acpi_boot_init();
 
 	initmem_init();
+	dma_contiguous_reserve(max_pfn_mapped << PAGE_SHIFT);
 
 	/*
 	 * Reserve memory for crash kernel after SRAT is parsed so that it
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
