Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8226B026B
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:19:35 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r4-v6so8593735wrt.2
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:19:35 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l18-v6si9610017wme.197.2018.07.16.04.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jul 2018 04:19:34 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 3/4] mm/list_lru: Pass struct list_lru_node as an argument __list_lru_walk_one()
Date: Mon, 16 Jul 2018 13:19:20 +0200
Message-Id: <20180716111921.5365-4-bigeasy@linutronix.de>
In-Reply-To: <20180716111921.5365-1-bigeasy@linutronix.de>
References: <20180716111921.5365-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

__list_lru_walk_one() is invoked with struct list_lru *lru, int nid as
the first two argument. Those two are only used to retrieve struct
list_lru_node. Since this is already done by the caller of the function
for the locking, we can pass struct list_lru_node directly and avoid the
dance around it.

Reviewed-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/list_lru.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 3e36e7a239e5..7b7a737f0963 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -216,12 +216,11 @@ unsigned long list_lru_count_node(struct list_lru *lr=
u, int nid)
 EXPORT_SYMBOL_GPL(list_lru_count_node);
=20
 static unsigned long
-__list_lru_walk_one(struct list_lru *lru, int nid, int memcg_idx,
+__list_lru_walk_one(struct list_lru_node *nlru, int memcg_idx,
 		    list_lru_walk_cb isolate, void *cb_arg,
 		    unsigned long *nr_to_walk)
 {
=20
-	struct list_lru_node *nlru =3D &lru->node[nid];
 	struct list_lru_one *l;
 	struct list_head *item, *n;
 	unsigned long isolated =3D 0;
@@ -283,8 +282,8 @@ list_lru_walk_one(struct list_lru *lru, int nid, struct=
 mem_cgroup *memcg,
 	unsigned long ret;
=20
 	spin_lock(&nlru->lock);
-	ret =3D __list_lru_walk_one(lru, nid, memcg_cache_id(memcg),
-				  isolate, cb_arg, nr_to_walk);
+	ret =3D __list_lru_walk_one(nlru, memcg_cache_id(memcg), isolate, cb_arg,
+				  nr_to_walk);
 	spin_unlock(&nlru->lock);
 	return ret;
 }
@@ -304,8 +303,9 @@ unsigned long list_lru_walk_node(struct list_lru *lru, =
int nid,
 			struct list_lru_node *nlru =3D &lru->node[nid];
=20
 			spin_lock(&nlru->lock);
-			isolated +=3D __list_lru_walk_one(lru, nid, memcg_idx,
-						isolate, cb_arg, nr_to_walk);
+			isolated +=3D __list_lru_walk_one(nlru, memcg_idx,
+							isolate, cb_arg,
+							nr_to_walk);
 			spin_unlock(&nlru->lock);
=20
 			if (*nr_to_walk <=3D 0)
--=20
2.18.0
