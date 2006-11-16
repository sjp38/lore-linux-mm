Subject: [PATCH] mm: cleanup and document reclaim recursion
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20061115140049.c835fbfd.akpm@osdl.org>
References: <1163618703.5968.50.camel@twins>
	 <20061115124228.db0b42a6.akpm@osdl.org> <1163625058.5968.64.camel@twins>
	 <20061115132340.3cbf4008.akpm@osdl.org> <1163626378.5968.74.camel@twins>
	 <20061115140049.c835fbfd.akpm@osdl.org>
Content-Type: text/plain
Date: Thu, 16 Nov 2006 10:52:25 +0100
Message-Id: <1163670745.5968.83.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-11-15 at 14:00 -0800, Andrew Morton wrote:
> On Wed, 15 Nov 2006 22:32:58 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > +			current->flags |= PF_MEMALLOC;
> >  			try_to_free_pages(zones, GFP_NOFS);
> > +			current->flags &= ~PF_MEMALLOC;
> 
> Sometime, later, in a different patch, we might as well suck that into
> try_to_free_pages() itself.   Along with nice comment explaining
> what it means and WARN_ON(current->flags & PF_MEMALLOC).

---

Cleanup and document the reclaim recursion avoiding properties of PF_MEMALLOC.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/buffer.c     |    9 +++++----
 mm/page_alloc.c |    2 --
 mm/vmscan.c     |   15 +++++++++++++++
 3 files changed, 20 insertions(+), 6 deletions(-)

Index: linux-2.6-git/fs/buffer.c
===================================================================
--- linux-2.6-git.orig/fs/buffer.c	2006-11-16 10:28:13.000000000 +0100
+++ linux-2.6-git/fs/buffer.c	2006-11-16 10:37:32.000000000 +0100
@@ -358,13 +358,14 @@ static void free_more_memory(void)
 	wakeup_pdflush(1024);
 	yield();
 
+	/* We're already in reclaim */
+	if (current->flags & PF_MEMALLOC)
+		return;
+
 	for_each_online_pgdat(pgdat) {
 		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
-		if (*zones && !(current->flags & PF_MEMALLOC)) {
-			current->flags |= PF_MEMALLOC;
+		if (*zones)
 			try_to_free_pages(zones, GFP_NOFS);
-			current->flags &= ~PF_MEMALLOC;
-		}
 	}
 }
 
Index: linux-2.6-git/mm/page_alloc.c
===================================================================
--- linux-2.6-git.orig/mm/page_alloc.c	2006-11-16 10:28:13.000000000 +0100
+++ linux-2.6-git/mm/page_alloc.c	2006-11-16 10:37:32.000000000 +0100
@@ -1067,14 +1067,12 @@ rebalance:
 
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
-	p->flags |= PF_MEMALLOC;
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
 	did_some_progress = try_to_free_pages(zonelist->zones, gfp_mask);
 
 	p->reclaim_state = NULL;
-	p->flags &= ~PF_MEMALLOC;
 
 	cond_resched();
 
Index: linux-2.6-git/mm/vmscan.c
===================================================================
--- linux-2.6-git.orig/mm/vmscan.c	2006-11-16 10:28:13.000000000 +0100
+++ linux-2.6-git/mm/vmscan.c	2006-11-16 10:37:32.000000000 +0100
@@ -1030,6 +1030,20 @@ unsigned long try_to_free_pages(struct z
 
 	count_vm_event(ALLOCSTALL);
 
+	/*
+	 * PF_MEMALLOC also keeps direct reclaim from recursing into itself.
+	 * Any invocation of direct reclaim with PF_MEMALLOC set is therefore
+	 * invalid.
+	 *
+	 * This makes sense, in that PF_MEMALLOC results in ALLOC_NO_WATERMARKS
+	 * for allocations (except __GFP_NOMEMALLOC), which only makes sense
+	 * for reclaim (or reclaim aiding) contexts. So starting reclaim
+	 * from a context that either helps out reclaim or is reclaim doesn't
+	 * make sense.
+	 */
+	WARN_ON(current->flags & PF_MEMALLOC);
+	current->flags |= PF_MEMALLOC;
+
 	for (i = 0; zones[i] != NULL; i++) {
 		struct zone *zone = zones[i];
 
@@ -1093,6 +1107,7 @@ out:
 
 		zone->prev_priority = priority;
 	}
+	current->flags &= ~PF_MEMALLOC;
 	return ret;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
