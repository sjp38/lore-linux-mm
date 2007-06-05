Message-Id: <20070605151203.790585000@chello.nl>
References: <20070605150523.786600000@chello.nl>
Date: Tue, 05 Jun 2007 17:05:27 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 4/4] mm: variable length argument support
Content-Disposition: inline; filename=no_MAX_ARG_PAGES.patch
Sender: owner-linux-mm@kvack.org
From: Ollie Wild <aaw@google.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Ollie Wild <aaw@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Remove the arg+env limit of MAX_ARG_PAGES by copying the strings directly
from the old mm into the new mm.

We create the new mm before the binfmt code runs, and place the new stack
at the very top of the address space. Once the binfmt code runs and figures
out where the stack should be, we move it downwards.

It is a bit peculiar in that we have one task with two mm's, one of which is
inactive.

Signed-off-by: Ollie Wild <aaw@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/ia64/ia32/binfmt_elf32.c     |   61 ----
 arch/um/kernel/trap.c             |    2 
 arch/x86_64/ia32/ia32_aout.c      |    2 
 arch/x86_64/ia32/ia32_binfmt.c    |   58 ---
 fs/binfmt_elf.c                   |   28 +
 fs/binfmt_elf_fdpic.c             |    8 
 fs/binfmt_misc.c                  |    4 
 fs/binfmt_script.c                |    4 
 fs/compat.c                       |  130 +++-----
 fs/exec.c                         |  566 +++++++++++++++++++++++---------------
 include/asm-um/processor-i386.h   |    3 
 include/asm-um/processor-x86_64.h |    3 
 include/linux/binfmts.h           |   17 -
 include/linux/mm.h                |    7 
 kernel/auditsc.c                  |    2 
 mm/mmap.c                         |   56 ++-
 mm/mprotect.c                     |    2 
 17 files changed, 495 insertions(+), 458 deletions(-)

