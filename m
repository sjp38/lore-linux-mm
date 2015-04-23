Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF4E6B007B
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 18:14:07 -0400 (EDT)
Received: by pdea3 with SMTP id a3so30027881pde.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 15:14:06 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ju8si14407732pbb.43.2015.04.23.15.14.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 15:14:06 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v2 PATCH 2/5] hugetlbfs: remove region_truncte() as region_del() can be used
Date: Thu, 23 Apr 2015 15:13:14 -0700
Message-Id: <1429827197-677-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1429827197-677-1-git-send-email-mike.kravetz@oracle.com>
References: <1429827197-677-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

Now that region_del() exists, the region_truncate() routine can be
removed.  Callers of region_truncate are changed to call region_del
instead with a ending value of -1.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 37 +------------------------------------
 1 file changed, 1 insertion(+), 36 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 31e36cd..60a4f21 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -328,41 +328,6 @@ retry:
 	return chg;
 }
 
-static long region_truncate(struct resv_map *resv, long end)
-{
-	struct list_head *head = &resv->regions;
-	struct file_region *rg, *trg;
-	long chg = 0;
-
-	spin_lock(&resv->lock);
-	/* Locate the region we are either in or before. */
-	list_for_each_entry(rg, head, link)
-		if (end <= rg->to)
-			break;
-	if (&rg->link == head)
-		goto out;
-
-	/* If we are in the middle of a region then adjust it. */
-	if (end > rg->from) {
-		chg = rg->to - end;
-		rg->to = end;
-		rg = list_entry(rg->link.next, typeof(*rg), link);
-	}
-
-	/* Drop any remaining regions. */
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-		if (&rg->link == head)
-			break;
-		chg += rg->to - rg->from;
-		list_del(&rg->link);
-		kfree(rg);
-	}
-
-out:
-	spin_unlock(&resv->lock);
-	return chg;
-}
-
 static long region_count(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
@@ -494,7 +459,7 @@ void resv_map_release(struct kref *ref)
 	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
 
 	/* Clear out any active regions before we release the map. */
-	region_truncate(resv_map, 0);
+	region_del(resv_map, 0, -1);
 	kfree(resv_map);
 }
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
