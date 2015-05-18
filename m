Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF6C6B006E
	for <linux-mm@kvack.org>; Mon, 18 May 2015 13:50:15 -0400 (EDT)
Received: by obfe9 with SMTP id e9so133438364obf.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 10:50:12 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id to9si6900753obc.20.2015.05.18.10.50.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 10:50:11 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/2] mm/hugetlb: compute/return the number of regions added by region_add()
Date: Mon, 18 May 2015 10:49:08 -0700
Message-Id: <1431971349-6668-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1431971349-6668-1-git-send-email-mike.kravetz@oracle.com>
References: <1431971349-6668-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Modify region_add() to keep track of regions(pages) added to the
reserve map and return this value.  The return value can be
compared to the return value of region_chg() to determine if the
map was modified between calls.  Make vma_commit_reservation()
also pass along the return value of region_add().  The special
case return values of vma_needs_reservation() should also be
taken into account when determining the return value of
vma_commit_reservation().

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c41b2a0..7f64034 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -156,6 +156,7 @@ static long region_add(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
 	struct file_region *rg, *nrg, *trg;
+	long chg = 0;
 
 	spin_lock(&resv->lock);
 	/* Locate the region we are either in or before. */
@@ -181,14 +182,17 @@ static long region_add(struct resv_map *resv, long f, long t)
 		if (rg->to > t)
 			t = rg->to;
 		if (rg != nrg) {
+			chg -= (rg->to - rg->from);
 			list_del(&rg->link);
 			kfree(rg);
 		}
 	}
+	chg += (nrg->from - f);
 	nrg->from = f;
+	chg += t - nrg->to;
 	nrg->to = t;
 	spin_unlock(&resv->lock);
-	return 0;
+	return chg;
 }
 
 static long region_chg(struct resv_map *resv, long f, long t)
@@ -1349,18 +1353,25 @@ static long vma_needs_reservation(struct hstate *h,
 	else
 		return chg < 0 ? chg : 0;
 }
-static void vma_commit_reservation(struct hstate *h,
+
+static long vma_commit_reservation(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long addr)
 {
 	struct resv_map *resv;
 	pgoff_t idx;
+	long add;
 
 	resv = vma_resv_map(vma);
 	if (!resv)
-		return;
+		return 1;
 
 	idx = vma_hugecache_offset(h, vma, addr);
-	region_add(resv, idx, idx + 1);
+	add = region_add(resv, idx, idx + 1);
+
+	if (vma->vm_flags & VM_MAYSHARE)
+		return add;
+	else
+		return 0;
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
