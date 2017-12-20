Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 865036B025E
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 05:21:15 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w5so14172084pgt.4
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 02:21:15 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50110.outbound.protection.outlook.com. [40.107.5.110])
        by mx.google.com with ESMTPS id p1si11677858pgf.275.2017.12.20.02.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 02:21:14 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 2/2] mm/memcg: Consolidate mem_cgroup_resize_[memsw]_limit() functions.
Date: Wed, 20 Dec 2017 13:24:29 +0300
Message-Id: <20171220102429.31601-2-aryabinin@virtuozzo.com>
In-Reply-To: <20171220102429.31601-1-aryabinin@virtuozzo.com>
References: <20171220102429.31601-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

mem_cgroup_resize_limit() and mem_cgroup_resize_memsw_limit() are almost
identical functions. Instead of having two of them, we could pass an
additional argument to mem_cgroup_resize_limit() and by using it,
consolidate all the code in a single function.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/memcontrol.c | 77 +++++++++++++--------------------------------------------
 1 file changed, 17 insertions(+), 60 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 09ee052cf684..b263500626fe 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2459,9 +2459,17 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 
 static DEFINE_MUTEX(memcg_limit_mutex);
 
-static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
+static bool invalid_mem_limit(struct mem_cgroup *memcg, bool memsw,
+			      unsigned long limit)
+{
+	return (!memsw && limit > memcg->memsw.limit) ||
+		(memsw && limit < memcg->memory.limit);
+}
+
+static int mem_cgroup_resize_limit(struct mem_cgroup *memcg, bool memsw,
 				   unsigned long limit)
 {
+	struct page_counter *counter = memsw ? &memcg->memsw : &memcg->memory;
 	unsigned long curusage;
 	unsigned long oldusage;
 	bool enlarge = false;
@@ -2476,7 +2484,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
 		      mem_cgroup_count_children(memcg);
 
-	curusage = oldusage = page_counter_read(&memcg->memory);
+	curusage = oldusage = page_counter_read(counter);
 
 	do {
 		if (signal_pending(current)) {
@@ -2485,75 +2493,24 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		}
 
 		mutex_lock(&memcg_limit_mutex);
-		if (limit > memcg->memsw.limit) {
+		if (invalid_mem_limit(memcg, memsw, limit)) {
 			mutex_unlock(&memcg_limit_mutex);
 			ret = -EINVAL;
 			break;
 		}
-		if (limit > memcg->memory.limit)
-			enlarge = true;
-		ret = page_counter_limit(&memcg->memory, limit);
-		mutex_unlock(&memcg_limit_mutex);
-
-		if (!ret)
-			break;
-
-		try_to_free_mem_cgroup_pages(memcg, curusage - limit,
-					GFP_KERNEL, true);
-
-		curusage = page_counter_read(&memcg->memory);
-		/* Usage is reduced ? */
-		if (curusage >= oldusage)
-			retry_count--;
-		else
-			oldusage = curusage;
-	} while (retry_count);
-
-	if (!ret && enlarge)
-		memcg_oom_recover(memcg);
-
-	return ret;
-}
 
-static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
-					 unsigned long limit)
-{
-	unsigned long curusage;
-	unsigned long oldusage;
-	bool enlarge = false;
-	int retry_count;
-	int ret;
-
-	/* see mem_cgroup_resize_res_limit */
-	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
-		      mem_cgroup_count_children(memcg);
-
-	curusage = oldusage = page_counter_read(&memcg->memsw);
-
-	do {
-		if (signal_pending(current)) {
-			ret = -EINTR;
-			break;
-		}
-
-		mutex_lock(&memcg_limit_mutex);
-		if (limit < memcg->memory.limit) {
-			mutex_unlock(&memcg_limit_mutex);
-			ret = -EINVAL;
-			break;
-		}
-		if (limit > memcg->memsw.limit)
+		if (limit > counter->limit)
 			enlarge = true;
-		ret = page_counter_limit(&memcg->memsw, limit);
+		ret = page_counter_limit(counter, limit);
 		mutex_unlock(&memcg_limit_mutex);
 
 		if (!ret)
 			break;
 
 		try_to_free_mem_cgroup_pages(memcg, curusage - limit,
-					GFP_KERNEL, false);
+					GFP_KERNEL, !memsw);
 
-		curusage = page_counter_read(&memcg->memsw);
+		curusage = page_counter_read(counter);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
 			retry_count--;
@@ -3233,10 +3190,10 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
 		}
 		switch (MEMFILE_TYPE(of_cft(of)->private)) {
 		case _MEM:
-			ret = mem_cgroup_resize_limit(memcg, nr_pages);
+			ret = mem_cgroup_resize_limit(memcg, false, nr_pages);
 			break;
 		case _MEMSWAP:
-			ret = mem_cgroup_resize_memsw_limit(memcg, nr_pages);
+			ret = mem_cgroup_resize_limit(memcg, true, nr_pages);
 			break;
 		case _KMEM:
 			ret = memcg_update_kmem_limit(memcg, nr_pages);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
