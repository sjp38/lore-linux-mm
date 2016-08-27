Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F53B830CD
	for <linux-mm@kvack.org>; Sat, 27 Aug 2016 10:17:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so13820039wmz.2
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 07:17:02 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id f37si11529878lfi.289.2016.08.27.07.17.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Aug 2016 07:17:00 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id k135so5065837lfb.1
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 07:17:00 -0700 (PDT)
Subject: [PATCH RFC 4/4] testing/radix-tree: benchmark for iterator
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 27 Aug 2016 17:16:56 +0300
Message-ID: <147230740991.10108.1628935246693150784.stgit@zurg>
In-Reply-To: <147230727479.9957.1087787722571077339.stgit@zurg>
References: <147230727479.9957.1087787722571077339.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

This adds simple benchmark for iterator similar to one I've used for
commit 78c1d78488a3 ("radix-tree: introduce bit-optimized iterator")

Building with make BENCHMARK=1 set radix tree order to 6 and adds -O2,
this allows to get performance comparable to in kernel performance.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 tools/testing/radix-tree/Makefile       |    6 ++
 tools/testing/radix-tree/benchmark.c    |  101 +++++++++++++++++++++++++++++++
 tools/testing/radix-tree/linux/kernel.h |    4 +
 tools/testing/radix-tree/main.c         |    2 +
 tools/testing/radix-tree/test.h         |    1 
 5 files changed, 113 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/radix-tree/benchmark.c

diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index 6079ec142685..1594335d1ed6 100644
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
+	CFLAGS += -DBENCHMARK=1 -O2
+endif
 
 targets: $(TARGETS)
 
diff --git a/tools/testing/radix-tree/benchmark.c b/tools/testing/radix-tree/benchmark.c
new file mode 100644
index 000000000000..05d46071bf37
--- /dev/null
+++ b/tools/testing/radix-tree/benchmark.c
@@ -0,0 +1,101 @@
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
+		radix_tree_tag_set(&tree, item_order_end(index, order), 0);
+	}
+
+	tagged = benchmark_iter(&tree, true);
+	normal = benchmark_iter(&tree, false);
+
+	printf("Size %ld, step %6ld, order %d tagged %10lld ns, normal %10lld ns\n",
+		size, step, order, tagged, normal);
+
+	item_kill_tree(&tree);
+}
+
+void benchmark(void)
+{
+	unsigned long size[] = {1 << 10, 1 << 20,
+#ifdef BENCHMARK
+		1 << 27,
+#endif
+		0};
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
index 52714e86991b..ddabc495423f 100644
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
index daa9010693e8..6e9a02cb7b97 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -335,6 +335,8 @@ int main(int argc, char **argv)
 	iteration_test();
 	single_thread_tests(long_run);
 
+	benchmark();
+
 	sleep(1);
 	printf("after sleep(1): %d allocated\n", nr_allocated);
 	rcu_unregister_thread();
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 93a6ce5e5a59..2529a622f1f2 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -31,6 +31,7 @@ void item_kill_tree(struct radix_tree_root *root);
 void tag_check(void);
 void multiorder_checks(void);
 void iteration_test(void);
+void benchmark(void);
 
 struct item *
 item_tag_set(struct radix_tree_root *root, unsigned long index, int tag);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
