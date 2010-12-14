Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 525C46B0095
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 11:15:16 -0500 (EST)
From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 16/19] Introduce FOLL_DIRTY to follow_page() for "dirty" pages
Date: Tue, 14 Dec 2010 08:15:04 -0800
Message-Id: <1292343307-7870-16-git-send-email-danms@us.ibm.com>
In-Reply-To: <1292343307-7870-1-git-send-email-danms@us.ibm.com>
References: <1292343307-7870-1-git-send-email-danms@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: danms@us.ibm.com
Cc: linux-mm@kvack.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Oren Laadan <orenl@cs.columbia.edu>

This is a preparatory patch necessary for checkpoint/restart (next
two patches) of memory to work correctly.

The patch introduces a new FOLL_DIRTY flag which tells follow_page()
to return -EFAULT also for not-present file-backed pages.

In 2.6.32 follow_page() changes its behavior due to this commit:
	mm: FOLL_DUMP replace FOLL_ANON
 	8e4b9a60718970bbc02dfd3abd0b956ab65af231

Also introduce __get_dirty_page() that returns a page only if it's
"dirty", that is that has been modified before, and otherwise returns
NULL. It uses FOLL_DUMP | FOLL_DIRTY and converts the error value
EFAULT to NULL - telling the caller that the page in question is
clean.

(This also optimizes for checkpoint in the next patch: before, if a
file-backed page was not-present we would first fault it in (read from
disk) and then detect that it was virgin. Instead, now we detect that
the page is clean earlier without needing to fault it in).

To see why it's needed, consider these scenarios:

1. Task maps a file beyond it's limit, never touches those
 extra page (if it did, it would get EFAULT/Bus error)

2. Task maps a file and writes the last page, then the file gets
 truncated (by at least a page). A subsequent access to the page will
 cause bus error (VM_FAULT_SIGBUS).

3. If the file size is extended back (using truncate) and the task
 accesses that page, then the task will get a fresh page (losing data
 it had written to that address before).

[Before kernel 2.6.32, that page would become anonymous once it was
dirtied, such that accesses in case #2 are valid, and in case #3 the
task would see the old page regardless of the file contents.]

--CHECKPOINT: before we used FOLL_ANON flags to tell follow_page() to
return the zero-page for case#1. For case#2, the actual page was
returned. Without this patch, In kernel 2.3.32, FOLL_DUMP would make
follow_page() return NULL and then fault handler would have returned
VM_FAULT_SIGBUS in case#1 (and depending on arch, case#2 too), and
checkpoint would fails.

--RESTART: case #1 works, because mmap() works as before, and those
pages that were never touched will not be restored either, they will
remain untouched. The same holds for case#2 (as of kernel 2.6.32),
because at checkpoint it would decide that the page is clean and not
save the contents, and therefore it will not try to restore the
contents at restart. This is consistent with the expected behavior
after restart: if the file remains as is, subsequent accesses will
trigger a bus error, and if the file is extended, then the user will
observe a fresh page.

Cc: linux-mm@kvack.org
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/mm.h |    2 +
 mm/memory.c        |   95 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 96 insertions(+), 1 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fcd60ba..2211a15 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -866,6 +866,7 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
 struct page *get_dump_page(unsigned long addr);
+struct page *__get_dirty_page(struct vm_area_struct *vma, unsigned long addr);
 
 extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
 extern void do_invalidatepage(struct page *page, unsigned long offset);
