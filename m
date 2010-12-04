Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A38C96B009F
	for <linux-mm@kvack.org>; Sat,  4 Dec 2010 01:55:42 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oB46tbwd022673
	for <linux-mm@kvack.org>; Fri, 3 Dec 2010 22:55:37 -0800
Received: from pvg6 (pvg6.prod.google.com [10.241.210.134])
	by hpaq12.eem.corp.google.com with ESMTP id oB46tR3e023231
	for <linux-mm@kvack.org>; Fri, 3 Dec 2010 22:55:36 -0800
Received: by pvg6 with SMTP id 6so2502670pvg.37
        for <linux-mm@kvack.org>; Fri, 03 Dec 2010 22:55:35 -0800 (PST)
Date: Fri, 3 Dec 2010 22:55:30 -0800
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 2/6] mm: add FOLL_MLOCK follow_page flag.
Message-ID: <20101204065530.GA27895@google.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
 <1291335412-16231-3-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1291335412-16231-3-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

I did not realize that previously, but it turns out to be possible to
manipulate LRU lists under control of the pte lock, rather than having
to get/put the page. This allows the FOLL_MLOCK follow_page flag
implementation to look much nicer than it did in initial proposal.

Please consider the following as a replacement for the initial
patch 2/6 proposal...

--------------------------------- 8< --------------------------------------

Move the code to mlock pages from __mlock_vma_pages_range()
to follow_page().

This allows __mlock_vma_pages_range() to not have to break down work
into 16-page batches.

An additional motivation for doing this within the present patch series
is that it'll make it easier for a later chagne to drop mmap_sem when
blocking on disk (we'd like to be able to resume at the page that was
read from disk instead of at the start of a 16-page batch).

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/mm.h |    1 +
 mm/memory.c        |   22 +++++++++++++++++
 mm/mlock.c         |   65 ++++------------------------------------------------
 3 files changed, 28 insertions(+), 60 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 721f451..cebbb0d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1415,6 +1415,7 @@ struct page *follow_page(struct vm_area_struct *, unsigned long address,
 #define FOLL_GET	0x04	/* do get_page on page */
 #define FOLL_DUMP	0x08	/* give error on hole if it would be zero */
 #define FOLL_FORCE	0x10	/* get_user_pages read/write w/o permission */
+#define FOLL_MLOCK	0x20	/* mark page as mlocked */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
diff --git a/mm/memory.c b/mm/memory.c
index b8f97b8..15e1f19 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1310,6 +1310,28 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 		 */
 		mark_page_accessed(page);
 	}
+	if (flags & FOLL_MLOCK) {
+		/*
+		 * The preliminary mapping check is mainly to avoid the
+		 * pointless overhead of lock_page on the ZERO_PAGE
+		 * which might bounce very badly if there is contention.
+		 *
+		 * If the page is already locked, we don't need to
+		 * handle it now - vmscan will handle it later if and
+		 * when it attempts to reclaim the page.
+		 */
+		if (page->mapping && trylock_page(page)) {
+			lru_add_drain();  /* push cached pages to LRU */
+			/*
+			 * Because we lock page here and migration is
+			 * blocked by the pte's page reference, we need
+			 * only check for file-cache page truncation.
+			 */
+			if (page->mapping)
+				mlock_vma_page(page);
+			unlock_page(page);
+		}
+	}
 unlock:
 	pte_unmap_unlock(ptep, ptl);
 out:
diff --git a/mm/mlock.c b/mm/mlock.c
index 71db83e..573bd2c 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -159,10 +159,9 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long addr = start;
-	struct page *pages[16]; /* 16 gives a reasonable batch */
 	int nr_pages = (end - start) / PAGE_SIZE;
-	int ret = 0;
 	int gup_flags;
+	int ret;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(end   & ~PAGE_MASK);
@@ -170,7 +169,7 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	VM_BUG_ON(end   > vma->vm_end);
 	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
-	gup_flags = FOLL_TOUCH | FOLL_GET;
+	gup_flags = FOLL_TOUCH | FOLL_MLOCK;
 	/*
 	 * We want to touch writable mappings with a write fault in order
 	 * to break COW, except for shared mappings because these don't COW
@@ -185,63 +184,9 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 		nr_pages--;
 	}
 
-	while (nr_pages > 0) {
-		int i;
-
-		cond_resched();
-
-		/*
-		 * get_user_pages makes pages present if we are
-		 * setting mlock. and this extra reference count will
-		 * disable migration of this page.  However, page may
-		 * still be truncated out from under us.
-		 */
-		ret = __get_user_pages(current, mm, addr,
-				min_t(int, nr_pages, ARRAY_SIZE(pages)),
-				gup_flags, pages, NULL);
-		/*
-		 * This can happen for, e.g., VM_NONLINEAR regions before
-		 * a page has been allocated and mapped at a given offset,
-		 * or for addresses that map beyond end of a file.
-		 * We'll mlock the pages if/when they get faulted in.
-		 */
-		if (ret < 0)
-			break;
-
-		lru_add_drain();	/* push cached pages to LRU */
-
-		for (i = 0; i < ret; i++) {
-			struct page *page = pages[i];
-
-			if (page->mapping) {
-				/*
-				 * That preliminary check is mainly to avoid
-				 * the pointless overhead of lock_page on the
-				 * ZERO_PAGE: which might bounce very badly if
-				 * there is contention.  However, we're still
-				 * dirtying its cacheline with get/put_page:
-				 * we'll add another __get_user_pages flag to
-				 * avoid it if that case turns out to matter.
-				 */
-				lock_page(page);
-				/*
-				 * Because we lock page here and migration is
-				 * blocked by the elevated reference, we need
-				 * only check for file-cache page truncation.
-				 */
-				if (page->mapping)
-					mlock_vma_page(page);
-				unlock_page(page);
-			}
-			put_page(page);	/* ref from get_user_pages() */
-		}
-
-		addr += ret * PAGE_SIZE;
-		nr_pages -= ret;
-		ret = 0;
-	}
-
-	return ret;	/* 0 or negative error code */
+	ret = __get_user_pages(current, mm, addr, nr_pages, gup_flags,
+			       NULL, NULL);
+	return max(ret, 0);	/* 0 or negative error code */
 }
 
 /*
-- 
1.7.3.1



-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
