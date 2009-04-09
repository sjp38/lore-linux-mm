Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B2A7F5F0001
	for <linux-mm@kvack.org>; Thu,  9 Apr 2009 04:19:09 -0400 (EDT)
Date: Thu, 9 Apr 2009 16:17:34 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH][2/2]page_fault retry with NOPAGE_RETRY
Message-ID: <20090409081734.GC31527@localhost>
References: <604427e00904081302g1e3e4923kd61ceac5de72ccb2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <604427e00904081302g1e3e4923kd61ceac5de72ccb2@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?utf-8?B?VMO2csO2aw==?= Edwin <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 09, 2009 at 04:02:43AM +0800, Ying Han wrote:
> x86 support:
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> 	       Mike Waychison <mikew@google.com>
>
> arch/x86/mm/fault.c |   20 ++++++++++++++
> 
> 
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 31e8730..0ec60a1 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -591,6 +591,7 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigne
>  #ifdef CONFIG_X86_64
>  	unsigned long flags;
>  #endif
> +	unsigned int retry_flag = FAULT_FLAG_RETRY;
> 
>  	tsk = current;
>  	mm = tsk->mm;
> @@ -689,6 +690,7 @@ again:
>  		down_read(&mm->mmap_sem);
>  	}
> 
> +retry:
>  	vma = find_vma(mm, address);
>  	if (!vma)
>  		goto bad_area;
> @@ -715,6 +717,7 @@ again:
>  good_area:
>  	si_code = SEGV_ACCERR;
>  	write = 0;
> +	write |= retry_flag;
>  	switch (error_code & (PF_PROT|PF_WRITE)) {
>  	default:	/* 3: write, present */
>  		/* fall through */
        case PF_WRITE:          /* write, not present */
                if (!(vma->vm_flags & VM_WRITE))
                        goto bad_area;
                write++;

This looks flaky, since 'write' is now some combination of bit fields.
How about merging 'retry_flag' and 'write' into 'flags' like this?

Thanks,
Fengguang
---
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index c76ef1d..2500ab6 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -587,10 +587,11 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	unsigned long address;
-	int write, si_code;
+	unsigned int flags = FAULT_FLAG_RETRY;
+	int si_code;
 	int fault;
 #ifdef CONFIG_X86_64
-	unsigned long flags;
+	unsigned long oops_flags;
 	int sig;
 #endif
 
@@ -694,6 +695,7 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigned long error_code)
 		down_read(&mm->mmap_sem);
 	}
 
+retry:
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -719,14 +721,13 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigned long error_code)
  */
 good_area:
 	si_code = SEGV_ACCERR;
-	write = 0;
 	switch (error_code & (PF_PROT|PF_WRITE)) {
 	default:	/* 3: write, present */
 		/* fall through */
 	case PF_WRITE:		/* write, not present */
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
-		write++;
+		flags |= VM_FAULT_WRITE;
 		break;
 	case PF_PROT:		/* read, present */
 		goto bad_area;
@@ -740,7 +741,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
@@ -748,6 +749,23 @@ good_area:
 			goto do_sigbus;
 		BUG();
 	}
+
+	/*
+	 * Here we retry fault once and switch to synchronous mode. The
+	 * main reason is to prevent us from the cases of starvation.
+	 * The retry logic open a starvation hole in which case pages might
+	 * be removed or changed after the retry.
+	 */
+	if (fault & VM_FAULT_RETRY) {
+		if (flags & FAULT_FLAG_RETRY) {
+			flags &= ~FAULT_FLAG_RETRY;
+			tsk->maj_flt++;
+			tsk->min_flt--;
+			goto retry;
+		}
+		BUG();
+	}
+
 	if (fault & VM_FAULT_MAJOR)
 		tsk->maj_flt++;
 	else
@@ -840,7 +858,7 @@ no_context:
 #ifdef CONFIG_X86_32
 	bust_spinlocks(1);
 #else
-	flags = oops_begin();
+	oops_flags = oops_begin();
 #endif
 
 	show_fault_oops(regs, error_code, address);
@@ -859,7 +877,7 @@ no_context:
 		sig = 0;
 	/* Executive summary in case the body of the oops scrolled away */
 	printk(KERN_EMERG "CR2: %016lx\n", address);
-	oops_end(flags, regs, sig);
+	oops_end(oops_flags, regs, sig);
 #endif
 
 out_of_memory:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
