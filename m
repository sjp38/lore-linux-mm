Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 77EF86B02BE
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 09:49:20 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t83so135932004oie.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 06:49:20 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id e1si6420848oih.57.2016.09.28.06.48.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Sep 2016 06:48:56 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH v2] mm,ksm: add __GFP_HIGH to the allocation in alloc_stable_node()
Date: Wed, 28 Sep 2016 21:46:02 +0800
Message-ID: <1475070362-44469-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, mhocko@suse.cz, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

According to HUgh's suggestion, alloc_stable_node() with GFP_KERNEL
will cause the hungtask, despite less possiblity.

At present, if alloc_stable_node allocate fails, two break_cow may
want to allocate a couple of pages, and the issue will come up when
free memory is under pressure.

we fix it by adding the __GFP_HIGH to GFP. because it grant access to
some of meory reserves. it will make progress to make it allocation
successful at the utmost.

Acked-by: Hugh Dickins <hughd@google.com>
Suggested-by: Hugh Dickins <hughd@google.com>
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/ksm.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 5048083..5e98c0b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -299,7 +299,14 @@ static inline void free_rmap_item(struct rmap_item *rmap_item)
 
 static inline struct stable_node *alloc_stable_node(void)
 {
-	return kmem_cache_alloc(stable_node_cache, GFP_KERNEL);
+	/*
+	 * The caller can take too long time with GFP_KERNEL when memory
+	 * is under pressure, it may be lead to the hung task. Therefore,
+	 * Adding the __GFP_HIGH to this. it grant access to some of
+	 * memory reserves. and it will make progress to make it allocation
+	 * successful at the utmost.
+	 */
+	return kmem_cache_alloc(stable_node_cache, GFP_KERNEL | __GFP_HIGH);
 }
 
 static inline void free_stable_node(struct stable_node *stable_node)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
