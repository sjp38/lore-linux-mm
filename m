Subject: RE: [patch] removes MAX_ARG_PAGES
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0184DF88@scsmsx411.amr.corp.intel.com>
References: <617E1C2C70743745A92448908E030B2A0184DF88@scsmsx411.amr.corp.intel.com>
Content-Type: text/plain
Date: Thu, 24 May 2007 17:20:19 +0200
Message-Id: <1180020019.7019.133.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ollie Wild <aaw@google.com>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-22 at 16:49 -0700, Luck, Tony wrote:
> > In order to solve this, I added a STACK_TOP_MAX macro for each arch and
> > use that. This made IA64 boot properly.
> 
> Yes.  Patches apply to 2.6.21 cleanly, build cleanly and boot for me too.
> I can even run:
> 
> 	$ ls -lrt `find /usr/share -type f -print`
> 
> on the new kernel (thats 48020 files for a total of 2.3MB of args).
> 
> > The second patch makes the compat stuff compile, untested though, as I
> > have no idea how that works on ia64.
> 
> Not so good on this part.  Running an ia32 binary on this patched kernel
> just hung my system :-(

I just tried this on an Altix from the test lab, and ia32 bash just
started.

native 64 bit gave this:

$ ls `find / -xdev -type f` | wc
      1   89847 4200288

but the 32 bit bash kept complaining about his arg list being too long.
This might be a 32->64 issue (/bin/ls is 64 bit after all - and I
couldn't find a 32 bit ls in the compat packages), but I really don't
know. Will look into this.

The difference I had with what I posted last is below; these changes
were just me cleaning up. (and fixing one bug on STACK_GROWS_UP
introduced by the previous patches - but AFAIK that is not relevant to
ia64)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/exec.c |   15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

Index: linux-2.6-2/fs/exec.c
===================================================================
--- linux-2.6-2.orig/fs/exec.c	2007-05-24 09:15:54.000000000 +0200
+++ linux-2.6-2/fs/exec.c	2007-05-24 09:41:49.000000000 +0200
@@ -532,26 +532,23 @@ int setup_arg_pages(struct linux_binprm 
 	stack_base = current->signal->rlim[RLIMIT_STACK].rlim_max;
 	if (stack_base > (1 << 30))
 		stack_base = 1 << 30;
-	stack_base = PAGE_ALIGN(stack_top - stack_base);
 
 	/* Make sure we didn't let the argument array grow too large. */
 	if (vma->vm_end - vma->vm_start > stack_base)
 		return -ENOMEM;
 
+	stack_base = PAGE_ALIGN(stack_top - stack_base);
+
 	stack_shift = stack_base - vma->vm_start;
 	mm->arg_start = bprm->p + stack_shift;
 	bprm->p = vma->vm_end + stack_shift;
 #else
 	BUG_ON(stack_top & ~PAGE_MASK);
 
-	stack_base = arch_align_stack(stack_top - mm->stack_vm*PAGE_SIZE);
-	stack_base = PAGE_ALIGN(stack_base);
-
-	/* Make sure we didn't let the argument array grow too large. */
-	if (stack_base > stack_top)
-		return -ENOMEM;
+	stack_top = arch_align_stack(stack_top);
+	stack_top = PAGE_ALIGN(stack_top);
+	stack_shift = stack_top - vma->vm_end;
 
-	stack_shift = stack_base - (bprm->p & PAGE_MASK);
 	bprm->p += stack_shift;
 	mm->arg_start = bprm->p;
 #endif
@@ -598,7 +595,7 @@ int setup_arg_pages(struct linux_binprm 
 			return -EFAULT;
 		}
 #else
-		if (expand_stack(vma, stack_base -
+		if (expand_stack(vma, vma->vm_start -
 					EXTRA_STACK_VM_PAGES * PAGE_SIZE)) {
 			up_write(&mm->mmap_sem);
 			return -EFAULT;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
