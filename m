Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F817C282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 21:07:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1788218FF
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 21:07:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1788218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F46C6B0277; Fri, 12 Apr 2019 17:07:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57D226B0278; Fri, 12 Apr 2019 17:07:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41DEB6B0279; Fri, 12 Apr 2019 17:07:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6F86B0277
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 17:07:51 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g48so9994909qtk.19
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 14:07:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=a/OCSr8XaqUkI5aiV7QusERIfjmAwBR/pe3c/zK+q1A=;
        b=WNZviPajysHWPaduTDkLrbitSUOCanxzOwrtDsyZUHBRa/UHp5uFBF0z+BUsWzZSqG
         CjH3S0J/jFjZiZluKF7Q1+jxe9yZd6LSHPWE7xJszMUXyOh/54ey4Ua2QnNBWwyL4ejM
         jWDEEQ8pRbkkWQa1HY/WwgRdylP+aPtK+C6mPMajJA0EMLH+DQZZq/kxDjjPgqaTZES6
         ZNqzu//Jft5KAKFObsqp0X01ulLHEoXntdT8WGyAxzLMV8TsLs1MenXes3omfwGOh605
         d4bHClHWYKu96pDFH/h+zK3L0xlwLBsB4k2jGD7+AlCvIAL8YmxcgYIyeo2U6bNTH+yA
         4dzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU+B2YLNPNN9gz2VNDGQy6FU6GuIAWXW8nqd53z4xxIfSOo7bI1
	D9FnQWJnK3aH6WDQoG6eN2LQEEk1eqvCeK5nzBGgUR5xGwKbMTTQdo9TtXg7polKW4RO4NNBq/U
	DouTJB741+oFJ7DMbYFECa4dD//8f+lglXVGWP7HklTJHbOCl/2Ex1H4DKqDDCfjUtw==
X-Received: by 2002:a37:8d44:: with SMTP id p65mr44870251qkd.151.1555103270861;
        Fri, 12 Apr 2019 14:07:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWymWhggIOcHac9AAfnM2/k5OndlvxcdXkXLCk18SEoV7l+Ga1LEGaDzUhTsToZfiENV+f
X-Received: by 2002:a37:8d44:: with SMTP id p65mr44870188qkd.151.1555103270006;
        Fri, 12 Apr 2019 14:07:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555103270; cv=none;
        d=google.com; s=arc-20160816;
        b=Ytv36pV7rF212wJgS8cjgzaPydL62Kj1aUobw32ANVpjavsPFUAl17YO6ZHsf3wplA
         amLXyNsg02Pqr4cAOiCwZSyIrXe4jelyXATxgnsLXbH0+65f5MHn6LPIh9WXiVdLqSdF
         tujPvtmfDZg1A9Y/qD7px+NXQcxhvkMiZ4/OndIRwk/HIlAV9Qitv6xqa6VM5cbJClas
         tShM0J7QgtXLijTZ7jkU0ovurtI7Ej2dF7eqtGQd8NAtxZUZlfvrRN9Y+qsH6wHmTHAj
         W+emH0nDOcU82gJpcJX8WNAezD4MhI/RnLFfwlZT/0oWIPKeLmrofd8aWD05Q7YVYEtP
         8PKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=a/OCSr8XaqUkI5aiV7QusERIfjmAwBR/pe3c/zK+q1A=;
        b=ib0caEIDxEG4sRzqoIu2I3Mq5uRaB/bN7K+d3F91kw9PH9dEK8GNN0snfbTquWAazj
         9ffMhJTl6nn5RcjwgQtfSR+Lt9awSH0phqq+ahRd7tVfJpiCH3uLavfguS9fW6ynXy9a
         b9iuzPlM8JgPrNfV6w8wUP5XW+qI0TT80m5Ohs0tTqpV9btBgR4qe0Bi9Qcr3/e/845l
         5ZEvGKrlcXONhir5ggsuytbgL9TBEVP8ex7PufvArNxalJoVzJ1pfx60ghgL6wALundD
         HWcH6xD6MQvaFR6/yvH1qnpW7rVFlSic1ldENMa9GZQjPi8+VjYzEv2fWJ0dNLnNIT64
         k9Fw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u58si547835qte.185.2019.04.12.14.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 14:07:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ECAFC70008;
	Fri, 12 Apr 2019 21:07:48 +0000 (UTC)
Received: from redhat.com (ovpn-125-94.rdu2.redhat.com [10.10.125.94])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0D4135D6A9;
	Fri, 12 Apr 2019 21:07:46 +0000 (UTC)
Date: Fri, 12 Apr 2019 17:07:43 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH 2/9] mm: Add an apply_to_pfn_range interface
Message-ID: <20190412210743.GA19252@redhat.com>
References: <20190412160338.64994-1-thellstrom@vmware.com>
 <20190412160338.64994-3-thellstrom@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190412160338.64994-3-thellstrom@vmware.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 12 Apr 2019 21:07:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 04:04:18PM +0000, Thomas Hellstrom wrote:
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
> mmap_sem to be held rather thand on vmas belonging to a process with the
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
> Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
> ---
>  include/linux/mm.h |  10 ++++
>  mm/memory.c        | 130 ++++++++++++++++++++++++++++++++++-----------
>  2 files changed, 108 insertions(+), 32 deletions(-)
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
> index a95b4a3b1ae2..60d67158964f 100644
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
> @@ -1960,86 +1959,107 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
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
> + * called. Either in the pte leaf function or before and after the call to
> + * apply_to_pfn_range.

This is wrong there should be a big FAT warning that this can only be use
against mmap of device file. The page table walking above is broken for
various thing you might find in any other vma like THP, device pte, hugetlbfs,
...

Also the mmu notifier can not be call from the pfn callback as that callback
happens under page table lock (the change_pte notifier callback is useless
and not enough). So it _must_ happen around the call to apply_to_pfn_range

apply_to_page_range was really not meant to be use in that way ... it was not
for regular vma.

Using this function for anything else is dangerous and having its uses spread
more increase that risk. So there must be a big FAT warning saying that you
should not use this lightly and that it should only be only on mmap of device
file.


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
> @@ -2049,16 +2069,62 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
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
> + */

It would be good to improve that comment too and make it a warning of
DO NOT USE ! THIS IS NOT SAFE ON REGULAR VMA !

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
> 2.20.1
> 

