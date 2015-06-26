Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 59E646B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 12:15:41 -0400 (EDT)
Received: by igblr2 with SMTP id lr2so16654167igb.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 09:15:41 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id nx10si15701725icc.45.2015.06.26.09.15.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jun 2015 09:15:40 -0700 (PDT)
Received: by iebrt9 with SMTP id rt9so78965484ieb.2
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 09:15:40 -0700 (PDT)
From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] mm:Make the function vma_has_reserves bool
Date: Fri, 26 Jun 2015 12:15:35 -0400
Message-Id: <1435335335-16007-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, rientjes@google.com, dave@stgolabs.net, mike.kravetz@oracle.com, lcapitulino@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This makes the function vma_has_reserves bool now due to this
particular function only returning either one or zero as its
return value.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 mm/hugetlb.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 75c0eef..0c34b40 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -616,7 +616,7 @@ void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 }
 
 /* Returns true if the VMA has associated reserve pages */
-static int vma_has_reserves(struct vm_area_struct *vma, long chg)
+static bool vma_has_reserves(struct vm_area_struct *vma, long chg)
 {
 	if (vma->vm_flags & VM_NORESERVE) {
 		/*
@@ -629,23 +629,23 @@ static int vma_has_reserves(struct vm_area_struct *vma, long chg)
 		 * properly, so add work-around here.
 		 */
 		if (vma->vm_flags & VM_MAYSHARE && chg == 0)
-			return 1;
+			return true;
 		else
-			return 0;
+			return false;
 	}
 
 	/* Shared mappings always use reserves */
 	if (vma->vm_flags & VM_MAYSHARE)
-		return 1;
+		return true;
 
 	/*
 	 * Only the process that called mmap() has reserves for
 	 * private mappings.
 	 */
 	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
-		return 1;
+		return true;
 
-	return 0;
+	return false;
 }
 
 static void enqueue_huge_page(struct hstate *h, struct page *page)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
