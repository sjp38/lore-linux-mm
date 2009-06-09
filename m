Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 510526B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 07:58:45 -0400 (EDT)
Date: Tue, 9 Jun 2009 20:34:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] HWPOISON: define VM_FAULT_HWPOISON to 0 when feature is
	disabled
Message-ID: <20090609123416.GD5589@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184640.4FD751D0290@basil.firstfloor.org> <20090609095423.GB14820@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609095423.GB14820@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 05:54:23PM +0800, Nick Piggin wrote:
> On Wed, Jun 03, 2009 at 08:46:40PM +0200, Andi Kleen wrote:

> > -	force_sig_info_fault(SIGBUS, BUS_ADRERR, address, tsk);
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +	if (fault & VM_FAULT_HWPOISON) {
> > +		printk(KERN_ERR
> > +	"MCE: Killing %s:%d due to hardware memory corruption fault at %lx\n",
> > +			tsk->comm, tsk->pid, address);
> > +		code = BUS_MCEERR_AR;
> > +	}
> > +#endif
> 
> If you make VM_FAULT_HWPOISON 0 when !CONFIG_MEMORY_FAILURE, then
> you can remove this ifdef, can't you?

Sure we can. Here is the incremental patch.

---
HWPOISON: define VM_FAULT_HWPOISON to 0 when feature is disabled

So as to eliminate one #ifdef in the c source.

Proposed by Nick Piggin.

CC: Nick Piggin <npiggin@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 arch/x86/mm/fault.c |    3 +--
 include/linux/mm.h  |    7 ++++++-
 2 files changed, 7 insertions(+), 3 deletions(-)

--- sound-2.6.orig/arch/x86/mm/fault.c
+++ sound-2.6/arch/x86/mm/fault.c
@@ -819,14 +819,13 @@ do_sigbus(struct pt_regs *regs, unsigned
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
@@ -702,11 +702,16 @@ static inline int page_mapped(struct pag
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
