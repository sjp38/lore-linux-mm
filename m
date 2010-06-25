Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AE5E36B01B9
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 17:24:31 -0400 (EDT)
Message-Id: <20100625212109.277669370@quilx.com>
Date: Fri, 25 Jun 2010 16:20:40 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q 14/16] SLUB: Get rid of useless function count_free()
References: <20100625212026.810557229@quilx.com>
Content-Disposition: inline; filename=sled_drop_count_free
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

count_free() == available()

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

Index: linux-2.6.34/mm/slub.c
===================================================================
--- linux-2.6.34.orig/mm/slub.c	2010-06-23 10:24:15.000000000 -0500
+++ linux-2.6.34/mm/slub.c	2010-06-23 10:24:16.000000000 -0500
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
 
@@ -3805,7 +3800,7 @@ static ssize_t show_slab_objects(struct 
 			x = atomic_long_read(&n->total_objects);
 		else if (flags & SO_OBJECTS)
 			x = atomic_long_read(&n->total_objects) -
-				count_partial(n, count_free);
+				count_partial(n, available);
 
 			else
 				x = atomic_long_read(&n->nr_slabs);
@@ -4694,7 +4689,7 @@ static int s_show(struct seq_file *m, vo
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
