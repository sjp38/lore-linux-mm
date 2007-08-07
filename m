From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 07 Aug 2007 17:19:47 +1000
Subject: [RFC/PATCH 3/12] Add MMF_DEAD flag to mm_struct being torn down
In-Reply-To: <1186471185.826251.312410898174.qpush@grosgo>
Message-Id: <20070807071954.1C634DDE1C@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This adds a flag to mm_struct that is set when the mm is being
torn down. It's needed by my next patch disconnecting sparc64
tlb flushing from the mmu_gather in order to let the later
become a stack based structure. In general, that flag provides
the information that is in tlb->fullmm but more easily accessible
to all page table accessors.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 include/linux/sched.h |    2 ++
 kernel/fork.c         |    1 +
 mm/mmap.c             |    3 +++
 3 files changed, 6 insertions(+)

Index: linux-work/include/linux/sched.h
===================================================================
--- linux-work.orig/include/linux/sched.h	2007-08-02 11:25:34.000000000 +1000
+++ linux-work/include/linux/sched.h	2007-08-02 11:39:44.000000000 +1000
@@ -366,6 +366,8 @@ extern int get_dumpable(struct mm_struct
 #define MMF_DUMP_FILTER_DEFAULT \
 	((1 << MMF_DUMP_ANON_PRIVATE) |	(1 << MMF_DUMP_ANON_SHARED))
 
+#define MMF_DEAD          	6  /* mm is being destroyed */
+
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
Index: linux-work/mm/mmap.c
===================================================================
--- linux-work.orig/mm/mmap.c	2007-08-02 11:25:35.000000000 +1000
+++ linux-work/mm/mmap.c	2007-08-02 11:39:44.000000000 +1000
@@ -2025,6 +2025,9 @@ void exit_mmap(struct mm_struct *mm)
 	unsigned long nr_accounted = 0;
 	unsigned long end;
 
+	/* Mark the MM as dead */
+	__set_bit(MMF_DEAD, &mm->flags);
+
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
 
Index: linux-work/kernel/fork.c
===================================================================
--- linux-work.orig/kernel/fork.c	2007-07-22 10:26:48.000000000 +1000
+++ linux-work/kernel/fork.c	2007-08-02 11:39:44.000000000 +1000
@@ -336,6 +336,7 @@ static struct mm_struct * mm_init(struct
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->flags = (current->mm) ? current->mm->flags
 				  : MMF_DUMP_FILTER_DEFAULT;
+	__clear_bit(MMF_DEAD, &mm->flags);
 	mm->core_waiters = 0;
 	mm->nr_ptes = 0;
 	set_mm_counter(mm, file_rss, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
