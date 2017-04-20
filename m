Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E7BC36B03A0
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 16:47:58 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f23so9160899qkh.21
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 13:47:58 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id l184si7047338qke.248.2017.04.20.13.47.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 13:47:58 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v5 03/11] mm: thp: introduce separate TTU flag for thp freezing
Date: Thu, 20 Apr 2017 16:47:44 -0400
Message-Id: <20170420204752.79703-4-zi.yan@sent.com>
In-Reply-To: <20170420204752.79703-1-zi.yan@sent.com>
References: <20170420204752.79703-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

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
              if (!pvmw.pte && page) {
                  set_pmd_migration_entry(&pvmw, page);
                  continue;
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
index 43ef2c30cb0f..f8ca2e74b819 100644
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
index 1c19331a2db9..0db1f1c90aad 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2159,7 +2159,7 @@ static void freeze_page(struct page *page)
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
 	if (PageAnon(page))
-		ttu_flags |= TTU_MIGRATION;
+		ttu_flags |= TTU_SPLIT_FREEZE;
 
 	unmap_success = try_to_unmap(page, ttu_flags);
 	VM_BUG_ON_PAGE(!unmap_success, page);
diff --git a/mm/rmap.c b/mm/rmap.c
index 5c97ce4f5b2d..b0c6b20dca74 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1308,7 +1308,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 	if (flags & TTU_SPLIT_HUGE_PMD) {
 		split_huge_pmd_address(vma, address,
-				flags & TTU_MIGRATION, page);
+				flags & TTU_SPLIT_FREEZE, page);
 	}
 
 	while (page_vma_mapped_walk(&pvmw)) {
@@ -1394,7 +1394,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			 */
 			dec_mm_counter(mm, mm_counter(page));
 		} else if (IS_ENABLED(CONFIG_MIGRATION) &&
-				(flags & TTU_MIGRATION)) {
+				(flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))) {
 			swp_entry_t entry;
 			pte_t swp_pte;
 			/*
@@ -1519,7 +1519,8 @@ bool try_to_unmap(struct page *page, enum ttu_flags flags)
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
