Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6DFGvMd003050
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 11:16:57 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6DFGvpn251554
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 09:16:57 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6DFGuRb018788
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 09:16:57 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 3/5] [hugetlb] Move update_and_free_page so it can be used by alloc functions
Date: Fri, 13 Jul 2007 08:16:54 -0700
Message-Id: <20070713151654.17750.21545.stgit@kernel>
In-Reply-To: <20070713151621.17750.58171.stgit@kernel>
References: <20070713151621.17750.58171.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, Ken Chen <kenchen@google.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 mm/hugetlb.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d1ca501..a754c20 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -88,6 +88,21 @@ static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 	return page;
 }
 
+static void update_and_free_page(struct page *page)
+{
+	int i;
+	nr_huge_pages--;
+	nr_huge_pages_node[page_to_nid(page)]--;
+	for (i = 0; i < BASE_PAGES_PER_HPAGE; i++) {
+		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
+				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
+				1 << PG_private | 1<< PG_writeback);
+	}
+	page[1].lru.next = NULL;
+	set_page_refcounted(page);
+	__free_pages(page, HUGETLB_PAGE_ORDER);
+}
+
 static void free_huge_page(struct page *page)
 {
 	BUG_ON(page_count(page));
@@ -186,21 +201,6 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 }
 
 #ifdef CONFIG_SYSCTL
-static void update_and_free_page(struct page *page)
-{
-	int i;
-	nr_huge_pages--;
-	nr_huge_pages_node[page_to_nid(page)]--;
-	for (i = 0; i < BASE_PAGES_PER_HPAGE; i++) {
-		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
-				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
-				1 << PG_private | 1<< PG_writeback);
-	}
-	page[1].lru.next = NULL;
-	set_page_refcounted(page);
-	__free_pages(page, HUGETLB_PAGE_ORDER);
-}
-
 #ifdef CONFIG_HIGHMEM
 static void try_to_free_low(unsigned long count)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
