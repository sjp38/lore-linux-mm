Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A34536B0071
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 14:19:17 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so99939699pab.0
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 11:19:17 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTP id kn8si3626925pab.32.2015.02.03.11.19.16
        for <linux-mm@kvack.org>;
        Tue, 03 Feb 2015 11:19:16 -0800 (PST)
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t13JEwH7018501
	for <linux-mm@kvack.org>; Tue, 3 Feb 2015 11:19:16 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1sb2cugaap-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <linux-mm@kvack.org>; Tue, 03 Feb 2015 11:19:16 -0800
Received: from facebook.com (2401:db00:20:7003:face:0:4d:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 8999bf7aabd911e481af0002c991e86a-ebd4390 for <linux-mm@kvack.org>;	Tue, 03
 Feb 2015 11:19:13 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC] mremap: add MREMAP_NOHOLE flag
Date: Tue, 3 Feb 2015 11:19:12 -0800
Message-ID: <7064772f72049de8a79383105f49b5db84a946e5.1422990665.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: danielmicay@gmail.com, Kernel-team@fb.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>

There was a similar patch posted before, but it doesn't get merged. I'd like
to try again if there are more discussions.
http://marc.info/?l=linux-mm&m=141230769431688&w=2

mremap can be used to accelerate realloc. The problem is mremap will
punch a hole in original VMA, which makes specific memory allocator
unable to utilize it. Jemalloc is an example. It manages memory in 4M
chunks. mremap a range of the chunk will punch a hole, which other
mmap() syscall can fill into. The 4M chunk is then fragmented, jemalloc
can't handle it.

This patch adds a new flag for mremap. With it, mremap will not punch the
hole. page tables of original vma will be zapped in the same way, but
vma is still there. That is original vma will look like a vma without
pagefault. Behavior of new vma isn't changed.

For private vma, accessing original vma will cause
page fault and just like the address of the vma has never been accessed.
So for anonymous, new page/zero page will be fault in. For file mapping,
new page will be allocated with file reading for cow, or pagefault will
use existing page cache.

For shared vma, original and new vma will map to the same file. We can
optimize this without zaping original vma's page table in this case, but
this patch doesn't do it yet.

Since with MREMAP_NOHOLE, original vma still exists. pagefault handler
for special vma might not able to handle pagefault for mremap'd area.
The patch doesn't allow vmas with VM_PFNMAP|VM_MIXEDMAP flags do NOHOLE
mremap.

Cc: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/uapi/linux/mman.h |  1 +
 mm/mremap.c               | 97 ++++++++++++++++++++++++++++++++---------------
 2 files changed, 67 insertions(+), 31 deletions(-)

diff --git a/include/uapi/linux/mman.h b/include/uapi/linux/mman.h
index ade4acd..9ee9a15 100644
--- a/include/uapi/linux/mman.h
+++ b/include/uapi/linux/mman.h
@@ -5,6 +5,7 @@
 
 #define MREMAP_MAYMOVE	1
 #define MREMAP_FIXED	2
+#define MREMAP_NOHOLE	4
 
 #define OVERCOMMIT_GUESS		0
 #define OVERCOMMIT_ALWAYS		1
diff --git a/mm/mremap.c b/mm/mremap.c
index 3b886dc..ea3f40d 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -236,7 +236,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
 static unsigned long move_vma(struct vm_area_struct *vma,
 		unsigned long old_addr, unsigned long old_len,
-		unsigned long new_len, unsigned long new_addr, bool *locked)
+		unsigned long new_len, unsigned long new_addr, bool *locked,
+		bool nohole)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma;
@@ -292,7 +293,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
 
 	/* Conceal VM_ACCOUNT so old reservation is not undone */
