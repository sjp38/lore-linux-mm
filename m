Date: Tue, 10 May 2005 21:38:34 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050511043834.10876.28719.33858@jackhammer.engr.sgi.com>
In-Reply-To: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.12-rc3 6/8] mm: manual page migration-rc2 -- sys_migrate_pages-mempolicy-migration-rc2.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>
List-ID: <linux-mm.kvack.org>

This patch adds code that translates the memory policy structures
as they are encountered to that they continue to represent where
memory should be allocated after the page migration has completed.

Signed-off-by: Ray Bryant <raybry@sgi.com>

 include/linux/mempolicy.h |    2 
 mm/mempolicy.c            |  114 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/mmigrate.c             |   10 ++++
 3 files changed, 126 insertions(+)

Index: linux-2.6.12-rc3-mhp1-page-migration-export/include/linux/mempolicy.h
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/include/linux/mempolicy.h	2005-05-10 11:17:55.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/include/linux/mempolicy.h	2005-05-10 11:18:24.000000000 -0700
@@ -152,6 +152,8 @@ struct mempolicy *mpol_shared_policy_loo
 
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
+extern int migrate_process_policy(struct task_struct *, short *);
+extern int migrate_vma_policy(struct vm_area_struct *, short *);
 
 #else
 
Index: linux-2.6.12-rc3-mhp1-page-migration-export/mm/mempolicy.c
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/mm/mempolicy.c	2005-05-10 11:17:55.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/mm/mempolicy.c	2005-05-10 11:18:24.000000000 -0700
@@ -1136,3 +1136,117 @@ void numa_default_policy(void)
 {
 	sys_set_mempolicy(MPOL_DEFAULT, NULL, 0);
 }
+
+/*
+ * update a node mask according to a migration request
+ */
+static void migrate_node_mask(unsigned long *new_node_mask,
+			      unsigned long *old_node_mask,
+			      short *nodemap)
+{
+	int i;
+
+	bitmap_zero(new_node_mask, MAX_NUMNODES);
+
+	i = find_first_bit(old_node_mask, MAX_NUMNODES);
+	while(i < MAX_NUMNODES) {
+		if (nodemap[i] >= 0)
+			set_bit(nodemap[i], new_node_mask);
+		else
+			set_bit(i, new_node_mask);
+		i = find_next_bit(old_node_mask, MAX_NUMNODES, i+1);
+	}
+}
+
+/*
+ * update a process or vma mempolicy according to a migration request
+ */
+static struct mempolicy *migrate_policy(struct mempolicy *old, short *nodemap)
+{
+	struct mempolicy *new;
+	DECLARE_BITMAP(old_nodes, MAX_NUMNODES);
+	DECLARE_BITMAP(new_nodes, MAX_NUMNODES);
+	struct zone *z;
+	int i;
+
+	new = kmem_cache_alloc(policy_cache, GFP_KERNEL);
+	if (!new)
+		return ERR_PTR(-ENOMEM);
+	atomic_set(&new->refcnt, 0);
+	switch(old->policy) {
+	case MPOL_DEFAULT:
+		BUG();
+	case MPOL_INTERLEAVE:
+		migrate_node_mask(new->v.nodes, old->v.nodes, nodemap);
+		break;
+	case MPOL_PREFERRED:
+		if (old->v.preferred_node>=0 && (nodemap[old->v.preferred_node] >= 0))
+			new->v.preferred_node = nodemap[old->v.preferred_node];
+		else
+			new->v.preferred_node = old->v.preferred_node;
+		break;
+	case MPOL_BIND:
+		bitmap_zero(old_nodes, MAX_NUMNODES);
+		for (i = 0; (z = old->v.zonelist->zones[i]) != NULL; i++)
+			set_bit(z->zone_pgdat->node_id, old_nodes);
+		migrate_node_mask(new_nodes, old_nodes, nodemap);
+		new->v.zonelist = bind_zonelist(new_nodes);
+		if (!new->v.zonelist) {
+			kmem_cache_free(policy_cache, new);
+			return ERR_PTR(-ENOMEM);
+		}
+	}
+	new->policy = old->policy;
+	return new;
+}
+
+/*
+ * update a process mempolicy based on a migration request
+ */
+int migrate_process_policy(struct task_struct *task, short *nodemap)
+{
+	struct mempolicy *new, *old = task->mempolicy;
+	int tmp;
+
+	if ((!old) || (old->policy == MPOL_DEFAULT))
+		return 0;
+
+	new = migrate_policy(task->mempolicy, nodemap);
+	if (IS_ERR(new))
+		return (PTR_ERR(new));
+
+	mpol_get(new);
+	task->mempolicy = new;
+	mpol_free(old);
+
+	if (task->mempolicy->policy == MPOL_INTERLEAVE) {
+		/*
+		 * If the task is still running and allocating storage, this
+		 * is racy, but there is not much that can be done about it.
+		 */
+		tmp = task->il_next;
+		if (nodemap[tmp] >= 0)
+			task->il_next = nodemap[tmp];
+	}
+
+	return 0;
+
+}
+
+/*
+ * update a vma mempolicy based on a migration request
+ */
+int migrate_vma_policy(struct vm_area_struct *vma, short *nodemap)
+{
+
+	struct mempolicy *new;
+
+	if (!vma->vm_policy || vma->vm_policy->policy == MPOL_DEFAULT)
+		return 0;
+
+	new = migrate_policy(vma->vm_policy, nodemap);
+	if (IS_ERR(new))
+		return (PTR_ERR(new));
+
+	return(policy_vma(vma, new));
+}
Index: linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-05-10 11:18:20.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c	2005-05-10 11:18:24.000000000 -0700
@@ -26,6 +26,7 @@
 #include <linux/delay.h>
 #include <linux/blkdev.h>
 #include <linux/nodemask.h>
+#include <linux/mempolicy.h>
 #include <asm/bitops.h>
 
 /*
@@ -798,8 +799,17 @@ sys_migrate_pages(const pid_t pid, const
   	smp_call_function(&lru_add_drain_per_cpu, NULL, 0, 1);
 	lru_add_drain();
 
+	/* update the process mempolicy, if needed */
+	ret = migrate_process_policy(task, node_map);
+	if (ret)
+		goto out_dec;
+
 	/* actually do the migration */
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		/* update the vma mempolicy, if needed */
+		ret = migrate_vma_policy(vma, node_map);
+		if (ret)
+			goto out_dec;
 		/* migrate the pages of this vma */
 		ret = migrate_vma(task, mm, vma, node_map);
 		if (ret >= 0)

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
