Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D6D1B6B0268
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 11:14:34 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id d201so31440297qkg.2
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 08:14:34 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id t30si23327762qtt.48.2017.02.05.08.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Feb 2017 08:14:34 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v3 06/14] mm: thp: introduce separate TTU flag for thp freezing
Date: Sun,  5 Feb 2017 11:12:44 -0500
Message-Id: <20170205161252.85004-7-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-1-zi.yan@sent.com>
References: <20170205161252.85004-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

TTU_MIGRATION is used to convert pte into migration entry until thp split
completes. This behavior conflicts with thp migration added later patches,
so let's introduce a new TTU flag specifically for freezing.

try_to_unmap() is used both for thp split (via freeze_page()) and page
migration (via __unmap_and_move()). In freeze_page(), ttu_flag given for
head page is like below (assuming anonymous thp):

    (TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS | TTU_RMAP_LOCKED | \
     TTU_MIGRATION | TTU_SPLIT_HUGE_PMD)

and ttu_flag given for tail pages is:

    (TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS | TTU_RMAP_LOCKED | \
     TTU_MIGRATION)

__unmap_and_move() calls try_to_unmap() with ttu_flag:

    (TTU_MIGRATION | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS)

Now I'm trying to insert a branch for thp migration at the top of
try_to_unmap_one() like below

static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
                       unsigned long address, void *arg)
  {
          ...
          if (flags & TTU_MIGRATION) {
                  if (!PageHuge(page) && PageTransCompound(page)) {
                          set_pmd_migration_entry(page, vma, address);
                          goto out;
                  }
          }

, so try_to_unmap() for tail pages called by thp split can go into thp
migration code path (which converts *pmd* into migration entry), while
the expectation is to freeze thp (which converts *pte* into migration entry.)

I detected this failure as a "bad page state" error in a testcase where
split_huge_page() is called from queue_pages_pte_range().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/rmap.h | 1 +
 mm/huge_memory.c     | 2 +-
 mm/rmap.c            | 7 ++++---
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 8c89e902df3e..97d8b7127bd2 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -88,6 +88,7 @@ enum ttu_flags {
 	TTU_MUNLOCK = 4,		/* munlock mode */
 	TTU_LZFREE = 8,			/* lazy free mode */
 	TTU_SPLIT_HUGE_PMD = 16,	/* split huge PMD if any */
+	TTU_SPLIT_FREEZE = 32,		/* freeze pte under splitting thp */
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d8e15fd817b0..6893c47428b6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2123,7 +2123,7 @@ static void freeze_page(struct page *page)
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
 	if (PageAnon(page))
-		ttu_flags |= TTU_MIGRATION;
+		ttu_flags |= TTU_SPLIT_FREEZE;
 
 	ret = try_to_unmap(page, ttu_flags);
 	VM_BUG_ON_PAGE(ret, page);
diff --git a/mm/rmap.c b/mm/rmap.c
index 8774791e2809..16789b936e3a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1310,7 +1310,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 	if (flags & TTU_SPLIT_HUGE_PMD) {
 		split_huge_pmd_address(vma, address,
-				flags & TTU_MIGRATION, page);
+				flags & TTU_SPLIT_FREEZE, page);
 	}
 
 	while (page_vma_mapped_walk(&pvmw)) {
@@ -1395,7 +1395,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			 */
 			dec_mm_counter(mm, mm_counter(page));
 		} else if (IS_ENABLED(CONFIG_MIGRATION) &&
-				(flags & TTU_MIGRATION)) {
+				(flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))) {
 			swp_entry_t entry;
 			pte_t swp_pte;
 			/*
@@ -1514,7 +1514,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 	 * locking requirements of exec(), migration skips
 	 * temporary VMAs until after exec() completes.
 	 */
-	if ((flags & TTU_MIGRATION) && !PageKsm(page) && PageAnon(page))
+	if ((flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))
+	    && !PageKsm(page) && PageAnon(page))
 		rwc.invalid_vma = invalid_migration_vma;
 
 	if (flags & TTU_RMAP_LOCKED)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
