Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 136066B00DF
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 07:32:48 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so490125pad.23
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 04:32:47 -0700 (PDT)
Received: from psmtp.com ([74.125.245.115])
        by mx.google.com with SMTP id gn4si1756341pbc.231.2013.10.23.04.32.46
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 04:32:47 -0700 (PDT)
From: Qiang Huang <h.huangqiang@huawei.com>
Subject: [PATCH 2/3] memcg, kmem: rename cache_from_memcg to cache_from_memcg_idx
Date: Wed, 23 Oct 2013 19:31:14 +0800
Message-ID: <1382527875-10112-3-git-send-email-h.huangqiang@huawei.com>
In-Reply-To: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com>
References: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org, penberg@kernel.org, glommer@parallels.com, rientjes@google.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

We can't see the relationship with memcg from the parameters,
so the name with memcg_idx would be more reasonable.

Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
---
 mm/slab.c        | 2 +-
 mm/slab.h        | 6 ++++--
 mm/slab_common.c | 2 +-
 mm/slub.c        | 2 +-
 4 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 8ccd296..3a90fbc 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3977,7 +3977,7 @@ static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 
 	VM_BUG_ON(!mutex_is_locked(&slab_mutex));
 	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg(cachep, i);
+		c = cache_from_memcg_idx(cachep, i);
 		if (c)
 			/* return value determined by the parent cache only */
 			__do_tune_cpucache(c, limit, batchcount, shared, gfp);
diff --git a/mm/slab.h b/mm/slab.h
index f96b49e..a6d5bee 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -160,7 +160,8 @@ static inline const char *cache_name(struct kmem_cache *s)
 	return s->name;
 }
 
-static inline struct kmem_cache *cache_from_memcg(struct kmem_cache *s, int idx)
+static inline struct kmem_cache *
+cache_from_memcg_idx(struct kmem_cache *s, int idx)
 {
 	return s->memcg_params->memcg_caches[idx];
 }
@@ -202,7 +203,8 @@ static inline const char *cache_name(struct kmem_cache *s)
 	return s->name;
 }
 
-static inline struct kmem_cache *cache_from_memcg(struct kmem_cache *s, int idx)
+static inline struct kmem_cache *
+cache_from_memcg_idx(struct kmem_cache *s, int idx)
 {
 	return NULL;
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2d41450..34d1551 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -552,7 +552,7 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
 		return;
 
 	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg(s, i);
+		c = cache_from_memcg_idx(s, i);
 		if (!c)
 			continue;
 
diff --git a/mm/slub.c b/mm/slub.c
index 0f3b6c1..0fa9930 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4999,7 +4999,7 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 		 * through the descendants with best-effort propagation.
 		 */
 		for_each_memcg_cache_index(i) {
-			struct kmem_cache *c = cache_from_memcg(s, i);
+			struct kmem_cache *c = cache_from_memcg_idx(s, i);
 			if (c)
 				attribute->store(c, buf, len);
 		}
-- 
1.8.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
