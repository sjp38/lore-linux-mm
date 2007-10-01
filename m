Date: Mon, 01 Oct 2007 18:34:39 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch / 002](memory hotplug) Callback function to create kmem_cache_node.
In-Reply-To: <20071001182329.7A97.Y-GOTO@jp.fujitsu.com>
References: <20071001182329.7A97.Y-GOTO@jp.fujitsu.com>
Message-Id: <20071001183316.7A9B.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is to make kmem_cache_nodes of all SLUBs for new node when 
memory-hotadd is called. This fixes panic due to access NULL pointer at
discard_slab() after memory hot-add.

If pages on the new node available, slub can use it before making
new kmem_cache_nodes. So, this callback should be called
BEFORE pages on the node are available.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 mm/slub.c |   79 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 79 insertions(+)

Index: current/mm/slub.c
===================================================================
--- current.orig/mm/slub.c	2007-09-28 11:23:50.000000000 +0900
+++ current/mm/slub.c	2007-09-28 11:23:59.000000000 +0900
@@ -20,6 +20,7 @@
 #include <linux/mempolicy.h>
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include <linux/memory.h>
 
 /*
  * Lock order:
@@ -2097,6 +2098,82 @@ static int init_kmem_cache_nodes(struct 
 	}
 	return 1;
 }
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+static void __slab_callback_offline(int nid)
+{
+	struct kmem_cache_node *n;
+	struct kmem_cache *s;
+
+	list_for_each_entry(s, &slab_caches, list) {
+		if (s->node[nid]) {
+			n = get_node(s, nid);
+			s->node[nid] = NULL;
+			kmem_cache_free(kmalloc_caches, n);
+		}
+	}
+}
+
+static int slab_callback_going_online(void *arg)
+{
+	struct kmem_cache_node *n;
+	struct kmem_cache *s;
+	struct memory_notify *marg = arg;
+	int nid;
+
+	nid = page_to_nid(pfn_to_page(marg->start_pfn));
+
+	/* If the node already has memory, then nothing is necessary. */
+	if (node_state(nid, N_HIGH_MEMORY))
+		return 0;
+
+	/*
+	 * New memory will be onlined on the node which has no memory so far.
+	 * New kmem_cache_node is necssary for it.
+	 */
+	down_read(&slub_lock);
+	list_for_each_entry(s, &slab_caches, list) {
+		/*
+		 * XXX: The new node's memory can't be allocated yet,
+		 *      kmem_cache_node will be allocated other node.
+		 */
+		n = kmem_cache_alloc(kmalloc_caches, GFP_KERNEL);
+		if (!n)
+			goto error;
+		init_kmem_cache_node(n);
+		s->node[nid] = n;
+	}
+	up_read(&slub_lock);
+
+	return 0;
+
+error:
+	__slab_callback_offline(nid);
+	up_read(&slub_lock);
+
+	return -ENOMEM;
+}
+
+static int slab_callback(struct notifier_block *self, unsigned long action,
+			 void *arg)
+{
+	int ret = 0;
+
+	switch (action) {
+	case MEM_GOING_ONLINE:
+		ret = slab_callback_going_online(arg);
+		break;
+	case MEM_ONLINE:
+	case MEM_GOING_OFFLINE:
+	case MEM_MAPPING_INVALID:
+		break;
+	}
+
+	ret = notifier_from_errno(ret);
+	return ret;
+}
+
+#endif /* CONFIG_MEMORY_HOTPLUG */
 #else
 static void free_kmem_cache_nodes(struct kmem_cache *s)
 {
@@ -2730,6 +2807,8 @@ void __init kmem_cache_init(void)
 		sizeof(struct kmem_cache_node), GFP_KERNEL);
 	kmalloc_caches[0].refcount = -1;
 	caches++;
+
+	hotplug_memory_notifier(slab_callback, 1);
 #endif
 
 	/* Able to allocate the per node structures */

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
