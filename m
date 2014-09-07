Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id C9BE96B0038
	for <linux-mm@kvack.org>; Sun,  7 Sep 2014 19:01:54 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id uy5so10279296obc.32
        for <linux-mm@kvack.org>; Sun, 07 Sep 2014 16:01:54 -0700 (PDT)
Received: from mail-oi0-x24a.google.com (mail-oi0-x24a.google.com [2607:f8b0:4003:c06::24a])
        by mx.google.com with ESMTPS id f4si11863446oeq.64.2014.09.07.16.01.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Sep 2014 16:01:53 -0700 (PDT)
Received: by mail-oi0-f74.google.com with SMTP id e131so540573oig.5
        for <linux-mm@kvack.org>; Sun, 07 Sep 2014 16:01:52 -0700 (PDT)
From: Peter Feiner <pfeiner@google.com>
Subject: [PATCH v6] mm: softdirty: enable write notifications on VMAs after VM_SOFTDIRTY cleared
Date: Sun,  7 Sep 2014 16:01:49 -0700
Message-Id: <1410130909-8864-1-git-send-email-pfeiner@google.com>
In-Reply-To: <1408571182-28750-1-git-send-email-pfeiner@google.com>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
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
cleared. Furthermore, to avoid unnecessary faults, write
notifications are disabled when VM_SOFTDIRTY is set.

As a side effect of enabling and disabling write notifications with
care, this patch fixes a bug in mprotect where vm_page_prot bits set
by drivers were zapped on mprotect. An analogous bug was fixed in mmap
by c9d0bf241451a3ab7d02e1652c22b80cd7d93e8f.

Reported-by: Peter Feiner <pfeiner@google.com>
Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Peter Feiner <pfeiner@google.com>

---

v1 -> v2: Instead of checking VM_SOFTDIRTY in the fault handler,
          enable write notifications on vm_page_prot when we clear
          VM_SOFTDIRTY.

v2 -> v3: * Grab the mmap_sem in write mode if any VMAs have
            VM_SOFTDIRTY set. This involved refactoring clear_refs_write
            to make it less unwieldy.

          * In mprotect, don't inadvertently disable write notifications on VMAs
            that have had VM_SOFTDIRTY cleared

          * The mprotect fix and mmap cleanup that comprised the
            second and third patches in v2 were swallowed by the main
            patch because of vm_page_prot corner case handling.

v3 -> v4: Handle !defined(CONFIG_MEM_SOFT_DIRTY): old patch would have
          enabled write notifications for all VMAs in this case.

v4 -> v5: IS_ENABLED(CONFIG_MEM_SOFT_DIRTY) instead of #ifdef ...

v5 -> v6:
          * Replaced vma_{enable,disable}_writenotify() with vma_set_page_prot()
            as per Hugh's suggestion.

          * Per Hugh's suggestion, added an arch generic pgprot_modify that
            handles pgprot_noncached and pgprot_writecombine pgprot. This arch
            generic pgprot_modify fixes the regression introduced in v2 that
            re-introduced the bug fixed by
            c9d0bf241451a3ab7d02e1652c22b80cd7d93e8f for arch's without
            pgprot_modify.

          * Made vma_set_page_prot's pgprot check less restrictive by using
            pgprot_modify. Couldn't remove the pgprot check altogether since
            pgprot_modify isn't 100% on all arch's, such as powerpc.

          * Fixed dirty_accountable bug.

          * Fixed non-x86 build (tested build on arm64 and powerpc)

          * Per Kirill's suggestion, changed locking so mmap_sem isn't held
            exclusively during page table traversal.

