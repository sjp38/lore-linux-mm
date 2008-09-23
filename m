Date: Tue, 23 Sep 2008 15:47:52 -0700
Subject: Re: mlock: Make the mlock system call interruptible by fatal
Message-ID: <20080923224751.GA2790@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: sqazi@google.com (Salman Qazi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Andrew Morton wrote:
>
>This isn't a terribly good interface.  Someone could now call
> __get_user_pages() with pages!=NULL and interruptible=1 and they would
> get a return value of -EINTR, even though some page*'s were placed in
> their pages array.
>
> That caller now has no way of knowing how many pages need to be
> released to clean up.
>
> Can we do
>
>        return i ? i : -EINTR;
>
> in the usual fashion?

Fixed.


Make the mlock system call interruptible by fatal signals, so that programs
that are mlocking a large number of pages terminate quickly when killed.

Signed-off-by: Salman Qazi <sqazi@google.com>
---

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 72a15dc..a2531e6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -807,7 +807,8 @@ static inline int handle_mm_fault(struct mm_struct *mm,
 }
 #endif
 
-extern int make_pages_present(unsigned long addr, unsigned long end);
+extern int make_pages_present(unsigned long addr, unsigned long end,
+			int interruptible);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
 
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm, unsigned long start,
diff --git a/mm/fremap.c b/mm/fremap.c
index 7881638..f5eff74 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -223,7 +223,7 @@ asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 			downgrade_write(&mm->mmap_sem);
 			has_write_lock = 0;
 		}
-		make_pages_present(start, start+size);
+		make_pages_present(start, start+size, 0);
 	}
 
 	/*
diff --git a/mm/memory.c b/mm/memory.c
index 1002f47..f6f8742 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1129,9 +1129,10 @@ static inline int use_zero_page(struct vm_area_struct *vma)
 	return !vma->vm_ops || !vma->vm_ops->fault;
 }
 
-int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, int len, int write, int force,
-		struct page **pages, struct vm_area_struct **vmas)
+static int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+			unsigned long start, int len, int write, int force,
+			struct page **pages, struct vm_area_struct **vmas,
+			int interruptible)
 {
 	int i;
 	unsigned int vm_flags;
@@ -1223,6 +1224,8 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			cond_resched();
 			while (!(page = follow_page(vma, start, foll_flags))) {
 				int ret;
+				if (interruptible && fatal_signal_pending(tsk))
+					return i ? i : -EINTR;
 				ret = handle_mm_fault(mm, vma, start,
 						foll_flags & FOLL_WRITE);
 				if (ret & VM_FAULT_ERROR) {
@@ -1266,6 +1269,14 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	} while (len);
 	return i;
 }
+
+int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, int len, int write, int force,
+		struct page **pages, struct vm_area_struct **vmas)
+{
+	return __get_user_pages(tsk, mm, start, len, write, force,
+				pages, vmas, 0);
+}
 EXPORT_SYMBOL(get_user_pages);
 
 pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
@@ -2758,7 +2769,7 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 }
 #endif /* __PAGETABLE_PMD_FOLDED */
 
-int make_pages_present(unsigned long addr, unsigned long end)
+int make_pages_present(unsigned long addr, unsigned long end, int interruptible)
 {
 	int ret, len, write;
 	struct vm_area_struct * vma;
@@ -2770,8 +2781,8 @@ int make_pages_present(unsigned long addr, unsigned long end)
 	BUG_ON(addr >= end);
 	BUG_ON(end > vma->vm_end);
 	len = DIV_ROUND_UP(end, PAGE_SIZE) - addr/PAGE_SIZE;
-	ret = get_user_pages(current, current->mm, addr,
-			len, write, 0, NULL, NULL);
+	ret = __get_user_pages(current, current->mm, addr,
+			len, write, 0, NULL, NULL, interruptible);
 	if (ret < 0) {
 		/*
 		   SUS require strange return value to mlock
diff --git a/mm/mlock.c b/mm/mlock.c
index 01fbe93..5586ee4 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -73,7 +73,7 @@ success:
 	if (newflags & VM_LOCKED) {
 		pages = -pages;
 		if (!(newflags & VM_IO))
-			ret = make_pages_present(start, end);
+			ret = make_pages_present(start, end, 1);
 	}
 
 	mm->locked_vm -= pages;
diff --git a/mm/mmap.c b/mm/mmap.c
index e7a5a68..afb8e39 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1225,10 +1225,10 @@ out:
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		make_pages_present(addr, addr + len, 0);
 	}
 	if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
-		make_pages_present(addr, addr + len);
+		make_pages_present(addr, addr + len, 0);
 	return addr;
 
 unmap_and_free_vma:
@@ -1701,7 +1701,7 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	if (!prev || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED)
-		make_pages_present(addr, prev->vm_end);
+		make_pages_present(addr, prev->vm_end, 0);
 	return prev;
 }
 #else
@@ -1728,7 +1728,7 @@ find_extend_vma(struct mm_struct * mm, unsigned long addr)
 	if (expand_stack(vma, addr))
 		return NULL;
 	if (vma->vm_flags & VM_LOCKED)
-		make_pages_present(addr, start);
+		make_pages_present(addr, start, 0);
 	return vma;
 }
 #endif
@@ -2049,7 +2049,7 @@ out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		make_pages_present(addr, addr + len, 0);
 	}
 	return addr;
 }
diff --git a/mm/mremap.c b/mm/mremap.c
index 1a77439..c83ffcc 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -239,7 +239,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		mm->locked_vm += new_len >> PAGE_SHIFT;
 		if (new_len > old_len)
 			make_pages_present(new_addr + old_len,
-					   new_addr + new_len);
+					   new_addr + new_len, 0);
 	}
 
 	return new_addr;
@@ -380,7 +380,7 @@ unsigned long do_mremap(unsigned long addr,
 			if (vma->vm_flags & VM_LOCKED) {
 				mm->locked_vm += pages;
 				make_pages_present(addr + old_len,
-						   addr + new_len);
+						   addr + new_len, 0);
 			}
 			ret = addr;
 			goto out;

---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
