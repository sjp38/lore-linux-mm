Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B55EA6B03B4
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:54:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g46so10944317wrd.3
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:54:01 -0700 (PDT)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id 34si3622736wrs.75.2017.06.23.01.54.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 01:54:00 -0700 (PDT)
Received: by mail-wr0-f195.google.com with SMTP id z45so10917131wrb.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:54:00 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/6] mm: kvmalloc support __GFP_RETRY_MAYFAIL for all sizes
Date: Fri, 23 Jun 2017 10:53:43 +0200
Message-Id: <20170623085345.11304-5-mhocko@kernel.org>
In-Reply-To: <20170623085345.11304-1-mhocko@kernel.org>
References: <20170623085345.11304-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

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
index 6520f2d4a226..ee250e2cde34 100644
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
@@ -366,13 +366,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
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
