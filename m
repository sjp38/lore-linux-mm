Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B10196B02EB
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 15:07:54 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id j65so261421684iof.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 12:07:54 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id k191si18265379itd.12.2016.11.28.12.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 12:07:53 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 04/33] radix tree test suite: Track preempt_count
Date: Mon, 28 Nov 2016 13:50:08 -0800
Message-Id: <1480369871-5271-5-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@infradead.org>

Rather than simply NOP out preempt_enable() and preempt_disable(),
keep track of preempt_count and display it regularly in case either
the test suite or the code under test is forgetting to balance the
enables & disables.  Only found a test-case that was forgetting to
re-enable preemption, but it's a possibility worth checking.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 tools/testing/radix-tree/linux.c         |  1 +
 tools/testing/radix-tree/linux/preempt.h |  6 +++---
 tools/testing/radix-tree/main.c          | 30 ++++++++++++++++++++----------
 3 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/tools/testing/radix-tree/linux.c b/tools/testing/radix-tree/linux.c
index 3cfb04e..1f32a16 100644
--- a/tools/testing/radix-tree/linux.c
+++ b/tools/testing/radix-tree/linux.c
@@ -9,6 +9,7 @@
 #include <urcu/uatomic.h>
 
 int nr_allocated;
+int preempt_count;
 
 void *mempool_alloc(mempool_t *pool, int gfp_mask)
 {
diff --git a/tools/testing/radix-tree/linux/preempt.h b/tools/testing/radix-tree/linux/preempt.h
index 6210672..65c04c2 100644
--- a/tools/testing/radix-tree/linux/preempt.h
+++ b/tools/testing/radix-tree/linux/preempt.h
@@ -1,4 +1,4 @@
-/* */
+extern int preempt_count;
 
-#define preempt_disable() do { } while (0)
-#define preempt_enable() do { } while (0)
+#define preempt_disable()	uatomic_inc(&preempt_count)
+#define preempt_enable()	uatomic_dec(&preempt_count)
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index daa9010..64ffe67 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -293,27 +293,36 @@ static void single_thread_tests(bool long_run)
 {
 	int i;
 
-	printf("starting single_thread_tests: %d allocated\n", nr_allocated);
+	printf("starting single_thread_tests: %d allocated, preempt %d\n",
+		nr_allocated, preempt_count);
 	multiorder_checks();
-	printf("after multiorder_check: %d allocated\n", nr_allocated);
+	printf("after multiorder_check: %d allocated, preempt %d\n",
+		nr_allocated, preempt_count);
 	locate_check();
-	printf("after locate_check: %d allocated\n", nr_allocated);
+	printf("after locate_check: %d allocated, preempt %d\n",
+		nr_allocated, preempt_count);
 	tag_check();
-	printf("after tag_check: %d allocated\n", nr_allocated);
+	printf("after tag_check: %d allocated, preempt %d\n",
+		nr_allocated, preempt_count);
 	gang_check();
-	printf("after gang_check: %d allocated\n", nr_allocated);
+	printf("after gang_check: %d allocated, preempt %d\n",
+		nr_allocated, preempt_count);
 	add_and_check();
-	printf("after add_and_check: %d allocated\n", nr_allocated);
+	printf("after add_and_check: %d allocated, preempt %d\n",
+		nr_allocated, preempt_count);
 	dynamic_height_check();
-	printf("after dynamic_height_check: %d allocated\n", nr_allocated);
+	printf("after dynamic_height_check: %d allocated, preempt %d\n",
+		nr_allocated, preempt_count);
 	big_gang_check(long_run);
-	printf("after big_gang_check: %d allocated\n", nr_allocated);
+	printf("after big_gang_check: %d allocated, preempt %d\n",
+		nr_allocated, preempt_count);
 	for (i = 0; i < (long_run ? 2000 : 3); i++) {
 		copy_tag_check();
 		printf("%d ", i);
 		fflush(stdout);
 	}
-	printf("after copy_tag_check: %d allocated\n", nr_allocated);
+	printf("after copy_tag_check: %d allocated, preempt %d\n",
+		nr_allocated, preempt_count);
 }
 
 int main(int argc, char **argv)
@@ -336,7 +345,8 @@ int main(int argc, char **argv)
 	single_thread_tests(long_run);
 
 	sleep(1);
-	printf("after sleep(1): %d allocated\n", nr_allocated);
+	printf("after sleep(1): %d allocated, preempt %d\n",
+		nr_allocated, preempt_count);
 	rcu_unregister_thread();
 
 	exit(0);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
