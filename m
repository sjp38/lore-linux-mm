Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5E06B002B
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:08 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id g24so10026029plj.4
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 70-v6si3614847ple.246.2018.02.04.17.28.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:07 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 51/64] arch/mn10300: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:41 +0100
Message-Id: <20180205012754.23615-52-dbueso@wotan.suse.de>
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
 arch/mn10300/mm/fault.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index 71c38f0c8702..cd973bd02259 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -175,7 +175,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
 	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR)
 		flags |= FAULT_FLAG_USER;
 retry:
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	vma = find_vma(mm, address);
 	if (!vma)
@@ -286,7 +286,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
 		}
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return;
 
 /*
@@ -294,7 +294,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/* User mode accesses just cause a SIGSEGV */
 	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR) {
@@ -349,7 +349,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR) {
 		pagefault_out_of_memory();
 		return;
@@ -357,7 +357,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/*
 	 * Send a sigbus, regardless of whether we were in kernel
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
