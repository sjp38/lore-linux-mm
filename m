Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v3 PATCH 2/5] mm: memcontrol: add may_swap parameter to mem_cgroup_force_empty()
Date: Thu, 10 Jan 2019 03:14:42 +0800
Message-Id: <1547061285-100329-3-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: linux-kernel-owner@vger.kernel.org
To: mhocko@suse.com, hannes@cmpxchg.org, shakeelb@google.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

mem_cgroup_force_empty() will be reused by the following patch which
does memory reclaim when offlining.  It is unnecessary to do swap in that
path, but force_empty still needs keep intact since it is also used by
other usecases per Shakeel.

So, introduce may_swap parameter to mem_cgroup_force_empty().  This is
the preparation for the following patch.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/memcontrol.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af7f18b..eaa3970 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2878,7 +2878,7 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
  *
  * Caller is responsible for holding css reference for memcg.
  */
-static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
+static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool may_swap)
 {
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 
@@ -2895,7 +2895,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 			return -EINTR;
 
 		progress = try_to_free_mem_cgroup_pages(memcg, 1,
-							GFP_KERNEL, true);
+							GFP_KERNEL, may_swap);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -2915,7 +2915,7 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
 
 	if (mem_cgroup_is_root(memcg))
 		return -EINVAL;
-	return mem_cgroup_force_empty(memcg) ?: nbytes;
+	return mem_cgroup_force_empty(memcg, true) ?: nbytes;
 }
 
 static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
-- 
1.8.3.1
