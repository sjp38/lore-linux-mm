Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC912803D0
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 08:29:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a7so39443744pgn.9
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 05:29:17 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0122.outbound.protection.outlook.com. [104.47.0.122])
        by mx.google.com with ESMTPS id 190si5512943pfd.212.2017.08.22.05.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Aug 2017 05:29:16 -0700 (PDT)
Subject: [PATCH 1/3] mm: Add rcu field to struct list_lru_memcg
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 22 Aug 2017 15:29:17 +0300
Message-ID: <150340495784.3845.8914468792862418341.stgit@localhost.localdomain>
In-Reply-To: <150340381428.3845.6099251634440472539.stgit@localhost.localdomain>
References: <150340381428.3845.6099251634440472539.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ktkhai@virtuozzo.com, vdavydov.dev@gmail.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org

This patch adds the new field and teaches kmalloc()
to allocate memory for it.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/list_lru.h |    1 +
 mm/list_lru.c            |    7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index fa7fd03cb5f9..b65505b32a3d 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -31,6 +31,7 @@ struct list_lru_one {
 };
 
 struct list_lru_memcg {
+	struct rcu_head		rcu;
 	/* array of per cgroup lists, indexed by memcg_cache_id */
 	struct list_lru_one	*lru[0];
 };
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 7a40fa2be858..a726e321bf3e 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -325,7 +325,8 @@ static int memcg_init_list_lru_node(struct list_lru_node *nlru)
 {
 	int size = memcg_nr_cache_ids;
 
-	nlru->memcg_lrus = kmalloc(size * sizeof(void *), GFP_KERNEL);
+	nlru->memcg_lrus = kmalloc(sizeof(struct list_lru_memcg) +
+				   size * sizeof(void *), GFP_KERNEL);
 	if (!nlru->memcg_lrus)
 		return -ENOMEM;
 
@@ -351,7 +352,7 @@ static int memcg_update_list_lru_node(struct list_lru_node *nlru,
 	BUG_ON(old_size > new_size);
 
 	old = nlru->memcg_lrus;
-	new = kmalloc(new_size * sizeof(void *), GFP_KERNEL);
+	new = kmalloc(sizeof(*new) + new_size * sizeof(void *), GFP_KERNEL);
 	if (!new)
 		return -ENOMEM;
 
@@ -360,7 +361,7 @@ static int memcg_update_list_lru_node(struct list_lru_node *nlru,
 		return -ENOMEM;
 	}
 
-	memcpy(new, old, old_size * sizeof(void *));
+	memcpy(&new->lru, &old->lru, old_size * sizeof(void *));
 
 	/*
 	 * The lock guarantees that we won't race with a reader

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
