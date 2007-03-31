From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH 09/11] RFP prot support: enhance syscall interface
Date: Sat, 31 Mar 2007 02:35:56 +0200
Message-ID: <20070331003556.3415.52561.stgit@americanbeauty.home.lan>
In-Reply-To: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
References: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Ingo Molnar <mingo@elte.hu>,
	Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

Enable the 'prot' parameter for shared-writable mappings (the ones which are
the primary target for remap_file_pages), without breaking up the vma.

This contains simply the changes to the syscall code, based on Ingo's patch.
Differently from his one, I've *not* added a new syscall, choosing to add a
new flag (MAP_CHGPROT) which the application must specify to get the new
behavior (prot != 0 is accepted and prot == 0 means PROT_NONE).

Upon Hugh's suggestion, simplify the permission checking on the VMA, reusing
mprotect()'s trick.

RFP prot support: cleanup syscall checks

From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
*) remap_file_pages protection support: use EOVERFLOW ret code

Use -EOVERFLOW ("Value too large for defined data type") rather than -EINVAL
when we cannot store the file offset in the PTE.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 mm/fremap.c |   52 ++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 40 insertions(+), 12 deletions(-)

diff --git a/mm/fremap.c b/mm/fremap.c
index 6cb2cc5..b1a4c34 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -4,6 +4,10 @@
  * Explicit pagetable population and nonlinear (random) mappings support.
  *
  * started by Ingo Molnar, Copyright (C) 2002, 2003
+ *
+ * support of nonuniform remappings:
+ * Copyright (C) 2004 Ingo Molnar
+ * Copyright (C) 2005 Paolo 'Blaisorblade' Giarrusso
  */
 
 #include <linux/mm.h>
@@ -79,12 +83,13 @@ out:
 }
 
 static int populate_range(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long addr, unsigned long size, pgoff_t pgoff)
+			unsigned long addr, unsigned long size, pgoff_t pgoff,
+			pgprot_t pgprot)
 {
 	int err;
 
 	do {
-		err = install_file_pte(mm, vma, addr, pgoff, vma->vm_page_prot);
+		err = install_file_pte(mm, vma, addr, pgoff, pgprot);
 		if (err)
 			return err;
 
@@ -102,21 +107,17 @@ static int populate_range(struct mm_struct *mm, struct vm_area_struct *vma,
  *                        file within an existing vma.
  * @start: start of the remapped virtual memory range
  * @size: size of the remapped virtual memory range
- * @prot: new protection bits of the range
+ * @prot: new protection bits of the range, must be 0 if not using MAP_CHGPROT
  * @pgoff: to be mapped page of the backing store file
- * @flags: 0 or MAP_NONBLOCKED - the later will cause no IO.
+ * @flags: bits MAP_CHGPROT or MAP_NONBLOCKED - the later will cause no IO.
  *
  * this syscall works purely via pagetables, so it's the most efficient
  * way to map the same (large) file into a given virtual window. Unlike
  * mmap()/mremap() it does not create any new vmas. The new mappings are
  * also safe across swapout.
- *
- * NOTE: the 'prot' parameter right now is ignored, and the vma's default
- * protection is used. Arbitrary protections might be implemented in the
- * future.
  */
 asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
-	unsigned long __prot, unsigned long pgoff, unsigned long flags)
+	unsigned long prot, unsigned long pgoff, unsigned long flags)
 {
 	struct mm_struct *mm = current->mm;
 	struct address_space *mapping;
@@ -124,8 +125,9 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 	struct vm_area_struct *vma;
 	int err = -EINVAL;
 	int has_write_lock = 0;
+ 	pgprot_t pgprot;
 
-	if (__prot)
+	if (prot && !(flags & MAP_CHGPROT))
 		return err;
 	/*
 	 * Sanitize the syscall parameters:
@@ -139,8 +141,10 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 
 	/* Can we represent this offset inside this architecture's pte's? */
 #if PTE_FILE_MAX_BITS < BITS_PER_LONG
-	if (pgoff + (size >> PAGE_SHIFT) >= (1UL << PTE_FILE_MAX_BITS))
+	if (pgoff + (size >> PAGE_SHIFT) >= (1UL << PTE_FILE_MAX_BITS)) {
+		err = -EOVERFLOW;
 		return err;
+	}
 #endif
 
 	/* We need down_write() to change vma->vm_flags. */
@@ -190,7 +194,31 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
-	err = populate_range(mm, vma, start, size, pgoff);
+	if (flags & MAP_CHGPROT && !(vma->vm_flags & VM_MANYPROTS)) {
+		if (!has_write_lock) {
+			up_read(&mm->mmap_sem);
+			down_write(&mm->mmap_sem);
+			has_write_lock = 1;
+			goto retry;
+		}
+		vma->vm_flags |= VM_MANYPROTS;
+	}
+
+	if (flags & MAP_CHGPROT) {
+		unsigned long vm_prots = calc_vm_prot_bits(prot);
+
+		/* vma->vm_flags >> 4 shifts VM_MAY% in place of VM_% */
+		if ((vm_prots & ~(vma->vm_flags >> 4)) &
+				(VM_READ | VM_WRITE | VM_EXEC)) {
+			err = -EPERM;
+			goto out;
+		}
+
+		pgprot = protection_map[vm_prots | VM_SHARED];
+	} else
+		pgprot = vma->vm_page_prot;
+
+	err = populate_range(mm, vma, start, size, pgoff, pgprot);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
 			downgrade_write(&mm->mmap_sem);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
