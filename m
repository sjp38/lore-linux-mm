Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 66D806B0062
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 03:26:01 -0400 (EDT)
Received: by pbbjt11 with SMTP id jt11so3954282pbb.14
        for <linux-mm@kvack.org>; Tue, 07 Aug 2012 00:26:00 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 1/5] rbtree: add prio tree and interval tree tests
Date: Tue,  7 Aug 2012 00:25:39 -0700
Message-Id: <1344324343-3817-2-git-send-email-walken@google.com>
In-Reply-To: <1344324343-3817-1-git-send-email-walken@google.com>
References: <1344324343-3817-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, vrajesh@umich.edu, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

This adds two test modules:

- prio_tree_test measures the performance of lib/prio_tree.c, both for
  insertion/removal and for stabbing searches

- interval_tree_test measures the performance of a library of equivalent
  functionality, built using the augmented rbtree support.

In order to support the second test module, lib/interval_tree.c is
introduced. It is kept separate from the interval_tree_test main file
for two reasons: first we don't want to provide an unfair advantage
over prio_tree_test by having everything in a single compilation unit,
and second there is the possibility that the interval tree functionality
could get some non-test users in kernel over time.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/interval_tree.h |   27 +++++++
 lib/Kconfig.debug             |   12 +++
 lib/Makefile                  |    4 +
 lib/interval_tree.c           |  159 +++++++++++++++++++++++++++++++++++++++++
 lib/interval_tree_test_main.c |  105 +++++++++++++++++++++++++++
 lib/prio_tree.c               |    4 +
 lib/prio_tree_test.c          |  106 +++++++++++++++++++++++++++
 7 files changed, 417 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/interval_tree.h
 create mode 100644 lib/interval_tree.c
 create mode 100644 lib/interval_tree_test_main.c
 create mode 100644 lib/prio_tree_test.c

diff --git a/include/linux/interval_tree.h b/include/linux/interval_tree.h
new file mode 100644
index 0000000..724556a
--- /dev/null
+++ b/include/linux/interval_tree.h
@@ -0,0 +1,27 @@
+#ifndef _LINUX_INTERVAL_TREE_H
+#define _LINUX_INTERVAL_TREE_H
+
+#include <linux/rbtree.h>
+
+struct interval_tree_node {
+	struct rb_node rb;
+	unsigned long start;	/* Start of interval */
+	unsigned long last;	/* Last location _in_ interval */
+	unsigned long __subtree_last;
+};
+
+extern void
+interval_tree_insert(struct interval_tree_node *node, struct rb_root *root);
+
+extern void
+interval_tree_remove(struct interval_tree_node *node, struct rb_root *root);
+
+extern struct interval_tree_node *
+interval_tree_iter_first(struct rb_root *root,
+			 unsigned long start, unsigned long last);
+
+extern struct interval_tree_node *
+interval_tree_iter_next(struct interval_tree_node *node,
+			unsigned long start, unsigned long last);
+
+#endif	/* _LINUX_INTERVAL_TREE_H */
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index d751431..331c64d 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1185,6 +1185,18 @@ config RBTREE_TEST
 	  A benchmark measuring the performance of the rbtree library.
 	  Also includes rbtree invariant checks.
 
+config PRIO_TREE_TEST
+	tristate "Prio tree test"
+	depends on m && DEBUG_KERNEL
+	help
+	  A benchmark measuring the performance of the prio tree library
+
+config INTERVAL_TREE_TEST
+	tristate "Interval tree test"
+	depends on m && DEBUG_KERNEL
+	help
+	  A benchmark measuring the performance of the interval tree library
+
 config PROVIDE_OHCI1394_DMA_INIT
 	bool "Remote debugging over FireWire early on boot"
 	depends on PCI && X86
diff --git a/lib/Makefile b/lib/Makefile
index 9c5c529..e1f109f 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -131,6 +131,10 @@ obj-$(CONFIG_GENERIC_STRNLEN_USER) += strnlen_user.o
 obj-$(CONFIG_STMP_DEVICE) += stmp_device.o
 
 obj-$(CONFIG_RBTREE_TEST) += rbtree_test.o
+obj-$(CONFIG_PRIO_TREE_TEST) += prio_tree_test.o
+obj-$(CONFIG_INTERVAL_TREE_TEST) += interval_tree_test.o
+
+interval_tree_test-objs := interval_tree_test_main.o interval_tree.o
 
 hostprogs-y	:= gen_crc32table
 clean-files	:= crc32table.h
