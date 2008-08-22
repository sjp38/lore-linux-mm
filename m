Date: Fri, 22 Aug 2008 20:40:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 11/14]  memcg: mem_cgroup private ID
Message-Id: <20080822204017.0ac8ce0a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds a private ID to each memory resource controller.
This is for mem+swap controller.

When we record memcgrp information per each swap entry, rememvering pointer
can consume 8(4) bytes per entry. This is large.

This patch limits the number of memory resource controller to 32768 and
give ID to each controller. (1 bit will be used for flag..)
This can help to save space in future.

ID "0" is used for indicating "invalid" or "not used" ID.
ID "1" is used for root.

(*) 32768 is too small ?

Changelog: 
  - new patch in v2.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   80 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 79 insertions(+), 1 deletion(-)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -40,6 +40,7 @@
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 static struct kmem_cache *page_cgroup_cache __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
+#define NR_MEMCGRP_ID			(32767)
 
 /*
  * Statistics for memory cgroup.
@@ -144,6 +145,10 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat stat;
 	/*
+	 * private ID
+	 */
+	unsigned short	memcgrp_id;
+	/*
 	 * special flags.
 	 */
 	int	no_limit;
@@ -324,6 +329,69 @@ static void mem_counter_reset(struct mem
 	spin_unlock_irqrestore(&mem->res.lock, flags);
 }
 
+/*
+ * private ID management for memcg.
+ * set/clear bitmap is called by create/destroy and done under cgroup_mutex.
+ */
+static unsigned long *memcgrp_id_bitmap;
+static struct mem_cgroup **memcgrp_array;
+int nr_memcgrp;
+
+static int memcgrp_id_init(void)
+{
+	void *addr;
+	unsigned long bitmap_size = NR_MEMCGRP_ID/8;
+	unsigned long array_size = NR_MEMCGRP_ID * sizeof(void*);
+
+	addr = kmalloc(bitmap_size, GFP_KERNEL | __GFP_ZERO);
+	if (!addr)
+		return -ENOMEM;
+	memcgrp_array = vmalloc(array_size);
+	if (!memcgrp_array) {
+		kfree(memcgrp_array);
+		return -ENOMEM;
+	}
+	memcgrp_id_bitmap = addr;
+	/* 0 for "invalid id" */
+	set_bit(0, memcgrp_id_bitmap);
+	set_bit(1, memcgrp_id_bitmap);
+	memcgrp_array[0] = NULL;
+	memcgrp_array[1] = &init_mem_cgroup;
+	init_mem_cgroup.memcgrp_id = 1;
+	nr_memcgrp = 1;
+	return 0;
+}
+
+static unsigned int get_new_memcgrp_id(struct mem_cgroup *mem)
+{
+	int id;
+	id = find_first_zero_bit(memcgrp_id_bitmap, NR_MEMCGRP_ID);
+
+	if (id == NR_MEMCGRP_ID - 1)
+		return -ENOSPC;
+	set_bit(id, memcgrp_id_bitmap);
+	memcgrp_array[id] = mem;
+	mem->memcgrp_id = id;
+
+	return 0;
+}
+
+static void free_memcgrp_id(struct mem_cgroup *mem)
+{
+	memcgrp_array[mem->memcgrp_id] = NULL;
+	clear_bit(mem->memcgrp_id , memcgrp_id_bitmap);
+}
+
+/*
+ * please access this while you can convice memcgroup exist.
+ */
+
+static struct mem_cgroup *mem_cgroup_id_lookup(unsigned short id)
+{
+	return memcgrp_array[id];
+}
+
+
 
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
 			struct page_cgroup *pc)
@@ -1358,12 +1426,19 @@ mem_cgroup_create(struct cgroup_subsys *
 	int node;
 
 	if (unlikely((cont->parent) == NULL)) {
+		if (memcgrp_id_init())
+			return ERR_PTR(-ENOMEM);
 		mem = &init_mem_cgroup;
 		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
 			return ERR_PTR(-ENOMEM);
+
+		if (get_new_memcgrp_id(mem)) {
+			kfree(mem);
+			return ERR_PTR(-ENOSPC);
+		}
 	}
 
 	mem_counter_init(mem);
@@ -1380,8 +1455,10 @@ mem_cgroup_create(struct cgroup_subsys *
 free_out:
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
-	if (cont->parent != NULL)
+	if (cont->parent != NULL) {
+		free_memcgrp_id(mem);
 		mem_cgroup_free(mem);
+	}
 	return ERR_PTR(-ENOMEM);
 }
 
@@ -1398,6 +1475,7 @@ static void mem_cgroup_destroy(struct cg
 	int node;
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
+	free_memcgrp_id(mem);
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
