Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id DDBAB6B005D
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 01:49:32 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id bi5so296127pad.27
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 22:49:31 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v4 1/3] Introduce new system call mvolatile
Date: Tue, 18 Dec 2012 15:47:52 +0900
Message-Id: <1355813274-571-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1355813274-571-1-git-send-email-minchan@kernel.org>
References: <1355813274-571-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch adds new system call m[no]volatile. If some user asks
is_volatile system call, it could, too.

The reason why I introduced new system call instead of madvise is
m[no]volatile vma handling is totally different with madvise's vma
handling.

1) The m[no]volatile should be successful although the range includes
   unmapped or non-volatile range. It just skips such range without stop
   with returning error although it encounter invalid range.
   It makes user convenient without calling several calling of small range.
   - Suggested by John Stultz

2) The propagation of purged state between vmas should be atomic between
   m[no]volatile and reclaim. For it, we need to tweak vma_merge/split_vma's
   anon_vma handling. It's very common operation and I don't want to add
   unnecessary overhead and code if it is possbile.

3) The purged state of volatile range should be propagated out to user
   with mnovolatile operation and it should be atomic with reclaim, too.

For meeting above requirements, I introudced new system call m[no]volatile.
It doesn't change vma_merge/split and repair vmas after vma operation.

So mvolatile(start, len)'s semantics is following as.

1) It makes range(start, len) as volatile although the range includes
   unmapped area, speacial mapping and mlocked area which are just skipped.
   Now it doesn't support Hugepage and KSM. - TODO
   Return -EINVAL if range doesn't include a right vma at all.
   Return -ENOMEM with interrupting range opeartion if memory is not
   enough to merge/split vmas. In this case, some range would be volatile
   and others not. So user have to recall mvolatile after he cancel all
   range by mnovolatile.
   Return 0 if range consists of only proper vmas.
   Return 1 if part of range includes hole/huge/ksm/mlock/special area.

2) If user calls mvolatile to the range which was already volatile VMA and
   even purged state, VOLATILE attributes still remains but purged state
   is reset. I expect some user want to split volatile vma into smaller
   ranges. Although he can do it for mnovlatile(whole range) and serveral calling
   with movlatile(smaller range), this function can avoid mnovolatile if he
   doesn't care purged state. I'm not sure we really need this function so
   I hope listen opinions. Unfortunately, current implemenation doesn't split
   volatile VMA with new range in this case. I forgot implementing it
   in this version but decide to send it to listen opinions because implementing
   is rather trivial if we decided.

mnovolatile(start, len)'s semantics is following as.

1) It makes range(start, len) as volatile although the range includes
   unmapped area, speacial mapping and non-volatile range which are just
   skipped.

2) If the range is purged, it will return 1 regardless of including invalid
   range.

3) It returns -ENOMEM if system doesn't have enough memory for vma operation.

4) It returns -EINVAL if range doesn't include a right vma at all.

5) If user try to access purged range without mnovoatile call, it encounters
   SIGBUS which would show up next patch.

Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Arun Sharma <asharma@fb.com>
Cc: sanjay@google.com
Cc: Paul Turner <pjt@google.com>
CC: David Rientjes <rientjes@google.com>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/x86/syscalls/syscall_64.tbl |    3 +-
 include/linux/mm.h               |    1 +
 include/linux/mm_types.h         |    2 +
 include/linux/syscalls.h         |    2 +
 mm/Makefile                      |    4 +-
 mm/huge_memory.c                 |    9 +-
 mm/ksm.c                         |    3 +-
 mm/mlock.c                       |    5 +-
 mm/mmap.c                        |    2 +-
 mm/mvolatile.c                   |  396 ++++++++++++++++++++++++++++++++++++++
 mm/rmap.c                        |    2 +
 11 files changed, 419 insertions(+), 10 deletions(-)
 create mode 100644 mm/mvolatile.c

diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index a582bfe..7da9c4a 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -319,7 +319,8 @@
 310	64	process_vm_readv	sys_process_vm_readv
 311	64	process_vm_writev	sys_process_vm_writev
 312	common	kcmp			sys_kcmp
