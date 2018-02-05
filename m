Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id ABD246B02B7
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:34:34 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id o16so18666778pgv.3
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:34:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t22-v6si3930142plo.256.2018.02.04.17.28.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:07 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 53/64] arch/nios2: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:43 +0100
Message-Id: <20180205012754.23615-54-dbueso@wotan.suse.de>
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
 arch/nios2/mm/fault.c | 12 ++++++------
 arch/nios2/mm/init.c  |  5 +++--
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index 768678b685af..a59ebadd8e13 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -85,11 +85,11 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	if (user_mode(regs))
 		flags |= FAULT_FLAG_USER;
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &mmrange)) {
 		if (!user_mode(regs) && !search_exception_tables(regs->ea))
 			goto bad_area_nosemaphore;
 retry:
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	}
 
 	vma = find_vma(mm, address);
@@ -174,7 +174,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 		}
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return;
 
 /*
@@ -182,7 +182,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -220,14 +220,14 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (!user_mode(regs))
 		goto no_context;
 	pagefault_out_of_memory();
 	return;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/* Kernel mode? Handle exceptions or die */
 	if (!user_mode(regs))
diff --git a/arch/nios2/mm/init.c b/arch/nios2/mm/init.c
index c92fe4234009..58bb1c1441ce 100644
--- a/arch/nios2/mm/init.c
+++ b/arch/nios2/mm/init.c
@@ -123,15 +123,16 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
 	struct mm_struct *mm = current->mm;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	/* Map kuser helpers to user space address */
 	ret = install_special_mapping(mm, KUSER_BASE, KUSER_SIZE,
 				      VM_READ | VM_EXEC | VM_MAYREAD |
 				      VM_MAYEXEC, kuser_page);
 
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
