Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFD4D6B0391
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:12:43 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 65so94276035pgi.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:12:43 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a74si7680195pfe.100.2017.03.02.07.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 07:12:43 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/4] thp: fix MADV_DONTNEED vs. MADV_FREE race
Date: Thu,  2 Mar 2017 18:10:33 +0300
Message-Id: <20170302151034.27829-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>

Basically the same race as with numa balancing in change_huge_pmd(), but
a bit simpler to mitigate: we don't need to preserve dirty/young flags
here due to MADV_FREE functionality.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/huge_memory.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bb2b3646bd78..324217c31ec9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1566,8 +1566,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		deactivate_page(page);
 
 	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
-		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
-			tlb->fullmm);
 		orig_pmd = pmd_mkold(orig_pmd);
 		orig_pmd = pmd_mkclean(orig_pmd);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
