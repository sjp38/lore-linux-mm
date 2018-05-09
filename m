Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 110B66B0570
	for <linux-mm@kvack.org>; Wed,  9 May 2018 15:38:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x7-v6so4128553wrm.13
        for <linux-mm@kvack.org>; Wed, 09 May 2018 12:38:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m71-v6si8871061wmc.138.2018.05.09.12.38.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 12:38:45 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 3/8] md: raid5: use refcount_t for reference counting instead atomic_t
Date: Wed,  9 May 2018 21:36:40 +0200
Message-Id: <20180509193645.830-4-bigeasy@linutronix.de>
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

Most changes are 1:1 replacements except for
	BUG_ON(atomic_inc_return(&sh->count) !=3D 1);

which has been turned into
        refcount_inc(&sh->count);
        BUG_ON(refcount_read(&sh->count) !=3D 1);

Suggested-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/md/raid5-cache.c |  8 ++---
 drivers/md/raid5-ppl.c   |  2 +-
 drivers/md/raid5.c       | 67 ++++++++++++++++++++--------------------
 drivers/md/raid5.h       |  4 +--
 4 files changed, 41 insertions(+), 40 deletions(-)

diff --git a/drivers/md/raid5-cache.c b/drivers/md/raid5-cache.c
index 3c65f52b68f5..532fdf56c117 100644
--- a/drivers/md/raid5-cache.c
+++ b/drivers/md/raid5-cache.c
@@ -1049,7 +1049,7 @@ int r5l_write_stripe(struct r5l_log *log, struct stri=
pe_head *sh)
 	 * don't delay.
 	 */
 	clear_bit(STRIPE_DELAYED, &sh->state);
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
=20
 	mutex_lock(&log->io_mutex);
 	/* meta + data */
@@ -1388,7 +1388,7 @@ static void r5c_flush_stripe(struct r5conf *conf, str=
uct stripe_head *sh)
 	lockdep_assert_held(&conf->device_lock);
=20
 	list_del_init(&sh->lru);
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
=20
 	set_bit(STRIPE_HANDLE, &sh->state);
 	atomic_inc(&conf->active_stripes);
