Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A4F516B0062
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 10:42:12 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 4/4] sl[au]b: process slabinfo_show in common code
Date: Thu, 27 Sep 2012 18:37:40 +0400
Message-Id: <1348756660-16929-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1348756660-16929-1-git-send-email-glommer@parallels.com>
References: <1348756660-16929-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>

With all the infrastructure in place, we can now have slabinfo_show
done from slab_common.c. A cache-specific function is called to grab
information about the cache itself, since that is still heavily
dependent on the implementation. But with the values produced by it, all
the printing and handling is done from common code.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
---
 include/linux/slab_def.h | 10 ++++++++++
 include/linux/slub_def.h | 11 +++++++++++
 mm/slab.c                | 24 +++++++++++++-----------
 mm/slab.h                | 14 +++++++++++++-
 mm/slab_common.c         | 18 +++++++++++++++++-
 mm/slub.c                | 22 ++++++++--------------
 6 files changed, 72 insertions(+), 27 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 36d7031..384cf17 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -97,6 +97,16 @@ struct kmem_cache {
 	 */
 };
 
+static inline int cache_order(struct kmem_cache *s)
+{
+	return s->gfporder;
+}
+
+static inline int objects_per_slab(struct kmem_cache *s)
+{
+	return s->num;
+}
+
 /* Size description struct for general caches. */
 struct cache_sizes {
 	size_t		 	cs_size;
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index f1590c9..668b9f1 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -125,6 +125,17 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
+static inline int cache_order(struct kmem_cache *s)
+{
+	return oo_order(s->oo);
+}
+
+static inline int objects_per_slab(struct kmem_cache *s)
+{
+	return oo_objects(s->oo);
+}
+
+
 /*
  * Kmalloc subsystem.
  */
diff --git a/mm/slab.c b/mm/slab.c
index a3de3e5..1781150 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4283,9 +4283,8 @@ out:
 }
 
 #ifdef CONFIG_SLABINFO
-int slabinfo_show(struct seq_file *m, void *p)
+void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 {
-	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
 	struct slab *slabp;
 	unsigned long active_objs;
 	unsigned long num_objs;
@@ -4340,13 +4339,18 @@ int slabinfo_show(struct seq_file *m, void *p)
 	if (error)
 		printk(KERN_ERR "slab: cache %s error: %s\n", name, error);
 
-	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
-		   name, active_objs, num_objs, cachep->size,
-		   cachep->num, (1 << cachep->gfporder));
-	seq_printf(m, " : tunables %4u %4u %4u",
-		   cachep->limit, cachep->batchcount, cachep->shared);
-	seq_printf(m, " : slabdata %6lu %6lu %6lu",
-		   active_slabs, num_slabs, shared_avail);
+	sinfo->active_objs = active_objs;
+	sinfo->num_objs = num_objs;
+	sinfo->active_slabs = active_slabs;
+	sinfo->num_slabs = num_slabs;
+	sinfo->shared_avail = shared_avail;
+	sinfo->limit = cachep->limit;
+	sinfo->batchcount = cachep->batchcount;
+	sinfo->shared = cachep->shared;
+}
+
+void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *cachep)
+{
 #if STATS
 	{			/* list3 stats */
 		unsigned long high = cachep->high_mark;
@@ -4376,8 +4380,6 @@ int slabinfo_show(struct seq_file *m, void *p)
 			   allochit, allocmiss, freehit, freemiss);
 	}
 #endif
-	seq_putc(m, '\n');
-	return 0;
 }
 
 #define MAX_SLABINFO_WRITE 128
diff --git a/mm/slab.h b/mm/slab.h
index 45b75c8..763f019 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -47,8 +47,20 @@ static inline struct kmem_cache *__kmem_cache_alias(const char *name, size_t siz
 
 int __kmem_cache_shutdown(struct kmem_cache *);
 
-int slabinfo_show(struct seq_file *m, void *p);
+struct slabinfo {
+	unsigned long active_objs;
+	unsigned long num_objs;
+	unsigned long active_slabs;
+	unsigned long num_slabs;
+	unsigned long shared_avail;
+	unsigned int limit;
+	unsigned int batchcount;
+	unsigned int shared;
 
+};
+
+void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo);
+void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *s);
 ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 		       size_t count, loff_t *ppos);
 #endif
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 1bde24a..89db427 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -239,7 +239,23 @@ static void s_stop(struct seq_file *m, void *p)
 
 static int s_show(struct seq_file *m, void *p)
 {
-	return slabinfo_show(m, p);
+	struct kmem_cache *s = list_entry(p, struct kmem_cache, list);
+	struct slabinfo sinfo;
+
+	memset(&sinfo, 0, sizeof(sinfo));
+	get_slabinfo(s, &sinfo);
+
+	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
+		   s->name, sinfo.active_objs, sinfo.num_objs, s->size,
+		   objects_per_slab(s), (1 << cache_order(s)));
+
+	seq_printf(m, " : tunables %4u %4u %4u",
+		   sinfo.limit, sinfo.batchcount, sinfo.shared);
+	seq_printf(m, " : slabdata %6lu %6lu %6lu",
+		   sinfo.active_slabs, sinfo.num_slabs, sinfo.shared_avail);
+	slabinfo_show_stats(m, s);
+	seq_putc(m, '\n');
+	return 0;
 }
 
 /*
diff --git a/mm/slub.c b/mm/slub.c
index 9e72722..d01cb9a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5378,18 +5378,14 @@ __initcall(slab_sysfs_init);
  * The /proc/slabinfo ABI
  */
 #ifdef CONFIG_SLABINFO
-int slabinfo_show(struct seq_file *m, void *p)
+void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
 {
 	unsigned long nr_partials = 0;
 	unsigned long nr_slabs = 0;
-	unsigned long nr_inuse = 0;
 	unsigned long nr_objs = 0;
 	unsigned long nr_free = 0;
-	struct kmem_cache *s;
 	int node;
 
-	s = list_entry(p, struct kmem_cache, list);
-
 	for_each_online_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
@@ -5402,16 +5398,14 @@ int slabinfo_show(struct seq_file *m, void *p)
 		nr_free += count_partial(n, count_free);
 	}
 
-	nr_inuse = nr_objs - nr_free;
+	sinfo->active_objs = nr_objs - nr_free;
+	sinfo->num_objs = nr_objs;
+	sinfo->active_slabs = nr_slabs;
+	sinfo->num_slabs = nr_slabs;
+}
 
-	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d", s->name, nr_inuse,
-		   nr_objs, s->size, oo_objects(s->oo),
-		   (1 << oo_order(s->oo)));
-	seq_printf(m, " : tunables %4u %4u %4u", 0, 0, 0);
-	seq_printf(m, " : slabdata %6lu %6lu %6lu", nr_slabs, nr_slabs,
-		   0UL);
-	seq_putc(m, '\n');
-	return 0;
+void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *s)
+{
 }
 
 ssize_t slabinfo_write(struct file *file, const char __user *buffer,
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
