Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 144A06B0007
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 07:02:22 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id c3-v6so19004265plz.7
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 04:02:22 -0700 (PDT)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id o10-v6si37773799pgq.148.2018.06.04.04.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 04:02:20 -0700 (PDT)
From: nixiaoming <nixiaoming@huawei.com>
Subject: [PATCH] mm: Add conditions to avoid out-of-bounds
Date: Mon, 4 Jun 2018 18:37:35 +0800
Message-ID: <20180604103735.42781-1-nixiaoming@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org, garsilva@embeddedor.com, ktkhai@virtuozzo.com, stummala@codeaurora.org
Cc: nixiaoming@huawei.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

In the function memcg_init_list_lru
if call goto fail when i == 0, will cause out-of-bounds at lru->node[i]

The same out-of-bounds access scenario exists in the functions
memcg_update_list_lru and __memcg_init_list_lru_node

Signed-off-by: nixiaoming <nixiaoming@huawei.com>
---
 mm/list_lru.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index fcfb6c8..ec6bdd9 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -298,6 +298,9 @@ static void __memcg_destroy_list_lru_node(struct list_lru_memcg *memcg_lrus,
 {
 	int i;
 
+	if (unlikely(begin >= end))
+		return;
+
 	for (i = begin; i < end; i++)
 		kfree(memcg_lrus->lru[i]);
 }
@@ -422,6 +425,8 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
 	}
 	return 0;
 fail:
+	if (unlikely(i == 0))
+		return -ENOMEM;
 	for (i = i - 1; i >= 0; i--) {
 		if (!lru->node[i].memcg_lrus)
 			continue;
@@ -456,6 +461,8 @@ static int memcg_update_list_lru(struct list_lru *lru,
 	}
 	return 0;
 fail:
+	if (unlikely(i == 0))
+		return -ENOMEM;
 	for (i = i - 1; i >= 0; i--) {
 		if (!lru->node[i].memcg_lrus)
 			continue;
-- 
2.10.1
