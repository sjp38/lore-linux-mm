Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE1C828E1
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 06:35:30 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so27907329lfa.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 03:35:30 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id kz10si3684787wjb.243.2016.07.08.03.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 03:35:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 8E8A21C26DB
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 11:35:28 +0100 (IST)
Date: Fri, 8 Jul 2016 11:35:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC][PATCH] x86, pkeys: scalable pkey_set()/pkey_get()
Message-ID: <20160708103526.GG11498@techsingularity.net>
References: <20160707230922.ED44A9DA@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707230922.ED44A9DA@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, mingo@kernel.org, dave.hansen@intel.com

On Thu, Jul 07, 2016 at 04:09:22PM -0700, Dave Hansen wrote:
>  b/arch/x86/include/asm/pkeys.h |   39 ++++++++++++++++++++++++++++++++++-----
>  b/mm/mprotect.c                |    4 ----
>  2 files changed, 34 insertions(+), 9 deletions(-)
> 
> diff -puN mm/mprotect.c~pkeys-119-fast-set-get mm/mprotect.c
> --- a/mm/mprotect.c~pkeys-119-fast-set-get	2016-07-07 12:25:49.582075153 -0700
> +++ b/mm/mprotect.c	2016-07-07 12:42:50.516384977 -0700
> @@ -542,10 +542,8 @@ SYSCALL_DEFINE2(pkey_get, int, pkey, uns
>  	if (flags)
>  		return -EINVAL;
>  
> -	down_write(&current->mm->mmap_sem);
>  	if (!mm_pkey_is_allocated(current->mm, pkey))
>  		ret = -EBADF;
> -	up_write(&current->mm->mmap_sem);
>  
>  	if (ret)
>  		return ret;

This does allow the possibility of

thread a	thread b
pkey_get enter
		pkey_free
		pkey_alloc
pkey_get leave

The kernel can tell if the key is allocated but not if it is the same
allocation userspace expected or not. That's why I thought this may need
to be a sequence counter. Unfortunately, now I realise that even that is
insufficient because the seqcounter would only detect that something
changed, it would have no idea if the pkey of interest was affected or
not. It gets rapidly messy after that.

Userspace may have no choice other than to serialise itself but the
documentation needs to be clear that the above race is possible.

> diff -puN arch/x86/include/asm/pkeys.h~pkeys-119-fast-set-get arch/x86/include/asm/pkeys.h
> --- a/arch/x86/include/asm/pkeys.h~pkeys-119-fast-set-get	2016-07-07 12:26:19.265421712 -0700
> +++ b/arch/x86/include/asm/pkeys.h	2016-07-07 15:18:15.391642423 -0700
> @@ -35,18 +35,47 @@ extern int __arch_set_user_pkey_access(s
>  
>  #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3)
>  
> +#define PKEY_MAP_SET	1
> +#define PKEY_MAP_CLEAR	2
>  #define mm_pkey_allocation_map(mm)	(mm->context.pkey_allocation_map)
> -#define mm_set_pkey_allocated(mm, pkey) do {		\
> -	mm_pkey_allocation_map(mm) |= (1U << pkey);	\
> +static inline
> +void mm_modify_pkey_alloc_map(struct mm_struct *mm, int pkey, int setclear)
> +{
> +	u16 new_map = mm_pkey_allocation_map(mm);
> +	if (setclear == PKEY_MAP_SET)
> +		new_map |= (1U << pkey);
> +	else if (setclear == PKEY_MAP_CLEAR)
> +		new_map &= ~(1U << pkey);
> +	else
> +		BUILD_BUG_ON(1);
> +	/*
> +	 * Make sure that mm_pkey_is_allocated() callers never
> +	 * see intermediate states by using WRITE_ONCE().
> +	 * Concurrent calls to this function are excluded by
> +	 * down_write(mm->mmap_sem) so we only need to protect
> +	 * against readers.
> +	 */
> +	WRITE_ONCE(mm_pkey_allocation_map(mm), new_map);
> +}

What prevents two pkey_set operations overwriting each others change with
WRITE_ONCE? Does this not need to be a cmpxchg read-modify-write loops?


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
