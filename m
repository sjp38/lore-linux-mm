Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 04E546B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 11:43:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m12-v6so3177372wma.9
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 08:43:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w67-v6sor863295wme.53.2018.07.02.08.43.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 08:43:39 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH] mm/sparse: Make sparse_init_one_section void and remove check
Date: Mon,  2 Jul 2018 17:43:25 +0200
Message-Id: <20180702154325.12196-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: pasha.tatashin@oracle.com, mhocko@suse.com, vbabka@suse.cz, bhe@redhat.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

sparse_init_one_section() is being called from two sites:
sparse_init() and sparse_add_one_section().
The former calls it from a for_each_present_section_nr() loop,
and the latter marks the section as present before calling it.
This means that when sparse_init_one_section() gets called, we already know
that the section is present.
So there is no point to double check that in the function.

This removes the check and makes the function void.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/sparse.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index b2848cc6e32a..f55e79fda03e 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -264,19 +264,14 @@ struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pn
 	return ((struct page *)coded_mem_map) + section_nr_to_pfn(pnum);
 }
 
-static int __meminit sparse_init_one_section(struct mem_section *ms,
+static void __meminit sparse_init_one_section(struct mem_section *ms,
 		unsigned long pnum, struct page *mem_map,
 		unsigned long *pageblock_bitmap)
 {
-	if (!present_section(ms))
-		return -EINVAL;
-
 	ms->section_mem_map &= ~SECTION_MAP_MASK;
 	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
 							SECTION_HAS_MEM_MAP;
  	ms->pageblock_flags = pageblock_bitmap;
-
-	return 1;
 }
 
 unsigned long usemap_size(void)
@@ -801,12 +796,11 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 #endif
 
 	section_mark_present(ms);
-
-	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
+	sparse_init_one_section(ms, section_nr, memmap, usemap);
 
 out:
 	pgdat_resize_unlock(pgdat, &flags);
-	if (ret <= 0) {
+	if (ret < 0) {
 		kfree(usemap);
 		__kfree_section_memmap(memmap, altmap);
 	}
-- 
2.13.6