-
+313	common	mvolatile		sys_mvolatile
+314	common	mnovolatile		sys_mnovolatile
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
 # for native 64-bit operation.
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bcaab4e..94742c4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -87,6 +87,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
+#define VM_VOLATILE	0x00001000	/* Pages could be discarded without swapout */
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 31f8a3a..ef2a4a4 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -275,6 +275,8 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	/* Page in this vma was discarded*/
+	bool purged;			/* Serialized by anon_vma's mutex */
 };
 
 struct core_thread {
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 727f0cd..a8ded1c 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -470,6 +470,8 @@ asmlinkage long sys_munlock(unsigned long start, size_t len);
 asmlinkage long sys_mlockall(int flags);
 asmlinkage long sys_munlockall(void);
 asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
+asmlinkage long sys_mvolatile(unsigned long start, size_t len);
+asmlinkage long sys_mnovolatile(unsigned long start, size_t len);
 asmlinkage long sys_mincore(unsigned long start, size_t len,
 				unsigned char __user * vec);
 
diff --git a/mm/Makefile b/mm/Makefile
index 6b025f8..962b69f 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -4,8 +4,8 @@
 
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
-			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o pagewalk.o pgtable-generic.o
+			   mvolatile.o mlock.o mmap.o mprotect.o mremap.o msync.o \
+			   rmap.o vmalloc.o pagewalk.o pgtable-generic.o
 
 ifdef CONFIG_CROSS_MEMORY_ATTACH
 mmu-$(CONFIG_MMU)	+= process_vm_access.o
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 40f17c3..3fe062d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1477,7 +1477,7 @@ out:
 	return ret;
 }
 
-#define VM_NO_THP (VM_SPECIAL|VM_MIXEDMAP|VM_HUGETLB|VM_SHARED|VM_MAYSHARE)
+#define VM_NO_THP (VM_SPECIAL|VM_MIXEDMAP|VM_HUGETLB|VM_SHARED|VM_MAYSHARE|VM_VOLATILE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
 		     unsigned long *vm_flags, int advice)
@@ -1641,8 +1641,11 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
 		 * page fault if needed.
 		 */
 		return 0;
-	if (vma->vm_ops)
-		/* khugepaged not yet working on file or special mappings */
+	if (vma->vm_ops || vma->vm_flags & VM_VOLATILE)
+		/*
+		 * khugepaged not yet working on file,special mappings
+		 * and volatile.
+		 */
 		return 0;
 	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
diff --git a/mm/ksm.c b/mm/ksm.c
index ae539f0..2775f59 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1486,7 +1486,8 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		 */
 		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
 				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
-				 VM_HUGETLB | VM_NONLINEAR | VM_MIXEDMAP))
+				 VM_HUGETLB | VM_NONLINEAR | VM_MIXEDMAP   |
+				 VM_VOLATILE))
 			return 0;		/* just ignore the advice */
 
 #ifdef VM_SAO
diff --git a/mm/mlock.c b/mm/mlock.c
index f0b9ce5..db3a477 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -316,8 +316,9 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	int ret = 0;
 	int lock = !!(newflags & VM_LOCKED);
 
-	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
-	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
+	if (newflags == vma->vm_flags || (vma->vm_flags &
+		 (VM_SPECIAL|VM_VOLATILE)) || is_vm_hugetlb_page(vma) ||
+		 vma == get_gate_vma(current->mm))
 		goto out;	/* don't set VM_LOCKED,  don't count */
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
diff --git a/mm/mmap.c b/mm/mmap.c
index 9a796c4..e4ac12d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -808,7 +808,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 	 * We later require that vma->vm_flags == vm_flags,
 	 * so this tests vma->vm_flags & VM_SPECIAL, too.
 	 */
-	if (vm_flags & VM_SPECIAL)
+	if (vm_flags & (VM_SPECIAL|VM_VOLATILE))
 		return NULL;
 
 	if (prev)
