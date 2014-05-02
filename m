Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2CF416B003B
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:41:49 -0400 (EDT)
Received: by mail-yk0-f170.google.com with SMTP id 79so3843581ykr.29
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:41:48 -0700 (PDT)
Received: from cam-smtp0.cambridge.arm.com (fw-tnat.cambridge.arm.com. [217.140.96.21])
        by mx.google.com with ESMTPS id 42si46440648yhp.196.2014.05.02.06.41.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:41:47 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 4/6] mm: Update the kmemleak stack trace for mempool allocations
Date: Fri,  2 May 2014 14:41:08 +0100
Message-Id: <1399038070-1540-5-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
References: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>

When mempool_alloc() returns an existing pool object, kmemleak_alloc()
is no longer called and the stack trace corresponds to the original
object allocation. This patch updates the kmemleak allocation stack
trace for such objects to make it more useful for debugging.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/mempool.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/mempool.c b/mm/mempool.c
index 905434f18c97..e7c4be024f1a 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -10,6 +10,7 @@
 
 #include <linux/mm.h>
 #include <linux/slab.h>
+#include <linux/kmemleak.h>
 #include <linux/export.h>
 #include <linux/mempool.h>
 #include <linux/blkdev.h>
@@ -220,6 +221,11 @@ repeat_alloc:
 		spin_unlock_irqrestore(&pool->lock, flags);
 		/* paired with rmb in mempool_free(), read comment there */
 		smp_wmb();
+		/*
+		 * Update the allocation stack trace as this is more useful
+		 * for debugging.
+		 */
+		kmemleak_update_trace(element);
 		return element;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
