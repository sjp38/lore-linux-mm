Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05E1AC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:16:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A066320866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:16:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="O6/Ca4do"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A066320866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34CE46B0269; Wed, 12 Jun 2019 08:16:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FD766B026C; Wed, 12 Jun 2019 08:16:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19F466B026D; Wed, 12 Jun 2019 08:16:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D485A6B0269
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:16:26 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i33so9689412pld.15
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:16:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=tIxnk8MvoLwQgulJ+sk8wHtSJUEw45uxHJKuX+EnlJc=;
        b=Etiv11sCoBBhUJhVRfKbfnJz7md0v2AtqIZWF0hZTTlIIGa6h8xn8XDeh8tboaoHCl
         InURUMIUQZZ7Vu2XHA3rHUXvxcWsoavtrsbCf3VE9rD0ODexKcz9SWSasQqFNAa35f6L
         PoxouTd0pKJN8ZDkmsPEunicC7ZbcjeGJjjagS6b8hDMCD75zYuyLBZnMf75Mph1AdJR
         szs9vSXel77retDfasHLgk+Qd+ctsjTkbXyXra/2K/bChLFONyO62fXp1LaBRp5/2BUl
         xLzCYj5RN1tEMo8YAL/EmG9MkOPzMrbyX7kOLjiTvQ6vxq1s2T4YBtOz31LLWmu3ZRln
         +5ng==
X-Gm-Message-State: APjAAAWcZFP0wpeYYfKIzVvtRvmUCM4/VpFNbxR9dxoJ/Wp8AgfC2gMA
	RCI3PDZngIB6st4U32KiyZJKjOBziHiq8ynzqz0Lh5D0MRgol9iIuYgPv5oSPfn7TnKm9HFMjkj
	DzA+FXS7PliCjI2qrqIyB8byK2IjIldcaREPcH/nSiLmELI75nyvwprJwhtCFrG4Xpw==
X-Received: by 2002:a63:9502:: with SMTP id p2mr2716464pgd.12.1560341786315;
        Wed, 12 Jun 2019 05:16:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAbsvp3bqBeprw7lZ7KnXvMOmOZ2Xn5VtdMk087xeVjXPbYmZO3RK8lWq7ySyzjeoAlTLx
X-Received: by 2002:a63:9502:: with SMTP id p2mr2716409pgd.12.1560341785493;
        Wed, 12 Jun 2019 05:16:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560341785; cv=none;
        d=google.com; s=arc-20160816;
        b=WoDzThHBqDy2h3CPUmvp9tek6Vh/o0b5citEeUuOqfyZ9cxBqe7jDwBzxpUr3pPV/6
         uOgzNbEy//MbwJK3S20O+qSAdefEkgL97qN1MPWylvVq90etXdFwodhrd4h/A7mGBcg4
         UXmRv0CzueLVyA8cAvaxkFie4ao2aJSkyZaygqWv+lK5H8RMZoiz0dw4dqoo/emq0p0L
         ARikVNG9bFvbd2N8+UUmIrxIEKNjPJydKE3KePr+uV9qhTiwARkHoLiQGILQ5VfLoaOV
         MMFh2h7vxt8Nv+oMf6KqY27STBFpbqqQBKAMpVHcnPE4+NH6Alwpf/8cBRc3B17gCvyg
         m8bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=tIxnk8MvoLwQgulJ+sk8wHtSJUEw45uxHJKuX+EnlJc=;
        b=bi8Wo2HAqwM19TiVytqNkvq8e2oEDyHjgzpRB82WAgaqMtrjTy9D+2gXSM7Rm1bndl
         aZxIN8ITQ0TVvy+JhWrHu+GjP5HwsVSxtCkQpctaiTg45UQzZ+uWd5J5akTrunjo17YP
         /sD43k7qsLNNDRjHK78CR/YSidxMbTyH9/70RdBI4KGVjFvYzKkB4ws7JK1xGC+Y9SZ7
         WYcRu7j6UHLZwyJcH2Pf1gYtll5mH+CfSgtyW2/RDxTwhs8kCaQm9Y2kQOgkMsm52r3U
         6jE+8FPKeGQrb+RyN3rZJx7b0VYq8hdfH4winpamsGWEjvrywhq+y+Ig54z3DHf9Uc6k
         nyfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="O6/Ca4do";
       spf=pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x18si5188231pjq.71.2019.06.12.05.16.25
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 05:16:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="O6/Ca4do";
       spf=pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=tIxnk8MvoLwQgulJ+sk8wHtSJUEw45uxHJKuX+EnlJc=; b=O6/Ca4dohfi7iE5uK6IVe63p4n
	bgBkWH7cxGwdHnSwIgV/t5odMa9kf4ed1DUKPzta0O1AuTzdF4n8297KVyapevTRG+IbjwF+XbB/W
	CsNUkGiy5JEuSe3FKNI6LzoNZqwrn5oi7OrYS821cA/K6BroCbF5gaP7lVexN/+VpmAZERCvgxbqS
	2OnLisiV8W5ggNCC4nwiAgCA/aKBHrX97GpNJ+L/wRVuAIoggauA14mdOdoGYKrqpwGARDBBgPUL+
	8xeXxf+FKkF2firqEp+IEcRFzY7KeNNEeF46yb1+goa4xZGv4Ufm9RrPO++CUZYNP4Lu3ZtqOoDfH
	0fmtfbQQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hb2Ae-0003PJ-NQ; Wed, 12 Jun 2019 12:16:04 +0000
