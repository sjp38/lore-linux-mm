Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 186CA6B01F2
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 11:40:08 -0400 (EDT)
Date: Fri, 23 Apr 2010 01:39:56 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable
 task can be found
Message-ID: <20100422153956.GY5683@laptop>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
 <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
 <20100407205418.FB90.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
 <20100421121758.af52f6e0.akpm@linux-foundation.org>
 <20100422072319.GW5683@laptop>
 <20100422162536.b904203e.kamezawa.hiroyu@jp.fujitsu.com>
 <20100422100944.GX5683@laptop>
 <alpine.DEB.2.00.1004220326130.19785@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004220326130.19785@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 22, 2010 at 03:28:38AM -0700, David Rientjes wrote:
> On Thu, 22 Apr 2010, Nick Piggin wrote:
> 
> > Oh actually what happened with the pagefault OOM / panic on oom thing?
> > We were talking around in circles about that too.
> > 
> 
> The oom killer rewrite attempts to kill current first, if possible, and 
> then will panic if panic_on_oom is set before falling back to selecting a 
> victim.

See, this is what we want to avoid. If the user sets panic_on_oom,
it is because they want the system to panic on oom. Not to kill
tasks and try to continue. The user does not know or care in the
slightest about "page fault oom". So I don't know why you think this
is a good idea.


>  This is consistent with all other architectures such as powerpc 
> that currently do not use pagefault_out_of_memory().  If all architectures 
> are eventually going to be converted to using pagefault_out_of_memory() 

Yes, architectures are going to be converted, it has already been
agreed, I dropped the ball and lazily hoped the arch people would do it.
But further work done should be to make it consistent in the right way,
not the wrong way.


> with additional work on top of -mm, it would be possible to define 
> consistent panic_on_oom semantics for this case.  I welcome such an 
> addition since I believe it's a natural extension of panic_on_oom, but I 
> believe it should be done consistently so the sysctl doesn't have 
> different semantics depending on the underlying arch.

It's simply a bug rather than intentional semantics. "pagefault oom"
is basically a meaningless semantic for the user.

Let's do a deal. I'll split up the below patch and send it to arch
maintainers, and you don't change the sysctl interface or "fix" the
pagefault oom path.

