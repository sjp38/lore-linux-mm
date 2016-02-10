Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C59EE828DF
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 13:10:04 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id q63so15674056pfb.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 10:10:04 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id gj3si6413443pac.243.2016.02.10.10.10.03
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 10:10:03 -0800 (PST)
Subject: [PATCH 2/3] mm: overload get_user_pages() functions
From: Dave Hansen <dave@sr71.net>
Date: Wed, 10 Feb 2016 10:10:02 -0800
References: <20160210181000.886CDF18@viggo.jf.intel.com>
In-Reply-To: <20160210181000.886CDF18@viggo.jf.intel.com>
Message-Id: <20160210181002.36462C0B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz


From: Dave Hansen <dave.hansen@linux.intel.com>

The concept here was a suggestion from Ingo.  The implementation
horrors are all mine.

This allows get_user_pages(), get_user_pages_unlocked(), and
get_user_pages_locked() to be called with or without the
leading tsk/mm arguments.  We will give a compile-time warning
about the old style being __deprecated and we will also
WARN_ON() if the non-remote version is used for a remote-style
access.

Doing this, folks will get nice warnings and will not break the
build.  This should be nice for -next and will hopefully let
developers fix up their own code instead of maintainers needing
to do it at merge time.

The way we do this is hideous.  It uses the __VA_ARGS__ macro
functionality to call different functions based on the number
of arguments passed to the macro.

There's an additional hack to ensure that our EXPORT_SYMBOL()
of the deprecated symbols doesn't trigger a warning.

We should be able to remove this mess as soon as -rc1 hits in
the release after this is merged.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: jack@suse.cz
---

 b/include/linux/mm.h |   77 ++++++++++++++++++++++++++++++++++++++++++++-------
 b/mm/gup.c           |   62 +++++++++++++++++++++++++++++++----------
 b/mm/nommu.c         |   64 +++++++++++++++++++++++++++++-------------
 b/mm/util.c          |    4 --
 4 files changed, 161 insertions(+), 46 deletions(-)

diff -puN include/linux/mm.h~gup-arg-helpers include/linux/mm.h
--- a/include/linux/mm.h~gup-arg-helpers	2016-02-10 10:09:00.817307941 -0800
+++ b/include/linux/mm.h	2016-02-10 10:09:00.826308355 -0800
@@ -1229,24 +1229,81 @@ long get_user_pages_remote(struct task_s
 			    unsigned long start, unsigned long nr_pages,
 			    int write, int force, struct page **pages,
 			    struct vm_area_struct **vmas);
-long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		    unsigned long start, unsigned long nr_pages,
-		    int write, int force, struct page **pages,
-		    struct vm_area_struct **vmas);
-long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
-		    unsigned long start, unsigned long nr_pages,
-		    int write, int force, struct page **pages,
-		    int *locked);
+long get_user_pages6(unsigned long start, unsigned long nr_pages,
+			    int write, int force, struct page **pages,
+			    struct vm_area_struct **vmas);
+long get_user_pages_locked6(unsigned long start, unsigned long nr_pages,
+		    int write, int force, struct page **pages, int *locked);
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 			       unsigned long start, unsigned long nr_pages,
 			       int write, int force, struct page **pages,
 			       unsigned int gup_flags);
-long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
-		    unsigned long start, unsigned long nr_pages,
+long get_user_pages_unlocked5(unsigned long start, unsigned long nr_pages,
 		    int write, int force, struct page **pages);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
 
