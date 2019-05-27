Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 251C2C28CBF
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 06:23:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB3DB2075E
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 06:23:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB3DB2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 725026B000C; Mon, 27 May 2019 02:23:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D4246B0266; Mon, 27 May 2019 02:23:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59C5D6B026B; Mon, 27 May 2019 02:23:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD176B000C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 02:23:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e21so26466741edr.18
        for <linux-mm@kvack.org>; Sun, 26 May 2019 23:23:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=wXU7IXNhTV1CWq8L01LaYW5UJ4S7AmQA4U0IHEhoIuw=;
        b=ZOkmPgxj6sgGx7rZxw/28dK4kg/3Q5ZxjwxwxR8+REQgDYPOQ6zAzClnf3GSYeqbd2
         omh9dYMKhKDwlVBr7Lc/Crrvr0wNAEABkAgGvZELMA36CwUTbk9L3fbyad5Ti7zQSjYO
         vyIRXnMLMcssr6S7rE/6J99sy5UvLEce/3novaVHdlW3hWNYnzS8Nm3wQAdiFKrPnvW1
         4R8B3PtQs3R0wZra6+Q6Bo4pOap7ariZTRYko64G11yjH7YeORN9UajU0xmiFJ90s1Tw
         piXPeQYd1d+kfwPU9YvHr1ZWV2jJNU5Ttq9HQN4hoHEHKItg5fnNlTL1/aHMKxTV7Vao
         841Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWKwTj0wf/tAvUv6oLBMZn3TWtjPau7bl5ipCHB1PLs1zdfta94
	fZnFtOhZMbfMM0hiNAY9pNUZI8NNOu1uPZgR0H8zlRft2XP0f83U/HzQ83BSyYNnR/T4u5vbnKL
	RUeuoWb1FdiNNPXaRsd2TNlWAAc/83l5Nm/jorsydMcNoXDA83JVxXaWOwBBNIaphvw==
X-Received: by 2002:a50:f706:: with SMTP id g6mr71108171edn.187.1558938185616;
        Sun, 26 May 2019 23:23:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUGty99BNjC31E/ZVkdaXjAqGUWsO2cVbJhX7uuPOdSwrDhcq5RtfqLO6rVgJlis1mqnTG
X-Received: by 2002:a50:f706:: with SMTP id g6mr71108122edn.187.1558938184824;
        Sun, 26 May 2019 23:23:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558938184; cv=none;
        d=google.com; s=arc-20160816;
        b=QmqM1bNXY4yvnHQIzOslNsCbmhyFfxLhO3eCM93nQH1T9juKL0+0yLfwFC79FJZE/B
         OQZXDeJ4rfgTG7NJi4qin0QtPY9Ii0rx2EMiWalQ5hz8cfrUvkGMXYFjzCfUPIc0SA9l
         w7oum9OjiHPeHJHZ8yiWN3Ql2luYjWf9nQKYyHg6o/nc1rCfZrSr5FGxiKCrl8hFnTYU
         9yMHfrI8A40GLU90lbmV8oTeanKEu9XpAKLIASUc/DhvIzYOIl3qebhj5hYegDOS3937
         u25IgmAWghQMFez/XAfdkfKG5yhZ1PTtdUtKjvQnFrUZL4y3QYveGeV9sCK6dMNCUYuW
         mXKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=wXU7IXNhTV1CWq8L01LaYW5UJ4S7AmQA4U0IHEhoIuw=;
        b=pKrqYq0pqNFT3La22+pmy/7O4N161LdHuKRyvNq1LE8g76RN5IKLV0IsRoYhqWv8Mu
         38D+L7foXskJuBM9ge/yUoVgg8tfX/MIq2DCSGvyXnfwLqQkxhL1L4bZKc3b5exbKDRT
         mwyfyTz6Dhf1KFiLU73EbAJVpD0zISvxal8fX6Uj+HuZNbHqIsIFIfp9R+XycuaFMPOT
         RlTg2XWUAZRXWnb571UOqXVdiYNDT4P7DE2WT5fkwIzk+YYNNvSgGbNJeUnKB7dBCL1Z
         t93gHlGISXw6z7g03+vZKoP1q6metzSZ4bneamMI4eK8ek7JfY17WWlIa/vjNlmL02iL
         e7Pw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w3si7706876edl.309.2019.05.26.23.23.04
        for <linux-mm@kvack.org>;
        Sun, 26 May 2019 23:23:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CDB861688;
	Sun, 26 May 2019 23:23:03 -0700 (PDT)
