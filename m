From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 07/22] HWPOISON: define VM_FAULT_HWPOISON to 0 when feature is disabled
Date: Mon, 15 Jun 2009 10:45:27 +0800
Message-ID: <20090615031253.275704587@intel.com>
References: <20090615024520.786814520@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 19E0F6B005C
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:14:28 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-remove-ifdef.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

From: Wu Fengguang <fengguang.wu@intel.com>

So as to eliminate one #ifdef in the c source.

Proposed by Nick Piggin.

Acked-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 arch/x86/mm/fault.c |    3 +--
 include/linux/mm.h  |    7 ++++++-
 2 files changed, 7 insertions(+), 3 deletions(-)

--- sound-2.6.orig/arch/x86/mm/fault.c
+++ sound-2.6/arch/x86/mm/fault.c
@@ -820,14 +820,13 @@ do_sigbus(struct pt_regs *regs, unsigned
 	tsk->thread.error_code	= error_code;
 	tsk->thread.trap_no	= 14;
 
-#ifdef CONFIG_MEMORY_FAILURE
 	if (fault & VM_FAULT_HWPOISON) {
 		printk(KERN_ERR
 	"MCE: Killing %s:%d due to hardware memory corruption fault at %lx\n",
 			tsk->comm, tsk->pid, address);
 		code = BUS_MCEERR_AR;
 	}
-#endif
+
 	force_sig_info_fault(SIGBUS, code, address, tsk);
 }
 
--- sound-2.6.orig/include/linux/mm.h
+++ sound-2.6/include/linux/mm.h
@@ -700,11 +700,16 @@ static inline int page_mapped(struct pag
 #define VM_FAULT_SIGBUS	0x0002
 #define VM_FAULT_MAJOR	0x0004
 #define VM_FAULT_WRITE	0x0008	/* Special case for get_user_pages */
-#define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned page */
 
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 
+#ifdef CONFIG_MEMORY_FAILURE
+#define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned page */
+#else
+#define VM_FAULT_HWPOISON 0
+#endif
+
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_HWPOISON)
 
 /*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
