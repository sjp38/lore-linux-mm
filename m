Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 798116B0038
	for <linux-mm@kvack.org>; Sun, 28 Dec 2014 13:48:00 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so22156394wib.1
        for <linux-mm@kvack.org>; Sun, 28 Dec 2014 10:48:00 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ha3si53952085wib.103.2014.12.28.10.47.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Dec 2014 10:47:59 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: switch soft limit default back to infinity
Date: Sun, 28 Dec 2014 13:47:48 -0500
Message-Id: <1419792468-9278-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

3e32cb2e0a12 ("mm: memcontrol: lockless page counters") accidentally
switched the soft limit default from infinity to zero, which turns all
memcgs with even a single page into soft limit excessors and engages
soft limit reclaim on all of them during global memory pressure.  This
makes global reclaim generally more aggressive, but also inverts the
meaning of existing soft limit configurations where unset soft limits
are usually more generous than set ones.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ef91e856c7e4..b7104a55ae64 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4679,6 +4679,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
 		page_counter_init(&memcg->memory, NULL);
+		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
 	}
@@ -4724,6 +4725,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 
 	if (parent->use_hierarchy) {
 		page_counter_init(&memcg->memory, &parent->memory);
+		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, &parent->memsw);
 		page_counter_init(&memcg->kmem, &parent->kmem);
 
@@ -4733,6 +4735,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		 */
 	} else {
 		page_counter_init(&memcg->memory, NULL);
+		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
 		/*
@@ -4807,7 +4810,7 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 	mem_cgroup_resize_limit(memcg, PAGE_COUNTER_MAX);
 	mem_cgroup_resize_memsw_limit(memcg, PAGE_COUNTER_MAX);
 	memcg_update_kmem_limit(memcg, PAGE_COUNTER_MAX);
-	memcg->soft_limit = 0;
+	memcg->soft_limit = PAGE_COUNTER_MAX;
 }
 
 #ifdef CONFIG_MMU
-- 
2.2.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
