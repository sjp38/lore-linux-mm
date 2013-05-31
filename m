Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 676CD6B0039
	for <linux-mm@kvack.org>; Fri, 31 May 2013 14:39:05 -0400 (EDT)
Subject: [v4][PATCH 5/6] mm: vmscan: batch shrink_page_list() locking operations
From: Dave Hansen <dave@sr71.net>
Date: Fri, 31 May 2013 11:39:02 -0700
References: <20130531183855.44DDF928@viggo.jf.intel.com>
In-Reply-To: <20130531183855.44DDF928@viggo.jf.intel.com>
Message-Id: <20130531183902.8E84DFB4@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>
changes for v2:
 * remove batch_has_same_mapping() helper.  A local varible makes
   the check cheaper and cleaner
 * Move batch draining later to where we already know
   page_mapping().  This probably fixes a truncation race anyway
 * rename batch_for_mapping_removal -> batch_for_mapping_rm.  It
   caused a line over 80 chars and needed shortening anyway.
 * Note: we only set 'batch_mapping' when there are pages in the
   batch_for_mapping_rm list

--

We batch like this so that several pages can be freed with a
single mapping->tree_lock acquisition/release pair.  This reduces
the number of atomic operations and ensures that we do not bounce
cachelines around.

Tim Chen's earlier version of these patches just unconditionally
created large batches of pages, even if they did not share a
page_mapping().  This is a bit suboptimal for a few reasons:
1. if we can not consolidate lock acquisitions, it makes little
   sense to batch
2. The page locks are held for long periods of time, so we only
   want to do this when we are sure that we will gain a
   substantial throughput improvement because we pay a latency
   cost by holding the locks.

This patch makes sure to only batch when all the pages on
'batch_for_mapping_rm' continue to share a page_mapping().
This only happens in practice in cases where pages in the same
file are close to each other on the LRU.  That seems like a
reasonable assumption.

In a 128MB virtual machine doing kernel compiles, the average
batch size when calling __remove_mapping_batch() is around 5,
so this does seem to do some good in practice.

On a 160-cpu system doing kernel compiles, I still saw an
average batch length of about 2.8.  One promising feature:
as the memory pressure went up, the average batches seem to
have gotten larger.

It has shown some substantial performance benefits on
microbenchmarks.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/mm/vmscan.c |   95 +++++++++++++++++++++++++++++++++++++----
 1 file changed, 86 insertions(+), 9 deletions(-)

diff -puN mm/vmscan.c~create-remove_mapping_batch mm/vmscan.c
--- linux.git/mm/vmscan.c~create-remove_mapping_batch	2013-05-30 16:07:51.711126969 -0700
+++ linux.git-davehans/mm/vmscan.c	2013-05-30 16:07:51.716127189 -0700
@@ -552,6 +552,61 @@ int remove_mapping(struct address_space
 	return 0;
 }
 
