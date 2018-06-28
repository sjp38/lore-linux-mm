Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B271B6B0269
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 02:29:16 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o68-v6so4490188qte.0
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 23:29:16 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c141-v6si5818337qka.343.2018.06.27.23.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 23:29:15 -0700 (PDT)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v6 2/5] mm/sparsemem: Defer the ms->section_mem_map clearing
Date: Thu, 28 Jun 2018 14:28:54 +0800
Message-Id: <20180628062857.29658-3-bhe@redhat.com>
In-Reply-To: <20180628062857.29658-1-bhe@redhat.com>
References: <20180628062857.29658-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Baoquan He <bhe@redhat.com>

In sparse_init(), if CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y, system
will allocate one continuous memory chunk for mem maps on one node and
populate the relevant page tables to map memory section one by one. If
fail to populate for a certain mem section, print warning and its
->section_mem_map will be cleared to cancel the marking of being present.
Like this, the number of mem sections marked as present could become
less during sparse_init() execution.

Here just defer the ms->section_mem_map clearing if failed to populate
its page tables until the last for_each_present_section_nr() loop. This
is in preparation for later optimizing the mem map allocation.

Signed-off-by: Baoquan He <bhe@redhat.com>
Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/sparse-vmemmap.c |  4 ----
 mm/sparse.c         | 15 ++++++++-------
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index bd0276d5f66b..68bb65b2d34d 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -292,18 +292,14 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 	}
 
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-		struct mem_section *ms;
-
 		if (!present_section_nr(pnum))
 			continue;
 
 		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
 		if (map_map[pnum])
 			continue;
-		ms = __nr_to_section(pnum);
 		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 		       __func__);
-		ms->section_mem_map = 0;
 	}
 
 	if (vmemmap_buf_start) {
diff --git a/mm/sparse.c b/mm/sparse.c
index 6314303130b0..6a706093307d 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -441,17 +441,13 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 
 	/* fallback */
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-		struct mem_section *ms;
-
 		if (!present_section_nr(pnum))
 			continue;
 		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
 		if (map_map[pnum])
 			continue;
-		ms = __nr_to_section(pnum);
 		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 		       __func__);
-		ms->section_mem_map = 0;
 	}
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
@@ -479,7 +475,6 @@ static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 
 	pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 	       __func__);
-	ms->section_mem_map = 0;
 	return NULL;
 }
 #endif
@@ -583,17 +578,23 @@ void __init sparse_init(void)
 #endif
 
 	for_each_present_section_nr(0, pnum) {
+		struct mem_section *ms;
+		ms = __nr_to_section(pnum);
 		usemap = usemap_map[pnum];
-		if (!usemap)
+		if (!usemap) {
+			ms->section_mem_map = 0;
 			continue;
+		}
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 		map = map_map[pnum];
 #else
 		map = sparse_early_mem_map_alloc(pnum);
 #endif
-		if (!map)
+		if (!map) {
+			ms->section_mem_map = 0;
 			continue;
+		}
 
 		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
 								usemap);
-- 
2.13.6
