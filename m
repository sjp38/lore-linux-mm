Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 11F2B6B002B
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:08 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m10so7437337pgq.1
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m184si4877770pgm.698.2018.02.04.17.28.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:06 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 41/64] arch/cris: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:31 +0100
Message-Id: <20180205012754.23615-42-dbueso@wotan.suse.de>
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
 arch/cris/mm/fault.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index 16af16d77269..decc8f1fbc9d 100644
--- a/arch/cris/mm/fault.c
+++ b/arch/cris/mm/fault.c
@@ -122,7 +122,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	if (user_mode(regs))
 		flags |= FAULT_FLAG_USER;
 retry:
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -205,7 +205,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 		}
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return;
 
 	/*
@@ -214,7 +214,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	 */
 
  bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
  bad_area_nosemaphore:
 	DPG(show_registers(regs));
@@ -286,14 +286,14 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
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
 
 	/*
 	 * Send a sigbus, regardless of whether we were in kernel
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
