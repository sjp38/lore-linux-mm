Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 809298D0017
	for <linux-mm@kvack.org>; Fri, 11 May 2012 13:50:05 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 17/29] slab: create duplicate cache
Date: Fri, 11 May 2012 14:44:19 -0300
Message-Id: <1336758272-24284-18-git-send-email-glommer@parallels.com>
In-Reply-To: <1336758272-24284-1-git-send-email-glommer@parallels.com>
References: <1336758272-24284-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

This patch provides kmem_cache_dup(), that duplicates
a cache for a memcg, preserving its creation properties.
Object size, alignment and flags are all respected.
An exception is the SLAB_PANIC flag, since cache creation
inside a memcg should not be fatal.

This code is mostly written by Suleiman Souhlal,
with some adaptations and simplifications by me.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
---
 mm/slab.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d05a326..985714a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -301,6 +301,8 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int len,
 			int node);
 static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp);
 static void cache_reap(struct work_struct *unused);
+static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
+			    int batchcount, int shared, gfp_t gfp);
 
 /*
  * This function must be completely optimized away if a constant is passed to
@@ -2598,6 +2600,36 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 EXPORT_SYMBOL(kmem_cache_create);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
+				  struct kmem_cache *cachep)
+{
+	struct kmem_cache *new;
+	unsigned long flags;
+	char *name;
+
+	name = mem_cgroup_cache_name(memcg, cachep);
+	if (!name)
+		return NULL;
+
+	flags = cachep->flags & ~(SLAB_PANIC|CFLGS_OFF_SLAB);
+	mutex_lock(&cache_chain_mutex);
+	new = __kmem_cache_create(memcg, name, obj_size(cachep),
+	    cachep->memcg_params.orig_align, flags, cachep->ctor);
+
+	if (new == NULL)
+		goto out;
+
+	if ((cachep->limit != new->limit) ||
+	    (cachep->batchcount != new->batchcount) ||
+	    (cachep->shared != new->shared))
+		do_tune_cpucache(new, cachep->limit, cachep->batchcount,
+		    cachep->shared, GFP_KERNEL);
+out:
+	mutex_unlock(&cache_chain_mutex);
+	kfree(name);
+	return new;
+}
+
 static int __init memcg_slab_register_all(void)
 {
 	struct kmem_cache *cachep;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