-	if (vm_flags & VM_ACCOUNT) {
+	if ((vm_flags & VM_ACCOUNT) && !nohole) {
 		vma->vm_flags &= ~VM_ACCOUNT;
 		excess = vma->vm_end - vma->vm_start - old_len;
 		if (old_addr > vma->vm_start &&
@@ -312,11 +313,18 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	hiwater_vm = mm->hiwater_vm;
 	vm_stat_account(mm, vma->vm_flags, vma->vm_file, new_len>>PAGE_SHIFT);
 
-	if (do_munmap(mm, old_addr, old_len) < 0) {
+	if (!nohole && do_munmap(mm, old_addr, old_len) < 0) {
 		/* OOM: unable to split vma, just get accounts right */
 		vm_unacct_memory(excess >> PAGE_SHIFT);
 		excess = 0;
 	}
+
+	if (nohole && (new_addr & ~PAGE_MASK)) {
+		/* caller will unaccount */
+		vma->vm_flags &= ~VM_ACCOUNT;
+		do_munmap(mm, old_addr, old_len);
+	}
+
 	mm->hiwater_vm = hiwater_vm;
 
 	/* Restore VM_ACCOUNT if one or two pieces of vma left */
@@ -334,14 +342,13 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	return new_addr;
 }
 
-static struct vm_area_struct *vma_to_resize(unsigned long addr,
-	unsigned long old_len, unsigned long new_len, unsigned long *p)
+static unsigned long validate_vma_and_charge(struct vm_area_struct *vma,
+	unsigned long addr,
+	unsigned long old_len, unsigned long new_len, unsigned long *p,
+	bool nohole)
 {
 	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma = find_vma(mm, addr);
-
-	if (!vma || vma->vm_start > addr)
-		goto Efault;
+	unsigned long diff;
 
 	if (is_vm_hugetlb_page(vma))
 		goto Einval;
@@ -350,6 +357,9 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	if (old_len > vma->vm_end - addr)
 		goto Efault;
 
+	if (nohole && (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP)))
+		goto Einval;
+
 	/* Need to be careful about a growing mapping */
 	if (new_len > old_len) {
 		unsigned long pgoff;
@@ -362,39 +372,45 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 			goto Einval;
 	}
 
+	if (nohole)
+		diff = new_len;
+	else
+		diff = new_len - old_len;
+
 	if (vma->vm_flags & VM_LOCKED) {
 		unsigned long locked, lock_limit;
 		locked = mm->locked_vm << PAGE_SHIFT;
 		lock_limit = rlimit(RLIMIT_MEMLOCK);
-		locked += new_len - old_len;
+		locked += diff;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
 			goto Eagain;
 	}
 
-	if (!may_expand_vm(mm, (new_len - old_len) >> PAGE_SHIFT))
+	if (!may_expand_vm(mm, diff >> PAGE_SHIFT))
 		goto Enomem;
 
 	if (vma->vm_flags & VM_ACCOUNT) {
-		unsigned long charged = (new_len - old_len) >> PAGE_SHIFT;
+		unsigned long charged = diff >> PAGE_SHIFT;
 		if (security_vm_enough_memory_mm(mm, charged))
 			goto Efault;
 		*p = charged;
 	}
 
-	return vma;
+	return 0;
 
 Efault:	/* very odd choice for most of the cases, but... */
-	return ERR_PTR(-EFAULT);
+	return -EFAULT;
 Einval:
-	return ERR_PTR(-EINVAL);
+	return -EINVAL;
 Enomem:
-	return ERR_PTR(-ENOMEM);
+	return -ENOMEM;
 Eagain:
-	return ERR_PTR(-EAGAIN);
+	return -EAGAIN;
 }
 
 static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
-		unsigned long new_addr, unsigned long new_len, bool *locked)
+		unsigned long new_addr, unsigned long new_len, bool *locked,
+		bool nohole)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
@@ -422,17 +438,23 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 		goto out;
 
 	if (old_len >= new_len) {
-		ret = do_munmap(mm, addr+new_len, old_len - new_len);
-		if (ret && old_len != new_len)
-			goto out;
+		if (!nohole) {
+			ret = do_munmap(mm, addr+new_len, old_len - new_len);
+			if (ret && old_len != new_len)
+				goto out;
+		}
 		old_len = new_len;
 	}
 
-	vma = vma_to_resize(addr, old_len, new_len, &charged);
-	if (IS_ERR(vma)) {
-		ret = PTR_ERR(vma);
+	vma = find_vma(mm, addr);
+	if (!vma || vma->vm_start > addr) {
+		ret = -EFAULT;
 		goto out;
 	}
+	ret = validate_vma_and_charge(vma, addr, old_len, new_len, &charged,
+		nohole);
+	if (ret)
+		goto out;
 
 	map_flags = MAP_FIXED;
 	if (vma->vm_flags & VM_MAYSHARE)
@@ -444,7 +466,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (ret & ~PAGE_MASK)
 		goto out1;
 
-	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked);
+	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked, nohole);
 	if (!(ret & ~PAGE_MASK))
 		goto out;
 out1:
@@ -483,8 +505,9 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	unsigned long ret = -EINVAL;
 	unsigned long charged = 0;
 	bool locked = false;
+	bool nohole = flags & MREMAP_NOHOLE;
 
-	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
+	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE | MREMAP_NOHOLE))
 		return ret;
 
 	if (flags & MREMAP_FIXED && !(flags & MREMAP_MAYMOVE))
@@ -508,7 +531,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 
 	if (flags & MREMAP_FIXED) {
 		ret = mremap_to(addr, old_len, new_addr, new_len,
-				&locked);
+				&locked, nohole);
 		goto out;
 	}
 
@@ -528,9 +551,9 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	/*
 	 * Ok, we need to grow..
 	 */
-	vma = vma_to_resize(addr, old_len, new_len, &charged);
-	if (IS_ERR(vma)) {
-		ret = PTR_ERR(vma);
+	vma = find_vma(mm, addr);
+	if (!vma || vma->vm_start > addr) {
+		ret = -EFAULT;
 		goto out;
 	}
 
@@ -541,6 +564,12 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		if (vma_expandable(vma, new_len - old_len)) {
 			int pages = (new_len - old_len) >> PAGE_SHIFT;
 
+			ret = validate_vma_and_charge(vma, addr, old_len, new_len,
+				&charged, false);
+			if (ret) {
+				BUG_ON(charged != 0);
+				goto out;
+			}
 			if (vma_adjust(vma, vma->vm_start, addr + new_len,
 				       vma->vm_pgoff, NULL)) {
 				ret = -ENOMEM;
@@ -558,6 +587,11 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		}
 	}
 
+	ret = validate_vma_and_charge(vma, addr, old_len, new_len,
+		&charged, nohole);
+	if (ret)
+		goto out;
+
 	/*
 	 * We weren't able to just expand or shrink the area,
 	 * we need to create a new one and move it..
@@ -577,7 +611,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 			goto out;
 		}
 
-		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked);
+		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked,
+			nohole);
 	}
 out:
 	if (ret & ~PAGE_MASK)
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
