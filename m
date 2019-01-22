Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 03AE78E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 05:37:49 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e29so9296847ede.19
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 02:37:48 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id l9-v6si1158921ejh.293.2019.01.22.02.37.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 02:37:47 -0800 (PST)
From: Oscar Salvador <osalvador@suse.de>
Subject: [RFC PATCH v2 4/4] mm, sparse: rename kmalloc_section_memmap, __kfree_section_memmap
Date: Tue, 22 Jan 2019 11:37:08 +0100
Message-Id: <20190122103708.11043-5-osalvador@suse.de>
In-Reply-To: <20190122103708.11043-1-osalvador@suse.de>
References: <20190122103708.11043-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, david@redhat.com, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Oscar Salvador <osalvador@suse.de>

From: Michal Hocko <mhocko@suse.com>

The sufix "kmalloc" is misleading.
Rename it to alloc_section_memmap/free_section_memmap which
better reflects the funcionality.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/sparse.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index dd30468dc8f5..27428b965d46 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -676,13 +676,13 @@ static void free_deferred_vmemmap_range(unsigned long start,
 	in_vmemmap_range = false;
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
@@ -732,13 +732,13 @@ static struct page *__kmalloc_section_memmap(void)
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
@@ -803,12 +803,12 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
 	ret = 0;
-	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
+	memmap = alloc_section_memmap(section_nr, nid, altmap);
 	if (!memmap)
 		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
 	if (!usemap) {
-		__kfree_section_memmap(memmap, altmap);
+		free_section_memmap(memmap, altmap);
 		return -ENOMEM;
 	}
 
@@ -830,7 +830,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 out:
 	if (ret < 0) {
 		kfree(usemap);
-		__kfree_section_memmap(memmap, altmap);
+		free_section_memmap(memmap, altmap);
 	}
 	return ret;
 }
@@ -881,7 +881,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
 		kfree(usemap);
 		if (memmap)
-			__kfree_section_memmap(memmap, altmap);
+			free_section_memmap(memmap, altmap);
 		return;
 	}
 
-- 
2.13.7
