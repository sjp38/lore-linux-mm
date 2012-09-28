Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 23DA26B0070
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 11:08:06 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 3/3] sl[au]b: process slabinfo_show in common code
Date: Fri, 28 Sep 2012 19:03:28 +0400
Message-Id: <1348844608-12568-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1348844608-12568-1-git-send-email-glommer@parallels.com>
References: <1348844608-12568-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>

With all the infrastructure in place, we can now have slabinfo_show
done from slab_common.c. A cache-specific function is called to grab
information about the cache itself, since that is still heavily
dependent on the implementation. But with the values produced by it, all
the printing and handling is done from common code.

[ v2: moved objects_per_slab and cache_order to slabinfo ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
---
 mm/slab.c        | 26 +++++++++++++++-----------
 mm/slab.h        | 16 +++++++++++++++-
 mm/slab_common.c | 18 +++++++++++++++++-
 mm/slub.c        | 24 ++++++++++--------------
 4 files changed, 57 insertions(+), 27 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a3de3e5..3402b86 100644
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
@@ -4340,13 +4339,20 @@ int slabinfo_show(struct seq_file *m, void *p)
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
+	sinfo->objects_per_slab = cachep->num;
+	sinfo->cache_order = cachep->gfporder;
+}
+
+void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *cachep)
+{
 #if STATS
 	{			/* list3 stats */
 		unsigned long high = cachep->high_mark;
@@ -4376,8 +4382,6 @@ int slabinfo_show(struct seq_file *m, void *p)
 			   allochit, allocmiss, freehit, freemiss);
 	}
 #endif
-	seq_putc(m, '\n');
-	return 0;
 }
 
 #define MAX_SLABINFO_WRITE 128
diff --git a/mm/slab.h b/mm/slab.h
index 3442eb8..5a43c2f 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -49,8 +49,22 @@ int __kmem_cache_shutdown(struct kmem_cache *);
 
 struct seq_file;
 struct file;
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
+	unsigned int objects_per_slab;
+	unsigned int cache_order;
+};
+
+void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo);
+void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *s);
 ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 		       size_t count, loff_t *ppos);
 #endif
diff --git a/mm/slab_common.c b/mm/slab_common.c
index fc12d7d..651b179 100644
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
+		   sinfo.objects_per_slab, (1 << sinfo.cache_order));
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
index 4c2c092..e9b7159 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5392,18 +5392,14 @@ __initcall(slab_sysfs_init);
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
 
@@ -5416,16 +5412,16 @@ int slabinfo_show(struct seq_file *m, void *p)
 		nr_free += count_partial(n, count_free);
 	}
 
-	nr_inuse = nr_objs - nr_free;
+	sinfo->active_objs = nr_objs - nr_free;
+	sinfo->num_objs = nr_objs;
+	sinfo->active_slabs = nr_slabs;
+	sinfo->num_slabs = nr_slabs;
+	sinfo->objects_per_slab = oo_objects(s->oo);
+	sinfo->cache_order = oo_order(s->oo);
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
