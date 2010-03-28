Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 29CE46B01AF
	for <linux-mm@kvack.org>; Sat, 27 Mar 2010 22:41:00 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o2S2esSj024549
	for <linux-mm@kvack.org>; Sun, 28 Mar 2010 04:40:55 +0200
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by kpbe15.cbf.corp.google.com with ESMTP id o2S2eqaI008533
	for <linux-mm@kvack.org>; Sat, 27 Mar 2010 19:40:53 -0700
Received: by pzk1 with SMTP id 1so152569pzk.10
        for <linux-mm@kvack.org>; Sat, 27 Mar 2010 19:40:52 -0700 (PDT)
Date: Sat, 27 Mar 2010 19:40:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] slab: add memory hotplug support
In-Reply-To: <alpine.DEB.2.00.1003271849260.7249@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1003271940190.8399@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box>
 <alpine.DEB.2.00.1002261123520.7719@router.home> <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com> <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com> <20100305062002.GV8653@laptop> <alpine.DEB.2.00.1003081502400.30456@chino.kir.corp.google.com>
 <20100309134633.GM8653@laptop> <alpine.DEB.2.00.1003271849260.7249@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Slab lacks any memory hotplug support for nodes that are hotplugged
without cpus being hotplugged.  This is possible at least on x86
CONFIG_MEMORY_HOTPLUG_SPARSE kernels where SRAT entries are marked
ACPI_SRAT_MEM_HOT_PLUGGABLE and the regions of RAM represent a seperate
node.  It can also be done manually by writing the start address to
/sys/devices/system/memory/probe for kernels that have
CONFIG_ARCH_MEMORY_PROBE set, which is how this patch was tested, and
then onlining the new memory region.

When a node is hotadded, a nodelist for that node is allocated and 
initialized for each slab cache.  If this isn't completed due to a lack
of memory, the hotadd is aborted: we have a reasonable expectation that
kmalloc_node(nid) will work for all caches if nid is online and memory is
available.  

Since nodelists must be allocated and initialized prior to the new node's
memory actually being online, the struct kmem_list3 is allocated off-node
due to kmalloc_node()'s fallback.

When an entire node would be offlined, its nodelists are subsequently
drained.  If slab objects still exist and cannot be freed, the offline is
aborted.  It is possible that objects will be allocated between this
drain and page isolation, so it's still possible that the offline will
still fail, however.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slab.c |  157 ++++++++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 125 insertions(+), 32 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -115,6 +115,7 @@
 #include	<linux/reciprocal_div.h>
 #include	<linux/debugobjects.h>
 #include	<linux/kmemcheck.h>
+#include	<linux/memory.h>
 
 #include	<asm/cacheflush.h>
 #include	<asm/tlbflush.h>
@@ -1102,6 +1103,52 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 }
 #endif
 
