Date: Mon, 25 Feb 2008 12:17:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] radix-tree based page_cgroup. [6/7] radix-tree based
 page cgroup
Message-Id: <20080225121744.a90704fb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

A lookup routine for page_cgroup struct.

Now, page_cgroup is pointed by struct page's page_cgroup entry

struct page {
	...
	struct page_cgroup *page_cgroup;
	..
}

But people dislike this because this increases sizeof(struct page).

For avoiding that, we'll have to add a lookup routine for
	pfn <-> page_cgroup.
by radix-tree.

New function is

struct page *get_page_cgroup(struct page *page, gfp_mask mask);

if (mask != 0), look up and allocate new one if necessary.
if (mask == 0), just do look up and return NULL if not exist.

Each radix-tree entry contains base address of array of page_cgroup.
As sparsemem does, this registered base address is subtracted by base_pfn
for that entry. See sparsemem's logic if unsure.

Signed-off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/Makefile      |    2 
 mm/page_cgroup.c |  151 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 152 insertions(+), 1 deletion(-)

Index: linux-2.6.25-rc2/mm/page_cgroup.c
===================================================================
--- /dev/null
+++ linux-2.6.25-rc2/mm/page_cgroup.c
@@ -0,0 +1,151 @@
+/*
+ * page_cgroup mamagement codes.
+ * page_cgroup is yet another mem_map when cgroup's memory resoruce controller
+ * is activated. It containes information which cannot be stored in usual
+ * mem_map. (it's too big.)
+ * This allows us to keep 'struct page' small when a user doesn't activate
+ * memory resource controller.
+ *
+ * Note: all things are allocated on demand.
+ *
+ * We can translate : struct page <-> pfn -> page_cgroup -> struct page.
+ */
+
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/radix-tree.h>
+#include <linux/memcontrol.h>
+#include <linux/page_cgroup.h>
+#include <linux/err.h>
+
+#define PCGRP_SHIFT	(8)
+#define PCGRP_SIZE	(1 << PCGRP_SHIFT)
+
+struct page_cgroup_root {
+	spinlock_t	       tree_lock;
+	struct radix_tree_root root_node;
+};
+
+static struct page_cgroup_root *root_dir[MAX_NUMNODES];
+
+static void init_page_cgroup(struct page_cgroup *base, unsigned long pfn)
+{
+	int i;
+	int size = PCGRP_SIZE * sizeof (struct page_cgroup);
+	struct page_cgroup *pc;
+
+	memset(base, 0, size);
+	for (i = 0; i < PCGRP_SIZE; ++i) {
+		pc = base + i;
+		pc->page = pfn_to_page(pfn + i);
+		spin_lock_init(&pc->lock);
+		INIT_LIST_HEAD(&pc->lru);
+	}
+}
+
+
+
+static struct page_cgroup *alloc_init_page_cgroup(unsigned long pfn, int nid,
+					gfp_t mask)
+{
+	int size, order;
+	struct page *page;
+
+	size = PCGRP_SIZE * sizeof(struct page_cgroup);
+	order = get_order(PAGE_ALIGN(size));
+	page = alloc_pages_node(nid, mask, order);
+	if (!page)
+		return NULL;
+
+	init_page_cgroup(page_address(page), pfn);
+
+	return page_address(page);
+}
+
+void free_page_cgroup(struct page_cgroup *pc)
+{
+	int size = PCGRP_SIZE * sizeof(struct page_cgroup);
+	int order = get_order(PAGE_ALIGN(size));
+	__free_pages(virt_to_page(pc), order);
+}
+
+
+/*
+ * Look up page_cgroup struct for struct page (page's pfn)
+ * if (gfp_mask != 0), look up and allocate new one if necessary.
+ * if (gfp_mask == 0), look up and return NULL if it cannot be found.
+ */
+
+struct page_cgroup *get_page_cgroup(struct page *page, gfp_t gfpmask)
+{
+	struct page_cgroup_root *root;
+	struct page_cgroup *pc, *base_addr;
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long idx = pfn >> PCGRP_SHIFT;
+	int nid	= page_to_nid(page);
+	unsigned long base_pfn, flags;
+	int error;
+
+	root = root_dir[nid];
+	/* Before Init ? */
+	if (unlikely(!root))
+		return NULL;
+
+	base_pfn = idx << PCGRP_SHIFT;
+retry:
+	error = 0;
+	rcu_read_lock();
+	pc = radix_tree_lookup(&root->root_node, idx);
+	rcu_read_unlock();
+
+	if (likely(pc))
+		return pc + (pfn - base_pfn);
+	if (!gfpmask)
+		return NULL;
+
+	/* Very Slow Path. On demand allocation. */
+	gfpmask = gfpmask & ~(__GFP_HIGHMEM | __GFP_MOVABLE);
+
+	base_addr = alloc_init_page_cgroup(base_pfn, nid, gfpmask);
+	if (!base_addr)
+		return ERR_PTR(-ENOMEM);
+
+	error = radix_tree_preload(gfpmask);
+	if (error)
+		goto out;
+	spin_lock_irqsave(&root->tree_lock, flags);
+	error = radix_tree_insert(&root->root_node, idx, base_addr);
+
+	if (error)
+		pc  = NULL;
+	else
+		pc = base_addr + (pfn - base_pfn);
+	spin_unlock_irqrestore(&root->tree_lock, flags);
+	radix_tree_preload_end();
+out:
+	if (!pc) {
+		free_page_cgroup(base_addr);
+		if (error == -EEXIST)
+			goto retry;
+	}
+	if (error)
+		pc = ERR_PTR(error);
+	return pc;
+}
+
+__init int page_cgroup_init(void)
+{
+	int nid;
+	struct page_cgroup_root *root;
+	for_each_node(nid) {
+		root = kmalloc_node(sizeof(struct page_cgroup_root),
+					GFP_KERNEL, nid);
+		INIT_RADIX_TREE(&root->root_node, GFP_ATOMIC);
+		spin_lock_init(&root->tree_lock);
+		smp_wmb();
+		root_dir[nid] = root;
+	}
+	printk(KERN_INFO "Page Accouintg is activated\n");
+	return 0;
+}
+late_initcall(page_cgroup_init);
Index: linux-2.6.25-rc2/mm/Makefile
===================================================================
--- linux-2.6.25-rc2.orig/mm/Makefile
+++ linux-2.6.25-rc2/mm/Makefile
@@ -32,5 +32,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
-obj-$(CONFIG_CGROUP_MEM_CONT) += memcontrol.o
+obj-$(CONFIG_CGROUP_MEM_CONT) += memcontrol.o page_cgroup.o
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
