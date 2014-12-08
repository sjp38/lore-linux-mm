Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 160FF6B0072
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 05:12:47 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so4990265pad.27
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 02:12:46 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id js5si59158681pbc.100.2014.12.08.02.12.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Dec 2014 02:12:45 -0800 (PST)
Date: Mon, 8 Dec 2014 02:12:26 -0800
From: tip-bot for Xishi Qiu <tipbot@zytor.com>
Message-ID: <tip-5f9f7a56565c3f44b0a4b2966414e09048dddcf7@git.kernel.org>
Reply-To: linux-kernel@vger.kernel.org, mingo@kernel.org, dave@sr71.net,
        qiuxishi@huawei.com, linux-mm@kvack.org, riel@redhat.com,
        hpa@zytor.com, tglx@linutronix.de
In-Reply-To: <54801228.5030405@huawei.com>
References: <54801228.5030405@huawei.com>
Subject: [tip:x86/mm] x86/mm: Fix zone ranges boot printout
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: tglx@linutronix.de, hpa@zytor.com, mingo@kernel.org, linux-kernel@vger.kernel.org, qiuxishi@huawei.com, riel@redhat.com, linux-mm@kvack.org, dave@sr71.net

Commit-ID:  5f9f7a56565c3f44b0a4b2966414e09048dddcf7
Gitweb:     http://git.kernel.org/tip/5f9f7a56565c3f44b0a4b2966414e09048dddcf7
Author:     Xishi Qiu <qiuxishi@huawei.com>
AuthorDate: Thu, 4 Dec 2014 15:50:00 +0800
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Mon, 8 Dec 2014 11:05:41 +0100

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
Cc: Linux MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: <dave@sr71.net>
Link: http://lkml.kernel.org/r/54801228.5030405@huawei.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/init.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 82b41d5..a97ee08 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -703,10 +703,10 @@ void __init zone_sizes_init(void)
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
