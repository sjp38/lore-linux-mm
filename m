Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6A26B02F4
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:07:50 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id s1so2218651ybl.5
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:07:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a33si1563083ybj.113.2017.12.15.14.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:59 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 76/78] md: Convert raid5-cache to XArray
Date: Fri, 15 Dec 2017 14:04:48 -0800
Message-Id: <20171215220450.7899-77-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This is the first user of the radix tree I've converted which was
storing numbers rather than pointers.  I'm fairly pleased with how
well it came out.  There's less boiler-plate involved than there was
with the radix tree, so that's a win.  It does use the advanced API,
and I think that's a signal that there needs to be a separate API for
using the XArray for only integers.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/md/raid5-cache.c | 119 ++++++++++++++++-------------------------------
 1 file changed, 40 insertions(+), 79 deletions(-)

diff --git a/drivers/md/raid5-cache.c b/drivers/md/raid5-cache.c
index 39f31f07ffe9..2c8ad0ed9b48 100644
--- a/drivers/md/raid5-cache.c
+++ b/drivers/md/raid5-cache.c
@@ -158,9 +158,8 @@ struct r5l_log {
 	/* to disable write back during in degraded mode */
 	struct work_struct disable_writeback_work;
 
-	/* to for chunk_aligned_read in writeback mode, details below */
-	spinlock_t tree_lock;
-	struct radix_tree_root big_stripe_tree;
+	/* for chunk_aligned_read in writeback mode, details below */
+	struct xarray big_stripe;
 };
 
 /*
@@ -170,9 +169,8 @@ struct r5l_log {
  * chunk contains 64 4kB-page, so this chunk contain 64 stripes). For
  * chunk_aligned_read, these stripes are grouped into one "big_stripe".
  * For each big_stripe, we count how many stripes of this big_stripe
- * are in the write back cache. These data are tracked in a radix tree
- * (big_stripe_tree). We use radix_tree item pointer as the counter.
- * r5c_tree_index() is used to calculate keys for the radix tree.
+ * are in the write back cache. This counter is tracked in an xarray
+ * (big_stripe). r5c_index() is used to calculate the index.
  *
  * chunk_aligned_read() calls r5c_big_stripe_cached() to look up
  * big_stripe of each chunk in the tree. If this big_stripe is in the
@@ -180,9 +178,9 @@ struct r5l_log {
  * rcu_read_lock().
  *
  * It is necessary to remember whether a stripe is counted in
- * big_stripe_tree. Instead of adding new flag, we reuses existing flags:
+ * big_stripe. Instead of adding new flag, we reuses existing flags:
  * STRIPE_R5C_PARTIAL_STRIPE and STRIPE_R5C_FULL_STRIPE. If either of these
- * two flags are set, the stripe is counted in big_stripe_tree. This
+ * two flags are set, the stripe is counted in big_stripe. This
  * requires moving set_bit(STRIPE_R5C_PARTIAL_STRIPE) to
  * r5c_try_caching_write(); and moving clear_bit of
  * STRIPE_R5C_PARTIAL_STRIPE and STRIPE_R5C_FULL_STRIPE to
@@ -190,23 +188,13 @@ struct r5l_log {
  */
 
 /*
- * radix tree requests lowest 2 bits of data pointer to be 2b'00.
- * So it is necessary to left shift the counter by 2 bits before using it
- * as data pointer of the tree.
- */
-#define R5C_RADIX_COUNT_SHIFT 2
-
-/*
- * calculate key for big_stripe_tree
+ * calculate key for big_stripe
  *
  * sect: align_bi->bi_iter.bi_sector or sh->sector
  */
-static inline sector_t r5c_tree_index(struct r5conf *conf,
-				      sector_t sect)
+static inline sector_t r5c_index(struct r5conf *conf, sector_t sect)
 {
-	sector_t offset;
-
-	offset = sector_div(sect, conf->chunk_sectors);
+	sector_div(sect, conf->chunk_sectors);
 	return sect;
 }
 
@@ -2646,10 +2634,6 @@ int r5c_try_caching_write(struct r5conf *conf,
 	int i;
 	struct r5dev *dev;
 	int to_cache = 0;
-	void **pslot;
-	sector_t tree_index;
-	int ret;
-	uintptr_t refcount;
 
 	BUG_ON(!r5c_is_writeback(log));
 
@@ -2697,39 +2681,29 @@ int r5c_try_caching_write(struct r5conf *conf,
 		}
 	}
 
