Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: Fwd: Re: slablru for 2.5.32-mm1
Date: Mon, 2 Sep 2002 18:49:34 -0400
References: <200209021137.41132.tomlins@cam.org> <3D73C3C3.B48FE419@zip.com.au>
In-Reply-To: <3D73C3C3.B48FE419@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209021849.34481.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 2, 2002 04:02 pm, Andrew Morton wrote:
> Ed Tomlinson wrote:
> > ...
> > The pages which back slab objects may be manually marked as referenced
> > via kmem_touch_page(), which simply sets PG_referenced.  It _could_ use
> > mark_page_accessed(), but doesn't.  So slab pages will always remain on
> > the inactive list.
> >
> > --
> > Since shrinking a slab is a much lower cost operation than a swap we keep
> > the slab pages in inactive where they age faster.  Note I did test with
> > slabs following the normal active/inactive cycle - we swapped more.
> > --
>
> It worries me that we may be keeping a large number of unfreeable
> slab pages on the inactive list.  These will churn around creating
> extra work, but more significantly they will revent refill_inactive
> from bringing down really-reclaimable pages.

Well we could move some the active list.  I would suggest this only 
happen for full slabs though.  How about the following?  Note the
test for referenced in refill_inactive will always fail for slab pages
(no pte_chain).   I do not think fixing this will make much 
difference though.

On another tack.  Another reason for using a simple boolean instead of 
a threshold is that I can envision needing to do different things inside
what is now called kmem_count_page.  For instance for buffers we might
want to call try_to_release_page(page, 0) and if it works just free the slab...
For this we would need to add and pass a control var (and gfpmask) to the  
pruner callback from kmem_count_page.   The counting would then happen 
in the callback.

Patch below is lightly tested.

Ed

----------
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.534   -> 1.535  
#	         mm/vmscan.c	1.99    -> 1.100  
#	include/linux/slab.h	1.13    -> 1.14   
#	           mm/slab.c	1.31    -> 1.32   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/09/02	ed@oscar.et.ca	1.535
# Place full slabpages onto the activelist
# --------------------------------------------
#
diff -Nru a/include/linux/slab.h b/include/linux/slab.h
--- a/include/linux/slab.h	Mon Sep  2 18:46:17 2002
+++ b/include/linux/slab.h	Mon Sep  2 18:46:17 2002
@@ -63,9 +63,6 @@
 extern int kmem_count_page(struct page *, int);
 #define kmem_touch_page(addr)                 SetPageReferenced(virt_to_page(addr));
 
-/* shrink a slab */
-extern int kmem_shrink_slab(struct page *);
-
 /* dcache prune ( defined in linux/fs/dcache.c) */
 extern int age_dcache_memory(kmem_cache_t *, int, int);
 
diff -Nru a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c	Mon Sep  2 18:46:17 2002
+++ b/mm/slab.c	Mon Sep  2 18:46:17 2002
@@ -421,6 +421,9 @@
  
 /* 
  * Used by shrink_cache to determine caches that need pruning.
+ * 0 - leave on inactive list
+ * 1 - free this slab
+ * 2 - move to active list
  */
 int kmem_count_page(struct page *page, int ref)
 {
@@ -435,6 +438,15 @@
 		ret = !slabp->inuse;
 	} else 
 		ret = !ref && !slabp->inuse;
+
+	/* try to unlink the slab */
+	if (ret)
+		ret = kmem_shrink_slab(page);
+
+	/* do we want to make this slab page active? */
+	if (!ret && (cachep->num == slabp->inuse))
+		ret = 2;
+
 	spin_unlock_irq(&cachep->spinlock);
 	return ret;
 }
@@ -1083,7 +1095,7 @@
  * - shrink works and we return the pages shrunk
  * - shrink fails because the slab is in use, we return 0
  * - the page_count gets decremented by __pagevec_release_nonlru
- * called with page_lock bit set. 
+ * called with page_lock bit set and cachep->spinlock held.
  */
 int kmem_shrink_slab(struct page *page)
 {
@@ -1091,7 +1103,6 @@
 	slab_t *slabp = GET_PAGE_SLAB(page);
 	unsigned int ret = 0;
 
-	spin_lock_irq(&cachep->spinlock);
 	if (!slabp->inuse) {
 	 	if (!cachep->growing) { 
 			unsigned int i = (1<<cachep->gfporder);
@@ -1108,7 +1119,6 @@
 		BUG_ON(PageActive(page));
 	}
 out:
-	spin_unlock_irq(&cachep->spinlock);
 	return ret; 
 }
 
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Mon Sep  2 18:46:17 2002
+++ b/mm/vmscan.c	Mon Sep  2 18:46:17 2002
@@ -123,11 +123,15 @@
 		 * stop if we are done.
 		 */
 		if (PageSlab(page)) {
-			if (kmem_count_page(page, TestClearPageReferenced(page))) {
-				if (kmem_shrink_slab(page))
-					goto free_ref;
+			switch (kmem_count_page(page, TestClearPageReferenced(page))) {
+			case 0:
+				goto keep_locked;
+			case 1: 
+				goto free_ref;
+			case 2:
+				goto activate_locked;
 			}
-			goto keep_locked;
+			BUG();
 		}
 
 		may_enter_fs = (gfp_mask & __GFP_FS) ||


----------






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
