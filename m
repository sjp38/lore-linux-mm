Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B52646B0254
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 16:18:03 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id yy13so10635465pab.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:18:03 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 78si11759567pfr.69.2016.01.27.13.18.00
        for <linux-mm@kvack.org>;
        Wed, 27 Jan 2016 13:18:00 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 4/5] mm: Use radix_tree_iter_retry()
Date: Wed, 27 Jan 2016 16:17:51 -0500
Message-Id: <1453929472-25566-5-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

Instead of a 'goto restart', we can now use radix_tree_iter_retry()
to restart from our current position.  This will make a difference
when there are more ways to happen across an indirect pointer.  And it
eliminates some confusing gotos.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 mm/filemap.c | 53 +++++++++++++++++------------------------------------
 mm/shmem.c   | 18 ++++++++++++------
 2 files changed, 29 insertions(+), 42 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 7705dac561ba..e0c4b905fe1c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1245,7 +1245,6 @@ unsigned find_get_entries(struct address_space *mapping,
 		return 0;
 
 	rcu_read_lock();
-restart:
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
 		struct page *page;
 repeat:
@@ -1253,8 +1252,10 @@ repeat:
 		if (unlikely(!page))
 			continue;
 		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page))
-				goto restart;
+			if (radix_tree_deref_retry(page)) {
+				slot = radix_tree_iter_retry(&iter);
+				continue;
+			}
 			/*
 			 * A shadow entry of a recently evicted page, a swap
 			 * entry from shmem/tmpfs or a DAX entry.  Return it
@@ -1307,7 +1308,6 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 		return 0;
 
 	rcu_read_lock();
-restart:
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
 		struct page *page;
 repeat:
@@ -1317,13 +1317,8 @@ repeat:
 
 		if (radix_tree_exception(page)) {
 			if (radix_tree_deref_retry(page)) {
-				/*
-				 * Transient condition which can only trigger
-				 * when entry at index 0 moves out of or back
-				 * to root: none yet gotten, safe to restart.
-				 */
-				WARN_ON(iter.index);
-				goto restart;
+				slot = radix_tree_iter_retry(&iter);
+				continue;
 			}
 			/*
 			 * A shadow entry of a recently evicted page,
@@ -1374,7 +1369,6 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 		return 0;
 
 	rcu_read_lock();
-restart:
 	radix_tree_for_each_contig(slot, &mapping->page_tree, &iter, index) {
 		struct page *page;
 repeat:
@@ -1385,12 +1379,8 @@ repeat:
 
 		if (radix_tree_exception(page)) {
 			if (radix_tree_deref_retry(page)) {
-				/*
-				 * Transient condition which can only trigger
-				 * when entry at index 0 moves out of or back
-				 * to root: none yet gotten, safe to restart.
-				 */
-				goto restart;
+				slot = radix_tree_iter_retry(&iter);
+				continue;
 			}
 			/*
 			 * A shadow entry of a recently evicted page,
@@ -1450,7 +1440,6 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 		return 0;
 
 	rcu_read_lock();
-restart:
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
 				   &iter, *index, tag) {
 		struct page *page;
@@ -1461,12 +1450,8 @@ repeat:
 
 		if (radix_tree_exception(page)) {
 			if (radix_tree_deref_retry(page)) {
-				/*
-				 * Transient condition which can only trigger
-				 * when entry at index 0 moves out of or back
-				 * to root: none yet gotten, safe to restart.
-				 */
-				goto restart;
+				slot = radix_tree_iter_retry(&iter);
+				continue;
 			}
 			/*
 			 * A shadow entry of a recently evicted page.
@@ -1529,7 +1514,6 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 		return 0;
 
 	rcu_read_lock();
-restart:
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
 				   &iter, start, tag) {
 		struct page *page;
@@ -1539,12 +1523,8 @@ repeat:
 			continue;
 		if (radix_tree_exception(page)) {
 			if (radix_tree_deref_retry(page)) {
-				/*
-				 * Transient condition which can only trigger
-				 * when entry at index 0 moves out of or back
-				 * to root: none yet gotten, safe to restart.
-				 */
-				goto restart;
+				slot = radix_tree_iter_retry(&iter);
+				continue;
 			}
 
 			/*
@@ -2151,10 +2131,11 @@ repeat:
 		if (unlikely(!page))
 			goto next;
 		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page))
-				break;
-			else
-				goto next;
+			if (radix_tree_deref_retry(page)) {
+				slot = radix_tree_iter_retry(&iter);
+				continue;
+			}
+			goto next;
 		}
 
 		if (!page_cache_get_speculative(page))
diff --git a/mm/shmem.c b/mm/shmem.c
index fa2ceb2d2655..6ec14b70d82d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -388,8 +388,10 @@ restart:
 		 * don't need to reset the counter, nor do we risk infinite
 		 * restarts.
 		 */
-		if (radix_tree_deref_retry(page))
-			goto restart;
+		if (radix_tree_deref_retry(page)) {
+			slot = radix_tree_iter_retry(&iter);
+			continue;
+		}
 
 		if (radix_tree_exceptional_entry(page))
 			swapped++;
@@ -1952,8 +1954,10 @@ restart:
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
 		page = radix_tree_deref_slot(slot);
 		if (!page || radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page))
-				goto restart;
+			if (radix_tree_deref_retry(page)) {
+				slot = radix_tree_iter_retry(&iter);
+				continue;
+			}
 		} else if (page_count(page) - page_mapcount(page) > 1) {
 			spin_lock_irq(&mapping->tree_lock);
 			radix_tree_tag_set(&mapping->page_tree, iter.index,
@@ -2007,8 +2011,10 @@ restart:
 
 			page = radix_tree_deref_slot(slot);
 			if (radix_tree_exception(page)) {
-				if (radix_tree_deref_retry(page))
-					goto restart;
+				if (radix_tree_deref_retry(page)) {
+					slot = radix_tree_iter_retry(&iter);
+					continue;
+				}
 
 				page = NULL;
 			}
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
