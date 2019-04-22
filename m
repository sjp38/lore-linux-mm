Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FE50C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:15:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42F7B20675
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:15:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42F7B20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5D646B0003; Mon, 22 Apr 2019 16:15:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE6006B0006; Mon, 22 Apr 2019 16:15:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B85E76B0007; Mon, 22 Apr 2019 16:15:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91C306B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 16:15:13 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c2so4286231qkm.4
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 13:15:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=usy6KlDXmrzbTI14u51QQ7/c6sQhb2wOZozYJa7szIM=;
        b=fdKdcDxJJIsbBhJ7d03+EzuIjP/ehZwyiYyFhsxSqpSoFxvXKkqne0umsTy6Kyr8LH
         FyTgSabNvyXWgSo9aVLnj5XswBYOb5JA8bfFPet3rCDFFGP7frM1OL1e7EfPp9UonBiW
         wDfo33H/vsrpaa8r1oeHMVVXTnD/30veytydGNPmgFY0PM5HhfvliD6+444zTpvijDh/
         KsthifpCHS9kprrJjNr9Kd9mbyBQoF1b2MGIwYuRh/6d0bOSOdobVHoeS3GYTysXve+m
         YM/Qbr2xiLXewOQUMHtfIMaxFALZ/LBifls8mSVDcJurPiwSGeUfNjNtwn4H0Incegd3
         gOCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWmuQIomCZORf1lk8/45VbSBUF1C0Yyy8K2kcteJ42C7IXI60mV
	qA7Cght277XJh5janu0qEO1rjexjzFHfqP7r0KOqf84Bk+DhsCRz7LTAZXTEaOs7BxSOwSqnTn2
	P3nO/MyVpyDPmSZfXHYV5+P0+gEmFGrRZJ5YuNmmIEYs5M0a6NwVK2x+AhpV2efhVdA==
X-Received: by 2002:a0c:b6d1:: with SMTP id h17mr16762091qve.38.1555964113343;
        Mon, 22 Apr 2019 13:15:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXp1Jo89ZRh4Nx3YZ2rgE3xgu+1CR95j+VWYoycsy3K7S79Ae1pHANnzut3ho+P4j/mzt3
X-Received: by 2002:a0c:b6d1:: with SMTP id h17mr16762029qve.38.1555964112555;
        Mon, 22 Apr 2019 13:15:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555964112; cv=none;
        d=google.com; s=arc-20160816;
        b=NkC5U+hpgUiupeXui+L6TgoGgo8kFczvD1WdYo1XCN9fjuBfA3xnyln7LvtRFYlR6p
         g1wFTO2ecJsIn+bZf2tbIQOq8S/h0C/JLCT82NDXTP2sy3UaIKB+cQkUDnnT2Y44SXhP
         6mnE4X5KFEBhvflU1RAycw6JUeQDKGB55qoSksGxyxFbgA3N6NGlw2EoX9/WxtQo5pEH
         e5Xq/teKGlyv2CZNlUIpeceb3SfPKy9iqIyaqnphPtRNclMLtdnlej5pIpUb+kh4TcQ3
         Ma1yuYW5dPNR+XWrh95UHVVsuXBlp6LKaiHRt0LiTveLwnqJo3TyoswU4Gy7HSySArlf
         tH9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=usy6KlDXmrzbTI14u51QQ7/c6sQhb2wOZozYJa7szIM=;
        b=N+YQlO9kZXesLMYNbYUkiszqm6vRAFUhxgfy+gDcc4NIBjPQi5kGQbR1flMQLUGxPE
         +5l8V1Nv3Ln60NhEBIyLM/JtkcvTje70cQKszURf8A9GBYIsihb+OrvYi3NdkFmjuuNm
         CHeGxqrjWwgvkG1e+qSKu5uwYzNpBLr1SVtGnjAqRBksOdAf6u137XOXZ6zDa9iD3P5/
         eD2qJxspV6mTflWqPZv5xg6bFnuBfF+1w5na/n3N/Xu0qjvh7Imi+qI6of7mvGDBmyRN
         Ggt6X1m3OTFphUaefqe1tELlboloFWwQPa3CYK+Bc2wfk8J1D3KVDJNTHA52Yy6afsCH
         oqPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 58si3947965qvq.19.2019.04.22.13.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 13:15:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0482930832F4;
	Mon, 22 Apr 2019 20:15:11 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C81C71001DED;
	Mon, 22 Apr 2019 20:15:06 +0000 (UTC)
