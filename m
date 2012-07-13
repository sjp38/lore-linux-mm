Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 6A6376B0072
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:32:48 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so5512005pbb.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:32:48 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 05/12] rbtree: performance and correctness test
Date: Thu, 12 Jul 2012 17:31:50 -0700
Message-Id: <1342139517-3451-6-git-send-email-walken@google.com>
In-Reply-To: <1342139517-3451-1-git-send-email-walken@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

This small module helps measure the performance of rbtree insert and erase.

Additionally, we run a few correctness tests to check that the rbtrees have
all desired properties:
- contains the right number of nodes in the order desired,
- never two consecutive red nodes on any path,
- all paths to leaf nodes have the same number of black nodes,
- root node is black

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 Makefile            |    2 +-
 lib/Kconfig.debug   |    1 +
 tests/Kconfig       |   18 +++++++
 tests/Makefile      |    1 +
 tests/rbtree_test.c |  135 +++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 156 insertions(+), 1 deletions(-)
 create mode 100644 tests/Kconfig
 create mode 100644 tests/Makefile
 create mode 100644 tests/rbtree_test.c

diff --git a/Makefile b/Makefile
index a687963..7bef085 100644
--- a/Makefile
+++ b/Makefile
@@ -708,7 +708,7 @@ export mod_strip_cmd
 
 
 ifeq ($(KBUILD_EXTMOD),)
-core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
+core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ tests/
 
 vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
 		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 6777153..b148fa1 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1144,6 +1144,7 @@ config LATENCYTOP
 
 source mm/Kconfig.debug
 source kernel/trace/Kconfig
+source tests/Kconfig
 
 config PROVIDE_OHCI1394_DMA_INIT
 	bool "Remote debugging over FireWire early on boot"
diff --git a/tests/Kconfig b/tests/Kconfig
new file mode 100644
index 0000000..ceca7ba
--- /dev/null
+++ b/tests/Kconfig
@@ -0,0 +1,18 @@
+menuconfig BENCHMARKS
+	bool "In kernel benchmarks"
+	def_bool n
+	help
+	  Includes in kernel benchmark modules in the build. These modules can
+	  be loaded later to trigger benchmarking kernel subsystems.
+	  Output will be generated in the system log.
+
+if BENCHMARKS
+
+config BENCHMARK_RBTREE
+	tristate "Red Black Tree Benchmark"
+	depends on m
+	default m
+	help
+	  A benchmark measuring the performance of the rbtree library.
+
+endif # BENCHMARKS
diff --git a/tests/Makefile b/tests/Makefile
new file mode 100644
index 0000000..440b77c
--- /dev/null
+++ b/tests/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_BENCHMARK_RBTREE) += rbtree_test.o
diff --git a/tests/rbtree_test.c b/tests/rbtree_test.c
new file mode 100644
index 0000000..4c6d250
--- /dev/null
+++ b/tests/rbtree_test.c
@@ -0,0 +1,135 @@
+#include <linux/module.h>
+#include <linux/rbtree.h>
+#include <linux/random.h>
+#include <asm/timex.h>
+
+#define NODES       100
+#define PERF_LOOPS  100000
+#define CHECK_LOOPS 100
+
+struct test_node {
+	struct rb_node rb;
+	u32 key;
+};
+
+static struct rb_root root = RB_ROOT;
+static struct test_node nodes[NODES];
+
+static struct rnd_state rnd;
+
+static void insert(struct test_node *node, struct rb_root *root)
+{
+	struct rb_node **new = &root->rb_node, *parent = NULL;
+
+	while (*new) {
+		parent = *new;
+		if (node->key < rb_entry(parent, struct test_node, rb)->key)
+			new = &parent->rb_left;
+		else
+			new = &parent->rb_right;
+	}
+
+	rb_link_node(&node->rb, parent, new);
+	rb_insert_color(&node->rb, root);
+}
+
+static inline void erase(struct test_node *node, struct rb_root *root)
+{
+	rb_erase(&node->rb, root);
+}
+
+static void init(void)
+{
+	int i;
+	for (i = 0; i < NODES; i++)
+		nodes[i].key = prandom32(&rnd);
+}
+
+static bool is_red(struct rb_node *rb)
+{
+	return !(rb->__rb_parent_color & 1);
+}
+
+static int black_path_count(struct rb_node *rb)
+{
+	int count;
+	for (count = 0; rb; rb = rb_parent(rb))
+		count += !is_red(rb);
+	return count;
+}
+
+static void check(int nr_nodes)
+{
+	struct rb_node *rb;
+	int count = 0;
+	int blacks;
+	u32 prev_key = 0;
+
+	for (rb = rb_first(&root); rb; rb = rb_next(rb)) {
+		struct test_node *node = rb_entry(rb, struct test_node, rb);
+		WARN_ON_ONCE(node->key < prev_key);
+		WARN_ON_ONCE(is_red(rb) &&
+			     (!rb_parent(rb) || is_red(rb_parent(rb))));
+		if (!count)
+			blacks = black_path_count(rb);
+		else
+			WARN_ON_ONCE((!rb->rb_left || !rb->rb_right) &&
+				     blacks != black_path_count(rb));
+		prev_key = node->key;
+		count++;
+	}
+	WARN_ON_ONCE(count != nr_nodes);
+}
+
+static int rbtree_test_init(void)
+{
+	int i, j;
+	cycles_t time1, time2, time;
+
+	printk(KERN_ALERT "rbtree testing");
+
+	prandom32_seed(&rnd, 3141592653589793238);
+	init();
+
+	time1 = get_cycles();
+
+	for (i = 0; i < PERF_LOOPS; i++) {
+		for (j = 0; j < NODES; j++)
+			insert(nodes + j, &root);
+		for (j = 0; j < NODES; j++)
+			erase(nodes + j, &root);
+	}
+
+	time2 = get_cycles();
+	time = time2 - time1;
+
+	time = div_u64(time, PERF_LOOPS);
+	printk(" -> %llu cycles\n", time);
+
+	for (i = 0; i < CHECK_LOOPS; i++) {
+		init();
+		for (j = 0; j < NODES; j++) {
+			check(j);
+			insert(nodes + j, &root);
+		}
+		for (j = 0; j < NODES; j++) {
+			check(NODES - j);
+			erase(nodes + j, &root);
+		}
+		check(0);
+	}
+
+	return -EAGAIN; /* Fail will directly unload the module */
+}
+
+static void rbtree_test_exit(void)
+{
+	printk(KERN_ALERT "test exit\n");
+}
+
+module_init(rbtree_test_init)
+module_exit(rbtree_test_exit)
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Michel Lespinasse");
+MODULE_DESCRIPTION("Red Black Tree test");
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
