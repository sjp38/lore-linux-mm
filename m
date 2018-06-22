Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4974A6B000A
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:12:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j14-v6so4565164wro.7
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 08:12:35 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p26-v6si4221658wra.244.2018.06.22.08.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 08:12:34 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/3] mm: workingset: remove local_irq_disable() from count_shadow_nodes()
Date: Fri, 22 Jun 2018 17:12:19 +0200
Message-Id: <20180622151221.28167-2-bigeasy@linutronix.de>
In-Reply-To: <20180622151221.28167-1-bigeasy@linutronix.de>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Kirill Tkhai <ktkhai@virtuozzo.com>

In commit 0c7c1bed7e13 ("mm: make counting of list_lru_one::nr_items
lockless") the
	spin_lock(&nlru->lock);

statement was replaced with
	rcu_read_lock();

in __list_lru_count_one(). The comment in count_shadow_nodes() says that
the local_irq_disable() is required because the lock must be acquired
with disabled interrupts and (spin_lock()) does not do so.
Since the lock is replaced with rcu_read_lock() the local_irq_disable()
is no longer needed. The code path is
  list_lru_shrink_count()
    -> list_lru_count_one()
      -> __list_lru_count_one()
        -> rcu_read_lock()
        -> list_lru_from_memcg_idx()
        -> rcu_read_unlock()

Remove the local_irq_disable() statement.

Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/workingset.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 40ee02c83978..ed8151180899 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -366,10 +366,7 @@ static unsigned long count_shadow_nodes(struct shrinke=
r *shrinker,
 	unsigned long nodes;
 	unsigned long cache;
=20
-	/* list_lru lock nests inside the IRQ-safe i_pages lock */
-	local_irq_disable();
 	nodes =3D list_lru_shrink_count(&shadow_nodes, sc);
-	local_irq_enable();
=20
 	/*
 	 * Approximate a reasonable limit for the radix tree nodes
--=20
2.18.0
