Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E313F6B02D0
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 17:11:15 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f5so72933600pgi.1
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 14:11:15 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w10si4743979pgc.131.2017.01.19.14.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 14:11:15 -0800 (PST)
Subject: [PATCH v3 05/12] mm: cleanup sparse_init_one_section() return value
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 19 Jan 2017 14:07:08 -0800
Message-ID: <148486362851.19694.4580553117827074003.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148486359570.19694.18265063120757801811.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148486359570.19694.18265063120757801811.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, linux-nvdimm@lists.01.org, Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

We mark and check that the section is present under a spin_lock() in
sparse_add_one_section(), so the lock ensures it will not change between
those 2 events. Also, we do not check the -EBUSY return value in
sparse_init(). Just make sparse_init_one_section() return void and clean
up the error handling.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
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
