Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 11CE06B0075
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 14:20:18 -0400 (EDT)
Date: Thu, 16 Aug 2012 20:20:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
Message-ID: <20120816182015.GC12578@dhcp22.suse.cz>
References: <alpine.LSU.2.00.1207091622470.2261@eggly.anvils>
 <20120710094513.GB9108@mudshark.cambridge.arm.com>
 <20120710104234.GI9108@mudshark.cambridge.arm.com>
 <20120711174802.GG13498@mudshark.cambridge.arm.com>
 <20120712111659.GF21013@tiehlicka.suse.cz>
 <20120712112645.GG2816@mudshark.cambridge.arm.com>
 <20120712115708.GG21013@tiehlicka.suse.cz>
 <20120807160337.GC16877@mudshark.cambridge.arm.com>
 <20120808162607.GA7885@dhcp22.suse.cz>
 <20120816160954.GA4330@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120816160954.GA4330@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Russell King <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu 16-08-12 17:09:54, Will Deacon wrote:
> On Wed, Aug 08, 2012 at 05:26:07PM +0100, Michal Hocko wrote:
[...]
> diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
> index da55c63..2adaa60 100644
> --- a/arch/ia64/include/asm/hugetlb.h
> +++ b/arch/ia64/include/asm/hugetlb.h
> @@ -1,6 +1,7 @@
>  #ifndef _ASM_IA64_HUGETLB_H
>  #define _ASM_IA64_HUGETLB_H
>  
> +#include <asm/cacheflush.h>
>  #include <asm/page.h>
>  
>  
> @@ -77,4 +78,9 @@ static inline void arch_release_hugepage(struct page *page)
>  {
>  }
>  
> +static inline void arch_clear_hugepage_flags(struct page *page)
> +{
> +	flush_dcache_page(page);
> +}
> +

Why do we need the hook for ia64? hugetlb_no_page calls clear_huge_page
and that one calls flush_dcache_page (via clear_user_page), right?
The same applies to copy_huge_page for COW.

> diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
> index dfdb95b..52696e6 100644
> --- a/arch/powerpc/include/asm/hugetlb.h
> +++ b/arch/powerpc/include/asm/hugetlb.h
> @@ -2,6 +2,7 @@
>  #define _ASM_POWERPC_HUGETLB_H
>  
>  #ifdef CONFIG_HUGETLB_PAGE
> +#include <asm/cacheflush.h>
>  #include <asm/page.h>
>  
>  extern struct kmem_cache *hugepte_cache;
> @@ -151,6 +152,11 @@ static inline void arch_release_hugepage(struct page *page)
>  {
>  }
>  
> +static inline void arch_clear_hugepage_flags(struct page *page)
> +{
> +	flush_dcache_page(page);
> +}
> +

Same here

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