Date: Mon, 22 Apr 2019 16:15:05 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 16/31] mm: introduce __vm_normal_page()
Message-ID: <20190422201504.GG14666@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-17-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-17-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 22 Apr 2019 20:15:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:07PM +0200, Laurent Dufour wrote:
> When dealing with the speculative fault path we should use the VMA's field
> cached value stored in the vm_fault structure.
> 
> Currently vm_normal_page() is using the pointer to the VMA to fetch the
> vm_flags value. This patch provides a new __vm_normal_page() which is
> receiving the vm_flags flags value as parameter.
> 
> Note: The speculative path is turned on for architecture providing support
> for special PTE flag. So only the first block of vm_normal_page is used
> during the speculative path.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/mm.h | 18 +++++++++++++++---
>  mm/memory.c        | 21 ++++++++++++---------
>  2 files changed, 27 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f465bb2b049e..f14b2c9ddfd4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1421,9 +1421,21 @@ static inline void INIT_VMA(struct vm_area_struct *vma)
>  #endif
>  }
>  
> -struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> -			     pte_t pte, bool with_public_device);
> -#define vm_normal_page(vma, addr, pte) _vm_normal_page(vma, addr, pte, false)
> +struct page *__vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> +			      pte_t pte, bool with_public_device,
> +			      unsigned long vma_flags);
> +static inline struct page *_vm_normal_page(struct vm_area_struct *vma,
> +					    unsigned long addr, pte_t pte,
> +					    bool with_public_device)
> +{
> +	return __vm_normal_page(vma, addr, pte, with_public_device,
> +				vma->vm_flags);
> +}
> +static inline struct page *vm_normal_page(struct vm_area_struct *vma,
> +					  unsigned long addr, pte_t pte)
> +{
> +	return _vm_normal_page(vma, addr, pte, false);
> +}
>  
>  struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
>  				pmd_t pmd);
> diff --git a/mm/memory.c b/mm/memory.c
> index 85ec5ce5c0a8..be93f2c8ebe0 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -533,7 +533,8 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
>  }
>  
>  /*
> - * vm_normal_page -- This function gets the "struct page" associated with a pte.
> + * __vm_normal_page -- This function gets the "struct page" associated with
> + * a pte.
>   *
>   * "Special" mappings do not wish to be associated with a "struct page" (either
>   * it doesn't exist, or it exists but they don't want to touch it). In this
> @@ -574,8 +575,9 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
>   * PFNMAP mappings in order to support COWable mappings.
>   *
>   */
> -struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> -			     pte_t pte, bool with_public_device)
> +struct page *__vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> +			      pte_t pte, bool with_public_device,
> +			      unsigned long vma_flags)
>  {
>  	unsigned long pfn = pte_pfn(pte);
>  
> @@ -584,7 +586,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>  			goto check_pfn;
>  		if (vma->vm_ops && vma->vm_ops->find_special_page)
>  			return vma->vm_ops->find_special_page(vma, addr);
> -		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
> +		if (vma_flags & (VM_PFNMAP | VM_MIXEDMAP))
>  			return NULL;
>  		if (is_zero_pfn(pfn))
>  			return NULL;
> @@ -620,8 +622,8 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>  
>  	/* !CONFIG_ARCH_HAS_PTE_SPECIAL case follows: */
>  
> -	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
> -		if (vma->vm_flags & VM_MIXEDMAP) {
> +	if (unlikely(vma_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
> +		if (vma_flags & VM_MIXEDMAP) {
>  			if (!pfn_valid(pfn))
>  				return NULL;
>  			goto out;
> @@ -630,7 +632,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>  			off = (addr - vma->vm_start) >> PAGE_SHIFT;
>  			if (pfn == vma->vm_pgoff + off)
>  				return NULL;
> -			if (!is_cow_mapping(vma->vm_flags))
> +			if (!is_cow_mapping(vma_flags))
>  				return NULL;
>  		}
>  	}
> @@ -2532,7 +2534,8 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
>  {
>  	struct vm_area_struct *vma = vmf->vma;
>  
> -	vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
> +	vmf->page = __vm_normal_page(vma, vmf->address, vmf->orig_pte, false,
> +				     vmf->vma_flags);
>  	if (!vmf->page) {
>  		/*
>  		 * VM_MIXEDMAP !pfn_valid() case, or VM_SOFTDIRTY clear on a
> @@ -3706,7 +3709,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
>  	ptep_modify_prot_commit(vma, vmf->address, vmf->pte, old_pte, pte);
>  	update_mmu_cache(vma, vmf->address, vmf->pte);
>  
> -	page = vm_normal_page(vma, vmf->address, pte);
> +	page = __vm_normal_page(vma, vmf->address, pte, false, vmf->vma_flags);
>  	if (!page) {
>  		pte_unmap_unlock(vmf->pte, vmf->ptl);
>  		return 0;
> -- 
> 2.21.0
> 

