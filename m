Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 090076B0547
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:41:53 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e202so15253751itc.8
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:53 -0700 (PDT)
Received: from mail-io0-f194.google.com (mail-io0-f194.google.com. [209.85.223.194])
        by mx.google.com with ESMTPS id y1si1470850ite.117.2017.08.01.05.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 05:41:52 -0700 (PDT)
Received: by mail-io0-f194.google.com with SMTP id m88so1457974iod.1
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:52 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/6] mm, sparse: rename kmalloc_section_memmap, __kfree_section_memmap
Date: Tue,  1 Aug 2017 14:41:11 +0200
Message-Id: <20170801124111.28881-7-mhocko@kernel.org>
In-Reply-To: <20170801124111.28881-1-mhocko@kernel.org>
References: <20170801124111.28881-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Both functions will use altmap rather than kmalloc for sparsemem-vmemmap
so rename them to alloc_section_memmap/free_section_memmap which better
reflect the functionality.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/sparse.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 19b9aa60f48a..be1527a37112 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -663,13 +663,13 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
 	/* This will make the necessary allocations eventually. */
 	return __sparse_mem_map_populate(pnum, nid, altmap);
 }
-static void __kfree_section_memmap(struct page *memmap)
+static void free_section_memmap(struct page *memmap)
 {
 	unsigned long start = (unsigned long)memmap;
 	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
@@ -707,13 +707,13 @@ static struct page *__kmalloc_section_memmap(void)
 	return ret;
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
 	return __kmalloc_section_memmap();
 }
 
-static void __kfree_section_memmap(struct page *memmap)
+static void free_section_memmap(struct page *memmap)
 {
 	if (is_vmalloc_addr(memmap))
 		vfree(memmap);
@@ -777,12 +777,12 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long st
 	ret = sparse_index_init(section_nr, pgdat->node_id);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, altmap);
+	memmap = alloc_section_memmap(section_nr, pgdat->node_id, altmap);
 	if (!memmap)
 		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
 	if (!usemap) {
-		__kfree_section_memmap(memmap);
+		free_section_memmap(memmap);
 		return -ENOMEM;
 	}
 
@@ -816,7 +816,7 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long st
 	pgdat_resize_unlock(pgdat, &flags);
 	if (ret <= 0) {
 		kfree(usemap);
-		__kfree_section_memmap(memmap);
+		free_section_memmap(memmap);
 	}
 	return ret;
 }
@@ -857,7 +857,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
 		kfree(usemap);
 		if (memmap)
-			__kfree_section_memmap(memmap);
+			free_section_memmap(memmap);
 		return;
 	}
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
