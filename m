Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id A442B6B0073
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 18:05:53 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so8652391pbb.14
        for <linux-mm@kvack.org>; Mon, 20 Aug 2012 15:05:53 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v3 6/9] rbtree: augmented rbtree test
Date: Mon, 20 Aug 2012 15:05:28 -0700
Message-Id: <1345500331-10546-7-git-send-email-walken@google.com>
In-Reply-To: <1345500331-10546-1-git-send-email-walken@google.com>
References: <1345500331-10546-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Small test to measure the performance of augmented rbtrees.

Signed-off-by: Michel Lespinasse <walken@google.com>
Acked-by: Rik van Riel <riel@redhat.com>

---
 lib/rbtree_test.c |  103 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 101 insertions(+), 2 deletions(-)

diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
index fd09465d82ca..66e41d4bfc39 100644
--- a/lib/rbtree_test.c
+++ b/lib/rbtree_test.c
@@ -10,6 +10,10 @@
 struct test_node {
 	struct rb_node rb;
 	u32 key;
+
+	/* following fields used for testing augmented rbtree functionality */
+	u32 val;
+	u32 augmented;
 };
 
 static struct rb_root root = RB_ROOT;
@@ -20,10 +24,11 @@ static struct rnd_state rnd;
 static void insert(struct test_node *node, struct rb_root *root)
 {
 	struct rb_node **new = &root->rb_node, *parent = NULL;
+	u32 key = node->key;
 
 	while (*new) {
 		parent = *new;
-		if (node->key < rb_entry(parent, struct test_node, rb)->key)
+		if (key < rb_entry(parent, struct test_node, rb)->key)
 			new = &parent->rb_left;
 		else
 			new = &parent->rb_right;
@@ -38,11 +43,62 @@ static inline void erase(struct test_node *node, struct rb_root *root)
 	rb_erase(&node->rb, root);
 }
 
+static inline u32 augment_recompute(struct test_node *node)
+{
+	u32 max = node->val, child_augmented;
+	if (node->rb.rb_left) {
+		child_augmented = rb_entry(node->rb.rb_left, struct test_node,
+					   rb)->augmented;
+		if (max < child_augmented)
+			max = child_augmented;
+	}
+	if (node->rb.rb_right) {
+		child_augmented = rb_entry(node->rb.rb_right, struct test_node,
+					   rb)->augmented;
+		if (max < child_augmented)
+			max = child_augmented;
+	}
+	return max;
+}
+
+static void augment_callback(struct rb_node *rb, void *unused)
+{
+	struct test_node *node = rb_entry(rb, struct test_node, rb);
+	node->augmented = augment_recompute(node);
+}
+
+static void insert_augmented(struct test_node *node, struct rb_root *root)
+{
+	struct rb_node **new = &root->rb_node, *parent = NULL;
+	u32 key = node->key;
+
+	while (*new) {
+		parent = *new;
+		if (key < rb_entry(parent, struct test_node, rb)->key)
+			new = &parent->rb_left;
+		else
+			new = &parent->rb_right;
+	}
+
+	rb_link_node(&node->rb, parent, new);
+	rb_insert_color(&node->rb, root);
+	rb_augment_insert(&node->rb, augment_callback, NULL);
+}
+
+static void erase_augmented(struct test_node *node, struct rb_root *root)
+{
+	struct rb_node *deepest = rb_augment_erase_begin(&node->rb);
+	rb_erase(&node->rb, root);
+	rb_augment_erase_end(deepest, augment_callback, NULL);
+}
+
 static void init(void)
 {
 	int i;
-	for (i = 0; i < NODES; i++)
+	for (i = 0; i < NODES; i++) {
 		nodes[i].key = prandom32(&rnd);
+		nodes[i].val = prandom32(&rnd);
+	}
 }
 
 static bool is_red(struct rb_node *rb)
@@ -81,6 +137,17 @@ static void check(int nr_nodes)
 	WARN_ON_ONCE(count != nr_nodes);
 }
 
+static void check_augmented(int nr_nodes)
+{
+	struct rb_node *rb;
+
+	check(nr_nodes);
+	for (rb = rb_first(&root); rb; rb = rb_next(rb)) {
+		struct test_node *node = rb_entry(rb, struct test_node, rb);
+		WARN_ON_ONCE(node->augmented != augment_recompute(node));
+	}
+}
+
 static int rbtree_test_init(void)
 {
 	int i, j;
@@ -119,6 +186,38 @@ static int rbtree_test_init(void)
 		check(0);
 	}
 
+	printk(KERN_ALERT "augmented rbtree testing");
+
+	init();
+
+	time1 = get_cycles();
+
+	for (i = 0; i < PERF_LOOPS; i++) {
+		for (j = 0; j < NODES; j++)
+			insert_augmented(nodes + j, &root);
+		for (j = 0; j < NODES; j++)
+			erase_augmented(nodes + j, &root);
+	}
+
+	time2 = get_cycles();
+	time = time2 - time1;
+
+	time = div_u64(time, PERF_LOOPS);
+	printk(" -> %llu cycles\n", (unsigned long long)time);
+
+	for (i = 0; i < CHECK_LOOPS; i++) {
+		init();
+		for (j = 0; j < NODES; j++) {
+			check_augmented(j);
+			insert_augmented(nodes + j, &root);
+		}
+		for (j = 0; j < NODES; j++) {
+			check_augmented(NODES - j);
+			erase_augmented(nodes + j, &root);
+		}
+		check_augmented(0);
+	}
+
 	return -EAGAIN; /* Fail will directly unload the module */
 }
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