Received: from [10.162.40.17] (p8cg001049571a15.blr.arm.com [10.162.40.17])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 794233F59C;
	Sun, 26 May 2019 23:23:01 -0700 (PDT)
Subject: Re: [PATCH v3 4/4] arm64: mm: Implement pte_devmap support
To: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, catalin.marinas@arm.com,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
References: <cover.1558547956.git.robin.murphy@arm.com>
 <817d92886fc3b33bcbf6e105ee83a74babb3a5aa.1558547956.git.robin.murphy@arm.com>
 <20190524180805.GA9697@fuggles.cambridge.arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <b94b23a7-4e6f-7787-aaa8-3c2d355fad03@arm.com>
Date: Mon, 27 May 2019 11:53:13 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190524180805.GA9697@fuggles.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/24/2019 11:38 PM, Will Deacon wrote:
> On Thu, May 23, 2019 at 04:03:16PM +0100, Robin Murphy wrote:
>> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
>> index 2c41b04708fe..a6378625d47c 100644
>> --- a/arch/arm64/include/asm/pgtable.h
>> +++ b/arch/arm64/include/asm/pgtable.h
>> @@ -90,6 +90,7 @@ extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
>>  #define pte_write(pte)		(!!(pte_val(pte) & PTE_WRITE))
>>  #define pte_user_exec(pte)	(!(pte_val(pte) & PTE_UXN))
>>  #define pte_cont(pte)		(!!(pte_val(pte) & PTE_CONT))
>> +#define pte_devmap(pte)		(!!(pte_val(pte) & PTE_DEVMAP))
>>  
>>  #define pte_cont_addr_end(addr, end)						\
>>  ({	unsigned long __boundary = ((addr) + CONT_PTE_SIZE) & CONT_PTE_MASK;	\
>> @@ -217,6 +218,11 @@ static inline pmd_t pmd_mkcont(pmd_t pmd)
>>  	return __pmd(pmd_val(pmd) | PMD_SECT_CONT);
>>  }
>>  
>> +static inline pte_t pte_mkdevmap(pte_t pte)
>> +{
>> +	return set_pte_bit(pte, __pgprot(PTE_DEVMAP));
>> +}
>> +
>>  static inline void set_pte(pte_t *ptep, pte_t pte)
>>  {
>>  	WRITE_ONCE(*ptep, pte);
>> @@ -381,6 +387,9 @@ static inline int pmd_protnone(pmd_t pmd)
>>  
>>  #define pmd_mkhuge(pmd)		(__pmd(pmd_val(pmd) & ~PMD_TABLE_BIT))
>>  
>> +#define pmd_devmap(pmd)		pte_devmap(pmd_pte(pmd))
>> +#define pmd_mkdevmap(pmd)	pte_pmd(pte_mkdevmap(pmd_pte(pmd)))
>> +
>>  #define __pmd_to_phys(pmd)	__pte_to_phys(pmd_pte(pmd))
>>  #define __phys_to_pmd_val(phys)	__phys_to_pte_val(phys)
>>  #define pmd_pfn(pmd)		((__pmd_to_phys(pmd) & PMD_MASK) >> PAGE_SHIFT)
>> @@ -537,6 +546,11 @@ static inline phys_addr_t pud_page_paddr(pud_t pud)
>>  	return __pud_to_phys(pud);
>>  }
>>  
>> +static inline int pud_devmap(pud_t pud)
>> +{
>> +	return 0;
>> +}
>> +
>>  /* Find an entry in the second-level page table. */
>>  #define pmd_index(addr)		(((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1))
>>  
>> @@ -624,6 +638,11 @@ static inline phys_addr_t pgd_page_paddr(pgd_t pgd)
>>  
>>  #define pgd_ERROR(pgd)		__pgd_error(__FILE__, __LINE__, pgd_val(pgd))
>>  
>> +static inline int pgd_devmap(pgd_t pgd)
>> +{
>> +	return 0;
>> +}
> 
> I think you need to guard this and pXd_devmap() with
> CONFIG_TRANSPARENT_HUGEPAGE, otherwise you'll conflict with the dummy
> definitions in mm.h and the build will fail.

Just curious why pgd_devmap() also needs to be wrapped in TRANSPARENT_HUGEPAGE
config (or use this dummy otherwise). IIUC in case of DAX mappings there can
never be a huge mapping at PGD level. It only supports PMD or PUD based ones.

