Message-Id: <200405222212.i4MMC1r14203@mail.osdl.org>
Subject: [patch 43/57] rmap 27 memset 0 vma
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:11:30 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

We're NULLifying more and more fields when initializing a vma
(mpol_set_vma_default does that too, if configured to do anything).  Now use
memset to avoid specifying fields, and save a little code too.

(Yes, I realize anon_vma will want to set vm_pgoff non-0, but I think that
will be better handled at the core, since anon vm_pgoff is negotiable up until
an anon_vma is actually assigned.)


---

 25-akpm/arch/ia64/ia32/binfmt_elf32.c |   10 ++--------
 25-akpm/arch/ia64/kernel/perfmon.c    |    7 ++-----
 25-akpm/arch/ia64/mm/init.c           |    7 +------
 25-akpm/fs/exec.c                     |    7 ++-----
 25-akpm/mm/mmap.c                     |   17 +++++------------
 5 files changed, 12 insertions(+), 36 deletions(-)

diff -puN arch/ia64/ia32/binfmt_elf32.c~rmap-27-memset-0-vma arch/ia64/ia32/binfmt_elf32.c
--- 25/arch/ia64/ia32/binfmt_elf32.c~rmap-27-memset-0-vma	2004-05-22 14:56:28.419771064 -0700
+++ 25-akpm/arch/ia64/ia32/binfmt_elf32.c	2004-05-22 14:59:37.110085776 -0700
@@ -74,15 +74,13 @@ ia64_elf32_init (struct pt_regs *regs)
 	 */
 	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
 	if (vma) {
+		memset(vma, 0, sizeof(*vma));
 		vma->vm_mm = current->mm;
 		vma->vm_start = IA32_GDT_OFFSET;
 		vma->vm_end = vma->vm_start + PAGE_SIZE;
 		vma->vm_page_prot = PAGE_SHARED;
 		vma->vm_flags = VM_READ|VM_MAYREAD;
 		vma->vm_ops = &ia32_shared_page_vm_ops;
-		vma->vm_pgoff = 0;
-		vma->vm_file = NULL;
-		vma->vm_private_data = NULL;
 		down_write(&current->mm->mmap_sem);
 		{
 			insert_vm_struct(current->mm, vma);
@@ -96,16 +94,12 @@ ia64_elf32_init (struct pt_regs *regs)
 	 */
 	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
 	if (vma) {
+		memset(vma, 0, sizeof(*vma));
 		vma->vm_mm = current->mm;
 		vma->vm_start = IA32_LDT_OFFSET;
 		vma->vm_end = vma->vm_start + PAGE_ALIGN(IA32_LDT_ENTRIES*IA32_LDT_ENTRY_SIZE);
 		vma->vm_page_prot = PAGE_SHARED;
 		vma->vm_flags = VM_READ|VM_WRITE|VM_MAYREAD|VM_MAYWRITE;
-		vma->vm_ops = NULL;
-		vma->vm_pgoff = 0;
-		vma->vm_file = NULL;
-		vma->vm_private_data = NULL;
-		mpol_set_vma_default(vma);
 		down_write(&current->mm->mmap_sem);
 		{
 			insert_vm_struct(current->mm, vma);
diff -puN arch/ia64/kernel/perfmon.c~rmap-27-memset-0-vma arch/ia64/kernel/perfmon.c
--- 25/arch/ia64/kernel/perfmon.c~rmap-27-memset-0-vma	2004-05-22 14:56:28.422770608 -0700
+++ 25-akpm/arch/ia64/kernel/perfmon.c	2004-05-22 14:59:36.585165576 -0700
@@ -2309,6 +2309,8 @@ pfm_smpl_buffer_alloc(struct task_struct
 		DPRINT(("Cannot allocate vma\n"));
 		goto error_kmem;
 	}
+	memset(vma, 0, sizeof(*vma));
+
 	/*
 	 * partially initialize the vma for the sampling buffer
 	 *
@@ -2319,11 +2321,6 @@ pfm_smpl_buffer_alloc(struct task_struct
 	vma->vm_mm	     = mm;
 	vma->vm_flags	     = VM_READ| VM_MAYREAD |VM_RESERVED;
 	vma->vm_page_prot    = PAGE_READONLY; /* XXX may need to change */
-	vma->vm_ops	     = NULL;
-	vma->vm_pgoff	     = 0;
-	vma->vm_file	     = NULL;
-	mpol_set_vma_default(vma);
-	vma->vm_private_data = NULL; 
 
 	/*
 	 * Now we have everything we need and we can initialize
diff -puN arch/ia64/mm/init.c~rmap-27-memset-0-vma arch/ia64/mm/init.c
--- 25/arch/ia64/mm/init.c~rmap-27-memset-0-vma	2004-05-22 14:56:28.423770456 -0700
+++ 25-akpm/arch/ia64/mm/init.c	2004-05-22 14:59:36.586165424 -0700
@@ -124,16 +124,12 @@ ia64_init_addr_space (void)
 	 */
 	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
 	if (vma) {
+		memset(vma, 0, sizeof(*vma));
 		vma->vm_mm = current->mm;
 		vma->vm_start = current->thread.rbs_bot & PAGE_MASK;
 		vma->vm_end = vma->vm_start + PAGE_SIZE;
 		vma->vm_page_prot = protection_map[VM_DATA_DEFAULT_FLAGS & 0x7];
 		vma->vm_flags = VM_READ|VM_WRITE|VM_MAYREAD|VM_MAYWRITE|VM_GROWSUP;
-		vma->vm_ops = NULL;
-		vma->vm_pgoff = 0;
-		vma->vm_file = NULL;
-		vma->vm_private_data = NULL;
-		mpol_set_vma_default(vma);
 		insert_vm_struct(current->mm, vma);
 	}
 
@@ -146,7 +142,6 @@ ia64_init_addr_space (void)
 			vma->vm_end = PAGE_SIZE;
 			vma->vm_page_prot = __pgprot(pgprot_val(PAGE_READONLY) | _PAGE_MA_NAT);
 			vma->vm_flags = VM_READ | VM_MAYREAD | VM_IO | VM_RESERVED;
-			mpol_set_vma_default(vma);
 			insert_vm_struct(current->mm, vma);
 		}
 	}
diff -puN fs/exec.c~rmap-27-memset-0-vma fs/exec.c
--- 25/fs/exec.c~rmap-27-memset-0-vma	2004-05-22 14:56:28.424770304 -0700
+++ 25-akpm/fs/exec.c	2004-05-22 14:59:36.588165120 -0700
@@ -404,6 +404,8 @@ int setup_arg_pages(struct linux_binprm 
 		return -ENOMEM;
 	}
 
+	memset(mpnt, 0, sizeof(*mpnt));
+
 	down_write(&mm->mmap_sem);
 	{
 		mpnt->vm_mm = mm;
@@ -425,11 +427,6 @@ int setup_arg_pages(struct linux_binprm 
 		else
 			mpnt->vm_flags = VM_STACK_FLAGS;
 		mpnt->vm_page_prot = protection_map[mpnt->vm_flags & 0x7];
-		mpnt->vm_ops = NULL;
-		mpnt->vm_pgoff = 0;
-		mpnt->vm_file = NULL;
-		mpol_set_vma_default(mpnt);
-		mpnt->vm_private_data = (void *) 0;
 		insert_vm_struct(mm, mpnt);
 		mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 	}
diff -puN mm/mmap.c~rmap-27-memset-0-vma mm/mmap.c
--- 25/mm/mmap.c~rmap-27-memset-0-vma	2004-05-22 14:56:28.426770000 -0700
+++ 25-akpm/mm/mmap.c	2004-05-22 14:59:37.240066016 -0700
@@ -689,21 +689,18 @@ munmap_back:
 	 * not unmapped, but the maps are removed from the list.
 	 */
 	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	error = -ENOMEM;
-	if (!vma)
+	if (!vma) {
+		error = -ENOMEM;
 		goto unacct_error;
+	}
+	memset(vma, 0, sizeof(*vma));
 
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
 	vma->vm_flags = vm_flags;
 	vma->vm_page_prot = protection_map[vm_flags & 0x0f];
-	vma->vm_ops = NULL;
 	vma->vm_pgoff = pgoff;
-	vma->vm_file = NULL;
-	vma->vm_private_data = NULL;
-	vma->vm_next = NULL;
-	mpol_set_vma_default(vma);
 
 	if (file) {
 		error = -EINVAL;
@@ -1447,17 +1444,13 @@ unsigned long do_brk(unsigned long addr,
 		vm_unacct_memory(len >> PAGE_SHIFT);
 		return -ENOMEM;
 	}
+	memset(vma, 0, sizeof(*vma));
 
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
 	vma->vm_flags = flags;
 	vma->vm_page_prot = protection_map[flags & 0x0f];
-	vma->vm_ops = NULL;
-	vma->vm_pgoff = 0;
-	vma->vm_file = NULL;
-	vma->vm_private_data = NULL;
-	mpol_set_vma_default(vma);
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 out:
 	mm->total_vm += len >> PAGE_SHIFT;

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
