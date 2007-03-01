From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301100902.30048.94291.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070301100802.30048.45045.sendpatchset@skynet.skynet.ie>
References: <20070301100802.30048.45045.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/8] Allow huge page allocations to use GFP_HIGH_MOVABLE
Date: Thu,  1 Mar 2007 10:09:02 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Huge pages are not movable so are not allocated from ZONE_MOVABLE. However,
as ZONE_MOVABLE will always have pages that can be migrated or reclaimed,
it can be used to satisfy hugepage allocations even when the system has been
running a long time. This allows an administrator to resize the hugepage
pool at runtime depending on the size of ZONE_MOVABLE.

This patch adds a new sysctl called hugepages_treat_as_movable. When
a non-zero value is written to it, future allocations for the huge page
pool will use ZONE_MOVABLE. Despite huge pages being non-movable, we do not
introduce additional external fragmentation of note as huge pages are always
the largest contiguous block we care about.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 include/linux/hugetlb.h   |    3 +++
 include/linux/mempolicy.h |    6 +++---
 include/linux/sysctl.h    |    1 +
 kernel/sysctl.c           |    8 ++++++++
 mm/hugetlb.c              |   23 ++++++++++++++++++++---
 mm/mempolicy.c            |    5 +++--
 6 files changed, 38 insertions(+), 8 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-002_create_movable_zone/include/linux/hugetlb.h linux-2.6.20-mm2-003_mark_hugepages_movable/include/linux/hugetlb.h
--- linux-2.6.20-mm2-002_create_movable_zone/include/linux/hugetlb.h	2007-02-04 18:44:54.000000000 +0000
+++ linux-2.6.20-mm2-003_mark_hugepages_movable/include/linux/hugetlb.h	2007-02-19 09:13:13.000000000 +0000
@@ -14,6 +14,7 @@ static inline int is_vm_hugetlb_page(str
 }
 
 int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
+int hugetlb_treat_movable_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int);
 void unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
@@ -28,6 +29,8 @@ int hugetlb_reserve_pages(struct inode *
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 
 extern unsigned long max_huge_pages;
+extern unsigned long hugepages_treat_as_movable;
+extern gfp_t htlb_alloc_mask;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-002_create_movable_zone/include/linux/mempolicy.h linux-2.6.20-mm2-003_mark_hugepages_movable/include/linux/mempolicy.h
--- linux-2.6.20-mm2-002_create_movable_zone/include/linux/mempolicy.h	2007-02-04 18:44:54.000000000 +0000
+++ linux-2.6.20-mm2-003_mark_hugepages_movable/include/linux/mempolicy.h	2007-02-19 09:13:13.000000000 +0000
@@ -159,7 +159,7 @@ extern void mpol_fix_fork_child_flag(str
 
 extern struct mempolicy default_policy;
 extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
-		unsigned long addr);
+		unsigned long addr, gfp_t gfp_flags);
 extern unsigned slab_node(struct mempolicy *policy);
 
 extern enum zone_type policy_zone;
