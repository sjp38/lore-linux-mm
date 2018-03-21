Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4336B002F
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:22:41 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g22so2405081pgv.16
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:22:41 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20104.outbound.protection.outlook.com. [40.107.2.104])
        by mx.google.com with ESMTPS id t16si3127592pfj.149.2018.03.21.06.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 06:22:40 -0700 (PDT)
Subject: [PATCH 07/10] list_lru: Pass lru argument to
 memcg_drain_list_lru_node()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 21 Mar 2018 16:22:24 +0300
Message-ID: <152163854435.21546.1198452279434156844.stgit@localhost.localdomain>
In-Reply-To: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, ktkhai@virtuozzo.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

This is just refactoring to allow next patches to have
lru pointer in memcg_drain_list_lru_node().

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/list_lru.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index a1259b88adba..85a0988154aa 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -515,9 +515,10 @@ int memcg_update_all_list_lrus(int new_size)
 	goto out;
 }
 
-static void memcg_drain_list_lru_node(struct list_lru_node *nlru,
+static void memcg_drain_list_lru_node(struct list_lru *lru, int nid,
 				      int src_idx, struct mem_cgroup *dst_memcg)
 {
+	struct list_lru_node *nlru = &lru->node[nid];
 	int dst_idx = dst_memcg->kmemcg_id;
 	struct list_lru_one *src, *dst;
 
@@ -546,7 +547,7 @@ static void memcg_drain_list_lru(struct list_lru *lru,
 		return;
 
 	for_each_node(i)
-		memcg_drain_list_lru_node(&lru->node[i], src_idx, dst_memcg);
+		memcg_drain_list_lru_node(lru, i, src_idx, dst_memcg);
 }
 
 void memcg_drain_all_list_lrus(int src_idx, struct mem_cgroup *dst_memcg)
