Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 5EFF96B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 06:55:03 -0500 (EST)
Date: Wed, 22 Feb 2012 09:53:26 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH] oom: add sysctl to enable slab memory dump
Message-ID: <20120222115320.GA3107@x61.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

Adds a new sysctl, 'oom_dump_slabs', that enables the kernel to produce a
dump of all eligible system slab caches when performing an OOM-killing.
Information includes per cache active objects, total objects, object size,
cache name and cache size.

The eligibility for being reported is given by an auxiliary sysctl,
'oom_dump_slabs_ratio', which express (in percentage) the memory committed
ratio between a particular cache size and the total slab size.

This, alongside with all other data dumped in OOM events, is very helpful
information in diagnosing why there was an OOM condition specially when
kernel code is under investigation.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 Documentation/sysctl/vm.txt |   30 ++++++++++++++++++
 include/linux/oom.h         |    2 +
 kernel/sysctl.c             |   16 +++++++++
 mm/oom_kill.c               |   13 ++++++++
 mm/slab.c                   |   72 +++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c                   |   52 +++++++++++++++++++++++++++++++
 6 files changed, 185 insertions(+), 0 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 96f0ee8..a0da8b3 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -498,6 +498,36 @@ this is causing problems for your system/application.
 
 ==============================================================
 
+oom_dump_slabs
+
+Enables a system-wide slab cache dump to be produced when the kernel
+performs an OOM-killing and includes, per slab cache, such information as
+active objects, total objects, object size, cache name, and cache size.
+This is helpful to determine the top slab cache memory users, as well as
+to identify what was their part on this OOM-killer occurrence.
+
+If this is set to zero, this information is suppressed.
+
+If this is set to non-zero, this information is shown whenever the
+OOM killer actually kills a memory-hogging task.
+
+The default value is 1 (enabled).
+
+==============================================================
+
+oom_dump_slabs_ratio
+
+Adjust, as a percentage of total system memory dedicated to the slab cache,
+a per cache size cutting point for oom_dump_slabs reports. If this is set to
+a non-zero 'N', only caches bigger than N% of total memory committed to slab
+will be dumped out when OOM-killer is invoked.
+
+When set to 0, all slab caches will be listed at dump report.
+
+The default value is 10.
+
+==============================================================
+
 oom_dump_tasks
 
 Enables a system-wide task dump (excluding kernel threads) to be
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 552fba9..8af3863 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -69,6 +69,8 @@ extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
+extern int sysctl_oom_dump_slabs;
+extern int sysctl_oom_dump_slabs_ratio;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
 #endif /* __KERNEL__*/
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index f487f25..a9da3d8 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1040,6 +1040,22 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
+	{
+		.procname	= "oom_dump_slabs",
+		.data		= &sysctl_oom_dump_slabs,
+		.maxlen		= sizeof(sysctl_oom_dump_slabs),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "oom_dump_slabs_ratio",
+		.data		= &sysctl_oom_dump_slabs_ratio,
+		.maxlen		= sizeof(sysctl_oom_dump_slabs_ratio),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 	{
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2958fd8..4de948d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -38,9 +38,20 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
 
+#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
+extern void oom_dump_slabs(int ratio);
+#else
+static void oom_dump_slabs(int ratio)
+{
+}
+#endif
+
+
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
+int sysctl_oom_dump_slabs = 1;
+int sysctl_oom_dump_slabs_ratio = 10;
 static DEFINE_SPINLOCK(zone_scan_lock);
 
 /*
@@ -429,6 +440,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 	dump_stack();
 	mem_cgroup_print_oom_info(memcg, p);
 	show_mem(SHOW_MEM_FILTER_NODES);
+	if (sysctl_oom_dump_slabs)
+		oom_dump_slabs(sysctl_oom_dump_slabs_ratio);
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(memcg, nodemask);
 }
diff --git a/mm/slab.c b/mm/slab.c
index f0bd785..c2b5d14 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4629,3 +4629,75 @@ size_t ksize(const void *objp)
 	return obj_size(virt_to_cache(objp));
 }
 EXPORT_SYMBOL(ksize);
+
+/**
+ * oom_dump_slabs - dump top slab cache users
+ * @ratio: memory committed ratio between a cache size and the total slab size
+ *
+ * Dumps the current memory state of all eligible slab caches.
+ * State information includes cache's active objects, total objects,
+ * object size, cache name, and cache size.
+ */
+void oom_dump_slabs(int ratio)
+{
+	struct kmem_cache *cachep;
+	struct kmem_list3 *l3;
+	struct slab *slabp;
+	unsigned long active_objs, num_objs, free_objects, cache_size;
+	unsigned long active_slabs, num_slabs, slab_total_mem;
+	int node;
+
+	slab_total_mem = (global_page_state(NR_SLAB_RECLAIMABLE) +
+		        global_page_state(NR_SLAB_UNRECLAIMABLE)) << PAGE_SHIFT;
+
+	if (ratio < 0)
+		ratio = 0;
+
+	if (ratio > 100)
+		ratio = 100;
+
+	pr_info("--- oom_dump_slabs:\n");
+	pr_info("<active_objs>    <num_objs>     <objsize>  <cache_name>\n");
+	mutex_lock(&cache_chain_mutex);
+	list_for_each_entry(cachep, &cache_chain, next) {
+		num_objs = 0;
+		num_slabs = 0;
+		active_objs = 0;
+		free_objects = 0;
+		active_slabs = 0;
+
+		for_each_online_node(node) {
+			l3 = cachep->nodelists[node];
+			if (!l3)
+				continue;
+
+			check_irq_on();
+			spin_lock_irq(&l3->list_lock);
+
+			list_for_each_entry(slabp, &l3->slabs_full, list) {
+				active_objs += cachep->num;
+				active_slabs++;
+			}
+			list_for_each_entry(slabp, &l3->slabs_partial, list) {
+				active_objs += slabp->inuse;
+				active_slabs++;
+			}
+			list_for_each_entry(slabp, &l3->slabs_free, list)
+				num_slabs++;
+
+			free_objects += l3->free_objects;
+			spin_unlock_irq(&l3->list_lock);
+		}
+		num_slabs += active_slabs;
+		num_objs = num_slabs * cachep->num;
+		cache_size = (cachep->buffer_size * num_objs);
+
+		if (cache_size >= (slab_total_mem * ratio / 100))
+			pr_info("%12lu  %12lu  %12u    %-20s : %9lu kB\n",
+				active_objs, num_objs, cachep->buffer_size,
+				cachep->name, cache_size >> 10);
+	}
+	mutex_unlock(&cache_chain_mutex);
+	pr_info("---\n");
+}
+EXPORT_SYMBOL(oom_dump_slabs);
diff --git a/mm/slub.c b/mm/slub.c
index 4907563..7719f92 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5480,3 +5480,55 @@ static int __init slab_proc_init(void)
 }
 module_init(slab_proc_init);
 #endif /* CONFIG_SLABINFO */
+
+/**
+ * oom_dump_slabs - dump top slab cache users
+ * @ratio: memory committed ratio between a cache size and the total slab size
+ *
+ * Dumps the current memory state of all eligible slab caches.
+ * State information includes cache's active objects, total objects,
+ * object size, cache name, and cache size.
+ */
+void oom_dump_slabs(int ratio)
+{
+	unsigned long cache_size, slab_total_mem;
+	unsigned long nr_objs, nr_free, nr_inuse;
+	struct kmem_cache *cachep;
+	int node;
+
+	slab_total_mem = (global_page_state(NR_SLAB_RECLAIMABLE) +
+		        global_page_state(NR_SLAB_UNRECLAIMABLE)) << PAGE_SHIFT;
+
+	if (ratio < 0)
+		ratio = 0;
+
+	if (ratio > 100)
+		ratio = 100;
+
+	pr_info("--- oom_dump_slabs:\n");
+	pr_info("<active_objs>    <num_objs>     <objsize>  <cache_name>\n");
+	down_read(&slub_lock);
+	list_for_each_entry(cachep, &slab_caches, list) {
+		nr_objs = 0;
+		nr_free = 0;
+
+		for_each_online_node(node) {
+			struct kmem_cache_node *n = get_node(cachep, node);
+			if (!n)
+				continue;
+
+			nr_objs += atomic_long_read(&n->total_objects);
+			nr_free += count_partial(n, count_free);
+		}
+		nr_inuse = nr_objs - nr_free;
+		cache_size = (cachep->size * nr_objs);
+
+		if (cache_size >= (slab_total_mem * ratio / 100))
+			pr_info("%12lu  %12lu  %12u    %-20s : %9lu kB\n",
+				nr_inuse, nr_objs, cachep->size,
+				cachep->name, cache_size >> 10);
+	}
+	up_read(&slub_lock);
+	pr_info("---\n");
+}
+EXPORT_SYMBOL(oom_dump_slabs);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
