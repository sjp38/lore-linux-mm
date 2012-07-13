Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 751DA6B005A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 19:11:38 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7479351pbb.14
        for <linux-mm@kvack.org>; Fri, 13 Jul 2012 16:11:37 -0700 (PDT)
Date: Fri, 13 Jul 2012 16:11:34 -0700
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 05/12] rbtree: performance and correctness test
Message-ID: <20120713231134.GA3269@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
 <1342139517-3451-6-git-send-email-walken@google.com>
 <20120713131514.86ab4df4.akpm@linux-foundation.org>
 <CANN689FUm83vGFVF30Lg52_28vxdY+mZ88jVCGpmVfiHiHwNtg@mail.gmail.com>
 <20120713154519.60a686e8.akpm@linux-foundation.org>
 <CANN689HSZqpsiOAMpKe_4=TWNhv7YPkiE5pqpnq1QQKkCiHm6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689HSZqpsiOAMpKe_4=TWNhv7YPkiE5pqpnq1QQKkCiHm6Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

This small module helps measure the performance of rbtree insert and erase.

Additionally, we run a few correctness tests to check that the rbtrees have
all desired properties:
- contains the right number of nodes in the order desired,
- never two consecutive red nodes on any path,
- all paths to leaf nodes have the same number of black nodes,
- root node is black

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 lib/Kconfig.debug |    7 +++
 lib/Makefile      |    2 +
 lib/rbtree_test.c |  135 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 144 insertions(+), 0 deletions(-)
 create mode 100644 lib/rbtree_test.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 6777153..736f564 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1145,6 +1145,13 @@ config LATENCYTOP
 source mm/Kconfig.debug
 source kernel/trace/Kconfig
 
+config RBTREE_TEST
+	tristate "Red-Black tree test"
+	depends on m && DEBUG_KERNEL
+	help
+	  A benchmark measuring the performance of the rbtree library.
+	  Also includes rbtree invariant checks.
+
 config PROVIDE_OHCI1394_DMA_INIT
 	bool "Remote debugging over FireWire early on boot"
 	depends on PCI && X86
diff --git a/lib/Makefile b/lib/Makefile
index 18515f0..4899899 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -123,6 +123,8 @@ obj-$(CONFIG_SIGNATURE) += digsig.o
 
 obj-$(CONFIG_CLZ_TAB) += clz_tab.o
 
+obj-$(CONFIG_RBTREE_TEST) += rbtree_test.o
+
 hostprogs-y	:= gen_crc32table
 clean-files	:= crc32table.h
 
diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
new file mode 100644
index 0000000..4c6d250
--- /dev/null
+++ b/lib/rbtree_test.c
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
