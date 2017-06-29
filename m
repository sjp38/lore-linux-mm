Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4646E2802FE
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 23:39:31 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 6so20586611oik.11
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 20:39:31 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id z70si2422636oia.152.2017.06.28.20.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 20:39:29 -0700 (PDT)
From: Sahitya Tummala <stummala@codeaurora.org>
Subject: [PATCH v4 1/2] mm/list_lru.c: fix list_lru_count_node() to be race free
Date: Thu, 29 Jun 2017 09:09:15 +0530
Message-Id: <1498707555-30525-1-git-send-email-stummala@codeaurora.org>
In-Reply-To: <20170628171854.t4sjyjv55j673qzv@esperanza>
References: <20170628171854.t4sjyjv55j673qzv@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Polakov <apolyakov@beget.ru>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.cz>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Sahitya Tummala <stummala@codeaurora.org>

list_lru_count_node() iterates over all memcgs to get
the total number of entries on the node but it can race with
memcg_drain_all_list_lrus(), which migrates the entries from
a dead cgroup to another. This can return incorrect number of
entries from list_lru_count_node().

Fix this by keeping track of entries per node and simply return
it in list_lru_count_node().

Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>
---
 include/linux/list_lru.h |  1 +
 mm/list_lru.c            | 14 ++++++--------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index cb0ba9f..fa7fd03 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -44,6 +44,7 @@ struct list_lru_node {
 	/* for cgroup aware lrus points to per cgroup lists, otherwise NULL */
 	struct list_lru_memcg	*memcg_lrus;
 #endif
+	long nr_items;
 } ____cacheline_aligned_in_smp;
 
 struct list_lru {
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 234676e..7a40fa2 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -117,6 +117,7 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
 		l = list_lru_from_kmem(nlru, item);
 		list_add_tail(item, &l->list);
 		l->nr_items++;
+		nlru->nr_items++;
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -136,6 +137,7 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 		l = list_lru_from_kmem(nlru, item);
 		list_del_init(item);
 		l->nr_items--;
+		nlru->nr_items--;
 		spin_unlock(&nlru->lock);
 		return true;
 	}
@@ -183,15 +185,10 @@ unsigned long list_lru_count_one(struct list_lru *lru,
 
 unsigned long list_lru_count_node(struct list_lru *lru, int nid)
 {
-	long count = 0;
-	int memcg_idx;
+	struct list_lru_node *nlru;
 
-	count += __list_lru_count_one(lru, nid, -1);
-	if (list_lru_memcg_aware(lru)) {
-		for_each_memcg_cache_index(memcg_idx)
-			count += __list_lru_count_one(lru, nid, memcg_idx);
-	}
-	return count;
+	nlru = &lru->node[nid];
+	return nlru->nr_items;
 }
 EXPORT_SYMBOL_GPL(list_lru_count_node);
 
@@ -226,6 +223,7 @@ unsigned long list_lru_count_node(struct list_lru *lru, int nid)
 			assert_spin_locked(&nlru->lock);
 		case LRU_REMOVED:
 			isolated++;
+			nlru->nr_items--;
 			/*
 			 * If the lru lock has been dropped, our list
 			 * traversal is now invalid and so we have to
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
