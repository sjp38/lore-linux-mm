Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 552B76B0037
	for <linux-mm@kvack.org>; Wed, 28 May 2014 04:00:06 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id l4so5614342lbv.34
        for <linux-mm@kvack.org>; Wed, 28 May 2014 01:00:05 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id ky6si39432146lbc.10.2014.05.28.01.00.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 01:00:04 -0700 (PDT)
Received: by mail-la0-f41.google.com with SMTP id e16so7198792lan.0
        for <linux-mm@kvack.org>; Wed, 28 May 2014 01:00:03 -0700 (PDT)
Subject: [PATCH] mm: dont call mmu_notifier_invalidate_page during munlock
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Wed, 28 May 2014 11:59:55 +0400
Message-ID: <20140528075955.20300.22758.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org

try_to_munlock() searches other mlocked vmas, it never unmaps pages.
There is no reason for invalidation because ptes are left unchanged.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 mm/rmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e773..75d9d5c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1225,7 +1225,7 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
-	if (ret != SWAP_FAIL)
+	if (ret != SWAP_FAIL && TTU_ACTION(flags) != TTU_MUNLOCK)
 		mmu_notifier_invalidate_page(mm, address);
 out:
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
