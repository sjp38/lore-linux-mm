Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E50CC31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:27:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AEAC208C4
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:27:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmwopensource.org header.i=@vmwopensource.org header.b="gYw3bH5a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AEAC208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A70046B0005; Wed, 12 Jun 2019 08:27:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FACB6B000A; Wed, 12 Jun 2019 08:27:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C2216B0269; Wed, 12 Jun 2019 08:27:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 214106B0005
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:27:19 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id v4so2650688ljk.15
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:27:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=6PDP5o7bl4rUA/772CcJlc+gJIZRm/9c226zDNSYBFc=;
        b=SaqSJhQ5CkGVvDCZQzSztmgsfjCtNTyibHJFj3pOhxyIzTdbM3ZwnaqTXOmT7OUGs8
         BdYi0SbWfHsNkJFEQjyxSRK+V3FH5qHAujye4FJtoeIlqM/cfXTYSp/LaJQuD1d5k5DX
         HexUx4jyhpUH6+f/St7T0ZgMPKlqJRLMjWy6gRL1fV0Zvi7LQvg+nrE/1cT5RlrNaoJt
         nIYnFIR6nRXFjJtCEW52BEwzYpSMfbwGk9NAROMeIWl9q7dOJQ1pvKqrjHWtUlBV1YeW
         tYy3lzJgyQuN/7iGX5KsyXgoQWFkqkkgCNXgRNW2ogCgOL2ZMb5Qf4jJ3DY/FWJRMvVb
         ZGZw==
X-Gm-Message-State: APjAAAUcXLVbw4B1JgHv1dsrkPqSXpMNqvgfPTx2l0CdYPRrYtjDImx7
	ynvwGPRCn8+a3+GRipkkHmC/eC509j4yjo6SX0iXMzfwXC0i74P3Nch40kfRcRgkXWSqwukEOPx
	SYiQy9OqG8uFAfWJ5eVO3cdTplM3hC3MgGOUpa0J9c2G/car/FEiJ1oWQoh8/t1D8DQ==
X-Received: by 2002:a2e:9bc6:: with SMTP id w6mr402820ljj.156.1560342438567;
        Wed, 12 Jun 2019 05:27:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuZ3MQBDY332P7b7cihqdoEKwz2z9wT/KyxCw3xd7UgKTIS/0DHFRm0kIX7DBkfAuZn0us
X-Received: by 2002:a2e:9bc6:: with SMTP id w6mr402760ljj.156.1560342437153;
        Wed, 12 Jun 2019 05:27:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560342437; cv=none;
        d=google.com; s=arc-20160816;
        b=gcjERianTSccE61z7NFTLiVC/+ZDwlD1K+P6MrYTRucIDAHyNhJL4cGSBcFIYsTWEE
         RSCkCKEotfrMw0FGiTn8+yhdWzxjW1q0HbMgWoyQRWqKXg2KU4G5VPFQPo1DKw8HbMwz
         xHbjiw6i0TNdnYDHzNGOscmYS78spXcdh5Uep+wtCra13Sg0TEjlS4oJExaWwbPKUyOR
         WU+lMV48jjJ+b+atmK4edLSysTlD6GyFJ/RDk/ZLeTrLnDLhCGk02UXfrILQK9yYXT/g
         SaGAN6MTOY3F2D//AFWZYoIS3mkDMiZULK1eDqeEpKwX3qMQ4aWkFSJMdEk/YrBt/qET
         4Hww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=6PDP5o7bl4rUA/772CcJlc+gJIZRm/9c226zDNSYBFc=;
        b=JV47WUa7xzxWWrKSDl6Gcdm6M6IwMxRBERz05SvJLH/LfDN+27ZxGeWUNGfzuOiYgW
         Rueg/ywZx1+awCVaaEX4DPgieyQlAb8S3DzfTozVZg5ladNF/nuKSPWRtYCzhr7WHz2B
         MxziTYWNtGhgU5Nlx4SbevtF67KUB0RG68H2/K5J7AqzSpLoGs/BfAJx6f4FN8vlws0s
         dp0tXca/veLsHwdxIkEUfkobd3S2zzUUo7hNZ83IUKNTu/PGMsuRya1TQdY8f+n8ikYt
         KQgtactpkrQsBpJbBvGELJ/ibAr8p6tRkjTBM45uTGi4dzdy6pKO8xC6puOkBe2QxZDK
         f9Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=gYw3bH5a;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.40 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from pio-pvt-msa1.bahnhof.se (pio-pvt-msa1.bahnhof.se. [79.136.2.40])
        by mx.google.com with ESMTPS id v71si16549297lje.161.2019.06.12.05.27.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 05:27:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.40 as permitted sender) client-ip=79.136.2.40;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=gYw3bH5a;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.40 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa1.bahnhof.se (Postfix) with ESMTP id 949F83F773;
	Wed, 12 Jun 2019 14:27:01 +0200 (CEST)
