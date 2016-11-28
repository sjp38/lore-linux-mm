Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A52276B02B2
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:15 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id j65so260932252iof.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:15 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id p79si41483085ioo.84.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 09/33] radix tree test suite: Use rcu_barrier
Date: Mon, 28 Nov 2016 13:50:13 -0800
Message-Id: <1480369871-5271-10-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Calling rcu_barrier() allows all of the rcu-freed memory to be actually
returned to the pool, and allows nr_allocated to return to 0.  As well
as allowing diffs between runs to be more useful, it also lets us
pinpoint leaks more effectively.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/main.c      | 12 ++++++++++--
 tools/testing/radix-tree/tag_check.c |  5 +++++
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index f1d1e3b..76d9c95 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -295,24 +295,31 @@ static void single_thread_tests(bool long_run)
 	printf("starting single_thread_tests: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
 	multiorder_checks();
+	rcu_barrier();
 	printf("after multiorder_check: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
 	locate_check();
+	rcu_barrier();
 	printf("after locate_check: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
 	tag_check();
+	rcu_barrier();
 	printf("after tag_check: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
 	gang_check();
+	rcu_barrier();
 	printf("after gang_check: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
 	add_and_check();
+	rcu_barrier();
 	printf("after add_and_check: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
 	dynamic_height_check();
+	rcu_barrier();
 	printf("after dynamic_height_check: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
 	big_gang_check(long_run);
+	rcu_barrier();
 	printf("after big_gang_check: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
 	for (i = 0; i < (long_run ? 2000 : 3); i++) {
@@ -320,6 +327,7 @@ static void single_thread_tests(bool long_run)
 		printf("%d ", i);
 		fflush(stdout);
 	}
+	rcu_barrier();
 	printf("after copy_tag_check: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
 }
@@ -354,8 +362,8 @@ int main(int argc, char **argv)
 
 	benchmark();
 
-	sleep(1);
-	printf("after sleep(1): %d allocated, preempt %d\n",
+	rcu_barrier();
+	printf("after rcu_barrier: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
 	rcu_unregister_thread();
 
diff --git a/tools/testing/radix-tree/tag_check.c b/tools/testing/radix-tree/tag_check.c
index b0ac057..186f6e4 100644
--- a/tools/testing/radix-tree/tag_check.c
+++ b/tools/testing/radix-tree/tag_check.c
@@ -51,6 +51,7 @@ void simple_checks(void)
 	verify_tag_consistency(&tree, 1);
 	printf("before item_kill_tree: %d allocated\n", nr_allocated);
 	item_kill_tree(&tree);
+	rcu_barrier();
 	printf("after item_kill_tree: %d allocated\n", nr_allocated);
 }
 
@@ -331,12 +332,16 @@ void tag_check(void)
 	single_check();
 	extend_checks();
 	contract_checks();
+	rcu_barrier();
 	printf("after extend_checks: %d allocated\n", nr_allocated);
 	__leak_check();
 	leak_check();
+	rcu_barrier();
 	printf("after leak_check: %d allocated\n", nr_allocated);
 	simple_checks();
+	rcu_barrier();
 	printf("after simple_checks: %d allocated\n", nr_allocated);
 	thrash_tags();
+	rcu_barrier();
 	printf("after thrash_tags: %d allocated\n", nr_allocated);
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
