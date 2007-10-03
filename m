Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l93LWn5M022576
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 17:32:49 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l93LWmtt688870
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 17:32:49 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l93LWcRR028029
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 17:32:38 -0400
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH] hugetlb: Fix pool resizing corner case V2
Date: Wed, 03 Oct 2007 14:32:27 -0700
Message-Id: <20071003213227.28925.49934.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Ken Chen <kenchen@google.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Changes in V2:
 - Removed now unnecessary check as suggested by Ken Chen

When shrinking the size of the hugetlb pool via the nr_hugepages sysctl, we
are careful to keep enough pages around to satisfy reservations.  But the
calculation is flawed for the following scenario:

Action                          Pool Counters (Total, Free, Resv)
======                          =============
Set pool to 1 page              1 1 0
Map 1 page MAP_PRIVATE          1 1 0
Touch the page to fault it in   1 0 0
Set pool to 3 pages             3 2 0
Map 2 pages MAP_SHARED          3 2 2
Set pool to 2 pages             2 1 2 <-- Mistake, should be 3 2 2
Touch the 2 shared pages        2 0 1 <-- Program crashes here

The last touch above will terminate the process due to lack of huge pages.

This patch corrects the calculation so that it factors in pages being used
for private mappings.  Andrew, this is a standalone fix suitable for
mainline.  It is also now corrected in my latest dynamic pool resizing
patchset which I will send out soon.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Acked-by: Ken Chen <kenchen@google.com>
---

 mm/hugetlb.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 84c795e..b6b3b64 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -224,14 +224,14 @@ static void try_to_free_low(unsigned long count)
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
@@ -247,11 +247,9 @@ static unsigned long set_max_huge_pages(unsigned long count)
 		if (!alloc_fresh_huge_page())
 			return nr_huge_pages;
 	}
-	if (count >= nr_huge_pages)
-		return nr_huge_pages;
 
 	spin_lock(&hugetlb_lock);
-	count = max(count, resv_huge_pages);
+	count = max(count, resv_huge_pages + nr_huge_pages - free_huge_pages);
 	try_to_free_low(count);
 	while (count < nr_huge_pages) {
 		struct page *page = dequeue_huge_page(NULL, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
