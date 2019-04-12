Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8A71C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:09:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62077218C3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:09:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62077218C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D99426B026B; Fri, 12 Apr 2019 16:09:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D48086B026C; Fri, 12 Apr 2019 16:09:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BECE76B026D; Fri, 12 Apr 2019 16:09:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 82BCF6B026B
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 16:09:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v9so7165283pgg.8
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 13:09:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eENzJZ3ukgkx/rhF9t9g3NV5jZTKQ81zZ8+iPyj9x/U=;
        b=EDCaUGhhbSB//XlfOt8uHcRB+GC6MmsxSSuwZGy07zcsNOmsdnFatUjPmWptjzefpM
         yeNeUbNQlf/jXD7S6d+UWF7G7WJ4Q1+GiesHLmSz6NcDjyY+rlXe03cW0t24wAq9U2pJ
         y/rW3V9Nf8lxqQlw9l4G7zzzTnrgPYiIYhSUjd1pJuhfE6gqZg9/jpBBvBRNVo0/Bq+6
         ZRhqG0c5W4I8b/YUSvjRi8rI3f/7mlbjhR6tMOntcBZFSN2fXrrOzkf6KlsYyB9EdciR
         C6hToE4SAVfJZL1zsBxy1d0lLrN/+k3EGZtNrRNaVXeMXoHtAOfC+HbX4Xh9GmrpFHwY
         Janw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVaVL3vRsLYMUXalxY4+2AxQ56Mi/Inm+OLs6+Jsr4PTHI5RYbH
	fR4B9HSJBSDcNH2m4nfEok2NYIlqryUv7P0bmt5XNwHPw56jfbQA/OqfjZtS0kImbAytj90Qzuk
	ZyWaLC7NnzQH8d3Vmgg+727yihZYjfABKbGjiX0vhVzK1cVUO8vXGeWs2jZYvJE5q4A==
X-Received: by 2002:aa7:8609:: with SMTP id p9mr58632295pfn.166.1555099779891;
        Fri, 12 Apr 2019 13:09:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOM1uP8mzwrT1so+OVnOTvSZ3bRlZFDxrqVQAkQXY/DrJbjv29mnSKnVZbPH5IvG0pPOFq
X-Received: by 2002:aa7:8609:: with SMTP id p9mr58632223pfn.166.1555099779019;
        Fri, 12 Apr 2019 13:09:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555099779; cv=none;
        d=google.com; s=arc-20160816;
        b=wAMNX3W4zjJcMF3jsbah60JJKKmUOciMjvONblZiVp5fTbtd/ziMe6rqNtbDBm33hJ
         hNKpxdG2KY02trbdoNGTK9p91vM71Oi15/yVN//K8F+5mNzWTC4ybWXfV59auGPjGsgA
         1/8qL/lVL2VTvNCli1vCvfiMpzHr6ry2v5IegXtvLVH1LYlvJadrDwNKXbhzJhAIet/X
         gqXYfXxhd6la9giM0kb+NxX36D54U3khfEgBAdf2HNdba4lrrY6SWmQDyOm0tsJ3fyPH
         e1qmd3XgW5cjMcdDC1nRGYhEtiAKliYVkUbcXEcCL0vgVTmVF8CaRTNxYGIODqZRN11F
         VeoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eENzJZ3ukgkx/rhF9t9g3NV5jZTKQ81zZ8+iPyj9x/U=;
        b=YPTYNNER4k4JGpD+r3czeSYcDUBu29cq+Ydg5CYfHubK42di6wKlDvWx397YpCWGnR
         R+UXfY5tsLbg5ZFEHDL3W1apLMjPRPm6+9WPvkIxx8aNzowcingeH00hF8dnrqLWuEf3
         XMz0R0JQtRG7COZy21bLe3doFmL1TRmC2QxjCOGK7hAuO/ng/J5G40Bp2no6E4pXS0WH
         skPIyBNIwA1B9lHDuJCXu2JbbB6buqpiNQWuX+ZRHFBhuzo8J+FGJKuO+Kwav5dsWCGt
         dWCI01mwiF/UgWH3i0sRdZHN7RQPBft9EKC1RyYLa9OVYR2J9mBulVD9WWRYKizkJ5KD
         hrOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j7si36832560pfb.75.2019.04.12.13.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 13:09:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Apr 2019 13:09:33 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,342,1549958400"; 
   d="scan'208";a="291124058"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga004.jf.intel.com with ESMTP; 12 Apr 2019 13:09:32 -0700
Date: Fri, 12 Apr 2019 13:09:30 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, dan.j.williams@intel.com, jglisse@redhat.com,
	ohall@gmail.com, x86@kernel.org, linuxppc-dev@lists.ozlabs.org,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/3] mm: introduce ARCH_HAS_PTE_DEVMAP
