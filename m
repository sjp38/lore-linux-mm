Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id E8E0F6B0010
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 14:42:49 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 9/9] remove /proc/sys/vm/hugepages_treat_as_movable
Date: Thu, 21 Feb 2013 14:41:48 -0500
Message-Id: <1361475708-25991-10-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

Now hugepages are definitely movable. So allocating hugepages from
ZONE_MOVABLE is natural and we have no reason to keep this parameter.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 Documentation/sysctl/vm.txt | 16 ----------------
 include/linux/hugetlb.h     |  2 --
 kernel/sysctl.c             |  7 -------
 mm/hugetlb.c                | 23 +++++------------------
 4 files changed, 5 insertions(+), 43 deletions(-)

diff --git v3.8.orig/Documentation/sysctl/vm.txt v3.8/Documentation/sysctl/vm.txt
index 078701f..997350a 100644
--- v3.8.orig/Documentation/sysctl/vm.txt
+++ v3.8/Documentation/sysctl/vm.txt
@@ -167,22 +167,6 @@ fragmentation index is <= extfrag_threshold. The default value is 500.
 
 ==============================================================
 
-hugepages_treat_as_movable
-
-This parameter is only useful when kernelcore= is specified at boot time to
-create ZONE_MOVABLE for pages that may be reclaimed or migrated. Huge pages
-are not movable so are not normally allocated from ZONE_MOVABLE. A non-zero
-value written to hugepages_treat_as_movable allows huge pages to be allocated
-from ZONE_MOVABLE.
-
-Once enabled, the ZONE_MOVABLE is treated as an area of memory the huge
-pages pool can easily grow or shrink within. Assuming that applications are
-not running that mlock() a lot of memory, it is likely the huge pages pool
-can grow to the size of ZONE_MOVABLE by repeatedly entering the desired value
-into nr_hugepages and triggering page reclaim.
-
-==============================================================
-
 hugetlb_shm_group
 
 hugetlb_shm_group contains group id that is allowed to create SysV
diff --git v3.8.orig/include/linux/hugetlb.h v3.8/include/linux/hugetlb.h
index e33f07f..c97e5c5 100644
--- v3.8.orig/include/linux/hugetlb.h
+++ v3.8/include/linux/hugetlb.h
@@ -35,7 +35,6 @@ int PageHuge(struct page *page);
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
-int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 
 #ifdef CONFIG_NUMA
 int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
@@ -73,7 +72,6 @@ void migrate_hugepage_add(struct page *page, struct list_head *list);
 int is_hugepage_movable(struct page *page);
 void copy_huge_page(struct page *dst, struct page *src);
 
-extern unsigned long hugepages_treat_as_movable;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
 extern struct list_head huge_boot_pages;
diff --git v3.8.orig/kernel/sysctl.c v3.8/kernel/sysctl.c
index c88878d..a98bcf2 100644
--- v3.8.orig/kernel/sysctl.c
+++ v3.8/kernel/sysctl.c
@@ -1189,13 +1189,6 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	 },
-	 {
-		.procname	= "hugepages_treat_as_movable",
-		.data		= &hugepages_treat_as_movable,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= hugetlb_treat_movable_handler,
-	},
 	{
 		.procname	= "nr_overcommit_hugepages",
 		.data		= NULL,
diff --git v3.8.orig/mm/hugetlb.c v3.8/mm/hugetlb.c
index c28e6c9..c60d203 100644
--- v3.8.orig/mm/hugetlb.c
+++ v3.8/mm/hugetlb.c
@@ -33,7 +33,6 @@
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
-static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
 int hugetlb_max_hstate __read_mostly;
@@ -542,7 +541,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 retry_cpuset:
 	cpuset_mems_cookie = get_mems_allowed();
 	zonelist = huge_zonelist(vma, address,
-					htlb_alloc_mask, &mpol, &nodemask);
+					GFP_HIGHUSER_MOVABLE, &mpol, &nodemask);
 	/*
 	 * A child process with MAP_PRIVATE mappings created by their parent
 	 * have no page reserves. This check ensures that reservations are
@@ -558,7 +557,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
-		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
+		if (cpuset_zone_allowed_softwall(zone, GFP_HIGHUSER_MOVABLE)) {
 			page = dequeue_huge_page_node(h, zone_to_nid(zone));
 			if (page) {
 				if (!avoid_reserve)
@@ -698,7 +697,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 		return NULL;
 
 	page = alloc_pages_exact_node(nid,
-		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
+		GFP_HIGHUSER_MOVABLE|__GFP_COMP|__GFP_THISNODE|
 						__GFP_REPEAT|__GFP_NOWARN,
 		huge_page_order(h));
 	if (page) {
@@ -909,12 +908,12 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 	spin_unlock(&hugetlb_lock);
 
 	if (nid == NUMA_NO_NODE)
-		page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
+		page = alloc_pages(GFP_HIGHUSER_MOVABLE|__GFP_COMP|
 				   __GFP_REPEAT|__GFP_NOWARN,
 				   huge_page_order(h));
 	else
 		page = alloc_pages_exact_node(nid,
-			htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
+			GFP_HIGHUSER_MOVABLE|__GFP_COMP|__GFP_THISNODE|
 			__GFP_REPEAT|__GFP_NOWARN, huge_page_order(h));
 
 	if (page && arch_prepare_hugepage(page)) {
@@ -2078,18 +2077,6 @@ int hugetlb_mempolicy_sysctl_handler(struct ctl_table *table, int write,
 }
 #endif /* CONFIG_NUMA */
 
-int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
-			void __user *buffer,
-			size_t *length, loff_t *ppos)
-{
-	proc_dointvec(table, write, buffer, length, ppos);
-	if (hugepages_treat_as_movable)
-		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
-	else
-		htlb_alloc_mask = GFP_HIGHUSER;
-	return 0;
-}
-
 int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 			void __user *buffer,
 			size_t *length, loff_t *ppos)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
