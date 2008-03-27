Date: Thu, 27 Mar 2008 17:50:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [-mm] [PATCH 3/4] memcg : shirink page cgroup
Message-Id: <20080327175020.fe916e43.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080327174435.e69f5b45.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080327174435.e69f5b45.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

This patch is for freeing page_cgroup if a chunk of pages are freed.

How this works 
 * when the order of free page reaches PCGRP_SHRINK_ORDER, pcgrp is freed.
   This will be done by RCU.

Changelog v1 -> v2:
 * shrink_order is automatically calculated.
 * added comments.
 * added cpu mask to page_cgroup_head. (this will be help at clearing.)
 * moved a routine for flushing percpu idx after deletion in radix-tree.
 * removed memory barrier. (I noticed that clearing can be done after
   lock/unlock.)
 * add a sanity check not to access a page_cgroup for a page whose refcnt is 0.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsuc.com>


 include/linux/page_cgroup.h |   13 ++++++++
 mm/page_alloc.c             |    2 +
 mm/page_cgroup.c            |   70 ++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 83 insertions(+), 2 deletions(-)

Index: linux-2.6.25-rc5-mm1-k/mm/page_cgroup.c
===================================================================
--- linux-2.6.25-rc5-mm1-k.orig/mm/page_cgroup.c
+++ linux-2.6.25-rc5-mm1-k/mm/page_cgroup.c
@@ -31,12 +31,14 @@
 
 static int page_cgroup_order __read_mostly;
 static int page_cgroup_head_size __read_mostly;
+int pcgroup_shrink_order __read_mostly;
 
 #define PCGRP_SHIFT	(page_cgroup_order)
 #define PCGRP_SIZE	(1 << PCGRP_SHIFT)
 #define PCGRP_MASK	(PCGRP_SIZE - 1)
 
 struct page_cgroup_head {
+	cpumask_t mask;
 	struct page_cgroup pc[0];
 };
 
@@ -61,6 +63,10 @@ static void calc_page_cgroup_order(void)
 	page_cgroup_order = order;
 	page_cgroup_head_size = sizeof(struct page_cgroup_head) +
 				(sizeof(struct page_cgroup) << order);
+	if (order + 1 < MAX_ORDER)
+		pcgroup_shrink_order = order + 1;
+	else
+		pcgroup_shrink_order = MAX_ORDER - 1;
 }
 
 static struct page_cgroup_root __initdata *tmp_root_dir[MAX_NUMNODES];
@@ -72,7 +78,7 @@ init_page_cgroup_head(struct page_cgroup
 	struct page *page;
 	struct page_cgroup *pc;
 	int i;
-
+	cpus_clear(head->mask);
 	for (i = 0, page = pfn_to_page(pfn), pc = &head->pc[0];
 		i < PCGRP_SIZE; i++, page++, pc++) {
 		pc->refcnt = 0;
@@ -120,6 +126,7 @@ static void cache_result(unsigned long i
 	pcp = &get_cpu_var(pcpu_pcgroup_cache);
 	pcp->ents[hnum].idx = idx;
 	pcp->ents[hnum].base = &head->pc[0] - (idx << PCGRP_SHIFT);
+	cpu_set(smp_processor_id(), head->mask);
 	put_cpu_var(pcpu_pcgroup_cache);
 }
 
@@ -150,6 +157,8 @@ static struct page_cgroup_root *pcgroup_
 
 	VM_BUG_ON(!page);
 
+	VM_BUG_ON(!page_count(page));
+
 	nid = page_to_nid(page);
 
 	return root_node[nid];
@@ -257,6 +266,62 @@ out:
 	}
 	return pc;
 }
