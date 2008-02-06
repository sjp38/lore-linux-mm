Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m16NCiDg016886
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:12:45 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m16NCi4c207224
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 16:12:44 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m16NCixc005721
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 16:12:44 -0700
Date: Wed, 6 Feb 2008 15:12:43 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 2/2] Explicitly retry hugepage allocations
Message-ID: <20080206231243.GG3477@us.ibm.com>
References: <20080206230726.GF3477@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080206230726.GF3477@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: melgor@ie.ibm.com
Cc: apw@shadowen.org, clameter@sgi.com, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add __GFP_REPEAT to hugepage allocations. Do so to not necessitate
userspace putting pressure on the VM by repeated echo's into
/proc/sys/vm/nr_hugepages to grow the pool. With the previous patch to
allow for large-order __GFP_REPEAT attempts to loop for a bit (as
opposed to indefinitely), this increases the likelihood of getting
hugepages when the system experiences (or recently experienced) load.

On a 2-way x86_64, this doubles the number of hugepages (from 10 to 20)
obtained while compiling a kernel at the same time. On a 4-way ppc64,
a similar scale increase is seen (from 3 to 5 hugepages). Finally, on a
2-way x86, this leads to a 5-fold increase in the hugepages allocatable
under load (90 to 554).

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1a56420..0358a91 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -176,7 +176,8 @@ static struct page *alloc_fresh_huge_page_node(int nid)
 	struct page *page;
 
 	page = alloc_pages_node(nid,
-		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
+		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
+						__GFP_REPEAT|__GFP_NOWARN,
 		HUGETLB_PAGE_ORDER);
 	if (page) {
 		set_compound_page_dtor(page, free_huge_page);
@@ -262,7 +263,8 @@ static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
 	}
 	spin_unlock(&hugetlb_lock);
 
-	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
+	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
+					__GFP_REPEAT|__GFP_NOWARN,
 					HUGETLB_PAGE_ORDER);
 
 	spin_lock(&hugetlb_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
