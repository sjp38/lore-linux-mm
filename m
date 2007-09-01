From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 26/26] SLUB: Add debugging for slab defrag
Date: Fri, 31 Aug 2007 18:41:33 -0700
Message-ID: <20070901014225.281378701@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0026-debug.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Add some debugging printks for slab defragmentation

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-08-28 20:11:34.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-08-28 20:21:39.000000000 -0700
@@ -2697,8 +2697,10 @@ int kmem_cache_isolate_slab(struct page 
 	 * This is necessary to make sure that the page does not vanish
 	 * from under us before we are able to check the result.
 	 */
-	if (!get_page_unless_zero(page))
+	if (!get_page_unless_zero(page)) {
+		printk(KERN_ERR "isolate %p zero ref\n", page);
 		return rc;
+	}
 
 	local_irq_save(flags);
 	slab_lock(page);
@@ -2712,6 +2714,8 @@ int kmem_cache_isolate_slab(struct page 
 	if (!PageSlab(page) || SlabFrozen(page) || !page->inuse) {
 		slab_unlock(page);
 		put_page(page);
+		printk(KERN_ERR "isolate faillock %p flags=%lx %s\n",
+			page, page->flags, PageSlab(page)?page->slab->name:"--");
 		goto out;
 	}
 
@@ -2739,6 +2743,7 @@ int kmem_cache_isolate_slab(struct page 
 	SetSlabFrozen(page);
 	slab_unlock(page);
 	rc = 0;
+	printk(KERN_ERR "Isolated %s slab=%p objects=%d\n", s->name, page, page->inuse);
 out:
 	local_irq_restore(flags);
 	return rc;
@@ -2809,6 +2814,8 @@ static int kmem_cache_vacate(struct page
 	 */
 	if (page->inuse == objects)
 		ClearSlabReclaimable(page);
+	printk(KERN_ERR "Finish vacate %s slab=%p objects=%d->%d\n",
+		s->name, page, objects, page->inuse);
 out:
 	leftover = page->inuse;
 	unfreeze_slab(s, page, tail);
@@ -2826,6 +2833,7 @@ int kmem_cache_reclaim(struct list_head 
 	void **scratch;
 	struct page *page;
 	struct page *page2;
+	int pages = 0;
 
 	if (list_empty(zaplist))
 		return 0;
@@ -2836,10 +2844,13 @@ int kmem_cache_reclaim(struct list_head 
 
 	list_for_each_entry_safe(page, page2, zaplist, lru) {
 		list_del(&page->lru);
+		pages++;
 		if (kmem_cache_vacate(page, scratch) == 0)
 				freed++;
 	}
 	kfree(scratch);
+	printk(KERN_ERR "kmem_cache_reclaim recovered %d of %d slabs.\n",
+			freed, pages);
 	return freed;
 }
 

-- 
