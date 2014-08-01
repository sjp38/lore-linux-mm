Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id B133E6B0037
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 15:21:12 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id a108so6295537qge.16
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 12:21:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u4si17231484qca.9.2014.08.01.12.21.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Aug 2014 12:21:12 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v6 05/13] clear_refs: remove clear_refs_private->vma and introduce clear_refs_test_walk()
Date: Fri,  1 Aug 2014 15:20:41 -0400
Message-Id: <1406920849-25908-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1406920849-25908-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1406920849-25908-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

clear_refs_write() has some prechecks to determine if we really walk over
a given vma. Now we have a test_walk() callback to filter vmas, so let's
utilize it.

ChangeLog v5:
- remove unused vma

ChangeLog v4:
- use walk_page_range instead of walk_page_vma with for loop

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c | 55 ++++++++++++++++++++++++++----------------------------
 1 file changed, 26 insertions(+), 29 deletions(-)

diff --git mmotm-2014-07-30-15-57.orig/fs/proc/task_mmu.c mmotm-2014-07-30-15-57/fs/proc/task_mmu.c
index 2c3a501c0dc7..4baf34230191 100644
--- mmotm-2014-07-30-15-57.orig/fs/proc/task_mmu.c
+++ mmotm-2014-07-30-15-57/fs/proc/task_mmu.c
@@ -709,7 +709,6 @@ enum clear_refs_types {
 };
 
 struct clear_refs_private {
-	struct vm_area_struct *vma;
 	enum clear_refs_types type;
 };
 
@@ -742,7 +741,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 {
 	struct clear_refs_private *cp = walk->private;
-	struct vm_area_struct *vma = cp->vma;
+	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte, ptent;
 	spinlock_t *ptl;
 	struct page *page;
@@ -776,13 +775,35 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 	return 0;
 }
 
+static int clear_refs_test_walk(unsigned long start, unsigned long end,
+				struct mm_walk *walk)
+{
+	struct clear_refs_private *cp = walk->private;
+	struct vm_area_struct *vma = walk->vma;
+
+	/*
+	 * Writing 1 to /proc/pid/clear_refs affects all pages.
+	 * Writing 2 to /proc/pid/clear_refs only affects anonymous pages.
+	 * Writing 3 to /proc/pid/clear_refs only affects file mapped pages.
+	 * Writing 4 to /proc/pid/clear_refs affects all pages.
+	 */
+	if (cp->type == CLEAR_REFS_ANON && vma->vm_file)
+		return 1;
+	if (cp->type == CLEAR_REFS_MAPPED && !vma->vm_file)
+		return 1;
+	if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
+		if (vma->vm_flags & VM_SOFTDIRTY)
+			vma->vm_flags &= ~VM_SOFTDIRTY;
+	}
+	return 0;
+}
+
 static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				size_t count, loff_t *ppos)
 {
 	struct task_struct *task;
 	char buffer[PROC_NUMBUF];
 	struct mm_struct *mm;
-	struct vm_area_struct *vma;
 	enum clear_refs_types type;
 	int itype;
 	int rv;
@@ -816,38 +837,14 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		};
 		struct mm_walk clear_refs_walk = {
 			.pmd_entry = clear_refs_pte_range,
+			.test_walk = clear_refs_test_walk,
 			.mm = mm,
 			.private = &cp,
 		};
 		down_read(&mm->mmap_sem);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
-		for (vma = mm->mmap; vma; vma = vma->vm_next) {
-			cp.vma = vma;
-			if (is_vm_hugetlb_page(vma))
-				continue;
-			/*
-			 * Writing 1 to /proc/pid/clear_refs affects all pages.
-			 *
-			 * Writing 2 to /proc/pid/clear_refs only affects
-			 * Anonymous pages.
-			 *
-			 * Writing 3 to /proc/pid/clear_refs only affects file
-			 * mapped pages.
-			 *
-			 * Writing 4 to /proc/pid/clear_refs affects all pages.
-			 */
-			if (type == CLEAR_REFS_ANON && vma->vm_file)
-				continue;
-			if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
-				continue;
-			if (type == CLEAR_REFS_SOFT_DIRTY) {
-				if (vma->vm_flags & VM_SOFTDIRTY)
-					vma->vm_flags &= ~VM_SOFTDIRTY;
-			}
-			walk_page_range(vma->vm_start, vma->vm_end,
-					&clear_refs_walk);
-		}
+		walk_page_range(0, ~0UL, &clear_refs_walk);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
 		flush_tlb_mm(mm);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