+/*
+ * Allocates and initializes nodelists for a node on each slab cache, used for
+ * either memory or cpu hotplug.  If memory is being hot-added, the kmem_list3
+ * will be allocated off-node since memory is not yet online for the new node.
+ * When hotplugging memory or a cpu, existing nodelists are not replaced if
+ * already in use.
+ *
+ * Must hold cache_chain_mutex.
+ */
+static int init_cache_nodelists_node(int node)
+{
+	struct kmem_cache *cachep;
+	struct kmem_list3 *l3;
+	const int memsize = sizeof(struct kmem_list3);
+
+	list_for_each_entry(cachep, &cache_chain, next) {
+		/*
+		 * Set up the size64 kmemlist for cpu before we can
+		 * begin anything. Make sure some other cpu on this
+		 * node has not already allocated this
+		 */
+		if (!cachep->nodelists[node]) {
+			l3 = kmalloc_node(memsize, GFP_KERNEL, node);
+			if (!l3)
+				return -ENOMEM;
+			kmem_list3_init(l3);
+			l3->next_reap = jiffies + REAPTIMEOUT_LIST3 +
+			    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
+
+			/*
+			 * The l3s don't come and go as CPUs come and
+			 * go.  cache_chain_mutex is sufficient
+			 * protection here.
+			 */
+			cachep->nodelists[node] = l3;
+		}
+
+		spin_lock_irq(&cachep->nodelists[node]->list_lock);
+		cachep->nodelists[node]->free_limit =
+			(1 + nr_cpus_node(node)) *
+			cachep->batchcount + cachep->num;
+		spin_unlock_irq(&cachep->nodelists[node]->list_lock);
+	}
+	return 0;
+}
+
 static void __cpuinit cpuup_canceled(long cpu)
 {
 	struct kmem_cache *cachep;
@@ -1172,7 +1219,7 @@ static int __cpuinit cpuup_prepare(long cpu)
 	struct kmem_cache *cachep;
 	struct kmem_list3 *l3 = NULL;
 	int node = cpu_to_node(cpu);
-	const int memsize = sizeof(struct kmem_list3);
+	int err;
 
 	/*
 	 * We need to do this right in the beginning since
@@ -1180,35 +1227,9 @@ static int __cpuinit cpuup_prepare(long cpu)
 	 * kmalloc_node allows us to add the slab to the right
 	 * kmem_list3 and not this cpu's kmem_list3
 	 */
-
-	list_for_each_entry(cachep, &cache_chain, next) {
-		/*
-		 * Set up the size64 kmemlist for cpu before we can
-		 * begin anything. Make sure some other cpu on this
-		 * node has not already allocated this
-		 */
-		if (!cachep->nodelists[node]) {
-			l3 = kmalloc_node(memsize, GFP_KERNEL, node);
-			if (!l3)
-				goto bad;
-			kmem_list3_init(l3);
-			l3->next_reap = jiffies + REAPTIMEOUT_LIST3 +
-			    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
-
-			/*
-			 * The l3s don't come and go as CPUs come and
-			 * go.  cache_chain_mutex is sufficient
-			 * protection here.
-			 */
-			cachep->nodelists[node] = l3;
-		}
-
-		spin_lock_irq(&cachep->nodelists[node]->list_lock);
-		cachep->nodelists[node]->free_limit =
-			(1 + nr_cpus_node(node)) *
-			cachep->batchcount + cachep->num;
-		spin_unlock_irq(&cachep->nodelists[node]->list_lock);
-	}
+	err = init_cache_nodelists_node(node);
+	if (err < 0)
+		goto bad;
 
 	/*
 	 * Now we can go ahead with allocating the shared arrays and
@@ -1331,11 +1352,75 @@ static struct notifier_block __cpuinitdata cpucache_notifier = {
 	&cpuup_callback, NULL, 0
 };
 
+#if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
+/*
+ * Drains freelist for a node on each slab cache, used for memory hot-remove.
+ * Returns -EBUSY if all objects cannot be drained so that the node is not
+ * removed.
+ *
+ * Must hold cache_chain_mutex.
+ */
+static int __meminit drain_cache_nodelists_node(int node)
+{
+	struct kmem_cache *cachep;
+	int ret = 0;
+
+	list_for_each_entry(cachep, &cache_chain, next) {
+		struct kmem_list3 *l3;
+
+		l3 = cachep->nodelists[node];
+		if (!l3)
+			continue;
+
+		drain_freelist(cachep, l3, l3->free_objects);
+
+		if (!list_empty(&l3->slabs_full) ||
+		    !list_empty(&l3->slabs_partial)) {
+			ret = -EBUSY;
+			break;
+		}
+	}
+	return ret;
+}
+
+static int __meminit slab_memory_callback(struct notifier_block *self,
+					unsigned long action, void *arg)
+{
+	struct memory_notify *mnb = arg;
+	int ret = 0;
+	int nid;
+
+	nid = mnb->status_change_nid;
+	if (nid < 0)
+		goto out;
+
+	switch (action) {
+	case MEM_GOING_ONLINE:
+		mutex_lock(&cache_chain_mutex);
+		ret = init_cache_nodelists_node(nid);
+		mutex_unlock(&cache_chain_mutex);
+		break;
+	case MEM_GOING_OFFLINE:
+		mutex_lock(&cache_chain_mutex);
+		ret = drain_cache_nodelists_node(nid);
+		mutex_unlock(&cache_chain_mutex);
+		break;
+	case MEM_ONLINE:
+	case MEM_OFFLINE:
+	case MEM_CANCEL_ONLINE:
+	case MEM_CANCEL_OFFLINE:
+		break;
+	}
+out:
+	return ret ? notifier_from_errno(ret) : NOTIFY_OK;
+}
+#endif /* CONFIG_NUMA && CONFIG_MEMORY_HOTPLUG */
+
 /*
  * swap the static kmem_list3 with kmalloced memory
  */
-static void init_list(struct kmem_cache *cachep, struct kmem_list3 *list,
-			int nodeid)
+static void __init init_list(struct kmem_cache *cachep, struct kmem_list3 *list,
+				int nodeid)
 {
 	struct kmem_list3 *ptr;
 
@@ -1580,6 +1665,14 @@ void __init kmem_cache_init_late(void)
 	 */
 	register_cpu_notifier(&cpucache_notifier);
 
+#ifdef CONFIG_NUMA
+	/*
+	 * Register a memory hotplug callback that initializes and frees
+	 * nodelists.
+	 */
+	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
+#endif
+
 	/*
 	 * The reap timers are started later, with a module init call: That part
 	 * of the kernel is not yet operational.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
