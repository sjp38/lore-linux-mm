Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 856C16B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 16:32:15 -0400 (EDT)
Date: Wed, 24 Jul 2013 16:32:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/5] x86: finish fault error path with fatal signal
Message-ID: <20130724203205.GL715@cmpxchg.org>
References: <20130711072507.GA21667@dhcp22.suse.cz>
 <20130714012641.C2DA4E05@pobox.sk>
 <20130714015112.FFCB7AF7@pobox.sk>
 <20130715154119.GA32435@dhcp22.suse.cz>
 <20130715160006.GB32435@dhcp22.suse.cz>
 <20130716153544.GX17812@cmpxchg.org>
 <20130716160905.GA20018@dhcp22.suse.cz>
 <20130716164830.GZ17812@cmpxchg.org>
 <20130719042124.GC17812@cmpxchg.org>
 <20130719042502.GF17812@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130719042502.GF17812@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com

On Fri, Jul 19, 2013 at 12:25:02AM -0400, Johannes Weiner wrote:
> The x86 fault handler bails in the middle of error handling when the
> task has been killed.  For the next patch this is a problem, because
> it relies on pagefault_out_of_memory() being called even when the task
> has been killed, to perform proper OOM state unwinding.
> 
> This is a rather minor optimization, just remove it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  arch/x86/mm/fault.c | 11 -----------
>  1 file changed, 11 deletions(-)
> 
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 1cebabe..90248c9 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -846,17 +846,6 @@ static noinline int
>  mm_fault_error(struct pt_regs *regs, unsigned long error_code,
>  	       unsigned long address, unsigned int fault)
>  {
> -	/*
> -	 * Pagefault was interrupted by SIGKILL. We have no reason to
> -	 * continue pagefault.
> -	 */
> -	if (fatal_signal_pending(current)) {
> -		if (!(fault & VM_FAULT_RETRY))
> -			up_read(&current->mm->mmap_sem);
> -		if (!(error_code & PF_USER))
> -			no_context(regs, error_code, address);
> -		return 1;

This is broken but I only hit it now after testing for a while.

The patch has the right idea: in case of an OOM kill, we should
continue the fault and not abort.  What I missed is that in case of a
kill during lock_page, i.e. VM_FAULT_RETRY && fatal_signal, we have to
exit the fault and not do up_read() etc.  This introduced a locking
imbalance that would get everybody hung on mmap_sem.

I moved the retry handling outside of mm_fault_error() (come on...)
and stole some documentation from arm.  It's now a little bit more
explicit and comparable to other architectures.

I'll send an updated series, patch for reference:

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] x86: finish fault error path with fatal signal

The x86 fault handler bails in the middle of error handling when the
task has been killed.  For the next patch this is a problem, because
it relies on pagefault_out_of_memory() being called even when the task
has been killed, to perform proper OOM state unwinding.

This is a rather minor optimization that cuts short the fault handling
by a few instructions in rare cases.  Just remove it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/x86/mm/fault.c | 33 +++++++++++++--------------------
 1 file changed, 13 insertions(+), 20 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 6d77c38..0c18beb 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -842,31 +842,17 @@ do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
 	force_sig_info_fault(SIGBUS, code, address, tsk, fault);
 }
 
-static noinline int
+static noinline void
 mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 	       unsigned long address, unsigned int fault)
 {
-	/*
-	 * Pagefault was interrupted by SIGKILL. We have no reason to
-	 * continue pagefault.
-	 */
-	if (fatal_signal_pending(current)) {
-		if (!(fault & VM_FAULT_RETRY))
-			up_read(&current->mm->mmap_sem);
-		if (!(error_code & PF_USER))
-			no_context(regs, error_code, address, 0, 0);
-		return 1;
-	}
-	if (!(fault & VM_FAULT_ERROR))
-		return 0;
-
 	if (fault & VM_FAULT_OOM) {
 		/* Kernel mode? Handle exceptions or die: */
 		if (!(error_code & PF_USER)) {
 			up_read(&current->mm->mmap_sem);
 			no_context(regs, error_code, address,
 				   SIGSEGV, SEGV_MAPERR);
-			return 1;
+			return;
 		}
 
 		up_read(&current->mm->mmap_sem);
@@ -884,7 +870,6 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 		else
 			BUG();
 	}
-	return 1;
 }
 
 static int spurious_fault_check(unsigned long error_code, pte_t *pte)
@@ -1189,9 +1174,17 @@ good_area:
 	 */
 	fault = handle_mm_fault(mm, vma, address, flags);
 
-	if (unlikely(fault & (VM_FAULT_RETRY|VM_FAULT_ERROR))) {
-		if (mm_fault_error(regs, error_code, address, fault))
-			return;
+	/*
+	 * If we need to retry but a fatal signal is pending, handle the
+	 * signal first. We do not need to release the mmap_sem because it
+	 * would already be released in __lock_page_or_retry in mm/filemap.c.
+	 */
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+		return;
+
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		mm_fault_error(regs, error_code, address, fault);
+		return;
 	}
 
 	/*
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
