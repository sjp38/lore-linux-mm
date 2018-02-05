Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6596B02A2
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:40 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id k6so18624224pgt.15
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v126si330488pgb.381.2018.02.04.17.28.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:06 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 43/64] arch/hexagon: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:33 +0100
Message-Id: <20180205012754.23615-44-dbueso@wotan.suse.de>
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
 arch/hexagon/kernel/vdso.c | 5 +++--
 arch/hexagon/mm/vm_fault.c | 8 ++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/arch/hexagon/kernel/vdso.c b/arch/hexagon/kernel/vdso.c
index 3ea968415539..53e3db1b54f1 100644
--- a/arch/hexagon/kernel/vdso.c
+++ b/arch/hexagon/kernel/vdso.c
@@ -64,8 +64,9 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	int ret;
 	unsigned long vdso_base;
 	struct mm_struct *mm = current->mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	/* Try to get it loaded right near ld.so/glibc. */
@@ -89,7 +90,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	mm->context.vdso = (void *)vdso_base;
 
 up_fail:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
 
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index 7d6ada2c2230..58203949486e 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -69,7 +69,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 	if (user_mode(regs))
 		flags |= FAULT_FLAG_USER;
 retry:
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -122,11 +122,11 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 			}
 		}
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		return;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/* Handle copyin/out exception cases */
 	if (!user_mode(regs))
@@ -155,7 +155,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 	return;
 
 bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	if (user_mode(regs)) {
 		info.si_signo = SIGSEGV;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
