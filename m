Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1B76B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 20:09:57 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o8so1576744wra.12
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 17:09:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f8si3264231edn.543.2018.04.06.17.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 17:09:55 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3709oBE049346
	for <linux-mm@kvack.org>; Fri, 6 Apr 2018 20:09:54 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h6fhuycu9-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 06 Apr 2018 20:09:53 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 7 Apr 2018 01:09:52 +0100
Date: Fri, 6 Apr 2018 17:09:43 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from
 PROT_EXEC
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
 <20180326172727.025EBF16@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180326172727.025EBF16@viggo.jf.intel.com>
Message-Id: <20180407000943.GA15890@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, shakeelb@google.com, stable@kernel.org, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On Mon, Mar 26, 2018 at 10:27:27AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> I got a bug report that the following code (roughly) was
> causing a SIGSEGV:
> 
> 	mprotect(ptr, size, PROT_EXEC);
> 	mprotect(ptr, size, PROT_NONE);
> 	mprotect(ptr, size, PROT_READ);
> 	*ptr = 100;
> 
> The problem is hit when the mprotect(PROT_EXEC)
> is implicitly assigned a protection key to the VMA, and made
> that key ACCESS_DENY|WRITE_DENY.  The PROT_NONE mprotect()
> failed to remove the protection key, and the PROT_NONE->
> PROT_READ left the PTE usable, but the pkey still in place
> and left the memory inaccessible.
> 
> To fix this, we ensure that we always "override" the pkee
> at mprotect() if the VMA does not have execute-only
> permissions, but the VMA has the execute-only pkey.
> 
> We had a check for PROT_READ/WRITE, but it did not work
> for PROT_NONE.  This entirely removes the PROT_* checks,
> which ensures that PROT_NONE now works.
> 
> Reported-by: Shakeel Butt <shakeelb@google.com>
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Fixes: 62b5f7d013f ("mm/core, x86/mm/pkeys: Add execute-only protection keys support")
> Cc: stable@kernel.org
> Cc: Ram Pai <linuxram@us.ibm.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Michael Ellermen <mpe@ellerman.id.au>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Shuah Khan <shuah@kernel.org>
> ---
> 
>  b/arch/x86/include/asm/pkeys.h |   12 +++++++++++-
>  b/arch/x86/mm/pkeys.c          |   19 ++++++++++---------
>  2 files changed, 21 insertions(+), 10 deletions(-)
> 
> diff -puN arch/x86/include/asm/pkeys.h~pkeys-abandon-exec-only-pkey-more-aggressively arch/x86/include/asm/pkeys.h
> --- a/arch/x86/include/asm/pkeys.h~pkeys-abandon-exec-only-pkey-more-aggressively	2018-03-26 10:22:35.380170193 -0700
> +++ b/arch/x86/include/asm/pkeys.h	2018-03-26 10:22:35.385170193 -0700
> @@ -2,6 +2,8 @@
>  #ifndef _ASM_X86_PKEYS_H
>  #define _ASM_X86_PKEYS_H
> 
> +#define ARCH_DEFAULT_PKEY	0
> +
>  #define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? 16 : 1)
> 
>  extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
> @@ -15,7 +17,7 @@ extern int __execute_only_pkey(struct mm
>  static inline int execute_only_pkey(struct mm_struct *mm)
>  {
>  	if (!boot_cpu_has(X86_FEATURE_OSPKE))
> -		return 0;
> +		return ARCH_DEFAULT_PKEY;
> 
>  	return __execute_only_pkey(mm);
>  }
> @@ -56,6 +58,14 @@ bool mm_pkey_is_allocated(struct mm_stru
>  		return false;
>  	if (pkey >= arch_max_pkey())
>  		return false;
> +	/*
> +	 * The exec-only pkey is set in the allocation map, but
> +	 * is not available to any of the user interfaces like
> +	 * mprotect_pkey().
> +	 */
> +	if (pkey == mm->context.execute_only_pkey)
> +		return false;
> +
>  	return mm_pkey_allocation_map(mm) & (1U << pkey);
>  }
> 
> diff -puN arch/x86/mm/pkeys.c~pkeys-abandon-exec-only-pkey-more-aggressively arch/x86/mm/pkeys.c
> --- a/arch/x86/mm/pkeys.c~pkeys-abandon-exec-only-pkey-more-aggressively	2018-03-26 10:22:35.381170193 -0700
> +++ b/arch/x86/mm/pkeys.c	2018-03-26 10:22:35.385170193 -0700
> @@ -94,15 +94,7 @@ int __arch_override_mprotect_pkey(struct
>  	 */
>  	if (pkey != -1)
>  		return pkey;
> -	/*
> -	 * Look for a protection-key-drive execute-only mapping
> -	 * which is now being given permissions that are not
> -	 * execute-only.  Move it back to the default pkey.
> -	 */
> -	if (vma_is_pkey_exec_only(vma) &&
> -	    (prot & (PROT_READ|PROT_WRITE))) {
> -		return 0;
> -	}
> +

Dave,
	this can be simply:

	if ((vma_is_pkey_exec_only(vma) && (prot != PROT_EXEC))
		return ARCH_DEFAULT_PKEY;

No?
RP
