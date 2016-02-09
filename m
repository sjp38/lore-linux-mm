Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id BC5196B0009
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 08:56:09 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id d63so17816254ioj.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 05:56:09 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id s95si22581760ioe.115.2016.02.09.05.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 05:56:08 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 1/6] mm: memcontrol: enable kmem accounting for all cgroups in the legacy hierarchy
Date: Tue, 9 Feb 2016 16:55:49 +0300
Message-ID: <24b6725d7aaf30306f3b9231e077d2831cdf1f6b.1455025246.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1455025246.git.vdavydov@virtuozzo.com>
References: <cover.1455025246.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, in the legacy hierarchy kmem accounting is off for all
cgroups by default and must be enabled explicitly by writing something
to memory.kmem.limit_in_bytes. Since we don't support reclaim on hitting
kmem limit, nor do we have any plans to implement it, this is likely to
be -1, just to enable kmem accounting and limit kernel memory
consumption by the memory.limit_in_bytes along with user memory.

This user API was introduced when the implementation of kmem accounting
lacked slab shrinker support and hence was useless in practice. Things
have changed since then - slab shrinkers were made memcg aware, the
accounting overhead seems to be negligible, and a failure to charge a
kmem allocation should not have critical consequences, because we only
account those kernel objects that should be safe to fail. That's why
kmem accounting is enabled by default for all cgroups in the default
hierarchy, which will eventually replace the legacy one.

The ability to enable kmem accounting for some cgroups while keeping it
disabled for others is getting difficult to maintain. E.g. to make
shadow node shrinker memcg aware (see mm/workingset.c), we need to know
the relationship between the number of shadow nodes allocated for a
cgroup and the size of its lru list. If kmem accounting is enabled for
all cgroups there is no problem, but what should we do if kmem
accounting is enabled only for half of cgroups? We've no other choice
but use global lru stats while scanning root cgroup's shadow nodes, but
that would be wrong if kmem accounting was enabled for all cgroups
(which is the case if the unified hierarchy is used), in which case we
should use lru stats of the root cgroup's lruvec.

That being said, let's enable kmem accounting for all memory cgroups by
default. If one finds it unstable or too costly, it can always be
disabled system-wide by passing cgroup.memory=nokmem to the kernel at
boot time.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 41 +++++------------------------------------
 1 file changed, 5 insertions(+), 36 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4b7dda7c2e74..28d1b1e9d4fb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2824,6 +2824,9 @@ static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
 	int memcg_id;
 
+	if (cgroup_memory_nokmem)
+		return 0;
+
 	BUG_ON(memcg->kmemcg_id >= 0);
 	BUG_ON(memcg->kmem_state);
 
@@ -2844,24 +2847,6 @@ static int memcg_online_kmem(struct mem_cgroup *memcg)
 	return 0;
 }
 
-static int memcg_propagate_kmem(struct mem_cgroup *parent,
-				struct mem_cgroup *memcg)
-{
-	int ret = 0;
-
-	mutex_lock(&memcg_limit_mutex);
-	/*
-	 * If the parent cgroup is not kmem-online now, it cannot be
-	 * onlined after this point, because it has at least one child
-	 * already.
-	 */
-	if (memcg_kmem_online(parent) ||
-	    (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nokmem))
-		ret = memcg_online_kmem(memcg);
-	mutex_unlock(&memcg_limit_mutex);
-	return ret;
-}
-
 static void memcg_offline_kmem(struct mem_cgroup *memcg)
 {
 	struct cgroup_subsys_state *css;
@@ -2920,10 +2905,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	}
 }
 #else
-static int memcg_propagate_kmem(struct mem_cgroup *parent, struct mem_cgroup *memcg)
-{
-	return 0;
-}
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
 	return 0;
@@ -2939,22 +2920,10 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 				   unsigned long limit)
 {
-	int ret = 0;
+	int ret;
 
 	mutex_lock(&memcg_limit_mutex);
-	/* Top-level cgroup doesn't propagate from root */
-	if (!memcg_kmem_online(memcg)) {
-		if (cgroup_is_populated(memcg->css.cgroup) ||
-		    (memcg->use_hierarchy && memcg_has_children(memcg)))
-			ret = -EBUSY;
-		if (ret)
-			goto out;
-		ret = memcg_online_kmem(memcg);
-		if (ret)
-			goto out;
-	}
 	ret = page_counter_limit(&memcg->kmem, limit);
-out:
 	mutex_unlock(&memcg_limit_mutex);
 	return ret;
 }
@@ -4205,7 +4174,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 		return &memcg->css;
 	}
 
-	error = memcg_propagate_kmem(parent, memcg);
+	error = memcg_online_kmem(memcg);
 	if (error)
 		goto fail;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
