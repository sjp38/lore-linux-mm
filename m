Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 626DEC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 18:38:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B3CC2184E
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 18:38:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B3CC2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 658956B0269; Fri, 24 May 2019 14:38:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 609106B026F; Fri, 24 May 2019 14:38:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D2006B0272; Fri, 24 May 2019 14:38:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F1EF96B0269
	for <linux-mm@kvack.org>; Fri, 24 May 2019 14:38:50 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t58so15305510edb.22
        for <linux-mm@kvack.org>; Fri, 24 May 2019 11:38:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+CNS4/QN0kTGiR7qeGPRldZiuL+u8iFCnqXvZ5DvkRM=;
        b=UOxLjkB7pnF322Sq3/JSvx/ikOySDkSDZymUyafiVuJDFtVtlUt1nCf6iIoLbSX+Gf
         EqrLWTxyzUMKi7kwLfBbAlygeV8PdaaGn4URacV1lF4Abo4LwfAzM4CnTSC2LTznaYh9
         xggqnGtIuW0lELC82HAvwG20q0pMTvJ89jFlgKelOiGiBXgvxrLkREj4nrsOIOdmhfLR
         E8cc9mBa/iUPDNHrIbnBjwd988bcFNHnNMM5c0AliW4+m/9hi+iF1te5GltY5j+lFOrh
         Es+0LATH14LW4vTSv5783ihj0xR3PvrY53FH3ZCmH7GGWhs6GIxzFUn9CJx/DQEszrli
         OG2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAU2MkftIB0BYGcK1luRWr7DiavH60z5t9XDXZvOXiMlAu+Dxdty
	BqWDGTwO1VDS9n753Tjj01ea/jcYyJUuzOfjTK56EQmFG0lBDXUtDMKjQGeO6P4rAXPgsEmz3fW
	3MTZhJKHtuuFHTHtOF4TqU8ZkGI0cmyUvZFkhljxLYg7SWlXWHPgjMwOQiPFlpgOJwg==
X-Received: by 2002:a17:906:7053:: with SMTP id r19mr5178490ejj.101.1558723130514;
        Fri, 24 May 2019 11:38:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHt6P/NlYd4tbnBuevKst8M+yC2fyNpf2xs4xy9rKNgW9r2XDCSCTZb61VKEpb/6/axUC0
X-Received: by 2002:a17:906:7053:: with SMTP id r19mr5178438ejj.101.1558723129572;
        Fri, 24 May 2019 11:38:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558723129; cv=none;
        d=google.com; s=arc-20160816;
        b=UK4g0qDHVbnG/z1n+dXE5l0WqlW3ibcwvM8v66cSJk3yg19iVc9IeJkW5gHW3xJ+1p
         KhJgQCi7hJCSZPo58Dv5v1WotXWR3l88RgmEJ9aYAKgs+Xp18rYvBfqUj9OhW+Z+Qg+W
         ilHIqOKaPmfWUucAtwOhnHLzYysYxp52gvk4XvAPdBGYPjzWlKSkkSZcWHeM1KL6evBy
         F6DysILxVg2D3LmI5aPSWdzemzepQg9wHw0HxEJiKNLO51OynROnfuCZqbwacHreY5yh
         Nr3cvg8GmzmDO0oxjo9rljxchcl6bekXAzg97AtCLLUfV4h0u2U9VoWvU6YZRXpxcTN8
         ESbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+CNS4/QN0kTGiR7qeGPRldZiuL+u8iFCnqXvZ5DvkRM=;
        b=VnYv/nD2ZKJqZ/8KcJwPEkgCEP6Lg2M2ytb+oyNO+8VCw1r5VuSLwRfUR/EQ4OtzOb
         IxE6+i1t7C5tDIxJQn+zZ0+Sq6oN0dzux1kcesChcERbUrjaD2LHw7nsk0GcLLGXYgVX
         1ZRWhEKZ4ncMcVczR+4BTLtJ2UazGeCs9KCHH/lEODgLEI8T1Lyrw/UGA0LCiPtzsHIu
         QQalrWo47UE5/MrNx2vFuZGobRbN1PWxthzivCtkJv2mghOoLOELXfr5D/RglEpzknR6
         F5AImvbT501TseT4XIe1cCjttaw+WFkN2JNIVA+/KSOkTxjZ+wtTiffeaFZUmHybJbge
         Vf/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z16si2477585edb.381.2019.05.24.11.38.49
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 11:38:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7A341A78;
	Fri, 24 May 2019 11:38:48 -0700 (PDT)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 44BC53F703;
	Fri, 24 May 2019 11:38:47 -0700 (PDT)
