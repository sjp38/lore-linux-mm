Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6SJHMc3000597
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 15:17:22 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6SJHMPZ232398
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 15:17:22 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6SJHMOh032719
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 15:17:22 -0400
From: Eric Munson <ebmunson@us.ibm.com>
Subject: [PATCH 4/5 V2] Build hugetlb backed process stacks
Date: Mon, 28 Jul 2008 12:17:14 -0700
Message-Id: <34bf5c7a2116bc6bd16b4235bc1cf84395ee561e.1216928613.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1216928613.git.ebmunson@us.ibm.com>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1216928613.git.ebmunson@us.ibm.com>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, Eric Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch allows a processes stack to be backed by huge pages on request.
The personality flag defined in a previous patch should be set before
exec is called for the target process to use a huge page backed stack.

When the hugetlb file is setup to back the stack it is sized to fit the
ulimit for stack size or 256 MB if ulimit is unlimited.  The GROWSUP and
GROWSDOWN VM flags are turned off because a hugetlb backed vma is not
resizable so it will be appropriately sized when created.  When a process
exceeds stack size it recieves a segfault as it would if it exceeded the
ulimit.

Also certain architectures require special setup for a memory region before
huge pages can be used in that region.  This patch defines a function with
__attribute__ ((weak)) set that can be defined by these architectures to
do any necessary setup.  If it exists, it will be called right before the
hugetlb file is mmapped.

Signed-off-by: Eric Munson <ebmunson@us.ibm.com>

---
Based on 2.6.26-rc8-mm1

Changes from V1:
Add comment about not padding huge stacks
Break personality_page_align helper and personality flag into separate patch
Add move_to_huge_pages function that moves the stack onto huge pages
Add hugetlb_mm_setup weak function for archs that require special setup to
 use hugetlb pages
Rebase to 2.6.26-rc8-mm1

 fs/exec.c               |  194 ++++++++++++++++++++++++++++++++++++++++++++---
 include/linux/hugetlb.h |    5 +
 2 files changed, 187 insertions(+), 12 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index c99ba24..bf9ead2 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -50,6 +50,7 @@
 #include <linux/cn_proc.h>
 #include <linux/audit.h>
 #include <linux/hugetlb.h>
+#include <linux/mman.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -59,6 +60,8 @@
 #include <linux/kmod.h>
 #endif
 
+#define HUGE_STACK_MAX (256*1024*1024)
+
 #ifdef __alpha__
 /* for /sbin/loader handling in search_binary_handler() */
 #include <linux/a.out.h>
@@ -189,7 +192,12 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 		return NULL;
 
 	if (write) {
-		unsigned long size = bprm->vma->vm_end - bprm->vma->vm_start;
+		/*
+		 * Args are always placed at the high end of the stack space
+		 * so this calculation will give the proper size and it is
+		 * compatible with huge page stacks.
+		 */
+		unsigned long size = bprm->vma->vm_end - pos;
 		struct rlimit *rlim;
 
 		/*
@@ -255,7 +263,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	 * configured yet.
 	 */
 	vma->vm_end = STACK_TOP_MAX;
-	vma->vm_start = vma->vm_end - PAGE_SIZE;
+	if (current->personality & HUGETLB_STACK)
+		vma->vm_start = vma->vm_end - HPAGE_SIZE;
+	else
+		vma->vm_start = vma->vm_end - PAGE_SIZE;
 
 	vma->vm_flags = VM_STACK_FLAGS;
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
@@ -574,6 +585,156 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 	return 0;
 }
 
