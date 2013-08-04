Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id B7F6D6B0033
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 22:14:26 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 01/23] radix-tree: implement preload for multiple contiguous elements
Date: Sun,  4 Aug 2013 05:17:03 +0300
Message-Id: <1375582645-29274-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The radix tree is variable-height, so an insert operation not only has
to build the branch to its corresponding item, it also has to build the
branch to existing items if the size has to be increased (by
radix_tree_extend).

The worst case is a zero height tree with just a single item at index 0,
and then inserting an item at index ULONG_MAX. This requires 2 new branches
of RADIX_TREE_MAX_PATH size to be created, with only the root node shared.

Radix tree is usually protected by spin lock. It means we want to
pre-allocate required memory before taking the lock.

Currently radix_tree_preload() only guarantees enough nodes to insert
one element. It's a hard limit. For transparent huge page cache we want
to insert HPAGE_PMD_NR (512 on x86-64) entries to address_space at once.

This patch introduces radix_tree_preload_count(). It allows to
preallocate nodes enough to insert a number of *contiguous* elements.
The feature costs about 5KiB per-CPU, details below.

Worst case for adding N contiguous items is adding entries at indexes
(ULONG_MAX - N) to ULONG_MAX. It requires nodes to insert single worst-case
item plus extra nodes if you cross the boundary from one node to the next.

Preload uses per-CPU array to store nodes. The total cost of preload is
"array size" * sizeof(void*) * NR_CPUS. We want to increase array size
to be able to handle 512 entries at once.

Size of array depends on system bitness and on RADIX_TREE_MAP_SHIFT.

We have three possible RADIX_TREE_MAP_SHIFT:

 #ifdef __KERNEL__
 #define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
 #else
 #define RADIX_TREE_MAP_SHIFT	3	/* For more stressful testing */
 #endif

On 64-bit system:
For RADIX_TREE_MAP_SHIFT=3, old array size is 43, new is 107.
For RADIX_TREE_MAP_SHIFT=4, old array size is 31, new is 63.
For RADIX_TREE_MAP_SHIFT=6, old array size is 21, new is 30.

On 32-bit system:
For RADIX_TREE_MAP_SHIFT=3, old array size is 21, new is 84.
For RADIX_TREE_MAP_SHIFT=4, old array size is 15, new is 46.
For RADIX_TREE_MAP_SHIFT=6, old array size is 11, new is 19.

On most machines we will have RADIX_TREE_MAP_SHIFT=6. In this case,
on 64-bit system the per-CPU feature overhead is
 for preload array:
   (30 - 21) * sizeof(void*) = 72 bytes
 plus, if the preload array is full
   (30 - 21) * sizeof(struct radix_tree_node) = 9 * 560 = 5040 bytes
 total: 5112 bytes

on 32-bit system the per-CPU feature overhead is
 for preload array:
   (19 - 11) * sizeof(void*) = 32 bytes
 plus, if the preload array is full
   (19 - 11) * sizeof(struct radix_tree_node) = 8 * 296 = 2368 bytes
 total: 2400 bytes

Since only THP uses batched preload at the moment, we disable (set max
preload to 1) it if !CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE. This can be
changed in the future.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 include/linux/radix-tree.h | 11 +++++++++++
 lib/radix-tree.c           | 41 ++++++++++++++++++++++++++++++++---------
 2 files changed, 43 insertions(+), 9 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 4039407..3bf0b3e 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -83,6 +83,16 @@ do {									\
 	(root)->rnode = NULL;						\
 } while (0)
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+/*
+ * At the moment only THP uses preload for more then on item for batched
+ * pagecache manipulations.
+ */
+#define RADIX_TREE_PRELOAD_NR	512
+#else
+#define RADIX_TREE_PRELOAD_NR	1
+#endif
+
 /**
  * Radix-tree synchronization
  *
@@ -232,6 +242,7 @@ unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
 				unsigned long index, unsigned long max_scan);
 int radix_tree_preload(gfp_t gfp_mask);
 int radix_tree_maybe_preload(gfp_t gfp_mask);
+int radix_tree_maybe_preload_contig(unsigned size, gfp_t gfp_mask);
 void radix_tree_init(void);
 void *radix_tree_tag_set(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 7811ed3..99ab73c 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -82,16 +82,24 @@ static struct kmem_cache *radix_tree_node_cachep;
  * The worst case is a zero height tree with just a single item at index 0,
  * and then inserting an item at index ULONG_MAX. This requires 2 new branches
  * of RADIX_TREE_MAX_PATH size to be created, with only the root node shared.
+ *
+ * Worst case for adding N contiguous items is adding entries at indexes
+ * (ULONG_MAX - N) to ULONG_MAX. It requires nodes to insert single worst-case
+ * item plus extra nodes if you cross the boundary from one node to the next.
+ *
  * Hence:
  */
