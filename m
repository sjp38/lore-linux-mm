Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 812716B02A8
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:43 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id b34so10048075plc.2
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a25si6080724pfl.324.2018.02.04.17.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 28/64] arch/x86: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:18 +0100
Message-Id: <20180205012754.23615-29-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This becomes quite straightforward with the mmrange in place.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/x86/entry/vdso/vma.c      | 11 ++++++-----
 arch/x86/kernel/vm86_32.c      |  5 +++--
 arch/x86/mm/debug_pagetables.c | 13 +++++++++----
 arch/x86/mm/mpx.c              | 14 ++++++++------
 arch/x86/um/vdso/vma.c         |  5 +++--
 5 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 2e0bdf6a3aaf..5993caa12cc3 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -157,7 +157,7 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 	int ret = 0;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	addr = get_unmapped_area(NULL, addr,
@@ -200,7 +200,7 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 	}
 
 up_fail:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
 
@@ -261,8 +261,9 @@ int map_vdso_once(const struct vdso_image *image, unsigned long addr)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	/*
 	 * Check if we have already mapped vdso blob - fail to prevent
 	 * abusing from userspace install_speciall_mapping, which may
@@ -273,11 +274,11 @@ int map_vdso_once(const struct vdso_image *image, unsigned long addr)
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma_is_special_mapping(vma, &vdso_mapping) ||
 				vma_is_special_mapping(vma, &vvar_mapping)) {
-			up_write(&mm->mmap_sem);
+			mm_write_unlock(mm, &mmrange);
 			return -EEXIST;
 		}
 	}
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return map_vdso(image, addr);
 }
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index 5edb27f1a2c4..524817b365f6 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -171,8 +171,9 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	pmd_t *pmd;
 	pte_t *pte;
 	int i;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	pgd = pgd_offset(mm, 0xA0000);
 	if (pgd_none_or_clear_bad(pgd))
 		goto out;
@@ -198,7 +199,7 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	}
 	pte_unmap_unlock(pte, ptl);
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	flush_tlb_mm_range(mm, 0xA0000, 0xA0000 + 32*PAGE_SIZE, 0UL);
 }
 
diff --git a/arch/x86/mm/debug_pagetables.c b/arch/x86/mm/debug_pagetables.c
index 421f2664ffa0..b044a0680923 100644
--- a/arch/x86/mm/debug_pagetables.c
+++ b/arch/x86/mm/debug_pagetables.c
@@ -1,6 +1,7 @@
 #include <linux/debugfs.h>
 #include <linux/module.h>
 #include <linux/seq_file.h>
+#include <linux/mm.h>
 #include <asm/pgtable.h>
 
 static int ptdump_show(struct seq_file *m, void *v)
@@ -25,9 +26,11 @@ static const struct file_operations ptdump_fops = {
 static int ptdump_show_curknl(struct seq_file *m, void *v)
 {
 	if (current->mm->pgd) {
-		down_read(&current->mm->mmap_sem);
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
+		mm_read_lock(current->mm, &mmrange);
 		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, false);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	}
 	return 0;
 }
@@ -51,9 +54,11 @@ static struct dentry *pe_curusr;
 static int ptdump_show_curusr(struct seq_file *m, void *v)
 {
 	if (current->mm->pgd) {
-		down_read(&current->mm->mmap_sem);
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
+		mm_read_lock(current->mm, &mmrange);
 		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, true);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	}
 	return 0;
 }
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 51c3e1f7e6be..e9c8d75e1d68 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -53,11 +53,11 @@ static unsigned long mpx_mmap(unsigned long len)
 	if (len != mpx_bt_size_bytes(mm))
 		return -EINVAL;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	addr = do_mmap(NULL, 0, len, PROT_READ | PROT_WRITE,
 		       MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate, NULL,
 		       &mmrange);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	if (populate)
 		mm_populate(addr, populate);
 
@@ -228,6 +228,7 @@ int mpx_enable_management(void)
 	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
 	struct mm_struct *mm = current->mm;
 	int ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * runtime in the userspace will be responsible for allocation of
@@ -241,7 +242,7 @@ int mpx_enable_management(void)
 	 * unmap path; we can just use mm->context.bd_addr instead.
 	 */
 	bd_base = mpx_get_bounds_dir();
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	/* MPX doesn't support addresses above 47 bits yet. */
 	if (find_vma(mm, DEFAULT_MAP_WINDOW)) {
@@ -255,20 +256,21 @@ int mpx_enable_management(void)
 	if (mm->context.bd_addr == MPX_INVALID_BOUNDS_DIR)
 		ret = -ENXIO;
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
 
 int mpx_disable_management(void)
 {
 	struct mm_struct *mm = current->mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!cpu_feature_enabled(X86_FEATURE_MPX))
 		return -ENXIO;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	mm->context.bd_addr = MPX_INVALID_BOUNDS_DIR;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return 0;
 }
 
diff --git a/arch/x86/um/vdso/vma.c b/arch/x86/um/vdso/vma.c
index 6be22f991b59..f129e97eb307 100644
--- a/arch/x86/um/vdso/vma.c
+++ b/arch/x86/um/vdso/vma.c
@@ -57,11 +57,12 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
 	int err;
 	struct mm_struct *mm = current->mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!vdso_enabled)
 		return 0;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	err = install_special_mapping(mm, um_vdso_addr, PAGE_SIZE,
@@ -69,7 +70,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
 		vdsop);
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return err;
 }
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
