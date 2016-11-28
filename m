Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF506B0266
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:56:39 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j92so262038162ioi.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:56:39 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id d137si19969920itc.92.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 27/33] radix tree test suite: Check multiorder iteration
Date: Mon, 28 Nov 2016 13:50:31 -0800
Message-Id: <1480369871-5271-28-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The random iteration test only inserts order-0 entries currently.
Update it to insert entries of order between 7 and 0.  Also make the
maximum index configurable, make some variables static, make the test
duration variable, remove some useless spinning, and add a fifth thread
which calls tag_tagged_items().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/iteration_check.c | 80 ++++++++++++++++++------------
 tools/testing/radix-tree/main.c            |  3 +-
 tools/testing/radix-tree/multiorder.c      | 23 +++++++++
 tools/testing/radix-tree/test.h            |  2 +-
 4 files changed, 73 insertions(+), 35 deletions(-)

diff --git a/tools/testing/radix-tree/iteration_check.c b/tools/testing/radix-tree/iteration_check.c
index f328a66..7572b7e 100644
--- a/tools/testing/radix-tree/iteration_check.c
+++ b/tools/testing/radix-tree/iteration_check.c
@@ -16,26 +16,36 @@
 #include <pthread.h>
 #include "test.h"
 
-#define NUM_THREADS 4
-#define TAG 0
+#define NUM_THREADS	5
+#define MAX_IDX		100
+#define TAG		0
+#define NEW_TAG		1
+
 static pthread_mutex_t tree_lock = PTHREAD_MUTEX_INITIALIZER;
 static pthread_t threads[NUM_THREADS];
 static unsigned int seeds[3];
