Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5E206B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 07:37:42 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k135so9569349lfb.2
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 04:37:42 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.135])
        by mx.google.com with ESMTPS id i130si8515642wme.120.2016.08.24.04.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 04:37:41 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2] mm: memcontrol: avoid unused function warning
Date: Wed, 24 Aug 2016 12:23:00 +0200
Message-Id: <20160824113733.2776701-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A bugfix in v4.8-rc2 introduced a harmless warning when CONFIG_MEMCG_SWAP
is disabled but CONFIG_MEMCG is enabled:

mm/memcontrol.c:4085:27: error: 'mem_cgroup_id_get_online' defined but not used [-Werror=unused-function]
 static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)

This moves the function inside of the #ifdef block that hides the
calling function, to avoid the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 1f47b61fb407 ("mm: memcontrol: fix swap counter leak on swapout from offline cgroup")
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

This is the alternative to the original patch, as suggested by Michal Hocko.
Andrew, please pick whichever version you like better.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2ff0289ad061..9a6a51a7c416 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4082,24 +4082,6 @@ static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
 	atomic_add(n, &memcg->id.ref);
 }
 
-static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
-{
-	while (!atomic_inc_not_zero(&memcg->id.ref)) {
-		/*
-		 * The root cgroup cannot be destroyed, so it's refcount must
-		 * always be >= 1.
-		 */
-		if (WARN_ON_ONCE(memcg == root_mem_cgroup)) {
-			VM_BUG_ON(1);
-			break;
-		}
-		memcg = parent_mem_cgroup(memcg);
-		if (!memcg)
-			memcg = root_mem_cgroup;
-	}
-	return memcg;
-}
-
 static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
 {
 	if (atomic_sub_and_test(n, &memcg->id.ref)) {
@@ -5821,6 +5803,24 @@ static int __init mem_cgroup_init(void)
 subsys_initcall(mem_cgroup_init);
 
 #ifdef CONFIG_MEMCG_SWAP
+static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
+{
+	while (!atomic_inc_not_zero(&memcg->id.ref)) {
+		/*
+		 * The root cgroup cannot be destroyed, so it's refcount must
+		 * always be >= 1.
+		 */
+		if (WARN_ON_ONCE(memcg == root_mem_cgroup)) {
+			VM_BUG_ON(1);
+			break;
+		}
+		memcg = parent_mem_cgroup(memcg);
+		if (!memcg)
+			memcg = root_mem_cgroup;
+	}
+	return memcg;
+}
+
 /**
  * mem_cgroup_swapout - transfer a memsw charge to swap
  * @page: page whose memsw charge to transfer
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
