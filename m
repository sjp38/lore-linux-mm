Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 639296B0261
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 10:40:35 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id w130so12610935lfd.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 07:40:35 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id ji7si3645217wjb.48.2016.07.07.07.40.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 07:40:34 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id A56C021009C
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 14:40:33 +0000 (UTC)
Date: Thu, 7 Jul 2016 15:40:32 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/9] mm: implement new pkey_mprotect() system call
Message-ID: <20160707144031.GY11498@techsingularity.net>
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124722.DE1EE343@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707124722.DE1EE343@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk

On Thu, Jul 07, 2016 at 05:47:22AM -0700, Dave Hansen wrote:
> diff -puN arch/x86/include/asm/mmu_context.h~pkeys-110-syscalls-mprotect_pkey arch/x86/include/asm/mmu_context.h
> --- a/arch/x86/include/asm/mmu_context.h~pkeys-110-syscalls-mprotect_pkey	2016-07-07 05:46:59.974764757 -0700
> +++ b/arch/x86/include/asm/mmu_context.h	2016-07-07 05:46:59.986765301 -0700
> @@ -4,6 +4,7 @@
>  #include <asm/desc.h>
>  #include <linux/atomic.h>
>  #include <linux/mm_types.h>
> +#include <linux/pkeys.h>
>  
>  #include <trace/events/tlb.h>
>  
> @@ -195,16 +196,20 @@ static inline void arch_unmap(struct mm_
>  		mpx_notify_unmap(mm, vma, start, end);
>  }
>  
> +#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
>  static inline int vma_pkey(struct vm_area_struct *vma)
>  {
> -	u16 pkey = 0;
> -#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
>  	unsigned long vma_pkey_mask = VM_PKEY_BIT0 | VM_PKEY_BIT1 |
>  				      VM_PKEY_BIT2 | VM_PKEY_BIT3;
> -	pkey = (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
> -#endif
> -	return pkey;
> +
> +	return (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
> +}
> +#else
> +static inline int vma_pkey(struct vm_area_struct *vma)
> +{
> +	return 0;
>  }
> +#endif
>  
>  static inline bool __pkru_allows_pkey(u16 pkey, bool write)
>  {

Looks like MASK could have been statically defined and be a simple shift
and mask known at compile time. Minor though.

> diff -puN arch/x86/include/asm/pkeys.h~pkeys-110-syscalls-mprotect_pkey arch/x86/include/asm/pkeys.h
> --- a/arch/x86/include/asm/pkeys.h~pkeys-110-syscalls-mprotect_pkey	2016-07-07 05:46:59.976764847 -0700
> +++ b/arch/x86/include/asm/pkeys.h	2016-07-07 05:46:59.986765301 -0700
> @@ -1,7 +1,12 @@
>  #ifndef _ASM_X86_PKEYS_H
>  #define _ASM_X86_PKEYS_H
>  
> -#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? 16 : 1)
> +#define PKEY_DEDICATED_EXECUTE_ONLY 15
> +/*
> + * Consider the PKEY_DEDICATED_EXECUTE_ONLY key unavailable.
> + */
> +#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? \
> +		PKEY_DEDICATED_EXECUTE_ONLY : 1)
>  
>  extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
>  		unsigned long init_val);
> @@ -10,7 +15,6 @@ extern int arch_set_user_pkey_access(str
>   * Try to dedicate one of the protection keys to be used as an
>   * execute-only protection key.
>   */
> -#define PKEY_DEDICATED_EXECUTE_ONLY 15
>  extern int __execute_only_pkey(struct mm_struct *mm);
>  static inline int execute_only_pkey(struct mm_struct *mm)
>  {
> @@ -31,4 +35,7 @@ static inline int arch_override_mprotect
>  	return __arch_override_mprotect_pkey(vma, prot, pkey);
>  }
>  
> +extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
> +		unsigned long init_val);
> +
>  #endif /*_ASM_X86_PKEYS_H */
> diff -puN arch/x86/kernel/fpu/xstate.c~pkeys-110-syscalls-mprotect_pkey arch/x86/kernel/fpu/xstate.c
> --- a/arch/x86/kernel/fpu/xstate.c~pkeys-110-syscalls-mprotect_pkey	2016-07-07 05:46:59.977764893 -0700
> +++ b/arch/x86/kernel/fpu/xstate.c	2016-07-07 05:46:59.987765346 -0700
> @@ -889,7 +889,7 @@ out:
>   * not modfiy PKRU *itself* here, only the XSAVE state that will
>   * be restored in to PKRU when we return back to userspace.
>   */
> -int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
> +int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
>  		unsigned long init_val)
>  {

In the changelog, you state that the key is unsigned long yet here and
in the documentation you linked, it's int. Minimally, it's surprising
that the key is signed.

>  	struct xregs_state *xsave = &tsk->thread.fpu.state.xsave;
> @@ -948,3 +948,16 @@ int arch_set_user_pkey_access(struct tas
>  
>  	return 0;
>  }
> +
> +/*
> + * When setting a userspace-provided value, we need to ensure
> + * that it is valid.  The __ version can get used by
> + * kernel-internal uses like the execute-only support.
> + */
> +int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
> +		unsigned long init_val)
> +{
> +	if (!validate_pkey(pkey))
> +		return -EINVAL;
> +	return __arch_set_user_pkey_access(tsk, pkey, init_val);
> +}

