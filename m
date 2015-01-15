Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6516B0073
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 13:49:26 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id hv19so15211458lab.0
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:49:25 -0800 (PST)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [5.255.216.100])
        by mx.google.com with ESMTPS id n8si900455lbc.28.2015.01.15.10.49.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 10:49:20 -0800 (PST)
Subject: [PATCH 6/6] memcg: filesystem bandwidth controller
From: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 15 Jan 2015 21:49:18 +0300
Message-ID: <20150115184918.10450.86621.stgit@buzz>
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

This is example of filesystem bandwidth controller build on the top of
dirty memory accounting, percpu_ratelimit and delay-injection.

Cgroup charges read/write requests into rate-limiters and injects delays
which controls overall speed.

Interface:
memory.fs_bps_limit     bytes per second, 0 == unlimited
memory.fs_iops_limit    iops limit, 0 == unlimited
Statistics: fs_io_bytes and fs_io_operations in memory.stat

For small bandwidth limits memory limit also must be set into corresponded
value otherwise injected delay after writing dirty-set might be enormous.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 block/blk-core.c           |    2 +
 fs/direct-io.c             |    2 +
 include/linux/memcontrol.h |    4 ++
 mm/memcontrol.c            |  102 +++++++++++++++++++++++++++++++++++++++++++-
 mm/readahead.c             |    2 +
 5 files changed, 110 insertions(+), 2 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 3ad4055..799f5f5 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1966,6 +1966,7 @@ void submit_bio(int rw, struct bio *bio)
 			count_vm_events(PGPGOUT, count);
 		} else {
 			task_io_account_read(bio->bi_iter.bi_size);
+			mem_cgroup_account_bandwidth(bio->bi_iter.bi_size);
 			count_vm_events(PGPGIN, count);
 		}
 
@@ -2208,6 +2209,7 @@ void blk_account_io_start(struct request *rq, bool new_io)
 		}
 		part_round_stats(cpu, part);
 		part_inc_in_flight(part, rw);
+		mem_cgroup_account_ioop();
 		rq->part = part;
 	}
 
diff --git a/fs/direct-io.c b/fs/direct-io.c
index e181b6b..9c60a82 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -24,6 +24,7 @@
 #include <linux/types.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/memcontrol.h>
 #include <linux/slab.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
@@ -775,6 +776,7 @@ submit_page_section(struct dio *dio, struct dio_submit *sdio, struct page *page,
 		 * Read accounting is performed in submit_bio()
 		 */
 		task_io_account_write(len);
+		mem_cgroup_account_bandwidth(len);
 	}
 
 	/*
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3f89e9b..633310e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -183,6 +183,8 @@ bool mem_cgroup_dirty_limits(struct address_space *mapping, unsigned long *dirty
 bool mem_cgroup_dirty_exceeded(struct inode *inode);
 void mem_cgroup_poke_writeback(struct address_space *mapping,
 			       struct mem_cgroup *memcg);
+void mem_cgroup_account_bandwidth(unsigned long bytes);
+void mem_cgroup_account_ioop(void);
 
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
@@ -362,6 +364,8 @@ static inline bool mem_cgroup_dirty_limits(struct address_space *mapping, unsign
 static inline bool mem_cgroup_dirty_exceeded(struct inode *inode) { return false; }
 static inline void mem_cgroup_poke_writeback(struct address_space *mapping,
 					     struct mem_cgroup *memcg) { }
+static inline void mem_cgroup_account_bandwidth(unsigned long bytes) {}
+static inline void mem_cgroup_account_ioop(void) {}
 
 #endif /* CONFIG_MEMCG */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d9d345c..f49fbbf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -27,6 +27,7 @@
 
 #include <linux/page_counter.h>
 #include <linux/memcontrol.h>
