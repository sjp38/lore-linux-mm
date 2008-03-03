Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m23I6lNV019134
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 13:06:47 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m23I6kHO187128
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 11:06:47 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m23I6k7i009193
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 11:06:46 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 2/3] hugetlb: Close a difficult to trigger reservation race
Date: Mon, 03 Mar 2008 10:06:44 -0800
Message-Id: <20080303180644.5383.97580.stgit@kernel>
In-Reply-To: <20080303180622.5383.20868.stgit@kernel>
References: <20080303180622.5383.20868.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

A hugetlb reservation may be inadequately backed in the event of racing
allocations and frees when utilizing surplus huge pages.  Consider the
following series of events in processes A and B:

 A) Allocates some surplus pages to satisfy a reservation
 B) Frees some huge pages
 A) A notices the extra free pages and drops hugetlb_lock to free some of
    its surplus pages back to the buddy allocator.
 B) Allocates some huge pages
 A) Reacquires hugetlb_lock and returns from gather_surplus_huge_pages()

Avoid this by commiting the reservation after pages have been allocated but
before dropping the lock to free excess pages.  For parity, release the
reservation in return_unused_surplus_pages().

This patch also corrects the cpuset_mems_nr() error path in
hugetlb_acct_memory().  If the cpuset check fails, uncommit the
reservation, but also be sure to return any surplus huge pages that may
have been allocated to back the failed reservation.

Thanks to Andy Whitcroft for discovering this.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Andy Whitcroft <apw@shadowen.org>
---

 mm/hugetlb.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 819d6d9..f6ce740 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -301,8 +301,10 @@ static int gather_surplus_pages(int delta)
 	int needed, allocated;
 
 	needed = (resv_huge_pages + delta) - free_huge_pages;
-	if (needed <= 0)
+	if (needed <= 0) {
+		resv_huge_pages += delta;
 		return 0;
+	}
 
 	allocated = 0;
 	INIT_LIST_HEAD(&surplus_list);
@@ -340,9 +342,12 @@ retry:
 	 * The surplus_list now contains _at_least_ the number of extra pages
 	 * needed to accomodate the reservation.  Add the appropriate number
 	 * of pages to the hugetlb pool and free the extras back to the buddy
-	 * allocator.
+	 * allocator.  Commit the entire reservation here to prevent another
+	 * process from stealing the pages as they are added to the pool but
+	 * before they are reserved.
 	 */
 	needed += allocated;
+	resv_huge_pages += delta;
 	ret = 0;
 free:
 	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
@@ -377,6 +382,9 @@ static void return_unused_surplus_pages(unsigned long unused_resv_pages)
 	struct page *page;
 	unsigned long nr_pages;
 
+	/* Uncommit the reservation */
+	resv_huge_pages -= unused_resv_pages;
+
 	nr_pages = min(unused_resv_pages, surplus_huge_pages);
 
 	while (nr_pages) {
@@ -1198,12 +1206,13 @@ static int hugetlb_acct_memory(long delta)
 		if (gather_surplus_pages(delta) < 0)
 			goto out;
 
-		if (delta > cpuset_mems_nr(free_huge_pages_node))
+		if (delta > cpuset_mems_nr(free_huge_pages_node)) {
+			return_unused_surplus_pages(delta);
 			goto out;
+		}
 	}
 
 	ret = 0;
-	resv_huge_pages += delta;
 	if (delta < 0)
 		return_unused_surplus_pages((unsigned long) -delta);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