-#define RADIX_TREE_PRELOAD_SIZE (RADIX_TREE_MAX_PATH * 2 - 1)
+#define RADIX_TREE_PRELOAD_MIN (RADIX_TREE_MAX_PATH * 2 - 1)
+#define RADIX_TREE_PRELOAD_MAX \
+	(RADIX_TREE_PRELOAD_MIN + \
+	 DIV_ROUND_UP(RADIX_TREE_PRELOAD_NR - 1, RADIX_TREE_MAP_SIZE))
 
 /*
  * Per-cpu pool of preloaded nodes
  */
 struct radix_tree_preload {
 	int nr;
-	struct radix_tree_node *nodes[RADIX_TREE_PRELOAD_SIZE];
+	struct radix_tree_node *nodes[RADIX_TREE_PRELOAD_MAX];
 };
 static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };
 
@@ -263,29 +271,35 @@ radix_tree_node_free(struct radix_tree_node *node)
 
 /*
  * Load up this CPU's radix_tree_node buffer with sufficient objects to
- * ensure that the addition of a single element in the tree cannot fail.  On
- * success, return zero, with preemption disabled.  On error, return -ENOMEM
+ * ensure that the addition of *contiguous* elements in the tree cannot fail.
+ * On success, return zero, with preemption disabled.  On error, return -ENOMEM
  * with preemption not disabled.
  *
  * To make use of this facility, the radix tree must be initialised without
  * __GFP_WAIT being passed to INIT_RADIX_TREE().
  */
-static int __radix_tree_preload(gfp_t gfp_mask)
+static int __radix_tree_preload_contig(unsigned size, gfp_t gfp_mask)
 {
 	struct radix_tree_preload *rtp;
 	struct radix_tree_node *node;
 	int ret = -ENOMEM;
+	int preload_target = RADIX_TREE_PRELOAD_MIN +
+		DIV_ROUND_UP(size - 1, RADIX_TREE_MAP_SIZE);
+
+	if (WARN_ONCE(size > RADIX_TREE_PRELOAD_NR,
+				"too large preload requested"))
+		return -ENOMEM;
 
 	preempt_disable();
 	rtp = &__get_cpu_var(radix_tree_preloads);
-	while (rtp->nr < ARRAY_SIZE(rtp->nodes)) {
+	while (rtp->nr < preload_target) {
 		preempt_enable();
 		node = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 		if (node == NULL)
 			goto out;
 		preempt_disable();
 		rtp = &__get_cpu_var(radix_tree_preloads);
-		if (rtp->nr < ARRAY_SIZE(rtp->nodes))
+		if (rtp->nr < preload_target)
 			rtp->nodes[rtp->nr++] = node;
 		else
 			kmem_cache_free(radix_tree_node_cachep, node);
@@ -308,7 +322,7 @@ int radix_tree_preload(gfp_t gfp_mask)
 {
 	/* Warn on non-sensical use... */
 	WARN_ON_ONCE(!(gfp_mask & __GFP_WAIT));
-	return __radix_tree_preload(gfp_mask);
+	return __radix_tree_preload_contig(1, gfp_mask);
 }
 EXPORT_SYMBOL(radix_tree_preload);
 
@@ -320,13 +334,22 @@ EXPORT_SYMBOL(radix_tree_preload);
 int radix_tree_maybe_preload(gfp_t gfp_mask)
 {
 	if (gfp_mask & __GFP_WAIT)
-		return __radix_tree_preload(gfp_mask);
+		return __radix_tree_preload_contig(1, gfp_mask);
 	/* Preloading doesn't help anything with this gfp mask, skip it */
 	preempt_disable();
 	return 0;
 }
 EXPORT_SYMBOL(radix_tree_maybe_preload);
 
+int radix_tree_maybe_preload_contig(unsigned size, gfp_t gfp_mask)
+{
+	if (gfp_mask & __GFP_WAIT)
+		return __radix_tree_preload_contig(size, gfp_mask);
+	/* Preloading doesn't help anything with this gfp mask, skip it */
+	preempt_disable();
+	return 0;
+}
+
 /*
  *	Return the maximum key which can be store into a
  *	radix tree with height HEIGHT.
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
