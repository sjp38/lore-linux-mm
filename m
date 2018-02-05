Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CDEEF6B0288
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:30 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id n11so10040217plp.13
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v68si6041290pfb.292.2018.02.04.17.28.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:07 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 48/64] arch/tile: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:38 +0100
Message-Id: <20180205012754.23615-49-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

* THIS IS A HACK *

Breaks arch/um/. See comment in fix_range_common().

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/um/include/asm/mmu_context.h |  5 +++--
 arch/um/kernel/tlb.c              | 12 +++++++++++-
 arch/um/kernel/trap.c             |  6 +++---
 3 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/arch/um/include/asm/mmu_context.h b/arch/um/include/asm/mmu_context.h
index 98cc3e36385a..7dc202c611db 100644
--- a/arch/um/include/asm/mmu_context.h
+++ b/arch/um/include/asm/mmu_context.h
@@ -49,14 +49,15 @@ extern void force_flush_all(void);
 
 static inline void activate_mm(struct mm_struct *old, struct mm_struct *new)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	/*
 	 * This is called by fs/exec.c and sys_unshare()
 	 * when the new ->mm is used for the first time.
 	 */
 	__switch_mm(&new->context.id);
-	down_write(&new->mmap_sem);
+        mm_write_lock(new, &mmrange);
 	uml_setup_stubs(new);
-	up_write(&new->mmap_sem);
+	mm_write_unlock(new, &mmrange);
 }
 
 static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next, 
diff --git a/arch/um/kernel/tlb.c b/arch/um/kernel/tlb.c
index 37508b190106..eeeeb048b6f4 100644
--- a/arch/um/kernel/tlb.c
+++ b/arch/um/kernel/tlb.c
@@ -297,10 +297,20 @@ void fix_range_common(struct mm_struct *mm, unsigned long start_addr,
 
 	/* This is not an else because ret is modified above */
 	if (ret) {
+		/*
+		 * FIXME: this is _wrong_ and will break arch/um.
+		 *
+		 *  The right thing to do is modify the flush_tlb_range()
+		 *  api, but that in turn would require file_operations
+		 *  knowing about mmrange... Compiles cleanly, but sucks
+		 *  otherwise.
+		 */
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
 		printk(KERN_ERR "fix_range_common: failed, killing current "
 		       "process: %d\n", task_tgid_vnr(current));
 		/* We are under mmap_sem, release it such that current can terminate */
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm, &mmrange);
 		force_sig(SIGKILL, current);
 		do_signal(&current->thread.regs);
 	}
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index e632a14e896e..14dcb83d00a9 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -47,7 +47,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 	if (is_user)
 		flags |= FAULT_FLAG_USER;
 retry:
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto out;
@@ -123,7 +123,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 #endif
 	flush_tlb_page(vma, address);
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 out_nosemaphore:
 	return err;
 
@@ -132,7 +132,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 	 * We ran out of memory, call the OOM killer, and return the userspace
 	 * (which will retry the fault, or kill us if we got oom-killed).
 	 */
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (!is_user)
 		goto out_nosemaphore;
 	pagefault_out_of_memory();
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
