Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7818A6B029C
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:24:05 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id o1so72928405ito.7
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:24:05 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id n124si257964iof.45.2016.11.16.14.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:04 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 05/29] radix tree test suite: Make runs more reproducible
Date: Wed, 16 Nov 2016 16:17:06 -0800
Message-Id: <1479341856-30320-42-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@infradead.org>

Instead of reseeding the random number generator every time around the
loop in big_gang_check(), seed it at the beginning of execution.  Use
rand_r() and an independent base seed for each thread in iteration_test()
so they don't stomp all over each others state.  Since this particular
test depends on the kernel scheduler, the iteration test can't be
reproduced based purely on the random seed, but at least it won't pollute
the other tests.

Print the seed, and allow the seed to be specified so that a run which
hits a problem can be reproduced.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 tools/testing/radix-tree/iteration_check.c | 11 +++++++----
 tools/testing/radix-tree/main.c            |  9 +++++++--
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/tools/testing/radix-tree/iteration_check.c b/tools/testing/radix-tree/iteration_check.c
index 9adb8e7..11d570c 100644
--- a/tools/testing/radix-tree/iteration_check.c
+++ b/tools/testing/radix-tree/iteration_check.c
@@ -20,6 +20,7 @@
 #define TAG 0
 static pthread_mutex_t tree_lock = PTHREAD_MUTEX_INITIALIZER;
 static pthread_t threads[NUM_THREADS];
+static unsigned int seeds[3];
 RADIX_TREE(tree, GFP_KERNEL);
 bool test_complete;
 
@@ -71,7 +72,7 @@ static void *tagged_iteration_fn(void *arg)
 				continue;
 			}
 
-			if (rand() % 50 == 0)
+			if (rand_r(&seeds[0]) % 50 == 0)
 				slot = radix_tree_iter_next(&iter);
 		}
 		rcu_read_unlock();
@@ -111,7 +112,7 @@ static void *untagged_iteration_fn(void *arg)
 				continue;
 			}
 
-			if (rand() % 50 == 0)
+			if (rand_r(&seeds[1]) % 50 == 0)
 				slot = radix_tree_iter_next(&iter);
 		}
 		rcu_read_unlock();
@@ -129,7 +130,7 @@ static void *remove_entries_fn(void *arg)
 	while (!test_complete) {
 		int pgoff;
 
-		pgoff = rand() % 100;
+		pgoff = rand_r(&seeds[2]) % 100;
 
 		pthread_mutex_lock(&tree_lock);
 		item_delete(&tree, pgoff);
@@ -146,9 +147,11 @@ void iteration_test(void)
 
 	printf("Running iteration tests for 10 seconds\n");
 
-	srand(time(0));
 	test_complete = false;
 
+	for (i = 0; i < 3; i++)
+		seeds[i] = rand();
+
 	if (pthread_create(&threads[0], NULL, tagged_iteration_fn, NULL)) {
 		perror("pthread_create");
 		exit(1);
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 2930560..5ddec8e 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -67,7 +67,6 @@ void big_gang_check(bool long_run)
 
 	for (i = 0; i < (long_run ? 1000 : 3); i++) {
 		__big_gang_check();
-		srand(time(0));
 		printf("%d ", i);
 		fflush(stdout);
 	}
@@ -329,12 +328,18 @@ int main(int argc, char **argv)
 {
 	bool long_run = false;
 	int opt;
+	unsigned int seed = time(NULL);
 
-	while ((opt = getopt(argc, argv, "l")) != -1) {
+	while ((opt = getopt(argc, argv, "ls:")) != -1) {
 		if (opt == 'l')
 			long_run = true;
+		else if (opt == 's')
+			seed = strtoul(optarg, NULL, 0);
 	}
 
+	printf("random seed %u\n", seed);
+	srand(seed);
+
 	rcu_register_thread();
 	radix_tree_init();
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
