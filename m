Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 276166B029E
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 06:02:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p190so63480074wmp.3
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 03:02:54 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id o83si23314256wmb.123.2016.10.31.03.02.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 03:02:52 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id 68so10904408wmz.2
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 03:02:52 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH 2/2] mm: remove get_user_pages_locked()
Date: Mon, 31 Oct 2016 10:02:28 +0000
Message-Id: <20161031100228.17917-3-lstoakes@gmail.com>
In-Reply-To: <20161031100228.17917-1-lstoakes@gmail.com>
References: <20161031100228.17917-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, linux-kernel@vger.kernel.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, kvm@vger.kernel.org, linux-media@vger.kernel.org, devel@driverdev.osuosl.org, Lorenzo Stoakes <lstoakes@gmail.com>

get_user_pages() now has an int *locked parameter which renders
get_user_pages_locked() redundant, so remove it.

This patch should not introduce any functional changes.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 include/linux/mm.h |  2 --
 mm/frame_vector.c  |  4 ++--
 mm/gup.c           | 56 +++++++++++++++++++-----------------------------------
 mm/nommu.c         |  8 --------
 4 files changed, 22 insertions(+), 48 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 396984e..4db3147 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1278,8 +1278,6 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
 			    struct vm_area_struct **vmas, int *locked);
-long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-		    unsigned int gup_flags, struct page **pages, int *locked);
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 			       unsigned long start, unsigned long nr_pages,
 			       struct page **pages, unsigned int gup_flags);
diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index db77dcb..c5ce1b1 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -55,8 +55,8 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
 		vec->got_ref = true;
 		vec->is_pfns = false;
-		ret = get_user_pages_locked(start, nr_frames,
-			gup_flags, (struct page **)(vec->ptrs), &locked);
+		ret = get_user_pages(start, nr_frames,
+			gup_flags, (struct page **)(vec->ptrs), NULL, &locked);
 		goto out;
 	}
 
diff --git a/mm/gup.c b/mm/gup.c
index 6b5539e..6cec693 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -826,37 +826,6 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 }
 
 /*
- * We can leverage the VM_FAULT_RETRY functionality in the page fault
- * paths better by using either get_user_pages_locked() or
- * get_user_pages_unlocked().
- *
- * get_user_pages_locked() is suitable to replace the form:
- *
- *      down_read(&mm->mmap_sem);
- *      do_something()
- *      get_user_pages(tsk, mm, ..., pages, NULL, NULL);
- *      up_read(&mm->mmap_sem);
- *
- *  to:
- *
- *      int locked = 1;
- *      down_read(&mm->mmap_sem);
- *      do_something()
- *      get_user_pages_locked(tsk, mm, ..., pages, &locked);
- *      if (locked)
- *          up_read(&mm->mmap_sem);
- */
-long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-			   unsigned int gup_flags, struct page **pages,
-			   int *locked)
-{
-	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       pages, NULL, locked, true,
-				       gup_flags | FOLL_TOUCH);
-}
-EXPORT_SYMBOL(get_user_pages_locked);
-
-/*
  * Same as get_user_pages_unlocked(...., FOLL_TOUCH) but it allows to
  * pass additional gup_flags as last parameter (like FOLL_HWPOISON).
  *
@@ -954,11 +923,6 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
  * use the correct cache flushing APIs.
  *
  * See also get_user_pages_fast, for performance critical applications.
- *
- * get_user_pages should be phased out in favor of
- * get_user_pages_locked|unlocked or get_user_pages_fast. Nothing
- * should use get_user_pages because it cannot pass
- * FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.
  */
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
@@ -976,6 +940,26 @@ EXPORT_SYMBOL(get_user_pages_remote);
  * less-flexible calling convention where we assume that the task
  * and mm being operated on are the current task's.  We also
  * obviously don't pass FOLL_REMOTE in here.
+ *
+ * We can leverage the VM_FAULT_RETRY functionality in the page fault
+ * paths better by using either get_user_pages()'s locked parameter or
+ * get_user_pages_unlocked().
+ *
+ * get_user_pages()'s locked parameter is suitable to replace the form:
+ *
+ *      down_read(&mm->mmap_sem);
+ *      do_something()
+ *      get_user_pages(tsk, mm, ..., pages, NULL, NULL);
+ *      up_read(&mm->mmap_sem);
+ *
+ *  to:
+ *
+ *      int locked = 1;
+ *      down_read(&mm->mmap_sem);
+ *      do_something()
+ *      get_user_pages(tsk, mm, ..., pages, NULL, &locked);
+ *      if (locked)
+ *          up_read(&mm->mmap_sem);
  */
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
diff --git a/mm/nommu.c b/mm/nommu.c
index 82aaa33..3d38d40 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -168,14 +168,6 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 }
 EXPORT_SYMBOL(get_user_pages);
 
-long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-			    unsigned int gup_flags, struct page **pages,
-			    int *locked)
-{
-	return get_user_pages(start, nr_pages, gup_flags, pages, NULL, NULL);
-}
-EXPORT_SYMBOL(get_user_pages_locked);
-
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 			       unsigned long start, unsigned long nr_pages,
 			       struct page **pages, unsigned int gup_flags)
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
