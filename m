Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 153156B0033
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 12:12:48 -0400 (EDT)
From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] memcg: don't initialize kmem-cache destroying work for root caches
Date: Mon,  5 Aug 2013 20:09:40 +0400
Message-Id: <1375718980-22154-1-git-send-email-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrey Vagin <avagin@openvz.org>, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, stable@vger.kernel.org

struct memcg_cache_params has a union. Different parts of this union
are used for root and non-root caches. A part with destroying work is
used only for non-root caches.

I fixed the same problem in another place v3.9-rc1-16204-gf101a94, but
didn't notice this one.

Cc: Glauber Costa <glommer@openvz.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: <stable@vger.kernel.org>    [3.9.x]
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 mm/memcontrol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c290a1c..c5792a5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3195,11 +3195,11 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
 	if (!s->memcg_params)
 		return -ENOMEM;
 
-	INIT_WORK(&s->memcg_params->destroy,
-			kmem_cache_destroy_work_func);
 	if (memcg) {
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
+		INIT_WORK(&s->memcg_params->destroy,
+				kmem_cache_destroy_work_func);
 	} else
 		s->memcg_params->is_root_cache = true;
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
