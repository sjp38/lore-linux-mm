Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1AAF46B0030
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:09 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y62so18641325pgy.0
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i64-v6si6201020pli.142.2018.02.04.17.28.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:08 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 50/64] arch/unicore32: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:40 +0100
Message-Id: <20180205012754.23615-51-dbueso@wotan.suse.de>
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
 arch/unicore32/mm/fault.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index dd35b6191798..f806ade79afd 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -233,12 +233,12 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	 * validly references user space from well defined areas of the code,
 	 * we can bug out early if this is from code which shouldn't.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &mmrange)) {
 		if (!user_mode(regs)
 		    && !search_exception_tables(regs->UCreg_pc))
 			goto no_context;
 retry:
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in
@@ -275,7 +275,7 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 		}
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/*
 	 * Handle the "normal" case first - VM_FAULT_MAJOR
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
