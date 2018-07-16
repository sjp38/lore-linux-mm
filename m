Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07F186B0008
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:19:34 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z16-v6so8279356wrs.22
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:19:33 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q74-v6si2308368wmd.156.2018.07.16.04.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jul 2018 04:19:32 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/4] mm/list_lru: use list_lru_walk_one() in list_lru_walk_node()
Date: Mon, 16 Jul 2018 13:19:18 +0200
Message-Id: <20180716111921.5365-2-bigeasy@linutronix.de>
In-Reply-To: <20180716111921.5365-1-bigeasy@linutronix.de>
References: <20180716111921.5365-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

list_lru_walk_node() invokes __list_lru_walk_one() with -1 as the
memcg_idx parameter. The same can be achieved by list_lru_walk_one() and
passing NULL as memcg argument which then gets converted into -1. This
is a preparation step when the spin_lock() function is lifted to the
caller of __list_lru_walk_one().
Invoke list_lru_walk_one() instead __list_lru_walk_one() when possible.

Reviewed-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/list_lru.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index ca6dbcfe4256..344306714636 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -294,8 +294,8 @@ unsigned long list_lru_walk_node(struct list_lru *lru, =
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
