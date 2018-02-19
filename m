Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 408FE6B0031
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c5so3678419pfn.17
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u5-v6si4902697plz.165.2018.02.19.11.46.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:06 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 01/61] radix tree test suite: Check reclaim bit
Date: Mon, 19 Feb 2018 11:44:56 -0800
Message-Id: <20180219194556.6575-2-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

In order to test the memory allocation failure paths, the radix tree
test suite fails allocations if __GFP_NOWARN is set.  That happens to work
for the radix tree implementation, but the semantics we really want are
that we want to fail allocations which are not GFP_KERNEL.  Do this
by failing allocations which don't have the DIRECT_RECLAIM bit set.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/linux.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/radix-tree/linux.c b/tools/testing/radix-tree/linux.c
index 6903ccf35595..f7f3caed3650 100644
--- a/tools/testing/radix-tree/linux.c
+++ b/tools/testing/radix-tree/linux.c
@@ -29,7 +29,7 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, int flags)
 {
 	struct radix_tree_node *node;
 
-	if (flags & __GFP_NOWARN)
+	if (!(flags & __GFP_DIRECT_RECLAIM))
 		return NULL;
 
 	pthread_mutex_lock(&cachep->lock);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
