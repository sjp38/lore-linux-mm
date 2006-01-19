From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Message-Id: <20060119080418.24736.74961.sendpatchset@debian>
In-Reply-To: <20060119080408.24736.13148.sendpatchset@debian>
References: <20060119080408.24736.13148.sendpatchset@debian>
Subject: [PATCH 2/2] Add CKRM memory resource controller using pzones
Date: Thu, 19 Jan 2006 17:04:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: linux-mm@kvack.org, KUROSAWA Takahiro <kurosawa@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch implements the CKRM memory resource controller using
pzones.  This patch requires CKRM patched source code.

CKRM patches can be obtained from
 http://sourceforge.net/project/showfiles.php?group_id=85838&package_id=163747

The CKRM patches requires configfs-patched source code:
 http://oss.oracle.com/projects/ocfs2/dist/files/patches/2.6.15-rc5/2005-12-14/01_configfs.patch

Signed-off-by: MAEDA Naoaki <maeda.naoaki@jp.fujitsu.com>

---
 include/linux/gfp.h |   31 ++
 mm/Kconfig          |    8 
 mm/Makefile         |    2 
 mm/mem_rc_pzone.c   |  597 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/mempolicy.c      |   10 
 5 files changed, 645 insertions(+), 3 deletions(-)

diff -urNp b/include/linux/gfp.h c/include/linux/gfp.h
--- b/include/linux/gfp.h	2006-01-17 10:25:44.000000000 +0900
+++ c/include/linux/gfp.h	2006-01-17 10:04:53.000000000 +0900
@@ -104,12 +104,43 @@ static inline void arch_free_page(struct
 extern struct page *
 FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
 
+#ifdef CONFIG_MEM_RC
+static inline int mem_rc_available(gfp_t gfp_mask, unsigned int order)
+{
+	gfp_mask &= GFP_LEVEL_MASK & ~__GFP_HIGHMEM;
+	return gfp_mask == GFP_USER && order == 0;
+}
+
+extern struct page *alloc_page_mem_rc(int nid, gfp_t gfp_mask);
+extern struct zonelist *mem_rc_get_zonelist(int nd, gfp_t gfp_mask,
+		unsigned int order);
+#else
+static inline int mem_rc_available(gfp_t gfp_mask, unsigned int order)
+{
+	return 0;
+}
+
+static inline struct page *alloc_page_mem_rc(int nid, gfp_t gfp_mask)
+{
+	return NULL;
+}
+
+static inline struct zonelist *mem_rc_get_zonelist(int nd, gfp_t gfp_mask,
+		unsigned int order)
+{
+	return NULL;
+}
+#endif
+
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
 	if (unlikely(order >= MAX_ORDER))
 		return NULL;
 
+	if (mem_rc_available(gfp_mask, order))
+		return alloc_page_mem_rc(nid, gfp_mask);
+
 	return __alloc_pages(gfp_mask, order,
 		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
 }
diff -urNp b/mm/Kconfig c/mm/Kconfig
--- b/mm/Kconfig	2006-01-17 10:12:56.000000000 +0900
+++ c/mm/Kconfig	2006-01-17 10:05:26.000000000 +0900
@@ -138,3 +138,11 @@ config PSEUDO_ZONE
 	help
 	  This option provides pseudo zone creation from a non-pseudo zone.
 	  Pseudo zones could be used for memory resource management.
+
+config MEM_RC
+	bool "Memory resource controller"
+	select PSEUDO_ZONE
+	depends on CPUMETER || CKRM
+	help
+	  This options will let you control the memory resource by using 
+	  the pseudo zone.
diff -urNp b/mm/Makefile c/mm/Makefile
--- b/mm/Makefile	2006-01-17 10:13:22.000000000 +0900
+++ c/mm/Makefile	2006-01-17 10:04:53.000000000 +0900
@@ -20,3 +20,5 @@ obj-$(CONFIG_SHMEM) += shmem.o
 obj-$(CONFIG_TINY_SHMEM) += tiny-shmem.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
+
+obj-$(CONFIG_MEM_RC) += mem_rc_pzone.o
diff -urNp b/mm/mem_rc_pzone.c c/mm/mem_rc_pzone.c
--- b/mm/mem_rc_pzone.c	1970-01-01 09:00:00.000000000 +0900
+++ c/mm/mem_rc_pzone.c	2006-01-17 10:09:46.000000000 +0900
@@ -0,0 +1,597 @@
+/*
+ *  mm/mem_rc_pzone.c
+ *
+ *  Memory resource controller by using pzones.
+ *
+ *  Copyright 2005 FUJITSU LIMITED
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/config.h>
+#include <linux/stddef.h>
+#include <linux/compiler.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/cpuset.h>
+#include <linux/bitops.h>
+#include <linux/cpumask.h>
+#include <linux/nodemask.h>
+#include <linux/ckrm_rc.h>
+
+#include <asm/semaphore.h>
+
+#define MEM_RC_METER_BASE	100
+#define MEM_RC_METER_TO_PAGES(_rcd, _node, _zidx, _val) \
+	((_rcd)->zone_pages[(_node)][(_zidx)] * (_val) / MEM_RC_METER_BASE)
+
+struct mem_rc_domain {
+	struct semaphore sem;
+	nodemask_t nodes;
+	unsigned long *zone_pages[MAX_NUMNODES];
+};
+
+struct mem_rc {
+	unsigned long guarantee;
+	struct mem_rc_domain *rcd;
+	struct zone **zones[MAX_NUMNODES];
+	struct zonelist *zonelists[MAX_NUMNODES];
+};
+
+
+struct ckrm_mem {
+	struct ckrm_class *class;	/* the class I belong to */
+	struct ckrm_class *parent;	/* parent of the class above. */
+	struct ckrm_shares shares;
+	spinlock_t cnt_lock;	/* always grab parent's lock before child's */
+	struct mem_rc	*mem_rc;	/* mem resource controller */
+	int 	cnt_total_guarantee; 	/* total guarantee behind the class */
+};
+
+static struct mem_rc_domain *grcd; /* system wide resource controller domain */
+static struct ckrm_res_ctlr rcbs; /* resource controller callback structure */
+
+static void mem_rc_destroy_rcdomain(void *arg)
+{
+	struct mem_rc_domain *rcd = arg;
+	int node;
+
+	for_each_node_mask(node, rcd->nodes) {
+		if (rcd->zone_pages[node])
+			kfree(rcd->zone_pages[node]);
+	}
+
+	kfree(rcd);
+}
+
+static void *mem_rc_create_rcdomain(struct cpuset *cs,
+					cpumask_t cpus, nodemask_t mems)
+{
+	struct mem_rc_domain *rcd;
+	struct zone *z;
+	pg_data_t *pgdat;
+	unsigned long *pp;
+	int i, node, allocn;
+
+	allocn = first_node(mems);
+	rcd = kmalloc_node(sizeof(*rcd), GFP_KERNEL, allocn);
+	if (!rcd)
+		return NULL;
+
+	memset(rcd, 0, sizeof(*rcd));
+
+	init_MUTEX(&rcd->sem);
+	rcd->nodes = mems;
+	for_each_node_mask(node, mems) {
+		pgdat = NODE_DATA(node);
+
+		pp = kmalloc_node(sizeof(unsigned long) * MAX_NR_ZONES,
+				  GFP_KERNEL, allocn);
+		if (!pp)
+			goto failed;
+
+		rcd->zone_pages[node] = pp;
+		for (i = 0; i < MAX_NR_ZONES; i++) {
+			if (i == ZONE_DMA) {
+				pp[i] = 0;
+				continue;
+			}
+			z = pgdat->node_zones + i;
+			pp[i] = z->present_pages;
+		}
+	}
+
+	return rcd;
+
+failed:
+	mem_rc_destroy_rcdomain(rcd);
+
+	return NULL;
+}
+
+
+static void *mem_rc_create(void *arg, char *name)
+{
+	struct mem_rc_domain *rcd = arg;
+	struct mem_rc *mr;
+	struct zonelist *zl, *zl_ref;
+	struct zone *parent, *z, *z_ref;
+	pg_data_t *pgdat;
+	int node, allocn;
+	int i, j;
+
+	allocn = first_node(rcd->nodes);
+	mr = kmalloc_node(sizeof(*mr), GFP_KERNEL, allocn);
+	if (!mr)
+		return NULL;
+
+	memset(mr, 0, sizeof(*mr));
+
+	down(&rcd->sem);
+	mr->rcd = rcd;
+	for_each_node_mask(node, rcd->nodes) {
+		pgdat = NODE_DATA(node);
+
+		mr->zones[node]
+			= kmalloc_node(sizeof(*mr->zones[node]) * MAX_NR_ZONES,
+				       GFP_KERNEL, allocn);
+		if (!mr->zones[node])
+			goto failed;
+
+		memset(mr->zones[node], 0,
+		       sizeof(*mr->zones[node]) * MAX_NR_ZONES);
+
+		mr->zonelists[node]
+			= kmalloc_node(sizeof(*mr->zonelists[node]),
+				       GFP_KERNEL, allocn);
+		if (!mr->zonelists[node])
+			goto failed;
+
+		memset(mr->zonelists[node], 0, sizeof(*mr->zonelists[node]));
+
+		for (i = 0; i < MAX_NR_ZONES; i++) {
+			parent = pgdat->node_zones + i;
+			if (rcd->zone_pages[node][i] == 0)
+				continue;
+
+			z = pzone_create(parent, name, 0);
+			if (!z)
+				goto failed;
+			mr->zones[node][i] = z;
+		}
+	}
+
+	for_each_node_mask(node, rcd->nodes) {
+		/* NORMAL zones and DMA zones also in HIGHMEM zonelist. */
+		zl_ref = NODE_DATA(node)->node_zonelists + __GFP_HIGHMEM;
+		zl = mr->zonelists[node];
+
+		for (j = i = 0; i < ARRAY_SIZE(zl_ref->zones); i++) {
+			z_ref = zl_ref->zones[i];
+			if (!z_ref)
+				break;
+
+			z = mr->zones[node][zone_idx(z_ref)];
+			if (!z)
+				continue;
+			zl->zones[j++] = z;
+		}
+		zl->zones[j] = NULL;
+	}
+	up(&rcd->sem);
+
+	return mr;
+
+failed:
+	for_each_node_mask(node, rcd->nodes) {
+		if (mr->zonelists[node])
+			kfree(mr->zonelists[node]);
+
+		if (!mr->zones[node])
+			continue;
+
+		for (i = 0; i < MAX_NR_ZONES; i++) {
+			z = mr->zones[node][i];
+			if (!z)
+				continue;
+			pzone_destroy(z);
+		}
+		kfree(mr->zones[node]);
+	}
+	up(&rcd->sem);
+	kfree(mr);
+
+	return NULL;
+}
+
+static void mem_rc_destroy(void *p)
+{
+	struct mem_rc *mr = p;
+	struct mem_rc_domain *rcd = mr->rcd;
+	struct zone *z;
+	int node, i;
+
+	down(&rcd->sem);
+	for (node = 0; node < MAX_NUMNODES; node++) {
+		if (mr->zonelists[node])
+			kfree(mr->zonelists[node]);
+			
+		if (!mr->zones[node])
+			continue;
+
+		for (i = 0; i < MAX_NR_ZONES; i++) {
+			z = mr->zones[node][i];
+			if (z)
+				pzone_destroy(z);
+			mr->zones[node][i] = NULL;
+		}
+		kfree(mr->zones[node]);
+	}
+	up(&rcd->sem);
+
+	kfree(mr);
+}
+
+static int mem_rc_set_guar(void *ctldata, unsigned long val)
+{
+	struct mem_rc *mr = ctldata;
+	struct mem_rc_domain *rcd = mr->rcd;
+	struct zone *z;
+	nodemask_t nodes_done;
+	int err;
+	int node;
+	int i;
+
+	down(&rcd->sem);
+	nodes_clear(nodes_done);
+	for_each_node_mask(node, rcd->nodes) {
+		for (i = 0; i < MAX_NR_ZONES; i++) {
+			z = mr->zones[node][i];
+			if (!z)
+				continue;
+
+			err = pzone_set_numpages(z,
+					MEM_RC_METER_TO_PAGES(rcd,
+						node, i, val));
+			if (err)
+				goto undo;
+		}
+		node_set(node, nodes_done);
+	}
+
+	mr->guarantee = val;
+	up(&rcd->sem);
+
+	return 0;
+
+undo:
+	for (i--; i >= 0; i--)
+		pzone_set_numpages(z, MEM_RC_METER_TO_PAGES(rcd, node, i, 
+						mr->guarantee));
+		
+	for_each_node_mask(node, nodes_done) {
+		for (i = 0; i < MAX_NR_ZONES; i++) {
+			z = mr->zones[node][i];
+			if (!z)
+				continue;
+
+			pzone_set_numpages(z,
+					MEM_RC_METER_TO_PAGES(rcd,
+						node, i, mr->guarantee));
+		}
+	}
+	up(&rcd->sem);
+
+	return err;
+}
+
+static int mem_rc_get_cur(void *ctldata, unsigned long *valp)
+{
+	struct mem_rc *mr = ctldata;
+	struct mem_rc_domain *rcd = mr->rcd;
+	struct zone *z;
+	unsigned long total, used;
+	int node;
+	int i;
+
+	total = used = 0;
+	for_each_node_mask(node, rcd->nodes) {
+		for (i = 0; i < MAX_NR_ZONES; i++) {
+			z = mr->zones[node][i];
+			if (!z)
+				continue;
+			total += z->present_pages;
+			used += z->present_pages - z->free_pages;
+		}
+	}
+
+	if (total > 0)
+		*valp = mr->guarantee * used / total;
+	else
+		*valp = 0;
+
+	return 0;
+}
+
+struct mem_rc *mem_rc_get(task_t *tsk)
+{
+	struct ckrm_class *class = tsk->class;
+	struct ckrm_mem *res;
+
+	if (unlikely(class == NULL))
+		return NULL;
+
+	res = ckrm_get_res_class(class, rcbs.resid, struct ckrm_mem);
+
+	if (unlikely(res == NULL))
+		return NULL;
+
+	return res->mem_rc;
+}
+EXPORT_SYMBOL(mem_rc_get);
+
+struct page *alloc_page_mem_rc(int nid, gfp_t gfpmask)
+{
+	struct mem_rc *mr;
+
+	mr = mem_rc_get(current);
+	if (!mr)
+		return __alloc_pages(gfpmask, 0,
+				     NODE_DATA(nid)->node_zonelists
+				     + (gfpmask & GFP_ZONEMASK));
+
+	return __alloc_pages(gfpmask, 0, mr->zonelists[nid]);
+}
+EXPORT_SYMBOL(alloc_page_mem_rc);
+
+struct zonelist *mem_rc_get_zonelist(int nd, gfp_t gfpmask,
+				     unsigned int order)
+{
+	struct mem_rc *mr;
+
+	if (!mem_rc_available(gfpmask, order))
+		return NULL;
+
+	mr = mem_rc_get(current);
+	if (!mr)
+		return NULL;
+
+	return mr->zonelists[nd];
+}
+
+static void mem_rc_set_guarantee(struct ckrm_mem *res, int val)
+{
+	int	rc;
+
+	if (res->mem_rc == NULL)
+		return;
+
+	res->mem_rc->guarantee = val;
+	rc = mem_rc_set_guar(res->mem_rc, (unsigned long)val);
+	if (rc)
+		printk("mem_rc_set_guar failed, err = %d\n", rc);
+}
+
+static void mem_res_initcls_one(struct ckrm_mem * res)
+{
+	res->shares.my_guarantee = 0;
+	res->shares.my_limit = CKRM_SHARE_DONTCARE;
+	res->shares.total_guarantee = CKRM_SHARE_DFLT_TOTAL_GUARANTEE;
+	res->shares.max_limit = CKRM_SHARE_DONTCARE;
+	res->shares.unused_guarantee = CKRM_SHARE_DFLT_TOTAL_GUARANTEE;
+	res->cnt_total_guarantee = 0;
+
+	return;
+}
+
+static void *mem_res_alloc(struct ckrm_class *class,
+				struct ckrm_class *parent)
+{
+	struct ckrm_mem *res;
+
+	res = kmalloc(sizeof(struct ckrm_mem), GFP_ATOMIC);
+
+	if (res) {
+		memset(res, 0, sizeof(struct ckrm_mem));
+		res->class = class;
+		res->parent = parent;
+		mem_res_initcls_one(res);
+		res->cnt_lock = SPIN_LOCK_UNLOCKED;
+		if (!parent)	{	/* root class */
+			res->cnt_total_guarantee = CKRM_SHARE_DFLT_TOTAL_GUARANTEE;
+			res->shares.my_guarantee = CKRM_SHARE_DONTCARE;
+		} else {
+			res->mem_rc = (struct mem_rc *)mem_rc_create(grcd, class->name);
+			if (res->mem_rc == NULL)
+				printk(KERN_ERR "mem_rc_create failed\n");
+		}
+	} else {
+		printk(KERN_ERR
+		       "mem_res_alloc: failed GFP_ATOMIC alloc\n");
+	}
+	return res;
+}
+
+static void mem_res_free(void *my_res)
+{
+	struct ckrm_mem *res = my_res, *parres;
+	u64	temp = 0;
+
+	if (!res)
+		return;
+
+	parres = ckrm_get_res_class(res->parent, rcbs.resid, struct ckrm_mem);
+	/* return child's guarantee to parent class */
+	spin_lock(&parres->cnt_lock);
+	ckrm_child_guarantee_changed(&parres->shares, res->shares.my_guarantee, 0);
+	if (parres->shares.total_guarantee) {
+		temp = (u64) parres->shares.unused_guarantee
+				* parres->cnt_total_guarantee;
+		do_div(temp, parres->shares.total_guarantee);
+	}
+	mem_rc_set_guarantee(parres, temp);
+	spin_unlock(&parres->cnt_lock);
+
+	mem_rc_destroy(res->mem_rc);
+	kfree(res);
+	return;
+}
+
+static void
+recalc_and_propagate(struct ckrm_mem * res)
+{
+	struct ckrm_class *child = NULL;
+	struct ckrm_mem *parres, *childres;
+	u64	cnt_total = 0,	cnt_guar = 0;
+
+	parres = ckrm_get_res_class(res->parent, rcbs.resid, struct ckrm_mem);
+
+	if (parres) {
+		struct ckrm_shares *par = &parres->shares;
+		struct ckrm_shares *self = &res->shares;
+
+		/* calculate total and currnet guarantee */
+		if (par->total_guarantee && self->total_guarantee) {
+			cnt_total = (u64) self->my_guarantee
+					 * parres->cnt_total_guarantee;
+			do_div(cnt_total, par->total_guarantee);
+			cnt_guar = (u64) self->unused_guarantee * cnt_total;
+			do_div(cnt_guar, self->total_guarantee);
+		}
+		mem_rc_set_guarantee(res, (int) cnt_guar);
+		res->cnt_total_guarantee = (int ) cnt_total;
+	}
+
+	/* propagate to children */
+	ckrm_lock_hier(res->class);
+	while ((child = ckrm_get_next_child(res->class, child)) != NULL) {
+		childres =
+			ckrm_get_res_class(child, rcbs.resid, struct ckrm_mem);
+		if (childres) {
+		    spin_lock(&childres->cnt_lock);
+		    recalc_and_propagate(childres);
+		    spin_unlock(&childres->cnt_lock);
+		}
+	}
+	ckrm_unlock_hier(res->class);
+	return;
+}
+
+static int mem_set_share_values(void *my_res, struct ckrm_shares *new)
+{
+	struct ckrm_mem *parres, *res = my_res;
+	struct ckrm_shares *cur = &res->shares, *par;
+	int rc = -EINVAL;
+	u64	temp = 0;
+
+	if (!res)
+		return rc;
+
+	if (res->parent) {
+		parres =
+		   ckrm_get_res_class(res->parent, rcbs.resid, struct ckrm_mem);
+		spin_lock(&parres->cnt_lock);
+		spin_lock(&res->cnt_lock);
+		par = &parres->shares;
+	} else {
+		spin_lock(&res->cnt_lock);
+		par = NULL;
+		parres = NULL;
+	}
+
+	rc = ckrm_set_shares(new, cur, par);
+
+	if (rc)
+		goto share_err;
+
+	if (parres) {
+		/* adjust parent's unused guarantee */
+		if (par->total_guarantee) {
+			temp = (u64) par->unused_guarantee
+					* parres->cnt_total_guarantee;
+			do_div(temp, par->total_guarantee);
+		}
+		mem_rc_set_guarantee(parres, temp);
+	} else {
+		/* adjust root class's unused guarantee */
+		temp = (u64) cur->unused_guarantee
+				* CKRM_SHARE_DFLT_TOTAL_GUARANTEE;
+		do_div(temp, cur->total_guarantee);
+		mem_rc_set_guarantee(res, temp);
+	}
+	recalc_and_propagate(res);
+
+share_err:
+	spin_unlock(&res->cnt_lock);
+	if (res->parent)
+		spin_unlock(&parres->cnt_lock);
+	return rc;
+}
+
+static int mem_get_share_values(void *my_res, struct ckrm_shares *shares)
+{
+	struct ckrm_mem *res = my_res;
+
+	if (!res)
+		return -EINVAL;
+	*shares = res->shares;
+	return 0;
+}
+
+static ssize_t mem_show_stats(void *my_res, char *buf)
+{
+	struct ckrm_mem *res = my_res;
+	unsigned long val;
+	ssize_t	i;
+
+	if (!res)
+		return -EINVAL;
+
+	if (res->mem_rc == NULL)
+		return 0;
+
+	mem_rc_get_cur(res->mem_rc, &val);
+	i = sprintf(buf, "mem:current=%ld\n", val);
+	return i;
+}
+
+static struct ckrm_res_ctlr rcbs = {
+	.res_name = "mem",
+	.resid = -1,
+	.res_alloc = mem_res_alloc,
+	.res_free = mem_res_free,
+	.set_share_values = mem_set_share_values,
+	.get_share_values = mem_get_share_values,
+	.show_stats = mem_show_stats,
+};
+
+static void init_global_rcd(void)
+{
+	grcd = (struct mem_rc_domain *) mem_rc_create_rcdomain((struct cpuset *)NULL, cpu_online_map, node_online_map);
+	if (grcd == NULL)
+		printk("mem_rc_create_rcdomain failed\n");
+}
+
+int __init init_ckrm_mem_res(void)
+{
+	init_global_rcd();
+	if (rcbs.resid == CKRM_NO_RES)	{
+		ckrm_register_res_ctlr(&rcbs);
+	}
+	return 0;
+}
+
+void __exit exit_ckrm_mem_res(void)
+{
+	ckrm_unregister_res_ctlr(&rcbs);
+	mem_rc_destroy_rcdomain(grcd);
+}
+
+module_init(init_ckrm_mem_res)
+module_exit(exit_ckrm_mem_res)
+
+MODULE_LICENSE("GPL")
diff -urNp b/mm/mempolicy.c c/mm/mempolicy.c
--- b/mm/mempolicy.c	2006-01-03 12:21:10.000000000 +0900
+++ c/mm/mempolicy.c	2006-01-17 10:04:53.000000000 +0900
@@ -726,8 +726,10 @@ get_vma_policy(struct task_struct *task,
 }
 
 /* Return a zonelist representing a mempolicy */
-static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
+static struct zonelist *zonelist_policy(gfp_t gfp, int order,
+		struct mempolicy *policy)
 {
+	struct zonelist *zl;
 	int nd;
 
 	switch (policy->policy) {
@@ -746,6 +748,8 @@ static struct zonelist *zonelist_policy(
 	case MPOL_INTERLEAVE: /* should not happen */
 	case MPOL_DEFAULT:
 		nd = numa_node_id();
+		if ((zl = mem_rc_get_zonelist(nd, gfp, order)) != NULL)
+			return zl;
 		break;
 	default:
 		nd = 0;
@@ -844,7 +848,7 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 		}
 		return alloc_page_interleave(gfp, 0, nid);
 	}
-	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
+	return __alloc_pages(gfp, 0, zonelist_policy(gfp, 0, pol));
 }
 
 /**
@@ -876,7 +880,7 @@ struct page *alloc_pages_current(gfp_t g
 		pol = &default_policy;
 	if (pol->policy == MPOL_INTERLEAVE)
 		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
-	return __alloc_pages(gfp, order, zonelist_policy(gfp, pol));
+	return __alloc_pages(gfp, order, zonelist_policy(gfp, order, pol));
 }
 EXPORT_SYMBOL(alloc_pages_current);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
