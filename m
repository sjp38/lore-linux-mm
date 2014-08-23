Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id B35836B0037
	for <linux-mm@kvack.org>; Sat, 23 Aug 2014 18:12:34 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id vb8so9580642obc.33
        for <linux-mm@kvack.org>; Sat, 23 Aug 2014 15:12:34 -0700 (PDT)
Received: from mail-ob0-x24a.google.com (mail-ob0-x24a.google.com [2607:f8b0:4003:c01::24a])
        by mx.google.com with ESMTPS id y11si41130540oep.28.2014.08.23.15.12.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 23 Aug 2014 15:12:33 -0700 (PDT)
Received: by mail-ob0-f202.google.com with SMTP id wp18so2422059obc.5
        for <linux-mm@kvack.org>; Sat, 23 Aug 2014 15:12:33 -0700 (PDT)
From: Peter Feiner <pfeiner@google.com>
Subject: [PATCH v2 1/3] mm: softdirty: enable write notifications on VMAs after VM_SOFTDIRTY cleared
Date: Sat, 23 Aug 2014 18:11:59 -0400
Message-Id: <1408831921-10168-2-git-send-email-pfeiner@google.com>
In-Reply-To: <1408831921-10168-1-git-send-email-pfeiner@google.com>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408831921-10168-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Peter Feiner <pfeiner@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

For VMAs that don't want write notifications, PTEs created for read
faults have their write bit set. If the read fault happens after
VM_SOFTDIRTY is cleared, then the PTE's softdirty bit will remain
clear after subsequent writes.

Here's a simple code snippet to demonstrate the bug:

  char* m = mmap(NULL, getpagesize(), PROT_READ | PROT_WRITE,
                 MAP_ANONYMOUS | MAP_SHARED, -1, 0);
  system("echo 4 > /proc/$PPID/clear_refs"); /* clear VM_SOFTDIRTY */
  assert(*m == '\0');     /* new PTE allows write access */
  assert(!soft_dirty(x));
  *m = 'x';               /* should dirty the page */
  assert(soft_dirty(x));  /* fails */

With this patch, write notifications are enabled when VM_SOFTDIRTY is
cleared. Furthermore, to avoid faults, write notifications are
disabled when VM_SOFTDIRTY is reset.

Signed-off-by: Peter Feiner <pfeiner@google.com>
---
 v1 -> v2: Instead of checking VM_SOFTDIRTY in the fault handler, enable write
           notifications on vm_page_prot when we clear VM_SOFTDIRTY.

 fs/proc/task_mmu.c | 17 ++++++++++++++++-
 include/linux/mm.h | 15 +++++++++++++++
 mm/mmap.c          | 10 +++++++++-
 3 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dfc791c..f1a5382 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -851,8 +851,23 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
 				continue;
 			if (type == CLEAR_REFS_SOFT_DIRTY) {
-				if (vma->vm_flags & VM_SOFTDIRTY)
+				if (vma->vm_flags & VM_SOFTDIRTY) {
 					vma->vm_flags &= ~VM_SOFTDIRTY;
+					/*
+					 * We don't have a write lock on
+					 * mm->mmap_sem, so we race with the
+					 * fault handler reading vm_page_prot.
+					 * Therefore writable PTEs (that won't
+					 * have soft-dirty set) can be created
+					 * for read faults. However, since the
+					 * PTE lock is held while vm_page_prot
+					 * is read and while we write protect
+					 * PTEs during our walk, any writable
+					 * PTEs that slipped through will be
+					 * write protected.
+					 */
+					vma_enable_writenotify(vma);
+				}
 			}
 			walk_page_range(vma->vm_start, vma->vm_end,
 					&clear_refs_walk);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8981cc8..5f26634 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1946,6 +1946,21 @@ static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
 }
 #endif
 
+/* Enable write notifications without blowing away special flags. */
+static inline void vma_enable_writenotify(struct vm_area_struct *vma)
+{
+	vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
+	                                  vm_get_page_prot(vma->vm_flags &
+					                   ~VM_SHARED));
+}
+
+/* Disable write notifications without blowing away special flags. */
+static inline void vma_disable_writenotify(struct vm_area_struct *vma)
+{
+	vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
+	                                  vm_get_page_prot(vma->vm_flags));
+}
+
 #ifdef CONFIG_NUMA_BALANCING
 unsigned long change_prot_numa(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
diff --git a/mm/mmap.c b/mm/mmap.c
index c1f2ea4..abcac32 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1549,8 +1549,16 @@ munmap_back:
 	 * Can we just expand an old mapping?
 	 */
 	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file, pgoff, NULL);
-	if (vma)
+	if (vma) {
+		if (!vma_wants_writenotify(vma)) {
+			/*
+			 * We're going to reset VM_SOFTDIRTY, so we can disable
+			 * write notifications.
+			 */
+			vma_disable_writenotify(vma);
+		}
 		goto out;
+	}
 
 	/*
 	 * Determine the object being mapped and call the appropriate
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
