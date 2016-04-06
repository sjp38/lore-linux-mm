Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCF06B0260
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:22:00 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id e128so41075288pfe.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:22:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yk5si6891850pab.160.2016.04.06.14.21.52
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:52 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 05/30] radix tree test suite: keep regression test runs short
Date: Wed,  6 Apr 2016 17:21:14 -0400
Message-Id: <1459977699-2349-6-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Matthew Wilcox <willy@linux.intel.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Currently the full suite of regression tests take upwards of 30 minutes to
run on my development machine.  The vast majority of this time is taken by
the big_gang_check() and copy_tag_check() tests, which each run their tests
through thousands of iterations...does this have value?

Without big_gang_check() and copy_tag_check(), the test suite runs in
around 15 seconds on my box.

Honestly the first time I ever ran through the entire test suite was to
gather the timings for this email - it simply takes too long to be useful
on a normal basis.

Instead, hide the excessive iterations through big_gang_check() and
copy_tag_check() tests behind an '-l' flag (for "long run") in case they
are still useful, but allow the regression test suite to complete in a
reasonable amount of time.  We still run each of these tests a few times (3
at present) to try and keep the test coverage.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 tools/testing/radix-tree/main.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 71c5272443b1..122c8b9be17e 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -61,11 +61,11 @@ void __big_gang_check(void)
 	} while (!wrapped);
 }
 
-void big_gang_check(void)
+void big_gang_check(bool long_run)
 {
 	int i;
 
-	for (i = 0; i < 1000; i++) {
+	for (i = 0; i < (long_run ? 1000 : 3); i++) {
 		__big_gang_check();
 		srand(time(0));
 		printf("%d ", i);
@@ -270,7 +270,7 @@ static void locate_check(void)
 	item_kill_tree(&tree);
 }
 
-static void single_thread_tests(void)
+static void single_thread_tests(bool long_run)
 {
 	int i;
 
@@ -285,9 +285,9 @@ static void single_thread_tests(void)
 	printf("after add_and_check: %d allocated\n", nr_allocated);
 	dynamic_height_check();
 	printf("after dynamic_height_check: %d allocated\n", nr_allocated);
-	big_gang_check();
+	big_gang_check(long_run);
 	printf("after big_gang_check: %d allocated\n", nr_allocated);
-	for (i = 0; i < 2000; i++) {
+	for (i = 0; i < (long_run ? 2000 : 3); i++) {
 		copy_tag_check();
 		printf("%d ", i);
 		fflush(stdout);
@@ -295,15 +295,23 @@ static void single_thread_tests(void)
 	printf("after copy_tag_check: %d allocated\n", nr_allocated);
 }
 
-int main(void)
+int main(int argc, char **argv)
 {
+	bool long_run = false;
+	int opt;
+
+	while ((opt = getopt(argc, argv, "l")) != -1) {
+		if (opt == 'l')
+			long_run = true;
+	}
+
 	rcu_register_thread();
 	radix_tree_init();
 
 	regression1_test();
 	regression2_test();
 	regression3_test();
-	single_thread_tests();
+	single_thread_tests(long_run);
 
 	sleep(1);
 	printf("after sleep(1): %d allocated\n", nr_allocated);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
