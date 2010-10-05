Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F02056B0071
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:00:16 -0400 (EDT)
Message-Id: <20101005185820.497596028@linux.com>
Date: Tue, 05 Oct 2010 13:57:40 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 15/16] slub: Detailed reports on validate
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=unified_detail_object_reports
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Provide some more detail on what is going on with various types of object
in slabs. This is mainly useful for debugging the queueing operations.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   86 +++++++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 74 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-05 13:40:08.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-05 13:40:11.000000000 -0500
@@ -4151,12 +4151,24 @@ static int count_total(struct page *page
 #endif
 
 #ifdef CONFIG_SLUB_DEBUG
-static int validate_slab(struct kmem_cache *s, struct page *page)
+
+struct validate_counters {
+	int objects;
+	int available;
+	int queue;
+	int checked;
+	int unchecked;
+	int hist[];
+};
+
+static int validate_slab(struct kmem_cache *s, struct page *page,
+		int partial, struct validate_counters *v)
 {
 	void *p;
 	void *addr = page_address(page);
 	unsigned long *m = map(page);
 	unsigned long errors = 0;
+	unsigned long inuse = 0;
 
 	if (!check_slab(s, page) || !verify_slab(s, page))
 		return 0;
@@ -4168,7 +4180,10 @@ static int validate_slab(struct kmem_cac
 			/* Available */
 			if (!check_object(s, page, p, SLUB_RED_INACTIVE))
 				errors++;
+			else
+				v->available++;
 		} else {
+			inuse++;
 #ifdef CONFIG_SLUB_DEBUG
 			/*
 			 * We cannot check if the object is on a queue without
@@ -4178,24 +4193,45 @@ static int validate_slab(struct kmem_cac
 			if (s->flags & SLAB_RED_ZONE) {
 				u8 *q = p + s->objsize;
 
-				if (*q != SLUB_RED_QUEUE)
+				if (*q != SLUB_RED_QUEUE) {
 					if (!check_object(s, page, p, SLUB_RED_ACTIVE))
 						errors++;
-			}
+					else
+						v->checked++;
+				} else
+					v->queue++;
+			} else
+				/*
+				 * Allocated object that cannot be verified
+				 * since red zoning is diabled. The object
+				 * may be free after all if its on a queue.
+				 */
 #endif
+				v->unchecked++;
 		}
 	}
 
+	v->hist[inuse]++;
+
+	if (inuse < page->objects) {
+		if (!partial)
+			slab_err(s, page, "Objects available but not on partial list");
+	} else {
+		if (partial)
+			slab_err(s, page, "On partial list but no object available");
+	}
+	v->objects += page->objects;
 	return errors;
 }
 
-static unsigned long validate_slab_slab(struct kmem_cache *s, struct page *page)
+static unsigned long validate_slab_slab(struct kmem_cache *s,
+	struct page *page, int partial, struct validate_counters *v)
 {
-	return validate_slab(s, page);
+	return validate_slab(s, page, partial, v);
 }
 
 static int validate_slab_node(struct kmem_cache *s,
-		struct kmem_cache_node *n)
+	struct kmem_cache_node *n, struct validate_counters *v)
 {
 	unsigned long count = 0;
 	struct page *page;
@@ -4206,7 +4242,7 @@ static int validate_slab_node(struct kme
 
 	list_for_each_entry(page, &n->partial, lru) {
 		if (get_node(s, page_to_nid(page)) == n)
-			errors += validate_slab_slab(s, page);
+			errors += validate_slab_slab(s, page, 1, v);
 		else
 			printk(KERN_ERR "SLUB %s: Partial list page from wrong node\n", s->name);
 		count++;
@@ -4219,7 +4255,7 @@ static int validate_slab_node(struct kme
 		goto out;
 
 	list_for_each_entry(page, &n->full, lru) {
-		validate_slab_slab(s, page);
+		errors += validate_slab_slab(s, page, 0, v);
 		count++;
 	}
 	if (count != atomic_long_read(&n->nr_slabs))
@@ -4235,15 +4271,41 @@ out:
 static long validate_slab_cache(struct kmem_cache *s)
 {
 	int node;
-	unsigned long count = 0;
+	int i;
+	struct validate_counters *v;
+	unsigned long errors = 0;
+	int maxobj = oo_objects(s->max);
+
+	v = kzalloc(GFP_KERNEL, offsetof(struct validate_counters, hist) + maxobj * sizeof(int));
+	if (!v)
+		return -ENOMEM;
 
-	flush_all(s);
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
-		count += validate_slab_node(s, n);
+		errors += validate_slab_node(s, n, v);
 	}
-	return count;
+
+	printk(KERN_DEBUG "Validation of slab %s: total=%d available=%d checked=%d",
+			s->name, v->objects, v->available, v->checked);
+
+	if (v->unchecked)
+		printk(" unchecked=%d", v->unchecked);
+
+	if (v->queue)
+		printk(" onqueue=%d", v->queue);
+
+	if (errors)
+		printk(" errors=%lu", errors);
+
+	for (i = 0; i < maxobj; i++)
+		if (v->hist[i])
+			printk(" p<%d>=%d", i, v->hist[i]);
+
+	printk("\n");
+	kfree(v);
+
+	return errors;
 }
 /*
  * Generate lists of code addresses where slabcache objects are allocated

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
