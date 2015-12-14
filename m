Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 73B7F6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 06:09:54 -0500 (EST)
Received: by padhk6 with SMTP id hk6so62284364pad.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 03:09:54 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id mi6si6086346pab.95.2015.12.14.03.09.53
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 03:09:53 -0800 (PST)
From: "Wang, Zhi A" <zhi.a.wang@intel.com>
Subject: [PATCH] mm: mempool: Factor out mempool_refill()
Date: Mon, 14 Dec 2015 11:09:43 +0000
Message-ID: <F3B0350DF4CB6849A642218320DE483D4B866043@SHSMSX101.ccr.corp.intel.com>
References: <1449978390-10931-1-git-send-email-zhi.a.wang@intel.com>
In-Reply-To: <1449978390-10931-1-git-send-email-zhi.a.wang@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>

This patch factors out mempool_refill() from mempool_resize(). It's reasona=
ble
that the mempool user wants to refill the pool immdiately when it has chanc=
e
e.g. inside a sleepible context, so that next time in the IRQ context the p=
ool
would have much more available elements to allocate.

After the refactor, mempool_refill() can also executes with mempool_resize(=
)
/mempool_alloc/mempool_free() or another mempool_refill().

Signed-off-by: Zhi Wang <zhi.a.wang@intel.com>
---
 include/linux/mempool.h |  1 +
 mm/mempool.c            | 61 ++++++++++++++++++++++++++++++++++++---------=
----
 2 files changed, 46 insertions(+), 16 deletions(-)

diff --git a/include/linux/mempool.h b/include/linux/mempool.h
index 69b6951..71f7460 100644
--- a/include/linux/mempool.h
+++ b/include/linux/mempool.h
@@ -30,6 +30,7 @@ extern mempool_t *mempool_create_node(int min_nr, mempool=
_alloc_t *alloc_fn,
 			gfp_t gfp_mask, int nid);
=20
 extern int mempool_resize(mempool_t *pool, int new_min_nr);
+extern void mempool_refill(mempool_t *pool);
 extern void mempool_destroy(mempool_t *pool);
 extern void * mempool_alloc(mempool_t *pool, gfp_t gfp_mask);
 extern void mempool_free(void *element, mempool_t *pool);
diff --git a/mm/mempool.c b/mm/mempool.c
index 004d42b..139c477 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -223,6 +223,47 @@ mempool_t *mempool_create_node(int min_nr, mempool_all=
oc_t *alloc_fn,
 EXPORT_SYMBOL(mempool_create_node);
=20
 /**
+ * mempool_refill - refill an existing memory pool immediately
+ * @pool:       pointer to the memory pool which was allocated via
+ *              mempool_create().
+ *
+ * This function tries to refill the pool with new elements
+ * immediately. Similar with mempool_resize(), it cannot be
+ * guaranteed that the pool will be fully filled immediately.
+ *
+ * Note, the caller must guarantee that no mempool_destroy is called
+ * while this function is running. mempool_alloc() & mempool_free()
+ * might be called (eg. from IRQ contexts) while this function executes.
+ */
+void mempool_refill(mempool_t *pool)
+{
+	void *element;
+	unsigned long flags;
+
+	spin_lock_irqsave(&pool->lock, flags);
+	if (pool->curr_nr >=3D pool->min_nr) {
+		spin_unlock_irqrestore(&pool->lock, flags);
+		return;
+	}
+
+	while (pool->curr_nr < pool->min_nr) {
+		spin_unlock_irqrestore(&pool->lock, flags);
+		element =3D pool->alloc(GFP_KERNEL, pool->pool_data);
+		if (!element)
+			return;
+		spin_lock_irqsave(&pool->lock, flags);
+		if (pool->curr_nr < pool->min_nr) {
+			add_element(pool, element);
+		} else {
+			spin_unlock_irqrestore(&pool->lock, flags);
+			pool->free(element, pool->pool_data);	/* Raced */
+			return;
+		}
+	}
+}
+EXPORT_SYMBOL(mempool_refill);
+
+/**
  * mempool_resize - resize an existing memory pool
  * @pool:       pointer to the memory pool which was allocated via
  *              mempool_create().
@@ -256,7 +297,8 @@ int mempool_resize(mempool_t *pool, int new_min_nr)
 			spin_lock_irqsave(&pool->lock, flags);
 		}
 		pool->min_nr =3D new_min_nr;
-		goto out_unlock;
+		spin_unlock_irqrestore(&pool->lock, flags);
+		goto out;
 	}
 	spin_unlock_irqrestore(&pool->lock, flags);
=20
@@ -279,22 +321,9 @@ int mempool_resize(mempool_t *pool, int new_min_nr)
 	pool->elements =3D new_elements;
 	pool->min_nr =3D new_min_nr;
=20
-	while (pool->curr_nr < pool->min_nr) {
-		spin_unlock_irqrestore(&pool->lock, flags);
-		element =3D pool->alloc(GFP_KERNEL, pool->pool_data);
-		if (!element)
-			goto out;
-		spin_lock_irqsave(&pool->lock, flags);
-		if (pool->curr_nr < pool->min_nr) {
-			add_element(pool, element);
-		} else {
-			spin_unlock_irqrestore(&pool->lock, flags);
-			pool->free(element, pool->pool_data);	/* Raced */
-			goto out;
-		}
-	}
-out_unlock:
 	spin_unlock_irqrestore(&pool->lock, flags);
+
+	mempool_refill(pool);
 out:
 	return 0;
 }
--=20
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
