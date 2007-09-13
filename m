Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DHxKIB020601
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 13:59:20 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DHxJ64440532
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 11:59:19 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DHxJub001000
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 11:59:19 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 2/5] hugetlb: Move update_and_free_page
Date: Thu, 13 Sep 2007 10:59:17 -0700
Message-Id: <20070913175917.27074.23080.stgit@kernel>
In-Reply-To: <20070913175855.27074.27030.stgit@kernel>
References: <20070913175855.27074.27030.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: libhugetlbfs-devel@lists.sourceforge.net, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

This patch simply moves update_and_free_page() so that it can be reused
later in this patch series.  The implementation is not changed.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 mm/hugetlb.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1dfeafa..50195a2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -90,6 +90,21 @@ static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 	return page;
 }
 
+static void update_and_free_page(struct page *page)
+{
+	int i;
+	nr_huge_pages--;
+	nr_huge_pages_node[page_to_nid(page)]--;
+	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
+		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
+				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
+				1 << PG_private | 1<< PG_writeback);
+	}
+	set_compound_page_dtor(page, NULL);
+	set_page_refcounted(page);
+	__free_pages(page, HUGETLB_PAGE_ORDER);
+}
+
 static void free_huge_page(struct page *page)
 {
 	BUG_ON(page_count(page));
@@ -199,21 +214,6 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 }
 
 #ifdef CONFIG_SYSCTL
-static void update_and_free_page(struct page *page)
-{
-	int i;
-	nr_huge_pages--;
-	nr_huge_pages_node[page_to_nid(page)]--;
-	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
-		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
-				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
-				1 << PG_private | 1<< PG_writeback);
-	}
-	set_compound_page_dtor(page, NULL);
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
