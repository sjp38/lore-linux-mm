Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB866B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 07:37:50 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id k14so5713460wgh.3
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 04:37:49 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
        by mx.google.com with ESMTPS id g18si2309316wiv.106.2014.07.08.04.37.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 04:37:49 -0700 (PDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so810763wib.0
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 04:37:48 -0700 (PDT)
Date: Tue, 8 Jul 2014 12:37:38 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH v11 6/7] ARM: add pmd_[dirty|mkclean] for THP
Message-ID: <20140708113737.GA2958@linaro.org>
References: <1404799424-1120-1-git-send-email-minchan@kernel.org>
 <1404799424-1120-7-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1404799424-1120-7-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org

On Tue, Jul 08, 2014 at 03:03:43PM +0900, Minchan Kim wrote:
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
> ---
>  arch/arm/include/asm/pgtable-3level.h | 3 +++
>  arch/arm64/include/asm/pgtable.h      | 2 ++
>  2 files changed, 5 insertions(+)

Hi Minchan,
arch/arm and arch/arm64 are handled separately.
Could you please split this patch into arm and arm64 versions?


> 
> diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
> index 85c60adc8b60..3a7bb8dc7d05 100644
> --- a/arch/arm/include/asm/pgtable-3level.h
> +++ b/arch/arm/include/asm/pgtable-3level.h
> @@ -220,6 +220,8 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
>  #define pmd_trans_splitting(pmd) (pmd_val(pmd) & PMD_SECT_SPLITTING)
>  #endif
>  
> +#define pmd_dirty	(pmd_val(pmd) & PMD_SECT_DIRTY)

This macro is missing the parameter definition, and will generate a
compile errror when CONFIG_ARM_LPAE=y

For 32-bit ARM with CONFIG_ARM_LPAE=n, we don't have THP support and I noticed
some compiler errors in mm/madvise.c:

  CC      mm/madvise.o
mm/madvise.c: In function a??madvise_free_pte_rangea??:
mm/madvise.c:279:3: error: implicit declaration of function a??pmdp_get_and_cleara?? [-Werror=implicit-function-declaration]
   orig_pmd = pmdp_get_and_clear(mm, addr, pmd);
   ^
mm/madvise.c:285:3: error: implicit declaration of function a??pmd_mkolda?? [-Werror=implicit-function-declaration]
   orig_pmd = pmd_mkold(orig_pmd);
   ^
mm/madvise.c:286:3: error: implicit declaration of function a??pmd_mkcleana?? [-Werror=implicit-function-declaration]
   orig_pmd = pmd_mkclean(orig_pmd);
   ^
mm/madvise.c:288:3: error: implicit declaration of function a??set_pmd_ata?? [-Werror=implicit-function-declaration]
   set_pmd_at(mm, addr, pmd, orig_pmd);
   ^
cc1: some warnings being treated as errors
make[1]: *** [mm/madvise.o] Error 1


Cheers,
-- 
Steve 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
