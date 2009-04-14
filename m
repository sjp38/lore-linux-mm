Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 41AE35F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 12:46:19 -0400 (EDT)
Date: Tue, 14 Apr 2009 18:46:59 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 4/5] slqb: config slab size
Message-ID: <20090414164659.GD14873@wotan.suse.de>
References: <20090414164439.GA14873@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090414164439.GA14873@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

slqb: config slab size

Yanmin Zhang had reported performance increases in a routing stress test
with SLUB using gigantic slab sizes. The theory is either increased TLB
efficiency or reduced page allocator costs. Anyway it is trivial and
basically no overhead to add similar parameters to SLQB to experiment with.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/slqb.c
===================================================================
--- linux-2.6.orig/mm/slqb.c	2009-04-15 02:34:09.000000000 +1000
+++ linux-2.6/mm/slqb.c	2009-04-15 02:34:40.000000000 +1000
@@ -56,6 +56,17 @@ static inline void struct_slqb_page_wron
 
 #define PG_SLQB_BIT (1 << PG_slab)
 
+/*
+ * slqb_min_order: minimum allocation order for slabs
+ */
+static int slqb_min_order = 0;
+
+/*
+ * slqb_min_objects: minimum number of objects per slab. Increasing this
+ * will increase the allocation order for slabs with larger objects
+ */
+static int slqb_min_objects = 1;
+
 #ifdef CONFIG_NUMA
 static inline int slab_numa(struct kmem_cache *s)
 {
@@ -856,9 +867,25 @@ check_slabs:
 out:
 	return 1;
 }
-
 __setup("slqb_debug", setup_slqb_debug);
 
+static int __init setup_slqb_min_order(char *str)
+{
+	get_option(&str, &slqb_min_order);
+
+	return 1;
+}
+__setup("slqb_min_order=", setup_slqb_min_order);
+
+static int __init setup_slqb_min_objects(char *str)
+{
+	get_option(&str, &slqb_min_objects);
+
+	return 1;
+}
+
+__setup("slqb_min_objects=", setup_slqb_min_objects);
+
 static unsigned long kmem_cache_flags(unsigned long objsize,
 				unsigned long flags, const char *name,
 				void (*ctor)(void *))
@@ -1758,6 +1785,8 @@ static int slab_order(int size, int max_
 		order = 0;
 	else
 		order = fls(size - 1) - PAGE_SHIFT;
+	if (order < slqb_min_order)
+		order = slqb_min_order;
 
 	while (order <= max_order) {
 		unsigned long slab_size = PAGE_SIZE << order;
@@ -1766,13 +1795,23 @@ static int slab_order(int size, int max_
 
 		objects = slab_size / size;
 		if (!objects)
-			continue;
+			goto next;
+
+		if (order < MAX_ORDER && objects < slqb_min_objects) {
+			/*
+			 * if we don't have enough objects for min_objects,
+			 * then try the next size up. Unless we have reached
+			 * our maximum possible page size.
+			 */
+			goto next;
+		}
 
 		waste = slab_size - (objects * size);
 
 		if (waste * frac <= slab_size)
 			break;
 
+next:
 		order++;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
