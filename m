Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7578F6B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 10:29:46 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id s131so75493796itd.6
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 07:29:46 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id r131si5486192pgr.225.2017.06.02.07.29.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 07:29:45 -0700 (PDT)
Subject: Re: [PATCH] mm: vmalloc: make vmalloc_to_page() deal with PMD/PUD
 mappings
References: <20170602112720.28948-1-ard.biesheuvel@linaro.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e98368d8-b1bc-5804-2115-370ec7109e9b@intel.com>
Date: Fri, 2 Jun 2017 07:29:42 -0700
MIME-Version: 1.0
In-Reply-To: <20170602112720.28948-1-ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, labbott@fedoraproject.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, zhongjiang@huawei.com, guohanjun@huawei.com, tanxiaojun@huawei.com

On 06/02/2017 04:27 AM, Ard Biesheuvel wrote:
> +static struct page *vmalloc_to_pud_page(unsigned long addr, pud_t *pud)
> +{
> +	struct page *page = NULL;
> +#ifdef CONFIG_HUGETLB_PAGE

Do we really want this based on hugetlbfs?  Won't this be dead code on x86?

Also, don't we discourage #ifdefs in .c files?

> +	pte_t pte = huge_ptep_get((pte_t *)pud);
> +
> +	if (pte_present(pte))
> +		page = pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);

x86 has pmd/pud_page().  Seems a bit silly to open-code it here.

> +#else
> +	VIRTUAL_BUG_ON(1);
> +#endif
> +	return page;
> +}

So if somebody manages to call this function on a huge page table entry,
but doesn't have hugetlbfs configured on, we kill the machine?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