@@ -1491,7 +1491,7 @@ static void r5c_do_reclaim(struct r5conf *conf)
 			 */
 			if (!list_empty(&sh->lru) &&
 			    !test_bit(STRIPE_HANDLE, &sh->state) &&
-			    atomic_read(&sh->count) =3D=3D 0) {
+			    refcount_read(&sh->count) =3D=3D 0) {
 				r5c_flush_stripe(conf, sh);
 				if (count++ >=3D R5C_RECLAIM_STRIPE_GROUP)
 					break;
@@ -2912,7 +2912,7 @@ int r5c_cache_data(struct r5l_log *log, struct stripe=
_head *sh)
 	 * don't delay.
 	 */
 	clear_bit(STRIPE_DELAYED, &sh->state);
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
=20
 	mutex_lock(&log->io_mutex);
 	/* meta + data */
diff --git a/drivers/md/raid5-ppl.c b/drivers/md/raid5-ppl.c
index 42890a08375b..87840cfe7a80 100644
--- a/drivers/md/raid5-ppl.c
+++ b/drivers/md/raid5-ppl.c
@@ -388,7 +388,7 @@ int ppl_write_stripe(struct r5conf *conf, struct stripe=
_head *sh)
=20
 	set_bit(STRIPE_LOG_TRAPPED, &sh->state);
 	clear_bit(STRIPE_DELAYED, &sh->state);
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
=20
 	if (ppl_log_stripe(log, sh)) {
 		spin_lock_irq(&ppl_conf->no_mem_stripes_lock);
diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index be117d0a65a8..57ea0ae8c7ff 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -306,7 +306,7 @@ static void do_release_stripe(struct r5conf *conf, stru=
ct stripe_head *sh,
 static void __release_stripe(struct r5conf *conf, struct stripe_head *sh,
 			     struct list_head *temp_inactive_list)
 {
-	if (atomic_dec_and_test(&sh->count))
+	if (refcount_dec_and_test(&sh->count))
 		do_release_stripe(conf, sh, temp_inactive_list);
 }
=20
@@ -398,7 +398,7 @@ void raid5_release_stripe(struct stripe_head *sh)
=20
 	/* Avoid release_list until the last reference.
 	 */
-	if (atomic_add_unless(&sh->count, -1, 1))
+	if (refcount_dec_not_one(&sh->count))
 		return;
=20
 	if (unlikely(!conf->mddev->thread) ||
@@ -411,7 +411,7 @@ void raid5_release_stripe(struct stripe_head *sh)
 slow_path:
 	local_irq_save(flags);
 	/* we are ok here if STRIPE_ON_RELEASE_LIST is set or not */
-	if (atomic_dec_and_lock(&sh->count, &conf->device_lock)) {
+	if (refcount_dec_and_lock(&sh->count, &conf->device_lock)) {
 		INIT_LIST_HEAD(&list);
 		hash =3D sh->hash_lock_index;
 		do_release_stripe(conf, sh, &list);
@@ -501,7 +501,7 @@ static void init_stripe(struct stripe_head *sh, sector_=
t sector, int previous)
 	struct r5conf *conf =3D sh->raid_conf;
 	int i, seq;
=20
-	BUG_ON(atomic_read(&sh->count) !=3D 0);
+	BUG_ON(refcount_read(&sh->count) !=3D 0);
 	BUG_ON(test_bit(STRIPE_HANDLE, &sh->state));
 	BUG_ON(stripe_operations_active(sh));
 	BUG_ON(sh->batch_head);
@@ -678,11 +678,11 @@ raid5_get_active_stripe(struct r5conf *conf, sector_t=
 sector,
 					  &conf->cache_state);
 			} else {
 				init_stripe(sh, sector, previous);
-				atomic_inc(&sh->count);
+				refcount_inc(&sh->count);
 			}
-		} else if (!atomic_inc_not_zero(&sh->count)) {
+		} else if (!refcount_inc_not_zero(&sh->count)) {
 			spin_lock(&conf->device_lock);
-			if (!atomic_read(&sh->count)) {
+			if (!refcount_read(&sh->count)) {
 				if (!test_bit(STRIPE_HANDLE, &sh->state))
 					atomic_inc(&conf->active_stripes);
 				BUG_ON(list_empty(&sh->lru) &&
@@ -698,7 +698,7 @@ raid5_get_active_stripe(struct r5conf *conf, sector_t s=
ector,
 					sh->group =3D NULL;
 				}
 			}
-			atomic_inc(&sh->count);
+			refcount_inc(&sh->count);
 			spin_unlock(&conf->device_lock);
 		}
 	} while (sh =3D=3D NULL);
@@ -760,9 +760,9 @@ static void stripe_add_to_batch_list(struct r5conf *con=
f, struct stripe_head *sh
 	hash =3D stripe_hash_locks_hash(head_sector);
 	spin_lock_irq(conf->hash_locks + hash);
 	head =3D __find_stripe(conf, head_sector, conf->generation);
-	if (head && !atomic_inc_not_zero(&head->count)) {
+	if (head && !refcount_inc_not_zero(&head->count)) {
 		spin_lock(&conf->device_lock);
-		if (!atomic_read(&head->count)) {
+		if (!refcount_read(&head->count)) {
 			if (!test_bit(STRIPE_HANDLE, &head->state))
 				atomic_inc(&conf->active_stripes);
 			BUG_ON(list_empty(&head->lru) &&
@@ -778,7 +778,7 @@ static void stripe_add_to_batch_list(struct r5conf *con=
f, struct stripe_head *sh
 				head->group =3D NULL;
 			}
 		}
-		atomic_inc(&head->count);
+		refcount_inc(&head->count);
 		spin_unlock(&conf->device_lock);
 	}
 	spin_unlock_irq(conf->hash_locks + hash);
@@ -847,7 +847,7 @@ static void stripe_add_to_batch_list(struct r5conf *con=
f, struct stripe_head *sh
 		sh->batch_head->bm_seq =3D seq;
 	}
=20
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 unlock_out:
 	unlock_two_stripes(head, sh);
 out:
@@ -1110,9 +1110,9 @@ static void ops_run_io(struct stripe_head *sh, struct=
 stripe_head_state *s)
 			pr_debug("%s: for %llu schedule op %d on disc %d\n",
 				__func__, (unsigned long long)sh->sector,
 				bi->bi_opf, i);
-			atomic_inc(&sh->count);
+			refcount_inc(&sh->count);
 			if (sh !=3D head_sh)
-				atomic_inc(&head_sh->count);
+				refcount_inc(&head_sh->count);
 			if (use_new_offset(conf, sh))
 				bi->bi_iter.bi_sector =3D (sh->sector
 						 + rdev->new_data_offset);
@@ -1174,9 +1174,9 @@ static void ops_run_io(struct stripe_head *sh, struct=
 stripe_head_state *s)
 				 "replacement disc %d\n",
 				__func__, (unsigned long long)sh->sector,
 				rbi->bi_opf, i);
-			atomic_inc(&sh->count);
+			refcount_inc(&sh->count);
 			if (sh !=3D head_sh)
-				atomic_inc(&head_sh->count);
+				refcount_inc(&head_sh->count);
 			if (use_new_offset(conf, sh))
 				rbi->bi_iter.bi_sector =3D (sh->sector
 						  + rrdev->new_data_offset);
@@ -1354,7 +1354,7 @@ static void ops_run_biofill(struct stripe_head *sh)
 		}
 	}
=20
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 	init_async_submit(&submit, ASYNC_TX_ACK, tx, ops_complete_biofill, sh, NU=
LL);
 	async_trigger_callback(&submit);
 }
@@ -1432,7 +1432,7 @@ ops_run_compute5(struct stripe_head *sh, struct raid5=
_percpu *percpu)
 		if (i !=3D target)
 			xor_srcs[count++] =3D sh->dev[i].page;
=20
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
=20
 	init_async_submit(&submit, ASYNC_TX_FENCE|ASYNC_TX_XOR_ZERO_DST, NULL,
 			  ops_complete_compute, sh, to_addr_conv(sh, percpu, 0));
@@ -1521,7 +1521,7 @@ ops_run_compute6_1(struct stripe_head *sh, struct rai=
d5_percpu *percpu)
 	BUG_ON(!test_bit(R5_Wantcompute, &tgt->flags));
 	dest =3D tgt->page;
=20
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
=20
 	if (target =3D=3D qd_idx) {
 		count =3D set_syndrome_sources(blocks, sh, SYNDROME_SRC_ALL);
@@ -1596,7 +1596,7 @@ ops_run_compute6_2(struct stripe_head *sh, struct rai=
d5_percpu *percpu)
 	pr_debug("%s: stripe: %llu faila: %d failb: %d\n",
 		 __func__, (unsigned long long)sh->sector, faila, failb);
=20
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
=20
 	if (failb =3D=3D syndrome_disks+1) {
 		/* Q disk is one of the missing disks */
@@ -1867,7 +1867,7 @@ ops_run_reconstruct5(struct stripe_head *sh, struct r=
aid5_percpu *percpu,
 			break;
 	}
 	if (i >=3D sh->disks) {
-		atomic_inc(&sh->count);
+		refcount_inc(&sh->count);
 		set_bit(R5_Discard, &sh->dev[pd_idx].flags);
 		ops_complete_reconstruct(sh);
 		return;
@@ -1908,7 +1908,7 @@ ops_run_reconstruct5(struct stripe_head *sh, struct r=
aid5_percpu *percpu,
 		flags =3D ASYNC_TX_ACK |
 			(prexor ? ASYNC_TX_XOR_DROP_DST : ASYNC_TX_XOR_ZERO_DST);
=20
-		atomic_inc(&head_sh->count);
+		refcount_inc(&head_sh->count);
 		init_async_submit(&submit, flags, tx, ops_complete_reconstruct, head_sh,
 				  to_addr_conv(sh, percpu, j));
 	} else {
@@ -1950,7 +1950,7 @@ ops_run_reconstruct6(struct stripe_head *sh, struct r=
aid5_percpu *percpu,
 			break;
 	}
 	if (i >=3D sh->disks) {
-		atomic_inc(&sh->count);
+		refcount_inc(&sh->count);
 		set_bit(R5_Discard, &sh->dev[sh->pd_idx].flags);
 		set_bit(R5_Discard, &sh->dev[sh->qd_idx].flags);
 		ops_complete_reconstruct(sh);
@@ -1974,7 +1974,7 @@ ops_run_reconstruct6(struct stripe_head *sh, struct r=
aid5_percpu *percpu,
 				 struct stripe_head, batch_list) =3D=3D head_sh;
=20
 	if (last_stripe) {
-		atomic_inc(&head_sh->count);
+		refcount_inc(&head_sh->count);
 		init_async_submit(&submit, txflags, tx, ops_complete_reconstruct,
 				  head_sh, to_addr_conv(sh, percpu, j));
 	} else
@@ -2031,7 +2031,7 @@ static void ops_run_check_p(struct stripe_head *sh, s=
truct raid5_percpu *percpu)
 	tx =3D async_xor_val(xor_dest, xor_srcs, 0, count, STRIPE_SIZE,
 			   &sh->ops.zero_sum_result, &submit);
=20
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 	init_async_submit(&submit, ASYNC_TX_ACK, tx, ops_complete_check, sh, NULL=
);
 	tx =3D async_trigger_callback(&submit);
 }
@@ -2050,7 +2050,7 @@ static void ops_run_check_pq(struct stripe_head *sh, =
struct raid5_percpu *percpu
 	if (!checkp)
 		srcs[count] =3D NULL;
=20
-	atomic_inc(&sh->count);
+	refcount_inc(&sh->count);
 	init_async_submit(&submit, ASYNC_TX_ACK, NULL, ops_complete_check,
 			  sh, to_addr_conv(sh, percpu, 0));
 	async_syndrome_val(srcs, 0, count+2, STRIPE_SIZE,
@@ -2150,7 +2150,7 @@ static struct stripe_head *alloc_stripe(struct kmem_c=
ache *sc, gfp_t gfp,
 		INIT_LIST_HEAD(&sh->lru);
 		INIT_LIST_HEAD(&sh->r5c);
 		INIT_LIST_HEAD(&sh->log_list);
-		atomic_set(&sh->count, 1);
+		refcount_set(&sh->count, 1);
 		sh->raid_conf =3D conf;
 		sh->log_start =3D MaxSector;
 		for (i =3D 0; i < disks; i++) {
@@ -2451,7 +2451,7 @@ static int drop_one_stripe(struct r5conf *conf)
 	spin_unlock_irq(conf->hash_locks + hash);
 	if (!sh)
 		return 0;
-	BUG_ON(atomic_read(&sh->count));
+	BUG_ON(refcount_read(&sh->count));
 	shrink_buffers(sh);
 	free_stripe(conf->slab_cache, sh);
 	atomic_dec(&conf->active_stripes);
@@ -2483,7 +2483,7 @@ static void raid5_end_read_request(struct bio * bi)
 			break;
=20
 	pr_debug("end_read_request %llu/%d, count: %d, error %d.\n",
-		(unsigned long long)sh->sector, i, atomic_read(&sh->count),
+		(unsigned long long)sh->sector, i, refcount_read(&sh->count),
 		bi->bi_status);
 	if (i =3D=3D disks) {
 		bio_reset(bi);
@@ -2620,7 +2620,7 @@ static void raid5_end_write_request(struct bio *bi)
 		}
 	}
 	pr_debug("end_write_request %llu/%d, count %d, error: %d.\n",
-		(unsigned long long)sh->sector, i, atomic_read(&sh->count),
+		(unsigned long long)sh->sector, i, refcount_read(&sh->count),
 		bi->bi_status);
 	if (i =3D=3D disks) {
 		bio_reset(bi);
@@ -4687,7 +4687,7 @@ static void handle_stripe(struct stripe_head *sh)
 	pr_debug("handling stripe %llu, state=3D%#lx cnt=3D%d, "
 		"pd_idx=3D%d, qd_idx=3D%d\n, check:%d, reconstruct:%d\n",
 	       (unsigned long long)sh->sector, sh->state,
-	       atomic_read(&sh->count), sh->pd_idx, sh->qd_idx,
+	       refcount_read(&sh->count), sh->pd_idx, sh->qd_idx,
 	       sh->check_state, sh->reconstruct_state);
=20
 	analyse_stripe(sh, &s);
@@ -5062,7 +5062,7 @@ static void activate_bit_delay(struct r5conf *conf,
 		struct stripe_head *sh =3D list_entry(head.next, struct stripe_head, lru=
);
 		int hash;
 		list_del_init(&sh->lru);
-		atomic_inc(&sh->count);
+		refcount_inc(&sh->count);
 		hash =3D sh->hash_lock_index;
 		__release_stripe(conf, sh, &temp_inactive_list[hash]);
 	}
@@ -5387,7 +5387,8 @@ static struct stripe_head *__get_priority_stripe(stru=
ct r5conf *conf, int group)
 		sh->group =3D NULL;
 	}
 	list_del_init(&sh->lru);
-	BUG_ON(atomic_inc_return(&sh->count) !=3D 1);
+	refcount_inc(&sh->count);
+	BUG_ON(refcount_read(&sh->count) !=3D 1);
 	return sh;
 }
=20
diff --git a/drivers/md/raid5.h b/drivers/md/raid5.h
index 3f8da26032ac..bc2a24e99346 100644
--- a/drivers/md/raid5.h
+++ b/drivers/md/raid5.h
@@ -4,7 +4,7 @@
=20
 #include <linux/raid/xor.h>
 #include <linux/dmaengine.h>
-
+#include <linux/refcount.h>
 /*
  *
  * Each stripe contains one buffer per device.  Each buffer can be in
@@ -208,7 +208,7 @@ struct stripe_head {
 	short			ddf_layout;/* use DDF ordering to calculate Q */
 	short			hash_lock_index;
 	unsigned long		state;		/* state flags */
-	atomic_t		count;	      /* nr of active thread/requests */
+	refcount_t		count;	      /* nr of active thread/requests */
 	int			bm_seq;	/* sequence number for bitmap flushes */
 	int			disks;		/* disks in stripe */
 	int			overwrite_disks; /* total overwrite disks in stripe,
--=20
2.17.0
