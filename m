Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB9B6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 11:38:29 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ib6so31897579pad.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 08:38:29 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id v76si4759232pfa.20.2016.07.07.08.38.27
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 08:38:28 -0700 (PDT)
Subject: Re: [PATCH 5/9] x86, pkeys: allocation/free syscalls
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124727.62F2BEE0@viggo.jf.intel.com>
 <20160707144017.GW11498@techsingularity.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <577E7762.1010003@intel.com>
Date: Thu, 7 Jul 2016 08:38:10 -0700
MIME-Version: 1.0
In-Reply-To: <20160707144017.GW11498@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk

On 07/07/2016 07:40 AM, Mel Gorman wrote:
> Ok, so the last patch wired up the system call before the kernel was
> tracking which numbers were in use. It doesn't really matter as such but
> the patches should be swapped around and only expose the systemcall when
> it's actually safe.

I can do that.

>> These system calls are also very important given the kernel's use
>> of pkeys to implement execute-only support.  These help ensure
>> that userspace can never assume that it has control of a key
>> unless it first asks the kernel.
>>
>> The 'init_access_rights' argument to pkey_alloc() specifies the
>> rights that will be established for the returned pkey.  For
>> instance:
>>
>> 	pkey = pkey_alloc(flags, PKEY_DENY_WRITE);
>>
>> will allocate 'pkey', but also sets the bits in PKRU[1] such that
>> writing to 'pkey' is already denied.  This keeps userspace from
>> needing to have knowledge about manipulating PKRU with the
>> RDPKRU/WRPKRU instructions.  Userspace is still free to use these
>> instructions as it wishes, but this facility ensures it is no
>> longer required.
>>
>> The kernel does _not_ enforce that this interface must be used for
>> changes to PKRU, even for keys it does not control.
>>
>> The kernel does not prevent pkey_free() from successfully freeing
>> in-use pkeys (those still assigned to a memory range by
>> pkey_mprotect()).  It would be expensive to implement the checks
>> for this, so we instead say, "Just don't do it" since sane
>> software will never do it anyway.
> 
> Unfortunately, it could manifest as either corruption due to an area
> expected to be protected being accessible or an unexpected SEGV.
> 
> I accept the expensive arguement but it opens a new class of problems
> that userspace debuggers will need to evaluate.

Yeah.  I guess it would be good to have a debugging mechanism here at least.

>> +static inline
>> +bool mm_pkey_is_allocated(struct mm_struct *mm, unsigned long pkey)
>> +{
>> +	if (!validate_pkey(pkey))
>> +		return true;
>> +
>> +	return mm_pkey_allocation_map(mm) & (1 << pkey);
>> +}
>> +
> 
> We flip-flop between whether pkey is signed or unsigned.

Yeah, I can add some consistency here, for sure.

>> +SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
>> +{
>> +	int pkey;
>> +	int ret;
>> +
>> +	/* No flags supported yet. */
>> +	if (flags)
>> +		return -EINVAL;
>> +	/* check for unsupported init values */
>> +	if (init_val & ~PKEY_ACCESS_MASK)
>> +		return -EINVAL;
>> +
>> +	down_write(&current->mm->mmap_sem);
>> +	pkey = mm_pkey_alloc(current->mm);
>> +
>> +	ret = -ENOSPC;
>> +	if (pkey == -1)
>> +		goto out;
>> +
>> +	ret = arch_set_user_pkey_access(current, pkey, init_val);
>> +	if (ret) {
>> +		mm_pkey_free(current->mm, pkey);
>> +		goto out;
>> +	}
>> +	ret = pkey;
>> +out:
>> +	up_write(&current->mm->mmap_sem);
>> +	return ret;
>> +}
> 
> It's not wrong as such but mmap_sem taken for write seems *extremely*
> heavy to protect the allocation mask. If userspace is racing a key
> allocation with mprotect, it's already game over in terms of random
> behaviour.
> 
> I've no idea what the frequency of pkey alloc/free is expected to be. If
> it's really low then maybe it doesn't matter but if it's high this is
> going to be a bottleneck later.

I think pkey_alloc() is fundamentally less frequent than mprotect().  If
you're doing a pkey_alloc() it's because you want to set it on at least
one memory area, which means at least one mprotect().  So, at _worst_,
it's 1:1.  If you've got more than one thing you're protecting, you'll
have many mprotect()s for each pkey_alloc().

The real reason I did this, though, was to avoid having _some_ other
lock.  It'll cost more storage space, have more locking rules and I need
exclusion against pkey_mprotect() which already holds mmap_sem for
write.  IOW, I think this was the simplest thing to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