+/* suppress warnings from use in EXPORT_SYMBOL() */
+#ifndef __DISABLE_GUP_DEPRECATED
+#define __gup_deprecated __deprecated
+#else
+#define __gup_deprecated
+#endif
+/*
+ * These macros provide backward-compatibility with the old
+ * get_user_pages() variants which took tsk/mm.  These
+ * functions/macros provide both compile-time __deprecated so we
+ * can catch old-style use and not break the build.  The actual
+ * functions also have WARN_ON()s to let us know at runtime if
+ * the get_user_pages() should have been the "remote" variant.
+ *
+ * These are hideous, but temporary.
+ *
+ * If you run into one of these __deprecated warnings, look
+ * at how you are calling get_user_pages().  If you are calling
+ * it with current/current->mm as the first two arguments,
+ * simply remove those arguments.  The behavior will be the same
+ * as it is now.  If you are calling it on another task, use
+ * get_user_pages_remote() instead.
+ *
+ * Any questions?  Ask Dave Hansen <dave@sr71.net>
+ */
+long
+__gup_deprecated
+get_user_pages8(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, unsigned long nr_pages,
+		int write, int force, struct page **pages,
+		struct vm_area_struct **vmas);
+#define GUP_MACRO(_1, _2, _3, _4, _5, _6, _7, _8, get_user_pages, ...)	\
+	get_user_pages
+#define get_user_pages(...) GUP_MACRO(__VA_ARGS__,	\
+		get_user_pages8,			\
+		get_user_pages7,			\
+		get_user_pages6)(__VA_ARGS__)
+
+__gup_deprecated
+long get_user_pages_locked8(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, unsigned long nr_pages,
+		int write, int force, struct page **pages,
+		int *locked);
+#define GUPL_MACRO(_1, _2, _3, _4, _5, _6, _7, get_user_pages_locked, ...)	\
+	get_user_pages_locked
+#define get_user_pages_locked(...) GUPL_MACRO(__VA_ARGS__,	\
+		get_user_pages_locked7,				\
+		get_user_pages_locked6,				\
+		get_user_pages_locked5)(__VA_ARGS__)
+
+__gup_deprecated
+long get_user_pages_unlocked7(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, unsigned long nr_pages,
+		int write, int force, struct page **pages);
+#define GUPU_MACRO(_1, _2, _3, _4, _5, _6, _7, get_user_pages_unlocked, ...)	\
+	get_user_pages_unlocked
+#define get_user_pages_unlocked(...) GUPU_MACRO(__VA_ARGS__,	\
+		get_user_pages_unlocked7,			\
+		get_user_pages_unlocked6,			\
+		get_user_pages_unlocked5)(__VA_ARGS__)
+
 /* Container for pinned pfns / pages */
 struct frame_vector {
 	unsigned int nr_allocated;	/* Number of frames we have space for */
diff -puN mm/gup.c~gup-arg-helpers mm/gup.c
--- a/mm/gup.c~gup-arg-helpers	2016-02-10 10:09:00.819308033 -0800
+++ b/mm/gup.c	2016-02-10 10:09:00.827308401 -0800
@@ -1,3 +1,4 @@
+#define __DISABLE_GUP_DEPRECATED 1
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/err.h>
@@ -807,15 +808,15 @@ static __always_inline long __get_user_p
  *      if (locked)
  *          up_read(&mm->mmap_sem);
  */
-long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
-			   unsigned long start, unsigned long nr_pages,
+long get_user_pages_locked6(unsigned long start, unsigned long nr_pages,
 			   int write, int force, struct page **pages,
 			   int *locked)
 {
-	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				       pages, NULL, locked, true, FOLL_TOUCH);
+	return __get_user_pages_locked(current, current->mm, start, nr_pages,
+				       write, force, pages, NULL, locked, true,
+				       FOLL_TOUCH);
 }
-EXPORT_SYMBOL(get_user_pages_locked);
+EXPORT_SYMBOL(get_user_pages_locked6);
 
 /*
  * Same as get_user_pages_unlocked(...., FOLL_TOUCH) but it allows to
@@ -860,14 +861,13 @@ EXPORT_SYMBOL(__get_user_pages_unlocked)
  * or if "force" shall be set to 1 (get_user_pages_fast misses the
  * "force" parameter).
  */
-long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
-			     unsigned long start, unsigned long nr_pages,
+long get_user_pages_unlocked5(unsigned long start, unsigned long nr_pages,
 			     int write, int force, struct page **pages)
 {
-	return __get_user_pages_unlocked(tsk, mm, start, nr_pages, write,
-					 force, pages, FOLL_TOUCH);
+	return __get_user_pages_unlocked(current, current->mm, start, nr_pages,
+					 write, force, pages, FOLL_TOUCH);
 }
