Date: Mon, 6 Mar 2006 19:20:11 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Fix drain_array() so that it works correctly with the shared_array
Message-ID: <Pine.LNX.4.64.0603061916110.28448@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The list_lock also protects the shared array and we call drain_array()
with the shared array. Therefore we cannot go as far as I wanted to
but have to take the lock in a way so that it also protects the 
array_cache in drain_pages.

(Note: maybe we should make the array_cache locking more consistent? I.e.
always take the array cache lock for shared arrays and disable interrupts
for the per cpu arrays?)

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc5-mm2/mm/slab.c
===================================================================
--- linux-2.6.16-rc5-mm2.orig/mm/slab.c	2006-03-06 17:41:06.000000000 -0800
+++ linux-2.6.16-rc5-mm2/mm/slab.c	2006-03-06 19:15:08.000000000 -0800
@@ -3554,7 +3554,8 @@ static void enable_cpucache(struct kmem_
 
 /*
  * Drain an array if it contains any elements taking the l3 lock only if
- * necessary.
+ * necessary. Note that the l3 listlock also protects the array_cache
+ * if drain_array() is used on the shared array.
  */
 void drain_array(struct kmem_cache *cachep, struct kmem_list3 *l3,
 			 struct array_cache *ac, int force, int node)
@@ -3566,16 +3567,18 @@ void drain_array(struct kmem_cache *cach
 
 	if (ac->touched && !force) {
 		ac->touched = 0;
-	} else if (ac->avail) {
-		tofree = force ? ac->avail : (ac->limit + 4) / 5;
-		if (tofree > ac->avail)
-			tofree = (ac->avail + 1) / 2;
+	} else {
 		spin_lock_irq(&l3->list_lock);
-		free_block(cachep, ac->entry, tofree, node);
+		if (ac->avail) {
+			tofree = force ? ac->avail : (ac->limit + 4) / 5;
+			if (tofree > ac->avail)
+				tofree = (ac->avail + 1) / 2;
+			free_block(cachep, ac->entry, tofree, node);
+			ac->avail -= tofree;
+			memmove(ac->entry, &(ac->entry[tofree]),
+				sizeof(void *) * ac->avail);
+		}
 		spin_unlock_irq(&l3->list_lock);
-		ac->avail -= tofree;
-		memmove(ac->entry, &(ac->entry[tofree]),
-			sizeof(void *) * ac->avail);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
