Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 550106B0289
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 05:31:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h191so2635854wmd.15
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 02:31:07 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id 5si6866069edx.248.2017.10.12.02.31.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Oct 2017 02:31:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 6AA3398C8B
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 09:31:05 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/8] mm, truncate: Remove all exceptional entries from pagevec under one lock
Date: Thu, 12 Oct 2017 10:30:58 +0100
Message-Id: <20171012093103.13412-4-mgorman@techsingularity.net>
In-Reply-To: <20171012093103.13412-1-mgorman@techsingularity.net>
References: <20171012093103.13412-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@techsingularity.net>

During truncate each entry in a pagevec is checked to see if it is an
exceptional entry and if so, the shadow entry is cleaned up.  This is
potentially expensive as multiple entries for a mapping locks/unlocks the
tree lock.  This batches the operation such that any exceptional entries
removed from a pagevec only acquire the mapping tree lock once. The corner
case where this is more expensive is where there is only one exceptional
entry but this is unlikely due to temporal locality and how it affects
LRU ordering. Note that for truncations of small files created recently,
this patch should show no gain because it only batches the handling of
exceptional entries.

sparsetruncate (large)
                              4.14.0-rc4             4.14.0-rc4
                         pickhelper-v1r1       batchshadow-v1r1
Min          Time       38.00 (   0.00%)       27.00 (  28.95%)
1st-qrtle    Time       40.00 (   0.00%)       28.00 (  30.00%)
2nd-qrtle    Time       44.00 (   0.00%)       41.00 (   6.82%)
3rd-qrtle    Time      146.00 (   0.00%)      147.00 (  -0.68%)
Max-90%      Time      153.00 (   0.00%)      153.00 (   0.00%)
Max-95%      Time      155.00 (   0.00%)      156.00 (  -0.65%)
Max-99%      Time      181.00 (   0.00%)      171.00 (   5.52%)
Amean        Time       93.04 (   0.00%)       88.43 (   4.96%)
Best99%Amean Time       92.08 (   0.00%)       86.13 (   6.46%)
Best95%Amean Time       89.19 (   0.00%)       83.13 (   6.80%)
Best90%Amean Time       85.60 (   0.00%)       79.15 (   7.53%)
Best75%Amean Time       72.95 (   0.00%)       65.09 (  10.78%)
Best50%Amean Time       39.86 (   0.00%)       28.20 (  29.25%)
Best25%Amean Time       39.44 (   0.00%)       27.70 (  29.77%)

bonnie
                                      4.14.0-rc4             4.14.0-rc4
                                 pickhelper-v1r1       batchshadow-v1r1
Hmean     SeqCreate ops         71.92 (   0.00%)       76.78 (   6.76%)
Hmean     SeqCreate read        42.42 (   0.00%)       45.01 (   6.10%)
Hmean     SeqCreate del      26519.88 (   0.00%)    27191.87 (   2.53%)
Hmean     RandCreate ops        71.92 (   0.00%)       76.95 (   7.00%)
Hmean     RandCreate read       44.44 (   0.00%)       49.23 (  10.78%)
Hmean     RandCreate del     24948.62 (   0.00%)    24764.97 (  -0.74%)

Truncation of a large number of files shows a substantial gain with 99% of files
being trruncated 6.46% faster. bonnie shows a modest gain of 2.53%

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/truncate.c | 86 ++++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 61 insertions(+), 25 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 3dfa2d5e642e..af1eaa5b9450 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -25,44 +25,77 @@
 #include <linux/rmap.h>
 #include "internal.h"
 
