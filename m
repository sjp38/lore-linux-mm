Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D406C6B02D4
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:40 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j65so260949660iof.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:40 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id x78si19986283itb.44.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:39 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 05/33] radix tree test suite: Free preallocated nodes
Date: Mon, 28 Nov 2016 13:50:43 -0800
Message-Id: <1480369871-5271-40-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@infradead.org>

It can be a source of mild concern when the test suite shows that we're
leaking nodes.  While poring over the source code looking for leaks
can lead to some fascinating bugs being discovered, sometimes the leak
is simply that these nodes were preallocated and are sitting on the
per-CPU list.  Free them by calling the CPU dead callback.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 tools/testing/radix-tree/main.c | 3 +++
 tools/testing/radix-tree/test.h | 1 +
 2 files changed, 4 insertions(+)

diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 64ffe67..52ce1ea 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -344,6 +344,9 @@ int main(int argc, char **argv)
 	iteration_test();
 	single_thread_tests(long_run);
 
+	/* Free any remaining preallocated nodes */
+	radix_tree_cpu_dead(0);
+
 	sleep(1);
 	printf("after sleep(1): %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 217fb24..5d2fad0 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -44,3 +44,4 @@ void radix_tree_dump(struct radix_tree_root *root);
 int root_tag_get(struct radix_tree_root *root, unsigned int tag);
 unsigned long node_maxindex(struct radix_tree_node *);
 unsigned long shift_maxindex(unsigned int shift);
+int radix_tree_cpu_dead(unsigned int cpu);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
