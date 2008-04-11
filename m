Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3BNaljt016137
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 19:36:47 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3BNalh0114796
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:36:47 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3BNalCS031267
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:36:47 -0600
Date: Fri, 11 Apr 2008 16:36:54 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 3/3] Explicitly retry hugepage allocations
Message-ID: <20080411233654.GC19078@us.ibm.com>
References: <20080411233500.GA19078@us.ibm.com> <20080411233553.GB19078@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080411233553.GB19078@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, clameter@sgi.com, apw@shadowen.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add __GFP_REPEAT to hugepage allocations. Do so to not necessitate
userspace putting pressure on the VM by repeated echo's into
/proc/sys/vm/nr_hugepages to grow the pool. With the previous patch to
allow for large-order __GFP_REPEAT attempts to loop for a bit (as
opposed to indefinitely), this increases the likelihood of getting
hugepages when the system experiences (or recently experienced) load.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index df28c17..e13a7b2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -199,7 +199,8 @@ static struct page *alloc_fresh_huge_page_node(int nid)
 	struct page *page;
 
 	page = alloc_pages_node(nid,
-		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
+		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
+						__GFP_REPEAT|__GFP_NOWARN,
 		HUGETLB_PAGE_ORDER);
 	if (page) {
 		if (arch_prepare_hugepage(page)) {
@@ -294,7 +295,8 @@ static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
 	}
 	spin_unlock(&hugetlb_lock);
 
-	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
+	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
+					__GFP_REPEAT|__GFP_NOWARN,
 					HUGETLB_PAGE_ORDER);
 
 	spin_lock(&hugetlb_lock);

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
