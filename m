Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4166B0280
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:27 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v17so18514276pgb.18
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r10si1894371pff.316.2018.02.04.17.28.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:07 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 54/64] arch/arm: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:44 +0100
Message-Id: <20180205012754.23615-55-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This becomes quite straightforward with the mmrange in place.
For those mmap_sem users that need mmrange, we simply add it
to the function as the mmap_sem usage is in the same context.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/arm/kernel/process.c          |  5 +++--
 arch/arm/kernel/swp_emulate.c      |  5 +++--
 arch/arm/lib/uaccess_with_memcpy.c | 18 ++++++++++--------
 arch/arm/mm/fault.c                |  6 +++---
 arch/arm64/kernel/traps.c          |  5 +++--
 arch/arm64/kernel/vdso.c           | 12 +++++++-----
 arch/arm64/mm/fault.c              |  6 +++---
 7 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index 1523cb18b109..39fd5bd204d7 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -424,6 +424,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	unsigned long addr;
 	unsigned long hint;
 	int ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!signal_page)
 		signal_page = get_signal_page();
@@ -433,7 +434,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	npages = 1; /* for sigpage */
 	npages += vdso_total_pages;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 	hint = sigpage_addr(mm, npages);
 	addr = get_unmapped_area(NULL, hint, npages << PAGE_SHIFT, 0, 0);
@@ -460,7 +461,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	arm_install_vdso(mm, addr + PAGE_SIZE);
 
  up_fail:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
 #endif
