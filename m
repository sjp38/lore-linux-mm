Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6DFHMCM004068
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 11:17:22 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6DFHKCL184470
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 09:17:20 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6DFHJvk002279
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 09:17:20 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
Date: Fri, 13 Jul 2007 08:17:17 -0700
Message-Id: <20070713151717.17750.44865.stgit@kernel>
In-Reply-To: <20070713151621.17750.58171.stgit@kernel>
References: <20070713151621.17750.58171.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, Ken Chen <kenchen@google.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Allow the hugetlb pool to grow dynamically for shared mappings as well.
Due to strict reservations, this is a bit more complex than the private
case.  We must grow the pool at mmap time so we can create a reservation.
The algorithm works as follows:

1) Determine and allocate the full hugetlb page shortage
2) If allocations fail, goto step 5
3) Take the hugetlb_lock and make sure we still have the right number.  If
   not, go back to step 1.
4) Add surplus pages to the hugetlb pool and mark them reserved
5) Free the rest of the surplus pages

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 mm/hugetlb.c |   82 +++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 78 insertions(+), 4 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f03db67..82cd935 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -198,6 +198,70 @@ static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
 	return page;
 }
 
+/*
+ * Increase the hugetlb pool such that it can accomodate a reservation
+ * of size 'delta'.
+ */
+static int gather_surplus_pages(int delta)
+{
+	struct list_head surplus_list;
+	struct page *page, *tmp;
+	int ret, i, needed, allocated;
+
+	/* Try and allocate all of the pages first */
+	needed = delta - free_huge_pages + resv_huge_pages;
+	allocated = 0;
+	INIT_LIST_HEAD(&surplus_list);
+
+	ret = -ENOMEM;
+retry:
+	spin_unlock(&hugetlb_lock);
+	for (i = 0; i < needed; i++) {
+		page = alloc_buddy_huge_page(NULL, 0);
+		if (!page) {
+			spin_lock(&hugetlb_lock);
+			needed = 0;
+			goto free;
+		}
+
+		list_add(&page->lru, &surplus_list);
+	}
+	allocated += needed;
+
+	/*
+	 * After retaking hugetlb_lock, we may find that some of the
+	 * free_huge_pages we were planning on using are no longer free.
+	 * In this case we need to allocate some additional pages.
+	 */
+	spin_lock(&hugetlb_lock);
+	needed = delta - free_huge_pages + resv_huge_pages - allocated;
+	if (needed > 0)
+		goto retry;
+
+	/*
+	 * Dispense the pages on the surplus list by adding them to the pool
+	 * or by freeing them back to the allocator.
+	 * We will have extra pages to free in one of two cases:
+	 * 1) We were not able to allocate enough pages to satisfy the entire
+	 *    reservation so we free all allocated pages.
+	 * 2) While we were allocating some surplus pages with the hugetlb_lock
+	 *    unlocked, some pool pages were freed.  Use those instead and
+	 *    free the surplus pages we allocated.
+	 */
+	needed += allocated;
+	ret = 0;
+free:
+	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
+		list_del(&page->lru);
+		if ((--needed) >= 0)
+			enqueue_huge_page(page);
+		else
+			update_and_free_page(page);
+	}
+
+	return ret;
+}
+
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
 				    unsigned long addr)
 {
@@ -893,13 +957,16 @@ static long region_truncate(struct list_head *head, long end)
 
 static int hugetlb_acct_memory(long delta)
 {
-	int ret = -ENOMEM;
+	int ret = 0;
 
 	spin_lock(&hugetlb_lock);
-	if ((delta + resv_huge_pages) <= free_huge_pages) {
+
+	if (((delta + resv_huge_pages) > free_huge_pages) &&
+			gather_surplus_pages(delta))
+		ret = -ENOMEM;
+	else
 		resv_huge_pages += delta;
-		ret = 0;
-	}
+
 	spin_unlock(&hugetlb_lock);
 	return ret;
 }
@@ -928,8 +995,15 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to)
 	 * a best attempt and hopefully to minimize the impact of changing
 	 * semantics that cpuset has.
 	 */
+	/*
+	 * I haven't figured out how to incorporate this cpuset bodge into
+	 * the dynamic hugetlb pool yet.  Hopefully someone more familiar with
+	 * cpusets can weigh in on their desired semantics.  Maybe we can just
+	 * drop this check?
+	 *
 	if (chg > cpuset_mems_nr(free_huge_pages_node))
 		return -ENOMEM;
+	 */
 
 	ret = hugetlb_acct_memory(chg);
 	if (ret < 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
