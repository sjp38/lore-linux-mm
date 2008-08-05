Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m75FT8UC137702
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 15:29:08 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m75FT8Vl3875014
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 16:29:08 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m75FT8st014159
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 16:29:08 +0100
Subject: [PATCH] hugetlb: call arch_prepare_hugepage() for surplus pages
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Content-Type: text/plain
Date: Tue, 05 Aug 2008 17:29:07 +0200
Message-Id: <1217950147.5032.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

The s390 software large page emulation implements shared page tables
by using page->index of the first tail page from a compound large page
to store page table information. This is set up in arch_prepare_hugepage(),
which is called from alloc_fresh_huge_page_node().

A similar call to arch_prepare_hugepage() is missing for surplus large
pages that are allocated in alloc_buddy_huge_page(), which breaks the
software emulation mode for (surplus) large pages on s390. This patch
adds the missing call to arch_prepare_hugepage(). It will have no effect
on other architectures where arch_prepare_hugepage() is a nop.

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---

 mm/hugetlb.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Index: linux/mm/hugetlb.c
===================================================================
--- linux.orig/mm/hugetlb.c
+++ linux/mm/hugetlb.c
@@ -565,7 +565,7 @@ static struct page *alloc_fresh_huge_pag
 		huge_page_order(h));
 	if (page) {
 		if (arch_prepare_hugepage(page)) {
-			__free_pages(page, HUGETLB_PAGE_ORDER);
+			__free_pages(page, huge_page_order(h));
 			return NULL;
 		}
 		prep_new_huge_page(h, page, nid);
@@ -665,6 +665,11 @@ static struct page *alloc_buddy_huge_pag
 					__GFP_REPEAT|__GFP_NOWARN,
 					huge_page_order(h));
 
+	if (page && arch_prepare_hugepage(page)) {
+		__free_pages(page, huge_page_order(h));
+		return NULL;
+	}
+
 	spin_lock(&hugetlb_lock);
 	if (page) {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
