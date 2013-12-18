Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 699986B004D
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:54:14 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so7962179pbc.5
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:54:14 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id v7si13541359pbi.38.2013.12.17.22.54.09
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 22:54:10 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 09/14] mm, hugetlb: remove a check for return value of alloc_huge_page()
Date: Wed, 18 Dec 2013 15:53:55 +0900
Message-Id: <1387349640-8071-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, alloc_huge_page() only return -ENOSPEC if failed.
So, we don't need to worry about other return value.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d960f46..0f56bbf 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2621,7 +2621,6 @@ retry_avoidcopy:
 	new_page = alloc_huge_page(vma, address, use_reserve);
 
 	if (IS_ERR(new_page)) {
-		long err = PTR_ERR(new_page);
 		page_cache_release(old_page);
 
 		/*
@@ -2650,10 +2649,7 @@ retry_avoidcopy:
 
 		/* Caller expects lock to be held */
 		spin_lock(ptl);
-		if (err == -ENOMEM)
-			return VM_FAULT_OOM;
-		else
-			return VM_FAULT_SIGBUS;
+		return VM_FAULT_SIGBUS;
 	}
 
 	/*
@@ -2785,11 +2781,7 @@ retry:
 
 		page = alloc_huge_page(vma, address, use_reserve);
 		if (IS_ERR(page)) {
-			ret = PTR_ERR(page);
-			if (ret == -ENOMEM)
-				ret = VM_FAULT_OOM;
-			else
-				ret = VM_FAULT_SIGBUS;
+			ret = VM_FAULT_SIGBUS;
 			goto out;
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
