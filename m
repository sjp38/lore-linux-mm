Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3H1euKB010484
	for <linux-mm@kvack.org>; Wed, 16 Apr 2008 21:40:56 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3H1euGn177494
	for <linux-mm@kvack.org>; Wed, 16 Apr 2008 19:40:56 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3H1etNJ011135
	for <linux-mm@kvack.org>; Wed, 16 Apr 2008 19:40:55 -0600
Date: Wed, 16 Apr 2008 18:40:54 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [UPDATED][PATCH 3/3] Explicitly retry hugepage allocations
Message-ID: <20080417014054.GB17076@us.ibm.com>
References: <20080411233500.GA19078@us.ibm.com> <20080411233553.GB19078@us.ibm.com> <20080411233654.GC19078@us.ibm.com> <20080415085608.GB20316@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080415085608.GB20316@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, clameter@sgi.com, apw@shadowen.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 15.04.2008 [09:56:08 +0100], Mel Gorman wrote:
> On (11/04/08 16:36), Nishanth Aravamudan didst pronounce:
> > Add __GFP_REPEAT to hugepage allocations. Do so to not necessitate
> > userspace putting pressure on the VM by repeated echo's into
> > /proc/sys/vm/nr_hugepages to grow the pool. With the previous patch to
> > allow for large-order __GFP_REPEAT attempts to loop for a bit (as
> > opposed to indefinitely), this increases the likelihood of getting
> > hugepages when the system experiences (or recently experienced) load.
> > 
> > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> I tested the patchset on an x86_32 laptop. With the patches, it was easier to
> use the proc interface to grow the hugepage pool. The following is the output
> of a script that grows the pool as much as possible running on 2.6.25-rc9
> 
> Allocating hugepages test
> -------------------------
> Disabling OOM Killer for current test process
> Starting page count: 0
> Attempt 1: 57 pages Progress made with 57 pages
> Attempt 2: 73 pages Progress made with 16 pages
> Attempt 3: 74 pages Progress made with 1 pages
> Attempt 4: 75 pages Progress made with 1 pages
> Attempt 5: 77 pages Progress made with 2 pages
> 
> 77 pages was the most it allocated but it took 5 attempts from userspace
> to get it. With your 3 patches applied,
> 
> Allocating hugepages test
> -------------------------
> Disabling OOM Killer for current test process
> Starting page count: 0
> Attempt 1: 75 pages Progress made with 75 pages
> Attempt 2: 76 pages Progress made with 1 pages
> Attempt 3: 79 pages Progress made with 3 pages
> 
> And 79 pages was the most it got. Your patches were able to allocate the
> bulk of possible pages on the first attempt.

Add __GFP_REPEAT to hugepage allocations. Do so to not necessitate
userspace putting pressure on the VM by repeated echo's into
/proc/sys/vm/nr_hugepages to grow the pool. With the previous patch to
allow for large-order __GFP_REPEAT attempts to loop for a bit (as
opposed to indefinitely), this increases the likelihood of getting
hugepages when the system experiences (or recently experienced) load.

Mel tested the patchset on an x86_32 laptop. With the patches, it was
easier to use the proc interface to grow the hugepage pool. The
following is the output of a script that grows the pool as much as
possible running on 2.6.25-rc9.

Allocating hugepages test
-------------------------
Disabling OOM Killer for current test process
Starting page count: 0
Attempt 1: 57 pages Progress made with 57 pages
Attempt 2: 73 pages Progress made with 16 pages
Attempt 3: 74 pages Progress made with 1 pages
Attempt 4: 75 pages Progress made with 1 pages
Attempt 5: 77 pages Progress made with 2 pages

77 pages was the most it allocated but it took 5 attempts from userspace
to get it. With the 3 patches in this series applied,

Allocating hugepages test
-------------------------
Disabling OOM Killer for current test process
Starting page count: 0
Attempt 1: 75 pages Progress made with 75 pages
Attempt 2: 76 pages Progress made with 1 pages
Attempt 3: 79 pages Progress made with 3 pages

And 79 pages was the most it got. Your patches were able to allocate the
bulk of possible pages on the first attempt.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Tested-by: Mel Gorman <mel@csn.ul.ie>

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