Date: Wed, 12 Jun 2019 05:16:04 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Thomas =?iso-8859-1?Q?Hellstr=F6m_=28VMware=29?= <thellstrom@vmwopensource.org>
Cc: dri-devel@lists.freedesktop.org, linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com, linux-kernel@vger.kernel.org,
	nadav.amit@gmail.com, Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>
Subject: Re: [PATCH v5 2/9] mm: Add an apply_to_pfn_range interface
Message-ID: <20190612121604.GB719@infradead.org>
References: <20190612064243.55340-1-thellstrom@vmwopensource.org>
 <20190612064243.55340-3-thellstrom@vmwopensource.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190612064243.55340-3-thellstrom@vmwopensource.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 08:42:36AM +0200, Thomas Hellström (VMware) wrote:
> From: Thomas Hellstrom <thellstrom@vmware.com>
> 
> This is basically apply_to_page_range with added functionality:
> Allocating missing parts of the page table becomes optional, which
> means that the function can be guaranteed not to error if allocation
> is disabled. Also passing of the closure struct and callback function
> becomes different and more in line with how things are done elsewhere.
> 
> Finally we keep apply_to_page_range as a wrapper around apply_to_pfn_range
> 
> The reason for not using the page-walk code is that we want to perform
> the page-walk on vmas pointing to an address space without requiring the
> mmap_sem to be held rather than on vmas belonging to a process with the
> mmap_sem held.
> 
> Notable changes since RFC:
> Don't export apply_to_pfn range.
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
> 
> Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com> #v1
> ---
>  include/linux/mm.h |  10 ++++
>  mm/memory.c        | 135 ++++++++++++++++++++++++++++++++++-----------
>  2 files changed, 113 insertions(+), 32 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0e8834ac32b7..3d06ce2a64af 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2675,6 +2675,16 @@ typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
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
> index 168f546af1ad..462aa47f8878 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2032,18 +2032,17 @@ int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long
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
> @@ -2054,86 +2053,109 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
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
> + * Note: The caller must ensure that the range does not contain huge pages.
> + * The caller must also assure that the proper mmu_notifier functions are
> + * called before and after the call to apply_to_pfn_range.
> + *
> + * WARNING: Do not use this function unless you know exactly what you are
> + * doing. It is lacking support for huge pages and transparent huge pages.
> + *
> + * Return: Zero on success. If the provided function returns a non-zero status,
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
> @@ -2143,16 +2165,65 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
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
> +
> +/**
> + * struct page_range_apply - Closure structure for apply_to_page_range()
> + * @pter: The base closure structure we derive from
> + * @fn: The leaf pte function to call
> + * @data: The leaf pte function closure
> + */
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
> + *
> + * WARNING: Do not use this function unless you know exactly what you are
> + * doing. It is lacking support for huge pages and transparent huge pages.
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
>  
>  EXPORT_SYMBOL_GPL(apply_to_page_range);

Actually - did you look into converting our two hand full of
apply_to_page_range callers to your new scheme?  It seems like that
might actually not be to bad and avoid various layers of wrappers.

