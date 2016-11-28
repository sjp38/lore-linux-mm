Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFA2F6B02DA
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:43 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id c21so252677193ioj.5
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:43 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id s139si19997601itb.41.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 08/33] radix tree test suite: benchmark for iterator
Date: Mon, 28 Nov 2016 13:50:12 -0800
Message-Id: <1480369871-5271-9-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>

From: Konstantin Khlebnikov <koct9i@gmail.com>

This adds simple benchmark for iterator similar to one I've used for
commit 78c1d78 ("radix-tree: introduce bit-optimized iterator")

Building with make BENCHMARK=1 set radix tree order to 6, this allows
to get performance comparable to in kernel performance.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/Makefile       |  6 +-
 tools/testing/radix-tree/benchmark.c    | 98 +++++++++++++++++++++++++++++++++
 tools/testing/radix-tree/linux/kernel.h |  4 ++
 tools/testing/radix-tree/main.c         |  2 +
 tools/testing/radix-tree/test.h         |  1 +
 5 files changed, 110 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/radix-tree/benchmark.c

diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index 3c338dc..08283a8 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -4,7 +4,11 @@ LDFLAGS += -lpthread -lurcu
 TARGETS = main
 OFILES = main.o radix-tree.o linux.o test.o tag_check.o find_next_bit.o \
 	 regression1.o regression2.o regression3.o multiorder.o \
-	 iteration_check.o
+	 iteration_check.o benchmark.o
+
+ifdef BENCHMARK
+	CFLAGS += -DBENCHMARK=1
+endif
 
 targets: $(TARGETS)
 
diff --git a/tools/testing/radix-tree/benchmark.c b/tools/testing/radix-tree/benchmark.c
new file mode 100644
index 0000000..215ca86
--- /dev/null
+++ b/tools/testing/radix-tree/benchmark.c
@@ -0,0 +1,98 @@
+/*
+ * benchmark.c:
+ * Author: Konstantin Khlebnikov <koct9i@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+#include <linux/radix-tree.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+#include <time.h>
+#include "test.h"
+
+#define NSEC_PER_SEC	1000000000L
+
+static long long benchmark_iter(struct radix_tree_root *root, bool tagged)
+{
+	volatile unsigned long sink = 0;
+	struct radix_tree_iter iter;
+	struct timespec start, finish;
+	long long nsec;
+	int l, loops = 1;
+	void **slot;
+
+#ifdef BENCHMARK
+again:
+#endif
+	clock_gettime(CLOCK_MONOTONIC, &start);
+	for (l = 0; l < loops; l++) {
+		if (tagged) {
+			radix_tree_for_each_tagged(slot, root, &iter, 0, 0)
+				sink ^= (unsigned long)slot;
+		} else {
+			radix_tree_for_each_slot(slot, root, &iter, 0)
+				sink ^= (unsigned long)slot;
+		}
+	}
+	clock_gettime(CLOCK_MONOTONIC, &finish);
+
+	nsec = (finish.tv_sec - start.tv_sec) * NSEC_PER_SEC +
+	       (finish.tv_nsec - start.tv_nsec);
+
+#ifdef BENCHMARK
+	if (loops == 1 && nsec * 5 < NSEC_PER_SEC) {
+		loops = NSEC_PER_SEC / nsec / 4 + 1;
+		goto again;
+	}
+#endif
+
+	nsec /= loops;
+	return nsec;
+}
+
+static void benchmark_size(unsigned long size, unsigned long step, int order)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	long long normal, tagged;
+	unsigned long index;
+
+	for (index = 0 ; index < size ; index += step) {
+		item_insert_order(&tree, index, order);
+		radix_tree_tag_set(&tree, index, 0);
+	}
+
+	tagged = benchmark_iter(&tree, true);
+	normal = benchmark_iter(&tree, false);
+
+	printf("Size %ld, step %6ld, order %d tagged %10lld ns, normal %10lld ns\n",
+		size, step, order, tagged, normal);
+
+	item_kill_tree(&tree);
+	rcu_barrier();
+}
+
+void benchmark(void)
+{
+	unsigned long size[] = {1 << 10, 1 << 20, 0};
+	unsigned long step[] = {1, 2, 7, 15, 63, 64, 65,
+				128, 256, 512, 12345, 0};
+	int c, s;
+
+	printf("starting benchmarks\n");
+	printf("RADIX_TREE_MAP_SHIFT = %d\n", RADIX_TREE_MAP_SHIFT);
+
+	for (c = 0; size[c]; c++)
+		for (s = 0; step[s]; s++)
+			benchmark_size(size[c], step[s], 0);
+
+	for (c = 0; size[c]; c++)
+		for (s = 0; step[s]; s++)
+			benchmark_size(size[c], step[s] << 9, 9);
+}
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index be98a47..dbe4b92 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -10,7 +10,11 @@
 #include "../../include/linux/compiler.h"
 #include "../../../include/linux/kconfig.h"
 
+#ifdef BENCHMARK
+#define RADIX_TREE_MAP_SHIFT	6
+#else
 #define RADIX_TREE_MAP_SHIFT	3
+#endif
 
 #ifndef NULL
 #define NULL	0
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 2eb6949..f1d1e3b 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -352,6 +352,8 @@ int main(int argc, char **argv)
 	/* Free any remaining preallocated nodes */
 	radix_tree_cpu_dead(0);
 
+	benchmark();
+
 	sleep(1);
 	printf("after sleep(1): %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 5d2fad0..215ab77 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -28,6 +28,7 @@ void item_kill_tree(struct radix_tree_root *root);
 void tag_check(void);
 void multiorder_checks(void);
 void iteration_test(void);
+void benchmark(void);
 
 struct item *
 item_tag_set(struct radix_tree_root *root, unsigned long index, int tag);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
