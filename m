Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 731EE6B0039
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 15:48:10 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id p10so1902746pdj.2
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 12:48:10 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ql9si9845634pac.103.2014.09.12.12.48.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 12:48:09 -0700 (PDT)
Date: Fri, 12 Sep 2014 15:47:55 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH v2 5/6] x86, mm, pat: Add pgprot_writethrough() for WT
Message-ID: <20140912194755.GL15656@laptop.dumpdata.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
 <1410367910-6026-6-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1410367910-6026-6-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com

On Wed, Sep 10, 2014 at 10:51:49AM -0600, Toshi Kani wrote:
> This patch adds pgprot_writethrough() for setting WT to a given
> pgprot_t.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  arch/x86/include/asm/pgtable_types.h |    3 +++
>  arch/x86/mm/pat.c                    |   10 ++++++++++
>  include/asm-generic/pgtable.h        |    4 ++++
>  3 files changed, 17 insertions(+)
> 
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index bd2f50f..cc7c65d 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -394,6 +394,9 @@ extern int nx_enabled;
>  #define pgprot_writecombine	pgprot_writecombine
>  extern pgprot_t pgprot_writecombine(pgprot_t prot);
>  
> +#define pgprot_writethrough	pgprot_writethrough
> +extern pgprot_t pgprot_writethrough(pgprot_t prot);
> +
>  /* Indicate that x86 has its own track and untrack pfn vma functions */
>  #define __HAVE_PFNMAP_TRACKING
>  
> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
> index 7644967..97aab95 100644
> --- a/arch/x86/mm/pat.c
> +++ b/arch/x86/mm/pat.c
> @@ -875,6 +875,16 @@ pgprot_t pgprot_writecombine(pgprot_t prot)
>  }
>  EXPORT_SYMBOL_GPL(pgprot_writecombine);
>  
> +pgprot_t pgprot_writethrough(pgprot_t prot)
> +{
> +	if (pat_enabled)
> +		return __pgprot(pgprot_val(prot) |
> +				cachemode2protval(_PAGE_CACHE_MODE_WT));
> +	else
> +		return pgprot_noncached(prot);
> +}
> +EXPORT_SYMBOL_GPL(pgprot_writethrough);
> +
>  #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_X86_PAT)
>  
>  static struct memtype *memtype_get_idx(loff_t pos)
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 53b2acc..1af0ed9 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -249,6 +249,10 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
>  #define pgprot_writecombine pgprot_noncached
>  #endif
>  
> +#ifndef pgprot_writethrough
> +#define pgprot_writethrough pgprot_noncached
> +#endif
> +
>  /*
>   * When walking page tables, get the address of the next boundary,
>   * or the end address of the range if that comes earlier.  Although no

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
