Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AF6E46B0089
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 18:25:43 -0400 (EDT)
Date: Mon, 11 Oct 2010 15:25:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] Retry page fault when blocking on disk transfer.
Message-Id: <20101011152534.6cf01208.akpm@linux-foundation.org>
In-Reply-To: <20101009012204.GA17458@google.com>
References: <1286265215-9025-1-git-send-email-walken@google.com>
	<1286265215-9025-3-git-send-email-walken@google.com>
	<4CAB628D.3030205@redhat.com>
	<AANLkTimdACZ9Xm01DM2+E64+T5XfLffrkFBhf7CJ286p@mail.gmail.com>
	<20101008043956.GA25662@google.com>
	<4CAF1B90.3080703@redhat.com>
	<AANLkTinWxTT=+m_fAudc080OUMwacSefnMbSMBFZgPMH@mail.gmail.com>
	<20101009012204.GA17458@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, 8 Oct 2010 18:22:04 -0700
Michel Lespinasse <walken@google.com> wrote:

> Second try on adding the VM_FAULT_RETRY functionality to the swap in path.
> 
> This proposal would replace [patch 2/3] of this series (the initial
> version of it, which was approved by linus / rik / hpa).
> 
> Changes since the approved version:
> 
> - split lock_page_or_retry() into an inline function in  pagemap.h,
>   handling the trylock_page() fast path, and __lock_page_or_retry() in
>   filemap.c, handling the blocking path (with or without retry).
> 
> - make do_swap_page() call lock_page_or_retry() in place of lock_page(),
>   and handle the retry case.

Replacement patches are a bit cruel to people who've already reviewed
the previous version.  I always turn them into deltas so I can see what
was changed.  It is below.

How well was the new swapin path tested?


 include/linux/pagemap.h |   13 +++++++++++++
 mm/filemap.c            |   35 ++++++++++++++---------------------
 mm/memory.c             |    7 ++++++-
 3 files changed, 33 insertions(+), 22 deletions(-)

diff -puN include/linux/pagemap.h~mm-retry-page-fault-when-blocking-on-disk-transfer-update include/linux/pagemap.h
--- a/include/linux/pagemap.h~mm-retry-page-fault-when-blocking-on-disk-transfer-update
+++ a/include/linux/pagemap.h
@@ -299,6 +299,8 @@ static inline pgoff_t linear_page_index(
 extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
 extern void __lock_page_nosync(struct page *page);
+extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
+				unsigned int flags);
 extern void unlock_page(struct page *page);
 
 static inline void __set_page_locked(struct page *page)
@@ -351,6 +353,17 @@ static inline void lock_page_nosync(stru
 }
 	
 /*
+ * lock_page_or_retry - Lock the page, unless this would block and the
+ * caller indicated that it can handle a retry.
+ */
+static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
+				     unsigned int flags)
+{
+	might_sleep();
+	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
+}
+
+/*
  * This is exported only for wait_on_page_locked/wait_on_page_writeback.
  * Never use this directly!
  */
diff -puN mm/filemap.c~mm-retry-page-fault-when-blocking-on-disk-transfer-update mm/filemap.c
--- a/mm/filemap.c~mm-retry-page-fault-when-blocking-on-disk-transfer-update
+++ a/mm/filemap.c
@@ -623,6 +623,19 @@ void __lock_page_nosync(struct page *pag
 							TASK_UNINTERRUPTIBLE);
 }
 
+int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
+			 unsigned int flags)
+{
+	if (!(flags & FAULT_FLAG_ALLOW_RETRY)) {
+		__lock_page(page);
+		return 1;
+	} else {
+		up_read(&mm->mmap_sem);
+		wait_on_page_locked(page);
+		return 0;
+	}
+}
+
 /**
  * find_get_page - find and get a page reference
  * @mapping: the address_space to search
@@ -1512,26 +1525,6 @@ static void do_async_mmap_readahead(stru
 					   page, offset, ra->ra_pages);
 }
 
-/*
- * Lock the page, unless this would block and the caller indicated that it
- * can handle a retry.
- */
-static int lock_page_or_retry(struct page *page,
-			      struct vm_area_struct *vma, struct vm_fault *vmf)
-{
-	if (trylock_page(page))
-		return 1;
-	if (!(vmf->flags & FAULT_FLAG_ALLOW_RETRY)) {
-		__lock_page(page);
-		return 1;
-	}
-
-	up_read(&vma->vm_mm->mmap_sem);
-	wait_on_page_locked(page);
-	page_cache_release(page);
-	return 0;
-}
-
 /**
  * filemap_fault - read in file data for page fault handling
  * @vma:	vma in which the fault was taken
@@ -1581,7 +1574,7 @@ retry_find:
 			goto no_cached_page;
 	}
 
-	if (!lock_page_or_retry(page, vma, vmf))
+	if (!lock_page_or_retry(page, &vma->vm_mm, vmf->flags))
 		return ret | VM_FAULT_RETRY;
 
 	/* Did it get truncated? */
diff -puN mm/memory.c~mm-retry-page-fault-when-blocking-on-disk-transfer-update mm/memory.c
--- a/mm/memory.c~mm-retry-page-fault-when-blocking-on-disk-transfer-update
+++ a/mm/memory.c
@@ -2627,6 +2627,7 @@ static int do_swap_page(struct mm_struct
 	struct page *page, *swapcache = NULL;
 	swp_entry_t entry;
 	pte_t pte;
+	int locked;
 	struct mem_cgroup *ptr = NULL;
 	int exclusive = 0;
 	int ret = 0;
@@ -2677,8 +2678,12 @@ static int do_swap_page(struct mm_struct
 		goto out_release;
 	}
 
-	lock_page(page);
+	locked = lock_page_or_retry(page, mm, flags);
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+	if (!locked) {
+		ret |= VM_FAULT_RETRY;
+		goto out_release;
+	}
 
 	/*
 	 * Make sure try_to_free_swap or reuse_swap_page or swapoff did not
_



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
