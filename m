Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4293F8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 14:18:17 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id m13so4713924pls.15
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 11:18:17 -0800 (PST)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id q16si22876825pgh.185.2019.01.09.11.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 11:18:15 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v3 PATCH 3/5] mm: memcontrol: introduce wipe_on_offline interface
Date: Thu, 10 Jan 2019 03:14:43 +0800
Message-Id: <1547061285-100329-4-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, hannes@cmpxchg.org, shakeelb@google.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We have some usecases which create and remove memcgs very frequently,
and the tasks in the memcg may just access the files which are unlikely
accessed by anyone else.  So, we prefer force_empty the memcg before
rmdir'ing it to reclaim the page cache so that they don't get
accumulated to incur unnecessary memory pressure.  Since the memory
pressure may incur direct reclaim to harm some latency sensitive
applications.

Force empty would help out such usecase, however force empty reclaims
memory synchronously when writing to memory.force_empty.  It may take
some time to return and the afterwards operations are blocked by it.
Although this can be done in background, some usecases may need create
new memcg with the same name right after the old one is deleted.  So,
the creation might get blocked by the before reclaim/remove operation.

Delaying memory reclaim in cgroup offline for such usecase sounds
reasonable.  Introduced a new interface, called wipe_on_offline for both
default and legacy hierarchy, which does memory reclaim in css offline
kworker.

Writing to 1 would enable it, writing 0 would disable it.

Suggested-by: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/memcontrol.h |  3 +++
 mm/memcontrol.c            | 53 ++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 54 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 83ae11c..2f1258a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -311,6 +311,9 @@ struct mem_cgroup {
 	struct list_head event_list;
 	spinlock_t event_list_lock;
 
+	/* Reclaim as much as possible memory in offline kworker */
+	bool wipe_on_offline;
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index eaa3970..ff50810 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2918,6 +2918,35 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
 	return mem_cgroup_force_empty(memcg, true) ?: nbytes;
 }
 
+static int wipe_on_offline_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+
+	seq_printf(m, "%lu\n", (unsigned long)memcg->wipe_on_offline);
+
+	return 0;
+}
+
+static int wipe_on_offline_write(struct cgroup_subsys_state *css,
+				 struct cftype *cft, u64 val)
+{
+	int ret = 0;
+
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	if (mem_cgroup_is_root(memcg))
+		return -EINVAL;
+
+	if (val == 0)
+		memcg->wipe_on_offline = false;
+	else if (val == 1)
+		memcg->wipe_on_offline = true;
+	else
+		ret = -EINVAL;
+
+	return ret;
+}
+
 static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
 				     struct cftype *cft)
 {
@@ -4283,6 +4312,11 @@ static ssize_t memcg_write_event_control(struct kernfs_open_file *of,
 		.write = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read_u64,
 	},
+	{
+		.name = "wipe_on_offline",
+		.seq_show = wipe_on_offline_show,
+		.write_u64 = wipe_on_offline_write,
+	},
 	{ },	/* terminate */
 };
 
@@ -4569,11 +4603,20 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	page_counter_set_min(&memcg->memory, 0);
 	page_counter_set_low(&memcg->memory, 0);
 
+	/*
+	 * Reclaim as much as possible memory when offlining.
+	 *
+	 * Do it after min/low is reset otherwise some memory might
+	 * be protected by min/low.
+	 */
+	if (memcg->wipe_on_offline)
+		mem_cgroup_force_empty(memcg, false);
+	else
+		drain_all_stock(memcg);
+
 	memcg_offline_kmem(memcg);
 	wb_memcg_offline(memcg);
 
-	drain_all_stock(memcg);
-
 	mem_cgroup_id_put(memcg);
 }
 
@@ -5694,6 +5737,12 @@ static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
 		.seq_show = memory_oom_group_show,
 		.write = memory_oom_group_write,
 	},
+	{
+		.name = "wipe_on_offline",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = wipe_on_offline_show,
+		.write_u64 = wipe_on_offline_write,
+	},
 	{ }	/* terminate */
 };
 
-- 
1.8.3.1
