Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2CB3E6B0083
	for <linux-mm@kvack.org>; Sat,  5 Sep 2009 17:23:04 -0400 (EDT)
Date: Sat, 5 Sep 2009 22:22:23 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 1/3] ksm: clean up obsolete references
Message-ID: <Pine.LNX.4.64.0909052219580.7381@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

A few cleanups, given the munlock fix: the comment on ksm_test_exit()
no longer applies, and it can be made private to ksm.c; there's no
more reference to mmu_gather or tlb.h, and mmap.c doesn't need ksm.h.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/ksm.h |   20 --------------------
 mm/ksm.c            |   14 +++++++++++++-
 mm/mmap.c           |    1 -
 3 files changed, 13 insertions(+), 22 deletions(-)

--- mmotm/include/linux/ksm.h	2009-09-05 14:40:16.000000000 +0100
+++ linux/include/linux/ksm.h	2009-09-05 16:41:55.000000000 +0100
@@ -12,8 +12,6 @@
 #include <linux/sched.h>
 #include <linux/vmstat.h>
 
-struct mmu_gather;
-
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags);
@@ -27,19 +25,6 @@ static inline int ksm_fork(struct mm_str
 	return 0;
 }
 
-/*
- * For KSM to handle OOM without deadlock when it's breaking COW in a
- * likely victim of the OOM killer, exit_mmap() has to serialize with
- * ksm_exit() after freeing mm's pages but before freeing its page tables.
- * That leaves a window in which KSM might refault pages which have just
- * been finally unmapped: guard against that with ksm_test_exit(), and
- * use it after getting mmap_sem in ksm.c, to check if mm is exiting.
- */
-static inline bool ksm_test_exit(struct mm_struct *mm)
-{
-	return atomic_read(&mm->mm_users) == 0;
-}
-
 static inline void ksm_exit(struct mm_struct *mm)
 {
 	if (test_bit(MMF_VM_MERGEABLE, &mm->flags))
@@ -78,11 +63,6 @@ static inline int ksm_fork(struct mm_str
 {
 	return 0;
 }
-
-static inline bool ksm_test_exit(struct mm_struct *mm)
-{
-	return 0;
-}
 
 static inline void ksm_exit(struct mm_struct *mm)
 {
--- mmotm/mm/ksm.c	2009-09-05 14:40:16.000000000 +0100
+++ linux/mm/ksm.c	2009-09-05 16:41:55.000000000 +0100
@@ -32,7 +32,6 @@
 #include <linux/mmu_notifier.h>
 #include <linux/ksm.h>
 
-#include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
 /*
@@ -285,6 +284,19 @@ static inline int in_stable_tree(struct
 }
 
 /*
+ * ksmd, and unmerge_and_remove_all_rmap_items(), must not touch an mm's
+ * page tables after it has passed through ksm_exit() - which, if necessary,
+ * takes mmap_sem briefly to serialize against them.  ksm_exit() does not set
+ * a special flag: they can just back out as soon as mm_users goes to zero.
+ * ksm_test_exit() is used throughout to make this test for exit: in some
+ * places for correctness, in some places just to avoid unnecessary work.
+ */
+static inline bool ksm_test_exit(struct mm_struct *mm)
+{
+	return atomic_read(&mm->mm_users) == 0;
+}
+
+/*
  * We use break_ksm to break COW on a ksm page: it's a stripped down
  *
  *	if (get_user_pages(current, mm, addr, 1, 1, 1, &page, NULL) == 1)
--- mmotm/mm/mmap.c	2009-09-05 14:40:16.000000000 +0100
+++ linux/mm/mmap.c	2009-09-05 16:41:55.000000000 +0100
@@ -27,7 +27,6 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
-#include <linux/ksm.h>
 #include <linux/mmu_notifier.h>
 #include <linux/perf_counter.h>
 #include <linux/hugetlb.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
