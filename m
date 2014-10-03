Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 78E7A6B0069
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 23:41:32 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id r10so752402igi.14
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 20:41:32 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id z13si1024995igg.1.2014.10.02.20.41.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 20:41:31 -0700 (PDT)
Received: by mail-ig0-f181.google.com with SMTP id r10so752317igi.14
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 20:41:30 -0700 (PDT)
From: Daniel Micay <danielmicay@gmail.com>
Subject: [PATCH v4] mm: add mremap flag for preserving the old mapping
Date: Thu,  2 Oct 2014 23:41:19 -0400
Message-Id: <1412307679-2458-1-git-send-email-danielmicay@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, jasone@canonware.com, luto@amacapital.net, Daniel Micay <danielmicay@gmail.com>

This introduces the MREMAP_RETAIN flag for preserving the source mapping
when MREMAP_MAYMOVE moves the pages to a new destination. Accesses to
the source mapping will fault and map in fresh zeroed pages.

It is currently limited to writable MAP_PRIVATE|MAP_ANONYMOUS mappings
and will return EFAULT when used on anything else. This covers the
intended use case in general purpose allocators.

For consistency, the old_len >= new_len case could decommit the pages
instead of unmapping. However, userspace can accomplish the same thing
via madvise and the flag is coherent without the additional complexity.

Motivation:

TCMalloc and jemalloc avoid releasing virtual memory in order to reduce
virtual memory fragmentation. A call to munmap or mremap would leave a
hole in the address space. Instead, unused pages are lazily returned to
the operating system via MADV_DONTNEED.

Since mremap cannot be used to elide copies, TCMalloc and jemalloc end
up being significantly slower for patterns like repeated vector / hash
table reallocations. Consider the typical vector building pattern:

    #include <string.h>
    #include <stdlib.h>

    int main(void) {
        for (size_t i = 0; i < 100; i++) {
            void *ptr = NULL;
            size_t old_size = 0;
            for (size_t size = 4; size < (1 << 30); size *= 2) {
                ptr = realloc(ptr, size);
                if (!ptr) return 1;
                memset(ptr + old_size, 0xff, size - old_size);
                old_size = size;
            }
            free(ptr);
        }
    }

Transparent huge pages disabled:

glibc (baseline, uses mremap already): 15.051s
jemalloc without MREMAP_RETAIN: 38.540s
jemalloc with MREMAP_RETAIN: 15.086s

Transparent huge pages enabled:

glibc (baseline, uses mremap already): 8.464s
jemalloc without MREMAP_RETAIN: 18.230s
jemalloc with MREMAP_RETAIN: 6.696s

In practice, in-place growth never occurs for huge allocations because
the heap grows in the downwards direction for all 3 allocators. TCMalloc
and jemalloc pay for enormous copies while glibc is only spending time
writing new elements to the vector. Even if it was grown in the other
direction, real-world applications would end up blocking in-place growth
with new allocations.

The allocators could attempt to map the source location again after an
mremap call, but there is no guarantee of success in a multi-threaded
program and fragmentating memory over time is considered unacceptable.

