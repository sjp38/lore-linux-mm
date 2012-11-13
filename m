Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id BE0196B009A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 12:15:14 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so3578138eaa.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:15:14 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 15/31] mm/mpol: Add MPOL_MF_LAZY
Date: Tue, 13 Nov 2012 18:13:38 +0100
Message-Id: <1352826834-11774-16-git-send-email-mingo@kernel.org>
In-Reply-To: <1352826834-11774-1-git-send-email-mingo@kernel.org>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Lee Schermerhorn <lee.schermerhorn@hp.com>

From: Lee Schermerhorn <lee.schermerhorn@hp.com>

This patch adds another mbind() flag to request "lazy migration".  The
flag, MPOL_MF_LAZY, modifies MPOL_MF_MOVE* such that the selected
pages are marked PROT_NONE. The pages will be migrated in the fault
path on "first touch", if the policy dictates at that time.

"Lazy Migration" will allow testing of migrate-on-fault via mbind().
Also allows applications to specify that only subsequently touched
pages be migrated to obey new policy, instead of all pages in range.
This can be useful for multi-threaded applications working on a
large shared data area that is initialized by an initial thread
resulting in all pages on one [or a few, if overflowed] nodes.
After PROT_NONE, the pages in regions assigned to the worker threads
will be automatically migrated local to the threads on 1st touch.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
[ nearly complete rewrite.. ]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Link: http://lkml.kernel.org/n/tip-7rsodo9x8zvm5awru5o7zo0y@git.kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/uapi/linux/mempolicy.h | 13 ++++++++---
 mm/mempolicy.c                 | 49 +++++++++++++++++++++++++++---------------
 2 files changed, 42 insertions(+), 20 deletions(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 472de8a..6a1baae 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -49,9 +49,16 @@ enum mpol_rebind_step {
 
 /* Flags for mbind */
 #define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
-#define MPOL_MF_MOVE	(1<<1)	/* Move pages owned by this process to conform to mapping */
-#define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to mapping */
-#define MPOL_MF_INTERNAL (1<<3)	/* Internal flags start here */
+#define MPOL_MF_MOVE	 (1<<1)	/* Move pages owned by this process to conform
+				   to policy */
+#define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to policy */
+#define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
+#define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
+
+#define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
+			 MPOL_MF_MOVE     | 	\
+			 MPOL_MF_MOVE_ALL |	\
+			 MPOL_MF_LAZY)
 
 /*
  * Internal flags that share the struct mempolicy flags word with
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1b2890c..5ee326c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -583,22 +583,32 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 		return ERR_PTR(-EFAULT);
 	prev = NULL;
 	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
+		unsigned long endvma = vma->vm_end;
+
+		if (endvma > end)
+			endvma = end;
+		if (vma->vm_start > start)
+			start = vma->vm_start;
+
 		if (!(flags & MPOL_MF_DISCONTIG_OK)) {
 			if (!vma->vm_next && vma->vm_end < end)
 				return ERR_PTR(-EFAULT);
 			if (prev && prev->vm_end < vma->vm_start)
 				return ERR_PTR(-EFAULT);
 		}
-		if (!is_vm_hugetlb_page(vma) &&
-		    ((flags & MPOL_MF_STRICT) ||
+
+		if (is_vm_hugetlb_page(vma))
+			goto next;
+
+		if (flags & MPOL_MF_LAZY) {
+			change_prot_none(vma, start, endvma);
+			goto next;
+		}
+
+		if ((flags & MPOL_MF_STRICT) ||
 		     ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
-				vma_migratable(vma)))) {
-			unsigned long endvma = vma->vm_end;
+		      vma_migratable(vma))) {
 
-			if (endvma > end)
-				endvma = end;
-			if (vma->vm_start > start)
-				start = vma->vm_start;
 			err = check_pgd_range(vma, start, endvma, nodes,
 						flags, private);
 			if (err) {
@@ -606,6 +616,7 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 				break;
 			}
 		}
+next:
 		prev = vma;
 	}
 	return first;
@@ -1137,8 +1148,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	int err;
 	LIST_HEAD(pagelist);
 
-	if (flags & ~(unsigned long)(MPOL_MF_STRICT |
-				     MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+  	if (flags & ~(unsigned long)MPOL_MF_VALID)
 		return -EINVAL;
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
 		return -EPERM;
@@ -1161,6 +1171,9 @@ static long do_mbind(unsigned long start, unsigned long len,
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
+	if (flags & MPOL_MF_LAZY)
+		new->flags |= MPOL_F_MOF;
+
 	/*
 	 * If we are using the default policy then operation
 	 * on discontinuous address spaces is okay after all
@@ -1197,21 +1210,23 @@ static long do_mbind(unsigned long start, unsigned long len,
 	vma = check_range(mm, start, end, nmask,
 			  flags | MPOL_MF_INVERT, &pagelist);
 
-	err = PTR_ERR(vma);
-	if (!IS_ERR(vma)) {
-		int nr_failed = 0;
-
+	err = PTR_ERR(vma);	/* maybe ... */
+	if (!IS_ERR(vma) && mode != MPOL_NOOP)
 		err = mbind_range(mm, start, end, new);
 
+	if (!err) {
+		int nr_failed = 0;
+
 		if (!list_empty(&pagelist)) {
+			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
-						(unsigned long)vma,
-						false, MIGRATE_SYNC);
+						  (unsigned long)vma,
+						  false, MIGRATE_SYNC);
 			if (nr_failed)
 				putback_lru_pages(&pagelist);
 		}
 
-		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
+		if (nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
 	} else
 		putback_lru_pages(&pagelist);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
