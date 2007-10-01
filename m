Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l91FHobY001258
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 11:17:50 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l91FHnn4495554
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 09:17:49 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l91FHn2x008061
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 09:17:49 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 1/4] hugetlb: Move update_and_free_page
Date: Mon, 01 Oct 2007 08:17:47 -0700
Message-Id: <20071001151747.12825.92956.stgit@kernel>
In-Reply-To: <20071001151736.12825.75984.stgit@kernel>
References: <20071001151736.12825.75984.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

This patch simply moves update_and_free_page() so that it can be reused
later in this patch series.  The implementation is not changed.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Acked-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Dave McCracken <dave.mccracken@oracle.com>
---

 mm/hugetlb.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4a374fa..8d3919d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -92,6 +92,21 @@ static struct page *dequeue_huge_page(struct vm_area_struct *vma,
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
@@ -201,21 +216,6 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
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
