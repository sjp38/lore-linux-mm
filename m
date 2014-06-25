Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id B1FAA6B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 12:50:45 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h15so1968495igd.2
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 09:50:45 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id q6si1897109igr.54.2014.06.25.09.50.44
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 09:50:44 -0700 (PDT)
Date: Wed, 25 Jun 2014 17:50:03 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 6/6] arm64: mm: Enable RCU fast_gup
Message-ID: <20140625165003.GI15240@leverpostej>
References: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
 <1403710824-24340-7-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403710824-24340-7-git-send-email-steve.capper@linaro.org>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, Will Deacon <Will.Deacon@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>

Hi Steve,

On Wed, Jun 25, 2014 at 04:40:24PM +0100, Steve Capper wrote:
> Activate the RCU fast_gup for ARM64. We also need to force THP splits
> to broadcast an IPI s.t. we block in the fast_gup page walker. As THP
> splits are comparatively rare, this should not lead to a noticeable
> performance degradation.
> 
> Some pre-requisite functions pud_write and pud_page are also added.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>
> ---
>  arch/arm64/Kconfig               |  3 +++
>  arch/arm64/include/asm/pgtable.h | 11 ++++++++++-
>  arch/arm64/mm/flush.c            | 19 +++++++++++++++++++
>  3 files changed, 32 insertions(+), 1 deletion(-)

[...]

> diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
> index e4193e3..ddf96c1 100644
> --- a/arch/arm64/mm/flush.c
> +++ b/arch/arm64/mm/flush.c
> @@ -103,3 +103,22 @@ EXPORT_SYMBOL(flush_dcache_page);
>   */
>  EXPORT_SYMBOL(flush_cache_all);
>  EXPORT_SYMBOL(flush_icache_range);
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +#ifdef CONFIG_HAVE_RCU_TABLE_FREE
> +static void thp_splitting_flush_sync(void *arg)
> +{
> +}
> +
> +void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
> +			  pmd_t *pmdp)
> +{
> +	pmd_t pmd = pmd_mksplitting(*pmdp);
> +	VM_BUG_ON(address & ~PMD_MASK);
> +	set_pmd_at(vma->vm_mm, address, pmdp, pmd);
> +
> +	/* dummy IPI to serialise against fast_gup */
> +	smp_call_function(thp_splitting_flush_sync, NULL, 1);

Is there some reason we can't use kick_all_cpus_sync()?

>From a glance it seems that powerpc does just that.

Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
