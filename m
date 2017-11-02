Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3A266B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 02:33:52 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u23so4974857pgo.4
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 23:33:52 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id x5si2620372pgb.591.2017.11.01.23.33.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 23:33:51 -0700 (PDT)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH] mm: page_ext: allocate page extension though first PFN is
 invalid
Date: Thu, 02 Nov 2017 15:35:07 +0900
Message-id: <20171102063507.25671-1-jaewon31.kim@samsung.com>
References: <CGME20171102063347epcas2p2ce3e91597de3bf68e818130ea44ac769@epcas2p2.samsung.com>
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

Though the first page is not valid, page_ext could be useful for other
pages in the section. But checking all PFNs in a section may be time
consuming job. Let's check each (section count / 16) PFN, then prepare
page_ext if any PFN is present or valid. And remove the CONFIG_DEBUG_VM in
lookup_page_ext to avoid panic.

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 mm/page_ext.c | 29 ++++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 32f18911deda..bf9c99beb312 100644
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
 
@@ -312,7 +308,17 @@ static int __meminit online_page_ext(unsigned long start_pfn,
 	}
 
 	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
-		if (!pfn_present(pfn))
+		unsigned long t_pfn = pfn;
+		bool present = false;
+
+		while (t_pfn <	ALIGN(pfn + 1, PAGES_PER_SECTION)) {
+			if (pfn_present(t_pfn)) {
+				present = true;
+				break;
+			}
+			t_pfn = ALIGN(pfn + 1, PAGES_PER_SECTION >> 4);
+		}
+		if (!present)
 			continue;
 		fail = init_section_page_ext(pfn, nid);
 	}
@@ -391,8 +397,17 @@ void __init page_ext_init(void)
 		 */
 		for (pfn = start_pfn; pfn < end_pfn;
 			pfn = ALIGN(pfn + 1, PAGES_PER_SECTION)) {
-
-			if (!pfn_valid(pfn))
+			unsigned long t_pfn = pfn;
+			bool valid = false;
+
+			while (t_pfn <	ALIGN(pfn + 1, PAGES_PER_SECTION)) {
+				if (pfn_valid(t_pfn)) {
+					valid = true;
+					break;
+				}
+				t_pfn = ALIGN(pfn + 1, PAGES_PER_SECTION >> 4);
+			}
+			if (!valid)
 				continue;
 			/*
 			 * Nodes's pfns can be overlapping.
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