Authentication-Results: pio-pvt-msa1.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=gYw3bH5a;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa1.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa1.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VQ4Rb09IF_rR; Wed, 12 Jun 2019 14:26:47 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa1.bahnhof.se (Postfix) with ESMTPA id 0FA363F6C5;
	Wed, 12 Jun 2019 14:26:45 +0200 (CEST)
Received: from localhost.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 8059D3619A3;
	Wed, 12 Jun 2019 14:26:45 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560342405;
	bh=+5GVyhTYo8FM9oLssS/tZIxqS+/3NprZW4Ed/jkf8Xk=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=gYw3bH5a+sDW1srtGfX3oOPFaJmEUYHu9j4KFVytZjIqhibon/ppKhfZlZctk7Fvk
	 PhtyC1kk+A7lKxnjH/LHqYqw4477BqdjT1VhKZxTyHp8At7IPmCVDZ2TCBVaLPYrAt
	 K3B4Xpn4RuRjJN/syumfKiMEUG6emAiU6sRskopY=
Subject: Re: [PATCH v5 2/9] mm: Add an apply_to_pfn_range interface
To: Christoph Hellwig <hch@infradead.org>
Cc: dri-devel@lists.freedesktop.org, linux-graphics-maintainer@vmware.com,
 pv-drivers@vmware.com, linux-kernel@vger.kernel.org, nadav.amit@gmail.com,
 Thomas Hellstrom <thellstrom@vmware.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, Will Deacon <will.deacon@arm.com>,
 Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@surriel.com>,
 Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>,
 Huang Ying <ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm@kvack.org,
 Ralph Campbell <rcampbell@nvidia.com>
References: <20190612064243.55340-1-thellstrom@vmwopensource.org>
 <20190612064243.55340-3-thellstrom@vmwopensource.org>
 <20190612121604.GB719@infradead.org>
From: =?UTF-8?Q?Thomas_Hellstr=c3=b6m_=28VMware=29?=
 <thellstrom@vmwopensource.org>
