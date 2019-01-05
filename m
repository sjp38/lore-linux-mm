Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 84CA78E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 19:21:49 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id q23so42774870ior.6
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 16:21:49 -0800 (PST)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id m18si610150itb.1.2019.01.04.16.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 16:21:48 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v2 PATCH 3/5] mm: memcontrol: introduce wipe_on_offline interface
Date: Sat,  5 Jan 2019 08:19:18 +0800
Message-Id: <1546647560-40026-4-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546647560-40026-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1546647560-40026-1-git-send-email-yang.shi@linux.alibaba.com>
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
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/memcontrol.h |  3 +++
 mm/memcontrol.c            | 49 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+)

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
index 75208a2..5a13c6b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2918,6 +2918,35 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
 	return mem_cgroup_force_empty(memcg) ?: nbytes;
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
 
@@ -4569,6 +4603,15 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	page_counter_set_min(&memcg->memory, 0);
 	page_counter_set_low(&memcg->memory, 0);
 
+	/*
+	 * Reclaim as much as possible memory when offlining.
+	 *
+	 * Do it after min/low is reset otherwise some memory might
+	 * be protected by min/low.
+	 */
+	if (memcg->wipe_on_offline)
+		mem_cgroup_force_empty(memcg);
+
 	memcg_offline_kmem(memcg);
 	wb_memcg_offline(memcg);
 
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
