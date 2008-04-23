Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3NFMpA2031088
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 11:22:51 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3NFKgt7125622
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 09:20:42 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3NFKeCo008415
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 09:20:42 -0600
Subject: Re: [patch 04/18] hugetlb: modular state
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
In-Reply-To: <20080423015430.054070000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
	 <20080423015430.054070000@nick.local0.net>
Content-Type: text/plain
Date: Wed, 23 Apr 2008 10:21:38 -0500
Message-Id: <1208964098.16652.13.camel@skynet>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-04-23 at 11:53 +1000, npiggin@suse.de wrote:

<snip>

> Index: linux-2.6/arch/powerpc/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/powerpc/mm/hugetlbpage.c
> +++ linux-2.6/arch/powerpc/mm/hugetlbpage.c
> @@ -128,7 +128,7 @@ pte_t *huge_pte_offset(struct mm_struct 
>  	return NULL;
>  }
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, int sz)

The sz has to be an unsigned long to match the definition in the header.
The same is true for the other architectures too.

Jon
Tollefson


>  {
>  	pgd_t *pg;
>  	pud_t *pu;
> Index: linux-2.6/arch/sparc64/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/sparc64/mm/hugetlbpage.c
> +++ linux-2.6/arch/sparc64/mm/hugetlbpage.c
> @@ -195,7 +195,7 @@ hugetlb_get_unmapped_area(struct file *f
>  				pgoff, flags);
>  }
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, int sz)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> Index: linux-2.6/arch/sh/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/sh/mm/hugetlbpage.c
> +++ linux-2.6/arch/sh/mm/hugetlbpage.c
> @@ -22,7 +22,7 @@
>  #include <asm/tlbflush.h>
>  #include <asm/cacheflush.h>
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, int sz)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> Index: linux-2.6/arch/ia64/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/ia64/mm/hugetlbpage.c
> +++ linux-2.6/arch/ia64/mm/hugetlbpage.c
> @@ -24,7 +24,7 @@
>  unsigned int hpage_shift=HPAGE_SHIFT_DEFAULT;
> 
>  pte_t *
> -huge_pte_alloc (struct mm_struct *mm, unsigned long addr)
> +huge_pte_alloc (struct mm_struct *mm, unsigned long addr, int sz)
>  {
>  	unsigned long taddr = htlbpage_to_page(addr);
>  	pgd_t *pgd;
> Index: linux-2.6/arch/x86/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/mm/hugetlbpage.c
> +++ linux-2.6/arch/x86/mm/hugetlbpage.c
> @@ -124,7 +124,7 @@ int huge_pmd_unshare(struct mm_struct *m
>  	return 1;
>  }
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, int sz)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> Index: linux-2.6/include/linux/hugetlb.h
> ===================================================================
> --- linux-2.6.orig/include/linux/hugetlb.h
> +++ linux-2.6/include/linux/hugetlb.h
> @@ -40,7 +40,7 @@ extern int sysctl_hugetlb_shm_group;
> 
>  /* arch callbacks */
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr);
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz);

<snip>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