Signed-off-by: Daniel Micay <danielmicay@gmail.com>
---
 include/linux/huge_mm.h   |  2 +-
 include/linux/mm.h        |  6 ++++++
 include/uapi/linux/mman.h |  1 +
 mm/huge_memory.c          |  4 ++--
 mm/memory.c               |  2 +-
 mm/mmap.c                 | 12 +++++++++++
 mm/mremap.c               | 52 +++++++++++++++++++++++++++++++----------------
 7 files changed, 57 insertions(+), 22 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 63579cb..3c13b20 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -143,7 +143,7 @@ static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 					 unsigned long end,
 					 long adjust_next)
 {
-	if (!vma->anon_vma || vma->vm_ops)
+	if (!vma->anon_vma || (vma->vm_ops && !vma->vm_ops->allow_huge_pages))
 		return;
 	__vma_adjust_trans_huge(vma, start, end, adjust_next);
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8981cc8..1e61036 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -273,6 +273,12 @@ struct vm_operations_struct {
 	/* called by sys_remap_file_pages() to populate non-linear mapping */
 	int (*remap_pages)(struct vm_area_struct *vma, unsigned long addr,
 			   unsigned long size, pgoff_t pgoff);
+
+	/* Check if the mapping may be duplicated by MREMAP_RETAIN */
+	bool (*may_duplicate)(struct vm_area_struct *vma);
+
+	/* if there is no vm_ops table, this is considered true */
+	bool allow_huge_pages;
 };
 
 struct mmu_gather;
diff --git a/include/uapi/linux/mman.h b/include/uapi/linux/mman.h
index ade4acd..4e9a546 100644
--- a/include/uapi/linux/mman.h
+++ b/include/uapi/linux/mman.h
@@ -5,6 +5,7 @@
 
 #define MREMAP_MAYMOVE	1
 #define MREMAP_FIXED	2
+#define MREMAP_RETAIN	4
 
 #define OVERCOMMIT_GUESS		0
 #define OVERCOMMIT_ALWAYS		1
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d9a21d06..350b478 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2077,7 +2077,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
 		 * page fault if needed.
 		 */
 		return 0;
-	if (vma->vm_ops)
+	if ((vma->vm_ops && !vma->vm_ops->allow_huge_pages))
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
 	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
@@ -2405,7 +2405,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 	    (vma->vm_flags & VM_NOHUGEPAGE))
 		return false;
 
-	if (!vma->anon_vma || vma->vm_ops)
+	if (!vma->anon_vma || (vma->vm_ops && !vma->vm_ops->allow_huge_pages))
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
diff --git a/mm/memory.c b/mm/memory.c
index e229970..c181401 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3275,7 +3275,7 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
 		int ret = VM_FAULT_FALLBACK;
-		if (!vma->vm_ops)
+		if (!vma->vm_ops || vma->vm_ops->allow_huge_pages)
 			ret = do_huge_pmd_anonymous_page(mm, vma, address,
 					pmd, flags);
 		if (!(ret & VM_FAULT_FALLBACK))
diff --git a/mm/mmap.c b/mm/mmap.c
index c0a3637..6b644fe 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1500,6 +1500,16 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
 }
 
+static bool anon_may_duplicate(struct vm_area_struct *vma)
+{
+	return vma->vm_flags & VM_WRITE && !(vma->vm_flags & VM_SHARED);
+}
+
+static const struct vm_operations_struct anon_vmops = {
+	.may_duplicate = anon_may_duplicate,
+	.allow_huge_pages = true
+};
+
 unsigned long mmap_region(struct file *file, unsigned long addr,
 		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff)
 {
@@ -1569,6 +1579,8 @@ munmap_back:
 	vma->vm_flags = vm_flags;
 	vma->vm_page_prot = vm_get_page_prot(vm_flags);
 	vma->vm_pgoff = pgoff;
+	if (!file)
+		vma->vm_ops = &anon_vmops;
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 
 	if (file) {
diff --git a/mm/mremap.c b/mm/mremap.c
index 05f1180..ca7a662 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -235,7 +235,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
 static unsigned long move_vma(struct vm_area_struct *vma,
 		unsigned long old_addr, unsigned long old_len,
-		unsigned long new_len, unsigned long new_addr, bool *locked)
+		unsigned long new_len, unsigned long new_addr, bool retain,
+		bool *locked)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma;
@@ -287,15 +288,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		old_len = new_len;
 		old_addr = new_addr;
 		new_addr = -ENOMEM;
-	}
-
-	/* Conceal VM_ACCOUNT so old reservation is not undone */
-	if (vm_flags & VM_ACCOUNT) {
-		vma->vm_flags &= ~VM_ACCOUNT;
-		excess = vma->vm_end - vma->vm_start - old_len;
-		if (old_addr > vma->vm_start &&
-		    old_addr + old_len < vma->vm_end)
-			split = 1;
+		retain = false;
 	}
 
 	/*
@@ -310,6 +303,19 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	hiwater_vm = mm->hiwater_vm;
 	vm_stat_account(mm, vma->vm_flags, vma->vm_file, new_len>>PAGE_SHIFT);
 
+	/* Leave the old mapping in place for MREMAP_RETAIN */
+	if (retain)
+		goto out;
+
+	/* Conceal VM_ACCOUNT so old reservation is not undone */
+	if (vm_flags & VM_ACCOUNT) {
+		vma->vm_flags &= ~VM_ACCOUNT;
+		excess = vma->vm_end - vma->vm_start - old_len;
+		if (old_addr > vma->vm_start &&
+		    old_addr + old_len < vma->vm_end)
+			split = 1;
+	}
+
 	if (do_munmap(mm, old_addr, old_len) < 0) {
 		/* OOM: unable to split vma, just get accounts right */
 		vm_unacct_memory(excess >> PAGE_SHIFT);
@@ -324,6 +330,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 			vma->vm_next->vm_flags |= VM_ACCOUNT;
 	}
 
