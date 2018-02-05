Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0806B027C
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:26 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v7so18549418pgo.8
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2-v6si6009565plh.764.2018.02.04.17.28.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:06 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 40/64] arch/sh: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:30 +0100
Message-Id: <20180205012754.23615-41-dbueso@wotan.suse.de>
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
 arch/sh/kernel/sys_sh.c            | 7 ++++---
 arch/sh/kernel/vsyscall/vsyscall.c | 5 +++--
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/sh/kernel/sys_sh.c b/arch/sh/kernel/sys_sh.c
index 724911c59e7d..35b91b6c8d34 100644
--- a/arch/sh/kernel/sys_sh.c
+++ b/arch/sh/kernel/sys_sh.c
@@ -58,6 +58,7 @@ asmlinkage long sys_mmap2(unsigned long addr, unsigned long len,
 asmlinkage int sys_cacheflush(unsigned long addr, unsigned long len, int op)
 {
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if ((op <= 0) || (op > (CACHEFLUSH_D_PURGE|CACHEFLUSH_I)))
 		return -EINVAL;
@@ -69,10 +70,10 @@ asmlinkage int sys_cacheflush(unsigned long addr, unsigned long len, int op)
 	if (addr + len < addr)
 		return -EFAULT;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	vma = find_vma (current->mm, addr);
 	if (vma == NULL || addr < vma->vm_start || addr + len > vma->vm_end) {
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 		return -EFAULT;
 	}
 
@@ -91,6 +92,6 @@ asmlinkage int sys_cacheflush(unsigned long addr, unsigned long len, int op)
 	if (op & CACHEFLUSH_I)
 		flush_icache_range(addr, addr+len);
 
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	return 0;
 }
diff --git a/arch/sh/kernel/vsyscall/vsyscall.c b/arch/sh/kernel/vsyscall/vsyscall.c
index cc0cc5b4ff18..17520e6b7783 100644
--- a/arch/sh/kernel/vsyscall/vsyscall.c
+++ b/arch/sh/kernel/vsyscall/vsyscall.c
@@ -63,8 +63,9 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	struct mm_struct *mm = current->mm;
 	unsigned long addr;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	addr = get_unmapped_area(NULL, 0, PAGE_SIZE, 0, 0);
@@ -83,7 +84,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	current->mm->context.vdso = (void *)addr;
 
 up_fail:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
