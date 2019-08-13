Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBF26C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 10:20:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA1172067D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 10:20:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA1172067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4874B6B0005; Tue, 13 Aug 2019 06:20:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46B656B0006; Tue, 13 Aug 2019 06:20:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34D4E6B0007; Tue, 13 Aug 2019 06:20:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0205.hostedemail.com [216.40.44.205])
	by kanga.kvack.org (Postfix) with ESMTP id 1681A6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 06:20:55 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B14392816
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:20:54 +0000 (UTC)
X-FDA: 75817011228.01.smoke19_5f27a07b80f2e
X-HE-Tag: smoke19_5f27a07b80f2e
X-Filterd-Recvd-Size: 4103
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:20:53 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D9537344;
	Tue, 13 Aug 2019 03:20:52 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 189DE3F694;
	Tue, 13 Aug 2019 03:20:51 -0700 (PDT)
Date: Tue, 13 Aug 2019 11:20:50 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Simek <monstr@monstr.eu>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] microblaze: switch to generic version of pte allocation
Message-ID: <20190813102049.GC866@lakrids.cambridge.arm.com>
References: <1565690952-32158-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1565690952-32158-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 01:09:12PM +0300, Mike Rapoport wrote:
> The microblaze implementation of pte_alloc_one() has a provision to
> allocated PTEs from high memory, but neither CONFIG_HIGHPTE nor pte_map*()
> versions for suitable for HIGHPTE are defined.
> 
> Except that, microblaze version of pte_alloc_one() is identical to the
> generic one as well as the implementations of pte_free() and
> pte_free_kernel().
> 
> Switch microblaze to use the generic versions of these functions.
> Also remove pte_free_slow() that is not referenced anywhere in the code.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
> The patch is vs. mmots/master since this tree contains bothi "mm: remove
> quicklist page table caches" and "mm: treewide: clarify
> pgtable_page_{ctor,dtor}() naming" patches that had a conflict resulting in
> a build failure [1].
> 
> [1] https://lore.kernel.org/linux-mm/201908131204.B910fkl1%25lkp@intel.com/

This looks sane to me, so FWIW:

Acked-by: Mark Rutland <mark.rutland@arm.com>

I guess Andrew will pick this up and fix up the conflict?

Thanks,
Mark.

> 
>  arch/microblaze/include/asm/pgalloc.h | 39 +++--------------------------------
>  1 file changed, 3 insertions(+), 36 deletions(-)
> 
> diff --git a/arch/microblaze/include/asm/pgalloc.h b/arch/microblaze/include/asm/pgalloc.h
> index dbf25a3..7ecb05b 100644
> --- a/arch/microblaze/include/asm/pgalloc.h
> +++ b/arch/microblaze/include/asm/pgalloc.h
> @@ -21,6 +21,9 @@
>  #include <asm/cache.h>
>  #include <asm/pgtable.h>
>  
> +#define __HAVE_ARCH_PTE_ALLOC_ONE_KERNEL
> +#include <asm-generic/pgalloc.h>
> +
>  extern void __bad_pte(pmd_t *pmd);
>  
>  static inline pgd_t *get_pgd(void)
> @@ -47,42 +50,6 @@ static inline void free_pgd(pgd_t *pgd)
>  
>  extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm);
>  
> -static inline struct page *pte_alloc_one(struct mm_struct *mm)
> -{
> -	struct page *ptepage;
> -
> -#ifdef CONFIG_HIGHPTE
> -	int flags = GFP_KERNEL | __GFP_ZERO | __GFP_HIGHMEM;
> -#else
> -	int flags = GFP_KERNEL | __GFP_ZERO;
> -#endif
> -
> -	ptepage = alloc_pages(flags, 0);
> -	if (!ptepage)
> -		return NULL;
> -	if (!pgtable_page_ctor(ptepage)) {
> -		__free_page(ptepage);
> -		return NULL;
> -	}
> -	return ptepage;
> -}
> -
> -static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
> -{
> -	free_page((unsigned long)pte);
> -}
> -
> -static inline void pte_free_slow(struct page *ptepage)
> -{
> -	__free_page(ptepage);
> -}
> -
> -static inline void pte_free(struct mm_struct *mm, struct page *ptepage)
> -{
> -	pgtable_pte_page_dtor(ptepage);
> -	__free_page(ptepage);
> -}
> -
>  #define __pte_free_tlb(tlb, pte, addr)	pte_free((tlb)->mm, (pte))
>  
>  #define pmd_populate(mm, pmd, pte) \
> -- 
> 2.7.4
> 

