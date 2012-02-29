Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 1042A6B007E
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 22:30:29 -0500 (EST)
Date: Wed, 29 Feb 2012 00:27:36 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH] mm: SLAB Out-of-memory diagnostics
Message-ID: <20120229032715.GA23758@t510.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, David Rientjes <rientjes@google.com>

Following the example at mm/slub.c, add out-of-memory diagnostics to the SLAB
allocator to help on debugging OOM conditions. This patch also adds a new
sysctl, 'oom_dump_slabs_forced', that overrides the effect of __GFP_NOWARN page
allocation flag and forces the kernel to report every slab allocation failure.

An example print out looks like this:

  <snip page allocator out-of-memory message>
  SLAB: Unable to allocate memory on node 0 (gfp=0x11200)
     cache: bio-0, object size: 192, order: 0
     node0: slabs: 3/3, objs: 60/60, free: 0

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 Documentation/sysctl/vm.txt |   23 ++++++++++++++++++
 include/linux/slab.h        |    2 +
 kernel/sysctl.c             |    9 +++++++
 mm/slab.c                   |   55 ++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 88 insertions(+), 1 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 96f0ee8..75bdf91 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -498,6 +498,29 @@ this is causing problems for your system/application.
 
 ==============================================================
 
+oom_dump_slabs_forced
+
+Overrides the effects of __GFP_NOWARN page allocation flag, thus forcing
+the system to print warnings about every allocation failure for the
+slab allocator, and helping on debugging certain OOM conditions.
+The print out is pretty similar, and complements data that is reported by
+the page allocator out-of-memory warning:
+
+<snip page allocator out-of-memory message>
+  SLAB: Unable to allocate memory on node 0 (gfp=0x11200)
+     cache: bio-0, object size: 192, order: 0
+     node0: slabs: 3/3, objs: 60/60, free: 0
+
+If this is set to zero, the default behavior is observed and warnings will only
+be printed out for allocation requests that didn't set the __GFP_NOWARN flag.
+
+When set to non-zero, this information is shown whenever the allocator finds
+itself failing to grant a request, regardless the __GFP_NOWARN flag status.
+
+The default value is 0 (disabled).
+
+==============================================================
+
 oom_dump_tasks
 
 Enables a system-wide task dump (excluding kernel threads) to be
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 573c809..ca57021 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -353,4 +353,6 @@ static inline void *kzalloc_node(size_t size, gfp_t flags, int node)
 
 void __init kmem_cache_init_late(void);
 
+/* sysctl */
+extern int sysctl_oom_dump_slabs;
 #endif	/* _LINUX_SLAB_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index f487f25..71fe8ec 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1040,6 +1040,15 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+#if defined(CONFIG_SLAB)
+       {
+               .procname       = "oom_dump_slabs_forced",
+               .data           = &sysctl_oom_dump_slabs,
+               .maxlen         = sizeof(sysctl_oom_dump_slabs),
+               .mode           = 0644,
+               .proc_handler   = proc_dointvec,
+       },
+#endif
 	{
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
diff --git a/mm/slab.c b/mm/slab.c
index f0bd785..993ca4c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -168,6 +168,9 @@
 			 SLAB_DEBUG_OBJECTS | SLAB_NOLEAKTRACE | SLAB_NOTRACK)
 #endif
 
+/* sysctl */
+int sysctl_oom_dump_slabs = 0;
+
 /*
  * kmem_bufctl_t:
  *
@@ -1731,6 +1734,52 @@ static int __init cpucache_init(void)
 }
 __initcall(cpucache_init);
 
+static noinline void
+slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
+{
+	struct kmem_list3 *l3;
+	struct slab *slabp;
+	unsigned long flags;
+	int node;
+
+	printk(KERN_WARNING
+		"SLAB: Unable to allocate memory on node %d (gfp=0x%x)\n",
+		nodeid, gfpflags);
+	printk(KERN_WARNING "   cache: %s, object size: %d, order: %d\n",
+		cachep->name, cachep->buffer_size, cachep->gfporder);
+
+	for_each_online_node(node) {
+		unsigned long active_objs = 0, num_objs = 0, free_objects = 0;
+		unsigned long active_slabs = 0, num_slabs = 0;
+
+		l3 = cachep->nodelists[node];
+		if (!l3)
+			continue;
+
+		spin_lock_irqsave(&l3->list_lock, flags);
+		list_for_each_entry(slabp, &l3->slabs_full, list) {
+			active_objs += cachep->num;
+			active_slabs++;
+		}
+		list_for_each_entry(slabp, &l3->slabs_partial, list) {
+			active_objs += slabp->inuse;
+			active_slabs++;
+		}
+		list_for_each_entry(slabp, &l3->slabs_free, list)
+			num_slabs++;
+
+		free_objects += l3->free_objects;
+		spin_unlock_irqrestore(&l3->list_lock, flags);
+
+		num_slabs += active_slabs;
+		num_objs = num_slabs * cachep->num;
+		printk(KERN_WARNING
+			"   node%d: slabs: %ld/%ld, objs: %ld/%ld, free: %ld\n",
+			node, active_slabs, num_slabs, active_objs, num_objs,
+			free_objects);
+	}
+}
+
 /*
  * Interface to system's page allocator. No need to hold the cache-lock.
  *
@@ -1757,8 +1806,12 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 		flags |= __GFP_RECLAIMABLE;
 
 	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
-	if (!page)
+	if (!page) {
+		if ((sysctl_oom_dump_slabs || !(flags & __GFP_NOWARN)) &&
+		    printk_ratelimit())
+			slab_out_of_memory(cachep, flags, nodeid);
 		return NULL;
+	}
 
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