Organization: VMware Inc.
Message-ID: <8f5a5b25-e21f-43f2-a4dd-a50debfd1287@vmwopensource.org>
Date: Wed, 12 Jun 2019 14:26:45 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190612121604.GB719@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/12/19 2:16 PM, Christoph Hellwig wrote:
> On Wed, Jun 12, 2019 at 08:42:36AM +0200, Thomas Hellström (VMware) wrote:
>> From: Thomas Hellstrom <thellstrom@vmware.com>
>>
>> This is basically apply_to_page_range with added functionality:
>> Allocating missing parts of the page table becomes optional, which
>> means that the function can be guaranteed not to error if allocation
>> is disabled. Also passing of the closure struct and callback function
>> becomes different and more in line with how things are done elsewhere.
>>
>> Finally we keep apply_to_page_range as a wrapper around apply_to_pfn_range
>>
>> The reason for not using the page-walk code is that we want to perform
>> the page-walk on vmas pointing to an address space without requiring the
>> mmap_sem to be held rather than on vmas belonging to a process with the
>> mmap_sem held.
>>
>> Notable changes since RFC:
>> Don't export apply_to_pfn range.
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Rik van Riel <riel@surriel.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Huang Ying <ying.huang@intel.com>
>> Cc: Souptick Joarder <jrdr.linux@gmail.com>
>> Cc: "Jérôme Glisse" <jglisse@redhat.com>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>>
>> Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
>> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com> #v1
>> ---
>>   include/linux/mm.h |  10 ++++
>>   mm/memory.c        | 135 ++++++++++++++++++++++++++++++++++-----------
>>   2 files changed, 113 insertions(+), 32 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 0e8834ac32b7..3d06ce2a64af 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -2675,6 +2675,16 @@ typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
>>   extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
>>   			       unsigned long size, pte_fn_t fn, void *data);
>>   
>> +struct pfn_range_apply;
>> +typedef int (*pter_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
>> +			 struct pfn_range_apply *closure);
>> +struct pfn_range_apply {
>> +	struct mm_struct *mm;
>> +	pter_fn_t ptefn;
>> +	unsigned int alloc;
>> +};
>> +extern int apply_to_pfn_range(struct pfn_range_apply *closure,
>> +			      unsigned long address, unsigned long size);
>>   
>>   #ifdef CONFIG_PAGE_POISONING
>>   extern bool page_poisoning_enabled(void);
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 168f546af1ad..462aa47f8878 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2032,18 +2032,17 @@ int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long
>>   }
>>   EXPORT_SYMBOL(vm_iomap_memory);
>>   
>> -static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
>> -				     unsigned long addr, unsigned long end,
>> -				     pte_fn_t fn, void *data)
>> +static int apply_to_pte_range(struct pfn_range_apply *closure, pmd_t *pmd,
>> +			      unsigned long addr, unsigned long end)
>>   {
>>   	pte_t *pte;
>>   	int err;
>>   	pgtable_t token;
>>   	spinlock_t *uninitialized_var(ptl);
>>   
>> -	pte = (mm == &init_mm) ?
>> +	pte = (closure->mm == &init_mm) ?
>>   		pte_alloc_kernel(pmd, addr) :
>> -		pte_alloc_map_lock(mm, pmd, addr, &ptl);
>> +		pte_alloc_map_lock(closure->mm, pmd, addr, &ptl);
>>   	if (!pte)
>>   		return -ENOMEM;
>>   
>> @@ -2054,86 +2053,109 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
>>   	token = pmd_pgtable(*pmd);
>>   
>>   	do {
>> -		err = fn(pte++, token, addr, data);
>> +		err = closure->ptefn(pte++, token, addr, closure);
>>   		if (err)
>>   			break;
>>   	} while (addr += PAGE_SIZE, addr != end);
>>   
>>   	arch_leave_lazy_mmu_mode();
>>   
>> -	if (mm != &init_mm)
>> +	if (closure->mm != &init_mm)
>>   		pte_unmap_unlock(pte-1, ptl);
>>   	return err;
>>   }
>>   
>> -static int apply_to_pmd_range(struct mm_struct *mm, pud_t *pud,
>> -				     unsigned long addr, unsigned long end,
>> -				     pte_fn_t fn, void *data)
>> +static int apply_to_pmd_range(struct pfn_range_apply *closure, pud_t *pud,
>> +			      unsigned long addr, unsigned long end)
>>   {
>>   	pmd_t *pmd;
>>   	unsigned long next;
>> -	int err;
>> +	int err = 0;
>>   
>>   	BUG_ON(pud_huge(*pud));
>>   
>> -	pmd = pmd_alloc(mm, pud, addr);
>> +	pmd = pmd_alloc(closure->mm, pud, addr);
>>   	if (!pmd)
>>   		return -ENOMEM;
>> +
>>   	do {
>>   		next = pmd_addr_end(addr, end);
>> -		err = apply_to_pte_range(mm, pmd, addr, next, fn, data);
>> +		if (!closure->alloc && pmd_none_or_clear_bad(pmd))
>> +			continue;
>> +		err = apply_to_pte_range(closure, pmd, addr, next);
>>   		if (err)
>>   			break;
>>   	} while (pmd++, addr = next, addr != end);
>>   	return err;
>>   }
>>   
>> -static int apply_to_pud_range(struct mm_struct *mm, p4d_t *p4d,
>> -				     unsigned long addr, unsigned long end,
>> -				     pte_fn_t fn, void *data)
>> +static int apply_to_pud_range(struct pfn_range_apply *closure, p4d_t *p4d,
>> +			      unsigned long addr, unsigned long end)
>>   {
>>   	pud_t *pud;
>>   	unsigned long next;
>> -	int err;
>> +	int err = 0;
>>   
>> -	pud = pud_alloc(mm, p4d, addr);
>> +	pud = pud_alloc(closure->mm, p4d, addr);
>>   	if (!pud)
>>   		return -ENOMEM;
>> +
>>   	do {
>>   		next = pud_addr_end(addr, end);
>> -		err = apply_to_pmd_range(mm, pud, addr, next, fn, data);
>> +		if (!closure->alloc && pud_none_or_clear_bad(pud))
>> +			continue;
>> +		err = apply_to_pmd_range(closure, pud, addr, next);
>>   		if (err)
>>   			break;
>>   	} while (pud++, addr = next, addr != end);
>>   	return err;
>>   }
>>   
>> -static int apply_to_p4d_range(struct mm_struct *mm, pgd_t *pgd,
>> -				     unsigned long addr, unsigned long end,
>> -				     pte_fn_t fn, void *data)
>> +static int apply_to_p4d_range(struct pfn_range_apply *closure, pgd_t *pgd,
>> +			      unsigned long addr, unsigned long end)
>>   {
>>   	p4d_t *p4d;
>>   	unsigned long next;
>> -	int err;
>> +	int err = 0;
>>   
>> -	p4d = p4d_alloc(mm, pgd, addr);
>> +	p4d = p4d_alloc(closure->mm, pgd, addr);
>>   	if (!p4d)
>>   		return -ENOMEM;
>> +
>>   	do {
>>   		next = p4d_addr_end(addr, end);
>> -		err = apply_to_pud_range(mm, p4d, addr, next, fn, data);
>> +		if (!closure->alloc && p4d_none_or_clear_bad(p4d))
>> +			continue;
>> +		err = apply_to_pud_range(closure, p4d, addr, next);
>>   		if (err)
>>   			break;
>>   	} while (p4d++, addr = next, addr != end);
>>   	return err;
>>   }
>>   
>> -/*
>> - * Scan a region of virtual memory, filling in page tables as necessary
>> - * and calling a provided function on each leaf page table.
>> +/**
>> + * apply_to_pfn_range - Scan a region of virtual memory, calling a provided
>> + * function on each leaf page table entry
>> + * @closure: Details about how to scan and what function to apply
>> + * @addr: Start virtual address
>> + * @size: Size of the region
>> + *
>> + * If @closure->alloc is set to 1, the function will fill in the page table
>> + * as necessary. Otherwise it will skip non-present parts.
>> + * Note: The caller must ensure that the range does not contain huge pages.
>> + * The caller must also assure that the proper mmu_notifier functions are
>> + * called before and after the call to apply_to_pfn_range.
>> + *
>> + * WARNING: Do not use this function unless you know exactly what you are
>> + * doing. It is lacking support for huge pages and transparent huge pages.
>> + *
>> + * Return: Zero on success. If the provided function returns a non-zero status,
>> + * the page table walk will terminate and that status will be returned.
>> + * If @closure->alloc is set to 1, then this function may also return memory
>> + * allocation errors arising from allocating page table memory.
>>    */
>> -int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>> -			unsigned long size, pte_fn_t fn, void *data)
>> +int apply_to_pfn_range(struct pfn_range_apply *closure,
>> +		       unsigned long addr, unsigned long size)
>>   {
>>   	pgd_t *pgd;
>>   	unsigned long next;
>> @@ -2143,16 +2165,65 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>>   	if (WARN_ON(addr >= end))
>>   		return -EINVAL;
>>   
>> -	pgd = pgd_offset(mm, addr);
>> +	pgd = pgd_offset(closure->mm, addr);
>>   	do {
>>   		next = pgd_addr_end(addr, end);
>> -		err = apply_to_p4d_range(mm, pgd, addr, next, fn, data);
>> +		if (!closure->alloc && pgd_none_or_clear_bad(pgd))
>> +			continue;
>> +		err = apply_to_p4d_range(closure, pgd, addr, next);
>>   		if (err)
>>   			break;
>>   	} while (pgd++, addr = next, addr != end);
>>   
>>   	return err;
>>   }
>> +
>> +/**
>> + * struct page_range_apply - Closure structure for apply_to_page_range()
>> + * @pter: The base closure structure we derive from
>> + * @fn: The leaf pte function to call
>> + * @data: The leaf pte function closure
>> + */
>> +struct page_range_apply {
>> +	struct pfn_range_apply pter;
>> +	pte_fn_t fn;
>> +	void *data;
>> +};
>> +
>> +/*
>> + * Callback wrapper to enable use of apply_to_pfn_range for
>> + * the apply_to_page_range interface
>> + */
>> +static int apply_to_page_range_wrapper(pte_t *pte, pgtable_t token,
>> +				       unsigned long addr,
>> +				       struct pfn_range_apply *pter)
>> +{
>> +	struct page_range_apply *pra =
>> +		container_of(pter, typeof(*pra), pter);
>> +
>> +	return pra->fn(pte, token, addr, pra->data);
>> +}
>> +
>> +/*
>> + * Scan a region of virtual memory, filling in page tables as necessary
>> + * and calling a provided function on each leaf page table.
>> + *
>> + * WARNING: Do not use this function unless you know exactly what you are
>> + * doing. It is lacking support for huge pages and transparent huge pages.
>> + */
>> +int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>> +			unsigned long size, pte_fn_t fn, void *data)
>> +{
>> +	struct page_range_apply pra = {
>> +		.pter = {.mm = mm,
>> +			 .alloc = 1,
>> +			 .ptefn = apply_to_page_range_wrapper },
>> +		.fn = fn,
>> +		.data = data
>> +	};
>> +
>> +	return apply_to_pfn_range(&pra.pter, addr, size);
>> +}
>>   
>>   EXPORT_SYMBOL_GPL(apply_to_page_range);
> Actually - did you look into converting our two hand full of
> apply_to_page_range callers to your new scheme?  It seems like that
> might actually not be to bad and avoid various layers of wrappers.

Yes, I had that in mind once this landed and got some serious testing.

/Thomas



