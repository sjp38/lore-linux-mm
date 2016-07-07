Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D99896B025F
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 10:40:20 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a4so12627555lfa.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 07:40:20 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id c11si756171wmi.99.2016.07.07.07.40.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 07:40:19 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id C94941C168B
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 15:40:18 +0100 (IST)
Date: Thu, 7 Jul 2016 15:40:17 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 5/9] x86, pkeys: allocation/free syscalls
Message-ID: <20160707144017.GW11498@techsingularity.net>
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124727.62F2BEE0@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707124727.62F2BEE0@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk

On Thu, Jul 07, 2016 at 05:47:27AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This patch adds two new system calls:
> 
> 	int pkey_alloc(unsigned long flags, unsigned long init_access_rights)
> 	int pkey_free(int pkey);
> 
> These implement an "allocator" for the protection keys
> themselves, which can be thought of as analogous to the allocator
> that the kernel has for file descriptors.  The kernel tracks
> which numbers are in use, and only allows operations on keys that
> are valid.  A key which was not obtained by pkey_alloc() may not,
> for instance, be passed to pkey_mprotect() (or the forthcoming
> get/set syscalls).
> 

Ok, so the last patch wired up the system call before the kernel was
tracking which numbers were in use. It doesn't really matter as such but
the patches should be swapped around and only expose the systemcall when
it's actually safe.

> These system calls are also very important given the kernel's use
> of pkeys to implement execute-only support.  These help ensure
> that userspace can never assume that it has control of a key
> unless it first asks the kernel.
> 
> The 'init_access_rights' argument to pkey_alloc() specifies the
> rights that will be established for the returned pkey.  For
> instance:
> 
> 	pkey = pkey_alloc(flags, PKEY_DENY_WRITE);
> 
> will allocate 'pkey', but also sets the bits in PKRU[1] such that
> writing to 'pkey' is already denied.  This keeps userspace from
> needing to have knowledge about manipulating PKRU with the
> RDPKRU/WRPKRU instructions.  Userspace is still free to use these
> instructions as it wishes, but this facility ensures it is no
> longer required.
> 
> The kernel does _not_ enforce that this interface must be used for
> changes to PKRU, even for keys it does not control.
> 
> The kernel does not prevent pkey_free() from successfully freeing
> in-use pkeys (those still assigned to a memory range by
> pkey_mprotect()).  It would be expensive to implement the checks
> for this, so we instead say, "Just don't do it" since sane
> software will never do it anyway.
> 

Unfortunately, it could manifest as either corruption due to an area
expected to be protected being accessible or an unexpected SEGV.

I accept the expensive arguement but it opens a new class of problems
that userspace debuggers will need to evaluate.

> diff -puN arch/x86/include/asm/mmu_context.h~pkeys-116-syscalls-allocation arch/x86/include/asm/mmu_context.h
> --- a/arch/x86/include/asm/mmu_context.h~pkeys-116-syscalls-allocation	2016-07-07 05:47:01.435831049 -0700
> +++ b/arch/x86/include/asm/mmu_context.h	2016-07-07 05:47:01.454831911 -0700
> @@ -108,7 +108,16 @@ static inline void enter_lazy_tlb(struct
>  static inline int init_new_context(struct task_struct *tsk,
>  				   struct mm_struct *mm)
>  {
> +	#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> +	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
> +		/* pkey 0 is the default and always allocated */
> +		mm->context.pkey_allocation_map = 0x1;
> +		/* -1 means unallocated or invalid */
> +		mm->context.execute_only_pkey = -1;
> +	}
> +	#endif
>  	init_new_context_ldt(tsk, mm);
> +
>  	return 0;
>  }
>  static inline void destroy_context(struct mm_struct *mm)

I prevents userspace modifying the default key from userspace with WRPKRU
or an unallocated key for that matter.  However, I also cannot find a case
where it really matters. An application screwing it up may ask mprotect
to do something very unexpected but that's about it.

> +static inline
> +bool mm_pkey_is_allocated(struct mm_struct *mm, unsigned long pkey)
> +{
> +	if (!validate_pkey(pkey))
> +		return true;
> +
> +	return mm_pkey_allocation_map(mm) & (1 << pkey);
> +}
> +

We flip-flop between whether pkey is signed or unsigned.

> +SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
> +{
> +	int pkey;
> +	int ret;
> +
> +	/* No flags supported yet. */
> +	if (flags)
> +		return -EINVAL;
> +	/* check for unsupported init values */
> +	if (init_val & ~PKEY_ACCESS_MASK)
> +		return -EINVAL;
> +
> +	down_write(&current->mm->mmap_sem);
> +	pkey = mm_pkey_alloc(current->mm);
> +
> +	ret = -ENOSPC;
> +	if (pkey == -1)
> +		goto out;
> +
> +	ret = arch_set_user_pkey_access(current, pkey, init_val);
> +	if (ret) {
> +		mm_pkey_free(current->mm, pkey);
> +		goto out;
> +	}
> +	ret = pkey;
> +out:
> +	up_write(&current->mm->mmap_sem);
> +	return ret;
> +}

It's not wrong as such but mmap_sem taken for write seems *extremely*
heavy to protect the allocation mask. If userspace is racing a key
allocation with mprotect, it's already game over in terms of random
behaviour.

I've no idea what the frequency of pkey alloc/free is expected to be. If
it's really low then maybe it doesn't matter but if it's high this is
going to be a bottleneck later.

> +
> +SYSCALL_DEFINE1(pkey_free, int, pkey)
> +{
> +	int ret;
> +
> +	down_write(&current->mm->mmap_sem);
> +	ret = mm_pkey_free(current->mm, pkey);
> +	up_write(&current->mm->mmap_sem);
> +
> +	/*
> +	 * We could provie warnings or errors if any VMA still
> +	 * has the pkey set here.
> +	 */
> +	return ret;
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
