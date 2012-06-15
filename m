Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 2C0C56B006C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 06:08:38 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 15:38:35 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FA8VPe1835488
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 15:38:31 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FFd93Z021054
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 01:39:09 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 1/2] hugetlb: Move all the in use pages to active list
Date: Fri, 15 Jun 2012 15:38:21 +0530
Message-Id: <1339754902-17779-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <87k3z8nb3h.fsf@skywalker.in.ibm.com>
References: <87k3z8nb3h.fsf@skywalker.in.ibm.com>
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
 mm/hugetlb.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c57740b..ee4da3b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -928,8 +928,10 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
 	page = dequeue_huge_page_node(h, nid);
 	spin_unlock(&hugetlb_lock);
 
-	if (!page)
+	if (!page) {
 		page = alloc_buddy_huge_page(h, nid);
+		list_move(&page->lru, &h->hugepage_activelist);
+	}
 
 	return page;
 }
@@ -1155,6 +1157,9 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
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
