Date: Fri, 25 Apr 2008 12:22:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: slub: Dump list of objects not freed on kmem_cache_close()
Message-ID: <Pine.LNX.4.64.0804251221170.5971@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dump a list of unfreed objects if a slab cache is closed but
objects still remain.

[Untested (straight use of the logic from process_slab()), may conflict 
with the other patch you just committed]

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   31 ++++++++++++++++++++++++++++++-
 1 file changed, 30 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-04-24 23:17:51.719890166 -0700
+++ linux-2.6/mm/slub.c	2008-04-24 23:19:03.139899059 -0700
@@ -2418,6 +2418,32 @@ const char *kmem_cache_name(struct kmem_
 }
 EXPORT_SYMBOL(kmem_cache_name);
 
+static void list_slab_objects(struct kmem_cache *s, struct page *page,
+							const char *text)
+{
+#ifdef CONFIG_SLUB_DEBUG
+	void *addr = page_address(page);
+	void *p;
+	DECLARE_BITMAP(map, page->objects);
+
+	bitmap_zero(map, page->objects);
+	slab_err(s, page, "%s", text);
+	slab_lock(page);
+	for_each_free_object(p, s, page->freelist)
+		set_bit(slab_index(p, s, addr), map);
+
+	for_each_object(p, s, addr, page->objects) {
+
+		if (!test_bit(slab_index(p, s, addr), map)) {
+			printk(KERN_ERR "INFO: Object 0x%p @offset=%tu\n",
+							p, p - addr);
+			print_tracking(s, p);
+		}
+	}
+	slab_unlock(page);
+#endif
+}
+
 /*
  * Attempt to free all slabs on a node. Return the number of slabs we
  * were unable to free.
@@ -2434,8 +2460,11 @@ static int free_list(struct kmem_cache *
 		if (!page->inuse) {
 			list_del(&page->lru);
 			discard_slab(s, page);
-		} else
+		} else {
 			slabs_inuse++;
+			list_slab_objects(s, page,
+				"Objects remaining on kmem_cache_close()");
+		}
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	return slabs_inuse;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
