Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 42B4C6B003A
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:41:51 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id rd18so4858953iec.7
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:41:51 -0700 (PDT)
Received: from cam-smtp0.cambridge.arm.com (fw-tnat.cambridge.arm.com. [217.140.96.21])
        by mx.google.com with ESMTPS id yk6si1120675icb.17.2014.05.02.06.41.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:41:50 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 3/6] lib: Update the kmemleak stack trace for radix tree allocations
Date: Fri,  2 May 2014 14:41:07 +0100
Message-Id: <1399038070-1540-4-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
References: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>

Since radix_tree_preload() stack trace is not always useful for
debugging an actual radix tree memory leak, this patch updates the
kmemleak allocation stack trace in the radix_tree_node_alloc() function.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 lib/radix-tree.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 9599aa72d7a0..5297f8e09096 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -27,6 +27,7 @@
 #include <linux/radix-tree.h>
 #include <linux/percpu.h>
 #include <linux/slab.h>
+#include <linux/kmemleak.h>
 #include <linux/notifier.h>
 #include <linux/cpu.h>
 #include <linux/string.h>
@@ -200,6 +201,11 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 			rtp->nodes[rtp->nr - 1] = NULL;
 			rtp->nr--;
 		}
+		/*
+		 * Update the allocation stack trace as this is more useful
+		 * for debugging.
+		 */
+		kmemleak_update_trace(ret);
 	}
 	if (ret == NULL)
 		ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
