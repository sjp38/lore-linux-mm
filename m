Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 841C96B0037
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 11:09:13 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id a1so6104733wgh.29
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:09:12 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ep3si7236400wib.35.2014.09.24.08.09.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 08:09:12 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/3] mm: memcontrol: do not kill uncharge batching in free_pages_and_swap_cache
Date: Wed, 24 Sep 2014 11:08:56 -0400
Message-Id: <1411571338-8178-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
References: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Michal Hocko <mhocko@suse.cz>

free_pages_and_swap_cache limits release_pages to PAGEVEC_SIZE chunks.
This is not a big deal for the normal release path but it completely
kills memcg uncharge batching which reduces res_counter spin_lock
contention. Dave has noticed this with his page fault scalability test
case on a large machine when the lock was basically dominating on all
CPUs:
    80.18%    80.18%  [kernel]               [k] _raw_spin_lock
                  |
                  --- _raw_spin_lock
                     |
                     |--66.59%-- res_counter_uncharge_until
                     |          res_counter_uncharge
                     |          uncharge_batch
                     |          uncharge_list
                     |          mem_cgroup_uncharge_list
                     |          release_pages
                     |          free_pages_and_swap_cache
                     |          tlb_flush_mmu_free
                     |          |
                     |          |--90.12%-- unmap_single_vma
                     |          |          unmap_vmas
                     |          |          unmap_region
                     |          |          do_munmap
                     |          |          vm_munmap
                     |          |          sys_munmap
                     |          |          system_call_fastpath
                     |          |          __GI___munmap
                     |          |
                     |           --9.88%-- tlb_flush_mmu
                     |                     tlb_finish_mmu
                     |                     unmap_region
                     |                     do_munmap
                     |                     vm_munmap
                     |                     sys_munmap
                     |                     system_call_fastpath
                     |                     __GI___munmap

In his case the load was running in the root memcg and that part
has been handled by reverting 05b843012335 ("mm: memcontrol: use
root_mem_cgroup res_counter") because this is a clear regression,
but the problem remains inside dedicated memcgs.

There is no reason to limit release_pages to PAGEVEC_SIZE batches other
than lru_lock held times. This logic, however, can be moved inside the
function. mem_cgroup_uncharge_list and free_hot_cold_page_list do not
hold any lock for the whole pages_to_free list so it is safe to call
them in a single run.

Page reference count and LRU handling is moved to release_lru_pages and
that is run in PAGEVEC_SIZE batches.

Reported-by: Dave Hansen <dave@sr71.net>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/swap.c       | 27 +++++++++++++++++++++------
 mm/swap_state.c | 14 ++++----------
 2 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 6b2dc3897cd5..8af99dd68dd2 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -888,9 +888,9 @@ void lru_add_drain_all(void)
 }
 
 /*
- * Batched page_cache_release().  Decrement the reference count on all the
- * passed pages.  If it fell to zero then remove the page from the LRU and
- * free it.
+ * Batched lru release. Decrement the reference count on all the passed pages.
+ * If it fell to zero then remove the page from the LRU and add it to the given
+ * list to be freed by the caller.
  *
  * Avoid taking zone->lru_lock if possible, but if it is taken, retain it
  * for the remainder of the operation.
@@ -900,10 +900,10 @@ void lru_add_drain_all(void)
  * grabbed the page via the LRU.  If it did, give up: shrink_inactive_list()
  * will free it.
  */
-void release_pages(struct page **pages, int nr, bool cold)
+static void release_lru_pages(struct page **pages, int nr,
+			      struct list_head *pages_to_free)
 {
 	int i;
-	LIST_HEAD(pages_to_free);
 	struct zone *zone = NULL;
 	struct lruvec *lruvec;
 	unsigned long uninitialized_var(flags);
@@ -943,11 +943,26 @@ void release_pages(struct page **pages, int nr, bool cold)
 		/* Clear Active bit in case of parallel mark_page_accessed */
 		__ClearPageActive(page);
 
-		list_add(&page->lru, &pages_to_free);
+		list_add(&page->lru, pages_to_free);
 	}
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
+}
+/*
+ * Batched page_cache_release(). Frees and uncharges all given pages
+ * for which the reference count drops to 0.
+ */
+void release_pages(struct page **pages, int nr, bool cold)
+{
+	LIST_HEAD(pages_to_free);
 
+	while (nr) {
+		int batch = min(nr, PAGEVEC_SIZE);
+
+		release_lru_pages(pages, batch, &pages_to_free);
+		pages += batch;
+		nr -= batch;
+	}
 	mem_cgroup_uncharge_list(&pages_to_free);
 	free_hot_cold_page_list(&pages_to_free, cold);
 }
diff --git a/mm/swap_state.c b/mm/swap_state.c
index ef1f39139b71..154444918685 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -265,18 +265,12 @@ void free_page_and_swap_cache(struct page *page)
 void free_pages_and_swap_cache(struct page **pages, int nr)
 {
 	struct page **pagep = pages;
+	int i;
 
 	lru_add_drain();
-	while (nr) {
-		int todo = min(nr, PAGEVEC_SIZE);
-		int i;
-
-		for (i = 0; i < todo; i++)
-			free_swap_cache(pagep[i]);
-		release_pages(pagep, todo, false);
-		pagep += todo;
-		nr -= todo;
-	}
+	for (i = 0; i < nr; i++)
+		free_swap_cache(pagep[i]);
+	release_pages(pagep, nr, false);
 }
 
 /*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
