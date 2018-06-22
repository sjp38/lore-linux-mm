Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 46D666B000E
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:12:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w9-v6so4704754wrl.13
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 08:12:37 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b11-v6si676488wri.417.2018.06.22.08.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 08:12:35 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 3/3] mm: list_lru: Add lock_irq member to __list_lru_init()
Date: Fri, 22 Jun 2018 17:12:21 +0200
Message-Id: <20180622151221.28167-4-bigeasy@linutronix.de>
In-Reply-To: <20180622151221.28167-1-bigeasy@linutronix.de>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

scan_shadow_nodes() is the only user of __list_lru_walk_one() which
disables interrupts before invoking it. The reason is that nlru->lock is
nesting inside IRQ-safe i_pages lock. Some functions unconditionally
acquire the lock with the _irq() suffix.

__list_lru_walk_one() can't acquire the lock unconditionally with _irq()
suffix because it might invoke a callback which unlocks the nlru->lock
and invokes a sleeping function without enabling interrupts.

Add an argument to __list_lru_init() which identifies wheather the
nlru->lock needs to be acquired with disabling interrupts or without.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/list_lru.h | 12 ++++++++----
 mm/list_lru.c            | 14 ++++++++++----
 mm/workingset.c          | 12 ++++--------
 3 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 96def9d15b1b..c2161c3a1809 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -51,18 +51,22 @@ struct list_lru_node {
=20
 struct list_lru {
 	struct list_lru_node	*node;
+	bool			lock_irq;
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 	struct list_head	list;
 #endif
 };
=20
 void list_lru_destroy(struct list_lru *lru);
-int __list_lru_init(struct list_lru *lru, bool memcg_aware,
+int __list_lru_init(struct list_lru *lru, bool memcg_aware, bool lock_irq,
 		    struct lock_class_key *key);
=20
-#define list_lru_init(lru)		__list_lru_init((lru), false, NULL)
-#define list_lru_init_key(lru, key)	__list_lru_init((lru), false, (key))
-#define list_lru_init_memcg(lru)	__list_lru_init((lru), true, NULL)
+#define list_lru_init(lru)		__list_lru_init((lru), false, false, \
+							NULL)
+#define list_lru_init_key(lru, key)	__list_lru_init((lru), false, false, \
+							(key))
+#define list_lru_init_memcg(lru)	__list_lru_init((lru), true, false, \
+							NULL)
=20
 int memcg_update_all_list_lrus(int num_memcgs);
 void memcg_drain_all_list_lrus(int src_idx, int dst_idx);
diff --git a/mm/list_lru.c b/mm/list_lru.c
index fcfb6c89ed47..1c49d48078e4 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -204,7 +204,10 @@ __list_lru_walk_one(struct list_lru *lru, int nid, int=
 memcg_idx,
 	struct list_head *item, *n;
 	unsigned long isolated =3D 0;
=20
-	spin_lock(&nlru->lock);
+	if (lru->lock_irq)
+		spin_lock_irq(&nlru->lock);
+	else
+		spin_lock(&nlru->lock);
 	l =3D list_lru_from_memcg_idx(nlru, memcg_idx);
 restart:
 	list_for_each_safe(item, n, &l->list) {
@@ -251,7 +254,10 @@ __list_lru_walk_one(struct list_lru *lru, int nid, int=
 memcg_idx,
 		}
 	}
=20
-	spin_unlock(&nlru->lock);
+	if (lru->lock_irq)
+		spin_unlock_irq(&nlru->lock);
+	else
+		spin_unlock(&nlru->lock);
 	return isolated;
 }
=20
@@ -553,7 +559,7 @@ static void memcg_destroy_list_lru(struct list_lru *lru)
 }
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
=20
-int __list_lru_init(struct list_lru *lru, bool memcg_aware,
+int __list_lru_init(struct list_lru *lru, bool memcg_aware, bool lock_irq,
 		    struct lock_class_key *key)
 {
 	int i;
@@ -580,7 +586,7 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aw=
are,
 		lru->node =3D NULL;
 		goto out;
 	}
-
+	lru->lock_irq =3D lock_irq;
 	list_lru_register(lru);
 out:
 	memcg_put_cache_ids();
diff --git a/mm/workingset.c b/mm/workingset.c
index 529480c21f93..23ce00f48212 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -480,13 +480,8 @@ static enum lru_status shadow_lru_isolate(struct list_=
head *item,
 static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
 				       struct shrink_control *sc)
 {
-	unsigned long ret;
-
-	/* list_lru lock nests inside the IRQ-safe i_pages lock */
-	local_irq_disable();
-	ret =3D list_lru_shrink_walk(&shadow_nodes, sc, shadow_lru_isolate, NULL);
-	local_irq_enable();
-	return ret;
+	return list_lru_shrink_walk(&shadow_nodes, sc, shadow_lru_isolate,
+				    NULL);
 }
=20
 static struct shrinker workingset_shadow_shrinker =3D {
@@ -523,7 +518,8 @@ static int __init workingset_init(void)
 	pr_info("workingset: timestamp_bits=3D%d max_order=3D%d bucket_order=3D%u=
\n",
 	       timestamp_bits, max_order, bucket_order);
=20
-	ret =3D __list_lru_init(&shadow_nodes, true, &shadow_nodes_key);
+	/* list_lru lock nests inside the IRQ-safe i_pages lock */
+	ret =3D __list_lru_init(&shadow_nodes, true, true, &shadow_nodes_key);
 	if (ret)
 		goto err;
 	ret =3D register_shrinker(&workingset_shadow_shrinker);
--=20
2.18.0
