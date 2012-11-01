Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 291096B0078
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:09:10 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 21/29] sl[au]b: always get the cache from its page in kmem_cache_free
Date: Thu,  1 Nov 2012 16:07:37 +0400
Message-Id: <1351771665-11076-22-git-send-email-glommer@parallels.com>
In-Reply-To: <1351771665-11076-1-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

struct page already have this information. If we start chaining caches,
this information will always be more trustworthy than whatever is passed
into the function

[ v3: added parent testing with VM_BUG_ON ]
[ v4: make it faster when kmemcg not in use ]
[ v6: move it to slab.h ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
CC: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h |  5 +++++
 mm/slab.c                  |  6 +++++-
 mm/slab.h                  | 39 +++++++++++++++++++++++++++++++++++++++
 mm/slob.c                  |  2 +-
 mm/slub.c                  | 15 +++------------
 5 files changed, 53 insertions(+), 14 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 16bff74..d77d88d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -547,6 +547,11 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 	return __memcg_kmem_get_cache(cachep, gfp);
 }
 #else
+static inline bool memcg_kmem_enabled(void)
+{
+	return false;
+}
+
 static inline bool
 memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
 {
diff --git a/mm/slab.c b/mm/slab.c
index dcc05f5..de9cc0d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -87,7 +87,6 @@
  */
 
 #include	<linux/slab.h>
-#include	"slab.h"
 #include	<linux/mm.h>
 #include	<linux/poison.h>
 #include	<linux/swap.h>
@@ -128,6 +127,8 @@
 
 #include	"internal.h"
 
+#include	"slab.h"
+
 /*
  * DEBUG	- 1 for kmem_cache_create() to honour; SLAB_RED_ZONE & SLAB_POISON.
  *		  0 for faster, smaller code (especially in the critical paths).
@@ -3946,6 +3947,9 @@ EXPORT_SYMBOL(__kmalloc);
 void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 {
 	unsigned long flags;
+	cachep = cache_from_obj(cachep, objp);
+	if (!cachep)
+		return;
 
 	local_irq_save(flags);
 	debug_check_no_locks_freed(objp, cachep->object_size);
diff --git a/mm/slab.h b/mm/slab.h
index 22eb5aa2..fb1c4c4 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -108,6 +108,13 @@ static inline bool cache_match_memcg(struct kmem_cache *cachep,
 	return (is_root_cache(cachep) && !memcg) ||
 				(cachep->memcg_params->memcg == memcg);
 }
+
+static inline bool slab_equal_or_root(struct kmem_cache *s,
+					struct kmem_cache *p)
+{
+	return (p == s) ||
+		(s->memcg_params && (p == s->memcg_params->root_cache));
+}
 #else
 static inline bool is_root_cache(struct kmem_cache *s)
 {
@@ -119,5 +126,37 @@ static inline bool cache_match_memcg(struct kmem_cache *cachep,
 {
 	return true;
 }
+
+static inline bool slab_equal_or_root(struct kmem_cache *s,
+				      struct kmem_cache *p)
+{
+	return true;
+}
 #endif
+
+static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
+{
+	struct kmem_cache *cachep;
+	struct page *page;
+
+	/*
+	 * When kmemcg is not being used, both assignments should return the
+	 * same value. but we don't want to pay the assignment price in that
+	 * case. If it is not compiled in, the compiler should be smart enough
+	 * to not do even the assignment. In that case, slab_equal_or_root
+	 * will also be a constant.
+	 */
+	if (!memcg_kmem_enabled() && !unlikely(s->flags & SLAB_DEBUG_FREE))
+		return s;
+
+	page = virt_to_head_page(x);
+	cachep = page->slab_cache;
+	if (slab_equal_or_root(cachep, s))
+		return cachep;
+
+	pr_err("%s: Wrong slab cache. %s but object is from %s\n",
+		__FUNCTION__, cachep->name, s->name);
+	WARN_ON_ONCE(1);
+	return s;
+}
 #endif
diff --git a/mm/slob.c b/mm/slob.c
index 3edfeaa..c86ee32 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -59,7 +59,6 @@
 
 #include <linux/kernel.h>
 #include <linux/slab.h>
-#include "slab.h"
 
 #include <linux/mm.h>
 #include <linux/swap.h> /* struct reclaim_state */
@@ -74,6 +73,7 @@
 
 #include <linux/atomic.h>
 
+#include "slab.h"
 /*
  * slob_block has a field 'units', which indicates size of block if +ve,
  * or offset of next block if -ve (in SLOB_UNITs).
diff --git a/mm/slub.c b/mm/slub.c
index a105bdc..6ff2bdb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2609,19 +2609,10 @@ redo:
 
 void kmem_cache_free(struct kmem_cache *s, void *x)
 {
-	struct page *page;
-
-	page = virt_to_head_page(x);
-
-	if (kmem_cache_debug(s) && page->slab_cache != s) {
-		pr_err("kmem_cache_free: Wrong slab cache. %s but object"
-			" is from  %s\n", page->slab_cache->name, s->name);
-		WARN_ON_ONCE(1);
+	s = cache_from_obj(s, x);
+	if (!s)
 		return;
-	}
-
-	slab_free(s, page, x, _RET_IP_);
-
+	slab_free(s, virt_to_head_page(x), x, _RET_IP_);
 	trace_kmem_cache_free(_RET_IP_, x);
 }
 EXPORT_SYMBOL(kmem_cache_free);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
