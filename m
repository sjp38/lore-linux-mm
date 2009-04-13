Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 039C45F0001
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 15:47:09 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n3DJlpVh016331
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 12:47:52 -0700
Received: from yw-out-1718.google.com (ywk9.prod.google.com [10.192.11.9])
	by spaceape11.eur.corp.google.com with ESMTP id n3DJlnHN006538
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 12:47:49 -0700
Received: by yw-out-1718.google.com with SMTP id 9so1281046ywk.82
        for <linux-mm@kvack.org>; Mon, 13 Apr 2009 12:47:49 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 13 Apr 2009 12:47:48 -0700
Message-ID: <604427e00904131247i6cce8c4epcfa14f499a3c2fb@mail.gmail.com>
Subject: [v4][PATCH 3/4]Add VM_FAULT_RETRY support
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>, torvalds@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Add VM_FAULT_RETRY support

Allow major faults to drop the mmap_sem read lock while waiting for
synchronous disk read. This allows another thread which wishes to grab
down_write(mmap_sem) to proceed while the current is waiting the disk IO.

Singed-off-by: Mike Waychison <mikew@google.com>
Signed-off-by: Ying Han <yinghan@google.com>
---

 include/linux/mm.h |    2 +
 mm/filemap.c       |   86 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 mm/memory.c        |    8 +++++
 3 files changed, 93 insertions(+), 3 deletions(-)


diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9d22a5e..3ab6a50 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -134,6 +134,7 @@ extern pgprot_t protection_map[16];

 #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
 #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
+#define FAULT_FLAG_RETRY	0x04	/* Retry major fault */

 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
@@ -696,6 +697,7 @@ static inline int page_mapped(struct page *page)

 #define VM_FAULT_MINOR	0 /* For backwards compat. Remove me quickly. */

+#define VM_FAULT_RETRY	0x0010
 #define VM_FAULT_OOM	0x0001
 #define VM_FAULT_SIGBUS	0x0002
 #define VM_FAULT_MAJOR	0x0004
diff --git a/mm/filemap.c b/mm/filemap.c
index 23acefe..c5088f3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -714,6 +714,72 @@ repeat:
 EXPORT_SYMBOL(find_lock_page);

 /**
+ * find_lock_page_retry - locate, pin and lock a pagecache page
+ * @mapping: the address_space to search
+ * @offset: the page index
+ * @vma: vma in which the fault was taken
+ * @ppage: zero if page not present, otherwise point to the page in pagecache
+ * @retry: 1 indicate caller tolerate a retry.
+ *
+ * If retry flag is on, and page is already locked by someone else, return
+ * a hint of retry and leave *ppage untouched.
+ *
+ * If the page was not found in pagecache, find_lock_page_retry()
+ * returns 0 and sets *@ppage to NULL.
+ *
+ * If the page was found in pagecache but is locked and @retry is
+ * true, find_lock_page_retry() returns VM_FAULT_RETRY and does not
+ * write to *@ppage.
+ *
+ * If the page was found in pagecache and @retry is false,
+ * find_lock_page_retry() locks the page, writes its address to *@ppage
+ * and returns 0.
+ */
+unsigned find_lock_page_retry(struct address_space *mapping, pgoff_t offset,
+				struct vm_area_struct *vma, struct page **ppage,
+				int retry)
+{
+	unsigned int ret = 0;
+	struct page *page;
+
+repeat:
+	page = find_get_page(mapping, offset);
+	if (page) {
+		if (!retry)
+			lock_page(page);
+		else {
+			if (!trylock_page(page)) {
+				struct mm_struct *mm = vma->vm_mm;
+
+				/* Page is already locked by someone else
+				 *
+				 * We don't want to holding
+				 * down_read(mmap_sem) inside lock_page().
+				 * We use wait_on_page_lock here to just
+				 * wait until the page is unlocked, but we
+				 * don't really need to lock the page.
+				 */
+				up_read(&mm->mmap_sem);
+				wait_on_page_locked(page);
+				down_read(&mm->mmap_sem);
+
+				page_cache_release(page);
+				return VM_FAULT_RETRY;
+			}
+		}
+		if (unlikely(page->mapping != mapping)) {
+			unlock_page(page);
+			page_cache_release(page);
+			goto repeat;
+		}
+		VM_BUG_ON(page->index != offset);
+	}
+	*ppage = page;
+	return ret;
+}
+EXPORT_SYMBOL(find_lock_page_retry);
+
+/**
  * find_or_create_page - locate or add a pagecache page
  * @mapping: the page's address_space
  * @index: the page's index into the mapping
@@ -1459,6 +1525,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fa
 	pgoff_t size;
 	int did_readaround = 0;
 	int ret = 0;
+	int retry_flag = vmf->flags & FAULT_FLAG_RETRY;
+	int retry_ret;

 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (vmf->pgoff >= size)
@@ -1473,6 +1541,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fa
 	 */
 retry_find:
 	page = find_lock_page(mapping, vmf->pgoff);
+
 	/*
 	 * For sequential accesses, we use the generic readahead logic.
 	 */
@@ -1480,7 +1549,12 @@ retry_find:
 		if (!page) {
 			page_cache_sync_readahead(mapping, ra, file,
 							   vmf->pgoff, 1);
-			page = find_lock_page(mapping, vmf->pgoff);
+			retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
+						vma, &page, retry_flag);
+			if (retry_ret == VM_FAULT_RETRY) {
+				ra->mmap_miss++;
+				return retry_ret;
+			}
 			if (!page)
 				goto no_cached_page;
 		}
@@ -1519,7 +1593,13 @@ retry_find:
 				start = vmf->pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
-		page = find_lock_page(mapping, vmf->pgoff);
+retry_find_retry:
+		retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
+				vma, &page, retry_flag);
+		if (retry_ret == VM_FAULT_RETRY) {
+			ra->mmap_miss++; /* counteract the followed retry hit */
+			return retry_ret;
+		}
 		if (!page)
 			goto no_cached_page;
 	}
@@ -1562,7 +1642,7 @@ no_cached_page:
 	 * meantime, we'll just come back here and read it again.
 	 */
 	if (error >= 0)
-		goto retry_find;
+		goto retry_find_retry;

 	/*
 	 * An error return from page_cache_read can result if the
diff --git a/mm/memory.c b/mm/memory.c
index 98fcc63..d76d88c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2595,6 +2595,14 @@ static int __do_fault(struct mm_struct *mm, struct vm_are
 	vmf.page = NULL;

 	ret = vma->vm_ops->fault(vma, &vmf);
+
+	/*
+	 * page may be available, but we have to restart the process
+	 * because mmap_sem was dropped during the ->fault
+	 */
+	if (ret == VM_FAULT_RETRY)
+		return ret;
+
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
 		return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
