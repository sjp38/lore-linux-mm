Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4736E6B00A7
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 18:56:20 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id i17so5035292qcy.3
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 15:56:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v6si16907164qco.27.2014.09.15.15.56.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 15:56:17 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 5/5] mm/hugetlb: add migration entry check in __unmap_hugepage_range
Date: Mon, 15 Sep 2014 18:39:59 -0400
Message-Id: <1410820799-27278-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, stable@vger.kernel.org

If __unmap_hugepage_range() tries to unmap the address range over which
hugepage migration is on the way, we get the wrong page because pte_page()
doesn't work for migration entries. This patch simply clears the pte for
migration entries as we do for hwpoison entries.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  # [2.6.36+]
---
ChangeLog v4:
- check hwpoisoned hugepage and migrating hugepage with the same check
  instead of doing separately
---
 mm/hugetlb.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git mmotm-2014-09-09-14-42.orig/mm/hugetlb.c mmotm-2014-09-09-14-42/mm/hugetlb.c
index 461ee1e10067..1ecb625bc498 100644
--- mmotm-2014-09-09-14-42.orig/mm/hugetlb.c
+++ mmotm-2014-09-09-14-42/mm/hugetlb.c
@@ -2653,9 +2653,10 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			goto unlock;
 
 		/*
-		 * HWPoisoned hugepage is already unmapped and dropped reference
+		 * Migrating hugepage or HWPoisoned hugepage is already
+		 * unmapped and its refcount is dropped, so just clear pte here.
 		 */
-		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
+		if (unlikely(!pte_present(pte))) {
 			huge_pte_clear(mm, address, ptep);
 			goto unlock;
 		}
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
