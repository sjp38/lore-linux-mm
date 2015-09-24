Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 37C986B025E
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 05:23:26 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so240992782wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 02:23:25 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id bf6si6745662wib.52.2015.09.24.02.23.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 02:23:24 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so19244710wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 02:23:24 -0700 (PDT)
Date: Thu, 24 Sep 2015 11:23:20 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
Message-ID: <20150924092320.GA26876@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150916174906.51062FBC@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Dave Hansen <dave@sr71.net> wrote:

> A protection key fault is very similar to any other access
> error.  There must be a VMA, etc...  We even want to take
> the same action (SIGSEGV) that we do with a normal access
> fault.
> 
> However, we do need to let userspace know that something
> is different.  We do this the same way what we did with
> SEGV_BNDERR with Memory Protection eXtensions (MPX):
> define a new SEGV code: SEGV_PKUERR.
> 
> We also add a siginfo field: si_pkey that reveals to
> userspace which protection key was set on the PTE that
> we faulted on.  There is no other easy way for
> userspace to figure this out.  They could parse smaps
> but that would be a bit cruel.

> diff -puN arch/x86/mm/fault.c~pkeys-09-siginfo arch/x86/mm/fault.c
> --- a/arch/x86/mm/fault.c~pkeys-09-siginfo	2015-09-16 10:48:15.580161678 -0700
> +++ b/arch/x86/mm/fault.c	2015-09-16 10:48:15.591162177 -0700
> @@ -15,12 +15,14 @@
>  #include <linux/context_tracking.h>	/* exception_enter(), ...	*/
>  #include <linux/uaccess.h>		/* faulthandler_disabled()	*/
>  
> +#include <asm/cpufeature.h>		/* boot_cpu_has, ...		*/
>  #include <asm/traps.h>			/* dotraplinkage, ...		*/
>  #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
>  #include <asm/kmemcheck.h>		/* kmemcheck_*(), ...		*/
>  #include <asm/fixmap.h>			/* VSYSCALL_ADDR		*/
>  #include <asm/vsyscall.h>		/* emulate_vsyscall		*/
>  #include <asm/vm86.h>			/* struct vm86			*/
> +#include <asm/mmu_context.h>		/* vma_pkey()			*/
>  
>  #define CREATE_TRACE_POINTS
>  #include <asm/trace/exceptions.h>
> @@ -169,6 +171,45 @@ is_prefetch(struct pt_regs *regs, unsign
>  	return prefetch;
>  }
>  
> +static u16 fetch_pkey(unsigned long address, struct task_struct *tsk)
> +{
> +	u16 ret;
> +	spinlock_t *ptl;
> +	pte_t *ptep;
> +	pte_t pte;
> +	int follow_ret;
> +
> +	if (!boot_cpu_has(X86_FEATURE_OSPKE))
> +		return 0;
> +
> +	follow_ret = follow_pte(tsk->mm, address, &ptep, &ptl);
> +	if (!follow_ret) {
> +		/*
> +		 * On a successful follow, make sure to
> +		 * drop the lock.
> +		 */
> +		pte = *ptep;
> +		pte_unmap_unlock(ptep, ptl);
> +		ret = pte_pkey(pte);
> +	} else {
> +		/*
> +		 * There is no PTE.  Go looking for the pkey in
> +		 * the VMA.  If we did not find a pkey violation
> +		 * from either the PTE or the VMA, then it must
> +		 * have been a fault from the hardware.  Perhaps
> +		 * the PTE got zapped before we got in here.
> +		 */
> +		struct vm_area_struct *vma = find_vma(tsk->mm, address);
> +		if (vma) {
> +			ret = vma_pkey(vma);
> +		} else {
> +			WARN_ONCE(1, "no PTE or VMA @ %lx\n", address);
> +			ret = 0;
> +		}
> +	}
> +	return ret;

Yeah, so I have three observations:

1)

I don't think this warning is entirely right, because this is a fundamentally racy 
op.

fetch_pkey(), called by force_sign_info_fault(), can be called while not holding 
the vma - and if we race with any other thread of the mm, the vma might be gone 
already.

So any threaded app using pkeys and vmas in parallel could trigger that WARN_ON().

2)

And note that this is a somewhat new scenario: in regular page faults, 
'error_code' always carries a then-valid cause of the page fault with itself. So 
we can put that into the siginfo and can be sure that it's the reason for the 
fault.

With the above pkey code, we fetch the pte separately from the fault, and without 
synchronizing with the fault - and we cannot do that, nor do we want to.

So I think this code should just accept the fact that races may happen. Perhaps 
warn if we get here with only a single mm user. (but even that would be a bit racy 
as we don't serialize against exit())

3)

For user-space that somehow wants to handle pkeys dynamically and drive them via 
faults, this seems somewhat inefficient: we already do a find_vma() in the primary 
fault lookup - and with the typical pkey usecase it will find a vma, just with the 
wrong access permissions. But when we generate the siginfo here, why do we do a 
find_vma() again? Why not pass the vma to the siginfo generating function?

> --- a/include/uapi/asm-generic/siginfo.h~pkeys-09-siginfo	2015-09-16 10:48:15.584161859 -0700
> +++ b/include/uapi/asm-generic/siginfo.h	2015-09-16 10:48:15.592162222 -0700
> @@ -95,6 +95,13 @@ typedef struct siginfo {
>  				void __user *_lower;
>  				void __user *_upper;
>  			} _addr_bnd;
> +			int _pkey; /* FIXME: protection key value??
> +				    * Do we really need this in here?
> +				    * userspace can get the PKRU value in
> +				    * the signal handler, but they do not
> +				    * easily have access to the PKEY value
> +				    * from the PTE.
> +				    */
>  		} _sigfault;

A couple of comments:

1)

Please use our ABI types - this one should be 'u32' I think.

We could use 'u8' as well here, and mark another 3 bytes next to it as reserved 
for future flags. Right now protection keys use 4 bits, but do you really think 
they'll ever grow beyond 8 bits? PTE bits are a scarce resource in general.

2)

To answer your question in the comment: it looks useful to have some sort of 
'extended page fault error code' information here, which shows why the page fault 
happened. With the regular error_code it's easy - with protection keys there's 16 
separate keys possible and user-space might not know the actual key value in the 
pte.

3)

Please add suitable self-tests to tools/tests/selftests/x86/ that both documents 
the preferred usage of pkeys, demonstrates all implemented aspects the new ABI and 
provokes a fault and prints the resulting siginfo, etc.

> @@ -206,7 +214,8 @@ typedef struct siginfo {
>  #define SEGV_MAPERR	(__SI_FAULT|1)	/* address not mapped to object */
>  #define SEGV_ACCERR	(__SI_FAULT|2)	/* invalid permissions for mapped object */
>  #define SEGV_BNDERR	(__SI_FAULT|3)  /* failed address bound checks */
> -#define NSIGSEGV	3
> +#define SEGV_PKUERR	(__SI_FAULT|4)  /* failed address bound checks */
> +#define NSIGSEGV	4

You copy & pasted the MPX comment here, it should read something like:

   #define SEGV_PKUERR	(__SI_FAULT|4)  /* failed protection keys checks */

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
