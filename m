Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5ADC86B0088
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:33 -0500 (EST)
Message-Id: <20111111200730.342369714@linux.com>
Date: Fri, 11 Nov 2011 14:07:19 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 08/18] slub: enable use of deactivate_slab with interrupts on
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=allocate_slab_with_irq_enabled
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

Locking needs to change a bit because we can no longer rely on interrupts
having been disabled.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-09 11:11:42.081654804 -0600
+++ linux-2.6/mm/slub.c	2011-11-09 11:11:45.341673526 -0600
@@ -1718,6 +1718,7 @@ static void deactivate_slab(struct kmem_
 	int tail = DEACTIVATE_TO_HEAD;
 	struct page new;
 	struct page old;
+	unsigned long uninitialized_var(flags);
 
 	if (page->freelist) {
 		stat(s, DEACTIVATE_REMOTE_FREES);
@@ -1744,7 +1745,7 @@ static void deactivate_slab(struct kmem_
 			new.inuse--;
 			VM_BUG_ON(!new.frozen);
 
-		} while (!__cmpxchg_double_slab(s, page,
+		} while (!cmpxchg_double_slab(s, page,
 			prior, counters,
 			freelist, new.counters,
 			"drain percpu freelist"));
@@ -1794,7 +1795,7 @@ redo:
 			 * that acquire_slab() will see a slab page that
 			 * is frozen
 			 */
-			spin_lock(&n->list_lock);
+			spin_lock_irqsave(&n->list_lock, flags);
 		}
 	} else {
 		m = M_FULL;
@@ -1805,7 +1806,7 @@ redo:
 			 * slabs from diagnostic functions will not see
 			 * any frozen slabs.
 			 */
-			spin_lock(&n->list_lock);
+			spin_lock_irqsave(&n->list_lock, flags);
 		}
 	}
 
@@ -1833,14 +1834,14 @@ redo:
 	}
 
 	l = m;
-	if (!__cmpxchg_double_slab(s, page,
+	if (!cmpxchg_double_slab(s, page,
 				old.freelist, old.counters,
 				new.freelist, new.counters,
 				"unfreezing slab"))
 		goto redo;
 
 	if (lock)
-		spin_unlock(&n->list_lock);
+		spin_unlock_irqrestore(&n->list_lock, flags);
 
 	if (m == M_FREE) {
 		stat(s, DEACTIVATE_EMPTY);
@@ -2178,7 +2179,7 @@ static void *__slab_alloc(struct kmem_ca
 		goto new_slab;
 redo:
 
-	if (unlikely(!node_match(page, node))) {
+	if (unlikely(!node_match(page, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, page, c->freelist);
 		c->page = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
