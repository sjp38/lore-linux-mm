Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id E38606B0254
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:51:37 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l68so3575482wml.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 12:51:37 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p77si406333wmg.32.2016.03.10.12.51.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 12:51:36 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: memcontrol: reclaim and OOM kill when shrinking memory.max below usage
Date: Thu, 10 Mar 2016 15:50:14 -0500
Message-Id: <1457643015-8828-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Setting the original memory.limit_in_bytes hardlimit is subject to a
race condition when the desired value is below the current usage. The
code tries a few times to first reclaim and then see if the usage has
dropped to where we would like it to be, but there is no locking, and
the workload is free to continue making new charges up to the old
limit. Thus, attempting to shrink a workload relies on pure luck and
hope that the workload happens to cooperate.

To fix this in the cgroup2 memory.max knob, do it the other way round:
set the limit first, then try enforcement. And if reclaim is not able
to succeed, trigger OOM kills in the group. Keep going until the new
limit is met, we run out of OOM victims and there's only unreclaimable
memory left, or the task writing to memory.max is killed. This allows
users to shrink groups reliably, and the behavior is consistent with
what happens when new charges are attempted in excess of memory.max.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroup-v2.txt |  6 ++++++
 mm/memcontrol.c             | 38 ++++++++++++++++++++++++++++++++++----
 2 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index c709d7ebc092..2fd4cdb78445 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1540,6 +1540,12 @@ system than killing the group.  Otherwise, memory.max is there to
 limit this type of spillover and ultimately contain buggy or even
 malicious applications.
 
+Setting the original memory.limit_in_bytes below the current usage was
+subject to a race condition, where concurrent charges could cause the
+limit setting to fail. memory.max on the other hand will first set the
+limit to prevent new charges, and then reclaim and OOM kill until the
+new limit is met - or the task writing to memory.max is killed.
+
 The combined memory+swap accounting and limiting is replaced by real
 control over swap space.
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f7c9b4cbdf01..8614e0d750e5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1236,7 +1236,7 @@ static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 	return limit;
 }
 
-static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
+static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				     int order)
 {
 	struct oom_control oc = {
@@ -1314,6 +1314,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	}
 unlock:
 	mutex_unlock(&oom_lock);
+	return chosen;
 }
 
 #if MAX_NUMNODES > 1
@@ -5029,6 +5030,8 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	unsigned int nr_reclaims = MEM_CGROUP_RECLAIM_RETRIES;
+	bool drained = false;
 	unsigned long max;
 	int err;
 
@@ -5037,9 +5040,36 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	if (err)
 		return err;
 
-	err = mem_cgroup_resize_limit(memcg, max);
-	if (err)
-		return err;
+	xchg(&memcg->memory.limit, max);
+
+	for (;;) {
+		unsigned long nr_pages = page_counter_read(&memcg->memory);
+
+		if (nr_pages <= max)
+			break;
+
+		if (signal_pending(current)) {
+			err = -EINTR;
+			break;
+		}
+
+		if (!drained) {
+			drain_all_stock(memcg);
+			drained = true;
+			continue;
+		}
+
+		if (nr_reclaims) {
+			if (!try_to_free_mem_cgroup_pages(memcg, nr_pages - max,
+							  GFP_KERNEL, true))
+				nr_reclaims--;
+			continue;
+		}
+
+		mem_cgroup_events(memcg, MEMCG_OOM, 1);
+		if (!mem_cgroup_out_of_memory(memcg, GFP_KERNEL, 0))
+			break;
+	}
 
 	memcg_wb_domain_size_changed(memcg);
 	return nbytes;
-- 
2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
