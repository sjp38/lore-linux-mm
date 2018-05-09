Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 965616B056E
	for <linux-mm@kvack.org>; Wed,  9 May 2018 15:38:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k16-v6so24460921wrh.6
        for <linux-mm@kvack.org>; Wed, 09 May 2018 12:38:44 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a5-v6si8074115wrf.92.2018.05.09.12.38.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 12:38:43 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/8] bdi: use refcount_t for reference counting instead atomic_t
Date: Wed,  9 May 2018 21:36:38 +0200
Message-Id: <20180509193645.830-2-bigeasy@linutronix.de>
In-Reply-To: <20180509193645.830-1-bigeasy@linutronix.de>
References: <20180509193645.830-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

refcount_t type and corresponding API should be used instead of atomic_t wh=
en
the variable is used as a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free situations.

Suggested-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/backing-dev-defs.h |  3 ++-
 include/linux/backing-dev.h      |  4 ++--
 mm/backing-dev.c                 | 12 ++++++------
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-d=
efs.h
index 0bd432a4d7bd..81c75934ca5b 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -12,6 +12,7 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/kref.h>
+#include <linux/refcount.h>
=20
 struct page;
 struct device;
@@ -76,7 +77,7 @@ enum wb_reason {
  */
 struct bdi_writeback_congested {
 	unsigned long state;		/* WB_[a]sync_congested flags */
-	atomic_t refcnt;		/* nr of attached wb's and blkg */
+	refcount_t refcnt;		/* nr of attached wb's and blkg */
=20
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct backing_dev_info *__bdi;	/* the associated bdi, set to NULL
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 72ca0f3d39f3..c28a47cbe355 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -404,13 +404,13 @@ static inline bool inode_cgwb_enabled(struct inode *i=
node)
 static inline struct bdi_writeback_congested *
 wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t =
gfp)
 {
-	atomic_inc(&bdi->wb_congested->refcnt);
+	refcount_inc(&bdi->wb_congested->refcnt);
 	return bdi->wb_congested;
 }
=20
 static inline void wb_congested_put(struct bdi_writeback_congested *conges=
ted)
 {
-	if (atomic_dec_and_test(&congested->refcnt))
+	if (refcount_dec_and_test(&congested->refcnt))
 		kfree(congested);
 }
=20
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 7441bd93b732..7984a872073e 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -450,10 +450,10 @@ wb_congested_get_create(struct backing_dev_info *bdi,=
 int blkcg_id, gfp_t gfp)
 	if (new_congested) {
 		/* !found and storage for new one already allocated, insert */
 		congested =3D new_congested;
-		new_congested =3D NULL;
 		rb_link_node(&congested->rb_node, parent, node);
 		rb_insert_color(&congested->rb_node, &bdi->cgwb_congested_tree);
-		goto found;
+		spin_unlock_irqrestore(&cgwb_lock, flags);
+		return congested;
 	}
=20
 	spin_unlock_irqrestore(&cgwb_lock, flags);
@@ -463,13 +463,13 @@ wb_congested_get_create(struct backing_dev_info *bdi,=
 int blkcg_id, gfp_t gfp)
 	if (!new_congested)
 		return NULL;
=20
-	atomic_set(&new_congested->refcnt, 0);
+	refcount_set(&new_congested->refcnt, 1);
 	new_congested->__bdi =3D bdi;
 	new_congested->blkcg_id =3D blkcg_id;
 	goto retry;
=20
 found:
-	atomic_inc(&congested->refcnt);
+	refcount_inc(&congested->refcnt);
 	spin_unlock_irqrestore(&cgwb_lock, flags);
 	kfree(new_congested);
 	return congested;
@@ -486,7 +486,7 @@ void wb_congested_put(struct bdi_writeback_congested *c=
ongested)
 	unsigned long flags;
=20
 	local_irq_save(flags);
-	if (!atomic_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
+	if (!refcount_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
 		local_irq_restore(flags);
 		return;
 	}
@@ -794,7 +794,7 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
 	if (!bdi->wb_congested)
 		return -ENOMEM;
=20
-	atomic_set(&bdi->wb_congested->refcnt, 1);
+	refcount_set(&bdi->wb_congested->refcnt, 1);
=20
 	err =3D wb_init(&bdi->wb, bdi, 1, GFP_KERNEL);
 	if (err) {
--=20
2.17.0
