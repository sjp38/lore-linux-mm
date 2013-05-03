Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id D64236B02FB
	for <linux-mm@kvack.org>; Fri,  3 May 2013 15:52:30 -0400 (EDT)
Message-ID: <51841576.80502@parallels.com>
Date: Fri, 03 May 2013 23:52:22 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH] soft-dirty: Call mmu notifiers when write-protecting ptes
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

As noticed by Xiao, since soft-dirty clear command modifies page
tables we have to flush tlbs and call mmu notifiers. While the
former is done by the clear_refs engine itself, the latter is to
be done.

One thing to note about this -- in order not to call per-page
invalidate notifier (_all_ address space is about to be changed),
the _invalidate_range_start and _end are used. But for those start
and end are not known exactly. To address this, the same trick as
in exit_mmap() is used -- start is 0 and end is (unsigned long)-1.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 27453c0..dbf61f6 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -11,6 +11,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -815,6 +816,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			.private = &cp,
 		};
 		down_read(&mm->mmap_sem);
+		if (type == CLEAR_REFS_SOFT_DIRTY)
+			mmu_notifier_invalidate_range_start(mm, 0, -1);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			cp.vma = vma;
 			if (is_vm_hugetlb_page(vma))
@@ -835,6 +838,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			walk_page_range(vma->vm_start, vma->vm_end,
 					&clear_refs_walk);
 		}
+		if (type == CLEAR_REFS_SOFT_DIRTY)
+			mmu_notifier_invalidate_range_end(mm, 0, -1);
 		flush_tlb_mm(mm);
 		up_read(&mm->mmap_sem);
 		mmput(mm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
