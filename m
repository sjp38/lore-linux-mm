From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070311021026.19963.48123.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311021009.19963.11893.sendpatchset@schroedinger.engr.sgi.com>
References: <20070311021009.19963.11893.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 3/3] Configurable slub_max_order
Date: Sat, 10 Mar 2007 18:10:26 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, mpm@selenic.com, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Add slub_max_order

Avoid slabs getting to large. Do no longer enforce slub_min_objects
if the slab gets bigger than slub_max_order.

I am not sure if we really want this. Maybe we should make the
selection of the base page size depending on page allocator
defrag behavior? I.e. try to restrict allocations to order 0 and order 2
so that can limit fragmentation?

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc3/mm/slub.c
===================================================================
--- linux-2.6.21-rc3.orig/mm/slub.c	2007-03-10 13:14:06.000000000 -0800
+++ linux-2.6.21-rc3/mm/slub.c	2007-03-10 13:14:11.000000000 -0800
@@ -1211,6 +1211,7 @@ static __always_inline struct page *get_
  * take the list_lock.
  */
 static int slub_min_order = 0;
+static int slub_max_order = 4;
 
 /*
  * Minimum number of objects per slab. This is necessary in order to
@@ -1249,7 +1250,11 @@ static int calculate_order(int size)
 			order < MAX_ORDER; order++) {
 		unsigned long slab_size = PAGE_SIZE << order;
 
-		if (slab_size < slub_min_objects * size)
+		if (slub_max_order > order &&
+				slab_size < slub_min_objects * size)
+			continue;
+
+		if (slab_size < size)
 			continue;
 
 		rem = slab_size % size;
@@ -1637,6 +1642,15 @@ static int __init setup_slub_min_order(c
 
 __setup("slub_min_order=", setup_slub_min_order);
 
+static int __init setup_slub_max_order(char *str)
+{
+	get_option (&str, &slub_max_order);
+
+	return 1;
+}
+
+__setup("slub_max_order=", setup_slub_max_order);
+
 static int __init setup_slub_min_objects(char *str)
 {
 	get_option (&str, &slub_min_objects);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
