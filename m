Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB97EC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A926218E2
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:52:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A926218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC29A6B0005; Thu, 21 Mar 2019 09:52:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E73886B0008; Thu, 21 Mar 2019 09:52:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3BFF6B000A; Thu, 21 Mar 2019 09:52:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACAA16B0005
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 09:52:07 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id y64so16272835qka.3
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 06:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=v9cAia9zyHt3Xo/+tUI1gBrDWkNFrx1j07K0lf6crT0=;
        b=dC9xgHnqJ+T4twrdu16CqNCASfwWFgpIVcjHprsIuxk8PWNaLTtCohIDzrHuBgtkIa
         EjwsTVo+QEeTQqzB7j0XEBCVhGqt0gURiEZTN1z6somSl2PHVR/gkT0EUw1vfBRiNoDg
         RcrDZCMvwKx37pqDtNyks60MDS0SLp9UOSQXRk+cbf6BzYueVTeNdsOSOkAdC/lavdFT
         gzeshjw11RA2S8um/cNDg/Ska7mkbqTUFjI6on2/eApL5YL0OaYIMJf/DGM+5+cNx+nr
         OFXYMKF3aJuzKcMP8Ew/NXIHjr0UpK09doiP8wZMpGlQi0iDcSX9d5EX7di+R0GxlJNQ
         y8Dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUZjxnPVKE4mIhyc3D7OsgnAvLIRdLuCrFii58WdkpEHOHoolWn
	xeGwnhPbasb9eZTWxdv1fYyx8KswX4fXLozHCGIYTM4tZsuPYTXT8XBSfurdDCQ2wFycR+eOqgJ
	hn9eEPWRhFnKxexSE3/2uyjseB6u1IkM5D9+KixyOdeqIMJKRoeGayKpBbEH0u9Eoqg==
X-Received: by 2002:a37:dd91:: with SMTP id u17mr2698268qku.264.1553176327408;
        Thu, 21 Mar 2019 06:52:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmtjbehk8/flE4i16DJtZ4PcISh6bl6t+78H8ToLBZPPTzdNo2C4Yx95T+8/igDuWURGgv
X-Received: by 2002:a37:dd91:: with SMTP id u17mr2698220qku.264.1553176326661;
        Thu, 21 Mar 2019 06:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553176326; cv=none;
        d=google.com; s=arc-20160816;
        b=iAM2wSDZMPI9UmKWccLeXhs0/vEm7x8S5sEl21Gx1765IGQkb25ByazPvBCxJhkfi7
         9Okz8largPEsLM1PGMgcmy20Qx6/+YCR/1sd7q5FnX/M3IlOrqV11lQGgujBGtj/UWfO
         AdC0lClJm+kM4m+0Eeo9fGPxyGZCyWFi+CeD20hOLuxYEmveWaLaEIkF1uXDHmseCi8G
         pAPJZxvTG9zoIpv8uTdzKUiJOj6W4dT5Md2uqL4kiXtmTijOv2DaRBw4/TN9PpTW5Mij
         h/KyZif6XfGOUtBdlZpXldBelIkURKjsmzE2A4yOArU7XBREPlCFcUzw9KoX+6n0YwWW
         9N4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=v9cAia9zyHt3Xo/+tUI1gBrDWkNFrx1j07K0lf6crT0=;
        b=o68J87WVhyIzMonF97M4S6u3r8fswCT8fu6x3vr4xefuuMkvWztio4rXr/ftXUHxad
         C7TdFJZWrL6DTfB9ku0OkMQgj+Tu1ihtDbx0+nhbLA8BICm+NMPPjPaC0VEqCn3m+Nil
         mjFls/WGDbzW+siT6XygU9BKzBsWfQPrU+sRRMLC8wmz9IXWFUqPJ4QDnCSKpiNGIqsI
         S/1UovDE6OIcip23iramUR7gbne0TEKKXxNa9wSa1ea5gg8Eg2JGVjrQj0u0KMiemBJs
         7MMNsHXictb9badPJEUuOmApwEn2lmS3xDp4ISUyQc70e3VnvNaU1EY4hkWyc9lAk5yq
         bzPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c78si1647206qkj.39.2019.03.21.06.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 06:52:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A80E588AA3;
	Thu, 21 Mar 2019 13:52:05 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 116B919C7F;
	Thu, 21 Mar 2019 13:52:03 +0000 (UTC)
Date: Thu, 21 Mar 2019 09:52:02 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH RESEND 2/3] mm: Add an apply_to_pfn_range interface
Message-ID: <20190321135202.GC2904@redhat.com>
References: <20190321132140.114878-1-thellstrom@vmware.com>
 <20190321132140.114878-3-thellstrom@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190321132140.114878-3-thellstrom@vmware.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 21 Mar 2019 13:52:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 01:22:35PM +0000, Thomas Hellstrom wrote:
