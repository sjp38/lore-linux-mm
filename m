Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA4E96B0299
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 04:39:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g4-v6so15092022itf.6
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 01:39:16 -0700 (PDT)
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70105.outbound.protection.outlook.com. [40.107.7.105])
        by mx.google.com with ESMTPS id a189-v6si9927013iog.16.2018.07.09.01.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 Jul 2018 01:39:16 -0700 (PDT)
Subject: [PATCH v9 10/17] From: Kirill Tkhai <ktkhai@virtuozzo.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 09 Jul 2018 11:39:04 +0300
Message-ID: <153112554453.4097.12367687920458389659.stgit@localhost.localdomain>
In-Reply-To: <153112469064.4097.2581798353485457328.stgit@localhost.localdomain>
References: <153112469064.4097.2581798353485457328.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org, ktkhai@virtuozzo.com

list_lru: Pass dst_memcg argument to memcg_drain_list_lru_node()

This is just refactoring to allow next patches to have
dst_memcg pointer in memcg_drain_list_lru_node().

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Tested-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/list_lru.h |    2 +-
 mm/list_lru.c            |   11 ++++++-----
 mm/memcontrol.c          |    2 +-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 9e75bb33766b..d9c16f2f2f00 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -69,7 +69,7 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 	__list_lru_init((lru), true, NULL, shrinker)
 
 int memcg_update_all_list_lrus(int num_memcgs);
-void memcg_drain_all_list_lrus(int src_idx, int dst_idx);
+void memcg_drain_all_list_lrus(int src_idx, struct mem_cgroup *dst_memcg);
 
 /**
  * list_lru_add: add an element to the lru list's tail
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 1fc5be746e69..5384cda08984 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -502,8 +502,9 @@ int memcg_update_all_list_lrus(int new_size)
 }
 
 static void memcg_drain_list_lru_node(struct list_lru_node *nlru,
-				      int src_idx, int dst_idx)
+				      int src_idx, struct mem_cgroup *dst_memcg)
 {
+	int dst_idx = dst_memcg->kmemcg_id;
 	struct list_lru_one *src, *dst;
 
 	/*
@@ -523,7 +524,7 @@ static void memcg_drain_list_lru_node(struct list_lru_node *nlru,
 }
 
 static void memcg_drain_list_lru(struct list_lru *lru,
-				 int src_idx, int dst_idx)
+				 int src_idx, struct mem_cgroup *dst_memcg)
 {
 	int i;
 
@@ -531,16 +532,16 @@ static void memcg_drain_list_lru(struct list_lru *lru,
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
index 0cb2c7ca2086..cac30b4e9904 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3009,7 +3009,7 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
 	}
 	rcu_read_unlock();
 
-	memcg_drain_all_list_lrus(kmemcg_id, parent->kmemcg_id);
+	memcg_drain_all_list_lrus(kmemcg_id, parent);
 
 	memcg_free_cache_id(kmemcg_id);
 }
