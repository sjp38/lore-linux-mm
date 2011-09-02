Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 96683900146
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:46 -0400 (EDT)
Message-Id: <20110902204743.792073929@linux.com>
Date: Fri, 02 Sep 2011 15:47:05 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 08/12] slub: enable use of deactivate_slab with interrupts on
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=allocate_slab_with_irq_enabled
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

Locking needs to change a bit.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-09-02 08:21:28.931219055 -0500
+++ linux-2.6/mm/slub.c	2011-09-02 08:22:38.141218609 -0500
@@ -1781,6 +1781,7 @@ static void deactivate_slab(struct kmem_
 	int tail = 0;
 	struct page new;
 	struct page old;
+	unsigned long uninitialized_var(flags);
 
 	if (page->freelist) {
 		stat(s, DEACTIVATE_REMOTE_FREES);
@@ -1807,7 +1808,7 @@ static void deactivate_slab(struct kmem_
 			new.inuse--;
 			VM_BUG_ON(!new.frozen);
 
-		} while (!__cmpxchg_double_slab(s, page,
+		} while (!cmpxchg_double_slab(s, page,
 			prior, counters,
 			freelist, new.counters,
 			"drain percpu freelist"));
@@ -1857,7 +1858,7 @@ redo:
 			 * that acquire_slab() will see a slab page that
 			 * is frozen
 			 */
-			spin_lock(&n->list_lock);
+			spin_lock_irqsave(&n->list_lock, flags);
 		}
 	} else {
 		m = M_FULL;
@@ -1868,7 +1869,7 @@ redo:
 			 * slabs from diagnostic functions will not see
 			 * any frozen slabs.
 			 */
-			spin_lock(&n->list_lock);
+			spin_lock_irqsave(&n->list_lock, flags);
 		}
 	}
 
@@ -1896,14 +1897,14 @@ redo:
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
