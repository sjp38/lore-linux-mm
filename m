Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id CB18C6B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 00:55:11 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id uq10so2461388igb.12
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:55:11 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id o1si13230543igw.22.2014.09.29.21.55.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 21:55:11 -0700 (PDT)
Received: by mail-ie0-f170.google.com with SMTP id rd18so1302476iec.15
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:55:10 -0700 (PDT)
From: Daniel Micay <danielmicay@gmail.com>
Subject: [PATCH v3] mm: add mremap flag for preserving the old mapping
Date: Tue, 30 Sep 2014 00:55:00 -0400
Message-Id: <1412052900-1722-1-git-send-email-danielmicay@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, jasone@canonware.com, Daniel Micay <danielmicay@gmail.com>

This introduces the MREMAP_RETAIN flag for preserving the source mapping
when MREMAP_MAYMOVE moves the pages to a new destination. Accesses to
the source location will fault and cause fresh pages to be mapped in.

For consistency, the old_len >= new_len case could decommit the pages
instead of unmapping. However, userspace can accomplish the same thing
via madvise and a coherent definition of the flag is possible without
the extra complexity.

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
        void *ptr = NULL;
        size_t old_size = 0;
        for (size_t size = 4; size < (1 << 30); size *= 2) {
            ptr = realloc(ptr, size);
            if (!ptr) return 1;
            memset(ptr + old_size, 0xff, size - old_size);
            old_size = size;
        }
    }

glibc (baseline, uses mremap already): 0.135s

jemalloc without MREMAP_RETAIN: 0.226s
jemalloc with MREMAP_RETAIN: 0.112s

TCMalloc without MREMAP_RETAIN: 0.238s
(the improvement should be similar to jemalloc)

In practice, in-place growth never occurs because the heap grows in the
downwards direction for all 3 allocators. TCMalloc and jemalloc pay for
enormous copies while glibc is only spending time writing new elements
to the vector. Even if it was grown in the other direction, real-world
applications would end up blocking in-place growth with new allocations.

The allocators could attempt to map the source location again after an
mremap call, but there is no guarantee of success in a multi-threaded
program and fragmentating memory over time is considered unacceptable.

Signed-off-by: Daniel Micay <danielmicay@gmail.com>
---
 include/uapi/linux/mman.h |  1 +
 mm/mremap.c               | 39 ++++++++++++++++++++++++---------------
 2 files changed, 25 insertions(+), 15 deletions(-)

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
diff --git a/mm/mremap.c b/mm/mremap.c
index 05f1180..079334a 100644
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
 
+	/* Leave the old mapping in place for MREMAP_RETAIN. */
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
@@ -392,7 +399,8 @@ Eagain:
 }
 
 static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
-		unsigned long new_addr, unsigned long new_len, bool *locked)
+		unsigned long new_addr, unsigned long new_len, bool retain,
+		bool *locked)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
@@ -442,7 +450,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (ret & ~PAGE_MASK)
 		goto out1;
 
-	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked);
+	ret = move_vma(vma, addr, old_len, new_len, new_addr, retain, locked);
 	if (!(ret & ~PAGE_MASK))
 		goto out;
 out1:
@@ -482,7 +490,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	unsigned long charged = 0;
 	bool locked = false;
 
-	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
+	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE | MREMAP_RETAIN))
 		return ret;
 
 	if (flags & MREMAP_FIXED && !(flags & MREMAP_MAYMOVE))
@@ -506,7 +514,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 
 	if (flags & MREMAP_FIXED) {
 		ret = mremap_to(addr, old_len, new_addr, new_len,
-				&locked);
+				flags & MREMAP_RETAIN, &locked);
 		goto out;
 	}
 
@@ -575,7 +583,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 			goto out;
 		}
 
-		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked);
+		ret = move_vma(vma, addr, old_len, new_len, new_addr,
+			       flags & MREMAP_RETAIN, &locked);
 	}
 out:
 	if (ret & ~PAGE_MASK)
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
