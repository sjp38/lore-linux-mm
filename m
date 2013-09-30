Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E46D36B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 03:58:58 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so5543910pab.17
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 00:58:58 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] mm, hugetlb: correct missing private flag clearing
Date: Mon, 30 Sep 2013 16:59:44 +0900
Message-Id: <1380527985-18499-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We should clear the page's private flag when returing the page to
the page allocator or the hugepage pool. This patch fixes it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
Hello, Andrew.

I sent the new version of commit ('07443a8') before you did pull request,
but it isn't included. It may be losted :)
So I send this fix. IMO, this is good for v3.12.

Thanks.

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b49579c..691f226 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -653,6 +653,7 @@ static void free_huge_page(struct page *page)
 	BUG_ON(page_count(page));
 	BUG_ON(page_mapcount(page));
 	restore_reserve = PagePrivate(page);
+	ClearPagePrivate(page);
 
 	spin_lock(&hugetlb_lock);
 	hugetlb_cgroup_uncharge_page(hstate_index(h),
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
