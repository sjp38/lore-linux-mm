Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9B29C6B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 05:21:14 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w5so14172069pgt.4
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 02:21:14 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50110.outbound.protection.outlook.com. [40.107.5.110])
        by mx.google.com with ESMTPS id p1si11677858pgf.275.2017.12.20.02.21.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 02:21:13 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 1/2] mm/memcg: try harder to decrease [memory,memsw].limit_in_bytes
Date: Wed, 20 Dec 2017 13:24:28 +0300
Message-Id: <20171220102429.31601-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

mem_cgroup_resize_[memsw]_limit() tries to free only 32 (SWAP_CLUSTER_MAX)
pages on each iteration. This makes practically impossible to decrease
limit of memory cgroup. Tasks could easily allocate back 32 pages,
so we can't reduce memory usage, and once retry_count reaches zero we return
-EBUSY.

It's easy to reproduce the problem by running the following commands:

  mkdir /sys/fs/cgroup/memory/test
  echo $$ >> /sys/fs/cgroup/memory/test/tasks
  cat big_file > /dev/null &
  sleep 1 && echo $((100*1024*1024)) > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
  -bash: echo: write error: Device or resource busy

Instead of trying to free small amount of pages, it's much more
reasonable to free 'usage - limit' pages.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/memcontrol.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f40b5ad3f959..09ee052cf684 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2476,7 +2476,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
 		      mem_cgroup_count_children(memcg);
 
-	oldusage = page_counter_read(&memcg->memory);
+	curusage = oldusage = page_counter_read(&memcg->memory);
 
 	do {
 		if (signal_pending(current)) {
@@ -2498,7 +2498,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, true);
+		try_to_free_mem_cgroup_pages(memcg, curusage - limit,
+					GFP_KERNEL, true);
 
 		curusage = page_counter_read(&memcg->memory);
 		/* Usage is reduced ? */
@@ -2527,7 +2528,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
 		      mem_cgroup_count_children(memcg);
 
-	oldusage = page_counter_read(&memcg->memsw);
+	curusage = oldusage = page_counter_read(&memcg->memsw);
 
 	do {
 		if (signal_pending(current)) {
@@ -2549,7 +2550,8 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, false);
+		try_to_free_mem_cgroup_pages(memcg, curusage - limit,
+					GFP_KERNEL, false);
 
 		curusage = page_counter_read(&memcg->memsw);
 		/* Usage is reduced ? */
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
