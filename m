Date: Fri, 23 Jul 2004 14:05:55 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: [PATCH] Locking optimization for cache_reap
Message-ID: <20040723190555.GB16956@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Here is another cache_reap optimization that reduces latency when
applied after the 'Move cache_reap out of timer context' patch I
submitted on 7/14 (for inclusion in -mm next week).

This applies to 2.6.8-rc2 + the above mentioned patch.

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>


Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c
+++ linux/mm/slab.c
@@ -2619,27 +2619,6 @@ static void enable_cpucache (kmem_cache_
 					cachep->name, -err);
 }
 
-static void drain_array(kmem_cache_t *cachep, struct array_cache *ac)
-{
-	int tofree;
-
-	check_irq_off();
-	if (ac->touched) {
-		ac->touched = 0;
-	} else if (ac->avail) {
-		tofree = (ac->limit+4)/5;
-		if (tofree > ac->avail) {
-			tofree = (ac->avail+1)/2;
-		}
-		spin_lock(&cachep->spinlock);
-		free_block(cachep, ac_entry(ac), tofree);
-		spin_unlock(&cachep->spinlock);
-		ac->avail -= tofree;
-		memmove(&ac_entry(ac)[0], &ac_entry(ac)[tofree],
-					sizeof(void*)*ac->avail);
-	}
-}
-
 static void drain_array_locked(kmem_cache_t *cachep,
 				struct array_cache *ac, int force)
 {
@@ -2697,16 +2676,14 @@ static void cache_reap (void *unused)
 			goto next;
 
 		check_irq_on();
-		local_irq_disable();
-		drain_array(searchp, ac_data(searchp));
 
-		if(time_after(searchp->lists.next_reap, jiffies))
-			goto next_irqon;
+		spin_lock_irq(&searchp->spinlock);
+
+		drain_array_locked(searchp, ac_data(searchp), 0);
 
-		spin_lock(&searchp->spinlock);
-		if(time_after(searchp->lists.next_reap, jiffies)) {
+		if(time_after(searchp->lists.next_reap, jiffies))
 			goto next_unlock;
-		}
+
 		searchp->lists.next_reap = jiffies + REAPTIMEOUT_LIST3;
 
 		if (searchp->lists.shared)
@@ -2739,9 +2716,7 @@ static void cache_reap (void *unused)
 			spin_lock_irq(&searchp->spinlock);
 		} while(--tofree > 0);
 next_unlock:
-		spin_unlock(&searchp->spinlock);
-next_irqon:
-		local_irq_enable();
+		spin_unlock_irq(&searchp->spinlock);
 next:
 		;
 	}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