@@ -256,9 +256,9 @@ static inline void mpol_fix_fork_child_f
 #define set_cpuset_being_rebound(x) do {} while (0)
 
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
-		unsigned long addr)
+		unsigned long addr, gfp_t gfp_flags)
 {
-	return NODE_DATA(0)->node_zonelists + gfp_zone(GFP_HIGHUSER);
+	return NODE_DATA(0)->node_zonelists + gfp_zone(gfp_flags);
 }
 
 static inline int do_migrate_pages(struct mm_struct *mm,
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-002_create_movable_zone/include/linux/sysctl.h linux-2.6.20-mm2-003_mark_hugepages_movable/include/linux/sysctl.h
--- linux-2.6.20-mm2-002_create_movable_zone/include/linux/sysctl.h	2007-02-19 01:22:32.000000000 +0000
+++ linux-2.6.20-mm2-003_mark_hugepages_movable/include/linux/sysctl.h	2007-02-19 09:13:13.000000000 +0000
@@ -207,6 +207,7 @@ enum
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
+	VM_HUGETLB_TREAT_MOVABLE=36, /* Allocate hugepages from ZONE_MOVABLE */
 
 	/* s390 vm cmm sysctls */
 	VM_CMM_PAGES=1111,
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-002_create_movable_zone/kernel/sysctl.c linux-2.6.20-mm2-003_mark_hugepages_movable/kernel/sysctl.c
--- linux-2.6.20-mm2-002_create_movable_zone/kernel/sysctl.c	2007-02-19 01:22:34.000000000 +0000
+++ linux-2.6.20-mm2-003_mark_hugepages_movable/kernel/sysctl.c	2007-02-19 09:13:13.000000000 +0000
@@ -737,6 +737,14 @@ static ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	 },
+	 {
+		.ctl_name	= VM_HUGETLB_TREAT_MOVABLE,
+		.procname	= "hugepages_treat_as_movable",
+		.data		= &hugepages_treat_as_movable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &hugetlb_treat_movable_handler,
+	},
 #endif
 	{
 		.ctl_name	= VM_LOWMEM_RESERVE_RATIO,
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-002_create_movable_zone/mm/hugetlb.c linux-2.6.20-mm2-003_mark_hugepages_movable/mm/hugetlb.c
--- linux-2.6.20-mm2-002_create_movable_zone/mm/hugetlb.c	2007-02-19 01:22:35.000000000 +0000
+++ linux-2.6.20-mm2-003_mark_hugepages_movable/mm/hugetlb.c	2007-02-19 09:13:13.000000000 +0000
@@ -27,6 +27,9 @@ unsigned long max_huge_pages;
 static struct list_head hugepage_freelists[MAX_NUMNODES];
 static unsigned int nr_huge_pages_node[MAX_NUMNODES];
 static unsigned int free_huge_pages_node[MAX_NUMNODES];
+gfp_t htlb_alloc_mask = GFP_HIGHUSER;
+unsigned long hugepages_treat_as_movable;
+
 /*
  * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
  */
@@ -68,12 +71,13 @@ static struct page *dequeue_huge_page(st
 {
 	int nid = numa_node_id();
 	struct page *page = NULL;
-	struct zonelist *zonelist = huge_zonelist(vma, address);
+	struct zonelist *zonelist = huge_zonelist(vma, address,
+						htlb_alloc_mask);
 	struct zone **z;
 
 	for (z = zonelist->zones; *z; z++) {
 		nid = zone_to_nid(*z);
-		if (cpuset_zone_allowed_softwall(*z, GFP_HIGHUSER) &&
+		if (cpuset_zone_allowed_softwall(*z, htlb_alloc_mask) &&
 		    !list_empty(&hugepage_freelists[nid]))
 			break;
 	}
@@ -103,7 +107,7 @@ static int alloc_fresh_huge_page(void)
 {
 	static int nid = 0;
 	struct page *page;
-	page = alloc_pages_node(nid, GFP_HIGHUSER|__GFP_COMP|__GFP_NOWARN,
+	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
 					HUGETLB_PAGE_ORDER);
 	nid = next_node(nid, node_online_map);
 	if (nid == MAX_NUMNODES)
@@ -243,6 +247,19 @@ int hugetlb_sysctl_handler(struct ctl_ta
 	max_huge_pages = set_max_huge_pages(max_huge_pages);
 	return 0;
 }
+
+int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
+			struct file *file, void __user *buffer,
+			size_t *length, loff_t *ppos)
+{
+	proc_dointvec(table, write, file, buffer, length, ppos);
+	if (hugepages_treat_as_movable)
+		htlb_alloc_mask = GFP_HIGH_MOVABLE;
+	else
+		htlb_alloc_mask = GFP_HIGHUSER;
+	return 0;
+}
+
 #endif /* CONFIG_SYSCTL */
 
 int hugetlb_report_meminfo(char *buf)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-002_create_movable_zone/mm/mempolicy.c linux-2.6.20-mm2-003_mark_hugepages_movable/mm/mempolicy.c
--- linux-2.6.20-mm2-002_create_movable_zone/mm/mempolicy.c	2007-02-19 09:08:29.000000000 +0000
+++ linux-2.6.20-mm2-003_mark_hugepages_movable/mm/mempolicy.c	2007-02-19 09:13:13.000000000 +0000
@@ -1211,7 +1211,8 @@ static inline unsigned interleave_nid(st
 
 #ifdef CONFIG_HUGETLBFS
 /* Return a zonelist suitable for a huge page allocation. */
-struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr)
+struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
+							gfp_t gfp_flags)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 
@@ -1219,7 +1220,7 @@ struct zonelist *huge_zonelist(struct vm
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
-		return NODE_DATA(nid)->node_zonelists + gfp_zone(GFP_HIGHUSER);
+		return NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_flags);
 	}
 	return zonelist_policy(GFP_HIGHUSER, pol);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
