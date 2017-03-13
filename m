Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC9AD6B0388
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 11:46:17 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n37so41297714qtb.7
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:46:17 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id v52si690434qtb.211.2017.03.13.08.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 08:46:16 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v4 03/11] mm: thp: introduce separate TTU flag for thp freezing
Date: Mon, 13 Mar 2017 11:44:59 -0400
Message-Id: <20170313154507.3647-4-zi.yan@sent.com>
In-Reply-To: <20170313154507.3647-1-zi.yan@sent.com>
References: <20170313154507.3647-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

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
 include/linux/rmap.h | 3 ++-
 mm/huge_memory.c     | 2 +-
 mm/rmap.c            | 7 ++++---
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index fee10d744ebd..58803b6e7f82 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -93,8 +93,9 @@ enum ttu_flags {
 	TTU_BATCH_FLUSH		= 0x40,	/* Batch TLB flushes where possible
 					 * and caller guarantees they will
 					 * do a final flush if necessary */
-	TTU_RMAP_LOCKED		= 0x80	/* do not grab rmap lock:
+	TTU_RMAP_LOCKED		= 0x80,	/* do not grab rmap lock:
 					 * caller holds it */
+	TTU_SPLIT_FREEZE	= 0x100,		/* freeze pte under splitting thp */
 };
 
 #ifdef CONFIG_MMU
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f42d4d0a3019..e32ccbd8ee3a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2142,7 +2142,7 @@ static void freeze_page(struct page *page)
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
 	if (PageAnon(page))
-		ttu_flags |= TTU_MIGRATION;
+		ttu_flags |= TTU_SPLIT_FREEZE;
 
 	ret = try_to_unmap(page, ttu_flags);
 	VM_BUG_ON_PAGE(ret, page);
diff --git a/mm/rmap.c b/mm/rmap.c
index e4391100af51..555cc7ebacf6 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1304,7 +1304,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 	if (flags & TTU_SPLIT_HUGE_PMD) {
 		split_huge_pmd_address(vma, address,
-				flags & TTU_MIGRATION, page);
+				flags & TTU_SPLIT_FREEZE, page);
 	}
 
 	while (page_vma_mapped_walk(&pvmw)) {
@@ -1390,7 +1390,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			 */
 			dec_mm_counter(mm, mm_counter(page));
 		} else if (IS_ENABLED(CONFIG_MIGRATION) &&
-				(flags & TTU_MIGRATION)) {
+				(flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))) {
 			swp_entry_t entry;
 			pte_t swp_pte;
 			/*
@@ -1521,7 +1521,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
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
