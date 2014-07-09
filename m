Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 05BBA6B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 01:38:34 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id ft15so1615574pdb.28
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 22:38:34 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id fy14si6916108pdb.378.2014.07.08.22.38.32
        for <linux-mm@kvack.org>;
        Tue, 08 Jul 2014 22:38:33 -0700 (PDT)
Date: Wed, 9 Jul 2014 14:38:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v11 6/7] ARM: add pmd_[dirty|mkclean] for THP
Message-ID: <20140709053837.GC9824@bbox>
References: <1404799424-1120-1-git-send-email-minchan@kernel.org>
 <1404799424-1120-7-git-send-email-minchan@kernel.org>
 <20140708113737.GA2958@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140708113737.GA2958@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org

Hello Steve,

On Tue, Jul 08, 2014 at 12:37:38PM +0100, Steve Capper wrote:
> On Tue, Jul 08, 2014 at 03:03:43PM +0900, Minchan Kim wrote:
> > MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
> > overwrite of the contents since MADV_FREE syscall is called for
> > THP page.
> > 
> > This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
> > support.
> > 
> > Cc: Catalin Marinas <catalin.marinas@arm.com>
> > Cc: Will Deacon <will.deacon@arm.com>
> > Cc: Steve Capper <steve.capper@linaro.org>
> > Cc: Russell King <linux@arm.linux.org.uk>
> > Cc: linux-arm-kernel@lists.infradead.org
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  arch/arm/include/asm/pgtable-3level.h | 3 +++
> >  arch/arm64/include/asm/pgtable.h      | 2 ++
> >  2 files changed, 5 insertions(+)
> 
> Hi Minchan,
> arch/arm and arch/arm64 are handled separately.
> Could you please split this patch into arm and arm64 versions?
> 

Sure.

> 
> > 
> > diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
> > index 85c60adc8b60..3a7bb8dc7d05 100644
> > --- a/arch/arm/include/asm/pgtable-3level.h
> > +++ b/arch/arm/include/asm/pgtable-3level.h
> > @@ -220,6 +220,8 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
> >  #define pmd_trans_splitting(pmd) (pmd_val(pmd) & PMD_SECT_SPLITTING)
> >  #endif
> >  
> > +#define pmd_dirty	(pmd_val(pmd) & PMD_SECT_DIRTY)
> 
> This macro is missing the parameter definition, and will generate a
> compile errror when CONFIG_ARM_LPAE=y
> 
> For 32-bit ARM with CONFIG_ARM_LPAE=n, we don't have THP support and I noticed
> some compiler errors in mm/madvise.c:
> 
>   CC      mm/madvise.o
> mm/madvise.c: In function a??madvise_free_pte_rangea??:
> mm/madvise.c:279:3: error: implicit declaration of function a??pmdp_get_and_cleara?? [-Werror=implicit-function-declaration]
>    orig_pmd = pmdp_get_and_clear(mm, addr, pmd);
>    ^
> mm/madvise.c:285:3: error: implicit declaration of function a??pmd_mkolda?? [-Werror=implicit-function-declaration]
>    orig_pmd = pmd_mkold(orig_pmd);
>    ^
> mm/madvise.c:286:3: error: implicit declaration of function a??pmd_mkcleana?? [-Werror=implicit-function-declaration]
>    orig_pmd = pmd_mkclean(orig_pmd);
>    ^
> mm/madvise.c:288:3: error: implicit declaration of function a??set_pmd_ata?? [-Werror=implicit-function-declaration]
>    set_pmd_at(mm, addr, pmd, orig_pmd);
>    ^
> cc1: some warnings being treated as errors
> make[1]: *** [mm/madvise.o] Error 1
> 

Oops, will fix.

Thanks for the review!

> 
> Cheers,
> -- 
> Steve 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
