Date: Thu, 6 Mar 2008 20:26:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Preview] [PATCH] radix tree based page cgroup [0/6]
Message-Id: <20080306202630.5f84e041.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080306.190304.83917780.taka@valinux.co.jp>
References: <20080305205137.5c744097.kamezawa.hiroyu@jp.fujitsu.com>
	<20080306.190304.83917780.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, hugh@veritas.com, yamamoto@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Thu, 06 Mar 2008 19:03:04 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:

> I doubt page_cgroups can be freed effectively since most of the pages
> are used and each of them has its corresponding page_cgroup when you
> need more free memory.
> 
> In this case, right after some page_cgroup freed when the corresponding
> pages are released, these pages are reallocated and page_cgroups are
> also reallocated and assigned to them. It will only give us meaningless
> overhead.
> 
> And I think it doesn't make sense to free page_cgroups to make much more
> free memory if there are a lot of free memory,
> 
> I guess freeing page_cgroup routine will be fine when making hugetlb
> pages.
> 
This is current version. I feel this is reasonable and flexible approach, now.
But of course, I need more tests.

==
This patch is for freeing page_cgroup if a chunk of pages are freed.

Now under test. This works well, now

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsuc.com>


 include/linux/page_cgroup.h |   12 +++++++++
 mm/page_alloc.c             |    3 ++
 mm/page_cgroup.c            |   54 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 69 insertions(+)

Index: linux-2.6.25-rc4/include/linux/page_cgroup.h
===================================================================
--- linux-2.6.25-rc4.orig/include/linux/page_cgroup.h
+++ linux-2.6.25-rc4/include/linux/page_cgroup.h
@@ -38,6 +38,12 @@ DECLARE_PER_CPU(struct page_cgroup_cache
 #define PCGRP_SHIFT	(CONFIG_CGROUP_PAGE_CGROUP_ORDER)
 #define PCGRP_SIZE	(1 << PCGRP_SHIFT)
 
+#if PCGRP_SHIFT + 3 >= MAX_ORDER
+#define PCGRP_SHRINK_ORDER	(MAX_ORDER - 1)
+#else
+#define PCGRP_SHRINK_ORDER	(PCGRP_SHIFT + 3)
+#endif
+
 /*
  * Lookup and return page_cgroup struct.
  * returns NULL when
@@ -69,6 +75,8 @@ get_page_cgroup(struct page *page, gfp_t
 	return (ret)? ret : __get_page_cgroup(page, gfpmask, allocate);
 }
 
+void try_to_shrink_page_cgroup(struct page *page, int order);
+
 #else
 
 static struct page_cgroup *
@@ -76,5 +84,9 @@ get_page_cgroup(struct page *page, gfp_t
 {
 	return NULL;
 }
+static void try_to_shrink_page_cgroup(struct page *page, int order)
+{
+	return 0;
+}
 #endif
 #endif
Index: linux-2.6.25-rc4/mm/page_cgroup.c
===================================================================
--- linux-2.6.25-rc4.orig/mm/page_cgroup.c
+++ linux-2.6.25-rc4/mm/page_cgroup.c
@@ -12,6 +12,7 @@
  */
 
 #include <linux/mm.h>
+#include <linux/mmzone.h>
 #include <linux/slab.h>
 #include <linux/radix-tree.h>
 #include <linux/memcontrol.h>
@@ -80,6 +81,7 @@ static void save_result(struct page_cgro
 	pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
 	pcp->ents[hash].idx = idx;
 	pcp->ents[hash].base = base;
+	smp_wmb();
 	preempt_enable();
 }
 
@@ -156,6 +158,59 @@ out:
 	return pc;
 }
 
+/* Must be called under zone->lock */
+void try_to_shrink_page_cgroup(struct page *page, int order)
+{
+	unsigned long pfn = page_to_pfn(page);
+	int nid = page_to_nid(page);
+	int idx = pfn >> PCGRP_SHIFT;
+	int hnum = (PAGE_CGROUP_NR_CACHE - 1);
+	struct page_cgroup_cache *pcp;
+	struct page_cgroup_head *head;
+	struct page_cgroup_root *root;
+	unsigned long end_pfn;
+	int cpu;
+
+
+	root = root_dir[nid];
+	if (!root || in_interrupt() || (order < PCGRP_SHIFT))
+		return;
+
+	pfn = page_to_pfn(page);
+	end_pfn = pfn + (1 << order);
+
+	while (pfn != end_pfn) {
+		idx = pfn >> PCGRP_SHIFT;
+		/* Is this pfn has entry ? */
+		rcu_read_lock();
+		head = radix_tree_lookup(&root->root_node, idx);
+		rcu_read_unlock();
+		if (!head) {
+			pfn += (1 << PCGRP_SHIFT);
+			continue;
+		}
+		/* It's guaranteed that no one access to this pfn/idx
+		   because there is no reference to this page. */
+		hnum = (idx) & (PAGE_CGROUP_NR_CACHE - 1);
+		for_each_online_cpu(cpu) {
+			pcp = &per_cpu(pcpu_page_cgroup_cache, cpu);
+			smp_rmb();
+			if (pcp->ents[hnum].idx == idx)
+				pcp->ents[hnum].base = NULL;
+		}
+		if (spin_trylock(&root->tree_lock)) {
+			/* radix tree is freed by RCU. so they will not call
+			   free_pages() right now.*/
+			radix_tree_delete(&root->root_node, idx);
+			spin_unlock(&root->tree_lock);
+			/* We can free this in lazy fashion .*/
+			free_page_cgroup(head);
+			printk("free %ld\n",pfn);
+		}
+		pfn += (1 << PCGRP_SHIFT);
+	}
+}
+
 __init int page_cgroup_init(void)
 {
 	int nid;
Index: linux-2.6.25-rc4/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc4.orig/mm/page_alloc.c
+++ linux-2.6.25-rc4/mm/page_alloc.c
@@ -45,6 +45,7 @@
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>
 #include <linux/memcontrol.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -445,6 +446,8 @@ static inline void __free_one_page(struc
 		order++;
 	}
 	set_page_order(page, order);
+	if (order >= PCGRP_SHRINK_ORDER)
+		try_to_shrink_page_cgroup(page, order);
 	list_add(&page->lru,
 		&zone->free_area[order].free_list[migratetype]);
 	zone->free_area[order].nr_free++;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
