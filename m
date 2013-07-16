Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 9A3D86B0031
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 13:06:40 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH RFC] lib: Make radix_tree_node_alloc() irq safe
Date: Tue, 16 Jul 2013 19:06:30 +0200
Message-Id: <1373994390-5479-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Jens Axboe <jaxboe@fusionio.com>, Jan Kara <jack@suse.cz>

With users of radix_tree_preload() run from interrupt (CFQ is one such
possible user), the following race can happen:

radix_tree_preload()
...
radix_tree_insert()
  radix_tree_node_alloc()
    if (rtp->nr) {
      ret = rtp->nodes[rtp->nr - 1];
<interrupt>
...
radix_tree_preload()
...
radix_tree_insert()
  radix_tree_node_alloc()
    if (rtp->nr) {
      ret = rtp->nodes[rtp->nr - 1];

And we give out one radix tree node twice. That clearly results in radix
tree corruption with different results (usually OOPS) depending on which
two users of radix tree race.

Fix the problem by disabling interrupts when working with rtp variable.
In-interrupt user can still deplete our preloaded nodes but at least we
won't corrupt radix trees.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 lib/radix-tree.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

  There are some questions regarding this patch:
Do we really want to allow in-interrupt users of radix_tree_preload()?  CFQ
could certainly do this in older kernels but that particular call site where I
saw the bug hit isn't there anymore so I'm not sure this can really happen with
recent kernels.

Also it is actually harmful to do preloading if you are in interrupt context
anyway. The disadvantage of disallowing radix_tree_preload() in interrupt is
that we would need to tweak radix_tree_node_alloc() to somehow recognize
whether the caller wants it to use preloaded nodes or not and that callers
would have to get it right (although maybe some magic in radix_tree_preload()
could handle that).

Opinions?

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index e796429..6f1045d 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -209,18 +209,26 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 
 	if (!(gfp_mask & __GFP_WAIT)) {
 		struct radix_tree_preload *rtp;
+		unsigned long flags;
 
 		/*
 		 * Provided the caller has preloaded here, we will always
 		 * succeed in getting a node here (and never reach
-		 * kmem_cache_alloc)
+		 * kmem_cache_alloc)... unless we race with interrupt also
+		 * consuming preloaded nodes.
 		 */
 		rtp = &__get_cpu_var(radix_tree_preloads);
+		/*
+		 * Disable interrupts to make sure radix_tree_node_alloc()
+		 * called from interrupt cannot return the same node as we do.
+		 */
+		local_irq_save(flags);
 		if (rtp->nr) {
 			ret = rtp->nodes[rtp->nr - 1];
 			rtp->nodes[rtp->nr - 1] = NULL;
 			rtp->nr--;
 		}
+		local_irq_restore(flags);
 	}
 	if (ret == NULL)
 		ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
@@ -269,6 +277,7 @@ int radix_tree_preload(gfp_t gfp_mask)
 	struct radix_tree_preload *rtp;
 	struct radix_tree_node *node;
 	int ret = -ENOMEM;
+	unsigned long flags;
 
 	preempt_disable();
 	rtp = &__get_cpu_var(radix_tree_preloads);
@@ -278,11 +287,15 @@ int radix_tree_preload(gfp_t gfp_mask)
 		if (node == NULL)
 			goto out;
 		preempt_disable();
+		local_irq_save(flags);
 		rtp = &__get_cpu_var(radix_tree_preloads);
-		if (rtp->nr < ARRAY_SIZE(rtp->nodes))
+		if (rtp->nr < ARRAY_SIZE(rtp->nodes)) {
 			rtp->nodes[rtp->nr++] = node;
-		else
+			local_irq_restore(flags);
+		} else {
+			local_irq_restore(flags);
 			kmem_cache_free(radix_tree_node_cachep, node);
+		}
 	}
 	ret = 0;
 out:
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
