Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C3EC66B006E
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 07:26:32 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so4354760pab.4
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 04:26:32 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id xu8si1502336pab.121.2014.12.11.04.26.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Dec 2014 04:26:31 -0800 (PST)
Date: Thu, 11 Dec 2014 04:26:10 -0800
From: tip-bot for Xishi Qiu <tipbot@zytor.com>
Message-ID: <tip-c072b90c8dfe135072f646cc50b826e30c5aa558@git.kernel.org>
Reply-To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hpa@zytor.com,
        mingo@kernel.org, dave@sr71.net, qiuxishi@huawei.com, riel@redhat.com,
        akpm@linux-foundation.org, tglx@linutronix.de
In-Reply-To: <5487AB3D.6070306@huawei.com>
References: <5487AB3D.6070306@huawei.com>
Subject: [tip:x86/urgent] x86/mm: Fix zone ranges boot printout
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: akpm@linux-foundation.org, tglx@linutronix.de, qiuxishi@huawei.com, riel@redhat.com, dave@sr71.net, mingo@kernel.org, hpa@zytor.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit-ID:  c072b90c8dfe135072f646cc50b826e30c5aa558
Gitweb:     http://git.kernel.org/tip/c072b90c8dfe135072f646cc50b826e30c5aa558
Author:     Xishi Qiu <qiuxishi@huawei.com>
AuthorDate: Wed, 10 Dec 2014 10:09:01 +0800
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Thu, 11 Dec 2014 11:35:02 +0100

x86/mm: Fix zone ranges boot printout

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

This patch fixes the printout, the following log shows the right
ranges:
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

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>
Cc: <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Link: http://lkml.kernel.org/r/5487AB3D.6070306@huawei.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
