Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA486B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 05:21:40 -0400 (EDT)
Date: Wed, 27 Oct 2010 11:21:35 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [GIT PULL] Please pull hwpoison updates for 2.6.37
Message-ID: <20101027092135.GE2472@basil.fritz.box>
References: <20101026100923.GA5118@basil.fritz.box>
 <20101027074254.GA809@elte.hu>
 <20101027075846.GA2472@basil.fritz.box>
 <20101027081853.GA20196@elte.hu>
 <20101027090128.GC2472@basil.fritz.box>
 <20101027090903.GA16957@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101027090903.GA16957@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <andi@firstfloor.org>, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 27, 2010 at 11:09:03AM +0200, Ingo Molnar wrote:
> 
> * Andi Kleen <andi@firstfloor.org> wrote:
> 
> > > You are welcome! How about the cleanliness feedback that i gave?
> > > (the stuff in parentheses)
> > 
> > Could move the ifdef into mm.h for the flags and let the optimizer
> > eliminate the code. I can do that in a followup patch.
> 
> Yeah. If it does not work out due to architectural differences then
> do not push it too hard (the code is small enough) - we only want to
> factor this out if it makes things cleaner.

Here's the patch I came up with. I'll keep it in my tree for now.

-Andi

---

x86/HWPOISON: Move do_sigbus ifdef into header
    
Ingo asked for moving the MEMORY_FAILURE ifdef in the x86's
fault handler's do_sigbus elsewhere. This patch moves the
ifdef into mm.h by defining the HWPOISON return flags
of handle_mm_fault() to 0 if MEMORY_FAILURE is not enabled.
This way the optimizer can eliminate the code without ifdef.
    
Reported-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 852b319..8b76d79 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -812,14 +812,12 @@ do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
 	tsk->thread.error_code	= error_code;
 	tsk->thread.trap_no	= 14;
 
-#ifdef CONFIG_MEMORY_FAILURE
 	if (fault & (VM_FAULT_HWPOISON|VM_FAULT_HWPOISON_LARGE)) {
 		printk(KERN_ERR
 	"MCE: Killing %s:%d due to hardware memory corruption fault at %lx\n",
 			tsk->comm, tsk->pid, address);
 		code = BUS_MCEERR_AR;
 	}
-#endif
 	force_sig_info_fault(SIGBUS, code, address, tsk, fault);
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a4c6684..d9a6af5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -718,8 +718,13 @@ static inline int page_mapped(struct page *page)
 #define VM_FAULT_SIGBUS	0x0002
 #define VM_FAULT_MAJOR	0x0004
 #define VM_FAULT_WRITE	0x0008	/* Special case for get_user_pages */
+#ifdef CONFIG_MEMORY_FAILURE
 #define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned small page */
 #define VM_FAULT_HWPOISON_LARGE 0x0020  /* Hit poisoned large page. Index encoded in upper bits */
+#else
+#define VM_FAULT_HWPOISON 0
+#define VM_FAULT_HWPOISON_LARGE 0
+#endif
 
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */


-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
