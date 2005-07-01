Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j620WNpb017094
	for <linux-mm@kvack.org>; Fri, 1 Jul 2005 17:32:23 -0700
Date: Fri, 1 Jul 2005 15:41:10 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050701224110.542.16139.58608@jackhammer.engr.sgi.com>
In-Reply-To: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
References: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.13-rc1 5/11] mm: manual page migration-rc4 -- sys_migrate_pages-mempolicy-migration-rc4.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch adds code that translates the memory policy structures
as they are encountered so that they continue to represent where
memory should be allocated after the page migration has completed.

Signed-off-by: Ray Bryant <raybry@sgi.com>

 include/linux/mempolicy.h |    2 
 mm/mempolicy.c            |  122 +++++++++++++++++++++++++++++++++++++++++++++-
 mm/mmigrate.c             |   14 ++++-
 3 files changed, 135 insertions(+), 3 deletions(-)

Index: linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/mempolicy.h
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/include/linux/mempolicy.h	2005-06-24 10:57:10.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/mempolicy.h	2005-06-27 12:29:06.000000000 -0700
@@ -152,6 +152,8 @@ struct mempolicy *mpol_shared_policy_loo
 
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
+extern int migrate_process_policy(struct task_struct *, int *);
+extern int migrate_vma_policy(struct vm_area_struct *, int *);
 
 #else
 
Index: linux-2.6.12-rc5-mhp1-page-migration-export/mm/mempolicy.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/mm/mempolicy.c	2005-06-24 10:57:10.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/mm/mempolicy.c	2005-06-27 12:28:33.000000000 -0700
@@ -706,7 +706,6 @@ static unsigned offset_il_node(struct me
 		c++;
 	} while (c <= target);
 	BUG_ON(nid >= MAX_NUMNODES);
-	BUG_ON(!test_bit(nid, pol->v.nodes));
 	return nid;
 }
 
@@ -1136,3 +1135,124 @@ void numa_default_policy(void)
 {
 	sys_set_mempolicy(MPOL_DEFAULT, NULL, 0);
 }
+
+/*
+ * update a node mask according to a migration request
+ */
+static void migrate_node_mask(unsigned long *new_node_mask,
+			      unsigned long *old_node_mask,
+			      int  *node_map)
+{
+	int i;
+
+	bitmap_zero(new_node_mask, MAX_NUMNODES);
+
+	i = find_first_bit(old_node_mask, MAX_NUMNODES);
+	while(i < MAX_NUMNODES) {
+		if (node_map[i] >= 0)
+			set_bit(node_map[i], new_node_mask);
+		else
+			set_bit(i, new_node_mask);
+		i = find_next_bit(old_node_mask, MAX_NUMNODES, i+1);
+	}
+}
+
+/*
+ * update a process or vma mempolicy according to a migration request
+ */
+static struct mempolicy *
+migrate_policy(struct mempolicy *old, int *node_map)
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
+		migrate_node_mask(new->v.nodes, old->v.nodes, node_map);
+		break;
+	case MPOL_PREFERRED:
+		if (old->v.preferred_node>=0 &&
+			(node_map[old->v.preferred_node] >= 0))
+			new->v.preferred_node = node_map[old->v.preferred_node];
+		else
+			new->v.preferred_node = old->v.preferred_node;
+		break;
+	case MPOL_BIND:
+		bitmap_zero(old_nodes, MAX_NUMNODES);
+		for (i = 0; (z = old->v.zonelist->zones[i]) != NULL; i++)
+			set_bit(z->zone_pgdat->node_id, old_nodes);
+		migrate_node_mask(new_nodes, old_nodes, node_map);
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
+int migrate_process_policy(struct task_struct *task, int  *node_map)
+{
+	struct mempolicy *new, *old = task->mempolicy;
+	int tmp;
+
+	if ((!old) || (old->policy == MPOL_DEFAULT))
+		return 0;
+
+	new = migrate_policy(task->mempolicy, node_map);
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
+		 * In the worst case, this will allow an allocation of one
+		 * page under the original policy (not the "new" one above).
+		 * Since we update policies according to the migration,
+		 * then migrate pages, that page should still get migrated
+		 * correctly.
+		 */
+		tmp = task->il_next;
+		if (node_map[tmp] >= 0)
+			task->il_next = node_map[tmp];
+	}
+
+	return 0;
+
+}
+
+/*
+ * update a vma mempolicy based on a migration request
+ */
+int migrate_vma_policy(struct vm_area_struct *vma, int *node_map)
+{
+
+	struct mempolicy *new;
+
+	if (!vma->vm_policy || vma->vm_policy->policy == MPOL_DEFAULT)
+		return 0;
+
+	new = migrate_policy(vma->vm_policy, node_map);
+	if (IS_ERR(new))
+		return (PTR_ERR(new));
+
+	return(policy_vma(vma, new));
+}
Index: linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-06-24 11:01:44.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c	2005-06-27 12:26:56.000000000 -0700
@@ -25,6 +25,7 @@
 #include <linux/mmigrate.h>
 #include <linux/delay.h>
 #include <linux/nodemask.h>
+#include <linux/mempolicy.h>
 #include <asm/bitops.h>
 
 /*
@@ -598,13 +599,17 @@ migrate_vma(struct task_struct *task, st
 {
 	struct page *page, *page2;
 	unsigned long vaddr;
-	int count = 0, nr_busy;
+	int rc, count = 0, nr_busy;
 	LIST_HEAD(pglist);
 
 	/* can't migrate mlock()'d pages */
 	if (vma->vm_flags & VM_LOCKED)
 		return 0;
 
+	/* update the vma mempolicy, if needed */
+	rc = migrate_vma_policy(vma, node_map);
+	if (rc < 0)
+		return rc;
 	/*
 	 * gather all of the pages to be migrated from this vma into pglist
 	 */
@@ -735,9 +740,14 @@ sys_migrate_pages(pid_t pid, __u32 count
 		node_map[tmp_old_nodes[i]] = tmp_new_nodes[i];
 
 	/* prepare for lru list manipulation */
-  	smp_call_function(&lru_add_drain_per_cpu, NULL, 0, 1);
+	smp_call_function(&lru_add_drain_per_cpu, NULL, 0, 1);
 	lru_add_drain();
 
+	/* update the process mempolicy, if needed */
+	ret = migrate_process_policy(task, node_map);
+	if (ret < 0)
+		goto out;
+
 	/* actually do the migration */
 	down_read(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {

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
