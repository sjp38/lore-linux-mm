Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3719B8E0001
	for <linux-mm@kvack.org>; Sat, 15 Sep 2018 14:50:14 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id e6-v6so2453476ljl.9
        for <linux-mm@kvack.org>; Sat, 15 Sep 2018 11:50:14 -0700 (PDT)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500::47])
        by mx.google.com with ESMTP id z5-v6si13042991lfj.6.2018.09.15.11.50.12
        for <linux-mm@kvack.org>;
        Sat, 15 Sep 2018 11:50:12 -0700 (PDT)
Date: Sat, 15 Sep 2018 21:50:09 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: [PATCH] Revert "x86/mm/legacy: Populate the user page-table with
 user pgd's"
In-Reply-To: <1536922754-31379-1-git-send-email-joro@8bytes.org>
Message-ID: <alpine.LRH.2.21.1809152128450.21274@math.ut.ee>
References: <1536922754-31379-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bp@alien8.de>, Andrea Arcangeli <aarcange@redhat.com>, Joerg Roedel <jroedel@suse.de>

It works as expected - when PAE is off, PTI can not be selected, and 
with PAE on, it can be selected and seems to work.

> Reported-by: Meelis Roos <mroos@linux.ee>

Tested-by: Meelis Roos <mroos@linux.ee>

> Fixes: 7757d607c6b3 ('x86/pti: Allow CONFIG_PAGE_TABLE_ISOLATION for x86_32')
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/include/asm/pgtable-2level.h | 9 ---------
>  security/Kconfig                      | 2 +-
>  2 files changed, 1 insertion(+), 10 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
> index 24c6cf5f16b7..60d0f9015317 100644
> --- a/arch/x86/include/asm/pgtable-2level.h
> +++ b/arch/x86/include/asm/pgtable-2level.h
> @@ -19,9 +19,6 @@ static inline void native_set_pte(pte_t *ptep , pte_t pte)
>  
>  static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
>  {
> -#ifdef CONFIG_PAGE_TABLE_ISOLATION
> -	pmd.pud.p4d.pgd = pti_set_user_pgtbl(&pmdp->pud.p4d.pgd, pmd.pud.p4d.pgd);
> -#endif
>  	*pmdp = pmd;
>  }
>  
> @@ -61,9 +58,6 @@ static inline pte_t native_ptep_get_and_clear(pte_t *xp)
>  #ifdef CONFIG_SMP
>  static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
>  {
> -#ifdef CONFIG_PAGE_TABLE_ISOLATION
> -	pti_set_user_pgtbl(&xp->pud.p4d.pgd, __pgd(0));
> -#endif
>  	return __pmd(xchg((pmdval_t *)xp, 0));
>  }
>  #else
> @@ -73,9 +67,6 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
>  #ifdef CONFIG_SMP
>  static inline pud_t native_pudp_get_and_clear(pud_t *xp)
>  {
> -#ifdef CONFIG_PAGE_TABLE_ISOLATION
> -	pti_set_user_pgtbl(&xp->p4d.pgd, __pgd(0));
> -#endif
>  	return __pud(xchg((pudval_t *)xp, 0));
>  }
>  #else
> diff --git a/security/Kconfig b/security/Kconfig
> index 27d8b2688f75..d9aa521b5206 100644
> --- a/security/Kconfig
> +++ b/security/Kconfig
> @@ -57,7 +57,7 @@ config SECURITY_NETWORK
>  config PAGE_TABLE_ISOLATION
>  	bool "Remove the kernel mapping in user mode"
>  	default y
> -	depends on X86 && !UML
> +	depends on (X86_64 || X86_PAE) && !UML
>  	help
>  	  This feature reduces the number of hardware side channels by
>  	  ensuring that the majority of kernel addresses are not mapped
> 

-- 
Meelis Roos (mroos@ut.ee)      http://www.cs.ut.ee/~mroos/
