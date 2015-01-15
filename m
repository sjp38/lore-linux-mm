Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBD66B006E
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 13:49:18 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id u14so5339285lbd.12
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:49:17 -0800 (PST)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [2a02:6b8:b030::69])
        by mx.google.com with ESMTPS id yo1si826123lbb.92.2015.01.15.10.49.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 10:49:17 -0800 (PST)
Subject: [PATCH 2/6] memcg: dirty-set limiting and filtered writeback
From: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 15 Jan 2015 21:49:13 +0300
Message-ID: <20150115184913.10450.38580.stgit@buzz>
In-Reply-To: <20150115180242.10450.92.stgit@buzz>
References: <20150115180242.10450.92.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: Roman Gushchin <klamm@yandex-team.ru>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, koct9i@gmail.com

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

mem_cgroup_dirty_limits() checks thresholds and schedules per-bdi
writeback work (where ->for_memcg is set) which writes only inodes
where dirty limit is exceeded for owner memcg or for whole bdi.

Interface: memory.dirty_ratio percent of memory limit used as threshold
(0 = unlimited, default 50). Background threshold is a half of that.
And fs_dirty_threshold line in memory.stat shows current threshold.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/fs-writeback.c                |   18 ++++-
 include/linux/backing-dev.h      |    1 
 include/linux/memcontrol.h       |    6 ++
 include/linux/writeback.h        |    1 
 include/trace/events/writeback.h |    1 
 mm/memcontrol.c                  |  145 ++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c              |   25 ++++++-
 7 files changed, 190 insertions(+), 7 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 2d609a5..9034768 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -20,6 +20,7 @@
 #include <linux/sched.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/memcontrol.h>
 #include <linux/pagemap.h>
 #include <linux/kthread.h>
 #include <linux/writeback.h>
@@ -47,6 +48,7 @@ struct wb_writeback_work {
 	unsigned int range_cyclic:1;
 	unsigned int for_background:1;
 	unsigned int for_sync:1;	/* sync(2) WB_SYNC_ALL writeback */
+	unsigned int for_memcg:1;
 	enum wb_reason reason;		/* why was writeback initiated? */
 
 	struct list_head list;		/* pending work list */
@@ -137,6 +139,7 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
 	work->reason	= reason;
+	work->for_memcg = reason == WB_REASON_FOR_MEMCG;
 
 	bdi_queue_work(bdi, work);
 }
