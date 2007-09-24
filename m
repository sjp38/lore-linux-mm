Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8OFlPko005052
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 11:47:25 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8OFlP4I499302
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 09:47:25 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8OFlPUn028578
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 09:47:25 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 4/4] hugetlb: Add hugetlb_dynamic_pool sysctl
Date: Mon, 24 Sep 2007 08:47:23 -0700
Message-Id: <20070924154722.7565.7556.stgit@kernel>
In-Reply-To: <20070924154638.7565.86666.stgit@kernel>
References: <20070924154638.7565.86666.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: libhugetlbfs-devel@lists.sourceforge.net, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

The maximum size of the huge page pool can be controlled using the overall
size of the hugetlb filesystem (via its 'size' mount option).  However in
the common case the this will not be set as the pool is traditionally fixed
in size at boot time.  In order to maintain the expected semantics, we need
to prevent the pool expanding by default.

This patch introduces a new sysctl controlling dynamic pool resizing.  When
this is enabled the pool will expand beyond its base size up to the size of
the hugetlb filesystem.  It is disabled by default.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Acked-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Dave McCracken <dave.mccracken@oracle.com>
---

 include/linux/hugetlb.h |    1 +
 kernel/sysctl.c         |    8 ++++++++
 mm/hugetlb.c            |    5 +++++
 3 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 3a19b03..ea0f50b 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -33,6 +33,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 
 extern unsigned long max_huge_pages;
 extern unsigned long hugepages_treat_as_movable;
+extern int hugetlb_dynamic_pool;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6ace893..45e8045 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -889,6 +889,14 @@ static ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &hugetlb_treat_movable_handler,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "hugetlb_dynamic_pool",
+		.data		= &hugetlb_dynamic_pool,
+		.maxlen		= sizeof(hugetlb_dynamic_pool),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 #endif
 	{
 		.ctl_name	= VM_LOWMEM_RESERVE_RATIO,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ea77cb8..8e9ea65 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -31,6 +31,7 @@ static unsigned int free_huge_pages_node[MAX_NUMNODES];
 static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
+int hugetlb_dynamic_pool;
 
 /*
  * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
@@ -194,6 +195,10 @@ static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
 {
 	struct page *page;
 
+	/* Check if the dynamic pool is enabled */
+	if (!hugetlb_dynamic_pool)
+		return NULL;
+
 	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
 					HUGETLB_PAGE_ORDER);
 	if (page) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
