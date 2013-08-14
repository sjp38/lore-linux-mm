Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 688396B008A
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 06:34:50 -0400 (EDT)
From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] kmemcg: don't allocate extra memory for root memcg_cache_params
Date: Wed, 14 Aug 2013 14:31:21 +0400
Message-Id: <1376476281-26559-1-git-send-email-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrey Vagin <avagin@openvz.org>, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

The memcg_cache_params structure contains the common part and the union,
which represents two different types of data: one for root cashes and
another for child caches.

The size of child data is fixed. The size of the memcg_caches array is
calculated in runtime.

Currently the size of memcg_cache_params for root caches is calculated
incorrectly, because it includes the size of parameters for child caches.

ssize_t size = memcg_caches_array_size(num_groups);
size *= sizeof(void *);

size += sizeof(struct memcg_cache_params);

Cc: Glauber Costa <glommer@openvz.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 mm/memcontrol.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c5792a5..d69a10b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3140,7 +3140,7 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 		ssize_t size = memcg_caches_array_size(num_groups);
 
 		size *= sizeof(void *);
-		size += sizeof(struct memcg_cache_params);
+		size += sizeof(offsetof(struct memcg_cache_params, memcg_caches));
 
 		s->memcg_params = kzalloc(size, GFP_KERNEL);
 		if (!s->memcg_params) {
@@ -3183,13 +3183,16 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
 			 struct kmem_cache *root_cache)
 {
-	size_t size = sizeof(struct memcg_cache_params);
+	size_t size;
 
 	if (!memcg_kmem_enabled())
 		return 0;
 
-	if (!memcg)
+	if (!memcg) {
+		size = offsetof(struct memcg_cache_params, memcg_caches);
 		size += memcg_limited_groups_array_size * sizeof(void *);
+	} else
+		size = sizeof(struct memcg_cache_params);
 
 	s->memcg_params = kzalloc(size, GFP_KERNEL);
 	if (!s->memcg_params)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
