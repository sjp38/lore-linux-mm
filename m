Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id DF2DD6B0068
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 05:27:17 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 17/20] mm, hugetlb: move up anon_vma_prepare()
Date: Fri,  9 Aug 2013 18:26:35 +0900
Message-Id: <1376040398-11212-18-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If we fail with a allocated hugepage, we need some effort to recover
properly. So, it is better not to allocate a hugepage as much as possible.
So move up anon_vma_prepare() which can be failed in OOM situation.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2372f75..7e9a651 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2520,6 +2520,17 @@ retry_avoidcopy:
 	spin_unlock(&mm->page_table_lock);
 
 	/*
+	 * When the original hugepage is shared one, it does not have
+	 * anon_vma prepared.
+	 */
+	if (unlikely(anon_vma_prepare(vma))) {
+		page_cache_release(old_page);
+		/* Caller expects lock to be held */
+		spin_lock(&mm->page_table_lock);
+		return VM_FAULT_OOM;
+	}
+
+	/*
 	 * If the process that created a MAP_PRIVATE mapping is about to
 	 * perform a COW due to a shared page count, attempt to satisfy
 	 * the allocation without using the existing reserves. The pagecache
@@ -2578,18 +2589,6 @@ retry_avoidcopy:
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
-		spin_lock(&mm->page_table_lock);
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