Message-ID: <20190412200930.GA26371@iweiny-DESK2.sc.intel.com>
References: <cover.1555093412.git.robin.murphy@arm.com>
 <25525e4dab6ebc49e233f21f7c29821223431647.1555093412.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <25525e4dab6ebc49e233f21f7c29821223431647.1555093412.git.robin.murphy@arm.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 07:56:02PM +0100, Robin Murphy wrote:
> ARCH_HAS_ZONE_DEVICE is somewhat meaningless in itself, and combined
> with the long-out-of-date comment can lead to the impression than an
> architecture may just enable it (since __add_pages() now "comprehends
> device memory" for itself) and expect things to work.
> 
> In practice, however, ZONE_DEVICE users have little chance of
> functioning correctly without __HAVE_ARCH_PTE_DEVMAP, so let's clean
> that up the same way as ARCH_HAS_PTE_SPECIAL and make it the proper
> dependency so the real situation is clearer.
> 
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  arch/powerpc/Kconfig                         | 2 +-
>  arch/powerpc/include/asm/book3s/64/pgtable.h | 1 -
>  arch/x86/Kconfig                             | 2 +-
>  arch/x86/include/asm/pgtable.h               | 4 ++--
>  arch/x86/include/asm/pgtable_types.h         | 1 -
>  include/linux/mm.h                           | 4 ++--
>  include/linux/pfn_t.h                        | 4 ++--
>  mm/Kconfig                                   | 5 ++---
>  mm/gup.c                                     | 2 +-
>  9 files changed, 11 insertions(+), 14 deletions(-)
> 
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 5e3d0853c31d..77e1993bba80 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -135,6 +135,7 @@ config PPC
>  	select ARCH_HAS_MMIOWB			if PPC64
>  	select ARCH_HAS_PHYS_TO_DMA
>  	select ARCH_HAS_PMEM_API                if PPC64
> +	select ARCH_HAS_PTE_DEVMAP		if PPC_BOOK3S_64
>  	select ARCH_HAS_PTE_SPECIAL
>  	select ARCH_HAS_MEMBARRIER_CALLBACKS
>  	select ARCH_HAS_SCALED_CPUTIME		if VIRT_CPU_ACCOUNTING_NATIVE && PPC64
> @@ -142,7 +143,6 @@ config PPC
>  	select ARCH_HAS_TICK_BROADCAST		if GENERIC_CLOCKEVENTS_BROADCAST
>  	select ARCH_HAS_UACCESS_FLUSHCACHE	if PPC64
>  	select ARCH_HAS_UBSAN_SANITIZE_ALL
> -	select ARCH_HAS_ZONE_DEVICE		if PPC_BOOK3S_64
>  	select ARCH_HAVE_NMI_SAFE_CMPXCHG
>  	select ARCH_MIGHT_HAVE_PC_PARPORT
>  	select ARCH_MIGHT_HAVE_PC_SERIO
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 581f91be9dd4..02c22ac8f387 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -90,7 +90,6 @@
>  #define _PAGE_SOFT_DIRTY	_RPAGE_SW3 /* software: software dirty tracking */
>  #define _PAGE_SPECIAL		_RPAGE_SW2 /* software: special page */
>  #define _PAGE_DEVMAP		_RPAGE_SW1 /* software: ZONE_DEVICE page */
> -#define __HAVE_ARCH_PTE_DEVMAP
>  
>  /*
>   * Drivers request for cache inhibited pte mapping using _PAGE_NO_CACHE
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 5ad92419be19..ffd50f27f395 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -60,6 +60,7 @@ config X86
>  	select ARCH_HAS_KCOV			if X86_64
>  	select ARCH_HAS_MEMBARRIER_SYNC_CORE
>  	select ARCH_HAS_PMEM_API		if X86_64
> +	select ARCH_HAS_PTE_DEVMAP		if X86_64
>  	select ARCH_HAS_PTE_SPECIAL
>  	select ARCH_HAS_REFCOUNT
>  	select ARCH_HAS_UACCESS_FLUSHCACHE	if X86_64
> @@ -69,7 +70,6 @@ config X86
>  	select ARCH_HAS_STRICT_MODULE_RWX
>  	select ARCH_HAS_SYNC_CORE_BEFORE_USERMODE
>  	select ARCH_HAS_UBSAN_SANITIZE_ALL
> -	select ARCH_HAS_ZONE_DEVICE		if X86_64
>  	select ARCH_HAVE_NMI_SAFE_CMPXCHG
>  	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
>  	select ARCH_MIGHT_HAVE_PC_PARPORT
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 2779ace16d23..89a1f6fd48bf 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -254,7 +254,7 @@ static inline int has_transparent_hugepage(void)
>  	return boot_cpu_has(X86_FEATURE_PSE);
>  }
>  
> -#ifdef __HAVE_ARCH_PTE_DEVMAP
> +#ifdef CONFIG_ARCH_HAS_PTE_DEVMAP
>  static inline int pmd_devmap(pmd_t pmd)
>  {
>  	return !!(pmd_val(pmd) & _PAGE_DEVMAP);
> @@ -715,7 +715,7 @@ static inline int pte_present(pte_t a)
>  	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
>  }
>  
> -#ifdef __HAVE_ARCH_PTE_DEVMAP
> +#ifdef CONFIG_ARCH_HAS_PTE_DEVMAP


>  static inline int pte_devmap(pte_t a)
>  {
>  	return (pte_flags(a) & _PAGE_DEVMAP) == _PAGE_DEVMAP;
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index d6ff0bbdb394..b5e49e6bac63 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -103,7 +103,6 @@
>  #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
>  #define _PAGE_NX	(_AT(pteval_t, 1) << _PAGE_BIT_NX)
>  #define _PAGE_DEVMAP	(_AT(u64, 1) << _PAGE_BIT_DEVMAP)
> -#define __HAVE_ARCH_PTE_DEVMAP
>  #else
>  #define _PAGE_NX	(_AT(pteval_t, 0))
>  #define _PAGE_DEVMAP	(_AT(pteval_t, 0))
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index d76dfb7ac617..fe05c94f23e9 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -504,7 +504,7 @@ struct inode;
>  #define page_private(page)		((page)->private)
>  #define set_page_private(page, v)	((page)->private = (v))
>  
> -#if !defined(__HAVE_ARCH_PTE_DEVMAP) || !defined(CONFIG_TRANSPARENT_HUGEPAGE)
> +#if !defined(CONFIG_ARCH_HAS_PTE_DEVMAP) || !defined(CONFIG_TRANSPARENT_HUGEPAGE)
>  static inline int pmd_devmap(pmd_t pmd)
>  {
>  	return 0;
> @@ -1698,7 +1698,7 @@ static inline void sync_mm_rss(struct mm_struct *mm)
>  }
>  #endif
>  
> -#ifndef __HAVE_ARCH_PTE_DEVMAP
> +#ifndef CONFIG_ARCH_HAS_PTE_DEVMAP
>  static inline int pte_devmap(pte_t pte)
>  {
>  	return 0;
> diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
> index 7bb77850c65a..de8bc66b10a4 100644
> --- a/include/linux/pfn_t.h
> +++ b/include/linux/pfn_t.h
> @@ -104,7 +104,7 @@ static inline pud_t pfn_t_pud(pfn_t pfn, pgprot_t pgprot)
>  #endif
>  #endif
>  
> -#ifdef __HAVE_ARCH_PTE_DEVMAP
> +#ifdef CONFIG_ARCH_HAS_PTE_DEVMAP
>  static inline bool pfn_t_devmap(pfn_t pfn)
>  {
>  	const u64 flags = PFN_DEV|PFN_MAP;
> @@ -122,7 +122,7 @@ pmd_t pmd_mkdevmap(pmd_t pmd);
>  	defined(CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD)
>  pud_t pud_mkdevmap(pud_t pud);
>  #endif
> -#endif /* __HAVE_ARCH_PTE_DEVMAP */
> +#endif /* CONFIG_ARCH_HAS_PTE_DEVMAP */
>  
>  #ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
>  static inline bool pfn_t_special(pfn_t pfn)
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 25c71eb8a7db..fcb7ab08e294 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -655,8 +655,7 @@ config IDLE_PAGE_TRACKING
>  	  See Documentation/admin-guide/mm/idle_page_tracking.rst for
>  	  more details.
>  
> -# arch_add_memory() comprehends device memory
> -config ARCH_HAS_ZONE_DEVICE
> +config ARCH_HAS_PTE_DEVMAP
>  	bool
>  
>  config ZONE_DEVICE
> @@ -664,7 +663,7 @@ config ZONE_DEVICE
>  	depends on MEMORY_HOTPLUG
>  	depends on MEMORY_HOTREMOVE
>  	depends on SPARSEMEM_VMEMMAP
> -	depends on ARCH_HAS_ZONE_DEVICE
> +	depends on ARCH_HAS_PTE_DEVMAP
>  	select XARRAY_MULTI
>  
>  	help
> diff --git a/mm/gup.c b/mm/gup.c
> index f84e22685aaa..72a5c7d1e1a7 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1623,7 +1623,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>  }
>  #endif /* CONFIG_ARCH_HAS_PTE_SPECIAL */
>  
> -#if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
> +#if defined(CONFIG_ARCH_HAS_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
>  static int __gup_device_huge(unsigned long pfn, unsigned long addr,
>  		unsigned long end, struct page **pages, int *nr)
>  {
> -- 
> 2.21.0.dirty
> 

