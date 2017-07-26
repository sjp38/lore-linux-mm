Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB136B0313
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:33:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r123so15760303wmb.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 01:33:57 -0700 (PDT)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id 9si17081414wra.123.2017.07.26.01.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 01:33:56 -0700 (PDT)
Received: by mail-wr0-f195.google.com with SMTP id o33so14071735wrb.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 01:33:56 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 5/5] mm, sparse: rename kmalloc_section_memmap, __kfree_section_memmap
Date: Wed, 26 Jul 2017 10:33:33 +0200
Message-Id: <20170726083333.17754-6-mhocko@kernel.org>
In-Reply-To: <20170726083333.17754-1-mhocko@kernel.org>
References: <20170726083333.17754-1-mhocko@kernel.org>
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
index 8460ecb9e69b..eb2e45b35a28 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -667,13 +667,13 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
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
@@ -711,13 +711,13 @@ static struct page *__kmalloc_section_memmap(void)
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
@@ -781,12 +781,12 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long st
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
 
@@ -820,7 +820,7 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long st
 	pgdat_resize_unlock(pgdat, &flags);
 	if (ret <= 0) {
 		kfree(usemap);
-		__kfree_section_memmap(memmap);
+		free_section_memmap(memmap);
 	}
 	return ret;
 }
@@ -861,7 +861,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
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
