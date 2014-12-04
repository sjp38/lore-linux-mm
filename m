Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 01C796B006C
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 02:52:55 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so2046929pdj.14
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 23:52:54 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id ck6si41866071pad.145.2014.12.03.23.52.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 23:52:53 -0800 (PST)
Message-ID: <54801228.5030405@huawei.com>
Date: Thu, 4 Dec 2014 15:50:00 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] x86, mm: fix zone ranges print in boot
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Rik van Riel <riel@redhat.com>, dave@sr71.net
Cc: the arch/x86 maintainers <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

This is the usual log without restrict memory.
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

This is the log when set "mem=2G" in cmdline.
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

This patch fix the print, the following log shows right ranges.
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
---
 arch/x86/mm/init.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

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