-EXPORT_SYMBOL(get_user_pages_unlocked);
+EXPORT_SYMBOL(get_user_pages_unlocked5);
 
 /*
  * get_user_pages_remote() - pin user pages in memory
@@ -939,16 +939,15 @@ EXPORT_SYMBOL(get_user_pages_remote);
  * This is the same as get_user_pages_remote() for the time
  * being.
  */
-long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, unsigned long nr_pages,
+long get_user_pages6(unsigned long start, unsigned long nr_pages,
 		int write, int force, struct page **pages,
 		struct vm_area_struct **vmas)
 {
-	return __get_user_pages_locked(tsk, mm, start, nr_pages,
+	return __get_user_pages_locked(current, current->mm, start, nr_pages,
 				       write, force, pages, vmas, NULL, false,
 				       FOLL_TOUCH);
 }
-EXPORT_SYMBOL(get_user_pages);
+EXPORT_SYMBOL(get_user_pages6);
 
 /**
  * populate_vma_page_range() -  populate a range of pages in the vma.
@@ -1484,3 +1483,38 @@ int get_user_pages_fast(unsigned long st
 }
 
 #endif /* CONFIG_HAVE_GENERIC_RCU_GUP */
+
+long get_user_pages8(struct task_struct *tsk, struct mm_struct *mm,
+		     unsigned long start, unsigned long nr_pages,
+		     int write, int force, struct page **pages,
+		     struct vm_area_struct **vmas)
+{
+	WARN_ONCE(tsk != current, "get_user_pages() called on remote task");
+	WARN_ONCE(mm != current->mm, "get_user_pages() called on remote mm");
+
+	return get_user_pages6(start, nr_pages, write, force, pages, vmas);
+}
+EXPORT_SYMBOL(get_user_pages8);
+
+long get_user_pages_locked8(struct task_struct *tsk, struct mm_struct *mm,
+			    unsigned long start, unsigned long nr_pages,
+			    int write, int force, struct page **pages, int *locked)
+{
+	WARN_ONCE(tsk != current, "get_user_pages_locked() called on remote task");
+	WARN_ONCE(mm != current->mm, "get_user_pages_locked() called on remote mm");
+
+	return get_user_pages_locked6(start, nr_pages, write, force, pages, locked);
+}
+EXPORT_SYMBOL(get_user_pages_locked8);
+
+long get_user_pages_unlocked7(struct task_struct *tsk, struct mm_struct *mm,
+				  unsigned long start, unsigned long nr_pages,
+				  int write, int force, struct page **pages)
+{
+	WARN_ONCE(tsk != current, "get_user_pages_unlocked() called on remote task");
+	WARN_ONCE(mm != current->mm, "get_user_pages_unlocked() called on remote mm");
+
+	return get_user_pages_unlocked5(start, nr_pages, write, force, pages);
+}
+EXPORT_SYMBOL(get_user_pages_unlocked7);
+
diff -puN mm/nommu.c~gup-arg-helpers mm/nommu.c
--- a/mm/nommu.c~gup-arg-helpers	2016-02-10 10:09:00.821308125 -0800
+++ b/mm/nommu.c	2016-02-10 10:09:00.828308447 -0800
@@ -15,6 +15,8 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#define __DISABLE_GUP_DEPRECATED
+
 #include <linux/export.h>
 #include <linux/mm.h>
 #include <linux/vmacache.h>
@@ -182,8 +184,7 @@ finish_or_fault:
  *   slab page or a secondary page from a compound page
  * - don't permit access to VMAs that don't support it, such as I/O mappings
  */
-long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		    unsigned long start, unsigned long nr_pages,
+long get_user_pages6(unsigned long start, unsigned long nr_pages,
 		    int write, int force, struct page **pages,
 		    struct vm_area_struct **vmas)
 {
@@ -194,20 +195,18 @@ long get_user_pages(struct task_struct *
 	if (force)
 		flags |= FOLL_FORCE;
 
-	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas,
-				NULL);
+	return __get_user_pages(current, current->mm, start, nr_pages, flags,
+				pages, vmas, NULL);
 }
-EXPORT_SYMBOL(get_user_pages);
+EXPORT_SYMBOL(get_user_pages6);
 
-long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
-			   unsigned long start, unsigned long nr_pages,
-			   int write, int force, struct page **pages,
-			   int *locked)
+long get_user_pages_locked6(unsigned long start, unsigned long nr_pages,
+			    int write, int force, struct page **pages,
+			    int *locked)
 {
-	return get_user_pages(tsk, mm, start, nr_pages, write, force,
-			      pages, NULL);
+	return get_user_pages6(start, nr_pages, write, force, pages, NULL);
 }
