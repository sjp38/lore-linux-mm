Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 308F7280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 07:53:25 -0400 (EDT)
Received: by pacan13 with SMTP id an13so60165596pac.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 04:53:24 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id xw10si18320279pac.200.2015.07.17.04.53.23
        for <linux-mm@kvack.org>;
        Fri, 17 Jul 2015 04:53:23 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 3/6] mm, mpx: add "vm_flags_t vm_flags" arg to do_mmap_pgoff()
Date: Fri, 17 Jul 2015 14:53:10 +0300
Message-Id: <1437133993-91885-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: Oleg Nesterov <oleg@redhat.com>

Add the additional "vm_flags_t vm_flags" argument to do_mmap_pgoff(),
rename it to do_mmap(), and re-introduce do_mmap_pgoff() as a simple
wrapper on top of do_mmap(). Perhaps we should update the callers of
do_mmap_pgoff() and kill it later.

This way mpx_mmap() can simply call do_mmap(vm_flags => VM_MPX) and
do not play with vm internals.

After this change mmap_region() has a single user outside of mmap.c,
arch/tile/mm/elf.c:arch_setup_additional_pages(). It would be nice
to change arch/tile/ and unexport mmap_region().

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
Tested-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/mpx.c  | 51 +++++++--------------------------------------------
 include/linux/mm.h | 12 ++++++++++--
 mm/mmap.c          | 10 ++++------
 mm/nommu.c         | 15 ++++++++-------
 4 files changed, 29 insertions(+), 59 deletions(-)

diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 4d1c11c07fe1..fdbd3e0b1dad 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -24,58 +24,21 @@
  */
 static unsigned long mpx_mmap(unsigned long len)
 {
-	unsigned long ret;
-	unsigned long addr, pgoff;
 	struct mm_struct *mm = current->mm;
-	vm_flags_t vm_flags;
-	struct vm_area_struct *vma;
+	unsigned long addr, populate;
 
 	/* Only bounds table and bounds directory can be allocated here */
 	if (len != MPX_BD_SIZE_BYTES && len != MPX_BT_SIZE_BYTES)
 		return -EINVAL;
 
 	down_write(&mm->mmap_sem);
-
-	/* Too many mappings? */
-	if (mm->map_count > sysctl_max_map_count) {
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	/* Obtain the address to map to. we verify (or select) it and ensure
-	 * that it represents a valid section of the address space.
-	 */
-	addr = get_unmapped_area(NULL, 0, len, 0, MAP_ANONYMOUS | MAP_PRIVATE);
-	if (addr & ~PAGE_MASK) {
-		ret = addr;
-		goto out;
-	}
-
-	vm_flags = VM_READ | VM_WRITE | VM_MPX |
-			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
-
-	/* Set pgoff according to addr for anon_vma */
-	pgoff = addr >> PAGE_SHIFT;
-
-	ret = mmap_region(NULL, addr, len, vm_flags, pgoff);
-	if (IS_ERR_VALUE(ret))
-		goto out;
-
-	vma = find_vma(mm, ret);
-	if (!vma) {
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	if (vm_flags & VM_LOCKED) {
-		up_write(&mm->mmap_sem);
-		mm_populate(ret, len);
-		return ret;
-	}
-
-out:
+	addr = do_mmap(NULL, 0, len, PROT_READ | PROT_WRITE,
+			MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate);
 	up_write(&mm->mmap_sem);
-	return ret;
+	if (populate)
+		mm_populate(addr, populate);
+
+	return addr;
 }
 
 enum reg_type {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c3a2b37365f6..fcf255a78b1f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1811,11 +1811,19 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff);
-extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
+extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
-	unsigned long pgoff, unsigned long *populate);
+	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);
 
+static inline unsigned long
+do_mmap_pgoff(struct file *file, unsigned long addr,
+	unsigned long len, unsigned long prot, unsigned long flags,
+	unsigned long pgoff, unsigned long *populate)
+{
+	return do_mmap(file, addr, len, prot, flags, 0, pgoff, populate);
+}
+
 #ifdef CONFIG_MMU
 extern int __mm_populate(unsigned long addr, unsigned long len,
 			 int ignore_errors);
diff --git a/mm/mmap.c b/mm/mmap.c
index 4f2fb700a2e5..2e98784d5b7c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1260,14 +1260,12 @@ static inline int mlock_future_check(struct mm_struct *mm,
 /*
  * The caller must hold down_write(&current->mm->mmap_sem).
  */
-
-unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
+unsigned long do_mmap(struct file *file, unsigned long addr,
 			unsigned long len, unsigned long prot,
-			unsigned long flags, unsigned long pgoff,
-			unsigned long *populate)
+			unsigned long flags, vm_flags_t vm_flags,
+			unsigned long pgoff, unsigned long *populate)
 {
 	struct mm_struct *mm = current->mm;
-	vm_flags_t vm_flags;
 
 	*populate = 0;
 
@@ -1311,7 +1309,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	 * to. we assume access permissions have been handled by the open
 	 * of the memory object, so we don't do any here.
 	 */
-	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
+	vm_flags |= calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
 	if (flags & (MAP_LOCKED | MAP_LOCKONFAULT))
diff --git a/mm/nommu.c b/mm/nommu.c
index 05e7447d960b..18dcf48883dc 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1233,13 +1233,14 @@ enomem:
 /*
  * handle mapping creation for uClinux
  */
-unsigned long do_mmap_pgoff(struct file *file,
-			    unsigned long addr,
-			    unsigned long len,
-			    unsigned long prot,
-			    unsigned long flags,
-			    unsigned long pgoff,
-			    unsigned long *populate)
+unsigned long do_mmap(struct file *file,
+			unsigned long addr,
+			unsigned long len,
+			unsigned long prot,
+			unsigned long flags,
+			vm_flags_t vm_flags,
+			unsigned long pgoff,
+			unsigned long *populate)
 {
 	struct vm_area_struct *vma;
 	struct vm_region *region;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
