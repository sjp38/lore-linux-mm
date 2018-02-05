Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED866B002D
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:07 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id x2so10023736plv.16
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h1si1506271pgs.717.2018.02.04.17.28.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:06 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 47/64] arch/microblaze: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:37 +0100
Message-Id: <20180205012754.23615-48-dbueso@wotan.suse.de>
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
 arch/microblaze/mm/fault.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index fd49efbdfbf4..072e0d79aab5 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -139,12 +139,12 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
+	if (unlikely(!mm_read_trylock(mm, &mmrange))) {
 		if (kernel_mode(regs) && !search_exception_tables(regs->pc))
 			goto bad_area_nosemaphore;
 
 retry:
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	}
 
 	vma = find_vma(mm, address);
@@ -251,7 +251,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 		}
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/*
 	 * keep track of tlb+htab misses that are good addrs but
@@ -262,7 +262,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	return;
 
 bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 bad_area_nosemaphore:
 	pte_errors++;
@@ -286,7 +286,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (!user_mode(regs))
 		bad_page_fault(regs, address, SIGKILL);
 	else
@@ -294,7 +294,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	return;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (user_mode(regs)) {
 		info.si_signo = SIGBUS;
 		info.si_errno = 0;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
