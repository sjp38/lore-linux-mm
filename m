Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 88CBD6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 14:50:24 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id z60so9024765qgd.13
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 11:50:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x3si26189106qab.111.2014.07.28.11.50.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 11:50:19 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/3] mm/hugetlb: use get_page_unless_zero() in hugetlb_fault()
Date: Mon, 28 Jul 2014 14:08:31 -0400
Message-Id: <1406570911-28133-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1406570911-28133-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1406570911-28133-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

After fixing the race in follow_page(FOLL_GET) for hugepages, I start to
observe the BUG of "get_page() on refcount 0 page" in hugetlb_fault() in
the same test.

I'm not exactly sure about how this race is triggered, but hugetlb_fault()
calls pte_page() and get_page() outside page table lock, so it's not safe.
This patch checks the refcount of the gotten page, and aborts the page fault
if the refcount is 0, expecting to retry.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  # [3.12+]
---
 mm/hugetlb.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git mmotm-2014-07-22-15-58.orig/mm/hugetlb.c mmotm-2014-07-22-15-58/mm/hugetlb.c
index 6793914b6aac..86e7341aad77 100644
--- mmotm-2014-07-22-15-58.orig/mm/hugetlb.c
+++ mmotm-2014-07-22-15-58/mm/hugetlb.c
@@ -3189,7 +3189,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * so no worry about deadlock.
 	 */
 	page = pte_page(entry);
-	get_page(page);
+	if (!get_page_unless_zero(page))
+		goto out_put_pagecache;
 	if (page != pagecache_page)
 		lock_page(page);
 
@@ -3215,15 +3216,14 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 out_ptl:
 	spin_unlock(ptl);
-
+	if (page != pagecache_page)
+		unlock_page(page);
+	put_page(page);
+out_put_pagecache:
 	if (pagecache_page) {
 		unlock_page(pagecache_page);
 		put_page(pagecache_page);
 	}
-	if (page != pagecache_page)
-		unlock_page(page);
-	put_page(page);
-
 out_mutex:
 	mutex_unlock(&htlb_fault_mutex_table[hash]);
 	return ret;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
