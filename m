Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A43BF6B02A1
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:24:05 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w132so75383702ita.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:24:05 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id u189si224902ioe.210.2016.11.16.14.24.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:03 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 04/29] radix tree test suite: Free preallocated nodes
Date: Wed, 16 Nov 2016 16:16:29 -0800
Message-Id: <1479341856-30320-5-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@infradead.org>

It can be a source of mild concern when the test suite shows that we're
leaking nodes.  While poring over the source code looking for leaks
can lead to some fascinating bugs being discovered, sometimes the leak
is simply that these nodes were preallocated and are sitting on the
per-CPU list.  Free them by faking a CPU_DEAD event.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 tools/testing/radix-tree/main.c | 3 +++
 tools/testing/radix-tree/test.h | 4 ++++
 2 files changed, 7 insertions(+)

diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 64ffe67..2930560 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -344,6 +344,9 @@ int main(int argc, char **argv)
 	iteration_test();
 	single_thread_tests(long_run);
 
+	/* Free any remaining preallocated nodes */
+	radix_tree_callback(NULL, CPU_DEAD, NULL);
+
 	sleep(1);
 	printf("after sleep(1): %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 217fb24..8cd666a 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -2,6 +2,8 @@
 #include <linux/types.h>
 #include <linux/radix-tree.h>
 #include <linux/rcupdate.h>
+#include <linux/notifier.h>
+#include <linux/cpu.h>
 
 struct item {
 	unsigned long index;
@@ -44,3 +46,5 @@ void radix_tree_dump(struct radix_tree_root *root);
 int root_tag_get(struct radix_tree_root *root, unsigned int tag);
 unsigned long node_maxindex(struct radix_tree_node *);
 unsigned long shift_maxindex(unsigned int shift);
+int radix_tree_callback(struct notifier_block *nfb,
+			unsigned long action, void *hcpu);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
