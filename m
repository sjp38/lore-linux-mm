Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A67D86B0038
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:32:18 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t6so253106924pgt.6
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:32:18 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id n6si20915483pga.123.2017.01.24.14.32.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 14:32:17 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id e4so52800888pfg.1
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:32:17 -0800 (PST)
Date: Tue, 24 Jan 2017 14:32:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, madvise: fail with ENOMEM when splitting vma will hit
 max_map_count
Message-ID: <alpine.DEB.2.10.1701241431120.42507@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Johannes Weiner <hannes@cmpxchg.org>, mtk.manpages@gmail.com, Jerome Marchand <jmarchan@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If madvise(2) advice will result in the underlying vma being split and
the number of areas mapped by the process will exceed
/proc/sys/vm/max_map_count as a result, return ENOMEM instead of EAGAIN.

EAGAIN is returned by madvise(2) when a kernel resource, such as slab,
is temporarily unavailable.  It indicates that userspace should retry the
advice in the near future.  This is important for advice such as
MADV_DONTNEED which is often used by malloc implementations to free
memory back to the system: we really do want to free memory back when
madvise(2) returns EAGAIN because slab allocations (for vmas, anon_vmas,
or mempolicies) cannot be allocated.

Encountering /proc/sys/vm/max_map_count is not a temporary failure,
however, so return ENOMEM to indicate this is a more serious issue.  A
followup patch to the man page will specify this behavior.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/sysctl/vm.txt |  4 ++--
 Documentation/vm/ksm.txt    |  4 ++++
 include/linux/mm.h          |  6 ++++--
 mm/madvise.c                | 51 +++++++++++++++++++++++++++++++++++++--------
 mm/mmap.c                   |  8 +++----
 5 files changed, 56 insertions(+), 17 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -376,8 +376,8 @@ max_map_count:
 
 This file contains the maximum number of memory map areas a process
 may have. Memory map areas are used as a side-effect of calling
-malloc, directly by mmap and mprotect, and also when loading shared
-libraries.
+malloc, directly by mmap, mprotect, and madvise, and also when loading
+shared libraries.
 
 While most applications need less than a thousand maps, certain
 programs, particularly malloc debuggers, may consume lots of them,
diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
--- a/Documentation/vm/ksm.txt
+++ b/Documentation/vm/ksm.txt
@@ -38,6 +38,10 @@ the range for whenever the KSM daemon is started; even if the range
 cannot contain any pages which KSM could actually merge; even if
 MADV_UNMERGEABLE is applied to a range which was never MADV_MERGEABLE.
 
+If a region of memory must be split into at least one new MADV_MERGEABLE
+or MADV_UNMERGEABLE region, the madvise may return ENOMEM if the process
+will exceed vm.max_map_count (see Documentation/sysctl/vm.txt).
+
 Like other madvise calls, they are intended for use on mapped areas of
 the user address space: they will report ENOMEM if the specified range
 includes unmapped gaps (though working on the intervening mapped areas),
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1968,8 +1968,10 @@ extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
 	struct mempolicy *, struct vm_userfaultfd_ctx);
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
-extern int split_vma(struct mm_struct *,
-	struct vm_area_struct *, unsigned long addr, int new_below);
+extern int __split_vma(struct mm_struct *, struct vm_area_struct *,
+	unsigned long addr, int new_below);
+extern int split_vma(struct mm_struct *, struct vm_area_struct *,
+	unsigned long addr, int new_below);
 extern int insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
 extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
 	struct rb_node **, struct rb_node *);
diff --git a/mm/madvise.c b/mm/madvise.c
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -89,14 +89,28 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
 		error = ksm_madvise(vma, start, end, behavior, &new_flags);
-		if (error)
+		if (error) {
+			/*
+			 * madvise() returns EAGAIN if kernel resources, such as
+			 * slab, are temporarily unavailable.
+			 */
+			if (error == -ENOMEM)
+				error = -EAGAIN;
 			goto out;
+		}
 		break;
 	case MADV_HUGEPAGE:
 	case MADV_NOHUGEPAGE:
 		error = hugepage_madvise(vma, &new_flags, behavior);
-		if (error)
+		if (error) {
+			/*
+			 * madvise() returns EAGAIN if kernel resources, such as
+			 * slab, are temporarily unavailable.
+			 */
+			if (error == -ENOMEM)
+				error = -EAGAIN;
 			goto out;
+		}
 		break;
 	}
 
@@ -117,15 +131,37 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	*prev = vma;
 
 	if (start != vma->vm_start) {
-		error = split_vma(mm, vma, start, 1);
-		if (error)
+		if (unlikely(mm->map_count >= sysctl_max_map_count)) {
+			error = -ENOMEM;
 			goto out;
+		}
+		error = __split_vma(mm, vma, start, 1);
+		if (error) {
+			/*
+			 * madvise() returns EAGAIN if kernel resources, such as
+			 * slab, are temporarily unavailable.
+			 */
+			if (error == -ENOMEM)
+				error = -EAGAIN;
+			goto out;
+		}
 	}
 
 	if (end != vma->vm_end) {
-		error = split_vma(mm, vma, end, 0);
-		if (error)
+		if (unlikely(mm->map_count >= sysctl_max_map_count)) {
+			error = -ENOMEM;
+			goto out;
+		}
+		error = __split_vma(mm, vma, end, 0);
+		if (error) {
+			/*
+			 * madvise() returns EAGAIN if kernel resources, such as
+			 * slab, are temporarily unavailable.
+			 */
+			if (error == -ENOMEM)
+				error = -EAGAIN;
 			goto out;
+		}
 	}
 
 success:
@@ -133,10 +169,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
 	vma->vm_flags = new_flags;
-
 out:
-	if (error == -ENOMEM)
-		error = -EAGAIN;
 	return error;
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2495,11 +2495,11 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 /*
- * __split_vma() bypasses sysctl_max_map_count checking.  We use this on the
- * munmap path where it doesn't make sense to fail.
+ * __split_vma() bypasses sysctl_max_map_count checking.  We use this where it
+ * has already been checked or doesn't make sense to fail.
  */
-static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
-	      unsigned long addr, int new_below)
+int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long addr, int new_below)
 {
 	struct vm_area_struct *new;
 	int err;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
