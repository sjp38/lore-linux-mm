Subject: Re: [PATCH 4/4] mm: variable length argument support
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070606020651.19a89dca.akpm@linux-foundation.org>
References: <20070605150523.786600000@chello.nl>
	 <20070605151203.790585000@chello.nl>
	 <20070606013658.20bcbe2f.akpm@linux-foundation.org>
	 <1181120061.7348.177.camel@twins>
	 <20070606020651.19a89dca.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 06 Jun 2007 11:34:33 +0200
Message-Id: <1181122473.7348.188.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-06 at 02:06 -0700, Andrew Morton wrote:

> I think the same problem will happen on NOMMU && STACK_GROWS_UP.  There are
> several new references to bprm->vma in there, not all inside CONFIG_MMU.

I found two: one in setup_arg_pages() and one in get_arg_page() both are
under CONFIG_MMU.

---
fix a no-MMU compile error on flush_cache_page() and clean up the no-MMU
code a bit by placing more #ifdef CONFIG_MMU stuff into their own
function.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/exec.c |  112 +++++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 68 insertions(+), 44 deletions(-)

Index: linux-2.6-2/fs/exec.c
===================================================================
--- linux-2.6-2.orig/fs/exec.c	2007-06-05 16:48:52.000000000 +0200
+++ linux-2.6-2/fs/exec.c	2007-06-06 11:21:35.000000000 +0200
@@ -215,6 +215,58 @@ static void free_arg_pages(struct linux_
 {
 }
 
+static void flush_arg_page(struct linux_binprm *bprm, unsigned long pos,
+		struct page *page)
+{
+	flush_cache_page(bprm->vma, pos, page_to_pfn(page));
+}
+
+static int __bprm_mm_init(struct linux_binprm *bprm)
+{
+	int err = -ENOMEM;
+	struct vm_area_struct *vma = NULL;
+	struct mm_struct *mm = bprm->mm;
+
+	bprm->vma = vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (!vma)
+		goto err;
+
+	down_write(&mm->mmap_sem);
+	vma->vm_mm = mm;
+
+	/*
+	 * Place the stack at the top of user memory.  Later, we'll
+	 * move this to an appropriate place.  We don't use STACK_TOP
+	 * because that can depend on attributes which aren't
+	 * configured yet.
+	 */
+	vma->vm_end = STACK_TOP_MAX;
+	vma->vm_start = vma->vm_end - PAGE_SIZE;
+
+	vma->vm_flags = VM_STACK_FLAGS;
+	vma->vm_page_prot = protection_map[vma->vm_flags & 0x7];
+	err = insert_vm_struct(mm, vma);
+	if (err) {
+		up_write(&mm->mmap_sem);
+		goto err;
+	}
+
+	mm->stack_vm = mm->total_vm = 1;
+	up_write(&mm->mmap_sem);
+
+	bprm->p = vma->vm_end - sizeof(void *);
+
+	return 0;
+
+err:
+	if (vma) {
+		bprm->vma = NULL;
+		kmem_cache_free(vm_area_cachep, vma);
+	}
+
+	return err;
+}
+
 #else
 
 static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
@@ -253,6 +305,17 @@ static void free_arg_pages(struct linux_
 		free_arg_page(bprm, i);
 }
 
+static void flush_arg_page(struct linux_binprm *bprm, unsigned long pos,
+		struct page *page)
+{
+}
+
+static int __bprm_mm_init(struct linux_binprm *bprm)
+{
+	bprm->p = PAGE_SIZE * MAX_ARG_PAGES - sizeof(void *);
+	return 0;
+}
+
 #endif /* CONFIG_MMU */
 
 /*
@@ -265,61 +328,23 @@ int bprm_mm_init(struct linux_binprm *bp
 {
 	int err;
 	struct mm_struct *mm = NULL;
-	struct vm_area_struct *vma = NULL;
 
 	bprm->mm = mm = mm_alloc();
 	err = -ENOMEM;
 	if (!mm)
 		goto err;
 
-	if ((err = init_new_context(current, mm)))
+	err = init_new_context(current, mm);
+	if (err)
 		goto err;
 
-#ifdef CONFIG_MMU
-	bprm->vma = vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
-	err = -ENOMEM;
-	if (!vma)
+	err = __bprm_mm_init(bprm);
+	if (err)
 		goto err;
 
-	down_write(&mm->mmap_sem);
-	{
-		vma->vm_mm = mm;
-
-		/*
-		 * Place the stack at the top of user memory.  Later, we'll
-		 * move this to an appropriate place.  We don't use STACK_TOP
-		 * because that can depend on attributes which aren't
-		 * configured yet.
-		 */
-		vma->vm_end = STACK_TOP_MAX;
-		vma->vm_start = vma->vm_end - PAGE_SIZE;
-
-		vma->vm_flags = VM_STACK_FLAGS;
-		vma->vm_page_prot = protection_map[vma->vm_flags & 0x7];
-		if ((err = insert_vm_struct(mm, vma))) {
-			up_write(&mm->mmap_sem);
-			goto err;
-		}
-
-		mm->stack_vm = mm->total_vm = 1;
-	}
-	up_write(&mm->mmap_sem);
-
-	bprm->p = vma->vm_end - sizeof(void *);
-#else
-	bprm->p = PAGE_SIZE * MAX_ARG_PAGES - sizeof(void *);
-#endif
-
 	return 0;
 
 err:
-#ifdef CONFIG_MMU
-	if (vma) {
-		bprm->vma = NULL;
-		kmem_cache_free(vm_area_cachep, vma);
-	}
-#endif
-
 	if (mm) {
 		bprm->mm = NULL;
 		mmdrop(mm);
@@ -428,8 +453,7 @@ static int copy_strings(int argc, char _
 				kmapped_page = page;
 				kaddr = kmap(kmapped_page);
 				kpos = pos & PAGE_MASK;
-				flush_cache_page(bprm->vma, kpos,
-						 page_to_pfn(kmapped_page));
+				flush_arg_page(bprm, kpos, kmapped_page);
 			}
 			if (copy_from_user(kaddr+offset, str, bytes_to_copy)) {
 				ret = -EFAULT;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
