Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFE966B0268
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 17:11:49 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id n31so30381428qtc.2
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 14:11:49 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id k3si4478961qkd.362.2017.12.27.14.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 14:11:49 -0800 (PST)
Message-Id: <20171227220652.804369136@linux.com>
Date: Wed, 27 Dec 2017 16:06:44 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 8/8] Add debugging output
References: <20171227220636.361857279@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=debug
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

Useful to see whats going on.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/lib/xarray.c
===================================================================
--- linux.orig/lib/xarray.c
+++ linux/lib/xarray.c
@@ -1583,11 +1583,13 @@ void xa_object_migrate(struct xa_node *n
 
 	new_node = kmem_cache_alloc_node(radix_tree_node_cachep, GFP_KERNEL, numa_node);
 
+	printk(KERN_INFO "xa_object_migrate(%px, %d)\n", node, numa_node);
 	xa_lock_irq(xa);
 
 	/* Check again..... */
 	if (xa != node->array || !list_empty(&node->private_list)) {
 		node = new_node;
+		printk(KERN_ERR "Skip temporary object\n");
 		goto unlock;
 	}
 
@@ -1606,6 +1608,7 @@ void xa_object_migrate(struct xa_node *n
 	else
 		slot = &xa_parent_locked(xa, new_node)->slots[new_node->offset];
 	rcu_assign_pointer(*slot, xa_mk_node(new_node));
+	printk(KERN_ERR "Success\n");
 
 unlock:
 	xa_unlock_irq(xa);
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -4245,6 +4245,7 @@ static void kmem_cache_move(struct page
 	unsigned long flags;
 	unsigned long objects;
 
+	printk(KERN_ERR "kmem_cache_move in: page=%px inuse=%d\n", page, page->inuse);
 	local_irq_save(flags);
 	slab_lock(page);
 
@@ -4267,6 +4268,7 @@ static void kmem_cache_move(struct page
 		if (test_bit(slab_index(p, s, addr), map))
 			vector[count++] = p;
 
+	printk(KERN_ERR "Vector of %d items\n", count);
 	if (s->isolate)
 		private = s->isolate(s, vector, count);
 	else
@@ -4295,6 +4297,7 @@ static void kmem_cache_move(struct page
 	 * Perform callbacks to move the objects.
 	 */
 	s->migrate(s, vector, count, node, private);
+	printk(KERN_ERR "kmem_cache_move out: page=%px inuse=%d\n", page, page->inuse);
 }
 
 /*
@@ -4312,6 +4315,7 @@ static unsigned long __move(struct kmem_
 	LIST_HEAD(move_list);
 	struct kmem_cache_node *n = get_node(s, node);
 
+	printk(KERN_ERR "__move(%s, %d, %d, %d) migrate=%px\n", s->name, node, target_node, ratio, s->migrate);
 	if (node == target_node && n->nr_partial <= 1)
 		/*
 		 * Trying to reduce fragmentataion on a node but there is
@@ -4322,9 +4326,16 @@ static unsigned long __move(struct kmem_
 
 	spin_lock_irqsave(&n->list_lock, flags);
 	list_for_each_entry_safe(page, page2, &n->partial, lru) {
-		if (!slab_trylock(page))
+		printk(KERN_ERR "Slab page %px inuse=%d ", page, page->inuse);
+		if (page->inuse > 1000) {
+			printk("Page->inuse too high....\n");
+			break;
+		}
+		if (!slab_trylock(page)) {
+			printk("Locked\n");
 			/* Busy slab. Get out of the way */
 			continue;
+		}
 
 		if (page->inuse) {
 			if (page->inuse > ratio * page->objects / 100) {
@@ -4333,10 +4344,13 @@ static unsigned long __move(struct kmem_
 				 * Skip slab because the object density
 				 * in the slab page is high enough
 				*/
+				printk("Below ratio. Skipping\n");
 				continue;
 			}
 
 			list_move(&page->lru, &move_list);
+			printk("Added to list to move\n");
+
 			if (s->migrate) {
 				/* Remove page from being considered for allocations */
 				n->nr_partial--;
@@ -4345,6 +4359,7 @@ static unsigned long __move(struct kmem_
 			slab_unlock(page);
 		} else {
 			/* Empty slab page */
+			printk("Empty\n");
 			list_del(&page->lru);
 			n->nr_partial--;
 			slab_unlock(page);
@@ -4374,11 +4389,17 @@ static unsigned long __move(struct kmem_
 		struct page *page;
 		struct page *page2;
 
+		printk(KERN_ERR "Beginning to migrate pages\n");
 		if (scratch) {
 			/* Try to remove / move the objects left */
 			list_for_each_entry(page, &move_list, lru) {
-				if (page->inuse)
+				if (page->inuse) {
 					kmem_cache_move(page, scratch, target_node);
+					if (page->inuse > 1000) {
+						printk(KERN_ERR "Page corrupted. Abort\n");
+						break;
+					}
+				}
 			}
 			kfree(scratch);
 		}
@@ -4404,9 +4425,11 @@ static unsigned long __move(struct kmem_
 			} else {
 				slab_unlock(page);
 				discard_slab(s, page);
+				printk(KERN_ERR "Freed one page %px\n", page);
 			}
 		}
 		spin_unlock_irqrestore(&n->list_lock, flags);
+		printk(KERN_ERR "Finished migrating slab objects\n");
 	}
 out:
 	return atomic_long_read(&n->nr_slabs);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