Kirill & Cyrill: I removed your Reviewed-By: footers since this patch is quite
different than v5 and I didn't want to presume your approval. Please re-add as
you see fit - this has been a group effort!
---
 fs/proc/task_mmu.c            | 19 +++++++++++++-----
 include/asm-generic/pgtable.h | 12 ++++++++++++
 include/linux/mm.h            |  5 +++++
 mm/memory.c                   |  3 ++-
 mm/mmap.c                     | 45 +++++++++++++++++++++++++++----------------
 mm/mprotect.c                 | 20 +++++--------------
 6 files changed, 66 insertions(+), 38 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dfc791c..4621914 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -829,8 +829,21 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			.private = &cp,
 		};
 		down_read(&mm->mmap_sem);
-		if (type == CLEAR_REFS_SOFT_DIRTY)
+		if (type == CLEAR_REFS_SOFT_DIRTY) {
+			for (vma = mm->mmap; vma; vma = vma->vm_next) {
+				if (!(vma->vm_flags & VM_SOFTDIRTY))
+					continue;
+				up_read(&mm->mmap_sem);
+				down_write(&mm->mmap_sem);
+				for (vma = mm->mmap; vma; vma = vma->vm_next) {
+					vma->vm_flags &= ~VM_SOFTDIRTY;
+					vma_set_page_prot(vma);
+				}
+				downgrade_write(&mm->mmap_sem);
+				break;
+			}
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
+		}
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			cp.vma = vma;
 			if (is_vm_hugetlb_page(vma))
@@ -850,10 +863,6 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				continue;
 			if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
 				continue;
-			if (type == CLEAR_REFS_SOFT_DIRTY) {
-				if (vma->vm_flags & VM_SOFTDIRTY)
-					vma->vm_flags &= ~VM_SOFTDIRTY;
-			}
 			walk_page_range(vma->vm_start, vma->vm_end,
 					&clear_refs_walk);
 		}
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 53b2acc..0f6edbd 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -249,6 +249,18 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 #define pgprot_writecombine pgprot_noncached
 #endif
 
+#ifndef pgprot_modify
+#define pgprot_modify pgprot_modify
+static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
+{
+	if (pgprot_val(oldprot) == pgprot_val(pgprot_noncached(oldprot)))
+		newprot = pgprot_noncached(newprot);
+	if (pgprot_val(oldprot) == pgprot_val(pgprot_writecombine(oldprot)))
+		newprot = pgprot_writecombine(newprot);
+	return newprot;
+}
+#endif
+
 /*
  * When walking page tables, get the address of the next boundary,
  * or the end address of the range if that comes earlier.  Although no
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8981cc8..4e070aa 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1939,11 +1939,16 @@ static inline struct vm_area_struct *find_exact_vma(struct mm_struct *mm,
 
 #ifdef CONFIG_MMU
 pgprot_t vm_get_page_prot(unsigned long vm_flags);
+void vma_set_page_prot(struct vm_area_struct *vma);
 #else
 static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
 {
 	return __pgprot(0);
 }
+static inline void vma_set_page_prot(struct vm_area_struct *vma)
+{
+	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
+}
 #endif
 
 #ifdef CONFIG_NUMA_BALANCING
diff --git a/mm/memory.c b/mm/memory.c
index adeac30..1715233 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2051,7 +2051,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	old_page = vm_normal_page(vma, address, orig_pte);
 	if (!old_page) {
 		/*
-		 * VM_MIXEDMAP !pfn_valid() case
+		 * VM_MIXEDMAP !pfn_valid() case, or VM_SOFTDIRTY clear on a
+		 * VM_PFNMAP VMA.
 		 *
 		 * We should not cow pages in a shared writeable mapping.
 		 * Just mark the pages writable as we can't do any dirty
diff --git a/mm/mmap.c b/mm/mmap.c
index c1f2ea4..4ef9325 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -89,6 +89,25 @@ pgprot_t vm_get_page_prot(unsigned long vm_flags)
 }
 EXPORT_SYMBOL(vm_get_page_prot);
 
+static pgprot_t vm_pgprot_modify(pgprot_t oldprot, unsigned long vm_flags)
+{
+	return pgprot_modify(oldprot, vm_get_page_prot(vm_flags));
+}
+
+/* Update vma->vm_page_prot to reflect vma->vm_flags. */
+void vma_set_page_prot(struct vm_area_struct *vma)
+{
+	unsigned long vm_flags = vma->vm_flags;
+
+	vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
+	if (vma_wants_writenotify(vma)) {
+		vm_flags &= ~VM_SHARED;
+		vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot,
+						     vm_flags);
+	}
+}
+
+
 int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic overcommit */
 int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
 unsigned long sysctl_overcommit_kbytes __read_mostly;
