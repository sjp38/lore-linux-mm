Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDE66B006E
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:48:38 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id j15so2350867qaq.40
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id h74si35628550qgd.79.2014.06.12.14.48.37
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 14:48:37 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v2 08/11] pagewalk: update comment on walk_page_range()
Date: Thu, 12 Jun 2014 17:48:08 -0400
Message-Id: <1402609691-13950-9-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

Rewriting common code of page table walker has been done, so this patch
updates the comment on walk_page_range() for the future development.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/pagewalk.c | 55 +++++++++++++++++++++++++++----------------------------
 1 file changed, 27 insertions(+), 28 deletions(-)

diff --git mmotm-2014-05-21-16-57.orig/mm/pagewalk.c mmotm-2014-05-21-16-57/mm/pagewalk.c
index b46c8882c643..626a80d4d9dd 100644
--- mmotm-2014-05-21-16-57.orig/mm/pagewalk.c
+++ mmotm-2014-05-21-16-57/mm/pagewalk.c
@@ -253,39 +253,38 @@ static int __walk_page_range(unsigned long start, unsigned long end,
  * walk_page_range - walk page table with caller specific callbacks
  *
  * Recursively walk the page table tree of the process represented by
- * @walk->mm within the virtual address range [@start, @end). In walking,
- * we can call caller-specific callback functions against each entry.
+ * @walk->mm within the virtual address range [@start, @end). During walking,
+ * we can call caller-specific callback functions against each leaf entry.
  *
  * Before starting to walk page table, some callers want to check whether
- * they really want to walk over the vma (for example by checking vm_flags.)
- * walk_page_test() and @walk->test_walk() do that check.
+ * they really want to walk over the current vma, typically by checking
+ * its vm_flags. walk_page_test() and @walk->test_walk() are used for this
+ * purpose.
  *
- * If any callback returns a non-zero value, the page table walk is aborted
- * immediately and the return value is propagated back to the caller.
- * Note that the meaning of the positive returned value can be defined
- * by the caller for its own purpose.
+ * Currently we have three types of possible leaf enties, pte (for normal
+ * pages,) pmd (for thps,) and hugetlb. We handle these three with pte_entry(),
+ * pmd_entry(), and hugetlb_entry(), respectively.
+ * If you don't set any function to some of these callbacks, the associated
+ * entries/pages are ignored.
+ * The return values of these three callbacks are commonly defined like below:
+ *  - 0  : succeeded to handle the current entry, and if you don't reach the
+ *         end address yet, continue to walk.
+ *  - >0 : succeeded to handle the current entry, and return to the caller
+ *         with caller specific value.
+ *  - <0 : failed to handle the current entry, and return to the caller
+ *         with error code.
+ * We can set the same function to different callbacks, where @walk->size
+ * should be helpful to know the type of entry in callbacks.
  *
- * If the caller defines multiple callbacks in different levels, the
- * callbacks are called in depth-first manner. It could happen that
- * multiple callbacks are called on a address. For example if some caller
- * defines test_walk(), pmd_entry(), and pte_entry(), then callbacks are
- * called in the order of test_walk(), pmd_entry(), and pte_entry().
- * If you don't want to go down to lower level at some point and move to
- * the next entry in the same level, you set @walk->skip to 1.
- * For example if you succeed to handle some pmd entry as trans_huge entry,
- * you need not call walk_pte_range() any more, so set it to avoid that.
- * We can't determine whether to go down to lower level with the return
- * value of the callback, because the whole range of return values (0, >0,
- * and <0) are used up for other meanings.
+ * struct mm_walk keeps current values of some common data like vma and pmd,
+ * which are useful for the access from callbacks. If you want to pass some
+ * caller-specific data to callbacks, @walk->private should be helpful.
  *
- * Each callback can access to the vma over which it is doing page table
- * walk right now via @walk->vma. @walk->vma is set to NULL in walking
- * outside a vma. If you want to access to some caller-specific data from
- * callbacks, @walk->private should be helpful.
- *
- * The callers should hold @walk->mm->mmap_sem. Note that the lower level
- * iterators can take page table lock in lowest level iteration and/or
- * in split_huge_page_pmd().
+ * Locking:
+ *   Callers of walk_page_range() and walk_page_vma() should hold
+ *   @walk->mm->mmap_sem, because these function traverse vma list and/or
+ *   access to vma's data. And page table lock is held during running
+ *   pmd_entry(), pte_entry(), and hugetlb_entry().
  */
 int walk_page_range(unsigned long start, unsigned long end,
 		    struct mm_walk *walk)
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
