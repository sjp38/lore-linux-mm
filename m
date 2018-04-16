Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1D96B0009
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:11:55 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id e6-v6so11114351ybk.0
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:11:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c3sor2918659ywf.573.2018.04.16.16.11.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 16:11:54 -0700 (PDT)
Date: Mon, 16 Apr 2018 16:11:51 -0700
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/2] mm, memcontrol: Implement memory.swap.events
Message-ID: <20180416231151.GI1911913@devbig577.frc2.facebook.com>
References: <20180416230901.GG1911913@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180416230901.GG1911913@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

Add swap max and fail events so that userland can monitor and respond
to running out of swap.

v2: Rebased on top of e27be240df53 ("mm: memcg: make sure
    memory.events is uptodate when waking pollers")

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-api@vger.kernel.org
---
Hello,

I'm not too sure about the fail event.  Right now, it's a bit
confusing which stats / events are recursive and which aren't and also
which ones reflect events which originate from a given cgroup and
which targets the cgroup.  No idea what the right long term solution
is and it could just be that growing them organically is actually the
only right thing to do.

Thanks.

 Documentation/cgroup-v2.txt |   16 ++++++++++++++++
 include/linux/memcontrol.h  |    5 +++++
 mm/memcontrol.c             |   24 +++++++++++++++++++++++-
 3 files changed, 44 insertions(+), 1 deletion(-)

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
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -53,6 +53,8 @@ enum memcg_memory_event {
 	MEMCG_HIGH,
 	MEMCG_MAX,
 	MEMCG_OOM,
+	MEMCG_SWAP_MAX,
+	MEMCG_SWAP_FAIL,
 	MEMCG_NR_MEMORY_EVENTS,
 };
 
@@ -208,6 +210,9 @@ struct mem_cgroup {
 	atomic_long_t memory_events[MEMCG_NR_MEMORY_EVENTS];
 	struct cgroup_file events_file;
 
+	/* handle for "memory.swap.events" */
+	struct cgroup_file swap_events_file;
+
 	/* protect arrays of thresholds */
 	struct mutex thresholds_lock;
 
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6012,13 +6012,17 @@ int mem_cgroup_try_charge_swap(struct pa
 	if (!memcg)
 		return 0;
 
-	if (!entry.val)
+	if (!entry.val) {
+		memcg_memory_event(memcg, MEMCG_SWAP_FAIL);
 		return 0;
+	}
 
 	memcg = mem_cgroup_id_get_online(memcg);
 
 	if (!mem_cgroup_is_root(memcg) &&
 	    !page_counter_try_charge(&memcg->swap, nr_pages, &counter)) {
+		memcg_memory_event(memcg, MEMCG_SWAP_MAX);
+		memcg_memory_event(memcg, MEMCG_SWAP_FAIL);
 		mem_cgroup_id_put(memcg);
 		return -ENOMEM;
 	}
@@ -6156,6 +6160,18 @@ static ssize_t swap_max_write(struct ker
 	return nbytes;
 }
 
+static int swap_events_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+
+	seq_printf(m, "max %lu\n",
+		   atomic_long_read(&memcg->memory_events[MEMCG_SWAP_MAX]));
+	seq_printf(m, "fail %lu\n",
+		   atomic_long_read(&memcg->memory_events[MEMCG_SWAP_FAIL]));
+
+	return 0;
+}
+
 static struct cftype swap_files[] = {
 	{
 		.name = "swap.current",
@@ -6168,6 +6184,12 @@ static struct cftype swap_files[] = {
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
 
