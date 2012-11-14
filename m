Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 4A9306B0089
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 04:15:30 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so119685dad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 01:15:29 -0800 (PST)
Date: Wed, 14 Nov 2012 01:15:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 4/4] mm, oom: remove statically defined arch functions of
 same name
In-Reply-To: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1211140113480.32125@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

out_of_memory() is a globally defined function to call the oom killer.
x86, sh, and powerpc all use a function of the same name within file
scope in their respective fault.c unnecessarily.  Inline the functions
into the pagefault handlers to clean the code up.

Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Paul Mundt <lethal@linux-sh.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 arch/powerpc/mm/fault.c |   27 ++++++++++++---------------
 arch/sh/mm/fault.c      |   19 +++++++------------
 arch/x86/mm/fault.c     |   23 ++++++++---------------
 3 files changed, 27 insertions(+), 42 deletions(-)

diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -113,19 +113,6 @@ static int store_updates_sp(struct pt_regs *regs)
 #define MM_FAULT_CONTINUE	-1
 #define MM_FAULT_ERR(sig)	(sig)
 
-static int out_of_memory(struct pt_regs *regs)
-{
-	/*
-	 * We ran out of memory, or some other thing happened to us that made
-	 * us unable to handle the page fault gracefully.
-	 */
-	up_read(&current->mm->mmap_sem);
-	if (!user_mode(regs))
-		return MM_FAULT_ERR(SIGKILL);
-	pagefault_out_of_memory();
-	return MM_FAULT_RETURN;
-}
-
 static int do_sigbus(struct pt_regs *regs, unsigned long address)
 {
 	siginfo_t info;
@@ -169,8 +156,18 @@ static int mm_fault_error(struct pt_regs *regs, unsigned long addr, int fault)
 		return MM_FAULT_CONTINUE;
 
 	/* Out of memory */
-	if (fault & VM_FAULT_OOM)
-		return out_of_memory(regs);
+	if (fault & VM_FAULT_OOM) {
+		up_read(&current->mm->mmap_sem);
+
+		/*
+		 * We ran out of memory, or some other thing happened to us that
+		 * made us unable to handle the page fault gracefully.
+		 */
+		if (!user_mode(regs))
+			return MM_FAULT_ERR(SIGKILL);
+		pagefault_out_of_memory();
+		return MM_FAULT_RETURN;
+	}
 
 	/* Bus error. x86 handles HWPOISON here, we'll add this if/when
 	 * we support the feature in HW
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -301,17 +301,6 @@ bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 	__bad_area(regs, error_code, address, SEGV_ACCERR);
 }
 
-static void out_of_memory(void)
-{
-	/*
-	 * We ran out of memory, call the OOM killer, and return the userspace
-	 * (which will retry the fault, or kill us if we got oom-killed):
-	 */
-	up_read(&current->mm->mmap_sem);
-
-	pagefault_out_of_memory();
-}
-
 static void
 do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address)
 {
@@ -353,8 +342,14 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 			no_context(regs, error_code, address);
 			return 1;
 		}
+		up_read(&current->mm->mmap_sem);
 
-		out_of_memory();
+		/*
+		 * We ran out of memory, call the OOM killer, and return the
+		 * userspace (which will retry the fault, or kill us if we got
+		 * oom-killed):
+		 */
+		pagefault_out_of_memory();
 	} else {
 		if (fault & VM_FAULT_SIGBUS)
 			do_sigbus(regs, error_code, address);
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -803,20 +803,6 @@ bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 	__bad_area(regs, error_code, address, SEGV_ACCERR);
 }
 
-/* TODO: fixup for "mm-invoke-oom-killer-from-page-fault.patch" */
-static void
-out_of_memory(struct pt_regs *regs, unsigned long error_code,
-	      unsigned long address)
-{
-	/*
-	 * We ran out of memory, call the OOM killer, and return the userspace
-	 * (which will retry the fault, or kill us if we got oom-killed):
-	 */
-	up_read(&current->mm->mmap_sem);
-
-	pagefault_out_of_memory();
-}
-
 static void
 do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
 	  unsigned int fault)
@@ -879,7 +865,14 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 			return 1;
 		}
 
-		out_of_memory(regs, error_code, address);
+		up_read(&current->mm->mmap_sem);
+
+		/*
+		 * We ran out of memory, call the OOM killer, and return the
+		 * userspace (which will retry the fault, or kill us if we got
+		 * oom-killed):
+		 */
+		pagefault_out_of_memory();
 	} else {
 		if (fault & (VM_FAULT_SIGBUS|VM_FAULT_HWPOISON|
 			     VM_FAULT_HWPOISON_LARGE))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
