Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 139AE6B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 04:23:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so7829645wmz.2
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 01:23:12 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id wg3si7346613wjb.188.2016.08.24.01.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 01:23:11 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: memcontrol: avoid unused function warning
Date: Wed, 24 Aug 2016 10:22:43 +0200
Message-Id: <20160824082301.632345-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A bugfix in v4.8-rc2 introduced a harmless warning when CONFIG_MEMCG_SWAP
is disabled but CONFIG_MEMCG is enabled:

mm/memcontrol.c:4085:27: error: 'mem_cgroup_id_get_online' defined but not used [-Werror=unused-function]
 static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)

This adds an extra #ifdef that matches the one around the caller to
avoid the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 1f47b61fb407 ("mm: memcontrol: fix swap counter leak on swapout from offline cgroup")
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2ff0289ad061..e8d787163b65 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4082,6 +4082,7 @@ static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
 	atomic_add(n, &memcg->id.ref);
 }
 
+#ifdef CONFIG_MEMCG_SWAP
 static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
 {
 	while (!atomic_inc_not_zero(&memcg->id.ref)) {
@@ -4099,6 +4100,7 @@ static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
 	}
 	return memcg;
 }
+#endif
 
 static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
 {
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
