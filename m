Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC9D6C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 13:46:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F2BD208C4
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 13:46:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="u4farRz9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F2BD208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E91D56B0003; Thu,  2 May 2019 09:46:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E41796B0006; Thu,  2 May 2019 09:46:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D30096B0007; Thu,  2 May 2019 09:46:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2316B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 09:46:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so1215892pgo.14
        for <linux-mm@kvack.org>; Thu, 02 May 2019 06:46:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ltwp7XCyFAkwdAhMqzDIsh/0oySf9fTzh9l18aVXPw0=;
        b=k+Ym7Mocc6xMZjw/eo7Ae8gVLhrC7RL74s9F8gQNPVTmpip2R6bnL2YoWHaFmEzunn
         ub3oElOsoIBlryYGlKi1ZFRoNsPOHh+6gbiwVQZHkfbw6vgnAEpB+wMWiiol0Nn+3t1M
         2X46imzyX0FiWuEg7sUfX/a6l6KS5Yr1i5yqvNCi+4vyngk4cu/lqlfEHpe1+/vYbYem
         kR4PMLggoFJqI/UtndG4iTJpHH4ugMyLNFvsDQ9jJS53SoVjf/c5d4r3G4y4Pxt5hcaj
         Ot5zUsYQCCpUY+L0jXVsFsc88UezgF75eUcv4Zn62PaKSuEIXKj57H8yoy+YvIqNtr2s
         /R0g==
X-Gm-Message-State: APjAAAWRd8NPza/jpcqf1KK+bNIsm3HYy6HI0yvOyUiKcrYxBP5RRQHQ
	9ruxtB5sFXdN7azModYeg44OqxOls5ZV1u4RTyeavK1adPK0T/cU7Ns9QZMX8W9R8B0y11KYCpU
	ozFOONUzNPo2EPJtSgvwOfhnJs/rAOtDt9N0E2R1HoBkIut8pb/X3/AzKNo6SAEkBtQ==
X-Received: by 2002:a63:1555:: with SMTP id 21mr4122343pgv.204.1556804788131;
        Thu, 02 May 2019 06:46:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzc1VUImUX81wCgLUS+sYPTXe8oGvpo5+Z4rGBj7sVOUlGxUh3IB+fk3cUaxAdbmqCAjxG+
X-Received: by 2002:a63:1555:: with SMTP id 21mr4122250pgv.204.1556804787046;
        Thu, 02 May 2019 06:46:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556804787; cv=none;
        d=google.com; s=arc-20160816;
        b=hyb9Qi8zrHVfHz8HDwC+S5YWl2bLBV17CZjMt2ALggX+TuETVUWC+h8t2zIbZUz5q8
         G7Fjfu/ZdtCdPjPTd2v+DqgZsa8jbKl0lWmsh4LxMsOqYuUCecp6XATWjBkZrllVVikD
         4fNq2139AejTl7PHXQnyzbPU3hTjD9hmDfNrLAxgr0Q6mksTkXJ1V91QCKjkHoSYkR2R
         /lrt99UrQRoj/3mYiEIcXie+2DehQMZYhaEjBjp5FdGxGSBUx8ZL+I8vG/v5+UX5lNKT
         VRhsDSwN8AH7uWW+5wnbsQPdxjqd0wQv3bKYT8gUqnslR7IwZuuTlyvCOmLQS+J2Rb2Z
         qVbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ltwp7XCyFAkwdAhMqzDIsh/0oySf9fTzh9l18aVXPw0=;
        b=QGMU6X4gxXivjdwKfVJPrcHxVVb5Eqb/qquOFaKK7GgwfVwpa1AjP5mT4o+tvOuw9+
         WLel2IYtjWv5hGZkgzgvT4IZL8e4Hu4U5XtTJu3dwP1S2t/NXKaJo2eiB/ds6xx0/OaK
         giQB+jLS07Il3NSmjulx1Fh8K8UPaXdSV9tgyQa3oOjwmOrCeoAPuNWVlq40l+YJoXF3
         Xb26lInHC4FPEvZU4MBfGAb9xAoMvAuHmVFFOkNevX2mIg5KLJH9iVhRjtfKiHVR3Rn1
         28uW8phNeTof9PQwYQ5HOQdQ529cLXmt2cSDg17jM8Sc0I/1PRt5R+gB9L6pAGJgm6sO
         tZeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=u4farRz9;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 3si47344826plo.300.2019.05.02.06.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 May 2019 06:46:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=u4farRz9;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Ltwp7XCyFAkwdAhMqzDIsh/0oySf9fTzh9l18aVXPw0=; b=u4farRz9CzO/iV6mYcVpx1ziV
	EHp2FZZQs1oTN0ZXaKEx2cQcyoit5UcB6kdWCiDFAaYvlPsBYj9fmR0+6nDRDwUCkGtttRwQQdjVq
	4Unx0ZTEyS79pvDZMeEGucxYEO6GuOB2/xu47QY6xEQRFr8E1mNSzeGlFKgGHe8X++7UwK7UJkONp
	Q3PYMETLR+gL50iTeBnsH9IT9A3X/I5/WKfeFoqP0PFEHsYks4hzz89MN39ScqHfl6vZJC+HXX6qT
	kpAJI01WIpFU5Jl2NN6MaS5Z0yoj+L1jtUONnF7vfq7a2W4jQzBA8ONYtcWRa2OXyIoeM7e8fiOT8
	Hnrz3iVGA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hMC2Z-0007SZ-Pj; Thu, 02 May 2019 13:46:23 +0000
