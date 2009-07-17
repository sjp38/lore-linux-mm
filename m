Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 955176B005C
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 13:27:21 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 05/10] ksm: no debug in page_dup_rmap()
Date: Fri, 17 Jul 2009 20:30:45 +0300
Message-Id: <1247851850-4298-6-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-5-git-send-email-ieidus@redhat.com>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
 <1247851850-4298-5-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ieidus@redhat.com, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh.dickins@tiscali.co.uk>

page_dup_rmap(), used on each mapped page when forking,  was originally
just an inline atomic_inc of mapcount.  2.6.22 added CONFIG_DEBUG_VM
out-of-line checks to it, which would need to be ever-so-slightly
complicated to allow for the PageKsm() we're about to define.

But I think these checks never caught anything.  And if it's coding
errors we're worried about, such checks should be in page_remove_rmap()
too, not just when forking; whereas if it's pagetable corruption we're
worried about, then they shouldn't be limited to CONFIG_DEBUG_VM.

Oh, just revert page_dup_rmap() to an inline atomic_inc of mapcount.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Signed-off-by: Chris Wright <chrisw@redhat.com>
Signed-off-by: Izik Eidus <ieidus@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>
---
 include/linux/rmap.h |    6 +-----
 mm/memory.c          |    2 +-
 mm/rmap.c            |   21 ---------------------
 3 files changed, 2 insertions(+), 27 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index bf116d0..477841d 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -71,14 +71,10 @@ void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned lon
 void page_add_file_rmap(struct page *);
 void page_remove_rmap(struct page *);
 
-#ifdef CONFIG_DEBUG_VM
-void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address);
-#else
-static inline void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address)
+static inline void page_dup_rmap(struct page *page)
 {
 	atomic_inc(&page->_mapcount);
 }
-#endif
 
 /*
  * Called from mm/vmscan.c to handle paging out
diff --git a/mm/memory.c b/mm/memory.c
index 8159a62..8b1922c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -595,7 +595,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page, vma, addr);
+		page_dup_rmap(page);
 		rss[!!PageAnon(page)]++;
 	}
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 836c6c6..ab84e45 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -709,27 +709,6 @@ void page_add_file_rmap(struct page *page)
 	}
 }
 
-#ifdef CONFIG_DEBUG_VM
-/**
- * page_dup_rmap - duplicate pte mapping to a page
- * @page:	the page to add the mapping to
- * @vma:	the vm area being duplicated
- * @address:	the user virtual address mapped
- *
- * For copy_page_range only: minimal extract from page_add_file_rmap /
- * page_add_anon_rmap, avoiding unnecessary tests (already checked) so it's
- * quicker.
- *
- * The caller needs to hold the pte lock.
- */
-void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address)
-{
-	if (PageAnon(page))
-		__page_check_anon_rmap(page, vma, address);
-	atomic_inc(&page->_mapcount);
-}
-#endif
-
 /**
  * page_remove_rmap - take down pte mapping from a page
  * @page: page to remove mapping from
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
