Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB5F6B007D
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 08:44:58 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so789446pde.4
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 05:44:57 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yp10si3147199pab.51.2014.11.05.05.44.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Nov 2014 05:44:55 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 1/3] memcg: do not abuse memcg_kmem_skip_account
Date: Wed, 5 Nov 2014 16:44:42 +0300
Message-ID: <9ac4c9e767d437f744bb61feb7e042c93c67f727.1415194280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

task_struct->memcg_kmem_skip_account was initially introduced to avoid
recursion during kmem cache creation: memcg_kmem_get_cache, which is
called by kmem_cache_alloc to determine the per-memcg cache to account
allocation to, may issue lazy cache creation if the needed cache doesn't
exist, which means issuing yet another kmem_cache_alloc. We can't just
pass a flag to the nested kmem_cache_alloc disabling kmem accounting,
because there are hidden allocations, e.g. in INIT_WORK. So we
introduced a flag on the task_struct, memcg_kmem_skip_account, making
memcg_kmem_get_cache return immediately.

By its nature, the flag may also be used to disable accounting for
allocations shared among different cgroups, and currently it is used
this way in memcg_activate_kmem. Using it like this looks like abusing
it to me. If we want to disable accounting for some allocatrons (which
we will definitely want one day), we should either add GFP_NO_MEMCG or
GFP_MEMCG flag in order to blacklist/whitelist some allocations.

For now, let's simply remove memcg_stop/resume_kmem_account from
memcg_activate_kmem.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f61ecbc97d30..b3fe830fdb29 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3428,12 +3428,6 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 		return 0;
 
 	/*
-	 * We are going to allocate memory for data shared by all memory
-	 * cgroups so let's stop accounting here.
-	 */
-	memcg_stop_kmem_account();
-
-	/*
 	 * For simplicity, we won't allow this to be disabled.  It also can't
 	 * be changed if the cgroup has children already, or if tasks had
 	 * already joined.
@@ -3475,7 +3469,6 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 	 */
 	memcg->kmemcg_id = memcg_id;
 out:
-	memcg_resume_kmem_account();
 	return err;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