Subject: Re: [PATCH v3 4/4] arm64: mm: Implement pte_devmap support
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, catalin.marinas@arm.com,
 anshuman.khandual@arm.com, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org
References: <cover.1558547956.git.robin.murphy@arm.com>
 <817d92886fc3b33bcbf6e105ee83a74babb3a5aa.1558547956.git.robin.murphy@arm.com>
 <20190524180805.GA9697@fuggles.cambridge.arm.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <9ef54c1b-b9a5-ed13-b9d6-65e7c4af0a75@arm.com>
Date: Fri, 24 May 2019 19:38:45 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190524180805.GA9697@fuggles.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 24/05/2019 19:08, Will Deacon wrote:
> On Thu, May 23, 2019 at 04:03:16PM +0100, Robin Murphy wrote:
>> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
>> index 2c41b04708fe..a6378625d47c 100644
>> --- a/arch/arm64/include/asm/pgtable.h
>> +++ b/arch/arm64/include/asm/pgtable.h
>> @@ -90,6 +90,7 @@ extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
>>   #define pte_write(pte)		(!!(pte_val(pte) & PTE_WRITE))
>>   #define pte_user_exec(pte)	(!(pte_val(pte) & PTE_UXN))
>>   #define pte_cont(pte)		(!!(pte_val(pte) & PTE_CONT))
>> +#define pte_devmap(pte)		(!!(pte_val(pte) & PTE_DEVMAP))
>>   
>>   #define pte_cont_addr_end(addr, end)						\
>>   ({	unsigned long __boundary = ((addr) + CONT_PTE_SIZE) & CONT_PTE_MASK;	\
>> @@ -217,6 +218,11 @@ static inline pmd_t pmd_mkcont(pmd_t pmd)
>>   	return __pmd(pmd_val(pmd) | PMD_SECT_CONT);
>>   }
>>   
>> +static inline pte_t pte_mkdevmap(pte_t pte)
>> +{
>> +	return set_pte_bit(pte, __pgprot(PTE_DEVMAP));
>> +}
>> +
>>   static inline void set_pte(pte_t *ptep, pte_t pte)
>>   {
>>   	WRITE_ONCE(*ptep, pte);
>> @@ -381,6 +387,9 @@ static inline int pmd_protnone(pmd_t pmd)
>>   
>>   #define pmd_mkhuge(pmd)		(__pmd(pmd_val(pmd) & ~PMD_TABLE_BIT))
>>   
>> +#define pmd_devmap(pmd)		pte_devmap(pmd_pte(pmd))
>> +#define pmd_mkdevmap(pmd)	pte_pmd(pte_mkdevmap(pmd_pte(pmd)))
>> +
>>   #define __pmd_to_phys(pmd)	__pte_to_phys(pmd_pte(pmd))
>>   #define __phys_to_pmd_val(phys)	__phys_to_pte_val(phys)
>>   #define pmd_pfn(pmd)		((__pmd_to_phys(pmd) & PMD_MASK) >> PAGE_SHIFT)
>> @@ -537,6 +546,11 @@ static inline phys_addr_t pud_page_paddr(pud_t pud)
>>   	return __pud_to_phys(pud);
>>   }
>>   
>> +static inline int pud_devmap(pud_t pud)
>> +{
>> +	return 0;
>> +}
>> +
>>   /* Find an entry in the second-level page table. */
>>   #define pmd_index(addr)		(((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1))
>>   
>> @@ -624,6 +638,11 @@ static inline phys_addr_t pgd_page_paddr(pgd_t pgd)
>>   
>>   #define pgd_ERROR(pgd)		__pgd_error(__FILE__, __LINE__, pgd_val(pgd))
>>   
>> +static inline int pgd_devmap(pgd_t pgd)
>> +{
>> +	return 0;
>> +}
> 
> I think you need to guard this and pXd_devmap() with
> CONFIG_TRANSPARENT_HUGEPAGE, otherwise you'll conflict with the dummy
> definitions in mm.h and the build will fail.

Ah, right you are - I got as far as catching similar issues with 
CONFIG_PGTABLE_LEVELS, but apparently I failed to spot the !THP guards 
in x86 and powerpc. Let me give this one a tweak and test a wider range 
of configs...

Robin.

