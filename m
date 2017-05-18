Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA2A6B0038
	for <linux-mm@kvack.org>; Thu, 18 May 2017 01:21:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b74so24708178pfd.2
        for <linux-mm@kvack.org>; Wed, 17 May 2017 22:21:13 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id h1si4136292plh.157.2017.05.17.22.21.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 May 2017 22:21:12 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v3 2/2] powerpc/mm/hugetlb: Add support for 1G huge pages
In-Reply-To: <1494995292-4443-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1494995292-4443-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1494995292-4443-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Thu, 18 May 2017 15:21:09 +1000
Message-ID: <87fug2loze.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> POWER9 supports hugepages of size 2M and 1G in radix MMU mode. This patch
> enables the usage of 1G page size for hugetlbfs. This also update the helper
> such we can do 1G page allocation at runtime.
>
> We still don't enable 1G page size on DD1 version. This is to avoid doing
> workaround mentioned in commit: 6d3a0379ebdc8 (powerpc/mm: Add
> radix__tlb_flush_pte_p9_dd1()
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/hugetlb.h | 10 ++++++++++
>  arch/powerpc/mm/hugetlbpage.c                |  7 +++++--
>  arch/powerpc/platforms/Kconfig.cputype       |  1 +
>  3 files changed, 16 insertions(+), 2 deletions(-)

I think this patch is OK, but it's very confusing because it doesn't
mention that it's only talking about *generic* gigantic page support.

We have existing support for gigantic pages on powerpc, on several
platforms. This patch appears to break that, but I think doesn't in
practice?

So can you make it a bit clearer in the commit message, and the code,
that this is only about enabling the generic gigantic page support, and
is unrelated to the arch-specific gigantic page support.

cheers

> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> index 6666cd366596..5c28bd6f2ae1 100644
> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> @@ -50,4 +50,14 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>  	else
>  		return entry;
>  }
> +
> +#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> +static inline bool gigantic_page_supported(void)
> +{
> +	if (radix_enabled())
> +		return true;
> +	return false;
> +}
> +#endif
> +
>  #endif
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index a4f33de4008e..80f6d2ed551a 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -763,8 +763,11 @@ static int __init add_huge_page_size(unsigned long long size)
>  	 * Hash: 16M and 16G
>  	 */
>  	if (radix_enabled()) {
> -		if (mmu_psize != MMU_PAGE_2M)
> -			return -EINVAL;
> +		if (mmu_psize != MMU_PAGE_2M) {
> +			if (cpu_has_feature(CPU_FTR_POWER9_DD1) ||
> +			    (mmu_psize != MMU_PAGE_1G))
> +				return -EINVAL;
> +		}
>  	} else {
>  		if (mmu_psize != MMU_PAGE_16M && mmu_psize != MMU_PAGE_16G)
>  			return -EINVAL;
> diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
> index 684e886eaae4..b76ef6637016 100644
> --- a/arch/powerpc/platforms/Kconfig.cputype
> +++ b/arch/powerpc/platforms/Kconfig.cputype
> @@ -344,6 +344,7 @@ config PPC_STD_MMU_64
>  config PPC_RADIX_MMU
>  	bool "Radix MMU Support"
>  	depends on PPC_BOOK3S_64
> +	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
>  	default y
>  	help
>  	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
