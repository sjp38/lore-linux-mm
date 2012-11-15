Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 8AF4E6B009C
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:55:01 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 6/7] memcg: add comments clarifying aspects of cache attribute propagation
Date: Thu, 15 Nov 2012 06:54:52 +0400
Message-Id: <1352948093-2315-7-git-send-email-glommer@parallels.com>
In-Reply-To: <1352948093-2315-1-git-send-email-glommer@parallels.com>
References: <1352948093-2315-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

This patch clarifies two aspects of cache attribute propagation.

First, the expected context for the for_each_memcg_cache macro in
memcontrol.h. The usages already in the codebase are safe. In mm/slub.c,
it is trivially safe because the lock is acquired right before the loop.
In mm/slab.c, it is less so: the lock is acquired by an outer function a
few steps back in the stack, so a VM_BUG_ON() is added to make sure it
is indeed safe.

A comment is also added to detail why we are returning the value of the
parent cache and ignoring the children's when we propagate the
attributes.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memcontrol.h |  6 ++++++
 mm/slab.c                  |  1 +
 mm/slub.c                  | 21 +++++++++++++++++----
 3 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 17d0d41..48eddec 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -415,6 +415,12 @@ static inline void sock_release_memcg(struct sock *sk)
 extern struct static_key memcg_kmem_enabled_key;
 
 extern int memcg_limited_groups_array_size;
+
+/*
+ * Helper macro to loop through all memcg-specific caches. Callers must still
+ * check if the cache is valid (it is either valid or NULL).
+ * the slab_mutex must be held when looping through those caches
+ */
 #define for_each_memcg_cache_index(_idx)	\
 	for ((_idx) = 0; i < memcg_limited_groups_array_size; (_idx)++)
 
diff --git a/mm/slab.c b/mm/slab.c
index 699d1d42..d408bf731 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4165,6 +4165,7 @@ static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 	if ((ret < 0) || !is_root_cache(cachep))
 		return ret;
 
+	VM_BUG_ON(!mutex_is_locked(&slab_mutex));
 	for_each_memcg_cache_index(i) {
 		c = cache_from_memcg(cachep, i);
 		if (c)
diff --git a/mm/slub.c b/mm/slub.c
index 56a8db2..fead2cd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5199,12 +5199,25 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 		if (s->max_attr_size < len)
 			s->max_attr_size = len;
 
+		/*
+		 * This is a best effort propagation, so this function's return
+		 * value will be determined by the parent cache only. This is
+		 * basically because not all attributes will have a well
+		 * defined semantics for rollbacks - most of the actions will
+		 * have permanent effects.
+		 *
+		 * Returning the error value of any of the children that fail
+		 * is not 100 % defined, in the sense that users seeing the
+		 * error code won't be able to know anything about the state of
+		 * the cache.
+		 *
+		 * Only returning the error code for the parent cache at least
+		 * has well defined semantics. The cache being written to
+		 * directly either failed or succeeded, in which case we loop
+		 * through the descendants with best-effort propagation.
+		 */
 		for_each_memcg_cache_index(i) {
 			struct kmem_cache *c = cache_from_memcg(s, i);
-			/*
-			 * This function's return value is determined by the
-			 * parent cache only
-			 */
 			if (c)
 				attribute->store(c, buf, len);
 		}
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
