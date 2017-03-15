Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF3DA6B0388
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 01:24:59 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b2so14561040pgc.6
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 22:24:59 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k13si976753pgn.38.2017.03.14.22.24.58
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 22:24:59 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 04/10] mm: make the try_to_munlock void function
Date: Wed, 15 Mar 2017 14:24:47 +0900
Message-ID: <1489555493-14659-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1489555493-14659-1-git-send-email-minchan@kernel.org>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

try_to_munlock returns SWAP_MLOCK if the one of VMAs mapped
the page has VM_LOCKED flag. In that time, VM set PG_mlocked to
the page if the page is not pte-mapped THP which cannot be
mlocked, either.

With that, __munlock_isolated_page can use PageMlocked to check
whether try_to_munlock is successful or not without relying on
try_to_munlock's retval. It helps to make try_to_unmap/try_to_unmap_one
simple with upcoming patches.

Cc: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h |  2 +-
 mm/mlock.c           |  6 ++----
 mm/rmap.c            | 17 +++++------------
 3 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b556eef..1b0cd4c 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -235,7 +235,7 @@ int page_mkclean(struct page *);
  * called in munlock()/munmap() path to check for other vmas holding
  * the page mlocked.
  */
-int try_to_munlock(struct page *);
+void try_to_munlock(struct page *);
 
 void remove_migration_ptes(struct page *old, struct page *new, bool locked);
 
diff --git a/mm/mlock.c b/mm/mlock.c
index 02f1382..9660ee5 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -123,17 +123,15 @@ static bool __munlock_isolate_lru_page(struct page *page, bool getpage)
  */
 static void __munlock_isolated_page(struct page *page)
 {
-	int ret = SWAP_AGAIN;
-
 	/*
 	 * Optimization: if the page was mapped just once, that's our mapping
 	 * and we don't need to check all the other vmas.
 	 */
 	if (page_mapcount(page) > 1)
-		ret = try_to_munlock(page);
+		try_to_munlock(page);
 
 	/* Did try_to_unlock() succeed or punt? */
-	if (ret != SWAP_MLOCK)
+	if (!PageMlocked(page))
 		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
 
 	putback_lru_page(page);
diff --git a/mm/rmap.c b/mm/rmap.c
index bdc7310..2f1fbd9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1547,18 +1547,10 @@ static int page_not_mapped(struct page *page)
  * Called from munlock code.  Checks all of the VMAs mapping the page
  * to make sure nobody else has this page mlocked. The page will be
  * returned with PG_mlocked cleared if no other vmas have it mlocked.
- *
- * Return values are:
- *
- * SWAP_AGAIN	- no vma is holding page mlocked, or,
- * SWAP_AGAIN	- page mapped in mlocked vma -- couldn't acquire mmap sem
- * SWAP_FAIL	- page cannot be located at present
- * SWAP_MLOCK	- page is now mlocked.
  */
-int try_to_munlock(struct page *page)
-{
-	int ret;
 
+void try_to_munlock(struct page *page)
+{
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
 		.arg = (void *)TTU_MUNLOCK,
@@ -1568,9 +1560,10 @@ int try_to_munlock(struct page *page)
 	};
 
 	VM_BUG_ON_PAGE(!PageLocked(page) || PageLRU(page), page);
+	VM_BUG_ON_PAGE(PageMlocked(page), page);
+	VM_BUG_ON_PAGE(PageCompound(page) && PageDoubleMap(page), page);
 
-	ret = rmap_walk(page, &rwc);
-	return ret;
+	rmap_walk(page, &rwc);
 }
 
 void __put_anon_vma(struct anon_vma *anon_vma)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
