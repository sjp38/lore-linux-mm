Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 01AEB6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 03:02:28 -0500 (EST)
Received: by igcto18 with SMTP id to18so6790338igc.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 00:02:27 -0800 (PST)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id 21si26416469ioq.82.2015.11.26.00.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 00:02:27 -0800 (PST)
Received: by iouu10 with SMTP id u10so79297423iou.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 00:02:27 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: hugetlb: call huge_pte_alloc() only if ptep is null
Date: Thu, 26 Nov 2015 17:02:16 +0900
Message-Id: <1448524936-10501-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Currently at the beginning of hugetlb_fault(), we call huge_pte_offset()
and check whether the obtained *ptep is a migration/hwpoison entry or not.
And if not, then we get to call huge_pte_alloc(). This is racy because the
*ptep could turn into migration/hwpoison entry after the huge_pte_offset()
check. This race results in BUG_ON in huge_pte_alloc().

We don't have to call huge_pte_alloc() when the huge_pte_offset() returns
non-NULL, so let's fix this bug with moving the code into else block.

Note that the *ptep could turn into a migration/hwpoison entry after
this block, but that's not a problem because we have another !pte_present
check later (we never go into hugetlb_no_page() in that case.)

Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org> [2.6.36+]
---
 mm/hugetlb.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git next-20151123/mm/hugetlb.c next-20151123_patched/mm/hugetlb.c
index 1101ccd..6ad5e91 100644
--- next-20151123/mm/hugetlb.c
+++ next-20151123_patched/mm/hugetlb.c
@@ -3696,12 +3696,12 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
 			return VM_FAULT_HWPOISON_LARGE |
 				VM_FAULT_SET_HINDEX(hstate_index(h));
+	} else {
+		ptep = huge_pte_alloc(mm, address, huge_page_size(h));
+		if (!ptep)
+			return VM_FAULT_OOM;
 	}
 
-	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
-	if (!ptep)
-		return VM_FAULT_OOM;
-
 	mapping = vma->vm_file->f_mapping;
 	idx = vma_hugecache_offset(h, vma, address);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
