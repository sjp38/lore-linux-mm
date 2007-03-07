From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070307023521.19658.80916.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 3/3] Guarantee minimum number of objects in a slab
Date: Tue,  6 Mar 2007 18:35:21 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

Guarantee a mininum number of objects per slab

The number of objects per slab is important for SLUB because it determines
the number of allocations that can be performed without having to consult
per node slab lists. Add another boot option "min_objects=xx" that
allows the configuration of the objects per slab. This is similar
to SLABS queue configurations.

Set the default of objects to 4. This will increase the page order for
certain slab objects.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc2-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-rc2-mm1.orig/mm/slub.c	2007-03-06 17:57:11.000000000 -0800
+++ linux-2.6.21-rc2-mm1/mm/slub.c	2007-03-06 17:57:15.000000000 -0800
@@ -1201,6 +1201,12 @@ static __always_inline struct page *get_
 static int slub_min_order = 0;
 
 /*
+ * Minumum number of objects per slab. This is necessary in order to
+ * reduce locking overhead. Similar to the queue size in SLAB.
+ */
+static int slub_min_objects = 4;
+
+/*
  * Merge control. If this is set then no merging of slab caches will occur.
  */
 static int slub_nomerge = 0;
@@ -1232,7 +1238,7 @@ static int calculate_order(int size)
 			order < MAX_ORDER; order++) {
 		unsigned long slab_size = PAGE_SIZE << order;
 
-		if (slab_size < size)
+		if (slab_size < slub_min_objects * size)
 			continue;
 
 		rem = slab_size % size;
@@ -1624,6 +1630,15 @@ static int __init setup_slub_min_order(c
 
 __setup("slub_min_order=", setup_slub_min_order);
 
+static int __init setup_slub_min_objects(char *str)
+{
+	get_option (&str, &slub_min_objects);
+
+	return 1;
+}
+
+__setup("slub_min_objects=", setup_slub_min_objects);
+
 static int __init setup_slub_nomerge(char *str)
 {
 	slub_nomerge = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
