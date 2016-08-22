Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B144C6B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 09:44:56 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k135so75008623lfb.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 06:44:56 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id pu8si18551361wjb.242.2016.08.22.06.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 06:44:55 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id o80so13576716wme.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 06:44:55 -0700 (PDT)
Date: Mon, 22 Aug 2016 15:44:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v3 1/2] mm/hugetlb: Introduce ARCH_HAS_GIGANTIC_PAGE
Message-ID: <20160822134454.GN13596@dhcp22.suse.cz>
References: <1471872004-59365-1-git-send-email-xieyisheng1@huawei.com>
 <1471872004-59365-2-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471872004-59365-2-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie Yisheng <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Mon 22-08-16 21:20:03, Xie Yisheng wrote:
> Avoid making ifdef get pretty unwieldy if many ARCHs support gigantic page.
> No functional change with this patch.
> 
> Signed-off-by: Xie Yisheng <xieyisheng1@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/s390/Kconfig | 1 +
>  arch/x86/Kconfig  | 1 +
>  fs/Kconfig        | 3 +++
>  mm/hugetlb.c      | 2 +-
>  4 files changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
> index e751fe2..a8c8fa3 100644
> --- a/arch/s390/Kconfig
> +++ b/arch/s390/Kconfig
> @@ -72,6 +72,7 @@ config S390
>  	select ARCH_HAS_DEVMEM_IS_ALLOWED
>  	select ARCH_HAS_ELF_RANDOMIZE
>  	select ARCH_HAS_GCOV_PROFILE_ALL
> +	select ARCH_HAS_GIGANTIC_PAGE
>  	select ARCH_HAS_KCOV
>  	select ARCH_HAS_SG_CHAIN
>  	select ARCH_HAVE_NMI_SAFE_CMPXCHG
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index c580d8c..2fdc300 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -29,6 +29,7 @@ config X86
>  	select ARCH_HAS_ELF_RANDOMIZE
>  	select ARCH_HAS_FAST_MULTIPLIER
>  	select ARCH_HAS_GCOV_PROFILE_ALL
> +	select ARCH_HAS_GIGANTIC_PAGE		if X86_64
>  	select ARCH_HAS_KCOV			if X86_64
>  	select ARCH_HAS_PMEM_API		if X86_64
>  	select ARCH_HAS_MMIO_FLUSH
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 2bc7ad7..b938205 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -199,6 +199,9 @@ config HUGETLBFS
>  config HUGETLB_PAGE
>  	def_bool HUGETLBFS
>  
> +config ARCH_HAS_GIGANTIC_PAGE
> +	bool
> +
>  source "fs/configfs/Kconfig"
>  source "fs/efivarfs/Kconfig"
>  
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 87e11d8..8488dcc 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1022,7 +1022,7 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>  		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
>  		nr_nodes--)
>  
> -#if (defined(CONFIG_X86_64) || defined(CONFIG_S390)) && \
> +#if defined(CONFIG_ARCH_HAS_GIGANTIC_PAGE) && \
>  	((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
>  	defined(CONFIG_CMA))
>  static void destroy_compound_gigantic_page(struct page *page,
> -- 
> 1.7.12.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