diff --git a/arch/arm/kernel/swp_emulate.c b/arch/arm/kernel/swp_emulate.c
index 3bda08bee674..e01a469393fb 100644
--- a/arch/arm/kernel/swp_emulate.c
+++ b/arch/arm/kernel/swp_emulate.c
@@ -111,13 +111,14 @@ static const struct file_operations proc_status_fops = {
 static void set_segfault(struct pt_regs *regs, unsigned long addr)
 {
 	siginfo_t info;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	if (find_vma(current->mm, addr) == NULL)
 		info.si_code = SEGV_MAPERR;
 	else
 		info.si_code = SEGV_ACCERR;
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	info.si_signo = SIGSEGV;
 	info.si_errno = 0;
diff --git a/arch/arm/lib/uaccess_with_memcpy.c b/arch/arm/lib/uaccess_with_memcpy.c
index 9b4ed1728616..24464fa0a78a 100644
--- a/arch/arm/lib/uaccess_with_memcpy.c
+++ b/arch/arm/lib/uaccess_with_memcpy.c
@@ -89,6 +89,7 @@ __copy_to_user_memcpy(void __user *to, const void *from, unsigned long n)
 {
 	unsigned long ua_flags;
 	int atomic;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (uaccess_kernel()) {
 		memcpy((void *)to, from, n);
@@ -99,7 +100,7 @@ __copy_to_user_memcpy(void __user *to, const void *from, unsigned long n)
 	atomic = faulthandler_disabled();
 
 	if (!atomic)
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 	while (n) {
 		pte_t *pte;
 		spinlock_t *ptl;
@@ -107,11 +108,11 @@ __copy_to_user_memcpy(void __user *to, const void *from, unsigned long n)
 
 		while (!pin_page_for_write(to, &pte, &ptl)) {
 			if (!atomic)
-				up_read(&current->mm->mmap_sem);
+				mm_read_unlock(current->mm, &mmrange);
 			if (__put_user(0, (char __user *)to))
 				goto out;
 			if (!atomic)
-				down_read(&current->mm->mmap_sem);
+				mm_read_lock(current->mm, &mmrange);
 		}
 
 		tocopy = (~(unsigned long)to & ~PAGE_MASK) + 1;
@@ -131,7 +132,7 @@ __copy_to_user_memcpy(void __user *to, const void *from, unsigned long n)
 			spin_unlock(ptl);
 	}
 	if (!atomic)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 
 out:
 	return n;
@@ -161,23 +162,24 @@ static unsigned long noinline
 __clear_user_memset(void __user *addr, unsigned long n)
 {
 	unsigned long ua_flags;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (uaccess_kernel()) {
 		memset((void *)addr, 0, n);
 		return 0;
 	}
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	while (n) {
 		pte_t *pte;
 		spinlock_t *ptl;
 		int tocopy;
 
 		while (!pin_page_for_write(addr, &pte, &ptl)) {
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm, &mmrange);
 			if (__put_user(0, (char __user *)addr))
 				goto out;
-			down_read(&current->mm->mmap_sem);
+			mm_read_lock(current->mm, &mmrange);
 		}
 
 		tocopy = (~(unsigned long)addr & ~PAGE_MASK) + 1;
@@ -195,7 +197,7 @@ __clear_user_memset(void __user *addr, unsigned long n)
 		else
 			spin_unlock(ptl);
 	}
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 out:
 	return n;
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 99ae40b5851a..6ce3e0707db5 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -291,11 +291,11 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	 * validly references user space from well defined areas of the code,
 	 * we can bug out early if this is from code which shouldn't.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &mmrange)) {
 		if (!user_mode(regs) && !search_exception_tables(regs->ARM_pc))
 			goto no_context;
 retry:
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in
@@ -348,7 +348,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 		}
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/*
 	 * Handle the "normal" case first - VM_FAULT_MAJOR
diff --git a/arch/arm64/kernel/traps.c b/arch/arm64/kernel/traps.c
index bbb0fde2780e..bf185655b142 100644
--- a/arch/arm64/kernel/traps.c
+++ b/arch/arm64/kernel/traps.c
@@ -351,13 +351,14 @@ void force_signal_inject(int signal, int code, struct pt_regs *regs,
 void arm64_notify_segfault(struct pt_regs *regs, unsigned long addr)
 {
 	int code;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	if (find_vma(current->mm, addr) == NULL)
 		code = SEGV_MAPERR;
 	else
 		code = SEGV_ACCERR;
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	force_signal_inject(SIGSEGV, code, regs, addr);
 }
diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
index 2d419006ad43..1b0006fe9668 100644
--- a/arch/arm64/kernel/vdso.c
+++ b/arch/arm64/kernel/vdso.c
@@ -94,8 +94,9 @@ int aarch32_setup_vectors_page(struct linux_binprm *bprm, int uses_interp)
 
 	};
 	void *ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 	current->mm->context.vdso = (void *)addr;
 
@@ -104,7 +105,7 @@ int aarch32_setup_vectors_page(struct linux_binprm *bprm, int uses_interp)
 				       VM_READ|VM_EXEC|VM_MAYREAD|VM_MAYEXEC,
 				       &spec);
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return PTR_ERR_OR_ZERO(ret);
 }
@@ -178,12 +179,13 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	struct mm_struct *mm = current->mm;
 	unsigned long vdso_base, vdso_text_len, vdso_mapping_len;
 	void *ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	vdso_text_len = vdso_pages << PAGE_SHIFT;
 	/* Be sure to map the data page */
 	vdso_mapping_len = vdso_text_len + PAGE_SIZE;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 	vdso_base = get_unmapped_area(NULL, 0, vdso_mapping_len, 0, 0);
 	if (IS_ERR_VALUE(vdso_base)) {
@@ -206,12 +208,12 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 		goto up_fail;
 
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return 0;
 
 up_fail:
 	mm->context.vdso = NULL;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return PTR_ERR(ret);
 }
 
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 1f3ad9e4f214..555d533d52ab 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -434,11 +434,11 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	 * validly references user space from well defined areas of the code,
 	 * we can bug out early if this is from code which shouldn't.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &mmrange)) {
 		if (!user_mode(regs) && !search_exception_tables(regs->pc))
 			goto no_context;
 retry:
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in which
@@ -477,7 +477,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 			goto retry;
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/*
 	 * Handle the "normal" (no error) case first.
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
