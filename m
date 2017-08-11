Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2DE6B02B4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 13:25:18 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id t37so20450434qtg.6
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 10:25:18 -0700 (PDT)
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com. [209.85.220.177])
        by mx.google.com with ESMTPS id h36si1222692qte.246.2017.08.11.10.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 10:25:17 -0700 (PDT)
Received: by mail-qk0-f177.google.com with SMTP id z18so23888376qka.4
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 10:25:17 -0700 (PDT)
Subject: Re: [kernel-hardening] [PATCH v5 06/10] arm64/mm: Disable section
 mappings if XPFO is enabled
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-7-tycho@docker.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <f6a42032-d4e5-f488-3d55-1da4c8a4dbaf@redhat.com>
Date: Fri, 11 Aug 2017 10:25:14 -0700
MIME-Version: 1.0
In-Reply-To: <20170809200755.11234-7-tycho@docker.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On 08/09/2017 01:07 PM, Tycho Andersen wrote:
> From: Juerg Haefliger <juerg.haefliger@hpe.com>
> 
> XPFO (eXclusive Page Frame Ownership) doesn't support section mappings
> yet, so disable it if XPFO is turned on.
> 
> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
> Tested-by: Tycho Andersen <tycho@docker.com>
> ---
>  arch/arm64/mm/mmu.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index f1eb15e0e864..38026b3ccb46 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -176,6 +176,18 @@ static void alloc_init_cont_pte(pmd_t *pmd, unsigned long addr,
>  	} while (addr = next, addr != end);
>  }
>  
> +static inline bool use_section_mapping(unsigned long addr, unsigned long next,
> +				unsigned long phys)
> +{
> +	if (IS_ENABLED(CONFIG_XPFO))
> +		return false;
> +
> +	if (((addr | next | phys) & ~SECTION_MASK) != 0)
> +		return false;
> +
> +	return true;
> +}
> +
>  static void init_pmd(pud_t *pud, unsigned long addr, unsigned long end,
>  		     phys_addr_t phys, pgprot_t prot,
>  		     phys_addr_t (*pgtable_alloc)(void), int flags)
> @@ -190,7 +202,7 @@ static void init_pmd(pud_t *pud, unsigned long addr, unsigned long end,
>  		next = pmd_addr_end(addr, end);
>  
>  		/* try section mapping first */
> -		if (((addr | next | phys) & ~SECTION_MASK) == 0 &&
> +		if (use_section_mapping(addr, next, phys) &&
>  		    (flags & NO_BLOCK_MAPPINGS) == 0) {
>  			pmd_set_huge(pmd, phys, prot);
>  
> 

There is already similar logic to disable section mappings for
debug_pagealloc at the start of map_mem, can you take advantage
of that?

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
