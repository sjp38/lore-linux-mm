Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBD7ijCD012089
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 02:44:45 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBD7h10N307016
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 02:43:01 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBD7h1Ip000711
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 02:43:01 -0500
Date: Wed, 12 Dec 2007 23:42:59 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 2/2] Revert "hugetlb: Add hugetlb_dynamic_pool sysctl"
Message-ID: <20071213074259.GB17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071213074156.GA17526@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: agl@us.ibm.com
Cc: wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Revert "hugetlb: Add hugetlb_dynamic_pool sysctl"

This reverts commit 54f9f80d6543fb7b157d3b11e2e7911dc1379790.

Given the new sysctl nr_overcommit_hugepages, the boolean dynamic pool
sysctl is not needed, as its semantics can be expressed by 0 in the
overcommit sysctl (no dynamic pool) and non-0 in the overcommit sysctl
(pool enabled).

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index f7bc869..30d606a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -33,7 +33,6 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 
 extern unsigned long max_huge_pages;
 extern unsigned long hugepages_treat_as_movable;
-extern int hugetlb_dynamic_pool;
 extern unsigned long nr_overcommit_huge_pages;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index b85a128..1135de7 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -906,14 +906,6 @@ static struct ctl_table vm_table[] = {
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
-		.procname	= "hugetlb_dynamic_pool",
-		.data		= &hugetlb_dynamic_pool,
-		.maxlen		= sizeof(hugetlb_dynamic_pool),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nr_overcommit_hugepages",
 		.data		= &nr_overcommit_huge_pages,
 		.maxlen		= sizeof(nr_overcommit_huge_pages),
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3a79065..7224a4f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -31,7 +31,6 @@ static unsigned int free_huge_pages_node[MAX_NUMNODES];
 static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
-int hugetlb_dynamic_pool;
 unsigned long nr_overcommit_huge_pages;
 static int hugetlb_next_nid;
 
@@ -230,10 +229,6 @@ static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
 	struct page *page;
 	unsigned int nid;
 
-	/* Check if the dynamic pool is enabled */
-	if (!hugetlb_dynamic_pool)
-		return NULL;
-
 	/*
 	 * Assume we will successfully allocate the surplus page to
 	 * prevent racing processes from causing the surplus to exceed
-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
