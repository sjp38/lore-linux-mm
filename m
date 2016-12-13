Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 151356B0069
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:26:14 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 136so2547675iou.7
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:26:14 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id 186si2693492itu.98.2016.12.13.12.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 12:26:13 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 4/5] radix tree test suite: Delete unused rcupdate.c
Date: Tue, 13 Dec 2016 14:21:31 -0800
Message-Id: <1481667692-14500-5-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1481667692-14500-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1481667692-14500-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Tejun Heo <tj@kernel.org>

From: Matthew Wilcox <mawilcox@microsoft.com>

This file was used to implement call_rcu() before liburcu implemented
that function.  It hasn't even been compiled since before the test suite
was added to the kernel.  Remove it to reduce confusion.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/rcupdate.c | 86 -------------------------------------
 1 file changed, 86 deletions(-)
 delete mode 100644 tools/testing/radix-tree/rcupdate.c

diff --git a/tools/testing/radix-tree/rcupdate.c b/tools/testing/radix-tree/rcupdate.c
deleted file mode 100644
index 31a2d14..0000000
--- a/tools/testing/radix-tree/rcupdate.c
+++ /dev/null
@@ -1,86 +0,0 @@
-#include <linux/rcupdate.h>
-#include <pthread.h>
-#include <stdio.h>
-#include <assert.h>
-
-static pthread_mutex_t rculock = PTHREAD_MUTEX_INITIALIZER;
-static struct rcu_head *rcuhead_global = NULL;
-static __thread int nr_rcuhead = 0;
-static __thread struct rcu_head *rcuhead = NULL;
-static __thread struct rcu_head *rcutail = NULL;
-
-static pthread_cond_t rcu_worker_cond = PTHREAD_COND_INITIALIZER;
-
-/* switch to urcu implementation when it is merged. */
-void call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *head))
-{
-	head->func = func;
-	head->next = rcuhead;
-	rcuhead = head;
-	if (!rcutail)
-		rcutail = head;
-	nr_rcuhead++;
-	if (nr_rcuhead >= 1000) {
-		int signal = 0;
-
-		pthread_mutex_lock(&rculock);
-		if (!rcuhead_global)
-			signal = 1;
-		rcutail->next = rcuhead_global;
-		rcuhead_global = head;
-		pthread_mutex_unlock(&rculock);
-
-		nr_rcuhead = 0;
-		rcuhead = NULL;
-		rcutail = NULL;
-
-		if (signal) {
-			pthread_cond_signal(&rcu_worker_cond);
-		}
-	}
-}
-
-static void *rcu_worker(void *arg)
-{
-	struct rcu_head *r;
-
-	rcupdate_thread_init();
-
-	while (1) {
-		pthread_mutex_lock(&rculock);
-		while (!rcuhead_global) {
-			pthread_cond_wait(&rcu_worker_cond, &rculock);
-		}
-		r = rcuhead_global;
-		rcuhead_global = NULL;
-
-		pthread_mutex_unlock(&rculock);
-
-		synchronize_rcu();
-
-		while (r) {
-			struct rcu_head *tmp = r->next;
-			r->func(r);
-			r = tmp;
-		}
-	}
-
-	rcupdate_thread_exit();
-
-	return NULL;
-}
-
-static pthread_t worker_thread;
-void rcupdate_init(void)
-{
-	pthread_create(&worker_thread, NULL, rcu_worker, NULL);
-}
-
-void rcupdate_thread_init(void)
-{
-	rcu_register_thread();
-}
-void rcupdate_thread_exit(void)
-{
-	rcu_unregister_thread();
-}
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