@@ -1470,11 +1489,16 @@ int vma_wants_writenotify(struct vm_area_struct *vma)
 	if (vma->vm_ops && vma->vm_ops->page_mkwrite)
 		return 1;
 
-	/* The open routine did something to the protections already? */
+	/* The open routine did something to the protections that pgprot_modify
+	 * won't preserve? */
 	if (pgprot_val(vma->vm_page_prot) !=
-	    pgprot_val(vm_get_page_prot(vm_flags)))
+	    pgprot_val(vm_pgprot_modify(vma->vm_page_prot, vm_flags)))
 		return 0;
 
+	/* Do we need to track softdirty? */
+	if (IS_ENABLED(CONFIG_MEM_SOFT_DIRTY) && !(vm_flags & VM_SOFTDIRTY))
+		return 1;
+
 	/* Specialty mapping? */
 	if (vm_flags & VM_PFNMAP)
 		return 0;
@@ -1610,21 +1634,6 @@ munmap_back:
 			goto free_vma;
 	}
 
-	if (vma_wants_writenotify(vma)) {
-		pgprot_t pprot = vma->vm_page_prot;
-
-		/* Can vma->vm_page_prot have changed??
-		 *
-		 * Answer: Yes, drivers may have changed it in their
-		 *         f_op->mmap method.
-		 *
-		 * Ensures that vmas marked as uncached stay that way.
-		 */
-		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
-		if (pgprot_val(pprot) == pgprot_val(pgprot_noncached(pprot)))
-			vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-	}
-
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	/* Once vma denies write, undo our temporary denial count */
 	if (file) {
@@ -1658,6 +1667,8 @@ out:
 	 */
 	vma->vm_flags |= VM_SOFTDIRTY;
 
+	vma_set_page_prot(vma);
+
 	return addr;
 
 unmap_and_free_vma:
diff --git a/mm/mprotect.c b/mm/mprotect.c
index c43d557..ace9345 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -29,13 +29,6 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-#ifndef pgprot_modify
-static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
-{
-	return newprot;
-}
-#endif
-
 /*
  * For a prot_numa update we only hold mmap_sem for read so there is a
  * potential race with faulting where a pmd was temporarily none. This
@@ -93,7 +86,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				 * Avoid taking write faults for pages we
 				 * know to be dirty.
 				 */
-				if (dirty_accountable && pte_dirty(ptent))
+				if (dirty_accountable && pte_dirty(ptent) &&
+				    (pte_soft_dirty(ptent) ||
+				     !(vma->vm_flags & VM_SOFTDIRTY)))
 					ptent = pte_mkwrite(ptent);
 				ptep_modify_prot_commit(mm, addr, pte, ptent);
 				updated = true;
@@ -320,13 +315,8 @@ success:
 	 * held in write mode.
 	 */
 	vma->vm_flags = newflags;
-	vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
-					  vm_get_page_prot(newflags));
-
-	if (vma_wants_writenotify(vma)) {
-		vma->vm_page_prot = vm_get_page_prot(newflags & ~VM_SHARED);
-		dirty_accountable = 1;
-	}
+	dirty_accountable = vma_wants_writenotify(vma);
+	vma_set_page_prot(vma);
 
 	change_protection(vma, start, end, vma->vm_page_prot,
 			  dirty_accountable, 0);
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