+static struct file *hugetlb_stack_file(int stack_hpages)
+{
+	struct file *hugefile = NULL;
+
+	if (!stack_hpages) {
+		set_personality(current->personality & (~HUGETLB_STACK));
+		printk(KERN_DEBUG
+			"Stack rlimit set too low for huge page backed stack.\n");
+		return NULL;
+	}
+
+	hugefile = hugetlb_file_setup(HUGETLB_STACK_FILE,
+					HPAGE_SIZE * stack_hpages,
+					HUGETLB_PRIVATE_INODE);
+	if (unlikely(IS_ERR(hugefile))) {
+		/*
+		 * If huge pages are not available for this stack fall
+		 * fall back to normal pages for execution instead of
+		 * failing.
+		 */
+		printk(KERN_DEBUG
+			"Huge page backed stack unavailable for process %lu.\n",
+			(unsigned long)current->pid);
+		set_personality(current->personality & (~HUGETLB_STACK));
+		return NULL;
+	}
+	return hugefile;
+}
+
+static int move_to_huge_pages(struct linux_binprm *bprm,
+				struct vm_area_struct *vma, unsigned long shift)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct vm_area_struct *new_vma;
+	unsigned long old_end = vma->vm_end;
+	unsigned long old_start = vma->vm_start;
+	unsigned long new_end = old_end - shift;
+	unsigned long new_start, length;
+	unsigned long arg_size = new_end - bprm->p;
+	unsigned long flags = vma->vm_flags;
+	struct file *hugefile = NULL;
+	unsigned int stack_hpages = 0;
+	struct page **from_pages = NULL;
+	struct page **to_pages = NULL;
+	unsigned long num_pages = (arg_size / PAGE_SIZE) + 1;
+	int ret;
+	int i;
+
+#ifdef CONFIG_STACK_GROWSUP
+	/*
+	 * Huge page stacks are not currently supported on GROWSUP
+	 * archs.
+	 */
+	set_personality(current->personality & (~HUGETLB_STACK));
+#else
+	if (current->signal->rlim[RLIMIT_STACK].rlim_cur == _STK_LIM_MAX)
+		stack_hpages = HUGE_STACK_MAX / HPAGE_SIZE;
+	else
+		stack_hpages = current->signal->rlim[RLIMIT_STACK].rlim_cur /
+				HPAGE_SIZE;
+	hugefile = hugetlb_stack_file(stack_hpages);
+	if (!hugefile)
+		goto out_small_stack;
+
+	length = stack_hpages * HPAGE_SIZE;
+	new_start = new_end - length;
+
+	from_pages = kmalloc(num_pages * sizeof(struct page*), GFP_KERNEL);
+	to_pages = kmalloc(num_pages * sizeof(struct page*), GFP_KERNEL);
+	if (!from_pages || !to_pages)
+		goto out_small_stack;
+
+	ret = get_user_pages(current, mm, (old_end - arg_size) & PAGE_MASK,
+				num_pages, 0, 0, from_pages, NULL);
+	if (ret <= 0)
+		goto out_small_stack;
+
+	/*
+	 * __do_munmap is used here because the boundary checking done in
+	 * do_munmap will fail out every time where the kernel is 64 bit and the
+	 * target program is 32 bit as the stack will start at TASK_SIZE for the
+	 * 64 bit address space.
+	 */
+	ret = __do_munmap(mm, old_start, old_end - old_start);
+	if (ret)
+		goto out_small_stack;
+
+	ret = -EINVAL;
+	if (hugetlb_mm_setup)
+		hugetlb_mm_setup(mm, new_start, length);
+	if (IS_ERR_VALUE(do_mmap(hugefile, new_start, length,
+			PROT_READ | PROT_WRITE, MAP_FIXED | MAP_PRIVATE, 0)))
+		goto out_error;
+	/* We don't want to fput this if the mmap succeeded */
+	hugefile = NULL;
+
+	ret = get_user_pages(current, mm, (new_end - arg_size) & PAGE_MASK,
+				num_pages, 0, 0, to_pages, NULL);
+	if (ret <= 0) {
+		ret = -ENOMEM;
+		goto out_error;
+	}
+
+	for (i = 0; i < num_pages; i++) {
+		char *vfrom, *vto;
+		vfrom = kmap(from_pages[i]);
+		vto = kmap(to_pages[i]);
+		memcpy(vto, vfrom, PAGE_SIZE);
+		kunmap(from_pages[i]);
+		kunmap(to_pages[i]);
+		put_page(from_pages[i]);
+		put_page(to_pages[i]);
+	}
+
+	kfree(from_pages);
+	kfree(to_pages);
+	new_vma = find_vma(current->mm, new_start);
+	if (!new_vma)
+		return -ENOSPC;
+	new_vma->vm_flags |= flags;
+	new_vma->vm_flags &= ~(VM_GROWSUP|VM_GROWSDOWN);
+	new_vma->vm_page_prot = vm_get_page_prot(new_vma->vm_flags);
+
+	bprm->vma = new_vma;
+	return 0;
+
+out_error:
+	for (i = 0; i < num_pages; i++)
+		put_page(from_pages[i]);
+	if (hugefile)
+		fput(hugefile);
+	if (from_pages)
+		kfree(from_pages);
+	if (to_pages)
+		kfree(to_pages);
+	return ret;
+
+out_small_stack:
+	if (hugefile)
+		fput(hugefile);
+	if (from_pages)
+		kfree(from_pages);
+	if (to_pages)
+		kfree(to_pages);
+#endif /* !CONFIG_STACK_GROWSUP */
+	if (shift)
+		return shift_arg_pages(vma, shift);
+	return 0;
+}
+
 #define EXTRA_STACK_VM_PAGES	20	/* random */
 
 /*
@@ -640,23 +801,32 @@ int setup_arg_pages(struct linux_binprm *bprm,
 		goto out_unlock;
 	BUG_ON(prev != vma);
 
+	/* Move stack to hugetlb pages if requested */
+	if (current->personality & HUGETLB_STACK)
+		ret = move_to_huge_pages(bprm, vma, stack_shift);
 	/* Move stack pages down in memory. */
