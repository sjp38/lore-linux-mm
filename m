Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0696B0055
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:54:16 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so8047385pbc.15
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:54:15 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id wh6si13516242pac.306.2013.12.17.22.54.10
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 22:54:11 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 11/14] mm, hugetlb: move up anon_vma_prepare()
Date: Wed, 18 Dec 2013 15:53:57 +0900
Message-Id: <1387349640-8071-12-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If we fail with a allocated hugepage, we need some effort to recover
properly. So, it is better not to allocate a hugepage as much as possible.
So move up anon_vma_prepare() which can be failed in OOM situation.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 03ab285..1817720 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2597,6 +2597,17 @@ retry_avoidcopy:
 	spin_unlock(ptl);
 
 	/*
+	 * When the original hugepage is shared one, it does not have
+	 * anon_vma prepared.
+	 */
+	if (unlikely(anon_vma_prepare(vma))) {
+		page_cache_release(old_page);
+		/* Caller expects lock to be held */
+		spin_lock(ptl);
+		return VM_FAULT_OOM;
+	}
+
+	/*
 	 * If the process that created a MAP_PRIVATE mapping is about to
 	 * perform a COW due to a shared page count, attempt to satisfy
 	 * the allocation without using the existing reserves. The pagecache
@@ -2655,18 +2666,6 @@ retry_avoidcopy:
 		return VM_FAULT_SIGBUS;
 	}
 
-	/*
-	 * When the original hugepage is shared one, it does not have
-	 * anon_vma prepared.
-	 */
-	if (unlikely(anon_vma_prepare(vma))) {
-		page_cache_release(new_page);
-		page_cache_release(old_page);
-		/* Caller expects lock to be held */
-		spin_lock(ptl);
-		return VM_FAULT_OOM;
-	}
-
 	copy_user_huge_page(new_page, old_page, address, vma,
 			    pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
