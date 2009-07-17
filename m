Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id ACDF06B0055
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 13:27:11 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 02/10] ksm: first tidy up madvise_vma()
Date: Fri, 17 Jul 2009 20:30:42 +0300
Message-Id: <1247851850-4298-3-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-2-git-send-email-ieidus@redhat.com>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ieidus@redhat.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh.dickins@tiscali.co.uk>

madvise.c has several levels of switch statements, what to do in which?
Move MADV_DOFORK code down from madvise_vma() to madvise_behavior(), so
madvise_vma() can be a simple router, to madvise_behavior() by default.

vma->vm_flags is an unsigned long so use the same type for new_flags.
Add missing comment lines to describe MADV_DONTFORK and MADV_DOFORK.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Signed-off-by: Chris Wright <chrisw@redhat.com>
Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/madvise.c |   39 +++++++++++++--------------------------
 1 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 76eb419..66c3126 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -41,7 +41,7 @@ static long madvise_behavior(struct vm_area_struct * vma,
 	struct mm_struct * mm = vma->vm_mm;
 	int error = 0;
 	pgoff_t pgoff;
-	int new_flags = vma->vm_flags;
+	unsigned long new_flags = vma->vm_flags;
 
 	switch (behavior) {
 	case MADV_NORMAL:
@@ -57,6 +57,10 @@ static long madvise_behavior(struct vm_area_struct * vma,
 		new_flags |= VM_DONTCOPY;
 		break;
 	case MADV_DOFORK:
+		if (vma->vm_flags & VM_IO) {
+			error = -EINVAL;
+			goto out;
+		}
 		new_flags &= ~VM_DONTCOPY;
 		break;
 	}
@@ -211,37 +215,16 @@ static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		unsigned long start, unsigned long end, int behavior)
 {
-	long error;
-
 	switch (behavior) {
-	case MADV_DOFORK:
-		if (vma->vm_flags & VM_IO) {
-			error = -EINVAL;
-			break;
-		}
-	case MADV_DONTFORK:
-	case MADV_NORMAL:
-	case MADV_SEQUENTIAL:
-	case MADV_RANDOM:
-		error = madvise_behavior(vma, prev, start, end, behavior);
-		break;
 	case MADV_REMOVE:
-		error = madvise_remove(vma, prev, start, end);
-		break;
-
+		return madvise_remove(vma, prev, start, end);
 	case MADV_WILLNEED:
-		error = madvise_willneed(vma, prev, start, end);
-		break;
-
+		return madvise_willneed(vma, prev, start, end);
 	case MADV_DONTNEED:
-		error = madvise_dontneed(vma, prev, start, end);
-		break;
-
+		return madvise_dontneed(vma, prev, start, end);
 	default:
-		BUG();
-		break;
+		return madvise_behavior(vma, prev, start, end, behavior);
 	}
-	return error;
 }
 
 static int
@@ -262,6 +245,7 @@ madvise_behavior_valid(int behavior)
 		return 0;
 	}
 }
+
 /*
  * The madvise(2) system call.
  *
@@ -286,6 +270,9 @@ madvise_behavior_valid(int behavior)
  *		so the kernel can free resources associated with it.
  *  MADV_REMOVE - the application wants to free up the given range of
  *		pages and associated backing store.
+ *  MADV_DONTFORK - omit this area from child's address space when forking:
+ *		typically, to avoid COWing pages pinned by get_user_pages().
+ *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when forking.
  *
  * return values:
  *  zero    - success
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
