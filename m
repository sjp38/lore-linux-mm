Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7E66B0390
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 10:48:54 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id g10so1807150wrg.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:48:54 -0800 (PST)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id t202si19367307wmd.108.2017.03.07.07.48.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 07:48:53 -0800 (PST)
Received: by mail-wr0-f195.google.com with SMTP id u108so739275wrb.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:48:53 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 4/4] mm: kvmalloc support __GFP_RETRY_MAYFAIL for all sizes
Date: Tue,  7 Mar 2017 16:48:43 +0100
Message-Id: <20170307154843.32516-5-mhocko@kernel.org>
In-Reply-To: <20170307154843.32516-1-mhocko@kernel.org>
References: <20170307154843.32516-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Now that __GFP_RETRY_MAYFAIL has a reasonable semantic regardless of the
request size we can drop the hackish implementation for !costly orders.
__GFP_RETRY_MAYFAIL retries as long as the reclaim makes a forward
progress and backs of when we are out of memory for the requested size.
Therefore we do not need to enforce__GFP_NORETRY for !costly orders just
to silent the oom killer anymore.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/util.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index 885a78d1941b..359d80333301 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -339,9 +339,9 @@ EXPORT_SYMBOL(vm_mmap);
  * Uses kmalloc to get the memory but if the allocation fails then falls back
  * to the vmalloc allocator. Use kvfree for freeing the memory.
  *
- * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. __GFP_RETRY_MAYFAIL
- * is supported only for large (>32kB) allocations, and it should be used only if
- * kmalloc is preferable to the vmalloc fallback, due to visible performance drawbacks.
+ * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported.
+ * __GFP_RETRY_MAYFAIL is supported, and it should be used only if kmalloc is
+ * preferable to the vmalloc fallback, due to visible performance drawbacks.
  *
  * Any use of gfp flags outside of GFP_KERNEL should be consulted with mm people.
  */
@@ -363,13 +363,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 	if (size > PAGE_SIZE) {
 		kmalloc_flags |= __GFP_NOWARN;
 
-		/*
-		 * We have to override __GFP_RETRY_MAYFAIL by __GFP_NORETRY for !costly
-		 * requests because there is no other way to tell the allocator
-		 * that we want to fail rather than retry endlessly.
-		 */
-		if (!(kmalloc_flags & __GFP_RETRY_MAYFAIL) ||
-				(size <= PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
+		if (!(kmalloc_flags & __GFP_RETRY_MAYFAIL))
 			kmalloc_flags |= __GFP_NORETRY;
 	}
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