+out:
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += new_len >> PAGE_SHIFT;
 		*locked = true;
@@ -333,7 +340,8 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 }
 
 static struct vm_area_struct *vma_to_resize(unsigned long addr,
-	unsigned long old_len, unsigned long new_len, unsigned long *p)
+	unsigned long old_len, unsigned long new_len, bool retain,
+	unsigned long *p)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = find_vma(mm, addr);
@@ -348,6 +356,11 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	if (old_len > vma->vm_end - addr)
 		goto Efault;
 
+	/* Forbid MREMAP_RETAIN if not explicitly permitted by the mapping */
+	if (retain && !(vma->vm_ops && vma->vm_ops->may_duplicate &&
+	    vma->vm_ops->may_duplicate(vma)))
+		goto Efault;
+
 	/* Need to be careful about a growing mapping */
 	if (new_len > old_len) {
 		unsigned long pgoff;
@@ -392,7 +405,8 @@ Eagain:
 }
 
 static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
-		unsigned long new_addr, unsigned long new_len, bool *locked)
+		unsigned long new_addr, unsigned long new_len, bool retain,
+		bool *locked)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
@@ -426,7 +440,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 		old_len = new_len;
 	}
 
-	vma = vma_to_resize(addr, old_len, new_len, &charged);
+	vma = vma_to_resize(addr, old_len, new_len, retain, &charged);
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
 		goto out;
@@ -442,7 +456,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (ret & ~PAGE_MASK)
 		goto out1;
 
-	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked);
+	ret = move_vma(vma, addr, old_len, new_len, new_addr, retain, locked);
 	if (!(ret & ~PAGE_MASK))
 		goto out;
 out1:
@@ -482,7 +496,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	unsigned long charged = 0;
 	bool locked = false;
 
-	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
+	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE | MREMAP_RETAIN))
 		return ret;
 
 	if (flags & MREMAP_FIXED && !(flags & MREMAP_MAYMOVE))
@@ -506,7 +520,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 
 	if (flags & MREMAP_FIXED) {
 		ret = mremap_to(addr, old_len, new_addr, new_len,
-				&locked);
+				flags & MREMAP_RETAIN, &locked);
 		goto out;
 	}
 
@@ -526,7 +540,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	/*
 	 * Ok, we need to grow..
 	 */
-	vma = vma_to_resize(addr, old_len, new_len, &charged);
+	vma = vma_to_resize(addr, old_len, new_len, flags & MREMAP_RETAIN,
+			    &charged);
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
 		goto out;
@@ -575,7 +590,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 			goto out;
 		}
 
-		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked);
+		ret = move_vma(vma, addr, old_len, new_len, new_addr,
+			       flags & MREMAP_RETAIN, &locked);
 	}
 out:
 	if (ret & ~PAGE_MASK)
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
