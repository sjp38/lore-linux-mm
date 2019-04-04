Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83F4EC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:52:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1702C2147C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:52:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QfMRF0P0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1702C2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73D7D6B0005; Thu,  4 Apr 2019 03:52:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 715466B0007; Thu,  4 Apr 2019 03:52:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 603CD6B0008; Thu,  4 Apr 2019 03:52:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 269906B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 03:52:45 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g1so1239600pfo.2
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 00:52:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cMJWzxe4Ao25HkpKxnpYPU9EEB9na0XP+peiUGUVxig=;
        b=BLlhLKB50mohoYCwbIeXWXciE1oX1GFOVKSoAkxDfylkx90dA+PhqNOLy2L74R/EAS
         2mwXdhf82H3lOSFFWsbsRuAgHC0HoMQ3EhIQcfOvo4lPgTFFqsZ7in2YJ481QOOwqtn3
         16nyhPaY1rKzEYlbb1yHpyFGdkuMGgd4ak7cKrY8DnQlyUNe8JEME+3brJhTYVlsiS6a
         xSbA7pcYRfY+n+ycIjxV+uBQk6z1Xng9kU2E8uwu4KVEpSZiMqMf+7uXVgWWGzYdcZKb
         y3F9IxzUQjD4Xfvoujotzs4Wk/Sh2QXrvXaeHtoxyqYWAS74O2vGZcFjmhmhH7P3CO9W
         0mvg==
X-Gm-Message-State: APjAAAXURBkI1VzZ5DigGniJ9sgbtuuWidOu9zL38tandiN+8r+8MxBL
	K3Hzc5X5Avj1out7L+3hff2csEQUIKROIjTmKpFkw/1q8YxbQ5LREL8yTXV1N5GRwCrhE4Ow49o
	mnTIS4lR0swNR2MIrRxRiz0kLtrRp6CAnzqXrA/9FsIEh+nvOQiJbC+8l6nCunbg80Q==
X-Received: by 2002:a63:ed10:: with SMTP id d16mr4356834pgi.75.1554364363218;
        Thu, 04 Apr 2019 00:52:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcsnp2qd+OjH0F71rTm5uyOpzK2uH6TN/7qxvJdwhcfxRbmuZzg6DCDqUQFOo+E4NrN4hZ
X-Received: by 2002:a63:ed10:: with SMTP id d16mr4356782pgi.75.1554364362301;
        Thu, 04 Apr 2019 00:52:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554364362; cv=none;
        d=google.com; s=arc-20160816;
        b=oVbcxIg9mf1TA8mD4Q8K+KIOVPSgYhiaWtz0cHjgBkIbLhoZgnRJ/U2wNvGcVnx54k
         le51uexMheRSlcmeGEMnU03aAllUiYliYhWIZ/PTgRruVEVaqFrqrCQqHdrGGacQsM99
         5P6lnHS93+P8J/2YqMDyCN7/bb2IbcBlDhzgvSy05WmJtdd+W9J/qlythfAuC8JI/Iq1
         t3MNpJ6WuYRqcoN8Sn5bYa9eo5A2BtXx4kHayptr5wYp0qlurbVfVT9D1VHwwOoLKfrf
         gRdzmZOylS0KY5rX4nIsEePvBxYsnUm4H8F2R4tB5XKg6yhMP5HspMUIExuKmi35otkb
         IAOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cMJWzxe4Ao25HkpKxnpYPU9EEB9na0XP+peiUGUVxig=;
        b=gjP6MeEg3wZ4sk7HLcqJvWcF3eypN9XpwclWPe1fku2cy+Ui6KZZhLbt26tV7ZCADI
         LZ0uJBNXtcxPNLBzVyT5/MuYHDsIgaeYiEhr2b1Zq8puhZebSM1tgyZzOChW6EdVDqxr
         E3RV4sXV+DGQtandamUCeii2l5ulwOVsnjIqZLI1O93540I3+gMYbX2QlCqD4W8qYpEG
         aDCxh+0DA6KLUbe/cf+8vUFaF0p5w2MInA9molSZ6J4Bj+HW11kkp3b2Eyw8T43gU8Ef
         zI8oRke7EJ34d6OBO97PjFTGI8kOdDCe/3VNjHDGEOT8NmRFaqZ+yIOXl5TF14M9p+mN
         CcAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QfMRF0P0;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m3si15229356pgp.263.2019.04.04.00.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 00:52:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QfMRF0P0;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=cMJWzxe4Ao25HkpKxnpYPU9EEB9na0XP+peiUGUVxig=; b=QfMRF0P0o4xB65zKJwlQQn3vD
	cFmhPptsCyvoTWqUCtdr2/GyQ6lQCYKQeUtoCWYwdO9lJqy0G+r51s/+otu96QwShwhDZZtDGnn89
	bHugKSoUDmx/nAKIvsQH04Kk6kHpMmy+MxrKGEp2z4OSRUM+Z1I5Ze6KLkQ4H9FhSA61hXC5tUszP
	RGP47SDri9X8Q1Sm9ck41cKQiBOAUlCvLBMWwrDsJpTTfCpqMpsOvW4OOCw2eJegBZzi0cQFiifDt
	8phiRtPVp1tnIxicGVce6xUBDhVhdzkO+5GR0BB9IXW+UMCy5E0ngOyFpFrnpUXhOFtFyqOY6SHiS
	Su54werTQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBxAN-0003vm-T6; Thu, 04 Apr 2019 07:52:08 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 3C8DD2022A093; Thu,  4 Apr 2019 09:52:06 +0200 (CEST)
