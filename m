Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id DAAC76B026A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:19:35 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id r4-v6so8593744wrt.2
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:19:35 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m10-v6si27929387wrm.287.2018.07.16.04.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jul 2018 04:19:34 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 4/4] mm/list_lru: Introduce list_lru_shrink_walk_irq()
Date: Mon, 16 Jul 2018 13:19:21 +0200
Message-Id: <20180716111921.5365-5-bigeasy@linutronix.de>
In-Reply-To: <20180716111921.5365-1-bigeasy@linutronix.de>
References: <20180716111921.5365-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Provide list_lru_shrink_walk_irq() and let it behave like
list_lru_walk_one() except that it locks the spinlock with
spin_lock_irq(). This is used by scan_shadow_nodes() because its lock
nests within the i_pages lock which is acquired with IRQ.
This change allows to use proper locking promitives instead hand crafted
lock_irq_disable() plus spin_lock().
There is no EXPORT_SYMBOL provided because the current user is in-KERNEL
only.

Add list_lru_shrink_walk_irq() which acquires the spinlock with the
proper locking primitives.

Reviewed-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/list_lru.h | 25 +++++++++++++++++++++++++
 mm/list_lru.c            | 15 +++++++++++++++
 mm/workingset.c          |  8 ++------
 3 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index d9c16f2f2f00..aa5efd9351eb 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -166,6 +166,23 @@ unsigned long list_lru_walk_one(struct list_lru *lru,
 				int nid, struct mem_cgroup *memcg,
 				list_lru_walk_cb isolate, void *cb_arg,
 				unsigned long *nr_to_walk);
+/**
+ * list_lru_walk_one_irq: walk a list_lru, isolating and disposing freeabl=
e items.
+ * @lru: the lru pointer.
+ * @nid: the node id to scan from.
+ * @memcg: the cgroup to scan from.
+ * @isolate: callback function that is resposible for deciding what to do =
with
+ *  the item currently being scanned
+ * @cb_arg: opaque type that will be passed to @isolate
+ * @nr_to_walk: how many items to scan.
+ *
+ * Same as @list_lru_walk_one except that the spinlock is acquired with
+ * spin_lock_irq().
+ */
+unsigned long list_lru_walk_one_irq(struct list_lru *lru,
+				    int nid, struct mem_cgroup *memcg,
+				    list_lru_walk_cb isolate, void *cb_arg,
+				    unsigned long *nr_to_walk);
 unsigned long list_lru_walk_node(struct list_lru *lru, int nid,
 				 list_lru_walk_cb isolate, void *cb_arg,
 				 unsigned long *nr_to_walk);
@@ -178,6 +195,14 @@ list_lru_shrink_walk(struct list_lru *lru, struct shri=
nk_control *sc,
 				 &sc->nr_to_scan);
 }
=20
+static inline unsigned long
+list_lru_shrink_walk_irq(struct list_lru *lru, struct shrink_control *sc,
+			 list_lru_walk_cb isolate, void *cb_arg)
+{
+	return list_lru_walk_one_irq(lru, sc->nid, sc->memcg, isolate, cb_arg,
+				     &sc->nr_to_scan);
+}
+
 static inline unsigned long
 list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
 	      void *cb_arg, unsigned long nr_to_walk)
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 7b7a737f0963..89349a0276de 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -289,6 +289,21 @@ list_lru_walk_one(struct list_lru *lru, int nid, struc=
t mem_cgroup *memcg,
 }
 EXPORT_SYMBOL_GPL(list_lru_walk_one);
=20
+unsigned long
+list_lru_walk_one_irq(struct list_lru *lru, int nid, struct mem_cgroup *me=
mcg,
+		      list_lru_walk_cb isolate, void *cb_arg,
+		      unsigned long *nr_to_walk)
+{
+	struct list_lru_node *nlru =3D &lru->node[nid];
+	unsigned long ret;
+
+	spin_lock_irq(&nlru->lock);
+	ret =3D __list_lru_walk_one(nlru, memcg_cache_id(memcg), isolate, cb_arg,
+				  nr_to_walk);
+	spin_unlock_irq(&nlru->lock);
+	return ret;
+}
+
 unsigned long list_lru_walk_node(struct list_lru *lru, int nid,
 				 list_lru_walk_cb isolate, void *cb_arg,
 				 unsigned long *nr_to_walk)
diff --git a/mm/workingset.c b/mm/workingset.c
index 06b45147e892..0b4f471d07ba 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -501,13 +501,9 @@ static enum lru_status shadow_lru_isolate(struct list_=
head *item,
 static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
 				       struct shrink_control *sc)
 {
-	unsigned long ret;
-
 	/* list_lru lock nests inside the IRQ-safe i_pages lock */
-	local_irq_disable();
-	ret =3D list_lru_shrink_walk(&shadow_nodes, sc, shadow_lru_isolate, NULL);
-	local_irq_enable();
-	return ret;
+	return list_lru_shrink_walk_irq(&shadow_nodes, sc, shadow_lru_isolate,
+					NULL);
 }
=20
 static struct shrinker workingset_shadow_shrinker =3D {
--=20
2.18.0
