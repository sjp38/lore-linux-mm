Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l94Ec6I3000547
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 10:38:06 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l94Ec5WA432020
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 08:38:05 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l94Ec5Xf022738
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 08:38:05 -0600
Subject: [PATCH] hugetlb: Update -mm patches to fix pool resizing
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Thu, 04 Oct 2007 09:38:04 -0500
Message-Id: <1191508684.19775.51.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew.  Here is a port of my explicit resizing corner-case fix that will
apply on top of the dynamic pool resizing patches now in -mm.  Thanks.

Signed-off-by: Adam Litke <agl@us.ibm.com>

>From the original mainline patch notes...
> Changes in V2:
>  - Removed now unnecessary check as suggested by Ken Chen
>
> When shrinking the size of the hugetlb pool via the nr_hugepages sysctl, we
> are careful to keep enough pages around to satisfy reservations.  But the
> calculation is flawed for the following scenario:
>
> Action                          Pool Counters (Total, Free, Resv)
> ======                          =============
> Set pool to 1 page              1 1 0
> Map 1 page MAP_PRIVATE          1 1 0
> Touch the page to fault it in   1 0 0
> Set pool to 3 pages             3 2 0
> Map 2 pages MAP_SHARED          3 2 2
> Set pool to 2 pages             2 1 2 <-- Mistake, should be 3 2 2
> Touch the 2 shared pages        2 0 1 <-- Program crashes here
>
> The last touch above will terminate the process due to lack of huge pages.
>
> This patch corrects the calculation so that it factors in pages being used
> for private mappings.  Andrew, this is a standalone fix suitable for
> mainline.  It is also now corrected in my latest dynamic pool resizing
> patchset which I will send out soon.
>
> Signed-off-by: Adam Litke <agl@us.ibm.com>
> Acked-by: Ken Chen <kenchen@google.com>

---

 hugetlb.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index dabe3d6..9bec60d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -297,14 +297,14 @@ static void try_to_free_low(unsigned long count)
 	for (i = 0; i < MAX_NUMNODES; ++i) {
 		struct page *page, *next;
 		list_for_each_entry_safe(page, next, &hugepage_freelists[i], lru) {
+			if (count >= nr_huge_pages)
+				return;
 			if (PageHighMem(page))
 				continue;
 			list_del(&page->lru);
 			update_and_free_page(page);
 			free_huge_pages--;
 			free_huge_pages_node[page_to_nid(page)]--;
-			if (count >= nr_huge_pages)
-				return;
 		}
 	}
 }
@@ -344,8 +344,6 @@ static unsigned long set_max_huge_pages(unsigned long count)
 			goto out;
 
 	}
-	if (count >= persistent_huge_pages)
-		goto out;
 
 	/*
 	 * Decrease the pool size
@@ -354,7 +352,8 @@ static unsigned long set_max_huge_pages(unsigned long count)
 	 * pages into surplus state as needed so the pool will shrink
 	 * to the desired size as pages become free.
 	 */
-	min_count = max(count, resv_huge_pages);
+	min_count = resv_huge_pages + nr_huge_pages - free_huge_pages;
+	min_count = max(count, min_count);
 	try_to_free_low(min_count);
 	while (min_count < persistent_huge_pages) {
 		struct page *page = dequeue_huge_page(NULL, 0);

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
