Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 5E75B6B0069
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 06:31:14 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 10:10:29 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FANl1v1114510
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 20:23:47 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FAV8mI018432
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 20:31:09 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 1/2] hugetlb: Move all the in use pages to active list
Date: Fri, 15 Jun 2012 16:01:02 +0530
Message-Id: <1339756263-20378-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, akpm@linux-foundation.org
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

When we fail to allocate pages from the reserve pool, hugetlb
do try to allocate huge pages using alloc_buddy_huge_page.
Add these to the active list. We also need to add the huge
page we allocate when we soft offline the oldpage to active
list.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c57740b..ec7b86e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -928,8 +928,14 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
 	page = dequeue_huge_page_node(h, nid);
 	spin_unlock(&hugetlb_lock);
 
-	if (!page)
+	if (!page) {
 		page = alloc_buddy_huge_page(h, nid);
+		if (page) {
+			spin_lock(&hugetlb_lock);
+			list_move(&page->lru, &h->hugepage_activelist);
+			spin_unlock(&hugetlb_lock);
+		}
+	}
 
 	return page;
 }
@@ -1155,6 +1161,9 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 			hugepage_subpool_put_pages(spool, chg);
 			return ERR_PTR(-ENOSPC);
 		}
+		spin_lock(&hugetlb_lock);
+		list_move(&page->lru, &h->hugepage_activelist);
+		spin_unlock(&hugetlb_lock);
 	}
 
 	set_page_private(page, (unsigned long)spool);
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
