Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B55D26B0273
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:56:39 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j65so260855529iof.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:56:39 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id m76si41571665iod.253.2016.11.28.11.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:39 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 07/33] radix tree test suite: iteration test misuses RCU
Date: Mon, 28 Nov 2016 13:50:45 -0800
Message-Id: <1480369871-5271-42-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Each thread needs to register itself with RCU, otherwise the reading
thread's read lock has no effect and the freeing thread will free the
memory in the tree without waiting for the read lock to be dropped.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/iteration_check.c | 28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/tools/testing/radix-tree/iteration_check.c b/tools/testing/radix-tree/iteration_check.c
index 11d570c..df71cb8 100644
--- a/tools/testing/radix-tree/iteration_check.c
+++ b/tools/testing/radix-tree/iteration_check.c
@@ -29,6 +29,8 @@ static void *add_entries_fn(void *arg)
 {
 	int pgoff;
 
+	rcu_register_thread();
+
 	while (!test_complete) {
 		for (pgoff = 0; pgoff < 100; pgoff++) {
 			pthread_mutex_lock(&tree_lock);
@@ -38,6 +40,8 @@ static void *add_entries_fn(void *arg)
 		}
 	}
 
+	rcu_unregister_thread();
+
 	return NULL;
 }
 
@@ -53,6 +57,8 @@ static void *tagged_iteration_fn(void *arg)
 	struct radix_tree_iter iter;
 	void **slot;
 
+	rcu_register_thread();
+
 	while (!test_complete) {
 		rcu_read_lock();
 		radix_tree_for_each_tagged(slot, &tree, &iter, 0, TAG) {
@@ -72,12 +78,18 @@ static void *tagged_iteration_fn(void *arg)
 				continue;
 			}
 
-			if (rand_r(&seeds[0]) % 50 == 0)
+			if (rand_r(&seeds[0]) % 50 == 0) {
 				slot = radix_tree_iter_next(&iter);
+				rcu_read_unlock();
+				rcu_barrier();
+				rcu_read_lock();
+			}
 		}
 		rcu_read_unlock();
 	}
 
+	rcu_unregister_thread();
+
 	return NULL;
 }
 
@@ -93,6 +105,8 @@ static void *untagged_iteration_fn(void *arg)
 	struct radix_tree_iter iter;
 	void **slot;
 
+	rcu_register_thread();
+
 	while (!test_complete) {
 		rcu_read_lock();
 		radix_tree_for_each_slot(slot, &tree, &iter, 0) {
@@ -112,12 +126,18 @@ static void *untagged_iteration_fn(void *arg)
 				continue;
 			}
 
-			if (rand_r(&seeds[1]) % 50 == 0)
+			if (rand_r(&seeds[1]) % 50 == 0) {
 				slot = radix_tree_iter_next(&iter);
+				rcu_read_unlock();
+				rcu_barrier();
+				rcu_read_lock();
+			}
 		}
 		rcu_read_unlock();
 	}
 
+	rcu_unregister_thread();
+
 	return NULL;
 }
 
@@ -127,6 +147,8 @@ static void *untagged_iteration_fn(void *arg)
  */
 static void *remove_entries_fn(void *arg)
 {
+	rcu_register_thread();
+
 	while (!test_complete) {
 		int pgoff;
 
@@ -137,6 +159,8 @@ static void *remove_entries_fn(void *arg)
 		pthread_mutex_unlock(&tree_lock);
 	}
 
+	rcu_unregister_thread();
+
 	return NULL;
 }
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
