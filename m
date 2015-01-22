Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 245D76B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 20:02:00 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id l13so21242iga.0
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 17:01:59 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id hv9si847616igb.0.2015.01.21.17.01.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jan 2015 17:01:59 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv2] mm: Don't offset memmap for flatmem
Date: Wed, 21 Jan 2015 17:01:40 -0800
Message-Id: <1421888500-24364-1-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1421804273-29947-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, linux-arm-kernel@lists.infradead.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, ssantosh@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, Kevin Hilman <khilman@linaro.org>, Arnd Bergman <arnd@arndb.de>, Stephen Boyd <sboyd@codeaurora.org>, linux-mm@kvack.org, Kumar Gala <galak@codeaurora.org>

Srinivas Kandagatla reported bad page messages when trying to
remove the bottom 2MB on an ARM based IFC6410 board

BUG: Bad page state in process swapper  pfn:fffa8
page:ef7fb500 count:0 mapcount:0 mapping:  (null) index:0x0
flags: 0x96640253(locked|error|dirty|active|arch_1|reclaim|mlocked)
page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
bad because of flags:
flags: 0x200041(locked|active|mlocked)
Modules linked in:
CPU: 0 PID: 0 Comm: swapper Not tainted 3.19.0-rc3-00007-g412f9ba-dirty #816
Hardware name: Qualcomm (Flattened Device Tree)
[<c0218280>] (unwind_backtrace) from [<c0212be8>] (show_stack+0x20/0x24)
[<c0212be8>] (show_stack) from [<c0af7124>] (dump_stack+0x80/0x9c)
[<c0af7124>] (dump_stack) from [<c0301570>] (bad_page+0xc8/0x128)
[<c0301570>] (bad_page) from [<c03018a8>] (free_pages_prepare+0x168/0x1e0)
[<c03018a8>] (free_pages_prepare) from [<c030369c>] (free_hot_cold_page+0x3c/0x174)
[<c030369c>] (free_hot_cold_page) from [<c0303828>] (__free_pages+0x54/0x58)
[<c0303828>] (__free_pages) from [<c030395c>] (free_highmem_page+0x38/0x88)
[<c030395c>] (free_highmem_page) from [<c0f62d5c>] (mem_init+0x240/0x430)
[<c0f62d5c>] (mem_init) from [<c0f5db3c>] (start_kernel+0x1e4/0x3c8)
[<c0f5db3c>] (start_kernel) from [<80208074>] (0x80208074)
Disabling lock debugging due to kernel taint

Removing the lower 2MB made the start of the lowmem zone to no longer
be page block aligned. IFC6410 uses CONFIG_FLATMEM where
alloc_node_mem_map allocates memory for the mem_map. alloc_node_mem_map
will offset for unaligned nodes with the assumption the pfn/page
translation functions will account for the offset. The functions for
CONFIG_FLATMEM do not offset however, resulting in overrunning
the memmap array. Just use the allocated memmap without any offset
when running with CONFIG_FLATMEM to avoid the overrun.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
Reported-by: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
---
 mm/page_alloc.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7633c50..269fc93 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5005,6 +5005,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 {
+	unsigned long __maybe_unused offset = 0;
+
 	/* Skip empty nodes */
 	if (!pgdat->node_spanned_pages)
 		return;
@@ -5021,6 +5023,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 		 * for the buddy allocator to function correctly.
 		 */
 		start = pgdat->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
+		offset = pgdat->node_start_pfn - start;
 		end = pgdat_end_pfn(pgdat);
 		end = ALIGN(end, MAX_ORDER_NR_PAGES);
 		size =  (end - start) * sizeof(struct page);
@@ -5028,7 +5031,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 		if (!map)
 			map = memblock_virt_alloc_node_nopanic(size,
 							       pgdat->node_id);
-		pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
+		pgdat->node_mem_map = map + offset;
 	}
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 	/*
@@ -5036,10 +5039,13 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 	 */
 	if (pgdat == NODE_DATA(0)) {
 		mem_map = NODE_DATA(0)->node_mem_map;
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-		if (page_to_pfn(mem_map) != pgdat->node_start_pfn)
-			mem_map -= (pgdat->node_start_pfn - ARCH_PFN_OFFSET);
-#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+#if defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) || defined(CONFIG_FLATMEM)
+		if (page_to_pfn(mem_map) != pgdat->node_start_pfn) {
+			if (IS_ENABLED(CONFIG_HAVE_MEMBLOCK_NODE_MAP))
+				offset = pgdat->node_start_pfn - ARCH_PFN_OFFSET;
+			mem_map -= offset;
+		}
+#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP || CONFIG_FLATMEM */
 	}
 #endif
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