--
Index: linux-2.6/arch/alpha/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/alpha/mm/fault.c
+++ linux-2.6/arch/alpha/mm/fault.c
@@ -188,16 +188,10 @@ do_page_fault(unsigned long address, uns
 	/* We ran out of memory, or some other thing happened to us that
 	   made us unable to handle the page fault gracefully.  */
  out_of_memory:
-	if (is_global_init(current)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
-	printk(KERN_ALERT "VM: killing process %s(%d)\n",
-	       current->comm, task_pid_nr(current));
 	if (!user_mode(regs))
 		goto no_context;
-	do_group_exit(SIGKILL);
+	pagefault_out_of_memory();
+	return;
 
  do_sigbus:
 	/* Send a sigbus, regardless of whether we were in kernel
Index: linux-2.6/arch/avr32/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/avr32/mm/fault.c
+++ linux-2.6/arch/avr32/mm/fault.c
@@ -211,15 +211,10 @@ no_context:
 	 */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (is_global_init(current)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
-	printk("VM: Killing process %s\n", tsk->comm);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
-	goto no_context;
+	pagefault_out_of_memory();
+	if (!user_mode(regs))
+		goto no_context;
+	return;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
Index: linux-2.6/arch/cris/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/cris/mm/fault.c
+++ linux-2.6/arch/cris/mm/fault.c
@@ -245,10 +245,10 @@ do_page_fault(unsigned long address, str
 
  out_of_memory:
 	up_read(&mm->mmap_sem);
-	printk("VM: killing process %s\n", tsk->comm);
-	if (user_mode(regs))
-		do_exit(SIGKILL);
-	goto no_context;
+	if (!user_mode(regs))
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
  do_sigbus:
 	up_read(&mm->mmap_sem);
Index: linux-2.6/arch/frv/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/frv/mm/fault.c
+++ linux-2.6/arch/frv/mm/fault.c
@@ -257,10 +257,10 @@ asmlinkage void do_page_fault(int datamm
  */
  out_of_memory:
 	up_read(&mm->mmap_sem);
-	printk("VM: killing process %s\n", current->comm);
-	if (user_mode(__frame))
-		do_group_exit(SIGKILL);
-	goto no_context;
+	if (!user_mode(__frame))
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
  do_sigbus:
 	up_read(&mm->mmap_sem);
Index: linux-2.6/arch/ia64/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/ia64/mm/fault.c
+++ linux-2.6/arch/ia64/mm/fault.c
@@ -276,13 +276,7 @@ ia64_do_page_fault (unsigned long addres
 
   out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (is_global_init(current)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
-	printk(KERN_CRIT "VM: killing process %s\n", current->comm);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
-	goto no_context;
+	if (!user_mode(regs))
+		goto no_context;
+	pagefault_out_of_memory();
 }
Index: linux-2.6/arch/m32r/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/m32r/mm/fault.c
+++ linux-2.6/arch/m32r/mm/fault.c
@@ -271,15 +271,10 @@ no_context:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (is_global_init(tsk)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
-	printk("VM: killing process %s\n", tsk->comm);
 	if (error_code & ACE_USERMODE)
-		do_group_exit(SIGKILL);
-	goto no_context;
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
Index: linux-2.6/arch/m68k/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/m68k/mm/fault.c
+++ linux-2.6/arch/m68k/mm/fault.c
@@ -180,15 +180,10 @@ good_area:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (is_global_init(current)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
-
-	printk("VM: killing process %s\n", current->comm);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
+	if (!user_mode(regs))
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
 no_context:
 	current->thread.signo = SIGBUS;
Index: linux-2.6/arch/microblaze/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/microblaze/mm/fault.c
+++ linux-2.6/arch/microblaze/mm/fault.c
@@ -273,16 +273,11 @@ bad_area_nosemaphore:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	if (current->pid == 1) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
 	up_read(&mm->mmap_sem);
-	printk(KERN_WARNING "VM: killing process %s\n", current->comm);
-	if (user_mode(regs))
-		do_exit(SIGKILL);
-	bad_page_fault(regs, address, SIGKILL);
+	if (!user_mode(regs))
+		bad_page_fault(regs, address, SIGKILL);
+	else
+		pagefault_out_of_memory();
 	return;
 
 do_sigbus:
Index: linux-2.6/arch/mn10300/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/mn10300/mm/fault.c
+++ linux-2.6/arch/mn10300/mm/fault.c
@@ -338,11 +338,10 @@ no_context:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	monitor_signal(regs);
-	printk(KERN_ALERT "VM: killing process %s\n", tsk->comm);
-	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR)
-		do_exit(SIGKILL);
-	goto no_context;
+	if ((fault_code & MMUFCR_xFC_ACCESS) != MMUFCR_xFC_ACCESS_USR)
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
Index: linux-2.6/arch/parisc/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/parisc/mm/fault.c
+++ linux-2.6/arch/parisc/mm/fault.c
@@ -264,8 +264,7 @@ no_context:
 
   out_of_memory:
 	up_read(&mm->mmap_sem);
-	printk(KERN_CRIT "VM: killing process %s\n", current->comm);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
-	goto no_context;
+	if (!user_mode(regs))
+		goto no_context;
+	pagefault_out_of_memory();
 }
Index: linux-2.6/arch/powerpc/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/fault.c
+++ linux-2.6/arch/powerpc/mm/fault.c
@@ -359,15 +359,10 @@ bad_area_nosemaphore:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (is_global_init(current)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
-	printk("VM: killing process %s\n", current->comm);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
-	return SIGKILL;
+	if (!user_mode(regs))
+		return SIGKILL;
+	pagefault_out_of_memory();
+	return 0;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
Index: linux-2.6/arch/score/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/score/mm/fault.c
+++ linux-2.6/arch/score/mm/fault.c
@@ -167,15 +167,10 @@ no_context:
 	*/
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (is_global_init(tsk)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
-	printk("VM: killing process %s\n", tsk->comm);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
-	goto no_context;
+	if (!user_mode(regs))
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
Index: linux-2.6/arch/sh/mm/fault_32.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/fault_32.c
+++ linux-2.6/arch/sh/mm/fault_32.c
@@ -290,15 +290,10 @@ no_context:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (is_global_init(current)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
-	printk("VM: killing process %s\n", tsk->comm);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
-	goto no_context;
+	if (!user_mode(regs))
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
 do_sigbus:
 	up_read(&mm->mmap_sem);
Index: linux-2.6/arch/sh/mm/tlbflush_64.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/tlbflush_64.c
+++ linux-2.6/arch/sh/mm/tlbflush_64.c
@@ -294,22 +294,11 @@ no_context:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	if (is_global_init(current)) {
-		panic("INIT out of memory\n");
-		yield();
-		goto survive;
-	}
-	printk("fault:Out of memory\n");
 	up_read(&mm->mmap_sem);
-	if (is_global_init(current)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
-	printk("VM: killing process %s\n", tsk->comm);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
-	goto no_context;
+	if (!user_mode(regs))
+		goto no_context;
+	pagefault_out_of_memory();
+	return;
 
 do_sigbus:
 	printk("fault:Do sigbus\n");
Index: linux-2.6/arch/xtensa/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/xtensa/mm/fault.c
+++ linux-2.6/arch/xtensa/mm/fault.c
@@ -146,15 +146,10 @@ bad_area:
 	 */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (is_global_init(current)) {
-		yield();
-		down_read(&mm->mmap_sem);
-		goto survive;
-	}
-	printk("VM: killing process %s\n", current->comm);
-	if (user_mode(regs))
-		do_group_exit(SIGKILL);
-	bad_page_fault(regs, address, SIGKILL);
+	if (!user_mode(regs))
+		bad_page_fault(regs, address, SIGKILL);
+	else
+		pagefault_out_of_memory();
 	return;
 
 do_sigbus:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
