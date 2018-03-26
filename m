Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E0F256B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 13:35:38 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t125so3541764wmt.3
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 10:35:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l64si4495205ede.545.2018.03.26.10.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 10:35:37 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2QHV3L9083866
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 13:35:36 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gy2r1qqu0-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 13:35:35 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 26 Mar 2018 18:35:32 +0100
Date: Mon, 26 Mar 2018 10:35:23 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH 1/9] x86, pkeys: do not special case protection key 0
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180323180903.33B17168@viggo.jf.intel.com>
 <20180323180905.B40984E6@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180323180905.B40984E6@viggo.jf.intel.com>
Message-Id: <20180326173522.GB5743@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On Fri, Mar 23, 2018 at 11:09:05AM -0700, Dave Hansen wrote:
> 
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
> thing to do, so we are not going to protect against it.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
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
> --- a/arch/x86/include/asm/mmu_context.h~x86-pkey-0-default-allocated	2018-03-21 15:47:48.182198927 -0700
> +++ b/arch/x86/include/asm/mmu_context.h	2018-03-21 15:47:48.187198927 -0700
> @@ -192,7 +192,7 @@ static inline int init_new_context(struc
> 
>  #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
>  	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
> -		/* pkey 0 is the default and always allocated */
> +		/* pkey 0 is the default and allocated implicitly */
>  		mm->context.pkey_allocation_map = 0x1;

In the second patch, you introduce DEFAULT_KEY. Maybe you 
should introduce here and express the above code as

		mm->context.pkey_allocation_map = (0x1 << DEFAULT_KEY);

Incase your default key changes to something else, you are still good.

>  		/* -1 means unallocated or invalid */
>  		mm->context.execute_only_pkey = -1;
> diff -puN arch/x86/include/asm/pkeys.h~x86-pkey-0-default-allocated arch/x86/include/asm/pkeys.h
> --- a/arch/x86/include/asm/pkeys.h~x86-pkey-0-default-allocated	2018-03-21 15:47:48.184198927 -0700
> +++ b/arch/x86/include/asm/pkeys.h	2018-03-21 15:47:48.188198927 -0700
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

-- 
Ram Pai
