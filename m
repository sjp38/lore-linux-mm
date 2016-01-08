Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 135D0828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 14:52:14 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l65so147220011wmf.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 11:52:14 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id o184si1013183wmb.25.2016.01.08.11.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jan 2016 11:52:13 -0800 (PST)
Date: Fri, 8 Jan 2016 20:51:16 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 31/31] x86, pkeys: execute-only support
In-Reply-To: <20160107000148.ED5D13DF@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1601082043160.3575@nanos>
References: <20160107000104.1A105322@viggo.jf.intel.com> <20160107000148.ED5D13DF@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, keescook@google.com, luto@amacapital.net

On Wed, 6 Jan 2016, Dave Hansen wrote:
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

> diff -puN arch/x86/mm/fault.c~pkeys-79-xonly arch/x86/mm/fault.c
> --- a/arch/x86/mm/fault.c~pkeys-79-xonly	2016-01-06 15:50:16.799660453 -0800
> +++ b/arch/x86/mm/fault.c	2016-01-06 15:50:16.810660949 -0800
> @@ -14,6 +14,8 @@
>  #include <linux/prefetch.h>		/* prefetchw			*/
>  #include <linux/context_tracking.h>	/* exception_enter(), ...	*/
>  #include <linux/uaccess.h>		/* faulthandler_disabled()	*/
> +#include <linux/pkeys.h>		/* PKEY_*			*/
> +#include <uapi/asm-generic/mman-common.h>
>  
>  #include <asm/cpufeature.h>		/* boot_cpu_has, ...		*/
>  #include <asm/traps.h>			/* dotraplinkage, ...		*/
> @@ -23,6 +25,7 @@
>  #include <asm/vsyscall.h>		/* emulate_vsyscall		*/
>  #include <asm/vm86.h>			/* struct vm86			*/
>  #include <asm/mmu_context.h>		/* vma_pkey()			*/
> +#include <asm/fpu/internal.h>		/* fpregs_active()		*/

These include changes are presumably leftovers from an earlier version. At
least I can't see a reason why we would need them for the change below.
  
>  #define CREATE_TRACE_POINTS
>  #include <asm/trace/exceptions.h>
> @@ -1108,6 +1111,16 @@ access_error(unsigned long error_code, s
>  	 */
>  	if (error_code & PF_PK)
>  		return 1;
> +
> +	if (!(error_code & PF_INSTR)) {
> +		/*
> +		 * Assume all accesses require either read or execute
> +		 * permissions.  This is not an instruction access, so
> +		 * it requires read permissions.
> +		 */
> +		if (!(vma->vm_flags & VM_READ))
> +			return 1;
> +	}

Except for the above nit: Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
