Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5AD6B007E
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 04:26:14 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id n3so11071441wmn.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 01:26:14 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id ei9si159024wjd.95.2016.04.05.01.26.10
        for <linux-mm@kvack.org>;
        Tue, 05 Apr 2016 01:26:13 -0700 (PDT)
From: Chen Feng <puck.chen@hisilicon.com>
Subject: [PATCH 2/2] arm64: mm: make pfn always valid with flat memory
Date: Tue, 5 Apr 2016 16:22:52 +0800
Message-ID: <1459844572-53069-2-git-send-email-puck.chen@hisilicon.com>
In-Reply-To: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, akpm@linux-foundation.org, robin.murphy@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, rientjes@google.com, linux-mm@kvack.org
Cc: puck.chen@hisilicon.com, puck.chen@foxmail.com, oliver.fu@hisilicon.com, linuxarm@huawei.com, dan.zhao@hisilicon.com, suzhuangluan@hisilicon.com, yudongbin@hislicon.com, albert.lubing@hisilicon.com, xuyiping@hisilicon.com, saberlily.xia@hisilicon.com

Make the pfn always valid when using flat memory.
If the reserved memory is not align to memblock-size,
there will be holes in zone.

This patch makes the memory in buddy always in the
array of mem-map.

Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
Signed-off-by: Fu Jun <oliver.fu@hisilicon.com>
---
 arch/arm64/mm/init.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index ea989d8..0e1d5b7 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -306,7 +306,8 @@ static void __init free_unused_memmap(void)
 	struct memblock_region *reg;
 
 	for_each_memblock(memory, reg) {
-		start = __phys_to_pfn(reg->base);
+		start = round_down(__phys_to_pfn(reg->base),
+				   MAX_ORDER_NR_PAGES);
 
 #ifdef CONFIG_SPARSEMEM
 		/*
@@ -327,8 +328,8 @@ static void __init free_unused_memmap(void)
 		 * memmap entries are valid from the bank end aligned to
 		 * MAX_ORDER_NR_PAGES.
 		 */
-		prev_end = ALIGN(__phys_to_pfn(reg->base + reg->size),
-				 MAX_ORDER_NR_PAGES);
+		prev_end = round_up(__phys_to_pfn(reg->base + reg->size),
+				    MAX_ORDER_NR_PAGES);
 	}
 
 #ifdef CONFIG_SPARSEMEM
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
