Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7C26B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 10:54:36 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id k48so3592493wev.12
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 07:54:35 -0700 (PDT)
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
        by mx.google.com with ESMTPS id gm1si4263648wib.20.2014.07.18.07.54.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 07:54:30 -0700 (PDT)
Received: by mail-we0-f170.google.com with SMTP id w62so4745436wes.29
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 07:54:29 -0700 (PDT)
Date: Fri, 18 Jul 2014 15:54:22 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH v13 6/8] arm: add pmd_[dirty|mkclean] for THP
Message-ID: <20140718145421.GA18569@linaro.org>
References: <1405666386-15095-1-git-send-email-minchan@kernel.org>
 <1405666386-15095-7-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405666386-15095-7-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org

On Fri, Jul 18, 2014 at 03:53:04PM +0900, Minchan Kim wrote:
> MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
> overwrite of the contents since MADV_FREE syscall is called for
> THP page.
> 
> This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
> support.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Steve Capper <steve.capper@linaro.org>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: linux-arm-kernel@lists.infradead.org
> Signed-off-by: Minchan Kim <minchan@kernel.org>

This patch looks good to me:
Acked-by: Steve Capper <steve.capper@linaro.org>

There is another patch that introduces a helper function to test for
pmd bits, please see below.

> ---
>  arch/arm/include/asm/pgtable-3level.h | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
> index 85c60adc8b60..830f84f2d277 100644
> --- a/arch/arm/include/asm/pgtable-3level.h
> +++ b/arch/arm/include/asm/pgtable-3level.h
> @@ -220,6 +220,8 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
>  #define pmd_trans_splitting(pmd) (pmd_val(pmd) & PMD_SECT_SPLITTING)
>  #endif
>  
> +#define pmd_dirty(pmd)		(pmd_val(pmd) & PMD_SECT_DIRTY)

Russell,
Should this be folded into my {pte|pmd}_isset patch?
http://lists.infradead.org/pipermail/linux-arm-kernel/2014-July/268979.html

Cheers,
-- 
Steve


> +
>  #define PMD_BIT_FUNC(fn,op) \
>  static inline pmd_t pmd_##fn(pmd_t pmd) { pmd_val(pmd) op; return pmd; }
>  
> @@ -228,6 +230,7 @@ PMD_BIT_FUNC(mkold,	&= ~PMD_SECT_AF);
>  PMD_BIT_FUNC(mksplitting, |= PMD_SECT_SPLITTING);
>  PMD_BIT_FUNC(mkwrite,   &= ~PMD_SECT_RDONLY);
>  PMD_BIT_FUNC(mkdirty,   |= PMD_SECT_DIRTY);
> +PMD_BIT_FUNC(mkclean,   &= ~PMD_SECT_DIRTY);
>  PMD_BIT_FUNC(mkyoung,   |= PMD_SECT_AF);
>  
>  #define pmd_mkhuge(pmd)		(__pmd(pmd_val(pmd) & ~PMD_TABLE_BIT))
> -- 
> 2.0.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
