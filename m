Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 317E86B038A
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:39:32 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x17so81881347pgi.3
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:39:32 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id h5si6624287pgg.45.2017.03.01.22.39.30
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 22:39:31 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 05/11] mm: make the try_to_munlock void function
Date: Thu,  2 Mar 2017 15:39:19 +0900
Message-Id: <1488436765-32350-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1488436765-32350-1-git-send-email-minchan@kernel.org>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

try_to_munlock returns SWAP_MLOCK if the one of VMAs mapped
the page has VM_LOCKED flag. In that time, VM set PG_mlocked to
the page if the page is not pte-mapped THP which cannot be
mlocked, either.

With that, __munlock_isolated_page can use PageMlocked to check
whether try_to_munlock is successful or not without relying on
try_to_munlock's retval. It helps to make ttu/ttuo simple with
upcoming patches.

Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h |  2 +-
 mm/mlock.c           |  6 ++----
 mm/rmap.c            | 16 ++++------------
 3 files changed, 7 insertions(+), 17 deletions(-)

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
index cdbed8a..d34a540 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -122,17 +122,15 @@ static bool __munlock_isolate_lru_page(struct page *page, bool getpage)
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
index 0a48958..61ae694 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1540,18 +1540,10 @@ static int page_not_mapped(struct page *page)
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
@@ -1561,9 +1553,9 @@ int try_to_munlock(struct page *page)
 	};
 
 	VM_BUG_ON_PAGE(!PageLocked(page) || PageLRU(page), page);
+	VM_BUG_ON_PAGE(PageMlocked(page), page);
 
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
