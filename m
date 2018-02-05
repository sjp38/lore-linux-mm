Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 669396B027A
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:24 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id l7so4866000pga.6
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b1-v6si6146916pls.421.2018.02.04.17.28.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:07 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 45/64] arch/m32r: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:35 +0100
Message-Id: <20180205012754.23615-46-dbueso@wotan.suse.de>
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
 arch/m32r/mm/fault.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/m32r/mm/fault.c b/arch/m32r/mm/fault.c
index 0129aea46729..2c6b58ecfc53 100644
--- a/arch/m32r/mm/fault.c
+++ b/arch/m32r/mm/fault.c
@@ -137,11 +137,11 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &mmrange)) {
 		if ((error_code & ACE_USERMODE) == 0 &&
 		    !search_exception_tables(regs->psw))
 			goto bad_area_nosemaphore;
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	}
 
 	vma = find_vma(mm, address);
@@ -213,7 +213,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	else
 		tsk->min_flt++;
 	set_thread_fault_code(0);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return;
 
 /*
@@ -221,7 +221,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -274,14 +274,14 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (!(error_code & ACE_USERMODE))
 		goto no_context;
 	pagefault_out_of_memory();
 	return;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/* Kernel mode? Handle exception or die */
 	if (!(error_code & ACE_USERMODE))
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