-EXPORT_SYMBOL(get_user_pages_locked);
+EXPORT_SYMBOL(get_user_pages_locked6);
 
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 			       unsigned long start, unsigned long nr_pages,
@@ -216,21 +215,20 @@ long __get_user_pages_unlocked(struct ta
 {
 	long ret;
 	down_read(&mm->mmap_sem);
-	ret = get_user_pages(tsk, mm, start, nr_pages, write, force,
-			     pages, NULL);
+	ret = __get_user_pages(tsk, mm, start, nr_pages, gup_flags, pages,
+				NULL, NULL);
 	up_read(&mm->mmap_sem);
 	return ret;
 }
 EXPORT_SYMBOL(__get_user_pages_unlocked);
 
-long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
-			     unsigned long start, unsigned long nr_pages,
+long get_user_pages_unlocked5(unsigned long start, unsigned long nr_pages,
 			     int write, int force, struct page **pages)
 {
-	return __get_user_pages_unlocked(tsk, mm, start, nr_pages, write,
-					 force, pages, 0);
+	return __get_user_pages_unlocked(current, current->mm, start, nr_pages,
+					 write, force, pages, 0);
 }
-EXPORT_SYMBOL(get_user_pages_unlocked);
+EXPORT_SYMBOL(get_user_pages_unlocked5);
 
 /**
  * follow_pfn - look up PFN at a user virtual address
@@ -2108,3 +2106,31 @@ static int __meminit init_admin_reserve(
 	return 0;
 }
 subsys_initcall(init_admin_reserve);
+
+long get_user_pages8(struct task_struct *tsk, struct mm_struct *mm,
+		     unsigned long start, unsigned long nr_pages,
+		     int write, int force, struct page **pages,
+		     struct vm_area_struct **vmas)
+{
+	return get_user_pages6(start, nr_pages, write, force, pages, vmas);
+}
+EXPORT_SYMBOL(get_user_pages8);
+
+long get_user_pages_locked8(struct task_struct *tsk, struct mm_struct *mm,
+			    unsigned long start, unsigned long nr_pages,
+			    int write, int force, struct page **pages,
+			    int *locked)
+{
+	return get_user_pages_locked6(start, nr_pages, write,
+				      force, pages, locked);
+}
+EXPORT_SYMBOL(get_user_pages_locked8);
+
+long get_user_pages_unlocked7(struct task_struct *tsk, struct mm_struct *mm,
+			      unsigned long start, unsigned long nr_pages,
+			      int write, int force, struct page **pages)
+{
+	return get_user_pages_unlocked5(start, nr_pages, write, force, pages);
+}
+EXPORT_SYMBOL(get_user_pages_unlocked7);
+
diff -puN mm/util.c~gup-arg-helpers mm/util.c
--- a/mm/util.c~gup-arg-helpers	2016-02-10 10:09:00.822308171 -0800
+++ b/mm/util.c	2016-02-10 10:09:00.827308401 -0800
@@ -283,9 +283,7 @@ EXPORT_SYMBOL_GPL(__get_user_pages_fast)
 int __weak get_user_pages_fast(unsigned long start,
 				int nr_pages, int write, struct page **pages)
 {
-	struct mm_struct *mm = current->mm;
-	return get_user_pages_unlocked(current, mm, start, nr_pages,
-				       write, 0, pages);
+	return get_user_pages_unlocked(start, nr_pages, write, 0, pages);
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
