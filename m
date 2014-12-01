Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7F66B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 19:48:15 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id x19so5385858ier.6
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 16:48:15 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id l7si19318914igx.31.2014.12.01.16.48.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 01 Dec 2014 16:48:13 -0800 (PST)
Message-ID: <1417473519.7182.6.camel@kernel.crashing.org>
Subject: Re: [PATCH 02/10] mm: Add p[te|md] protnone helpers for use by NUMA
 balancing
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 02 Dec 2014 09:38:39 +1100
In-Reply-To: <1416578268-19597-3-git-send-email-mgorman@suse.de>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de>
	 <1416578268-19597-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, 2014-11-21 at 13:57 +0000, Mel Gorman wrote:

>  #ifdef CONFIG_NUMA_BALANCING
> +/*
> + * These work without NUMA balancing but the kernel does not care. See the
> + * comment in include/asm-generic/pgtable.h
> + */
> +static inline int pte_protnone(pte_t pte)
> +{
> +	return (pte_val(pte) &
> +		(_PAGE_PRESENT | _PAGE_USER)) == _PAGE_PRESENT;
> +}

I would add a comment clarifying that this only works for user pages,
ie, this accessor will always return "true" for a kernel page on ppc.

> +static inline int pmd_protnone(pmd_t pmd)
> +{
> +	return pte_protnone(pmd_pte(pmd));
> +}
> +
>  static inline int pte_present(pte_t pte)
>  {
>  	return pte_val(pte) & _PAGE_NUMA_MASK;
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 081d6f4..2e25780 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -502,6 +502,22 @@ static inline int pmd_present(pmd_t pmd)
>  				 _PAGE_NUMA);
>  }
>  
> +#ifdef CONFIG_NUMA_BALANCING
> +/*
> + * These work without NUMA balancing but the kernel does not care. See the
> + * comment in include/asm-generic/pgtable.h
> + */
> +static inline int pte_protnone(pte_t pte)
> +{
> +	return pte_flags(pte) & _PAGE_PROTNONE;
> +}
> +
> +static inline int pmd_protnone(pmd_t pmd)
> +{
> +	return pmd_flags(pmd) & _PAGE_PROTNONE;
> +}
> +#endif /* CONFIG_NUMA_BALANCING */
> +
>  static inline int pmd_none(pmd_t pmd)
>  {
>  	/* Only check low word on 32-bit platforms, since it might be
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 177d597..d497d08 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -688,6 +688,26 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
>  #endif
>  }
>  
> +#ifndef CONFIG_NUMA_BALANCING
> +/*
> + * Technically a PTE can be PROTNONE even when not doing NUMA balancing but
> + * the only case the kernel cares is for NUMA balancing and is only ever set
> + * when the VMA is accessible. For PROT_NONE VMAs, the PTEs are not marked
> + * _PAGE_PROTNONE so by by default, implement the helper as "always no". It
> + * is the responsibility of the caller to distinguish between PROT_NONE
> + * protections and NUMA hinting fault protections.
> + */
> +static inline int pte_protnone(pte_t pte)
> +{
> +	return 0;
> +}
> +
> +static inline int pmd_protnone(pmd_t pmd)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_NUMA_BALANCING */
> +
>  #ifdef CONFIG_NUMA_BALANCING
>  /*
>   * _PAGE_NUMA distinguishes between an unmapped page table entry, an entry that


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
