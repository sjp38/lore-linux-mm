Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 125CA6B0296
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 04:39:03 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id w126-v6so12401469qka.11
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 01:39:03 -0700 (PDT)
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70111.outbound.protection.outlook.com. [40.107.7.111])
        by mx.google.com with ESMTPS id v62-v6si749403qkh.168.2018.07.09.01.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 Jul 2018 01:39:02 -0700 (PDT)
Subject: [PATCH v9 09/17] list_lru: Add memcg argument to
 list_lru_from_kmem()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 09 Jul 2018 11:38:53 +0300
Message-ID: <153112553378.4097.3204989884654871988.stgit@localhost.localdomain>
In-Reply-To: <153112469064.4097.2581798353485457328.stgit@localhost.localdomain>
References: <153112469064.4097.2581798353485457328.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org, ktkhai@virtuozzo.com

This is just refactoring to allow next patches to have
memcg pointer in list_lru_from_kmem().

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Tested-by: Shakeel Butt <shakeelb@google.com>
---
 mm/list_lru.c |   25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 5aebbb9b2f5b..1fc5be746e69 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -65,18 +65,24 @@ static __always_inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
 }
 
 static inline struct list_lru_one *
-list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
+list_lru_from_kmem(struct list_lru_node *nlru, void *ptr,
+		   struct mem_cgroup **memcg_ptr)
 {
-	struct mem_cgroup *memcg;
+	struct list_lru_one *l = &nlru->lru;
+	struct mem_cgroup *memcg = NULL;
 
 	if (!nlru->memcg_lrus)
-		return &nlru->lru;
+		goto out;
 
 	memcg = mem_cgroup_from_kmem(ptr);
 	if (!memcg)
-		return &nlru->lru;
+		goto out;
 
-	return list_lru_from_memcg_idx(nlru, memcg_cache_id(memcg));
+	l = list_lru_from_memcg_idx(nlru, memcg_cache_id(memcg));
+out:
+	if (memcg_ptr)
+		*memcg_ptr = memcg;
+	return l;
 }
 #else
 static void list_lru_register(struct list_lru *lru)
@@ -99,8 +105,11 @@ list_lru_from_memcg_idx(struct list_lru_node *nlru, int idx)
 }
 
 static inline struct list_lru_one *
-list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
+list_lru_from_kmem(struct list_lru_node *nlru, void *ptr,
+		   struct mem_cgroup **memcg_ptr)
 {
+	if (memcg_ptr)
+		*memcg_ptr = NULL;
 	return &nlru->lru;
 }
 #endif /* CONFIG_MEMCG_KMEM */
@@ -113,7 +122,7 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
 
 	spin_lock(&nlru->lock);
 	if (list_empty(item)) {
-		l = list_lru_from_kmem(nlru, item);
+		l = list_lru_from_kmem(nlru, item, NULL);
 		list_add_tail(item, &l->list);
 		l->nr_items++;
 		nlru->nr_items++;
@@ -133,7 +142,7 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 
 	spin_lock(&nlru->lock);
 	if (!list_empty(item)) {
-		l = list_lru_from_kmem(nlru, item);
+		l = list_lru_from_kmem(nlru, item, NULL);
 		list_del_init(item);
 		l->nr_items--;
 		nlru->nr_items--;