Date: Thu, 4 Apr 2019 09:52:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de,
	ak@linux.intel.com, liran.alon@oracle.com, keescook@google.com,
	konrad.wilk@oracle.com,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
	jcm@redhat.com, boris.ostrovsky@oracle.com,
	kanth.ghatraju@oracle.com, joao.m.martins@oracle.com,
	jmattson@google.com, pradeep.vincent@oracle.com,
	john.haxby@oracle.com, tglx@linutronix.de,
	kirill.shutemov@linux.intel.com, hch@lst.de,
	steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
	dave.hansen@intel.com, aaron.lu@intel.com,
	akpm@linux-foundation.org, alexander.h.duyck@linux.intel.com,
	amir73il@gmail.com, andreyknvl@google.com,
	aneesh.kumar@linux.ibm.com, anthony.yznaga@oracle.com,
	ard.biesheuvel@linaro.org, arnd@arndb.de, arunks@codeaurora.org,
	ben@decadent.org.uk, bigeasy@linutronix.de, bp@alien8.de,
	brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
	cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
	dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
	hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
	james.morse@arm.com, jannh@google.com, jgross@suse.com,
	jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
	jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
	khlebnikov@yandex-team.ru, logang@deltatee.com,
	marco.antonio.780@gmail.com, mark.rutland@arm.com,
	mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
	mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
	m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
	paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
	rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
	rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
	rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
	serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
	vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
	yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
	ying.huang@intel.com, zhangshaokun@hisilicon.com,
	iommu@lists.linux-foundation.org, x86@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 04/13] xpfo, x86: Add support for XPFO for x86-64
Message-ID: <20190404075206.GP4038@hirez.programming.kicks-ass.net>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <c15e7d09dfe3dfdb9947d39ed0ddd6573ff86dbf.1554248002.git.khalid.aziz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c15e7d09dfe3dfdb9947d39ed0ddd6573ff86dbf.1554248002.git.khalid.aziz@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 11:34:05AM -0600, Khalid Aziz wrote:
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 2779ace16d23..5c0e1581fa56 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -1437,6 +1437,32 @@ static inline bool arch_has_pfn_modify_check(void)
>  	return boot_cpu_has_bug(X86_BUG_L1TF);
>  }
>  
> +/*
> + * The current flushing context - we pass it instead of 5 arguments:
> + */
> +struct cpa_data {
> +	unsigned long	*vaddr;
> +	pgd_t		*pgd;
> +	pgprot_t	mask_set;
> +	pgprot_t	mask_clr;
> +	unsigned long	numpages;
> +	unsigned long	curpage;
> +	unsigned long	pfn;
> +	unsigned int	flags;
> +	unsigned int	force_split		: 1,
> +			force_static_prot	: 1;
> +	struct page	**pages;
> +};
> +
> +
> +int
> +should_split_large_page(pte_t *kpte, unsigned long address,
> +			struct cpa_data *cpa);
> +extern spinlock_t cpa_lock;
> +int
> +__split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
> +		   struct page *base);
> +

I really hate exposing all that.