There appears to be a subtle bug fixed for validate_key. It appears
there wasn't protection of the dedicated key before but nothing could
reach it.

The arch_max_pkey and PKEY_DEDICATE_EXECUTE_ONLY interaction is subtle
but I can't find a problem with it either.

That aside, the validate_pkey check looks weak. It might be a number
that works but no guarantee it's an allocated key or initialised
properly. At this point, garbage can be handed into the system call
potentially but maybe that gets fixed later.

> diff -puN arch/x86/mm/pkeys.c~pkeys-110-syscalls-mprotect_pkey arch/x86/mm/pkeys.c
> --- a/arch/x86/mm/pkeys.c~pkeys-110-syscalls-mprotect_pkey	2016-07-07 05:46:59.980765029 -0700
> +++ b/arch/x86/mm/pkeys.c	2016-07-07 05:46:59.987765346 -0700
> @@ -38,7 +38,7 @@ int __execute_only_pkey(struct mm_struct
>  		return PKEY_DEDICATED_EXECUTE_ONLY;
>  	}
>  	preempt_enable();
> -	ret = arch_set_user_pkey_access(current, PKEY_DEDICATED_EXECUTE_ONLY,
> +	ret = __arch_set_user_pkey_access(current, PKEY_DEDICATED_EXECUTE_ONLY,
>  			PKEY_DISABLE_ACCESS);
>  	/*
>  	 * If the PKRU-set operation failed somehow, just return
> diff -puN mm/mprotect.c~pkeys-110-syscalls-mprotect_pkey mm/mprotect.c
> --- a/mm/mprotect.c~pkeys-110-syscalls-mprotect_pkey	2016-07-07 05:46:59.982765119 -0700
> +++ b/mm/mprotect.c	2016-07-07 05:46:59.987765346 -0700
> @@ -352,8 +352,11 @@ fail:
>  	return error;
>  }
>  
> -SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
> -		unsigned long, prot)
> +/*
> + * pkey==-1 when doing a legacy mprotect()
> + */
> +static int do_mprotect_pkey(unsigned long start, size_t len,
> +		unsigned long prot, int pkey)
>  {
>  	unsigned long nstart, end, tmp, reqprot;
>  	struct vm_area_struct *vma, *prev;
> @@ -409,7 +412,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
>  
>  	for (nstart = start ; ; ) {
>  		unsigned long newflags;
> -		int pkey = arch_override_mprotect_pkey(vma, prot, -1);
> +		int new_vma_pkey;
>  
>  		/* Here we know that vma->vm_start <= nstart < vma->vm_end. */
>  
> @@ -417,7 +420,8 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
>  		if (rier && (vma->vm_flags & VM_MAYEXEC))
>  			prot |= PROT_EXEC;
>  
> -		newflags = calc_vm_prot_bits(prot, pkey);
> +		new_vma_pkey = arch_override_mprotect_pkey(vma, prot, pkey);
> +		newflags = calc_vm_prot_bits(prot, new_vma_pkey);
>  		newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
>  

On CPUs that do not support the feature, arch_override_mprotect_pkey
returns 0 and the normal protections are used. It's not clear how an
application is meant to detect if the operation succeeded or not. What
if the application relies on pkeys to be working?

Should pkey_mprotect return ENOSYS if the CPU does not support the
requested feature or is that handled somewhere else?

>  		/* newflags >> 4 shift VM_MAY% in place of VM_% */
> @@ -454,3 +458,18 @@ out:
>  	up_write(&current->mm->mmap_sem);
>  	return error;
>  }
> +
> +SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
> +		unsigned long, prot)
> +{
> +	return do_mprotect_pkey(start, len, prot, -1);
> +}
> +
> +SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
> +		unsigned long, prot, int, pkey)
> +{
> +	if (!validate_pkey(pkey))
> +		return -EINVAL;
> +
> +	return do_mprotect_pkey(start, len, prot, pkey);
> +}
> _

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
