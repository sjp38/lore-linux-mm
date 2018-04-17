Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0018C6B0031
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:54:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x17so11576910pfn.10
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:54:24 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00120.outbound.protection.outlook.com. [40.107.0.120])
        by mx.google.com with ESMTPS id r138si11600361pgr.84.2018.04.17.08.54.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 08:54:23 -0700 (PDT)
Subject: [PATCH v2 07/12] list_lru: Pass dst_memcg argument to
 memcg_drain_list_lru_node()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 17 Apr 2018 21:54:06 +0300
Message-ID: <152399124671.3456.4156323309583190460.stgit@localhost.localdomain>
In-Reply-To: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

This is just refactoring to allow next patches to have
dst_memcg pointer in memcg_drain_list_lru_node().

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/list_lru.h |    2 +-
 mm/list_lru.c            |   11 ++++++-----
 mm/memcontrol.c          |    2 +-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index f5b6bb7a8670..5c7db0022ce6 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -66,7 +66,7 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 #define list_lru_init_memcg(lru)	__list_lru_init((lru), true, NULL)
 
 int memcg_update_all_list_lrus(int num_memcgs);
-void memcg_drain_all_list_lrus(int src_idx, int dst_idx);
+void memcg_drain_all_list_lrus(int src_idx, struct mem_cgroup *dst_memcg);
 
 /**
  * list_lru_add: add an element to the lru list's tail
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 437f854eac44..a92850bc209f 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -517,8 +517,9 @@ int memcg_update_all_list_lrus(int new_size)
 }
 
 static void memcg_drain_list_lru_node(struct list_lru_node *nlru,
-				      int src_idx, int dst_idx)
+				      int src_idx, struct mem_cgroup *dst_memcg)
 {
+	int dst_idx = dst_memcg->kmemcg_id;
 	struct list_lru_one *src, *dst;
 
 	/*
@@ -538,7 +539,7 @@ static void memcg_drain_list_lru_node(struct list_lru_node *nlru,
 }
 
 static void memcg_drain_list_lru(struct list_lru *lru,
-				 int src_idx, int dst_idx)
+				 int src_idx, struct mem_cgroup *dst_memcg)
 {
 	int i;
 
@@ -546,16 +547,16 @@ static void memcg_drain_list_lru(struct list_lru *lru,
 		return;
 
 	for_each_node(i)
-		memcg_drain_list_lru_node(&lru->node[i], src_idx, dst_idx);
+		memcg_drain_list_lru_node(&lru->node[i], src_idx, dst_memcg);
 }
 
-void memcg_drain_all_list_lrus(int src_idx, int dst_idx)
+void memcg_drain_all_list_lrus(int src_idx, struct mem_cgroup *dst_memcg)
 {
 	struct list_lru *lru;
 
 	mutex_lock(&list_lrus_mutex);
 	list_for_each_entry(lru, &list_lrus, list)
-		memcg_drain_list_lru(lru, src_idx, dst_idx);
+		memcg_drain_list_lru(lru, src_idx, dst_memcg);
 	mutex_unlock(&list_lrus_mutex);
 }
 #else
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 562dfb1be9ef..ffbe65d43a15 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3182,7 +3182,7 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
 	}
 	rcu_read_unlock();
 
-	memcg_drain_all_list_lrus(kmemcg_id, parent->kmemcg_id);
+	memcg_drain_all_list_lrus(kmemcg_id, parent);
 
 	memcg_free_cache_id(kmemcg_id);
 }