>  #include <asm-generic/pgtable.h>
>  #endif	/* __ASSEMBLY__ */
>  

> diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
> new file mode 100644
> index 000000000000..3045bb7e4659
> --- /dev/null
> +++ b/arch/x86/mm/xpfo.c
> @@ -0,0 +1,123 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
> + * Copyright (C) 2016 Brown University. All rights reserved.
> + *
> + * Authors:
> + *   Juerg Haefliger <juerg.haefliger@hpe.com>
> + *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published by
> + * the Free Software Foundation.
> + */
> +
> +#include <linux/mm.h>
> +
> +#include <asm/tlbflush.h>
> +
> +extern spinlock_t cpa_lock;
> +
> +/* Update a single kernel page table entry */
> +inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
> +{
> +	unsigned int level;
> +	pgprot_t msk_clr;
> +	pte_t *pte = lookup_address((unsigned long)kaddr, &level);
> +
> +	if (unlikely(!pte)) {
> +		WARN(1, "xpfo: invalid address %p\n", kaddr);
> +		return;
> +	}
> +
> +	switch (level) {
> +	case PG_LEVEL_4K:
> +		set_pte_atomic(pte, pfn_pte(page_to_pfn(page),
> +			       canon_pgprot(prot)));

(sorry, do we also need a nikon_pgprot() ? :-)

> +		break;
> +	case PG_LEVEL_2M:
> +	case PG_LEVEL_1G: {
> +		struct cpa_data cpa = { };
> +		int do_split;
> +
> +		if (level == PG_LEVEL_2M)
> +			msk_clr = pmd_pgprot(*(pmd_t *)pte);
> +		else
> +			msk_clr = pud_pgprot(*(pud_t *)pte);
> +
> +		cpa.vaddr = kaddr;
> +		cpa.pages = &page;
> +		cpa.mask_set = prot;
> +		cpa.mask_clr = msk_clr;
> +		cpa.numpages = 1;
> +		cpa.flags = 0;
> +		cpa.curpage = 0;
> +		cpa.force_split = 0;
> +
> +
> +		do_split = should_split_large_page(pte, (unsigned long)kaddr,
> +						   &cpa);
> +		if (do_split) {
> +			struct page *base;
> +
> +			base = alloc_pages(GFP_ATOMIC, 0);
> +			if (!base) {
> +				WARN(1, "xpfo: failed to split large page\n");

You have to be fcking kidding right? A WARN when a GFP_ATOMIC allocation
fails?!

> +				break;
> +			}
> +
> +			if (!debug_pagealloc_enabled())
> +				spin_lock(&cpa_lock);
> +			if  (__split_large_page(&cpa, pte, (unsigned long)kaddr,
> +						base) < 0) {
> +				__free_page(base);
> +				WARN(1, "xpfo: failed to split large page\n");
> +			}
> +			if (!debug_pagealloc_enabled())
> +				spin_unlock(&cpa_lock);
> +		}
> +
> +		break;

Ever heard of helper functions?

> +	}
> +	case PG_LEVEL_512G:
> +		/* fallthrough, splitting infrastructure doesn't
> +		 * support 512G pages.
> +		 */

Broken coment style.

> +	default:
> +		WARN(1, "xpfo: unsupported page level %x\n", level);
> +	}
> +
> +}
> +EXPORT_SYMBOL_GPL(set_kpte);
> +
> +inline void xpfo_flush_kernel_tlb(struct page *page, int order)
> +{
> +	int level;
> +	unsigned long size, kaddr;
> +
> +	kaddr = (unsigned long)page_address(page);
> +
> +	if (unlikely(!lookup_address(kaddr, &level))) {
> +		WARN(1, "xpfo: invalid address to flush %lx %d\n", kaddr,
> +		     level);
> +		return;
> +	}
> +
> +	switch (level) {
> +	case PG_LEVEL_4K:
> +		size = PAGE_SIZE;
> +		break;
> +	case PG_LEVEL_2M:
> +		size = PMD_SIZE;
> +		break;
> +	case PG_LEVEL_1G:
> +		size = PUD_SIZE;
> +		break;
> +	default:
> +		WARN(1, "xpfo: unsupported page level %x\n", level);
> +		return;
> +	}
> +
> +	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
> +}

You call this from IRQ/IRQ-disabled context... that _CANNOT_ be right.

