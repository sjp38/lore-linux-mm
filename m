Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7896B006C
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 06:28:02 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so34698952pab.3
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 03:28:01 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id gq6si230633pbc.111.2015.02.16.03.27.58
        for <linux-mm@kvack.org>;
        Mon, 16 Feb 2015 03:27:58 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 1/4] mm: rename FOLL_MLOCK to FOLL_POPULATE
Date: Mon, 16 Feb 2015 13:27:51 +0200
Message-Id: <1424086074-200683-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424086074-200683-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424086074-200683-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michel Lespinasse <walken@google.com>

After commit a1fde08c74e9 FOLL_MLOCK has lost its original meaning: we
don't necessarily mlock the page if the flags is set -- we also take
VM_LOCKED into consideration.

Since we use the same codepath for __mm_populate(), let's rename
FOLL_MLOCK to FOLL_POPULATE.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: David Rientjes <rientjes@google.com>
Cc: Michel Lespinasse <walken@google.com>
---
 include/linux/mm.h | 2 +-
 mm/gup.c           | 6 +++---
 mm/huge_memory.c   | 2 +-
 mm/mlock.c         | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a09837f3f4b7..2dbf6f0f6e5b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2110,7 +2110,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 #define FOLL_FORCE	0x10	/* get_user_pages read/write w/o permission */
 #define FOLL_NOWAIT	0x20	/* if a disk transfer is needed, start the IO
 				 * and return without waiting upon it */
-#define FOLL_MLOCK	0x40	/* mark page as mlocked */
+#define FOLL_POPULATE	0x40	/* fault in page */
 #define FOLL_SPLIT	0x80	/* don't return transhuge pages, split them */
 #define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
 #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
diff --git a/mm/gup.c b/mm/gup.c
index a6e24e246f86..1b114ba9aebf 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -92,7 +92,7 @@ retry:
 		 */
 		mark_page_accessed(page);
 	}
-	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
+	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
 		/*
 		 * The preliminary mapping check is mainly to avoid the
 		 * pointless overhead of lock_page on the ZERO_PAGE
@@ -265,8 +265,8 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	unsigned int fault_flags = 0;
 	int ret;
 
-	/* For mlock, just skip the stack guard page. */
-	if ((*flags & FOLL_MLOCK) &&
+	/* For mm_populate(), just skip the stack guard page. */
+	if ((*flags & FOLL_POPULATE) &&
 			(stack_guard_page_start(vma, address) ||
 			 stack_guard_page_end(vma, address + PAGE_SIZE)))
 		return -ENOENT;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e08e37ad050e..bc8d351026a9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1231,7 +1231,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  pmd, _pmd,  1))
 			update_mmu_cache_pmd(vma, addr, pmd);
 	}
-	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
+	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
 		if (page->mapping && trylock_page(page)) {
 			lru_add_drain();
 			if (page->mapping)
diff --git a/mm/mlock.c b/mm/mlock.c
index 73cf0987088c..7712d8ab6fe5 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -237,7 +237,7 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
 	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
 
-	gup_flags = FOLL_TOUCH | FOLL_MLOCK;
+	gup_flags = FOLL_TOUCH | FOLL_POPULATE;
 	/*
 	 * We want to touch writable mappings with a write fault in order
 	 * to break COW, except for shared mappings because these don't COW
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
