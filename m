Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 625826B0008
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 02:17:20 -0500 (EST)
Received: by mail-da0-f49.google.com with SMTP id v40so2526714dad.8
        for <linux-mm@kvack.org>; Sun, 03 Feb 2013 23:17:19 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 2/3] mm: accelerate mm_populate() treatment of THP pages
Date: Sun,  3 Feb 2013 23:17:11 -0800
Message-Id: <1359962232-20811-3-git-send-email-walken@google.com>
In-Reply-To: <1359962232-20811-1-git-send-email-walken@google.com>
References: <1359962232-20811-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

This change adds a follow_page_mask function which is equivalent to
follow_page, but with an extra page_mask argument.

follow_page_mask sets *page_mask to HPAGE_PMD_NR - 1 when it encounters a
THP page, and to 0 in other cases.

__get_user_pages() makes use of this in order to accelerate populating
THP ranges - that is, when both the pages and vmas arrays are NULL,
we don't need to iterate HPAGE_PMD_NR times to cover a single THP page
(and we also avoid taking mm->page_table_lock that many times).

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 include/linux/mm.h | 13 +++++++++++--
 mm/memory.c        | 31 +++++++++++++++++++++++--------
 mm/nommu.c         |  6 ++++--
 3 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3d9fbcf9fa94..31e4d42002ee 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1636,8 +1636,17 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 
-struct page *follow_page(struct vm_area_struct *, unsigned long address,
-			unsigned int foll_flags);
+struct page *follow_page_mask(struct vm_area_struct *vma,
+			      unsigned long address, unsigned int foll_flags,
+			      unsigned int *page_mask);
+
+static inline struct page *follow_page(struct vm_area_struct *vma,
+		unsigned long address, unsigned int foll_flags)
+{
+	unsigned int unused_page_mask;
+	return follow_page_mask(vma, address, foll_flags, &unused_page_mask);
+}
+
 #define FOLL_WRITE	0x01	/* check pte is writable */
 #define FOLL_TOUCH	0x02	/* mark page accessed */
 #define FOLL_GET	0x04	/* do get_page on page */
diff --git a/mm/memory.c b/mm/memory.c
index f0b6b2b798c4..52c8599e7fe4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1458,10 +1458,11 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 EXPORT_SYMBOL_GPL(zap_vma_ptes);
 
 /**
- * follow_page - look up a page descriptor from a user-virtual address
+ * follow_page_mask - look up a page descriptor from a user-virtual address
  * @vma: vm_area_struct mapping @address
  * @address: virtual address to look up
  * @flags: flags modifying lookup behaviour
+ * @page_mask: on output, *page_mask is set according to the size of the page
  *
  * @flags can have FOLL_ flags set, defined in <linux/mm.h>
  *
@@ -1469,8 +1470,9 @@ EXPORT_SYMBOL_GPL(zap_vma_ptes);
  * an error pointer if there is a mapping to something not represented
  * by a page descriptor (see also vm_normal_page()).
  */
-struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
-			unsigned int flags)
+struct page *follow_page_mask(struct vm_area_struct *vma,
+			      unsigned long address, unsigned int flags,
+			      unsigned int *page_mask)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -1480,6 +1482,8 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
 
+	*page_mask = 0;
+
 	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
 	if (!IS_ERR(page)) {
 		BUG_ON(flags & FOLL_GET);
@@ -1526,6 +1530,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 				page = follow_trans_huge_pmd(vma, address,
 							     pmd, flags);
 				spin_unlock(&mm->page_table_lock);
+				*page_mask = HPAGE_PMD_NR - 1;
 				goto out;
 			}
 		} else
@@ -1680,6 +1685,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 {
 	long i;
 	unsigned long vm_flags;
+	unsigned int page_mask;
 
 	if (!nr_pages)
 		return 0;
@@ -1757,6 +1763,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				get_page(page);
 			}
 			pte_unmap(pte);
+			page_mask = 0;
 			goto next_page;
 		}
 
@@ -1774,6 +1781,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		do {
 			struct page *page;
 			unsigned int foll_flags = gup_flags;
+			unsigned int page_increm;
 
 			/*
 			 * If we have a pending SIGKILL, don't keep faulting
@@ -1783,7 +1791,8 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				return i ? i : -ERESTARTSYS;
 
 			cond_resched();
-			while (!(page = follow_page(vma, start, foll_flags))) {
+			while (!(page = follow_page_mask(vma, start,
+						foll_flags, &page_mask))) {
 				int ret;
 				unsigned int fault_flags = 0;
 
@@ -1857,13 +1866,19 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 
 				flush_anon_page(vma, page, start);
 				flush_dcache_page(page);
+				page_mask = 0;
 			}
 next_page:
-			if (vmas)
+			if (vmas) {
 				vmas[i] = vma;
-			i++;
-			start += PAGE_SIZE;
-			nr_pages--;
+				page_mask = 0;
+			}
+			page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
+			if (page_increm > nr_pages)
+				page_increm = nr_pages;
+			i += page_increm;
+			start += page_increm * PAGE_SIZE;
+			nr_pages -= page_increm;
 		} while (nr_pages && start < vma->vm_end);
 	} while (nr_pages);
 	return i;
diff --git a/mm/nommu.c b/mm/nommu.c
index 429a3d5217fa..9a6a25181267 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1817,9 +1817,11 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	return ret;
 }
 
-struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
-			unsigned int foll_flags)
+struct page *follow_page_mask(struct vm_area_struct *vma,
+			      unsigned long address, unsigned int flags,
+			      unsigned int *page_mask)
 {
+	*page_mask = 0;
 	return NULL;
 }
 
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