diff --git a/mm/mvolatile.c b/mm/mvolatile.c
new file mode 100644
index 0000000..ab5de2b
--- /dev/null
+++ b/mm/mvolatile.c
@@ -0,0 +1,396 @@
+/*
+ *	linux/mm/mvolatile.c
+ *
+ *  Copyright 2012 Minchan Kim
+ *
+ *  This work is licensed under the terms of the GNU GPL, version 2. See
+ *  the COPYING file in the top-level directory.
+ */
+
+#include <linux/mm_types.h>
+#include <linux/mm.h>
+#include <linux/syscalls.h>
+#include <linux/rmap.h>
+#include <linux/mempolicy.h>
+
+#define NO_PURGED	0
+#define PURGED		1
+
+/*
+ * N: Normal VMA
+ * P: Purged volatile VMA
+ * V: Volatile VMA
+ *
+ * Assume that each VMA has two block so case 1-8 consists of three VMA.
+ * For example, NNPPVV means VMA1 has normal VMA, VMA2 has purged volailte VMA,
+ * and VMA3 has volatile VMA. With another example, NNPVVV means VMA1 has normal VMA,
+ * VMA2-1 has purged volatile VMA, VMA2-2 has volatile VMA.
+ *
+ * Case 7,8 create a new VMA and we call it VMA4 which can be loated before VMA2
+ * or after.
+ *
+ * Notice: The merge between volatile VMAs shouldn't happen.
+ * If we call mnovolatile(VMA2),
+ *
+ * Case 1 NNPPVV -> NNNNVV
+ * Case 2 VVPPNN -> VVNNNN
+ * Case 3 NNPPNN -> NNNNNN
+ * Case 4 NNPPVV -> NNNPVV
+ * case 5 VVPPNN -> VVPNNN
+ * case 6 VVPPVV -> VVNNVV
+ * case 7 VVPPVV -> VVNPVV
+ * case 8 VVPPVV -> VVPNVV
+ */
+static int do_mnovolatile(struct vm_area_struct *vma,
+		struct vm_area_struct **prev, unsigned long start,
+		unsigned long end, bool *purged)
+{
+	pgoff_t pgoff;
+	bool old_purged;
+	unsigned long this_start, this_end;
+	unsigned long next_start, next_end;
+	vm_flags_t new_flags, old_flags;
+	struct mm_struct *mm = vma->vm_mm;
+	int error = 0;
+	struct vm_area_struct *next = NULL;
+	next_start = next_end = 0;
+
+	old_flags = vma->vm_flags;
+	new_flags = old_flags & ~VM_VOLATILE;
+
+	if (new_flags == vma->vm_flags) {
+		*prev = vma;
+		goto success;
+	}
+
+	/*
+	 * From now on, purged state is freezed so closing the race with
+	 * reclaim. It makes works easy.
+	 */
+	vma_lock_anon_vma(vma);
+	vma->vm_flags = new_flags;
+	vma_unlock_anon_vma(vma);
+
+	/*
+	 * Setting vm_flags before vma adjust/split has a problem about
+	 * flag propatation or when error happens during the operation.
+	 * For preventing, we need more tweaking.
+	 */
+	old_purged = vma->purged;
+	*purged |= old_purged;
+	vma->purged = false;
+
+	this_start = vma->vm_start;
+	this_end = vma->vm_end;
+
+	if (*prev) {
+		next = (*prev)->vm_next;
+		if (next) {
+			next_start = next->vm_start;
+			next_end = next->vm_end;
+		}
+	}
+
+	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
+	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
+			vma->vm_file, pgoff, vma_policy(vma));
+	if (*prev) {
+		/* case 1 -> Nothing */
+		/* case 2 -> Nothing */
+		/* case 3 -> Nothing */
+		/* case 4 -> Set VMA2-2 with old_flags and old_purged */
+		/* case 5 -> Set VMA2-1 with old_flags and old_purged */
+		if ((*prev)->vm_end == this_end) /* case 1 */
+			goto next;
+		else if ((*prev)->vm_end == next_end) /* case 2 */
+			goto next;
+		else if ((*prev)->vm_end > next_end) /* case 3 */
+			goto next;
+		else if ((*prev)->vm_end > this_start) { /* case 4 */
+			vma_lock_anon_vma(next);
+			next->vm_flags = old_flags;
+			next->purged = old_purged;
+			vma_unlock_anon_vma(next);
+		} else if ((*prev)->vm_end < this_end) { /* case 5 */
+			vma_lock_anon_vma(*prev);
+			(*prev)->vm_flags = old_flags;
+			(*prev)->purged = old_purged;
+			vma_unlock_anon_vma(*prev);
+		}
+next:
+		vma = *prev;
+		goto success;
+	}
+
+	*prev = vma;
+
+	if (start != vma->vm_start) {
+		struct vm_area_struct *tmp_vma;
+		error = split_vma(mm, vma, start, 1);
+		if (error)
+			goto out;
+		/* case 8 -> Set VMA4 with old_flags and old_purged */
+		tmp_vma = vma->vm_prev;
+		vma_lock_anon_vma(tmp_vma);
+		tmp_vma->vm_flags = old_flags;
+		tmp_vma->purged = old_purged;
+		vma_unlock_anon_vma(tmp_vma);
+	}
+
+	if (end != vma->vm_end) {
+		struct vm_area_struct *tmp_vma;
+		error = split_vma(mm, vma, end, 0);
+		if (error)
+			goto out;
+		/* case 7 -> Set VMA4 with old_flags and old_purged */
+		tmp_vma = vma->vm_next;
+		vma_lock_anon_vma(tmp_vma);
+		tmp_vma->vm_flags = old_flags;
+		tmp_vma->purged = old_purged;
+		vma_unlock_anon_vma(tmp_vma);
+	}
+
+success:
+	return 0;
+out:
+	vma_lock_anon_vma(vma);
+	vma->vm_flags = old_flags;
+	vma->purged = old_purged;
+	vma_unlock_anon_vma(vma);
+	return error;
+}
+
+/* I didn't look into KSM/Hugepage so disalbed them */
+#define VM_NO_VOLATILE	(VM_SPECIAL|VM_MIXEDMAP|VM_HUGETLB|\
+				VM_MERGEABLE|VM_HUGEPAGE|VM_LOCKED)
+
+static int do_mvolatile(struct vm_area_struct *vma, struct vm_area_struct **prev,
+		unsigned long start, unsigned long end)
+{
+	int error = -EINVAL;
+	vm_flags_t new_flags = vma->vm_flags;
+	struct mm_struct *mm = vma->vm_mm;
+
+	new_flags |= VM_VOLATILE;
+
+	/* Note : Current version doesn't support file vma volatile */
+	if (vma->vm_file) {
+		*prev = vma;
+		goto out;
+	}
+
+	if (vma->vm_flags & VM_NO_VOLATILE ||
+			(vma == get_gate_vma(current->mm))) {
+		*prev = vma;
+		goto out;
+	}
+	/*
+	 * In case of calling MADV_VOLATILE again,
+	 * We just reset purged state.
+	 */
+	if (new_flags == vma->vm_flags) {
+		*prev = vma;
+		vma_lock_anon_vma(vma);
+		vma->purged = false;
+		vma_unlock_anon_vma(vma);
+		error = 0;
+		goto out;
+	}
+
+	*prev = vma;
+
+	if (start != vma->vm_start) {
+		error = split_vma(mm, vma, start, 1);
+		if (error)
+			goto out;
+	}
+
+	if (end != vma->vm_end) {
+		error = split_vma(mm, vma, end, 0);
+		if (error)
+			goto out;
+	}
+
+	error = 0;
+
+	vma_lock_anon_vma(vma);
+	vma->vm_flags = new_flags;
+	vma_unlock_anon_vma(vma);
+out:
+	return error;
+}
+
+/*
+ * Return -EINVAL if range doesn't include a right vma at all.
+ * Return -ENOMEM with interrupting range opeartion if memory is not enough to
+ * merge/split vmas.
+ * Return 0 if range consists of only proper vmas.
+ * Return 1 if part of range includes hole/huge/ksm/mlock/special area.
+ */
+SYSCALL_DEFINE2(mvolatile, unsigned long, start, size_t, len)
+{
+	unsigned long end, tmp;
+	struct vm_area_struct *vma, *prev;
+	bool invalid = false;
+	int error = -EINVAL;
+
+	down_write(&current->mm->mmap_sem);
+	if (start & ~PAGE_MASK)
+		goto out;
+
+	len &= PAGE_MASK;
+	if (!len)
+		goto out;
+
+	end = start + len;
+	if (end < start)
+		goto out;
+
+	vma = find_vma_prev(current->mm, start, &prev);
+	if (!vma)
+		goto out;
+
+	if (start > vma->vm_start)
+		prev = vma;
+
+	for (;;) {
+		/* Here start < (end|vma->vm_end). */
+		if (start < vma->vm_start) {
+			start = vma->vm_start;
+			if (start >= end)
+				goto out;
+			invalid = true;
+		}
+
+		/* Here vma->vm_start <= start < (end|vma->vm_end) */
+		tmp = vma->vm_end;
+		if (end < tmp)
+			tmp = end;
+
+		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
+		error = do_mvolatile(vma, &prev, start, tmp);
+		if (error == -ENOMEM) {
+			up_write(&current->mm->mmap_sem);
+			return error;
+		}
+		if (error == -EINVAL)
+			invalid = true;
+		else
+			error = 0;
+		start = tmp;
+		if (prev && start < prev->vm_end)
+			start = prev->vm_end;
+		if (start >= end)
+			break;
+
+		vma = prev->vm_next;
+		if (!vma)
+			break;
+	}
+out:
+	up_write(&current->mm->mmap_sem);
+	return invalid ? 1 : 0;
+}
+
+SYSCALL_DEFINE2(mnovolatile, unsigned long, start, size_t, len)
+{
+	unsigned long end, tmp;
+	struct vm_area_struct *vma, *prev;
+	int ret, error = -EINVAL;
+	bool purged = false;
+
+	down_write(&current->mm->mmap_sem);
+	if (start & ~PAGE_MASK)
+		goto out;
+
+	len &= PAGE_MASK;
+	if (!len)
+		goto out;
+
+	end = start + len;
+	if (end < start)
+		goto out;
+
+	vma = find_vma_prev(current->mm, start, &prev);
+	if (!vma)
+		goto out;
+
+	if (start > vma->vm_start)
+		prev = vma;
+
+	for (;;) {
+		/* Here start < (end|vma->vm_end). */
+		if (start < vma->vm_start) {
+			start = vma->vm_start;
+			if (start >= end)
+				goto out;
+		}
+
+		/* Here vma->vm_start <= start < (end|vma->vm_end) */
+		tmp = vma->vm_end;
+		if (end < tmp)
+			tmp = end;
+
+		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
+		error = do_mnovolatile(vma, &prev, start, tmp, &purged);
+		if (error) {
+			WARN_ON(error != -ENOMEM);
+			goto out;
+		}
+		start = tmp;
+		if (prev && start < prev->vm_end)
+			start = prev->vm_end;
+		if (start >= end)
+			break;
+
+		vma = prev->vm_next;
+		if (!vma)
+			break;
+	}
+out:
+	up_write(&current->mm->mmap_sem);
+
+	if (error)
+		ret = error;
+	else if (purged)
+		ret = PURGED;
+	else
+		ret = NO_PURGED;
+
+	return ret;
+}
+
+/* Not intend to merge, Just test */
+SYSCALL_DEFINE2(mpurge, unsigned long, start, size_t, len)
+{
+	int error = -EINVAL;
+	unsigned long end;
+	struct vm_area_struct *vma;
+
+	down_read(&current->mm->mmap_sem);
+	if (start & ~PAGE_MASK)
+		goto out;
+
+	len &= PAGE_MASK;
+	if (!len)
+		goto out;
+
+	end = start + len;
+	if (end < start)
+		goto out;
+
+	vma = find_vma(current->mm, start);
+	if (!vma || vma->vm_start >= end)
+		goto out;
+
+	if (!(vma->vm_flags & VM_VOLATILE))
+		goto out;
+
+	vma_lock_anon_vma(vma);
+	vma->purged = true;
+	vma_unlock_anon_vma(vma);
+out:
+	up_read(&current->mm->mmap_sem);
+
+	return error;
+}
diff --git a/mm/rmap.c b/mm/rmap.c
index 2ee1ef0..7f4493c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -308,6 +308,8 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	vma->anon_vma = anon_vma;
 	anon_vma_lock(anon_vma);
 	anon_vma_chain_link(vma, avc, anon_vma);
+	/* Propagate parent's purged state to child */
+	vma->purged = pvma->purged;
 	anon_vma_unlock(anon_vma);
 
 	return 0;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
