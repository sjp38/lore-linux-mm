Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A58D46B006E
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 10:23:50 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so269546pad.29
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 07:23:50 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id jd9si8391427pbd.114.2014.10.26.07.23.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Oct 2014 07:23:49 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 2/2] memcg: use generic slab iterators for showing slabinfo
Date: Sun, 26 Oct 2014 17:23:30 +0300
Message-ID: <b76ef4efe6ad0a01c5bc16f6ccea3ba8743cfb86.1414332926.git.vdavydov@parallels.com>
In-Reply-To: <21c195b795ce734d413042d3974e4d26ae2dafdf.1414332926.git.vdavydov@parallels.com>
References: <21c195b795ce734d413042d3974e4d26ae2dafdf.1414332926.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Let's use generic slab_start/next/stop for showing memcg caches info.
In contrast to the current implementation, this will work even if all
memcg caches' info doesn't fit into a seq buffer (a page), plus it
simply looks neater.

Actually, the main reason I do this isn't mere cleanup. I'm going to zap
the memcg_slab_caches list, because I find it useless provided we have
the slab_caches list, and this patch is a step in this direction.

It should be noted that before this patch an attempt to read
memory.kmem.slabinfo of a cgroup that doesn't have kmem limit set
resulted in -EIO, while after this patch it will silently show nothing
except the header, but I don't think it will frustrate anyone.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    4 ----
 mm/memcontrol.c      |   25 ++++---------------------
 mm/slab.h            |    1 +
 mm/slab_common.c     |   25 +++++++++++++++++++------
 4 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index c265bec6a57d..8a2457d42fc8 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -513,10 +513,6 @@ struct memcg_cache_params {
 
 int memcg_update_all_caches(int num_memcgs);
 
-struct seq_file;
-int cache_show(struct kmem_cache *s, struct seq_file *m);
-void print_slabinfo_header(struct seq_file *m);
-
 /**
  * kmalloc_array - allocate memory for an array.
  * @n: number of elements.
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c50176429fa3..54d4305ba1dd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2460,26 +2460,6 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 	return cache_from_memcg_idx(cachep, memcg_cache_id(p->memcg));
 }
 
-#ifdef CONFIG_SLABINFO
-static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	struct memcg_cache_params *params;
-
-	if (!memcg_kmem_is_active(memcg))
-		return -EIO;
-
-	print_slabinfo_header(m);
-
-	mutex_lock(&memcg_slab_mutex);
-	list_for_each_entry(params, &memcg->memcg_slab_caches, list)
-		cache_show(memcg_params_to_cache(params), m);
-	mutex_unlock(&memcg_slab_mutex);
-
-	return 0;
-}
-#endif
-
 static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
 			     unsigned long nr_pages)
 {
@@ -4621,7 +4601,10 @@ static struct cftype mem_cgroup_files[] = {
 #ifdef CONFIG_SLABINFO
 	{
 		.name = "kmem.slabinfo",
-		.seq_show = mem_cgroup_slabinfo_read,
+		.seq_start = slab_start,
+		.seq_next = slab_next,
+		.seq_stop = slab_stop,
+		.seq_show = memcg_slab_show,
 	},
 #endif
 #endif
diff --git a/mm/slab.h b/mm/slab.h
index 53a55c70c409..3347fd77f7be 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -360,5 +360,6 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 void *slab_start(struct seq_file *m, loff_t *pos);
 void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
+int memcg_slab_show(struct seq_file *m, void *p);
 
 #endif /* MM_SLAB_H */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index d8b266750985..d5e9e050a3ec 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -807,7 +807,7 @@ EXPORT_SYMBOL(kmalloc_order_trace);
 #define SLABINFO_RIGHTS S_IRUSR
 #endif
 
-void print_slabinfo_header(struct seq_file *m)
+static void print_slabinfo_header(struct seq_file *m)
 {
 	/*
 	 * Output format version, so at least we can change it
@@ -872,7 +872,7 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
 	}
 }
 
-int cache_show(struct kmem_cache *s, struct seq_file *m)
+static void cache_show(struct kmem_cache *s, struct seq_file *m)
 {
 	struct slabinfo sinfo;
 
@@ -891,7 +891,6 @@ int cache_show(struct kmem_cache *s, struct seq_file *m)
 		   sinfo.active_slabs, sinfo.num_slabs, sinfo.shared_avail);
 	slabinfo_show_stats(m, s);
 	seq_putc(m, '\n');
-	return 0;
 }
 
 static int slab_show(struct seq_file *m, void *p)
@@ -900,10 +899,24 @@ static int slab_show(struct seq_file *m, void *p)
 
 	if (p == slab_caches.next)
 		print_slabinfo_header(m);
-	if (!is_root_cache(s))
-		return 0;
-	return cache_show(s, m);
+	if (is_root_cache(s))
+		cache_show(s, m);
+	return 0;
+}
+
+#ifdef CONFIG_MEMCG_KMEM
+int memcg_slab_show(struct seq_file *m, void *p)
+{
+	struct kmem_cache *s = list_entry(p, struct kmem_cache, list);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+
+	if (p == slab_caches.next)
+		print_slabinfo_header(m);
+	if (!is_root_cache(s) && s->memcg_params->memcg == memcg)
+		cache_show(s, m);
+	return 0;
 }
+#endif
 
 /*
  * slabinfo_op - iterator that generates /proc/slabinfo
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
