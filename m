Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 649486B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 13:48:54 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i205-v6so9184920ita.3
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 10:48:54 -0700 (PDT)
Received: from mailout.easymail.ca (mailout.easymail.ca. [64.68.200.34])
        by mx.google.com with ESMTPS id e124si4378834ioa.235.2018.03.26.10.48.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 10:48:53 -0700 (PDT)
Subject: Re: [PATCH 1/9] x86, pkeys: do not special case protection key 0
References: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
 <20180326172722.8CC08307@viggo.jf.intel.com>
From: Shuah Khan <shuah@kernel.org>
Message-ID: <9c2de5f6-d9e2-3647-7aa8-86102e9fa6c3@kernel.org>
Date: Mon, 26 Mar 2018 11:47:26 -0600
MIME-Version: 1.0
In-Reply-To: <20180326172722.8CC08307@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, stable@kernel.org, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, Shuah Khan <shuahkh@osg.samsung.com>, Shuah Khan <shuah@kernel.org>

On 03/26/2018 11:27 AM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> mm_pkey_is_allocated() treats pkey 0 as unallocated.  That is
> inconsistent with the manpages, and also inconsistent with
> mm->context.pkey_allocation_map.  Stop special casing it and only
> disallow values that are actually bad (< 0).
> 
> The end-user visible effect of this is that you can now use
> mprotect_pkey() to set pkey=0.
> 
> This is a bit nicer than what Ram proposed because it is simpler
> and removes special-casing for pkey 0.  On the other hand, it does
> allow applciations to pkey_free() pkey-0, but that's just a silly

applications - typo.

> thing to do, so we are not going to protect against it.

If you plan to compare proposals, it would be nicer to include the
details of what Ram proposed as well in the commit log or link to the
discussion.

Also what happens "pkey_free() pkey-0" - can you elaborate more on that
"silliness consequences"

> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Fixes: 58ab9a088dda ("x86/pkeys: Check against max pkey to avoid overflows")
> Cc: stable@kernel.org
> Cc: Ram Pai <linuxram@us.ibm.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Michael Ellermen <mpe@ellerman.id.au>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>p
> Cc: Shuah Khan <shuah@kernel.org>
> ---
> 
>  b/arch/x86/include/asm/mmu_context.h |    2 +-
>  b/arch/x86/include/asm/pkeys.h       |    6 +++---
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff -puN arch/x86/include/asm/mmu_context.h~x86-pkey-0-default-allocated arch/x86/include/asm/mmu_context.h
> --- a/arch/x86/include/asm/mmu_context.h~x86-pkey-0-default-allocated	2018-03-26 10:22:33.742170197 -0700
> +++ b/arch/x86/include/asm/mmu_context.h	2018-03-26 10:22:33.747170197 -0700
> @@ -192,7 +192,7 @@ static inline int init_new_context(struc
>  
>  #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
>  	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
> -		/* pkey 0 is the default and always allocated */
> +		/* pkey 0 is the default and allocated implicitly */
>  		mm->context.pkey_allocation_map = 0x1;
>  		/* -1 means unallocated or invalid */
>  		mm->context.execute_only_pkey = -1;
> diff -puN arch/x86/include/asm/pkeys.h~x86-pkey-0-default-allocated arch/x86/include/asm/pkeys.h
> --- a/arch/x86/include/asm/pkeys.h~x86-pkey-0-default-allocated	2018-03-26 10:22:33.744170197 -0700
> +++ b/arch/x86/include/asm/pkeys.h	2018-03-26 10:22:33.747170197 -0700
> @@ -49,10 +49,10 @@ bool mm_pkey_is_allocated(struct mm_stru
>  {
>  	/*
>  	 * "Allocated" pkeys are those that have been returned
> -	 * from pkey_alloc().  pkey 0 is special, and never
> -	 * returned from pkey_alloc().
> +	 * from pkey_alloc() or pkey 0 which is allocated
> +	 * implicitly when the mm is created.
>  	 */
> -	if (pkey <= 0)
> +	if (pkey < 0)
>  		return false;
>  	if (pkey >= arch_max_pkey())
>  		return false;
> _
> 

thanks,
-- Shuah