-	/* if the stripe is not counted in big_stripe_tree, add it now */
+	/* if the stripe is not counted in big_stripe, add it now */
 	if (!test_bit(STRIPE_R5C_PARTIAL_STRIPE, &sh->state) &&
 	    !test_bit(STRIPE_R5C_FULL_STRIPE, &sh->state)) {
-		tree_index = r5c_tree_index(conf, sh->sector);
-		spin_lock(&log->tree_lock);
-		pslot = radix_tree_lookup_slot(&log->big_stripe_tree,
-					       tree_index);
-		if (pslot) {
-			refcount = (uintptr_t)radix_tree_deref_slot_protected(
-				pslot, &log->tree_lock) >>
-				R5C_RADIX_COUNT_SHIFT;
-			radix_tree_replace_slot(
-				&log->big_stripe_tree, pslot,
-				(void *)((refcount + 1) << R5C_RADIX_COUNT_SHIFT));
-		} else {
-			/*
-			 * this radix_tree_insert can fail safely, so no
-			 * need to call radix_tree_preload()
-			 */
-			ret = radix_tree_insert(
-				&log->big_stripe_tree, tree_index,
-				(void *)(1 << R5C_RADIX_COUNT_SHIFT));
-			if (ret) {
-				spin_unlock(&log->tree_lock);
-				r5c_make_stripe_write_out(sh);
-				return -EAGAIN;
-			}
+		XA_STATE(xas, &log->big_stripe, r5c_index(conf, sh->sector));
+		void *entry;
+
+		/* Caller would rather handle failures than supply GFP flags */
+		xas_lock(&xas);
+		entry = xas_create(&xas);
+		if (entry)
+			entry = xa_mk_value(xa_to_value(entry) + 1);
+		else
+			entry = xa_mk_value(1);
+		xas_store(&xas, entry);
+		xas_unlock(&xas);
+		if (xas_error(&xas)) {
+			r5c_make_stripe_write_out(sh);
+			return -EAGAIN;
 		}
-		spin_unlock(&log->tree_lock);
 
 		/*
 		 * set STRIPE_R5C_PARTIAL_STRIPE, this shows the stripe is
-		 * counted in the radix tree
+		 * counted in big_stripe
 		 */
 		set_bit(STRIPE_R5C_PARTIAL_STRIPE, &sh->state);
 		atomic_inc(&conf->r5c_cached_partial_stripes);
@@ -2812,9 +2786,6 @@ void r5c_finish_stripe_write_out(struct r5conf *conf,
 	struct r5l_log *log = conf->log;
 	int i;
 	int do_wakeup = 0;
-	sector_t tree_index;
-	void **pslot;
-	uintptr_t refcount;
 
 	if (!log || !test_bit(R5_InJournal, &sh->dev[sh->pd_idx].flags))
 		return;
@@ -2852,24 +2823,21 @@ void r5c_finish_stripe_write_out(struct r5conf *conf,
 	atomic_dec(&log->stripe_in_journal_count);
 	r5c_update_log_state(log);
 
-	/* stop counting this stripe in big_stripe_tree */
+	/* stop counting this stripe in big_stripe */
 	if (test_bit(STRIPE_R5C_PARTIAL_STRIPE, &sh->state) ||
 	    test_bit(STRIPE_R5C_FULL_STRIPE, &sh->state)) {
-		tree_index = r5c_tree_index(conf, sh->sector);
-		spin_lock(&log->tree_lock);
-		pslot = radix_tree_lookup_slot(&log->big_stripe_tree,
-					       tree_index);
-		BUG_ON(pslot == NULL);
-		refcount = (uintptr_t)radix_tree_deref_slot_protected(
-			pslot, &log->tree_lock) >>
-			R5C_RADIX_COUNT_SHIFT;
-		if (refcount == 1)
-			radix_tree_delete(&log->big_stripe_tree, tree_index);
+		XA_STATE(xas, &log->big_stripe, r5c_index(conf, sh->sector));
+		void *entry;
+
+		xas_lock(&xas);
+		entry = xas_load(&xas);
+		BUG_ON(!entry);
+		if (entry == xa_mk_value(1))
+			entry = NULL;
 		else
-			radix_tree_replace_slot(
-				&log->big_stripe_tree, pslot,
-				(void *)((refcount - 1) << R5C_RADIX_COUNT_SHIFT));
-		spin_unlock(&log->tree_lock);
+			entry = xa_mk_value(xa_to_value(entry) - 1);
+		xas_store(&xas, entry);
+		xas_unlock(&xas);
 	}
 
 	if (test_and_clear_bit(STRIPE_R5C_PARTIAL_STRIPE, &sh->state)) {
@@ -2949,16 +2917,10 @@ int r5c_cache_data(struct r5l_log *log, struct stripe_head *sh)
 bool r5c_big_stripe_cached(struct r5conf *conf, sector_t sect)
 {
 	struct r5l_log *log = conf->log;
-	sector_t tree_index;
-	void *slot;
 
 	if (!log)
 		return false;
-
-	WARN_ON_ONCE(!rcu_read_lock_held());
-	tree_index = r5c_tree_index(conf, sect);
-	slot = radix_tree_lookup(&log->big_stripe_tree, tree_index);
-	return slot != NULL;
+	return xa_load(&log->big_stripe, r5c_index(conf, sect)) != NULL;
 }
 
 static int r5l_load_log(struct r5l_log *log)
@@ -3112,8 +3074,7 @@ int r5l_init_log(struct r5conf *conf, struct md_rdev *rdev)
 	if (!log->meta_pool)
 		goto out_mempool;
 
-	spin_lock_init(&log->tree_lock);
-	INIT_RADIX_TREE(&log->big_stripe_tree, GFP_NOWAIT | __GFP_NOWARN);
+	xa_init(&log->big_stripe);
 
 	log->reclaim_thread = md_register_thread(r5l_reclaim_thread,
 						 log->rdev->mddev, "reclaim");
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
