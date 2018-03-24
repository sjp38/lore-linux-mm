Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 89F516B0012
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 12:51:46 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id z124so6594724ywd.21
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 09:51:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5-v6sor4762566ybc.173.2018.03.24.09.51.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 09:51:45 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/2] mm, memcontrol: Implement memory.swap.events
Date: Sat, 24 Mar 2018 09:51:27 -0700
Message-Id: <20180324165127.701194-3-tj@kernel.org>
In-Reply-To: <20180324165127.701194-1-tj@kernel.org>
References: <20180324165127.701194-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, linux-api@vger.kernel.org

Add swap max and fail events so that userland can monitor and respond
to running out of swap.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-api@vger.kernel.org
---
 Documentation/cgroup-v2.txt | 16 ++++++++++++++++
 include/linux/memcontrol.h  |  5 +++++
 mm/memcontrol.c             | 24 +++++++++++++++++++++++-
 3 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 74cdeae..b0dda10 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1199,6 +1199,22 @@ PAGE_SIZE multiple when read back.
 	Swap usage hard limit.  If a cgroup's swap usage reaches this
 	limit, anonymous memory of the cgroup will not be swapped out.
 
+  memory.swap.events
+	A read-only flat-keyed file which exists on non-root cgroups.
+	The following entries are defined.  Unless specified
+	otherwise, a value change in this file generates a file
+	modified event.
+
+	  max
+		The number of times the cgroup's swap usage was about
+		to go over the max boundary and swap allocation
+		failed.
+
+	  fail
+		The number of times swap allocation failed either
+		because of running out of swap system-wide or max
+		limit.
+
 
 Usage Guidelines
 ~~~~~~~~~~~~~~~~
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 85a8f00..f198339 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -54,6 +54,8 @@ enum memcg_event_item {
 	MEMCG_HIGH,
 	MEMCG_MAX,
 	MEMCG_OOM,
+	MEMCG_SWAP_MAX,
+	MEMCG_SWAP_FAIL,
 	MEMCG_NR_EVENTS,
 };
 
@@ -202,6 +204,9 @@ struct mem_cgroup {
 	/* handle for "memory.events" */
 	struct cgroup_file events_file;
 
+	/* handle for "memory.swap.events" */
+	struct cgroup_file swap_events_file;
+
 	/* protect arrays of thresholds */
 	struct mutex thresholds_lock;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9f9c8a7..1a14d4a4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5987,13 +5987,17 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
 	if (!memcg)
 		return 0;
 
-	if (!entry.val)
+	if (!entry.val) {
+		mem_cgroup_event(memcg, MEMCG_SWAP_FAIL);
 		return 0;
+	}
 
 	memcg = mem_cgroup_id_get_online(memcg);
 
 	if (!mem_cgroup_is_root(memcg) &&
 	    !page_counter_try_charge(&memcg->swap, nr_pages, &counter)) {
+		mem_cgroup_event(memcg, MEMCG_SWAP_MAX);
+		mem_cgroup_event(memcg, MEMCG_SWAP_FAIL);
 		mem_cgroup_id_put(memcg);
 		return -ENOMEM;
 	}
@@ -6131,6 +6135,18 @@ static ssize_t swap_max_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
+static int swap_events_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+
+	memcg_stat_flush(memcg);
+
+	seq_printf(m, "max %llu\n", memcg->events[MEMCG_SWAP_MAX]);
+	seq_printf(m, "fail %llu\n", memcg->events[MEMCG_SWAP_FAIL]);
+
+	return 0;
+}
+
 static struct cftype swap_files[] = {
 	{
 		.name = "swap.current",
@@ -6143,6 +6159,12 @@ static struct cftype swap_files[] = {
 		.seq_show = swap_max_show,
 		.write = swap_max_write,
 	},
+	{
+		.name = "swap.events",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.file_offset = offsetof(struct mem_cgroup, swap_events_file),
+		.seq_show = swap_events_show,
+	},
 	{ }	/* terminate */
 };
 
-- 
2.9.5
