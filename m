Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 420226B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 20:52:20 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 91-v6so11911239pla.18
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 17:52:20 -0700 (PDT)
Received: from m12-18.163.com (m12-18.163.com. [220.181.12.18])
        by mx.google.com with ESMTP id b9-v6si4219825pla.32.2018.04.03.17.52.18
        for <linux-mm@kvack.org>;
        Tue, 03 Apr 2018 17:52:19 -0700 (PDT)
From: Xidong Wang <wangxidong_97@163.com>
Subject: [PATCH 1/1] z3fold: fix memory leak
Date: Wed,  4 Apr 2018 08:51:51 +0800
Message-Id: <1522803111-29209-1-git-send-email-wangxidong_97@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vitaly Wool <vitalywool@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: wangxidong_97@163.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In function z3fold_create_pool(), the memory allocated by
__alloc_percpu() is not released on the error path that pool->compact_wq
, which holds the return value of create_singlethread_workqueue(), is NULL.
This will result in a memory leak bug.

Signed-off-by: Xidong Wang <wangxidong_97@163.com>
---
 mm/z3fold.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index d589d31..b987cc5 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -490,6 +490,7 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
 out_wq:
 	destroy_workqueue(pool->compact_wq);
 out:
+	free_percpu(pool->unbuddied);
 	kfree(pool);
 	return NULL;
 }
-- 
2.7.4
