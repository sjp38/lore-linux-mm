Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB096B0255
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 06:13:27 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj10so41425167pad.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 03:13:27 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rf10si4693337pab.213.2016.03.01.03.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 03:13:26 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 1/2] mm: memcontrol: cleanup css_reset callback
Date: Tue, 1 Mar 2016 14:13:12 +0300
Message-ID: <69629961aefc48c021b895bb0c8297b56c11a577.1456830735.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

 - Do not take memcg_limit_mutex for resetting limits - the cgroup
   cannot be altered from userspace anymore, so no need to protect them.

 - Use plain page_counter_limit() for resetting ->memory and ->memsw
   limits instead of mem_cgrouop_resize_* helpers - we enlarge the
   limits, so no need in special handling.

 - Reset ->swap and ->tcpmem limits as well.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae8b81c55685..8615b066b642 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4257,9 +4257,11 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
-	mem_cgroup_resize_limit(memcg, PAGE_COUNTER_MAX);
-	mem_cgroup_resize_memsw_limit(memcg, PAGE_COUNTER_MAX);
-	memcg_update_kmem_limit(memcg, PAGE_COUNTER_MAX);
+	page_counter_limit(&memcg->memory, PAGE_COUNTER_MAX);
+	page_counter_limit(&memcg->swap, PAGE_COUNTER_MAX);
+	page_counter_limit(&memcg->memsw, PAGE_COUNTER_MAX);
+	page_counter_limit(&memcg->kmem, PAGE_COUNTER_MAX);
+	page_counter_limit(&memcg->tcpmem, PAGE_COUNTER_MAX);
 	memcg->low = 0;
 	memcg->high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
