Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 203EC6B0267
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 21:45:26 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c4so5402804pfb.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 18:45:26 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id w76si31382818pfa.220.2016.12.08.18.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 18:45:25 -0800 (PST)
Subject: [PATCH v2 04/11] mm: cleanup sparse_init_one_section() return value
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 08 Dec 2016 18:41:15 -0800
Message-ID: <148125127569.13512.1723769542125375411.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148125125407.13512.1253904589564772668.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148125125407.13512.1253904589564772668.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: toshi.kani@hpe.com, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Logan Gunthorpe <logang@deltatee.com>, Vlastimil Babka <vbabka@suse.cz>

We mark and check that the section is present under a spin_lock() in
sparse_add_one_section(), so the lock ensures it will not change between
those 2 events. Also, we do not check the -EBUSY return value in
sparse_init(). Just make sparse_init_one_section() return void and clean
up the error handling.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Stephen Bates <stephen.bates@microsemi.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/sparse.c |   21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 91e1908db23d..59966a3e8ff0 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -231,19 +231,14 @@ struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pn
 	return ((struct page *)coded_mem_map) + section_nr_to_pfn(pnum);
 }
 
-static int __meminit sparse_init_one_section(struct mem_section *ms,
+static void __meminit sparse_init_one_section(struct mem_section *ms,
 		unsigned long pnum, struct page *mem_map,
 		struct mem_section_usage *usage)
 {
-	if (!present_section(ms))
-		return -EINVAL;
-
 	ms->section_mem_map &= ~SECTION_MAP_MASK;
 	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
 		SECTION_HAS_MEM_MAP;
 	ms->usage = usage;
-
-	return 1;
 }
 
 unsigned long usemap_size(void)
@@ -690,11 +685,6 @@ static void free_map_bootmem(struct page *memmap)
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
-/*
- * returns the number of sections whose mem_maps were properly
- * set.  If this is <=0, then that means that the passed-in
- * map was not consumed and must be freed.
- */
 int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
@@ -725,7 +715,7 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
 
 	ms = __pfn_to_section(start_pfn);
 	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
-		ret = -EEXIST;
+		ret = -EBUSY;
 		goto out;
 	}
 
@@ -733,15 +723,16 @@ int __meminit sparse_add_one_section(struct zone *zone, unsigned long start_pfn)
 
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
 
-	ret = sparse_init_one_section(ms, section_nr, memmap, usage);
+	sparse_init_one_section(ms, section_nr, memmap, usage);
 
 out:
 	pgdat_resize_unlock(pgdat, &flags);
-	if (ret <= 0) {
+	if (ret < 0 && ret != -EEXIST) {
 		kfree(usage);
 		__kfree_section_memmap(memmap);
+		return ret;
 	}
-	return ret;
+	return 0;
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