@@ -258,15 +261,16 @@ static int move_expired_inodes(struct list_head *delaying_queue,
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
-	struct inode *inode;
+	struct inode *inode, *next;
 	int do_sb_sort = 0;
 	int moved = 0;
 
-	while (!list_empty(delaying_queue)) {
-		inode = wb_inode(delaying_queue->prev);
+	list_for_each_entry_safe(inode, next, delaying_queue, i_wb_list) {
 		if (work->older_than_this &&
 		    inode_dirtied_after(inode, *work->older_than_this))
 			break;
+		if (work->for_memcg && !mem_cgroup_dirty_exceeded(inode))
+			continue;
 		list_move(&inode->i_wb_list, &tmp);
 		moved++;
 		if (sb_is_blkdev_sb(inode->i_sb))
@@ -650,6 +654,11 @@ static long writeback_sb_inodes(struct super_block *sb,
 			break;
 		}
 
+		if (work->for_memcg && !mem_cgroup_dirty_exceeded(inode)) {
+			redirty_tail(inode, wb);
+			continue;
+		}
+
 		/*
 		 * Don't bother with new inodes or inodes being freed, first
 		 * kind does not need periodic writeout yet, and for the latter
@@ -1014,6 +1023,9 @@ static long wb_do_writeback(struct bdi_writeback *wb)
 
 		wrote += wb_writeback(wb, work);
 
+		if (work->for_memcg)
+			clear_bit(BDI_memcg_writeback_running, &bdi->state);
+
 		/*
 		 * Notify the caller of completion if this is a synchronous
 		 * work item, otherwise just free it.
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 5da6012..91b55d8 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -32,6 +32,7 @@ enum bdi_state {
 	BDI_sync_congested,	/* The sync queue is getting full */
 	BDI_registered,		/* bdi_register() was done */
 	BDI_writeback_running,	/* Writeback is in progress */
+	BDI_memcg_writeback_running,
 };
 
 typedef int (congested_fn)(void *, int);
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b281333..ae05563 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -178,6 +178,9 @@ void mem_cgroup_dec_page_dirty(struct address_space *mapping);
 void mem_cgroup_inc_page_writeback(struct address_space *mapping);
 void mem_cgroup_dec_page_writeback(struct address_space *mapping);
 void mem_cgroup_forget_mapping(struct address_space *mapping);
+bool mem_cgroup_dirty_limits(struct address_space *mapping, unsigned long *dirty,
+			     unsigned long *thresh, unsigned long *bg_thresh);
+bool mem_cgroup_dirty_exceeded(struct inode *inode);
 
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
@@ -352,6 +355,9 @@ static inline void mem_cgroup_dec_page_dirty(struct address_space *mapping) {}
 static inline void mem_cgroup_inc_page_writeback(struct address_space *mapping) {}
 static inline void mem_cgroup_dec_page_writeback(struct address_space *mapping) {}
 static inline void mem_cgroup_forget_mapping(struct address_space *mapping) {}
+static inline bool mem_cgroup_dirty_limits(struct address_space *mapping, unsigned long *dirty,
+			     unsigned long *thresh, unsigned long *bg_thresh) { return false; }
+static inline bool mem_cgroup_dirty_exceeded(struct inode *inode) { return false; }
 
 #endif /* CONFIG_MEMCG */
 
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 0004833..1239fa6 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -47,6 +47,7 @@ enum wb_reason {
 	WB_REASON_LAPTOP_TIMER,
 	WB_REASON_FREE_MORE_MEM,
 	WB_REASON_FS_FREE_SPACE,
+	WB_REASON_FOR_MEMCG,
 	/*
 	 * There is no bdi forker thread any more and works are done
 	 * by emergency worker, however, this is TPs userland visible
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index cee02d6..106a8d7 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -29,6 +29,7 @@
 		{WB_REASON_LAPTOP_TIMER,	"laptop_timer"},	\
 		{WB_REASON_FREE_MORE_MEM,	"free_more_memory"},	\
 		{WB_REASON_FS_FREE_SPACE,	"fs_free_space"},	\
+		{WB_REASON_FOR_MEMCG,		"for_memcg"},		\
 		{WB_REASON_FORKER_THREAD,	"forker_thread"}
 
 struct wb_writeback_work;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c5655f1..17d966a3b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -363,6 +363,10 @@ struct mem_cgroup {
 
 	struct percpu_counter nr_dirty;
 	struct percpu_counter nr_writeback;
+	unsigned long dirty_threshold;
+	unsigned long dirty_background;
+	unsigned int dirty_exceeded;
+	unsigned int dirty_ratio;
 
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
@@ -3060,6 +3064,8 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 
 static DEFINE_MUTEX(memcg_limit_mutex);
 
+static void mem_cgroup_update_dirty_thresh(struct mem_cgroup *memcg);
+
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 				   unsigned long limit)
 {
@@ -3112,6 +3118,9 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 	if (!ret && enlarge)
 		memcg_oom_recover(memcg);
 
+	if (!ret)
+		mem_cgroup_update_dirty_thresh(memcg);
+
 	return ret;
 }
 
@@ -3750,6 +3759,8 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 			percpu_counter_sum_positive(&memcg->nr_dirty));
 	seq_printf(m, "fs_writeback %llu\n", PAGE_SIZE *
 			percpu_counter_sum_positive(&memcg->nr_writeback));
+	seq_printf(m, "fs_dirty_threshold %llu\n", (u64)PAGE_SIZE *
+			memcg->dirty_threshold);
 
 #ifdef CONFIG_DEBUG_VM
 	{
@@ -3803,6 +3814,25 @@ static int mem_cgroup_swappiness_write(struct cgroup_subsys_state *css,
 	return 0;
 }
 
+static u64 mem_cgroup_dirty_ratio_read(struct cgroup_subsys_state *css,
+				       struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return memcg->dirty_ratio;
+}
+
+static int mem_cgroup_dirty_ratio_write(struct cgroup_subsys_state *css,
+					struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	memcg->dirty_ratio = val;
+	mem_cgroup_update_dirty_thresh(memcg);
+
+	return 0;
+}
+
 static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 {
 	struct mem_cgroup_threshold_ary *t;
@@ -4454,6 +4484,11 @@ static struct cftype mem_cgroup_files[] = {
 		.write_u64 = mem_cgroup_swappiness_write,
 	},
 	{
+		.name = "dirty_ratio",
+		.read_u64 = mem_cgroup_dirty_ratio_read,
+		.write_u64 = mem_cgroup_dirty_ratio_write,
+	},
+	{
 		.name = "move_charge_at_immigrate",
 		.read_u64 = mem_cgroup_move_charge_read,
 		.write_u64 = mem_cgroup_move_charge_write,
@@ -4686,6 +4721,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
+		memcg->dirty_ratio = 50; /* default value for cgroups */
 	}
 
 	memcg->last_scanned_node = MAX_NUMNODES;
@@ -4750,6 +4786,10 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		if (parent != root_mem_cgroup)
 			memory_cgrp_subsys.broken_hierarchy = true;
 	}
+
+	memcg->dirty_ratio = parent->dirty_ratio;
+	mem_cgroup_update_dirty_thresh(memcg);
+
 	mutex_unlock(&memcg_create_mutex);
 
 	ret = memcg_init_kmem(memcg, &memory_cgrp_subsys);
@@ -5939,6 +5979,111 @@ void mem_cgroup_forget_mapping(struct address_space *mapping)
 	}
 }
 