Date: Thu, 2 May 2019 06:46:23 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>, jglisse@redhat.com,
	Mike Rapoport <rppt@linux.vnet.ibm.com>, x86@kernel.org,
	linux-efi@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
	intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	schwidefsky@de.ibm.com
Subject: Re: [PATCH] mm/pgtable: Drop pgtable_t variable from pte_fn_t
 functions
Message-ID: <20190502134623.GA18948@bombadil.infradead.org>
References: <1556803126-26596-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556803126-26596-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 06:48:46PM +0530, Anshuman Khandual wrote:
> Drop the pgtable_t variable from all implementation for pte_fn_t as none of
> them use it. apply_to_pte_range() should stop computing it as well. Should
> help us save some cycles.

You didn't add Martin Schwidefsky for some reason.  He introduced
it originally for s390 for sub-page page tables back in 2008 (commit
2f569afd9c).  I think he should confirm that he no longer needs it.

> ---
> - Boot tested on arm64 and x86 platforms.
> - Build tested on multiple platforms with their defconfig
> 
>  arch/arm/kernel/efi.c          | 3 +--
>  arch/arm/mm/dma-mapping.c      | 3 +--
>  arch/arm/mm/pageattr.c         | 3 +--
>  arch/arm64/kernel/efi.c        | 3 +--
>  arch/arm64/mm/pageattr.c       | 3 +--
>  arch/x86/xen/mmu_pv.c          | 3 +--
>  drivers/gpu/drm/i915/i915_mm.c | 3 +--
>  drivers/xen/gntdev.c           | 6 ++----
>  drivers/xen/privcmd.c          | 6 ++----
>  drivers/xen/xlate_mmu.c        | 3 +--
>  include/linux/mm.h             | 3 +--
>  mm/memory.c                    | 5 +----
>  mm/vmalloc.c                   | 2 +-
>  13 files changed, 15 insertions(+), 31 deletions(-)
> 
> diff --git a/arch/arm/kernel/efi.c b/arch/arm/kernel/efi.c
> index 9f43ba012d10..b1f142a01f2f 100644
> --- a/arch/arm/kernel/efi.c
> +++ b/arch/arm/kernel/efi.c
> @@ -11,8 +11,7 @@
>  #include <asm/mach/map.h>
>  #include <asm/mmu_context.h>
>  
> -static int __init set_permissions(pte_t *ptep, pgtable_t token,
> -				  unsigned long addr, void *data)
> +static int __init set_permissions(pte_t *ptep, unsigned long addr, void *data)
>  {
>  	efi_memory_desc_t *md = data;
>  	pte_t pte = *ptep;
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 43f46aa7ef33..739286511a18 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -496,8 +496,7 @@ void __init dma_contiguous_remap(void)
>  	}
>  }
>  
> -static int __dma_update_pte(pte_t *pte, pgtable_t token, unsigned long addr,
> -			    void *data)
> +static int __dma_update_pte(pte_t *pte, unsigned long addr, void *data)
>  {
>  	struct page *page = virt_to_page(addr);
>  	pgprot_t prot = *(pgprot_t *)data;
> diff --git a/arch/arm/mm/pageattr.c b/arch/arm/mm/pageattr.c
> index 1403cb4a0c3d..c8b500940e1f 100644
> --- a/arch/arm/mm/pageattr.c
> +++ b/arch/arm/mm/pageattr.c
> @@ -22,8 +22,7 @@ struct page_change_data {
>  	pgprot_t clear_mask;
>  };
>  
> -static int change_page_range(pte_t *ptep, pgtable_t token, unsigned long addr,
> -			void *data)
> +static int change_page_range(pte_t *ptep, unsigned long addr, void *data)
>  {
>  	struct page_change_data *cdata = data;
>  	pte_t pte = *ptep;
> diff --git a/arch/arm64/kernel/efi.c b/arch/arm64/kernel/efi.c
> index 4f9acb5fbe97..230cff073a08 100644
> --- a/arch/arm64/kernel/efi.c
> +++ b/arch/arm64/kernel/efi.c
> @@ -86,8 +86,7 @@ int __init efi_create_mapping(struct mm_struct *mm, efi_memory_desc_t *md)
>  	return 0;
>  }
>  
> -static int __init set_permissions(pte_t *ptep, pgtable_t token,
> -				  unsigned long addr, void *data)
> +static int __init set_permissions(pte_t *ptep, unsigned long addr, void *data)
>  {
>  	efi_memory_desc_t *md = data;
>  	pte_t pte = READ_ONCE(*ptep);
> diff --git a/arch/arm64/mm/pageattr.c b/arch/arm64/mm/pageattr.c
> index 6cd645edcf35..0be077628b21 100644
> --- a/arch/arm64/mm/pageattr.c
> +++ b/arch/arm64/mm/pageattr.c
> @@ -27,8 +27,7 @@ struct page_change_data {
>  
>  bool rodata_full __ro_after_init = IS_ENABLED(CONFIG_RODATA_FULL_DEFAULT_ENABLED);
>  
> -static int change_page_range(pte_t *ptep, pgtable_t token, unsigned long addr,
> -			void *data)
> +static int change_page_range(pte_t *ptep, unsigned long addr, void *data)
>  {
>  	struct page_change_data *cdata = data;
>  	pte_t pte = READ_ONCE(*ptep);
> diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
> index a21e1734fc1f..308a6195fd26 100644
> --- a/arch/x86/xen/mmu_pv.c
> +++ b/arch/x86/xen/mmu_pv.c
> @@ -2702,8 +2702,7 @@ struct remap_data {
>  	struct mmu_update *mmu_update;
>  };
>  
> -static int remap_area_pfn_pte_fn(pte_t *ptep, pgtable_t token,
> -				 unsigned long addr, void *data)
> +static int remap_area_pfn_pte_fn(pte_t *ptep, unsigned long addr, void *data)
>  {
>  	struct remap_data *rmd = data;
>  	pte_t pte = pte_mkspecial(mfn_pte(*rmd->pfn, rmd->prot));
> diff --git a/drivers/gpu/drm/i915/i915_mm.c b/drivers/gpu/drm/i915/i915_mm.c
> index e4935dd1fd37..c23bb29e6d3e 100644
> --- a/drivers/gpu/drm/i915/i915_mm.c
> +++ b/drivers/gpu/drm/i915/i915_mm.c
> @@ -35,8 +35,7 @@ struct remap_pfn {
>  	pgprot_t prot;
>  };
>  
> -static int remap_pfn(pte_t *pte, pgtable_t token,
> -		     unsigned long addr, void *data)
> +static int remap_pfn(pte_t *pte, unsigned long addr, void *data)
>  {
>  	struct remap_pfn *r = data;
>  
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index 7cf9c51318aa..f0df481e2697 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -264,8 +264,7 @@ void gntdev_put_map(struct gntdev_priv *priv, struct gntdev_grant_map *map)
>  
>  /* ------------------------------------------------------------------ */
>  
> -static int find_grant_ptes(pte_t *pte, pgtable_t token,
> -		unsigned long addr, void *data)
> +static int find_grant_ptes(pte_t *pte, unsigned long addr, void *data)
>  {
>  	struct gntdev_grant_map *map = data;
>  	unsigned int pgnr = (addr - map->vma->vm_start) >> PAGE_SHIFT;
> @@ -292,8 +291,7 @@ static int find_grant_ptes(pte_t *pte, pgtable_t token,
>  }
>  
>  #ifdef CONFIG_X86
> -static int set_grant_ptes_as_special(pte_t *pte, pgtable_t token,
> -				     unsigned long addr, void *data)
> +static int set_grant_ptes_as_special(pte_t *pte, unsigned long addr, void *data)
>  {
>  	set_pte_at(current->mm, addr, pte, pte_mkspecial(*pte));
>  	return 0;
> diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
> index b24ddac1604b..4c7268869e2c 100644
> --- a/drivers/xen/privcmd.c
> +++ b/drivers/xen/privcmd.c
> @@ -730,8 +730,7 @@ struct remap_pfn {
>  	unsigned long i;
>  };
>  
> -static int remap_pfn_fn(pte_t *ptep, pgtable_t token, unsigned long addr,
> -			void *data)
> +static int remap_pfn_fn(pte_t *ptep, unsigned long addr, void *data)
>  {
>  	struct remap_pfn *r = data;
>  	struct page *page = r->pages[r->i];
> @@ -965,8 +964,7 @@ static int privcmd_mmap(struct file *file, struct vm_area_struct *vma)
>   * on a per pfn/pte basis. Mapping calls that fail with ENOENT
>   * can be then retried until success.
>   */
> -static int is_mapped_fn(pte_t *pte, struct page *pmd_page,
> -	                unsigned long addr, void *data)
> +static int is_mapped_fn(pte_t *pte, unsigned long addr, void *data)
>  {
>  	return pte_none(*pte) ? 0 : -EBUSY;
>  }
> diff --git a/drivers/xen/xlate_mmu.c b/drivers/xen/xlate_mmu.c
> index e7df65d32c91..ba883a80b3c0 100644
> --- a/drivers/xen/xlate_mmu.c
> +++ b/drivers/xen/xlate_mmu.c
> @@ -93,8 +93,7 @@ static void setup_hparams(unsigned long gfn, void *data)
>  	info->fgfn++;
>  }
>  
> -static int remap_pte_fn(pte_t *ptep, pgtable_t token, unsigned long addr,
> -			void *data)
> +static int remap_pte_fn(pte_t *ptep, unsigned long addr, void *data)
>  {
>  	struct remap_data *info = data;
>  	struct page *page = info->pages[info->index++];
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 6b10c21630f5..f9509d57edc6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2595,8 +2595,7 @@ static inline int vm_fault_to_errno(vm_fault_t vm_fault, int foll_flags)
>  	return 0;
>  }
>  
> -typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
> -			void *data);
> +typedef int (*pte_fn_t)(pte_t *pte, unsigned long addr, void *data);
>  extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
>  			       unsigned long size, pte_fn_t fn, void *data);
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index ab650c21bccd..dd0e64c94ddc 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1952,7 +1952,6 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
>  {
>  	pte_t *pte;
>  	int err;
> -	pgtable_t token;
>  	spinlock_t *uninitialized_var(ptl);
>  
>  	pte = (mm == &init_mm) ?
> @@ -1965,10 +1964,8 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
>  
>  	arch_enter_lazy_mmu_mode();
>  
> -	token = pmd_pgtable(*pmd);
> -
>  	do {
> -		err = fn(pte++, token, addr, data);
> +		err = fn(pte++, addr, data);
>  		if (err)
>  			break;
>  	} while (addr += PAGE_SIZE, addr != end);
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index e86ba6e74b50..94533beb6b68 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2332,7 +2332,7 @@ void __weak vmalloc_sync_all(void)
>  }
>  
>  
> -static int f(pte_t *pte, pgtable_t table, unsigned long addr, void *data)
> +static int f(pte_t *pte, unsigned long addr, void *data)
>  {
>  	pte_t ***p = data;
>  
> -- 
> 2.20.1
> 

