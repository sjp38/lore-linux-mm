Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id EBF716B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 18:17:12 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id x3so25411410pfb.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 15:17:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d82si1247573pfj.52.2016.03.29.15.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 15:17:12 -0700 (PDT)
Date: Tue, 29 Mar 2016 15:17:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 3/8] mm: Add support for PUD-sized transparent
 hugepages
Message-Id: <20160329151710.6a256611fd28637d5c40ac3c@linux-foundation.org>
In-Reply-To: <1454242175-16870-4-git-send-email-matthew.r.wilcox@intel.com>
References: <1454242175-16870-1-git-send-email-matthew.r.wilcox@intel.com>
	<1454242175-16870-4-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Sun, 31 Jan 2016 23:09:30 +1100 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> From: Matthew Wilcox <willy@linux.intel.com>
> 
> The current transparent hugepage code only supports PMDs.  This patch
> adds support for transparent use of PUDs with DAX.  It does not include
> support for anonymous pages.
> 
> Most of this patch simply parallels the work that was done for huge PMDs.
> The only major difference is how the new ->pud_entry method in mm_walk
> works.  The ->pmd_entry method replaces the ->pte_entry method, whereas
> the ->pud_entry method works along with either ->pmd_entry or ->pte_entry.
> The pagewalk code takes care of locking the PUD before calling ->pud_walk,
> so handlers do not need to worry whether the PUD is stable.

Why is this patchset always so hard to compile :(

> ...
>
> --- a/include/linux/pfn_t.h
> +++ b/include/linux/pfn_t.h
> @@ -82,6 +82,13 @@ static inline pmd_t pfn_t_pmd(pfn_t pfn, pgprot_t pgprot)
>  {
>  	return pfn_pmd(pfn_t_to_pfn(pfn), pgprot);
>  }
> +
> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> +static inline pud_t pfn_t_pud(pfn_t pfn, pgprot_t pgprot)
> +{
> +	return pfn_pud(pfn_t_to_pfn(pfn), pgprot);
> +}
> +#endif
>  #endif
>  
>  #ifdef __HAVE_ARCH_PTE_DEVMAP
> @@ -98,5 +105,6 @@ static inline bool pfn_t_devmap(pfn_t pfn)
>  }
>  pte_t pte_mkdevmap(pte_t pte);
>  pmd_t pmd_mkdevmap(pmd_t pmd);
> +pud_t pud_mkdevmap(pud_t pud);

arm allnoconfig:

In file included from kernel/memremap.c:17:
include/linux/pfn_t.h:107: error: 'pud_mkdevmap' declared as function returning an array
because it expands to

pgd_t pud_mkdevmap(pgd_t pud);

and

typedef unsigned long pgd_t[2];                                                 


Also the patch provides no implementation of pud_mkdevmap() so it's
obviously going to break bisection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
