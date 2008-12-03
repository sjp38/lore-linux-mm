Subject: [PATCH] mmotm:  ignore sigkill in get_user_pages during munlock
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <604427e00812022117x6538553w8ceb24e6fa7f3a30@mail.gmail.com>
References: <604427e00812022117x6538553w8ceb24e6fa7f3a30@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 03 Dec 2008 15:01:31 -0500
Message-Id: <1228334491.6693.82.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

PATCH ignore sigkill in get_user_pages during munlock

Against:  2.6.28-rc7-mmotm-081203-0150

Fixes:  make-get_user_pages-interruptible.patch

An unfortunate side effect of "make-get_user_pages-interruptible"
is that it prevents a SIGKILL'd task from munlock-ing pages that it
had mlocked, resulting in freeing of mlocked pages.  Freeing of mlocked
pages, in itself, is not so bad.  We just count them now--altho' I
had hoped to remove this stat and add PG_MLOCKED to the free pages
flags check.

However, consider pages in shared libraries mapped by more than one
task that a task mlocked--e.g., via mlockall().  If the task that
mlocked the pages exits via SIGKILL, these pages would be left mlocked
and unevictable.

Proposed fix:

Add another GUP flag to ignore sigkill when calling get_user_pages
from munlock()--similar to Kosaki Motohiro's 'IGNORE_VMA_PERMISSIONS
flag for the same purpose.  We are not actually allocating memory in
this case, which "make-get_user_pages-interruptible" intends to avoid.
We're just munlocking pages that are already resident and mapped, and
we're reusing get_user_pages() to access those pages.

?? Maybe we should combine 'IGNORE_VMA_PERMISSIONS and '_IGNORE_SIGKILL
into a single flag:  GUP_FLAGS_MUNLOCK ???

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/internal.h |    1 +
 mm/memory.c   |   11 ++++++++---
 mm/mlock.c    |    9 +++++----
 3 files changed, 14 insertions(+), 7 deletions(-)

Index: linux-2.6.28-rc7-mmotm-081203/mm/internal.h
===================================================================
--- linux-2.6.28-rc7-mmotm-081203.orig/mm/internal.h	2008-12-03 14:32:06.000000000 -0500
+++ linux-2.6.28-rc7-mmotm-081203/mm/internal.h	2008-12-03 14:32:08.000000000 -0500
@@ -276,6 +276,7 @@ static inline void mminit_validate_memmo
 #define GUP_FLAGS_WRITE                  0x1
 #define GUP_FLAGS_FORCE                  0x2
 #define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
+#define GUP_FLAGS_IGNORE_SIGKILL         0x8
 
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long start, int len, int flags,
Index: linux-2.6.28-rc7-mmotm-081203/mm/memory.c
===================================================================
--- linux-2.6.28-rc7-mmotm-081203.orig/mm/memory.c	2008-12-03 14:32:06.000000000 -0500
+++ linux-2.6.28-rc7-mmotm-081203/mm/memory.c	2008-12-03 14:33:46.000000000 -0500
@@ -1197,6 +1197,7 @@ int __get_user_pages(struct task_struct 
 	int write = !!(flags & GUP_FLAGS_WRITE);
 	int force = !!(flags & GUP_FLAGS_FORCE);
 	int ignore = !!(flags & GUP_FLAGS_IGNORE_VMA_PERMISSIONS);
+	int ignore_sigkill = !!(flags & GUP_FLAGS_IGNORE_SIGKILL);
 
 	if (len <= 0)
 		return 0;
@@ -1275,10 +1276,14 @@ int __get_user_pages(struct task_struct 
 			struct page *page;
 
 			/*
-			 * If we have a pending SIGKILL, don't keep
-			 * allocating memory.
+			 * If we have a pending SIGKILL, don't keep faulting
+			 * pages and potentially allocating memory, unless
+			 * current is handling munlock--e.g., on exit. In
+			 * that case, we are not allocating memory.  Rather,
+			 * we're only unlocking already resident/mapped pages.
 			 */
-			if (unlikely(fatal_signal_pending(current)))
+			if (unlikely(!ignore_sigkill &&
+					fatal_signal_pending(current)))
 				return i ? i : -ERESTARTSYS;
 
 			if (write)
Index: linux-2.6.28-rc7-mmotm-081203/mm/mlock.c
===================================================================
--- linux-2.6.28-rc7-mmotm-081203.orig/mm/mlock.c	2008-12-03 14:32:06.000000000 -0500
+++ linux-2.6.28-rc7-mmotm-081203/mm/mlock.c	2008-12-03 14:32:08.000000000 -0500
@@ -173,12 +173,13 @@ static long __mlock_vma_pages_range(stru
 		  (atomic_read(&mm->mm_users) != 0));
 
 	/*
-	 * mlock:   don't page populate if page has PROT_NONE permission.
-	 * munlock: the pages always do munlock althrough
-	 *          its has PROT_NONE permission.
+	 * mlock:   don't page populate if vma has PROT_NONE permission.
+	 * munlock: always do munlock although the vma has PROT_NONE
+	 *          permission, or SIGKILL is pending.
 	 */
 	if (!mlock)
-		gup_flags |= GUP_FLAGS_IGNORE_VMA_PERMISSIONS;
+		gup_flags |= GUP_FLAGS_IGNORE_VMA_PERMISSIONS |
+			     GUP_FLAGS_IGNORE_SIGKILL;
 
 	if (vma->vm_flags & VM_WRITE)
 		gup_flags |= GUP_FLAGS_WRITE;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
