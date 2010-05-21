Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1938E6B01B4
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:19:01 -0400 (EDT)
Message-Id: <20100521211542.154300353@quilx.com>
Date: Fri, 21 May 2010 16:15:01 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC V2 SLEB 09/14] SLED: Get rid of useless function
References: <20100521211452.659982351@quilx.com>
Content-Disposition: inline; filename=sled_drop_count_free
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

count_free() == available()

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-05-20 14:40:17.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-05-20 14:40:22.000000000 -0500
@@ -1617,11 +1617,6 @@ static inline int node_match(struct kmem
 	return 1;
 }
 
-static int count_free(struct page *page)
-{
-	return available(page);
-}
-
 static unsigned long count_partial(struct kmem_cache_node *n,
 					int (*get_count)(struct page *))
 {
@@ -1670,7 +1665,7 @@ slab_out_of_memory(struct kmem_cache *s,
 		if (!n)
 			continue;
 
-		nr_free  = count_partial(n, count_free);
+		nr_free  = count_partial(n, available);
 		nr_slabs = node_nr_slabs(n);
 		nr_objs  = node_nr_objs(n);
 
@@ -3802,7 +3797,7 @@ static ssize_t show_slab_objects(struct 
 			x = atomic_long_read(&n->total_objects);
 		else if (flags & SO_OBJECTS)
 			x = atomic_long_read(&n->total_objects) -
-				count_partial(n, count_free);
+				count_partial(n, available);
 
 			else
 				x = atomic_long_read(&n->nr_slabs);
@@ -4683,7 +4678,7 @@ static int s_show(struct seq_file *m, vo
 		nr_partials += n->nr_partial;
 		nr_slabs += atomic_long_read(&n->nr_slabs);
 		nr_objs += atomic_long_read(&n->total_objects);
-		nr_free += count_partial(n, count_free);
+		nr_free += count_partial(n, available);
 	}
 
 	nr_inuse = nr_objs - nr_free;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
