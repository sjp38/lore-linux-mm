Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 303306B029A
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 04:39:52 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id j3so16205315pga.5
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 01:39:52 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id t77si791458pfa.185.2017.11.07.01.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 01:39:51 -0800 (PST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH] mm: page_ext: check if page_ext is not prepared
Date: Tue, 07 Nov 2017 18:41:31 +0900
Message-id: <20171107094131.14621-1-jaewon31.kim@samsung.com>
References: <CGME20171107093947epcas2p3d449dd14d11907cd29df7be7984d90f0@epcas2p3.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com, Jaewon Kim <jaewon31.kim@samsung.com>

online_page_ext and page_ext_init allocate page_ext for each section, but
they do not allocate if the first PFN is !pfn_present(pfn) or
!pfn_valid(pfn). Then section->page_ext remains as NULL. lookup_page_ext
checks NULL only if CONFIG_DEBUG_VM is enabled. For a valid PFN,
__set_page_owner will try to get page_ext through lookup_page_ext.
Without CONFIG_DEBUG_VM lookup_page_ext will misuse NULL pointer as value
0. This incurrs invalid address access.

This is the panic example when PFN 0x100000 is not valid but PFN 0x13FC00
is being used for page_ext. section->page_ext is NULL, get_entry returned
invalid page_ext address as 0x1DFA000 for a PFN 0x13FC00.

To avoid this panic, CONFIG_DEBUG_VM should be removed so that page_ext
will be checked at all times.

<1>[   11.618085] Unable to handle kernel paging request at virtual address 01dfa014
<1>[   11.618140] pgd = ffffffc0c6dc9000
<1>[   11.618174] [01dfa014] *pgd=0000000000000000, *pud=0000000000000000
<4>[   11.618240] ------------[ cut here ]------------
<2>[   11.618278] Kernel BUG at ffffff80082371e0 [verbose debug info unavailable]
<0>[   11.618338] Internal error: Oops: 96000045 [#1] PREEMPT SMP
<4>[   11.618381] Modules linked in:
<4>[   11.618524] task: ffffffc0c6ec9180 task.stack: ffffffc0c6f40000
<4>[   11.618569] PC is at __set_page_owner+0x48/0x78
<4>[   11.618607] LR is at __set_page_owner+0x44/0x78
<4>[   11.626025] [<ffffff80082371e0>] __set_page_owner+0x48/0x78
<4>[   11.626071] [<ffffff80081df9f0>] get_page_from_freelist+0x880/0x8e8
<4>[   11.626118] [<ffffff80081e00a4>] __alloc_pages_nodemask+0x14c/0xc48
<4>[   11.626165] [<ffffff80081e610c>] __do_page_cache_readahead+0xdc/0x264
<4>[   11.626214] [<ffffff80081d8824>] filemap_fault+0x2ac/0x550
<4>[   11.626259] [<ffffff80082e5cf8>] ext4_filemap_fault+0x3c/0x58
<4>[   11.626305] [<ffffff800820a2f8>] __do_fault+0x80/0x120
<4>[   11.626347] [<ffffff800820eb4c>] handle_mm_fault+0x704/0xbb0
<4>[   11.626393] [<ffffff800809ba70>] do_page_fault+0x2e8/0x394
<4>[   11.626437] [<ffffff8008080be4>] do_mem_abort+0x88/0x124

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 mm/page_ext.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 32f18911deda..114a4d3dcc3c 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -124,7 +124,6 @@ struct page_ext *lookup_page_ext(struct page *page)
 	struct page_ext *base;
 
 	base = NODE_DATA(page_to_nid(page))->node_page_ext;
-#if defined(CONFIG_DEBUG_VM)
 	/*
 	 * The sanity checks the page allocator does upon freeing a
 	 * page can reach here before the page_ext arrays are
@@ -133,7 +132,6 @@ struct page_ext *lookup_page_ext(struct page *page)
 	 */
 	if (unlikely(!base))
 		return NULL;
-#endif
 	index = pfn - round_down(node_start_pfn(page_to_nid(page)),
 					MAX_ORDER_NR_PAGES);
 	return get_entry(base, index);
@@ -198,7 +196,6 @@ struct page_ext *lookup_page_ext(struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
 	struct mem_section *section = __pfn_to_section(pfn);
-#if defined(CONFIG_DEBUG_VM)
 	/*
 	 * The sanity checks the page allocator does upon freeing a
 	 * page can reach here before the page_ext arrays are
@@ -207,7 +204,6 @@ struct page_ext *lookup_page_ext(struct page *page)
 	 */
 	if (!section->page_ext)
 		return NULL;
-#endif
 	return get_entry(section->page_ext, pfn);
 }
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
