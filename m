Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9D26B00DD
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 07:32:44 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so834223pab.20
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 04:32:44 -0700 (PDT)
Received: from psmtp.com ([74.125.245.164])
        by mx.google.com with SMTP id w1si15153859pan.286.2013.10.23.04.32.42
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 04:32:43 -0700 (PDT)
From: Qiang Huang <h.huangqiang@huawei.com>
Subject: [PATCH 3/3] memcg, kmem: use cache_from_memcg_idx instead of hard code
Date: Wed, 23 Oct 2013 19:31:15 +0800
Message-ID: <1382527875-10112-4-git-send-email-h.huangqiang@huawei.com>
In-Reply-To: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com>
References: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org, penberg@kernel.org, glommer@parallels.com, rientjes@google.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
---
 mm/memcontrol.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 15ad0e3..5479b37 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2882,7 +2882,7 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 
 	VM_BUG_ON(p->is_root_cache);
 	cachep = p->root_cache;
-	return cachep->memcg_params->memcg_caches[memcg_cache_id(p->memcg)];
+	return cache_from_memcg_idx(cachep, memcg_cache_id(p->memcg));
 }
 
 #ifdef CONFIG_SLABINFO
@@ -3323,7 +3323,7 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	idx = memcg_cache_id(memcg);
 
 	mutex_lock(&memcg_cache_mutex);
-	new_cachep = cachep->memcg_params->memcg_caches[idx];
+	new_cachep = cache_from_memcg_idx(cachep, idx);
 	if (new_cachep) {
 		css_put(&memcg->css);
 		goto out;
@@ -3369,8 +3369,8 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	 * we'll take the set_limit_mutex to protect ourselves against this.
 	 */
 	mutex_lock(&set_limit_mutex);
-	for (i = 0; i < memcg_limited_groups_array_size; i++) {
-		c = s->memcg_params->memcg_caches[i];
+	for_each_memcg_cache_index(i) {
+		c = cache_from_memcg_idx(s, i);
 		if (!c)
 			continue;
 
@@ -3503,8 +3503,8 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	 * code updating memcg_caches will issue a write barrier to match this.
 	 */
 	read_barrier_depends();
-	if (likely(cachep->memcg_params->memcg_caches[idx])) {
-		cachep = cachep->memcg_params->memcg_caches[idx];
+	if (likely(cache_from_memcg_idx(cachep, idx))) {
+		cachep = cache_from_memcg_idx(cachep, idx);
 		goto out;
 	}
 
-- 
1.8.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
