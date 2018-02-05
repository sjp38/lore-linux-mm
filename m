Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D40B46B0010
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:07 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id l3so9981013pld.8
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3si2861529pgr.179.2018.02.04.17.28.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:06 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 42/64] arch/frv: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:32 +0100
Message-Id: <20180205012754.23615-43-dbueso@wotan.suse.de>
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
 arch/frv/mm/fault.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/frv/mm/fault.c b/arch/frv/mm/fault.c
index 494d33b628fc..a5da0586e6cc 100644
--- a/arch/frv/mm/fault.c
+++ b/arch/frv/mm/fault.c
@@ -86,7 +86,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 	if (user_mode(__frame))
 		flags |= FAULT_FLAG_USER;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	vma = find_vma(mm, ear0);
 	if (!vma)
@@ -181,7 +181,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 	else
 		current->min_flt++;
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return;
 
 /*
@@ -189,7 +189,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
  * Fix it, but check if it's kernel or user first..
  */
  bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/* User mode accesses just cause a SIGSEGV */
 	if (user_mode(__frame)) {
@@ -259,14 +259,14 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
  * us unable to handle the page fault gracefully.
  */
  out_of_memory:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (!user_mode(__frame))
 		goto no_context;
 	pagefault_out_of_memory();
 	return;
 
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