Index: linux-2.6-2/arch/um/kernel/trap.c
===================================================================
--- linux-2.6-2.orig/arch/um/kernel/trap.c	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/arch/um/kernel/trap.c	2007-06-05 16:29:45.000000000 +0200
@@ -61,8 +61,6 @@ int handle_page_fault(unsigned long addr
 		goto good_area;
 	else if(!(vma->vm_flags & VM_GROWSDOWN))
 		goto out;
-	else if(is_user && !ARCH_IS_STACKGROW(address))
-		goto out;
 	else if(expand_stack(vma, address))
 		goto out;
 
Index: linux-2.6-2/arch/x86_64/ia32/ia32_binfmt.c
===================================================================
--- linux-2.6-2.orig/arch/x86_64/ia32/ia32_binfmt.c	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/arch/x86_64/ia32/ia32_binfmt.c	2007-06-05 16:29:45.000000000 +0200
@@ -232,9 +232,6 @@ do {							\
 #define load_elf_binary load_elf32_binary
 
 #define ELF_PLAT_INIT(r, load_addr)	elf32_init(r)
-#define setup_arg_pages(bprm, stack_top, exec_stack) \
-	ia32_setup_arg_pages(bprm, stack_top, exec_stack)
-int ia32_setup_arg_pages(struct linux_binprm *bprm, unsigned long stack_top, int executable_stack);
 
 #undef start_thread
 #define start_thread(regs,new_rip,new_rsp) do { \
@@ -286,61 +283,6 @@ static void elf32_init(struct pt_regs *r
 	me->thread.es = __USER_DS;
 }
 
-int ia32_setup_arg_pages(struct linux_binprm *bprm, unsigned long stack_top,
-			 int executable_stack)
-{
-	unsigned long stack_base;
-	struct vm_area_struct *mpnt;
-	struct mm_struct *mm = current->mm;
-	int i, ret;
-
-	stack_base = stack_top - MAX_ARG_PAGES * PAGE_SIZE;
-	mm->arg_start = bprm->p + stack_base;
-
-	bprm->p += stack_base;
-	if (bprm->loader)
-		bprm->loader += stack_base;
-	bprm->exec += stack_base;
-
-	mpnt = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
-	if (!mpnt) 
-		return -ENOMEM; 
-
-	down_write(&mm->mmap_sem);
-	{
-		mpnt->vm_mm = mm;
-		mpnt->vm_start = PAGE_MASK & (unsigned long) bprm->p;
-		mpnt->vm_end = stack_top;
-		if (executable_stack == EXSTACK_ENABLE_X)
-			mpnt->vm_flags = VM_STACK_FLAGS |  VM_EXEC;
-		else if (executable_stack == EXSTACK_DISABLE_X)
-			mpnt->vm_flags = VM_STACK_FLAGS & ~VM_EXEC;
-		else
-			mpnt->vm_flags = VM_STACK_FLAGS;
- 		mpnt->vm_page_prot = (mpnt->vm_flags & VM_EXEC) ? 
- 			PAGE_COPY_EXEC : PAGE_COPY;
-		if ((ret = insert_vm_struct(mm, mpnt))) {
-			up_write(&mm->mmap_sem);
-			kmem_cache_free(vm_area_cachep, mpnt);
-			return ret;
-		}
-		mm->stack_vm = mm->total_vm = vma_pages(mpnt);
-	} 
-
-	for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
-		struct page *page = bprm->page[i];
-		if (page) {
-			bprm->page[i] = NULL;
-			install_arg_page(mpnt, page, stack_base);
-		}
-		stack_base += PAGE_SIZE;
-	}
-	up_write(&mm->mmap_sem);
-	
-	return 0;
-}
-EXPORT_SYMBOL(ia32_setup_arg_pages);
-
 #ifdef CONFIG_SYSCTL
 /* Register vsyscall32 into the ABI table */
 #include <linux/sysctl.h>
Index: linux-2.6-2/fs/binfmt_elf.c
===================================================================
--- linux-2.6-2.orig/fs/binfmt_elf.c	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/fs/binfmt_elf.c	2007-06-05 16:29:45.000000000 +0200
@@ -148,6 +148,7 @@ create_elf_tables(struct linux_binprm *b
 	elf_addr_t *elf_info;
 	int ei_index = 0;
 	struct task_struct *tsk = current;
+	struct vm_area_struct *vma;
 
 	/*
 	 * If this architecture has a platform capability string, copy it
@@ -234,6 +235,15 @@ create_elf_tables(struct linux_binprm *b
 	sp = (elf_addr_t __user *)bprm->p;
 #endif
 
+
+	/*
+	 * Grow the stack manually; some architectures have a limit on how
+	 * far ahead a user-space access may be in order to grow the stack.
+	 */
+	vma = find_extend_vma(current->mm, bprm->p);
+	if (!vma)
+		return -EFAULT;
+
 	/* Now, let's put argc (and argv, envp if appropriate) on the stack */
 	if (__put_user(argc, sp++))
 		return -EFAULT;
@@ -254,8 +264,8 @@ create_elf_tables(struct linux_binprm *b
 		size_t len;
 		if (__put_user((elf_addr_t)p, argv++))
 			return -EFAULT;
-		len = strnlen_user((void __user *)p, PAGE_SIZE*MAX_ARG_PAGES);
-		if (!len || len > PAGE_SIZE*MAX_ARG_PAGES)
+		len = strnlen_user((void __user *)p, MAX_ARG_STRLEN);
+		if (!len || len > MAX_ARG_STRLEN)
 			return 0;
 		p += len;
 	}
@@ -266,8 +276,8 @@ create_elf_tables(struct linux_binprm *b
 		size_t len;
 		if (__put_user((elf_addr_t)p, envp++))
 			return -EFAULT;
-		len = strnlen_user((void __user *)p, PAGE_SIZE*MAX_ARG_PAGES);
-		if (!len || len > PAGE_SIZE*MAX_ARG_PAGES)
+		len = strnlen_user((void __user *)p, MAX_ARG_STRLEN);
+		if (!len || len > MAX_ARG_STRLEN)
 			return 0;
 		p += len;
 	}
@@ -777,10 +787,6 @@ static int load_elf_binary(struct linux_
 	}
 
 	/* OK, This is the point of no return */
-	current->mm->start_data = 0;
-	current->mm->end_data = 0;
-	current->mm->end_code = 0;
-	current->mm->mmap = NULL;
 	current->flags &= ~PF_FORKNOEXEC;
 	current->mm->def_flags = def_flags;
 
@@ -988,9 +994,13 @@ static int load_elf_binary(struct linux_
 
 	compute_creds(bprm);
 	current->flags &= ~PF_FORKNOEXEC;
-	create_elf_tables(bprm, &loc->elf_ex,
+	retval = create_elf_tables(bprm, &loc->elf_ex,
 			  (interpreter_type == INTERPRETER_AOUT),
 			  load_addr, interp_load_addr);
+	if (retval < 0) {
+		send_sig(SIGKILL, current, 0);
+		goto out;
+	}
 	/* N.B. passed_fileno might not be initialized? */
 	if (interpreter_type == INTERPRETER_AOUT)
 		current->mm->arg_start += strlen(passed_fileno) + 1;
Index: linux-2.6-2/fs/binfmt_elf_fdpic.c
===================================================================
--- linux-2.6-2.orig/fs/binfmt_elf_fdpic.c	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/fs/binfmt_elf_fdpic.c	2007-06-05 16:29:45.000000000 +0200
@@ -621,8 +621,8 @@ static int create_elf_fdpic_tables(struc
 	p = (char __user *) current->mm->arg_start;
 	for (loop = bprm->argc; loop > 0; loop--) {
 		__put_user((elf_caddr_t) p, argv++);
-		len = strnlen_user(p, PAGE_SIZE * MAX_ARG_PAGES);
-		if (!len || len > PAGE_SIZE * MAX_ARG_PAGES)
+		len = strnlen_user(p, MAX_ARG_STRLEN);
+		if (!len || len > MAX_ARG_STRLEN)
 			return -EINVAL;
 		p += len;
 	}
@@ -633,8 +633,8 @@ static int create_elf_fdpic_tables(struc
 	current->mm->env_start = (unsigned long) p;
 	for (loop = bprm->envc; loop > 0; loop--) {
 		__put_user((elf_caddr_t)(unsigned long) p, envp++);
-		len = strnlen_user(p, PAGE_SIZE * MAX_ARG_PAGES);
-		if (!len || len > PAGE_SIZE * MAX_ARG_PAGES)
+		len = strnlen_user(p, MAX_ARG_STRLEN);
+		if (!len || len > MAX_ARG_STRLEN)
 			return -EINVAL;
 		p += len;
 	}
Index: linux-2.6-2/fs/binfmt_misc.c
===================================================================
--- linux-2.6-2.orig/fs/binfmt_misc.c	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/fs/binfmt_misc.c	2007-06-05 16:29:45.000000000 +0200
@@ -126,7 +126,9 @@ static int load_misc_binary(struct linux
 		goto _ret;
 
 	if (!(fmt->flags & MISC_FMT_PRESERVE_ARGV0)) {
-		remove_arg_zero(bprm);
+		retval = remove_arg_zero(bprm);
+		if (retval)
+			goto _ret;
 	}
 
 	if (fmt->flags & MISC_FMT_OPEN_BINARY) {
Index: linux-2.6-2/fs/binfmt_script.c
===================================================================
--- linux-2.6-2.orig/fs/binfmt_script.c	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/fs/binfmt_script.c	2007-06-05 16:29:45.000000000 +0200
@@ -67,7 +67,9 @@ static int load_script(struct linux_binp
 	 * This is done in reverse order, because of how the
 	 * user environment and arguments are stored.
 	 */
-	remove_arg_zero(bprm);
+	retval = remove_arg_zero(bprm);
+	if (retval)
+		return retval;
 	retval = copy_strings_kernel(1, &bprm->interp, bprm);
 	if (retval < 0) return retval; 
 	bprm->argc++;
Index: linux-2.6-2/fs/compat.c
===================================================================
--- linux-2.6-2.orig/fs/compat.c	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/fs/compat.c	2007-06-05 16:29:45.000000000 +0200
@@ -1257,6 +1257,7 @@ static int compat_copy_strings(int argc,
 {
 	struct page *kmapped_page = NULL;
 	char *kaddr = NULL;
+	unsigned long kpos = 0;
 	int ret;
 
 	while (argc-- > 0) {
@@ -1265,92 +1266,84 @@ static int compat_copy_strings(int argc,
 		unsigned long pos;
 
 		if (get_user(str, argv+argc) ||
-			!(len = strnlen_user(compat_ptr(str), bprm->p))) {
+		    !(len = strnlen_user(compat_ptr(str), MAX_ARG_STRLEN))) {
 			ret = -EFAULT;
 			goto out;
 		}
 
-		if (bprm->p < len)  {
+		if (MAX_ARG_STRLEN < len) {
 			ret = -E2BIG;
 			goto out;
 		}
 
-		bprm->p -= len;
-		/* XXX: add architecture specific overflow check here. */
+		/* We're going to work our way backwords. */
 		pos = bprm->p;
+		str += len;
+		bprm->p -= len;
 
 		while (len > 0) {
-			int i, new, err;
 			int offset, bytes_to_copy;
-			struct page *page;
 
 			offset = pos % PAGE_SIZE;
-			i = pos/PAGE_SIZE;
-			page = bprm->page[i];
-			new = 0;
-			if (!page) {
-				page = alloc_page(GFP_HIGHUSER);
-				bprm->page[i] = page;
-				if (!page) {
-					ret = -ENOMEM;
+			if (offset == 0)
+				offset = PAGE_SIZE;
+
+			bytes_to_copy = offset;
+			if (bytes_to_copy > len)
+				bytes_to_copy = len;
+
+			offset -= bytes_to_copy;
+			pos -= bytes_to_copy;
+			str -= bytes_to_copy;
+			len -= bytes_to_copy;
+
+			if (!kmapped_page || kpos != (pos & PAGE_MASK)) {
+				struct page *page;
+
+#ifdef CONFIG_STACK_GROWSUP
+				ret = expand_downwards(bprm->vma, pos);
+				if (ret < 0) {
+					/* We've exceed the stack rlimit. */
+					ret = -E2BIG;
+					goto out;
+				}
+#endif
+				ret = get_user_pages(current, bprm->mm, pos,
+						     1, 1, 1, &page, NULL);
+				if (ret <= 0) {
+					/* We've exceed the stack rlimit. */
+					ret = -E2BIG;
 					goto out;
 				}
-				new = 1;
-			}
 
-			if (page != kmapped_page) {
-				if (kmapped_page)
+				if (kmapped_page) {
+					flush_kernel_dcache_page(kmapped_page);
 					kunmap(kmapped_page);
+					put_page(kmapped_page);
+				}
 				kmapped_page = page;
 				kaddr = kmap(kmapped_page);
+				kpos = pos & PAGE_MASK;
+				flush_cache_page(bprm->vma, kpos,
+						 page_to_pfn(kmapped_page));
 			}
-			if (new && offset)
-				memset(kaddr, 0, offset);
-			bytes_to_copy = PAGE_SIZE - offset;
-			if (bytes_to_copy > len) {
-				bytes_to_copy = len;
-				if (new)
-					memset(kaddr+offset+len, 0,
-						PAGE_SIZE-offset-len);
-			}
-			err = copy_from_user(kaddr+offset, compat_ptr(str),
-						bytes_to_copy);
-			if (err) {
+			if (copy_from_user(kaddr+offset, compat_ptr(str),
+						bytes_to_copy)) {
 				ret = -EFAULT;
 				goto out;
 			}
-
-			pos += bytes_to_copy;
-			str += bytes_to_copy;
-			len -= bytes_to_copy;
 		}
 	}
 	ret = 0;
 out:
-	if (kmapped_page)
+	if (kmapped_page) {
+		flush_kernel_dcache_page(kmapped_page);
 		kunmap(kmapped_page);
-	return ret;
-}
-
-#ifdef CONFIG_MMU
-
-#define free_arg_pages(bprm) do { } while (0)
-
-#else
-
-static inline void free_arg_pages(struct linux_binprm *bprm)
-{
-	int i;
-
-	for (i = 0; i < MAX_ARG_PAGES; i++) {
-		if (bprm->page[i])
-			__free_page(bprm->page[i]);
-		bprm->page[i] = NULL;
+		put_page(kmapped_page);
 	}
+	return ret;
 }
 
-#endif /* CONFIG_MMU */
-
 /*
  * compat_do_execve() is mostly a copy of do_execve(), with the exception
  * that it processes 32 bit argv and envp pointers.
@@ -1363,7 +1356,6 @@ int compat_do_execve(char * filename,
 	struct linux_binprm *bprm;
 	struct file *file;
 	int retval;
-	int i;
 
 	retval = -ENOMEM;
 	bprm = kzalloc(sizeof(*bprm), GFP_KERNEL);
@@ -1377,24 +1369,19 @@ int compat_do_execve(char * filename,
 
 	sched_exec();
 
-	bprm->p = PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *);
 	bprm->file = file;
 	bprm->filename = filename;
 	bprm->interp = filename;
-	bprm->mm = mm_alloc();
-	retval = -ENOMEM;
-	if (!bprm->mm)
-		goto out_file;
 
-	retval = init_new_context(current, bprm->mm);
-	if (retval < 0)
-		goto out_mm;
+	retval = bprm_mm_init(bprm);
+	if (retval)
+		goto out_file;
 
-	bprm->argc = compat_count(argv, bprm->p / sizeof(compat_uptr_t));
+	bprm->argc = compat_count(argv, MAX_ARG_STRINGS);
 	if ((retval = bprm->argc) < 0)
 		goto out_mm;
 
-	bprm->envc = compat_count(envp, bprm->p / sizeof(compat_uptr_t));
+	bprm->envc = compat_count(envp, MAX_ARG_STRINGS);
 	if ((retval = bprm->envc) < 0)
 		goto out_mm;
 
@@ -1419,10 +1406,8 @@ int compat_do_execve(char * filename,
 	if (retval < 0)
 		goto out;
 
-	retval = search_binary_handler(bprm, regs);
+	retval = search_binary_handler(bprm,regs);
 	if (retval >= 0) {
-		free_arg_pages(bprm);
-
 		/* execve success */
 		security_bprm_free(bprm);
 		acct_update_integrals(current);
@@ -1431,19 +1416,12 @@ int compat_do_execve(char * filename,
 	}
 
 out:
-	/* Something went wrong, return the inode and free the argument pages*/
-	for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
-		struct page * page = bprm->page[i];
-		if (page)
-			__free_page(page);
-	}
-
 	if (bprm->security)
 		security_bprm_free(bprm);
 
 out_mm:
 	if (bprm->mm)
-		mmdrop(bprm->mm);
+		mmput (bprm->mm);
 
 out_file:
 	if (bprm->file) {
Index: linux-2.6-2/fs/exec.c
===================================================================
--- linux-2.6-2.orig/fs/exec.c	2007-06-05 16:29:41.000000000 +0200
+++ linux-2.6-2/fs/exec.c	2007-06-05 16:29:45.000000000 +0200
@@ -54,6 +54,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
+#include <asm/tlb.h>
 
 #ifdef CONFIG_KMOD
 #include <linux/kmod.h>
@@ -178,6 +179,157 @@ exit:
 	goto out;
 }
 
+#ifdef CONFIG_MMU
+
+static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
+		int write)
+{
+	struct page *page;
+	int ret;
+
+#ifdef CONFIG_STACK_GROWSUP
+	if (write) {
+		ret = expand_downwards(bprm->vma, pos);
+		if (ret < 0)
+			return NULL;
+	}
+#endif
+	ret = get_user_pages(current, bprm->mm, pos,
+			1, write, 1, &page, NULL);
+	if (ret <= 0)
+		return NULL;
+
+	return page;
+}
+
+static void put_arg_page(struct page *page)
+{
+	put_page(page);
+}
+
+static void free_arg_page(struct linux_binprm *bprm, int i)
+{
+}
+
+static void free_arg_pages(struct linux_binprm *bprm)
+{
+}
+
+#else
+
+static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
+		int write)
+{
+	struct page *page;
+
+	page = bprm->page[pos / PAGE_SIZE];
+	if (!page && write) {
+		page = alloc_page(GFP_HIGHUSER|__GFP_ZERO);
+		if (!page)
+			return NULL;
+		bprm->page[pos / PAGE_SIZE] = page;
+	}
+
+	return page;
+}
+
+static void put_arg_page(struct page *page)
+{
+}
+
+static void free_arg_page(struct linux_binprm *bprm, int i)
+{
+	if (bprm->page[i]) {
+		__free_page(bprm->page[i]);
+		bprm->page[i] = NULL;
+	}
+}
+
+static void free_arg_pages(struct linux_binprm *bprm)
+{
+	int i;
+
+	for (i = 0; i < MAX_ARG_PAGES; i++)
+		free_arg_page(bprm, i);
+}
+
+#endif /* CONFIG_MMU */
+
+/*
+ * Create a new mm_struct and populate it with a temporary stack
+ * vm_area_struct.  We don't have enough context at this point to set the stack
+ * flags, permissions, and offset, so we use temporary values.  We'll update
+ * them later in setup_arg_pages().
+ */
+int bprm_mm_init(struct linux_binprm *bprm)
+{
+	int err;
+	struct mm_struct *mm = NULL;
+	struct vm_area_struct *vma = NULL;
+
+	bprm->mm = mm = mm_alloc();
+	err = -ENOMEM;
+	if (!mm)
+		goto err;
+
+	if ((err = init_new_context(current, mm)))
+		goto err;
+
+#ifdef CONFIG_MMU
+	bprm->vma = vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	err = -ENOMEM;
+	if (!vma)
+		goto err;
+
+	down_write(&mm->mmap_sem);
+	{
+		vma->vm_mm = mm;
+
+		/*
+		 * Place the stack at the top of user memory.  Later, we'll
+		 * move this to an appropriate place.  We don't use STACK_TOP
+		 * because that can depend on attributes which aren't
+		 * configured yet.
+		 */
+		vma->vm_end = STACK_TOP_MAX;
+		vma->vm_start = vma->vm_end - PAGE_SIZE;
+
+		vma->vm_flags = VM_STACK_FLAGS;
+		vma->vm_page_prot = protection_map[vma->vm_flags & 0x7];
+		if ((err = insert_vm_struct(mm, vma))) {
+			up_write(&mm->mmap_sem);
+			goto err;
+		}
+
+		mm->stack_vm = mm->total_vm = 1;
+	}
+	up_write(&mm->mmap_sem);
+
+	bprm->p = vma->vm_end - sizeof(void *);
+#else
+	bprm->p = PAGE_SIZE * MAX_ARG_PAGES - sizeof(void *);
+#endif
+
+	return 0;
+
+err:
+#ifdef CONFIG_MMU
+	if (vma) {
+		bprm->vma = NULL;
+		kmem_cache_free(vm_area_cachep, vma);
+	}
+#endif
+
+	if (mm) {
+		bprm->mm = NULL;
+		mmdrop(mm);
+	}
+
+	return err;
+}
+
+EXPORT_SYMBOL(bprm_mm_init);
+
 /*
  * count() counts the number of strings in array ARGV.
  */
@@ -203,15 +355,16 @@ static int count(char __user * __user * 
 }
 
 /*
- * 'copy_strings()' copies argument/environment strings from user
- * memory to free pages in kernel mem. These are in a format ready
- * to be put directly into the top of new user memory.
+ * 'copy_strings()' copies argument/environment strings from the old
+ * processes's memory to the new process's stack.  The call to get_user_pages()
+ * ensures the destination page is created and not swapped out.
  */
 static int copy_strings(int argc, char __user * __user * argv,
 			struct linux_binprm *bprm)
 {
 	struct page *kmapped_page = NULL;
 	char *kaddr = NULL;
+	unsigned long kpos = 0;
 	int ret;
 
 	while (argc-- > 0) {
@@ -220,69 +373,77 @@ static int copy_strings(int argc, char _
 		unsigned long pos;
 
 		if (get_user(str, argv+argc) ||
-				!(len = strnlen_user(str, bprm->p))) {
+				!(len = strnlen_user(str, MAX_ARG_STRLEN))) {
 			ret = -EFAULT;
 			goto out;
 		}
 
-		if (bprm->p < len)  {
+#ifdef CONFIG_MMU
+		if (MAX_ARG_STRLEN < len) {
+			ret = -E2BIG;
+			goto out;
+		}
+#else
+		if (bprm->p < len) {
 			ret = -E2BIG;
 			goto out;
 		}
+#endif
 
-		bprm->p -= len;
-		/* XXX: add architecture specific overflow check here. */
+		/* We're going to work our way backwords. */
 		pos = bprm->p;
+		str += len;
+		bprm->p -= len;
 
 		while (len > 0) {
-			int i, new, err;
 			int offset, bytes_to_copy;
-			struct page *page;
 
 			offset = pos % PAGE_SIZE;
-			i = pos/PAGE_SIZE;
-			page = bprm->page[i];
-			new = 0;
-			if (!page) {
-				page = alloc_page(GFP_HIGHUSER);
-				bprm->page[i] = page;
+			if (offset == 0)
+				offset = PAGE_SIZE;
+
+			bytes_to_copy = offset;
+			if (bytes_to_copy > len)
+				bytes_to_copy = len;
+
+			offset -= bytes_to_copy;
+			pos -= bytes_to_copy;
+			str -= bytes_to_copy;
+			len -= bytes_to_copy;
+
+			if (!kmapped_page || kpos != (pos & PAGE_MASK)) {
+				struct page *page;
+
+				page = get_arg_page(bprm, pos, 1);
 				if (!page) {
-					ret = -ENOMEM;
+					ret = -E2BIG;
 					goto out;
 				}
-				new = 1;
-			}
 
-			if (page != kmapped_page) {
-				if (kmapped_page)
+				if (kmapped_page) {
+					flush_kernel_dcache_page(kmapped_page);
 					kunmap(kmapped_page);
+					put_arg_page(kmapped_page);
+				}
 				kmapped_page = page;
 				kaddr = kmap(kmapped_page);
+				kpos = pos & PAGE_MASK;
+				flush_cache_page(bprm->vma, kpos,
+						 page_to_pfn(kmapped_page));
 			}
-			if (new && offset)
-				memset(kaddr, 0, offset);
-			bytes_to_copy = PAGE_SIZE - offset;
-			if (bytes_to_copy > len) {
-				bytes_to_copy = len;
-				if (new)
-					memset(kaddr+offset+len, 0,
-						PAGE_SIZE-offset-len);
-			}
-			err = copy_from_user(kaddr+offset, str, bytes_to_copy);
-			if (err) {
+			if (copy_from_user(kaddr+offset, str, bytes_to_copy)) {
 				ret = -EFAULT;
 				goto out;
 			}
-
-			pos += bytes_to_copy;
-			str += bytes_to_copy;
-			len -= bytes_to_copy;
 		}
 	}
 	ret = 0;
 out:
-	if (kmapped_page)
+	if (kmapped_page) {
+		flush_kernel_dcache_page(kmapped_page);
 		kunmap(kmapped_page);
+		put_arg_page(kmapped_page);
+	}
 	return ret;
 }
 
@@ -302,154 +463,157 @@ int copy_strings_kernel(int argc,char **
 EXPORT_SYMBOL(copy_strings_kernel);
 
 #ifdef CONFIG_MMU
-/*
- * This routine is used to map in a page into an address space: needed by
- * execve() for the initial stack and environment pages.
- *
- * vma->vm_mm->mmap_sem is held for writing.
- */
-void install_arg_page(struct vm_area_struct *vma,
-			struct page *page, unsigned long address)
+
+static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	pte_t * pte;
-	spinlock_t *ptl;
+	unsigned long old_start = vma->vm_start;
+	unsigned long old_end = vma->vm_end;
+	unsigned long length = old_end - old_start;
+	unsigned long new_start = old_start + shift;
+	unsigned long new_end = old_end + shift;
+	struct mmu_gather *tlb;
+
+	BUG_ON(new_start > new_end);
+
+	if (new_start < old_start) {
+		if (vma != find_vma(mm, new_start))
+			return -EFAULT;
+
+		vma_adjust(vma, new_start, old_end,
+			   vma->vm_pgoff - (-shift >> PAGE_SHIFT), NULL);
+
+		if (length != move_page_tables(vma, old_start,
+					       vma, new_start, length))
+			return -ENOMEM;
+
+		lru_add_drain();
+		tlb = tlb_gather_mmu(mm, 0);
+		if (new_end > old_start)
+			free_pgd_range(&tlb, new_end, old_end, new_end,
+				vma->vm_next ? vma->vm_next->vm_start : 0);
+		else
+			free_pgd_range(&tlb, old_start, old_end, new_end,
+				vma->vm_next ? vma->vm_next->vm_start : 0);
+		tlb_finish_mmu(tlb, new_end, old_end);
 
-	if (unlikely(anon_vma_prepare(vma)))
-		goto out;
+		vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
+	} else {
+		struct vm_area_struct *tmp, *prev;
 
-	flush_dcache_page(page);
-	pte = get_locked_pte(mm, address, &ptl);
-	if (!pte)
-		goto out;
-	if (!pte_none(*pte)) {
-		pte_unmap_unlock(pte, ptl);
-		goto out;
+		tmp = find_vma_prev(mm, new_end, &prev);
+		if ((tmp && tmp->vm_start < new_end) || prev != vma)
+			return -EFAULT;
+
+		find_vma_prev(mm, vma->vm_start, &prev);
+
+		vma_adjust(vma, old_start, new_end, vma->vm_pgoff, NULL);
+
+		if (length != move_page_tables_up(vma, old_start,
+					       vma, new_start, length))
+			return -ENOMEM;
+
+		lru_add_drain();
+		tlb = tlb_gather_mmu(mm, 0);
+		free_pgd_range(&tlb, old_start, new_start,
+			       prev ? prev->vm_end: 0, new_start);
+		tlb_finish_mmu(tlb, old_start, new_start);
+
+		vma_adjust(vma, new_start, new_end,
+			   vma->vm_pgoff + (shift >> PAGE_SHIFT), NULL);
 	}
-	inc_mm_counter(mm, anon_rss);
-	lru_cache_add_active(page);
-	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
-					page, vma->vm_page_prot))));
-	page_add_new_anon_rmap(page, vma, address);
-	pte_unmap_unlock(pte, ptl);
 
-	/* no need for flush_tlb */
-	return;
-out:
-	__free_page(page);
-	force_sig(SIGKILL, current);
+	return 0;
 }
 
 #define EXTRA_STACK_VM_PAGES	20	/* random */
 
+/* Finalizes the stack vm_area_struct.  The flags and permissions are updated,
+ * the stack is optionally relocated, and some extra space is added.
+ */
 int setup_arg_pages(struct linux_binprm *bprm,
 		    unsigned long stack_top,
 		    int executable_stack)
 {
-	unsigned long stack_base;
-	struct vm_area_struct *mpnt;
+	unsigned long ret;
+	unsigned long stack_base, stack_shift;
 	struct mm_struct *mm = current->mm;
-	int i, ret;
-	long arg_size;
+	struct vm_area_struct *vma = bprm->vma;
 
 #ifdef CONFIG_STACK_GROWSUP
-	/* Move the argument and environment strings to the bottom of the
-	 * stack space.
-	 */
-	int offset, j;
-	char *to, *from;
-
-	/* Start by shifting all the pages down */
-	i = 0;
-	for (j = 0; j < MAX_ARG_PAGES; j++) {
-		struct page *page = bprm->page[j];
-		if (!page)
-			continue;
-		bprm->page[i++] = page;
-	}
-
-	/* Now move them within their pages */
-	offset = bprm->p % PAGE_SIZE;
-	to = kmap(bprm->page[0]);
-	for (j = 1; j < i; j++) {
-		memmove(to, to + offset, PAGE_SIZE - offset);
-		from = kmap(bprm->page[j]);
-		memcpy(to + PAGE_SIZE - offset, from, offset);
-		kunmap(bprm->page[j - 1]);
-		to = from;
-	}
-	memmove(to, to + offset, PAGE_SIZE - offset);
-	kunmap(bprm->page[j - 1]);
-
 	/* Limit stack size to 1GB */
 	stack_base = current->signal->rlim[RLIMIT_STACK].rlim_max;
 	if (stack_base > (1 << 30))
 		stack_base = 1 << 30;
-	stack_base = PAGE_ALIGN(stack_top - stack_base);
 
-	/* Adjust bprm->p to point to the end of the strings. */
-	bprm->p = stack_base + PAGE_SIZE * i - offset;
+	/* Make sure we didn't let the argument array grow too large. */
+	if (vma->vm_end - vma->vm_start > stack_base)
+		return -ENOMEM;
 
-	mm->arg_start = stack_base;
-	arg_size = i << PAGE_SHIFT;
+	stack_base = PAGE_ALIGN(stack_top - stack_base);
 
-	/* zero pages that were copied above */
-	while (i < MAX_ARG_PAGES)
-		bprm->page[i++] = NULL;
+	stack_shift = stack_base - vma->vm_start;
+	mm->arg_start = bprm->p + stack_shift;
+	bprm->p = vma->vm_end + stack_shift;
 #else
-	stack_base = arch_align_stack(stack_top - MAX_ARG_PAGES*PAGE_SIZE);
-	stack_base = PAGE_ALIGN(stack_base);
-	bprm->p += stack_base;
+	BUG_ON(stack_top & ~PAGE_MASK);
+
+	stack_top = arch_align_stack(stack_top);
+	stack_top = PAGE_ALIGN(stack_top);
+	stack_shift = stack_top - vma->vm_end;
+
+	bprm->p += stack_shift;
 	mm->arg_start = bprm->p;
-	arg_size = stack_top - (PAGE_MASK & (unsigned long) mm->arg_start);
 #endif
 
-	arg_size += EXTRA_STACK_VM_PAGES * PAGE_SIZE;
-
 	if (bprm->loader)
-		bprm->loader += stack_base;
-	bprm->exec += stack_base;
-
-	mpnt = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
-	if (!mpnt)
-		return -ENOMEM;
+		bprm->loader += stack_shift;
+	bprm->exec += stack_shift;
 
 	down_write(&mm->mmap_sem);
 	{
-		mpnt->vm_mm = mm;
-#ifdef CONFIG_STACK_GROWSUP
-		mpnt->vm_start = stack_base;
-		mpnt->vm_end = stack_base + arg_size;
-#else
-		mpnt->vm_end = stack_top;
-		mpnt->vm_start = mpnt->vm_end - arg_size;
-#endif
+		struct vm_area_struct *prev = NULL;
+		unsigned long vm_flags = vma->vm_flags;
+
 		/* Adjust stack execute permissions; explicitly enable
 		 * for EXSTACK_ENABLE_X, disable for EXSTACK_DISABLE_X
 		 * and leave alone (arch default) otherwise. */
 		if (unlikely(executable_stack == EXSTACK_ENABLE_X))
-			mpnt->vm_flags = VM_STACK_FLAGS |  VM_EXEC;
+			vm_flags |= VM_EXEC;
 		else if (executable_stack == EXSTACK_DISABLE_X)
-			mpnt->vm_flags = VM_STACK_FLAGS & ~VM_EXEC;
-		else
-			mpnt->vm_flags = VM_STACK_FLAGS;
-		mpnt->vm_flags |= mm->def_flags;
-		mpnt->vm_page_prot = protection_map[mpnt->vm_flags & 0x7];
-		if ((ret = insert_vm_struct(mm, mpnt))) {
+			vm_flags &= ~VM_EXEC;
+		vm_flags |= mm->def_flags;
+
+		ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end,
+				vm_flags);
+		if (ret) {
 			up_write(&mm->mmap_sem);
-			kmem_cache_free(vm_area_cachep, mpnt);
 			return ret;
 		}
-		mm->stack_vm = mm->total_vm = vma_pages(mpnt);
-	}
+		BUG_ON(prev != vma);
 
-	for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
-		struct page *page = bprm->page[i];
-		if (page) {
-			bprm->page[i] = NULL;
-			install_arg_page(mpnt, page, stack_base);
+		/* Move stack pages down in memory. */
+		if (stack_shift) {
+			ret = shift_arg_pages(vma, stack_shift);
+			if (ret) {
+				up_write(&mm->mmap_sem);
+				return ret;
+			}
+		}
+
+#ifdef CONFIG_STACK_GROWSUP
+		if (expand_stack(vma, vma->vm_end +
+					EXTRA_STACK_VM_PAGES * PAGE_SIZE)) {
+			up_write(&mm->mmap_sem);
+			return -EFAULT;
+		}
+#else
+		if (expand_stack(vma, vma->vm_start -
+					EXTRA_STACK_VM_PAGES * PAGE_SIZE)) {
+			up_write(&mm->mmap_sem);
+			return -EFAULT;
 		}
-		stack_base += PAGE_SIZE;
+#endif
 	}
 	up_write(&mm->mmap_sem);
 	
@@ -458,21 +622,6 @@ int setup_arg_pages(struct linux_binprm 
 
 EXPORT_SYMBOL(setup_arg_pages);
 
-#define free_arg_pages(bprm) do { } while (0)
-
-#else
-
-static inline void free_arg_pages(struct linux_binprm *bprm)
-{
-	int i;
-
-	for (i = 0; i < MAX_ARG_PAGES; i++) {
-		if (bprm->page[i])
-			__free_page(bprm->page[i]);
-		bprm->page[i] = NULL;
-	}
-}
-
 #endif /* CONFIG_MMU */
 
 struct file *open_exec(const char *name)
@@ -1000,44 +1149,44 @@ EXPORT_SYMBOL(compute_creds);
  * points to; chop off the first by relocating brpm->p to right after
  * the first '\0' encountered.
  */
-void remove_arg_zero(struct linux_binprm *bprm)
+int remove_arg_zero(struct linux_binprm *bprm)
 {
-	if (bprm->argc) {
-		char ch;
-
-		do {
-			unsigned long offset;
-			unsigned long index;
-			char *kaddr;
-			struct page *page;
-
-			offset = bprm->p & ~PAGE_MASK;
-			index = bprm->p >> PAGE_SHIFT;
-
-			page = bprm->page[index];
-			kaddr = kmap_atomic(page, KM_USER0);
-
-			/* run through page until we reach end or find NUL */
-			do {
-				ch = *(kaddr + offset);
-
-				/* discard that character... */
-				bprm->p++;
-				offset++;
-			} while (offset < PAGE_SIZE && ch != '\0');
-
-			kunmap_atomic(kaddr, KM_USER0);
-
-			/* free the old page */
-			if (offset == PAGE_SIZE) {
-				__free_page(page);
-				bprm->page[index] = NULL;
-			}
-		} while (ch != '\0');
+        int ret = 0;
+        unsigned long offset;
+        char *kaddr;
+        struct page *page;
+
+        if (!bprm->argc)
+                return 0;
+
+        do {
+                offset = bprm->p & ~PAGE_MASK;
+                page = get_arg_page(bprm, bprm->p, 0);
+                if (!page) {
+                        ret = -EFAULT;
+                        goto out;
+                }
+                kaddr = kmap_atomic(page, KM_USER0);
+
+                for (; offset < PAGE_SIZE && kaddr[offset];
+                                offset++, bprm->p++)
+                        ;
+
+                kunmap_atomic(kaddr, KM_USER0);
+                put_arg_page(page);
+
+                if (offset == PAGE_SIZE)
+                        free_arg_page(bprm, (bprm->p >> PAGE_SHIFT) - 1);
+        } while (offset == PAGE_SIZE);
+
+        bprm->p++;
+        bprm->argc--;
+        ret = 0;
 
-		bprm->argc--;
-	}
+out:
+        return ret;
 }
+
 EXPORT_SYMBOL(remove_arg_zero);
 
 /*
@@ -1062,7 +1211,7 @@ int search_binary_handler(struct linux_b
 		fput(bprm->file);
 		bprm->file = NULL;
 
-	        loader = PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *);
+	        loader = bprm->vma->vm_end - sizeof(void *);
 
 		file = open_exec("/sbin/loader");
 		retval = PTR_ERR(file);
@@ -1156,7 +1305,6 @@ int do_execve(char * filename,
 	struct file *file;
 	unsigned long tmp;
 	int retval;
-	int i;
 
 	retval = -ENOMEM;
 	bprm = kzalloc(sizeof(*bprm), GFP_KERNEL);
@@ -1170,25 +1318,19 @@ int do_execve(char * filename,
 
 	sched_exec();
 
-	bprm->p = PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *);
-
 	bprm->file = file;
 	bprm->filename = filename;
 	bprm->interp = filename;
-	bprm->mm = mm_alloc();
-	retval = -ENOMEM;
-	if (!bprm->mm)
-		goto out_file;
 
-	retval = init_new_context(current, bprm->mm);
-	if (retval < 0)
-		goto out_mm;
+	retval = bprm_mm_init(bprm);
+	if (retval)
+		goto out_file;
 
-	bprm->argc = count(argv, bprm->p / sizeof(void *));
+	bprm->argc = count(argv, MAX_ARG_STRINGS);
 	if ((retval = bprm->argc) < 0)
 		goto out_mm;
 
-	bprm->envc = count(envp, bprm->p / sizeof(void *));
+	bprm->envc = count(envp, MAX_ARG_STRINGS);
 	if ((retval = bprm->envc) < 0)
 		goto out_mm;
 
@@ -1217,9 +1359,8 @@ int do_execve(char * filename,
 
 	retval = search_binary_handler(bprm,regs);
 	if (retval >= 0) {
-		free_arg_pages(bprm);
-
 		/* execve success */
+		free_arg_pages(bprm);
 		security_bprm_free(bprm);
 		acct_update_integrals(current);
 		kfree(bprm);
@@ -1227,26 +1368,19 @@ int do_execve(char * filename,
 	}
 
 out:
-	/* Something went wrong, return the inode and free the argument pages*/
-	for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
-		struct page * page = bprm->page[i];
-		if (page)
-			__free_page(page);
-	}
-
+	free_arg_pages(bprm);
 	if (bprm->security)
 		security_bprm_free(bprm);
 
 out_mm:
 	if (bprm->mm)
-		mmdrop(bprm->mm);
+		mmput (bprm->mm);
 
 out_file:
 	if (bprm->file) {
 		allow_write_access(bprm->file);
 		fput(bprm->file);
 	}
-
 out_kfree:
 	kfree(bprm);
 
Index: linux-2.6-2/include/asm-um/processor-i386.h
===================================================================
--- linux-2.6-2.orig/include/asm-um/processor-i386.h	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/include/asm-um/processor-i386.h	2007-06-05 16:29:45.000000000 +0200
@@ -67,9 +67,6 @@ static inline void rep_nop(void)
 #define current_text_addr() \
 	({ void *pc; __asm__("movl $1f,%0\n1:":"=g" (pc)); pc; })
 
-#define ARCH_IS_STACKGROW(address) \
-       (address + 32 >= UPT_SP(&current->thread.regs.regs))
-
 #define KSTK_EIP(tsk) KSTK_REG(tsk, EIP)
 #define KSTK_ESP(tsk) KSTK_REG(tsk, UESP)
 #define KSTK_EBP(tsk) KSTK_REG(tsk, EBP)
Index: linux-2.6-2/include/asm-um/processor-x86_64.h
===================================================================
--- linux-2.6-2.orig/include/asm-um/processor-x86_64.h	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/include/asm-um/processor-x86_64.h	2007-06-05 16:29:45.000000000 +0200
@@ -44,9 +44,6 @@ static inline void arch_copy_thread(stru
 #define current_text_addr() \
 	({ void *pc; __asm__("movq $1f,%0\n1:":"=g" (pc)); pc; })
 
-#define ARCH_IS_STACKGROW(address) \
-        (address + 128 >= UPT_SP(&current->thread.regs.regs))
-
 #define KSTK_EIP(tsk) KSTK_REG(tsk, RIP)
 #define KSTK_ESP(tsk) KSTK_REG(tsk, RSP)
 
Index: linux-2.6-2/include/linux/binfmts.h
===================================================================
--- linux-2.6-2.orig/include/linux/binfmts.h	2007-06-05 16:29:41.000000000 +0200
+++ linux-2.6-2/include/linux/binfmts.h	2007-06-05 16:29:45.000000000 +0200
@@ -5,12 +5,9 @@
 
 struct pt_regs;
 
-/*
- * MAX_ARG_PAGES defines the number of pages allocated for arguments
- * and envelope for the new program. 32 should suffice, this gives
- * a maximum env+arg of 128kB w/4KB pages!
- */
-#define MAX_ARG_PAGES 32
+/* FIXME: Find real limits, or none. */
+#define MAX_ARG_STRLEN (PAGE_SIZE * 32)
+#define MAX_ARG_STRINGS 0x7FFFFFFF
 
 /* sizeof(linux_binprm->buf) */
 #define BINPRM_BUF_SIZE 128
@@ -24,7 +21,12 @@ struct pt_regs;
  */
 struct linux_binprm{
 	char buf[BINPRM_BUF_SIZE];
+#ifdef CONFIG_MMU
+	struct vm_area_struct *vma;
+#else
+# define MAX_ARG_PAGES	32
 	struct page *page[MAX_ARG_PAGES];
+#endif
 	struct mm_struct *mm;
 	unsigned long p; /* current top of mem */
 	int sh_bang;
@@ -69,7 +71,7 @@ extern int register_binfmt(struct linux_
 extern int unregister_binfmt(struct linux_binfmt *);
 
 extern int prepare_binprm(struct linux_binprm *);
-extern void remove_arg_zero(struct linux_binprm *);
+extern int __must_check remove_arg_zero(struct linux_binprm *);
 extern int search_binary_handler(struct linux_binprm *,struct pt_regs *);
 extern int flush_old_exec(struct linux_binprm * bprm);
 
@@ -86,6 +88,7 @@ extern int suid_dumpable;
 extern int setup_arg_pages(struct linux_binprm * bprm,
 			   unsigned long stack_top,
 			   int executable_stack);
+extern int bprm_mm_init(struct linux_binprm *bprm);
 extern int copy_strings_kernel(int argc,char ** argv,struct linux_binprm *bprm);
 extern void compute_creds(struct linux_binprm *binprm);
 extern int do_coredump(long signr, int exit_code, struct pt_regs * regs);
Index: linux-2.6-2/include/linux/mm.h
===================================================================
--- linux-2.6-2.orig/include/linux/mm.h	2007-06-05 16:29:43.000000000 +0200
+++ linux-2.6-2/include/linux/mm.h	2007-06-05 16:29:45.000000000 +0200
@@ -786,7 +786,6 @@ static inline int handle_mm_fault(struct
 
 extern int make_pages_present(unsigned long addr, unsigned long end);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
-void install_arg_page(struct vm_area_struct *, struct page *, unsigned long);
 
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm, unsigned long start,
 		int len, int write, int force, struct page **pages, struct vm_area_struct **vmas);
@@ -812,6 +811,9 @@ extern unsigned long move_page_tables_up
 extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long old_len, unsigned long new_len,
 			       unsigned long flags, unsigned long new_addr);
+extern int mprotect_fixup(struct vm_area_struct *vma,
+			  struct vm_area_struct **pprev, unsigned long start,
+			  unsigned long end, unsigned long newflags);
 
 /*
  * Prototype to add a shrinker callback for ageable caches.
@@ -1130,6 +1132,9 @@ extern int expand_stack(struct vm_area_s
 #ifdef CONFIG_IA64
 extern int expand_upwards(struct vm_area_struct *vma, unsigned long address);
 #endif
+#ifdef CONFIG_STACK_GROWSUP
+extern int expand_downwards(struct vm_area_struct *vma, unsigned long address);
+#endif
 
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
 extern struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr);
Index: linux-2.6-2/mm/mmap.c
===================================================================
--- linux-2.6-2.orig/mm/mmap.c	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/mm/mmap.c	2007-06-05 16:29:45.000000000 +0200
@@ -1557,33 +1557,13 @@ int expand_upwards(struct vm_area_struct
 }
 #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
 
-#ifdef CONFIG_STACK_GROWSUP
-int expand_stack(struct vm_area_struct *vma, unsigned long address)
-{
-	return expand_upwards(vma, address);
-}
-
-struct vm_area_struct *
-find_extend_vma(struct mm_struct *mm, unsigned long addr)
-{
-	struct vm_area_struct *vma, *prev;
-
-	addr &= PAGE_MASK;
-	vma = find_vma_prev(mm, addr, &prev);
-	if (vma && (vma->vm_start <= addr))
-		return vma;
-	if (!prev || expand_stack(prev, addr))
-		return NULL;
-	if (prev->vm_flags & VM_LOCKED) {
-		make_pages_present(addr, prev->vm_end);
-	}
-	return prev;
-}
-#else
 /*
  * vma is the first one with address < vma->vm_start.  Have to extend vma.
  */
-int expand_stack(struct vm_area_struct *vma, unsigned long address)
+#ifndef CONFIG_STACK_GROWSUP
+static inline
+#endif
+int expand_downwards(struct vm_area_struct *vma, unsigned long address)
 {
 	int error;
 
@@ -1620,6 +1600,34 @@ int expand_stack(struct vm_area_struct *
 	return error;
 }
 
+#ifdef CONFIG_STACK_GROWSUP
+int expand_stack(struct vm_area_struct *vma, unsigned long address)
+{
+	return expand_upwards(vma, address);
+}
+
+struct vm_area_struct *
+find_extend_vma(struct mm_struct *mm, unsigned long addr)
+{
+	struct vm_area_struct *vma, *prev;
+
+	addr &= PAGE_MASK;
+	vma = find_vma_prev(mm, addr, &prev);
+	if (vma && (vma->vm_start <= addr))
+		return vma;
+	if (!prev || expand_stack(prev, addr))
+		return NULL;
+	if (prev->vm_flags & VM_LOCKED) {
+		make_pages_present(addr, prev->vm_end);
+	}
+	return prev;
+}
+#else
+int expand_stack(struct vm_area_struct *vma, unsigned long address)
+{
+	return expand_downwards(vma, address);
+}
+
 struct vm_area_struct *
 find_extend_vma(struct mm_struct * mm, unsigned long addr)
 {
Index: linux-2.6-2/mm/mprotect.c
===================================================================
--- linux-2.6-2.orig/mm/mprotect.c	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/mm/mprotect.c	2007-06-05 16:29:45.000000000 +0200
@@ -128,7 +128,7 @@ static void change_protection(struct vm_
 	flush_tlb_range(vma, start, end);
 }
 
-static int
+int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	unsigned long start, unsigned long end, unsigned long newflags)
 {
Index: linux-2.6-2/arch/ia64/ia32/binfmt_elf32.c
===================================================================
--- linux-2.6-2.orig/arch/ia64/ia32/binfmt_elf32.c	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/arch/ia64/ia32/binfmt_elf32.c	2007-06-05 16:29:45.000000000 +0200
@@ -195,62 +195,23 @@ ia64_elf32_init (struct pt_regs *regs)
 	ia32_load_state(current);
 }
 
+#undef setup_arg_pages
+
 int
 ia32_setup_arg_pages (struct linux_binprm *bprm, int executable_stack)
 {
-	unsigned long stack_base;
-	struct vm_area_struct *mpnt;
-	struct mm_struct *mm = current->mm;
-	int i, ret;
-
-	stack_base = IA32_STACK_TOP - MAX_ARG_PAGES*PAGE_SIZE;
-	mm->arg_start = bprm->p + stack_base;
-
-	bprm->p += stack_base;
-	if (bprm->loader)
-		bprm->loader += stack_base;
-	bprm->exec += stack_base;
-
-	mpnt = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
-	if (!mpnt)
-		return -ENOMEM;
-
-	down_write(&current->mm->mmap_sem);
-	{
-		mpnt->vm_mm = current->mm;
-		mpnt->vm_start = PAGE_MASK & (unsigned long) bprm->p;
-		mpnt->vm_end = IA32_STACK_TOP;
-		if (executable_stack == EXSTACK_ENABLE_X)
-			mpnt->vm_flags = VM_STACK_FLAGS |  VM_EXEC;
-		else if (executable_stack == EXSTACK_DISABLE_X)
-			mpnt->vm_flags = VM_STACK_FLAGS & ~VM_EXEC;
-		else
-			mpnt->vm_flags = VM_STACK_FLAGS;
-		mpnt->vm_page_prot = (mpnt->vm_flags & VM_EXEC)?
-					PAGE_COPY_EXEC: PAGE_COPY;
-		if ((ret = insert_vm_struct(current->mm, mpnt))) {
-			up_write(&current->mm->mmap_sem);
-			kmem_cache_free(vm_area_cachep, mpnt);
-			return ret;
-		}
-		current->mm->stack_vm = current->mm->total_vm = vma_pages(mpnt);
-	}
+	int ret;
 
-	for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
-		struct page *page = bprm->page[i];
-		if (page) {
-			bprm->page[i] = NULL;
-			install_arg_page(mpnt, page, stack_base);
-		}
-		stack_base += PAGE_SIZE;
+	ret = setup_arg_pages(bprm, IA32_STACK_TOP, executable_stack);
+	if (!ret) {
+		/*
+		 * Can't do it in ia64_elf32_init(). Needs to be done before
+		 * calls to elf32_map()
+		 */
+		current->thread.ppl = ia32_init_pp_list();
 	}
-	up_write(&current->mm->mmap_sem);
 
-	/* Can't do it in ia64_elf32_init(). Needs to be done before calls to
-	   elf32_map() */
-	current->thread.ppl = ia32_init_pp_list();
-
-	return 0;
+	return ret;
 }
 
 static void
Index: linux-2.6-2/arch/x86_64/ia32/ia32_aout.c
===================================================================
--- linux-2.6-2.orig/arch/x86_64/ia32/ia32_aout.c	2007-06-05 16:23:16.000000000 +0200
+++ linux-2.6-2/arch/x86_64/ia32/ia32_aout.c	2007-06-05 16:29:45.000000000 +0200
@@ -404,7 +404,7 @@ beyond_if:
 
 	set_brk(current->mm->start_brk, current->mm->brk);
 
-	retval = ia32_setup_arg_pages(bprm, IA32_STACK_TOP, EXSTACK_DEFAULT);
+	retval = setup_arg_pages(bprm, IA32_STACK_TOP, EXSTACK_DEFAULT);
 	if (retval < 0) { 
 		/* Someone check-me: is this error path enough? */ 
 		send_sig(SIGKILL, current, 0); 
Index: linux-2.6-2/kernel/auditsc.c
===================================================================
--- linux-2.6-2.orig/kernel/auditsc.c	2007-06-05 16:29:41.000000000 +0200
+++ linux-2.6-2/kernel/auditsc.c	2007-06-05 16:31:28.000000000 +0200
@@ -848,7 +848,7 @@ static void audit_log_execve_info(struct
 		long ret;
 		char *tmp;
 
-		len = strnlen_user(p, MAX_ARG_PAGES*PAGE_SIZE);
+		len = strnlen_user(p, MAX_ARG_STRLEN);
 		/*
 		 * We just created this mm, if we can't find the strings
 		 * we just copied in something is _very_ wrong.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
