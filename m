Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5A21C6B00B6
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 17:31:55 -0400 (EDT)
Date: Mon, 7 Sep 2009 22:31:09 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 2/8] mm: remove unused GUP flags
In-Reply-To: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909072230010.15430@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

GUP_FLAGS_IGNORE_VMA_PERMISSIONS and GUP_FLAGS_IGNORE_SIGKILL were
flags added solely to prevent __get_user_pages() from doing some of
what it usually does, in the munlock case: we can now remove them.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/internal.h |    6 ++----
 mm/memory.c   |   14 ++++----------
 mm/nommu.c    |    6 ++----
 3 files changed, 8 insertions(+), 18 deletions(-)

--- mm1/mm/internal.h	2009-06-25 05:18:10.000000000 +0100
+++ mm2/mm/internal.h	2009-09-07 13:16:22.000000000 +0100
@@ -250,10 +250,8 @@ static inline void mminit_validate_memmo
 }
 #endif /* CONFIG_SPARSEMEM */
 
-#define GUP_FLAGS_WRITE                  0x1
-#define GUP_FLAGS_FORCE                  0x2
-#define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
-#define GUP_FLAGS_IGNORE_SIGKILL         0x8
+#define GUP_FLAGS_WRITE		0x01
+#define GUP_FLAGS_FORCE		0x02
 
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long start, int len, int flags,
--- mm1/mm/memory.c	2009-09-05 14:40:16.000000000 +0100
+++ mm2/mm/memory.c	2009-09-07 13:16:22.000000000 +0100
@@ -1217,8 +1217,6 @@ int __get_user_pages(struct task_struct
 	unsigned int vm_flags = 0;
 	int write = !!(flags & GUP_FLAGS_WRITE);
 	int force = !!(flags & GUP_FLAGS_FORCE);
-	int ignore = !!(flags & GUP_FLAGS_IGNORE_VMA_PERMISSIONS);
-	int ignore_sigkill = !!(flags & GUP_FLAGS_IGNORE_SIGKILL);
 
 	if (nr_pages <= 0)
 		return 0;
@@ -1244,7 +1242,7 @@ int __get_user_pages(struct task_struct
 			pte_t *pte;
 
 			/* user gate pages are read-only */
-			if (!ignore && write)
+			if (write)
 				return i ? : -EFAULT;
 			if (pg > TASK_SIZE)
 				pgd = pgd_offset_k(pg);
@@ -1278,7 +1276,7 @@ int __get_user_pages(struct task_struct
 
 		if (!vma ||
 		    (vma->vm_flags & (VM_IO | VM_PFNMAP)) ||
-		    (!ignore && !(vm_flags & vma->vm_flags)))
+		    !(vm_flags & vma->vm_flags))
 			return i ? : -EFAULT;
 
 		if (is_vm_hugetlb_page(vma)) {
@@ -1298,13 +1296,9 @@ int __get_user_pages(struct task_struct
 
 			/*
 			 * If we have a pending SIGKILL, don't keep faulting
-			 * pages and potentially allocating memory, unless
-			 * current is handling munlock--e.g., on exit. In
-			 * that case, we are not allocating memory.  Rather,
-			 * we're only unlocking already resident/mapped pages.
+			 * pages and potentially allocating memory.
 			 */
-			if (unlikely(!ignore_sigkill &&
-					fatal_signal_pending(current)))
+			if (unlikely(fatal_signal_pending(current)))
 				return i ? i : -ERESTARTSYS;
 
 			if (write)
--- mm1/mm/nommu.c	2009-09-05 14:40:16.000000000 +0100
+++ mm2/mm/nommu.c	2009-09-07 13:16:22.000000000 +0100
@@ -136,7 +136,6 @@ int __get_user_pages(struct task_struct
 	int i;
 	int write = !!(flags & GUP_FLAGS_WRITE);
 	int force = !!(flags & GUP_FLAGS_FORCE);
-	int ignore = !!(flags & GUP_FLAGS_IGNORE_VMA_PERMISSIONS);
 
 	/* calculate required read or write permissions.
 	 * - if 'force' is set, we only require the "MAY" flags.
@@ -150,8 +149,8 @@ int __get_user_pages(struct task_struct
 			goto finish_or_fault;
 
 		/* protect what we can, including chardevs */
-		if (vma->vm_flags & (VM_IO | VM_PFNMAP) ||
-		    (!ignore && !(vm_flags & vma->vm_flags)))
+		if ((vma->vm_flags & (VM_IO | VM_PFNMAP)) ||
+		    !(vm_flags & vma->vm_flags))
 			goto finish_or_fault;
 
 		if (pages) {
@@ -170,7 +169,6 @@ finish_or_fault:
 	return i ? : -EFAULT;
 }
 
-
 /*
  * get a list of pages in an address range belonging to the specified process
  * and indicate the VMA that covers each page

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
