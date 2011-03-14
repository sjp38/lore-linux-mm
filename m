Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 42C4D8D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 16:55:01 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p2EKsxsq018269
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:54:59 -0700
Received: from pxi3 (pxi3.prod.google.com [10.243.27.3])
	by wpaz21.hot.corp.google.com with ESMTP id p2EKsvnP006697
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:54:57 -0700
Received: by pxi3 with SMTP id 3so1864047pxi.26
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:54:57 -0700 (PDT)
Date: Mon, 14 Mar 2011 13:54:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH v2 00/23] (alpha) __vmalloc: add gfp flags variant
 of pte and pmd allocation
In-Reply-To: <AANLkTik3qn-RVUTZp5+gTk+wB9SO_MsxySHEwE8Yzi-e@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103141351210.31514@chino.kir.corp.google.com>
References: <AANLkTik3qn-RVUTZp5+gTk+wB9SO_MsxySHEwE8Yzi-e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prasad Joshi <prasadjoshi124@gmail.com>
Cc: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, linux-alpha@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org

On Mon, 14 Mar 2011, Prasad Joshi wrote:

> __vmalloc: propagating GFP allocation flag.
> 

This isn't the correct title of the patch.  You don't need to actually 
give them titles, the subject line will be used instead.

The subject line should also indicate this as patch 01/2 and it should 
read "mm, alpha: add gfp flags variant of pte and pmd allocations".

> - adds functions to allow caller to pass the GFP flag for memory allocation
> - helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
>   file system evict_inode).
> 
> Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
> Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>

The first signed-off-by line usually indicates the author of the change in 
which case this would require the first line of the email to be

From: Anand Mitra <mitra@kqinfotech.com>

if that's the correct attribution.

> ---
> Chnagelog:
> arch/alpha/include/asm/pgalloc.h |   18 ++++++++++++++----
> 1 files changed, 14 insertions(+), 4 deletions(-)
> ---
> diff --git a/arch/alpha/include/asm/pgalloc.h b/arch/alpha/include/asm/pgalloc.h
> index bc2a0da..d05dfc2 100644
> --- a/arch/alpha/include/asm/pgalloc.h
> +++ b/arch/alpha/include/asm/pgalloc.h
> @@ -38,10 +38,15 @@ pgd_free(struct mm_struct *mm, pgd_t *pgd)
>  }
> 
>  static inline pmd_t *
> +__pmd_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
> +{
> +	return (pmd_t *)__get_free_page(gfp_mask | __GFP_ZERO);
> +}
> +
> +static inline pmd_t *
>  pmd_alloc_one(struct mm_struct *mm, unsigned long address)
>  {
> -	pmd_t *ret = (pmd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
> -	return ret;
> +	return __pmd_alloc_one(mm, address, GFP_KERNEL | __GFP_REPEAT);
>  }
> 
>  static inline void
> @@ -51,10 +56,15 @@ pmd_free(struct mm_struct *mm, pmd_t *pmd)
>  }
> 
>  static inline pte_t *
> +__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addressi,
> gfp_t gfp_mask)

This patch is corrupt probably because of your email client (and all other 
patches in this series are corrupt, as well).  Please see 
Documentation/email-clients.txt and try sending test patches to a 
colleague and git-apply them first.

BTW, s/addressi/address/ for this function definition.

> +{
> +	return (pte_t *)__get_free_page(gfp_mask | __GFP_ZERO);
> +}
> +
> +static inline pte_t *
>  pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
>  {
> -	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
> -	return pte;
> +	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
>  }
> 
>  static inline void

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
