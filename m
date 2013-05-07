Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 8A6796B00D9
	for <linux-mm@kvack.org>; Tue,  7 May 2013 17:20:03 -0400 (EDT)
Subject: [RFC][PATCH 6/7] use __remove_mapping_batch() in shrink_page_list()
From: Dave Hansen <dave@sr71.net>
Date: Tue, 07 May 2013 14:20:02 -0700
References: <20130507211954.9815F9D1@viggo.jf.intel.com>
In-Reply-To: <20130507211954.9815F9D1@viggo.jf.intel.com>
Message-Id: <20130507212002.219EDB7F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

Tim Chen's earlier version of these patches just unconditionally
created large batches of pages, even if they did not share a
page->mapping.  This is a bit suboptimal for a few reasons:
1. if we can not consolidate lock acquisitions, it makes little
   sense to batch
2. The page locks are held for long periods of time, so we only
   want to do this when we are sure that we will gain a
   substantial throughput improvement because we pay a latency
   cost by holding the locks.

This patch makes sure to only batch when all the pages on
'batch_for_mapping_removal' continue to share a page->mapping.
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

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/mm/vmscan.c |   52 +++++++++++++++++++++++++++++++++--------
 1 file changed, 42 insertions(+), 10 deletions(-)

diff -puN mm/vmscan.c~use-remove_mapping_batch mm/vmscan.c
--- linux.git/mm/vmscan.c~use-remove_mapping_batch	2013-05-07 13:48:15.016102828 -0700
+++ linux.git-davehans/mm/vmscan.c	2013-05-07 13:48:15.020103005 -0700
@@ -599,7 +599,14 @@ static int __remove_mapping_batch(struct
 		page = lru_to_page(&need_free_mapping);
 		list_move(&page->list, free_pages);
 		free_mapping_page(mapping, page);
-		unlock_page(page);
+		/*
+		 * At this point, we have no other references and there is
+		 * no way to pick any more up (removed from LRU, removed
+		 * from pagecache). Can use non-atomic bitops now (and
+		 * we obviously don't have to worry about waking up a process
+		 * waiting on the page lock, because there are no references.
+		 */
+		__clear_page_locked(page);
 		nr_reclaimed++;
 	}
 	return nr_reclaimed;
@@ -740,6 +747,15 @@ static enum page_references page_check_r
 	return PAGEREF_RECLAIM;
 }
 
+static bool batch_has_same_mapping(struct page *page, struct list_head *batch)
+{
+	struct page *first_in_batch;
+	first_in_batch = lru_to_page(batch);
+	if (first_in_batch->mapping == page->mapping)
+		return true;
+	return false;
+}
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -753,6 +769,7 @@ static unsigned long shrink_page_list(st
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
+	LIST_HEAD(batch_for_mapping_removal);
 	int pgactivate = 0;
 	unsigned long nr_dirty = 0;
 	unsigned long nr_congested = 0;
@@ -771,6 +788,19 @@ static unsigned long shrink_page_list(st
 		cond_resched();
 
 		page = lru_to_page(page_list);
+		/*
+		 * batching only makes sense when we can save lock
+		 * acquisitions, so drain the batched pages when
+		 * we move over to a different mapping
+		 */
+		if (!list_empty(&batch_for_mapping_removal) &&
+		    !batch_has_same_mapping(page, &batch_for_mapping_removal)) {
+			nr_reclaimed +=
+				__remove_mapping_batch(&batch_for_mapping_removal,
+							&ret_pages,
+							&free_pages);
+		}
+
 		list_del(&page->lru);
 
 		if (!trylock_page(page))
@@ -975,17 +1005,17 @@ static unsigned long shrink_page_list(st
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
+		list_add(&page->lru, &batch_for_mapping_removal);
+		continue;
 free_it:
 		nr_reclaimed++;
 
@@ -1016,7 +1046,9 @@ keep:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
-
+	nr_reclaimed += __remove_mapping_batch(&batch_for_mapping_removal,
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
