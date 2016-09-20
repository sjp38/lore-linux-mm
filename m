Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B38F6B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 02:57:37 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 92so31358366iom.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 23:57:37 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id v88si33297389iov.139.2016.09.19.23.57.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 23:57:36 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm,ksm: add __GFP_HIGH to the allocation in alloc_stable_node()
Date: Tue, 20 Sep 2016 14:54:44 +0800
Message-ID: <1474354484-58233-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, akpm@linux-foundation.org, mhocko@suse.cz, vbabka@suse.cz, rientjes@google.com
Cc: linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

Accoding to HUgh's suggestion, alloc_stable_node() with GFP_KERNEL
will cause the hungtask, despite less possiblity.

At present, if alloc_stable_node allocate fails, two break_cow may
want to allocate a couple of pages, and the issue will come up when
free memory is under pressure.

we fix it by adding the __GFP_HIGH to GFP. because it grant access to
some of meory reserves. it will make progess to make it allocation
successful at the utmost.

Suggested-by: Hugh Dickins <hughd@google.com>
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/ksm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 5048083..42bf16e 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -299,7 +299,7 @@ static inline void free_rmap_item(struct rmap_item *rmap_item)
 
 static inline struct stable_node *alloc_stable_node(void)
 {
-	return kmem_cache_alloc(stable_node_cache, GFP_KERNEL);
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
