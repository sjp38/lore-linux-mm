Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 5F6456B003C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 05:09:34 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 14:34:39 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 4B7BF3940057
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 14:39:24 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3499KPO4981102
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 14:39:21 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3499Mab017005
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 09:09:23 GMT
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 2/6] mm/hugetlb: update_and_free_page gigantic pages awareness
Date: Thu,  4 Apr 2013 17:09:10 +0800
Message-Id: <1365066554-29195-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

order >= MAX_ORDER pages can't be freed to buddy system directly, this patch
destroy the gigantic hugetlb page to normal order-0 pages and free them one
by one.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/hugetlb.c    |   39 +++++++++++++++++++++++++++++----------
 mm/internal.h   |    1 +
 mm/page_alloc.c |    2 +-
 3 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4a0c270..eeaf6f2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -579,25 +579,44 @@ err:
 	return NULL;
 }
 
+static inline clear_page_flag(struct page *page)
+{
+	page->flags &= ~(1 << PG_locked | 1 << PG_error |
+		1 << PG_referenced | 1 << PG_dirty |
+		1 << PG_active | 1 << PG_reserved |
+		1 << PG_private | 1 << PG_writeback);
+}
+
 static void update_and_free_page(struct hstate *h, struct page *page)
 {
 	int i;
+	struct page *p;
+	int order = huge_page_order(h);
 
-	VM_BUG_ON(h->order >= MAX_ORDER);
+	VM_BUG_ON(!hugetlb_shrink_gigantic_pool && h->order >= MAX_ORDER);
 
 	h->nr_huge_pages--;
 	h->nr_huge_pages_node[page_to_nid(page)]--;
-	for (i = 0; i < pages_per_huge_page(h); i++) {
-		page[i].flags &= ~(1 << PG_locked | 1 << PG_error |
-				1 << PG_referenced | 1 << PG_dirty |
-				1 << PG_active | 1 << PG_reserved |
-				1 << PG_private | 1 << PG_writeback);
-	}
-	VM_BUG_ON(hugetlb_cgroup_from_page(page));
 	set_compound_page_dtor(page, NULL);
-	set_page_refcounted(page);
 	arch_release_hugepage(page);
-	__free_pages(page, huge_page_order(h));
+	VM_BUG_ON(hugetlb_cgroup_from_page(page));
+
+	if (order < MAX_ORDER) {
+		for (i = 0; i < pages_per_huge_page(h); i++)
+			clear_page_flag(page+i);
+		set_page_refcounted(page);
+		__free_pages(page, huge_page_order(h));
+	} else {
+		int nr_pages = 1 << order;
+		destroy_compound_page(page, order);
+		set_compound_order(page, 0);
+		for (i = 0, p = page; i < nr_pages; i++,
+					p = mem_map_next(p, page, i)) {
+			clear_page_flag(p);
+			set_page_refcounted(p);
+			__free_pages(p, 0);
+		}
+	}
 }
 
 struct hstate *size_to_hstate(unsigned long size)
diff --git a/mm/internal.h b/mm/internal.h
index 8562de0..a63a35f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -101,6 +101,7 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
  */
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
+extern int destroy_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
 extern bool is_free_buddy_page(struct page *page);
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1394c5a..0ea14ba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -367,7 +367,7 @@ void prep_compound_page(struct page *page, unsigned long order)
 }
 
 /* update __split_huge_page_refcount if you change this function */
-static int destroy_compound_page(struct page *page, unsigned long order)
+int destroy_compound_page(struct page *page, unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
