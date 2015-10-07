Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A31036B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 17:29:05 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so32174909pad.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 14:29:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z5si60701879pbt.98.2015.10.07.14.29.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 14:29:04 -0700 (PDT)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCHv4] mm: Don't offset memmap for flatmem
Date: Wed,  7 Oct 2015 14:28:55 -0700
Message-Id: <1444253335-5811-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, Vlastimil Babka <vbabka@suse.cz>, Bjorn Andersson <bjorn.andersson@sonymobile.com>
Cc: Laura Abbott <laura@labbott.name>, Santosh Shilimkar <ssantosh@kernel.org>, Russell King <rmk@arm.linux.org.uk>, Kevin Hilman <khilman@linaro.org>, Arnd Bergman <arnd@arndb.de>, Stephen Boyd <sboyd@codeaurora.org>, Andy Gross <agross@codeaurora.org>, Mel Gorman <mgorman@suse.de>, Steven Rostedt <rostedt@goodmis.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <lauraa@codeaurora.org>

From: Laura Abbott <laura@labbott.name>

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

Signed-off-by: Laura Abbott <laura@labbott.name>
Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
Reported-by: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
Tested-by: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Tested-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>


---
I was reminded at Linaro Connect that I never followed up on this patch.
v3 (http://marc.info/?l=linux-mm&m=142629173021316&w=2)
was dropped due to crashing (https://lkml.org/lkml/2015/3/20/546)
The fundamentals of the patch were fine, the VM_BUG_ON I added turned out
to be incorrect. It was supposed to be a sanity check but it didn't
actually hold true in all cases (or even most cases...) v4 just drops
the sanity check. I verified that the offset is working on both ARM, x86,
and i386 QEMU with the config provided by Steven Rostedt.

Since this was minor diff from the previous patch, I kept all the previous
Acked-by/Tested-by.
---
 mm/page_alloc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40e2942..9e5ba5e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4953,6 +4953,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 {
+	unsigned long __maybe_unused offset = 0;
+
 	/* Skip empty nodes */
 	if (!pgdat->node_spanned_pages)
 		return;
@@ -4969,6 +4971,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 		 * for the buddy allocator to function correctly.
 		 */
 		start = pgdat->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
+		offset = pgdat->node_start_pfn - start;
 		end = pgdat_end_pfn(pgdat);
 		end = ALIGN(end, MAX_ORDER_NR_PAGES);
 		size =  (end - start) * sizeof(struct page);
@@ -4976,7 +4979,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 		if (!map)
 			map = memblock_virt_alloc_node_nopanic(size,
 							       pgdat->node_id);
-		pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
+		pgdat->node_mem_map = map + offset;
 	}
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 	/*
@@ -4984,9 +4987,9 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 	 */
 	if (pgdat == NODE_DATA(0)) {
 		mem_map = NODE_DATA(0)->node_mem_map;
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+#if defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) || defined(CONFIG_FLATMEM)
 		if (page_to_pfn(mem_map) != pgdat->node_start_pfn)
-			mem_map -= (pgdat->node_start_pfn - ARCH_PFN_OFFSET);
+			mem_map -= offset;
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 	}
 #endif
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