+/*
+ * This will be called from deep place in free_pages()
+ * Because this is called by page allocator, we can assume that
+ * 1. zone->lock is held.
+ * 2. no one touches pages in [page...page + (1 << order))
+ * 3. Because of 2, page_cgroups against [page...page + (1 << order)]
+ *    is not touched and will not be touched while we hold zone->lock.
+ */
+void __shrink_page_cgroup(struct page *page, int order)
+{
+	struct page_cgroup_root *root;
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long end_pfn;
+	int cpu;
+
+	root = pcgroup_get_root(page);
+	if (in_interrupt() || !root || (order < PCGRP_SHIFT))
+		return;
+
+	pfn = page_to_pfn(page);
+	end_pfn = pfn + (1 << order);
+
+	while (pfn != end_pfn) {
+		if (spin_trylock(&root->tree_lock)) {
+			struct page_cgroup_cache *pcp;
+			struct page_cgroup_head *head = NULL;
+			int idx = pfn >> PCGRP_SHIFT;
+			/*
+			 * Because [pfn, end_pfn) are free pages, we can assume
+			 * no lookup in this range will occur. So this has no
+			 * race. For rafix-tree, we have to take a lock.
+			 * Radix tree is freed by RCU. so they will not call
+			 * free_pages() directly under this.
+			 */
+			head = radix_tree_delete(&root->root_node, idx);
+			spin_unlock(&root->tree_lock);
+
+			/*
+			 * It's guaranteed that no one has access to this pfn
+			 * because there isn't and won't be access to the page
+			 * and page_cgroup.
+			 */
+			if (head) {
+				int hnum = hashfunc(idx);
+				for_each_cpu_mask(cpu, head->mask) {
+					pcp = &per_cpu(pcpu_pcgroup_cache, cpu);
+					if (pcp->ents[hnum].idx == idx)
+						pcp->ents[hnum].base = NULL;
+				}
+				/* SLAB for head is SLAB_DESTROY_BY_RCU. */
+				free_page_cgroup(head);
+			}
+		}
+		pfn += PCGRP_SIZE;
+	}
+}
 
 __init int page_cgroup_init(void)
 {
@@ -296,7 +361,8 @@ __init int page_cgroup_init(void)
 	for_each_node(nid)
 		root_node[nid] = tmp_root_dir[nid];
 
-	printk(KERN_INFO "Page Accouintg is activated\n");
+	printk(KERN_INFO "Page Accouintg is activated, its order is %d\n",
+			page_cgroup_order);
 	return 0;
 unroll:
 	for_each_node(nid)
Index: linux-2.6.25-rc5-mm1-k/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc5-mm1-k.orig/mm/page_alloc.c
+++ linux-2.6.25-rc5-mm1-k/mm/page_alloc.c
@@ -45,6 +45,7 @@
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>
 #include <linux/memcontrol.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -463,6 +464,7 @@ static inline void __free_one_page(struc
 		order++;
 	}
 	set_page_order(page, order);
+	shrink_page_cgroup(page, order);
 	list_add(&page->lru,
 		&zone->free_area[order].free_list[migratetype]);
 	zone->free_area[order].nr_free++;
Index: linux-2.6.25-rc5-mm1-k/include/linux/page_cgroup.h
===================================================================
--- linux-2.6.25-rc5-mm1-k.orig/include/linux/page_cgroup.h
+++ linux-2.6.25-rc5-mm1-k/include/linux/page_cgroup.h
@@ -40,6 +40,15 @@ extern struct page_cgroup *get_page_cgro
 extern struct page_cgroup *
 get_alloc_page_cgroup(struct page *page, gfp_t gfpmask);
 
+extern int pcgroup_shrink_order;
+extern void __shrink_page_cgroup(struct page *page, int order);
+
+static inline void shrink_page_cgroup(struct page *page, int order)
+{
+	if (unlikely(order >= pcgroup_shrink_order))
+		__shrink_page_cgroup(page, order);
+}
+
 #else
 
 static inline struct page_cgroup *get_page_cgroup(struct page *page)
@@ -52,5 +61,9 @@ get_alloc_page_cgroup(struct page *page,
 {
 	return NULL;
 }
+static inline void
+shrink_page_cgroup(struct page *page, int order)
+{
+}
 #endif
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
