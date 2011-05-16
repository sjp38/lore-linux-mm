Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C8425900115
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:31 -0400 (EDT)
Message-Id: <20110516202629.872677981@linux.com>
Date: Mon, 16 May 2011 15:26:20 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 15/25] slub: Avoid disabling interrupts in free slowpath
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=slab_free_without_irqoff
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Disabling interrupts can be avoided now. However, list operation still require
disabling interrupts since allocations can occur from interrupt
contexts and there is no way to perform atomic list operations. So
acquire the list lock opportunistically if there is a chance
that list operations would be needed. This may result in
needless synchronizations but allows the avoidance of synchronization
in the majority of the cases.

Dropping interrupt handling significantly simplifies the slowpath.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-16 12:45:42.741458944 -0500
+++ linux-2.6/mm/slub.c	2011-05-16 12:45:44.211458942 -0500
@@ -2182,11 +2182,10 @@ static void __slab_free(struct kmem_cach
 	struct kmem_cache_node *n = NULL;
 	unsigned long flags;
 
-	local_irq_save(flags);
 	stat(s, FREE_SLOWPATH);
 
 	if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
-		goto out_unlock;
+		return;
 
 	do {
 		prior = page->freelist;
@@ -2205,7 +2204,7 @@ static void __slab_free(struct kmem_cach
 			 * Otherwise the list_lock will synchronize with
 			 * other processors updating the list of slabs.
 			 */
-                        spin_lock(&n->list_lock);
+                        spin_lock_irqsave(&n->list_lock, flags);
 		}
 		inuse = new.inuse;
 
@@ -2221,7 +2220,7 @@ static void __slab_free(struct kmem_cach
 		 */
                 if (was_frozen)
                         stat(s, FREE_FROZEN);
-                goto out_unlock;
+                return;
         }
 
 	/*
@@ -2244,11 +2243,7 @@ static void __slab_free(struct kmem_cach
 			stat(s, FREE_ADD_PARTIAL);
 		}
 	}
-
-	spin_unlock(&n->list_lock);
-
-out_unlock:
-	local_irq_restore(flags);
+	spin_unlock_irqrestore(&n->list_lock, flags);
 	return;
 
 slab_empty:
@@ -2260,8 +2255,7 @@ slab_empty:
 		stat(s, FREE_REMOVE_PARTIAL);
 	}
 
-	spin_unlock(&n->list_lock);
-	local_irq_restore(flags);
+	spin_unlock_irqrestore(&n->list_lock, flags);
 	stat(s, FREE_SLAB);
 	discard_slab(s, page);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
