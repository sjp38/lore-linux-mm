From: Anton Salikhmetov <salikhmetov@gmail.com>
Subject: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in sys_msync()
Date: Wed, 23 Jan 2008 02:21:19 +0300
Message-Id: <1201044083504-git-send-email-salikhmetov@gmail.com>
In-Reply-To: <12010440803930-git-send-email-salikhmetov@gmail.com>
References: <12010440803930-git-send-email-salikhmetov@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Force file times update at the next write reference after
calling the msync() system call with the MS_ASYNC flag.

Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>
---
 mm/msync.c |   92 +++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 82 insertions(+), 10 deletions(-)

diff --git a/mm/msync.c b/mm/msync.c
index 60efa36..87f990e 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -5,6 +5,7 @@
  * Copyright (C) 2008 Anton Salikhmetov <salikhmetov@gmail.com>
  */
 
+#include <asm/tlbflush.h>
 #include <linux/file.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
@@ -12,6 +13,73 @@
 #include <linux/sched.h>
 #include <linux/syscalls.h>
 
+static void vma_wrprotect_pmd_range(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long start, unsigned long end)
+{
+	while (start < end) {
+		spinlock_t *ptl;
+		pte_t *pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);
+
+		if (pte_dirty(*pte) && pte_write(*pte)) {
+			pte_t entry = ptep_clear_flush(vma, start, pte);
+
+			entry = pte_wrprotect(entry);
+			set_pte_at(vma->vm_mm, start, pte, entry);
+		}
+
+		pte_unmap_unlock(pte, ptl);
+		start += PAGE_SIZE;
+	}
+}
+
+static void vma_wrprotect_pud_range(struct vm_area_struct *vma, pud_t *pud,
+		unsigned long start, unsigned long end)
+{
+	pmd_t *pmd = pmd_offset(pud, start);
+
+	while (start < end) {
+		unsigned long next = pmd_addr_end(start, end);
+
+		if (!pmd_none_or_clear_bad(pmd))
+			vma_wrprotect_pmd_range(vma, pmd, start, next);
+
+		++pmd;
+		start = next;
+	}
+}
+
+static void vma_wrprotect_pgd_range(struct vm_area_struct *vma, pgd_t *pgd,
+		unsigned long start, unsigned long end)
+{
+	pud_t *pud = pud_offset(pgd, start);
+
+	while (start < end) {
+		unsigned long next = pud_addr_end(start, end);
+
+		if (!pud_none_or_clear_bad(pud))
+			vma_wrprotect_pud_range(vma, pud, start, next);
+
+		++pud;
+		start = next;
+	}
+}
+
+static void vma_wrprotect(struct vm_area_struct *vma)
+{
+	unsigned long addr = vma->vm_start;
+	pgd_t *pgd = pgd_offset(vma->vm_mm, addr);
+
+	while (addr < vma->vm_end) {
+		unsigned long next = pgd_addr_end(addr, vma->vm_end);
+
+		if (!pgd_none_or_clear_bad(pgd))
+			vma_wrprotect_pgd_range(vma, pgd, addr, next);
+
+		++pgd;
+		addr = next;
+	}
+}
+
 /*
  * MS_SYNC syncs the entire file - including mappings.
  *
@@ -78,16 +146,20 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
 		error = 0;
 		start = vma->vm_end;
 		file = vma->vm_file;
-		if (file && (vma->vm_flags & VM_SHARED) && (flags & MS_SYNC)) {
-			get_file(file);
-			up_read(&mm->mmap_sem);
-			error = do_fsync(file, 0);
-			fput(file);
-			if (error || start >= end)
-				goto out;
-			down_read(&mm->mmap_sem);
-			vma = find_vma(mm, start);
-			continue;
+		if (file && (vma->vm_flags & VM_SHARED)) {
+			if ((flags & MS_ASYNC))
+				vma_wrprotect(vma);
+			if (flags & MS_SYNC) {
+				get_file(file);
+				up_read(&mm->mmap_sem);
+				error = do_fsync(file, 0);
+				fput(file);
+				if (error || start >= end)
+					goto out;
+				down_read(&mm->mmap_sem);
+				vma = find_vma(mm, start);
+				continue;
+			}
 		}
 
 		vma = vma->vm_next;
-- 
1.4.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