> This is basically apply_to_page_range with added functionality:
> Allocating missing parts of the page table becomes optional, which
> means that the function can be guaranteed not to error if allocation
> is disabled. Also passing of the closure struct and callback function
> becomes different and more in line with how things are done elsewhere.
> 
> Finally we keep apply_to_page_range as a wrapper around apply_to_pfn_range

The apply_to_page_range() is dangerous API it does not follow other
mm patterns like mmu notifier. It is suppose to be use in arch code
or vmalloc or similar thing but not in regular driver code. I see
it has crept out of this and is being use by few device driver. I am
not sure we should encourage that.

> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: "Jérôme Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
> ---
>  include/linux/mm.h |  10 ++++
>  mm/memory.c        | 121 +++++++++++++++++++++++++++++++++------------
>  2 files changed, 99 insertions(+), 32 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80bb6408fe73..b7dd4ddd6efb 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2632,6 +2632,16 @@ typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
>  extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
>  			       unsigned long size, pte_fn_t fn, void *data);
>  
> +struct pfn_range_apply;
> +typedef int (*pter_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
> +			 struct pfn_range_apply *closure);
> +struct pfn_range_apply {
> +	struct mm_struct *mm;
> +	pter_fn_t ptefn;
> +	unsigned int alloc;
> +};
> +extern int apply_to_pfn_range(struct pfn_range_apply *closure,
> +			      unsigned long address, unsigned long size);
>  
>  #ifdef CONFIG_PAGE_POISONING
>  extern bool page_poisoning_enabled(void);
> diff --git a/mm/memory.c b/mm/memory.c
> index dcd80313cf10..0feb7191c2d2 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1938,18 +1938,17 @@ int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long
>  }
>  EXPORT_SYMBOL(vm_iomap_memory);
>  
> -static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
> -				     unsigned long addr, unsigned long end,
> -				     pte_fn_t fn, void *data)
> +static int apply_to_pte_range(struct pfn_range_apply *closure, pmd_t *pmd,
> +			      unsigned long addr, unsigned long end)
>  {
>  	pte_t *pte;
>  	int err;
>  	pgtable_t token;
>  	spinlock_t *uninitialized_var(ptl);
>  
> -	pte = (mm == &init_mm) ?
> +	pte = (closure->mm == &init_mm) ?
>  		pte_alloc_kernel(pmd, addr) :
> -		pte_alloc_map_lock(mm, pmd, addr, &ptl);
> +		pte_alloc_map_lock(closure->mm, pmd, addr, &ptl);
>  	if (!pte)
>  		return -ENOMEM;
>  
> @@ -1960,86 +1959,103 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
>  	token = pmd_pgtable(*pmd);
>  
>  	do {
> -		err = fn(pte++, token, addr, data);
> +		err = closure->ptefn(pte++, token, addr, closure);
>  		if (err)
>  			break;
>  	} while (addr += PAGE_SIZE, addr != end);
>  
>  	arch_leave_lazy_mmu_mode();
>  
> -	if (mm != &init_mm)
> +	if (closure->mm != &init_mm)
>  		pte_unmap_unlock(pte-1, ptl);
>  	return err;
>  }
>  
> -static int apply_to_pmd_range(struct mm_struct *mm, pud_t *pud,
> -				     unsigned long addr, unsigned long end,
> -				     pte_fn_t fn, void *data)
> +static int apply_to_pmd_range(struct pfn_range_apply *closure, pud_t *pud,
> +			      unsigned long addr, unsigned long end)
>  {
>  	pmd_t *pmd;
>  	unsigned long next;
> -	int err;
> +	int err = 0;
>  
>  	BUG_ON(pud_huge(*pud));
>  
> -	pmd = pmd_alloc(mm, pud, addr);
> +	pmd = pmd_alloc(closure->mm, pud, addr);
>  	if (!pmd)
>  		return -ENOMEM;
> +
>  	do {
>  		next = pmd_addr_end(addr, end);
> -		err = apply_to_pte_range(mm, pmd, addr, next, fn, data);
> +		if (!closure->alloc && pmd_none_or_clear_bad(pmd))
> +			continue;
> +		err = apply_to_pte_range(closure, pmd, addr, next);
>  		if (err)
>  			break;
>  	} while (pmd++, addr = next, addr != end);
>  	return err;
>  }
>  
> -static int apply_to_pud_range(struct mm_struct *mm, p4d_t *p4d,
> -				     unsigned long addr, unsigned long end,
> -				     pte_fn_t fn, void *data)
> +static int apply_to_pud_range(struct pfn_range_apply *closure, p4d_t *p4d,
> +			      unsigned long addr, unsigned long end)
>  {
>  	pud_t *pud;
>  	unsigned long next;
> -	int err;
> +	int err = 0;
>  
> -	pud = pud_alloc(mm, p4d, addr);
> +	pud = pud_alloc(closure->mm, p4d, addr);
>  	if (!pud)
>  		return -ENOMEM;
> +
>  	do {
>  		next = pud_addr_end(addr, end);
> -		err = apply_to_pmd_range(mm, pud, addr, next, fn, data);
> +		if (!closure->alloc && pud_none_or_clear_bad(pud))
> +			continue;
> +		err = apply_to_pmd_range(closure, pud, addr, next);
>  		if (err)
>  			break;
>  	} while (pud++, addr = next, addr != end);
>  	return err;
>  }
>  
> -static int apply_to_p4d_range(struct mm_struct *mm, pgd_t *pgd,
> -				     unsigned long addr, unsigned long end,
> -				     pte_fn_t fn, void *data)
> +static int apply_to_p4d_range(struct pfn_range_apply *closure, pgd_t *pgd,
> +			      unsigned long addr, unsigned long end)
>  {
>  	p4d_t *p4d;
>  	unsigned long next;
> -	int err;
> +	int err = 0;
>  
> -	p4d = p4d_alloc(mm, pgd, addr);
> +	p4d = p4d_alloc(closure->mm, pgd, addr);
>  	if (!p4d)
>  		return -ENOMEM;
> +
>  	do {
>  		next = p4d_addr_end(addr, end);
> -		err = apply_to_pud_range(mm, p4d, addr, next, fn, data);
> +		if (!closure->alloc && p4d_none_or_clear_bad(p4d))
> +			continue;
> +		err = apply_to_pud_range(closure, p4d, addr, next);
>  		if (err)
>  			break;
>  	} while (p4d++, addr = next, addr != end);
>  	return err;
>  }
>  
> -/*
> - * Scan a region of virtual memory, filling in page tables as necessary
> - * and calling a provided function on each leaf page table.
> +/**
> + * apply_to_pfn_range - Scan a region of virtual memory, calling a provided
> + * function on each leaf page table entry
> + * @closure: Details about how to scan and what function to apply
> + * @addr: Start virtual address
> + * @size: Size of the region
> + *
> + * If @closure->alloc is set to 1, the function will fill in the page table
> + * as necessary. Otherwise it will skip non-present parts.
> + *
> + * Returns: Zero on success. If the provided function returns a non-zero status,
> + * the page table walk will terminate and that status will be returned.
> + * If @closure->alloc is set to 1, then this function may also return memory
> + * allocation errors arising from allocating page table memory.
>   */
> -int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
> -			unsigned long size, pte_fn_t fn, void *data)
> +int apply_to_pfn_range(struct pfn_range_apply *closure,
> +		       unsigned long addr, unsigned long size)
>  {
>  	pgd_t *pgd;
>  	unsigned long next;
> @@ -2049,16 +2065,57 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>  	if (WARN_ON(addr >= end))
>  		return -EINVAL;
>  
> -	pgd = pgd_offset(mm, addr);
> +	pgd = pgd_offset(closure->mm, addr);
>  	do {
>  		next = pgd_addr_end(addr, end);
> -		err = apply_to_p4d_range(mm, pgd, addr, next, fn, data);
> +		if (!closure->alloc && pgd_none_or_clear_bad(pgd))
> +			continue;
> +		err = apply_to_p4d_range(closure, pgd, addr, next);
>  		if (err)
>  			break;
>  	} while (pgd++, addr = next, addr != end);
>  
>  	return err;
>  }
> +EXPORT_SYMBOL_GPL(apply_to_pfn_range);
> +
> +struct page_range_apply {
> +	struct pfn_range_apply pter;
> +	pte_fn_t fn;
> +	void *data;
> +};
> +
> +/*
> + * Callback wrapper to enable use of apply_to_pfn_range for
> + * the apply_to_page_range interface
> + */
> +static int apply_to_page_range_wrapper(pte_t *pte, pgtable_t token,
> +				       unsigned long addr,
> +				       struct pfn_range_apply *pter)
> +{
> +	struct page_range_apply *pra =
> +		container_of(pter, typeof(*pra), pter);
> +
> +	return pra->fn(pte, token, addr, pra->data);
> +}
> +
> +/*
> + * Scan a region of virtual memory, filling in page tables as necessary
> + * and calling a provided function on each leaf page table.
> + */
> +int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
> +			unsigned long size, pte_fn_t fn, void *data)
> +{
> +	struct page_range_apply pra = {
> +		.pter = {.mm = mm,
> +			 .alloc = 1,
> +			 .ptefn = apply_to_page_range_wrapper },
> +		.fn = fn,
> +		.data = data
> +	};
> +
> +	return apply_to_pfn_range(&pra.pter, addr, size);
> +}
>  EXPORT_SYMBOL_GPL(apply_to_page_range);
>  
>  /*
> -- 
> 2.19.0.rc1
> 

