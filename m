Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 47B476B005C
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 21:46:02 -0400 (EDT)
Subject: [PATCH 4/5]memhp: alloc page from other node in memory online
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain
Date: Mon, 29 Jun 2009 09:47:26 +0800
Message-Id: <1246240046.26292.20.camel@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux-foundation.org, "yakui.zhao" <yakui.zhao@intel.com>
List-ID: <linux-mm.kvack.org>

To initialize hotadded node, some pages are allocated. At that time,
the node hasn't memory, this makes the allocation always fail.
In such case, let's allocate pages from other nodes.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Signed-off-by: Yakui Zhao <yakui.zhao@intel.com>
---
 mm/page_cgroup.c    |   12 +++++++++---
 mm/sparse-vmemmap.c |    8 +++++++-
 mm/sparse.c         |    9 ++++++---
 3 files changed, 22 insertions(+), 7 deletions(-)

Index: linux/mm/page_cgroup.c
===================================================================
--- linux.orig/mm/page_cgroup.c	2009-06-26 09:55:29.000000000 +0800
+++ linux/mm/page_cgroup.c	2009-06-26 09:55:36.000000000 +0800
@@ -116,10 +116,16 @@ static int __init_refok init_section_pag
 		nid = page_to_nid(pfn_to_page(pfn));
 		table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
 		VM_BUG_ON(!slab_is_available());
-		base = kmalloc_node(table_size,
+		if (node_state(nid, N_HIGH_MEMORY)) {
+			base = kmalloc_node(table_size,
 				GFP_KERNEL | __GFP_NOWARN, nid);
-		if (!base)
-			base = vmalloc_node(table_size, nid);
+			if (!base)
+				base = vmalloc_node(table_size, nid);
+		} else {
+			base = kmalloc(table_size, GFP_KERNEL | __GFP_NOWARN);
+			if (!base)
+				base = vmalloc(table_size);
+		}
 	} else {
 		/*
  		 * We don't have to allocate page_cgroup again, but
Index: linux/mm/sparse-vmemmap.c
===================================================================
--- linux.orig/mm/sparse-vmemmap.c	2009-06-26 09:55:29.000000000 +0800
+++ linux/mm/sparse-vmemmap.c	2009-06-26 09:55:36.000000000 +0800
@@ -48,8 +48,14 @@ void * __meminit vmemmap_alloc_block(uns
 {
 	/* If the main allocator is up use that, fallback to bootmem. */
 	if (slab_is_available()) {
-		struct page *page = alloc_pages_node(node,
+		struct page *page;
+
+		if (node_state(node, N_HIGH_MEMORY))
+			page = alloc_pages_node(node,
 				GFP_KERNEL | __GFP_ZERO, get_order(size));
+		else
+			page = alloc_pages(GFP_KERNEL | __GFP_ZERO,
+				get_order(size));
 		if (page)
 			return page_address(page);
 		return NULL;
Index: linux/mm/sparse.c
===================================================================
--- linux.orig/mm/sparse.c	2009-06-26 09:55:29.000000000 +0800
+++ linux/mm/sparse.c	2009-06-26 09:55:36.000000000 +0800
@@ -62,9 +62,12 @@ static struct mem_section noinline __ini
 	unsigned long array_size = SECTIONS_PER_ROOT *
 				   sizeof(struct mem_section);
 
-	if (slab_is_available())
-		section = kmalloc_node(array_size, GFP_KERNEL, nid);
-	else
+	if (slab_is_available()) {
+		if (node_state(nid, N_HIGH_MEMORY))
+			section = kmalloc_node(array_size, GFP_KERNEL, nid);
+		else
+			section = kmalloc(array_size, GFP_KERNEL);
+	} else
 		section = alloc_bootmem_node(NODE_DATA(nid), array_size);
 
 	if (section)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
