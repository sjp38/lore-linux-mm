Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 030696B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 08:25:53 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id q8so1801725pfh.12
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 05:25:52 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr60103.outbound.protection.outlook.com. [40.107.6.103])
        by mx.google.com with ESMTPS id s12si8251577pgc.746.2018.01.19.05.25.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 05:25:51 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v5 1/2] mm/memcontrol.c: try harder to decrease [memory,memsw].limit_in_bytes
Date: Fri, 19 Jan 2018 16:25:43 +0300
Message-Id: <20180119132544.19569-1-aryabinin@virtuozzo.com>
In-Reply-To: <20171220102429.31601-1-aryabinin@virtuozzo.com>
References: <20171220102429.31601-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

mem_cgroup_resize_[memsw]_limit() tries to free only 32 (SWAP_CLUSTER_MAX)
pages on each iteration.  This makes it practically impossible to decrease
limit of memory cgroup.  Tasks could easily allocate back 32 pages, so we
can't reduce memory usage, and once retry_count reaches zero we return
-EBUSY.

Easy to reproduce the problem by running the following commands:

  mkdir /sys/fs/cgroup/memory/test
  echo $$ >> /sys/fs/cgroup/memory/test/tasks
  cat big_file > /dev/null &
  sleep 1 && echo $((100*1024*1024)) > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
  -bash: echo: write error: Device or resource busy

Instead of relying on retry_count, keep retrying the reclaim until the
desired limit is reached or fail if the reclaim doesn't make any progress
or a signal is pending.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
---
 mm/memcontrol.c | 42 ++++++------------------------------------
 1 file changed, 6 insertions(+), 36 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 13aeccf32c2e..9d987f3e79dc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1176,20 +1176,6 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 }
 
 /*
- * This function returns the number of memcg under hierarchy tree. Returns
- * 1(self count) if no children.
- */
-static int mem_cgroup_count_children(struct mem_cgroup *memcg)
-{
-	int num = 0;
-	struct mem_cgroup *iter;
-
-	for_each_mem_cgroup_tree(iter, memcg)
-		num++;
-	return num;
-}
-
-/*
  * Return the memory (and swap, if configured) limit for a memcg.
  */
 unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
@@ -2462,24 +2448,11 @@ static DEFINE_MUTEX(memcg_limit_mutex);
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 				   unsigned long limit, bool memsw)
 {
-	unsigned long curusage;
-	unsigned long oldusage;
 	bool enlarge = false;
-	int retry_count;
 	int ret;
 	bool limits_invariant;
 	struct page_counter *counter = memsw ? &memcg->memsw : &memcg->memory;
 
-	/*
-	 * For keeping hierarchical_reclaim simple, how long we should retry
-	 * is depends on callers. We set our retry-count to be function
-	 * of # of children which we should visit in this loop.
-	 */
-	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
-		      mem_cgroup_count_children(memcg);
-
-	oldusage = page_counter_read(counter);
-
 	do {
 		if (signal_pending(current)) {
 			ret = -EINTR;
@@ -2506,15 +2479,12 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, !memsw);
-
-		curusage = page_counter_read(counter);
-		/* Usage is reduced ? */
-		if (curusage >= oldusage)
-			retry_count--;
-		else
-			oldusage = curusage;
-	} while (retry_count);
+		if (!try_to_free_mem_cgroup_pages(memcg, 1,
+					GFP_KERNEL, !memsw)) {
+			ret = -EBUSY;
+			break;
+		}
+	} while (true);
 
 	if (!ret && enlarge)
 		memcg_oom_recover(memcg);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
