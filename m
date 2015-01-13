Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 20E9A6B0073
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 11:38:57 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so5215496wid.0
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 08:38:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hg16si21122438wib.50.2015.01.13.08.38.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 08:38:50 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/5] mm: gup: add __get_user_pages_unlocked to customize gup_flags
Date: Tue, 13 Jan 2015 17:37:51 +0100
Message-Id: <1421167074-9789-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1421167074-9789-1-git-send-email-aarcange@redhat.com>
References: <1421167074-9789-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

Some caller (like KVM) may want to set the gup_flags like
FOLL_HWPOSION to get a proper -EHWPOSION retval instead of -EFAULT to
take a more appropriate action if get_user_pages runs into a memory
failure.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h |  4 ++++
 mm/gup.c           | 44 ++++++++++++++++++++++++++++++++------------
 mm/nommu.c         | 16 +++++++++++++---
 3 files changed, 49 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2ea38d8..c4d3102 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1238,6 +1238,10 @@ long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
 		    unsigned long start, unsigned long nr_pages,
 		    int write, int force, struct page **pages,
 		    int *locked);
+long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+			       unsigned long start, unsigned long nr_pages,
+			       int write, int force, struct page **pages,
+			       unsigned int gup_flags);
 long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 		    unsigned long start, unsigned long nr_pages,
 		    int write, int force, struct page **pages);
diff --git a/mm/gup.c b/mm/gup.c
index c2bd9b3..d616811 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -591,9 +591,9 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 						int write, int force,
 						struct page **pages,
 						struct vm_area_struct **vmas,
-						int *locked, bool notify_drop)
+						int *locked, bool notify_drop,
+						unsigned int flags)
 {
-	int flags = FOLL_TOUCH;
 	long ret, pages_done;
 	bool lock_dropped;
 
@@ -707,11 +707,37 @@ long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
 			   int *locked)
 {
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				       pages, NULL, locked, true);
+				       pages, NULL, locked, true, FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
 /*
+ * Same as get_user_pages_unlocked(...., FOLL_TOUCH) but it allows to
+ * pass additional gup_flags as last parameter (like FOLL_HWPOISON).
+ *
+ * NOTE: here FOLL_TOUCH is not set implicitly and must be set by the
+ * caller if required (just like with __get_user_pages). "FOLL_GET",
+ * "FOLL_WRITE" and "FOLL_FORCE" are set implicitly as needed
+ * according to the parameters "pages", "write", "force"
+ * respectively.
+ */
+__always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+					       unsigned long start, unsigned long nr_pages,
+					       int write, int force, struct page **pages,
+					       unsigned int gup_flags)
+{
+	long ret;
+	int locked = 1;
+	down_read(&mm->mmap_sem);
+	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
+				      pages, NULL, &locked, false, gup_flags);
+	if (locked)
+		up_read(&mm->mmap_sem);
+	return ret;
+}
+EXPORT_SYMBOL(__get_user_pages_unlocked);
+
+/*
  * get_user_pages_unlocked() is suitable to replace the form:
  *
  *      down_read(&mm->mmap_sem);
@@ -732,14 +758,8 @@ long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 			     unsigned long start, unsigned long nr_pages,
 			     int write, int force, struct page **pages)
 {
-	long ret;
-	int locked = 1;
-	down_read(&mm->mmap_sem);
-	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				      pages, NULL, &locked, false);
-	if (locked)
-		up_read(&mm->mmap_sem);
-	return ret;
+	return __get_user_pages_unlocked(tsk, mm, start, nr_pages, write,
+					 force, pages, FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages_unlocked);
 
@@ -803,7 +823,7 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		int force, struct page **pages, struct vm_area_struct **vmas)
 {
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				       pages, vmas, NULL, false);
+				       pages, vmas, NULL, false, FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages);
 
diff --git a/mm/nommu.c b/mm/nommu.c
index d6d0a6ac..05f42f0 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -223,9 +223,10 @@ long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
-long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
-			     unsigned long start, unsigned long nr_pages,
-			     int write, int force, struct page **pages)
+long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+			       unsigned long start, unsigned long nr_pages,
+			       int write, int force, struct page **pages,
+			       unsigned int gup_flags)
 {
 	long ret;
 	down_read(&mm->mmap_sem);
@@ -234,6 +235,15 @@ long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 	up_read(&mm->mmap_sem);
 	return ret;
 }
+EXPORT_SYMBOL(__get_user_pages_unlocked);
+
+long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+			     unsigned long start, unsigned long nr_pages,
+			     int write, int force, struct page **pages)
+{
+	return __get_user_pages_unlocked(tsk, mm, start, nr_pages, write,
+					 force, pages, 0);
+}
 EXPORT_SYMBOL(get_user_pages_unlocked);
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
