Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9016C6B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 17:40:25 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id h14so751214eaj.14
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 14:40:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x41si78732eee.252.2014.03.13.14.40.22
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 14:40:23 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/6] radix-tree: add end_index to support ranged iteration
Date: Thu, 13 Mar 2014 17:39:41 -0400
Message-Id: <1394746786-6397-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org

It's useful if we can run only over a specific index range of radix trees,
which this patch does. This patch changes only radix_tree_for_each_slot()
and radix_tree_for_each_tagged(), because we need it only for them for now.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 drivers/gpu/drm/qxl/qxl_ttm.c |  2 +-
 include/linux/radix-tree.h    | 27 ++++++++++++++++++++-------
 kernel/irq/irqdomain.c        |  2 +-
 lib/radix-tree.c              |  8 ++++----
 mm/filemap.c                  |  4 ++--
 mm/shmem.c                    |  2 +-
 6 files changed, 29 insertions(+), 16 deletions(-)

diff --git v3.14-rc6.orig/drivers/gpu/drm/qxl/qxl_ttm.c v3.14-rc6/drivers/gpu/drm/qxl/qxl_ttm.c
index c7e7e6590c2b..ad477307e732 100644
--- v3.14-rc6.orig/drivers/gpu/drm/qxl/qxl_ttm.c
+++ v3.14-rc6/drivers/gpu/drm/qxl/qxl_ttm.c
@@ -398,7 +398,7 @@ static int qxl_sync_obj_wait(void *sync_obj,
 		struct radix_tree_iter iter;
 		int release_id;
 
-		radix_tree_for_each_slot(slot, &qfence->tree, &iter, 0) {
+		radix_tree_for_each_slot(slot, &qfence->tree, &iter, 0, ~0UL) {
 			struct qxl_release *release;
 
 			release_id = iter.index;
diff --git v3.14-rc6.orig/include/linux/radix-tree.h v3.14-rc6/include/linux/radix-tree.h
index 403940787be1..6e14a8e06105 100644
--- v3.14-rc6.orig/include/linux/radix-tree.h
+++ v3.14-rc6/include/linux/radix-tree.h
@@ -265,6 +265,7 @@ static inline void radix_tree_preload_end(void)
  * @index:	index of current slot
  * @next_index:	next-to-last index for this chunk
  * @tags:	bit-mask for tag-iterating
+ * @end_index:  last index to be scanned
  *
  * This radix tree iterator works in terms of "chunks" of slots.  A chunk is a
  * subinterval of slots contained within one radix tree leaf node.  It is
@@ -277,6 +278,7 @@ struct radix_tree_iter {
 	unsigned long	index;
 	unsigned long	next_index;
 	unsigned long	tags;
+	unsigned long	end_index;
 };
 
 #define RADIX_TREE_ITER_TAG_MASK	0x00FF	/* tag index in lower byte */
@@ -288,10 +290,12 @@ struct radix_tree_iter {
  *
  * @iter:	pointer to iterator state
  * @start:	iteration starting index
+ * @end:	iteration ending index
  * Returns:	NULL
  */
 static __always_inline void **
-radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start)
+radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start,
+			unsigned long end)
 {
 	/*
 	 * Leave iter->tags uninitialized. radix_tree_next_chunk() will fill it
@@ -303,6 +307,7 @@ radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start)
 	 */
 	iter->index = 0;
 	iter->next_index = start;
+	iter->end_index = end;
 	return NULL;
 }
 
@@ -352,6 +357,8 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 		iter->tags >>= 1;
 		if (likely(iter->tags & 1ul)) {
 			iter->index++;
+			if (iter->index > iter->end_index)
+				return NULL;
 			return slot + 1;
 		}
 		if (!(flags & RADIX_TREE_ITER_CONTIG) && likely(iter->tags)) {
@@ -359,6 +366,8 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 
 			iter->tags >>= offset;
 			iter->index += offset + 1;
+			if (iter->index > iter->end_index)
+				return NULL;
 			return slot + offset + 1;
 		}
 	} else {
@@ -367,6 +376,8 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 		while (size--) {
 			slot++;
 			iter->index++;
+			if (iter->index > iter->end_index)
+				return NULL;
 			if (likely(*slot))
 				return slot;
 			if (flags & RADIX_TREE_ITER_CONTIG) {
@@ -391,7 +402,7 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
  * Locks can be released and reacquired between iterations.
  */
 #define radix_tree_for_each_chunk(slot, root, iter, start, flags)	\
-	for (slot = radix_tree_iter_init(iter, start) ;			\
+	for (slot = radix_tree_iter_init(iter, start, ~0UL) ;		\
 	      (slot = radix_tree_next_chunk(root, iter, flags)) ;)
 
 /**
@@ -414,11 +425,12 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
  * @root:	the struct radix_tree_root pointer
  * @iter:	the struct radix_tree_iter pointer
  * @start:	iteration starting index
+ * @end:	iteration ending index
  *
  * @slot points to radix tree slot, @iter->index contains its index.
  */
-#define radix_tree_for_each_slot(slot, root, iter, start)		\
-	for (slot = radix_tree_iter_init(iter, start) ;			\
+#define radix_tree_for_each_slot(slot, root, iter, start, end)		\
+	for (slot = radix_tree_iter_init(iter, start, end) ;		\
 	     slot || (slot = radix_tree_next_chunk(root, iter, 0)) ;	\
 	     slot = radix_tree_next_slot(slot, iter, 0))
 
@@ -433,7 +445,7 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
  * @slot points to radix tree slot, @iter->index contains its index.
  */
 #define radix_tree_for_each_contig(slot, root, iter, start)		\
-	for (slot = radix_tree_iter_init(iter, start) ;			\
+	for (slot = radix_tree_iter_init(iter, start, ~0UL) ;		\
 	     slot || (slot = radix_tree_next_chunk(root, iter,		\
 				RADIX_TREE_ITER_CONTIG)) ;		\
 	     slot = radix_tree_next_slot(slot, iter,			\
@@ -446,12 +458,13 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
  * @root:	the struct radix_tree_root pointer
  * @iter:	the struct radix_tree_iter pointer
  * @start:	iteration starting index
+ * @end:	iteration ending index
  * @tag:	tag index
  *
  * @slot points to radix tree slot, @iter->index contains its index.
  */
-#define radix_tree_for_each_tagged(slot, root, iter, start, tag)	\
-	for (slot = radix_tree_iter_init(iter, start) ;			\
+#define radix_tree_for_each_tagged(slot, root, iter, start, end, tag)	\
+	for (slot = radix_tree_iter_init(iter, start, end) ;		\
 	     slot || (slot = radix_tree_next_chunk(root, iter,		\
 			      RADIX_TREE_ITER_TAGGED | tag)) ;		\
 	     slot = radix_tree_next_slot(slot, iter,			\
diff --git v3.14-rc6.orig/kernel/irq/irqdomain.c v3.14-rc6/kernel/irq/irqdomain.c
index f14033700c25..55fc49b412e1 100644
--- v3.14-rc6.orig/kernel/irq/irqdomain.c
+++ v3.14-rc6/kernel/irq/irqdomain.c
@@ -571,7 +571,7 @@ static int virq_debug_show(struct seq_file *m, void *private)
 	mutex_lock(&irq_domain_mutex);
 	list_for_each_entry(domain, &irq_domain_list, link) {
 		int count = 0;
-		radix_tree_for_each_slot(slot, &domain->revmap_tree, &iter, 0)
+		radix_tree_for_each_slot(slot, &domain->revmap_tree, &iter, 0, ~0UL)
 			count++;
 		seq_printf(m, "%c%-16s  %6u  %10u  %10u  %s\n",
 			   domain == irq_default_domain ? '*' : ' ', domain->name,
diff --git v3.14-rc6.orig/lib/radix-tree.c v3.14-rc6/lib/radix-tree.c
index bd4a8dfdf0b8..487ba9c403d2 100644
--- v3.14-rc6.orig/lib/radix-tree.c
+++ v3.14-rc6/lib/radix-tree.c
@@ -1051,7 +1051,7 @@ radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 	if (unlikely(!max_items))
 		return 0;
 
-	radix_tree_for_each_slot(slot, root, &iter, first_index) {
+	radix_tree_for_each_slot(slot, root, &iter, first_index, ~0UL) {
 		results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
 		if (!results[ret])
 			continue;
@@ -1093,7 +1093,7 @@ radix_tree_gang_lookup_slot(struct radix_tree_root *root,
 	if (unlikely(!max_items))
 		return 0;
 
-	radix_tree_for_each_slot(slot, root, &iter, first_index) {
+	radix_tree_for_each_slot(slot, root, &iter, first_index, ~0UL) {
 		results[ret] = slot;
 		if (indices)
 			indices[ret] = iter.index;
@@ -1130,7 +1130,7 @@ radix_tree_gang_lookup_tag(struct radix_tree_root *root, void **results,
 	if (unlikely(!max_items))
 		return 0;
 
-	radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
+	radix_tree_for_each_tagged(slot, root, &iter, first_index, ~0UL, tag) {
 		results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
 		if (!results[ret])
 			continue;
@@ -1167,7 +1167,7 @@ radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
 	if (unlikely(!max_items))
 		return 0;
 
-	radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
+	radix_tree_for_each_tagged(slot, root, &iter, first_index, ~0UL, tag) {
 		results[ret] = slot;
 		if (++ret == max_items)
 			break;
diff --git v3.14-rc6.orig/mm/filemap.c v3.14-rc6/mm/filemap.c
index 7a13f6ac5421..8c24eda539d8 100644
--- v3.14-rc6.orig/mm/filemap.c
+++ v3.14-rc6/mm/filemap.c
@@ -841,7 +841,7 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 
 	rcu_read_lock();
 restart:
-	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start, ~0UL) {
 		struct page *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
@@ -985,7 +985,7 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 	rcu_read_lock();
 restart:
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
-				   &iter, *index, tag) {
+				   &iter, *index, ~0UL, tag) {
 		struct page *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
diff --git v3.14-rc6.orig/mm/shmem.c v3.14-rc6/mm/shmem.c
index 1f18c9d0d93e..973caa10fe1e 100644
--- v3.14-rc6.orig/mm/shmem.c
+++ v3.14-rc6/mm/shmem.c
@@ -346,7 +346,7 @@ static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
 
 	rcu_read_lock();
 restart:
-	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start, ~0UL) {
 		struct page *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
