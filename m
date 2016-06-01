Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 888B86B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 20:36:45 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i127so13542366ita.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 17:36:45 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id h5si7476405pah.28.2016.05.31.17.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 17:36:44 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id b124so653677pfb.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 17:36:44 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: thp: check pmd_trans_unstable() after split_huge_pmd()
Date: Wed,  1 Jun 2016 09:36:40 +0900
Message-Id: <1464741400-12143-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

split_huge_pmd() doesn't guarantee that the pmd is normal pmd pointing to
pte entries, which can be checked with pmd_trans_unstable(). Some callers
of split_huge_pmd() don't have the check, so let's add it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/gup.c       | 2 ++
 mm/mempolicy.c | 2 ++
 mm/mprotect.c  | 2 +-
 mm/mremap.c    | 3 +--
 4 files changed, 6 insertions(+), 3 deletions(-)

diff --git v4.6-mmotm-2016-05-27-15-19/mm/gup.c v4.6-mmotm-2016-05-27-15-19_patched/mm/gup.c
index c057784..dee142e 100644
--- v4.6-mmotm-2016-05-27-15-19/mm/gup.c
+++ v4.6-mmotm-2016-05-27-15-19_patched/mm/gup.c
@@ -279,6 +279,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 			spin_unlock(ptl);
 			ret = 0;
 			split_huge_pmd(vma, pmd, address);
+			if (pmd_trans_unstable(pmd))
+				ret = -EBUSY;
 		} else {
 			get_page(page);
 			spin_unlock(ptl);
diff --git v4.6-mmotm-2016-05-27-15-19/mm/mempolicy.c v4.6-mmotm-2016-05-27-15-19_patched/mm/mempolicy.c
index 297d685..fe90e50 100644
--- v4.6-mmotm-2016-05-27-15-19/mm/mempolicy.c
+++ v4.6-mmotm-2016-05-27-15-19_patched/mm/mempolicy.c
@@ -512,6 +512,8 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		}
 	}
 
+	if (pmd_trans_unstable(pmd))
+		return 0;
 retry:
 	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
diff --git v4.6-mmotm-2016-05-27-15-19/mm/mprotect.c v4.6-mmotm-2016-05-27-15-19_patched/mm/mprotect.c
index 5019a1e..a4830f0 100644
--- v4.6-mmotm-2016-05-27-15-19/mm/mprotect.c
+++ v4.6-mmotm-2016-05-27-15-19_patched/mm/mprotect.c
@@ -163,7 +163,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
 				split_huge_pmd(vma, pmd, addr);
-				if (pmd_none(*pmd))
+				if (pmd_trans_unstable(pmd))
 					continue;
 			} else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
diff --git v4.6-mmotm-2016-05-27-15-19/mm/mremap.c v4.6-mmotm-2016-05-27-15-19_patched/mm/mremap.c
index 1f157ad..da22ad2 100644
--- v4.6-mmotm-2016-05-27-15-19/mm/mremap.c
+++ v4.6-mmotm-2016-05-27-15-19_patched/mm/mremap.c
@@ -210,9 +210,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 				}
 			}
 			split_huge_pmd(vma, old_pmd, old_addr);
-			if (pmd_none(*old_pmd))
+			if (pmd_trans_unstable(old_pmd))
 				continue;
-			VM_BUG_ON(pmd_trans_huge(*old_pmd));
 		}
 		if (pte_alloc(new_vma->vm_mm, new_pmd, new_addr))
 			break;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
