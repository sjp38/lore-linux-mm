Message-Id: <200405222212.i4MMCHr14270@mail.osdl.org>
Subject: [patch 45/57] rmap 29 VM_RESERVED safety
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:11:47 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

From: Andrea Arcangeli <andrea@suse.de>

Set VM_RESERVED in videobuf_mmap_mapper, to warn do_no_page and swapout not to
worry about its pages.  Set VM_RESERVED in ia64_elf32_init, it too provides an
unusual nopage which might surprise higher level checks.  Future safety: they
don't actually pose a problem in this current tree.


---

 25-akpm/arch/ia64/ia32/binfmt_elf32.c   |    2 +-
 25-akpm/drivers/media/video/video-buf.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/ia64/ia32/binfmt_elf32.c~rmap-29-vm_reserved-safety arch/ia64/ia32/binfmt_elf32.c
--- 25/arch/ia64/ia32/binfmt_elf32.c~rmap-29-vm_reserved-safety	2004-05-22 14:56:28.701728200 -0700
+++ 25-akpm/arch/ia64/ia32/binfmt_elf32.c	2004-05-22 14:59:36.581166184 -0700
@@ -79,7 +79,7 @@ ia64_elf32_init (struct pt_regs *regs)
 		vma->vm_start = IA32_GDT_OFFSET;
 		vma->vm_end = vma->vm_start + PAGE_SIZE;
 		vma->vm_page_prot = PAGE_SHARED;
-		vma->vm_flags = VM_READ|VM_MAYREAD;
+		vma->vm_flags = VM_READ|VM_MAYREAD|VM_RESERVED;
 		vma->vm_ops = &ia32_shared_page_vm_ops;
 		down_write(&current->mm->mmap_sem);
 		{
diff -puN drivers/media/video/video-buf.c~rmap-29-vm_reserved-safety drivers/media/video/video-buf.c
--- 25/drivers/media/video/video-buf.c~rmap-29-vm_reserved-safety	2004-05-22 14:56:28.702728048 -0700
+++ 25-akpm/drivers/media/video/video-buf.c	2004-05-22 14:56:28.707727288 -0700
@@ -1176,7 +1176,7 @@ int videobuf_mmap_mapper(struct vm_area_
 	map->end      = vma->vm_end;
 	map->q        = q;
 	vma->vm_ops   = &videobuf_vm_ops;
-	vma->vm_flags |= VM_DONTEXPAND;
+	vma->vm_flags |= VM_DONTEXPAND | VM_RESERVED;
 	vma->vm_flags &= ~VM_IO; /* using shared anonymous pages */
 	vma->vm_private_data = map;
 	dprintk(1,"mmap %p: %08lx-%08lx pgoff %08lx bufs %d-%d\n",

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
