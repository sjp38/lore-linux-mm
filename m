Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 899AD6B0005
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 10:54:41 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id b13so90941450pat.3
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 07:54:41 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id rz5si4520069pab.104.2016.07.08.07.54.38
        for <linux-mm@kvack.org>;
        Fri, 08 Jul 2016 07:54:38 -0700 (PDT)
Subject: Re: [RFC][PATCH] x86, pkeys: scalable pkey_set()/pkey_get()
References: <20160707230922.ED44A9DA@viggo.jf.intel.com>
 <20160708103526.GG11498@techsingularity.net>
From: Dave Hansen <dave@sr71.net>
Message-ID: <577FBEAC.9050500@sr71.net>
Date: Fri, 8 Jul 2016 07:54:36 -0700
MIME-Version: 1.0
In-Reply-To: <20160708103526.GG11498@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, mingo@kernel.org, dave.hansen@intel.com

On 07/08/2016 03:35 AM, Mel Gorman wrote:
> On Thu, Jul 07, 2016 at 04:09:22PM -0700, Dave Hansen wrote:
>>  b/arch/x86/include/asm/pkeys.h |   39 ++++++++++++++++++++++++++++++++++-----
>>  b/mm/mprotect.c                |    4 ----
>>  2 files changed, 34 insertions(+), 9 deletions(-)
>>
>> diff -puN mm/mprotect.c~pkeys-119-fast-set-get mm/mprotect.c
>> --- a/mm/mprotect.c~pkeys-119-fast-set-get	2016-07-07 12:25:49.582075153 -0700
>> +++ b/mm/mprotect.c	2016-07-07 12:42:50.516384977 -0700
>> @@ -542,10 +542,8 @@ SYSCALL_DEFINE2(pkey_get, int, pkey, uns
>>  	if (flags)
>>  		return -EINVAL;
>>  
>> -	down_write(&current->mm->mmap_sem);
>>  	if (!mm_pkey_is_allocated(current->mm, pkey))
>>  		ret = -EBADF;
>> -	up_write(&current->mm->mmap_sem);
>>  
>>  	if (ret)
>>  		return ret;
> 
> This does allow the possibility of
> 
> thread a	thread b
> pkey_get enter
> 		pkey_free
> 		pkey_alloc
> pkey_get leave
> 
> The kernel can tell if the key is allocated but not if it is the same
> allocation userspace expected or not. That's why I thought this may need
> to be a sequence counter. Unfortunately, now I realise that even that is
> insufficient because the seqcounter would only detect that something
> changed, it would have no idea if the pkey of interest was affected or
> not. It gets rapidly messy after that.
> 
> Userspace may have no choice other than to serialise itself but the
> documentation needs to be clear that the above race is possible.

Yeah, I'll clarify the documentation.  But, I do think this is one of
those races like an stat().  A stat() tells you that a file was once
there with so and so properties, but it does not mean that it is there
any more or that what _is_ there is the same thing you stat()'d.

>> diff -puN arch/x86/include/asm/pkeys.h~pkeys-119-fast-set-get arch/x86/include/asm/pkeys.h
>> --- a/arch/x86/include/asm/pkeys.h~pkeys-119-fast-set-get	2016-07-07 12:26:19.265421712 -0700
>> +++ b/arch/x86/include/asm/pkeys.h	2016-07-07 15:18:15.391642423 -0700
>> @@ -35,18 +35,47 @@ extern int __arch_set_user_pkey_access(s
>>  
>>  #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3)
>>  
>> +#define PKEY_MAP_SET	1
>> +#define PKEY_MAP_CLEAR	2
>>  #define mm_pkey_allocation_map(mm)	(mm->context.pkey_allocation_map)
>> -#define mm_set_pkey_allocated(mm, pkey) do {		\
>> -	mm_pkey_allocation_map(mm) |= (1U << pkey);	\
>> +static inline
>> +void mm_modify_pkey_alloc_map(struct mm_struct *mm, int pkey, int setclear)
>> +{
>> +	u16 new_map = mm_pkey_allocation_map(mm);
>> +	if (setclear == PKEY_MAP_SET)
>> +		new_map |= (1U << pkey);
>> +	else if (setclear == PKEY_MAP_CLEAR)
>> +		new_map &= ~(1U << pkey);
>> +	else
>> +		BUILD_BUG_ON(1);
>> +	/*
>> +	 * Make sure that mm_pkey_is_allocated() callers never
>> +	 * see intermediate states by using WRITE_ONCE().
>> +	 * Concurrent calls to this function are excluded by
>> +	 * down_write(mm->mmap_sem) so we only need to protect
>> +	 * against readers.
>> +	 */
>> +	WRITE_ONCE(mm_pkey_allocation_map(mm), new_map);
>> +}
> 
> What prevents two pkey_set operations overwriting each others change with
> WRITE_ONCE? Does this not need to be a cmpxchg read-modify-write loops?

pkey_set() only reads the allocation map and only writes to PKRU which
is thread-local.

The writers to the allocation map are pkey_alloc()/free() and those are
still mmap_sem-protected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