-RADIX_TREE(tree, GFP_KERNEL);
-bool test_complete;
+static RADIX_TREE(tree, GFP_KERNEL);
+static bool test_complete;
+static int max_order;
 
 /* relentlessly fill the tree with tagged entries */
 static void *add_entries_fn(void *arg)
 {
-	int pgoff;
-
 	rcu_register_thread();
 
 	while (!test_complete) {
-		for (pgoff = 0; pgoff < 100; pgoff++) {
+		unsigned long pgoff;
+		int order;
+
+		for (pgoff = 0; pgoff < MAX_IDX; pgoff++) {
 			pthread_mutex_lock(&tree_lock);
-			if (item_insert(&tree, pgoff) == 0)
-				item_tag_set(&tree, pgoff, TAG);
+			for (order = max_order; order >= 0; order--) {
+				if (item_insert_order(&tree, pgoff, order)
+						== 0) {
+					item_tag_set(&tree, pgoff, TAG);
+					break;
+				}
+			}
 			pthread_mutex_unlock(&tree_lock);
 		}
 	}
@@ -62,14 +72,7 @@ static void *tagged_iteration_fn(void *arg)
 	while (!test_complete) {
 		rcu_read_lock();
 		radix_tree_for_each_tagged(slot, &tree, &iter, 0, TAG) {
-			void *entry;
-			int i;
-
-			/* busy wait to let removals happen */
-			for (i = 0; i < 1000000; i++)
-				;
-
-			entry = radix_tree_deref_slot(slot);
+			void *entry = radix_tree_deref_slot(slot);
 			if (unlikely(!entry))
 				continue;
 
@@ -110,14 +113,7 @@ static void *untagged_iteration_fn(void *arg)
 	while (!test_complete) {
 		rcu_read_lock();
 		radix_tree_for_each_slot(slot, &tree, &iter, 0) {
-			void *entry;
-			int i;
-
-			/* busy wait to let removals happen */
-			for (i = 0; i < 1000000; i++)
-				;
-
-			entry = radix_tree_deref_slot(slot);
+			void *entry = radix_tree_deref_slot(slot);
 			if (unlikely(!entry))
 				continue;
 
@@ -152,7 +148,7 @@ static void *remove_entries_fn(void *arg)
 	while (!test_complete) {
 		int pgoff;
 
-		pgoff = rand_r(&seeds[2]) % 100;
+		pgoff = rand_r(&seeds[2]) % MAX_IDX;
 
 		pthread_mutex_lock(&tree_lock);
 		item_delete(&tree, pgoff);
@@ -164,36 +160,54 @@ static void *remove_entries_fn(void *arg)
 	return NULL;
 }
 
+static void *tag_entries_fn(void *arg)
+{
+	rcu_register_thread();
+
+	while (!test_complete) {
+		tag_tagged_items(&tree, &tree_lock, 0, MAX_IDX, 10, TAG,
+					NEW_TAG);
+	}
+	rcu_unregister_thread();
+	return NULL;
+}
+
 /* This is a unit test for a bug found by the syzkaller tester */
-void iteration_test(void)
+void iteration_test(unsigned order, unsigned test_duration)
 {
 	int i;
 
-	printf("Running iteration tests for 10 seconds\n");
+	printf("Running %siteration tests for %d seconds\n",
+			order > 0 ? "multiorder " : "", test_duration);
 
+	max_order = order;
 	test_complete = false;
 
 	for (i = 0; i < 3; i++)
 		seeds[i] = rand();
 
 	if (pthread_create(&threads[0], NULL, tagged_iteration_fn, NULL)) {
-		perror("pthread_create");
+		perror("create tagged iteration thread");
 		exit(1);
 	}
 	if (pthread_create(&threads[1], NULL, untagged_iteration_fn, NULL)) {
-		perror("pthread_create");
+		perror("create untagged iteration thread");
 		exit(1);
 	}
 	if (pthread_create(&threads[2], NULL, add_entries_fn, NULL)) {
-		perror("pthread_create");
+		perror("create add entry thread");
 		exit(1);
 	}
 	if (pthread_create(&threads[3], NULL, remove_entries_fn, NULL)) {
-		perror("pthread_create");
+		perror("create remove entry thread");
+		exit(1);
+	}
+	if (pthread_create(&threads[4], NULL, tag_entries_fn, NULL)) {
+		perror("create tag entry thread");
 		exit(1);
 	}
 
-	sleep(10);
+	sleep(test_duration);
 	test_complete = true;
 
 	for (i = 0; i < NUM_THREADS; i++) {
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 170175c..f7e9801 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -350,7 +350,8 @@ int main(int argc, char **argv)
 	regression1_test();
 	regression2_test();
 	regression3_test();
-	iteration_test();
+	iteration_test(0, 10);
+	iteration_test(7, 20);
 	single_thread_tests(long_run);
 
 	/* Free any remaining preallocated nodes */
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 9757b89..08b4e16 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -75,8 +75,27 @@ static void __multiorder_tag_test(int index, int order)
 	item_kill_tree(&tree);
 }
 
+static void __multiorder_tag_test2(unsigned order, unsigned long index2)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	unsigned long index = (1 << order);
+	index2 += index;
+
+	assert(item_insert_order(&tree, 0, order) == 0);
+	assert(item_insert(&tree, index2) == 0);
+
+	assert(radix_tree_tag_set(&tree, 0, 0));
+	assert(radix_tree_tag_set(&tree, index2, 0));
+
+	assert(tag_tagged_items(&tree, NULL, 0, ~0UL, 10, 0, 1) == 2);
+
+	item_kill_tree(&tree);
+}
+
 static void multiorder_tag_tests(void)
 {
+	int i, j;
+
 	/* test multi-order entry for indices 0-7 with no sibling pointers */
 	__multiorder_tag_test(0, 3);
 	__multiorder_tag_test(5, 3);
@@ -116,6 +135,10 @@ static void multiorder_tag_tests(void)
 	__multiorder_tag_test(300, 8);
 
 	__multiorder_tag_test(0x12345678UL, 8);
+
+	for (i = 1; i < 10; i++)
+		for (j = 0; j < (10 << i); j++)
+			__multiorder_tag_test2(i, j);
 }
 
 static void multiorder_check(unsigned long index, int order)
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 7c2611c..056a23b 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -32,7 +32,7 @@ unsigned long find_item(struct radix_tree_root *, void *item);
 
 void tag_check(void);
 void multiorder_checks(void);
-void iteration_test(void);
+void iteration_test(unsigned order, unsigned duration);
 void benchmark(void);
 
 struct item *
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
