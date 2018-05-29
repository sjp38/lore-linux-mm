Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 49F5A6B000C
	for <linux-mm@kvack.org>; Tue, 29 May 2018 17:17:33 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y124-v6so14509548qkc.8
        for <linux-mm@kvack.org>; Tue, 29 May 2018 14:17:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k195-v6sor125484qke.53.2018.05.29.14.17.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 14:17:32 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 03/13] blk-cgroup: allow controllers to output their own stats
Date: Tue, 29 May 2018 17:17:14 -0400
Message-Id: <20180529211724.4531-4-josef@toxicpanda.com>
In-Reply-To: <20180529211724.4531-1-josef@toxicpanda.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

blk-iolatency has a few stats that it would like to print out, and
instead of adding a bunch of crap to the generic code just provide a
helper so that controllers can add stuff to the stat line if they want
to.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 block/blk-cgroup.c         | 52 +++++++++++++++++++++++++++++++++++++++++++---
 include/linux/blk-cgroup.h |  3 +++
 2 files changed, 52 insertions(+), 3 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index eb85cb87c40f..9e767e4a852d 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -954,13 +954,28 @@ static int blkcg_print_stat(struct seq_file *sf, void *v)
 
 	hlist_for_each_entry_rcu(blkg, &blkcg->blkg_list, blkcg_node) {
 		const char *dname;
+		char *buf;
 		struct blkg_rwstat rwstat;
 		u64 rbytes, wbytes, rios, wios;
+		size_t size = seq_get_buf(sf, &buf), count = 0, total = 0;
+		int i;
 
 		dname = blkg_dev_name(blkg);
 		if (!dname)
 			continue;
 
+		/*
+		 * Hooray string manipulation, count is the size written NOT
+		 * INCLUDING THE \0, so size is now count+1 less than what we
+		 * had before, but we want to start writing the next bit from
+		 * the \0 so we only add count to buf.
+		 */
+		count = snprintf(buf, size, "%s ", dname);
+		if (count >= size)
+			continue;
+		buf += count;
+		size -= count + 1;
+
 		spin_lock_irq(blkg->q->queue_lock);
 
 		rwstat = blkg_rwstat_recursive_sum(blkg, NULL,
@@ -975,9 +990,40 @@ static int blkcg_print_stat(struct seq_file *sf, void *v)
 
 		spin_unlock_irq(blkg->q->queue_lock);
 
-		if (rbytes || wbytes || rios || wios)
-			seq_printf(sf, "%s rbytes=%llu wbytes=%llu rios=%llu wios=%llu\n",
-				   dname, rbytes, wbytes, rios, wios);
+		if (rbytes || wbytes || rios || wios) {
+			total += count;
+			count = snprintf(buf, size,
+					 "rbytes=%llu wbytes=%llu rios=%llu wios=%llu",
+					 rbytes, wbytes, rios, wios);
+			if (count >= size)
+				continue;
+			buf += count;
+			total += count;
+			size -= count + 1;
+		}
+
+		mutex_lock(&blkcg_pol_mutex);
+		for (i = 0; i < BLKCG_MAX_POLS; i++) {
+			struct blkcg_policy *pol = blkcg_policy[i];
+
+			if (!blkg->pd[i] || !pol->pd_stat_fn)
+				continue;
+
+			count = pol->pd_stat_fn(blkg->pd[i], buf, size);
+			if (count >= size)
+				continue;
+			buf += count;
+			total += count;
+			size -= count + 1;
+		}
+		mutex_unlock(&blkcg_pol_mutex);
+		if (total) {
+			count = snprintf(buf, size, "\n");
+			if (count >= size)
+				continue;
+			total += count;
+			seq_commit(sf, total);
+		}
 	}
 
 	rcu_read_unlock();
diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index 69aa71dc0c04..b41292726c0f 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -148,6 +148,8 @@ typedef void (blkcg_pol_online_pd_fn)(struct blkg_policy_data *pd);
 typedef void (blkcg_pol_offline_pd_fn)(struct blkg_policy_data *pd);
 typedef void (blkcg_pol_free_pd_fn)(struct blkg_policy_data *pd);
 typedef void (blkcg_pol_reset_pd_stats_fn)(struct blkg_policy_data *pd);
+typedef size_t (blkcg_pol_stat_pd_fn)(struct blkg_policy_data *pd, char *buf,
+				      size_t size);
 
 struct blkcg_policy {
 	int				plid;
@@ -167,6 +169,7 @@ struct blkcg_policy {
 	blkcg_pol_offline_pd_fn		*pd_offline_fn;
 	blkcg_pol_free_pd_fn		*pd_free_fn;
 	blkcg_pol_reset_pd_stats_fn	*pd_reset_stats_fn;
+	blkcg_pol_stat_pd_fn		*pd_stat_fn;
 };
 
 extern struct blkcg blkcg_root;
-- 
2.14.3
