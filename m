Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 335196B007E
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 14:58:28 -0400 (EDT)
From: Waiman Long <Waiman.Long@hp.com>
Subject: [PATCH] slub: prevent validate_slab() error due to race condition
Date: Thu, 26 Apr 2012 14:57:38 -0400
Message-Id: <1335466658-29063-1-git-send-email-Waiman.Long@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, don.morris@hp.com, Waiman Long <Waiman.Long@hp.com>, Waiman Long <waiman.long@hp.com>

The SLUB memory allocator was changed substantially from 3.0 to 3.1 by
replacing some of page locking codes for updating the free object list
of the slab with double-quadword atomic exchange (cmpxchg_double_slab)
or a pseudo one using a page lock when debugging is turned on.  In the
normal case, that should be enough to make sure that the slab is in a
consistent state. However, when CONFIG_SLUB_DEBUG is turned on and the
Redzone debugging flag is set, the Redzone bytes are also used to mark
if an object is free or allocated. The extra state information in those
Redzone bytes is not protected by the cmpxchg_double_slab(). As a
result,
validate_slab() may report a Redzone error if the validation is
performed
while racing with a free to a debugged slab.

The problem was reported in

	https://bugzilla.kernel.org/show_bug.cgi?id=42312

It is fairly easy to reproduce by passing in the kernel parameter of
"slub_debug=FZPU".  After booting, run the command (as root):

	while true ; do ./slabinfo -v ; sleep 3 ; done

The slabinfo test code can be found in tools/vm/slabinfo.c.

At the same time, load the system with heavy I/O activities by, for
example, building the Linux kernel. The following kind of dmesg messages
will then be reported:

	BUG names_cache: Redzone overwritten
	SLUB: names_cache 3 slabs counted but counter=4

This patch fixes the BUG message by acquiring the node-level lock for
slabs flagged for debugging to avoid this possible racing condition.
The locking is done on the node-level lock instead of the more granular
page lock because the new code may speculatively acquire the node-level
lock later on. Acquiring the page lock and then the node lock may lead
to potential deadlock.

As the increment of slab node count and insertion of the new slab into
the partial or full slab list is not an atomic operation, there is a
small time window where the two may not match. This patch temporarily
works around this problem by allowing the node count to be one larger
than the number of slab presents in the lists. This workaround may not
work if more than one CPU is actively adding slab to the same node,
but it should be good enough to workaround the problem in most cases.

To really fix the issue, the overall synchronization between debug slub
operations and slub validation needs a revisit.

This patch also fixes a number of "code indent should use tabs where
possible" error reported by checkpatch.pl in the __slab_free() function
by replacing groups of 8-space tab by real tabs.

After applying the patch, the slub error and warnings are all gone in
the 4-CPU x86-64 test machine.

Signed-off-by: Waiman Long <waiman.long@hp.com>
Reviewed-by: Don Morris <don.morris@hp.com>
---
 mm/slub.c |   46 +++++++++++++++++++++++++++++++++-------------
 1 files changed, 33 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ffe13fd..4ca3140 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2445,8 +2445,18 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 	stat(s, FREE_SLOWPATH);
 
-	if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
-		return;
+	if (kmem_cache_debug(s)) {
+		/*
+		 * We need to acquire the node lock to prevent spurious error
+		 * with validate_slab().
+		 */
+		n = get_node(s, page_to_nid(page));
+		spin_lock_irqsave(&n->list_lock, flags);
+		if (!free_debug_processing(s, page, x, addr)) {
+			spin_unlock_irqrestore(&n->list_lock, flags);
+			return;
+		}
+	}
 
 	do {
 		prior = page->freelist;
@@ -2467,7 +2477,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 			else { /* Needs to be taken off a list */
 
-	                        n = get_node(s, page_to_nid(page));
+				n = get_node(s, page_to_nid(page));
 				/*
 				 * Speculatively acquire the list_lock.
 				 * If the cmpxchg does not succeed then we may
@@ -2501,10 +2511,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		 * The list lock was not taken therefore no list
 		 * activity can be necessary.
 		 */
-                if (was_frozen)
-                        stat(s, FREE_FROZEN);
-                return;
-        }
+		if (was_frozen)
+			stat(s, FREE_FROZEN);
+		return;
+	}
 
 	/*
 	 * was_frozen may have been set after we acquired the list_lock in
@@ -2514,7 +2524,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		stat(s, FREE_FROZEN);
 	else {
 		if (unlikely(!inuse && n->nr_partial > s->min_partial))
-                        goto slab_empty;
+			goto slab_empty;
 
 		/*
 		 * Objects left in the slab. If it was not on the partial list before
@@ -4122,7 +4132,7 @@ static void validate_slab_slab(struct kmem_cache *s, struct page *page,
 static int validate_slab_node(struct kmem_cache *s,
 		struct kmem_cache_node *n, unsigned long *map)
 {
-	unsigned long count = 0;
+	unsigned long count = 0, n_count;
 	struct page *page;
 	unsigned long flags;
 
@@ -4143,10 +4153,20 @@ static int validate_slab_node(struct kmem_cache *s,
 		validate_slab_slab(s, page, map);
 		count++;
 	}
-	if (count != atomic_long_read(&n->nr_slabs))
-		printk(KERN_ERR "SLUB: %s %ld slabs counted but "
-			"counter=%ld\n", s->name, count,
-			atomic_long_read(&n->nr_slabs));
+	n_count = atomic_long_read(&n->nr_slabs);
+	/*
+	 * The following workaround is to greatly reduce the chance of counter
+	 * mismatch messages due to the fact that inc_slabs_node() and the
+	 * subsequent insertion into the partial or full slab list is not
+	 * atomic. Consequently, there is a small timing window when the two
+	 * are not in the same state. A possible fix is to take the node lock
+	 * while doing inc_slabs_node() and slab insertion, but that may
+	 * require substantial changes to existing slow path slab allocation
+	 * logic.
+	 */
+	if ((count != n_count) && (count + 1 != n_count))
+		printk(KERN_ERR "SLUB: %s %ld slabs counted but counter=%ld\n",
+			s->name, count, n_count);
 
 out:
 	spin_unlock_irqrestore(&n->list_lock, flags);
-- 
1.7.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
