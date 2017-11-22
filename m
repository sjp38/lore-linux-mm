Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 726596B0069
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:07:49 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id b77so2188856pfl.2
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:07:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v6si15670027pfa.316.2017.11.22.13.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:07:48 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 03/62] radix tree test suite: Check reclaim bit
Date: Wed, 22 Nov 2017 13:06:40 -0800
Message-Id: <20171122210739.29916-4-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

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
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
