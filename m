Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB5A6B0006
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:52:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i193-v6so871363wmf.6
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:52:51 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g8-v6si1276561wrw.125.2018.07.03.07.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 07:52:49 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/4] mm/list_lru: use list_lru_walk_one() in list_lru_walk_node()
Date: Tue,  3 Jul 2018 16:52:32 +0200
Message-Id: <20180703145235.28050-2-bigeasy@linutronix.de>
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

list_lru_walk_node() invokes __list_lru_walk_one() with -1 as the
memcg_idx parameter. The same can be achieved by list_lru_walk_one() and
passing NULL as memcg argument which then gets converted into -1. This
is a preparation step when the spin_lock() function is lifted to the
caller of __list_lru_walk_one().
Invoke list_lru_walk_one() instead __list_lru_walk_one() when possible.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/list_lru.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index fcfb6c89ed47..ddbffbdd3d72 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -272,8 +272,8 @@ unsigned long list_lru_walk_node(struct list_lru *lru, =
int nid,
 	long isolated =3D 0;
 	int memcg_idx;
=20
-	isolated +=3D __list_lru_walk_one(lru, nid, -1, isolate, cb_arg,
-					nr_to_walk);
+	isolated +=3D list_lru_walk_one(lru, nid, NULL, isolate, cb_arg,
+				      nr_to_walk);
 	if (*nr_to_walk > 0 && list_lru_memcg_aware(lru)) {
 		for_each_memcg_cache_index(memcg_idx) {
 			isolated +=3D __list_lru_walk_one(lru, nid, memcg_idx,
--=20
2.18.0