+#include <linux/percpu_ratelimit.h>
 #include <linux/cgroup.h>
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
@@ -368,6 +369,9 @@ struct mem_cgroup {
 	unsigned int dirty_exceeded;
 	unsigned int dirty_ratio;
 
+	struct percpu_ratelimit iobw;
+	struct percpu_ratelimit ioop;
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
@@ -3762,6 +3766,12 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 	seq_printf(m, "fs_dirty_threshold %llu\n", (u64)PAGE_SIZE *
 			memcg->dirty_threshold);
 
+	seq_printf(m, "fs_io_bytes %llu\n",
+			percpu_ratelimit_sum(&memcg->iobw));
+	seq_printf(m, "fs_io_operations %llu\n",
+			percpu_ratelimit_sum(&memcg->ioop));
+
+
 #ifdef CONFIG_DEBUG_VM
 	{
 		int nid, zid;
@@ -3833,6 +3843,40 @@ static int mem_cgroup_dirty_ratio_write(struct cgroup_subsys_state *css,
 	return 0;
 }
 
+static u64 mem_cgroup_get_bps_limit(
+		struct cgroup_subsys_state *css, struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return percpu_ratelimit_quota(&memcg->iobw, NSEC_PER_SEC);
+}
+
+static int mem_cgroup_set_bps_limit(
+		struct cgroup_subsys_state *css, struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	percpu_ratelimit_setup(&memcg->iobw, val, NSEC_PER_SEC);
+	return 0;
+}
+
+static u64 mem_cgroup_get_iops_limit(
+		struct cgroup_subsys_state *css, struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return percpu_ratelimit_quota(&memcg->ioop, NSEC_PER_SEC);
+}
+
+static int mem_cgroup_set_iops_limit(
+		struct cgroup_subsys_state *css, struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	percpu_ratelimit_setup(&memcg->ioop, val, NSEC_PER_SEC);
+	return 0;
+}
+
 static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 {
 	struct mem_cgroup_threshold_ary *t;
@@ -4489,6 +4533,16 @@ static struct cftype mem_cgroup_files[] = {
 		.write_u64 = mem_cgroup_dirty_ratio_write,
 	},
 	{
+		.name = "fs_bps_limit",
+		.read_u64 = mem_cgroup_get_bps_limit,
+		.write_u64 = mem_cgroup_set_bps_limit,
+	},
+	{
+		.name = "fs_iops_limit",
+		.read_u64 = mem_cgroup_get_iops_limit,
+		.write_u64 = mem_cgroup_set_iops_limit,
+	},
+	{
 		.name = "move_charge_at_immigrate",
 		.read_u64 = mem_cgroup_move_charge_read,
 		.write_u64 = mem_cgroup_move_charge_write,
@@ -4621,7 +4675,9 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 		return NULL;
 
 	if (percpu_counter_init(&memcg->nr_dirty, 0, GFP_KERNEL) ||
-	    percpu_counter_init(&memcg->nr_writeback, 0, GFP_KERNEL))
+	    percpu_counter_init(&memcg->nr_writeback, 0, GFP_KERNEL) ||
+	    percpu_ratelimit_init(&memcg->iobw, GFP_KERNEL) ||
+	    percpu_ratelimit_init(&memcg->ioop, GFP_KERNEL))
 		goto out_free;
 
 	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
@@ -4633,6 +4689,8 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 out_free:
 	percpu_counter_destroy(&memcg->nr_dirty);
 	percpu_counter_destroy(&memcg->nr_writeback);
+	percpu_ratelimit_destroy(&memcg->iobw);
+	percpu_ratelimit_destroy(&memcg->ioop);
 	kfree(memcg);
 	return NULL;
 }
@@ -4659,6 +4717,8 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 
 	percpu_counter_destroy(&memcg->nr_dirty);
 	percpu_counter_destroy(&memcg->nr_writeback);
+	percpu_ratelimit_destroy(&memcg->iobw);
+	percpu_ratelimit_destroy(&memcg->ioop);
 	free_percpu(memcg->stat);
 
 	disarm_static_keys(memcg);
@@ -5956,8 +6016,44 @@ void mem_cgroup_inc_page_writeback(struct address_space *mapping)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_mapping(mapping);
 
-	for (; memcg; memcg = parent_mem_cgroup(memcg))
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
 		percpu_counter_inc(&memcg->nr_writeback);
+		percpu_ratelimit_charge(&memcg->iobw, PAGE_CACHE_SIZE);
+	}
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
+		if (percpu_ratelimit_blocked(&memcg->iobw))
+			inject_delay(percpu_ratelimit_target(&memcg->iobw));
+	}
+	rcu_read_unlock();
+}
+
+void mem_cgroup_account_bandwidth(unsigned long bytes)
+{
+	struct mem_cgroup *memcg;
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
+		if (percpu_ratelimit_charge(&memcg->iobw, bytes))
+			inject_delay(percpu_ratelimit_target(&memcg->iobw));
+	}
+	rcu_read_unlock();
+}
+
+void mem_cgroup_account_ioop(void)
+{
+	struct mem_cgroup *memcg;
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
+		if (percpu_ratelimit_charge(&memcg->ioop, 1))
+			inject_delay(percpu_ratelimit_target(&memcg->ioop));
+	}
+	rcu_read_unlock();
 }
 
 void mem_cgroup_dec_page_writeback(struct address_space *mapping)
@@ -6038,6 +6134,8 @@ bool mem_cgroup_dirty_limits(struct address_space *mapping,
 		if (dirty > background) {
 			if (!memcg->dirty_exceeded)
 				memcg->dirty_exceeded = 1;
+			if (percpu_ratelimit_blocked(&memcg->iobw))
+				inject_delay(percpu_ratelimit_target(&memcg->iobw));
 			rcu_read_unlock();
 			if (dirty > (background + threshold) / 2 &&
 			    !test_and_set_bit(BDI_memcg_writeback_running,
diff --git a/mm/readahead.c b/mm/readahead.c
index 17b9172..7c7ec23 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -16,6 +16,7 @@
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 #include <linux/syscalls.h>
+#include <linux/memcontrol.h>
 #include <linux/file.h>
 
 #include "internal.h"
@@ -102,6 +103,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			break;
 		}
 		task_io_account_read(PAGE_CACHE_SIZE);
+		mem_cgroup_account_bandwidth(PAGE_CACHE_SIZE);
 	}
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