diff --git a/lib/interval_tree.c b/lib/interval_tree.c
new file mode 100644
index 0000000..6fd540b
--- /dev/null
+++ b/lib/interval_tree.c
@@ -0,0 +1,159 @@
+#include <linux/init.h>
+#include <linux/interval_tree.h>
+
+/* Callbacks for augmented rbtree insert and remove */
+
+static inline unsigned long
+compute_subtree_last(struct interval_tree_node *node)
+{
+	unsigned long max = node->last, subtree_last;
+	if (node->rb.rb_left) {
+		subtree_last = rb_entry(node->rb.rb_left,
+			struct interval_tree_node, rb)->__subtree_last;
+		if (max < subtree_last)
+			max = subtree_last;
+	}
+	if (node->rb.rb_right) {
+		subtree_last = rb_entry(node->rb.rb_right,
+			struct interval_tree_node, rb)->__subtree_last;
+		if (max < subtree_last)
+			max = subtree_last;
+	}
+	return max;
+}
+
+RB_DECLARE_CALLBACKS(static, augment_callbacks, struct interval_tree_node, rb,
+		     unsigned long, __subtree_last, compute_subtree_last)
+
+/* Insert / remove interval nodes from the tree */
+
+void interval_tree_insert(struct interval_tree_node *node,
+			  struct rb_root *root)
+{
+	struct rb_node **link = &root->rb_node, *rb_parent = NULL;
+	unsigned long start = node->start, last = node->last;
+	struct interval_tree_node *parent;
+
+	while (*link) {
+		rb_parent = *link;
+		parent = rb_entry(rb_parent, struct interval_tree_node, rb);
+		if (parent->__subtree_last < last)
+			parent->__subtree_last = last;
+		if (start < parent->start)
+			link = &parent->rb.rb_left;
+		else
+			link = &parent->rb.rb_right;
+	}
+
+	node->__subtree_last = last;
+	rb_link_node(&node->rb, rb_parent, link);
+	rb_insert_augmented(&node->rb, root, &augment_callbacks);
+}
+
+void interval_tree_remove(struct interval_tree_node *node,
+			  struct rb_root *root)
+{
+	rb_erase_augmented(&node->rb, root, &augment_callbacks);
+}
+
+/*
+ * Iterate over intervals intersecting [start;last]
+ *
+ * Note that a node's interval intersects [start;last] iff:
+ *   Cond1: node->start <= last
+ * and
+ *   Cond2: start <= node->last
+ */
+
+static struct interval_tree_node *
+subtree_search(struct interval_tree_node *node,
+	       unsigned long start, unsigned long last)
+{
+	while (true) {
+		/*
+		 * Loop invariant: start <= node->__subtree_last
+		 * (Cond2 is satisfied by one of the subtree nodes)
+		 */
+		if (node->rb.rb_left) {
+			struct interval_tree_node *left =
+				rb_entry(node->rb.rb_left,
+					 struct interval_tree_node, rb);
+			if (start <= left->__subtree_last) {
+				/*
+				 * Some nodes in left subtree satisfy Cond2.
+				 * Iterate to find the leftmost such node N.
+				 * If it also satisfies Cond1, that's the match
+				 * we are looking for. Otherwise, there is no
+				 * matching interval as nodes to the right of N
+				 * can't satisfy Cond1 either.
+				 */
+				node = left;
+				continue;
+			}
+		}
+		if (node->start <= last) {		/* Cond1 */
+			if (start <= node->last)	/* Cond2 */
+				return node;	/* node is leftmost match */
+			if (node->rb.rb_right) {
+				node = rb_entry(node->rb.rb_right,
+					struct interval_tree_node, rb);
+				if (start <= node->__subtree_last)
+					continue;
+			}
+		}
+		return NULL;	/* No match */
+	}
+}
+
+struct interval_tree_node *
+interval_tree_iter_first(struct rb_root *root,
+			 unsigned long start, unsigned long last)
+{
+	struct interval_tree_node *node;
+
+	if (!root->rb_node)
+		return NULL;
+	node = rb_entry(root->rb_node, struct interval_tree_node, rb);
+	if (node->__subtree_last < start)
+		return NULL;
+	return subtree_search(node, start, last);
+}
+
+struct interval_tree_node *
+interval_tree_iter_next(struct interval_tree_node *node,
+			unsigned long start, unsigned long last)
+{
+	struct rb_node *rb = node->rb.rb_right, *prev;
+
+	while (true) {
+		/*
+		 * Loop invariants:
+		 *   Cond1: node->start <= last
+		 *   rb == node->rb.rb_right
+		 *
+		 * First, search right subtree if suitable
+		 */
+		if (rb) {
+			struct interval_tree_node *right =
+				rb_entry(rb, struct interval_tree_node, rb);
+			if (start <= right->__subtree_last)
+				return subtree_search(right, start, last);
+		}
+
+		/* Move up the tree until we come from a node's left child */
+		do {
+			rb = rb_parent(&node->rb);
+			if (!rb)
+				return NULL;
+			prev = &node->rb;
+			node = rb_entry(rb, struct interval_tree_node, rb);
+			rb = node->rb.rb_right;
+		} while (prev == rb);
+
+		/* Check if the node intersects [start;last] */
+		if (last < node->start)		/* !Cond1 */
+			return NULL;
+		else if (start <= node->last)	/* Cond2 */
+			return node;
+	}
+}
diff --git a/lib/interval_tree_test_main.c b/lib/interval_tree_test_main.c
new file mode 100644
index 0000000..b259039
--- /dev/null
+++ b/lib/interval_tree_test_main.c
@@ -0,0 +1,105 @@
+#include <linux/module.h>
+#include <linux/interval_tree.h>
+#include <linux/random.h>
+#include <asm/timex.h>
+
+#define NODES        100
+#define PERF_LOOPS   100000
+#define SEARCHES     100
+#define SEARCH_LOOPS 10000
+
+static struct rb_root root = RB_ROOT;
+static struct interval_tree_node nodes[NODES];
+static u32 queries[SEARCHES];
+
+static struct rnd_state rnd;
+
+static inline unsigned long
+search(unsigned long query, struct rb_root *root)
+{
+	struct interval_tree_node *node;
+	unsigned long results = 0;
+
+	for (node = interval_tree_iter_first(root, query, query); node;
+	     node = interval_tree_iter_next(node, query, query))
+		results++;
+	return results;
+}
+
+static void init(void)
+{
+	int i;
+	for (i = 0; i < NODES; i++) {
+		u32 a = prandom32(&rnd), b = prandom32(&rnd);
+		if (a <= b) {
+			nodes[i].start = a;
+			nodes[i].last = b;
+		} else {
+			nodes[i].start = b;
+			nodes[i].last = a;
+		}
+	}
+	for (i = 0; i < SEARCHES; i++)
+		queries[i] = prandom32(&rnd);
+}
+
+static int interval_tree_test_init(void)
+{
+	int i, j;
+	unsigned long results;
+	cycles_t time1, time2, time;
+
+	printk(KERN_ALERT "interval tree insert/remove");
+
+	prandom32_seed(&rnd, 3141592653589793238ULL);
+	init();
+
+	time1 = get_cycles();
+
+	for (i = 0; i < PERF_LOOPS; i++) {
+		for (j = 0; j < NODES; j++)
+			interval_tree_insert(nodes + j, &root);
+		for (j = 0; j < NODES; j++)
+			interval_tree_remove(nodes + j, &root);
+	}
+
+	time2 = get_cycles();
+	time = time2 - time1;
+
+	time = div_u64(time, PERF_LOOPS);
+	printk(" -> %llu cycles\n", (unsigned long long)time);
+
+	printk(KERN_ALERT "interval tree search");
+
+	for (j = 0; j < NODES; j++)
+		interval_tree_insert(nodes + j, &root);
+
+	time1 = get_cycles();
+
+	results = 0;
+	for (i = 0; i < SEARCH_LOOPS; i++)
+		for (j = 0; j < SEARCHES; j++)
+			results += search(queries[j], &root);
+
+	time2 = get_cycles();
+	time = time2 - time1;
+
+	time = div_u64(time, SEARCH_LOOPS);
+	results = div_u64(results, SEARCH_LOOPS);
+	printk(" -> %llu cycles (%lu results)\n",
+	       (unsigned long long)time, results);
+
+	return -EAGAIN; /* Fail will directly unload the module */
+}
+
+static void interval_tree_test_exit(void)
+{
+	printk(KERN_ALERT "test exit\n");
+}
+
+module_init(interval_tree_test_init)
+module_exit(interval_tree_test_exit)
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Michel Lespinasse");
+MODULE_DESCRIPTION("Interval Tree test");
diff --git a/lib/prio_tree.c b/lib/prio_tree.c
index 8d443af..4e0d2ed 100644
--- a/lib/prio_tree.c
+++ b/lib/prio_tree.c
@@ -14,6 +14,7 @@
 #include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/prio_tree.h>
