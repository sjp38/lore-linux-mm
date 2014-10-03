Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8E36B0069
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 14:02:43 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so996307vcb.38
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 11:02:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id se3si4795070vdc.52.2014.10.03.11.02.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 11:02:41 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 02/17] mm: gup: add get_user_pages_locked and get_user_pages_unlocked
Date: Fri,  3 Oct 2014 19:07:52 +0200
Message-Id: <1412356087-16115-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

We can leverage the VM_FAULT_RETRY functionality in the page fault
paths better by using either get_user_pages_locked or
get_user_pages_unlocked.

The former allow conversion of get_user_pages invocations that will
have to pass a "&locked" parameter to know if the mmap_sem was dropped
during the call. Example from:

    down_read(&mm->mmap_sem);
    do_something()
    get_user_pages(tsk, mm, ..., pages, NULL);
    up_read(&mm->mmap_sem);

to:

    int locked = 1;
    down_read(&mm->mmap_sem);
    do_something()
    get_user_pages_locked(tsk, mm, ..., pages, &locked);
    if (locked)
        up_read(&mm->mmap_sem);

The latter is suitable only as a drop in replacement of the form:

    down_read(&mm->mmap_sem);
    get_user_pages(tsk, mm, ..., pages, NULL);
    up_read(&mm->mmap_sem);

into:

    get_user_pages_unlocked(tsk, mm, ..., pages);

Where tsk, mm, the intermediate "..." paramters and "pages" can be any
value as before. Just the last parameter of get_user_pages (vmas) must
be NULL for get_user_pages_locked|unlocked to be usable (the latter
original form wouldn't have been safe anyway if vmas wasn't null, for
the former we just make it explicit by dropping the parameter).

If vmas is not NULL these two methods cannot be used.

This patch then applies the new forms in various places, in some case
also replacing it with get_user_pages_fast whenever tsk and mm are
current and current->mm. get_user_pages_unlocked varies from
get_user_pages_fast only if mm is not current->mm (like when
get_user_pages works on some other process mm). Whenever tsk and mm
matches current and current->mm get_user_pages_fast must always be
used to increase performance and get the page lockless (only with irq
disabled).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Andres Lagar-Cavilla <andreslc@google.com>
Reviewed-by: Peter Feiner <pfeiner@google.com>
---
 include/linux/mm.h |   7 +++
 mm/gup.c           | 178 +++++++++++++++++++++++++++++++++++++++++++++++++----
 mm/nommu.c         |  23 +++++++
 3 files changed, 197 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0f4196a..8900ba9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1196,6 +1196,13 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		    unsigned long start, unsigned long nr_pages,
 		    int write, int force, struct page **pages,
 		    struct vm_area_struct **vmas);
+long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
+		    unsigned long start, unsigned long nr_pages,
+		    int write, int force, struct page **pages,
+		    int *locked);
+long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+		    unsigned long start, unsigned long nr_pages,
+		    int write, int force, struct page **pages);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
 struct kvec;
diff --git a/mm/gup.c b/mm/gup.c
index af7ea3e..6f2f757 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -580,6 +580,166 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	return 0;
 }
 
