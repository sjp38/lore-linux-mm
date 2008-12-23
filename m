Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CD1F06B0044
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 05:38:28 -0500 (EST)
Received: by rv-out-0708.google.com with SMTP id f25so2164397rvb.26
        for <linux-mm@kvack.org>; Tue, 23 Dec 2008 02:38:27 -0800 (PST)
Date: Tue, 23 Dec 2008 19:38:21 +0900
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] fix unmap_vmas() with NULL vma
Message-ID: <20081223103820.GB7217@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

unmap_vmas() with NULL vma causes kernel NULL pointer dereference by
vma->mm.

It is happend the following scenario:

1. dup_mm() duplicates mm_struct and ->mmap is NULL
2. dup_mm() calls dup_mmap() to duplicate vmas

3. If dup_mmap() cannot duplicate any vmas due to no enough memory,
it returns error and ->mmap is still NULL

4. dup_mm() calls mmput() with the incompletely duplicated mm_struct to
deallocate it

5. mmput calls exit_mmap with the mm_struct
6. exit_mmap calls unmap_vmas with NULL vma

Cc: linux-mm@kvack.org
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 mm/memory.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: 2.6-rc/mm/memory.c
===================================================================
--- 2.6-rc.orig/mm/memory.c
+++ 2.6-rc/mm/memory.c
@@ -899,8 +899,12 @@ unsigned long unmap_vmas(struct mmu_gath
 	unsigned long start = start_addr;
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	int fullmm = (*tlbp)->fullmm;
-	struct mm_struct *mm = vma->vm_mm;
+	struct mm_struct *mm;
+
+	if (!vma)
+		return start;
 
+	mm = vma->vm_mm;
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
