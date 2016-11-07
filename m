Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E32B6B025E
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:32:14 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id i88so57415016pfk.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:14 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id a2si33437364pgn.278.2016.11.07.15.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:32:13 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id i88so17317825pfk.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:13 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 03/12] mm: thp: introduce separate TTU flag for thp freezing
Date: Tue,  8 Nov 2016 08:31:48 +0900
Message-Id: <1478561517-4317-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

TTU_MIGRATION is used to convert pte into migration entry until thp split
completes. This behavior conflicts with thp migration added later patches,
so let's introduce a new TTU flag specifically for freezing.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/rmap.h | 1 +
 mm/huge_memory.c     | 2 +-
 mm/rmap.c            | 8 +++++---
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/rmap.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/rmap.h
index b46bb56..a2fa425 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/rmap.h
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/rmap.h
@@ -87,6 +87,7 @@ enum ttu_flags {
 	TTU_MUNLOCK = 4,		/* munlock mode */
 	TTU_LZFREE = 8,			/* lazy free mode */
 	TTU_SPLIT_HUGE_PMD = 16,	/* split huge PMD if any */
+	TTU_SPLIT_FREEZE = 32,		/* freeze pte under splitting thp */
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/huge_memory.c
index 2d1d6bb..0509d17 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/huge_memory.c
@@ -1794,7 +1794,7 @@ static void freeze_page(struct page *page)
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
 	if (PageAnon(page))
-		ttu_flags |= TTU_MIGRATION;
+		ttu_flags |= TTU_SPLIT_FREEZE;
 
 	/* We only need TTU_SPLIT_HUGE_PMD once */
 	ret = try_to_unmap(page, ttu_flags | TTU_SPLIT_HUGE_PMD);
diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/rmap.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/rmap.c
index 1ef3640..a4be307 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/mm/rmap.c
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/rmap.c
@@ -1449,7 +1449,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 	if (flags & TTU_SPLIT_HUGE_PMD) {
 		split_huge_pmd_address(vma, address,
-				flags & TTU_MIGRATION, page);
+				flags & TTU_SPLIT_FREEZE, page);
 		/* check if we have anything to do after split */
 		if (page_mapcount(page) == 0)
 			goto out;
@@ -1527,7 +1527,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 * will take care of the rest.
 		 */
 		dec_mm_counter(mm, mm_counter(page));
-	} else if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION)) {
+	} else if (IS_ENABLED(CONFIG_MIGRATION) &&
+		   (flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))) {
 		swp_entry_t entry;
 		pte_t swp_pte;
 		/*
@@ -1649,7 +1650,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 	 * locking requirements of exec(), migration skips
 	 * temporary VMAs until after exec() completes.
 	 */
-	if ((flags & TTU_MIGRATION) && !PageKsm(page) && PageAnon(page))
+	if ((flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))
+	    && !PageKsm(page) && PageAnon(page))
 		rwc.invalid_vma = invalid_migration_vma;
 
 	if (flags & TTU_RMAP_LOCKED)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
