Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4436B0006
	for <linux-mm@kvack.org>; Mon, 28 May 2018 03:53:16 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w8-v6so9848189wrn.10
        for <linux-mm@kvack.org>; Mon, 28 May 2018 00:53:16 -0700 (PDT)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id y25-v6si6281013wrd.203.2018.05.28.00.53.14
        for <linux-mm@kvack.org>;
        Mon, 28 May 2018 00:53:14 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [RFC PATCH 3/3] mm/memory_hotplug: Get rid of link_mem_sections
Date: Mon, 28 May 2018 09:52:37 +0200
Message-Id: <20180528075237.18105-4-osalvador@techadventures.net>
In-Reply-To: <20180528075237.18105-1-osalvador@techadventures.net>
References: <20180528075237.18105-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, akpm@linux-foundation.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

link_mem_sections() and walk_memory_range() share most of the code,
so we can use walk_memory_range() with a callback to register_mem_sect_under_node()
instead of using link_mem_sections().

To control whether the node id must be check, two new functions has been added:

register_mem_sect_under_node_nocheck_node()
and
register_mem_sect_under_node_check_node()

They both call register_mem_sect_under_node_check() with
the parameter check_nid set to true or false.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 drivers/base/node.c  | 47 ++++++++++-------------------------------------
 include/linux/node.h | 21 +++++++++------------
 mm/memory_hotplug.c  |  8 ++++----
 3 files changed, 23 insertions(+), 53 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index a5e821d09656..248c712e8de5 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -398,6 +398,16 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
 	return pfn_to_nid(pfn);
 }
 
+int register_mem_sect_under_node_check_node(struct memory_block *mem_blk, void *nid)
+{
+	return register_mem_sect_under_node (mem_blk, *(int *)nid, true);
+}
+
+int register_mem_sect_under_node_nocheck_node(struct memory_block *mem_blk, void *nid)
+{
+	return register_mem_sect_under_node (mem_blk, *(int *)nid, false);
+}
+
 /* register memory section under specified node if it spans that node */
 int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
 				 bool check_nid)
@@ -490,43 +500,6 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 	return 0;
 }
 
-int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		      bool check_nid)
-{
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
-}
-
 #ifdef CONFIG_HUGETLBFS
 /*
  * Handle per node hstate attribute [un]registration on transistions
diff --git a/include/linux/node.h b/include/linux/node.h
index 6d336e38d155..1158bea9be52 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -31,19 +31,11 @@ struct memory_block;
 extern struct node *node_devices[];
 typedef  void (*node_registration_func_t)(struct node *);
 
-#if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_NUMA)
-extern int link_mem_sections(int nid, unsigned long start_pfn,
-			     unsigned long nr_pages, bool check_nid);
-#else
-static inline int link_mem_sections(int nid, unsigned long start_pfn,
-				    unsigned long nr_pages, bool check_nid)
-{
-	return 0;
-}
-#endif
-
 extern void unregister_node(struct node *node);
 #ifdef CONFIG_NUMA
+#if defined(CONFIG_MEMORY_HOTPLUG_SPARSE)
+extern int register_mem_sect_under_node_check_node(struct memory_block *mem_blk, void *nid);
+#endif
 /* Core of the node registration - only memory hotplug should use this */
 extern int __register_one_node(int nid);
 
@@ -54,12 +46,17 @@ static inline int register_one_node(int nid)
 
 	if (node_online(nid)) {
 		struct pglist_data *pgdat = NODE_DATA(nid);
+		unsigned long start = pgdat->node_start_pfn;
+		unsigned long size = pgdat->node_spanned_pages;
 
 		error = __register_one_node(nid);
 		if (error)
 			return error;
 		/* link memory sections under this node */
-		error = link_mem_sections(nid, pgdat->node_start_pfn, pgdat->node_spanned_pages, true);
+#if defined(CONFIG_MEMORY_HOTPLUG_SPARSE)
+		error = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1),
+					(void *)&nid, register_mem_sect_under_node_check_node);
+#endif
 	}
 
 	return error;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f84ef96175ab..ac21dc506b84 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -40,6 +40,8 @@
 
 #include "internal.h"
 
+extern int register_mem_sect_under_node_nocheck_node(struct memory_block *mem_blk, void *nid);
+
 /*
  * online_page_callback contains pointer to current page onlining function.
  * Initially it is generic_online_page(). If it is required it could be
@@ -1118,7 +1120,6 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	u64 start, size;
 	bool new_node;
 	int ret;
-	unsigned long start_pfn, nr_pages;
 
 	start = res->start;
 	size = resource_size(res);
@@ -1157,9 +1158,8 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	}
 
 	/* link memory sections under this node.*/
-	start_pfn = start >> PAGE_SHIFT;
-	nr_pages = size >> PAGE_SHIFT;
-	ret = link_mem_sections(nid, start_pfn, nr_pages, false);
+	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1),
+				(void *)&nid, register_mem_sect_under_node_nocheck_node);
 	if (ret)
 		goto register_fail;
 
-- 
2.13.6