-static void clear_shadow_entry(struct address_space *mapping, pgoff_t index,
-			       void *entry)
+/*
+ * Regular page slots are stabilized by the page lock even without the tree
+ * itself locked.  These unlocked entries need verification under the tree
+ * lock.
+ */
+static inline void __clear_shadow_entry(struct address_space *mapping,
+				pgoff_t index, void *entry)
 {
 	struct radix_tree_node *node;
 	void **slot;
 
-	spin_lock_irq(&mapping->tree_lock);
-	/*
-	 * Regular page slots are stabilized by the page lock even
-	 * without the tree itself locked.  These unlocked entries
-	 * need verification under the tree lock.
-	 */
 	if (!__radix_tree_lookup(&mapping->page_tree, index, &node, &slot))
-		goto unlock;
+		return;
 	if (*slot != entry)
-		goto unlock;
+		return;
 	__radix_tree_replace(&mapping->page_tree, node, slot, NULL,
 			     workingset_update_node, mapping);
 	mapping->nrexceptional--;
-unlock:
+}
+
+static void clear_shadow_entry(struct address_space *mapping, pgoff_t index,
+			       void *entry)
+{
+	spin_lock_irq(&mapping->tree_lock);
+	__clear_shadow_entry(mapping, index, entry);
 	spin_unlock_irq(&mapping->tree_lock);
 }
 
 /*
- * Unconditionally remove exceptional entry. Usually called from truncate path.
+ * Unconditionally remove exceptional entries. Usually called from truncate
+ * path. Note that the pagevec may be altered by this function by removing
+ * exceptional entries similar to what pagevec_remove_exceptionals does.
  */
-static void truncate_exceptional_entry(struct address_space *mapping,
-				       pgoff_t index, void *entry)
+static void truncate_exceptional_pvec_entries(struct address_space *mapping,
+				struct pagevec *pvec, pgoff_t *indices, int ei)
 {
+	int i, j;
+	bool dax;
+
+	/* Return immediately if caller indicates there are no entries */
+	if (ei == PAGEVEC_SIZE)
+		return;
+
 	/* Handled by shmem itself */
 	if (shmem_mapping(mapping))
 		return;
 
-	if (dax_mapping(mapping)) {
-		dax_delete_mapping_entry(mapping, index);
-		return;
+	dax = dax_mapping(mapping);
+	if (!dax)
+		spin_lock_irq(&mapping->tree_lock);
+
+	for (i = ei, j = ei; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		pgoff_t index = indices[i];
+
+		if (!radix_tree_exceptional_entry(page)) {
+			pvec->pages[j++] = page;
+			continue;
+		}
+
+		if (unlikely(dax)) {
+			dax_delete_mapping_entry(mapping, index);
+			continue;
+		}
+
+		__clear_shadow_entry(mapping, index, page);
 	}
-	clear_shadow_entry(mapping, index, entry);
+
+	if (!dax)
+		spin_unlock_irq(&mapping->tree_lock);
+	pvec->nr = j;
 }
 
 /*
@@ -301,6 +334,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		 */
 		struct page *pages[PAGEVEC_SIZE];
 		int batch_count = 0;
+		int ei = PAGEVEC_SIZE;
 
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
@@ -311,8 +345,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
-				truncate_exceptional_entry(mapping, index,
-							   page);
+				if (ei == PAGEVEC_SIZE)
+					ei = i;
 				continue;
 			}
 
@@ -334,12 +368,11 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		delete_from_page_cache_batch(mapping, batch_count, pages);
 		for (i = 0; i < batch_count; i++)
 			unlock_page(pages[i]);
-		pagevec_remove_exceptionals(&pvec);
+		truncate_exceptional_pvec_entries(mapping, &pvec, indices, ei);
 		pagevec_release(&pvec);
 		cond_resched();
 		index++;
 	}
-
 	if (partial_start) {
 		struct page *page = find_lock_page(mapping, start - 1);
 		if (page) {
@@ -381,6 +414,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 	index = start;
 	for ( ; ; ) {
+		int ei = PAGEVEC_SIZE;
+
 		cond_resched();
 		if (!pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE), indices)) {
@@ -397,6 +432,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			pagevec_release(&pvec);
 			break;
 		}
+
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -409,8 +445,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			}
 
 			if (radix_tree_exceptional_entry(page)) {
-				truncate_exceptional_entry(mapping, index,
-							   page);
+				if (ei != PAGEVEC_SIZE)
+					ei = i;
 				continue;
 			}
 
@@ -420,7 +456,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
-		pagevec_remove_exceptionals(&pvec);
+		truncate_exceptional_pvec_entries(mapping, &pvec, indices, ei);
 		pagevec_release(&pvec);
 		index++;
 	}
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
