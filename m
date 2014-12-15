Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 84EBF6B0073
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 12:12:53 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so15088384wgh.8
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 09:12:52 -0800 (PST)
Received: from mail-wg0-x22c.google.com (mail-wg0-x22c.google.com. [2a00:1450:400c:c00::22c])
        by mx.google.com with ESMTPS id bw13si17940147wib.18.2014.12.15.09.12.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 09:12:52 -0800 (PST)
Received: by mail-wg0-f44.google.com with SMTP id b13so15186753wgh.3
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 09:12:52 -0800 (PST)
From: Petr Cermak <petrcermak@chromium.org>
Subject: [PATCH 1/2] task_mmu: Reduce excessive indentation in clear_refs_write
Date: Mon, 15 Dec 2014 17:12:30 +0000
Message-Id: <1418663550-15778-1-git-send-email-petrcermak@chromium.org>
References: <1418223544-11382-1-git-send-email-petrcermak@chromium.org>
In-Reply-To: <1418223544-11382-1-git-send-email-petrcermak@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Petr Cermak <petrcermak@chromium.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Primiano Tucci <primiano@chromium.org>

This is a purely cosmetic fix for clear_refs_write(). It removes excessive
indentation as suggested by Bjorn Helgaas <bhelgaas@google.com>. This is to
make upcoming changes to the file more readable.

Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Primiano Tucci <primiano@chromium.org>
Cc: Petr Cermak <petrcermak@chromium.org>
Signed-off-by: Petr Cermak <petrcermak@chromium.org>
---
 fs/proc/task_mmu.c | 100 +++++++++++++++++++++++++++--------------------------
 1 file changed, 51 insertions(+), 49 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 246eae8..3ee8541 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -852,59 +852,61 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	if (!task)
 		return -ESRCH;
 	mm = get_task_mm(task);
-	if (mm) {
-		struct clear_refs_private cp = {
-			.type = type,
-		};
-		struct mm_walk clear_refs_walk = {
-			.pmd_entry = clear_refs_pte_range,
-			.mm = mm,
-			.private = &cp,
-		};
-		down_read(&mm->mmap_sem);
-		if (type == CLEAR_REFS_SOFT_DIRTY) {
-			for (vma = mm->mmap; vma; vma = vma->vm_next) {
-				if (!(vma->vm_flags & VM_SOFTDIRTY))
-					continue;
-				up_read(&mm->mmap_sem);
-				down_write(&mm->mmap_sem);
-				for (vma = mm->mmap; vma; vma = vma->vm_next) {
-					vma->vm_flags &= ~VM_SOFTDIRTY;
-					vma_set_page_prot(vma);
-				}
-				downgrade_write(&mm->mmap_sem);
-				break;
-			}
-			mmu_notifier_invalidate_range_start(mm, 0, -1);
-		}
+	if (!mm)
+		goto out_task;
+
+	struct clear_refs_private cp = {
+		.type = type,
+	};
+	struct mm_walk clear_refs_walk = {
+		.pmd_entry = clear_refs_pte_range,
+		.mm = mm,
+		.private = &cp,
+	};
+	down_read(&mm->mmap_sem);
+	if (type == CLEAR_REFS_SOFT_DIRTY) {
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
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
+			if (!(vma->vm_flags & VM_SOFTDIRTY))
 				continue;
-			if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
-				continue;
-			walk_page_range(vma->vm_start, vma->vm_end,
-					&clear_refs_walk);
+			up_read(&mm->mmap_sem);
+			down_write(&mm->mmap_sem);
+			for (vma = mm->mmap; vma; vma = vma->vm_next) {
+				vma->vm_flags &= ~VM_SOFTDIRTY;
+				vma_set_page_prot(vma);
+			}
+			downgrade_write(&mm->mmap_sem);
+			break;
 		}
-		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_end(mm, 0, -1);
-		flush_tlb_mm(mm);
-		up_read(&mm->mmap_sem);
-		mmput(mm);
+		mmu_notifier_invalidate_range_start(mm, 0, -1);
 	}
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		cp.vma = vma;
+		if (is_vm_hugetlb_page(vma))
+			continue;
+		/*
+		 * Writing 1 to /proc/pid/clear_refs affects all pages.
+		 *
+		 * Writing 2 to /proc/pid/clear_refs only affects anonymous
+		 * pages.
+		 *
+		 * Writing 3 to /proc/pid/clear_refs only affects file mapped
+		 * pages.
+		 *
+		 * Writing 4 to /proc/pid/clear_refs affects all pages.
+		 */
+		if (type == CLEAR_REFS_ANON && vma->vm_file)
+			continue;
+		if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
+			continue;
+		walk_page_range(vma->vm_start, vma->vm_end, &clear_refs_walk);
+	}
+	if (type == CLEAR_REFS_SOFT_DIRTY)
+		mmu_notifier_invalidate_range_end(mm, 0, -1);
+	flush_tlb_mm(mm);
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+
+out_task:
 	put_task_struct(task);
 
 	return count;
-- 
2.2.0.rc0.207.ga3a616c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
