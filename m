Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD6266B033C
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 05:00:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z70so28234039wrc.1
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 02:00:55 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id k6si10712633wme.117.2017.06.13.02.00.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 02:00:54 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id v104so27755556wrb.0
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 02:00:53 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 3/4] mm, hugetlb: get rid of dequeue_huge_page_node
Date: Tue, 13 Jun 2017 11:00:38 +0200
Message-Id: <20170613090039.14393-4-mhocko@kernel.org>
In-Reply-To: <20170613090039.14393-1-mhocko@kernel.org>
References: <20170613090039.14393-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

dequeue_huge_page_node has a single caller alloc_huge_page_node and we
already have to handle NUMA_NO_NODE specially there. So get rid of the
helper and use the same numa mask trick for hugetlb dequeue as we use
for the allocation.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/hugetlb.c | 29 ++++++++++-------------------
 1 file changed, 10 insertions(+), 19 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 696de029f0fa..f58d6362c2c3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -943,14 +943,6 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, int nid,
 	return NULL;
 }
 
-static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
-{
-	if (nid != NUMA_NO_NODE)
-		return dequeue_huge_page_node_exact(h, nid);
-
-	return dequeue_huge_page_nodemask(h, nid, NULL);
-}
-
 static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
 				unsigned long address, int avoid_reserve,
@@ -1640,23 +1632,22 @@ struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
 struct page *alloc_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page = NULL;
+	nodemask_t nmask;
+
+	if (nid != NUMA_NO_NODE) {
+		nmask = NODE_MASK_NONE;
+		node_set(nid, nmask);
+	} else {
+		nmask = node_states[N_MEMORY];
+	}
 
 	spin_lock(&hugetlb_lock);
 	if (h->free_huge_pages - h->resv_huge_pages > 0)
-		page = dequeue_huge_page_node(h, nid);
+		page = dequeue_huge_page_nodemask(h, nid, &nmask);
 	spin_unlock(&hugetlb_lock);
 
-	if (!page) {
-		nodemask_t nmask;
-
-		if (nid != NUMA_NO_NODE) {
-			nmask = NODE_MASK_NONE;
-			node_set(nid, nmask);
-		} else {
-			nmask = node_states[N_MEMORY];
-		}
+	if (!page)
 		page = __alloc_buddy_huge_page(h, nid, &nmask);
-	}
 
 	return page;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
