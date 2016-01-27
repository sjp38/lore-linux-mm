Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C80336B0257
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 16:18:09 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id uo6so10943195pac.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:18:09 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id n2si11695735pap.201.2016.01.27.13.18.03
        for <linux-mm@kvack.org>;
        Wed, 27 Jan 2016 13:18:03 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 1/5] radix-tree: Fix race in gang lookup
Date: Wed, 27 Jan 2016 16:17:48 -0500
Message-Id: <1453929472-25566-2-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ohad Ben-Cohen <ohad@wizery.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

If the indirect_ptr bit is set on a slot, that indicates we need to
redo the lookup.  Introduce a new function radix_tree_iter_retry()
which forces the loop to retry the lookup by setting 'slot' to NULL and
turning the iterator back to point at the problematic entry.

This is a pretty rare problem to hit at the moment; the lookup has to
race with a grow of the radix tree from a height of 0.  The consequences
of hitting this race are that gang lookup could return a pointer to a
radix_tree_node instead of a pointer to whatever the user had inserted
in the tree.

Fixes: cebbd29e1c2f ("radix-tree: rewrite gang lookup using iterator")
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Cc: stable@vger.kernel.org
---
 include/linux/radix-tree.h | 16 ++++++++++++++++
 lib/radix-tree.c           | 12 ++++++++++--
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index f9a3da5bf892..db0ed595749b 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -387,6 +387,22 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 			     struct radix_tree_iter *iter, unsigned flags);
 
 /**
+ * radix_tree_iter_retry - retry this chunk of the iteration
+ * @iter:	iterator state
+ *
+ * If we iterate over a tree protected only by the RCU lock, a race
+ * against deletion or creation may result in seeing a slot for which
+ * radix_tree_deref_retry() returns true.  If so, call this function
+ * and continue the iteration.
+ */
+static inline __must_check
+void **radix_tree_iter_retry(struct radix_tree_iter *iter)
+{
+	iter->next_index = iter->index;
+	return NULL;
+}
+
+/**
  * radix_tree_chunk_size - get current chunk size
  *
  * @iter:	pointer to radix tree iterator
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index a25f635dcc56..65422ac17114 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1105,9 +1105,13 @@ radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 		return 0;
 
 	radix_tree_for_each_slot(slot, root, &iter, first_index) {
-		results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
+		results[ret] = rcu_dereference_raw(*slot);
 		if (!results[ret])
 			continue;
+		if (radix_tree_is_indirect_ptr(results[ret])) {
+			slot = radix_tree_iter_retry(&iter);
+			continue;
+		}
 		if (++ret == max_items)
 			break;
 	}
@@ -1184,9 +1188,13 @@ radix_tree_gang_lookup_tag(struct radix_tree_root *root, void **results,
 		return 0;
 
 	radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
-		results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
+		results[ret] = rcu_dereference_raw(*slot);
 		if (!results[ret])
 			continue;
+		if (radix_tree_is_indirect_ptr(results[ret])) {
+			slot = radix_tree_iter_retry(&iter);
+			continue;
+		}
 		if (++ret == max_items)
 			break;
 	}
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
