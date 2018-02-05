Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C61DD6B0029
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:06 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id b34so10043855plc.2
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w8-v6si4331550plk.597.2018.02.04.17.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 29/64] arch/alpha: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:19 +0100
Message-Id: <20180205012754.23615-30-dbueso@wotan.suse.de>
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
 arch/alpha/kernel/traps.c |  6 ++++--
 arch/alpha/mm/fault.c     | 10 +++++-----
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/arch/alpha/kernel/traps.c b/arch/alpha/kernel/traps.c
index 4bd99a7b1c41..2d884945bd26 100644
--- a/arch/alpha/kernel/traps.c
+++ b/arch/alpha/kernel/traps.c
@@ -986,12 +986,14 @@ do_entUnaUser(void __user * va, unsigned long opcode,
 		info.si_code = SEGV_ACCERR;
 	else {
 		struct mm_struct *mm = current->mm;
-		down_read(&mm->mmap_sem);
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
+		mm_read_lock(mm, &mmrange);
 		if (find_vma(mm, (unsigned long)va))
 			info.si_code = SEGV_ACCERR;
 		else
 			info.si_code = SEGV_MAPERR;
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	}
 	info.si_addr = va;
 	send_sig_info(SIGSEGV, &info, current);
diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 690d86a00a20..ec0ad8e23528 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -118,7 +118,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	if (user_mode(regs))
 		flags |= FAULT_FLAG_USER;
 retry:
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -181,14 +181,14 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 		}
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return;
 
 	/* Something tried to access memory that isn't in our memory map.
 	   Fix it, but check if it's kernel or user first.  */
  bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	if (user_mode(regs))
 		goto do_sigsegv;
@@ -212,14 +212,14 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	/* We ran out of memory, or some other thing happened to us that
 	   made us unable to handle the page fault gracefully.  */
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
 	/* Send a sigbus, regardless of whether we were in kernel
 	   or user mode.  */
 	info.si_signo = SIGBUS;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
