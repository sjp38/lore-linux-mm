Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 32B606B028F
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 07:18:07 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id w123so43790476pfb.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 04:18:07 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id z87si16467086pfa.67.2016.02.04.04.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 04:18:06 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: memcontrol: do not bypass slab charge if memcg is offline
Date: Thu, 4 Feb 2016 15:17:55 +0300
Message-ID: <1454588275-7615-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Slab pages are charged in two steps. First, an appropriate per memcg
cache is selected (see memcg_kmem_get_cache) basing on the current
context, then the new slab page is charged to the memory cgroup which
the selected cache was created for (see memcg_charge_slab ->
__memcg_kmem_charge_memcg). It is OK to bypass kmemcg charge at step 1,
but if step 1 succeeded and we successfully allocated a new slab page,
step 2 must be performed, otherwise we would get a per memcg kmem cache
which contains a slab that does not hold a reference to the memory
cgroup owning the cache. Since per memcg kmem caches are destroyed on
memcg css free, this could result in freeing a cache while there are
still active objects in it.

However, currently we will bypass slab page charge if the memory cgroup
owning the cache is offline (see __memcg_kmem_charge_memcg). This is
very unlikely to occur in practice, because for this to happen a process
must be migrated to a different cgroup and the old cgroup must be
removed while the process is in kmalloc somewhere between steps 1 and 2
(e.g.  trying to allocate a new page). Nevertheless, it's still better
to eliminate such a possibility.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3e4199830456..f36b20f5b3ed 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2325,9 +2325,6 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 	struct page_counter *counter;
 	int ret;
 
-	if (!memcg_kmem_online(memcg))
-		return 0;
-
 	ret = try_charge(memcg, gfp, nr_pages);
 	if (ret)
 		return ret;
@@ -2346,10 +2343,11 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 {
 	struct mem_cgroup *memcg;
-	int ret;
+	int ret = 0;
 
 	memcg = get_mem_cgroup_from_mm(current->mm);
-	ret = __memcg_kmem_charge_memcg(page, gfp, order, memcg);
+	if (memcg_kmem_online(memcg))
+		ret = __memcg_kmem_charge_memcg(page, gfp, order, memcg);
 	css_put(&memcg->css);
 	return ret;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