-	if (stack_shift) {
+	else if (stack_shift)
 		ret = shift_arg_pages(vma, stack_shift);
-		if (ret) {
-			up_write(&mm->mmap_sem);
-			return ret;
-		}
+
+	if (ret) {
+		up_write(&mm->mmap_sem);
+		return ret;
 	}
 
+	/*
+	 * Stack padding code is skipped for huge stacks because the vma
+	 * is not expandable when backed by a hugetlb file.
+	 */
+	if (!(current->personality & HUGETLB_STACK)) {
 #ifdef CONFIG_STACK_GROWSUP
-	stack_base = vma->vm_end + EXTRA_STACK_VM_PAGES * PAGE_SIZE;
+		stack_base = vma->vm_end + EXTRA_STACK_VM_PAGES * PAGE_SIZE;
 #else
-	stack_base = vma->vm_start - EXTRA_STACK_VM_PAGES * PAGE_SIZE;
+		stack_base = vma->vm_start - EXTRA_STACK_VM_PAGES * PAGE_SIZE;
 #endif
-	ret = expand_stack(vma, stack_base);
-	if (ret)
-		ret = -EFAULT;
+		ret = expand_stack(vma, stack_base);
+		if (ret)
+			ret = -EFAULT;
+	}
 
 out_unlock:
 	up_write(&mm->mmap_sem);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 26ffed9..b4c88bb 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -110,6 +110,11 @@ static inline unsigned long hugetlb_total_pages(void)
 #define HUGETLB_RESERVE	0x00000002UL	/* Reserve the huge pages backed by the
 					 * new file */
 
+#define HUGETLB_STACK_FILE "hugetlb-stack"
+
+extern void hugetlb_mm_setup(struct mm_struct *mm, unsigned long addr,
+				unsigned long len) __attribute__ ((weak));
+
 #ifdef CONFIG_HUGETLBFS
 struct hugetlbfs_config {
 	uid_t   uid;
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
