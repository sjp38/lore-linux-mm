Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B8BE6B000A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:52:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id s14-v6so1136295wra.0
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:52:53 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z13-v6si1218767wrg.240.2018.07.03.07.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 07:52:51 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 2/4] mm/list_lru: Move locking from __list_lru_walk_one() to its caller
Date: Tue,  3 Jul 2018 16:52:33 +0200
Message-Id: <20180703145235.28050-3-bigeasy@linutronix.de>
In-Reply-To: <20180703145235.28050-1-bigeasy@linutronix.de>
References: <20180624200907.ufjxk6l2biz6xcm2@esperanza>
 <20180703145235.28050-1-bigeasy@linutronix.de>
Reply-To: "[PATCH 0/4]"@kvack.org, "mm/list_lru:add"@kvack.org,
	list_lru_shrink_walk_irq@kvack.org, and@kvack.org (), use@kvack.org,
	it@kvack.org
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Move the locking inside __list_lru_walk_one() to its caller. This is a
preparation step in order to introduce list_lru_walk_one_irq() which
does spin_lock_irq() instead of spin_lock() for the locking.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/list_lru.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index ddbffbdd3d72..819e0595303e 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -204,7 +204,6 @@ __list_lru_walk_one(struct list_lru *lru, int nid, int =
memcg_idx,
 	struct list_head *item, *n;
 	unsigned long isolated =3D 0;
=20
-	spin_lock(&nlru->lock);
 	l =3D list_lru_from_memcg_idx(nlru, memcg_idx);
 restart:
 	list_for_each_safe(item, n, &l->list) {
@@ -250,8 +249,6 @@ __list_lru_walk_one(struct list_lru *lru, int nid, int =
memcg_idx,
 			BUG();
 		}
 	}
-
-	spin_unlock(&nlru->lock);
 	return isolated;
 }
=20
@@ -260,8 +257,14 @@ list_lru_walk_one(struct list_lru *lru, int nid, struc=
t mem_cgroup *memcg,
 		  list_lru_walk_cb isolate, void *cb_arg,
 		  unsigned long *nr_to_walk)
 {
-	return __list_lru_walk_one(lru, nid, memcg_cache_id(memcg),
-				   isolate, cb_arg, nr_to_walk);
+	struct list_lru_node *nlru =3D &lru->node[nid];
+	unsigned long ret;
+
+	spin_lock(&nlru->lock);
+	ret =3D __list_lru_walk_one(lru, nid, memcg_cache_id(memcg),
+				  isolate, cb_arg, nr_to_walk);
+	spin_unlock(&nlru->lock);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(list_lru_walk_one);
=20
@@ -276,8 +279,13 @@ unsigned long list_lru_walk_node(struct list_lru *lru,=
 int nid,
 				      nr_to_walk);
 	if (*nr_to_walk > 0 && list_lru_memcg_aware(lru)) {
 		for_each_memcg_cache_index(memcg_idx) {
+			struct list_lru_node *nlru =3D &lru->node[nid];
+
+			spin_lock(&nlru->lock);
 			isolated +=3D __list_lru_walk_one(lru, nid, memcg_idx,
 						isolate, cb_arg, nr_to_walk);
+			spin_unlock(&nlru->lock);
+
 			if (*nr_to_walk <=3D 0)
 				break;
 		}
--=20
2.18.0
