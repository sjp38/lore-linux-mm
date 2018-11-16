Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9CC6B08EE
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:13:16 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o9so15003556pgv.19
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 02:13:16 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id r3-v6si30123605pgr.252.2018.11.16.02.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 02:13:14 -0800 (PST)
From: Oscar Salvador <osalvador@suse.com>
Subject: [RFC PATCH 4/4] mm, sparse: rename kmalloc_section_memmap, __kfree_section_memmap
Date: Fri, 16 Nov 2018 11:12:22 +0100
Message-Id: <20181116101222.16581-5-osalvador@suse.com>
In-Reply-To: <20181116101222.16581-1-osalvador@suse.com>
References: <20181116101222.16581-1-osalvador@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, david@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Michal Hocko <mhocko@suse.com>

Both functions will use altmap rather than kmalloc for sparsemem-vmemmap
so rename them to alloc_section_memmap/free_section_memmap which better
reflect the functionality.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/sparse.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 29cbaa0e46c3..719853ef2e55 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -589,13 +589,13 @@ static void free_vmemmap_range(unsigned long limit, unsigned long start, unsigne
 	}
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
 	/* This will make the necessary allocations eventually. */
 	return sparse_mem_map_populate(pnum, nid, altmap);
 }
-static void __kfree_section_memmap(struct page *memmap,
+static void free_section_memmap(struct page *memmap,
 		struct vmem_altmap *altmap)
 {
 	unsigned long start = (unsigned long)memmap;
@@ -646,13 +646,13 @@ static struct page *__kmalloc_section_memmap(void)
 	return ret;
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
 	return __kmalloc_section_memmap();
 }
 
-static void __kfree_section_memmap(struct page *memmap,
+static void free_section_memmap(struct page *memmap,
 		struct vmem_altmap *altmap)
 {
 	if (is_vmalloc_addr(memmap))
@@ -718,12 +718,12 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
 	ret = 0;
-	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, altmap);
+	memmap = alloc_section_memmap(section_nr, pgdat->node_id, altmap);
 	if (!memmap)
 		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
 	if (!usemap) {
-		__kfree_section_memmap(memmap, altmap);
+		free_section_memmap(memmap, altmap);
 		return -ENOMEM;
 	}
 
@@ -756,7 +756,7 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 	pgdat_resize_unlock(pgdat, &flags);
 	if (ret < 0) {
 		kfree(usemap);
-		__kfree_section_memmap(memmap, altmap);
+		free_section_memmap(memmap, altmap);
 	}
 	return ret;
 }
@@ -798,7 +798,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
 		kfree(usemap);
 		if (memmap)
-			__kfree_section_memmap(memmap, altmap);
+			free_section_memmap(memmap, altmap);
 		return;
 	}
 
-- 
2.13.6
