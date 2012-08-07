Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 11E526B0044
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 03:12:16 -0400 (EDT)
Received: by pbbjt11 with SMTP id jt11so3931195pbb.14
        for <linux-mm@kvack.org>; Tue, 07 Aug 2012 00:12:15 -0700 (PDT)
Date: Tue, 7 Aug 2012 00:12:11 -0700
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH] rbtree: add RB_DECLARE_CALLBACKS() macro
Message-ID: <20120807071211.GA1278@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
 <1343946858-8170-9-git-send-email-walken@google.com>
 <1344262669.27828.55.camel@twins>
 <1344267537.27828.93.camel@twins>
 <CANN689HKPKeZ-sqqwXGPhv=Jno4c=v=ffeOxLPkOFmMzEVXexw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689HKPKeZ-sqqwXGPhv=Jno4c=v=ffeOxLPkOFmMzEVXexw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

This proposed patch goes after 9/9 of my previous submission and makes it
easier to define the augmented rbtree callbacks.

Peter, does this fix the concern you raised over patch 8/9 ?

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/x86/mm/pat_rbtree.c |   37 ++-----------------------------------
 include/linux/rbtree.h   |   30 ++++++++++++++++++++++++++++++
 lib/rbtree_test.c        |   34 ++--------------------------------
 3 files changed, 34 insertions(+), 67 deletions(-)

diff --git a/arch/x86/mm/pat_rbtree.c b/arch/x86/mm/pat_rbtree.c
index 7e1515b..4d11695 100644
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
index 4ace31b..8d1e83b 100644
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
index e28345d..b20e999 100644
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
