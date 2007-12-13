Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBD7fwQ0030006
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 02:41:58 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBD7fwNx126874
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 00:41:58 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBD7fvRY029423
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 00:41:57 -0700
Date: Wed, 12 Dec 2007 23:41:56 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 1/2] hugetlb: introduce nr_overcommit_hugepages sysctl
Message-ID: <20071213074156.GA17526@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: agl@us.ibm.com
Cc: wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

While examining the code to support /proc/sys/vm/hugetlb_dynamic_pool, I
became convinced that having a boolean sysctl was insufficient:

1) To support per-node control of hugepages, I have previously submitted
patches to add a sysfs attribute related to nr_hugepages. However, with
a boolean global value and per-mount quota enforcement constraining the
dynamic pool, adding corresponding control of the dynamic pool on a
per-node basis seems inconsistent to me.

2) Administration of the hugetlb dynamic pool with multiple hugetlbfs
mount points is, arguably, more arduous than it needs to be. Each quota
would need to be set separately, and the sum would need to be monitored.

To ease the administration, and to help make the way for per-node
control of the static & dynamic hugepage pool, I added a separate
sysctl, nr_overcommit_hugepages. This value serves as a high watermark
for the overall hugepage pool, while nr_hugepages serves as a low
watermark. The boolean sysctl can then be removed, as the condition

	nr_overcommit_hugepages > 0

indicates the same administrative setting as

	hugetlb_dynamic_pool == 1

Quotas still serve as local enforcement of the size of the pool on a
per-mount basis.

A few caveats:

1) There is a race whereby the global surplus huge page counter is
incremented before a hugepage has allocated. Another process could then
try grow the pool, and fail to convert a surplus huge page to a normal
huge page and instead allocate a fresh huge page. I believe this is
benign, as no memory is leaked (the actual pages are still tracked
correctly) and the counters won't go out of sync.

2) Shrinking the static pool while a surplus is in effect will allow the
number of surplus huge pages to exceed the overcommit value. As long as
this condition holds, however, no more surplus huge pages will be
allowed on the system until one of the two sysctls are increased
sufficiently, or the surplus huge pages go out of use and are freed.

Successfully tested on x86_64 with the current libhugetlbfs snapshot,
modified to use the new sysctl.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
Andrew, since 2.6.24 would be the first release with the dynamic_pool
sysctl, I think these might deserve consideration for inclusion, even so
late in the cycle? It all depends on how close to an (important?)
user-space visible change removing the sysctl might be in 2.6.25?
Obviously pending comments, acks, nacks from Adam et al.


diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 2496879..f7bc869 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -34,6 +34,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 extern unsigned long max_huge_pages;
 extern unsigned long hugepages_treat_as_movable;
 extern int hugetlb_dynamic_pool;
+extern unsigned long nr_overcommit_huge_pages;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 8ac5171..b85a128 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -912,6 +912,14 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nr_overcommit_hugepages",
+		.data		= &nr_overcommit_huge_pages,
+		.maxlen		= sizeof(nr_overcommit_huge_pages),
+		.mode		= 0644,
+		.proc_handler	= &proc_doulongvec_minmax,
+	},
 #endif
 	{
 		.ctl_name	= VM_LOWMEM_RESERVE_RATIO,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6f97821..3a79065 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -32,6 +32,7 @@ static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 int hugetlb_dynamic_pool;
+unsigned long nr_overcommit_huge_pages;
 static int hugetlb_next_nid;
 
 /*
@@ -227,22 +228,62 @@ static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
 						unsigned long address)
 {
 	struct page *page;
+	unsigned int nid;
 
 	/* Check if the dynamic pool is enabled */
 	if (!hugetlb_dynamic_pool)
 		return NULL;
 
+	/*
+	 * Assume we will successfully allocate the surplus page to
+	 * prevent racing processes from causing the surplus to exceed
+	 * overcommit
+	 *
+	 * This however introduces a different race, where a process B
+	 * tries to grow the static hugepage pool while alloc_pages() is
+	 * called by process A. B will only examine the per-node
+	 * counters in determining if surplus huge pages can be
+	 * converted to normal huge pages in adjust_pool_surplus(). A
+	 * won't be able to increment the per-node counter, until the
+	 * lock is dropped by B, but B doesn't drop hugetlb_lock until
+	 * no more huge pages can be converted from surplus to normal
+	 * state (and doesn't try to convert again). Thus, we have a
+	 * case where a surplus huge page exists, the pool is grown, and
+	 * the surplus huge page still exists after, even though it
+	 * should just have been converted to a normal huge page. This
+	 * does not leak memory, though, as the hugepage will be freed
+	 * once it is out of use. It also does not allow the counters to
+	 * go out of whack in adjust_pool_surplus() as we don't modify
+	 * the node values until we've gotten the hugepage and only the
+	 * per-node value is checked there.
+	 */
+	spin_lock(&hugetlb_lock);
+	if (surplus_huge_pages >= nr_overcommit_huge_pages) {
+		spin_unlock(&hugetlb_lock);
+		return NULL;
+	} else {
+		nr_huge_pages++;
+		surplus_huge_pages++;
+	}
+	spin_unlock(&hugetlb_lock);
+
 	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
 					HUGETLB_PAGE_ORDER);
+
+	spin_lock(&hugetlb_lock);
 	if (page) {
+		nid = page_to_nid(page);
 		set_compound_page_dtor(page, free_huge_page);
-		spin_lock(&hugetlb_lock);
-		nr_huge_pages++;
-		nr_huge_pages_node[page_to_nid(page)]++;
-		surplus_huge_pages++;
-		surplus_huge_pages_node[page_to_nid(page)]++;
-		spin_unlock(&hugetlb_lock);
+		/*
+		 * We incremented the global counters already
+		 */
+		nr_huge_pages_node[nid]++;
+		surplus_huge_pages_node[nid]++;
+	} else {
+		nr_huge_pages--;
+		surplus_huge_pages--;
 	}
+	spin_unlock(&hugetlb_lock);
 
 	return page;
 }
@@ -481,6 +522,12 @@ static unsigned long set_max_huge_pages(unsigned long count)
 	 * Increase the pool size
 	 * First take pages out of surplus state.  Then make up the
 	 * remaining difference by allocating fresh huge pages.
+	 *
+	 * We might race with alloc_buddy_huge_page() here and be unable
+	 * to convert a surplus huge page to a normal huge page. That is
+	 * not critical, though, it just means the overall size of the
+	 * pool might be one hugepage larger than it needs to be, but
+	 * within all the constraints specified by the sysctls.
 	 */
 	spin_lock(&hugetlb_lock);
 	while (surplus_huge_pages && count > persistent_huge_pages) {
@@ -509,6 +556,14 @@ static unsigned long set_max_huge_pages(unsigned long count)
 	 * to keep enough around to satisfy reservations).  Then place
 	 * pages into surplus state as needed so the pool will shrink
 	 * to the desired size as pages become free.
+	 *
+	 * By placing pages into the surplus state independent of the
+	 * overcommit value, we are allowing the surplus pool size to
+	 * exceed overcommit. There are few sane options here. Since
+	 * alloc_buddy_huge_page() is checking the global counter,
+	 * though, we'll note that we're not allowed to exceed surplus
+	 * and won't grow the pool anywhere else. Not until one of the
+	 * sysctls are changed, or the surplus pages go out of use.
 	 */
 	min_count = resv_huge_pages + nr_huge_pages - free_huge_pages;
 	min_count = max(count, min_count);

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
