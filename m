Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 540A96B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:51:55 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so45598957pfa.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 09:51:55 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id tv9si4963453pac.85.2016.07.07.09.51.54
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 09:51:54 -0700 (PDT)
Subject: Re: [PATCH 2/9] mm: implement new pkey_mprotect() system call
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124722.DE1EE343@viggo.jf.intel.com>
 <20160707144031.GY11498@techsingularity.net>
From: Dave Hansen <dave@sr71.net>
Message-ID: <577E88A8.8030909@sr71.net>
Date: Thu, 7 Jul 2016 09:51:52 -0700
MIME-Version: 1.0
In-Reply-To: <20160707144031.GY11498@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk

On 07/07/2016 07:40 AM, Mel Gorman wrote:
> On Thu, Jul 07, 2016 at 05:47:22AM -0700, Dave Hansen wrote:
>> +#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
>>  static inline int vma_pkey(struct vm_area_struct *vma)
>>  {
>> -	u16 pkey = 0;
>> -#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
>>  	unsigned long vma_pkey_mask = VM_PKEY_BIT0 | VM_PKEY_BIT1 |
>>  				      VM_PKEY_BIT2 | VM_PKEY_BIT3;
>> -	pkey = (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
>> -#endif
>> -	return pkey;
>> +
>> +	return (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
>> +}
>> +#else
>> +static inline int vma_pkey(struct vm_area_struct *vma)
>> +{
>> +	return 0;
>>  }
>> +#endif
>>  
>>  static inline bool __pkru_allows_pkey(u16 pkey, bool write)
>>  {
> 
> Looks like MASK could have been statically defined and be a simple shift
> and mask known at compile time. Minor though.

The VM_PKEY_BIT*'s are only ever defined as masks and not bit numbers.
So, if you want to use a mask, you end up doing something like:

	unsigned long mask = (NR_PKEYS-1) << ffz(~VM_PKEY_BIT0);

Which ends up with the same thing, but I think ends up being pretty on
par for ugliness.

...
>> +/*
>> + * When setting a userspace-provided value, we need to ensure
>> + * that it is valid.  The __ version can get used by
>> + * kernel-internal uses like the execute-only support.
>> + */
>> +int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
>> +		unsigned long init_val)
>> +{
>> +	if (!validate_pkey(pkey))
>> +		return -EINVAL;
>> +	return __arch_set_user_pkey_access(tsk, pkey, init_val);
>> +}
> 
> There appears to be a subtle bug fixed for validate_key. It appears
> there wasn't protection of the dedicated key before but nothing could
> reach it.

Right.  There was no user interface that took a key and we trusted that
the kernel knew what it was doing.

> The arch_max_pkey and PKEY_DEDICATE_EXECUTE_ONLY interaction is subtle
> but I can't find a problem with it either.
> 
> That aside, the validate_pkey check looks weak. It might be a number
> that works but no guarantee it's an allocated key or initialised
> properly. At this point, garbage can be handed into the system call
> potentially but maybe that gets fixed later.

It's called in three paths:
1. by the kernel when setting up execute-only support
2. by pkey_alloc() on the pkey we just allocated
3. by pkey_set() on a pkey we just checked was allocated

So, it isn't broken, but it's also not clear at all why it is safe and
what validate_pkey() is actually validating.

But, that said, this does make me realize that with
pkey_alloc()/pkey_free(), this is probably redundant.  We verify that
the key is allocated, and we only allow valid keys to be allocated.

IOW, I think I can remove validate_pkey(), but only if we keep pkey_alloc().

...
>> -		newflags = calc_vm_prot_bits(prot, pkey);
>> +		new_vma_pkey = arch_override_mprotect_pkey(vma, prot, pkey);
>> +		newflags = calc_vm_prot_bits(prot, new_vma_pkey);
>>  		newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
>>  
> 
> On CPUs that do not support the feature, arch_override_mprotect_pkey
> returns 0 and the normal protections are used. It's not clear how an
> application is meant to detect if the operation succeeded or not. What
> if the application relies on pkeys to be working?

It actually shows up as -ENOSPC from pkey_alloc().  This sounds goofy,
but it teaches programs something very important: they always have to
look for ENOSPC, and must always be prepared to function without
protection keys.  A library might have stolen all the keys, or an
LD_PRELOAD, so an app can never be sure what is available.

If we teach them to check for ENOSPC from day one, they'll never be
surprised.

I've tried to spell this out a bit more clearly in the manpages.  I'll
also add it to the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
