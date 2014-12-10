Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id DAAAD6B0038
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 21:11:58 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so1771266pdi.3
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 18:11:58 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id fu6si4390845pdb.178.2014.12.09.18.11.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 18:11:57 -0800 (PST)
Message-ID: <5487AB3D.6070306@huawei.com>
Date: Wed, 10 Dec 2014 10:09:01 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V3 1/2] x86/mm: fix zone ranges boot printout
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, dave@sr71.net, Rik van Riel <riel@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-tip-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>

This is the usual physical memory layout boot printout:
...
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0xc3fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x00099fff]
[    0.000000]   node   0: [mem 0x00100000-0xbf78ffff]
[    0.000000]   node   0: [mem 0x100000000-0x63fffffff]
[    0.000000]   node   1: [mem 0x640000000-0xc3fffffff]
...

This is the log when we set "mem=2G" on the boot cmdline:
...
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]  // should be 0x7fffffff, right?
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x00099fff]
[    0.000000]   node   0: [mem 0x00100000-0x7fffffff]
...

This patch fixes the printout, the following log shows the right ranges:
...
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0x7fffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x00099fff]
[    0.000000]   node   0: [mem 0x00100000-0x7fffffff]
...

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
---
 arch/x86/include/asm/dma.h | 2 +-
 arch/x86/mm/init.c         | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/dma.h b/arch/x86/include/asm/dma.h
index 0bdb0c5..fe884e1 100644
--- a/arch/x86/include/asm/dma.h
+++ b/arch/x86/include/asm/dma.h
@@ -70,7 +70,7 @@
 #define MAX_DMA_CHANNELS	8
 
 /* 16MB ISA DMA zone */
-#define MAX_DMA_PFN   ((16 * 1024 * 1024) >> PAGE_SHIFT)
+#define MAX_DMA_PFN   ((16UL * 1024 * 1024) >> PAGE_SHIFT)
 
 /* 4GB broken PCI/AGP hardware bus master zone */
 #define MAX_DMA32_PFN ((4UL * 1024 * 1024 * 1024) >> PAGE_SHIFT)
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 66dba36..07244aa 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -674,10 +674,10 @@ void __init zone_sizes_init(void)
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
 
 #ifdef CONFIG_ZONE_DMA
-	max_zone_pfns[ZONE_DMA]		= MAX_DMA_PFN;
+	max_zone_pfns[ZONE_DMA]		= min(MAX_DMA_PFN, max_low_pfn);
 #endif
 #ifdef CONFIG_ZONE_DMA32
-	max_zone_pfns[ZONE_DMA32]	= MAX_DMA32_PFN;
+	max_zone_pfns[ZONE_DMA32]	= min(MAX_DMA32_PFN, max_low_pfn);
 #endif
 	max_zone_pfns[ZONE_NORMAL]	= max_low_pfn;
 #ifdef CONFIG_HIGHMEM
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