+/*
+ * pages come in here (via remove_list) locked and leave unlocked
+ * (on either ret_pages or free_pages)
+ *
+ * We do this batching so that we free batches of pages with a
+ * single mapping->tree_lock acquisition/release.  This optimization
+ * only makes sense when the pages on remove_list all share a
+ * page_mapping().  If this is violated you will BUG_ON().
+ */
+static int __remove_mapping_batch(struct list_head *remove_list,
+				  struct list_head *ret_pages,
+				  struct list_head *free_pages)
+{
+	int nr_reclaimed = 0;
+	struct address_space *mapping;
+	struct page *page;
+	LIST_HEAD(need_free_mapping);
+
+	if (list_empty(remove_list))
+		return 0;
+
+	mapping = page_mapping(lru_to_page(remove_list));
+	spin_lock_irq(&mapping->tree_lock);
+	while (!list_empty(remove_list)) {
+		page = lru_to_page(remove_list);
+		BUG_ON(!PageLocked(page));
+		BUG_ON(page_mapping(page) != mapping);
+		list_del(&page->lru);
+
+		if (!__remove_mapping(mapping, page)) {
+			unlock_page(page);
+			list_add(&page->lru, ret_pages);
+			continue;
+		}
+		list_add(&page->lru, &need_free_mapping);
+	}
+	spin_unlock_irq(&mapping->tree_lock);
+
+	while (!list_empty(&need_free_mapping)) {
+		page = lru_to_page(&need_free_mapping);
+		list_move(&page->list, free_pages);
+		mapping_release_page(mapping, page);
+		/*
+		 * At this point, we have no other references and there is
+		 * no way to pick any more up (removed from LRU, removed
+		 * from pagecache). Can use non-atomic bitops now (and
+		 * we obviously don't have to worry about waking up a process
+		 * waiting on the page lock, because there are no references.
+		 */
+		__clear_page_locked(page);
+		nr_reclaimed++;
+	}
+	return nr_reclaimed;
+}
+
 /**
  * putback_lru_page - put previously isolated page onto appropriate LRU list
  * @page: page to be put back to appropriate lru list
@@ -730,6 +785,8 @@ static unsigned long shrink_page_list(st
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
+	LIST_HEAD(batch_for_mapping_rm);
+	struct address_space *batch_mapping = NULL;
 	int pgactivate = 0;
 	unsigned long nr_unqueued_dirty = 0;
 	unsigned long nr_dirty = 0;
@@ -751,6 +808,7 @@ static unsigned long shrink_page_list(st
 		cond_resched();
 
 		page = lru_to_page(page_list);
+
 		list_del(&page->lru);
 
 		if (!trylock_page(page))
@@ -853,6 +911,10 @@ static unsigned long shrink_page_list(st
 
 			/* Case 3 above */
 			} else {
+				/*
+				 * batch_for_mapping_rm could be drained here
+				 * if its lock_page()s hurt latency elsewhere.
+				 */
 				wait_on_page_writeback(page);
 			}
 		}
@@ -883,6 +945,18 @@ static unsigned long shrink_page_list(st
 		}
 
 		mapping = page_mapping(page);
+		/*
+		 * batching only makes sense when we can save lock
+		 * acquisitions, so drain the previously-batched
+		 * pages when we move over to a different mapping
+		 */
+		if (batch_mapping && (batch_mapping != mapping)) {
+			nr_reclaimed +=
+				__remove_mapping_batch(&batch_for_mapping_rm,
+							&ret_pages,
+							&free_pages);
+			batch_mapping = NULL;
+		}
 
 		/*
 		 * The page is mapped into the page tables of one or more
@@ -998,17 +1072,18 @@ static unsigned long shrink_page_list(st
 			}
 		}
 
-		if (!mapping || !__remove_mapping(mapping, page))
+		if (!mapping)
 			goto keep_locked;
-
 		/*
-		 * At this point, we have no other references and there is
-		 * no way to pick any more up (removed from LRU, removed
-		 * from pagecache). Can use non-atomic bitops now (and
-		 * we obviously don't have to worry about waking up a process
-		 * waiting on the page lock, because there are no references.
+		 * This list contains pages all in the same mapping, but
+		 * in effectively random order and we hold lock_page()
+		 * on *all* of them.  This can potentially cause lock
+		 * ordering issues, but the reclaim code only trylocks
+		 * them which saves us.
 		 */
-		__clear_page_locked(page);
+		list_add(&page->lru, &batch_for_mapping_rm);
+		batch_mapping = mapping;
+		continue;
 free_it:
 		nr_reclaimed++;
 
@@ -1039,7 +1114,9 @@ keep:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
-
+	nr_reclaimed += __remove_mapping_batch(&batch_for_mapping_rm,
+						&ret_pages,
+						&free_pages);
 	/*
 	 * Tag a zone as congested if all the dirty pages encountered were
 	 * backed by a congested BDI. In this case, reclaimers should just
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