+#include <linux/export.h>
 
 /*
  * A clever mix of heap and radix trees forms a radix priority search tree (PST)
@@ -241,6 +242,7 @@ struct prio_tree_node *prio_tree_insert(struct prio_tree_root *root,
 	BUG();
 	return NULL;
 }
+EXPORT_SYMBOL(prio_tree_insert);
 
 /*
  * Remove a prio_tree_node @node from a radix priority search tree @root. The
@@ -290,6 +292,7 @@ void prio_tree_remove(struct prio_tree_root *root, struct prio_tree_node *node)
 	while (cur != node)
 		cur = prio_tree_replace(root, cur->parent, cur);
 }
+EXPORT_SYMBOL(prio_tree_remove);
 
 static void iter_walk_down(struct prio_tree_iter *iter)
 {
@@ -464,3 +467,4 @@ repeat:
 
 	goto repeat;
 }
+EXPORT_SYMBOL(prio_tree_next);
diff --git a/lib/prio_tree_test.c b/lib/prio_tree_test.c
new file mode 100644
index 0000000..c26084d
--- /dev/null
+++ b/lib/prio_tree_test.c
@@ -0,0 +1,106 @@
+#include <linux/module.h>
+#include <linux/prio_tree.h>
+#include <linux/random.h>
+#include <asm/timex.h>
+
+#define NODES        100
+#define PERF_LOOPS   100000
+#define SEARCHES     100
+#define SEARCH_LOOPS 10000
+
+static struct prio_tree_root root;
+static struct prio_tree_node nodes[NODES];
+static u32 queries[SEARCHES];
+
+static struct rnd_state rnd;
+
+static inline unsigned long
+search(unsigned long query, struct prio_tree_root *root)
+{
+	struct prio_tree_iter iter;
+	unsigned long results = 0;
+
+	prio_tree_iter_init(&iter, root, query, query);
+	while (prio_tree_next(&iter))
+		results++;
+	return results;
+}
+
+static void init(void)
+{
+	int i;
+	for (i = 0; i < NODES; i++) {
+		u32 a = prandom32(&rnd), b = prandom32(&rnd);
+		if (a <= b) {
+			nodes[i].start = a;
+			nodes[i].last = b;
+		} else {
+			nodes[i].start = b;
+			nodes[i].last = a;
+		}
+	}
+	for (i = 0; i < SEARCHES; i++)
+		queries[i] = prandom32(&rnd);
+}
+
+static int prio_tree_test_init(void)
+{
+	int i, j;
+	unsigned long results;
+	cycles_t time1, time2, time;
+
+	printk(KERN_ALERT "prio tree insert/remove");
+
+	prandom32_seed(&rnd, 3141592653589793238ULL);
+	INIT_PRIO_TREE_ROOT(&root);
+	init();
+
+	time1 = get_cycles();
+
+	for (i = 0; i < PERF_LOOPS; i++) {
+		for (j = 0; j < NODES; j++)
+			prio_tree_insert(&root, nodes + j);
+		for (j = 0; j < NODES; j++)
+			prio_tree_remove(&root, nodes + j);
+	}
+
+	time2 = get_cycles();
+	time = time2 - time1;
+
+	time = div_u64(time, PERF_LOOPS);
+	printk(" -> %llu cycles\n", (unsigned long long)time);
+
+	printk(KERN_ALERT "prio tree search");
+
+	for (j = 0; j < NODES; j++)
+		prio_tree_insert(&root, nodes + j);
+
+	time1 = get_cycles();
+
+	results = 0;
+	for (i = 0; i < SEARCH_LOOPS; i++)
+		for (j = 0; j < SEARCHES; j++)
+			results += search(queries[j], &root);
+
+	time2 = get_cycles();
+	time = time2 - time1;
+
+	time = div_u64(time, SEARCH_LOOPS);
+	results = div_u64(results, SEARCH_LOOPS);
+	printk(" -> %llu cycles (%lu results)\n",
+	       (unsigned long long)time, results);
+
+	return -EAGAIN; /* Fail will directly unload the module */
+}
+
+static void prio_tree_test_exit(void)
+{
+	printk(KERN_ALERT "test exit\n");
+}
+
+module_init(prio_tree_test_init)
+module_exit(prio_tree_test_exit)
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Michel Lespinasse");
+MODULE_DESCRIPTION("Prio Tree test");
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