@@ -1420,6 +1421,7 @@ struct page *follow_page(struct vm_area_struct *, unsigned long address,
 #define FOLL_GET	0x04	/* do get_page on page */
 #define FOLL_DUMP	0x08	/* give error on hole if it would be zero */
 #define FOLL_FORCE	0x10	/* get_user_pages read/write w/o permission */
+#define FOLL_DIRTY	0x20	/* give error on non-present file mapped */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
diff --git a/mm/memory.c b/mm/memory.c
index 02e48aa..3784d4a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1321,8 +1321,17 @@ bad_page:
 
 no_page:
 	pte_unmap_unlock(ptep, ptl);
-	if (!pte_none(pte))
+	if (!pte_none(pte)) {
+		/*
+		 * When checkpointing we only care about dirty pages.
+		 * If a file-backed page is missing, then return an
+		 * error to tell __get_dirty_page() that it's clean,
+		 * so it won't try to demand page it into memory.
+		 */
+		if ((flags & FOLL_DIRTY) && pte_file(pte))
+			page = ERR_PTR(-EFAULT);
 		return page;
+	}
 
 no_page_table:
 	/*
@@ -1336,6 +1345,16 @@ no_page_table:
 	if ((flags & FOLL_DUMP) &&
 	    (!vma->vm_ops || !vma->vm_ops->fault))
 		return ERR_PTR(-EFAULT);
+
+	/*
+	 * When checkpointing we only care about dirty pages. If there
+	 * is no page table for a non-anonymous page, we return an
+	 * error to tell __get_dirty_page() that the page is clean, so
+	 * it won't allocate page tables and the page unnecessarily.
+	 */
+	if ((flags & FOLL_DIRTY) && vma->vm_ops)
+		return ERR_PTR(-EFAULT);
+
 	return page;
 }
 
@@ -1604,6 +1623,80 @@ pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
 	return NULL;
 }
 
+/**
+ * __get_dirty_page - return page pointer for dirty user page
+ * @vma - target vma
+ * @addr - page address
+ *
+ * Looks up the page that correspond to the address in the vma, and
+ * return the page if it was modified (and grabs a reference to it),
+ * or otherwise returns NULL or error.
+ *
+ * Should only be called for private vma.
+ * Must be called with mmap_sem held for read or write.
+ */
+struct page *__get_dirty_page(struct vm_area_struct *vma, unsigned long addr)
+{
+	struct page *page;
+
+	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+
+	/*
+	 * FOLL_DUMP tells follow_page() to return -EFAULT for either
+	 * non-present anonymous pages, or memory "holes".
+	 * FOLL_DIRTY tells follow_page() to return -EFAULT also for
+	 * non-present file-mapped pages.
+	 * Otherwise, follow_page() returns the page, or NULL if the
+	 * page is swapped out.
+	 */
+
+	cond_resched();
+	while (!(page = follow_page(vma, addr,
+				    FOLL_GET | FOLL_DUMP | FOLL_DIRTY))) {
+		int ret;
+
+		/* the page is swapped out - bring it in (optimize ?) */
+		ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
+		if (ret & VM_FAULT_ERROR) {
+			if (ret & VM_FAULT_OOM)
+				return ERR_PTR(-ENOMEM);
+			else if (ret & VM_FAULT_SIGBUS)
+				return ERR_PTR(-EFAULT);
+			else
+				BUG();
+			break;
+		}
+		cond_resched();
+	}
+
+	/* -EFAULT means that the page is clean (see above) */
+	if (PTR_ERR(page) == -EFAULT)
+		return NULL;
+	else if (IS_ERR(page))
+		return page;
+
+	/*
+	 * Only care about dirty pages: either anonymous non-zero pages,
+	 * or file-backed COW (copy-on-write) pages that were modified.
+	 * A clean COW page is not interesting because its contents are
+	 * identical to the backing file; ignore such pages.
+	 * A file-backed broken COW is identified by its page_mapping()
+	 * being unset (NULL) because the page will no longer be mapped
+	 * to the original file after having been modified.
+	 */
+	if (is_zero_pfn(page_to_pfn(page))) {
+		/* this is the zero page: ignore */
+		page_cache_release(page);
+		page = NULL;
+	} else if (vma->vm_file && (page_mapping(page) != NULL)) {
+		/* file backed clean cow: ignore */
+		page_cache_release(page);
+		page = NULL;
+	}
+
+	return page;
+}
+
 /*
  * This is the old fallback for page remapping.
  *
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
