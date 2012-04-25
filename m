Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 0A8846B004D
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 13:45:56 -0400 (EDT)
Received: by ghbg15 with SMTP id g15so44408ghb.2
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:45:56 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] rename is_mlocked_vma() to mlocked_vma_newpage()
Date: Wed, 25 Apr 2012 10:45:55 -0700
Message-Id: <1335375955-32037-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Andrew pointed out that the is_mlocked_vma() is misnamed. A function
with name like that would expect bool return and no side-effects.

Since it is called on the fault path for new page, rename it in this
patch.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/internal.h |    5 +++--
 mm/vmscan.c   |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 2189af4..a935af3 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -131,7 +131,8 @@ static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
  * to determine if it's being mapped into a LOCKED vma.
  * If so, mark page as mlocked.
  */
-static inline int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
+static inline int mlock_vma_newpage(struct vm_area_struct *vma,
+				    struct page *page)
 {
 	VM_BUG_ON(PageLRU(page));
 
@@ -189,7 +190,7 @@ extern unsigned long vma_address(struct page *page,
 				 struct vm_area_struct *vma);
 #endif
 #else /* !CONFIG_MMU */
-static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
+static inline int mlock_vma_newpage(struct vm_area_struct *v, struct page *p)
 {
 	return 0;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1a51868..686c63e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3531,7 +3531,7 @@ int page_evictable(struct page *page, struct vm_area_struct *vma)
 	if (mapping_unevictable(page_mapping(page)))
 		return 0;
 
-	if (PageMlocked(page) || (vma && is_mlocked_vma(vma, page)))
+	if (PageMlocked(page) || (vma && mlock_vma_newpage(vma, page)))
 		return 0;
 
 	return 1;
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
