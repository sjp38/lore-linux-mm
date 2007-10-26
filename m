Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9Q86WmA136538
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 08:06:32 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9Q86WWs1822854
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 10:06:32 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9Q86VBF019743
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 10:06:32 +0200
Subject: Re: [patch 2/6] CONFIG_HIGHPTE vs. sub-page page tables.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <1193345221.7018.18.camel@pasglop>
References: <20071025181520.880272069@de.ibm.com>
	 <20071025181901.212545095@de.ibm.com>  <1193345221.7018.18.camel@pasglop>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 10:06:31 +0200
Message-Id: <1193385991.31831.11.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com
List-ID: <linux-mm.kvack.org>

> @@ -107,20 +107,21 @@ __init_refok pte_t *pte_alloc_one_kernel
>  	return pte;
>  }
>  
> -struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
> +pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
>  {
>  	struct page *ptepage;
>  
>  #ifdef CONFIG_HIGHPTE
> -	gfp_t flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_REPEAT;
> +	gfp_t flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_REPEAT | __GFP_ZERO;
>  #else
> -	gfp_t flags = GFP_KERNEL | __GFP_REPEAT;
> +	gfp_t flags = GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO;
>  #endif
>  
>  	ptepage = alloc_pages(flags, 0);
> -	if (ptepage)
> -		clear_highpage(ptepage);
> -	return ptepage;
> +	if (!ptepage)
> +		return NULL;
> +	pgtable_page_ctor(ptepage);
> +	return page_address(ptepage);
>  }
>  
> void pte_free_kernel(struct mm_struct *mm, pte_t *pte)

Hmpf, where is my brown paper bag? The pte_alloc_one function for 32 bit
powerpc should better return a struct page pointer .. fix below.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.

---

diff -urpN linux-2.6/arch/powerpc/mm/pgtable_32.c linux-2.6-patched/arch/powerpc/mm/pgtable_32.c
--- linux-2.6/arch/powerpc/mm/pgtable_32.c	2007-10-26 09:38:30.000000000 +0200
+++ linux-2.6-patched/arch/powerpc/mm/pgtable_32.c	2007-10-26 10:01:10.000000000 +0200
@@ -121,7 +121,7 @@ pgtable_t pte_alloc_one(struct mm_struct
 	if (!ptepage)
 		return NULL;
 	pgtable_page_ctor(ptepage);
-	return page_address(ptepage);
+	return ptepage;
 }
 
 void pte_free_kernel(struct mm_struct *mm, pte_t *pte)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
