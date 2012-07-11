Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 4EC276B0069
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 09:25:10 -0400 (EDT)
Received: by yenr5 with SMTP id r5so1405269yen.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 06:25:09 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH RFC] mm/memcg: calculate max hierarchy limit number instead of min
Date: Wed, 11 Jul 2012 21:24:41 +0800
Message-Id: <1342013081-4096-1-git-send-email-liwp.linux@gmail.com>
In-Reply-To: <a>
References: <a>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Since hierachical_memory_limit shows "of bytes of memory limit with
regard to hierarchy under which the memory cgroup is", the count should
calculate max hierarchy limit when use_hierarchy in order to show hierarchy
subtree limit. hierachical_memsw_limit is the same case.

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/memcontrol.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 69a7d45..6392c0a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3929,10 +3929,10 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
 		unsigned long long *mem_limit, unsigned long long *memsw_limit)
 {
 	struct cgroup *cgroup;
-	unsigned long long min_limit, min_memsw_limit, tmp;
+	unsigned long long max_limit, max_memsw_limit, tmp;
 
-	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
-	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
+	max_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
+	max_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
 	cgroup = memcg->css.cgroup;
 	if (!memcg->use_hierarchy)
 		goto out;
@@ -3943,13 +3943,13 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
 		if (!memcg->use_hierarchy)
 			break;
 		tmp = res_counter_read_u64(&memcg->res, RES_LIMIT);
-		min_limit = min(min_limit, tmp);
+		max_limit = max(max_limit, tmp);
 		tmp = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-		min_memsw_limit = min(min_memsw_limit, tmp);
+		max_memsw_limit = max(max_memsw_limit, tmp);
 	}
 out:
-	*mem_limit = min_limit;
-	*memsw_limit = min_memsw_limit;
+	*mem_limit = max_limit;
+	*memsw_limit = max_memsw_limit;
 }
 
 static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
