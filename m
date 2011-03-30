Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 285718D004C
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:24:28 -0400 (EDT)
Message-Id: <20110330202425.248941090@linux.com>
Date: Wed, 30 Mar 2011 15:23:58 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubll1 16/19] slub: Avoid disabling interrupts in free slowpath
References: <20110330202342.669400887@linux.com>
Content-Disposition: inline; filename=slab_free_without_irqoff
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

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
 mm/slub.c |   23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-03-30 14:43:44.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-03-30 14:43:51.000000000 -0500
@@ -2209,13 +2209,11 @@ static void __slab_free(struct kmem_cach
 	struct kmem_cache_node *n = NULL;
 #ifdef CONFIG_CMPXCHG_LOCAL
 	unsigned long flags;
-
-	local_irq_save(flags);
 #endif
 	stat(s, FREE_SLOWPATH);
 
 	if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
-		goto out_unlock;
+		return;
 
 	do {
 		prior = page->freelist;
@@ -2234,7 +2232,11 @@ static void __slab_free(struct kmem_cach
 			 * Otherwise the list_lock will synchronize with
 			 * other processors updating the list of slabs.
 			 */
+#ifdef CONFIG_CMPXCHG_LOCAL
+                        spin_lock_irqsave(&n->list_lock, flags);
+#else
                         spin_lock(&n->list_lock);
+#endif
 		}
 		inuse = new.inuse;
 
@@ -2250,7 +2252,7 @@ static void __slab_free(struct kmem_cach
 		 */
                 if (was_frozen)
                         stat(s, FREE_FROZEN);
-                goto out_unlock;
+                return;
         }
 
 	/*
@@ -2273,12 +2275,10 @@ static void __slab_free(struct kmem_cach
 			stat(s, FREE_ADD_PARTIAL);
 		}
 	}
-
-	spin_unlock(&n->list_lock);
-
-out_unlock:
 #ifdef CONFIG_CMPXCHG_LOCAL
-	local_irq_restore(flags);
+	spin_unlock_irqrestore(&n->list_lock, flags);
+#else
+	spin_unlock(&n->list_lock);
 #endif
 	return;
 
@@ -2291,9 +2291,10 @@ slab_empty:
 		stat(s, FREE_REMOVE_PARTIAL);
 	}
 
-	spin_unlock(&n->list_lock);
 #ifdef CONFIG_CMPXCHG_LOCAL
-	local_irq_restore(flags);
+	spin_unlock_irqrestore(&n->list_lock, flags);
+#else
+	spin_unlock(&n->list_lock);
 #endif
 	stat(s, FREE_SLAB);
 	discard_slab(s, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
