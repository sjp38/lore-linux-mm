Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA8236B000C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:52:54 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x6-v6so1104212wrl.6
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:52:54 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n191-v6si795371wmb.89.2018.07.03.07.52.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 07:52:53 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 3/4] mm/list_lru: Pass struct list_lru_node as an argument __list_lru_walk_one()
Date: Tue,  3 Jul 2018 16:52:34 +0200
Message-Id: <20180703145235.28050-4-bigeasy@linutronix.de>
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

__list_lru_walk_one() is invoked with struct list_lru *lru, int nid as
the first two argument. Those two are only used to retrieve struct
list_lru_node. Since this is already done by the caller of the function
for the locking, we can pass struct list_lru_node directly and avoid the
dance around it.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/list_lru.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 819e0595303e..4d7f981e6144 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -194,12 +194,11 @@ unsigned long list_lru_count_node(struct list_lru *lr=
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
@@ -261,8 +260,8 @@ list_lru_walk_one(struct list_lru *lru, int nid, struct=
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
@@ -282,8 +281,9 @@ unsigned long list_lru_walk_node(struct list_lru *lru, =
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
