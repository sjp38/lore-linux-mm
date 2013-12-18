Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 968E66B0062
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:54:17 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so7831589pdj.2
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:54:17 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ye6si13499901pbc.350.2013.12.17.22.54.10
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 22:54:11 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 12/14] mm, hugetlb: clean-up error handling in hugetlb_cow()
Date: Wed, 18 Dec 2013 15:53:58 +0900
Message-Id: <1387349640-8071-13-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Current code include 'Caller expects lock to be held' in every error path.
We can clean-up it as we do error handling in one place.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1817720..a9ae7d3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2577,6 +2577,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	int outside_reserve = 0;
 	long chg;
 	bool use_reserve = false;
+	int ret = 0;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
@@ -2601,10 +2602,8 @@ retry_avoidcopy:
 	 * anon_vma prepared.
 	 */
 	if (unlikely(anon_vma_prepare(vma))) {
-		page_cache_release(old_page);
-		/* Caller expects lock to be held */
-		spin_lock(ptl);
-		return VM_FAULT_OOM;
+		ret = VM_FAULT_OOM;
+		goto out_old_page;
 	}
 
 	/*
@@ -2623,11 +2622,8 @@ retry_avoidcopy:
 	if (!outside_reserve) {
 		chg = vma_needs_reservation(h, vma, address);
 		if (chg < 0) {
-			page_cache_release(old_page);
-
-			/* Caller expects lock to be held */
-			spin_lock(ptl);
-			return VM_FAULT_OOM;
+			ret = VM_FAULT_OOM;
+			goto out_old_page;
 		}
 		use_reserve = !chg;
 	}
@@ -2661,9 +2657,8 @@ retry_avoidcopy:
 			WARN_ON_ONCE(1);
 		}
 
-		/* Caller expects lock to be held */
-		spin_lock(ptl);
-		return VM_FAULT_SIGBUS;
+		ret = VM_FAULT_SIGBUS;
+		goto out_lock;
 	}
 
 	copy_user_huge_page(new_page, old_page, address, vma,
@@ -2694,11 +2689,12 @@ retry_avoidcopy:
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	page_cache_release(new_page);
+out_old_page:
 	page_cache_release(old_page);
-
+out_lock:
 	/* Caller expects lock to be held */
 	spin_lock(ptl);
-	return 0;
+	return ret;
 }
 
 /* Return the pagecache page at a given address within a VMA */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