+static void mem_cgroup_update_dirty_thresh(struct mem_cgroup *memcg)
+{
+	struct cgroup_subsys_state *pos;
+
+	if (memcg->memory.limit > totalram_pages || !memcg->dirty_ratio) {
+		memcg->dirty_threshold = 0; /* 0 means no limit at all*/
+		memcg->dirty_background = ULONG_MAX;
+	} else {
+		memcg->dirty_threshold = memcg->memory.limit *
+					 memcg->dirty_ratio / 100;
+		memcg->dirty_background = memcg->dirty_threshold / 2;
+	}
+
+	/* Propogate threshold into childs */
+	rcu_read_lock();
+	css_for_each_descendant_pre(pos, &memcg->css) {
+		struct mem_cgroup *memcg = mem_cgroup_from_css(pos);
+		struct mem_cgroup *parent = parent_mem_cgroup(memcg);
+
+		if (!(pos->flags & CSS_ONLINE))
+			continue;
+
+		if (memcg->dirty_threshold == 0 ||
+		    memcg->dirty_threshold == ULONG_MAX) {
+			if (parent && parent->use_hierarchy &&
+				      parent->dirty_threshold)
+				memcg->dirty_threshold = ULONG_MAX;
+			else
+				memcg->dirty_threshold = 0;
+		}
+	}
+	rcu_read_unlock();
+}
+
+bool mem_cgroup_dirty_limits(struct address_space *mapping,
+			     unsigned long *pdirty,
+			     unsigned long *pthresh,
+			     unsigned long *pbg_thresh)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	unsigned long dirty, threshold, background;
+	struct mem_cgroup *memcg;
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
+		/* No limit at all */
+		if (memcg->dirty_threshold == 0)
+			break;
+		/* No limit here, but must check parent */
+		if (memcg->dirty_threshold == ULONG_MAX)
+			continue;
+		dirty = percpu_counter_read_positive(&memcg->nr_dirty) +
+			percpu_counter_read_positive(&memcg->nr_writeback);
+		threshold = memcg->dirty_threshold;
+		background = memcg->dirty_background;
+		if (dirty > background) {
+			if (!memcg->dirty_exceeded)
+				memcg->dirty_exceeded = 1;
+			rcu_read_unlock();
+			if (dirty > (background + threshold) / 2 &&
+			    !test_and_set_bit(BDI_memcg_writeback_running,
+					      &bdi->state))
+				bdi_start_writeback(bdi, dirty - background,
+						    WB_REASON_FOR_MEMCG);
+			*pdirty = dirty;
+			*pthresh = threshold;
+			*pbg_thresh = background;
+			return true;
+		}
+	}
+	rcu_read_unlock();
+
+	return false;
+}
+
+bool mem_cgroup_dirty_exceeded(struct inode *inode)
+{
+	struct address_space *mapping = inode->i_mapping;
+	struct mem_cgroup *memcg;
+	unsigned long dirty;
+
+	if (mapping->backing_dev_info->dirty_exceeded)
+		return true;
+
+	rcu_read_lock();
+	memcg = rcu_dereference(mapping->i_memcg);
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
+		if (!memcg->dirty_threshold) {
+			memcg = NULL;
+			break;
+		}
+		if (!memcg->dirty_exceeded)
+			continue;
+		dirty = percpu_counter_read_positive(&memcg->nr_dirty) +
+			percpu_counter_read_positive(&memcg->nr_writeback);
+		if (dirty > memcg->dirty_background)
+			break;
+		memcg->dirty_exceeded = 0;
+	}
+	rcu_read_unlock();
+
+	return memcg != NULL;
+}
+
 /*
  * subsys_initcall() for memory controller.
  *
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index afaf263..325510f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1328,6 +1328,17 @@ static inline void bdi_dirty_limits(struct backing_dev_info *bdi,
 	}
 }
 
+static unsigned long mem_cgroup_position_ratio(unsigned long dirty,
+		unsigned long thresh, unsigned long bg_thresh)
+{
+	unsigned long setpoint = dirty_freerun_ceiling(thresh, bg_thresh);
+
+	if (dirty > thresh)
+		return 0;
+
+	return pos_ratio_polynom(setpoint, dirty, thresh);
+}
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -1362,6 +1373,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		unsigned long uninitialized_var(bdi_dirty);
 		unsigned long dirty;
 		unsigned long bg_thresh;
+		bool memcg;
 
 		/*
 		 * Unstable writes are a feature of certain networked
@@ -1387,6 +1399,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 			bg_thresh = background_thresh;
 		}
 
+		memcg = mem_cgroup_dirty_limits(mapping, &dirty, &thresh, &bg_thresh);
+
 		/*
 		 * Throttle it only when the background writeback cannot
 		 * catch-up. This avoids (excessively) small writeouts
@@ -1404,7 +1418,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 			break;
 		}
 
-		if (unlikely(!writeback_in_progress(bdi)))
+		if (unlikely(!writeback_in_progress(bdi) && !memcg))
 			bdi_start_background_writeback(bdi);
 
 		if (!strictlimit)
@@ -1421,9 +1435,12 @@ static void balance_dirty_pages(struct address_space *mapping,
 				     start_time);
 
 		dirty_ratelimit = bdi->dirty_ratelimit;
-		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
-					       background_thresh, nr_dirty,
-					       bdi_thresh, bdi_dirty);
+		if (memcg)
+			pos_ratio = mem_cgroup_position_ratio(dirty, thresh, bg_thresh);
+		else
+			pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
+					background_thresh, nr_dirty,
+					bdi_thresh, bdi_dirty);
 		task_ratelimit = ((u64)dirty_ratelimit * pos_ratio) >>
 							RATELIMIT_CALC_SHIFT;
 		max_pause = bdi_max_pause(bdi, bdi_dirty);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
