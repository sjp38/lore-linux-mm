Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C42C6B0029
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 22:27:17 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id b67so970606qkh.5
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 19:27:17 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f41si816707qte.268.2018.02.27.19.27.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 19:27:16 -0800 (PST)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v3 2/4] mm/sparsemem: Defer the ms->section_mem_map clearing
Date: Wed, 28 Feb 2018 11:26:55 +0800
Message-Id: <20180228032657.32385-3-bhe@redhat.com>
In-Reply-To: <20180228032657.32385-1-bhe@redhat.com>
References: <20180228032657.32385-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com
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
---
 mm/sparse-vmemmap.c |  1 -
 mm/sparse.c         | 12 ++++++++----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index bd0276d5f66b..640e68f8324b 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -303,7 +303,6 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 		ms = __nr_to_section(pnum);
 		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 		       __func__);
-		ms->section_mem_map = 0;
 	}
 
 	if (vmemmap_buf_start) {
diff --git a/mm/sparse.c b/mm/sparse.c
index 3400c1c02f7a..5769a0a79dc1 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -490,7 +490,6 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 		ms = __nr_to_section(pnum);
 		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 		       __func__);
-		ms->section_mem_map = 0;
 	}
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
@@ -518,7 +517,6 @@ static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 
 	pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 	       __func__);
-	ms->section_mem_map = 0;
 	return NULL;
 }
 #endif
@@ -622,17 +620,23 @@ void __init sparse_init(void)
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
