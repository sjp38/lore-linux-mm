Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 91A6F6B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 17:11:30 -0400 (EDT)
Received: by qcbkw5 with SMTP id kw5so21502320qcb.2
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 14:11:30 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 89si14588557qky.38.2015.03.17.14.11.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Mar 2015 14:11:29 -0700 (PDT)
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t2HL9eqi018905
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 14:11:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1t6urdr1kh-15
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 14:11:28 -0700
Received: from facebook.com (2401:db00:20:7003:face:0:4d:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 ecf0e66ccce911e4a7600002c992ebde-22bda310 for <linux-mm@kvack.org>;	Tue, 17
 Mar 2015 14:09:40 -0700
From: Shaohua Li <shli@fb.com>
Subject: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
Date: Tue, 17 Mar 2015 14:09:39 -0700
Message-ID: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: danielmicay@gmail.com, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>

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
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
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
index 38df67b..4771fd1 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -234,7 +234,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
 static unsigned long move_vma(struct vm_area_struct *vma,
 		unsigned long old_addr, unsigned long old_len,
-		unsigned long new_len, unsigned long new_addr, bool *locked)
+		unsigned long new_len, unsigned long new_addr, bool *locked,
+		bool nohole)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma;
@@ -290,7 +291,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
 
 	/* Conceal VM_ACCOUNT so old reservation is not undone */
-	if (vm_flags & VM_ACCOUNT) {
+	if ((vm_flags & VM_ACCOUNT) && !nohole) {
 		vma->vm_flags &= ~VM_ACCOUNT;
 		excess = vma->vm_end - vma->vm_start - old_len;
 		if (old_addr > vma->vm_start &&
@@ -310,11 +311,18 @@ static unsigned long move_vma(struct vm_area_struct *vma,
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
@@ -332,14 +340,13 @@ static unsigned long move_vma(struct vm_area_struct *vma,
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
@@ -348,6 +355,9 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	if (old_len > vma->vm_end - addr)
 		goto Efault;
 
+	if (nohole && (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP)))
+		goto Einval;
+
 	/* Need to be careful about a growing mapping */
 	if (new_len > old_len) {
 		unsigned long pgoff;
@@ -360,39 +370,45 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
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
@@ -420,17 +436,23 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
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
@@ -442,7 +464,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (ret & ~PAGE_MASK)
 		goto out1;
 
-	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked);
+	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked, nohole);
 	if (!(ret & ~PAGE_MASK))
 		goto out;
 out1:
@@ -481,8 +503,9 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	unsigned long ret = -EINVAL;
 	unsigned long charged = 0;
 	bool locked = false;
+	bool nohole = flags & MREMAP_NOHOLE;
 
-	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
+	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE | MREMAP_NOHOLE))
 		return ret;
 
 	if (flags & MREMAP_FIXED && !(flags & MREMAP_MAYMOVE))
@@ -506,7 +529,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 
 	if (flags & MREMAP_FIXED) {
 		ret = mremap_to(addr, old_len, new_addr, new_len,
-				&locked);
+				&locked, nohole);
 		goto out;
 	}
 
@@ -526,9 +549,9 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
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
 
@@ -539,6 +562,12 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
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
@@ -556,6 +585,11 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
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
@@ -575,7 +609,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
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