+static inline long __get_user_pages_locked(struct task_struct *tsk,
+					   struct mm_struct *mm,
+					   unsigned long start,
+					   unsigned long nr_pages,
+					   int write, int force,
+					   struct page **pages,
+					   struct vm_area_struct **vmas,
+					   int *locked,
+					   bool notify_drop)
+{
+	int flags = FOLL_TOUCH;
+	long ret, pages_done;
+	bool lock_dropped;
+
+	if (locked) {
+		/* if VM_FAULT_RETRY can be returned, vmas become invalid */
+		BUG_ON(vmas);
+		/* check caller initialized locked */
+		BUG_ON(*locked != 1);
+	}
+
+	if (pages)
+		flags |= FOLL_GET;
+	if (write)
+		flags |= FOLL_WRITE;
+	if (force)
+		flags |= FOLL_FORCE;
+
+	pages_done = 0;
+	lock_dropped = false;
+	for (;;) {
+		ret = __get_user_pages(tsk, mm, start, nr_pages, flags, pages,
+				       vmas, locked);
+		if (!locked)
+			/* VM_FAULT_RETRY couldn't trigger, bypass */
+			return ret;
+
+		/* VM_FAULT_RETRY cannot return errors */
+		if (!*locked) {
+			BUG_ON(ret < 0);
+			BUG_ON(ret >= nr_pages);
+		}
+
+		if (!pages)
+			/* If it's a prefault don't insist harder */
+			return ret;
+
+		if (ret > 0) {
+			nr_pages -= ret;
+			pages_done += ret;
+			if (!nr_pages)
+				break;
+		}
+		if (*locked) {
+			/* VM_FAULT_RETRY didn't trigger */
+			if (!pages_done)
+				pages_done = ret;
+			break;
+		}
+		/* VM_FAULT_RETRY triggered, so seek to the faulting offset */
+		pages += ret;
+		start += ret << PAGE_SHIFT;
+
+		/*
+		 * Repeat on the address that fired VM_FAULT_RETRY
+		 * without FAULT_FLAG_ALLOW_RETRY but with
+		 * FAULT_FLAG_TRIED.
+		 */
+		*locked = 1;
+		lock_dropped = true;
+		down_read(&mm->mmap_sem);
+		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
+				       pages, NULL, NULL);
+		if (ret != 1) {
+			BUG_ON(ret > 1);
+			if (!pages_done)
+				pages_done = ret;
+			break;
+		}
+		nr_pages--;
+		pages_done++;
+		if (!nr_pages)
+			break;
+		pages++;
+		start += PAGE_SIZE;
+	}
+	if (notify_drop && lock_dropped && *locked) {
+		/*
+		 * We must let the caller know we temporarily dropped the lock
+		 * and so the critical section protected by it was lost.
+		 */
+		up_read(&mm->mmap_sem);
+		*locked = 0;
+	}
+	return pages_done;
+}
+
+/*
+ * We can leverage the VM_FAULT_RETRY functionality in the page fault
+ * paths better by using either get_user_pages_locked() or
+ * get_user_pages_unlocked().
+ *
+ * get_user_pages_locked() is suitable to replace the form:
+ *
+ *      down_read(&mm->mmap_sem);
+ *      do_something()
+ *      get_user_pages(tsk, mm, ..., pages, NULL);
+ *      up_read(&mm->mmap_sem);
+ *
+ *  to:
+ *
+ *      int locked = 1;
+ *      down_read(&mm->mmap_sem);
+ *      do_something()
+ *      get_user_pages_locked(tsk, mm, ..., pages, &locked);
+ *      if (locked)
+ *          up_read(&mm->mmap_sem);
+ */
+long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
+			   unsigned long start, unsigned long nr_pages,
+			   int write, int force, struct page **pages,
+			   int *locked)
+{
+	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
+				       pages, NULL, locked, true);
+}
+EXPORT_SYMBOL(get_user_pages_locked);
+
+/*
+ * get_user_pages_unlocked() is suitable to replace the form:
+ *
+ *      down_read(&mm->mmap_sem);
+ *      get_user_pages(tsk, mm, ..., pages, NULL);
+ *      up_read(&mm->mmap_sem);
+ *
+ *  with:
+ *
+ *      get_user_pages_unlocked(tsk, mm, ..., pages);
+ *
+ * It is functionally equivalent to get_user_pages_fast so
+ * get_user_pages_fast should be used instead, if the two parameters
+ * "tsk" and "mm" are respectively equal to current and current->mm,
+ * or if "force" shall be set to 1 (get_user_pages_fast misses the
+ * "force" parameter).
+ */
+long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+			     unsigned long start, unsigned long nr_pages,
+			     int write, int force, struct page **pages)
+{
+	long ret;
+	int locked = 1;
+	down_read(&mm->mmap_sem);
+	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
+				      pages, NULL, &locked, false);
+	if (locked)
+		up_read(&mm->mmap_sem);
+	return ret;
+}
+EXPORT_SYMBOL(get_user_pages_unlocked);
+
 /*
  * get_user_pages() - pin user pages in memory
  * @tsk:	the task_struct to use for page fault accounting, or
@@ -629,22 +789,18 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
  * use the correct cache flushing APIs.
  *
  * See also get_user_pages_fast, for performance critical applications.
+ *
+ * get_user_pages should be phased out in favor of
+ * get_user_pages_locked|unlocked or get_user_pages_fast. Nothing
+ * should use get_user_pages because it cannot pass
+ * FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.
  */
 long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages, int write,
 		int force, struct page **pages, struct vm_area_struct **vmas)
 {
-	int flags = FOLL_TOUCH;
-
-	if (pages)
-		flags |= FOLL_GET;
-	if (write)
-		flags |= FOLL_WRITE;
-	if (force)
-		flags |= FOLL_FORCE;
-
-	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas,
-				NULL);
+	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
+				       pages, vmas, NULL, false);
 }
 EXPORT_SYMBOL(get_user_pages);
 
diff --git a/mm/nommu.c b/mm/nommu.c
index a881d96..3918b0f 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -213,6 +213,29 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 }
 EXPORT_SYMBOL(get_user_pages);
 
+long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
+			   unsigned long start, unsigned long nr_pages,
+			   int write, int force, struct page **pages,
+			   int *locked)
+{
+	return get_user_pages(tsk, mm, start, nr_pages, write, force,
+			      pages, NULL);
+}
+EXPORT_SYMBOL(get_user_pages_locked);
+
+long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+			     unsigned long start, unsigned long nr_pages,
+			     int write, int force, struct page **pages)
+{
+	long ret;
+	down_read(&mm->mmap_sem);
+	ret = get_user_pages(tsk, mm, start, nr_pages, write, force,
+			     pages, NULL);
+	up_read(&mm->mmap_sem);
+	return ret;
+}
+EXPORT_SYMBOL(get_user_pages_unlocked);
+
 /**
  * follow_pfn - look up PFN at a user virtual address
  * @vma: memory mapping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
