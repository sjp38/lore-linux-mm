Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 865736B000E
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 07:19:35 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id e5-v6so2858932wro.2
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 04:19:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h63-v6sor451694wmi.13.2018.06.22.04.19.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 04:19:34 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v2 3/4] mm/memory_hotplug: Make register_mem_sect_under_node a cb of walk_memory_range
Date: Fri, 22 Jun 2018 13:18:38 +0200
Message-Id: <20180622111839.10071-4-osalvador@techadventures.net>
In-Reply-To: <20180622111839.10071-1-osalvador@techadventures.net>
References: <20180622111839.10071-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, Jonathan.Cameron@huawei.com, arbab@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

link_mem_sections() and walk_memory_range() share most of the code,
so we can use convert link_mem_sections() into a dummy function that calls
walk_memory_range() with a callback to register_mem_sect_under_node().

This patch converts register_mem_sect_under_node() in order to
match a walk_memory_range's callback, getting rid of the
check_nid argument and checking instead if the system is still
boothing, since we only have to check for the nid if the system
is in such state.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Suggested-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 drivers/base/node.c  | 44 ++++++--------------------------------------
 include/linux/node.h | 12 +++++++-----
 mm/memory_hotplug.c  |  5 +----
 3 files changed, 14 insertions(+), 47 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index a5e821d09656..845d5523812b 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -399,10 +399,9 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
 }
 
 /* register memory section under specified node if it spans that node */
-int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
-				 bool check_nid)
+int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 {
-	int ret;
+	int ret, nid = *(int *)arg;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
 
 	if (!mem_blk)
@@ -433,7 +432,7 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
 		 * case, during hotplug we know that all pages in the memory
 		 * block belong to the same node.
 		 */
-		if (check_nid) {
+		if (system_state == SYSTEM_BOOTING) {
 			page_nid = get_nid_for_pfn(pfn);
 			if (page_nid < 0)
 				continue;
@@ -490,41 +489,10 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 	return 0;
 }
 
-int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		      bool check_nid)
+int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
 {
-	unsigned long end_pfn = start_pfn + nr_pages;
-	unsigned long pfn;
-	struct memory_block *mem_blk = NULL;
-	int err = 0;
-
-	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
-		unsigned long section_nr = pfn_to_section_nr(pfn);
-		struct mem_section *mem_sect;
-		int ret;
-
-		if (!present_section_nr(section_nr))
-			continue;
-		mem_sect = __nr_to_section(section_nr);
-
-		/* same memblock ? */
-		if (mem_blk)
-			if ((section_nr >= mem_blk->start_section_nr) &&
-			    (section_nr <= mem_blk->end_section_nr))
-				continue;
-
-		mem_blk = find_memory_block_hinted(mem_sect, mem_blk);
-
-		ret = register_mem_sect_under_node(mem_blk, nid, check_nid);
-		if (!err)
-			err = ret;
-
-		/* discard ref obtained in find_memory_block() */
-	}
-
-	if (mem_blk)
-		kobject_put(&mem_blk->dev.kobj);
-	return err;
+	return walk_memory_range(start_pfn, end_pfn, (void *)&nid,
+					register_mem_sect_under_node);
 }
 
 #ifdef CONFIG_HUGETLBFS
diff --git a/include/linux/node.h b/include/linux/node.h
index 6d336e38d155..257bb3d6d014 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -33,10 +33,10 @@ typedef  void (*node_registration_func_t)(struct node *);
 
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_NUMA)
 extern int link_mem_sections(int nid, unsigned long start_pfn,
-			     unsigned long nr_pages, bool check_nid);
+			     unsigned long end_pfn);
 #else
 static inline int link_mem_sections(int nid, unsigned long start_pfn,
-				    unsigned long nr_pages, bool check_nid)
+				    unsigned long end_pfn)
 {
 	return 0;
 }
@@ -54,12 +54,14 @@ static inline int register_one_node(int nid)
 
 	if (node_online(nid)) {
 		struct pglist_data *pgdat = NODE_DATA(nid);
+		unsigned long start_pfn = pgdat->node_start_pfn;
+		unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
 
 		error = __register_one_node(nid);
 		if (error)
 			return error;
 		/* link memory sections under this node */
-		error = link_mem_sections(nid, pgdat->node_start_pfn, pgdat->node_spanned_pages, true);
+		error = link_mem_sections(nid, start_pfn, end_pfn);
 	}
 
 	return error;
@@ -69,7 +71,7 @@ extern void unregister_one_node(int nid);
 extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
-						int nid, bool check_nid);
+						void *arg);
 extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 					   unsigned long phys_index);
 
@@ -99,7 +101,7 @@ static inline int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 	return 0;
 }
 static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
-							int nid, bool check_nid)
+							void *arg)
 {
 	return 0;
 }
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e2ed64b994e5..4eb6e824a80c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1123,7 +1123,6 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	u64 start, size;
 	bool new_node = false;
 	int ret;
-	unsigned long start_pfn, nr_pages;
 
 	start = res->start;
 	size = resource_size(res);
@@ -1164,9 +1163,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	}
 
 	/* link memory sections under this node.*/
-	start_pfn = start >> PAGE_SHIFT;
-	nr_pages = size >> PAGE_SHIFT;
-	ret = link_mem_sections(nid, start_pfn, nr_pages, false);
+	ret = link_mem_sections(nid, PFN_DOWN(start), PFN_UP(start + size - 1));
 	BUG_ON(ret);
 
 	/* create new memmap entry */
-- 
2.13.6
