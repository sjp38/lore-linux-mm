Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8940C6B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 11:37:00 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so54259894pab.2
        for <linux-mm@kvack.org>; Wed, 13 May 2015 08:37:00 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id zu5si27599689pac.183.2015.05.13.08.36.58
        for <linux-mm@kvack.org>;
        Wed, 13 May 2015 08:36:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] radix-tree: replace preallocated node array with linked list
Date: Wed, 13 May 2015 18:36:54 +0300
Message-Id: <1431531414-173802-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently we use per-cpu array to hold pointers to preallocated nodes.
Let's replace it with linked list. On x86_64 it saves 256 bytes in
per-cpu ELF section which may translate into freeing up 2MB of memory
for NR_CPUS==8192.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 lib/radix-tree.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 3d2aa27b845b..1f58724a2f58 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -65,7 +65,8 @@ static struct kmem_cache *radix_tree_node_cachep;
  */
 struct radix_tree_preload {
 	int nr;
-	struct radix_tree_node *nodes[RADIX_TREE_PRELOAD_SIZE];
+	/* nodes->private_data points to next prealocated node */
+	struct radix_tree_node *nodes;
 };
 static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };
 
@@ -197,8 +198,9 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 		 */
 		rtp = this_cpu_ptr(&radix_tree_preloads);
 		if (rtp->nr) {
-			ret = rtp->nodes[rtp->nr - 1];
-			rtp->nodes[rtp->nr - 1] = NULL;
+			ret = rtp->nodes;
+			rtp->nodes = ret->private_data;
+			ret->private_data = NULL;
 			rtp->nr--;
 		}
 		/*
@@ -257,16 +259,18 @@ static int __radix_tree_preload(gfp_t gfp_mask)
 
 	preempt_disable();
 	rtp = this_cpu_ptr(&radix_tree_preloads);
-	while (rtp->nr < ARRAY_SIZE(rtp->nodes)) {
+	while (rtp->nr < RADIX_TREE_PRELOAD_SIZE) {
 		preempt_enable();
 		node = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 		if (node == NULL)
 			goto out;
 		preempt_disable();
 		rtp = this_cpu_ptr(&radix_tree_preloads);
-		if (rtp->nr < ARRAY_SIZE(rtp->nodes))
-			rtp->nodes[rtp->nr++] = node;
-		else
+		if (rtp->nr < RADIX_TREE_PRELOAD_SIZE) {
+			node->private_data = rtp->nodes;
+			rtp->nodes = node;
+			rtp->nr++;
+		} else
 			kmem_cache_free(radix_tree_node_cachep, node);
 	}
 	ret = 0;
@@ -1463,15 +1467,16 @@ static int radix_tree_callback(struct notifier_block *nfb,
 {
        int cpu = (long)hcpu;
        struct radix_tree_preload *rtp;
+       struct radix_tree_node *node;
 
        /* Free per-cpu pool of perloaded nodes */
        if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
                rtp = &per_cpu(radix_tree_preloads, cpu);
                while (rtp->nr) {
-                       kmem_cache_free(radix_tree_node_cachep,
-                                       rtp->nodes[rtp->nr-1]);
-                       rtp->nodes[rtp->nr-1] = NULL;
-                       rtp->nr--;
+			node = rtp->nodes;
+			rtp->nodes = node->private_data;
+			kmem_cache_free(radix_tree_node_cachep, node);
+			rtp->nr--;
                }
        }
        return NOTIFY_OK;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
