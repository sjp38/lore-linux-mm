Date: Thu, 18 Oct 2007 12:25:37 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch](memory hotplug) Make kmem_cache_node for SLUB on memory online to avoid panic(take 3)
Message-Id: <20071018122345.514F.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch fixes panic due to access NULL pointer
of kmem_cache_node at discard_slab() after memory online.

When memory online is called, kmem_cache_nodes are created for
all SLUBs for new node whose memory are available.

slab_mem_going_online_callback() is called to make kmem_cache_node()
in callback of memory online event. If it (or other callbacks) fails,
then slab_mem_offline_callback() is called for rollback.

In memory offline, slab_mem_going_offline_callback() is called to
shrink all slub cache, then slab_mem_offline_callback() is called later.

This patch is tested on my ia64 box.

Please apply.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


---
 mm/slub.c |  115 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 115 insertions(+)

Index: current/mm/slub.c
===================================================================
--- current.orig/mm/slub.c	2007-10-17 21:17:53.000000000 +0900
+++ current/mm/slub.c	2007-10-17 22:23:08.000000000 +0900
@@ -20,6 +20,7 @@
 #include <linux/mempolicy.h>
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include <linux/memory.h>
 
 /*
  * Lock order:
@@ -2688,6 +2689,118 @@ int kmem_cache_shrink(struct kmem_cache 
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+#if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
+static int slab_mem_going_offline_callback(void *arg)
+{
+	struct kmem_cache *s;
+
+	down_read(&slub_lock);
+	list_for_each_entry(s, &slab_caches, list)
+		kmem_cache_shrink(s);
+	up_read(&slub_lock);
+
+	return 0;
+}
+
+static void slab_mem_offline_callback(void *arg)
+{
+	struct kmem_cache_node *n;
+	struct kmem_cache *s;
+	struct memory_notify *marg = arg;
+	int offline_node;
+
+	offline_node = marg->status_change_nid;
+
+	/*
+	 * If the node still has available memory. we need kmem_cache_node
+	 * for it yet.
+	 */
+	if (offline_node < 0)
+		return;
+
+	down_read(&slub_lock);
+	list_for_each_entry(s, &slab_caches, list) {
+		n = get_node(s, offline_node);
+		if (n) {
+			/*
+			 * if n->nr_slabs > 0, slabs still exist on the node
+			 * that is going down. We were unable to free them,
+			 * and offline_pages() function shoudn't call this
+			 * callback. So, we must fail.
+			 */
+			BUG_ON(atomic_read(&n->nr_slabs));
+
+			s->node[offline_node] = NULL;
+			kmem_cache_free(kmalloc_caches, n);
+		}
+	}
+	up_read(&slub_lock);
+}
+
+static int slab_mem_going_online_callback(void *arg)
+{
+	struct kmem_cache_node *n;
+	struct kmem_cache *s;
+	struct memory_notify *marg = arg;
+	int nid = marg->status_change_nid;
+
+	/*
+	 * If the node's memory is already available, then kmem_cache_node is
+	 * already created. Nothing to do.
+	 */
+	if (nid < 0)
+		return 0;
+
+	/*
+	 * We are bringing a node online. No memory is availabe yet. We must
+	 * allocate a kmem_cache_node structure in order to bring the node
+	 * online.
+	 */
+	down_read(&slub_lock);
+	list_for_each_entry(s, &slab_caches, list) {
+  		/*
+		 * XXX: kmem_cache_alloc_node will fallback to other nodes
+		 *      since memory is not yet available from the node that
+		 *      is brought up.
+  		 */
+		n = kmem_cache_alloc(kmalloc_caches, GFP_KERNEL);
+		if (!n)
+			return -ENOMEM;
+		init_kmem_cache_node(n);
+		s->node[nid] = n;
+  	}
+	up_read(&slub_lock);
+
+  	return 0;
+}
+
+static int slab_memory_callback(struct notifier_block *self,
+				unsigned long action, void *arg)
+{
+	int ret = 0;
+
+	switch (action) {
+	case MEM_GOING_ONLINE:
+		ret = slab_mem_going_online_callback(arg);
+		break;
+	case MEM_GOING_OFFLINE:
+		ret = slab_mem_going_offline_callback(arg);
+		break;
+	case MEM_OFFLINE:
+	case MEM_CANCEL_ONLINE:
+		slab_mem_offline_callback(arg);
+		break;
+	case MEM_ONLINE:
+	case MEM_CANCEL_OFFLINE:
+		break;
+	}
+
+	ret = notifier_from_errno(ret);
+	return ret;
+}
+
+#endif /* CONFIG_MEMORY_HOTPLUG */
+
 /********************************************************************
  *			Basic setup of slabs
  *******************************************************************/
@@ -2709,6 +2822,8 @@ void __init kmem_cache_init(void)
 		sizeof(struct kmem_cache_node), GFP_KERNEL);
 	kmalloc_caches[0].refcount = -1;
 	caches++;
+
+	hotplug_memory_notifier(slab_memory_callback, 1);
 #endif
 
 	/* Able to allocate the per node structures */

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
