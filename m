Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D1C456B0269
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:19:34 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id k15-v6so8540384wrq.1
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:19:34 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z8-v6si24940465wrv.127.2018.07.16.04.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jul 2018 04:19:33 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 2/4] mm/list_lru: Move locking from __list_lru_walk_one() to its caller
Date: Mon, 16 Jul 2018 13:19:19 +0200
Message-Id: <20180716111921.5365-3-bigeasy@linutronix.de>
In-Reply-To: <20180716111921.5365-1-bigeasy@linutronix.de>
References: <20180716111921.5365-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Move the locking inside __list_lru_walk_one() to its caller. This is a
preparation step in order to introduce list_lru_walk_one_irq() which
does spin_lock_irq() instead of spin_lock() for the locking.

Reviewed-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/list_lru.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 344306714636..3e36e7a239e5 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -226,7 +226,6 @@ __list_lru_walk_one(struct list_lru *lru, int nid, int =
memcg_idx,
 	struct list_head *item, *n;
 	unsigned long isolated =3D 0;
=20
-	spin_lock(&nlru->lock);
 	l =3D list_lru_from_memcg_idx(nlru, memcg_idx);
 restart:
 	list_for_each_safe(item, n, &l->list) {
@@ -272,8 +271,6 @@ __list_lru_walk_one(struct list_lru *lru, int nid, int =
memcg_idx,
 			BUG();
 		}
 	}
-
-	spin_unlock(&nlru->lock);
 	return isolated;
 }
=20
@@ -282,8 +279,14 @@ list_lru_walk_one(struct list_lru *lru, int nid, struc=
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
@@ -298,8 +301,13 @@ unsigned long list_lru_walk_node(struct list_lru *lru,=
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
