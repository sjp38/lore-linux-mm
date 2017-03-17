Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE7926B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 03:22:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x63so120000630pfx.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 00:22:10 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 1si7737165pgl.232.2017.03.17.00.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 00:22:10 -0700 (PDT)
Subject: Re: [HMM 07/16] mm/migrate: new memory migration helper for use with
 device memory v4
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-8-git-send-email-jglisse@redhat.com>
 <20170316160520.d03ac02474cad6d2c8eba9bc@linux-foundation.org>
 <d4e8433d-4680-dced-4f11-2f3cc8ebc613@nvidia.com>
 <CAKTCnzmYob5uq11zkJE781BX9rDH9EYM7zxHH+ZMtTs4D5kkiQ@mail.gmail.com>
 <94e0d115-7deb-c748-3dc2-60d6289e6551@nvidia.com>
 <CAKTCnznV1D4iZcn-PWvfu92_NB-Ree=cOT3bKfuJSPSXVB_QAg@mail.gmail.com>
 <a8b67ed5-118c-6da5-1db6-6edf836f9230@gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <8c26baee-c681-a03d-4021-f9f92182e71f@nvidia.com>
Date: Fri, 17 Mar 2017 00:17:15 -0700
MIME-Version: 1.0
In-Reply-To: <a8b67ed5-118c-6da5-1db6-6edf836f9230@gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On 03/16/2017 09:51 PM, Balbir Singh wrote:
[...]
> So this is what I ended up with, a quick fix for the 32 bit
> build failures
>
> Date: Fri, 17 Mar 2017 15:42:52 +1100
> Subject: [PATCH] mm/hmm: Fix build on 32 bit systems
>
> Fix build breakage of hmm-v18 in the current mmotm by
> making the migrate_vma() and related functions 64
> bit only. The 32 bit variant will return -EINVAL.
> There are other approaches to solving this problem,
> but we can enable 32 bit systems as we need them.
>
> This patch tries to limit the impact on 32 bit systems
> by turning HMM off on them and not enabling the migrate
> functions.
>
> I've built this on ppc64/i386 and x86_64
>
> Signed-off-by: Balbir Singh <bsingharora@gmail.com>
> ---
>  include/linux/migrate.h | 18 +++++++++++++++++-
>  mm/Kconfig              |  4 +++-
>  mm/migrate.c            |  3 ++-
>  3 files changed, 22 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 01f4945..1888a70 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -124,7 +124,7 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  }
>  #endif /* CONFIG_NUMA_BALANCING && CONFIG_TRANSPARENT_HUGEPAGE*/
>
> -
> +#ifdef CONFIG_64BIT
>  #define MIGRATE_PFN_VALID	(1UL << (BITS_PER_LONG_LONG - 1))
>  #define MIGRATE_PFN_MIGRATE	(1UL << (BITS_PER_LONG_LONG - 2))
>  #define MIGRATE_PFN_HUGE	(1UL << (BITS_PER_LONG_LONG - 3))

As long as we're getting this accurate, should we make that 1ULL, in all of the 
MIGRATE_PFN_* defines? The 1ULL is what determines the type of the resulting number, 
so it's one more tiny piece of type correctness that is good to have.

The rest of this fix looks good, and the above is not technically necessary (the 
code that uses it will force its own type anyway), so:

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks
John Hubbard
NVIDIA

> @@ -145,6 +145,7 @@ static inline unsigned long migrate_pfn_size(unsigned long mpfn)
>  {
>  	return mpfn & MIGRATE_PFN_HUGE ? PMD_SIZE : PAGE_SIZE;
>  }
> +#endif
>
>  /*
>   * struct migrate_vma_ops - migrate operation callback
> @@ -194,6 +195,7 @@ struct migrate_vma_ops {
>  				 void *private);
>  };
>
> +#ifdef CONFIG_64BIT
>  int migrate_vma(const struct migrate_vma_ops *ops,
>  		struct vm_area_struct *vma,
>  		unsigned long mentries,
> @@ -202,5 +204,19 @@ int migrate_vma(const struct migrate_vma_ops *ops,
>  		unsigned long *src,
>  		unsigned long *dst,
>  		void *private);
> +#else
> +static inline int migrate_vma(const struct migrate_vma_ops *ops,
> +				struct vm_area_struct *vma,
> +				unsigned long mentries,
> +				unsigned long start,
> +				unsigned long end,
> +				unsigned long *src,
> +				unsigned long *dst,
> +				void *private)
> +{
> +	return -EINVAL;
> +}
> +#endif
> +
>
>  #endif /* _LINUX_MIGRATE_H */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index a430d51..c13677f 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -291,7 +291,7 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
>
>  config HMM
>  	bool
> -	depends on MMU
> +	depends on MMU && 64BIT
>
>  config HMM_MIRROR
>  	bool "HMM mirror CPU page table into a device page table"
> @@ -307,6 +307,7 @@ config HMM_MIRROR
>  	  Second side of the equation is replicating CPU page table content for
>  	  range of virtual address. This require careful synchronization with
>  	  CPU page table update.
> +	depends on 64BIT
>
>  config HMM_DEVMEM
>  	bool "HMM device memory helpers (to leverage ZONE_DEVICE)"
> @@ -314,6 +315,7 @@ config HMM_DEVMEM
>  	help
>  	  HMM devmem are helpers to leverage new ZONE_DEVICE feature. This is
>  	  just to avoid device driver to replicate boiler plate code.
> +	depends on 64BIT
>
>  config PHYS_ADDR_T_64BIT
>  	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
> diff --git a/mm/migrate.c b/mm/migrate.c
> index b9d25d1..15f2972 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2080,7 +2080,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>
>  #endif /* CONFIG_NUMA */
>
> -
> +#ifdef CONFIG_64BIT
>  struct migrate_vma {
>  	struct vm_area_struct	*vma;
>  	unsigned long		*dst;
> @@ -2787,3 +2787,4 @@ int migrate_vma(const struct migrate_vma_ops *ops,
>  	return 0;
>  }
>  EXPORT_SYMBOL(migrate_vma);
> +#endif
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
