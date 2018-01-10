Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 898DB6B0268
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 07:43:26 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x24so6914245pge.13
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 04:43:26 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50111.outbound.protection.outlook.com. [40.107.5.111])
        by mx.google.com with ESMTPS id a23si11703389pfa.111.2018.01.10.04.43.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 10 Jan 2018 04:43:24 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v4] mm/memcg: try harder to decrease [memory,memsw].limit_in_bytes
Date: Wed, 10 Jan 2018 15:43:17 +0300
Message-Id: <20180110124317.28887-1-aryabinin@virtuozzo.com>
In-Reply-To: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
References: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

mem_cgroup_resize_[memsw]_limit() tries to free only 32 (SWAP_CLUSTER_MAX)
pages on each iteration. This makes practically impossible to decrease
limit of memory cgroup. Tasks could easily allocate back 32 pages,
so we can't reduce memory usage, and once retry_count reaches zero we return
-EBUSY.

Easy to reproduce the problem by running the following commands:

  mkdir /sys/fs/cgroup/memory/test
  echo $$ >> /sys/fs/cgroup/memory/test/tasks
  cat big_file > /dev/null &
  sleep 1 && echo $((100*1024*1024)) > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
  -bash: echo: write error: Device or resource busy

Instead of relying on retry_count, keep retrying the reclaim until
the desired limit is reached or fail if the reclaim doesn't make
any progress or a signal is pending.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
---

Changes since v3:
 - Rebase

Changes since v2:
 - Changelog wording per mhocko@


 mm/memcontrol.c | 44 ++++++++------------------------------------
 1 file changed, 8 insertions(+), 36 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 13aeccf32c2e..c3d1eaef752d 100644
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
@@ -2462,24 +2448,12 @@ static DEFINE_MUTEX(memcg_limit_mutex);
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 				   unsigned long limit, bool memsw)
 {
-	unsigned long curusage;
-	unsigned long oldusage;
+	unsigned long usage;
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
@@ -2506,15 +2480,13 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
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
+		usage = page_counter_read(counter);
+		if (!try_to_free_mem_cgroup_pages(memcg, usage - limit,
+						GFP_KERNEL, !memsw)) {
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
