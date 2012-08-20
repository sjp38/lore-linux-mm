Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 074306B0071
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 18:05:57 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so8652391pbb.14
        for <linux-mm@kvack.org>; Mon, 20 Aug 2012 15:05:57 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v3 9/9] rbtree: add RB_DECLARE_CALLBACKS() macro
Date: Mon, 20 Aug 2012 15:05:31 -0700
Message-Id: <1345500331-10546-10-git-send-email-walken@google.com>
In-Reply-To: <1345500331-10546-1-git-send-email-walken@google.com>
References: <1345500331-10546-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

As proposed by Peter Zijlstra, this makes it easier to define the augmented
rbtree callbacks.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 arch/x86/mm/pat_rbtree.c |   37 ++-----------------------------------
 include/linux/rbtree.h   |   30 ++++++++++++++++++++++++++++++
 lib/rbtree_test.c        |   34 ++--------------------------------
 3 files changed, 34 insertions(+), 67 deletions(-)

diff --git a/arch/x86/mm/pat_rbtree.c b/arch/x86/mm/pat_rbtree.c
index 7e1515bd4770..4d116959075d 100644
--- a/arch/x86/mm/pat_rbtree.c
+++ b/arch/x86/mm/pat_rbtree.c
@@ -69,41 +69,8 @@ static u64 compute_subtree_max_end(struct memtype *data)
 	return max_end;
 }
 
-/* Update 'subtree_max_end' for node and its parents */
-static void memtype_rb_propagate_cb(struct rb_node *node, struct rb_node *stop)
-{
-	while (node != stop) {
-		struct memtype *data = container_of(node, struct memtype, rb);
-		u64 subtree_max_end = compute_subtree_max_end(data);
-		if (data->subtree_max_end == subtree_max_end)
-			break;
-		data->subtree_max_end = subtree_max_end;
-		node = rb_parent(&data->rb);
-	}
-}
-
-static void memtype_rb_copy_cb(struct rb_node *old, struct rb_node *new)
-{
-	struct memtype *old_data = container_of(old, struct memtype, rb);
-	struct memtype *new_data = container_of(new, struct memtype, rb);
-
-	new_data->subtree_max_end = old_data->subtree_max_end;
-}
-
-/* Update 'subtree_max_end' after tree rotation. old and new are the
- * former and current subtree roots */
-static void memtype_rb_rotate_cb(struct rb_node *old, struct rb_node *new)
-{
-	struct memtype *old_data = container_of(old, struct memtype, rb);
-	struct memtype *new_data = container_of(new, struct memtype, rb);
-
-	new_data->subtree_max_end = old_data->subtree_max_end;
-	old_data->subtree_max_end = compute_subtree_max_end(old_data);
-}
-
-static const struct rb_augment_callbacks memtype_rb_augment_cb = {
-	memtype_rb_propagate_cb, memtype_rb_copy_cb, memtype_rb_rotate_cb
-};
+RB_DECLARE_CALLBACKS(static, memtype_rb_augment_cb, struct memtype, rb,
+		     u64, subtree_max_end, compute_subtree_max_end)
 
 /* Find the first (lowest start addr) overlapping range from rb tree */
 static struct memtype *memtype_rb_lowest_match(struct rb_root *root,
diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 4ace31b33380..8d1e83b1c87b 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -79,6 +79,36 @@ rb_insert_augmented(struct rb_node *node, struct rb_root *root,
 	__rb_insert_augmented(node, root, augment->rotate);
 }
 
+#define RB_DECLARE_CALLBACKS(rbstatic, rbname, rbstruct, rbfield,	      \
+			     rbtype, rbaugmented, rbcompute)		      \
+static void rbname ## _propagate(struct rb_node *rb, struct rb_node *stop)    \
+{									      \
+	while (rb != stop) {						      \
+		rbstruct *node = rb_entry(rb, rbstruct, rbfield);	      \
+		rbtype augmented = rbcompute(node);			      \
+		if (node->rbaugmented == augmented)			      \
+			break;						      \
+		node->rbaugmented = augmented;				      \
+		rb = rb_parent(&node->rbfield);				      \
+	}								      \
+}									      \
+static void rbname ## _copy(struct rb_node *rb_old, struct rb_node *rb_new)   \
+{									      \
+	rbstruct *old = rb_entry(rb_old, rbstruct, rbfield);		      \
+	rbstruct *new = rb_entry(rb_new, rbstruct, rbfield);		      \
+	new->rbaugmented = old->rbaugmented;				      \
+}									      \
+static void rbname ## _rotate(struct rb_node *rb_old, struct rb_node *rb_new) \
+{									      \
+	rbstruct *old = rb_entry(rb_old, rbstruct, rbfield);		      \
+	rbstruct *new = rb_entry(rb_new, rbstruct, rbfield);		      \
+	new->rbaugmented = old->rbaugmented;				      \
+	old->rbaugmented = rbcompute(old);				      \
+}									      \
+rbstatic const struct rb_augment_callbacks rbname = {			      \
+	rbname ## _propagate, rbname ## _copy, rbname ## _rotate	      \
+};
+
 
 /* Find logical next and previous nodes in a tree */
 extern struct rb_node *rb_next(const struct rb_node *);
diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
index e28345df09bf..b20e99969b0f 100644
--- a/lib/rbtree_test.c
+++ b/lib/rbtree_test.c
@@ -61,38 +61,8 @@ static inline u32 augment_recompute(struct test_node *node)
 	return max;
 }
 
-static void augment_propagate(struct rb_node *rb, struct rb_node *stop)
-{
-	while (rb != stop) {
-		struct test_node *node = rb_entry(rb, struct test_node, rb);
-		u32 augmented = augment_recompute(node);
-		if (node->augmented == augmented)
-			break;
-		node->augmented = augmented;
-		rb = rb_parent(&node->rb);
-	}
-}
-
-static void augment_copy(struct rb_node *rb_old, struct rb_node *rb_new)
-{
-	struct test_node *old = rb_entry(rb_old, struct test_node, rb);
-	struct test_node *new = rb_entry(rb_new, struct test_node, rb);
-	new->augmented = old->augmented;
-}
-
-static void augment_rotate(struct rb_node *rb_old, struct rb_node *rb_new)
-{
-	struct test_node *old = rb_entry(rb_old, struct test_node, rb);
-	struct test_node *new = rb_entry(rb_new, struct test_node, rb);
-
-	/* Rotation doesn't change subtree's augmented value */
-	new->augmented = old->augmented;
-	old->augmented = augment_recompute(old);
-}
-
-static const struct rb_augment_callbacks augment_callbacks = {
-	augment_propagate, augment_copy, augment_rotate
-};
+RB_DECLARE_CALLBACKS(static, augment_callbacks, struct test_node, rb,
+		     u32, augmented, augment_recompute)
 
 static void insert_augmented(struct test_node *node, struct rb_root *root)
 {
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
