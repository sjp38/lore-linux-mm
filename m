Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 87F6D6B037A
	for <linux-mm@kvack.org>; Sat,  9 Sep 2017 11:38:24 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g128so7619702qke.5
        for <linux-mm@kvack.org>; Sat, 09 Sep 2017 08:38:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w15sor2215047qtw.19.2017.09.09.08.38.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Sep 2017 08:38:23 -0700 (PDT)
Subject: Re: [PATCH v6 09/11] arm64/mm: disable section/contiguous mappings if
 XPFO is enabled
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-10-tycho@docker.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <17b9b826-366e-48f1-a117-e650b7a5811f@redhat.com>
Date: Sat, 9 Sep 2017 08:38:20 -0700
MIME-Version: 1.0
In-Reply-To: <20170907173609.22696-10-tycho@docker.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-arm-kernel@lists.infradead.org

On 09/07/2017 10:36 AM, Tycho Andersen wrote:
> XPFO doesn't support section/contiguous mappings yet, so let's disable it
> if XPFO is turned on.
> 
> Thanks to Laura Abbot for the simplification from v5, and Mark Rutland for
> pointing out we need NO_CONT_MAPPINGS too.
> 
> CC: linux-arm-kernel@lists.infradead.org
> Signed-off-by: Tycho Andersen <tycho@docker.com>


This should just be folded into the initial arm64 patch
since it basically bugs out otherwise.

Thanks,
Laura

> ---
>  arch/arm64/mm/mmu.c  | 2 +-
>  include/linux/xpfo.h | 4 ++++
>  mm/xpfo.c            | 6 ++++++
>  3 files changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index f1eb15e0e864..34bb95303cce 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -420,7 +420,7 @@ static void __init map_mem(pgd_t *pgd)
>  	struct memblock_region *reg;
>  	int flags = 0;
>  
> -	if (debug_pagealloc_enabled())
> +	if (debug_pagealloc_enabled() || xpfo_enabled())
>  		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
>  
>  	/*
> diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
> index d37a06c9d62c..1693af1a0293 100644
> --- a/include/linux/xpfo.h
> +++ b/include/linux/xpfo.h
> @@ -43,6 +43,8 @@ void xpfo_temp_map(const void *addr, size_t size, void **mapping,
>  void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
>  		     size_t mapping_len);
>  
> +bool xpfo_enabled(void);
> +
>  #else /* !CONFIG_XPFO */
>  
>  static inline void xpfo_kmap(void *kaddr, struct page *page) { }
> @@ -65,6 +67,8 @@ static inline void xpfo_temp_unmap(const void *addr, size_t size,
>  }
>  
>  
> +static inline bool xpfo_enabled(void) { return false; }
> +
>  #endif /* CONFIG_XPFO */
>  
>  #endif /* _LINUX_XPFO_H */
> diff --git a/mm/xpfo.c b/mm/xpfo.c
> index f79075bf7d65..25fba05d01bd 100644
> --- a/mm/xpfo.c
> +++ b/mm/xpfo.c
> @@ -70,6 +70,12 @@ struct page_ext_operations page_xpfo_ops = {
>  	.init = init_xpfo,
>  };
>  
> +bool __init xpfo_enabled(void)
> +{
> +	return !xpfo_disabled;
> +}
> +EXPORT_SYMBOL(xpfo_enabled);
> +
>  static inline struct xpfo *lookup_xpfo(struct page *page)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
