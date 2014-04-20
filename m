Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 367246B0038
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 22:26:49 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id wp4so3064664obc.7
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 19:26:49 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id jh2si26032310obb.113.2014.04.19.19.26.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 19:26:48 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 3/6] mips: call find_vma with the mmap_sem held
Date: Sat, 19 Apr 2014 19:26:28 -0700
Message-Id: <1397960791-16320-4-git-send-email-davidlohr@hp.com>
In-Reply-To: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
References: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zeus@gnu.org, aswin@hp.com, davidlohr@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org

Performing vma lookups without taking the mm->mmap_sem is asking
for trouble. While doing the search, the vma in question can be
modified or even removed before returning to the caller. Take the
lock (exclusively) in order to avoid races while iterating through
the vmacache and/or rbtree.

Updates two functions:
  - process_fpemu_return()
  - cteon_flush_cache_sigtramp()

This patch is completely *untested*.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-mips@linux-mips.org
---
 arch/mips/kernel/traps.c | 2 ++
 arch/mips/mm/c-octeon.c  | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
index 074e857..c51bd20 100644
--- a/arch/mips/kernel/traps.c
+++ b/arch/mips/kernel/traps.c
@@ -712,10 +712,12 @@ int process_fpemu_return(int sig, void __user *fault_addr)
 		si.si_addr = fault_addr;
 		si.si_signo = sig;
 		if (sig == SIGSEGV) {
+			down_read(&current->mm->mmap_sem);
 			if (find_vma(current->mm, (unsigned long)fault_addr))
 				si.si_code = SEGV_ACCERR;
 			else
 				si.si_code = SEGV_MAPERR;
+			up_read(&current->mm->mmap_sem);
 		} else {
 			si.si_code = BUS_ADRERR;
 		}
diff --git a/arch/mips/mm/c-octeon.c b/arch/mips/mm/c-octeon.c
index f41a5c5..05b1d7c 100644
--- a/arch/mips/mm/c-octeon.c
+++ b/arch/mips/mm/c-octeon.c
@@ -137,8 +137,10 @@ static void octeon_flush_cache_sigtramp(unsigned long addr)
 {
 	struct vm_area_struct *vma;
 
+	down_read(&current->mm->mmap_sem);
 	vma = find_vma(current->mm, addr);
 	octeon_flush_icache_all_cores(vma);
+	up_read(&current->mm->mmap_sem);
 }
 
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
